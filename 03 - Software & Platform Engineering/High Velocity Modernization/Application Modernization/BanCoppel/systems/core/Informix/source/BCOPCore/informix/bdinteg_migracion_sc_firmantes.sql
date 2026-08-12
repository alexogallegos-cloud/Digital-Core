CREATE PROCEDURE "informix".migracion_sc_firmantes()
	RETURNING CHAR(6);

--DECLARACION DE VARIABLES;
DEFINE cCodret      CHAR(5);
DEFINE isqlerr      INTEGER;
DEFINE vempresa     char(03);
DEFINE vcuenta      char(20);
DEFINE vsecuencia   smallint;
DEFINE vparentesco  char(20);  


--INICIALIZACIÓN DE VARIABLES
LET cCodret       = '00000';
LET isqlerr       = 0;
LET vempresa      = '';
LET vcuenta       = '';
LET vsecuencia    = 0;
LET vparentesco   = '';


--SET DEBUG FILE TO '/tmp/migracion_sc_firmantes.out';
--TRACE ON;

	BEGIN

		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN
				let cCodret = isqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

        foreach with hold
            select DECODE(parentesco,'K','I','S','I','M','P','O','I'), empresa, cuenta, secuencia
              into vparentesco, vempresa, vcuenta, vsecuencia
              from bdicheq:sc_firmantes
             where parentesco in ('K','S','M','O')

            begin work;
                UPDATE {+ INDEX(bdicheq:sc_firmantes idx_firmantes1)} bdicheq:sc_firmantes SET parentesco = vparentesco  
                 WHERE empresa = vempresa 
                   and cuenta = vcuenta
                   and secuencia = vsecuencia;
            commit work;
        end foreach;

		RETURN cCodret;

	END;
--*********************************************************
--| Procedimiento   : migracion_sc_firmantes
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Diciembre de 2010
--| Descripción     : Realiza la migración de parentesco
--|					  de firmantes del cliente.
--**********************************************************
END PROCEDURE;