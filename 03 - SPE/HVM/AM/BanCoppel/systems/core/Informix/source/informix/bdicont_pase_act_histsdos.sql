CREATE PROCEDURE "informix".pase_act_histsdos(pempresa char(3))
RETURNING CHAR(5);

DEFINE cod_ret char(5);
DEFINE hempresa          char(3);
DEFINE hccmayor          char(10);
DEFINE hccsub            char(10);
DEFINE hccsubsub         char(10);
DEFINE hccssubsub        char(10);
DEFINE hccsssubsub       char(10);
DEFINE hsector           char(10);
DEFINE hciudad           char(3);
DEFINE hsucursal         char(4);
DEFINE hmoneda           char(2);
DEFINE hmes_dia          date;
DEFINE hcargos_dia       money(18,2);
DEFINE habonos_dia       money(18,2);
DEFINE hnro_cargos_dia   integer;
DEFINE hnro_abonos_dia   integer;
DEFINE hdias_proyectado  smallint;
DEFINE hdias_acumulado   smallint;
DEFINE hsaldo_acumulado  money(18,2);
DEFINE hsaldo_inicio_dia money(18,2);
DEFINE hsaldo_fin_de_dia money(18,2);
DEFINE vpri_dia_mes date;
DEFINE vult_dia_mes date;
DEFINE vcontador INTEGER;

-- ****************************************************************************
-- Graba movimientos del Mensual en el Historico de Contabilidad
-- ****************************************************************************
LET vcontador = 1;
LET cod_ret = "000";

SELECT pri_dia_mes, ult_dia_mes INTO vpri_dia_mes,vult_dia_mes FROM bdicont:co_fechas
    WHERE empresa = pempresa;

FOREACH WITH HOLD
         SELECT *
         INTO  hempresa,hccmayor,hccsub,hccsubsub,hccssubsub,hccsssubsub,hsector,hciudad,hsucursal,
               hmoneda,hmes_dia,hcargos_dia,habonos_dia,hnro_cargos_dia,hnro_abonos_dia,hdias_proyectado,
               hdias_acumulado,hsaldo_acumulado,hsaldo_inicio_dia,hsaldo_fin_de_dia
         FROM co_histsdodias_tmp
        WHERE empresa = pempresa
          AND mes_dia BETWEEN vpri_dia_mes AND vult_dia_mes

	IF vcontador=1 THEN
		BEGIN WORK;
	END IF;

         INSERT INTO co_histsdodias
         VALUES(hempresa,hccmayor,hccsub,hccsubsub,hccssubsub,hccsssubsub,hsector,hciudad,hsucursal,
                hmoneda,hmes_dia,hcargos_dia,habonos_dia,hnro_cargos_dia,hnro_abonos_dia,hdias_proyectado,
                hdias_acumulado,hsaldo_acumulado,hsaldo_inicio_dia,hsaldo_fin_de_dia);

	IF vcontador >=75000 THEN
		COMMIT WORK;
		LET vcontador=1;
	ELSE
		LET vcontador = vcontador + 1 ;
	END IF;

  CONTINUE FOREACH;
END FOREACH;

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
	END IF;

RETURN cod_ret;

END PROCEDURE;