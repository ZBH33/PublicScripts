#!/bin/bash
#
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLypPg82fpcq931aH3h0IW5BfbY8IBhdcsa9NtVbvqa z@workstation"
umask 0077
[ -d ~/.ssh ]||mkdir -p ~/.ssh
[ -f ~/.ssh/authorized_keys ]|| touch ~/.ssh/authorized_keys
grep --quiet --fixed-strings "$PUBLIC_KEY" ~/.ssh/authorized_keys
if [ $? -eq 0 ]
then
   echo Key already exists, no update performed.
   exit
fi
echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys