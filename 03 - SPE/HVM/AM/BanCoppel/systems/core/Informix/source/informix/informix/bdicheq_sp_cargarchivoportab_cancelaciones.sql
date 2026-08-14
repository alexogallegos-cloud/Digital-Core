CREATE PROCEDURE "informix".sp_cargarchivoportab_cancelaciones(pfecha_reg date,pnombrearchivo CHAR(30),cod_oper CHAR(2),itotalsol integer)
RETURNING CHAR(5),  --CODIGO RETORNO
		  CHAR(35), --NOMBRE DEL ARCHIVO
		  CHAR(50); --RUTA EN CENTRAL DONDE SE DEPOSITO ARCHIVO

		  
   -- // DESCRIPCION DE LOS PARAMETROS DE ENTRADA
    /*  pfecha_reg:       Fecha en la cual se va a cargar el arhivo
        pnombrearchivo:   Nombre del archivo que se va a cargar
		cod_oper:         Tipo de operación:  22= CANCELACIONES
		itotalsol:        Numero total de solicitudes cargadas en central 								  
	*/
	
	
	
--##############################################
---- DEFINIR  VARIABLES  GENERALES---	
--##############################################	
	
DEFINE cSqlerr				 INTEGER;
DEFINE cIsamErr				 INTEGER;
DEFINE cDescErr				 char(50);
DEFINE cCodret      		 char(5);
DEFINE cCodret2      		 char(5);
DEFINE cCodret3      		 char(50);	
DEFINE cruta_archi			 char(50);	
	
-- DEFINIR VARIABLES RUTAS
DEFINE ccancRutaArchivo      char(60);	
	
	
--## variables para  fecha de hoy
DEFINE dFechaHoy 			DATE;	
DEFINE cfecha_dmy           char(10);	
DEFINE vfecha_reg           char(8);  	
	
--##Variable para ver si el archivo ya fue procesado	
DEFINE itot_arch			INTEGER;	
	
--##Variables para el nombre del archivo	
DEFINE cArchivresp           char(35);
DEFINE cnombarcpar           char(20);	

--## Variable para ejecutar el System 
DEFINE cSQL 				 char(250);	
	
--## Estatus de carga del proceso 	
DEFINE cEstatuscarga	 	 char(1);	
	
--## Bandera para carga de proceso	
DEFINE cBandera 			 char(1);	
	
	
DEFINE cLinea 				 char(500);	
	
DEFINE iNumReg 				 INTEGER;	
	
DEFINE ven_transacc         SMALLINT;	
DEFINE cMensaje 			 char(110);	
DEFINE pempresa              char(3);	
	

DEFINE cRenglon 			 char(500);
	
-- DEFINIR VARIABLES ENCABEZADO 

DEFINE cfecha_presentacion   char(8);
DEFINE ccod_operacion        char(2);
DEFINE cnum_secuencia        INTEGER;
DEFINE cbanco_rec            INTEGER;
DEFINE csent_archi           char(1);	
	
-- DEFINIR VARIABLES DETALLE  
DEFINE ccod_ope              char(2); 
DEFINE isecuencia            integer; 
DEFINE cfolio_cancelacion    char(30);
DEFINE cfecha_solicitud      char(8);
DEFINE cnombre_cte           char(60);
DEFINE crfc_cte              char(13);
DEFINE ccta_receptora        char(20);
DEFINE ctipo_cta_receptora   char(2);
DEFINE cbco_receptor         char(5);
DEFINE ccta_ordenante        char(20);
DEFINE ctipo_cta_ordenante   char(2);
DEFINE cbco_ordenante        char(5);
DEFINE cfecha_nacimiento     char(8);
DEFINE crfc_empresa          char(12);
DEFINE cestatus_respuesta    char(2);
DEFINE cfecha_respuesta      char(8);
DEFINE ccurp_cte             char(18);	
DEFINE cfolio_solicitud      char(30);	
	
-- DEFINIR VARIABLES SUMARIO
DEFINE cnumsecuencia         INTEGER;
DEFINE ccodoperacion     	 INTEGER;
DEFINE itotalregistros   	 INTEGER;

DEFINE iRegistros		 	INTEGER; 	
	
DEFINE ivalidafolioexis	 INTEGER;	
	
	
	
	
--#############################################	
-- INICIALIZAR VALORES INICIALES --
--#############################################
LET cSqlerr 			= 0;
LET cIsamErr 			= 0;
LET cDescErr 			= '';
LET cCodret 			= '00000';
LET cCodret2 			= '';
LET cCodret3 			= '';	
LET cArchivresp         = "";	
LET cruta_archi			 = '';	
	

-- INICIALIZAR VARIABLES RUTAS		
LET ccancRutaArchivo     = '';	
	
	
-- Variables para fecha de hoy

LET dFechaHoy   		= DATE(1);	
LET cfecha_dmy          = '';
LET vfecha_reg          = ''; 

--Varible para archivo duplicado
LET itot_arch			   = 0;	
	
--Varibles para nombre del archivo	
LET cArchivresp            = "";
LET cnombarcpar            = "canceporta40137E";	
	
--Varibles para ejecutar System	
LET cSQL 				= '';	

-- Estatus de carga del proceso	
LET cEstatuscarga       = '0'; 	



LET cBandera = "F";
LET cLinea = '';
LET iNumReg = 0;
LET ven_transacc           = 0;	
LET cMensaje               = '';	
LET  pempresa              = '001';

LET cRenglon = '';

-- INICIALIZAR VARIABLES ENCABEZADO 

LET cfecha_presentacion  = '';
LET ccod_operacion       = '';
LET cnum_secuencia       = 0;
LET cbanco_rec           = 0;
LET csent_archi          = '';


-- INICIALIZAR VARIABLES DETALLE
LET  ccod_ope             = '';
LET  isecuencia           = 0;
LET cfolio_cancelacion    = '';
LET  cfecha_solicitud     = '';
LET  cnombre_cte          = '';
LET  crfc_cte             = '';
LET  ccta_receptora       = '';
LET  ctipo_cta_receptora  = '';
LET  cbco_receptor        = '';
LET  ccta_ordenante       = '';
LET  ctipo_cta_ordenante  = '';
LET  cbco_ordenante       = '';
LET  cfecha_nacimiento    = '';
LET  crfc_empresa         = '';
LET  cestatus_respuesta   = '';
LET  cfecha_respuesta     = '';
LET  ccurp_cte            = '';
LET  cfolio_solicitud     = '';

-- INICIALIZAR VARIABLES SUMARIO
LET cnumsecuencia      = 0;
LET ccodoperacion      = 0;  
LET itotalregistros    = 0;

LET iRegistros			   = 0;

LET ivalidafolioexis = 0;

	BEGIN
		------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;   
				Let cCodret2 = cIsamErr;   
				Let cCodret3 = cDescErr;   
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;	
				
				END IF;
			   RETURN cCodret, cArchivresp, cruta_archi;
			END IF;
		END EXCEPTION;
		
		
		  --SET DEBUG FILE TO "/informix/VILLELA/sp_cargarchivoportab_cancelaciones.out";
		  --TRACE ON;
	  
		  SET LOCK MODE TO WAIT 3;
		  SET ISOLATION TO DIRTY READ;
	
		  BEGIN WORK;
		  LET ven_transacc = 1;
		
		  IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 OR LENGTH(NVL(cod_oper,'')) = 0  OR LENGTH(NVL(itotalsol,'')) = 0
			  THEN
			  LET cCodret='77777';   --PARAMETROS VACIOS	
			  RETURN cCodret, cArchivresp, cruta_archi;
		  END IF;
			
		
		
	--Se leerá de la tabla de parámetros (sc_parametros), aquellos datos fijos(rutas).
		
	      SELECT {+INDEX(sc_param idx_param1 )} valor
		  INTO ccancRutaArchivo 
		  FROM BDICHEQ:sc_param 
		  WHERE empresa = "001" 
		  AND codparam = 'rta_canpor_s';
		
		
	   -- Se leera la fecha de Hoy. 
	
		select fecha_hoy
		into dFechaHoy
		from sc_fechas
		where empresa = pempresa;	
		
		
		 --// PONE EN VARIABLES LA FECHA SOLICITADA (D/M/Y)	
		LET cfecha_dmy = LPAD(DAY(pfecha_reg),2,0)||'/'||LPAD(MONTH(pfecha_reg),2,0)||'/'||(YEAR(pfecha_reg));
		
	     --// PONE EN VARIABLES LA FECHA SOLICITADA (AAAAMMDD)
		LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0); 
		

		-- Busca en bitacora total de archivos procesados
		
	    select count(*) 
		into  itot_arch
		FROM  BDICHEQ: sc_portacec_bitacora_archivo_cancelaciones
		where fecha_carga=vfecha_reg and archivo=pnombrearchivo
		and estatus_carga ='0';
		
					
		IF   itot_arch > 0  THEN -- TRATA DE VOLVER A CARGAR EL ARCHIVO
		
			LET cCodret = '33333';
			LET cEstatuscarga = '1'; 
			
			
			LET cArchivresp= TRIM(cnombarcpar) || TRIM(vfecha_reg) || '.txt';
			LET cruta_archi=ccancRutaArchivo;
		
		ELSE
		

				--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
			--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'portacanc_tmp2') THEN
				DROP TABLE bdicheq:"informix".portacanc_tmp2;

			END IF
			
		
			--- CREAR LA TABLA DE TEMPORAL
			CREATE TABLE bdicheq:"informix".portacanc_tmp2 (linea CHAR(500));
		
		
			LET cSQL = '';
			--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
			LET cSQL = 'ls ' ||trim(ccancRutaArchivo)||' > '||trim(ccancRutaArchivo)||'carpeta.car';
			SYSTEM cSQL;

			LET cSQL = '';
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET cSQL = 'echo " LOAD FROM '  ||trim(ccancRutaArchivo) || 'carpeta.car' || ' INSERT INTO portacanc_tmp2" > '|| trim(ccancRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			--Let cSQL = 'dbaccess bdicheq ' ||trim(ccancRutaArchivo)|| 'Temporal.sql';   --Se activa para desarrollo   
			LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' ||trim(ccancRutaArchivo)|| 'Temporal.sql'; 
			COMMIT WORK;
			SYSTEM cSQL;
		
		
			BEGIN WORK;
			--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
			FOREACH
				SELECT linea INTO cLinea FROM portacanc_tmp2
				IF cLinea = pNombreArchivo THEN
					LET cBandera = "T";
					EXIT FOREACH;
				END IF
			END FOREACH
		
		
			--- BORRAR LA TABLA TEMPORAL
			DROP TABLE portacanc_tmp2;
				
				--- VALIDA QUE EL ARCHIVO EXISTA
		IF cBandera = "F" THEN			
			LET cCodret = '191';
			LET cEstatuscarga = '1'; 
			LET pnombrearchivo= 'Codigo error 191'; 
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
		
	
		ELSE
	
			-----------------------------------	
			--LIMPIAR LAS TABLAS TEMPORALES
			DELETE FROM sc_portaarchtemp WHERE num_serial is not null;
			
				---------Se carga archivo ( LOAD)---------
			Let cSQL = '';
			Let  cSQL = 'echo "load from '||trim(ccancRutaArchivo) ||trim(pnombrearchivo)||
						' insert into sc_portaarchtemp(columna);" > ' ||trim(ccancRutaArchivo) || 'cargaarchivo.sql';
			System cSQL;
			Let cSQL = '';
			--Let cSQL = 'dbaccess bdicheq '||trim(ccancRutaArchivo) ||'cargaarchivo.sql';  --Se activa para desarrollo
			Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||trim(ccancRutaArchivo) ||'cargaarchivo.sql';   
			COMMIT WORK;
			System cSQL;
			BEGIN WORK;
	
	
			----###############LIMPIA LOS REGISTROS EN BLANCO######################## ----------------------------------------
			 DELETE FROM BDICHEQ:sc_portaarchtemp WHERE LENGTH(TRIM(columna))<=1;
	
			 ------------------------------------------------------------------------------------------	      			
						------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
							--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT columna FROM sc_portaarchtemp WHERE SUBSTR(columna,1,2) NOT IN ("01","02","09")) THEN
				--Existe un tipo de registro que no es autorizado
				LET cCodret = '175';
				LET cEstatuscarga = '1'; 
				LET pnombrearchivo= 'Codigo error 175'; 
				--Obtener los mensajes de retorno 
				SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
			ELSE
	
				--- VALIDA QUE EXISTAN LOS NUMEROS DE REGISTROS CORRESPONDIENTES
				LET iNumReg = 0;
				--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
				SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "01";
				IF iNumReg = 0 THEN
					--No Existe Encabezado en el archivo
					LET cCodret = '176';
					LET cEstatuscarga = '1'; 
					LET pnombrearchivo= 'Codigo error 176'; 
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
					--Existe mas de un Encabezado en el archivo	
					ELIF iNumReg > 1 THEN			
					LET cCodret = '177';
					LET cEstatuscarga = '1'; 
					LET pnombrearchivo= 'Codigo error 177'; 
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
				ELSE
			
					LET iNumReg		= 0;
					--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
					SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "09";
					IF iNumReg = 0 THEN
						--No Existe Sumario en el archivo
						LET cCodret = '178';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 178'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
						
					ELIF iNumReg > 1 THEN
						--Existe mas de un Sumario en el archivo
						LET cCodret = '179';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 179'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
					ELSE
					 
						LET iNumReg		= 0;
						--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
						SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "02";
						IF iNumReg = 0 THEN
							--No Existe Detalle en el archivo
							LET cCodret = '180';
							LET cEstatuscarga = '1'; 
							LET pnombrearchivo= 'Codigo error 180'; 
							--Obtener los mensajes de retorno 
							SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	

						ELSE
	
	
								FOREACH		
													
									SELECT columna INTO cRenglon FROM sc_portaarchtemp ORDER BY(num_serial)		

									--ASIGNACION DE VALORES A LAS VARIABLES
									IF SUBSTR(cRenglon,1,2) = "01" THEN --- ENCABEZADO		
										LET  cnum_secuencia = SUBSTR(cRenglon,3,7);
										LET  ccod_operacion = SUBSTR(cRenglon,10,2);
										LET  cbanco_rec = SUBSTR(cRenglon,12,5);	
										LET  csent_archi = SUBSTR(cRenglon,17,1);	
										LET  cfecha_presentacion = SUBSTR(cRenglon,18,8);

										
									ELIF  SUBSTR(cRenglon,1,2) = "02" THEN --- DETALLE
													LET isecuencia = SUBSTR(cRenglon,3,7);			
													LET ccod_ope   = SUBSTR(cRenglon,10,2);
												    LET cfolio_cancelacion = SUBSTR(cRenglon,12,30);													
													LET cfecha_solicitud = SUBSTR(cRenglon,42,8);
													LET cnombre_cte  = SUBSTR(cRenglon,50,99);
													LET crfc_cte     = SUBSTR(cRenglon,149,13);
													LET ccta_receptora  = SUBSTR(cRenglon,162,18);
													LET ctipo_cta_receptora = SUBSTR(cRenglon,180,2);
													LET cbco_receptor = SUBSTR(cRenglon,182,5);
													LET ccta_ordenante = SUBSTR(cRenglon,187,18);
													LET ctipo_cta_ordenante = SUBSTR(cRenglon,205,2);
													LET cbco_ordenante = SUBSTR(cRenglon,207,5);
													LET cfecha_nacimiento = SUBSTR(cRenglon,212,8);
													LET crfc_empresa = SUBSTR(cRenglon,220,13);
													LET cestatus_respuesta = SUBSTR(cRenglon,233,2);
													LET cfecha_respuesta = SUBSTR(cRenglon,235,8);
													LET ccurp_cte = SUBSTR(cRenglon,243,18);	
										            LET cfolio_solicitud = SUBSTR(cRenglon,261,30);
													
													
													
												IF  bdiprog:isnumeric(isecuencia) <> '1' 
															OR TRIM(ccod_ope) = '' OR (ccod_ope IS null)
															OR TRIM(cfolio_cancelacion) = '' OR (cfolio_cancelacion IS null)
															OR TRIM(cfecha_solicitud) = '' OR (cfecha_solicitud IS null) 
															OR TRIM(cnombre_cte) = '' OR (cnombre_cte IS null) 
															OR TRIM(crfc_cte) = '' OR (crfc_cte IS null) 
															OR TRIM(ccta_receptora) = '' OR (ccta_receptora IS null) 
															OR TRIM(ctipo_cta_receptora) = '' OR (ctipo_cta_receptora IS null)
															OR TRIM(cbco_receptor) = '' OR (cbco_receptor IS null) 
															OR TRIM(ccta_ordenante) = '' OR (ccta_ordenante IS null) 
															OR TRIM(ctipo_cta_ordenante) = ''  OR (ctipo_cta_ordenante IS null) 
															OR TRIM(cbco_ordenante) = ''  OR (cbco_ordenante IS null) 
															OR TRIM(cfecha_nacimiento) = ''  OR (cfecha_nacimiento IS null) 
															OR TRIM(crfc_empresa) = ''  OR (crfc_empresa IS null) 
															OR TRIM(cestatus_respuesta) = ''  OR (cestatus_respuesta IS null) 
															OR TRIM(cfecha_respuesta) = ''  OR (cfecha_respuesta IS null) 
															OR TRIM(ccurp_cte) = ''  OR (ccurp_cte IS null) 
															OR TRIM(cfolio_solicitud) = '' OR (cfolio_solicitud IS null)
															
															THEN
															--Error Un valor nULLOS En EL Archivo
															LET cCodret = '182';
															LET cEstatuscarga = '1'; 
															LET pnombrearchivo= 'Codigo error 182'; 
															--Obtener los mensajes de retorno 
															SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;	
												
												ELSE 
												
												
														-- // INSERTA EN LA TABLA sc_portacec_archfolio registra por cada folio de solicitud la fecha de carga y nombre de archivo 
														
														    			
															select count(*)
															into ivalidafolioexis
															from bdicheq: sc_portacec_archfolio_cancelaciones
															where folio_solicitud = cfolio_solicitud;

															
															IF ivalidafolioexis= 0 THEN -- //CONDICION PARA VALIDAR QUE EL FOLIO NO ESTE DUPLICADO
																		
																		
																update sc_portacec_solicitud
																set cod_operacion='22',
																estatus_portabilidad  = '4',														
																clave_origen='3',
																clave_sentido='0',
																folio_cancelacion = cfolio_cancelacion,
																fecha_solca_portabilidad= vfecha_reg,
																suc_cancela= 'OTBN.',
																user_cancela='informix'
																where folio_solicitud = cfolio_solicitud;			

															END IF
															
															INSERT INTO sc_portacec_archfolio_cancelaciones 
															(fecha_carga, archivo, folio_solicitud,folio_cancelacion,cta_receptora,bco_receptor,cta_ordenante,bco_ordenante )
															values (vfecha_reg,pnombrearchivo,cfolio_solicitud,cfolio_cancelacion,ccta_receptora,cbco_receptor,ccta_ordenante,cbco_ordenante);		
																		
												END IF												
																										
													
									ELIF 	SUBSTR(cRenglon,1,2) = "09" THEN       --- SUMARIO			
													LET cnumsecuencia =   SUBSTR(cRenglon,3,7);
													LET ccodoperacion =   SUBSTR(cRenglon,10,2); 
													LET itotalregistros = SUBSTR(cRenglon,12,7);				
													
										
									END IF	---CONDICION PARA EXTRAER DATOS (ENCABEZADO, DETALLE Y SUMARIO)
						

								END FOREACH		
	
	
		                END IF --VALIDA DETALLE	
							
				    END IF--VALIDA SUMARIO
						
			   END IF	--VALIDA ENCABEZADO

		    END IF -- VALIDA TIPOS DE REGISTROS
			
		END IF-- VALIDACION QUE EL ARCHIVO EXISTA
				
	 END IF -- VALIDA QUE EL ARCHIVO NO SE VUELVA A PROCESAR
		

			INSERT INTO sc_portacec_bitacora_archivo_cancelaciones
			(fecha_carga, fecha_presentacion, archivo, estatus_carga, total_registros)
			values(vfecha_reg,cfecha_presentacion,pnombrearchivo,cEstatuscarga,itotalregistros); 
		

			COMMIT WORK;				
			LET ven_transacc = 0;
					
			RETURN cCodret, cArchivresp, cruta_archi;
		
	END
    END PROCEDURE ;