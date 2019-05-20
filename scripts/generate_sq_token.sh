#!/bin/bash +xe

echo "Generating Sonar Authentication Token"

pretty_sleep() {
  secs=${1:-30}
  tool=${2:-service}
  while [ $secs -gt 0 ]; do
    echo -ne "$tool unavailable, sleeping for: $secs\033[0Ks\r"
    sleep 1
    : $((secs--))
  done
  echo "$tool was unavailable, so slept for: ${1:-60} secs"
}

echo "* Waiting for the Sonar user token api to become available - this can take a few minutes"
until [[ $(curl -I -s -u ${SONARQUBE_USERNAME}:${SONARQUBE_PASSWORD} -X POST ${SONARQUBE_URL}/api/user_tokens/generate?name=${SONARQUBE_USERNAME} | head -n 1 | cut -d$' ' -f2) == 400 ]]; do pretty_sleep 30 Sonar; done

# Validating if token already exists:
USER_TOKEN=$(curl -u ${SONARQUBE_USERNAME}:${SONARQUBE_PASSWORD} -X POST ${SONARQUBE_URL}/api/user_tokens/search |
python -c "
import sys, json 
def tokenExists(userTokens, token):
    if len(userTokens) == 0: return ''
    for t in userTokens:
        if t['name'] == token:
            return t['name']
    return ''
userTokens = json.load(sys.stdin)['userTokens']
print(tokenExists(userTokens, '${SONARQUBE_USERNAME}'))
")

SONAR_TOKEN=""

if [[ ! -z $USER_TOKEN ]]; then
  SONAR_TOKEN=$USER_TOKEN
  echo "Sonar Auth Token exists already"
else
  SONAR_TOKEN=$(curl -u ${SONARQUBE_USERNAME}:${SONARQUBE_PASSWORD} -X POST ${SONARQUBE_URL}/api/user_tokens/generate?name=${SONARQUBE_USERNAME} |
  python -c 'import sys,json; print(json.load(sys.stdin)["token"])')
  echo "Generated Sonar Auth Token"
fi
export SONAR_AUTH_TOKEN=${SONAR_TOKEN}