#!/usr/bin/env pwsh
# Применение ребрендинга Ultrahand -> Ryzhand / Ryazhahand.
#
# Правила (порядок важен -- длинные паттерны раньше коротких):
# <UPPERHAND> -> <UPPERRYZ>
# <TitleHand> -> <TitleRyz>
# <lowerhand> -> <lowerryaz>
# <oldAuthor> -> <newAuthor>
# github.com/<oldAuthor>/<oldRepo> -> github.com/<newAuthor>/<newRepo>
#
# Исключения: lib/libryazhahand/, .git/, build/, out/, .pics/*.png, этот скрипт.

[CmdletBinding()]
param(
 [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
 [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-Location $Root

# Подставляем токены пары здесь, чтобы скрипт не "ребрендировал" сам себя
# при повторных запусках.
$OLD_AUTHOR = 'pp' + 'kantorski'
$NEW_AUTHOR = 'Dimasick-git'
$OLD_OVERLAY = 'Ult' + 'rahand-Overlay'
$NEW_OVERLAY = 'Ryazhahand-Overlay'
$OLD_LIB = 'libult' + 'rahand'
$NEW_LIB = 'libryazhahand'
$OLD_UPPER = 'ULT' + 'RAHAND'
$NEW_UPPER = 'RYZHAND'
$OLD_TITLE = 'Ult' + 'rahand'
$NEW_TITLE = 'Ryzhand'
$OLD_LOWER = 'ult' + 'rahand'
$NEW_LOWER = 'ryazhahand'

$rules = @(
 @{ from = "github.com/$OLD_AUTHOR/$OLD_OVERLAY"; to = "github.com/Dimasick-git/$NEW_OVERLAY" }
 @{ from = "github.com/$OLD_AUTHOR/$OLD_LIB"; to = "github.com/Dimasick-git/$NEW_LIB" }
 @{ from = "github.com/$OLD_AUTHOR"; to = 'github.com/Dimasick-git' }
 @{ from = $OLD_AUTHOR; to = $NEW_AUTHOR }
 @{ from = $OLD_OVERLAY; to = $NEW_OVERLAY }
 @{ from = ($OLD_OVERLAY.ToUpper()); to = ($NEW_OVERLAY.ToUpper()) }
 @{ from = ($OLD_TITLE + ' Overlay'); to = ($NEW_TITLE + ' Overlay') }
 @{ from = $OLD_LIB; to = $NEW_LIB }
 @{ from = ($OLD_LIB.ToUpper()); to = ($NEW_LIB.ToUpper()) }
 @{ from = $OLD_UPPER; to = $NEW_UPPER }
 @{ from = $OLD_TITLE; to = $NEW_TITLE }
 @{ from = $OLD_LOWER; to = $NEW_LOWER }
)

$textExtensions = @(
 '.md','.txt','.cpp','.hpp','.h','.c','.mk','.ini','.json','.yml','.yaml',
 '.toml','.cfg','.conf','.xml','.sh','.ps1','.py','.makefile','.gitignore',
 '.gitattributes','.editorconfig','.lock'
)

$skipPatterns = @(
 '\\lib\\libryazhahand\\',
 '\\\.git\\',
 '\\build\\',
 '\\out\\',
 '\\debug\\build\\',
 'scripts\\rebrand\.ps1',
 'scripts\\rebrand-report\.txt'
)

$noExtTextFiles = @('Makefile','LICENSE','SUB_LICENSE','CODE_OF_CONDUCT')

function Should-Skip([string]$path) {
 foreach ($pat in $skipPatterns) {
 if ($path -match $pat) { return $true }
 }
 return $false
}

function Is-TextFile([System.IO.FileInfo]$file) {
 if ($file.Extension -and $textExtensions -contains $file.Extension.ToLower()) { return $true }
 if (-not $file.Extension -and $noExtTextFiles -contains $file.Name) { return $true }
 return $false
}

$allFiles = Get-ChildItem -Path $Root -Recurse -File -Force -ErrorAction SilentlyContinue
$report = [System.Collections.Generic.List[string]]::new()
$changed = 0
$scanned = 0

foreach ($file in $allFiles) {
 if (Should-Skip $file.FullName) { continue }
 if (-not (Is-TextFile $file)) { continue }

 $scanned++
 try {
 $content = [System.IO.File]::ReadAllText($file.FullName)
 } catch {
 continue
 }
 if ([string]::IsNullOrEmpty($content)) { continue }

 $orig = $content
 $hits = @{}
 foreach ($rule in $rules) {
 $count = ([regex]::Matches($content, [regex]::Escape($rule.from))).Count
 if ($count -gt 0) {
 $content = $content.Replace($rule.from, $rule.to)
 $hits[$rule.from] = $count
 }
 }

 if ($content -ne $orig) {
 $rel = $file.FullName.Replace($Root + '\','')
 $hitSummary = ($hits.GetEnumerator() | ForEach-Object { "$($_.Key)x$($_.Value)" }) -join ', '
 $report.Add("$rel : $hitSummary")
 $changed++
 if (-not $DryRun) {
 [System.IO.File]::WriteAllText($file.FullName, $content)
 }
 }
}

$reportPath = Join-Path $Root 'scripts\rebrand-report.txt'
$header = @(
 "Rebrand run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
 "Dry run: $DryRun"
 "Scanned: $scanned"
 "Changed: $changed"
 ""
)
($header + $report) | Set-Content -Path $reportPath -Encoding UTF8

Write-Output "Scanned: $scanned files"
Write-Output "Changed: $changed files"
Write-Output "Report: $reportPath"
