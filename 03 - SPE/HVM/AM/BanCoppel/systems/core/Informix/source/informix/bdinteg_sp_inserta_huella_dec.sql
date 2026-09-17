CREATE PROCEDURE "informix".sp_inserta_huella_dec(pEmpresa CHAR(3), pNumcte CHAR(20),pSucursal CHAR(5),pUser_insert CHAR(8),pFecha DATE,cDH1 CHAR(955),cDH2 CHAR(955),cDH3 CHAR(955),cDH4 CHAR(955),cDH5 CHAR(955),cDH6 CHAR(955),cDH7 CHAR(955),cDH8 CHAR(955),cDH9 CHAR(955),cDH10 CHAR(955), cTipo CHAR(2))
--Retorno
RETURNING CHAR(5) AS cCodigoRet;

--Declaracion de variables
DEFINE sSecuencia   SMALLINT;
DEFINE sId_template SMALLINT;
DEFINE cTemplate    CHAR(942);
DEFINE sNfiq        SMALLINT;
DEFINE sMinucias SMALLINT;
DEFINE sId_Excepcion SMALLINT;
DEFINE dFecha   date;
DEFINE dFecha_insert DATETIME YEAR TO FRACTION;
DEFINE iSqlErr   INTEGER;
DEFINE cCodigoRet  char(5);
DEFINE iCont    SMALLINT ;
DEFINE iSiguienteSecuencia SMALLINT;

DEFINE cTp_persona CHAR(2);
DEFINE cEsfisica  CHAR(1);
DEFINE cExiste  CHAR(1);
DEFINE cTemplateD CHAR(942);
DEFINE cTemplateI CHAR(942);

DEFINE cTemplate1 CHAR(942);
DEFINE cTemplate2 CHAR(942);
DEFINE cTemplate3 CHAR(942);
DEFINE cTemplate4 CHAR(942);
DEFINE cTemplate5 CHAR(942);
DEFINE cTemplate6 CHAR(942);
DEFINE cTemplate7 CHAR(942);
DEFINE cTemplate8 CHAR(942);
DEFINE cTemplate9 CHAR(942);
DEFINE cTemplate10 CHAR(942);
DEFINE cTipoP 	   CHAR(1);

--inicializacion de variables
LET iSqlErr=0;
LET cCodigoRet = '00000';
LET sSecuencia = 0;
LET sId_template = 0;
LET cTemplate = '';
LET sNfiq = 0;
LET sMinucias = 0;
LET sId_Excepcion = 0;
LET dFecha = pFecha;
LET iCont = 1;
LET iSiguienteSecuencia = 0;

LET cTemplate1 = '';
LET cTemplate2 = '';
LET cTemplate3 = '';
LET cTemplate4 = '';
LET cTemplate5 = '';
LET cTemplate6 = '';
LET cTemplate7 = '';
LET cTemplate8 = '';
LET cTemplate9 = '';
LET cTemplate10 = '';
LET cTipoP = '';

--SET DEBUG FILE TO '/home/sysifx/Selene/bdinteg/sp_inserta_huella_dec.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr !=0 THEN
			RETURN (isqlerr);  
		END IF
	END EXCEPTION

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' OR NVL(pSucursal, '') = '' OR NVL(pUser_insert, '') = '' OR NVL(dFecha, '') = '' OR NVL(cDH1,'') = '' OR NVL(cDH2,'') = '' OR NVL(cDH3,'') = '' OR NVL(cDH4,'') = '' OR NVL(cDH5,'') = '' OR NVL(cDH6,'') = '' OR NVL(cDH7,'') = '' OR NVL(cDH8,'') = '' OR NVL(cDH9,'') = '' OR NVL(cDH10,'') = '' THEN
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet;
	ELSE 
		SELECT tpo_persona INTO cTp_persona
		FROM   bdinteg:"informix".si_cliente
		WHERE  numcte = pNumcte;

		SELECT es_fisica INTO cEsfisica
		FROM bdinteg:"informix".si_tipper
		WHERE tpo_persona = cTp_persona;

		IF UPPER(cEsfisica) != "S" THEN
			LET cCodigoRet = '00120';
			RETURN cCodigoRet;
		END IF;

		--3 Validar que exista la sucursal en el sistema, en caso de no existir retornar cCodigoRet = '00111';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;

		IF cExiste IS NULL THEN
			LET cCodigoRet = '00111';
			RETURN cCodigoRet;
		END IF;

		--4.- Validar que exista el ejecutivo en el sistema, en caso de no existir retornar cCodigoRet = '00112';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pUser_insert;

		IF cExiste IS NULL THEN
			LET cCodigoRet='00112';
			RETURN cCodigoRet;
		END IF;
		
		WHILE (iCont <=10)
			LET cTemplate = '';
			
			--1 
			IF (iCont=1) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH1) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate1;
				LET cTemplate = cTemplate1; 
			END IF;    
			--2   
			IF (iCont=2) THEN      
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH2) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate2;
				LET cTemplate = cTemplate2; 				
			END IF;    
			--3    
			IF (iCont=3) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH3) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate3;
				LET cTemplate = cTemplate3; 
			END IF;
			--4
			IF (iCont=4) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH4) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate4;
				LET cTemplate = cTemplate4; 
			END IF;
			--5
			IF (iCont=5) THEN     
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH5) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate5;
				LET cTemplate = cTemplate5; 
			END IF;
			--6
			IF (iCont=6) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH6) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate6;
				LET cTemplate = cTemplate6; 
			END IF;
			--7
			IF (iCont=7) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH7) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate7; 
				LET cTemplate = cTemplate7;    
			END IF;
			--8
			IF (iCont=8) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH8) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate8;
				LET cTemplate = cTemplate8; 
			END IF;
			--9
			IF (iCont=9) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH9) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate9;
				LET cTemplate = cTemplate9; 
			END IF;    
			--10
			IF (iCont=10) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH10) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate10;
				LET cTemplate = cTemplate10; 
			END IF;

			--CONSULTAR ULTIMA SECUENCIA CON ESTATUS A DE ID_TEMPLATE 
			LET sSecuencia = (SELECT secuencia FROM "informix".si_cte_huella_dec WHERE numcte =  pNumcte AND estatus = 'A' AND id_template = sId_template);

			IF NVL(sSecuencia, '') = ''  THEN
				LET sSecuencia = 1; 
			ELSE 
				LET sSecuencia = sSecuencia + 1;
			END IF;
			
			--ELIMINAR REGISTROS DE TEMPLATES DEL CLIENTE
			DELETE FROM "informix".si_cte_huella_dec_actual WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES
			INSERT INTO "informix".si_cte_huella_dec_actual(numcte,secuencia,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			--ACTUALIZAR EL ESTATUS DE LOS TEMPLATES ANTERIORES CON ESTATUS I= INACTIVO
			UPDATE "informix".si_cte_huella_dec SET estatus = 'I' WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES CON ESTATUS A= ACTIVO
			INSERT INTO "informix".si_cte_huella_dec(numcte,secuencia,estatus,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,'A',sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			LET iCont = iCont + 1;
		END WHILE;

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		END IF;		
	 
		IF (NVL(cTemplate2, '') = '') THEN
			IF (NVL(cTemplate1, '') = '') THEN
				IF (NVL(cTemplate3, '') = '') THEN
					IF (NVL(cTemplate4, '') = '') THEN
						IF (NVL(cTemplate5, '') = '') THEN
							LET cTemplateD = '';
						ELSE
							LET cTemplateD = cTemplate5;
						END IF;
					ELSE
						LET cTemplateD = cTemplate4;
					END IF;
				ELSE
					LET cTemplateD = cTemplate3;
				END IF;
			ELSE
				LET cTemplateD = cTemplate1;
			END IF;
		ELSE
			LET cTemplateD = cTemplate2;
		END IF;
		
		IF (NVL(cTemplate7, '') = '') THEN
			IF (NVL(cTemplate6, '') = '') THEN
				IF (NVL(cTemplate8, '') = '') THEN
					IF (NVL(cTemplate9, '') = '') THEN
						IF (NVL(cTemplate10, '') = '') THEN
							LET cTemplateI = '';
						ELSE
							LET cTemplateI = cTemplate10;
						END IF;
					ELSE
						LET cTemplateI = cTemplate9;
					END IF;
				ELSE
					LET cTemplateI = cTemplate8;
				END IF;
			ELSE
				LET cTemplateI = cTemplate6;
			END IF;
		ELSE
			LET cTemplateI = cTemplate7;
		END IF;
		
		IF (NVL(cTemplateD, '') = '' OR NVL(cTemplateI, '') = '') THEN
			
			If  NVL(cTemplateD, '') = '' THEN
				
				IF (NVL(cTemplate7, '') = '') THEN					
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = '';
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate9;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate8;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9 ;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate6;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate7;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					ELSE
						LET cTemplateD = cTemplate6;
					END IF;
				END IF;
				
			ELSE			
				IF (NVL(cTemplate2, '') = '') THEN					
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = '';
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate4;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate3;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate1;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate2;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					ELSE
						LET cTemplateI = cTemplate1;
					END IF;
				END IF;
				
			END IF
		END IF;
		
		IF TRIM(cTipo) = 'M' THEN
			LET cTipoP='C';
			
		ELSE
		
			LET cTipoP='A';
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_ctehuella(pEmpresa, pSucursal, pUser_insert, pUser_insert, pFecha, cTipoP, pNumcte, cTemplateD, cTemplateI)
		INTO cCodigoRet,iSiguienteSecuencia;

	END IF;
	
	RETURN cCodigoRet;	
	
END;
END PROCEDURE

DOCUMENT
'Peticion: 420',
'AutOR : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 31/08/2018',
'Descripcion: Store Procedure Insertar los datos de las huellas en la tabla si_cte_huella_dec',
'BD : bdinteg';

CREATE PROCEDURE "informix".sp_generatramaservicio(cEmpresa CHAR(3), cNumCte CHAR(20), cEmpleado CHAR(8), cUsuario3 CHAR(8), cSucursal CHAR(4), cTipo CHAR(1), pcIP CHAR(15), pcVerificacion CHAR(2), pcSensor CHAR(2), pcComponente CHAR(16))		


	RETURNING CHAR(6),  CHAR(2000);


	DEFINE cCodRet			CHAR(6);
    DEFINE cCodRet2			CHAR(6);	
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
	DEFINE bTransacInterAct	BOOLEAN;	
	DEFINE bEnTransac		BOOLEAN;
	DEFINE cNomSP			CHAR(50);
	DEFINE cTrama			CHAR(2000); 


	LET cCodRet = '000000';				
    LET cCodRet2 = "";
	LET bTransacInterAct = 'F';			
	LET bEnTransac = 'F';
	LET cNomSP = '';						

--set debug file to "/tmp/sp_generatramaservicio.out";
--trace on;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr !=0 THEN
			RETURN isqlerr, cTrama;  
		END IF
	END EXCEPTION

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;	

	
	IF EXISTS (SELECT valor FROM "informix".si_param WHERE cod_param = '135' AND valor = '1') THEN
		
		EXECUTE PROCEDURE "informix".sp_generahuellalinea_chl(cNumCte, pcIP, cTipo, cEmpleado, pcVerificacion, pcSensor) 
		INTO cCodRet2, cTrama;

		IF CAST(cCodRet2 AS INTEGER) = 0 THEN
			
			EXECUTE PROCEDURE bdisitesp:"informix".sp_mttositespalterna(cEmpresa, cNumCte, cSucursal, cUsuario3) 
			INTO cCodRet2;
			
			IF CAST(cCodRet2 AS INTEGER) = 0 THEN
				LET bEnTransac = 'F';
			ELSE
				LET cNomSP = 'sp_mttositespalterna';
			END IF;
		ELSE
			LET cNomSP = 'sp_generahuellalinea_chl';
		END IF;
	END IF;										
	
  IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		LET cCodRet = cCodRet2;
		
		EXECUTE PROCEDURE "informix".sp_graba_bitacora_registro_huellas(cTipo, cNumCte, cSucursal, cUsuario3, pcIP, pcComponente, cCodRet, cNomSP) 
		INTO cCodRet2;
		
  END IF;		
	

RETURN cCodRet, cTrama;	
END;
END PROCEDURE
DOCUMENT
"AutOR : Selene Campos.",
"FECHA : 2019-05-28",
"BD    : bdinteg",
"VER   : 1.1",
"FOLIO :  ",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_registro_ivr_bpi(pTipoProceso CHAR(3), pFechaInicial DATE, pFechaFinal DATE)

RETURNING 
		CHAR(100) AS Proceso,
		CHAR(5) AS CodRet,
		CHAR(100) AS DataError;

	 --DEFINICION DE VARIABLES--
    DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
    DEFINE cCodRet      	CHAR(5);
	DEFINE dFechaIni        DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin        DATETIME YEAR TO FRACTION(5);
	DEFINE cNumCte			CHAR(20);
	DEFINE cEstatus         CHAR(1);
	DEFINE dFechaOper		DATETIME YEAR TO FRACTION(5);
	DEFINE cProceso			CHAR(100);
	DEFINE cVarDataErr		CHAR(100);
	DEFINE iEstatus			INTEGER;
	DEFINE sCommit          SMALLINT;
	DEFINE iCont            INTEGER;
	DEFINE dFechaUltAcceso  DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaReg		DATETIME YEAR TO FRACTION(5);
	DEFINE sServicio		SMALLINT;
	DEFINE cStmt 			CHAR (500);
	DEFINE cRutaOltp	    CHAR(50);
	
	--INICIALIZACION DE VARIABLES--
    LET iSqlErr 		= 0;
    LET cCodRet 		= '00000';
	LET dFechaIni   	= '';
	LET dFechaFin	    = '';
	LET cNumCte	     	= '';
	LET cEstatus  		= '';
	LET dFechaOper     	= '';
	LET cProceso 		= 'SP_REGISTRO_IVR_BPI';
	LET cVarDataErr 	= '';
	LET iEstatus        = 1;
	LET iCont	        = 0;
	LET sCommit         = 0;
	LET dFechaUltAcceso = '';
	LET dFechaReg		= '';
	LET sServicio 		= 0; 
	LET cStmt           = '';
	LET cRutaOltp       = '/RESPALDOSNEW/depuraremesas/';

    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_registro_ivr_bpi_ljfs.out";
	--TRACE ON;

	BEGIN
		--CONTROLAMOS ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
				IF (sCommit = -1) THEN
					ROLLBACK WORK;
				END IF;
				LET cVarDataErr = 'ERROR NO CONTROLADO';
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion)
				VALUES (cProceso, dFechaIni, CURRENT, cCodRet , cVarDataErr);
					
				RETURN cProceso,cCodRet, cVarDataErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		--TRUNCATE TABLE bdinteg:"informix".tmp_unica_paso;
	
		--VALIDAR LOS PARAMETROS DE ENTRADA 
		IF NVL(pTipoProceso,'') = '' OR NVL(pFechaInicial,'')='' OR NVL(pFechaFinal,'')='' THEN
			LET cCodRet =   '00001';
			LET iEstatus=0;
			LET cVarDataErr = 'UNO O MAS PARAMETROS VACIOS';
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
				
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaFinal > CURRENT::DATE THEN
			LET cCodRet =   '00002'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA FINAL ES MAYOR A LA FECHA DE HOY";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
					
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaInicial > pFechaFinal THEN
			LET cCodRet =   '00003'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA INICIO ES MAYOR A LA FECHA FIN";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr);
			RETURN cProceso,cCodRet, cVarDataErr;
			
		END IF;  --TERMINA DE VALIDAR LOS PARAMETROS DE ENTRADA
		
	-- INICIA PROCESO IVR
		
	IF (UPPER(pTipoProceso) = 'IVR') THEN   --UNI_IVR	
								 
		--/** OBTENEMOS LOS REGISTROS DE LA FECHA DESEADA PARA IVR **/
		DROP TABLE IF EXISTS temp_ivrusuarios;
		SELECT      bitc.numcte, ivr.status_cte, MAX(bitc.fecha_oper) fecha_oper
		FROM        bdinteg:"informix".si_bitacora_ivr bitc  
		INNER JOIN  bdinteg:"informix".si_cliente_ivr ivr ON (ivr.numcte = bitc.numcte)
		WHERE       bitc.fecha_oper >  pFechaInicial
		AND         bitc.fecha_oper <= pFechaFinal 
		GROUP BY    bitc.numcte, ivr.status_cte
		INTO temp_ivrusuarios;						 
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'si_registro_ivr.unl SELECT * FROM temp_ivrusuarios;">' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdinteg ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_ivrusuarios.sql';
		SYSTEM cStmt;
		   
		DROP TABLE IF EXISTS temp_ivrusuarios;		  		

		LET cVarDataErr = 'EJECUCION EXITOSA IVR';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);
		  
	END IF; --  TERMINA PROCESO IVR

	
	-- INICIA PROCESO BPI
	IF (UPPER(pTipoProceso) = 'BPI') THEN   --UNI_BPI
	    
		--/** OBTENEMOS LOS REGISTROS DE LA FECHA DESEADA PARA BPI **/
		--INSERT    INTO bdinteg:"informix".tmp_unica_paso (numcte)
		DROP TABLE IF EXISTS temp_bpiusuarios;
		SELECT    a.numcte,  a.f_ultimo_acceso, a.f_registro, a.servicio
		FROM      TABLE(MULTISET(SELECT    bis.numcte,  bis.f_ultimo_acceso, bis.f_registro, bis.servicio 
								 FROM      bdinteg:"informix".si_bpiusuarios bis
								 WHERE     (bis.f_ultimo_acceso > pFechaInicial AND bis.f_ultimo_acceso <= pFechaFinal)
								 UNION ALL
								 SELECT    bis.numcte,  bis.f_ultimo_acceso, bis.f_registro, bis.servicio 
								 FROM      bdinteg:"informix".si_bpiusuarios bis
								 WHERE     (bis.f_registro > pFechaInicial AND bis.f_registro <= pFechaFinal)
								 AND       f_ultimo_acceso IS NULL)) a						
		INTO temp_bpiusuarios;						 
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'si_registro_bpi.unl SELECT * FROM temp_bpiusuarios;">' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdinteg ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_bpiusuarios.sql';
		SYSTEM cStmt;
		
		DROP TABLE IF EXISTS temp_bpiusuarios;

		LET cVarDataErr = 'EJECUCION EXITOSA BPI';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);		  		  
		
	END IF; --  TERMINA PROCESO BPI
	
RETURN cProceso, cCodRet, cVarDataErr;

END;
END PROCEDURE;