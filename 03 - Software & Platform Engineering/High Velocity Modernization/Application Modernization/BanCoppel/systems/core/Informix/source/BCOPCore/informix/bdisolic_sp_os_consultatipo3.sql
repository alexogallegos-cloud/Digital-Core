CREATE PROCEDURE "informix".sp_os_consultatipo3(pempresa char(3), pNumcte    CHAR(20), pNumProducto char(4), pTipo char(1) )

RETURNING CHAR(5) 	as retorno,		  
		   CHAR(1)  as status, -- A Autorizada, R Rechazada, D Sin Efecto, Sin respuesta 
		   CHAR(1)  as vigente; -- 1 Vigente, 0 Vencida
--- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
-- Fecha Creación:  Julio 2013
-- Autor: FMJ 
-- Descripcion: Valida si para una solicitud o Cliente se pueden enviar o no OS.
--****************************************************************************
--*                        DEFINICION DE VARIABLES
--****************************************************************************
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
DEFINE vvigrespos_oferta	CHAR(1); 
DEFINE vvigencia_os			CHAR(1);

DEFINE vFechaApertura		DATE; 
DEFINE vFUltimoPago			DATE;
DEFINE vClave				CHAR(1);
DEFINE vVigencia			CHAR(1);
DEFINE vdias_vigencia		SMALLINT;
DEFINE vfechasol			DATE; 
DEFINE vfechares				DATE;
DEFINE vFechaCompara		DATE;

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

LET vvigrespos_oferta	= '';
LET vvigencia_os		= '';
LET vClave 				= '';
LET vVigencia			= '';
LET vdias_vigencia		= 0;
LET vfechasol			= DATE(1);
LET vfechares			= DATE(1);
LET vFechaCompara		= DATE(1);
--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, vClave,vVigencia ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


--SET DEBUG FILE TO "sp_validageneraos.out";
--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************
    SELECT fecha_hoy
      INTO v_hoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;
	
	
	  select numcte_pros
	    into vnumsolPros
		from bdiprospectos:pr_cliente
	   where numcte = pNumcte;
	   
	  select MAX (secuencia), clave, fechasolicitud,fecharespuesta
	    into vsecuenciaos, vClave, vfechasol, vfechares
	    from bdisolic:"informix".ss_osclientesupervisar
	   where empresa  = pEmpresa
		 and num_solicitud  = vnumsolPros
	   GROUP BY clave,fechasolicitud,fecharespuesta;
		 				 
		 
	  select  vigrespos_oferta,  vigencia_os  
	    into  vvigrespos_oferta, vvigencia_os
	   from bdisolic:ss_oscalle_vigencia 
	   where clave_producto = pNumProducto;
	   
	   select  dias_vigencia 
	     into  vdias_vigencia
		from bdisolic:ss_oscalle_plazovigencia
	   where clave_producto = pNumProducto
         and resp_oscalle = vClave ;

       IF (vfechares = DATE(1)) THEN
	     let vFechaCompara =vfechasol;		 
	   ELSE
	     let vFechaCompara =vfechares;	
	   END IF;
	   
	   --- (vfecharespuesta) = date(1)	 
	  if  (v_hoy > vFechaCompara + vdias_vigencia units day) then 
	    let vVigencia = 0;
	  else let vVigencia = 1;	
	  end if;
	  
	  if pTipo = 1 then 	    
	    if vvigrespos_oferta = 0 then
		  let vVigencia   =0;
		end if;
	  ---else 	
	    --if vvigencia_os = 1 then
		  --let vVigencia   =1;
		--end if;
	  end if;	

END	
	return  scod_ret, vClave, vVigencia;
END PROCEDURE
