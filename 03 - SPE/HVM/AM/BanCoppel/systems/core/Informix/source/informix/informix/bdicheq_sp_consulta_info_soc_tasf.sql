CREATE PROCEDURE "informix".sp_consulta_info_soc_tasf(p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza       SMALLINT;
DEFINE ven_transacc        SMALLINT;
DEFINE v_c_vcontador       INTEGER;

DEFINE vsqlerr              INTEGER;
DEFINE vcodret              CHAR(5);
			  
DEFINE   v_aniomes      	CHAR(6); 
DEFINE   v_num_serial   	CHAR(20); 
DEFINE   v_folio_suc    	CHAR(16);
DEFINE   v_sucursal     	CHAR(4);
DEFINE   v_usuario      	CHAR(8);
DEFINE   v_fech_alt     	DATE;
DEFINE   v_fech_val     	DATE;
DEFINE   v_fech_hor     	DATETIME HOUR to FRACTION(3);
DEFINE   v_transacc     	CHAR(4);
DEFINE   v_suc_cuen     	CHAR(4);
DEFINE   v_producto     	CHAR(4);
DEFINE   v_empresa      	CHAR(3);
DEFINE   v_cuenta       	CHAR(20);
DEFINE   v_causa_dev    	CHAR(2);
DEFINE   v_num_cheq     	INTEGER;
DEFINE   v_monto_tot    	MONEY;
DEFINE   v_firme        	MONEY;
DEFINE   v_en_sbc       	MONEY;
DEFINE   v_remesas      	MONEY;
DEFINE   v_dias_ret     	SMALLINT;
DEFINE   v_cancelad     	CHAR(1);
DEFINE   v_edo_cta      	CHAR(1);
DEFINE   v_sdo_cuenta   	MONEY;
DEFINE   v_transacc_suc 	CHAR(4);
DEFINE   v_referencia   	CHAR(40);
DEFINE   v_tasa_aplicada	DECIMAL(9,6);
DEFINE   v_num_tarjeta  	CHAR(16);
DEFINE   v_usuautoriza  	CHAR(8);
DEFINE   v_referencia_23    CHAR(23);
DEFINE   v_descripcion	    CHAR(50);
DEFINE   v_cuenta_cargo	    CHAR(60);
DEFINE   v_cuenta_abono	    CHAR(60);


LET vsqlerr      = 0; 
LET vcodret      = "000";

LET v_c_vcomienza        = -1;
LET ven_transacc         = 0;
LET v_c_vcontador        = 0;


BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/desk_info_op.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     --SET DEBUG FILE TO '/informix/rsv/descarga/err.txt';
	 --TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  	  		
      FOREACH WITH HOLD
	        -- Realiza la consulta principal de informacion 
	        SELECT a.fech_alt,    a.aniomes,     a.num_serial,    a.folio_suc,   a.sucursal,     a.usuario,                        a.fech_val,       a.fech_hor,
                   a.transacc,    a.suc_cuen,    a.producto,      a.empresa,     a.cuenta,       a.causa_dev,    a.num_cheq,       a.monto_tot,      a.firme,
                   a.en_sbc,      a.remesas,     a.dias_ret,      a.cancelad,    a.edo_cta,      a.sdo_cuenta,   a.transacc_suc,   a.referencia,     a.tasa_aplicada, 
				   a.num_tarjeta, a.usuautoriza, a.referencia_23, a.descripcion, a.cuenta_cargo, a.cuenta_abono
			  INTO v_fech_alt,    v_aniomes,     v_num_serial,    v_folio_suc,   v_sucursal,     v_usuario,                        v_fech_val,       v_fech_hor,
                   v_transacc,    v_suc_cuen,    v_producto,      v_empresa,     v_cuenta,       v_causa_dev,    v_num_cheq,       v_monto_tot,      v_firme,
                   v_en_sbc,      v_remesas,     v_dias_ret,      v_cancelad,    v_edo_cta,      v_sdo_cuenta,   v_transacc_suc,   v_referencia,     v_tasa_aplicada, 
				   v_num_tarjeta, v_usuautoriza, v_referencia_23, v_descripcion, v_cuenta_cargo, v_cuenta_abono
			  FROM tmp_mov a
			  			  
			   -- Abre la transaccion 
			   IF (v_c_vcomienza = -1) THEN
                   LET v_c_vcomienza = 0;
                   LET ven_transacc = 1;
                   BEGIN WORK;
               END IF;

              --Inserta regristro 
             INSERT INTO sc_movs2402  VALUES( v_fech_alt,    v_aniomes,     v_num_serial,    v_folio_suc,   v_sucursal,     v_usuario,      v_fech_alt,       v_fech_val,       v_fech_hor,
                                              v_transacc,    v_suc_cuen,    v_producto,      v_empresa,     v_cuenta,       v_causa_dev,    v_num_cheq,       v_monto_tot,      v_firme,
                                              v_en_sbc,      v_remesas,     v_dias_ret,      v_cancelad,    v_edo_cta,      v_sdo_cuenta,   v_transacc_suc,   v_referencia,     v_tasa_aplicada, 
				                              v_num_tarjeta, v_usuautoriza, v_referencia_23, v_descripcion, v_cuenta_cargo, v_cuenta_abono, ' ',               ' ');  

			   LET v_c_vcontador = v_c_vcontador + 1;
			   --Realiza commit cada 1000 registros 
			     IF (v_c_vcontador >= 1000) THEN
                    LET v_c_vcontador = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;  
				
	   END FOREACH;
	   --Si la transaccion esta abierta realiza el commit
	    IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
				  
RETURN  vcodret;
END; 
END PROCEDURE;