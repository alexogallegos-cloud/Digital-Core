# _brain_context.py
# Sección visual "¿Qué es el Digital Brain?" — adaptada para Liverpool retail.
# Paleta: RUN = sky #87C3D3, CHANGE = cerise #E00198, ONTO = rose #DA7AB0.
# NO editar este archivo manualmente — generado para cableado en build-portal.py.

BRAIN_CSS = """
/* ── Section headings (brain) ────────────────────────────────────────────── */
.section-eyebrow{font-size:10px;font-weight:700;letter-spacing:.18em;color:#E00198;
                 text-transform:uppercase;margin-bottom:10px}
.section-title{font-size:28px;font-weight:800;margin-bottom:8px;letter-spacing:-.01em;color:#fff}
.section-sub{font-size:14px;color:#c4a8bc;max-width:520px;line-height:1.6;margin-bottom:40px}

/* ── Brain context (embedded) ─────────────────────────────────────────────── */
.brain-lead{display:grid;grid-template-columns:1.1fr 1fr;gap:44px;align-items:start;margin-top:30px}
.lead-copy{font-size:14px;color:#c4a8bc;line-height:1.75}
.lead-copy strong{color:#fff;font-weight:700}
.brain-points{display:flex;flex-direction:column;gap:16px}
.brain-point{display:flex;gap:13px;align-items:flex-start}
.bp-dot{width:9px;height:9px;border-radius:50%;margin-top:5px;flex-shrink:0}
.bp-run{background:#87C3D3;box-shadow:0 0 8px rgba(135,195,211,.7)}
.bp-change{background:#E00198;box-shadow:0 0 8px rgba(224,1,152,.7)}
.bp-onto{background:#DA7AB0;box-shadow:0 0 8px rgba(218,122,176,.7)}
.bp-title{font-size:13px;font-weight:700;color:#fff}
.bp-desc{font-size:12px;color:#c4a8bc;line-height:1.55;margin-top:3px}
.brain-frame-wrap{margin-top:40px;border-radius:16px;overflow:hidden;
  border:1px solid rgba(135,195,211,.14);background:#0d0408;
  box-shadow:0 0 60px rgba(80,0,60,.22)}
#brainStage{position:relative;width:100%;height:740px;background:#0d0408;overflow:hidden}
#brainStage canvas{position:absolute;top:0;left:0;width:100%;height:100%;display:block}
#brainC{z-index:1}#brainOv{z-index:2;pointer-events:none}
#brainLoading{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);
  font-size:13px;letter-spacing:.08em;color:rgba(135,195,211,.8);z-index:3;text-align:center}
@media(max-width:880px){.brain-lead{grid-template-columns:1fr;gap:28px}#brainStage{height:560px}}
"""

BRAIN_HTML = """
<script src="three.min.js"></script>
<section class="section brain-context" id="brain">
  <div class="section-eyebrow">El concepto</div>
  <div class="section-title">&iquest;Qu&eacute; es el Digital Brain?</div>
  <p class="section-sub">Antes de las vistas, el modelo mental: una base de conocimiento sem&aacute;ntica del negocio retail de Liverpool.</p>
  <div class="brain-lead">
    <div class="lead-copy">
      El <strong>Digital Brain de Liverpool</strong> no es un sistema m&aacute;s: es la <strong>memoria y el razonamiento</strong> del landscape tecnol&oacute;gico de El Puerto de Liverpool. Captura el estado actual verificado &mdash; lo que opera hoy &mdash; y razona sobre la transformaci&oacute;n &mdash; lo que debe cambiar &mdash; todo bajo un vocabulario com&uacute;n.
      <br><br>
      La gr&aacute;fica muestra sus <strong>componentes de conocimiento</strong> repartidos en dos hemisferios, atravesados por dos ontolog&iacute;as. El brillo de cada nodo indica su madurez: poblado, parcial o pendiente.
    </div>
    <div class="brain-points">
      <div class="brain-point"><div class="bp-dot bp-run"></div>
        <div><div class="bp-title">RUN &mdash; Memoria del presente (AS-IS)</div>
        <div class="bp-desc">Sistemas, reglas, capacidades, vocabulario, interfaces y dependencias que describen c&oacute;mo opera Liverpool hoy.</div></div></div>
      <div class="brain-point"><div class="bp-dot bp-change"></div>
        <div><div class="bp-title">CHANGE &mdash; Razonamiento de transformaci&oacute;n (TO-BE)</div>
        <div class="bp-desc">Complejidad de migraci&oacute;n, decisi&oacute;n 7R, Simplification S/4HANA, agenda commercetools y riesgos que gu&iacute;an la transformaci&oacute;n.</div></div></div>
      <div class="brain-point"><div class="bp-dot bp-onto"></div>
        <div><div class="bp-title">Dos ontolog&iacute;as transversales</div>
        <div class="bp-desc">El RTB de Retail (el QU&Eacute; del negocio) y TOGAF/ITOM (el C&Oacute;MO tecnol&oacute;gico) aplican a ambos hemisferios.</div></div></div>
    </div>
  </div>
  <div class="brain-frame-wrap">
    <div id="brainStage">
      <div id="brainLoading">Cargando cerebro digital&hellip;</div>
      <canvas id="brainC"></canvas>
      <canvas id="brainOv"></canvas>
    </div>
  </div>
</section>
<script>
(function(){
var stage=document.getElementById('brainStage');
if(!stage||!window.THREE)return;
var oc=document.getElementById('brainOv').getContext('2d');
var ov=document.getElementById('brainOv');
var loadingEl=document.getElementById('brainLoading');
function SW(){return stage.clientWidth||1;}
function SH(){return stage.clientHeight||1;}

var VERT=`precision highp float;
varying vec3 vWP;varying vec3 vN;
void main(){vec4 wp=modelMatrix*vec4(position,1.0);vWP=wp.xyz;
  vN=normalize(normalMatrix*normal);gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}`;
var FRAG=`precision highp float;
uniform float uTime;uniform vec3 uCam;uniform float uScale;
varying vec3 vWP;varying vec3 vN;
float h3(vec3 p){p=fract(p*vec3(443.9,397.3,491.2));p+=dot(p.zxy,p.yxz+19.19);return fract(p.x*p.y*p.z);}
float vn(vec3 p){vec3 i=floor(p),f=fract(p),u=f*f*(3.0-2.0*f);
  float a=h3(i),b=h3(i+vec3(1,0,0)),c=h3(i+vec3(0,1,0)),d=h3(i+vec3(1,1,0));
  float e=h3(i+vec3(0,0,1)),ff=h3(i+vec3(1,0,1)),g=h3(i+vec3(0,1,1)),hh=h3(i+vec3(1,1,1));
  return mix(mix(mix(a,b,u.x),mix(c,d,u.x),u.y),mix(mix(e,ff,u.x),mix(g,hh,u.x),u.y),u.z);}
float fbm(vec3 p){float v=0.0,a=0.55;
  for(int i=0;i<4;i++){v+=a*(vn(p)-0.5);p=p*2.1+vec3(17.3,8.1,12.4);a*=0.48;}return v;}
float cl(float n,float fr,float pw){return pow(abs(cos(n*3.14159*fr)),pw);}
void main(){vec3 N=normalize(vN);vec3 V=normalize(uCam-vWP);
  float chg=step(0.0,vWP.x);
  vec3 cRUN=vec3(0.53,0.76,0.83);vec3 cCHG=vec3(0.878,0.004,0.596);vec3 col=mix(cCHG,cRUN,chg);
  vec3 sp=vWP*uScale;
  float n1=fbm(sp*2.5);float t1=cl(n1,7.0,14.0);
  float n2=fbm(sp*5.5+vec3(11.0,5.0,8.3));float t2=cl(n2,14.0,20.0)*0.55;
  float n3=fbm(sp*11.0+vec3(33.0,22.0,17.5));float t3=cl(n3,24.0,28.0)*0.28;
  float tr=clamp(t1+t2+t3,0.0,1.0);
  float fr=pow(1.0-max(dot(N,V),0.0),2.5);
  float hot=0.0;vec3 wn=normalize(vWP);
  hot+=smoothstep(0.14,0.0,distance(wn,normalize(vec3(0.6,0.4,0.7))))*(0.5+0.5*sin(uTime*2.1));
  hot+=smoothstep(0.12,0.0,distance(wn,normalize(vec3(-0.5,0.2,0.8))))*(0.5+0.5*sin(uTime*1.7+1.3));
  hot+=smoothstep(0.10,0.0,distance(wn,normalize(vec3(0.3,-0.3,0.9))))*(0.5+0.5*sin(uTime*2.6+2.5));
  vec3 out_col=col*0.05+col*tr*1.8+col*fr*0.55+vec3(0.85,0.95,1.0)*hot*3.0;
  gl_FragColor=vec4(out_col,1.0);}`;

var renderer=new THREE.WebGLRenderer({canvas:document.getElementById('brainC'),antialias:true,alpha:true});
renderer.setPixelRatio(Math.min(devicePixelRatio,2));renderer.setSize(SW(),SH());renderer.setClearColor(0x000000,0);
var scene=new THREE.Scene();
var camera=new THREE.PerspectiveCamera(42,SW()/SH(),.1,500);
camera.position.set(0,1.5,9.5);camera.lookAt(0,0,0);
var neonMat=new THREE.ShaderMaterial({vertexShader:VERT,fragmentShader:FRAG,side:THREE.DoubleSide,
  uniforms:{uCam:{value:camera.position},uTime:{value:0},uScale:{value:1.0}}});
function glowMat(hex,op){return new THREE.MeshBasicMaterial({color:new THREE.Color(hex),side:THREE.BackSide,
  transparent:true,opacity:op,blending:THREE.AdditiveBlending,depthWrite:false});}
var GLOWS=[{m:glowMat(0xE00198,.06),s:1.04},{m:glowMat(0x87C3D3,.04),s:1.09},{m:glowMat(0x4a006a,.02),s:1.16}];
var brainRoot=null;
function u32(dv,off){return dv.getUint32(off,true);}
function accToArray(gltf,buf,bs,ai){var acc=gltf.accessors[ai],bv=gltf.bufferViews[acc.bufferView];
  var dims={SCALAR:1,VEC2:2,VEC3:3,VEC4:4}[acc.type]||1;var off2=bs+(bv.byteOffset||0)+(acc.byteOffset||0);
  var bEl=acc.componentType===5126?4:acc.componentType===5125?4:2;var sl=buf.slice(off2,off2+acc.count*dims*bEl);
  if(acc.componentType===5126)return new Float32Array(sl);if(acc.componentType===5125)return new Uint32Array(sl);
  return new Uint16Array(sl);}
function parseGLB(buf){var dv=new DataView(buf);if(u32(dv,0)!==0x46546C67)throw new Error('No es GLB');
    var jl=u32(dv,12);var gltf=JSON.parse(new TextDecoder().decode(new Uint8Array(buf,20,jl)));var bs=20+jl+8;
    var meshes=[];(gltf.meshes||[]).forEach(function(m){(m.primitives||[]).forEach(function(p){
      var g=new THREE.BufferGeometry();
      if(p.attributes.POSITION!=null)g.setAttribute('position',new THREE.BufferAttribute(accToArray(gltf,buf,bs,p.attributes.POSITION),3));
      if(p.attributes.NORMAL!=null)g.setAttribute('normal',new THREE.BufferAttribute(accToArray(gltf,buf,bs,p.attributes.NORMAL),3));
      if(p.indices!=null)g.setIndex(new THREE.BufferAttribute(accToArray(gltf,buf,bs,p.indices),1));
      if(!g.attributes.normal)g.computeVertexNormals();meshes.push(g);});});
    if(!meshes.length)throw new Error('Sin geometria');return meshes;}
function b64buf(b64){var bin=atob(b64),n=bin.length,a=new Uint8Array(n);for(var i=0;i<n;i++)a[i]=bin.charCodeAt(i);return a.buffer;}
var GLB_B64="__BRAIN_GLB_B64__";
function loadGLB(ok,err){
  if(GLB_B64&&GLB_B64.length>32){try{ok(parseGLB(b64buf(GLB_B64)));}catch(e){err(e);}return;}
  fetch('brain.glb').then(function(r){if(!r.ok)throw new Error('HTTP '+r.status);return r.arrayBuffer();}).then(function(buf){try{ok(parseGLB(buf));}catch(e){err(e);}}).catch(err);}
loadGLB(function(geos){loadingEl.style.display='none';
  var group=new THREE.Group();
  geos.forEach(function(geo){var m=new THREE.Mesh(geo,neonMat);
    GLOWS.forEach(function(g){var sh=new THREE.Mesh(geo,g.m);sh.scale.setScalar(g.s);m.add(sh);});group.add(m);});
  var box=new THREE.Box3().setFromObject(group);var sz=new THREE.Vector3();box.getSize(sz);
  var maxD=Math.max(sz.x,sz.y,sz.z,.001);var sf=2.5/maxD;group.scale.setScalar(sf);
  box.setFromObject(group);var ctr=new THREE.Vector3();box.getCenter(ctr);group.position.sub(ctr);
  neonMat.uniforms.uScale.value=1.0/(maxD*sf*.5);
  group.rotation.x=0;group.rotation.y=0;group.rotation.z=-Math.PI/2;brainRoot=group;scene.add(group);
},function(e){loadingEl.textContent='Error: '+(e&&e.message?e.message:String(e));loadingEl.style.animation='none';});
function animateBrain(){requestAnimationFrame(animateBrain);var t=Date.now()*.001;
  neonMat.uniforms.uTime.value=t;if(brainRoot)brainRoot.position.y=Math.sin(t*.5)*.06;renderer.render(scene,camera);}
animateBrain();

ov.width=SW();ov.height=SH();
window.addEventListener('resize',function(){camera.aspect=SW()/SH();camera.updateProjectionMatrix();
  renderer.setSize(SW(),SH());ov.width=SW();ov.height=SH();});

var RC=[135,195,211],CC=[224,1,152];
var RUN=[{name:'Landscape de Sistemas',sub:'54 sistemas',mat:'full'},
  {name:'Reglas de Negocio',sub:'169 reglas',mat:'full'},
  {name:'Capacidades RTB',sub:'282 caps',mat:'full'},
  {name:'Vocabulario Empresarial',sub:'155 términos',mat:'full'},
  {name:'Interfaces RFC/BAPI',sub:'80 interfaces',mat:'full'},
  {name:'Data-Lineage de Tablas',sub:'80 tablas',mat:'full'},
  {name:'Dependencias Cross-Sistema',sub:'463 evidencia',mat:'full'}];
var CHG=[{name:'Complejidad de Migración',sub:'12 programas',mat:'full'},
  {name:'Ranking 7R',sub:'backlog',mat:'full'},
  {name:'Simplification S/4HANA',sub:'12 items',mat:'full'},
  {name:'Agenda commercetools',sub:'eCommerce TO-BE',mat:'partial'},
  {name:'Digital Twins',sub:'7 gemelos',mat:'partial'},
  {name:'Riesgos e Issues',sub:'120 riesgos',mat:'full'},
  {name:'Roadmap de Transformación',sub:'pendiente',mat:'scaffold'}];
function buildNodes(items,sem,arc){var n=items.length;
  return items.map(function(it,i){var frac=(i+0.5)/n;
    var a0=arc==='left'?108*Math.PI/180:-50*Math.PI/180;
    var a1=arc==='left'?230*Math.PI/180:50*Math.PI/180;
    var ang=a0+frac*(a1-a0);
    return {name:it.name,sub:it.sub,mat:it.mat,sem:sem,arc:arc,ang:ang};});}
var allNodes=buildNodes(CHG,'change','left').concat(buildNodes(RUN,'run','right'));
var pkts=allNodes.reduce(function(arr,nd){
  arr.push({nd:nd,t:Math.random(),spd:.004+Math.random()*.003});
  arr.push({nd:nd,t:Math.random()+.5,spd:.003+Math.random()*.003});return arr;},[]);
function rGlow(x,y,r,col,a){var g=oc.createRadialGradient(x,y,0,x,y,r);
  g.addColorStop(0,'rgba('+col+','+a+')');g.addColorStop(1,'rgba('+col+',0)');
  oc.fillStyle=g;oc.beginPath();oc.arc(x,y,r,0,Math.PI*2);oc.fill();}
function roundRect(x,y,w,h,r){oc.beginPath();oc.moveTo(x+r,y);
  oc.arcTo(x+w,y,x+w,y+h,r);oc.arcTo(x+w,y+h,x,y+h,r);
  oc.arcTo(x,y+h,x,y,r);oc.arcTo(x,y,x+w,y,r);oc.closePath();}
function drawOntoBar(x,y,w,h,title,sub,fs){
  oc.fillStyle='rgba(10,4,8,.55)';roundRect(x,y,w,h,h/2);oc.fill();
  var g=oc.createLinearGradient(x,0,x+w,0);
  g.addColorStop(0,'rgba('+CC+',.6)');g.addColorStop(.5,'rgba(255,255,255,.22)');g.addColorStop(1,'rgba('+RC+',.6)');
  oc.strokeStyle=g;oc.lineWidth=1.3;roundRect(x,y,w,h,h/2);oc.stroke();
  oc.textAlign='center';oc.textBaseline='middle';
  oc.font='bold '+fs+'px Segoe UI';oc.fillStyle='rgba(255,255,255,.92)';oc.fillText(title,x+w/2,y+h/2-7);
  oc.font=(fs*.72)+'px Segoe UI';oc.fillStyle='rgba(255,255,255,.5)';oc.fillText(sub,x+w/2,y+h/2+8);}
var t2=null;
function draw2d(ts){requestAnimationFrame(draw2d);if(!t2)t2=ts;var t=(ts-t2)*.001;
  var W=ov.width,H=ov.height,cx=W/2,cy=H/2;var R=Math.min(cx,cy)*.58;
  oc.clearRect(0,0,W,H);
  for(var i=0;i<80;i++){var sx=(Math.sin(i*5.3)*.5+.5)*W,sy=(Math.sin(i*2.7)*.5+.5)*H;
    oc.globalAlpha=.06+Math.abs(Math.sin(t*.4+i))*.08;oc.fillStyle='#87C3D3';oc.fillRect(sx,sy,1,1);}
  oc.globalAlpha=1;
  oc.lineWidth=1;
  oc.beginPath();oc.arc(cx,cy,R,108*Math.PI/180,252*Math.PI/180);oc.strokeStyle='rgba(224,1,152,.15)';oc.stroke();
  oc.beginPath();oc.arc(cx,cy,R,-72*Math.PI/180,72*Math.PI/180);oc.strokeStyle='rgba(135,195,211,.15)';oc.stroke();
  allNodes.forEach(function(nd){var nx=cx+Math.cos(nd.ang)*R,ny=cy+Math.sin(nd.ang)*R;
    var col=nd.sem==='run'?RC:CC;var g=oc.createLinearGradient(cx,cy,nx,ny);
    g.addColorStop(0,'rgba('+col+',.45)');g.addColorStop(1,'rgba('+col+',0)');
    oc.beginPath();oc.moveTo(cx,cy);oc.lineTo(nx,ny);oc.strokeStyle=g;oc.lineWidth=.8;oc.stroke();});
  pkts.forEach(function(p){p.t=(p.t+p.spd)%1;
    var nx=cx+Math.cos(p.nd.ang)*R,ny=cy+Math.sin(p.nd.ang)*R;
    var ft=p.nd.sem==='change'?1-p.t:p.t;
    var fx=cx+(nx-cx)*ft,fy=cy+(ny-cy)*ft;var col=p.nd.sem==='run'?RC:CC;
    var a=Math.sin(p.t*Math.PI)*.85;oc.beginPath();oc.arc(fx,fy,2.5,0,Math.PI*2);
    oc.fillStyle='rgba('+col+','+a+')';oc.fill();});
  allNodes.forEach(function(nd){var nx=cx+Math.cos(nd.ang)*R,ny=cy+Math.sin(nd.ang)*R;
    var col=nd.sem==='run'?RC:CC;var onLeft=nd.arc==='left';
    if(nd.mat==='full'){rGlow(nx,ny,24,col,.5);
      oc.beginPath();oc.arc(nx,ny,6.5,0,Math.PI*2);oc.fillStyle='rgb('+col+')';oc.fill();
      oc.strokeStyle='rgba('+col+',.3)';oc.lineWidth=9;oc.beginPath();oc.arc(nx,ny,10,0,Math.PI*2);oc.stroke();
    }else if(nd.mat==='partial'){rGlow(nx,ny,18,col,.32);
      oc.beginPath();oc.arc(nx,ny,5.5,0,Math.PI*2);oc.fillStyle='rgb('+col+')';oc.fill();
      oc.setLineDash([3,3]);oc.strokeStyle='rgba('+col+',.55)';oc.lineWidth=1.5;
      oc.beginPath();oc.arc(nx,ny,11,0,Math.PI*2);oc.stroke();oc.setLineDash([]);
    }else{rGlow(nx,ny,11,col,.16);oc.beginPath();oc.arc(nx,ny,5,0,Math.PI*2);
      oc.strokeStyle='rgba('+col+',.6)';oc.lineWidth=1.5;oc.stroke();}
    oc.textAlign=onLeft?'right':'left';var lx=nx+(onLeft?-19:19);
    oc.textBaseline='alphabetic';oc.font='bold 12.5px Segoe UI';
    oc.shadowColor='rgba('+col+',.55)';oc.shadowBlur=6;
    oc.fillStyle=nd.mat==='scaffold'?'rgba(255,255,255,.55)':'rgba(255,255,255,.94)';
    oc.fillText(nd.name,lx,ny-1);oc.shadowBlur=0;
    oc.font='10px Segoe UI';oc.textBaseline='top';oc.fillStyle='rgba('+col+',.72)';
    oc.fillText(nd.sub,lx,ny+5);});
  var arR=R*0.68;
  function arrowBez(x0,y0,cpx,cpy,x1,y1,col0,col1,lbl,lblY,lblBase){
    var g=oc.createLinearGradient(x0,y0,x1,y1);
    g.addColorStop(0,'rgba('+col0+',.6)');g.addColorStop(1,'rgba('+col1+',.6)');
    oc.beginPath();oc.moveTo(x0,y0);oc.quadraticCurveTo(cpx,cpy,x1,y1);
    oc.strokeStyle=g;oc.lineWidth=2;oc.setLineDash([]);oc.stroke();
    var tx=x1-cpx,ty=y1-cpy,tl=Math.sqrt(tx*tx+ty*ty);tx/=tl;ty/=tl;
    var px=-ty,py=tx,sz=8;
    oc.fillStyle='rgba('+col1+',.75)';oc.beginPath();
    oc.moveTo(x1+tx*sz,y1+ty*sz);
    oc.lineTo(x1-tx*sz*.4+px*sz*.45,y1-ty*sz*.4+py*sz*.45);
    oc.lineTo(x1-tx*sz*.4-px*sz*.45,y1-ty*sz*.4-py*sz*.45);
    oc.closePath();oc.fill();
    oc.font='8.5px Segoe UI';oc.textAlign='center';oc.textBaseline=lblBase;
    oc.fillStyle='rgba(255,255,255,.38)';oc.fillText(lbl,cx,lblY);}
  arrowBez(cx-R*.30,cy+R*.55,cx,cy+R*.78,cx+R*.30,cy+R*.55,CC,RC,'Transforma',cy+R*.82,'top');
  arrowBez(cx+R*.30,cy-R*.55,cx,cy-R*.78,cx-R*.30,cy-R*.55,RC,CC,'Aprende',cy-R*.82,'bottom');
  var BOTS_L=[
    {name:'DT Complejidad Migración'},
    {name:'DT Ranking 7R'},
    {name:'DT Roadmap TO-BE'},
    {name:'DT Riesgos e Issues'}
  ];
  var BOTS_R=[
    {name:'DT Landscape Sistemas'},
    {name:'DT Capacidades RTB'},
    {name:'DT Data Lineage'},
    {name:'DT Dependencias'}
  ];
  function drawBot(bx,by,col,label,idx){
    var pulse=0.6+0.4*Math.sin(t*1.4+idx*0.9);
    rGlow(bx,by,24,col,.35*pulse);
    oc.strokeStyle='rgba('+col+','+(0.75*pulse)+')';oc.lineWidth=1.5;
    oc.beginPath();oc.moveTo(bx,by-8);oc.lineTo(bx,by-17);oc.stroke();
    oc.fillStyle='rgba('+col+','+(0.95*pulse)+')';
    oc.beginPath();oc.arc(bx,by-19,2.8,0,Math.PI*2);oc.fill();
    var hw=18,hh=14;
    oc.fillStyle='rgba(13,4,8,.92)';roundRect(bx-hw/2,by-hh/2,hw,hh,3);oc.fill();
    oc.strokeStyle='rgba('+col+','+(0.88*pulse)+')';oc.lineWidth=1.6;
    roundRect(bx-hw/2,by-hh/2,hw,hh,3);oc.stroke();
    oc.fillStyle='rgba('+col+','+(0.98*pulse)+')';
    oc.beginPath();oc.arc(bx-4.5,by-1,2.8,0,Math.PI*2);oc.fill();
    oc.beginPath();oc.arc(bx+4.5,by-1,2.8,0,Math.PI*2);oc.fill();
    oc.fillStyle='rgba('+col+',.48)';roundRect(bx-5.5,by+4.5,11,2.2,1);oc.fill();
    oc.font='8px Segoe UI';
    var maxPw=88,disp=label;
    while(oc.measureText(disp).width+10>maxPw&&disp.length>4)disp=disp.slice(0,-1);
    if(disp!==label)disp=disp.trimEnd()+'…';
    var tw=oc.measureText(disp).width,pw=tw+10,ph=12,lbx=bx-pw/2,lby=by+11;
    oc.fillStyle='rgba(13,4,8,.88)';roundRect(lbx,lby,pw,ph,ph/2);oc.fill();
    oc.strokeStyle='rgba('+col+',.45)';oc.lineWidth=0.9;roundRect(lbx,lby,pw,ph,ph/2);oc.stroke();
    oc.fillStyle='rgba(255,255,255,.85)';oc.textAlign='center';oc.textBaseline='middle';
    oc.fillText(disp,bx,lby+ph/2);}
  var botY=Math.max(28,SH()*.04)+58;
  var lStart=W*.08,lEnd=W*.38,rStart=W*.62,rEnd=W*.92;
  var lStep=(lEnd-lStart)/3,rStep=(rEnd-rStart)/3;
  BOTS_L.forEach(function(b,i){
    drawBot(lStart+i*lStep,botY,CC,b.name,i);});
  BOTS_R.forEach(function(b,i){
    drawBot(rStart+i*rStep,botY,RC,b.name,i+10);});
  var hy=Math.max(28,SH()*.04), hox=30, hf=Math.min(cx,cy)*.048;
  oc.textBaseline='alphabetic';oc.textAlign='right';
  oc.font='900 '+hf+'px Segoe UI';oc.shadowColor='rgba('+CC+',.65)';oc.shadowBlur=16;
  oc.fillStyle='rgb('+CC+')';oc.fillText('CHANGE LIVERPOOL',cx-hox,hy);oc.shadowBlur=0;
  oc.font='600 10px Segoe UI';oc.fillStyle='rgba(255,255,255,.5)';oc.fillText('Transformación · TO-BE',cx-hox,hy+18);
  oc.textAlign='left';oc.font='900 '+hf+'px Segoe UI';oc.shadowColor='rgba('+RC+',.65)';oc.shadowBlur=16;
  oc.fillStyle='rgb('+RC+')';oc.fillText('RUN LIVERPOOL',cx+hox,hy);oc.shadowBlur=0;
  oc.font='600 10px Segoe UI';oc.fillStyle='rgba(255,255,255,.5)';oc.fillText('Memoria del presente · AS-IS',cx+hox,hy+18);
  var obFs=Math.min(13,W*.011);var obW=Math.max(360,Math.min(W*.55,680)), obH=40;
  var obX=cx-obW/2, ob2Y=H-108;
  var ob1Y=botY+42;
  drawOntoBar(obX,ob1Y,obW,obH,'Retail Technology Blueprint','El QUÉ del negocio',obFs);
  drawOntoBar(obX,ob2Y,obW,obH,'TOGAF / ITOM','El CÓMO tecnológico',obFs);
  var mly=H-134;oc.textBaseline='middle';oc.font='9px Segoe UI';
  var mitems=[['Poblado','full'],['Parcial','partial'],['Pendiente','scaffold']];
  var dotGap=13,gap=22,totalW=0;
  mitems.forEach(function(it){totalW+=dotGap+oc.measureText(it[0]).width+gap;});
  var sxx=cx-totalW/2;
  mitems.forEach(function(it){var mx=sxx+5;
    if(it[1]==='full'){oc.fillStyle='rgba(200,205,225,.75)';oc.beginPath();oc.arc(mx,mly,4,0,Math.PI*2);oc.fill();}
    else if(it[1]==='partial'){oc.fillStyle='rgba(200,205,225,.55)';oc.beginPath();oc.arc(mx,mly,3,0,Math.PI*2);oc.fill();
      oc.setLineDash([2,2]);oc.strokeStyle='rgba(200,205,225,.55)';oc.lineWidth=1;oc.beginPath();oc.arc(mx,mly,6.5,0,Math.PI*2);oc.stroke();oc.setLineDash([]);}
    else{oc.strokeStyle='rgba(200,205,225,.55)';oc.lineWidth=1.3;oc.beginPath();oc.arc(mx,mly,4,0,Math.PI*2);oc.stroke();}
    oc.fillStyle='rgba(255,255,255,.5)';oc.textAlign='left';oc.fillText(it[0],mx+dotGap,mly);
    sxx+=dotGap+oc.measureText(it[0]).width+gap;});}
requestAnimationFrame(draw2d);
})();
</script>
"""
