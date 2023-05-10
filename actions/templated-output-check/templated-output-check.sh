#! /bin/bash

RESET='\033[0m'

is_templated() {
  file="$1"
  directory=$(dirname "${file}")
  filename=$(basename -- "${file}")
  extension="${filename##*.}"
  filename="${filename%.*}"
  path="${directory}/${filename}.tpl.${extension}"
  [[ -f ${path} ]]
}

filter() {
  local function="$1"
  local arg
  while read -r arg; do
    "${function}" "${arg}" && echo "${arg}"
  done
}

diffs=$(git diff --name-only --cached)
templates=$(echo "${diffs}" | filter is_templated)

if [[ -n ${templates} ]]; then
  echo -e "${RESET}The following file(s) have been modified but are derived from templates:"
  echo "${templates}"
  read -r -p "Do you wish to continue? [yN] " RESPONSE
  RESPONSE="${RESPONSE:-N}"
  if [[ ${RESPONSE} == "N" || ${RESPONSE} == "n" ]]; then
    exit 1
  fi
fi
