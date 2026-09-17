create procedure "informix".sp_validavencidos_bis(pEmpresa char(3), pNumCredito char(20), pFechaConsulta Date)

    RETURNING VARCHAR(6), INTEGER, INTEGER;

--15/07/2008
--Creado por:
--Abraham Ayala Aguilar
--Valida que el cliente no tenga creditos vencidos

--10-10-2008
--Modifico:
--Abraham Ayala
--Se sustituyo la manera de consultar si el cliente tiene cuentas vencidas, ahora se calcula conforme a la fecha de vencido, atraves del SP_dias_vencido



--DEFINICION DE VARIABLES--
    DEFINE vCod_Ret       VARCHAR(6);
    DEFINE iSqlErr        INTEGER;
    DEFINE vDifDias       INTEGER;
    DEFINE vFecha2        CHAR(10);
    DEFINE vEstadoCuenta  INTEGER;
    DEFINE vStatus        INTEGER;

	--Set debug file to '/tmp/sp_validavencidos_funciondiasvenc.out';
	--trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret, vDifDias, vEstadoCuenta;
            END IF;
        END EXCEPTION;

--INICIALIZACION DE VARIABLES--
        LET vCod_Ret = "999";   --No tiene cuentas vencidas
        LET vDifDias = 0;
        LET vEstadoCuenta = 3;  -- Para cuando No tiene cuentas vencidas

        IF pEmpresa IS NOT NULL AND TRIM(pEmpresa) <> '' AND pNumCredito IS NOT NULL AND TRIM(pNumCredito) <> '' AND pFechaConsulta IS NOT NULL THEN

            Execute procedure bdicred:sp_dias_vencido_bis(pEmpresa, pNumCredito) into vCod_Ret, vStatus;

            IF vCod_Ret = '000' THEN
                IF vStatus > 0 THEN
                    LET vDifDias = vStatus;

                    IF vDifDias > 0 AND vDifDias < 61 THEN
                        LET vEstadoCuenta = 1;      --Compromiso de pago
                    ELIF vDifDias > 60 THEN ---AND vDifDias < 166 THEN
                        LET vEstadoCuenta = 2;      --Acuerdo de pago
                    --ELIF vDifDias > 165 THEN
                      --  LET vEstadoCuenta = 0;      --No se elaboran compromisos ni acuerdos
                    END IF;
                END IF;
            ELSE
                LET vCod_Ret = '002';   --Error al calcular dias vencidos
                RETURN vCod_Ret, vDifDias, vEstadoCuenta;
            END IF;
        ELSE
            LET vCod_Ret = "001";   --Faltan valores
        END IF;

        RETURN vCod_Ret, vDifDias, vEstadoCuenta;
    END;
END PROCEDURE;