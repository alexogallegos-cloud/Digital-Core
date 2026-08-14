CREATE PROCEDURE "informix".sp_muestra_detalle_pestana_transfer(p_sNumeroCuentatransfer CHAR(20), p_sFolioSuc CHAR(20))

  RETURNING	  DATE AS fechaTransac,  DATETIME HOUR to FRACTION(3) AS horaIniTransac,  DATETIME HOUR to FRACTION(3) AS horaFinTransac, CHAR(20) AS secuencia, CHAR(20) AS bancoOrigen,  CHAR(30) AS numeroOrigen,  CHAR(20) AS bancoDestino,    CHAR(30) AS numeroIdDestino,  CHAR(20) AS estatusTransac,  money(16,2) AS saldoOrigen,  money(16,2) AS saldoDestino, CHAR(20) AS motivo,  CHAR(30) AS referencia,  money(16,2) AS comision,  money(16,2) AS iva,  CHAR(30) AS idReverso,  CHAR(20) AS tipoTransac,  CHAR(30) AS transacMps,   CHAR(30) AS idDevolucion, CHAR(5) AS consecutivo,
CHAR(5) AS transacc, CHAR(5) AS tpoidorigen, money(16,2) AS monto, CHAR(5) AS tpoiddestino, CHAR(5) AS metodoacceso, CHAR(5) AS tpoacceso,
CHAR(20) AS idtransac, CHAR(20) AS idreceptor, CHAR(5) AS integridad;  

	--definicion de variables--	    
	
	
	DEFINE resultado_fechaTransac		DATE;
	DEFINE resultado_horaIniTransac	    DATETIME HOUR to FRACTION(3);
	DEFINE resultado_horaFinTransac	    DATETIME HOUR to FRACTION(3);
	DEFINE resultado_secuencia	        CHAR(20);
    	DEFINE resultado_bancoOrigen	    CHAR(20);
	DEFINE resultado_numeroOrigen	    CHAR(30);
    	DEFINE resultado_bancoDestino	    CHAR(20);
	DEFINE resultado_numeroIdDestino    CHAR(30);
	DEFINE resultado_estatusTransac     CHAR(20);
	DEFINE resultado_saldoOrigen       money(16,2);
	DEFINE resultado_saldoDestino      money(16,2);
	DEFINE resultado_motivo		        CHAR(20);
	DEFINE resultado_referencia    	    CHAR(30);
	DEFINE resultado_comision	      money(16,2);
	DEFINE resultado_iva              money(16,2);
	DEFINE resultado_idReverso          CHAR(30);
	DEFINE resultado_tipoTransac        CHAR(20);
	DEFINE resultado_transacMps         CHAR(30);
	DEFINE resultado_iddevolucion       CHAR(30);
	DEFINE resultado_consecutivo        CHAR(5);
	DEFINE resultado_transacc           CHAR(5);
	DEFINE resultado_tpoidorigen      CHAR(5);
	DEFINE resultado_monto              money(16,2);
	DEFINE resultado_tpoiddestino     CHAR(5);
	DEFINE resultado_metodoacceso      CHAR(5);
	DEFINE resultado_tpoacceso         CHAR(5);
	DEFINE resultado_idtransac         CHAR(20);
	DEFINE resultado_idreceptor        CHAR(20);
	DEFINE resultado_integridad         CHAR(5);
	

   
	DEFINE iSqlErr                      	INTEGER;
	
     -- Inicializacao de las variables.
	
	
	
	LET resultado_fechaTransac	     = '';
	LET resultado_horaIniTransac	   = TO_DATE("00:00","%H:%M");
	LET resultado_horaFinTransac	   = TO_DATE("00:00","%H:%M");
	LET resultado_secuencia	         = '';
    LET resultado_bancoOrigen	     = '';
   	LET resultado_numeroOrigen	     = '';
	LET resultado_bancoDestino	     = '';
	LET resultado_numeroIdDestino    = '';
	LET resultado_estatusTransac     = '';
	LET resultado_saldoOrigen        = '';
	LET resultado_saldoDestino       = '';
	LET resultado_motivo		     = '';
	LET resultado_referencia    	 = '';
	LET resultado_comision	         = '';
	LET resultado_iva    	         = '';
	LET resultado_idReverso          = '';
	LET resultado_tipoTransac        = '';
	LET resultado_transacMps         = '';
	LET resultado_iddevolucion       = '';
	LET resultado_consecutivo        = '';
	LET resultado_transacc           = '';
	LET resultado_tpoidorigen      = '';
	LET resultado_monto              = '';
	LET resultado_tpoiddestino     = '';
	LET resultado_metodoacceso      = '';
	LET resultado_tpoacceso         = '';
	LET resultado_idtransac         = '';
	LET resultado_idreceptor        = '';
	LET resultado_integridad         = '';
	



	

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
             
	
	LET resultado_fechaTransac	    = '';
	LET resultado_horaIniTransac	 =   TO_DATE("00:00","%H:%M");
	LET resultado_horaFinTransac	 =  TO_DATE("00:00","%H:%M");
	LET resultado_secuencia	         = '';
    LET resultado_bancoOrigen	     = '';
   	LET resultado_numeroOrigen	     = '';
	LET resultado_bancoDestino	     = '';
	LET resultado_numeroIdDestino    = '';
	LET resultado_estatusTransac     = '';
	LET resultado_saldoOrigen        = '';
	LET resultado_saldoDestino       = '';
	LET resultado_motivo		     = '';
	LET resultado_referencia    	 = '';
	LET resultado_comision	         = '';
	LET resultado_iva    	         = '';
	LET resultado_idReverso          = '';
	LET resultado_tipoTransac        = '';
	LET resultado_transacMps         = '';
	LET resultado_iddevolucion       = '';
    LET resultado_consecutivo        = '';
	LET resultado_transacc           = '';
	LET resultado_tpoidorigen      = '';
	LET resultado_monto              = '';
	LET resultado_tpoiddestino     = '';
	LET resultado_metodoacceso      = '';
	LET resultado_tpoacceso         = '';
	LET resultado_idtransac         = '';
	LET resultado_idreceptor        = '';
	LET resultado_integridad         = '';
       
 RETURN  resultado_fechaTransac, resultado_horaIniTransac, resultado_horaFinTransac, resultado_secuencia, resultado_bancoOrigen,  resultado_numeroOrigen, resultado_bancoDestino,   resultado_numeroIdDestino, resultado_estatusTransac, resultado_saldoOrigen, resultado_saldoDestino, resultado_motivo, resultado_referencia, resultado_comision, resultado_iva,  resultado_idReverso, resultado_tipoTransac,  resultado_transacMps, resultado_iddevolucion, resultado_consecutivo, resultado_transacc, resultado_tpoidorigen, resultado_monto, resultado_tpoiddestino, resultado_metodoacceso, resultado_tpoacceso, resultado_idtransac, resultado_idreceptor, resultado_integridad;
            
    END IF;
        END EXCEPTION;




	
	       SELECT   bditransfer:tf_all_transaction.fech_alt, bditransfer:tf_all_transaction.fech_hor_ini, bditransfer:tf_all_transaction.fech_hor_fin, bditransfer:tf_all_transaction.secuencia, bdinteg:si_bancos.descripcion, bditransfer:tf_all_transaction.id_cuenta_origen,
					bditransfer:tf_all_transaction.id_banco_destino, bditransfer:tf_all_transaction.id_cuenta_destino, bditransfer:tf_all_transaction.estatus_transac, bditransfer:tf_all_transaction.sdo_cuenta_origen,  
						bditransfer:tf_all_transaction.sdo_cuenta_destino, bditransfer:tf_all_transaction.motivo, bditransfer:tf_all_transaction.referencia, bditransfer:tf_all_transaction.comision, bditransfer:tf_all_transaction.iva, bditransfer:tf_all_transaction.id_reverso, bditransfer:tf_all_transaction.naturaleza, bditransfer:tf_all_transaction.id_transacc_mps,  bditransfer:tf_all_transaction.id_devolucion, bditransfer:tf_all_transaction.consecutivo, bditransfer:tf_all_transaction.transacc, bditransfer:tf_all_transaction.tpo_id_origen,
                         bditransfer:tf_all_transaction.monto, bditransfer:tf_all_transaction.tpo_id_destino, bditransfer:tf_all_transaction.metodo_acceso, bditransfer:tf_all_transaction.tpo_acceso,bditransfer:tf_all_transaction.id_transac,
                         bditransfer:tf_all_transaction.id_receptor, bditransfer:tf_all_transaction.integridad 

				INTO  resultado_fechaTransac, resultado_horaIniTransac, resultado_horaFinTransac, resultado_secuencia, resultado_bancoOrigen,  resultado_numeroOrigen, resultado_bancoDestino,  resultado_numeroIdDestino,  resultado_estatusTransac, resultado_saldoOrigen, resultado_saldoDestino, resultado_motivo, resultado_referencia, resultado_comision, resultado_iva,  resultado_idReverso, resultado_tipoTransac,  resultado_transacMps, resultado_iddevolucion, resultado_consecutivo, resultado_transacc, resultado_tpoidorigen, resultado_monto, resultado_tpoiddestino, resultado_metodoacceso, resultado_tpoacceso, resultado_idtransac, resultado_idreceptor, resultado_integridad

			FROM bditransfer:tf_all_transaction, bdinteg:si_bancos
              WHERE bditransfer:tf_all_transaction.id_transacc_mps = p_sFolioSuc
                AND bditransfer:tf_all_transaction.cuenta = p_sNumeroCuentatransfer
                AND bditransfer:tf_all_transaction.id_banco_origen=bdinteg:si_bancos.banco;
			
 IF ( resultado_fechaTransac IS NULL ) THEN

	
	LET resultado_fechaTransac	     = '';
	LET resultado_horaIniTransac	   = TO_DATE("00:00","%H:%M");
	LET resultado_horaFinTransac	   = TO_DATE("00:00","%H:%M");
	LET resultado_secuencia	         = '';
    LET resultado_bancoOrigen	     = '';
   	LET resultado_numeroOrigen	     = '';
	LET resultado_bancoDestino	     = '';
	LET resultado_numeroIdDestino    = '';
	LET resultado_estatusTransac     = '';
	LET resultado_saldoOrigen        = '';
	LET resultado_saldoDestino       = '';
	LET resultado_motivo		     = '';
	LET resultado_referencia    	 = '';
	LET resultado_comision	         = '';
	LET resultado_iva    	         = '';
	LET resultado_idReverso          = '';
	LET resultado_tipoTransac        = '';
	LET resultado_transacMps         = '';
	LET resultado_iddevolucion       = '';
	LET resultado_consecutivo        = '';
	LET resultado_transacc           = '';
	LET resultado_tpoidorigen      = '';
	LET resultado_monto              = '';
	LET resultado_tpoiddestino     = '';
	LET resultado_metodoacceso      = '';
	LET resultado_tpoacceso         = '';
	LET resultado_idtransac         = '';
	LET resultado_idreceptor        = '';
	LET resultado_integridad         = '';

	END IF;



RETURN  resultado_fechaTransac, resultado_horaIniTransac, resultado_horaFinTransac, resultado_secuencia, resultado_bancoOrigen,  resultado_numeroOrigen, resultado_bancoDestino,  resultado_numeroIdDestino,  resultado_estatusTransac, resultado_saldoOrigen, resultado_saldoDestino, resultado_motivo, resultado_referencia, resultado_comision, resultado_iva, resultado_idReverso, resultado_tipoTransac,  resultado_transacMps,  resultado_iddevolucion, resultado_consecutivo, resultado_transacc, resultado_tpoidorigen, resultado_monto, resultado_tpoiddestino, resultado_metodoacceso, resultado_tpoacceso, resultado_idtransac, resultado_idreceptor, resultado_integridad;
		
	END
END PROCEDURE;