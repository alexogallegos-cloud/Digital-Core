CREATE PROCEDURE "informix".sp_validageneraos(pempresa char(3), pNumcte    CHAR(20), pNumSolicitud CHAR(20), pFecha Date)

RETURNING CHAR(5) 	as retorno,		  
		   CHAR(1)  as enviaOS;
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
DEFINE vnumcredito			CHAR(20); 
DEFINE vStatusCred			CHAR(2);

DEFINE vFechaApertura		DATE; 
DEFINE vFUltimoPago			DATE;


--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET scod_ret        = "00000";
LET vEnvioOS		= '';
LET vsqlerr			=0;

LET vnumcredito			=''; 
LET vStatusCred			=''; 

LET vFechaApertura		= DATE(1); 
LET vFUltimoPago		= DATE(1);

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, vEnvioOS;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_validageneraos.out";
--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************
	set isolation to dirty read;
	foreach 
	  select num_credito, fecha_apertura, status_cred 
	    into vnumcredito, vFechaApertura, vStatusCred
		from bdicred:"informix".sd_maecred
	   where empresa = pEmpresa
	     and numcte = pNumcte
		 
	  select  fecha_ultimo_pago into vFUltimoPago
	    from bdicred:"informix".sd_indicador_cred
	   where empresa  = pEmpresa
		 and num_credito = vnumcredito;
	  
	  if  nvl(vFUltimoPago,date(1)) >= pFecha - 12 units month then
	    let vEnvioOS = 'F';
	  elif nvl(vFUltimoPago,date(1)) = Date(1)	then
	    if vFechaApertura < pFecha - 12 units month then
		  let vEnvioOS = 'V';
		end if;
	  end if;
	end foreach; 
    
	foreach 
	  select num_credito  
	    into vnumcredito
		from bdicred:"informix".sd_maecredcrd
	   where empresa = pEmpresa
	     and numcte = pNumcte
		 
	  select  fecha_ultimo_pago into vFUltimoPago
	    from bdicred:"informix".sd_indicador_cred_crd
	   where empresa  = pEmpresa
		 and num_credito = vnumcredito;
	  
	  if  vFUltimoPago >= pFecha - 12 units month then
	    let vEnvioOS = 'F';
	  end if;
	  
	end foreach
END	
	return  scod_ret, vEnvioOS;
END PROCEDURE;