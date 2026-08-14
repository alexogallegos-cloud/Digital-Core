CREATE PROCEDURE "informix".sp_cons_faltantes_caja_aud(pTipo INTEGER,
								                       pCodigo CHAR(4),
													   pEmpresa CHAR(3),
													   pSucursal CHAR(4),
													   pUsuario CHAR(8),
													   pFechaIni CHAR(10),
													   pFechaFin CHAR(10),
													   pSkip INTEGER,
													   pLimite INTEGER)
	RETURNING CHAR(5)  AS CodRet,
			  CHAR(10) AS Fecha,
			  CHAR(8)  AS Usuario,
			  CHAR(21) AS Importe,
			  CHAR(45) AS Nombre,
			  CHAR(4)  AS Transaccion,
			  CHAR(4)  AS Sucursal,
			  CHAR(10) AS Fecha_de_eliminacion,
			  CHAR(21) AS Saldo,
			  CHAR(10) AS Fecha_asigna,
			  INTEGER  AS TotRows;
			   
--Definicion de Variables
DEFINE iSqlErr 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cFecha 				CHAR(10);
DEFINE cUsuario				CHAR(8);
DEFINE cImporte				CHAR(21);
DEFINE cFechaElimina 		CHAR(10);
DEFINE cTransaccion 		CHAR(4);
DEFINE cSucursal			CHAR(4);
DEFINE cSaldo				CHAR(21);
DEFINE cNombre				CHAR(45);
DEFINE cAnio 	 			CHAR(4);
DEFINE cMes 				CHAR(2);
DEFINE cDia 				CHAR(2);
DEFINE cDescConcepto		CHAR(80);
DEFINE cFecharegistro		CHAR(10);
DEFINE iTotalRows			INTEGER;
DEFINE iLinea				INTEGER;
DEFINE iIdConcepto			INTEGER;
DEFINE iDiasConsulta		INTEGER;
DEFINE dFechaRegistro		DATE;
DEFINE dFechaLiquida		DATE;
DEFINE dFechaIni 			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE cFechaAsigna			CHAR(10);
DEFINE v_cod_transacc		CHAR(4);
DEFINE v_transacc		    CHAR(4);
DEFINE v_codigo_transacc    CHAR(4);
--Variables para comparar
DEFINE vFecha 				CHAR(10);
DEFINE vUsuario				CHAR(8);
DEFINE vImporte				CHAR(21);
DEFINE vTransaccion 		CHAR(4);
DEFINE vSucursal			CHAR(4);
DEFINE vSaldo				CHAR(21);
DEFINE vFechaElimina 		CHAR(10);


LET vFecha			= '';
LET vUsuario		='';
LET vImporte 		= '';
LET vTransaccion 	= '';
LET vSucursal 		= '';
LET vSaldo          = '';
LET vFechaElimina   = '';


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cFecha			= '';
LET cUsuario		='';
LET cImporte 		= '';
LET cFechaElimina 	= '';
LET cTransaccion 	= '';
LET cSucursal 		= '';
LET cSaldo 			= '';
LET cNombre 		= '';
LET iLinea 			= 0;
LET cAnio  			= '';
LET cMes  			= '';
LET cDia 			= '';
LET dFechaIni 		= DATE(1);
LET dFechaFin 		= DATE(1);
LET dFechaHoy		= DATE(1);
LET dFechaLiquida   = DATE(1);
LET iTotalRows 		= 0;
LET iDiasConsulta	= 0;
LET cFechaAsigna    = '';
LET v_cod_transacc  = '';
	--SET DEBUG FILE TO "/informix/1170/PRO_656_RD/soc/sp_faltantes"||"_"||""||pTipo||""||".out"; 
	--TRACE ON;

BEGIN
	ON EXCEPTION
	
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			
			IF iSqlErr= -668 THEN 
				LET cCodRet = '00005';
			ELSE
				LET cCodRet = iSqlErr;
			END IF;
			
			RETURN cCodRet,'','','','','','','','','','';
		
		END IF;
		
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO wait 3;
	
	LET cAnio = SUBSTRING(pFechaIni FROM 1 FOR 4);
	LET cMes = SUBSTRING(pFechaIni FROM 6 FOR 2) ;
	LET cDia = SUBSTRING(pFechaIni FROM 9 FOR 2);
	LET dFechaIni = TRIM(cMes||'/'||cDia||'/'||cAnio);
			
	LET cAnio = SUBSTRING(pFechaFin FROM 1 FOR 4);
	LET cMes =  SUBSTRING(pFechaFin FROM 6 FOR 2) ;
	LET cDia = SUBSTRING(pFechaFin FROM 9 FOR 2);
	LET dFechaFin = TRIM(cMes||'/'||cDia||'/'||cAnio);
	
	IF pTipo = 1 THEN
	
		IF (pEmpresa IS NULL OR NVL(pEmpresa,'') = '') OR (pUsuario IS NULL OR NVL(pUsuario,'') = '') OR
			(pFechaIni IS NULL OR NVL(pFechaIni,'') = '') OR (pFechaFin IS NULL OR NVL(pFechaFin,'') = '') OR
			(pCodigo IS NULL OR NVL(pCodigo,'') = '') OR (pSucursal IS NULL OR NVL(pSucursal,'') = '') THEN
			
			LET cCodRet = '00001';
		ELSE
				
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
			
			LET iDiasConsulta = (dFechaHoy - 1) - dFechaIni;
			
			IF (iDiasConsulta > 365) OR (dFechaIni >= dFechaHoy OR dFechaFin >= dFechaHoy) THEN 
				--Sobrepasa el año de consulta o esta consultando la fecha hoy 
				LET cCodRet = '00002';
			ELSE 	
				FOREACH
				
					SELECT a.numempleado,a.fecharegistro, a.saldoinicial,a.numsucursal, 
					(case 
						when (a.fechaliquida is null or a.fechaliquida = '') then date(1)
						else a.fechaliquida
					end),a.saldoactual,DECODE(a.idconcepto,3,'0038',1,'0006'), b.nombre
					INTO cUsuario,cFecharegistro,cImporte,cSucursal,dFechaLiquida,cSaldo,cTransaccion, cNombre
					FROM bdirech:"informix".rec_confaltante a, bdinteg:"informix".si_ejecut b
					WHERE a.idconcepto <> 2
					AND a.fecharegistro >= dFechaIni 
					AND a.fecharegistro <= dFechaFin
					AND a.numsucursal = pSucursal
					AND a.numempleado = b.ejecutivo
					
					
				LET vFecha = cFecharegistro;
				LET vUsuario = cUsuario;
				LET vImporte = 	cImporte;
				LET vTransaccion = cTransaccion;
				LET vSucursal = cSucursal;
				LET vSaldo = cSaldo;
				LET vFechaElimina = dFechaLiquida;
				
				 SELECT cod_transacc 
				 into v_transacc
				 FROM bdinteg:"informix".si_rptcaja_aud WHERE usuario = vUsuario AND cod_transacc = vTransaccion AND fecha = vFecha AND monto = vImporte  AND saldo = vSaldo AND fecha_eliminacion = vFechaElimina;
				
				IF  v_transacc is null or v_transacc=''  THEN
				 	INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa,usuario, cod_transacc,sucursal,fecha,monto,transaccion,saldo,fecha_eliminacion,nombre_usuario, fecha_insert)
					VALUES (pEmpresa,cUsuario,cTransaccion,pSucursal,cFecharegistro,cImporte,cTransaccion,cSaldo,dFechaLiquida,cNombre, today);
				END IF;
				
					LET cCodRet = '00000'; --Sin Errores
					LET iLinea = iLinea + 1;
				END FOREACH;
			END IF;	
		END IF;
	
		RETURN cCodRet,'','','','','','','','','','';
		
	ELIF pTipo = 2 THEN

		
		SELECT transaccion 
		into v_codigo_transacc
		FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo;
		
		
		SELECT COUNT(usuario)
		INTO iTotalRows
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND cod_transacc =v_codigo_transacc;
		
		FOREACH
		
			SELECT SKIP pSkip LIMIT  pLimite  
			rpt.fecha,rpt.usuario,rpt.monto,rpt.nombre_usuario,rpt.transaccion,rpt.sucursal, --CASE (fecha_eliminacion ) 
				(Case 
					When rpt.fecha_eliminacion = date(1) Then
						null
				Else
					rpt.fecha_eliminacion
				End) as fecha_eliminacion,rpt.saldo,rec.fechaasigna
			INTO cFecha,cUsuario,cImporte,cNombre,cTransaccion,cSucursal,cFechaElimina,cSaldo,cFechaAsigna
			FROM bdinteg:"informix".si_rptcaja_aud AS rpt, bdirech:"informix".rec_confaltante AS rec
			WHERE rpt.empresa = pEmpresa
			AND rpt.sucursal = pSucursal
			AND rpt.cod_transacc = v_codigo_transacc
			AND rpt.fecha BETWEEN dFechaIni AND dFechaFin
			AND rec.fecharegistro >= dFechaIni
			AND rec.fecharegistro <= dFechaFin
			AND rec.idconcepto <> 2
			AND rec.numempleado = rpt.usuario
			AND rec.fecharegistro =  rpt.fecha
			AND rec.saldoinicial =  Cast(rpt.monto as money)
			AND rec.numsucursal = rpt.sucursal
			AND DECODE(rec.idconcepto,3,'0038',1,'0006') = rpt.transaccion
			ORDER BY rpt.fecha ASC			
			
			
			RETURN cCodRet,cFecha,cUsuario,cImporte,cNombre,LPAD(TRIM(cTransaccion),4,'0'),cSucursal,NVL(cFechaElimina,''),cSaldo,NVL(cFechaAsigna,''),iTotalRows WITH RESUME;
			
		END FOREACH;
		
		LET pSkip = pSkip + pLimite ;
		
	ELSE
		LET cCodRet = '00003';
		
		RETURN cCodRet,'','','','','','','','','','';
		
	END IF;	

END;
END PROCEDURE
DOCUMENT
'FOLIO : 1556',
'AUTOR : Eduardo Lopez Cuevas ',
'FECHA :29-10-2013 ',
'DESCRIPCION: Se crea nuevo sp para obtener los datos del reporte de faltantes de caja ',
'SUSTENTO: RQM 12 023 Consulta de Transacciones V5.pdf ',
'SOLICITA: Norberto Corona',
'BD: bdinteg',

'Modificado por: Adilene Lara',
'Fecha: 14/01/2015',
'Descripción: Se modifica funcionalidad de acuerdo a los cambios realizados para la optimización de consulta de transacciones',

'Modificado por: L. Montserrat León Amador',
'Fecha: 13/09/2017',
'Descripción: Se modifica spl para agregar el retorno del campo fechaasigna de la tabla rec_confaltante',

'Modificado por: Rey David Zavala',
'Fecha: 22/11/2018',
'Descripción: Se agregan variables para insertar los resultados de los select y hacer mas libiano el proceso, de corrigue el error que ocaciono la incidencia INC 65 462, se castea el valor de la monto a Money';

CREATE PROCEDURE "informix".sp_actualiza_bitacora_ine()
RETURNING CHAR(5)  AS cCodRet;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE sNumCte			CHAR(20);
DEFINE dFechaIFE		DATETIME YEAR to FRACTION(3);
DEFINE iContador 	    INTEGER;

DEFINE sPonderacion    SMALLINT;
DEFINE cSituacionCte   CHAR(1);
DEFINE sCausaCte       SMALLINT;

--Inicializacion de Variables
LET cCodRet    		= '00000';
LET iSqlErr 		= 0;
LET sNumCte 		= "";
LET iContador       = 0;

LET sPonderacion = "0";
LET cSituacionCte   ="";
LET sCausaCte  = 0;

BEGIN

	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			ROLLBACK WORK;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	DROP TABLE IF EXISTS TMPSI_BITACORA_IFE20181103;
	DROP TABLE IF EXISTS TMPSI_BITACORA_IFE20181118;

	SELECT NUMCTE, MAX( FECHA ) AS FECHA
	FROM SI_BITACORA_IFE
	WHERE FECHA BETWEEN EXTEND(MDY(11,03,2018), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
	AND EXTEND(MDY(11,03,2018), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND
	AND flag_ws = 1
	AND cod_resp_ife = ''
	AND ( ( CASE WHEN test_uv_reflec_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_uv_shape_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_ir_ink_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_uv_reflectance_rev = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_ir_ink_rev = 'FAIL' THEN 0 ELSE 1 END ) ) >= 3
	AND NUMCTE IN
	( SELECT NUMCTE FROM BDISITESP:SE_CTESSITESPCTE WHERE situacion||causa = 'P109' )
	GROUP BY NUMCTE
	INTO TEMP TMPSI_BITACORA_IFE20181103;

	SELECT NUMCTE, MAX( FECHA ) AS FECHA
	FROM SI_BITACORA_IFE
	WHERE FECHA BETWEEN EXTEND(MDY(11,18,2018), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
	AND EXTEND(MDY(11,18,2018), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND
	AND flag_ws = 1
	AND cod_resp_ife = ''
	AND ( ( CASE WHEN test_uv_reflec_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_uv_shape_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_ir_ink_anv = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_uv_reflectance_rev = 'FAIL' THEN 0 ELSE 1 END )+
		( CASE WHEN test_ir_ink_rev = 'FAIL' THEN 0 ELSE 1 END ) ) >= 3
	AND NUMCTE IN
	( SELECT NUMCTE FROM BDISITESP:SE_CTESSITESPCTE WHERE situacion||causa = 'P109' )
	GROUP BY NUMCTE
	INTO TEMP TMPSI_BITACORA_IFE20181118;

	CREATE INDEX "informix".idx_TMPSI_BITACORA_IFE20181103_cte ON TMPSI_BITACORA_IFE20181103(numcte);
	CREATE INDEX "informix".idx_TMPSI_BITACORA_IFE20181118_cte ON TMPSI_BITACORA_IFE20181118(numcte);

	DELETE FROM TMPSI_BITACORA_IFE20181103 WHERE NUMCTE IN
	(   SELECT NUMCTE
		FROM SI_BITACORA_IFE
		WHERE FECHA BETWEEN EXTEND(MDY(11,04,2018), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
						AND EXTEND(MDY(11,29,2018), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND
		--AND flag_ws = 1
		--AND cod_resp_ife = ''
		AND resultado = 'Falso'
	);

	DELETE FROM TMPSI_BITACORA_IFE20181118 WHERE NUMCTE IN
	(   SELECT NUMCTE
		FROM SI_BITACORA_IFE
		WHERE FECHA BETWEEN EXTEND(MDY(11,19,2018), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
						AND EXTEND(MDY(11,29,2018), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND
		--AND flag_ws = 1
		--AND cod_resp_ife = ''
		AND resultado = 'Falso'
	);

	INSERT INTO TMPSI_BITACORA_IFE20181118 ( NUMCTE, fecha )
	SELECT NUMCTE, fecha FROM TMPSI_BITACORA_IFE20181103;

     --SET DEBUG FILE TO "/tmp/ivan/sp_actualiza_bitacora_ine.out";
	 --TRACE ON;
	 
	BEGIN WORK;

    FOREACH WITH HOLD SELECT numcte, fecha INTO sNumCte, dFechaIFE FROM TMPSI_BITACORA_IFE20181118
	
		LET sNumCte = TRIM( sNumCte );
	
	    LET iContador = iContador + 1;
		
		UPDATE bdinteg:si_bitacora_ife
		SET resultado = 'Verdadero', causa_rechazo = 'Datos Validos de acuerdo al WS del IFE'
		WHERE numcte = sNumCte AND fecha = dFechaIFE;
		
		EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(5,'001',sNumCte,'P',109,'', '','', '', '','','')
		INTO cCodRet, sPonderacion,cSituacionCte,sCausaCte;

        IF( iContador = 1000 ) THEN
            COMMIT WORK;
            LET iContador = 0;
			BEGIN WORK;
        END IF;
        
    END FOREACH;

    COMMIT WORK;
	
	DROP TABLE IF EXISTS TMPSI_BITACORA_IFE20181103;
	DROP TABLE IF EXISTS TMPSI_BITACORA_IFE20181118;	

	RETURN cCodRet;

END;

END PROCEDURE;