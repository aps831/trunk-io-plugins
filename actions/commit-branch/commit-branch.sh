#!/bin/bash

RESET='\033[0m'
protected_branch="master"
branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ ${branch} == "${protected_branch}" ]]; then
  echo -e "${RESET}You are committing directly to the '${protected_branch}' branch."
  read -r -p "Do you want to proceed with the commit? [Yn] " RESPONSE
  RESPONSE="${RESPONSE:-Y}"
  case "${RESPONSE}" in
  Y | y)
    exit 0
    ;;
  n)
    exit 1
    ;;
  *)
    exit 1
    ;;
  esac
fi
