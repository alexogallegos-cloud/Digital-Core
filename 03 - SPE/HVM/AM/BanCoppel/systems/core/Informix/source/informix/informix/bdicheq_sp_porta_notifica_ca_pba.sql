CREATE PROCEDURE "informix".sp_porta_notifica_ca_pba(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE v_c_vcontador    INTEGER;
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_num_cliente    CHAR(20);
	DEFINE v_valida_noti    INT;
    DEFINE v_fecha_can      CHAR(8);
    DEFINE vSp_CodRet       CHAR(5);
    DEFINE v_fecha_noti     CHAR(8);
	  
    LET v_c_vcomienza       = -1;	
    LET ven_transacc        = 0;
    LET v_c_vcontador       = 0;
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
	LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000";
	LET v_num_cliente       = '';
	LET v_valida_noti       = 0;
	LET vSp_CodRet          = '00000';
	
	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/notifica_ca.err";
	 	    TRACE ON;
			LET vcodret     = vsqlerr;
            LET vErrorInfo  = cErrorInfo;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
		
    ---SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/notifica_ca.txt';
	---TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
		   

	FOREACH WITH HOLD
	        SELECT num_cliente  , fecha_cancela
			INTO   v_num_cliente, v_fecha_can 
			FROM   bdicheq:sc_porta_cancel_auto
			
            -- ABRE LA TRANSACCION 
	        IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
		  	
            LET  v_fecha_noti = SUBSTR(v_fecha_can,7,2)||SUBSTR(v_fecha_can,5,2)||SUBSTR(v_fecha_can,0,4);
				
		    SELECT COUNT(*)
            INTO   v_valida_noti
			FROM   bdinteg:si_correos           
            WHERE  tipo_correo = 1 
            AND    status_correo = 'A'
            AND    numcte = v_num_cliente;
		  	
            -- NOTIFICACION POR CORREO 			
			IF  v_valida_noti > 0 THEN 
			    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
                '1',
                'PORTACEC',
                'CAN_AUT_EM',
                v_num_cliente,
                '',
                '',
                '2',
                v_fecha_noti,
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                1,
                0,
                0,
                0,
                0,
                '',
                '')
			    INTO vSp_CodRet; 
				
			ELSE  
			    -- NOTIFICACION POR SMS
			    SELECT COUNT(*)
				INTO   v_valida_noti
				FROM   bdinteg:si_telefonos_actual 
                WHERE  numcte = v_num_cliente
				AND    tipo_tel = '2'
				AND    cofetel = 'V';
			    
				IF v_valida_noti > 0 THEN 
				   EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                   ('2',
                   'PORTACECSM',
                   'CAN_AUT_SM',
                   v_num_cliente,
                   '',
                   '',
                   '2',
                   v_fecha_noti,
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   1,
                   0,
                   0,
                   0,
                   0,
                   '',
                   '')
				   INTO vSp_CodRet;
			    END IF; 
			END IF; 
			
			LET  v_c_vcontador = v_c_vcontador + 1;
			IF  (v_c_vcontador >= 1000) THEN
                LET v_c_vcontador = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
    END FOREACH;
   
	--SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 
    RETURN  vcodret;
END; 
END PROCEDURE;