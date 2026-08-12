CREATE PROCEDURE "informix".sp_inserta_bitacora(pempresa CHAR(3), pproceso CHAR(4),pCod_ret CHAR(6)
                                                             ,pMensaje CHAR(150), p_tipoejecucion CHAR(2)) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE iSql_err 		  INTEGER;
DEFINE cError_info		  CHAR(150);
DEFINE iIsamErr           INTEGER;
DEFINE cMensaje 		  CHAR(80);
DEFINE cCod_ret           CHAR(6);
DEFINE dDia               DATE;
DEFINE cHora              CHAR(8);


--SET DEBUG FILE TO '/respaldosbd/Malena/sp_inserta_bitacora.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET iSql_err      = 0;
	  LET iIsamErr      = 0;
	  LET cError_info   = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
    
    
 
BEGIN
        ON EXCEPTION SET iSql_err, iIsamErr, cError_info
            LET cCod_ret = iSql_err;
            LET cMensaje = cError_info;
            RETURN cCod_ret;
        END EXCEPTION;
				
		SET LOCK MODE TO WAIT 3;

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO dDia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHora FROM sysmaster:sysshmvals;

        IF (p_tipoejecucion = '01') THEN
			--Se inserta registro de inicio de la ejecucion de proceso
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, '000000', 'PROCESO INICIALIZADO', user, dDia, cHora);
                
        ELIF (p_tipoejecucion = '02') THEN
			--Se inserta registro para el caso de que ocurra algun error
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, pCod_ret, pMensaje, user, dDia, cHora);
    
        ELIF (p_tipoejecucion = '03') THEN
			--Se inserta registro de fin de ejecucion de proceso
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, '000000', 'PROCESO FINALIZADO', user, dDia,  cHora);

        END IF;

    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento espejo para llevar un registro de inicio y fin en la ejecucion de procesos así como en caso de que ocurra algun error.',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/JULIO/2011',
'BD: BDICRED',
'VERSION:20110715.1805';

CREATE PROCEDURE "informix".sp_inserta_muestraedocta
(
pEmpresa 		CHAR(3), 
pNumCte			CHAR(20),
pNumCredito 	CHAR(20), 
pFechaCorte 	DATE, 
pNumTarjeta 	CHAR(20),
pStaMesAnte 	CHAR(2),
pStaMesAct 		CHAR(2)
)
RETURNING
	CHAR(6) AS COD_RET, ---cod_ret
	CHAR(80) AS DESCRIPCION; ---descripcion

	---DECLARACIONES
    DEFINE iSqlErr         	INTEGER;
	DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo      	CHAR(80);
    DEFINE cCodRet         	CHAR(6);
    DEFINE cMensajeRet     	CHAR(80);
	DEFINE dtFechaHoy		DATE;
	DEFINE sEstado			SMALLINT;

	---INICIALIZACIONES
    LET iSqlErr            	= 0;
	LET iIsamErr            = 0;
    LET cErrorInfo         	= "";
    LET cCodRet            	= "000000";
    LET cMensajeRet        	= "PROCESO EXITOSO";
	LET dtFechaHoy			= DATE(1); --MDY(1,1,1900);
	LET sEstado				= 0;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO "/home/sysifx/has/sp_inserta_muestraedocta.out";
--	TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pFechaCorte,DATE(1))= DATE(1) OR NVL(pNumTarjeta,'') = '' OR 
			NVL(pStaMesAnte,'') = '' OR NVL(pStaMesAct,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA INCOMPLETOS';
		RETURN cCodRet, cMensajeRet;
	END IF
	
	-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;
	
	
	--- OBTIENE EL VALOR DEL FLAG AUTOMATICO
	SELECT TRIM(valor)::INTEGER
	INTO sEstado
	FROM bdicred:'informix'.sd_param 
	WHERE empresa = '001'
	AND cod_param = '127';

	INSERT INTO bdicred:'informix'.sd_muestra_edocta 
	(empresa,numcte,num_credito,fecha_corte,tipo_logica,num_tarjeta,estatus_mes_anterior,estatus_mes_actual,flag_automatico,flag_generacion,fecha_insert,usuario_insert)
	VALUES(pEmpresa,pNumCte,pNumCredito,pFechaCorte,'',pNumTarjeta,pStaMesAnte,pStaMesAct,2,sEstado,dtFechaHoy,USER);
    
	RETURN cCodRet, cMensajeRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Inserta los creditos agregados manualmente del aplicativo en el catálogo de muestras de estados de cuenta', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20110805.1814';

CREATE PROCEDURE "informix".sp_mec_cliente_muestra
(
pEmpresa 		CHAR(3), 
pTotalMuestra 	INT8
)
RETURNING
	CHAR(6) AS COD_RET, 
	INTEGER AS SECUENCIA, 
	CHAR(80) AS DESCRIPCION; 

	---DECLARACIONES
    DEFINE iSqlErr         		INTEGER;
	DEFINE iIsamErr             INTEGER;
    DEFINE cErrorInfo      		CHAR(80);
    DEFINE cCodRet         		CHAR(6);
    DEFINE cMensajeRet     		CHAR(80);
    DEFINE iSecuencia      		INTEGER;
	DEFINE iNumeroAleatorio		INTEGER;

	---INICIALIZACIONES
    LET iSqlErr            	= 0;
	LET iIsamErr            = 0;
    LET cErrorInfo         	= "";
    LET cCodRet            	= "000000";
    LET cMensajeRet        	= "PROCESO EXITOSO";
	LET iSecuencia      	= 0;
    LET iNumeroAleatorio	= 0;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, iSecuencia, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--Estado = 0, Muestra en su estado inicial.
	--Estado = 1, Ya se uso secuencia como muestras.	

	---SET DEBUG FILE TO "/tmp/has/sp_mec_cliente_muestra.out";
	---TRACE ON;

	-- SE VALIDAN LOS PARAMATROS DE ENTRADA
	IF NVL(pEmpresa,'') = '' OR  NVL(pTotalMuestra,0) <= 0 THEN
		LET cCodRet = '000001';
		LET cMensajeRet = "PARAMETROS DE ENTRADA INCOMPLETOS";
		RETURN cCodRet, iSecuencia, cMensajeRet;
	END IF	

	-- VALIDA QUE LA MUESTRAS QUE EXISTAN TENGAN NO TENGAN STATUS GENERADO
	IF (SELECT COUNT(estado) FROM bdicred:'informix'.tmp_sd_muestra_edocta WHERE estado = 1) = pTotalMuestra THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'EL TOTAL DE MUESTRAS TIENEN ESTADO INVALIDO';
		RETURN cCodRet, iSecuencia, cMensajeRet;
	END IF
    
	-- BUCLE PARA OBTENER UN NUMERO DE SECUENCIA VALIDO EN BASE A UN NUMERO ALEATORIO
	WHILE iSecuencia = 0
		--- PROCEDIMIENTO GENERICO QUE GENERA UN NUMERO ALEATORIO
		EXECUTE PROCEDURE bdicred:'informix'.sp_random()
		INTO iNumeroAleatorio;	
		
		IF iNumeroAleatorio <= pTotalMuestra THEN
			LET iSecuencia = iNumeroAleatorio;
		ELSE
			LET iSecuencia = MOD(iNumeroAleatorio,pTotalMuestra);
		END IF
		
		IF EXISTS(SELECT estado FROM bdicred:'informix'.tmp_sd_muestra_edocta WHERE estado = 0 AND secuencia = iSecuencia) THEN
			UPDATE 'informix'.tmp_sd_muestra_edocta
			SET estado = 1
			WHERE secuencia = iSecuencia;
		ELSE
			LET iSecuencia = 0;
		END IF
	END WHILE

	RETURN cCodRet, iSecuencia, cMensajeRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener el numero de secuencia aleatorio en la tabla de trabajo de las muestras', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2011',
'VERSION: 20110805.1814';

CREATE PROCEDURE "informix".sp_random() RETURNING INTEGER;
	DEFINE GLOBAL dSeed DECIMAL(10) DEFAULT 1; 
	DEFINE dTemporal DECIMAL(20,0); 
	LET dTemporal = (dSeed * 1103515245) + 12345; 
	LET dSeed = dTemporal - 4294967296 * TRUNC(dTemporal / 4294967296); 
	RETURN MOD(TRUNC(dSeed / 65536), 32768); 
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento espejo del proceso de calculo de numero aleatorio mediante una semilla',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/JULIO/2011',
'BD: BDICRED',
'VERSION:20110715.1530';

CREATE PROCEDURE "informix".sp_mec2(pEmpresa CHAR(3), pFechaCorte DATE, pFechaCorteAnt DATE)
RETURNING CHAR (6) AS Codret  ,CHAR(100) AS Descripcion;
--'DESCRIPCION: Se realiza procedimiento para la obtencion de una muestra creditos '
--'AUTOR : Maria Elena Angulo Aispuro'--'FECHA : 01/AGOSTO/2011'--'BD: BDICRED'
--'MODIFICADO: Maria Elizabeth Anzures Ibarguen'--'FECHA: 28-SEPTIEMBRE-2011'
--'DESCRIPCION: Se agregaron 16 conusultas mas para la obtencion de muestras'
	
---Definicion de Variables          
DEFINE cCodRet CHAR(6); DEFINE cCodRet2	 CHAR(6); DEFINE cMensajeRet CHAR(100); DEFINE cMensajeRet2	CHAR(100); DEFINE iSqlErr INTEGER;
DEFINE iIsamErr  INTEGER; DEFINE scont INT8; DEFINE cErrorInfo  CHAR(80); DEFINE dFechaAnioAnt	 DATE; DEFINE dFechaHoy	DATE;
DEFINE iSecuencia	 INT8; DEFINE iMuestra	 INTEGER; DEFINE iFlagGeneracion  INTEGER; DEFINE iContador	INTEGER; DEFINE cNumcte	CHAR(20);
DEFINE sMesHoy 	SMALLINT; 	DEFINE sDiaHoy SMALLINT; DEFINE sAnioHoy SMALLINT; 	DEFINE dtCorteActual DATE;
DEFINE dtCorteAnterior	DATE; 	DEFINE cProceso	CHAR(4); 	DEFINE cCodRetIB  CHAR(6);
---Inicializaciones
LET iSqlErr    = 0; LET iIsamErr   = 0; LET cErrorInfo  = ""; LET scont	 = 0; LET cCodRet  = "000000"; LET cCodRet2   = "000000";
LET cMensajeRet  = "Se realizó la consulta correctamente"; LET cMensajeRet2  =""; LET dFechaHoy	  =MDY(1,1,1900);
LET dFechaAnioAnt  =MDY(1,1,1900); LET iSecuencia = 0; LET iMuestra	  = 0; LET iFlagGeneracion   = 0;
LET iContador  = 0; LET cNumcte	  =""; LET sMesHoy 	= 0; LET sDiaHoy = 0; LET sAnioHoy = 0; LET dtCorteActual = DATE(1);
LET dtCorteAnterior	= DATE(1); LET cCodRetIB  = '000000'; LET cProceso = '';
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2001',cCodRet,cMensajeRet,'01')	INTO cCodRet;
--SET DEBUG FILE TO '/home/informix/Elizabeth/mec.out';
--TRACE ON;
	--Validacion de parametros de entrada
	IF (pEmpresa='') OR (pFechaCorte='') OR (pFechaCorteAnt='') OR  (pEmpresa IS NULL) OR (pFechaCorte IS NULL) OR (pFechaCorteAnt IS NULL)  THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	ELSE
		------------------------------TOTALERO A VIGENTE NO TOTALERO CON PAGOS-----------------------------------------------------------------------
		--Se limpia para iniciar la tabla de trabajo
		DELETE FROM bdicred:"informix".tmp_sd_muestra_edocta;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia INTEGER;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia serial;
		--Se obtienen la fecha de corte del año anterior
		LET dFechaAnioAnt = mdy(MONTH(pFechaCorteAnt),'20',YEAR(pFechaCorteAnt)) - 1 units YEAR;
		/*--Obtener fecha actual
		SELECT fecha_hoy
		INTO dfechahoy
		FROM bdicred:"informix".sd_fechas
	    WHERE empresa = pEmpresa;
		let dfechahoy = date(dfechahoy)   - 1 units month; 
		LET sMesHoy = MONTH(dFechaHoy);
	LET sDiaHoy = DAY(dFechaHoy);
	LET sAnioHoy = YEAR(dFechaHoy);
		--- VALIDA QUE NO SEA UNA FECHA ANTES DEL CORTE
	IF sDiaHoy < 20 THEN
		LET cCodRet = '000004';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ES MENOR AL DIA DEL CORTE';
		RETURN cCodRet,cMensajeRet;
	END IF
	--- OBTIENE LA FECHA DEL CORTE ACTUAL Y DEL CORTE ANTERIOR
	LET dtCorteActual		= MDY(sMesHoy,20,sAnioHoy);
	LET dtCorteAnterior		=  dFechaHoy - 1 UNITS MONTH;
	LET dtCorteAnterior		=  MDY(MONTH(dtCorteAnterior),20,YEAR(dtCorteAnterior));*/
		--Se obtiene valor que contENDrá el campo flag_generacion al insertar el registro muestra.
		SELECT TRIM(valor)::INTEGER
		INTO iFlagGeneracion
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "127";	
				--Se obtiene numero de muestras de valores aleatorios a obtener.
		SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";	
		--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	INSERT INTO 'informix'.tmp_sd_muestra_edocta
(tipo_logica,estado,num_credito,numcte,num_tarjeta,fecha,estatus_anterior,estatus_actual)
	select '14',0, a.num_credito,c.numcte, c.num_tarjeta,b.fecha, 'AA','AA'
from bdicred:sd_maesdoshist a,
     bdicred:sd_tarjeta c,
     bdicred:sd_maesdoshist b
     ,bdicred:sd_maecredanexo d
where a.empresa = '001'
and a.fecha = pFechaCorteAnt
and b.fecha = pFechaCorte
and a.empresa = b.empresa
and a.empresa = c.empresa
and a.empresa = d.empresa
and a.num_credito = b.num_credito
and a.num_credito = c.num_credito
and a.num_credito = d.num_credito 
and c.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
and a.monto_vencido + a.mto_venc_trasp = 0
and b.monto_vencido + b.mto_venc_trasp = 0
and a.sdo_cap_insoluto <= 0
and d.fecha_ult_pago > a.fecha
and d.fecha_ult_pago <= b.fecha
and b.sdo_cap_insoluto > 0
and a.sdo_cap_insoluto <= 
    (select sum(monto)
    from bdicred:sd_movhis
    where empresa = '001'
      and a.num_credito = num_credito
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
      and codigo_ref = 1
      and fecha_mov > a.fecha - 1 UNITS MONTH
      and fecha_mov <=  a.fecha
      and reversado = 'N') 
and (select count(m.empresa)
       from bdicred:sd_movhis m
      where m.empresa = a.empresa
        and m.fecha_mov > a.fecha - 1 UNITS MONTH
        and m.fecha_mov <= a.fecha
        and m.num_credito = a.num_credito
        and m.codigo_fun = '002'
        and m.codigo_ref in (30,31,32,33,34,35,36,37,38,39,57,30,50,51,40,41,42,60,61,62,63,64,65)
       and m.reversado = 'N')>= 1
		and (select count(mo.empresa)
       from bdicred:sd_movhis mo
      where mo.empresa = a.empresa
        and mo.fecha_mov > a.fecha - 1 UNITS MONTH
        and mo.fecha_mov <= a.fecha
        and mo.num_credito = a.num_credito
        and mo.codigo_fun = '002'
        and mo.codigo_ref in (30,31,32,33,34,35,36,37,38,39,57,30,50,51,40,41,42,60,61,62,63,64,65)
        and mo.reversado = 'N')>= 1;
	
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay Información de clientes con estatus totalero a vigente no totalero con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02')INTO cCodRet; 
		ELSE
			WHILE 1 = 1 
			--Se ejecuta proceso para obtener un valor aleatorio
				EXECUTE PROCEDURE bdicred:"informix".sp_mec_cliente_muestra(pEmpresa,scont) INTO cCodRet2, iSecuencia,cMensajeRet2;
					IF cCodRet2 =0 THEN	
						SELECT numcte 
						INTO cNumcte
						FROM bdicred:"informix".tmp_sd_muestra_edocta 
						WHERE secuencia = iSecuencia;
						--Se valida que no exista el cliente en los ultimos 12 meses
						IF NOT EXISTS (SELECT numcte FROM bdicred:"informix".sd_muestra_edocta 
									WHERE numcte = cNumcte 
									AND fecha_corte >=dFechaAnioAnt 
									AND fecha_corte<=pFechaCorte) THEN
							--Una vez que pasa la validación anterior se inserta el cliente en la tabla de muestras
							INSERT INTO bdicred:"informix".sd_muestra_edocta(empresa,numcte,num_credito,fecha_corte,tipo_logica,num_tarjeta,estatus_mes_anterior,estatus_mes_actual,flag_automatico,flag_generacion,fecha_insert,usuario_insert)
							SELECT '001',numcte,num_credito,fecha,tipo_logica,num_tarjeta,estatus_anterior,estatus_actual,1,iFlagGeneracion,dfechahoy,user
							FROM bdicred:"informix".tmp_sd_muestra_edocta
							WHERE secuencia = iSecuencia
							AND tipo_logica='14';
							--Se obtienen  el total de valores aleatorios determinados y termina ciclo
							LET iContador=iContador+1;
							IF iContador=iMuestra THEN
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02') INTO cCodRet;
							
								EXIT WHILE;			
							END IF;
						END IF; 
					ELSE 
						IF cCodRet2=2 THEN
							LET cCodRet= '000003';
							LET cMensajeRet= 'No hay creditos validos para la muestra o ya existe en fechas de corte anterior';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02')							INTO cCodRet;
							EXIT WHILE;			
						ELSE 
							LET cCodRet= '000004';
							LET cMensajeRet= 'Ocurrio un error al obtener número de cliente aleatorio(sp_mec_cliente_muestra)';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02')							INTO cCodRet;	
							EXIT WHILE;			
						END IF;
					END IF;
			END WHILE;
		END IF;	
	-------------------------------------------TOTALERO A VIGENTE NO TOTALERO SIN PAGOS-----------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET iSecuencia	 = 0;	LET cMensajeRet2 ="";	LET cCodRet2  = "000000";	LET iContador = 0;
	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizó la consulta correctamente";	LET iMuestra = 0;
		--Se limpia para iniciar la tabla de trabajo
		DELETE FROM bdicred:"informix".tmp_sd_muestra_edocta;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia INTEGER;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia serial;
		--Se obtiene numero de muestras de valores aleatorios a obtener.
		SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";

		--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	INSERT INTO 'informix'.tmp_sd_muestra_edocta 
(tipo_logica,estado,num_credito,numcte,num_tarjeta,fecha,estatus_anterior,estatus_actual)
	select '15',0, a.num_credito,c.numcte, c.num_tarjeta,b.fecha, 'AA','BA'
from bdicred:sd_maesdoshist a,
     bdicred:sd_tarjeta c,
     bdicred:sd_maesdoshist b
     ,bdicred:sd_maecredanexo d
where a.empresa = '001'
and a.fecha = pFechaCorteAnt
and b.fecha = pFechaCorte
and a.empresa = b.empresa
and a.empresa = c.empresa
and a.empresa = d.empresa
and a.num_credito = b.num_credito
and a.num_credito = c.num_credito
and a.num_credito = d.num_credito 
and c.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
and a.monto_vencido + a.mto_venc_trasp = 0
and b.monto_vencido + b.mto_venc_trasp = 0
and a.sdo_cap_insoluto <= 0
and b.sdo_cap_insoluto  > 0
and d.fecha_ult_pago <= a.fecha
and a.sdo_cap_insoluto <= 
    (select sum(monto)
    from bdicred:sd_movhis
    where empresa = '001'
      and a.num_credito = num_credito
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
      and codigo_ref = 1
      and fecha_mov > a.fecha - 1 UNITS MONTH
      and fecha_mov <=  a.fecha
      and reversado = 'N') 
and (select count(m.empresa)
       from bdicred:sd_movhis m
      where m.empresa = a.empresa
        and m.fecha_mov > a.fecha - 1 UNITS MONTH
        and m.fecha_mov <= a.fecha
        and m.num_credito = a.num_credito
        and m.codigo_fun = '002'
        and m.codigo_ref in (30,31,32,33,34,35,36,37,38,39,57,30,50,51,40,41,42,60,61,62,63,64,65)
       and m.reversado = 'N')>= 1
and (select count(mo.empresa)
       from bdicred:sd_movhis mo
      where mo.empresa = a.empresa
        and mo.fecha_mov > a.fecha 
        and mo.fecha_mov <= b.fecha
        and mo.num_credito = a.num_credito
        and mo.codigo_fun = '002'
        and mo.codigo_ref in (30,31,32,33,34,35,36,37,38,39,57,30,50,51,40,41,42,60,61,62,63,64,65)
        and mo.reversado = 'N')>= 1;
		
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay Información de clientes con estatus totalero a vigente no totalero sin pagos';
			 EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02')INTO cCodRet;
		ELSE
			WHILE 1 = 1 
			--Se ejecuta proceso para obtener un valor aleatorio
				EXECUTE PROCEDURE bdicred:"informix".sp_mec_cliente_muestra(pEmpresa,scont) INTO cCodRet2, iSecuencia,cMensajeRet2;
					IF cCodRet2 =0 THEN	
						SELECT numcte 
						INTO cNumcte
						FROM bdicred:"informix".tmp_sd_muestra_edocta 
						WHERE secuencia = iSecuencia;
						--Se valida que no exista el cliente en los ultimos 12 meses
						IF NOT EXISTS (SELECT numcte FROM bdicred:"informix".sd_muestra_edocta 
									WHERE numcte = cNumcte 
									AND fecha_corte >=dFechaAnioAnt 
									AND fecha_corte<=pFechaCorte) THEN
							--Una vez que pasa la validación anterior se inserta el cliente en la tabla de muestras
							INSERT INTO bdicred:"informix".sd_muestra_edocta(empresa,numcte,num_credito,fecha_corte,tipo_logica,num_tarjeta,estatus_mes_anterior,estatus_mes_actual,flag_automatico,flag_generacion,fecha_insert,usuario_insert)
							SELECT '001',numcte,num_credito,fecha,tipo_logica,num_tarjeta,estatus_anterior,estatus_actual,1,iFlagGeneracion,dfechahoy,user
							FROM bdicred:"informix".tmp_sd_muestra_edocta
							WHERE secuencia = iSecuencia
							AND tipo_logica= '15';
							--Se obtienen  el total de valores aleatorios determinados y termina ciclo
							LET iContador=iContador+1;
							IF iContador=iMuestra THEN
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02') INTO cCodRet;
								EXIT WHILE;			
							END IF;
						END IF; 
					ELSE 
						IF cCodRet2=2 THEN
							LET cCodRet= '000003';
							LET cMensajeRet= 'No hay creditos validos para la muestra o ya existe en fechas de corte anterior';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02')							INTO cCodRet;
							EXIT WHILE;			
						ELSE 
							LET cCodRet= '000004';
							LET cMensajeRet= 'Ocurrio un error al obtener número de cliente aleatorio(sp_mec_cliente_muestra)';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02')							INTO cCodRet;	
							EXIT WHILE;			
						END IF;
					END IF;
			END WHILE;
		END IF;	
	-------------------------------VENCIDO A TOTALERO-----------------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET iSecuencia	 = 0;	LET cMensajeRet2 ="";	LET cCodRet2  = "000000";	LET iContador = 0;
	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizó la consulta correctamente";	LET iMuestra = 0;
		--Se limpia para iniciar la tabla de trabajo
		DELETE FROM bdicred:"informix".tmp_sd_muestra_edocta;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia INTEGER;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia serial;
		--Se obtiene numero de muestras de valores aleatorios a obtener.
		SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";
	
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	INSERT INTO 'informix'.tmp_sd_muestra_edocta 
(tipo_logica,estado,num_credito,numcte,num_tarjeta,fecha,estatus_anterior,estatus_actual)	
	select '16',0, a.num_credito,c.numcte, c.num_tarjeta, b.fecha ,'BT','AA'
from bdicred:sd_maesdoshist a, bdicred:sd_tarjeta c,
     bdicred:sd_maesdoshist b
where a.empresa = '001'
and a.fecha = pFechaCorteAnt
and b.fecha = pFechaCorte
and a.empresa = b.empresa
and a.empresa = c.empresa
and a.num_credito = b.num_credito
 and a.num_credito = c.num_credito
and c.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
and a.mto_venc_trasp + a.cap_tras_no_venci > 0
and b.monto_vencido + b.mto_venc_trasp = 0
and b.sdo_cap_insoluto <= 0
and b.sdo_cap_insoluto <= (
    nvl((select sum(monto)
    from bdicred:sd_movhis
    where b.empresa = empresa
      and b.num_credito = num_credito
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
      and codigo_ref in (7,8,10,901)
      and fecha_mov > a.fecha
      and fecha_mov <=  b.fecha
     and reversado = 'N'),0));
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay Información de clientes con estatus vencido a totalero ';
			 EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02') INTO cCodRet;
		ELSE
			WHILE 1 = 1 
			--Se ejecuta proceso para obtener un valor aleatorio
				EXECUTE PROCEDURE bdicred:"informix".sp_mec_cliente_muestra(pEmpresa,scont) INTO cCodRet2, iSecuencia,cMensajeRet2;
					IF cCodRet2 =0 THEN	
						SELECT numcte 
						INTO cNumcte
						FROM bdicred:"informix".tmp_sd_muestra_edocta 
						WHERE secuencia = iSecuencia;
						--Se valida que no exista el cliente en los ultimos 12 meses
						IF NOT EXISTS (SELECT numcte FROM bdicred:"informix".sd_muestra_edocta 
									WHERE numcte = cNumcte 
									AND fecha_corte >=dFechaAnioAnt 
									AND fecha_corte<=pFechaCorte) THEN
							--Una vez que pasa la validación anterior se inserta el cliente en la tabla de muestras
							INSERT INTO bdicred:"informix".sd_muestra_edocta(empresa,numcte,num_credito,fecha_corte,tipo_logica,num_tarjeta,estatus_mes_anterior,estatus_mes_actual,flag_automatico,flag_generacion,fecha_insert,usuario_insert)
							SELECT '001',numcte,num_credito,fecha,tipo_logica,num_tarjeta,estatus_anterior,estatus_actual,1,iFlagGeneracion,dfechahoy,user
							FROM bdicred:"informix".tmp_sd_muestra_edocta
							WHERE secuencia = iSecuencia
							AND tipo_logica= '16';
							--Se obtienen  el total de valores aleatorios determinados y termina ciclo
							LET iContador=iContador+1;
							IF iContador=iMuestra THEN
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02') INTO cCodRet;
								EXIT WHILE;			
							END IF;
						END IF; 
					ELSE 
						IF cCodRet2=2 THEN
							LET cCodRet= '000003';
							LET cMensajeRet= 'No hay creditos validos para la muestra o ya existe en fechas de corte anterior';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02')							INTO cCodRet;
							EXIT WHILE;			
						ELSE 
							LET cCodRet= '000004';
							LET cMensajeRet= 'Ocurrio un error al obtener número de cliente aleatorio(sp_mec_cliente_muestra)';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02')							INTO cCodRet;	
							EXIT WHILE;			
						END IF;
					END IF;
			END WHILE;
		END IF;	
-------------------------------TRANSITORIO A TOTALERO-----------------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET iSecuencia	 = 0;	LET cMensajeRet2 ="";	LET cCodRet2  = "000000";	LET iContador = 0;
	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizó la consulta correctamente";	LET iMuestra = 0;
		--Se limpia para iniciar la tabla de trabajo
		DELETE FROM bdicred:"informix".tmp_sd_muestra_edocta;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia INTEGER;
		ALTER TABLE bdicred:"informix".tmp_sd_muestra_edocta MODIFY secuencia serial;
		--Se obtiene numero de muestras de valores aleatorios a obtener.
		SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";
	
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	INSERT INTO 'informix'.tmp_sd_muestra_edocta 
(tipo_logica,estado,num_credito,numcte,num_tarjeta,fecha,estatus_anterior,estatus_actual)
	select '17',0, a.num_credito, c.numcte,c.num_tarjeta, b.fecha, 'BA','AA'
from bdicred:sd_maesdoshist a,
     bdicred:sd_tarjeta c,
     bdicred:sd_maesdoshist b
where a.empresa = '001'
and a.fecha = pFechaCorteAnt
and b.fecha = pFechaCorte
and a.empresa = b.empresa
and a.empresa = c.empresa
and a.num_credito = b.num_credito
and a.num_credito = c.num_credito
and c.secuencia = (select max(tar.secuencia)
                  from bdicred:sd_tarjeta tar
                  where tar.empresa = a.empresa
                  and tar.num_credito = a.num_credito
                  and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
and a.monto_vencido > 0
and b.monto_vencido + b.mto_venc_trasp = 0
and b.sdo_cap_insoluto <= 0
and b.sdo_cap_insoluto <= (
    nvl((select sum(monto)
    from bdicred:sd_movhis
    where b.empresa = empresa
      and fecha_mov > a.fecha
      and fecha_mov <=  b.fecha
      and b.num_credito = num_credito
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
      and codigo_ref in (7,8,10,901)
      and reversado = 'N'),0));

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay Información de clientes con estatus transitorio a totalero ';
			 EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02')INTO cCodRet;
		ELSE
			WHILE 1 = 1 
			--Se ejecuta proceso para obtener un valor aleatorio
				EXECUTE PROCEDURE bdicred:"informix".sp_mec_cliente_muestra(pEmpresa,scont) INTO cCodRet2, iSecuencia,cMensajeRet2;
					IF cCodRet2 =0 THEN	
						SELECT numcte 
						INTO cNumcte
						FROM bdicred:"informix".tmp_sd_muestra_edocta 
						WHERE secuencia = iSecuencia;
						--Se valida que no exista el cliente en los ultimos 12 meses
						IF NOT EXISTS (SELECT numcte FROM bdicred:"informix".sd_muestra_edocta 
									WHERE numcte = cNumcte 
									AND fecha_corte >=dFechaAnioAnt 
									AND fecha_corte<=pFechaCorte) THEN
							--Una vez que pasa la validación anterior se inserta el cliente en la tabla de muestras
							INSERT INTO bdicred:"informix".sd_muestra_edocta(empresa,numcte,num_credito,fecha_corte,tipo_logica,num_tarjeta,estatus_mes_anterior,estatus_mes_actual,flag_automatico,flag_generacion,fecha_insert,usuario_insert)
							SELECT '001',numcte,num_credito,fecha,tipo_logica,num_tarjeta,estatus_anterior,estatus_actual,1,iFlagGeneracion,dfechahoy,user
							FROM bdicred:"informix".tmp_sd_muestra_edocta
							WHERE secuencia = iSecuencia
							AND tipo_logica= '17';
							--Se obtienen  el total de valores aleatorios determinados y termina ciclo
							LET iContador=iContador+1;
							IF iContador=iMuestra THEN
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02') INTO cCodRet;
								EXIT WHILE;			
							END IF;
						END IF; 
					ELSE 
						IF cCodRet2=2 THEN
							LET cCodRet= '000003';
							LET cMensajeRet= 'No hay creditos validos para la muestra o ya existe en fechas de corte anterior';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02')							INTO cCodRet;
							EXIT WHILE;			
						ELSE 
							LET cCodRet= '000004';
							LET cMensajeRet= 'Ocurrio un error al obtener número de cliente aleatorio(sp_mec_cliente_muestra)';	
							EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02')							INTO cCodRet;	
							EXIT WHILE;			
						END IF;
					END IF;
			END WHILE;
		END IF;		
			
	END IF;	EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2001',cCodRet,cMensajeRet,'03')		INTO cCodRet;
	RETURN cCodRet,cMensajeRet;
END
END PROCEDURE
;