CREATE PROCEDURE "informix".sp_altabaja_existente (pTokenIni char (9), pTokenFin char (9), pUsuario char (8),pCiclo int, pTipo char(1), pFecha DATE)
returning char (5), char(6),char (9),char(9)

--Elaboró: Javier A. Chávez Trujillo.
--Fecha: 05/11/09
--Solicitó: Mauricio León.
--Actividad: Agrega los nuevos token
--Modificó: Javier Chávez
--Modificación: Se agrego una instruccion para el rellenado con ceros a variables.
--Fecha:09-03-2010
---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicitó: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Realizo: Ilse Jazmín Gómez Pérez
--Modificación:Se modifico para que guarde la fecha de caducidad.
--Solicitó: José de Jesus Nevarez
--Fecha:22/11/2013
---------------------------------------------------------------------------------------------
--Define Variables
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE ciclo int;
DEFINE vEntrada int;
DEFINE vExistencias char (6);
DEFINE vSerieFin char(9);
DEFINE vSerieIni char(9);

--SET DEBUG FILE TO "/tmp/sp_agregar_token_existente.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	
-- Inicializa
LET cod_ret = '00000';
LET sql_err =0;
LET ciclo =0;
LET vEntrada =0;
LET vExistencias ='';
LET vSerieFin =0;
LET vSerieIni =0;


 BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,vExistencias,vSerieIni,vSerieFin;
      END IF ;
   END EXCEPTION ;

  IF(pTipo = 'A') THEN
	IF(pTokenFin IS NULL OR pTokenFin = '') THEN
		IF NOT EXISTS( SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pTokenIni) THEN
					INSERT INTO bdibpi:"informix".tkn_nseries VALUES (pTokenIni,100,CURRENT,pUsuario,'04',pFecha);
					INSERT INTO bdibpi:"informix".tkn_status_token VALUES (pTokenIni,100,'0',CURRENT,pUsuario,'04');
					LET cod_ret = '00000'; -- Se agregó el registro
		ELSE
				LET cod_ret = '00001'; -- El token ya existe en la tabla
		END IF;
	ELSE
		IF NOT EXISTS (SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin) THEN

					SET LOCK MODE TO WAIT 3;
					LET vEntrada = pTokenIni::int;
					FOR  ciclo = 1 TO pCiclo
						INSERT INTO bdibpi:"informix".tkn_nseries VALUES (LPAD(vEntrada,9,'0'),100,CURRENT,pUsuario,'04',pFecha);
						INSERT INTO bdibpi:"informix".tkn_status_token VALUES (LPAD(vEntrada,9,'0'),100,'0',CURRENT,pUsuario,'04');
						LET vEntrada = vEntrada+1;
					END FOR;
					LET cod_ret = '00000'; --Se agregaron los registros
		ELSE
					LET cod_ret = '00002'; --Algun token ya esta en la tabla
		END IF;
	END IF;

 ELSE

	IF(pTokenFin is NULL OR pTokenFin = '')THEN

				IF EXISTS(SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pTokenIni AND id_status = 100)THEN

					DELETE bdibpi:"informix".tkn_nseries WHERE ns_token = pTokenIni;
					DELETE bdibpi:"informix".tkn_status_token WHERE ns_token = pTokenIni;
					LET cod_ret = '00000';
				ELSE

					LET cod_ret = '00003';

				END IF;

	ELSE
				IF EXISTS (SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin AND id_status = 100) THEN

					DELETE 	bdibpi:"informix".tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin;
					DELETE 	bdibpi:"informix".tkn_status_token WHERE ns_token BETWEEN pTokenIni AND pTokenFin;
					LET cod_ret = '00000';
				ELSE

					LET cod_ret = '00004';

				END IF;
	END IF;

 END IF;

		SELECT COUNT(*) INTO vExistencias FROM bdibpi:"informix".tkn_nseries  WHERE id_status = 100;
		SELECT MIN(ns_token::varchar(9)) INTO vSerieIni FROM bdibpi:"informix".tkn_nseries WHERE id_status = 100;
		SELECT MAX(ns_token::varchar(9)) INTO vSerieFin FROM bdibpi:"informix".tkn_nseries WHERE id_status = 100;

	RETURN cod_ret,vExistencias,vSerieIni,vSerieFin;
 END;
END PROCEDURE;