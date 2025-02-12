# aws-ecs-demo

# Requirements

```bash
$ terraform version
Terraform v1.10.5
on linux_amd64
```

# Create the cluster

```bash
git clone https://github.com/udhos/toyeks

cd toyeks

export AWS_PROFILE=...

./run.sh boot
./run.sh plan
./run.sh apply
```

# Destroy the cluster

```bash
./run.sh destroy
```
