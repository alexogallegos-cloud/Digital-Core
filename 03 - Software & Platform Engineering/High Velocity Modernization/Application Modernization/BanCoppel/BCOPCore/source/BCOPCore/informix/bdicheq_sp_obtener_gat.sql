CREATE PROCEDURE "informix".sp_obtener_gat(vProducto CHAR(4), eCuenta CHAR(20), vFechaFin DATE, eEmpresa CHAR(3))
RETURNING CHAR(5) AS CodRet, 
DECIMAL(9,6) AS vgat_nominal,
DECIMAL(9,6) AS vgat_real;

-- DECLARACION DE VARIABLES
DEFINE vcodret             		CHAR(5);
DEFINE vgat_nominal             DECIMAL(9,6);
DEFINE vgat_real                DECIMAL(9,6);
DEFINE vMaxTasa                 DECIMAL(9,6);
DEFINE vTasaGat                 DECIMAL(9,6);
DEFINE vMaxFecha                DATE;
DEFINE vExiste                  INTEGER;
DEFINE vMaxMes          		INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);

-- SE INICIALIZAN VARIABLES
LET vcodret           = '000';
LET vMaxMes           = 0;
LET vgat_nominal      = 0;
LET vgat_real         = 0;
LET vExiste           = 0;

BEGIN
	-- CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET vcodret  = SQL_ERR;
		RETURN vcodret, vgat_nominal, vgat_real;
    END EXCEPTION;

    --SET DEBUG FILE TO '/sp_obtener_gat.out';
    --TRACE ON;

    IF vProducto = '1100' THEN 
        SELECT valor_tasa
            INTO vTasaGat
            FROM sc_tasa_variable
            WHERE empresa = eEmpresa
            AND cuenta = eCuenta
            AND inicio_periodo < vFechaFin
            AND tipo_tasa = 'P';
           
        SELECT FIRST 1 gat_nominal, gat_real
            INTO vgat_nominal, vgat_real
            FROM sc_gat
            WHERE producto = vProducto
            AND tasa = vTasaGat;
    ELSE
        SELECT COUNT(*)
            INTO vExiste
            FROM sc_gat
            WHERE producto = vProducto;

        IF vExiste > 0 THEN
            SELECT MAX(tasa)
                INTO vMaxTasa
                FROM sc_gat WHERE producto = vProducto;

            SELECT MAX(fecha_publicacion)
                INTO vMaxFecha
                FROM sc_gat 
                WHERE producto = vProducto 
                AND tasa = vMaxTasa;

            SELECT FIRST 1 gat_nominal, gat_real 
                INTO vgat_nominal, vgat_real
                FROM sc_gat 
                WHERE producto = vProducto 
                AND tasa = vMaxTasa
                AND fecha_publicacion = vMaxFecha;
        ELSE
            LET vcodret = '001'; --No se encontro producto en sc_gat
        END IF;
    END IF;
        
    



	RETURN vcodret, vgat_nominal, vgat_real;
END;
END PROCEDURE;