
(() => {
 'use strict';
 const $=id=>document.getElementById(id),desk=$('desk'),readers=$('readers');
 const desktop=matchMedia('(min-width:1151px)'),wide=matchMedia('(min-width:741px)');
 const storageKey='remnet-preferences-v1-panel-widths';
 const defaults={left:260,right:200},minimum={left:200,right:160};
 let wanted={...defaults},drag=null;
 try{const saved=JSON.parse(localStorage.getItem(storageKey));for(const side of ['left','right'])if(Number.isFinite(saved?.[side]))wanted[side]=Math.max(minimum[side],Math.min(640,saved[side]));}catch{}
 const handles={};
 const save=()=>{try{localStorage.setItem(storageKey,JSON.stringify(wanted))}catch{}};
 const clamp=(value,min,max)=>Math.max(min,Math.min(value,Math.max(min,max)));
 function limits(side){
  const total=desk.clientWidth,visibleLeft=!desk.classList.contains('closed');
  const visibleRight=desktop.matches&&!readers.classList.contains('outline-closed')&&!readers.classList.contains('comparing');
  if(side==='left')return Math.min(640,total-(visibleRight?minimum.right+8:0)-(readers.classList.contains('comparing')?400:360));
  return Math.min(640,total-(visibleLeft?minimum.left:0)-368);
 }
 function apply(){
  // 優先的に中央360pxを確保し、ウィンドウ縮小時だけ保存値より狭くする。
  const total=desk.clientWidth,visibleRight=desktop.matches&&!readers.classList.contains('outline-closed')&&!readers.classList.contains('comparing');
  let left=clamp(wanted.left,minimum.left,limits('left'));
  const remaining=total-(desk.classList.contains('closed')?0:left)-368;
  let right=clamp(wanted.right,minimum.right,remaining);
  if(visibleRight)left=clamp(left,minimum.left,total-right-368);
  document.documentElement.style.setProperty('--left-width',left+'px');
  document.documentElement.style.setProperty('--right-width',right+'px');
  for(const side of ['left','right']){
   const h=handles[side];if(!h)continue;
   h.setAttribute('aria-valuenow',String(Math.round(side==='left'?left:right)));
   h.setAttribute('aria-valuemax',String(Math.max(minimum[side],Math.floor(limits(side)))));
  }
 }
 function stop(){
  if(!drag)return;const {handle,pointer}=drag;drag=null;
  handle.classList.remove('dragging');document.body.classList.remove('panel-resizing');
  if(handle.hasPointerCapture(pointer))handle.releasePointerCapture(pointer);
  save();
 }
 function create(side,parent,before){
  const h=document.createElement('div');handles[side]=h;
  h.className='panel-splitter '+side+'-splitter';h.tabIndex=0;h.setAttribute('role','separator');h.setAttribute('aria-orientation','vertical');
  h.setAttribute('aria-label',side==='left'?'ファイル一覧の幅':'本文の見出し一覧の幅');
  h.setAttribute('aria-controls',side==='left'?'sidebar':'outline');h.setAttribute('aria-valuemin',String(minimum[side]));
  h.title='ドラッグで幅を変更・ダブルクリックで初期幅へ（矢印キーでも調整）';
  parent.insertBefore(h,before);
  h.addEventListener('pointerdown',e=>{
   if(e.button!==0||!wide.matches||(side==='right'&&!desktop.matches))return;
   e.preventDefault();stop();
   drag={handle:h,pointer:e.pointerId,side,x:e.clientX,start:side==='left'?$('sidebar').getBoundingClientRect().width:$('outline').getBoundingClientRect().width};
   h.setPointerCapture(e.pointerId);h.classList.add('dragging');document.body.classList.add('panel-resizing');
  });
  h.addEventListener('pointermove',e=>{
   if(!drag||drag.handle!==h||drag.pointer!==e.pointerId)return;
   const delta=(e.clientX-drag.x)*(side==='left'?1:-1);
   wanted[side]=clamp(drag.start+delta,minimum[side],limits(side));apply();
  });
  h.addEventListener('pointerup',stop);h.addEventListener('pointercancel',stop);h.addEventListener('lostpointercapture',stop);
  h.addEventListener('dblclick',()=>{wanted[side]=defaults[side];apply();save()});
  h.addEventListener('keydown',e=>{
   if(!['ArrowLeft','ArrowRight','Home'].includes(e.key))return;e.preventDefault();
   wanted[side]=e.key==='Home'?defaults[side]:clamp(wanted[side]+(e.key==='ArrowRight'?1:-1)*(side==='left'?1:-1)*(e.shiftKey?40:10),minimum[side],limits(side));
   apply();save();
  });
 }
 create('left',$('workspace'),$('workspace').firstChild);create('right',readers,$('outline'));
 const originalToggle=$('outline-toggle').onclick;
 $('outline-toggle').onclick=()=>{
  if(!desktop.matches){originalToggle();return}
  const closed=readers.classList.toggle('outline-closed');
  $('outline-toggle').setAttribute('aria-expanded',String(!closed));apply();
 };
 function sync(){
  stop();if(desktop.matches){$('outline').classList.remove('shown');$('outline-toggle').setAttribute('aria-expanded',String(!readers.classList.contains('outline-closed')&&!readers.classList.contains('comparing')))}
  else $('outline-toggle').setAttribute('aria-expanded',String($('outline').classList.contains('shown')));
  apply();
 }
 new MutationObserver(apply).observe(desk,{attributes:true,attributeFilter:['class']});
 new MutationObserver(()=>{apply();if(desktop.matches)$('outline-toggle').setAttribute('aria-expanded',String(!readers.classList.contains('outline-closed')&&!readers.classList.contains('comparing')))}).observe(readers,{attributes:true,attributeFilter:['class']});
 new ResizeObserver(apply).observe(desk);
 addEventListener('resize',apply);addEventListener('blur',stop);wide.addEventListener('change',sync);desktop.addEventListener('change',sync);
 sync();
})();
