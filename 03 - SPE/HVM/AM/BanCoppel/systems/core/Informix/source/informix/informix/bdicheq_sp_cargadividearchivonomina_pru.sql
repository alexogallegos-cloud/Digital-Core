CREATE PROCEDURE "informix".sp_cargadividearchivonomina_pru(pnombrearchivo CHAR(20))
RETURNING CHAR(5), CHAR(16), CHAR(50);

    ---- VARIABLES  GENERALES---
    DEFINE cSqlerr			 INTEGER;
    DEFINE cCodret      	 CHAR(5);
    DEFINE cCodret2      	 CHAR(3);
    DEFINE cNombreArchivo    CHAR(23);
    DEFINE vsSQL    CHAR(100);
    DEFINE cFolio CHAR(16);
    DEFINE cRuta CHAR(60);
    DEFINE cMensaje CHAR(50);
    Define cSQL CHAR(250);
    DEFINE cLinea LVARCHAR(500);
    DEFINE cBandera CHAR(1);
    DEFINE cBan INTEGER;
    DEFINE iContador SMALLINT;
    DEFINE iNumCaracteres INTEGER;
    DEFINE iNumReg INTEGER;
    Define cRenglon CHAR(134);
    DEFINE dFecha1 DATE;
    DEFINE dFecha2 DATE;

    --Variables de encabezado
    Define cTipoRegistroE CHAR(1);  --clave para identificar registro  (1)
    Define cSecuenciaE CHAR(5);      --numero de archivos en el dia
    Define cSentidoE CHAR(1);               --control bancoppel
    Define cFechaGenE CHAR(8);      --fecha generacion
    Define cCuentaCargoE CHAR(16);  --cuenta cargo
    Define cFechaAplicE CHAR(8);      --fecha para aplicacion
    Define clf_crE CHAR(2);                --control fin de linea

    --Variables de detalle
    Define cTipoRegistroD CHAR(1);                 --clave para identificar registro  (2)
    Define cSecuenciaD CHAR(5); 	          --numero de archivos en el dia
    Define cNumeroEmpleadoD CHAR(8);     --clave del empleado
    Define cApellidoPaternoD CHAR(30);      --ape del empleado
    Define cApellidoMaternoD CHAR(20);    --ape del empleado
    Define cNombreD CHAR(30);                  --nombre del empleado
    Define cCuentaAbonoD CHAR(16);        --cuenta destino del empleado
    Define cConceptoD CHAR(2);                --no existe en el layout, incluirlo para saber el motivo del depósito
    Define cImporteD CHAR(18);                   --importe a pagar
    Define clf_crD CHAR(2);                          --control fin de linea

    --Variables de  sumario
    Define cTipoRegistroS CHAR(1);          --clave para identificar registro  (3)
    Define cSecuenciaS CHAR(5);           --numero de archivo en el dia
    Define cTotalRegistrosS CHAR(5);    --total de empleados que van en el archivo
    Define cImporteTotalS CHAR(18);    --total a pagar de los empleados
    Define clf_crS CHAR(2);  

    DEFINE vexiste SMALLINT;
    DEFINE vexistehist SMALLINT;
    
    DEFINE iCtas INTEGER;
    DEFINE iCuenta INTEGER;
    DEFINE iSumCuentas INTEGER;
    DEFINE mImporte INTEGER;
    DEFINE mSumImporte MONEY(18,2);
    
    -- // VALORES INICIALES
    LET cSqlerr = '';
    LET cCodret = '00000';
    LET cCodret2 = '000';
    LET cNombreArchivo = '';
    LET vsSQL    = '';
    LET cFolio = '';
    LET cRuta = '';
    LET cSQL = '';
    LET cLinea = '';
    LET cRenglon = '';
    LET cBandera = "F";
    LET iContador = 0;
    LET iNumCaracteres = 0;
    LET iNumReg = 0;
    LET cBan = 0;
    LET dFecha1 = CURRENT;
    LET dFecha2 = CURRENT;
    LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE';

    --Variables de encabezado
    LET cTipoRegistroE = '';  
    LET cSecuenciaE = '';      
    LET cSentidoE = '';               
    LET cFechaGenE = '';       
    LET cCuentaCargoE = '';   
    LET cFechaAplicE = '';      
    LET clf_crE = '';               

    --Variables de detalle
    LET cTipoRegistroD = '';                  
    LET cSecuenciaD = ''; 	          
    LET cNumeroEmpleadoD = '';    
    LET cApellidoPaternoD = '';      
    LET cApellidoMaternoD = '';    
    LET cNombreD = '';                  
    LET cCuentaAbonoD = '';       
    LET cConceptoD = '';              
    LET cImporteD = '';                   
    LET clf_crD = '';                      

    --Variables de  sumario
    LET cTipoRegistroS = '';          
    LET cSecuenciaS = '';            
    LET cTotalRegistrosS = '';     
    LET cImporteTotalS = '';    
    LET clf_crS = '';
    LET vexiste = 0;
    LET vexistehist = 0;
    
    LET iCtas = 0;
    LET iCuenta = 0;
    LET iSumCuentas = 0;
    LET mImporte = 0;
    LET mSumImporte = 0.00;
    
     SET debug FILE TO "/tmp/Sp_CargaDivideArchivoNomina.out";
     Trace ON;
    
    BEGIN
    
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret, cFolio, cMensaje;
        END IF;
	END EXCEPTION;
    
    SELECT COUNT(*)
      INTO vexistehist
      FROM sc_nominaencabezadosumariohist
     WHERE nombre_archivo = pnombrearchivo;
     
    SELECT COUNT(*)
      INTO vexiste
      FROM sc_nominaencabezadosumario
     WHERE nombre_archivo = pnombrearchivo;
     
    IF vexistehist > 0 OR vexiste > 0 THEN
        LET cCodret = '';    
        RETURN cCodret, cFolio, cMensaje;
    END IF;
	
	-- // Se leerá de la tabla de parámetros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, número de contrato, etc.).
	SELECT valor 
      INTO cRuta 
	  FROM bdicheq:sc_param 
	 WHERE empresa = "001" 
	   AND codparam = 'NomRutaDestino';
       
	--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
	--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'Nomi_tmp2') THEN
		DROP TABLE Nomi_tmp2;
	END IF

	--- CREAR LA TABLA DE TEMPORAL
	CREATE TABLE Nomi_tmp2 (linea LVARCHAR(500));

	LET cSQL = '';
	--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
	LET cSQL = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'carpeta.car';
	SYSTEM cSQL;

	LET cSQL = '';
	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSQL = 'echo "LOAD FROM ' || TRIM(cRuta) || 'carpeta.car' || ' INSERT INTO Nomi_tmp2" > '|| TRIM(cRuta) || 'Temporal.sql';
	SYSTEM cSQL;

	LET cSQL = '';
	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(cRuta) || 'Temporal.sql';
	SYSTEM cSQL;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    
	--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea 
          INTO cLinea 
          FROM Nomi_tmp2
          
		IF cLinea = pNombreArchivo THEN
			LET cBandera = "T";
			EXIT FOREACH;
		END IF
	END FOREACH

	--- BORRAR LA TABLA TEMPORAL
	DROP TABLE Nomi_tmp2;

	--- VALIDA QUE EL ARCHIVO EXISTA
	IF cBandera = "F" THEN
		--LET cMensaje = 'El Archivo no Existe en la ruta parametrizada';
		LET cCodret = '191';
        
		--Obtener los mensajes de retorno 
		SELECT DESCRIPCION 
          INTO cMensaje 
          FROM bdinteg:si_codret 
         WHERE sistema = '01' 
           AND codigo_retorno = cCodret;
           
		RETURN cCodret, cFolio, cMensaje;
	ELSE
		-----------------------------------	
		-- // LIMPIAR LAS TABLAS TEMPORALES
		DELETE FROM sc_NominaArchTemp 
         WHERE num_serial is not null;
         
		DELETE FROM sc_nominaencabezadosumariotemp 
         WHERE nombre_archivo = pNombreArchivo;
         
		DELETE FROM sc_nominamovimientostemp 
         WHERE nombre_archivo = pNombreArchivo;

		---------Se carga archivo ( LOAD)---------
		Let cSQL = '';
		Let  cSQL = 'echo "load from '||TRIM(cRuta) || TRIM(pNombreArchivo) ||
					' insert into sc_NominaArchTemp(columna); " > '||TRIM(cRuta) ||'querynom.sql';
		System cSQL;
		Let cSQL = '';
		--- Let cSQL = 'dbaccess bdicheq '||TRIM(cRuta) ||'querynom.sql';  --Se activa para desarrollo   
		Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||TRIM(cRuta) ||'querynom.sql ';  --Se activa para Produccion
		System cSQL;
		------------------------------------------------------------------------------------------
		------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
		--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
		IF EXISTS(SELECT columna FROM sc_NominaArchTemp WHERE SUBSTR(columna,1,1) NOT IN ("1","2","3")) THEN
			--Existe un tipo de registro que no es autorizado
			LET cCodret = '175';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		--- VALIDA QUE EXISTAN LOS NUEMROS DE REGISTROS CORRESPONDIENTES
		LET iNumReg = 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM  sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "1";
         
		IF iNumReg = 0 THEN
			--No Existe Encabezado en el archivo
			LET cCodret = '176';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Encabezado en el archivo
			LET cCodret = '177';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		LET iNumReg		= 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "3";
         
		IF iNumReg = 0 THEN
			--No Existe Sumario en el archivo
			LET cCodret = '178';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Sumario en el archivo
			LET cCodret = '179';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		LET iNumReg	= 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "2";
         
		IF iNumReg = 0 THEN
			--No Existe Detalle en el archivo
			LET cCodret = '180';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'Nomi_tmp_secuencia') THEN
			DROP TABLE Nomi_tmp_secuencia;
		END IF
        
		---VALIDAR LA SECUENCIA DE LOS REGISTROS
		--- CREAR LA TABLA DE SECUENCIA
		CREATE TABLE Nomi_tmp_secuencia (secuencia CHAR(5));
				
		INSERT INTO Nomi_tmp_secuencia
		SELECT SUBSTR(columna,2,5) AS SECUENCIA 
          FROM bdicheq:sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "2" ;
         
		---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
		IF EXISTS(SELECT SECUENCIA FROM Nomi_tmp_secuencia GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
			DROP TABLE Nomi_tmp_secuencia;
			--La secuencia en el detalle no es correcta
			LET cCodret = '181';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		---BORRAR LA TABLA DE SECUENCIA
		DROP TABLE Nomi_tmp_secuencia;
        
		---------Se valida la estructura del archivo---------
		FOREACH
			SELECT columna 
              INTO cRenglon 
              FROM sc_NominaArchTemp 
             ORDER BY(num_serial)
             
			--ASIGNACION DE VALORES A LAS VARIABLES
			IF SUBSTR(cRenglon,1,1) = "1" THEN --- ENCABEZADO
				LET cTipoRegistroE = SUBSTR(cRenglon,1,1);  
				LET cSecuenciaE = SUBSTR(cRenglon,2,5);      
				LET cSentidoE = SUBSTR(cRenglon,7,1);               
				LET cFechaGenE = SUBSTR(cRenglon,8,8);       
				LET cCuentaCargoE = SUBSTR(cRenglon,16,16);   
				LET cFechaAplicE = SUBSTR(cRenglon,32,8); 
                
				--Validar si son nullos
				IF TRIM(cTipoRegistroE) = '' OR (cTipoRegistroE IS null) OR TRIM(cSecuenciaE) = '' OR (cSecuenciaE IS null) OR 
				   TRIM(cSentidoE) = '' OR (cSentidoE IS null) OR TRIM(cFechaGenE) = '' OR (cFechaGenE IS null) OR
				   TRIM(cCuentaCargoE) = '' OR (cCuentaCargoE IS null) OR TRIM(cFechaAplicE) = '' OR (cFechaAplicE IS null)  THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroE) <> '1' OR bdiprog:isnumeric(cSecuenciaE) <> '1' OR  bdiprog:isnumeric(cFechaGenE) <> '1' 
					OR bdiprog:isnumeric(cCuentaCargoE) <> '1' OR bdiprog:isnumeric(cFechaAplicE) <> '1'THEN
					--Error Un valor No Es  Numerico En Encabezado
					LET cCodret = '183';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--Validar si son cadenas
				IF bdiprog:isnumeric(cSentidoE) <> '0' THEN
					--Error Un valor Es  Numerico En Encabezado
					LET cCodret = '184';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaGenE,1,2) > 0 AND  SUBSTR(cFechaGenE,1,2) < 13) AND (SUBSTR(cFechaGenE,3,2) > 0 AND SUBSTR(cFechaGenE,3,2) < 32) 
					AND (SUBSTR(cFechaGenE,5,4) > 2000 AND SUBSTR(cFechaGenE,5,4) < 3000 ) )  THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaAplicE,1,2) > 0 AND  SUBSTR(cFechaAplicE,1,2) < 13) AND (SUBSTR(cFechaAplicE,3,2) > 0 AND SUBSTR(cFechaAplicE,3,2) < 32) 
					AND (SUBSTR(cFechaAplicE,5,4) > 2000 AND SUBSTR(cFechaAplicE,5,4) < 3000)) THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				LET cBan = cBan + 1;
                
			ELIF SUBSTR(cRenglon,1,1) = "2" THEN --- DETALLE
            
				LET cTipoRegistroD = SUBSTR(cRenglon,1,1);                  
				LET cSecuenciaD = SUBSTR(cRenglon,2,5); 	          
				LET cNumeroEmpleadoD = SUBSTR(cRenglon,7,8);    
				LET cApellidoPaternoD = SUBSTR(cRenglon,15,30);      
				LET cApellidoMaternoD = SUBSTR(cRenglon,45,20);    
				LET cNombreD = SUBSTR(cRenglon,65,30);                  
				LET cCuentaAbonoD = SUBSTR(cRenglon,95,16);       
				LET cConceptoD = SUBSTR(cRenglon,111,2);              
				LET cImporteD = SUBSTR(cRenglon,113,18);  
                
				--Validar si son nullos
				IF TRIM(cTipoRegistroD) = '' OR (cTipoRegistroD IS null) OR TRIM(cSecuenciaD) = '' OR (cSecuenciaD IS null) OR 
				   TRIM(cNumeroEmpleadoD) = '' OR (cNumeroEmpleadoD IS null) OR TRIM(cApellidoPaternoD) = '' OR (cApellidoPaternoD IS null) OR
				   TRIM(cApellidoMaternoD) = '' OR (cApellidoMaternoD IS null) OR TRIM(cNombreD) = '' OR (cNombreD IS null) OR 
				   TRIM(cCuentaAbonoD) = '' OR (cCuentaAbonoD IS null) OR TRIM(cConceptoD) = '' OR (cConceptoD IS null) OR TRIM(cImporteD) = '' 
				   OR (cImporteD IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;	
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroD) <> '1' OR bdiprog:isnumeric(cSecuenciaD) <> '1' --OR  bdiprog:isnumeric(cNumeroEmpleadoD) <> '1' 
					OR bdiprog:isnumeric(cCuentaAbonoD) <> '1' OR bdiprog:isnumeric(cConceptoD) <> '1' OR bdiprog:isnumeric(cImporteD) <> '1' THEN
					--Error Un valor No Es  Numerico En detalle
					LET cCodret = '187';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--HAcer el inser a la temporal para una siguiente validacion
				INSERT INTO sc_nominamovimientostemp 
                (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
				VALUES 
                (pNombreArchivo, cNumeroEmpleadoD, cApellidoPaternoD, cApellidoMaternoD, cNombreD, cCuentaAbonoD, (cImporteD), cConceptoD, '0');
                
                /* #########################################################
                LET iCtas = iCtas + 1;
                
                LET iCuenta = SUBSTR(cCuentaAbonoD,3,9)::INTEGER;
                LET iSumCuentas = iSumCuentas + iCuenta;
                
                --- LET mImporte = cImporteD::INTEGER;
                LET mSumImporte = mSumImporte + (cImporteD);
                ######################################################### */
			ELIF SUBSTR(cRenglon,1,1) = "3" THEN --- SUMARIO
            
				LET cTipoRegistroS = SUBSTR(cRenglon,1,1);          
				LET cSecuenciaS = SUBSTR(cRenglon,2,5);            
				LET cTotalRegistrosS = SUBSTR(cRenglon,7,5);     
				LET cImporteTotalS = SUBSTR(cRenglon,12,18);  
                    
				--Validar si son nullos
				IF TRIM(cTipoRegistroS) = '' OR (cTipoRegistroS IS null) OR TRIM(cSecuenciaS) = '' OR (cSecuenciaS IS null) OR 
				   TRIM(cTotalRegistrosS) = '' OR (cTotalRegistrosS IS null) OR TRIM(cImporteTotalS) = '' OR (cImporteTotalS IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroS) <> '1' OR bdiprog:isnumeric(cSecuenciaS) <> '1' OR  bdiprog:isnumeric(cTotalRegistrosS) <> '1' 
					OR bdiprog:isnumeric(cImporteTotalS) <> '1' THEN
					--Error Un valor No Es  Numerico En Sumario
					LET cCodret = '189';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				LET cBan = cBan + 1;
			END IF;            
		END FOREACH;
        
        /* #######################################################################################################################################################
        INSERT INTO sc_cifr_ctl_disp
        ( nombre_archivo, fecha_aplicacion, no_cuentas, suma_cuentas, suma_importe )
        VALUES
        ( pNombreArchivo, SUBSTR(cFechaAplicE,1,2)||'/'||SUBSTR(cFechaAplicE,3,2)||'/'||SUBSTR(cFechaAplicE,5,4), iCtas, iSumCuentas, (mSumImporte / 100) );
        ####################################################################################################################################################### */
        
        IF cBan = 2 THEN--06302009   2009-06-30    empresa + fecha + folio (2)     aaaammdd   mmddaaaa
		--- LET cFechaFormateada = SUBSTR(cFecha_presentacionD,5,2) ||'/'|| SUBSTR(cFecha_presentacionD,7,2) ||'/'|| SUBSTR(cFecha_presentacionD,1,4);
			INSERT INTO sc_nominaencabezadosumariotemp 
            ( empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot, status, fecha_insert )
			VALUES 
            ( SUBSTR(pNombreArchivo,1,3), SUBSTR(cFechaGenE,1,2)||'/'||SUBSTR(cFechaGenE,3,2)||'/'||SUBSTR(cFechaGenE,5,4), SUBSTR(pNombreArchivo,12,2), pNombreArchivo, 
              cSentidoE, cCuentaCargoE, SUBSTR(cFechaAplicE,1,2)||'/'||SUBSTR(cFechaAplicE,3,2)||'/'||SUBSTR(cFechaAplicE,5,4), cTotalRegistrosS, (cImporteTotalS), '0', CURRENT );
		ELSE
			--No se Obtubo Encabezado o Suamrio
			LET cCodret = '190';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF;
        
        -- Se manda llamar el sp sp_validadatostempnomina
		EXECUTE PROCEDURE bdicheq:sp_validadatostempnomina(SUBSTR(pNombreArchivo,1,3), SUBSTR(cFechaGenE,1,2)||'/'||SUBSTR(cFechaGenE,3,2)||'/'||SUBSTR(cFechaGenE,5,4), SUBSTR(pNombreArchivo,12,2)) 
        INTO cCodret2,cFolio;
        
		IF cCodret2 <> '000' THEN
			--Error en el sp de valida datos
			--192 - 199
			IF cCodret2 = '600' THEN
				LET cCodret = '192';
			ELIF cCodret2 = '100' THEN
				LET cCodret = '193';
			ELIF cCodret2 = '150' THEN
				LET cCodret = '194';
			ELIF cCodret2 = '200' THEN
				LET cCodret = '195';
			ELIF cCodret2 = '250' THEN
				LET cCodret = '196';
			ELIF cCodret2 = '550' THEN
				LET cCodret = '197';
			ELIF cCodret2 = '300' THEN
				LET cCodret = '198';
			ELIF cCodret2 = '350' THEN
				LET cCodret = '199';
			ELIF cCodret2 = '400' THEN
				LET cCodret = '186';
			ELIF cCodret2 = '450' THEN
				LET cCodret = '188';
			END IF;
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio,cMensaje;
		END IF;
		--------------------------------------------------------------
	END IF;
    
	RETURN cCodret, cFolio, cMensaje;
    
    END;
    
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de validar si existe el archivo en la ruta parametrizada, ',
'             ademas divide el archivo y valida la estrutura del archivo, junto con la integridad de ',
'             los datos, y manda llamar el procedimiento que valida el archivo',
'FECHA : Septiembre de 2009',
'BD    : BDICHEQ',
'VERSION: 20090908.0400';

CREATE PROCEDURE "informix".sp_cargadividearchivonomina(pnombrearchivo CHAR(20))
RETURNING CHAR(5), CHAR(16), CHAR(50);

    ---- VARIABLES  GENERALES---
    DEFINE cSqlerr			 INTEGER;
    DEFINE cCodret      	 CHAR(5);
    DEFINE cCodret2      	 CHAR(3);
    DEFINE cNombreArchivo    CHAR(23);
    DEFINE vsSQL    CHAR(100);
    DEFINE cFolio CHAR(16);
    DEFINE cRuta CHAR(60);
    DEFINE cMensaje CHAR(50);
    Define cSQL CHAR(250);
    DEFINE cLinea LVARCHAR(500);
    DEFINE cBandera CHAR(1);
    DEFINE cBan INTEGER;
    DEFINE iContador SMALLINT;
    DEFINE iNumCaracteres INTEGER;
    DEFINE iNumReg INTEGER;
    Define cRenglon CHAR(134);
    DEFINE dFecha1 DATE;
    DEFINE dFecha2 DATE;

    --Variables de encabezado
    Define cTipoRegistroE CHAR(1);  --clave para identificar registro  (1)
    Define cSecuenciaE CHAR(5);      --numero de archivos en el dia
    Define cSentidoE CHAR(1);               --control bancoppel
    Define cFechaGenE CHAR(8);      --fecha generacion
    Define cCuentaCargoE CHAR(16);  --cuenta cargo
    Define cFechaAplicE CHAR(8);      --fecha para aplicacion
    Define clf_crE CHAR(2);                --control fin de linea

    --Variables de detalle
    Define cTipoRegistroD CHAR(1);                 --clave para identificar registro  (2)
    Define cSecuenciaD CHAR(5); 	          --numero de archivos en el dia
    Define cNumeroEmpleadoD CHAR(8);     --clave del empleado
    Define cApellidoPaternoD CHAR(30);      --ape del empleado
    Define cApellidoMaternoD CHAR(20);    --ape del empleado
    Define cNombreD CHAR(30);                  --nombre del empleado
    Define cCuentaAbonoD CHAR(16);        --cuenta destino del empleado
    Define cConceptoD CHAR(2);                --no existe en el layout, incluirlo para saber el motivo del depósito
    Define cImporteD CHAR(18);                   --importe a pagar
    Define clf_crD CHAR(2);                          --control fin de linea

    --Variables de  sumario
    Define cTipoRegistroS CHAR(1);          --clave para identificar registro  (3)
    Define cSecuenciaS CHAR(5);           --numero de archivo en el dia
    Define cTotalRegistrosS CHAR(5);    --total de empleados que van en el archivo
    Define cImporteTotalS CHAR(18);    --total a pagar de los empleados
    Define clf_crS CHAR(2);  

    DEFINE vexiste SMALLINT;
    DEFINE vexistehist SMALLINT;
    
    DEFINE iCtas INTEGER;
    DEFINE iCuenta INTEGER;
    DEFINE iSumCuentas INTEGER;
    DEFINE mImporte INTEGER;
    DEFINE mSumImporte MONEY(18,2);
    
    -- // VALORES INICIALES
    LET cSqlerr = '';
    LET cCodret = '00000';
    LET cCodret2 = '000';
    LET cNombreArchivo = '';
    LET vsSQL    = '';
    LET cFolio = '';
    LET cRuta = '';
    LET cSQL = '';
    LET cLinea = '';
    LET cRenglon = '';
    LET cBandera = "F";
    LET iContador = 0;
    LET iNumCaracteres = 0;
    LET iNumReg = 0;
    LET cBan = 0;
    LET dFecha1 = CURRENT;
    LET dFecha2 = CURRENT;
    LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE';

    --Variables de encabezado
    LET cTipoRegistroE = '';  
    LET cSecuenciaE = '';      
    LET cSentidoE = '';               
    LET cFechaGenE = '';       
    LET cCuentaCargoE = '';   
    LET cFechaAplicE = '';      
    LET clf_crE = '';               

    --Variables de detalle
    LET cTipoRegistroD = '';                  
    LET cSecuenciaD = ''; 	          
    LET cNumeroEmpleadoD = '';    
    LET cApellidoPaternoD = '';      
    LET cApellidoMaternoD = '';    
    LET cNombreD = '';                  
    LET cCuentaAbonoD = '';       
    LET cConceptoD = '';              
    LET cImporteD = '';                   
    LET clf_crD = '';                      

    --Variables de  sumario
    LET cTipoRegistroS = '';          
    LET cSecuenciaS = '';            
    LET cTotalRegistrosS = '';     
    LET cImporteTotalS = '';    
    LET clf_crS = '';
    LET vexiste = 0;
    LET vexistehist = 0;
    
    LET iCtas = 0;
    LET iCuenta = 0;
    LET iSumCuentas = 0;
    LET mImporte = 0;
    LET mSumImporte = 0.00;
    
    --- SET debug FILE TO "/resplogifx/Sp_CargaDivideArchivoNomina.out";
    --- Trace ON;
    
    BEGIN
    
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret, cFolio, cMensaje;
        END IF;
	END EXCEPTION;
    
    SELECT COUNT(*)
      INTO vexistehist
      FROM sc_nominaencabezadosumariohist
     WHERE nombre_archivo = pnombrearchivo;
     
    SELECT COUNT(*)
      INTO vexiste
      FROM sc_nominaencabezadosumario
     WHERE nombre_archivo = pnombrearchivo;
     
    IF vexistehist > 0 OR vexiste > 0 THEN
        LET cCodret = '';    
        RETURN cCodret, cFolio, cMensaje;
    END IF;
	
	-- // Se leerá de la tabla de parámetros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, número de contrato, etc.).
	SELECT valor 
      INTO cRuta 
	  FROM bdicheq:sc_param 
	 WHERE empresa = "001" 
	   AND codparam = 'NomRutaDestino';
       
	--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
	--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'Nomi_tmp2') THEN
		DROP TABLE Nomi_tmp2;
	END IF

	--- CREAR LA TABLA DE TEMPORAL
	CREATE TABLE Nomi_tmp2 (linea LVARCHAR(500));

	LET cSQL = '';
	--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
	LET cSQL = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'carpeta.car';
	SYSTEM cSQL;

	LET cSQL = '';
	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSQL = 'echo "LOAD FROM ' || TRIM(cRuta) || 'carpeta.car' || ' INSERT INTO Nomi_tmp2" > '|| TRIM(cRuta) || 'Temporal.sql';
	SYSTEM cSQL;

	LET cSQL = '';
	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(cRuta) || 'Temporal.sql';
	SYSTEM cSQL;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    
	--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea 
          INTO cLinea 
          FROM Nomi_tmp2
          
		IF cLinea = pNombreArchivo THEN
			LET cBandera = "T";
			EXIT FOREACH;
		END IF
	END FOREACH

	--- BORRAR LA TABLA TEMPORAL
	DROP TABLE Nomi_tmp2;

	--- VALIDA QUE EL ARCHIVO EXISTA
	IF cBandera = "F" THEN
		--LET cMensaje = 'El Archivo no Existe en la ruta parametrizada';
		LET cCodret = '191';
        
		--Obtener los mensajes de retorno 
		SELECT DESCRIPCION 
          INTO cMensaje 
          FROM bdinteg:si_codret 
         WHERE sistema = '01' 
           AND codigo_retorno = cCodret;
           
		RETURN cCodret, cFolio, cMensaje;
	ELSE
		-----------------------------------	
		-- // LIMPIAR LAS TABLAS TEMPORALES
		DELETE FROM sc_NominaArchTemp 
         WHERE num_serial is not null;
         
		DELETE FROM sc_nominaencabezadosumariotemp 
         WHERE nombre_archivo = pNombreArchivo;
         
		DELETE FROM sc_nominamovimientostemp 
         WHERE nombre_archivo = pNombreArchivo;

		---------Se carga archivo ( LOAD)---------
		Let cSQL = '';
		Let  cSQL = 'echo "load from '||TRIM(cRuta) || TRIM(pNombreArchivo) ||
					' insert into sc_NominaArchTemp(columna); " > '||TRIM(cRuta) ||'querynom.sql';
		System cSQL;
		Let cSQL = '';
		--- Let cSQL = 'dbaccess bdicheq '||TRIM(cRuta) ||'querynom.sql';  --Se activa para desarrollo   
		Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||TRIM(cRuta) ||'querynom.sql ';  --Se activa para Produccion
		System cSQL;
		------------------------------------------------------------------------------------------
		------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
		--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
		IF EXISTS(SELECT columna FROM sc_NominaArchTemp WHERE SUBSTR(columna,1,1) NOT IN ("1","2","3")) THEN
			--Existe un tipo de registro que no es autorizado
			LET cCodret = '175';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		--- VALIDA QUE EXISTAN LOS NUEMROS DE REGISTROS CORRESPONDIENTES
		LET iNumReg = 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM  sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "1";
         
		IF iNumReg = 0 THEN
			--No Existe Encabezado en el archivo
			LET cCodret = '176';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Encabezado en el archivo
			LET cCodret = '177';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		LET iNumReg		= 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "3";
         
		IF iNumReg = 0 THEN
			--No Existe Sumario en el archivo
			LET cCodret = '178';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Sumario en el archivo
			LET cCodret = '179';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		LET iNumReg	= 0;
        
		--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
		SELECT COUNT(*)::INTEGER 
          INTO iNumReg 
          FROM sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "2";
         
		IF iNumReg = 0 THEN
			--No Existe Detalle en el archivo
			LET cCodret = '180';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'Nomi_tmp_secuencia') THEN
			DROP TABLE Nomi_tmp_secuencia;
		END IF
        
		---VALIDAR LA SECUENCIA DE LOS REGISTROS
		--- CREAR LA TABLA DE SECUENCIA
		CREATE TABLE Nomi_tmp_secuencia (secuencia CHAR(5));
				
		INSERT INTO Nomi_tmp_secuencia
		SELECT SUBSTR(columna,2,5) AS SECUENCIA 
          FROM bdicheq:sc_NominaArchTemp 
         WHERE SUBSTR(columna,1,1) = "2" ;
         
		---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
		IF EXISTS(SELECT SECUENCIA FROM Nomi_tmp_secuencia GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
			DROP TABLE Nomi_tmp_secuencia;
			--La secuencia en el detalle no es correcta
			LET cCodret = '181';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF
        
		---BORRAR LA TABLA DE SECUENCIA
		DROP TABLE Nomi_tmp_secuencia;
        
		---------Se valida la estructura del archivo---------
		FOREACH
			SELECT columna 
              INTO cRenglon 
              FROM sc_NominaArchTemp 
             ORDER BY(num_serial)
             
			--ASIGNACION DE VALORES A LAS VARIABLES
			IF SUBSTR(cRenglon,1,1) = "1" THEN --- ENCABEZADO
				LET cTipoRegistroE = SUBSTR(cRenglon,1,1);  
				LET cSecuenciaE = SUBSTR(cRenglon,2,5);      
				LET cSentidoE = SUBSTR(cRenglon,7,1);               
				LET cFechaGenE = SUBSTR(cRenglon,8,8);       
				LET cCuentaCargoE = SUBSTR(cRenglon,16,16);   
				LET cFechaAplicE = SUBSTR(cRenglon,32,8); 
                
				--Validar si son nullos
				IF TRIM(cTipoRegistroE) = '' OR (cTipoRegistroE IS null) OR TRIM(cSecuenciaE) = '' OR (cSecuenciaE IS null) OR 
				   TRIM(cSentidoE) = '' OR (cSentidoE IS null) OR TRIM(cFechaGenE) = '' OR (cFechaGenE IS null) OR
				   TRIM(cCuentaCargoE) = '' OR (cCuentaCargoE IS null) OR TRIM(cFechaAplicE) = '' OR (cFechaAplicE IS null)  THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje  || ' Error encabezado de pagina';
				END IF;
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroE) <> '1' OR bdiprog:isnumeric(cSecuenciaE) <> '1' OR  bdiprog:isnumeric(cFechaGenE) <> '1' 
					OR bdiprog:isnumeric(cCuentaCargoE) <> '1' OR bdiprog:isnumeric(cFechaAplicE) <> '1'THEN
					--Error Un valor No Es  Numerico En Encabezado
					LET cCodret = '183';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--Validar si son cadenas
				IF bdiprog:isnumeric(cSentidoE) <> '0' THEN
					--Error Un valor Es  Numerico En Encabezado
					LET cCodret = '184';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaGenE,1,2) > 0 AND  SUBSTR(cFechaGenE,1,2) < 13) AND (SUBSTR(cFechaGenE,3,2) > 0 AND SUBSTR(cFechaGenE,3,2) < 32) 
					AND (SUBSTR(cFechaGenE,5,4) > 2000 AND SUBSTR(cFechaGenE,5,4) < 3000 ) )  THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaAplicE,1,2) > 0 AND  SUBSTR(cFechaAplicE,1,2) < 13) AND (SUBSTR(cFechaAplicE,3,2) > 0 AND SUBSTR(cFechaAplicE,3,2) < 32) 
					AND (SUBSTR(cFechaAplicE,5,4) > 2000 AND SUBSTR(cFechaAplicE,5,4) < 3000)) THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				LET cBan = cBan + 1;
                
			ELIF SUBSTR(cRenglon,1,1) = "2" THEN --- DETALLE
            
				LET cTipoRegistroD = SUBSTR(cRenglon,1,1);                  
				LET cSecuenciaD = SUBSTR(cRenglon,2,5); 	          
				LET cNumeroEmpleadoD = SUBSTR(cRenglon,7,8);    
				LET cApellidoPaternoD = SUBSTR(cRenglon,15,30);      
				LET cApellidoMaternoD = SUBSTR(cRenglon,45,20);    
				LET cNombreD = SUBSTR(cRenglon,65,30);                  
				LET cCuentaAbonoD = SUBSTR(cRenglon,95,16);       
				LET cConceptoD = SUBSTR(cRenglon,111,2);              
				LET cImporteD = SUBSTR(cRenglon,113,18);  
                
				--Validar si son nullos
				IF TRIM(cTipoRegistroD) = '' OR (cTipoRegistroD IS null) OR TRIM(cSecuenciaD) = '' OR (cSecuenciaD IS null) OR 
				   TRIM(cNumeroEmpleadoD) = '' OR (cNumeroEmpleadoD IS null) OR TRIM(cApellidoPaternoD) = '' OR (cApellidoPaternoD IS null) /*OR
				   TRIM(cApellidoMaternoD) = '' OR (cApellidoMaternoD IS null)*/ OR TRIM(cNombreD) = '' OR (cNombreD IS null) OR 
				   TRIM(cCuentaAbonoD) = '' OR (cCuentaAbonoD IS null) OR TRIM(cConceptoD) = '' OR (cConceptoD IS null) OR TRIM(cImporteD) = '' 
				   OR (cImporteD IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje  || ' Error en detalle';
				END IF;	
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroD) <> '1' OR bdiprog:isnumeric(cSecuenciaD) <> '1' --OR  bdiprog:isnumeric(cNumeroEmpleadoD) <> '1' 
					OR bdiprog:isnumeric(cCuentaAbonoD) <> '1' OR bdiprog:isnumeric(cConceptoD) <> '1' OR bdiprog:isnumeric(cImporteD) <> '1' THEN
					--Error Un valor No Es  Numerico En detalle
					LET cCodret = '187';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
                
				--HAcer el inser a la temporal para una siguiente validacion
				INSERT INTO sc_nominamovimientostemp 
                (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
				VALUES 
                (pNombreArchivo, cNumeroEmpleadoD, cApellidoPaternoD, cApellidoMaternoD, cNombreD, cCuentaAbonoD, (cImporteD), cConceptoD, '0');
                
                /* #########################################################
                LET iCtas = iCtas + 1;
                
                LET iCuenta = SUBSTR(cCuentaAbonoD,3,9)::INTEGER;
                LET iSumCuentas = iSumCuentas + iCuenta;
                
                --- LET mImporte = cImporteD::INTEGER;
                LET mSumImporte = mSumImporte + (cImporteD);
                ######################################################### */
			ELIF SUBSTR(cRenglon,1,1) = "3" THEN --- SUMARIO
            
				LET cTipoRegistroS = SUBSTR(cRenglon,1,1);          
				LET cSecuenciaS = SUBSTR(cRenglon,2,5);            
				LET cTotalRegistrosS = SUBSTR(cRenglon,7,5);     
				LET cImporteTotalS = SUBSTR(cRenglon,12,18);  
                    
				--Validar si son nullos
				IF TRIM(cTipoRegistroS) = '' OR (cTipoRegistroS IS null) OR TRIM(cSecuenciaS) = '' OR (cSecuenciaS IS null) OR 
				   TRIM(cTotalRegistrosS) = '' OR (cTotalRegistrosS IS null) OR TRIM(cImporteTotalS) = '' OR (cImporteTotalS IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje || ' Error pie de pagina';
				END IF;
                
				--Validar si son numericos
				IF bdiprog:isnumeric(cTipoRegistroS) <> '1' OR bdiprog:isnumeric(cSecuenciaS) <> '1' OR  bdiprog:isnumeric(cTotalRegistrosS) <> '1' 
					OR bdiprog:isnumeric(cImporteTotalS) <> '1' THEN
					--Error Un valor No Es  Numerico En Sumario
					LET cCodret = '189';
                    
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION 
                      INTO cMensaje 
                      FROM bdinteg:si_codret 
                     WHERE sistema = '01' 
                       AND codigo_retorno = cCodret;
                       
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				LET cBan = cBan + 1;
			END IF;            
		END FOREACH;
        
        /* #######################################################################################################################################################
        INSERT INTO sc_cifr_ctl_disp
        ( nombre_archivo, fecha_aplicacion, no_cuentas, suma_cuentas, suma_importe )
        VALUES
        ( pNombreArchivo, SUBSTR(cFechaAplicE,1,2)||'/'||SUBSTR(cFechaAplicE,3,2)||'/'||SUBSTR(cFechaAplicE,5,4), iCtas, iSumCuentas, (mSumImporte / 100) );
        ####################################################################################################################################################### */
        
        IF cBan = 2 THEN--06302009   2009-06-30    empresa + fecha + folio (2)     aaaammdd   mmddaaaa
		--- LET cFechaFormateada = SUBSTR(cFecha_presentacionD,5,2) ||'/'|| SUBSTR(cFecha_presentacionD,7,2) ||'/'|| SUBSTR(cFecha_presentacionD,1,4);
			INSERT INTO sc_nominaencabezadosumariotemp 
            ( empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot, status, fecha_insert )
			VALUES 
            ( SUBSTR(pNombreArchivo,1,3), SUBSTR(cFechaGenE,1,2)||'/'||SUBSTR(cFechaGenE,3,2)||'/'||SUBSTR(cFechaGenE,5,4), SUBSTR(pNombreArchivo,12,2), pNombreArchivo, 
              cSentidoE, cCuentaCargoE, SUBSTR(cFechaAplicE,1,2)||'/'||SUBSTR(cFechaAplicE,3,2)||'/'||SUBSTR(cFechaAplicE,5,4), cTotalRegistrosS, (cImporteTotalS), '0', CURRENT );
		ELSE
			--No se Obtubo Encabezado o Suamrio
			LET cCodret = '190';
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio, cMensaje;
		END IF;
        
        -- Se manda llamar el sp sp_validadatostempnomina
		EXECUTE PROCEDURE bdicheq:sp_validadatostempnomina(SUBSTR(pNombreArchivo,1,3), SUBSTR(cFechaGenE,1,2)||'/'||SUBSTR(cFechaGenE,3,2)||'/'||SUBSTR(cFechaGenE,5,4), SUBSTR(pNombreArchivo,12,2)) 
        INTO cCodret2,cFolio;
        
		IF cCodret2 <> '000' THEN
			--Error en el sp de valida datos
			--192 - 199
			IF cCodret2 = '600' THEN
				LET cCodret = '192';
			ELIF cCodret2 = '100' THEN
				LET cCodret = '193';
			ELIF cCodret2 = '150' THEN
				LET cCodret = '194';
			ELIF cCodret2 = '200' THEN
				LET cCodret = '195';
			ELIF cCodret2 = '250' THEN
				LET cCodret = '196';
			ELIF cCodret2 = '550' THEN
				LET cCodret = '197';
			ELIF cCodret2 = '300' THEN
				LET cCodret = '198';
			ELIF cCodret2 = '350' THEN
				LET cCodret = '199';
			ELIF cCodret2 = '400' THEN
				LET cCodret = '186';
			ELIF cCodret2 = '450' THEN
				LET cCodret = '188';
			END IF;
            
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION 
              INTO cMensaje 
              FROM bdinteg:si_codret 
             WHERE sistema = '01' 
               AND codigo_retorno = cCodret;
               
			RETURN cCodret, cFolio,cMensaje;
		END IF;
		--------------------------------------------------------------
	END IF;
    
	RETURN cCodret, cFolio, cMensaje;
    
    END;
    
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de validar si existe el archivo en la ruta parametrizada, ',
'             ademas divide el archivo y valida la estrutura del archivo, junto con la integridad de ',
'             los datos, y manda llamar el procedimiento que valida el archivo',
'FECHA : Septiembre de 2009',
'BD    : BDICHEQ',
'VERSION: 20090908.0400';

CREATE PROCEDURE "informix".sp_regordenctecte( pEmpresa  CHAR(3),               --- EMPRESA
                                               pchrSucursal CHAR(4),            --- SUCURSAL
                                               pchrUsuario CHAR(8),             --- USUARIO
                                               pintBancoDest INTEGER,           --- NUMERO DEL BANCO DESTINO
                                               pmnyImporte MONEY(14,2),         --- IMPORTE TRANSACCION
                                               pchrTransuc  CHAR(4),            --- TRANSACCION
                                               pchrFolioSuc CHAR(16),           --- FOLIO
                                               pdtfechacaptura DATE,            --- FECHA CAPTURA
                                               pmnyComision MONEY(14,2),        --- COMISION
                                               pmnyIvaComis MONEY(14,2),        --- IVA DE LA COMISION 
                                               pvchrNombreOrd VARCHAR(40),      --- NOMBRE DEL ORDENANTE
                                               pintTipoCtaOrd INTEGER,          --- TIPO DE CUENTA DEL ORDENANTE
                                               pvchrCuentaOrd VARCHAR(20),      --- CUENTA DEL ORDENANTE
                                               pvchrRfcOrd VARCHAR(18),         --- RFC DEL ORDENANTE
                                               pvchrNombreBenef VARCHAR(40),    --- NOMBRE DEL BENEFICIARIO
                                               pintTipoCtaBenef INTEGER,        --- TIPO DE CUENTA DEL BEBEFICIARIO
                                               pvchrCtaBenef VARCHAR(20),       --- CUENTA DEL BENEFICIARIO
                                               pvchrRFCBenef VARCHAR(18),       --- RFC DEL BENEFICIARIO
                                               pvchrConceptoPago VARCHAR(40),   --- CONCEPTO DEL PAGO
                                               pmnyIVA MONEY(14,2),             --- IVA
                                               pdecRefNum DECIMAL(7,0),         --- REFERENCIA NUMERICA
                                               pvchrRefCobranza1 VARCHAR(40) )  --- REFERENCIA COBRANZA
RETURNING CHAR(5), char(100), CHAR(30);
    
    DEFINE cVarDataErr      CHAR(100);
    DEFINE vchrcodret 	    CHAR(5);
    DEFINE vintcodret	    INTEGER;
    DEFINE vchrCveRastreo	CHAR(30);
    DEFINE vintPermiteCta11 INTEGER;
    DEFINE vchrFuente       CHAR(7);
    DEFINE vchrTranscargo   CHAR(4);
    DEFINE vchrComis        CHAR(4);
    DEFINE vchrIvaComis     CHAR(4);
    DEFINE vchrtranret      CHAR(4);
    DEFINE dteFechacargo    DATE;
    DEFINE vmnySdoDisp      MONEY(14,2);
    DEFINE vmnyMontoRet     MONEY(14,2);
    DEFINE vchrTarjeta      CHAR(20);
    DEFINE vtransaccion     INTEGER;
    DEFINE vchrparametro    VARCHAR(255);
    DEFINE vchrFechaValor   VARCHAR(10);
    DEFINE dIva             DECIMAL(5,3);
    DEFINE vmnyMontoLibre   MONEY(14,2);
    DEFINE vdigitoverifica  SMALLINT;
    DEFINE vexiste_cta      CHAR(20);
    DEFINE vexiste_suc      CHAR(4);
	DEFINE vchrCtaOrdClabe  VARCHAR(20);
	DEFINE vchrCtaOrdtblp   VARCHAR(20);
    DEFINE vchrTelefono     CHAR(10); 
    DEFINE intpktblpago     INTEGER;
    DEFINE vchrtopologia    CHAR(1);
    DEFINE intBancoOrd      INTEGER;
    DEFINE vintCveCesif     INTEGER;
    DEFINE vsintLongCveRast SMALLINT;
    DEFINE vdecRefNum       DECIMAL(7,0);
    DEFINE vexiste_clave    CHAR(40);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vchrExisteCta    SMALLINT;
	DEFINE pvchrCuentaBenef	CHAR(20);
	DEFINE pvchrCveTransfer INTEGER;
	DEFINE vchrestatusenvio CHAR(1);
	DEFINE vfecha_hoy		DATE;
	DEFINE vcodret1         CHAR(5);
	DEFINE vfechaHabil		DATE;
    DEFINE wmedioent        CHAR(3);
    DEFINE wvchrnombreord   CHAR(40);
    DEFINE wvchrnombrebenef CHAR(40);
    DEFINE wvchrconceptopago2 CHAR(40);
    DEFINE wvchrrefcobranza CHAR(40);
    DEFINE wvchrrfcbenef 	CHAR(18);
    DEFINE wvchrrfcord 		CHAR(18);
    DEFINE wmnyImporte 		DECIMAL (14,2);
    DEFINE wmnyIVA 			DECIMAL (14,2);
	
	-- // FIRMA
	DEFINE ret						INTEGER;
	DEFINE wvchrfirma 			    CHAR(512);
	DEFINE wchrcadena_00			CHAR(3000);
	DEFINE wchrcadena_01			CHAR(200);
	DEFINE wchrcadena_02			CHAR(200);
	DEFINE wchrcadena_03			CHAR(200);
	DEFINE wchrcadena_04			CHAR(200);
	DEFINE wvchrnombre				CHAR(30);
	DEFINE vchrFechaValor2			VARCHAR(10);

    LET vtransaccion = 0;
    LET cVarDataErr = '';
    LET vdigitoverifica = 0;
    LET vexiste_cta = '';
    LET vexiste_suc = '';
    LET vchrExisteCta = 0;
	LET pvchrCuentaBenef='';
	LET pvchrCveTransfer = 90684;
	LET vchrestatusenvio = 'N';
	LET vfecha_hoy      = '';
	LET vcodret1       = "00000";
    LET wvchrnombreord = '';
    LET wvchrnombrebenef = '';
    LET wvchrconceptopago2 = '';
    LET wvchrrefcobranza = '';
    LET wvchrrfcbenef = '';
    LET wvchrrfcord = '';
	
	-- // FIRMA
	LET ret           = 0;
	LET wvchrfirma    = '';
	LET wchrcadena_00 = '';
	LET wchrcadena_01 = '';
	LET wchrcadena_02 = '';
	LET wchrcadena_03 = '';
	LET wchrcadena_04 = '';
	LET wvchrnombre   = '';
	LET vchrFechaValor2 = '';
	
	--- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenctecte.out';
    --- TRACE ON;
	
    BEGIN
    
    ON EXCEPTION SET vintcodret
		SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenctecte.err';
		TRACE ON;
        IF vintcodret <> 0 THEN
            LET vchrcodret = vintcodret;
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END EXCEPTION;

    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;

    -- // Iniciar la transaccion
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        BEGIN WORK;
    end if;
    
    -- // Inicializacion de variables
    LET vchrcodret = '000';
    LET vchrCveRastreo = '';
    LET vchrTarjeta = '';
    LET vind_dispon = '0';

    set isolation to dirty read;
    set lock mode to wait 3;
    
    LET pintTipoCtaOrd = pintTipoCtaOrd;
    LET pvchrCuentaOrd = pvchrCuentaOrd;
    
    SELECT ind_disponible, fecha_hoy, fecha_hoy
      INTO vind_dispon, vfecha_hoy, vfechaHabil
      FROM bdicheq:sc_fechas 
     WHERE empresa = pEmpresa;

    LET vchrFechaValor2 = to_char(vfechaHabil, '%Y%m%d');
     
    IF vind_dispon = '0' THEN
        LET vchrcodret = '004'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'SISTEMA DE CHEQUES NO DISPONIBLE.';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // valida canal internet
    IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
        if pchrSucursal = '5003' then
            EXECUTE PROCEDURE sp_validaspei_bpi(pvchrCuentaOrd, pvchrCtaBenef)
            INTO vchrcodret, cVarDataErr;
            
            IF trim(vchrcodret) <> '000' THEN
                RETURN vchrcodret, cVarDataErr, '';    
            end if;
        end if;
    END IF;

    -- // Obtiene el numero de tarjeta
    IF pintTipoCtaOrd = 3 THEN
        SELECT num_tarjeta
          INTO vchrTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = pEmpresa
           AND num_tarjeta = trim(pvchrCuentaOrd)
           AND status_tar = 'A';
        
        IF (vchrTarjeta is null) OR (vchrTarjeta = '') then
            LET vchrcodret = '019'; -- // Tarjeta no vigente Ã³ no asignada
            LET cVarDataErr = 'Tarjeta no vigente Ã³ no asignada';
            RETURN vchrcodret, cVarDataErr, '';
        ELSE             
            -- // Verifica si se encuentra activa la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT mae.cuenta 
                  INTO pvchrCuentaOrd 
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.empresa = pEmpresa
                   AND mae.cuenta = tar.cuenta
                   AND mae.status_cta <> "2"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            ELSE
                SELECT mae.cuenta_tf 
                  INTO pvchrCuentaOrd 
                  FROM bditransfer:tf_maecte mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.cuenta_tf = tar.cuenta
                   AND mae.status_cta = "1"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            END IF;
            
            IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN
                LET vchrcodret = '020'; -- // La cuenta Ord. no se encuentra activa
                LET cVarDataErr = 'La cuenta Ord. no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        END IF
    END IF

    -- // Valida la fecha del Movimiento
    IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then
        LET vchrcodret = '001'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'Falta parametro Fecha de Operacion';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // Obtiene el Iva General
    SELECT valor
      INTO dIva
      FROM bdinteg:si_param
     WHERE cod_param = 47
       AND empresa = pEmpresa;
     
    IF dIva IS NULL THEN
        LET vchrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;
	
    -- // Obtiene la fecha de operacion
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'FECHA_OPERACION';
     
    IF vchrparametro IS NULL THEN
        LET vchrcodret = '011';
        LET cVarDataErr = 'Parametro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    -- // Formatea la fecha a mm/dd/aaaa
    LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) || '/' || SUBSTR(TRIM(vchrparametro),0,2) || '/' || SUBSTR(TRIM(vchrparametro),7,4);
	LET vchrFechaValor2 = SUBSTR(TRIM(vchrparametro),7,4) || SUBSTR(TRIM(vchrparametro),4,2) || SUBSTR(TRIM(vchrparametro),1,2);

       -- // Verifica  la cuenta del ordenante a 18 digitos
    IF pintTipoCtaOrd = 40 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            SELECT cuenta_clabe
              INTO vchrCtaOrdClabe
              FROM bdicheq:sc_maechq
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            SELECT cta_clabe
              INTO vchrCtaOrdClabe
              FROM bditransfer:tf_maecte
             WHERE cuenta_tf = pvchrCuentaOrd;
        END IF;
        
        IF vchrCtaOrdClabe IS NULL THEN
            LET vchrCtaOrdClabe = '021'; -- // No se tiene cuenta clabe.
            LET cVarDataErr = 'Cuenta No valida. ';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        IF vchrCtaOrdClabe IS NOT NULL THEN
			IF LENGTH(vchrCtaOrdClabe) >= 16 AND LENGTH(vchrCtaOrdClabe) < 18 THEN
				LET vchrCtaOrdClabe = LPAD(vchrCtaOrdClabe,18,'0');
            ELIF LENGTH(vchrCtaOrdClabe) > 18 THEN
                LET vchrcodret = '020'; -- // La cuenta debe ser de 18 digitos.
                LET cVarDataErr = 'La cuenta Clave del Ord. debe ser de 18 digitos';
                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Verifica si existe la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bdicheq:sc_maechq 
                 WHERE empresa = pEmpresa
                   AND cuenta = pvchrCuentaOrd 
                   AND status_cta <> "2";
            ELSE
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bditransfer:tf_maecte 
                 WHERE cuenta_tf = pvchrCuentaOrd 
                   AND status_cta = "1";
            END IF;
               
            IF vexiste_cta is null OR vexiste_cta = '' THEN
                LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
                LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no permite 11 digitos.
            LET cVarDataErr = 'La cuenta Ord. no permite solo 11 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;
    
    IF pintTipoCtaOrd = 10 THEN
        IF LENGTH(pvchrCuentaOrd) = 10 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = pvchrCuentaOrd;
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta ordenante no existe';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
        
        IF vexiste_cta is null OR vexiste_cta = '' THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
        
        SELECT cuenta
          INTO pvchrCuentaOrd
          FROM bdicheq:sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = vexiste_cta 
           AND status_cta <> "2";
            
        IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN
            LET vchrcodret = '020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;

    -- // Verifica la longitud de la cta benef
    IF pintTipoCtaBenef = 40 THEN
        IF LENGTH(pvchrCtaBenef) >= 16 AND LENGTH(pvchrCtaBenef) < 18 THEN
            LET pvchrCtaBenef = LPAD(pvchrCtaBenef,18,'0');
            
            EXECUTE PROCEDURE sp_validadv(pvchrCtaBenef)
            INTO vchrcodret, vdigitoverifica;
            
            IF vdigitoverifica = 0 THEN
                LET vchrcodret = '020'; -- // La Cuenta Clabe del Benefciario es Invalida
                LET cVarDataErr = 'La Cuenta Clabe del Benefciario es Invalida ';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCtaBenef) <> 18 THEN
            LET vchrcodret = '020'; -- // La cuenta Benef debe ser de 18 digitos.
            LET cVarDataErr = 'La cuenta Benef debe ser de 18 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
	ELIF pintTipoCtaBenef = 10 AND pintBancoDest = pvchrCveTransfer  THEN
		SELECT cuenta_tf
			INTO pvchrCuentaBenef
			FROM bditransfer:tf_maecte
		WHERE telefono = pvchrCtaBenef
			AND status_cta = "1";
			IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN
				SELECT cuenta
					INTO pvchrCuentaBenef
					FROM bdicheq:sc_cuenta_telefono
				WHERE telefono =pvchrCtaBenef;
			END IF;
			IF LENGTH(pvchrCuentaBenef) > 0 THEN
				LET vchrcodret = '1168';
				LET cVarDataErr = 'Cuenta destino Transfer, ingresa al menÃº: Transfer/Traspaso a cuenta Transfer';
                 RETURN vchrcodret, cVarDataErr, '';
			END IF;
    END IF;

    -- // Trae la transaccion de Cargo.
    SELECT vchrValor
      INTO vchrTranscargo
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_CARGO';

    IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN
        LET vchrcodret = '022'; -- // Falta parametro de transaccion comision.
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    FOREACH WITH HOLD
        -- // Trae la transaccion de la Comision
        SELECT vchrValor
          INTO vchrComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_COMISION'

        IF vchrComis IS NULL OR vchrCOmis = '' THEN
            LET vchrcodret = '023'; -- // Falta parametro de transaccion comision.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Trae la transaccion del IVA de la Comision
        SELECT vchrValor
          INTO vchrIvaComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_IVACOM';

        IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN
            LET vchrcodret = '023'; -- // Falta parametro de transaccion iva.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Valida si existe la transaccion de la sucursal
        IF TRIM(pchrTransuc) = '' THEN
            --- LET pchrTransuc = LPAD(TRIM(vchrTranscargo), 4, '0');
            LET pchrTransuc = '0000';
        END IF;
		
		-- // GUARDA REGISTRO EN BDISPEI:TBLPAGO 
		IF pintTipoCtaOrd = '40' THEN
			LET vchrCtaOrdtblp = vchrCtaOrdClabe;
        ELIF pintTipoCtaOrd = '10' THEN
			LET vchrCtaOrdtblp = vchrTelefono;
		ELSE
			LET vchrCtaOrdtblp = vchrTarjeta;
		END IF;

        EXECUTE PROCEDURE sp_regordenpagospei(pEmpresa,         --- Empresa.
                                              pchrUsuario,      --- Usuario.
                                              pchrSucursal,     --- Sucursal.
                                              pchrFolioSuc,     --- Folio Sucursal.
                                              pintBancoDest,    --- Clave Banco Beneficiario.
                                              pdtfechacaptura,  --- Fecha Valor.
                                              1,                --- Tipo de pago CLIENTE-CLIENTE.
                                              NULL,             --- Clave de tipo de operacion.
                                              pmnyImporte,      --- Importe de la operacion.
                                              pvchrNombreOrd,   --- Nombre del Ordenante.
                                              vchrCtaOrdtblp,   --- Cuenta del ordenante.
                                              pvchrRfcOrd,      --- Rfc del Ordenante
                                              pvchrNombreBenef, --- Nombre del Beneficiario.
                                              pvchrCtaBenef,    --- Cuenta del Beneficiario.
                                              pvchrRFCBenef,    --- Rfc del Beneficiario.
                                              pmnyIVA,          --- Importe del Iva.
                                              pdecRefNum,       --- Referencia Numerica.
                                              pvchrRefCobranza1,--- Referencia de cobranza.
                                              NULL,             --- Concepto de pago con longitud de 210 pos.
                                              NULL,             --- Clave para el pago.
                                              NULL,             --- Nombre del beneficiario2.
                                              NULL,             --- Rfc Beneficiario2.
                                              NULL,             --- Concepto de pago2 a 40 pos.
                                              pvchrConceptoPago,--- Concepto de pago con longitud de 40 pos.
                                              vchrTranscargo,   --- chrtxop.
                                              pintTipoCtaOrd,   --- Tipo cuenta Ordenante.
                                              pintTipoCtaBenef) --- Tipo cuenta Beneficiario.
        INTO vchrcodret, cVarDataErr, vchrCveRastreo, intpktblpago, vchrFechaValor, vchrtopologia, intBancoOrd, vintCveCesif, vsintLongCveRast, vdecRefNum;

        IF trim(vchrcodret) <> '000' THEN
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Busca si aplica comision e iva especial
        SELECT suc.sucursal
          INTO vexiste_suc
          FROM bdinteg:si_sucursales suc, 
               bdinteg:si_param par 
         WHERE par.cod_param = 47
           AND suc.sucursal = pchrSucursal
           AND par.valor = suc.iva
           AND par.empresa = suc.empresa
           AND par.empresa = pEmpresa;
           
        IF vexiste_suc is null OR vexiste_suc = '' THEN
            -- // Trae la transaccion de la Comision especial
            SELECT trancivaesp
              INTO vchrtranret
              FROM bdinteg:si_transacc
             WHERE numero = vchrComis
               AND empresa = pEmpresa
               AND sistema = '01';
               
            LET vchrComis = trim(vchrtranret);

            -- // Trae la transaccion del IVA especial
            SELECT trancivaesp
              INTO vchrtranret
              FROM bdinteg:si_transacc
             WHERE numero = vchrIvaComis
               AND empresa = pEmpresa
               AND sistema = '01';
            
            LET vchrIvaComis = trim(vchrtranret);
        END IF

        -- // Aplicar el Cargo de la operacion SPEI - Ejecutar cargo a cheques
        EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                             pchrSucursal,   --- sucursal
                                             pchrUsuario,    --- usuario
                                             vchrTranscargo, --- transaccion
                                             pchrTransuc,    --- transaccion suc
                                             pchrFolioSuc,   --- folio suc
                                             pvchrCuentaOrd, --- cuenta
                                             0,              --- no. cheque
                                             pmnyImporte,    --- monto
                                             "01",           --- divisa
                                             vchrCveRastreo, --- referencia
                                             vchrTarjeta,    --- no. tarjeta
                                             pchrUsuario)    --- usuario autoriza
        INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
        
        -- // Valida si se pudo realizar el cargo
        IF trim(vchrcodret) <> '000' THEN
            LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
            
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Registra el detalle de la transaccion del pago
        INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
        VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrTranscargo, pEmpresa, pvchrCuentaOrd, pmnyImporte, vchrCveRastreo);
        
        -- // Aplicar la Comision de la operacion
        IF pmnyComision > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrComis,      --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyComision,   --- monto
                                                 "01",           --- divisa
                                                 vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                
                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrComis, pEmpresa, pvchrCuentaOrd, pmnyComision, vchrCveRastreo);
        END IF;

        -- // Aplicar el IVA de la Comision
        IF pmnyIvaComis > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrIvaComis,   --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyIvaComis,   --- monto
                                                 "01",           --- divisa
                                                 vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                    
                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion del iva de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrIvaComis, pEmpresa, pvchrCuentaOrd, pmnyIvaComis, vchrCveRastreo);
        END IF;
        
        SELECT referencia
          INTO vexiste_clave
          FROM bdicheq:sc_movdia
         WHERE empresa = pEmpresa
           AND cuenta = pvchrCuentaOrd
           AND transacc = vchrTranscargo
           AND cancelad <> 'S'
           AND referencia = vchrCveRastreo;
           
        IF vexiste_clave = vchrCveRastreo THEN
            -- CONTROL DE ESTATUS DE ENVIO EN HORARIO DE LIQUIDACION FINAL
            IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '19:00:00' THEN
				SELECT vchrvalor
				  INTO vchrparametro
				  FROM tblparametros
				  WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';
				  
					IF vchrparametro IS NOT NULL THEN
						IF (vchrparametro * 1) = 1 THEN
							LET vchrestatusenvio='E';
                
							CALL "informix".sp_validafecha(pEmpresa, vfecha_hoy)
								RETURNING vcodret1, vfechaHabil;
                
							LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
							LET vchrFechaValor2 = to_char(vfechaHabil, '%Y%m%d');
						END IF;
					END IF;
            END IF;
            
			-- // NUEVOS CAMBIOS PARA GENERAR EL CIFRADO
            IF pmnyImporte > 100000.00 THEN
                LET wmedioent = 'h2h';
            ELSE
                LET wmedioent = '';
            END IF;
            
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ñ', 'N');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Á', 'A');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'É', 'E');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Í', 'I');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ó', 'O');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ú', 'U');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ü', 'U');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'ý', 'X');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ý', 'X');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ã', 'A');
            
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ñ', 'N');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Á', 'A');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'É', 'E');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Í', 'I');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ó', 'O');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ú', 'U');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ü', 'U');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ý', 'X');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ý', 'X');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ã', 'A');
   
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ñ', 'N');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ñ', 'n');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'á', 'a');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'é', 'e');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'í', 'i');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ó', 'o');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ú', 'u');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Á', 'A');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'É', 'E');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Í', 'I');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ó', 'O');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ú', 'U');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ü', 'U');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ý', 'X');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ý', 'X');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ã', 'A');
            
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ñ', 'N');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ñ', 'n');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'á', 'a');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'é', 'e');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'í', 'i');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ó', 'o');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ú', 'u');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Á', 'A');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'É', 'E');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Í', 'I');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ó', 'O');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ú', 'U');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ü', 'U');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ý', 'X');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ý', 'X');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ã', 'A');
                    
            LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ñ', 'N');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'ý', 'X');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ý', 'X');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ã', 'A');
			
            LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ñ', 'N');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'ý', 'X');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ý', 'X');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ã', 'A');
			
            LET wmnyImporte = pmnyImporte;
            LET wmnyIVA = pmnyIVA;

            LET wchrcadena_01 = '||'||vintCveCesif||'|'||'Bancoppel'||'|'||vchrFechaValor2||'|'||'|'||TRIM(vchrCveRastreo)||'|'||intBancoOrd||'|';
            LET wchrcadena_02 = wmnyImporte||'|'||'1'::integer||'|'||pintTipoCtaOrd||'|'||TRIM(pvchrNombreOrd)||'|'||TRIM(vchrCtaOrdtblp)||'|'||TRIM(pvchrRFCOrd)||'|';
            LET wchrcadena_03 = pintTipoCtaBenef||'|'||TRIM(pvchrNombreBenef)||'|'||TRIM(pvchrCtaBenef)||'|'||TRIM(pvchrRFCBenef)||'||||||'||TRIM(pvchrConceptoPago)||'|||||'||TRIM(pvchrRefCobranza1)||'|';
            LET wchrcadena_04 = vdecRefNum||'||'||TRIM(vchrtopologia)||'|'||''||TRIM(wmedioent)||'|'||'|'||'0'||'|'||wmnyIVA||'||';
            LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03)||TRIM(wchrcadena_04);
            
            LET wvchrfirma = space(512);
            
            EXECUTE function bdispei:syn_sign(TRIM(wchrcadena_00), wvchrfirma, 21) 
            INTO ret;
            
            IF ret = 0 THEN 
                -- // INSERTA REGISTRO DE LA OPERACION EN LA TBLPAGO
				INSERT INTO tblpago
				( intpkpago, mnyimporte, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef,
				  intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, mnyiva, intrefnumerica, vchrconceptopago2, vchrrefcobranza,
				  chrusuarioprom, intcvetipopago, chrsentidopago, dtfechavalor, vchrclaverastreo, chrfolioprom, dtfechacaptura,
				  chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, cvecesifbcoord, cvecesifbcodest, chrtxop, sintlongcverastreo, vchrfirma )
				VALUES
				( intpktblpago, pmnyImporte, vchrestatusenvio, pvchrNombreOrd, vchrCtaOrdtblp, pvchrRFCOrd, pintTipoCtaOrd, pvchrNombreBenef,
				  pintTipoCtaBenef, pvchrCtaBenef, pvchrRFCBenef, pmnyIVA, vdecRefNum, pvchrConceptoPago, pvchrRefCobranza1,
				  pchrUsuario, 1, 'E', vchrFechaValor, vchrCveRastreo, pchrFolioSuc, pdtfechacaptura,
				  '', '', vchrtopologia, '0', intBancoOrd, vintCveCesif, vchrTranscargo, vsintLongCveRast, wvchrfirma );
            ELSE
				CONTINUE FOREACH;
            END IF;
        END IF;
    END FOREACH;

    -- // Aplica la transaccion 
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        COMMIT WORK;
    end if;

    -- // Regresa el codigo de retorno y clave de rastreo.
    RETURN vchrcodret, cVarDataErr, vchrCveRastreo;

    END;
    
END PROCEDURE;