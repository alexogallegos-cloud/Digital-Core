CREATE PROCEDURE "informix".sp_generaconta(pFechaOperacion DATE)
RETURNING CHAR(5);
--//***************************************************************************
--// sp_generaconta
--// Version              1.0.0
--// Obejtivo:            Obtiene el monto de la comision, el iva y otros
--//                      como consulta antes de aplicar el pase contable.
--// Creado por:          Alejandro Rueda Sanchez
--// ModIFicado por:
--// Ultima Modificacion: AGOSTO - 2008
--//                      Creación de SPL
--//***************************************************************************

--//DEFINICION DE VARIABLES
DEFINE mnyImporteOp    MONEY(18,2);
DEFINE intTipoPago     INTEGER;
DEFINE chrSentido      CHAR(1);
DEFINE intCantidad     INTEGER;
DEFINE chrTransEnv     CHAR(4);
DEFINE chrTransRec     CHAR(4);
DEFINE chrCodRet       CHAR(5);
DEFINE intCodRet       INTEGER;
DEFINE chrCodTransacc  CHAR(4);
DEFINE vchrNumSucursal CHAR(4);
DEFINE chrSucursalOrig CHAR(4);
DEFINE chrempresa      CHAR(3);
DEFINE chrc_ccmayor    CHAR(4);
DEFINE chrc_ccsub      CHAR(2);
DEFINE chrc_ccsubsub   CHAR(2);
DEFINE chrc_ccsssub    CHAR(2);
DEFINE chrc_ccssssub   CHAR(2);
DEFINE chrc_sector     CHAR(2);
DEFINE chra_ccmayor    CHAR(4);
DEFINE chra_ccsub      CHAR(2);
DEFINE chra_ccsubsub   CHAR(2);
DEFINE chra_ccsssub    CHAR(2);
DEFINE chra_ccssssub   CHAR(2);
DEFINE chra_sector     CHAR(2);
DEFINE intPKTabla      INTEGER;
DEFINE vt_producto     CHAR(4);


   ON EXCEPTION SET intCodRet
      IF intCodRet <> 0 THEN
         LET chrCodRet = intCodRet;
         RETURN chrCodRet;
      END IF;
    END EXCEPTION;

   --SET DEBUG FILE TO "/tmp/sp_generaconta.out";
   --TRACE ON;

    --//Inicializacion de variables
    LET chrCodRet = '000';
    LET intPKTabla = 0;
    LET vt_producto = "0000";
    LET chrSucursalOrig = "0";

    --//Limpia la tabla
    DELETE FROM tblpasecont;

    --//Valida el status de los pagos
    SELECT COUNT(*)
      INTO intCantidad
      FROM tblpago
     WHERE dtfechavalor = pFechaOperacion
       AND chrestatusenvio NOT IN ('L','E','D','A','C','I','Q');
    IF intCantidad > 0 THEN
      RETURN '051';
    END IF;

    --//Obtiene la sucursal que afecta los movimientos
    SELECT vchrvalor
      INTO vchrNumSucursal
      FROM tblparametros
     WHERE vchrcveparametro = 'SUCURSAL_CENTRAL';


    --Obtiene los totales de las operaciones enviadas que NO contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(mnyimporte), p.intcvetipopago, chrsentidopago, te.chrtransenvio, nvl(dt.sucursal,'0'), producto
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc, chrSucursalOrig, vt_producto
          FROM tblpago p, tbltipopago tp,
               tbltransenvio te, tbltpago_tenvio pte,
               OUTER tbldetranpago dt ,
               OUTER bdicheq:sc_maechq mae
         WHERE p.intcvetipopago = tp.intcvetipopago
           AND pte.intcvetipopago =  tp.intcvetipopago
           AND pte.chrtxop = te.chrtxop
           AND te.chrtxop = p.chrtxop
           AND intcontabiliza = 1
           AND intcontatoper = 0
           AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'E'
           AND chrestatusenvio in ('L', 'D', 'E')
           and dt.clave_rastreo = p.vchrclaverastreo
           and dt.fech_alt = dtfechacaptura
           and dt.transacc = p.chrtxop
           and mae.cuenta = trim(p.vchrcuentaord)
         GROUP BY p.intcvetipopago, chrsentidopago, te.chrtransenvio, dt.sucursal, producto

        --//Valida que tenga transaccion
        IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
           RETURN '050';
        END IF;

        --//Obtiene los valores para la transaccion
        SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
               c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
               a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
          INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
               chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
               chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
          FROM bdinteg:si_prodtran
         WHERE sistema = '01'
           AND transaccion = chrCodTransacc
           AND producto = vt_producto;

        --//Valida que LA transaccion exista en central
        IF chrc_ccmayor IS NULL  THEN
           RETURN '052';
        END IF;
        LET intPKTabla = intPKTabla + 1;

        --//Si no existe centro origen, lo toma de parametros
        IF chrSucursalOrig = '0' THEN
           LET chrSucursalOrig = vchrNumSucursal;
        END IF;

        --//Inserta cargo
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono,costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                    chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',chrSucursalOrig);

        LET intPKTabla = intPKTabla + 1;

        --//Inserta Abono
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono,costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                    chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',chrSucursalOrig);
    END FOREACH;

    --//Obtiene los totales de las operaciones enviadas que SI contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(mnyimporte), p.intcvetipopago, p.chrsentidopago, top.chrtransenvio, '0' as sucursal
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc, chrSucursalOrig
          FROM tblpago p, tbltipopago tp, tbltipooperacion top
         WHERE p.intcvetipopago = tp.intcvetipopago
           AND top.intcvetpooperacion =  p.intcvetpooperacion
	   AND tp.intcontabiliza = 1
           AND tp.intcontatoper = 1
           AND top.intcontabiliza = 1
           AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'E'
           AND chrestatusenvio in ('L', 'D', 'E')
         GROUP BY p.intcvetipopago, chrsentidopago, top.chrtransenvio

        --//Valida que tenga transaccion
        IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
           RETURN '050';
        END IF;

        --//Obtiene los valores para la transaccion
        SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
               c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
               a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
          INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
               chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
               chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
          FROM bdinteg:si_prodtran
         WHERE sistema = '01'
           AND transaccion = chrCodTransacc;

        --//Valida que LA transaccion exista en central
        IF chrc_ccmayor IS NULL  THEN
           RETURN '052';
        END IF;
        LET intPKTabla = intPKTabla + 1;

        --//Si no existe centro origen, lo toma de parametros
        IF chrSucursalOrig = '0' THEN
           LET chrSucursalOrig = vchrNumSucursal;
        END IF;

        --//Inserta cargo
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono, costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                    chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',chrSucursalOrig);

        LET intPKTabla = intPKTabla + 1;

        --//Inserta Abono
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono, costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                    chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',chrSucursalOrig);
    END FOREACH;

    --//Obtiene los totales de las operaciones recibidas que NO contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(mnyimporte), p.intcvetipopago, chrsentidopago, tp.chrtransrecep, producto
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc, vt_producto
          FROM tblpago p, tbltipopago tp, bdicheq:sc_maechq mae
         WHERE p.intcvetipopago = tp.intcvetipopago
    	   AND intcontabiliza = 1
           AND intcontatoper = 0
    	   AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'R'
           AND (chrestatusenvio = 'A')
           AND lpad(nvl(vchrcuentabenef, '0'), 18, '0') not in (select vchrcuenta from bdispei:tblctabansi)
           AND mae.cuenta = DECODE(length(trim(p.vchrcuentabenef)),18,trim(p.vchrcuentabenef[7,17]),trim(p.vchrcuentabenef))
         GROUP BY p.intcvetipopago, chrsentidopago, tp.chrtransrecep, producto
     UNION
        SELECT SUM(mnyimporte), p.intcvetipopago, chrsentidopago, tp.chrtransrecep, producto
          --INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc, vt_producto
          FROM tblpago p, tbltipopago tp,  bdicheq:sc_tarjeta tar,  bdicheq:sc_maechq mae
         WHERE p.intcvetipopago = tp.intcvetipopago
           AND intcontabiliza = 1
           AND intcontatoper = 0
           AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'R'
           AND (chrestatusenvio = 'A')
           --AND lpad(nvl(vchrcuentabenef, '0'), 18, '0') not in (select vchrcuenta from bdispei:tblctabansi)
           and tar.num_tarjeta = vchrcuentabenef
           and tar.cuenta = mae.cuenta
         GROUP BY p.intcvetipopago, chrsentidopago, tp.chrtransrecep, producto


          --//Valida que tenga transaccion
          IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
            RETURN '050';
          END IF;

          --//Obtiene los valores para la transaccion
          SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
                 c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
                 a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
            INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
                 chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
                 chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
            FROM bdinteg:si_prodtran
           WHERE sistema = '01'
             AND transaccion = chrCodTransacc
             AND producto = vt_producto;

          --//Valida que LA transaccion exista en central
          IF chrc_ccmayor IS NULL  THEN
             RETURN '052';
          END IF;
          LET intPKTabla = intPKTabla + 1;

          --//Inserta abono
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono, costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                      chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',vchrNumSucursal);

          LET intPKTabla = intPKTabla + 1;

          --//Inserta cargo
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono, costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                      chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',vchrNumSucursal);
    END FOREACH;


    --//Obtiene los totales de las operaciones recibidas que SI contabilizan por tipo de operacion (CTA VOSTRO)
    FOREACH
        SELECT SUM(mnyimporte), cb.intcvetipopago, p.chrsentidopago, top.chrtransrecep
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc
          FROM tblpago p, tblctabansi cb, tbltipopago tp, tbltipooperacion top
         WHERE lpad(p.vchrcuentabenef, 18, '0') = cb.vchrcuenta
           AND cb.intcvetipopago = tp.intcvetipopago
           AND cb.intcvetpooperacion = top.intcvetpooperacion
    	   AND tp.intcontabiliza = 1
    	   AND tp.intcontatoper = 1
    	   AND top.intcontabiliza = 1
           AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'R'
           AND (chrestatusenvio = 'A')
         GROUP BY cb.intcvetipopago, chrsentidopago, top.chrtransrecep

         --//Valida que tenga transaccion
         IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
            RETURN '050';
         END IF;

         --//Obtiene los valores para la transaccion
         SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
                c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
                a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
           INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
                chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
                chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
           FROM bdinteg:si_prodtran
          WHERE sistema = '01'
            AND transaccion = chrCodTransacc;

          --//Valida que la transaccion exista en central
          IF chrc_ccmayor IS NULL  THEN
             RETURN '052';
          END IF;
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Cargo
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono,costo_orig )
               VALUES (intPKTabla,vchrNumSucursal,
                      chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                      chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',vchrNumSucursal);
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Abono
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono,costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                      chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',vchrNumSucursal);

    END FOREACH;


    --//Obtiene los totales de las operaciones recibidas que SI contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(mnyimporte), p.intcvetipopago, p.chrsentidopago, top.chrtransrecep
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc
          FROM tblpago p, tbltipopago tp, tbltipooperacion top
         WHERE p.intcvetipopago = tp.intcvetipopago
           AND top.intcvetpooperacion =  p.intcvetpooperacion
    	   AND tp.intcontabiliza = 1
           AND tp.intcontatoper = 1
           AND top.intcontabiliza = 1
           AND tp.inttipofuncion <> 1
           AND dtfechavalor = pFechaOperacion
           AND chrsentidopago = 'R'
           AND chrestatusenvio = 'A'
         GROUP BY p.intcvetipopago, chrsentidopago, top.chrtransrecep

          --//Valida que tenga transaccion
          IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
             RETURN '050';
          END IF;

          --//Obtiene los valores para la transaccion
          SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
                 c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
                 a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
            INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
                 chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
                 chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
            FROM bdinteg:si_prodtran
           WHERE sistema = '01'
             AND transaccion = chrCodTransacc;

          --//Valida que LA transaccion exista en central
          IF chrc_ccmayor IS NULL  THEN
             RETURN '052';
          END IF;
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Cargo
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono,costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                      chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',vchrNumSucursal);
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Abono
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono, costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                      chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',vchrNumSucursal);
    END FOREACH;

    --//Obtiene los totales de las devoluciones recibidas que NO contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(p.mnyimporte), p2.intcvetipopago, p.chrsentidopago, te.chrtransenvio, producto
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc, vt_producto
          FROM tblpago p, tbltipopago tp, tblpago p2, tbltipopago tp2, tbltransenvio te, tbltpago_tenvio pte,
               bdicheq:sc_maechq mae
         WHERE p.intcvetipopago = tp.intcvetipopago
    	   AND tp.inttipofuncion = 1
           AND p.dtfechavalor = pFechaOperacion
           AND p.chrsentidopago = 'R'
           AND p.chrestatusenvio = 'A'
           AND p2.intpkpago = p.intpkpagoorig
           AND p2.intcvetipopago = tp2.intcvetipopago
           AND tp2.intcontabiliza = 1
           AND tp2.intcontatoper = 0
    	   AND pte.intcvetipopago =  tp2.intcvetipopago
           AND pte.chrtxop = te.chrtxop
           AND te.chrtxop = p2.chrtxop
           AND mae.cuenta = DECODE(length(trim(p2.vchrcuentaord)),18,trim(p2.vchrcuentaord[7,17]),trim(p2.vchrcuentaord))
         GROUP BY p2.intcvetipopago, p.chrsentidopago, te.chrtransenvio, producto

        --//Valida que tenga transaccion
        IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
           RETURN '050';
        END IF;

        --//Obtiene los valores para la transaccion
        SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
               c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
               a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
          INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
               chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
               chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
          FROM bdinteg:si_prodtran
         WHERE sistema = '01'
           AND transaccion = chrCodTransacc
           AND producto = vt_producto;

        --//Valida que LA transaccion exista en central
        IF chrc_ccmayor IS NULL  THEN
           RETURN '052';
        END IF;
        LET intPKTabla = intPKTabla + 1;

        --//Inserta cargo
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono, costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                    chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'D', vchrNumSucursal);
        LET intPKTabla = intPKTabla + 1;

        --//Inserta Abono
        INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                    ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                    chrdivisa,mnymonto,chrcargoabono,costo_orig)
             VALUES (intPKTabla,vchrNumSucursal,
                    chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                    chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'C', vchrNumSucursal);
    END FOREACH;

    --//Obtiene los totales de las devoluciones recibidas que SI contabilizan por tipo de operacion
    FOREACH
        SELECT SUM(p.mnyimporte), p2.intcvetipopago, p.chrsentidopago, top.chrtransenvio
          INTO mnyImporteOp, intTipoPago, chrSentido, chrCodTransacc
          FROM tblpago p, tbltipopago tp, tblpago p2, tbltipopago tp2, tbltipooperacion top
         WHERE p.intcvetipopago = tp.intcvetipopago
    	   AND tp.inttipofuncion = 1
           AND p.dtfechavalor = pFechaOperacion
           AND p.chrsentidopago = 'R'
           AND (p.chrestatusenvio = 'A')
           AND p2.intpkpago = p.intpkpagoorig
           AND p2.intcvetipopago = tp2.intcvetipopago
           AND tp2.intcontabiliza = 1
           AND tp2.intcontatoper = 1
    	   AND top.intcvetpooperacion = p2.intcvetpooperacion
         GROUP BY p2.intcvetipopago, p.chrsentidopago, top.chrtransenvio

         --//Valida que tenga transaccion
         IF chrCodTransacc IS NULL OR chrCodTransacc = '' THEN
            RETURN '050';
         END IF;

         --//Obtiene los valores para la transaccion
         SELECT empresa, c_ccmayor, c_ccsub, c_ccsubsub,
                c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
                a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
           INTO chrempresa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
                chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
                chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
           FROM bdinteg:si_prodtran
          WHERE sistema = '01'
            AND transaccion = chrCodTransacc;

          --//Valida que LA transaccion exista en central
          IF chrc_ccmayor IS NULL  THEN
             RETURN '052';
          END IF;
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Cargo
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono, costo_orig) VALUES(intPKTabla,vchrNumSucursal,
                      chrc_ccmayor,chrempresa,chrc_ccsub,chrc_ccsubsub,chrc_ccsssub,
                      chrc_ccssssub,chrc_sector,'',chrCodTransacc,'01',mnyImporteOp,'C',vchrNumSucursal);
          LET intPKTabla = intPKTabla + 1;

          --//Inserta Abono
          INSERT INTO tblpasecont(intpkpasecont,chrsucursal,ccmayor,chrempresa,
                      ccsub,ccsubsub,ccssubsub,ccsssubsub,ccsector,ccauxiliar,chrtransaccion,
                      chrdivisa,mnymonto,chrcargoabono, costo_orig)
               VALUES (intPKTabla,vchrNumSucursal,
                      chra_ccmayor,chrempresa,chra_ccsub,chra_ccsubsub,chra_ccsssub,
                      chra_ccssssub,chra_sector,'',chrCodTransacc,'01',mnyImporteOp,'D',vchrNumSucursal);
    END FOREACH;

    RETURN chrCodRet;
END PROCEDURE;