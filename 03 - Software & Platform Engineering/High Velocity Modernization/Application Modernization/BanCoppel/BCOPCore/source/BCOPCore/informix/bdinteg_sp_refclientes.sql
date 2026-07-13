CREATE PROCEDURE "informix".sp_refclientes(
								sEmpresa CHAR(3),
								sNumCte CHAR(20),
								sSucursal CHAR(4),
								sApellPaterno CHAR(26),
								sApellMaterno CHAR(26),
								sNombre1 CHAR(26),
								sNombre2 CHAR(26),
								sRfc CHAR(13),
								dFechaNac DATE,
								sCurp CHAR(20),
								sSexo CHAR(1),
								sEstadoCivil CHAR(2),
								sNacionalidad CHAR(3),
								sNoFm CHAR(18),
								sCodigoIden CHAR(2),
								sPersDomicilio CHAR(2),
								sEmail CHAR(60),
								sParentesco CHAR(2),
								sApellCasada CHAR(26),
								sNumcteRef CHAR(20),
								sNumCteBanco CHAR(20),
								sUsuario CHAR(8),
								dFecha DATE
								)
								RETURNING CHAR(5), INTEGER;

--DOCUMENTACION:
--Realizó: Martha Aguirre
--Fecha: 31/01/2009
--Funcionalidad: Inserta en la tabla si_refcliente las referencias de los clientes solicitantes de Crédito

DEFINE iSecuencia  INTEGER;
DEFINE cCodRet     CHAR(5);
DEFINE iSqlErr     INTEGER;
DEFINE wBegin CHAR(1);

LET iSecuencia = 0;
LET cCodRet = "000";


--	SET DEBUG FILE TO '/pisa/pisabanco/sp_refclientes_today.out';
--    TRACE ON;
		
BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;

            ROLLBACK WORK;

            IF (wBegin = "S") THEN
                BEGIN WORK;
            END IF;

            RETURN cCodRet, iSecuencia;
        END IF;
    END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;


    LET wBegin = "N";

    begin work;

    update si_param set valor = cast(valor as integer) + 1 where empresa = sEmpresa and cod_param = 121;
    SELECT cast(valor as integer) INTO iSecuencia FROM bdinteg:si_param where empresa = sEmpresa and cod_param = 121;

    commit work;

    if wBegin = 'S' THEN
        begin work;
    end if;


	INSERT INTO si_refclientes
	(empresa, numcte, sucursal, secuencia, apell_paterno, apell_materno, nombre1, nombre2,
	 rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, pers_domicilio,
	 email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert)
	VALUES
	(sEmpresa, sNumCte, sSucursal, iSecuencia, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
	 sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sPersDomicilio,
	 sEmail, sParentesco, sApellCasada, sNumcteRef, sNumCteBanco, sUsuario, dFecha);

/*	SELECT max(secuencia) 
	INTO iSecuencia
	FROM si_refclientes
        where empresa = sEmpresa
          and numcte = sNumCte;
*/
	RETURN cCodRet, iSecuencia;

END;
END PROCEDURE;