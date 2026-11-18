
(() => {
 'use strict';
 let source=null,suppressUntil=0;
 function clear(all=true){
  document.querySelectorAll('.tab-slot').forEach(s=>{s.classList.remove('drop-before','drop-after');if(all)s.classList.remove('dragging')});
 }
 function finish(){if(source)suppressUntil=Date.now()+300;source=null;clear()}
 function bind(slot,id,hooks){
  slot.draggable=matchMedia('(hover:hover) and (pointer:fine)').matches;
  slot.addEventListener('dragstart',e=>{
   if(!slot.draggable||e.target.closest('.tab-close')){e.preventDefault();return}
   source=id;e.dataTransfer.effectAllowed='move';e.dataTransfer.setData('text/plain',id);
   slot.classList.add('dragging');
  });
  slot.addEventListener('dragover',e=>{
   if(!source||source===id)return;e.preventDefault();e.dataTransfer.dropEffect='move';
   clear(false);const bounds=slot.getBoundingClientRect();
   slot.classList.add(e.clientX<bounds.left+bounds.width/2?'drop-before':'drop-after');
  });
  slot.addEventListener('dragleave',()=>slot.classList.remove('drop-before','drop-after'));
  slot.addEventListener('drop',e=>{
   if(!source)return;e.preventDefault();e.stopPropagation();
   const from=source,bounds=slot.getBoundingClientRect(),after=e.clientX>=bounds.left+bounds.width/2;
   finish();hooks.move(from,id,after,false);
  });
  slot.addEventListener('dragend',finish);
  slot.addEventListener('keydown',e=>{
   if(!e.ctrlKey||!e.shiftKey||!['ArrowLeft','ArrowRight'].includes(e.key))return;
   e.preventDefault();const order=hooks.order(),i=order.indexOf(id),direction=e.key==='ArrowRight'?1:-1;
   if(i+direction<0||i+direction>=order.length)return;
   hooks.move(id,order[i+direction],direction>0,true);
  });
 }
 window.REMNET_TAB_DRAG={bind,get active(){return source!==null},get suppressClick(){return Date.now()<suppressUntil}};
})();
