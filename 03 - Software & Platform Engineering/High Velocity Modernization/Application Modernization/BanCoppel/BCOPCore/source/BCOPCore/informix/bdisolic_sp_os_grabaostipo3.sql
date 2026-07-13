CREATE PROCEDURE "informix".sp_os_grabaostipo3(pempresa char(3), pNumSolicitud CHAR(20), pNumcte    CHAR(20), pTipo Char(1) )

RETURNING CHAR(5) 	as retorno,
          INTEGER   as secuencia;
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
DEFINE vnumsolPros			CHAR(20); 
DEFINE vStatusCred			CHAR(2);
DEFINE v_hoy                  DATE;
DEFINE vsecuenciaos			INTEGER;

DEFINE vFechaApertura		DATE; 
DEFINE vFUltimoPago			DATE;
DEFINE vfecharespuesta      DATE;


--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET scod_ret        = "00000";
LET vEnvioOS		= '';
LET vsqlerr			=0;

LET vnumsolPros			=''; 
LET vStatusCred			=''; 
LET vsecuenciaos         = 0;

LET vFechaApertura		= DATE(1); 
LET vFUltimoPago		= DATE(1);
LET vfecharespuesta     = DATE(1);

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,0;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_validageneraos.out";
--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************
    SELECT fecha_hoy
      INTO v_hoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;

	set isolation to dirty read;
	
	  select numcte_pros
	    into vnumsolPros
		from bdiprospectos:pr_cliente
	   where numcte = pNumcte;
	   
	  select secuencia, fecharespuesta
	    into vsecuenciaos, vfecharespuesta
	    from bdisolic:"informix".ss_osclientesupervisar
	   where empresa  = pEmpresa
		 and num_solicitud  = vnumsolPros;

      If pTipo <> 'C' then 
	     INSERT INTO "informix".ss_solicitud_os 
	                 (empresa,   num_solicitud, fecha_solicitud, status, usuario_solicita, observacion1, motivo_os, secuenciaos)
              VALUES (pEmpresa, pNumSolicitud, v_hoy, "S", "sistema", "OS Autorizada por OS Prospecto ", 13,vsecuenciaos);  
         execute procedure  "informix".sp_os_integracion(pNumSolicitud ,v_hoy) into scod_ret;
	     if scod_ret ='00000' then 
	       update bdisolic:ss_osclientesupervisar 
		      set clave = 'A', 
                  fecharespuesta = vfecharespuesta
		    where empresa = pEmpresa
		      and num_solicitud = pNumSolicitud;
	     end if;	
      end if;
END	
	return  scod_ret, vsecuenciaos;
END PROCEDURE;