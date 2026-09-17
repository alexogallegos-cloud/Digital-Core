CREATE PROCEDURE "informix".sp_actualizanumsalariominimo(pEmpresa char(3))
RETURNING CHAR(6),CHAR(80);

-- Autor: Viridiana Osobampo.
-- Descripción: Actualiza el número de salarios mínimos correspondientes al
--              ingreso mensual del cliente en base al valor de salario mínimo
--              registrado a la fecha de la solicitud.
-- Fecha de creación: 23-04-2009.
-- Proyecto: Caja Unica.
-- Solo para ejecutarse durante la implementación de Caja Única. Corrida Única.

DEFINE salariominimo        SMALLINT;
DEFINE solicitud            CHAR(20);
DEFINE ingresomensual       MONEY(14,2);
DEFINE numsalariosminimos   SMALLINT;
DEFINE fechasolicitud       DATE;
DEFINE divsalariominimo     SMALLINT;
DEFINE mensaje              CHAR(80);
DEFINE existe               SMALLINT;
define dFechaCambio         DATE;
define dDiahasta            DATE;
define iTotal               SMALLINT;

DEFINE scod_ret         CHAR(6);
DEFINE vsqlerr		INTEGER;

LET salariominimo       =0;
LET solicitud           ="";
LET ingresomensual      = 0;
LET numsalariosminimos  = 0;
LET fechasolicitud      =DATE(1);
LET divsalariominimo    = 0;
LET mensaje             = "";
LET existe              =0;
LET dDiahasta           = DATE(1);
LET itotal 		= 0;

LET vsqlerr         = 0;
LET scod_ret        = "000000";

BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
	      LET scod_ret=vsqlerr;
	      RETURN scod_ret,mensaje;
	   END IF;
	END EXCEPTION;
	
--SET DEBUG FILE TO "/tmp/actualizasmb.out";
--TRACE ON;

SELECT COUNT(tabname) INTO existe 
FROM systables WHERE tabname = 'si_tmphistdiv';

IF existe > 0 THEN
    DROP TABLE si_tmphistdiv;
END IF;

    SELECT *, mdy(1,1,1900) AS fechahasta 
    FROM bdinteg:si_histdiv
    WHERE empresa = pEmpresa
      AND divisa = '90'
    ORDER BY empresa, divisa, fecha_tc
      INTO temp si_tmphistdiv;

    CREATE INDEX idx_si_tmphistdiv ON si_tmphistdiv (empresa,divisa,fecha_tc) USING btree;

    SELECT COUNT(divisa)
      INTO divsalariominimo
      FROM si_tmphistdiv
     WHERE empresa = pEmpresa
       AND divisa = '90';

    IF divsalariominimo = 0 THEN
        LET scod_ret = '001';
        LET mensaje = 'No existe tipo de cambio para la divisa 90 (SMB)';
        RETURN scod_ret,mensaje;
    END IF;

-- Obtiene el valor que tenia el salario mínimo cuando se realizó la solicitud, calcula el numero de salarios mínimos equivalentes
-- al ingreso mensual y realiza la actualización en el registro de la solicitud correspondiente.

---------------------------
    FOREACH
        SELECT fecha_tc
        INTO dFechaCambio
        FROM si_tmphistdiv
        WHERE empresa = '001' AND divisa = '90'
        ORDER BY empresa, divisa, fecha_tc

        SELECT MIN(fecha_tc) - 1, COUNT(*)
        INTO dDiahasta, iTotal
        FROM  bdinteg:si_histdiv 
        WHERE empresa = '001' AND divisa = '90'
        AND fecha_tc > dFechaCambio;

        IF iTotal = 0 THEN
            LET dDiahasta = mdy(1,1,2010);
        END IF;

        UPDATE si_tmphistdiv SET fechaHasta = dDiahasta WHERE empresa = '001' AND divisa = '90' AND fecha_tc = dFechaCambio;

    END FOREACH;


---------------------------
    LET iTotal = 0;
FOREACH
    SELECT r.num_solicitud, r.ingreso_mensual,s.fecha_insert, d.precio_compra
      INTO solicitud,ingresomensual,fechasolicitud, salariominimo
      FROM bdisolic:ss_resum_scor_fin r, bdisolic:ss_solicitudes s, si_tmphistdiv  d
     WHERE r.empresa = s.empresa
       AND r.empresa = d.empresa
       AND r.num_solicitud = s.num_solicitud
       AND r.empresa = pEmpresa
       AND d.divisa = '90'
       and s.fecha_insert >= d.fecha_tc and s.fecha_insert <= d.fechaHasta

       IF ingresomensual > 0  THEN
          LET numsalariosminimos= ROUND((ingresomensual / salariominimo),2);
       ELSE
         LET numsalariosminimos= 0;
       END IF;

        UPDATE bdisolic:ss_resum_scor_fin
           SET smbc = numsalariosminimos
         WHERE empresa = pEmpresa
           AND num_solicitud = solicitud;

    LET iTotal = iTotal + 1;

END FOREACH
LET Mensaje = 'Proceso Terminado. ' || itotal || ' Solicitudes afectadas.';

DROP TABLE si_tmphistdiv;
END
    RETURN scod_ret, mensaje;
END PROCEDURE;