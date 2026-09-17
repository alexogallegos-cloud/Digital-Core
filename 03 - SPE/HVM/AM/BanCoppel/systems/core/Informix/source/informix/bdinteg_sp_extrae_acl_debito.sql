CREATE PROCEDURE "informix".sp_extrae_acl_debito (p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE)

    RETURNING CHAR(11) AS folioCSUAC, DATE AS fechaAclaracion, DATE AS fechaMovimiento, CHAR(4) AS transaccion, money(16,2) AS montoAclaracion;

	--definicion de variables--	    
    	DEFINE resultado_folioCSUAC 		CHAR(11);	
  	DEFINE resultado_fechaAclaracion 	DATE;
   	DEFINE resultado_fechaMovimiento 	DATE;
    	DEFINE resultado_transaccion 		CHAR(4);
	DEFINE resultado_montoAclaracion	money(16,2);
    	DEFINE iSqlErr                      	INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_folioCSUAC  = '';	
    	LET resultado_fechaAclaracion = '';
    	LET resultado_fechaMovimiento = '';
    	LET resultado_transaccion = '';
	LET resultado_montoAclaracion = '';

    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_folioCSUAC = '';	
                    LET resultado_fechaAclaracion =	'';
                    LET resultado_fechaMovimiento =	'';
                    LET resultado_transaccion = '';
                    LET resultado_montoAclaracion = '';
                    RETURN resultado_folioCSUAC, resultado_fechaAclaracion, resultado_fechaMovimiento, resultado_transaccion, resultado_montoAclaracion;
                END IF;
        END EXCEPTION;
        

        FOREACH
            SELECT bdiaclaracion:acl_aclaracion.folio_csuac, bdiaclaracion:acl_aclaracion.fechacaptura, bdiaclaracion:acl_movimiento.fechahora,
                 bdiaclaracion:acl_tipo_movimiento.transaccion, bdiaclaracion:acl_aclaracion.importereclamado
            INTO resultado_folioCSUAC, resultado_fechaAclaracion, resultado_fechaMovimiento, resultado_transaccion, resultado_montoAclaracion
                FROM (bdiaclaracion:acl_aclaracion INNER JOIN
                    (bdiaclaracion:acl_movimiento INNER JOIN bdiaclaracion:acl_tipo_movimiento
                   ON bdiaclaracion:acl_tipo_movimiento.pky_tipo_movimiento = bdiaclaracion:acl_movimiento.fky_tipo_movimiento)
                        ON bdiaclaracion:acl_movimiento.fky_aclaracion = bdiaclaracion:acl_aclaracion.pky_aclaracion) INNER JOIN bdiaclaracion:acl_producto
                            ON bdiaclaracion:acl_producto.pky_producto = bdiaclaracion:acl_aclaracion.fky_producto
                            WHERE bdiaclaracion:acl_aclaracion.fky_estatus_aclaracion = 2 
                            AND bdiaclaracion:acl_aclaracion.fechacaptura BETWEEN p_sFechaInicial AND p_sFechaFinal
                            AND bdiaclaracion:acl_producto.numero_cuenta = p_sNumeroCuenta
                            RETURN resultado_folioCSUAC, resultado_fechaAclaracion, resultado_fechaMovimiento, resultado_transaccion, resultado_montoAclaracion WITH RESUME;
        END FOREACH;
	END
END PROCEDURE;