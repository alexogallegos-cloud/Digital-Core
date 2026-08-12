CREATE PROCEDURE "informix".sp_ce_obtendescripcionerror (pCodigo CHAR(5), pTipo CHAR(10))

RETURNING CHAR(5) 	as retorno,
          CHAR(50) 	as descripcion;
		  
--- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
-- Fecha Creación:  Julio 2013
-- Autor: FMJ
-- Descripcion: Valida si para una solicitud o Cliente se pueden enviar o no OS.

--****************************************************************************
--*                        DEFINICION DE VARIABLES
--****************************************************************************

DEFINE vsqlerr				INTEGER;
DEFINE scod_ret             CHAR(5);
DEFINE vEnvioOS				CHAR(1);
DEFINE vlDescripcion		CHAR(50);
DEFINE vStatusCred			CHAR(2);
DEFINE v_hoy                DATE;
DEFINE vsecuenciaos			INTEGER;

DEFINE vFechaApertura		DATE;
DEFINE vFUltimoPago			DATE;
DEFINE vlNumCte				CHAR(10);
DEFINE cCodRet				CHAR(5);
DEFINE vvcCod_ret			CHAR(5);

--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET cCodRet        		= "00000";
LET vEnvioOS			= '';
LET vsqlerr				= 0;

LET vldescripcion		= '';
LET vStatusCred			= '';
LET vsecuenciaos        = 0;
LET vlNumCte			= '';

LET vFechaApertura		= DATE(1);
LET vFUltimoPago		= DATE(1);
LET vvcCod_ret			= '';
LET vlDescripcion 		= '';

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,'';
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_obtienedescripcionerror.out";
-- TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************

	set isolation to dirty read;

	select descripcion into vlDescripcion
      from bdicred:sd_param_campania
     where empresa = '001'
      and tipo_campania = 21
      and grupo_parametro =pTipo
      and valor_alfabetico = pCodigo;

    if nvl(vlDescripcion,'') ='' then
      select descripcion into vlDescripcion from bdinteg:si_codret
      where codigo_retorno =pCodigo::integer  and sistema =7;
    end if;
END
	return  cCodRet, vlDescripcion;
END PROCEDURE;