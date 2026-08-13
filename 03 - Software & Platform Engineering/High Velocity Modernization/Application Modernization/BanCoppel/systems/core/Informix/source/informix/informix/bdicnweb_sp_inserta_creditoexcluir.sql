CREATE PROCEDURE "informix".sp_inserta_creditoexcluir( pCuenta CHAR(20))

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

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "sp_inserta_creditoexcluir.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
    	
 SELECT id_registro, status
	INTO vRegistro, vStatusSol
	FROM bdicnweb:"informix".sw_evc_excluidos
	WHERE  cuenta = pCuenta
	AND id_registro = (select max(id_registro) from bdicnweb:"informix".sw_evc_excluidos where cuenta = pCuenta);

	IF (SELECT COUNT(*) FROM bdicnweb:"informix".sw_evc_excluidos WHERE cuenta = pCuenta) > 1 THEN

         IF vStatusSol <> 'P' THEN
						
			delete from sw_evc_excluidos where cuenta = pCuenta
			and id_registro < vRegistro;
			
         END IF;
	END IF;
END PROCEDURE;