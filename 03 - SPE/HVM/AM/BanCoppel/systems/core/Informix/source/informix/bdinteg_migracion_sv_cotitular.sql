CREATE PROCEDURE "informix".migracion_sv_cotitular()
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
LEt vrowid      = 0;


--SET DEBUG FILE TO '/respaldosbd/migracion_sv_cotitular.out';
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
              from bdinvers:sv_cotitular
             where parentesco in ('K','S','M','O')

            begin work;
                 UPDATE bdinvers:sv_cotitular SET parentesco = vparentesco WHERE rowid = vrowid;
            commit work;
        end foreach;

		RETURN cCodret;

	END;
--*********************************************************
--| Procedimiento   : migracion_sv_cotitular
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Diciembre de 2010
--| Descripción     : Realiza la migración de parentesco
--|					  de firmantes del cliente.
--**********************************************************
END PROCEDURE;