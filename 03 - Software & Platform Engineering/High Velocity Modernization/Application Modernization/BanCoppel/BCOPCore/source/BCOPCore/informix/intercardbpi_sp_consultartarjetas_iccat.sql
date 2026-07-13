CREATE PROCEDURE "informix".sp_consultartarjetas_iccat (pNumCte char (9), pRegistro SMALLINT)
	returning char (5) AS CodRet, char (16) AS NumTarjeta, char (104) AS Nombre, char (3) AS Status, 
	DATETIME YEAR TO SECOND AS FechaNac, char (1) AS Titular, char (4) AS Expiracion, char (1) AS Tipo, char(20) AS cuenta, char(60) AS descripcion;

	--Elaboró: Javier A. Chávez T.
	--Actividad: Retorna los datos del cliente
	--Solicito: Mauricio León
	--Fecha: 02-04-09
	
	--Modifico: Manuel Ramos Figueroa
	--Actividad: Se modifica para que regrese codigo de retorno de error (003) si el bin de la tarjeta no es un bin valido.
	--Fecha: 14-02-12
	
	--Modifico: Leidy Lizeth Quevedo Peñuelas
	--Actividad: Se modifica para que regrese el número de cuenta y estatus correspondientes a las tarjetas del cliente.
	--Fecha: 13-06-16

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
	DEFINE vConta smallint;
	DEFINE cCuenta CHAR (20);
	DEFINE cDescripcion CHAR (60);
	

	--Inicializa
	LET vFechaNac = '';
	LET cod_ret ='000';
	LET vNumTarjeta = '';
	LET vNombre = '';
	LET vStatus = '';
	LET vTitular = '';
	LET vExpiracion = '';
	LET vTipo = '';
	LET vConta = 0;
	LET cCuenta = '';
	LET cDescripcion = '';
	


 BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo,cCuenta,cDescripcion;
        END IF ;
    END EXCEPTION ;
	
	--SET DEBUG FILE TO '/home/tmp/sp_consultartarjetas_iccat.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	IF(pNumCte <> "") THEN

        SET ISOLATION DIRTY READ ;

		FOREACH
			SELECT SKIP pRegistro FIRST 10
                            numtarjeta, nombre, codstatustarjeta, fechanacimiento, titular, fechaexp
			INTO vNumTarjeta, vNombre, vStatus, vFechaNac, vTitular, vExpiracion
			FROM intercard:"informix".tarjeta
			WHERE numcliente = pNumCte  order by codstatustarjeta desc

            SET ISOLATION DIRTY READ ;

			SELECT creditodebito INTO vTipo FROM intercard:"informix".bines  where bin = substring(vNumTarjeta FROM 1 FOR 6);

			IF (NVL(vTipo, '') <> '' ) THEN
			
				IF (vTipo = 'D') THEN
				SELECT scmaechq.cuenta , scmaechqest.descripcion
						INTO cCuenta, cDescripcion
					FROM BDICHEQ:"informix".sc_maechq scmaechq, BDICHEQ:"informix".sc_mae_estatus scmaechqest, BDICHEQ:"informix".sc_tarjeta sctarjeta
					WHERE sctarjeta.num_tarjeta = vNumTarjeta 
					AND sctarjeta.numcte = pNumCte
					AND scmaechq.cuenta =  sctarjeta.cuenta 
					AND scmaechq.status_cta  = scmaechqest.cod_estatus;
				
				ELIF (vTipo = 'C') THEN
					SELECT sdmae.num_credito, sdTipoCar.descripcion
						INTO cCuenta, cDescripcion
					FROM BDICRED:"informix".sd_maecred sdmae, BDICRED:"informix".sd_tipocartera sdTipoCar, BDICRED:"informix".sd_tarjeta sdTarjeta
					WHERE sdTarjeta.num_tarjeta = vNumTarjeta
					AND sdTarjeta.numcte = pNumCte
					AND sdTarjeta.num_credito = sdmae.num_credito
					AND sdmae.status_cred = sdTipoCar.status_cred;
				END IF;
			
				LET vConta = vConta + 1;
				RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo,cCuenta,cDescripcion  WITH RESUME;
			
			END IF;
		END FOREACH;

		IF (vNumTarjeta = '') THEN
			LET cod_ret = '002';
            RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo,cCuenta,cDescripcion;
		ELSE 
			IF (vConta < 1) THEN
				LET cod_ret = '003'; --El Cliente no tiene tarjetas con BIN valido.
				RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo,cCuenta,cDescripcion;
			END IF;
		END IF;

    ELSE
		LET cod_ret = '001';
		RETURN cod_ret, vNumTarjeta,vNombre,vStatus,vFechaNac,vTitular,vExpiracion,vTipo,cCuenta,cDescripcion;
	END IF;

END;
END PROCEDURE;