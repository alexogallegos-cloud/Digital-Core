CREATE PROCEDURE "informix".sp_mc_cal_men_c_interno(cTrimestre CHAR(5),iMes INTEGER, iClaveTarjeta SMALLINT)
       RETURNING CHAR (5), CHAR(500);

/*
################################################################################
#   Calculo Mensual Productos Oro y Platino							           #
#      								                                           #
################################################################################
*/

--- GENERALES
DEFINE cCodret                   CHAR(5);
DEFINE cVarDataErr               CHAR(500);
DEFINE cCodFila                  CHAR(8);
DEFINE iSqlErr                   INTEGER;
DEFINE cVarDataErr1              CHAR(100);
DEFINE cVarDataErr4              CHAR(100);
DEFINE cVarDataErr5              CHAR(100);
DEFINE cVarDataErr6              CHAR(100);
DEFINE cVarDataErr9              CHAR(100);
DEFINE cVarDataErr10             CHAR(100);
DEFINE cVarDataErr11             CHAR(100);
DEFINE cVarDataErr12             CHAR(100);
DEFINE cVarDataErr13             CHAR(100);
DEFINE cVarDataErr14             CHAR(100);
DEFINE cVarDataErr15             CHAR(100);
DEFINE cVarDataErr16             CHAR(100);
DEFINE cVarDataErr17             CHAR(100);
DEFINE cProducto                 CHAR(4);
DEFINE cTipoTransaccion          VARCHAR(60);
DEFINE cTipoCompra               VARCHAR(60);
DEFINE Vtipo                     CHAR(01);
DEFINE cTipoDevolucion           VARCHAR(60);

DEFINE cDiasPendientes           SMALLINT;
DEFINE dFecha                    DATE;
DEFINE cEstatus                  CHAR(01);

--- TRANSACCIONES DE COMPRAS ---
DEFINE acum_tot_compras          INTEGER;
DEFINE acum_mon_compras          MONEY(16,2);
DEFINE acum_tot_compras_i        INTEGER;
DEFINE acum_mon_compras_i        MONEY(16,2);

--- TRANSACCIONES EN EFECTIVO DE ATM's  ---
DEFINE acum_tot_transacc_mis     INTEGER;
DEFINE acum_mon_transacc_mis     MONEY(16,2);
DEFINE acum_tot_transacc_nop     INTEGER;
DEFINE acum_mon_transacc_nop     MONEY(16,2);
DEFINE acum_tot_transacc_int     INTEGER;
DEFINE acum_mon_transacc_int     MONEY(16,2);

--- DEVOLUCIONES
DEFINE acum_tot_dev_nal          INTEGER;
DEFINE acum_mon_dev_nal          MONEY(16,2);
DEFINE acum_tot_dev_internal     INTEGER;
DEFINE acum_mon_dev_internal     MONEY(16,2);

--- ADQUIRENCIA NACIONAL E INTERNACIONAL
DEFINE acum_tot_adq_nal          INTEGER;
DEFINE acum_mon_adq_nal          MONEY(16,2);
DEFINE acum_tot_adq_internal     INTEGER;
DEFINE acum_mon_adq_internal     MONEY(16,2);



DEFINE Vnom_tabla               CHAR(30);
DEFINE Vultimo_mes              INTEGER;
DEFINE Vultima_actualizacion    DATE;
DEFINE Vconsecutivo             SMALLINT;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO 
--DEFINE Vclavetarjeta 		    SMALLINT;

  ON EXCEPTION SET iSqlErr
	SET DEBUG FILE TO "/respaldos/sp_mc_cal_men_c_interno.err";
     LET cVarDataErr = ' ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
     LET cCodret = '-1';
     INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                   ultima_actualizacion,
                                                   estatus_actualizacion,
                                                   dias_pendientes,
                                                   ultimo_error)
          VALUES ( 'sp_mc_cal_men_c',iMes,TODAY,'', 0 ,cVarDataErr);
     RETURN cCodret, cVarDataErr;

  END EXCEPTION;
  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- VARIABLES DE COMPRAS
LET acum_tot_compras = 0;
LET acum_mon_compras = 0.0;
LET acum_tot_compras_i = 0;
LET acum_mon_compras_i = 0.0;

-- VARIABLES DE TRANSACCIONES
LET acum_tot_transacc_mis = 0;
LET acum_mon_transacc_mis = 0.0;
LET acum_tot_transacc_nop = 0;
LET acum_mon_transacc_nop = 0.0;
LET acum_tot_transacc_int = 0;
LET acum_mon_transacc_int = 0.0;

-- VARIABLES DE DEVOLUCIONES
LET acum_tot_dev_nal = 0;
LET acum_mon_dev_nal = 0.0;
LET acum_tot_dev_internal = 0;
LET acum_mon_dev_internal = 0.0;

-- VARIABLES DE ADQUIRENCIA
LET acum_tot_adq_nal = 0;
LET acum_mon_adq_nal = 0.0;
LET acum_tot_adq_internal = 0;
LET acum_mon_adq_internal = 0.0;

LET cCodret = '00000';
LET cVarDataErr = ' ';
LET cVarDataErr1 = '';
LET cVarDataErr9 = '';
LET cVarDataErr10 = '';
LET cVarDataErr11 = '';
LET cVarDataErr12 = '';
LET cVarDataErr13 = '';
LET cVarDataErr14 = '';
LET cVarDataErr15 = '';
LET cVarDataErr16 = '';
LET cVarDataErr17 = '';

LET Vtipo = '';
LET cDiasPendientes = 0;
LET dFecha = TODAY;
LET cEstatus = '';

LET Vnom_tabla = '';
LET Vultima_actualizacion = '';
LET Vultimo_mes = 0;
LET Vconsecutivo = 0;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
--LET Vclavetarjeta = 9;


--SET DEBUG FILE TO "/ifxsif01/ilopez/Pruebas_SP/sp_mc_cal_men_c_interno.out";
--TRACE ON;

--- ACUMULADO MENSUAL DE LAS COMPRAS NACIONALES CRÉDITO ---
-------------------------------------------------------------------------------
---- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES DENTRO 
---- DEL PAÍS EN OTROS POS ----
-------------------------------------------------------------------------------

--- SELECCION DEL PRODUCTO DE LA TABLA DE PARAMETROS ---
--- NOTA: PARA TODOS LOS CONCEPTOS SE QUEDA EL MISMO  NUM_PRODUCTO ---
--SET ISOLATION TO DIRTY READ;
SELECT tipo
  INTO Vtipo
  FROM bdireports:rpt_mc_param
 WHERE tipo = 'C'
   AND marca = 'MC'
 GROUP BY tipo;

IF Vtipo IS NOT NULL THEN
   --LET cProducto = '7000';
   
   --SET ISOLATION TO DIRTY READ;
   SELECT valor
   INTO cProducto
   FROM bdireports:rpt_mc_param
   WHERE tipo = 'C'
   AND marca = 'MC'
   AND id_param = (CASE WHEN iClaveTarjeta = 9 THEN 2 WHEN iClaveTarjeta = 10 THEN 4 END);
END IF;

LET cCodFila = 'CNC';
LET cTipoCompra = 'COMPRAS NACIONALES EN OTROS POS';

-----------------------------------------
--- COMPRAS NACIONALES EN OTROS POS ----
-----------------------------------------

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_compras = cTipoCompra) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_compras), 0), NVL(SUM(monto_compras), 0)
     INTO acum_tot_compras, acum_mon_compras
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_compras = cTipoCompra;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras,
                                          tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, acum_tot_compras,
               acum_mon_compras, cTipoCompra, 0, 0, 0, 0, 0, 0);

   IF acum_tot_compras = 0 AND acum_mon_compras = 0.00 THEN
      LET cCodret = '00009';
      LET cVarDataErr9 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, 
                    cDiasPendientes ,cCodret||cVarDataErr9);
   END IF;

   IF acum_tot_compras <> 0 AND acum_mon_compras <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr9 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                          trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00010';
   LET cEstatus = 'C';
   LET cVarDataErr9 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                         trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0 ,cCodret||cVarDataErr9);
END IF;


-------------------------------------------------------------------------
---- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ----
-------------------------------------------------------------------------
LET cCodFila = 'CIC';
LET cTipoCompra = 'COMPRAS INTERNACIONALES CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_compras = cTipoCompra) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_compras), 0), NVL( SUM(monto_compras), 0)
     INTO acum_tot_compras_i, acum_mon_compras_i
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_compras = cTipoCompra;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras,
                                          tipo_compras,
                                          total_transacciones,
                                          monto_transacciones,
                                          tipo_transaccion, total_devolucion,
                                          monto_devolucion, tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, acum_tot_compras_i,
      acum_mon_compras_i, cTipoCompra, 0, 0, 0, 0, 0, 0);

   IF acum_tot_compras_i = 0 AND acum_mon_compras_i = 0.00 THEN
      LET cCodret = '00010';
      LET cVarDataErr10 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, cDiasPendientes,
                     cCodret||cVarDataErr10);
   END IF;

   IF acum_tot_compras_i <> 0 AND acum_mon_compras_i <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr10 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00010';
   LET cEstatus = 'C';
   LET cVarDataErr10 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
                 cCodret||cVarDataErr10);
END IF;


---- TRANSACCIONES DE EFECTIVO EN ATM's ----
------------------------------------
---- MIS CLIENTES EN MIS BANCOS ----
------------------------------------
LET cCodFila = 'TEC';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO PROPIO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

--SET ISOLATION TO DIRTY READ;
	
	select NVL(SUM(total_transacciones),0),NVL(SUM(monto_transacciones) ,0)
	INTO acum_tot_transacc_mis,acum_mon_transacc_mis
	FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col,
                                          mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0,
               acum_tot_transacc_mis, acum_mon_transacc_mis, cTipoTransaccion, 0, 0, 0);
			   
			   

	IF acum_tot_transacc_mis = 0 AND acum_mon_transacc_mis = 0.00 THEN
      LET cCodret = '00004';
      LET cVarDataErr4 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr4);
   END IF;

   IF acum_tot_transacc_mis <> 0 AND acum_mon_transacc_mis <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr4 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00005';
   LET cVarDataErr4 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                        trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr4);
END IF;


--------------------------------------------------------------------------------
---- TRANSACCIONES DE DISPOSICIÓN DE EFECTIVO DE MIS TARJETAHABIENTES
----DENTRO DEL PAÍS EN ATM's DE OTROS BANCOS ----
--------------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO NO PROPIO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones),0), NVL(SUM(monto_transacciones), 0)
     INTO acum_tot_transacc_nop, acum_mon_transacc_nop
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col,
                                          mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
       VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0,
              acum_tot_transacc_nop, acum_mon_transacc_nop, cTipoTransaccion,
              0, 0, 0);

   IF acum_tot_transacc_nop = 0 AND acum_mon_transacc_nop = 0.00 THEN
      LET cCodret = '00004';
      LET cVarDataErr12 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, cDiasPendientes,
                     cCodret||cVarDataErr12);
   END IF;

   IF acum_tot_transacc_nop <> 0 AND acum_mon_transacc_nop <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr12 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00005';
   LET cEstatus = 'C';
   LET cVarDataErr12 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
                 cCodret||cVarDataErr12);
END IF;


--------------------------------------------------------------------------------
---- TRANSACCIONES DE DISPOSICIÓN DE EFECTIVO DE MIS TARJETAHABIENTES 
---- FUERA DEL PAÍS ----
-------------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO INTERNACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT SUM(total_transacciones), SUM(monto_transacciones)
     INTO acum_tot_transacc_int, acum_mon_transacc_int
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras, 
                                          tipo_compras,
                                          total_transacciones, 
                                          monto_transacciones,
                                          tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0,
               acum_tot_transacc_int, acum_mon_transacc_int, 
               cTipoTransaccion, 0, 0, 0);

   IF acum_tot_transacc_int = 0 AND acum_mon_transacc_int = 0.00 THEN
      LET cCodret = '00004';
      LET cVarDataErr13 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
      VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, cDiasPendientes,
                cCodret||cVarDataErr13);
   END IF;

   IF acum_tot_transacc_int <> 0 AND acum_mon_transacc_int <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr13 = 'REGISTRO EXITOSO rpt_mc_vol_men';
   END IF;
ELSE
   LET cCodret = '00005';
   LET cEstatus = 'C';
   LET cVarDataErr13 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus, 0,
                 cCodret||cVarDataErr13);
END IF;


-------------------------------------------------------------------------------
---- TRANSACCIONES DE DEVOLUCIONES / CRÉDITO EN COMPRAS
---- DE MIS TARJETAHABIENTES DENTRO DEL PAÍS ----
-------------------------------------------------------------------------------

LET cCodFila = 'DNC';
LET cTipoDevolucion = 'DEVOLUCION NACIONAL CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_devolucion = cTipoDevolucion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_devolucion),0), NVL(SUM(monto_devolucion), 0)
     INTO acum_tot_dev_nal, acum_mon_dev_nal
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_devolucion = cTipoDevolucion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras, 
                                          tipo_compras,
                                          total_transacciones, 
                                          monto_transacciones,
                                          tipo_transaccion,
                                          total_devolucion, monto_devolucion, 
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0, 0, 0, 0, 
               acum_tot_dev_nal, acum_mon_dev_nal, cTipoDevolucion);

   IF acum_tot_dev_nal = 0 AND acum_mon_dev_nal = 0.00 THEN
      LET cCodret = '00014';
      LET cVarDataErr14 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_dia_C',iMes,dFecha,cEstatus, 
                     cDiasPendientes ,cCodret||cVarDataErr14);
   END IF;

   IF acum_tot_dev_nal <> 0 AND acum_mon_dev_nal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr14 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00015';
   LET cEstatus = 'C';
   LET cVarDataErr14 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                         trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
                 cCodret||cVarDataErr14);
END IF;


-------------------------------------------------------------------------------
---- TRANSACCIONES DE DEVOLUCIONES / CRÉDITO EN COMPRAS
---- DE MIS TARJETAHABIENTES FUERA DEL PAÍS ----
-------------------------------------------------------------------------------

LET cCodFila = 'DIC';
LET cTipoDevolucion = 'DEVOLUCION INTERNACIONAL CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_devolucion = cTipoDevolucion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_devolucion), 0), NVL(SUM(monto_devolucion), 0)
     INTO acum_tot_dev_internal, acum_mon_dev_internal
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_devolucion = cTipoDevolucion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras, 
                                          tipo_compras,
                                          total_transacciones,
                                          monto_transacciones,
                                          tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0, 0, 0, 0, 
               acum_tot_dev_internal, acum_mon_dev_internal, cTipoDevolucion);

   IF acum_tot_dev_internal = 0 AND acum_mon_dev_internal = 0.00 THEN
      LET cCodret = '00015';
      LET cVarDataErr15 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, cDiasPendientes,
                     cCodret||cVarDataErr15);
   END IF;

   IF acum_tot_dev_internal <> 0 AND acum_mon_dev_internal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr15 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00015';
   LET cEstatus = 'C';
   LET cVarDataErr15 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
                 cCodret||cVarDataErr15);
END IF;

IF iClaveTarjeta = 9 THEN
-----------------------------------------------
-----------------------------------------------
---- TRANSACCIONES DE ADQUIRENCIA NACIONAL ----
-----------------------------------------------
-----------------------------------------------

LET cProducto = '9999';
LET cCodFila = 'ADN';
LET cTipoTransaccion = 'ATM ADQUIRENTE NACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones),0), NVL(SUM(monto_transacciones), 0)
     INTO acum_tot_adq_nal, acum_mon_adq_nal
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras, 
                                          tipo_compras,
                                          total_transacciones, 
                                          monto_transacciones,
                                          tipo_transaccion,
                                          total_devolucion,
                                          monto_devolucion, tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0, acum_tot_adq_nal,
               acum_mon_adq_nal, cTipoTransaccion, 0, 0, 0);

   IF acum_tot_adq_nal = 0 AND acum_mon_adq_nal = 0.00 THEN
      LET cCodret = '00016';
      LET cVarDataErr16 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, 
                     cDiasPendientes ,cCodret||cVarDataErr16);
   END IF;

   IF acum_tot_adq_nal <> 0 AND acum_mon_adq_nal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr16 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00016';
   LET cEstatus = 'C';
   LET cVarDataErr16 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
                 cCodret||cVarDataErr16);
END IF;


----------------------------------------------------
----------------------------------------------------
---- TRANSACCIONES DE ADQUIRENCIA INTERNACIONAL ----
----------------------------------------------------
----------------------------------------------------

LET cCodFila = 'ADI';
LET cTipoTransaccion = 'ATM ADQUIRENTE INTERNACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_men
 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
   AND id_col = cCodFila
   AND mes = iMes
   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones),0), NVL(SUM(monto_transacciones), 0)
     INTO acum_tot_adq_internal, acum_mon_adq_internal
     FROM bdireports:rpt_mc_vol_dia
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_men (num_producto, trimestre, id_col, mes,
                                          total_compras, monto_compras, 
                                          tipo_compras,
                                          total_transacciones, 
                                          monto_transacciones, 
                                          tipo_transaccion,
                                          total_devolucion, 
                                          monto_devolucion, tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, iMes, 0, 0, 0, 
               acum_tot_adq_internal,
               acum_mon_adq_internal, cTipoTransaccion, 0, 0, 0);

   IF acum_tot_adq_nal = 0 AND acum_mon_adq_nal = 0.00 THEN
      LET cCodret = '00017';
      LET cVarDataErr17 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
           VALUES ( 'sp_mc_cal_men_c',iMes,dFecha,cEstatus, 
                     cDiasPendientes ,cCodret||cVarDataErr17);

   END IF;

   IF acum_tot_adq_nal <> 0 AND acum_mon_adq_nal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr17 = 'REGISTRO EXITOSO EN rpt_mc_vol_men.'|| 
                           trim(cCodFila)|| ','||
                           trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00017';
   LET cEstatus = 'C';
   LET cVarDataErr17 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
    VALUES ('sp_mc_cal_men_c', iMes, TODAY, cEstatus , 0,
             cCodret||cVarDataErr17);
END IF;
END IF;

LET cVarDataErr = trim(cVarDataErr)||trim(cVarDataErr1)||trim(cVarDataErr9)||
                  trim(cVarDataErr10)|| trim(cVarDataErr11)||
                  trim(cVarDataErr12)||trim(cVarDataErr13)||
                  trim(cVarDataErr14)||trim(cVarDataErr15)||
                  trim(cVarDataErr16)||trim(cVarDataErr17);

RETURN cCodret,cVarDataErr;

END PROCEDURE;