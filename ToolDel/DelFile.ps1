function sendRequest {
     param(
            [parameter(Mandatory=$true)] # Định nghĩa tham số bắt buộc
            [string]$content
        )
       # Thay thế 'YOUR_BOT_TOKEN' bằng mã token truy cập API của bot của bạn
    $botToken = '6531753209:AAEv0yuwMdmAO9N8xKmcoDITvCM5BZ5jiTY'

    # Thay thế 'USER_ID' bằng ID của người dùng mà bạn muốn gửi tin nhắn đến
    $userId = '-946486935'
    # Thay thế 'YOUR_MESSAGE' bằng nội dung tin nhắn bạn muốn gửi
    $messageText = $content

    # Tạo URL cho yêu cầu API
    $apiUrl = "https://api.telegram.org/bot$botToken/sendMessage"

    # Tạo một hashtable chứa thông tin cho yêu cầu API
    $body = @{
        chat_id = $userId
        text = $messageText
    }
    # Gửi yêu cầu POST đến API của Telegram để gửi tin nhắn
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body

    # Xem kết quả của yêu cầu
    #$response

}



$currentDate = Get-Date
$daysToKeep = 1
$cutOffDate = $currentDate.AddDays(-$daysToKeep)

# Đường dẫn đến tập tin txt cần đọc để lấy danh sách các tập tin cần nén
$filePath = ".\PathsDel.txt"
# Đọc nội dung tập tin vào một mảng
$listPathsDel = Get-Content -Path $filePath

function toolDel {
    $sourceFolderPath = $listPathsDel
    $files = Get-ChildItem -Path $sourceFolderPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$daysToKeep) }

    $latestFile = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    foreach ($file in $files) {
        if ($file.FullName -ne $latestFile.FullName) {
            Remove-Item -Path $file.FullName -Force
        }
    }

    Write-Host "DELETE FILE SUCCESS!" -ForegroundColor Green
}

toolDel
