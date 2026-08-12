CREATE PROCEDURE "informix".sp_blqvalidacuentasconcentrarcap(pUsuario     char(8), 
				      	 		     pIdFuncion   char(10),
                                      	 		     pCuenta      CHAR(20))
	RETURNING CHAR(5) AS codret,
		  CHAR(20) AS NumTarjeta,
		  CHAR(10) AS FechaConcent,
		  DECIMAL(14,2) AS ImpteConcent,
		  CHAR(60) AS Estatus,
		  DECIMAL(14,2) AS SaldoConcentrado;
	
DEFINE cCodRet 		CHAR(5);

DEFINE iSqlErr 		INT;

DEFINE cEmpresa       	CHAR(3);

DEFINE pTipoEjecx	SMALLINT; -- 1=POR TARJETA 2=POR CUENTA.
DEFINE pTarjeta		CHAR(20);

DEFINE cCodRet6		CHAR(6);
DEFINE cMensajeRet	CHAR(80);
DEFINE cCuenta		CHAR(20);
DEFINE cNumCliente	CHAR(20);
DEFINE cNomCliente	CHAR(104);
DEFINE cProducto	CHAR(40);
DEFINE cNumTarjeta	CHAR(20);
DEFINE cEstatus		CHAR(60);
DEFINE cFechaConcent	CHAR(10);
DEFINE dImpteConcent	DECIMAL(14,2);

DEFINE vCodRet1         CHAR(5);
DEFINE vSaldoConcentrado DECIMAL(14,2);

LET cCodRet6			= "000000";
LET cMensajeRet			= "PROCESO EXITOSO";
LET cCuenta			= "";
LET cNumCliente			= "";
LET cNomCliente			= "";
LET cProducto			= "";
LET cNumTarjeta			= "";
LET cEstatus			= "";
LET cFechaConcent		= "";
LET dImpteConcent		= 0.0;

LET vCodRet1     		= "00000";
LET vSaldoConcentrado 		= 0.00;

LET cCodRet 			= "00000";
LET iSqlErr 			= 0;

LET cEmpresa 			= "001";
LET pTipoEjecx			= 2; -- 1=POR TARJETA 2=POR CUENTA.
LET pTarjeta			= "";

BEGIN
		
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
				vSaldoConcentrado;
		END IF;
	END EXCEPTION;

	IF  pUsuario = '' 
	 OR pIdFuncion = '' 
	 OR pCuenta = ''
	THEN
		LET cCodRet = '00003';
		RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
			vSaldoConcentrado;
	END IF;
		
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, 
							    		pIdFuncion) 
		INTO cCodRet;
	--
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
			vSaldoConcentrado;
	END IF;

	-- OBTIENE LOS DATOS Y VALIDA LA CUENTA DE CHEQUES
	LET cCuenta = "";
	SET ISOLATION TO DIRTY READ;
	SELECT mc.cuenta
	INTO cCuenta
	FROM bdicheq:"informix".sc_maechq mc
	WHERE mc.cuenta = pCuenta;
	IF NVL(cCuenta,"") = "" THEN
		-- "La Cuenta no existe"
		LET cCodRet = "00009";
		RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
			vSaldoConcentrado;
	END IF;

	-- OBTIENE LOS DATOS Y VALIDA LA CUENTA DE CHEQUES ESTE CONCENTRADA
	LET cCuenta = "";
	SET ISOLATION TO DIRTY READ;
	
	SELECT mc.cuenta
	INTO cCuenta
	FROM bdicheq:"informix".sc_maechq mc
	WHERE mc.cuenta = pCuenta
		AND mc.status_cta = "6";
	
	IF NVL(cCuenta,"") = "" THEN
		-- "La Cuenta no está concentrada"
		LET cCodRet = "00134";
		RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
			vSaldoConcentrado;
	END IF;

        EXECUTE PROCEDURE bdicheq:"informix".sp_calcsdoctainactiva(cEmpresa
					    			  ,pCuenta)
		INTO vCodRet1,
		     vSaldoConcentrado;

	-- codigo de retorno del 2do. SP
	IF vCodRet1 = '100' THEN
	--      cuenta no existe 
		LET cCodRet = '00134';
		RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
			vSaldoConcentrado;
	ELSE
	--      proceso correcto
		LET cCodRet = '00000';
	END IF;

        EXECUTE PROCEDURE bdicheq:"informix".sp_blqvalidacuentasconcentrar(pTipoEjecx
									  ,pTarjeta
					    				  ,pCuenta)
		INTO cCodRet6,
			cMensajeRet,
			cCuenta,
			cNumCliente,
			cNomCliente,
			cProducto,
			cNumTarjeta,
			cEstatus,
			cFechaConcent,
			dImpteConcent;

	-- codigo de retorno del 1er. SP
	-- proceso correcto
	IF cCodRet6 = '000000' THEN
		LET cCodRet = '00000';
	END IF;
	-- falta uno o más parametros
	IF cCodRet6 = '000001' THEN
		LET cCodRet = '00003';
	END IF;
	-- si 1 la tarjeta no existe
	-- si 2 la cuenta no esta concentrada
	IF cCodRet6 = '000002' THEN
		IF pTipoEjecx = 1 THEN
			LET cCodRet = '00029';
		ELSE
			LET cCodRet = '00134';
		END IF;
	END IF;
	-- la cuenta de la tarjeta no esta concentrada
	IF cCodRet6 = '000003' THEN
		LET cCodRet = '00135';
	END IF;

	RETURN cCodRet, cNumTarjeta, cFechaConcent, dImpteConcent, cEstatus, 
		vSaldoConcentrado;
		
END;
	
END PROCEDURE;