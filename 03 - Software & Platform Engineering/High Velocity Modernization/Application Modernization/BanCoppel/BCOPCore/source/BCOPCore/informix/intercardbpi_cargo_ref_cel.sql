CREATE PROCEDURE "informix".cargo_ref_cel
	(pTarjeta       CHAR(16),
	 pSucursal      CHAR(4),
     	 pUsuario       CHAR(8),
     	 pNumTran       CHAR(4),
     	 pNumTranS      CHAR(4),
     	 pFolio         CHAR(16),
     	 pNumCredito    CHAR(20),
	 pDocumento     INTEGER,
     	 pMonto         MONEY(16,2),
	 pMonto2        MONEY(16,2),
	 pNumTranCash   CHAR(4),
	 pFolioCash     CHAR(16),
     	 pDivisa        CHAR(2),
     	 pReferencia    CHAR(40),
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
	 pSurNumTran    CHAR(4),
     	 pSurNumTranS   CHAR(4),
     	 pSurFolio      CHAR(16),
     	 pSurDocumento  INTEGER,
     	 pSurMonto      MONEY(16,2),
     	 pSurDivisa     CHAR(2),
     	 pSurReferencia CHAR(40)
         )

   RETURNING CHAR(5),      -- Codigo de Retorno
             CHAR(4),      -- Transaccion
             DATE,         -- Fecha Aplicacion
             MONEY(16,2),  -- Saldo Disponible
             MONEY(16,2),  -- Importe Cargado
             CHAR(5),      -- Codigo de Retorno Comision
             CHAR(4),      -- Transaccion Comision
             DATE,         -- Fecha Aplicacion Comision
             MONEY(16,2),  -- Saldo Disponible Comision
             MONEY(16,2);  -- Importe Cargado ComisioN

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE Saldo               MONEY(16,2);
   DEFINE SaldoCom            MONEY(16,2);
   DEFINE FechaHoy            DATE;
   DEFINE pMonto              MONEY(16,2);
   DEFINE pComMonto           MONEY(16,2);
   DEFINE pNumTran            CHAR(4);
   DEFINE pComNumTran         CHAR(4);

   let cod_ret = "000  ";
   let pNumTran = "7777";
   let pComNumTran = "3333";
   let cod_ret2 = "000  ";
   let FechaHoy = "01/01/2007";
   let Saldo = 1500.00;
   let SaldoCom = 1500.00;
   let pMonto = 200;
   let pComMonto = 200;
   

   RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;

END PROCEDURE;