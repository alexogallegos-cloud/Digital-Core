CREATE PROCEDURE "informix".sp_actsdodiarioc( pcuenta       CHAR(20),
                                              paniomes      CHAR(6),
                                              psucursal     CHAR(4),
                                              psaldoactual  MONEY(14,2),
                                              pintprovnp    MONEY(14,2),
                                              pdia          CHAR(2),
                                              paniomes2     CHAR(6),
                                              pdia2         CHAR(2),
                                              pstatus_cta   CHAR(1) )
RETURNING CHAR(5);
        
    DEFINE vCodRet      CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vexiste_cta  SMALLINT;
    DEFINE vsdo_ayer    DECIMAL(18,2);
    DEFINE vsdo_antier  DECIMAL(18,2);
    DEFINE vsdo_modif   CHAR(1);
    
    LET vCodRet     = '000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vsqlerr     = 0;
    LET visamerr    = 0;
    LET vdescerr    = '';
    LET vexiste_cta = 0;
    LET vsdo_ayer   = 0.00;
    LET vsdo_antier = 0.00;
    LET vsdo_modif  = '';
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actsdodiarioc.err";
        TRACE ON;
        IF vsqlerr != 0 THEN
            LET vCodRet  = vsqlerr;
            LET vCodRet2 = visamerr;
            LET vCodRet3 = vdescerr;
            RETURN vCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actsdodiarioc.out";
    --- TRACE ON;
    
    LET vsdo_ayer = psaldoactual;
       
    IF vsdo_ayer is null THEN
        LET vsdo_ayer = 0.00;
    END IF;
       
    SELECT DECODE( pdia2,  1, capvig1,   2, capvig2,   3, capvig3,   4, capvig4,   5, capvig5,   
                           6, capvig6,   7, capvig7,   8, capvig8,   9, capvig9,  10, capvig10,
                          11, capvig11, 12, capvig12, 13, capvig13, 14, capvig14, 15, capvig15, 
                          16, capvig16, 17, capvig17, 18, capvig18, 19, capvig19, 20, capvig20,
                          21, capvig21, 22, capvig22, 23, capvig23, 24, capvig24, 25, capvig25, 
                          26, capvig26, 27, capvig27, 28, capvig28, 29, capvig29, 30, capvig30, 31, capvig31 )
      INTO vsdo_antier
      FROM sc_sdodiarioc
     WHERE cuenta = pcuenta
       AND aniomes = paniomes2;
       
    IF vsdo_antier is null THEN
        LET vsdo_antier = 0.00;
    END IF;
    
    IF vsdo_ayer <> vsdo_antier THEN
        LET vsdo_modif = 'V';
    ELSE
        LET vsdo_modif = 'F';
    END IF;
    
    SELECT COUNT(*)
      INTO vexiste_cta
      FROM sc_sdodiarioc
     WHERE cuenta = pcuenta
       AND aniomes = paniomes;
       
    IF vexiste_cta > 0 THEN 
        UPDATE sc_sdodiarioc 
           SET capvig1     =  DECODE( pdia,  1, psaldoactual, capvig1     ),
               intprovnp1  =  DECODE( pdia,  1, pintprovnp,   intprovnp1  ),
               statuscta1  =  DECODE( pdia,  1, pstatus_cta,  statuscta1  ),
               capvig2     =  DECODE( pdia,  2, psaldoactual, capvig2     ),
               intprovnp2  =  DECODE( pdia,  2, pintprovnp,   intprovnp2  ),
               statuscta2  =  DECODE( pdia,  2, pstatus_cta,  statuscta2  ),
               capvig3     =  DECODE( pdia,  3, psaldoactual, capvig3     ),
               intprovnp3  =  DECODE( pdia,  3, pintprovnp,   intprovnp3  ),
               statuscta3  =  DECODE( pdia,  3, pstatus_cta,  statuscta3  ),
               capvig4     =  DECODE( pdia,  4, psaldoactual, capvig4     ),
               intprovnp4  =  DECODE( pdia,  4, pintprovnp,   intprovnp4  ),
               statuscta4  =  DECODE( pdia,  4, pstatus_cta,  statuscta4  ),
               capvig5     =  DECODE( pdia,  5, psaldoactual, capvig5     ),
               intprovnp5  =  DECODE( pdia,  5, pintprovnp,   intprovnp5  ),
               statuscta5  =  DECODE( pdia,  5, pstatus_cta,  statuscta5  ),
               capvig6     =  DECODE( pdia,  6, psaldoactual, capvig6     ),
               intprovnp6  =  DECODE( pdia,  6, pintprovnp,   intprovnp6  ),
               statuscta6  =  DECODE( pdia,  6, pstatus_cta,  statuscta6  ),
               capvig7     =  DECODE( pdia,  7, psaldoactual, capvig7     ),
               intprovnp7  =  DECODE( pdia,  7, pintprovnp,   intprovnp7  ),
               statuscta7  =  DECODE( pdia,  7, pstatus_cta,  statuscta7  ),
               capvig8     =  DECODE( pdia,  8, psaldoactual, capvig8     ),
               intprovnp8  =  DECODE( pdia,  8, pintprovnp,   intprovnp8  ),
               statuscta8  =  DECODE( pdia,  8, pstatus_cta,  statuscta8  ),
               capvig9     =  DECODE( pdia,  9, psaldoactual, capvig9     ),
               intprovnp9  =  DECODE( pdia,  9, pintprovnp,   intprovnp9  ),
               statuscta9  =  DECODE( pdia,  9, pstatus_cta,  statuscta9  ),
               capvig10    =  DECODE( pdia, 10, psaldoactual, capvig10    ),
               intprovnp10 =  DECODE( pdia, 10, pintprovnp,   intprovnp10 ),
               statuscta10 =  DECODE( pdia, 10, pstatus_cta,  statuscta10 ),
               capvig11    =  DECODE( pdia, 11, psaldoactual, capvig11    ),
               intprovnp11 =  DECODE( pdia, 11, pintprovnp,   intprovnp11 ),
               statuscta11 =  DECODE( pdia, 11, pstatus_cta,  statuscta11 ),
               capvig12    =  DECODE( pdia, 12, psaldoactual, capvig12    ),
               intprovnp12 =  DECODE( pdia, 12, pintprovnp,   intprovnp12 ),
               statuscta12 =  DECODE( pdia, 12, pstatus_cta,  statuscta12 ),
               capvig13    =  DECODE( pdia, 13, psaldoactual, capvig13    ),
               intprovnp13 =  DECODE( pdia, 13, pintprovnp,   intprovnp13 ),
               statuscta13 =  DECODE( pdia, 13, pstatus_cta,  statuscta13 ),
               capvig14    =  DECODE( pdia, 14, psaldoactual, capvig14    ),
               intprovnp14 =  DECODE( pdia, 14, pintprovnp,   intprovnp14 ),
               statuscta14 =  DECODE( pdia, 14, pstatus_cta,  statuscta14 ),
               capvig15    =  DECODE( pdia, 15, psaldoactual, capvig15    ),
               intprovnp15 =  DECODE( pdia, 15, pintprovnp,   intprovnp15 ),
               statuscta15 =  DECODE( pdia, 15, pstatus_cta,  statuscta15 ),
               capvig16    =  DECODE( pdia, 16, psaldoactual, capvig16    ),
               intprovnp16 =  DECODE( pdia, 16, pintprovnp,   intprovnp16 ),
               statuscta16 =  DECODE( pdia, 16, pstatus_cta,  statuscta16 ),
               capvig17    =  DECODE( pdia, 17, psaldoactual, capvig17    ),
               intprovnp17 =  DECODE( pdia, 17, pintprovnp,   intprovnp17 ),
               statuscta17 =  DECODE( pdia, 17, pstatus_cta,  statuscta17 ),
               capvig18    =  DECODE( pdia, 18, psaldoactual, capvig18    ),
               intprovnp18 =  DECODE( pdia, 18, pintprovnp,   intprovnp18 ),
               statuscta18 =  DECODE( pdia, 18, pstatus_cta,  statuscta18 ),
               capvig19    =  DECODE( pdia, 19, psaldoactual, capvig19    ),
               intprovnp19 =  DECODE( pdia, 19, pintprovnp,   intprovnp19 ),
               statuscta19 =  DECODE( pdia, 19, pstatus_cta,  statuscta19 ),
               capvig20    =  DECODE( pdia, 20, psaldoactual, capvig20    ),
               intprovnp20 =  DECODE( pdia, 20, pintprovnp,   intprovnp20 ),
               statuscta20 =  DECODE( pdia, 20, pstatus_cta,  statuscta20 ),
               capvig21    =  DECODE( pdia, 21, psaldoactual, capvig21    ),
               intprovnp21 =  DECODE( pdia, 21, pintprovnp,   intprovnp21 ),
               statuscta21 =  DECODE( pdia, 21, pstatus_cta,  statuscta21 ),
               capvig22    =  DECODE( pdia, 22, psaldoactual, capvig22    ),
               intprovnp22 =  DECODE( pdia, 22, pintprovnp,   intprovnp22 ),
               statuscta22 =  DECODE( pdia, 22, pstatus_cta,  statuscta22 ),
               capvig23    =  DECODE( pdia, 23, psaldoactual, capvig23    ),
               intprovnp23 =  DECODE( pdia, 23, pintprovnp,   intprovnp23 ),
               statuscta23 =  DECODE( pdia, 23, pstatus_cta,  statuscta23 ),
               capvig24    =  DECODE( pdia, 24, psaldoactual, capvig24    ),
               intprovnp24 =  DECODE( pdia, 24, pintprovnp,   intprovnp24 ),
               statuscta24 =  DECODE( pdia, 24, pstatus_cta,  statuscta24 ),
               capvig25    =  DECODE( pdia, 25, psaldoactual, capvig25    ),
               intprovnp25 =  DECODE( pdia, 25, pintprovnp,   intprovnp25 ),
               statuscta25 =  DECODE( pdia, 25, pstatus_cta,  statuscta25 ),
               capvig26    =  DECODE( pdia, 26, psaldoactual, capvig26    ),
               intprovnp26 =  DECODE( pdia, 26, pintprovnp,   intprovnp26 ),
               statuscta26 =  DECODE( pdia, 26, pstatus_cta,  statuscta26 ),
               capvig27    =  DECODE( pdia, 27, psaldoactual, capvig27    ),
               intprovnp27 =  DECODE( pdia, 27, pintprovnp,   intprovnp27 ),
               statuscta27 =  DECODE( pdia, 27, pstatus_cta,  statuscta27 ),
               capvig28    =  DECODE( pdia, 28, psaldoactual, capvig28    ),
               intprovnp28 =  DECODE( pdia, 28, pintprovnp,   intprovnp28 ),
               statuscta28 =  DECODE( pdia, 28, pstatus_cta,  statuscta28 ),
               capvig29    =  DECODE( pdia, 29, psaldoactual, capvig29    ),
               intprovnp29 =  DECODE( pdia, 29, pintprovnp,   intprovnp29 ),
               statuscta29 =  DECODE( pdia, 29, pstatus_cta,  statuscta29 ),
               capvig30    =  DECODE( pdia, 30, psaldoactual, capvig30    ),
               intprovnp30 =  DECODE( pdia, 30, pintprovnp,   intprovnp30 ),
               statuscta30 =  DECODE( pdia, 30, pstatus_cta,  statuscta30 ),
               capvig31    =  DECODE( pdia, 31, psaldoactual, capvig31    ),
               intprovnp31 =  DECODE( pdia, 31, pintprovnp,   intprovnp31 ),
               statuscta31 =  DECODE( pdia, 31, pstatus_cta,  statuscta31 ),
               capvigacum  =  capvigacum + psaldoactual,
               diacum      =  diacum + 1,
               sdo_modif   =  vsdo_modif
         WHERE cuenta  = pcuenta
           AND aniomes = paniomes;
    ELSE
        INSERT INTO sc_sdodiarioc VALUES
        ( pcuenta, paniomes, psucursal,
          DECODE( pdia, 1,  psaldoactual, 0 ),
          DECODE( pdia, 1,  pintprovnp,   0 ),
          DECODE( pdia, 1,  pstatus_cta, '' ),
          DECODE( pdia, 2,  psaldoactual, 0 ),
          DECODE( pdia, 2,  pintprovnp,   0 ),
          DECODE( pdia, 2,  pstatus_cta, '' ),
          DECODE( pdia, 3,  psaldoactual, 0 ),
          DECODE( pdia, 3,  pintprovnp,   0 ),
          DECODE( pdia, 3,  pstatus_cta, '' ),
          DECODE( pdia, 4,  psaldoactual, 0 ),
          DECODE( pdia, 4,  pintprovnp,   0 ),
          DECODE( pdia, 4,  pstatus_cta, '' ),
          DECODE( pdia, 5,  psaldoactual, 0 ),
          DECODE( pdia, 5,  pintprovnp,   0 ),
          DECODE( pdia, 5,  pstatus_cta, '' ),
          DECODE( pdia, 6,  psaldoactual, 0 ),
          DECODE( pdia, 6,  pintprovnp,   0 ),
          DECODE( pdia, 6,  pstatus_cta, '' ),
          DECODE( pdia, 7,  psaldoactual, 0 ),
          DECODE( pdia, 7,  pintprovnp,   0 ),
          DECODE( pdia, 7,  pstatus_cta, '' ),
          DECODE( pdia, 8,  psaldoactual, 0 ),
          DECODE( pdia, 8,  pintprovnp,   0 ),
          DECODE( pdia, 8,  pstatus_cta, '' ),
          DECODE( pdia, 9,  psaldoactual, 0 ),
          DECODE( pdia, 9,  pintprovnp,   0 ),
          DECODE( pdia, 9,  pstatus_cta, '' ),
          DECODE( pdia, 10, psaldoactual, 0 ),
          DECODE( pdia, 10, pintprovnp,   0 ),
          DECODE( pdia, 10, pstatus_cta, '' ),
          DECODE( pdia, 11, psaldoactual, 0 ),
          DECODE( pdia, 11, pintprovnp,   0 ),
          DECODE( pdia, 11, pstatus_cta, '' ),
          DECODE( pdia, 12, psaldoactual, 0 ),
          DECODE( pdia, 12, pintprovnp,   0 ),
          DECODE( pdia, 12, pstatus_cta, '' ),
          DECODE( pdia, 13, psaldoactual, 0 ),
          DECODE( pdia, 13, pintprovnp,   0 ),
          DECODE( pdia, 13, pstatus_cta, '' ),
          DECODE( pdia, 14, psaldoactual, 0 ),
          DECODE( pdia, 14, pintprovnp,   0 ),
          DECODE( pdia, 14, pstatus_cta, '' ),
          DECODE( pdia, 15, psaldoactual, 0 ),
          DECODE( pdia, 15, pintprovnp,   0 ),
          DECODE( pdia, 15, pstatus_cta, '' ),
          DECODE( pdia, 16, psaldoactual, 0 ),
          DECODE( pdia, 16, pintprovnp,   0 ),
          DECODE( pdia, 16, pstatus_cta, '' ),
          DECODE( pdia, 17, psaldoactual, 0 ),
          DECODE( pdia, 17, pintprovnp,   0 ),
          DECODE( pdia, 17, pstatus_cta, '' ),
          DECODE( pdia, 18, psaldoactual, 0 ),
          DECODE( pdia, 18, pintprovnp,   0 ),
          DECODE( pdia, 18, pstatus_cta, '' ),
          DECODE( pdia, 19, psaldoactual, 0 ),
          DECODE( pdia, 19, pintprovnp,   0 ),
          DECODE( pdia, 19, pstatus_cta, '' ),
          DECODE( pdia, 20, psaldoactual, 0 ),
          DECODE( pdia, 20, pintprovnp,   0 ),
          DECODE( pdia, 20, pstatus_cta, '' ),
          DECODE( pdia, 21, psaldoactual, 0 ),
          DECODE( pdia, 21, pintprovnp,   0 ),
          DECODE( pdia, 21, pstatus_cta, '' ),
          DECODE( pdia, 22, psaldoactual, 0 ),
          DECODE( pdia, 22, pintprovnp,   0 ),
          DECODE( pdia, 22, pstatus_cta, '' ),
          DECODE( pdia, 23, psaldoactual, 0 ),
          DECODE( pdia, 23, pintprovnp,   0 ),
          DECODE( pdia, 23, pstatus_cta, '' ),
          DECODE( pdia, 24, psaldoactual, 0 ),
          DECODE( pdia, 24, pintprovnp,   0 ),
          DECODE( pdia, 24, pstatus_cta, '' ),
          DECODE( pdia, 25, psaldoactual, 0 ),
          DECODE( pdia, 25, pintprovnp,   0 ),
          DECODE( pdia, 25, pstatus_cta, '' ),
          DECODE( pdia, 26, psaldoactual, 0 ),
          DECODE( pdia, 26, pintprovnp,   0 ),
          DECODE( pdia, 26, pstatus_cta, '' ),
          DECODE( pdia, 27, psaldoactual, 0 ),
          DECODE( pdia, 27, pintprovnp,   0 ),
          DECODE( pdia, 27, pstatus_cta, '' ),
          DECODE( pdia, 28, psaldoactual, 0 ),
          DECODE( pdia, 28, pintprovnp,   0 ),
          DECODE( pdia, 28, pstatus_cta, '' ),
          DECODE( pdia, 29, psaldoactual, 0 ),
          DECODE( pdia, 29, pintprovnp,   0 ),
          DECODE( pdia, 29, pstatus_cta, '' ),
          DECODE( pdia, 30, psaldoactual, 0 ),
          DECODE( pdia, 30, pintprovnp,   0 ),
          DECODE( pdia, 30, pstatus_cta, '' ),
          DECODE( pdia, 31, psaldoactual, 0 ),
          DECODE( pdia, 31, pintprovnp,   0 ),
          DECODE( pdia, 31, pstatus_cta, '' ),
          psaldoactual, 1, 'F' );
    END IF;
    
    END;
    
    RETURN vCodRet;
    
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_inserta_solicitud_portabilidad(pEmpresa CHAR(3), 
													  pSucursal CHAR(4), 
													  pNumCte CHAR(20),
													  pBancoOrd CHAR(3),
													  pCtaOrd CHAR(20),													  
													  pTipoCtaOrd CHAR(2), 
													  pBancoRec CHAR(3), 
													  pCtaRec CHAR(20), 
													  pTipoCtaRec CHAR(2),
													  pRFCEmpresa CHAR(12),
													  pCodOperacion CHAR(2),
													  pEstatusCecoban CHAR(2),
													  pEstatusResp CHAR(2),
													  pEstatusPort CHAR(2),
													  pCveOrigen CHAR(1),
													  pCveSentido CHAR(1),
													  pNumIntentos INTEGER,
													  pFolioSol CHAR(30),
													  pUserInsert CHAR(8),
													  pComentario CHAR(60),
													  pTipo INTEGER)
--DATOS A REGRESAR---												 
	RETURNING
	CHAR(6) AS cCodRet;
	
---DECLARACIONES
DEFINE iSqlErr  	INTEGER;
DEFINE cCodRet  	CHAR(6);
DEFINE cCodRetSP  	CHAR(6);
DEFINE cCveBcoOrd   CHAR(5);
DEFINE cCveBcoRec   CHAR(5);
DEFINE cCtaRef  	CHAR(20);
DEFINE cTarjRef   	CHAR(20);
DEFINE cFecha		CHAR(10);
DEFINE dFecha		DATE;
DEFINE cCodigoError CHAR(5);
DEFINE sFuenteError SMALLINT;
DEFINE cMenRetSp    CHAR(110);
DEFINE cCuenta      CHAR(20);
DEFINE cProced_aper CHAR(2);

DEFINE vcuenta      CHAR(20);

---INICIALIZACIONES
LET iSqlErr      = 0;
LET cCodRet      = "000000";
LET cCodRetSP    = "00000";
LET cCveBcoOrd   = "";
LET cCveBcoRec   = "";
LET cCtaRef   	 = "";
LET cTarjRef   	 = "";
LET cFecha	 	 = '01/01/1990';
LET dFecha 		 = DATE(1);
LET cCodigoError = "";
LET sFuenteError = 0;
LET cProced_aper = '00';

LET vcuenta      = ''; 

BEGIN
    ON EXCEPTION SET iSqlErr	
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	 --SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/sp_inserta_solicitud_portabilidad.out";
	 --TRACE ON;
	
	IF NVL(pEmpresa,'') = "" OR NVL(pSucursal,'') = "" OR (NVL(pTipo,0) <> 1 AND NVL(pTipo,0) <> 2) THEN	
		LET cCodRet = "000001"; --PARAMETROS VACIOS
		RETURN cCodRet;			
	ELSE			
		
		SELECT fecha_hoy
		INTO dFecha
		FROM bdicheq:"informix".sc_fechas 
		WHERE empresa = pEmpresa;
			
		LET cFecha = TO_CHAR(dFecha, '%Y%m%d');
		
		SELECT cvecesif
		INTO cCveBcoOrd
		FROM bdinteg:"informix".si_bancos
		WHERE banco = pBancoOrd;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "001289";
			RETURN cCodRet;	
		END IF;
		
		SELECT cvecesif
		INTO cCveBcoRec
		FROM bdinteg:"informix".si_bancos
		WHERE banco = pBancoRec;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "001289";
			RETURN cCodRet;	
		END IF;
		
		IF NVL(pTipoCtaOrd,"") = "40" THEN
				
				--LET cCtaRef = pCtaOrd;
		
				EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCtaOrd)
				INTO cCodigoError,sFuenteError;				
				
				IF NVL(cCodigoError,"") = "0" AND NVL(sFuenteError,0) = 1 THEN
				
				ELSE
					LET cCodRet = "001283";
					RETURN cCodRet;	
				END IF;
		
		ELIF NVL(pTipoCtaOrd,"") = "3" THEN
		
				--LET cTarjRef = pCtaOrd;
			
		ELIF NVL(pTipoCtaOrd,"") <> "3" OR NVL(pTipoCtaOrd,"") <> "40" THEN
			LET cCodRet = "001292";
			RETURN cCodRet;
		END IF;
		
		
		IF NVL(pTipoCtaRec,"") = "40" THEN
				
				LET cCtaRef = pCtaRec;
		
				EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCtaRec)
				INTO cCodigoError,sFuenteError;
				
				
				IF NVL(cCodigoError,"") = "0" AND NVL(sFuenteError,0) = 1 THEN
				
				ELSE
					LET cCodRet = "001283";
					RETURN cCodRet;	
				END IF;
		
		ELIF NVL(pTipoCtaRec,"") = "3" THEN
		
				LET cTarjRef = pCtaRec;
				
		ELIF NVL(pTipoCtaRec,"") <> "3" OR NVL(pTipoCtaRec,"") <> "40" THEN
			LET cCodRet = "001293";
			RETURN cCodRet;			
		END IF;
		
		
		INSERT INTO bdicheq:"informix".sc_portacec_solicitud (empresa,folio_solicitud,sucursal,num_cte,bco_ordenante,cta_ordenante,tipo_cta_ordenante,bco_receptor,cta_receptora,tipo_cta_receptora,fecha_solicitud,rfc_empresa,cod_operacion,fecha_presentacion,estatus_cecoban,fecha_estatus_cecoban,estatus_respuesta,fecha_respuesta,estatus_portabilidad,fecha_estatus_portabilidad,clave_origen,clave_sentido,num_intentos,user_insert,fecha_solca_portabilidad,comentario) 
		VALUES (pEmpresa,pFolioSol,pSucursal,pNumCte,cCveBcoOrd,pCtaOrd,pTipoCtaOrd,cCveBcoRec,pCtaRec,pTipoCtaRec,cFecha,pRFCEmpresa,pCodOperacion,'',pEstatusCecoban,'',pEstatusResp,'',pEstatusPort,'',pCveOrigen,pCveSentido,pNumIntentos,pUserInsert,'',pComentario);

		IF NVL(pTipo,0) = 1 THEN
		
			RETURN cCodRet;
			
		ELIF NVL(pTipo,0) = 2 THEN 
	---Se agrega actualizacion del origen de recursos en la cuenta BCPL 		
			SELECT proced_aperturacta 
			INTO cProced_aper
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta_clabe = pCtaOrd;
			
			IF cProced_aper <> '02' THEN
				UPDATE bdicheq:"informix".sc_maechq 
				SET proced_aperturacta ='02' 
				WHERE cuenta_clabe = pCtaOrd;
			END IF;
--- Termina actualizacion del origen de recursos en la cuenta BCPL
				LET vcuenta = substr(pCtaOrd, 7, 11);
						
                SELECT cuenta
                INTO cCuenta
                FROM bdicheq:"informix".sc_maechq
                WHERE empresa = pEmpresa
				AND cuenta = vcuenta;
                -- AND cuenta_clabe = pCtaOrd;

			--EXECUTE PROCEDURE bdicheq:"informix".sp_inserta_portabilidad(pEmpresa,pNumCte,pCtaOrd,cCtaRef,cTarjRef,pComentario,"1","OFI",pSucursal,pUserInsert,pBancoRec)
            --BCPL 2210215
			IF (pSucursal = '5003') THEN --DESB 11022016
				EXECUTE PROCEDURE bdicheq:"informix".sp_portabprocesaalta ('WEB',pSucursal,pNumCte,cCuenta,pBancoRec,cCtaRef,cTarjRef,pComentario,pUserInsert)
				INTO cCodRetSP, cMenRetSp;
			ELSE
				EXECUTE PROCEDURE bdicheq:"informix".sp_portabprocesaalta ('OFI',pSucursal,pNumCte,cCuenta,pBancoRec,cCtaRef,cTarjRef,pComentario,pUserInsert)
				INTO cCodRetSP, cMenRetSp;
			END IF;
			
              IF cCodRetSP <> '00000' THEN
                   DELETE bdicheq:"informix".sc_portacec_solicitud 
                   WHERE empresa = pEmpresa
                    AND num_cte = pNumCte 
                    AND cta_ordenante = pCtaOrd
                    AND cta_receptora = pCtaRec;
                    
                    LET cCodRetSP = '001272';
					LET cCodRet = cCodRetSP;
              
              END IF;
            --BCPL 2210215

				RETURN cCodRet;		
		END IF;
	
	END IF;
END;
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para insertar la solicitud de alta de portabilidad de nomina para los casos de BanCoppel a .",
"			  otro banco ó de otro banco a BanCoppel.",
"Codigos de Error: ",
"",
"			cCodRet = 000001 Parametros Vacios.",
"			cCodRet = 001283 La cuenta CLABE es incorrecta; ultimo numero (digito verificador) invalido.",
"			cCodRet = 001289 No existe informacion. Favor de verificar.",
"			cCodRet = 001292 El tipo de Cuenta Ordenante es distinta, verifique.",
"			cCodRet = 001293 El tipo de Cuenta Receptora es distinta, verifique.",
"",
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 28/08/2015",
"BD     : bdicheq",
"****************************************************************************************************************************",
"Modificacion: Se modifica para agregar el origen de alta 'WEB' al procesar el alta.",
"Modificó  : Moisés Soriano",
"Solicitó: Alejandro Vazquez",
"Folio: 1636",
"Fecha  : 11/02/2015";

CREATE PROCEDURE "informix".sp_consultaconstancia_isr(pEmpresa CHAR(3),pNumCte CHAR(20),pCuenta CHAR(20),pTarjeta CHAR(20) , pTipo CHAR(1),pRegistros SMALLINT)

RETURNING
	CHAR(6) 	AS Cod_Ret,
	CHAR(20) 	AS Cuenta,
	CHAR(1) 	AS ServicioISR;

	DEFINE iSqlErr 			INTEGER;
	DEFINE iNRows 			INTEGER;
	DEFINE cCodRet 			CHAR(6);
	DEFINE cCuenta 			CHAR(20);
	DEFINE cCuentaTarjeta 	CHAR(20);
	DEFINE cServicioISR 	CHAR(1);
	DEFINE cValor 			CHAR(60);
	
	LET iSqlErr 		= 0;
	LET iNRows 			= 0;
	LET cCodRet 		= '000000';
	LET cCuenta 		= '';
	LET cCuentaTarjeta 	= '';
	LET cServicioISR 	= '';
	LET cValor 			= '' ;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			END IF;
		END EXCEPTION;    

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/tmp/sp_consultaconstancia_isr.sql";
		--TRACE ON;
		
		IF  TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCte, '')) = '' AND TRIM(NVL(pCuenta, '')) = '' AND TRIM(NVL(pTarjeta,'') )= '' OR TRIM(NVL(pTipo,'')) = '' THEN
			LET cCodRet = '000002';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
		END IF
		
		SELECT valor INTO cValor FROM "informix".sc_param WHERE codparam = 'periodoactual';
		
		IF NVL(pTipo,'') = '1' THEN
			IF NVL(pNumCte, '') <> '' THEN
				FOREACH		    
					SELECT SKIP pRegistros DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND num_cte = TRIM(NVL(pNumCte,''))
					ORDER BY cuenta ASC
					
					SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec: "informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,'')) WITH RESUME;
					
				END FOREACH;
				
			ELIF NVL(pCuenta, '') <> '' THEN
							
					SELECT DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND cuenta = TRIM(NVL(pCuenta,''));
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			
			ELIF NVL(pTarjeta, '') <> '' THEN
			
					SELECT cuenta INTO cCuentaTarjeta FROM "informix".sc_tarjeta WHERE num_tarjeta = TRIM(NVL(pTarjeta,''));

					SELECT DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND cuenta = TRIM(NVL(cCuentaTarjeta,''));
						
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));		

			END IF;
		ELIF NVL(pTipo,'') = '2' THEN
			IF NVL(pNumCte, '') <> '' THEN
				FOREACH		    
					SELECT SKIP pRegistros DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a , "informix".sc_maechq b
					WHERE a.empresa = NVL(pEmpresa,'') AND a.num_cte = NVL(pNumCte,'')
					AND a.ejercicio >= NVL(cvalor,'') AND a.cuenta = b.cuenta
					
					SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;	
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,'')) WITH RESUME;
					
				END FOREACH;
				
			ELIF NVL(pCuenta, '') <> '' THEN						
							
					SELECT  DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a, "informix".sc_maechq b
					WHERE a.empresa = TRIM(NVL(pEmpresa,'')) AND a.cuenta = TRIM(NVL(pCuenta,'')) AND a.ejercicio >= TRIM(NVL(cvalor,'')) AND a.cuenta = b.cuenta;
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			
			ELIF NVL(pTarjeta, '') <> '' THEN
			
					SELECT cuenta INTO cCuentaTarjeta FROM "informix".sc_tarjeta WHERE num_tarjeta = TRIM(NVL(pTarjeta,''));

					SELECT  DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a, "informix".sc_maechq b
					WHERE a.empresa = TRIM(NVL(pEmpresa,'')) AND a.cuenta = TRIM(NVL(cCuentaTarjeta,'')) AND a.ejercicio >= TRIM(NVL(cvalor,'')) AND a.cuenta = b.cuenta;
						
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));

			END IF;
		ELSE
			LET cCodRet = '000005';
		END IF;
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");		
		IF iNRows = 0 OR  cCodRet <> '000000' THEN
			LET cCodRet = '000005';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
		END IF;		

	END;
END PROCEDURE
DOCUMENT
'FOLIO: 37-RQI 15 023 CONSULTA CFDI-ISR',
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 07/04/2016',
'MODIFICACIÃN: SE CREA PROCEDIMIENTO PARA OBTENER LAS CUENTAS QUE TIENEN CONSTANCIA DE RETENCION DE ISR',
'Y EL SERVICIO ACTIVO DE ISR MEDIANTE CORREO ELECTRONICO',
'SOLICITA: RODOLFO GÃMEZ',
'DB:BDICHEQ';

CREATE PROCEDURE "informix".sp_consultaperiodo_isr (pEmpresa CHAR(3),pCuenta CHAR(20), pRegistros SMALLINT)
RETURNING
	CHAR(6) AS Cod_Ret,
	CHAR(4) AS Periodo;

	DEFINE iSqlErr INTEGER;
	DEFINE iNRows INTEGER;
	DEFINE cCodRet CHAR(6);
	DEFINE cPeriodo CHAR(4);
	
	LET iSqlErr = 0;
	LET iNRows = 0;
	LET cCodRet = '000000';
	LET cPeriodo = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cPeriodo;
		END IF;
	END EXCEPTION;    

	SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

	  --SET DEBUG FILE TO "/tmp/sp_consultaperiodo_isr.out";
	  --TRACE ON;
	
	IF  NVL(pEmpresa,'') = ''  OR NVL(pCuenta, '') = ''  THEN
		LET cCodRet = '000002';
		RETURN cCodRet,cPeriodo;
	END IF

	FOREACH		    
		SELECT SKIP pRegistros DISTINCT(ejercicio) INTO cPeriodo
		FROM 'informix'.sc_retenisr
		WHERE empresa = pEmpresa 
		AND cuenta = pCuenta
		ORDER BY ejercicio ASC		
		
		RETURN cCodRet,NVL(cPeriodo,'')  WITH RESUME;
		
	END FOREACH;	
	
	LET iNRows = dbinfo("sqlca.sqlerrd2");		
	IF iNRows = 0 THEN
		LET cCodRet = '000005';
		RETURN cCodRet,cPeriodo;
	END IF;		

END;
END PROCEDURE
DOCUMENT
'Folio: 37-RQI 15 023 Consulta de Constancia',
'Autor: 95281495-Ernesto Aguilera',
'Fecha: 08/04/2016',
'ModificaciÃ³n: Se crea procedimiento para obtener los periodos de las cuentas que tienen constancia de retencion de ISR y el servicio activo de ISR mediante correo electronico',
'Sustento: RQI 15 023 Consulta CFDI-ISR.pdf',
'Solicita: Rodolfo GÃ³mez',
'DB:bdicheq';

CREATE PROCEDURE "informix".sc_datosriesgoscaptacion()
RETURNING CHAR(5);
--------------------------------------------------------------
--ACTIVIDAD:Recopila los datos de captacion del cliente, como
--el saldo disponible hasta el dia de hoy y los guarda en la
--tabla sc_riesgoscap.
--------------------------------------------------------------

--Definicion de variables
DEFINE vchrcodret        CHAR(5);
DEFINE vchrnumcte        CHAR(20);
DEFINE vchrnumcuenta     CHAR(20);
DEFINE vchrsucursal	     CHAR(4);
DEFINE vchrplaza		 CHAR(3);
DEFINE vchrproducto	     CHAR(4);
DEFINE vchractividad     CHAR(3);
DEFINE vchrresidencia	 CHAR(1);
DEFINE vchredocivil		 CHAR(2);
DEFINE vchrsexo	  	     CHAR(1);
DEFINE vchrhabitaen		 CHAR(2);
DEFINE vchrocupacion     CHAR(30);
DEFINE vchrciudad        CHAR(15);

DEFINE vintcodret        INTEGER;

DEFINE vdectasa			 DECIMAL(9,6);

DEFINE vintanioshab	     SMALLINT;
DEFINE vintdiasacum      SMALLINT;
DEFINE vintdependientes  SMALLINT;

DEFINE vmnyacumsdo		 MONEY(14,2);
DEFINE vmnysdoprom		 MONEY(14,2);
DEFINE vmnysdoactual	 MONEY(14,2);
DEFINE vmnysdoret		 MONEY(14,2);
DEFINE vmnysdocong		 MONEY(14,2);
DEFINE vmnyacumsdopos    MONEY(14,2);

DEFINE vdtefechaaniv     DATE;
DEFINE vdtefechaalta     DATE;
DEFINE vdteprimermov     DATE;
DEFINE vdteultimomov     DATE;
DEFINE vdtefechahoy      DATE;

--DEBUG FLAG
--SET debug file to "/tmp/sc_datosriesgoscaptacion.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET vintcodret
   IF vintcodret <> 0 THEN
      LET vchrcodret=vintcodret;
      RETURN vchrcodret;
   END IF;
END EXCEPTION;

--Inicializacion de variables
LET vchrcodret        ="000";
LET vchrnumcte        ="";
LET vchrnumcuenta	  ="";
LET vchrsucursal      ="";
LET vchrplaza         ="";
LET vchrproducto      ="";
LET vchractividad     ="";
LET vchrresidencia    ="";
LET vchredocivil      ="";
LET vchrsexo          ="";
LET vchrhabitaen      ="";
LET vchrocupacion     ="";
LET vchrciudad        ="";

LET vintcodret        =0;

LET vdectasa          =0;

LET vintanioshab      =0;
LET vintdiasacum      =0;
LET vintdependientes  =0;

LET vmnyacumsdo       =0;
LET vmnysdoprom       =0;
LET vmnysdoactual     =0;
LET vmnysdoret		  =0;
LET vmnysdocong		  =0;


TRUNCATE TABLE bdicheq:sc_riesgoscap;

--Obtiene la fecha del dia de hoy
SELECT fecha_hoy INTO vdtefechahoy FROM bdinteg:si_fechas;

FOREACH
    SELECT mae.num_cte,mae.cuenta,mae.sucursal,mae.plaza,mae.producto,fec.valor,
           cli.actividad_princ,cli.residencia,cte.estado_civil,cte.sexo,cte.anios_habita,
           noc.acum_sdo_pos,noc.dias_acum_int,mae.sdo_actual,mae.sdo_retenido,mae.sdo_cong,noc.acum_sdo_pos,
           noc.fecha_alta,cli.fecha_alta,pfs.descripcion,cte.dependientes
    INTO vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdectasa,
         vchractividad,vchrresidencia,vchredocivil,vchrsexo,vintanioshab,
         vmnyacumsdo,vintdiasacum,vmnysdoactual,vmnysdoret,vmnysdocong,vmnyacumsdopos,
         vdtefechaaniv,vdtefechaalta,vchrocupacion,vintdependientes
    FROM bdicheq:sc_maechq mae
    LEFT OUTER JOIN bdicheq:sc_producto pro ON(mae.producto=pro.producto AND mae.empresa=pro.empresa)
    LEFT OUTER JOIN bdicheq:sc_maenoc noc ON(noc.cuenta=mae.cuenta AND mae.empresa=noc.empresa)
	LEFT OUTER JOIN bdinteg:si_cliente cli ON(mae.num_cte=cli.numcte AND mae.empresa=cli.empresa)
	LEFT OUTER JOIN bdinteg:si_ctepf cte ON(mae.num_cte=cte.numcte AND mae.empresa=cte.empresa)
	LEFT OUTER JOIN bdinteg:si_fechavalor fec ON(pro.tasa=fec.tasa AND pro.empresa=fec.empresa)
    LEFT OUTER JOIN bdinteg:si_profesion pfs ON(cte.profesion=pfs.profesion)
    WHERE mae.status_cta='1' AND mae.empresa='001'

    --Calcula el saldo promedio del cliente
	IF vmnysdoprom IS NOT NULL AND vmnyacumsdo IS NOT NULL AND vintdiasacum IS NOT NULL AND vintdiasacum <> 0 THEN
		LET vmnysdoprom = vmnyacumsdo / vintdiasacum;
	END IF;

    --Calcula el saldo actual del cliente
	IF vmnysdoactual IS NOT NULL AND vmnysdoret IS NOT NULL AND vmnysdocong IS NOT NULL THEN
		LET vmnysdoactual = vmnysdoactual - (vmnysdoret + vmnysdocong);
	END IF;

    --Obtiene la fecha del primer y ultimo movimiento
    SELECT MIN(fech_alt),MAX(fech_alt) INTO vdteprimermov,vdteultimomov
    FROM bdicheq:sc_movhis WHERE cuenta=vchrnumcuenta;

    --Obtiene la ciudad del cliente
    SELECT a.nombreciudad INTO vchrciudad FROM bdinteg:si_catciudades a,bdinteg:si_direcciones b
    WHERE b.numcte=vchrnumcte AND b.numerociudad=a.numerociudad AND b.tipo_dir='1' AND b.secuencia=1;

    INSERT INTO sc_riesgoscap ( empresa,numcte,cuenta,sucursal,plaza,producto,tasa,actividad,residencia,
                                edocivil,sexo,anioshab,sdoprom,sdodisp,fecha,ocupacion,dependientes,
                                ciudad,provintdev,fechaaniv,fecaltacte,primermov,ultimomov)
    VALUES ( '001',vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdectasa,vchractividad,vchrresidencia,
            vchredocivil,vchrsexo,vintanioshab,vmnysdoprom,vmnysdoactual,vdtefechahoy,vchrocupacion,vintdependientes,
            vchrciudad,vmnyacumsdopos,vdtefechaaniv,vdtefechaalta,vdteprimermov,vdteultimomov);

END FOREACH;

RETURN vchrcodret;
END;

END PROCEDURE;