CREATE PROCEDURE "informix".sp_reporte_edocuenta(pempresa char(3),pnum_tarjeta char(20),
  				 Periodo date)

RETURNING CHAR(5),integer;

DEFINE cod_ret             char(5);
DEFINE sql_err             integer;

DEFINE v_fecha	DATE;
DEFINE v_fecha_hist DATE;
DEFINE v_reporte integer;


LET v_fecha = " ";
LET v_fecha_hist = " ";
LET v_reporte = 0;

 
 --SET DEBUG FILE TO "obtenPeriodos_edocuenta.out";
 --TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret," ";
        END IF
   END EXCEPTION;

SET ISOLATION TO DIRTY READ;

   LET cod_ret = "000";

    IF Periodo <= MDY('05','20','2008') THEN
       LET  v_reporte = 0;
    ELIF
	
        --EXISTS(SELECT {+INDEX(sd_encabezado_edocta td_encabezado_tarjeta)} * FROM bdicred:sd_encabezado_edocta where fecha_emision = mdy(month(Periodo),day(Periodo),year(Periodo)) and num_tarjeta = pnum_tarjeta) THEN
		EXISTS(SELECT * FROM bdicred@pld_tcp:sd_encabezado_edocta where fecha_emision = mdy(month(Periodo),day(Periodo),year(Periodo)) and num_tarjeta = pnum_tarjeta) THEN
        LET v_reporte = 2;   
        
    ELIF
        EXISTS(SELECT {+INDEX(sd_encabezado_edocta_hist idx_encabezado2_edocta1_hist)} * FROM bdicred:sd_encabezado_edocta_hist where fecha_emision = mdy(month(Periodo),day(Periodo),year(Periodo)) and num_tarjeta = pnum_tarjeta) THEN
		--EXISTS(SELECT {+INDEX(sd_encabezado_edocta_hist idx_encabezado2_edocta1_hist)} * FROM bdicred@pld_tcp:sd_encabezado_edocta_hist where fecha_emision = mdy(month(Periodo),day(Periodo),year(Periodo)) and num_tarjeta = pnum_tarjeta) THEN
        LET v_reporte = 1;   

    ELSE
        LET cod_ret = "002";  

  END IF   

	RETURN cod_ret,v_reporte WITH RESUME;

END;

--Procedimiento para el cambio de mensajes
--AUTOR : Leonardo Hernandez Moreno',
--FECHA : 12/Marzo/2010',
--BD    : BDICRED'
END PROCEDURE;