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