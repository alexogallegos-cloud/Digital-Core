CREATE PROCEDURE "informix".sp_buscar_token_inserta (pTokenIni char (9), pTokenFin char (9), pUsuarioBusca char(9))
returning char(5) as cod_ret

--Elaboró: Javier A. Chávez Trujillo.
--Fecha: 02/12/09
--Solicitó: Mauricio León.
--Actividad: Busca Los token
--Modificó: Javier Chávez
--Modificación: se le agrego una linea para hacer mas rápido el insert
--Fecha:11-03-2010

--Define Variables
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE fRegistro char(10);
DEFINE usuarioReg char(9);
DEFINE fRegistroDisp char(10);
DEFINE usuarioRegDisp char(9);
DEFINE fRegistroAsig char(10);
DEFINE usuarioRegAsig char(9);
DEFINE fRegistroEntreg char(10);
DEFINE usuarioRegEntreg char(9);
DEFINE fRegistroGarantia char(10);
DEFINE usuarioRegGarantia char(9);
DEFINE ciclo int;
DEFINE vTokenBusq char(9);

LET  cod_ret = '00001';
LET  fRegistro = '';
LET  usuarioReg = '';
LET  fRegistroDisp = '';
LET  usuarioRegDisp = '';
LET fRegistroAsig = '';
LET usuarioRegAsig = '';
LET fRegistroEntreg = '';
LET usuarioRegEntreg = '';
LET fRegistroGarantia = '';
LET usuarioRegGarantia = '';
LET ciclo = 0;
LET vTokenBusq = '';

BEGIN
 ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

	DELETE FROM bdibpi:tkn_busqueda WHERE usuario_busca = pUsuarioBusca;

	IF(pTokenFin IS NULL OR pTokenFin = '') THEN
		   IF EXISTS(SELECT ns_token FROM  tkn_status_token WHERE ns_token = pTokenIni) THEN

				SELECT  substring (f_status::varchar(23)from 1 for 10),usr_registro_estatus INTO fRegistro,usuarioReg FROM tkn_nseries WHERE ns_token = pTokenIni;

				SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroDisp,usuarioRegDisp
				FROM tkn_status_token
				WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = pTokenIni  AND actual = 105)
				AND ns_token = pTokenIni AND actual = 105;

				SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroAsig,usuarioRegAsig
				FROM tkn_status_token
				WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = pTokenIni  AND actual = 110 )
				AND ns_token = pTokenIni AND actual = 110;

				SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroEntreg,usuarioRegEntreg
				FROM tkn_status_token
				WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = pTokenIni  AND actual = 130 )
				AND ns_token = pTokenIni AND actual = 130;

				SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroGarantia,usuarioRegGarantia
				FROM tkn_status_token
				WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = pTokenIni  AND actual = 199 )
				AND ns_token = pTokenIni AND actual = 199;

				IF (fRegistro <> '' OR fRegistro IS NOT NULL) THEN

					INSERT INTO tkn_busqueda (ns_token,fecha_registro,usuario_registro,fecha_disp,usuario_disp,fecha_asig,usuario_asig,fecha_entreg,usuario_entreg,fecha_garantia,usuario_garantia,usuario_busca)
					VALUES (pTokenIni,fRegistro,usuarioReg,fRegistroDisp,usuarioRegDisp,fRegistroAsig,usuarioRegAsig,fRegistroEntreg,usuarioRegEntreg,fRegistroGarantia,usuarioRegGarantia,pUsuarioBusca);

					LET cod_ret = '00000';

				ELSE

					LET cod_ret = '00002';

				END IF;
			ELSE

					LET cod_ret = '00001';

			END IF;

	ELSE
			SET ISOLATION DIRTY READ; 
                FOREACH
                       SELECT ns_token,substring (f_status::varchar(23)from 1 for 10),usr_registro_estatus INTO vTokenBusq,fRegistro,usuarioReg FROM  tkn_nseries WHERE ns_token BETWEEN pTokenIni AND pTokenFin ORDER BY ns_token

			 IF(vTokenBusq <> '' OR vTokenBusq IS NOT NULL) THEN

					IF (fRegistro <> '' OR fRegistro IS NOT NULL)THEN

							SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroDisp,usuarioRegDisp
							FROM tkn_status_token
							WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = vTokenBusq  AND actual = 105)
							AND ns_token = vTokenBusq AND actual = 105;

							SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroAsig,usuarioRegAsig
							FROM tkn_status_token
							WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = vTokenBusq  AND actual = 110 )
							AND ns_token = vTokenBusq AND actual = 110;

							SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroEntreg,usuarioRegEntreg
							FROM tkn_status_token
							WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = vTokenBusq  AND actual = 130 )
							AND ns_token = vTokenBusq AND actual = 130;

							SELECT substring (f_cambio_status::varchar(23)from 1 for 10),usr_cambio_status INTO fRegistroGarantia,usuarioRegGarantia
							FROM tkn_status_token
							WHERE f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = vTokenBusq  AND actual = 199 )
							AND ns_token = vTokenBusq AND actual = 199;

							INSERT INTO tkn_busqueda (ns_token,fecha_registro,usuario_registro,fecha_disp,usuario_disp,fecha_asig,usuario_asig,fecha_entreg,usuario_entreg,fecha_garantia,usuario_garantia,usuario_busca)
							VALUES (vTokenBusq,fRegistro,usuarioReg,fRegistroDisp,usuarioRegDisp,fRegistroAsig,usuarioRegAsig,fRegistroEntreg,usuarioRegEntreg,fRegistroGarantia,usuarioRegGarantia,pUsuarioBusca);

							LET cod_ret = '00000';

					ELSE
							LET cod_ret = '00002';
					END IF;
			 ELSE

				LET cod_ret = '00002';

			 END IF;

		END FOREACH;
   END IF;

    RETURN cod_ret;

END;

END PROCEDURE;