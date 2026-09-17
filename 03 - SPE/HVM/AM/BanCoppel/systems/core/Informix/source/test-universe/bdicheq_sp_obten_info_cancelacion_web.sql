CREATE PROCEDURE "informix".sp_obten_info_cancelacion_web(pEmpresa CHAR(3),pNumCta CHAR(20),pNumCte CHAR(20))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(40) AS cBancoOrdenante,
			CHAR(18) AS cCuentaCLABEOrdenante,
			CHAR(40) AS cBancoReceptor,
			CHAR(18) AS cCuentaCLAVEReceptor,
			CHAR(30) AS cFolioSolicitud;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 				CHAR(5);
DEFINE  cBancoOrdenante			CHAR(40);
DEFINE  cCuentaCLABEOrdenante	CHAR(18);
DEFINE  cBancoReceptor			CHAR(40);
DEFINE  cCuentaCLAVEReceptor	CHAR(18);
DEFINE  cFolioSolicitud			CHAR(30);
DEFINE  iSqlErr					INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 				= '00000';
LET cBancoOrdenante			= '';
LET cCuentaCLABEOrdenante	= '';
LET cBancoReceptor			= '';
LET cCuentaCLAVEReceptor	= '';
LET cFolioSolicitud			= '';
LET iSqlErr					= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_obten_info_cancelacion.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCta,'') <> '' AND NVL(pNumCte,'') <> '' THEN

	SELECT cta_ordenante, bco_ordenante, cta_receptora, bco_receptor, folio_solicitud
		INTO cCuentaCLABEOrdenante,cBancoOrdenante,cCuentaCLAVEReceptor,cBancoReceptor,cFolioSolicitud
		FROM bdicheq:"informix".sc_portacec_solicitud
		WHERE empresa = pEmpresa AND num_cte = pNumCte AND cta_ordenante = pNumCta
            and folio_solicitud = (
            SELECT max(folio_solicitud)
               FROM bdicheq:"informix".sc_portacec_solicitud
               WHERE empresa = pEmpresa 
                 AND num_cte = pNumCte
                 AND cta_ordenante = pNumCta
                  AND clave_sentido in ('1', '0')
                   And estatus_portabilidad = '1'
            );

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01289';
		ELSE
			SELECT descripcion INTO cBancoOrdenante FROM bdinteg:"informix".si_bancos
			WHERE cvecesif = cBancoOrdenante;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '01289';
			ELSE
				SELECT descripcion INTO cBancoReceptor FROM bdinteg:"informix".si_bancos
				WHERE cvecesif = cBancoReceptor;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '01289';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01288';
	END IF
	RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Datos',
'001289 - No existe el Cliente',
'001288 - Parametros incompletos',
'DESCRIPCION: obtener la informaciÃ³n de la orden de cancelaciÃ³n de transferencia',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo GÃ³mez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_marcacancelacionadn_web(pEmpresa char(3), pCuenta char(20))

--DATOS A REGRESAR---
RETURNING
char(5)  as Cod_Ret	--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         char(5);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00000";
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Actualiza bandera para identificar que cliente solicito su portabilidad a otro banco
    update  bdisolic:ss_adn_solicitudcuenta set flag_porta=1
    where empresa= pEmpresa and num_solicitud=pCuenta;
    
    RETURN Vcod_Ret; 

END PROCEDURE;