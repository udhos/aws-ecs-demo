# aws-ecs-demo

# Requirements

```bash
$ terraform version
Terraform v1.10.5
on linux_amd64
```

# Create the cluster

```bash
git clone https://github.com/udhos/aws-ecs-demo

cd aws-ecs-demo

export AWS_PROFILE=...

./run.sh boot
./run.sh plan -var='vpc_id=vpc-0f364168' -var='subnets=["subnet-bb404e91"]' -var='cidr_blocks=["172.31.48.0/20"]'
./run.sh apply
```

# Destroy the cluster

```bash
./run.sh destroy -var='vpc_id=vpc-0f364168' -var='subnets=["subnet-bb404e91"]' -var='cidr_blocks=["172.31.48.0/20"]'
```

# References

## ECS Exec Checker

ECS Exec Checker: https://github.com/aws-containers/amazon-ecs-exec-checker

```bash
git clone https://github.com/aws-containers/amazon-ecs-exec-checker

cd amazon-ecs-exec-checker

./check-ecs-exec.sh demo bad779bfe77a448c854878853536e7e6
```

## Execute command

```bash
aws ecs update-service \
    --task-definition miniapi \
    --cluster demo \
    --service demo \
    --enable-execute-command \
    --force-new-deployment

aws ecs execute-command --cluster demo \
    --task bad779bfe77a448c854878853536e7e6 \
    --container miniapi \
    --interactive \
    --command "/bin/sh"

/ # curl miniapi.demo:8080/cards/123
{"request":{"headers":{"Accept":["*/*"],"User-Agent":["curl/8.10.1"]},"method":"GET","uri":"/cards/123","host":"miniapi.demo:8080","body":"","form_query":{},"form_post":{},"parameters":{"param1":"","param2":""}},"message":"not found","status":404,"server_hostname":"ip-172-31-54-136.ec2.internal","server_version":"1.3.2"}
/ #
```
