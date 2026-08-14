CREATE PROCEDURE "informix".sp_consultartarjetas_iccat (pNumCte char (9), pRegistro SMALLINT)
	returning char (5) AS CodRet, char (16) AS NumTarjeta, char (104) AS Nombre, char (3) AS Status,
	DATETIME YEAR TO SECOND AS FechaNac, char (1) AS Titular, char (4) AS Expiracion, char (1) AS Tipo;

	--Elaboró: Javier A. Chávez T.
	--Actividad: Retorna los datos del cliente
	--Solicito: Mauricio León
	--Fecha: 02-04-09

	--DEFINE VARIABLES
	DEFINE vFechaNac DATETIME YEAR to SECOND;
	DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vNumTarjeta char (16);
	DEFINE vNombre char (104);
	DEFINE vStatus char (3);
	DEFINE vTitular char (1);
	DEFINE vExpiracion char (4);
	DEFINE vTipo char (1);

	--Inicializa
	LET vFechaNac = '';
	LET cod_ret ='000';
	LET vNumTarjeta = '';
	LET vNombre = '';
	LET vStatus = '';
	LET vTitular = '';
	LET vExpiracion = '';
	LET vTipo = '';


 BEGIN

          ON EXCEPTION SET sql_err
                  IF sql_err <> 0 THEN
                                let cod_ret = sql_err;
                                RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo;
                  END IF ;
          END EXCEPTION ;

	   SET LOCK MODE TO WAIT 3;

	   IF(pNumCte <> "") THEN

                        SET ISOLATION DIRTY READ ;

			FOREACH
				SELECT SKIP pRegistro FIRST 10
                                numtarjeta, nombre, codstatustarjeta, fechanacimiento, titular, fechaexp
				INTO vNumTarjeta, vNombre, vStatus, vFechaNac, vTitular, vExpiracion
				FROM tarjeta
				WHERE numcliente = pNumCte  order by codstatustarjeta desc

                                SET ISOLATION DIRTY READ ;

				SELECT creditodebito INTO vTipo FROM bines  where bin = substring(vNumTarjeta FROM 1 FOR 6);

				RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo  WITH RESUME;

			END FOREACH;

			IF (vNumTarjeta = '') THEN
				LET cod_ret = '002';
                                RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo;
			END IF;
	  ELSE
			LET cod_ret = '001';
			RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo;
	  END IF;

 END;
END PROCEDURE;