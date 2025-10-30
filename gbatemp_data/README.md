RyazhenkaAI offline data (GBATemp exports)

Put your .txt exports here. Then deploy to SD:

Windows (PowerShell):
  powershell -ExecutionPolicy Bypass -File tools/prepare_sd_layout.ps1 -SdRoot E:\

MSYS2 bash:
  bash tools/prepare_sd_layout.sh /e

Target on SD:
  sd:/switch/RyazhenkaAI/data/*.txt
