CREATE PROCEDURE "informix".sp_calculadvmastv(pNumRefMasTv CHAR(13))
	RETURNING CHAR(6) AS CodRetorno, SMALLINT AS DVCalculado;

--Definicion de Variables
DEFINE 	iSqlErr 			INTEGER;
DEFINE 	cCodRet 			CHAR(6);
DEFINE	sCiclo				SMALLINT;
DEFINE	sNoPeso				SMALLINT;
DEFINE	sSuma				SMALLINT;
DEFINE	sValorDigito		SMALLINT;
DEFINE	sAux				SMALLINT;      
DEFINE	cNum1				CHAR(1);
DEFINE	cNum2				CHAR(1);	
DEFINE	sDigVerCapturado 	SMALLINT;
DEFINE	sFijo				SMALLINT;
DEFINE	sResiduo        	SMALLINT;

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '003';
LET	sCiclo = 1;
LET	sNoPeso = 0;
LET	sSuma = 0;
LET	sValorDigito = 0; 
LET	sAux = 0;
LET	cNum1 = '';
LET	cNum2 = '';
LET	sDigVerCapturado = 0;
LET	sFijo = 0;	
LET	sResiduo = 0;

--SET DEBUG FILE TO '/tmp/sp_calculadvmastv.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sValorDigito;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF LENGTH(TRIM(pNumRefMasTv)) = 13 THEN
		
		LET sFijo = SUBSTR(pNumRefMasTv, 1, 2)::SMALLINT;
		
		IF sFijo > 0  AND sFijo  < 12 THEN
		
			LET sDigVerCapturado = SUBSTR(pNumRefMasTv, 13, 1)::SMALLINT;

			FOR sCiclo = 1 TO 12
	
				LET sValorDigito = SUBSTR(pNumRefMasTv, sCiclo, 1)::SMALLINT;
				IF MOD(sCiclo, 2) = 1 THEN
					LET sNoPeso = 1;
				ELSE
					LET sNoPeso = 2;
				END IF;
				
				LET sAux = sValorDigito * sNoPeso;
					   
				IF sAux > 9 THEN
					--raise notice 'Multiplicacion Mayor a 9 = %', sAux ;
					LET cNum1 = SUBSTR(sAux::CHAR(2), 1, 1);
					LET cNum2 = SUBSTR(sAux::CHAR(2), 2, 1);
					LET sAux = (cNum1::SMALLINT) + (cNum2::SMALLINT);
				END IF; 
				LET sSuma = sSuma + sAux;
			END FOR;
			
			LET sResiduo = MOD(sSuma, 10);

			IF sResiduo > 0 THEN
				LET sValorDigito = 10 - sResiduo;
				IF sValorDigito =  sDigVerCapturado THEN
					LET cCodRet = '000';
				ELSE
					LET cCodRet = '001';
				END IF;
			ELSE
				IF sResiduo =  sDigVerCapturado THEN
					LET cCodRet = '000';
				ELSE
					LET cCodRet = '001';
				END IF;
			END IF;
		END IF;		
	ELSE
		--raise notice 'Referencia no es de 13 digitos'; 
		LET cCodRet = '002';
	END IF;

	RETURN cCodRet, sValorDigito;
		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Calcula el digito verificador para MASTV',
'AUTOR : Adrian Lara',
'FECHA : 16 de Agosto de 2011',
'VERSION: 20110816',
'BD: bdiprog',
'SISTEMA : Pagos Programados';

CREATE PROCEDURE "informix".sp_altatelefonoctasftes(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										p_sUser CHAR(8))
RETURNING
    CHAR(5),
	CHAR(60);

--Creado por: Javier Calderon
--Actividad:  Si no existe el telefono se registra en la tabla pp_ctasterceros
--Solicito:   Mauricio Leon
--Fecha:      25/02/2010
--Modifico:   Walber Castro
--Razon:      Se agrego actualizacion del digito verificador y codigo de retorno para cuando el telefono ya exista.
--Fecha:      06/10/2010
--Modifico:   Walber Castro
--Razon:      Se agrega validación del status en el query del NOT EXISTS.
--Fecha:      25/10/2010
--Modifico:	Walber Castro
--Razon:    Se modifica la empresa de 000 a 201.
--Fecha:    2011-07-13
--Modifico: Walber Castro
--Razón:    Se agrega nuevo parámetro del usuario.
--Fecha:    2011-09-23

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
LET vCodRet = '000';
LET vMensaje = '';
LET vDigito = '';

SET LOCK MODE TO WAIT 10;
--SET DEBUG FILE TO "/tmp/sp_altatelefonoctasftes.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	IF NOT EXISTS (SELECT user_insert FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') THEN	
		EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '201',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  p_sUser) INTO vCodRet, vMensaje;
		
		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;		END IF;
	ELSE
		LET vCodRet = '001';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;