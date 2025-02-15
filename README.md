# aws-ecs-demo

# TODO

- [X] ECS Exec.
- [X] In-cluster communication (kubecache -> miniapi).
- [X] Groupcache ecs task auto-discovery (kubecache) - no agent.
- [ ] Groupcache ecs task auto-discovery (kubecache) - with agent ecs-task-discovery-agent.
- [ ] Task health check.
- [ ] Load generator (generator -> kubecache).
- [ ] Task auto-scaling.
- [ ] Public access from internet (internet -> kubecache).
- [ ] Prometheus metrics.

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
./run.sh plan -var='vpc_id=vpc-0f364168' -var='subnets=["subnet-bb404e91"]' -var='cidr_blocks=["172.31.0.0/16"]'
./run.sh apply
```

# Destroy the cluster

```bash
./run.sh destroy -var='vpc_id=vpc-0f364168' -var='subnets=["subnet-bb404e91"]' -var='cidr_blocks=["172.31.0.0/16"]'
```

# References

## ECS Exec Checker

ECS Exec Checker: https://github.com/aws-containers/amazon-ecs-exec-checker

```bash
git clone https://github.com/aws-containers/amazon-ecs-exec-checker

cd amazon-ecs-exec-checker

./check-ecs-exec.sh demo 523ab4fcd99e431fb2b966fa6d1f5d1a
```

## Execute command

```bash
aws ecs execute-command --cluster demo \
    --task c2730bc4f1fa4de683e079710faba501 \
    --container miniapi \
    --interactive \
    --command "/bin/sh"

/ # curl miniapi.demo:8080/cards/123
{"request":{"headers":{"Accept":["*/*"],"User-Agent":["curl/8.10.1"]},"method":"GET","uri":"/cards/123","host":"miniapi.demo:8080","body":"","form_query":{},"form_post":{},"parameters":{"param1":"","param2":""}},"message":"not found","status":404,"server_hostname":"ip-172-31-54-136.ec2.internal","server_version":"1.3.2"}
/ #

aws ecs execute-command --cluster demo \
    --task 17c30cf353b345679a6bad0319d363a8 \
    --container kubecache \
    --interactive \
    --command "/bin/sh"

```
