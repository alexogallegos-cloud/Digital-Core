CREATE PROCEDURE "informix".sp_cargaarchivos_dep_atm ( 
    psRuta_Repositorio 	VARCHAR (90), 
    psNomArchivo 		VARCHAR (30), 
    psArchivoOrigen 	VARCHAR (3), 
    piTipoLayOut 		INTEGER, 
    psSistema 			VARCHAR (1),
    psRuta_Procesos 	VARCHAR (90) 
)
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

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
	
	-- SET DEBUG FILE TO "/RESPALDOSNEW/__argoz/cnc/debug/sp_cargaarchivos_dep_atm.out";
	-- TRACE ON;
    
	BEGIN
	
		ON EXCEPTION SET viSQLerr

            SET DEBUG FILE TO "/RESPALDOSNEW/excep_sp_cargaarchivos_dep_atm.out" WITH APPEND;
            TRACE ON;
    
			TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_dep_atm DROP STORAGE;
            
			LET vsCodRet = '00107';
			
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos(psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut ,  psSistema)
        INTO vsCodRet, vsMensaje_Respuesta;
            
        IF ( vsCodRet  <> '00000' ) THEN
		
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
            RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' Código Bitacora Final: ' || vCodRetAux), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;          
			
        END IF

		IF ( NOT EXISTS 
			(
				SELECT Registro 
				FROM bditarjeta:"informix".td_carga_archivo_dep_atm  
                WHERE Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR*'
			)) THEN -- IF (1)
            
            LET vsTipoSumario 			= 'ERROR HEADER';
            LET viInicioCadena_Reg 		= -1;
            LET viInicioCadena_Monto 	= -1;
            LET viPosMontoReg_Ini 		= -1;
            LET viPosMontoReg_Fin 		= -1;
			
			LET vsCodRet = '00101';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE PROCESO EL ARCHIVO ESPERADO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF ( NOT EXISTS 
			(
				SELECT TRIM(Registro) 
				FROM bditarjeta:"informix".td_carga_archivo_dep_atm 
				WHERE Registro MATCHES vsTipoSumario 
			)) THEN --NO CONTIENE REGISTRO DE SUMARIO

            LET vsCodRet = '00102';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF ( piTipoLayOut = 8 ) THEN --ELIF (1.1)

			SELECT FIRST 1 
				( SUBSTR(Registro, vsposicion_Regtxn, 12) ) AS Registros_txn,  --TOTAL REGISTROS 
				( SUBSTR(Registro, vsposicion_Montotxn, 12) ) AS Monto_txn	--MONTO TOTAL
			INTO vsRegistros_txn, vsMonto_txn
			FROM bditarjeta:"informix".td_carga_archivo_dep_atm 
			WHERE Registro MATCHES '*Total de Tx:*';

			-- BORRA LOS REGISTROS DE ENCABEZADO
			DELETE FROM bditarjeta:"informix".td_carga_archivo_dep_atm 
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
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		END IF; -- IF (1)
		
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN --ERROR. NO CONTIENE EL ENCABEZADO CORRESPONDIENTE IF (2)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN --ERROR. NO CORRESPONDE A NINGUN LAYOUT
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELSE
		
            LET vsMensaje_Respuesta = 'VALIDANDO REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn ) INTO vdMonto_txn;
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		END IF; -- IF (2)	

		IF ( vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00106';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTROS NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF ( vdMonto_txn = 'F' ) THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00107';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELIF ( vdRegistros_txn = 'V'  AND vdMonto_txn = 'V' ) THEN -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
		
			LET vsMensaje_Respuesta = 'SE VÁLIDO QUE SE TIENEN NÚMEROS EN LAS TXN DE REGISTROS Y MONTO';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELSE 
	
			LET vsCodRet = '00108';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE INFORMACIÓN O PRESENTA ALGUNA INCONSISTENCIA.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_guardabitacora_dep_atm( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
	
		END IF; -- IF (2.3)
			
	    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' Código Bitacora Final: ' || vCodRetAux), NVL(vsRegistros_txn, 0), NVL((vsMonto_txn), 0.0), 1;
	END
END PROCEDURE
DOCUMENT

'MODIFICO: #1 Victoria Quiñones',
'Proyecto: ',
'Solicito: Jose Luis Puebla',
'Conciliación de Depositadores ATM ',
'Fecha: 2019/03/28',
'Version: 20190328.0000',
'BD: BdiTarjeta',
'MODOFICO: #2 Armando Garcia ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Es incluido el nuevo sp para cargar y registrar la informacion del archivo de Conciliación Depositadores ATM',
'Fecha de modificación: 17 de agosto del 2021',
'BD: BdiTarjeta',
'MODIFICO: #3 Maria Fernanda Ortiz Figueroa',
'Fecha: 23 de febrero de 2023',
'Sistema: Conciliación STAT06 Depositadores ATM',
'BD: bditarjeta',
'Solicito: Productos Error JOB 734 y OSI por revisión de procesos',
'Descripción: Se ajustaron los valores de retorno, ya que el proceso de esta conciliación solo realizará la carga de la información más no la conciliación',
'ya que se determino que la información generada y reportada en un archivo por OSI ya no era de utilidad, y por ende no es necesario realizar dicho proceso',
'MODIFICO: #4 Maria Fernanda Ortiz Figueroa',
'Fecha: 18 de abril de 2023',
'Sistema: Conciliación STAT06 Depositadores ATM',
'BD: bditarjeta',
'Solicito: Alertamiento JOB 734 Gerencia Produccion',
'Descripción: Se mejoraron las validaciones y mensajes en la bitacora para tener un mejor control del proceso'
;

CREATE PROCEDURE "informix".sp_tras_bitacorahis_con_pba(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
	--SET DEBUG FILE TO "/tmp/manuel/tras.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Error en sp_tras_bitacorahis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Informacion de bitacora a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRASNFERENCIA DE BITACORA A HISTORICOS';
   LET iValor = 0;
   LET iNumReg = 0;
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '402';
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin   FROM bdinteg:"informix".si_fechas;				
		
		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_his(consecutivo,elemento,fecha_hora,actividad,cve_usuario)
		SELECT consecutivo,elemento,fecha_hora,actividad,cve_usuario
		FROM bditarjeta:"informix".td_bitacora_conciliacion
		WHERE date(fecha_hora) <= dFechaFin;
						
		LET iNumReg =dbinfo("sqlca.sqlerrd2");
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Exito en Traspaso de  Bitacora a Historico (sp_tras_bitacorahis_con) ' || iNumReg  || ' ' || 'Registros Transferidos',cNumEmpl) INTO P_COD_RET;
				
		DELETE FROM bditarjeta:"informix".td_bitacora_conciliacion	WHERE date(fecha_hora) <= dFechaFin;	   

	
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE;