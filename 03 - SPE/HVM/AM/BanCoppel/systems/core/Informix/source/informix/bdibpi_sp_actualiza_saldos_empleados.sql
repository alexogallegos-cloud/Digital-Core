CREATE PROCEDURE "informix".sp_actualiza_saldos_empleados(pIdEmpresa CHAR(3),pCadena char(560))
RETURNING   CHAR(5); ---cod_ret


--****************************************************************************************************
-- DESCRIPCION:  Actualiza el monto de los empleados en la tabla bpi_empleadospm
-- AUTOR : Francisco Rodríguez Ibarra
-- FECHA : 22/11/2011
-- BD: bibpi
-- SOLICITO :Mauricio León
--***************************************************************************************************
-- DESCRIPCION: Se castea el monto a money(16,2)
-- AUTOR : ING. ALFONSO CRUZ
-- FECHA : 09/05/2012
-- BD: bibpi
-- SOLICITO :Mauricio León
--***************************************************************************************************
/*  DEFINICION DE VARIABLES */
DEFINE vCodRet   CHAR(5);
DEFINE cSqlerr INTEGER;
DEFINE vCantEmp  INTEGER;
DEFINE vCadAux CHAR(28);
DEFINE vPosCadena INTEGER;
DEFINE vNumEmp CHAR(10);
DEFINE vSaldo  CHAR(18);
DEFINE vSaldoConv CHAR(20);

/* INICIALIZACION DE VARIABLES */
LET vPosCadena=1;
LET vCodRet="00000";

--SET debug FILE TO "/home/informix/ivonne/sp_actualiza_saldos_empleados.out";
--SET debug FILE TO "/home/sysifx/soporte/empresanet/sp_actualiza_saldos_empleados.out";
--Trace ON;


SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
                LET vCodRet = cSqlerr;
        END IF;
        RETURN vCodRet;
    END EXCEPTION;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
	LET vCantEmp=LENGTH (TRIM(pCadena))/28;
	WHILE (vCantEmp > 0)
		LET vCadAux=SUBSTR(pCadena,vPosCadena,28);
		LET vNumEmp=SUBSTR(vCadAux,1,10);
		LET vSaldo=SUBSTR(vCadAux,11,18);
		LET vSaldoConv=  SUBSTR(vSaldo,1,16)||"."||SUBSTR(vSaldo,17,18);
		UPDATE bdibpi:"informix".bpi_empleadospm SET monto=CAST(vSaldoConv AS MONEY(16,2)) WHERE num_empleado=vNumEmp AND id_empresa=pIdEmpresa;
		LET vPosCadena=vPosCadena+28;
		LET vCantEmp=vCantEmp-1;
	END WHILE;

	RETURN vCodRet;
END;
END PROCEDURE;