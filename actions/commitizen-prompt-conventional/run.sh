#! /bin/bash
RESET='\033[0m'

if [[ ${1} == ".git/COMMIT_EDITMSG" ]]; then
  exec </dev/tty && cz --hook || true
else
  echo -e "${RESET}Skipping interactive commit prompt"
  exit 0
fi
