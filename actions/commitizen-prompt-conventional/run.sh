#! /bin/bash
if [[ ${1} == ".git/COMMIT_EDITMSG" ]]; then
  exec </dev/tty && cz --hook || true
else
  echo "Skipping interactive commit prompt"
  exit 0
fi
