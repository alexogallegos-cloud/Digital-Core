CREATE PROCEDURE "informix".sp_consflag_respuesta_web(pMensaje CHAR(5),pCod_interact CHAR(5),pCod_WS CHAR(4),pCod_detail CHAR(4))
RETURNING CHAR(6) AS Cod_ret, CHAR(1) AS flag

--	DECLARA VARIABLES
DEFINE cCod_ret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cFlag CHAR(1);
DEFINE cFlagint CHAR(1);
DEFINE cFlagrev CHAR(1);
--	INICIALIZA VARIABLES
LET iSqlErr = 0;
LET cCod_ret = '00000';
LET cFlag = '0';
LET cFlagint = '0';
LET cFlagrev = '0';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consflag_respuesta.out";
--TRACE ON; 
BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		LET cCod_ret = iSqlErr;
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END EXCEPTION;

	-- VALIDACION DE PARAMETROS
	
	IF NVL(pMensaje,'') = ''THEN
			LET cCod_ret = '00001';
			LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF ( NVL(pCod_interact,'') = ''  OR pCod_interact::INT= 0) AND NVL(pCod_WS,'') = '' OR NVL(pCod_detail,'') = ''  THEN
		LET cCod_ret = '00000';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	ELIF pCod_interact::INT <> 0 then
		LET cCod_ret = '00002';
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	
	END IF
	
	LET pMensaje = UPPER(pMensaje);
	
	SELECT flag_rev,flag_intento
	INTO cFlagint,cFlagrev
	FROM bdisac:"informix".sac_app_cat_mensajesdetail
	WHERE agent_trans_type_code = TRIM(pMensaje)
	AND opcode= TRIM (pCod_WS)
	AND opcode_detail = TRIM (pCod_detail);
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCod_ret = '00003';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF cFlagint::INT = 1 or cFlagrev::INT = 1 THEN
		LET cFlag = '1';
	END IF
	
	RETURN cCod_ret,cFlag;
	
END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - MARIO OLIVO',
'FOLIO:95',
'DESCRIPCION: el SP regresa el flag ya sea para mandar a reversar o bien intentar el reverso.',
'FECHA:2016/07/26',
'SOLICITA:Leonardo Hernandez',
'RQM: Adendum',
'VERSION:20160726.1752',
'BD:bdisac';

CREATE PROCEDURE "informix".sp_reporteapp_diario(pdtPeriodo DATE)

RETURNING 
DATE AS Dia, CHAR(16) AS Num_confirmacion, MONEY AS Importe, CHAR (20) AS Forma_pago, 
CHAR (16) AS Folio_op, CHAR (5) AS Sucursal, CHAR (8) AS Cajero, CHAR (120) AS Nom_benef;

--****************************************************************************************************
-- DESCRIPCION:  GENERA REPORTE DE DIARIO APPRIZA
-- AUTOR : Noe Medina Ramirez
-- FECHA : 31/01/2019
-- BD: BDISAC
-- SISTEMA : APP SOC
--***************************************************************************************************

DEFINE vdtDia DATE;
DEFINE vsNum_confirmacion CHAR(16);

DEFINE viImporte MONEY; 
DEFINE vsForma_pago CHAR (20);
DEFINE vsFolio_op CHAR (16);
DEFINE vsSucursal CHAR (5);
DEFINE vsCajero CHAR (8);
DEFINE vsFirstname CHAR (120);
DEFINE vsMiddlename CHAR (120);
DEFINE vsLastname CHAR (120);

DEFINE visqlerr INTEGER ;




LET vdtDia = CURRENT;
LET vsNum_confirmacion = '';

LET viImporte = 0.0;
LET vsForma_pago = '';
LET vsFolio_op = '';
LET vsSucursal = '';
LET vsCajero = '';
LET vsFirstname = '';
LET vsMiddlename = '';
LET vsLastname = '';

LET visqlerr = 0 ;

BEGIN

	ON EXCEPTION SET visqlerr  

		RETURN '01/01/1900', visqlerr, '', 0.0, '', '', '', '';

	END EXCEPTION;


	IF (pdtPeriodo  IS NULL) THEN 
		RETURN '01/01/1900', '', '', 0.0, '', '', '', '';
	ELSE

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH SELECT MOV.fecha_pago, 
						APP.unirefnum, 
					 MOV.importe_pago, 
		            case when MOV.forma_pago='1' and MOV.origen ='CPL' then 'EFECTIVO-CPL' 
		                 when MOV.forma_pago='1' and MOV.origen <>'CPL' then 'EFECTIVO'
		                 when MOV.forma_pago='2' and MOV.origen <>'CPL' then 'CARGO EN CUENTA'
		                 when MOV.forma_pago='3' and MOV.origen <>'CPL' then 'MIXTO'
		                 when MOV.forma_pago='4' and MOV.origen <>'CPL' then 'ABONO CTA'
		            end forma_pago,
					 --MOV.forma_pago, 
					 MOV.folio_suc, 
					 MOV.id_sucursal, 
					 MOV.usuario, 
					 APP.r_firstname, 
					 APP.r_middlename, 
					 APP.r_lastname
			INTO vdtDia, vsNum_confirmacion, viImporte, vsForma_pago, vsFolio_op, vsSucursal, vsCajero, vsFirstname, vsMiddlename, vsLastname
			FROM bdisac:sac_movimientoshistorial AS MOV INNER JOIN bdisac:sac_app_payi AS APP
			ON MOV.fecha_pago = pdtPeriodo
			AND MOV.folio_suc = APP.refnum
			AND MOV.referencia1 = APP.unirefnum
			AND MOV.status_cancelado = 'N'

			RETURN vdtDia, vsNum_confirmacion, viImporte, vsForma_pago, vsFolio_op, vsSucursal, vsCajero, (TRIM(vsFirstname) || ' ' || TRIM(vsMiddlename) || ' ' || TRIM(vsLastname)) WITH RESUME;

		END FOREACH;

	END IF;

END

END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez',
'Proyecto: APP SOC',
'Solicito: ',
'Descripcion: GENERA REPORTE DE APP DIARIO EN EL SOC.',
'Fecha: 31/01/2019',
'Version: 20190131.1000',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_guarda_tmpresponsecardif(pFolioSuc CHAR(16),pTrama CHAR(10240))											
RETURNING
CHAR (4) AS cRetCode;		


	--DECLARACION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(4);
	DEFINE iCuanatos INTEGER;
	DEFINE iPosicion INTEGER;
	DEFINE cAux CHAR(10240);
	DEFINE cCodTrama CHAR(20);
	DEFINE cDescripcion CHAR(120);
	DEFINE cPoliza CHAR(70);
	DEFINE cEstatus CHAR(10);
	DEFINE iNumPoliza INTEGER;

	LET iSqlErr = 0;
	LET cCodRet = '0000';
	LET iCuanatos = 0;
	LET iPosicion = 0;
	LET cAux = '';
	LET cCodTrama = '';
	LET cDescripcion = '';
	LET cPoliza = '';
	LET cEstatus = '';
	LET iNumPoliza = 0;

	BEGIN
   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN trim(cCodRet);	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
		--TRACE ON;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pTrama,'') <> '' THEN
			WHILE iNumPoliza < 6
				LET iCuanatos = INSTR(pTrama,'>>');
				IF iCuanatos > 0 THEN
					
					LET cAux =  SUBSTR(pTrama,0,iCuanatos-1);		
					LET iPosicion = INSTR(pTrama,'|');		
					LET cCodTrama = SUBSTR(pTrama,0,iPosicion-1);
					
					LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
					LET iPosicion = INSTR(cAux,'|');
					LET cDescripcion =  SUBSTR(cAux, 0 ,iPosicion-1);
					
					LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
					LET iPosicion = INSTR(cAux,'|');
					LET cPoliza =  SUBSTR(cAux, 0 ,iPosicion-1);
					
					LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
					LET cEstatus =  cAux;
					
					INSERT INTO tmpResponseCardif (folio_suc,codret,descripcion,poliza,estatus) VALUES (pFolioSuc,cCodTrama,cDescripcion,cPoliza,cEstatus);
				ELSE
					IF LENGTH(pTrama)>0 THEN
						LET cAux =  pTrama;		
						LET iPosicion = INSTR(pTrama,'|');		
						LET cCodTrama = SUBSTR(pTrama,0,iPosicion-1);
						
						LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
						LET iPosicion = INSTR(cAux,'|');
						LET cDescripcion =  SUBSTR(cAux, 0 ,iPosicion-1);
						
						LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
						LET iPosicion = INSTR(cAux,'|');
						LET cPoliza =  SUBSTR(cAux, 0 ,iPosicion-1);
						
						LET cAux =  SUBSTR(cAux,iPosicion+1,LENGTH(cAux));
						LET cEstatus =  cAux;
						
						INSERT INTO tmpResponseCardif (folio_suc,codret,descripcion,poliza,estatus) VALUES (pFolioSuc,cCodTrama,cDescripcion,cPoliza,cEstatus);
						EXIT WHILE;
					ELSE
						LET cCodRet = '0001';
					END IF;
				END IF;
				LET pTrama = SUBSTR(pTrama,iCuanatos + 2,LENGTH(pTrama));
				LET iNumPoliza = iNumPoliza + 1;
			END WHILE;
		ELSE
			LET cCodRet = '0002';
		END IF;
		RETURN TRIM(cCodRet);

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para guardar el response del servicio de reverso en la tabla temporal tmpResponseCardif',
'AUTOR: Mario Gallardo',
'FECHA: 2020/04/29',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reverso_cardif(
	pEmpresa CHAR(3),
	pSucursal CHAR(4),
	pNumCte CHAR(20),
	pEjecutivo CHAR(8),
	pFoliosuc CHAR(16),
	pTipoRev CHAR(1),
	pNumCredito CHAR(20),
	pFolioPromo CHAR(16),
	pTipoEjec CHAR(1),
	pOpc1 CHAR(20),
	pOpc2 CHAR(20),
	pOpc3 CHAR(20),
	pNumerosPolizas CHAR(10240))

	RETURNING 
		CHAR(5) AS CodRet,
		CHAR(2) AS CodProceso,
		CHAR(5) AS CodRet2,
		CHAR(20) AS Ret1,
		CHAR(20) AS Ret2,
		CHAR(20) AS Ret3;

	DEFINE cCodRet 				  CHAR(5);
	DEFINE CodProceso			  CHAR(2);
	DEFINE CodRet2				  CHAR(5);
	DEFINE iSqlErr 				  INTEGER;
	DEFINE cCodRetBicheqRev       CHAR(5);
	DEFINE cCodRetBdinversRev     CHAR(5);
	DEFINE cCodRetBdicredRev      CHAR(5);
	DEFINE cCodRetBditransRev 	  CHAR(5);
	DEFINE cCodRetBdisucRev 	  CHAR(5);
	DEFINE cCodRetBdicredRevpromo CHAR(5);
	DEFINE cCodRetGuardaResponse  CHAR(5);
	DEFINE cCodResponse CHAR(10);
	DEFINE cNombre1		CHAR(26);
	DEFINE cNombre2		CHAR(26);
	DEFINE cApPat		CHAR(26);
	DEFINE cApMat		CHAR(26);
	DEFINE cFechaNac	CHAR(23);
	DEFINE cSecuencia   INT;
	DEFINE cPoliza      CHAR(50);
	DEFINE cRetBdinvers				CHAR(20);
		
	LET cCodRet					    = '00000';
	LET CodProceso					= '00';
	LET CodRet2						= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetBicheqRev 			= '';     
	LET cCodRetBdinversRev          = '';
	LET cCodRetBdicredRev           = '';
	LET cCodRetBditransRev 	        = '';
	LET cCodRetBdisucRev 	        = '';
	LET cCodRetBdicredRevpromo 		= '';
	LET cCodRetGuardaResponse 		= '';
	LET cNombre1					= '';
	LET cNombre2					= '';
	LET cApPat						= '';
	LET cApMat						= '';
	LET cFechaNac					= '';
	LET cSecuencia 	    			= 0;
	LET cPoliza                     = '';
	LET cCodResponse                = '';
	
	--SET DEBUG FILE TO '/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_reverso_cardif.out';
	--TRACE ON;
BEGIN	
		ON EXCEPTION
		SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,CodProceso,CodRet2,'','','';
			END IF;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF (SELECT COUNT(*) 
		FROM bdisac:"informix".sac_cardif_migrante 
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND numcte = pNumCte 
		AND estatus = '1' 
		AND (tipo_pago = '' OR tipo_pago is null)
		AND (folio_suc = '' OR folio_suc is null)) > 0 THEN
		  
			IF NVL(pEmpresa,'')='' OR pEmpresa IS NULL 
				OR NVL(pSucursal,'')= '' OR pSucursal IS NULL 
				OR NVL(pNumCte,'')= '' OR pNumCte IS NULL
			THEN
				LET cCodRet = '00001'; --Uno de los campos obligatorios viene vacio
				RETURN cCodRet, CodProceso, CodRet2,'','','';
			END IF;
		  
			FOREACH
				SELECT nombre1, nombre2, apell_paterno, apell_materno--, fechanac 
				INTO cNombre1, cNombre2, cApPat, cApMat--, cFechaNac
				FROM bdisac:"informix".sac_cardif_migrante 
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND numcte = pNumCte 
				AND estatus = '1' 
				AND (tipo_pago = '' OR tipo_pago is null)
				AND (folio_suc = '' OR folio_suc is null)

				UPDATE bdisac:"informix".sac_cardif_migrante 
				SET estatus = '5' 
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND numcte = pNumCte 
				AND nombre1 = cNombre1
				AND nombre2 = cNombre2
				AND apell_paterno = cApPat
				AND apell_materno = cApMat
				--AND fechanac = cFechaNac
				AND estatus = '1' 
				AND (tipo_pago = '' OR tipo_pago is null)
				AND (folio_suc = '' OR folio_suc is null);

				SELECT MAX(secuencia) 
				INTO cSecuencia
				FROM bdisac:"informix".sac_cardif_migrante 
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND numcte = pNumCte
				AND nombre1 = cNombre1
				AND nombre2 = cNombre2
				AND apell_paterno = cApPat
				AND apell_materno = cApMat
				--AND fechanac = cFechaNac
				AND estatus = '3';

				UPDATE bdisac:"informix".sac_cardif_migrante 
				SET estatus = '2' 
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND numcte = pNumCte 
				AND estatus = '3'
				AND secuencia = cSecuencia;
		END FOREACH;
			  
			  
	ELSE
		IF NVL(pEmpresa,'')='' OR pEmpresa IS NULL OR 
			NVL(pSucursal,'')= '' OR pSucursal IS NULL OR 
			NVL(pNumCte,'')= '' OR pNumCte IS NULL OR 
			NVL(pEjecutivo,'') ='' OR pEjecutivo IS NULL OR 
			NVL(pFoliosuc,'')= '' OR pFoliosuc IS NULL OR 
			NVL(pTipoRev,'')= '' OR pTipoRev IS NULL 
		THEN
			LET cCodRet = '00001'; --Uno de los campos obligatorios viene vacio
			RETURN cCodRet, CodProceso, CodRet2,'','','';
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBicheqRev;
		
		LET cCodRetBicheqRev = LPAD(TRIM(cCodRetBicheqRev), 5, '0');
		
		IF cCodRetBicheqRev <> '00000' THEN 
			LET CodRet2 = cCodRetBicheqRev;
			LET CodProceso =  '01';
			RETURN cCodRet,CodProceso,CodRet2,'','','';
		END IF;
		
		EXECUTE PROCEDURE bdinvers:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBdinversRev,cRetBdinvers;
		
		LET cCodRetBdinversRev = LPAD(TRIM(cCodRetBdinversRev), 5, '0');
		
		IF cCodRetBdinversRev <> '00000'THEN
			LET CodRet2 = cCodRetBdinversRev;
			LET CodProceso =  '02';	
			RETURN cCodRet,CodProceso,CodRet2,'','','';
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
			INTO cCodRetBdicredRev;
		
		LET cCodRetBdicredRev = LPAD(TRIM(cCodRetBdicredRev), 5, '0');
		
		IF cCodRetBdicredRev <> '00000'THEN
			LET CodRet2 = cCodRetBdicredRev;
			LET CodProceso =  '03';
			RETURN cCodRet,CodProceso,CodRet2,'','','';
		END IF;
		
		IF (pTipoEjec = 'A') THEN --Solo para el reverso automatico
		
			EXECUTE PROCEDURE bditrans:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
			INTO cCodRetBditransRev;
			
			LET cCodRetBditransRev = LPAD(TRIM(cCodRetBditransRev), 5, '0');
			
			IF cCodRetBditransRev <> '00000' THEN
				LET CodRet2 = cCodRetBditransRev;
				LET CodProceso =  '04';
				RETURN cCodRet,CodProceso,CodRet2,'','','';
			END IF;				 
		END IF;
			
		EXECUTE PROCEDURE bdisuc:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBdisucRev;
		
		LET cCodRetBdisucRev = LPAD(TRIM(cCodRetBdisucRev), 5, '0');
		
		IF cCodRetBdisucRev <> '00000'THEN
			LET CodRet2= cCodRetBdisucRev;
			LET CodProceso =  '05';
			RETURN cCodRet,CodProceso,CodRet2,'','','';
		END IF;
		
		IF (pTipoEjec = 'A') THEN --Solo para el reverso automatico
			EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(pNumCredito,pFolioPromo,pTipoEjec)
			INTO cCodRetBdicredRevpromo;
			
			LET cCodRetBdicredRevpromo = LPAD(TRIM(cCodRetBdicredRevpromo), 5, '0');
			
			IF cCodRetBdicredRevpromo <> '00000'THEN
				LET CodRet2 = cCodRetBdicredRevpromo;
				LET CodProceso =  '06';
				RETURN cCodRet,CodProceso,CodRet2,'','','';
			END IF;
		END IF;

		DELETE FROM bdisac:"informix".tmpResponseCardif WHERE folio_suc = pFoliosuc;
		EXECUTE PROCEDURE bdisac:"informix".sp_guarda_tmpResponseCardif(pFoliosuc,pNumerosPolizas) INTO cCodRetGuardaResponse;

		FOREACH
			SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno, num_poliza--, fechanac 
			INTO pNumCte, cNombre1, cNombre2, cApPat, cApMat, cPoliza--, cFechaNac
			FROM bdisac:"informix".sac_cardif_migrante 
			WHERE empresa = pEmpresa 
			AND folio_suc = pFoliosuc
			
				SELECT codret INTO cCodResponse FROM tmpResponseCardif 
				WHERE poliza = cPoliza AND codret = '0';
				
				IF cCodResponse = '0' THEN				
				
					UPDATE bdisac:"informix".sac_cardif_migrante 
					SET estatus = '5' 
					WHERE empresa = pEmpresa 
					AND folio_suc = pFoliosuc
					AND numcte =  pNumCte
					AND nombre1 = cNombre1
					AND nombre2 = cNombre2
					AND apell_paterno = cApPat
					AND apell_materno = cApMat;
					--AND fechanac = cFechaNac;

					SELECT MAX(secuencia) 
					INTO cSecuencia
					FROM bdisac:"informix".sac_cardif_migrante 
					WHERE empresa = pEmpresa
					AND sucursal = pSucursal
					AND numcte = pNumCte
					AND nombre1 = TRIM(cNombre1)
					AND nombre2 = TRIM(cNombre2)
					AND apell_paterno = TRIM(cApPat)
					AND apell_materno = TRIM(cApMat)
					--AND fechanac = cFechaNac
					AND estatus = '3';

					UPDATE bdisac:"informix".sac_cardif_migrante 
					SET estatus = '2' 
					WHERE empresa = pEmpresa
					AND sucursal = pSucursal
					AND numcte = pNumCte 
					AND estatus = '3'
					AND secuencia = cSecuencia;
					
				END IF;
				LET cCodResponse = '';
		END FOREACH;
	END IF;
	DELETE FROM bdisac:"informix".tmpResponseCardif WHERE folio_suc = pFoliosuc;
	RETURN cCodRet,CodProceso,CodRet2,'','','';
		
END;
END PROCEDURE;