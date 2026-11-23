#requires -Version 7.0
param([string]$OutputName='_site')
$ErrorActionPreference='Stop'
$project=Split-Path $PSScriptRoot -Parent
if($OutputName -notmatch '^(_site|preview_[A-Za-z0-9_]+)$'){throw '出力先の名前が不正です。'}
$out=Join-Path $project $OutputName
if(Test-Path -LiteralPath $out){throw '出力先は既に存在します。上書きしません。'}
& (Join-Path $PSScriptRoot 'update-policy.ps1')
& (Join-Path $PSScriptRoot 'update-search.ps1')
. (Join-Path $PSScriptRoot 'パス.ps1')
$files=@(Get-RemnetPublishFiles)
[void][IO.Directory]::CreateDirectory($out)
foreach($entry in $files){
 $source=Join-Path $project $entry.source;$dest=Join-Path $out $entry.public
 [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
 if($entry.public -eq 'assets/scripts/pages.js'){
  $raw=[IO.File]::ReadAllText($source);$pages=@(ConvertFrom-Json $raw.Substring($raw.IndexOf('['),$raw.LastIndexOf(']')-$raw.IndexOf('[')+1))
  foreach($page in $pages){$page.PSObject.Properties.Remove('source')}
  $text='/* 公開ページの登録・検索データ */'+[Environment]::NewLine+'window.REMNET_PAGES = '+(ConvertTo-Json -InputObject $pages -Depth 12)+';'+[Environment]::NewLine
  [IO.File]::WriteAllText($dest,$text,[Text.UTF8Encoding]::new($false))
 }elseif([IO.Path]::GetExtension($source) -in @('.html','.css','.md')){
  $text=Convert-RemnetReferences -Text ([IO.File]::ReadAllText($source)) -File $source -Direction ToPublic -Markdown:([IO.Path]::GetExtension($source) -eq '.md')
  if([IO.Path]::GetExtension($source) -eq '.html'){
   $prefix='../'*(@($entry.public -split '/').Count-1)
   $icons='<link rel="icon" href="'+$prefix+'favicon.ico?v=rem-20261123" sizes="16x16 32x32 48x48" type="image/x-icon">'+
    '<link rel="icon" href="'+$prefix+'assets/images/icons/favicon-32.png?v=rem-20261123" sizes="32x32" type="image/png">'+
    '<link rel="apple-touch-icon" href="'+$prefix+'apple-touch-icon.png?v=rem-20261123" sizes="180x180">'
   # headの終了タグを省略した既存作品では、bodyの直前がheadの末尾になる。
   if($text -notmatch '(?i)(</head>|<body\b)'){throw "アイコンを設定する位置がありません: $($entry.public)"}
   $text=([regex]::new('(?i)(</head>|<body\b)')).Replace($text,[Text.RegularExpressions.MatchEvaluator]{param($m) $icons+$m.Value},1)
  }
  [IO.File]::WriteAllText($dest,$text,[Text.UTF8Encoding]::new($false))
 }else{[IO.File]::Copy($source,$dest,$false)}
}
Write-Output "公開用ファイルを作成しました：$out（$($files.Count)件）。GitHubへは送信していません。"
