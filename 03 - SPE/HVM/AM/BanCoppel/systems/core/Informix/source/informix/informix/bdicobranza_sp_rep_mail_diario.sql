CREATE PROCEDURE "informix".sp_rep_mail_diario ()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--08-27-2012
--manda llamar sps que crean archivos de envio de mail que corren de manera diaria


----DATOS QUE VAN EN LA TABLA

--VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(5);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(80);


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02')RETURNING P_COD_RET;	
	RETURN P_COD_RET;
    END EXCEPTION;

 -- Set debug file to 'mail.out';
 -- trace on;

---INICIALIZAN VARIABLES PARA QUERYS
Let P_cod_ret		= "00000";
LET vproceso		='2091';
LET cMensaje   		= 'PROCESO EXITOSO';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING P_COD_RET;
    
	
	-------------------------------------LLAMA A SPS QUE CORREN DIARO------------------------------------
	call "informix".sp_rep_envio_mail_compromiso() RETURNING P_COD_RET;  
	call "informix".sp_rep_envio_sms_pp() RETURNING P_COD_RET; 
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;