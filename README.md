# Environment Variables to File 👋

This action was developed to solve a problem of a private project but can be util for anyone that needs load environment variable from secret managers or parameter store and create an .env file and move to the inside of a build, etc…

### A usage e.g.

```
name: Deploy to lambda
on:
  push:
    branches:
      - main

jobs:
  cd:
    runs-on: ubuntu-latest

    steps:
      - name: Set up aws-cli
        uses: chrislennon/action-aws-cli@v1.1
        env:
          ACTIONS_ALLOW_UNSECURE_COMMANDS: 'true'

      - id: env_file
        name: Environment variables to file
        uses: kayo-almeida/envs-to-file@v2
        with:
          parameters-path: /my-project/production/
          secrets-path: /my-project/production/all-secrets
          file-name: .tmp.env
          aws-region: sa-east-1

      - name: Build application
        run: |
          yarn build
          mv ${{ steps.env_file.outputs.file }} ./build/.env

```

### About the inputs:

Any input is not required

| INPUT           | DESCRIPTION                                                                                                    |
| --------------- | -------------------------------------------------------------------------------------------------------------- |
| parameters-path | Path of parameters of parameter store. You just need to input this value if you want to load secret managers.  |
| secrets-path    | Path of secrets of secret manager. You just need to input this value if you want to load secret managers.      |
| file-name       | Name of file (default is .env) and you really don't need to input this value, unless you want.                 |
| aws-region      | The AWS Region (default: us-east-1). If you are using another region maybe you need to input this region here. |

Besides this params, you need to have a AWS CLI installed in your workflow machine. I recommend this guy:

https://github.com/chrislennon/action-aws-cli

(Don't forget of put the AWS environment variables in your secrets on github configuration 😉)
