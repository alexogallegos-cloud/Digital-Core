CREATE PROCEDURE "informix".sp_saldos_monto_prom_mes(p_anio INTEGER, p_mes INTEGER, p_num_credito CHAR(20), p_origen INTEGER)
       RETURNING CHAR(6), CHAR(150);



-- EL PARAMETRO p_origen
-- 1 = EL USARIO INDICA LA FECHA A EJECUTAR
-- 2 = LA EJECUCION SE REALIZA CON LA FECHA ACTUAL
       
DEFINE v_saldos            CHAR(3);
DEFINE vcodret             CHAR(6);
DEFINE vvcCod_ret          CHAR(6);
DEFINE ccod_ret            CHAR(6);
DEFINE vmensaje            CHAR(150);
DEFINE cmensaje            CHAR(150);
DEFINE sql_err             INTEGER;
DEFINE isam_err            INTEGER;
DEFINE error_info          VARCHAR(150);
DEFINE v_num_credito       CHAR(20);
DEFINE vfch_fin            DATE;
DEFINE vfch_inicio         DATE;
DEFINE vmes_ejecut         CHAR(8);
DEFINE v_saldos_prom       CHAR (3);
DEFINE v_contador          INTEGER;
DEFINE v_saldos_anual      CHAR(3);
DEFINE vempresa            CHAR(3);
DEFINE cProceso            CHAR(4);

DEFINE v_monto             DECIMAL(18,2);
DEFINE promedio            DECIMAL;
DEFINE dMontoAnual         DECIMAL(18,2);
    
    --SET DEBUG FILE TO "/tmp/sp_dispo_monto_prom_mes.out";
    --TRACE ON; 

    CALL "informix".sp_fecha_moncob(p_anio, p_mes, p_origen)
         RETURNING vfch_inicio, vfch_fin, vmes_ejecut;

    LET vMensaje = 'PROCESO EXITOSO';
    LET cmensaje = 'PROCESO EXITOSO';
    LET vCodRet = '00000';
    LET vempresa = '001';
    LET cProceso = '0003';
    LET cCod_ret = '000000';
        
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;
        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '02', vmes_ejecut)
        RETURNING vvcCod_ret;
        RETURN vcodret, vmensaje;
    END EXCEPTION;

        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '01', vmes_ejecut)
        RETURNING vvcCod_ret;

    SELECT valor_alfabetico INTO v_saldos FROM mc_configuracion WHERE empresa = vempresa
    AND grupo_parametro = 'INDICADORES' AND num_parametro = 4;

    SELECT valor_alfabetico INTO v_saldos_prom FROM mc_configuracion WHERE empresa = vempresa
    AND grupo_parametro = 'INDICADORES' AND num_parametro = 5;

    SELECT valor_alfabetico INTO v_saldos_anual FROM mc_configuracion WHERE empresa = vempresa
    AND grupo_parametro = 'INDICADORES' AND num_parametro = 6;

SET ISOLATION TO dirty READ;
FOREACH

    SELECT {+INDEX( bdicred:sd_maesdoshist maesdishist1)}a.num_credito --, b.sdo_acum_mes_cap, b.cap_tras_no_venci, b.dias_acum_int, b.sdo_cap_insoluto 
    INTO v_num_credito --, v_sdo_acum_mes_cap, v_cap_tras_no_venci, v_dias_acum_int, v_monto_mes 
    FROM bdimonitorcob:mc_masterestad a, bdicred:sd_maesdoshist b
    WHERE b.fecha BETWEEN vfch_inicio AND vfch_fin
    AND b.empresa = a.empresa
    AND b.num_credito = a.num_credito
   
-- falta extraer el monto del saldo
-- falta extraer el promedio mensual de saldo 

   IF v_monto IS NULL THEN
      LET v_monto=0;
   END IF

   IF v_contador= 0 THEN
     LET promedio = 0;
        ELSE
        LET promedio = v_monto / v_contador;
    END IF

   IF (p_mes = 01) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ene = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
 
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ene = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;
        
   ELIF (p_mes = 02) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET feb = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;

       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET feb = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 03) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET mar = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET mar = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 04) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET abr = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET abr = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 05) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET may = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;

      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET may = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

    ELIF (p_mes = 06) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jun = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;

      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jun = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 07) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jul = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jul = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 08) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ago = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ago = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 09) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET sep = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;

       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET sep = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 10) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET oct = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET oct = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 11) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET nov = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET nov = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   ELIF (p_mes = 12) THEN
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET dic = v_monto, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos
        AND anio = p_anio;
      
      UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET dic = promedio, fecha_ejecucion = CURRENT
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_saldos_prom
        AND anio = p_anio;

   END IF
   
   --actualizar el monto de la tabla mc_detestadanual si el monto del mes es mayor al monto anual para el concepto '200'
    SELECT {+INDEX(bdimonitorcob:mc_detestadanual detanual)} monto
    INTO dMontoAnual
    FROM mc_detestadanual
    WHERE anio = p_anio
    AND id_conceptoa = v_saldos_anual 
    AND num_credito = v_num_credito;
    
    IF v_monto > dMontoAnual THEN

        UPDATE {+INDEX(bdimonitorcob:mc_detestadanual detanual)} mc_detestadanual
        SET monto = v_monto
        WHERE anio = p_anio
        AND id_conceptoa = v_saldos_anual 
        AND num_credito= v_num_credito;

    END IF;

END FOREACH;
END

    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

RETURN vCodRet, vMensaje;
END PROCEDURE;