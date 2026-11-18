#requires -Version 7.0
$script:RemnetProject=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:RemnetMap=@(Get-Content -LiteralPath (Join-Path $PSScriptRoot '公開先.json') -Raw|ConvertFrom-Json)
function Get-RemnetPublicPath([string]$Source){
 $rel=[IO.Path]::GetRelativePath($script:RemnetProject,[IO.Path]::GetFullPath($Source)).Replace('\','/')
 $known=@($script:RemnetMap|Where-Object source -eq $rel)
 if($known.Count){return $known[0].public}
 if($rel -match '^site/共通/(.+)$'){return 'assets/'+$Matches[1]}
 if($rel -match '^site/作品/(.+)$'){return 'works/'+$Matches[1]}
 if($rel -match '^site/(案内|日記|記録|記事|文献・問い|制作|つながり|連絡先)/([^/]+\.html)$'){return 'pages/'+$Matches[2]}
 return $null
}
function Get-RemnetSourcePath([string]$Public){
 $key=$Public.Replace('\','/').TrimStart('/')
 if($key -match '(^|/)\.\.(/|$)'){throw '公開パスが範囲外です。'}
 $known=@($script:RemnetMap|Where-Object public -eq $key)
 if($known.Count -gt 1){throw '公開先が重複しています。'}
 if($known.Count){return Join-Path $script:RemnetProject $known[0].source}
 if($key -match '^assets/(.+)$'){return Join-Path $script:RemnetProject ('site/共通/'+$Matches[1])}
 if($key -match '^works/(.+)$'){return Join-Path $script:RemnetProject ('site/作品/'+$Matches[1])}
 if($key -match '^pages/(diary-[a-z0-9-]+\.html)$'){return Join-Path $script:RemnetProject ('site/日記/'+$Matches[1])}
 return $null
}
function Convert-RemnetReferences {
 param([string]$Text,[string]$File,[ValidateSet('ToPublic','ToSource')][string]$Direction='ToPublic',[switch]$Markdown)
 if($Direction -eq 'ToPublic'){$sourceFile=[IO.Path]::GetFullPath($File);$publicFile=Get-RemnetPublicPath $sourceFile}
 else{$publicFile=$File.Replace('\','/');$sourceFile=Get-RemnetSourcePath $publicFile}
 if(!$sourceFile -or !$publicFile){throw "対応のないファイル: $File"}
 $virtual=Join-Path $script:RemnetProject '__public'
 function Convert-OneReference([string]$Value){
  $decoded=[Net.WebUtility]::HtmlDecode($Value)
  if(!$decoded -or $decoded -match '^(?:[a-z][a-z0-9+.-]*:|//|#)'){return $Value}
  $parts=[regex]::Match($decoded,'^([^?#]*)([?#].*)?$');$path=[uri]::UnescapeDataString($parts.Groups[1].Value);$suffix=$parts.Groups[2].Value
  if(!$path){return $Value}
  if($Direction -eq 'ToPublic'){
   $target=if($path.StartsWith('/')){Join-Path $script:RemnetProject ('site/'+$path.TrimStart('/'))}else{Join-Path ([IO.Path]::GetDirectoryName($sourceFile)) $path}
   $published=Get-RemnetPublicPath ([IO.Path]::GetFullPath($target));if(!$published){return $Value}
   $from=Join-Path $virtual $publicFile;$to=Join-Path $virtual $published
  }else{
   $current=Join-Path $virtual $publicFile
   $target=[IO.Path]::GetFullPath($(if($path.StartsWith('/')){Join-Path $virtual $path.TrimStart('/')}else{Join-Path ([IO.Path]::GetDirectoryName($current)) $path}))
   if(!$target.StartsWith($virtual+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){return $Value}
   $resolved=Get-RemnetSourcePath ([IO.Path]::GetRelativePath($virtual,$target).Replace('\','/'));if(!$resolved){return $Value}
   $from=$sourceFile;$to=$resolved
  }
  $rel=[IO.Path]::GetRelativePath([IO.Path]::GetDirectoryName($from),$to).Replace('\','/')
  (($rel -split '/'|ForEach-Object {if($_ -in @('.','..')){$_}else{[uri]::EscapeDataString($_)}}) -join '/')+$suffix
 }
 function Convert-Part([string]$Part){
  if($Markdown){return [regex]::Replace($Part,'(\[[^\]]*\]\()([^\s)]+)(\))',[Text.RegularExpressions.MatchEvaluator]{param($m) $m.Groups[1].Value+(Convert-OneReference $m.Groups[2].Value)+$m.Groups[3].Value})}
  $out=[regex]::Replace($Part,'(?i)(\b(?:href|src)\s*=\s*)(["''])([^"'']*)\2',[Text.RegularExpressions.MatchEvaluator]{param($m) $m.Groups[1].Value+$m.Groups[2].Value+[Net.WebUtility]::HtmlEncode((Convert-OneReference $m.Groups[3].Value))+$m.Groups[2].Value})
  [regex]::Replace($out,'(?i)url\(\s*(["'']?)([^"'')]+)\1\s*\)',[Text.RegularExpressions.MatchEvaluator]{param($m) 'url('+$m.Groups[1].Value+(Convert-OneReference $m.Groups[2].Value)+$m.Groups[1].Value+')'})
 }
 if($Markdown){$chunks=[regex]::Split($Text,'(?ms)(^```[^\r\n]*\r?\n.*?^```[^\r\n]*$)');(($chunks|ForEach-Object {if($_ -match '\A```'){$_}else{Convert-Part $_}}) -join '')}else{Convert-Part $Text}
}
function Get-RemnetPublishFiles {
 $items=@($script:RemnetMap)
 foreach($entry in $items){
  $full=[IO.Path]::GetFullPath((Join-Path $script:RemnetProject $entry.source))
  $siteBoundary=(Join-Path $script:RemnetProject 'site')+[IO.Path]::DirectorySeparatorChar
  if($full -ne (Join-Path $script:RemnetProject 'README.md') -and !$full.StartsWith($siteBoundary,[StringComparison]::OrdinalIgnoreCase)){throw '公開元に管理資料を指定できません。'}
  if(!$full.StartsWith($script:RemnetProject+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or !(Test-Path -LiteralPath $full -PathType Leaf)){throw "公開元がありません: $($entry.source)"}
 }
 foreach($file in Get-ChildItem -LiteralPath (Join-Path $script:RemnetProject 'site') -Recurse -File){
  if($file.Name -eq 'desktop.ini'){continue}
  if($file.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'リンクされたファイルは公開しません。'}
  $rel=[IO.Path]::GetRelativePath($script:RemnetProject,$file.FullName).Replace('\','/')
  if(@($items|Where-Object source -eq $rel).Count){continue}
  if($file.Extension -notin @('.html','.css','.js','.png','.jpg','.jpeg','.svg','.webp','.gif','.woff','.woff2')){throw "未登録の公開候補: $rel"}
  $public=Get-RemnetPublicPath $file.FullName;if(!$public){throw "公開先が不明: $rel"};$items+=[pscustomobject]@{source=$rel;public=$public}
 }
 $seen=@{}
 foreach($entry in $items){
  $out=[IO.Path]::GetFullPath((Join-Path (Join-Path $script:RemnetProject '_site') $entry.public))
  if(!$out.StartsWith((Join-Path $script:RemnetProject '_site')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw '公開先が範囲外です。'}
  if($seen.ContainsKey($entry.public)){throw "公開先の重複: $($entry.public)"};$seen[$entry.public]=$true
 }
 return $items
}
