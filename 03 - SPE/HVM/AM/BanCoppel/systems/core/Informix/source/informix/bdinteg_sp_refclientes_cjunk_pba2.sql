CREATE PROCEDURE "informix".sp_refclientes_cjunk_pba2(
												sEmpresa CHAR(3),
												cFuncion CHAR(1),
												sNoSolicitud CHAR(20),
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
												sNumIdentif CHAR(30),
												sPersDomicilio CHAR(2),
												sEmail CHAR(60),
												sParentesco CHAR(2),
												sApellCasada CHAR(26),
												sNumcteRef CHAR(20),
												sNumCteBanco CHAR(20),
												sUsuario CHAR(8),
												dFecha DATE,
												pSecuenciaRef integer
												)
RETURNING CHAR(5), INTEGER;

--DOCUMENTACION:
--Realizó: Martha Aguirre
--Fecha: 31/01/2009
--Funcionalidad: Inserta en la tabla si_refclientes
-- las referencias de los clientes solicitantes de Crédito

--Modifico: Daniela Ramirez
--Fecha: 13/06/2011
--Modificación: se agrega parametro de secuencia.

DEFINE iSecuencia  INTEGER;
DEFINE cCodRet     CHAR(5);
DEFINE iSqlErr     INTEGER;
DEFINE wBegin CHAR(1);

LET iSecuencia = 0;
LET cCodRet = "00000";

    --SET DEBUG FILE TO "/respaldosbd/Martha/sp_refclientes_cjunk.out";
    --TRACE ON;

SET LOCK MODE TO WAIT 7;
		
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
	commit work;

	if wBegin = 'S' THEN
		begin work;
	end if;

	IF cFuncion = "A" THEN
		
		-- UPDATE {+INDEX(bdinteg:"informix".si_param ix_si_param)} bdinteg:"informix".si_param SET valor = CAST(valor AS INTEGER) + 1 WHERE empresa = sEmpresa AND cod_param = 121;
		UPDATE bdinteg:"informix".si_param SET valor = CAST(valor AS INTEGER) + 1 WHERE empresa = sEmpresa AND cod_param = 121;
		
		SELECT CAST(valor AS INTEGER) INTO iSecuencia FROM bdinteg:"informix".si_param WHERE empresa = sEmpresa AND cod_param = 121;
		
		INSERT INTO bdinteg:"informix".si_refclientes
		(empresa, num_solicitud, numcte, sucursal, secuencia, apell_paterno, apell_materno, nombre1, nombre2,
		 rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio,
		 email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert)
		VALUES
		(sEmpresa, sNoSolicitud, sNumCte, sSucursal, iSecuencia, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
		 sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdentif, sPersDomicilio,
		 sEmail, sParentesco, sApellCasada, sNumcteRef, sNumCteBanco, sUsuario, dFecha);

	 ELIF cFuncion = "C" THEN
		--SELECT CAST(valor AS INTEGER) INTO iSecuencia FROM bdinteg:si_param where empresa = sEmpresa AND cod_param = 121;
		
		UPDATE bdinteg:"informix".si_refclientes SET 
		(empresa,num_solicitud, numcte, sucursal, apell_paterno, apell_materno, nombre1, nombre2,
		 rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio,
		 email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert) =	
		(sEmpresa, sNoSolicitud, sNumCte, sSucursal, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
		 sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdentif, sPersDomicilio,
		 sEmail, sParentesco, sApellCasada, sNumcteRef, sNumCteBanco, sUsuario, dFecha)
		WHERE numcte = sNumCte AND secuencia = pSecuenciaRef; 
		--WHERE numcte = sNumCte AND secuencia = iSecuencia; 
		
		--LET iSecuencia = iSecuencia;
		LET iSecuencia = pSecuenciaRef;
	END IF;

/*
	SELECT max(secuencia) 
	INTO iSecuencia
	FROM si_refclientes
	WHERE empresa = sEmpresa
	AND numcte = sNumCte;
*/
	RETURN cCodRet, iSecuencia;

END;
END PROCEDURE;