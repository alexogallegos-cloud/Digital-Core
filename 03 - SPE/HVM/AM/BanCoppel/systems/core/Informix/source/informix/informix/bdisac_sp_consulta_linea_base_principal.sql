CREATE PROCEDURE "informix".sp_consulta_linea_base_principal(pCaptura CHAR(20),
												pImporte CHAR(20), pNumCuenta CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno,
	CHAR AS LlevaDatosAdicionales,
	CHAR(700)  AS RespuestaAMostrar,
	CHAR(2000)  AS RespuestaDecodificada;


	--Definicion de Variables
	DEFINE iSqlErr 					INTEGER;
	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRet2     			CHAR(5);
	DEFINE i						INTEGER;
	DEFINE k 						CHAR(1);
	DEFINE cCadena 					CHAR(20);
	DEFINE cConcepto    			CHAR(250);
	DEFINE cLeyenda     			CHAR(20);
	DEFINE cTipoLicencia 			CHAR(1);
	DEFINE cTipoReferencia 			CHAR(10);
	DEFINE cDescripcionConcepto		CHAR(300);

	DEFINE cPeriodo					CHAR(300);
	DEFINE cPlaca 					CHAR(20);	--*
	DEFINE cModelo 					CHAR(15);
	DEFINE cFolio 					CHAR(25);	--*
	DEFINE cModeloFolio				CHAR(15);
	DEFINE cCantidad 				CHAR(15);
	DEFINE cFolioInfraccion 		CHAR(15);
	DEFINE cAnioInfraccion  		CHAR(10);
	DEFINE cTipoHolograma  			CHAR(150);
	DEFINE cMarca 					CHAR(50);
	DEFINE cVerificentro  			CHAR(10);

	DEFINE cReferencia 				CHAR(50);	--*
	DEFINE cEjercicioFiscal 		CHAR(4);

	DEFINE cRFC 					CHAR(12);
	DEFINE cMES						CHAR(50);
	DEFINE cPredial 				CHAR(25);	--*
	DEFINE cTipoOperacion  			CHAR(50);
	DEFINE cTramite 	  			CHAR(300);
	DEFINE cSubconcepto   			CHAR(300);
	DEFINE cTipoDeclaracion			CHAR(300);
	DEFINE cVigencia 				CHAR(30);

	DEFINE cRespuestaMostrar 		CHAR(700);
	DEFINE cRespuestaDecodificada	CHAR(2000);

	DEFINE cOrigen					CHAR(40);
	DEFINE cPrecio					CHAR(40);
	DEFINE cAdmonTributaria			CHAR(55);
	DEFINE cEjercicio				CHAR(100);
	DEFINE cBimestre				CHAR(20);
	DEFINE cLlevaDatosAdicionales	CHAR;

	--Inicializacion de Variables
	LET iSqlErr 				= 0;
	LET cCodRet 				= '00000';
	LET cCodRet2   				= '';
	LET i       				= 0;
	LET cCadena 				= '';
	LET k						= '';
	LET cConcepto 				= '';
	LET cLeyenda    			= '';
	LET cTipoLicencia			= '';
	LET cTipoReferencia			= '';
	LET cDescripcionConcepto 	= '';
	LET cPeriodo				= '';
	LET cFolio					= '';

	LET cPeriodo				= '';
	LET cPlaca 					= '';
	LET cModeloFolio			= '';
	LET cCantidad 				= '';
	LET cFolioInfraccion 		= '';
	LET cAnioInfraccion 		= '';
	LET cTipoHolograma 			= '';
	LET cMarca 					= '';
	LET cVerificentro 			= '';

	LET cReferencia 			= '';
	LET cEjercicioFiscal 		= '';

	LET cRFC 					= '';
	LET cMES 			   		= '';
	LET cPredial 				= '';
	LET cTipoOperacion  		= '';
	LET cTramite 	  			= '';
	LET cSubconcepto 			= '';
	LET cTipoDeclaracion		= '';
	LET cVigencia 				= '';

	LET cRespuestaMostrar		= '';
	LET cRespuestaDecodificada	= '';

	LET cOrigen					= '';
	LET cPrecio					= '';
	LET cAdmonTributaria		= '';
	LET cEjercicio				= '';
	LET cBimestre				= '';
	LET cLlevaDatosAdicionales	= '0';

	--SET DEBUG FILE TO '/home/informix/bibiana/sp_decodifica_linea_base_principal.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF (pImporte::INTEGER < 1) THEN --10
			--EL IMPORTE DEL PAGO ES MENOR A 10 PESOS
			LET cCodRet = '00001';

		ELSE

			IF(LENGTH(TRIM(NVL(pCaptura,'')))==20) THEN
				IF(pCaptura[1,2] IN ('01','03','05','07','09','11','13','14'))THEN
				--TRANSITO, VIALIDAD Y MEDIO AMBIENTE LICENCIAS
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_licencias(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Tipo='||TRIM(NVL(cTipoLicencia,''))||'|Periodo='||TRIM(NVL(cPeriodo,''))||'|Referencia='||TRIM(NVL(cTipoReferencia,''))||'|';
				ELIF(pCaptura[1,2] IN ('20','21'))THEN 
				--PERMISOS ADMINISTRATIVOS TEMPORALES REVOCABLES 
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatospermisosadmintemrevo(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Folio='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('36','37','38','39','40','41','42','43','44','45','46'))THEN --- Se quita el concepto 48 BGV
				--TRAMITES DE VEHICULOS PARTICULARES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosTramitesVehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cOrigen,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cMarca,'')) || '|' || TRIM(NVL(cModelo,'')) || '|' || TRIM(NVL(cPlaca,'')) || '|';
				ELIF(pCaptura[1,2] IN ('49'))THEN
				--MULTAS DE TRANSITO
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_multas(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Folio Infracción='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('50','51','52'))THEN
				--MEDIO AMBIENTE
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_medio(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPlaca, cModelo, cMarca, cFolioInfraccion, cAnioInfraccion, cVerificentro, cTipoHolograma, cCantidad,cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Placa='||TRIM(NVL(cPlaca,''))||'|Modelo='||TRIM(NVL(cModelo,''))||'|Marca='||TRIM(NVL(cMarca,''))||'|Folio Infracción='||TRIM(NVL(cFolioInfraccion,''))||'|Año Infracción='||TRIM(NVL(cAnioInfraccion,''))||'|Clave Verificentro='||TRIM(NVL(cVerificentro,''))||'|Tipo Holograma='||TRIM(NVL(cTipoHolograma,''))||'|Cantidad='||TRIM(NVL(cCantidad,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('54','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77'))THEN
				--TRAMITES DEL REGISTRO CIVIL
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosRegistroCivil(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio, cCantidad, cPrecio, cReferencia, cAdmonTributaria, cConcepto;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					IF(pCaptura[1,2] == ('77')) THEN
					--SE OMITE '|' || TRIM(NVL(cAdmonTributaria,'')) || VIENE EN EL PDF PERO NO EN EL RECIBO OFICIAL
						LET cRespuestaDecodificada = '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
					ELSE
						LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
					END IF;

				ELIF(pCaptura[1,2] IN ('78','79'))THEN
				--SERVICIOS DE LA POLICIA
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioPolicia(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|';
				ELIF(pCaptura[1,2] IN ('80','81'))THEN
				--IMPUESTO PREDIAL
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosImpuestoPredial(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPredial, cEjercicio, cBimestre;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cPredial,'')) || '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
				ELIF(pCaptura[1,2] IN ('82','83'))THEN
				--DERECHOS POR SUMINISTRO DE AGUA
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioAgua(pCaptura, pImporte, pNumCuenta, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cEjercicio, cBimestre;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
					LET cLlevaDatosAdicionales = '1';
				ELIF(pCaptura[1,2] IN ('84','85','86','87'))THEN
				--TENENCIA Y DERECHOS VEHICULARES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_vehicular(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto,  cReferencia, cModeloFolio, cEjercicioFiscal;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Referencia='||TRIM(NVL(cReferencia,''))||'|Modelo o Folio='||TRIM(NVL(cModeloFolio,''))||'|Ejercicio Fiscal='||TRIM(NVL(cEjercicioFiscal,''))||'|';
					LET cLlevaDatosAdicionales = '1';
				ELIF(pCaptura[1,2] IN ('88','96','89','90','91','92','93','94','97','98'))THEN --- Se quita el concepto 94 y 95 ya que no son permitidos en el portal. BGV
				--OTRAS CONTRIBUCIONES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_otras(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cRFC, cEjercicioFiscal, cMes, cPredial, cTipoOperacion, cFolio, cTramite,cSubconcepto,cReferencia,   cTipoDeclaracion, cVigencia, cLlevaDatosAdicionales;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|Subconcepto='||TRIM(NVL(cSubconcepto,''))||'|';
					LET cRespuestaDecodificada = '|RFC='||TRIM(NVL(cRFC,''))||'|Ejercicio='||TRIM(NVL(cEjercicioFiscal,''))||'|Mes='||TRIM(NVL(cMes,''))||'|Cuenta Predial='||TRIM(NVL(cPredial,''))||'|Tipo de Operación='||TRIM(NVL(cTipoOperacion,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|Trámite='||TRIM(NVL(cTramite,''))||'|Referencia='||TRIM(NVL(cReferencia,''))||'|Tipo de Declaración='||TRIM(NVL(cTipoDeclaracion,''))||'|Vigencia='||TRIM(NVL(cVigencia,''))||'|';
					IF(pCaptura[1,2] IN('91','94','95','97','98')AND(cLlevaDatosAdicionales='0'))THEN
						LET cLlevaDatosAdicionales = '0';
					ELSE
						LET cLlevaDatosAdicionales = '1';
					END IF;
				ELSE
					--LA CLAVE DE PAGO NO CORRESPONDE A LAS OPERACIONES VALIDAS
					LET cCodRet = '00002';
				END IF;
			ELSE
				--LA LONGITUD DE LA LINEA DE CAPTURA ES DIFERENTE A 20 CARACTERES
				LET cCodRet = '00001';
			END IF;

		END IF;
		--LET cCodRet = '00000';
		RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DECODIFICA LA LINEA BASE Y LISTA LOS CAMPOS A MOSTRAR',
'AUTOR : Liliana Perez',
'FECHA : 27-04-2018',
'VERSION: ',
'BD: bdisac',
'Folio: ';

CREATE PROCEDURE "informix".sp_guardasoldespagosky(pImporteTransaccion money(10,2), pFolioSuc char(16), pNumCuenta char(12), pUsuario char(8)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet;
	
	--Definicion de Variables
	DEFINE cCodigoRet  CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEnteId CHAR(3);
	DEFINE cMpelId CHAR(15);
	DEFINE cFolio_pago CHAR(10);
	DEFINE cAutorizacion CHAR(10);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cEnteId = '0';
	LET cMpelId = '0';
	LET cFolio_pago ='';
	LET cAutorizacion = '';

	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM(NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		 --Validamos parámetros para que no sean nulos
		 IF NVL(pImporteTransaccion,'') = '' OR NVL(pFolioSuc,'') = '' OR NVL(pNumCuenta,'') = '' OR NVL(pUsuario,'') = '' THEN
		 LET cCodigoRet = '00001';		 RETURN NVL(cCodigoRet,"");
         ELSE	
		 
		 SELECT mpel_id INTO cMpelId FROM sac_sky_wsgpago where folio_suc = pFolioSuc;
		 SELECT autorizacion INTO cAutorizacion FROM sac_sky_wsgpago where folio_suc = pFolioSuc; 
		 SELECT valor into cEnteId FROM sac_param WHERE cod_param = '114';

		 
		 LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);	
		 
		 INSERT INTO "informix".sac_sky_wsgreverso(txn_status,ente_id,numcuenta,fechadepbanco,importetrans,folio_pago,autorizacion_s,mpel_id_s,uso_futuro1,uso_futuro2,uso_futuro3,folio_suc,usuario_insert,fecha_insert) 
		 VALUES('C',cEnteId,pNumCuenta,today,pImporteTransaccion,cFolio_pago,cAutorizacion,cMpelId,null,null,null,pFolioSuc,pUsuario,today);
		  	
	 	
		 IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		 END IF;	
	END IF;
	
	RETURN  TRIM(NVL(cCodigoRet,""));
	
	END;
END PROCEDURE;