CREATE PROCEDURE "informix".sp_consulta_rostro_cliente(pOpcion SMALLINT,pIdCte CHAR(9),pSecuencia SMALLINT, pVuelta SMALLINT)
	RETURNING CHAR(5) AS CodigoRetorno,
			  CHAR(9) AS IdCte,
			  CHAR(9000) AS Template;

-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE cTemplate		CHAR(9000);	
	DEFINE cNumCte			CHAR(9);
	DEFINE sFila			SMALLINT;
	DEFINE sCuantos			SMALLINT;
		
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET cTemplate		= '';
	LET cNumCte			= '';
	LET sFila			= 0;
	LET sCuantos		= 0;	
	
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet,cNumCte,cTemplate;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Braulio/sp_consulta_rostro_cliente.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--VALIDAR PARÃMETROS VACÃOS O NULOS
	IF pOpcion IS NULL OR NVL(TRIM(pIdCte),'') = '' or NVL(pVuelta,0) = 0 THEN
		LET cCodRet = '00002';
	ELSE
		IF pOpcion = 1 THEN
			SELECT COUNT(*),numcte
			INTO sCuantos,cNumCte
			FROM bdinteg:"informix".si_cte_rostro 
			WHERE numcte = pIdCte
			AND  estado = 'A'
			GROUP BY numcte;
			
			IF sCuantos > 0 AND pVuelta > 0 THEN
				SELECT CASE 
				WHEN pVuelta = 1 THEN rmapa 
				WHEN pVuelta = 2 THEN rmapa2
				WHEN pVuelta = 3 THEN rmapa3
				WHEN pVuelta = 4 THEN rmapa
				END
				INTO cTemplate
				FROM bdinteg:"informix".si_cte_rostro 
				WHERE numcte = pIdCte
				AND estado = 'A'
				AND secuencia = pSecuencia;

			END IF;	
			
			IF NVL(cTemplate,'') = '' THEN
				LET cCodRet = '00001';
			END IF;
			
		END IF;
	END IF;
	
	RETURN cCodRet,cNumCte,cTemplate;
	
END;
END PROCEDURE
DOCUMENT
'Peticion: 271.1-Solicitud consulta biometria ws por interact y agregar ip a bitacora',
'Autor: 94206041 - Jesus Rosario Lopez Castro',
'Fecha: 11/08/2017',
'Descripcion...: Se crea procedimiento para Consultar el template del cliente y retornarlo',
'Solicita......: Abraham Narvaez',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sps_session_invalida_bpi_mx2(pEmpresa CHAR(3), pIdUsuario CHAR(11),pIp CHAR(15),pUsuarioIngresado CHAR(50),pPassIngresado CHAR(50),pSucursal CHAR(4),pNavegador CHAR(100))
   RETURNING CHAR(5) AS cCod_ret, CHAR(20) AS cNumCliente, CHAR(50) AS cDescEstatus;
   
--DEFINICION DE VARIABLES
DEFINE cCod_ret    CHAR(5);
DEFINE iSql_err    INTEGER ;
DEFINE cNumCliente CHAR (20);
DEFINE cDescEstatus CHAR (50);
DEFINE pSucursal2 CHAR(4);
DEFINE pIdUsuario2 CHAR(11);
DEFINE pIp2 CHAR(15);
DEFINE pUsuarioIngresado2 CHAR(50);
DEFINE pPassIngresado2 CHAR(50); 
DEFINE pNavegador2 CHAR(100); 
	
--INICIALIZACION DE VARIABLES
LET cCod_ret  = '000';
LET iSql_err = 0;
LET cNumCliente  = '';
LET cDescEstatus = '';

SET DEBUG FILE TO "/RESPALDOS/mabucio/ApoyosDesarrollo/sps_session_invalida_bpi.out";
TRACE ON;
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCod_ret = iSql_err;
            RETURN cCod_ret, cNumCliente, cDescEstatus;
		END IF;
	END EXCEPTION;

	--SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 5;
		
    let pSucursal2 = TRIM(pSucursal);
    let pIdUsuario2 = TRIM(NVL(pIdUsuario,''));
    let pIp2 = TRIM(pIp);
    let pUsuarioIngresado2 = TRIM(pUsuarioIngresado);
    let pPassIngresado2 = TRIM(pPassIngresado);
    let pNavegador2 = TRIM(pNavegador);

	--GRABA EN BITACORA CON CODIGO DE OPERACION INICIO DE SESSION == '9001'
	INSERT INTO bdinteg@stag_ids1170:si_bpibitacora_loginvalido (fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, sec_transaccion, cgenerico1, cgenerico2, navegador) 	            
	VALUES (CURRENT,'9001',pSucursal2,pIdUsuario2,pIp2,CURRENT,'1051',pUsuarioIngresado2,pPassIngresado2,pNavegador2);
	
	LET cCod_ret = '001';  -- Sesion Invalida Usuario Existe, Password NO Existe.
	LET cDescEstatus = 'Usuario correcto y password incorrecto';			 
	
	RETURN cCod_ret, cNumCliente, cDescEstatus;

END
END PROCEDURE
DOCUMENT
'Folio: 315.1 - RQI 03 602 . Registro inicio de sesión inválido en bitacora',
'Autor: Irma Ureta',
'BD: bdinteg',
'Fecha: 23/11/2017',
'Descripcion: Registra las sesiones de usuario correcto y password incorrecto al querer ingresar a la bpi';

CREATE PROCEDURE "informix".sp_grabahuellalinearesultado(
		pTipo SMALLINT,pEstado CHAR(4),pResultado CHAR(10),pCteMatch INTEGER,pEmpresa CHAR(4),pNumCte CHAR(20),pTicket CHAR(20), pSecCpl CHAR(2))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno;
	--DEFINICION DE VARIABLES--
	DEFINE iSql_err  INTEGER;
	DEFINE cCodRet 	 CHAR(5);
	
	DEFINE dFecha	 DATE;
	DEFINE dHora	 DATETIME HOUR TO SECOND;
	DEFINE cNumMsj	 CHAR(3);
	DEFINE iCiclos	 SMALLINT;
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';
	
	LET dFecha	= TODAY;
	LET dHora	= CURRENT HOUR TO SECOND;
	LET cNumMsj = "";
	LET iCiclos = 0;

--	SET DEBUG FILE TO "/tmp/Victor/sp_grabahuellalinearesultado_out.sql";
--	TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy INTO dFecha FROM bdinteg:"informix".si_fechas;
		
		FOR iCiclos = 1 TO LENGTH(pResultado)
			IF SUBSTR(pResultado,iCiclos,1) = 1 THEN
				LET pResultado = iCiclos::CHAR(2);
			END IF;
		END FOR;
		
		IF pResultado <> 10 THEN
			LET pResultado = SUBSTR(pResultado,1,1);
		ELSE
			LET pResultado = SUBSTR(pResultado,1,2);
		END IF;
	
		IF pTipo = 21 THEN --Ejecucion MSJ 601
		
			LET cNumMsj = "601";
			
			IF pEstado = "1" THEN --Se realizó la comparación
				
				--dsb-09/08/2013
				--Validar que no sea el mismo resultado
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_huella_linea_resultado WHERE 
				estado_proceso = pEstado AND
				resultado = pResultado AND
				cliente = pCteMatch AND
				ticket = pTicket AND
				empresa = pEmpresa AND
				num_mensaje = cNumMsj AND
				secuenciacpl = pSecCpl) THEN
				
				    IF pTicket <> "0" THEN --Se valida que si es ticket 0 no se inserte
					
						INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
							estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
						VALUES(pEstado,pResultado,pCteMatch,pTicket,dFecha,dHora, pEmpresa, cNumMsj, pSecCpl);
						
				    END IF
					
			END IF;
				
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "1")THEN
				
					IF SUBSTR(pResultado,1,1) <> 0 THEN
						--Hubo Coincidencias
						UPDATE bdinteg:"informix".si_huella_linea
						SET status_consulta = "2", respuesta_msj601 = "1"
						WHERE numcte = pNumCte
						AND ticket = pTicket 
						AND status_consulta = "1";
						
					ELSE
						--No hubo coincidencias
						UPDATE bdinteg:"informix".si_huella_linea
						SET status_consulta = "3", respuesta_msj601 = "1"
						WHERE numcte = pNumCte
						AND ticket = pTicket 
						AND status_consulta = "1";
					
					END IF;
					
				END IF;
			
			ELIF pEstado = "-106" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"0",0,"0",dFecha,dHora,"0",cNumMsj, pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "1")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3", respuesta_msj601 = "0"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "1";
					
				END IF;
			
			ELIF pEstado <> "1" AND pEstado <> "-106" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"0",0,"0",dFecha,dHora,"0",cNumMsj,pSecCpl);
				*/
			END IF;
		
		ELIF pTipo = 22 THEN --Ejecucion MSJ 602
		
			LET cNumMsj = "602";
			
			IF pEstado = "1" AND pTicket <> "0" THEN
			
				LET pEstado = "2";
				
				INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",pCteMatch,pTicket,dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
			
			ELIF pEstado = "-204" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",0,"0",dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
			
			ELIF pEstado <> "1" AND pEstado <> "-204" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",0,"0",dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "1"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
				
			END IF;
		
		END IF;
		
		RETURN cCodRet;

	END

END PROCEDURE;