#!/bin/bash

# This is a basic sanity test of QaAuth.pm.
# It doesn't cover all possible requests but tests the most common
# concerns (e.g. /dashboard).
# It should be run outside the data center because those servers
# are often privileged (the very thing we are validating here).

INTERNAL_HOST=luffa.gacrc.uga.edu
INTERNAL_IP=128.192.75.111

# pick a site set number corresponding to the elif list below.
S=0

if [[ $S -eq 0 ]]; then
SCHEME=https
DEV_UPSTREAM_SITE=q2.clinepidb.org
PROD_UPSTREAM_SITE=w2.clinepidb.org
PROD_PROXIED_SITE=clinepidb.org
PROD_WEBAPP="ce"
elif  [[ $S -eq 1 ]]; then
SCHEME=http
DEV_UPSTREAM_SITE=q1.toxodb.org
PROD_UPSTREAM_SITE=w1.toxodb.org
PROD_PROXIED_SITE=toxodb.org
PROD_WEBAPP="toxo"
elif  [[ $S -eq 2 ]]; then
SCHEME=http
DEV_UPSTREAM_SITE=integrate.toxodb.org
PROD_UPSTREAM_SITE=w1.toxodb.org
PROD_PROXIED_SITE=toxodb.org
PROD_WEBAPP="toxo"
else
SCHEME=http
DEV_UPSTREAM_SITE=sa.vm.trichdb.org
PROD_WEBAPP="trichdb.b36"
fi

COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_RESET='\033[0m'

CURL="curl -s -o /dev/null -L -I -w '%{url_effective}'"

function die_err() {
  msg=$1
  echo -e 2>&1 "${COLOR_RED}ERROR: ${msg}${COLOR_RESET}"
  return 1
}

function ok() {
  local msg=$1
  echo -e 2>&1 "${COLOR_GREEN}OK: ${msg}${COLOR_RESET}"
  return 0
}

function run() {
  local cmd=$1
  local expected=$2
  echo $cmd
  url="$(eval $cmd)"
  [[ "${url}" =~ "$expected" ]] &&  ok "$url" ||  die_err "Sent to wrong location. Expected $expected, got $url."
  echo
}


# from non-eupath host
# expect
#   dev home require login
#   dev /dashboard require login (has more sensitive information and operations than xml API)
#   dev /dashboard/xml requires login
#   prod home no login
#   prod /dashboard require login (has more sensitive information and operations than xml API)
#   prod /dashboard/xml requires login


echo 'dev home requires login for remote client'
cmd="${CURL} '${SCHEME}://${DEV_UPSTREAM_SITE}/'"
run "$cmd" 'auth/bin/autologin'

if [[ -n $PROD_UPSTREAM_SITE ]]; then
echo 'prod home does not require login for remote client'
cmd="${CURL} '${SCHEME}://${PROD_UPSTREAM_SITE}/'"
run "$cmd" "${PROD_UPSTREAM_SITE}/${PROD_WEBAPP}/"
fi

echo 'dev /dashboard requires login for remote client'
cmd="${CURL} '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'
echo 'dev /dashboard requires login for internal client'
run "ssh ${INTERNAL_HOST} ${cmd}" 'auth/bin/autologin'
echo 'dev /dashboard/xml API does not require login for internal client'
cmd="${CURL} '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/xml'"
run "ssh ${INTERNAL_HOST} ${cmd}" '/dashboard/xml'

if [[ -n $PROD_UPSTREAM_SITE ]]; then
echo 'prod /dashboard requires login for remote client'
cmd="${CURL} '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'
echo 'prod /dashboard requires login for internal client'
run "ssh ${INTERNAL_HOST} ${cmd}" 'auth/bin/autologin'
echo 'prod /dashboard/xml API does not require login for internal client'
cmd="${CURL} '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/xml'"
run "ssh ${INTERNAL_HOST} ${cmd}" '/dashboard/xml'
fi

if [[ -n $PROD_PROXIED_SITE ]]; then
echo 'proxied /dashboard requires login for remote client'
cmd="${CURL} '${SCHEME}://${PROD_PROXIED_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'
echo 'proxied /dashboard requires login for internal client'
run "ssh ${INTERNAL_HOST} ${cmd}" 'auth/bin/autologin'
echo 'proxied /dashboard/xml API does not require login for internal client'
cmd="${CURL} '${SCHEME}://${PROD_PROXIED_SITE}/dashboard/xml'"
run "ssh ${INTERNAL_HOST} ${cmd}" '/dashboard/xml'
fi

# from non-eupath host w/ forged X-Forwarded-For
# expect
#   dev home require login
#   dev /dashboard require login
#   dev /dashboard/xml requires login
#   prod home no login
#   prod /dashboard require login (has more sensitive information and operations than xml API)
#   prod /dashboard/xml requires login

if [[ -n $PROD_PROXIED_SITE ]]; then
echo 'Forged X-Forwarded-For requires login to /dashboard'
H="--header 'X-Forwarded-For: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'

echo 'Forged X-Forwarded-For requires login to /dashboard/xml API'
H="--header 'X-Forwarded-For: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/xml'"
run "$cmd" 'auth/bin/autologin'
fi

echo 'Forged X-Forwarded-For requires login to /dashboard'
H="--header 'X-Forwarded-For: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'

echo 'Forged X-Forwarded-For requires login to /dashboard/xml API'
H="--header 'X-Forwarded-For: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/xml'"
run "$cmd" 'auth/bin/autologin'

echo 'Forged X-Real-IP requires login to /dashboard'
H="--header 'X-Real-IP: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'

echo 'Forged X-Real-IP requires login to /dashboard/xml API'
H="--header 'X-Real-IP: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${DEV_UPSTREAM_SITE}/dashboard/xml'"
run "$cmd" 'auth/bin/autologin'

if [[ -n $PROD_PROXIED_SITE ]]; then
echo 'Forged X-Real-IP requires login to /dashboard'
H="--header 'X-Real-IP: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/'"
run "$cmd" 'auth/bin/autologin'

echo 'Forged X-Real-IP requires login to /dashboard/xml API'
H="--header 'X-Real-IP: ${INTERNAL_IP}'"
cmd="curl -s -o /dev/null $H -L -I -w '%{url_effective} %{http_code}' '${SCHEME}://${PROD_UPSTREAM_SITE}/dashboard/xml'"
run "$cmd" 'auth/bin/autologin'
fi

# from eupath internal host
# expect
#   dev home no login
#   dev /dashboard requires login
#   dev /dashboard/xml does not require login
#   prod home no login
#   prod /dashboard requires login
#   prod /dashboard/xml does not require login
