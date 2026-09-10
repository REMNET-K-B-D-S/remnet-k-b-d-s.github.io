#requires -Version 7.0
param([string]$OutputName = ('preview_' + (Get-Date -Format 'yyyyMMdd_HHmmss')))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($OutputName -notmatch '^(preview_[a-zA-Z0-9_]+|_site)$') { throw '出力名は preview_... または _site を指定してください。' }
$root = $PSScriptRoot
$out = Join-Path $root $OutputName
if (Test-Path -LiteralPath $out) { throw "既存の出力は上書きしません: $out" }
$diary = Join-Path $root '日記\公開'
function Escape([string]$value) { [System.Net.WebUtility]::HtmlEncode($value) }
$posts = @()
foreach ($file in @(Get-ChildItem -LiteralPath $diary -File -Filter '*.md')) {
 if ($file.Name -ieq 'README.md') { continue }
 if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "リンクされた日記は扱いません: $($file.Name)" }
 if ($file.BaseName -notmatch '^(\d{4}-\d{2}-\d{2})(?:-.+)?$') { throw "ノート名を YYYY-MM-DD または YYYY-MM-DD-題名 にしてください: $($file.Name)" }
 $dateText = $Matches[1]
 $date = [datetime]::MinValue
 if (-not [datetime]::TryParseExact($dateText,'yyyy-MM-dd',[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::None,[ref]$date)) { throw "日付が正しくありません: $($file.Name)" }
 $md = [IO.File]::ReadAllText($file.FullName,[Text.UTF8Encoding]::new($false,$true)).Trim()
 if ($md -match '^---(?:\r?\n|$)') { throw "この日記には先頭の設定欄は不要です。# 題名 から書いてください: $($file.Name)" }
 if ($md -notmatch '\A#\s+([^\r\n]+)(?:\r?\n|$)') { throw "先頭に # 題名 を書いてください: $($file.Name)" }
 $title = $Matches[1].Trim()
 $body = [regex]::Replace($md,'\A#\s+[^\r\n]+(?:\r?\n|$)','',1).Trim()
 $html = (ConvertFrom-Markdown -InputObject $body).Html
 $excerpt = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($html,'<[^>]*>',' '))
 $excerpt = [regex]::Replace($excerpt,'\s+',' ').Trim()
 if ($excerpt.Length -gt 100) { $excerpt=$excerpt.Substring(0,100)+'…' }
 $posts += [pscustomobject]@{Name=$file.BaseName;Date=$dateText;Title=$title;Body=$html;Excerpt=$excerpt;Href=([uri]::EscapeDataString($file.BaseName)+'.html')}
}
$posts = @($posts | Sort-Object @{Expression='Date';Descending=$true},@{Expression='Name';Descending=$true})
# All input validation is complete before creating output. New paths only.
[void][IO.Directory]::CreateDirectory((Join-Path $out 'notes'))
[void][IO.Directory]::CreateDirectory((Join-Path $out 'assets'))
function Write-New([string]$path,[string]$value) {
 $stream=[IO.File]::Open($path,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write)
 try {$bytes=[Text.UTF8Encoding]::new($false).GetBytes($value);$stream.Write($bytes,0,$bytes.Length)} finally {$stream.Dispose()}
}
foreach ($asset in @('diary.css','theme.js')) {
 Write-New (Join-Path $out "assets/$asset") ([IO.File]::ReadAllText((Join-Path $root "assets/$asset")))
}
function Page([string]$title,[string]$content,[string]$prefix) {
 $safeTitle=Escape $title
 return @"
<!doctype html>
<html lang="ja" data-theme="light"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'self'; script-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'none'">
<meta name="color-scheme" content="light dark"><title>$safeTitle | REMNET</title>
<link rel="stylesheet" href="${prefix}assets/diary.css"><script src="${prefix}assets/theme.js" defer></script></head>
<body><a class="skip" href="#main">本文へ進む</a><header class="top"><div class="shell top-inner"><a class="wordmark" href="${prefix}../home.html">REMNET<span>_</span>K<span>_</span>B<span>_</span>D<span>_</span>S</a><button class="theme" type="button" aria-label="ダークモードに切り替え" aria-pressed="false"><span class="disc" aria-hidden="true"></span><span id="theme-label">夜の色へ</span></button></div></header>
<main id="main" class="shell">$content</main>
<footer class="shell"><span class="mono">REMNET_K_B_D_S / NOTES &amp; LOG</span><a href="${prefix}index.html">日記一覧へ ↗</a></footer></body></html>
"@
}
$rows = [Collections.Generic.List[string]]::new()
foreach ($post in $posts) {
 $safeTitle=Escape $post.Title
 $excerpt=Escape $post.Excerpt
 $rows.Add("<a class=`"diary-row`" href=`"notes/$($post.Href)`"><time datetime=`"$($post.Date)`">$($post.Date)</time><div><h2>$safeTitle</h2><p>$excerpt</p></div><span class=`"arrow`" aria-hidden=`"true`">↗</span></a>")
 $article = @"
<div class="breadcrumb"><a href="../index.html">← 日記一覧</a><span class="mono">NOTES / LOG</span></div>
<article class="post"><header class="post-head"><time datetime="$($post.Date)" class="mono">$($post.Date)</time><h1>$safeTitle</h1></header><div class="prose">$($post.Body)</div></article><div class="post-end"><span>ここまで、今日の記録。</span><a href="../index.html">ほかの日も読む ↗</a></div>
"@
 Write-New (Join-Path $out "notes/$($post.Name).html") (Page $post.Title $article '../')
}
$entries = $rows -join "`n"
if ($posts.Count -eq 0) { $entries='<p class="empty">まだ、最初のページを待っています。</p>' }
$index = @"
<section class="journal-hero"><div class="eyebrow mono">03 / PERSONAL JOURNAL</div><h1>日々を、<br><em>ひとつずつ。</em></h1><div class="hero-bottom"><p>書きとめたこと。つくったこと。<br>その日に残しておきたかったこと。</p><span class="large-under" aria-hidden="true">_</span></div></section><div class="list-head"><span>日記・記録</span><span class="mono">$($posts.Count) ENTRIES / NEWEST FIRST</span></div><nav class="journal-list" aria-label="日記の記事一覧">$entries</nav><aside class="end-note">短い日も、長い日も。</aside>
"@
Write-New (Join-Path $out 'index.html') (Page '日記・記録' $index './')
Write-Output "生成完了: $($posts.Count) 記事 / $out"