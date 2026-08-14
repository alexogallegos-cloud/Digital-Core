CREATE PROCEDURE "informix".sp_actualizastatuscred(pEmpresa CHAR(3), pNumCredito CHAR(20))
   RETURNING CHAR(6),    -- CÃ³digo de Retorno
             CHAR (120); -- Mensaje de Retorno

-- Autor: David Uriel Prieto Hurtado
-- Fecha de ModificaciÃ³n 01/06/2009
-- Observaciones: Se realiza  procedimiento para realizar la actualizacion del estatus de credito de acuerdo al cuadre de credito proporcionado.

--Fecha: 16/07/2009
--Modicacion: Se permitio que el status "BT" pueda o no tener interes vigente e iva de interes vigente
--Autor: Roque Enrique Solis C.


-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE sql_err                SMALLINT;
DEFINE iIsamErr               SMALLINT;
DEFINE cErrorInfo             CHAR(40);
DEFINE iSqlErr                INTEGER;

DEFINE cCodRet                CHAR(6);
DEFINE cMensajeRet            CHAR (120);

DEFINE cNumcte                CHAR(20);
DEFINE cSucursal              CHAR(4);
DEFINE cStatusCred            CHAR(2);
DEFINE iPlazo                 INTEGER;
DEFINE dtFechaAper            DATE;
DEFINE dtFechaVenc            DATE;
DEFINE dTasaInteres           DECIMAL(9,6);
DEFINE dTasaMoratorios        DECIMAL(9,6);
DEFINE dSdoRetenido           DECIMAL(18,2);
DEFINE dSdoNoExig             DECIMAL(18,2);
DEFINE dSdoContabMora         DECIMAL(18,2);
DEFINE dSdoCapital            DECIMAL(18,2);
DEFINE dSdoCapInsoluto        DECIMAL(18,2);
DEFINE dSdoMtoVdo             DECIMAL(18,2);
DEFINE dMtoVdoTrasp           DECIMAL(18,2);
DEFINE dMtoFinanciado         DECIMAL(18,2);
DEFINE dMtoOtorgado           DECIMAL(18,2);
DEFINE dCapTrasNoVdo          DECIMAL(18,2);
DEFINE dMtoVdoInt             DECIMAL(18,2);
DEFINE dMtoVdoTrasInt         DECIMAL(18,2);
DEFINE dIntTraNoExig          DECIMAL(18,2);
DEFINE cDescTpoCart           CHAR(60);
DEFINE cCodTpoCred            CHAR(2);
DEFINE dPorcIva               DECIMAL(5,3);
DEFINE dMoratorio             DECIMAL(18,2);
DEFINE dIvaMoratorio          DECIMAL(18,2);
DEFINE dIvaIntVenc            DECIMAL(18,2);
DEFINE dInteresMes            DECIMAL(18,2);
DEFINE dIvaMes                DECIMAL(18,2);
DEFINE dTotalLiquidacion      DECIMAL(18,2);
DEFINE dIntMoraCope           DECIMAL(18,2);
DEFINE dIvaIntMoraCope        DECIMAL(18,2);
DEFINE dIntMoraBase           DECIMAL(18,2);
DEFINE dIvaIntMoraBase        DECIMAL(18,2);
DEFINE dIvaIntMoraCopeBase    DECIMAL(18,2);
DEFINE dCapitalTotal          DECIMAL(18,2);
DEFINE dIntVig                DECIMAL(18,2);
DEFINE dIvaIntVig             DECIMAL(18,2);
DEFINE cStatusCredNew         CHAR(2);
--Actualizacion para nuevas etapas
DEFINE vFechaHoy              DATE;
DEFINE UltimaFechaVigente     DATE;
DEFINE UltimaFechaVigente_old DATE;
DEFINE vAct                   INTEGER;
DEFINE vAct_aux               INTEGER;


-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************
   LET  iSqlErr = 0;
   BEGIN
   ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet  = SQL_ERR;
	  LET cMensajeRet = "OcurriÃ³ error en el procedimiento (sp_actualizastatuscred): " || cErrorInfo ;
      RETURN cCodRet,cMensajeRet;
   END EXCEPTION;

--SET DEBUG FILE TO "/ifxsif01/aldo/etapas/sp_actualizastatuscred.out"; 
--TRACE ON;

--Modificacion: Se cambio validacion para vencido para que exiga el capital vencido
--Auoto: Roque Enrique Solis
--Fecha 18/08/2009
-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************
LET sql_err                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET iSqlErr                = 0;

LET cCodRet                = "000000";
LET cMensajeRet            = "Se actualizÃ¡ status del crÃ©dito correctamente";

LET cNumcte                = "";
LET cSucursal              = "";
LET cStatusCred            = "";
LET iPlazo                 = 0;
LET dtFechaAper            = DATE(1);
LET dtFechaVenc            = DATE(1);
LET dTasaInteres           = 0;
LET dTasaMoratorios        = 0;
LET dSdoRetenido           = 0;
LET dSdoNoExig             = 0;
LET dSdoContabMora         = 0;
LET dSdoCapital            = 0;
LET dSdoCapInsoluto        = 0;
LET dSdoMtoVdo             = 0;
LET dMtoVdoTrasp           = 0;
LET dMtoFinanciado         = 0;
LET dMtoOtorgado           = 0;
LET dCapTrasNoVdo          = 0;
LET dMtoVdoInt             = 0;
LET dMtoVdoTrasInt         = 0;
LET dIntTraNoExig          = 0;
LET cDescTpoCart           = "";
LET cCodTpoCred            = "";
LET dPorcIva               = 0;
LET dMoratorio             = 0;
LET dIvaMoratorio          = 0;
LET dIvaIntVenc            = 0;
LET dInteresMes            = 0;
LET dIvaMes                = 0;
LET dTotalLiquidacion      = 0;
LET dIntMoraCope           = 0;
LET dIvaIntMoraCope        = 0;
LET dIntMoraBase           = 0;
LET dIvaIntMoraBase        = 0;
LET dIvaIntMoraCopeBase    = 0;
LET dCapitalTotal          = 0;
LET dIntVig                = 0;
LET dIvaIntVig             = 0;
LET cStatusCredNew         = "";
--Actualizacion para nuevas etapas
LET vFechaHoy              = DATE(1);
LET UltimaFechaVigente     = DATE(1);
LET UltimaFechaVigente_old = DATE(1);
LET vAct                   = 0;
LET vAct_aux               = 0;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

-- Se ejecuta el procedimiento para consultar los saldos actuales del crÃ©dito
     CALL sp_cargamovtosnvasfunc (pEmpresa, pNumCredito)
RETURNING cCodRet, cMensajeRet, cNumcte, cSucursal, cStatusCred, iPlazo, dtFechaAper, dtFechaVenc, dTasaInteres,
          dTasaMoratorios, dSdoRetenido, dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo,
          dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasNoVdo, dMtoVdoInt, dMtoVdoTrasInt, dIntTraNoExig,
          cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes,
          dTotalLiquidacion, dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase,
          dCapitalTotal, dIntVig, dIvaIntVig;

 IF cCodRet <> "000000" THEN
       LET cCodRet = "000001";
       LET cMensajeRet= "OcurriÃ³ un error al consultar la informaciÃ³n ctual del crÃ©dito";
    RETURN cCodRet,cMensajeRet;
 END IF;


IF dSdoMtoVdo > 0 THEN
   SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicred:sd_fechas
      WHERE empresa=pEmpresa;

   SELECT max(fecha)
      INTO UltimaFechaVigente
      FROM bdicred:sd_maesdoshist 
      WHERE empresa = pEmpresa
         AND num_credito = pNumCredito
         AND monto_vencido > 0 
         AND mto_venc_trasp = 0
         AND fecha <= vFechaHoy;

   IF UltimaFechaVigente is null THEN

      SELECT max(fecha)
         INTO UltimaFechaVigente_old
         FROM bdicred:sd_maesdoshist_old
         WHERE empresa = pEmpresa
               AND num_credito = pNumCredito
               AND monto_vencido > 0 
               AND mto_venc_trasp = 0;

      IF UltimaFechaVigente_old is null THEN
         LET vAct=41;
      ELSE 
         SELECT count(*)
               INTO vAct 
               FROM bdicred:sd_maesdoshist_old b 
               WHERE b.empresa = pEmpresa
                  AND b.num_credito = pNumCredito
                  AND b.fecha >= UltimaFechaVigente_old
                  AND b.fecha <= vFechaHoy;

         SELECT count(*)
               INTO vAct_aux
               FROM bdicred:sd_maesdoshist b 
               WHERE b.empresa = pEmpresa
                  AND b.num_credito = pNumCredito
                  AND b.fecha >= UltimaFechaVigente_old
                  AND b.fecha <= vFechaHoy;

         LET vAct = vAct + vAct_aux;
      END IF;  

   ELSE

      SELECT count(*)
         INTO vAct
         FROM bdicred:sd_maesdoshist 
         WHERE empresa = pEmpresa
               AND num_credito = pNumCredito
               AND fecha >= UltimaFechaVigente
               AND fecha <= vFechaHoy;

   END IF;
ELSE
   LET vAct=0;
END IF; 


IF vAct < 2 THEN
   LET cStatusCredNew= "E1";
ELIF vAct >1 AND vAct < 4 THEN
   LET cStatusCredNew= "E2";
ELIF vAct >3 THEN
   LET cStatusCredNew= "E3";
ELSE
      LET cCodRet = "000002";
      LET cMensajeRet= "No es posible actualizar el status del crÃ©dito";
   RETURN cCodRet,cMensajeRet;
END IF;


IF cStatusCredNew <> "" AND cStatusCredNew <> cStatusCred THEN
    UPDATE "informix".sd_maecred
       SET status_cred = cStatusCredNew
     WHERE empresa = pEmpresa
       AND  num_credito = pNumCredito;

   UPDATE "informix".sd_maesdos
       SET act = vAct
     WHERE empresa = pEmpresa
       AND  num_credito = pNumCredito;
END IF;

   RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Este Procedimiento actualiza el status de un crÃ©dito',
'AUTOR : David Uriel Prieto Hurtado',
'FECHA : 13/04/2009',
'BD : BDICRED';

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