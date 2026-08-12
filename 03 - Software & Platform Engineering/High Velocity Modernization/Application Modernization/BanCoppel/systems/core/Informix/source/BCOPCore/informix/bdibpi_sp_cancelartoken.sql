CREATE PROCEDURE "informix".sp_cancelartoken(pEmpresa char(3),pNumCliente char(9),pNumtoken char(10),pUsrAtendio char(9),pStatusViejo char(3),pStatusNuevo char(3), pCanal char(2))
RETURNING CHAR(5)

	------------------------------------------------------------------------------------------------------------------------------------
	--Elaboró: Francisco Rodríguez Ibarra
    --Actividad: Cancela la el token, es decir elimina registro de la si_bpitoken, registra la informacion en la si_bpitokenhis
    --Solicito: Mauricio León
    --Fecha: 04-10-2010
	------------------------------------------------------------------------------------------------------------------------------------
	--Modifico:Jose Ruben Lopez
    --Actividad: Se Agrego tipo=5 en bpi_tokensolicitud
    --Solicito: Jose de Jesus Nevarez
    --Fecha: 09-09-2013
	------------------------------------------------------------------------------------------------------------------------------------			
	-- Modifica: Jessica Gutíerrez
    --Actividad: Se modifica en la consulta para que solo traiga un registro en el inner de las tablas bpi_tokensolicitud y si_bpitoken.
    -- Fecha: 7-11-2013
  	------------------------------------------------------------------------------------------------------------------------------------	
	
	-- DECLARA
	DEFINE vCod_Ret char(5);
    DEFINE sql_err integer ;
	DEFINE vNumCliente char(9);
	DEFINE vSucursalRegistra char(4);
	DEFINE vFolioToken char(25);
	DEFINE vF_Status date;
	DEFINE vF_Registro date;
    DEFINE vNumcte char(9);
    DEFINE vSolicitud char(10);
	DEFINE vCod_Ret_Token char(5);
	DEFINE vid_usuario integer;
	-- INICIALIZA
	LET vCod_Ret = '00000';
	LET vNumCliente = '';
	LET vSucursalRegistra = '';
	LET vFolioToken = '';
	LET vF_Status = '01-01-1900';
	LET vF_Registro = '01-01-1900';
    LET vNumcte = '';
    LET vSolicitud = '';
	LET vCod_Ret_Token = '';
	
	--SET DEBUG FILE TO "/home/nubia/sp_cancelartoken.out";
    --TRACE ON;
	BEGIN
	ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF(pNumCliente<>'' OR pNumtoken IS NOT NULL) AND (pNumtoken<>'' OR  pNumtoken IS NOT NULL) THEN
 		
			SELECT TS.num_cliente, TS.suc_registro, TS.folio_token, TS.f_status::date, TS.f_registro::date, TK.numcte, TK.solicitud
			INTO vNumCliente, vSucursalRegistra , vFolioToken , vF_Status , vF_Registro, vNumcte, vSolicitud
				FROM bdinteg:"informix".si_bpitoken AS TS, bdibpi:"informix".bpi_tokensolicitud AS TK
				WHERE TS.empresa=TRIM(pEmpresa) 
				AND TS.num_cliente=TRIM(pNumCliente) 
				AND TS.ns_token=TRIM(pNumtoken)
                AND TK.numcte = TS.num_cliente
				AND TK.ns_token = TS.ns_token;
				
			
			IF(vNumCliente <>'' OR vNumCliente IS NOT NULL) THEN
            
				INSERT INTO bdinteg:"informix".si_bpitokenhis(empresa,num_cliente,ns_token,suc_registro,folio_token,id_status_token,f_status,f_registro) 
									VALUES(pEmpresa,vNumCliente,pNumtoken,vSucursalRegistra,vFolioToken,pStatusNuevo,vF_Status,vF_Registro);
				        
				DELETE bdibpi:"informix".bpi_resp_seguridad 
				 WHERE id_usuario IN (SELECT id_usuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = vNumCliente AND  st_portal IS NOT NULL)
				   AND id_pregunta = '1010';				
				DELETE bdinteg:"informix".si_bpitoken       WHERE empresa=TRIM(pEmpresa) AND num_cliente=TRIM(pNumCliente) AND ns_token=TRIM(pNumtoken);

                		UPDATE bdibpi:"informix".tkn_envios SET id_status = 199 WHERE solicitud = vSolicitud AND numcte = pNumCliente;
                		UPDATE bdibpi:"informix".bpi_tokensolicitud SET tipo = 5 WHERE solicitud = vSolicitud AND numcte = pNumCliente;
					
				EXECUTE PROCEDURE  bdibpi:"informix".sp_set_statustoken_admtoken(pNumToken,pStatusViejo,pStatusNuevo,pUsrAtendio,pCanal) INTO  vCod_Ret_Token;
				
				IF (vCod_Ret_Token<>'000') THEN
					LET vCod_Ret='00003';				END IF;
			
			ELSE
				LET vCod_Ret='00002';			END IF
		ELSE
			LET vCod_Ret='00001';		END IF;
		RETURN vCod_Ret;
	END;
END PROCEDURE;