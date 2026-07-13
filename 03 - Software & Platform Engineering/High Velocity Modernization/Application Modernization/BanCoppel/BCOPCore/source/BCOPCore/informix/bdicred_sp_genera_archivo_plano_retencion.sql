CREATE PROCEDURE "informix".sp_genera_archivo_plano_retencion()			 
RETURNING 
	CHAR(5) AS codRet;
	-- *                        DEFINICION DE VARIABLES                           *
	DEFINE vCodRet 						CHAR(5);
	DEFINE vRuta						VARCHAR(100);
	DEFINE sNombreArchivoFinal          VARCHAR(250);
	DEFINE cRutaFinal		            VARCHAR(110);
	DEFINE vFechaHoy				 	DATE;
	DEFINE vFechaPriDiaMes			 	DATE;
	DEFINE cFechaHoy			 		CHAR(12);
	DEFINE cFechaPriDiaMes			 	CHAR(12);
	DEFINE cSQLQuestion					CHAR(40);
	DEFINE vsSQL 						CHAR(2950);
	DEFINE vsSQL1 						CHAR(300);
	DEFINE vsSQL2 						CHAR(2450);
	DEFINE vsSQL3 						CHAR(200);
	DEFINE iSqlErr                      INTEGER;
	DEFINE iSamErr                     	INTEGER;
	-- *                        ASIGNACION DE VARIABLES                           *
	LET vCodRet	= '00000';
	LET vRuta	= '';
	LET sNombreArchivoFinal	= '';
	LET cRutaFinal	= '';
	LET vFechaHoy	= DATE(1);
	LET vFechaPriDiaMes	= DATE(1);
	LET cFechaHoy  = '';
	LET cFechaPriDiaMes	= '';
	LET cSQLQuestion	= '';
	LET vsSQL	= '' ;
	LET vsSQL1	= '' ;
	LET vsSQL2	= '' ;
	LET vsSQL3	= '' ;
	LET iSqlErr	= 0;
	LET iSamErr	= 0;
	--
	BEGIN
		-- 
		ON EXCEPTION SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
			END IF;
			RETURN vCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_genera_archivo_plano_retencion.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT valor INTO vRuta FROM bdinteg:si_param where cod_param=503;
		
		IF NVL(vRuta,'') = '' THEN
			LET vCodRet = '00002';
			RETURN vCodRet;
		ELSE
			SELECT fecha_hoy,pri_dia_mes INTO vFechaHoy,vFechaPriDiaMes FROM bdicred:sd_fechas;
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				LET vCodRet = '00002';
			ELSE
				LET cFechaHoy = "'" || YEAR(vFechaHoy) || "-" || LPAD(MONTH(vFechaHoy),2,0) ||"-"|| LPAD(DAY(vFechaHoy),2,0) || "'";
				IF vFechaHoy = vFechaPriDiaMes THEN 
					LET cSQLQuestion = "= " || cFechaHoy; 
				ELSE
					LET cFechaPriDiaMes = "'" || YEAR(vFechaPriDiaMes) || "-" || LPAD(MONTH(vFechaPriDiaMes),2,0) || "-" || LPAD(DAY(vFechaPriDiaMes),2,0) || "'";
					LET cSQLQuestion = "BETWEEN " || cFechaPriDiaMes || " AND " || cFechaHoy;
				END IF;
				
				LET cRutaFinal  = '/RESPALDOS'|| TRIM(vRuta) ||'/';
				LET sNombreArchivoFinal = cRutaFinal || 'Motivos_Cancelacion_Folios_' || YEAR(vFechaHoy)||""||LPAD(MONTH(vFechaHoy),2,0)||""||LPAD(DAY(vFechaHoy),2,0) ||'.txt';
				LET vsSQL1 = ' echo "UNLOAD TO ' || "'" || sNombreArchivoFinal || "'" || ' DELIMITER ' || '''|''';
				LET vsSQL2 = "SELECT "  ||
								"RPAD(sdbitret.num_credito,12,' '), RPAD(NVL(sdtar.num_tarjeta,''),16,' '), RPAD(sdbitret.numcte,9,' '), RPAD((CASE WHEN NVL(sddef.num_producto,'') = '' THEN '' ELSE sddef.num_producto||' '||NVL(sddef.nombre_prod,'') END),45,' '), RPAD(NVL(sdmae.fecha_apertura,''),10,' '), RPAD(NVL(sicte.fecha_nac,''),10,' '), RPAD(NVL(siest.siglas,''),4,' '), RPAD(NVL(sicat.municipiozona,''),40,' '), RPAD(sdbitret.fecha,10,' ')," || 
								" RPAD(NVL(sdbitret.motivo,''),50,' '), RPAD(NVL(sdcrecan.folio_cancelacion,''),16,' '), RPAD(NVL(sdcteret.folio,''),16,' '), RPAD(NVL(sdbitret.sucursal,''),4,' ')," || 
								" CASE" || 
									" WHEN (sdcteret.semaforo = '1') THEN '0'" || 
									" WHEN (sdcteret.semaforo = '3') THEN '1'" || 
									" WHEN (sdcteret.semaforo = '5') THEN '2'" || 
									" ELSE ' '" || 
								" END, NVL(sdcteret.semaforo,' '), RPAD(NVL(sdbitret.hora_ini,''),10,' '), RPAD(NVL(sdbitret.hora_fin,''),10,' ')" || 
							 " FROM " || 
								 "bdicred:sd_bitacora_retencion sdbitret LEFT OUTER JOIN bdicred:sd_maecred sdmae ON (sdmae.numcte = sdbitret.numcte AND sdmae.num_credito = sdbitret.num_credito)" || 
								 " LEFT OUTER JOIN bdicred:sd_ctes_retencion sdcteret ON (sdcteret.numcte = sdmae.numcte AND sdcteret.num_credito = sdmae.num_credito)" || 
								 " LEFT OUTER JOIN bdicred:sd_definicion sddef ON (sddef.empresa = sdmae.empresa AND sddef.num_producto = sdmae.num_producto)" || 
								 " LEFT OUTER JOIN bdicred:sd_tarjeta sdtar ON (sdtar.empresa = sdmae.empresa AND sdtar.numcte = sdmae.numcte AND sdtar.num_credito = sdmae.num_credito AND sdtar.tipo_tarjeta = 'T' AND sdtar.secuencia = (SELECT MAX(sdtarj.secuencia) FROM bdicred:sd_tarjeta sdtarj WHERE sdtarj.empresa = sdmae.empresa AND sdtarj.numcte = sdmae.numcte AND sdtarj.num_credito = sdmae.num_credito AND sdtarj.tipo_tarjeta = 'T'))" || 
								 " LEFT OUTER JOIN bdicred:sd_cred_can sdcrecan ON (sdcrecan.empresa = sdmae.empresa AND sdcrecan.num_cte = sdmae.numcte AND sdcrecan.num_credito = sdmae.num_credito)" || 
								 " LEFT OUTER JOIN bdinteg:si_ctepf sicte ON (sicte.empresa = sdmae.empresa AND sicte.numcte = sdmae.numcte)" || 
								 " LEFT OUTER JOIN bdinteg:si_direcciones_actual sidiract ON (sidiract.numcte = sdmae.numcte AND sidiract.tipo_dir = 1)" || 
								 " LEFT OUTER JOIN bdinteg:si_estados siest ON (siest.pais = sidiract.pais AND siest.estado = sidiract.estado)" || 
								 " LEFT OUTER JOIN bdinteg:si_catzonas sicat ON (sicat.numerociudad = sidiract.numerociudad AND sicat.numerocolonia = sidiract.numerocolonia)" || 
							 " WHERE " || 
								"sdbitret.estatus = 1 AND sdbitret.fecha " || TRIM(cSQLQuestion) || 
							 " ORDER BY sdbitret.sucursal,sdbitret.fecha;";
				
				LET vsSQL3 = ' " > ' || cRutaFinal || 'Ejecutageneraarchivoplanoretencion.sql';
				LET vsSQL = TRIM(vsSQL1) || ' '  || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
				SYSTEM vsSQL;

				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdicred ' || cRutaFinal || 'Ejecutageneraarchivoplanoretencion.sql';
				SYSTEM vsSQL;
				
				LET vsSQL = '';
				LET vsSQL =  "rm " || cRutaFinal || "Ejecutageneraarchivoplanoretencion.sql";
				SYSTEM vsSQL;
				
			END IF;
		END IF;
		
		RETURN vCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Cordova Ramirez',
'DESCRIPCION: Realiza una consulta, genera un archivo plano en formato .txt y retorna un codigo de retorno exitoso en caso se genere el archivo .txt exitosamente', 
'Codigo de retorno 00002 indica que no se encontraron datos en las tablas correspondientes',
'FECHA : 15/Octubre/2021',
'BD    : BDICRED',
'SOLICITO: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_inserta_bitacora_rentencion(pSucursal CHAR(4), pEjecutivo CHAR(8), pNumcte CHAR(9),pNumCredito CHAR(12),pFecha DATE, pHoraIni CHAR(19), pHoraFin CHAR (19), pMotivo CHAR(50), pEstatus CHAR(1))
RETURNING CHAR(5) AS codRet;
	-- VARIABLES --
	DEFINE vCodRet	CHAR(5);
	DEFINE iSqlErr 	  INTEGER; 
    DEFINE iIsamErr   INTEGER;
	-- ASIGNACION DE VARIABLES --
	LET vCodRet    = '00000';
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	
	BEGIN	
		-- MANEJO DE EXCEPCIONES --
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				LET vCodRet = iSqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_inserta_bitacora_rentencion.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pSucursal,'')) = '' OR TRIM(NVL(pEjecutivo,'')) = '' OR TRIM(NVL(pNumcte,'')) = '' OR pFecha IS NULL OR TRIM(NVL(pHoraIni,'')) = '' OR TRIM(NVL(pHoraFin,'')) = '' OR TRIM(NVL(pEstatus,'')) = '' THEN 
		LET vCodRet = '00001';
		RETURN vCodRet;
	ELSE
		IF pEstatus = '1' OR pEstatus = '2' THEN
			IF (TRIM(NVL(pNumCredito,'')) = '' OR TRIM(NVL(pMotivo,'')) = '') AND pEstatus = '1' THEN 
				LET vCodRet = '00001';
			ELSE
				INSERT INTO "informix".sd_bitacora_retencion(sucursal, ejecutivo, numcte, num_credito, fecha, hora_ini, hora_fin, motivo, estatus) 
				VALUES(pSucursal, pEjecutivo, pNumcte, TRIM(NVL(pNumCredito,'')), pFecha, pHoraIni, pHoraFin, TRIM(NVL(pMotivo,'')), pEstatus);
			END IF;
		ELSE
			LET vCodRet = '00002';
		END IF;
	END IF;
	
	RETURN vCodRet;
	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Cordova Ramirez', 
'DESCRIPCION: Inserte registros en la tabla sd_bitacora_retencion, validando los parametros de entrada',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalido',
'Codigo de retorno 00002 indica que se ha enviado un status diferente de 1 y 2 , el cual es invalido',
'FECHA : 30/Septiembre/2021',
'BD    : BDICRED',
'SOLICITO: Abraham Narvaez';

CREATE PROCEDURE "informix".cartera_con_atraso(pempresa     CHAR(3),
			    pfechaini    DATE,
			    pfechafin    DATE)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Credito
          CHAR(4),       -- Sucursal
	  CHAR(40),      -- Nombre Sucursal
          CHAR(104),     -- Nombre del Cliente
          CHAR(13),      -- Telefono1
          CHAR(13),      -- Telefono2
          CHAR(13),      -- Telefono3
          DATE,          -- Fecha Ultimo Pago
          MONEY(14,2),	 -- Importe Ultimo Pago
          MONEY(14,2),	 -- Saldo Total Adeudado
          MONEY(14,2),	 -- Pago Minimo
          MONEY(14,2),	 -- Saldo Adeudos Traspasados
          MONEY(14,2),	 -- Saldo Adeudos Transitorios
          MONEY(14,2),	 -- Saldo Vencido
          CHAR(5),	 -- Extension
          SMALLINT;	 -- Pagos Vencidos


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vsqlerr            INTEGER;
DEFINE scod_ret           CHAR(5);
DEFINE s_numcred          CHAR(20);
DEFINE s_sucursal         CHAR(4);
DEFINE s_nomsuc           CHAR(40);
DEFINE s_nombrecte        CHAR(104);
DEFINE s_telefono1        CHAR(13);
DEFINE s_telefono2        CHAR(13);
DEFINE s_telefono3        CHAR(13);
DEFINE s_fecha_ult_pago   DATE;
DEFINE s_monto_ult_pago   MONEY(14,2);
DEFINE s_sdo_total        MONEY(14,2);
DEFINE s_pago_minimo      MONEY(14,2);
DEFINE s_sdo_traspasados  MONEY(14,2);
DEFINE s_sdo_transitorios MONEY(14,2);

DEFINE s_saldo_vencido    MONEY(14,2);
DEFINE s_extension	  CHAR(5);
DEFINE s_pagos_vencidos   SMALLINT;

DEFINE s_numcte        CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE s_fecha_cuota   DATE;
define vnumcte			char(20);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET scod_ret           = "000";
LET vsqlerr            = 0;
LET s_numcte           = "";
LET v_cuantos          = 0;

LET s_numcred          = "";
LET s_sucursal         = "";
LET s_nomsuc           = "";
LET s_nombrecte        = "";
LET s_telefono1        = "";
LET s_telefono2        = "";
LET s_telefono3        = "";
LET s_fecha_ult_pago   = "";
LET s_monto_ult_pago   = 0;
LET s_sdo_total        = 0;
LET s_pago_minimo     = 0;
LET s_sdo_traspasados  = 0;
LET s_sdo_transitorios = 0;
LET s_fecha_cuota      = "";

LET s_saldo_vencido    = 0;
LET s_extension	       = 0;
let vnumcte= '';
LET s_pagos_vencidos   = 0;


--scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
--s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios
--s_saldo_vencido,s_extension,s_pagos_vencidos




-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
             s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios,
             s_saldo_vencido,s_extension,s_pagos_vencidos;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/credito/basura/cartera_con_atraso.out";
-- TRACE ON;
 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

let pempresa = pempresa;
let pfechafin = pfechafin;
let pfechaini  = pfechaini;


   -- Carga la Fecha del Dia
   
   SELECT fecha_hoy 
     INTO vfecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = pempresa;
     


      FOREACH 	
	SELECT
            a.numcte,a.num_credito, a.sucursal,
            b.nombre,     
            trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno),
           -- nvl(d.telefono1," "), nvl(d.telefono2," "), nvl(d.telefono3," "), nvl(d.extension," "),
            (nvl(e.sdo_cap_insoluto,"0")), nvl(mto_venc_trasp,"0"), nvl(monto_vencido,"0"), nvl(monto_financiado,"0")
	INTO
            vnumcte,s_numcred,s_sucursal,
            s_nomsuc,
            s_nombrecte,
            --s_telefono1,s_telefono2,s_telefono3,s_extension,
            s_sdo_total, s_sdo_traspasados,s_sdo_transitorios,s_pago_minimo
        FROM
            bdicred:sd_maecred a,   
            bdinteg:si_sucursales b,   
            bdinteg:si_cliente c,
            --bdinteg:si_direcciones d,
            bdicred:sd_maesdos e   
	WHERE
            a.empresa = c.empresa  
        AND (a.fecha_apertura >= pfechaini AND a.fecha_apertura <= pfechafin)
        AND a.numcte = c.numcte   
        AND a.empresa = b.empresa
        AND a.sucursal = b.sucursal
        AND e.num_credito = a.num_credito
        AND e.empresa = a.empresa 
       -- AND d.numcte = a.numcte
       -- AND d.secuencia = (select max(secuencia) from bdinteg:si_direcciones where numcte = a.numcte and tipo_dir = 1)
        AND a.empresa = pempresa
		AND a.status_cred NOT IN ('AA','E1') 
		AND (e.mto_venc_trasp + e.monto_vencido) > 0
        -- IFRS AND (a.status_cred<>'AA')) 
     ORDER BY a.sucursal, b.nombre ASC
	
	
		select  telefono 
			into  s_telefono1
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 1 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 1 and cofetel ='V');
										
		select  telefono 
			into  s_telefono2
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 2 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 2 and cofetel ='V');
												
		select  telefono ,extension
			into  s_telefono3, s_extension
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 3 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 3 and cofetel ='V');


      SELECT max(capital_fecha_pago), max(fecha_cuota)
        INTO s_fecha_ult_pago, s_fecha_cuota
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
--         AND capital_status in (7,2)
--  IFRS   AND capital_status in (7,2,6)
         AND NOT capital_fecha_pago IS NULL;


      SELECT nvl(capital_pagado,"0") + nvl(interes_pagado,"0") + nvl(iva_pagado,"0")
        INTO s_monto_ult_pago
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
         AND capital_fecha_pago = s_fecha_ult_pago
         AND fecha_cuota = s_fecha_cuota;

      -- Saldo Vencido
      LET s_saldo_vencido = s_sdo_traspasados + s_sdo_transitorios;


      -- Pagos Vencidos
      SELECT count(capital_status)
        INTO s_pagos_vencidos
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
		 AND capital_status in (7,2,6);
         --IFRS AND capital_status in (7,2);


      RETURN scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
             s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios,
             s_saldo_vencido,s_extension,s_pagos_vencidos
             WITH RESUME;

      END FOREACH

END

END PROCEDURE
;