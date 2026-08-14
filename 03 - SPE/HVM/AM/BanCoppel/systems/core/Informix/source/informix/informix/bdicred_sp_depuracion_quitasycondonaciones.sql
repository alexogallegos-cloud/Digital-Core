CREATE PROCEDURE "informix".sp_depuracion_quitasycondonaciones()
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE COD_RET      		CHAR(5);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vDia					CHAR(2);
DEFINE vMes					CHAR(2);
DEFINE vAnio				CHAR(4);
DEFINE vFechaHoy            DATE;
DEFINE vFechaAnt            DATE;
DEFINE vFechainsert         DATE;

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET COD_RET         		= "00000";
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vDia					= '';
LET vMes					= '';
LET vAnio				    = '';
LET v_empresa 		        = '001';
LET vFechaHoy               = DATE(1);
LET vFechaAnt               = DATE(1);
LET vFechainsert            = DATE(1);

BEGIN

		
	 SELECT fecha_hoy INTO vFechaHoy
	 FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
	 LET vFechaAnt = vFechaHoy - 1 units month; 
     --Depuracion de creditos con estatus MA
   FOREACH WITH HOLD
     --Buscar el credito en la tabla de bitacora  

        ---- Realiza consulta de creditos con estatus MA con mas de 1 mes de haberse insertado
        SELECT a.num_credito, a.fecha_insert
		  INTO vNumCredito,vFechainsert
	    FROM bdicred:sd_bitacora_quitacondonacion a
	    WHERE a.estatus_proceso = 'MA' AND a.fecha_insert < MDY(MONTH(vFechaAnt),DAY(vFechaAnt),YEAR(vFechaAnt)) 	
		  
		    BEGIN WORK;
		     UPDATE bdicred:"informix".sd_bitacora_quitacondonacion SET estatus_proceso = 'CN', fecha_status = today 
				WHERE num_credito = vNumCredito AND fecha_insert = MDY(MONTH(vFechainsert),DAY(vFechainsert),YEAR(vFechainsert));
		   COMMIT WORK;
	     
   END FOREACH
		
	
RETURN COD_RET,P_MENSAJE;
     
END
END PROCEDURE;