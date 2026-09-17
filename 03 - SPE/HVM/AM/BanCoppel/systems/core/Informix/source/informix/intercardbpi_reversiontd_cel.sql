CREATE PROCEDURE "informix".reversiontd_cel
	(pTarjeta          CHAR(16),
	 pSucursal         CHAR(4),
         pUsuario          CHAR(8),
         pOriFolio         CHAR(16),
	 pOriDocumento     INTEGER,
         pNumCredito       CHAR(20),
         pNumTran          CHAR(4),
         pMonto            MONEY(16,2),
	 pMonto2           MONEY(16,2),
         pNumTranCash      CHAR(4),
	 pOriFolioCash	   CHAR(15),
	 pMontoRev         MONEY(16,2),
         pFolio            CHAR(16),
	 pDocumento        INTEGER,
         pNumTranS         CHAR(4),
         pDivisa           CHAR(2),
         pComSucursal      CHAR(4),
         pComUsuario       CHAR(8),
         pOriComFolio      CHAR(16),
         pOriComDocumento  INTEGER,
         pComNumCredito    CHAR(20),
         pComNumTran       CHAR(4),
         pComMonto         MONEY(16,2),
         pComRevMonto      MONEY(16,2),
         pComFolio         CHAR(16),
         pComDocumento     INTEGER,
         pComNumTranS      CHAR(4),
         pComDivisa        CHAR(2),
	 pComBandera       CHAR(1),
         pOriSurFolio      CHAR(16),
         pOriSurDocumento  INTEGER,
	 pOriSurNumTran    CHAR(4),
         pOriSurMonto      MONEY(16,2),
         pSurMonto         MONEY(16,2),
         pSurFolio         CHAR(16),
         pSurDocumento     INTEGER,
	 pSurNumTran       CHAR(4),
         pSurDivisa        CHAR(2))

   RETURNING CHAR(5),      -- Codigo de Retorno
             DATE,         -- Fecha Aplicacion
             CHAR(5),      -- Codigo de Retorno Comision
             DATE;         -- Fecha Aplicacion Comision

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE SaldoCom            MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE MontoOtorgado       MONEY(16,2);
   DEFINE CodigoRef           INTEGER;
   DEFINE CodigoFun           CHAR(3);
   DEFINE wEmpresa            CHAR(3);
   DEFINE wSucursal           CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE pForzado            CHAR(1);
   DEFINE wBegin              CHAR(1);
   DEFINE vusuario            char(8);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END EXCEPTION;



  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin = "N";
   LET vusuario = USER;

   LET cod_ret = "00000";
   LET cod_ret2 = "00000";
   LET CodigoFun = "002";
   LET MontoOtorgado = 0;

   LET FechaHoy = "01/01/2007";

 
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;

END PROCEDURE
 
;