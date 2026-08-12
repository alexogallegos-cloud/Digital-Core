CREATE PROCEDURE "informix".sc_cons_status_cta(pempresa CHAR(3),
                                                pnum_cta CHAR(20))
returning char(5), char(1), char(4);

					 
    -- Definición de variables
    define vCodRet          char(5);
    define vStatus          char(1);
	define vProducto		char(4);
    define sql_err          integer;
    
    --- Inicializa Variables de Salida
    let vCodRet   	= 	"000";
    let vStatus    	= 	"";
	let vProducto	=	"";
	
	-- ***************************************************************************        
    -- Objetivo:            Consulta el status y producto de una cuenta en especifico
    -- Creado por:			Walber Castro    
    -- Fecha: 				2012/07/04        
    -- ***************************************************************************

    BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vStatus, vProducto;
        END IF ;
    END EXCEPTION ;

    -- SET DEBUG FILE TO "/tmp/sc_cons_status_cta.out";
    -- TRACE ON;

    IF pnum_cta = "" OR pnum_cta IS NULL OR pempresa = "" OR pempresa IS NULL THEN
        let vCodRet = "001";
        RETURN vCodRet, vStatus, vProducto;
    END IF ;

    SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
    
    SELECT LIMIT 1 status_cta, producto
    INTO vStatus, vProducto
    FROM bdicheq:"informix".sc_maechq
	WHERE cuenta = pnum_cta AND empresa = pempresa;
    
    RETURN vCodRet, vStatus, vProducto;

    END
    
END PROCEDURE ;