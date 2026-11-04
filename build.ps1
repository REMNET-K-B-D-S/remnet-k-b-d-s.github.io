#requires -Version 7.0
param([string]$OutputName='_site')
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if($OutputName -notmatch '^(_site|preview_[a-zA-Z0-9_]+)$'){throw 'Invalid output name.'}
$out=Join-Path $PSScriptRoot $OutputName
if(Test-Path -LiteralPath $out){throw "Output already exists: $out"}
$files=@(
 'index.html','home.html','notes.html','contact.html',
 'diary.html','research-ethics.html','articles.html','library.html','questions.html','tags.html'
)
# Only website files in the approved asset/page folders are published.
foreach($folder in @('About','Links','SPIRIT表紙_試作05','assets')){
 foreach($file in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot $folder) -File -Recurse){
  if($file.Extension -in @('.html','.css','.js','.png','.jpg','.jpeg','.svg','.webp','.gif','.woff','.woff2')){
   $files += [IO.Path]::GetRelativePath($PSScriptRoot,$file.FullName)
  }
 }
}
$files=@($files|Sort-Object -Unique)
foreach($file in $files){
 if(-not(Test-Path -LiteralPath (Join-Path $PSScriptRoot $file) -PathType Leaf)){throw "Missing: $file"}
}
# Preserve the existing public-diary renderer and its source files unchanged.
$diaryOutput='preview_'+[guid]::NewGuid().ToString('N')
& (Join-Path $PSScriptRoot '日記公開基盤/build.ps1') -OutputName $diaryOutput
[void][IO.Directory]::CreateDirectory($out)
foreach($file in $files){
 $dest=Join-Path $out $file
 [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
 [IO.File]::Copy((Join-Path $PSScriptRoot $file),$dest,$false)
}
$diaryResult=Join-Path $PSScriptRoot "日記公開基盤/$diaryOutput"
foreach($file in Get-ChildItem -LiteralPath $diaryResult -File -Recurse){
 $relative=[IO.Path]::GetRelativePath($diaryResult,$file.FullName)
 $dest=Join-Path $out "日記公開基盤/$relative"
 [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
 [IO.File]::Copy($file.FullName,$dest,$false)
}
[IO.File]::WriteAllText((Join-Path $out '.nojekyll'),'')
Write-Output "Site generated: $out"