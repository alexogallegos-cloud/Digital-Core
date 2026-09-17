CREATE PROCEDURE "informix".cargo_ref_cel_pba
	  (	pTarjeta             CHAR(16),
		pSucursal            CHAR(4),
		pUsuario             CHAR(8),
		pNumTran             CHAR(4),
		pNumTranS            CHAR(4),
		pFolio               CHAR(16),
		pNumCredito          CHAR(20),
		pDocumento           INTEGER,
		pMonto               MONEY(16,2),
		pMonto2              MONEY(16,2),
		pCashTranCen         CHAR(4),
		pCashFolio           CHAR(15),
		pDivisa              CHAR(2),
		pReferencia          CHAR(40),
		pComSucursal         CHAR(4),
		pComUsuario          CHAR(8),
		pComNumTran          CHAR(4),
		pComNumTranS         CHAR(4),
		pComFolio            CHAR(16),
		pComNumCredito       CHAR(20),
		pComDocumento        INTEGER,
		pComMonto            MONEY(16,2),
		pComDivisa           CHAR(2),
		pComReferencia       CHAR(40),
		pComBandera          CHAR(1),
		pSurcharge           CHAR(1),  -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)
		pComCashNumTran      CHAR(4),
		pComCashNumTranS     CHAR(4),
		pComCashFolio        CHAR(16),
		pComCashDocumento    INTEGER,
		pComCashMonto        MONEY(16,2),
		pComCashDivisa       CHAR(2),
		pComCashReferencia   CHAR(40))

   RETURNING CHAR(5),       -- Codigo de Retorno
             CHAR(4),       -- Transaccion
             DATE,          -- Fecha Aplicacion
             MONEY(16,2),   -- Saldo Disponible
             MONEY(16,2),   -- Importe Cargado
             CHAR(5),       -- Codigo de Retorno Comision
             CHAR(4),       -- Transaccion Comision
             DATE,          -- Fecha Aplicacion Comision
             MONEY(16,2),   -- Saldo Disponible Comision
             MONEY(16,2);   -- Importe Cargado ComisioN

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret               CHAR(5);
   DEFINE cod_ret2              CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nrows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);

   DEFINE NumProducto           CHAR(4);
   DEFINE StatusCred            CHAR(2);
   DEFINE Saldo                 MONEY(16,2);
   DEFINE SaldoCom              MONEY(16,2);
   DEFINE TipoCredito           CHAR(2);
   DEFINE MontoOtorgado         MONEY(16,2);
   DEFINE v_com1_dlls           MONEY(16,2);
   DEFINE v_com2_dlls           MONEY(16,2);
   DEFINE v_mtofavor_dlls       MONEY(16,2);
   DEFINE v_mto1_dlls           MONEY(16,2);
   DEFINE v_mto2_dlls           MONEY(16,2);
   DEFINE MtoTot                MONEY(16,2);
   DEFINE TotCargo              MONEY(16,2);
   DEFINE TotComision           MONEY(16,2);
   DEFINE CodigoRef             INTEGER;
   DEFINE CodigoFun             CHAR(3);
   DEFINE wEmpresa              CHAR(3);
   DEFINE wSucursal             CHAR(4);
   DEFINE wDivisa               CHAR(2);
   DEFINE FechaHoy              DATE;
   DEFINE pForzado              CHAR(1);
   DEFINE wBegin                CHAR(1);
   DEFINE vusuario              CHAR(8);
   DEFINE v_paso                SMALLINT;
   DEFINE v_mn                  CHAR(2);
   DEFINE v_dv                  CHAR(2);
   DEFINE v_valor               SMALLINT;
   DEFINE v_tipocambio          DECIMAL(14,6);
   DEFINE v_mensaje             VARCHAR(100);
   DEFINE TasaIva               DECIMAL(5,3);
   DEFINE Iva                   DECIMAL(14,2);
   DEFINE vMtoComDisp           DECIMAL(14,2);
   DEFINE vMtoComDisp_iva       DECIMAL(14,2);     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   DEFINE v_faplica             CHAR(1);
   DEFINE v_factor              DECIMAL(9,6);
   DEFINE v_rangos              CHAR(1);
   DEFINE v_rmax                MONEY(14,2);
   DEFINE v_codparam            CHAR(4);
   DEFINE vSdoPos               DECIMAL(14,2);
   DEFINE vMtoPaso              DECIMAL(14,2);
-- Jom INI Bloqueo de cuentas
   DEFINE vBloqueo              INTEGER;
-- Jom FIN Bloqueo de cuentas
   DEFINE vMtoFavor             DECIMAL(16,2);
   DEFINE pNumTranFavor         CHAR(4);
-- Jom INI limites
   DEFINE vnum_cliente          char(20);
   DEFINE vcodret               char(05);
   DEFINE vmsje_limites         char(80); 
   DEFINE vid_autor             char(01);
   DEFINE vid_transacc          char(02);
   DEFINE vid_canal             char(02);
   DEFINE vuser_limit           char(08);
-- Jom FIN limites
   DEFINE vEscajero             char(01);
   DEFINE v_bloqprod            INTEGER;   
   DEFINE vValDocto             char(01);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/cargoref_cel.out";
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin           = "N";
   LET vusuario         = USER;
   LET cod_ret          = "000";
   LET Saldo            = 0;
   LET SaldoCom         = 0;
   LET cod_ret2         = "000";
   LET SaldoCom         = 0;
   LET MontoOtorgado    = 0;
   LET FechaHoy         = NULL;
   LET v_paso           = 0;
   LET MtoTot	        = 0;
   LET v_valor          = 0;
   LET v_tipocambio     = 0;
   LET v_mensaje        = "??";
   LET v_com1_dlls      = 0;
   LET v_com2_dlls      = 0;
   LET v_mtofavor_dlls  = 0;
   LET v_mto1_dlls      = 0;
   LET v_mto2_dlls      = 0;
   LET vMtoComDisp      = 0;
   LET vMtoComDisp_iva  = 0;
   LET vMtoPaso         = 0;
-- Jom INI Bloqueo de cuentas
   LET vBloqueo	        = 0;
-- Jom FIN Bloqueo de cuentas
   LET vMtoFavor        = 0;
   LET pNumTranFavor = pNumTran;
-- Jom INI limites
   LET vnum_cliente     = '';
   LET vcodret          = '';
   LET vmsje_limites    = '';
   LET vid_autor        = '';
   LET vid_transacc     = '';
   LET vid_canal        = '';
   LET vuser_limit      = '';
-- Jom FIN limites
   LET v_bloqprod       = 0;
   LET vEscajero = '0';
   LET vValDocto = '';
     
   --se obtiene la transaccion a favor de acuerdo a la transaccion recibida   
	SELECT transacc_favor,cajero
	INTO pNumTranFavor,vEscajero
	FROM "informix".sd_conceptoscargoscredito
	WHERE transacc = pNumTran;
		
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN--cuando no exista en la tabla se pone el valor por default
      LET pNumTranFavor = pNumTran;
      LET vEscajero = '0';
    END IF;

    IF LENGTH(TRIM(pSucursal)) = 3 then
       LET pSucursal = "9" || TRIM(pSucursal);
    END IF

   SELECT valor INTO v_mn FROM bdinteg:"informix".si_param WHERE cod_param = 15; -- codigo mn
   SELECT valor INTO v_dv FROM bdinteg:"informix".si_param WHERE cod_param = 17; -- divisa de cambio
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   SELECT fecha_hoy
     INTO FechaHoy
     FROM "informix".sd_fechas;
    --WHERE empresa = wEmpresa;

   -- ************************
   -- Busca Datos del Credito*
   -- ************************
       SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
              b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
          c.cod_tipcred, d.iva, e.fecha_proceso,
          CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
          a.id_unidad_prod, numcte
         INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
              Saldo, TipoCredito, TasaIva, FechaHoy, vSdoPos,
              vBloqueo, vnum_cliente
         FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
          bdinteg:"informix".si_sucursales d
        WHERE a.num_credito = pNumCredito
          AND a.empresa = "001"
          AND b.num_credito = a.num_credito
          AND a.empresa = b.empresa
          AND c.num_producto = a.num_producto
          AND e.num_credito = a.num_credito
          AND e.empresa = a.empresa
          AND d.empresa = a.empresa
          AND d.sucursal = pSucursal;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pNumTranS = "9999" then
      	LET cod_ret = "100";
      ELSE
      	LET cod_ret = "008";
      END IF
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF(TipoCredito <> "03") THEN -- Credito no es tarjeta
      LET cod_ret = "206";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

-- ini -- Se agrega bloqueo de cuentas
-- Bloqueo de cuentas operaciones
-- id_unidad_prod = 2 = bloqueo pago
-- id_unidad_prod = 3 = bloqueo disposicion
-- id_unidad_prod = 4 = bloqueo pago y disposicion



--Jom ini Bloqueo de creditos
   IF (vBloqueo = 3 or vBloqueo = 4) THEN -- Bloqueado
      LET cod_ret = "207";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF
  
-- Jom Fin Bloqueo de creditos

   IF SUBSTR(StatusCred,1,1) IN ("B", "F", "C")  THEN -- Cancelado o Bloqueado
      LET cod_ret = "207";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

    select count(*) 
      into v_bloqprod
      from bdicred:"informix".sd_bloqueoprod 
     where num_producto=NumProducto 
       and transac_bloq in (pNumTran,pNumTranFavor,pComNumTran,pComNumTranS,pComCashNumTran,pComCashNumTranS);

   IF v_bloqprod > 0  THEN -- bloqueo por producto
      LET cod_ret = "199";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   -- ****************************
   -- Valida Datos del Plasticos *
   -- ****************************

   SELECT valida_docto
     INTO vValDocto
     FROM bdinteg:"informix".si_transacc
    WHERE empresa = wEmpresa
      AND sistema = "06"
      AND numero = pNumTran;

   IF ( nvl(vValDocto,'') <> 'T' ) then
       SELECT COUNT(*) INTO v_valor
         FROM "informix".sd_tarjeta
        WHERE empresa = wEmpresa
          AND num_tarjeta = pTarjeta
          AND status_tar = "A"
          AND expiracion >= FechaHoy;

       IF v_valor IS NULL OR v_valor = 0 THEN -- No hay Plasticos Asignados
          LET cod_ret = "208";
          RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
             cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
       END IF;
   END IF;

   -- ********************************************************
   -- Extrae Tipo de Cambio si se requiere para la operacion *
   -- ********************************************************
	IF pDivisa <> v_mn OR pComDivisa <> v_mn OR pComCashDivisa <> v_mn THEN
		SELECT precio_venta INTO v_tipocambio
	          FROM bdinteg:"informix".si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:"informix".si_tpcambio
					  WHERE empresa = "001"
					    AND divisa = v_dv);
	END IF

   -- *******************************************************
   -- Valoriza Movimientos en Moneda Diferente a 01 (Pesos) *
   -- *******************************************************

   IF pDivisa <> v_mn THEN
    LET v_mto1_dlls = pMonto;
	LET pMonto = v_mto1_dlls * v_tipocambio;
	LET v_mto2_dlls = pMonto2;
	LET pMonto2 = v_mto2_dlls * v_tipocambio;
   END IF

   IF pComMonto > 0 THEN
   	IF pComDivisa <> v_mn THEN
		LET v_com1_dlls = pComMonto;
		LET pComMonto = v_com1_dlls * v_tipocambio;
   	END IF
   END IF

   IF pComCashMonto > 0 THEN
   	IF pComCashDivisa <> v_mn THEN
		LET v_com2_dlls = pComCashMonto;
		LET pComCashMonto = v_com1_dlls * v_tipocambio;
   	END IF
   END IF

   -- *********************************************
   -- Extrae Comision por disposicion de efectivo *
   -- *********************************************
   IF  pNumTrans IN ("0800", "6900","0871","0872","0873") THEN
        SELECT valor INTO v_codparam
          FROM "informix".sd_param
         WHERE empresa = wEmpresa
           AND cod_param = "334";

        IF vSdoPos > 0 AND vSdoPos < pMonto THEN
            LET vMtoPaso = pMonto - vSdoPos;
        ELIF vSdoPos > 0 AND vSdoPos >= pMonto THEN
            LET vMtoPaso = 0;
        ELIF vSdoPos = 0 THEN
            LET vMtoPaso = pMonto;
        END IF

        IF vMtoPaso > 0 THEN
                SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
                  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
                  FROM "informix".sd_tpcomis
                 WHERE empresa = wEmpresa
                   AND cod_comis = v_codparam;

                IF v_faplica = 2 THEN
                        LET vMtoComDisp = vMtoPaso * (v_factor/100);
                END IF

                IF v_rangos = "1" THEN
                        IF vMtoComDisp < v_rmax THEN
                                LET vMtoComDisp = v_rmax;
                        END IF
                END IF
        END IF
   END IF

   -- *******************************************************
   -- Calcula Iva Global por Comision, solo para validacion *
   -- *******************************************************
		     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM	26/10/2010
   if (pSurcharge = 'V') then
      LET Iva = (pComCashMonto * TasaIva) ;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else
      LET Iva = (pComMonto + pComCashMonto) * TasaIva;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   end if;
   LET vMtoComDisp_iva = vMtoComDisp * TasaIva;     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   LET Iva = Iva +  vMtoComDisp_iva;                -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010

   -- ***************************************
   -- Valida Disponible vs Monto Movimiento *
   -- ***************************************
   IF Saldo < pMonto + pMonto2 + pComMonto +
	      pComCashMonto + vMtoComDisp + Iva THEN
     LET cod_ret = "005";
     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF

   -- *********************************************
   -- validacion de limites de operaciones        *
   -- *********************************************
--validacion de limites jom ini
    select usuario
      into vuser_limit
      from bdinteg:"informix".si_usuario_limites
     where usuario = pUsuario
       and empresa = wEmpresa;

       if ( vuser_limit is not null or vuser_limit <> '' ) then 
    -- // validación adicional para reconocimiento de canal 120612
        IF (vuser_limit = "intercar") then
            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa;
         ELSE
          SELECT id_canal 
          into vid_canal
             from bdinteg:si_canales
          where cc_canal = psucursal;
         
            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa
                and id_canal = vid_canal;
         END IF;         


            if (vid_transacc is not null or vid_transacc <> '') then
-- RQI 01 050 Ajuste envío de mensajes JOM INI
-- Se agrega el parametro de tarjeta
                execute procedure bdinteg:"informix".sp_limite_max(vnum_cliente, pNumCredito, vid_transacc, vid_canal, FechaHoy, pMonto,pTarjeta)
-- RQI 01 050 Ajuste envío de mensajes JOM FIN
                into vcodret, vmsje_limites, vid_autor;

                if (vcodret = '00035') then
                     LET cod_ret = "035";
                     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;

                end if;
            end if;
        end if;

--validacion de limites jom ini

   -- ***********************************
   -- Determina Total de la Transaccion *
   -- ***********************************
   LET MtoTot =pMonto + pMonto2 + pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET TotComision = pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET SaldoCom = Saldo - TotComision;

   -- *************************************************************************
   -- *         Afecta Movimiento(s) de Cargo y Comision Respectivamente      *
   -- *************************************************************************

   -- ******************************************************
   -- Afecta Movto(s) de Disposicion en Cajeros y/o Compra *
   -- ******************************************************
   LET vMtoFavor= pMonto - vMtoPaso;

   IF pDivisa <> v_mn THEN
    	LET v_mtofavor_dlls =  vMtoFavor / v_tipocambio;
    else
        LET v_mtofavor_dlls = 0;
    end if;

   IF vMtoFavor > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTranFavor, vMtoFavor, pFolio,
                         pTarjeta, v_mtofavor_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF;
   END IF;

   IF vMtoPaso > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTrans, vMtoPaso, pFolio,
                         pTarjeta, v_mto1_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;
        END IF;
   END IF;

   -- ***********************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion o COmpra *
   -- ***********************************************************
   IF pComMonto > 0 THEN

-- jon ini mod surcharge
        if (pSurcharge = 'V') then
            if (pComNumTrans = '0857') then     -- red
                LET pComNumTrans = '0890';
            elif (pComNumTrans = '0858') then -- convenio
                LET pComNumTrans = '0891';
            elif (pComNumTrans = '0859') then -- internacional
                LET pComNumTrans = '0892';
            end if;
        end if;
-- jon fin mod surcharge

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComNumTrans,pComMonto, pComFolio,
                                     pTarjeta, v_com1_dlls, v_tipocambio,
                                     FechaHoy, pComReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET cod_ret2 = cod_ret;
                    LET TotComision = 0;
                    LET Saldo = 0;
                    RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                           cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- ********************************************
   -- Afecta Movto(s) de Disposicion en Comercio *
   -- ********************************************
   IF pMonto2 > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario, pCashTranCen, pMonto2,pCashFolio,
                                     pTarjeta, v_mto2_dlls, v_tipocambio,
                                     FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF

   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion en Comercio *
   -- **************************************************************
   IF pComCashMonto > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComCashNumTrans, pComCashMonto,
				     pComCashFolio, pTarjeta, v_com2_dlls,
				     v_tipocambio, FechaHoy,
				     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
		LET cod_ret2 = cod_ret;
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion de Efectivo *
   -- **************************************************************
   IF vMtoComDisp > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,v_codparam, vMtoComDisp,
                                     pFolio, pTarjeta, v_com2_dlls,
                                     v_tipocambio, FechaHoy,
                                     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   LET Saldo = Saldo - MtoTot;

-- jom ini -- Se elimina el iva del total comision
   if (pSurcharge = 'V' or vEscajero = '1') then
      LET TotComision = vMtoComDisp + vMtoComDisp_iva;      -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else 
      LET TotComision = TotComision - Iva;
   end if;
-- jom fin

   RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
	  cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;


END PROCEDURE
DOCUMENT
'Esta Funcion Realiza el Cargo a una Tarjeta de Credito  ',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'MODIFICADO : Antonio Ruiz Martinez',
'FECHA : 05/06/2007',
'VERSION: 1.00.000',
'DESCRIPCION: se parametriza la asiganacion de transacciones a favor',
'MODIFICO : Jesus Manuel Aguilar Heredia',
'FECHA : 22/07/2011',
'VERSION: 2011.07.22',
'BD : bdicred ';

CREATE PROCEDURE "informix".sp_con_sc_movhis(  pFecha DATE )
RETURNING CHAR(5),integer,integer,integer,decimal(18,2),integer,decimal(18,2);
--,CODIGO DE ERROR SQL
--,NUMERO DE CONTRATOS ATM CAPTACION PERSONAS FISICAS
--,NUMERO DE CONTRATMOS ATM CAPTACION PERSONAS MORALES
--,NUMERO DE OPERACIONES ATM CAPTACION PERSONAS FISICAS
--,NUMERO DE OPERACIONES ATM CAPTACION PERSONAS FISICAS MONTO
--,NUMERO OPERACIONES CAPTACION PERSONAS MORALES,NUMERO OPERACIONES CAPTACION PERSONAS MORALES MONTO

	--Variables Exception
	DEFINE vcodret          CHAR(5);
	DEFINE vsqlerr,visamerr INTEGER; 


	DEFINE v_imes1								INTEGER;	
	DEFINE v_imes2								INTEGER;	
	DEFINE v_imes3								INTEGER;	
	DEFINE v_ivano1								INTEGER;
	
	DEFINE v_CON_ATMCAPF                        INTEGER;
	DEFINE v_CON_ATMCAPM						INTEGER;
	DEFINE v_OPE_ATMCAPF						INTEGER;
	DEFINE v_MONTO_TOT1							DECIMAL(18,2);	
	DEFINE v_OPE_ATMCAPM						INTEGER;
	DEFINE v_MONTO_TOT2							DECIMAL(18,2);

	--SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 3;
	
	LET v_imes1    	   = 0;		
	LET v_imes2		   = 0;	
	LET v_imes3        = MONTH(pFecha);		
	LET vcodret        = "000";
	LET v_CON_ATMCAPF  =0;
	LET v_CON_ATMCAPM  =0;
	LET v_OPE_ATMCAPF  =0;
	LET v_MONTO_TOT1   =0;	
	LET v_OPE_ATMCAPM  =0;
	LET v_MONTO_TOT2   =0;		
	
	BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
    IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,v_CON_ATMCAPF,v_CON_ATMCAPM,v_OPE_ATMCAPF,v_MONTO_TOT1,v_OPE_ATMCAPM ,v_MONTO_TOT2;	
    END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_con_sc_movhis.out";
	--TRACE ON;
	
	
	
	
		IF v_imes3 = 1 THEN 
		  LET v_ivano1 = YEAR(pFecha);	
		  LET v_ivano1 =  v_ivano1 -1; 
		  LET v_imes1 = 11;		
		  LET v_imes2 = 12;
		ELIF v_imes3 = 2 THEN
		  LET v_ivano1 = YEAR(pFecha);	
		  LET v_ivano1 =  v_ivano1 -1; 		                             
		 LET v_imes1 = 12;
         LET v_imes2 = 01;		  
		ELIF (v_imes3 != 1 AND v_imes3 != 2) THEN
	      LET v_ivano1 = YEAR(pFecha);	
		  LET v_imes1 = v_imes3 - 2;		
		  LET v_imes2 = v_imes3 -1 ;
		END IF;  
	
	
			--2.0 3.0 OBTIENE LOS CLIENTES TIPO MORALES Y SUS CUENTA EN CAPTACION
			SELECT NVL(cl.numcte,'') as numcte,NVL(cuenta,'') as cuenta,NVL(razon_social,0) as razon_social,NVL(rfc,0) as rfc
			  FROM bdinteg:si_cliente cl LEFT JOIN bdicheq:sc_maechq ma 
                ON ma.num_cte = cl.numcte                  
			 WHERE cl.empresa = '001'
			   AND tpo_persona = 2
			  INTO temp tmp_clienteCAPM
			  WITH NO LOG;	  
			
			--cliente fisicos.
			SELECT count(*) 
			  INTO v_CON_ATMCAPF	
			  FROM bdicheq:SC_maechq
			 WHERE  fec_ult_mov IS NOT NULL
			   AND cuenta IS NOT NULL
			   AND producto <> 1100
			   AND status_cta <> 2
			   AND status_cta <> 6
			   AND num_cte NOT IN (SELECT numcte FROM tmp_clienteCAPM WHERE cuenta <> '');	

			--clientes morales. 
		    SELECT count(*) 
			  INTO v_CON_ATMCAPM	
			  FROM bdicheq:SC_maechq
			 WHERE fec_ult_mov IS NOT NULL
			   AND cuenta IS NOT NULL
			   AND producto <> 1100
			   AND status_cta <> 2
			   AND status_cta <> 6			   
			   AND num_cte IN (SELECT numcte FROM tmp_clienteCAPM WHERE cuenta <> '');				 
			    
			SELECT  {bdicred:sc_movhis informix.idx_movhisnew3}
					cuenta,fech_alt,cancelad,transacc,usuario,folio_suc,monto_tot
			  FROM bdicheq:sc_movhis a
             WHERE  a.transacc IN ('0871','0873','0800','0893')	              		
			UNION 
			SELECT {bdicred:sc_movhis_old informix.idxmovhistranspba}
					cuenta,fech_alt,cancelad,transacc,usuario,folio_suc,monto_tot		 
			  FROM bdicheq:sc_movhis_old a
             WHERE  a.transacc IN ('0871','0873','0800','0893')	                     
			INTO TEMP tmp_sc_movhis_old
			WITH NO LOG;
			
		CREATE INDEX informix.idx01tmp_sc_movhis_old ON informix.tmp_sc_movhis_old(fech_alt,cuenta,cancelad,usuario,folio_suc);
	
	
		-- MOVMIENTOS ATM CAPTCION PERSONAS FISICAS
		SELECT count(*),SUM(monto_tot)
		  INTO v_OPE_ATMCAPF,v_MONTO_TOT1
		  FROM tmp_sc_movhis_old
		 WHERE fech_alt BETWEEN  MDY(v_imes1,'01',v_ivano1) AND  pFecha
		   AND cuenta NOT IN  (SELECT cuenta FROM tmp_clienteCAPM WHERE cuenta <> '')
		   AND cancelad <> 'S'
		   AND usuario in ('intercar','sysconau')   		
		   AND folio_suc like ('i%') ;   	
	
		-- MOVIMIENTOS ATM CAPTACION PERSONAS MORALES			 
  		SELECT count(*),SUM(monto_tot) 
		  INTO v_OPE_ATMCAPM,v_MONTO_TOT2
		  FROM tmp_sc_movhis_old
		 WHERE fech_alt    BETWEEN  MDY(v_imes1,'01',v_ivano1) AND  pFecha
		   AND cuenta      IN  (SELECT cuenta FROM tmp_clienteCAPM WHERE cuenta <> '')
		   AND cancelad    <> 'S'
		   AND usuario in ('intercar','sysconau')   		
		   AND folio_suc like ('i%') ;   

		RETURN vcodret,v_CON_ATMCAPF,v_CON_ATMCAPM,v_OPE_ATMCAPF,v_MONTO_TOT1,v_OPE_ATMCAPM ,v_MONTO_TOT2;	
		DROP TABLE tmp_clienteCAPM;
	END  
END PROCEDURE;