CREATE PROCEDURE "informix".sp_valida_respuesta_ws_dish(pNumCategoria CHAR   (2),  pNumConvenio CHAR (3), pId_Sucursal CHAR (4), 
		pFolioSucursal CHAR (16),  pFecha_Pago  DATE,     pNumTrama    INTEGER)
RETURNING CHAR(5) as cCodRet, CHAR(40) as cCodigoRespuesta;
      
-- Declaracion de variables 
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodigoRespuesta CHAR(40);
	DEFINE vCampoTres CHAR(40);	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodigoRespuesta	= '';
	LET vCampoTres = '';
					
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_valida_respuesta_ws_dish.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF  NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL(pFecha_Pago, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; 
		RETURN cCodRet, NVL(cCodigoRespuesta, '');
	END IF;

	SELECT TRIM(campo3) INTO vCampoTres FROM bdisac: "informix".sac_msw_respuesta
	WHERE numcategoria= pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = pNumTrama;
		  
    SELECT codigoRetorno INTO cCodigoRespuesta FROM bdisac: "informix".sac_dish_cat_respuestaws where codigoRespuesta = vCampoTres AND trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
	ELSE 
		LET cCodRet = '00000';
	END IF;
	
	RETURN cCodRet, NVL(cCodigoRespuesta, '');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 90020599 - Mario Enriquez Gallegos',
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_dish_cat_respuestaws',
'FECHA : 08-10-2019',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_pagos_activos_msw(pOrigen CHAR(4))
	RETURNING
	CHAR(5)	 AS codigo,	
	CHAR(30) AS mensaje,	
	CHAR(2)	 AS categoria,	
	CHAR(3)	 AS convenio,	
	CHAR(20) AS descripcion,	
	CHAR(8)	 AS fecha;

	DEFINE iSqlErr       INTEGER;
    DEFINE iIsamErr      INTEGER;
    DEFINE cInfoErr      CHAR(100);
	DEFINE cCodRet       CHAR(5);
	DEFINE cMensaje		 CHAR(30);
	DEFINE cCategoria	 CHAR(2);
	DEFINE cConvenio	 CHAR(3);
	DEFINE cDescripcion	 CHAR(20);
	DEFINE dFecha		 DATE;
	DEFINE cFechaFormat	 CHAR(8);
	DEFINE cMensaje1     CHAR(20);
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_pagos_activos_msw_epg.out';
	--TRACE ON;

	LET cCodRet      = "00000";
	LET cMensaje     = "Exitoso";
	LET cCategoria   = '';
	LET cConvenio    = '';
	LET cDescripcion = '';
	LET dFecha       = '';
	LET cFechaFormat = '';
	LET cMensaje1 = '';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_pagos_activos_msw_epg");
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, cFechaFormat;
            END IF;
        END EXCEPTION;
		
		LET cMensaje1 = pOrigen;
		
		IF pOrigen = "" THEN
            LET cCodRet = "00100";
			LET cMensaje = "Error";
            RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;

		IF pOrigen = 'CPL' OR pOrigen = 'cpl' THEN
			FOREACH
				SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
				INTO cCategoria, cConvenio, cDescripcion, dFecha
				FROM bdisac:"informix".sac_servicios_cpl a, bdisac:"informix".sac_convenios b, bdisac:sac_controlconvenios C
				WHERE (a.numcategoria = b.numcategoria AND a.numconvenio = b.numconvenio)--nmr
                  and (a.numcategoria = c.numcategoria AND a.numconvenio = c.numconvenio)--nmr
                  AND c.status_cpl = 'A'--nmr
				ORDER BY a.numcategoria, a.numconvenio
				
				LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;
				
				RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
				WITH RESUME;
			END FOREACH;

            ELIF pOrigen = 'BCPL' OR pOrigen = 'bcpl' THEN
                FOREACH
                    SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
                    INTO cCategoria, cConvenio, cDescripcion, dFecha
                    FROM bdisac:"informix".sac_controlconvenios a, bdisac:"informix".sac_convenios b
                    WHERE a.estatus = 'A'
                    AND a.numcategoria = b.numcategoria
                    AND a.numconvenio = b.numconvenio
                    AND a.status_cpl = 'A'

                    ORDER BY a.numcategoria, a.numconvenio

                    LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;

                    RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
                    WITH RESUME;
                END FOREACH;
			ELSE
                LET cCodRet = "00101";
                LET cMensaje = "Origen desconocido";
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;	
		
	END;
END PROCEDURE;