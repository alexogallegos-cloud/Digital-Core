CREATE PROCEDURE "informix".sp_depura_reserva_cnr(f_reserva date)
RETURNING   CHAR(6) 	AS retorno,
            CHAR(250)   AS mensaje_ret;

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(250);

DEFINE vnum_credito   char(25);
DEFINE count_tot_reserva     int;
DEFINE count_tot_movhis      int;
DEFINE T_REG_MOV             smallint;


LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vnum_credito = '';
LET count_tot_reserva     = 0;
LET count_tot_movhis      = 0;
LET T_REG_MOV             = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
    END EXCEPTION;


--SET DEBUG FILE TO "trace_sp_depura_reserva_cnr.out";
--TRACE ON; 

    set isolation to dirty read;
    set lock mode to wait 3;
	
		CREATE INDEX   IF NOT EXISTS "informix".inx_sd_movhis_calif_cnr2 ON sd_movhis_calif_cnr(empresa, fecha_mov, num_credito);
		UPDATE STATISTICS MEDIUM FOR TABLE sd_movhis_calif_cnr;	

    select num_credito
    from bdicred:sd_hist_reserva_cnr
    where fecha_cierre = f_reserva
    INTO TEMP  univ_x_depurar WITH NO LOG;

    CREATE INDEX idx_univ_x_depurar ON univ_x_depurar(num_credito);
    update statistics medium for table univ_x_depurar;


    FOREACH WITH HOLD 
        Select num_credito
        into vnum_credito
        from univ_x_depurar

        LET count_tot_reserva = count_tot_reserva+1;
        
        begin;
            delete bdicred:sd_hist_reserva_cnr
            where empresa = '001'
              and num_credito = vnum_credito
              and fecha_cierre = f_reserva;

            delete bdicred:sd_movhis_calif_cnr
            where empresa = '001'
              and fecha_mov = f_reserva   
              and num_credito = vnum_credito;
        commit; 

    LET T_REG_MOV = 0;

    END FOREACH

UPDATE STATISTICS MEDIUM FOR TABLE sd_hist_reserva_cnr;
UPDATE STATISTICS MEDIUM FOR TABLE sd_movhis_calif_cnr;

LET cMensajeRet = "Depuración Calificacion CNR "||f_reserva||": HIST_RESERVA_CNR: "||count_tot_reserva;
RETURN cCodRet, cMensajeRet; 

END;
END PROCEDURE;