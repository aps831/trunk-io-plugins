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
  echo -e "${RED}Ignoring hardcoding check as '$(basename "${CONFIG_FILE}")' not found${RESET}"
  exit 0
fi

# Check hardcoding schema
jv -assertcontent -assertformat "${SCRIPT_DIR}/hardcoding-schema.json" "${CONFIG_FILE}" &>/dev/null
if [[ $? == 1 ]]; then
  echo -e "${RED}Hardcoding check failed: '$(basename "${CONFIG_FILE}")' is not valid${RESET}"
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
    partialMatch=$(echo "${inner}" | base64 --decode | gojq -r '.partialMatch')

    if [[ ${valuePrefix} == "null" ]]; then
      valuePrefix=""
    fi

    if [[ ${valueSuffix} == "null" ]]; then
      valueSuffix=""
    fi

    if [[ ${partialMatch} == "null" ]]; then
      partialMatch=false
    fi

    if [[ ! -f ${file} ]]; then

      output="${output}\nFile '${file}' not found for value '${value}' of '${description}' at path '${valuePath}'"

    else

      # Convert file
      if [[ ${file} == *.yml || ${file} == *.yaml || ${file} == *.json ]]; then

        convertedFile=${file}
        yqlike=true

      elif [[ ${file} == *.xml ]]; then

        convertedFile=$(mktemp)
        yq -p=xml -o=yaml '.' "${file}" >"${convertedFile}"
        yqlike=true

      elif [[ ${file} == *.toml ]]; then

        convertedFile=$(mktemp)
        yq -p=toml -o=yaml '.' "${file}" >"${convertedFile}"
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

          elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

            output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

          fi

        fi

      # .tool-versions
      elif [[ ${file} == *.tool-versions ]]; then

        actual=$(grep "${valuePath}" "${file}" | awk '{print $2}')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .sh
      elif [[ ${file} == *.sh ]]; then

        actual=$(grep "^${valuePath}=" "${file}" | awk '{s=index($0,"=");print substr($0,s+1)}' | sed -e 's/^\s*"*//' -e 's/"*;*\s*$//')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .tfvars
      elif [[ ${file} == *.tfvars ]]; then

        actual=$(grep "^${valuePath}\s*= " "${file}" | awk '{s=index($0,"=");print substr($0,s+2)}' | sed -e 's/^\s*"*//' -e 's/"*;*\s*$//')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .bat
      elif [[ ${file} == *.bat ]]; then

        actual=$(grep "^set ${valuePath}=" "${file}" | awk '{s=index($0,"=");print substr($0,s+1)}' | sed -e 's/^\s*"*//' -e 's/"*;*\s*$//')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .js .ts
      elif [[ ${file} == *.js || ${file} == *.ts ]]; then

        actual=$(grep "^const ${valuePath} = " "${file}" | awk '{s=index($0,"=");print substr($0,s+2)}' | sed -e 's/^\s*"*//' -e 's/"*;*\s*$//')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # .sdkmanrc
      elif [[ ${file} == *.sdkmanrc ]]; then

        actual=$(grep "${valuePath}" "${file}" | awk '{s=index($1,"=");print substr($1,s+1)}')
        expected="${valuePrefix}${value}${valueSuffix}"

        if [[ ${actual} == "" ]]; then

          output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

        elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

          output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

        fi

      # Dockerfile
      elif [[ ${file} == *Dockerfile* ]]; then

        term=${valuePath%[*}
        term=${term#*.}
        index=${valuePath#*[}
        index=${index%]*}

        re='^[0-9]+$'
        if ! [[ $index =~ $re ]]; then

          output="${output}\nPath '${valuePath}' not valid for value '${value}' of '${description}' in file '${file}'"

        else

          index=$((index + 1))
          actual=$(grep "${term}" "${file}" | awk '{$1=""}1' | awk '{$1=$1}1' | awk "{i++}i==$index")
          expected="${valuePrefix}${value}${valueSuffix}"

          if [[ ${actual} == "" ]]; then

            output="${output}\nPath '${valuePath}' not found in file '${file}' for value '${value}' of '${description}'"

          elif [[ ${partialMatch} == false && ${actual} != "${expected}" || ${partialMatch} == true && ${actual} != *"${expected}"* ]]; then

            output="${output}\nFound value '${actual}' for '${description}' instead of '${expected}' in file '${file}' at path '${valuePath}'"

          fi

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
