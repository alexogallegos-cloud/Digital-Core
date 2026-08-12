CREATE PROCEDURE "informix".sp_cnsif_ideconsultarecofi(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cPERIODO CHAR(06))
							
			returning   CHAR(5)     AS Cod_Retorno,
						DATE        AS Fecha_Cargo,	      
						CHAR(20)    AS Cuenta,          
						CHAR(06)    AS Periodo,
						MONEY(16,2) AS Importe,
                        CHAR(2)     AS SistemaCuenta;

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;		

DEFINE v_cod_ret    CHAR(5);
DEFINE dFechaCargo  DATE;
DEFINE cNumCuenta   CHAR(20);
DEFINE cPeriodos    CHAR(06);
DEFINE mImporte     MONEY(16,2);
DEFINE Total_Recaudaciones   MONEY(16,2);
DEFINE cSistemaC    CHAR(2);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;
--DEFINE Total_RecauAux        MONEY(16,2);

LET  v_cod_ret    = "00000";
LET dFechaCargo   = "";
LET cNumCuenta    = "";
LET cPeriodos     = "";
LET mImporte      = 0;
LET Total_Recaudaciones = 0;
--LET Total_RecauAux      = 0;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;         
LET cSistemaC        ='00';
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC;						
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_ideconsultarecofi_2.out";
	--TRACE ON;

	IF 	cID_USUARIOC  = '' 	OR
		cID_FUNCIONC  = '' 	OR
		cNUMCLIENTE   = ''	OR
		cPERIODO      = ''  THEN 
		LET cCodRet = "00060";
		RETURN cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC;
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'23','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC;						
	END IF;
	-- TERMINA VALIDACION

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCLIENTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCLIENTE = cNumCtePrincipal;
	END IF;

	FOREACH
	SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE numcte  = cNUMCLIENTE
	UNION
	SELECT NVL(COUNT(numcte_tf),0) FROM  bditransfer:tf_maecte WHERE numcte_tf  = cNUMCLIENTE
	ORDER BY 1 DESC
	END FOREACH;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00062";
		RETURN cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC;
	END IF;

	SELECT NVL(COUNT(num_cte),0) INTO iexiste FROM  bdilide:sl_detlide WHERE num_cte  = cNUMCLIENTE;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00061";
		RETURN cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	FOREACH
	
		EXECUTE PROCEDURE bdilide:sp_ideconsultarecofi(cNUMCLIENTE, cPERIODO,0)
		INTO
		v_cod_ret, dFechaCargo,cNumCuenta,cPeriodos,mImporte

		IF LENGTH(v_cod_ret) = 3 THEN
			LET  cCodRet = '00' || v_cod_ret;
		ELIF LENGTH(v_cod_ret) = 5 THEN
			LET  cCodRet = v_cod_ret;
		END IF
		IF SUBSTR(TRIM(cNumCuenta),1,1)='3' THEN
            LET cSistemaC='03';
        ELIF SUBSTR(TRIM(cNumCuenta),1,1)='6' THEN
            LET cSistemaC='06';
        ELSE
            LET cSistemaC='01';
        END IF;
        RETURN 	cCodRet,dFechaCargo,cNumCuenta,cPeriodos,mImporte,cSistemaC WITH Resume;
	END FOREACH
	
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener Detalle de Recaudaciones LIDE. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente.",
"FECHA : 15-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultacuentadebito( psNumCuenta CHAR(13), psNumCliente CHAR(20), psNumTarjeta CHAR(16), psEmpresa CHAR(3), piTipoBusqueda SMALLINT )
	RETURNING CHAR(5) AS CodigoRetorno, 
		CHAR(13) AS NumCuenta, CHAR(20) AS NumCliente, CHAR(16) AS NumTarjeta, CHAR(40) AS DescProducto, 
		CHAR(26) AS Nombre1, CHAR(26) AS Nombre2, CHAR(26) AS ApellidoPaterno, CHAR(26) AS ApellidoMaterno, 
		CHAR(30) AS Status;
	
	--Declaración de variables.
	DEFINE sCodigoRetorno 	CHAR(5);
	DEFINE sSqlErr			INTEGER;
	DEFINE sNumCuenta		CHAR(13);
	DEFINE sNumCliente  	CHAR(20);
	DEFINE sNumTarjeta  	CHAR(16);
	DEFINE sCodProducto		CHAR(4);
	DEFINE sDescProducto   	CHAR(40);	
	DEFINE iCont			INTEGER;
	DEFINE iSecuencia   	INTEGER;
	DEFINE sNombre1 		CHAR(26);
	DEFINE sNombre2 		CHAR(25);
	DEFINE sApellidoPaterno CHAR(25);
	DEFINE sApellidoMaterno CHAR(25);
	DEFINE sStatus   		CHAR(30);
	DEFINE iTpo_cliente		INT;
	DEFINE cNumCtePrincipal CHAR(20);
	DEFINE cNumCteTf		CHAR(20);


	--Asignación de valores a variables.
	LET sCodigoRetorno = '00000';
	LET sSqlErr = 0;
	LET sNumCuenta = ''; 
	LET sNumCliente = '';
	LET sNumTarjeta = '';
	LET sDescProducto = '';	
	LET sCodProducto ='';
	LET iCont = 0;
	LET sNombre1 = '';
	LET sNombre2 = '';
	LET sApellidoPaterno = '';
	LET sApellidoMaterno = '';
	LET iSecuencia = 0;
	LET sStatus = '';
	LET iTpo_cliente=0;
	LET cNumCtePrincipal = "";
	LET cNumCteTf = "";
	

	BEGIN
		ON EXCEPTION SET sSqlErr
			IF sSqlErr <> 0 THEN
				LET sCodigoRetorno = sSqlErr;				
				RETURN sCodigoRetorno, 
					sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
					sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
					sStatus;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/SIA/sp_consultacuentadebito.out";
		--TRACE ON;

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(psNumCliente) INTO sCodigoRetorno,iTpo_cliente,cNumCtePrincipal;
		IF cNumCtePrincipal IS NOT NULL THEN
			LET psNumCliente = cNumCtePrincipal;
		END IF;
		
		--Búsqueda por número de cuenta.
		IF( piTipoBusqueda = 1 ) THEN
		
			LET psNumCuenta = TRIM( psNumCuenta );
			
			-- Se busca la cuenta en el maestro de cheques.
			--SELECT a.cuenta, NVL( a.num_cte, '' ), NVL( a.status_cta, '' ), b.producto, b.nombre
				--INTO sNumCuenta, sNumCliente, sStatus, sCodProducto, sDescProducto
			FOREACH
			SELECT a.cuenta, NVL( a.num_cte, '' ), b.producto, b.nombre
				INTO sNumCuenta, sNumCliente, sCodProducto, sDescProducto
			FROM bdicheq:"informix".sc_maechq a
				JOIN bdicheq:"informix".sc_producto b ON ( a.producto = b.producto )
			WHERE a.empresa = psEmpresa AND a.cuenta = psNumCuenta
			UNION
			SELECT a.cuenta_tf, CASE WHEN iTpo_cliente = 1 THEN a.numcte_tf ELSE a.numcte END, b.producto, b.nombre
			FROM bditransfer:"informix".tf_maecte a
				JOIN bdicheq:"informix".sc_producto b ON ( a.producto = b.producto )
			WHERE a.empresa = psEmpresa AND a.cuenta_tf = psNumCuenta
			END FOREACH;

			-- Se valida si la cuenta se encontró...
			IF ( sNumCuenta IS NULL ) THEN				

				-- Se busca la cuenta en el maestro de pagarés.
				--SELECT NVL( a.cuenta, '' ), NVL( a.num_cte, '' ), NVL( a.status_cta, '' ), b.nombre
					--INTO sNumCuenta, sNumCliente, sStatus, sDescProducto
				SELECT NVL( a.cuenta, '' ), NVL( a.num_cte, '' ), b.nombre
					INTO sNumCuenta, sNumCliente, sDescProducto
				FROM bdinvers:"informix".sv_maeinv a
					LEFT OUTER JOIN bdinvers:"informix".sv_instrum b ON ( b.cod_instrum = a.cod_instrum )
				WHERE a.empresa = psEmpresa AND a.cuenta = psNumCuenta 
					AND a.secuencia = ( 
						SELECT MAX( secuencia )
						FROM bdinvers:"informix".sv_maeinv
						WHERE empresa = psEmpresa AND cuenta = psNumCuenta );
			
			ELIF ( sCodProducto <> '1100' ) THEN -- Si no es una cuenta de inversión creciente...
			SELECT numcte_tf
				INTO cNumCteTf
				FROM bditransfer:"informix".tf_maecte
				WHERE cuenta_tf = psNumCuenta;
			
			IF cNumCteTf IS NOT NULL THEN
				LET sNumCliente = cNumCteTf;
			END IF;
			FOREACH

				-- Se busca la tarjeta relacionada a la cuenta de débito.
				SELECT NVL( a.numcuenta, '' ), a.numtarjeta
					INTO sNumCuenta, sNumTarjeta
				FROM intercard:"informix".tarjetacuenta a
					LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta b ON ( b.empresa = psEmpresa AND b.num_tarjeta  = a.numtarjeta )
				WHERE b.numcte = sNumCliente AND b.cuenta = psNumCuenta

				
				SELECT UPPER(b.descstatustarjeta)
				INTO sStatus
				FROM intercard:"informix".tarjeta a JOIN intercard:"informix".statustarjeta b
				ON (a.codstatustarjeta = b.codstatustarjeta)
				WHERE a.numtarjeta = sNumTarjeta;
				
				IF ( sNumCuenta <> '' AND sNumCliente <> '' AND sDescProducto <> '' ) THEN
					FOREACH
					SELECT numcte, NVL( nombre1, '' ), NVL( nombre2, '' ), NVL( apell_paterno, '' ), NVL( apell_materno, '' )
						INTO sNumCliente, sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno
					FROM bdinteg:"informix".si_cliente
					WHERE numcte = sNumCliente
					UNION
					SELECT CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END, NVL( nombre1, '' ), NVL( nombre2, '' ), NVL( apell_paterno, '' ), NVL( apell_materno, '' )
					FROM bditransfer:"informix".tf_maecte
					WHERE numcte_tf = sNumCliente
					END FOREACH;
				
					IF ( sNumCliente IS NOT NULL ) THEN 

						LET iCont = 1;
						
						RETURN sCodigoRetorno, 
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
							sStatus WITH RESUME;
						
					END IF;
			    END IF;	
			END FOREACH;	
			END IF;
			
			IF ( sCodProducto = '1100' ) THEN
				--IF ( sNumCuenta <> '' AND sNumCliente <> '' AND sStatus <> '' AND sDescProducto <> '' ) THEN
				IF ( sNumCuenta <> '' AND sNumCliente <> '' AND sDescProducto <> '' ) THEN
				FOREACH
					SELECT numcte, NVL( nombre1, '' ), NVL( nombre2, '' ), NVL( apell_paterno, '' ), NVL( apell_materno, '' )
						INTO sNumCliente, sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno
					FROM bdinteg:"informix".si_cliente
					WHERE numcte = sNumCliente
					
					IF ( sNumCliente IS NOT NULL ) THEN 

						LET iCont = 1;
						
						RETURN sCodigoRetorno, 
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
							sStatus WITH RESUME;
						
					END IF;
				END FOREACH;	
				END IF;	
			END IF;
		
		-- Búsqueda por número de cliente.
		ELIF ( piTipoBusqueda = 2 ) THEN
	
			LET psNumCliente = TRIM( psNumCliente );
			
			-- Se buscan las cuentas de cheques e inversiones crecientes.
			FOREACH
				SELECT cuenta
					INTO sNumCuenta
				FROM bdicheq:"informix".sc_maechq
				WHERE num_cte = psNumCliente
				UNION
				SELECT cuenta_tf 
				FROM bditransfer:tf_maecte
				WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = psNumCliente
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentadebito( sNumCuenta, psNumCliente, psNumTarjeta, psEmpresa, 1 )
						INTO sCodigoRetorno, 
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
							sStatus
						
					IF ( sCodigoRetorno = '00000' ) THEN
					
						LET iCont = iCont + 1;
						
						RETURN sCodigoRetorno,
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto,
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
							sStatus WITH RESUME;
					
					END IF;
				END FOREACH;	
			END FOREACH;
			
			-- Se buscan las cuentas de pagarés.
			FOREACH
				SELECT DISTINCT cuenta
					INTO sNumCuenta
				FROM bdinvers:"informix".sv_maeinv
				WHERE num_cte = psNumCliente
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentadebito( sNumCuenta, psNumCliente, psNumTarjeta, psEmpresa, 1 )
						INTO sCodigoRetorno, 
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
							sStatus
							
					IF ( sCodigoRetorno = '00000' ) THEN
					
						LET iCont = iCont + 1;
						
						RETURN sCodigoRetorno,
							sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto,
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno,
							sStatus WITH RESUME;
					
					END IF;
				END FOREACH;	
			END FOREACH;			

		-- Búsqueda por número de tarjeta.
		/*ELIF ( piTipoBusqueda = 3 ) THEN
		
			LET psNumTarjeta = TRIM( psNumTarjeta );
			
			-- Se busca la cuenta de la tarjeta.
			SELECT a.cuenta
				INSERT INTO sNumCuenta
			FROM bdicheq:"informix".sc_tarjeta a
				LEFT OUTER JOIN intercard:"informix".tarjeta b ON ( a.num_tarjeta = b.numtarjeta )
				LEFT OUTER JOIN intercard:"informix".statustarjeta c ON ( b.codstatustarjeta = c.codstatustarjeta )
			WHERE a.empresa = psEmpresa AND a.num_tarjeta = psNumTarjeta;

			IF ( NVL( sNumCuenta, '' ) <> '' ) THEN
			
				EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentadebito( sNumCuenta, psNumCliente, psNumTarjeta, psEmpresa, 1 )
					INTO sCodigoRetorno, 
						sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
						sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, 
						sStatus;
				
				IF ( sCodigoRetorno = '00000' ) THEN
				
					LET iCont = 1;
					
					RETURN sCodigoRetorno,
						sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto,
						sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno,
						sStatus;
				
				END IF;
			END IF;				
		END IF;*/
		ELIF (piTipoBusqueda = 3) THEN
			LET psNumTarjeta = TRIM(psNumTarjeta);
			SELECT a.cuenta, a.numcte, a.num_tarjeta, NVL(c.nombre, '')
			INTO sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto
			FROM bdicheq:"informix".sc_tarjeta a
			LEFT OUTER JOIN bdicheq:"informix".sc_maechq b ON (a.cuenta = b.cuenta) 
			JOIN bdicheq:"informix".sc_producto c ON (b.producto = c.producto)				
			WHERE a.num_tarjeta = psNumTarjeta AND a.empresa = psEmpresa; 
			
			IF (sNumCuenta IS NOT NULL AND sNumCliente IS NOT NULL AND sNumTarjeta IS NOT NULL AND sDescProducto <> '') THEN
				
				SELECT numcte, NVL(nombre1, ''), NVL(nombre2, ''), NVL(apell_paterno, ''), NVL( apell_materno, '')
				INTO sNumCliente, sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno
				FROM bdinteg:"informix".si_cliente WHERE numcte = sNumCliente;
				
					IF (sNumCliente IS NOT NULL) THEN

						SELECT UPPER(b.descstatustarjeta)
						INTO sStatus FROM intercard:"informix".tarjeta a JOIN intercard:"informix".statustarjeta b
						ON (a.codstatustarjeta = b.codstatustarjeta) WHERE a.numtarjeta = sNumTarjeta;
								
						IF (sNumCliente IS NOT NULL) THEN 						
							LET iCont = 1;					
							RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, sStatus WITH RESUME;							
						END IF;
				    END IF;
			END IF;			
		END IF;
		
		IF ( iCont = 0 ) THEN
		
			LET sCodigoRetorno = '00001'; -- Cliente no tiene cuentas.
			
			RETURN sCodigoRetorno,
				sNumCuenta, sNumCliente, sNumTarjeta, sDescProducto,
				sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno,
				sStatus;
			
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO:		Francisco Rodríguez Ibarra.',
'FECHA:			30 de abril de 2010.',
'DESCRIPCIÓN:	Obtiene las cuentas de débito , ya sea por numcliente, por cuenta o por numtarjeta',
'RETORNO:		00000 Datos obtenidos satisfactoriamente',
'				00001 Cliente sin cuentas.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Viernes, 31 de Diciembre de 2011.',
'MODIFICACIÓN:	Se reestructuran y optimizan las búsquedas para consultar cuentas de cheques, inversiones y pagarés.',

'MODIFICÓ:		Bernardo Carlos Báez González .',
'FECHA:			10 de Febrero de 2012.',
'PRO./FOLIO:    SIFAuditoria/1249.',
'PAQUETE/CU:    PCU-bdinteg/CU-0162-ConsultarCuentaDebito-SPL.',
'MODIFICACIÓN:	Se Modifican Para que se Retorne el Status de Tarjeta en vez status de la Cuenta.',

'MODIFICÓ:		JOSE ANGEL GAXIOLA GAXIOLA.',
'FECHA:			09 DE OCTUBRE DE 2012 .',
'PRO./FOLIO:    ConsultaAuditoriaSIF/1228.',
'MODIFICACIÓN:	SE MODIFICA AGREGANDOLE FOREACH PARA QUE PUEDA RETORNAR MAS DE UNA TARJETA PARA UNA CUENTA .';

CREATE PROCEDURE "informix".sp_dicta_consanalistadictamen()

	-- RETORNOS DEL PROCEDIMIENTO
	RETURNING 	CHAR(6)  		AS  Codigo,
				CHAR(8)			AS 	Numero,
				CHAR(45)		AS 	Nombre;
				
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(6);
	DEFINE cNumAnalista 	CHAR(8);
	DEFINE cNombreAnalista 	CHAR(45);
	
	--INICIALIZACION DE VARIABLES
	LET iSqlErr 		= 0;
	LET cCodRet 		= '000000';
	LET cNumAnalista 	= '';
	LET cNombreAnalista = '';
	
	--SET DEBUG FILE TO '/informix/cristo/sp_dicta_consanalistadictamen.out';
	--TRACE ON;
	
		BEGIN 				--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;			
				RETURN cCodRet, TRIM(NVL(cNumAnalista,"")), TRIM(NVL(cNombreAnalista,""));
			END IF;
		END EXCEPTION;	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
			-- SE BUSCAN TODOS LOS REGISTROS DE TIPO DE DICTAMEN Y SU DESCRIPCION
			FOREACH   
				SELECT DISTINCT (TRIM(analista_fraudes))
				INTO cNumAnalista
				FROM 'informix'.si_bitacora_comparaciones
				WHERE status_alerta = 3
				
				SELECT nombre
				INTO cNombreAnalista
				FROM 'informix'.si_ejecut
				WHERE ejecutivo = cNumAnalista;
				
				RETURN cCodRet, TRIM(NVL(cNumAnalista,"")), TRIM(NVL(cNombreAnalista,"")) WITH RESUME;				
			END FOREACH
			
			 -- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '000001';
				RETURN cCodRet, TRIM(NVL(cNumAnalista,"")), TRIM(NVL(cNombreAnalista,""));
			END IF;
		END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE CONSULTA LOS CAMPOS TIPODICTAMEN Y DESCRIPCION DE LA TABLA BDISITESP:SE_CATDICTAMENES ',
'AUTOR: FRANCISCO EDUARDO BENITEZ BAEZ ',
'FECHA: 10 DE SEPTIEMBRE DEL 2014 ',
'VERSION: 201410091730',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_dicta_consultacatdictamen()

	-- RETORNOS DEL PROCEDIMIENTO
	RETURNING 	CHAR(6)  		AS  CODIGO_DE_RETORNO,
				CHAR(1)			AS 	TIPO_DE_DICTAMEN,
				CHAR(100)		AS 	DESCRIPCION
				
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(6);
	DEFINE cTipoDictamen CHAR(1);
	DEFINE cDescripcion CHAR(100);
	
	--INICIALIZACION DE VARIABLES
	LET iSqlErr 		= 0;
	LET cCodRet 		= "000000";
	LET cTipoDictamen 	= "";
	LET cDescripcion 	= "";
	
	--SET DEBUG FILE TO '/informix/cristo/sp_dicta_consultacatdictamen.out';
	--TRACE ON;
	
		BEGIN 				--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;			
				RETURN cCodRet, TRIM(NVL(cTipoDictamen,"")), TRIM(NVL(cDescripcion,""));
			END IF;
		END EXCEPTION;	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
			-- SE BUSCAN TODOS LOS REGISTROS DE TIPO DE DICTAMEN Y SU DESCRIPCION
			FOREACH   
				SELECT tipoDictamen, TRIM(descripcion)
				INTO cTipoDictamen, cDescripcion
				FROM bdisitesp:"informix".se_catdictamenes
				ORDER BY tipoDictamen, descripcion
				RETURN cCodRet, TRIM(NVL(cTipoDictamen,"")), TRIM(NVL(cDescripcion,"")) WITH RESUME;				
			END FOREACH
			
			 -- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '000001';
				LET cDescripcion = 'NO EXISTEN REGISTROS CON LA INFORMACION PROPORCIONADA.';
				RETURN cCodRet, TRIM(NVL(cTipoDictamen,"")), TRIM(NVL(cDescripcion,""));
			END IF;
		END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE CONSULTA LOS CAMPOS TIPODICTAMEN Y DESCRIPCION DE LA TABLA BDISITESP:SE_CATDICTAMENES ',
'AUTOR: FRANCISCO EDUARDO BENITEZ BAEZ ',
'FECHA: 10 DE SEPTIEMBRE DEL 2014 ',
'VERSION: 201410091730',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_alta_indicadores_2014_prod(fecha_inicial DATE, fecha_final DATE)
RETURNING CHAR(6), CHAR(100);
--VARIABLES DE ERROR
DEFINE cVarDataErr      	VARCHAR(64);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE vCodRet          	CHAR(6);
--DEFINICION DE VARIABLES		
--DEFINE dFechahoy			DATE;		
DEFINE vcod_param_sms		SMALLINT;
DEFINE vcod_param_cels		SMALLINT;
DEFINE vcod_param_correo	SMALLINT;
DEFINE dmax_fecha_insert	DATE;
DEFINE vsms_val				INTEGER;
DEFINE vsms_total			INTEGER;
DEFINE vsms_no_val			INTEGER;
--DEFINE fecha_inicial		DATE;
--DEFINE  fecha_final	DATE;
DEFINE ivalidos				INTEGER;
DEFINE iinvalidos			INTEGER;
DEFINE isin_validar			INTEGER;
DEFINE mes_inicial 			INTEGER;
DEFINE mes_final 			INTEGER;

--ALTA DE CLIENTES
DEFINE vcod_param_alta_cte	SMALLINT;  
DEFINE cnumcte				CHAR(20);
DEFINE iBanco				INTEGER;
DEFINE icoppel				INTEGER;
DEFINE ibanco_coppel 		INTEGER;
DEFINE isolo_coppel 		INTEGER;
DEFINE isolo_banco			INTEGER;
DEFINE ibca_basica			INTEGER;
DEFINE ibca_avanzada		INTEGER;
DEFINE csucursal			CHAR(4);
DEFINE iprospectos			INTEGER;
DEFINE dfecha_alta			DATE;
DEFINE iTitulares			INTEGER;
DEFINE isinproductos		INTEGER;

--ASIGNACION DE VARIABLES
LET vcod_param_sms=0;
LET vcod_param_cels=0;
LET vcod_param_correo=0;
LET vsms_val=0;				
LET vsms_total=0;	
LET vsms_no_val=0;	
LET ivalidos=0;			
LET iinvalidos=0;
LET isin_validar=0;
LET mes_inicial =0;
LET mes_final =0;
--ALTA DE CLIENTES
LET vcod_param_alta_cte=0;
LET cnumcte='';
LET iBanco=0;
LET icoppel=0;
LET ibanco_coppel=0;
LET isolo_coppel=0;
LET isolo_banco=0;
LET ibca_basica=0;
LET ibca_avanzada=0;
LET csucursal='';
LET iprospectos=0;
LET dfecha_alta='';
LET iTitulares=0;
LET isinproductos=0;

--ASIGNACION DE VARIABLES ERROR
LET vCodRet = '000000';
LET cVarDataErr = 'EL REPORTE DE ESTADISTICAS, FUE GENERADO SATISFACTORIAMENTE';
--SET DEBUG FILE TO '/informix/rmarquez/sp_get_estadisticas_correos_telefonos.out';
--TRACE ON;
BEGIN
	--Manejo del error
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
			LET vCodret=iSqlErr;			
			ROLLBACK;
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_alta_ctes_titulares') THEN
				DROP TABLE tmp_alta_ctes_titulares;
			END IF;	
			RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	---SET pdqpriority 10;	
	--CONSULTA EL VALOR A LA TABLA SI_PARAM
		
	BEGIN WORK;		
	--TABLA TEMPORAL DE CLIENTES TITULARES		
	SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.fecha_alta
	FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
	WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta between fecha_inicial AND  fecha_final
	AND a.tipo_cliente='1'	
	INTO TEMP tmp_alta_ctes_titulares
	WITH NO LOG; 
	CREATE INDEX "informix".tmp_idx_alta_ctes_titulares ON tmp_alta_ctes_titulares (numcte, fecha_alta, sucursal);
		
--ESTADISTICAS DE ALTA DE CLIENTES		
		
	WHILE  (fecha_inicial <= fecha_final)			
 	
		LET ibanco_coppel = 0;
		LET isolo_coppel = 0;
		LET isolo_banco = 0;
		LET isinproductos = 0;	
		
		--GENERA TOTALES GLOBALES DE ALTA DE CLIENTES.
		SELECT NVL(COUNT(*),0)
		INTO iTitulares
		FROM tmp_alta_ctes_titulares
		WHERE fecha_alta = fecha_inicial;
		
		SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} NVL(COUNT(*),0)
		INTO iProspectos
		FROM bdinteg:si_cliente
		WHERE tipo_cliente = '2'
		AND fecha_alta= fecha_inicial; 
						
		FOREACH --	AGREGAR LA SUCURSAL
			SELECT numcte, sucursal 
			INTO cnumcte, csucursal
			FROM tmp_alta_ctes_titulares
			WHERE fecha_alta= fecha_inicial
			
			LET iBanco = 0;
			LET iCoppel = 0;
			
			IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
				LET iBanco=1;
			ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud<>'C') THEN
				LET iBanco=1;			
			ELIF EXISTS(SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
				LET iBanco=1;
			END IF;			
			IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud='C') THEN
				LET iCoppel=1; 
			END IF;
			--CONTABILIZA LOS TOTALES DE CLIENTES POR PRODUCTO
			IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
				LET isinproductos = isinproductos + 1;  
			END IF;	
			IF (iBanco = 1 AND iCoppel=1) THEN
				LET ibanco_coppel = ibanco_coppel + 1;  
			ELSE
				LET isolo_coppel = isolo_coppel + iCoppel; 
				LET isolo_banco = isolo_banco + iBanco; 
			END IF;			
		END FOREACH;
		
		--TOTAL DE CLIENTES TITULARES QUE SE LES DIO EL SERVICIO DE BANCA ELECTRONICA BASICA Y BANCA AVANZADA.	
		SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
		INTO ibca_basica, ibca_avanzada
		FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
							CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
							CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
							FROM bdinteg:"informix".si_bpiusuarios a, tmp_alta_ctes_titulares b
							WHERE a.numcte=b.numcte
							AND a.suc_registro= b.sucursal 
							AND a.f_registro::DATE=fecha_inicial
							AND b.fecha_alta::DATE=fecha_inicial
							GROUP BY a.servicio)));  
							
		INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
		VALUES (fecha_inicial, NVL(iTitulares,0), NVL(iProspectos,0), NVL(( iTitulares + iProspectos),0), NVL(isolo_coppel,0), NVL(isolo_banco,0) , NVL(ibanco_coppel,0), NVL(isinproductos,0), NVL(ibca_basica,0), NVL(ibca_avanzada,0), USER, CURRENT);
	
		--VALIDA SI NO INSERTO EN LA TABLA
		IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
			INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
			VALUES(fecha_inicial, 0, 0, 0,0,0,0,0, USER, CURRENT);
		END IF;						
	
	LET fecha_inicial= fecha_inicial + 1;	
	END WHILE; 		
	COMMIT WORK;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_alta_ctes_titulares') THEN
		DROP TABLE tmp_alta_ctes_titulares;
	END IF;	
	RETURN vCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'REALIZA:Estadísticas sobre alta de clientes',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:28/10/2014',
'VERSION:20141028',
'ELABORÓ: Rocio Karina Márquez Coronel',
'DESCRIPCION: Se creo sp para generar información faltante a la tabla de si_alta_ctes indicadores de la base de datos bdinteg.',
'Del 16 al 21 de Octubre de 2014';

CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_dia_corporativo(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_numeroCliente CHAR(20), p_skip INT, p_sTarjeta CHAR(30), p_sEmpresa CHAR(4))

    RETURNING	DATE AS fechaMovimiento, DATETIME HOUR to FRACTION(3) AS horaMovimiento , money(16,2) AS monto, 
                CHAR(30) AS folioSuc, CHAR(40) AS nombreSucursal, CHAR(40) AS tipo, CHAR(1) AS reversado, CHAR(10) AS id, 
                CHAR(20) AS cuenta, CHAR(1) AS naturaleza,CHAR(40) AS referencia ,CHAR(20) AS tarjeta;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento 	DATE;
	DEFINE resultado_monto              money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR to FRACTION(3);
	DEFINE resultado_folioSuc           CHAR(30);
	DEFINE resultado_nombreSucursal     CHAR(40);
    DEFINE resultado_tipo               CHAR(40);
   	DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_id             	CHAR(10);
   	DEFINE resultado_cuenta             CHAR(20);
    DEFINE resultado_naturaleza         CHAR(1);
    DEFINE resultado_referencia         CHAR(40);
    DEFINE resultado_tarjeta        	CHAR(20);
    
    DEFINE cuenta_temp              	CHAR(20);
	/*VJMP Cuenta Transfer*/
	DEFINE cuenta_temp_tf              	CHAR(20);
    
    DEFINE iSqlErr                  	INTEGER;
     
     -- InicializaciÃ?Â³n de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
    	LET resultado_nombreSucursal = '';
	LET resultado_tipo = '';
    	LET resultado_reversado = '';
    	LET resultado_id = '';
    	LET resultado_cuenta = '';
    	LET resultado_naturaleza = '';
    	LET resultado_referencia = '';
    	LET resultado_tarjeta = '';

    	SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_nombreSucursal = '';
                    LET resultado_tipo = '';
                    LET resultado_reversado = '';
                    LET resultado_id = '';
                    LET resultado_cuenta = '';
                    LET resultado_naturaleza = '';
                    LET resultado_referencia = '';
                    LET resultado_tarjeta = '';
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, 
                            resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, 
                            resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta;
                END IF;
        END EXCEPTION;

            IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
				/*Movimientos TRANSFER Tarjeta VJMP Inicio*/
				Select mc.cuenta_tf
					INTO cuenta_temp_tf
					From bditransfer:tf_maecte mc
					Inner Join bdicheq:sc_tarjeta t ON ( t.cuenta = mc.cuenta_tf)
					where t.num_tarjeta = p_sTarjeta;
				IF cuenta_temp_tf IS NOT NULL AND cuenta_temp_tf <> '' THEN
					FOREACH       
						Select SKIP p_skip
							tat.fech_alt, tat.fech_hor_ini, tat.monto, tat.id_transacc_mps, (Select Trim(nombre) from bdinteg:si_sucursales where sucursal = '9747') as nombre,
							Trim(ct.descripcion) as Transaccion, 
							Case tat.id_reverso
								When '00000000000000000000' Then ''
								When Null Then ''
								When '' Then ''
								Else 'S'
							End As Reverso,
							tat.transacc, tat.cuenta, tat.naturaleza, tat.id_transacc_mps, ''
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta
						from bditransfer:tf_all_transaction tat
						LEFT JOIN bditransfer:tf_cat_transac_mps ct ON (ct.transac = tat.transacc)
						WHERE tat.cuenta = cuenta_temp_tf
							   AND tat.fech_alt >= p_sFechaInicial 
							   AND tat.fech_alt <= p_sFechaFinal 
							   ORDER BY tat.fech_alt asC, tat.fech_hor_ini asC
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta WITH RESUME;
					END FOREACH;
				Else
				/*Movimientos TRANSFER Tarjeta VJMP Fin*/
					select distinct numcuenta
						into cuenta_temp
						from intercard:tarjetacuenta 
						where numtarjeta = p_sTarjeta;

					FOREACH       
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, cuenta,bdinteg:si_transacc.naturaleza,referencia, num_tarjeta
						  INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta
						  FROM bdicheq:sc_movdia 
							LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
							LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
						  WHERE fech_val <= p_sFechaFinal 
							AND fech_val >= p_sFechaInicial 
							AND num_tarjeta = p_sTarjeta
							AND bdicheq:sc_movdia.empresa = p_sEmpresa
							AND cuenta = cuenta_temp
						  ORDER BY folio_suc asC, fech_val asC
						  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta WITH RESUME;
					END FOREACH;
				End If;
            ELSE
				/*Movimientos TRANSFER Cuenta VJMP Inicio*/
				Select cuenta_tf
					INTO cuenta_temp_tf
					from bditransfer:tf_maecte 
					where cuenta_tf = p_sNumeroCuenta;
				
				IF cuenta_temp_tf IS NOT NULL AND cuenta_temp_tf <> '' THEN
					FOREACH       
						Select SKIP p_skip
							tat.fech_alt, tat.fech_hor_ini, tat.monto, tat.id_transacc_mps, (Select Trim(nombre) from bdinteg:si_sucursales where sucursal = '9747') as nombre,
							Trim(ct.descripcion) as Transaccion, 
							Case tat.id_reverso
								When '00000000000000000000' Then ''
								When Null Then ''
								When '' Then ''
								Else 'S'
							End As Reverso,
							tat.transacc, tat.cuenta, tat.naturaleza, tat.id_transacc_mps, ''
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta
						from bditransfer:tf_all_transaction tat
						LEFT JOIN bditransfer:tf_cat_transac_mps ct ON (ct.transac = tat.transacc)
						WHERE tat.cuenta = cuenta_temp_tf
							   AND tat.fech_alt >= p_sFechaInicial 
							   AND tat.fech_alt <= p_sFechaFinal 
							   ORDER BY tat.fech_alt asC, tat.fech_hor_ini asC
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia, resultado_tarjeta WITH RESUME;
					END FOREACH;
				Else
				/*Movimientos TRANSFER Cuenta VJMP Fin*/
					IF (p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '') THEN
						FOREACH       
							SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, cuenta,bdinteg:si_transacc.naturaleza,referencia, num_tarjeta
							  INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza, resultado_referencia, resultado_tarjeta
							  FROM bdicheq:sc_movdia 
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
							  WHERE fech_val <= p_sFechaFinal 
								AND fech_val >= p_sFechaInicial 
								AND cuenta = p_sNumeroCuenta
								AND bdicheq:sc_movdia.empresa = p_sEmpresa
							  ORDER BY folio_suc asC, fech_val asC
							  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza, resultado_referencia, resultado_tarjeta WITH RESUME;
						END FOREACH;
					ELSE
						FOREACH       
							SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, bdicheq:sc_maechq.cuenta, bdinteg:si_transacc.naturaleza,referencia,num_tarjeta
							  INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza, resultado_referencia,resultado_tarjeta
							  FROM bdicheq:sc_movdia 
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
								LEFT JOIN bdicheq:sc_maechq ON (bdicheq:sc_movdia.cuenta = bdicheq:sc_maechq.cuenta AND bdicheq:sc_maechq.empresa = p_sEmpresa)
							  WHERE fech_val <= p_sFechaFinal 
								AND fech_val >= p_sFechaInicial 
								AND num_cte = p_numeroCliente
								AND bdicheq:sc_movdia.empresa = p_sEmpresa
							  ORDER BY folio_suc asC, fech_val asC
							  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza, resultado_referencia, resultado_tarjeta WITH RESUME;
						END FOREACH;
					END IF;
				End If;
           END IF;
	END 
END PROCEDURE;