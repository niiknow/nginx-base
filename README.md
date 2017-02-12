# nginx-base
Docker nginx with Letsencrypt and AWS CLI.  

## run

```
mkdir -p /opt/myapp/{app,backup}
docker run -d --restart=always -p 80:80 -p 443:443 \
-v /opt/myapp/app:/app -v /opt/myapp/backup:/backup \
--env EMAIL='admin@example.com' \
--env DOMAINS='example.com www.example.com' \
--env AWS_ACCESS_KEY_ID=<<YOUR_ACCESS_KEY>> \
--env AWS_SECRET_ACCESS_KEY=<<YOUR_SECRET_ACCESS>> \
--env AWS_DEFAULT_REGION=us-west-2 \
niiknow/nginx-base 
```

## Environment variables:
 - EMAIL - the email address to obtain certificates on behalf of.
 - DOMAINS - a space separated list of domains to obtain a certificate for.
 - AWS_ACCESS_KEY_ID - for awscli
 - AWS_SECRET_ACCESS_KEY - for awscli
 - AWS_DEFAULT_REGION - for awscli

EMAIL and DOMAINS environment variable are not required unless you want to use Letsencrypt.  Same goes for AWS environment variable unless you want to do backup with AWS CLI.
