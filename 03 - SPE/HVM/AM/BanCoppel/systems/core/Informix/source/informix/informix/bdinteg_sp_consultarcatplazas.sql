CREATE PROCEDURE "informix".sp_consultarcatplazas(pEmpresa CHAR(3), pPlaza CHAR(3))
    RETURNING   CHAR(5) AS retorno,
				CHAR(3) AS empresa,
				CHAR(3) AS plaza,
				CHAR(40) AS nombre,
				CHAR(3) AS regional;

    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet    		CHAR(5);
    DEFINE cEmpresa 	    CHAR(3);
    DEFINE cPlaza	        CHAR(3);
    DEFINE cNombre          CHAR(40);
    DEFINE cRegional        CHAR(3);

    LET cCodRet = '00000';
	LET cEmpresa = '';
	LET cPlaza = '';
	LET cNombre = '';
	LET cRegional = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					RETURN cCodRet, cEmpresa, cPlaza, cNombre, cRegional;
                END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_consultarcatplazas.out";
		--TRACE ON;

        IF pPlaza = '' THEN
            LET pPlaza = NULL;
        END IF;

        FOREACH
            SELECT DISTINCT sSuc.empresa, sSuc.plaza, sPlas.nombre, sPlas.regional
            INTO cEmpresa, cPlaza, cNombre, cRegional
            FROM si_sucursales sSuc, si_plazas sPlas
            WHERE sSuc.plaza = NVL(pPlaza, sPlas.plaza)
            AND sSuc.tpo_sucursal = 'S'
            ORDER BY sPlas.nombre

			RETURN cCodRet, cEmpresa, cPlaza, cNombre, cRegional WITH RESUME;
        END FOREACH;
    END;
END PROCEDURE;