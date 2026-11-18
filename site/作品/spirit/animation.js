const timeline=gsap.timeline({paused:true});window.__timelines={main:timeline};
const state={pull:0},ctx=document.querySelector('.motion').getContext('2d'),photo=document.querySelector('#original');
const thumb=document.createElement('canvas');thumb.width=1672;thumb.height=941;const tc=thumb.getContext('2d');
const ring=document.createElement('canvas');ring.width=1672;ring.height=941;const rc=ring.getContext('2d');
const pivot={x:225,y:790},tip={x:392,y:681},minAngle=-15*Math.PI/180,maxAngle=32*Math.PI/180;
function centerY(a){return pivot.y+(tip.x-pivot.x)*Math.sin(a)+(tip.y-pivot.y)*Math.cos(a)}
const startY=centerY(minAngle),endY=centerY(maxAngle);
function prepare(){
tc.clearRect(0,0,1672,941);tc.save();tc.beginPath();tc.moveTo(210,770);tc.bezierCurveTo(217,740,245,718,278,710);tc.bezierCurveTo(312,706,349,682,375,666);tc.bezierCurveTo(394,660,416,659,425,671);tc.bezierCurveTo(431,686,420,704,397,721);tc.bezierCurveTo(366,745,326,772,285,803);tc.bezierCurveTo(250,825,226,832,219,815);tc.bezierCurveTo(208,798,205,783,210,770);tc.closePath();tc.clip();tc.drawImage(photo,0,0);tc.restore();
rc.clearRect(0,0,1672,941);rc.save();rc.beginPath();rc.ellipse(391,681,42,41,0,0,Math.PI*2);rc.ellipse(391,681,34,33,0,0,Math.PI*2,true);rc.clip('evenodd');rc.drawImage(photo,0,0);rc.restore();draw();}
function draw(){if(!photo.complete||!photo.naturalWidth)return;const p=state.pull,a=minAngle+(maxAngle-minAngle)*p,cy=centerY(a),stroke=cy-startY;ctx.clearRect(0,0,1672,941);
ctx.drawImage(photo,325,498,113,79,325,498,113,79);
const level=82+24*p;ctx.save();ctx.beginPath();ctx.rect(336,level,116,266-level);ctx.clip();ctx.drawImage(photo,0,0);ctx.restore();ctx.fillStyle='#c8e7d1';ctx.fillRect(339,level,110,1.4);
ctx.drawImage(photo,384,577,14,67,384,574,14,Math.max(1,cy-44-574));
const vx=tip.x-pivot.x,vy=tip.y-pivot.y,sx=vx/(vx*Math.cos(a)-vy*Math.sin(a));
ctx.save();ctx.translate(pivot.x,pivot.y);ctx.scale(sx,1);ctx.rotate(a);ctx.translate(-pivot.x,-pivot.y);ctx.drawImage(thumb,0,0);ctx.restore();
ctx.drawImage(ring,0,cy-tip.y);
const g=ctx.createLinearGradient(378,0,405,0);g.addColorStop(0,'#a9ceb5');g.addColorStop(.5,'#c8e7d1');g.addColorStop(1,'#b5d9bf');ctx.fillStyle=g;ctx.fillRect(379,399,24,stroke);ctx.fillStyle='#53585b';ctx.fillRect(378,398+stroke,26,4);
window.motionValues={pull:p,angle:a*180/Math.PI,bottleLevel:level,syringeHeight:stroke,ringY:cy};}
if(photo.complete&&photo.naturalWidth)prepare();else photo.addEventListener('load',prepare);
timeline.to(state,{pull:1,duration:3.5,ease:'sine.inOut',onUpdate:draw},.25);
let t=.45;const chars=[...document.querySelectorAll('.char')];chars.forEach((el,i)=>{timeline.set(el,{opacity:1},t);const key=[...document.querySelectorAll('.key')].find(k=>k.dataset.key===el.textContent.toUpperCase());if(key){timeline.to(key,{y:3,opacity:1,filter:'brightness(.8)',duration:.03},t).to(key,{y:0,opacity:0,filter:'brightness(1)',duration:.045},t+.04)}t+=.085;if(i===27)t+=.2;});
timeline.set('.cursor',{opacity:1},t).to('.cursor',{opacity:0,duration:.01,repeat:3,yoyo:true,repeatDelay:.32},t+.25);timeline.to({}, {duration:.1},6.9);
window.spiritTimeline=timeline;window.spiritInfo={duration:7,characters:chars.length,typingEnd:t,drawStart:.25,drawEnd:3.75,typingStart:.45};
if(document.body.classList.contains('viewer')){const fit=document.querySelector('.fit'),stage=document.querySelector('.stage');function size(){stage.style.transform='scale('+fit.clientWidth/1600+')'}window.addEventListener('resize',size);size();document.querySelector('#replay').onclick=()=>timeline.restart();window.addEventListener('load',()=>{if(matchMedia('(prefers-reduced-motion: reduce)').matches)timeline.seek(7);else timeline.play()});}
