CREATE PROCEDURE "informix".sp_depura_regreso15()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE vsql                CHAR(1500);

DEFINE v_institucion        CHAR(2);
DEFINE v_numsol             CHAR(20);
DEFINE v_total		INTEGER;
DEFINE v_total_f		INTEGER;
DEFINE contador             INTEGER;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vsql                 = "";

LET v_institucion        ="";
LET v_numsol             ="";
LET v_total		    = 0;	
LET v_total_f		    = 0;
LET contador             = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
    END EXCEPTION;


--SET DEBUG FILE TO "trace_depura_regreso15.out";
--TRACE ON; 

    set isolation to dirty read;
    set lock mode to wait 3;


IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'regreso_paso') THEN

    CREATE TABLE regreso_paso
    (
        institucion char(2),
        num_solicitud char(20)
    );

    BEGIN;
        CREATE INDEX idx_reg_pas ON regreso_paso(num_solicitud) ONLINE;
    COMMIT;

    LET vsql = 'echo "'||
               'LOAD FROM /RESPALDOS/rel_regreso.unl INSERT INTO regreso_paso;' ||
               ' " >> /resplogifx/burodecredito/genload_regreso15.sql';
   system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genload_regreso15.sql';
  system vsql;

    UPDATE STATISTICS MEDIUM FOR TABLE regreso_paso;

  let vsql = "rm /resplogifx/burodecredito/genload_regreso15.sql";
  system vsql;
END IF;

SELECT count(*) INTO v_total from regreso_paso;

    FOREACH WITH HOLD
        SELECT institucion,num_solicitud
          INTO v_institucion, v_numsol
          FROM regreso_paso

          BEGIN;
          DELETE "informix".sb_regreso_2015 where institucion = v_institucion AND num_solicitud = v_numsol;
          COMMIT;
          
          LET contador = contador+1;

          BEGIN;
          DELETE "informix".regreso_paso where institucion = v_institucion AND num_solicitud = v_numsol;
          COMMIT;
    END FOREACH

   SELECT count(*) INTO v_total_f from regreso_paso;

   IF v_total_f = 0 THEN
     DROP TABLE regreso_paso;
   END IF;
   
    LET cCodRet     = "000000";
    LET cMensajeRet = "Depuración de regreso_2015: "||contador || " de " || v_total;

    RETURN cCodRet, cMensajeRet; 
     
END;
END PROCEDURE;