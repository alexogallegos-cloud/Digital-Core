CREATE PROCEDURE "informix".sp_obtener_udi(pEmpresa CHAR(3), pFecha DATE)
RETURNING CHAR(5), DECIMAL(14,6), DATE;

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vValor1	      DECIMAL(14,6);
   DEFINE vValor2      	      DECIMAL(14,6);
   DEFINE vPrecio	      DECIMAL(14,6);
   DEFINE vFechaPaso	      DATE;
   DEFINE vDivUdi	      CHAR(2);
   DEFINE vClaseUdi	      CHAR(1);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio,pFecha;
   END EXCEPTION;

-- SET DEBUG FILE TO "determina_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vValor1	  = 0;
   LET vValor2	  = 0;
   LET vPrecio	  = 0;
   LET vFechaPaso = "";
   LET vClaseUdi = "0";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
      SELECT TRIM(valor) INTO vDivUdi
	FROM bdinteg:si_param
       WHERE empresa = pEmpresa
	 AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClaseUdi
	  FROM bdicred:sd_param
      WHERE empresa = pEmpresa
	  AND cod_param = "336";

      -- **************
      -- Precio Inicio*
      -- **************
     
      SELECT precio_compra INTO vPrecio
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = vDivUdi
       	 AND fecha_tpcambio = pFecha
         AND clase_tpcambio = vClaseUdi;

	IF vPrecio IS NULL THEN
           
            SELECT MAX(fecha_tpcambio) INTO vFechaPaso
            FROM bdinteg:si_tpcambio;
            --LET vFechaPaso = YEAR(vFechaPaso) || "-" || MONTH(vFechaPaso) || "-" || DAY(vFechaPaso);

            SELECT precio_compra INTO vPrecio
            FROM bdinteg:si_tpcambio
            WHERE empresa = pEmpresa
              AND divisa = vDivUdi
              AND fecha_tpcambio = vFechaPaso
              AND clase_tpcambio = vClaseUdi;

	END IF

    IF vPrecio IS NULL THEN

      SELECT MAX(fecha_tc) INTO vFechaPaso
      FROM bdinteg:si_histdiv;
      --LET vFechaPaso = YEAR(vFechaPaso) || "-" || MONTH(vFechaPaso) || "-" || DAY(vFechaPaso);

       SELECT precio_compra INTO vPrecio
       FROM bdinteg:si_histdiv
       WHERE empresa = pEmpresa
       AND divisa = vDivUdi
       AND fecha_tc = vFechaPaso
       AND clase_tpcambio = vClaseUdi;

       IF vPrecio IS NULL THEN
		  LET cod_ret = "901";
		  RETURN cod_ret, vPrecio, vFechaPaso;
	   END IF
    END IF

END
RETURN cod_ret, vPrecio, vFechaPaso;

END PROCEDURE
;