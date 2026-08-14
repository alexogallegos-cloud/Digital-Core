CREATE PROCEDURE "informix".sp_depura_bitacorabpi_v2(fechmin CHAR(10), fechmax CHAR(10))
    RETURNING CHAR(5), integer, integer;  --Códigos de retorno

DEFINE cCodRet       CHAR(5);
DEFINE vid_operacion    CHAR (4);
DEFINE vtotregshist  integer;
DEFINE iSqlErr       integer;
DEFINE cont_borra    integer;
DEFINE cursor_borra  integer;

LET cCodRet        = '00000';
LET vid_operacion     = '0000';
LET vtotregshist   = 0;
LET iSqlErr        = 0;
LET cont_borra     = 0;
LET cursor_borra   = 0;

 --SET DEBUG FILE TO "/tmp/sp_depura_bitacorabpi_v2.out";
 --TRACE ON;

        SET LOCK MODE TO wait 5;
BEGIN

   ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet, vtotregshist, cont_borra;
                END IF;
    END EXCEPTION;

     SELECT  count(*) 
        INTO vtotregshist  
     FROM bdinteg:si_bpibitacora
     WHERE extend (fecha_oper, year to day) between fechmin and fechmax
     and NVL(id_operacion,'') <> '';
	
	FOREACH cursor_borra WITH HOLD FOR
		SELECT id_operacion
			INTO vid_operacion
			FROM bdinteg:si_bpibitacora
			WHERE extend (fecha_oper, year to day) between fechmin and fechmax
			and NVL(id_operacion,'') <> ''
   begin work;
		DELETE FROM bdinteg:si_bpibitacora
			WHERE CURRENT OF cursor_borra;
		commit work;
		

        LET cont_borra = cont_borra + 1;

    END FOREACH;

END;
RETURN cCodRet, vtotregshist, cont_borra;
END PROCEDURE



;