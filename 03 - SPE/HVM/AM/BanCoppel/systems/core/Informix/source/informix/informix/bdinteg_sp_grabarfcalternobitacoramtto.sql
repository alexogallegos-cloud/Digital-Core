CREATE PROCEDURE "informix".sp_grabarfcalternobitacoramtto(pEmpresa CHAR(4),
														   pNumCte  CHAR(20),
														   pRFCAnt  CHAR(13),
														   pRFCAlt  CHAR(13),
														   pUserInsert CHAR(8),
                                                           --CFDI
                                                           pSucursal CHAR(4),
                                                           pNombre1 CHAR(26),
                                                           pNombre2 CHAR(26),
                                                           pApell_paterno CHAR(26),
                                                           pApell_materno CHAR(26),
                                                           pCod_postal CHAR(5),
                                                           pRegimen CHAR(3))
RETURNING CHAR(5)  AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE sSecuencia    SMALLINT;
DEFINE dFechaHoy     DATE;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET sSecuencia      = '0';
LET dFechaHoy 		= DATE(1);


--SET DEBUG FILE TO '/tmp/sp_grabarfcalternobitacoramtto.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '373';
			RETURN cCodRet;
	ELIF NVL(pRFCAlt,'') = '' THEN
		LET cCodRet = '373';
		RETURN cCodRet;
	ELIF NVL(pUserInsert,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
    --CFDI 4.0
	ELIF NVL(pSucursal,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
	ELIF NVL(pNombre1,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
	ELIF NVL(pApell_paterno,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
--	ELIF NVL(pCod_postal,'')=''THEN
--		LET cCodRet = '373';
--		RETURN cCodRet;	
    --End CFDI 4.0
	ELSE
		UPDATE bdinteg:"informix".si_cliente 
		SET rfc_alterno= pRFCAlt
		WHERE empresa = pEmpresa 
		AND numcte = pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '373';
			RETURN cCodRet;
		ELSE
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '373';
				RETURN cCodRet;
			ELSE
				SELECT NVL(MAX(Secuencia),'0')
				INTO sSecuencia
				FROM bdinteg:"informix".si_bitacora_rfcalterno 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte;

				LET sSecuencia = sSecuencia + 1;
				
				INSERT INTO bdinteg:"informix".si_bitacora_rfcalterno (empresa,numcte,secuencia,rfcalt_org,rfcalt_nvo,usert_insert,fecha_insert) 
				VALUES (pEmpresa,pNumCte,sSecuencia,pRFCAnt,pRFCAlt,pUserInsert,dFechaHoy);
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCodRet = '374';
					RETURN cCodRet;
                ELSE
                    --CFDI
                    IF EXISTS (select numcte from bdinteg:"informix".si_fiscal where numcte = pNumCte) THEN
                        UPDATE bdinteg:"informix".si_fiscal 
                        SET sucursal= pSucursal,
                        ejecutivo = pUserInsert,
                        apell_paterno = pApell_paterno,
                        apell_materno = pApell_materno,
                        nombre1 = pNombre1,
                        nombre2 = pNombre2,
                        cod_postal = pCod_postal,
						rfc = pRFCAlt,
                        regim_fiscal = pRegimen,
						fecha_hora = current
                        WHERE empresa = pEmpresa 
                        AND numcte = pNumCte;

                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                            LET cCodRet = '00375';
                            RETURN cCodRet;	
                        ELSE
                        	RETURN cCodRet;
                        END IF;
                    ELSE
                        INSERT INTO bdinteg:"informix".si_fiscal(empresa,numcte,sucursal,ejecutivo,apell_paterno,apell_materno,nombre1,nombre2,nom_razon_soc,cod_postal,rfc,regim_fiscal,fecha_hora,canal)
                        VALUES(pEmpresa,pNumCte,pSucursal,pUserInsert,pApell_paterno,pApell_materno,pNombre1,pNombre2,'',pCod_postal,pRFCAlt,pRegimen,current,'1');

                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                            LET cCodRet = '00376';
                            RETURN cCodRet;	
                        ELSE
                        	RETURN cCodRet;
                        END IF;
                    END IF;

                END IF;
--
			END IF;
		END IF;
	END IF;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para grabar el RFC Alterno en una bitacora, además de actualizarlo en la tabla si_cliente',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 02 Agosto 2012',
'VERSION: 20120802.01',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_buscaregimenfiscal(pRegFiscal CHAR(3))
RETURNING CHAR(5)	AS CodRetorno,
		  CHAR(3)	AS CodRegFiscal,
		  CHAR(150)	AS Descrip;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cRegimenFiscal	 CHAR(3);
DEFINE cDescripcion  CHAR(150);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cRegimenFiscal 	= '';
LET cDescripcion 	= '';

--SET DEBUG FILE TO '/tmp/sp_buscaregimenfiscal.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet,'','';
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;


        IF NVL(pRegFiscal,'') = '' THEN
                LET cCodRet = '00001';
                RETURN cCodRet,'','';
        ELSE
                SELECT c_regimenfiscal, descripcion
                INTO cRegimenFiscal, cDescripcion
                FROM bdinteg:"informix".si_regimen_fiscal
                WHERE c_regimenfiscal=pRegFiscal;

                LET cCodRet = iSqlErr;
                RETURN cCodRet, NVL(cRegimenFiscal,''), NVL(cdescripcion,'');

        END IF;

    END;
END PROCEDURE
DOCUMENT
'Descripcion : Consulta el regimen fiscal del cliente',
'Etiqueta    : CFDI 4.0',
'Modifico    : Maria de los Angeles Perez Rios',
'Fecha       : 10/11/2023',
'VERSION     : 20231110.01',
'BD          : BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_mant_cte (pSuc CHAR(4), pGte CHAR(8), pUsuario CHAR(8), pNumcte CHAR(9), pFecha DATE, pIp CHAR(16))
       RETURNING CHAR(5) as codret;

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;


LET vcodret = '00000';
LET vsqlerr = 0;

BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
	if pNumcte <>'' then
	   INSERT INTO informix.bitacora_mantenimiento(sucursal, gerente, usuario_modifica, numcte, fecha_modifica, ip_maquina) 
              VALUES(pSuc, pGte, pUsuario, pNumcte, CURRENT, pIp);

	   LET vcodret='00000';
       RETURN vcodret;
	else
	  LET vcodret='00001';
      RETURN vcodret;
	end if;
END;
END PROCEDURE;