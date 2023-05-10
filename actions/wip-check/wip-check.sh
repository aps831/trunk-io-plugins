#! /bin/bash
# shellcheck disable=SC2312

RESET='\033[0m'
SEARCH_TERM_FIXME="FIXME"
SEARCH_TERM_TODO="TODO"

if [[ $(git diff --cached | grep -E "^\+" | grep -v '+++ b/' | cut -c 2-) == *${SEARCH_TERM_FIXME}* ]] || [[ $(git diff --cached | grep -E "^\+" | grep -v '+++ b/' | cut -c 2-) == *${SEARCH_TERM_TODO}* ]]; then
  echo -e "${RESET}Found ${SEARCH_TERM_FIXME} | ${SEARCH_TERM_TODO} in commit."
  read -r -p "Do you wish to continue with the commit? [Yn] " RESPONSE
  RESPONSE="${RESPONSE:-Y}"
  if [[ ${RESPONSE} == "N" || ${RESPONSE} == "n" ]]; then
    exit 1
  fi
fi
