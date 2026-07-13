CREATE PROCEDURE "informix".sp_consultas_cac_central_pba2(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4)
                                                     )
RETURNING
          CHAR(6),          -- Código de Retorno
          CHAR(80),         -- Mensaje de Retorno		 
          CHAR(20),         -- Número de Solicitud
          CHAR(20),         -- Número de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a Sección
          DECIMAL(5,2),     -- Puntos 2da Sección
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2),     -- Suma de Secciones
		  CHAR(3);          -- Causa del Status


DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa					CHAR(3);
DEFINE dECValor1					DECIMAL(5,2);
DEFINE dECValor2					DECIMAL(5,2);
DEFINE dMACValor1					DECIMAL(5,2);
DEFINE dMACValor2					DECIMAL(5,2);
DEFINE dPSValor1					DECIMAL(5,2);
DEFINE dPSValor2					DECIMAL(5,2);

DEFINE iMeseshist               INTEGER;
DEFINE cProducto               CHAR(4);



LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa						= '';
LET dECValor1					= 0.0;
LET dECValor2					= 0.0;
LET dMACValor1				= 0.0;
LET dMACValor2				= 0.0;
LET dPSValor1					= 0.0;
LET dPSValor2					= 0.0;
LET iMeseshist               = 0;
LET cProducto               = "";


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selección principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreón
--07/06/ 2010
--Comentarios: se agregó la causa del status y los filtros para los criterios del cac y mc.

--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validación de eficiencia, meses de historia y puntuación scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'');
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizó la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;


IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

    SELECT valor1,valor2
      INTO dECValor1,dECValor2
      FROM bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    SELECT valor1,valor2
      INTO dMACValor1,dMACValor2
      FROM  bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
    SELECT valor1,valor2
      INTO dPSValor1,dPSValor2
      FROM  bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "03";
END IF;


FOREACH
    -- Se obtienen los datos de la solicitud.
     SELECT {+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes3)}
            sol.num_solicitud,         -- Número de Solicitud
            sol.numcte,                -- Número Cte
            sol.sucursal,              -- Sucursal
            sol.status_solicitud,      -- Status Solicitud
            sol.tipo_solicitud,        -- Tipo Solicitud
            sol.monto_solicitado,      -- Monto Solicitado
            sol.fecha_insert,          -- Fecha Insert
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima Autorización
                 THEN NVL(aut.fecha_entrada,date(1))
                 ELSE NVL(esp.fecha_modif,date(1))
            END),
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de Autorización
                 THEN NVL(aut.comentario,"")
                 ELSE NVL(esp.comentario,"")
            END),
            NVL(aut.revision_cac,0),
	    aut.causa_solicitud,
		sol.num_producto
       INTO cNumSolicitud,
            cNumCte,
            cSucursal,
            cStatusSol,
            cTipoSolicitud,
            dMontoSolicitado,
            dtFechaInsert,
            dtFechaModificacion,
            cComentarioAut,
            iRevisionCac,
			cCausa,
			cProducto
      FROM bdisolic:"informix".ss_solicitudes sol
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
                                                          AND aut.empresa= sol.empresa
                                                          AND aut.status_solicitud= sol.status_solicitud
                                                          AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                                                                   FROM bdisolic:"informix".ss_autorizacion aut_aux
                                                                                   WHERE aut_aux.empresa= sol.empresa
                                                                                   AND aut_aux.num_solicitud= sol.num_solicitud
                                                                                   AND aut_aux.status_solicitud= sol.status_solicitud)
                                                          AND aut.ejecutivo_auto= aut.ejecutivo_auto)
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
                                                                   AND esp.num_solicitud= sol.num_solicitud
                                                                   AND esp.numcte=sol.numcte
                                                                   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
                                                                                         FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
                                                                                        WHERE esp_aux.empresa= sol.empresa
                                                                                          AND esp_aux.num_solicitud= sol.num_solicitud
                                                                                          AND esp_aux.numcte= sol.numcte)
                                                                   AND sol.status_solicitud= esp.status_nvo)
      Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
	LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
     WHERE sol.num_solicitud= (CASE WHEN pNumSol IS NULL THEN sol.num_solicitud ELSE pNumSol END)
       ---AND sol.empresa= pEmpresa
       AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opción de la consulta es CAC, si es asi tendrian que ser solo status "RT"
       AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
       ---AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
       AND sol.sucursal between '0000' and '9760'
       AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
			AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
		AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

		AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
		AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
		AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

    -- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
    -- En caso contrario no se mostraria en la consulta.

       IF cStatusSol IN ('CC','BC') THEN
            SELECT COUNT(*)
              INTO iInfoBuro
              FROM bdiburo:"informix".br_traslado AS tras
              INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
			  WHERE tras.num_solicitud = cNumSolicitud;

             IF NVL(iInfoBuro,0) = 0 THEN

				SELECT COUNT(*)
                INTO iInfoBuro
                FROM bdiburo:"informix".br_traslado AS tras
                INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
                WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
				   CONTINUE FOREACH;
                END IF;

			 END IF;

       END IF;

    -- Se obtienen los datos de la información crediticia en COPPEL/BANCOPPEL.

               SELECT ef.situacion_pago,         -- Situacion Pago
                       ef.meses_historia          -- Meses Historia
                  INTO dSituacionPago,
                       iMesesHistoria
                  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
                 WHERE ef.empresa= pEmpresa
                   AND ef.num_solicitud= cNumSolicitud;
				   
				   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÉDITO

                  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
                    CONTINUE FOREACH;
                  END IF;

                IF NVL(pArea, "") <> "" THEN

                      IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
                               (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

                            CONTINUE FOREACH;
                  END IF;

    END IF;
    -- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
    SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
           NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
           NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
           COUNT(num_solicitud) AS cantidad
      INTO dSeccion1,    
           dSeccion2,
           dSumaSecciones,
           iCantidad
      FROM bdisolic:"informix".ss_resumen_scoring
     WHERE empresa= pEmpresa
       AND num_solicitud = cNumSolicitud
       AND seccion IN ('1','2');

    IF iCantidad <> 2 THEN

           LET dSeccion1= 0;
           LET dSeccion2= 0;
           LET dSumaSecciones= 0;

        SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
               COUNT(*) AS cuantos
          INTO dSeccion1, icuantos
          FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
         WHERE rsf.empresa = pEmpresa
           AND rsf.num_solicitud = cNumSolicitud
           AND rsf.empresa = sf.empresa
           AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
           AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
           AND sf.min_mes_hist <= rsf.meses_historia
           AND sf.max_mes_hist >= rsf.meses_historia
           AND sf.min_porc_pago <= rsf.situacion_pago
           AND sf.max_porc_pago >= rsf.situacion_pago;

       FOREACH
            SELECT sg.empresa, sg.seccion,
                   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
              INTO cEmpAux, iSecAux, dSeccionAux
              FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
             WHERE sg.empresa = dc.empresa
               AND sg.grupo = dc.grupo
               AND sg.seccion = dc.seccion
               AND dc.num_solicitud = cNumSolicitud
               AND dc.seccion = '2'
               AND dc.empresa = pEmpresa
          GROUP BY sg.empresa, sg.seccion, sg.agrupar

            LET dSeccion2= dSeccion2 + dSeccionAux;
            LET dSumaSecciones= dSeccion1 + dSeccion2;
   END FOREACH;

   END IF;

   IF NVL(pArea,"") <> "" THEN
        IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
                CONTINUE FOREACH;
        END IF;
   END IF;

 -- Se obtiene el nombre del cliente
    SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                              TRIM(nvl(a.nombre2,'')) ||' '||
                                              TRIM(nvl(a.apell_paterno,'')) ||' '||
                                              TRIM(nvl(a.apell_materno,'')),
                                              TRIM(a.razon_social)),
           rfc
      INTO cNombreCte, cRFC
      FROM bdinteg:"informix".si_cliente a
     WHERE a.numcte = cNumCte;


    RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'') WITH RESUME;

END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'las consultas del Aplicativo CConCac en el central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/01/2009',
'BD    : BDICRED',

'DESCRIPCION: Se modifíca para que se haga un fíltro más ahora por  --- Producto --- ', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 08 de Agosto del 2012',
'VERSION: 20120808.1748',


'DESCRIPCION: Se modifíca para que valide si se encuentra el cliente  o no en la tabla " ss_resum_scor_fin " de , todos modos regrese la información debida', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 04 de septiembre del 2012',
'VERSION: 20120904.1640';

create procedure "informix".liberasalret_pba(pempresa char(3), pejecutivo char(10))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret        integer;
    define vdia_res         integer;
    define vmonto           money(14,2);
    define vfecha_alta      date;
    define vnum_chq         integer;
    define vtransacc        char(4);
    define vmonto_ori       money(14,2);
    define vnumero          char(4);
    define vsistema         char(2);
    define vfecha_hoy       date;
    define vfecha_ant       date;
    define vfechab_ant      date;
    define vcuenta          char(20);
    define vcancelado       char(1);
    define vrowid           integer;
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vconproc         integer;
    define vproceso         char(20);
    define vexiste          integer;
    define vexistefin       integer;
    define vRetenido        DECIMAL(14,2);
    define vabierto         CHAR(1);
    define vcomienza        INTEGER;
    define vsql             char(600);
    define vstmt            char(250);
    define vmincta          char(20);
    define vmaxcta          char(20);
    define vexisteproc      char(12);
    define vcodretsbg1      char(5);
    define vcodretsbg2      char(5);
    define vcontsbg1        integer;
    define vcontsbg2        integer;
    define vcodret_libinterpza  char(5);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vconproc  = 0;
    let vproceso  = "libsalretchq";
    let vsistema  = "01";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vsql      = '';
    let vstmt     = '';
    let vcodretsbg1 = '';
    let vcodretsbg2 = '';
    let vcontsbg1   = 0;
    let vcontsbg2   = 0;
    let vcodret_libinterpza = '';

    --- set debug file to "liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'C'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
            
            if vabierto = "1" then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant 
      from sc_fechas  
     where empresa = pempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    select proceso
      into vexisteproc
      from sc_contproc
     where empresa = pempresa
       and proceso = 'cierre'
       and fecha = vfecha_ant;
    
    if vexisteproc is null or vexisteproc = '' then
        let vcodret = "962";       
        return vcodret;
    END IF
    
    -- // VERIFICA CONTROL DE PROCESOS EN INTEGRAL
    select count(*)   
      into vexiste
      from bdinteg:sx_contproc  
     where empresa = pempresa  
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        let vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||pejecutivo||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
    else
        select count(*)   
          into vexistefin
          from bdinteg:sx_contproc  
         where empresa     = pempresa  
           and proceso     = vproceso
           and fecha       = vfecha_hoy
           and sistema     = vsistema
           and status_proc = "F"; 

        if vexistefin = 0 then
            let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'I'||''', '||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
        else
            let vcodret = "971";
            
            -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
            select count(*) 
              into vconproc
              from sc_contproc
             where empresa = pempresa
               and proceso = vproceso
               and fecha = vfecha_hoy;

            if vconproc > 0 then
                if vabierto = 1 then
                    ROLLBACK WORK;  
                end if;
                
                return vcodret;
            end if;     
        end if
    end if; 
    
    execute procedure cal_habil_ant(vfecha_hoy) 
    into vcodret, vfechab_ant;

    if vcodret <> "000" then
        if vabierto = 1 then
            ROLLBACK WORK;  
        end if;
        
        let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||pejecutivo||''', '||
                   'status_proc   = '''||'C'||''', '||
                   'codret        = '''||vcodret||''', '||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
        
        return vcodret;
    end if;  

    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
    
    foreach principal with hold for
        select numero
          into vnumero
          from bdinteg:si_transacc
         where empresa = pempresa
           and sistema = "01"
           and numero like "08%"
           and tipo_tran in ("20","21","22")
           and naturaleza = "C"
         order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   rowid, cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori
              into vrowid, vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori
              from sc_docret
             where cuenta between vmincta and vmaxcta
               and transacc = vnumero
               and cancelado = 'P'
               and (vfecha_hoy - fecha_alta) >= dias_ret 
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET vabierto = "1";
            END IF;
            
            SELECT sdo_retenido
              INTO vRetenido
              FROM sc_maechq
             where empresa = pempresa
               and cuenta = vcuenta;

            LET vRetenido = vRetenido - vmonto;	

            IF vRetenido >= 0 THEN
                update sc_maechq
                   set sdo_retenido = sdo_retenido - vmonto
                 where empresa = pempresa
                   and cuenta = vcuenta;
            END IF
            
            update {+INDEX(sc_docret idx_docret2)} sc_docret
               set cancelado = "L",
                   dias_ret = 0
             where cuenta = vcuenta
               and transacc = vtransacc
               and cancelado = 'P'
               and rowid = vrowid;
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    -- // REALIZA LIBERACION DE RETENIDOS INTERPLAZA
    execute procedure "informix".sp_liberaretinterpza(pempresa)
    into vcodret_libinterpza;
    
    -- // REALIZA COBRO DE SOBREGIROS
    execute procedure "informix".sp_cobrosbg(pempresa)
    into vcodretsbg1, vcodretsbg2, vcontsbg1, vcontsbg2;

    -- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa
       and proceso = vproceso;

    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||pejecutivo||''', '||
               'status_proc   = '''||'F'||''', '||
               'codret        = '''||vcodret||''', '||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
    SYSTEM vstmt;
    
    return vcodret;

    END;

end procedure;