$dst = "lib/libRYAZHAHAND/common"
Write-Host "Installing minimp3 headers to $dst" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $dst | Out-Null

Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/lieff/minimp3/master/minimp3_ex.h" -OutFile "$dst/minimp3_ex.h"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/lieff/minimp3/master/minimp3.h" -OutFile "$dst/minimp3.h"

Write-Host "Done." -ForegroundColor Green
