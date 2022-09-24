# Intro to RBAC
According to the official kubernetes docs:
> Role-based access control (RBAC) is a method of regulating access to computer
> or network resources based on the roles of individual users within an enterprise.

The core logical components of RBAC are:

#### Entity
A group, user, or service account (an identity representing an application that wants
to execute certain operations (actions) and requires permissions to do so).

#### Resource
A pod, service, or secret that the entity wants to access using the certain operations.

#### Role
Used to define rules for the actions the entity can take on various resources.

#### Role binding
This attaches (binds) a role to an entity, stating that the set of rules define the actions
permitted by the attached entity on the specified resources.

There are two types of Roles (Role, ClusterRole) and the respective bindings (RoleBinding, ClusterRoleBinding).
These differentiate between authorization in a namespace or cluster-wide.

#### Namespace
Namespaces are an excellent way of creating security boundaries, they also provide a unique
 scope for object names as the ‘namespace’ name implies. They are intended to be used in
 multi-tenant environments to create virtual kubernetes clusters on the same physical cluster.

## Install Test Pods
```
kubectl create namespace rbac-test
kubectl create deploy nginx --image=nginx -n rbac-test
```
To verify the test pods were properly installed, run:
```
kubectl get all -n rbac-test
```
Output should be similar to:
```
NAME                       READY   STATUS    RESTARTS   AGE
pod/nginx-5c7588df-8mvxx   1/1     Running   0          48s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           48s

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-5c7588df   1         1         1       48s
```

## Create new IAM user
Create a new user called rbac-user, and generate/save credentials for it:
```
aws iam create-user --user-name rbac-user
aws iam create-access-key --user-name rbac-user | tee /tmp/create_output.json
{
    "AccessKey": {
        "UserName": "rbac-user",
        "Status": "Active",
        "CreateDate": "2019-07-17T15:37:27Z",
        "SecretAccessKey": < AWS Secret Access Key > ,
        "AccessKeyId": < AWS Access Key >
    }
}
```
To make it easy to switch back and forth between the admin user you created the cluster
with, and this new rbac-user, run the following command to create a script that when
sourced, sets the active user to be rbac-user:
```
cat << EoF > rbacuser_creds.sh
export AWS_SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey /tmp/create_output.json)
export AWS_ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId /tmp/create_output.json)
EoF
```

## Map an IAM User to k8s
Next, we’ll define a k8s user called `rbac-user`, and map to its IAM user counterpart. Run
the following to get the existing `ConfigMap` and save into a file called `aws-auth.yaml`:
```
kubectl get configmap -n kube-system aws-auth -o yaml | grep -v "creationTimestamp\|resourceVersion\|selfLink\|uid" | sed '/^  annotations:/,+2 d' > aws-auth.yaml
```
Next append the rbac-user mapping to the existing configMap
```
cat << EoF >> aws-auth.yaml
data:
  mapUsers: |
    - userarn: arn:aws:iam::${ACCOUNT_ID}:user/rbac-user
      username: rbac-user
EoF
```
Some of the values may be dynamically populated when the file is created. To verify everything
populated and was created correctly, run the following:
```
cat aws-auth.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::123456789:user/rbac-user
      username: rbac-user
```
Next, apply the ConfigMap to apply this mapping to the system:
```
kubectl apply -f aws-auth.yaml
```

## Test the New User
Up until now, as the cluster operator, you’ve been accessing the cluster as the admin 
user. Let’s now see what happens when we access the cluster as the newly created rbac-user.

Issue the following command to source the `rbac-user`’s AWS IAM user environmental variables:
```
. rbacuser_creds.sh
```
By running the above command, you’ve now set AWS environmental variables which should override the 
default admin user or role. To verify we’ve overrode the default user settings, run the following command:
```
aws sts get-caller-identity
```
You should see something similar to below, where we’re now making API calls as rbac-user:
```{
    "Account": <AWS Account ID>,
    "UserId": <AWS User ID>,
    "Arn": "arn:aws:iam::<AWS Account ID>:user/rbac-user"
}
```
Now that we’re making calls in the context of the `rbac-user`, lets quickly make a request to get all pods:
```
kubectl get pods -n rbac-test

No resources found.  Error from server (Forbidden): pods is forbidden: User "rbac-user" cannot list 
resource "pods" in API group "" in the namespace "rbac-test"
```
We already created the `rbac-user`, so why did we get that error?

Just creating the user doesn’t give that user access to any resources in the cluster. In order to 
achieve that, we’ll need to define a role, and then bind the user to that role. We’ll do that next.

## Create the Role and Binding
As mentioned earlier, we have our new user `rbac-user`, but its not yet bound to any roles. In 
order to do that, we’ll need to switch back to our default admin user.

Run the following to unset the environmental variables that define us as `rbac-user`:
```
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
```
To verify we’re the admin user again, and no longer rbac-user, issue the following command:
```
aws sts get-caller-identity
#The output should show the user is no longer rbac-user:
{
    "Account": <AWS Account ID>,
    "UserId": <AWS User ID>,
    "Arn": "arn:aws:iam::<your AWS account ID>:assumed-role/eksworkshop-admin/i-123456789"
}
```
Now that we’re the `admin` user again, we’ll create a role called `pod-reader` that provides 
`list`, `get`, and `watch` access for pods and deployments, but only for the `rbac-test` namespace. 
Run the following to create this role:
```
cat << EoF > rbacuser-role.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: rbac-test
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["list","get","watch"]
- apiGroups: ["extensions","apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
EoF
```
We have the user, we have the role, and now we’re bind them together with a `RoleBinding` resource. 
Run the following to create this `RoleBinding`:
```
cat << EoF > rbacuser-role-binding.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: rbac-test
subjects:
- kind: User
  name: rbac-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EoF
```
Next, we apply the `Role`, and `RoleBinding`s we created:
```
kubectl apply -f rbacuser-role.yaml
kubectl apply -f rbacuser-role-binding.yaml
```

## Verify the Role and Binding
Now that the user, `Role`, and `RoleBinding` are defined, lets switch back 
to `rbac-user`, and test. To switch back to `rbac-user`, issue the following command
that sources the `rbac-user` env vars, and verifies they’ve taken:
```
. rbacuser_creds.sh; aws sts get-caller-identity
```
You should see output reflecting that you are logged in as rbac-user.
As rbac-user, issue the following to get pods in the rbac namespace:
```
kubectl get pods -n rbac-test

NAME                    READY     STATUS    RESTARTS   AGE
nginx-55bd7c9fd-kmbkf   1/1       Running   0          23h
```
Try running the same command again, but outside of the rbac-test namespace:
```
kubectl get pods -n kube-system

No resources found.
Error from server (Forbidden): pods is forbidden: User "rbac-user" cannot list resource "pods" in API group "" in the namespace "kube-system"
Because the role you are bound to does not give you access to any namespace other than rbac-test.
```

## Clean up
```
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
kubectl delete namespace rbac-test
rm rbacuser_creds.sh
rm rbacuser-role.yaml
rm rbacuser-role-binding.yaml
aws iam delete-access-key --user-name=rbac-user --access-key-id=$(jq -r .AccessKey.AccessKeyId /tmp/create_output.json)
aws iam delete-user --user-name rbac-user
rm /tmp/create_output.json
```
Next remove the rbac-user mapping from the existing configMap by editing the existing aws-auth.yaml file:
```
data:
  mapUsers: |
    []
```
And apply the ConfigMap and delete the aws-auth.yaml file
```
kubectl apply -f aws-auth.yaml
rm aws-auth.yaml
```
