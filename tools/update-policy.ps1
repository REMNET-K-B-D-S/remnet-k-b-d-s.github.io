#requires -Version 7.0
$ErrorActionPreference='Stop'
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$site=Join-Path $project 'site/案内'
$documents=@(
 @{Source='site/案内/サイトポリシー_研究・取材に関する方針.md';Id='site-policy';Title='研究・取材に関する方針';File='site-policy.html'},
 @{Source='README.md';Id='readme';Title='README.md';File='readme.html'}
)
foreach($doc in $documents){
 $body=(ConvertFrom-Markdown -LiteralPath (Join-Path $project $doc.Source)).Html
 $body=$body.Replace('href="https://remnet-k-b-d-s.github.io/#contact"','href="../連絡先/index.html" data-page="contact"')
 $body=$body.Replace('href="https://remnet-k-b-d-s.github.io/#site-policy"','href="site-policy.html" data-page="site-policy"')
 $body=[regex]::Replace($body,'href="([^"]+)"',[Text.RegularExpressions.MatchEvaluator]{
  param($m)
  if([uri]::UnescapeDataString($m.Groups[1].Value).EndsWith('サイトポリシー_研究・取材に関する方針.md')){return 'href="site-policy.html" data-page="site-policy"'}
  return $m.Value
 })
 $title=[Net.WebUtility]::HtmlEncode($doc.Title)
 $html=@"
<!doctype html>
<html lang="ja" data-theme="dark"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="dark light"><meta name="remnet-group" content="案内"><meta name="remnet-tags" content="サイトの説明,研究,取材,ライセンス"><title>$title — REMNET_K_B_D_S</title><link rel="stylesheet" href="../共通/styles/site.css"><style>.paper{overflow-wrap:anywhere}</style><script src="../共通/scripts/reader.js" defer></script></head>
<body class="page-body" data-page="$($doc.Id)"><article class="paper"><div class="page-label"><span>案内 ／ $title</span><span>REMNET_K_B_D_S</span></div>
$body
<footer class="page-end"><a href="about.html" data-page="about">← REMNETについて</a><a href="readme.html" data-page="readme">README.md</a><a href="site-policy.html" data-page="site-policy">研究・取材に関する方針</a></footer></article></body></html>
"@
 [IO.File]::WriteAllText((Join-Path $site $doc.File),$html,[Text.UTF8Encoding]::new($false))
}
Write-Output 'READMEとサイトポリシーのHP表示をMarkdownから更新しました。'
