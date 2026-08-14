CREATE PROCEDURE "informix".sp_mc_cal_tri_d(cTrimestre CHAR(5),iMes INTEGER)
       RETURNING CHAR (5), CHAR(500);

/*
#####################################################################################
#                                                                                   #
#Cálculo Trimestral Producto Débito 559471       								    #
#####################################################################################
*/

--- GENERALES
DEFINE cCodFila                  CHAR(8);
DEFINE iSqlErr                   INTEGER;
DEFINE cVarDataErr               CHAR(500);
DEFINE cVarDataErr1              CHAR(100);
DEFINE cVarDataErr2              CHAR(100);
DEFINE cVarDataErr3              CHAR(100);
DEFINE cVarDataErr4              CHAR(100);
DEFINE cVarDataErr5              CHAR(100);
DEFINE cVarDataErr6              CHAR(100);
DEFINE cVarDataErr7              CHAR(100);
DEFINE cVarDataErr8              CHAR(100);
DEFINE cCodret                   CHAR(5);
DEFINE cProducto                 CHAR(4);
DEFINE cTipoCompra               VARCHAR(60);
DEFINE cTipoTransaccion          VARCHAR(60);
DEFINE cTipoDevolucion           VARCHAR(60);

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
DEFINE total_transacc_atm_deb	 INTEGER;
DEFINE total_monto_atm_deb	     MONEY(16,2);

--- DEVOLUCIONES
DEFINE acum_tot_dev_nal          INTEGER;
DEFINE acum_mon_dev_nal          MONEY(16,2);
DEFINE acum_tot_dev_internal     INTEGER;
DEFINE acum_mon_dev_internal     MONEY(16,2);

DEFINE Vtipo                     CHAR(01);
DEFINE cDiasPendientes           SMALLINT;
DEFINE dFecha                    DATE;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
DEFINE Vbin 					  CHAR(6); 
DEFINE Vclavetarjeta 			  SMALLINT;

  ON EXCEPTION SET iSqlErr

        SET DEBUG FILE TO "/respaldos/sp_mc_cal_tri_d.err";
        LET cVarDataErr = ' ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
        LET cCodret = '-1';
        INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                      ultima_actualizacion,
                                                      estatus_actualizacion,
                                                      dias_pendientes,
                                                      ultimo_error)
            VALUES ( 'sp_mc_cal_tri_D', iMes, TODAY,'', 0 , cVarDataErr);
        RETURN cCodret, cVarDataErr;

  END EXCEPTION;

  
  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO "/informix/ilopez/MASTERCARD/sp_mc_cal_tri_d.out";
--TRACE ON;


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
LET total_transacc_atm_deb = 0;
LET total_monto_atm_deb	= 0.0;

-- VARIABLES DE DEVOLUCIONES
LET acum_tot_dev_nal = 0;
LET acum_mon_dev_nal = 0.0;
LET acum_tot_dev_internal = 0;
LET acum_mon_dev_internal = 0.0;
LET dFecha = TODAY;

---Set debug file to "sp_mc_cal_tri_d.out";
---trace on;

LET cCodret = '00000';
LET cVarDataErr = ' ';
LET cVarDataErr1 = '';
LET cVarDataErr2 = '';
LET cVarDataErr3 = '';
LET cVarDataErr4 = '';
LET cVarDataErr5 = '';
LET cVarDataErr6 = '';
LET cVarDataErr7 = '';
LET cVarDataErr8 = '';
LET Vtipo = '';
LET cDiasPendientes = 0;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
LET Vclavetarjeta = 8;

--SET DEBUG FILE TO "/tmp/mfinis/sp_mc_cal_tri_d.out";
--TRACE ON;

--- ACUMULADO MENSUAL DE LAS COMPRAS NACIONALES DÉBITO ---
--------------------------------------------------------------
---- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES
---- DENTRO DEL PAÍS EN OTROS POS ----
--------------------------------------------------------------

--- SELECCION DEL PRODUCTO DE LA TABLA DE PARAMETROS ---
--- NOTA: PARA TODOS LOS CONCEPTOS SE QUEDA EL MISMO  NUM_PRODUCTO ---
--SET ISOLATION TO DIRTY READ;
SELECT {+AVOID_FULL (bdireports:rpt_mc_param)} tipo
  INTO Vtipo
  FROM bdireports:rpt_mc_param
 WHERE tipo = 'D'
   AND marca = 'MC'
 GROUP BY tipo;

IF Vtipo IS NOT NULL THEN
   LET cProducto = '2400';
END IF;

------------------------------------
--- CONSULTA EL TIPO DE PRODUCTO ---
------------------------------------
--- DONDE EL BIN 559471 HACE REFERENCIA A TARJETAS DE DÉBITO ---

--SET ISOLATION TO DIRTY READ;
SELECT bin
INTO Vbin
FROM intercard:tipotarjeta
WHERE clave_tipotarjeta = Vclavetarjeta;

LET cCodFila = 'CND';
LET cTipoCompra = 'COMPRAS NACIONALES EN OTROS POS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_compras = cTipoCompra) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_compras), 0), NVL(SUM(monto_compras), 0)
     INTO acum_tot_compras, acum_mon_compras
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      ---AND mes = iMes
      AND tipo_compras = cTipoCompra;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre,
                                          id_col, mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, acum_tot_compras,
               acum_mon_compras, cTipoCompra, 0, 0, 0, 0, 0, 0);

   IF acum_tot_compras = 0 AND acum_mon_compras = 0.00 THEN
      LET cCodret = '00002';
      LET cVarDataErr2 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr2);

   END IF;

   IF acum_tot_compras <> 0 AND acum_mon_compras <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr2 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'||trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00002';
   LET cVarDataErr8 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
    VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr2);
END IF;


-------------------------------------------------------------------------
---- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ----
-------------------------------------------------------------------------
LET cCodFila = 'CID';
LET cTipoCompra = 'COMPRAS INTERNACIONALES DEBITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_compras = cTipoCompra) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_compras), 0), NVL(SUM(monto_compras), 0)
     INTO acum_tot_compras_i, acum_mon_compras_i
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      ---AND mes = iMes
      AND tipo_compras = cTipoCompra;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre,
                                          id_col, mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, acum_tot_compras_i,
               acum_mon_compras_i, cTipoCompra, 0, 0, 0, 0, 0, 0);

   IF acum_tot_compras_i = 0 AND acum_mon_compras_i = 0.00 THEN
      LET cCodret = '00003';
      LET cVarDataErr3 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr3);

   END IF;

   IF  acum_tot_compras_i <> 0 AND acum_mon_compras_i <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr3 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00003';
   LET cVarDataErr3 = '.DATOS DUPLICADOS:'|| trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr3);
END IF;

--------------------------------------------
---- TRANSACCIONES DE EFECTIVO EN ATM's ----
--------------------------------------------
---- MIS CLIENTES EN MIS BANCOS ------------
--------------------------------------------
LET cCodFila = 'TED';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO PROPIO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   --AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones), 0), NVL(SUM(monto_transacciones), 0)
     INTO acum_tot_transacc_mis, acum_mon_transacc_mis
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
     --- AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;
	

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col,
                                          mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0,
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
      LET cCodret = '00004';
      LET cVarDataErr4 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00004';
   LET cVarDataErr4 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                        trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr4);
END IF;


------------------------------------------------------------------------------
---- TRANSACCIONES DE DISPOSICIÓN DE EFECTIVO DE MIS TARJETAHABIENTES ----
---- DENTRO DEL PAÍS EN ATM's DE OTROS BANCOS ----
------------------------------------------------------------------------------
LET cCodFila = 'TED';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO NO PROPIO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

	
	--SET ISOLATION TO DIRTY READ;
	
	select NVL(SUM(total_transacciones),0),NVL(SUM(monto_transacciones) ,0)
	INTO acum_tot_transacc_nop, acum_mon_transacc_nop 
	FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      AND tipo_transaccion = cTipoTransaccion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col,
                                          mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0,
               acum_tot_transacc_nop,acum_mon_transacc_nop , cTipoTransaccion, 0, 0, 0);
	
	
	
	
	

   IF acum_tot_transacc_nop = 0 AND acum_mon_transacc_nop = 0.00 THEN
      LET cCodret = '00005';
      LET cVarDataErr5 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr5);
   END IF;

   IF acum_tot_transacc_nop <> 0 AND acum_mon_transacc_nop <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr5 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00005';
   LET cVarDataErr5 = '.DATOS DUPLICADOS:'|| trim(cCodFila)|| ','||
                        trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr5);
END IF;

-------------------------------------------------------
---- TRANSACCIONES DE DISPOSICIÓN DE EFECTIVO DE ----
---- MIS TARJETAHABIENTES FUERA DEL PAÍS ----
-------------------------------------------------------
LET cCodFila = 'TED';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO INTERNACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones), 0), NVL(SUM(monto_transacciones), 0)
     INTO acum_tot_transacc_int, acum_mon_transacc_int
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      ---AND mes = iMes
      AND tipo_transaccion = cTipoTransaccion;
	

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col, mes,
                                          total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0,
               acum_tot_transacc_int, acum_mon_transacc_int,
               cTipoTransaccion, 0, 0, 0);

   IF acum_tot_transacc_int = 0 AND acum_mon_transacc_int = 0.00 THEN
      LET cCodret = '00006';
      LET cVarDataErr6 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr6);
   END IF;

   IF acum_tot_transacc_int <> 0 AND acum_mon_transacc_int <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr2 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00006';
   LET cVarDataErr6 = '.DATOS DUPLICADOS:'|| trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr6);
END IF;

-------------------------------------------------------------------------------
------SUMATORIA DE ATM'S --DISPOSICIÓN DE EFECTIVO-----------------------------
LET cCodFila = 'TED';
LET cTipoTransaccion = 'ATM CAJEROS AUTOMATICOS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_transaccion = cTipoTransaccion) THEN


--SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_transacciones), 0), NVL(SUM(monto_transacciones), 0)
   INTO total_transacc_atm_deb,total_monto_atm_deb 
   FROM bdireports:'informix'.rpt_mc_vol_tri
		WHERE num_producto = cProducto
				AND trimestre = cTrimestre
				AND id_col = 'TED'
				AND  tipo_transaccion IN('ATM TRANSACCION EFECTIVO PROPIO','ATM DOMESTICO OTROS BANCOS','ATM TRANSACCION EFECTIVO NO PROPIO','ATM TRANSACCION EFECTIVO INTERNACIONAL');

	
 --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col, mes,
                                          total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0,
               total_transacc_atm_deb, total_monto_atm_deb,
               cTipoTransaccion, 0, 0, 0);

   IF acum_tot_transacc_int = 0 AND acum_mon_transacc_int = 0.00 THEN
      LET cCodret = '00006';
      LET cVarDataErr6 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr6);
   END IF;

   IF total_transacc_atm_deb <> 0 AND total_monto_atm_deb <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr2 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00006';
   LET cVarDataErr6 = '.DATOS DUPLICADOS:'|| trim(cCodFila)|| ','||
                       trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr6);
END IF;

-------------------------------------------------------------------
---- TRANSACCIONES DE DEVOLUCIONES / DÉBITO EN COMPRAS DE MIS
---- TARJETAHABIENTES DENTRO DEL PAÍS ----
-------------------------------------------------------------------

LET cCodFila = 'DND';
LET cTipoDevolucion = 'DEVOLUCION NACIONAL DEBITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_devolucion = cTipoDevolucion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_devolucion), 0), NVL(SUM(monto_devolucion), 0)
     INTO acum_tot_dev_nal, acum_mon_dev_nal
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      ---AND mes = iMes
      AND tipo_devolucion = cTipoDevolucion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col, mes,
                                          total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0, 0, 0, 0,
               acum_tot_dev_nal, acum_mon_dev_nal, cTipoDevolucion);

   IF acum_tot_dev_nal = 0 AND acum_mon_dev_nal = 0.00 THEN
      LET cCodret = '00007';
      LET cVarDataErr7 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr7);
   END IF;

   IF acum_tot_dev_nal <> 0 AND acum_mon_dev_nal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr7 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00007';
   LET cVarDataErr7 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                        trim(cProducto)||','|| iMes ||'.';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes, ultimo_error)
       VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr7);
END IF;


--------------------------------------------------------------------------------
---- TRANSACCIONES DE DEVOLUCIONES / DÉBITO EN COMPRAS
---- DE MIS TARJETAHABIENTES FUERA DEL PAÍS ----
--------------------------------------------------------------------------------

LET cCodFila = 'DID';
LET cTipoDevolucion = 'DEVOLUCION INTERNACIONAL DEBITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_tri
                 WHERE trimestre = cTrimestre
                   AND num_producto = cProducto
                   AND id_col = cCodFila
                   ---AND mes = iMes
                   AND tipo_devolucion = cTipoDevolucion) THEN

   --SET ISOLATION TO DIRTY READ;
   SELECT NVL(SUM(total_devolucion), 0), NVL(SUM(monto_devolucion), 0)
     INTO acum_tot_dev_internal, acum_mon_dev_internal
     FROM bdireports:rpt_mc_vol_men
    WHERE trimestre = cTrimestre
      AND num_producto = cProducto
      AND id_col = cCodFila
      ---AND mes = iMes
      AND tipo_devolucion = cTipoDevolucion;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_tri (num_producto, trimestre, id_col,
                                          mes, total_compras,
                                          monto_compras, tipo_compras,
                                          total_transacciones,
                                          monto_transacciones, tipo_transaccion,
                                          total_devolucion, monto_devolucion,
                                          tipo_devolucion)
        VALUES(cProducto, cTrimestre, cCodFila, 0, 0, 0, 0, 0, 0, 0,
               acum_tot_dev_internal, acum_mon_dev_internal, cTipoDevolucion);

   IF acum_tot_dev_internal = 0 AND acum_mon_dev_internal = 0.00 THEN
      LET cCodret = '00008';
      LET cVarDataErr8 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,ultimo_error)
           VALUES ( 'sp_mc_cal_tri_D',iMes,dFecha,'', cDiasPendientes ,cCodret||cVarDataErr8);
   END IF;

   IF acum_tot_dev_internal <> 0 AND acum_mon_dev_internal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr8 = 'REGISTRO EXITOSO EN rpt_mc_vol_tri.'|| trim(cCodFila)|| ','||
                          trim(cProducto)||','|| dFecha ||'. ';
   END IF;
ELSE
   LET cCodret = '00008';
   LET cVarDataErr8 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                      trim(cProducto)||','|| iMes ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ('sp_mc_cal_tri_D', iMes, TODAY, '' , 0 ,cCodret||cVarDataErr8);
END IF;

LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr2)||trim(cVarDataErr3)||
                  trim(cVarDataErr4)||trim(cVarDataErr5)||trim(cVarDataErr6)||
                  trim(cVarDataErr7)||trim(cVarDataErr8);

RETURN cCodret,cVarDataErr;

END PROCEDURE;