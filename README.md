# aws_unit_testing_support
## Overview

Automatically update the AMI of the EC2 template.

## Requirement

You have aws-cli installed on your server.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## How to Use cloudwatchalarm.sh

1. Create sg_list.txt 
```bash

aws cloudwatch describe-alarms \
  --query "MetricAlarms[?contains(AlarmName, '$ALARM_NAME')].AlarmName" \
  --output text | tr '\t' '\n' > alarm_list.txt

```

2. Running the Script

```bash

./describe_alarms.sh alarm_list.txt

```

## How to Use describe_securitygroup.sh

1. Create sg_list.txt 
```bash

aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, '$GROUP_NAME')].GroupName" \
  --output text | tr '\t' '\n' > sg_list.txt

```

2. Running the Script

```bash

./describe_security_groups.sh sg_list.txt

```
