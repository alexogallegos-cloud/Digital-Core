CREATE PROCEDURE "informix".sp_ce_registra_mensaje(	pEmpleado 	  	CHAR(8) ,
													pTipoMensaje  	CHAR(10),
													pIdMensaje    	CHAR(30),
													pStr1 			CHAR(30), --pUsuario,  ---pTipoMensaje  Codigo de error
                                                    pStr2 			CHAR(30),  
                                                    pStr3 			CHAR(30),  
                                                    pStr4 			CHAR (30), 
                                                    pStr5 			CHAR(150), 
                                                    pStr6 			CHAR(100), 
                                                    pStr7 			CHAR(60),  
                                                    pStr8 			CHAR(60), 
                                                    pStr9 			CHAR(15), 
                                                    pStr10 			CHAR(100), 
                                                    pImporte1 		MONEY (16,2), 
                                                    pImporte2 		MONEY (16,2), 
                                                    pImporte3 		MONEY (16,2), 
                                                    pImporte4 		MONEY (16,2), 
                                                    pImporte5 		MONEY (16,2), 
                                                    pEmail		  	CHAR(50))
RETURNING CHAR(5) AS retorno;

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
	DEFINE v_hoy                DATE;
	DEFINE vsecuenciaos			INTEGER;

	DEFINE vFechaApertura		DATE; 
	DEFINE vFUltimoPago			DATE;
	DEFINE vlNumCte				CHAR(10);
	DEFINE cCodRet				CHAR(5);
	DEFINE vvcCod_ret			CHAR(5);
	DEFINE vValido              CHAR(1);


--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

	LET cCodRet        		= "00000";
	LET vEnvioOS			= '';
	LET vsqlerr				= 0;

	LET vnumsolPros			=''; 
	LET vStatusCred			=''; 
	LET vsecuenciaos        = 0;
	LET vlNumCte			= '';	

	LET vFechaApertura		= DATE(1); 
	LET vFUltimoPago		= DATE(1);
	LET vvcCod_ret			= '00000';

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_validageneraos.out";
-- TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************
    
	SET ISOLATION TO DIRTY READ;
	
	/*
	IF (pUsuario = '' or  pEmail = '' OR pPassword = '' OR pNombre ='') THEN
       LET vvcCod_ret = '00010';
      RETURN cCodRet;
    END IF;
	*/
  
   EXECUTE PROCEDURE bdinteg:sp_validaEmail(pEmail) INTO vvcCod_ret,vValido  ;
	
	-- select first 1  numcte into vlNumCte  
	-- from bdinteg:si_correos 
	-- where correo_elec = pEmail
	-- AND status_correo = 'A';
	-- IF NVL(vlNumCte, '') <> '' THEN 
	-- let vlNumCte  = '000000000';
	
   IF vvcCod_ret ='00000'  THEN 
      LET vlNumCte  = '000000000';            
        CALL bdimnsj:"informix".sp_registra_evento (1, pIdMensaje, vlNumCte, '','', 1,
                                                    pStr1, pStr2,  pStr3, pStr4, pStr5, pStr6, pStr7,  pStr8, pStr9,pStr10, 
                                                    pEmail,'',
                                                    pImporte1 , 
                                                    pImporte2 , 
                                                    pImporte3 , 
                                                    pImporte4 , 
                                                    pImporte5, '', '')RETURNING vvcCod_ret;
      
   END IF;
	--ELSE						
	  --LET cCodRet = '00002';
    --END IF;													
END	
	RETURN vvcCod_ret;
	
END PROCEDURE;