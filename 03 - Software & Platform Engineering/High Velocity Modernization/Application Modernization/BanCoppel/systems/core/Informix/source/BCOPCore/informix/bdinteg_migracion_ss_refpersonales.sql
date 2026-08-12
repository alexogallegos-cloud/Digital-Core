CREATE PROCEDURE "informix".migracion_ss_refpersonales()
	RETURNING CHAR(6);

--DECLARACION DE VARIABLES;
DEFINE cCodret          CHAR(5);
DEFINE isqlerr          INTEGER;
DEFINE vnum_solicitud   char(20);
DEFINE vnumcte          char(20);
DEFINE vparentesco      char(20);
DEFINE vparentescod     char(20);
DEFINE vnumcteref       char(20);

--INICIALIZACIÓN DE VARIABLES
LET cCodret         = '00000';
LET isqlerr         = 0;
LET vnum_solicitud  = '';
LET vnumcte         = '';
LET vparentesco     = '';
LET vparentescod    = '';
LET vnumcteref      = '';


--SET DEBUG FILE TO '/tmp/migracion_ss_refpersonales.out';
--TRACE ON;

	BEGIN

		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN
				let cCodret = isqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

        foreach with hold
            select DECODE(parentesco,'K','I','S','I','M','P','O','I'), parentesco, num_solicitud, numcte, numcte_ref
              into vparentescod, vparentesco,vnum_solicitud, vnumcte, vnumcteref
              from bdisolic:ss_refpersonales
             where parentesco in ('K','S','M','O')

            begin work;
                UPDATE bdisolic:ss_refpersonales SET parentesco = vparentescod
                 WHERE num_solicitud = vnum_solicitud
                   and numcte = vnumcte
                   and parentesco = vparentesco
                   and numcte_ref = vnumcteref;
            commit work;
        end foreach;

		RETURN cCodret;

	END;
--*********************************************************
--| Procedimiento   : migracion_ss_refpersonales
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Diciembre de 2010
--| Descripción     : Realiza la migración de parentesco
--|					  de referencias del cliente.
--**********************************************************
END PROCEDURE;