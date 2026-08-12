CREATE PROCEDURE "informix".sp_refdirecciones_cjunk(
                                     pEmpresa           CHAR(3),
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
	
	--DEFINICION DE VARIABLES
	
	DEFINE cCodRet          CHAR(40);
	DEFINE cNombre          CHAR(40);
	DEFINE cNumcte          CHAR(20);
	DEFINE iSqlErr          INTEGER;
	DEFINE cDescFijoMovil   CHAR(5);
	DEFINE cResulFijoMovil  CHAR(5);
	DEFINE iFijoMovil1      INTEGER;
	DEFINE iFijoMovil2      INTEGER;
	DEFINE iFijoMovil3      INTEGER;
	
	--INICILIZACION DE VARIABLES
	
	LET cCodRet         = '';
	LET cNombre         = '';
	LET cNumcte         = '';
	LET iSqlErr         = 0;
	LET cDescFijoMovil  = '';
	LET cResulFijoMovil = '';
	LET iFijoMovil1     = 0;
	LET iFijoMovil2     = 0;
	LET iFijoMovil3     = 0;
	
	--SET DEBUG FILE TO "/tmp/sp_refdirecciones_cjunk.out";
	--TRACE ON;
	
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

		SELECT numcte INTO cNumcte 
		FROM "informix".si_cliente
		WHERE numcte = pNumCte;
		IF cNumcte IS NULL THEN
			LET cCodRet = "104";
			RETURN cCodRet;
		END IF

		IF pFuncion="A" THEN
		{
			SELECT nombre INTO cNombre
			FROM "informix".si_paises
			WHERE pais = pPais;
			IF cNombre IS NULL THEN
				LET cCodRet="121";
				RETURN cCodRet;
			END IF;

			SELECT nombre INTO cNombre
			FROM "informix".si_estados
			WHERE pais=pPais AND estado=pEntidad;

			IF cNombre IS NULL THEN
				LET cCodRet="122";
				RETURN cCodRet;
			END IF;

			SELECT nombre INTO cNombre
			FROM "informix".si_ciudades
			WHERE pais=pPais AND estado=pEntidad AND ciudad=pLocalidad;
			IF cNombre IS NULL THEN
				LET cCodRet="123";
				RETURN cCodRet;
			END IF;
		}
		 
			IF pTipo = '1' THEN 
				
				IF pTelefono1 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
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
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
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
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
					LET pTipoTel3 = 'O';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil3 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil3 = 1;
					ELSE
						LET iFijoMovil3 = 0;
					END IF;
				END IF;
				
				UPDATE {+INDEX ("informix".si_refdirecciones idx_si_refdirecciones)} "informix".si_refdirecciones SET
					(calle,colonia,entre_calles,
					pais,estado,ciudad,municipio,cod_postal,apart_postal,
					estado_inegi,municipio_inegi,localidad_inegi,
					numerociudad,numeroextcalle,numerointcalle,departamento,
					numerocalle,numerocolonia,puntocardinal,unidadhabitac,
					manzana,otros,andador,etapa,lote,edIFicio,entrada,observaciones,
					user_insert,fecha_insert,numcte_banco,movil_fijo1,movil_fijo2,movil_fijo3) = 
					(NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''),
					NVL(pPais,''),NVL(pEntidad,''),NVL(pLocalidad,''), NVL(pMunicipio,''), NVL(pCodPostal,''),"",
					NVL(pEstadoInegi,''),NVL(pMunicipioInegi,''),NVL(pLocalidadInegi,''),
					NVL(pNoCiudad,0),NVL(pNoExt,''),NVL(pNoInt,''),NVL(pDepto,''),
					NVL(pNoCalle,0),NVL(pNoColonia,0),NVL(pPuntocar,''),NVL(pUniHabi,''),
					NVL(pManz,0),NVL(pPotros,0),NVL(pAndador,0),NVL(pEtapa,0),NVL(pLote,0),NVL(pEdif,0),NVL(pEntrada,0),NVL(pObserva,''),
					NVL(pUserInsert,''),pFechaInsert,NVL(pNumCteBanco,''),iFijoMovil1,iFijoMovil2,iFijoMovil3)
					WHERE numcte = pNumCte
					AND secuencia = pSecuencia;
				
			ELIF pTipo = '0' THEN 
				IF pTelefono1 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
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
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
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
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
					LET pTipoTel3 = 'O';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil3 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil3 = 1;
					ELSE
						LET iFijoMovil3 = 0;
					END IF;
				END IF;

				--INSERT INTO bdinteg:"informix".si_refdirecciones
				--	(numcte,secuencia,tipo_dir,tipo_telef1,telefono1,tipo_telef2, telefono2,tipo_telef3, telefono3, extension)
				--VALUES
				--	(pNumCte,pSecuencia,pTiipoDir,pTipoTel1,pTelefono1,pTipoTel2,pTelefono2,pTipoTel3,pTelefono3,pExtension);				
				

				INSERT INTO "informix".si_refdirecciones
					(numcte, secuencia, tipo_dir, calle, colonia, entre_calles,
					pais, estado, ciudad, municipio, cod_postal, apart_postal,
					tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3,
					extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
					numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
					puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
					entrada, observaciones, numcte_banco, user_insert, fecha_insert, movil_fijo1, status_stel1, 
					movil_fijo2, status_stel2 , movil_fijo3, status_stel3 )
				VALUES
					(pNumCte, pSecuencia, pTiipoDir, NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''), 
					NVL(pPais,''), NVL(pEntidad,''), NVL(pLocalidad,''), NVL(pMunicipio,''), NVL(pCodPostal,''), "", 
					pTipoTel1, pTelefono1, pTipoTel2, pTelefono2, pTipoTel3, pTelefono3, 
					pExtension, NVL(pEstadoInegi,''), NVL(pMunicipioInegi,''), NVL(pLocalidadInegi,''), NVL(pNoCiudad,0), 
					NVL(pNoExt,''), NVL(pNoInt,''), NVL(pDepto,''), NVL(pNoCalle,0), NVL(pNoColonia,0), NVL(pPuntocar,''), 
					NVL(pUniHabi,''), NVL(pManz,0), NVL(pPotros,0), NVL(pAndador,0), NVL(pEtapa,0), NVL(pLote,0), NVL(pEdif,0), 
					NVL(pEntrada,0), NVL(pObserva,''), NVL(pNumCteBanco,''), NVL(pUserInsert,''), CURRENT, iFijoMovil1, '', iFijoMovil2 , '', iFijoMovil3, '');
				
			END IF;
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DOCUMENTACION:',
'Realizó: Martha Aguirre',
'Fecha: 31/01/2009',
'Funcionalidad: Inserta en la tabla si_refdirecciones las direcciones de las referencias de los clientes solicitantes de Crédito',
'------------------------------------------------------------------------------------------------------------------------------------',
'Realizó: Rodolfo Tortolero Varela',
'Fecha: 28/09/2011',
'Funcionalidad: Cuando el pTipo = 0, Validar los campos para que no se inserten nulos',
'------------------------------------------------------------------------------------------------------------------------------------',
'Modifico: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Se modifica UPDATE E INSERT para agregar parametros iFijoMovil1, iFijoMovil2, iFijoMovil3',
'------------------------------------------------------------------------------------------------------------------------------------',
'Modifico: Rodolfo Tortolero Varela',
'Fecha: 10/06/2013',
'BDD: bdinteg',
'Descripcion: Se agrega validación para validar de acuerdo a la descripción obtenida: ',
'             Si cDescFijoMovil es "FIJO"  - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 0 ',
'             Si cDescFijoMovil es "MOVIL" - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 1 ';

CREATE PROCEDURE "informix".sp_compara_tel(pEmpresa CHAR(3), pNumCteTitular CHAR(20), pTelefono CHAR(13), pTipoTel INTEGER, pNumCteCompara CHAR(20), pFuncion CHAR(1))
RETURNING CHAR(5);

DEFINE cCodret            CHAR(5);
DEFINE iTipo_tel          INTEGER;
DEFINE cTelefono          CHAR(13);
DEFINE cTelefonoCompara   CHAR(13);
DEFINE iTipo_telCompara   INTEGER;
DEFINE iBand              INTEGER;
DEFINE iSql_err           INTEGER;
DEFINE cSecuencia         CHAR(20);


	--SET DEBUG FILE TO '/tmp/sp_compara_tel.out';
	--TRACE ON;

LET cCodret          = '00000';
LET cTelefono        = '';
LET cTelefonoCompara = '';
LET iTipo_tel        = 0;
LET iTipo_telCompara = 0;
LET iBand            = 0;
LET iSql_err         = 0;
LET cSecuencia       = '';


BEGIN

    ON EXCEPTION SET iSql_err
        LET cCodret = CAST(iSql_err AS CHAR);    
        RETURN cCodret;
    END EXCEPTION;	
		
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteTitular,'')) <> '' AND TRIM(NVL(pFuncion,'')) <> '' THEN
	
        IF pFuncion = '1' THEN --validacion del telefono a guardar comparandolo los telefonos guardados previamente 
            IF NVL(pTipoTel,0) = 1 OR NVL(pTipoTel,0) = 2 OR NVL(pTipoTel,0) = 3 OR NVL(pTipoTel,0) = 4 THEN
		        FOREACH
                    SELECT telefono, tipo_tel 
                    INTO cTelefono, iTipo_tel
                    FROM "informix".si_telefonos_actual 
                    WHERE empresa = pEmpresa 
                    AND numcte  = pNumCteTitular 
                    AND status_tel = 'A'  
	 
                    IF TRIM(pTelefono) = TRIM(cTelefono) AND iTipo_tel <> pTipoTel THEN 
                        LET iBand = 1;
                    END IF;
	
                END FOREACH;
			ELSE
			    LET iBand = 3;
			END IF;
        ELIF pFuncion = '2' THEN --elimina telefono de la si_telefonos_actual y cansela los de la si_telefonos   
	        IF NVL(pTipoTel,0) = 1 OR NVL(pTipoTel,0) = 2 OR NVL(pTipoTel,0) = 3 OR NVL(pTipoTel,0) = 4 THEN
			
			    IF EXISTS(SELECT telefono FROM "informix".si_telefonos WHERE empresa = pEmpresa AND numcte  = pNumCteTitular 
                AND status_tel = 'A' AND tipo_tel = pTipoTel) THEN
                    UPDATE "informix".si_telefonos SET status_tel = 'C' WHERE empresa = pEmpresa AND numcte = pNumCteTitular AND tipo_tel = pTipoTel;
				END IF;
			    
				IF EXISTS(SELECT telefono FROM "informix".si_telefonos_actual WHERE empresa = pEmpresa AND numcte  = pNumCteTitular 
                AND status_tel = 'A' AND tipo_tel = pTipoTel) THEN
                    DELETE FROM "informix".si_telefonos_actual WHERE empresa = pEmpresa AND numcte = pNumCteTitular AND tipo_tel = pTipoTel;
			    END IF;
				
			ELSE
			    LET iBand = 3;	
		    END IF;
        ELIF pFuncion = '3' THEN -- verifica si el cliente tiene un telefono de trabajo
	
            IF NOT EXISTS(SELECT telefono FROM "informix".si_telefonos_actual WHERE empresa = pEmpresa AND numcte  = pNumCteTitular 
            AND status_tel = 'A' AND tipo_tel = 3) THEN
                LET iBand = 1;
		    END IF;
		ELIF pFuncion = '4' THEN  --se uso para compara el numero de una referencia con los numeros del cliente titular
			IF  TRIM(NVL(pNumCteCompara,'')) <> '' THEN 
			
			    FOREACH
			        SELECT telefono
                    INTO cTelefonoCompara
                    FROM "informix".si_telefonos_actual 
                    WHERE empresa = pEmpresa 
                    AND numcte  = pNumCteCompara 
                    AND status_tel = 'A'  
					
			        IF TRIM(pTelefono) = TRIM(cTelefonoCompara) THEN
				        LET iBand = 1;
					END IF;
				    
                END FOREACH; 
			ELSE
			    LET iBand = 3;
            END IF;
		END IF;	
	ELSE
	
		IF pFuncion = '4' THEN  --se uso para compara el numero de una referencia con los numeros del cliente titular
	
            IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteCompara,'')) <> '' THEN 	
                
                FOREACH
			        SELECT telefono
                    INTO cTelefonoCompara
                    FROM "informix".si_telefonos_actual 
                    WHERE empresa = pEmpresa 
                    AND numcte  = pNumCteCompara 
                    AND status_tel = 'A'  
					
			        IF TRIM(pTelefono) = TRIM(cTelefonoCompara) THEN
				        LET iBand = 1;
					END IF;
				    
                END FOREACH; 
			ELSE
			    LET iBand = 3;
            END IF;
		ELSE
			LET iBand = 2;
		END IF;
	    
    END IF;
	
    LET cCodret = '000' || pFuncion || CAST(iBand AS CHAR);
	
RETURN cCodret;	
	
END;

END PROCEDURE
DOCUMENT
'AUTOR         : Felipe Urias',
'DESCRIPCION   : Este sp cuenta con cuatro funcionalidades para la validacion y manejo de los numeros telefonicos de los clientes',
'BASE DE DATOS : Bdinteg ',
'FECHA         : 19/04/2013';

CREATE PROCEDURE "informix".sp_alteratipodatofustelefonos()
RETURNING CHAR(5) AS CodRet;

    -- // Definicion de Variables
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE cNumCte      CHAR(20);
    DEFINE cTelefono    CHAR(13);
    DEFINE siTipoTel    SMALLINT;
    DEFINE siSecuencia  SMALLINT;
    DEFINE cFechaHora   CHAR(23);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcontador    INTEGER;

    -- // Inicializacion de Variables
    LET iSqlErr     = 0;
    LET iIsamErr    = 0;
    LET cDescErr    = '';
    LET cCodRet     = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET vabierto    = '0';
    LET cNumCte     = '';
    LET cTelefono   = '';
    LET siTipoTel   = 0;
    LET siSecuencia = 0;
    LET cFechaHora  = '';
    LET vcomienza   = -1;
    LET vcontador   = 0;

    --SET DEBUG FILE TO '/tmp/sp_alteratipodatofustelefonos.out';
    --TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO '/tmp/sp_alteratipodatofustelefonos.err';
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // MODIFICACION EN si_telefonos
    ALTER TABLE "informix".si_fustelefonos ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;

    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_fustelefonos
         --WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;

        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);

        UPDATE "informix".si_fustelefonos 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;
    
    /*LET vcomienza = -1;
    LET vcontador = 0;
    
    -- // MODIFICACION EN si_telefonos_actual
    ALTER TABLE "informix".si_telefonos_actual ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;
    
    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_telefonos_actual
         WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;
        
        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);
        
        UPDATE "informix".si_telefonos_actual 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;*/
    
    ALTER TABLE "informix".si_fustelefonos DROP fecha_hora;
    RENAME COLUMN "informix".si_fustelefonos.fecha_completa TO fecha_hora;
    
    --ALTER TABLE "informix".si_telefonos_actual DROP fecha_hora;
    --RENAME COLUMN "informix".si_telefonos_actual.fecha_completa TO fecha_hora;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cambia el tipo de dato al campo fecha_hora de la tabla si_telefonos',
'AUTOR: Iris Arias Zazueta',
'FECHA: 07-01-2013',
'VERSION: 1.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_reporte_huellas_aut()
	RETURNING
		CHAR(6) 	AS 	COD_RET,
		CHAR(80) 	AS MENSAJE_RET;
		
		
	--DECLARACION DE VARIABLES
	DEFINE cCodret 		 	CHAR(6);
	DEFINE iSqlErr        	INTEGER;
	DEFINE cMensaje       	CHAR(80);
	DEFINE cNumCte1			CHAR(20);
	DEFINE cApellPat1		CHAR(26);
	DEFINE cApellMat1		CHAR(26);
	DEFINE cNom1			CHAR(26);
	DEFINE cNom2			CHAR(26);
	DEFINE cRFC1			CHAR(13);
	DEFINE dtFechaNac1		DATE;
	DEFINE cNumCte2			VARCHAR(9);
	DEFINE cApellPat2		CHAR(26);
	DEFINE cApellMat2		CHAR(26);
	DEFINE cNom1_2			CHAR(26);
	DEFINE cNom2_2			CHAR(26);
	DEFINE cRFC2			CHAR(13);
	DEFINE dtFechaNac2		DATE;
	DEFINE cTicket			CHAR(20);
	DEFINE dtFechaCons		DATE;
	DEFINE dPorce			DECIMAL;
	DEFINE dtFechaInsert	DATE;
	DEFINE iDia         	INTEGER;
	
	
	DEFINE dFechaIni	DATE;
	DEFINE dFechaFin	DATE;
	DEFINE dFechaAux	DATE;
	
	
	

	--INICIALIZACION DE VARIABLES
	LET cCodret			= '00000';
	LET iSqlErr 		= 0;
	LET cMensaje		= 'PROCESO EXITOSO';
	LET cNumCte1		= '';
	LET cApellPat1		= '';
	LET cApellMat1		= '';
	LET cNom1			= '';
	LET cNom2			= '';
	LET cRFC1			= '';
	LET dtFechaNac1		= DATE(1);
	LET cNumCte2		= '';
	LET cApellPat2		= '';
	LET cApellMat2		= '';
	LET cNom1_2			= '';
	LET cNom2_2			= '';
	LET cRFC2			= '';
	LET dtFechaNac2		= DATE(1);
	LET cTicket			= '';
	LET dtFechaCons		= DATE(1);
	LET dPorce			= 0.0;
	LET dtFechaInsert	= DATE(1);


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET cMensaje = "ERROR NO CONTROLADO";
			RETURN cCodret, cMensaje;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT day(fecha_hoy)  INTO  iDia FROM bdinteg:si_fechas;
	
	IF (iDia) <= 15 THEN --Reporte del 16 al 30
		SELECT   date( month(fecha) || '/16/' || year(fecha) ),fecha    INTO dFechaIni,dFechaFin
		FROM TABLE (multiset(
			select date(pri_dia_mes - interval(1) DAY TO DAY) as fecha  from bdinteg:si_fechas));
			
	ELIF (iDia) > 15 THEN --Reporte del 01 al 15
		SELECT pri_dia_mes, date( month(pri_dia_mes) || '/15/' || year(pri_dia_mes) )   INTO dFechaIni,dFechaFin FROM bdinteg:si_fechas;
		
	END IF;	
	
	--SET DEBUG FILE TO "/informix/ArmandoM/sp_huella_linea.out";
	--TRACE ON;

		SELECT DISTINCT LPAD(TRIM(cliente::CHAR(9)), 9,'0') numcte2, a.ticket, a.fecha, cte1.apell_paterno apell_pat_2, cte1.apell_materno apell_mat_2, cte1.nombre1 nom1_2, cte1.nombre2 nom2_2, cte1.rfc rfc_2, pf.fecha_nac fecha_nac2
		FROM si_huella_linea_resultado a,  si_cliente cte1, si_ctepf pf
		WHERE fecha  between dFechaIni and dFechaFin    -- parametro de entrada
		AND num_mensaje = '602' AND cliente <> '0' AND a.empresa = '5' AND pf.fecha_nac <= '01-01-1995'
		AND LPAD(TRIM(cliente::CHAR(9)), 9,'0') = cte1.numcte AND LPAD(TRIM(cliente::CHAR(9)), 9,'0') = pf.numcte

		INTO temp clientes_bcpl_dupl_2 WITH NO LOG;

		SET ISOLATION TO DIRTY READ;
		SELECT a.numcte numcte1, a.fecha_consulta, a.ticket, cte1.apell_paterno apell_pat_1, cte1.apell_materno apell_mat_1, cte1.nombre1 nom1_1, cte1.nombre2 nom2_1, cte1.rfc rfc_1, pf.fecha_nac fecha_nac1
		FROM si_huella_linea a, si_cliente cte1, si_ctepf pf
		WHERE (fecha_consulta between dFechaIni and dFechaFin) AND ticket IN
		(SELECT ticket FROM clientes_bcpl_dupl_2) AND a.numcte = cte1.numcte  AND a.numcte = pf.numcte
		
		INTO temp clientes_bcpl_dupl_1 WITH NO LOG;

		INSERT INTO si_clientes_huellas_dupl(numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1, rfc_1, fecha_nac1, numcte2, apell_pat_2, apell_mat_2, nom1_2, nom2_2, rfc_2, fecha_nac2, ticket, fecha_consulta, fecha_insert)
			SELECT a.numcte1, a.apell_pat_1, a.apell_mat_1, a.nom1_1, a.nom2_1, a.rfc_1, a.fecha_nac1, b.numcte2, b.apell_pat_2, b.apell_mat_2, b.nom1_2, b.nom2_2, b.rfc_2, b.fecha_nac2, a.ticket, a.fecha_consulta, CURRENT AS fecha_insert
			FROM clientes_bcpl_dupl_1 a, clientes_bcpl_dupl_2 b
			WHERE a.ticket = b.ticket 
			AND b.fecha = a.fecha_consulta;
			
			
		EXECUTE PROCEDURE "informix".sp_compara_nombres()
		INTO cCodret;
	
		RETURN cCodret, cMensaje;
	END;	
END PROCEDURE;