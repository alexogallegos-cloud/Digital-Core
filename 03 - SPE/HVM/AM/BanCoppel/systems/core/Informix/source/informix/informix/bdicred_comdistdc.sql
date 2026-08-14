create procedure "informix".comdistdc 
	 (pEmpresa    CHAR(3),
	 pSucursal   CHAR(4),
     	 pMonto      MONEY(16,2),
		 pProducto	CHAR(4))

    RETURNING CHAR(5),       -- Codigo de Retorno
              MONEY(16,2),   -- Importe comiison
              MONEY(16,2);   -- Importe iva de comision

-- Elaborado : Juan Olivares
-- 26/Nov/2009
-- Devuelve el importe de la comision y el iva correspondiente 
-- por concepto de retiro de efectivo

   DEFINE TasaIva               DECIMAL(5,3);
   DEFINE viva                  DECIMAL(14,2);
   DEFINE v_codparam            CHAR(4);   
   DEFINE v_factor              DECIMAL(9,6);
   DEFINE vMtoComDisp           DECIMAL(14,2);
   DEFINE cod_ret               CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, 0, 0;
   END EXCEPTION;

   SET ISOLATION TO dirty READ;

--   SET DEBUG FILE TO "comdistdc.out";
--   TRACE ON;

   LET cod_ret               = '00000';
   LET sql_err               = 0;
   LET isam_err              = 0;
   LET error_info            = '';
   LET TasaIva               = 0;
   LET viva                  = 0;
   LET v_codparam            = '';
   LET v_factor              = 0;
   LET vMtoComDisp           = 0;

    SELECT iva 
      INTO TasaIva
      FROM bdinteg:si_sucursales
     WHERE empresa = pEmpresa
       AND sucursal = pSucursal;

     IF (TasaIva is null or TasaIva = 0) THEN	
        LET cod_ret = "008";
        RETURN cod_ret,0,0;
     END IF;

	 --AAME RQI 27 000 14062017 Se Cambia la forma de obtener el codigo del parametro de la comision por disposición por producto
    /*SELECT valor 
      INTO v_codparam
      FROM bdicred:sd_param
     WHERE empresa = pEmpresa
       AND cod_param = "334";*/
	   
   SELECT cod_comision_efectivo 
	INTO v_codparam
	FROM "informix".sd_definicion 
	WHERE num_producto = pProducto;

    SELECT apli_factor
      INTO v_factor
      FROM "informix".sd_tpcomis
     WHERE empresa = pEmpresa
       AND cod_comis = v_codparam;
      	
   LET vMtoComDisp = pmonto * (v_factor/100);
        
   LET viva = vMtoComDisp * TasaIva;

   RETURN cod_ret, vMtoComDisp, viva;

END PROCEDURE;