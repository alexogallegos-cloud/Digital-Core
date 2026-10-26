#!/usr/bin/env python3
"""
build_incident_pages_sim.py — Bloques de simulación y guiones de animación.

Dos tipos de simulación:
  grid_sim    comparación actual contra propuesta sobre una rejilla de 50 celdas
  cluster_sim partición de clúster de dos nodos con toma de control

Y los guiones STEPS que animan los paneles de secuencia de cada página.
"""

import json


# ═════════════════════════════════════════════════════════════════════════════
# Simulación de rejilla comparativa
# ═════════════════════════════════════════════════════════════════════════════

def grid_sim(s):
    return f'''<div style="padding:20px 28px 24px;background:#ffffff;border-top:1px solid var(--border);">
  <div style="font-size:13px;font-weight:700;color:var(--txt);margin-bottom:4px;">Simulación &mdash; {s['title']}</div>
  <div style="font-size:10px;color:var(--dim);margin-bottom:16px;">{s['sub']}</div>

  <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;">

    <div style="border:2px solid #ef4444;border-radius:8px;padding:16px;background:#fff8f8;">
      <div style="font-size:11px;font-weight:700;color:#ef4444;margin-bottom:8px;display:flex;align-items:center;gap:6px;">
        <span style="background:#ef4444;color:white;border-radius:4px;padding:2px 6px;font-size:10px;">ACTUAL</span>{s['left_title']}
      </div>
      <div style="background:#1e293b;border-radius:6px;padding:10px;margin-bottom:12px;font-family:monospace;font-size:10px;color:#94a3b8;line-height:1.7;">{s['left_code']}</div>
      <div id="sgL" style="display:grid;grid-template-columns:repeat(25,1fr);gap:2px;margin-bottom:12px;"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:6px;text-align:center;">
        <div style="background:#fff1f2;border-radius:6px;padding:8px 4px;"><div id="sgLa" style="font-size:17px;font-weight:700;color:#ef4444;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m1']}</div></div>
        <div style="background:#fff1f2;border-radius:6px;padding:8px 4px;"><div id="sgLb" style="font-size:17px;font-weight:700;color:#f97316;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m2']}</div></div>
        <div style="background:#fff1f2;border-radius:6px;padding:8px 4px;"><div id="sgLc" style="font-size:14px;font-weight:700;color:#dc2626;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m3']}</div></div>
      </div>
    </div>

    <div style="border:2px solid #22c55e;border-radius:8px;padding:16px;background:#f0fdf4;">
      <div style="font-size:11px;font-weight:700;color:#15803d;margin-bottom:8px;display:flex;align-items:center;gap:6px;">
        <span style="background:#22c55e;color:white;border-radius:4px;padding:2px 6px;font-size:10px;">PROPUESTA</span>{s['right_title']}
      </div>
      <div style="background:#1e293b;border-radius:6px;padding:10px;margin-bottom:12px;font-family:monospace;font-size:10px;color:#94a3b8;line-height:1.7;">{s['right_code']}</div>
      <div id="sgR" style="display:grid;grid-template-columns:repeat(25,1fr);gap:2px;margin-bottom:12px;"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:6px;text-align:center;">
        <div style="background:#dcfce7;border-radius:6px;padding:8px 4px;"><div id="sgRa" style="font-size:17px;font-weight:700;color:#15803d;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m1']}</div></div>
        <div style="background:#dcfce7;border-radius:6px;padding:8px 4px;"><div id="sgRb" style="font-size:17px;font-weight:700;color:#15803d;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m2']}</div></div>
        <div style="background:#dcfce7;border-radius:6px;padding:8px 4px;"><div id="sgRc" style="font-size:14px;font-weight:700;color:#15803d;font-variant-numeric:tabular-nums;">0</div><div style="font-size:9px;color:#64748b;">{s['m3']}</div></div>
      </div>
    </div>
  </div>

  <button id="btnSim" style="padding:8px 24px;background:var(--ancla);color:white;border:none;border-radius:6px;cursor:pointer;font-size:12px;font-weight:600;letter-spacing:.3px;">&#9654; Ejecutar simulación</button>
  <span id="simStatus" style="font-size:10px;color:var(--dim);margin-left:12px;"></span>
  <div style="font-size:9px;color:var(--dim);margin-top:10px;line-height:1.5;">{s['foot']}</div>
</div>

<script>
(function(){{
  var CFG = {json.dumps(s['cfg'], ensure_ascii=False)};
  var CELLS = 50, running = false, timer = null;
  function grid(id){{
    var g = document.getElementById(id); if(!g) return; g.innerHTML = '';
    for(var i=0;i<CELLS;i++){{
      var d = document.createElement('div'); d.id = id+'_'+i;
      d.style.cssText = 'height:10px;border-radius:2px;background:#e2e8f0;transition:background .08s;';
      g.appendChild(d);
    }}
  }}
  function cell(id,i,c){{ var e=document.getElementById(id+'_'+i); if(e) e.style.background=c; }}
  function clear(id){{ for(var i=0;i<CELLS;i++) cell(id,i,'#e2e8f0'); }}
  function txt(id,v){{ var e=document.getElementById(id); if(e) e.textContent=v; }}
  function fmt(t,v){{ return t.replace('%', v); }}

  function reset(){{
    if(timer){{ clearTimeout(timer); timer=null; }}
    running=false; clear('sgL'); clear('sgR');
    txt('sgLa','0'); txt('sgLb','0'); txt('sgLc','0');
    txt('sgRa','0'); txt('sgRb','0'); txt('sgRc','0'); txt('simStatus','');
    var b=document.getElementById('btnSim');
    if(b){{ b.disabled=false; b.innerHTML='&#9654; Ejecutar simulación'; b.onclick=run; }}
  }}

  function run(){{
    if(running) return; running=true;
    var b=document.getElementById('btnSim'); if(b) b.disabled=true;
    txt('simStatus','Simulando...'); clear('sgL'); clear('sgR');
    setTimeout(function(){{
      for(var i=0;i<CFG.rFill;i++) cell('sgR',i,'#bbf7d0');
      for(var j=0;j<CFG.rHit;j++) cell('sgR',CFG.rAt+j,'#15803d');
      txt('sgRa',CFG.rA); txt('sgRb',CFG.rB); txt('sgRc',CFG.rC);
    }},160);
    var i=0;
    function step(){{
      if(i>=CELLS){{
        txt('simStatus', CFG.done);
        if(b){{ b.disabled=false; b.innerHTML='&#8635; Reiniciar'; b.onclick=reset; }}
        running=false; return;
      }}
      var over = (i >= CFG.breakAt);
      cell('sgL', i, over ? '#ef4444' : '#fed7aa');
      var f=(i+1)/CELLS;
      txt('sgLa', fmt(CFG.fmtA, Math.round(CFG.lA*f*10)/10));
      txt('sgLb', fmt(CFG.fmtB, Math.round(CFG.lB*f)));
      txt('sgLc', fmt(CFG.fmtC, Math.round(CFG.lC*f)));
      i++; timer=setTimeout(step, CFG.ms);
    }}
    step();
  }}
  grid('sgL'); grid('sgR');
  var b0=document.getElementById('btnSim'); if(b0) b0.onclick=run;
}})();
</script>'''


# ═════════════════════════════════════════════════════════════════════════════
# Simulación de partición de clúster (INC-013)
# ═════════════════════════════════════════════════════════════════════════════

def cluster_sim(s):
    return '''<div style="padding:20px 28px 24px;background:#ffffff;border-top:1px solid var(--border);">
  <div style="font-size:13px;font-weight:700;color:var(--txt);margin-bottom:4px;">
    Simulación &mdash; Partición del clúster DCMSIF y toma de control
  </div>
  <div style="font-size:10px;color:var(--dim);margin-bottom:16px;">
    Reproduce la ventana de 12:15 a 14:01 CST en tiempo comprimido, desde la causa hasta la remediación. Fuentes: <code>cluster.10082026</code>, <code>hacmp.out</code>,
    <code>clavailability.log</code>, <code>clevmgrd.debug</code> y los paquetes FFDC.
  </div>

  <div style="display:grid;grid-template-columns:1fr 150px 1fr;gap:14px;align-items:start;margin-bottom:16px;">

    <div id="csN1" style="border:2px solid #22c55e;border-radius:8px;padding:14px;background:#f0fdf4;transition:all .3s;">
      <div style="font-size:11px;font-weight:700;color:#15803d;margin-bottom:2px;">POWER10 &mdash; vPC_BC_IBMPOWER10_Po3</div>
      <div style="font-size:9px;color:#64748b;margin-bottom:10px;">Clúster nuevo. Aloja 10.36.197.51 con la instancia Informix activa</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;text-align:center;">
        <div style="background:#ffffff;border-radius:6px;padding:7px 4px;"><div id="csCpu" style="font-size:15px;font-weight:700;color:#15803d;font-variant-numeric:tabular-nums;">OK</div><div style="font-size:8.5px;color:#64748b;">ping a la .51</div></div>
        <div style="background:#ffffff;border-radius:6px;padding:7px 4px;"><div id="csEn0" style="font-size:15px;font-weight:700;color:#15803d;font-variant-numeric:tabular-nums;">1</div><div style="font-size:8.5px;color:#64748b;">chasis con la IP</div></div>
      </div>
      <div id="csIp1" style="margin-top:9px;font-size:10px;font-weight:700;color:#15803d;text-align:center;padding:5px;background:#dcfce7;border-radius:5px;">10.36.197.51</div>
    </div>

    <div style="text-align:center;padding-top:28px;">
      <div id="csHb" style="font-size:19px;letter-spacing:2px;color:#22c55e;font-family:monospace;">&bull;&bull;&bull;&bull;</div>
      <div style="font-size:8.5px;color:#64748b;margin-top:5px;">heartbeat en0</div>
      <div id="csClock" style="margin-top:12px;font-size:16px;font-weight:800;color:#122FB1;font-variant-numeric:tabular-nums;">12:15:00</div>
      <div id="csState" style="font-size:9px;color:#64748b;margin-top:3px;">Antes del evento</div>
    </div>

    <div id="csN2" style="border:2px solid #C5CCE8;border-radius:8px;padding:14px;background:#f8fafc;transition:all .3s;">
      <div style="font-size:11px;font-weight:700;color:#4a5a8a;margin-bottom:2px;">POWER8 &mdash; vPC_BC_IBMPower880</div>
      <div style="font-size:9px;color:#64748b;margin-bottom:10px;">Clúster viejo, nodo DCMSIF02 en espera. Sin Informix arrancado</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;text-align:center;">
        <div style="background:#ffffff;border-radius:6px;padding:7px 4px;"><div id="csVg" style="font-size:15px;font-weight:700;color:#4a5a8a;font-variant-numeric:tabular-nums;">0</div><div style="font-size:8.5px;color:#64748b;">VGs activados</div></div>
        <div style="background:#ffffff;border-radius:6px;padding:7px 4px;"><div id="csEl" style="font-size:15px;font-weight:700;color:#4a5a8a;font-variant-numeric:tabular-nums;">0s</div><div style="font-size:8.5px;color:#64748b;">acquire</div></div>
      </div>
      <div id="csIp2" style="margin-top:9px;font-size:10px;font-weight:700;color:#94a3b8;text-align:center;padding:5px;background:#f1f5f9;border-radius:5px;">sin IP de servicio</div>
    </div>
  </div>

  <div id="csLog" style="background:#e8ebf8;border:1px solid var(--border);border-radius:8px;padding:10px 12px;font-family:'Cascadia Code','Consolas',monospace;font-size:11px;height:132px;overflow-y:auto;margin-bottom:14px;"></div>

  <button id="btnCs" style="padding:8px 24px;background:var(--ancla);color:white;border:none;border-radius:6px;cursor:pointer;font-size:12px;font-weight:600;letter-spacing:.3px;">&#9654; Ejecutar simulación</button>
  <span id="csStatus" style="font-size:10px;color:var(--dim);margin-left:12px;"></span>

  <div style="font-size:9px;color:var(--dim);margin-top:10px;line-height:1.5;">
    El contador de volume groups avanza a escala real: 34 grupos procesados, con <code>ifx01vg</code> consumiendo
    71.5 s de los 478 totales. La barra de heartbeat representa el estado de membresía que registró DCMSIF02, no una
    medición de tráfico. El panel izquierdo aparece en trazo discontinuo de forma deliberada: del nodo que el clúster
    declaró caído no se recolectó ningún archivo, de modo que su estado real durante el episodio es desconocido.
  </div>
</div>

<script>
(function(){
  var SEQ = [
    {t:'12:15:00', hb:4, st:'Antes del evento',      msg:'La .51 vive solo en el POWER10. DCMSIF01_SRV sigue resolviendo a esa IP en /etc/hosts', cls:'ok'},
    {t:'12:15-12:32', hb:4, st:'Ventana sin evidencia', msg:'Algo levanta 10.36.197.51 en el POWER8. Del POWER8 no se recolectó ningún registro', cls:'err', dup:true},
    {t:'12:3x', hb:3, st:'IP duplicada en la fabric', msg:'APIC aprende la .51 en vPC_BC_IBMPower880 y en vPC_BC_IBMPOWER10_Po3 a la vez', cls:'err', split:true},
    {t:'12:32:00', hb:2, st:'Falla el ping a la .51', msg:'Pérdida de alcance a la dirección productiva del clúster nuevo', cls:'err', pingfail:true},
    {t:'12:34:08', hb:2, st:'Reacción humana',       msg:'Ocho sesiones interactivas en seis minutos. Diagnósticos de red desde las 12:38:13', cls:'err'},
    {t:'12:44:19', hb:0, st:'SPLIT del clúster viejo', msg:'CL_SPLIT_DETECTED y REASON=LINK_DOWN. 70 LVM_GS_RLEAVE sobre 35 volume groups', cls:'err'},
    {t:'12:44:49', hb:0, st:'Split policy is None',  msg:'Sin política de partición y sin tie breaker: nada arbitra', cls:'err'},
    {t:'12:44:50', hb:0, st:'node_down DCMSIF01',    msg:'El clúster declara caído a su par. No hay evidencia de ese nodo para contrastarlo', cls:'err', down:true},
    {t:'12:44:59', hb:0, st:'rg_move ACQUIRE',       msg:'Tres grupos de recursos, 34 volume groups de pasivo a activo', cls:'err', vg:[0,34,478]},
    {t:'12:45:02', hb:0, st:'3 IP aliasadas',        msg:'10.36.197.207, 10.36.198.146 y 10.36.199.129 pasan al nodo en espera', cls:'err', ip:true},
    {t:'12:50:59', hb:0, st:'config_too_long',       msg:'El acquire supera el umbral de 360 s. Se dispara la captura FFDC', cls:'err'},
    {t:'12:53:08', hb:1, st:'stop_server FALLA',     msg:'SIFHAOFF.sh rc=1: shared memory not initialized for INFORMIXSERVER coppel_shm', cls:'err', fail:true},
    {t:'12:55:09', hb:2, st:'VGs a modo pasivo',     msg:'varyonvg -c -n -P sobre 35 grupos. No quedaron activos', cls:'ok'},
    {t:'12:55:12', hb:2, st:'event_error',           msg:'rg_move RELEASE FAILED. Manual intervention is required', cls:'err', ipback:true},
    {t:'13:17:44', hb:3, st:'NODE_UP',               msg:'El nodo remoto vuelve a estado vivo, 33 minutos después del split', cls:'ok'},
    {t:'14:01:06', hb:4, st:'Remediación',           msg:'Termina la recolección en el POWER8. El apagado del nodo es posterior a esta marca', cls:'ok', done:true}
  ];
  var running=false, idx=0, timer=null;
  function id(x){ return document.getElementById(x); }
  function hb(n){
    var m=['&#9643;&#9643;&#9643;&#9643;','&bull;&#9643;&#9643;&#9643;','&bull;&bull;&#9643;&#9643;','&bull;&bull;&bull;&#9643;','&bull;&bull;&bull;&bull;'];
    var c=['#ef4444','#ef4444','#f97316','#f59e0b','#22c55e'];
    id('csHb').innerHTML=m[n]; id('csHb').style.color=c[n];
  }
  function log(t,cls,msg){
    var d=document.createElement('div');
    d.style.cssText='display:flex;gap:6px;padding:2px 0;opacity:0;transition:opacity .25s;';
    d.innerHTML='<span style="color:#4a5a8a;min-width:58px;">'+t+'</span>'+
                '<span style="min-width:30px;color:'+(cls==='ok'?'#22c55e':'#ef4444')+';">'+(cls==='ok'?'OK ':'ERR')+'</span>'+
                '<span style="flex:1;color:#0d1a3a;">'+msg+'</span>';
    id('csLog').appendChild(d);
    requestAnimationFrame(function(){ d.style.opacity='1'; });
    id('csLog').scrollTop=id('csLog').scrollHeight;
  }
  function reset(){
    if(timer){ clearTimeout(timer); timer=null; }
    running=false; idx=0;
    id('csLog').innerHTML=''; id('csClock').textContent='12:15:00';
    id('csState').textContent='Antes del evento'; id('csState').style.color='#64748b';
    id('csCpu').textContent='OK'; id('csCpu').style.color='#15803d';
    id('csEn0').textContent='1'; id('csEn0').style.color='#15803d';
    id('csVg').textContent='0'; id('csEl').textContent='0s';
    hb(4);
    id('csN1').style.borderColor='#22c55e'; id('csN1').style.background='#f0fdf4';
    id('csN2').style.borderColor='#C5CCE8'; id('csN2').style.background='#f8fafc';
    id('csIp1').textContent='10.36.197.51'; id('csIp1').style.background='#dcfce7'; id('csIp1').style.color='#15803d';
    id('csIp2').textContent='sin IP de servicio'; id('csIp2').style.background='#f1f5f9'; id('csIp2').style.color='#94a3b8';
    id('csStatus').textContent='';
    var b=id('btnCs'); b.disabled=false; b.innerHTML='&#9654; Ejecutar simulación'; b.onclick=run;
  }
  function vgRamp(from,to,secs,dur){
    var t0=Date.now();
    (function tick(){
      var p=Math.min((Date.now()-t0)/dur,1);
      id('csVg').textContent=Math.round(from+(to-from)*p);
      id('csEl').textContent=Math.round(secs*p)+'s';
      if(p<1) requestAnimationFrame(tick);
    })();
  }
  function run(){
    if(running) return; running=true;
    var b=id('btnCs'); b.disabled=true; id('csStatus').textContent='Reproduciendo...';
    id('csLog').innerHTML=''; idx=0;
    (function next(){
      if(idx>=SEQ.length){
        id('csStatus').textContent='Completado, 29 minutos reproducidos';
        b.disabled=false; b.innerHTML='&#8635; Reiniciar'; b.onclick=reset; running=false; return;
      }
      var e=SEQ[idx++];
      id('csClock').textContent=e.t;
      id('csState').textContent=e.st;
      id('csState').style.color = (e.cls==='ok') ? '#15803d' : '#ef4444';
      hb(e.hb);
      log(e.t,e.cls,e.msg);
      if(e.dup){
        id('csN2').style.borderColor='#f59e0b'; id('csN2').style.background='#fffbeb';
        id('csIp2').textContent='10.36.197.51 (!)'; id('csIp2').style.background='#fef3c7'; id('csIp2').style.color='#b45309';
      }
      if(e.pingfail){
        id('csCpu').textContent='FALLA'; id('csCpu').style.color='#ef4444';
        id('csIp1').style.background='#fef3c7'; id('csIp1').style.color='#b45309';
      }
      if(e.split){
        id('csEn0').textContent='2'; id('csEn0').style.color='#ef4444';
        id('csN1').style.borderColor='#f59e0b'; id('csN2').style.borderColor='#ef4444';
      }
      if(e.down){ id('csN2').style.background='#fff5f5'; }
      if(e.vg){ vgRamp(e.vg[0],e.vg[1],e.vg[2],5200); id('csN2').style.borderColor='#ef4444'; id('csN2').style.background='#fff5f5'; }
      if(e.ip){
        id('csIp2').textContent='.51 + 3 IP del viejo'; id('csIp2').style.background='#fee2e2'; id('csIp2').style.color='#ef4444';
      }
      if(e.fail){ id('csN2').style.borderColor='#ef4444'; }
      if(e.ipback){
        id('csIp2').textContent='2 IP sin liberar'; id('csIp2').style.background='#fef3c7'; id('csIp2').style.color='#b45309';
      }
      if(e.done){ id('csN1').style.borderColor='#22c55e'; id('csN1').style.background='#f0fdf4'; }
      timer=setTimeout(next, e.vg ? 5400 : 1250);
    })();
  }
  hb(4);
  var b0=id('btnCs'); if(b0) b0.onclick=run;
})();
</script>'''


# ═════════════════════════════════════════════════════════════════════════════
# Bloques listos
# ═════════════════════════════════════════════════════════════════════════════

SIM_011 = grid_sim({
    'title': 'Vista de compatibilidad contra acceso directo a la partición',
    'sub': 'La vista <code>intercard:movimiento</code> resuelve <code>movimiento_dia UNION ALL movimiento_all</code> '
           'en cada acceso. Escala visual: cada celda es una fracción del barrido completo.',
    'left_title': 'Double-scan, la vista recorre ambas tablas',
    'left_code': '<span style="color:#64748b;">-- el UNION ALL se resuelve en cada rama</span><br>'
                 '<span style="color:#f87171;">JOIN intercard:movimiento</span><span style="color:#e2e8f0;"> m</span>',
    'right_title': 'Un barrido, índice de la tabla física',
    'right_code': '<span style="color:#64748b;">-- cada rama ataca su partición</span><br>'
                  '<span style="color:#86efac;">JOIN intercard:movimiento_dia</span><span style="color:#e2e8f0;"> m</span>',
    'm1': 'instancias', 'm2': 'MB retenidos', 'm3': 'barridos físicos',
    'foot': 'Cifras de la izquierda tomadas de la ventana 12:29 a 13:28 del 14 de septiembre: la concurrencia pasa de '
            '4 a 12 instancias y la memoria agregada de 9.2 a 650.6 MB. La derecha refleja el comportamiento esperado '
            'tras el fix desplegado a las 19:20 CST, con una instancia que termina antes de que el canal reintente.',
    'cfg': {'lA': 12, 'lB': 651, 'lC': 24, 'fmtA': '%', 'fmtB': '% MB', 'fmtC': '%',
            'rA': '1', 'rB': '3 MB', 'rC': '1', 'rFill': 50, 'rAt': 24, 'rHit': 2,
            'breakAt': 25, 'ms': 58, 'done': 'Completado, 12 instancias y 650 MB'},
})

SIM_012 = grid_sim({
    'title': 'Concurrencia de <code>bdicheq:cons_sdos1</code> en la ventana batch',
    'sub': 'Cinco instancias simultáneas de 21.0 MB exactos, repartidas entre <code>running</code> e '
           '<code>IO Wait</code>. Escala visual: cada celda es un instante de la ventana de 29 minutos.',
    'left_title': 'Observado, concurrencia con espera de disco',
    'left_code': '<span style="color:#64748b;">-- mismo plan, lanzado en paralelo</span><br>'
                 '<span style="color:#fbbf24;">bdicheq:cons_sdos1</span><span style="color:#e2e8f0;"> x5, IO Wait</span>',
    'right_title': 'Referencia, el resto de la ventana',
    'right_code': '<span style="color:#64748b;">-- perfil normal del batch nocturno</span><br>'
                  '<span style="color:#86efac;">8.2 sesiones en ejecución</span>',
    'm1': 'instancias', 'm2': 'MB agregados', 'm3': 'en IO Wait',
    'foot': 'Esta ventana no registra falla. Las cifras provienen de 30 capturas entre 01:00 y 01:29 CDMX del 24 de '
            'agosto. El valor del registro es servir de referencia: sin saber cómo se ve la normalidad, ninguna '
            'cifra de un incidente futuro tiene contra qué compararse.',
    'cfg': {'lA': 5, 'lB': 105, 'lC': 3, 'fmtA': '%', 'fmtB': '% MB', 'fmtC': '%',
            'rA': '1', 'rB': '21 MB', 'rC': '0', 'rFill': 50, 'rAt': 20, 'rHit': 1,
            'breakAt': 36, 'ms': 52, 'done': 'Completado, pico de 5 instancias a la 01:13'},
})

SIM_013 = cluster_sim({})


# ═════════════════════════════════════════════════════════════════════════════
# Guiones de animación de los paneles
# ═════════════════════════════════════════════════════════════════════════════

def _s(node, logs, hud=None, tl=None, tlw=None, tld=None, ms=800, color='#ef4444'):
    d = {'node': node, 'log': logs, 'ms': ms, 'color': color}
    if hud:
        d['hud'] = hud
    if tl is not None:
        d['tl'] = tl
        d['tlw'] = tlw
        d['tld'] = tld
    return d


STEPS_011 = [
    _s('Ln0', [['L', '12:29', 'ok', 'Canal BPI solicita movimientos de tarjeta']],
       [['L', 0, '4', '0']], color='#122FB1'),
    _s('Ln1', [['L', '12:29', 'ok', 'bdicred:sp_msi_consultmovs_bpi inicia']],
       [['L', 1, '9.2 MB', '0 MB']]),
    _s('Ln2', [['L', '12:31', 'err', 'JOIN contra la vista en ambas ramas del UNION ALL']],
       [['L', 2, '2x', '0']]),
    _s('Ln3', [['L', '12:39', 'err', 'La vista recorre movimiento_dia y movimiento_all']],
       [['L', 1, '24.2 MB', '0 MB']], tl=0, tlw=35, tld='23 min'),
    _s('Ln4', [['L', '12:49', 'err', 'El SP no termina, BPI lanza otra instancia'],
               ['L', '13:02', 'err', 'Instancia mayor en 211.9 MB, colapso inminente']],
       [['L', 0, '10', '0'], ['L', 1, '477 MB', '0 MB']], tl=1, tlw=100, tld='13:03'),
    _s('Ln5', [['L', '13:16', 'err', 'Doce instancias simultáneas, 650.6 MB agregados'],
               ['L', '14:12', 'err', 'Load average entre 50 y 60']],
       [['L', 0, '12', '0'], ['L', 1, '650 MB', '0 MB'], ['L', 2, '24', '0']],
       tl=2, tlw=100, tld='22 min'),
    _s('Rn1', [['R', '19:20', 'ok', 'Deploy de sp_msi_consultmovs_bpi_NEW']],
       [['R', 0, '1', '0']], color='#22c55e'),
    _s('Rn2', [['R', '19:20', 'ok', 'Rama sd_movdiacrd apunta a movimiento_dia']],
       color='#22c55e'),
    _s('Rn3', [['R', '19:20', 'ok', 'Rama sd_movhiscrd apunta a movimiento_all']],
       color='#22c55e'),
    _s('Rn4', [['R', '19:20', 'ok', 'El optimizador usa el índice de la tabla física']],
       [['R', 2, '1', '0']], color='#22c55e'),
    _s('Rn5', [['R', '19:30', 'ok', 'El SP termina antes del reintento, load average normalizado']],
       [['R', 1, '3 MB', '0 MB']], tl=4, tlw=100, tld='fix', color='#22c55e'),
]

STEPS_012 = [
    _s('Ln0', [['L', '01:00', 'ok', 'Control-M dispara la malla nocturna']],
       [['L', 0, '0', '0']], color='#122FB1'),
    _s('Ln1', [['L', '01:05', 'ok', 'Familia sp_ics_* domina la ventana, 28 apariciones']],
       color='#122FB1', tl=0, tlw=40, tld='29 min'),
    _s('Ln2', [['L', '01:11', 'err', 'cons_sdos1 alcanza 4 instancias, 84.0 MB']],
       [['L', 0, '4', '0'], ['L', 1, '84 MB', '0 MB']], tl=1, tlw=55, tld='16 min'),
    _s('Ln3', [['L', '01:13', 'err', 'Pico de 5 instancias, 104.9 MB, varias en IO Wait']],
       [['L', 0, '5', '0'], ['L', 1, '105 MB', '0 MB'], ['L', 2, '3', '0']],
       tl=2, tlw=100, tld='01:13'),
    _s('Ln4', [['L', '01:20', 'err', 'SQL inline de batch sobre intercard:movimiento, 6 apariciones']],
       color='#f59e0b'),
    _s('Ln5', [['L', '01:29', 'ok', 'Ventana cerrada sin contención ni lock waits']],
       tl=0, tlw=100, tld='estable', color='#22c55e'),
    _s('Rn0', [['R', '01:00', 'ok', '30 capturas de un minuto, cobertura continua']],
       [['R', 0, '30', '0']], color='#22c55e'),
    _s('Rn1', [['R', '01:29', 'ok', 'Sesiones por captura entre 3,315 y 3,558']],
       [['R', 1, '3,439', '0']], color='#22c55e'),
    _s('Rn2', [['R', '01:29', 'ok', 'Promedio de 8.2 sesiones en ejecución']],
       [['R', 2, '8.2', '0']], color='#22c55e'),
    _s('Rn3', [['R', '01:29', 'ok', 'Sin lock waits en toda la ventana']], color='#22c55e'),
    _s('Rn4', [['R', '01:29', 'ok', 'Perfil de SPs dominantes registrado']], color='#22c55e'),
    _s('Rn5', [['R', '01:29', 'ok', 'Línea base disponible para comparación futura']], color='#22c55e'),
]

STEPS_013 = [
    _s('Ln0', [['L', '12:15', 'err', 'Ventana del disparador. Del POWER8 no se recolectó ningún registro'],
               ['L', '12:15', 'err', 'DCMSIF01_SRV sigue resolviendo a 10.36.197.51 en /etc/hosts']],
       tl=0, tlw=100, tld='17 min'),
    _s('Ln1', [['L', '12:3x', 'err', 'APIC aprende 10.36.197.51 en vPC_BC_IBMPower880, chasis POWER8'],
               ['L', '12:3x', 'err', 'y a la vez en vPC_BC_IBMPOWER10_Po3, chasis POWER10']],
       [['L', 0, '2', '0']]),
    _s('Ln2', [['L', '12:32', 'err', 'Falla el ping a 10.36.197.51, dirección productiva del clúster nuevo'],
               ['L', '12:34:08', 'err', 'Entran ocho sesiones interactivas en seis minutos'],
               ['L', '12:38:13', 'err', 'Diagnósticos de red fuera de toda cadencia automática']],
       tl=1, tlw=100, tld='12:32', ms=1000),
    _s('Ln3', [['L', '12:44:19', 'err', 'CL_SPLIT_DETECTED en el clúster viejo, REASON=LINK_DOWN'],
               ['L', '12:44:19', 'err', '70 LVM_GS_RLEAVE, 35 volume groups por duplicado']],
       tl=2, tlw=100, tld='9 min'),
    _s('Ln4', [['L', '12:44:49', 'err', 'Split policy is None, quarantine=0. No hay tie breaker configurado'],
               ['L', '12:44:50', 'err', 'node_down DCMSIF01 sin posibilidad de contraste']],
       [['L', 2, '1', '0']]),
    _s('Ln5', [['L', '12:44:59', 'err', 'rg_move ACQUIRE sobre tres grupos, 34 VGs de pasivo a activo'],
               ['L', '12:50:59', 'err', 'config_too_long, el acquire supera los 360 s'],
               ['L', '12:53:08', 'err', 'SIFHAOFF.sh rc=1, shared memory not initialized coppel_shm'],
               ['L', '12:55:09', 'ok', 'Los 35 VGs vuelven a modo pasivo con varyonvg -c -n -P'],
               ['L', '12:55:12', 'err', 'rg_move RELEASE FAILED, event_error'],
               ['L', '14:01:06', 'ok', 'Termina la recolección en el POWER8. El apagado es posterior']],
       [['L', 1, '34', '0'], ['L', 2, '3', '0']], tl=3, tlw=100, tld='10m53s', ms=1400),
    _s('Rn0', [['R', '—', 'ok', 'Un solo juego de direcciones por clúster en los cuatro nodos']],
       color='#22c55e'),
    _s('Rn1', [['R', '—', 'ok', 'Retirar el bloque de migración: DCMSIF01_SRV deja de resolver a la .51']],
       [['R', 0, '1', '0']], color='#22c55e'),
    _s('Rn2', [['R', '—', 'ok', 'netmon.cf con objetivos: el nodo verifica si la falla es de su propio adaptador']],
       color='#22c55e'),
    _s('Rn3', [['R', '—', 'ok', 'Política de partición con desempate: gana quien ya tiene el grupo']],
       color='#22c55e'),
    _s('Rn4', [['R', '—', 'ok', 'Umbral por encima de los 478 s que tarda la operación real'],
               ['R', '—', 'ok', 'Sin toma de control, cero volume groups movidos']],
       [['R', 1, '0', '0']], color='#22c55e'),
    _s('Rn5', [['R', '—', 'ok', 'SIFHAOFF.sh idempotente: detener lo que no corre devuelve cero']],
       [['R', 2, '0', '0']], tl=4, tlw=100, tld='limpio', color='#22c55e'),
]
