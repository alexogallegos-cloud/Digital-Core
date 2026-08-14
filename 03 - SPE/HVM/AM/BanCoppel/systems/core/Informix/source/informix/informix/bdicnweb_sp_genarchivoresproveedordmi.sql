CREATE PROCEDURE "informix".sp_genarchivoresproveedordmi(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipoArchivo CHAR(1), pNombreArch CHAR(20), pNumCliente CHAR(20), pFechaInicio CHAR(8), pFechaFin CHAR(8))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(95);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTransaction = 't';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genarchivoresproveedordmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipoArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDA TIPO DE ARCHIVO A PROCESAR
		IF pTipoArchivo = 'N' THEN
			IF pNombreArch = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		ELIF pTipoArchivo = 'R' THEN
			IF pNumCliente = '' OR pFechaInicio = '' OR pFechaFin = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdidomi:'informix'.sp_genera_archivo_proveedor(pTipoArchivo, pNombreArch, LPAD(TRIM(pNumCliente), 20, '0'), pFechaInicio, pFechaFin)
		INTO cCodRetSp;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdidomi:sp_genera_archivo_proveedor';
		ELIF cCodRetSp::INTEGER = 2204 THEN	
			LET cCodRet = '00618';                                                  
		ELIF cCodRetSp::INTEGER = 2235 THEN	
			LET cCodRet = '00644';
		ELIF cCodRetSp::INTEGER = 2300 THEN	
			LET cCodRet = '00667';                                                 
		ELIF cCodRetSp::INTEGER = 2301 THEN	
			LET cCodRet = '00481';                                                  
		ELIF cCodRetSp::INTEGER = 2302 THEN	
			LET cCodRet = '00618';			                                        
		ELIF cCodRetSp::INTEGER = 2303 THEN 
			LET cCodRet = '00616';                                                  
		ELIF cCodRetSp::INTEGER = 2306 THEN	
			LET cCodRet = '00388';                                                 
		ELIF cCodRetSp::INTEGER = 2307 THEN
			LET cCodRet = '00388';                                                 
		ELIF cCodRetSp::INTEGER = 2308 THEN	
			LET cCodRet = '00115';                                                 
		END IF;
		
		RETURN cCodret;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 26/08/2015',
'DESCRIPCION: SPL encargado de la generación del archivo de respuesta o reverso Domi.',
'pTipoArchivo = N se refiera a Respuesta', 
'pTipoArchivo = R se refiera a Reverso',
'FUNCIONALIDAD: Carga de Archivos de Proveedor', 
'MODULO: OPERACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generadorpresentadoreceptordmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pIdOperacion CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS nombre_archivo_generado;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cNombreArchivo CHAR(20);
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cNombreArchivo = '';
	LET iNoRegistros = 0;
	LET bInTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_generadorpresentadoreceptordmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pIdOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;
	
		BEGIN WORK;
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		IF pIdOperacion = 'P' THEN
			FOREACH
				EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_generador_presentador(pNombreArchivo, pUsuario)
				INTO cNombreArchivo, cCodRetSp, cDescCodRetSp
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdidomi:sp_domi_generador_presentador';
				ELIF cCodRetSp::INTEGER = 2100 THEN
					LET cCodRet = '00521';
				ELIF cCodRetSp::INTEGER = 2101 THEN
					LET cCodRet = '00522';
				ELIF cCodRetSp::INTEGER = 2102 THEN
					LET cCodRet = '00523';
				ELIF cCodRetSp::INTEGER = 2103 THEN
					LET cCodRet = '00524';
				ELIF cCodRetSp::INTEGER = 2104 THEN
					LET cCodRet = '00525';
				ELIF cCodRetSp::INTEGER = 2105 THEN
					LET cCodRet = '00526';
				ELIF cCodRetSp::INTEGER = 2106 THEN
					LET cCodRet = '00677';
				ELIF cCodRetSp::INTEGER = 2107 THEN
					LET cCodRet = '00574';
				ELIF cCodRetSp::INTEGER = 2108 THEN
					LET cCodRet = '00678';
				ELIF cCodRetSp::INTEGER = 2109 THEN
					LET cCodRet = '00530';
				ELIF cCodRetSp::INTEGER = 2110 THEN
					LET cCodRet = '00679';
				ELIF cCodRetSp::INTEGER = 2111 THEN
					LET cCodRet = '00680';
				ELIF cCodRetSp::INTEGER = 2112 THEN
					LET cCodRet = '00532';
				ELIF cCodRetSp::INTEGER = 2113 THEN
					LET cCodRet = '00533';
				ELIF cCodRetSp::INTEGER = 2114 THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 2115 THEN
					LET cCodRet = '00534';
				ELIF cCodRetSp::INTEGER = 2116 THEN
					LET cCodRet = '00535';
				ELIF cCodRetSp::INTEGER = 2117 THEN
					LET cCodRet = '00536';
				ELIF cCodRetSp::INTEGER = 2118 THEN
					LET cCodRet = '00537';
				ELIF cCodRetSp::INTEGER = 2119 THEN
					LET cCodRet = '00538';
				ELIF cCodRetSp::INTEGER = 2120 THEN
					LET cCodRet = '00695';
				ELIF cCodRetSp::INTEGER = 2121 THEN
					LET cCodRet = '00481';
				ELIF cCodRetSp::INTEGER = 2122 THEN
					LET cCodRet = '00540';
				ELIF cCodRetSp::INTEGER = 2123 THEN
					LET cCodRet = '00541';
				ELIF cCodRetSp::INTEGER = 2124 THEN
					LET cCodRet = '00616';
				ELIF cCodRetSp::INTEGER = 2125 THEN
					LET cCodRet = '00644';
				ELIF cCodRetSp::INTEGER = 2126 THEN
					LET cCodRet = '00653';
				ELIF cCodRetSp::INTEGER = 2127 THEN
					LET cCodRet = '00696';
				ELIF cCodRetSp::INTEGER = 2128 THEN
					LET cCodRet = '00546';
				ELIF cCodRetSp::INTEGER = 2129 THEN
					LET cCodRet = '00547';
				ELIF cCodRetSp::INTEGER = 2130 THEN
					LET cCodRet = '00548';
					
				ELIF cCodRetSp::INTEGER = 610 THEN
					LET cCodRet = '00489';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00697';
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00458';	
				ELSE 
					LET cCodRet = cCodRetSp;
				END IF;
			
				RETURN cCodRet, cNombreArchivo WITH RESUME;
			END FOREACH;
			
		ELIF pIdOperacion = 'R' THEN
		
			FOREACH
				EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_generador_receptor(pNombreArchivo, pUsuario)
				INTO cNombreArchivo, cCodRetSp, cDescCodRetSp
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdidomi:sp_domi_generador_receptor';
				ELIF cCodRetSp::INTEGER = 2100 THEN
					LET cCodRet = '00521';
				ELIF cCodRetSp::INTEGER = 2101 THEN
					LET cCodRet = '00522';
				ELIF cCodRetSp::INTEGER = 2102 THEN
					LET cCodRet = '00523';
				ELIF cCodRetSp::INTEGER = 2103 THEN
					LET cCodRet = '00524';
				ELIF cCodRetSp::INTEGER = 2104 THEN
					LET cCodRet = '00525';
				ELIF cCodRetSp::INTEGER = 2105 THEN
					LET cCodRet = '00526';
				ELIF cCodRetSp::INTEGER = 2106 THEN
					LET cCodRet = '00677';
				ELIF cCodRetSp::INTEGER = 2107 THEN
					LET cCodRet = '00574';
				ELIF cCodRetSp::INTEGER = 2108 THEN
					LET cCodRet = '00678';
				ELIF cCodRetSp::INTEGER = 2109 THEN
					LET cCodRet = '00530';
				ELIF cCodRetSp::INTEGER = 2110 THEN
					LET cCodRet = '00679';
				ELIF cCodRetSp::INTEGER = 2111 THEN
					LET cCodRet = '00680';
				ELIF cCodRetSp::INTEGER = 2112 THEN
					LET cCodRet = '00532';
				ELIF cCodRetSp::INTEGER = 2113 THEN
					LET cCodRet = '00533';
				ELIF cCodRetSp::INTEGER = 2114 THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 2115 THEN
					LET cCodRet = '00534';
				ELIF cCodRetSp::INTEGER = 2116 THEN
					LET cCodRet = '00535';
				ELIF cCodRetSp::INTEGER = 2117 THEN
					LET cCodRet = '00536';
				ELIF cCodRetSp::INTEGER = 2118 THEN
					LET cCodRet = '00537';
				ELIF cCodRetSp::INTEGER = 2119 THEN
					LET cCodRet = '00538';
				ELIF cCodRetSp::INTEGER = 2120 THEN
					LET cCodRet = '00695';
				ELIF cCodRetSp::INTEGER = 2121 THEN
					LET cCodRet = '00481';
				ELIF cCodRetSp::INTEGER = 2122 THEN
					LET cCodRet = '00540';
				ELIF cCodRetSp::INTEGER = 2123 THEN
					LET cCodRet = '00541';
				ELIF cCodRetSp::INTEGER = 2124 THEN
					LET cCodRet = '00616';
				ELIF cCodRetSp::INTEGER = 2125 THEN
					LET cCodRet = '00644';
				ELIF cCodRetSp::INTEGER = 2126 THEN
					LET cCodRet = '00653';
				ELIF cCodRetSp::INTEGER = 2127 THEN
					LET cCodRet = '00696';
				ELIF cCodRetSp::INTEGER = 2128 THEN
					LET cCodRet = '00546';
				ELIF cCodRetSp::INTEGER = 2129 THEN
					LET cCodRet = '00547';
				ELIF cCodRetSp::INTEGER = 2130 THEN
					LET cCodRet = '00548';
				
				ELIF cCodRetSp::INTEGER = 610 THEN
					LET cCodRet = '00489';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00697';
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00458';
				ELSE 
					LET cCodRet = cCodRetSp;
				END IF;
				
				RETURN cCodRet, cNombreArchivo WITH RESUME;
			END FOREACH;
			
		END IF;
		
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 05/10/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: GeneraciÃ³n Manual de Archivos DomiciliaciÃ³n', 
'DESCRIPCION: SPL encargado de realizar la generaciÃ³n manual de Archivos DomiciliaciÃ³n.',
'Donde pIdOperacion = P corresponde a la generacion de los archivos presentados,',
'pIdOperacion = R corresponde a la generacion de los archivos recibidos,',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporte10dmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNomArchivo CHAR(20), pTipoProceso INTEGER, pFechaInicio CHAR(10), 
	pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,      	
		CHAR(10) AS  fecha_presentacion,	
		CHAR(20) AS  nom_archivo,    	
		MONEY(18, 2) AS  importe,        	
		CHAR(7)   AS  sec,  	
		CHAR(20)  AS  cta_origen,
		CHAR(20)  AS  cta_dest,     	
		CHAR(20)  AS  tipo_cta,      	
		CHAR(20)  AS  banc_dest,    	
		CHAR(20)  AS  status  ,    	
		CHAR(2)   AS  cod_resp,   	
		CHAR(60)  AS  causa_rechazo,   	
		CHAR(2)	 AS  clave_status;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescError     CHAR(130);
	DEFINE cFechaPresentacion  CHAR(10);   
	DEFINE cNomArchivo       CHAR(20);   
	DEFINE mImp2          MONEY(18, 2);
	DEFINE cSec           CHAR(7);    
	DEFINE cCtaOrigen     CHAR(20);   
	DEFINE cCtaDest       CHAR(20);   
	DEFINE cTipoCta        CHAR(20);   
	DEFINE cBancDest      CHAR(20);   
	DEFINE cStatus        CHAR(20);   
	DEFINE cCodResp       CHAR(2);    
	DEFINE cCausaRech     CHAR(60);  
	DEFINE cClaveStatus      CHAR(2);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cDescError     = "";
	LET cFechaPresentacion  = '';
	LET cNomArchivo       = '';
	LET mImp2           = 0.00;
	LET cSec           = '';
	LET cCtaOrigen     = '';
	LET cCtaDest       = '';
	LET cTipoCta        = '';
	LET cBancDest      = '';
	LET cStatus        = '';
	LET cCodResp       = '';
	LET cCausaRech     = '';
	LET cClaveStatus   = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporte10dmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_genrep102(pNomArchivo, pTipoProceso, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cDescError, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus, cCodResp, cCausaRech,cClaveStatus
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_genrep10';
			ELIF cCodRetSp::INTEGER = 2600  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2601  THEN
				LET cCodRet = '00668'; --LA CONSULTA SÓLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O POR TIPO DE PROCESO, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2602  THEN
				LET cCodRet = '00017'; 
			ELIF cCodRetSp::INTEGER = 2603  THEN
				LET cCodRet = '00017';
			ELIF cCodRetSp::INTEGER = 2604  THEN
				LET cCodRet = '00481';
			ELIF cCodRetSp::INTEGER = 2605  THEN
				LET cCodRet = '00671'; --LA CONSULTA SÓLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O FECHAS, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2606  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2607  THEN
				LET cCodRet = '00674'; --TIPO DE PROCESO NO VALIDO PARA LA GENERACIÓN DE REPORTES CÓDIGO 10, VERIFIQUE
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFechaPresentacion, UPPER (cNomArchivo), mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, UPPER (cBancDest),cStatus,cCodResp, cCausaRech,cClaveStatus WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFechaPresentacion, cNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTipoCta, cBancDest, cStatus,cCodResp, cCausaRech,cClaveStatus;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez ',
'FECHA: 09/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DOMICILIACIÓN',
'DESCRIPCION: SPL encargado de genera el reporte de los archivos codigo 10, ya sean presentados o recibidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporte30dmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNomArchivo CHAR(20), pTipoProceso INTEGER, pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(10) AS fecha_presentacion,   
		CHAR(20) AS nombre_archivo,   
		CHAR(40) AS nombre_ordenante,   
		CHAR(60) AS servicio,   
		CHAR(7) AS referencia ,    
		MONEY(18,2) AS importe,
		CHAR(20) AS cta_destino,   
		CHAR(7)	 AS  sec,    
		CHAR(20) AS tipo_cta,   
		CHAR(20) AS banco_dest,   
		CHAR(20) AS status,   
		CHAR(60) AS causa_rech ,   
		CHAR(2)	 AS  cod_respuesta;  		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescError   CHAR(130);
	DEFINE cFechPresentacion  CHAR(10);   
	DEFINE cNomArchivo    CHAR(20);   
	DEFINE cNomOrdenante  CHAR(40);   
	DEFINE cServicio      CHAR(60);   
	DEFINE cReferencia    CHAR(7);    
	DEFINE mImporte       MONEY(18,2);
	DEFINE cCtaDest       CHAR(20);   
	DEFINE cSec           CHAR(7);    
	DEFINE cTipoCta        CHAR(20);   
	DEFINE cBancDest      CHAR(20);   
	DEFINE cStatus        CHAR(20);   
	DEFINE cCausaRech     CHAR(60);   
	DEFINE cCodResp       CHAR(2);    
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cDescError     = "";   
	LET cFechPresentacion  = "";   
	LET cNomArchivo    = "";   
	LET cNomOrdenante  = "";   
	LET cServicio      = "";   
	LET cReferencia    = "";   
	LET mImporte       = 0.00; 
	LET cCtaDest       = "";   
	LET cSec           = "";   
	LET cTipoCta       = "";   
	LET cBancDest      = "";   
	LET cStatus        = "";   
	LET cCausaRech     = "";   
	LET cCodResp       = ""; 
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporte30dmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;
				
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_genrep302(pNomArchivo, pTipoProceso, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cDescError, cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_genrep102';
			ELIF cCodRetSp::INTEGER = 2600  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2601  THEN
				LET cCodRet = '00668'; --LA CONSULTA SÓLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O POR TIPO DE PROCESO, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2602  THEN
				LET cCodRet = '00017'; 
			ELIF cCodRetSp::INTEGER = 2603  THEN
				LET cCodRet = '00017';
			ELIF cCodRetSp::INTEGER = 2604  THEN
				LET cCodRet = '00481';
			ELIF cCodRetSp::INTEGER = 2605  THEN
				LET cCodRet = '00671'; --LA CONSULTA SÓLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O FECHAS, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2606  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2608  THEN
				LET cCodRet = '00673'; --TIPO DE PROCESO NO VALIDO PARA LA GENERACIÓN DE REPORTES CÓDIGO 30, VERIFIQUE
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
			END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cFechPresentacion, cNomArchivo, cNomOrdenante, cServicio, cReferencia, mImporte, cCtaDest, cSec, cTipoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez ',
'FECHA: 09/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DOMICILIACIÓN',
'DESCRIPCION: SPL encargado de genera el reporte de los archivos codigo 30, ya sean presentados o recibidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporte34dmi(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pNomArchivo CHAR(20), pTipoProceso INTEGER, pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,              
		CHAR(10) AS fecha_presentacion,           
		CHAR(20) AS nom_archivo,                  
		CHAR(40) AS nom_ordenante,                
		CHAR(60) AS servicio,                     
		CHAR(7) AS ref_numerica,                  
		MONEY(15,2) AS importe,                   
		CHAR(20) AS cta_destino,                  
		CHAR(7) AS sec,               				
		CHAR(20) AS tipo_cuenta,			      
		CHAR(20) AS banco_destino,               		
		CHAR(10) AS fecha_origen,         			
		CHAR(20) AS estatus,                 		
		CHAR(4) AS sucursal;            			
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(65);
	DEFINE cFechaPresentacion CHAR(10);
	DEFINE cNomArchivo CHAR(20);
	DEFINE cNomOrdenante CHAR(40);
	DEFINE cServicio CHAR(60);
	DEFINE cRefNumerica CHAR(7);
	DEFINE mImporte MONEY(15,2);
	DEFINE cCtaDestino CHAR(20);
	DEFINE cSec CHAR(7);
	DEFINE cTipoCuenta CHAR(20);
	DEFINE cBancoDestino CHAR(20);
	DEFINE cFechaOrigen CHAR(10);
	DEFINE cEstatus CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cFechaPresentacion = '';
	LET cNomArchivo = '';
	LET cNomOrdenante = '';
	LET cServicio = '';
	LET cRefNumerica = '';
	LET mImporte = 0.00;
	LET cCtaDestino = '';
	LET cSec = '';
	LET cTipoCuenta = '';
	LET cBancoDestino = '';
	LET cFechaOrigen = '';
	LET cEstatus = '';
	LET cSucursal = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporte34dmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			--EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_genrep342(pNomArchivo, pTipoProceso, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_genrep34(pNomArchivo, pTipoProceso, pFechaInicio, pFechaFin)
			INTO cCodRetSp,cDescCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_genrep34';
			ELIF cCodRetSp::INTEGER = 2600  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2601  THEN
				LET cCodRet = '00668'; --LA CONSULTA SÃLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O POR TIPO DE PROCESO, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2602  THEN
				LET cCodRet = '00017'; 
			ELIF cCodRetSp::INTEGER = 2603  THEN
				LET cCodRet = '00017';
			ELIF cCodRetSp::INTEGER = 2604  THEN
				LET cCodRet = '00481';
			ELIF cCodRetSp::INTEGER = 2605  THEN
				LET cCodRet = '00671'; --LA CONSULTA SÃLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O FECHAS, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2606  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2609  THEN
				LET cCodRet = '00672'; --TIPO DE PROCESO NO VALIDO PARA LA GENERACIÃN DE REPORTES CÃDIGO 34, VERIFIQUE
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cFechaPresentacion,UPPER(cNomArchivo),UPPER(cNomOrdenante),UPPER(cServicio),cRefNumerica,mImporte,
			cCtaDestino,cSec,UPPER(cTipoCuenta),UPPER(cBancoDestino),cFechaOrigen,UPPER(cEstatus),cSucursal WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cFechaPresentacion,cNomArchivo,cNomOrdenante,cServicio,cRefNumerica,mImporte,
			cCtaDestino,cSec,cTipoCuenta,cBancoDestino,cFechaOrigen,cEstatus,cSucursal;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/09/2015',
'DESCRIPCION: SPL encargado de genera el reporte de los archivos codigo 34, ya sean presentados o recibidos.',
'FUNCIONALIDAD: Reportes DomiciliaciÃ³n', 
'MODULO: OPERACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportecargosdmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), 
	pNumCliente CHAR(20), pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	
		RETURNING CHAR(5) AS codret,                            
			DATE AS dFechaCargo,                             
			CHAR(20) AS cNoCuenta,                            
			MONEY(16,2) AS mImporte,                        
			CHAR(40) AS cReferencia,                               
			CHAR(41) AS cBancoRecPres,                           
			CHAR(20) AS cEstatus,                               
			CHAR(20) AS cDescripcionEstatus,                           
			CHAR(20) AS cCausaRechazo,                      
			CHAR(60) AS cDescripcionRechazo,                
			DATE AS dFechaInicio,                     
			DATE AS dFechaFin;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaCargo DATE;                           
	DEFINE cNoCuenta CHAR(20);                            
	DEFINE mImporte MONEY(16,2);                         
	DEFINE cReferencia CHAR(40);                                
	DEFINE cBancoRecPres CHAR(41);                           
	DEFINE cEstatus CHAR(20);                               
	DEFINE cDescripcionEstatus CHAR(20);                           
	DEFINE cCausaRechazo CHAR(20);                      
	DEFINE cDescripcionRechazo CHAR(60);                 
	DEFINE dFechaInicio DATE;                      
	DEFINE dFechaFin DATE; 
	DEFINE iExiste INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET dFechaCargo = '';                           
	LET cNoCuenta = '';                            
	LET mImporte = 0.00;                        
	LET cReferencia = '';                                
	LET cBancoRecPres = '';                           
	LET cEstatus = '';                              
	LET cDescripcionEstatus = '';                           
	LET cCausaRechazo = '';                     
	LET cDescripcionRechazo = '';                 
	LET dFechaInicio = '';                      
	LET dFechaFin = ''; 
	LET iExiste = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportecargosdmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta = '' OR pNumCliente = '' OR pFechaInicio  = '' OR pFechaFin  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;  
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;  
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;  
		END IF;
		
		SELECT COUNT(*) 
        INTO iExiste
        FROM bdicnweb:'informix'.sw_dm_reportecargoscte
        WHERE num_cliente = pNumCliente;
           
		IF iExiste > 0 THEN
			DELETE FROM bdicnweb:'informix'.sw_dm_reportecargoscte
			WHERE num_cliente = pNumCliente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		-- Se consulta el sp, para el llenado de la tabla		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_reportecargoscliente(pTipoConsulta, pNumCliente, pFechaInicio, pFechaFin)
			INTO cCodRetSp,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin
			
			INSERT INTO bdicnweb:'informix'.sw_dm_reportecargoscte(num_cliente,fecha_cargo,num_cuenta,
			importe,referencia,banco_rec_pres,estatus,descripcion_estatus,causa_rechazo,descripcion_rechazo,fecha_inicio,fecha_fin)
			VALUES(pNumCliente,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,cCausaRechazo,
			cDescripcionRechazo,dFechaInicio,dFechaFin);
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_reportecargoscliente';
			ELIF cCodRetSp::INTEGER = 2500  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2501  THEN
				LET cCodRet = '00525'; 
			END IF;
		END FOREACH;
		
		-- Consultamos la tabla, para obtener todos los registros del spl
		FOREACH
			SELECT SKIP pregistros FIRST precuperacion fecha_cargo,num_cuenta,importe,referencia,banco_rec_pres,estatus,descripcion_estatus,causa_rechazo,descripcion_rechazo,fecha_inicio,fecha_fin 
			INTO dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin 
			FROM bdicnweb:'informix'.sw_dm_reportecargoscte
			WHERE num_cliente = pNumCliente
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00698'; 
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;  
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin;  
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/10/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta de Cargos DomiciliaciÃ³n', 
'DESCRIPCION: SPL encargado de consultar los cargos efectuados al cliente por Domiciliacion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportecargosdmi_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), 
	pNumCliente CHAR(20), pFechaInicio CHAR(10), pFechaFin CHAR(10))
	
		RETURNING CHAR(5) AS codret,                            
			INTEGER AS num_registros;               

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaCargo DATE;                           
	DEFINE cNoCuenta CHAR(20);                            
	DEFINE mImporte MONEY(16,2);                         
	DEFINE cReferencia CHAR(40);                                
	DEFINE cBancoRecPres CHAR(41);                           
	DEFINE cEstatus CHAR(20);                               
	DEFINE cDescripcionEstatus CHAR(20);                           
	DEFINE cCausaRechazo CHAR(20);                      
	DEFINE cDescripcionRechazo CHAR(60);                 
	DEFINE dFechaInicio DATE;                      
	DEFINE dFechaFin DATE; 
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET dFechaCargo = '';                           
	LET cNoCuenta = '';                            
	LET mImporte = 0.00;                        
	LET cReferencia = '';                                
	LET cBancoRecPres = '';                           
	LET cEstatus = '';                              
	LET cDescripcionEstatus = '';                           
	LET cCausaRechazo = '';                     
	LET cDescripcionRechazo = '';                 
	LET dFechaInicio = '';                      
	LET dFechaFin = ''; 
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportecargosdmi_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta = '' OR pNumCliente = '' OR pFechaInicio  = '' OR pFechaFin  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros; 
		END IF;
		
		SELECT COUNT(*) 
        INTO iExiste
        FROM bdicnweb:'informix'.sw_dm_reportecargoscte
        WHERE num_cliente = pNumCliente;
        
		IF iExiste > 0 THEN
			DELETE FROM bdicnweb:'informix'.sw_dm_reportecargoscte
			WHERE num_cliente = pNumCliente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		-- Se consulta el sp, para el llenado de la tabla		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_reportecargoscliente(pTipoConsulta, pNumCliente, pFechaInicio, pFechaFin)
			INTO cCodRetSp,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,
			cCausaRechazo,cDescripcionRechazo,dFechaInicio,dFechaFin
			
			INSERT INTO bdicnweb:'informix'.sw_dm_reportecargoscte(num_cliente,fecha_cargo,num_cuenta,
			importe,referencia,banco_rec_pres,estatus,descripcion_estatus,causa_rechazo,descripcion_rechazo,fecha_inicio,fecha_fin)
			VALUES(pNumCliente,dFechaCargo,cNoCuenta,mImporte,cReferencia,cBancoRecPres,cEstatus,cDescripcionEstatus,cCausaRechazo,
			cDescripcionRechazo,dFechaInicio,dFechaFin);
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_reportecargoscliente';
			ELIF cCodRetSp::INTEGER = 2500  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2501  THEN
				LET cCodRet = '00525'; 
			END IF;
		END FOREACH;
		
		-- Consultamos la tabla, para obtener el nÃºmero total de registros del spl
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:'informix'.sw_dm_reportecargoscte
		WHERE num_cliente = pNumCliente;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00698';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/10/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta de Cargos DomiciliaciÃ³n', 
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los cargos efectuados al cliente por Domiciliacion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteconciliacontabledmi(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pNomArchivo CHAR(20), pTipoProceso INTEGER, pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,                            
		DATE AS fecha_presentacion,                             
		INTEGER AS reg_archOriginal,                            
		MONEY(18,2) AS sum_archOriginal,                        
		INTEGER AS reg_archResp1,                               
		MONEY(18,2) AS sum_archResp1,                           
		INTEGER AS reg_archResp2,                               
		MONEY(18,2) AS sum_archResp2,                           
		CHAR(14) AS cuenta_contableCargo,                      
		MONEY(18,2) AS sum_cuentaContableCargo,                
		CHAR(14) AS cuenta_contableDeudora,                     
		MONEY(18,2) AS sum_cuentaContableDeudora,               
		CHAR(14) AS cuenta_contableAbono,                      
		MONEY(18,2) AS sum_cuentaContableAbono;                
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaPresentacion  DATE;
	DEFINE iRegArchOriginal INTEGER;
	DEFINE mSumArchOriginal MONEY(18,2);
	DEFINE iRegArchResp1 INTEGER;
	DEFINE mSumArchResp1 MONEY(18,2);
	DEFINE iRegArchResp2 INTEGER;
	DEFINE mSumArchResp2 MONEY(18,2);
	DEFINE cCuentaContableCargo CHAR(14);
	DEFINE mSumCuentaContableCargo MONEY(18,2);
	DEFINE cCuentaContableDeudora CHAR(14);
	DEFINE mSumCuentaContableDeudora MONEY(18,2);
	DEFINE cCuentaContableAbono CHAR(14);
	DEFINE mSumCuentaContableAbono MONEY(18,2);
	DEFINE iRecuperacion INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET dFechaPresentacion = '';
	LET iRegArchOriginal = 0;
	LET mSumArchOriginal = 0.00;
	LET iRegArchResp1 = 0;
	LET mSumArchResp1 = 0.00;
	LET iRegArchResp2 = 0;
	LET mSumArchResp2 = 0.00;
	LET cCuentaContableCargo = '';
	LET mSumCuentaContableCargo = 0.00;
	LET cCuentaContableDeudora = '';
	LET mSumCuentaContableDeudora = 0.00;
	LET cCuentaContableAbono = '';
	LET mSumCuentaContableAbono = 0.00;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteconciliacontabledmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_conciliacontable2(pNomArchivo, pTipoProceso, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
				cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_conciliacontable';
			ELIF cCodRetSp::INTEGER = 2600  THEN
				LET cCodRet = '00481';
			ELIF cCodRetSp::INTEGER = 2612  THEN
				LET cCodRet = '00668'; --LA CONSULTA SÓLO PUEDE REALIZARSE POR NOMBRE DE ARCHIVO O POR TIPO DE PROCESO, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 2613  THEN
				LET cCodRet = '00669'; --LA PARAMETRIZACIÓN DE CUENTAS CONTABLE ES INCORRECTA
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFechaPresentacion,iRegArchOriginal,mSumArchOriginal,iRegArchResp1,mSumArchResp1,iRegArchResp2,mSumArchResp2,
			cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableDeudora,mSumCuentaContableDeudora,cCuentaContableAbono,mSumCuentaContableAbono;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/09/2015',
'DESCRIPCION: SPL encargado de consultar el detalle de la sumatoria por dia, según la cuenta contable.',
'FUNCIONALIDAD: Reportes Domiciliación', 
'MODULO: OPERACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportedatoserviciosdmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pServicio CHAR(18),pSucursal CHAR(4),pFechaInicio CHAR(10),pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(10) AS fecha_aplica	,
		CHAR(20) AS num_cte,
		CHAR(80) AS nom_cte,
		CHAR(20) AS cuenta,
		CHAR(60) AS servicio,
		CHAR(4)  AS sucursal,
		CHAR(20)	As estatus	,
		MONEY(18,2) AS monto_maximo,
		SMALLINT AS sNumCve;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cErrorInfo	CHAR(80);	  	
	DEFINE cFechaAplica CHAR(10);
	DEFINE cNumCte	CHAR(20);  	
	DEFINE cNomCte	CHAR(80);	
	DEFINE cCuenta	CHAR(20);  	
	DEFINE cServicio CHAR(60);
	DEFINE cSucursal	CHAR(4);
	DEFINE cEstatus		CHAR(20);  	
	DEFINE mMontoMaximo	MONEY(18,2);
	DEFINE sNumCve 	SMALLINT ;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cErrorInfo		= '';	  	
	LET cFechaAplica	= '';
	LET cNumCte			= '';  	
	LET cNomCte			= '';
	LET cCuenta			= '';  	
	LET cServicio		= '';
	LET cSucursal		= '';
	LET cEstatus		= '';  	
	LET mMontoMaximo	= 0.00;
	LET sNumCve 	= 0 ;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportedatoserviciosdmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pServicio = '' OR pSucursal	= '' OR pRegistros IS NULL OR pRecuperacion IS 
		NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END IF;
			
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_genrepservicios2(pServicio,pSucursal,pFechaInicio,pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cErrorInfo, cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_genrepservicios';
			ELIF iCodRetSp = 02610 THEN
				LET cCodRet = '00091';
			ELIF iCodRetSp = 02611 THEN
				LET cCodRet = '00003';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cFechaAplica,cNumCte,UPPER (cNomCte),cCuenta,UPPER (cServicio),UPPER (cSucursal),UPPER (cEstatus),mMontoMaximo,sNumCve WITH RESUME;
		END FOREACH; 
		IF iRecuperacion = 0 AND pRegistros = 0 THEN 
				LET cCodRet ='00017';
				RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet ='1001';
				RETURN cCodRet,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
			END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 07/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:  REPORTES DOMICILIACIÓN',
'DESCRIPCION: SPL que regresa los datos para el reporte de Servicios Domiciliarios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteserviciosdmi(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR (18)	AS	rfc,    
		CHAR (60)	As  razon_social,   
		CHAR (20)	As  nombrecorto,       
		CHAR (1) 	As  convenio,			   
		CHAR (2)	As  cvecanal,		     
		CHAR (1)	AS  presentador,         
		CHAR (20) 	AS  numcte,    	
		CHAR (20)	AS  numreintentos,	   
		CHAR (20)	AS  comision,
		CHAR (20)	AS  comisiondev,		 
		CHAR (20)	AS  cuentacargocomision,  
		CHAR (1)	AS  layoutespecial, 
		CHAR (4)	AS  codgrupoact,  
		CHAR (4)	As  codgrupodes,
		CHAR (4) 	AS codgruporeact;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE 	cRfc          CHAR (18);
	DEFINE 	cRazonSocial  CHAR (60); 
	DEFINE 	cNombreCorto  CHAR (20); 
	DEFINE 	cConvenio 	  CHAR (1) ;   
	DEFINE 	cCveCanal	  CHAR (2);
	DEFINE 	cPresentador  CHAR (1);
	DEFINE 	cNumCte 	  CHAR (20); 
	DEFINE 	cNumReintentos CHAR (20); 
	DEFINE 	cComision  	  CHAR (20); 
	DEFINE 	cComisionDev  CHAR (20); 
	DEFINE 	cCuentaCargocomision	CHAR (20);  
	DEFINE 	cLayoutEspecial  CHAR (1);
	DEFINE 	cCodGrupoAct	  CHAR (4);
	DEFINE 	cCodGrupoDes 	CHAR (4);
	DEFINE 	cCodGrupoReact	CHAR (4) ;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET	cRfc       = '';
	LET	cRazonSocial = ''; 
	LET	cNombreCorto = ''; 
	LET	cConvenio = '';   
	LET	cCveCanal= '';
	LET	cPresentador= '';
	LET	cNumCte = ''; 
	LET	cNumReintentos = ''; 
	LET	cComision  = ''; 
	LET	cComisionDev = ''; 
	LET	cCuentaCargocomision = '';  
	LET	cLayoutEspecial = '';
	LET	cCodGrupoAct = '';
	LET	cCodGrupoDes = '';
	LET	cCodGrupoReact = ''; 
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,cCodGrupoReact;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteserviciosdmi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,cCodGrupoReact;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,cCodGrupoReact;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,cCodGrupoReact;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_consultaservicios2(pRegistros, pRecuperacion)
			INTO cCodRetSp, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, 
			cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,
			cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,
			cCodGrupoReact
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidomi:sp_domi_consultaservicios2 ';
			END IF;
			
			IF iCodRetSp = 1 AND pRegistros = 0 THEN 
				LET cCodRet ='00017';
				RETURN cCodRet, cRfc, cRazonSocial,
				cNombreCorto, cConvenio, cCveCanal, 
				cPresentador, cNumCte, cNumReintentos,
				cComision, cComisionDev,
				cCuentaCargocomision, cLayoutEspecial,
				cCodGrupoAct, cCodGrupoDes,
				cCodGrupoReact;
			ELIF iCodRetSp = 1 AND pRegistros > 0 THEN
					LET cCodRet ='1001';
					RETURN cCodRet, cRfc, cRazonSocial,cNombreCorto, cConvenio, cCveCanal, cPresentador, cNumCte, cNumReintentos,cComision, cComisionDev,cCuentaCargocomision, cLayoutEspecial,cCodGrupoAct, cCodGrupoDes,cCodGrupoReact;
			END IF;
			
			RETURN cCodRet, UPPER (cRfc), UPPER (cRazonSocial), UPPER (cNombreCorto), UPPER (cConvenio), cCveCanal, cPresentador, cNumCte, UPPER (cNumReintentos),cComision, cComisionDev,cCuentaCargocomision, UPPER (cLayoutEspecial),cCodGrupoAct, cCodGrupoDes,cCodGrupoReact WITH RESUME; 
		END FOREACH; 
	END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 07/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:  REPORTES DOMICILIACIÓN',
'DESCRIPCION: SPL para obtener los servicios que se pueden domiciliar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtenernombresarchprocesardomi(pUsuario CHAR(8), pIdFuncion CHAR(10))	
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS nombre_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreArchivo    CHAR(20);
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTransaccion BOOLEAN;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombreArchivo = '';
	LET iNoRegistros = 0;
	LET bInTransaccion = 'f';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodret, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenernombresarchprocesardomi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodret,cNombreArchivo;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodret, cNombreArchivo;
		END IF;
		
		BEGIN WORK;
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_obtenernombresarchivosprocesar()
			INTO cCodRetSp, cNombreArchivo			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdidomi:sp_obtenernombresarchprocesardomi';
			ELIF iCodRetSp = '90001' THEN
				LET cCodRet = '00494'; -- NO EXISTEN ARCHIVOS POR PROCESAR
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodret, UPPER(cNombreArchivo) WITH RESUME;
		END FOREACH;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00494';
			RETURN cCodret, cNombreArchivo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 21/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA MANUAL DE ARCHIVOS',
'DESCRIPCION:SPL que realiza la consulta de archivos para carga domiciliaciÃ³n',
'BD: bdidomi';

CREATE PROCEDURE "informix".sp_presentadordomi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pMac CHAR(18), pIp VARCHAR(16))
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS nombre_archivo_generado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreArchivo CHAR(20);
	DEFINE cMensajeRespuesta CHAR(100);
	DEFINE bInTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreArchivo = '';
	LET cMensajeRespuesta = '';
	LET bInTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_presentadordomi.out';
		--TRACE ON;
		
		--Se limpia tabla por usuario
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '3', '', '', '', pMac, pIp)INTO cCodRetSp;
		
		---Se inserta proceso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '1', '', '', '', pMac, pIp)INTO cCodRetSp;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			
			--Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			---Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		BEGIN WORK;
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_presentador(pNombreArchivo, pUsuario)
			INTO cNombreArchivo, cCodRetSp, cMensajeRespuesta
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "bdidomi:'informix'.sp_domi_presentador";
			ELIF iCodRetSp = 1401 THEN 
				LET cCodRet = '00521';
			ELIF iCodRetSp = 1402 THEN 
				LET cCodRet = '00522';
			ELIF iCodRetSp = 1403 THEN 
				LET cCodRet = '00675';
			ELIF iCodRetSp = 1404 THEN 
				LET cCodRet = '00676';
			ELIF iCodRetSp = 1405 THEN 
				LET cCodRet = '00084';
			ELIF iCodRetSp = 10106 THEN 
				LET cCodRet = '00526';
			ELIF iCodRetSp = 1407 THEN 
				LET cCodRet = '00677';
			ELIF iCodRetSp = 1408 THEN 
				LET cCodRet = '00574';
			ELIF iCodRetSp = 1409 THEN 
				LET cCodRet = '00678';
			ELIF iCodRetSp = 1410 THEN 
				LET cCodRet = '00530';
			ELIF iCodRetSp = 1411 THEN 
				LET cCodRet = '00679';
			ELIF iCodRetSp = 1412 THEN 
				LET cCodRet = '00680';
			ELIF iCodRetSp = 1413 THEN 
				LET cCodRet = '00532';
			ELIF iCodRetSp = 1414 THEN 
				LET cCodRet = '00533';
			ELIF iCodRetSp = 1415 THEN 
				LET cCodRet = '00003';
			ELIF iCodRetSp = 1416 THEN 
				LET cCodRet = '00534';
			ELIF iCodRetSp = 1417 THEN 
				LET cCodRet = '00535';
			ELIF iCodRetSp = 1418 THEN 
				LET cCodRet = '00594';
			ELIF iCodRetSp = 1419 THEN 
				LET cCodRet = '00492';
			ELIF iCodRetSp = 1420 THEN 
				LET cCodRet = '00538';
			ELIF iCodRetSp = 1421 THEN 
				LET cCodRet = '00549';
			ELIF iCodRetSp = 1422 THEN 
				LET cCodRet = '00550';
			ELIF iCodRetSp = 1423 THEN 
				LET cCodRet = '00551';
			ELIF iCodRetSp = 1424 OR iCodRetSp = 1430 THEN 
				LET cCodRet = '00552';
			ELIF iCodRetSp = 1425 THEN 
				LET cCodRet = '00540';
		    ELIF iCodRetSp = 1426 THEN 
				LET cCodRet = '00553';
			END IF;
			
			IF cCodRet::INT > 0 THEN
				IF bInTransaccion THEN
					BEGIN WORK;
				END IF;
				
				---Actualiza proceso erróneo
				EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
				
				RETURN cCodRet, cNombreArchivo;
			END IF;
			
			RETURN cCodRet, cNombreArchivo WITH RESUME;
			
		END FOREACH;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		---Actualiza proceso exitoso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'T', '', '', pMac, pIp)INTO cCodRetSp;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 22/09/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Carga manual de archivos',
'DESCRIPCION: Proceso de carga de archivos presentados de las domiciliaciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_receptordomi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pMac CHAR(18), pIp VARCHAR(16))
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS nombre_archivo_generado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreArchivo CHAR(20);
	DEFINE cMensajeRespuesta CHAR(100);
	DEFINE bInTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreArchivo = '';
	LET cMensajeRespuesta = '';
	LET bInTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			--Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_receptordomi.out';
		--TRACE ON;
				
		--Se limpia tabla por usuario
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '3', '', '', '', pMac, pIp)INTO cCodRetSp;
		
		---Se inserta proceso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '1', '', '', '', pMac, pIp)INTO cCodRetSp;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN		
			LET cCodRet = '00003';
			
			--Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			---Actualiza proceso erróneo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
			
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		BEGIN WORK;
		
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdidomi:'informix'.sp_domi_receptor(pNombreArchivo, pUsuario)
			INTO cNombreArchivo, cCodRetSp, cMensajeRespuesta
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "bdidomi:'informix'.sp_domi_receptor";
			ELIF iCodRetSp = 101 THEN 
				LET cCodRet = '00521';
			ELIF iCodRetSp = 102 THEN 
				LET cCodRet = '00522';
			ELIF iCodRetSp = 103 THEN 
				LET cCodRet = '00675';
			ELIF iCodRetSp = 104 THEN 
				LET cCodRet = '00676';
			ELIF iCodRetSp = 105 THEN 
				LET cCodRet = '00084';
			ELIF iCodRetSp = 106 THEN 
				LET cCodRet = '00526';
			ELIF iCodRetSp = 107 THEN 
				LET cCodRet = '00677';
			ELIF iCodRetSp = 108 THEN 
				LET cCodRet = '00574';
			ELIF iCodRetSp = 109 THEN 
				LET cCodRet = '00678';
			ELIF iCodRetSp = 110 THEN 
				LET cCodRet = '00530';
			ELIF iCodRetSp = 111 THEN 
				LET cCodRet = '00679';
			ELIF iCodRetSp = 112 THEN 
				LET cCodRet = '00680';
			ELIF iCodRetSp = 113 THEN 
				LET cCodRet = '00681';
			ELIF iCodRetSp = 114 THEN 
				LET cCodRet = '00533';
			ELIF iCodRetSp = 115 THEN 
				LET cCodRet = '00003';
			ELIF iCodRetSp = 116 THEN 
				LET cCodRet = '00534';
			ELIF iCodRetSp = 117 THEN 
				LET cCodRet = '00535';
			ELIF iCodRetSp = 118 THEN 
				LET cCodRet = '00594';
			ELIF iCodRetSp = 119 THEN 
				LET cCodRet = '00492';
			ELIF iCodRetSp = 120 THEN 
				LET cCodRet = '00538';
			ELIF iCodRetSp = 122 THEN 
				LET cCodRet = '00550';
			ELIF iCodRetSp = 123 THEN 
				LET cCodRet = '00551';
			ELIF iCodRetSp = 124 THEN 
				LET cCodRet = '00682';
			ELIF iCodRetSp = 125 THEN 
				LET cCodRet = '00555';
			ELIF iCodRetSp = 126 THEN 
				LET cCodRet = '00683';
			ELIF iCodRetSp = 127 THEN 
				LET cCodRet = '00684';
			ELIF iCodRetSp = 128 THEN 
				LET cCodRet = '00685';
			ELIF iCodRetSp = 129 THEN 
				LET cCodRet = '00686';
			ELIF iCodRetSp = 130 THEN 
				LET cCodRet = '00540';
			ELIF iCodRetSp = 131 THEN 
				LET cCodRet = '00553';
			ELIF iCodRetSp = 132 THEN 
				LET cCodRet = '00072';
			ELIF iCodRetSp = 603 THEN 
				LET cCodRet = '00388';
			ELIF iCodRetSp = 400 THEN 
				LET cCodRet = '00440';
			ELIF iCodRetSp = 401 THEN 
				LET cCodRet = '00553';
			ELIF iCodRetSp = 402 THEN 
				LET cCodRet = '00700';
			ELIF iCodRetSp = 403 THEN 
				LET cCodRet = '00521';
			ELIF iCodRetSp = 404 THEN 
				LET cCodRet = '00702';
			ELIF iCodRetSp = 406 THEN 
				LET cCodRet = '00656';
			ELIF iCodRetSp = 407 THEN 
				LET cCodRet = '00658';
			ELIF iCodRetSp = 408 THEN 
				LET cCodRet = '00663';
			ELIF iCodRetSp = 409 THEN 
				LET cCodRet = '00655';
			ELIF iCodRetSp = 410 THEN 
				LET cCodRet = '00657';
			ELIF iCodRetSp = 411 THEN 
				LET cCodRet = '00659';
			ELIF iCodRetSp = 610 THEN 
				LET cCodRet = '00489';
			END IF;
					
			IF cCodRet::INT > 0 THEN
				IF bInTransaccion THEN
					BEGIN WORK;
				END IF;
				
				---Actualiza proceso erróneo
				EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'E', cCodRet, '', pMac, pIp)INTO cCodRetSp;
				
				RETURN cCodRet, cNombreArchivo;
			END IF;
			
			RETURN cCodRet, cNombreArchivo WITH RESUME;
					
		END FOREACH;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		---Actualiza proceso exitoso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizamonitorprocesos(pUsuario, pIdFuncion, '2', 'T', '', '', pMac, pIp)INTO cCodRetSp;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 21/09/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Carga manual de archivos',
'DESCRIPCION: Genera la recepción de las domiciliaciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conshistcambiosautorizadosctapm(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(2),
		pNumCliente CHAR(20), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,
			CHAR(10) AS fecha_modificacion,
			CHAR(20) AS num_cuenta,
			CHAR(22) AS tipo_firma,
			CHAR(2) AS num_firmas,
			CHAR(120) AS combinacion,
			CHAR(10) AS us_modificacion;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE dFechaMod CHAR(10);
		DEFINE cNumCuenta CHAR(20);
		DEFINE cTipoFirma CHAR(22);
		DEFINE cNumFirmas CHAR(2);
		DEFINE cCombinacion CHAR(120);
		DEFINE cUsMod CHAR(10);
		DEFINE cIdRegFirmas CHAR(2);
		DEFINE cDescRegFirmas CHAR(20);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET dFechaMod = '';
		LET cNumCuenta = '';
		LET cTipoFirma = '';
		LET cNumFirmas = '';
		LET cCombinacion = '';
		LET cUsMod = '';
		LET cIdRegFirmas = '';
		LET cDescRegFirmas = '';
		LET iRecuperacion = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_conshistcambiosautorizadosctapm.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNumCliente = '' OR 
			pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
			END IF;
			
			IF pIdConsulta = 'AC' THEN
				FOREACH 
				
					SELECT SKIP pRegistros FIRST pRecuperacion
						{+ INDEX(bdicnweb:sw_sc_firmantes c92357113. 220_922)}
						NVL(TO_CHAR(a.fecha_modificacion,'%d/%m/%Y'),''),NVL(a.us_modificacion,''),NVL(a.cuenta,''),
						NVL(a.secuencia,''),NVL(a.reg_firma,''),NVL(a.combinacion,''),NVL(b.descripcion,'')
					INTO dFechaMod, cUsMod, cNumCuenta, cNumFirmas, cIdRegFirmas, cCombinacion, cDescRegFirmas
					FROM bdicnweb:"informix".sw_sc_firmantes AS a LEFT JOIN bdicnweb:"informix".sw_sq_catregimen AS b 
					ON a.consecutivo = b.consecutivo 
					WHERE --a.cuenta = TRIM(cNumCuenta)
					--AND 
					a.fecha_modificacion BETWEEN pFechaInicio AND pFechaFin
					
					LET cTipoFirma = cIdRegFirmas ||' '|| cDescRegFirmas;
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, dFechaMod, cNumCuenta, UPPER(cTipoFirma), cNumFirmas, UPPER(cCombinacion), cUsMod WITH RESUME;
					
				END FOREACH;	
			END IF;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, dFechaMod, cNumCuenta, cTipoFirma, cNumFirmas, cCombinacion, cUsMod;
			END IF;	
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/10/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: CONSULTA DE HISTORIAL DE CAMBIOS PM', 
'DESCRIPCION: SPL que consulta el detalle del historial de los cambios autorizados de las cuentas que se hacen en Persona Moral.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardacambiosautorizadoscuentapm(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCuenta CHAR(20))
		
		RETURNING CHAR(5) AS codret;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cSecuencia SMALLINT;
		DEFINE cNumFirmas CHAR(2);
		DEFINE cCombFirmas CHAR(120);
		DEFINE cTipoFirma CHAR(20);
		
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cSecuencia = 0;
		LET cNumFirmas = '';
		LET cCombFirmas = '';
		LET cTipoFirma = '';
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_guardacambiosautorizadoscuentapm.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNumCuenta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
		
			SET ISOLATION TO DIRTY READ;
		
			--Obtengo la maxima secuencia de la firmas registradas.
			SELECT MAX(secuencia) INTO cSecuencia
			FROM bdicheq:"informix".sc_firmantes WHERE cuenta = pNumCuenta;
			
			IF cSecuencia IS NULL OR cSecuencia = '' THEN
			   LET cCodRet = '00009';
			   RETURN cCodRet;
			END IF;
			
			--Se obtiene la combinacion de firmas en base a la secuencia y la cuenta parametrizada.
			SELECT LIMIT 1 TRIM(reg_firma), TRIM(combinacion) 
			INTO cNumFirmas, cCombFirmas
			FROM bdicheq:"informix".sc_firmantes WHERE secuencia = cSecuencia AND cuenta = pNumCuenta;
			
			INSERT INTO bdicnweb:"informix".sw_sc_firmantes(fecha_modificacion,us_modificacion,cuenta,secuencia,reg_firma,combinacion)			
			VALUES(CURRENT, pUsuario, pNumCuenta, cSecuencia, cNumFirmas, cCombFirmas);
			
			--Se obtiene el tipo de firma de la cuenta.
			SELECT {+ INDEX(bdicntchq:sq_catregimen "informix".idx01sq_catregimen)} LIMIT 1 TRIM(descripcion)  INTO cTipoFirma
			FROM bdicntchq:"informix".sq_catregimen WHERE cve_regimen = cNumFirmas;
			
			INSERT INTO bdicnweb:"informix".sw_sq_catregimen(fecha_modificacion,us_modificacion,descripcion)			
			VALUES(CURRENT, pUsuario, cTipoFirma);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00236';
				RETURN cCodRet;
			END IF;

			RETURN cCodRet;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/10/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: CONSULTA DE HISTORIAL DE CAMBIOS PM', 
'DESCRIPCION: SPL que realiza un respaldo de los datos de los firmantes de la funcionalidad Persona Moral antes de ser modificados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_concentracionrecibida_cg(pUsuario CHAR(8), pIdFuncion CHAR(10), pFolioOperacion CHAR(8), pOrigen CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(30) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(2);
	DEFINE cCodTrans CHAR(4);
	DEFINE cCodProveedor CHAR(4);
	DEFINE fDenominacionOp1 FLOAT;
	DEFINE fDenominacionOp2 FLOAT;
	DEFINE fDenominacionOp3 FLOAT;
	DEFINE fDenominacionOp4 FLOAT;
	DEFINE fDenominacionOp5 FLOAT;
	DEFINE fDenominacionOp6 FLOAT;
	DEFINE fDenominacionOp7 FLOAT;
	DEFINE fDenominacionOp8 FLOAT;
	DEFINE fDenominacionOp9 FLOAT;
	DEFINE fDenominacionOp10 FLOAT;
	DEFINE fDenominacionOp11 FLOAT;
	DEFINE fDenominacionOp12 FLOAT;
	DEFINE fDenominacionOp13 FLOAT;
	DEFINE fDenominacionOp14 FLOAT;
	DEFINE fDenominacionOp15 FLOAT;
	DEFINE fCantidadOp1 FLOAT;
	DEFINE fCantidadOp2 FLOAT;
	DEFINE fCantidadOp3 FLOAT;
	DEFINE fCantidadOp4 FLOAT;
	DEFINE fCantidadOp5 FLOAT;
	DEFINE fCantidadOp6 FLOAT;
	DEFINE fCantidadOp7 FLOAT;
	DEFINE fCantidadOp8 FLOAT;
	DEFINE fCantidadOp9 FLOAT;
	DEFINE fCantidadOp10 FLOAT;
	DEFINE fCantidadOp11 FLOAT;
	DEFINE fCantidadOp12 FLOAT;
	DEFINE fCantidadOp13 FLOAT;
	DEFINE fCantidadOp14 FLOAT;
	DEFINE fCantidadOp15 FLOAT;
	DEFINE fMonto FLOAT;
	DEFINE cDescripcion CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';
	LET cCodTrans = '';
	LET cCodProveedor = '';
	LET fDenominacionOp1 = 0;
	LET fDenominacionOp2 = 0;
	LET fDenominacionOp3 = 0;
	LET fDenominacionOp4 = 0;
	LET fDenominacionOp5 = 0;
	LET fDenominacionOp6 = 0;
	LET fDenominacionOp7 = 0;
	LET fDenominacionOp8 = 0;
	LET fDenominacionOp9 = 0;
	LET fDenominacionOp10 = 0;
	LET fDenominacionOp11 = 0;
	LET fDenominacionOp12 = 0;
	LET fDenominacionOp13 = 0;
	LET fDenominacionOp14 = 0;
	LET fDenominacionOp15 = 0;
	LET fCantidadOp1 = 0;
	LET fCantidadOp2 = 0;
	LET fCantidadOp3 = 0;
	LET fCantidadOp4 = 0;
	LET fCantidadOp5 = 0;
	LET fCantidadOp6 = 0;
	LET fCantidadOp7 = 0;
	LET fCantidadOp8 = 0;
	LET fCantidadOp9 = 0;
	LET fCantidadOp10 = 0;
	LET fCantidadOp11 = 0;
	LET fCantidadOp12 = 0;
	LET fCantidadOp13 = 0;
	LET fCantidadOp14 = 0;
	LET fCantidadOp15 = 0;
	LET fMonto = 0;
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_concentracionrecibida_cg.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFolioOperacion = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		IF pOrigen NOT IN ('S', 'C') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 6;
		
		SELECT status, cod_proveedor
		INTO cStatus, cCodProveedor
		FROM bdisuc:"informix".ss_mae_entradasalida
		WHERE folio_oper = pFolioOperacion;
		
		SELECT cod_trans, NVL(cantidad_1, 0), NVL(cantidad_2, 0), NVL(cantidad_3, 0), NVL(cantidad_4, 0), NVL(cantidad_5, 0),
				NVL(cantidad_6, 0), NVL(cantidad_7, 0), NVL(cantidad_8, 0), NVL(cantidad_9, 0), NVL(cantidad_10, 0),
				NVL(cantidad_11, 0), NVL(cantidad_12, 0), NVL(cantidad_13, 0), NVL(cantidad_14, 0), NVL(cantidad_15, 0),
				CASE WHEN denominacion_1 = '' THEN 0 ELSE DECODE(denominacion_1, '-1', '1', 'M', '1', denominacion_1)::FLOAT END,
				CASE WHEN denominacion_2 = '' THEN 0 ELSE DECODE(denominacion_2, '-1', '1', 'M', '1', denominacion_2)::FLOAT END,
				CASE WHEN denominacion_3 = '' THEN 0 ELSE DECODE(denominacion_3, '-1', '1', 'M', '1', denominacion_3)::FLOAT END,
				CASE WHEN denominacion_4 = '' THEN 0 ELSE DECODE(denominacion_4, '-1', '1', 'M', '1', denominacion_4)::FLOAT END,
				CASE WHEN denominacion_5 = '' THEN 0 ELSE DECODE(denominacion_5, '-1', '1', 'M', '1', denominacion_5)::FLOAT END,
				CASE WHEN denominacion_6 = '' THEN 0 ELSE DECODE(denominacion_6, '-1', '1', 'M', '1', denominacion_6)::FLOAT END,
				CASE WHEN denominacion_7 = '' THEN 0 ELSE DECODE(denominacion_7, '-1', '1', 'M', '1', denominacion_7)::FLOAT END,
				CASE WHEN denominacion_8 = '' THEN 0 ELSE DECODE(denominacion_8, '-1', '1', 'M', '1', denominacion_8)::FLOAT END,
				CASE WHEN denominacion_9 = '' THEN 0 ELSE DECODE(denominacion_9, '-1', '1', 'M', '1', denominacion_9)::FLOAT END,
				CASE WHEN denominacion_10 = '' THEN 0 ELSE DECODE(denominacion_10, '-1', '1', 'M', '1', denominacion_10)::FLOAT END,
				CASE WHEN denominacion_11 = '' THEN 0 ELSE DECODE(denominacion_11, '-1', '1', 'M', '1', denominacion_11)::FLOAT END,
				CASE WHEN denominacion_12 = '' THEN 0 ELSE DECODE(denominacion_12, '-1', '1', 'M', '1', denominacion_12)::FLOAT END,
				CASE WHEN denominacion_13 = '' THEN 0 ELSE DECODE(denominacion_13, '-1', '1', 'M', '1', denominacion_13)::FLOAT END,
				CASE WHEN denominacion_14 = '' THEN 0 ELSE DECODE(denominacion_14, '-1', '1', 'M', '1', denominacion_14)::FLOAT END,
				CASE WHEN denominacion_15 = '' THEN 0 ELSE DECODE(denominacion_15, '-1', '1', 'M', '1', denominacion_15)::FLOAT END
		INTO cCodTrans, fCantidadOp1, fCantidadOp2, fCantidadOp3, fCantidadOp4, fCantidadOp5,
				fCantidadOp6, fCantidadOp7, fCantidadOp8, fCantidadOp9, fCantidadOp10,
				fCantidadOp11, fCantidadOp12, fCantidadOp13, fCantidadOp14, fCantidadOp15,
				fDenominacionOp1, fDenominacionOp2, fDenominacionOp3, fDenominacionOp4, fDenominacionOp5, 
				fDenominacionOp6, fDenominacionOp7, fDenominacionOp8, fDenominacionOp9, fDenominacionOp10, 
				fDenominacionOp11, fDenominacionOp12, fDenominacionOp13, fDenominacionOp14, fDenominacionOp15
		FROM bdisuc:"informix".ss_operaciones
		WHERE folio_oper = pFolioOperacion;
		
		-- ConcentraciÃ³n recibida
		IF (cStatus = '06' AND cCodTrans = '0002') OR (cCodTrans = '0041') THEN
			LET fMonto = fCantidadOp1 * fDenominacionOp1 +
						fCantidadOp2 * fDenominacionOp2 +
						fCantidadOp3 * fDenominacionOp3 +
						fCantidadOp4 * fDenominacionOp4 +
						fCantidadOp5 * fDenominacionOp5 +
						fCantidadOp6 * fDenominacionOp6 +
						fCantidadOp7 * fDenominacionOp7 +
						fCantidadOp8 * fDenominacionOp8 +
						fCantidadOp9 * fDenominacionOp9 +
						fCantidadOp10 * fDenominacionOp10 +
						fCantidadOp11 * fDenominacionOp11 +
						fCantidadOp12 * fDenominacionOp12 +
						fCantidadOp13 * fDenominacionOp13 +
						fCantidadOp14 * fDenominacionOp14 +
						fCantidadOp15 * fDenominacionOp15;
			
			UPDATE bdisuc:"informix".ss_cajageneral
			SET cantidad_1 = cantidad_1 + fCantidadOp1,
				cantidad_2 = cantidad_2 + fCantidadOp2,
				cantidad_3 = cantidad_3 + fCantidadOp3,
				cantidad_4 = cantidad_4 + fCantidadOp4,
				cantidad_5 = cantidad_5 + fCantidadOp5,
				cantidad_6 = cantidad_6 + fCantidadOp6,
				cantidad_7 = cantidad_7 + fCantidadOp7,
				cantidad_8 = cantidad_8 + fCantidadOp8,
				cantidad_9 = cantidad_9 + fCantidadOp9,
				cantidad_10 = cantidad_10 + fCantidadOp10,
				cantidad_11 = cantidad_11 + fCantidadOp11,
				cantidad_12 = cantidad_12 + fCantidadOp12,
				cantidad_13 = cantidad_13 + fCantidadOp13,
				cantidad_14 = cantidad_14 + fCantidadOp14,
				cantidad_15 = cantidad_15 + fCantidadOp15,
				saldo_total = saldo_total + fMonto
			WHERE cod_proveedor = cCodProveedor;
			
			UPDATE bdisuc:"informix".ss_mae_entradasalida 
			SET status = DECODE(pOrigen, 'S', '07', 'C', '15'),
				hora_recepcion = TO_CHAR(CURRENT, '%H:%m'), 
				fecha_recepcion = CURRENT,
				usuario_recepcion = pUsuario, 
				monto = fMonto
			WHERE folio_oper = pFolioOperacion;
			
			SELECT descripcion 
			INTO cDescripcion
			FROM bdisuc:"informix".ss_catstatus 
			WHERE status = DECODE(pOrigen, 'S', '07', 'C', '15');
			
		END IF;
		
		RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/07/2015',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de operaciones',
'DESCRIPCION: Realiza la concentraciÃ³n recibida',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadenosdoactualcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdProvCaja CHAR(4), pIdOperacion CHAR(4))
		RETURNING CHAR(5) AS codret, 
			DECIMAL(10,2) AS disponible1,
			CHAR(18) AS denominacion1,
			MONEY(14,2) AS mTotal1,
			DECIMAL(10,2) AS disponible2,			
			CHAR(18) AS denominacion2,
			MONEY(14,2) AS mTotal2,
			DECIMAL(10,2) AS disponible3,
			CHAR(18) AS denominacion3,
			MONEY(14,2) AS mTotal3,
			DECIMAL(10,2) AS disponible4,
			CHAR(18) AS denominacion4,
			MONEY(14,2) AS mTotal4,
			DECIMAL(10,2) AS disponible5,
			CHAR(18) AS denominacion5,
			MONEY(14,2) AS mTotal5,
			DECIMAL(10,2) AS disponible6,
			CHAR(18) AS denominacion6,
			MONEY(14,2) AS mTotal6,
			DECIMAL(10,2) AS cant_totalmorralla,
			CHAR(10) AS den_morralla,
			DECIMAL(10,2) AS disp_morralla,
			MONEY(14,2) AS total_actual,
			CHAR(2) AS divisa,
			DECIMAL(10,2) AS disponible7,
			CHAR(18) AS denominacion7,
			DECIMAL(10,2) AS disponible8,
			CHAR(18) AS denominacion8,
			DECIMAL(10,2) AS disponible9,
			CHAR(18) AS denominacion9,
			DECIMAL(10,2) AS disponible10,
			CHAR(18) AS denominacion10,
			DECIMAL(10,2) AS disponible11,
			CHAR(18) AS denominacion11,
			DECIMAL(10,2) AS disponible12,
			CHAR(18) AS denominacion12,
			DECIMAL(10,2) AS disponible13,
			CHAR(18) AS denominacion13,
			DECIMAL(10,2) AS disponible14,
			CHAR(18) AS denominacion14,
			DECIMAL(10,2) AS disponible15,
			CHAR(18) AS denominacion15;
			
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE dDisponible1 DECIMAL(10,2); 
		DEFINE cDenominacion1 CHAR(18);
		DEFINE mTotal1 MONEY(14,2);
		DEFINE dDisponible2 DECIMAL(10,2); 
		DEFINE cDenominacion2 CHAR(18);
		DEFINE mTotal2 MONEY(14,2);
		DEFINE dDisponible3 DECIMAL(10,2); 
		DEFINE cDenominacion3 CHAR(18); 
		DEFINE mTotal3 MONEY(14,2);
		DEFINE dDisponible4 DECIMAL(10,2); 
		DEFINE cDenominacion4 CHAR(18); 
		DEFINE mTotal4 MONEY(14,2);
		DEFINE dDisponible5 DECIMAL(10,2); 
		DEFINE cDenominacion5 CHAR(18);
		DEFINE mTotal5 MONEY(14,2);
		DEFINE dDisponible6 DECIMAL(10,2); 		
		DEFINE cDenominacion6 CHAR(18);
		DEFINE mTotal6 MONEY(14,2);
		DEFINE dDisponible7 DECIMAL(10,2); 
		DEFINE cDenominacion7 CHAR(18);  
		DEFINE mTotal7 MONEY(14,2);
		DEFINE dDisponible8 DECIMAL(10,2); 
		DEFINE cDenominacion8 CHAR(18); 
		DEFINE mTotal8 MONEY(14,2);
		DEFINE dDisponible9 DECIMAL(10,2); 
		DEFINE cDenominacion9 CHAR(18);
		DEFINE mTotal9 MONEY(14,2);
		DEFINE dDisponible10 DECIMAL(10,2); 
		DEFINE cDenominacion10 CHAR(18);
		DEFINE mTotal10 MONEY(14,2);
		DEFINE dDisponible11 DECIMAL(10,2); 
		DEFINE cDenominacion11 CHAR(18);
		DEFINE mTotal11 MONEY(14,2);
		DEFINE dDisponible12 DECIMAL(10,2); 
		DEFINE cDenominacion12 CHAR(18);
		DEFINE mTotal12 MONEY(14,2);
		DEFINE dDisponible13 DECIMAL(10,2); 
		DEFINE cDenominacion13 CHAR(18);
		DEFINE mTotal13 MONEY(14,2);
		DEFINE dDisponible14 DECIMAL(10,2); 
		DEFINE cDenominacion14 CHAR(18);
		DEFINE mTotal14 MONEY(14,2);		
		DEFINE dDisponible15 DECIMAL(10,2); 
		DEFINE cDenominacion15 CHAR(18);	
		DEFINE mTotal15 MONEY(14,2);
		
		DEFINE iCantTotalmorralla INTEGER;
		DEFINE cDenMorralla CHAR(10);
		DEFINE dDispMorralla DECIMAL(10,2);	
		DEFINE cDivisa CHAR(2);
		DEFINE mSaldoAnterior MONEY(14,2);
		DEFINE mSaldoAsignado MONEY(14,2);
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE mTotalActual MONEY(14,2);
        DEFINE iNoRegistros INTEGER; 
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET dDisponible1 = 0.00; 
		LET cDenominacion1 = '';
		LET mTotal1 = NULL;
		LET dDisponible2 = 0.00; 
		LET cDenominacion2 = '';
		LET mTotal2 = NULL;
		LET dDisponible3 = 0.00; 
		LET cDenominacion3 = ''; 
		LET mTotal3= NULL;
		LET dDisponible4 = 0.00; 
		LET cDenominacion4 = '';
		LET mTotal4 = NULL;
		LET dDisponible5 = 0.00; 
		LET cDenominacion5 = '';  
		LET mTotal5 = NULL;
		LET dDisponible6 = 0.00; 
		LET cDenominacion6 = '';  
		LET mTotal6 = NULL;
		LET dDisponible7 = 0.00; 
		LET cDenominacion7 = ''; 
		LET mTotal7 = NULL;		
		LET dDisponible8 = 0.00; 
		LET cDenominacion8 = '';
		LET mTotal8 = NULL;
		LET dDisponible9 = 0.00; 
		LET cDenominacion9 = '';
		LET mTotal9 = NULL;
		LET dDisponible10 = 0.00; 
		LET cDenominacion10 = '';
		LET mTotal10 = NULL;
		LET dDisponible11 = 0.00; 
		LET cDenominacion11 = '';
		LET mTotal11 = NULL;
		LET dDisponible12 = 0.00; 
		LET cDenominacion12 = '';
		LET mTotal12 = NULL;
		LET dDisponible13 = 0.00; 
		LET cDenominacion13 = '';
		LET mTotal13 = NULL;
		LET dDisponible14 = 0.00; 		
		LET cDenominacion14 = '';
		LET mTotal14 = NULL;		
		LET dDisponible15 = 0.00; 
		LET cDenominacion15 = '';
		LET mTotal15 = NULL;
		
		LET iCantTotalmorralla = 1;
		LET cDenMorralla = 'MORRALLA';
		LET dDispMorralla = 0.00;	
		LET cDivisa = '';
		LET mSaldoAnterior = NULL;
		LET mSaldoAsignado = NULL;
		LET mSaldoTotal = NULL;
		LET mTotalActual = NULL;
        LET iNoRegistros = 0; 
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultadenosdoactualcaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdProvCaja = '' OR pIdOperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;
			
			--SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA NÃMERO DE CAJA GENERAL
			IF NOT EXISTS(SELECT * FROM bdisuc:"informix".ss_cajageneral WHERE cod_proveedor = pIdProvCaja) THEN
				LET cCodRet = '90000'; -- La caja general nÃºmero ?numero? no existe. Por favor verifique 
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;
			
			-- CONSULTA DE PÃNEL
			FOREACH
				SELECT divisa, saldo_anterior, saldo_asignado, saldo_total,
					   NVL(cantidad_1,''), NVL(denominacion_1,''), NVL((cantidad_1 * denominacion_1::INTEGER),0) AS total_1, 
					   NVL(cantidad_2,''), NVL(denominacion_2,''), NVL((cantidad_2 * denominacion_2::INTEGER),0) AS total_2, 
					   NVL(cantidad_3,''), NVL(denominacion_3,''), NVL((cantidad_3 * denominacion_3::INTEGER),0) AS total_3, 
					   NVL(cantidad_4,''), NVL(denominacion_4,''), NVL((cantidad_4 * denominacion_4::INTEGER),0) AS total_4, 
					   NVL(cantidad_5,''), NVL(denominacion_5,''), NVL((cantidad_5 * denominacion_5::INTEGER),0) AS total_5, 
					   NVL(cantidad_6,''), NVL(denominacion_6,''), NVL((cantidad_6 * denominacion_6::INTEGER),0) AS total_6, 	
					   NVL(cantidad_7,''), NVL(denominacion_7,''), NVL((cantidad_7 * denominacion_7::INTEGER),0) AS total_7,
					   NVL(cantidad_8,''), NVL(denominacion_8,''), NVL((cantidad_8 * denominacion_8::INTEGER),0) AS total_8,
					   NVL(cantidad_9,''), NVL(denominacion_9,''), NVL((cantidad_9 * denominacion_9::INTEGER),0) AS total_9,
					   NVL(cantidad_10,''), NVL(denominacion_10,''), NVL((cantidad_10 * denominacion_10::INTEGER),0) AS total_10,
					   NVL(cantidad_11,''), NVL(denominacion_11,''), NVL((cantidad_11 * denominacion_11::INTEGER),0) AS total_11,
					   NVL(cantidad_12,''), NVL(denominacion_12,''), NVL((cantidad_12 * denominacion_12::INTEGER),0) AS total_12,
					   NVL(cantidad_13,''), NVL(denominacion_13,''), NVL((cantidad_13 * denominacion_13::INTEGER),0) AS total_13,
					   NVL(cantidad_14,''), NVL(denominacion_14,''), NVL((cantidad_14 * denominacion_14::INTEGER),0) AS total_14,
					   NVL(cantidad_15,''), NVL(denominacion_15,''), NVL((cantidad_15 * denominacion_15::INTEGER),0) AS total_15
					   
				INTO cDivisa, mSaldoAnterior, mSaldoAsignado, mSaldoTotal,
					 dDisponible1, cDenominacion1, mTotal1,
					 dDisponible2, cDenominacion2, mTotal2,
					 dDisponible3, cDenominacion3, mTotal3,
					 dDisponible4, cDenominacion4, mTotal4,
					 dDisponible5, cDenominacion5, mTotal5,
					 dDisponible6, cDenominacion6, mTotal6,
					 dDisponible7, cDenominacion7, mTotal7,
					 dDisponible8, cDenominacion8, mTotal8,
					 dDisponible9, cDenominacion9, mTotal9,
					 dDisponible10, cDenominacion10, mTotal10,
					 dDisponible11, cDenominacion11, mTotal11,
					 dDisponible12, cDenominacion12, mTotal12,
					 dDisponible13, cDenominacion13, mTotal13,
					 dDisponible14, cDenominacion14, mTotal14,
					 dDisponible15, cDenominacion15, mTotal15
					 
				FROM bdisuc:"informix".ss_cajageneral WHERE cod_proveedor = pIdProvCaja
					
				IF cDenominacion1 = '-1' OR cDenominacion1 = 'M' THEN
					LET dDispMorralla = dDisponible1;
					LET cDenominacion1 = '1';
				ELIF cDenominacion2 = '-1' OR cDenominacion2 = 'M' THEN
					LET dDispMorralla = dDisponible2;
					LET cDenominacion2 = '1';
				ELIF cDenominacion3 = '-1' OR cDenominacion3 = 'M' THEN
					LET dDispMorralla = dDisponible3;
					LET cDenominacion3 = '1';
				ELIF cDenominacion4 = '-1' OR cDenominacion4 = 'M' THEN
					LET dDispMorralla = dDisponible4;
					LET cDenominacion4 = '1';
				ELIF cDenominacion5 = '-1' OR cDenominacion5 = 'M' THEN
					LET dDispMorralla = dDisponible5;
					LET cDenominacion5 = '1';
				ELIF cDenominacion6 = '-1' OR cDenominacion6 = 'M' THEN
					LET dDispMorralla = dDisponible6;
					LET cDenominacion6 = '1';
				ELIF cDenominacion7 = '-1' OR cDenominacion7 = 'M' THEN
					LET dDispMorralla = dDisponible7;
					LET cDenominacion7 = '1';
				ELIF cDenominacion8 = '-1' OR cDenominacion8 = 'M' THEN
					LET dDispMorralla = dDisponible8;
					LET cDenominacion8 = '1';
				ELIF cDenominacion9 = '-1' OR cDenominacion9 = 'M' THEN
					LET dDispMorralla = dDisponible9;
					LET cDenominacion9 = '1';
				ELIF cDenominacion10 = '-1' OR cDenominacion10 = 'M' THEN
					LET dDispMorralla = dDisponible10;
					LET cDenominacion10 = '1';
				ELIF cDenominacion11 = '-1' OR cDenominacion11 = 'M' THEN
					LET dDispMorralla = dDisponible11;
					LET cDenominacion11 = '1';
				ELIF cDenominacion12 = '-1' OR cDenominacion12 = 'M' THEN
					LET dDispMorralla = dDisponible12;
					LET cDenominacion12 = '1';
				ELIF cDenominacion13 = '-1' OR cDenominacion13 = 'M' THEN
					LET dDispMorralla = dDisponible13;
					LET cDenominacion13 = '1';
				ELIF cDenominacion14 = '-1' OR cDenominacion14 = 'M' THEN
					LET dDispMorralla = dDisponible14;
					LET cDenominacion14 = '1';
				ELIF cDenominacion15 = '-1' OR cDenominacion15 = 'M' THEN
					LET dDispMorralla = dDisponible15;					
					LET cDenominacion15 = '1';
				END IF;
					
				LET mTotalActual = NVL(mTotal1,0) + NVL(mTotal2,0) + NVL(mTotal3,0) + NVL(mTotal4,0) + NVL(mTotal5,0) + NVL(mTotal6,0) + NVL(dDispMorralla,0);
				
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15 WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dDisponible1, cDenominacion1, mTotal1, dDisponible2, cDenominacion2, mTotal2, dDisponible3, cDenominacion3, mTotal3, dDisponible4, cDenominacion4, mTotal4, 
				dDisponible5, cDenominacion5, mTotal5, dDisponible6, cDenominacion6, mTotal6, iCantTotalmorralla, cDenMorralla, dDispMorralla, mTotalActual, cDivisa,
				dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, dDisponible11, cDenominacion11, dDisponible12, cDenominacion12,
				dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/02/2015',
'DESCRIPCION: SPL que obtiene el detalle de las cantidades actuales (montos y denominaciones) de la caja general consultada.',
'FUNCIONALIDAD: Compras y DepÃ³sitos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetalleoperacionmonitorcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoFolio CHAR(8), pCodStatus CHAR(2))
		RETURNING CHAR(5) AS codret,
			DECIMAL(10,2) AS fCant1, 
			CHAR(18) AS cDenominacion1, 
			MONEY(14,2) AS mTotal1, 
			DECIMAL(10,2) AS fCant2, 
			CHAR(18) AS cDenominacion2,
			MONEY(14,2) AS mTotal2,
			DECIMAL(10,2) AS fCant3,
			CHAR(18) AS cDenominacion3, 
			MONEY(14,2) AS mTotal3,
			DECIMAL(10,2) AS fCant4, 
			CHAR(18) AS cDenominacion4, 
			MONEY(14,2) AS mTotal4,
			DECIMAL(10,2) AS fCant5,
			CHAR(18) AS cDenominacion5,
			MONEY(14,2) AS mTotal5,
			DECIMAL(10,2) AS fCant6, 
			CHAR(18) AS cDenominacion6,
			MONEY(14,2) AS mTotal6,		
			CHAR(10) AS cMorralla,
			CHAR(18) AS cDenMorralla,
			MONEY(14,2) AS mTotalMorralla, 
			MONEY (14,2) AS monto_tot,
			CHAR(30) AS desc_moneda,
			CHAR(30) AS desc_status,
			DATE AS fech_solicitud, 
			CHAR(5) AS ho_solicitud, 
			CHAR(8) AS us_solicitud,
			DATE AS fech_envio,
			CHAR(5) AS ho_envio, 
			CHAR(8) AS us_envio,
			DATE AS fech_recepcion, 
			CHAR(5) AS ho_recepcion, 
			CHAR(8) AS us_recepcion,
			CHAR(45) AS nom_solicitud,
			CHAR(45) AS nom_envio,
		    CHAR(45) AS nom_recepcion,	
			DATE AS fech_reversion, 
			CHAR(5) AS ho_reversion, 
			CHAR(8) AS us_reversion,
			CHAR(45) AS nom_reversion,
			CHAR(1) AS indicador_usuario;

		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE fCant1 DECIMAL(10,2); 
	DEFINE cDenominacion1 CHAR(18); 
	DEFINE mTotal1 MONEY(14,2);
	DEFINE fCant2 DECIMAL(10,2); 
	DEFINE cDenominacion2 CHAR(18);
	DEFINE mTotal2 MONEY(14,2);
	DEFINE fCant3 DECIMAL(10,2); 
	DEFINE cDenominacion3 CHAR(18); 
	DEFINE mTotal3 MONEY(14,2);
	DEFINE fCant4 DECIMAL(10,2); 
	DEFINE cDenominacion4 CHAR(18);
	DEFINE mTotal4 MONEY(14,2);
	DEFINE fCant5 DECIMAL(10,2); 
	DEFINE cDenominacion5 CHAR(18); 
	DEFINE mTotal5 MONEY(14,2);
	DEFINE fCant6 DECIMAL(10,2); 
	DEFINE cDenominacion6 CHAR(18); 
	DEFINE mTotal6 MONEY(14,2);
	DEFINE fCant7 DECIMAL(10,2); 
	DEFINE cDenominacion7 CHAR(18); 
	DEFINE mTotal7 MONEY(14,2);
	DEFINE fCant8 DECIMAL(10,2); 
	DEFINE cDenominacion8 CHAR(18);
	DEFINE mTotal8 MONEY(14,2);	
	DEFINE fCant9 DECIMAL(10,2); 
	DEFINE cDenominacion9 CHAR(18);
	DEFINE mTotal9 MONEY(14,2);
	DEFINE fCant10 DECIMAL(10,2); 
	DEFINE cDenominacion10 CHAR(18);
	DEFINE mTotal10 MONEY(14,2);
	DEFINE fCant11 DECIMAL(10,2); 
	DEFINE cDenominacion11 CHAR(18);
	DEFINE mTotal11 MONEY(14,2);
	DEFINE fCant12 DECIMAL(10,2); 
	DEFINE cDenominacion12 CHAR(18);
	DEFINE mTotal12 MONEY(14,2);
	DEFINE fCant13 DECIMAL(10,2); 
	DEFINE cDenominacion13 CHAR(18);
	DEFINE mTotal13 MONEY(14,2);
	DEFINE fCant14 DECIMAL(10,2); 
	DEFINE cDenominacion14 CHAR(18);
	DEFINE mTotal14 MONEY(14,2);
	DEFINE fCant15 DECIMAL(10,2); 
	DEFINE cDenominacion15 CHAR(18);
	DEFINE mTotal15 MONEY(14,2);
	DEFINE cMorralla CHAR(10);		   
	DEFINE cDenMorralla CHAR(18);      
	DEFINE mTotalMorralla MONEY(14,2); 
	DEFINE mMontoTot MONEY(14,2);
	DEFINE cDivisa CHAR(2);
	DEFINE cDescMoneda CHAR(30);
	DEFINE cDescStatus CHAR(30);
	DEFINE dFechSolicitud DATE;
	DEFINE cHoSolicitud CHAR(5);
	DEFINE cUsSolicitud CHAR(8);
	DEFINE dFechEnvio DATE;
	DEFINE cHoEnvio CHAR(5);
	DEFINE cUsEnvio CHAR(8);
	DEFINE dFechRecepcion DATE;
	DEFINE cHoRecepcion CHAR(5);
	DEFINE cUsRecepcion CHAR(8);
	DEFINE cNomSolicitud CHAR(45);
	DEFINE cNomEnvio CHAR(45);
	DEFINE cNomRecepcion CHAR(45);
	
	DEFINE dFechReversion DATE;
	DEFINE cHoReversion CHAR(5); 
	DEFINE cUsReversion CHAR(8);
	DEFINE cNomReversion CHAR(45);
	DEFINE cIndicadorUs CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET fCant1 = 0.00; 
	LET cDenominacion1 = ''; 
	LET mTotal1 = NULL;
	LET fCant2 = 0.00; 
	LET cDenominacion2 = ''; 
	LET mTotal2 = NULL;
	LET fCant3 = 0.00; 
	LET cDenominacion3 = '';
	LET mTotal3 = NULL;
	LET fCant4 = 0.00; 
	LET cDenominacion4 = '';
	LET mTotal4 = NULL;
	LET fCant5 = 0.00; 
	LET cDenominacion5 = '';
	LET mTotal5 = NULL;
	LET fCant6 = 0.00; 
	LET cDenominacion6 = ''; 
	LET mTotal6 = NULL; 
	LET fCant7 = 0.00; 
	LET cDenominacion7 = ''; 
	LET mTotal7 = NULL;
	LET fCant8 = 0.00; 
	LET cDenominacion8 = ''; 
	LET mTotal8 = NULL;
	LET fCant9 = 0.00; 
	LET cDenominacion9 = '';
	LET mTotal9 = NULL;
	LET fCant10 = 0.00; 
	LET cDenominacion10 = '';
	LET mTotal10 = NULL;
	LET fCant11 = 0.00; 
	LET cDenominacion11 = '';
	LET mTotal11 = NULL;
	LET fCant12 = 0.00; 
	LET cDenominacion12 = '';
	LET mTotal12 = NULL;
	LET fCant13 = 0.00; 
	LET cDenominacion13 = '';
	LET mTotal13 = NULL;
	LET fCant14 = 0.00; 
	LET cDenominacion14 = '';
	LET mTotal14 = NULL;
	LET fCant15 = 0.00; 
	LET cDenominacion15 = '';
	LET mTotal15 = NULL;
	LET cMorralla = 'MORRALLA';   
	LET cDenMorralla = '';			
	LET mTotalMorralla = NULL;    
	LET mMontoTot = NULL;
	LET cDivisa = '';
	LET cDescMoneda = '';
	LET cDescStatus = '';
	LET dFechSolicitud = ''; 
	LET cHoSolicitud = '';
	LET cUsSolicitud = '';
	LET dFechEnvio = ''; 
	LET cHoEnvio = '';
	LET cUsEnvio = '';
	LET dFechRecepcion = ''; 
	LET cHoRecepcion = '';
	LET cUsRecepcion = '';
	LET cNomSolicitud = '';
	LET cNomEnvio = '';
	LET cNomRecepcion = '';
	
	LET dFechReversion = '';
	LET cHoReversion = ''; 
	LET cUsReversion = '';
	LET cNomReversion = '';
	LET cIndicadorUs = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetalleoperacionmonitorcaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoFolio = '' OR pCodStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END IF;
		
		SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		 
		SELECT cantidad_1, denominacion_1, NVL((cantidad_1 * DECODE(denominacion_1, '-1', '1', 'M', '1', denominacion_1)::INTEGER),0) AS total_1,
			   cantidad_2, denominacion_2, NVL((cantidad_2 * DECODE(denominacion_2, '-1', '1', 'M', '1', denominacion_2)::INTEGER),0) AS total_2,
			   cantidad_3, denominacion_3, NVL((cantidad_3 * DECODE(denominacion_3, '-1', '1', 'M', '1', denominacion_3)::INTEGER),0) AS total_3,
			   cantidad_4, denominacion_4, NVL((cantidad_4 * DECODE(denominacion_4, '-1', '1', 'M', '1', denominacion_4)::INTEGER),0) AS total_4,
			   cantidad_5, denominacion_5, NVL((cantidad_5 * DECODE(denominacion_5, '-1', '1', 'M', '1', denominacion_5)::INTEGER),0) AS total_5,
			   cantidad_6, denominacion_6, NVL((cantidad_6 * DECODE(denominacion_6, '-1', '1', 'M', '1', denominacion_6)::INTEGER),0) AS total_6,			
			   cantidad_7, denominacion_7, NVL((cantidad_7 * DECODE(denominacion_7, '-1', '1', 'M', '1', denominacion_7)::INTEGER), 0) AS total_7,
			   cantidad_8, denominacion_8, NVL((cantidad_8 * DECODE(denominacion_8, '-1', '1', 'M', '1', denominacion_8)::INTEGER),0) AS total_8,
			   cantidad_9, denominacion_9, NVL((cantidad_9 * DECODE(denominacion_9, '-1', '1', 'M', '1', denominacion_9)::INTEGER),0) AS total_9,
			   cantidad_10, denominacion_10, NVL((cantidad_10 * denominacion_10::INTEGER),0) AS total_10,
			   cantidad_11, denominacion_11, NVL((cantidad_11 * denominacion_11::INTEGER),0) AS total_11,
			   cantidad_12, denominacion_12, NVL((cantidad_12 * denominacion_12::INTEGER),0) AS total_12,
			   cantidad_13, denominacion_13, NVL((cantidad_13 * denominacion_13::INTEGER),0) AS total_13,
			   cantidad_14, denominacion_14, NVL((cantidad_14 * denominacion_14::INTEGER),0) AS total_14,
			   cantidad_15, denominacion_15, NVL((cantidad_15 * denominacion_15::INTEGER),0) AS total_15,
			   		
			   (NVL((cantidad_7 * DECODE(denominacion_7, '-1', '1', 'M', '1', denominacion_7)::INTEGER),0) + NVL((cantidad_8 * DECODE(denominacion_8, '-1', '1', 'M', '1', denominacion_8)::INTEGER),0) + NVL((cantidad_9 * DECODE(denominacion_9, '-1', '1', 'M', '1', denominacion_9)::INTEGER),0) +
			   	NVL((cantidad_10 * DECODE(denominacion_10, '-1', '1', 'M', '1', denominacion_10)::INTEGER),0) + NVL((cantidad_11 * DECODE(denominacion_11, '-1', '1', 'M', '1', denominacion_11)::INTEGER),0) + NVL((cantidad_12 * DECODE(denominacion_12, '-1', '1', 'M', '1', denominacion_12)::INTEGER),0) +
			   	NVL((cantidad_13 * DECODE(denominacion_13, '-1', '1', 'M', '1', denominacion_13)::INTEGER),0) + NVL((cantidad_14 * DECODE(denominacion_14, '-1', '1', 'M', '1', denominacion_14)::INTEGER),0) + NVL((cantidad_15 * DECODE(denominacion_15, '-1', '1', 'M', '1', denominacion_15)::INTEGER),0)
			   	) AS suma_total, monto, divisa 		
		INTO fCant1, cDenominacion1, mTotal1,
			 fCant2, cDenominacion2, mTotal2,
			 fCant3, cDenominacion3, mTotal3,
			 fCant4, cDenominacion4, mTotal4,
			 fCant5, cDenominacion5, mTotal5,
			 fCant6, cDenominacion6, mTotal6,
			 fCant7, cDenominacion7, mTotal7,
			 fCant8, cDenominacion8, mTotal8,
			 fCant9, cDenominacion9, mTotal9,
			 fCant10, cDenominacion10, mTotal10,
			 fCant11, cDenominacion11, mTotal11,
			 fCant12, cDenominacion12, mTotal12,
			 fCant13, cDenominacion13, mTotal13,
			 fCant14, cDenominacion14, mTotal14,
			 fCant15, cDenominacion15, mTotal15,
			 mTotalMorralla, mMontoTot, cDivisa
		FROM bdisuc:ss_operaciones 
		WHERE folio_oper = pNoFolio;
		
		SELECT descripcion INTO cDescMoneda FROM bdinteg:si_divisas WHERE divisa = cDivisa;
		
		SELECT descripcion INTO cDescStatus FROM bdisuc:ss_catstatus WHERE status = pCodStatus;
		
		SELECT fecha_solicitud, hora_solicitud, usuario_solicitud, fecha_envio, hora_envio, usuario_envio, fecha_recepcion, hora_recepcion, usuario_recepcion, fecha_reversion, hora_reversion, usuario_reversion
		INTO dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio, dFechRecepcion, cHoRecepcion, cUsRecepcion, dFechReversion, cHoReversion, cUsReversion
		FROM bdisuc:"informix".ss_mae_entradasalida where folio_oper = pNoFolio;
		
		-- VALIDA RECEPCION
		IF dFechRecepcion IS NULL AND cHoRecepcion IS NULL AND cUsRecepcion IS NULL THEN
			IF dFechReversion IS NULL AND cHoReversion IS NULL AND cUsReversion IS NULL THEN
				LET cIndicadorUs = '0'; --Muestra Ninguno
			ELSE 
				LET cIndicadorUs = '2'; --Muestra ReversiÃ³n
			END IF;
		ELSE 
			LET cIndicadorUs = '1';     --Muestra RecepciÃ³n
		END IF;			
	
		SELECT nombre INTO cNomSolicitud FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUsSolicitud;
		SELECT nombre INTO cNomEnvio FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUsEnvio;
		SELECT nombre INTO cNomRecepcion FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUsRecepcion;
		SELECT nombre INTO cNomReversion FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUsReversion;
		
		RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, UPPER(cMorralla), cDenMorralla, mTotalMorralla, mMontoTot, UPPER(cDescMoneda), UPPER(cDescStatus), dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, UPPER(cNomSolicitud), UPPER(cNomEnvio), UPPER(cNomRecepcion), dFechReversion, cHoReversion, cUsReversion, UPPER(cNomReversion), cIndicadorUs;
				
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado de las denominaciones, montos y totales de cada operaciÃ³n, asÃ­ como los detalles de la solicitud',
'envÃ­o, recepciÃ³n y reversiÃ³n.',
'FECHA: 27/02/2015',
'DESCRIPCION: Se agregÃ³ un indicador, el cual nos dice si los datos a mostrar en el detalle de la operaciÃ³n deben ser:',
'indicador_usuario = 1 (RecepciÃ³n), indicador_usuario = 2 (ReversiÃ³n), o indicador_usuario = 0 (Ninguno)',
'FUNCIONALIDAD: Monitor Operaciones Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_asignacionctesusuariofusion(pUsuario CHAR(8), pIdFuncion CHAR(10), pTamanioBloque INTEGER, pTipoOperacion SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
	    INTEGER AS iId_registro,
	    CHAR(20) AS cNumcte_1,
	    CHAR(20) AS cNumcte_2,
	    CHAR(13) AS cRfc_1,
	    CHAR(13) AS cRfc_2,
	    CHAR(1)  AS cCte_correcto,
	    CHAR(1)  AS cFlag_fusion,
	    CHAR(2)  AS cCausa_no_fus,
	    CHAR(1)  AS cEstatus_asig,
	    CHAR(8)  AS cUser_asig,
	    DATE AS dFecha_dict,
	    CHAR(26) AS nombre1_cte1,
	    CHAR(26) AS nombre2_cte1,
	    CHAR(26) AS appat_cte1,
	    CHAR(26) AS apmat_cte1,
	    CHAR(13) AS rfc_cte1,
	    DATE AS fecnac_cte1,				  
	    CHAR(26) AS nombre1_cte2,
	    CHAR(26) AS nombre2_cte2,
	    CHAR(26) AS appat_cte2,
	    CHAR(26) AS apmat_cte2,
	    CHAR(13) AS rfc_cte2,
	    DATE AS fecnac_cte2,
	    CHAR(2) AS cTpopersona1,
	    CHAR(2) AS cTpopersona2,
	    CHAR(1) AS cTipo_cliente1,
	    CHAR(1) AS cTipo_cliente2;				  
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iId_registro INTEGER;
	DEFINE cNumcte_1 CHAR(20);
	DEFINE cNumcte_2 CHAR(20); 
	DEFINE cRfc_1 CHAR(13);
	DEFINE cRfc_2 CHAR(13);
	DEFINE cCte_correcto CHAR(1);
	DEFINE cFlag_fusion CHAR(1);
	DEFINE cCausa_no_fus CHAR(2);
	DEFINE cEstatus_asig CHAR(1);
	DEFINE cUser_asig CHAR(8) ;
	DEFINE dFecha_dict DATETIME YEAR TO FRACTION(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegistrosTotales INTEGER;
	DEFINE iNoRegistrosRecuperados INTEGER;
	DEFINE iNoRegsRecuperados INTEGER;
	DEFINE iRowId INTEGER;
	
	DEFINE cNombre1Cte1 CHAR(26);
	DEFINE cNombre2Cte1 CHAR(26);
	DEFINE cApPaterCte1 CHAR(26);
	DEFINE cApMaterCte1 CHAR(26);
	DEFINE cRfcCte1 CHAR(26);
	DEFINE dFechaNacCte1 DATE;
	DEFINE cTpopersona1 CHAR(2);
	DEFINE cTipo_cliente1 CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cNombre1Cte2 CHAR(26);
	DEFINE cNombre2Cte2 CHAR(26);
	DEFINE cApPaterCte2 CHAR(26);
	DEFINE cApMaterCte2 CHAR(26);
	DEFINE cRfcCte2 CHAR(26);
	DEFINE dFechaNacCte2 DATE;
	DEFINE cTpopersona2 CHAR(2);
	DEFINE cTipo_cliente2 CHAR(1);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iId_registro = 0;
	LET cNumcte_1 = '';
	LET cNumcte_2 = ''; 
	LET cRfc_1 = '';
	LET cRfc_2 = '';
	LET cCte_correcto = '';
	LET cFlag_fusion  = '';
	LET cCausa_no_fus = '';
	LET cEstatus_asig = '';
	LET cUser_asig = '';
	LET	dFecha_dict = NULL;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegistrosTotales = 0;
	LET iNoRegistrosRecuperados = 0;
	LET iNoRegsRecuperados = 0;
	LET iRowId = 0;
	
	LET cNombre1Cte1 = '';
	LET cNombre2Cte1 = '';
	LET cApPaterCte1 = '';
	LET cApMaterCte1 = '';
	LET cRfcCte1 = '';
	LET dFechaNacCte1 = NULL;
	LET cNombre1Cte2 = '';
	LET cNombre2Cte2 = '';
	LET cApPaterCte2 = '';
	LET cApMaterCte2 = '';
	LET cRfcCte2 = '';
	LET dFechaNacCte2 = NULL;
	LET cTpopersona1 = '';
	LET cTpopersona2 = '';
	LET cTipo_cliente1 = '';
	LET cTipo_cliente2 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
					   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
					   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
					   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
					   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_asignacionctesusuariofusion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
					   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
					   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
					   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
					   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END IF;
		
		IF pTipoOperacion NOT IN (0, 1) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
					   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
					   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
					   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
					   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END IF;
		
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
					   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
					   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
					   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
					   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END IF;
		
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
					   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
					   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
					   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
					   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END IF;
		
		-- SE APARTAN LOS CLIENTES
		IF pRegistros = 0 AND pTipoOperacion = 0 THEN
			IF pTamanioBloque IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
						   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
						   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
						   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
						   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
			END IF;
			
			
			-- VALIDAMOS QUE NO SE TENGAN CLIENTES ASIGNADOS
				IF NOT EXISTS (SELECT usuario_asig FROM "informix".sw_tr_clientesasignados_soc WHERE usuario_asig = pUsuario) THEN
		
				INSERT INTO "informix".sw_tr_clientesasignados_soc(id_registro, numcte_1, usuario_asig, no_regstotales)
				SELECT FIRST 10 id_registro, numcte_1, pUsuario, COUNT (id_registro)
				FROM "informix".sw_tr_clientesduplicados 
				WHERE id_registro NOT IN (SELECT id_registro FROM bdicnweb:"informix".sw_tr_clientesasignados_soc)
					AND flag_fusion IN ('0')
				GROUP  BY id_registro, numcte_1, 3;
					
				-- SE ACTUALIZAN LOS CLIENTES EN LA TABLA PRINCIPAL
				UPDATE "informix".sw_tr_clientesduplicados 
				SET user_asig = pUsuario,
					estatus_asig = '1' -- CLIENTE ASIGNADO
				WHERE id_registro IN (SELECT id_registro FROM bdicnweb:"informix".sw_tr_clientesasignados_soc WHERE usuario_asig = pUsuario);
			ELSE

				LET cCodRet = '00362';
				RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
						   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
						   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
						   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
						   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
			END IF;
		END IF;
		
		IF pTipoOperacion = 1 THEN
			-- SE DEPURAN LOS CLIENTES ASIGNADOS
			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT id_registro, numcte_1, no_regstotales
					INTO iRowId, cNumcte_1, iNoRegistrosTotales
					FROM "informix".sw_tr_clientesasignados_soc 
					WHERE usuario_asig = pUsuario
					
				SELECT COUNT(numcte_1)
				INTO iNoRegistrosRecuperados
				FROM "informix".sw_tr_clientesduplicados
				WHERE id_registro = iRowId
					AND flag_fusion IN ('1');
				
				IF iNoRegistrosRecuperados = iNoRegistrosTotales THEN
					UPDATE "informix".sw_tr_clientesasignados_soc
					SET status_cliente = '3' -- CLIENTE FUSIONADO
					WHERE id_registro = iRowId;
				ELIF iNoRegistrosRecuperados < iNoRegistrosTotales THEN
					UPDATE "informix".sw_tr_clientesasignados_soc
					SET status_cliente = '1' -- ASIGNADO
					WHERE id_registro = iRowId;
				END IF;
					
			END FOREACH;

		END IF;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_registro, numcte_1, numcte_2, rfc_1, rfc_2, cte_correcto, flag_fusion, causa_no_fus, estatus_asig, user_asig, fecha_dict 
			INTO iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict   
			FROM "informix".sw_tr_clientesduplicados 
			WHERE id_registro in (SELECT id_registro FROM bdicnweb:"informix".sw_tr_clientesasignados_soc WHERE usuario_asig = pUsuario AND status_cliente = '1')
				AND flag_fusion = '0'
			
			SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, a.rfc, b.fecha_nac, tpo_persona, tipo_cliente 
			INTO cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1, cTpopersona1, cTipo_cliente1
			FROM bdinteg:"informix".si_cliente a LEFT JOIN bdinteg:"informix".si_ctepf b ON b.numcte = a.numcte
			WHERE a.numcte = cNumcte_1;
			
			SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, a.rfc, b.fecha_nac, tpo_persona, tipo_cliente 
			INTO cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, cTpopersona2, cTipo_cliente2
			FROM bdinteg:"informix".si_cliente a LEFT JOIN bdinteg:"informix".si_ctepf b ON b.numcte = a.numcte
			WHERE a.numcte = cNumcte_2;
			
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
				   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
				   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
				   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
				   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2 WITH RESUME;
			
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;		

		/* No se encontraron resultados */
		IF iNoRegistros = 0 and pRegistros = 0 THEN
			IF pTipoOperacion = 0 THEN
				LET cCodRet = '00017';
			ELIF pTipoOperacion = 1 THEN
				LET cCodRet = '00363'; 
				
			END IF;
			
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
				   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
				   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
				   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
				   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iId_registro, cNumcte_1, cNumcte_2, cRfc_1, cRfc_2, cCte_correcto, cFlag_fusion, 
				   cCausa_no_fus, cEstatus_asig, cUser_asig, dFecha_dict,
				   cNombre1Cte1, cNombre2Cte1, cApPaterCte1, cApMaterCte1, cRfcCte1, dFechaNacCte1,
				   cNombre1Cte2, cNombre2Cte2, cApPaterCte2, cApMaterCte2, cRfcCte2, dFechaNacCte2, 
				   cTpopersona1, cTpopersona2, cTipo_cliente1, cTipo_cliente2;
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 02/07/2014',
'DESCRIPCION: Obtiene catalogo y realiza asignacion de cliente a usuario',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/06/2016',
'DESCRIPCION: Se cambian las consultas para utilizar el id_registro como llave primaria',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consasignacionesfusioncte(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cNumEjecutivo,
				  CHAR(100) AS cNombreEjecutivo,
				  CHAR(20) AS cNumCliente,
				  CHAR(100) AS cNombreCliente,
				  CHAR(1) AS cCveStatusAsig,
				  CHAR(20) AS cDescripcionStatusAsig,
				  INTEGER AS iIdRegistro;			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE cNumEjecutivo CHAR(20); 
	DEFINE cNombreEjecutivo CHAR(100);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cCveStatusAsig CHAR(1);
	DEFINE cDescripcionStatusAsig CHAR(20);
	DEFINE iNoRegistro INTEGER;
	DEFINE iIdRegistro INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNombreEjecutivo = '';
	LET cNumEjecutivo = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cCveStatusAsig = '';
	LET cDescripcionStatusAsig = '';
	LET iNoRegistro = 0;
	LET iIdRegistro = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consasignacionesfusioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		END IF;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion 
				    id_usuario
					, c.nombre AS ejecutivo
					, NVL(b.numcte_1, '') AS num_cliente
					, TRIM(TRIM(TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2, '')))||' '||TRIM(TRIM(NVL(apell_paterno, ''))||' '||TRIM(NVL(apell_materno, '')))) AS nombre_cliente
					, NVL(b.status_cliente, '0') AS estatus_cliente
					, DECODE(b.status_cliente, '1', 'ASIGNADO', '2', 'EN PROCESO', '3', 'FUSIONADO', '')
					, b.id_registro
			INTO cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig, iIdRegistro
			FROM (((bdinteg:si_seg_usuarios_funciones a LEFT JOIN bdicnweb:sw_tr_clientesasignados_soc b ON b.usuario_asig = a.id_usuario)
					LEFT JOIN bdinteg:si_ejecut c ON c.ejecutivo = a.id_usuario)
					LEFT JOIN bdinteg:si_cliente d ON d.numcte = b.numcte_1)
					LEFT JOIN bdicnweb:sw_tr_clientesduplicados e ON e.id_registro = b.id_registro
			WHERE id_funcion = 'CLI351' AND status = '1'
			
			
			LET iNoRegistro = iNoRegistro + 1;
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig, iIdRegistro WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistro = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		ELIF iNoRegistro = 0 AND pRegistros > 0 THEN 
			LET cCodRet = '1001';
			RETURN cCodRet, cNumEjecutivo, cNombreEjecutivo, cNumCliente, cNombreCliente, cCveStatusAsig, cDescripcionStatusAsig,iIdRegistro;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 15/07/2014',
'DESCRIPCION: Consulta estado de asignacion de clientes fusionados',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/06/2016',
'DESCRIPCION: Se cambian las consultas para utilizar el id_registro como llave primaria',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_eliminasignacionctesfusion(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                                INTEGER AS regs_afectados;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, 0;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_eliminasignacionctesfusion.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, 0;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, 0;
                END IF;
                
                SET LOCK MODE TO WAIT 3;
                DELETE FROM bdicnweb:"informix".sw_tr_clientesasignados_soc WHERE usuario_asig = pUsuario;
                
                RETURN cCodRet, DBINFO('sqlca.sqlerrd2');
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Elimina a los clientes asignados a un usuario para fusiÃ³n de clientes',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 23/02/2016',
'DESCRIPCION: Se realizo la modificacion quitando la actualizacion de usuario_asig para poder usar ese campo en otra funcionaldiad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardafusioncte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte1 CHAR(20), pIdRegistro INTEGER, pCteCorrecto  CHAR(1), pEstadoFusion CHAR(1), pCausaNoFus CHAR(2), pEstatusAsig CHAR(1))  
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistrosRecuperados INTEGER;
	DEFINE iNoRegistrosProcesados INTEGER;
	DEFINE iRowId INTEGER;
	DEFINE cNumcte_2 CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistrosRecuperados = 0;
	LET iNoRegistrosProcesados = 0;
	LET iRowId = 0;
	LET cNumcte_2 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardafusioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte1 ='' OR pIdRegistro IS NULL OR pEstadoFusion ='' OR pCteCorrecto ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
				
		IF pEstadoFusion = '3' THEN
			LET pCteCorrecto = '';
		END IF;
				
		UPDATE bdicnweb:sw_tr_clientesduplicados 
		SET cte_correcto = pCteCorrecto, 
			flag_fusion = pEstadoFusion, 
			causa_no_fus = pCausaNoFus, 
			estatus_asig = pEstatusAsig,
			user_asig = pUsuario, fecha_dict =current 
		WHERE id_registro = pIdRegistro;
		
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00283';
		END IF;

		--INSERTA INSTRUCCION DE FUSION
		IF pEstadoFusion = '1' THEN
			SELECT numcte_2 INTO cNumcte_2 
			FROM bdicnweb:sw_tr_clientesduplicados 
			WHERE id_registro= pIdRegistro;
						
			INSERT INTO bdinteg:si_fusion_solic (cliente_tit, cliente_tras, canal, fecha_insert, estatus, cod_retorno, proceso, fecha_fusion, fecha_proceso)
			VALUES (DECODE(pCteCorrecto, 1, pNumcte1, 2, cNumcte_2), DECODE(pCteCorrecto, 1, cNumcte_2, 2, pNumcte1), '4', CURRENT::DATE, 0,'','','','');
		END IF;
		
		
		-- ACTUALIZACIÓN DE ESTATUS EN LA TABLA DE ASIGNACIONES
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iNoRegistrosProcesados
		FROM bdicnweb:sw_tr_clientesduplicados
		WHERE id_registro = pIdRegistro
			AND flag_fusion IN ('1');
		
		IF iNoRegistrosProcesados = iNoRegistrosRecuperados THEN
			UPDATE bdicnweb:"informix".sw_tr_clientesasignados_soc 
			SET status_cliente = '3'
			WHERE id_registro = pIdRegistro;
		END IF;
		
		RETURN cCodRet;	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 03/07/2014',
'DESCRIPCION: Actualiza cliente  con estatus a fusionar',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/06/2016',
'DESCRIPCION: Se cambian las consultas para utilizar el id_registro como llave primaria',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_marcarstatusctefusion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegistro INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_actualizados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_marcarstatusctefusion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE "informix".sw_tr_clientesasignados_soc
		SET status_cliente = '2' -- EN PROCESO
		WHERE id_registro = pIdRegistro;
			
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00001';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/07/2014',
'DESCRIPCION: Cambia el estatus de un cliente para el monitor de asignaciones de clientes fusionados',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/06/2016',
'DESCRIPCION: Se cambian las consultas para utilizar el id_registro como llave primaria',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reasignacionctesusuariofusion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegistroCliente INTEGER, pUsuarioOrigen CHAR(20), pUsuarioDestino CHAR(20))
		RETURNING CHAR(5) AS codret,
			INTEGER AS registros_afectados;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRowId INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRowId = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reasignacionctesusuariofusion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pIdRegistroCliente IS NULL OR pUsuarioOrigen = '' OR pUsuarioDestino = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		

		-- ACTUALIZACIÓN DEL CLIENTE HACIA EL USUARIO
		UPDATE bdicnweb:"informix".sw_tr_clientesasignados_soc
		SET usuario_asig = pUsuarioDestino
		WHERE id_registro = pIdRegistroCliente;

		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		IF iNoRegistros = 0 THEN
	
			UPDATE "informix".sw_tr_clientesasignados_soc
			SET usuario_asig = pUsuarioDestino
			WHERE id_registro = pIdRegistroCliente;

			IF iNoRegistros = 0 THEN
				LET cCodRet = '00281';
			END IF;
		END IF;

		-- ACTUALIZACIÓN EN LA TABLA DE LOS CLIENTES FUSIONADOS
		UPDATE bdicnweb:sw_tr_clientesduplicados
		SET user_asig = pUsuarioDestino
		WHERE id_registro = pIdRegistroCliente;

		RETURN cCodRet, iNoRegistros;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/07/2014',
'DESCRIPCION: Reasignación de clientes para fusionar',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/06/2016',
'DESCRIPCION: Se cambian las consultas para utilizar el id_registro como llave primaria',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_consulta_catmotivos_pendiente(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_motivo_pendiente,
				CHAR(50) AS desc_motivo_pendiente,
				CHAR(1) AS requiere_captura;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdMotivoPendiente INTEGER;
	DEFINE cDescMotivoPendiente CHAR(50);
	DEFINE cRequiereCaptura CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdMotivoPendiente = 0;
	LET cDescMotivoPendiente = '';
	LET iNoRegistros = 0;
	LET cRequiereCaptura = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_tr_consulta_catmotivos_pendiente.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH SELECT id_motivo_pendiente, desc_motivo_pendiente, requiere_captura
			INTO iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura
			FROM bdicnweb:"informix".sw_tr_fusioncat_motivos_pendiente
			ORDER BY orden
		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura WITH RESUME;
		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdMotivoPendiente, cDescMotivoPendiente, cRequiereCaptura;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/12/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusión de clientes',
'DESCRIPCION: Consulta el catalogo de motivos por el cual una fusión queda pendiente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_genreportectesfusionados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFechaInicio DATE, pFechaFin DATE, pIdEmpleado CHAR(8))
	
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_tr_genreportectesfusionados_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;

		SELECT COUNT(*)
		INTO iNoRegistros
		FROM (bdicnweb:'informix'.sw_tr_clientesduplicados a LEFT JOIN 
			  bdinteg:'informix'.si_ejecut b ON b.ejecutivo = a.user_asig)
		WHERE flag_fusion = '1'
		AND fecha_dict::DATE BETWEEN pFechaInicio AND pFechaFin
		AND a.user_asig = CASE WHEN pIdEmpleado = '' THEN a.user_asig ELSE pIdEmpleado END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iNoRegistros;
		END IF;		
		
		RETURN cCodRet,iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 22/12/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Reportes de FusiÃ³n de Clientes',
'DESCRIPCION: Consulta el numero total de los registros de fusion semiautomatizada a fusionar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_genreportectesnofusionados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFechaInicio DATE, pFechaFin DATE, pIdEmpleado CHAR(8))
	
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_tr_genreportectesnofusionados_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM (bdicnweb:'informix'.sw_tr_clientesduplicados a LEFT JOIN 
			  bdinteg:'informix'.si_ejecut b ON b.ejecutivo = a.user_asig)
		WHERE flag_fusion IN ('0','3')
		AND fecha_dict::DATE BETWEEN pFechaInicio AND pFechaFin
		AND a.user_asig = CASE WHEN pIdEmpleado = '' THEN a.user_asig ELSE pIdEmpleado END;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iNoRegistros;
		END IF;		
		
		RETURN cCodRet,iNoRegistros;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 22/12/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Reportes de FusiÃ³n de Clientes',
'DESCRIPCION: Consulta el numero total de los registros de fusion semiautomatizada no fusionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_guarda_motpendiente_fusion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegistro INTEGER, pIdMotivoPendiente INTEGER, pOtroMotivo CHAR(100))
                RETURNING CHAR(5) AS codret,
                        INTEGER AS num_registros;
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
				
                ON EXCEPTION IN (-691)
                        LET cCodRet = '00284';
                        RETURN cCodRet, 
                        iNoRegistros;
                END EXCEPTION;
				
                --SET DEBUG FILE TO '/tmp/mfinis/sp_tr_guarda_motpendiente_fusion.out';
                --TRACE ON;
				
                IF pUsuario = '' OR pIdFuncion = '' OR pIdRegistro IS NULL OR pIdMotivoPendiente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
                IF EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_tr_fusioncat_motivos_pendiente WHERE id_motivo_pendiente = pIdMotivoPendiente AND requiere_captura = '1') THEN
                        IF pOtroMotivo = ''  THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, iNoRegistros;
                        END IF;
                END IF;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                SET LOCK MODE TO WAIT 3;
                INSERT INTO bdicnweb:"informix".sw_tr_fusion_motivos_pendiente(id_motivo_pendiente, id_registro , desc_motivo_otro)
                VALUES (pIdMotivoPendiente, pIdRegistro, pOtroMotivo);
                LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '00282';
                END IF;
                RETURN cCodRet, iNoRegistros;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/12/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusión de Clientes',
'DESCRIPCION: Alamcena el motivo por el cual se queda pendiente la fusión de un cliente',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 17/02/2016',
'DESCRIPCION: Se realizo la modificacion al parametro de num_cuenta por el de id_registro de la tabla bdicnweb:sw_tr_fusion_motivos_pendiente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizaindicadorespei(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(5), pIdindc INTEGER, pPorcentaje  DECIMAL(7,4),pRango CHAR(5), pPonderacion INT, pPorcentajeFin DECIMAL(5,2), pDescIndicador CHAR(200))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdGral          INTEGER;
        DEFINE iIdIndc          INTEGER;
        DEFINE iIdSubindi       INTEGER;
        DEFINE cTipo            CHAR(5);
        DEFINE dPorcentaje      DECIMAL(7,4);
        DEFINE cRango           CHAR(5);
        DEFINE sPonderacion SMALLINT;
        DEFINE dPorcentajeFin DECIMAL(5,2);
        DEFINE cActividad   CHAR(50);
        DEFINE cTipoDescripcion  CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdGral = 0;
        LET iIdIndc = 0;
        LET iIdSubindi = 0;
        LET cTipo = '';
        LET dPorcentaje = 0.00;
        LET cRango = '';
        LET sPonderacion  = 0;
        LET dPorcentajeFin = 0.00;
        LET cActividad='ACTUALIZA PARAMETROS DE PONDERACION';
        LET cTipoDescripcion='';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizaindicadorespei.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pTipo='' OR  pIdindc IS NULL OR pPorcentaje IS NULL OR pRango='' OR pPonderacion IS NULL  OR pPorcentajeFin IS NULL THEN
                    LET cCodRet = '00003';
                    RETURN cCodRet;
                END IF;
                
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                    RETURN cCodRet;
                END IF;
                
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO  WAIT;  
                
                SELECT a.*, (CASE WHEN a.tipo = 'M' THEN 'MONTO' ELSE 'TRANSACCION' END) tipoDescripcion
                INTO iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin,cTipoDescripcion
                FROM bdibi@stag_ids1170:"informix".bi_ind_indpon a
                WHERE id_gral = 1
                AND tipo = pTipo
                AND id_indc=pIdindc
                AND ponderacion=pPonderacion;
                                
                --PORCENTAJE
                IF (dPorcentaje IS NULL OR dPorcentaje <> pPorcentaje)THEN
                        UPDATE bdibi@stag_ids1170:"informix".bi_ind_indpon SET
                        porcentaje=pPorcentaje
                        WHERE id_gral = 1
                        AND tipo = pTipo
                        AND id_indc=pIdindc
                        AND ponderacion=pPonderacion;
                        
                        INSERT INTO  bdibi@stag_ids1170:"informix".bi_ind_log(fecha_act,valor_ant,campo_act,usuario,actividad,desc_indicador,ponderacion,tipo) 
                        VALUES (CURRENT, dPorcentaje, 'porcentaje',pUsuario, cActividad, pDescIndicador, pPonderacion,cTipoDescripcion);
                END IF;
                
                --RANGO
                IF (cRango ='' OR cRango <> pRango)THEN
                        UPDATE bdibi@stag_ids1170:"informix".bi_ind_indpon SET
                        rango=pRango
                        WHERE id_gral = 1
                        AND tipo = pTipo
                        AND id_indc=pIdindc
                        AND ponderacion=pPonderacion;
                        
                        INSERT INTO  bdibi@stag_ids1170:"informix".bi_ind_log(fecha_act,valor_ant,campo_act,usuario,actividad,desc_indicador,ponderacion,tipo)
                        VALUES (CURRENT, cRango, 'rango',pUsuario, cActividad, pDescIndicador, pPonderacion,cTipoDescripcion);
                END IF;
                
                
                --PORCENTAJE FIN
                IF (dPorcentajeFin IS NULL OR dPorcentajeFin <> pPorcentajeFin)THEN
                        UPDATE bdibi@stag_ids1170:"informix".bi_ind_indpon
                        SET     porcentaje_fin = pPorcentajeFin
                        WHERE id_gral = 1
                        AND tipo = pTipo
                        AND id_indc=pIdindc
                        AND ponderacion=pPonderacion;
                        
                        INSERT INTO  bdibi@stag_ids1170:"informix".bi_ind_log(fecha_act,valor_ant,campo_act,usuario,actividad,desc_indicador,ponderacion,tipo)
                        VALUES (CURRENT, dPorcentajeFin, 'porcentaje_fin',pUsuario, cActividad, pDescIndicador, pPonderacion,cTipoDescripcion);
                END IF;
                
        
                RETURN cCodRet; 
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 18/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACION DE CATALOGO INDICADORES SPEI',
'DESCRIPCION: SPL que actualiza los valores de indicadores ',
'BD: bdicnweb',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 22/04/2016',
'DESCRIPCION: Se realizo una modificacion al al corte de los campos de porcentaje y porcentaje_fin .',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi';

CREATE PROCEDURE "informix".sp_ope_bajacuentaspei(pUsuario CHAR(8), pIdFuncion CHAR(10), pId INTEGER)
                RETURNING CHAR(5)  AS codret;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCuenta CHAR(20);
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
                        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_bajacuentaspei.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pId IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                SELECT cuenta
                        INTO cCuenta
                        FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
                        WHERE id = pId;
                
                DELETE FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
                        WHERE id = pId;
                
                INSERT INTO bdibi@stag_ids1170:"informix".bi_ind_log (fecha_act,valor_ant,usuario,actividad)
                        VALUES(CURRENT,cCuenta,pUsuario,"BAJA CUENTA");
                                                                        
                RETURN cCodRet;
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 10/02/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CUENTAS SPEI',
'DESCRIPCION: SPL que se utiliza para dar de baja cuentas SPEI',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 04/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi y al insert emitir el from';

CREATE PROCEDURE "informix".sp_ope_buscacuentaspei(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
		RETURNING CHAR(5)  AS codret,
			CHAR(18) AS clabe,
			CHAR(20) AS tarjeta;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
   	DEFINE cClabe CHAR(18);
	DEFINE cTarjeta CHAR(20);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClabe = '';
	LET cTarjeta = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cClabe,cTarjeta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_buscacuentaspei.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cClabe,cTarjeta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cClabe,cTarjeta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF (SELECT COUNT(*) FROM bdicheq:"informix".sc_maechq AS a INNER JOIN bdicheq:sc_tarjeta AS b ON a.cuenta = b.cuenta WHERE a.cuenta = pCuenta AND b.status_tar = 'A') > 0 THEN
			
			SELECT a.cuenta_clabe, b.num_tarjeta
				INTO cClabe,cTarjeta
				FROM bdicheq:"informix".sc_maechq AS a
				INNER JOIN bdicheq:sc_tarjeta AS b ON a.cuenta = b.cuenta
				WHERE a.cuenta = pCuenta AND b.status_tar = 'A';
				
				LET iNoRegistros = iNoRegistros + 1;
				
		ELSE IF ((SELECT COUNT(*) FROM bdicheq:"informix".sc_maechq AS a WHERE a.cuenta = pCuenta) > 0 ) THEN
				
				SELECT a.cuenta_clabe, '' AS tarjeta
					INTO cClabe,cTarjeta
					FROM bdicheq:"informix".sc_maechq AS a
					WHERE a.cuenta = pCuenta;
					
					LET iNoRegistros = iNoRegistros + 1;
			 ELSE
					LET iNoRegistros = 0;
			 END IF;		
		END IF;
			
		IF (iNoRegistros = 0 ) THEN
			LET cCodRet = '00121';
			RETURN cCodRet,cClabe,cTarjeta;
		END IF;
		RETURN cCodRet,cClabe,cTarjeta;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 09/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CUENTAS SPEI',
'DESCRIPCION: SPL que busca numero de cuenta, en caso de encontrarla, devuelve cuenta clabe y numero de tarjeta',
'BD: bdicnweb',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 22/04/2016',
'DESCRIPCION: Se modifica el SPL para obtener la cuenta CLABE aunque no exista la tarjeta',
'BD: bdicnweb',
'FECHA: 25/04/2016',
'DESCRIPCION: Se modifica el SPL para corregir la busqueda de cuentas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacuentaspei(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5)  AS codret,
				  INTEGER  AS idreg,
				  CHAR(20) AS cuenta,
				  CHAR(20) AS clabe,
				  CHAR(18) AS tarjeta;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iIdReg INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE cClabe CHAR(20);
	DEFINE cTarjeta CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iIdReg = 0;
	LET cCuenta = '';
	LET cClabe = '';
	LET cTarjeta = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacuentaspei.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		END IF;
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id, cuenta, clabe, tarjeta
				INTO iIdReg,cCuenta,cClabe,cTarjeta
				FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
				WHERE id_gral = 1
				ORDER BY 1
				
		LET iNoRegistros = iNoRegistros +1;
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,iIdReg,cCuenta,cClabe,cTarjeta;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 09/02/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CUENTAS SPEI',
'DESCRIPCION: SPL que obtiene el catalogo de cuentas SPEI para su mantenimiento',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi';

CREATE PROCEDURE "informix".sp_ope_consultacuentaspei_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5)  AS codret,
			INTEGER  AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;		
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacuentaspei_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
			INTO iNoRegistros
			FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
			WHERE id_gral = 1;
							
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iNoRegistros;
		END IF;	
		RETURN cCodRet,iNoRegistros;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 09/02/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CUENTAS SPEI',
'DESCRIPCION: SPL que obtiene el total de cuentas SPEI',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi';

CREATE PROCEDURE "informix".sp_ope_consultaindicadorespei(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(5))
                RETURNING CHAR(5) AS codret,
                INTEGER     AS id_gral,
                INTEGER     AS id_indc,
                INTEGER     AS id_subindi,
                CHAR(5)         AS tipo,
                DECIMAL(7,4) AS porcentaje,
                CHAR(5)         AS rango,
                SMALLINT    AS ponderacion,
                DECIMAL(5,2)  AS porcentaje_fin;
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdGral  INTEGER;
        DEFINE iIdIndc  INTEGER;
        DEFINE iIdSubindi INTEGER;
        DEFINE cTipo CHAR(5);
        DEFINE dPorcentaje DECIMAL(7,4);
        DEFINE cRango CHAR(5);
        DEFINE sPonderacion SMALLINT;
        DEFINE dPorcentajeFin DECIMAL(5,2);
        DEFINE iNoRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdGral = 0;
        LET iIdIndc = 0;
        LET iIdSubindi = 0;
        LET cTipo = '';
        LET dPorcentaje = 0.00;
        LET cRango = '';
        LET sPonderacion  = 0;
        LET dPorcentajeFin = 0.00;
        LET iNoRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaindicadorespei.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
                
                FOREACH SELECT *
                        INTO  iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin
                        FROM bdibi@stag_ids1170:"informix".bi_ind_indpon
                        WHERE id_gral = 1 
                        AND tipo = pTipo
                        ORDER BY 2,3
                        
                LET  iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin WITH RESUME;            
                END FOREACH;
                
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing Guadalupe Angelica Hernandez Perez',
'FECHA: 09/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: INDICADORES SPEI',
'DESCRIPCION: SPL que obtiene los valores de indicadores ',
'BD: bdicnweb',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 22/04/2016',
'DESCRIPCION: Se realizo una modificacion al al corte de los campos de porcentaje y porcentaje_fin .',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi';

CREATE PROCEDURE "informix".sp_ope_insertacuentaspei(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pClabe CHAR(20), pTarjeta CHAR(18))
		RETURNING CHAR(5)  AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iId INTEGER;
	DEFINE iCuentas INTEGER;
   	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iId = 0;
	LET iCuentas = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_insertacuentaspei.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pClabe= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pTarjeta = '' THEN
			SELECT COUNT(*) 
				INTO iCuentas
				FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
				WHERE cuenta = pCuenta AND clabe = pClabe;
		ELSE
			SELECT COUNT(*) 
				INTO iCuentas
				FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
				WHERE cuenta = pCuenta AND clabe = pClabe AND tarjeta = pTarjeta;
		END IF;
		
		IF iCuentas = 0 THEN 
			SELECT MAX(id) AS id
				INTO iId
				FROM bdibi@stag_ids1170:"informix".bi_ind_catcuenta
				WHERE id_gral = 1;
		
			IF iId IS NULL THEN
				LET iId = 0;
			ELSE
				LET iId = iId + 1;
			END IF;
		
			INSERT INTO bdibi@stag_ids1170:"informix".bi_ind_catcuenta
				VALUES(1,iId,pCuenta,pClabe,pTarjeta);
			
			INSERT INTO bdibi@stag_ids1170:"informix".bi_ind_log (fecha_act,usuario,actividad)
			VALUES(CURRENT,pUsuario,"ALTA CUENTA");
	    ELSE
			LET cCodRet = '00350';
			RETURN cCodRet;
		END IF;
				 	
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 10/02/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CUENTAS SPEI',
'DESCRIPCION: SPL que se utiliza para dar de alta cuentas SPEI',
'BD: bdicnweb',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 02/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi',
'AUTOR:Guadalupe Angélica Hernández Pérez',
'FECHA: 04/08/2016',
'DESCRIPCION: Se modifica el SPL para agregarle los sinónimos haciendo referencia a la base de bdibi y al insert emitir el from';

CREATE PROCEDURE "informix".sp_consultadefporpoductodigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodSistema CHAR(2),pCodProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
				CHAR(3) AS cCodDefinicion,
				CHAR(50) AS cProdNombre;
				
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodDefinicion CHAR(3);
	DEFINE cProdNombre CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCodDefinicion = '';
	LET cProdNombre = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodDefinicion, cProdNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadefporpoductodigitalizacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCodSistema = ''  OR  pCodProducto = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodDefinicion, cProdNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodDefinicion, cProdNombre;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultadefinicionesporproducto_soc(cEmpresa, pCodSistema, pCodProducto)
		INTO cCodRetSp, cCodDefinicion, cProdNombre;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 000002 THEN -- FALTAN PARAMETROS DE ENTRADA 
			LET cCodRet = '00003';
		ELIF iCodRetSp = 000003 THEN -- FALTAN PARAMETROS DE ENTRADA
			LET cCodRet = '00003';
		ELIF iCodRetSp = 000004 THEN -- PARAMETRO CODIGO SISTEMA NO VALIDO
			LET cCodRet = '00370';
		ELIF iCodRetSp = 000005 THEN -- PARAMETRO CODIGO PRODUCTO NO VALIDO
			LET cCodRet = '00364';
		ELIF iCodRetSp = 000007 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cCodDefinicion, cProdNombre;
 
	END;
	
END PROCEDURE
DOCUMENT 'Esparza Brenis Fernando Martin',
'FECHA: 25/07/2014',
'DESCRIPCION: Consulta de definiciÃ³n del producto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaindicadorespei_pba(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(5))
                RETURNING CHAR(5) AS codret,
                INTEGER     AS id_gral,
                INTEGER     AS id_indc,
                INTEGER     AS id_subindi,
                CHAR(5)         AS tipo,
                DECIMAL(7,4) AS porcentaje,
                CHAR(5)         AS rango,
                SMALLINT    AS ponderacion,
                DECIMAL(5,2)  AS porcentaje_fin;
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdGral  INTEGER;
        DEFINE iIdIndc  INTEGER;
        DEFINE iIdSubindi INTEGER;
        DEFINE cTipo CHAR(5);
        DEFINE dPorcentaje DECIMAL(7,4);
        DEFINE cRango CHAR(5);
        DEFINE sPonderacion SMALLINT;
        DEFINE dPorcentajeFin DECIMAL(5,2);
        DEFINE iNoRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdGral = 0;
        LET iIdIndc = 0;
        LET iIdSubindi = 0;
        LET cTipo = '';
        LET dPorcentaje = 0.00;
        LET cRango = '';
        LET sPonderacion  = 0;
        LET dPorcentajeFin = 0.00;
        LET iNoRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END EXCEPTION;
                
                SET DEBUG FILE TO '/tmp/sp_ope_consultaindicadorespei.out';
                TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
                
                FOREACH SELECT *
                        INTO  iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin
                        FROM bdibi@stag_ids1170:"informix".bi_ind_indpon
                        WHERE id_gral = 1 
                        AND tipo = pTipo
                        ORDER BY 2,3
                        
                LET  iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin WITH RESUME;            
                END FOREACH;
                
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iIdGral,iIdIndc,iIdSubindi,cTipo,dPorcentaje,cRango,sPonderacion,dPorcentajeFin;
                END IF;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing Guadalupe Angelica Hernandez Perez',
'FECHA: 09/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: INDICADORES SPEI',
'DESCRIPCION: SPL que obtiene los valores de indicadores ',
'BD: bdicnweb',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 22/04/2016',
'DESCRIPCION: Se realizo una modificacion al al corte de los campos de porcentaje y porcentaje_fin .',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caj_constaccesotrasaccioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE vmensaje 	CHAR(50);
	
	LET cCodRet    = '00000';
	LET iSqlErr    = 0;
	LET cCodRetSp  = '';
	LET iCodRetSp  = 0;
	LET vmensaje   ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_constaccesotrasaccioncaja.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisuc:"informix".sp_accesodot(pSucursal)
		INTO cCodRetSp , vmensaje;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP  bdisuc:sp_accesodot";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00283';	
		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SOLICITUD DOTACION SUCURSAL',
'DESCRIPCION: SPL que valida el acceso a la transaccion por medio de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caj_genreportefaltsobrantepanacaja_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pTransaccion CHAR(4))
 RETURNING CHAR(5) AS codret,
  INTEGER AS total_registros;
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE cSucursal 	CHAR(4);
	DEFINE cNumPapeleta CHAR(16);
	DEFINE mMonto 		MONEY (16,2);
	DEFINE mMontoCSuc   MONEY (16,2);
	DEFINE mMontoDiferencia MONEY (16,2);
	DEFINE dFechaDeferencia DATE;
	DEFINE cMensaje     CHAR(50);	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cCodRetSp 			= '';
	LET iCodRetSp 			= 0;
	LET cSucursal 			= '0000';
	LET cNumPapeleta 		= '0';
	LET mMonto 				= 0;
	LET mMontoCSuc   		= 0;
	LET mMontoDiferencia 	= 0;
	LET dFechaDeferencia 	= NULL;
	LET cMensaje		 	='';	
	LET iNoRegistros 		= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_genreportefaltsobrantepanacaja_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pTransaccion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
                SELECT COUNT(*)  
                INTO  iNoRegistros
                FROM bdisuc:"informix".ss_diferenciadot_suc 
                WHERE fecha_dif between pFechaInicio and pFechaFin  
                AND  transs = pTransaccion;
        
				IF iNoRegistros = 0 THEN
                        LET cCodRet = '00017';
                END IF;
                
                RETURN cCodRet, iNoRegistros;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 28/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: FALTANTES/SOBRANTES PANAM',
'DESCRIPCION: sp que obtiene el total de registros a consultar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caj_genreportefaltsobrantepanacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pTransaccion CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5) AS codret,
		CHAR(4) AS sucursal,
		CHAR(16) AS no_papeleta, 
		MONEY (16,2) AS importe, 
		MONEY (16,2) AS importe_sucursal,
		MONEY (16,2) AS importe_diferencia,
		DATE AS fecha;
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE cSucursal 	CHAR(4);
	DEFINE cNumPapeleta CHAR(16);
	DEFINE mMonto 		MONEY (16,2);
	DEFINE mMontoCSuc   MONEY (16,2);
	DEFINE mMontoDiferencia MONEY (16,2);
	DEFINE dFechaDeferencia DATE;
	DEFINE cMensaje     CHAR(50);	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cSucursal = '0000';
	LET cNumPapeleta = '0';
	LET mMonto 		= 0;
	LET mMontoCSuc   = 0;
	LET mMontoDiferencia = 0;
	LET dFechaDeferencia = NULL;
	LET cMensaje ='';	
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_genreportefaltsobrantepanacaja.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pTransaccion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH		
			EXECUTE PROCEDURE bdisuc:"informix".sp_rep_faltsob_pana2(pFechaInicio, pFechaFin, pTransaccion,pRegistros, pRecuperacion)
			INTO  cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia,cCodRetSp,cMensaje
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisuc:sp_rep_faltsob_pana2";
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
            RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia WITH RESUME;
		END FOREACH;

		-- colocar cod d error 17 y 1001
	    IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
			RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
	    END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SOLICITUD DOTACION SUCURSAL',
'DESCRIPCION: SPL que genera el reporte de los faltantes y sobrantes de panamericana',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caj_validasucursalcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(30) AS nombreSucursal;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE vmensaje 	CHAR(50);
	DEFINE cNombreSucursal   CHAR(30);
	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;
	LET cCodRetSp	= '';
	LET iCodRetSp 	= 0;
	LET vmensaje	= '';
	LET cNombreSucursal='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreSucursal;
		END EXCEPTION;
		
		 -- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_validasucursalcaja.out';
		 -- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisuc:"informix".sp_valida_suc2(pSucursal)
		INTO cCodRetSp ,vmensaje,cNombreSucursal;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisuc:sp_valida_suc2";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00833';
		END IF;		
		RETURN cCodRet,cNombreSucursal;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SOLICITUD DOTACION SUCURSAL',
'DESCRIPCION: SPL que validad si existe la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadomicilioactualcte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pTipoDir CHAR(1))
RETURNING CHAR(5) AS codRetorno, -- Codigo de Retorno
	CHAR(20) AS numCliente, --Número de Cliente
	CHAR(20) AS numCredito, --Numero de Credito
	CHAR(104) AS nomCliente, --Nombre del Cliente
	CHAR(2) AS estado, --Estado
	CHAR(30) AS nomEstado, --Nombre del Estado
	CHAR(3) AS ciudad, --Ciudad
	SMALLINT AS numCiudad, --Numero de Ciudad
	CHAR(60) AS nomCiudad, --Nombre de Ciudad
	SMALLINT AS ciudadCoppel, --Ciudad Coppel
	INTEGER AS numColonia, --Numero de Colonia
	CHAR(32) AS nomColonia, --Nombre de Colonia
	CHAR(27) AS municipio, --Municipio
	INTEGER AS numCalle, --Numero de Calle
	CHAR(30) AS nomCalle, --Nombre de Calle
	SMALLINT AS edificio, --Edificio
	CHAR(6) AS departamento, --Departamento
	CHAR(5) AS codPostal, --Codigo Postal
	CHAR(80) AS observaciones, --Observaciones
	CHAR(10) AS numExterior, --Numero Exterior
	CHAR(10) AS numInterior, --Numero Interior
	CHAR(30) AS nomEdificio; -- Nombre de Edificio
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNomCliente CHAR(104);
	DEFINE cEstado CHAR(2);
	DEFINE cNomEstado CHAR(30);
	DEFINE cCiudad CHAR(3);
	DEFINE sNumCiudad SMALLINT;
	DEFINE cNomCiudad CHAR(60);
	DEFINE sCiudadCoppel SMALLINT;
	DEFINE iNumColonia INTEGER;
	DEFINE cNomColonia CHAR(32);
	DEFINE cMunicipio CHAR(27);
	DEFINE iNumCalle INTEGER;
	DEFINE cNomCalle CHAR(30);
	DEFINE sEdificio SMALLINT;
	DEFINE cDepartamento CHAR(6);
	DEFINE cCodPostal CHAR(5);
	DEFINE cObservaciones CHAR(80);
	DEFINE cNumExterior CHAR(10);
	DEFINE cNumInterior CHAR(10);
	DEFINE cNomEdificio  CHAR(30);
	DEFINE cEmpresa CHAR(3);

	LET     cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente = '';
	LET cNumCredito = '';
	LET cNomCliente = '';
	LET cEstado = '';
	LET cNomEstado = '';
	LET cCiudad = '';
	LET sNumCiudad = 0;
	LET cNomCiudad = '';
	LET sCiudadCoppel = 0;
	LET iNumColonia = 0;
	LET cNomColonia = '';
	LET cMunicipio = '';
	LET iNumCalle = 0;
	LET cNomCalle = '';
	LET sEdificio = 0;
	LET cDepartamento = '';
	LET cCodPostal = '';
	LET cObservaciones = '';
	LET cNumExterior = '';
	LET cNumInterior = '';
	LET cNomEdificio  = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadomicilioactualcte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pNumCte = '' AND pNumCredito = '') OR pTipoDir = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END IF;
		
		IF pTipoDir NOT IN ('1', '2', '3') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END IF;
		
		 -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel,
				iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, 
				cNumExterior, cNumInterior, cNomEdificio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerdomiciliocliente(cEmpresa, pNumCte, pNumCredito, pTipoDir) INTO cCodRetSp, 
		cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel,
		iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
		cNumInterior, cNomEdificio     
		
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'Error en la ejeución del SP prodcutivo sp_obtenerdomiciliocliente ('||cCodRetSp::INTEGER||')';
			END IF;
			 
			IF cCodRetSp = '000' THEN
				LET cCodRet = '00000';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;                                       
			END IF; 
			IF cCodRetSp = '001' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad,
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			IF cCodRetSp = '002' THEN
				LET cCodRet = '00022';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad,
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			IF cCodRetSp = '003' THEN
				LET cCodRet = '00046';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			
			IF pTipoDir = '1' AND cCodRetSp = '004' THEN
				LET cCodRet = '00066';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			ELIF pTipoDir = '2' AND cCodRetSp = '004' THEN
				LET cCodRet = '00080';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;   
			ELIF pTipoDir = '3' AND cCodRetSp = '004' THEN
				LET cCodRet = '00841';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;     													
			END IF;

		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S Sandra Cano',
'FECHA: 09/08/2016',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MANTENIMIENTO DOMICILIOS CLIENTE',
'DESCRIPCION: SPL que consulta los domicilios del cliente. Se modifica para agregar tipo domicilio 3, envio de token',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_actualizanombrexmlfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pNomXml CHAR(40))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomXml CHAR(40);	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomXml = '';
	LET iNoRegistros =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_actualizanombrexmlfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNomXml = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		-- ACTUALIZACION DEL NOMBRE DE ARCHIVO
		UPDATE  bdilide:sl_ftc_prm
		SET valor = pNomXml
		WHERE cve_param = 5
		AND valor_param = 3;
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');		
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		RETURN cCodRet,iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio ',
'FECHA: 09/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza actualizacion de nombre de xml creado en la funcionalidad de Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_bitacoreogenreportesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_bitacoreogenreportesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pBandera = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pBandera = '1' THEN 		
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'GENERACION DE REPORTE');
			RETURN cCodRet;
		ELIF pBandera = '2' THEN
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'GENERACION DE XML');
			RETURN cCodRet;
		ELIF pBandera = '3' THEN
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'VALIDACION DE XSD');
			RETURN cCodRet;		
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
	END;	
END PROCEDURE		
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que bitacorea las actividades de la funcionalidad de generacion de reporte Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturaclientesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pNumCliente CHAR(20), pCuenta CHAR(20), pTipoReporte CHAR(1))
                RETURNING CHAR(5) AS codret;            
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cRazonSocial CHAR(60);
        DEFINE cApellPaterno CHAR(26);
        DEFINE cApellMaterno CHAR(26);
        DEFINE cNombre1 CHAR(26);
        DEFINE cNombre2 CHAR(26);
        DEFINE cCalle CHAR(40);
        DEFINE cNumIntCalle CHAR(10);
        DEFINE cNumExtCalle CHAR(10);
        DEFINE cColonia CHAR(32);
        DEFINE cDelegacion CHAR(27);
        DEFINE cCodPostal CHAR(5);
        DEFINE cPais CHAR(3);
        DEFINE cCiudad CHAR(30);
        DEFINE cRfc CHAR(13);
        DEFINE dFechaNac CHAR(10);  
        DEFINE cCuenta  CHAR(20);
        DEFINE  mMonto MONEY(18,2);
        DEFINE cSumaProm MONEY (18,2);
        DEFINE cMesesActivo INTEGER;
        DEFINE mInteresPagado MONEY(16,2);
        DEFINE cEjercicio CHAR(4);
        DEFINE cTipoPersona CHAR(2);
        DEFINE cCRazonSocial CHAR(60);
        DEFINE cCApellPaterno CHAR(26);
        DEFINE cCApellMaterno CHAR(26);
        DEFINE cCNombre1 CHAR(26);
        DEFINE cCNombre2 CHAR(26);
        DEFINE cCCalle CHAR(40);
        DEFINE cCNumIntCalle CHAR(10);
        DEFINE cCNumExtCalle CHAR(10);
        DEFINE cCColonia CHAR(32);
        DEFINE cCDelegacion CHAR(27);
        DEFINE cCCodPostal CHAR(5);
        DEFINE cCPais CHAR(3);
        DEFINE cCCiudad CHAR(30);
        DEFINE cCRfc CHAR(13);
        DEFINE dCFechaNac CHAR(10); 
        DEFINE cCCuenta  CHAR(20);
        DEFINE mCMonto MONEY(18,2);
        DEFINE mCInteresPagado MONEY(18,2);
        DEFINE iExiste INTEGER;
        DEFINE iComplementaria INTEGER;
        DEFINE sConsecutivo SMALLINT;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cRazonSocial = '';
        LET cApellPaterno = '';
        LET cApellMaterno = '';
        LET cNombre1 = '';
        LET cNombre2 = '';
        LET cCalle = '';
        LET cNumIntCalle = '';
        LET cNumExtCalle = '';
        LET cColonia = '';
        LET cDelegacion = '';
        LET cCodPostal = '';
        LET cPais = ''; 
        LET cCiudad = '';
        LET cRfc = '';
        LET dFechaNac = '';
        LET cCuenta = '';
        LET mMonto = 0.00;
        LET cSumaProm = 0.00;
        LET cMesesActivo = 0;
        LET mInteresPagado = 0.00;
        LET cEjercicio  = '';
        LET cTipoPersona = '';
        LET cCRazonSocial = '';
        LET cCApellPaterno = '';
        LET cCApellMaterno = '';
        LET cCNombre1 = '';
        LET cCNombre2 = '';
        LET cCCalle = '';
        LET cCNumIntCalle = '';
        LET cCNumExtCalle = '';
        LET cCColonia = '';
        LET cCDelegacion = '';
        LET cCCodPostal = '';
        LET cCPais = '';
        LET cCCiudad = '';
        LET cCRfc = '';
        LET dCFechaNac = '';    
        LET cCCuenta  = '';
        LET mCMonto = 0.00;
        LET mCInteresPagado = 0.00;
        LET iExiste = 0;
        LET iComplementaria = 0;
                LET sConsecutivo = 0;
        
        BEGIN
				ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                ON EXCEPTION IN (-268)
                        LET cCodRet = '00284';
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_cap_capturaclientesfatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = ''   THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                SELECT TRIM(razon_social),  TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno) , TRIM(apell_materno), TRIM(tpo_persona)
                INTO cRazonSocial,  cNombre1, cNombre2, cApellPaterno, cApellMaterno, cTipoPersona
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = pNumCliente;
                
                SELECT TRIM(numerointcalle), TRIM(numeroextcalle)
                INTO cNumIntCalle, cNumExtCalle
                FROM bdinteg:"informix".si_direcciones_actual
                WHERE numcte = pNumCliente
                AND tipo_dir  = 1;  

				SELECT TRIM(c.nombrecalle)
                INTO cCalle
                FROM bdinteg:"informix".si_direcciones_actual d 
				INNER JOIN bdinteg:"informix".si_catcalles AS c
				ON d.numerocalle = c.numerocalle
                WHERE numcte = pNumCliente  
                AND tipo_dir  = 1; 
				               		
				SELECT  TRIM(d.nombrezona), TRIM(e.nombreciudad)
				INTO cColonia, cDelegacion
				FROM bdinteg:si_direcciones_actual AS a, bdinteg:si_catzonas AS d, bdinteg:si_catciudades AS e
				WHERE a.numerociudad = d.numerociudad
				AND a.numerocolonia = d.numerocolonia
				AND d.numerociudad = e.numerociudad
				AND a.tipo_dir = 1
				and a.numcte = pNumCliente;
				
                SELECT TRIM(cod_postal)
                INTO cCodPostal
                FROM bdinteg:"informix".si_direcciones_actual
                WHERE numcte = pNumCliente
                AND tipo_dir  = 1;              
                
                SELECT TRIM(p.nombre)
                INTO cPais
                FROM bdinteg:"informix".si_paises p
                INNER JOIN  bdinteg:"informix".si_direcciones_actual a ON p.pais = a.pais
                WHERE  a.numcte =  pNumCliente
                AND a.tipo_dir = 1;
                
                SELECT  TRIM(g.nombre)as estado
				INTO cCiudad
				FROM bdinteg:si_direcciones_actual AS a, 
				bdinteg:si_estados AS g
				WHERE a.tipo_dir = 1
				AND a.estado = g.estado
				and a.numcte = pNumCliente;

				IF cTipoPersona = '01' THEN
                        SELECT TRIM(rfc), fecha_nac
                        INTO  cRfc, dFechaNac
                        FROM bdinteg:"informix".si_cliente sc 
                        INNER JOIN bdinteg:"informix".si_ctepf cpf ON sc.numcte = cpf.numcte    
                        WHERE sc.numcte = pNumCliente;
                ELIF cTipoPersona = '02' THEN
                        SELECT TRIM(rfc), fecha_constitct
                        INTO  cRfc, dFechaNac
                        FROM bdinteg:"informix".si_cliente sc 
                        INNER JOIN bdinteg:"informix".si_ctepm cpm ON sc.numcte = cpm.numcte    
                        WHERE sc.numcte = pNumCliente;
                END IF;
                                
                SELECT (sdo_prom1 + sdo_prom2 + sdo_prom3 + sdo_prom4 + sdo_prom5 + sdo_prom6 + sdo_prom7 + sdo_prom8 + sdo_prom9 + sdo_prom10 + sdo_prom11 + sdo_prom12)
                INTO cSumaProm
                FROM bdicheq:"informix".sc_retenisr 
                WHERE num_cte = pNumCliente AND ejercicio = pEjercicio AND cuenta =  pCuenta;
                
                SELECT COUNT(*) AS cMesesActivo
                INTO cMesesActivo
                        FROM (
                        SELECT sdo_prom1 as meses, 'sdo_prom1' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union 
                        SELECT sdo_prom2, 'sdo_prom2' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom3, 'sdo_prom3' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom4, 'sdo_prom4' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom5, 'sdo_prom5' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom6, 'sdo_prom6' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom7, 'sdo_prom7' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom8, 'sdo_prom8' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom9, 'sdo_prom9' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom10, 'sdo_prom10' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom11, 'sdo_prom11' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom12, 'sdo_prom12' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta)
                        WHERE meses <> 0;
                        
                        LET mMonto = cSumaProm / cMesesActivo;
                                
                        SELECT  interes_pagado
                        INTO mInteresPagado
                        FROM bdicheq:"informix".sc_retenisr 
						WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta;
                                
                        SELECT consecutivo
                        INTO sConsecutivo
                        FROM bdilide:"informix".sl_ftc_cns                              
                        WHERE ejercicio = pEjercicio
                        AND tipo_rpt = pTipoReporte;
                        IF sConsecutivo IS NULL THEN 
                            LET sConsecutivo = 1;
                        END IF; 
                                
				IF (SELECT COUNT(num_cliente) FROM bdilide:"informix".sl_ftc_cte WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio)>0 THEN
                        LET iExiste = 1;
                END IF;
                
                IF (SELECT COUNT(num_cliente) FROM bdilide:"informix".sl_ftc_det WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio)>0 THEN
                        LET iExiste = 1;
                        SELECT razon_soc, nombre1, nombre2, apell_paterno, apell_materno, nom_calle, num_int, num_ext, colonia, delegacion, cod_postal, pais,ciudad, rfc, fecha_nac, cuenta, monto_cta, interes_pagado
                        INTO cCRazonSocial, cCNombre1,cCNombre2,cCApellPaterno,cCApellMaterno,cCCalle,cCNumIntCalle,cCNumExtCalle,cCColonia,cCDelegacion,cCCodPostal,cCPais,cCCiudad,cCRfc,dCFechaNac,cCCuenta, mCMonto, mCInteresPagado
                        FROM bdilide:"informix".sl_ftc_det
                        WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                        
                        IF (TRIM(cRazonSocial) <> TRIM(cCRazonSocial) OR TRIM(cApellPaterno) <> TRIM (cCApellPaterno) OR TRIM(cApellMaterno) <> TRIM(cCApellMaterno) OR  TRIM(cNombre1) <> TRIM(cCNombre1) OR TRIM(cNombre2) <> TRIM(cCNombre2) OR TRIM(cCalle) <> TRIM(cCCalle) OR TRIM(cNumIntCalle) <> TRIM(cCNumIntCalle) OR  TRIM(cNumExtCalle) <> TRIM(cCNumExtCalle) OR TRIM(cColonia) <> TRIM(cCColonia) OR TRIM(cDelegacion) <> TRIM(cCDelegacion) OR TRIM(cCodPostal) <> TRIM(cCCodPostal) OR TRIM(cPais) <> TRIM(cCPais) OR TRIM(cCiudad) <> TRIM(cCCiudad) OR TRIM(cRfc) <> TRIM(cCRfc) OR dFechaNac<> dCFechaNac OR mMonto <> mCMonto OR mInteresPagado <> mCInteresPagado OR TRIM(cCCuenta) <> TRIM(pCuenta)) THEN
                                LET iComplementaria = 1;                        
                        END IF;                        
                        IF (iComplementaria = 1 AND pTipoReporte = 'C') THEN
                                UPDATE bdilide:"informix".sl_ftc_cte
                                SET cuenta = pCuenta, tipo_rep = 'C', cns_rep = sConsecutivo
                                WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                                
                                UPDATE bdilide:"informix".sl_ftc_det
                                SET razon_soc = cRazonSocial, nombre1 = cNombre1, nombre2 = cNombre2, apell_paterno = cApellPaterno, apell_materno = cApellMaterno, nom_calle = cCalle, num_int = cNumIntCalle, num_ext = cNumExtCalle, colonia = cColonia, delegacion = cDelegacion, cod_postal = cCodPostal, pais = cPais, ciudad = cCiudad, rfc = cRfc, fecha_nac = dCFechaNac, cuenta = pCuenta, monto_cta = mMonto, interes_pagado = mInteresPagado
                                WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                        ELSE
                                LET cCodRet = '00293';
                                RETURN cCodRet;
                        END IF;                                
                END IF;
                                        
                IF iExiste = 0  THEN 
                        IF pTipoReporte = 'N' THEN
							INSERT INTO bdilide:"informix".sl_ftc_cte(ejercicio, num_cliente, cuenta, tipo_rep, cns_rep, fecha_cap, usuario)
							VALUES (pEjercicio, pNumCliente, pCuenta, pTipoReporte, 0, CURRENT, pUsuario);
                        ELIF pTipoReporte = 'C' THEN 
                            INSERT INTO bdilide:"informix".sl_ftc_cte(ejercicio, num_cliente, cuenta, tipo_rep, cns_rep, fecha_cap, usuario)
							VALUES (pEjercicio, pNumCliente, pCuenta, pTipoReporte, sConsecutivo, CURRENT, pUsuario);
                        END IF;
                        INSERT INTO bdilide:"informix".sl_ftc_det(num_cliente, razon_soc, nombre1, nombre2, apell_paterno, apell_materno, nom_calle, num_int, num_ext,colonia, delegacion, cod_postal, pais, ciudad, rfc, fecha_nac, cuenta, monto_cta, interes_pagado, ejercicio, usuario, fecha_insert)               
                        VALUES (pNumCliente, cRazonSocial, cNombre1, cNombre2, cApellPaterno, cApellMaterno, cCalle, cNumIntCalle, cNumExtCalle, cColonia, cDelegacion, cCodPostal, cPais, cCiudad,  cRfc, dFechaNac, pCuenta, mMonto, mInteresPagado, pEjercicio, pUsuario, CURRENT);
                END IF;
                                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00282';
                        RETURN cCodRet;
                END IF;         
                RETURN cCodRet;
        END;    
END PROCEDURE           
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 08/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA',
'DESCRIPCION:SPL que inserta los clientes fatca.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 25/05/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue del domicilio de los Clientes Persona Fisica.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 14/06/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue de la Colonia y Municipio de los Clientes Persona Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturactparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2),pTipoParam INTEGER, pValorAsociado INTEGER, pValorParam CHAR(5), pValor CHAR(200), pDesValor CHAR(200))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp 		CHAR(5);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cUltimoValor INTEGER;
	DEFINE cNewValor   CHAR(20);
	DEFINE sCveParam    SMALLINT;               
	DEFINE cValorParam  CHAR(5);
	DEFINE cValor       CHAR(200);
	DEFINE cDescValor   CHAR(200);
	DEFINE cUsuarioAct  CHAR(8);
	DEFINE dFechaAct    DATETIME YEAR TO SECOND;
	DEFINE cValorAsociadoPadre CHAR(5);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cUltimoValor  = 0;
	LET cNewValor     = 0;
	LET sCveParam    = 0;               
	LET cValorParam  = '';
	LET cValor       = '';
	LET cDescValor   = '';
	LET cUsuarioAct  = '';
	LET dFechaAct    = '';
	LET cValorAsociadoPadre = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_capturactparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = ''  OR pTipoParam IS NULL OR pValor = '' OR pDesValor = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE "informix".sp_cap_clasificadorparametrosfatca(pUsuario, pIdFuncion, pTipoParam, pValorAsociado)
		INTO cCodRetSp,cUltimoValor, cNewValor;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cap_clasificadorparametrosfatca';
			END IF;
		
			
		--REALIZA ALTA
		IF pBandera = '1'  THEN 		
			IF pTipoParam  = 1 OR pTipoParam = 5 THEN 
				SELECT COUNT (*)
				INTO iNoRegistros
				FROM bdilide:"informix".sl_ftc_prm
				WHERE cve_param = pTipoParam
				AND UPPER(TRIM(valor)) = UPPER(TRIM(pValor))
				AND UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor));
				
				IF iNoRegistros > 0 THEN 
					LET cCodRet = '00004';
					RETURN cCodRet;
				END IF;
				
				IF(SELECT COUNT(*) FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)) OR UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor))) = 0 THEN				
					INSERT INTO bdilide:"informix".sl_ftc_prm(cve_param, valor_param, valor, desc_valor, usuario_act, fecha_act)
					VALUES (pTipoParam, cNewValor, pValor, pDesValor,pUsuario, CURRENT);			
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cNewValor, '', '', pUsuario, 'INSERCION DE REGISTRO');				
				ELSE
					LET cCodRet = '00520';
					RETURN cCodRet;		
				END IF;				
			ELSE 				
				IF(SELECT COUNT(*) FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)) OR UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor))) = 0 THEN				
					INSERT INTO bdilide:"informix".sl_ftc_prm(cve_param, valor_param, valor, desc_valor, usuario_act, fecha_act)
					VALUES (pTipoParam, cNewValor, pValor, pDesValor,pUsuario, CURRENT);			
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cNewValor, '', '', pUsuario, 'INSERCION DE REGISTRO');
				ELSE 				
					LET cCodRet = '00520'; 
					RETURN cCodRet;		
				END IF;			
			END IF;		
			
		--REALIZA  MODIFICACION
		ELIF pBandera = '2' THEN 		
			IF pTipoParam >= 2 AND pTipoParam <= 4 THEN 			
		
				SELECT valor, desc_valor
				INTO cValor, cDescValor
				FROM bdilide:"informix".sl_ftc_prm
				WHERE cve_param = pTipoParam 	
				AND  valor_param  = pValorParam;
				
				SELECT valor_param, ((LEFT(valor_param,LENGTH(valor_param) -  CHARINDEX(".",valor_param))))
				INTO  cValorParam, cValorAsociadoPadre
				FROM bdilide:"informix".sl_ftc_prm 
				WHERE cve_param = pTipoParam
				AND valor_param = pValorParam;
				
				IF( pValor <> cValor) THEN 
					IF NOT EXISTS(SELECT valor FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)))  THEN 
					
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   valor = pValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');	
						
					ELSE 
						LET cCodRet = '00520';			
						RETURN cCodRet;
					END IF;
				END IF;	

				IF( pDesValor <> cDescValor) THEN 
					IF NOT EXISTS(SELECT desc_valor FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor)))  THEN 
					
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   desc_valor = pDesValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');	
			
					ELSE 
						LET cCodRet = '00520';			
						RETURN cCodRet;
					END IF;
				END IF;

				IF (pValorAsociado <> cValorAsociadoPadre )  THEN 					
				
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   valor_param  = cNewValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cValorParam, 'valor_param', pUsuario, 'ACTUALIZACION DE REGISTRO');	
				
				END IF;
			ELIF pTipoParam =  5 THEN 
				UPDATE bdilide:"informix".sl_ftc_prm 
					SET    valor = pValor,  desc_valor = pDesValor
					WHERE cve_param = pTipoParam
					AND  valor_param  = pValorParam;
				INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, pTipoParam, cValorParam, cValorParam, 'valor_param', pUsuario, 'ACTUALIZACION DE REGISTRO');				
				
			END IF;	
		END IF;			

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 26/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que inserta  de nuevos parametros y actualizacion de parametros existentes para la generacion de reporte fatca.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 13/06/2016',
'DESCRIPCION:Se realiza la modificación de la actualizacion de campos en tabla de fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogocanalfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                SMALLINT  AS valor_param,
                CHAR(200)   AS valor;
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE sValorParam SMALLINT;
        DEFINE cValor CHAR(200);
        DEFINE iNoRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET sValorParam = 0;
        LET cValor  = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sValorParam,cValor;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogocanalfatca.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sValorParam,cValor;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, sValorParam,cValor;
			END IF;
			
			FOREACH 
				SELECT p.valor_param, UPPER(valor)
					INTO  sValorParam,cValor
				FROM bdilide:"informix".sl_ftc_prm p
					WHERE p.cve_param=1
					ORDER BY 1 ASC
					
			LET  iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, sValorParam,cValor WITH RESUME;            
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sValorParam,cValor;
			END IF;
	END;		
END PROCEDURE
DOCUMENT 'AUTOR:Martha Salgado Mendoza ',
'FECHA: 27/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA',
'DESCRIPCION: SPL que obtiene los valores para el tipo de parametro CANAL',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogoclasificacionfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS c_vparam,
			CHAR(200) AS c_desc_vparam;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cCvParam CHAR(5);
	DEFINE cDescVParam CHAR(200);
	DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCvParam = '';
	LET cDescVParam = '';
	LET iNoRegistros = 0;	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCvParam, cDescVParam ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogoclasificacionfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCvParam, cDescVParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCvParam, cDescVParam;
		END IF;
		
		FOREACH SELECT c_vparam, c_desc_vparam
			INTO cCvParam, cDescVParam
			FROM bdilide:sl_ftc_clas_cat
			ORDER BY 1
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cCvParam, cDescVParam WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet,  cCvParam, cDescVParam; 
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 10/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de catalogos clasificacion Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogotipoparamfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			      INTEGER AS cve_param,
				  CHAR(100) AS desc_param;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCveParam INTEGER;
	DEFINE cDescParam CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCveParam =0; 
	LET cDescParam ='';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveParam, cDescParam ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogotipoparamfatca.out';
		--TRACE ON;
		
		-- VALIDACION DE USUARIOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iCveParam, cDescParam ;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iCveParam, cDescParam ;
		END IF;

		FOREACH SELECT cve_param, desc_param
			INTO iCveParam, cDescParam
			FROM bdilide:sl_ftc_cat
			ORDER BY 1
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iCveParam, cDescParam WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCveParam, cDescParam; 
		END IF;		
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de catalogos tipo parametro Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_clasificadorparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParam INTEGER, pValorAsociado INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER AS ultimo_valor,
		CHAR(20) AS new_valor;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUltimoValor INTEGER;
	DEFINE cNewValor   CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cUltimoValor  = 0;
	LET cNewValor     = 0;
		
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUltimoValor, cNewValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_clasificadorparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		IF pTipoParam >= 2 AND pTipoParam <= 4 THEN 
		
			SELECT ultimo_val, LEFT(ultimo_val,CHARINDEX(".",ultimo_val)) || (SUBSTRING(ultimo_val FROM CHARINDEX(".",ultimo_val)+1 FOR ( LENGTH(ultimo_val)-CHARINDEX(".",ultimo_val))) + 1)::DECIMAL(9,0) AS nuevo_valor
			INTO cUltimoValor, cNewValor			
			FROM
				(SELECT MAX(valor_param) AS ultimo_val
				FROM bdilide:'informix'.sl_ftc_prm
				WHERE cve_param = pTipoParam AND valor_param >= pValorAsociado  AND valor_param < pValorAsociado + 1);
						
			IF cUltimoValor IS NULL THEN 
				LET cNewValor = pValorAsociado;
			ELIF cUltimoValor::INTEGER > 0  AND cNewValor IS NULL THEN
				LET cNewValor = cUltimoValor + .1;
			END IF;
			
			RETURN cCodRet, cUltimoValor, cNewValor;
		
		ELIF pTipoParam = 1 OR pTipoParam = 5 THEN
		
			SELECT ultimo_val, (ultimo_val + 1) AS nuevo_valor 
			INTO cUltimoValor, cNewValor
			FROM 
				(SELECT MAX(valor_param::INTEGER) AS ultimo_val
				FROM bdilide:'informix'.sl_ftc_prm
				WHERE  cve_param = pTipoParam);
			
			IF cUltimoValor IS NULL  THEN 
				LET cNewValor =  1;
				RETURN cCodRet, cUltimoValor, cNewValor;
			END IF;			
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		RETURN cCodRet, cUltimoValor, cNewValor;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 025/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que obtiene la clasificacion dependiendo el tipo de parametro requerido.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consconsecutivonormalfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),  pEjercicio SMALLINT)
		RETURNING CHAR(5) AS codret,
		SMALLINT AS consecutivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sConsecutivo SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sConsecutivo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sConsecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consconsecutivonormalfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		SELECT consecutivo 
		INTO sConsecutivo 
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio
		AND tipo_rpt = 'N';
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		RETURN cCodRet, sConsecutivo;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que consulta el numero consecutivo del tipo de reporte normal para el archivo xml de Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consdtalleclientefatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cliente,
		CHAR(150)       AS nombre,
		CHAR(20)        AS num_cuenta,
		DECIMAL(16,2)   AS saldo,
		CHAR (1)        AS tipo_repeporte;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCte  CHAR(20);
	DEFINE cNombre      CHAR(150);
	DEFINE cNumCuenta   CHAR(20);
	DEFINE dSaldo   DECIMAL(16,2);
	DEFINE cTipoReporte     CHAR(1);
	DEFINE sConsecutivoRpt  SMALLINT;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cActividad CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCte= '';
	LET cNombre     = '';
	LET cNumCuenta  = '';
	LET dSaldo              =0.00;
	LET cTipoReporte = '';
	LET sConsecutivoRpt = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cActividad = 'CONSULTA FATCA';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consdtalleclientefatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT MAX(cns_rep)
		INTO sConsecutivoRpt
		FROM bdilide:"informix".sl_ftc_cte
		WHERE ejercicio = pEjercicio
		AND tipo_rep = pTipoReporte;	
			
		IF (pTipoReporte = '' ) THEN                 
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
					CASE WHEN (NVL(apell_paterno,"") || NVL(apell_materno,"") || NVL(nombre1,"") || NVL(nombre2,"")) != "" THEN TRIM(NVL(apell_paterno,"")) || " "|| TRIM(NVL(apell_materno,"")) || " " || TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,""))
                    ELSE TRIM(razon_soc)  END AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
					INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
					FROM bdilide:"informix".sl_ftc_cte a
						INNER JOIN  bdilide:"informix".sl_ftc_det b     ON a.num_cliente = b.num_cliente
					WHERE a.ejercicio = b.ejercicio
						AND a.ejercicio = pEjercicio                            
					ORDER BY a.num_cliente ASC, a.cuenta ASC
			
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
			END FOREACH;
						
		ELSE 
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
					CASE WHEN (NVL(apell_paterno,"") || NVL(apell_materno,"") || NVL(nombre1,"") || NVL(nombre2,"")) != "" THEN TRIM(NVL(apell_paterno,"")) || " "|| TRIM(NVL(apell_materno,"")) || " " || TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,""))
                    ELSE TRIM(razon_soc)  END AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
					INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
					FROM bdilide:"informix".sl_ftc_cte a
						INNER JOIN  bdilide:"informix".sl_ftc_det b     ON a.num_cliente = b.num_cliente
					WHERE a.ejercicio = b.ejercicio
						AND a.ejercicio = pEjercicio
						AND a.tipo_rep = pTipoReporte
						AND a.cns_rep = sConsecutivoRpt
					ORDER BY a.num_cliente ASC, a.cuenta ASC                
			
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
			END FOREACH;
		END IF;
												   
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;         
	
	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca.',
'AUTOR: M.D.S Sandra Cano',
'FECHA: 27/05/2016',
'DESCRIPCION: Modificacion del SPL para desplegar el la razon social para los clientes Persona Moral.',
'AUTOR: M.D.S Sandra Cano',
'FECHA: 02/06/2016',
'DESCRIPCION: Modificacion del SPL para despliegue correcto del nombre de Cliente Persona Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consordenxsdfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		SMALLINT AS cve_param,
		CHAR(5) AS valor_param,
		CHAR(200) AS valor,
		CHAR(200) AS desc_valor,	
		CHAR(8) AS usuario_act,
		DATETIME YEAR TO SECOND  AS fecha_act;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sCveParam	SMALLINT;
	DEFINE  cValorParam	CHAR(5);
	DEFINE  cValor	    CHAR(200);
	DEFINE  cDescValor	CHAR(200);
	DEFINE  cUsuarioAct	CHAR(8);
	DEFINE  dFechaAct	DATETIME YEAR TO SECOND;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sCveParam	= 0;
	LET cValorParam	= '';
	LET cValor	    = '';
	LET cDescValor	= '';
	LET cUsuarioAct	= '';
	LET dFechaAct	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consordenxsdfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;
		
		FOREACH SELECT  *
			INTO sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct
			FROM bdilide:'informix'.sl_ftc_prm
			WHERE cve_param = 6
			ORDER BY 2
						
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene el orden de XSD Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_constintercambioparamfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pBandera CHAR(1), pValorParam CHAR(5), pValor CHAR(200),pDesValor CHAR(200))
        RETURNING CHAR(5) AS codret,
            CHAR(5)    AS valor_param,
            CHAR(5)    AS valor_param1,
            CHAR(200)  AS valor,
            CHAR(200)  AS valor1,
            CHAR(200)  AS des_valor,
            CHAR(200)  AS des_valor1;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cValorParam   CHAR(5);
        DEFINE cValorParam1  CHAR(5);
        DEFINE cValor        CHAR(200);
        DEFINE cValor1       CHAR(200);
        DEFINE cDescValor    CHAR(200);
        DEFINE cDescValor1    CHAR(200);
        DEFINE iNoRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cValorParam  = '';
        LET cValorParam1  = '';
        LET cValor       = '';
        LET cValor1       = '';
        LET cDescValor   = '';
        LET cDescValor1   = '';
        LET iNoRegistros = 0;

        BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END EXCEPTION;
			
			ON EXCEPTION IN (-703)
				LET cCodRet = '00281';
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END EXCEPTION;	

			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_constintercambioparamfatca.out';
			--TRACE ON;

			IF pUsuario = '' OR pIdFuncion = '' OR pBandera = ''  OR  pValorParam = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END IF;

			IF pBandera = 1 THEN  -- intercambio de valor parametro
					SELECT valor, valor_param
						INTO  cValor, cValorParam
                    FROM bdilide:'informix'.sl_ftc_prm
						WHERE UPPER(valor) = UPPER(TRIM(pValor))
						AND cve_param = 1;

                    SELECT valor, valor_param
						INTO  cValor1, cValorParam1
                    FROM bdilide:'informix'.sl_ftc_prm
						WHERE valor_param = pValorParam
						AND cve_param = 1;

                    UPDATE  bdilide:'informix'.sl_ftc_prm
                        SET  valor = cValor
                        WHERE cve_param = 1
                        AND valor_param = cValorParam1;

                    UPDATE bdilide:'informix'.sl_ftc_prm
                        SET  valor = cValor1
                        WHERE cve_param = 1
                        AND valor_param = cValorParam;
							
					INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
						VALUES (CURRENT, 1, cValorParam, cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
					INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
						VALUES (CURRENT, 1, pValorParam, cValor1, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						
                ELIF pBandera = 2 THEN  -- intercambio de canal

					SELECT COUNT(*) AS buscaparam
					INTO iNoRegistros
					FROM bdilide:'informix'.sl_ftc_prm
					where desc_valor = UPPER(TRIM(pDesValor))
					AND cve_param = 1;

                    IF (iNoRegistros = 1) THEN

                        SELECT  valor_param,  desc_valor
							INTO   cValorParam, cDescValor
                        FROM bdilide:'informix'.sl_ftc_prm
							WHERE desc_valor = UPPER(TRIM(pDesValor))
							AND cve_param = 1;

                        SELECT  valor_param, desc_valor
							INTO   cValorParam1, cDescValor1
                        FROM bdilide:'informix'.sl_ftc_prm
							WHERE valor_param = pValorParam
							AND cve_param = 1;

                        UPDATE  bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor))
							WHERE cve_param = 1
							AND valor_param = cValorParam1;

                        UPDATE bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor1))
							WHERE cve_param = 1
							AND valor_param = cValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor1, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');

                ELIF (iNoRegistros = 0) THEN
						SELECT desc_valor
							INTO cDescValor
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE cve_param = 1
                            AND valor_param = pValorParam;
								
                        UPDATE bdilide:'informix'.sl_ftc_prm
                            SET  desc_valor = UPPER(TRIM(pDesValor))
                            WHERE cve_param = 1
                            AND valor_param = pValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');

                        END IF;

                ELIF pBandera = 3 THEN

					SELECT COUNT(*) AS buscaparam
						INTO iNoRegistros
					FROM bdilide:'informix'.sl_ftc_prm
						WHERE UPPER(desc_valor) = UPPER(TRIM(pDesValor))
						AND cve_param = 1;

					IF (iNoRegistros = 1) THEN
						SELECT   valor_param, valor, desc_valor
							INTO  cValorParam, cValor, cDescValor
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE  UPPER(desc_valor) = UPPER(TRIM(pDesValor))
							AND  UPPER(valor) = UPPER(TRIM(pValor))
							AND cve_param = 1;

						SELECT  valor_param, valor, desc_valor
							INTO   cValorParam1, cvalor1, cDescValor1
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE valor_param = pValorParam
							AND cve_param = 1;

						UPDATE  bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor)), valor = cValor
							WHERE cve_param = 1
							AND valor_param = cValorParam1;

						UPDATE bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor1)), valor = cValor1
							WHERE cve_param = 1
							AND valor_param = cValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam1, cDescValor1, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						

                        ELSE IF (iNoRegistros = 0) THEN
							SELECT desc_valor
								INTO cDescValor
							FROM bdilide:'informix'.sl_ftc_prm
								WHERE cve_param = 1
								AND valor_param = pValorParam;

                            UPDATE bdilide:'informix'.sl_ftc_prm
                                SET  desc_valor = UPPER(TRIM(pDesValor))
                                WHERE cve_param = 1
                                AND valor_param = pValorParam;
								
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
							

                            SELECT valor, valor_param
                                INTO  cValor, cValorParam
                            FROM bdilide:'informix'.sl_ftc_prm
                                WHERE UPPER(valor) = UPPER(TRIM(pValor))
                                AND cve_param = 1;

                            SELECT valor, valor_param
                                INTO  cValor1, cValorParam1
                            FROM bdilide:'informix'.sl_ftc_prm
                                WHERE valor_param = pValorParam
                                AND cve_param = 1;

							UPDATE  bdilide:'informix'.sl_ftc_prm
								SET  valor = pValor
								WHERE cve_param = 1
								AND valor_param = pValorParam;

							UPDATE bdilide:'informix'.sl_ftc_prm
									SET  valor = cValor1
								WHERE cve_param = 1
								AND valor_param = cValorParam;
								
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
								VALUES (CURRENT, 1,cValorParam , cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
								VALUES (CURRENT, 1, pValorParam, cValor1, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						END IF;
                    END IF;
					
                END IF;

                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                    LET cCodRet = '00283';
                    RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
                END IF;

                RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 26/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que realiza el intercambio de canales, des_canales de los parametros fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaclientefatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR(20) AS num_cliente,
                CHAR(150)       AS nombre,
                CHAR(20)        AS num_cuenta,
                DECIMAL(16,2)   AS saldo,
                CHAR (1)        AS tipo_repeporte;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumCte  CHAR(20);
        DEFINE cNombre      CHAR(150);
        DEFINE cNumCuenta   CHAR(20);
        DEFINE dSaldo   DECIMAL(16,2);
        DEFINE cTipoReporte     CHAR(1);
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        DEFINE cActividad CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cNumCte= '';
        LET cNombre     = '';
        LET cNumCuenta  = '';
        LET dSaldo              =0.00;
        LET cTipoReporte = '';
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        LET cActividad = 'CONSULTA FATCA';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaclientefatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                
                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                IF (pTipoReporte = '' ) THEN 
                
                        FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
                        TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
                                INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
                                FROM bdilide:'informix'.sl_ftc_cte a
                                INNER JOIN  bdilide:'informix'.sl_ftc_det b     ON a.num_cliente = b.num_cliente
                                WHERE a.ejercicio = b.ejercicio
                                AND a.ejercicio = pEjercicio                            
                                ORDER BY a.num_cliente ASC, a.cuenta ASC
                        
                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
                        END FOREACH;
                                
                ELSE 
                
                        FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
                                TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
                                INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
                                FROM bdilide:'informix'.sl_ftc_cte a
                                INNER JOIN  bdilide:'informix'.sl_ftc_det b     ON a.num_cliente = b.num_cliente
                                WHERE a.ejercicio = b.ejercicio
                                AND a.ejercicio = pEjercicio
                                AND a.tipo_rep = pTipoReporte
                                ORDER BY a.num_cliente ASC, a.cuenta ASC                
                
                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
                        END FOREACH;
                END IF;
                INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
                VALUES (CURRENT, 0, '', '', '', pUsuario, 'CONSULTA FATCA');
                                        
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;         
        
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaclientefatca_total(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR (1))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
		BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;		
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaclientefatca_total.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pEjercicio = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF (pTipoReporte = '' ) THEN 
		
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM 
				(SELECT a.num_cliente, TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
				FROM bdilide:'informix'.sl_ftc_cte a
				INNER JOIN  bdilide:'informix'.sl_ftc_det b	ON a.num_cliente = b.num_cliente
				WHERE a.ejercicio = b.ejercicio
				AND a.ejercicio = pEjercicio				
				ORDER BY a.num_cliente ASC, a.cuenta ASC);
		ELSE 
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM 
				(SELECT a.num_cliente, TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
				FROM bdilide:'informix'.sl_ftc_cte a
				INNER JOIN  bdilide:'informix'.sl_ftc_det b	ON a.num_cliente = b.num_cliente
				WHERE a.ejercicio = b.ejercicio
				AND a.ejercicio = pEjercicio	
				AND a.tipo_rep = pTipoReporte);
		END IF;
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el total de clientes fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaconsecutivofatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio SMALLINT, pTipoRpt CHAR(1), pFolio CHAR(20))
		RETURNING CHAR(5) AS codret,
		SMALLINT AS consecutivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sConsecutivo SMALLINT;
	DEFINE cFolio CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sConsecutivo = 0;
	LET cFolio = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sConsecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaconsecutivofatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' OR pTipoRpt = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;				
		IF NOT EXISTS (SELECT consecutivo FROM bdilide:'informix'.sl_ftc_cns WHERE ejercicio = pEjercicio AND tipo_rpt = pTipoRpt) THEN 
			
			IF pTipoRpt = 'N' THEN 
			
				INSERT INTO bdilide:'informix'.sl_ftc_cns(ejercicio, tipo_rpt, consecutivo,usuario, fecha_act)
				VALUES (pEjercicio, pTipoRpt, 1 , pUsuario, CURRENT);
				
				SELECT consecutivo 
					INTO sConsecutivo 
					FROM bdilide:'informix'.sl_ftc_cns
					WHERE ejercicio = pEjercicio
					AND tipo_rpt = pTipoRpt;

			ELSE 
				IF pEjercicio = '' OR pTipoRpt = '' OR  pFolio = '' THEN 
					LET cCodRet = '00003';
					RETURN cCodRet, sConsecutivo;
				END IF;
			
				INSERT INTO bdilide:'informix'.sl_ftc_cns(ejercicio, tipo_rpt, consecutivo, folio, usuario, fecha_act)
				VALUES (pEjercicio, pTipoRpt, 1,  pfolio , pUsuario, CURRENT);
				
					SELECT consecutivo 
					INTO sConsecutivo 
					FROM bdilide:'informix'.sl_ftc_cns
					WHERE ejercicio = pEjercicio
					AND tipo_rpt = pTipoRpt;
				
				INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
                VALUES (CURRENT, 0, '', pFolio, 'folio', pUsuario, 'INSERCION FOLIO ANTERIOR');
			END IF;
		
		ELSE				
			SELECT consecutivo, folio
			INTO sConsecutivo, cFolio
			FROM bdilide:'informix'.sl_ftc_cns 
			WHERE ejercicio = pEjercicio 
			AND tipo_rpt = pTipoRpt;
			
		
		IF (sConsecutivo IS NULL OR sConsecutivo = 0 ) THEN 
			LET sConsecutivo = 1;		
		ELSE 		
			LET sConsecutivo = sConsecutivo + 1;		
		END IF;
			IF pTipoRpt = 'N' THEN 			
				UPDATE bdilide:'informix'.sl_ftc_cns
				SET consecutivo = sConsecutivo
				WHERE ejercicio = pEjercicio
				AND tipo_rpt = pTipoRpt;
			ELSE 
				UPDATE bdilide:'informix'.sl_ftc_cns
				SET consecutivo = sConsecutivo, folio = pFolio
				WHERE ejercicio = pEjercicio
				AND tipo_rpt = pTipoRpt;				
				INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
					VALUES (CURRENT, 0, '', pFolio, 'folio', pUsuario, 'INSERCION FOLIO ANTERIOR');
			END IF;
		END IF;	
		
		SELECT folio
		INTO cFolio
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio
		AND tipo_rpt = 'C';
		
		IF cFolio <> '' AND pTipoRpt = 'C' THEN 
			UPDATE bdilide:'informix'.sl_ftc_prm
			set valor = 'C'
			WHERE cve_param = 5
			AND valor_param = 7;
			
		ELSE
			UPDATE bdilide:'informix'.sl_ftc_prm
			set valor = 'N'
			WHERE cve_param = 5
			AND valor_param = 7;
		END IF;
			
		RETURN cCodRet, sConsecutivo;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		RETURN cCodRet, sConsecutivo;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que consulta el numero consecutivo de complemento para el archivo xml de Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultacredencialesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(200) AS usuario,
		CHAR(200) AS password,
		CHAR(200) AS puerto,
		CHAR(200) AS ip,
		CHAR(200) AS pscp;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cCredenciales CHAR(200);
	DEFINE cUsuario CHAR(200);
	DEFINE cPassword CHAR(200);
	DEFINE cPuerto CHAR(200);
	DEFINE cIp CHAR(200);
	DEFINE cPscp CHAR(200);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cCredenciales = '';
	LET cUsuario = '';
	LET cPassword = '';
	LET cPuerto = '';
	LET cIp = '';
	LET cPscp = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultacredencialesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END IF;
		
		SELECT valor
		INTO cUsuario
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 1;

		SELECT valor
		INTO cPassword
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 2;

		SELECT valor
		INTO cPuerto
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 3;

		SELECT valor
		INTO cIp
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 4;
		
		SELECT valor
		INTO cPscp
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 5;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
        END IF;
		
		RETURN cCodRet, TRIM(cUsuario), TRIM(cPassword), TRIM(cPuerto), TRIM(cIp), TRIM(cPscp);
		
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/04/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene los parametros de las credenciales para obtener la ruta productiva de fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultadtallectesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pEjercicio CHAR(4), pTipoReporte CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(100)AS razon_soc,
		CHAR(30) AS nombre1,
		CHAR(30) AS nombre2,
		CHAR(30) AS apell_paterno,
		CHAR(30) AS apell_materno, 
		CHAR(130) AS direccion,
		CHAR(20) AS tin,
		CHAR(13) AS rfc,
		CHAR(10) AS fecha_nac,
		CHAR(20) AS cuenta,
		DECIMAL (16,2) AS monto_cta,		
		CHAR(4)  AS ejercicio,
		CHAR(2)  AS tipo_persona,
		CHAR(26) AS apellido_paterno,
		CHAR(26) AS apellido_materno,
		CHAR(26) AS nombres1,
		CHAR(26) AS nombres2,
		CHAR(13) AS rfc_pm,
		CHAR(120) AS direcciones,
		CHAR(10) AS fecha_nacimiento,
		MONEY (16,2) AS interes_pagado;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE cRazonSoc       CHAR(100);
	DEFINE cNombre1        CHAR(30);
	DEFINE cNombre2        CHAR(30); 
	DEFINE cApellPaterno   CHAR(30); 
	DEFINE cApellMaterno   CHAR(30); 
	DEFINE cNomCalle       CHAR(30); 
	DEFINE cDireccion	   CHAR(130);
	DEFINE cTin            CHAR(20); 
	DEFINE cRfc            CHAR(13); 
	DEFINE cFechaNac       CHAR(10); 
	DEFINE cCuenta         CHAR(20); 
	DEFINE dMontoCta 		DECIMAL (16,2);
	DEFINE mInteresPagado MONEY (16,2);
	DEFINE cEjercicio		CHAR(4);
	DEFINE cTipo_persona	CHAR(2);
	DEFINE cNumCte CHAR(20);
	DEFINE cApellPat	CHAR(26);
	DEFINE cApellMat  CHAR(26);
	DEFINE cNombres1         CHAR(26);
	DEFINE cNombres2         CHAR(26);
	DEFINE cRfc1          CHAR(13);
	DEFINE cDirecciones      CHAR(120);
	DEFINE cFechaNacim       CHAR(10); 
	DEFINE sConsecutivo 	SMALLINT;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente       =  '';
	LET cRazonSoc       =  '';
	LET cNombre1        =  '';
	LET cNombre2        =  '';
	LET cApellPaterno   =  '';
	LET cApellMaterno   =  '';
	LET cDireccion       =  '';
	LET cTin            =  '';
	LET cRfc            =  '';
	LET cFechaNac       =  '';
	LET cCuenta         =  '';
	LET dMontoCta 	    =  0.00;
	LET mInteresPagado = 0.0;
	LET cEjercicio	    =  '';
	LET cTipo_persona	=  '';
	LET cNumCte       =  '';
	LET cApellPat	= '';
	LET cApellMat   = '';
	LET cNombres1   = '';
	LET cNombres2   = '';
	LET cRfc1        = '';
	LET cDirecciones  = '';
	LET cFechaNacim	= '';
	LET sConsecutivo = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultadtallectesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT MAX(cns_rep)
				INTO sConsecutivo
				FROM bdilide:"informix".sl_ftc_cte
				WHERE ejercicio = pEjercicio
				AND tipo_rep = pTipoReporte;	
				
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion fisica.num_cliente,fisica.razon_soc,  fisica.nombre1, fisica.nombre2, fisica.apell_paterno, fisica.apell_materno, fisica.direccion, fisica.tin, fisica.rfc, 
				SUBSTRING(fisica.fecha_nac FROM 7 FOR 4) || '-'|| SUBSTRING(fisica.fecha_nac FROM 1 FOR 2) || '-' ||SUBSTRING(fisica.fecha_nac FROM 4 FOR 2), fisica.cuenta, fisica.monto_cta, fisica.ejercicio, fisica.tpo_persona,apoderado.numcte,apoderado.apell_paterno, apoderado.apell_materno, apoderado.nombre1, apoderado.nombre2, apoderado.rfc,apoderado.direcciones, SUBSTRING(apoderado.fecha_nac FROM 7 FOR 4) || '-'|| SUBSTRING(apoderado.fecha_nac FROM 1 FOR 2) || '-' ||SUBSTRING(apoderado.fecha_nac FROM 4 FOR 2),fisica.interes_pagado
				INTO cNumCliente, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNumCte, cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim,mInteresPagado
				FROM
				(SELECT cte.num_cliente, det.razon_soc,  det.nombre1, det.nombre2, det.apell_paterno, det.apell_materno, 
				TRIM(CASE WHEN NVL(det.nom_calle,"") != "" THEN TRIM(det.nom_calle) || '/' ELSE TRIM(NVL(det.nom_calle,"")) END  ||
				CASE WHEN NVL(det.num_ext,"") != "" THEN TRIM(det.num_ext) || '/' ELSE TRIM(NVL(det.num_ext,"")) END  ||
				CASE WHEN NVL(det.num_int,"") != "" THEN TRIM(det.num_int) || '/' ELSE TRIM(NVL(det.num_int,"")) END  ||
				CASE WHEN NVL(det.colonia,"") != "" THEN TRIM(det.colonia) || '/' ELSE TRIM(NVL(det.colonia,"")) END  ||
				CASE WHEN NVL(det.delegacion,"") != "" THEN TRIM(det.delegacion) || '/' ELSE TRIM(NVL(det.delegacion,"")) END  ||
				CASE WHEN NVL(det.pais,"") != "" THEN TRIM(det.pais) || '/' ELSE TRIM(NVL(det.pais,"")) END  ||
				CASE WHEN NVL(det.ciudad,"") != "" THEN TRIM(det.ciudad) || '/' ELSE TRIM(NVL(det.ciudad,"")) END ||
				CASE WHEN NVL(det.cod_postal,"") != "" THEN TRIM(det.cod_postal)  ELSE TRIM(NVL(det.cod_postal,"")) END) AS direccion,  
				det.tin, det.rfc, det.fecha_nac, det.cuenta, det.monto_cta,  det.ejercicio, si_cliente.tpo_persona, det.interes_pagado
				FROM bdilide:"informix".sl_ftc_cte cte 
				INNER JOIN bdilide:"informix".sl_ftc_det det ON det.num_cliente = cte.num_cliente
				INNER JOIN bdinteg:"informix".si_cliente si_cliente ON cte.num_cliente = si_cliente.numcte
				WHERE cte.ejercicio = det.ejercicio
				AND cte.ejercicio = pEjercicio
				AND cte.cns_rep = sConsecutivo
				AND cte.tipo_rep = pTipoReporte) fisica
				LEFT JOIN 
				(
				SELECT numcte, numcteapoderado, apell_paterno, apell_materno, nombre1, nombre2, rfc,
				TRIM(CASE WHEN NVL(nombrecalle,"") != "" THEN TRIM(nombrecalle) || '/' ELSE TRIM(NVL(nombrecalle,"")) END  ||
				CASE WHEN NVL(numeroextcalle,"") != "" THEN TRIM(numeroextcalle) || '/' ELSE TRIM(NVL(numeroextcalle,"")) END  ||
				CASE WHEN NVL(numerointcalle,"") != "" THEN TRIM(numerointcalle) || '/' ELSE TRIM(NVL(numerointcalle,"")) END  ||
				CASE WHEN NVL(nombrezona,"") != "" THEN TRIM(nombrezona) || '/' ELSE TRIM(NVL(nombrezona,"")) END  ||
				CASE WHEN NVL(municipiozona,"") != "" THEN TRIM(municipiozona) || '/' ELSE TRIM(NVL(municipiozona,"")) END  ||
				CASE WHEN NVL(nombre,"") != "" THEN TRIM(nombre) || '/' ELSE TRIM(NVL(nombre,"")) END  ||
				CASE WHEN NVL(nombreciudad,"") != "" THEN TRIM(nombreciudad) || '/' ELSE TRIM(NVL(nombreciudad,"")) END ||
				CASE WHEN NVL(cod_postal,"") != "" THEN TRIM(cod_postal)  ELSE TRIM(NVL(cod_postal,"")) END) AS direcciones, 
				fecha_nac
				FROM
				((SELECT apo.numcte, apo.numcteapoderado, si.apell_paterno, si.apell_materno, si.nombre1, si.nombre2, si.rfc, dic.numerocalle, dic.numerocolonia, dic.municipio, dic.pais, dic.ciudad, dic.numeroextcalle, dic.numerointcalle,  dic.cod_postal, cpf.fecha_nac
				FROM bdinteg:"informix".si_apoderado apo
				INNER JOIN bdinteg:"informix".si_cliente si ON apo.numcteapoderado = si.numcte
				INNER JOIN bdinteg:"informix".si_direcciones_actual dic ON apo.numcteapoderado = dic.numcte
				INNER JOIN bdinteg:"informix".si_ctepf cpf ON apo.numcteapoderado = cpf.numcte
				WHERE dic.tipo_dir = 1) dic
				LEFT JOIN bdinteg:"informix".si_catcalles AS c ON dic.numerocalle = c.numerocalle 
				LEFT JOIN bdinteg:"informix".si_catzonas cz ON dic.numerocolonia = cz.numerocolonia
				AND cz.municipiozona = dic.municipio 
				LEFT JOIN bdinteg:"informix".si_paises p ON dic.pais = p.pais
				LEFT JOIN bdinteg:"informix".si_catciudades cc ON dic.ciudad = cc.numerociudad) 
				) apoderado
				ON fisica.num_cliente = apoderado.numcte
	
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cRazonSoc, UPPER(TRIM(cNombre1)), UPPER(TRIM(cNombre2)), UPPER(TRIM(cApellPaterno)), UPPER(TRIM(cApellMaterno)), UPPER(TRIM(cDireccion)), cTin, UPPER(TRIM(cRfc)), cFechaNac, cCuenta, dMontoCta, cEjercicio, cTipo_persona, UPPER(TRIM(cNombres1)), UPPER(TRIM(cNombres2)), UPPER(TRIM(cApellPat)), UPPER(TRIM(cApellMat)),UPPER(TRIM(cRfc1)),UPPER(TRIM(cDirecciones)),cFechaNacim, mInteresPagado WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;		
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca para la genracion del reporte XML.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 26/05/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue del domicilio de los Clientes Persona Moral y Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultafolioanteriorfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFolio CHAR(20);
	DEFINE cConsecutivo CHAR(4);
	DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFolio = '';
	LET cConsecutivo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultafolioanteriorfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio =''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT folio, consecutivo
		INTO cFolio, cConsecutivo
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio AND tipo_rpt = 'C';
		
		LET iNoRegistros = iNoRegistros + 1;		
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00767';
			RETURN cCodRet;		
		END IF;		
	
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio ',
'FECHA: 09/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza consulta del folio anterior para el reporte fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultageneroisrfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCliente CHAR(20), pNumCuenta CHAR(20), pEjercicio CHAR(4), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret,
	  CHAR(20) AS num_cliente,
	  CHAR(20) AS num_cuenta,
	  CHAR(4) AS ejercicio,
	  CHAR(104) AS nom_completo;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR (20);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cEjercicio CHAR(4);
	DEFINE cNomCompleto CHAR(104);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNoCliente CHAR(20);
	DEFINE cTipoPer CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNoRegistros = 0;
	LET cNumCliente = '';
	LET cNumCuenta='';
	LET cEjercicio = '';
	LET cNomCompleto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNoCliente = '';
	LET cTipoPer = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultageneroisrfatca.out';
		--TRACE ON;
		
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pEjercicio = '' OR pBandera =''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		SELECT numcte, tpo_persona
		INTO cNoCliente, cTipoPer
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCliente;
		
		IF cTipoPer = '01' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, 
				TRIM(b.nombre1)||' '||TRIM(b.nombre2)||' '||TRIM(b.apell_paterno)||' '||TRIM( b.apell_materno)
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		ELIF cTipoPer = '02' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, razon_social
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		END IF;		
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de clientes si es que genero ISR o no',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 27/05/2016',
'DESCRIPCION: Modificacion del SPL para retornar datos del Cliente Persona Moral',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparamarchivofatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2))
                RETURNING CHAR(5) AS codret,
                        SMALLINT AS cve_param,
                        CHAR(5) AS valor_param,
                        CHAR(200) AS valor,
                        CHAR(3) AS id_identificador,
                        CHAR(50) AS des_identificador;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE sCveParam SMALLINT;
        DEFINE cValorParam CHAR(5);
        DEFINE cValor CHAR(200);  
        DEFINE cIdIdentificador     CHAR(3);
        DEFINE cDesIdentificador CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET sCveParam   = 0;
        LET cValorParam = '';
        LET cValor          = '';
        LET cIdIdentificador    = '';
        LET cDesIdentificador   = '';
        
                
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END EXCEPTION;
                
               -- SET DEBUG FILE TO '/INFORMIXDUMP/Malik/sp_cap_consultaparamarchivofatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pBandera = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                SET ISOLATION TO DIRTY READ; 
                
                IF pBandera = 1 THEN            
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm  
                        WHERE cve_param = 5 
                        AND valor_param = 14; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 2 THEN
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm 
                        WHERE cve_param = 2
                        AND valor_param = 3;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                ELIF pBandera = 3 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 4 
                        AND valor_param = 1;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 4 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 2 
                        AND valor_param = 4; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                                
                ELIF pBandera = 5 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 1;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 6 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 6;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 7 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 7;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
				
				ELIF pBandera = 8 THEN
                                      
                FOREACH
                SELECT  ID, identificador, valor
                INTO cIdIdentificador, cDesIdentificador, cValor
                FROM (
                SELECT 1 AS ID, 'VERSION' AS identificador, valor
                FROM bdilide:sl_ftc_prm
                WHERE cve_param = 5 
                AND valor_param = 5
                UNION 
                SELECT 2 AS ID, 'SENDINGCOMPANYIN' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 2
                UNION
                SELECT 3 AS ID,'TRANSMITTINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 9
                UNION
                SELECT 4 AS ID, 'RECEIVINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 10
                UNION
                SELECT 5 AS ID, 'MESSAGETYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 11
                UNION
                SELECT 6 AS ID, 'MESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 3
                UNION
                SELECT 7 AS ID, 'CORRMESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 12
                UNION
                SELECT 8 AS ID, 'REPORTINGPERIOD' as identificador, SUBSTRING(valor FROM 7 FOR 4) || '-'|| SUBSTRING(valor FROM 4 FOR 2) || '-' ||SUBSTRING(valor FROM 1 FOR 2)
				FROM bdilide:'informix'.sl_ftc_prm   
				WHERE cve_param = 5 
				AND valor_param = 6
                UNION
                SELECT 9 AS ID, 'RESCOUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 20
                UNION
                SELECT 10 AS ID, 'TINTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 1
                UNION
                SELECT 11 AS ID, 'NAME' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 14
                UNION
                SELECT 12 AS ID, 'COUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 15
                UNION
                SELECT 13 AS ID, 'ADDRRESS FREE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 16
                UNION
                SELECT 14 AS ID, 'DOCTYPEINDIC' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 18
                UNION
                SELECT 15 AS ID, 'DOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm  
                WHERE cve_param = 5 
                AND valor_param = 17
                UNION
                SELECT 16 AS ID, 'CORRDOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 19
				UNION
                SELECT 17 AS ID, 'TIPO PAGO' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 21
				UNION
                SELECT 18 AS ID, 'CODIGO MONEDA' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 22
				UNION
                SELECT 19 AS ID, 'TIN ISSUEDBY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 23
				UNION
                SELECT 20 AS ID, 'ACCT HOLDERTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 24
                ORDER BY 1)
                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador WITH RESUME;
                END FOREACH;
            END IF;         
                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
               END IF;                                
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 09/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene los parametros para el archivo XML Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
            RETURNING CHAR(5) AS codret,
                CHAR(200) AS canal,
                CHAR(5) AS valor_param,
				CHAR(200) AS valor,
                CHAR(200) AS clasificacion,
                INTEGER AS id_clasificacion;              
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCanal CHAR(200);
        DEFINE cValorParam CHAR(5);
		DEFINE cValor CHAR(200);
        DEFINE cClasificacion CHAR(200);
        DEFINE cIdClasificacion INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCanal ='';
        LET cValorParam='';
        LET cClasificacion ='';
        LET cIdClasificacion=0;
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD              
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
					FOREACH 
						SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal,  a.valor_param, a.valor, '-' as clasificacion,  valor_param as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
							WHERE a.cve_param = b.cve_param
							AND a.cve_param = pTipoParametro
							ORDER BY valor_param::INTEGER 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			ELIF pTipoParametro>=2 OR  pTipoParametro <= 4THEN
					FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal, a.valor_param, a.valor, c.c_desc_vparam as clasificacion, a.valor_param::int as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a
						INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
						LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
							WHERE  a.cve_param = pTipoParametro
							ORDER BY valor_param::DECIMAL 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			END IF; 
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion; 
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion; 
			END IF;
			
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
					WHERE a.cve_param = b.cve_param
					AND a.cve_param = pTipoParametro;							
		ELIF pTipoParametro >= 2 OR  pTipoParametro <= 4 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a
					INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
					LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
					WHERE  a.cve_param = pTipoParametro;						
		END IF;	
		
				IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de totales para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_limpiaconsultasfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistrosdet INTEGER;
	DEFINE iNoRegistroscte INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistrosdet = 0;
	LET iNoRegistroscte = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_limpiaconsultasfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistrosdet
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistrosdet > 0) THEN 			
		DELETE 
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistroscte
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistroscte > 0 ) THEN 
		DELETE 
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		END IF;
		
		IF iNoRegistroscte  = 0  OR iNoRegistrosdet = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
			
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 04/03/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que realiza la limpieza de tablas dependiendo su ejercicio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
		DATE AS fecha,
		CHAR (4) AS sucursal,
		CHAR (20) AS cuenta,
		CHAR (20) AS num_cte,
		DATE AS fech_cap,
		DECIMAL (18,2) AS capital,
		DECIMAL (18,2) AS interes,
		SMALLINT AS secuencia;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dFecha DATE;
	DEFINE cSucursal CHAR (4);
	DEFINE cCuenta CHAR (20);
	DEFINE cNumCte CHAR (20);
	DEFINE dFechCap DATE;
	DEFINE dCapital DECIMAL (18,2);
	DEFINE dInteres DECIMAL (18,2);
	DEFINE sSecuencia SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET dFecha = '';
	LET cSucursal = '';
	LET cCuenta = '';
	LET cNumCte = '';
	LET dFechCap = '';
	LET dCapital = 0.00;
	LET dInteres = 0.00;
	LET sSecuencia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, sucursal, cuenta, num_cte, fech_cap, capital, interes, secuencia
			INTO dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia 
			FROM bdinvers:"informix".sv_sdosdiarios
			WHERE fecha >= pFechaInicio 
				AND fecha <= pFechafin
			
			LET iNoRegistros = iNoRegistros + 1;
			
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe AngÃ©lica HernÃ¡ndez PÃ©rez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT COUNT(*) 
		INTO iNoRegistros 
		FROM bdinvers:"informix".sv_sdosdiarios
		WHERE fecha >= pFechaInicio
			AND fecha <= pFechaFin;
					
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de totales para los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(40) AS nombre, 
		CHAR(14) AS cta_contable, 
		DECIMAL(16,2) AS Saldo_cheques, 
		DECIMAL(16,2) AS saldo_contab, 
		DECIMAL(16,2) AS dif_saldos,  
		CHAR(255) AS observaciones, 
		CHAR(1) AS editable;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(40);
    DEFINE cCtaContable CHAR(14);
    DEFINE dSdoCheques DECIMAL(16,2);
    DEFINE dSdoContab DECIMAL(16,2);
    DEFINE dDifSaldos DECIMAL(16,2);
    DEFINE cObservaciones CHAR(255);
    DEFINE cEditable CHAR(1);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
			
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombre        = '';
    LET cCtaContable   = '';
    LET dSdoCheques    = 0.00;
    LET dSdoContab     = 0.00;
    LET dDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2(pFechaCcl, pTipo, pRegistros, pRecuperacion)
			INTO cCodRetSp, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable		
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultacedulas2 ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, UPPER(TRIM(cNombre)), cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, UPPER(TRIM(cObservaciones)), UPPER(TRIM(cEditable)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
	
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el detalle de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT)
		RETURNING CHAR(5) AS codret,		
		INTEGER AS num_registros;

	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE cDescCodRet 				CHAR(100);
	DEFINE iCodRetSp				INTEGER;
	DEFINE iSqlErr 					INTEGER;	
	DEFINE iNumRegistros 			INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2_totales(pFechaCcl, pTipo)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditarjeta:sp_consultacedulas2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;
        
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el total de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el spl productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacedulas( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255), CHAR(1);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consultacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consultacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;