CREATE PROCEDURE "informix".sp_cargaarchivos_atm_stat06_pagos ( 
    psRuta_Repositorio 	VARCHAR (90), 
    psNomArchivo 		VARCHAR (30), 
    psArchivoOrigen 	VARCHAR (3), 
    piTipoLayOut 		INTEGER, 
    psSistema 			VARCHAR (1),
    psRuta_Procesos 	VARCHAR (90) 
)
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

    DEFINE vsCadena             CHAR(50);
    DEFINE vsNombreTablaCarga   CHAR(50);
    DEFINE vsSQL 				VARCHAR (200) ;
    DEFINE viSQLerr 			INTEGER ;
    DEFINE vsCodRet 			VARCHAR(5);
	DEFINE vCodRetAux 			VARCHAR(5);
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
    DEFINE vsMonto_txn			VARCHAR(12);
    DEFINE vdRegistros_txn		VARCHAR(01);
    DEFINE vdMonto_txn			VARCHAR(01);

    LET vsCadena                = TRIM(psNomArchivo);
    LET vsNombreTablaCarga      = '';
    LET vsSQL 					= '' ;
    LET viSQLerr 				= 0;
    LET vsCodRet 				= '00000';
	LET vCodRetAux 				= '00000';
    LET vsMensaje_Respuesta	 	= 'PROCESO EXITOSO';
    LET viTotalRegistros 		= 0;
    LET vmTotalMonto 			= 0.0;
    LET viPosMontoReg_Ini 		= 0;
    LET viPosMontoReg_Fin 		= 0;
    LET viInicioCadena_Monto	= 0;
    LET vsTipoSumario 			= '*Total de Tx:*';
    LET vsposicion_Regtxn		= 25;
    LET vsposicion_Montotxn		= 57;
    LET vsRegistros_txn	 		= ''; 
    LET vsMonto_txn				= ''; 
    LET vdRegistros_txn			= '';
    LET vdMonto_txn			= '';
	

	--SET DEBUG FILE TO "/RESPALDOSNEW/e10000656/sp_cargaarchivos_dep_atm204.out";
	--TRACE ON;    

	BEGIN

		ON EXCEPTION SET viSQLerr

			--SET DEBUG FILE TO "/RESPALDOSNEW/e10000656/excep_sp_cargaarchivos_cob_atm204.out" WITH APPEND;
            --TRACE ON;
    
			TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos DROP STORAGE;
            
			LET vsCodRet = '00107';
			
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos(psRuta_Repositorio, psNomArchivo, psArchivoOrigen,piTipoLayOut,psSistema)
        INTO vsCodRet, vsMensaje_Respuesta;
            
        IF ( vsCodRet  <> '00000' ) THEN
		
			EXECUTE PROCEDURE intercard:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
            RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' Codigo Bitacora Final: ' || vCodRetAux), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;          
			
        END IF
----
		IF ( NOT EXISTS 
			(
				SELECT Registro 
				FROM bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos  
                WHERE Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR*'
			)) THEN -- IF (1)
            
            LET vsTipoSumario 			= 'ERROR HEADER';
            LET viInicioCadena_Reg 		= -1;
            LET viInicioCadena_Monto 	= -1;
            LET viPosMontoReg_Ini 		= -1;
            LET viPosMontoReg_Fin 		= -1;
			
			LET vsCodRet = '00101';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE PROCESO EL ARCHIVO ESPERADO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF ( NOT EXISTS 
			(
				SELECT TRIM(Registro) 
				FROM intercard:"informix".td_carga_archivo_atm_stat06_pagos 
				WHERE Registro MATCHES vsTipoSumario 
			)) THEN --NO CONTIENE REGISTRO DE SUMARIO

            LET vsCodRet = '00102';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF ( piTipoLayOut = 8 ) THEN --ELIF (1.1)

			SELECT FIRST 1 
				( SUBSTR(Registro, vsposicion_Regtxn, 12) ) AS Registros_txn,  --TOTAL REGISTROS 
				( SUBSTR(Registro, vsposicion_Montotxn, 12) ) AS Monto_txn	--MONTO TOTAL
			INTO vsRegistros_txn, vsMonto_txn
			FROM bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos 
			WHERE Registro MATCHES '*Total de Tx:*';

			-- BORRA LOS REGISTROS DE ENCABEZADO
			DELETE FROM bditarjeta:"informix".td_carga_archivo_atm_stat06_pagos 
			WHERE 
			(
				   (Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR*') 
				OR (Registro MATCHES '===============*') 
				OR (Registro MATCHES '*Institucion            Clave:*') 
				OR (Registro MATCHES '*Codigo: Transaccional*') 
				OR (Registro MATCHES '    *' ) 
				OR (Registro MATCHES '   ' ) 
				OR (Registro MATCHES '  Emisor*' ) 
				OR (Registro = '' ) 
			) 
			AND NOT (Registro MATCHES '        Total de Tx: *' );

		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT

            LET vsTipoSumario 			= 'ERROR LAYOUT';
            LET viInicioCadena_Reg 		= 0;
            LET viInicioCadena_Monto 	= 0;
            LET viPosMontoReg_Ini 		= 0;
            LET viPosMontoReg_Fin 		= 0;
			
			LET vsCodRet = '00103';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE ESPECIFICO EL TIPO DE LAYOUT DEL ARCHIVO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		END IF; -- IF (1)
		
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN --ERROR. NO CONTIENE EL ENCABEZADO CORRESPONDIENTE IF (2)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN --ERROR. NO CORRESPONDE A NINGUN LAYOUT
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELSE
		
            LET vsMensaje_Respuesta = 'VALIDANDO REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';

			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn ) INTO vdMonto_txn;
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		END IF; -- IF (2)	

		IF ( vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00106';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTROS NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF ( vdMonto_txn = 'F' ) THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00107';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELIF ( vdRegistros_txn = 'V'  AND vdMonto_txn = 'V' ) THEN -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
		
			LET vsMensaje_Respuesta = 'SE VALIDO QUE SE TIENEN NUMEROS EN LAS TXN DE REGISTROS Y MONTO';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELSE 
	
			LET vsCodRet = '00108';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE INFORMACION O PRESENTA ALGUNA INCONSISTENCIA.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_atm_stat06_pagos( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
	
		END IF; -- IF (2.3)
		
	    RETURN vsCodRet, DECODE (vsCodRet, '00000',  vsMensaje_Respuesta || ' Codigo Bitacora Final: ' || vCodRetAux), NVL(vsRegistros_txn, 0), NVL((vsMonto_txn), 0.0), 1;
	
	END

END PROCEDURE;