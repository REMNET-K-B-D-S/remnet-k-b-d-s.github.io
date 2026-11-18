#requires -Version 7.0
param([string]$OutputName='_site')
$ErrorActionPreference='Stop'
if($OutputName -notmatch '^(_site|preview_[A-Za-z0-9_]+)$'){throw 'Invalid output name.'}
$out=Join-Path $PSScriptRoot $OutputName
if(Test-Path -LiteralPath $out){throw 'Output already exists.'}
& (Join-Path $PSScriptRoot 'scripts/update-policy.ps1')
# 登録漏れや本文修正後の更新忘れを、公開する前に解消・検出する。
& (Join-Path $PSScriptRoot 'scripts/update-search.ps1')
$files=@('index.html','.nojekyll','README.md','サイトポリシー_研究・取材に関する方針.md')
foreach($folder in @('assets','pages','works','About','Links','SPIRIT表紙_試作05','日記公開基盤')){
 if(Test-Path -LiteralPath (Join-Path $PSScriptRoot $folder)){
  foreach($f in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot $folder) -File -Recurse){
   if($f.Extension -in @('.html','.css','.js','.png','.jpg','.jpeg','.svg','.webp','.gif','.woff','.woff2','.md') -or $f.Name -eq 'LICENSE'){
    $files+=[IO.Path]::GetRelativePath($PSScriptRoot,$f.FullName)
   }
  }
 }
}
$files+=@(Get-ChildItem -LiteralPath $PSScriptRoot -File -Filter '*.html'|ForEach-Object Name)
$files=@($files|Sort-Object -Unique)
foreach($rel in $files){if(!(Test-Path -LiteralPath (Join-Path $PSScriptRoot $rel) -PathType Leaf)){throw "Missing: $rel"}}
[void][IO.Directory]::CreateDirectory($out)
foreach($rel in $files){
 $to=Join-Path $out $rel;[void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to))
 [IO.File]::Copy((Join-Path $PSScriptRoot $rel),$to,$false)
}
Write-Output "Site generated: $out"



