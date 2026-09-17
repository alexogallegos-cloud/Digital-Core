CREATE PROCEDURE "informix".sp_altabaja_disponible (pTokenIni char (9), pTokenFin char (9), pUsuario char (8),pCon integer, pTipo char (1))
returning char (5) as CodRet, char(6) as Existentes, char(6) as disponible, char(9) as Minimo, char (9) as maximo

--Elaboró: Javier A. Chávez Trujillo.
--Fecha: 05/11/09
--Solicitó: Mauricio León.
--Actividad: pone los token de existente a disponible y viceversa.
--Modificó: Javier Chávez
--Modificación: Se agrego una instruccion para el rellenado con ceros a variables
--Fecha:09-03-2010

---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Define Variables
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE vCont integer;
DEFINE vNsToken char(9);
DEFINE vEntrada integer;
DEFINE ciclo integer;
DEFINE vExistencias char (6);
DEFINE vDisponibles char (6);
DEFINE vSerieIni char(9);
DEFINE vSerieFin char(9);

--SET DEBUG FILE TO "/tmp/sp_agregar_token_existente.out";
--TRACE ON;

-- Inicializa
LET cod_ret = '00000';


BEGIN
 ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,vExistencias,vDisponibles,vSerieIni,vSerieFin;
      END IF ;
   END EXCEPTION ;

	IF(pTipo = 'B')THEN
			IF (pTokenFin IS NULL OR pTokenFin = '') THEN
					IF EXISTS (SELECT ns_token FROM tkn_nseries WHERE ns_token = pTokenIni AND id_status = 105) THEN
							UPDATE tkn_nseries SET
							id_status = 100,canal='04'
							WHERE ns_token = pTokenIni;
							INSERT INTO bdibpi:tkn_status_token VALUES (pTokenIni,100,'105',CURRENT,pUsuario,'04');
							LET cod_ret = '00000';
						ELSE
							LET cod_ret = '00001';
						END IF;

			ELSE
					SELECT COUNT(*) INTO vCont FROM tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin AND id_status = 105;

					IF(vCont=pCon)THEN
							UPDATE tkn_nseries SET
							id_status = 100,canal='04'
							WHERE ns_token BETWEEN pTokenIni AND pTokenFin AND id_status = 105;
								SET LOCK MODE TO WAIT 3;
								LET vEntrada = pTokenIni::int;
							FOR  ciclo = 1 TO pCon
								INSERT INTO bdibpi:tkn_status_token VALUES (LPAD(vEntrada,9,'0'),100,'105',CURRENT,pUsuario,'04');
								LET vEntrada = vEntrada+1;
							END FOR;

							LET cod_ret = '00000';
					ELSE
						LET cod_ret = '00002';
					END IF;
			END IF;
	ELIF (pTipo = 'A') THEN

			IF (pTokenFin IS NULL OR pTokenFin = '') THEN
					IF EXISTS (SELECT ns_token FROM tkn_nseries WHERE ns_token = pTokenIni AND id_status = 100) THEN
							UPDATE tkn_nseries SET
							id_status = 105,canal='04'
							WHERE ns_token = pTokenIni;
							INSERT INTO bdibpi:tkn_status_token VALUES (pTokenIni,105,'100',CURRENT,pUsuario,'04');
							LET cod_ret = '00000';
						ELSE
							LET cod_ret = '00003';
						END IF;
			ELSE
				SELECT COUNT(*) INTO vCont FROM tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin AND id_status = 100;
				IF (vCont=pCon) THEN
							UPDATE tkn_nseries SET
							id_status = 105,canal='04'
							WHERE ns_token BETWEEN pTokenIni AND pTokenFin AND id_status = 100;

							SET LOCK MODE TO WAIT 3;
								LET vEntrada = pTokenIni::int;
							FOR  ciclo = 1 TO pCon
								INSERT INTO bdibpi:tkn_status_token VALUES (LPAD(vEntrada,9,'0'),105,'100',CURRENT,pUsuario,'04');
								LET vEntrada = vEntrada+1;
							END FOR;
							LET cod_ret = '00000';
				ELSE
					LET cod_ret = '00004';
				END IF;

			END IF;

	END IF;
		SELECT
		SUM(CASE WHEN  id_status = 100 THEN 1 END) id100,
		SUM(CASE WHEN  id_status = 105 THEN 1 END) id105
		INTO vExistencias, vDisponibles
		FROM tkn_nseries
		WHERE id_status IN (100,105);

		SELECT MIN(ns_token::varchar(9)) INTO vSerieIni FROM tkn_nseries WHERE id_status = 100;
		SELECT MAX(ns_token::varchar(9)) INTO vSerieFin FROM tkn_nseries WHERE id_status = 100;

 RETURN cod_ret,vExistencias,vDisponibles,vSerieIni,vSerieFin;
END;
END PROCEDURE;