CREATE PROCEDURE "informix".sp_val_clubproteccion_web(pCliente CHAR(20),pCuenta CHAR(20),pCredito CHAR(20),pTarjeta CHAR(20))


RETURNING CHAR(5) AS codRet,
		  DATE AS fecha_vencimiento;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE dtFechaHoy DATE;
DEFINE dtFechaVenc DATE;
DEFINE cNumCte CHAR(20);
DEFINE iDiaVenc INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodret	= "00000";
LET iSqlErr = 0;
LET iDiaVenc = 0;
LET cNumCte = '';
LET dtFechaHoy = '';
LET dtFechaVenc = DATE(1);

--SET DEBUG FILE TO '/home/sp_val_clubproteccion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,dtFechaVenc;
		END IF;
	END EXCEPTION;

	RETURN cCodret,today+100;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET pCliente=TRIM(NVL(pCliente,''));
	LET pCuenta=TRIM(NVL(pCuenta,''));
	LET pCredito=TRIM(NVL(pCredito,''));
	LET pTarjeta=TRIM(NVL(pTarjeta,''));
	

	IF pCliente = '' AND pCuenta = '' AND pCredito= '' AND pTarjeta = '' THEN
		LET cCodret	= "00001";
	ELSE
		IF pCliente = '' THEN
			IF  pCuenta <> '' OR pCredito <> '' THEN
				SELECT num_cte INTO cNumCte FROM bdicheq: "informix".sc_maechq WHERE cuenta = pCuenta;
				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecred WHERE num_credito = pCredito;

					IF dbinfo("sqlca.sqlerrd2") = 0 then
						SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecredcrd WHERE num_credito = pCredito;
					END IF;
				END IF;
			ELIF pTarjeta <> '' THEN
				SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_tarjeta WHERE num_tarjeta = pTarjeta;

				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicheq: "informix".sc_tarjeta WHERE num_tarjeta = pTarjeta;
				END IF;
			END IF;
		ELSE
			SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas where empresa='001';

			SELECT fecha_vencimiento INTO dtFechaVenc FROM bdinteg: "informix".si_ctesavencer  WHERE numcte_banco = pCliente AND pagado = 0;

			IF dtFechaHoy <= dtFechaVenc THEN
				LET iDiaVenc =  dtFechaVenc - dtFechaHoy;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc <= 7 THEN
					LET cCodret	= "01468";
					RETURN cCodret,dtFechaVenc;
				END IF;
			ELIF dtFechaHoy > dtFechaVenc THEN
				LET iDiaVenc =  dtFechaHoy - dtFechaVenc;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc > 0 AND iDiaVenc <= 60 THEN
					LET cCodret	= '01469';
					RETURN cCodret,dtFechaVenc;
				ELIF iDiaVenc > 60 THEN
					LET cCodret	= '01470';
					RETURN cCodret,dtFechaVenc;
				END IF;
			END IF;
		END IF;

	END IF;

	RETURN cCodret,dtFechaVenc;
END
END PROCEDURE
DOCUMENT
'Folio: 137 Consulta saldos para Club de proteccion familiar.',
'Autor: Bryan Limon',
'BD: bdinteg',
'Fecha: 03/11/2016',
'Descripcion: REALIZA LA VALIDACION SEGUN EL ESTADO EN QUE SE ENCUENTRE EL CLUB DE PROTECCION DEL CLIENTE VALIDA QUE MENSAJE MOSTRAR AL USUARIO AL USUARIO';

CREATE PROCEDURE "informix".sp_valida_cel_repetido_web(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))

	RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;
	
	DEFINE sCodRet		CHAR(5);
	DEFINE iCantRep     INTEGER;
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE iDias        INTEGER;
	
	LEt sCodRet     =   '00000';
	LET iCantRep    =   0;
	LET iSqlErr		=   0;
	LET iSamErr     =   0;
	LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='V'	AND (DATE(CURRENT) - DATE(fecha_hora) < 90);
		
	IF iCantRep >= 1 THEN
		LET sCodRet = '00288';
	END IF;
	
	RETURN sCodRet, iCantRep;
END
END PROCEDURE;