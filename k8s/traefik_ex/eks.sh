#!/bin/bash
# Usage:
# --cmd=[
#     setup_eks_cluster |
#     takedown_eks_cluster |
#     pull_kubeflow_repo |
#     install_kubeflow |
#     install_traefik
# ]
# --eks_cluster_name --> EKS_CLUSTER_NAME
# --aws_region --> EKS_CLUSTER_REGION

# default args
EKS_CLUSTER_NAME="eks-traefik-fastapi"
EKS_CLUSTER_REGION="us-east-2"
K8S_VERSION=1.21


# Parse args
for i in "$@"; do
  case $i in
    -c=*|--cmd=*)
      CMD="${i#*=}"
      shift # past argument
      shift # past value
      ;;
    -n=*|--eks_cluster_name=*)
      EKS_CLUSTER_NAME="${i#*=}"
      shift # past argument
      shift # past value
      ;;
    -r=*|--aws_region=*)
      EKS_CLUSTER_REGION="${i#*=}"
      shift # past argument
      shift # past value
      ;;
esac
done

echo "Running --cmd=${CMD}"

case $CMD in

    install_traefik)
      # Deploy CRDs
      kubectl apply -f 0-crds.yaml  # https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/traefik/0-crds.yaml
      # Deploy RBAC
      kubectl apply -f 1-rbac.yaml  # https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/traefik/1-rbac.yaml

      # Create k8s tls secret w/ key and cert files fo *.mickelonius.com
      # CRT_FILE=/home/mike/Documents/SSL/mickelonius/STAR_mickelonius_com.crt
      # SSH_KEY_FILE=/home/mike/.ssh/private.key
      kubectl create secret tls mickelonius-tls --key=$SSH_KEY_FILE --cert=$CRT_FILE
      kubectl apply -f '1.5-tls-store.yaml'
      # Deploy Traefik Proxy
      kubectl apply -f 2-deployment.yaml  # https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/traefik/2-deployment.yaml

      # LoadBalancer Service
      # kubectl apply -f https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/traefik/services/3-service-lb.yaml

      # Output: The Service "traefik" is invalid: spec.ports: Invalid value: []core.ServicePort{core.ServicePort{Name:"web",
      # Protocol:"TCP", AppProtocol:(*string)(nil), Port:80, TargetPort:intstr.IntOrString{Type:0, IntVal:80, StrVal:""},
      # NodePort:0}, core.ServicePort{Name:"websecure-tcp", Protocol:"TCP", AppProtocol:(*string)(nil), Port:443,
      # TargetPort:intstr.IntOrString{Type:0, IntVal:443, StrVal:""}, NodePort:0}, core.ServicePort{Name:"websecure-udp",
      # Protocol:"UDP", AppProtocol:(*string)(nil), Port:443, TargetPort:intstr.IntOrString{Type:0, IntVal:443, StrVal:""}, NodePort:0}}:
      # may not contain more than 1 protocol when type is 'LoadBalancer'
      # Problem is, you are not authorized to create a LoadBalancer listing on both TCP and UDP simultaneously
      # This is due to a limitation of the AWS LoadBalancer Controller
      # (https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/1608#issuecomment-937346660)

      # Create a NodePort Service and create the NLB manually:
      # https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/traefik/services/3-service-node-port.yaml
      kubectl apply -f 3-service-node-port.yaml

      # Accessing the NodePort Service
      # You’ve just successfully created the NodePort. Now it’s time to create some AWS resources to access it.
      # The following commands will create a Network Load Balancer and configure it to forward the traffic to the
      # NodePort you just created.

      # Retrieve information about the EKS cluster:
      ## Retrieve the VPC ID.
      VPC_ID=$(aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --query 'cluster.resourcesVpcConfig.vpcId' --output=text)
      ## Retrieve the node group ID.
      NODE_GROUP_ID=$(aws eks list-nodegroups --cluster-name=${EKS_CLUSTER_NAME} --query 'nodegroups[0]' --output text)
      ## Retrieve instances subnet IDs.
      INSTANCES_SUBNET_IDS=$(aws ec2 describe-instances --filters Name=network-interface.vpc-id,Values=$VPC_ID "Name=tag:eks:nodegroup-name,Values=$NODE_GROUP_ID" --query 'Reservations[*].Instances[*].SubnetId' --output text | tr '\n' ' ')

      ## Create the Network Load Balancer with subnets retrieve just before.
      aws elbv2 create-load-balancer --name ${EKS_CLUSTER_NAME} \
        --type network \
        --subnets $(echo ${INSTANCES_SUBNET_IDS})

      ## Create the target group for the NLB:
      TG_NAME=${EKS_CLUSTER_NAME}-tg

      ## Create a TCP target group for web entrypoint on port 30442.
      aws elbv2 create-target-group --name ${TG_NAME}-web --protocol TCP --port 30442 --vpc-id ${VPC_ID} \
        --health-check-protocol TCP \
        --health-check-port 30442 \
        --target-type instance

      ## Create a TCP_UDP target group for websecure entrypoint on port 30443.
      aws elbv2 create-target-group --name ${TG_NAME}-websecure --protocol TCP_UDP --port 30443 --vpc-id ${VPC_ID} \
        --health-check-protocol TCP \
        --health-check-port 30443 \
        --target-type instance

      ## Create a TCP target group for web entrypoint on port 30444.
#      aws elbv2 create-target-group --name ${TG_NAME}-webapi --protocol TCP --port 30444 --vpc-id ${VPC_ID} \
#        --health-check-protocol TCP \
#        --health-check-port 30444 \
#        --target-type instance

      ## Retrieve instances IDs.
      INSTANCES=$(kubectl get nodes -o json | jq -r ".items[].spec.providerID"  | cut -d'/' -f5)
      IDS=$(for x in `echo ${INSTANCES}`; do echo Id=$x ; done | tr '\n' ' ')

      ## Retrieve the target group Arn for the web entrypoint.
      TG_ARN_WEB=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-web'].TargetGroupArn" --output text)
      ## Register instances to the previous TargetGroup web.
      aws elbv2 register-targets --target-group-arn ${TG_ARN_WEB} --targets $(echo ${IDS})

      ## Retrieve the target group Arn for the websecure entrypoint.
      TG_ARN_WEBSECURE=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-websecure'].TargetGroupArn" --output text)
      ## Register instances to the previous TargetGroup websecure.
      aws elbv2 register-targets --target-group-arn ${TG_ARN_WEBSECURE} --targets $(echo ${IDS})

#      TG_ARN_WEBAPI=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-webapi'].TargetGroupArn" --output text)
#      ## Register instances to the previous TargetGroup webapi.
#      aws elbv2 register-targets --target-group-arn ${TG_ARN_WEBAPI} --targets $(echo ${IDS})

      ## Retrieve the NLB Arn
      LB_ARN=$(aws elbv2 describe-load-balancers --names ${EKS_CLUSTER_NAME} --query 'LoadBalancers[0].LoadBalancerArn' --output text)

      ## Create a TCP listener on port 80 that will forward to the TargetGroup ${EKS_CLUSTER_NAME}-tg-web
      aws elbv2 create-listener --load-balancer-arn ${LB_ARN} \
        --protocol TCP --port 80 \
        --default-actions Type=forward,TargetGroupArn=${TG_ARN_WEB}

      ## Create a TCP_UDP listener on port 443 that will forward to the TargetGroup ${EKS_CLUSTER_NAME}-tg-websecure
      aws elbv2 create-listener --load-balancer-arn ${LB_ARN} \
        --protocol TCP_UDP --port 443 \
        --default-actions Type=forward,TargetGroupArn=${TG_ARN_WEBSECURE}

      # Create a TCP_UDP listener on port 8080 that will forward to the TargetGroup ${EKS_CLUSTER_NAME}-tg-webapi
#      aws elbv2 create-listener --load-balancer-arn ${LB_ARN} \
#        --protocol TCP --port 8080 \
#        --default-actions Type=forward,TargetGroupArn=${TG_ARN_WEBAPI}

      ## Configure instance security groups and retrieve the security group for each instances.
      SGs=$(for x in $(echo $INSTANCES); do aws ec2 describe-instances --filters Name=instance-id,Values=$x \
       --query 'Reservations[*].Instances[*].SecurityGroups[0].GroupId' --output text ; done | sort | uniq)

      for x in $(echo $SGs); do
        echo SG=$x;
        aws ec2 authorize-security-group-ingress --group-id $x --protocol tcp --port 30442 --cidr 0.0.0.0/0;
        aws ec2 authorize-security-group-ingress --group-id $x --protocol tcp --port 30443 --cidr 0.0.0.0/0;
#        aws ec2 authorize-security-group-ingress --group-id $x --protocol udp --port 30444 --cidr 0.0.0.0/0;
      done

      ## Retrieve the NLB Arn and extract the ID.
      NLB_NAME_ID=$(aws elbv2 describe-load-balancers --names ${EKS_CLUSTER_NAME} --query 'LoadBalancers[0].LoadBalancerArn' --output text | awk -F":loadbalancer/" '{print $2}')
      ## Retrieve the NLS DNS name.
      NLB_DNS_NAME=$(aws elbv2 describe-load-balancers --names ${EKS_CLUSTER_NAME} --query 'LoadBalancers[0].DNSName' --output text)

      # Access the Traefik Proxy dashboard:
      #open https://${NLB_DNS_NAME}/dashboard/
      kubectl apply -f traefik-dashboard-app.yaml  # https://raw.githubusercontent.com/traefik-tech-blog/traefik-http3/master/app/app.yaml
      #open https://${NLB_DNS_NAME}

      #Check your application with http3check:
      #open https://http3check.net/?host=${NLB_DNS_NAME}

      # This can be replaced by a separate application deployment step
      kubectl apply -f fastapi-app.yaml

      # This can be replaced by a separate application deployment step
      kubectl apply -f web-app.yaml
      ;;

    cleanup_traefik)
      kubectl delete -f fastapi-app.yaml
      kubectl delete -f web-app.yaml

      # Clean up
      LB_ARN=$(aws elbv2 describe-load-balancers --names ${EKS_CLUSTER_NAME} --query 'LoadBalancers[0].LoadBalancerArn' --output text)
      TG_ARN_WEB=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-web'].TargetGroupArn" --output text)
      TG_ARN_WEBSECURE=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-websecure'].TargetGroupArn" --output text)
#      TG_ARN_WEBAPI=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='${EKS_CLUSTER_NAME}-tg-webapi'].TargetGroupArn" --output text)

      ## Delete the Network Load Balancer.
      aws elbv2 delete-load-balancer --load-balancer-arn ${LB_ARN}

      ## Delete the 2 target groups created.
      aws elbv2 delete-target-group --target-group-arn ${TG_ARN_WEB}
      aws elbv2 delete-target-group --target-group-arn ${TG_ARN_WEBSECURE}
#      aws elbv2 delete-target-group --target-group-arn ${TG_ARN_WEBAPI}

      ## Delete the EKS cluster.
      eksctl delete cluster --name ${EKS_CLUSTER_NAME} #--region ${AWS_REGION}
      ;;

    setup_eks_cluster)
      echo "Creating EKS cluster [${EKS_CLUSTER_NAME}]"
      eksctl create cluster \
          --name ${EKS_CLUSTER_NAME} \
          --version ${K8S_VERSION} \
          --region ${EKS_CLUSTER_REGION} \
          --nodegroup-name linux-nodes \
          --node-type m5.xlarge \
          --nodes 5 \
          --nodes-min 5 \
          --nodes-max 10 \
          --managed \
          --with-oidc

      # If you are using an existing EKS cluster, create an OIDC provider
      # and associate it with for your EKS cluster with the following command:
      # eksctl utils associate-iam-oidc-provider --cluster ${EKS_CLUSTER_NAME} \
      #                                          --region ${EKS_CLUSTER_REGION} --approve

      echo "aws eks update-kubeconfig --region ${EKS_CLUSTER_REGION} --name ${EKS_CLUSTER_NAME}"
      ;;

    takedown_eks_cluster)
      echo "Deleting $EKS_CLUSTER_NAME"
      eksctl delete cluster --name $EKS_CLUSTER_NAME
      ;;

    print)
      echo "Print me!"
      ;;

  esac
