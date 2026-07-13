CREATE PROCEDURE "informix".reversiontd_cel
	      (pTarjeta              CHAR(16),
	       pSucursal             CHAR(4),
         pUsuario              CHAR(8),
         pOriFolio             CHAR(16),
	       pOriDocumento         INTEGER,
         pNumCredito           CHAR(20),
         pNumTran              CHAR(4),
         pMonto                MONEY(16,2),
	       pMonto2               MONEY(16,2),
	       pCashTranCen	       CHAR(4),
	       pCashFolio            CHAR(15),
	       pMontoRev             MONEY(16,2),
         pFolio                CHAR(16),
	       pDocumento            INTEGER,
         pNumTranS             CHAR(4),
         pDivisa               CHAR(2),
         pComSucursal          CHAR(4),
         pComUsuario           CHAR(8),
         pOriComFolio          CHAR(16),
         pOriComDocumento      INTEGER,
         pComNumCredito        CHAR(20),
         pComNumTran           CHAR(4),
         pComMonto             MONEY(16,2),
         pComRevMonto          MONEY(16,2),
         pComFolio             CHAR(16),
         pComDocumento         INTEGER,
         pComNumTranS          CHAR(4),
         pComDivisa            CHAR(2),
  	     pComBandera           CHAR(1),
         pSurcharge            CHAR (1), -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)
         pOriComCashFolio      CHAR(16),
         pOriComCashDocumento  INTEGER,
	       pOriComCashNumTran    CHAR(4),
         pOriComCashMonto      MONEY(16,2),
         pComCashMonto         MONEY(16,2),
         pComCashFolio         CHAR(16),
         pComCashDocumento     INTEGER,
	       pComCashNumTran       CHAR(4),
         pComCashDivisa        CHAR(2))

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
   DEFINE MtoMov	            DECIMAL(14,2);
   DEFINE MtoReversion	      DECIMAL(14,2);
   DEFINE TipoCredito         CHAR(2);
   DEFINE VSucursal           CHAR(3);
   DEFINE VFecha	            DATE;
   DEFINE MtoCargado	        DECIMAL(14,2);
   DEFINE MtoCgoCom 	        DECIMAL(14,2);
   DEFINE vRefCgo	            VARCHAR(100);
   DEFINE vRefCom	            VARCHAR(100);
   DEFINE vRefComCash	        VARCHAR(100);
   DEFINE vTranNro	          SMALLINT;
   DEFINE vTranNroPASO	      SMALLINT;
   DEFINE vMontoVal           DECIMAL(14,2);
   DEFINE vTranComDisp        CHAR(4);
   DEFINE vTranNroPASOc       CHAR(4);
   DEFINE vComDisp            DECIMAL(14,2);
   DEFINE vTranRelac          CHAR(4);
--JOM INI
   DEFINE vSaldoFavor         DECIMAL(14,2);
   define vMontoVal_afavor    DECIMAL(14,2);
   DEFINE vTranfavor          CHAR(4);
--JOM FIN
-- Jom INI limites
   DEFINE vnum_cliente          char(10);
   DEFINE vcodret               char(05);
   DEFINE vmsje_limites         char(80); 
   DEFINE vid_autor             char(01);
   DEFINE vid_transacc          char(02);
   DEFINE vid_canal             char(02);
   DEFINE vuser_limit           char(08);
-- Jom FIN limites

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END EXCEPTION;

 --SET DEBUG FILE TO "/ids10_uc9/raul/surcharge/juan/reversion_td_cel.out";
 --TRACE ON;

  SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin = "N";
   LET vusuario = USER;

   LET cod_ret = "000";
   LET cod_ret2 = "000";
   LET CodigoFun = "002";
   LET MontoOtorgado = 0;
   LET FechaHoy = NULL;
   LET vRefCgo = " ";
   LET vRefCom = " ";
   LET vRefComCash = " ";
   LET vTranRelac = "0000";

--JOM INI
   let vSaldoFavor = 0;
   let vMontoVal_afavor = 0;
   LET vTranfavor = '';
   LET vTranNroPASO	= 0;
   LeT vTranNroPASOc = '';
--JOM FIN
-- Jom INI limites
   let vnum_cliente     = '';
   let vcodret          = '';
   let vmsje_limites    = '';
   let vid_autor        = '';
   let vid_transacc     = '';
   let vid_canal        = '';
   let vuser_limit      = '';
-- Jom FIN limites

   if (pmonto is null) then let pmonto = 0; end if; 
   if (pComMonto is null) then let pComMonto = 0; end if;

   IF LENGTH(pSucursal) < 4 THEN
   	LET pSucursal = "9" || TRIM(pSucursal);
   END IF


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
          b.monto_otorgado - b.sdo_cap_insoluto, c.cod_tipcred, numcte
     INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
          Saldo, TipoCredito, vnum_cliente
     FROM sd_maecred a, sd_maesdos b, sd_definicion c
    WHERE a.empresa = "001"
      AND a.num_credito = pNumCredito
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
      AND a.empresa = c.empresa
      AND a.num_producto = c.num_producto;


   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET cod_ret = "008";
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END IF;

   IF(TipoCredito <> "03") THEN -- Credito no es tarjeta
      LET cod_ret = "206";
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END IF;

   IF StatusCred IN ("BT","E2","E3","CC") THEN -- Cancelado o Bloqueado
      LET cod_ret = "207";
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END IF

   IF pMonto < 0 OR pMonto2 < 0 THEN
      LET cod_ret = "410";
      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
   END IF

   SELECT fecha_hoy
     INTO FechaHoy
     FROM bdicred:sd_fechas
    WHERE empresa = wEmpresa;

   -- *****************************
   -- Valida Datos de la Operacion*
   -- *****************************
   IF NOT pOriFolio IS NULL AND TRIM(pOriFolio) <> "" THEN


	LET vTranNroPASO = pNumTran;
	LET vTranNroPASOc = vTranNroPASO;

   	IF LENGTH(vTranNroPASOc) < 4 THEN
       		LET vTranNroPASOc = LPAD(TRIM(vTranNroPASOc),4,"6");
   	END IF

        SELECT NVL(tran_relac,"0000")
          INTO vTranRelac
          FROM bdinteg:si_transacc
         WHERE empresa = wEmpresa
           AND sistema = "06"
           AND numero = vTranNroPASOc;

      SELECT monto INTO vMontoVal
          FROM sd_movdia
         WHERE empresa = wEmpresa
           AND num_credito = pNumCredito
           AND folio_suc = pOriFolio
           AND reversado = 'N'   
	   AND transacc_suc = vTranRelac;

     SELECT monto INTO vMontoVal_afavor
          FROM sd_movdia
         WHERE empresa = wEmpresa
           AND num_credito = pNumCredito
           AND folio_suc = pOriFolio
           AND reversado = 'N'   
	   AND transacc_suc IN ("7381","7382","7383","7384","6877");

       if ( vMontoVal_afavor is null) then let vMontoVal_afavor = 0; end if;

    IF (vMontoVal is null or vMontoVal = '') then
         if ( vMontoVal_afavor > 0) then 
            let  vMontoVal = vMontoVal_afavor;
         else
            let vMontoVal = -1;
         end if;
    else
       let vMontoVal = vMontoVal + vMontoVal_afavor;
    end if;

	IF pCashTranCen = "0812" THEN
        	IF vMontoVal <> pMonto2 THEN
                	LET cod_ret = "410";
                	RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
        	END IF
	ELSE
        	IF vMontoVal <> pMonto THEN
                	LET cod_ret = "410";
                	RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;
        	END IF
	END IF
   END IF

--JOM INI
  -- ************************************************************
   -- *       reverso de saldo a favor                           *
   -- ************************************************************

     IF NOT pOriFolio IS NULL AND TRIM(pOriFolio) <> "" THEN
        SELECT transacc_suc, NVL(monto,0)
          INTO vTranfavor, vSaldoFavor
          FROM sd_movdia
         WHERE empresa = wEmpresa
           AND num_credito = pNumCredito
           AND folio_suc = pOriFolio
           AND transacc_suc IN ("7381","7382","7383","7384","6877");

       IF vSaldoFavor IS NULL  THEN
           LET vSaldoFavor= 0;
       END IF

        LET nrows = dbinfo("sqlca.sqlerrd2");
        IF(nrows > 0) THEN
            EXECUTE PROCEDURE abono_cred
              (wEmpresa, pNumCredito, pSucursal, pUsuario, vTranfavor, vSaldoFavor,
               pOriFolio, pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
            INTO cod_ret;
         END IF
       END IF

   -- *****************************
   -- Reversa Movimiento de Cargo *
   -- *****************************
   IF NOT pOriFolio IS NULL AND TRIM(pOriFolio) <> "" THEN

        EXECUTE PROCEDURE abono_cred
          (wEmpresa, pNumCredito, pSucursal, pUsuario, pNumTran, (pMonto - vSaldoFavor),
           pOriFolio, pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
        INTO cod_ret;

   END IF
--JOM FIN

   -- *****************************************************
   -- Reversa Movimiento de Cargo por Cash Back o Advance *
   -- *****************************************************
   IF NOT pCashFolio IS NULL AND TRIM(pCashFolio ) <> "" THEN

	EXECUTE PROCEDURE abono_cred
	  (wEmpresa, pNumCredito, pSucursal, pUsuario, pCashTranCen, pMonto2,
	   pCashFolio, pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
	INTO cod_ret;

   END IF


   -- ********************************
   -- Reversa Movimiento de Comision *
   -- ********************************
   IF pMonto = pMontoRev THEN
   	IF NOT pOriComFolio IS NULL AND TRIM(pOriComFolio ) <> "" THEN
   	
   	   	-- jom ini mod surcharge
        if (pSurcharge = 'V') then
            if (pComNumTran = '0867') then   -- red
                let pComNumTran = '6847';
            elif (pComNumTran = '0868') then -- convenio
                let pComNumTran = '6848';
            elif (pComNumTran = '0869') then -- internacional
                let pComNumTran = '6849';
            elif (pComNumTran = '0874') then     -- red conuslta
                let pComNumTran = '0893';
            elif (pComNumTran = '0875') then -- convenio consulta
                let pComNumTran = '0894';
            elif (pComNumTran = '0876') then -- internacional consulta
                let pComNumTran = '0895';
            end if;
        end if;
   -- jom fin mod surcharge
   	
		EXECUTE PROCEDURE abono_cred
	  	  (wEmpresa, pNumCredito, pSucursal, pUsuario, pComNumTran,
		   pComMonto, pOriComFolio, pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
		INTO cod_ret;
	END IF

   	IF NOT pOriComCashFolio IS NULL AND TRIM(pOriComCashFolio ) <> "" THEN
	
		EXECUTE PROCEDURE abono_cred
	  	  (wEmpresa, pNumCredito, pSucursal, pUsuario,
		   pOriComCashNumTran, pOriComCashMonto, pOriComCashFolio,
		   pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
		INTO cod_ret;
	END IF
   END IF

   -- **************************************************************
   -- Reversa Movimiento de Comision por Disposicion de Efectivo  **
   -- **************************************************************
   IF NOT pOriFolio IS NULL AND TRIM(pOriFolio) <> "" THEN
	SELECT DECODE(transacc_suc,"6901","6995","6902","6996"), monto
	  INTO vTranComDisp, vComDisp
	  FROM sd_movdia
	 WHERE empresa = wEmpresa
	   AND num_credito = pNumCredito
	   AND folio_suc = pOriFolio
	   AND transacc_suc IN ("6901", "6902");

        LET nrows = dbinfo("sqlca.sqlerrd2");
        IF(nrows > 0) THEN

                EXECUTE PROCEDURE abono_cred
                  (wEmpresa, pNumCredito, pSucursal, pUsuario,
                   vTranComDisp, vComDisp, pOriFolio,
                   pTarjeta, 0, 0, FechaHoy, " ", "R"," "," ")
                INTO cod_ret;
	END IF

   END IF
   
   -- *********************************************
   -- validacion de limites de operaciones        *
   -- *********************************************
   -- validacion de limites jom ini
    select usuario
      into vuser_limit
      from bdinteg:si_usuario_limites
     where usuario = pUsuario
       and empresa = wEmpresa;

       if ( vuser_limit is not null or vuser_limit <> '' ) then 
            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:si_transacc_limites
             where transacc = vTranRelac
               and sistema = '06'
               and empresa = wEmpresa;

            if (vid_transacc is not null or vid_transacc <> '') then
                execute procedure bdinteg:sp_reversa_acum_x(FechaHoy, vnum_cliente, pNumCredito, vid_transacc, vid_canal, pMonto)
                into vcodret, vmsje_limites, vid_autor;

--                if vcodret <> '00000' then   -- NO SE TOMA EN CUENTA EN CODIGO DE RETORNO
--                	LET cod_ret = "410";       -- NO SE TOMA EN CUENTA EN CODIGO DE RETORNO
--                	RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy; -- NO SE TOMA EN CUENTA EN CODIGO DE RETORNO
--                end if;                      -- NO SE TOMA EN CUENTA EN CODIGO DE RETORNO
            end if;
        end if;
--validacion de limites jom ini


   -- ************************************************************
   -- *       Aplica Movimiento Compensatorio si es el caso      *
   -- ************************************************************
   IF pMonto <> pMontoRev THEN

	LET vTranNro = pNumTran;
	LET pNumTran = vTranNro;
   	IF LENGTH(pNumTran) < 4 THEN
       		LET pNumTran = LPAD(TRIM(pNumTran),4,"6");
   	END IF

	LET pComRevMonto = 0;
	LET pComCashMonto = 0;
	LET pNumTran = pNumTran;
   	SELECT NVL(tran_relac,"0000")
     	  INTO pNumTran
     	  FROM bdinteg:si_transacc
         WHERE empresa = wEmpresa
      	   AND sistema = "06"
      	   AND numero = pNumTran;

	FOREACH SELECT referencia
          INTO vRefCgo
	  FROM sd_movdia
	 WHERE empresa = wEmpresa
	   AND num_credito = pNumCredito
	   AND folio_suc = pOriFolio
	   AND transacc_suc = pNumTran
	UNION ALL
        SELECT referencia
          FROM sd_movhis
         WHERE empresa = wEmpresa
           AND num_credito = pNumCredito
           AND folio_suc = pOriFolio
           AND transacc_suc = pNumTran

		IF vRefCgo IS NULL THEN
			LET vRefCgo = pOriFolio;
		END IF

	END FOREACH

	EXECUTE PROCEDURE cargo_ref_cel
	 (pTarjeta, pSucursal, pUsuario, pNumTran, pNumTran, pFolio,
	  pNumCredito, pDocumento, pMontoRev, pMonto2, pCashTranCen, pCashFolio,
	  pDivisa, vRefCgo, pComSucursal, pComUsuario, pComNumTranS,
	  pComNumTranS, pComFolio, pComNumCredito, pComDocumento,
	  pComRevMonto, pComDivisa, vRefCom, pComBandera, pSurcharge, pComCashNumTran,
	  pComCashNumTran, pComCashFolio, pComCashDocumento,
	  pComCashMonto, pComCashDivisa, vRefComCash)
	INTO cod_ret, pNumTran, VFecha, Saldo, MtoCargado,
	     cod_ret2, pComNumTran, VFecha, SaldoCom, MtoCgoCom;

  END IF

      RETURN cod_ret, FechaHoy, cod_ret2, FechaHoy;

END PROCEDURE
DOCUMENT
'Esta funcion realiza la reversion de tarjeta de credito  ',
'AUTOR : Antonio Ruiz Mtz ',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".sp_act_sdoamortiza(eEmpresa CHAR(3), pNumCrd CHAR(20))
       RETURNING VARCHAR(5);

DEFINE P_COD_RET  VARCHAR(5);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE SQL_ERR    INTEGER;
DEFINE ISAM_ERR   INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE vNumCrd    char(20);
DEFINE vMtoOtorgado decimal(14,2);
DEFINE vSdoInsoluto decimal(14,2);
DEFINE vDifSdo      decimal(14,2);
DEFINE vStatus      char(2);
					   
					   
DEFINE vMtoCapAMortiza decimal(14,2);
DEFINE vDifMtoOtorgado decimal(14,2);
DEFINE vDifSdoReal     decimal(14,2);
DEFINE vMtoCapPago     decimal(14,2);
DEFINE vCapNoExigAmortiza     decimal(14,2);
DEFINE vCapExigAmortiza     decimal(14,2);
DEFINE vCapExigible     decimal(14,2);
DEFINE vCapNoExigible     decimal(14,2);
DEFINE vCapTotal     decimal(14,2);
DEFINE vFecActualiza   date;

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET;
  END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/sp_actamo.out";
 --TRACE ON;



  LET P_COD_RET       = '00000';
  LET P_MENSAJE       = 'PROCESO EXITOSO';
  LET vNumCrd         = '';
  LET vMtoOtorgado    = 0;
  LET vDifSdo         = 0;
  LET vStatus         = '';
				   
				   
  LET vMtoCapAMortiza = 0;
  LET vDifMtoOtorgado = 0;
  LET vSdoInsoluto    = 0;
  LET vDifSdoReal     = 0;
  LET vMtoCapPago     = 0;
  LET vFecActualiza   = '';
  LET vCapNoExigAmortiza = 0;
  LET vCapExigAmortiza   = 0;
  LET vCapExigible       = 0;
  LET vCapNoExigible     = 0;
  LET vCapTotal          = 0;

  --FOREACH
        SELECT num_credito,status_cred
        INTO vNumCrd,vStatus
        FROM sd_maecredcrd
        WHERE empresa = eEmpresa
        AND num_credito = pNumCrd;
        --ORDER BY 1


        SELECT sdo_capital + mto_venc_trasp + monto_vencido + cap_tras_no_venci,sdo_cap_insoluto
        INTO vSdoInsoluto,vCapTotal
        FROM sd_maesdoscrd
        WHERE empresa = eEMpresa
          AND num_credito = vNumCrd;

        SELECT sum(capital_debe - capital_pagado)
        INTO vMtoCapAMortiza
        FROM sd_amortiza_creditocrd
        WHERE empresa  = eEMpresa
          AND num_credito = vNumCrd;

        SELECT max(fecha_cuota)
        INTO vFecActualiza
        FROM sd_amortiza_creditocrd
        WHERE empresa = eEmpresa
          AND num_credito = vNumCrd;

	IF (vSdoInsoluto = vCapTotal) and (vStatus = 'VP' or vStatus = 'AA' or vStatus = 'E1') THEN
             IF vSdoInsoluto  < vMtoCapAMortiza THEN
                LET vDifSdoReal =  vMtoCapAMortiza - vSdoInsoluto ;

                UPDATE sd_amortiza_creditocrd SET capital_debe = capital_debe - vDifSdoReal
                WHERE empresa = eEmpresa
                AND num_credito = vNumCrd
                AND fecha_cuota = vFecActualiza;

                UPDATE sd_amortiza_creditocrd SET capital_status = '5'
                WHERE empresa = eEmpresa
                AND num_credito = vNumCrd
                AND fecha_cuota = vFecActualiza
                AND capital_debe = capital_pagado;

             END IF;
        END IF;
  --END FOREACH;
END ;
     RETURN P_COD_RET;

END PROCEDURE;