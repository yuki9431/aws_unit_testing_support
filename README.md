# aws_unit_testing_support
## Overview

Scripts supporting unit testing.

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

## How to Use TestNetConnection.ps1

1. Write the destination
```powershell

$servers = @(
    @{ Name = "8.8.8.8"; Port = 25 },
    @{ Name = "www.sample.com"; Port = 80 },
    @{ Name = "www.sample.com"; Port = 443 },
    @{ Name = "vpce-xxxxxxxxxx.vpce-svc-xxxxxxxxx.ap-northeast-1.vpce.amazonaws.com"; Port = 22 }
)

```

2. Running the Script

```powershell

.\TestNetConnection.ps1

```
