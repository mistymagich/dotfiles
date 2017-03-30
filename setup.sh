#!/usr/bin/env bash

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)



# Helpers
# @see [emacs.d/tput-helpers at ac153e108efe3125c014cbb79b0e0caaf908268b · jpablobr/emacs.d](https://github.com/jpablobr/emacs.d/blob/ac153e108efe3125c014cbb79b0e0caaf908268b/vendor/snippets/yasnippets-jpablobr/sh-mode/tput-helpers)
# @see [私が他人のシェルスクリプトから学んだこと | Yakst](https://yakst.com/ja/posts/31)
# -----------------------------------------------------------------

info() {
    echo "$(tput setaf 2)[INFO]$(tput op) $1"
}

error() {
    echo "$(tput setaf 1)[ERROR]$(tput op) $1"
}

warning() {
    echo "$(tput setaf 3)[WARN]$(tput op) $1"
}

section() {
   echo -e "\n$(tput setaf 5)###$(tput op) $1"
}



# create link dotfiles
# -----------------------------------------------------------------
section "Create dotfiles link"
FINDPARAM='-maxdepth 1 -not -path . -not -path .. -not -regex .+/.git'
find -name ".*" -not -path "." -not -name ".git" -exec rm -rf ~/{} \;
yes|find `pwd` ${FINDPARAM} -name ".*" -ok ln -s {} ${HOME}/ \; 2> /dev/null



# ~/.ssh/authorized_keys
# @see https://github.com/claytron/dotfiles/blob/master/create_links.sh
# -----------------------------------------------------------------
section "Add SSH pubkey"
FINDPARAM='-maxdepth 1 -not -path . -not -path .. -not -regex .+/.git'
[ ! -d "$HOME/.ssh" ] && mkdir "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
actual_dotfile="/tmp/authorized_keys"
to_create="$HOME/.ssh/authorized_keys"

curl -s https://github.com/mistymagich.keys > $actual_dotfile

# remove the old symlink if it is there
[ -h "$to_create" ] && rm "$to_create" && echo "removed symlink for $to_create"
# Create the file if it doesn't exist
[ ! -e "$to_create" ] && touch "$to_create"
# For each key, see if it exists, if not, add it
while read skey; do
if ! grep -q "$skey" "$to_create"; then
      echo "$skey" >> "$to_create"
      key_name=$(echo "$skey" | awk '{print $3}')
      echo "Added $key_name"
  fi
done < "$actual_dotfile"

# Ensure that StrictModes doesn't cause us issues with SSH key auth
if [ -e "$HOME/.ssh/authorized_keys" ]; then
    chmod 600 "$HOME/.ssh/authorized_keys"
fi



# Configuration Git
# -----------------------------------------------------------------
section "Configuration Git"
GIT_CONFIG_LOCAL=~/.gitconfig.local
if [ ! -e $GIT_CONFIG_LOCAL ]; then
	echo -n "git config user.email?> "
	read GIT_AUTHOR_EMAIL

	echo -n "git config user.name?> "
	read GIT_AUTHOR_NAME

	echo -n "git config user.signingkey?> "
	read GIT_AUTHOR_SIGNINGKEY

	cat << EOF > $GIT_CONFIG_LOCAL
[user]
    name = $GIT_AUTHOR_NAME
    email = $GIT_AUTHOR_EMAIL
    signingkey = $GIT_AUTHOR_SIGNINGKEY
EOF
fi

