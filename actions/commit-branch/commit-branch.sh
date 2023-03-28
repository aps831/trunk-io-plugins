#!/bin/bash

protected_branch="master"
branch="$(git rev-parse --abbrev-ref HEAD)"

RED='\033[0;31m'
NOCOL='\033[0m'
if [[ ${branch} == "${protected_branch}" ]]; then
  echo -e "${RED}You are committing directly to the '${protected_branch}' branch${NOCOL}"
  read -r -p "Do you want to proceed? [Y/n] " RESPONSE
  RESPONSE="${RESPONSE:-Y}"
  case "${RESPONSE}" in
  Y | y)
    echo "Continuing commit."
    exit 0
    ;;
  n)
    echo "Abandoning commit."
    exit 1
    ;;
  *)
    echo "Abandoning commit."
    exit 1
    ;;
  esac
fi
