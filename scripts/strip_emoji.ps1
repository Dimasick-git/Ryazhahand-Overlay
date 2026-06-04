#!/usr/bin/env pwsh
# Удаляет эмодзи и символы вне базового латинского/кириллического диапазона
# из текстовых файлов проекта. Switch UI не рендерит эмодзи -- они
# превращаются в "?" или ломают layout.

[CmdletBinding()]
param(
 [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
 [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-Location $Root

# Регулярка покрывает:
# - U+1F300..U+1FAFF -- эмодзи (символы, объекты, лица, флаги)
# - U+2600..U+27BF -- Dingbats и символы (галочки, стрелки, шестерёнки)
# - U+2700..U+27BF -- Dingbats
# - U+1F000..U+1F9FF -- регион эмодзи
# - U+FE0F, U+FE0E -- variation selectors
# - U+200D -- zero-width joiner (в составных эмодзи)
# - U+2300..U+23FF -- Misc technical (часы, символы)
# - U+25A0..U+26FF -- геометрические + misc
$emojiRegex = "[\u{1F300}-\u{1FAFF}\u{1F000}-\u{1F9FF}\u{2600}-\u{27BF}\u{2300}-\u{23FF}\u{25A0}-\u{26FF}\u{FE00}-\u{FE0F}\u{200D}\u{2B00}-\u{2BFF}]"

$extensions = @('.md','.txt','.cpp','.hpp','.h','.c','.mk','.ini','.json','.yml','.yaml','.ps1','.py','.sh')
$skipPatterns = @(
 '\\lib\\libryazhahand\\',
 '\\\.git\\',
 '\\build\\',
 '\\out\\',
 'scripts\\strip_emoji\.ps1',
 'scripts\\rebrand-report\.txt'
)

function Should-Skip([string]$path) {
 foreach ($pat in $skipPatterns) { if ($path -match $pat) { return $true } }
 return $false
}

$report = [System.Collections.Generic.List[string]]::new()
$changed = 0
$scanned = 0

Get-ChildItem -Path $Root -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
 $file = $_
 if (Should-Skip $file.FullName) { return }
 $ext = $file.Extension.ToLower()
 if (-not $extensions.Contains($ext) -and $file.Name -notin @('Makefile','LICENSE','README')) { return }

 $scanned++
 try { $content = [System.IO.File]::ReadAllText($file.FullName) } catch { return }
 if ([string]::IsNullOrEmpty($content)) { return }

 $cleaned = [regex]::Replace($content, $emojiRegex, '')
 # Также убрать лишние двойные пробелы перед знаками препинания после удаления
 $cleaned = [regex]::Replace($cleaned, ' +', ' ')
 $cleaned = [regex]::Replace($cleaned, ' +\r?\n', "`n")

 if ($cleaned -ne $content) {
 $rel = $file.FullName.Replace($Root + '\','')
 $diff = ($content.Length - $cleaned.Length)
 $report.Add("$rel : -$diff chars")
 $changed++
 if (-not $DryRun) {
 [System.IO.File]::WriteAllText($file.FullName, $cleaned)
 }
 }
}

$reportPath = Join-Path $Root 'scripts\strip_emoji-report.txt'
$header = @(
 "Strip emoji run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
 "Dry run: $DryRun"
 "Scanned: $scanned"
 "Changed: $changed"
 ""
)
($header + $report) | Set-Content -Path $reportPath -Encoding UTF8

Write-Output "Scanned: $scanned"
Write-Output "Changed: $changed"
Write-Output "Report: $reportPath"
