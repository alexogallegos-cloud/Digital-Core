CREATE PROCEDURE "informix".cons_sdoschq_bpi_pba(pEmpresa char(3),
                                       pCuenta char(20),
                                       pNumTarjeta char(16))
   returning char(5), money(14,2), money(14,2), money(14,2),
                     char(40), money(14,2), char(18);

   -- Modificó: Mauricio León
   -- Actividad: Se agrega instrucción SET ISOLATION
   -- Fecha:  22/06/2009
					 
-- Definición de variables
   define vCodRet             char(5);
   define vCuenta              char(20);
   define vSdoCta             money(14,2);
   define vSdoRet             money(14,2);
   define vSdoCong            money(14,2);
   define vSdoDisp            money(14,2);
   define vImpChqSbg         money(14,2);
   define vProducto            char(4);
   define vProdNom             char(35);
   define vDescripcion            char(40);
   define vCtaClabe           char(18);
   define sql_err              integer;

--- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = pcuenta;
    let vSdoDisp  = 0 ;
    let vSdoRet   = 0 ;
    let vSdoCta   = 0 ;
    let vDescripcion = "";
    let vSdoCong  = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;
      END IF ;
   END EXCEPTION ;

--SET DEBUG FILE TO "/tmp/cons_sdos1.out";
--TRACE ON;

--- Valida que la Cuenta  no sea Blanco
   IF (pCuenta = "00000000000" or pCuenta="") AND pNumTarjeta = "0000000000000000" THEN
      let vCodRet = "110";
       RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;
   END IF ;

   SET ISOLATION DIRTY READ ;

    IF TRIM(NVL(pCuenta,'')) = '' OR pCuenta IS NULL THEN
        SELECT cuenta INTO vCuenta FROM sc_tarjeta WHERE  empresa = pEmpresa and  num_tarjeta = pNumTarjeta;
    ELSE
        LET vCuenta = pCuenta;
    END IF

      SELECT cuenta, sdo_retenido, sdo_cong, sdo_actual,
                     mc.producto, pr.nombre, cuenta_clabe, imp_chq_sbg
      INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg
      FROM sc_maechq mc,sc_producto pr
      WHERE mc.empresa = pEmpresa AND cuenta = pCuenta
            AND pr.empresa = mc.empresa AND pr.producto = mc.producto;

      IF vCuenta IS NULL THEN
         let vCodRet = "100";
         RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;
      END IF ;

--- Calcula Saldo Disponible
    let vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg;

    { IF vSdoDisp < 0 THEN
        let vSdoDisp = 0;
    END IF }

--- Regresa Variables de Salida
    let vDescripcion = vProducto || " " || vProdNom;
    RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;

END
END PROCEDURE ;