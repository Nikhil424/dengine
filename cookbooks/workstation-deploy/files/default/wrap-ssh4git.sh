#!/usr/bin/env bash
/usr/bin/env ssh -o "StrictHostKeyChecking=no" -i "/root/.ssh/git-ssh" $1 $2
