(() => {
 'use strict';
 const button = document.querySelector('.theme');
 const label = document.getElementById('theme-label');
 function apply(dark) {
  document.documentElement.dataset.theme = dark ? 'dark' : 'light';
  button.setAttribute('aria-pressed', String(dark));
  button.setAttribute('aria-label', dark ? 'ライトモードに切り替え' : 'ダークモードに切り替え');
  label.textContent = dark ? '昼の色へ' : '夜の色へ';
 }
 try { apply(sessionStorage.getItem('remnet-diary-theme') === 'dark'); } catch { apply(false); }
 button.addEventListener('click', () => {
  const dark = document.documentElement.dataset.theme !== 'dark';
  apply(dark);
  try { sessionStorage.setItem('remnet-diary-theme', dark ? 'dark' : 'light'); } catch {}
 });
})();