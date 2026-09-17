CREATE PROCEDURE "informix".sp_consulta_tipo_movimiento(p_FolioSuc CHAR(20),p_NumTarjeta CHAR(20),p_OrigenEvento INTEGER)

    RETURNING CHAR(1) AS resultado_origen,VARCHAR(2) AS modo_entrada;
    DEFINE resultado_origen 	CHAR(1);
    DEFINE iSqlErr      		INTEGER;
	DEFINE nombre_origen 		CHAR(50);
    DEFINE imodo_entrada        VARCHAR(2);
	
    LET resultado_origen 		= '';
	LET nombre_origen 			= '';
   	LET imodo_entrada           = '';
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_origen = '';
				RETURN  iSqlErr,'Er'; --RETURNING
			END IF;
        END EXCEPTION;

     -- SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;

     -- SET DEBUG FILE TO "/RESPALDOSNEW/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;
 	SELECT nombre 
        INTO nombre_origen 
		FROM "informix".acl_origen_evento 
        WHERE pky_origen_evento = p_OrigenEvento;
	
    IF nombre_origen = 'POS' or nombre_origen = 'ATMS' Then
            
            SELECT intercard:movimiento.esnacional, intercard:movimiento.metodocaptura
            INTO resultado_origen, imodo_entrada
            FROM intercard:movimiento
            WHERE intercard:movimiento.secuenciaextendida=p_FolioSuc
            AND intercard:movimiento.numtarjeta=p_NumTarjeta;
             
                IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    SELECT intercard:movimientohistorico.esnacional, intercard:movimientohistorico.metodocaptura
                    INTO resultado_origen, imodo_entrada
                    FROM intercard:movimientohistorico
                    WHERE intercard:movimientohistorico.secuenciaextendida=p_FolioSuc
                    AND intercard:movimientohistorico.numtarjeta=p_NumTarjeta;
                ELSE
                    RETURN resultado_origen,imodo_entrada; -- RETURNING
                END IF; 


             --RETURN resultado_origen,imodo_entrada; -- RETURNING


                 IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    LET resultado_origen = 'N';
                 END IF;

                 IF ( imodo_entrada IS NULL OR imodo_entrada='') THEN
                    LET imodo_entrada = 'NN';
                 END IF;
	ELSE
		LET resultado_origen = 'V';
        LET imodo_entrada= 'NN';
	END IF;
    
    RETURN resultado_origen,imodo_entrada;

    END
END PROCEDURE;