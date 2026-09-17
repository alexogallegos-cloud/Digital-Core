CREATE PROCEDURE "informix".sp_envpag_valmontmax
(
	pModalidad   SMALLINT,  	--Modalidad
	pImporte     MONEY(14,2),  	--Monto a enviar-recibir
	pNombre1   	 CHAR (26), 	--nombre cliente-usuario
	pNombre2	 CHAR (26),
	pApellidoPat CHAR (26),
	pApellidoMat CHAR (26)
)

RETURNING CHAR (6) AS cCodRet;

	DEFINE cCodRet				CHAR(6);
	DEFINE iSqlErr 		  		INTEGER;
	DEFINE mLimite_envio  		MONEY(14,2);
	DEFINE iDias_limit   		INTEGER;
	DEFINE dtFecha_hoy   		DATE;
	DEFINE dtFecha_limit 		DATE;
	DEFINE mImporte_ya	 		MONEY(14,2);
	DEFINE mImporte_yahis 		MONEY(14,2);
	DEFINE mImporte_ya_movhis 	MONEY(14,2);
		
	LET cCodRet		 			= '000000';
	LET iSqlErr 				= 0;
	LET mLimite_envio   		= 0.00;
	LET iDias_limit     		= 0;
	LET dtFecha_hoy     		= DATE(1);
	LET dtFecha_limit   		= DATE(1);
	LET mImporte_ya				= 0.00;
	LET mImporte_yahis			= 0.00;
	LET mImporte_ya_movhis		= 0.00;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/adrian/sp_envpag_valmontmax_aia.out';
		--TRACE ON;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  		
				
		IF NVL(pModalidad,0) NOT IN (1,2) OR NVL(pNombre1,'') ='' OR NVL(pApellidoPat,'') ='' THEN 
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;
		
		-- BUSCANDO LA CANTIDAD LIMITE PERMITIDA
		SELECT NVL(valor,0) 
		INTO mLimite_envio
		FROM "informix".sac_param 
		WHERE cod_param = '6070033';
		
		/*
		-- BUSCANDO LOS DIAS LIMITES PARA EL CALCULO DE LA FECHA RANGO
		SELECT NVL(valor,0) 
		INTO iDias_limit
		FROM "informix".sac_param 
		WHERE cod_param = '6070034';
		*/
		
		--CONSULTAR FECHAHOY
		SELECT fecha_hoy 
		INTO dtFecha_hoy
		FROM "informix".sac_fechas
		WHERE empresa ='001';		
		
		--OBTENER FECHA LIMITE
		LET dtFecha_limit = MDY(MONTH(dtFecha_hoy),01,YEAR(dtFecha_hoy));
		
		-- ASEGURANDO DATOS EN MAYUSCULA
		LET pNombre1 = UPPER(pNombre1);
		LET pNombre2 = UPPER(pNombre2);
		LET pApellidoPat = UPPER(pApellidoPat);
		LET pApellidoMat = UPPER(pApellidoMat);		
		
		--ENVIO DE LA ORDEN DEL PAGO
		IF NVL(pImporte, 0) = 0 THEN
				LET cCodRet = '000001';
				RETURN cCodRet;
			END IF;
			
		IF pModalidad = 1 THEN							
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE PAGOS EN EFECTIVO PARA EL ORDENANTE				
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_envio,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1'  AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_rem = pNombre1
			AND enviohis.seg_nom_rem = pNombre2
			AND enviohis.apell_pat_rem = pApellidoPat
			AND enviohis.apell_mat_rem = pApellidoMat;

			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
						
		ELSE
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE COBROS EN EFECTIVO PARA EL BENEFICIARIO
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_pago,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_ben = pNombre1
			AND enviohis.seg_nom_ben = pNombre2
			AND enviohis.apell_pat_ben = pApellidoPat
			AND enviohis.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
					
		END IF;
		
		IF (NVL(mImporte_ya,0) + NVL(mImporte_yahis,0) + NVL(mImporte_ya_movhis,0) + NVL(pImporte,0)) > mLimite_envio THEN
				LET cCodRet = '000004';
				RETURN cCodRet;
		END IF
		
	RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que validará el monto máximo mensual en efectivo por usuario para envíos y/o cobros previa validación de los parámetros de entrada ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 13 de Octubre del 2014',
'VERSION: 20141030.1500',
'BD: bdisac',
'Folio: 1464 - LimiteOrdPagEfec',

'DESCRIPCION: Ahora se contemplará Envios/Cobros para la sumatoria del acumulado cuando ocurre el siguiente caso',
'por ejemplo: Hoy se realiza un envío y no es cobrado',
'AUTOR: Francisco Eduardo Benitez Baez',
'FECHA DE CREACION: 01 de Diciembre del 2014',
'VERSION: 20141201.1552',
'BD: BDISAC',
'Folio: 1474 - MttoLimiteOrdPagEfec',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE FUNCTION "informix".fn_instr(pString VARCHAR(255),pToken VARCHAR(255),pStar INTEGER DEFAULT 1 )
RETURNING SMALLINT ;

	DEFINE i,j SMALLINT ;
	DEFINE w_1 VARCHAR(255) ;

	IF ( pString IS NULL) OR (pToken IS NULL ) THEN
		RETURN -1 ;
	END IF ;
	LET j = LENGTH(pString);
	FOR i = pStar TO j 
		IF ( SUBSTR(pString,I,1) = SUBSTR(pToken,1,1) ) THEN
			LET w_1 = SUBSTR(pString,i,LENGTH(pToken)) ;
			IF ( w_1 = pToken) THEN
				RETURN i ;
			END IF ;
		END IF ;
	END FOR ;
RETURN 0 ;
END FUNCTION ;