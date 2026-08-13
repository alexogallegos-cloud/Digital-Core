CREATE PROCEDURE "informix".sp_generahuellalinea(
													pNumCte CHAR(20),
													pIP CHAR(15),
													pTipoMov CHAR(2),
													pEmpleado CHAR(8),
													pVerificacion CHAR(2),
													pSensor CHAR(2)
												)

--DATOS A REGRESAR---
RETURNING
CHAR(5) 					AS CodigoRetorno,
CHAR(2000) 					AS TramaSalida;


--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCadena				CHAR(2000);
DEFINE dFechaCons			DATETIME YEAR TO DAY;
DEFINE fechaComparacion		DATETIME YEAR TO DAY;
DEFINE cSecuencia			CHAR(2);
DEFINE cSexo				CHAR(1);
DEFINE cSucursal			CHAR(4);
DEFINE cFechAlta			CHAR(10);
DEFINE cHuellaD				CHAR(942);
DEFINE cHuellaI				CHAR(942);
DEFINE cStatuHuella 		CHAR(1);
DEFINE cRefCte				CHAR(20);
DEFINE dFechaUltCon			DATETIME YEAR TO SECOND;
DEFINE cTipoCte				CHAR(2);
DEFINE cTicket				CHAR(20);
DEFINE cStatusCons			CHAR(1);
DEFINE cRspMsj601			CHAR(1);
DEFINE cFechaAlt			CHAR(10);
DEFINE cFecUlCam			CHAR(18);
DEFINE cContador 			INTEGER;
DEFINE cContador_2 			INTEGER;
DEFINE cContador_3			INTEGER;
DEFINE cContador_4			INTEGER;
DEFINE cContador_5			CHAR(1);
DEFINE cContador_6			INTEGER;
DEFINE cSecuenciaMax 		INTEGER;
DEFINE cSecuenciaDec 		INTEGER;
DEFINE iHuellas_cap 		SMALLINT;
DEFINE dFecha_alta_prueba 	DATE;
DEFINE cprint				CHAR(50);
DEFINE iExiste				SMALLINT;
DEFINE iVacio				SMALLINT;

  --SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_PropuestaFinal.out";
  --TRACE ON;

--INICIALIZACION DE VARIABLES--
LET iSql_err 	 		= 0;
LET cCodRet 	 		= '00000';
LET cCadena		 		= "";
LET dFechaCons	 		= TODAY;
LET fechaComparacion	= TODAY;
LET cSecuencia	 		= "";
LET cSexo		 		= "";
LET cSucursal	 		= "";
LET cFechAlta	 		= "";
LET cHuellaD	 		= "";
LET cHuellaI	 		= "";
LET cStatuHuella 		= "";
LET cRefCte		 		= "";
LET dFechaUltCon 		= CURRENT YEAR TO SECOND;
LET cTipoCte	 		= "";
LET cTicket		 		= "";
LET cStatusCons  		= "0";
LET cRspMsj601   		= "";
LET cFechaAlt	 		= "";
LET cFecUlCam	 		= "";
LET cContador    		= 0;
LET cContador_2  		= 0;
LET cContador_3  		= 0;
LET cContador_4  		= 0;
LET cContador_5			= "0";
LET cContador_6			= 0;
LET cSecuenciaMax 		= 0;
LET cSecuenciaDec 		= 1;
LET iHuellas_cap 		= 0;
LET dFecha_alta_prueba 	= TODAY;
LET cprint				= '';
LET iExiste				= 0;
LET iVacio				= 0;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet, cCadena;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

	--Controlar tipo pTipoMov = 'A' y pTipoMov vacio
	IF (pTipoMov = 'A') THEN
		LET pTipoMov = '1';
	ELIF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL )	THEN
		LET pTipoMov = '1';
		LET iVacio = 1;
	END IF;
	
	SELECT COUNT(*) 
	INTO cContador
	FROM bdinteg:"informix".si_cliente 
	WHERE numcte = pNumCte;

	IF (cContador > 0) THEN		
		
		--Fecha Consulta
		SELECT fecha_hoy 
		INTO dFechaCons 
		FROM bdinteg:"informix".si_fechas 
		WHERE empresa = '001';
		
		--Nuevas lineas para comparar si fueron tomadas nuevas huellas. En caso de que si se pone cContador_5 = '1'
		SELECT MAX(fecha)
		INTO fechaComparacion
		FROM bdinteg:"informix".si_cte_huella_dec_actual
		WHERE numcte = pNumCte;

		SELECT COUNT(*) 
        INTO cContador_6
        FROM bdinteg:"informix".si_huella_linea_dec 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
	
		IF (fechaComparacion == dFechaCons )THEN
			LET cContador_5 = '1';
		END IF;
		
		
		
		--Se consulta la huella del cliente si no existen o es de otro dia la consulta se agregan
		SELECT COUNT(*) 
		INTO cContador_2
		FROM bdinteg:"informix".si_huella_linea 
		WHERE fecha_consulta <> dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> "";
		IF (cContador_5 =='1') THEN
			IF (cContador_2 > 0) THEN
				
				IF (iVacio = 1) THEN
					--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
					LET pTipoMov = '4';
				END IF;
				
				INSERT INTO bdinteg:"informix".si_huella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
															empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, 
															tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, 
						imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				DELETE FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;			
			END IF;
		END IF;
		--ref_coppel, Tipo Persona
        SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona)
		INTO cRefCte, cTipoCte
		FROM bdinteg:"informix".si_cliente cte
		WHERE cte.numcte = pNumCte;
           
        --sexo
        SELECT TRIM(ctepf.sexo)
		INTO cSexo
		FROM bdinteg:"informix".si_ctepf ctepf
		WHERE ctepf.numcte = pNumCte;

		--tiene huella el cliente	
        SELECT COUNT(*) 
        INTO cContador_3
        FROM bdinteg:"informix".si_cte_huella 
        WHERE numcte = pNumCte;
		
		IF (cContador_3 > 0)THEN			
			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte AND estado = 'A';

			--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
			SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), 
					NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
			INTO cSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte
			AND secuencia = cSecuenciaMax;
		END IF;
			
		-- Se insertan registros en la si_huella_linea
		LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
		
		
		
		--Se consulta la huella del cliente, si es el mismo dia se regresan los mismo datos ya consultados
        SELECT COUNT(*) 
        INTO cContador_4
        FROM bdinteg:"informix".si_huella_linea 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
		
		
		IF (cContador_5 =='1') THEN
			IF (cContador_4 = 0) THEN
			
				INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
													empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
													tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES  (pNumCte, dFechaCons, cSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);
			END IF;
		END IF;
		LET cFecUlCam = TO_CHAR(dFechaUltCon);
		LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";
		
		--Se construye trama
		LET cCadena = TRIM(pNumCte) ||"|"|| TRIM(cSecuencia) ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
			||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
			||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
			||"|"|| TRIM(pVerificacion) ||"|";
		
		--INICIA 10 HUELLAS
		IF cContador_5 == '1' THEN
			IF (cContador_6 = 0) THEN

				IF (cContador_3 > 1) THEN
					SELECT MAX(secuencia)
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				END IF;

				-- SE INSERTA TABLA si_huella_linea_dec codigo nuevo proyecto 10 huellas
				SELECT count(numcte) 
				INTO iHuellas_cap 
				FROM bdinteg:"informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
													ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
													fecha_ult_cambio,huellas_cap,fecha_insert)
					VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
								
				END IF; 
				
				SELECT COUNT(numcte) 
				INTO iExiste 
				FROM bdinteg:"informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
				AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal, 
														fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
														tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
														fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
							tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
							origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
							codret_result
					FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
					
					-- SELECT ticket 
					-- INTO cTicket 
					-- FROM bdinteg:"informix".si_huella_linea_dec 
					-- WHERE numcte = pNumCte
					-- AND secuencia = cSecuenciaDec;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																	fecha_nac,situacion,causa,activo)
						SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
						FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
				END IF;
				
				
			 
			END IF;		 
		END IF;
	ELSE
		LET cCodRet = '00001';
		LET cCadena = 'El cliente no existe en la si_cliente';
	END IF;

	RETURN cCodRet, TRIM(cCadena);
END;
END PROCEDURE

DOCUMENT
'Inserta registro en si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agrega un insert a la si_huella_linea_dec y a la si_huella_linea_dec_hist',
'Modifico: Carlos Vazquez Mitre',
'Fecha: 31/01/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Para RQI 63 730 Comparacion en linea 10 huellas, se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 890 Se agrega una consulta a la si_cte_huella_dec_actual para saber si hay algun cambio en las huellas. Se anadieron las variables cContador_5 y cContador_6 para evitar que se anadan campos a la tablas si no hay nuevas huellas',
'Modifico: Jahaziel Eduardo Heredia Hinojosa',
'Fecha: 29/12/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_generahuellalinea_chl(pNumCte CHAR(20),pIP CHAR(15),pTipoMov CHAR(2),pEmpleado CHAR(8),pVerificacion CHAR(2), pSensor CHAR(2))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(2000) 	AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 	INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cCadena		CHAR(2000);
	DEFINE dFechaCons	DATETIME YEAR TO DAY;
	DEFINE smSecuencia	SMALLINT;
	DEFINE cGeneraTrama	CHAR(1);
	DEFINE smSec_linea	SMALLINT;
	DEFINE cSexo		CHAR(1);
	DEFINE cSucursal	CHAR(4);
	DEFINE cFechAlta	CHAR(10);
	DEFINE cHuellaD		CHAR(942);
	DEFINE cHuellaI		CHAR(942);
	DEFINE cStatuHuella CHAR(1);
	DEFINE cRefCte		CHAR(20);
	DEFINE dFechaUltCon	DATETIME YEAR TO SECOND;
	DEFINE cTipoCte		CHAR(2);
	DEFINE cTicket		CHAR(20);
	DEFINE cStatusCons	CHAR(1);
	DEFINE cRspMsj601	CHAR(1);
	DEFINE cFechaAlt	CHAR(10);
	DEFINE cFecUlCam	CHAR(18);
	DEFINE dFecha_alta_prueba 	DATE;
	DEFINE iExiste		SMALLINT;
	DEFINE iHuellas_cap 		SMALLINT;
	DEFINE cSecuenciaDec 		INTEGER;
	--DEFINE cContador_3			INTEGER;
	DEFINE iVacio				SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';
	LET cCadena		 = "";
	LET dFechaCons	 = TODAY;
	LET smSecuencia	 = 0;
	LET cGeneraTrama = '0';
	LET smSec_linea	 = 0;
	LET cSexo		 = "";
	LET cSucursal	 = "";
	LET cFechAlta	 = "";
	LET cHuellaD	 = "";
	LET cHuellaI	 = "";
	LET cStatuHuella = "";
	LET cRefCte		 = "";
	LET dFechaUltCon = CURRENT YEAR TO SECOND;
	LET cTipoCte	 = "";
	LET cTicket		 = "";
	LET cStatusCons  = "0";
	LET cRspMsj601   = "";
	LET cFechaAlt	 = "";
	LET cFecUlCam	 = "";
	LET dFecha_alta_prueba 	= TODAY;
	LET iExiste				= 0;
	LET iHuellas_cap 		= 0;
	LET cSecuenciaDec 		= 1;
	--LET cContador_3  		= 0;
	LET iVacio				= 0;
	


	--SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_chl_PropuestaFinal.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cCadena;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) THEN
			
			--Controlar pTipoMov vacio
			IF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL ) THEN
				LET pTipoMov = '1';
				LET iVacio = 1;
			END IF;
			
			SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona), TRIM(ctepf.sexo)
			INTO cRefCte, cTipoCte, cSexo
			FROM bdinteg:"informix".si_cliente cte,
				 bdinteg:"informix".si_ctepf ctepf
			WHERE cte.numcte = pNumCte
			AND ctepf.numcte = pNumCte;
				
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte)THEN
				--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
				SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
				INTO smSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
				FROM bdinteg:"informix".si_cte_huella 
				WHERE numcte = pNumCte
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte AND estado = 'A');
			END IF;
			
			--Fecha Consulta
			SELECT fecha_hoy INTO dFechaCons FROM bdinteg:"informix".si_fechas;
			LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
			
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND status_consulta <> "") THEN
				-- Se actualiza registro en la si_huella_linea
				SELECT NVL(secuencia ,'0'), NVL(ticket,'')
				INTO smSec_linea, cTicket
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				IF smSecuencia > smSec_linea THEN	
				
					IF (iVacio = 1) THEN
						--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
						LET pTipoMov = '4';
					END IF;
				
					INSERT INTO bdinteg:"informix".si_huella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert)
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
					
					INSERT INTO bdinteg:"informix".si_huella_linea_resultado_hist_chl (estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, 
								nombre, fecha_nac, situacion, causa)
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					DELETE FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
										
					DELETE FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					LET cTicket = '';
					
					INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
								empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, 
								respuesta_msj601)
					VALUES	(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
							pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte, pVerificacion, cTicket, cStatusCons, 
							cRspMsj601);
					/*UPDATE bdinteg:"informix".si_huella_linea SET fecha_consulta = dFechaCons, secuencia = smSecuencia, sexo = cSexo, sucursal = cSucursal, 
						   fecha_alta_huella = TO_DATE(cFechaAlt, "%Y-%m-%d"), ip = pIP, tipo_mov_huella = pTipoMov, empleado = pEmpleado, tipo_sensor = pSensor, 
						   dmapa = cHuellaD, imapa = cHuellaI, status_huella = cStatuHuella, ref_coppel = cRefCte, fecha_ult_cambio = dFechaUltCon, tipo_cliente = cTipoCte,
							tipo_verificacion = pVerificacion , ticket = cTicket, status_consulta = cStatusCons, respuesta_msj601 = cRspMsj601, fecha_insert = CURRENT
					WHERE numcte = pNumCte;*/

					LET cGeneraTrama = '1';
				ELSE
					LET cCodRet = '00002';
					LET cCadena = 'El registro no afecto si_huella_linea porque ya existe';
				END IF;
			ELSE
				INSERT INTO bdinteg:"informix".si_huella_linea(	numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
																empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
																tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);

				LET cGeneraTrama = '1';
			END IF;
			
	
			
			IF cGeneraTrama = '1' THEN
				LET cFecUlCam = TO_CHAR(dFechaUltCon);
				LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";

				--Se construye trama
				LET cCadena = TRIM(pNumCte) ||"|"|| smSecuencia ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
					||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
					||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
					||"|"|| TRIM(pVerificacion) ||"|";
			END IF;
					
					--tiene huella el cliente	
        --SELECT COUNT(*) 
        --INTO cContador_3
        --FROM bdinteg:"informix".si_cte_huella 
        --WHERE numcte = pNumCte;
		
	
			
		-- INICIA 10 HUELLAS
		
				
			 --IF (cContador_3 > 1) THEN
				SELECT MAX(secuencia) 
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				--END IF;
				
				-- SE INSERTA TABLA si_huella_linea_dec
				SELECT count(numcte) 
					INTO iHuellas_cap 
				FROM "informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte
					AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO "informix".si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
																		ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
																		fecha_ult_cambio,huellas_cap,fecha_insert)
						VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
				END IF;
				
				SELECT COUNT(numcte) 
					INTO iExiste 
				FROM "informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
					AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO "informix".si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,
						fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
						tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
						fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
						tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
						origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
						codret_result
					FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
					
					-- SELECT ticket 
						-- INTO cTicket 
					-- FROM "informix".si_huella_linea_dec 
					-- WHERE secuencia = cSecuenciaDec 
						-- AND numcte = pNumCte;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																		fecha_nac,situacion,causa,activo)
							SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
							FROM "informix".si_huella_linea_dec_result 
							WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM "informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
				END IF;
				
		
		ELSE
			LET cCodRet = '00001';
			LET cCadena = 'El cliente no existe en la si_cliente';
		END IF;

		RETURN cCodRet, TRIM(cCadena);
	END

END PROCEDURE

DOCUMENT
'Inserta registro en bdinteg:si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'**************************************************************************************',
'MODIFICACION:Se modifica para eliminar el UPDATE de la tabla si_huella_linea cuando ya exista registro de las huellas del cliente,',
'en su lugar realizara un movimiento de la informacion al historico y despues insertara el(los) nuevo(s) registro(s)',
'SUSTENTA: RQI 64 060',
'FECHA : 03/DICIEMBRE/2014',
'MODIFICACION:Se modifica el tipo de dato de las variables smSecuencia y smSec_linea para evitar problemas funcionales en el proceso',
'SUSTENTA: RQI 64 166',
'FECHA : 15/JUNIO/2016',
'**************************************************************************************',
'MODIFICACION:Se modifica para generar el registro en si_huella_linea_dec y si aplica generar los historicos',
'Autor : Narciso Cisneros',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA : 25/MARZO/2022',
'----------------------------------------------------------------------------',
'MOFICACION:se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'MOFICACION:se elimina la validacion cuando la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 05/01/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inserta_actividad_economica_cliente(p_NumCte CHAR(20), p_Sucursal CHAR(4), p_Ejecutivo CHAR(8),  p_Actividad CHAR(100))
        RETURNING CHAR(6);
		
		DEFINE v_CodRet 				VARCHAR(5);
		DEFINE sql_err                  INTEGER;
        DEFINE isam_err                 INTEGER;
        DEFINE error_info               VARCHAR(60);
		DEFINE v_Existe					INTEGER;
		
		DEFINE v_Fecha					DATETIME year to second;
		
		LET v_CodRet					='00000';
		LET sql_err                     = 0;
        LET isam_err                    = 0;
        LET error_info                  = "";
		LET v_Existe					= 0;
		LET v_Fecha						= CURRENT;
		BEGIN
                ON EXCEPTION SET sql_err, isam_err, error_info
                        LET v_CodRet = sql_err;
                        RETURN v_CodRet;
                END EXCEPTION;
				
				SELECT  count(*) INTO v_Existe FROM si_cliente WHERE numcte = p_NumCte;
				
				IF v_Existe <=0 THEN
					LET v_CodRet = '00001';
				ELSE
					INSERT INTO si_cliente_actividad_economica (empresa, numcte, sucursal, ejecutivo, fecha_insert, actividad_economica) 
					VALUES('001',p_NumCte,p_Sucursal,p_Ejecutivo,v_Fecha,p_Actividad);
				END IF;
				
				RETURN v_CodRet;
		END
END PROCEDURE
DOCUMENT
'SP para Insertar actividad economica del cliente cuando se corra la calificaciÃ³n inicial de riesgo de cliente',
'AUTOR : Eduardo Ãvila PÃ©re Tagle',
'Area: Sitemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Miguel Angel Mendoza Maldonado',
'Fecha: 01/Mayo/2024',
'Version: 2.0.0',
'BD: bdinteg',
'Requerimiento: RQM 11 178 CalificaciÃ³n inicial de riesgo de cliente';

CREATE PROCEDURE "informix".sp_wsenviohuellas(fechaActual DATE,registros INT)

RETURNING
        CHAR(5)   as ccCodRetorno,
        char(100) as mensaje,
        CHAR(10)  as cCliente_coppel,
        CHAR(10)  as cCliente_banco,
        CHAR(10)  as cUsuario,
        CHAR      as cSexo,
        CHAR      as cCompany,
        CHAR      as cstore_number,
        CHAR      as cStatus_huella,
        date      as dFecha_insert,
        CHAR      as cDpositiond,
        CHAR      as cDsecuencia,
        CHAR(942) as cDMapa,
        CHAR      as cIpositiond,
        CHAR      as cIsecuencia,
        CHAR(942) as cIMapa;


DEFINE  ccCodRetorno    CHAR(5);
DEFINE  mensaje         char(100);                                                                        
DEFINE  cCliente_coppel CHAR(10);
DEFINE  cCliente_banco  CHAR(10);
DEFINE  cUsuario        CHAR(10);
DEFINE  cSexo           CHAR;
DEFINE  cCompany        CHAR;
DEFINE  cstore_number   CHAR;
DEFINE  cStatus_huella  CHAR;
DEFINE  dFecha_insert   date;
DEFINE  cDpositiond     CHAR;
DEFINE  cDsecuencia     CHAR;
DEFINE  cDMapa          CHAR(942);
DEFINE  cIpositiond     CHAR;
DEFINE  cIsecuencia     CHAR;
DEFINE  cIMapa          CHAR(942);
DEFINE  iNumreg         INTEGER;
DEFINE  sql_err         INTEGER;
DEFINE  isam_err        INTEGER;
DEFINE  vcodret1        INTEGER;
DEFINE  vcodret2        INTEGER;

LET  ccCodRetorno       = '00000';
LET  mensaje            = 'EXITO' ;
LET  cCliente_coppel    = '';
LET  cCliente_banco     = '';
LET  cUsuario           = '';
LET  cSexo              = '';
LET  cCompany           = '';
LET  cstore_number      = '';
LET  cStatus_huella     = '';
LET  dFecha_insert      = mdy(01,01,1900);
LET  cDpositiond        = '';
LET  cDsecuencia        = '';
LET  cDMapa             = '';
LET  cIpositiond        = '';
LET  cIsecuencia        = '';
LET  cIMapa             = '';
LET  iNumreg            = 0;

BEGIN

        ON EXCEPTION SET sql_err, isam_err
            IF sql_err <> 0 THEN
                                LET ccCodRetorno = sql_err;
                                LET mensaje = 'NUM ISAM ERR: '|| isam_err || ' ' || "SQL";
            RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,TODAY,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/EPG/sp_wsenviohuellas.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
        IF   ( registros IS NULL OR registros = '' OR registros < 0  ) THEN
                LET ccCodRetorno = '00002';
                LET mensaje = "Valor de variable registros no validos";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF

        DELETE FROM sp_temphuella;
		
        INSERT INTO  bdinteg:cte_coppel_huella 
        SELECT a.numcte_coppel,0,c.numcte_banco, CURRENT TIMESTAMP,a.fecha_insert,'' 
        FROM clientes_coppel_envia_xml a 
        LEFT JOIN cte_coppel_huella b ON a.numcte_coppel = b.numcte_coppel 
        LEFT JOIN si_relacion_ctebcplcpl c ON c.cliente = a.numcte_coppel
        WHERE b.numcte_coppel IS NULL AND a.fecha_insert >= MDY(month (fechaActual),day (fechaActual),year(fechaActual));
 

        INSERT INTO  bdinteg:sp_temphuella 
        SELECT LIMIT registros numcte_coppel, numcte_banco 
		FROM cte_coppel_huella
		--INNER JOIN si_huella_linea AS a on numcte_banco = a.numcte 
		WHERE estatus = 0  
			and date (fec_xml_creacion)= MDY(month (fechaActual),day (fechaActual),year(fechaActual));

					
        FOREACH
              
            SELECT LIMIT registros d.numcte_coppel, d.numcte_banco
            INTO  cCliente_coppel,cCliente_banco
            FROM sp_temphuella AS d
                    
			SELECT empleado, sexo, 5 AS company, 2 AS store_number, status_huella, date (fecha_alta_huella),  2 AS positiond, secuencia, dmapa, 7 AS positiond, secuencia, imapa 
            INTO  cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa
            FROM si_huella_linea AS a 
			WHERE a.numcte = cCliente_banco;	
				
			IF cUsuario is null THEN
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 3, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
			ELSE
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 1, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
				LET iNumreg = iNumreg + 1;     	 

				RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa WITH RESUME;

			END IF;
			
        END FOREACH;


        IF  iNumreg = 0 THEN
                LET ccCodRetorno = '00001';
                LET mensaje = "No se encontro informacion por actualizar";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;

END


END PROCEDURE;