CREATE PROCEDURE "informix".sp_ins_solic_const (pempresa char(3) ) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
		
	DEFINE v_ejerc_ant 			CHAR(4);
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_ejercicio          CHAR(4);
	DEFINE v_vig          		SMALLINT;


    --SET DEBUG FILE TO  "sp_ins_solic_const.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_ejerc_ant = '';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_ejercicio = '';
	LET v_vig = 0;

	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		
		SELECT YEAR(fecha_hoy - 1 UNITS YEAR)
		  INTO v_ejerc_ant --Para buscar las constancias generadas del ejercicio inmediato anterior
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
		
		SELECT TRIM(valor)
			INTO v_vig
			FROM "informix".edelec_param WHERE cod_param = 8;		
 		
		FOREACH WITH HOLD -- Insertar solicitudes de constancias
			SELECT a.numcte,a.cuenta,c.ejercicio
			  INTO v_numcte, v_cuenta, v_ejercicio
			  FROM bdiedoelec:edelec_constancia a, bdicheq:sc_maechq b, bdicheq:sc_retenisr c
			 WHERE a.numcte = b.num_cte
			   AND a.status_serv_elec = 'A'
			   AND b.cuenta = a.cuenta
			   AND c.empresa = pempresa
               AND c.cuenta = b.cuenta
               AND c.ejercicio = v_ejerc_ant 
			   
			IF NOT EXISTS (SELECT cuenta FROM bdiedoelec:edelec_solic_const WHERE cuenta = v_cuenta AND ejercicio = v_ejercicio) THEN
			
			
				INSERT INTO "informix".edelec_solic_const (empresa,numcte,cuenta,ejercicio,fecha_recepcion,fecha_vigencia)
										VALUES (pempresa,v_numcte,v_cuenta,v_ejercicio, TODAY, TODAY + v_vig);
			
				INSERT INTO "informix".edelec_log_solic_const (empresa,numcte,cuenta,ejercicio,status_envio_edocta,fecha_modificacion)
										VALUES (pempresa, v_numcte, v_cuenta, v_ejercicio, 'SE', TODAY);
			END IF;
		CONTINUE FOREACH;
		END FOREACH;	
		
		RETURN v_sCodRet;    

    END
END PROCEDURE;