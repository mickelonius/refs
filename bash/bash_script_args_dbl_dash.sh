
# > demo-space-separated.sh -e conf -s /etc /etc/hosts
#FILE EXTENSION  = conf
#SEARCH PATH     = /etc
#DEFAULT         =
#Number files in SEARCH PATH with EXTENSION: 14
#Last line of file specified as non-opt/last argument:
##93.184.216.34    example.com

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--extension)
      EXTENSION="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--searchpath)
      SEARCHPATH="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters