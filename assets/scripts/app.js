
(() => {
 'use strict';
 const pages=window.REMNET_PAGES||[], byId=new Map(pages.map(p=>[p.id,p]));
 const $=id=>document.getElementById(id), key='remnet-preferences-v1';
 const read=(name,fallback)=>{try{return JSON.parse(localStorage.getItem(key+name))??fallback}catch{return fallback}};
 const store=(name,value)=>{try{localStorage.setItem(key+name,JSON.stringify(value))}catch{}};
 let mode=read('mode','dark'),look=read('look',{size:16,grid:true,accents:{}}),active='home',opened=['home'],scrolls={},comparison=null;
 if(!['dark','light'].includes(mode))mode='dark';
 if(!look||typeof look!=='object')look={size:16,grid:true,accents:{}};
 look.size=Math.max(14,Math.min(24,Number(look.size)||16));look.accents=look.accents||{};
 look.textColors=look.textColors||{};look.headingColors=look.headingColors||{};look.readingStyle=['notebook','letter','graph','ledger'].includes(look.readingStyle)?look.readingStyle:'notebook';look.calloutStyle=['frame','margin','ledger'].includes(look.calloutStyle)?look.calloutStyle:'frame';
 const frame=$('reader'),tabs=$('tabs'),mobile=matchMedia('(max-width:740px)');
 let previousSettingsFocus=null;
 function send(target,data){target.contentWindow?.postMessage(data,'*')}
 function preferences(){return {type:'remnet-settings',mode,size:look.size,readingStyle:look.readingStyle||'notebook',calloutStyle:look.calloutStyle||'frame',grid:look.grid!==false,accent:look.accents[mode]||null,textColor:look.textColors[mode]||null,headingColor:look.headingColors[mode]||null}}
 function applyLook(){$('reading-style').value=look.readingStyle||'notebook';$('callout-style').value=look.calloutStyle||'frame';document.documentElement.dataset.theme=mode;document.documentElement.style.setProperty('--文字サイズ',look.size+'px');
  document.documentElement.style.removeProperty('--強調');if(/^#[\da-f]{6}$/i.test(look.accents[mode]||''))document.documentElement.style.setProperty('--強調',look.accents[mode]);
  for(const [name,value] of [['--文字',look.textColors[mode]],['--紫',look.headingColors[mode]]]){document.documentElement.style.removeProperty(name);if(/^#[\da-f]{6}$/i.test(value||''))document.documentElement.style.setProperty(name,value)}
  document.querySelectorAll('[data-mode]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.mode===mode)));
  $('font-size').value=look.size;$('size-state').textContent=look.size+'px';$('grid-choice').checked=look.grid!==false;
  $('accent-choice').value=look.accents[mode]||(mode==='dark'?'#acd5b9':'#b3d0c4');send(frame,preferences());if(comparison)send($('compare-reader'),preferences());store('mode',mode);store('look',look);
  $('text-choice').value=look.textColors[mode]||(mode==='dark'?'#eee8f4':'#e7e5ec');$('heading-choice').value=look.headingColors[mode]||(mode==='dark'?'#d4b6f2':'#c4a8e8');
 }
 function fileHref(p){return 'pages/'+encodeURIComponent(p.file)}
 const groups=["案内","日記","記録","記事","文献・問い","制作","つながり","連絡先"];
 const sidebarEntries={案内:['home','about','readme','site-policy'],日記:['diary'],記録:['notes'],記事:['articles'],'文献・問い':['library','questions','tags'],制作:['lab','works'],つながり:['links','shop'],連絡先:['contact']};
 let lastSearch='';
 let folderState=read('folders',{});if(!folderState||typeof folderState!=='object'||Array.isArray(folderState))folderState={};
 function folderButton(){const allClosed=[...$('tree').children].every(d=>!d.open),label=allClosed?'分類をすべて開く':'分類をすべて閉じる';$('fold-all').setAttribute('aria-label',label);$('fold-all').title=label;$('fold-all').classList.toggle('all-closed',allClosed)}
 function drawTree(){
  $('tree').replaceChildren();let count=0;
  groups.forEach(group=>{
   const members=(sidebarEntries[group]||[]).map(id=>byId.get(id)).filter(Boolean);
   if(!members.length)return;count+=members.length;
   const details=document.createElement('details');details.open=typeof folderState[group]==='boolean'?folderState[group]:group==='案内';details.addEventListener('toggle',()=>{folderState[group]=details.open;store('folders',folderState);folderButton()});
   const summary=document.createElement('summary');summary.textContent=group;details.append(summary);const list=document.createElement('div');list.className='children';
   members.forEach(p=>{const a=document.createElement('a');a.href='#'+p.id;a.dataset.page=p.id;a.textContent=({readme:'README.md','site-policy':'サイトポリシー_研究・取材に関する方針.md'})[p.id]||p.title;a.title=a.textContent;if(p.id===active)a.setAttribute('aria-current','page');list.append(a)});
   details.append(list);$('tree').append(details);
  });
  $('search-state').textContent='';folderButton();
 }
 function arrows(){$('tab-left').disabled=tabs.scrollLeft<=1;$('tab-right').disabled=tabs.scrollLeft+tabs.clientWidth>=tabs.scrollWidth-2}
 function drawTabs(focus=false){tabs.replaceChildren();opened.forEach(id=>{
  const p=byId.get(id),slot=document.createElement('div');slot.className='tab-slot';slot.setAttribute('role','presentation');window.REMNET_TAB_DRAG.bind(slot,id,{order:()=>opened,move:moveTab});
  const b=document.createElement('button');b.className='tab';b.id='tab-'+id;b.textContent=p.title;b.dataset.page=id;b.setAttribute('role','tab');b.setAttribute('aria-selected',String(id===active));b.setAttribute('aria-controls','main-panel');b.tabIndex=id===active?0:-1;
  b.addEventListener('keydown',e=>{if(e.ctrlKey&&e.shiftKey)return;let i=opened.indexOf(id);if(e.key==='ArrowRight')i=(i+1)%opened.length;else if(e.key==='ArrowLeft')i=(i+opened.length-1)%opened.length;else if(e.key==='Home')i=0;else if(e.key==='End')i=opened.length-1;else if(e.key==='Delete'&&id!=='home'){e.preventDefault();closeTab(id);return}else return;e.preventDefault();const next=$('tab-'+opened[i]);next.focus();next.scrollIntoView({block:'nearest',inline:'nearest'})});slot.append(b);
  if(id!=='home'){const x=document.createElement('button');x.className='tab-close';x.textContent='×';x.setAttribute('aria-label',p.title+'のタブを閉じる');x.addEventListener('click',()=>closeTab(id));slot.append(x)}tabs.append(slot);
 });$('main-panel').setAttribute('aria-labelledby','tab-'+active);const b=$('tab-'+active);b.scrollIntoView({block:'nearest',inline:'nearest'});if(focus)b.focus({preventScroll:true});arrows();$('page-count').textContent=opened.length+'ページを開いています';}
 function moveTab(id,target,after,focus){
  if(id===target||!opened.includes(id)||!opened.includes(target))return;
  const next=opened.filter(p=>p!==id),index=next.indexOf(target)+(after?1:0);
  next.splice(index,0,id);opened=next;drawTabs(false);
  if(focus)$('tab-'+id)?.focus({preventScroll:true});
  $('announce').textContent=byId.get(id).title+'のタブを'+(opened.indexOf(id)+1)+'番目に移動しました。';
 }
 function syncSelection(reveal=true){document.querySelectorAll('#tree a[data-page]').forEach(a=>{if(a.dataset.page===active){a.setAttribute('aria-current','page');if(reveal)a.closest('details').open=true}else a.removeAttribute('aria-current')});}
 function navigate(id,options={}){if(id==='search'){if(typeof options.query==='string')lastSearch=options.query;options.query=lastSearch;}if(!byId.has(id))return;if(!opened.includes(id))opened.push(id);const changed=active!==id;active=id;
  if(changed||options.force||options.query){$('outline-links').replaceChildren();frame.src=fileHref(byId.get(id))+(options.query||'')+(options.anchor?'#'+encodeURIComponent(options.anchor):'');}
  else if(options.anchor)send(frame,{type:'remnet-jump',id:options.anchor});
  frame.title=byId.get(id).title+'の本文';$('where').textContent=byId.get(id).group+' ／ '+byId.get(id).title;document.title=byId.get(id).title+' — REMNET_K_B_D_S';
  if(!options.fromHistory)history.pushState(null,'','#'+id);drawTabs(options.focus);syncSelection(!options.fromHistory);if(mobile.matches&&!$('sidebar').hidden){setFiles(false);$('file-toggle').focus({preventScroll:true})}$('announce').textContent=byId.get(id).title+'を開きました。';
 }
 function closeTab(id){if(id==='home')return;const i=opened.indexOf(id);opened=opened.filter(p=>p!==id);if(active===id)navigate(opened[Math.max(0,i-1)],{focus:true});else drawTabs(true)}
 function setFiles(show){$('sidebar').hidden=!show;$('desk').classList.toggle('closed',!show);for(const id of ['file-toggle','file-left']){$(id).setAttribute('aria-expanded',String(show));$(id).title=show?'ファイル一覧を閉じる':'ファイル一覧を開く'}if(mobile.matches&&!show)window.scrollTo(0,0);arrows()}
 function setSettings(show){$('settings').hidden=!show;$('look-toggle').setAttribute('aria-expanded',String(show));if(show){previousSettingsFocus=document.activeElement;$('font-size').focus()}else previousSettingsFocus?.focus()}
 function outline(headings){$('outline-links').replaceChildren();headings.forEach(h=>{const b=document.createElement('button');b.textContent=h.text;b.dataset.heading=h.id;b.dataset.level=String(h.level||1);b.addEventListener('click',()=>{send(frame,{type:'remnet-jump',id:h.id});if(innerWidth<=1150){$('outline').classList.remove('shown');$('outline-toggle').setAttribute('aria-expanded','false')}});$('outline-links').append(b)});}
 function setCompare(show){$('compare-panel').hidden=!show;$('readers').classList.toggle('comparing',show);$('compare-toggle').setAttribute('aria-expanded',String(show));if(show){$('compare-select').replaceChildren();pages.forEach(p=>{const o=document.createElement('option');o.value=p.id;o.textContent=p.title;$('compare-select').append(o)});comparison=opened.find(id=>id!==active)||'about';$('compare-select').value=comparison;$('compare-reader').src=fileHref(byId.get(comparison));$('compare-reader').title=byId.get(comparison).title+'の比較用本文'}else{comparison=null;$('compare-reader').removeAttribute('src');$('compare-toggle').focus()}}
 document.addEventListener('click',e=>{const b=e.target.closest('[data-page]');if(!b)return;e.preventDefault();if(b.getAttribute('role')==='tab'&&window.REMNET_TAB_DRAG.suppressClick)return;navigate(b.dataset.page,{focus:b.getAttribute('role')==='tab'});});
 // ページ識別用のハッシュを変えず、読み進める位置だけを本文へ移す。
 document.querySelector('.skip').addEventListener('click',e=>{
  e.preventDefault();$('workspace').focus({preventScroll:true});
  $('workspace').scrollIntoView({block:'nearest',inline:'nearest'});
 });
 $('fold-all').onclick=()=>{const details=[...$('tree').children],show=details.every(d=>!d.open);details.forEach(d=>{d.open=show;folderState[d.children[0].textContent]=show});store('folders',folderState);folderButton()};
 tabs.addEventListener('dragover',e=>{if(!window.REMNET_TAB_DRAG.active)return;e.preventDefault();const r=tabs.getBoundingClientRect();if(e.clientX<r.left+30)tabs.scrollBy({left:-24});else if(e.clientX>r.right-30)tabs.scrollBy({left:24})});
 $('file-toggle').onclick=()=>setFiles($('sidebar').hidden);$('file-left').onclick=()=>setFiles($('sidebar').hidden);$('search-form').addEventListener('submit',e=>{e.preventDefault();navigate('search',{query:'?q='+encodeURIComponent($('search').value.trim())})});
 $('tab-left').onclick=()=>tabs.scrollBy({left:-230});$('tab-right').onclick=()=>tabs.scrollBy({left:230});tabs.addEventListener('scroll',arrows,{passive:true});
 tabs.addEventListener('wheel',e=>{if(e.ctrlKey||tabs.scrollWidth<=tabs.clientWidth)return;e.preventDefault();const delta=Math.abs(e.deltaX)>Math.abs(e.deltaY)?e.deltaX:e.deltaY;tabs.scrollLeft+=delta*(e.deltaMode===1?20:e.deltaMode===2?tabs.clientWidth:1)},{passive:false});
 $('outline-toggle').onclick=()=>{const show=!$('outline').classList.contains('shown');$('outline').classList.toggle('shown',show);$('outline-toggle').setAttribute('aria-expanded',String(show))};
 $('compare-toggle').onclick=()=>setCompare(!comparison);$('compare-close').onclick=()=>setCompare(false);$('compare-select').onchange=e=>{comparison=e.target.value;$('compare-reader').src=fileHref(byId.get(comparison));$('compare-reader').title=byId.get(comparison).title+'の比較用本文'};
 document.querySelectorAll('[data-mode]').forEach(b=>b.onclick=()=>{mode=b.dataset.mode;applyLook()});$('look-toggle').onclick=()=>setSettings($('settings').hidden);$('look-close').onclick=()=>setSettings(false);
 $('font-size').oninput=e=>{look.size=Number(e.target.value);applyLook()};$('grid-choice').onchange=e=>{look.grid=e.target.checked;applyLook()};$('accent-choice').oninput=e=>{look.accents[mode]=e.target.value;applyLook()};$('text-choice').oninput=e=>{look.textColors[mode]=e.target.value;applyLook()};$('heading-choice').oninput=e=>{look.headingColors[mode]=e.target.value;applyLook()};$('look-reset').onclick=()=>{look={size:16,grid:true,accents:{},textColors:{},headingColors:{}};applyLook()};
 document.addEventListener('keydown',e=>{if(e.key==='Escape'){if(!$('settings').hidden)setSettings(false);else if($('outline').classList.contains('shown')){$('outline').classList.remove('shown');$('outline-toggle').setAttribute('aria-expanded','false');$('outline-toggle').focus()}else if(mobile.matches&&!$('sidebar').hidden){setFiles(false);$('file-toggle').focus()}}});
 window.addEventListener('message',e=>{const main=e.source===frame.contentWindow,other=e.source===$('compare-reader').contentWindow;if((!main&&!other)||!e.data)return;const d=e.data;
  if(d.type==='remnet-ready'){send(main?frame:$('compare-reader'),preferences());if(main){outline(d.headings||[]);send(frame,{type:'remnet-restore',top:scrolls[active]||0})}}
  if(d.type==='remnet-open'&&byId.has(d.id)){const query=typeof d.query==='string'&&/^\?tag=[a-z-]+$/.test(d.query)?d.query:'';if(other){comparison=d.id;$('compare-select').value=d.id;$('compare-reader').src=fileHref(byId.get(d.id))+query}else navigate(d.id,{anchor:d.anchor,query,focus:false})}
  if(d.type==='remnet-scroll'&&main){scrolls[d.page]=d.top;document.querySelectorAll('#outline-links button').forEach(b=>b.classList.toggle('active',b.dataset.heading===d.heading))}
 });
 frame.addEventListener('load',()=>send(frame,preferences()));$('compare-reader').addEventListener('load',()=>send($('compare-reader'),preferences()));
 window.addEventListener('popstate',()=>navigate(location.hash.slice(1)||'home',{fromHistory:true}));new ResizeObserver(arrows).observe(tabs);
 new ResizeObserver(entries=>document.documentElement.style.setProperty('--上部高さ',entries[0].target.getBoundingClientRect().height+'px')).observe(document.querySelector('.topbar'));
 $('reading-style').onchange=e=>{look.readingStyle=e.target.value;applyLook()};$('callout-style').onchange=e=>{look.calloutStyle=e.target.value;applyLook()};drawTree();setFiles(!mobile.matches);applyLook();navigate(byId.has(location.hash.slice(1))?location.hash.slice(1):'home',{force:true,fromHistory:true});
})();



