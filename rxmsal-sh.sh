#!/bin/sh

TOKENENDPOINT="https://login.microsoftonline.com/ddd3d26c-b197-4d00-a32d-1ffd84c0c295/oauth2/v2.0/token"
TENANT="ddd3d26c-b197-4d00-a32d-1ffd84c0c295"
SCOPE="offline_access https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/SMTP.Send"
CLIENTID="fea760d5-b496-4f63-be1e-93855c1c5f78"

TOKEN_FILE="$1"

if [ -z "$TOKEN_FILE" ]; then
  echo "Token file path as the first argument please" >&2
  exit 1
fi

read_token_file() {
  if [ ! -f "$1" ]; then
    echo "Token file not found: $1" >&2
    return 1
  fi

  token_json=$(cat "$1")
  token_access_token=$(echo "$token_json" | jq -r '.access_token')
  token_access_token_expiration=$(echo "$token_json" | jq -r '.access_token_expiration')
  token_refresh_token=$(echo "$token_json" | jq -r '.refresh_token')
  token_email=$(echo "$token_json" | jq -r '.email')
}

write_token_file() {
  jq -n \
    --arg access_token "$token_access_token" \
    --arg access_token_expiration "$token_access_token_expiration" \
    --arg refresh_token "$token_refresh_token" \
    --arg email "$token_email" \
    '{
      access_token: $access_token,
      access_token_expiration: $access_token_expiration,
      refresh_token: $refresh_token,
      email: $email
    }' > "$1"
}

access_token_valid() {
  if [ -z "$token_access_token_expiration" ]; then
    echo "token_access_token_expiration is NULL" >&2
    return 1
  fi
  expiration_time=$(date -d "$token_access_token_expiration" +%s)
  current_time=$(date +%s)
  [ "$expiration_time" -gt "$current_time" ]
}

update_tokens() {
  response="$1"
  token_access_token=$(echo "$response" | jq -r '.access_token')
  token_refresh_token=$(echo "$response" | jq -r '.refresh_token // empty')
  expires_in=$(echo "$response" | jq -r '.expires_in')
  expiration_time=$(date -d "+$expires_in seconds" -u +"%Y-%m-%dT%H:%M:%S%z")
  token_access_token_expiration="$expiration_time"
  write_token_file "$TOKEN_FILE"
}

refresh_token() {
  if [ -z "$token_refresh_token" ]; then
    echo "token_refresh_token is NULL" >&2
    return 1
  fi

  post_fields="client_id=$CLIENTID&tenant=$TENANT&refresh_token=$token_refresh_token&grant_type=refresh_token"
  response=$(curl -s -X POST -d "$post_fields" "$TOKENENDPOINT")

  if [ "$(echo "$response" | jq -r '.error // empty')" ]; then
    echo "Error in token refresh response" >&2
    echo "RESPONSE: $response" >&2
    return 1
  fi

  update_tokens "$response"
}

read_token_file "$TOKEN_FILE" || { echo "Failed to read token file" >&2; exit 1; }

if ! access_token_valid; then
  echo "Access token expired, refreshing token" >&2
  refresh_token || { echo "Failed to refresh token" >&2; exit 1; }
fi

echo "$token_access_token"
