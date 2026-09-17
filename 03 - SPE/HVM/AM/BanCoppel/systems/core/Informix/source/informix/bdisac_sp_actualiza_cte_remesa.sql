CREATE PROCEDURE "informix".sp_actualiza_cte_remesa(
							pNumcte     	CHAR(20), 
							pNombre1 		CHAR(26),
							pNombre2 		CHAR(26),
							pApellPat 		CHAR(26),
							pApellMat		CHAR(26),
							pFechaNac		DATE,
							pCodIdent		CHAR(2),
							pNumIdent		CHAR(30),
							pPaisEmision	CHAR(3),
							pFechaVence		DATE,
							pNacionalidad	CHAR(3),
							pPaisNac		CHAR(3),
							pEdoNac			CHAR(2),
							pCiudadNac		CHAR(5),
							pSexo			CHAR(1),
							pEdoDom			CHAR(2),
							pCiudadDom		CHAR(3),
							pMunicipioDom	CHAR(5),
							pColoniaDom		CHAR(60),
							pNroColDom		INTEGER,
							pCalleDom		CHAR(40),
							pNroCalleDom	INTEGER,
							pNroExte		CHAR(10),
							pNroInt			CHAR(10),
							pCodPostal		CHAR(5),
							pTelCasa		CHAR(13),
							pTelCelular		CHAR(13),
							pRfc			CHAR(13),
							pNumEnvios		CHAR(7),
							pEmpleado		CHAR(8),
							pSucursal		CHAR(4),
							pTipoCliente	INTEGER,
							pTipoCteRem		CHAR(2),
							pEmpresa		CHAR(3),
							pfecha			DATE,
							pCodOcupacion	INTEGER,
							pDepartamento   CHAR(6))
														
--DATOS DE SALIDA							
RETURNING
	CHAR(5)  AS cCodRet,
	CHAR(20) AS Numcte,
	CHAR(1)	 AS FlagTel;
	
--DECLARACION DE VARIABLES
DEFINE iSqlErr        		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cCodRet        		CHAR(5);
DEFINE iSignumcte 			INTEGER;
DEFINE vCanal				SMALLINT;	
DEFINE v_CodRetTel			CHAR(5);
DEFINE v_CodRetCofetel		CHAR(5);
DEFINE v_CorRetAper			CHAR(5);
DEFINE v_SecAper			INTEGER;
DEFINE v_ErrAper			INTEGER;
DEFINE iSecuenciaDom		INTEGER;
DEFINE cFlagCofetelCasa		CHAR(1);
DEFINE cFlagCofetelCel		CHAR(1);
DEFINE cSecOcupa			INTEGER;
DEFINE sLong_cte			SMALLINT;
DEFINE sDiferencia			SMALLINT;
DEFINE sI 					SMALLINT;
DEFINE sFlagTel				CHAR(1);
DEFINE iTipoDir				INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr     = 0;
LET iIsamErr    = 0;
LET cCodRet	    = '00000';
LET iSignumcte  = 0;
LET vCanal	    = 1;
LET v_CodRetTel = "";
LET v_CodRetCofetel = "";
LET v_CorRetAper = "";
LET cFlagCofetelCasa = "0";
LET cFlagCofetelCel = "0";
LET cSecOcupa = 0;
LET sFlagTel = "0";
LET iTipoDir = 0;

SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;
	
--SET DEBUG FILE TO '/informix/Aaron/sp_actualiza_cte_remesa.out';
--TRACE ON;

	BEGIN
	--CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, pNumcte, sFlagTel;
			END IF;
		END EXCEPTION;
		
	IF pSucursal = '5002' THEN
			LET vCanal = 12;
	END IF;
	
	IF pTipoCliente = 3 THEN --Usuario Nuevo
		
		SELECT valor
        INTO sLong_cte
        FROM bdinteg:"informix".si_param
        WHERE cod_param = 7
        AND empresa = pEmpresa;
		
		SELECT valor
		INTO iSignumcte
		FROM bdinteg:"informix".si_param
		WHERE empresa = pEmpresa
		AND cod_param = 6;

		IF iSignumcte IS NULL THEN
			LET iSignumcte = 1;
		END IF;
		
		LET pNumcte= iSignumcte;
		LET iSignumcte=iSignumcte + 1;
		
		LET sDiferencia = sLong_cte - LENGTH(pNumcte);

		IF sDiferencia > 0 THEN
			FOR sI = 1 TO sDiferencia
				LET pNumcte = "0" || pNumcte;
			END FOR;
		END IF;
		
		UPDATE bdinteg:"informix".si_param
		SET (valor) = (iSignumcte)
		WHERE empresa = pEmpresa
		AND cod_param = 6;
		
		--si_cliente
		INSERT INTO bdinteg:"informix".si_cliente(Empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,numeric2,money1,date1,puesto_ppes,familiar_ppes,
		actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno,tpo_biometria,cliente_pros,envio_movtos)
		VALUES(pEmpresa,pNumcte,"AL",pSucursal,pEmpleado,"01","2",pApellPat,pApellMat,pNombre1,pNombre2,"",pRfc,"32","000","000","000","000","1",pFecha,"","01","","","",0,0,0,pFecha,"","",
		"0000000",pEmpleado,pEmpleado,DATE(current),"","0","",0);
		
		--si_ctepf
		INSERT INTO bdinteg:"informix".si_ctepf(empresa,numcte,fecha_nac,lugar_nac,nacionalidad,no_fm3,estado_civil,regim_matrimonio,profesion,sexo,curp,codidentifi,numidentifi,no_imss,dependientes,
		tutor,nom_conyuge,seguro_defunc,escolaridad,habita_en,anios_habita,nombre_prop,imp_hipo_renta, actividadogiro,numeroife,numerotutor,numeroconyuge,string1,string2,numeric1,numeric2,money1,
		date1,user_insert,fecha_insert,sms_cel,hora_insert,validacurp,id_pais)
		VALUES(pEmpresa,pNumcte,pFechaNac,pEdoNac,pNacionalidad,"","","","",pSexo,"",pCodIdent,pNumIdent,"",0,"","",0,"","","","",0,"","","","","","",0,0,0,NULL,pEmpleado,pfecha,"",CURRENT,"",pPaisNac);
		
		--si_direcciones
		INSERT INTO bdinteg:"informix".si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,estado_inegi,municipio_inegi,
		localidad_inegi,numerociudad, numeroextcalle, numerointcalle,departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
		entrada, observaciones, user_insert, fecha_insert)
        VALUES(pNumcte,"1","1",pCalleDom,pColoniaDom,"","001",pEdoDom,pCiudadDom,pMunicipioDom,pCodPostal,"","","","",0,pNroExte,pNroInt,pDepartamento,pNroCalleDom,pNroColDom,"","",0,0,0,0,0,0,0,"",pEmpleado,pfecha);

	ELIF pTipoCliente = 2 THEN --Usuario Banco - Actualizacion de datos
		
		--Actualiza si_ctepf
		UPDATE bdinteg:"informix".si_ctepf SET fecha_nac = pFechaNac, nacionalidad = pNacionalidad,sexo = pSexo,codidentifi = pCodIdent,numidentifi = pNumIdent,id_pais = pPaisNac
		WHERE numcte = pNumcte;
		
		
		--Se verifica si el cliente tiene tipo de direcciÃ?ÃÂ³n 1, si no, se inserta nueva direccion de tipo 1
		SELECT tipo_dir, secuencia INTO iTipoDir, iSecuenciaDom
		FROM bdinteg:"informix".si_direcciones_actual 
		WHERE numcte = pnumcte AND tipo_dir = 1 AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pnumcte AND tipo_dir = 1);
		
		IF NVL(iTipoDir,0) = 0 THEN
		/*	SELECT tipo_dir, secuencia INTO iTipoDir, iSecuenciaDom
			FROM bdinteg:"informix".si_direcciones_actual 
			WHERE numcte = pnumcte AND tipo_dir = 2 AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pnumcte AND tipo_dir = 2);
			
			IF NVL(iTipoDir,0) = 0 THEN
				LET iTipoDir = 0;
			END IF;*/
			--si_direcciones
			SELECT MAX(secuencia) INTO iSecuenciaDom FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pnumcte;
			IF NVL(iSecuenciaDom,0) = 0 THEN
				LET iSecuenciaDom = 1;
			ELSE
				LET iSecuenciaDom = iSecuenciaDom + 1;
			END IF;
			INSERT INTO bdinteg:"informix".si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,estado_inegi,municipio_inegi,
			localidad_inegi,numerociudad, numeroextcalle, numerointcalle,departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
			entrada, observaciones, user_insert, fecha_insert)
			VALUES(pNumcte,iSecuenciaDom,"1",pCalleDom,pColoniaDom,"","001",pEdoDom,pCiudadDom,pMunicipioDom,pCodPostal,"","","","",0,pNroExte,pNroInt,pDepartamento,pNroCalleDom,pNroColDom,"","",0,0,0,0,0,0,0,"",pEmpleado,pfecha);

		ELSE
			
			UPDATE bdinteg:"informix".si_direcciones_actual SET
				calle = pCalleDom,
				colonia = pColoniaDom,
				estado = pEdoDom,
				ciudad = pCiudadDom,
				municipio = pMunicipioDom,
				cod_postal = pCodPostal, 
				numeroextcalle = pNroExte,
				numerointcalle = pNroInt,
				departamento = pDepartamento,
				numerocalle = pNroCalleDom,
				numerocolonia = pNroColDom
			WHERE numcte = pNumcte AND tipo_dir = iTipoDir AND secuencia = iSecuenciaDom;  
		END IF;
	END IF;
	
	--Obtiene secuencia para despues mandarla al procedimiento sp_bitacoraapertura
	SELECT MAX(id_secuencia) INTO cSecOcupa FROM bdinteg:"informix".si_bitacoraapertura 
	WHERE rfc = pRfc;
	
	IF NVL(cSecOcupa,"") = "" THEN
		LET cSecOcupa  = 1;
	ELSE
		LET cSecOcupa = cSecOcupa + 1;
	END IF;	
	
	--Guarda ocupacion 
	CALL bdinteg:"informix".sp_bitacoraapertura (pRfc,pNumcte,6,"", pCodOcupacion,"0","",pfecha,pSucursal,cSecOcupa,"","") RETURNING v_CorRetAper, v_SecAper, v_ErrAper;
	
	IF  v_CorRetAper <> 0 THEN 
			LET cCodRet = "00003";
			RETURN cCodRet, pNumcte, sFlagTel;
	END IF;
	
	INSERT INTO bdisac:"informix".sac_cte_remesas(numcte,fecha_alta,sucursal,status_cte,tipo_cte,pais_emision,fecha_vencimiento,usuario,fecha_insert,numenvios,ciudadnacimiento)
	VALUES(pNumcte,pfecha,pSucursal,"A",pTipoCteRem,pPaisEmision,pFechaVence,pEmpleado,current,pNumEnvios,pCiudadNac);
	
	
	-- Validaciones telefonos
	IF TRIM(pTelCasa) <> "" THEN
		--Registra telefono de casa y valida con cofetel.
		CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumcte, pTelCasa, 1, "", 0, vCanal, pEmpleado) RETURNING v_CodRetTel;
		IF  v_CodRetTel <> 0 THEN 
			LET cCodRet = "00001";
			LET sFlagTel = "1";
			RETURN cCodRet, pNumcte, sFlagTel;
		END IF;
		
		SELECT "1" 
		INTO cFlagCofetelCasa
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = pNumcte AND telefono = pTelCasa AND status_tel = "A" AND tipo_tel = "1";
		
		IF NVL(cFlagCofetelCasa,"") = "" THEN
			LET cFlagCofetelCasa = "0";
		END IF;

	END IF;
	
	--si_telefonos 'Numero de celular
	IF TRIM(pTelCelular) <> "" THEN
		--Registra celular y valida con cofetel.
		CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumcte, pTelCelular, 2, "", 0, vCanal, pEmpleado) RETURNING v_CodRetTel;
		IF  v_CodRetTel <> 0 THEN -- 1166 Codigo 
			LET cCodRet = "00001";
			LET sFlagTel = "2";
			RETURN cCodRet, pNumcte, sFlagTel;
		END IF;
		
		SELECT 1 
		INTO cFlagCofetelCel
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = pNumcte AND telefono = pTelCasa AND status_tel = "A" AND tipo_tel = "2";
		
		IF NVL(cFlagCofetelCel,"") = "" THEN
			LET cFlagCofetelCel = "0";
		END IF;
		
	END IF;
	
	--Validacion cofetel
	CALL bdinteg:"informix".sp_actvalidacioncofetel (pEmpresa,pNumcte,cFlagCofetelCasa,cFlagCofetelCel,"0","1","1") RETURNING v_CodRetCofetel;
	IF  v_CodRetCofetel <> 0 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet, pNumcte, sFlagTel;
	END IF;
	
	RETURN cCodRet, pNumcte, sFlagTel;

END;
END PROCEDURE
DOCUMENT
'FOLIO: 433',
'DESCRIPCION: Actualiza informacion de usuario de remesas',
'AUTOR: MARCO RIVERA',
'SUSTENTO: 433 REQ. Base de datos para el alta de usuarios de remesas',
'FECHA DE CREACION: 21/08/2018',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------',
'FOLIO: 496',
'DESCRIPCION: Actualiza informacion de usuario de remesas',
'AUTOR: MARCO RIVERA',
'SUSTENTO: Homologacion del proyecto RQM 10 784-2 - Base de datos para el alta de usuarios de remesas / Nueva estructura INE',
'FECHA DE CREACION: 23/10/2018',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------',
'FOLIO RATIONAL: 33367',
'DESCRIPCION: OptimizaciÃ³n en el alta para usuarios de remesas',
'AUTOR: MARIO ENRIQUEZ',
'SUSTENTO: Optimizar la manera en la que se registra la informaciÃ³n en los campos que hacen referencia a fechas',
'FECHA DE MODIFICACION: 13/06/2019',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ws_coppel_ta(
											pcAgent_trans_type_code VARCHAR(10),
											pcAgent_cd VARCHAR(6),
											pcUsuario VARCHAR(8),
											pcPassword VARCHAR(8),
											pcIp_origen VARCHAR(15),
											pcSession_id VARCHAR(30),										  
											pDateProcess VARCHAR(8),
											pTimeProcess VARCHAR(8),
											pFechaTran VARCHAR(10),
											pFolio VARCHAR(20),
											pTelefono VARCHAR(10),
											pCompania VARCHAR(15))	
RETURNING
	CHAR(5)	as cCod_retorno,
	CHAR(4)  as  cod_ret,
	char(100) as  mensaje,
	CHAR(10) as cFecha_proceso,
	CHAR(6)   as  cHora_proceso,
	CHAR(20) as	vRecargaSerial,
	CHAR(12) as	vNumCelular,
	CHAR(15) as	vcompania,
	CHAR(10) as vmonto,
	CHAR(10) as cFecha_Recarga,
	CHAR(5) as	vSucursal,
	CHAR(1) as	vcobrado,
	CHAR(80) as	vEstatus;
			
--variables de retorno
	
	DEFINE cod_ret			CHAR(8);
	DEFINE mensaje			CHAR(120);
	DEFINE cod_ret2   		CHAR(8);
	DEFINE cOpcode 			CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(80);
	DEFINE cNombre_proceso	CHAR(17);
	DEFINE cCadena_ent		CHAR(100);
	DEFINE cCod_retorno		CHAR(5);
	DEFINE cFecha_proceso 	CHAR(10);
	DEFINE cCancelado 		CHAR(10);
	DEFINE cHora_proceso 	CHAR(6);
	DEFINE cFecha_Recarga	CHAR(10);
	DEFINE vRecargaSerial 	CHAR(20);
	DEFINE vNumCelular 		CHAR(12);
	DEFINE vcompania 		CHAR(15);
	DEFINE vmonto 			CHAR(10);
	DEFINE vSucursal 		CHAR(5);
	DEFINE vcobrado 		CHAR(1);
	DEFINE vEstatus 		CHAR(80);
	DEFINE vInsStmt			LVARCHAR(2000);
	DEFINE dFechaRecarga	DATE;
	--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER;
	DEFINE iIsamError 		INTEGER;
	--variables del proceso
	DEFINE	vdiv 			INTEGER;
	DEFINE cTablaBusq		VARCHAR(30);
	DEFINE cIndice			VARCHAR(30);
	DEFINE cFechaQry		VARCHAR(50);
	DEFINE cFolioQry		VARCHAR(50);
	DEFINE cTelefonoQry		VARCHAR(50);
	DEFINE cCompaniaQry		VARCHAR(50);	
	DEFINE cCondiciones		VARCHAR(200);
	DEFINE sRegistros		SMALLINT;
	
	---INICIALIZAR DE VARIABLES
	   
	LET cod_ret = '0000';
	LET mensaje = 'Consulta Exitosa';
	LET cod_ret2 = '0000';
	LET cOpcode = '0000';
	LET cDescr_completa_mensaje = 'Consulta Exitosa.';
	LET cNombre_proceso='sp_ws_coppel_TA';
	LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
	LET cCod_retorno  = '00000';
	LET cFecha_proceso = LPAD(MONTH(CURRENT),2,'0') || '/' || LPAD(DAY(CURRENT),2,'0') || '/' || YEAR(CURRENT);
	LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET iIsamError = 0;
	LET cCancelado = '';
	LET cFecha_Recarga = '';
	LET vRecargaSerial = '0';
	LET vNumCelular = '0';
	LET vcompania = '0';
	LET vmonto = '0';
	LET vSucursal = '0';
	LET vcobrado = '0';
	LET vEstatus = '0';
	LET vInsStmt = '';
	LET dFechaRecarga = DATE(0);
	LET cTablaBusq = '';
	LET cIndice = '';
	LET cCondiciones = '';
	
	LET cFechaQry = '';
	LET cFolioQry = '';
	LET cTelefonoQry = '';
	LET cCompaniaQry = '';
	LET sRegistros = 0;
	
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_coppel_ta.out';
	--TRACE ON;	
	   
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
		
			IF iSqlErr = '-1213' THEN
			
				LET cod_ret = '0001';
				LET cOpcode = cod_ret;
		
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cod_ret;
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, LPAD(cod_ret,5,'0'), mensaje, '', '', cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
				INTO cCod_retorno;
				
				IF cOpcode IS NULL THEN
					LET cOpcode = cod_ret;
					LET mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
				
			 ELSE

				LET cod_ret = iSqlErr;
				LET cOpcode = cod_ret;

				LET mensaje = '';
				LET cDescr_completa_mensaje = '';
				
				--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cod_ret, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
				INTO cCod_retorno;
				
		    END IF;	
			
			
			INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
			VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pDateProcess,pTimeProcess,pFechaTran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current); 
			
			RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
		
			--RETURN LPAD(cCod_retorno,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso
			
		END IF;
	END EXCEPTION;


	--------VALIDACION DE PARAMETROS-------------------------
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  NVL(pcAgent_cd,'')= '' OR NVL(pcUsuario,'')= '' OR NVL(pcAgent_trans_type_code,'')= ''
		OR NVL(pcPassword,'')= ''	OR NVL(pDateProcess,'')= '' OR NVL(pTimeProcess,'')= '' 
		OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')='' 
		OR (NVL(pFechaTran,'')='' AND NVL(pFolio,'')='' AND NVL(pCompania,'')='' AND NVL(pTelefono,'')='')THEN
		
		LET cod_ret ='9996';
	ELSE
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id) 
		INTO cod_ret, mensaje;
		IF cod_ret = '0000' THEN 
			
			IF pFechaTran <> '' THEN 
				LET pFechaTran = LPAD(pFechaTran,10,'0');
				LET pFechaTran = substr(pFechaTran,4,2)||"/"||substr(pFechaTran,0,2)||"/"||substr(pFechaTran,7,4);
			END IF;
			
			DROP TABLE IF EXISTS tmp_movtos_ws_ta;
			
			IF pFechaTran = cFecha_proceso Or pFechaTran = '' THEN
				LET cTablaBusq = 'sac_movimientos';
				LET cIndice	= 'idx_sac_movimientos7';
				
				LET cFechaQry = " AND mov.fecha_pago = TODAY";
			ELSE
				LET cTablaBusq = 'sac_movimientoshistorial';
				LET cIndice	= 'idxsac_movhisfe';
				LET cFechaQry = " AND mov.fecha_pago = '"||pFechaTran||"'";
			END IF;	
			
			LET cFecha_proceso = LPAD(DAY(CURRENT),2,'0') || '/' || LPAD(MONTH(CURRENT),2,'0') || '/' || YEAR(CURRENT);

			IF pFolio <> '' THEN LET cFolioQry = " AND mov.folio_suc = '"||pFolio||"'";	END IF;
			IF pTelefono <> '' THEN LET cTelefonoQry = " AND mov.referencia1 = '"||pTelefono||"'"; END IF;
			IF pCompania <> '' THEN	LET cCompaniaQry = " AND mov.referencia2 = '"||pCompania||"'"; END IF;
			LET cCondiciones = cFechaQry||cFolioQry||cTelefonoQry||cCompaniaQry;
				
			LET vInsStmt = "SELECT {+INDEX("||cTablaBusq||","||cIndice||")+INDEX(sac_pagostae, idx01_folio_suc} FIRST 5 mov.folio_suc as folio_suc,mov.referencia1 as referencia1,mov.referencia2 as referencia2,mov.importe_pago as importe_pago,mov.fecha_insert as fecha_insert,mov.id_sucursal as id_sucursal, pag.conceptorespuesta as conceptorespuesta, mov.status_cancelado "||
			"FROM "||cTablaBusq||" AS mov INNER JOIN sac_pagostae AS pag ON mov.folio_suc = pag.folio_suc "||
			"WHERE mov.numcategoria = '03' "|| 
			"AND mov.numconvenio = '001' "||
			cCondiciones||
			" INTO TEMP tmp_movtos_ws_ta WITH NO LOG";
			
			EXECUTE IMMEDIATE vInsStmt;
			
			FOREACH WITH HOLD
				SELECT folio_suc,referencia1,referencia2,importe_pago,fecha_insert,id_sucursal, conceptorespuesta, status_cancelado
				INTO vRecargaSerial, vNumCelular,vcompania,vmonto,dFechaRecarga,vSucursal,vEstatus,cCancelado
				FROM tmp_movtos_ws_ta
				
				LET sRegistros = sRegistros+1;
				
				IF dFechaRecarga IS NOT NULL AND dFechaRecarga <> '' THEN 
					LET dFechaRecarga = trim(YEAR(dFechaRecarga) || LPAD(MONTH(dFechaRecarga),2,'0') || LPAD(DAY(dFechaRecarga),2,'0'));
				END IF;
				
				IF NVL(cCancelado,'') = 'N' THEN
					LET vcobrado= '1'; 
				END IF;	
			
				LET cFecha_Recarga =  LPAD(DAY(dFechaRecarga),2,'0')||"/"|| LPAD(MONTH(dFechaRecarga),2,'0') ||"/"||YEAR(dFechaRecarga);
				IF NVL(cCancelado,'') = 'N' THEN LET vcobrado= '1'; END IF;
				
				

				
				RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0') WITH RESUME;
			
			END FOREACH; 
			
			IF sRegistros < 1 THEN
				LET vRecargaSerial='0';
				LET vNumCelular='0';
			END IF;
		END IF;				
	END IF;

	IF cod_ret <> '0000' OR sRegistros < 1 THEN			
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cod_ret;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cod_ret;
			LET mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;

		IF NVL(vRecargaSerial,'0') = '0' and NVL(vNumCelular,'0') = '0'  then
			LET cOpcode = '7777';
			LET mensaje = 'Folio no encontrado con los parametros proporcionados.';
			LET	cDescr_completa_mensaje = 'Folio no encontrado con los parametros proporcionados.';
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cod_ret, mensaje, '', '', cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
		INTO cCod_retorno;

		INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pDateProcess,pTimeProcess,pFechaTran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current);

		RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
	
	END IF;		
END
END PROCEDURE;