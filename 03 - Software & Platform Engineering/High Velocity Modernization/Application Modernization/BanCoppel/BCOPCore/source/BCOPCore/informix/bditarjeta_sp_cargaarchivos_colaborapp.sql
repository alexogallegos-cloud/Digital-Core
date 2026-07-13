CREATE PROCEDURE "informix".sp_cargaarchivos_colaborapp ( 
psRuta_Repositorio VARCHAR (90), 
psNomArchivo VARCHAR (30), 
psArchivoOrigen VARCHAR(3), 
piTipoLayOut INTEGER, 
psSistema VARCHAR(1) 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

--DEFINICION DE VARIABLES  
DEFINE vsSQL 				VARCHAR (200) ;
DEFINE viSQLerr 			INTEGER ;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);
DEFINE viTotalRegistros 	INTEGER;
DEFINE vmTotalMonto 		MONEY;
DEFINE viInicioCadena_Reg	INTEGER;
DEFINE viPosMontoReg_Ini 	INTEGER;
DEFINE viPosMontoReg_Fin 	INTEGER;
DEFINE viInicioCadena_Monto	INTEGER;
DEFINE vsTipoSumario 		VARCHAR(35);
DEFINE vsposicion_Regtxn	INTEGER;
DEFINE vsposicion_Montotxn	INTEGER;
DEFINE vsRegistros_txn		VARCHAR(12);
DEFINE vsMonto_txn			VARCHAR(15);
DEFINE vdRegistros_txn		VARCHAR(01);
DEFINE vdsMonto_txn			VARCHAR(01);
DEFINE vsEnc_Monto_Total    MONEY;
DEFINE vregistro            CHAR(600);
DEFINE vregistro2            CHAR(600);
DEFINE vregistro3           CHAR(600);
DEFINE vmonto_row           MONEY;

    --SET DEBUG FILE TO "/informix/mgap/trace_carga_colaborapp.out";
 	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET vsSQL 					= '' ;
LET viSQLerr 				= 0;      
LET vsCodRet 				= '00000';
LET vsMensaje_Respuesta	 	= 'PROCESO EXITOSO';
LET viTotalRegistros 		= 0;
LET vmTotalMonto 			= 0.0;
LET viPosMontoReg_Ini 		= 0;
LET viPosMontoReg_Fin 		= 0;
LET viInicioCadena_Monto	= 0;
LET vsTipoSumario 			= '';
LET vsposicion_Regtxn		= 9;
LET vsposicion_Montotxn		= 18;
LET vsRegistros_txn	 		= ''; 
LET vsMonto_txn				= '';  
LET vdRegistros_txn			= '';
LET vdsMonto_txn			= '';
LET vsEnc_Monto_Total       = 0.0;	
LET vregistro               = ''; 
LET vregistro2               = ''; 
LET vregistro3              = '';  
LET vmonto_row              = 0.0;	
	
	
	BEGIN

		ON EXCEPTION SET viSQLerr
			--LIMPIA LA TABLA
			DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp;
			LET vsCodRet = '00108';
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
		LET vsMensaje_Respuesta = 'GENERAR COMANDO DE CARGA';
		
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos
		   (psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut , psSistema)
            INTO vsCodRet, vsMensaje_Respuesta;
            
        IF ( vsCodRet  <> '00000' ) THEN

		    LET vsMensaje_Respuesta = 'ERROR EN LA CARGA';
		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
            
        END IF

		IF (NOT EXISTS (SELECT Registro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp  
		WHERE Registro MATCHES 'HEADER*')) THEN  
 
			LET vsTipoSumario = 'ERROR HEADER';

		ELIF (NOT EXISTS (SELECT Registro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp  
		WHERE Registro MATCHES 'TRAILER*')) THEN  
 
			LET vsTipoSumario = 'ERROR TRAILER';	

			-- ########################### Layout de Depositos Colaborapp   ##########################################
			
		ELIF (piTipoLayOut = 9) THEN 

			SELECT FIRST 1 
				( SUBSTR(Registro, vsposicion_Regtxn, 8)) AS Registros_txn,  --TOTAL REGISTROS 
				--( SUBSTR(Registro, vsposicion_Montotxn, 15)) AS Monto_txn	--MONTO TOTAL
                 --((( SUBSTR(Registro, vsposicion_Montotxn, 15))::MONEY)/100) AS Monto_txn	--MONTO TOTAL				
				 SUBSTR(Registro, vsposicion_Montotxn, 15) AS Monto_txn	--MONTO TOTAL
				INTO 
				vsRegistros_txn,
				vsMonto_txn
				FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp 
				WHERE Registro MATCHES 'TRAILER*';

			    --BORRA LOS REGISTROS DE ENCABEZADO		
			     DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE (Registro MATCHES 'HEADER*');

			    ---COSECHA MARCOS  BORRA EL TRAILER 
	      	    DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE (Registro MATCHES 'TRAILER*');
				 
		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT
		
			LET vsTipoSumario = 'ERROR LAYOUT';
  	
		END IF; -- IF (1)
 
        LET vsTipoSumario = vsTipoSumario;
		---------------------------
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN  

			LET vsCodRet = '00100';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
		
		ELIF (TRIM(vsTipoSumario) = 'ERROR TRAILER') THEN 	
		 	
			LET vsCodRet = '00101';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL TRAILER CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
 
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN  
			
			LET vsCodRet = '00102';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
		ELIF (NOT EXISTS (SELECT TRIM(Registro) FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE Registro MATCHES (vsTipoSumario || '*'))) THEN --NO CONTIENE REGISTRO DE SUMARIO
		    
            IF  vsRegistros_txn > 0 then
			
			  LET vsCodRet = '00103';
			  LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';
			END IF;
			
		ELSE
		
		    LET vsMensaje_Respuesta = 'VALIDAR REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn  )    INTO vdsMonto_txn;  
		
		END IF; -- IF (2)	


		 IF ( vsCodRet  <> '00000' ) THEN

		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
            
        END IF
		
		IF (vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTRO NO NUMERICO.';
			RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
			
		ELIF (vdsMonto_txn = 'F') THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
		
		ELSE -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
	
			LET vsMensaje_Respuesta = 'TODOS SOMOS NUMEROS';
	
		END IF; -- IF (2.3)
 
		    --Obtiene el numero de registros del archivo y las compara con el total 
			select count(registro) into vitotalregistros from bditarjeta:"informix".td_carga_archivo_colaborapp;
			let vsmensaje_respuesta = 'Validar discrepancias en el total sumario/trailer vs archivo.';
			if ((vitotalregistros) <> (vsRegistros_txn) ) then --valida lo reportado en el sumario con el contenido el archivo
				let vscodret = '00106'; --cantidades distintas de registros
				let vsmensaje_respuesta = '[' || vscodret ||  ']El archivo (' || trim(psnomarchivo) || ') contiene discrepancias en el total de registros reportados '|| vitotalregistros ||' y los contenidos '|| vsRegistros_txn ||' en el archivo.';
				let vitotalregistros = 0;
				 RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
			End if;
	 
	        --VALIDA DIFERENCIAS EN EL MONTO DEL ARCHIVO
		    	 -- respaldo SELECT SUM((((SUBSTR(registro,23,13))::MONEY)/100)) INTO vsEnc_Monto_Total FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp; 
				
				LET vsMonto_txn =  ((vsMonto_txn::MONEY)/100); 
				
				FOREACH cursor_money WITH HOLD FOR 
				
				          SELECT Registro INTO vregistro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp
						  
				            LET  vmonto_row = NVL(((SUBSTR(vregistro,23,13))::MONEY)/100,0);
				            LET  vsEnc_Monto_Total = vsEnc_Monto_Total + vmonto_row;
			 	
				END FOREACH;				
				 ---------------
			  	IF (vsMonto_txn <> vsEnc_Monto_Total)  THEN --VALIDA QUE EL MONTO REPORTADO EN EL SUMARIO CON EL CONTENIDO EL ARCHIVO 
						LET vsCodRet = '00107'; --CANTIDADES DISTINTAS DE MONTOS
						LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || trim(psNomArchivo) || ') CONTIENE DISCREPANCIAS EN EL MONTO TOTAL REPORTADO Y EL CONTENIDO(' || vsEnc_Monto_Total || ').';
				END IF;
	            ---------------
				FOREACH cursor_form_date WITH HOLD FOR 
				 
						  SELECT  TRIM(SUBSTRING (Registro FROM 74 FOR 2 )),  --  Fecha_consumo (DD)  	  
						          TRIM(SUBSTRING (Registro FROM 76 FOR 2 )),  --  Fecha_consumo (MM)  	  
						          TRIM(SUBSTRING (Registro FROM 78 FOR 2 ))  --  Fecha_consumo (AA)
								  INTO vregistro,vregistro2, vregistro3	  
				          FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp
                            
                          IF vregistro between '01' and '31' THEN 
						     ELSE 							 
							 LET vsCodRet = '00109';
			                 LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE FORMATO DE FECHA INCORRECTA';
						  END IF; 	
							
						  IF (vregistro2 between '01' and '12') THEN 
						     ELSE 
							  LET vsCodRet = '00109';
			                  LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE FORMATO DE FECHA INCORRECTA';
                          END IF; 	
							  
                          IF vregistro3 >= '21' THEN  
						     ELSE 							 
							 LET vsCodRet = '00109';
			                 LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ')  CONTIENE FORMATO DE FECHA INCORRECTA';
						  END IF; 	 
				END FOREACH;	
				--------------
		  RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
		
	END

END PROCEDURE;