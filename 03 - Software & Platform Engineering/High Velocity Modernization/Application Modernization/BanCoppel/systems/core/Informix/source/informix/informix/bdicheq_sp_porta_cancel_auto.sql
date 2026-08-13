CREATE PROCEDURE "informix".sp_porta_cancel_auto(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE v_c_vcontador    INTEGER;
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_cta_orden      CHAR(20);
	DEFINE v_cta_ord_lim    CHAR(20);
	DEFINE v_fecha_hoy      DATE;
	DEFINE v_fech_est_porta CHAR(8);
	DEFINE v_fech_sol_porta CHAR(8);
	DEFINE v_cadena         CHAR(30);
	DEFINE v_clave_tipo     CHAR(4);
	DEFINE v_ind_cancela    CHAR(1);
	DEFINE v_libre          CHAR(8);
	DEFINE v_num_cliente    CHAR(20);
	DEFINE v_porta_cuenta   CHAR(20);
	DEFINE v_fecha_can_fin  DATE;

	  
    LET v_c_vcomienza       = -1;	
    LET ven_transacc        = 0;
    LET v_c_vcontador       = 0;
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
	LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000";
	LET v_cta_ord_lim       = ' ';
	LET v_fecha_hoy         = ' ';
	LET v_fech_est_porta    = ' ';
    LET v_fech_sol_porta    = ' ';
	LET v_cadena            = ' ';
	LET v_clave_tipo        = ' ';
	LET v_ind_cancela       = 'C';
	LET v_libre             = '00000000'; 
	
	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/cance_auto.err";
	 	    TRACE ON;
			LET vcodret     = vsqlerr;
            LET vErrorInfo  = cErrorInfo;
            LET v_cta_ord_lim  = v_cta_ord_lim;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
    --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/cance_auto.txt';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
	       
	SELECT fecha_hoy
	INTO   v_fecha_hoy
	FROM   bdicheq:sc_fechas;
	
	SELECT clave_tipo
	INTO   v_clave_tipo
	FROM   bdicheq:sc_portacec_tipo_operacion
	WHERE  clave_tipo = 'CA';
			
	FOREACH WITH HOLD
	        SELECT porta_cuenta_clabe, num_cliente  , porta_cuenta ,  folio_cancela , fecha_cancela
			INTO   v_cta_orden       , v_num_cliente, v_porta_cuenta, v_cadena, v_fech_sol_porta
			FROM   bdicheq:sc_porta_cancel_auto
			
            -- Abre la transaccion 
	        IF (v_c_vcomienza = -1) THEN
               LET v_c_vcomienza = 0;
               LET ven_transacc = 1;
			   COMMIT WORK; 
               BEGIN WORK;
            END IF;
		  
		    LET v_cta_ord_lim = TRIM(v_cta_orden);
			 			 
            UPDATE bdicheq:sc_portacec_solicitud 
            SET    estatus_portabilidad         = '4',
                   fecha_estatus_portabilidad   =  v_fech_sol_porta,
                   clave_origen                 = '1',
                   clave_sentido		        = '0',
                   fecha_solca_portabilidad     =  v_fech_sol_porta,
				   folio_cancelacion            =  v_cadena,
				   suc_cancela                  = 'OTBN.',
				   user_cancela                 = 'informix'
            WHERE  cta_ordenante                =  v_cta_ord_lim      
			AND    estatus_portabilidad         = '1'
            AND    bco_ordenante                ='40137'        
            AND    clave_origen                 IN ('1','2','3')
            AND    clave_sentido                = '1'            
            AND    cod_operacion                IN ('20','21');   

						
			IF    (dbinfo('sqlca.sqlerrd2') > 0 ) THEN
			       
				   --ARMA LA CADENA PARA LA FECHA DE CANCELACION
				   LET v_fecha_can_fin = SUBSTR(v_fech_sol_porta,5,2)||SUBSTR(v_fech_sol_porta,7,2)||SUBSTR(v_fech_sol_porta,0,4);
						
			       UPDATE bdicheq:sc_portabilidadnomina 
			       SET    estatus           = '02',        
			              user_cancel       = 'informix',
			       	      fecha_cancel      =  v_fecha_can_fin,
			       	      origen_cancel     = 'OFI',
			       	      sucursal_cancel   = 'OTBN'
		           WHERE  cliente           = v_num_cliente
			       AND    cuenta_abono      = v_porta_cuenta
			       AND    estatus           = '01';	
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
	--INICIALIZA LA TABLA DE DETALLE DE PORTABILIDADES A CANCELAR 		 
	TRUNCATE TABLE bdicheq:sc_porta_cancel_auto;
    BEGIN WORK; 
    RETURN  vcodret;
END; 
END PROCEDURE;