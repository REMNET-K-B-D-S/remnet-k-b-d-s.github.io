
(() => {
 'use strict';
 const query=new URLSearchParams(location.search).get('q')||'';
 const q=query.trim().toLocaleLowerCase();
 const hits=q?(window.REMNET_PAGES||[]).filter(p=>p.id!=='search'&&(p.title+' '+p.text+' '+(p.tags||[]).join(' ')).toLocaleLowerCase().includes(q)):[];
 document.getElementById('query-state').textContent=q?('「'+query+'」：'+hits.length+'件'+(hits.length?'':'。別の言葉で探してください。')):'検索欄に言葉を入力して「検索」を押してください。';
 const results=document.getElementById('search-results');
 hits.forEach(p=>{
  const a=document.createElement('a');a.href=new URL(p.source||('pages/'+p.file),new URL('../',location.href)).href;a.dataset.page=p.id;
  const title=document.createElement('strong');title.textContent=p.title;
  const group=document.createElement('small');group.textContent=p.group;
  a.append(title,group);results.append(a);
 });
})();
