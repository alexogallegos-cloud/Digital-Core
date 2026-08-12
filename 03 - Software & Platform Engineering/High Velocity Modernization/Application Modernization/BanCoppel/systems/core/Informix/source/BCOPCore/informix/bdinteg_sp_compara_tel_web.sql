CREATE PROCEDURE "informix".sp_compara_tel_web(pEmpresa CHAR(3), pNumCteTitular CHAR(20), pTelefono CHAR(13), pTipoTel INTEGER, pNumCteCompara CHAR(20), pFuncion CHAR(1))
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
	
    LET cCodret = '00000' || pFuncion || CAST(iBand AS CHAR);
	
RETURN cCodret;	
	
END;

END PROCEDURE
DOCUMENT
'AUTOR         : Felipe Urias',
'DESCRIPCION   : Este sp cuenta con cuatro funcionalidades para la validacion y manejo de los numeros telefonicos de los clientes',
'BASE DE DATOS : Bdinteg ',
'FECHA         : 19/04/2013';

CREATE PROCEDURE "informix".sp_consctemttorfcalterno_web(pEmpresa CHAR(4),
													     pNumCte  CHAR(20),
													     pTarjeta CHAR(20),
													     pCuenta  CHAR(20))
RETURNING CHAR(5)   AS CodRetorno,
		  CHAR(20)  AS NumCte,
		  CHAR(26)  AS Nombre1,
		  CHAR(26)  AS Nombre2,
		  CHAR(26)  AS ApPaterno,
		  CHAR(26)  AS ApMaterno,
		  CHAR(13)  AS RFC,
		  CHAR(13)  AS RFC_Alterno,
		  INTEGER   AS iNumeric,
		  CHAR(100) AS Descripcion,
		  DATE      AS Fecha_Nac,
		  SMALLINT  AS Dependientes;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cNumCte		 CHAR(20);
DEFINE cNombre1		 CHAR(26);
DEFINE cNombre2 	 CHAR(26);
DEFINE cApPaterno 	 CHAR(26);
DEFINE cApMaterno 	 CHAR(26);
DEFINE cRFC 		 CHAR(13);
DEFINE cRFCAlt 		 CHAR(13);
DEFINE cCuenta       CHAR(20);
DEFINE cBin          CHAR(6);
DEFINE cCredDeb      CHAR(1);
DEFINE cStatus       CHAR(2);
DEFINE cDescripcion  CHAR(100);
DEFINE dFechNacm     DATE;
DEFINE sDependientes SMALLINT;
DEFINE iNumeric      INTEGER;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cNombre1 		= '';
LET cNombre2 		= '';
LET cApPaterno 		= '';
LET cApMaterno 		= '';
LET cRFC 			= '';
LET cRFCAlt 		= '';
LET cCuenta         = '';
LET cBin         	= '';
LET cCredDeb     	= '';
LET cStatus         = '';
LET cDescripcion 	= '';
LET dFechNacm 		= DATE(1);
LET sDependientes   = '0';
LET iNumeric 		= 0;


--SET DEBUG FILE TO '/tmp/sp_consctemttorfcalterno.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','','','','','','','';
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '00372';
			RETURN cCodRet,'','','','','','','','','','','';
	ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
		LET cCodRet = '00372';
		RETURN cCodRet,'','','','','','','','','','','';		
	ELSE
		IF pCuenta <> '' THEN
			SELECT num_cte,cuenta 
			INTO cNumCte,cCuenta 
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pCuenta
			AND status_cta  = '1';
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito,status_cred 
				INTO cNumCte,cCuenta,cStatus 
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					SELECT numcte,num_credito,status_cred 
					INTO cNumCte,cCuenta,cStatus 
					FROM bdicred:"informix".sd_maecredcrd 
					WHERE num_credito = pCuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00346';
						RETURN cCodRet,'','','','','','','','','','','';
					ELSE
						IF cStatus IN ('CV', 'FF', 'FC') THEN
							LET cCodRet = '00346';
							RETURN cCodRet,'','','','','','','','','','','';
						END IF;
					END IF;
				ELSE
					IF cStatus IN ('CV', 'FF', 'FC') THEN
						LET cCodRet = '00346';
						RETURN cCodRet,'','','','','','','','','','','';
					END IF;
				END IF;
			END IF;
			
		ELIF pTarjeta <> '' THEN
			LET cBin = SUBSTR(pTarjeta,0,6);
			
			SELECT creditodebito 
			INTO cCredDeb
			FROM intercard:"informix".bines 
			WHERE bin = cBin;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00347';
				RETURN cCodRet,'','','','','','','','','','','';
			ELSE
				IF cCredDeb = "C" THEN
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCodRet = '00347';
						RETURN cCodRet,'','','','','','','','','','','';
					END IF;
				ELIF  cCredDeb = "D" THEN
					SELECT numcte,cuenta
					INTO cNumCte,cCuenta 
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE empresa = "001"
					AND num_tarjeta = pTarjeta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCodRet = '00347';
						RETURN cCodRet,'','','','','','','','','','','';
					END IF;
				END IF;
			END IF;
		ELIF pNumCte <> '' THEN
			LET cNumCte = pNumCte;
		END IF;
			SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,a.rfc,a.rfc_alterno,a.numeric2,b.descripcioncorta,c.fecha_nac,c.dependientes
			INTO cNumCte, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cRFCAlt,iNumeric,cDescripcion,dFechNacm,sDependientes
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_catcterelacionado b, bdinteg:"informix".si_ctepf c
			WHERE a.numcte = cNumCte
			AND b.clavetipo = a.numeric2
			AND c.numcte = a.numcte;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00345';
				RETURN cCodRet,'','','','','','','','','','','';
			END IF;
			RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,NVL(cRFCAlt,''),iNumeric,cDescripcion,dFechNacm,sDependientes;	
	END IF;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la Consulta del RFC Alterno en Sucursal ',
'AUTOR : MartÃ­n Eduardo Miranda',
'FECHA : 02 Agosto 2012',
'VERSION: 20120802.01',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consultacta_club_web(pEmpresa CHAR(3), pCliente CHAR(20), pPoliza CHAR(20),pCteCoppel CHAR(20))
RETURNING CHAR(5) as CodRet, CHAR(1) AS Domiciliada, CHAR(20) AS NumCta, CHAR(20) AS NumTarjeta, CHAR(4) AS SucOperante, CHAR(8) AS NumPromotor, CHAR(16) AS FolioOperacion, CHAR(1) AS Respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cDomiciliada CHAR(1);
DEFINE cNumCta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cSucOperante CHAR(4);
DEFINE cNumPromotor CHAR(8);
DEFINE cFolioOperacion CHAR(16);
DEFINE cTipoPago CHAR(1);
DEFINE dFecha DATETIME YEAR TO SECOND;
DEFINE cRespuesta CHAR(1);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "00000";
LET iSqlErr = 0;
LET cDomiciliada = '';
LET cNumCta='';
LET cNumTarjeta='';
LET cSucOperante='';
LET cNumPromotor='';
LET cFolioOperacion='';
LET cRespuesta='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacta_club.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pPoliza,''))='' THEN
			LET cCodret	= "00001";
		ELSE
			SELECT  MAX(fecha)
			INTO dFecha
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa;
			
			SELECT respuesta
			INTO cRespuesta
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa
			AND fecha=dFecha;
		
			SELECT suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,foliooperacion
			INTO cSucOperante,cNumPromotor,cTipoPago,cNumTarjeta,cNumCta,cFolioOperacion
			FROM  "informix".si_club_proteccion
			WHERE empresa= pEmpresa AND numcte=pCliente;
			--AND num_poliza= pPoliza;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "00002";
			ELSE
				IF TRIM(NVL(cTipoPago,''))='1' THEN
					LET cDomiciliada = 'S';
				ELSE 
					LET cDomiciliada = 'N';
					LET cNumCta='';
					LET cNumTarjeta='';
				END IF
			END IF
		END IF
		
RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
END
END PROCEDURE

DOCUMENT
"DescripciÃÂ³n: Retorna la cuenta domiciliada para el Club de protecciÃÂ³n.",
"Autor : Leslie RendÃÂ³n",
"FECHA : 07/07/2014",
"BD    : bdinteg",

'DescripciÃÂ³n: Se comenta filtro num_poliza = pPoliza para que no se realice la comparacion en la tabla si_club_proteccion',
'Autor : Bryan Limon',
'FECHA : 16/05/2017',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_consultapaises_web(pNumeroPagina INTEGER, pCantidadRegistros INTEGER)

--ENTRADAS:
--pNumeroPagina			= Número de página del segmento, iniciando en 0, 1, 2 hasta que se terminen los datos de la tablas.
--pCantidadRegistros	= Número de registros por segmentos, si es 0 tomará 16 como defecto.

--RETORNOS:
--000000 = Éxitoso.
--000001 = No hay registros para esos parámetros.
--000002 = Parámetros Negativos.

--DATOS DE RETORNO
RETURNING
CHAR(05) AS codRet,
CHAR(03) AS idPais,
CHAR(30) AS nombrePais;
		
--DEFINICIÓN DE VARIABLES
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(05);
DEFINE cIdPais		CHAR(03);
DEFINE cNombrePais	CHAR(30);
DEFINE iNumeroPag	INTEGER;
DEFINE iCantidadRe	INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr		= 0;
LET cCodRet		= '00000';
LET cIdPais		= '';
LET cNombrePais	= '';
LET iNumeroPag	= 0;
LET iCantidadRe	= 0;
	
	--SET DEBUG FILE TO "";
	--TRACE ON;
	
-- INICIO DEL PROCEDIMIENTO
	BEGIN
		-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdPais,cNombrePais;
			END IF;
		END EXCEPTION;	
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR PARÁMETROS NULOS O NEGATIVOS
		IF NVL(pNumeroPagina, 0) < 0 OR NVL(pCantidadRegistros, 0) < 0 THEN
			LET cCodRet = '00002';
			LET cNombrePais = 'Parámetros en cero o negativos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
		
		--ESTABLECER VALORES POR DEFECTO
		IF pCantidadRegistros = 0 THEN
			LET iCantidadRe = 16;
		ELSE
			LET iCantidadRe = pCantidadRegistros;
		END IF
		LET iNumeroPag = pNumeroPagina * iCantidadRe;
	
		FOREACH
			--CONSULTAR LA TABLA si_paisnacion
			SELECT SKIP iNumeroPag FIRST iCantidadRe id_pais, nombre 
			INTO cIdPais, cNombrePais
			FROM bdinteg:"informix".si_paisnacion
			ORDER BY nombre

			RETURN cCodRet, cIdPais, cNombrePais WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			LET cNombrePais = 'Sin Datos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
			
	END
END PROCEDURE
DOCUMENT
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - José Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripción:	Creación de SP que consulta el catálogo de paises por segmentos",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694";

CREATE PROCEDURE "informix".sp_consultareferencias_web (pEmpresa char(3), pNumeroCliente char(20))
        returning char(5), integer, integer;

--Creado: Rodolfo Tortolero Varela
--Fecha: 05/03/2009
--Consulta las secuencias maximas del cliente en la tabla si_refclientes

--Se Definen Variables
DEFINE iSqlErr INTEGER;
DEFINE vcodret char(5);
DEFINE iSecuencia1 integer;
DEFINE iSecuencia2 integer;

--Se Inicializan Variables
LET vcodret = "00000";
LET iSecuencia1  = 0;
LET iSecuencia2  = 0;

    BEGIN
            ON EXCEPTION
                    SET iSqlErr
                    IF iSqlErr <> 0 THEN
                            LET vCodRet = iSqlErr;
                            RETURN  vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            END EXCEPTION;

            SELECT  MAX(secuencia)  INTO iSecuencia1
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente;

            SELECT  MAX(secuencia)  INTO iSecuencia2
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente AND secuencia < iSecuencia1;

            IF iSecuencia1 <> 0 OR iSecuencia1 IS NOT NULL THEN
                    IF iSecuencia2 <> 0  OR iSecuencia2 IS NOT NULL THEN
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    ELSE
                            LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            ELSE
                    LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                    RETURN vcodret, iSecuencia1, iSecuencia2;
            END IF;
    END;
END PROCEDURE;