CREATE PROCEDURE "informix".sp_validaauxiliar (spEmpresa CHAR (3), spAuxiliar CHAR(12))

RETURNING INT, CHAR (48);

DEFINE ivCodRet      INT;
DEFINE svMensaje     CHAR(48);
DEFINE ivRegistros   INT;
DEFINE svNomCompleto CHAR(48);
DEFINE svRazonSocial CHAR(35);
DEFINE svTipPersona  CHAR(2);

--*************************************************************
-- Creado por Fabiola Corrales Tapia 31/Ago/2007            --*
-- Debug del Procedure                                      --*
-- SET DEBUG FILE TO "/tmp/sp_validaauxiliar.out";          --*
-- TRACE ON;                                                --*
--*************************************************************

    LET ivCodRet = 1;
    LET svMensaje = NULL;
    LET ivRegistros = 0;

    SELECT COUNT(*) INTO ivRegistros FROM bdicont:co_auxiliar
    WHERE empresa = spEmpresa AND numero = spAuxiliar;

    IF ivRegistros = 1 THEN
        LET ivCodRet  = 0;
        LET svMensaje = 'AUXILIAR VALIDO';

        SELECT TRIM(NVL(apell_paterno,''))||" "||TRIM(NVL(apell_materno,''))||" "||TRIM(NVL(nombre1,''))||" "||TRIM(NVL(nombre2,'')), TRIM(NVL(razon_soc,'')), tp_persona
        INTO svNomCompleto, svRazonSocial, svTipPersona
        FROM bdicont:co_auxiliar
        WHERE empresa = spEmpresa AND numero = spAuxiliar;

        IF svTipPersona = '01'  THEN
            LET svMensaje = svNomCompleto;
            LET ivCodRet = 0;
        ELIF svTipPersona = '02' THEN
            LET svMensaje = svRazonSocial;
            LET ivCodRet = 0;
        ELSE
            LET svMensaje = 'EL TIPO DE PERSONA ES INCORRECTO';
            LET ivCodRet = 0;
        END IF

    ELSE
        IF ivRegistros > 1 THEN
            LET ivCodRet  = 3;
            LET svMensaje = 'EXISTE MAS DE UN REGISTRO DEL AUXILIAR ';
        ELSE
            LET ivCodRet  = 1;
            LET svMensaje = 'NO EXISTE EL NUMERO DE AUXILIAR';
        END IF
    END IF
    RETURN ivCodRet, svMensaje;
END PROCEDURE;