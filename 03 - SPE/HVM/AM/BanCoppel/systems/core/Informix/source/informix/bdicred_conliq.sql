CREATE PROCEDURE "informix".conliq(o_empresa	CHAR(3),
			o_numcred	CHAR(20))
RETURNING CHAR(5), CHAR(60), MONEY(14,2);

-- **************************************************************************
-- *           			DEFINICION DE VARIABLES                     *
-- **************************************************************************

DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE x_adetot		MONEY(14,2);
DEFINE x_nombre		CHAR(60);
DEFINE v_fechavig	DATE;
DEFINE v_intdia		MONEY(14,2);
DEFINE v_partd          CHAR(4);
DEFINE v_hoy            DATE;
DEFINE v_fcuota         DATE;
DEFINE v_dias           SMALLINT;
DEFINE v_tpcred         CHAR(2);


-- **************************************************************************
-- *           			ASIGNACION DE VARIABLES                     *
-- **************************************************************************
LET v_codret	="00000";
LET sql_err	=0;
LET x_adetot	=0;
LET x_nombre	=" ";
LET v_fechavig  ="";
-- **************************************************************************
-- *           			CONTROL DE ERRORES                          *
-- **************************************************************************

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
	 RETURN v_codret, x_nombre, x_adetot;
      end if;
   END EXCEPTION;



-- **************************************************************************
-- *           			PROGRAMA PRINCIPAL                          *
-- **************************************************************************

        -- Determina Fecha Cuota Vigente
        SELECT NVL(MIN(fecha_cuota),"01/01/1800")
          INTO v_fechavig
          FROM sd_paginter, sd_fechas
         WHERE fecha_cuota >= fecha_hoy
           AND num_credito = o_numcred
           AND sd_paginter.empresa = o_empresa;



	SELECT sdo_cap_insoluto + sdo_exig_int + sdo_moratorio +
	       NVL((SELECT SUM(monto_com-monto_pag)
                  FROM sd_detcomi d, sd_tpcomis e
                 WHERE d.num_credito = o_numcred
                   AND estado_com ="P"
                   AND e.cod_comis = d.cod_comis
		   AND fecha_alta <= v_fechavig),0),
	       TRIM(NVL(razon_social,' ')) ||
	       TRIM(NVL(nombre1, ' ')) || ' ' ||
	       TRIM(NVL(nombre2, ' ')) || ' ' ||
	       TRIM(NVL(apell_paterno, ' ')) || ' ' ||
	       TRIM(NVL(apell_materno, ' ')), cod_tipcred
	  INTO x_adetot, x_nombre, v_tpcred
	  FROM sd_maesdos a, sd_maecred b, si_cliente c, sd_definicion d
	 WHERE a.num_credito = o_numcred
	   AND a.empresa = o_empresa
	   AND b.num_credito = a.num_credito
	   AND b.empresa     = a.empresa
	   AND d.num_producto = b.num_producto
	   AND d.empresa = b.empresa
	   AND c.numcte = b.numcte;

	IF x_adetot IS NULL THEN
		LET v_codret ="100";
		RETURN v_codret, x_nombre, x_adetot;
	END IF


	EXECUTE PROCEDURE calc_intdia(o_numcred)
	   INTO v_codret, v_intdia, v_dias;
		 -- Por si son a favor del cliente
		IF v_intdia < 0 or v_intdia IS NULL THEN
			LET v_intdia = 0;
		END IF

	LET x_adetot = x_adetot + v_intdia;


END

	RETURN v_codret, x_nombre, x_adetot;

END PROCEDURE;