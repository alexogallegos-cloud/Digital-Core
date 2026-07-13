CREATE PROCEDURE "informix".pasecajag_pba(pempresa   CHAR(3), pfecha_pase DATE, pusuario   CHAR(8))
RETURNING CHAR(5), CHAR(8), INTEGER; 

   DEFINE vdate                         DATETIME year to second;
   DEFINE vctrl_poliza                  INTEGER;
   DEFINE vcod_ret                      CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;

   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wdescripcion_det              CHAR(30);
   DEFINE wdivisa 						CHAR(2);
   DEFINE vsecuencia					SMALLINT;
   DEFINE vregional                     CHAR(3);
   DEFINE vsucdest					    CHAR(4);
   DEFINE wproveedor					CHAR(4);
   DEFINE wnro_auxiliar                 CHAR(12);
   DEFINE wfecha                        DATE;
   DEFINE vnaturaleza                   CHAR(1);
   DEFINE wempresa                      CHAR(3);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);

   DEFINE vcargo                        CHAR(1);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wsucursal                     CHAR(4);
   DEFINE wtransacc                     CHAR(4);
   DEFINE wprocedencia					CHAR(4);
   DEFINE wstatus						CHAR(2);
   DEFINE wmonto                        MONEY(14,2);

{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE detusuario                    CHAR(8);
   DEFINE wfolio			    		CHAR(8);
   DEFINE wtesoreria 					CHAR(4);
   DEFINE vfecha_envio                  DATE;
   DEFINE vfecha_recep                  DATE;
   DEFINE vtranenvio                    CHAR(4);
   DEFINE vtipo_tran                    CHAR(2);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET vcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;

      LET vctrl_poliza = 0;
      INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
      VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
      
      RETURN vcod_ret, pusuario, vctrl_poliza;

   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION;

-- set debug file to "pasecajag_pba.TRC";
-- TRACE ON;

   LET vcod_ret = "000";
   LET vdate = current;
   LET vctrl_poliza = 0;
   LET wbegin = "S";
   LET detusuario = pusuario;
   LET wprocedencia = "";
   LET wstatus = "";
   LET wtesoreria = "";
   LET vfecha_envio = "";
   LET vfecha_recep = "";
   LET wproveedor = "";
   LET vcargo = "";
   LET vtipo_tran = "";

   LET wempresa = "";

   ---SET PDQPRIORITY 10; HMD-INCIDENCIA-20220224

   BEGIN WORK;

      SELECT
         fecha_hoy 
      INTO
         wfecha_hoy
      FROM
         bdinteg:si_fechas
      WHERE
         empresa = pempresa;

	  LET pfecha_pase = wfecha_hoy;

      --borra lo existente en la base de contabilidad
      delete from ss_poliza;

      delete from bdicont:co_poldet
      where empresa = pempresa
      and fecha_captura = pfecha_pase
      and usuario = pusuario;

      delete from bdicont:co_detpol
      where empresa = pempresa
      and fecha_captura = pfecha_pase
      and usuario = pusuario;

      delete from bdicont:co_poliza
      where empresa = pempresa
      and fecha_captura = pfecha_pase
      and usuario = pusuario;

      -- Carga el Centro de Costo de Tesoreria
      SELECT valor INTO wtesoreria
      FROM   ss_param_cajagen
      WHERE  codigo = "0034" AND empresa=pempresa;

      SELECT
         ejecutivo,sucursal
      INTO
         wejecutivo,vsucdest
      FROM
         bdinteg:si_ejecut
      WHERE
         empresa = pempresa
      AND
         ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET vcod_ret = "090";
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret) 
         VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
         RETURN vcod_ret, pusuario, vctrl_poliza;
      END IF;

      LET wusuario = pusuario;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CAJA GENERAL DEL DIA "||wfecha_hoy;
      LET wfecha = wfecha_hoy;

	LOCK TABLE bdisuc:ss_mae_entradasalida IN SHARE MODE;
	LOCK TABLE bdisuc:ss_operaciones IN SHARE MODE;

     FOREACH
       SELECT
           empresa,
           sucursal,
           cod_proveedor,
           monto,
           folio_oper,
           fecha_envio,
           fecha_recepcion
       INTO
            wempresa,
            wsucursal,
            wprocedencia,
            wmonto,
            wfolio,
            vfecha_envio,
            vfecha_recep
       FROM
            bdisuc:ss_mae_entradasalida
       WHERE empresa = pempresa
         AND (fecha_envio = pfecha_pase OR fecha_recepcion = pfecha_pase)
         AND status != '08'
         AND monto > 0

       SELECT divisa,cod_trans INTO wdivisa,wtransacc
       FROM   bdisuc:ss_operaciones
       WHERE  folio_oper = wfolio
	     AND  reversado='0';

	   IF  wtransacc IS NULL  THEN
	      continue foreach;
	   END IF

       IF wdivisa IS NULL THEN
          LET wdivisa = '01';
       END IF

       -- Verifica si la Transaccion Contabiliza
       SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
       FROM   bdinteg:si_transacc
       WHERE  sistema='02' AND se_contabiliza='S' AND empresa = pempresa AND numero = wtransacc;
       IF vnaturaleza IS NULL or vnaturaleza = "" THEN
          continue foreach;
       END IF

       -- Verifica la Divisa de la Morralla
       IF wdivisa = "MR" THEN
          SELECT valor INTO wdivisa
          FROM   bdinteg:si_param
          WHERE  cod_param = 15 AND empresa=pempresa;
       END IF

       -- Checa la Transaccion con las Fechas de Envio y Recepcion
       IF NOT vfecha_envio IS NULL THEN
          IF (wtransacc = "0001" or wtransacc = "0010" or wtransacc = "0036") AND vfecha_envio = pfecha_pase THEN -- es Dotacion la Cambia
             LET vtranenvio = "0011"; -- Envio de Dotaciones
             -- Verifica si la Transaccion Contabiliza
             SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
             FROM   bdinteg:si_transacc
             WHERE  sistema='02' AND se_contabiliza='S' 
             AND    empresa = pempresa AND numero = vtranenvio;
             CALL sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                             wprocedencia,vnaturaleza,wmonto,vtipo_tran) returning vcod_ret;
             IF Trim(vcod_ret) != "000" THEN
                INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
                VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
                RETURN vcod_ret, pusuario, vctrl_poliza;
             END IF
          END IF
          IF (wtransacc = "0002" OR wtransacc = '0041' ) AND vfecha_envio = pfecha_pase THEN -- es Concentracion la Cambia
             LET vtranenvio = "0012"; -- Envio de Cocentraciones
             -- Verifica si la Transaccion Contabiliza
             SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
             FROM   bdinteg:si_transacc
             WHERE  sistema='02' AND se_contabiliza='S' 
             AND    empresa = pempresa AND numero = vtranenvio;
             CALL sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                             wprocedencia,vnaturaleza,wmonto,vtipo_tran) returning vcod_ret;
             IF Trim(vcod_ret) != "000" THEN
                INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
                VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
                RETURN vcod_ret, pusuario, vctrl_poliza;
             END IF
          END IF
          IF vfecha_recep IS NULL THEN
             continue foreach;
          END IF
       END IF

       IF NOT vfecha_recep IS NULL THEN
          IF (wtransacc = "0001" or wtransacc = "0010" or wtransacc = "0036") AND vfecha_recep = pfecha_pase THEN
             LET vtranenvio = "0013"; -- Recibe Dotaciones
             -- Verifica si la Transaccion Contabiliza
             SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
             FROM   bdinteg:si_transacc
             WHERE  sistema='02' AND se_contabiliza='S' 
             AND    empresa = pempresa AND numero = vtranenvio;
             CALL sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                             wprocedencia,vnaturaleza,wmonto,vtipo_tran) returning vcod_ret;
             IF Trim(vcod_ret) != "000" THEN
                INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
                VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
                RETURN vcod_ret, pusuario, vctrl_poliza;
             END IF
          END IF
          IF (wtransacc = "0002" OR wtransacc ='0041' ) AND vfecha_recep = pfecha_pase THEN
             LET vtranenvio = "0014"; -- Recibe Concentraciones
             -- Verifica si la Transaccion Contabiliza
             SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
             FROM   bdinteg:si_transacc
             WHERE  sistema='02' AND se_contabiliza='S' 
             AND    empresa = pempresa AND numero = vtranenvio;
             CALL sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                             wprocedencia,vnaturaleza,wmonto,vtipo_tran) returning vcod_ret;
             IF Trim(vcod_ret) != "000" THEN
                INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
                VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);             
                RETURN vcod_ret, pusuario, vctrl_poliza;
             END IF
          END IF
       END IF
      END FOREACH;

      FOREACH
         SELECT
           cod_trans,
           sucursal,
           divisa,
           procedencia,
           monto,
           folio_oper
         INTO
            wtransacc,
            wsucursal,
            wdivisa,
            wprocedencia,
            wmonto,
            wfolio
         FROM bdisuc:ss_operaciones
        WHERE cod_trans not in ('0001','0002','0010','0036','0041')
		  AND fecha_operacion = pfecha_pase
		  AND sucursal != '0'
		  AND reversado = '0'

         -- Verifica si la Transaccion Contabiliza
         SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
         FROM   bdinteg:si_transacc
         WHERE  sistema='02' AND se_contabiliza='S' AND empresa = pempresa AND numero = wtransacc;

         IF vnaturaleza IS NULL or vnaturaleza = "" THEN
            continue foreach;
         END IF

         -- Verifica la Divisa de la Morralla
         IF wdivisa = "MR" THEN
            SELECT valor INTO wdivisa
            FROM   bdinteg:si_param
            WHERE  cod_param = 15 AND empresa=pempresa;
         END IF

          LET vtranenvio = wtransacc; -- Transacciones Normales
          CALL sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                         wprocedencia,vnaturaleza,wmonto,vtipo_tran) returning vcod_ret;
          IF Trim(vcod_ret) != "000" THEN
             INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
             VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);
             RETURN vcod_ret, pusuario, vctrl_poliza;
          END IF
      END FOREACH

      LET vsecuencia = 1;

      FOREACH
          SELECT sucursal,cod_trans,divisa,
                 cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,
                 nro_auxiliar,monto,cargo_abono,cod_proveedor
          INTO   wsucursal,wtransacc,wdivisa,
                 wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,
                 wnro_auxiliar,wmonto,vcargo,vsucdest
          FROM   bdisuc:ss_poliza

          SELECT regional INTO vregional
          FROM   bdinteg:si_plazas a,bdinteg:si_sucursales b
          WHERE  a.plaza = b.plaza
          AND    sucursal=wsucursal;

          IF vcargo = "1" THEN
             INSERT INTO
               bdicont:co_poldet
                (usuario,fecha_captura,
 	         secuencia,empresa,
                 ccmayor,ccsub,
                 ccsubsub,ccssubsub,
                 ccsssubsub,sector,
                 ciudad,sucursal,
                 nro_auxiliar,naturaleza,
                 monto,descripcion_det,
                 fecha_valida,moneda,
                 ccosto_orig)
             VALUES
                (pusuario,pfecha_pase,
                 vsecuencia,pempresa,
                 wcmayor,wcsub1,
                 wcsub2,wcsub3,
                 wcsub4,wcsector,
                 vregional,wsucursal,
                 wnro_auxiliar,"D",
                 wmonto,wdescripcion_det,
                 wfecha_hoy,wdivisa,
                 vsucdest);
          END IF
          IF vcargo = "0" THEN
             INSERT INTO
               bdicont:co_poldet
                (usuario,fecha_captura,
 	         secuencia,empresa,
                 ccmayor,ccsub,
                 ccsubsub,ccssubsub,
                 ccsssubsub,sector,
                 ciudad,sucursal,
                 nro_auxiliar,naturaleza,
                 monto,descripcion_det,
                 fecha_valida,moneda,
                 ccosto_orig)
             VALUES
                (pusuario,pfecha_pase,
                 vsecuencia,pempresa,
                 wcmayor,wcsub1,
                 wcsub2,wcsub3,
                 wcsub4,wcsector,
                 vregional,wsucursal,
                 wnro_auxiliar,"C",
                 wmonto,wdescripcion_det,
                 wfecha_hoy,wdivisa,
                 vsucdest);
          END IF
          LET vsecuencia = vsecuencia + 1;
      END FOREACH;

   IF (wbegin = "S") THEN
      COMMIT WORK;
      BEGIN WORK;
   ELSE
      COMMIT WORK;
   END IF;

   --EJECUTA EL PROCESO DE AUDITOR
   let pfecha_pase = pfecha_pase;
   let pempresa = pempresa;
   let detusuario = detusuario;

   EXECUTE PROCEDURE BDICONT:AUDITAPASE(pfecha_pase,pempresa,detusuario)
           INTO vcod_ret;

  SELECT
     DISTINCT control_poliza
         INTO vctrl_poliza
         FROM bdicont:co_detpol
        WHERE usuario = wusuario
          AND fecha_captura = pfecha_pase
          AND moneda = "01"
          AND empresa = pempresa;

   INSERT INTO bdisuc:ss_ctrlpasecg(empresa,usuario,control_poliza,fecha,cod_ret)
   VALUES(pempresa, pusuario,vctrl_poliza,vdate,vcod_ret);

    EXECUTE PROCEDURE "informix".ss_ins_cajagen_hist(pempresa,pfecha_pase)
	        INTO vcod_ret;
   
   COMMIT WORK;
   
    RETURN vcod_ret, pusuario, vctrl_poliza;
END PROCEDURE;