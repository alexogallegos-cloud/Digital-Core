CREATE PROCEDURE "informix".sp_ope_genera_archivo_img_presentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoBloque INTEGER, pRutaDescarga CHAR(50), pDireccionMac CHAR(15), totalRegTrunc INTEGER)
                RETURNING CHAR(5) AS codret,
                          CHAR(50) AS nombreArchivoImg;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cNombreArchivo CHAR(30);
        DEFINE iTotalCheques INTEGER;
        DEFINE mTotalImporte DECIMAL(20,2);
        DEFINE cArchivoAI CHAR(30);
        DEFINE cBanco CHAR(3);
        DEFINE cMiBanco CHAR(3);
        DEFINE pFechaHoy DATE;
        DEFINE iDayFecha INTEGER;
        DEFINE iNumBloqueImg INTEGER;
        DEFINE cNumBloqueImg CHAR(7);
        DEFINE cCadenaImgEncabezado CHAR(250);
        DEFINE cTipoRegistro CHAR(2);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cVersion CHAR(3);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cSentido CHAR(1);
        DEFINE cMoneda CHAR(1);
        DEFINE cFechaProceso CHAR(8);
        DEFINE cUsoFuturo CHAR(1);
        DEFINE cCadenaImgDetalle CHAR(5000);
        DEFINE mMontoImagen DECIMAL(14,2);
        DEFINE iContIntercambio INTEGER;
        DEFINE cCodigoSeguridad CHAR(3);
        DEFINE cImported CHAR(15);
        DEFINE cImportes CHAR(16);
        DEFINE cMonto CHAR(12);
        DEFINE cMontos CHAR(13);
        DEFINE cCents CHAR(2);
        DEFINE bImagenF BLOB;
        DEFINE bImagenT BLOB;
        DEFINE cImagenFormatoT CHAR(3);
        DEFINE cImagenFormatoF CHAR(3);
        DEFINE iTotalChq INTEGER;
        DEFINE cTotalRegistros CHAR(9);
        DEFINE cCadenaImgSumario CHAR(100);
        DEFINE iExistenImgsDigitalizadas INTEGER;
        DEFINE iIdConsultaDetalleCheque40 INTEGER;
        DEFINE cDescBanco CHAR (40);
        DEFINE cCuentaReferencia CHAR(20);
        DEFINE cNumCheque INTEGER;
        DEFINE mImporte DECIMAL(14,2);
        DEFINE cCuentaDeposito CHAR(20);
        DEFINE cSucursalOperadora CHAR(44);
        DEFINE cChqProcesado CHAR(1);
        DEFINE cChqCompensacion CHAR(3);
        DEFINE cChqTransaccion CHAR(2);
        DEFINE cChqCodSeguridad CHAR(3);
        DEFINE cChqDigVerPre CHAR(1);
        DEFINE cChqDigVerInter CHAR(1);
        DEFINE cTransaccion CHAR(4);
        DEFINE cNombreCte CHAR(60);
        DEFINE cRfcCte CHAR(13);
        DEFINE cCurpCte CHAR(20);
        DEFINE cTipoCuentaDep CHAR(2);
        DEFINE cIndImgCheque CHAR(1);
        DEFINE iTamAnvImgCheque INTEGER;
        DEFINE iTamRevImgCheque INTEGER;
        DEFINE cEjecutivo CHAR(8);
        DEFINE cDireccionMac CHAR(15);
        DEFINE cIndDuplicado CHAR(1);
        DEFINE cIdStatusProceso CHAR(1);
        DEFINE cRowId INTEGER;
        DEFINE cSQL CHAR(1000);
        DEFINE cSumario CHAR(117);
        DEFINE cEncabezado CHAR(117);
        DEFINE cCommand CHAR(500);
        DEFINE cRutaArchivo CHAR(500);
        DEFINE cRutaJava CHAR(500);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cNombreArchivo = '';
        LET iTotalCheques = 0;
        LET mTotalImporte = 0.0;
        LET iContIntercambio = 0;
        LET cArchivoAI = '';
        LET cBanco = '';
        LET cMiBanco = '';
        LET pFechaHoy = NULL;
        LET iDayFecha = 0;
        LET cNombreArchivo = '';
        LET iNumBloqueImg = 0;
        LET cCadenaImgEncabezado = '';
        LET cTipoRegistro = '';
        LET cNumSecuencia = '';
        LET cVersion = '';
        LET cCodOperacion = '';
        LET cSentido= '';
        LET cMoneda = '';
        LET cFechaProceso = '';
        LET cUsoFuturo = '';
        LET cCadenaImgDetalle = '';
        LET mMontoImagen = 0.0;
        LET iContIntercambio = 0;
        LET cCodigoSeguridad = '';
        LET cMonto = '';
        LET cCents = '';
        LET bImagenF = null;
        LET bImagenT = null;
        LET cImagenFormatoT = '';
        LET cImagenFormatoF = '';
        LET iTotalChq = 0;
        LET mTotalImporte = 0.0;
        LET cTotalRegistros = '';
        LET cCadenaImgSumario = '';
        LET iExistenImgsDigitalizadas = 0;
        LET iIdConsultaDetalleCheque40 = 0;
        LET cDescBanco = '';
        LET cCuentaReferencia = '';
        LET cNumCheque = 0;
        LET mImporte = 0.0;
        LET cCuentaDeposito = '';
        LET cSucursalOperadora ='';
        LET cChqProcesado = '';
        LET cChqCompensacion = '';
        LET cChqTransaccion = '';
        LET cChqCodSeguridad = '';
        LET cChqDigVerPre = '';
        LET cChqDigVerInter = '';
        LET cTransaccion = '';
        LET cNombreCte = '';
        LET cRfcCte = '';
        LET cCurpCte = '';
        LET cTipoCuentaDep = '';
        LET cIndImgCheque = '';
        LET iTamAnvImgCheque = 0;
        LET iTamRevImgCheque = 0;
        LET cEjecutivo = '';
        LET cDireccionMac = '';
        LET cIndDuplicado = '';
        LET cIdStatusProceso = '';
        LET cRowId = 0;
        LET cSQL = '';
        LET cImported = '';
        LET cImportes = '';
        LET cMontos = '';
        LET cNumBloqueImg = '';
        LET cSumario = '';
        LET cEncabezado = '';
        LET cCommand = '';
        LET cRutaArchivo = '/home/intersoc/';
        LET cRutaJava = '/usr/java8'; --Parametrizar produccion

        BEGIN

                ON EXCEPTION SET iSqlErr
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet,'';
                END EXCEPTION;
                
                ON EXCEPTION IN (-668, -535, -255)
                END EXCEPTION WITH RESUME;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genera_archivo_img_presentado.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pNoBloque IS NULL OR pRutaDescarga = '' OR pDireccionMac = '' OR totalRegTrunc IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,'';
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,'';
                END IF;

               
                -- SE VALIDA QUE EXISTAN IMAGENES DIGITALIZADAS
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                SELECT COUNT(ind_img_cheque)
				INTO iExistenImgsDigitalizadas
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND ind_img_cheque = '2';

				IF iExistenImgsDigitalizadas = 0 THEN
					-- MANDASR MENSAJE DE QUE NO EXISTEN REGISTROS COMPLETOS
					LET iExistenImgsDigitalizadas = 0;
					SELECT COUNT(ind_img_cheque)
					INTO iExistenImgsDigitalizadas
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
						AND direccion_mac = pDireccionMac
						AND ind_img_cheque = '1';

					IF iExistenImgsDigitalizadas = 0 THEN
						LET cCodRet = '00780';
						 RETURN cCodRet,TRIM(cArchivoAI);
					END IF;

				END IF;



                SELECT  valor INTO cBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param ='5';
                SELECT fecha_hoy INTO pFechaHoy from bdicheq:sc_fechas where empresa = '001';
                LET iDayFecha = DAY(pFechaHoy);
                LET iContIntercambio = 1;
                LET cNombreArchivo = 'PRE_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y');
                LET cMiBanco = LPAD(cBanco,3,'0');

                SELECT count(nombrearchivo) INTO iNumBloqueImg FROM bditef:cce_gransumario WHERE nombrearchivo[1,12] =cNombreArchivo AND total_reg_ti <> '0';

                LET iNumBloqueImg = iNumBloqueImg;

                LET cArchivoAI ="EAI"||cMiBanco||"A1.AI"||LPAD(TO_CHAR(iDayFecha),2,'0')||LPAD(TO_CHAR(iNumBloqueImg),3,'0');



                IF totalRegTrunc > 0 THEN
                        --=========================
                        -- AI ENCABEZADO IMAGENES
                        --=========================
                        LET cCadenaImgEncabezado = '';

                        LET cTipoRegistro = '01';
                        LET cNumSecuencia = '0000001';
                        LET cVersion = '051';
                        LET cCodOperacion = '40';

                        LET cSentido= 'E';
                        LET cMoneda = '1';
                        LET cNumBloqueImg = LPAD(iNumBloqueImg,7,'0');
                        LET cUsoFuturo = ' ';


                        LET cFechaProceso = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');

                        LET cEncabezado = cTipoRegistro||cNumSecuencia||cVersion||cCodOperacion||cMiBanco||cSentido||cMoneda||cNumBloqueImg||cFechaProceso||LPAD(cUsoFuturo,83,' ');

                        --=========================
                        -- AI DETALLE IMAGENES
                        --=========================

                        LET cCadenaImgDetalle = '';

                        SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';
                        LET iTotalChq = 0;
                        LET mTotalImporte = 0.0;

                        DELETE FROM bdicnweb:"informix".ccep_procesdetalleimg_tmp;
                        
                        BEGIN WORK;

                        FOREACH SELECT id_consultadetallecheque40, banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora,
                                chq_procesado, chq_compensacion,chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, transaccion, nombre_cte, rfc_cte,
                                curp_cte,tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque,tam_rev_img_cheque, ejecutivo,direccion_mac,ind_duplicado,id_status_proceso,
                                imagenf,imagent,imagen_formatof,imagen_formatot
                                INTO iIdConsultaDetalleCheque40,cBanco,cDescBanco,cCuentaReferencia, cNumCheque,mImporte,cCuentaDeposito,cSucursalOperadora,cChqProcesado,
                                cChqCompensacion,cChqTransaccion,cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,
                                cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,cEjecutivo,cDireccionMac,cIndDuplicado,cIdStatusProceso,
                                bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT
                                FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
                                WHERE ejecutivo = pUsuario
                                AND direccion_mac = pDireccionMac
                                AND imagenf IS NOT NULL
                                AND imagent IS NOT NULL


                                IF mImporte > mMontoImagen AND cIndImgCheque = '1'  THEN
                                        IF iTamAnvImgCheque IS NOT NULL AND iTamRevImgCheque IS NOT NULL THEN
                                                LET iContIntercambio = iContIntercambio + 1;
                                                LET cTipoRegistro = '02';
                                                LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio),7,'0');
                                                LET cCodOperacion = '40';
                                                LET cCodigoSeguridad = LPAD(TRIM(cChqCodSeguridad),3,'0');
                                                --TRACE cCodigoSeguridad;
                                                --TRACE cImported;
                                                LET cImported = '';
                                                LET cImported = TO_CHAR(mImporte);
                                                LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
                                                LET cMonto = LPAD(TRIM(cMonto),12,'0');
                                                LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
                                                LET cCents = LPAD(TRIM(cCents),2,'0');
                                                LET cImported = TRIM(cMonto || cCents);
                                                
                                                --TRACE cImported;
                                                LET cUsoFuturo = '_';


                                                INSERT INTO bdicnweb:"informix".ccep_procesdetalleimg_tmp
                                                (tipoRegistro,numSecuencia,codOperacion,fechaProceso,bancoPropio,moneda,codigoSeguridad,
                                                chqDigVerPre,chqTransaccion,chqCompensacion,cBanco,chqDigInter,
                                                cuentaReferencia,numCheque,importeStr,usoFuturo,tamAnvImgCheque,
                                                tamRevImgCheque,imagenF,imagenT
                                                )VALUES
                                                (cTipoRegistro,cNumSecuencia,cCodOperacion,cFechaProceso,cMiBanco,cMoneda,cCodigoSeguridad,
                                                cChqDigVerPre,LPAD(cChqTransaccion,2,'0'),LPAD(cChqCompensacion,3,'0'),LPAD(cBanco,3,'0'),cChqDigVerInter,
                                                LPAD(cCuentaReferencia,13,'0'),LPAD(cNumCheque,10,'0'),cImported,LPAD(cUsoFuturo,13,'_'),LPAD(TO_CHAR(iTamAnvImgCheque),15,'0'),
                                                LPAD(TO_CHAR(iTamRevImgCheque),15,'0'),bImagenF,bImagenT);


                                                LET iTotalChq = iTotalChq + 1;
                                                LET mTotalImporte = mTotalImporte + mImporte;

                                        END IF;
                                END IF;
                        END FOREACH;
                        COMMIT;

                        
                        --=========================
                        -- AI SUMARIO IMAGENES
                        --=========================
                        LET cTipoRegistro = '09';
                        LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio + 1),7,'0');
                        LET cTotalRegistros = LPAD(TO_CHAR(iTotalChq ),9,'0');
                        LET cImportes = '';
                        LET cImportes = TO_CHAR(mTotalImporte);
                        LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
                        LET cMontos = LPAD(TRIM(cMontos),13,'0');
                        LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
                        LET cCents = LPAD(TRIM(cCents),2,'0');
                        LET cImportes = '0'||cMontos || cCents;
                  
                        LET cUsoFuturo = ' ';


                        LET cSumario = cTipoRegistro||cNumSecuencia||cTotalRegistros||cImportes||LPAD(cUsoFuturo,83,' ');
                        
                        SET ISOLATION TO DIRTY READ;
                        SET LOCK MODE TO WAIT 3;
						
                        LET cCommand = TRIM(cRutaJava)||"/bin/java -jar "||TRIM(cRutaArchivo)||"GeneraArchivoCCEAI.jar '"||TRIM(cArchivoAI)||"' '"|| cSumario ||"' '"|| cEncabezado||"' '"|| TRIM(pRutaDescarga)||"'";
        
                        SYSTEM(TRIM(cCommand));

                END IF;		
                RETURN cCodRet,TRIM(cArchivoAI);
        END;

END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 18/02/2016',
'MODULO: Camara de Compensacion Electonica Presentada',
'FUNCIONALIDAD: Generacion de Archivo',
'DESCRIPCION: realiza la generacion del archivo de intercambio Codigo 40 a presentar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu2(
pUsuario                CHAR(8), 
pIdFuncion              CHAR(10), 
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    CHAR(25),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10) 
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   CHAR(5);
DEFINE iSqlErr   INTEGER;
DEFINE cCodRetSp CHAR(3);
DEFINE iCodRetSp INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(30);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search_web(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current, '')
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search_web";
		ELIF iCodRetSp = 27 THEN
			LET cCodRet = '00976'; -- USUARIO NO TIENE ID. ASIGNADO
		ELIF iCodRetSp = 26 THEN
			LET cCodRet = '00025'; -- NO EXISTE USUARIO, 			 	EL USUARIO NO EXISTE
		ELIF iCodRetSp = 23 THEN
			LET cCodRet = '00978'; -- SE TIENE QUE REVERSAR PRIMERO ANTES DE INTENTAR EL PAGO NUEVAMENTE	
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00977'; -- NO EXISTE MARCA EN SAC PARAM	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00770'; -- ERROR EN EL PROCESO, 				PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 05/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Consulta Remesas WU',
'DESCRIPCION: Guarda respuesta de transaccion en bdisac:sac_wu_search',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/08/2024',
'DESCRIPCION: SP clon de sp_remesasguardarespuestawu que se encarda de Guarda respuesta de la transaccion en bdisac:sac_wu_search, llamando al SP sp_sac_wu_guardarespuesta_search_web',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_reenviosreptotales(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pTipoSolicitud CHAR(1), 
pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE)
			RETURNING
			CHAR(5) AS codigo_ret,
			INTEGER AS num_registros;
		
	DEFINE iFolio     INTEGER;
	DEFINE iSqlErr    INTEGER;
	DEFINE cCodRet    CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cRetorno01 CHAR(20); --tiposol / numanalista
	DEFINE cRetorno02 CHAR(104); --producto /  nomanalista
	DEFINE cRetorno03 CHAR(25); --numsolic / perfilusuario
	DEFINE cRetorno04 CHAR(20); --numcte / errorcve01
	DEFINE cRetorno05 CHAR(4); --numsuc / errorcve02 
	DEFINE cRetorno06 CHAR(104); --nomcte / errorcve03
	DEFINE cRetorno07 CHAR(10); --fechasol / errorcve04
	DEFINE cRetorno08 CHAR(12); --hora / errorcve05
	DEFINE cRetorno09 CHAR(4); --estatus / errorcve06
	DEFINE cRetorno10 CHAR(4); --reenvio_exit SI o NO / errorcve07
	DEFINE cRetorno11 CHAR(10); --fecha_reenvio / errorcve08
	DEFINE cRetorno12 CHAR(4); --estatus fin / errorcve09
	DEFINE cRetorno13 CHAR(80); --motivo_reenvio/ totalbc
	DEFINE cRetorno14 CHAR(104); --nombre_analista / totalcc
	DEFINE cRetorno15 CHAR(10); -- totalglobal	
	DEFINE vCont	SMALLINT; -- Contador de solicitudes

	LET iFolio = 0;
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cRetorno01 = ''; --tiposol / numanalista
	LET cRetorno02 = ''; --producto /  nomanalista
	LET cRetorno03 = ''; --numsolic / perfilusuario
	LET cRetorno04 = ''; --numcte / errorcve01
	LET cRetorno05 = ''; --numsuc / errorcve02 
	LET cRetorno06 = ''; --nomcte / errorcve03
	LET cRetorno07 = ''; --fechasol / errorcve04
	LET cRetorno08 = ''; --hora / errorcve05
	LET cRetorno09 = ''; --estatus / errorcve06
	LET cRetorno10 = ''; --reenvio_exit SI o NO / errorcve07
	LET cRetorno11 = ''; --fecha_reenvio / errorcve08
	LET cRetorno12 = '' ; --estatus fin / errorcve09
	LET cRetorno13 = ''; --motivo_reenvio/ totalbc
	LET cRetorno14 = ''; --nombre_analista / totalcc
	LET cRetorno15 = ''; -- totalglobal	
	LET vCont	= 0; -- Contador de solicitudes
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_reenviosreptotales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		--LIMPIA TABLA
		DELETE FROM bdicnweb:"informix".sw_mon_buro_reenviosrep WHERE usuario_inserta = pUsuario;
		
		--REALIZA CONSULTA Y LLENA TABLA 
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_reenviosrep(pModo, pTipoSolicitud, pNumSolicitud, pNumCte, pEstatus, pFechaIni, pFechaFin)
			INTO cCodRetSp, cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, 
			cRetorno12, cRetorno13, cRetorno14, cRetorno15
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_mon_buro_reenviosrep";
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00017';
			END IF;
			
			IF(cCodRet = '00000') THEN
				--SET LOCK MODE TO WAIT 3;
				INSERT INTO bdicnweb:"informix".sw_mon_buro_reenviosrep(retorno_01,retorno_02,retorno_03,retorno_04,retorno_05,retorno_06,retorno_07,retorno_08,retorno_09,retorno_10,retorno_11,retorno_12,retorno_13,retorno_14,retorno_15,usuario_inserta,fecha_insert)
				VALUES(cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, cRetorno12, cRetorno13, cRetorno14, cRetorno15, pUsuario, CURRENT);
				
				LET vCont = vCont + 1;
				
				IF vCont = 3500 THEN EXIT FOREACH; END IF;
			END IF;
		END FOREACH;
		
		--REALIZA CONSULTA DE TOTAL DE REGISTROS
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:"informix".sw_mon_buro_reenviosrep
		WHERE usuario_inserta = pUsuario;
		
		IF iNoRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;			
		END IF;
		
		RETURN cCodRet, iNoRegistros; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/11/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE SOLICITUDES EN BC Y CC',
'DESCRIPCION:SPL que ejecuta sp productivo e inserta los datos en tabla auxiliar para obtener los totales del Reporte de Solicitudes en BC y CC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_hojafirmactamec_complementoinfo(pCuenta CHAR(20))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(100) AS cMensaje,
		  CHAR(20)  AS numcliente,
		  CHAR(50)   AS tipofirma;
		  


--****************************************************************************************************
-- Objetivo:Spl que obtiene informaciÃ³n de clientes y tipo se firma
-- Autor: Nadia Ordaz
-- FECHA : 24/07/2024
-- SOLICITO : Ismael Hernandez
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
	DEFINE iSql_Err                     INTEGER;
	DEFINE cCodRet         			    CHAR(5);
	DEFINE cMensaje                     CHAR(50);
	
	DEFINE numcliente         			CHAR(20);
	DEFINE tipofirma                    CHAR(50);
            
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '00000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	
    LET numcliente          = '';
    LET tipofirma           = '';
	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
    END EXCEPTION;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/hojafirmaCtaMEC.out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pCuenta,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
	END IF;

	FOREACH cur for							
		SELECT numcte, tipo_firma
		INTO numcliente, tipofirma
		FROM bdicheq:"informix".sc_firmantes
		WHERE empresa = '001'
			AND cuenta = pCuenta
		ORDER BY secuencia ASC
		
		RETURN cCodRet, cMensaje, numcliente, tipofirma WITH RESUME;
		
	END FOREACH;	
END;

END PROCEDURE;