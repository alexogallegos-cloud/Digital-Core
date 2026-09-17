CREATE PROCEDURE "informix".asigna_tasasol(o_empresa      CHAR(3),
			        o_num_producto CHAR(4),
				o_cod_prod     CHAR(2))
RETURNING CHAR(5), DECIMAL(9,6);

-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE vcod_ret CHAR(5);
DEFINE vvaltasa DECIMAL(9,6);
-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcod_ret = "00000";
LET vvaltasa = 0;
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      RETURN vcod_ret,vvaltasa;
   END IF;
END EXCEPTION;

-- *********** INICIA PROCESO DE ASIGNACION ******************

        SELECT DECODE(a.factor_sobretasa, '+', b.valor + a.sobretasa,
                                          '-', b.valor - a.sobretasa,
                                 '*', b.valor * a.sobretasa,
                                          '/', b.valor / a.sobretasa)
	  INTO vvaltasa
          FROM bdicred:sd_anexodefinicion a,
               bdinteg:si_fechavalor b
         WHERE a.num_producto = o_num_producto
           AND a.cod_prod = o_cod_prod
           AND a.empresa = o_empresa
           AND b.fecha in(
               SELECT MAX(c.fecha)
               FROM bdicred:sd_anexodefinicion d,
                    bdinteg:si_fechavalor c
               WHERE d.num_producto = o_num_producto
               AND d.cod_prod = o_cod_prod
               AND d.empresa = o_empresa
               AND c.empresa = d.empresa
               AND c.tasa = d.cod_tasa_base
               )
           AND b.empresa = a.empresa
           AND b.tasa = a.cod_tasa_base;

	IF vvaltasa IS NULL THEN
		LET vvaltasa = 0;
		LET vcod_ret = "501";
		RETURN vcod_ret, vvaltasa;
	END IF

END

	RETURN vcod_ret, vvaltasa;

END PROCEDURE;