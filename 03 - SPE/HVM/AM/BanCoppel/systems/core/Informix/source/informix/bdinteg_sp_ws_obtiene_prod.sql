CREATE PROCEDURE "informix".sp_ws_obtiene_prod(
	cAgentTransTypeCode CHAR(10),
	cAgentCd CHAR(3),
	cUsuario CHAR(8),
	cPassword CHAR(8),
	cIpOrigen CHAR(15),
	cIdSession CHAR(30),
	cNumCte CHAR(20)
)
RETURNING 
  CHAR(4) AS cCodRet,
  CHAR(120) AS cMensajeResp,
  CHAR(4) AS cCodProd,
  CHAR(120) AS cDescProd,
  CHAR(255) AS cCausaRechazoBcpl,
  CHAR(255) AS cCausaRechazoCpl;
  
   
DEFINE sql_err INTEGER;
DEFINE vcodret1 CHAR(4);
DEFINE vdesc_msj CHAR(120);
DEFINE vcod_prod CHAR(4);
DEFINE vdesc_prod CHAR(120);
DEFINE vcausa_rechazo_bcpl CHAR(255);
DEFINE vcausa_rechazo_cpl CHAR(255);
DEFINE cSucursal CHAR(100);
DEFINE cEjecutivo CHAR(100);
DEFINE cPuesto CHAR(3);
	
LET vcodret1 = '0000';
LET vdesc_msj = '';
LET vcod_prod = '';
LET vdesc_prod = '';
LET vcausa_rechazo_bcpl = '';
LET vcausa_rechazo_cpl = '';
LET cSucursal = '';
LET cEjecutivo = '';
LET cPuesto = '';

	
    BEGIN
	
    ON EXCEPTION SET sql_err

		RETURN sql_err,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl, vcausa_rechazo_cpl;

    END EXCEPTION;

	 --SET DEBUG FILE TO '/informix/LIP/logs/sp_ws_obtiene_prod.out';
	 --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(cAgentTransTypeCode,'')) <> '' AND TRIM(NVL(cAgentCd, '')) <> '' AND TRIM(NVL(cUsuario,'')) <> '' AND TRIM(NVL(cPassword,'')) <> '' AND TRIM(NVL(cIpOrigen,'')) <> '' AND TRIM(NVL(cIdSession,'')) <> '' AND TRIM(NVL(cNumCte, '')) <> '' THEN
	
		--VALIDAR SESIÃ?Â?Ã?Â?N
		EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(cAgentTransTypeCode), TRIM(cAgentCd), TRIM(cUsuario), TRIM(cPassword), TRIM(cIpOrigen), TRIM(cIdSession) ) INTO vcodret1, vdesc_msj;

			IF TRIM(vcodret1) = '0000' THEN
				
				--CONSULTAR SUCURSAL
				SELECT valor INTO cSucursal FROM si_param WHERE cod_param = 480;
				
				--CONSULTAR EJECUTIVO
				SELECT valor INTO cEjecutivo FROM si_param WHERE cod_param = 481;
				
				--OBTENER PRODUCTOS
				EXECUTE PROCEDURE bdisolic:"informix".sp_determina_productos(cNumCte, cSucursal, cEjecutivo, 'E', '0', '0', '1', '1') INTO vcodret1, vcod_prod, vdesc_prod, vcausa_rechazo_bcpl;
				
				-- En el caso de tener un problema en la oferta, no se ofertará ningún producto.
				IF (vcod_prod is NULL or vcod_prod = '') THEN 
					LET vcod_prod = '0000';
					LET vdesc_prod = 'NINGUN PRODUCTO';
					LET vcausa_rechazo_bcpl = '';
				END IF;
				
				-- A PETICION DE OMNICANAL SIEMPRE SE REGRESA '0000'
				LET vcodret1 = '0000';
				
			END IF;
			
	ELSE
	
		LET vcodret1= "9996";
		LET vdesc_msj = "Uno de los parÃ?Â?Ã?Â¡metros de seguridad viene vacÃ?Â?Ã?Â­o";
		
	END IF;
	
	RETURN vcodret1,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl, vcausa_rechazo_cpl;
END;
END PROCEDURE;