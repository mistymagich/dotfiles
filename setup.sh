#!/usr/bin/env bash

set -eu


SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# create link dotfiles
# -----------------------------------------------------------------

FINDPARAM='-maxdepth 1 -not -path "." -not -path ".." -not -name ".git"'
find -name ".*" -not -path "." -not -name ".git" -ok rm -r ~/{} \;
yes|find `pwd` ${FINDPARAM} -name ".*" -ok ln -s {} ${HOME}/ \; 2> /dev/null



# ~/.ssh/authorized_keys
# -----------------------------------------------------------------
[ ! -d "$HOME/.ssh" ] && mkdir "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
actual_dotfile="$SCRIPT_DIR/authorized_keys"
to_create="$HOME/.ssh/authorized_keys"
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


