CREATE PROCEDURE "informix".sp_soe_actualiza_status(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pIdStatus SMALLINT, pIdUsuario INTEGER, pIpUsuario CHAR(15), pSucCambio CHAR(4))
	RETURNING CHAR(5) as codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdStatus SMALLINT;
	DEFINE iIdentAdmin CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdStatus = 0;
	LET iIdentAdmin = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_actualiza_status.out';
		--TRACE ON;
		
		-- ValidaciÃ³n de las variables
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- ValidaciÃ³n del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT id_status
		INTO iIdStatus
		FROM bdibei:"informix".bei_usuario
		WHERE id_usuario = pIdUsuario 
			AND num_cliente = pNumCliente;
			
		SELECT identificacion_admin
		INTO iIdentAdmin
		FROM bdibei:"informix".bei_servicio
		WHERE id_usuario = pIdUsuario 
			AND num_cliente = pNumCliente;
			
		IF iIdStatus >= 30 THEN
			IF iIdStatus <> 99 THEN
				IF iIdStatus <> pIdStatus THEN
					
					-- ActualizaciÃ³n del estatus
					UPDATE bdibei:"informix".bei_usuario
					   SET id_status = pIdStatus,
					        f_status = CURRENT
					WHERE id_usuario = pIdUsuario 
						AND num_cliente = pNumCliente;
					
					UPDATE bdibei:"informix".bei_servicio
					   SET id_status = pIdStatus
					WHERE id_usuario = pIdUsuario 
					   AND num_cliente = pNumCliente;
					
					-- Se insert el registro en la tabla bei_cambiastusuario
					INSERT INTO bdibei:"informix".bei_cambiostusuario(id_usuario, numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio, pidentadmin)
					VALUES(pIdUsuario, pNumCliente, iIdStatus, pIdStatus, pIpUsuario, CURRENT, pSucCambio, pUsuario, iIdentAdmin);
				
				ELSE
					IF pIdStatus == 95 THEN
						LET cCodRet = '00182'; -- El servicio de usuario ya tiene un reset de usuario
					ELIF  pIdStatus == 60 THEN
						LET cCodRet = '00210'; -- El servicio de usuario se encuentra bloqueado
					ELSE
						LET cCodRet = '00211'; -- El servicio de usuario tiene estatus de desbloqueado, el usuario puede acceder al portal sin problema
					END IF;	
					
				END IF;
			ELSE
				LET cCodRet = '00181'; -- El usuario presenta estatus cancelado
			END IF;
		ELSE
			LET cCodRet = '00180'; -- El usuario no se ha registrado en el portal de empresanet
			CALL bdibpi:"informix".sp_soe_actualiza_status_bpi(pUsuario, pIdFuncion , pNumCliente, pIdStatus, pIdUsuario, pIpUsuario, pSucCambio) 
				RETURNING cCodRet;					
		END IF;
	END;
	
	RETURN cCodRet;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 02/09/2013",
"DESCRIPCION: Actualiza el estatus de un cliente para que sea tomado como autenticado",
"AUTOR: Viridiana Rosas",
"FECHA: 14/10/2013",
"DESCRIPCION: Se modifica sp para que actualice el estatus del usuario en la tabla bei_servicio y ademÃ¡s",
" se agregen los campos id del usuario y numero de identificacion en la tabla bei_cambiostusuario";

CREATE FUNCTION "informix".getint2ascii(pNumber INT)
	RETURNING CHAR(1) as cascii;
	
	DEFINE cAscii CHAR(1);
	
	LET cAscii = '';
	
	BEGIN
	
		IF pNumber = 65 THEN
			LET cAscii = 'A';
		ELIF pNumber = 66 THEN
			LET cAscii = 'B';
		ELIF pNumber = 67 THEN
			LET cAscii = 'C';
		ELIF pNumber = 68 THEN
			LET cAscii = 'D';
		ELIF pNumber = 69 THEN
			LET cAscii = 'E';
		ELIF pNumber = 70 THEN
			LET cAscii = 'F';
		ELIF pNumber = 71 THEN
			LET cAscii = 'G';
		ELIF pNumber = 72 THEN
			LET cAscii = 'H';
		ELIF pNumber = 73 THEN
			LET cAscii = 'I';
		ELIF pNumber = 74 THEN
			LET cAscii = 'J';
		ELIF pNumber = 75 THEN
			LET cAscii = 'K';
		ELIF pNumber = 76 THEN
			LET cAscii = 'L';
		ELIF pNumber = 77 THEN
			LET cAscii = 'M';
		ELIF pNumber = 78 THEN
			LET cAscii = 'N';
		ELIF pNumber = 79 THEN
			LET cAscii = 'O';
		ELIF pNumber = 80 THEN
			LET cAscii = 'P';
		ELIF pNumber = 81 THEN
			LET cAscii = 'Q';
		ELIF pNumber = 82 THEN
			LET cAscii = 'R';
		ELIF pNumber = 83 THEN
			LET cAscii = 'S';
		ELIF pNumber = 84 THEN
			LET cAscii = 'T';
		ELIF pNumber = 85 THEN
			LET cAscii = 'U';
		ELIF pNumber = 86 THEN
			LET cAscii = 'V';
		ELIF pNumber = 87 THEN
			LET cAscii = 'W';
		ELIF pNumber = 88 THEN
			LET cAscii = 'X';
		ELIF pNumber = 89 THEN
			LET cAscii = 'Y';
		ELIF pNumber = 90 THEN
			LET cAscii = 'Z';
		ELIF pNumber = 91 THEN
			LET cAscii = 'a';
		ELIF pNumber = 92 THEN
			LET cAscii = 'b';
		ELIF pNumber = 93 THEN
			LET cAscii = 'c';
		ELIF pNumber = 94 THEN
			LET cAscii = 'd';
		ELIF pNumber = 95 THEN
			LET cAscii = 'e';
		ELIF pNumber = 96 THEN
			LET cAscii = 'f';
		ELIF pNumber = 97 THEN
			LET cAscii = 'g';
		ELIF pNumber = 98 THEN
			LET cAscii = 'h';
		ELIF pNumber = 99 THEN
			LET cAscii = 'i';
		ELIF pNumber = 100 THEN
			LET cAscii = 'j';
		ELIF pNumber = 101 THEN
			LET cAscii = 'k';
		ELIF pNumber = 102 THEN
			LET cAscii = 'l';
		ELIF pNumber = 103 THEN
			LET cAscii = 'm';
		ELIF pNumber = 104 THEN
			LET cAscii = 'n';
		ELIF pNumber = 105 THEN
			LET cAscii = 'o';
		ELIF pNumber = 106 THEN
			LET cAscii = 'p';
		ELIF pNumber = 107 THEN
			LET cAscii = 'q';
		ELIF pNumber = 108 THEN
			LET cAscii = 'r';
		ELIF pNumber = 109 THEN
			LET cAscii = 's';
		ELIF pNumber = 110 THEN
			LET cAscii = 't';
		ELIF pNumber = 111 THEN
			LET cAscii = 'u';
		ELIF pNumber = 112 THEN
			LET cAscii = 'v';
		ELIF pNumber = 113 THEN
			LET cAscii = 'w';
		ELIF pNumber = 114 THEN
			LET cAscii = 'x';
		ELIF pNumber = 115 THEN
			LET cAscii = 'y';
		ELIF pNumber = 116 THEN
			LET cAscii = 'z';
		END IF;
		
		RETURN cAscii;
	END;

END FUNCTION;

CREATE PROCEDURE "informix".getrandomcode()
	RETURNING INT, CHAR(8);
	
	DEFINE m INT8;
	DEFINE a INT8;
	DEFINE time INT8;
	DEFINE x INT8;
	DEFINE _x DECIMAL(24);
	DEFINE c INT8;
	DEFINE k INT8;
	DEFINE _rnd CHAR(8);
	DEFINE i INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCadRnds CHAR(64);
	DEFINE cAscii CHAR(1);
	DEFINE iRows INTEGER;
	DEFINE y INT8;
	
	LET m = 4294967296;
	LET a = 65537;
	LET c = 214748364;
	LET k = 16;
	LET _rnd = '';
	LET iSqlErr = 0;
	LET cCadRnds = '';
	LET cAscii  = '';
	LET iRows = 0;
	LET _x = 0.0;
	LET x = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET _rnd = iSqlErr;
			RETURN iSqlErr, _rnd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/getRandomCode.out';
		--TRACE ON;
		
		SELECT ((CURRENT YEAR TO SECOND) - (EXTEND(DATETIME(2013-1-1) YEAR TO DAY, YEAR TO SECOND)))::INTERVAL SECOND(9) TO SECOND::CHAR(10)::INT
		INTO x
		FROM systables WHERE tabid = 1;

		WHILE LENGTH(TRIM(cCadRnds)) < 70
			LET x = (a * x) + c;
			LET x = MOD(x, m);
			LET _x = x / m;
			
			LET y = 65 + (_x * (116 - 65));
			EXECUTE FUNCTION getint2ascii(y::INT) INTO cAscii;
			LET cCadRnds = TRIM(cCadRnds)||cAscii;
			
			IF LENGTH(TRIM(cCadRnds)) = 64 THEN
				EXIT WHILE;
			END IF;
		END WHILE;
		
		LET iRows = 0;
		FOR i=0 TO LENGTH(cCadRnds) STEP 8
			RETURN iRows, SUBSTR(cCadRnds, i, 8) WITH RESUME;
			LET iRows = iRows + 1;
			IF iRows = 8 THEN
				EXIT FOR;
			END IF;
		END FOR;
		
	END;
	
END PROCEDURE;