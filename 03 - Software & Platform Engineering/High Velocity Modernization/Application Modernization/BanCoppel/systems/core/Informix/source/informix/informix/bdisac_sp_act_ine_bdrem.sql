CREATE PROCEDURE "informix".sp_act_ine_bdrem()

RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (100) AS cr_Message; --1.2
		  
--Declaracion de variables 
		DEFINE cCodRet 		    		CHAR(5);
		DEFINE iSqlErr					INTEGER;
		DEFINE imenscode				INTEGER;
		DEFINE cr_Message				VARCHAR (100);
		DEFINE cr_Message_Detail		VARCHAR (100);
		DEFINE cAnoVencimiento      	CHAR (4);
		DEFINE cAnoVencimiento_2      	CHAR (4);
		DEFINE cFechaVencimiento 		CHAR (10);
		DEFINE cFechaVencimiento_ine	CHAR (10);
		DEFINE cFechaVencimiento_ine2	CHAR (10);
		DEFINE cTipoIdentificacion 		CHAR (2); 
		DEFINE dFechaSistema 			DATE;
		DEFINE Cadena  					LVARCHAR;
		DEFINE Palabra_aBuscar 			CHAR(10);
        DEFINE Longitud_Palabra     	INTEGER;
		DEFINE Longitud_Palabra_2   	INTEGER;
		DEFINE cNumCte              	CHAR(10);
		DEFINE cNoCteValido         	CHAR(10);
		DEFINE iContador_movim      	INTEGER;
		DEFINE cSinFechaVencimiento 	INTEGER;
		DEFINE cFlag 					CHAR (1);
		DEFINE dFechaValidacion			DATETIME YEAR to FRACTION(3);
		
		--SET DEBUG FILE TO '/informix/EPG/sp_act_ine_bdrem.out';
		--TRACE ON;
 
		LET cCodRet 			 	= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				 	= 0;
		LET imenscode			 	= 0;
        LET cr_Message			 	= 'Proceso Exitoso';
		LET cAnoVencimiento 	 	= '';
		LET cAnoVencimiento_2 	 	= '';
		LET cTipoIdentificacion  	= '';
		LET cFechaVencimiento 	 	= '';
		LET cFechaVencimiento_ine 	= '';
		LET cFechaVencimiento_ine2 	= '';
		LET dFechaSistema 		 	= '01-01-1900';
		LET Cadena               	= '';
		LET Palabra_aBuscar      	= '# EXPIRY: ';
		LET Longitud_Palabra     	= 4;
		LET Longitud_Palabra_2   	= 2;
		LET cNumCte              	= '';
		LET cNoCteValido         	= '';
		LET iContador_movim      	= 0;
		LET cSinFechaVencimiento 	= 0;
		LET cFlag 				 	= '';
		LET dFechaValidacion	 	= CURRENT;
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cr_Message = 'Fallo preoceso de actualizaciÃÂ³n';
			RETURN cCodRet, cr_Message;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-1204)
		IF cFlag = '1' THEN
			LET cFechaVencimiento_ine = MDY(12,31,2021);
		END IF;	
		IF cFlag = '2' THEN
			LET cFechaVencimiento_ine2 = MDY(12,31,2021);
		END IF;
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	SELECT fecha_hoy INTO dFechaSistema FROM bdisac:"informix".sac_fechas;	
	
	BEGIN WORK;	
	FOREACH WITH HOLD
		
		--Seleccionamos los clientes remesas que tengan vencida su INE o este null
		SELECT numcte, fecha_vencimiento INTO cNumCte, cFechaVencimiento 
		  FROM "informix".sac_cte_remesas WHERE fecha_vencimiento < MDY(01,01,YEAR(dFechaSistema)) OR fecha_vencimiento IS NULL
		
		--Seleccionamos con que tipo de identifacion se dio de alta
		SELECT limit 1 codidentifi INTO cTipoIdentificacion FROM bdinteg:si_ctepf WHERE numcte = cNumCte;
		
        IF (cFechaVencimiento = '' OR cFechaVencimiento IS NULL OR cFechaVencimiento < dFechaSistema) AND cTipoIdentificacion = 'A' THEN 

			--Ultima fecha de validacion si el cliente fue a dar mantenimiento a sus datos		
			SELECT MAX(FECHA) INTO dFechaValidacion
			  FROM bdinteg:"informix".si_bitacora_ife 
			 WHERE --fecha >=  EXTEND(MDY(01,01,YEAR(dFechaSistema)), YEAR to SECOND) AND 
			 numcte = cNumCte 
			   AND cod_resp_ife = '91' 
			   AND resultado = 'Verdadero'
			   AND resp_ife = 'La transaccion fue atendida con exito.';
	
			--Validacion si el cliente fue a dar mantenimiento a sus datos			
			SELECT FIRST 1 numcte, cadena_anverso INTO cNoCteValido, Cadena
			  FROM bdinteg:"informix".si_bitacora_ife 
			 WHERE fecha  = dFechaValidacion
			   AND numcte = cNumCte
			   AND cod_resp_ife = '91' 
			   AND resultado = 'Verdadero'
			   AND resp_ife = 'La transaccion fue atendida con exito.';

			IF DBINFO("sqlca.sqlerrd2") > 0 THEN 
				LET iContador_movim = iContador_movim + 1;
				LET cSinFechaVencimiento = CHARINDEX(Palabra_aBuscar,Cadena);
				IF cSinFechaVencimiento = 0 THEN
					UPDATE "informix".sac_cte_remesas SET fecha_vencimiento = MDY(12,31,YEAR(dFechaSistema)), fecha_actualizacion = current WHERE numcte = cNoCteValido;
					IF 	iContador_movim = 1000 THEN
						COMMIT WORK;
						LET iContador_movim = 0;
						BEGIN WORK;
					END IF;					
				ELSE 
					LET cFlag = '1';
					LET cAnoVencimiento = REPLACE(SUBSTRING(Cadena FROM CHARINDEX(Palabra_aBuscar,Cadena) + 10 FOR Longitud_Palabra),'-','');
					LET cAnoVencimiento = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
											   (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
											   (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cAnoVencimiento, 
											   'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),
											   'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'R',''),'S',''),'T',''),
											   'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'#',''),' ',''));
					IF  LEN (cAnoVencimiento) = 4 THEN
						LET cFechaVencimiento_ine = MDY(12,31,cAnoVencimiento);
						UPDATE "informix".sac_cte_remesas SET fecha_vencimiento = cFechaVencimiento_ine, fecha_actualizacion = current WHERE numcte = cNoCteValido;
						IF 	iContador_movim = 1000 THEN
							COMMIT WORK;
							LET iContador_movim = 0;
							BEGIN WORK;
						END IF;
						CONTINUE FOREACH;
					ELSE
						LET cFlag = '2';
						LET cAnoVencimiento_2 = 20||SUBSTRING(Cadena FROM CHARINDEX(Palabra_aBuscar,Cadena) + 16 FOR Longitud_Palabra);
						LET cAnoVencimiento_2 = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
						   (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
						   (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cAnoVencimiento_2, 
						   'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),
						   'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'R',''),'S',''),'T',''),
						   'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'#',''),' ',''));
						IF  LEN (cAnoVencimiento_2) = 4 THEN	
							LET cFechaVencimiento_ine2 = MDY(12,31,cAnoVencimiento_2); 
							UPDATE "informix".sac_cte_remesas SET fecha_vencimiento = cFechaVencimiento_ine2, fecha_actualizacion = current WHERE numcte = cNoCteValido;
							IF 	iContador_movim = 1000 THEN
								COMMIT WORK;
								LET iContador_movim = 0;
								BEGIN WORK;
							END IF;
						ELSE
							UPDATE "informix".sac_cte_remesas SET fecha_vencimiento = MDY(12,31,YEAR(TODAY)), fecha_actualizacion = current WHERE numcte = cNoCteValido;
							IF 	iContador_movim = 1000 THEN
								COMMIT WORK;
								LET iContador_movim = 0;
								BEGIN WORK;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END FOREACH;
	COMMIT;
	
	RETURN cCodRet, cr_Message;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95736042 - Eduardo Pineda Guzman',
'DESCRIPCION: Actualizacion de fecha de vencimiento Clientes Remesa',
'FECHA : 29/04/2021',
'BD: bdisac',
'-------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultacteremesa_identificacion(pIdentificacion CHAR(30))

	--DATOS DE SALIDA
	RETURNING   CHAR(5)   AS CodigoRetorno,
				CHAR(1)	  AS TipoBusqueda,
				CHAR(40)  AS Nombre1,
				CHAR(40)  AS Nombre2,
				CHAR(40)  AS ApellPat,
				CHAR(40)  AS ApelliMat,
				DATE  	  AS FechaNac,
				CHAR(5)   AS CodIdentificacion,
				CHAR(20)  AS NumIdentificacion,
				CHAR(45)  AS PaisEmision,
				DATE  	  AS FechaVencimiento,
				CHAR(50)  AS Nacionalidad,
				CHAR(30)  AS PaisNac,
				CHAR(30)  AS EdoNac,
				CHAR(30)  AS LugarNac,
				CHAR(5)   AS Sexo,
				CHAR(50)  AS Estado,
				CHAR(50)  AS Ciudad,
				CHAR(50)  AS Municipio,
				CHAR(80)  AS Colonia,
				CHAR(80)  AS Calle,
				CHAR(10)   AS NroExterior,
				CHAR(10)   AS NroInterior,
				CHAR(5)	  AS CodPostal,
				CHAR(15)  AS TelCasa,
				CHAR(15)  AS TelCelular,
				CHAR(20)  AS Numcte;
	--DECLARACION DE VARIABLES
	DEFINE iSqlErr        		INTEGER;
	DEFINE iIsamErr         	INTEGER;
	DEFINE cCodRet        		CHAR(5);
	DEFINE cTipoBusqueda		CHAR(1);
	DEFINE cNombre1				CHAR(40);
	DEFINE cNombre2				CHAR(40);
	DEFINE cApellPat			CHAR(40);
	DEFINE cApellMat			CHAR(40);
	DEFINE dFechaNac			DATE;
	DEFINE cCodIdentificacion	CHAR(5);
	DEFINE cNumIdentificacion 	CHAR(20);
	DEFINE cPais_emision    	CHAR(45);
	DEFINE dFecha_vencimiento   DATE;
	DEFINE cNacionalidad		CHAR(50);
	DEFINE cPaisNac				CHAR(30);
	DEFINE cEdoNac				CHAR(30);
	DEFINE cLugarNac			CHAR(30);
	DEFINE cSexo				CHAR(5);
	DEFINE cEdo					CHAR(50);
	DEFINE cCiudad				CHAR(50);
	DEFINE cMunicipio			CHAR(50);
	DEFINE cNroColonia			CHAR(80);
	DEFINE cNroCalle			CHAR(80);
	DEFINE cNroExt				CHAR(10);
	DEFINE cNroInt				CHAR(10);
	DEFINE cCodPostal			CHAR(5);
	DEFINE cTelCasa				CHAR(15);
	DEFINE cTelCelular			CHAR(15);
	DEFINE cNumCte				CHAR(20);
	DEFINE iContAPP	         	INTEGER;	
	DEFINE iContBTS	         	INTEGER;	
	DEFINE iContWU	         	INTEGER;	
	DEFINE c_dateofbirth        CHAR(8);
	DEFINE c_expirationdate		CHAR(8);
	
	--INICIALIZACION DE VARIABLES
	LET iSqlErr       	   = 0;
	LET iIsamErr           = 0;
	LET cCodRet	           = "00000";
	LET cTipoBusqueda	   = "";
	LET cNombre1		   = "";
	LET cNombre2		   = "";
	LET cApellPat		   = "";
	LET cApellMat		   = "";
	LET dFechaNac		   = "";
	LET cCodIdentificacion = "";
	LET cNumIdentificacion = "";
	LET cPais_emision      = "";
	LET dFecha_vencimiento = "";
	LET cNacionalidad	   = "";
	LET cPaisNac		   = "";
	LET cEdoNac			   = "";
	LET cLugarNac		   = "";
	LET cSexo			   = "";
	LET cEdo			   = "";
	LET cCiudad			   = "";
	LET cMunicipio		   = "";
	LET cNroColonia		   = "";
	LET cNroCalle		   = "";
	LET cNroExt			   = "";
	LET cNroInt			   = "";
	LET cCodPostal		   = "";
	LET cTelCasa		   = "";
	LET cTelCelular		   = "";
	LET cNumCte			   = "";
	LET iContAPP           = 0;
	LET iContBTS           = 0;
	LET iContWU            = 0;
	LET c_dateofbirth	   = "";
	LET c_expirationdate   = "";
	
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/MarcoR/bdisac/TraceBdisac/sp_consultacteremesa_identificacion.out';
	--TRACE ON;	

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						RETURN cCodRet,cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
						cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cNumCte;
				END IF;
		END EXCEPTION;
	
		--VALIDACIÃN DEL PARAMETRO DE ENTRADA.
		IF TRIM(pIdentificacion) = "" THEN
			LET cCodRet = "00002"; --PARAMETRO VACIO
			RETURN cCodRet,cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
			cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cNumCte;
		END IF;
	

		--IF EXISTS(SELECT * FROM bdisac:"informix".SAC_APP_PAYI WHERE numberci = pIdentificacion AND fecha >= ADD_MONTHS(CURRENT,-3)) THEN
		SELECT COUNT (*) INTO iContAPP FROM bdisac:"informix".SAC_APP_PAYI WHERE numberci = pIdentificacion AND fecha >= ADD_MONTHS(CURRENT,-3);
		IF iContAPP > 0 THEN
			SELECT LIMIT 1 "1",firstname,middlename,lastname,mommaidenname,dateofbirth,
			typecodeci,numberci,issuercc, expirationdate,countrycode,countrycodeadr,
			"","","",statecode,city,city,"","","","",zipcode,homephonenum,numbercel,numcte
			INTO cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,c_dateofbirth,cCodIdentificacion,cNumIdentificacion,cpais_emision,c_expirationdate,cNacionalidad,
			cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cNumCte
			FROM bdisac:"informix".SAC_APP_PAYI
			WHERE numberci = pIdentificacion AND fecha = (SELECT MAX(fecha) FROM bdisac:"informix".SAC_APP_PAYI WHERE numberci = pIdentificacion AND fecha >= ADD_MONTHS(CURRENT,-3));
			
			LET dFechaNac = MDY(SUBSTRING(c_dateofbirth FROM 5 FOR 2), SUBSTRING(c_dateofbirth FROM 7 FOR 2), SUBSTRING(c_dateofbirth FROM 1 FOR 4));
			LET dFecha_vencimiento = MDY(SUBSTRING(c_expirationdate FROM 5 FOR 2), SUBSTRING(c_expirationdate FROM 7 FOR 2), SUBSTRING(c_expirationdate FROM 1 FOR 4));
			
		END IF;
		
		--ELIF EXISTS(SELECT * FROM bdisac:"informix".SAC_BTS_PAYI WHERE r_identif_nm = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3)) THEN
		SELECT count(*) INTO iContBTS FROM bdisac:"informix".SAC_BTS_PAYI WHERE r_identif_nm = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3);
		IF (iContBTS > 0 AND iContAPP = 0) THEN
			SELECT LIMIT 1 "2",r_first_name,r_middle_name,r_last_name,r_mother_m_name,r_fecha_nac,
			r_type_cd,r_identif_nm,"",r_expiration_dt,r_nacionalidad,r_pais_nac,"","","",
			r_estado,r_ciudad,r_mncpo_deleg,r_colonia,r_nom_calle,r_num_ext,r_num_int,r_cp,r_telefono,"",numcte 
			INTO cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,c_dateofbirth,cCodIdentificacion,cNumIdentificacion,cpais_emision,c_expirationdate,cNacionalidad,
			cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cNumCte
			FROM bdisac:"informix".SAC_BTS_PAYI 
			WHERE r_identif_nm = pIdentificacion AND fecha_insert = (SELECT MAX(fecha_insert) FROM bdisac:"informix".SAC_BTS_PAYI WHERE r_identif_nm = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3));
			
			LET dFechaNac = MDY(SUBSTRING(c_dateofbirth FROM 5 FOR 2), SUBSTRING(c_dateofbirth FROM 7 FOR 2), SUBSTRING(c_dateofbirth FROM 1 FOR 4));
			LET dFecha_vencimiento = MDY(SUBSTRING(c_expirationdate FROM 5 FOR 2), SUBSTRING(c_expirationdate FROM 7 FOR 2), SUBSTRING(c_expirationdate FROM 1 FOR 4));
			
			IF cPaisNac <> "" THEN -- obtiene el codigo del pais de nacimiento
				LET cPaisNac = TRIM(cPaisNac);
				SELECT pais INTO cPaisNac
				FROM bdinteg:"informix".si_paises WHERE nombre = cPaisNac;
			END IF;
		END IF;
		
		--ELIF EXISTS(SELECT * FROM bdisac:"informix".SAC_WU_PAY WHERE benef_id_number = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3)) THEN
		SELECT COUNT(*) INTO iContWU FROM bdisac:"informix".SAC_WU_PAY WHERE benef_id_number = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3);
		IF (iContWU > 0 AND iContBTS = 0 AND iContAPP = 0) THEN
			SELECT LIMIT 1 "3",benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_fecha_nac,
			benef_id_type,benef_id_number,benef_id_pais_expedicion,id_benef_tiene_fecha_venc,
			benef_nacionalidad,benef_pais_nac,benef_edo_nac,benef_ciudad_nac,benef_sexo,benef_edo,benef_ciudad,benef_ciudad,benef_col_del_mncpo,"","","",benef_cp,benef_tel_particular,benef_tel_celular,numcte
			INTO cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,c_dateofbirth,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
			cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cNumCte
			FROM bdisac:"informix".SAC_WU_PAY
			WHERE benef_id_number = pIdentificacion AND fecha_insert = (SELECT MAX(fecha_insert) FROM bdisac:"informix".SAC_WU_PAY WHERE benef_id_number = pIdentificacion AND fecha_insert >= ADD_MONTHS(CURRENT,-3));
			
			LET dFechaNac = MDY(SUBSTRING(c_dateofbirth FROM 3 FOR 2), SUBSTRING(c_dateofbirth FROM 1 FOR 2), SUBSTRING(c_dateofbirth FROM 5 FOR 4));
			IF dFecha_vencimiento = 'N' THEN
				LET dFecha_vencimiento = '01/01/1900';
			ELSE
				LET dFecha_vencimiento = substrB(dFecha_vencimiento,3,2) || "/" || LEFT(dFecha_vencimiento,2) || "/" || RIGHT(dFecha_vencimiento,4);
			END IF;
		   
		ELSE
			LET cCodRet = "00001"; -- No se encontro cliente
		END IF;
		
	RETURN cCodRet,cTipoBusqueda,cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
	cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,NVL(cNumCte,'');
	
END;
END PROCEDURE
DOCUMENT
'FOLIO: 496',
'DESCRIPCION: SE CREA SP PARA LA BUSQUEDA DE CLIENTE POR NUMERO DE IDENTIFICACION EN LAS DIFERENTES TABLAS DE PAGO.',
'AUTOR: MARCO RIVERA',
'SUSTENTO: Homologacion del proyecto RQM 10 784-2 - Base de datos para el alta de usuarios de remesas / Nueva estructura INE',
'FECHA DE CREACION: 15/10/2018',
'SOLICITA: LEORNARDO HERNANDEZ',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_insertaerrorws(iTipo INTEGER, pProceso CHAR(30), pCodRet CHAR(5), pDescError CHAR(50), 
                                              pSqlErr CHAR(6),   pIsamErr CHAR(6), pCadena_ent CHAR (100),
											  pUsuario CHAR (8),  pFechaPeticion CHAR (8), pHoraPeticion CHAR (6) )
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		   INTEGER;
DEFINE cCodRet 		   CHAR(5);
DEFINE cHoraInsert	   CHAR(6);
DEFINE cFechaInsert    CHAR(8);
--DEFINE dFechaInsert    DATE;
DEFINE iIsamErr        INTEGER;

--Set debug file to '/respaldosbd/jasmin/sp_insertaerrorws.out';
--TRACE ON; 


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cHoraInsert     = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
--LET dFechaInsert    = CURRENT::DATE;
LET cFechaInsert    = pFechaPeticion;
LET iIsamErr        = 0;



BEGIN
	ON EXCEPTION
		SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;		
			INSERT INTO bdisac:"informix".sac_ws_errores (proceso,  cod_ret, desc_error, sql_err, isam_err, cadena_ent, user_insert, fecha_insert, hora_insert)
									VALUES (pProceso, pCodRet, '', iSqlErr, iIsamErr, pCadena_ent, pUsuario, CURRENT, cHoraInsert );
		
			UPDATE  bdisac:"informix".sac_ws_procesos
			SET cod_ret = pCodRet
			WHERE proceso = pProceso
			AND fecha_proceso = pFechaPeticion
			AND hora_proceso = pHoraPeticion
			AND user_insert = pUsuario
			AND estatus = 0;
		
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF iTipo = 1 THEN
		INSERT INTO bdisac:"informix".sac_ws_errores (proceso,  cod_ret, desc_error, sql_err, isam_err, cadena_ent, user_insert, fecha_insert, hora_insert)
									VALUES (pProceso, pCodRet, pDescError, pSqlErr, pIsamErr, pCadena_ent, pUsuario, CURRENT, cHoraInsert );
		
		UPDATE  bdisac:"informix".sac_ws_procesos
		SET cod_ret = pCodRet, estatus = 2 -- ERROR
		WHERE proceso = pProceso
		AND fecha_proceso = cFechaInsert
		AND hora_proceso = pHoraPeticion
		AND user_insert = pUsuario
		AND estatus = 0;
	ELSE
	    UPDATE  bdisac:"informix".sac_ws_procesos
		SET cod_ret = pCodRet, estatus = 1
		WHERE proceso = pProceso
		AND fecha_proceso = cFechaInsert
		AND hora_proceso = pHoraPeticion
		AND user_insert = pUsuario
		AND estatus = 0;
    END IF;	
	
	RETURN cCodRet;

END;

END PROCEDURE

DOCUMENT
'DESCRIPCION: procedimiento para insertar los errores ocasionados en el proceso de abono a cuenta automatico de BTS',
'AUTOR : Jasmin Soto',
'FECHA : 01/11/2012',
'VERSION: 1.0',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_valida_session(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd 				CHAR(6),
											  pcUsuario 				CHAR(8),
											  pcPassword 				CHAR(8),
											  pcIp_origen 			CHAR(15),
											  pcSession_id 			CHAR(30))
											
        RETURNING
		CHAR (4) AS cRetCode,
		CHAR (256) AS cErDescription;		


--DECLARACION DE VARIABLES
DEFINE iSqlErr  		 INTEGER;
DEFINE cPCodRet 		 CHAR(5);
DEFINE cReturnCode 		 CHAR (4);
DEFINE cErrorDescription CHAR (100);
DEFINE cCodRet 			 CHAR(4);
	
DEFINE dtFecha_dia		DATE;
DEFINE vcEmpresa        CHAR(3);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE cOpcode			CHAR(5);
DEFINE dFechaNueva 	 	CHAR(10);
DEFINE cDia         	CHAR(2);
DEFINE cMes         	CHAR(2);
DEFINE cAnio        	CHAR(4);

--INICIALIZACION DE VARIABLES
LET dtFecha_dia   = CURRENT::DATE;		
LET cAgent_cd ='';
LET cUsuario ='';
LET cPassword ='';
LET cIp_origeN ='';
LET cId_sesion_act ='';	
LET dFechaNueva   = DATE(1);

LET iSqlErr = 0;
LET cReturnCode = '0000';
LET cCodRet = '0000';
LET cOpcode = '0000';
LET cErrorDescription = 'Consulta exitosa';

--SET DEBUG FILE TO '/informix/manuel/sp_valida_session.out';
--TRACE ON;	

	BEGIN
   
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';

		RETURN trim(cOpcode), trim(cErrorDescription);
		
        END IF;
    END EXCEPTION;
	
	
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
	
    LET pcusuario=trim(pcusuario); 
	IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = pcusuario AND activa = 'S' ) THEN
	
		SELECT agent_cd,usuario,password,ip_origen,id_sesion_act::CHAR(30)
		INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
		FROM bdisac:"informix".sac_ws_clientes 
		WHERE agent_cd = pcAgent_cd AND usuario = pcusuario and  fecha_insert = dtFecha_dia;
		
		IF cAgent_cd = pcAgent_cd THEN
			IF cUsuario = pcUsuario   THEN
				IF cPassword = pcPassword THEN
					IF cIp_origen = pcIp_origen THEN
						IF cId_sesion_act = pcSession_id THEN
						--	IF length(pcSystemDate)>1 THEN
						--		LET cDia=SUBSTR(pcSystemDate,1,2);
						--		LET cMes=SUBSTR(pcSystemDate,3,2);
						--		LET cAnio=SUBSTR(pcSystemDate,5,4);
						--		LET dFechaNueva = mdy(cMes,cDia,cAnio);
					--		ELSE
						--		LET cReturnCode = '9996';
						--		LET cErrorDescription = "Consulta no exitosa. Fecha inválida. pcSystemDate>1";
					--		END IF;
						ELSE
							LET cReturnCode = '9975';
							LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
						END IF;
					ELSE
						LET cReturnCode = '9976';
						LET cErrorDescription = "Error autenticación. IP origen inválida ";
					END IF;
				ELSE
					LET cReturnCode = '9979';
					LET cErrorDescription = " Error autenticación. Password no existe.";
				END IF;
			ELSE
			    LET cReturnCode = '9980';
				LET cErrorDescription = 'Error autenticación. Usuario no existe';
			END IF;
		ELSE
			LET cReturnCode = '9998';
			LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
		END IF;
    ELSE
		LET cReturnCode ='9982';
		LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
	END IF;
	
	RETURN trim(cReturnCode), trim(cErrorDescription);
	
	END;
END PROCEDURE;