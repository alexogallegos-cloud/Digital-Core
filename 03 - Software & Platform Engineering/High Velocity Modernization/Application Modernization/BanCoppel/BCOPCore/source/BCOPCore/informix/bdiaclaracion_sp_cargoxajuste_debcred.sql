CREATE PROCEDURE "informix".sp_cargoxajuste_debcred(pEmpresa CHAR(3), pFolioSuac CHAR(10), pDictamen CHAR(2),pEmpleadoAut CHAR (8),pMontoAD DECIMAL(18,2), pTipo Integer,pRequiereAut SMALLINT)
RETURNING CHAR(3);

    DEFINE cCodRet                CHAR(3);  --> ok
    DEFINE sql_err                INTEGER;
    DEFINE isam_err               INTEGER;

    DEFINE CnumCuenta             CHAR(20);
    DEFINE Tproducto              INTEGER;
    DEFINE CnumTarjeta            CHAR(20);
    DEFINE CmontoAcla             DECIMAL(18,2);

    DEFINE Ctrans_cargo_ajuste      CHAR(04);     --> Numero de transacción
    DEFINE Ifky_producto          INTEGER;    --> ok Comisiones
    DEFINE Ipky_tipo_movimiento   INTEGER;    --> ok Comisiones
    DEFINE FIpky_tipo_movimiento  INTEGER;    -- determinar el pky de aclaracion
    DEFINE Ipky_movimiento        INTEGER;    --> ok Comisiones

    -->> Variables para Codigos de Retorno
    DEFINE DCodret_a              CHAR(5);    --> ok Retornos.
    --DEFINE DCodret_c            CHAR(5);    --> ok Retornos.
    DEFINE DTranret_c             CHAR(5);    --> ok Retornos.
    DEFINE DFechoy_c              DATE;     --> ok Retornos.
    DEFINE DVsdodisp_c            MONEY(14,2);  --> ok Retornos.
    DEFINE DVmontoret_c           MONEY(14,2);  --> ok Retornos.

    DEFINE CMensaje               CHAR(80);
    DEFINE CSecuencia             INTEGER;
    DEFINE Ctrannopro             CHAR(04);
    DEFINE Ctransinauto           CHAR(04);
    DEFINE Ctranpro               CHAR(04);
    DEFINE Ctranauto              CHAR(04);
    DEFINE CtranCargoAjuste       CHAR(04);
    DEFINE Ccargo                 SMALLINT;
    DEFINE ptranaplica            CHAR(04);
    DEFINE wBegin                 CHAR(1);
    DEFINE v_contador             SMALLINT;
    DEFINE pFolioSuacSUC          CHAR(16);
    DEFINE v_fecha_folio          CHAR(10);
    DEFINE CSecuencia_acl_mov     INTEGER;  --> ok

    --> Variables para duplicidad de movimientos
    DEFINE v_fky_padre            INTEGER;  -- ok Mov_Duplicados
    DEFINE v_monto                DECIMAL(18,2);
    DEFINE v_interes              DECIMAL(18,2);
    DEFINE v_montoprocedente      DECIMAL(18,2);
    DEFINE v_fky_tipo_evento      INTEGER;
    DEFINE v_duplicado            SMALLINT;

    /* Retornos saldo*/
    DEFINE vcodret                CHAR(5);
    DEFINE vsdodisp               MONEY(16,2);
    DEFINE vstatuscta             CHAR(1);

    DEFINE CnumCredito            CHAR(20);
    DEFINE CCodret_c              CHAR(5);
    DEFINE isAbono                SMALLINT;
    DEFINE isCargo                SMALLINT;



    LET isAbono         = 0;
    LET isCargo         = 0;

    LET cCodRet          = '000';
    -->> Variables para Comisiones (NP, CM) / Intereses
    LET Ctrans_cargo_ajuste    = '';
    LET Ifky_producto      = 0;
    LET Ipky_tipo_movimiento   = 0;
    LET Ipky_movimiento      = 0;
    LET FIpky_tipo_movimiento  = 0;

    -->> Variables para Codigos de Retorno
    LET DCodret_a        = '';
    --LET DCodret_c            = '';
    LET DTranret_c           = '';
    LET DFechoy_c            = '';
    LET DVsdodisp_c          = 0;
    LET DVmontoret_c         = 0;

    LET CnumCuenta         = '';
    LET Tproducto          = 0;
    LET CnumTarjeta      = '';
    LET CmontoAcla       = 0;

    LET CMensaje         = '';
    LET CSecuencia       = 0;
    LET Ctrannopro       = '';
    LET Ctransinauto     = '';
    LET Ctranpro         = '';
    LET Ctranauto        = '';
    LET CtranCargoAjuste = '';
    LET Ccargo           = 0;
    LET ptranaplica      = '0000';
    LET wBegin         = 'N';
    LET v_contador       = 0;
    LET pFolioSuacSUC    = '';
    LET v_fecha_folio    = "";
    LET CSecuencia_acl_mov   = 0;
    --> Variables para duplicidad de movimientos
    LET v_fky_padre       = 0;
    LET v_monto           = 0;
    LET v_montoprocedente = 0;
    LET v_fky_tipo_evento = 0;
    LET v_duplicado       = 0;

    LET CnumCredito         = '';
    LET CCodret_c           = '';

    LET v_interes          = 0;

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,CMensaje
      LET cCodRet = sql_err;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN

         BEGIN WORK;
      END IF;

      RETURN cCodRet;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;


   --SET DEBUG FILE TO "/informix/VJMP/sp_aplicaaclaradebito_des"||"_"||""||TRIM(pFolioSuac)||""||"_35.out";
   --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplicaaclaradebito_des"||"_N_"||""||TRIM(pFolioSuac)||""||"_35.out"; --> TRACE DESDE APP
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;

   IF pFolioSuac IS NULL OR pFolioSuac = '' THEN      --> CodRet ok, pFolioSuac pentrada ok, cCodRet ok
      LET cCodRet='001';
      RETURN cCodRet;
   END IF;

  IF pDictamen IS NULL OR pDictamen = '' THEN       --> CodRet ok, pDictamen pentrada ok, cCodRet ok
      LET cCodRet='007';
      RETURN cCodRet;
   END IF;

--Credito
IF (pTipo = 1) THEN
  IF (pDictamen = 'AD') THEN

  IF EXISTS (SELECT * FROM acl_movimiento WHERE folio_csuac = pFolioSuac AND cargo = 0 AND exitoso = 1) THEN
      LET isAbono = 1;
      ELSE
      LET isAbono = 0;
    END IF;

    IF EXISTS (SELECT * FROM acl_movimiento WHERE folio_csuac = pFolioSuac AND cargo = 1) THEN
      LET isCargo = 1;
      ELSE
      LET isCargo = 0;
    END IF;

    IF (isAbono = 1 AND isCargo = 0)
    THEN
    FOREACH WITH hold
      -- >> Insertar movimientos duplicados.
      SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_cargo_ajuste, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
      INTO
      pFolioSuac,          -- folio_csuac,                --> Mismo que el padre -- ok
      v_monto,             -- monto,                      --> Mismo que el padre -- para afectación contable
      v_montoprocedente,   -- montoprocedente,            --> Mismo que el padre -- Breviario cultural
      Ctrans_cargo_ajuste,   -- numero_transaccion,         --> null -- Trans_cargo_por_ajuste para que haga la afectación con esa transacción.
      Ipky_movimiento,     -- fky_padre,                  --> pky del movimiento padre
      Ifky_producto,       -- fky_producto,               --> Mismo que el padre
      v_fky_tipo_evento,   -- fky_tipo_evento,            --> Mismo que el padre
      Ipky_tipo_movimiento -- fky_tipo_movimiento,        --> Mismo que el padre
      FROM acl_movimiento a, acl_tipo_movimiento b
      WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
      AND a.folio_csuac = pFolioSuac
      AND a.cargo = 0
      AND a.calculado = 0
      AND a.exitoso = 1
      AND a.fecha_afectacion IS NOT NULL
      AND a.duplicado = 0

      /*Obtiene interes a v_interes*/
        SELECT a.montoprocedente
        INTO
        v_interes
        FROM acl_movimiento a, acl_tipo_movimiento b
        WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
        AND a.folio_csuac = pFolioSuac
        AND a.exitoso = 1
        AND a.calculado = 1
        AND a.fecha_afectacion IS NOT NULL
        AND a.duplicado = 0;

      /*Suma interes a v_montoprocedente*/
      IF(v_interes <> 0)  THEN
          LET v_montoprocedente = (v_montoprocedente+v_interes);
      END  IF;


      SELECT MAX (secuencia)
      INTO CSecuencia_acl_mov
      FROM acl_movimiento
      WHERE folio_csuac = pFolioSuac;

      SELECT fky_padre
        INTO v_fky_padre
        FROM acl_movimiento a
        WHERE folio_csuac = pFolioSuac
              AND monto = v_monto;

      LET v_montoprocedente = (v_montoprocedente-pMontoAD);

      IF (v_fky_padre IS NULL) THEN

        INSERT INTO acl_movimiento VALUES (
        -- pky_movimiento                         calculado     cargo     cargo_ajuste  exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
        MOVIMIENTO_SEQ.nextval,     0,            1,        1,           0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      pMontoAD,  v_montoprocedente,  1,            Ctrans_cargo_ajuste,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              null, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null,0,0);

      END IF;

    END FOREACH;

  END IF; --End v_fky_padre

END IF; --Fin predictamen



IF (pRequiereAut == 0) --Aplica cargo  si no requiere autorización
  THEN
--======================== Aplica cargo

  FOREACH WITH hold

        SELECT pky_movimiento, numero_cuenta, numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion,trans_cargo_ajuste, nvl(cargo,0)
        INTO CSecuencia, CnumCredito, CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,CtranCargoAjuste,Ccargo
        FROM acl_movimiento a
        LEFT OUTER JOIN acl_producto b on (a.fky_producto = b.pky_producto)
        LEFT OUTER JOIN acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
        WHERE folio_csuac = pFolioSuac
      AND (procede IS NULL OR procede = 1)
          AND (exitoso IS NULL OR exitoso <> '1')
      AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END

           IF CnumCredito IS NULL THEN
              LET cCodRet='003';
              ROLLBACK WORK;
              IF (wBegin = "S") THEN
                  BEGIN WORK;
              END IF;
              RETURN cCodRet;
           END IF;

           IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
              LET cCodRet='004';
              ROLLBACK WORK;
              IF (wBegin = "S") THEN
                  BEGIN WORK;
              END IF;
              RETURN cCodRet;
           END IF;

           IF (CnumTarjeta is null) then
              let CnumTarjeta = '';
           END IF;


        IF (pDictamen = 'AD') THEN --> transaccion cargo_por_ajuste
            LET ptranaplica = CtranCargoAjuste;
        END IF;

        SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
        INTO v_fecha_folio FROM bdicred:sd_fechas;

        LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(pFolioSuac,10,0);

        LET CmontoAcla = pMontoAD;

    --Aplicacion de cargo
      call bdicred:sp_cargo_abono_aclara(pEmpresa, CnumCredito, CnumTarjeta, CmontoAcla, user, '9250',ptranaplica,Ccargo ,pFolioSuacSUC)
      RETURNING CCodret_c, CMensaje;

    IF (CCodret_c = "005") THEN
      LET cCodRet='005'; -- Intento de cargo con crédito vencido "BT" y bloqueado y sin saldo suficiente
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
        BEGIN WORK;
      END IF;
      RETURN cCodRet;
    END IF;

    IF (CCodret_c = "207") THEN
      LET cCodRet='207'; -- Intento de cargo con crédito vencido "BT" y bloqueado
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
        BEGIN WORK;
      END IF;
      RETURN cCodRet;
    END IF;

    IF (CCodret_c <> "000") THEN
      LET cCodRet='009'; --definir codigo en caso de falla en el cargo o abono
      --ROLLBACK WORK;
      IF (wBegin = "S") THEN
        BEGIN WORK;
      END IF;
      RETURN cCodRet;
    END IF;


-------------- >> Actualiza tabla de movimientos (acl_movimiento) relacionados a la aclaración para indicar que se aplicaron

    IF (CCodret_c = "000") THEN
      UPDATE acl_movimiento
      SET exitoso = '1',
          fecha_afectacion = CURRENT,
          numero_transaccion = ptranaplica,
          secuencia = CSecuencia_acl_mov
      WHERE pky_movimiento = CSecuencia
      AND folio_csuac = pFolioSuac;
    END IF;

    END FOREACH;

END IF; --Fin pTipo credito

END IF;

--Debito
IF (pTipo = 2) THEN
  IF (pDictamen = 'AD') THEN

    IF EXISTS (SELECT * FROM acl_movimiento WHERE folio_csuac = pFolioSuac AND cargo = 0 AND exitoso = 1) THEN
      LET isAbono = 1;
      ELSE
      LET isAbono = 0;
    END IF;

    IF EXISTS (SELECT * FROM acl_movimiento WHERE folio_csuac = pFolioSuac AND cargo = 1) THEN
      LET isCargo = 1;
      ELSE
      LET isCargo = 0;
    END IF;

    IF (isAbono = 1 AND isCargo = 0)
    THEN
      FOREACH WITH hold
        -- >> Insertar movimiento cargo.
        SELECT a.pky_movimiento,a.folio_csuac, a.monto, a.montoprocedente, b.trans_cargo_ajuste, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento, a.fky_tipo_movimiento
        INTO
        Ipky_movimiento,     -- pky_movimiento,          --> pky del movimiento padre
        pFolioSuac,          -- folio_csuac,            --> Mismo que el padre -- ok
        v_monto,             -- monto,            --> Mismo que el padre -- para afectación contable
        v_montoprocedente,   -- montoprocedente,      --> Mismo que el padre -- Breviario cultural
        Ctrans_cargo_ajuste,   -- numero_transaccion,     --> null -- Trans_cargo_por_ajuste para que haga la afectación con esa transacción.
        Ifky_producto,       -- fky_producto,         --> Mismo que el padre
        v_fky_tipo_evento,   -- fky_tipo_evento,      --> Mismo que el padre
        Ipky_tipo_movimiento, -- fky_tipo_movimiento,     --> Mismo que el padre
        FIpky_tipo_movimiento
        FROM acl_movimiento a, acl_tipo_movimiento b
        WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
        AND a.folio_csuac = pFolioSuac
        AND a.cargo = 0
        AND a.exitoso = 1
        AND a.calculado = 0
        AND a.procede = 1
        AND a.fecha_afectacion IS NOT NULL
        AND a.duplicado = 0
        --AND a.fky_tipo_movimiento <> 332 --> Validación no duplicar intereses abonados

        /*Obtiene interes a v_interes*/
        SELECT a.montoprocedente
        INTO
        v_interes
        FROM acl_movimiento a, acl_tipo_movimiento b
        WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
        AND a.folio_csuac = pFolioSuac
        AND a.exitoso = 1
        AND a.calculado = 1
        AND a.fecha_afectacion IS NOT NULL
        AND a.duplicado = 0;

      /*Suma interes a v_montoprocedente*/
      IF(v_interes <> 0)  THEN
          LET v_montoprocedente = (v_montoprocedente+v_interes);
      END  IF;

        SELECT MAX (secuencia)
        INTO CSecuencia_acl_mov
        FROM acl_movimiento
        WHERE folio_csuac = pFolioSuac;

        SELECT fky_padre
        INTO v_fky_padre
        FROM acl_movimiento a
        WHERE folio_csuac = pFolioSuac
              AND monto = v_monto;

        LET v_montoprocedente = (v_montoprocedente-pMontoAD);

        IF (v_fky_padre IS NULL ) THEN
          --Realiza el  insert al movimiento por el monto
          INSERT INTO acl_movimiento VALUES (
          -- pky_movimiento                         calculado     cargo     cargo_ajuste  exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
          MOVIMIENTO_SEQ.nextval,     0,            1,        1,        0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      pMontoAD,  v_montoprocedente,  1,            Ctrans_cargo_ajuste,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              null, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null, 0, 0);

        END IF;

      END FOREACH; -- FIN foreach movimiento

    END IF; -- fin if insertar movimiento sino existe cargo

  END IF; -- fin predictamen AD

  IF (pRequiereAut == 0) --Aplicar cargo si no requiere autorizacion
    THEN
      SELECT numero_cuenta --> Cuenta de Captación
        INTO CnumCuenta
        FROM acl_producto a, acl_aclaracion b
       WHERE b.fky_producto = a.pky_producto
         AND b.folio_csuac = pFolioSuac ;

  LET CnumCuenta = CnumCuenta;

    FOREACH WITH hold

    SELECT pky_movimiento, /*numero_cuenta,*/ numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion,trans_cargo_ajuste, nvl(cargo,0)
          INTO CSecuencia, /*CnumCuenta,*/ CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,CtranCargoAjuste, Ccargo
          FROM acl_movimiento a
          LEFT OUTER JOIN acl_producto b on (a.fky_producto = b.pky_producto)
          LEFT OUTER JOIN acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
         WHERE (folio_csuac = pFolioSuac AND (procede IS NULL OR procede = 1) AND (exitoso IS NULL OR exitoso <> '1') AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END)
       OR  (folio_csuac = pFolioSuac AND (procede IS NULL OR procede = 1) AND (exitoso IS NULL OR exitoso <> '1') AND fky_tipo_movimiento = 332 ) --> Abono de intereses

  LET CnumCuenta = CnumCuenta;
  LET CmontoAcla = pMontoAD;

       IF CnumCuenta IS NULL THEN
              LET cCodRet='002'; -- >> "Número de cuenta es nulo"
              ROLLBACK WORK;
              IF (wBegin = "S") THEN
                  BEGIN WORK;
              END IF;
              RETURN cCodRet;
           END IF;

           IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
              LET cCodRet='004'; --> ok
              RETURN cCodRet;
           END IF;

           IF (CnumTarjeta is null) then
              LET CnumTarjeta = '';
           END IF;

      SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
      INTO v_fecha_folio
      FROM bdicheq:sc_fechas;

      LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(pFolioSuac,10,0);

      IF (pDictamen = 'AD') THEN --> Transaccion cargo por ajuste
        LET ptranaplica = CtranCargoAjuste;
      END IF;

      IF (pDictamen IN ('AD')) THEN

      CALL bdicheq:cons_saldo (CnumCuenta) RETURNING  vcodret,vsdodisp,vstatuscta;

            CALL bdicheq:cargo_ref(pEmpresa, '9250', user, ptranaplica, '0000', pFolioSuacSUC, CnumCuenta, 0, CmontoAcla, '01', pFolioSuac, CnumTarjeta, user)
            RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;

      END IF

      LET cCodRet = DCodret_a;

      IF (DCodret_a = "005") THEN
          LET cCodRet = '005'; -- Intento de cargo con credito vencido "BT" y bloqueado y sin saldo suficiente
          ROLLBACK WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

      IF (DCodret_a = "207") THEN
          LET cCodRet = '207'; -- Intento de cargo con crédito vencido "BT" y bloqueado
          ROLLBACK WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;


      IF (DCodret_a = "400") THEN
          LET cCodRet = '400'; -- Fondos insuficientes débito
        --  ROLLBACK WORK;  -- Evitar el rollback cuando no se tenga saldo, para mantener la comisión insertada
        COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

      IF (DCodret_a = "552") THEN
          LET cCodRet = '552'; -- Naturaleza de la transaccion incorrecta abono
          --ROLLBACK WORK;
          COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

      IF (DCodret_a = "551") THEN
          LET cCodRet = '551'; -- Naturaleza de la transaccion incorrecta cargo
          --ROLLBACK WORK;
          COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;


      IF (DCodret_a = "300") THEN
          LET cCodRet = '300'; -- Cuenta bloqueada
          --ROLLBACK WORK;
          COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

      IF (DCodret_a = "301") THEN
          LET cCodRet = '301'; -- Cuenta bloqueada abonos
          --ROLLBACK WORK;
          COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

      IF (DCodret_a = "060") THEN
          LET cCodRet = '060'; -- Cuenta bloqueada
          --ROLLBACK WORK;
          COMMIT WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

        IF (DCodret_a = "200") THEN
          LET cCodRet = '200'; -- Cuenta cancelada
          ROLLBACK WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;


      IF (DCodret_a <> "000") THEN
          LET cCodRet = '009'; -- definir codigo en caso de falla en el cargo o abono
           -- ROLLBACK WORK;
          IF (wBegin = "S") THEN
            BEGIN WORK;
          END IF;
          RETURN cCodRet;
      END IF;

    -------------- >> Consulta de secuencia

      LET CSecuencia_acl_mov = 0;

      SELECT MAX (secuencia)--, folio_csuac
      INTO CSecuencia_acl_mov
      FROM acl_movimiento
      WHERE folio_csuac = pFolioSuac;

    -------------- >> Validación de secuencia
      IF (CSecuencia_acl_mov is null) THEN
          LET CSecuencia_acl_mov = 1;
        ELSE
          LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;
      END IF;

    -------------- >> Actualización de datos de aclaración

      IF (pDictamen IN ('AD')) THEN

           IF (DCodret_a="000") THEN
           UPDATE acl_movimiento
           SET cargo = 1,
             exitoso = '1',
             procede = 1,
             fecha_afectacion = CURRENT,
             numero_transaccion = ptranaplica,
             secuencia = CSecuencia_acl_mov
          WHERE pky_movimiento = CSecuencia
            AND folio_csuac = pFolioSuac;
          ELSE
            UPDATE acl_movimiento
            SET cargo = 1,
             exitoso = '0',
             procede = 1,
             numero_transaccion = ptranaplica,
             secuencia = CSecuencia_acl_mov
          WHERE pky_movimiento = CSecuencia
           AND folio_csuac = pFolioSuac;

           END IF; --fin actualizacion movimiento

      END IF;

      LET v_contador = v_contador + 1;

    END FOREACH; -- fin foreach opten parametros cargo

    END IF --Fin RequiereAut

    END IF --Fin pTipo debito

    COMMIT WORK;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

  END;

 RETURN cCodRet;

END PROCEDURE
DOCUMENT
'Sp sp_cargoDebitoCreditoAD',
'Realiza el cargo por ajuste diferencia',
'Sistema: Aclaraciones RQM 438',
'AUTOR : Rodolfo Velazquez',
'FECHA : 01/Junio/2017',
'VERSION: 1.0.0';

CREATE PROCEDURE "informix".sp_consulta_aclaraciones_producto_cliente_2(p_tipo_consulta INTEGER, p_id_producto INTEGER,p_tipo_producto INTEGER, p_num_cliente INTEGER, p_pky_rango_importe INTEGER)
RETURNING   CHAR(5) AS s_codRet,
 VARCHAR(20) AS s_monto_total_aclaraciones,
 VARCHAR(20) AS s_numero_aclaraciones_con_abono,
 VARCHAR(20) AS s_importe_aclaraciones_con_abono,
 VARCHAR(20) AS s_numero_aclaraciones_sin_abono,
 VARCHAR(20) AS s_importe_aclaraciones_sin_abono,
 VARCHAR(20) AS s_total_numero_aclaraciones,
 VARCHAR(20) AS s_total_importe_aclaraciones;

DEFINE cod_retorno  CHAR(5);
DEFINE monto_total_aclaraciones_producto_cliente MONEY;
DEFINE numero_aclaraciones_con_abono INTEGER;
DEFINE numero_aclaraciones_sin_abono INTEGER;
DEFINE importe_aclaraciones_con_abono MONEY;
DEFINE importe_aclaraciones_sin_abono MONEY;
DEFINE total_numero_aclaraciones INTEGER;
DEFINE total_importe_aclaraciones MONEY;
DEFINE iSqlErr INTEGER;
DEFINE uno INTEGER;
DEFINE anio INTEGER;
DEFINE cero INTEGER;
DEFINE resolucion_con_abono_temporal INTEGER;
DEFINE resolucion_sin_abono_temporal INTEGER;
DEFINE estatus_aclaracion_ingresada INTEGER;
DEFINE estatus_aclaracion_con_dic_sin_digi INTEGER;
DEFINE estatus_aclaracion_finalizada INTEGER;
DEFINE estatus_corp_gral_pred_aceptado INTEGER;
DEFINE estatus_corp_gral_cierre_prev_no_real INTEGER;
DEFINE estatus_corp_gral_cierre_prev INTEGER;
DEFINE estatus_corp_analisis INTEGER;
DEFINE estatus_corp_por_abonar INTEGER;
DEFINE estatus_corp_dictamen_acep INTEGER;
DEFINE aclaracion_cuenta_movil INTEGER;
DEFINE estatus_dictamen_abonada_sin_autor INTEGER;
DEFINE resolucion_con_abono INTEGER;
DEFINE estatus_corp_predictaminada INTEGER;
DEFINE last_year INTEGER;
DEFINE monthSys INTEGER;
DEFINE daySys INTEGER;
DEFINE fechaPasada VARCHAR(50);
DEFINE v_rango_menor INTEGER;
DEFINE v_rango_mayor INTEGER;

LET  last_year = YEAR(CURRENT);
LET  monthSys  = MONTH(CURRENT);
LET  daySys= DAY (CURRENT);
LET fechaPasada=TO_CHAR(last_year-1) || '-' || TO_CHAR(monthSys)|| '-' || TO_CHAR(daySys);
LET total_numero_aclaraciones = 0;
LET total_importe_aclaraciones = 0;
LET numero_aclaraciones_con_abono =0;
LET numero_aclaraciones_sin_abono = 0;
LET monto_total_aclaraciones_producto_cliente= 0;
LET importe_aclaraciones_con_abono = 0;
LET importe_aclaraciones_sin_abono = 0;
LET cod_retorno = '000*';
LET uno = '1';
LET anio = '365';
LET cero ='0';	
LET estatus_aclaracion_con_dic_sin_digi = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclaracion idx_acl_ctvo)}pky_estatus_aclaracion FROM bdiaclaracion:"informix".acl_estatus_aclaracion where nombre='ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO');
LET estatus_corp_gral_cierre_prev = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'CIERRE_PREVENTIVO');
LET estatus_corp_gral_cierre_prev_no_real = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'CIERRE_PREVENTIVO_NO_REALIZADO');
LET resolucion_con_abono_temporal = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_resolucion)}pky_resolucion FROM bdiaclaracion:"informix".acl_resolucion where nombre = 'abonoMontoMaximo');
LET resolucion_sin_abono_temporal = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_resolucion)}pky_resolucion FROM bdiaclaracion:"informix".acl_resolucion where nombre='analisisMontoMaximo');
LET resolucion_con_abono  = (SELECT {+INDEX(bdiaclaracion:"informix".acl_resolucion idx_acl_resolucion)}pky_resolucion FROM bdiaclaracion:"informix".acl_resolucion where nombre='abonoMontoMaximoBC');
LET estatus_aclaracion_ingresada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclaracion idx_acl_ctvo)}pky_estatus_aclaracion FROM bdiaclaracion:"informix".acl_estatus_aclaracion where nombre='ACLARACION_INGRESADA');
LET estatus_corp_analisis = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)} pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'ANALISIS');
LET estatus_corp_predictaminada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'PREDICTAMINADA');
LET estatus_corp_por_abonar = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'POR_ABONAR');
LET estatus_aclaracion_finalizada = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_aclaracion idx_acl_estatus_corporativo)}pky_estatus_aclaracion FROM bdiaclaracion:"informix".acl_estatus_aclaracion where nombre = 'ACLARACION_FINALIZADA');
LET estatus_corp_dictamen_acep = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'DICTAMEN_ACEPTADA');
LET aclaracion_cuenta_movil = (SELECT pky_cat_tipo_aclaracion from bdiaclaracion:"informix".acl_cat_tipo_aclaracion where nombre = 'ACLARACION_VIA_TELEFONICA_TRAN');
LET estatus_dictamen_abonada_sin_autor = (SELECT {+INDEX(bdiaclaracion:"informix".acl_estatus_corporativo idx_acl_estatus_corporativo)}pky_estatus_corporativo FROM bdiaclaracion:"informix".acl_estatus_corporativo where nombre = 'DICTAMEN_ABONADA_SIN_AUTORIZACION');

LET v_rango_menor = 0;
LET v_rango_mayor = 0;

BEGIN

ON EXCEPTION
	SET iSqlErr
	IF iSqlErr <> 0 THEN
		RETURN  '001*',iSqlErr||'*',0||'*',0||'*',0||'*',0||'*',0||'*',0||'*'; --RETURNING
	END IF;	
END EXCEPTION;
SET ISOLATION TO DIRTY READ; 
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/consulta_aclaraciones_producto_cliente"||"_"||""||TRIM(p_num_cliente)||""||"_34.out"; --> TRACE DESDE APP
--TRACE ON;

/* Suma de abonos por rango */

IF (p_tipo_consulta = '1') THEN
		/* Obtiene los rangos del intervalo (pky_rango_importe) */
		SELECT rango_menor,rango_mayor
		INTO v_rango_menor,v_rango_mayor
		FROM acl_rango_importe WHERE pky_rango_importe = p_pky_rango_importe;

		LET monto_total_aclaraciones_producto_cliente = (SELECT NVL(SUM({+INDEX(bdiaclaracion:"informix".acl_movimiento u141_147)}mov.montoprocedente),cero) AS MONTO FROM acl_aclaracion acl INNER JOIN acl_producto pr ON pr.pky_producto=acl.fky_producto INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto = pr.fky_tipo_producto INNER JOIN acl_movimiento mov ON mov.fky_aclaracion = acl.pky_aclaracion WHERE acl.fky_cat_tipo_aclaracion <> aclaracion_cuenta_movil AND acl.num_cliente = p_num_cliente AND ( (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general  =estatus_corp_analisis) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_finalizada and acl.fky_estatus_corp_general =estatus_corp_dictamen_acep  and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_ingresada and acl.fky_estatus_corp_general=estatus_corp_gral_cierre_prev_no_real) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general=estatus_corp_gral_cierre_prev and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general=estatus_corp_dictamen_acep and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general=estatus_corp_dictamen_acep and acl.procede=cero) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general=estatus_dictamen_abonada_sin_autor and acl.procede=uno) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general=estatus_corp_predictaminada ) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_finalizada and acl.fky_estatus_corp_general=estatus_dictamen_abonada_sin_autor and acl.procede=uno) ) AND mov.montoprocedente BETWEEN v_rango_menor and v_rango_mayor AND acl.fechacaptura BETWEEN TO_DATE(fechaPasada,"%Y-%m-%d") AND CURRENT AND (mov.cargo=cero AND mov.exitoso=uno) );
END IF;

/* Consultas para el tablero de seguimiento */

IF (p_tipo_consulta = '2') THEN

	DROP TABLE IF EXISTS tblAclaracionesAbono;
	SELECT NVL({+INDEX(bdiaclaracion:"informix".acl_movimiento u141_147)}mov.montoprocedente,cero) AS MONTO FROM bdiaclaracion:"informix".acl_aclaracion acl INNER JOIN bdiaclaracion:"informix".acl_producto pr ON pr.pky_producto=acl.fky_producto INNER JOIN bdiaclaracion:"informix".acl_tipo_producto tp ON tp.pky_tipo_producto = pr.fky_tipo_producto INNER JOIN bdiaclaracion:"informix".acl_movimiento mov ON mov.fky_aclaracion = acl.pky_aclaracion WHERE acl.fky_cat_tipo_aclaracion <> aclaracion_cuenta_movil AND acl.num_cliente= p_num_cliente AND tp.tipo_producto = p_tipo_producto AND ((acl.fky_estatus_aclaracion = estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_analisis AND (mov.cargo=cero AND mov.exitoso=uno)) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_finalizada and acl.fky_estatus_corp_general = estatus_corp_dictamen_acep and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_gral_cierre_prev_no_real AND (mov.cargo=cero AND mov.exitoso=uno)) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general = estatus_corp_gral_cierre_prev and acl.procede = uno ) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general = estatus_corp_dictamen_acep and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_finalizada and acl.fky_estatus_corp_general = estatus_dictamen_abonada_sin_autor and acl.procede=uno) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_predictaminada AND mov.cargo=0) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general = estatus_dictamen_abonada_sin_autor and acl.procede=uno)) AND  acl.fechacaptura BETWEEN TO_DATE(fechaPasada,"%Y-%m-%d") AND CURRENT
	INTO TEMP tblAclaracionesAbono WITH NO LOG;	
	CREATE INDEX "informix".idx_tblAclaracionesAbono ON tblAclaracionesAbono(MONTO) ONLINE;
	
	UPDATE STATISTICS LOW FOR TABLE tblAclaracionesAbono;
	
	DROP TABLE IF EXISTS tblAclaracionesSinAbono;
	SELECT NVL({+INDEX(bdiaclaracion:"informix".acl_movimiento u141_147)}mov.montoprocedente,cero) AS MONTO FROM bdiaclaracion:"informix".acl_aclaracion acl INNER JOIN bdiaclaracion:"informix".acl_producto pr ON pr.pky_producto=acl.fky_producto INNER JOIN bdiaclaracion:"informix".acl_tipo_producto tp ON tp.pky_tipo_producto = pr.fky_tipo_producto INNER JOIN bdiaclaracion:"informix".acl_movimiento mov ON mov.fky_aclaracion = acl.pky_aclaracion WHERE acl.fky_cat_tipo_aclaracion <> aclaracion_cuenta_movil AND acl.num_cliente= p_num_cliente AND tp.tipo_producto = p_tipo_producto AND ((acl.fky_estatus_aclaracion = estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_analisis and (acl.procede is null and mov.cargo is null)) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_finalizada and acl.fky_estatus_corp_general = estatus_corp_dictamen_acep and acl.procede=cero) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_gral_cierre_prev_no_real and (acl.procede is null OR acl.procede == 0)) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general = estatus_corp_gral_cierre_prev and acl.procede=cero) OR (acl.fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi and acl.fky_estatus_corp_general = estatus_corp_dictamen_acep and acl.procede=cero) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_por_abonar and acl.procede is null) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_predictaminada and mov.cargo is null) OR (acl.fky_estatus_aclaracion= estatus_aclaracion_ingresada and acl.fky_estatus_corp_general = estatus_corp_predictaminada and (acl.procede = 0 AND mov.cargo=1))) AND  acl.fechacaptura BETWEEN TO_DATE(fechaPasada,"%Y-%m-%d") AND  CURRENT
	INTO TEMP tblAclaracionesSinAbono WITH NO LOG;	
    CREATE INDEX "informix".idx_tblAclaracionesSinAbono ON tblAclaracionesSinAbono(MONTO) ONLINE;
	
	UPDATE STATISTICS LOW FOR TABLE tblAclaracionesSinAbono;	

	LET importe_aclaraciones_con_abono = (SELECT SUM(MONTO)FROM tblAclaracionesAbono);
	LET numero_aclaraciones_con_abono = (SELECT COUNT (*) FROM tblAclaracionesAbono);
	LET importe_aclaraciones_sin_abono = (SELECT SUM(MONTO)FROM tblAclaracionesSinAbono);
	LET numero_aclaraciones_sin_abono = (SELECT COUNT (*) FROM tblAclaracionesSinAbono);
	LET total_numero_aclaraciones = (numero_aclaraciones_sin_abono + numero_aclaraciones_con_abono);
	LET total_importe_aclaraciones = (importe_aclaraciones_sin_abono + importe_aclaraciones_con_abono);

END IF;

RETURN cod_retorno, monto_total_aclaraciones_producto_cliente||'*', numero_aclaraciones_con_abono||'*', importe_aclaraciones_con_abono||'*', numero_aclaraciones_sin_abono||'*', importe_aclaraciones_sin_abono||'*', total_numero_aclaraciones||'*',total_importe_aclaraciones;
END
END PROCEDURE
DOCUMENT
'Sp : sp_consulta_aclaraciones_producto_cliente',
'Sistema : Aclaraciones',
'AUTOR : Root',
'Modificacion : Bancoppel',
'Area  	Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador : Norberto Corona Berruecos',
'FECHA : 13/Marzo/2018',
'VERSION : 2.0.0',
'BD : bdiaclaracion';

CREATE PROCEDURE "informix".sp_aplica_cierre_preventivo()
--V. 3/4/2019 (13:00 PM)
        RETURNING      
        VARCHAR (3) AS sCodRet, --Salida de codigo de retorno
        VARCHAR(10) AS sfolio_csuac, -- Salida de folio csuac procesado
        VARCHAR (100) AS sProcesadoCorrectamente; -- Clave de Procesamiento del folio
        
        --Definicion de variables

        DEFINE v_fechacaptura DATE;
        DEFINE v_num_cliente VARCHAR(10);
        DEFINE v_tipo_producto VARCHAR(1);
        DEFINE v_tipo_movimiento VARCHAR(1);                       
        DEFINE v_resp_estimada INTEGER;
        DEFINE v_resp_estimada_intl INTEGER;                       
        DEFINE v_importereclamado MONEY;
        DEFINE v_folio_csuac VARCHAR(10);
        DEFINE v_nombre_origen VARCHAR(50);
        DEFINE v_procesadoCorrectamente VARCHAR (100);
        DEFINE v_pky_aclaracion INTEGER;
        DEFINE v_fky_estatus_aclaracion INTEGER;
        DEFINE v_fky_estatus_corp_analisis INTEGER;
        DEFINE V_fky_estatus_corp_general INTEGER;
        DEFINE v_fechaCierre date;
        -- Retorno sp_consulta_tipo_movimiento
        DEFINE v_resultado_origen VARCHAR(1);
        DEFINE v_modo_entrada  VARCHAR(2);
        DEFINE v_num_tarjeta VARCHAR (16);
        DEFINE v_folioSuc VARCHAR (30);
        DEFINE v_pky_origen_evento INTEGER;

        -- Calculo para dias de respuesta maxima
        DEFINE v_dias_respuesta_maxima_folio INTEGER;    
        DEFINE v_fecha_resultante DATE;

        --SALIDAS DE CODIGO DE ERROR DE SPS DE AFECTACIONES
        DEFINE cCodRet CHAR(3); --OUT CODE ERROR CREDITO
        DEFINE v_CodRet CHAR(3);
        DEFINE iSqlErr INTEGER;
        DEFINE wBegin CHAR(1);

        --VARIABLES DE DICTAMEN
        DEFINE v_observaciones LVARCHAR;
        DEFINE v_procede SMALLINT;
        DEFINE v_cod_resolucion INTEGER;
        DEFINE v_estatus_aclaracion INTEGER;
        DEFINE v_estatus_aclaracion_no_realizado INTEGER;
        DEFINE v_nuevo_estatus_general INTEGER;
        DEFINE v_dias_conclusion INTEGER;
        DEFINE v_fecha_temp DATE;
        DEFINE v_contador INTEGER;

        --VARIABLES DE CIERRES PREVENTIVOS
        DEFINE v_cierreAutomatico VARCHAR (50);
        DEFINE v_cierreAutomaticoNoRealizadoAfectacion VARCHAR (50);
        DEFINE v_cierreAutomaticoNoRealizadoOrigenMov VARCHAR(50);
        DEFINE v_resolucion INTEGER;
        DEFINE v_comentario LVARCHAR;
        DEFINE fky_cierre_en_proceso INTEGER;

            --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplica_cierre_preventivo"||CURRENT||"_34.out"; --> TRACE DESDE APP
            --TRACE ON;

           SET ISOLATION TO COMMITTED READ;
           SET LOCK MODE TO WAIT 3;

        BEGIN
        
        ON EXCEPTION SET iSqlErr
            LET v_CodRet = '003';
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN v_CodRet,'.'||iSqlErr||'.',v_pky_aclaracion;
        END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET wBegin = "S";
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

        
        LET cCodRet = '000'; -- CODE ERROR AFECTACION EXITO SET
        LET v_resultado_origen = '0';
        --RESOLUCION/ACCION PARA BITACORA
        
        LET v_cierreAutomatico ='cierreAutomatico';
        LET v_cierreAutomaticoNoRealizadoAfectacion = 'cierreAutomaticoNoRealizadoAfectacion';
        LET v_cierreAutomaticoNoRealizadoOrigenMov = 'cierreAutomaticoNoRealizadoOrigenMov';
        
        ---seteo de valores para dictamen a cierre preventivo
        LET v_observaciones ='SOLICITUD SI PROCEDE SE BONIFICA LA CANTIDAD CORRESPONDIENTE AL IMPORTE RECLAMADO';
        LET v_procede ='1';
        LET v_cod_resolucion='8'; -- Politica Interna
        LET v_estatus_aclaracion='3'; -- Aclaracion con dictamen sin digitalizar
        LET v_estatus_aclaracion_no_realizado = '2';
        LET wBegin = 'N';

        SELECT pky_estatus_corporativo INTO fky_cierre_en_proceso 
			FROM "informix".acl_estatus_corporativo WHERE nombre = 'CIERRE_EN_PROCESO';
        
                  FOREACH 
                        --{+INDEX(acl_aclaracion pky_aclaracion)}
                    --SELECT FIRST 10
                                
                        SELECT {+INDEX(acl_aclaracion idx_folio_csuac)} SKIP 0
							   acl.pky_aclaracion,
                               acl.fechacaptura,
                               acl.folio_csuac,
                               acl.fky_estatus_aclaracion,
                               acl.fky_estatus_corp_analisis,
                               acl.fky_estatus_corp_general,
                               acl.importereclamado,
                               acl.num_cliente,
                               oe.pky_origen_evento,
                               oe.nombre,
                               trim(REPLACE(mov.folio_suc,'i','')),
                               pr.numero_tarjeta,
                               tp.tipo_producto,
                               acl.tipo_movimiento,
                               (ri.resp_estimada_cierre_nacional-1),
                               (ri.resp_estimada_cierre_intl-1),
                               ((today+ 1) - fechacaptura)
                        INTO   
                               v_pky_aclaracion, 
                               v_fechacaptura,
                               v_folio_csuac,
                               v_fky_estatus_aclaracion,
                               v_fky_estatus_corp_analisis,
                               V_fky_estatus_corp_general,
                               v_importereclamado,
                               v_num_cliente,
                               v_pky_origen_evento, 
                               v_nombre_origen,
                               v_folioSuc,
                               v_num_tarjeta,
                               v_tipo_producto,
                               v_tipo_movimiento,
                               v_resp_estimada,
                               v_resp_estimada_intl,
                               v_dias_conclusion
                        FROM   acl_aclaracion acl -- tabla principal
                        INNER JOIN acl_regla_negocio rn ON acl.fky_regla_negocio = rn.pky_id_regla-- Regla de negocio a la que se asocio la aclaracion
                        INNER JOIN acl_rango_importe ri ON rn.pky_id_regla= ri.fky_id_regla --cruce con rango de importe definido al folio
                        INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto = rn.fky_tipo_producto -- cruce con tipo producto DEBITO/CREDITO
                        INNER JOIN acl_tipo_evento te ON te.pky_tipo_evento = acl.fky_tipo_evento --Mediante el tipo de evento del folio
                        INNER JOIN acl_origen_evento oe ON oe.pky_origen_evento = te.fky_origen_evento -- Se obtendra el origen POS/ATM
                        INNER JOIN acl_movimiento mov ON mov.folio_csuac = acl.folio_csuac  -- movimiento para obtener targeta
                        INNER JOIN acl_producto pr ON pr.pky_producto= acl.fky_producto -- Producto asociado para obtener targeta
                        WHERE 
                            mov.fky_padre is null and mov.fky_aclaracion IS NOT NULL   -- Movimiento
                            AND ((acl.fky_estatus_aclaracion='2' AND acl.fky_estatus_corp_general='1') OR (acl.fky_estatus_aclaracion='2' AND acl.fky_estatus_corp_general='2'))
							AND (te.cierre_automatico=1) --RQM 521-3
                            AND (acl.fky_estatus_corp_analisis <> fky_cierre_en_proceso or acl.fky_estatus_corp_analisis is null)
                             AND -- Folios en anaÂ¡lisis aclaraciones, no importanto si esta en area externa
                            ri.rango_menor <= acl.importereclamado AND ri.rango_mayor >= acl.importereclamado -- y que tengan el importe reclamado de dicha aclaracion
                      
                      
                        LET v_procesadoCorrectamente='PROCESADO'; -- Aplica el cierre preventivo 
                        LET v_CodRet = '000';
                        LET cCodRet = '000';
                        LET v_resolucion = (SELECT pky_resolucion FROM acl_resolucion WHERE nombre = 'cierreAutomatico');
                        LET v_nuevo_estatus_general = (SELECT pky_estatus_corporativo FROM acl_estatus_corporativo where nombre='CIERRE_PREVENTIVO');
                        LET v_comentario = 'Solicitud si procede se bonifica la cantidad correspondiente al importe reclamado.';
                        LET v_fechaCierre = CURRENT;
                            
    -- ====================     Iniciando las validaciones de folios Nacionales/Internacionales.
                            -- Es necesario saber de que tipo de folio es para saber cuantos dias calcular 
                            IF (trim(v_nombre_origen) <> 'POS' AND trim(v_nombre_origen) <> 'ATMS') THEN -- Se tomaran como folios nacionales

                                        LET v_tipo_movimiento = 'V';
                                       
                            ELSE    -- Se tomaran como folios Internacionales/Nacionales --  POS/ATMS 
                              
                                       IF((v_tipo_movimiento IS NULL) OR (v_tipo_movimiento='') OR v_tipo_movimiento='N') THEN -- No tiene origen de movimiento, habra que buscarlo al SP de tipo de movimiento 
                              
                                            --Llamada nuevamente mediante el sp para obtener el valor                                            
                                            CALL "informix".sp_consulta_tipo_movimiento(v_folioSuc,v_num_tarjeta,v_pky_origen_evento)
                                            RETURNING v_resultado_origen,v_modo_entrada;

                                            LET v_tipo_movimiento = v_resultado_origen;

                                            -- NO se encontro un tipo de movimiento determinado, retorna el folio no procesado TM (Tipo Movimiento)   
                                            IF ((v_tipo_movimiento IS NULL) OR (v_tipo_movimiento = '') OR v_tipo_movimiento='N')  THEN 
                                                
                                                LET v_procesadoCorrectamente = 'NO_PROCESADO_TM'; -- NO PROCESADO POR NO TENER ORIGEN DEFINIDO
                                                LET v_CodRet = '001';
                                                LET v_tipo_movimiento = 'X';
                                                LET v_nuevo_estatus_general = (SELECT pky_estatus_corporativo FROM acl_estatus_corporativo where nombre='CIERRE_PREVENTIVO_NO_REALIZADO');
                                                LET v_resolucion = (SELECT pky_resolucion FROM acl_resolucion WHERE nombre = 'cierreAutomaticoNoRealizadoAfectacion');
                                                LET v_comentario = 'Sin realizar el cierre automÃ¡tico';
                                                LET v_fechaCierre = NULL;
                                                LET v_estatus_aclaracion = v_estatus_aclaracion_no_realizado;
                                                LET v_procede = NULL;
                                                LET v_dias_conclusion=NULL;
                                                
--============================= TIPO MOVIMIENTO
                                                LET v_fecha_resultante = (today - v_resp_estimada);  
  
                                                IF (v_fecha_resultante >= v_fechacaptura AND V_fky_estatus_corp_general <> v_nuevo_estatus_general) THEN

                                  
                                                UPDATE acl_aclaracion 
                                                SET fecha_dictamen = v_fechaCierre,
                                                    montoprocedente=v_importereclamado,
                                                    predictamen=v_observaciones,
                                                    procede=v_procede,
                                                    fky_estatus_aclaracion=v_estatus_aclaracion,
                                                    fky_estatus_corp_general=v_nuevo_estatus_general,
                                                    fky_tipo_codigo_resolucion=v_cod_resolucion,
                                                    dias_conclusion= v_dias_conclusion
                                                WHERE folio_csuac = v_folio_csuac;    
                                                
                                             
                                                INSERT INTO "informix".acl_entrada_bitacora
                                                    VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                           v_comentario,                   -- descripcion   
                                                           CURRENT,                      -- fechaHOra
                                                           v_folio_csuac,                -- folio_csuac   
                                                           v_resolucion,                    -- accion/acl_resolucion 
                                                           v_pky_aclaracion,             -- pky_aclaracion
                                                           NULL,                     -- fky_area
                                                           v_fky_estatus_aclaracion,        -- fky_estatus_aclaracion
                                                           v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                                           v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                                           '0');                          -- Usuario   

                                                    RETURN  v_CodRet,v_folio_csuac, v_procesadoCorrectamente
                                                    WITH resume;
--============================= end tipo movimiento
                                                else
                                                    let v_fecha_resultante = 0;
                                                end if;

                                            END IF;

                                       END IF;

                            END IF; 
                            --* Termina de validar Tipo movimiento folio por procesar
    -- ==================== Terminando las validaciones NACIONALES/INTERNACIONALES

    -- ==================== Determinando DIAS MAXIMOS de respuesta
                           IF ((v_tipo_movimiento IS NOT NULL) AND (v_tipo_movimiento <> '') OR v_tipo_movimiento <> 'N') THEN 

                                    -- Dias de respuesta maxima
                                    IF (v_tipo_movimiento ='V' ) THEN  
                                        LET v_dias_respuesta_maxima_folio = v_resp_estimada; -- Respuesta maxima Nacional
                                    ELSE 
                                        LET v_dias_respuesta_maxima_folio = v_resp_estimada_intl; -- Respuesta maxima Internacional
                                    END IF;

                                    LET v_fecha_resultante = 0;

                                    LET v_fecha_resultante = today- v_dias_respuesta_maxima_folio;

                                    --Aplicar proceso de cierre automatico
                                    IF (v_fecha_resultante >= v_fechacaptura) THEN

                                        -- Se pretende bonificar, dependiendo del tipo de producto
                                        IF (v_tipo_producto = '1') THEN -- Bonificacion productos credito
                                            
                                            
                                           call  bdicred:sp_aplicaaclaracredito('001', v_folio_csuac, 'AS' , '0' , 'acl_auto' )
                                           RETURNING cCodRet;
                                         
                                        ELSE -- bonificacion productos debito
                                        
                                            call bdicheq:sp_aplicaaclaradebito('001', v_folio_csuac, 'AS' , '0' , 'acl_auto' )
                                            RETURNING cCodRet;    
                                         
                                        END IF;

                                        -- Validando salida de ejecucionde SP de afectacion

                                        --Afectacion cuentas -- ABONO
                                        IF cCodRet <> '000' THEN

                                         --Afectacion credito no realizada -- ABONO
                                             LET v_procesadoCorrectamente = 'NO_PROCESADO_AM';                                             LET v_CodRet = '002';
                                             LET v_resolucion = (SELECT pky_resolucion FROM acl_resolucion WHERE nombre = 'cierreAutomaticoNoRealizadoAfectacion');
                                             LET v_nuevo_estatus_general = (SELECT pky_estatus_corporativo FROM acl_estatus_corporativo where nombre='CIERRE_PREVENTIVO_NO_REALIZADO');
                                             LET v_comentario = 'Sin realizar el cierre automatico';
                                             LET v_estatus_aclaracion = v_estatus_aclaracion_no_realizado;
                                             LET v_fechaCierre=NULL;
                                             LET v_procede = NULL;
                                             LET v_dias_conclusion = NULL;
                                        END IF;

                                  
                                         --Actualizando aclaracion
   
                                                UPDATE acl_aclaracion 
                                                SET fecha_dictamen = v_fechaCierre,
                                                    montoprocedente=v_importereclamado,
                                                    predictamen=v_observaciones,
                                                    procede=v_procede,
                                                    fky_estatus_aclaracion=v_estatus_aclaracion, --help
                                                    fky_estatus_corp_general=v_nuevo_estatus_general,
                                                    fky_tipo_codigo_resolucion=v_cod_resolucion,
                                                    dias_conclusion= v_dias_conclusion
                                                WHERE folio_csuac = v_folio_csuac;    
                                                
--=============    BITACORA INSERT

                                          -- REGISTRO DE HISTORICO
                                             
                                             INSERT INTO "informix".acl_entrada_bitacora
                                                VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                               v_comentario,                   -- descripcion   
                                               CURRENT,                      -- fechaHOra
                                               v_folio_csuac,                -- folio_csuac   
                                               v_resolucion,                    -- accion/acl_resolucion 
                                               v_pky_aclaracion,             -- pky_aclaracion
                                               NULL,                     -- fky_area
                                               v_fky_estatus_aclaracion,        -- fky_estatus_aclaracion
                                               v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                               v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                               '0');                          -- Usuario   
                                               
                                           
                                               
                                       --return  v_CodRet,v_folio_csuac, v_procesadoCorrectamente||'|'||v_tipo_movimiento||'|'||v_dias_respuesta_maxima_folio||'|'||v_fecha_resultante||'|'||v_dias_conclusion||'|'||v_fechacaptura||'|'||v_resultado_origen||'|'||v_resolucion||'|'||v_nuevo_estatus_general||'|'||v_comentario
                                       return  v_CodRet||'|',v_folio_csuac||'|', v_procesadoCorrectamente
                                       WITH resume;
                                    END IF -- Termina de aplicar el cierre automatico

                            END IF;
						LET v_estatus_aclaracion = '3'; 
                        LET v_procede = '1';    
                   END FOREACH;  -- END FOREACH
--                    END LOOP;

        END;
END PROCEDURE -- PROCEDURE

DOCUMENT
'Sp sp_aplica_cierre_preventivo',
'Se incluye validacion para afectar movimientos de aclaraciones con tiempos con respuesta estimanda pasados - Cierre preventivo',
'Sistema: Aclaraciones',
'AUTOR : Root Technologies',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA CREACION: 15/Marz0/2017',
'FECHA UTLIMA MODIFICACION: 14/Marzo/2019',
'INCLUYE RQM 521-3',
'VERSION: 2.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_numaclaracion(pUsuario CHAR(50))
	RETURNING CHAR(5) AS codret,
		INTEGER AS sql_error, 
		INTEGER AS num_aclaracion, 
		DATE AS primera_fecha;

    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumAclaracion INTEGER;
	DEFINE dPrimerFecha DATE;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumAclaracion = 0;
	LET dPrimerFecha = '';

    BEGIN
	
        ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = '002';
				RETURN cCodRet,iSqlErr,iNumAclaracion,dPrimerFecha;
			END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_numaclaracion.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(num_cliente) AS no_aclaracion, MIN(fecha_dictamen) AS primer_acl
		INTO iNumAclaracion, dPrimerFecha
		FROM "informix".acl_aclaracion
		WHERE num_cliente = pUsuario
		AND fky_estatus_aclaracion IN (2,3,4,5);

		IF NVL(iNumAclaracion,0) = 0 THEN
			LET iNumAclaracion = 0;
			LET dPrimerFecha = '';
		END IF;

		RETURN cCodRet,iSqlErr,iNumAclaracion,dPrimerFecha;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/08/2018',
'SISTEMA: ACLARACIONES',
'FUNCIONALIDAD: CENTRO DE ATENCIÃ?N TELEFÃ?NICA (CAT)',
'DESCRIPCION: SPL encargado de recuperar el nÃºmero de aclaraciones.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_registra_documento_en_bitacora(
						pIdAclaracion INTEGER, pIdDocumento INTEGER, pUsuario INTEGER)

	RETURNING
		CHAR(5)							as cod_ret;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_pky_aclaracion				INTEGER;
	DEFINE v_folio_csuac	  			CHAR(11);
	DEFINE v_fky_area					INTEGER;
	DEFINE v_fky_estatus_aclaracion		INTEGER;
	DEFINE v_fky_estatus_corp_analisis	INTEGER;
	DEFINE v_fky_estatus_corp_general	INTEGER;
	DEFINE v_mensaje					LVARCHAR;
	DEFINE v_desc_documento				VARCHAR(255);
	DEFINE c_accion_resolucion			INTEGER;
	DEFINE c_fechahora		  			DATETIME YEAR to FRACTION(5);
	
	DEFINE c_separador					CHAR(1);
	DEFINE c_prefijo					CHAR(3);
	
	DEFINE v_existe_cliente				SMALLINT;
	
	LET v_cod_ret 						= '00000';
	LET c_fechahora						= CURRENT;
	LET v_pky_aclaracion				= NULL;
	LET v_folio_csuac	  				= NULL;
	LET v_fky_area						= NULL;
	LET v_fky_estatus_aclaracion		= NULL;
	LET v_fky_estatus_corp_analisis		= NULL;
	LET v_fky_estatus_corp_general		= NULL;
	LET v_mensaje						= 'Se agregó el documento: ';
	LET v_desc_documento				= NULL;
	LET c_accion_resolucion				= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
			    RETURN v_cod_ret;
		    END IF;
		END EXCEPTION;
		
		IF (pIdDocumento IS NULL)  AND (pIdAclaracion IS NULL) THEN
			RETURN '00001'; --La invocación debe tener algún valor
		END IF;
		
		IF (pIdAclaracion IS NULL) THEN
			RETURN '00002'; --Debe proporcionar pky_aclaracion
		END IF;
		
		IF (pIdDocumento IS NULL) THEN
			RETURN '00003'; --Debe proporcionar el mensaje a almacenar
		END IF;
		
		SELECT pky_aclaracion, folio_csuac, fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
			INTO v_pky_aclaracion, v_folio_csuac, v_fky_area, v_fky_estatus_aclaracion, v_fky_estatus_corp_analisis, v_fky_estatus_corp_general
		FROM acl_aclaracion 
		WHERE pky_aclaracion = pIdAclaracion;
		
		IF (v_pky_aclaracion IS NULL) THEN
			RETURN '00004'; --No existe la Aclaración
		END IF;
		
		SELECT descripcion 
			INTO v_desc_documento
		FROM acl_tipo_documento 
		WHERE pky_tipo_documento = pIdDocumento
			AND activo = 1;
		
		IF (v_desc_documento IS NULL) THEN
			RETURN '00005'; --No existe el documento
		END IF;
		
		SELECT pky_resolucion 
			INTO c_accion_resolucion
		FROM acl_resolucion WHERE nombre = 'agregaDocumento';
		
		LET v_mensaje = TRIM(v_mensaje) ||' '|| TRIM(v_desc_documento);
		LET v_mensaje = TRIM(v_mensaje);
		
		INSERT INTO "informix".acl_entrada_bitacora 
			(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
				fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario)
			VALUES(entrada_bitacora_seq.NEXTVAL,v_mensaje, c_fechahora, v_folio_csuac, c_accion_resolucion, pIdAclaracion, v_fky_area, 
				v_fky_estatus_aclaracion, v_fky_estatus_corp_analisis, v_fky_estatus_corp_general, pUsuario);
		
		RETURN v_cod_ret;
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_inserta_movimiento( 
                pFechaHora CHAR(30), 
                pMonto MONEY, 
                pFolioSuc CHAR(30), 
                pReferencia23 CHAR(23), 
                pProducto INTEGER, 
                pTipoEvento INTEGER, 
                pAclaracion INTEGER, 
                pMovimientoPadre INTEGER,
                pNumSucursal CHAR(10),
                pReferenciaComercio CHAR(40),
                pFechaConsumo CHAR(30),
                pMontoProcedente MONEY,
                pFolioCSUAC CHAR(10),
                pReversado SMALLINT,
                pCalculado SMALLINT,
                pMontoDuplicado SMALLINT,
                pTipoMovimiento INTEGER,
                pReferencia VARCHAR(30))
RETURNING CHAR(3);


DEFINE cCodRet    CHAR(3);  --> ok
DEFINE CSecuencia INTEGER;
DEFINE vFechaHora DATETIME YEAR to FRACTION(5);
DEFINE vFechaConsumo DATETIME YEAR to FRACTION(5);


LET cCodRet = '';
LET CSecuencia   = 0; 
LET vFechaConsumo = null;
LET vFechaHora = null;
 
 
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    
BEGIN

--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/actualiza_movimiento"||"_N_"||""||TRIM(pFolioCSUAC)||""||"_34.out"; --> TRACE DESDE APP
--TRACE ON;

     IF pFechaHora = '' OR pFechaHora IS  NULL THEN  
        LET pFechaHora = null;
     END IF;
     IF pFechaConsumo = '' OR pFechaConsumo IS  NULL THEN  
        LET pFechaConsumo = null;
     END IF; 
     IF pFolioSuc = '' OR pFolioSuc IS  NULL THEN  
        LET pFolioSuc = null;
     END IF; 
     IF pReferencia23 = '' OR pReferencia23 IS  NULL THEN  
        LET pReferencia23 = null;
     END IF; 
     IF pNumSucursal = '' OR pNumSucursal IS  NULL THEN  
        LET pNumSucursal = null;
     END IF; 
     IF pReferenciaComercio = '' OR pReferenciaComercio IS  NULL THEN  
        LET pReferenciaComercio = null;
     END IF; 
     IF pFolioCSUAC = '' OR pFolioCSUAC IS  NULL THEN  
        LET pFolioCSUAC = null;
     END IF; 
     IF pReferencia = '' OR pReferencia IS  NULL THEN  
        LET pReferencia = '';
     END IF; 
     IF pFechaHora <> '' OR pFechaHora IS NOT NULL THEN   
        IF length(pFechaHora) > 10 THEN
            LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y %H:%M:%S')) ;
        ELSE 
            LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y')) ;
        END IF;
     END IF;    
     IF pFechaConsumo <> '' OR pFechaConsumo IS NOT NULL THEN  
       LET vFechaConsumo = (TO_DATE(pFechaConsumo,'%d/%m/%Y %H:%M:%S'));
     END IF;

     
        INSERT INTO acl_movimiento
                           -- pky_movimiento            calculado     cargo     cargo_ajuste    exitoso     fecha_afectacion   fecha_hora_e_global      fechahora       folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente        duplicado         numero_transaccion     procede     referencia      referencia23    reversado     secuencia   fky_aclaracion     fky_padre     fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion       ref_comercio        num_sucursal   fecha_consumo  recuperacion  monto_recuperacion
        VALUES(MOVIMIENTO_SEQ.nextval, pCalculado,    null,        null,         null,          null,               null,               vFechaHora,     pFolioCSUAC,    pFolioSuc,              null,               null,      null,     pMonto,   pMontoProcedente,   pMontoDuplicado,            null,            null,      pReferencia,   pReferencia23,   pReversado,     null,        pAclaracion,        pMovimientoPadre,      pProducto,              null,               pTipoEvento,        pTipoMovimiento,                null,                  pReferenciaComercio,   pNumSucursal , vFechaConsumo,        0,            0);
        
        LET cCodRet = '000';

END;
RETURN cCodRet;
END PROCEDURE
DOCUMENT
'sp_inserta_movimiento',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_reporte_mensual_acl() Returning char(5);

	/*DEFINICIÃN DE VARIABLES*/
	DEFINE  vsql        		char(3000);
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	DEFINE p_cuenta				varchar(20);
	DEFINE p_folio				varchar(20);
	DEFINE p_tarjeta			varchar(20);
	DEFINE p_cliente 			varchar(20);
 	DEFINE p_nombre1  			varchar(200);
	DEFINE p_nombre2   			varchar(50);
	DEFINE p_apell_paterno		varchar(50);
	DEFINE p_apell_materno		varchar(50);
	DEFINE p_rfc				varchar(20);
	DEFINE p_curp          		varchar(20);
	DEFINE p_evento				varchar(50);
	DEFINE icontador 			integer;
	DEFINE v_fecha_fin			date;
	DEFINE v_fecha_inicio		date;
	DEFINE v_temp_tabla INTEGER;
	
	LET p_cuenta		=	'';
	LET p_folio			=	'';
	LET p_tarjeta		=	'';
	LET p_cliente 		=	'';
 	LET p_nombre1  		=	'';
	LET p_nombre2   	=	'';
	LET p_apell_paterno	=	'';
	LET p_apell_materno	=	'';
	LET p_rfc			=	'';
	LET p_curp          =	'';
	LET p_evento		=	'';
	LET icontador 		=	0;
	
--Verificar tablas fisicas
		
		
		SELECT tabid
			INTO v_temp_tabla
		FROM systables WHERE tabname ='acl_reporte_mensual';
		IF v_temp_tabla IS NOT NULL THEN
			DROP TABLE "informix".acl_reporte_mensual;
		END IF;
--Verificar tabla fisica
	
	--creacion de tabla
        CREATE  TABLE  "informix".acl_reporte_mensual
            (folio_csuac            varchar(11),
			cuenta          		varchar(20),
            tarjeta          		varchar(20),
            cliente         		varchar(20),
            nombre           		varchar(200),
            rfc        				varchar(20),
            curp                  	varchar(20),
            evento             varchar(100),
           	primary key (folio_csuac)
		)  extent size 362695 next size 36484 lock mode row;


		
	let vcodret = "";
	let vsqlerr = 0;
	
	SELECT prox_fecha as fecha_fin, pri_dia_mes as fecha_inicio
			INTO v_fecha_fin, v_fecha_inicio
	FROM bdinteg:"informix".si_fechas;
		
	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_reportediarioacl.out";
	--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_reportediarioacl.out";
   -- TRACE ON;
	
	
	BEGIN	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
BEGIN WORK;
		
		--Generacion de registros para Reporte Diario (Aclaraciones Pendientes)
	FOREACH WITH HOLD
		select
			a.folio_csuac,
			p.numero_cuenta,
			p.numero_tarjeta,	
			c.numcte, 
			c.nombre1,
			c.nombre2,
			c.apell_paterno,
			c.apell_materno,
			c.rfc,
			ct.curp,
			e.descripcion
		INTO
			p_folio,
			p_cuenta,		
		  	p_tarjeta,		
		    p_cliente, 		
		    p_nombre1,  		
		    p_nombre2,  	
		    p_apell_paterno,
		    p_apell_materno,
		    p_rfc,			
		    p_curp,          
		    p_evento		
		     		
		from acl_aclaracion a
			left outer join acl_producto p on a.fky_producto=p.pky_producto
			left outer join acl_tipo_evento e on a.fky_tipo_evento=e.pky_tipo_evento
			left outer join bdinteg:si_cliente c on a.num_cliente=c.numcte
			left outer join bdinteg:si_ctepf ct on c.numcte=ct.numcte
		where (a.fechacaptura BETWEEN v_fecha_inicio AND v_fecha_fin) and a.folio_csuac is not null and a.fky_estatus_aclaracion > 1
						
					
			LET p_nombre1 = trim(p_nombre1)||' '||trim(p_nombre2)||' '||trim(p_apell_paterno)||' '||trim(p_apell_materno);
					
						
					INSERT INTO "informix".acl_reporte_mensual (folio_csuac, cuenta, tarjeta, cliente, nombre, rfc, curp, evento)
					VALUES (p_folio, p_cuenta, p_tarjeta, p_cliente, p_nombre1, p_rfc,	p_curp, p_evento);
					
					LET iContador = iContador + 1;
					
					IF iContador = 1000 THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF; 

	END FOREACH;				
	
	COMMIT WORK;
	
			
			
			
			
			--Generacion de Reporte Mensual
			let vsql = ' echo "Folio_Csuac|Numero_Cuenta|Numero_tarjeta|Num_Cliente|Nombre_cliente|Rfc|Curp|Nombre_Evento">/resplogifx/repaclaraciones/ACL_INGRESADAS_'||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_inicio)||'.unl';
			system vsql; 
			let vsql = '';
			let vsql=  'echo "UNLOAD TO reportemensual.unl  select folio_csuac,cuenta,tarjeta,cliente,nombre,rfc,curp,evento from acl_reporte_mensual;">reportemensual.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdiaclaracion	  reportemensual.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  reportemensual.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' reportemensual.unl >>/resplogifx/repaclaraciones/ACL_INGRESADAS_"||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_inicio)||".unl";
			system vsql;
			let vsql ='rm  reportemensual.unl';
			system vsql; 
				
			let vcodret = '00000';					
			
			--truncate table "informix".acl_reporte_diario REUSE STORAGE;
-----------------------------------------------------------------------------------
		

		
		drop table "informix".acl_reporte_mensual;
				
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte mensual de Aclaraciones',
'Genera la extraciÃ³n de informaciÃ³n correspondiente a las aclaraciones ingresadas en el mes con datos espesificos',
'Es llamado desde desde la opcion 722 del menu de produccion',
'Aclaraciones',
'AUTOR : Rey David Zavala Garcia',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 23/Mayo/2019',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_documentos_faltantes(pIdAclaracion INTEGER, pCliente CHAR(9))

	RETURNING
		CHAR(5)							AS cod_ret,
		INTEGER							AS id_documento,
		CHAR(4)							AS producto_bdidigital,
		CHAR(4)							AS codigo_doc_bdidigital,
		CHAR(100)						AS descripcion,
		INTEGER							AS id_digitalizado_en_acl,
		SMALLINT						AS existe_en_bdidigital,
		SMALLINT						AS opcional,
		CHAR(50)						AS nombre_acl_doc,
		DATE 							AS registro_acl_doc,
		DATE 							AS registro_bdidigital;


	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_existe_aclaracion			SMALLINT;
	DEFINE v_cliente_aclaracion			CHAR(9);
	DEFINE v_folio_csuac				CHAR(11);
	DEFINE v_id_documento				INTEGER;
	DEFINE v_grupo_doc					CHAR(4);
	DEFINE v_codigo_doc					CHAR(4);
	DEFINE v_existe_archivo_digital		SMALLINT;
	DEFINE v_desc_documento				CHAR(100);
	DEFINE v_id_digitalizado			INTEGER;
	DEFINE v_opcional					SMALLINT;
	DEFINE v_nombre_acl_doc				CHAR(50);
	DEFINE v_fecha_registro				DATETIME YEAR to FRACTION(5);
	DEFINE v_registro_acl_doc			DATE;
	DEFINE v_registro_bdidigital		DATE;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	LET v_existe_aclaracion				= NULL;
	LET v_cliente_aclaracion			= NULL;
	LET v_folio_csuac					= NULL;
	LET v_id_documento					= NULL;
	LET v_grupo_doc						= NULL;
	LET v_codigo_doc					= NULL;
	LET v_existe_archivo_digital		= NULL;
	LET v_desc_documento				= NULL;
	LET v_id_digitalizado				= NULL;
	LET v_opcional						= NULL;
	LET v_nombre_acl_doc				= NULL;
	LET v_fecha_registro				= NULL;
	LET v_registro_acl_doc				= NULL;
	LET v_registro_bdidigital			= NULL;
	
	--SET DEBUG FILE TO "/informix/traces/doctos_ptes.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital;
				
		    END IF;
		END EXCEPTION;
		
		IF ((pCliente IS NULL) OR (pCliente = '')) AND (pIdAclaracion IS NULL) THEN
			RETURN '00002', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --La invocaciÃ³n debe tener algÃºn valor
		END IF;
		
		IF (pIdAclaracion IS NULL) THEN
			RETURN '00003', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el ID de la AclaraciÃ³n
		END IF;
		
		IF (pCliente IS NULL) OR (pCliente = '') THEN
			RETURN '00004', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el nÃºmero de cliente
		END IF;
		
		SELECT 1, num_cliente, folio_csuac
			INTO v_existe_aclaracion, v_cliente_aclaracion, v_folio_csuac
		FROM acl_aclaracion
		WHERE pky_aclaracion = pIdAclaracion;
		
		IF (v_existe_aclaracion IS NULL) THEN
			RETURN '00005', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --No existe la AclaraciÃ³n
		END IF;
		
		LET pCliente = LPAD(TRIM(pCliente), 9, '0');
		
		IF (pCliente <> v_cliente_aclaracion) THEN
			RETURN '00006', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --El cliente de la aclaraciÃ³n no coincide con el solicitado
		END IF;
		
		FOREACH
			
			SELECT tdocm.fky_tipo_documento, tdoc.descripcion, doc.pky_documento, te.grupo_doc,
					tdg.cod_docto, tdocm.opcional, doc.nombre, doc.fecharegistro
				INTO v_id_documento, v_desc_documento, v_id_digitalizado, v_grupo_doc,
					v_codigo_doc, v_opcional, v_nombre_acl_doc, v_fecha_registro
			FROM acl_aclaracion acl
				INNER JOIN acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
				INNER JOIN acl_tipo_doc_matriz tdocm ON fky_id_regla = fky_regla_negocio
				INNER JOIN acl_tipo_documento tdoc ON tdoc.pky_tipo_documento = tdocm.fky_tipo_documento
				LEFT OUTER JOIN acl_tipo_docto_dg_tipodocto tdg ON tdg.fky_tipo_documento = tdoc.pky_tipo_documento
					AND te.grupo_doc = tdg.grupo_doc
				LEFT OUTER JOIN acl_documento doc ON pky_aclaracion = doc.fky_aclaracion 
					AND tdocm.fky_tipo_documento = doc.fky_tipo_documento
			WHERE pky_aclaracion = pIdAclaracion
			
			LET v_registro_acl_doc = DATE(v_fecha_registro);
			LET v_existe_archivo_digital = NULL;
			
			IF v_codigo_doc IS NOT NULL THEN
				SELECT FIRST 1 1, fecha_alta
					INTO v_existe_archivo_digital, v_registro_bdidigital
				FROM bdidigital@coppelimg_tcp:dg_expediente exp			
				WHERE exp.producto = v_grupo_doc
					AND exp.cod_docto = v_codigo_doc
					AND exp.cliente = pcliente
					AND exp.cuenta = v_folio_csuac
					AND exp.descrip2 <> 'firma_borra_da';
			END IF;
			
			LET v_existe_archivo_digital = NVL(v_existe_archivo_digital,0);
			
			RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital, 
						v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital
				WITH RESUME;
			
		END FOREACH;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_reverso_estatus_preingreso()
  RETURNING 
    CHAR(3) as cCodRet, 
	CHAR(12) as folioCsuac; 
	
  -- Definición de variables
  DEFINE sql_err INTEGER;
  DEFINE v_cod_ret CHAR(3);
  DEFINE v_fecha_hoy DATE;
  DEFINE v_fecha_acl DATE;
  DEFINE v_days INTEGER;
  DEFINE v_folio_csuac VARCHAR(12);
  DEFINE v_folio_aclaracion VARCHAR(18);
  DEFINE v_pky_aclaracion INTEGER;
  DEFINE v_dias_feriados INTEGER;
  DEFINE v_dias_finSemana INTEGER;
  DEFINE v_dia_hoy INTEGER;
  DEFINE contador INTEGER;
  
  DEFINE v_num_cliente CHAR(9);
  DEFINE v_nombre1 CHAR(50);
  DEFINE v_nombre2 CHAR(50);
  DEFINE v_apell_paterno CHAR(50);
  DEFINE v_apell_materno CHAR(50);
  DEFINE v_nombre_completo CHAR(150);
  
  DEFINE vcodretDatosCte CHAR(5);
  DEFINE vCorreoElec CHAR(100);
  DEFINE vTipoCorreo SMALLINT;
  DEFINE vStatusCorreo CHAR(1);
  
  DEFINE vTelefono CHAR(13);
  DEFINE vTipoTel SMALLINT;
  DEFINE vSecuencia SMALLINT;
  DEFINE vStatus_Tel CHAR(1);
  DEFINE vExtension CHAR(5);
  DEFINE vCarrier SMALLINT;
  DEFINE vNombreCarrier CHAR(20);
  DEFINE StatusValidacion SMALLINT;
  
  DEFINE v_dias_vencimiento INTEGER;
  DEFINE c_estatus_pre_ingreso CHAR(50);
  DEFINE c_id_estatus_pre_ingreso INTEGER;
  DEFINE c_estatus_declinado CHAR(50);
  DEFINE c_id_estatus_declinado INTEGER;
  
  DEFINE v_codret_notificacion CHAR(5);
  
  --Variables para la bitácora
  DEFINE v_id_area INTEGER;
  DEFINE v_estatus_acl INTEGER;
  DEFINE v_estatus_corp_analisis INTEGER;
  DEFINE v_estatus_corp_general INTEGER;
  DEFINE v_id_accion INTEGER;
  DEFINE v_desc_bitacora CHAR(100);
   
  --Declaración de Variables para los documentos faltantes
  DEFINE v_cod_ret_docto CHAR(5);
  DEFINE v_id_documento INTEGER;
  DEFINE v_codigo_doc_bdidigital CHAR(4);
  DEFINE v_docto CHAR(100);
  DEFINE v_existe_docto_aclaracion INTEGER;
  DEFINE v_existe_docto_en_bdidigital SMALLINT;
  DEFINE v_producto_bdidigital CHAR(4);
  DEFINE v_docto_es_opcional SMALLINT;
  DEFINE v_nombre_acl_doc CHAR(50);
  DEFINE v_fecha_registro_acl_doc DATE;
  DEFINE v_fecha_registro_bdidigital DATE;
  DEFINE v_docto1 CHAR(60);
  DEFINE v_docto2 CHAR(100);
  DEFINE v_docto3 CHAR(60);
  DEFINE v_docto4 CHAR(100);
  DEFINE v_docto5 CHAR(30);
  DEFINE v_contador_doctos INTEGER;
  
  --Declaración de Constantes para los envíos de notificaciones
  DEFINE c_contrato_correo_latinia CHAR(10);
  DEFINE c_contrato_sms_latinia CHAR(10);
  DEFINE c_plantilla_latinia CHAR(12);
  
  -- inicialización de variables
  LET v_cod_ret = "000";
  LET v_fecha_hoy = today;
  LET v_dia_hoy = WEEKDAY(v_fecha_hoy);
  LET v_fecha_acl = "";
  LET v_folio_csuac = "";
  LET v_folio_aclaracion = NULL;
  LET v_pky_aclaracion = "";
  LET v_num_cliente = NULL;
  
  LET v_nombre1 = NULL;
  LET v_nombre2 = NULL;
  LET v_apell_paterno = NULL;
  LET v_apell_materno = NULL;
  LET v_nombre_completo = NULL;
  
  LET c_contrato_correo_latinia = 'ACL_EMAIL';
  LET c_contrato_sms_latinia = 'ACL_SMS';
  LET c_plantilla_latinia = 'ACL_DECLINA';
  
  LET vTelefono = NULL;
  LET vcorreoelec = NULL;
  LET v_codret_notificacion = NULL;
  
  LET v_id_area = NULL;
  LET v_estatus_acl = NULL;
  LET v_estatus_corp_analisis = NULL;
  LET v_estatus_corp_general = NULL;
  LET v_id_accion = NULL;
  LET v_desc_bitacora = NULL;
  
  LET v_dias_vencimiento = NULL;
  LET c_estatus_pre_ingreso = 'PRE_INGRESO';
  LET c_id_estatus_pre_ingreso = NULL;
  LET c_estatus_declinado = 'DECLINADA';
  LET c_id_estatus_declinado = NULL;
  
  LET v_cod_ret_docto = NULL;
  LET v_id_documento = NULL;
  LET v_codigo_doc_bdidigital = NULL;
  LET v_docto = NULL;
  LET v_existe_docto_aclaracion = NULL;
  LET v_existe_docto_en_bdidigital = NULL;
  LET v_producto_bdidigital = NULL;
  LET v_docto_es_opcional = NULL;
  LET v_nombre_acl_doc = NULL;
  LET v_fecha_registro_acl_doc = NULL;
  LET v_fecha_registro_bdidigital = NULL;
  LET v_docto1 = NULL;
  LET v_docto2 = NULL;
  LET v_docto3 = NULL;
  LET v_docto4 = NULL;
  LET v_docto5 = NULL;
  LET v_contador_doctos = 0;
  
BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET v_cod_ret = sql_err;
           RETURN v_cod_ret,v_folio_csuac;
     END IF;
  END EXCEPTION;
	 
	--SET DEBUG FILE TO '/informix/traces/sp_reverso_estatus_preingreso.out';
	--TRACE ON;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  --Se obtiene el valor del estatus corporativo Pre-Ingreso y Declinada de tipo análisis
  SELECT pky_estatus_corporativo 
    INTO c_id_estatus_pre_ingreso
  FROM acl_estatus_corporativo 
  WHERE nombre = c_estatus_pre_ingreso AND fky_tipo_estatus = 2 
    AND activo = 1;
  
  IF c_id_estatus_pre_ingreso IS NULL THEN --No está definido el Estatus Pre-Ingreso
    RETURN '001',v_folio_csuac;
  END IF;
  
  SELECT pky_estatus_corporativo 
    INTO c_id_estatus_declinado
  FROM acl_estatus_corporativo 
  WHERE nombre = c_estatus_declinado AND fky_tipo_estatus = 2 
    AND activo = 1;
  
  IF c_id_estatus_declinado IS NULL THEN --No está definido el Estatus Declinado
    RETURN '002',v_folio_csuac;
  END IF;
  
  --LET v_fecha_hoy = today-7;
  
  IF (v_dia_hoy != 0 AND v_dia_hoy != 6) THEN 
    FOREACH
      /*Busca Aclaraciones con estatus corporativo analisis en PreIngreso*/
      SELECT pky_aclaracion,fechacaptura, folio_csuac, num_cliente
        INTO v_pky_aclaracion,v_fecha_acl, v_folio_csuac, v_num_cliente
      FROM acl_aclaracion 
	  WHERE fky_estatus_corp_analisis = c_id_estatus_pre_ingreso
  	  
	  --Se obtienen los días de vigencia que tiene una Aclaración dependiendo su Canal de Ingreso 
	  SELECT dias_vencimiento 
        INTO v_dias_vencimiento
      FROM acl_aclaracion acl
        INNER JOIN acl_cat_tipo_aclaracion ta on fky_cat_tipo_aclaracion = pky_cat_tipo_aclaracion
      WHERE folio_csuac = v_folio_csuac;

      --En caso de no tener definida la vigencia, se considera 0
      LET v_dias_vencimiento = NVL(v_dias_vencimiento, 0);
	
	  --Se obtiene el nombre del Cliente
	  SELECT nombre1, nombre2, apell_paterno, apell_materno 
        INTO v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno 
	  FROM bdinteg:si_cliente 
	  WHERE numcte = v_num_cliente;
	  
	  LET v_nombre_completo = TRIM(NVL(v_nombre1,'')) || ' ' || TRIM(NVL(v_nombre2,'')) || ' ' || TRIM(NVL(v_apell_paterno,'')) || ' ' || TRIM(NVL(v_apell_materno,''));
	  
	  --Se obtiene el Correo Electrónico del cliente
	  CALL bdinteg:sp_consulta_correos ('001', v_num_cliente,'1','0')
              RETURNING  vcodretDatosCte, vcorreoelec, vtipocorreo, vstatuscorreo;
	   --Se obtiene el Teléfono Celular del cliente
	  CALL bdinteg:sp_consulta_telefonos ('001', v_num_cliente,'2','0')
              RETURNING  vcodretDatosCte, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
	  
	  --Se corrobora si existe si el folio csuac de aclaración se encuentra asignada a un folio agrupador (folio_aclaracion)
	  SELECT folio_aclaracion 
	    INTO v_folio_aclaracion
	  FROM acl_folio_aclaracion_acl_aclaracion
	  WHERE fky_aclaracion = v_pky_aclaracion;
	  
	  --En caso de no estar asignada a un Folio Agrupador, se considerará el Folio CSUAC
	  LET v_folio_aclaracion = NVL(v_folio_aclaracion,v_folio_csuac);
	  
	  LET v_contador_doctos = 0;
	  --En caso de tener correo registrado el cliente, se obtienen los documentos que no envío
	  IF vcorreoelec IS NOT NULL OR vcorreoelec <> '' THEN
	    FOREACH 
	      EXECUTE FUNCTION "informix".sp_documentos_faltantes(v_pky_aclaracion, v_num_cliente) 
	        INTO v_cod_ret_docto, v_id_documento, v_producto_bdidigital, v_codigo_doc_bdidigital, v_docto, v_existe_docto_aclaracion, v_existe_docto_en_bdidigital, v_docto_es_opcional, v_nombre_acl_doc, v_fecha_registro_acl_doc, v_fecha_registro_bdidigital
	      --Se valida si el documento no fue proporcionado por el usuario
		  IF (v_existe_docto_aclaracion IS NOT NULL OR v_existe_docto_aclaracion > 0) OR (v_existe_docto_en_bdidigital IS NOT NULL OR v_existe_docto_en_bdidigital > 0) THEN
	        LET v_contador_doctos = v_contador_doctos + 1;
	        IF v_contador_doctos = 1 THEN
			  LET v_docto1 = v_docto;
            ELIF v_contador_doctos = 2 THEN
			  LET v_docto2 = v_docto;
			ELIF v_contador_doctos = 3 THEN
			  LET v_docto3 = v_docto;
			ELIF v_contador_doctos = 4 THEN
			  LET v_docto4 = v_docto;
			ELIF v_contador_doctos = 5 THEN
			  LET v_docto5 = v_docto;
			END IF;
	      END IF;
	    END FOREACH;
	  END IF;
	  
  	  -- obtener dias feriados
  	  LET v_dias_feriados = 0;
  	  SELECT count(*)
        INTO  v_dias_feriados
  	  FROM  bdinteg:si_feriado_banca 
	  WHERE fecha BETWEEN v_fecha_acl 
  	    AND v_fecha_hoy AND WEEKDAY(fecha) BETWEEN 1 AND 5;
  	
  	  LET v_days = DATE(v_fecha_hoy) - DATE(v_fecha_acl);
      
      LET v_dias_finSemana = 0;
  
      LET contador= 0;
      
      WHILE  contador < v_days LOOP
        IF (WEEKDAY(v_fecha_acl)==0 OR  WEEKDAY(v_fecha_acl)== 6) then
          LET v_dias_finSemana = v_dias_finSemana + 1; 
        END IF;
        LET contador = contador + 1;
  	    LET v_fecha_acl = v_fecha_acl+1;
      END LOOP;
      
      -- resta dias_feriados y fines de semana.
  	  LET v_days = v_days - (v_dias_feriados + v_dias_finSemana);
      
      IF(v_days >= v_dias_vencimiento) THEN
        /*Actualizando la aclaracion de preIngreso a Declinado*/
		UPDATE acl_aclaracion SET fky_estatus_corp_analisis = c_id_estatus_declinado WHERE pky_aclaracion = v_pky_aclaracion;
        
        /*Resgistro de Bitácora*/
		--Se obtienen los valores actuales de la Aclaración para insertarlos en la bitácora
        SELECT fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general 
          INTO v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general 
        FROM acl_aclaracion
        WHERE folio_Csuac = v_folio_csuac;
		--Se obtiene la resolución correspondiente al reverso
        SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'registroIntento';
		
		LET v_desc_bitacora = 'El folio: ' || v_folio_csuac || ' se actualizó de estatus Pre-Ingreso a Declinado.';
		
        INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		
		--Se envían las notificaciones correspondientes a la declinación
		--Notificación Vía SMS
		IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
		  CALL bdimnsj:sp_registra_evento('2',c_contrato_sms_latinia,c_plantilla_latinia,v_num_cliente,'','','1',v_folio_aclaracion,'','','',v_nombre_completo,'','','','','','',vTelefono,0,0,0,0,0,today,'')
		      RETURNING v_codret_notificacion;
		END IF;
        
        --Se registra la notificación en la bitácora del Sistema.
        IF v_codret_notificacion = '00000' THEN
		  LET v_desc_bitacora = 'El mensaje de texto de notificación fué enviado al Cliente con éxito.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionSMSExitoso';
        ELSE
		  LET v_desc_bitacora = 'El mensaje de texto de notificación no pudo ser enviado al Cliente.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionSMSFallido';
        END IF;
		
		INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		LET v_codret_notificacion = NULL;
		
		--Notificación Vía Correo
		IF vcorreoelec IS NOT NULL OR vcorreoelec <> '' THEN
		  CALL bdimnsj:sp_registra_evento('1',c_contrato_correo_latinia,c_plantilla_latinia,v_num_cliente,'','','1',v_folio_aclaracion,'','',v_docto5,v_nombre_completo,v_docto3,v_docto1,v_docto4,'',v_docto2,vCorreoElec,'',0,0,0,0,0,today,'')
		      RETURNING v_codret_notificacion;
		END IF;
		
		--Se registra la notificación en la bitácora del Sistema.
		IF v_codret_notificacion = '00000' THEN
		  LET v_desc_bitacora = 'El correo electrónico de notificación fué enviado al Cliente con éxito.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionCorreoFallido';
        ELSE
		  LET v_desc_bitacora = 'El correo electrónico de notificación no pudo ser enviado al Cliente.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionCorreoExitoso';
        END IF;
		
		INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		--Se limpian las variables de Correo y teléfonos del cliente.
		LET vTelefono = NULL;
		LET vcorreoelec = NULL;
		LET v_codret_notificacion = NULL;
		
        RETURN v_cod_ret,v_folio_csuac WITH RESUME;
      END IF;
  	END FOREACH;
	
  END IF;
END;
END PROCEDURE
DOCUMENT
'Sistema: Aclaraciones',
'AUTOR : Root',
'Modificación : BanCoppel',
'Coordinador: Norberto Corona Berruecos',
'FECHA: Febrero/2019',
'Requerimiento: RQM 06 626',
'VERSION: 2.0.0',
'BD:  bdiaclaracion';

CREATE PROCEDURE "informix".sp_recuperacion_saldos()
RETURNING CHAR(7) AS CODIGO
--V. 2.0.3
DEFINE v_folio CHAR(24);
DEFINE v_producto SMALLINT;
DEFINE v_credito SMALLINT;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
DEFINE s_CodRet CHAR(6);
DEFINE v_mensaje CHAR(600);
DEFINE s_Mensaje CHAR(100);
DEFINE s_Cc SMALLINT;
DEFINE s_AfectacionC MONEY;
DEFINE s_CodleyendaC CHAR(3);
DEFINE s_Ci SMALLINT;
DEFINE s_AfectacionI MONEY;
DEFINE s_CodleyendaI CHAR(3);
DEFINE s_Ca SMALLINT;
DEFINE s_AfectacionA MONEY;
DEFINE s_CodleyendaA CHAR(3);
DEFINE s_Cin SMALLINT;
DEFINE s_AfectacionIn MONEY;
DEFINE s_CodleyendaIn CHAR(3);
--Variables para la bitacora
DEFINE v_descripcion LVARCHAR(625); 
DEFINE v_fechahora DATETIME YEAR TO FRACTION(5);
DEFINE v_folio_csuac CHAR(24);
DEFINE v_fky_accion INTEGER;
DEFINE v_fky_aclaracion INTEGER;
DEFINE v_fky_area INTEGER;
DEFINE v_fky_estatus_aclaracion INTEGER;
DEFINE v_estatus_corp_analisis INTEGER;
DEFINE v_estatus_corp_general INTEGER;
DEFINE v_fky_usuario INTEGER;
--Variable de retorno
DEFINE iSqlErr INTEGER;
DEFINE v_codigo_ret CHAR(7);

--535
DEFINE wBegin CHAR(1);


LET v_mensaje = 'ERROR GENERAL';
LET v_folio = '';
LET v_credito = 1;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
LET s_CodRet = '';
LET v_mensaje = '';
LET s_Mensaje = '';
LET s_Cc = 0;
LET s_AfectacionC = 0;
LET s_CodleyendaC = '';
LET s_Ci = 0;
LET s_AfectacionI = 0;
LET s_CodleyendaI = '';
LET s_Ca = 0;
LET s_AfectacionA = 0;
LET s_CodleyendaA = '';
LET s_Cin = 0;
LET s_AfectacionIn = 0;
LET s_CodleyendaIn = '';

--Variables para la bitacora
LET v_descripcion = 'ERROR'; 
LET v_fechahora = CURRENT;
LET v_folio_csuac = 'ERROR';
LET v_fky_accion = 0;
LET v_fky_aclaracion = 0;
LET v_fky_area = 0;
LET v_fky_estatus_aclaracion = 0;
LET v_estatus_corp_analisis = 0;
LET v_estatus_corp_general = 0;
LET v_fky_usuario = 0;

--Codigo de retorno
LET v_codigo_ret = '';


--535
LET wBegin = 'N';


BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_codigo_ret = iSqlErr;
				RETURN v_codigo_ret;
			END IF;
		END EXCEPTION;
	
		ON EXCEPTION SET iSqlErr
			  LET v_codigo_ret = iSqlErr;
			  --ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;

			  RETURN v_codigo_ret;
		   END EXCEPTION;

		   ON EXCEPTION IN (-535)
			  LET wBegin = "S";
			  --ROLLBACK WORK;
			  COMMIT WORK;
				SET ISOLATION TO DIRTY READ;

			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   
	
--	BEGIN WORK;

    FOREACH v_folio WITH HOLD FOR
            SELECT DISTINCT (rec.FOLIO_CSUAC), tp.tipo_producto
            INTO v_folio, v_producto
            FROM ACL_RECUPERACION_SALDOS rec
            LEFT JOIN acl_aclaracion acl    ON acl.pky_aclaracion=rec.fky_aclaracion
            LEFT JOIN acl_producto producto ON producto.pky_producto=acl.fky_producto
            LEFT JOIN acl_tipo_producto tp  ON tp.pky_tipo_producto=producto.fky_tipo_producto 
            WHERE CRON_ACTIVO='1'
			
--		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/RECSALDOS"||v_folio||".out";
	---		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/sp_recuperacion_saldos.trc";
--			TRACE ON;

                IF (v_producto == 1) THEN
                    --CREDITO
                        CALL "informix".sp_upd_credrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;

						LET v_codigo_ret = s_CodRet;


							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;						
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '208') THEN
								LET v_mensaje = 'No se realizó la afectación de comision/iva. ';
								--Variables para la bitacora
								LET v_descripcion = 'No se realizó la afectación de comision/iva...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;							
							IF (s_CodRet == '000' OR s_CodRet == '000006' OR s_CodRet == '000000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	

									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
										
									END IF;
								END IF;
								
							ELSE
							
							IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
								
								--Insertar a acl_bitacora_error_rec_saldo para errores
								LET v_fechahora = current; 
								INSERT INTO "informix".acl_bitacora_error_rec_saldo (
								codigo,
								folio_csuac,
								fecha
								)
								VALUES (
								s_CodRet,
								v_folio,
								v_fechahora
								);
								
							END IF;
								
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF
				--DEBITO
                IF (v_producto == 2) THEN
                        CALL "informix".sp_upd_debrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;
						
						LET v_codigo_ret = s_CodRet;

							
							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;								
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'||' Folio: '||v_folio; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);		
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
							ELSE
								IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
									
									--Insertar a acl_bitacora_error_rec_saldo para errores
									LET v_fechahora = current; 
									INSERT INTO "informix".acl_bitacora_error_rec_saldo (
									codigo,
									folio_csuac,
									fecha
									)
									VALUES (
									s_CodRet,
									v_folio,
									v_fechahora
									);
									
								END IF;
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF	
--           COMMIT;
    END FOREACH
	LET v_codigo_ret = '000000';
	RETURN v_codigo_ret;
END;
END PROCEDURE;