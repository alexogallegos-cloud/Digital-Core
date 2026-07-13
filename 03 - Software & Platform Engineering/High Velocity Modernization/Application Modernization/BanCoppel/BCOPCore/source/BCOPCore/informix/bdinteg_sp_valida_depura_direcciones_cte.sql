CREATE PROCEDURE "informix".sp_valida_depura_direcciones_cte(pNumCte CHAR(20))
				RETURNING CHAR(5) AS cCodRet, BOOLEAN AS bCteValido;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
--VARIABLES
DEFINE bCteValido		BOOLEAN;
DEFINE iCountReg		INTEGER;
DEFINE bTieneProductos	BOOLEAN;

--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET bCteValido			= 'f';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, bCteValido;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_valida_depura_direcciones_cte.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_valida_depura_direcciones_cte.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se valida que el cliente no cuente con productos de captación, crédito e inversion activos.
	EXECUTE PROCEDURE "informix".sp_cte_tiene_productos(pNumCte) INTO cCodRet, bTieneProductos;
	IF (cCodRet <> '00000') OR (bTieneProductos = 't') THEN
		return cCodRet, bCteValido;
	END IF;			
	
	--Se valida que el cliente no tenga solicitudes de crédito en proceso.
	SELECT 
	{+AVOID_FULL (bdisolic:"informix".ss_solicitudes)}
	COUNT(*)
	INTO iCountReg
	FROM bdisolic:"informix".ss_solicitudes
	WHERE
	numcte = pNumCte
	AND tipo_solicitud IN ('T', 'C', 'P')--Tarjeta, Credito, Prestamo
	AND status_solicitud NOT IN ('RT'--Rechazada
	, 'AN'--Anulada por el Cliente
	, 'CN'--Cancelada
	, 'RP'--Rechazo por Precalificación
	, 'CM')--Cancelación por Mesa de Control
	;
	IF iCountReg > 0 THEN
		return cCodRet, bCteValido;
	END IF;			

	--Se valida que el cliente no sea un usuario de remesas.
	SELECT 
	{+AVOID_FULL (bdisac:"informix".sac_cte_remesas)}
	COUNT(*)
	INTO iCountReg
	FROM bdisac:"informix".sac_cte_remesas
	WHERE numcte = pNumCte
	;
	IF iCountReg > 0 THEN
		return cCodRet, bCteValido;
	END IF;			

	--Se valida que el cliente no sea un cliente adicional a una cuenta.
	SELECT 
	{+AVOID_FULL (bdicheq:"informix".sc_firmantes)}
	COUNT(*)
	INTO iCountReg 
	FROM bdicheq:"informix".sc_firmantes
	WHERE numcte = pNumCte
	;
	IF iCountReg > 0 THEN
		return cCodRet, bCteValido;
	END IF;			
	
	LET bCteValido = 't';
	return cCodRet, bCteValido;
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 01/03/2021',
'MODULO: Integral',
'BD: bdinteg',
'DESCRIPCION: Valida si a un cliente se pueden depurar sus direcciones registradas',
'Devuelve t en caso de que se puedan depurar las direcciones del cliente, en caso contrario retorna f'
;

CREATE PROCEDURE "informix".sp_depura_direcciones_prospectos()
				RETURNING CHAR(5) AS cCodRet;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
--VARIABLES
DEFINE bCteValido		BOOLEAN;
DEFINE dFechIni			DATE;
DEFINE dFechFin			DATE;
DEFINE bContinuaProc	BOOLEAN;
DEFINE iTipoCtePros		SMALLINT;
DEFINE iCountReg		INTEGER;
DEFINE dHoraInicio		DATETIME HOUR TO MINUTE;
DEFINE dCurrentTime		DATETIME HOUR TO MINUTE;
DEFINE dMaxTime			INTEGER;
DEFINE intervalo 		INTERVAL minute(9) TO MINUTE;
DEFINE cadena 			VARCHAR(12);
DEFINE entero 			INTEGER;
DEFINE iCont			INTEGER;
DEFINE iMaxCommit		SMALLINT;
DEFINE cNumCte			CHAR(20);
DEFINE iSecuencia		INTEGER;


--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET dFechIni			= NULL;
LET dFechFin			= NULL;
LET bContinuaProc		= 't';
LET iTipoCtePros		= 2;
LET iCountReg 			= 0 ;	
LET dHoraInicio			= CURRENT hour to minute;
LET dCurrentTime		= NULL;
LET dMaxTime			= 105;
LET iMaxCommit			= 5000;
LET cNumCte				= '';


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_depura_direcciones_prospectos.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_depura_direcciones_prospectos.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones_actual), AVOID_FULL ("informix".si_cliente)}
		DISTINCT(d.numcte)
		INTO cNumCte
		FROM "informix".si_direcciones_actual d
		INNER JOIN "informix".si_cliente cte ON cte.numcte = d.numcte
		WHERE 
		d.fecha_insert = TODAY-1
		AND cte.tipo_cliente = iTipoCtePros
		
		--Se valida que se puedan depurar las direcciones del cliente.
		EXECUTE PROCEDURE "informix".sp_valida_depura_direcciones_cte(cNumCte) INTO cCodRet, bCteValido;
		IF (cCodRet <> '00000') OR (bCteValido = 'f') THEN
			CONTINUE FOREACH;
		END IF;			
		
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones_actual)}
		COUNT(*)
		INTO iCountReg 
		FROM "informix".si_direcciones_actual
		WHERE numcte = cNumCte
		;
		
		IF iCountReg > 0 THEN
			--Se depuran las direcciones actuales del prospecto
			DELETE "informix".si_direcciones_actual 
			WHERE numcte = cNumCte;
			
			LET iCont = iCont + iCountReg;
		END IF;
			
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones)}
		COUNT(*)
		INTO iCountReg 
		FROM "informix".si_direcciones
		WHERE numcte = cNumCte
		;
		
		IF iCountReg > 0 THEN
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones_his)}
			MAX(secuencia) 
			INTO iSecuencia
			FROM "informix".si_direcciones_his
			WHERE numcte = cNumCte;
			
			IF iSecuencia IS NULL OR iSecuencia = 0 THEN
				LET iSecuencia = 0;
			END IF;
			
			--Se respaldan los registros a depurar
			INSERT INTO "informix".si_direcciones_his (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3)
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones)}
			numcte, (secuencia + iSecuencia) as secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
			FROM "informix".si_direcciones
			WHERE numcte = cNumCte
			ORDER BY secuencia asc
			;
		
			--Se depuran las direcciones del prospecto
			DELETE "informix".si_direcciones
			WHERE numcte = cNumCte;
			
			LET iCont = iCont + (iCountReg * 2);
		END IF;
			
		IF iCont >= iMaxCommit THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;
	COMMIT WORK;
		
	LET iCont = 0;
	BEGIN WORK;
	--Se obtiene el valor de la fecha de inicio para depurar las direcciones de los prospectos
	SELECT 
	TO_DATE(valor, "%d/%m/%Y")
	INTO dFechFin
	FROM "informix".si_param
	WHERE descripcion ='Fecha ini depurar direcciones prospectos'
	;
	
	IF dFechFin >= TODAY-1 THEN
		LET bContinuaProc = 'f';
		LET dFechFin = TODAY;
		--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecución comience en dicho día
		UPDATE 
		"informix".si_param 
		SET valor = TO_CHAR(dFechFin, '%d/%m/%Y')
		WHERE descripcion ='Fecha ini depurar direcciones prospectos'
		;
	END IF;

	WHILE (bContinuaProc) LOOP
	
		LET dFechIni = dFechFin;
		LET dFechFin = dFechIni + 30 UNITS DAY;
		
		IF (dFechFin > TODAY) THEN
			LET dFechFin =TODAY;
		END IF;

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_direcciones)}
			DISTINCT(a.numcte)
			INTO cNumCte
			FROM "informix".si_cliente a
			INNER JOIN "informix".si_direcciones d ON d.numcte=a.numcte
			WHERE 
			a.tipo_cliente = iTipoCtePros
			AND a.fecha_insert BETWEEN dFechIni AND dFechFin
			
			--Se valida que el cliente no cuente con productos de captación, crédito e inversion activos.
			EXECUTE PROCEDURE "informix".sp_valida_depura_direcciones_cte(cNumCte) INTO cCodRet, bCteValido;
			IF (cCodRet <> '00000') OR (bCteValido = 'f') THEN
				CONTINUE FOREACH;
			END IF;			
			
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones_actual)}
			COUNT(*)
			INTO iCountReg 
			FROM "informix".si_direcciones_actual
			WHERE numcte = cNumCte
			;
			
			IF iCountReg > 0 THEN
				--Se depuran las direcciones actuales del prospecto
				DELETE "informix".si_direcciones_actual 
				WHERE numcte = cNumCte;
				
				LET iCont = iCont + iCountReg;
			END IF;
				
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones)}
			COUNT(*)
			INTO iCountReg 
			FROM "informix".si_direcciones
			WHERE numcte = cNumCte
			;
			
			IF iCountReg > 0 THEN
				SELECT 
				{+AVOID_FULL ("informix".si_direcciones_his)}
				MAX(secuencia) 
				INTO iSecuencia
				FROM "informix".si_direcciones_his
				WHERE numcte = cNumCte;
				
				IF iSecuencia IS NULL OR iSecuencia = 0 THEN
					LET iSecuencia = 0;
				END IF;
				
				--Se respaldan los registros a depurar
				INSERT INTO "informix".si_direcciones_his (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3)
				SELECT 
				{+AVOID_FULL ("informix".si_direcciones)}
				numcte, (secuencia + iSecuencia) as secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
				FROM "informix".si_direcciones
				WHERE numcte = cNumCte
				ORDER BY secuencia asc
				;
				
				--Se depuran las direcciones del prospecto
				DELETE "informix".si_direcciones
				WHERE numcte = cNumCte;
				
				LET iCont = iCont + (iCountReg * 2);
			END IF;
				
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en casod e que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF( (entero >= dMaxTime) OR (dFechFin = TODAY)) THEN
			LET bContinuaProc = 'f';
			--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecución comience en dicho día
			UPDATE 
			"informix".si_param 
			SET valor = TO_CHAR(dFechFin, '%d/%m/%Y')
			WHERE descripcion ='Fecha ini depurar direcciones prospectos'
			;
		END IF;
	END LOOP;
	COMMIT WORK;
	RETURN cCodRet;	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 01/03/2021',
'MODULO: Integral',
'BD: bdinteg',
'DESCRIPCION: Depura las direcciones de los prospectos'
;

CREATE PROCEDURE "informix".sp_bitacora_renapob (Pnumcte CHAR(20),pMsjResp CHAR(100), pStatus  CHAR(3),pTransaccion  CHAR(6))
					
				
	RETURNING CHAR(5);

	DEFINE cCodRet 			CHAR(5);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE Iexiste			INTEGER;
	
		
	LET cCodRet 	  ='00000';
	LET iSqlErr 	  = 0;
	LET Iexiste		  = 0;
	
	
--	SET DEBUG FILE TO '/home/sysifx/Selene/sp_bitacora_renapob.out';
--	TRACE ON;
	
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF NVL(pNumcte,'') = ''  THEN
	
		LET cCodRet = '00001'; --Datos vacios
		RETURN cCodRet;
		
	ELSE
	
		SELECT COUNT(numcte) INTO Iexiste FROM "informix".si_bitacora_renapob WHERE numcte = Pnumcte;
	
		IF Iexiste > 0 THEN
			
			UPDATE "informix".si_bitacora_renapob SET fecha_insert=CURRENT, mensaje_resp=pMsjResp ,status= pStatus, transacc= pTransaccion WHERE numcte = pNumcte;
			
		ELSE
			
			--INSERSION EN BITACORA RENAPO
			INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
			VALUES (pNumcte,CURRENT,pMsjResp,pStatus,pTransaccion);

		
		END IF;
	END IF;
	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
"Autor :Selene Campos 95296042",
"FECHA : 25/01/2021",
"BD    : Bdinteg",
"Descripcion: Se crea procedimiento para guardar los datos de la consulta ante RENAPO";

CREATE PROCEDURE "informix".sp_borrar_curp (Pnumcte CHAR(20),pTipo INTEGER, pEmpresa CHAR(3),pSituacion CHAR(1), pCausa SMALLINT, pTipoMovto CHAR(1), pCveSitEspOrigen CHAR(12), pSucursal CHAR(4), pEmpleadoEfectuo CHAR(8), pNombreEfectuo CHAR(40), pUsrModifica CHAR(9), pMsjModifica CHAR(100) )
					
				
	RETURNING CHAR(5);

	DEFINE cCodRet 			CHAR(5);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE Iexiste			INTEGER;
	DEFINE iPonderacion		SMALLINT;
	DEFINE cSituacion		CHAR(1);
	DEFINE iCausa		 	SMALLINT;

		
	LET cCodRet 	  ='00000';
	LET iSqlErr 	  = 0;
	LET Iexiste		  = 0;
	LET iPonderacion  = 0;
	LET cSituacion	  = '';
	LET iCausa  = 0;


	
--	SET DEBUG FILE TO '/home/sysifx/Selene/sp_borrar_curp.out';
--	TRACE ON;
	
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF (NVL(pNumcte,'') = ''  OR NVL(pTipo,'') = '' OR NVL(pEmpresa,'') = '' OR NVL(pSituacion,'') = '' OR NVL(pCausa,'') = '' OR NVL(pCveSitEspOrigen,'') = ''OR NVL(pEmpleadoEfectuo,'') = '' OR NVL(pTipoMovto,'') = ''  OR NVL(pSucursal,'') = '' OR NVL(pNombreEfectuo,'') = '' ) THEN
			
				
		LET cCodRet = '00001'; --Datos vacios
		RETURN cCodRet;
		
	ELSE
	
		SELECT COUNT(numcte) INTO Iexiste FROM "informix".si_ctepf WHERE numcte = Pnumcte;
	
		IF Iexiste > 0 THEN
			
			UPDATE "informix".si_ctepf SET curp= '' WHERE numcte = pNumcte;
			
			--Asignar la sistuacion especial C2
			EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp (pTipo, TRIM(NVL(pEmpresa,'')),TRIM(NVL(Pnumcte,'')), TRIM(NVL(pSituacion,'')), pCausa, TRIM(NVL(pTipoMovto,'')), TRIM(NVL(pCveSitEspOrigen,'')), TRIM(NVL(pSucursal,'')), TRIM(NVL(pEmpleadoEfectuo,'')),  TRIM(NVL(pNombreEfectuo,'')),  TRIM(NVL(pUsrModifica,'')),  TRIM(NVL(pMsjModifica,''))) INTO cCodRet, iPonderacion,cSituacion,iCausa ;
			
			
		ELSE
			
			LET cCodRet = '00002';
			
		
		END IF;
	END IF;
	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
"Autor :Selene Campos 95296042",
"FECHA : 25/01/2021",
"BD    : Bdinteg",
"Descripcion: Se crea procedimiento borrar el campo CURP cuando no se valide correctamente la huella de gerente";

CREATE PROCEDURE "informix".sp_consultacte(cOpcion CHAR(1), cTipoTar  CHAR(1), cNumTarjeta  CHAR(16), cNumCliente CHAR(20), cRFCmh CHAR(13))
	RETURNING 
	CHAR(6),    -- Codigo de retorno
	CHAR(20),   -- # Cliente
	CHAR(110),  -- Nombre Cliente
	CHAR(13),   -- RFC
	CHAR(10), 	-- Fecha nacimiento
	CHAR(30);   -- Tipo Documento
	
	DEFINE cCodRet  	CHAR(6);
	DEFINE cNumeroCte	CHAR(20);
	DEFINE cNombreCte 	CHAR(110);
	DEFINE cRFC     	CHAR(13);
	DEFINE cFechaNac	CHAR(10);
	DEFINE cNumIdenti	CHAR(30);
	DEFINE iSqlErr  	INTEGER;
	DEFINE iExists		INTEGER;
	DEFINE iSecuencia 	INTEGER;
	
	LET cCodRet  	= "000000";
	LET cNumeroCte 	= "";
	LET cNombreCte 	= "";
	LET cRFC 		= "";
	LET cFechaNac 	= "";
	LET cNumIdenti 	= "";
	LET iSqlErr 	= 1;
	LET iExists		= 0;
	LET iSecuencia	= 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet = iSqlErr;				
				RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,cNumIdenti;	
			END IF;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_consultaCte.out";
		--TRACE ON;
		IF (cOpcion = '' OR cOpcion IS NULL) THEN
			LET cCodRet = '000001';
		ELSE
			IF cOpcion = '1' THEN
				IF (cTipoTar = '' OR cTipoTar IS NULL) OR (cNumTarjeta = '' OR cNumTarjeta IS NULL) THEN
					LET cCodRet = '000001';
				ELSE
					IF cTipoTar = 'C' THEN
						SELECT 1 INTO iExists FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = cNumTarjeta and status_tar = 'A';
						IF iExists > 0 THEN
							SELECT cte.numcte, TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) AS nombreCte, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicred
							INTO cNumeroCte, cNombreCte, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicred:"informix".sd_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							IF cRFC <> cRFCmh THEN
								LET cCodRet = '000005';
							END IF;
						ELSE
							LET cCodRet = '000003';
						END IF;
					ELIF cTipoTar = 'D' THEN	
						SELECT 1 INTO iExists FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = cNumTarjeta and status_tar = 'A';
						IF iExists > 0 THEN
							SELECT cte.numcte, TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) AS nombreCte, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicheq
							INTO cNumeroCte, cNombreCte, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicheq:"informix".sc_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							IF cRFC <> cRFCmh THEN
								LET cCodRet = '000005';
							END IF;
						ELSE
							LET cCodRet = '000003';
						END IF;
					END IF;				
				END IF;	
				IF cNumeroCte IS NULL THEN
					LET cCodRet = '000002';
				END IF;	
			ELIF cOpcion = '2' THEN
				IF (cNumCliente = '' OR cNumCliente IS NULL) THEN
					LET cCodRet = '000001';
				ELSE
					SELECT MAX(secuencia) INTO iSecuencia
					FROM bdinteg:"informix".si_huella_temp
					WHERE numcte = cNumCliente;
					
					DELETE FROM bdinteg:"informix".si_huella_temp WHERE numcte = cNumCliente AND secuencia = iSecuencia;
				END IF;
			ELSE
				LET cCodRet = '000004';
			END IF;
		END IF;	
		RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,NVL(cNumIdenti,'');

END
END PROCEDURE
DOCUMENT
'Se crea SP para la consuta de los datos del cliente por numero de tarjeta. Anexo a eso',
'se incluye la opcion del borrado del template temporal de la huella del cliente en caso de fallar el mantenimiento de huella y biometria',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_guardabithbio(cNumCte CHAR(20), cSucursal CHAR(4), cNumUsuario CHAR(10), cIPMaquina CHAR(14), cTipoProceso CHAR(1), 
								 cNumGteAutoriza CHAR(10), cTipoIdent CHAR(1), cNumIdent CHAR(30))
RETURNING CHAR(6)    

DEFINE cCodRet  	CHAR(6);
DEFINE iSqlErr		INTEGER;

LET cCodRet	= "000000";
LET iSqlErr = 1;

BEGIN	

	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_guardabithbio.out";
		--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (cNumCte = '' OR cNumCte IS NULL) OR (cSucursal = '' OR cSucursal IS NULL) OR (cNumUsuario = '' OR cNumUsuario IS NULL) OR (cIPMaquina = '' OR cIPMaquina IS NULL) 
		OR (cTipoProceso = '' OR cTipoProceso IS NULL) OR (cNumGteAutoriza = '' OR cNumGteAutoriza IS NULL) OR (cTipoIdent = '' OR cTipoIdent IS NULL) THEN
		LET cCodRet = '000001';
	ELSE				
		INSERT INTO bdinteg:"informix".si_bitmant_huellarostro(numcte, sucursal, ejecutivo, ip_maquina, fecha_hora, tipo_proceso, numgte_autoriza, tipo_ident, num_ident)
		VALUES(cNumCte, cSucursal, cNumUsuario, cIPMaquina, CURRENT, cTipoProceso, cNumGteAutoriza, cTipoIdent, cNumIdent);			
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para el guardado de bitacora al realizarce mantenimiento de huella y biometria facial del cliente de manera correcta',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".considentificacion(p_numcte char(10))
   RETURNING CHAR(5), CHAR(20), CHAR(20);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_tipoIdent		CHAR(50);
   DEFINE v_noIdent			CHAR(50);

   LET v_tipoIdent = "";
   LET v_noIdent   = "";
	

	--SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
	--TRACE ON;
BEGIN	
	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_tipoIdent, v_noIdent;
	END EXCEPTION;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	
	

	SELECT tipo_ident, num_ident
	INTO v_tipoIdent,v_noIdent 
	FROM "informix".si_bitmant_huellarostro
    	WHERE numcte = trim(p_numcte) AND  fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:"informix".si_bitmant_huellarostro WHERE NUMCTE = trim(p_numcte));
    	
    
    
    IF trim(v_noIdent) is null then
		let cod_ret = "104";
		RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
    end if

    RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
END
END PROCEDURE

DOCUMENT
'SPL Extrae tipo y numero de identificacion ingresados en manhuella',
"MODIFICO : CRISTIAN IBARRA",
"FECHA : 27/Febrero/2021",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sps_obt_numcte_status(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50), pIndicador CHAR(1))
                      returning char(5),char(20),smallint;

	-- Creador: Moises Soriano	
	-- Objetivo: Obtener el número y estatus del cliente,
	-- Se clona sp_obt_numcte_status, se agrega parametro de entrada
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 11/04/2016
					
					  
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_id_status smallint ;
   define v_num_cte char (20);
   define pNumCte char (20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_id_status = 0;
   let v_num_cte = "";
   
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obt_numcte_status.out";
	--TRACE ON;

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_num_cte, v_id_status;
      end if
   end exception;

SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   

   IF pIndicador = '' AND pIdUsuario <> '' THEN
      LET  pIndicador = '1';
   END IF;

  IF pIdUsuario <> '' THEN
		IF pIndicador = '1' THEN  -- pIdUsuario = id_usuario
			SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		ELIF pIndicador = '2' THEN -- pIdUsuario = numcliente
			LET pNumCte = pIdUsuario;
		END IF;
	
        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

             SELECT numcte,id_status INTO v_num_cte, v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte;
			 LET v_num_cte = pNumCte;
             LET cod_ret = '000';

        ELSE

            LET cod_ret = '001';

        END IF ;

  ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT numcte,id_status INTO v_num_cte,v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '002';

        END IF ;

  END IF ;
  
  RETURN cod_ret, v_num_cte, v_id_status;

END

END PROCEDURE ;