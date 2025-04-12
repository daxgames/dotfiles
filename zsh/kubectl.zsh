if [[ -n "$(command -v kubectl)" ]] ; then
  source <(kubectl completion zsh)

  function kglFunc() {
    pod=$(kubectl get pods -n $1 | grep $2 |grep -v Terminating | awk '{print $1}')
    if [[ -n ${pod} ]] ; then
      echo "kubectl logs -n $1 ${pod} $3 -f"
      kubectl logs -n $1 ${pod} $3 -f
    fi
  }

  function kcns_func() {
    if [[ -n "${1}" ]] && [[ "$(kubectl config view --minify -o jsonpath='{..namespace}')" != "${1}" ]]; then
      kubectl config set-context --current --namespace $1
      echo -e "KUBECONFIG=${KUBECONFIG:-~/.kube/config}\nCurrent Context: $(kubectl config current-context)"
      echo Current Namespace: $1
    fi
  }

  function kcla() {
    account_id=$1
    cluster=$2
    account_name=$3
    profile=${4}
    region=${5}
    namespace=${6}

    echo awssso.sh ${profile}
    awssso.sh ${profile}

    . myenv

    kcl ${account_id} ${cluster} ${account_name} ${profile} ${region} ${namespace}
  }

  function kc() {
    account_id=$1
    cluster=$2
    account_name=$3
    profile=${4}
    region=${5}
    namespace=${6}

    kubeconfig_file=config
    [[ ${DOKCER} == true ]] && docker-root-${cluster}

    echo export KUBECONFIG=~/.kube/${kubeconfig_file}
    export KUBECONFIG=~/.kube/${kubeconfig_file}

    echo aws eks update-kubeconfig --name ${cluster} --region ${region} --profile ${profile}
    aws eks update-kubeconfig --name ${cluster} --region ${region} --profile ${profile}

    aws_arn_2=aws
    [[ ${region} =~ (-gov-) ]] && aws_arn_2=aws-us-gov

    echo kubectl config use-context arn:${aws_arn_2}:eks:${region}:${account_id}:cluster/${cluster} >/dev/null
    kubectl config use-context arn:${aws_arn_2}:eks:${region}:${account_id}:cluster/${cluster} >/dev/null

    kcns_func ${namespace}
  }


  function kcl() {
    account_id=$1
    cluster=$2
    account_name=$3
    profile=${4}
    region=${5}
    namespace=${6}

    kubeconfig_file=$cluster-${namespace}
    [[ ${DOKCER} == true ]] && docker-root-${cluster}

    echo export KUBECONFIG=~/.kube/${kubeconfig_file}
    export KUBECONFIG=~/.kube/${kubeconfig_file}

    echo aws eks update-kubeconfig --name ${cluster} --region ${region} --profile ${profile}
    aws eks update-kubeconfig --name ${cluster} --region ${region} --profile ${profile}

    aws_arn_2=aws
    [[ ${region} =~ (-gov-) ]] && aws_arn_2=aws-us-gov

    echo kubectl config use-context arn:${aws_arn_2}:eks:${region}:${account_id}:cluster/${cluster} >/dev/null
    kubectl config use-context arn:${aws_arn_2}:eks:${region}:${account_id}:cluster/${cluster} >/dev/null

    kcns_func ${namespace}
  }

  function kconsole() {
    export POD=`kubectl get pods | grep "$1" | awk '{ print $1}'`; kubectl exec -ti $POD $2 -- bash
  }

  function klog() {
    export POD=`kubectl get pods | grep "$1" | awk '{ print $1}'`; kubectl logs $POD $2
  }

  function klogf() {
    export POD=`kubectl get pods | grep "$1" | awk '{ print $1}'`; kubectl logs $POD $2 -f
  }

  alias k='kubectl'
  alias kcq='echo -e "KUBECONFIG=${KUBECONFIG:-~/.kube/config}\nCurrent Context: $(kubectl config current-context)"'
  alias kcns='kcns_func $*'
  alias kcols='kkubectl get pods -o jsonubectl get pods -o jsonpath="{.spec.containers[*].name}"'
  alias kg='kubectl get'
  alias kgpo='kubectl get pods'
  alias kgde='kubectl get deployments'
  alias kgsv='kubectl get services'
  alias kgns='kubectl get namespaces'
  alias kgse='kubectl get secrets'
  alias kgco='kubectl get configmaps'
  alias kgno='kubectl get nodes'
  alias kgev='kubectl get events'
  alias kd='kubectl describe'
  alias kdpo='kubectl describe pods'
  alias kdde='kubectl describe deployments'
  alias kdsv='kubectl describe services'
  alias kdns='kubectl describe namespaces'
  alias kdse='kubectl describe secrets'
  alias kdco='kubectl describe configmaps'
  alias kdno='kubectl describe nodes'
  alias kdel='kubectl delete'
  alias kdelpo='kubectl delete pods'
  alias kdelde='kubectl delete deployments'
  alias kdelsv='kubectl delete services'
  alias kdelns='kubectl delete namespaces'
  alias kdelse='kubectl delete secrets'
  alias kdelco='kubectl delete configmaps'
  alias kdelse='kubectl delete secrets'
  alias kdelno='kubectl delete nodes'
  alias kex='kubectl exec -it'
fi
