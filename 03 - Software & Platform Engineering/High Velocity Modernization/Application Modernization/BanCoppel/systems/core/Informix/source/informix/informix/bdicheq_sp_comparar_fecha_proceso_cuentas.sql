CREATE PROCEDURE "informix".sp_comparar_fecha_proceso_cuentas(pNumEmpresa  CHAR(3),
															 pCuentaOrigen VARCHAR(11),
															 pCuentaDestino VARCHAR(11))
RETURNING
    CHAR(5),         
    CHAR(1); 

--Creado por: Javier Calderon
--Actividad:  Comparar fecha proceso entre cuentas origen y destino
--Solicito:   Mauricio Leon
--Fecha:      18/02/2010
--Modificado: Berenice Noriega 
--Actividad:  Sentencia SET LOCK MODE TO WAIT 10;
--Fecha: 	  31/12/2012

DEFINE vCodRet          CHAR(5);
DEFINE vValorRet     CHAR(1);
DEFINE iSqlErr			INTEGER;
DEFINE vFechaProcesoOr  DATE;
DEFINE vFechaProcesoDe  DATE;
LET vCodRet = '000';
LET vValorRet = '0';
  
SET LOCK MODE TO WAIT 20;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vValorRet;
        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	
	SELECT fecha_proceso INTO vFechaProcesoOr FROM sc_maechq WHERE empresa = pNumEmpresa AND cuenta = pCuentaOrigen;
	SELECT fecha_proceso INTO vFechaProcesoDe FROM sc_maechq WHERE empresa = pNumEmpresa AND cuenta = pCuentaDestino;
	
	IF (vFechaProcesoOr <> vFechaProcesoDe) THEN
		LET vValorRet = '1';
	END IF;
	
	RETURN vCodRet, vValorRet;
END
END PROCEDURE;