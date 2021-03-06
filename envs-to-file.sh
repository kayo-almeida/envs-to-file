  #!/bin/sh
PARAMETERS_PATH=$1
SECRETS_PATH=$2
OUTPUT_FILE=$3
AWS_REGION=$4

# create blank file
echo "" > $OUTPUT_FILE

# if parameters path is defined get environments
if [ -n "$PARAMETERS_PATH" ]; then
  echo "\n\nš loading environment variables from parameter store...\n\n"

  VAR_DATA=$(echo $(aws ssm get-parameters-by-path \
    --region $AWS_REGION \
    --with-decryption \
    --path "$PARAMETERS_PATH" \
    --query 'Parameters[].[Name,Value]' \
    --output text | \
    awk -F'\t' '
    {
      printf "%s=\"%s\" ", $1, $2
    }') | sed -e "s/$(echo $PARAMETERS_PATH | sed 's/\//\\\//g')//g")

  echo $VAR_DATA | sed -e "s/\" /\"\n/g" >> $OUTPUT_FILE
fi

# if secrets path is defined get secrets
if [ -n "$SECRETS_PATH" ]; then
  echo "\n\nš loading environment variables from secret manager...\n\n"

  SECRET_LIST=$(echo $(aws secretsmanager list-secrets \
  --region $AWS_REGION \
  --filters Key=name,Values=$SECRETS_PATH \
  --max-items 500 | jq --raw-output '.SecretList[].Name'))

  for secret in $SECRET_LIST; do
    SECRET_ITEMS=$(echo $(aws secretsmanager get-secret-value \
    --region $AWS_REGION \
    --secret-id $secret --query '[SecretString]' --output text))

    for s in $(echo $SECRET_ITEMS | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
        echo $s >> $OUTPUT_FILE
    done
  done
fi

# return envs
export $(cat $OUTPUT_FILE | xargs) 

echo "\n\nāļø  environment variables loadeds!\n\n"
