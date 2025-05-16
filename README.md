# aws_unit_testing_support
## Overview

Automatically update the AMI of the EC2 template.

## Requirement

You have aws-cli installed on your server.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## How to Use describe_securitygroup.sh

1. create sg_list.txt 
```bash

aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, '$GROUPNAME')].GroupName" \
  --output text | tr '\t' '\n' > sg_list.txt

```

2. Running the Script

```

./describe_security_groups.sh sg_list.txt

```
