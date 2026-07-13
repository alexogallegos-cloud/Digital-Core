CREATE PROCEDURE "informix".sp_actvalidacioncofetel ( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1), cTipo CHAR(1))
    RETURNING
    CHAR(5);
	
    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;
    DEFINE iMaxSecuencia_actual INT;
	
    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET iMaxSecuencia = 0;
    LET iMaxSecuencia_actual = 0;
	
    -----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la bdinteg:"informix".si_direcciones si el teléfono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	--MODIFICACIÓN: Rodolfo Tortolero Varela
	--FECHA: 2011-09-28
	--FUNCIONALIDAD: Se agrega para que tambien actualize en la tabla bdinteg:"informix".si_direcciones_actual.
	----------------------------------------

    --SET DEBUG FILE TO "/tmp/Sp_ActValidacionCofetel.out";
    --TARCE ON;

    SET ISOLATION COMMITTED READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        IF ctipo = "1" THEN
			SELECT max(secuencia) INTO iMaxSecuencia  from bdinteg:"informix".si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;
			SELECT max(secuencia) INTO iMaxSecuencia_actual  from bdinteg:"informix".si_direcciones_actual  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

			 IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF

			IF cFlagTelefonoCelular = "1" and cTipoDireccion = "1" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF

			IF cFlagTelefonoOficina = "1" and cTipoDireccion = "2" THEN
				UPDATE bdinteg:"informix".si_direcciones SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				UPDATE bdinteg:"informix".si_direcciones_actual SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia_actual;
			END IF
		ELIF ctipo = "0" THEN
			LET iMaxSecuencia = 0;
				SELECT max(secuencia) INTO iMaxSecuencia  from bdinteg:"informix".si_refdirecciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;
				IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel1 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF

				IF cFlagTelefonoCelular = "1"and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel2 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF

				IF cFlagTelefonoOficina = "1" and cTipoDireccion = "1" THEN
					UPDATE bdinteg:"informix".si_refdirecciones SET ind_COFETELtel3 = "V" WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
				END IF
		END IF
		
		RETURN cCodRet;
    END;
END PROCEDURE;