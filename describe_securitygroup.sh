#!/bin/bash

# 使用方法
usage() {
    echo "使用法: $0 <セキュリティグループ名リストファイル>"
    echo "例: $0 sg_list.txt"
    exit 1
}

# 引数確認
if [ "$#" -ne 1 ]; then
    usage
fi

SG_LIST_FILE=$1

# ファイル存在確認
if [ ! -f "$SG_LIST_FILE" ]; then
    echo "エラー: ファイルが存在しません: $SG_LIST_FILE"
    exit 1
fi

# 出力ファイル名作成
DATE_TIME=$(date +"%Y%m%d_%H%M")
BASENAME="${SG_LIST_FILE%.*}"
OUTPUT_FILE="${BASENAME}_${DATE_TIME}.csv"

# ヘッダー行
echo "セキュリティグループ名,説明,VPC,ルールタイプ,タイプ,プロトコル,ポート範囲,ソース,ルールの説明,タグ" > "$OUTPUT_FILE"

# リストを1行ずつ処理
while IFS= read -r SG_NAME || [ -n "$SG_NAME" ]; do
    if [ -z "$SG_NAME" ]; then
        continue
    fi

    aws ec2 describe-security-groups \
      --filters Name=group-name,Values="$SG_NAME" \
      --query "SecurityGroups[]" | jq -r --arg sgname "$SG_NAME" '
        .[] as $sg |
        ($sg.Tags // []) as $tags |

        # Inbound ルール処理
        ($sg.IpPermissions[]? |
            . as $rule |
            ($rule.IpRanges[]? // {"CidrIp":"0.0.0.0/0"}) as $ip |
            {
                name: $sg.GroupName,
                desc: $sg.Description,
                vpc: $sg.VpcId,
                direction: "Inbound",
                type: $rule.IpProtocol,
                protocol: $rule.IpProtocol,
                port: (
                    if $rule.FromPort == null then "All"
                    elif $rule.FromPort == $rule.ToPort then ($rule.FromPort|tostring)
                    else ($rule.FromPort|tostring) + "-" + ($rule.ToPort|tostring)
                    end
                ),
                source: $ip.CidrIp,
                ruledesc: ($ip.Description // "なし"),
                tags: ($tags | map("\(.Key)=\(.Value)") | join(";"))
            }
        ),

        # Outbound ルール処理
        ($sg.IpPermissionsEgress[]? |
            . as $rule |
            ($rule.IpRanges[]? // {"CidrIp":"0.0.0.0/0"}) as $ip |
            {
                name: $sg.GroupName,
                desc: $sg.Description,
                vpc: $sg.VpcId,
                direction: "Outbound",
                type: $rule.IpProtocol,
                protocol: $rule.IpProtocol,
                port: (
                    if $rule.FromPort == null then "All"
                    elif $rule.FromPort == $rule.ToPort then ($rule.FromPort|tostring)
                    else ($rule.FromPort|tostring) + "-" + ($rule.ToPort|tostring)
                    end
                ),
                source: $ip.CidrIp,
                ruledesc: ($ip.Description // "なし"),
                tags: ($tags | map("\(.Key)=\(.Value)") | join(";"))
            }
        )
        | [
            .name, .desc, .vpc, .direction, .type, .protocol, .port, .source, .ruledesc, .tags
        ] | @csv
    ' >> "$OUTPUT_FILE"

done < "$SG_LIST_FILE"

echo "出力完了: $OUTPUT_FILE"
