CREATE PROCEDURE "informix".cons_saldo_cel_pago
	     (pTarjeta       CHAR(16),
         pNumCredito    CHAR(20),
         pComSucursal   CHAR(4),
         pComUsuario    CHAR(8),
         pComNumTran    CHAR(4),
         pComNumTranS   CHAR(4),
         pComFolio      CHAR(16),
         pComNumCredito CHAR(20),
         pComDocumento  INTEGER,
         pComMonto      MONEY(16,2),
         pComDivisa     CHAR(2),
         pComReferencia CHAR(40),
	     pComBandera    CHAR(1),
         pSurcharge     CHAR (1)) -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)


   RETURNING CHAR(5),      -- Codigo de Retorno
             MONEY(16,2),  -- Saldo adeudo total
	         CHAR(1),	   -- Status del Credito
             CHAR(5),      -- Codigo de Retorno Comision
             DATE,         -- Fecha Aplicacion Comision,
             MONEY(16,2),  -- Saldo Disponible
             MONEY(16,2),  -- Pago minimo
             MONEY(16,2),  -- Pago para no generar intereses
             DATE;         -- Fecha limite de pago (Cuando se regersa '1900-01-01' la leyenda es "INMEDIATO"


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE CodRet2             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE pNumCre             CHAR(20);

   DEFINE Saldo               MONEY(16,2);
   DEFINE FechaHoy            DATE;
   DEFINE VStatus             CHAR(1);
   DEFINE dTotalLiq           DECIMAL(18,2);
   DEFINE mPgomin             DECIMAL(18,2);
   DEFINE mPagonoint          DECIMAL(18,2);
   DEFINE dFechalimite        DATE;

   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Cons_Sdo_TC.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo, mPgomin, mPagonoint, dFechalimite;
   END EXCEPTION;

 --SET DEBUG FILE TO "/respaldos/IPCB/Cons_Sdo_TC_pago_JOM.out";
 --TRACE ON;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

    LET cod_ret       = "000";
    LET CodRet2      = "00000";
    LET VStatus       ="1";
    LET Saldo         = 0;
    LET FechaHoy      = NULL;
	LET mPgomin       = 0;
	LET dTotalLiq     = 0;
    LET mPagonoint    = 0;
    LET dFechalimite  = null;
    LET pNumCre       = '';
    LET cod_ret2      = "000";
    LET pNumCre       = pNumCredito;

    EXECUTE PROCEDURE "informix".cons_saldo_cel(pTarjeta,pNumCre,pComSucursal,pComUsuario,pComNumTran,pComNumTranS,pComFolio,pComNumCredito,pComDocumento,pComMonto,pComDivisa,pComReferencia,pComBandera,pSurcharge)
            INTO cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo;

    IF (cod_ret = '000') THEN
        EXECUTE PROCEDURE "informix".sp_consulta_saldocortemin('001',pNumCre,0) -- Pago para no generar intereses actualizado con pagos
               INTO CodRet2, mPagonoint;
        IF (CodRet2 = '00000') THEN
            EXECUTE PROCEDURE "informix".sp_consulta_saldocortemin('001',pNumCre,4) -- pago minimo al corte actualizado con pagos
                   INTO CodRet2, mPgomin;
            IF (CodRet2 = '00000') THEN
                Select NVL(prox_fecha_pago,DATE(1))
                  into dFechalimite 
                  from "informix".sd_maecred a,
                       "informix".sd_maecredanexo b
                  where a.num_credito = pNumCre
                    and a.empresa = b.empresa
                    and a.num_credito = b.num_credito;
            ELSE
               LET cod_ret = "209";
            END IF;
        ELSE
            LET cod_ret = "209";
        END IF;
    END IF;

    IF (nvl(mPagonoint,0) <= 0) THEN LET mPagonoint = 0; END IF;
    IF (nvl(mPgomin,0) <= 0)    THEN LET mPgomin = 0;    END IF;


    RETURN cod_ret, dTotalLiq, VStatus, cod_ret2, FechaHoy, Saldo, mPgomin, mPagonoint, dFechalimite;

END PROCEDURE;