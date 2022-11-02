#!/bin/sh

echo "Setting up Dan's docker dotfiles..."

(cat <<EOF
alias d=docker

alias dcf="docker config"

alias dcm="docker compose"
alias dcmcr="docker compose create"
alias dcmdn="docker compose down"
alias dcmex="docker compose exec"
alias dcmh="docker compose --help"
alias dcmkl="docker compose kill"
alias dcmls="docker compose ls"
alias dcmrm="docker compose rm"
alias dcmru="docker compose ru"
alias dcmsr="docker compose start"
alias dcmso="docker compose stop"
alias dcmup="docker compose up"
alias dcmv="docker compose version"

alias dct="docker container"
alias dctex="docker container exec"
alias dcth="docker container --help"
alias dcti="docker container inspect"
alias dctls="docker container ls"
alias dctkl="docker container kill"
alias dctpr="docker container prune"
alias dctrm="docker container rm"
alias dctrn="docker container rename"
alias dctrs="docker container restart"
alias dctsr="docker container start"
alias dctst="docker container stats"
alias dctso="docker container stop"

alias dh="docker --help"

alias dim="docker image"
alias dimb="docker image build"
alias dimh="docker image --help"
alias dimhs="docker image history"
alias dimi="docker image inspect"
alias dimls="docker image ls"
alias dimpr="docker image prune"
alias dimpl="docker image pull"
alias dimps="docker image push"
alias dimrm="docker image rm"
alias dimt="docker image tag"

alias dnt="docker network"
alias dntcn="docker network connect"
alias dntcr="docker network create"
alias dntdc="docker network disconnect"
alias dnth="docker network --help"
alias dnti="docker network inspect"
alias dntls="docker network ls"
alias dntpr="docker network prune"
alias dntrm="docker network rm"

alias dsc="docker secret"
alias dsccr="docker secret create"
alias dsch="docker secret --help"
alias dsci="docker secret inspect"
alias dscls="docker secret ls"
alias dscrm="docker secret rm"

alias dv="docker version"

alias dvo="docker volume"
alias dvoh="docker volume --help"
alias dvocr="docker secret create"
alias dvoi="docker secret inspect"
alias dvols="docker secret ls"
alias dvopr="docker secret prune"
alias dvorm="docker secret rm"
EOF
) | "$(dirname "$0")/util/add-aliases.sh" "/home/$SUDO_USER/.bashrc" "docker"
