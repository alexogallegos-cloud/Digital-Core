CREATE PROCEDURE "informix".sp_consultarcatzonas(cEmpresa CHAR(3), cPlaza CHAR(3))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se obtiene el catálogo de zonas
--Realizó: Nancy Sevilla Camacho
--Fecha: 24/05/2012                    
--------------------------------------------------------------------

    --DATOS A REGRESAR---	
    RETURNING   CHAR(5) AS retorno,
				CHAR(3) AS empresa,
				CHAR(3) AS plaza,
				CHAR(40) AS nombre,
				CHAR(3) AS regional;

	--DEFINICION DE VARIABLES--					
    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet    		CHAR(5);
    ---------------------------	
    DEFINE cEmpresa 	    CHAR(3);
    DEFINE cPlaza	        CHAR(3);
    DEFINE cNombre          CHAR(40);
    DEFINE cRegional        CHAR(3);

	--INICIALIZACION DE VARIABLES--	
    LET cCodRet = '00000';
	LET cEmpresa = '';
	LET cPlaza = '';
	LET cNombre = '';
	LET cRegional = '';
	
	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultarcatzonas.out";
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;		

	-- INICIO DEL PROCEDIMIENTO		
    BEGIN
	-- MANEJADOR DE ERRORES		
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					RETURN cCodRet, cEmpresa, cPlaza, cNombre, cRegional;
                END IF;
        END EXCEPTION;

        IF cPlaza = '' THEN
            LET cPlaza = NULL;
        END IF;

        FOREACH

            SELECT DISTINCT sSuc.empresa, sSuc.plaza, sPlas.nombre, sPlas.regional
              INTO cEmpresa, cPlaza, cNombre, cRegional
              FROM bdinteg:"informix".si_sucursales sSuc, bdinteg:"informix".si_plazas sPlas
             WHERE sSuc.empresa='001' and sSuc.plaza = NVL(cPlaza, sPlas.plaza) 
               AND sSuc.tpo_sucursal = 'S'
             ORDER BY sSuc.plaza

			RETURN cCodRet, 
				   cEmpresa, 
				   cPlaza, 
				   cNombre, 
				   cRegional 
			  WITH RESUME;
			
		END FOREACH;
		
    END;
	
END PROCEDURE;