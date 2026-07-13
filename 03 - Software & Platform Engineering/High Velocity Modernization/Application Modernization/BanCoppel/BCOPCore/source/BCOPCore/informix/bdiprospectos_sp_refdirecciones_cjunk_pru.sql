CREATE PROCEDURE "informix".sp_refdirecciones_cjunk_pru( pEmpresa           CHAR(3),
                                                     pTipo              CHAR (1),
                                                     pFuncion           CHAR(1),
                                                     pNumCte            CHAR(20),
                                                     pSecuencia         INTEGER,
                                                     pTiipoDir          CHAR(1),
                                                     pCalle             CHAR(40),
                                                     pColonia           CHAR(60),
                                                     pMunicipio         CHAR(5),
                                                     pEntreCalles       CHAR(40),
                                                     pPais              CHAR(3),
                                                     pEntidad           CHAR(2),
                                                     pLocalidad         CHAR(3),
                                                     pCodPostal         CHAR(5),
                                                     pTipoTel1          CHAR(1),
                                                     pTelefono1         CHAR(13),
                                                     pTipoTel2          CHAR(1),
                                                     pTelefono2         CHAR(13),
                                                     pTipoTel3          CHAR(1),
                                                     pTelefono3         CHAR(13),
                                                     pExtension         CHAR(5),
                                                     pEstadoInegi       CHAR(2),
                                                     pMunicipioInegi    CHAR(3),
                                                     pLocalidadInegi    CHAR(4),
                                                     pNoCiudad          SMALLINT,
                                                     pNoExt             CHAR(10),
                                                     pNoInt             CHAR(10),
                                                     pDepto             CHAR(6),
                                                     pNoCalle           INTEGER,
                                                     pNoColonia         INTEGER,
                                                     pPuntocar          CHAR(1),
                                                     pUniHabi           CHAR(1),
                                                     pManz              SMALLINT,
                                                     pPotros            SMALLINT,
                                                     pAndador           SMALLINT,
                                                     pEtapa             SMALLINT,
                                                     pLote              SMALLINT,
                                                     pEdif              SMALLINT,
                                                     pEntrada           SMALLINT,
                                                     pObserva           CHAR(80),
                                                     pUserInsert        CHAR(8),
                                                     pFechaInsert       DATE,
                                                     pNumCteBanco       CHAR(20))
RETURNING CHAR(5);
	
	DEFINE cCodRet          CHAR(40);
	DEFINE cNombre          CHAR(40);
	DEFINE cNumcte          CHAR(20);
	DEFINE iSqlErr          INTEGER;
	DEFINE cDescFijoMovil   CHAR(5);
	DEFINE cResulFijoMovil  CHAR(5);
	DEFINE iFijoMovil1      INTEGER;
	DEFINE iFijoMovil2      INTEGER;
	DEFINE iFijoMovil3      INTEGER;
	
	LET cCodRet         = '';
	LET cNombre         = '';
	LET cNumcte         = '';
	LET iSqlErr         = 0;
	LET cDescFijoMovil  = '';
	LET cResulFijoMovil = '';
	LET iFijoMovil1     = 0;
	LET iFijoMovil2     = 0;
	LET iFijoMovil3     = 0;
	
	--- SET DEBUG FILE TO "/tmp/sp_refdirecciones_cjunk.out";
	--- TRACE ON;
	
	BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet=iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET cCodRet = "000";
    LET pTipo = pTipo;

    SELECT numcte_pros 
      INTO cNumcte 
      FROM "informix".pr_cliente
     WHERE numcte_pros = pNumCte;
     
    IF cNumcte IS NULL THEN
        LET cCodRet = "104";
        RETURN cCodRet;
    END IF

    IF pFuncion = "A" THEN
        IF pTipo = '1' THEN 
            IF pTelefono1 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono1) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
                
                LET pTipoTel1 = 'P';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil1 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil1 = 1;
                ELSE
                    LET iFijoMovil1 = 0;
                END IF;
            END IF;
            
            IF pTelefono2 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono2) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
                
                LET pTipoTel2 = 'C';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil2 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil2 = 1;
                ELSE
                    LET iFijoMovil2 = 0;
                END IF;
            END IF;
            
            IF pTelefono3 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono3) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
                
                LET pTipoTel3 = 'O';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil3 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil3 = 1;
                ELSE
                    LET iFijoMovil3 = 0;
                END IF;
            END IF;
            
            UPDATE "informix".pr_refdirecciones 
               SET ( calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
                     estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
                     departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                     otros, andador, etapa, lote, edIFicio, entrada, observaciones,
                     user_insert, fecha_insert, numcte_banco, movil_fijo1, movil_fijo2, movil_fijo3 ) = 
                   ( NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''), NVL(pPais,''),NVL(pEntidad,''),NVL(pLocalidad,''), NVL(pMunicipio,''), NVL(pCodPostal,''), "",
                     NVL(pEstadoInegi,''), NVL(pMunicipioInegi,''), NVL(pLocalidadInegi,''), NVL(pNoCiudad,0), NVL(pNoExt,''), NVL(pNoInt,''), 
                     NVL(pDepto,''), NVL(pNoCalle,0), NVL(pNoColonia,0), NVL(pPuntocar,''), NVL(pUniHabi,''), NVL(pManz,0), 
                     NVL(pPotros,0), NVL(pAndador,0), NVL(pEtapa,0), NVL(pLote,0),NVL(pEdif,0),NVL(pEntrada,0),NVL(pObserva,''),
                     NVL(pUserInsert,''), pFechaInsert, NVL(pNumCteBanco,''), iFijoMovil1, iFijoMovil2, iFijoMovil3 )
                WHERE numcte_pros = pNumCte
                AND secuencia = pSecuencia;
            
        ELIF pTipo = '0' THEN 
        
            IF pTelefono1 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono1) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
                
                LET pTipoTel1 = 'P';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil1 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil1 = 1;
                ELSE
                    LET iFijoMovil1 = 0;
                END IF;
            END IF;

            IF pTelefono2 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono2) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
                
                LET pTipoTel2 = 'C';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil2 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil2 = 1;
                ELSE
                    LET iFijoMovil2 = 0;
                END IF;
            END IF;

            IF pTelefono3 <> '' THEN
                -- // VERIFICA SI ES MOVIL O FIJO   
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono3) 
                INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
                
                LET pTipoTel3 = 'O';
                
                IF cDescFijoMovil = 'FIJO' THEN
                    LET iFijoMovil3 = 0;
                ELIF cDescFijoMovil = 'MOVIL' THEN
                    LET iFijoMovil3 = 1;
                ELSE
                    LET iFijoMovil3 = 0;
                END IF;
            END IF;
            
            INSERT INTO "informix".pr_refdirecciones
                ( numcte_pros, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, 
                  municipio, cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, 
                  estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, 
                  numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, 
                  lote, edificio, entrada, observaciones, numcte_banco, user_insert, fecha_insert, 
                  movil_fijo1, status_stel1, movil_fijo2, status_stel2 , movil_fijo3, status_stel3 )
            VALUES
                ( pNumCte, pSecuencia, pTiipoDir, NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''), NVL(pPais,''), NVL(pEntidad,''), NVL(pLocalidad,''), 
                  NVL(pMunicipio,''), NVL(pCodPostal,''), "", pTipoTel1, pTelefono1, pTipoTel2, pTelefono2, pTipoTel3, pTelefono3, pExtension, 
                  NVL(pEstadoInegi,''), NVL(pMunicipioInegi,''), NVL(pLocalidadInegi,''), NVL(pNoCiudad,0), NVL(pNoExt,''), NVL(pNoInt,''), NVL(pDepto,''), 
                  NVL(pNoCalle,0), NVL(pNoColonia,0), NVL(pPuntocar,''), NVL(pUniHabi,''), NVL(pManz,0), NVL(pPotros,0), NVL(pAndador,0), NVL(pEtapa,0), 
                  NVL(pLote,0), NVL(pEdif,0), NVL(pEntrada,0), NVL(pObserva,''), NVL(pNumCteBanco,''), NVL(pUserInsert,''), CURRENT, 
                  iFijoMovil1, '', iFijoMovil2 , '', iFijoMovil3, '' );
        END IF;
        
        RETURN cCodRet;
    END IF;
    
	END;
    
END PROCEDURE;