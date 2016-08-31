#!/usr/bin/env bash

set -eu


SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# create link dotfiles
# -----------------------------------------------------------------
echo ">>>>>>> Create dotfiles link ..."
FINDPARAM='-maxdepth 1 -not -path . -not -path .. -not -regex .+/.git'
find -name ".*" -not -path "." -not -name ".git" -exec rm -rf ~/{} \;
yes|find `pwd` ${FINDPARAM} -name ".*" -ok ln -s {} ${HOME}/ \; 2> /dev/null



# ~/.ssh/authorized_keys
# @see https://github.com/claytron/dotfiles/blob/master/create_links.sh
# -----------------------------------------------------------------
echo ">>>>>>> Add SSH pubkey ..."
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


# ~/.gitconfig.local
echo ">>>>>>> Configuration Git ..."
GIT_CONFIG_LOCAL=~/.gitconfig.local
if [ ! -e $GIT_CONFIG_LOCAL ]; then
	echo -n "git config user.email?> "
	read GIT_AUTHOR_EMAIL

	echo -n "git config user.name?> "
	read GIT_AUTHOR_NAME

	cat << EOF > $GIT_CONFIG_LOCAL
[user]
    name = $GIT_AUTHOR_NAME
    email = $GIT_AUTHOR_EMAIL
EOF
fi


# Install oh my zsh
echo ">>>>>>> Install prezto ..."
if [ ! -d ~/.zprezto ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

