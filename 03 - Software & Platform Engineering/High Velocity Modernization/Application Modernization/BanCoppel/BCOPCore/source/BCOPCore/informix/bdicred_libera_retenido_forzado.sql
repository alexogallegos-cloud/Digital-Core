CREATE PROCEDURE "informix".libera_retenido_forzado()
RETURNING CHAR(5);       -- Codigo de Retorno

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE vFOlio	CHAR(16);
   DEFINE vFecha	DATE;
   DEFINE vDiasRet	SMALLINT;
   DEFINE vMonto	DECIMAL(14,2);
   DEFINE vMontoLib     DECIMAL(14,2);
   DEFINE vDIas		SMALLINT;
   DEFINE vNumCredito char(20);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      ROLLBACK WORK;
      RETURN CodRet;
   END EXCEPTION

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet    = '000';
   LET vFolio    = "??????";
   LET vFecha    = " ";
   LET vDiasRet  = 0;
   LET vMonto    = 0;
   LET vMontoLib = 0;
   LET vDias     = 0;
   LEt vNumCredito = '';

 -- **************************************************************************
 -- *                      PROGRAMA PRINCIPAL                                *
 -- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/informix/miguel/libera_retenido_forzado.out";
	--TRACE ON;
	
	FOREACH WITH HOLD
        SELECT a.folio_suc, a.fecha_hora, a.num_credito, a.monto
          into vFolio, vFecha, vNumCredito, vMontoLib
		  FROM bdicred:sd_retenidolibera a,
               bdicred:sd_maeretenido b
		 WHERE empresa = '001'
		   AND estatus in ("P","S")
           AND a.num_credito = b.num_credito
           AND a.folio_suc = b.folio_suc
       
		SELECT sdo_retenido INTO vMonto FROM bdicred:sd_maesdos WHERE num_credito = vNumCredito;
		
		IF vMontoLib<= vMonto THEN
           begin work;

                UPDATE bdicred:sd_maeretenido
                   SET estatus = "S"
                 WHERE empresa = '001'
                   AND num_credito = vNumCredito
                   AND folio_suc = vFolio
                   AND fecha = vFecha;
				
                UPDATE sd_maesdos 
					SET sdo_retenido  = sdo_retenido - vMontoLib 
				WHERE num_credito = vNumCredito;

            commit work;
		END IF;

	END FOREACH


	RETURN CodRet;

END PROCEDURE;