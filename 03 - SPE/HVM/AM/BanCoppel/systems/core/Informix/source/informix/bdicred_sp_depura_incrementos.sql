create procedure "informix".sp_depura_incrementos()
--execute procedure sp_depura_incrementos()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
			
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);	

DEFINE vnum_credito        	CHAR(12);	
DEFINE vnum_cte     		VARCHAR(20);	
DEFINE vstatus				CHAR(2);	
DEFINE fh_inicio			char(19);DEFINE fh_fin				char(19);DEFINE vfecha				DATE;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vnum_credito			="";
LET vnum_cte				="";
LET vstatus					="";
LET fh_inicio				=date(1);
LET fh_fin					=date(1);
LET vfecha					=date(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/sp_depura_incrementos.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

SELECT num_solicitud,fecha_insert
FROM bdicred:sd_bitacora_aumlincred 
WHERE status = 'RT' AND fecha_insert = mdy('12','10','2015') AND origen = 'C' 
INTO TEMP tot_creditos  WITH NO LOG;

CREATE INDEX idx_totcreditos ON tot_creditos (num_solicitud);	
update statistics medium for table tot_creditos;		

select first 1 today||" "||current HOUR TO SECOND   INTO fh_inicio
from systables;

  foreach with hold
    SELECT num_solicitud,fecha_insert INTO  vnum_credito, vfecha
	FROM tot_creditos

    begin;
		DELETE FROM "informix".sd_autorizacion_aumlincred WHERE num_solicitud = vnum_credito  AND fecha_insert  = vfecha;
		DELETE FROM "informix".sd_clientes_clean_behavior WHERE fecha_reporte  = vfecha AND num_credito = vnum_credito;
		DELETE FROM "informix".sd_bitacora_aumlincred WHERE empresa="001" AND num_solicitud = vnum_credito AND status = "RT" AND fecha_insert  = vfecha;
	commit;	
  END FOREACH

select first 1 today||" "||current HOUR TO SECOND   INTO fh_fin
from systables;

LET cCodRet     = "00000";
LET cMensajeRet = "DEPURA INCREMENTOS INICIO:"||fh_inicio ||" FIN:"||fh_fin;

RETURN cCodRet, cMensajeRet; 
END;
END PROCEDURE;