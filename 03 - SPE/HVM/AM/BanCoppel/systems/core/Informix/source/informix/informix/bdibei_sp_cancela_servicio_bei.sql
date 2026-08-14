CREATE PROCEDURE "informix".sp_cancela_servicio_bei(pEmpresa char (3), pNumCliente char(9),pSucursal char(4), pUsuario char(8) )
	 RETURNING  CHAR(5), CHAR(5);   -- Codigo de Retorno
	

	--****************************************************************************************************
	-- DESCRIPCION: Cacela el servicio de EmpresaNetPlus pasando los estatus de usuario a 99
	--				y el token a 199.
	-- AUTOR : David Picos C.
	-- FECHA :  2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- Liberado a Producción: Sin liberar
	--
	-- Modificado por: Berenice Noriega, para considerar los clientes sin solicitud atendida. regresa un codigo 
	-- extra para el manejo de error de llamados a spl, se manejan "else" para ejecutar cambios solo si la ejecucion 
	-- de llamados de spl fue exitoso. 
	-- 
	-- Fecha de Modificación: 21 Agosto 2014.
	--  
	--Se modifica SPL para agregar la nueva tabla de historicos bdibei:bei_tokenhis
	--David Picos
	--***************************************************************************************************
	
	
	
    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INTEGER;
    DEFINE vCodRet      CHAR(5);
	DEFINE vCodRet2     CHAR(5);
    DEFINE vIdStatus    CHAR(4);
    DEFINE vServicio smallint;
    DEFINE vSolicitud CHAR(10);

    DEFINE vIdStaSol CHAR(4);
	DEFINE cSolicitud CHAR(10);
	DEFINE vToken CHAR(10);
	DEFINE vIdStaToken CHAR(3);
	DEFINE vSucRegistra CHAR(4);
	DEFINE vF_Status DATE;
	DEFINE vF_Registro DATE;
	DEFINE vIdStaAdm CHAR(4);
	DEFINE vNstoken CHAR(10);
	DEFINE vIdentAdmin CHAR(30);
	DEFINE vIdusuario INTEGER;
	DEFINE vStatusT CHAR (4);
	DEFINE id_tipo_usuario CHAR(4);
	DEFINE vNumCte CHAR(9);
	DEFINE iTotalReg integer;
	DEFINE vfoliotoken CHAR(12);
	DEFINE vSucregistro CHAR(9);
	DEFINE vIdusuario2 INTEGER;
	DEFINE vFecharegistro DATE;
	
    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET vCodRet =   '00000';
	LET vCodRet2 =   '00000';

    LET vIdStatus = '';
    LET vServicio = 0;
    LET VSolicitud = '';

    LET vIdStaSol = '';
	LET vToken = '';
	LET vIdStaToken = '';
	LET vSucRegistra = '';
	LET vF_Status = '01-01-1900';
	LET vF_Registro  = '01-01-1900';
	LET vIdStaAdm = '';
	LET vNstoken = '';
	LET vIdentAdmin = '';
	LET vIdusuario = 0;
	LET vStatusT = '';
	LET id_tipo_usuario = '';
	LET vNumCte = '';
	LET iTotalReg = 0;
	LET vfoliotoken = '';
	LET vSucregistro = '';
	LET vIdusuario2 = 0;
	LET vFecharegistro = '01-01-1900';
	
	
--	SET DEBUG FILE TO "/home/informix/david/sp_cancela_servicio_bei.out";
--	TRACE ON;

BEGIN 
	
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vCodRet2;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

 
-------------------------------------------------------------------------------------------------------------   
---CAMBIO DE ESTATUS USUARIOS ADMINISTRADORES Y OPERADORES---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
   ---ADMINISTRADORES----------------------------------------------------------------------------------------
    FOREACH --Ciclo para cada administrador
		SELECT id_status,id_usuario, identificacion_admin
		INTO vIdStaAdm, vIdusuario, vIdentAdmin
		FROM "informix".bei_servicio
		WHERE num_cliente=pNumCliente 
				 
		IF vIdStaAdm <>'' THEN
			EXECUTE PROCEDURE bdibei:"informix".sp_actualizastatususuario_bei(pEmpresa, pNumCliente, vIdusuario, 99,'',pSucursal, pUsuario,vIdentAdmin)
			INTO vCodRet2; --Actualiza bei_servicio,bei_usuario he inserta en bei_cambiostusuario

			IF vCodRet2 <>'00000' THEN
				LET vCodRet='00001'; --Error en el sp_actualizastatususuario_bei para administradores
				RETURN vCodRet, vCodRet2;
			ELSE 
				UPDATE "informix".bei_contratacion SET status_contrato = 99 WHERE num_cliente = pNumCliente;  --actualiza contrato a cancelado, lo usa el SOE
			END IF;
		ELSE
			LET vCodRet='00002'; --Sin administradores, o los administradores no tienen registro de estatus, error.
			RETURN vCodRet, vCodRet2;
		END IF;
	END FOREACH; --Termina ciclo para cambio de estatus de administradores.
	
	--OPERADORES--------------------------------------------------------------------------
	SELECT COUNT(*)
    INTO iTotalReg
    FROM "informix".bei_usuario  usr
    WHERE usr.num_cliente  = pNumCliente
    AND usr.id_tipo_usuario=2;
	
	IF iTotalReg > 0 THEN --Si tiene operadores registrados entra aqui, si no tiene no es error.
		FOREACH	--Ciclo para cada operador
			--Se toma el viejo estatus 
			SELECT usr.id_usuario 
			INTO vIdusuario  
			FROM "informix".bei_usuario usr
			WHERE usr.num_cliente = pNumCliente and usr.id_tipo_usuario ='2'
						
			IF NVL(vIdusuario,0) <> 0 THEN
				
				EXECUTE PROCEDURE bdibei:"informix".sp_actualizastatususuario_bei(pEmpresa, pNumCliente, vIdusuario, 99,'',pSucursal, pUsuario,'')
				INTO vCodRet2; --Actualiza bei_servicio,bei_usuario he inserta en bei_cambiostusuario
				
				IF vCodRet2 <>'00000' THEN
					LET vCodRet='00003'; --Error en el sp_actualizastatususuario_bei para operadores
					RETURN vCodRet, vCodRet2;
				END IF;

			END IF;
		END FOREACH;
	END IF;
	
-------------------------------------------------------------------------------------------------------------
---CANCELAR LOS TOKENS DE LOS ADMIN Y OPERADORES-------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		
	FOREACH --Ciclo para todas las solicitudes.
		SELECT solicitud
        INTO vSolicitud
        FROM "informix".bei_solicitudtoken
        WHERE numcte=pNumCliente 

        FOREACH --Ciclo para cada token de las solicitudes
            SELECT ns_token
            INTO vNstoken
            FROM "informix".bei_tokensolicitud
            WHERE solicitud=vSolicitud 
            AND numcte=pNumCliente 
                  
			SELECT folio_token,suc_registro,id_status_token,id_usuario,f_registro
            INTO vfoliotoken,vSucregistro,vStatusT,vIdusuario2, vFecharegistro
            FROM "informix".bei_token
            WHERE ns_token=vNstoken; 
                          
            IF NVL(vNstoken,'')<>'' THEN --si tienen tokens los cancela, si no tiene no es error, puede no estar atendida.
				EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(vNstoken,vStatusT, 199 ,pUsuario,'03')
				INTO vCodRet2;  --Actualiza en tabla tkn_nseries he inserta en tkn_status_token
                
				IF vCodRet2 <>'000'THEN
                    LET vCodRet='00004'; --ERROR EN EL SP sp_set_statustoken_admtoken 
                    RETURN vCodRet, vCodRet2;
				ELSE
					INSERT INTO bdibei:"informix".bei_tokenhis(id_usuario,num_cliente,ns_token,suc_registro,folio_token,id_status_token,f_status,f_registro) 
					VALUES(vIdusuario2,pNumCliente,vNstoken,vSucregistro,vfoliotoken,199,current,vFecharegistro);
					DELETE bdibei:"informix".bei_token WHERE num_cliente=TRIM(pNumCliente) and ns_token = vNstoken;
 			    END IF;
	        END IF;

        END FOREACH;
    END FOREACH; -- Termina ciclo para cada Solicitud                  
	
-------------------------------------------------------------------------------------------------------------	
---CAMBIO DE STATUS DE LA SOLICITUD DE TOKENS AL CLIENTE-----------------------------------------------------
-------------------------------------------------------------------------------------------------------------
	-- la solicitud se cancela solo si el servicio esta completo---

    FOREACH --Ciclo para cambiar el estatus de la solicitud
        SELECT solicitud, id_status 
		INTO vSolicitud, vIdStaSol 
        FROM "informix".bei_solicitudtoken  
		WHERE numcte = TRIM(pNumCliente)
		--CANCELA STATUS DE LAS SOLICITUDES DE TOKEN
			EXECUTE PROCEDURE bdibei:"informix".sp_set_solicitudstatus_admtoken_bei(vSolicitud, pNumCliente, pUsuario, vIdStaSol, 199) 
			INTO vCodRet2; --Actualiza tabla bei_solicitudtoken, bei_tokensolicitud, bei_envios he inserta en bei_stasolicitud
			
			IF vCodRet2 <>'000'THEN
				LET vCodRet='000005'; --ERROR EN EL sp_set_solicitudstatus_admtoken_bei
				RETURN vCodRet, vCodRet2;
			END IF;
		
    END FOREACH; -- Termina Ciclo para cambiar solicitud

	RETURN vCodRet, vCodRet2;
		   
END;
END PROCEDURE;