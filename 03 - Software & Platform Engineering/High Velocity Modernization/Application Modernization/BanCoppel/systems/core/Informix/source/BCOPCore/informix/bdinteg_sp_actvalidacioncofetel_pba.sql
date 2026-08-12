CREATE PROCEDURE "informix".sp_actvalidacioncofetel_pba( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1))
    RETURNING CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;

    -- Inicializa variables
     LET cCodRet = "00000";
     LET iSql_err = 0;
     LET iMaxSecuencia = 0;

    --SET debug FILE TO "/tmp/sp_actvalidacioncofetel.out";
    --trace ON;
	 
	-----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la si_direcciones si el telefono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	 
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SELECT max(secuencia) INTO iMaxSecuencia  from si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

        IF cFlagTelefonoCasa = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel1 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;
		
		IF cFlagTelefonoCelular = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel2 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

		IF cFlagTelefonoOficina = 1 AND cTipoDireccion = "2" THEN
            UPDATE si_direcciones SET ind_COFETELtel3 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;