CREATE PROCEDURE "informix".sp_ht_obtener_tels_sin_guardar_pba()
RETURNING CHAR(6),		-- CODIGO DE RETORNO
          CHAR(13),		-- FOLIO ARCHIVO
		  INT8,			-- TOTAL DE CLIENTES
		  INT8;			-- NUMERO DE TELEFONOS DUPLICADOS
          
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cDescRet			CHAR(80);
    
    DEFINE dFechaHoy		DATE;
    DEFINE cHoraMinHoy		CHAR(4);
    DEFINE cCte				CHAR(20);
    DEFINE dtFechaCte		DATE;
    DEFINE cNombre1			CHAR(26);
    DEFINE cNombre2			CHAR(26);
    DEFINE cApellPaterno	CHAR(26);
    DEFINE cApellMaterno	CHAR(26);
    DEFINE cNomEstado		CHAR(30);
    DEFINE cNomCiudad		CHAR(26);
    DEFINE iTipoTel			SMALLINT;
    DEFINE iCarrier			SMALLINT;
    DEFINE cTelefono		CHAR(13);
    DEFINE cFolioArchivo	CHAR(13);
    DEFINE iNumTelsDup		INT8;
    DEFINE iNumSecCte		INT8;
    DEFINE iTotCtes			INT8;
    DEFINE iBandera			SMALLINT;
    DEFINE iExiste			SMALLINT;
    DEFINE cVerificado		CHAR(1);
	DEFINE dFechaAnte		DATE;
    
    LET iSqlErr             = 0;
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";
    LET cCodRet             = "000000";
    LET cDescRet			= "PROCESO EXITOSO";
    
    LET dFechaHoy			= DATE(1);
    LET cHoraMinHoy			= "";
    LET cCte				= "";
    LET dtFechaCte			= DATE(1);
    LET cNombre1			= "";
    LET cNombre2			= "";
    LET cApellPaterno		= "";
    LET cApellMaterno		= "";
    LET cNomEstado			= "";
    LET cNomCiudad			= "";
    LET iTipoTel			= 0;
    LET iCarrier			= 0;
    LET cTelefono			= "";
    LET cFolioArchivo		= "";
    LET iNumTelsDup			= 0;
    LET iNumSecCte			= 1;
    LET iTotCtes			= 0;
    LET iBandera			= 0;
    LET iExiste				= 0;
    LET cVerificado			= "";
	LET dFechaAnte			= DATE(1);

    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
            RETURN cCodRet, cFolioArchivo, iTotCtes, iNumTelsDup;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
     --SET DEBUG FILE TO '/informix/moha/sp_ht_obtener_tels_sin_guardar.out';
     --TRACE ON;
    
    --// OBTIENE LA HORA DE HOY
    SELECT fecha_hoy, SUBSTR(CURRENT::DATETIME HOUR TO SECOND,1,2) || SUBSTR(CURRENT::DATETIME HOUR TO SECOND,4,2)
      INTO dFechaHoy, cHoraMinHoy
      FROM "informix".si_fechas
     WHERE empresa = "001";
	
	IF DAY(dFechaHoy) = 22 THEN
		LET dFechaAnte = dFechaHoy - 1 UNITS MONTH;
		LET dFechaAnte = dFechaAnte - 2 UNITS DAY;
	
		--// ACTUALIZA LAS FECHAS QUE YA PASARON
		UPDATE "informix".si_ht_controlproc
		SET status = 1
		WHERE fecha = dFechaAnte;
		
		LET dFechaAnte = dFechaHoy - 2 UNITS DAY;
	
		--// INSERTA EL NUEVO REGISTRO DEL MES
		INSERT INTO "informix".si_ht_controlproc(fecha, status)
		VALUES( dFechaAnte, 0 );
	END IF
	
	LET dFechaAnte = MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy));
	
	--// VALIDA QUE CORRA EL PROCESO SOLO SI HAY REGISTRO DEL MES ACTUAL
	IF EXISTS(SELECT status FROM "informix".si_ht_controlproc WHERE fecha = dFechaAnte AND status = 0) THEN

		CREATE TEMP TABLE tmp_si_ht_detalle_ctrl_tels
		(
		folio_archivo	char(13), 
		num_cte			char(20), 
		sec_cte			smallint default 1, 
		telefono		char(13),
		PRIMARY KEY(folio_archivo,num_cte,telefono)
		) WITH NO LOG;

		--// CREACION DEL FOLIO
		LET cFolioArchivo =  "137" || SUBSTR(YEAR(dFechaHoy),3,2) || LPAD(MONTH(dFechaHoy),2,"0") || LPAD(DAY(dFechaHoy),2,"0") || cHoraMinHoy;
		
		--// OBTIENE TELEFONOS DE CLIENTES DE CREDITO
		SELECT {+INDEX (si_bitacora_tel idx_bitactel_cte)}
			   dos.num_credito, crd.numcte
		  FROM bdicred: "informix".sd_maesdos dos
		 INNER JOIN bdicred: "informix".sd_maecred crd ON (dos.num_credito = crd.num_credito)
		 INNER JOIN "informix".si_bitacora_tel bt ON (bt.numcte = crd.numcte)
		 WHERE crd.status_cred IN ("BA","BT")
		   AND bt.sucursal = "0000"
		INTO TEMP tmp_ctes_cred WITH NO LOG;
		CREATE INDEX idx_tmp_creds ON tmp_ctes_cred(numcte) USING BTREE FILLFACTOR 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_ctes_cred;
		
		LET cCte = "";
		
		--// GENERA LA ULTIMA TABLA TEMPORAL DE CREDITO
		SELECT {+INDEX(si_telefonos_actual idx_telact_ctetipo)}
			   cte.numcte, cte.fecha_insert, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno,
			   edo.nombre, cd.nombreciudad, tel.tipo_tel, tel.carrier, tel.telefono
		  FROM tmp_ctes_cred tmp
		 INNER JOIN "informix".si_cliente cte ON ( tmp.numcte = cte.numcte )
		 INNER JOIN "informix".si_telefonos_actual tel ON ( tel.numcte = cte.numcte AND tel.tipo_tel IN (1,2) AND tel.cofetel = "V" AND LENGTH(tel.telefono) = 10 )
		  LEFT OUTER JOIN "informix".si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = 1 )
		  LEFT OUTER JOIN "informix".si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
		  LEFT OUTER JOIN "informix".si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
		  LEFT OUTER JOIN "informix".si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
		  LEFT OUTER JOIN "informix".si_estados edo ON ( edo.estado = dir.estado )
		WHERE cte.fecha_insert < '07012014'
		INTO TEMP tmp_tels_credito WITH NO LOG;
		CREATE INDEX idxtmp_tels_credito_telefono ON tmp_tels_credito(telefono) USING btree fillfactor 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_tels_credito;
		
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_ctes_cred;
		
		--// VALIDA QUE NO EXISTAN TELEFONOS EN ARCHIVOS ANTERIORES
		SELECT *
		  FROM tmp_tels_credito
		 WHERE telefono NOT IN( SELECT telefono FROM si_ht_detalle_ctrl_tels )
		INTO TEMP tmp_tels_credito_2 WITH NO LOG;
		CREATE INDEX idxtmp_tels_credito_2_num_cte_tel ON tmp_tels_credito_2(numcte, telefono) USING btree fillfactor 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_tels_credito_2;
		
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_tels_credito;
		
		LET cCte = "";
		LET cTelefono = "";
		
		--// BORRA LOS TELEFONOS CELULARES QUE SE REPITEN EN PARTICULARES DEL MISMO CLIENTE
		FOREACH 
			SELECT numcte, telefono
			  INTO cCte, cTelefono
			  FROM tmp_tels_credito_2
			 GROUP BY 1, 2
			HAVING COUNT(*) > 1
			
			DELETE tmp_tels_credito_2 
			 WHERE numcte = cCte 
			   AND telefono = cTelefono 
			   AND tipo_tel = 2;
		END FOREACH
		
		LET cCte = "";
		LET cTelefono = "";
		
		--// CICLO PARA INSERTAR LOS TELEFONOS DE CREDITO
		FOREACH 
			SELECT numcte, fecha_insert, nombre1, nombre2, apell_paterno, apell_materno, nombre, nombreciudad, tipo_tel, carrier, telefono
			  INTO cCte, dtFechaCte, cNombre1, cNombre2, cApellPaterno, cApellMaterno, cNomEstado, cNomCiudad, iTipoTel, iCarrier, cTelefono
			  FROM tmp_tels_credito_2 t1
			 WHERE numcte = numcte 
			   AND telefono = telefono
			
			--// VALIDA EN LA SI TELEFONOS SI VERIFICADO ES NULO ENTONCES NO ESTA VALIDADO
			SELECT LIMIT 1 verificado
			  INTO cVerificado
			  FROM "informix".si_telefonos
			 WHERE numcte = cCte
			   AND telefono = cTelefono 
			   AND tipo_tel = iTipoTel;
			
			IF cVerificado IS NULL THEN
				LET iBandera = 0;
			ELSE
				SELECT 1
				  INTO iBandera
				  FROM "informix".si_tels_invalidos
				 WHERE telefono = cTelefono;
				
				LET iBandera = NVL(iBandera,0);
			END IF
			
			IF iBandera = 0 THEN
				LET iExiste = 0;
				
				SELECT 1
				  INTO iExiste
				  FROM "informix".tmp_si_ht_detalle_ctrl_tels
				 WHERE folio_archivo = cFolioArchivo 
				   AND num_cte = cCte 
				   AND telefono = cTelefono;
				
				LET iExiste = NVL(iExiste,0);
				
				IF iExiste = 0 THEN
					INSERT INTO "informix".tmp_si_ht_detalle_ctrl_tels (folio_archivo, num_cte, telefono)
					VALUES (cFolioArchivo, cCte, cTelefono);
				END IF
			END IF
		END FOREACH
			
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_tels_credito_2;
		
		LET cTelefono = "";
		
		--// VALIDA CUANTOS CLIENTES COMPARTEN EL MISMO TELEFONO
		FOREACH 
			SELECT telefono
			  INTO cTelefono
			  FROM "informix".tmp_si_ht_detalle_ctrl_tels
			 WHERE folio_archivo = cFolioArchivo
			 GROUP BY 1
			HAVING COUNT(num_cte) > 1
			
			LET cCte = "";
			LET iNumSecCte = 1;
			
			FOREACH 
				SELECT SKIP 1 num_cte
				  INTO cCte
				  FROM "informix".tmp_si_ht_detalle_ctrl_tels
				 WHERE folio_archivo = cFolioArchivo 
				   AND telefono = cTelefono
					
				LET iNumSecCte = iNumSecCte + 1;
				
				UPDATE "informix".tmp_si_ht_detalle_ctrl_tels
				   SET sec_cte = iNumSecCte
				 WHERE folio_archivo = cFolioArchivo 
				   AND num_cte = cCte 
				   AND telefono = cTelefono;
				
				LET iNumTelsDup = iNumTelsDup + 1;
			END FOREACH
		END FOREACH
		
		--// OBTIENE EL NUMERO TOTAL DE CLIENTES
		SELECT COUNT(*)
		  INTO iTotCtes
		  FROM "informix".tmp_si_ht_detalle_ctrl_tels
		 WHERE folio_archivo = cFolioArchivo;
		
		LET iTotCtes = NVL(iTotCtes,0);
		
		DROP TABLE tmp_si_ht_detalle_ctrl_tels;
		
	END IF
    
    RETURN cCodRet, cFolioArchivo, iTotCtes, iNumTelsDup;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_cons_bts_aud(pTipo INTEGER,
											pFechaIni CHAR(10),
											pFechaFin CHAR(10),
											pEmpresa CHAR(3),
											pSucursal CHAR(4),
											pCodigo CHAR(4),
											pUsuario CHAR(8),
											pSkip INTEGER,
											pLimite INTEGER)  
RETURNING 
		  CHAR(5)  AS CodRet,
		  CHAR(10) AS Fecha,
		  CHAR(12) AS Hora,
		  CHAR(16) AS Folio,
		  CHAR(8) AS Usuario,
		  CHAR(4) AS Sucursal,
		  CHAR(17) AS Importe,
		  CHAR(4) AS Transaccion,
		  CHAR(20) AS Clave_de_Confirmacion,
		  CHAR(104) AS Beneficiario,
		  CHAR(25) AS Identificacion,
		  CHAR(25) AS Folio_Identificacion,
		  CHAR(45) AS Forma_de_Pago,
		  CHAR(20) AS Cuenta,
		  CHAR(4) AS Trans_Suc,
		  INTEGER  AS TotRows;
			
--Definicion de Variables
DEFINE cCodRet				CHAR(5);
DEFINE cHora				CHAR(12);
DEFINE cFolio				CHAR(16);
DEFINE cUsuario				CHAR(8);
DEFINE cSucursal			CHAR(4);
DEFINE cImporte				CHAR(17);
DEFINE cTransaccion			CHAR(4);
DEFINE cCveConfirm			CHAR(20);
DEFINE cBeneficiario 		CHAR(104);
DEFINE cIdentificacion 		CHAR(25);
DEFINE cFolioIdentificacion	CHAR(25);
DEFINE cFormaPago			CHAR(45);
DEFINE cCuenta				CHAR(20);
DEFINE cTransacSuc			CHAR(4);
DEFINE dFecha				DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iFechAnio 			INTEGER;
DEFINE iLinea				INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE iSqlErr 				INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFechaActual			DATE;


LET cCodRet 				= "";
LET dFecha 					= DATE(1);
LET cHora 					= "";
LET cFolio 					= "";
LET cUsuario 				= "";
LET cSucursal 				= "";
LET cImporte 				= "";
LET cTransaccion 			= "";
LET cCveConfirm 			= "";
LET cBeneficiario 			= "";
LET cIdentificacion 		= "";
LET cFolioIdentificacion 	= "";
LET cFormaPago 				= "";
LET cCuenta 				= "";
LET cTransacSuc 			= "";
LET dFechaIni 				= DATE(1);
LET dFechaFin 				= DATE(1);
LET dFechaHoy 				= DATE(1);
LET dFechaParaMovhisOld 	= DATE(1);
LET dFechaParaMovhisOld2 	= DATE(1);
LET iFechAnio 				= 0;
LET iLinea 					= 0;
LET cFechaParaMovhisOld 	= "";
LET cFechaParaMovhisOld2 	= "";
LET cFechaIni 				= "";
LET cFechaFin 				= "";
LET cDia 					= "";
LET cMes 					= "";
LET cAnio 					= "";
LET iTotalRows 				= 0;
LET dFechaActual            = DATE(1);

/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Remesas BTS" desde la tabla si_rptcaja_aud                                       /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 26/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*-------------------------------------------------------------------------------------------------*/

--SET DEBUG FILE TO '/tmp/sp_cons_bts_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND usuario = pUsuario
			AND cod_transacc = pCodigo;
			--AND fecha_inicio = dFechaIni 
			--AND fecha_fin = dFechaFin;
			
			LET dFecha 					= "";
			LET cHora 					= "";
			LET cFolio 					= "";
			LET cUsuario 				= "";
			LET cSucursal 				= "";
			LET cImporte 				= "";
			LET cTransaccion 			= "";
			LET cCveConfirm 			= "";
			LET cBeneficiario 			= "";
			LET cIdentificacion 		= "";
			LET cFolioIdentificacion 	= "";
			LET cFormaPago 				= "";
			LET cCuenta 				= "";
			LET cTransacSuc 			= "";
			LET iTotalRows 				= 0;
			
			RETURN cCodRet,dFecha,cHora,cFolio,cUsuario,cSucursal, cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc,iTotalRows;
			
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
					
				LET cFechaIni = pFechaIni;
				LET cDia = SUBSTRING(cFechaIni FROM 1 FOR 2);
				LET cMes =  SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
				LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

				LET cFechaFin = pFechaFin;
				LET cDia = SUBSTRING(cFechaFin FROM 1 FOR 2);
				LET cMes =  SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
				LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
				
				SELECT DISTINCT(COUNT(folio))
				INTO iTotalRows
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S';
				FOREACH
				
					SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,transaccion,clave_confir, beneficiario, identificacion, folio_identif, trim(referencia),cuenta,transacc_suc
					INTO dFecha,cHora,cFolio,cUsuario, cSucursal,cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc
					FROM bdinteg:"informix".si_rptcaja_aud
					WHERE empresa = pEmpresa
					AND sucursal = pSucursal
					AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
					AND fecha BETWEEN dFechaIni AND dFechaFin
					AND reversado <> 'S'
					ORDER BY fecha,hora ASC
					
					LET cCodRet = '00000'; --Sin Errores
					
					RETURN cCodRet,dFecha,cHora,cFolio,cUsuario,cSucursal, cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc, iTotalRows WITH RESUME;
					
				END FOREACH;
			
			LET pSkip = pSkip + pLimite ;
			
END
END PROCEDURE;