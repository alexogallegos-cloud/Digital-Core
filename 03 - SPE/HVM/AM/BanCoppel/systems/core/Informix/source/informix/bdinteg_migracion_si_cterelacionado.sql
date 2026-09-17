CREATE PROCEDURE "informix".migracion_si_cterelacionado()
	RETURNING CHAR(6);

--DECLARACION DE VARIABLES;
DEFINE cCodret      CHAR(5);
DEFINE isqlerr      INTEGER;
DEFINE vparentesco  char(20);  
DEFINE vrowid       integer;


--INICIALIZACIÓN DE VARIABLES
LET cCodret     = '00000';
LET isqlerr     = 0;
LET vparentesco = '';
LEt vrowid = 0;


--SET DEBUG FILE TO '/tmp/migracion_si_cterelacionado.out';
--TRACE ON;

	BEGIN

		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN
				let cCodret = isqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

        foreach with hold
            select rowid, DECODE(parentesco,'K','I','S','I','M','P','O','I')
              into vrowid, vparentesco
              from bdinteg:si_cterelacionado
             where parentesco in ('K','S','M','O')

            begin work;
                 UPDATE bdinteg:si_cterelacionado SET parentesco = vparentesco WHERE rowid = vrowid;
            commit work;
        end foreach;

		RETURN cCodret;

	END;
END PROCEDURE;