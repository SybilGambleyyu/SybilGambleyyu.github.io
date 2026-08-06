#!/usr/bin/env bash
#
# The official deploy-pages action cancels a Pages deployment after ten minutes.
# Pages can legitimately keep a small static-site deployment queued longer than
# that, so this workflow keeps polling the same documented deployment endpoint
# for up to 45 minutes before it explicitly cancels it.

set -euo pipefail

: "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:?missing id-token request token}"
: "${ACTIONS_ID_TOKEN_REQUEST_URL:?missing id-token request URL}"
: "${ARTIFACT_ID:?missing Pages artifact ID}"
: "${GITHUB_API_URL:?missing GitHub API URL}"
: "${GITHUB_OUTPUT:?missing GitHub output path}"
: "${GITHUB_REPOSITORY:?missing repository name}"
: "${GITHUB_SHA:?missing commit SHA}"
: "${GITHUB_TOKEN:?missing GitHub token}"

api_url="${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/pages/deployments"
headers=(
  --header "Accept: application/vnd.github+json"
  --header "Authorization: Bearer ${GITHUB_TOKEN}"
  --header "X-GitHub-Api-Version: 2022-11-28"
)

oidc_response="$(
  curl --fail --silent --show-error \
    --header "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
    "${ACTIONS_ID_TOKEN_REQUEST_URL}"
)"
oidc_token="$(jq -er '.value' <<<"${oidc_response}")"
payload="$(
  jq -n \
    --arg artifact_id "${ARTIFACT_ID}" \
    --arg build_version "${GITHUB_SHA}" \
    --arg oidc_token "${oidc_token}" \
    '{
      artifact_id: ($artifact_id | tonumber),
      oidc_token: $oidc_token,
      pages_build_version: $build_version
    }'
)"

deployment_response="$(
  curl --fail --silent --show-error --request POST "${headers[@]}" \
    --header "Content-Type: application/json" \
    --data "${payload}" "${api_url}"
)"
deployment_id="$(
  jq -er '.id // (.status_url | split("/")[-1])' <<<"${deployment_response}"
)"
page_url="$(jq -r '.page_url // empty' <<<"${deployment_response}")"
if [[ -n "${page_url}" ]]; then
  printf 'page_url=%s\n' "${page_url}" >>"${GITHUB_OUTPUT}"
fi

status_url="${api_url}/${deployment_id}"
deadline=$((SECONDS + 2700))
while ((SECONDS < deadline)); do
  if status_response="$(
    curl --fail --silent --show-error --retry 3 --retry-all-errors \
      "${headers[@]}" "${status_url}"
  )"; then
    status="$(jq -er '.status' <<<"${status_response}")"
    case "${status}" in
      succeed)
        printf 'GitHub Pages deployment %s succeeded.\n' "${deployment_id}"
        exit 0
        ;;
      deployment_failed | deployment_content_failed | deployment_cancelled | deployment_lost)
        printf 'GitHub Pages deployment %s ended with %s.\n' \
          "${deployment_id}" "${status}" >&2
        exit 1
        ;;
      *)
        printf 'GitHub Pages deployment %s status: %s\n' \
          "${deployment_id}" "${status}"
        ;;
    esac
  else
    printf 'Could not read GitHub Pages deployment %s; retrying.\n' \
      "${deployment_id}" >&2
  fi
  sleep 5
done

printf 'GitHub Pages deployment %s exceeded the 45-minute queue budget; cancelling.\n' \
  "${deployment_id}" >&2
curl --fail --silent --show-error --request POST "${headers[@]}" \
  "${status_url}/cancel" >/dev/null || true
exit 1
