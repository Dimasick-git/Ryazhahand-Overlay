param(
	[string]$SdRoot = "E:\"
)

$sdData = Join-Path $SdRoot "switch/RyazhenkaAI/data"
Write-Host "Copying gbatemp_data to $sdData" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $sdData | Out-Null
Copy-Item -Path "gbatemp_data\*.txt" -Destination $sdData -Force
Write-Host "Done." -ForegroundColor Green
