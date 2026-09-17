CREATE PROCEDURE "informix".sp_ht_obtener_tels_sin_guardar()
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
		--IFRS Se contemplan los nuevos estatus por etapas  equivalente a vencidos
		SELECT {+INDEX (si_bitacora_tel idx_bitactel_cte)}
			   dos.num_credito, crd.numcte
		  FROM bdicred: "informix".sd_maesdos dos
		 INNER JOIN bdicred: "informix".sd_maecred crd ON (dos.num_credito = crd.num_credito)
		 INNER JOIN "informix".si_bitacora_tel bt ON (bt.numcte = crd.numcte)
		 WHERE crd.status_Cred IN ('BA','BT','E1','E2','E3')
		   AND (dos.monto_vencido + dos.mto_venc_trasp) > 0
		 --WHERE crd.status_cred IN ("BA","BT")
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

CREATE PROCEDURE "informix".sp_ini_session_bex_mx2(pNumCel char(10),pImei CHAR(150), pUdid CHAR(150), pIp char(15))
   RETURNING CHAR(5), CHAR (20), CHAR(26), CHAR(26), CHAR(26), CHAR(26),  VARCHAR(2), DATETIME YEAR TO SECOND, VARCHAR(11), VARCHAR(5),CHAR(20),CHAR(100),money(14,2),DECIMAL(18,2),VARCHAR(2),VARCHAR(2);
   
	DEFINE cCod_ret 			 CHAR(5);
	DEFINE iSql_err 			 INTEGER ;
	DEFINE cNumCliente 			 CHAR (20);
	DEFINE sIdStatus 			 VARCHAR (2);
	DEFINE cNombre1, cNombre2, cApellPaterno, cApellMaterno CHAR (26);
	DEFINE iIdStatusToken 		 INTEGER;
	DEFINE dFecPrimAcceso 		 DATE;
	DEFINE dFecUltAcceso 		 CHAR(19);
	DEFINE dFecha  				 DATETIME YEAR TO SECOND;
	DEFINE vIdUsuario 			 VARCHAR(11);
	DEFINE cPass 				 CHAR(50);
	DEFINE vIntentos			 varchar(1);
	DEFINE vCodRetInt  			 CHAR(5);
	DEFINE vCanal				 CHAR(10);
	DEFINE vCtaAso				 CHAR(20);
	DEFINE pUser 				 INTEGER;
	DEFINE pCanal 				 INTEGER;
	DEFINE vLogCta 				 INTEGER;
	DEFINE vCta					 CHAR(20);
	DEFINE Vsdo 				 money(14,2);
	
	DEFINE cCodRet           	 CHAR(6);
	DEFINE cMensajeRet       	 CHAR(80);
	DEFINE cNumCredito       	 CHAR(20);
	DEFINE cCodTipCred       	 CHAR(2);
	DEFINE dtFechaOrigen     	 DATE;
	DEFINE dtFechaProxPago   	 DATE;
	DEFINE dPagoMinimo       	 DECIMAL(18,2);
	DEFINE dtFechaUltPago    	 DATE;
	DEFINE iPlazo            	 INTEGER;
	DEFINE iPagosRealizados  	 INTEGER;
	DEFINE dLineaOtorgada    	 DECIMAL(18,2);
	DEFINE dTasaInteres      	 DECIMAL(9,6);
	DEFINE dTasaMoratorios   	 DECIMAL(9,6);
	DEFINE dMontoSBC         	 DECIMAL(14,2);
	DEFINE dCapVig           	 DECIMAL(18,2);
	DEFINE dCapTrans         	 DECIMAL(18,2);
	DEFINE dCapVdoExig       	 DECIMAL(18,2);
	DEFINE dCapVdoNoExig     	 DECIMAL(18,2);
	DEFINE dSdoActCap        	 DECIMAL(18,2);
	DEFINE dIntVig           	 DECIMAL(18,2);
	DEFINE dIntVdo           	 DECIMAL(18,2);
	DEFINE dIntMoratorio     	 DECIMAL(18,2);
	DEFINE dIntMoratorio_d	 	 DECIMAL(18,2);
	DEFINE dIntMes           	 DECIMAL(18,2);
	DEFINE dSdoActInt        	 DECIMAL(18,2);
	DEFINE dIvaIntVig        	 DECIMAL(18,2);
	DEFINE dIvaIntVdo        	 DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
	DEFINE dIvaIntMes        	 DECIMAL(18,2);
	DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
	DEFINE dComPend          	 DECIMAL(18,2);
	DEFINE dIvaCom           	 DECIMAL(18,2);
	DEFINE dSdoRetenido      	 DECIMAL(18,2);
	DEFINE dSdoTotalLiq      	 DECIMAL(18,2);
	DEFINE dtIvaFechaPag         DATE;
	DEFINE dtFechaCuota          DATE;
	DEFINE dIntDevengado         DECIMAL(18,2);
	DEFINE dIvaIntDevengado      DECIMAL(18,2);
	DEFINE dLineaDisponible      DECIMAL(18,2);
	DEFINE dPagosVdos            DECIMAL(18,2);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
	DEFINE dFactorComision       DECIMAL(18,2);
	DEFINE dtMesiversario        DATE;
	DEFINE dtFechaHoy            DATE;
	DEFINE cTipCred              CHAR(2);
	DEFINE cDescStatusCred   	 CHAR(60);
	DEFINE iIdUnidadProd     	 INTEGER;
	DEFINE cCodCaract2       	 CHAR(3);
	DEFINE nCtaCred				 VARCHAR(2);
	DEFINE nCtaCap				 VARCHAR(2);
	DEFINE vNombre				 CHAR(100);
	
	LET cCodRet               = '';
	LET cMensajeRet           = '';
	LET cNumCredito           = '';
	LET cCodTipCred           = '';
	LET cDescStatusCred       = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMoratorio_d       = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dtIvaFechaPag         = DATE(1);
	LET dtFechaCuota          = DATE(1);
	LET dIntDevengado         = 0;
	LET dIvaIntDevengado      = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescSitEspCred       = '';
	LET dFactorComision       = 0;
	LET dtMesiversario        = DATE(1);
	LET dtFechaHoy            = DATE(1);
	LET cTipCred              = '';
	LET nCtaCred			  = '0';
	LET nCtaCap				  = '0';
	LET cCod_ret  			  = "00000";
	LET cNumCliente  		  = '';
	LET sIdStatus 			  = '0';
	LET cNombre1 			  = '';
	LET cNombre2 			  = '';
	LET cApellPaterno  		  = '';
	LET cApellMaterno  		  = '';
	LET iIdStatusToken 		  = 0;
	LET dFecUltAcceso 		  = '';
	LET dFecha				  = NULL;
	LET vIdUsuario 			  = '';
	LET cPass 				  = '';
	let vIntentos			  = '0';
	LET vCodRetInt			  = '';
	LET vCanal				  = '';
	LET vCtaAso				  = '';
	LET pUser				  = 0;
	LET pCanal				  = 0;
	LET vCta				  = '';
	LET Vsdo				  = 0;
	LET vNombre				  = '';
		
	
  BEGIN

   ON EXCEPTION SET iSql_err
	  IF iSql_err <> 0 THEN
			LET cCod_ret = iSql_err;
		   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	  END IF ;
   END EXCEPTION ;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT id_usuario, a.num_cliente, 
	a.estatus_servicio,a.fecha_ulti_acceso,	cuenta
	INTO vIdUsuario,cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
	FROM bdibpi:"informix".bpi_registro_bex a WHERE a.no_celular = pNumCel AND a.estatus_servicio <> '2';
	
	IF dFecUltAcceso IS NULL THEN
		LET dFecUltAcceso=substring (current::varchar(23) from 1 for 19);
	ELSE
		LET dFecUltAcceso= substring (dFecUltAcceso::varchar(23)from 1 for 19);
	END IF;
	
	
	/*SELECT id_usuario, a.num_cliente, a.estatus_servicio,
	CASE WHEN a.fecha_ulti_acceso IS NULL THEN substring (current::varchar(23) from 1 for 19)
	ELSE substring (a.fecha_ulti_acceso::varchar(23)from 1 for 19)
	END fecha_ulti_acceso, cuenta
	INTO vIdUsuario,cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
	FROM bdibpi:"informix".bpi_registro_bex a WHERE a.no_celular = pNumCel AND a.estatus_servicio <> '2';
	*/
	--Consulta si existe una sesion en otro canal de banca por internet
	SELECT COUNT(canal) INTO pCanal FROM  bpi_doblesesion WHERE numcliente = cNumCliente;
	
	IF pCanal = 1 THEN
		SELECT canal INTO vCanal FROM  bpi_doblesesion WHERE numcliente = cNumCliente;
	END IF;

	IF vCanal = '' THEN 
		LET vCanal = '0';
	ELSE
		IF vCanal = 'PORTALBPI' THEN
			LET vCanal = '1';
		END IF;	
		IF vCanal = 'APPS' THEN
			LET vCanal = '2';
		END IF;	
		IF vCanal = 'BEX' THEN
			LET vCanal = '3';
		END IF;	
		--GM3.PDRH.- INI: Se agrega "vCanal = 4" para tener un cÃ³digo de retorno.
		IF vCanal = 'BMOVI' THEN
			LET vCanal = '4';
		END IF;	
		--GM3.PDRH.- FIN
	END IF;
	
	SELECT COUNT(no_celular) INTO pUser FROM bdibpi:bpi_registro_bex WHERE imei=pImei AND udid=pUdid AND no_celular=pNumCel AND servicio='activo';
	
	IF pUser = 0 THEN
		LET cCod_ret = '00003';
		RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	END IF
	
	
	
	IF NVL(cNumCliente,'') != ''  THEN
	
		
		SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
		INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
		FROM bdinteg:"informix".si_cliente si WHERE si.numcte = cNumCliente;
	
		IF sIdStatus = '1' THEN
		
			SELECT numero_intentos INTO vIntentos FROM bdibpi:"informix".bpi_ctl_inicio_sesion_bex b  
			WHERE no_celular = pNumCel  AND id_usuario=vIdUsuario AND  DATE(fecha_inicio_acces) = TODAY;
	
			IF vIntentos = '2' THEN 
			
				UPDATE bdibpi:"informix".bpi_registro_bex SET estatus_servicio = '3', fecha_modificada = CURRENT WHERE no_celular=pNumCel  AND estatus_servicio = '1';
				LET cCod_ret = '00001';
				RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
			END IF;
			
		--ACTUALIZA ULTIMO ACCESO en bpi_usuario
			IF NVL(vIdUsuario, '') <> '' THEN
				UPDATE bdibpi:"informix".bpi_registro_bex SET fecha_ulti_acceso = CURRENT 
				WHERE id_usuario=vIdUsuario AND num_cliente = cNumCliente AND no_celular = pNumCel AND estatus_servicio = '1';
				LET cCod_ret = '00000';  -- Sesion iniciada
			END IF;
		END IF;			
			
		IF sIdStatus = '3' THEN

			LET cCod_ret = '00001'; --Usuario Bloqueado por numero de intentos
		
		END IF;	
	
	ELSE
		LET cCod_ret = '00002';  -- Usuario invalido
	END IF ;
	
	IF cCod_ret = '00000' THEN
	--IFRS Se contemplan los nuevos estatus por etapas 
	--SELECT COUNT(num_credito) INTO nCtaCred FROM bdicred:sd_maecred WHERE status_cred IN('AA','BA','BT','VP') AND numcte=cNumCliente;
		SELECT COUNT(num_credito) INTO nCtaCred FROM bdicred:sd_maecred WHERE status_cred IN('AA','BA','BT','VP','E1','E2','E3') AND numcte=cNumCliente;

	SELECT COUNT(cuenta) INTO nCtaCap FROM bdicheq:sc_maechq WHERE status_cta not in ('2') AND num_cte=cNumCliente;
	
		LET vLogCta=LENGTH(vCtaAso);
		
		IF vLogCta = 11 THEN 
			
			SELECT mc.cuenta, (mc.sdo_actual-mc.sdo_retenido-mc.sdo_cong-mc.imp_chq_sbg) as sdo
				INTO  vCta, Vsdo  
				FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
				WHERE mc.cuenta = vCtaAso
				AND mc.status_cta not in ('2')
				AND pr.empresa = mc.empresa 
				AND pr.producto = mc.producto;


			SELECT pr.nombre
			INTO vNombre
				FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto AS pr
				WHERE mc.num_cte = cNumCliente
				AND mc.cuenta = vCtaAso
				AND mc.status_cta = '1'
				AND pr.empresa = mc.empresa 
				AND pr.producto = mc.producto
				AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500');
			

				
		END IF;
		
		IF vLogCta = 16 THEN 
			
			SELECT  num_credito INTO vCta 
			FROM bdicred:sd_tarjeta where num_tarjeta = vCtaAso;
			
			EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general('001',vCta) INTO cCodRet, cMensajeRet, cNumCredito, cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,
				dtFechaUltPago,iPlazo, iPagosRealizados, dLineaOtorgada,dTasaInteres, dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,
				dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta,cSitCte,cCausaCte,
				cDescSitEspCte,cSitCred,cCausaCred,cDescSitEspCred;
			--IFRS Se contemplan los nuevos estatus por etapas 
			SELECT df.nombre_prod
			INTO vNombre 
				FROM bdicred:"informix".sd_maecred mc
				--join bdicred:"informix".sd_tarjeta tr on (tr.empresa = '001' and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = '001' and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
				join bdicred:"informix".sd_tarjeta tr on (tr.empresa = '001' and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT','E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = '001' and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
				join bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
				WHERE mc.numcte = cNumCliente 
				AND tr.num_tarjeta = vCtaAso
				AND mc.num_producto IN ('6600','7000','8100','6001');
			
		END IF;
			
	END IF;
		
  RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;

END
END PROCEDURE;