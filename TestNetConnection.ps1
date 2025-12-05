$servers = @(
    @{ Name = "8.8.8.8"; Port = 25 },
    @{ Name = "www.sample.com"; Port = 80 },
    @{ Name = "www.sample.com"; Port = 443 },
    @{ Name = "vpce-xxxxxxxxxx.vpce-svc-xxxxxxxxx.ap-northeast-1.vpce.amazonaws.com"; Port = 22 }
)

$hostname = "hostname: $(HOSTNAME.EXE)"

foreach ($server in $servers) {
    # サーバーごとにファイルパスを生成
    $outputFile = "$($server.Name)_$($server.Port).txt"

    $result = Test-NetConnection -ComputerName $server.Name -Port $server.Port
    Write-Output $result.TcpTestSucceeded

    $hostname | Out-File -FilePath ".\$outputFile" -Append -Encoding utf8
    $result   | Out-File -FilePath ".\$outputFile" -Append -Encoding utf8
}