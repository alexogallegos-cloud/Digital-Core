CREATE PROCEDURE "informix".sp_clientevencido_bis(pEmpresa CHAR(3), pNumCliente CHAR(20))

    RETURNING VARCHAR (6);

    -- 15/07/2008
    -- Creado por:
    -- Abraham Ayala Aguilar
    -- Consulta si el cliente tiene creditos vencidos.

	-- 10-10-2008
	-- Modifico:
	-- Abraham Ayala
	-- Se sustituyo la manera de consultar si el cliente tiene cuentas vencidas, ahora se calcula conforme a la fecha de vencido,
    -- atraves del SP_dias_vencido.

    -- 30-10-2008
    -- Modifico:
    -- Walberto Castro
    -- Se agrego la validacion de cuando los días vencidos sean mayor que 165 días se regrese el codigo de retorno 003.

    -- 12-06-2009
    -- Modifico:
    -- Bernardo Carlos Báez González
    -- Se modifico para revisar si el Cliente-Cuenta tiene un compromiso o acuerdo vigente y Marcar los compromisos cumplidos.
    -- Esto solo aplicara cuando se efectue un pago de tarjeta de credito en bdicred:sd_movdia para el cliente-Cuenta que se esta
    -- evaluando.
	--19-09-2012
	--Se depura codigo que no se utiliza y se agrega validación para tomar en cuenta solo creditos con estatus BA y BT para realizar convenios.
	
	-- 19-08-2015
	-- Modifico:
	-- Viridiana Paredes R.
	-- Se verifica si el cliente no tiene convenios en prestamo personal y credinomina con estatus "BA" y "BT".	
	--Base de datos: bdicobranza
 

	--DEFINICION DE VARIABLES
    DEFINE vCod_Ret       	VARCHAR (6);
    DEFINE iSqlErr        	INTEGER;
    DEFINE vStatus       	INTEGER;
    DEFINE vNumCredito    	CHAR(20);
	
	--INICIALIZACION DE VARIABLES
	LET vCod_Ret 		= "000";	LET vStatus			= 0;
	LET vNumCredito		= '';	

	--Set debug file to '/tmp/sp_clientevencido_pba.out';
	--trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret;
            END IF;
        END EXCEPTION;		
		
		IF ( NVL(pEmpresa,'') = '' ) OR ( NVL(pNumCliente,'') = '') THEN
			--Faltan valores
			LET vCod_Ret = "999";
		ELSE
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
		
			FOREACH			
				-- consulta si el cliente no tiene convenios en creditos de plazo fijo DSB VP
				SELECT a.num_credito
				INTO vNumCredito
				FROM bdicred:"informix".sd_maecred a, 
				     bdicred:"informix".sd_definicion b, 
					 bdicred:"informix".sd_maesdos c  
				WHERE a.empresa = pEmpresa
				AND a.numcte = pNumCliente
				AND a.num_credito = c.num_credito
				AND a.status_cred IN ('BA','BT','E1','E2','E3')
				AND (c.monto_vencido + c.mto_venc_trasp) > 0
				AND a.num_producto = b.num_producto
				AND b.realizar_convenio ='S'

				EXECUTE PROCEDURE bdicred:"informix".sp_dias_vencido_bis(pEmpresa, vNumCredito) INTO vCod_Ret, vStatus;
				
				IF EXISTS(SELECT * FROM "informix".cb_compac WHERE empresa= pEmpresa AND numcliente = pNumCliente) THEN
					--Tiene convenio vigente
					LET vCod_Ret = "004";
					RETURN vCod_Ret;
				END IF;
				
				IF vCod_Ret = '000' THEN
					IF vStatus > 0 THEN
						--Tiene cuentas vencidas
						LET vCod_Ret = "001";
						RETURN vCod_Ret;
					END IF;
				ELSE
					--Error al calcular dias vencidos
					LET vCod_Ret = "002";
					RETURN vCod_Ret;
				END IF;				
				
			END FOREACH;
			
			IF vCod_Ret = '000' THEN
			
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				FOREACH			
					-- solo se deben de realizar convenios sobre creditos con estatus FF y CV
					SELECT a.num_credito
					INTO vNumCredito
					FROM bdicred:"informix".sd_maecredcrd a, 
					     bdicred:"informix".sd_definicion b, 
						 bdicred:"informix".sd_maesdoscrd c 
					WHERE a.empresa = pEmpresa
					AND a.numcte = pNumCliente
					AND a.num_credito = c.num_credito
					AND a.status_cred IN ('BA','BT','VP','E1','E2','E3')
					AND (c.monto_vencido + c.mto_venc_trasp) > 0
					AND a.num_producto = b.num_producto
					AND b.realizar_convenio ='S'

					--En construccion
					EXECUTE PROCEDURE bdicred:"informix".sp_dias_vencido_bis(pEmpresa, vNumCredito) INTO vCod_Ret, vStatus;

					IF EXISTS(SELECT * FROM "informix".cb_compac WHERE empresa= pEmpresa AND numcliente = pNumCliente) THEN
						--Tiene convenio vigente
						LET vCod_Ret = "004";
						RETURN vCod_Ret;
					END IF;

					IF vCod_Ret = '000' THEN
						IF vStatus > 0 THEN
							--Tiene cuentas vencidas
							LET vCod_Ret = "001";
							RETURN vCod_Ret;
						END IF;
					ELSE
						--Error al calcular dias vencidos
						LET vCod_Ret = "002";
						RETURN vCod_Ret;
					END IF;					
				END FOREACH;			
			END IF;			
		END IF;
        RETURN vCod_Ret;
    END;
END PROCEDURE;