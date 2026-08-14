CREATE  PROCEDURE "informix".sp_valida_pasecont(psucursal  CHAR(4), pfecha   date)

RETURNING CHAR(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE vexiste SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "00000";
   LET vexiste = 0;

-- set debug file to "sp_valida_pasecont.out";
-- trace on;

   IF psucursal IS NULL OR psucursal  = "" THEN
      LET cod_ret = "00001";
      RETURN cod_ret;
   END IF

   SELECT 1 into vexiste
    FROM ss_pase_sucursal
    WHERE sucursal = psucursal
    AND suc_abrio = 1  
    AND suc_cerro = 1
    AND fecha_pase = pfecha;
   IF vexiste is null or vexiste = 0 then
        LET cod_ret ='00001';
        RETURN cod_ret;
   ELSE
      RETURN cod_ret;
   END IF

END PROCEDURE;