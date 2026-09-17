CREATE  PROCEDURE "informix".sp_usuarios(psucursal  CHAR(4),
                          pejecutivo   CHAR(8),
                          pregistro    smallint)
   RETURNING CHAR(5),CHAR(8),CHAR(50),CHAR(20),DATE;

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE vejecutivo CHAR(8);
   DEFINE vnombre CHAR(50);
   DEFINE vpuesto CHAR(20);
   DEFINE vfecha_venc DATE;
   DEFINE vcont  SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "000";
   LET vcont  = 0;
   LET vnombre = "";
   LET vpuesto = "";
   LET vfecha_venc = "";

-- set debug file to "sp_usuarios.out";
-- trace on;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

   IF psucursal IS NULL OR psucursal  = "" THEN
      LET cod_ret = "110";
      RETURN cod_ret,vejecutivo,vnombre,vpuesto,vfecha_venc;
   END IF

-- ***************************************************************************
-- Inicia busqueda de cuenta del maestro contable
-- ***************************************************************************

   FOREACH
      SELECT ejecutivo,nombre,nombramiento,vigencia
      INTO   vejecutivo,vnombre,vpuesto,vfecha_venc
      FROM   si_ejecut
      WHERE  sucursal = psucursal
      if vcont < pregistro then
         LET vcont = vcont + 1;
         continue foreach;
      end if
      LET vcont = vcont + 1;
      RETURN cod_ret,vejecutivo,vnombre,vpuesto,vfecha_venc with resume;
   END FOREACH;

END PROCEDURE;