CREATE PROCEDURE "informix".cargarev(o_empresa CHAR(3),
			   o_sucursal CHAR(3),
			   o_usuario  CHAR(8),
			   o_folio    CHAR(16))
RETURNING CHAR(5),char(20),char(60),money(14,2),char(20);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE vnum_credito     CHAR(20);
DEFINE vnom_cliente     CHAR(60);
DEFINE vmonto           MONEY(14,2);
DEFINE vcuotas		CHAR(20);

-- ***************************************************************************

   ON EXCEPTION SET sql_err
      LET vnum_credito = " ";
      LET vnom_cliente = " ";
      LET vmonto = 0;
      LET vcuotas = " ";
      LET v_codret  = "000";
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret,vnum_credito,vnom_cliente,vmonto,vcuotas;
      END IF
   END EXCEPTION;


LET v_codret  = "000";
LET sql_err   = 0;
LET vnum_credito = " ";
LET vnom_cliente = " ";
LET vmonto = 0;
LET vcuotas = " ";


SELECT valor INTO vnum_credito
FROM   so_dettransacmov
WHERE  campoid = "CUENTA"
AND    sectransac = trim(o_folio);
--AND usuarioid = o_usuario;
	
SELECT valor INTO vnom_cliente
FROM   so_dettransacmov
WHERE  campoid = "STRING2"
AND    sectransac = trim(o_folio);
--AND usuarioid = o_usuario;

SELECT valor INTO vmonto
FROM   so_dettransacmov
WHERE  campoid = "IMPORTE"
AND    sectransac = trim(o_folio);
--AND    usuarioid = o_usuario;

SELECT valor INTO vcuotas
FROM   so_dettransacmov
WHERE  campoid = "INTEGER2"
AND    sectransac = trim(o_folio);
--AND    usuarioid = o_usuario;

IF vnum_credito IS NULL THEN LET vnum_credito = " "; END IF;

IF vnom_cliente IS NULL then  LET vnom_cliente = " "; END IF;
IF vmonto IS NULL then LET vmonto = 0;  END IF;
IF vcuotas IS NULL then LET vcuotas = " "; END IF;


RETURN v_codret,vnum_credito,vnom_cliente,vmonto,vcuotas;

END PROCEDURE;