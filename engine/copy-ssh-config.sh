#!/usr/bin/env bash
cp -f /home/roddocker/.ssh-readonly/* /root/.ssh/ 2>/dev/null
cp -f /home/roddocker/.ssh-readonly/* /home/roddocker/.ssh/ 2>/dev/null
chown -R root: /root/.ssh
chown -R roddocker: /home/roddocker/.ssh
rm -f /root/.ssh/config
rm -f /home/roddocker/.ssh/config
