CREATE PROCEDURE "informix".sp_generaarchivocobranzaantad(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE vCadena_req					CHAR(334);
DEFINE cComercio					CHAR(5);

DEFINE vTpoRegistro 				CHAR(1);
DEFINE vId_registro					INTEGER;
DEFINE vFech_trans					CHAR(17);
DEFINE vFechaTran					CHAR(19);
DEFINE vTpoTransaccion				CHAR(6);
DEFINE vReferencia 	 				CHAR(50);
DEFINE vEmisor						CHAR(5);
DEFINE vSucursal					CHAR(15);
DEFINE vCaja						CHAR(12);
DEFINE vCajero						CHAR(12);
DEFINE vImporte 					CHAR(16);
DEFINE vComision 					CHAR(16);
DEFINE vNum_Aut 	 				CHAR(6);
DEFINE vFolio_comercio 				CHAR(12);
DEFINE vId_trans 					CHAR(12);
DEFINE vForma_pago 					CHAR(1);
DEFINE vTipo_proceso 				CHAR(1);
DEFINE vCod_resp 					CHAR(2);
DEFINE vNum_tarjeta 				CHAR(16);
DEFINE vCuenta_Cargo				CHAR(12);

DEFINE vNumero_Operaciones			INTEGER;
DEFINE vImporte_Total 				INTEGER;
DEFINE vImporte_Total_Comision		INTEGER;


DEFINE dFechaIni					DATE;
DEFINE dFecha_Hoy					DATE;	
DEFINE dFecha_Max_Procesada			DATE;	
DEFINE cRutaArchAntad				CHAR(38);
DEFINE cStmt						CHAR(500);
DEFINE vValor						CHAR(150);
DEFINE vCadena_Completa				CHAR(1620);
DEFINE vFolio_suc					CHAR(16);
DEFINE vNumcategoria				CHAR(2);
DEFINE vNumconvenio					CHAR(3);


--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cComercio				= '';

LET vTpoRegistro				= '';
LET vId_registro				= 0 ;
LET vFech_trans					= '';
LET vFechaTran					= '';
LET vTpoTransaccion				= '';
LET vReferencia 	 			= '';
LET vEmisor						= '';
LET vSucursal					= '';
LET vCaja						= '';
LET vCajero						= '';
LET vImporte 					= '';
LET vComision 					= '';
LET vNum_Aut 	 				= '';
LET vFolio_comercio 			= '';
LET vId_trans 					= '';
LET vForma_pago 				= '';
LET vTipo_proceso 				= '';
LET vCod_resp 					= '';
LET vNum_tarjeta 				= '';
LET vCuenta_Cargo				= '';
LET vNumero_Operaciones			= 0;
LET vImporte_Total 				= 0;
LET vImporte_Total_Comision		= 0;

--LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET dFecha_Max_Procesada	= MDY('01','01','1900');
LET cRutaArchAntad			= '';
LET cStmt					= '';
LET vValor					= '';
LET vCadena_Completa		= '';
LET vFolio_suc				= '';
LET vNumcategoria			= '';
LET vNumconvenio			= '';


	--SET DEBUG FILE TO  '/informix/noe/sp_generaarchivocobranzaantad.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				--WHERE nom_rutina ='sp_generaarchivocobranzaantad';
				WHERE numcategoria =SUBSTR(pConvenio,1,2) and numconvenio=SUBSTR(pConvenio,3,3);
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		
--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria =SUBSTR(pConvenio,1,2) and numconvenio=SUBSTR(pConvenio,3,3);
		
		
--SI fecha_ultimo_archivo ES IGUAL A HOY, NO GENERA ARCHIVO
		IF dFechaIni = dFecha_Hoy THEN
			RETURN;
		END IF;
		


		--SI NO ENCONTRO MOVIMIENTOS ASIGNA LA FECHA_HOY(SAC_FECHAS) A FECHA_MAXIMA_PROCESADA
		--IF DBINFO('sqlca.sqlerrd2') =0 THEN
		LET dFecha_Max_Procesada = dFecha_Hoy;
		--END IF;


--ASIGNA VALOR A LAS VARIABLES  DE FECHA
		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');
		
		
--ID COMERCIO
		SELECT valor INTO vValor FROM bdisac:"informix".sac_param where cod_param = 87140;
			IF DBINFO("sqlca.sqlerrd2") = 0 Or trim(vValor) = '' THEN
				LET cCodRet = '00003';
				RETURN;
			END IF;

		LET cComercio= TRIM(vValor);



--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT FIRST 1 ruta_archivo_cobranza || nombre_archivo_cobranza
		INTO vValor
		FROM "informix".sac_convenios
		--WHERE nomconvenio like '%(ANTAD)' AND statusconvenio='A';
		WHERE numcategoria =SUBSTR(pConvenio,1,2) and numconvenio=SUBSTR(pConvenio,3,3);
		
		LET cRutaArchAntad = REPLACE(vValor,' ','') || '.txt';


		
--REEMPLAZA LA MASCARA POR LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaArchAntad = REPLACE(cRutaArchAntad,'AAAA',cAnio);
		LET cRutaArchAntad = REPLACE(cRutaArchAntad,'MM',cMes);
		LET cRutaArchAntad = REPLACE(cRutaArchAntad,'DD',cDia);



--CABECERA
		LET vTpoRegistro = 1;
		LET cStmt = 'echo "' || vTpoRegistro || LPAD(TRIM(cComercio), 5, '0') || cAnio || cMes || cDia || '0210' || '" >> ' || cRutaArchAntad;
		SYSTEM cStmt;

		

--DETALLE OPERACIONES
		LET vTpoRegistro  = 2;

		DROP TABLE IF EXISTS TB_CONVENIOS_ANTAD_TMP;
		SELECT numcategoria || numconvenio convenio, nombre_referencia2 emisor FROM "informix".sac_convenios 
		WHERE nomconvenio like '%(ANTAD)' 
		INTO TEMP TB_CONVENIOS_ANTAD_TMP WITH NO LOG;

	--Busca catg||conv de los convenios que tuvieros movimientos en las fechas especificadas
		FOREACH 
		
		--Se agrega validaciÃ³n para permitir PA cuando un pago es reversado y uno exitoso
		       SELECT M.numcategoria, M.numconvenio, TO_CHAR(M.fecha_insert), M.forma_pago, M.cuenta_cargo, M.folio_suc, R.cadena_req, R.campo8, R.campo11, R.campo7 
				INTO vNumcategoria, vNumconvenio, vFechaTran, vForma_pago, vCuenta_Cargo, vFolio_suc, vCadena_Completa, vNum_Aut, vId_trans, vCod_resp
			   FROM "informix".sac_movimientoshistorial M, "informix".sac_msw_respuesta R
				WHERE M.numcategoria = R.numcategoria AND M.numconvenio = R.numconvenio AND M.folio_suc = R.folio_suc
			   AND M.numcategoria || M.numconvenio IN (SELECT convenio FROM TB_CONVENIOS_ANTAD_TMP)
			   AND M.flag_confirmacion_central='1' AND M.flag_confirmacion_sucursal='1'
			   AND M.fecha_pago > dFechaIni AND M.fecha_pago <= dFecha_Max_Procesada 
			   AND M.status_cancelado <> 'S' 
			   AND (R.campo7 <> 'PA' OR (R.campo7 = 'PA'
                                        AND EXISTS (SELECT M2.referencia1
										            FROM sac_movimientoshistorial M2
													WHERE M2.numcategoria || M2.numconvenio IN (SELECT convenio FROM TB_CONVENIOS_ANTAD_TMP) 
													AND M2.flag_confirmacion_central = '1' AND M2.flag_confirmacion_sucursal = '1'
			                                        AND M2.fecha_pago > dFechaIni AND M2.fecha_pago <= dFecha_Max_Procesada
                                                    AND M2.status_cancelado IN ('N','S')
		                                            GROUP BY M2.referencia1
		                                            HAVING COUNT(DISTINCT M2.status_cancelado) = 2 )))			   

		
		/* SELECT M.numcategoria, M.numconvenio, TO_CHAR(M.fecha_insert), M.forma_pago, M.cuenta_cargo, M.folio_suc, R.cadena_req, R.campo8, R.campo11, R.campo7 
				  INTO vNumcategoria, vNumconvenio, vFechaTran, vForma_pago, vCuenta_Cargo, vFolio_suc, vCadena_Completa, vNum_Aut, vId_trans, vCod_resp
				FROM "informix".sac_movimientoshistorial M, "informix".sac_msw_respuesta R
				WHERE M.numcategoria=R.numcategoria and M.numconvenio=R.numconvenio and M.folio_suc=R.folio_suc
				AND M.numcategoria || M.numconvenio in(SELECT convenio FROM TB_CONVENIOS_ANTAD_TMP)
				AND M.flag_confirmacion_central='1' AND M.flag_confirmacion_sucursal='1'
				AND M.fecha_pago > dFechaIni and M.fecha_pago <= dFecha_Max_Procesada 
				AND M.status_cancelado <> 'S' and R.campo7 <> 'PA' */

				SELECT emisor INTO vEmisor FROM TB_CONVENIOS_ANTAD_TMP WHERE convenio = vNumcategoria || vNumconvenio;

				LET vCadena_req = TRIM(vCadena_Completa);
				
				LET vId_registro	= vId_registro + 1;
				LET vFech_trans		= REPLACE(TRIM(vFechaTran),'-','');
				LET vTpoTransaccion	= SUBSTR(vCadena_req,58,6);
				LET vReferencia 	= RPAD(trim(substr(vCadena_req,64,37)),50,' ');
				LET vSucursal 		= LPAD(trim(substr(vCadena_req,10,4)),15,'0');
				LET vCaja 			= LPAD(trim(substr(vCadena_req,14,8)),12,'0');
				LET vCajero			= LPAD(trim(substr(vCadena_req,14,8)),12,'0');
				LET vImporte 		= LPAD(replace(trim(substr(vCadena_req,101,9)),'.',''),16,'0');
				LET vComision 		= LPAD(replace(trim(substr(vCadena_req,117,9)),'.',''),16,'0');
				LET vNum_Aut 		= LPAD(vNum_Aut,6,'0');
				LET vFolio_comercio = LPAD(trim(substr(vCadena_req,37,8)),12,'0');
				LET vTipo_proceso 	= 'E';
				LET vNum_tarjeta 	= '0000000000000000';


				IF vForma_pago = '2' THEN

					LET vNum_tarjeta=(SELECT num_tarjeta FROM bdicheq:sc_movhis WHERE folio_suc=substr(vCadena_req,14,8) || substr(vCadena_req,37,8) and cuenta=vCuenta_Cargo);

					IF length(vNum_tarjeta) =16 THEN
						LET vNum_tarjeta= LPAD(substr(vNum_tarjeta,13,4),16,'*');
					ELSE
						LET vNum_tarjeta 	= '0000000000000000';
					END IF;
					
				END IF;

				
				LET cStmt = 'echo "' || vTpoRegistro 
									 || LPAD(vId_registro,7,'0')
									 || vFech_trans
									 || vTpoTransaccion
									 || vReferencia
									 || vEmisor
									 || vSucursal
									 || vCaja
									 || vCajero
									 || vImporte
									 || vComision
									 || vNum_Aut
									 || vFolio_comercio
									 || vId_trans
									 || vForma_pago
									 || vTipo_proceso
									 || vCod_resp
									 || vNum_tarjeta || '" >> ' || cRutaArchAntad;
				SYSTEM cStmt;


				LET vNumero_Operaciones= vNumero_Operaciones + 1;
				LET vImporte_Total = vImporte_Total + cast(vImporte as INTEGER);
				LET vImporte_Total_Comision = vImporte_Total_Comision + CAST(vComision AS INTEGER);
					
		END FOREACH;


		DROP TABLE IF EXISTS TB_CONVENIOS_ANTAD_TMP;
		
--FIN REPORTE
		LET vTpoRegistro  = 3;	

		LET cStmt = 'echo "' || vTpoRegistro
							 || LPAD(vNumero_Operaciones,7,'0')
							 || LPAD(vImporte_Total,12,'0')
							 || LPAD(vImporte_Total_Comision,12,'0')
							 || '" >> ' || cRutaArchAntad;
		SYSTEM cStmt;

		
		
--ACTUALIZA ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		--WHERE nom_rutina ='sp_generaarchivocobranzaantad';
		WHERE numcategoria =SUBSTR(pConvenio,1,2) and numconvenio=SUBSTR(pConvenio,3,3);

	END;
END PROCEDURE;