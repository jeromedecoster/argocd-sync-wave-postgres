#!/bin/bash

log()   { echo -e "\e[30;47m ${1} \e[0m ${@:2}"; }        # $1 background white
info()  { echo -e "\e[48;5;28m ${1} \e[0m ${@:2}"; }      # $1 background green
warn()  { echo -e "\e[48;5;202m ${1} \e[0m ${@:2}" >&2; } # $1 background orange
error() { echo -e "\e[48;5;196m ${1} \e[0m ${@:2}" >&2; } # $1 background red

# the directory containing the script file
export PROJECT_DIR="$(cd "$(dirname "$0")"; pwd)"

#
# variables
#
[[ -f $PROJECT_DIR/.env ]] \
    && source $PROJECT_DIR/.env \
    || warn WARN .env file is missing


#
# overwrite TF variables
#
export TF_VAR_project_name=$PROJECT_NAME
export TF_VAR_app_name=$APP_NAME
export TF_VAR_aws_region=$AWS_REGION
export TF_VAR_github_owner=$GITHUB_OWNER
export TF_VAR_github_token=$GITHUB_TOKEN
export TF_VAR_github_repo=$GITHUB_REPO


# log $1 in underline then $@ then a newline
under() {
    local arg=$1
    shift
    echo -e "\033[0;4m${arg}\033[0m ${@}"
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}

env-create() {
  local AWS_PROFILE=default
    
  # root account id
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
      --query 'Account' \
      --profile $AWS_PROFILE \
      --output text)
  log AWS_ACCOUNT_ID $AWS_ACCOUNT_ID

    # setup .env file with default values
    scripts/env-file.sh .env \
        AWS_PROFILE=$AWS_PROFILE \
        AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID \
        PROJECT_NAME=sync-wave \
        APP_NAME=vote

    # setup .env file again
    # /!\ use your own values
    scripts/env-file.sh .env \
        AWS_REGION=eu-west-3 \
        GITHUB_OWNER=jeromedecoster \
        GITHUB_REPO=git@github.com:jeromedecoster/argocd-sync-wave-postgres.git \
        GITHUB_TOKEN=

    # install stern if missing
    # https://github.com/stern/stern
    if [[ -z $(which stern) ]]
    then
        log INSTALL stern
        # ask sudo access
        warn WARN sudo is required...
        sudo echo >/dev/null
        # one more check if the user abort the password question
        [[ -z `sudo -n uptime 2>/dev/null` ]] && { error ABORT sudo required; exit 0; }
        
        # -s, --silent : Silent  or  quiet  mode. Don't show progress meter or error messages.
        # -f, --fail : fail  silently  (no output at all) on server errors.
        # curl https://gobinaries.com/davidrjonas/semver-cli --fail --silent | sh

        local TEMP_DIR=$(mktemp --directory /tmp/stern-XXXX)
        cd $TEMP_DIR
        OS="$(uname | tr '[:upper:]' '[:lower:]')"
        log OS $OS

        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
        log ARCH $ARCH

        curl -fsSL https://api.github.com/repos/stern/stern/releases/latest > data.json

        FILE=$(jq -r '.assets[].name' data.json | grep $OS | grep $ARCH)
        log FILE $FILE

        # -f, --fail : fail  silently  (no output at all) on server errors.
        # -s, --silent : Silent  or  quiet  mode. Don't show progress meter or error messages.
        # -S, --show-error : When used with -s, --silent, it makes curl show an error message if it fails.
        # -L, --location : If the server reports that the requested page has moved to a different location,
        #                  curl redo the request on the new place.
        # -O, --remote-name : Write output to a local file named like the remote file we get.
        curl -fsSLO $(jq -r .assets[].browser_download_url data.json | grep $FILE)
        tar zxvf "$FILE" stern
        sudo mv stern /usr/local/bin
    fi
}

# 2) run postgres alpine docker image
pg() {
  # stop previous
  ID=$(docker stop $(docker ps -a -q -f name=postgres) 2>/dev/null)
  if [[ -n "$ID" ]]; then
    docker rm --force $ID 2>/dev/null
  fi

  docker run \
    --rm \
    --name postgres \
    --env POSTGRES_PASSWORD=password \
    --publish 5432:5432 \
    postgres:15.0-alpine
}

# 2) seed postgres instance
seed() {
  psql postgresql://postgres:password@0.0.0.0:5432/postgres < sql/create.sql
}

# 2) run vote website using npm - dev mode
vote() {
  cd vote
  # https://unix.stackexchange.com/a/454554
  command npm install
  npx livereload . --wait 200 --extraExts 'njk' & \
    NODE_ENV=development \
    VERSION=0.0.1 \
    WEBSITE_PORT=4000 \
    POSTGRES_USER=postgres \
    POSTGRES_HOST=0.0.0.0 \
    POSTGRES_DATABASE=postgres \
    POSTGRES_PASSWORD=password \
    POSTGRES_PORT=5432 \
    npx nodemon --ext js,json,njk index.js
}

# terraform init (updgrade) + validate
terraform-init() {
  CHDIR="$PROJECT_DIR/terraform/infra" scripts/terraform-init.sh
  CHDIR="$PROJECT_DIR/terraform/build-push" scripts/terraform-init.sh
  CHDIR="$PROJECT_DIR/terraform/kind-argocd" scripts/terraform-init.sh
  CHDIR="$PROJECT_DIR/terraform/secrets" scripts/terraform-init.sh
  CHDIR="$PROJECT_DIR/terraform/templates" scripts/terraform-init.sh
}

# terraform create ecr repo + ssh key
infra-create() {
  CHDIR="$PROJECT_DIR/terraform/infra" scripts/terraform-apply.sh
}

# build + push docker image to ecr
build-ecr-push() {
  CHDIR="$PROJECT_DIR/terraform/build-push" scripts/terraform-apply.sh

  docker images \
    --filter="reference=$PROJECT_NAME-$APP_NAME" \
    --filter="reference=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME-$APP_NAME"
}

# setup kind + argocd + image updater
kind-argocd-create() {
  CHDIR="$PROJECT_DIR/terraform/kind-argocd" scripts/terraform-apply.sh
}

# create namespaces + secrets
secrets-create() {
  CHDIR="$PROJECT_DIR/terraform/secrets" scripts/terraform-apply.sh
}

# create files using templates
templates-create() {
  CHDIR="$PROJECT_DIR/terraform/templates" scripts/terraform-apply.sh
}

# open argocd (website)
argocd-open() {
  log KIND_LISTEN_ADDRESS $KIND_LISTEN_ADDRESS
  log KIND_LOCALHOST_PORT $KIND_LOCALHOST_PORT

  ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
      --namespace argocd \
      --output jsonpath="{.data.password}" |
      base64 --decode)
  log ARGOCD_PASSWORD $ARGOCD_PASSWORD
  scripts/env-file.sh .env ARGOCD_PASSWORD=$ARGOCD_PASSWORD

  # xdg-open https://0.0.0.0:8443
  info OPEN $KIND_LISTEN_ADDRESS:$KIND_LOCALHOST_PORT
  if [[ -n $(which xdg-open) ]]; then
      xdg-open https://$KIND_LISTEN_ADDRESS:$KIND_LOCALHOST_PORT
  elif [[ -n $(which open) ]]; then
      open https://$KIND_LISTEN_ADDRESS:$KIND_LOCALHOST_PORT
  fi

  warn ACCEPT insecure self-signed certificate
  info LOGIN admin
  info PASSWORD $ARGOCD_PASSWORD
}

# argocd login (terminal)
argocd-login() {
  log KIND_LISTEN_ADDRESS $KIND_LISTEN_ADDRESS
  log KIND_LOCALHOST_PORT $KIND_LOCALHOST_PORT
  
  ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
      --namespace argocd \
      --output jsonpath="{.data.password}" |
      base64 --decode)
  log ARGOCD_PASSWORD $ARGOCD_PASSWORD
  scripts/env-file.sh .env ARGOCD_PASSWORD=$ARGOCD_PASSWORD
  
  # must match kind_config.node[role = "control-plane"].extra_port_mappings[container_port = 30080]
  argocd login $KIND_LISTEN_ADDRESS:$KIND_LOCALHOST_PORT \
      --insecure \
      --username=admin \
      --password=$ARGOCD_PASSWORD
}

# watch logs using stern
watch-logs() {
  stern . --namespace vote-app
}

# watch all within namespace
watch-all() {
  watch --interval 1 kubectl get all --namespace vote-app
}

# watch pods using kubectl
watch-pods() {
  kubectl get pods --namespace vote-app --watch
}

watch-events() {
  # https://kubernetes.io/docs/reference/kubectl/#custom-columns
  kubectl get event \
    --output=custom-columns=TIME:.firstTimestamp,NAME:.metadata.name,REASON:.reason \
    --namespace vote-app \
    --watch
}

app-no-sync-create() {
  kubectl apply -f argocd/application-no-sync.yaml
}

app-no-sync-destroy() {
  kubectl delete -f argocd/application-no-sync.yaml
}

app-sync-create() {
  kubectl apply -f argocd/application-sync.yaml
}

app-sync-destroy() {
  kubectl delete -f argocd/application-sync.yaml
}

infra-destroy() {
  terraform -chdir=$PROJECT_DIR/terraform/infra destroy -auto-approve
}

kind-argocd-destroy() {
  terraform -chdir=$PROJECT_DIR/terraform/kind-argocd destroy -auto-approve
}

secrets-destroy() {
  terraform -chdir=$PROJECT_DIR/terraform/secrets destroy -auto-approve
}

# # terraform destroy all
# terraform-destroy() {
#   terraform -chdir=$PROJECT_DIR/terraform/secrets destroy -auto-approve
#   terraform -chdir=$PROJECT_DIR/terraform/build-push destroy -auto-approve
#   terraform -chdir=$PROJECT_DIR/terraform/kind-argocd destroy -auto-approve
#   terraform -chdir=$PROJECT_DIR/terraform/infra destroy -auto-approve
#   terraform -chdir=$PROJECT_DIR/terraform/infra destroy -auto-approve
# }

# if `$1` is a function, execute it. Otherwise, print usage
# compgen -A 'function' list all declared functions
# https://stackoverflow.com/a/2627461
FUNC=$(compgen -A 'function' | grep $1)
[[ -n $FUNC ]] && {
    info EXECUTE $1
    eval $1
} || usage
exit 0
