#wait until engine start
sleep 10

# Initial request to get the API access token
response=$(curl -s "http://localhost:6878/server/api?api_version=3&method=get_api_access_token")

# Parse the token from the JSON response
token=$(echo $response | jq -r '.result.token')

if [[ $ALLOW_REMOTE_ACCESS == "yes" ]];then
    # Use the token in the next request to enable remote access
    curl "http://localhost:6878/server/api?api_version=3&method=set_allow_remote_access&token=$token&value=1"
fi
