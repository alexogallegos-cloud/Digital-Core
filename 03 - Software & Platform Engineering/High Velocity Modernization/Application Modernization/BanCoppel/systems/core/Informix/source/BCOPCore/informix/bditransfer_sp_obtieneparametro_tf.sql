CREATE PROCEDURE "informix".sp_obtieneparametro_tf
(
	pEmpresa 		CHAR(03),
	pCodParam 		INTEGER
)

RETURNING
	CHAR(06) 	AS cCodRet,
	CHAR(60)	AS cValor;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);
DEFINE cValor		CHAR(60);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet	= '000000';
LET cValor 	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_obtieneparametro_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cValor;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	LET pEmpresa 	= TRIM(pEmpresa);
	
	IF NVL(pEmpresa,'') = '' OR NVL(pCodParam, -1) = -1 THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cValor;
	END IF;
	
	SELECT valor
	INTO cValor
	FROM bditransfer:"informix".tf_param
	WHERE empresa = pEmpresa AND cod_param = pCodParam;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		LET cValor 	= '';
		RETURN cCodRet, cValor;
	END IF;
	RETURN cCodRet, cValor;
END;
END PROCEDURE

DOCUMENT
'Realiza una simple consulta para obtener un campo de la tabla tf_param',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'BD    : bditransfer';

CREATE PROCEDURE "informix".sp_registra_ctafondeo_tf
(
	pEmpresa 		CHAR(03),
	pNumCte 		CHAR(20),
	pCtaTransfer	CHAR(20),
	pCuenta			CHAR(20),
	pPromotor		CHAR(08),
	pBanTipoReg		CHAR(01)
)

RETURNING
	CHAR(06) 	AS CodRet,
	CHAR(25)	AS CtaTF;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE sSecuencia	SMALLINT;
DEFINE cStatus		CHAR(1);
DEFINE dFecha		DATETIME YEAR TO FRACTION;

--RETORNOS
DEFINE cCodRet		CHAR(06);
DEFINE cCtaTF		CHAR(25);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet		= '000000';
LET cCtaTF		= '';
LET sSecuencia	= 0;
LET dFecha		= CURRENT;

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_registra_ctafondeo_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cCtaTF;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte, '') = '' OR NVL(pCtaTransfer, '') = '' OR NVL(pCuenta, '') = ''OR NVL(pBanTipoReg, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cCtaTF;
	END IF;
	
	LET pEmpresa 		= TRIM(pEmpresa);
	LET pNumCte 		= TRIM(pNumCte);
	LET pCtaTransfer	= TRIM(pCtaTransfer);
	LET pCuenta			= TRIM(pCuenta);
	LET pPromotor		= TRIM(pPromotor);
	LET pBanTipoReg		= TRIM(pBanTipoReg);
	
	IF pBanTipoReg = '1' THEN -- Indica que es un Alta
		IF NVL(pPromotor, '') <> '' THEN
			LET cStatus = 'A';
			SELECT MAX(secuencia)
			INTO sSecuencia
			FROM bditransfer:"informix".tf_cta_fondeo
			WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer;
			
			IF NVL(sSecuencia, -1) > 0 THEN
				LET sSecuencia = sSecuencia + 1;
			ELSE
				LET sSecuencia = 1;
			END IF
			
			INSERT INTO bditransfer:"informix".tf_cta_fondeo(empresa, numcte, cuenta_tf, cuenta, secuencia, status, fecha_alta, ejecutivo)
			VALUES(pEmpresa, pNumCte, pCtaTransfer, pCuenta, sSecuencia, cStatus, dFecha, pPromotor);
			LET cCtaTF = TRIM(pCtaTransfer) || sSecuencia;
			RETURN cCodRet, cCtaTF;
		ELSE
			LET cCodRet = '000001';
			RETURN cCodRet, cCtaTF;
		END IF;
	ELIF pBanTipoReg = '2' THEN -- Indica que es una Baja
		SELECT MAX(secuencia)
		INTO sSecuencia
		FROM bditransfer:"informix".tf_cta_fondeo
		WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer AND status = 'A';
		
		IF NVL(sSecuencia, -1) > 0 THEN
		LET cStatus = 'C';
			UPDATE bditransfer:"informix".tf_cta_fondeo SET status = cStatus, fecha_baja = dFecha
			WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer AND cuenta = pCuenta AND secuencia = sSecuencia AND status = 'A';
			LET cCtaTF = TRIM(pCtaTransfer) || sSecuencia || '1';
			RETURN cCodRet, cCtaTF;
		ELSE
			LET cCodRet = '000003';
			RETURN cCodRet, cCtaTF;
		END IF
	ELSE
		LET cCodRet = '000002';
		RETURN cCodRet, cCtaTF;
	END IF
END;
END PROCEDURE

DOCUMENT
'Mediante la bandera que se obtiene de un parámetro determina si es un INSERT o un UPDATE, en el INSERT registra nuevos datos que se obtienen de los parametros a la',
'tabla bditransfer:"informix".tf_cta_fondeo, primero se checa cual ha sido la última secuencia para registrarlo con +1.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'BD    : bditransfer';

CREATE PROCEDURE "informix".sp_reversatarjeta_tf(pEmpresa CHAR(3),pTarjeta CHAR(16))
	
RETURNING CHAR(5)   AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr        INTEGER;
DEFINE cCodRet        CHAR(5);

--Inicializacion de Variables
LET iSqlErr        = 0;
LET cCodRet        = '00000';

--SET DEBUG FILE TO '/home/tmp/leonardo/sp_reversatarjeta_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet; 
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') <> '' AND NVL(pTarjeta, '') <> '' THEN
		
		INSERT INTO bditransfer:"informix".tf_reversotarjeta (empresa,numtarjeta,status_envio,fecha_insert) VALUES (pEmpresa,pTarjeta,'0',CURRENT);
	
	ELSE
		LET cCodRet = '00001'; --Parametros vacios
	END IF;

	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1600',
'AUTOR :95594213 Leonardo Plata',
'FECHA : 11/06/2014',
'MODIFICACIÓN: Se crea sp para insertar en la tabla tf_reversotarjeta',
'SUSTENTO: AsignacionReposicionTarjeta_Anexo.doc',
'SOLICITA: Rodolfo Gomez',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_tf_obtiene_paramtrama(pId SMALLINT)

RETURNING	CHAR(6) AS Codigo_Retorno, SMALLINT AS Transaccion, CHAR(128) AS WebService;

--DECLARACION DE LAS VARIABLES
DEFINE	iSqlErr	 INTEGER;
DEFINE	sTrans	 SMALLINT;
DEFINE	cCodRet	 CHAR(6);
DEFINE	cWebServ CHAR(128);

--INICIALIZACION DE LAS VARIABLES
LET	iSqlErr 	=0;	
LET sTrans		=0;
LET cCodRet		='000000';
LET cWebServ	='';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_obtiene_paramtrama.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,sTrans,TRIM(cWebServ);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pId,0) = 0 THEN
		LET cCodRet='000001';
		RETURN cCodRet,sTrans,TRIM(cWebServ);
	END IF;
	--SELECCIONA LA TRANSACCION Y EL NOMBRE CONTRA EL CAMPO ID
	SELECT transaccion, nombre
	INTO sTrans, cWebServ
	FROM "informix".tf_web_services
	WHERE id=pId;
	
	--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		RETURN cCodRet,sTrans,TRIM(cWebServ);
	END IF;
	RETURN cCodRet,sTrans,TRIM(cWebServ);
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 JesÃºs Ernesto Aguilera Inda.',
'DESCRIPCIÃN: SP que obtiene el nombre del servicio web a utilizar por transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃN: 20140527.1040',
'BASE DE DATOS: bditransfer';

CREATE PROCEDURE "informix".sp_tf_obtienevalorws(pEmpresa CHAR(3),pTransaccion CHAR(5),pIdServicio INTEGER)

RETURNING	CHAR(6) AS Codigo_Retorno, 
			CHAR (17) AS Valor_Num,
			CHAR(100) AS Valor_Alfa,
			CHAR(100) AS Descripcion;

--DECLARACION DE LAS VARIABLES
DEFINE iSqlErr		INTEGER;
DEFINE cCodRet		CHAR(6);
DEFINE cValorNum	CHAR(17);
DEFINE cValorAlfa	CHAR(100);
DEFINE cDescripcion CHAR(100);

--INICALIZACION DE LAS VARIABLES
LET iSqlErr			=0;
LET	cCodRet			='000000';
LET	cValorNum		='';
LET	cValorAlfa		='';
LET cDescripcion	='';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_obtienevalorws.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pEmpresa,'') = '' OR NVL(pTransaccion,'') = '' OR NVL(pIdServicio,0) = 0 THEN
		LET cCodRet='000001';
		RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
	END IF;
	
	FOREACH
		SELECT valor_numerico,valor_alfabetico,descripcion
		INTO cValorNum,cValorAlfa,cDescripcion
		FROM "informix".tf_param_tiposerv
		WHERE empresa=pEmpresa
		AND transaccion=pTransaccion
		AND	id_trans=pIdServicio
		
		RETURN cCodRet, cValorNum,cValorAlfa,TRIM(cDescripcion) WITH RESUME;
		
	END FOREACH
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 Jesus Ernesto Aguilera Inda.',
'DESCRIPCION: Consulta el valor de la tabla tf_param y mandarlo por parametro utilizado en transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃ?N: 20140527.1040',
'BASE DE DATOS: bditransfer';

CREATE PROCEDURE "informix".sp_tf_registraerror(pNumTran SMALLINT,pCodRet INTEGER,pDescripcion CHAR(256),pCuenta CHAR(20)) --PARAMETROS DE ENTRADA

RETURNING CHAR(6) AS Codigo_Retorno; --CODIGO DE RETORNO

--DEFINICION DE LAS VARIABLES
DEFINE 	iSqlErr			INTEGER;
DEFINE 	cCodRet 		CHAR(6);
DEFINE 	dFechaHoy		DATE;

--INICIALIZACION DE LAS VARIABLES
LET iSqlErr			=	0;
LET	cCodRet			=	'000000';
LET	dFechaHoy		=	'';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_registraerror.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
		
	--VALIDA ERRORES DE PARAMETROS
	IF NVL(pNumTran,0) = 0 OR NVL(pCodRet,0) = 0 OR NVL(pDescripcion,'') = '' OR NVL(pCuenta,'') = '' THEN
		LET cCodRet='000001';		RETURN cCodRet;
	END IF;
	
	--SELECCIONA LA FECHA DEL DIA DE HOY PARA SER INSERTADA EN LA TABLA tf_error
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa='001';
	
	INSERT INTO "informix".tf_error (id_transaccion,codigo_error,descripcion,cuenta_transfer,fecha_insert)
	VALUES (pNumTran,TO_CHAR(pCodRet),TRIM(pDescripcion),TRIM(pCuenta),dFechaHoy);
		
		--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet	= '000002';			RETURN cCodRet;
		END IF;
		
	RETURN cCodRet;	
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 JesÃºs Ernesto Aguilera Inda.',
'DESCRIPCIÃN: Graba errores generados durante la transacciÃ³n 9002 de transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃN: 20140527.1040',
'BASE DE DATOS: bditransfer';

CREATE PROCEDURE "informix".sp_valida_cta_transfer(pEmpresa CHAR(3), pCuenta CHAR(20), pTarjeta CHAR(20), pTipoConsulta INTEGER, pTipoEjeucion INTEGER)
	RETURNING CHAR(5)  AS CodRet,
			  CHAR(20) AS Cuenta,
			  CHAR(20) AS Tarjeta,
			  CHAR(4) AS Producto,
			  CHAR(15) AS Status;
			  
DEFINE cCodRet  	CHAR(5);
DEFINE cCodErr  	CHAR(5);
DEFINE cCodErr2  	CHAR(5);
--DEFINE cCodErr3  	CHAR(5);
DEFINE cCuenta  	CHAR(20);
DEFINE cTarjeta     CHAR(20);  
DEFINE cProductoTar CHAR(4);
DEFINE cStatusTar   CHAR(15);
DEFINE iSecuencia   INTEGER;
DEFINE iSecTar      INTEGER;
DEFINE iSqlErr  	INTEGER;

LET cCodRet  	 = '00000';
LET cCodErr  	 = '00000';
LET cCodErr2  	 = '00000';
--LET cCodErr3  	 = '660';
LET cTarjeta	 = '';
LET cCuenta	     = '';
LET cProductoTar = '';
LET cStatusTar   = '';
LET iSecuencia 	 = 0;
LET iSecTar 	 = 0;
LET iSqlErr  	 = 0;


			  
--SET DEBUG FILE TO '/respaldosbd/felipe/Sps/sp_valida_cta_transfer.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cCuenta,''), NVL(cTarjeta,''), NVL(cProductoTar,''), NVL(cStatusTar,'');
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF TRIM(NVL(pEmpresa,'')) <> ''  AND TRIM(NVL(pCuenta,'')) <> '' AND NVL(pTipoConsulta,0) > 0  AND NVL(pTipoConsulta,0) < 5   AND NVL(pTipoEjeucion,0) > 0 AND NVL(pTipoEjeucion,0) <5 THEN
		
		IF pTipoEjeucion = 1 THEN
		
			SELECT num_tarjeta, cuenta, prodtarjeta, status_tar
			INTO cTarjeta, cCuenta, cProductoTar, cStatusTar
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa  = pEmpresa
			AND cuenta = pCuenta;
			--AND status_tar  = 'A';
			
			IF NVL(cTarjeta, '') <> '' THEN
				LET cCodRet = '626';
			ELSE
				SELECT  producto 
				INTO cProductoTar
				FROM bditransfer:"informix".tf_maecte 
				WHERE empresa = pEmpresa
				AND cuenta_tf = pCuenta;
			END IF;
			
		ELIF  pTipoEjeucion = 3 OR pTipoEjeucion = 4 THEN
		
			SELECT MAX(secuencia) 
			INTO iSecuencia
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa  = pEmpresa
			AND cuenta = pCuenta;
			
			IF pTipoEjeucion = 3 THEN
				LET cCodErr = '639';
				LET cCodErr2 = '641'; 
			ELIF pTipoEjeucion = 4 THEN
				LET cCodErr = '651';
				LET cCodErr2 = '652';
			END IF;
			
			IF pTipoConsulta = 1 OR pTipoConsulta = 2 OR pTipoConsulta = 3 THEN
					
				SELECT num_tarjeta, cuenta, prodtarjeta, status_tar
				INTO cTarjeta, cCuenta, cProductoTar, cStatusTar
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa  = pEmpresa
				AND cuenta = pCuenta
				AND secuencia = iSecuencia;
				
				IF NVL(cTarjeta,'') <> '' THEN
					
					IF TRIM(cProductoTar) <> '8000' THEN
						LET cCodRet = cCodErr2;
					ELSE
						--IF pTipoEjeucion = 4 THEN		
						--	IF TRIM(cStatusTar) <> 'A' THEN
						--		LET cCodRet = cCodErr3;
						--	END IF;
						--END IF;
					END IF;
				ELSE
					LET cCodRet = cCodErr;
				END IF;
				
			ELSE
			
				IF NVL(pTarjeta,'') <> '' THEN
				
					SELECT num_tarjeta, cuenta, prodtarjeta, status_tar, secuencia
					INTO cTarjeta, cCuenta, cProductoTar, cStatusTar, iSecTar
					FROM bdicheq:"informix".sc_tarjeta
					WHERE empresa  = pEmpresa
					AND num_tarjeta = pTarjeta;
					
					IF NVL(cTarjeta,'') <> '' THEN
					
						IF TRIM(cProductoTar) <> '8000' THEN
							LET cCodRet = cCodErr2;
						END IF;
						
						IF cCodRet = '00000' THEN
							IF pTipoEjeucion = 3 THEN
								IF iSecTar <> iSecuencia  THEN
									LET cCodRet = '640';
								END IF;
							END IF;
						END IF;
					ELSE
						LET cCodRet = cCodErr;
					END IF;
				
				ELSE
					LET cCodRet = '00001';
				END IF; 
			END IF;
		ELSE
			LET cCodRet = '00002';
		END IF;
		
		IF TRIM(cStatusTar) = 'A' THEN
			LET cStatusTar  = 'ACTIVA';
		ELIF TRIM(cStatusTar) = 'C' THEN
			LET cStatusTar  = 'CANCELADA';
		END IF;
		
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet, NVL(cCuenta,''), NVL(cTarjeta,''), NVL(cProductoTar,''), NVL(cStatusTar,'');
	
END
END PROCEDURE
DOCUMENT
'FOLIO: 1600',
'AUTOR : 94972834',
'FECHA : 08/05/2014',
'SUSTENTO: Asigna_Tarjeta.pdf, Reposicion_Tarjeta.pdf, Eliminación de tarjeta.pdf',
'SOLICITA: Rodolfo Gomez',
'00001: Falta parametro de entrada obligatorio',
'00002: No se usa en cuenta de fondeo',
'639: El cliente no tiene una tarjeta||     asosiada a la cuenta (para reposicion)',
'641: La tarjeta //|| no pertenece a un producto||        Transfer.(para reposicion)',
'651: No se encuentra registrada||ninguna tarjeta del cliente||     tranfer //. (para cancelacion)',
'652: La tarjeta no pertenece a un producto||               Transfer.(para cancelacion)',
'660: ',
'FOLIO: 1631',
'AUTOR : 94972834',
'FECHA : 04/08/2014',
'SOLICITA: Rodolfo Gomez',
'DESCRIPCION: se cambia el orden entre la validacion de producto y secuenca de tarjeta.',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_canc_abono(
                                        pcAgent_trans_type_code CHAR(10),
										pcAgent_cd              CHAR(6),
										pcUsuario               CHAR(8),
										pcPassword              CHAR(8),
										pcIp_origen             CHAR(15),
										pcSession_id            CHAR(30),
                                        pcServiceName 			CHAR (128),
										pcSystemDate 			CHAR(20),
                                        pcCountryCode 			CHAR (3),
                                        pcBankId 				CHAR (3),
                                        pcOriginalMpsTransactionId CHAR (12),
										pcexternalTransactionId CHAR(30))
	RETURNING
		CHAR (20) AS cReturnCode,
		CHAR (256) AS cErrorDescription,
		CHAR(30) AS CexternalTransactionId;

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cReturnCode CHAR (20);
	DEFINE cErrorDescription CHAR (256);
	DEFINE cExternalTransactionId CHAR (30);
    
    DEFINE cAgent_cd		CHAR	(3);
	DEFINE cUsuario			CHAR	(8);
	DEFINE cPassword		CHAR	(8);
	DEFINE cIp_origen		CHAR	(15);
	DEFINE cId_sesion_act	CHAR	(30);
	DEFINE cNombre_preceso	CHAR	(17);
	DEFINE dtFecha_dia		DATE		;
	DEFINE cOpcode			CHAR	(5);
	--DEFINE cFecha 		CHAR	(8);
	--DEFINE cHora 			CHAR	(6);
	DEFINE cCodRet 			CHAR	(4);
	
	DEFINE vcusuario  		CHAR(8);  
	DEFINE vcTransuc		CHAR(4);
	DEFINE vdFechaHoy 		DATE;
	DEFINE vcFechaFolio		CHAR(6);
	DEFINE vcSufijo			CHAR(3);
	DEFINE vcPrefijo		CHAR(3);
	DEFINE vcHHMMSSFolio	CHAR(9);
	DEFINE vcTansacc  		CHAR(4);
	DEFINE vcCodRetReverso  CHAR(5);
	DEFINE vcFolioSucCargo	CHAR(4);
	DEFINE vcSucursal 		CHAR(4);
	DEFINE vcEmpresa 		CHAR(3);
	
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);
		
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cExternalTransactionId ='0000000';
	
	LET dFechaNueva   = DATE(1);
    LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_canc_abono';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cOpcode = '';
	/*LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/
	LET vcTransuc='';
	LET vcUsuario ='informix';
	LET vdFechaHoy = CURRENT::DATE;
	LET vcSucursal = '9250';
	LET vcEmpresa = '001';
	LET pcSystemDate=replace(pcSystemDate,'/','');


--SET DEBUG FILE TO '/informix/andrescrespo/ccargo.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			let cErrorDescription='Codigo no registrado en catalogo.';
			
			RETURN TRIM(cOpcode), TRIM(cErrorDescription), TRIM(pcExternalTransactionId);
        END IF;
    END EXCEPTION;



SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    
    IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?' 
			OR NVL(pcOriginalMpsTransactionId,'?')= '?' OR NVL(pcexternalTransactionId,'?')= '?'
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
			
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and  fecha_insert = dtFecha_dia;

				IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044' )  THEN 
					IF pcCountryCode='484' THEN		
						IF length(pcOriginalMpsTransactionId)=12 THEN
							IF (length(pcexternalTransactionId)>=6 and length(pcexternalTransactionId)<=30)  THEN
								IF cAgent_cd = pcAgent_cd THEN
									IF cUsuario = pcUsuario   THEN
										IF cPassword = pcPassword THEN
											IF cIp_origen = pcIp_origen THEN
												IF cId_sesion_act::CHAR(30) = pcSession_id THEN
													IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
														IF length(pcSystemDate)>1 THEN
															LET cDia=SUBSTR(pcSystemDate,1,2);
															LET cMes=SUBSTR(pcSystemDate,3,2);
															LET cAnio=SUBSTR(pcSystemDate,5,4);
															LET dFechaNueva = mdy(cMes,cDia,cAnio);
															IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
												
																execute procedure bdicred:"informix".reversion(vcEmpresa, vcSucursal, vcUsuario , trim(pcexternalTransactionId), 'R') 
																into vcCodRetReverso;
															
																IF vcCodRetReverso ::INTEGER != 0 THEN
																	LET cReturnCode = '9996';
																	LET cErrorDescription = "Error al generar la reversión.";	
																ELSE
																	RETURN trim(cReturnCode), trim(cErrorDescription), trim(pcexternalTransactionId);
																END IF;
																
															ELSE
																LET cReturnCode = '9996';
																LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";	
															END IF;
															
														ELSE
															LET cReturnCode = '9996';
															LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";	
														END IF;
													ELSE
														LET cReturnCode = '9975';
														LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
													END IF;	
												ELSE
													LET cReturnCode = '9975';
													LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
												END IF;
											ELSE
												LET cReturnCode = '9976';
												LET cErrorDescription = "Error autenticación. IP origen inválida ";
											END IF;
										ELSE
											LET cReturnCode = '9979';
											LET cErrorDescription = " Error autenticación. Password no existe.";
										END IF;
									ELSE
										LET cReturnCode = '9980';
										LET cErrorDescription = 'Error autenticación. Usuario no existe';
									END IF;
								ELSE
									LET cReturnCode = '9998';
									LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";	
								END IF;
							ELSE
								LET cReturnCode ='9996';
								LET cErrorDescription = " Error de parametros de entrada. ExternalTransactionId";
							END IF;
						ELSE
							LET cReturnCode ='9996';
							LET cErrorDescription = " Error de parametros de entrada. OriginalMpsTransactionId";
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. CountryCode";
					END IF;	
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. BankId";
				END IF;	
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;
	LET pcExternalTransactionId='';
	RETURN TRIM(cReturnCode), TRIM(cErrorDescription), TRIM(pcExternalTransactionId);
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Reversion de un abono a TDC o debito ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_cancelacion_cargo(
                                        pcAgent_trans_type_code CHAR(10),
										pcAgent_cd              CHAR(6),
										pcUsuario               CHAR(8),
										pcPassword              CHAR(8),
										pcIp_origen             CHAR(15),
										pcSession_id            CHAR(30),
                                        pcServiceName 			CHAR (128),
										pcSystemDate 			CHAR (15),
                                        pcCountryCode 			CHAR (3),
                                        pcBankId 				CHAR (3),
                                        pcOriginalMpsTransactionId CHAR (12),
										pcexternalTransactionId CHAR(15))
	RETURNING
		CHAR (20) AS cReturnCode,
		CHAR (256) AS cErrorDescription,
		CHAR(30) AS CexternalTransactionId;

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  				INTEGER;
	DEFINE cPCodRet					CHAR(5);
	DEFINE cReturnCode 				CHAR (20);
	DEFINE cErrorDescription 		CHAR (256);
	DEFINE cExternalTransactionId 	CHAR (30);

    DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE	;
	DEFINE cOpcode			CHAR(5);
	--DEFINE cFecha 		CHAR(8);
	--DEFINE cHora 			CHAR(6);
	DEFINE cCodRet 			CHAR(4);


	DEFINE vcusuario  		CHAR(4);
	DEFINE vcTransuc		CHAR(4);
	DEFINE vdFechaHoy 		DATE;
	DEFINE vcTansacc  		CHAR(4);
	DEFINE vcCodRetReverso  CHAR(5);
	DEFINE vcTranccTemp		CHAR(4);
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);
	DEFINE vcFolioSucCargo	CHAR(30);
	DEFINE cCodRet1			CHAR(4);
	DEFINE 	vcSucursal 		CHAR(4);
	DEFINE vcEmpresa 		CHAR(3);

	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cExternalTransactionId ='0000000';
	LET dFechaNueva   = DATE(1);
	LET vcSucursal= '9250';
	LET vcEmpresa = '001';
	
    LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cOpcode = '';
	/*LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/
	LET vcUsuario ='informix';
	LET vdFechaHoy = CURRENT::DATE;
	LET cCodRet1='';
	LET vcFolioSucCargo='';
	LET pcSystemDate=replace(pcSystemDate,'/','');

--SET DEBUG FILE TO '/informix/andrescrespo/sp_dmcargo.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';

			RETURN TRIM(cOpcode), TRIM(cErrorDescription), TRIM(pcexternalTransactionId);
        END IF;
    END EXCEPTION;



--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 3;

    IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			/*OR length(pcSystemDate)< 14*/ OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			OR NVL(pcOriginalMpsTransactionId,'?')= '?'  or NVL(pcexternalTransactionId,'?')='?'
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario)  AND activa = 'S' ) THEN
				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario)  and  fecha_insert = dtFecha_dia;

				IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137'  or pcBankId='044')  THEN
					IF pcCountryCode='484' THEN
						IF length(pcOriginalMpsTransactionId)=12 THEN
							IF (length(pcexternalTransactionId)>=6 and length(pcexternalTransactionId)<=15) THEN
								IF cAgent_cd = pcAgent_cd THEN
									IF cUsuario = pcUsuario   THEN
										IF cPassword = pcPassword THEN
											IF cIp_origen = pcIp_origen THEN
												IF cId_sesion_act::CHAR(30) = pcSession_id THEN
													IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
														IF length(pcSystemDate)>1 THEN
															LET cDia=SUBSTR(pcSystemDate,1,2);
															LET cMes=SUBSTR(pcSystemDate,3,2);
															LET cAnio=SUBSTR(pcSystemDate,5,4);
															LET dFechaNueva = mdy(cMes,cDia,cAnio);
															IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
					
																execute procedure bdicheq:"informix".reversion(vcEmpresa, vcSucursal, vcUsuario , trim(pcexternalTransactionId), 'R')
																into vcCodRetReverso;
		
																IF vcCodRetReverso ::INTEGER != 0 THEN
																	LET cReturnCode = '9996';
																	LET cErrorDescription = "Error al generar la reversión.";	
																ELSE
																	RETURN trim(cReturnCode), trim(cErrorDescription), trim(pcexternalTransactionId);
																END IF;
																
															ELSE
																LET cReturnCode = '9996';
																LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
															END IF;
		
														ELSE
															LET cReturnCode = '9996';
															LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
														END IF;
													ELSE
														LET cReturnCode = '9975';
														LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
													END IF;
												ELSE
													LET cReturnCode = '9975';
													LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
												END IF;
											ELSE
												LET cReturnCode = '9976';
												LET cErrorDescription = "Error autenticación. IP origen inválida ";
											END IF;
										ELSE
											LET cReturnCode = '9979';
											LET cErrorDescription = " Error autenticación. Password no existe.";
										END IF;
									ELSE
										LET cReturnCode = '9980';
										LET cErrorDescription = 'Error autenticación. Usuario no existe';
									END IF;
								ELSE
									LET cReturnCode = '9998';
									LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
								END IF;
							ELSE
								LET cReturnCode ='9996';
								LET cErrorDescription = " Error de parametros de entrada. externalTransactionId";
							END IF;
						ELSE
							LET cReturnCode ='9996';
							LET cErrorDescription = " Error de parametros de entrada. OriginalMpsTransactionId";
						END IF;	
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. CountryCode";
					END IF;
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. pcBankId";
				END IF;
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;
RETURN TRIM(cReturnCode), TRIM(cErrorDescription), TRIM(pcexternalTransactionId);
END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Reversion de un cargo a tarjeta de debito',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_consulta_udi(pcAgent_trans_type_code CHAR(10),
											pcAgent_cd              CHAR(6),
											pcUsuario               CHAR(8),
											pcPassword              CHAR(8),
											pcIp_origen             CHAR(15),
											pcSession_id            CHAR(30),
											pcServiceName 			CHAR(128), 	
											pcSystemDate 			char(20), 	
											pcCountryCode 			CHAR(3), 
											pcBankId 				CHAR(3),	
											pcAccessMethod   		CHAR(3))	
RETURNING 	CHAR(5) AS COD_ERROR,	
			CHAR(100) AS DESC_ERROR,
			DECIMAL(7,3) AS UDI;

---DECLARACION DE VARIABLES
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(4);
DEFINE cDesCodRet	CHAR (300);
DEFINE dPrecio		DECIMAL(7,3);
DEFINE cCotRetSP   	CHAR(5);
DEFINE cMsgRetSP   	CHAR(300);
DEFINE dtFechaUdi   CHAR(10);
define cDia         CHAR(2);
define cMes         CHAR(2);
define cAnio        CHAR(4);
define dFechaNueva  CHAR(10);
define dFechaNueva1 CHAR(10);

DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE dtFecha_dia		DATE	;
--DEFINE cFecha 		CHAR(8);
--DEFINE cHora 			CHAR(6);
--DEFINE cOpcode			CHAR(4);

---INICIALIZACION DE VARIABLES
LET iSqlErr       = 0;
LET cCodRet       = 'S';
LET cDesCodRet    = 'Proceso Exitoso.';
LET dPrecio	  	  = 0;
LET cCotRetSP     = '00000';
LET cMsgRetSP     = '';
LET dtFechaUdi    = DATE(1);
let cDia          = '';
let cMes          = '';
let cAnio         = '';
let dFechaNueva   = DATE(1);
let dFechaNueva1   = DATE(1);
LET pcSystemDate=REPLACE(pcSystemDate,'/','');

LET cAgent_cd ='';
LET cUsuario ='';
LET cPassword ='';
LET cIp_origeN ='';
LET cId_sesion_act ='';
LET cNombre_preceso = 'sp_consulta_udi';
LET dtFecha_dia   = CURRENT::DATE;

/*LET cOpcode = '';
LET cDescr_mensaje = '';
LET cDescr_completa_mensaje = '';*/


 --SET DEBUG FILE TO '/informix/andrescrespo/sp_UDI.out';
 --TRACE ON;

	BEGIN
    ON EXCEPTION SET iSqlErr
		IF 	iSqlErr <> 0 THEN
			LET cCodRet = 'O';
			let cDesCodRet='Codigo no registrado en catalogo.';
			RETURN trim(cCodRet),TRIM(cDesCodRet),NVL(dPrecio,0.00);
		END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	--------------VALIDACIÓN DE PARAMETROS-------------------------
		IF NVL(pcServiceName,'?') = '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?' OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			/*OR length(pcSystemDate)< 10*/ OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?' THEN
			LET cCodRet ='O';
			LET cDesCodRet = "9996-Error de parametros de entrada";
		ELSE 
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes		
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN
			
				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and usuario=trim(pcusuario) AND fecha_insert = dtFecha_dia;
							
					IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' OR pcBankId='044')  THEN
						IF pcCountryCode='484' THEN
							IF pcAccessMethod='115' THEN		
								IF cAgent_cd = pcAgent_cd THEN
									IF cUsuario = pcUsuario   THEN
										IF cPassword = pcPassword THEN
											IF cIp_origen = pcIp_origen THEN
												IF cId_sesion_act::CHAR(30) = pcSession_id THEN
													IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
															IF length(pcSystemDate)>1 THEN
																LET cDia=SUBSTR(pcSystemDate,1,2);
																LET cMes=SUBSTR(pcSystemDate,3,2);
																LET cAnio=SUBSTR(pcSystemDate,5,4);
																LET dFechaNueva = mdy(cMes,cDia,cAnio);
																IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
															
																	EXECUTE PROCEDURE intercard:"informix".sp_obtener_udi('001',dFechaNueva)
																	INTO cCotRetSP,dprecio,dtFechaUdi;
														
																	IF cCotRetSP::INTEGER != 0 THEN
																		LET cCodRet = 'O'; 
																		LET cDesCodRet = 'Error al ejecutar sp_obtener_udi';
																		RETURN trim(cCodRet),TRIM(cDesCodRet),NVL(dPrecio,0.00);
																	END IF;
																	
																		IF dPrecio = 0.0 OR dPrecio IS NULL THEN
																		LET cCodRet = 'O';
																		LET cDesCodRet = "9981-Parámetro no encontrado, No se encontro valor UDI en la base de datos.";
																		END IF;
															
																		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
																			LET cCodRet = "O";
																			LET cDesCodRet = "9996-No se encontro valor UDI en la base de datos.";
																			RETURN trim(cCodRet),TRIM(cDesCodRet),NVL(dPrecio,0.00);
																		END IF;
			
																ELSE
																	LET cCodRet = 'O';
																	LET cDesCodRet = "9996-Consulta no exitosa. Fecha inválida.";	
																END IF;
															ELSE
																LET cCodRet = 'O';
																LET cDesCodRet = "9996-Consulta no exitosa. Fecha inválida.";	
		
															END IF;
													ELSE
														LET cCodRet = 'O';
														LET cDesCodRet = "9975-Error autenticación. Id de sesión inválido.";
													END IF;	
												ELSE
													LET cCodRet = 'O';
													LET cDesCodRet = "9975-Error autenticación. Id de sesión inválido.";
												END IF;
											ELSE
												LET cCodRet = 'O';
												LET cDesCodRet = "9976-Error autenticación. IP origen inválida ";
											END IF;
										ELSE
											LET cCodRet = 'O';
											LET cDesCodRet = " 9979-Error autenticación. Password no existe.";
										END IF;
									ELSE
										LET cCodRet = 'O';
										LET cDesCodRet = '9980-Error autenticación. Usuario no existe';
									END IF;
								ELSE
									LET cCodRet = 'O';
									LET cDesCodRet = "9998-Autenticación fallida. Código de agente inválido.";	
								END IF;
							ELSE
								LET cCodRet = 'O';
								LET cDesCodRet = "9996-Error de parametros de entrada. AccessMethod";	
							END IF;
						ELSE
							LET cCodRet = 'O';
							LET cDesCodRet = "9996-Error de parametros de entrada. CountryCode";	
						END IF;
					ELSE
						LET cCodRet = 'O';
						LET cDesCodRet = "9996-Error de parametros de entrada. BankId";	
					END IF;
			ELSE
				LET cCodRet ='O';
				LET cDesCodRet = "9982-Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;
	
	RETURN trim(cCodRet),TRIM(cDesCodRet),NVL(dprecio,0.00);

END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Consulta del valor udi ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_cpago(  	pcAgent_trans_type_code CHAR(10),
                                        pcAgent_cd 				CHAR(6),
                                        pcUsuario 				CHAR(8),
                                        pcPassword 				CHAR(8),
                                        pcIp_origen 			CHAR(15),
                                        pcSession_id 			CHAR(30),
                                        pcServiceName 			CHAR(128),
                                        pcSystemDate 			CHAR(15),
                                        pcCountryCode 			CHAR(3),
                                        pcBankId 				CHAR(3),
                                        pcAccessMethod 			CHAR(3),
                                        pcIdTransaccion 		CHAR(30),
                                        pcTipoOperacion 		CHAR(1))
	RETURNING
		CHAR (100) AS cErrorDescription,
		CHAR (30) AS cIdTransaccion,
		CHAR (40) AS cIdTransaccionReverso;

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cReturnCode CHAR (5);
	DEFINE cErrorDescription CHAR (100);
	DEFINE cIdTransaccion CHAR (30);
	DEFINE cIdTransaccionReverso CHAR (40);

	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE	;
	--DEFINE cFecha 		CHAR(8);
	--DEFINE cHora 			CHAR(6);
	DEFINE cCodRet 			CHAR(4);


	DEFINE vcTranccTemp		CHAR	(4);
	DEFINE vcTransuc		CHAR	(4);
	DEFINE viCheque         CHAR	(4);
	DEFINE vmMonto          MONEY(16,2);
	DEFINE vcDivisa         CHAR	(4);
	DEFINE vcReferencia     CHAR	(20);
	DEFINE vcNoTarjeta      CHAR	(18);
	DEFINE vcSucursal		CHAR	(4);
	DEFINE vcNocliente    	CHAR	(10);
	DEFINE cCodRet1			char	(5);
	DEFINE vcFolioSucCargo 	char	(30);

	DEFINE vcTansacc  		CHAR(4);
	DEFINE vcodretTemp    	CHAR(5);
    DEFINE vctranret   		CHAR(4);
	DEFINE vcusuario  		CHAR(8);
	DEFINE vdfechoy 		DATE;
	DEFINE vmsdodisp		MONEY(16,2);
	define vmontoret		MONEY(16,2);


	DEFINE cTipoord			CHAR(2);
	DEFINE cTipobenef		CHAR(2);
	DEFINE cMerror			CHAR(200);
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);



	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '00000';
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cIdTransaccion = pcIdTransaccion;
	LET cIdTransaccionReverso= '0';

	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_canc_cargo';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cCodRet1 = '';
	LET vcFolioSucCargo='';
	/*LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/
	LET vcTransuc='8501'; --sucursal
	LET vcUsuario ='informix';
	LET vcTansacc = '002';
	LET dFechaNueva   = DATE(1);
	LET pcSystemDate=replace(pcSystemDate,'/','');

--SET DEBUG FILE TO '/informix/andrescrespo/cpago.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET cReturnCode = '500';
			LET cPCodRet = iSqlErr;
			let cErrorDescription='Codigo no registrado en catalogo.';

			SELECT descripcion
			INTO  cErrorDescription
			FROM  tf_codret
			WHERE cod_error = cReturnCode;

            RETURN trim(cReturnCode)||"-"||trim(cErrorDescription), trim(cIdTransaccion), trim(cIdTransaccionReverso);
		END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

		

	RETURN trim(cReturnCode)||"-"||trim(cErrorDescription), trim(cIdTransaccion), trim(cIdTransaccionReverso);

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: dummy',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_dm_notdep(pcAgent_trans_type_code CHAR(10),
                                        pcAgent_cd CHAR(6),
                                        pcUsuario CHAR(8),
                                        pcPassword CHAR(8),
                                        pcIp_origen CHAR(15),
                                        pcSession_id CHAR(30),
                                        pcServiceName CHAR (128), 
                                        pcSystemDate CHAR (15), 
                                        pcCountryCode CHAR (3), 
                                        pcBankId CHAR (3), 
                                        pcAccessMethod CHAR (3),
                                        pcBankCustomerNumber CHAR (12)) 
	RETURNING
		CHAR (20) AS cReturnCode,
		CHAR (256) AS cErrorDescription;
	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cReturnCode CHAR (20);
	DEFINE cErrorDescription CHAR (100);
			
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
				
--SET DEBUG FILE TO '/informix/gaby/sp_dm_notdep.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET cReturnCode = '500';
			LET cPCodRet = iSqlErr;
	  	
			SELECT descripcion 
			INTO  cErrorDescription
			FROM  tf_codret 
			WHERE cod_error = cReturnCode;
						
            RETURN cReturnCode, cErrorDescription;
        END IF;
    END EXCEPTION;
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;
	
	RETURN trim(cReturnCode),trim(cErrorDescription);
	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: dummy ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_dm_renapo(
pcAgent_trans_type_code CHAR(10),
pcAgent_cd CHAR(6),
pcUsuario CHAR(8),
pcPassword CHAR(8),
pcIp_origen CHAR(15),
pcSession_id CHAR(30),
pcServiceName CHAR (128), 
pcSystemDate CHAR (15), 
pcCountryCode CHAR (3), 
pcBankId CHAR (3), 
pcAccessMethod CHAR (3),
pcMedioAcceso CHAR (1),
pcApellidoPaterno CHAR (50),
pcApellidoMaterno CHAR (50),
pcNombre CHAR (50),
pcFechaNacimiento CHAR (15),
pcNumCelular CHAR (12),
pcNumTarjeta CHAR (16),
pcCalle CHAR (100),
pcNumeroExterior CHAR (15),
pcNumeroInterior CHAR (15),
pcColonia CHAR (100),
pcEstado CHAR (100),
pcMunicipio CHAR (50),
pcCodigoPostal CHAR (8),
pcSexo CHAR(1),
pcRfc CHAR (13),
pcEntidadNacimiento CHAR (50)) 
	
RETURNING
		CHAR (5) AS cCodigoError,
		CHAR (256) AS cErrorDescription,
		CHAR (50) AS cApellidoPaterno,
		CHAR (50) AS cApellidoMaterno,
		CHAR (50) AS cNombre,
		CHAR (15) AS cfechaNacimiento,
		CHAR (12) AS cNumCelular,
		CHAR (16) AS cNumeroTarjeta,
		CHAR (18) AS cCurp,
		CHAR (10) AS cFechaValidacionRenapo,
		CHAR (3) AS cStatusRenapo;
		
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cCodigoError CHAR (5);
	DEFINE cDescripcionError CHAR (256);
	DEFINE cApellidoPaterno CHAR (50);
	DEFINE cApellidoMaterno CHAR (50);
	DEFINE cNombre CHAR (50);
	DEFINE cfechaNacimiento CHAR (15);
	DEFINE cNumCelular CHAR (12);
	DEFINE cNumeroTarjeta CHAR (16);
	DEFINE cCurp CHAR (18);
	DEFINE cFechaValidacionRenapo CHAR (10);
	DEFINE cStatusRenapo CHAR (3);
	
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigoError = '0';
	LET cDescripcionError = 'Consulta exitosa';
	LET cApellidoPaterno='';
        LET cApellidoMaterno='';
	LET cNombre='';
	LET cfechaNacimiento='00/00/00';
	LET cNumCelular='';
	LET cNumeroTarjeta='';
	LET cCurp='';
	LET cFechaValidacionRenapo='00/00/00';
	LET cStatusRenapo='';
		
	
				
--SET DEBUG FILE TO '/informix/gaby/sp_dm_renapo.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET cCodigoError = '500';
			LET cPCodRet = iSqlErr;
			LET cDescripcionError='codigo no dado de alta';
			RETURN trim(cCodigoError), trim(cDescripcionError),cApellidoPaterno,cApellidoMaterno, cNombre,cfechaNacimiento,cNumCelular,cNumeroTarjeta,cCurp,cFechaValidacionRenapo,cStatusRenapo;

        END IF;
    END EXCEPTION;
	
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;
	
	RETURN trim(cCodigoError), trim(cDescripcionError),cApellidoPaterno,cApellidoMaterno, cNombre,cfechaNacimiento,cNumCelular,cNumeroTarjeta,cCurp,cFechaValidacionRenapo,cStatusRenapo;
	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: dummy ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_tipo_cambio(	pcAgent_trans_type_code CHAR(10),
											pcAgent_cd 				CHAR(6),
											pcUsuario 				CHAR(8),
											pcPassword 				CHAR(8),
											pcIp_origen 			CHAR(15),
											pcSession_id 			CHAR(30),
											pcServiceName 			CHAR (128), 
											pcSystemDate 			CHAR (20), 
											pcCountryCode 			CHAR (3), 
											pcBankId 				CHAR (3),
											pcAccessMethod 			CHAR (3))
	RETURNING	
		CHAR (20) AS cReturnCode,
		CHAR (256) AS cErrorDescription,
		DECIMAL(7,3) AS dAmount;
	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  		INTEGER;
	DEFINE cPCodRet 		CHAR(5);
	DEFINE cReturnCode 		CHAR(20);
	DEFINE cErrorDescription CHAR(256);
	DEFINE dAmount 			DECIMAL(7,3);
	
	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE;
	DEFINE cOpcode			CHAR(5);
	--DEFINE cFecha 		CHAR(8);
	--DEFINE cHora 			CHAR(6);
	DEFINE cCodRet 			CHAR(4);
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);
	DEFINE cprueba			char(20);
	
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET dAmount =0;
	LET dFechaNueva   = DATE(1);
	
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_tipo_cambio';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0';
	LET cOpcode = '';
	/*LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/
	LET pcSystemDate=replace(pcSystemDate,'/','');

	
--SET DEBUG FILE TO '/informix/andrescrespo/sp_tipo_cambio.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';
		
			RETURN trim(cOpcode),trim(cErrorDescription),NVL(dAmount,0.00);	
        END IF;
    END EXCEPTION;
	
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--------------VALIDACIÓN DE PARAMETROS-------------------------
		IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			/*OR length(pcSystemDate)< 14*/ OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'  then
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
		ELSE 
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes		
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario =trim(pcusuario) AND activa = 'S' ) THEN
			
				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario =trim(pcusuario) and  fecha_insert = dtFecha_dia;
							
				IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044')  THEN
					IF pcCountryCode='484' THEN		
						IF cAgent_cd = pcAgent_cd THEN
							IF cUsuario = pcUsuario   THEN
								IF cPassword = pcPassword THEN
									IF cIp_origen = pcIp_origen THEN
										IF cId_sesion_act::CHAR(30) = pcSession_id THEN
											IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
													IF length(pcSystemDate)>1 THEN
														let cprueba=pcSystemDate;
														LET cDia=SUBSTR(pcSystemDate,1,2);
														LET cMes=SUBSTR(pcSystemDate,3,2);
														LET cAnio=SUBSTR(pcSystemDate,5,4);
														LET dFechaNueva = mdy(cMes,cDia,cAnio);
														IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
															
															SELECT PRECIO_COMPRA 
															INTO dAmount
															FROM bdinteg:si_tpcambio 
															WHERE divisa = '02' and empresa='001' and clase_tpcambio='O'
															AND fecha_tpcambio in(select MAX(fecha_tc) from bdinteg:si_histdiv);
															
																										
															IF dAmount = 0.0 OR dAmount IS NULL THEN
																LET cReturnCode = '9981';
																LET cErrorDescription = "Parámetro no encontrado, valor cambio";
															END IF;
							
														ELSE
															LET cReturnCode = '9996';
															LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";	
														END IF;
														
													ELSE
														LET cReturnCode = '9996';
														LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";	
													END IF;
											ELSE
												LET cReturnCode = '9975';
												LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
											END IF;	
										ELSE
											LET cReturnCode = '9975';
											LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
										END IF;
									ELSE
										LET cReturnCode = '9976';
										LET cErrorDescription = "Error autenticación. IP origen inválida ";
									END IF;
								ELSE
									LET cReturnCode = '9979';
									LET cErrorDescription = " Error autenticación. Password no existe.";
								END IF;
							ELSE
								LET cReturnCode = '9980';
								LET cErrorDescription = 'Error autenticación. Usuario no existe';
							END IF;
						ELSE
							LET cReturnCode = '9998';
							LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";	
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. CountryCode";
					END IF;	
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. BankId";
				END IF;	
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;
		
	
	RETURN trim(cReturnCode),trim(cErrorDescription),NVL(dAmount,0.00);
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Realiza consulta de tipo de cambio ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

create procedure "informix".sp_transfer_conadmin_capture 
(
piconsecutivo integer, psnomarchivo_out char (50),psnumtarjeta char(30), pssecuencia_out char(6),
pmonto_out money,psfecha_out char(6), psintegridad char(1), psaplicado char(6),psmsn_error char(130),
vsstatus_cnc char (1),pscve_usuario char(10)
)
returning char (1);

--Variables de control de errores 
define visqlerr integer;
define vscodret2 char(5);
define vsmensaje_respuesta varchar(250);

--Variables de trabajo
define vsnomarchivo_in char (50);
define vdfecha_proceso date ;
define vssecuencia_in char (6);
define vpmonto_in money ;
define vsfecha_in char (6);
define viconsecutivo integer;
define vicount integer;

define vsdescripcion_cnc char(200);
define vsdescripcion_cnc2 char(200);
define pssecuenciaextendida char(16);

define vsflagencontrado char (1);

begin
	on exception set visqlerr
		let vsmensaje_respuesta = vsmensaje_respuesta||' Error sp_transfer_conadmin '||visqlerr;
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( '3', vsmensaje_respuesta, pscve_usuario) into vscodret2;
		let vsstatus_cnc='E';
		return 	vsstatus_cnc;
	end exception;
	
--set debug file to "/informix/HomeInformix/sp_transfer_conadmin.out";
--trace on;

let visqlerr  = 0;

let vsnomarchivo_in= '';
let vdfecha_proceso = today ;
let vssecuencia_in = '';
let vpmonto_in = 0.0 ;
let vsfecha_in = '';
let pssecuenciaextendida='';
let vicount = 0;

let vsdescripcion_cnc = '';
let vsdescripcion_cnc2 = '';
let vsflagencontrado = 'V';

Let psnumtarjeta = substr (psnumtarjeta, 5,16);

let vsmensaje_respuesta = 'Consulta si_fechas';
--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
set isolation to dirty read;
	select limit 1 fecha_hoy into vdfecha_proceso from bdinteg:"informix".si_fechas;
	
If (psaplicado = '000000' or trim(psaplicado) = '0' or trim(psaplicado) = '' or psaplicado is null ) THEN
		
	Let psaplicado = 'V';
else 
	
	Let psaplicado = 'F';
	Let vsdescripcion_cnc2 = ' El registro no se aplico por :'||trim(psmsn_error);
end if;

if   (psnumtarjeta = '' or psnumtarjeta is null or pssecuencia_out = '' or pssecuencia_out is null ) then

	Let vsdescripcion_cnc = 'No se recibieron los datos completos del registro OutCapture. ';
	let vsflagencontrado = 'F';
	
elif (psintegridad != 'V') then 
	Let vsdescripcion_cnc = 'Se encontro un error de integridad en registro OutCapture. ';
	let vsflagencontrado = 'F';
else 
	
	let vsmensaje_respuesta = 'Consulta tf_incapture';
	
	set isolation to dirty read;
	select count(nombre_archivo_envio) into vicount from bditransfer:tf_incapture
	where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';
	
	if (vicount = 0) then 
		Let vsdescripcion_cnc = 'No se encontro registro incapture relacionado.';
		let vsflagencontrado = 'F';
	
	elif (vicount = 1) then 
	
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
		into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
		from bditransfer:tf_incapture
		where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';

		if (vpmonto_in != pmonto_out and vsfecha_in != psfecha_out) then 
			Let vsdescripcion_cnc = 'Existen diferencias en monto y fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		elif (vpmonto_in != pmonto_out ) then
				Let vsdescripcion_cnc = 'Existen diferencias en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		elif ( vsfecha_in != psfecha_out) then
				Let vsdescripcion_cnc = 'Existen diferencias en fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		ELSE
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
	else 
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
		into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
		from bditransfer:tf_incapture
		where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P' and (nvl(monto,0)::money/100)=pmonto_out;
		
		if (vsnomarchivo_in='' or vsnomarchivo_in is null) then 
			set isolation to dirty read;
			select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
			into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
			from bditransfer:tf_incapture
			where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';
			
			Let vsdescripcion_cnc = 'Conciliado con diferencias a validar, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;		
			
		elif ( vsfecha_in != psfecha_out) then
				Let vsdescripcion_cnc = 'Existen diferencias en fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		else 
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
		
	
	end if;
	
End if; 
let vsmensaje_respuesta = 'Insert tf_conadmin';
--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
	INSERT INTO bditransfer:"informix".tf_conadmin_capture
	(
		--consecutivo
		fecha_proceso,
		numtarjeta,
		secuencia,
		secuenciaextendida,
		descripcion_concilia,
		nombrearchivo_incapture,
		fecha_mov_incapture,
		monto_incapture,
		nombrearchivo_outcapture,
		fecha_mov_outcapture,
		monto_outcapture,
		integridad,
		aplicado_transfer,
		encontrado
	)
	VALUES
	(
		vdfecha_proceso,
		TRIM(NVL(psnumtarjeta,'')),
		TRIM(NVL(pssecuencia_out,'')),
		TRIM(NVL(pssecuenciaextendida,'')),
		trim(vsdescripcion_cnc)||trim(vsdescripcion_cnc2),
		TRIM(NVL(vsnomarchivo_in,'')),
		TRIM(NVL(vsfecha_in,'')),
		NVL(vpmonto_in,''),
		TRIM(NVL(psnomarchivo_out,'')),
		TRIM(NVL(psfecha_out,'')),
		NVL(pmonto_out,''),
		psintegridad,
		psaplicado,
		vsflagencontrado
	);
	
If (vsflagencontrado = 'V') then
	
	Update bditransfer:tf_incapture set status_cnc = 'V' ,nombre_archivo_cnc = trim(psnomarchivo_out)
	where consecutivo=viconsecutivo ;
	
	let vsstatus_cnc='V';
	
End if;
	
let vsmensaje_respuesta = 'Proceso exitoso';

return 	vsstatus_cnc;

end
end procedure
DOCUMENT
'AUTOR: Juan Fco. Ponce Damian',
'Proyecto: Proyecto Transfer',
'Solicito: Luis Antonio Gomez',
'Descripcion: Proceso conciliación administrativa transfer InCapture Vs OutCapture',
'Fecha: 2014/09/18',
'BD: BdiTransfer';

CREATE PROCEDURE "informix".sp_transfer_esnumerico ( psCadena CHAR (30))

RETURNING CHAR (1) AS Numerico ;

--****************************************************************************************************
-- DESCRIPCION:  SP CLONADO QUE VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR : Casanova Edeza Hector Juan // Clonador Ricardo Reséndiz Martinez
-- FECHA : 04/04/2014
-- BD: bditarjeta
-- SISTEMA : Reingenieria de la Conciliacion Automática
-- MODIFICADO : SIN MODIFICACIONES
--***************************************************************************************************

/*  definicion de variables */
define vsrespuesta char (1) ;
define visqlerr integer ;
/* inicializacion de variables */


begin

	on exception set visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		if visqlerr = -1213 then
			let vsrespuesta = 'F' ;
		else
			let vsrespuesta = ' ' ;
		end if;

		return vsrespuesta ;

	end exception;

let vsrespuesta = 'F' ;
let visqlerr = 0;


	if (pscadena >= 0) then
		let vsrespuesta = 'V';
	else
		let vsrespuesta = 'F';
	end if;

	return vsrespuesta ;

end

end procedure
document
'autor: casanova edeza hector juan // clonador ricardo resendiz martinez',
'proyecto: proceso de validacion  de transfer',
'solicito: jose luis puebla',
'descripcion: verifica que la cadena de entrada solamente contenga numeros.',
'fecha: 2014/07/04',
'version: 20140704.1630',
'bd: bditransfer';

create procedure "informix".sp_transfer_guardabitacora(
	pselemento integer,
	psactividad char(150),
	pscve_usuario char(10)
)

	returning char(5) as retorno;

	/*definicion de variables*/

	/*variables de retorno*/
	define visqlerr integer ;
	define vssqlerr char(5);

	/*inicializacion de variables*/

	let visqlerr = 0;
	let vssqlerr = '00000';

	begin

		on exception set visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				let vssqlerr = visqlerr;
				return vssqlerr;

		end exception;

--	set debug file to "/informix/HomeInformix/rrm/sp_transfer_bitacora.out";
--	trace on;

	set lock mode to wait 3;

	insert into bditransfer:"informix".tf_bitacora_transfer (elemento, fecha_hora, actividad, cve_usuario)
		values (	pselemento,
					(select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals),
					psactividad,
					pscve_usuario
				);

		let vssqlerr = '00000';

	return vssqlerr;


end

end procedure
DOCUMENT
'autor: Ricardo Reséndiz Martinez',
'proyecto: Integracion de Transfer ',
'solicito: jose luis puebla',
'descripcion: guarda bitacora.',
'fecha: 2014/07/23',
'version: 20110723.1720',
'bd: bditransfer';

CREATE PROCEDURE "informix".sp_consulta_detalle_compensacion(pConsulta INTEGER,pTipoConsulta CHAR(2),pFechaConsulta DATE)

--RETORNOS
RETURNING
CHAR(5) 	AS	CodigoRetorno,
CHAR(100)	AS	MensajeRetorno,
CHAR(16)	AS 	Num_Cuenta,
CHAR(6) 	AS	Secuencia,
CHAR(6) 	AS	Fecha_Alta,
MONEY(14,2)	AS	Monto_total_operaciones,
CHAR(9) 	AS 	Id_Negocio,
CHAR(1)		AS	Estatus;

--dEFINICION DE VARIABLES

DEFINE	cCodigoRetorno       CHAR(5);
DEFINE 	cMensajeRetorno		 CHAR(100);
DEFINE	cCuenta		  		 CHAR(16);
DEFINE	cSecuencia		 	 CHAR(6);
DEFINE	cFechaAlta	 		 CHAR(6);
DEFINE	mMontoTotalOperacion MONEY(14,2);
DEFINE	cIdNegocio			 CHAR(9);
DEFINE	cStatus			 	 CHAR(1);
DEFINE  cCdtoDeb		     CHAR(1);
DEFINE  cFecha				 CHAR(6);
DEFINE  iSqlErr				 INTEGER;


--INICIALIZACION DE VARIABLES
LET	cCodigoRetorno 		 = "00000";	
LET cMensajeRetorno 	 = "EXITO";	
LET	cCuenta	  			 = "";
LET cSecuencia		     = "";
LET cFechaAlta	         = "";	
LET mMontoTotalOperacion = 0.00;
LET cIdNegocio			 = "";
LET cStatus			     = "";
LET cCdtoDeb			 = "";
LET cFecha				 = "";
LET iSqlErr				 = 0;	
		
	 
--SET DEBUG FILE TO "/respaldosbd/raulpacheco/sp_consulta_detalle_compensacion.out"; 
--TRACE ON;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodigoRetorno = iSqlErr;
			LET cMensajeRetorno ="ERROR NO CONTROLADO";
			RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")); 
		END IF;
	END EXCEPTION;
 
 	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF NVL(pConsulta,0) NOT IN (1,2) THEN
		LET  cCodigoRetorno= "00001";
		LET  cMensajeRetorno="PARAMETRO pConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF
	IF TRIM(NVL(pTipoConsulta,"")) NOT IN("GE","DI","SC","SD") THEN
		LET  cCodigoRetorno= "00002";
		LET  cMensajeRetorno="PARAMETRO pTipoConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) ;
	END IF;	
	IF TRIM(NVL(pFechaConsulta,"")) = "" THEN
		LET  cCodigoRetorno= "00003";
		LET  cMensajeRetorno= "PARAMETRO pFechaConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF;	
	--SE CAMBIA EL FORMATO DE LA FECHA PARA PODERCE COMPARAR CON UN VALOR DE LA TABLA
	LET cFecha = SUBSTR(YEAR(pFechaConsulta),3,2) || LPAD(MONTH(pFechaConsulta),2,"0") || LPAD(DAY(pFechaConsulta),2,"0");
	--SE OPTIENE DETALLES DE OPERACIONES GENERALES
	IF pTipoConsulta = "GE" THEN
		FOREACH			
			SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
			INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
			FROM 'informix'.tf_incapture
			WHERE SUBSTR(cuenta,1,6) IN (SELECT bin	FROM intercard:'informix'.bines WHERE 
			creditodebito = DECODE (pConsulta,1,"D",2,"C",""))
			AND fecha_alta = cFecha			
			RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;
		END FOREACH;	
	END IF;
	--SE OBTIENE DETALLE DE DISPOSICIONES
	IF pConsulta = 1 THEN
		IF pTipoConsulta = "DI" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D') 
				AND archivo_origen IN(SELECT valor FROM 'informix'.tf_param_transfer
				WHERE codigo BETWEEN '100' AND '109')
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;	
		END IF;
	--SE OBTIENE DETALLE DE COMPRAS TIPO DEBITO
		IF pTipoConsulta = "SC" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D')
				AND archivo_origen IN (SELECT valor FROM 'informix'.tf_param_transfer
				WHERE codigo BETWEEN '110' AND '149')
				AND tipotransaccion <> '21'
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	--SE OBTIENE DETALLE DEVOLUCIONES DEBITO
		IF pTipoConsulta = "SD" THEN
			FOREACH
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D')
				AND tipotransaccion = '21'
				AND fecha_alta = cFecha
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	ELIF pConsulta = 2 THEN 	
	--SE OBTIENE DETALLE DE DISPOSICIONES
		IF pTipoConsulta = "DI" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin FROM Intercard:"informix".bines WHERE creditodebito = 'C') 
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
				WHERE codigo BETWEEN '150' AND '159') AND fecha_alta = cFecha				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;	
		END IF;	
	--SE OBTIENE DETALLES DE COMPRAS TIPO CREDITO 
		IF pTipoConsulta = "SC" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM "informix".tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin FROM Intercard:"informix".bines 
					WHERE creditodebito = DECODE (pConsulta,1,"D",2,"C","")) 
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer 
					WHERE codigo BETWEEN '160' AND '199') 
				AND tipotransaccion <> '21' 
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;
			END FOREACH;
		END IF;
		
	--SE OBTIENE DETALLE DEVOLUCIONES CREDITO
		IF pTipoConsulta = "SD" THEN
			FOREACH
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM "informix".tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin from Intercard:"informix".bines 
					WHERE creditodebito = 'C')
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
					WHERE codigo BETWEEN '160' AND '199') 
				AND tipotransaccion = '21'
				AND fecha_alta = cFecha
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	END IF;	
	
	
	IF NVL(mMontoTotalOperacion,0.00) = 0 THEN
		LET cCodigoRetorno = "00004";
		LET cMensajeRetorno = "DATOS NO ENCONTRADOS";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF;	
END;	
END PROCEDURE
DOCUMENT
"AUTOR: 96152877 - Jose Raul Pacheco Ortiz",
"FOLIO: 1434",
"DESCRIPCION: Se para obtener detalles de los tipos de archivos transfer.",
"FECHA: 27/08/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
"---------------------------------------------------------------------------------------------------------------",
"AUTOR: 95407693 - Daniel Lazalde",
"FOLIO: 1492",
"DESCRIPCION: Se consulta detalle de compensación",
"FECHA: 25/09/2014",
"SUSTENTO: Se definio con José Luis Puebla en el requerimiento Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
'-----------------------------------------------------------------------------',
"MODIFICO: - María del Rosario Montes Villa",
"FOLIO: 1492",
"DESCRIPCION: Se consulta detalle de compensación.",
"FECHA: 09/10/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER";

CREATE PROCEDURE "informix".sp_consulta_resumen_compensacion(pConsulta INTEGER, pFechaConsultar DATE)

--RETORNOS
RETURNING
CHAR(5)			AS	CodigoRetorno,
CHAR(100)		AS	MensajeRetorno,
CHAR(1)			AS	ConciliacionEjecut,
INTEGER 		AS	Num_Total_Operaciones,
MONEY(14,2) 	AS 	Monto_Total_Operacion,
INTEGER			AS	Num_Total_Dispociciones,
MONEY(14,2)		AS	Monto_Total_Disposiciones,
INTEGER			AS	Num_Subtotal_Compras,
MONEY(14,2) 	AS	Monto_Subtotal_Compras,
INTEGER 		AS	Num_Subtotal_Devoluciones,
MONEY(14,2)		AS	Monto_Subtotal_Devoluciones;

--DEFINICON DE VARIABLES
DEFINE cCodigoRetorno 			CHAR(5);
DEFINE cMensajeRetorno			CHAR(100);
DEFINE iNumTotalOperaciones 	INTEGER;
DEFINE mMontoTotalOperacion		MONEY(14,2);
DEFINE iNumTotalDispo			INTEGER;
DEFINE mMontoTotalDispo			MONEY(14,2);
DEFINE iNumSubTotalCOmpras		INTEGER;
DEFINE mMontoSubtotalCompras	MONEY(14,2);
DEFINE iNumSubTotalDevo 		INTEGER;
DEFINE mMontoSubTotalDevo		MONEY(14,2);
DEFINE iSqlErr 					INTEGER;
DEFINE cFecha					CHAR(6);
DEFINE cConciliacionEjecut		CHAR(1);

--INICIALIZACION DE VARIABLES
LET cCodigoRetorno 			= "00000";
LET cMensajeRetorno			= "EXITO";
LET iNumTotalOperaciones 	= 0;
LET mMontoTotalOperacion	= 0.00;
LET iNumTotalDispo			= 0;
LET mMontoTotalDispo		= 0.00;
LET iNumSubTotalCompras		= 0;
LET mMontoSubtotalCompras	= 0.00;
LET iNumSubTotalDevo 		= 0;
LET mMontoSubTotalDevo		= 0.00;
LET iSqlErr 				= 0;
LET cFecha					= ""; 
LET cConciliacionEjecut		= "";

--SET DEBUG FILE TO "/respaldosbd/carlosaguirre/sp_consulta_resumen_compensacion.out"; 
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodigoRetorno = iSqlErr;
			LET cMensajeRetorno = "ERROR NO CONTROLADO";
			RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
				NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
				NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
		END IF;
	END EXCEPTION;
 
 	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- VALIDA QUE EL PARAMETRO pConsulta NO VENGA VACIA
	IF NVL(pConsulta,0) NOT IN (1,2) THEN
		LET cCodigoRetorno = "00001"; -- ERROR EN PARAMETRO DE TIPO DE CONSULTA
		LET cMensajeRetorno = "PARAMETRO pConsulta NULO O INVALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
			NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
			NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	END IF;
	
	-- SE VALIDA QUE LA FECHA NO TENGA VALOR NULO O SEA MAYOR A LA FECHA DEL SISTEMA
	IF NVL(pFechaConsultar,DATE(1)) = DATE(1) THEN
		LET cCodigoRetorno = "00002"; -- ERROR EN PARAMETRO DE FECHA 
		LET cMensajeRetorno = "PARAMETRO pFechaConsultar NULO O INVALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
			NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
			NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	END IF;
	
	SELECT valor
	INTO cConciliacionEjecut
	FROM bditarjeta:"informix".td_param_conciliacion_concreing
	WHERE codigo = "001";
	
	--SE CAMBIA DE FORMATO LA FECHA QUE SE INGRESO COMO PARAMATRO PARA PODER COMPARAR 
	LET cFecha = SUBSTR(YEAR(pFechaConsultar),3,2) || LPAD(MONTH(pFechaConsultar),2,"0") || LPAD(DAY(pFechaConsultar),2,"0");

	--Total de Transacciones Operadas (Débito y Crédito).
	SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
		INTO iNumTotalOperaciones, mMontoTotalOperacion
	FROM "informix".tf_incapture
	WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
		WHERE creditodebito = DECODE(pConsulta,1,"D",2,"C",""))
	AND fecha_alta = cFecha;
	
	IF pConsulta = 1 THEN -- DEBITO
	
		--Total de Disposiciones Operadas Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumTotalDispo, mMontoTotalDispo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "100" AND "109")
		AND fecha_alta = cFecha;

		--Total de Compras Exitosas Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalCompras, mMontoSubtotalCompras
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "110" AND "149")
		AND tipotransaccion <> "21"
		AND fecha_alta = cFecha;

		--Total de Devoluciones Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalDevo, mMontoSubTotalDevo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "110" AND "149")
		AND tipotransaccion = "21"
		AND fecha_alta = cFecha;
	
	ELIF pConsulta = 2 THEN -- CREDITO
		
		--Total de Disposiciones Operadas Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumTotalDispo, mMontoTotalDispo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "150" AND "159")
		AND fecha_alta = cFecha;

		--Total de Compras Exitosas Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalCompras, mMontoSubtotalCompras
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "160" AND "199")
		AND tipotransaccion <> "21"
		AND fecha_alta = cFecha;
		
		--Total de Devoluciones Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalDevo, mMontoSubTotalDevo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "160" AND "199") 
		AND tipotransaccion = "21"
		AND fecha_alta = cFecha;
		
	END IF;
	
	--SE VALIDA QUE LAS VARIABLES DE RETORNOS TENGAN VALOR 
	IF iNumTotalOperaciones = 0 THEN
		LET cMensajeRetorno = "DATOS VACIOS";
		LET cCodigoRetorno = "00003";
	END IF;
	
	RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
		NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
		NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	
END;
END PROCEDURE
DOCUMENT
"AUTOR: 96152877 - Jose Raul Pacheco Ortiz",
"FOLIO: 1434",
"DESCRIPCION: Se sube para la consulta de archivos transfer.",
"FECHA: 27/08/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
'-----------------------------------------------------------------------------',
"AUTOR: 95407693, Daniel Lazalde",
"FOLIO: 1492",
"DESCRIPCION: Consulta resumen compensación",
"FECHA: 24/09/2014",
"MODIFICACION: Se agrego parametro cConciliacionEjecut que identifica si se esta procesando en ese momento en conciliacion y ",
"modificación de las consultas para usar el archivo_origen parametrizable",
'-----------------------------------------------------------------------------',
"MODIFICO: - María del Rosario Montes Villa",
"FOLIO: 1434",
"DESCRIPCION: Se sube para la consulta de archivos transfer.",
"FECHA: 09/10/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER";

CREATE PROCEDURE "informix".sp_consulta_archivos_transfer (
								pIdOpcion INTEGER, 
								pFechaInicial DATE, 
								pFechaFin DATE, 
								pArchivoOrigen CHAR (3)
								)

--RETORNOS
RETURNING 
CHAR(5) 	AS CodRet,
CHAR(100)	AS MensajeRet,
CHAR(50) 	AS Nombre_Archivo,
CHAR(3) 	AS Achivo_Origen,
DATE 		AS Fecha_Archivo,
INTEGER 	AS Num_Registros,
DATE  		AS Fecha_Integracion,
DATE  		AS Fecha_Transferencia,
CHAR(1) 	AS Tranferencia,
CHAR(1) 	AS Carga,
CHAR(1) 	AS Proceso,
CHAR(1) 	AS Edo_Seguridad;

--DECLARACIONES DE VARIABLES
DEFINE cCodRet        		CHAR(5);
DEFINE cMensajeRet			CHAR(100);
DEFINE cNombreArchivo 		CHAR(50);
DEFINE cArchivoOrigen 		CHAR(3);
DEFINE dtFechaArchivo 		DATE;
DEFINE dtFechaSistema  		DATE;
DEFINE iNumeroRegistros 	INTEGER;
DEFINE dtFechaIntegracion 	DATE;
DEFINE dtFechaTransferencia DATE;
DEFINE cTransferencia		CHAR(1);
DEFINE cCarga           	CHAR(1);
DEFINE cProceso         	CHAR(1);
DEFINE cEdoSeguridad    	CHAR(1);
DEFINE iSqlErr 				INTEGER; 

--INICIALIZACION DE VARIABLES
LET cCodRet 				= '00000';
LET cMensajeRet 			= "EXITO";
LET cNombreArchivo 			= "";
LET cArchivoOrigen 			= "";
LET dtFechaArchivo 			= DATE(1);
LET iNumeroRegistros 		= 0;
LET dtFechaIntegracion 		= DATE(1);
LET dtFechaSistema 			= DATE(1);
LET dtFechaTransferencia	= DATE(1);
LET cTransferencia 			= "";
LET cCarga 					= "";
LET cProceso 				= "";
LET cEdoSeguridad 			= ""; 
LET iSqlErr 				= 0;

--SET DEBUG FILE TO '/respaldosbd/raulpacheco/sp_consulta_archivos_transfer.out'; 
--TRACE ON;

BEGIN 

	ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet="OCURRIO UN ERROR NO CONTROLADO";
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF;
	END EXCEPTION;
	
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	SELECT fecha_hoy
	INTO dtFechaSistema
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = "001";

	--VALIDA QUE LOS PARAMETROS VENGAN CON UNE VALOR CORRECTO
	IF NVL(pIdOpcion,0) NOT IN (1,2) THEN	
		LET cCodRet = "00001"; --PARAMETROS  ERRONEOS
		LET cMensajeRet ="VALOR NO ACEPTADO PARA EL TIPO DE OPCION";		
		RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));			
	END IF;
		
	--SE VALIDA LA OPCION QUE SE USARA EN LOS RADIO BUTTON SI ES 0 ES LA OPCION CONSULTA DIA ACTUAL
	IF  NVL(pIdOpcion,0) = 1 THEN
			--SE VALIDA SI EL PARAMETRO DE ARCHIVO ORIGEN VIENE VASIO O DIFERENTE A VACIO
		IF TRIM(NVL(pArchivoOrigen, "")) <> "" THEN 
			FOREACH	
				SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
				INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
				FROM "informix".tf_archivos_transfer 
				WHERE fecha_archivo = dtFechaSistema
				AND archivo_origen = pArchivoOrigen
				
				 
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
				LET cCodRet= "00005";
				LET cMensajeRet="NO EXISTEN DATOS";
					
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
					
			END IF;
	
			
		ELSE 	
			FOREACH
				
				SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
				INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
				FROM "informix".tf_archivos_transfer
				WHERE fecha_archivo = dtFechaSistema
		
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				
			END FOREACH;	
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
		END IF;
				

	ELSE --iIdOpcion=2
		
		IF NVL(pFechaInicial,"") = ""  OR NVL(pFechaFin,"") = "" THEN

			LET cCodRet = "00002";
			LET cMensajeRet = "ERROR EN PARAMETROS";

			RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
		END IF	
			--SE VALIDA SI LA FECHA VIENE CON VALOR
		IF NVL(pFechaInicial,"") <> ""  OR NVL(pFechaFin,"") <> "" THEN				
			--SE VALIDA QUE LA FECHA INICIAL Y LA FECHA FINAL NO SEA MAYOR A LA FECHA INICIAL
			IF NVL(pFechaFin, "") < NVL(pFechaInicial,"")  THEN
				LET cCodRet = "00003";
				LET cMensajeRet = "ERROR EN PARAMETROS";
				
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF	
			--SE VALIDA QUE LA FECHA INICIAL Y LA FECHA FINAL NO SEA MAYOR A LA FECHA DEL SISTEMA
			IF NVL(pFechaInicial,"") > NVL(dtFechaSistema,"") OR NVL(pFechaFin,"") > NVL(dtFechaSistema,"") 	THEN
				LET cCodRet = "00004";
				LET cMensajeRet = "ERROR EN PARAMETROS";
				
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF
		
			-- SE VALIDA SI EL ARCHIVO VIENE CON VALOR
			IF TRIM(NVL(pArchivoOrigen, "")) = "" THEN
			
				FOREACH
	
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE fecha_archivo <= pFechaFin
					AND  fecha_archivo  >= pFechaInicial
					
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
		
			
			ELSE
				FOREACH
					
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE fecha_archivo <= pFechaFin
					AND  fecha_archivo  >= pFechaInicial
					AND  archivo_origen = pArchivoOrigen
					
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
			
			END IF; 	
				
			
		
		ELSE --FECHA INICIAL Y FINAL VACIA 
			--SE VALIDA SI EL ARCHIVO ORIGEN VIENE CON VALOR
			IF TRIM(NVL(pArchivoOrigen, "")) = "" THEN
				FOREACH
				
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
						
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH; 	
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
				
			ELSE	
				FOREACH
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE  archivo_origen = pArchivoOrigen
						
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
				
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005"; 
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;				
			END IF;
				
	
		END IF;
			
	END IF;	
	
END;
		
END PROCEDURE
DOCUMENT
'AUTOR: 96152877 - Jose Raul Pacheco Ortiz  ',
'FOLIO: 1434',
'DESCRIPCION: Realiza la consulta de archivos transfer ya sea por rango de fecha o por dia actual .',
'FECHA: 12/08/2014',
'SUSTENTO: Se definio con Ricardo Resendis en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf', 
'BD: BDITRANSFER';

create procedure "informix".sp_transfer_conadmin_sva 
(
psnomarchivo_out char (50),pdfecha_recibido date, pstipo_cuenta char(1), pscuenta char(18), pscomentario char(256),
pmonto_out char (18), psintegridad char(1), psaplicado char(6),psmsn_motivo char(150),
vsstatus_cnc char (1),piconsecutivo integer, pscve_usuario char(10)
)
returning char (1);

--Variables de control de errores 
define visqlerr integer ;
define vscodret2 char(5);
define vsmensaje_respuesta varchar(250);

--Variables de trabajo
define vsnomarchivo_in char (50);
define vdfecha_proceso date ;
define vstipo_cuenta char (1);
define vpmonto_in char (18) ;
define vsfecha_in date;
define viconsecutivo integer;
define vinumresul integer;

define vsdescripcion_cnc char(200);
define vsdescripcion_cnc2 char(200);

define pssecuenciaextendida char(16);

define vsflagencontrado char (1);

begin
	on exception set visqlerr
		let vsmensaje_respuesta = vsmensaje_respuesta||' Error sp_transfer_conadmin_sva '||visqlerr;
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( '3', vsmensaje_respuesta, pscve_usuario) ;
		let vsstatus_cnc='E';
		return 	vsstatus_cnc;
	end exception;
	
--set debug file to "/informix/HomeInformix/sp_transfer_conadmin_sva.out";
--trace on;

let visqlerr  = 0;

let vsnomarchivo_in= '';
let vdfecha_proceso = today ;
let vstipo_cuenta = '';
let vpmonto_in = '' ;
let viconsecutivo = 0;
let vinumresul = 0;

let vsfecha_in = '01-01-1900';
let pssecuenciaextendida='';

let vsdescripcion_cnc = '';
let vsdescripcion_cnc2 = '';
let vsflagencontrado = 'V';

let vsmensaje_respuesta = 'Consulta si_fechas';
--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
set isolation to dirty read;
	select limit 1 fecha_hoy into vdfecha_proceso from bdinteg:"informix".si_fechas;
--Clasificación de bandera de aplicado por parte de Transfer.

If (psaplicado = '000000' or trim(psaplicado) = '0' or trim(psaplicado) = '' or psaplicado is null ) THEN
		
	Let psaplicado = 'V';
else 
	
	Let psaplicado = 'F';
	Let vsdescripcion_cnc2 = 'El registro no se aplico por :'||trim(psmsn_motivo);
end if;

--Clasificación general de conciliacion administrativa

if   (pscuenta = '' or pscuenta is null or pstipo_cuenta = '' or pstipo_cuenta is null) then

	Let vsdescripcion_cnc = 'No se recibieron los datos completos del registro OutSVA.';
	let vsflagencontrado = 'F';
	
elif (psintegridad != 'V') then 
	Let vsdescripcion_cnc = 'Se encontro un error de integridad en registro OutSVA.';
	let vsflagencontrado = 'F';
	
-- inicia el proceso de busqueda de la pareja InSVA
else 
	
	let vsmensaje_respuesta = 'Consulta tf_sva_incoming';
	
	set isolation to dirty read;
	select count(cuenta) into vinumresul from bditransfer:tf_sva_incoming
	where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P';
	
	if (vinumresul = 0 ) then 
	
		Let vsdescripcion_cnc = 'No se encontro registro InSVA relacionado.';
		let vsflagencontrado = 'F';
	
	elif (vinumresul = 1) then
		set isolation to dirty read;
		select nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
		into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
		from bditransfer:tf_sva_incoming
		where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P';
		
		if (trim(vpmonto_in) != trim(pmonto_out)) then 
			
			Let vsdescripcion_cnc = 'Los registros tienen diferencia en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		else 
		
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
						
	else
		-- Busqueda con mas filtros en caso de tener varios posibles. 
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
		into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
		from bditransfer:tf_sva_incoming
		where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P'
		and  trim(nvo_monto) = trim(pmonto_out);
		
		if (vsnomarchivo_in = '' or vsnomarchivo_in is null ) then
			--Busqueda sin filtro de monto.
			set isolation to dirty read;
			select limit 1 nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
			into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
			from bditransfer:tf_sva_incoming
			where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P'
			and comentario = pscomentario;
			
			if (vsnomarchivo_in = '' or vsnomarchivo_in is null ) then
			
				Let vsdescripcion_cnc = 'No se encontro registro InSVA relacionado. ';
				let vsflagencontrado = 'F';
			else 
				Let vsdescripcion_cnc = 'Los registros tienen diferencia en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
			end if;
		
		else 
		
		Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		
		end if; 
			
		
	end if;
	
	
end if;
let vsmensaje_respuesta = 'Insert tf_conadmin_sva';
--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
	INSERT INTO bditransfer:"informix".tf_conadmin_sva
	(
		--consecutivo,
		fecha_proceso,
		tipo_cuenta,
		cuenta,
		comentario,
		--secuenciaextendidadescripcion_concilia,
		descripcion_concilia,
		nombrearchivo_insva,
		fecha_mov_insva,
		monto_insva,
		nombrearchivo_outsva,
		fecha_mov_outsva,
		monto_outsva,
		integridad,
		aplicado_transfer,
		encontrado
		
	)
	VALUES
	(
		vdfecha_proceso,
		NVL(pstipo_cuenta,''),
		TRIM(NVL(pscuenta,'')),
		TRIM(NVL(pscomentario,'')),
		trim(vsdescripcion_cnc)||trim(vsdescripcion_cnc2),
		TRIM(NVL(vsnomarchivo_in,'')),
		vsfecha_in,
		TRIM(NVL(vpmonto_in,'')),
		TRIM(NVL(psnomarchivo_out,'')),
		pdfecha_recibido,
		TRIM(NVL(pmonto_out,'')),
		psintegridad,
		psaplicado,
		vsflagencontrado
	);
	
If (vsflagencontrado = 'V') then
	
	Update bditransfer:tf_sva_incoming set status_cnc = 'V' ,nombre_archivo_cnc = trim(psnomarchivo_out)
	where consecutivo=viconsecutivo ;
	
	let vsstatus_cnc='V';
	
End if;
	
let vsmensaje_respuesta = 'Proceso exitoso';

return 	vsstatus_cnc;

end
end procedure
DOCUMENT
'AUTOR: Juan Fco. Ponce Damian',
'Proyecto: Proyecto Transfer',
'Solicito: Luis Antonio Gomez',
'Descripcion: Proceso conciliación administrativa transfer InSVA Vs OutSVA',
'Fecha: 2014/09/24',
'BD: BdiTransfer';

CREATE PROCEDURE "informix".sp_actualizanumctetitular(pEmpresa CHAR(3), pRFC CHAR(13), pNumCte CHAR(20))
--DATOS A REGRESAR--
RETURNING 	CHAR(6) AS CodigoRetorno,
			CHAR(1) AS BanCteTransfer;

--DEFINICION DE VARIABLES--
DEFINE cCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumCtetf CHAR(20);
DEFINE cBanCtetf CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet = '000';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cNumCtetf = '';
LET cBanCtetf = '0';

--SET DEBUG FILE TO "/informix/IrisA/sp_actualizanumctetitular.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanCtetf;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa, '') <> '' AND NVL(pRFC, '') <> '' AND NVL(pNumCte, '') <> '' THEN

		SELECT numcte_tf 
		INTO cNumCtetf
		FROM "informix".tf_maecte 
		WHERE empresa = pEmpresa AND rfc = pRFC;

		IF NVL(cNumCtetf, '') <> '' THEN

			LET cBanCtetf = '1';

			UPDATE "informix".tf_maecte 
			SET numcte = pNumCte
			WHERE empresa = pEmpresa AND numcte_tf = cNumCtetf;

		END IF;

	END IF;

	RETURN cCodRet, cBanCtetf;

END;
END PROCEDURE;