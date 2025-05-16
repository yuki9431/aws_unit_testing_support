#!/bin/bash

# 使用方法の説明
usage() {
    echo "使用法: $0 <アラーム名リストファイル>"
    echo "例: $0 alarm_list.txt"
    exit 1
}

# 引数チェック
if [ "$#" -ne 1 ]; then
    usage
fi

ALARM_LIST_FILE=$1

# ファイル存在チェック
if [ ! -f "$ALARM_LIST_FILE" ]; then
    echo "エラー: ファイルが存在しません: $ALARM_LIST_FILE"
    exit 1
fi

# 日付・時間を取得（例：20250515_1230）
DATE_TIME=$(date +"%Y%m%d_%H%M")

# 出力ファイル名を組み立て
BASENAME="${ALARM_LIST_FILE%.*}"
OUTPUT_FILE="${BASENAME}_${DATE_TIME}.csv"

# 出力ファイルにヘッダー行を書き込む
echo "アラーム名,メトリクス名,名前空間,統計,期間(秒),比較演算子,しきい値,データポイント数,欠落データの処理,通知先(SNS),アラームの説明" > "$OUTPUT_FILE"

# リストファイルを1行ずつ処理
while IFS= read -r ALARM_NAME || [ -n "$ALARM_NAME" ]; do
    # 空行はスキップ
    if [ -z "$ALARM_NAME" ]; then
        continue
    fi

    # CloudWatchアラームの取得とCSV出力
    aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" --query "MetricAlarms[]" | \
    jq -r '.[] | [
        .AlarmName,
        .MetricName,
        .Namespace,
        .Statistic,
        (.Period | tostring),
        .ComparisonOperator,
        (.Threshold | tostring),
        (.EvaluationPeriods | tostring),
        (.TreatMissingData // "デフォルト"),
        (if (.AlarmActions | length) > 0 then (.AlarmActions[] | select(contains("arn:aws:sns")) | split(":") | last) else "設定なし" end),
        (.AlarmDescription // "なし")
    ] | @csv' >> "$OUTPUT_FILE"

    if [ $? -ne 0 ]; then
        echo "エラー: ${ALARM_NAME} に対するCloudWatchアラーム情報取得に失敗しました。" >&2
    fi

done < "$ALARM_LIST_FILE"

echo "出力が完了しました: $OUTPUT_FILE"
