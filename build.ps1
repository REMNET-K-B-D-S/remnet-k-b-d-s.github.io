#requires -Version 7.0
param([string]$OutputName='_site')
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if ($OutputName -notmatch '^(_site|preview_[a-zA-Z0-9_]+)$') { throw 'Invalid output name.' }
$out=Join-Path $PSScriptRoot $OutputName
if(Test-Path -LiteralPath $out) { throw "Output already exists: $out" }
$files=@('index.html','home.html','Links/links_20260910.html','About/about.html','About/about.css','assets/about_ハートと点滴くま.png','assets/lab_草に還る実験室.png','assets/mail_新芽のキーボードと緑のディスク.png','SPIRIT表紙_試作05/opening.html','SPIRIT表紙_試作05/style.css','SPIRIT表紙_試作05/animation.js','SPIRIT表紙_試作05/gsap.min.js','SPIRIT表紙_試作05/scene.png','SPIRIT表紙_試作05/clean-plate.png','日記公開基盤/assets/theme.js')
foreach($file in $files) { if(-not(Test-Path -LiteralPath (Join-Path $PSScriptRoot $file) -PathType Leaf)) { throw "Missing: $file" } }
$diaryOutput='preview_'+[guid]::NewGuid().ToString('N')
& (Join-Path $PSScriptRoot '日記公開基盤/build.ps1') -OutputName $diaryOutput
[void][IO.Directory]::CreateDirectory($out)
foreach($file in $files) {
 $dest=Join-Path $out $file
 [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
 [IO.File]::Copy((Join-Path $PSScriptRoot $file),$dest,$false)
}
$diaryResult=Join-Path $PSScriptRoot "日記公開基盤/$diaryOutput"
foreach($file in Get-ChildItem -LiteralPath $diaryResult -File -Recurse) {
 $relative=[IO.Path]::GetRelativePath($diaryResult,$file.FullName)
 $dest=Join-Path $out "日記公開基盤/$relative"
 [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
 if(-not(Test-Path -LiteralPath $dest)) { [IO.File]::Copy($file.FullName,$dest,$false) }
}
[IO.File]::WriteAllText((Join-Path $out '.nojekyll'),'')
Write-Output "Site generated: $out"