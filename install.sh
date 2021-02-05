#!/bin/bash

bash -c 'cat > /etc/motd' <<-'EOF'
 _____ _   _  _____ _____ ___   _      _      ___________
|_   _| \ | |/  ___|_   _/ _ \ | |    | |    |  ___|  _  \
  | | |  \| |\ `--.  | |/ /_\ \| |    | |    | |__ | | | |  _   _  ___ _   _  ___
  | | | . ` | `--. \ | ||  _  || |    | |    |  __|| | | | | | | |/ _ \ | | |/ _ \
 _| |_| |\  |/\__/ / | || | | || |____| |____| |___| |/ /  | |_| |  __/ |_| |  __/
 \___/\_| \_/\____/  \_/\_| |_/\_____/\_____/\____/|___/    \__, |\___|\__, |\___|
                                                             __/ |      __/ |
                                                            |___/      |___/
    Pterodactyl Network Panel Release 1.0 <-
    no copyright © 2069
EOF

set -e

SCRIPT_VERSION="v1.0"

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

output "Pterodactyl installation script @ $SCRIPT_VERSION"
output
output "https://github.com/icedmoca/pterodactylinstallscript"
output
output "This script is not associated with the official Pterodactyl Project or other scripts."

output

panel() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/$SCRIPT_VERSION/install-panel.sh)
}

wings() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/$SCRIPT_VERSION/install-wings.sh)
}

legacy_panel() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/$SCRIPT_VERSION/legacy/panel_0.7.sh)
}

legacy_wings() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/$SCRIPT_VERSION/legacy/daemon_0.6.sh)
}

canary_panel() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/master/install-panel.sh)
}

canary_wings() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactylinstallscript/master/install-wings.sh)
}

while [ "$done" == false ]; do
  options=(
    "Install the panel"
    "Install Wings"
    "Install both [0] and [1] on the same machine (wings script runs after panel)\n"

    "Install 0.7 version of panel (unsupported, no longer maintained!)"
    "Install 0.6 version of daemon (works with panel 0.7, no longer maintained!)"
    "Install both [3] and [4] on the same machine (daemon script runs after panel)\n"

    "Install panel with canary version of the script (the versions that lives in master, may be broken!)"
    "Install Wings with canary version of the script (the versions that lives in master, may be broken!)"
    "Install both [5] and [6] on the same machine (wings script runs after panel)"
  )

  actions=(
    "panel"
    "wings"
    "panel; wings"

    "legacy_panel"
    "legacy_wings"
    "legacy_panel; legacy_wings"

    "canary_panel"
    "canary_wings"
    "canary_panel; canary_wings"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]}-1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i=0;i<=${#actions[@]}-1;i+=1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done