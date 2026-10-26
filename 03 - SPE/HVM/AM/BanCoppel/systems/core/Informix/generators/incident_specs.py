#!/usr/bin/env python3
"""
incident_specs.py — Especificaciones de datos por incidente.

Consumido por build-incident-pages.py. Cada entrada de INCIDENTS describe un
incidente con evidencia verificable. No se inventan cifras: cada métrica tiene
su fuente anotada en la sección de evidencia de la propia página.
"""

from build_incident_pages_sim import (
    SIM_011, SIM_012, SIM_013,
    STEPS_011, STEPS_012, STEPS_013,
)


# ═════════════════════════════════════════════════════════════════════════════
# INC-011 — 2026-09-14 — Vista intercard:movimiento, double-scan
# ═════════════════════════════════════════════════════════════════════════════

INC_011 = {
    'slug':   'inc-011-intercard-movimiento-double-scan',
    'folder': '2026-09-14',
    'inc':    'INC-011',
    'date_pill': '14 sep 2026',
    'headline': 'Vista intercard:movimiento, double-scan y ondas de concurrencia',
    'subtitle': 'Diagnóstico de incidente en producción, Informix, 14 de septiembre de 2026, '
                'ventana observada 12:29 a 13:28 CDMX, 60 capturas de onstat',
    'title': 'INC-011, intercard:movimiento double-scan, BanCoppel Informix, 14 septiembre 2026',
    'metrics': [
        ('50-60',     'Load average pico',       ''),
        ('12',        'Instancias concurrentes', 'w'),
        ('650 MB',    'Memoria agregada',        'w'),
        ('472',       'Apariciones en running',  ''),
        ('50',        'SPs sobre la vista',      'i'),
        ('19:20 CST', 'Deploy del fix',          'g'),
    ],
    'impact': {
        'badge': 'N3 CRÍTICO',
        'items': [
            {'lbl': 'Dominio afectado', 'val': 'bdicred, intercard, bdicnweb, bdicheq',
             'sub': 'Cuatro dominios sobre la misma vista compartida'},
            {'lbl': 'Capacidad afectada', 'val': 'Consulta de movimientos de tarjeta',
             'sub': 'Canal BPI, reportes a meses sin intereses e historial de cuenta'},
            {'lbl': 'Qué deja de funcionar', 'val': 'Degradación general del motor', 'val_cls': 'impact-crit',
             'sub': 'El load average sostenido afecta a toda sesión concurrente, no solo al SP culpable'},
            {'lbl': 'SP principal', 'val': 'bdicred:sp_msi_consultmovs_bpi',
             'sub': 'Invocado por el canal BPI con usuario interbpi'},
            {'lbl': 'Riesgo regulatorio', 'val': 'SLA operativo CNBV', 'val_cls': 'impact-reg',
             'sub': 'Degradación en horario de mayor operación transaccional'},
        ],
    },
    'ctx': [
        {
            'title': 'Contexto funcional, por qué sucede esto',
            'cards': [
                {'num': '01', 'title': '¿Qué es la vista intercard:movimiento?',
                 'body': 'La tabla original de movimientos de tarjeta se partió en dos tablas físicas, '
                         '<code>movimiento_dia</code> con los movimientos del día en curso y '
                         '<code>movimiento_all</code> con el histórico. Para no tocar el código existente se creó '
                         'una vista de compatibilidad <code>movimiento = movimiento_dia UNION ALL movimiento_all</code>. '
                         'La vista preserva la compatibilidad pero no la eficiencia.'},
                {'num': '02', 'title': '¿Por qué duele la vista?',
                 'body': 'Todo acceso a la vista resuelve internamente el <code>UNION ALL</code>, de modo que el motor '
                         'recorre <strong>ambas</strong> tablas aunque el predicado solo necesite una. Con N instancias '
                         'concurrentes el costo de entrada y salida es de 2N barridos en lugar de N.'},
                {'num': '03', 'title': '¿Qué es el patrón de onda?',
                 'body': 'El SP tarda tanto que el canal BPI lanza otra instancia antes de que la anterior termine. '
                         'Cada instancia retiene memoria a razón de unos <strong>9.5 MB por minuto</strong>. '
                         'Se acumulan instancias hasta que colapsan o son terminadas, y el ciclo reinicia. '
                         'En la ventana observada se contaron dos ondas completas.'},
                {'num': '!', 'reg': True, 'title': '¿Por qué puede repetirse?',
                 'body': 'El fix corrigió un SP. Quedan <strong>50 SPs</strong> que siguen accediendo a la vista. '
                         'El de mayor riesgo inmediato es <code>bdicnweb:sp_msi_genrepmsi</code>, con patrón '
                         'idéntico al corregido y todavía sin atender.'},
            ],
        },
        {
            'title': 'Evidencia raw, análisis independiente de 60 capturas onstat',
            'title_color': 'var(--ancla)',
            'style': 'border-top:2px solid rgba(18,47,177,.2);',
            'cards': [
                {'num': 'S', 'title': 'Volumen de sesiones',
                 'body': 'Promedio de <strong>5,818 sesiones</strong> por captura, con mínimo de 5,615 y máximo de 6,121. '
                         'Sesiones en estado <code>running</code>: promedio 28.7, máximo 44.'},
                {'num': 'R', 'title': 'Dominancia del SP',
                 'body': '<code>sp_msi_consultmovs_bpi</code> aparece <strong>472 veces</strong> en estado running '
                         'a lo largo de la ventana. El segundo lugar tiene 59 apariciones. '
                         'Es dominancia absoluta, no un SP más entre varios.'},
                {'num': 'M', 'title': 'Crecimiento de memoria',
                 'body': 'Onda uno de 12:39 a 13:02, con la instancia mayor pasando de 12.8 MB a 211.9 MB. '
                         'Colapso a las 13:03 y reinicio inmediato. Onda dos de 13:03 a 13:25, '
                         'con pico agregado de <strong>650.6 MB</strong> en doce instancias simultáneas.'},
                {'num': 'F', 'reg': True, 'title': 'Forma del fix',
                 'body': 'En el <code>UNION ALL</code> del <code>FOREACH</code>, la rama de <code>sd_movdiacrd</code> '
                         'pasa a unir contra <code>movimiento_dia</code> y la de <code>sd_movhiscrd</code> contra '
                         '<code>movimiento_all</code>. El optimizador usa el índice de la tabla física correcta '
                         'sin resolver la vista.'},
            ],
            'foot': 'Fuente: 60 capturas de <code>onstat -g ses</code> entre 12:29 y 13:28 CDMX, '
                    'más tribal_knowledge y decisions_history de brain.db (ADR-INTERCARD-001 y ADR-INTERCARD-002).',
        },
    ],
    'findings': {
        'title': 'Hallazgos confirmados, código y logs verificados',
        'sub': 'evidencia 2026-09-14, 60 capturas',
        'rows': [
            {'badge': 'CRÍTICO', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'bdicred_sp_msi_consultmovs_bpi.sql', 'source': 'bdicred, consulta de movimientos canal BPI',
             'loc': 'UNION ALL', 'loc_cls': 'd05-rate-high',
             'desc': 'Ambas ramas del <code>FOREACH</code> unían contra la vista <code>intercard:movimiento</code>, '
                     'forzando double-scan en cada rama. Corregido y desplegado a las 19:20 CST del mismo día.'},
            {'badge': 'PENDIENTE', 'badge_cls': 'd05-badge-warn',
             'artifact': 'bdicnweb_sp_msi_genrepmsi.sql', 'source': 'bdicnweb, reportes de meses sin intereses',
             'loc': '1604, 1749, 1760, 1796', 'loc_cls': 'd05-rate-mid',
             'desc': 'Único SP de clasificación Tier A todavía sin corregir. Patrón idéntico al corregido: '
                     '<code>UNION ALL</code> con <code>sd_movdiacrd</code> y <code>sd_movhiscrd</code> uniendo contra la vista.'},
            {'badge': 'RIESGO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'bdicheq:sp_histmovcheq, familia de 13 SPs', 'source': 'bdicheq, historial de cuenta de cheques',
             'loc': 'Tier D', 'loc_cls': '',
             'desc': 'bdicheq concentra el 20% de las sesiones de producción. Trece SPs distintos sobre la misma vista '
                     'en el mismo horario suman una presión agregada potencialmente mayor que la del SP ya corregido.'},
            {'badge': 'RIESGO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'bdireports, 8 SPs de reporte', 'source': 'bdireports, batch nocturno',
             'loc': 'Tier D', 'loc_cls': '',
             'desc': 'Si el double-scan alarga estos trabajos, el batch se solapa con la apertura bancaria y el SPEI '
                     'matutino. Mismo mecanismo, distinto horario.'},
        ],
        'note': 'El fix resuelve un SP de cincuenta. El riesgo de recurrencia persiste hasta completar el inventario, '
                'cuya prioridad es Tier A, luego Tier C, luego la familia bdicheq y por último el resto de Tier D.',
    },
    'sim': None,   # se llena abajo
    'timeline': {
        'title': 'Línea de tiempo, escala 12:29 a 19:20 CDMX',
        'rows': [
            {'lbl': 'Onda uno, 12:39 a 13:02, memoria 12.8 a 211.9 MB', 'cls': 'tl-amber', 'color': 'var(--amber)'},
            {'lbl': 'Colapso y reinicio, 13:03', 'cls': 'tl-err', 'color': 'var(--err)'},
            {'lbl': 'Onda dos, 13:03 a 13:25, pico agregado 650.6 MB', 'cls': 'tl-err', 'color': 'var(--err)'},
            {'lbl': 'Pico de load average, 14:12 a 14:45', 'cls': 'tl-err', 'color': 'var(--err)'},
            {'lbl': 'Deploy del fix, 19:20', 'cls': 'tl-ok', 'color': 'var(--ok)'},
        ],
        'markers': ['12:29', '12:39', '13:03', '13:25', '14:12', '14:45', '19:20'],
    },
    'panel_l': {
        'badge': 'OBS', 'badge_cls': 'pb-err',
        'title': 'Secuencia observada',
        'sub': 'Canal BPI sobre la vista de compatibilidad',
        'nodes': [
            {'top': 'Canal BPI, usuario interbpi', 'main': 'Solicitud de movimientos'},
            {'top': 'bdicred', 'main': 'sp_msi_consultmovs_bpi', 'style': 'accent'},
            {'top': 'UNION ALL del FOREACH', 'main': 'JOIN intercard:movimiento', 'style': 'danger',
             'note': 'x2', 'note2': 'double-scan', 'note_color': '#ef4444'},
            {'top': 'La vista resuelve ambas ramas', 'main': 'movimiento_dia y movimiento_all', 'style': 'danger'},
            {'top': 'El SP no termina a tiempo', 'main': 'BPI lanza otra instancia', 'style': 'danger',
             'note': '9.5 MB', 'note2': 'por minuto'},
            {'top': 'Hasta 12 simultáneas', 'main': 'Load average 50 a 60', 'style': 'danger'},
        ],
        'hud': [('0', 'Instancias', ''), ('0 MB', 'Memoria', 't'), ('0', 'Barridos', '')],
        'rc': {
            'title': 'Causa raíz',
            'body': 'La vista de compatibilidad <code>intercard:movimiento</code> oculta un <code>UNION ALL</code> '
                    'que obliga a recorrer las dos tablas físicas en cada rama del <code>FOREACH</code>. '
                    'El SP se alarga, el canal reintenta y las instancias se apilan.',
            'fixes': ['La vista da compatibilidad, no eficiencia',
                      'Cada instancia retiene unos 9.5 MB por minuto',
                      'Quedan 50 SPs con el mismo patrón'],
        },
    },
    'panel_r': {
        'badge': 'FIX', 'badge_cls': 'pb-ok',
        'title': 'Con el fix aplicado',
        'sub': 'Acceso directo a la partición correcta, desplegado 19:20 CST',
        'nodes': [
            {'top': 'Canal BPI, usuario interbpi', 'main': 'Solicitud de movimientos'},
            {'top': 'bdicred', 'main': 'sp_msi_consultmovs_bpi_NEW', 'style': 'accent'},
            {'top': 'Rama sd_movdiacrd', 'main': 'JOIN movimiento_dia', 'style': 'good'},
            {'top': 'Rama sd_movhiscrd', 'main': 'JOIN movimiento_all', 'style': 'good'},
            {'top': 'Índice de la tabla física', 'main': 'Sin resolver la vista', 'style': 'good'},
            {'top': 'El SP termina a tiempo', 'main': 'Load average normalizado', 'style': 'good'},
        ],
        'hud': [('0', 'Instancias', 'g'), ('0 MB', 'Memoria', 'g'), ('0', 'Barridos', 'g')],
        'rc': {
            'title': 'Resultado',
            'body': 'Cada rama ataca la tabla física que le corresponde. El optimizador usa el índice directo, '
                    'el SP termina antes de que el canal reintente y las instancias dejan de apilarse.',
            'fixes': ['Un barrido por rama en lugar de dos',
                      'Referencia para corregir los 50 SPs restantes'],
        },
    },
    'steps': [],   # se llena abajo
}


# ═════════════════════════════════════════════════════════════════════════════
# INC-012 — 2026-08-24 — Batch nocturno, línea base con hallazgos
# ═════════════════════════════════════════════════════════════════════════════

INC_012 = {
    'slug':   'inc-012-batch-nocturno-linea-base',
    'folder': '2026-08-24',
    'inc':    'INC-012',
    'date_pill': '24 ago 2026',
    'headline': 'Batch nocturno, línea base estable con hallazgos precursores',
    'subtitle': 'Observación de ventana batch, Informix, 24 de agosto de 2026, '
                '01:00 a 01:29 CDMX, 30 capturas de onstat',
    'title': 'INC-012, batch nocturno línea base, BanCoppel Informix, 24 agosto 2026',
    'metrics': [
        ('30',      'Capturas analizadas',   'i'),
        ('3,439',   'Sesiones promedio',     'i'),
        ('8.2',     'Running promedio',      'g'),
        ('5',       'Instancias cons_sdos1', 'w'),
        ('104.9 MB', 'Memoria agregada',     'w'),
        ('ESTABLE', 'Veredicto',             'g'),
    ],
    'impact': {
        'badge': 'N1 OBSERVACIÓN',
        'items': [
            {'lbl': 'Naturaleza', 'val': 'No es un incidente',
             'sub': 'Ventana de observación tomada como línea base del batch nocturno'},
            {'lbl': 'Estado del sistema', 'val': 'Estable en toda la ventana',
             'sub': 'Sin lock waits, sin degradación, sin errores de aplicación'},
            {'lbl': 'Valor del registro', 'val': 'Referencia de comparación',
             'sub': 'Permite distinguir carga normal de carga anómala en ventanas futuras'},
            {'lbl': 'Hallazgo principal', 'val': 'bdicheq:cons_sdos1 en IO Wait', 'val_cls': 'impact-crit',
             'sub': 'Cinco instancias simultáneas con 21 MB cada una, mezcla de running e IO Wait'},
            {'lbl': 'Señal precursora', 'val': 'SQL de batch sobre la vista',
             'sub': 'La misma vista intercard:movimiento del INC-011, ahora en horario nocturno'},
        ],
    },
    'ctx': [
        {
            'title': 'Contexto funcional, qué se observó',
            'cards': [
                {'num': '01', 'title': '¿Por qué registrar una ventana sin incidente?',
                 'body': 'Sin línea base, cualquier cifra de un incidente futuro carece de referencia. '
                         'Saber que el batch nocturno opera con <strong>3,439 sesiones</strong> y apenas '
                         '<strong>8.2 en ejecución</strong> convierte cualquier desviación en señal medible.'},
                {'num': '02', 'title': '¿Qué domina el batch nocturno?',
                 'body': 'La familia <code>sp_ics_*</code> de bdicred encabeza con 28 apariciones de '
                         '<code>sp_ics_cuotas</code> y 13 de <code>sp_ics_personas</code>. Les siguen '
                         '<code>bdicheq:cons_sdos1</code> y <code>bdicheq:sp_actsdodiarioc</code> con 13 y 12.'},
                {'num': '03', 'title': '¿Qué llama la atención en cons_sdos1?',
                 'body': 'Alcanza <strong>cinco instancias simultáneas</strong> a la 01:13, con 21 MB '
                         'exactos cada una y 104.9 MB agregados. Varias permanecen en <code>IO Wait</code>, '
                         'no en <code>running</code>, lo que indica espera de entrada y salida, no cómputo.'},
                {'num': '!', 'reg': True, 'title': '¿Qué conecta esta ventana con el INC-011?',
                 'body': 'Aparece SQL de batch accediendo a <code>intercard:movimiento</code> como vista, '
                         'seis veces en la ventana. Es el mismo mecanismo de double-scan del incidente de '
                         'septiembre, operando de noche sobre un motor con holgura.'},
            ],
        },
    ],
    'findings': {
        'title': 'Hallazgos de la ventana, sin impacto en servicio',
        'sub': 'evidencia 2026-08-24, 01:00 a 01:29 CDMX',
        'rows': [
            {'badge': 'OBSERVACIÓN', 'badge_cls': 'd05-badge-warn',
             'artifact': 'bdicheq:cons_sdos1', 'source': 'bdicheq, consulta de saldos',
             'loc': '01:13', 'loc_cls': 'd05-rate-mid',
             'desc': 'Cinco instancias simultáneas de 21.0 MB cada una, 104.9 MB agregados, repartidas entre '
                     '<code>running</code> e <code>IO Wait</code>. El perfil de memoria idéntico por instancia '
                     'sugiere una misma consulta con el mismo plan, lanzada en paralelo.'},
            {'badge': 'PRECURSOR', 'badge_cls': 'd05-badge-warn',
             'artifact': 'SQL inline de batch', 'source': 'intercard, acceso directo sin SP',
             'loc': '6 apariciones', 'loc_cls': '',
             'desc': 'Sentencias de batch que consultan <code>intercard:movimiento</code> como vista, heredando '
                     'el double-scan. De noche el motor absorbe el costo; en apertura bancaria no necesariamente.'},
            {'badge': 'LÍNEA BASE', 'badge_cls': 'd05-badge-gating',
             'artifact': 'Perfil de carga nocturna', 'source': '30 capturas de onstat',
             'loc': '01:00 a 01:29', 'loc_cls': '',
             'desc': 'Sesiones por captura entre 3,315 y 3,558. Sesiones en ejecución entre 0 y 34, promedio 8.2. '
                     'Este es el patrón contra el que debe compararse cualquier ventana batch futura.'},
        ],
        'note': 'Esta ventana no documenta una falla. Documenta cómo se ve la normalidad, y deja señalados dos '
                'elementos que en otro horario podrían dejar de serlo.',
    },
    'sim': None,
    'timeline': {
        'title': 'Línea de tiempo, escala 01:00 a 01:29 CDMX',
        'rows': [
            {'lbl': 'Ventana de observación completa', 'cls': 'tl-ok', 'color': 'var(--ok)'},
            {'lbl': 'Concurrencia de cons_sdos1, 01:11 a 01:27', 'cls': 'tl-amber', 'color': 'var(--amber)'},
            {'lbl': 'Pico de 5 instancias, 01:13', 'cls': 'tl-amber', 'color': 'var(--amber)'},
        ],
        'markers': ['01:00', '01:05', '01:11', '01:13', '01:20', '01:27', '01:29'],
    },
    'panel_l': {
        'badge': 'OBS', 'badge_cls': 'pb-err',
        'title': 'Lo observado en la ventana',
        'sub': 'Batch nocturno con concurrencia moderada',
        'nodes': [
            {'top': 'Control-M', 'main': 'Disparo del batch nocturno'},
            {'top': 'bdicred', 'main': 'Familia sp_ics_*', 'style': 'accent'},
            {'top': 'bdicheq', 'main': 'cons_sdos1', 'style': 'accent',
             'note': '5x', 'note2': '21 MB c/u'},
            {'top': 'Varias instancias esperan disco', 'main': 'Estado IO Wait', 'style': 'danger'},
            {'top': 'SQL inline de batch', 'main': 'intercard:movimiento como vista', 'style': 'danger'},
            {'top': 'El motor absorbe el costo', 'main': 'Sistema estable', 'style': 'good'},
        ],
        'hud': [('0', 'Instancias', ''), ('0 MB', 'Memoria', 't'), ('0', 'En IO Wait', '')],
        'rc': {
            'title': 'Lectura de la ventana',
            'body': 'No hubo falla. Hubo dos señales que conviene no perder de vista: concurrencia repetida de '
                    '<code>cons_sdos1</code> con espera de disco, y batch accediendo a la vista compartida.',
            'fixes': ['Ninguna acción urgente',
                      'Vigilar si la concurrencia crece',
                      'El acceso por vista hereda el double-scan'],
        },
    },
    'panel_r': {
        'badge': 'REF', 'badge_cls': 'pb-ok',
        'title': 'Uso como línea base',
        'sub': 'Qué convierte a esta ventana en referencia',
        'nodes': [
            {'top': '30 capturas de un minuto', 'main': 'Cobertura continua', 'style': 'good'},
            {'top': 'Sesiones por captura', 'main': '3,315 a 3,558', 'style': 'good'},
            {'top': 'Sesiones en ejecución', 'main': 'Promedio 8.2', 'style': 'good'},
            {'top': 'Sin lock waits', 'main': 'Sin contención observada', 'style': 'good'},
            {'top': 'Perfil de SPs dominantes', 'main': 'Familia sp_ics_* al frente', 'style': 'good'},
            {'top': 'Comparable contra', 'main': 'Cualquier ventana batch futura', 'style': 'good'},
        ],
        'hud': [('0', 'Capturas', 'g'), ('0', 'Sesiones', 'g'), ('0', 'Running', 'g')],
        'rc': {
            'title': 'Valor del registro',
            'body': 'Esta ventana fija el patrón de normalidad del batch nocturno. Sin ella, una cifra como '
                    '"ocho sesiones en ejecución" no significa nada.',
            'fixes': ['Referencia para detección de anomalías',
                      'Insumo del gemelo de telemetría'],
        },
    },
    'steps': [],
}


# ═════════════════════════════════════════════════════════════════════════════
# INC-013 — 2026-10-08 — Partición de clúster PowerHA y toma de control indebida
# ═════════════════════════════════════════════════════════════════════════════

INC_013 = {
    'slug':   'inc-013-powerha-split-toma-de-control',
    'folder': '2026-10-08',
    'inc':    'INC-013',
    'date_pill': '8 oct 2026',
    'headline': 'Duplicidad de la IP 10.36.197.51 entre POWER8 y POWER10, y partición del clúster',
    'subtitle': 'Diagnóstico de incidente en producción, 8 de octubre de 2026. Síntoma a las 12:32 CST, '
                'partición del clúster DCMSIF a las 12:44:19. Investigación abierta con el equipo de redes e IBM',
    'title': 'INC-013, duplicidad de IP y partición PowerHA, BanCoppel Informix, 8 octubre 2026',
    'metrics': [
        ('12:32',    'Falla el ping a la .51',   ''),
        ('2',        'vPC anunciando la misma IP', ''),
        ('12:44:19', 'Split del clúster',        'w'),
        ('3',        'Grupos de recursos tomados', 'w'),
        ('None',     'Política de partición',    ''),
        ('ABIERTA',  'Causa del disparador',     'i'),
    ],
    'impact': {
        'badge': 'N4 CRÍTICO',
        'items': [
            {'lbl': 'Causa identificada', 'val': 'IP 10.36.197.51 duplicada', 'val_cls': 'impact-crit',
             'sub': 'Aprendida simultáneamente en el vPC del POWER8 y en el del POWER10, mismo EPG'},
            {'lbl': 'Condición habilitante', 'val': 'Renumeración de clúster incompleta',
             'sub': 'La .51 fue la dirección de servicio del clúster viejo y el /etc/hosts conserva ambos juegos'},
            {'lbl': 'Síntoma en servicio', 'val': 'Pérdida de alcance a la .51 a las 12:32', 'val_cls': 'impact-crit',
             'sub': 'Es la dirección productiva del clúster nuevo, con la instancia Informix activa'},
            {'lbl': 'Efecto de segundo orden', 'val': 'Partición y toma de recursos',
             'sub': 'El clúster viejo pierde heartbeat a las 12:44 y toma tres grupos del nodo par'},
            {'lbl': 'Qué sigue abierto', 'val': 'Qué levantó la .51 en el POWER8', 'val_cls': 'impact-reg',
             'sub': 'Ventana 12:15 a 12:32. Sin evidencia de ese nodo. Casos abiertos con redes e IBM'},
        ],
    },
    'ctx': [
        {
            'title': 'La causa identificada, duplicidad de 10.36.197.51',
            'title_color': 'var(--err)',
            'style': 'background:#fff8f8; border-top:2px solid rgba(239,68,68,.25);',
            'cards': [
                {'num': 'A', 'reg': True, 'title': 'Lo que ve la fabric',
                 'body': 'El rastreador de endpoints de APIC muestra la misma dirección <code>10.36.197.51</code> '
                         'aprendida al mismo tiempo en <strong>dos vPC distintos</strong>: '
                         '<code>vPC_BC_IBMPower880</code>, que es el chasis POWER8, y '
                         '<code>vPC_BC_IBMPOWER10_Po3</code>, que es el POWER10. Mismo tenant, misma aplicación y '
                         'mismo EPG <code>EPG_1_USUARIOS</code>. Dos chasis anunciando la misma IP.'},
                {'num': 'B', 'title': 'Por qué esa dirección y no otra',
                 'body': 'La <code>10.36.197.51</code> <strong>fue la dirección de servicio del clúster viejo</strong>. '
                         'Su propia verificación la valida así en 2019: <code>DCMSIF01_SRV (10.36.197.51) PASS</code>. '
                         'En algún momento ese clúster se renumeró a <code>DCMSIF01_SRVN</code> en '
                         '<code>10.36.197.207</code>, y la .51 se reasignó al clúster nuevo. En la configuración '
                         'vigente al 7 de octubre de 2026 el clúster viejo ya no la menciona ni una vez.'},
                {'num': 'C', 'title': 'La condición habilitante',
                 'body': 'El <code>/etc/hosts</code> conserva los dos juegos de direcciones a la vez, y un bloque lo '
                         'rotula literalmente <code># IPs PowerHA Cluster (Migracion)</code>. La etiqueta '
                         '<code>DCMSIF01_SRV</code> sigue resolviendo a la .51 en dos bloques distintos, y '
                         '<code>DCMSIF01_TSRV</code> resuelve a dos direcciones diferentes según el bloque que se lea. '
                         'Cualquier script o alias del lado POWER8 que invoque esas etiquetas levanta la IP del otro servidor.'},
                {'num': '?', 'title': 'Lo que todavía no se sabe',
                 'body': 'Qué levantó la .51 en el POWER8 entre las <strong>12:15 y las 12:32</strong>. De ese nodo no '
                         'se recolectó ningún registro de autenticación ni de comandos, su <code>cluster.log</code> '
                         'dejó de escribirse a las 03:04 y sus trazas de clúster no tienen nada antes de las 12:44. '
                         'Es la pregunta que cierran los casos abiertos con redes e IBM.'},
            ],
            'foot': 'Fuente: capturas de APIC EP Tracker aportadas por el equipo de telecomunicaciones, '
                    '<code>clverify.log</code> del clúster DCMSIF, ODM <code>HACMPadapter</code> del 7-oct-2026 '
                    'y <code>/etc/hosts</code> respaldado por PowerHA.',
        },
        {
            'title': 'Contexto funcional, el efecto de segundo orden en el clúster',
            'cards': [
                {'num': '01', 'title': '¿Qué es el clúster DCMSIF?',
                 'body': 'Dos nodos AIX en PowerHA SystemMirror, <strong>DCMSIF01</strong> y <strong>DCMSIF02</strong>, '
                         'con <strong>tres redes de heartbeat independientes</strong> sobre en0, en1 y en2, más disco '
                         'de repositorio CAA con respaldo. El grupo productivo <code>DCMSIF1_RG</code> agrupa el '
                         'controlador <code>SIF_APP</code>, la dirección <code>DCMSIF01_SRVN</code> y 35 volume groups '
                         'de modo concurrente mejorado, entre ellos <code>ifx01vg</code>.'},
                {'num': '02', 'title': '¿Por qué no lo impidió nada?',
                 'body': 'El registro interno del gestor, recuperado del paquete FFDC, lo dice literalmente a las '
                         '12:44:49: <code>Split policy is None</code> y <code>quarantine=0</code>. '
                         'No hay política de partición ni tie breaker configurados. La isla que conserva el quórum '
                         'procede a tomar los recursos del otro <strong>sin ningún arbitraje</strong>.'},
                {'num': '03', 'title': '¿Por qué tardó casi ocho minutos?',
                 'body': 'La adquisición pasa los 34 volume groups de modo pasivo a activo de forma secuencial. '
                         '<code>ifx01vg</code> tarda <strong>71.5 segundos</strong> por sí solo. El umbral de alerta '
                         '<code>config_too_long</code> está en 360 segundos, por debajo del tiempo normal de la '
                         'operación que vigila, de modo que cualquier toma de control legítima lo dispara.'},
                {'num': '!', 'reg': True, 'title': '¿Por qué falló el release?',
                 'body': 'Al revertir, el clúster intentó detener Informix con <code>SIFHAOFF.sh</code>. El script '
                         'devolvió 1 con <code>shared memory not initialized for INFORMIXSERVER coppel_shm</code>. '
                         'La captura de procesos de las 12:50:59 confirma que no había ningún <code>oninit</code> en '
                         'ese nodo, y nunca se ejecutó <code>start_server</code>. Detener algo que no corre debería '
                         'ser éxito, no error.'},
            ],
        },
        {
            'title': 'Integridad de la evidencia, lo que el paquete no permite afirmar',
            'title_color': 'var(--ancla)',
            'style': 'border-top:2px solid rgba(18,47,177,.2);',
            'cards': [
                {'num': 'A', 'title': 'El paquete mezcla dos clústeres',
                 'body': 'La evidencia contiene artefactos del clúster <code>DCMSIF</code>, identificador 1471564138, '
                         'y del clúster <code>DCMSIF01_cluster</code>, identificador 1175813769, con nodos, redes, '
                         'grupos de recursos, volume groups y discos de repositorio <strong>completamente distintos</strong>. '
                         'Las carpetas venían rotuladas por dirección IP, lo que induce a tratarlas como dos nodos '
                         'del mismo clúster.'},
                {'num': 'B', 'title': 'No hay evidencia del nodo declarado caído',
                 'body': 'Del nodo DCMSIF01 del clúster DCMSIF no existe un solo archivo: ni logs de PowerHA, ni '
                         'reporte de errores, ni telemetría. <strong>Todo el incidente está documentado por el nodo que '
                         'tomó la decisión</strong>, que es la parte interesada.'},
                {'num': 'C', 'title': 'La telemetría disponible es de otra máquina',
                 'body': 'El único nmon del paquete pertenece al nodo <code>DCMSIF02N2</code> del clúster nuevo. '
                         'Su inventario de volume groups es la familia <code>vgifx*</code> y no contiene '
                         '<code>ifx01vg</code> ni ninguno de los <code>sif01vg</code> a <code>sif32vg</code>. '
                         'No describe a ninguno de los dos nodos del clúster que falló.'},
                {'num': '!', 'reg': True, 'title': 'Trampas de lectura detectadas',
                 'body': 'El <code>cluster.log</code> de AIX es acumulativo desde 2019 y el formato syslog no escribe '
                         'el año: filtrar por "Oct 8" mezcla 2023, 2024 y 2026. Y el archivo '
                         '<code>clverify.2026.10.08.*</code> no es una verificación de ese día; arrastra un error de '
                         'junio de 2019. Ambas produjeron conclusiones falsas en el primer análisis.'},
            ],
            'foot': 'Verificado contra los objetos <code>HACMPcluster</code>, <code>HACMPadapter</code>, '
                    '<code>HACMPnetwork</code> y <code>HACMPsircol</code> de cada bundle, y contra la sección '
                    '<code>VGSIZE</code> del archivo nmon.',
        },
        {
            'title': 'Siguientes pasos de la investigación',
            'title_color': '#166534',
            'style': 'background:#f0fdf4; border-top:2px solid rgba(34,197,94,.35);',
            'cards': [
                {'num': 'R1', 'title': 'Redes: historial del endpoint con direcciones MAC',
                 'body': 'La tabla <code>State Transitions</code> sale vacía en las dos capturas, y es justo donde '
                         'vive el historial. Se requiere el movimiento de la <code>10.36.197.51</code> el 8 de octubre '
                         'entre las <strong>11:45 y las 13:30</strong>, con las direcciones MAC de cada aprendizaje. '
                         'La MAC identifica qué adaptador físico reclamó la dirección, y con eso se cierra quién fue.'},
                {'num': 'R2', 'title': 'Redes: faults de endpoint y Rogue Endpoint Control',
                 'body': 'Se requieren los eventos de movimiento de endpoint y si se activó '
                         '<strong>Rogue Endpoint Control</strong> sobre ese EPG y esos dos vPC en la ventana. '
                         'Importa porque, si la fabric puso el endpoint en cuarentena, la acción pudo afectar al vPC '
                         'completo y no solo a la .51. Eso explicaría la pérdida de heartbeat de las 12:44 en las '
                         'redes 7.36.x, que no tienen relación con la dirección duplicada.'},
                {'num': 'R3', 'title': 'Redes: ¿se duplicaron también las otras dos?',
                 'body': 'Chequeo de alto valor y bajo esfuerzo. Si <code>10.36.198.51</code> y '
                         '<code>10.36.199.51</code> se duplicaron junto con la .51, el disparador levantó el juego '
                         'completo de etiquetas de migración, lo que apunta a un mecanismo de clúster o de arranque. '
                         'Si solo se duplicó la .51, apunta a una acción puntual.'},
                {'num': 'I1', 'reg': True, 'title': 'IBM: qué puede levantar DCMSIF01_SRV en el POWER8',
                 'body': 'Resource group residual, alias en <code>/etc/rc.net</code>, script de arranque o entrada '
                         'heredada. Junto con eso, los tres defectos de configuración que este análisis documenta y '
                         'que son hallazgos válidos para el mismo caso: <code>netmon.cf</code> vacío, política de '
                         'partición en <code>None</code> sin desempate, y <code>SIFHAOFF.sh</code> no idempotente.'},
            ],
            'foot': 'Pendiente además, del lado de la evidencia: el <code>/var/hacmp/</code> completo del nodo '
                    'DCMSIF01 del clúster 1471564138, la salida de <code>lscluster -i</code> y '
                    '<code>clctrl -tune -a</code> de ambos nodos, y los registros del VIOS y del switch para la '
                    'ventana de 12:15 a 13:05. Y la confirmación operativa de si <code>10.36.198.146</code> y '
                    '<code>10.36.199.129</code> fueron liberadas manualmente del nodo en espera.',
        },
    ],
    'findings': {
        'title': 'Hallazgos confirmados, red y configuración de clúster',
        'sub': 'evidencia 2026-10-08, APIC y bundles PowerHA',
        'rows': [
            {'badge': 'CAUSA', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'IP 10.36.197.51 duplicada', 'source': 'APIC EP Tracker, EPG_1_USUARIOS',
             'loc': '2 vPC', 'loc_cls': 'd05-rate-high',
             'desc': 'La misma dirección aprendida de forma simultánea en <code>vPC_BC_IBMPower880</code>, chasis '
                     'POWER8, y en <code>vPC_BC_IBMPOWER10_Po3</code>, chasis POWER10. El ping a la .51 empieza a '
                     'fallar a las <strong>12:32</strong>. Es la dirección productiva del clúster nuevo, con la '
                     'instancia Informix activa detrás.'},
            {'badge': 'HABILITANTE', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'Renumeración de clúster incompleta', 'source': '/etc/hosts y clverify histórico',
             'loc': 'DCMSIF01_SRV', 'loc_cls': 'd05-rate-high',
             'desc': 'La .51 fue la dirección de servicio del clúster viejo, validada como '
                     '<code>DCMSIF01_SRV (10.36.197.51) PASS</code> en 2019 y renumerada después a '
                     '<code>DCMSIF01_SRVN</code> en .207. El <code>/etc/hosts</code> conserva ambos juegos bajo un '
                     'bloque rotulado <code># IPs PowerHA Cluster (Migracion)</code>, y '
                     '<code>DCMSIF01_TSRV</code> resuelve a dos direcciones distintas según el bloque.'},
            {'badge': 'CRÍTICO', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'netmon.cf vacío en ambos nodos', 'source': '/usr/es/sbin/cluster/netmon.cf',
             'loc': '2 bytes', 'loc_cls': 'd05-rate-high',
             'desc': 'El archivo contiene un espacio y un salto de línea. Con redes de un solo adaptador por nodo, '
                     'sin objetivos en <code>netmon.cf</code> PowerHA no puede distinguir entre su propio adaptador '
                     'caído y el nodo remoto caído. La verificación del clúster lo marca como <code>FAIL</code> en '
                     'las tres redes y en los dos nodos, y lo viene marcando desde al menos 2019.'},
            {'badge': 'CRÍTICO', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'Política de partición en None, sin tie breaker', 'source': 'ODM HACMPsplitmerge',
             'loc': '12:44:49', 'loc_cls': 'd05-rate-high',
             'desc': '<code>split = None</code>, <code>merge = Majority</code>, <code>action = Reboot</code>, y la '
                     'consulta en runtime del desempate devuelve vacío. El gestor lo registra literalmente: '
                     '<code>Split policy is None</code>. Ante una partición, la isla con quórum procede a tomar los '
                     'recursos del par sin arbitraje alguno.'},
            {'badge': 'CRÍTICO', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'SIFHAOFF.sh, controlador SIF_APP', 'source': '/usr/es/sbin/cluster/scripts/',
             'loc': '12:53:08, rc=1', 'loc_cls': 'd05-rate-high',
             'desc': 'Devolvió <code>shared memory not initialized for INFORMIXSERVER coppel_shm</code> y código 1. '
                     'El paro no es idempotente: detener una instancia que no está corriendo se trata como error. '
                     'Consecuencia directa: <code>rg_move RELEASE</code> falló y el grupo quedó en <code>event_error</code>.'},
            {'badge': 'CRÍTICO', 'badge_cls': 'd05-badge-defecto',
             'artifact': 'Toma de control sin arranque de aplicación', 'source': 'PowerHA, rg_move ACQUIRE',
             'loc': '12:44:59 a 12:52:57', 'loc_cls': 'd05-rate-high',
             'desc': 'Se activaron 34 volume groups y se tomó la dirección de servicio productiva, pero no se ejecutó '
                     'ningún <code>start_server</code>. El nodo pasivo quedó con los datos montados y la IP tomada, '
                     'sin dar servicio. Expone sin sustituir.'},
            {'badge': 'ALTO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'Umbral config_too_long descalibrado', 'source': 'PowerHA, valor en runtime',
             'loc': '360 s', 'loc_cls': 'd05-rate-mid',
             'desc': 'La adquisición real tarda 478 segundos por la topología de 35 volume groups. El umbral está por '
                     'debajo del tiempo normal de la operación que vigila, de modo que siempre dispara y pierde valor '
                     'como señal. El valor 360 no existe en ningún objeto de configuración del bundle.'},
            {'badge': 'ALTO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'Reset de LUN sobre 86 discos', 'source': 'cl_fscsilunreset, fase de adquisición',
             'loc': 'SC_FORCED_OPEN_LUN', 'loc_cls': 'd05-rate-mid',
             'desc': 'No hubo forced varyon ni ruptura de reservas sobre los volume groups, pero sí reset de LUN con '
                     'apertura forzada sobre 86 discos. El emparejamiento disco a volume group dentro del script es '
                     'posicional y no de pertenencia real, por lo que no se puede descartar que discos de '
                     '<code>ifx01vg</code> lo recibieran.'},
            {'badge': 'ALTO', 'badge_cls': 'd05-badge-restrict',
             'artifact': 'Evidencia de dos clústeres mezclada', 'source': 'Paquete de recolección',
             'loc': 'DCMSIF y DCMSIF01_cluster', 'loc_cls': '',
             'desc': 'Las carpetas vienen rotuladas por dirección IP y pertenecen a clústeres distintos. No existe '
                     'ningún archivo del nodo que fue declarado caído. Toda la reconstrucción descansa en un solo '
                     'testigo, que es el nodo que tomó la decisión.'},
            {'badge': 'MEDIO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'Retención de clstrmgr.debug', 'source': 'log/clstrmgr.debug y 7 rotaciones',
             'loc': '3 min 17 s', 'loc_cls': '',
             'desc': 'Ocho copias cubren tres minutos diecisiete segundos en total, rotando cada 24 a 28 segundos. '
                     'La ventana del incidente se recuperó únicamente porque el paquete FFDC congeló una copia a las '
                     '12:50:59 que cubre de 12:40:54 en adelante, y la familia <code>.long</code> desde 12:23:15.'},
            {'badge': 'MEDIO', 'badge_cls': 'd05-badge-warn',
             'artifact': 'cluster.log mudo diez horas antes', 'source': 'adm/cluster.log',
             'loc': '03:04:16', 'loc_cls': '',
             'desc': 'El log que un operador consultaría primero dejó de escribirse el mismo día a las 03:04:16, casi '
                     'diez horas antes del incidente. En la captura de procesos conviven <code>syslogd</code> y '
                     '<code>rsyslogd</code>.'},
            {'badge': 'MEDIO', 'badge_cls': 'd05-badge-restrict',
             'artifact': '/var en umbral permanente', 'source': 'errpt, CL_VAR_FULL',
             'loc': '75%', 'loc_cls': '',
             'desc': 'Alertas desde el 2 de octubre, trece solo el 7 de octubre entre las 18:31 y las 23:48. '
                     'El mensaje advierte que RSCT puede fallar si <code>/var</code> se llena, de modo que el ruido '
                     'crónico es además un riesgo latente.'},
        ],
        'note': 'La causa del incidente es la duplicidad de la 10.36.197.51, habilitada por una renumeración de '
                'clúster que dejó el /etc/hosts con los dos juegos de direcciones. Lo que ocurre en el clúster a '
                'partir de las 12:44 es un efecto de segundo orden, y los tres defectos de configuración son lo que '
                'lo convirtió en una toma de control con reversión fallida. Esos tres son corregibles de inmediato y '
                'con independencia de lo que resuelvan los casos abiertos con redes e IBM.',
    },
    'sim': None,
    'timeline': {
        'title': 'Línea de tiempo, de la causa a la remediación. Escala 12:15 a 14:01 CST',
        'rows': [
            {'lbl': 'Ventana del disparador, 12:15 a 12:32. Sin evidencia', 'cls': 'tl-amber', 'color': 'var(--amber)'},
            {'lbl': 'Síntoma: falla el ping a la .51, 12:32', 'cls': 'tl-err', 'color': 'var(--err)'},
            {'lbl': 'Reacción humana, 12:34:08 a 12:43', 'cls': 'tl-amber', 'color': 'var(--amber)'},
            {'lbl': 'Segundo orden: split y toma de recursos, 12:44:19 a 12:55:12', 'cls': 'tl-err', 'color': 'var(--err)'},
            {'lbl': 'Remediación: apagado del POWER8, posterior a las 14:01', 'cls': 'tl-ok', 'color': 'var(--ok)'},
        ],
        'markers': ['12:15', '12:32', '12:34', '12:44', '12:55', '13:17', '13:45', '14:01'],
    },
    'panel_l': {
        'badge': 'OBS', 'badge_cls': 'pb-err',
        'title': 'Secuencia observada',
        'sub': 'Reconstruida desde el historial de eventos de DCMSIF02',
        'nodes': [
            {'top': '12:15 a 12:32, sin evidencia', 'main': 'Algo levanta la .51 en el POWER8', 'style': 'danger',
             'note': 'caso', 'note2': 'abierto', 'note_color': '#94a3b8'},
            {'top': 'APIC, EPG_1_USUARIOS', 'main': 'Misma IP en dos vPC', 'style': 'danger',
             'note': 'P8', 'note2': 'y P10', 'note_color': '#ef4444'},
            {'top': '12:32, síntoma en servicio', 'main': 'Falla el ping a 10.36.197.51', 'style': 'danger'},
            {'top': '12:44:19, clúster viejo', 'main': 'Split detectado, dos islas', 'style': 'danger'},
            {'top': '12:44:49, gestor de clúster', 'main': 'Split policy is None', 'style': 'danger',
             'note': 'sin', 'note2': 'arbitraje', 'note_color': '#ef4444'},
            {'top': '12:44:59 a 12:55:12', 'main': '3 grupos tomados, release falla', 'style': 'danger',
             'note': 'rc=1', 'note2': 'event_error', 'note_color': '#ef4444'},
        ],
        'hud': [('0', 'Chasis con la IP', ''), ('0', 'VGs movidos', 't'), ('0', 'Eventos fallidos', '')],
        'rc': {
            'title': 'Causa, efecto y lo que sigue abierto',
            'body': 'La causa es la duplicidad de la <code>10.36.197.51</code> entre el POWER8 y el POWER10, '
                    'habilitada por una renumeración de clúster que dejó el <code>/etc/hosts</code> con los dos '
                    'juegos de direcciones. Lo que ocurre desde las 12:44 en el clúster viejo es efecto de segundo '
                    'orden. Sigue abierto qué levantó la dirección en el POWER8.',
            'fixes': ['El apagado del POWER8 fue remediación, posterior a las 14:01',
                      'Los VGs volvieron a modo pasivo, no quedaron activos',
                      'Los defectos de configuración son corregibles ya'],
        },
    },
    'panel_r': {
        'badge': 'REM', 'badge_cls': 'pb-ok',
        'title': 'Con la remediación propuesta',
        'sub': 'Cuatro correcciones, cada una corta la cadena en un punto distinto',
        'nodes': [
            {'top': 'Saneo de /etc/hosts en los 4 nodos', 'main': 'Un solo juego de direcciones', 'style': 'good'},
            {'top': 'Retiro de etiquetas de migración', 'main': 'DCMSIF01_SRV ya no resuelve a la .51', 'style': 'good'},
            {'top': 'netmon.cf poblado', 'main': 'El nodo valida si la falla es suya', 'style': 'good'},
            {'top': 'Política de partición y desempate', 'main': 'Gana quien ya tiene el grupo', 'style': 'good'},
            {'top': 'Umbral calibrado a la topología', 'main': 'config_too_long deja de ser ruido', 'style': 'good'},
            {'top': 'SIFHAOFF.sh idempotente', 'main': 'Sin event_error residual', 'style': 'good'},
        ],
        'hud': [('0', 'Chasis con la IP', 'g'), ('0', 'VGs movidos', 'g'), ('0', 'Eventos fallidos', 'g')],
        'rc': {
            'title': 'Qué corta la cadena, y en qué orden',
            'body': 'Las dos primeras atacan la causa: mientras el <code>/etc/hosts</code> siga con los dos juegos de '
                    'direcciones, la duplicidad puede repetirse. Las cuatro siguientes atacan el efecto de segundo '
                    'orden y son independientes de lo que resuelvan redes e IBM, de modo que no hay razón para '
                    'esperar a cerrarlos.',
            'fixes': ['Prioridad uno: un solo juego de direcciones por clúster',
                      'Prioridad dos: política de partición con desempate',
                      'Verificar si .198.51 y .199.51 también se duplicaron'],
        },
    },
    'steps': [],
}


INC_011['sim'],   INC_011['steps'] = SIM_011, STEPS_011
INC_012['sim'],   INC_012['steps'] = SIM_012, STEPS_012
INC_013['sim'],   INC_013['steps'] = SIM_013, STEPS_013

INCIDENTS = [INC_011, INC_012, INC_013]
