#! /bin/bash
RESET='\033[0m'
RED='\033[0;31m]'
CONFIG_FILE="${PWD}/.czrc"

# Check for .czrc
if [[ ! -f ${CONFIG_FILE} ]]; then
  echo -e "${RED}Ignoring commitizen prompt as '$(basename "${CONFIG_FILE}")' not found${RESET}"
  exit 0
fi

if [[ ${1} == ".git/COMMIT_EDITMSG" ]]; then
  exec </dev/tty && cz --hook || true
else
  echo -e "${RESET}Skipping interactive commit prompt"
  exit 0
fi
