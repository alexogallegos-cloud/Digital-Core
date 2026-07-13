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