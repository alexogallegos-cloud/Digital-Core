CREATE PROCEDURE "informix".sp_validasolper(pNumCte varchar(13), pNumCuenta varchar(13), pNumtarjeta CHAR(16))
   RETURNING CHAR(5), CHAR(50), CHAR(6), CHAR(1);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cEstatusProceso CHAR(1);
   DEFINE cNumTarj        CHAR(16);     
   DEFINE cNumCte        CHAR(16);    
   
   LET cCodRet 		      = '00000';   
   LET cDescripcion	      = '';
   LET cIdSolicitud	      = '';
   LET cEstatusProceso    = '';
   LET cNumTarj           = '';
   LET cNumCte           = '';      
      
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/SP_VALIDASOLPER.out";
--	TRACE ON;	
	-- AAME RQM 10 676-2 Se agrega filtro de consulta por Número de tarjeta
	FOREACH
		SELECT MAX(idsolicitud)
		INTO cIdSolicitud
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta 
		--AND numtarjeta = pNumtarjeta
	   
        SELECT estatusproceso 
		INTO  cEstatusProceso
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta AND idsolicitud = cIdSolicitud;



		IF cNumTarj <> "" OR cNumTarj is not null THEN
			SELECT numcliente INTO cNumCte FROM intercard: tarjeta WHERE numcliente = pNumCte AND codstatustarjeta = 'NOA';
		END IF;
		
		IF cEstatusProceso = "V" AND NVL(cNumCte,'') <> '' THEN
			
			SELECT num_tarjeta INTO cNumTarj FROM bdicheq: sc_tarjeta WHERE numcte = pNumCte AND cuenta = pNumCuenta AND status_tar = 'A';
			IF cNumTarj = "" OR cNumTarj is null THEN
				SELECT num_tarjeta INTO cNumTarj FROM bdicred: sd_tarjeta WHERE numcte = pNumCte AND num_credito = pNumCuenta AND status_tar IN('A','I');
			END IF;
			
			IF cNumTarj = "" OR cNumTarj is null THEN
				LET cCodRet = "00000";
				LET cDescripcion = "Solicitud Procesada";					
			ELSE
				LET cCodRet = "00001";
				LET cDescripcion = "Solicitud (Reposición)";
			END IF;
			-- AAME RQM 10 676-2 Se agrega return para que no continue con validación una vez que se tiene resultado
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
		ELIF cEstatusProceso = "F" AND NVL(cNumCte,'') = '' THEN
			LET cCodRet = "00000";
			LET cDescripcion = "Solicitud en Proceso";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
			-- AAME RQM 10 676-2 Se agrega nueva validación no contemplada para indicar que ya se procesó la solicitud y se encuentra activa la tarjeta
		ELIF cEstatusProceso = "V" AND NVL(cNumCte,'') = '' THEN
			LET cCodRet = "00001";
			LET cDescripcion = "Solicitud Procesada";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;			
		END IF;	
	END FOREACH;
			-- AAME RQM 10 676-2 Se completo mas la descripción
	IF cIdSolicitud = "" OR cEstatusProceso = "" OR cIdSolicitud is null OR cEstatusProceso is null THEN
		LET cCodRet = "00001";
		LET cDescripcion = 'Solicitud (Por primera vez) ';		
	END IF;
	
	RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Elmer López Valenzuela',
'FECHA: 03/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar exista una solicitud que no ha sido procesada para el cliente';

CREATE PROCEDURE "informix".sp_validaexistenciatarjetasbandachip(
																pTipoEjecucion INTEGER, 
																pTarjeta VARCHAR(16),
																pSucursal VARCHAR(5),
																pProceso INTEGER)
														   
--DATOS A REGRESAR---
RETURNING CHAR(5)  AS codigo_retorno,
		  CHAR(1)  AS Tarjeta_Banda, 
		  CHAR(1)  AS Tarjeta_Chip, 
          CHAR(1)  AS Asignar_Tarjeta,
          CHAR(1)  AS Proceso;
		 
--DEFINICIÓN DE VARIABLES--
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(5);
DEFINE iRows             INTEGER;
------------------------------------
DEFINE sBanda            CHAR(1);
DEFINE sChip             CHAR(1);
DEFINE iExistencia       INTEGER;
DEFINE iSolicitadas      INTEGER;
DEFINE iCantidad         INTEGER;
DEFINE iClaveTipoTarjeta INTEGER;
DEFINE sAsignarTarjeta   CHAR(1);
DEFINE sProceso          CHAR(1);

DEFINE Dato_iExistencia       INTEGER;
DEFINE Dato_iSolicitadas      INTEGER;


       
--INICIALIZACIÓN DE VARIABLES--
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "Proceso exitóso";
LET cCodRet               = "00000";
LET iRows                 = 0;
------------------------------------
LET sBanda                = "";
LET sChip                 = "";
LET iExistencia           = 0;
LET iSolicitadas          = 0;
LET iCantidad             = 0;
LET iClaveTipoTarjeta     = 0;
LET sAsignarTarjeta       = "";
LET sProceso              = "";

LET Dato_iExistencia           = 0;
LET Dato_iSolicitadas          = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 

	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		   RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;	
		END IF;
			
	END EXCEPTION;
		  
--SET DEBUG FILE TO '/tmp/sp_validaexistenciatarjetasbandachip.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Se valida que los parámetros de entrada no vengan vacíos
	IF NVL(pTipoEjecucion,0) = "" OR NVL(pSucursal,"") = "" THEN 
		-- Parámetros de entrada vacíos
		LET cCodRet = "186";
		RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;			
	END IF;	

    Select valor
      into sProceso
        from bdicred:sd_param
          where cod_param='051';
   
    IF NVL(sProceso,0) = "" OR NVL(sProceso,"") = "" THEN 
		--El tipo de ejecución no corresponde a ningún proceso
        LET cCodRet = "183";
		RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;			
	END IF;	
	
	IF pTipoEjecucion = 1 THEN
        
    -- Se valida la existencia de tarjetas
    /*    SELECT NVL(existencia,0),
	       NVL(solicitadas,0)
	     INTO Dato_iExistencia,
		      Dato_iSolicitadas
	     FROM intercard:"informix".sucursal_tipotarjeta
		WHERE clave_tipotarjeta =3
		  AND SUBSTRING(clave_sucursal FROM 2 FOR 5) = pSucursal;


    -- Se valida la existencia de tarjetas
        SELECT NVL(existencia,0),
	       NVL(solicitadas,0)
	     INTO iExistencia,
		      iSolicitadas
	     FROM intercard:"informix".sucursal_tipotarjeta
		WHERE clave_tipotarjeta =4
		  AND SUBSTRING(clave_sucursal FROM 2 FOR 5) = pSucursal;

		   
	--	LET iRows = DBINFO("sqlca.sqlerrd2");
		-- Se encontraron existencias de tarjetas con banda
	--	IF iRows > 0 THEN	   

		/*	LET iCantidad = iExistencia + iSolicitadas + Dato_iExistencia + Dato_iSolicitadas;

			IF iCantidad < 0 THEN
		    	    LET iCantidad = 0;
			END IF;
			
		

			IF iCantidad > 0 THEN */
				LET sBanda = 0; -- Bin con banda, Proceso Anterior
		   /* ELIF iCantidad = 0 OR iCantidad < 0 THEN */
				LET sChip = 1; -- Bin con CHIP, Proceso Nuevo
           /* ELSE
            	LET cCodRet = '187';  -- No se encontraron existencias de tarjetas    
			END IF; */
		--ELSE
		--	LET cCodRet = '187';  -- No se encontraron existencias de tarjetas
		--END IF;

		RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;	
		
	ELIF pTipoEjecucion = 2 THEN
	
		-- Se valida que el parámetro de entrada pTarjeta no venga vacío
		IF NVL(pTarjeta,"") = "" OR NVL(pProceso,0) = "" THEN 
			-- Parámetro de entrada pTarjeta vacío
			LET cCodRet = "181";
			RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;	
		END IF;		
		
		-- Se valida que el parámetro pProceso corresponda a los procesos 1 y 2
		IF pProceso <> 1 AND pProceso <> 2 THEN
			-- Parámetro de entrada no corresponde a ningún proceso
			LET cCodRet = "182";
			RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;		
		END IF;
	
	   SELECT clave_tipotarjeta
	     INTO iClaveTipoTarjeta
	     FROM intercard:"informix".lote
		WHERE numerolote = (SELECT numerolote FROM intercard:"informix".tarjeta WHERE numtarjeta = pTarjeta)
		  AND clave_sucursal = LPAD(pSucursal,5,0);

		LET iRows = DBINFO("sqlca.sqlerrd2");		
		-- Se encontraron registros
		IF iRows > 0 THEN	
			IF iClaveTipoTarjeta = 4 or iClaveTipoTarjeta = 3 THEN
				IF pProceso = 1 THEN
					LET sAsignarTarjeta = "1"; -- Se debe asignar tarjeta
					LET sBanda = "1";          -- Proceso actual
				ELSE
					LET sAsignarTarjeta = "0"; -- No se debe asignar tarjeta
					LET cCodRet = '184';  -- No se asigna tarjeta porque la clave tipo tarjeta es <> 4	
				END IF;
--	2015.12.08-I - Se agrega el Tipo_Tarjeta = 13 (Transfer):
				ELIF iClaveTipoTarjeta >= 5 THEN
--	2015.12.08-F
				IF pProceso = 2 THEN
					LET sAsignarTarjeta = "1"; -- Se debe asignar tarjeta
					LET sChip = "1";           -- Proceso nuevo
				ELSE
					LET sAsignarTarjeta = "0"; -- No se debe asignar tarjeta
					LET cCodRet = '185';  -- No se asigna tarjeta porque la clave tipo tarjeta es <> 5 o 6
				END IF;
			END IF;
			
			RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;
			
		ELSE
			LET cCodRet = '188';  -- No se encontraron registros del número de tarjeta con el lote		
		END IF;
	
	ELSE
	
		-- El tipo de ejecución no corresponde a ningún proceso
		LET cCodRet = "183";
		
		RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;	
	
	END IF;
	
	RETURN cCodRet, NVL(sBanda,0), NVL(sChip,0), NVL(sAsignarTarjeta,0), sProceso;	
	   
END
END PROCEDURE
DOCUMENT
'Valida la existencia de tarjetas con banda y CHIP',
'AUTOR : Nancy Sevilla Camacho',
'FECHA : 02/12/2011',
'BD    : INTERCARD';

CREATE PROCEDURE "informix".sp_registra_evento(pIdProceso VARCHAR(20),pNumTarjeta VARCHAR(16),pUsuario CHAR(10))

RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

---VARIABLES PARA CAPTURAR ERRORES
DEFINE vNumTarjeta          Varchar(16);
DEFINE vsnumcte 	        CHAR (20);
DEFINE vsCodRet1            CHAR(5);
DEFINE vsCodRet2            CHAR(5);
DEFINE vstelefono	        CHAR(13);
DEFINE vstipotel 	        SMALLINT;
DEFINE vsSecuencia          SMALLINT;
DEFINE vsStatustel	        CHAR(1);
DEFINE vsextension 	   	    CHAR(5);
DEFINE vscarrier	   	    SMALLINT;
DEFINE vsnombrecarrier 	    CHAR(20);
DEFINE vsStatusvalidacion   SMALLINT;
DEFINE vscorreo			    CHAR(100);
DEFINE vstipocorreo		    SMALLINT;
DEFINE vsStatuscorreo       CHAR(1);
DEFINE vsMensaje            CHAR(200);
DEFINE vsString1            VARCHAR(50);  
DEFINE cCodRet              CHAR(5);
DEFINE vsecuencial          integer; 
DEFINE valerta1             varchar(10);
DEFINE valerta2             varchar(10);
DEFINE vIdPlantilla1        varchar(15); 
DEFINE vIdPlantilla2        varchar(15); 
DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
DEFINE vcount               integer;


BEGIN 
 
 ---INICIALIZAN VARIABLES PARA QUERYS
LET vsnumcte           = '';
LET vsCodRet1          = '00000';
LET vsCodRet2          = '00000';
LET vstelefono         = '';
LET vsMensaje          = ''; 
LET vstipotel          = 0;
LET vsSecuencia        = 0;
LET vsStatustel        = '';
LET vsextension        = '';
LET vscarrier          = 0;   
LET vsnombrecarrier    = '';
LET vsStatusvalidacion = 0;
LET vscorreo           = '';
LET vsStatuscorreo     = '';
LET vstipocorreo       = 0;
LET cCodRet = '00000';
LET vsecuencial = 0; 
LET vdFechaInsert      =  sysdate;  
LET vdFechaHoy         =  sysdate;  
LET vcount             = 0; 
 
--set debug file to "/informix/HomeInformix/mgap/sp_registra_evento.out";
--trace on;	

LET vNumTarjeta = pNumTarjeta; 

        IF (pIdProceso = 'REC_SUC') THEN

            LET vIdPlantilla1 ='TJTPERMAIL';    -- plantilla email    
            LET valerta1      ='TJTPERMAIL';    -- alerta email 
            LET vIdPlantilla2 ='TJTPER_SMS';    -- plantilla sms    
            LET valerta2      ='TJTPER_SMS';    -- alerta sms   		         
        
        ELIF (pIdProceso = 'MSJ_NOTIF_SIA') THEN
            
            LET vIdPlantilla1 ='TJEMAILSIA'; 
            LET valerta1      ='TJEMAILSIA'; 
            LET vIdPlantilla2 ='TJTSMS_SIA';
            LET valerta2      ='TJTSMS_SIA'; 

        ELSE
            
            LET vsCodRet1 = '005'; 
            LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
            
            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
            VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
            
            RETURN 	vsCodRet1,vsMensaje; 
        
        END IF;         
         
        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
													  VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');  
 
        SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert   FROM intercard:"informix".bitacoraenvios_tjts  
		where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= pIdProceso;
      
		SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
		WHERE   numtarjeta = vNumTarjeta;
		 
	    IF (vsnumcte <> '' AND vsnumcte is not null  ) THEN  --- De encontrar usuarios le busca primero su contacto celular.

	       EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
		   INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
		   
	        IF vsCodRet1 <> '000' THEN   
			
	                          EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				              INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;         
							  
	                            IF vsCodRet2 <> '000' THEN  
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
 
								 ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											
											    ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                INTO 	cCodRet;
												
												    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF;  
													
												UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
									  
									         ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
											 
	                                          LET vsCodRet1 = '002';
                                              LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje 
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
							    END IF;	
	                            ------------------
	 
	         ELSE 
				    IF (vstelefono <> '' AND vstelefono is not null)  THEN   
					    
						---  INVOCAR  SP REGISTRA EVENTO (SMS) 
						    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
				            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','','',vstelefono,0,0,0,0,0,vdFechaHoy,'')
                            INTO 	cCodRet;
							
								    IF  ( cCodRet <> '00000' )  THEN 
                                        LET vsCodRet1 = '004';
										LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial; 
	                                END IF; 
							
							UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio SMS al titular.' 
                            WHERE secuencial = vsecuencial;
						
	                  ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico. 
									
					        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				            INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
									
							    IF vsCodRet2 <> '000' THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
									
							     ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											  	---  INVOCAR  SP REGISTRA EVENTO (EMAIL) 
												    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
									                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                    INTO 	cCodRet;
													
                                                    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF; 
													
													UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                    WHERE secuencial = vsecuencial; 
													
									         ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
	                                          LET vsCodRet1 = '003';
											  LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
										
							    END IF;	
					END IF;		
			END IF; 	  
	 
	      ELSE  
              LET vsCodRet1 = '001';  
              LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
		  
          UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
          WHERE secuencial = vsecuencial; 		         

	      END IF;   				 
	 
----------------------------------------------------------------------------------------------------------------------------------------------------
RETURN 	vsCodRet1,vsMensaje; 
   
END;
END PROCEDURE;