(() => {
 const root=document.documentElement;
 const buttons=[...document.querySelectorAll('[data-mode]')];
 const links=[...document.querySelectorAll('a[href]')].filter(a=>{
  const raw=a.getAttribute('href');
  return raw && !raw.startsWith('#') && !/^[a-z][a-z0-9+.-]*:/i.test(raw) && !raw.startsWith('//') && /\.html?(?:[?#]|$)/i.test(raw);
 });
 links.forEach(a=>a.dataset.baseHref=a.getAttribute('href'));
 function applyTheme(value){
  const mode=value==='dark'?'dark':'light';
  root.dataset.theme=mode;
  buttons.forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.mode===mode)));
  links.forEach(a=>{try{const url=new URL(a.dataset.baseHref,location.href);url.searchParams.set('theme',mode);a.setAttribute('href',url.href);}catch{}});
  try{sessionStorage.setItem('remnet-top-theme',mode);sessionStorage.setItem('remnet-diary-theme',mode);}catch{}
 }
 let initial=new URLSearchParams(location.search).get('theme');
 if(initial!=='dark'&&initial!=='light'){try{initial=sessionStorage.getItem('remnet-top-theme');}catch{}}
 if(initial!=='dark'&&initial!=='light'){initial=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}
 applyTheme(initial);
 buttons.forEach(b=>b.addEventListener('click',()=>applyTheme(b.dataset.mode)));
})();
