CREATE PROCEDURE  "informix".sp_valfcfs(pusuario         char(4),
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
   LET cod_ret           = "000";
   LET vfecha_central    = "";
   LET vexiste 		       = 0;
   
BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
		     LET vexiste = 2;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   --SET LOCK MODE TO WAIT 3;  

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "110";
		     LET vexiste = 2;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF
      
-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   
   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdicont:co_fechas;
   
   IF EXISTS(SELECT usuario FROM bdicont:co_poldet WHERE usuario = pusuario AND  
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