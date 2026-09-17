CREATE PROCEDURE "informix".sp_reverso_cardif(pEmpresa CHAR(3),pSucursal CHAR(4),pNumCte CHAR(20), pEjecutivo CHAR(8),pFoliosuc CHAR(16),pTipoRev CHAR(1),pNumCredito CHAR(20),pFolioPromo CHAR(16),pTipoEjec CHAR(1))

	RETURNING CHAR(5),CHAR(2),CHAR(5);

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
	DEFINE cNombre1		CHAR(26);
	DEFINE cNombre2		CHAR(26);
	DEFINE cApPat		CHAR(26);
	DEFINE cApMat		CHAR(26);
	DEFINE cFechaNac	CHAR(23);
	DEFINE cSecuencia   INT;
	
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
	LET cCodRetBdicredRevpromo 		= '';
	LET cNombre1					= '';
	LET cNombre2					= '';
	LET cApPat						= '';
	LET cApMat						= '';
	LET cFechaNac					= '';
	LET cSecuencia 	    			= 0;
	
	--SET DEBUG FILE TO '/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_reverso_cardif.out';
	--TRACE ON;
BEGIN	
		ON EXCEPTION
		SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,CodProceso,CodRet2 ;
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
				RETURN cCodRet, CodProceso, CodRet2;
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
			RETURN cCodRet, CodProceso, CodRet2;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBicheqRev;
		
		LET cCodRetBicheqRev = LPAD(TRIM(cCodRetBicheqRev), 5, '0');
		
		IF cCodRetBicheqRev <> '00000' THEN 
			LET CodRet2 = cCodRetBicheqRev;
			LET CodProceso =  '01';
			RETURN cCodRet,CodProceso,CodRet2;
		END IF;
		
		EXECUTE PROCEDURE bdinvers:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBdinversRev,cRetBdinvers;
		
		LET cCodRetBdinversRev = LPAD(TRIM(cCodRetBdinversRev), 5, '0');
		
		IF cCodRetBdinversRev <> '00000'THEN
			LET CodRet2 = cCodRetBdinversRev;
			LET CodProceso =  '02';	
			RETURN cCodRet,CodProceso,CodRet2;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
			INTO cCodRetBdicredRev;
		
		LET cCodRetBdicredRev = LPAD(TRIM(cCodRetBdicredRev), 5, '0');
		
		IF cCodRetBdicredRev <> '00000'THEN
			LET CodRet2 = cCodRetBdicredRev;
			LET CodProceso =  '03';
			RETURN cCodRet,CodProceso,CodRet2;
		END IF;
		
		IF (pTipoEjec = 'A') THEN --Solo para el reverso automatico
		
			EXECUTE PROCEDURE bditrans:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
			INTO cCodRetBditransRev;
			
			LET cCodRetBditransRev = LPAD(TRIM(cCodRetBditransRev), 5, '0');
			
			IF cCodRetBditransRev <> '00000' THEN
				LET CodRet2 = cCodRetBditransRev;
				LET CodProceso =  '04';
				RETURN cCodRet,CodProceso,CodRet2;
			END IF;				 
		END IF;
			
		EXECUTE PROCEDURE bdisuc:"informix".reversion(pempresa,psucursal,pEjecutivo,pFoliosuc,pTipoRev)
		INTO cCodRetBdisucRev;
		
		LET cCodRetBdisucRev = LPAD(TRIM(cCodRetBdisucRev), 5, '0');
		
		IF cCodRetBdisucRev <> '00000'THEN
			LET CodRet2= cCodRetBdisucRev;
			LET CodProceso =  '05';
			RETURN cCodRet,CodProceso,CodRet2;
		END IF;
		
		IF (pTipoEjec = 'A') THEN --Solo para el reverso automatico
			EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(pNumCredito,pFolioPromo,pTipoEjec)
			INTO cCodRetBdicredRevpromo;
			
			LET cCodRetBdicredRevpromo = LPAD(TRIM(cCodRetBdicredRevpromo), 5, '0');
			
			IF cCodRetBdicredRevpromo <> '00000'THEN
				LET CodRet2 = cCodRetBdicredRevpromo;
				LET CodProceso =  '06';
				RETURN cCodRet,CodProceso,CodRet2;
			END IF;
		END IF;
		
		FOREACH
			SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno--, fechanac 
				INTO pNumCte, cNombre1, cNombre2, cApPat, cApMat--, cFechaNac
				FROM bdisac:"informix".sac_cardif_migrante 
				WHERE empresa = pEmpresa 
				  AND folio_suc = pFoliosuc

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
		END FOREACH;
	END IF;
	
	RETURN cCodRet,CodProceso,CodRet2;
		
END;
END PROCEDURE;