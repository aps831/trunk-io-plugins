#!/bin/bash

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

DEFAULT_CONFIG_FILE="${PWD}/hardcoding.json"
CONFIG_FILE="${1:-${DEFAULT_CONFIG_FILE}}"
BASE_PATH=$(dirname "${CONFIG_FILE}")
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Check for hardcoding.json
if [[ ! -f ${CONFIG_FILE} ]]; then
  echo "${RED}Ignoring hardcoding check as '$(basename "${CONFIG_FILE}")' not found${RESET}"
  exit 0
fi

# Check hardcoding schema
jv -assertcontent -assertformat "${SCRIPT_DIR}/hardcoding-schema.json" "${CONFIG_FILE}" &>/dev/null
if [[ $? == 1 ]]; then
  echo "${RED}Hardcoding check failed: '$(basename "${CONFIG_FILE}")' is not valid${RESET}"
  exit 1
fi

output="${RESET}"

# Iterate over outer array
# shellcheck disable=SC2002
for outer in $(cat "${CONFIG_FILE}" | gojq -r '.[] | @base64'); do

  description=$(echo "${outer}" | base64 --decode | gojq -r '.description')
  value=$(echo "${outer}" | base64 --decode | gojq -r '.value')

  # Iterate over inner array
  for inner in $(echo "${outer}" | base64 --decode | gojq -r '.files[] | @base64'); do

    file="${BASE_PATH}/$(echo "${inner}" | base64 --decode | gojq -r '.filePath')"
    valuePath=$(echo "${inner}" | base64 --decode | gojq -r '.valuePath')
    valuePrefix=$(echo "${inner}" | base64 --decode | gojq -r '.valuePrefix')
    valueSuffix=$(echo "${inner}" | base64 --decode | gojq -r '.valueSuffix')

    if [[ ${valuePrefix} == "null" ]]; then
      valuePrefix=""
    fi

    if [[ ${valueSuffix} == "null" ]]; then
      valueSuffix=""
    fi

    if [[ ! -f ${file} ]]; then

      output="${output}\nFile '${file}' not found for value '${value}' of '${description}' at path '${valuePath}'"

    else

      if [[ ${file} == *.yml || ${file} == *.yaml || ${file} == *.json ]]; then

        convertedFile=${file}
        yqlike=true

      elif [[ ${file} == *.xml ]]; then

        convertedFile=$(mktemp)
        yq -p=xml '.' "${file}" >"${convertedFile}"
        yqlike=true

      elif [[ ${file} == *.tf ]]; then

        convertedFile=$(mktemp)
        hcl2json "${file}" >"${convertedFile}"
        yqlike=true

      else

        yqlike=false

      fi

      if [[ ${yqlike} == true ]]; then

        actual=$(yq "${valuePath}" <"${convertedFile}" 2>/dev/null)

        if [ $? != 0 ]; then

          output="${output}\nPath '${valuePath}' not valid for value '${value}' of '${description}' in file '${file}'"

        else

          expected="${valuePrefix}${value}${valueSuffix}"

          if [[ ${actual} == "null" ]]; then

            output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

          elif ! [[ ${actual} =~ ${expected} ]]; then

            output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

          fi

        fi

      # .tool-versions
      elif [[ ${file} == *.tool-versions ]]; then

        actual=$(grep "${valuePath}" "${file}" | awk '{print $2}')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif ! [[ ${actual} =~ ${expected} ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .sh
      elif [[ ${file} == *.sh ]]; then

        actual=$(grep "${valuePath}" "${file}" | awk '{s=index($1,"=");print substr($1,s+2)}' | awk '{s=index($1,"\""); print substr($1,0,s-1)}')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif ! [[ ${actual} =~ ${expected} ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      else

        output="${output}\nFile type '${file}' not supported"

      fi
    fi
  done
done

# Output
if [[ ${output} == "${RESET}" ]]; then

  echo -e "${GREEN}Hardcoding check: successful!${RESET}"

  exit 0

else

  echo -e "${RED}${output}${RESET}"

  exit 1

fi
