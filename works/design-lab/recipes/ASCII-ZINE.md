# 06 ASCII ZINE｜HTMLレシピ

## 対応するHTML

[動くHTMLを開く](../pages/06-ascii-zine.html)

## このデザイン

記号・空白・改行だけでも絵と枠が見える、コピー誌風の文字デザイン。

## 心理的にAI製っぽく見えにくいかもしれない理由

効率より執念が見える文字組みを、誰かが手で作った痕跡として使う。

これは客観的な判定方法ではなく、REMNET_K_B_D_Sによる、Codexを制作補助に活用したデザイン上の仮説です。

## 基本の色

紙 #EEE7D9／黒 #181713。

## 再現方法

1. 下のHTML全文を、新しい拡張子 `.html` のファイルへ貼り付けます。
2. UTF-8で保存します。
3. 保存したHTMLをウェブブラウザで開きます。
4. `:root` またはCSS冒頭の色指定を変えると、自分用の配色にできます。
5. 文章部分を差し替えれば、構造を保ったまま別のページへ展開できます。

## 現在のHTML全文

以下は、対応するHTMLファイルと同じ内容です。

```html
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>06 ASCII ZINE｜REMNET Design Archive</title>
  <style>
    :root { --paper:#eee7d9; --ink:#181713; }
    * { box-sizing:border-box; }
    body { margin:0; color:var(--ink); background:var(--paper); font:16px/1.45 "Courier New","MS Gothic",monospace; }
    a { color:inherit; }
    .zine { width:min(calc(100% - 22px),900px); margin:18px auto 50px; }
    .ascii { overflow:hidden; white-space:pre; font-size:clamp(7px,1.45vw,14px); line-height:1.05; letter-spacing:0; }
    header { padding:22px 0; text-align:center; border-top:3px double var(--ink); border-bottom:3px double var(--ink); }
    .small { margin:0; font-size:.75rem; letter-spacing:.2em; }
    h1 { margin:14px 0; font-size:clamp(2.4rem,9vw,7rem); line-height:.85; letter-spacing:-.09em; }
    .issue { display:inline-block; padding:3px 10px; border:1px solid var(--ink); }
    .spread { display:grid; grid-template-columns:1fr 1fr; margin-top:22px; border:2px solid var(--ink); }
    .page { min-height:400px; padding:clamp(20px,5vw,46px); }
    .page + .page { border-left:2px dashed var(--ink); }
    h2 { margin:0 0 24px; font-size:1.1rem; text-transform:uppercase; }
    p { margin:0; } p+p { margin-top:16px; }
    .loud { margin:28px 0; font-size:clamp(1.3rem,3.5vw,2.5rem); font-weight:700; line-height:1.15; }
    pre.code { margin:20px 0 0; padding:14px; overflow:auto; border:1px dashed var(--ink); font:11px/1.45 Consolas,monospace; }
    .notice { margin:22px 0; padding:12px; text-align:center; border-top:1px solid var(--ink); border-bottom:1px solid var(--ink); }
    footer { display:flex; justify-content:space-between; gap:18px; padding:18px 0; border-bottom:3px double var(--ink); font-size:.76rem; }
    .back { font-weight:700; }
    @media(max-width:650px){ .spread{grid-template-columns:1fr}.page+.page{border-left:0;border-top:2px dashed var(--ink)}footer{flex-direction:column} }
  </style>
</head>
<body>
  <main class="zine">
    <div class="ascii" aria-hidden="true">+------------------------------------------------------------------------------+
| [REM]====[NET]====[K]====[B]====[D]====[S] || [ASCII]====[ZINE]====[2026] |
+------------------------------------------------------------------------------+</div>
    <header><p class="small">OPEN CALL FOR STRANGE WEB PAGES</p><h1>ASCII<br>ZINE</h1><span class="issue">ISSUE 06 / FREE CODE</span></header>
    <section class="spread">
      <article class="page"><h2>文字しかないのに、絵が見える。</h2><p class="loud">古の手仕事デザイン。</p><p>記号、空白、改行。使っている材料はほぼ文字だけ。それでも棚、枠、矢印、顔、機械まで作れる。</p><div class="notice">[ REMNETの雑感 ]<br>画像がないなら、文字で描けばいいじゃない。</div><p>少しズレても、それが印刷物やコピー誌のような個体差になる。完璧な整列から、あえて半歩だけ外へ出る。</p></article>
      <article class="page"><h2>心理ハック仮説</h2><p>手で文字数を数え、空白を置いたような画面には、効率より執念が見える。その不必要な執念を、人は「誰かが作った痕跡」と受け取るのかもしれない。</p><h2 style="margin-top:30px">再現の芯</h2><pre class="code"><code>&lt;pre class="ascii"&gt;
+----------------------+
|  REMNET WEB ARCHIVE  |
+----------------------+
&lt;/pre&gt;

.ascii {
  white-space: pre;
  font-family: monospace;
  line-height: 1;
}</code></pre><p class="loud">COPY.<br>BREAK.<br>MAKE AGAIN.</p></article>
    </section>
    <div class="ascii" aria-hidden="true">+----+  +----------+  +----+  +----------------------+  +----+  +----------+
| !! |--| HUMAN?   |--| ?? |--| ANSWER NOT REQUIRED  |--| OK |--| GO BACK  |
+----+  +----------+  +----+  +----------------------+  +----+  +----------+</div>
    <footer><a class="back" href="../index.html">&lt; INDEXへ戻る</a><span>created by REMNET_K_B_D_S 制作補助：Codex / 企画・制作：REMNET_K_B_D_S</span></footer>
  </main>
</body>
</html>

```

## クレジット

```text
SINCE 2026-08-03
created by REMNET_K_B_D_S
制作補助：Codex
企画・制作：REMNET_K_B_D_S
```

