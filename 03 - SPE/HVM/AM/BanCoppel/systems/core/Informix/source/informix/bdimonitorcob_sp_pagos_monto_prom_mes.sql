CREATE PROCEDURE "informix".sp_pagos_monto_prom_mes(v_anio INTEGER, v_mes INTEGER, p_num_credito CHAR(20), p_origen INTEGER)
       RETURNING CHAR(5), CHAR(80);

--Modificó: Lorenzo Ibarra Garcia
--Fecha: 08-10-2009
--Se corrigió la inserción a la tabla de la bitacora.
--Se agrego la actualización del campo monto de la tabla mc_detestadanual si el monto del mes es mayor al monto anual para el concepto '210'
       
DEFINE v_concepto         CHAR(3);
DEFINE vCodRet            CHAR(5);
DEFINE vMensaje           CHAR(80);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE v_num_credito      CHAR(20);
DEFINE v_monto            MONEY;
DEFINE v_fch_ini          DATE;
DEFINE v_fch_fin          DATE;
DEFINE v_fch_inic         DATE;
DEFINE v_conceptop        CHAR (3); 
DEFINE v_contador         integer;
DEFINE promedio           decimal;
DEFINE p_mes              INTEGER;
DEFINE p_anio             INTEGER;
DEFINE cNombreProceso     CHAR(30);
DEFINE cMesAnioEjecucion  CHAR(20);
DEFINE dMontoAnual        MONEY(18,2);
DEFINE cConceptoAnual     CHAR(3);
DEFINE d                  DATE;
DEFINE i                  INTEGER;
DEFINE v_pri_dia_mes      DATE;
DEFINE vv_pri_dia_mes     DATE;
DEFINE v_fecha_inicial    CHAR(10);

    LET i = 1;

    IF p_origen = 1 THEN
        
        IF  v_mes = 1 THEN
            LET v_mes= 12;
            LET v_anio = v_anio - 1;
            
            LET v_fecha_inicial =   v_mes || '-' || '21' || '-' || v_anio ;             ------CAMBIOS
            LET d   =   DATE(v_fecha_inicial);

        ELSE
        
            LET v_fecha_inicial =   v_mes - 1 || '-' || '21' || '-' || v_anio ;         ------CAMBIOS
            LET d   =   DATE(v_fecha_inicial);
            
        END IF;

    ELSE
        SELECT pri_dia_mes INTO vv_pri_dia_mes FROM bdinteg:si_fechas;
        LET v_pri_dia_mes = vv_pri_dia_mes - 2 UNITS MONTH;
        LET d = v_pri_dia_mes + 20 units day;
    END IF;

    --SET DEBUG FILE TO "/tmp/sp_pagos_monto_prom_mes.out";
    --TRACE ON; 

CALL    bdicred:monthadd(d, i)
        RETURNING v_fch_ini;

    LET v_num_credito       = " ";
    LET v_monto             = 0;
    LET v_concepto          = "240";
    LET v_conceptop         = "180";
    LET vCodRet             = "11111";
    LET vMensaje            = "PROCESO INICIALIZADO";
    LET v_fch_inic          = d;    ------------------------------FECHA INICIAL    
    LET v_fch_fin           = v_fch_ini - i UNITS DAY;  ----------FECHA FINAL
    LET p_anio              = year  (v_fch_fin);
    LET p_mes               = month (v_fch_fin);
    LET cNombreProceso      = 'Calcula Pagos';
    LET cMesAnioEjecucion   = TO_CHAR(v_fch_fin, '%m%Y');
    LET dMontoAnual         = 0;
    LET cConceptoAnual      = '210';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
        
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, user, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
        
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
  
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, user, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

    SET ISOLATION TO dirty READ;

FOREACH


SELECT {+INDEX(bdimonitorcob:mc_masterestad mc_masterestad_uc1)} a.num_credito, SUM (b.monto), count (b.monto) 
   INTO v_num_credito, v_monto, v_contador 
   FROM bdimonitorcob:mc_masterestad a, bdicred:sd_movhis b
   WHERE a.num_credito = b.num_credito
     AND a.empresa = b.empresa
     AND b.codigo_fun IN ('033','334','335','336','901','337')
     AND b.codigo_ref IN ( 1,901)
     AND b.fecha_mov between v_fch_inic AND v_fch_fin
     AND b.reversado = 'N' group by a.num_credito
   
   
   IF v_monto is null then
      LET v_monto=0;
   END IF

   IF v_contador= 0 then
     LET promedio = 0;
        ELSE
        LET promedio = v_monto / v_contador;
    END IF

   IF (p_mes = 01) THEN
         UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ene = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
 
         UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ene = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;
        
   ELIF (p_mes = 02) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET feb = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;

        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET feb = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 03) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET mar = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET mar = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 04) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET abr = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET abr = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 05) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET may = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;

       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET may = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;
    ELIF (p_mes = 06) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jun = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;

       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jun = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 07) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jul = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET jul = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;
   ELIF (p_mes = 08) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ago = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET ago = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 09) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET sep = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;

        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET sep = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 10) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET oct = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET oct = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 11) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET nov = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
        UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET nov = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   ELIF (p_mes = 12) THEN
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET dic = v_monto, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_concepto
        AND anio = p_anio;
      
       UPDATE {+INDEX{bdimonitorcob:mc_detestadmes idx_detestadmes)} mc_detestadmes
         SET dic = promedio, fecha_ejecucion = current
      WHERE num_credito = v_num_credito
        AND id_conceptom = v_conceptop
        AND anio = p_anio;

   END IF

   --actualizar el monto de la tabla mc_detestadanual si el monto del mes es mayor al monto anual para el concepto '210'
    SELECT {+INDEX(bdimonitorcob:mc_detestadanual detanual)} monto
    INTO dMontoAnual
    FROM mc_detestadanual
    WHERE anio = p_anio
    AND id_conceptoa = cConceptoAnual 
    AND num_credito = v_num_credito;
    
    IF v_monto > dMontoAnual THEN
        UPDATE {+INDEX(bdimonitorcob:mc_detestadanual detanual)} mc_detestadanual
        SET monto = v_monto
        WHERE anio = p_anio
        AND id_conceptoa = cConceptoAnual 
        AND num_credito= v_num_credito;
    END IF;
   
END FOREACH;

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

    --insertar control de procesos
    INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
    VALUES(cNombreProceso, vCodRet, vMensaje, user, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

END 

RETURN vCodRet, vMensaje;

END PROCEDURE;