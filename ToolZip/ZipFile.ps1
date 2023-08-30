#Nơi sẽ bị nén | Ví dụ | $sourceFolderPath = "C:\logs" 
#Nơi lưu file sau khi nén xong | Ví dụ | $backupFolderPath = "C:\Logs_BAK" 
# Gửi cảnh báo nếu zip lỗi qua telegram

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
$daysToKeep = 0
$cutOffDate = $currentDate.AddDays(-$daysToKeep)

# Đường dẫn đến tập tin txt cần đọc để lấy danh sách các tập tin cần nén
$filePath = ".\listFolderWillZip.txt"

# Đường dẫn đến tập tin txt cần đọc để lấy đường dẫn sẽ lưu các file .zip sau khi lưu lại
$filePathSave = ".\PathSaveFileZip.txt"

# Đọc nội dung tập tin vào một mảng
$listSourceFolderPath = Get-Content -Path $filePath

# Đọc nội dung của file txt mà vừa nãy lấy đường dẫn để lưu folder sau zip
$backupFolderPath = Get-Content -Path $filePathSave


function zipFunction {
    param (
        [array]$listSourceFolderPath,
        [string]$backupFolderPath
    )
            #Tạo khung bảng cố định
            $column1Header = "FROM"
            $column2Header = "TO"
            $column3Header = "STATUS"
            $separator = "+--------------------------------+--------------------------------+--------------------------------+"
            Write-Host
            Write-Host "STATUS DESCRIPTION ZIP FILE:" -ForegroundColor Yellow
            Write-Host $separator
            Write-Host ("| {0,-30} | {1,-30} | {2,-30} |" -f $column1Header, $column2Header, $column3Header)
            Write-Host $separator

    foreach ($sourceFolderPath in $listSourceFolderPath) {
        try {
            # Tạo tên tệp nén dựa trên ngày và giờ hiện tại
            $folderName = (Split-Path -Path $sourceFolderPath -Leaf)
            $zipFileName = "$folderName BAK_$($currentDate.ToString("yyyyMMdd_HHmmss")).zip"
            $zipFilePath = Join-Path -Path $backupFolderPath -ChildPath $zipFileName

            # Lấy danh sách các tệp cần nén
            $filesToZip = Get-ChildItem -Path $sourceFolderPath | Where-Object { $_.LastWriteTime -lt $cutOffDate }

            # Nén các tệp và thư mục vào tệp nén
            Add-Type -A 'System.IO.Compression.FileSystem'
            [IO.Compression.ZipFile]::CreateFromDirectory($sourceFolderPath, $zipFilePath)

            # Di chuyển tệp nén từ thư mục nguồn vào thư mục đích
            Move-Item $zipFilePath $backupFolderPath

            # Thông báo
            #Kẻ theo GPT
            
            # Set màu cho chữ DONE
            $formatString = "| {0,-30} | {1,-30} | {2, -0}" -f $sourceFolderPath, $backupFolderPath, ""
            $coloredDoneText = "DONE"
            $resetString = " |"
            Write-Host -NoNewLine $formatString
            Write-Host -NoNewLine ("{0,-30}" -f $coloredDoneText) -ForegroundColor Green
            Write-Host -NoNewLine $resetString
            Write-Host
            Write-Host $separator
            
        }
        catch {
            # Set màu cho chữ DONE
            $formatString = "| {0,-30} | {1,-30} | {2, -0}" -f $sourceFolderPath, $backupFolderPath, ""
            $coloredDoneText = "FALSE"
            $resetString = " |"
            Write-Host -NoNewLine $formatString
            Write-Host -NoNewLine ("{0,-30}" -f $coloredDoneText) -ForegroundColor Red
            Write-Host -NoNewLine $resetString "---> Detail:" $($_.Exception.Message)
            Write-Host
            Write-Host $separator
            sendRequest -content "[ERROR] An error occurred while running the tool: \n $($_.Exception.Message)"
        }
    }
}
#Gọi hàm
zipFunction -listSourceFolderPath $listSourceFolderPath -backupFolderPath $backupFolderPath





