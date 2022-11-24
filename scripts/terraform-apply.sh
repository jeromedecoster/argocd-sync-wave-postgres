#!/bin/bash

log()   { echo -e "\e[30;47m ${1} \e[0m ${@:2}"; }        # $1 background white
info()  { echo -e "\e[48;5;28m ${1} \e[0m ${@:2}"; }      # $1 background green
warn()  { echo -e "\e[48;5;202m ${1} \e[0m ${@:2}" >&2; } # $1 background orange
error() { echo -e "\e[48;5;196m ${1} \e[0m ${@:2}" >&2; } # $1 background red

log START $(date "+%Y-%d-%m %H:%M:%S")
START=$SECONDS

show_duration() {
    local elapsed=$(($SECONDS - $START))

    # https://stackoverflow.com/a/8903280/1503073
    [[ $elapsed -gt 59 ]] && { local min=$(($elapsed / 60)) ; } || { local min=0 ; }
    local sec=$(($elapsed % 60))

    [[ $min -lt 10 ]] && min=0$min ;
    [[ $sec -lt 10 ]] && sec=0$sec ;

    info DURATION $min:$sec
}

# https://www.cyberciti.biz/faq/linux-bash-exit-status-set-exit-statusin-bash/
# exit code `0` : Success
# exit code `1` : Operation not permitted
check_exit_code() {
    [[ $1 == 0 ]] && return
    error ABORT exit code $1 returned
    show_duration
    exit 0
}

[[ -z $(printenv | grep ^CHDIR=) ]] \
    && { error ABORT CHDIR env variable is required; exit 1; } \
    || log CHDIR $CHDIR
    
# list all TF_VAR_ variables available in enviroment variables
while read line; do
    TF_VAR=$(echo $line | cut -d '=' -f 1)
    VALUE=$(echo $line | cut -d '=' -f 2-)
    log $TF_VAR $VALUE
done < <(printenv | grep ^TF_VAR_)

# https://www.terraform.io/cli/commands/fmt
info TERRAFORM fmt
terraform -chdir="$CHDIR" fmt -recursive
# abort if exit code != 0
check_exit_code $?


# https://www.terraform.io/cli/commands/validate
info TERRAFORM validate
terraform -chdir="$CHDIR" validate
# abort if exit code != 0
check_exit_code $?


# https://www.terraform.io/cli/commands/plan
info TERRAFORM plan
terraform -chdir="$CHDIR" plan -out=terraform.plan
# abort if exit code != 0
check_exit_code $?

    
# https://www.terraform.io/cli/commands/apply
info TERRAFORM apply
terraform -chdir="$CHDIR" apply -auto-approve terraform.plan
# abort if exit code != 0
check_exit_code $?


log END $(date "+%Y-%d-%m %H:%M:%S")
show_duration