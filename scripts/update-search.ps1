#requires -Version 7.0
param([switch]$CheckOnly)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path $PSScriptRoot -Parent
$manifest=Join-Path $root 'assets/scripts/pages.js'
$raw=[IO.File]::ReadAllText($manifest)
$start=$raw.IndexOf('[');$end=$raw.LastIndexOf(']')
if($start -lt 0 -or $end -lt $start){throw '検索用データの形式が不正です。'}
$previous=@(ConvertFrom-Json $raw.Substring($start,$end-$start+1))
$groups=@('案内','日記','記録','記事','文献・問い','制作','つながり','連絡先')
function Decode([string]$text){[Net.WebUtility]::HtmlDecode($text)}
function Meta([string]$html,[string]$name){
 foreach($tag in [regex]::Matches($html,'(?is)<meta\b[^>]*>')){
  $fields=@{}
  foreach($attribute in [regex]::Matches($tag.Value,'([a-zA-Z-]+)\s*=\s*(?:"([^"]*)"|''([^'']*)'')')){
   $value=if($attribute.Groups[2].Success){$attribute.Groups[2].Value}else{$attribute.Groups[3].Value}
   $fields[$attribute.Groups[1].Value.ToLowerInvariant()]=Decode $value
  }
  if($fields.ContainsKey('name') -and $fields.name -eq $name -and $fields.ContainsKey('content')){return $fields.content}
 }
 return ''
}
$discovered=@();$ids=@{};$files=@{}
foreach($nested in @(Get-ChildItem -LiteralPath (Join-Path $root 'pages') -Recurse -File -Filter '*.html')){
 if($nested.DirectoryName -ne (Join-Path $root 'pages')){throw 'ページHTMLはpages直下に置いてください。入れ子のページは未対応です。'}
}
foreach($file in @(Get-ChildItem -LiteralPath (Join-Path $root 'pages') -File -Filter '*.html' | Sort-Object Name)){
 if($file.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'リンクされたページは登録できません。'}
 $html=[IO.File]::ReadAllText($file.FullName,[Text.UTF8Encoding]::new($false,$true))
 $body=[regex]::Match($html,'(?is)<body\b[^>]*\bdata-page\s*=\s*["'']([a-z0-9-]+)["''][^>]*>')
 if(!$body.Success){throw "ページのdata-pageがありません: $($file.Name)"}
 $id=$body.Groups[1].Value
 if($ids.ContainsKey($id)){throw "ページIDが重複しています: $id"}
 $ids[$id]=$true;$files[$file.Name]=$true
 $old=@($previous|Where-Object id -eq $id)
 if($old.Count -gt 1){throw "既存の登録が重複しています: $id"}
 if($old.Count -and $old[0].file -ne $file.Name){throw "既存ページのファイル名変更は案内先も含めて確認してください: $id"}
 $group=Meta $html 'remnet-group'
 if(!$group -and $old.Count){$group=$old[0].group}
 if($group -notin $groups){throw "ページの分類をmeta name=remnet-groupで指定してください: $($file.Name)"}
 $title=Meta $html 'remnet-title'
 if(!$title){$title=Decode ([regex]::Match($html,'(?is)<title>(.*?)</title>').Groups[1].Value)}
 $title=([regex]::Replace($title,'\s*[—–|｜]\s*REMNET_K_B_D_S\s*$','')).Trim()
 if(!$title){throw "ページのタイトルがありません: $($file.Name)"}
 $tagText=Meta $html 'remnet-tags'
 $tags=if($tagText){@($tagText -split ','|ForEach-Object {$_.Trim()}|Where-Object {$_})}elseif($old.Count){@($old[0].tags)}else{@()}
 $text=[regex]::Replace($html,'(?is)<!--.*?-->|<head\b[^>]*>.*?</head>|<script\b[^>]*>.*?</script>|<style\b[^>]*>.*?</style>','')
 $text=[regex]::Replace((Decode ([regex]::Replace($text,'<[^>]*>',' '))),'\s+',' ').Trim()
 $discovered+=[pscustomobject]@{id=$id;file=$file.Name;title=$title;group=$group;tags=@($tags|Where-Object {$null -ne $_ -and $_ -ne ''});text=$text}
}
foreach($p in $previous){if(!$ids.ContainsKey($p.id)){throw "登録済みページがなくなっています。削除意図を確認してください: $($p.file)"}}
foreach($id in @('home','about','diary','notes','articles','library','questions','tags','lab','works','links','shop','contact','search')){
 if(!$ids.ContainsKey($id)){throw "固定の入口ページがありません: $id"}
}
# 新しいページを含め、タブ操作のリンク先も検査する。
foreach($p in $discovered){
 $html=[IO.File]::ReadAllText((Join-Path $root ('pages/'+$p.file)))
 foreach($match in [regex]::Matches($html,'(?is)<a\b[^>]*\bdata-page=["'']([^"'']+)["''][^>]*>')){
  if(!$ids.ContainsKey($match.Groups[1].Value)){throw "ページ移動先のIDが未登録です: $($p.file)"}
 }
}
# 既存の表示順を保ち、新規ページを末尾へ追加。左の入口数は増やさない。
$ordered=@()
foreach($p in $previous){$ordered+=@($discovered|Where-Object id -eq $p.id)}
$ordered+=@($discovered|Where-Object {$_.id -notin @($previous|ForEach-Object id)})
if($CheckOnly){Write-Output "検索の確認：$($ordered.Count)ページ。変更していません。";return}
$js='/* 公開ページから生成したタイトル・本文・タグの検索データ。 */'+[Environment]::NewLine+'window.REMNET_PAGES = '+(ConvertTo-Json -InputObject @($ordered) -Depth 10)+';'+[Environment]::NewLine
$temporary=$manifest+'.tmp'
try{[IO.File]::WriteAllText($temporary,$js,[Text.UTF8Encoding]::new($false));[IO.File]::Move($temporary,$manifest,$true)}finally{if(Test-Path -LiteralPath $temporary){Remove-Item -LiteralPath $temporary}}
Write-Output "検索を更新しました：$($ordered.Count)ページ。"
