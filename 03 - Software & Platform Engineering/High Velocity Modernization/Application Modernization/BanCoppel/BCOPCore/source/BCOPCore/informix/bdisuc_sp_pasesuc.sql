CREATE  PROCEDURE "informix".sp_pasesuc(pempresa char(3),
                          psucursal  CHAR(4),
                          pusuario   char(8),
                          pfuncion   char(1),
                          pfecha   date)
   RETURNING CHAR(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE vexiste SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "000";
   LET vexiste = 0;

-- set debug file to "/home/c91986087/sp_pasesuc.out";
-- trace on;

   IF psucursal IS NULL OR psucursal  = "" THEN
      LET cod_ret = "110";
      RETURN cod_ret;
   END IF

-- ***************************************************************************
-- Inicia Proceso de Pase Contable sin Movimientos
-- ***************************************************************************
   SELECT 1 into vexiste
   FROM   ss_pase_sucursal
   WHERE  sucursal = psucursal
   AND    fecha_pase = pfecha;
   IF vexiste is null or vexiste = 0 then
      IF pfuncion = "A" THEN
         INSERT INTO ss_pase_sucursal(sucursal,suc_abrio,suc_cerro,
                     fecha_pase,usuario)
         VALUES (psucursal,'1','0',pfecha,pusuario);
      END IF
   ELSE
      IF pfuncion = "C" THEN
         UPDATE ss_pase_sucursal SET suc_cerro = '1'
         WHERE  sucursal = psucursal
         AND    fecha_pase = pfecha;
      END IF
   END IF

   RETURN cod_ret;

END PROCEDURE;