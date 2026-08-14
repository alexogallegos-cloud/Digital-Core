CREATE PROCEDURE  "informix".sp_valfcfs_web_pbatrace(pusuario         char(4),
                                  pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             SMALLINT;

   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE vexiste           SMALLINT; 

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret           = "00000";
   LET vfecha_central    = "";

      SET DEBUG FILE TO "/DBA/INC/20240518/RESPALDO/bdisuc.sp_valfcfs_web.240518_trace.out";
      TRACE ON;


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF;
   END EXCEPTION;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "00110";
         RETURN cod_ret,vfecha_central,vexiste;
      END IF
      
-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   
   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdicont:co_fechas;
   
   IF EXISTS(SELECT usuario FROM bdicont:co_poldet_20240518 WHERE usuario = pusuario AND  
                     fecha_captura = pfecha_sucursal AND fecha_valida = vfecha_central) THEN
      LET vexiste = 0;
   ELSE
      LET vexiste = 1;
   END IF;
  

   IF not vfecha_central > pfecha_sucursal THEN
      --RETURN cod_ret,vfecha_central,vexiste;
   --ELSE
      LET vfecha_central = pfecha_sucursal;
   END IF;
    
    RETURN cod_ret,vfecha_central,vexiste;
END
END PROCEDURE;