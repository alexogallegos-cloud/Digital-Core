CREATE PROCEDURE "informix".verificatarjetacancelada(pNumTarjeta CHAR(16), pOpcion SMALLINT)
	--DATOS A REGRESAR---
	RETURNING
			CHAR(5) As Cod_Ret,
			CHAR(1) As Status_Tar_Cred;  

	--DEFINICION DE VARIABLES--
    DEFINE vCantReg         SMALLINT; 
    DEFINE vCodRet          CHAR(5);
    DEFINE vCodStatusint    CHAR(3);
    DEFINE vCodStatuschq    CHAR(1);
    DEFINE vCodStatuscred   CHAR(1);
	DEFINE cProducto        CHAR(100);
	DEFINE cProductoTarjeta CHAR(4);
	DEFINE iBanderaPro      INTEGER;
	
	--INICIALIZACION DE VARIABLES--
	LET vCodRet  		 = "000";
	LET vCantReg 		 = 0;
    LET vCodStatusint  	 = "";
    LET vCodStatuschq  	 = "";
    LET vCodStatuscred 	 = "";
	LET cProducto      	 = '';
	LET cProductoTarjeta = '';
	LET iBanderaPro      = 0;
	
--SET DEBUG FILE TO '/home/tmp/leonardo/verificatarjetacancelada.out';
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    IF pOpcion = 1 THEN
		SELECT TRIM(valor)
		INTO cProducto
		FROM bditransfer:"informix".tf_param 
		WHERE empresa = '001'
        AND cod_param = '4';
		
        SELECT inttar.codstatustarjeta, chqtar.status_tar, chqtar.prodtarjeta
        INTO  vCodStatusint, vCodStatuschq, cProductoTarjeta
        FROM intercard:"informix".tarjeta inttar,
            bdicheq:"informix".sc_tarjeta chqtar
        WHERE inttar.numtarjeta = pNumTarjeta 
		AND chqtar.empresa = '001'
        AND chqtar.num_tarjeta = pNumTarjeta;
		  
		IF TRIM(cProducto) <> NVL(cProductoTarjeta, '') THEN 
			LET iBanderaPro = 0;
		ELSE
			LET iBanderaPro = 1;
		END IF;
    ELSE
        SELECT inttar.codstatustarjeta, credtar.status_tar
        INTO vCodStatusint, vCodStatuscred
        FROM intercard:"informix".tarjeta inttar,
            bdicred:"informix".sd_tarjeta credtar
        WHERE inttar.numtarjeta = pNumTarjeta 
           AND credtar.num_tarjeta = pNumTarjeta
           AND credtar.empresa = '001';
    END IF

	IF iBanderaPro = 0 THEN 
	
		--DSB 2010-10-28 Manuel Ramos Figueroa
		--Cancela la tarjeta en la bdicheq:sc_tarjeta o bdicred:sd_tarjeta segun sea el caso, si aparese activa y cancelada en la intercard:tarjeta
		--IF vCodStatusint <> 'ACT' AND (vCodStatuschq = 'C' OR vCodStatuscred = 'C') THEN
		IF vCodStatusint <> 'ACT' THEN
			--Se validan los estatus BLT,BLO,NOA los cuales no se debe cancelar la tarjeta
			IF vCodStatusint = 'BLT' OR vCodStatusint = 'BLO' OR vCodStatusint = 'NOA' THEN --DSB 22/Feb/2011
				LET vCodRet = "011";
			ELSE
				IF (vCodStatuschq = 'A') THEN
					UPDATE bdicheq:sc_tarjeta SET status_tar='C' WHERE num_tarjeta=pNumTarjeta AND empresa='001';
				ELIF (vCodStatuscred = 'A') THEN
					UPDATE bdicred:sd_tarjeta SET status_tar='C' WHERE num_tarjeta=pNumTarjeta AND empresa='001';
				END IF
				IF  vCodStatuscred <> 'I' THEN
					LET vCodRet = "111";
				END IF
			END IF
		END IF

		LET vCantReg = DBINFO("sqlca.sqlerrd2");

		IF vCantReg = 0 THEN
			LET vCodRet = "132";
		END IF
	ELSE
		LET vCodRet = '858';
	END IF;
    RETURN vCodRet,vCodStatuscred;
END PROCEDURE
DOCUMENT
'Modificó: Manuel Ramos Figueroa',
'Fecha: 28/Octubre/2010',
'Descripcion: Se modifica para actualizar el campo status_tar a cancelado "C" de la bdicheq:sc_tarjeta o bdicred:sd_tarjeta segun sea el caso',
             'cuando está este cancelada en la intercard:tarjeta.',
'BD: bdicheq',
'Modificó: Marcos Cuevas',
'Fecha: 22/Feb/2011',
'Descripcion: Se modifica para añadir validacion sobre los estatus BLT,BLO,NOA',
'                                                                                                                          ',
'Modificó : Martín Eduado Miranda Miranda',
'Fecha: 20/06/2012',
'Descripción: Se modifica Procedimiento Almacenado para retornar el status de la Tarjeta para el caso de TDC',
'',
'Folio: 1611',
'AUTOR :95594213 Leonardo Plata',
'FECHA : 01/07/2014',
'MODIFICACIÓN: Se Modifica sp para que en caso de que el producto de la tarjeta sea 8000 retorne codigo de error',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez ',
'BD: bdicheq';

CREATE PROCEDURE "informix".cancelatarjeta(pEmpresa CHAR(3),
                  pCuenta CHAR(20), pNumTarjeta CHAR(20),
                  pNumCte CHAR(20))

	RETURNING
	CHAR(5),MONEY(14,2); -- Codigo de retorno

	DEFINE vCodRet	  CHAR(5);
	DEFINE vActualizo INTEGER;
	DEFINE vSqlErr	  INTEGER;
        DEFINE vmonto_aut MONEY(14,2);

	LET vcodret    = "000";
	LET vActualizo = 0;
	LET vSqlErr    = 0;
        LET vmonto_aut = 0;

	BEGIN
		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet,vmonto_aut;
			END IF;
		END EXCEPTION;


		-- ACTUALIZAR EL ESTADO DE LA TARJETA
		UPDATE
			bdicheq:sc_tarjeta
		SET
			status_tar = 'C'
		WHERE
			empresa = pEmpresa AND
			cuenta = pCuenta AND
			numcte = pNumCte AND
			num_tarjeta = pNumTarjeta;

		-- Regresa el Monto Autorizado de la Tarjeta
                SELECT limite_aut INTO vmonto_aut
                FROM   sc_tarjeta
		WHERE  empresa = pEmpresa AND
		       cuenta = pCuenta AND
		       numcte = pNumCte AND
		       num_tarjeta = pNumTarjeta;

                -- VERIFICAR SI SE CAMBIO EL ESTADO DE LA TARJETA
		SELECT
			1
		INTO
			vActualizo
		FROM
			bdicheq:sc_tarjeta
		WHERE
			empresa = pEmpresa AND
			cuenta = pCuenta AND
			numcte = pNumCte AND
			num_tarjeta = pNumTarjeta AND
			status_tar = 'C';


		IF vActualizo <> 1 THEN
			LET vCodRet = "254";
		END IF

		RETURN vCodRet,vmonto_aut;
	END
END PROCEDURE;