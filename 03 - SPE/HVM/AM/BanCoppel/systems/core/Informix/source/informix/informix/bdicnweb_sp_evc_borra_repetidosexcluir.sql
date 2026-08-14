CREATE PROCEDURE "informix".sp_evc_borra_repetidosexcluir(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))

RETURNING CHAR(5) AS codret;
-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);
DEFINE iSqlErr INT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "00000";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";
LET iSqlErr = 0;

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

	IF trim(cCodRet) <> "00000" THEN
		RETURN trim(cCodRet);
	END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

----SET DEBUG FILE TO "/informix/marcov/sp_evc_borra_repetidosexcluir.out";
----TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	IF (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} 
		COUNT(*)
		from bdicnweb:"informix".sw_evc_excluidos
		where id_registro 
		not in (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)}  max(id_registro)
						from bdicnweb:"informix".sw_evc_excluidos group by cuenta) 
		and status <> 'P')
		>= 1 THEN

		DELETE {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)}
		FROM bdicnweb:"informix".sw_evc_excluidos
		WHERE id_registro
		NOT IN(SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)} MAX(id_registro)
						FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta)
		AND status <> 'P';
	END IF;
 
RETURN trim(cCodRet);
END;
 
END PROCEDURE;