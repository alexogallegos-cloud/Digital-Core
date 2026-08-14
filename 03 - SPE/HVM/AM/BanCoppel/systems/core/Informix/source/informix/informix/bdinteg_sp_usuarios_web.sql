CREATE  PROCEDURE "informix".sp_usuarios_web(psucursal  CHAR(4),
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
   LET cod_ret = "00000";
   LET vcont  = 0;
   LET vnombre = "";
   LET vpuesto = "";
   LET vfecha_venc = "";

-- set debug file to "sp_usuarios.out";
-- trace on;

   IF psucursal IS NULL OR psucursal  = "" THEN
      LET cod_ret = "00110";
      RETURN cod_ret,vejecutivo,vnombre,vpuesto,vfecha_venc;
   END IF

-- ***************************************************************************
-- Inicia busqueda de cuenta del maestro contable
-- ***************************************************************************
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	
   FOREACH
      SELECT ejecutivo,nombre,nombramiento,vigencia
      INTO   vejecutivo,vnombre,vpuesto,vfecha_venc
      FROM   si_ejecut
      WHERE  sucursal = psucursal
      IF vcont < pregistro THEN
         LET vcont = vcont + 1;
         CONTINUE foreach;
      END IF
      LET vcont = vcont + 1;
      RETURN cod_ret,vejecutivo,vnombre,vpuesto,vfecha_venc with resume;
   END FOREACH;

END PROCEDURE;