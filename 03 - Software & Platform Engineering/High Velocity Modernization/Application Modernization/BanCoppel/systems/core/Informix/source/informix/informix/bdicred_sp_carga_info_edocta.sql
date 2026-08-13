create procedure "informix".sp_carga_info_edocta()
RETURNING CHAR(5);

DEFINE v_ruta             VARCHAR(255);
DEFINE v_ruta_cfd         VARCHAR(255);
DEFINE cod_ret            CHAR(6);
DEFINE sql_err            INTEGER;
DEFINE v_shell            CHAR(500);
DEFINE v_sql              CHAR(500);
DEFINE v_sql1             CHAR(500);
DEFINE v_sql2             CHAR(500);
DEFINE dFecha_hoy         DATE;
DEFINE dFechaCorte        DATE;
DEFINE dFechaCorte_pasada DATE;
DEFINE cEmpresa           CHAR(3);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);
DEFINE cArchivo2          CHAR(50);
DEFINE cFecha_hoy         CHAR(8);
DEFINE iCantRegs          INTEGER;
DEFINE c_num_proceso      CHAR(4);
DEFINE c_mensaje          CHAR(80);
DEFINE error_info		      CHAR(80);
DEFINE vCod_ret           CHAR(6);
DEFINE isam_err 	        INTEGER;

LET v_ruta           = "";
LET v_shell          = "";
LET v_sql            = "";
LET v_sql1           = "";
LET v_sql2           = "";
LET dFecha_hoy       = date(1);
LET dFechaCorte      = date(1);
LET dFechaCorte_pasada = date(1);
LET cEmpresa         = "001";
LET cArchivo_dbld    = "f_edocta.com";
LET cArchivo_log     = "f_edocta.log";
LET cod_ret          = "00000";
LET cArchivo2        = "";
LET cFecha_hoy       = "";
LET iCantRegs        = 0;
LET c_num_proceso    = '0410';
LET c_mensaje        = '';
LET error_info       = '';
LET vCod_ret         = '';
LET isam_err         = 0;

  set isolation to dirty read;
  set lock mode to wait 3;

  -- Fecha: 27/11/2014
  -- Autor: Marco A. Campos
  -- Descripción: Cargar ciertos campos de estados de cuenta de un archivo .unl en la tabla sd_info_edoscta para ser utilizada en sp_rep_regulatorios_irb_compl 

--SET DEBUG FILE TO '/RESPALDOS/ipcb/pruebas/latinia/sp_carga_info_edocta.out';
--TRACE ON;
 
BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            LET c_mensaje = error_info;

			     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, c_num_proceso, cod_ret, c_mensaje, '02')
            RETURNING vCod_ret;

            RETURN TRIM(cod_ret);
        END IF
   END EXCEPTION;

   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, c_num_proceso, cod_ret, c_mensaje, '01')
         RETURNING vCod_ret;
  
   
   -- /RESPALDOS/infoedocta/   PROD 
   -- /respaldos/infoedocta/   Test   
   SELECT TRIM(valor) INTO v_ruta FROM bdicred:"informix".sd_param WHERE empresa = cEmpresa AND cod_param = '039';

  
   SELECT fecha_hoy INTO dFecha_hoy
     FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';

--Temporal solo para pruebas
	--let dFecha_hoy = today-1 units month;
--let dFecha_hoy = mdy('10','20','2017'); 
--Temporal solo para pruebas

   LET dFechaCorte = lpad(MONTH(dFecha_hoy),2,0) ||  '/20/' || YEAR(dFecha_hoy) ;
   IF MONTH(dFecha_hoy) = 1 then
      LET dFechaCorte_pasada = lpad(MONTH(dFecha_hoy-1 units month),2,0) || '/20/' || YEAR(dFecha_hoy-1 units year);
   ELSE
      LET dFechaCorte_pasada = lpad(MONTH(dFecha_hoy-1 units month),2,0) || '/20/' || YEAR(dFecha_hoy) ;
   END IF;
   
   --- Calcular cuántos registros hay de la fecha de corte actual.
   SELECT count(*) INTO iCantRegs
     FROM bdicred@pld_tcp:"informix".sd_encabezado2_edocta    
--     FROM bdicred:"informix".sd_encabezado2_edocta    --Pruebas
    WHERE fecha_emision = dFechaCorte;
   
    
   system ' echo "FILE ' ||  TRIM(v_ruta) || 'edocta_muestra.unl DELIMITER ' || "'" || '|' || "'" || ' 23;' || '">' || TRIM(v_ruta) || TRIM(cArchivo_dbld);  
   system ' echo "INSERT INTO sd_info_edocta;' || '">>' || TRIM(v_ruta) || TRIM(cArchivo_dbld);
   system 'chmod 777 ' || TRIM(v_ruta) || TRIM(cArchivo_dbld);

   system ' echo "date ' || '">' || TRIM(v_ruta) || 'dbload_edocta.sh';
   system ' echo "nice -n 30 dbload -d bdicred -c ' || TRIM(v_ruta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(v_ruta) || TRIM(cArchivo_log) || ' -e ' || iCantRegs ||' -n 1000 -k ' || ' " >> ' || TRIM(v_ruta)|| 'dbload_edocta.sh'; 
   system ' echo "date ' || '">>' || TRIM(v_ruta)|| 'dbload_edocta.sh';
   system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(v_ruta)|| 'dbload_edocta.sh';             
   system ' echo "set pdqpriority 0;' || '">>' || TRIM(v_ruta)|| 'dbload_edocta.sh';          
   system ' echo "update statistics medium for table sd_info_edocta; ' || '">>' || TRIM(v_ruta)|| 'dbload_edocta.sh';           
   system ' echo "EOF' || '">>' || TRIM(v_ruta)|| 'dbload_edocta.sh';           
   system 'chmod 777 ' || TRIM(v_ruta)|| 'dbload_edocta.sh';
   system '/usr/bin/sh ' || TRIM(v_ruta)|| 'dbload_edocta.sh';      
   
  
  -- Sí se respaldó correctamente el archivo, borrar de sd_info_edocta lo que exista menor a la fecha de corte pasada.  
  LET iCantRegs = 0;
  SELECT count(*) INTO iCantRegs
    FROM bdicred:"informix".sd_info_edocta
   WHERE fecha_emision < dFechaCorte_pasada;
   
   IF iCantRegs > 0 THEN
      BEGIN;
          DELETE bdicred:"informix".sd_info_edocta
           WHERE fecha_emision < dFechaCorte_pasada;
      COMMIT;
   END IF;
   
   UPDATE statistics medium for table bdicred:"informix".sd_info_edocta;         

   LET cFecha_hoy = year(dFecha_hoy) || lpad(month(dFecha_hoy),2,0) || lpad(day(dFecha_hoy),2,0);
   LET cArchivo2 = 'edocta_muestra_' || cFecha_hoy || '.unl';

   system 'mv ' || trim(v_ruta) || 'edocta_muestra.unl' || ' ' || trim(v_ruta) ||  trim(cArchivo2);
   system 'gzip ' || trim(v_ruta) || trim(cArchivo2);      


  END;

  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, c_num_proceso,'', '','03' ) RETURNING vCod_ret;
  
  RETURN trim(cod_ret);

END PROCEDURE;