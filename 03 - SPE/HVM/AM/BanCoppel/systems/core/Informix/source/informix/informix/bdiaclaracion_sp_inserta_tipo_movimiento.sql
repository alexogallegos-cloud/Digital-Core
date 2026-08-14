CREATE PROCEDURE "informix".sp_inserta_tipo_movimiento(pTransaccionNoProcede CHAR(4),pIdOrigenEvento INTEGER,pIdTransaccion INTEGER,pIdTipoProducto INTEGER,pDescripcion CHAR(255))

	RETURNING	  CHAR (4) AS respuestaEjecucion;  
	--definicion de variables--	    
	DEFINE respuestaEjecucion		CHAR(4);
    DEFINE secuenciaMax               INTEGER;
    DEFINE iSqlErr INTEGER;
	
     -- Inicializacao de las variables.
	
	LET respuestaEjecucion = '0000';

   	
	SET ISOLATION TO DIRTY READ;			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET respuestaEjecucion = '0001';  
                    RETURN respuestaEjecucion;
                END IF;
        END EXCEPTION;

        SELECT LIMIT 1 "informix".TIPO_MOVIMIENTO_SEQ.nextval 
        INTO  secuenciaMax
        FROM bdiaclaracion:"informix".acl_tipo_movimiento;

        INSERT INTO bdiaclaracion:"informix".acl_tipo_movimiento (pky_tipo_movimiento,activo,descripcion,trans_no_procede,fky_origen_evento,fky_tipo_transaccion,fky_tipo_producto)
        VALUES (secuenciaMax,1,pDescripcion,pTransaccionNoProcede,pIdOrigenEvento,pIdTransaccion,pIdTipoProducto);

        RETURN  respuestaEjecucion;
		
    END
END PROCEDURE;