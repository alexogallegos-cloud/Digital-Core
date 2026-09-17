CREATE PROCEDURE "informix".sp_ctasdos_cte_bei(pempresa CHAR(3),pnum_cte CHAR(20),pRegistros SMALLINT)

   returning char(5), char(20),char(2),char(4), char(40), date,
                money(14,2), money(14,2), money(14,2),money(14,2),char(18),char(2);

    --****************************************************************************************************
    -- DESCRIPCION:          OBTIENE LOS DATOS DE LAS CUENTAS PARA LA BANCA EMPRESARIAL
    -- AUTOR:                Francisco Rodriguez Ibarra
    -- FECHA:                26/08/2011
    -- BD:                   bdicheq
    -- SOLICITO:             Mauricio Leon
    -- MODIFICADO:            Donovan F. Torres Landeros,
    -- ULTIMA MODIFICACION:   2025/06/04,
    -- RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro),
    --                       a la operacion aritmetica para el nuevo calculo de,
    --                       saldo disponible.,
    --PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion,
    --BD:                    bdicheq,
    --VER:                   1.2;
--***************************************************************************************************

-- Definicion de variables
   define vCodRet             char(5);
   define vCuenta              char(20);
   define vSdoCta             money(14,2);
   define vSdoRet             money(14,2);
   define vSdoCong            money(14,2);
   define vSdoDisp            money(14,2);
   define vImpChqSbg         money(14,2);
   define vProducto            char(4);
   define vProdNom             char(40);
   define vEjeClabeTDC           char(18);
   define sql_err              integer;
   define iCont		integer;
    DEFINE v_fecha_venc date;
    define v_plazo smallint;
    define v_fechoy date;
    define vStatusCta char(2);
    define vStatusTarj char(2);
    define vInteres money(14,2);
   --RQM 09 704. Se agrega la siguiente variable DFTL
   DEFINE mSaldo_SBC          money(14,2);


--- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = "";
    let vSdoDisp  = 0 ;
    let vSdoRet   = 0 ;
    let vSdoCta   = 0 ;
    let vSdoCong  = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vEjeClabeTDC = "";
    let vImpChqSbg = 0;
    let iCont =0;
    LET v_fecha_venc  = "01-01-1900";
    LET v_fechoy  = "01-01-1900";
    let v_plazo = 0;
    let vStatusCta = "";
    let vStatusTarj = "";
    let vInteres = 0;
    --RQM 09 704. Se agrega la siguiente variable DFTL    
    LET mSaldo_SBC   = 0;



BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet, vCuenta, vStatusCta,vProducto,vProdNom, v_fecha_venc, vSdoDisp, vSdoRet, vSdoCta, vSdoCong, vEjeClabeTDC,vStatusTarj;
      END IF ;
   END EXCEPTION ;

    --SET DEBUG FILE TO "/home/c90402536/Traza/sp_ctasdos_cte_bei_modif.out";
    --TRACE ON; 


--- Valida que el cliente no sea Blanco
   IF pnum_cte = "000000000" THEN
      let vCodRet = "110";
       RETURN vCodRet, vCuenta, vStatusCta,vProducto,vProdNom, v_fecha_venc, vSdoDisp, vSdoRet, vSdoCta, vSdoCong, vEjeClabeTDC,vStatusTarj;
   END IF ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

---Consulta cuentas efectivas
    FOREACH
            --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
            SELECT  SKIP pRegistros FIRST 10  mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual, mc.saldo_sbc,
                mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta
                INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, mSaldo_SBC, vProducto, vProdNom, vEjeClabeTDC, vImpChqSbg, vStatusCta
                FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
                WHERE mc.num_cte = pnum_cte
                AND mc.status_cta not in (2,5)
                AND pr.empresa = mc.empresa
                AND pr.producto = mc.producto
                ORDER BY mc.cuenta
			
            --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
            LET vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldo_SBC;

            { IF vSdoDisp < 0 THEN
                let vSdoDisp = 0;
            END IF }
            LET iCont = iCont + 1;
            RETURN vCodRet, vCuenta, vStatusCta,vProducto,vProdNom, v_fecha_venc, vSdoDisp, vSdoRet, vSdoCta, vSdoCong, vEjeClabeTDC,vStatusTarj WITH RESUME;
	END FOREACH;

	IF ( iCont = 0 ) THEN
		LET vCodRet = '101'; --Cliente No tiene cuentas de cheques
		RETURN vCodRet, vCuenta, vStatusCta,vProducto,vProdNom, v_fecha_venc, vSdoDisp, vSdoRet, vSdoCta, vSdoCong, vEjeClabeTDC,vStatusTarj;
	END IF

END
END PROCEDURE ;