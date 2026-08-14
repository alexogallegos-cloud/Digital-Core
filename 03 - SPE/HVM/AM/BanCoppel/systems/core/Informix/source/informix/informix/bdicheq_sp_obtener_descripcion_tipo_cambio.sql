CREATE PROCEDURE "informix".sp_obtener_descripcion_tipo_cambio(pEmpresa CHAR(3), pNumTarjeta CHAR(16),pFolioSucursal CHAR(16), pFechaAlta DATE, pMonto MONEY)
RETURNING CHAR(5) AS CodRet, 
CHAR(180) AS vreferencia;
		  
-- DECLARACION DE VARIABLES
DEFINE vreferencia         		CHAR(180);
DEFINE vcodret             		CHAR(5);
DEFINE vdivisa325				CHAR(3);
DEFINE vmonto_divisa325			CHAR(13);
DEFINE vnomcomercio325			CHAR(30);
DEFINE vabrev_divisa			CHAR(3);
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);

-- SE INICIALIZAN VARIABLES
LET vcodret           = '000';
LET vreferencia      = '';

BEGIN
	-- CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET vcodret  = SQL_ERR;
        LET vreferencia  = ERROR_INFO;
		RETURN vcodret, vreferencia;
    END EXCEPTION;
	
	IF ( pEmpresa IS NULL OR pNumTarjeta IS NULL OR pFolioSucursal IS NULL OR pFechaAlta IS NULL OR pMonto IS NULL) THEN
        LET vcodret = '001'; 
        RETURN vcodret, vreferencia;
    END IF;

	-- BUSQUEDA DE MOVIMIENTO EN td_movimientos_conciliacion
	SELECT FIRST 1 divisa325, monto_divisa325, nomcomercio325  
	INTO vdivisa325, vmonto_divisa325, vnomcomercio325
	FROM bditarjeta:td_movimientos_conciliacion 
	WHERE folio_mov = pFolioSucursal
	AND numtarjeta = pNumTarjeta
	AND archivo_origen in ('VID','MCD', 'VND')
	AND fechacarga::DATE = pFechaAlta;
	
	IF  vdivisa325 IS NULL OR vmonto_divisa325 IS NULL OR vnomcomercio325 IS NULL THEN
		LET vcodret = '002';
		LET vreferencia = 'INFORMACION NO ENCONTRADA EN td_movimientos_conciliacion';
		RETURN vcodret, vreferencia;
	END IF
	
	IF  vdivisa325 = '484' THEN
		LET vcodret = '003';
		LET vreferencia = 'MOVIMIENTO NACIONAL';
		RETURN vcodret, vreferencia;
	END IF
	
	-- BUSQUEDA DIVISA
	SELECT FIRST 1 abrev_divisa
	INTO vabrev_divisa
	FROM intercard:cat_paisdivisa
	WHERE cod_divisa = vdivisa325;
	
	IF vabrev_divisa IS NULL OR vabrev_divisa = '' THEN
		LET vcodret = '004';
		LET vreferencia = 'DIVISA NO ENCONTRADA';
		RETURN vcodret, vreferencia;
	END IF
	
	-- DESCRIPCION MOVIMIENTO INTERNACIONAL
	/**********************************************************************
            DESCRIPCION:
            Total de la compra 
            + moneda extranjera (abreviatura) 
            + 'T.C.' 
            + tipo de cambio del dÃÂ­a de la transacciÃÂ³n 
    ***********************************************************************/
	LET vreferencia = TRIM(vnomcomercio325) ||' $'||ROUND((vmonto_divisa325/100),2)||' '||TRIM(vabrev_divisa)||' T.C. $'||ROUND((pMonto/(vmonto_divisa325/100)),2);

	RETURN vcodret, vreferencia;
END;
END PROCEDURE;