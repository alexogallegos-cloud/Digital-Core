CREATE PROCEDURE "informix".ivr_finaliza_sesion( pTarjeta CHAR(16), pTelefono CHAR(10)) 
RETURNING CHAR(5); --- Codigo de Retorno
    --DefiniciÃ¯Â¿Â½n de variables:
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    --DEFINE vcTelefono   CHAR(10);
    DEFINE vcTarjeta    CHAR(20);
    DEFINE vcNumCliente CHAR(10); 
    DEFINE vSecMax      INTEGER;
	DEFINE vExisteCliente INTEGER;
	DEFINE vSucursal 	CHAR(4);
	DEFINE vOpcionAcceso CHAR(15);
	DEFINE vNumtarjeta 		CHAR(16);
	DEFINE vCuenta			CHAR(20);
	
	--AsinaciÃ¯Â¿Â½n de valor a las variables:	
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '';
    LET vCodRet3     = '';  
    --LET vcTelefono   = '';
    LET vcTarjeta    = '';
    LET vcNumCliente = '';   
    LET vSecMax      = 0;	
	LET vExisteCliente = 0;
	LET vSucursal 	 = '';
	LET vOpcionAcceso = '';
	LET vNumtarjeta 	= '';
	LET vCuenta		 = '';
    BEGIN

		ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
			--SET DEBUG FILE TO "/tmp/Cris/ivr_finaliza_sesion.err";
			--TRACE ON;
			IF Sql_Err <> 0 THEN
				LET vCodRet1 = Sql_Err;
				LET vCodRet2 = Isam_Err;
				LET vCodRet3 = Desc_Err;
				RETURN vCodRet1;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/Cris/ivr_finaliza_sesion.out"; -->>>MODIFICAR RUTA PARA LOG
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	IF pTelefono IS NOT NULL  OR pTelefono <> '' THEN
		LET pTarjeta = TRIM(NVL(pTarjeta,'')); --#CVA_20190502.1215 --Se quitan los espacios en blanco que pueda tener el parametro.
		
		IF ( pTarjeta IS NULL OR pTarjeta = '' ) THEN
			LET vCodRet1 = '00017';
		END IF;

		IF vCodRet1 = '00000' THEN
			IF LENGTH (pTarjeta) = 9 THEN --Num Cliente
				--#CVA_20190502.1215 --Se optimiza proceso, quitando consultas innecesarias a base de datos y validaciones de mÃ¯Â¿Â½s.
				SELECT a.numcte, b.sucursal  
				INTO vcNumCliente, vSucursal 
				FROM bdinteg:"informix".si_cliente_ivr a, bdinteg:"informix".si_cliente b 
				WHERE (a.numcte = pTarjeta) 
				AND (a.numcte = b.numcte);
				
				LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta
				
				IF vExisteCliente = 0 THEN
					LET vCodRet1 = '00002'; ---Cliente no existe	
				END IF;

				LET vOpcionAcceso = 'NUM_CTE';

			ELIF LENGTH (pTarjeta) = 11 THEN -- DÃ¯Â¿Â½bito		
				 --#CVA_20190502.1215 --Se optimiza proceso.
				
				SELECT num_cte, sucursal 
				INTO vcNumCliente, vSucursal 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = pTarjeta 
				AND status_cta = '1';
				
				LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta

				IF vExisteCliente = 0 THEN		
					LET vCodRet1 = '00001'; ---Cuenta  no existe	
				ELSE
					IF ( TRIM(NVL(vcNumCliente,'')) = '') THEN
						LET vCodRet1 = '00002'; ---Cliente no existe	
					END IF;			
				END IF;
				
				LET vOpcionAcceso = 'NUM_CTA_CAP';

			ELIF LENGTH (pTarjeta) = 12  THEN --CrÃ¯Â¿Â½dito
				--#CVA_20190502.1215 Se cambia validaciÃ¯Â¿Â½n de nÃ¯Â¿Â½mero de crÃ¯Â¿Â½dito, se agrega consulta a la tabla sd_maecredcrd y se quitan algunas validaciones innecesarias.						
				SELECT LIMIT 1 numcte, sucursal 
				INTO vcNumCliente, vSucursal 
				FROM 
				TABLE(MULTISET(
				SELECT numcte, sucursal 
				FROM bdicred:"informix".sd_maecred 
																				   
				WHERE num_credito = pTarjeta 
				AND status_cred IN ('BT','AA','BA','E1','E2','E3') 
												   
				UNION ALL 
				SELECT numcte, sucursal 
				FROM bdicred:"informix".sd_maecredcrd 
																							  
				WHERE num_credito = pTarjeta 
				AND status_cred IN ('BT','AA','BA','VP','E1','E2','E3')));
				
				LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta

				IF vExisteCliente = 0 THEN		
					LET vCodRet1 = '00001'; ---NÃ¯Â¿Â½mero de crÃ¯Â¿Â½dito no existe,
				ELSE
					IF ( TRIM(NVL(vcNumCliente,'')) = '') THEN
						LET vCodRet1 = '00002'; ---Cliente no existe	
					END IF;			
				END IF;
				
				LET vOpcionAcceso = 'NUM_CTA_CRED';

			ELIF LENGTH (pTarjeta) = 16 THEN --Num Tarjeta			
				
				SELECT tar.numcte, chq.sucursal 
				INTO vcNumCliente, vSucursal 
				FROM bdicheq:"informix".sc_tarjeta tar, bdicheq:"informix".sc_maechq chq 
				WHERE tar.empresa = chq.empresa 
				AND tar.num_tarjeta = pTarjeta 
				AND tar.tipo_tarjeta = 'T' 
				AND tar.status_tar = 'A' 
				AND chq.cuenta = tar.cuenta 
				AND chq.num_cte = tar.numcte;
				
				LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta
				
				LET vOpcionAcceso = 'NUM_TDD';

				IF vExisteCliente = 0 THEN					
					
					SELECT tar.numcte, crd.sucursal 
					INTO vcNumCliente, vSucursal 
					FROM bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maecred crd 
					WHERE tar.empresa = crd.empresa 
					AND tar.num_tarjeta = pTarjeta 
					AND tar.tipo_tarjeta = 'T' 
					AND tar.status_tar = 'A' 
					AND crd.num_credito = tar.num_credito 
					AND crd.numcte = tar.numcte;
					
					LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta

					LET vOpcionAcceso = 'NUM_TDC';

					IF vExisteCliente = 0 THEN	
						LET vCodRet1 = '00001'; --NÃ¯Â¿Â½mero de tarjeta no existe.
					ELSE
						IF ( TRIM(NVL(vcNumCliente,'')) = '') THEN
							LET vCodRet1 = '00002'; --Cliente no existe.
						END IF;
					END IF;
				ELSE
					IF ( TRIM(NVL(vcNumCliente,'')) = '') THEN
						LET vCodRet1 = '00002'; --Cliente no existe
					END IF;
				END IF;
			ELSE
				LET vCodRet1 = '00001'; --NÃ¯Â¿Â½mero de tarjeta no existe.
			END IF;
		END IF;
			
			IF vCodRet1 = '00000' THEN
				--#CVA_20190502.1215 - Se optima proceso, de actualizaciÃ¯Â¿Â½n de estatus de acceso del clinete.
				LET vExisteCliente = 0;
				
				UPDATE bdinteg:"informix".si_cliente_ivr
				SET status_acceso = '0'
				WHERE numcte = vcNumCliente;		
				
				LET vExisteCliente =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190502.1215 --Asigna el resultado de la consulta
				
				IF vExisteCliente = 0 THEN
					LET vCodRet1 = '00002';
				ELSE
					LET vcNumCliente = TRIM(NVL(vcNumCliente,''));
					/*
					-- Se obtiene el numero de telefono del cliente
					SELECT telefono 
					INTO vcTelefono 
					FROM bdinteg:"informix".si_cliente_ivr 
					WHERE numcte = vcNumCliente;
					*/
					-- // RECOPILANDO DATA DE BITACORA
		
						SELECT FIRST 1 num_tarjeta,cuenta
						INTO vNumtarjeta,vCuenta
						FROM bdicheq:"informix".sc_tarjeta 
						WHERE numcte = vcNumCliente
						AND status_tar = 'A'
						AND tipo_tarjeta = 'T';

					 IF DBINFO("sqlca.sqlerrd2") != 0 THEN
						
						SELECT FIRST 1 sucursal
						INTO vSucursal
						FROM bdicheq:"informix".sc_maechq 
						WHERE cuenta = vCuenta;
						
					 ELSE
		
						SELECT FIRST 1 num_tarjeta, num_credito
						INTO vNumtarjeta,vCuenta
						FROM bdicred:"informix".sd_tarjeta
						WHERE numcte = vcNumCliente
						AND status_tar ='A'
						AND tipo_tarjeta = 'T';

						SELECT FIRST 1 sucursal
						INTO vSucursal
						FROM bdicred:"informix".sd_maecred
						WHERE num_credito = vCuenta;

					 END IF;

						IF vNumtarjeta IS NULL THEN
						LET vNumtarjeta = '';
						END IF;
						    	
						IF vSucursal IS NULL THEN
						LET  vSucursal = '';
    					END IF;

					-- // GUARDA REGISTRO EN BITACORA
					SELECT MAX(secuencia) --#CVA_20190502.1215 - Se optima proceso
					INTO vSecMax
					FROM bdinteg:"informix".si_bitacora_ivr
					WHERE DATE(fecha_oper) = CURRENT::DATE
					AND telefono = pTelefono;
					
					IF vSecMax IS NULL THEN
						LET vSecMax = 0;
					END IF;
							
					LET vSecMax = vSecMax + 1;
					
					INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal) 
					VALUES (CURRENT, vSecMax, 'FIN_SESION', vNumtarjeta, vcNumCliente, pTelefono, vOpcionAcceso, vSucursal);
					
				END IF;
			ELSE
					-- // GUARDA REGISTRO EN BITACORA CUANDO CLIENTE NO EXISTE
					SELECT MAX(secuencia) --#CVA_20190502.1215 - Se optima proceso
					INTO vSecMax
					FROM bdinteg:"informix".si_bitacora_ivr
					WHERE DATE(fecha_oper) = CURRENT::DATE
					AND telefono = pTelefono;
					
					IF vSecMax IS NULL THEN
						LET vSecMax = 0;
					END IF;
							
					LET vSecMax = vSecMax + 1;
					
					INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal) 
					VALUES (CURRENT, vSecMax, 'NE', '', '', pTelefono, vOpcionAcceso, '');

			END IF;	
	ELSE
		LET vCodRet1 = '00003'; --ParametrÃÂ³ telefono viene vacÃÂ­o
	END IF

		RETURN vCodRet1;
    END;
  
END PROCEDURE
DOCUMENT
'DESCRIPCIÃ¯Â¿Â½N: Se modifica Procedimiento Almacenado para finalizar sesiÃ¯Â¿Â½n cuando se ingresa por...',
'... nÃ¯Â¿Â½mero de cliente, cuenta dÃ¯Â¿Â½bito, cuenta crÃ¯Â¿Â½dito o nÃ¯Â¿Â½mero de tarjeta.',
'MODIFICÃ¯Â¿Â½: Jorge A. GastÃ¯Â¿Â½lum Acosta',
'FOLIO:  298.1 - RQM 10 700 ActualizaciÃ¯Â¿Â½n IVR envÃ¯Â¿Â½o de movimientos correo electrÃ¯Â¿Â½nico y cuenta CLABE por voz y SMS.',
'FECHA : 12/10/2017',
'BD    : BDIVR',
'Modifico: Ricardo gabriel roman garcia',
'Se quitaron los trim, select case y if exist',
'Fecha : 2019/04/24',
'Modifico: Cristian Valentina Aguilar',
'DescripciÃ¯Â¿Â½n: Se optimiza proceso, se quitan consultas y validaciones innecesarias, ademas de cambiarlo para que tenga un return mÃ¯Â¿Â½s el de la excepciÃ¯Â¿Â½n.',
'Fecha : 2019/05/02',
'Etiqueta: #CVA_20190502.1215 ',
'Modifico: Mireya Rodriguez',
'DescripciÃ¯Â¿Â½n: Se agregarÃ¯Â¿Â½ la variable vSucursal para obtener el numero de sucursal dependiendo del parametro de entrada, se realizÃ¯Â¿Â½ una consulta para obtener el telefono del cliente y se agregaron los nuevos campos al insert de la tabla si_bitacora_ivr',
'Fecha: 2019/08/16',
'Descripcion: Se agrega nueva variable pTelefono para guardar el telefono de la llamada de IVR y vOpcionAcceso para registrar la opciÃÂ³n de acceso del cliente ',
'AUTOR : Yonaiker Morillo',
'FECHA : 17/09/2020',
'FOLIO : 697.1',
'BD    : BDIVR';

CREATE PROCEDURE "informix".ivr_valida_cuenta_telefono(p_cTelefono CHAR(10), p_cCapturado CHAR(16))
RETURNING CHAR(5), --- Codigo de Retorno
		  CHAR(9), --- NÃºmero de Cliente
	      CHAR(4), --- NÃºmero de Sucursal
		  CHAR(15), -- OpciÃ³n de Acceso
		  CHAR(1); -- Flag para Existencia de ContraseÃÂ±a

	--DeclaraciÃ³n de variables
	DEFINE v_sTipoConsulta 		SMALLINT;
	DEFINE cReCord 				CHAR(6);
	DEFINE vdFechaHoy       	DATE;
	DEFINE v_cStatus_Cred		CHAR(2);
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE v_sStatus_cta		CHAR(2);
	DEFINE v_sNumcliente		CHAR(9);
	DEFINE vcProducto       	CHAR(4);
	DEFINE v_scodstatustarjeta	CHAR(3);
	DEFINE v_sStatus1			CHAR(2);
	DEFINE v_sStatus2			CHAR(2);
	DEFINE vSecMax          	INTEGER;
	DEFINE cDescOper      		CHAR(20);
	DEFINE viExisteTel			CHAR(10);
	DEFINE viExisteCte      	SMALLINT;
	DEFINE viExisCteIVR     	SMALLINT;
	DEFINE vcStatusAcceso   	CHAR(1);
	DEFINE vcTarjetaReg     	CHAR(20);
	DEFINE vStatuscte			CHAR (2);
    DEFINE vinddisponchq    	CHAR(1);
    DEFINE vinddisponcrd    	CHAR(1);
	DEFINE vcNumCtaCte			CHAR(12);
	DEFINE vOpcionAcceso 		CHAR(15);
	DEFINE vSucursal   	 		CHAR(4);
	DEFINE vTarjeta      		CHAR(16);
	DEFINE iResConsulta			INTEGER;
	DEFINE vFlag_contra         CHAR(1);
	DEFINE viDiasVig			INTEGER;
	DEFINE vdFechaAlta       	DATE;
	DEFINE vdFechaUltOper		DATETIME YEAR TO SECOND;
	
	--InicializaciÃ³n de Variables
	
	LET v_sTipoConsulta = 0;
	LET cReCord = '00001';
	LET vdFechaHoy = '';
	LET v_cStatus_Cred = '';
	LET v_sStatus_cta = '';
	LET v_sNumcliente = '';
	LET vcProducto     = '';
	LET v_scodstatustarjeta = '';
	LET v_sStatus1 = '';
	LET v_sStatus2 = '';
	LET vSecMax = 0;
	LET cDescOper = 'VALIDA_TIPO_CONSULTA';
	LET viExisteTel = '';
	LET viExisteCte    = 0;
	LET viExisCteIVR   = 0;
	LET vcStatusAcceso = '';
	LET vcTarjetaReg   = '';
	LET vStatuscte = '';
    LET vinddisponchq  = '0';
    LET vinddisponcrd  = '0';
	LET vcNumCtaCte = '';
	LET vOpcionAcceso   = '';
	LET vSucursal   = '';
	LET vTarjeta   = '';
	LET iResConsulta = 0;
	LET vFlag_contra = '0';
	LET viDiasVig = 0;
	LET vdFechaAlta = '';
	LET vdFechaUltOper = '';
	
	--SET DEBUG FILE TO "/tmp/yonaiker/Proyecto_Folio_623.1/Modificaciones_18032020/Nueva_idea/ivr_valida_cuenta_telefono.out"; -- MODIFICAR RUTA DEL ARCHIVO
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cReCord     = iSqlErr;
				RETURN cReCord, v_sNumcliente, vSucursal, vOpcionAcceso, vFlag_contra;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF ( TRIM(NVL(p_cTelefono,'') )  != '' ) THEN
		
		IF ( TRIM(NVL(p_cCapturado,'')) != '' ) THEN
		
			-- // OBTIENE LA FECHA DEL DIA
			SELECT fecha_hoy
			  INTO vdFechaHoy
			  FROM bdinteg:"informix".si_fechas
			 WHERE empresa = '001';
			 
			SELECT ind_disponible
			  INTO vinddisponchq
			  FROM bdicheq:"informix".sc_fechas 
			 WHERE empresa = '001';
			 
			SELECT ind_disponible
			  INTO vinddisponcrd
			  FROM bdicred:"informix".sd_fechas 
			 WHERE empresa = '001';
			 
			IF (vinddisponchq = '0' OR vinddisponcrd = '0' ) THEN
				LET cReCord = '017';
				LET v_sNumcliente = '';
			END IF;
			
			LET v_sTipoConsulta = LENGTH (p_cCapturado);
			
			--//VALIDAR EXISTENCIA DE DATOS DE ACUERDO A LA CAPTURA DEL CLIENTE
			IF v_sTipoConsulta = 9 THEN
				SELECT numcte
				INTO v_sNumcliente
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = p_cCapturado;
				
				LET vOpcionAcceso = 'NUM_CTE'; --Se agrega opciÃÂ³n nÃÂºmero de cliente por la que accesa el cliente.

				IF (TRIM(v_sNumcliente) IS NOT NULL) OR (TRIM(v_sNumcliente) != '') THEN
					
					SELECT LIMIT 1 cuenta,producto --OBTIENE NUMERO DE CTA DEL CTE
						INTO vcNumCtaCte, vcProducto
					FROM bdicheq:"informix".sc_maechq 
					WHERE num_cte = v_sNumcliente
					AND status_cta = '1';
					
					LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#MRF - Asigna para validar el resultado de la consulta
					
					IF iResConsulta > 0 THEN
						SELECT t.num_tarjeta, b.sucursal --OBTIENE NÃÅ¡MERO DE TARJETA POR NÃÅ¡MERO DE CUENTA
						INTO vTarjeta, vSucursal 
						FROM bdicheq:"informix".sc_maechq b,
						bdicheq:"informix".sc_tarjeta t
						WHERE b.cuenta = t.cuenta
						AND b.cuenta = vcNumCtaCte 
						AND t.tipo_tarjeta = 'T' 
						AND t.status_tar = 'A';
						
						IF NVL(vTarjeta,'') = '' THEN
							LET vTarjeta = '';
						END IF;
					END IF;
					
					IF (TRIM(vcNumCtaCte) IS NULL) OR (TRIM(vcNumCtaCte) = '')THEN
						SELECT LIMIT 1 num_credito,num_producto	--OBTIENE NUMERO DE CREDITO DEL CTE
							INTO vcNumCtaCte, vcProducto
						FROM bdicred:"informix".sd_maecred 
						WHERE numcte = v_sNumcliente
						AND status_cred IN ('AA','BT','BA','E1','E2','E3');
						
						LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#MRF - Asigna para validar el resultado de la consulta
					
						IF iResConsulta > 0 THEN
							SELECT tar.num_tarjeta, crd.sucursal
							INTO vTarjeta, vSucursal 
							FROM bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maecred crd
							WHERE crd.num_credito = tar.num_credito 
							AND crd.num_credito = vcNumCtaCte
							AND tar.tipo_tarjeta = 'T'
							AND tar.status_tar = 'A';
							
							IF NVL(vTarjeta,'') = '' THEN
								LET vTarjeta = '';
							END IF;
						END IF;
						
						IF (TRIM(vcNumCtaCte) IS NULL) OR (TRIM(vcNumCtaCte) = '') THEN
							LET cReCord = '018';
						END IF;
					END IF;
					
					LET p_cCapturado = vTarjeta;
					LET cReCord = '00000';
					
				ELSE 
					LET cReCord = '00002'; ---Cliente no existe en la tabla de clientes de la bdinteg	
				END IF;
				
			--//CONSULTA NUMERO DE CUENTA	
			ELIF (v_sTipoConsulta = 11) THEN						
			
			LET vOpcionAcceso = 'NUM_CTA_CAP'; --Se agrega opciÃÂ³n nÃÂºmero de cuenta captaciÃÂ³n por la que accesa el cliente.
			
				/*
				SELECT c.status_cta, c.num_cte, c.producto, c.sucursal, t.num_tarjeta 
				INTO v_sStatus_cta, v_sNumcliente, vcProducto, vSucursal, vTarjeta  
				FROM bdicheq:"informix".sc_maechq c,
				bdicheq:"informix".sc_tarjeta t
				WHERE c.cuenta = t.cuenta
				AND	c.cuenta = p_cCapturado;
				*/
				
				SELECT status_cta, num_cte, producto, sucursal 
				INTO v_sStatus_cta, v_sNumcliente, vcProducto, vSucursal 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = p_cCapturado;
				
				IF (TRIM(NVL(v_sNumcliente ,'')) <> '') THEN	
				
					IF (TRIM(v_sStatus_cta ) <> '1' ) THEN
						Let cReCord = '00001';
					ELSE
						SELECT num_tarjeta 
						INTO vTarjeta 
						FROM bdicheq:"informix".sc_tarjeta 
						WHERE cuenta = p_cCapturado 
						AND tipo_tarjeta = 'T' 
						AND status_tar = 'A';
						
						LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20191022.1204 --Asigna para validar el resultado de la consulta	
						
						IF iResConsulta = 0 THEN
							LET vTarjeta = '';
						END IF;
						
						Let cReCord = '00000';
						LET p_cCapturado = vTarjeta;
						
					END IF;
				ELSE
					LET cReCord = '00001';
				END IF;
				
			--//CONSULTA NUMERO DE CREDITO		
			ELIF (v_sTipoConsulta = 12) THEN 

			LET vOpcionAcceso = 'NUM_CTA_CRED'; --Se agrega opciÃÂ³n nÃÂºmero de cuenta crÃÂ©dito por la que accesa el cliente.
				
			/*	SELECT status_cred, numcte, num_producto, sucursal, num_tarjeta  	
				INTO v_cStatus_Cred, v_sNumcliente, vcProducto, vSucursal , vTarjeta
				FROM 
				TABLE(MULTISET(
				SELECT c.status_cred, c.numcte, c.num_producto, c.sucursal, t.num_tarjeta 						
				FROM bdicred:"informix".sd_maecred c,
					 bdicred:"informix".sd_tarjeta t
				WHERE c.num_credito = t.num_credito 
				AND c.num_credito = p_cCapturado
				UNION ALL
				SELECT c.status_cred, c.numcte, c.num_producto, c.sucursal, t.num_tarjeta 		
				FROM bdicred:"informix".sd_maecredcrd c,
					 bdicred:"informix".sd_tarjeta t
				WHERE c.num_credito = t.num_credito
				AND c.num_credito = p_cCapturado));
				
				IF (TRIM(NVL(v_sNumcliente,'')) != '' )THEN
					
					IF  TRIM(v_cStatus_Cred) = 'AA'  OR TRIM(v_cStatus_Cred) = 'BT'  OR TRIM(v_cStatus_Cred) = 'BA' THEN
						LET cReCord = "00000";
						LET p_cCapturado = vTarjeta;
						LET vOpcionAcceso = 'NUM_CTA_CRED'; --Se agrega opciÃÂ³n nÃÂºmero de cuenta crÃÂ©dito por la que accesa el cliente.
					ELSE
						LET cReCord = "00001"; --El nÃÂºmero de crÃÂ©dito tiene un estatus no vÃÂ¡lido.
					END IF;					
				ELSE		
						LET cReCord = '00002'; --NÃÂºmero de crÃÂ©dito no existe en la bdicred:sd_maecred ni en bdicred:sd_maecredcrd
				END IF;*/
				
				
				SELECT  status_cred, numcte, num_producto, sucursal 
				INTO v_cStatus_Cred, v_sNumcliente, vcProducto, vSucursal 
				FROM 
				TABLE(MULTISET(
				SELECT status_cred, numcte, num_producto, sucursal 
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = p_cCapturado
				UNION ALL
				SELECT status_cred, numcte, num_producto, sucursal 
				FROM bdicred:"informix".sd_maecredcrd 
				WHERE num_credito = p_cCapturado));
				
				IF (TRIM(NVL(v_sNumcliente,'')) != '' )THEN
					
					IF  TRIM(v_cStatus_Cred) = 'AA'  OR TRIM(v_cStatus_Cred) = 'BT'  OR TRIM(v_cStatus_Cred) = 'BA' 
					OR TRIM(v_cStatus_Cred) = 'E1' OR TRIM(v_cStatus_Cred) = 'E2' OR TRIM(v_cStatus_Cred) = 'E3'THEN
						
						SELECT num_tarjeta 
						INTO vTarjeta 						
						FROM bdicred:"informix".sd_tarjeta
						WHERE num_credito = p_cCapturado
						AND tipo_tarjeta = 'T'
						AND status_tar = 'A';
						
						LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20191022.1204 --Asigna para validar el resultado de la consulta	

						IF iResConsulta = 0 THEN
							LET vTarjeta = '';
						END IF;
						
						LET cReCord = "00000";
						LET p_cCapturado = vTarjeta;
						
					ELSE
						LET cReCord = "00001"; --El nÃÂºmero de crÃÂ©dito tiene un estatus no vÃÂ¡lido.
					END IF;					
				ELSE		
						LET cReCord = '00002'; --NÃÂºmero de crÃÂ©dito no existe en la bdicred:sd_maecred ni en bdicred:sd_maecredcrd
				END IF;
				
			--//CONSULTA NUMERO DE TARJETA	
			ELIF (v_sTipoConsulta = 16) THEN 
				--DEBITO
				SELECT tar.numcte, chq.producto, chq.sucursal
					INTO v_sNumcliente, vcProducto, vSucursal
				FROM bdicheq:"informix".sc_tarjeta tar,
					 bdicheq:"informix".sc_maechq chq
				WHERE tar.empresa = chq.empresa
				AND tar.num_tarjeta = p_cCapturado
				AND tar.tipo_tarjeta = 'T'
				AND tar.status_tar = 'A'
				AND chq.cuenta = tar.cuenta
				AND chq.num_cte = tar.numcte;
				
				LET vOpcionAcceso = 'NUM_TDD'; --Se agrega opciÃÂ³n nÃÂºmero de tarjeta de dÃÂ©bito por la que accesa el cliente.

				--CREDITO
				IF (TRIM(NVL(v_sNumcliente,''))  = '') THEN
					SELECT tar.numcte, crd.num_producto, crd.sucursal
						INTO v_sNumcliente, vcProducto, vSucursal
					FROM bdicred:"informix".sd_tarjeta tar,
						 bdicred:"informix".sd_maecred crd
					WHERE tar.empresa = crd.empresa
					AND tar.num_tarjeta = p_cCapturado
					AND tar.tipo_tarjeta = 'T'
					AND tar.status_tar = 'A'
					AND crd.num_credito = tar.num_credito
					AND crd.numcte = tar.numcte;

					LET vOpcionAcceso = 'NUM_TDC'; --Se agrega opciÃÂ³n nÃÂºmero de tarjeta de crÃÂ©dito por la que accesa el cliente.

					IF (TRIM(NVL(v_sNumcliente,''))  <> '') THEN
						LET cReCord = '00000';
					ELSE
						LET cReCord = '00001';
						
					END IF;
				ELSE
					LET cReCord = '00000';
				END IF;	
			ELSE
				LET cReCord = '00001';
			END IF;
		ELSE
			LET cReCord = '00001';
		END IF;

			
			IF (cReCord == '00000') THEN 
			-- // VERIFICA SI EL CLIENTE EXISTE EN TABLA DE CLIENTES IVR
				SELECT COUNT(*)
				  INTO viExisCteIVR
				  FROM bdinteg:"informix".si_cliente_ivr
				 WHERE numcte = v_sNumcliente;
		    		    
				IF viExisCteIVR > 0 THEN
					-- // VERIFICA BANDERA DE ACCESO
					SELECT status_acceso, num_tarjeta
					  INTO vcStatusAcceso, vcTarjetaReg
					  FROM bdinteg:"informix".si_cliente_ivr
					 WHERE numcte = v_sNumcliente;
					 
					 SELECT MAX(fecha_oper) 
					 INTO vdFechaUltOper
					 FROM bdinteg: si_bitacora_ivr 
					 WHERE numcte = v_sNumcliente;
					 
					 LET vdFechaUltOper = NVL(vdFechaUltOper,'');
					 
					IF (vcStatusAcceso IS NULL OR vcStatusAcceso = '' OR (vcStatusAcceso = '1' AND vdFechaUltOper > (CURRENT YEAR TO SECOND - 1 UNITS HOUR)))THEN
						LET cReCord = '00020';
						--LET v_sNumcliente = ''; --JMMO Ya esta autentificado.
					END IF;
					
					IF p_cCapturado <> vcTarjetaReg THEN 
						UPDATE bdinteg:"informix".si_cliente_ivr
						   SET num_tarjeta = p_cCapturado
						 WHERE numcte = v_sNumcliente;
					END IF;
				ELSE
					-- // VERIFICA QUE EL CLIENTE EXISTA
					SELECT COUNT(*)
					  INTO viExisteCte
					  FROM bdinteg:"informix".si_cliente
					 WHERE numcte = v_sNumcliente;

					IF viExisteCte = 0 THEN
						LET cReCord = '00002';
						LET v_sNumcliente = '';
					END IF;

					-- // VERIFICA QUE EL TELEFONO SEA DE CASA O CELULAR
					SELECT COUNT(*)
					  INTO viExisteTel
					  FROM bdinteg:"informix".si_telefonos_actual
					 WHERE numcte = v_sNumcliente
					   AND telefono = p_cTelefono
					   AND tipo_tel = 1;

					IF viExisteTel = 0 THEN
						SELECT COUNT(*)
						  INTO viExisteTel
						  FROM bdinteg:"informix".si_telefonos_actual
						 WHERE numcte = v_sNumcliente
						   AND telefono = p_cTelefono
						   AND tipo_tel = 2;
					
						IF viExisteTel = 0 THEN
							LET cReCord = '00003';
							LET v_sNumcliente = '';
						END IF;
					END IF;

					IF cReCord = '00000' THEN 
						INSERT INTO bdinteg:"informix".si_cliente_ivr VALUES
						( v_sNumcliente, 'P', p_cTelefono, p_cCapturado, NVL (vcProducto,' '), '', '', 0, vdFechaHoy, '0' );
					END IF;

				END IF;				
				
			END IF;

			IF cReCord = '00000' OR cReCord = '00020' THEN

				
				-- RECOPILANDO DATA DE BITACORA
				IF p_cCapturado = '' OR p_cCapturado IS NULL THEN

					SELECT FIRST 1 num_tarjeta
					INTO p_cCapturado
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE numcte = v_sNumcliente
					AND status_tar = 'A'
					AND tipo_tarjeta = 'T';

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN

						SELECT FIRST 1 num_tarjeta
						INTO p_cCapturado
						FROM bdicred:"informix".sd_tarjeta
						WHERE numcte = v_sNumcliente
						AND status_tar ='A'
						AND tipo_tarjeta = 'T';

					END IF;

					IF p_cCapturado IS NULL THEN
						LET p_cCapturado = '';
					END IF;

				END IF;	

				-- GUARDA REGISTRO EN BITACORA
				SELECT MAX(secuencia)
				INTO vSecMax
				FROM bdinteg:"informix".si_bitacora_ivr
				WHERE DATE(fecha_oper) = CURRENT::DATE
				AND telefono = p_cTelefono;

				IF vSecMax IS NULL THEN
					LET vSecMax = 0;
				END IF;

				LET vSecMax = vSecMax + 1;
				
				LET p_cCapturado = NVL(TRIM(p_cCapturado),'');
				
				INSERT INTO bdinteg:"informix".si_bitacora_ivr 
				VALUES (CURRENT, vSecMax, cDescOper, p_cCapturado, v_sNumcliente, p_cTelefono, vOpcionAcceso, vSucursal);
			ELSE
				-- // GUARDA REGISTRO EN BITACORA CUANDO CLIENTE NO EXISTE
		    	SELECT MAX(secuencia) --#CVA_20190502.1215 - Se optima proceso
		    	INTO vSecMax
		    	FROM bdinteg:"informix".si_bitacora_ivr
		    	WHERE DATE(fecha_oper) = CURRENT::DATE
		    	AND telefono = p_cTelefono;
		
		    	IF vSecMax IS NULL THEN
		    		LET vSecMax = 0;
		    	END IF;
	    	
		    	LET vSecMax = vSecMax + 1;
		
		    	INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal) 
		    	VALUES (CURRENT, vSecMax, 'NE', '', '', p_cTelefono, vOpcionAcceso, '');	
			END IF;

				-- // REALIZA VALIDACION DE EXISTENCIA DE CONTRASEÃâA	
 			    SELECT fecha_contra INTO vdFechaAlta
			    FROM bdinteg:"informix".si_cliente_ivr a
                WHERE numcte = v_sNumcliente;
				-- // VERIFICA LA VIGENCIA DE LA CONTRASEÃâA
				SELECT valor::int
				INTO viDiasVig
				FROM bdicheq:"informix".sc_param
				WHERE empresa = '001'
				AND codparam = 'ivrvigcont';
				
				IF ( (( vdFechaHoy - vdFechaAlta ) > viDiasVig) OR cReCord != '00000' ) THEN
					LET vFlag_contra = 0;
				ELSE
					LET vFlag_contra = 1;
				END IF;
				
			END IF;

		RETURN cReCord, v_sNumcliente, vSucursal, vOpcionAcceso, vFlag_contra;		
	END
END PROCEDURE
DOCUMENT
'Realiza la validaciÃÂ³n de la cuenta del cliente y telefono del cliente',
'AUTOR : Heriberto Torres',
'FECHA : 12/10/2017',
'BD    : BDIVR',
'Modifico: Hever Barraza',
'DescripciÃÂ³n: Se agregaron los parametros vOpcionAcceso para validar la opciÃÂ³n por la que acceso el cliente y vSucursal para conocer a que sucursal',
'pertenece la opciciÃÂ³n y registrarlo en la bitacora mensual de IVR, ademÃÂ¡s del retorno de la sucursal',
'Fecha : 2019/08/08',
'Modifico: Valentina Aguilar',
'DescripciÃÂ³n: Se separa validaciÃÂ³n para obtener el nÃÂºmero de tarjeta, cuando se trae un nÃÂºmero de crÃÂ©dito', 
'			ya que no todos los crÃÂ©ditos, tienen tarjeta asignada.',
'Fecha : 2019/10/22',
'Modifico: Mireya Rodriguez',
'DescripciÃÂ³n: Se cambiÃÂ³ la validaciÃÂ³n de la tarjeta y opciÃÂ³n de acceso para el nÃÂºmero de cliente, cuenta y crÃÂ©dito, ya que si el cliente no tiene cuenta se guarda vacÃÂ­a la opciÃÂ³n de acceso y la tarjeta',
'Fecha : 2019/11/22',
'Modifico: Yonaiker Morillo',
'DescripciÃÂ³n: Se agrego una bandera como dato para retornar si el cliente tiene contraseÃÂ±a y es valida a la fecha',
'Fecha : 2019/12/02',
'Modifico: Yonaiker Morillo',
'DescripciÃÂ³n: Se agrego validaciÃÂ³n en la ultima sesion de cliente para verificar el status de acceso al IVR',
'Fecha : 2020/03/30',
'Modifico: Yonaiker Morillo',
'DescripciÃÂ³n: Se modifico el codigo de retorno al no encontrar productos al cliente, se le coloco 018',
'Fecha : 2020/05/26',
'Modifico: Yonaiker Morillo',
'DescripciÃÂ³n: Se quito validaciÃÂ³n de cierre en las tablas sc_fechas y sd_fechas',
'Fecha : 2020/08/28',
'Modifico: Yonaiker Morillo',
'Folio: 697.1',
'DescripciÃÂ³n: Se modifica para agregar insercion en bitacora en caso de error, y secuencia buscada por telefono para que la informacion llegue a bitacora lo mas correctamente posible',
'Fecha : 2020/10/13';

CREATE PROCEDURE "informix".sp_ivr_envia_edomov (p_cTipoConsulta CHAR (16), p_cCliente CHAR (10), p_cTelefono CHAR(10))
RETURNING CHAR (5), CHAR (1),CHAR(1), CHAR(1);

--DeclaraciÃÂ³n de variables e inicaciÃÂ³n en vacio
DEFINE v_iNumeroEnvio 	INTEGER;
DEFINE v_iTipoConsulta 	CHAR(16);
DEFINE v_cOperacion 	CHAR(20);
DEFINE v_cProducto 		CHAR(20);
DEFINE vSecMax 			INTEGER;
DEFINE cReCord 			CHAR(5); 
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamErr 		INTEGER;
DEFINE cErrorInfo 		CHAR(20);
DEFINE v_cCodRetorno 	CHAR(5);
DEFINE v_cDigitos 		CHAR(4);
DEFINE vCuota 			CHAR(2);
DEFINE vCredito 		CHAR(12);
DEFINE vCuenta 			CHAR(16);
DEFINE iTieneCuenta 	CHAR(1);
DEFINE iTotal 			INTEGER;
DEFINE vFechaCorte 		CHAR(10);
DEFINE vAno 			CHAR(4); 
DEFINE vMes 			CHAR(2); 
DEFINE vCorreoELec 		CHAR(100);
DEFINE vTipoCorreo 		INTEGER;
DEFINE vStatusCorreo 	CHAR(1);
DEFINE vTieneCorreo 	CHAR(1);
DEFINE vNumTarjetaCred  CHAR(16);
DEFINE vNumTarjetaCheq  CHAR(16);
DEFINE v_ruta 			CHAR(200);
DEFINE vOpcionAcceso 	CHAR(15);
DEFINE vSucursal 		CHAR(4);
DEFINE vTarjeta 		CHAR(16);


--InicializaciÃÂ³n de variables
LET v_iNumeroEnvio = 0;
LET v_iTipoConsulta = '';
LET v_cOperacion = '';
LET v_cProducto = '';
LET vSecMax = 0;
LET cReCord = '00001';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cErrorInfo = 0;
LET v_cCodRetorno = '';	
LET v_cDigitos = '';
LET vCuota = '';
LET vCredito = '';
LET vCuenta = '';
LET iTieneCuenta = '0';
LET iTotal = 0;
LET vAno = ''; 
LET vMes = ''; 
LET vFechaCorte = '01-01-1900';
LET vCorreoELec = '';
LET vTipoCorreo = 0;
LET vStatusCorreo = '';
LET vTieneCorreo = '0';
LET vNumTarjetaCred  = '0';
LET vNumTarjetaCheq  = '0';
LET v_ruta = 'export PATH=/usr/java7_64/jre/bin:$PATH';
LET vOpcionAcceso = '';
LET vSucursal = '';
LET vTarjeta = '';

	-- SET DEBUG FILE TO "/tmp/yonaiker/Proyecto_Homologacion_697.1/sp_irma_cancelacion/sp_ivr_envia_edomov.out"; --- MODIFICAR RUTA DEL ARCHIVO
	-- SET DEBUG FILE TO "/tmp/Felix/modificaciones_status_acceso/envio.out";
	-- TRACE ON;

	BEGIN

	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		LET cReCord     = iSqlErr;
		END IF;
		RETURN cReCord, v_iNumeroEnvio, iTieneCuenta,vTieneCorreo;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
-- VERIFICA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS O NULLS
		IF ( p_cTipoConsulta is null OR p_cTipoConsulta = '' ) OR ( p_cCliente is null OR p_cCliente = '' ) OR ( p_cTelefono is null OR p_cTelefono = '') THEN
		RETURN cReCord, v_iNumeroEnvio, iTieneCuenta,vTieneCorreo;
		END IF;	
	
			--Realizar ejecuciÃÂ³n de SP 
			LET v_iTipoConsulta = LENGTH (p_cTipoConsulta);
			LET v_cDigitos =  TRIM(NVL(SUBSTR(p_cTipoConsulta, (LENGTH(TRIM(p_cTipoConsulta)) - 3), 4),'')); 
			--Validar Por DÃÂ©bito
			IF v_iTipoConsulta = 11 THEN
				LET v_cOperacion = 'ENV_EDOMOV_CUENTA';
				SELECT correo_elec, tipo_correo,status_correo 
				INTO vCorreoELec, vTipoCorreo, vStatusCorreo 
				FROM bdinteg:si_correos 
				WHERE numcte = p_cCliente 
				AND tipo_correo = 1 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) 
								FROM bdinteg:si_correos 
								WHERE numcte = p_cCliente 
								AND tipo_correo = 1 
								AND status_correo = 'A');
				--Validar si cuenta correo para realizar el envio de estado de movimiento
				IF	(vCorreoELec IS NOT NULL) OR (vCorreoELec <> '') AND (vTipoCorreo = 1) AND (vStatusCorreo = 'A') THEN
					LET vTieneCorreo = 1;
					SELECT c.producto, c.sucursal, t.num_tarjeta 
					INTO v_cProducto, vSucursal, vTarjeta 
					FROM bdicheq:"informix".sc_maechq c, bdicheq:"informix".sc_tarjeta t 
					WHERE c.cuenta = t.cuenta 
					AND c.cuenta = p_cTipoConsulta 
					AND t.tipo_tarjeta = 'T' 
					AND t.status_tar = 'A';
					
					IF v_cProducto IS NOT NULL OR v_cProducto <> '' THEN
						--Obtener el nÃÂºmero de Edo. de Movimientos que se han enviado al dÃÂ­a	
						SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} COUNT (cuenta) 
						INTO v_iNumeroEnvio 
						FROM bdiedoelec:edomov_ivr 
						WHERE id > 0
                        AND producto = v_cProducto 
						AND numcte = p_cCliente 
						AND cuenta = p_cTipoConsulta 
						AND fecha_modificacion = DATE(CURRENT);
						
							IF v_iNumeroEnvio < 3 THEN	
								LET cReCord = '00000'; ----->CÃÂ³digo de retorno correcto para un tipo consulta de cuenta
								LET v_iNumeroEnvio = v_iNumeroEnvio +1;
								INSERT INTO bdiedoelec:edomov_ivr (empresa,numcte,cuenta,credito,tarjeta,producto,fecha_corte,status_envio_edocta,fecha_modificacion) VALUES ('001',p_cCliente,p_cTipoConsulta,vCredito,'',v_cProducto,vFechaCorte,'AE',CURRENT);
									--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVE', p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;
							    	-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1',v_cDigitos,'','','','Envio Estado de Movimientos antes del corte','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
 									
									 
									IF vCorreoELec != '' THEN
										--NOTIFICACION EMAIL
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
									ELSE
										--NOTIFICACION SMS
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									END IF;

									SYSTEM 'echo "cd /resplogifx/conciliachq/" > /resplogifx/conciliachq/envedoctachq.sql';	
                                    SYSTEM 'echo "'||trim(v_ruta)||'" >> /resplogifx/conciliachq/envedoctachq.sql';	
	                                SYSTEM 'echo "java -jar envioMovimientos.jar '||''''''||' '||''''''||' '||TRIM(p_cTipoConsulta)||' '||''''''||' '||''''''||' '||TRIM(vCorreoELec)||'" >> /resplogifx/conciliachq/envedoctachq.sql'; 
                                    ---  SYSTEM '/usr/bin/chmod 777 /resplogifx/conciliachq/envedoctachq.sql';
	                                SYSTEM '. /resplogifx/conciliachq/envedoctachq.sql';
								
							ELSE
									--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;
									--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

									IF vCorreoELec != '' THEN
										--NOTIFICACION EMAIL
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
									ELSE
										--NOTIFICACION SMS
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									END IF;
							END IF;
							
							LET p_cTipoConsulta = vTarjeta;
							LET vOpcionAcceso = 'NUM_CTA_CAP';  --Se agrega opcion de acceso para Numero de Cuenta Captacion
					ELSE
						LET cReCord = '00001';
						/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1','','','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
						-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

						IF vCorreoELec != '' THEN
							--NOTIFICACION EMAIL
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
						ELSE
							--NOTIFICACION SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
						END IF;
					END IF;
				ELSE
					/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
					-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

					
					IF vCorreoELec != '' THEN
						--NOTIFICACION EMAIL
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
					ELSE
						--NOTIFICACION SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
					END IF;
				END IF;
			--Validar por CrÃÂ©dito			
			ELIF v_iTipoConsulta = 12 THEN
				LET v_cOperacion = 'ENV_EDOMOV_CREDITO';
				SELECT correo_elec, tipo_correo,status_correo 
				INTO vCorreoELec, vTipoCorreo, vStatusCorreo 
				FROM bdinteg:si_correos 
				WHERE numcte = p_cCliente 
				AND tipo_correo = 1 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) 
								FROM bdinteg:si_correos 
								WHERE numcte = p_cCliente 
								AND tipo_correo = 1 
								AND status_correo = 'A');
				--Validar si cuenta correo para realizar el envio de estado de movimiento
				IF	(vCorreoELec IS NOT NULL) OR (vCorreoELec <> '') AND (vTipoCorreo = 1) AND (vStatusCorreo = 'A') THEN
					LET vTieneCorreo = 1;
					SELECT c.num_producto, c.sucursal, t.num_tarjeta 
					INTO v_cProducto, vSucursal, vTarjeta 
					FROM bdicred:"informix".sd_maecred c, bdicred:"informix".sd_tarjeta t 
					WHERE c.num_credito = t.num_credito
					AND c.num_credito = p_cTipoConsulta 
					AND c.numcte = p_cCliente 
					AND t.tipo_tarjeta = 'T' 
					AND t.status_tar = 'A';
					
					IF v_cProducto IS NOT NULL or v_cProducto <> '' THEN
						SELECT dia_cuota 
						INTO vCuota 
						FROM bdicred:sd_definicion 
						WHERE num_producto = v_cProducto;
						
						IF vCuota is NOT NULL OR vCuota <> '' THEN
							SELECT first 1 YEAR(current),LPAD(MONTH(current)-1 ,2,0)
                            INTO vAno,vMes 
							FROM bdicred:sd_definicion
                            WHERE num_producto >= '6001';
							
							LET vFechaCorte = vMes||'-'||vCuota||'-'||vAno;							
							--Obtener el nÃÂºmero de Edo. de Movimientos que se han enviado al dÃÂ­a
							SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} COUNT (credito) 
							INTO v_iNumeroEnvio 
							FROM bdiedoelec:edomov_ivr
							WHERE id > 0
                            AND producto = v_cProducto 
							AND numcte = p_cCliente 
							AND credito = p_cTipoConsulta 
							AND fecha_modificacion = DATE(CURRENT);
							
								IF v_iNumeroEnvio < 3 THEN	
									LET cReCord = '00000'; ----->CÃÂ³digo de retorno correcto para un tipo de consulta de crÃÂ©dito
									LET v_iNumeroEnvio = v_iNumeroEnvio +1;
									INSERT INTO bdiedoelec:edomov_ivr (empresa,numcte,cuenta,credito,tarjeta,producto,fecha_corte,status_envio_edocta,fecha_modificacion) VALUES ('001',p_cCliente,'',p_cTipoConsulta,'',v_cProducto,vFechaCorte,'AE',CURRENT);
									
									/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVE', p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
									
									-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1',v_cDigitos,'','','','Envio Estado de Movimientos antes del corte','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									
 									
									IF vCorreoELec != '' THEN
										--NOTIFICACION EMAIL
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
									ELSE
										--NOTIFICACION SMS
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									END IF;

									SYSTEM 'echo "cd /resplogifx/conciliachq/" > /resplogifx/conciliachq/envedoctachq.sql';	
                                    SYSTEM 'echo "'||trim(v_ruta)||'" >> /resplogifx/conciliachq/envedoctachq.sql';	
	                                SYSTEM 'echo "java -jar envioMovimientos.jar '||''''''||' '||''''''||' '||TRIM(p_cTipoConsulta)||' '||''''''||' '||''''''||' '||TRIM(vCorreoELec)||'" >> /resplogifx/conciliachq/envedoctachq.sql'; 
                                    ---SYSTEM '/usr/bin/chmod 777 /resplogifx/conciliachq/envedoctachq.sql';
	                                SYSTEM '. /resplogifx/conciliachq/envedoctachq.sql';

								ELSE
									/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
									-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;


									IF vCorreoELec != '' THEN
										--NOTIFICACION EMAIL
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
									ELSE
										--NOTIFICACION SMS
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									END IF;
								END IF;
								
								LET p_cTipoConsulta = vTarjeta;
								LET vOpcionAcceso = 'NUM_CTA_CRED';  --Se agrega opcion de acceso para Numero de Cuenta Credito
						ELSE
							LET cReCord = '00001';
							/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
							-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

							IF vCorreoELec != '' THEN
								--NOTIFICACION EMAIL
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
							ELSE
								--NOTIFICACION SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
							END IF;
						END IF;
					ELSE
						LET cReCord = '00001';
						/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
						-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

						
						IF vCorreoELec != '' THEN
							--NOTIFICACION EMAIL
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
						ELSE
							--NOTIFICACION SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
						END IF;
					END IF;
				ELSE
					LET cReCord = '00001'; 
					/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
					-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

					
					IF vCorreoELec != '' THEN
						--NOTIFICACION EMAIL
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
					ELSE
						--NOTIFICACION SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
					END IF;
				END IF;
				
			--Validar por Tarjeta
			ELIF v_iTipoConsulta = 16 THEN
				LET v_cOperacion = 'ENV_EDOMOV_TARJETA';
				SELECT correo_elec, tipo_correo,status_correo 
				INTO vCorreoELec, vTipoCorreo, vStatusCorreo 
				FROM bdinteg:si_correos 
				WHERE numcte = p_cCliente 
				AND tipo_correo = 1 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) 
								FROM bdinteg:si_correos 
								WHERE numcte = p_cCliente 
								AND tipo_correo = 1 
								AND status_correo = 'A');
				--Validar si cuenta correo para realizar el envio de estado de movimiento
				IF	(vCorreoELec IS NOT NULL) OR (vCorreoELec <> '') AND (vTipoCorreo = 1) AND (vStatusCorreo = 'A') THEN
					LET vTieneCorreo = 1;
					
						SELECT num_tarjeta 
						INTO vNumTarjetaCheq  
						FROM bdicheq: sc_tarjeta 
						WHERE num_tarjeta = p_cTipoConsulta 
						AND tipo_tarjeta = 'T' 
						AND status_tar = 'A';
						
						SELECT num_tarjeta 
						INTO vNumTarjetaCred 
						FROM bdicred:sd_tarjeta
						WHERE num_tarjeta = p_cTipoConsulta 
						AND tipo_tarjeta = 'T' 
						AND status_tar = 'A';
						
					IF vNumTarjetaCred <> 0 THEN
						SELECT t.num_credito, t.prodtarjeta, c.sucursal 
						INTO vCredito, v_cProducto, vSucursal 
						FROM bdicred:"informix".sd_tarjeta t, bdicred:"informix".sd_maecred c 
						WHERE t.num_credito = c.num_credito 
						AND t.num_tarjeta = p_cTipoConsulta 
						AND t.numcte = c.numcte 
						AND t.tipo_tarjeta = 'T' 
						AND t.status_tar = 'A';
						
						SELECT dia_cuota 
						INTO vCuota 
						FROM bdicred:sd_definicion 
						WHERE num_producto = v_cProducto;
						
						IF vCuota is NOT NULL OR vCuota <> '' THEN
							SELECT first 1 YEAR(current),LPAD(MONTH(current)-1 ,2,0)
                            INTO vAno,vMes 
                            FROM bdicred: sd_definicion
                            WHERE num_producto >= '6001';
                            
							LET vFechaCorte = vMes||'-'||vCuota||'-'||vAno;
							--Obtener el nÃÂºmero de Edo. de Movimientos que se han enviado al dÃÂ­a
							SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} COUNT (credito) 
							INTO v_iNumeroEnvio 
							FROM bdiedoelec:edomov_ivr 
							WHERE id > 0
                            AND producto = v_cProducto 
							AND numcte = p_cCliente 
							AND credito = vCredito 
							AND fecha_modificacion = DATE(CURRENT);
							
								IF v_iNumeroEnvio < 3 THEN	 	
									LET cReCord = '00000'; ----->CÃÂ³digo de retorno correcto para un tipo consulta de tarjeta
									LET v_iNumeroEnvio = v_iNumeroEnvio +1;
									INSERT INTO bdiedoelec:edomov_ivr (empresa,numcte,cuenta,credito,tarjeta,producto,fecha_corte,status_envio_edocta,fecha_modificacion) VALUES ('001',p_cCliente,'',vCredito,p_cTipoConsulta,v_cProducto,vFechaCorte,'AE',CURRENT);
									/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVE', p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
									-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1',v_cDigitos,'','','','Envio Estado de Movimientos antes del corte','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

									IF vCorreoELec != '' THEN
										--NOTIFICACION EMAIL
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
									ELSE
										--NOTIFICACION SMS
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
									END IF;
								    
									SYSTEM 'echo "cd /resplogifx/conciliachq/" > /resplogifx/conciliachq/envedoctachq.sql';	
                                    SYSTEM 'echo "'||trim(v_ruta)||'" >> /resplogifx/conciliachq/envedoctachq.sql';	
	                                SYSTEM 'echo "java -jar envioMovimientos.jar '||''''''||' '||''''''||' '||TRIM(vCredito)||' '||''''''||' '||''''''||' '||TRIM(vCorreoELec)||'" >> /resplogifx/conciliachq/envedoctachq.sql'; 
                                    ---SYSTEM '/usr/bin/chmod 777 /resplogifx/conciliachq/envedoctachq.sql';
	                                SYSTEM '. /resplogifx/conciliachq/envedoctachq.sql';
									
							   END IF;
							   
							   LET vOpcionAcceso = 'NUM_TDC';  --Se agrega opcion de acceso para Tarjeta de Credito
						ELSE
							LET cReCord = '00001';
							/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
							-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

							
							IF vCorreoELec != '' THEN
								--NOTIFICACION EMAIL
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
							ELSE
								--NOTIFICACION SMS
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
							END IF;
						END IF;
					
					ELIF vNumTarjetaCheq <> 0 THEN
						SELECT t.prodtarjeta, t.cuenta, c.sucursal 
						INTO v_cProducto, vCuenta, vSucursal 
						FROM bdicheq:"informix".sc_tarjeta t, bdicheq:"informix".sc_maechq c 
						WHERE t.cuenta = c.cuenta 
						AND t.num_tarjeta = p_cTipoConsulta 
						AND t.numcte = c.num_cte 
						AND t.tipo_tarjeta = 'T' 
						AND t.status_tar = 'A';
						
						SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} COUNT (cuenta) 
						INTO v_iNumeroEnvio 
						FROM bdiedoelec:edomov_ivr 
						WHERE id > 0
                        AND producto = v_cProducto 
						AND numcte = p_cCliente 
						AND cuenta = vCuenta 
						AND fecha_modificacion = DATE(CURRENT);
						
							IF v_iNumeroEnvio < 3 THEN
								LET cReCord = '00000'; ----->CÃÂ³digo de retorno correcto para un tipo consulta de tarjeta
								LET v_iNumeroEnvio = v_iNumeroEnvio +1;
								INSERT INTO bdiedoelec:edomov_ivr (empresa,numcte,cuenta,credito,tarjeta,producto,fecha_corte,status_envio_edocta,fecha_modificacion) VALUES ('001',p_cCliente,vCuenta,'',p_cTipoConsulta,v_cProducto,vFechaCorte,'AE',CURRENT);
								/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVE', p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
								
								-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1',v_cDigitos,'','','','Envio Estado de Movimientos antes del corte','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;


								IF vCorreoELec != '' THEN
									--NOTIFICACION EMAIL
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
								ELSE
									--NOTIFICACION SMS
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
								END IF;

								SYSTEM 'echo "cd /resplogifx/conciliachq/" > /resplogifx/conciliachq/envedoctachq.sql';	
                                SYSTEM 'echo "'||trim(v_ruta)||'" >> /resplogifx/conciliachq/envedoctachq.sql';	
	                            SYSTEM 'echo "java -jar envioMovimientos.jar '||''''''||' '||''''''||' '||TRIM(vCuenta)||' '||''''''||' '||''''''||' '||TRIM(vCorreoELec)||'" >> /resplogifx/conciliachq/envedoctachq.sql'; 
                                --SYSTEM '/usr/bin/chmod 777 /resplogifx/conciliachq/envedoctachq.sql';
	                            SYSTEM '. /resplogifx/conciliachq/envedoctachq.sql';
								
							ELSE
								LET cReCord = '00001';
								/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
								-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

								IF vCorreoELec != '' THEN
									--NOTIFICACION EMAIL
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
								ELSE
									--NOTIFICACION SMS
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
								END IF;
							END IF;
							
							LET vOpcionAcceso = 'NUM_TDD';  --Se agrega opcion de acceso para Tarjeta de Debito
					ELSE
						LET cReCord = '00001';
						/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO 		v_cCodRetorno;*/
						-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

						IF vCorreoELec != '' THEN
							--NOTIFICACION EMAIL
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
						ELSE
							--NOTIFICACION SMS
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
						END IF;
					END IF;
				ELSE
					LET cReCord = '00001';
					/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
					-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

					IF vCorreoELec != '' THEN
						--NOTIFICACION EMAIL
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
					ELSE
						--NOTIFICACION SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
					END IF;
				END IF;
					
			ELSE
				LET cReCord = '00002'; ----->CÃÂ³digo de retorno cuando se recibe un tipo consulta diferente de 11, 12 o 16
				/*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','IVR_EDOMVN',p_cCliente,p_cTipoConsulta,'','1',v_cDigitos,'','','','','','','','','','',p_cTelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND) INTO v_cCodRetorno;*/
				-- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVN',p_cCliente,'','','1','','','','','','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;

				
				IF vCorreoELec != '' THEN
					--NOTIFICACION EMAIL
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','EMAIL_IVR','IVR_CONSM_EM',p_cCliente,'','','1','','','','','Consulta de Movimientos de tus Cuentas','','','','','',vCorreoELec,'',1,0,0,0,0,CURRENT,'') INTO v_cCodRetorno;
				ELSE
					--NOTIFICACION SMS
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','IVR_ALTA','IVR_EDOMVE',p_cCliente,'','','1','','','','','envio de Consulta de Movimientos','','','','','','',p_cTelefono,1,0,0,0,0,'','') INTO v_cCodRetorno;
				END IF;
			END IF
			
			--Calcular valor de secuencia de bitacora	
				SELECT MAX(secuencia)
				INTO vSecMax
				FROM bdinteg: si_bitacora_ivr
				WHERE DATE(fecha_oper) = CURRENT::DATE
				AND telefono = p_cTelefono;

				IF vSecMax is null THEN
					LET vSecMax = 0;
				END IF;

				LET vSecMax = vSecMax + 1;
			
			--Realizar registro en bitacora con los datos correspondientes			
			IF cReCord = '00000' THEN
				INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal)
				VALUES (CURRENT, vSecMax, v_cOperacion, p_cTipoConsulta, p_cCliente, p_cTelefono, vOpcionAcceso, vSucursal);
			ELSE
				INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal) 
				VALUES (CURRENT, vSecMax, 'NE', '', '', p_cTelefono, vOpcionAcceso, '');	
			END IF;
		
			FOREACH WITH HOLD				 
								
					SELECT  count (num_credito) INTO iTotal
					FROM bdicred:"informix".sd_maecred 
																				 
					WHERE numcte = p_cCliente
					AND status_cred IN ('BT','AA','BA','E1','E2','E3')
													
					AND num_credito NOT IN(	
				SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} credito FROM bdiedoelec:edomov_ivr WHERE id > 0 AND numcte = p_cCliente AND fecha_modificacion = DATE(CURRENT))
					union
					select count(num_credito)
					FROM bdicred:"informix".sd_maecredcrd
					WHERE status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
					AND numcte =  p_cCliente
					AND num_credito NOT IN(	
				SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} credito FROM bdiedoelec: edomov_ivr WHERE id > 0 AND numcte = p_cCliente AND fecha_modificacion = DATE(CURRENT))
					union 
					SELECT count (cuenta)
					FROM bdicheq:"informix".sc_maechq 
					WHERE num_cte = p_cCliente
					AND status_cta = '1' 
					AND cuenta not in (
					SELECT {+INDEX(bdiedoelec:edomov_ivr idx_edomov_ivr)} cuenta FROM bdiedoelec: edomov_ivr WHERE id > 0 AND numcte = p_cCliente AND fecha_modificacion = DATE(CURRENT))
										
					IF iTotal > 0 THEN
						LET iTieneCuenta = 1;
						EXIT FOREACH;
					END IF;
					
			END FOREACH;
			
			IF vTieneCorreo = 0 THEN
				LET cReCord = '00080';			
			END IF;
			
			RETURN cReCord, v_iNumeroEnvio, iTieneCuenta,vTieneCorreo;

	END
END PROCEDURE
DOCUMENT
'Registra evento de envÃÂ­o de estado movimiento para que latinia haga el envÃÂ­o de estado de movimientos a los clientes',
'AUTOR : Heriberto Torres',
'FECHA : 12/10/2017',
'BD    : BDIVR',
'Modifico: Ricardo gabriel roman garcia',
'Se quitaron los trim, select case y if exist',
'Fecha : 2019/04/24',
'Modifico: Mireya Rodriguez',
'DescripciÃÂ³n: Se agregaron las variables vTarjeta para obtener el numero de tarjeta del cliente, vOpcionAcceso para validar la opciÃÂ³n por la que acceso el cliente y vSucursal para conocer a que sucursal pertenece la opciÃÂ³n y registrarlo en la bitacora mensual de IVR',
'Fecha: 2019/08/09',
'Modifico: Felix Gonzalez',
'DescripciÃÂ³n: Se cambio leyenda de mensaje en registraevento',
'Fecha: 2019/08/09',
'Modifico: Felix Gonzalez',
'DescripciÃÂ³n: Modificacion de plantillas de sms y correo por folio 698',
'Fecha : 2020/08/12',
'Modifico: Yonaiker Morillo',
'Folio: 697.1',
'DescripciÃÂ³n: Se modifica para agregar insercion en bitacora en caso de error, y secuencia buscada por telefono para que la informacion llegue a bitacora lo mas correctamente posible',
'Fecha : 2020/10/13';

CREATE PROCEDURE "informix".ivr_consulta_saldos(p_caracteres SMALLINT, p_numtarjeta CHAR(16), p_cuenta CHAR(11), p_num_credito CHAR(12), p_numcte CHAR(9), p_otrascuentas CHAR(1), pTelefono CHAR(10)) 
RETURNING 	CHAR (5) AS Cod_Retorno,
			CHAR(1) AS otras_ctas,
			
           -- CHAR(4) AS prodInfinite,
			CHAR(4) AS producto1,
			CHAR (2) AS tipo1,			
			CHAR(20) AS cuenta1, 
			CHAR(4) AS Terminacioncuenta1,
			MONEY(14,2) AS Saldo_disponible1,
			MONEY(14,2) AS Pago_minimo1,
			MONEY(14,2) AS Pago_No_Int1,
			DATE AS Fecha_LimitPago1,
			
			CHAR(4) AS producto2,
			CHAR (2) AS tipo2,			
			CHAR(20) AS cuenta2, 
			CHAR(4) AS Terminacioncuenta2,
			MONEY(14,2) AS Saldo_disponible2,
			MONEY(14,2) AS Pago_minimo2,
			MONEY(14,2) AS Pago_No_Int2,			
			DATE AS Fecha_LimitPago2,
			
			CHAR(4) AS producto3,
			CHAR (2) AS tipo3,			
			CHAR(20) AS cuenta3, 
			CHAR(4) AS Terminacioncuenta3,
			MONEY(14,2) AS Saldo_disponible3,
			MONEY(14,2) AS Pago_minimo3,
			MONEY(14,2) AS Pago_No_Int3,			
			DATE AS Fecha_LimitPago3,
			
			CHAR(4) AS producto4,
			CHAR (2) AS tipo4,			
			CHAR(20) AS cuenta4, 
			CHAR(4) AS Terminacioncuenta4,
			MONEY(14,2) AS Saldo_disponible4,
			MONEY(14,2) AS Pago_minimo4,
			MONEY(14,2) AS Pago_No_Int4,		
			DATE AS Fecha_LimitPago4,
			
			CHAR(4) AS producto5,
			CHAR (2) AS tipo5,			
			CHAR(20) AS cuenta5, 
			CHAR(4) AS Terminacioncuenta5,
			MONEY(14,2) AS Saldo_disponible5,
			MONEY(14,2) AS Pago_minimo5,
			MONEY(14,2) AS Pago_No_Int5,			
			DATE AS Fecha_LimitPago5,
			
			CHAR(4) AS producto6,
			CHAR (2) AS tipo6,			
			CHAR(20) AS cuenta6, 
			CHAR(4) AS Terminacioncuenta6,
			MONEY(14,2) AS Saldo_disponible6,
			MONEY(14,2) AS Pago_minimo6,
			MONEY(14,2) AS Pago_No_Int6,			
			DATE AS Fecha_LimitPago6,
			
			CHAR(4) AS producto7,
			CHAR (2) AS tipo7,			
			CHAR(20) AS cuenta7, 
			CHAR(4) AS Terminacioncuenta7,
			MONEY(14,2) AS Saldo_disponible7,
			MONEY(14,2) AS Pago_minimo7,
			MONEY(14,2) AS Pago_No_Int7,			
			DATE AS Fecha_LimitPago7,
			
			CHAR(4) AS producto8,
			CHAR (2) AS tipo8,			
			CHAR(20) AS cuenta8, 
			CHAR(4) AS Terminacioncuenta8,
			MONEY(14,2) AS Saldo_disponible8,
			MONEY(14,2) AS Pago_minimo8,
			MONEY(14,2) AS Pago_No_Int8,			
			DATE AS Fecha_LimitPago8,
			
			CHAR(4) AS producto9,
			CHAR (2) AS tipo9,			
			CHAR(20) AS cuenta9, 
			CHAR(4) AS Terminacioncuenta9,
			MONEY(14,2) AS Saldo_disponible9,
			MONEY(14,2) AS Pago_minimo9,
			MONEY(14,2) AS Pago_No_Int9,			
			DATE AS Fecha_LimitPago9,
			
			CHAR(4) AS producto10,
			CHAR (2) AS tipo10,			
			CHAR(20) AS cuenta10, 
			CHAR(4) AS Terminacioncuenta10,
			MONEY(14,2) AS Saldo_disponible10,
			MONEY(14,2) AS Pago_minimo10,
			MONEY(14,2) AS Pago_No_Int10,			
			DATE AS Fecha_LimitPago10;
			
	DEFINE cod_ret     		CHAR(5);
	DEFINE vOtrasCtas      	CHAR(1);
	
    DEFINE prodInfinite         CHAR(4);
	DEFINE vProducto 			CHAR(4); 
	DEFINE vtipo				CHAR(2); 
	DEFINE vCuenta 				CHAR(16); 
	DEFINE iTerminacioncuenta  	CHAR(4); 
	DEFINE vSdoDisp       		MONEY(14,2); 
	DEFINE vPagoMin        		MONEY(14,2);
	DEFINE vPagoNoInt      		MONEY(14,2);
	DEFINE vFechLimPago    		DATE;
		
	DEFINE vProducto1 			CHAR(4); 
	DEFINE vtipo1				CHAR(2); 
	DEFINE vCuenta1 			CHAR(16); 
	DEFINE iTerminacioncuenta1  CHAR(4); 
	DEFINE vSdoDisp1       		MONEY(14,2); 
	DEFINE vPagoMin1        	MONEY(14,2);
	DEFINE vPagoNoInt1      	MONEY(14,2);
	DEFINE vFechLimPago1    	DATE;

	DEFINE vProducto2 			CHAR(4);
	DEFINE vtipo2				CHAR(2);
	DEFINE vCuenta2 			CHAR(16);
	DEFINE iTerminacioncuenta2  CHAR(4);
	DEFINE vSdoDisp2       		MONEY(14,2);
	DEFINE vPagoMin2        	MONEY(14,2);
	DEFINE vPagoNoInt2      	MONEY(14,2);
	DEFINE vFechLimPago2    	DATE;

	DEFINE vProducto3 			CHAR(4);
	DEFINE vtipo3				CHAR(2);
	DEFINE vCuenta3 			CHAR(16);
	DEFINE iTerminacioncuenta3  CHAR(4);
	DEFINE vSdoDisp3       		MONEY(14,2);
	DEFINE vPagoMin3        	MONEY(14,2);
	DEFINE vPagoNoInt3      	MONEY(14,2);
	DEFINE vFechLimPago3    	DATE;

	DEFINE vProducto4 			CHAR(4);
	DEFINE vtipo4				CHAR(2);
	DEFINE vCuenta4 			CHAR(16);
	DEFINE iTerminacioncuenta4  CHAR(4);
	DEFINE vSdoDisp4       		MONEY(14,2);
	DEFINE vPagoMin4        	MONEY(14,2);
	DEFINE vPagoNoInt4      	MONEY(14,2);
	DEFINE vFechLimPago4    	DATE;

	DEFINE vProducto5 			CHAR(4);
	DEFINE vtipo5				CHAR(2);
	DEFINE vCuenta5 			CHAR(16);
	DEFINE iTerminacioncuenta5  CHAR(4);
	DEFINE vSdoDisp5       		MONEY(14,2);
	DEFINE vPagoMin5        	MONEY(14,2);
	DEFINE vPagoNoInt5      	MONEY(14,2);
	DEFINE vFechLimPago5    	DATE;

	DEFINE vProducto6 			CHAR(4);
	DEFINE vtipo6				CHAR(2);
	DEFINE vCuenta6 			CHAR(16);
	DEFINE iTerminacioncuenta6  CHAR(4);
	DEFINE vSdoDisp6       		MONEY(14,2);
	DEFINE vPagoMin6        	MONEY(14,2);
	DEFINE vPagoNoInt6      	MONEY(14,2);
	DEFINE vFechLimPago6    	DATE;

	DEFINE vProducto7 			CHAR(4);
	DEFINE vtipo7				CHAR(2);
	DEFINE vCuenta7 			CHAR(16);
	DEFINE iTerminacioncuenta7  CHAR(4);
	DEFINE vSdoDisp7       		MONEY(14,2);
	DEFINE vPagoMin7        	MONEY(14,2);
	DEFINE vPagoNoInt7      	MONEY(14,2);
	DEFINE vFechLimPago7    	DATE;

	DEFINE vProducto8 			CHAR(4);
	DEFINE vtipo8				CHAR(2);
	DEFINE vCuenta8 			CHAR(16);
	DEFINE iTerminacioncuenta8  CHAR(4);
	DEFINE vSdoDisp8       		MONEY(14,2);
	DEFINE vPagoMin8        	MONEY(14,2);
	DEFINE vPagoNoInt8      	MONEY(14,2);
	DEFINE vFechLimPago8    	DATE;

	DEFINE vProducto9 			CHAR(4);
	DEFINE vtipo9				CHAR(2);
	DEFINE vCuenta9 			CHAR(16);
	DEFINE iTerminacioncuenta9  CHAR(4);
	DEFINE vSdoDisp9       		MONEY(14,2);
	DEFINE vPagoMin9        	MONEY(14,2);
	DEFINE vPagoNoInt9      	MONEY(14,2);
	DEFINE vFechLimPago9    	DATE;

	DEFINE vProducto10 			CHAR(4);
	DEFINE vtipo10				CHAR(2);
	DEFINE vCuenta10 			CHAR(16);
	DEFINE iTerminacioncuenta10 CHAR(4);
	DEFINE vSdoDisp10       	MONEY(14,2);
	DEFINE vPagoMin10        	MONEY(14,2);
	DEFINE vPagoNoInt10      	MONEY(14,2);
	DEFINE vFechLimPago10    	DATE;
	
	DEFINE sql_err      		SMALLINT;
	DEFINE vNumtarjeta 			CHAR(16);		
		-- CONS_SDOS1	
	DEFINE vcod_ret             char(5);
	DEFINE vnum_cte             char(20);
	DEFINE vapell_pat           char(26);
	DEFINE vapell_mat           char(26);
	DEFINE vnombre1             char(26);
	DEFINE vnombre2             char(26);
	DEFINE vrazon_soc           char(60);
	DEFINE vedo_cta             char(1);	
	DEFINE cSdo_ret             money(14,2);
	DEFINE vsdo_ccc             money(14,2);
	DEFINE vsdo_disp_ccc        money(14,2);
	DEFINE vsdo_cta             money(14,2);
	DEFINE vtipo_linea          char(1);
	DEFINE vdescrip1            char(40);
	DEFINE vdescrip2            char(40);
	DEFINE vsdo_t1              money(14,2);
	DEFINE vsdo_cong            money(14,2);
	DEFINE vimp_chq_sbc         money(14,2);
	DEFINE vusubloq             char(8);
	DEFINE vfecbloq             date;
	DEFINE vnum_tarjeta         char(16);
	DEFINE vcta_clabe           char(18);
	DEFINE CodRet				CHAR(5);
	DEFINE vSistema 			CHAR(2);	
	DEFINE vCodRetSdoCorte      CHAR(5);   
    DEFINE vcodret_sdos         CHAR(6);
    DEFINE vnumcredito          CHAR(20);
    DEFINE vcodigo_tipcred      CHAR(2);
    DEFINE vfecha_origen        DATE;
    DEFINE vfecha_prox_pago     DATE;
    DEFINE vfecha_ult_pago      DATE;
    DEFINE vplazo               INTEGER;
    DEFINE vpagos_realizados    INTEGER;
    DEFINE vlinea_otorgada      DECIMAL(18,2);
    DEFINE vtasa_interes        DECIMAL(9,6);
    DEFINE vtasa_moratorios     DECIMAL(9,6);
    DEFINE vmonto_sbc           DECIMAL(14,2);
    DEFINE vcap_vig             DECIMAL(18,2);
    DEFINE vcap_trans           DECIMAL(18,2);
    DEFINE vcap_vdo_exig        DECIMAL(18,2);
    DEFINE vcap_vdo_no_exig     DECIMAL(18,2);
    DEFINE vsdo_act_total_cap   DECIMAL(18,2);
    DEFINE vint_vig             DECIMAL(18,2);
    DEFINE vint_vdo             DECIMAL(18,2);
    DEFINE vint_moratorios      DECIMAL(18,2);
    DEFINE vint_mes             DECIMAL(18,2);
    DEFINE vsdo_act_total_int   DECIMAL(18,2);
    DEFINE viva_int_vig         DECIMAL(18,2);
    DEFINE viva_int_vdo         DECIMAL(18,2);
    DEFINE viva_int_moratorios  DECIMAL(18,2);
    DEFINE viva_int_mes         DECIMAL(18,2);
    DEFINE vsdo_act_total_iva   DECIMAL(18,2);
    DEFINE vcom_pend            DECIMAL(18,2);
    DEFINE viva_com             DECIMAL(18,2);
    DEFINE vsdo_retenido        DECIMAL(18,2);
    DEFINE vint_devengado       DECIMAL(18,2);
    DEFINE viva_int_devengado   DECIMAL(18,2);
    DEFINE vlinea_disponible    DECIMAL(18,2);
    DEFINE vpagos_vdos          DECIMAL(18,2);
    DEFINE vdesc_status_cred    CHAR(60);
    DEFINE vid_bloqueo_cred     INTEGER;
    DEFINE vbloqueo_cta         CHAR(60);
    DEFINE vid_causa_bloqueo_cred CHAR(3);
    DEFINE vcausa_bloqueo_cta   CHAR(50);
    DEFINE vid_sit_esp_cte      CHAR(1);
    DEFINE vid_causa_esp_cte    INTEGER;
    DEFINE vsit_esp_cte         CHAR(75);
    DEFINE vid_sit_esp_cred     CHAR(1);
    DEFINE vid_causa_esp_cred   INTEGER;
    DEFINE vsit_esp_cred        CHAR(75);		
    DEFINE vmensaje_sdos        CHAR(80);  
    DEFINE vSecMax         		INTEGER;
	--DEFINE vTelefono 			CHAR(13);
	DEFINE iContador			SMALLINT;
	DEFINE sTipoconsulta		CHAR(30);
	DEFINE iProdInvalido		INTEGER; --#CVA_20190327.1014'
	DEFINE viExisMasCtas 		INTEGER;
	DEFINE iResConsulta 		INTEGER; --#CVA_20190327.1014'
	DEFINE vOpcionAcceso CHAR(15);
	DEFINE vSucursal    CHAR(4);
	DEFINE vSucursalTarj CHAR(4);
	--AsignaciÃÂÃÂ³n de Valor a las variables.
	LET cod_ret 			  	= "00000";
	LET vOtrasCtas   			= '0';	
    LET prodInfinite            = "5400";	
	LET vProducto 				= "";
	LET vtipo					= "";
	LET vCuenta      			= '';
	LET iTerminacioncuenta   	="0000";
	LET vSdoDisp     			= 0.00;
	LET vPagoMin     			= 0.00;
	LET vPagoNoInt   			= 0.00;
	LET vFechLimPago 			= '01-01-1990';
	
	LET vProducto1 				= "";
	LET vtipo1					= "";
	LET vCuenta1      			= '';
	LET iTerminacioncuenta1   	="";
	LET vSdoDisp1     			= 0.00;
	LET vPagoMin1     			= 0.00;
	LET vPagoNoInt1   			= 0.00;
	LET vFechLimPago1 			= ''; 
	
	LET vProducto2 				= "";
	LET vtipo2					= "";
	LET vCuenta2      			= '';
	LET iTerminacioncuenta2   	="";
	LET vSdoDisp2     			= 0.00;
	LET vPagoMin2     			= 0.00;
	LET vPagoNoInt2   			= 0.00;
	LET vFechLimPago2 			= ''; 
	
	LET vProducto3 				= "";
	LET vtipo3					= "";
	LET vCuenta3      			= '';
	LET iTerminacioncuenta3   	="";
	LET vSdoDisp3     			= 0.00;
	LET vPagoMin3     			= 0.00;
	LET vPagoNoInt3   			= 0.00;
	LET vFechLimPago3 			= ''; 
	
	LET vProducto4 				= "";
	LET vtipo4					= "";
	LET vCuenta4      			= '';
	LET iTerminacioncuenta4   	="";
	LET vSdoDisp4     			= 0.00;
	LET vPagoMin4     			= 0.00;
	LET vPagoNoInt4   			= 0.00;
	LET vFechLimPago4 			= ''; 
	
	LET vProducto5 				= "";
	LET vtipo5					= "";
	LET vCuenta5      			= '';
	LET iTerminacioncuenta5   	="";
	LET vSdoDisp5     			= 0.00;
	LET vPagoMin5     			= 0.00;
	LET vPagoNoInt5   			= 0.00;
	LET vFechLimPago5 			= ''; 
	
	LET vProducto6 				= "";
	LET vtipo6					= "";
	LET vCuenta6      			= '';
	LET iTerminacioncuenta6   	="";
	LET vSdoDisp6     			= 0.00;
	LET vPagoMin6     			= 0.00;
	LET vPagoNoInt6   			= 0.00;
	LET vFechLimPago6 			= ''; 
	
	LET vProducto7 				= "";
	LET vtipo7					= "";
	LET vCuenta7      			= '';
	LET iTerminacioncuenta7   	="";
	LET vSdoDisp7     			= 0.00;
	LET vPagoMin7     			= 0.00;
	LET vPagoNoInt7   			= 0.00;
	LET vFechLimPago7 			= ''; 
	
	LET vProducto8 				= "";
	LET vtipo8					= "";
	LET vCuenta8     			= '';
	LET iTerminacioncuenta8   	="";
	LET vSdoDisp8     			= 0.00;
	LET vPagoMin8     			= 0.00;
	LET vPagoNoInt8   			= 0.00;
	LET vFechLimPago8 			= ''; 
	
	LET vProducto9 				= "";
	LET vtipo9					= "";
	LET vCuenta9      			= '';
	LET iTerminacioncuenta9   	="";
	LET vSdoDisp9     			= 0.00;
	LET vPagoMin9     			= 0.00;
	LET vPagoNoInt9   			= 0.00;
	LET vFechLimPago9 			= ''; 
	
	LET vProducto10 			= "";
	LET vtipo10					= "";
	LET vCuenta10      			= '';
	LET iTerminacioncuenta10   	="";
	LET vSdoDisp10     			= 0.00;
	LET vPagoMin10     			= 0.00;
	LET vPagoNoInt10   			= 0.00;
	LET vFechLimPago10 			= '';
	
	LET vtipo1					= "";
	--LET vTelefono				= '';	
	LET vSecMax      			= 0;
    LET Sql_Err	 				= 0;    
    LET viExisMasCtas 			= 0;
    LET vcodret_sdos           	= '';
    LET vmensaje_sdos          	= '';
    LET vnumcredito            	= '';
    LET vcodigo_tipcred        	= '';
    LET vfecha_origen          	= '';
    LET vfecha_prox_pago       	= '';
    LET vfecha_ult_pago       	= '';
    LET vplazo                 	= 0;
    LET vpagos_realizados      	= 0;
    LET vlinea_otorgada        	= 0;
    LET vtasa_interes          	= 0;
    LET vtasa_moratorios       	= 0;
    LET vmonto_sbc             	= 0;
    LET vcap_vig               	= 0;
    LET vcap_trans             	= 0;
    LET vcap_vdo_exig          	= 0;
    LET vcap_vdo_no_exig       	= 0;
    LET vsdo_act_total_cap     	= 0;
    LET vint_vig               	= 0;
    LET vint_vdo               	= 0;
    LET vint_moratorios        	= 0;
    LET vint_mes               	= 0;
    LET vsdo_act_total_int     	= 0;
    LET viva_int_vig           	= 0;
    LET viva_int_vdo           	= 0;
    LET viva_int_moratorios    	= 0;
    LET viva_int_mes           	= 0;
    LET vsdo_act_total_iva     	= 0;
    LET vcom_pend              	= 0;
    LET viva_com               	= 0;
    LET vsdo_retenido          	= 0;    
    LET vint_devengado         	= 0;
    LET viva_int_devengado     	= 0;
    LET vlinea_disponible      	= 0;
    LET vpagos_vdos            	= 0;
    LET vdesc_status_cred      	= '';
    LET vid_bloqueo_cred       	= 0;
    LET vbloqueo_cta           	= '';
    LET vid_causa_bloqueo_cred 	= '';
    LET vcausa_bloqueo_cta     	= '';
    LET vid_sit_esp_cte        	= '';
    LET vid_causa_esp_cte      	= 0;
    LET vsit_esp_cte           	= '';
    LET vid_sit_esp_cred       	= '';
    LET vid_causa_esp_cred     	= 0;
    LET vsit_esp_cred          	= '';
    LET vCodRetSdoCorte        	= '';
    LET vSdoDisp1     			= 0.00;
    LET vSecMax      			= 0;	
	-- 	SP CONS_SDOS1
	LET vcod_ret   				= "000";
	LET vnum_cte   				= "";
	LET vapell_pat				= " ";
	LET vapell_mat 				= " ";
	LET vnombre1   				= " ";
	LET vnombre2   				= " ";
	LET vrazon_soc 				= " ";
	LET vedo_cta   				= "";	
	LET cSdo_ret   				= 0 ;
	LET vsdo_ccc   				= 0 ;
	LET vsdo_disp_ccc 			= 0 ;
	LET vsdo_cta   				= 0 ;
	LET vtipo_linea 			= " ";
	LET vdescrip1 				= "";
	LET vdescrip2 				= "";
	LET vsdo_t1 				=  0 ;
	LET vsdo_cong  				= 0 ;
	LET vimp_chq_sbc 			= 0;
	LET vusubloq 				= " ";
	LET vfecbloq 				= "";
	LET vnum_tarjeta 			= "";
	LET vcta_clabe 				= "";
	LET vCodRetSdoCorte       	= '';    
	LET cod_ret 			  	= "00000";
	LET sql_err				  	="0";
	LET vNumtarjeta			  	= "";		
	LET vSistema 			  	= "";	
	Let iContador = 1;	
	LET sTipoconsulta = "";
	LET iProdInvalido		=0; --#CVA_20190327.1014'
	LET iResConsulta = 0;  --#CVA_20190327.1014'
	LET vOpcionAcceso   = '';
	LET vSucursal   = '';
	LET vSucursalTarj  = '';
			
BEGIN
   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN		
			LET cod_ret = sql_err;
			RETURN 	cod_ret,
					vOtrasCtas,
					vProducto1,vtipo1,TRIM(vCuenta1),iTerminacioncuenta1,vSdoDisp1,vPagoMin1,vPagoNoInt1,vFechLimPago1, 
					vProducto2,vtipo2,TRIM(vCuenta2),iTerminacioncuenta2,vSdoDisp2,vPagoMin2,vPagoNoInt2,vFechLimPago2, 
					vProducto3,vtipo3,TRIM(vCuenta3),iTerminacioncuenta3,vSdoDisp3,vPagoMin3,vPagoNoInt3,vFechLimPago3, 
					vProducto4,vtipo4,TRIM(vCuenta4),iTerminacioncuenta4,vSdoDisp4,vPagoMin4,vPagoNoInt4,vFechLimPago4,
					vProducto5,vtipo5,TRIM(vCuenta5),iTerminacioncuenta5,vSdoDisp5,vPagoMin5,vPagoNoInt5,vFechLimPago5, 
					vProducto6,vtipo6,TRIM(vCuenta6),iTerminacioncuenta6,vSdoDisp6,vPagoMin6,vPagoNoInt6,vFechLimPago6, 
					vProducto7,vtipo7,TRIM(vCuenta7),iTerminacioncuenta7,vSdoDisp7,vPagoMin7,vPagoNoInt7,vFechLimPago7, 
					vProducto8,vtipo8,TRIM(vCuenta8),iTerminacioncuenta8,vSdoDisp8,vPagoMin8,vPagoNoInt8,vFechLimPago8, 
					vProducto9,vtipo9,TRIM(vCuenta9),iTerminacioncuenta9,vSdoDisp9,vPagoMin9,vPagoNoInt9,vFechLimPago9, 
					vProducto10,vtipo10,TRIM(vCuenta10),iTerminacioncuenta10,vSdoDisp10,vPagoMin10,vPagoNoInt10,vFechLimPago10;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/yonaiker/Proyecto_Homologacion_697.1/ivr_consulta_saldos.out";
	--TRACE ON;

	 SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;	 

IF pTelefono IS NOT NULL  OR pTelefono <> '' THEN

	IF p_caracteres NOT IN (9, 11, 12, 16) THEN

	 LET cod_ret = '00001';
	
	END IF;
	
	IF ((LENGTH (p_numtarjeta) = 0) AND (LENGTH(p_cuenta) = 0) AND (LENGTH (p_num_credito) = 0) AND (LENGTH(p_numcte) = 0)) THEN  

		LET cod_ret = '00001'; 

	ELSE
		IF (p_caracteres = 9) THEN --VALIDA SI EL PARAMETRO INGRESADO ES NUMERO DE CLIENTE
				
			IF NVL(p_numcte,'') <> '' THEN
			
				FOREACH WITH HOLD				 
								
					SELECT FIRST 10 num_producto, num_credito, 'CR' AS Tipo 
						INTO vProducto,vCuenta, vtipo
					FROM bdicred:sd_maecred
					WHERE numcte = p_numcte 
					AND status_cred IN ('BT','AA','BA','E1','E2','E3')
					AND num_producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
						UNION	
					select num_producto, num_credito, 'CR' AS tipo
					FROM bdicred:"informix".sd_maecredcrd
					WHERE status_cred IN('AA','BA','BT','VP','E1','E2','E3')
					AND numcte =  p_numcte 
					AND num_producto IN ('6300','6400','6800')  
					AND num_producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
						UNION 
					SELECT producto, cuenta,'DB' AS Tipo 
					FROM bdicheq: sc_maechq 
					WHERE num_cte = p_numcte 
					AND status_cta = '1' 
					AND producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
					ORDER BY Tipo 		

					LET vCuenta = TRIM(NVL(vCuenta,''));
						
					IF vtipo = 'DB' THEN --VALIDA LA CUENTA DE DEBITO DEL CLIENTE						
						/*SELECT NVL (numtarjeta,'') 
						INTO vNumtarjeta
						FROM intercard: tarjetacuenta 
						WHERE numcuenta = vCuenta;															
						--- Se comenta, por que presentaba error cuando el cliente tiene mÃÂÃÂ s de una tarjeta     CVA_20190530.0732*/
						
						SELECT num_tarjeta 
						INTO vNumtarjeta 
						FROM bdicheq:"informix".sc_tarjeta
						WHERE cuenta = vCuenta
						AND status_tar = 'A';
						
						LET vNumtarjeta = TRIM(NVL(vNumtarjeta,''));
						
						CALL bdicheq:"informix".cons_sdos1('001',vCuenta,vNumtarjeta) 						
						RETURNING vcod_ret,vCuenta,vnum_cte,vapell_pat,vapell_mat, vnombre1,vnombre2,vrazon_soc,vedo_cta,vSdoDisp,cSdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea, vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc, vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 

					ELIF vtipo = 'CR' THEN --VALIDA LA CUENTA DE CREDITO DEL CLIENTE
						SELECT num_producto, 'SD' AS sistema 
						INTO vProducto, vSistema
							FROM
						TABLE
						(MULTISET(
							SELECT {+INDEX(bdicred:sd_maecred maecred3)} num_producto
							FROM bdicred:"informix".sd_maecred 						
							WHERE empresa = '001'
                            AND num_credito = vCuenta
							AND status_cred IN ('BT','AA','BA','E1','E2','E3')
							UNION ALL
							SELECT {+INDEX(bdicred:sd_maecredcrd idx_maecrd)} num_producto 
							FROM bdicred:"informix".sd_maecredcrd 
							WHERE num_credito = vCuenta
							AND status_cred IN ('BT','AA','BA','VP','E1','E2','E3')
						));
						
						LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190503.1639 --Asigna para validar el resultado de la consulta						
						
						IF iResConsulta <> 0 THEN
							IF NVL(TRIM(vCuenta),'') <> '' THEN 
								LET vCuenta =TRIM(vCuenta);

								EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vCuenta)
								
								INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
								vPagoMin, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
								vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
								vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
								viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vSdoDisp, vint_devengado, viva_int_devengado, 
								vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
								vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
							
								-- SALDO DISPONIBLE AL DIA DE HOY
								IF vSdoDisp IS NULL OR vSdoDisp < 0.00 THEN 
									LET vSdoDisp = 0.00; 
								END IF;

								-- PAGO PARA NO GENERAR INTERESES
								EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vCuenta, 0)
								INTO vCodRetSdoCorte, vPagoNoInt;
		
								IF vPagoNoInt IS NULL THEN 
									LET vPagoNoInt = 0.00; 
								END IF;

								-- PAGO MINIMO
								IF vPagoMin < 0 THEN 
									LET vPagoMin = 0.00; 
								END IF;
								-- FECHA LIMITE DE PAGO 
								LET vFechLimPago = vfecha_prox_pago;
								IF (vFechLimPago = '' or vFechLimPago = ' ' or vFechLimPago IS NULL) THEN
									LET vFechLimPago = '01-01-1990';
								END IF;					
			
							END IF;				
							
						END IF;	
					END IF;
					
					SELECT sucursal 
					INTO vSucursal  
					FROM bdinteg:"informix".si_cliente 
					WHERE numcte = p_numcte;
					
					SELECT t.num_tarjeta --OBTIENE NÃÂÃÂ¡MERO DE TARJETA POR NÃÂÃÂ¡MERO DE CUENTA
					INTO vNumtarjeta
					FROM bdicheq:"informix".sc_maechq b,
					bdicheq:"informix".sc_tarjeta t
					WHERE b.cuenta = t.cuenta
					AND b.cuenta = vCuenta 
					AND t.tipo_tarjeta = 'T' 
					AND t.status_tar = 'A';

                    IF vtipo = 'CR' THEN
                        SELECT t.num_tarjeta, b.numcte --OBTIENE NÃÂÃÂ¡MERO DE TARJETA POR NÃÂÃÂ¡MERO DE CUENTA
					    INTO vNumtarjeta, vnum_cte
					    FROM bdicred:"informix".sd_maecred b,
					    bdicred:"informix".sd_tarjeta t
					    WHERE b.num_credito = t.num_credito
					    AND b.num_credito = vCuenta 
					    AND t.tipo_tarjeta = 'T'
						AND b.num_producto IN ( '6001' , '7000', '8100', '5400', '8500' )
					    AND t.status_tar = 'A';
                    END IF;
					
					LET vSucursal = TRIM(NVL(vSucursal,''));
					LET vNumtarjeta = TRIM(NVL(vNumtarjeta,''));
					
					LET sTipoconsulta = 'OBT_SDO_CLIENTE';
					LET vOpcionAcceso = 'NUM_CTE'; --Se agrega opciÃÂÃÂ³n nÃÂÃÂºmero de cliente por la que accesa el cliente.					
					LET iTerminacioncuenta =  TRIM(NVL(SUBSTR(vCuenta, (LENGTH(TRIM(vCuenta)) - 3), 4),''));					
					
					IF (iContador = 1) AND (vcuenta IS NOT NULL) THEN
						LET vProducto1     = vProducto;
						LET vtipo1      = vtipo;
						LET vCuenta1     = vcuenta;
						LET iTerminacioncuenta1   = iTerminacioncuenta;
						LET vSdoDisp1     = vSdoDisp;
						LET vPagoMin1 = vPagoMin;
						LET vPagoNoInt1 = vPagoNoInt;
						LET vFechLimPago1 = vFechLimPago;
					END IF;
					IF (iContador = 2) AND (vcuenta IS NOT NULL) THEN
						LET vProducto2     = vProducto;
						LET vtipo2      = vtipo;
						LET vCuenta2     = vcuenta;
						LET iTerminacioncuenta2   = iTerminacioncuenta;
						LET vSdoDisp2     = vSdoDisp;
						LET vPagoMin2 = vPagoMin;
						LET vPagoNoInt2 = vPagoNoInt;
						LET vFechLimPago2 = vFechLimPago;
					END IF;
					IF (iContador = 3) AND (vcuenta IS NOT NULL) THEN
						LET vProducto3     = vProducto;
						LET vtipo3      = vtipo;
						LET vCuenta3     = vcuenta;
						LET iTerminacioncuenta3   = iTerminacioncuenta;
						LET vSdoDisp3     = vSdoDisp;
						LET vPagoMin3 = vPagoMin;
						LET vPagoNoInt3 = vPagoNoInt;
						LET vFechLimPago3 = vFechLimPago;
					END IF;
					IF (iContador = 4) AND (vcuenta IS NOT NULL) THEN
						LET vProducto4     = vProducto;
						LET vtipo4      = vtipo;
						LET vCuenta4     = vcuenta;
						LET iTerminacioncuenta4   = iTerminacioncuenta;
						LET vSdoDisp4     = vSdoDisp;
						LET vPagoMin4 =  vPagoMin;
						LET vPagoNoInt4 = vPagoNoInt;
						LET vFechLimPago4 = vFechLimPago;
					END IF;
					IF (iContador = 5) AND (vcuenta IS NOT NULL) THEN
						LET vProducto5     = vProducto;
						LET vtipo5      = vtipo;
						LET vCuenta5     = vcuenta;
						LET iTerminacioncuenta5   = iTerminacioncuenta;
						LET vSdoDisp5     = vSdoDisp;
						LET vPagoMin5 = vPagoMin;
						LET vPagoNoInt5 = vPagoNoInt;
						LET vFechLimPago5 = vFechLimPago;
					END IF;					
					IF (iContador = 6) AND (vcuenta IS NOT NULL) THEN
						LET vProducto6     = vProducto;
						LET vtipo6      = vtipo;
						LET vCuenta6     = vcuenta;
						LET iTerminacioncuenta6   = iTerminacioncuenta;
						LET vSdoDisp6     = vSdoDisp;
						LET vPagoMin6 = vPagoMin;
						LET vPagoNoInt6 = vPagoNoInt;
						LET vFechLimPago6 = vFechLimPago;
					END IF;
					IF (iContador = 7) AND (vcuenta IS NOT NULL) THEN
						LET vProducto7     = vProducto;
						LET vtipo7      = vtipo;
						LET vCuenta7     = vcuenta;
						LET iTerminacioncuenta7   = iTerminacioncuenta;
						LET vSdoDisp7     = vSdoDisp;
						LET vPagoMin7 = vPagoMin;
						LET vPagoNoInt7 = vPagoNoInt;
						LET vFechLimPago7 = vFechLimPago;					
					END IF;
					IF (iContador = 8) AND (vcuenta IS NOT NULL) THEN
						LET vProducto8     = vProducto;
						LET vtipo8      = vtipo;
						LET vCuenta8     = vcuenta;
						LET iTerminacioncuenta8   = iTerminacioncuenta;
						LET vSdoDisp8     = vSdoDisp;
						LET vPagoMin8 = vPagoMin;
						LET vPagoNoInt8 = vPagoNoInt;
						LET vFechLimPago8 = vFechLimPago;
					END IF;
					IF (iContador = 9) AND (vcuenta IS NOT NULL) THEN
						LET vProducto9     = vProducto;
						LET vtipo9      = vtipo;
						LET vCuenta9     = vcuenta;
						LET iTerminacioncuenta9   = iTerminacioncuenta;
						LET vSdoDisp9     = vSdoDisp;
						LET vPagoMin9 = vPagoMin;
						LET vPagoNoInt9 = vPagoNoInt;
						LET vFechLimPago9 = vFechLimPago;
					END IF;
					IF (iContador = 10) AND (vcuenta IS NOT NULL) THEN
						LET vproducto10     = vProducto;
						LET vtipo10      = vtipo;
						LET vcuenta10     = vcuenta;
						LET iTerminacioncuenta10   = iTerminacioncuenta;
						LET vSdoDisp10     = vSdoDisp;
						LET vPagoMin10 = vPagoMin;
						LET vPagoNoInt10 = vPagoNoInt;
						LET vFechLimPago10 = vFechLimPago;
					END IF;		
					
					IF iContador < 10 THEN
						LET iContador  = iContador + 1;
						LET vProducto 				= "";
						LET vtipo					= "";
						LET vCuenta      			= '';
						LET iTerminacioncuenta   	="0000";
						LET vSdoDisp     			= 0.00;
						LET vPagoMin     			= 0.00;
						LET vPagoNoInt   			= 0.00;
						LET vFechLimPago 			= '01-01-1990';
						CONTINUE FOREACH;
					END IF;					
				
				END FOREACH;
			ELSE 
				LET cod_ret = '00001';
			END IF;
		END IF;	
		
		IF (p_caracteres = 11) THEN --VALIDA SI EL PARAMETRO INGRESADO ES NUMERO DE CUENTA DEBITO
			IF NVL(p_cuenta,'') <> '' THEN
			
				LET sTipoconsulta = 'OBT_SDO_CUENTA';		
				SELECT producto,num_cte, cuenta,'DB' AS Tipo, sucursal -- #CVA_20190327.1014 
				INTO vProducto,vnum_cte,vCuenta, vtipo, vSucursal
				FROM bdicheq: sc_maechq 
				WHERE cuenta = p_Cuenta 
				AND status_cta = '1';
				
				LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190503.1639 --Asigna para validar el resultado de la consulta						
				
				LET vnum_cte = TRIM(NVL(vnum_cte,''));
				LET vProducto = TRIM(NVL(vProducto,''));
				LET vCuenta = TRIM(NVL(vCuenta,''));
				LET vtipo = TRIM(NVL(vtipo,''));
				LET vSucursal = TRIM(NVL(vSucursal,''));
				
				IF iResConsulta != 0 THEN
					LET vOpcionAcceso = 'NUM_CTA_CAP'; --Se agrega opciÃÂÃÂ³n nÃÂÃÂºmero de cuenta captaciÃÂÃÂ³n por la que accesa el cliente.
					SELECT COUNT (*) -- #CVA_20190327.1014 
					INTO iProdInvalido 
					FROM bdinteg:"informix".si_prodinval_ivr where producto = vProducto;
					
					IF iProdInvalido  = 0 THEN		-- #CVA_20190327.1014 		
								
						/*SELECT NVL(numtarjeta,'') 
						INTO vNumtarjeta 
						FROM intercard:tarjetacuenta 
						WHERE numcuenta = vCuenta;	
						--- Se comenta, por que presentaba error cuando el cliente tiene mÃÂÃÂ s de una tarjeta   CVA_20190530.0732*/
					
						SELECT num_tarjeta 
						INTO vNumtarjeta 
						FROM bdicheq:"informix".sc_tarjeta
						WHERE cuenta = vCuenta
						AND status_tar = 'A';
												
						LET vNumtarjeta = TRIM(NVL(vNumtarjeta,''));
					
						CALL bdicheq:"informix".cons_sdos1('001',TRIM(vCuenta),vNumtarjeta) 
						
					
						
						RETURNING vcod_ret,vCuenta,vnum_cte,vapell_pat,vapell_mat, vnombre1,vnombre2,vrazon_soc,vedo_cta,vSdoDisp,cSdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea, vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc, vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 
						LET vedo_cta = vedo_cta;
						LET vSdoDisp = vSdoDisp;
					ELSE -- #CVA_20190327.1014 
						LET cod_ret = '00001';
					END IF;
				ELSE 
					LET cod_ret = '00001';	 -- #CVA_20190327.1014 
				END IF;
			ELSE 
				LET cod_ret = '00001';
			END IF;
		END IF;
				
		IF (p_caracteres = 12) THEN --VALIDA SI EL PARAMETRO INGRESADO ES NUMERO DE CUENTA CREDITO
			LET sTipoconsulta = 'OBT_SDO_CREDITO';		
			
			IF NVL(p_num_credito,'') <> '' THEN		
				--FOREACH
				SELECT numcte, num_producto, num_credito, 'CR' AS tipo , sucursal
				INTO vnum_cte, vProducto,vCuenta, vtipo, vSucursal 
				FROM TABLE (MULTISET(
					SELECT {+INDEX(bdicred:sd_maecred maecred3)} numcte, num_producto, num_credito, 'CR' AS tipo, sucursal				
					FROM bdicred: sd_maecred 
					WHERE empresa = '001'
                    AND num_credito = p_num_credito 
					AND status_cred IN ('BT','AA','BA','E1','E2','E3')
					UNION ALL	
					SELECT {+INDEX(bdicred:sd_maecredcrd idx_maecrd)} numcte,num_producto, num_credito, 'CR' AS tipo, sucursal
					FROM bdicred:"informix".sd_maecredcrd
					WHERE status_cred IN('AA','BA','BT','VP','E1','E2','E3')
					AND num_credito = p_num_credito
				)); 	
				
				LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190503.1639 --Asigna para validar el resultado de la consulta						
				LET vnum_cte = TRIM(NVL(vnum_cte,''));
				LET vProducto = TRIM(NVL(vProducto,''));
				LET vCuenta = TRIM(NVL(vCuenta,''));
				LET vtipo = TRIM(NVL(vtipo,''));
				LET vSucursal = TRIM(NVL(vSucursal,''));
				
				IF iResConsulta > 0 THEN
					LET vOpcionAcceso = 'NUM_CTA_CRED'; --Se agrega opciÃÂÃÂ³n nÃÂÃÂºmero de cuenta crÃÂÃÂ©dito por la que accesa el cliente.
					
					SELECT num_tarjeta
					INTO vNumtarjeta
					FROM bdicred: sd_tarjeta
					WHERE num_credito = vCuenta 
					AND tipo_tarjeta = 'T' 
					AND status_tar = 'A';
					
					LET vNumtarjeta = TRIM(NVL(vNumtarjeta,''));
					
					SELECT COUNT (*) -- #CVA_20190327.1014 
					INTO iProdInvalido 
					FROM bdinteg:"informix".si_prodinval_ivr where producto = vProducto;
					
					IF iProdInvalido  = 0 THEN		-- #CVA_20190327.1014 	
					
						IF NVL(TRIM(vCuenta),'') <> '' THEN 
						
							EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vCuenta)
							INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
							vPagoMin, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
							vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
							vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
							viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vSdoDisp, vint_devengado, viva_int_devengado, 
							vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
							vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;

							-- SALDO DISPONIBLE AL DIA DE HOY				
							IF vSdoDisp IS NULL OR vSdoDisp < 0.00 THEN 
								LET vSdoDisp = 0.00; 
							END IF;
							-- PAGO PARA NO GENERAR INTERESES
							EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vCuenta, 0)
							INTO vCodRetSdoCorte, vPagoNoInt;

							IF vPagoNoInt IS NULL THEN 
								LET vPagoNoInt = 0.00; 
							END IF;

							-- PAGO MINIMO				
							IF vPagoMin < 0 THEN 
								LET vPagoMin = 0.00; 
							END IF;
							--FECHA LIMITE DE PAGO 
							LET vFechLimPago = vfecha_prox_pago;																	
						END IF;
					ELSE 
						LET cod_ret = '00001';	 -- #CVA_20190327.1014 
					END IF;
				ELSE
					LET cod_ret = '00001';	 -- #CVA_20190327.1014 
				END IF;
				--END FOREACH;
			ELSE 
				LET cod_ret = '00001';				
			END IF;
		END IF;	
		
		IF (p_caracteres = 16) THEN --VALIDA SI EL PARAMETRO INGRESADO ES NUMERO DE TARJETA
			IF NVL(p_numtarjeta,'') <> '' THEN	
				LET sTipoconsulta = 'OBT_SDO_TARJETA';				
				FOREACH WITH HOLD	
				
					SELECT tar.prodtarjeta, tar.numcte, tar.cuenta,'DB' AS vTipo, chq.sucursal, tar.num_tarjeta
					INTO vProducto,vnum_cte, vCuenta, vtipo, vSucursal, vNumtarjeta  
					FROM bdicheq: sc_tarjeta tar, 
					bdicheq: sc_maechq chq
					WHERE tar.num_tarjeta = p_numtarjeta 
					AND tar.status_tar = 'A'
					AND chq.cuenta = tar.cuenta
					AND chq.num_cte = tar.numcte					
						UNION ALL					
					SELECT tar.prodtarjeta, tar.numcte, tar.num_credito, 'CR' AS vTipo, crd.sucursal, tar.num_tarjeta
					FROM bdicred: sd_tarjeta tar,
					bdicred: sd_maecred crd
					WHERE tar.num_tarjeta = p_numtarjeta
					AND tar.status_tar ='A'
					AND crd.num_credito = tar.num_credito
					AND crd.numcte = tar.numcte				
									
					LET iResConsulta =  DBINFO("sqlca.sqlerrd2"); --#CVA_20190503.1639 --Asigna para validar el resultado de la consulta						
					LET vnum_cte = TRIM(NVL(vnum_cte,''));
					LET vProducto = TRIM(NVL(vProducto,''));
					LET vCuenta = TRIM(NVL(vCuenta,''));
					LET vtipo = TRIM(NVL(vtipo,''));
					LET vSucursal = TRIM(NVL(vSucursal,''));
					LET vNumtarjeta = TRIM(NVL(vNumtarjeta,''));
					
					IF iResConsulta != 0 THEN	
						SELECT COUNT (*) -- #CVA_20190327.1014 
						INTO iProdInvalido 
						FROM bdinteg:"informix".si_prodinval_ivr where producto = vProducto;
						
						IF iProdInvalido  = 0 THEN		-- #CVA_20190327.1014 	
							IF vtipo = 'DB' THEN --VALIDA LA TARJETA DE DEBITO DEL CLIENTE				
							LET vOpcionAcceso = 'NUM_TDD'; --Se agrega opciÃÂÃÂ³n nÃÂÃÂºmero de tarjeta de dÃÂÃÂ©bito por la que accesa el cliente.	
							--LET vSucursal = vSucursalTarj; 
							/*SELECT NVL (numtarjeta,'') 
								INTO vNumtarjeta
								FROM intercard: tarjetacuenta 
								WHERE numcuenta = vCuenta;
								
								--- Se comenta, por que presentaba error cuando el cliente tiene mÃÂÃÂ s de una tarjeta   CVA_20190530.0732*/						
																
								CALL bdicheq:"informix".cons_sdos1('001',vCuenta,p_numtarjeta) 
										
								RETURNING vcod_ret,vCuenta,vnum_cte,vapell_pat,vapell_mat, vnombre1,vnombre2,vrazon_soc,vedo_cta,vSdoDisp,cSdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea, vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc, vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 
				
							ELIF vtipo = 'CR' THEN --VALIDA LA TARJETA DE CREDITO DEL CLIENTE	
								LET vOpcionAcceso = 'NUM_TDC'; --Se agrega opciÃÂÃÂ³n nÃÂÃÂºmero de tarjeta de crÃÂÃÂ©dito por la que accesa el cliente.
								IF NVL(TRIM(vCuenta),'') <> '' THEN 	
								
									EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vCuenta)
									INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
									vPagoMin, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
									vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
									vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
									viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vSdoDisp, vint_devengado, viva_int_devengado, 
									vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
									vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
				
									-- SALDO DISPONIBLE AL DIA DE HOY						
									IF vSdoDisp is null OR vSdoDisp < 0.00 THEN 
										LET vSdoDisp = 0.00; 
									END IF;
									-- PAGO PARA NO GENERAR INTERESES
									EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vCuenta, 0)
									INTO vCodRetSdoCorte, vPagoNoInt;
									
									IF vPagoNoInt IS NULL THEN 
										LET vPagoNoInt = 0.00; 
									END IF;
									-- PAGO MINIMO
									IF vPagoMin < 0 THEN 
										LET vPagoMin = 0.00; 
									END IF;
									-- FECHA LIMITE DE PAGO 
									LET vFechLimPago = vfecha_prox_pago;																							
								END IF;					
							END IF;	
						ELSE 
							LET cod_ret = '00001';	 -- #CVA_20190327.1014 
						END IF;	
					ELSE 
						LET cod_ret = '00001';	 -- #CVA_20190327.1014 
					END IF;		
				END FOREACH;						
			ELSE 
				LET cod_ret = '00001';				
			END IF;			
		END IF;
		LET iTerminacioncuenta =  TRIM(NVL(SUBSTR(vCuenta, (LENGTH(TRIM(vCuenta)) - 3), 4),''));
		
		IF (p_caracteres = 11 OR p_caracteres = 12 OR p_caracteres = 16) AND cod_ret = '00000' THEN
		-- VERIFICA SI EL CLIENTE TIENE MAS CUENTAS 

			IF vnum_cte <> '' THEN
				SELECT SUM(total) 
				INTO viExisMasCtas
				FROM 
				TABLE(MULTISET(
					SELECT  COUNT(*) AS total
					FROM bdicheq:"informix".sc_maechq a 
					WHERE a.empresa = '001'
					AND a.num_cte =  vnum_cte
					AND a.status_cta IN('1','4','5') 
					AND producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
						UNION ALL
					SELECT COUNT(*) AS total
					FROM bdicred:"informix".sd_maecred b
					WHERE b.empresa = '001'
					AND b.numcte = vnum_cte
					and b.status_cred IN('AA','BA','BT','E1','E2','E3')
					AND num_producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
						UNION ALL
					SELECT  COUNT(*) AS total
					FROM bdicred:"informix".sd_maecredcrd c
					WHERE c.empresa = '001'
					AND c.numcte =  vnum_cte
					and c.status_cred IN('AA','BA','BT','VP','E1','E2','E3')
					AND num_producto NOT IN(SELECT {+INDEX(bdinteg:si_prodinval_ivr idx_prodinvivr_prod)} producto FROM bdinteg:"informix".si_prodinval_ivr)
				)); /* #CVA_20190327.1014 Se agrega consulta para que obtenga el contador de las cuentas que tiene el cliente, en caso que sea mayor de 1 se indicarÃÂÃÂ¡ que hay mas cuentas y el ivr deberÃÂÃÂ¡ ofrecer el flujo al cliente de si quiere el saldo de las demÃÂÃÂ¡s cuentas*/
				
				IF viExisMasCtas > 1 THEN
					LET vOtrasCtas = '1';
				ELSE
					LET vOtrasCtas = '0';
				END IF;
				
				LET vProducto1     = vProducto;
				LET vtipo1      = vtipo;
				LET vCuenta1     = vcuenta;
				LET iTerminacioncuenta1   = iTerminacioncuenta;
				LET vSdoDisp1     = vSdoDisp;
				LET vPagoMin1 = vPagoMin;
				LET vPagoNoInt1 = vPagoNoInt;
				LET vFechLimPago1 = vFechLimPago;
			END IF;
				--LET vOtrasCtas = '0';
				--LET cod_ret = '00001';				
		END IF;
		
		IF vnum_cte != '' THEN

           /*--VALIDAR TELÃÂÃ¢ÂÂ°FONO     //Aqui se busca el telefono para guardarlo en la bitacora pero es incorrecto ya que no es el de la llamada
			SELECT t.telefono
			INTO  vTelefono
			FROM bdinteg:"informix".si_telefonos t,
			bdinteg:"informix".si_cliente c
			WHERE t.numcte = vnum_cte
			AND c.numcte = t.numcte
			AND t.status_tel = 'A'
			AND t.tipo_tel = 2
			AND t.secuencia = (SELECT MAX(secuencia ) 
							   FROM bdinteg:"informix".si_telefonos
							   WHERE numcte =  vnum_cte
							   AND tipo_tel = 2
							   AND status_tel = 'A');

			IF (vTelefono IS NULL OR vTelefono = '' OR vTelefono = ' ') THEN
				LET vTelefono = '';
			END IF;
*/			
			IF p_otrascuentas = "1" THEN
			
				LET sTipoconsulta = 'OBT_SDO_OTRCTAS';
				
			END IF;

				-- // RECOPILANDO DATA DE BITACORA
			IF vNumtarjeta = '' OR vNumtarjeta IS NULL THEN

				SELECT FIRST 1 num_tarjeta
				INTO vNumtarjeta
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE numcte = vnum_cte
				AND status_tar = 'A'
				AND tipo_tarjeta = 'T';

				IF DBINFO("sqlca.sqlerrd2") = 0 THEN

				SELECT FIRST 1 num_tarjeta
				INTO vNumtarjeta
				FROM bdicred:"informix".sd_tarjeta
				WHERE numcte = vnum_cte
				AND status_tar ='A'
				AND tipo_tarjeta = 'T';

				END IF;

				IF vNumtarjeta IS NULL THEN
				LET vNumtarjeta = '';
				END IF;

			END IF;	
			
			IF cod_ret = '00000' THEN
				-- GUARDA REGISTRO EN BITACORA		
				SELECT MAX(secuencia) 
				INTO vSecMax
				FROM bdinteg:"informix".si_bitacora_ivr
				WHERE DATE(fecha_oper) = CURRENT::DATE
				AND telefono = pTelefono;	

					IF vSecMax IS NULL  THEN
						LET vSecMax = 1;
					ELSE	
						LET vSecMax = vSecMax + 1;
					END IF; 

				LET vNumtarjeta = LPAD(NVL(TRIM(vNumtarjeta),''),16,'0');
			
				INSERT INTO bdinteg:"informix".si_bitacora_ivr 
				VALUES (CURRENT, vSecMax, sTipoconsulta, vNumtarjeta, vnum_cte, pTelefono, vOpcionAcceso, vSucursal);
			
			END IF;	
				
		ELSE 
			LET cod_ret = '00001';				
		END IF;
	END IF;

	IF cod_ret != '00000' THEN
		-- GUARDA REGISTRO EN BITACORA		
			SELECT MAX(secuencia) 
			INTO vSecMax
			FROM bdinteg:"informix".si_bitacora_ivr
			WHERE DATE(fecha_oper) = CURRENT::DATE
			AND telefono = pTelefono;	
					
				IF vSecMax IS NULL  THEN
					LET vSecMax = 1;
				ELSE	
					LET vSecMax = vSecMax + 1;
				END IF; 
						
			LET vNumtarjeta = LPAD(NVL(TRIM(vNumtarjeta),''),16,'0');
			
			INSERT INTO bdinteg:"informix".si_bitacora_ivr (fecha_oper, secuencia, operacion, num_tarjeta, numcte, telefono, opcion_acceso, sucursal) 
			VALUES (CURRENT, vSecMax, 'NE', '', '', pTelefono, vOpcionAcceso, '');
			
			RETURN 	cod_ret,
			vOtrasCtas,
			vProducto1,vtipo1,TRIM(vCuenta1),iTerminacioncuenta1,vSdoDisp1,vPagoMin1,vPagoNoInt1,vFechLimPago1, 
			vProducto2,vtipo2,TRIM(vCuenta2),iTerminacioncuenta2,vSdoDisp2,vPagoMin2,vPagoNoInt2,vFechLimPago2, 
			vProducto3,vtipo3,TRIM(vCuenta3),iTerminacioncuenta3,vSdoDisp3,vPagoMin3,vPagoNoInt3,vFechLimPago3, 
			vProducto4,vtipo4,TRIM(vCuenta4),iTerminacioncuenta4,vSdoDisp4,vPagoMin4,vPagoNoInt4,vFechLimPago4,
			vProducto5,vtipo5,TRIM(vCuenta5),iTerminacioncuenta5,vSdoDisp5,vPagoMin5,vPagoNoInt5,vFechLimPago5, 
			vProducto6,vtipo6,TRIM(vCuenta6),iTerminacioncuenta6,vSdoDisp6,vPagoMin6,vPagoNoInt6,vFechLimPago6, 
			vProducto7,vtipo7,TRIM(vCuenta7),iTerminacioncuenta7,vSdoDisp7,vPagoMin7,vPagoNoInt7,vFechLimPago7, 
			vProducto8,vtipo8,TRIM(vCuenta8),iTerminacioncuenta8,vSdoDisp8,vPagoMin8,vPagoNoInt8,vFechLimPago8, 
			vProducto9,vtipo9,TRIM(vCuenta9),iTerminacioncuenta9,vSdoDisp9,vPagoMin9,vPagoNoInt9,vFechLimPago9, 
			vProducto10,vtipo10,TRIM(vCuenta10),iTerminacioncuenta10,vSdoDisp10,vPagoMin10,vPagoNoInt10,vFechLimPago10;
	END IF;

ELSE 

LET cod_ret = '00002'; --Telefono de la llamada Nulo o VacÃÂÃÂ­o

END IF;

	RETURN 	cod_ret,
			vOtrasCtas,
			vProducto1,vtipo1,TRIM(vCuenta1),iTerminacioncuenta1,vSdoDisp1,vPagoMin1,vPagoNoInt1,vFechLimPago1, 
			vProducto2,vtipo2,TRIM(vCuenta2),iTerminacioncuenta2,vSdoDisp2,vPagoMin2,vPagoNoInt2,vFechLimPago2, 
			vProducto3,vtipo3,TRIM(vCuenta3),iTerminacioncuenta3,vSdoDisp3,vPagoMin3,vPagoNoInt3,vFechLimPago3, 
			vProducto4,vtipo4,TRIM(vCuenta4),iTerminacioncuenta4,vSdoDisp4,vPagoMin4,vPagoNoInt4,vFechLimPago4,
			vProducto5,vtipo5,TRIM(vCuenta5),iTerminacioncuenta5,vSdoDisp5,vPagoMin5,vPagoNoInt5,vFechLimPago5, 
			vProducto6,vtipo6,TRIM(vCuenta6),iTerminacioncuenta6,vSdoDisp6,vPagoMin6,vPagoNoInt6,vFechLimPago6, 
			vProducto7,vtipo7,TRIM(vCuenta7),iTerminacioncuenta7,vSdoDisp7,vPagoMin7,vPagoNoInt7,vFechLimPago7, 
			vProducto8,vtipo8,TRIM(vCuenta8),iTerminacioncuenta8,vSdoDisp8,vPagoMin8,vPagoNoInt8,vFechLimPago8, 
			vProducto9,vtipo9,TRIM(vCuenta9),iTerminacioncuenta9,vSdoDisp9,vPagoMin9,vPagoNoInt9,vFechLimPago9, 
			vProducto10,vtipo10,TRIM(vCuenta10),iTerminacioncuenta10,vSdoDisp10,vPagoMin10,vPagoNoInt10,vFechLimPago10;
	
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para regresar los saldos con su debido producto y los datos requeridos como son las fechas lÃÂÃÂ­mite y saldos para no generar intereses, de las cuentas tanto de captaciÃÂÃÂ³n como de crÃÂÃÂ©dito, se mantiene el control del registro en la bitacora con la descripciÃÂÃÂ³n de la operaciÃÂÃÂ³n OBT_SALDOS_CUENTAS y sus datos correspondiente.',
'AUTOR : Paola ArmendÃÂÃÂ¡riz',
'FECHA : 22/09/2017',
'BD    : BDIVR',
'DescripciÃÂÃÂ³n: se modifica consulta para que identifique que el cliente tiene mÃÂÃÂ¡s cuentas',
'Fecha : 2019/03/27',
'ModificÃÂÃÂ³: Cristian Valentina Aguilar PÃÂÃÂ©rez',
'Etiqueta: #CVA_20190327.1014', 
'Modifico: Ricardo gabriel roman garcia',
'Se quitaron los trim, select case y if exist',
'Fecha : 2019/04/24',
'ModificÃÂÃÂ³: Cristian Valentina Aguilar PÃÂÃÂ©rez',
'Etiqueta: #CVA_20190327.1014', 
'Modifico: Ricardo gabriel roman garcia',
'Se comenta, por que presentaba error cuando el cliente tiene mÃÂÃÂ s de una tarjeta',
'Fecha : 2019/05/30',
'Modifico: Hever Barraza',
'Se agregaron los parametros vOpcionAcceso para validar la opciÃÂÃÂ³n por la que acceso el cliente y vSucursal para conocer a que sucursal',
'pertenece la opciciÃÂÃÂ³n y registrarlo en la bitacora mensual de IVR, ademÃÂÃÂ¡s se agregÃÂÃÂ³ parametro de entrada p_otrascuentas para validar cuando se consulten otras cuentas.',
'Fecha : 2019/08/23',
'Descripcion: Se agrega nuevo parametro de entrada pTelefono para capturar el telefono de la llamada e insertarlo en bitacora',
'AUTOR : Yonaiker Morillo',
'FECHA : 18/09/2020',
'FOLIO : 697.1',
'BD    : BDIVR';

CREATE PROCEDURE "informix".sp_ivr_valida_cliente_iccat(pnumTelefono CHAR(10), popcionAcceso CHAR(16))
RETURNING CHAR(5); -- CÃDIGO DE RETORNO

-- DECLARACIÃN DE VARIABLES
DEFINE error_sql 			INTEGER;
DEFINE vnumCte				CHAR(9);
DEFINE vcodret				VARCHAR(5);
DEFINE vnumTelRegisrado		CHAR(10);
DEFINE vopcionAcceso		SMALLINT;
-- DEFINE pnumTelefono		VARCHAR(10);
-- DEFINE vnumtarjeta		VARCHAR(16);

-- INICIALIZACIÃN DE VARIABLES
LET vnumCte 				= '';
LET vcodret 				= '00000';
LET vnumTelRegisrado 		= '';
LET vopcionAcceso 			= 0;
-- LET pnumTelefono 		= '';
-- LET vnumtarjeta 			= '';

-- SET DEBUG FILE TO "/tmp/clizarraga/sp_ivr_valida_cliente_iccat.out";
-- TRACE ON;

BEGIN
    ON EXCEPTION SET error_sql
        IF error_sql != 0 THEN
            LET vcodret = error_sql;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- SE VALIDA QUE LA INFORMACIÃN CAPTURADA NO ESTÃ VACÃA NI COMPUESTA DE ESPACIOS EN BLANCO
	IF (TRIM(NVL(popcionAcceso, '')) != '') THEN
		LET vopcionAcceso = LENGTH(popcionAcceso);

		IF vopcionAcceso NOT IN (9, 11, 12, 16) THEN
			LET vcodret = '00001'; -- INFORMACIÃN DE ACCESO INVÃLIDA
			RETURN vcodret;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CLIENTE
		IF vopcionAcceso = 9 THEN
			SELECT numcte
				INTO vnumCte
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = popcionAcceso;

			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00011'; -- NÃMERO DE CLIENTE INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CUENTA
		IF vopcionAcceso = 11 THEN
			SELECT num_cte
				INTO vnumCte
				FROM bdicheq:sc_maechq
				WHERE cuenta = popcionAcceso;
				
			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00012'; -- NÃMERO DE CUENTA INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE CRÃDITO
		IF vopcionAcceso = 12 THEN
			SELECT numcte
				INTO vnumCte
				FROM bdicred:sd_maecred
				WHERE num_credito = popcionAcceso;

			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00013'; -- NÃMERO DE CRÃDITO INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;
		
		-- VALIDACIÃN DE INFORMACIÃN DE ACCESO POR NÃMERO DE TARJETA
		IF vopcionAcceso = 16 THEN
			SELECT numcliente
				INTO vnumCte
				FROM intercard:tarjeta
				WHERE numtarjeta = popcionAcceso;
				
			IF (TRIM(vnumCte) IS NULL) OR (TRIM(vnumCte) = '') THEN
				LET vcodret = '00014'; -- NÃMERO DE TARJETA INGRESADO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;
	ELSE
		LET vcodret = '00001'; -- INFORMACIÃN DE ACCESO INVÃLIDA
		RETURN vcodret;
	END IF;
	
	-- INFORMACIÃN DE ACCESO VÃLIDA
	/*
	IF (vcodret = '00000') THEN
		-- VERIFICACIÃN DE QUE EL CLIENTE TENGA UN NÃMERO DE TELÃFONO REGISTRADO
		SELECT COUNT(*)
			INTO vnumTelRegisrado
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = vnumCte
				AND telefono = pnumTelefono
				AND tipo_tel = 1; -- TELÃFONO DE CASA

		IF vnumTelRegisrado = 0 THEN
			SELECT COUNT(*)
				INTO vnumTelRegisrado
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = vnumCte
					AND telefono = pnumTelefono
					AND tipo_tel = 2; -- TELÃFONO CELULAR
					
			IF vnumTelRegisrado = 0 THEN
				LET vcodret = '00021'; -- NÃMERO DE TELÃFONO INVÃLIDO
				RETURN vcodret;
			END IF;
		END IF;

	END IF;
	*/

	-- SI LAS VALIDACIONES FUERON CORRECTAS, SE RECOPILA INFORMACIÃN DEL CLIENTE EN LA TABLA DE CLIENTES ICCAT
	INSERT INTO bdivr:si_cliente_iccat(telefono, numcliente, fecha)
	VALUES (pnumTelefono, vnumCte, current);
	
END;
RETURN vcodret;
END PROCEDURE;