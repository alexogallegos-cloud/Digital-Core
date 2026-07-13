CREATE PROCEDURE "informix".sp_clientevencido(pEmpresa CHAR(3), pNumCliente CHAR(20))

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

--DEFINICION DE VARIABLES--
    DEFINE vCod_Ret       VARCHAR (6);
    DEFINE iSqlErr        INTEGER;
    DEFINE vStatus       INTEGER;
    DEFINE vNumCredito    CHAR(20);
	DEFINE vmSuma   MONEY(18,2);
    DEFINE vmCatidadAcordada    MONEY(18,2);
    DEFINE vdFechaAcuerdo DATE;

--    Set debug file to '/tmp/sp_clientevencido_pba.out';
--    trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret;
            END IF;
        END EXCEPTION;


--INICIALIZACION DE VARIABLES--
        LET vCod_Ret = "000";   --No tiene cuentas vencidas
        LET vmSuma = 0.00;
        LET vmCatidadAcordada = 0.00;
		

        IF (pEmpresa IS NOT NULL and pEmpresa <> '') AND (pNumCliente IS NOT NULL and pNumCliente <> '') THEN

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		       FOREACH
			   
                SELECT a.num_credito INTO vNumCredito
                FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:sd_maesdos b ON b.num_credito = a.num_credito
                WHERE a.empresa = pEmpresa AND a.numcte = pNumCliente
				AND a.status_cred IN ('BA','BT','E1','E2','E3')       -- solo se deben de realizar convenios sobre creditos BT y  BA
				AND (b.monto_vencido + b.mto_venc_trasp) > 0
				
				
				
						EXECUTE PROCEDURE bdicred:"informix".sp_dias_vencido(pEmpresa, vNumCredito) INTO vCod_Ret, vStatus;

						IF EXISTS(SELECT * FROM bdicobranza:"informix".cb_compac WHERE empresa= '001' AND numcliente = pNumCliente) THEN
							LET vCod_Ret = "004";   --Tiene convenio vigente
							Return vCod_Ret;
						END IF;

						IF vCod_Ret = '000' THEN
								IF vStatus > 0 THEN
								   
										LET vCod_Ret = "001";   --Tiene cuentas vencidas
									
								END IF;
						ELSE
							
							LET vCod_Ret = "002";   --Error al calcular dias vencidos
							
							
						END IF;
						
						Return vCod_Ret;
						
            END FOREACH;

        ELSE

            LET vCod_Ret = "999";   --Faltan valores

        END IF;

        RETURN vCod_Ret;

    END;

END PROCEDURE;