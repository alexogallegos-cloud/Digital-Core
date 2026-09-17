CREATE PROCEDURE "informix".sp_concreing_consultamovpendientes2 (psCve_usuario CHAR(10), psFecha DATE, psRecuperacion INTEGER, psRegistros INTEGER)
	RETURNING CHAR (5) AS Retorno, 
	INTEGER AS Consecutivo,
	CHAR(23) AS NombreArchivo,
	CHAR(3) AS ArchivoOrigen,
	CHAR(1) AS Integridad,
	CHAR(20) AS IntegridadError,
	CHAR(16) AS NumTarjeta,
	CHAR(6) AS Secuencia,
	CHAR(9) AS IdComercio325,
	CHAR(30) AS NomComercio325,
	CHAR(23) AS Referencia23_325,
	CHAR(13) AS Monto ,
	CHAR(15) as Rfc325,
	CHAR(3) AS Divisa325,
	CHAR(13) AS MontoCashBack ,
	CHAR(1) AS Conciliacion ,
	INTEGER AS TipoConciliacion,
	CHAR(15) AS SecuenciaExtendida,
	MONEY(16,2) AS MontoIntercard,
	CHAR(1) AS MovConciliado ,
	CHAR(1) AS MovReversado ,
	CHAR(1) AS Aplicacion ,
	CHAR(16) AS FolioAplica ,
	CHAR(5) AS CodigoRetorno,
	CHAR(15) AS TipoTransaccion325,
	CHAR(13) AS Monto325,
	CHAR(1) AS BanderaProceso;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE MOVIMIENTOS PENDIENTES  ------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	*****************************************************************************************************
	-- Modificado: Juan Fco. Ponce Damian 
	-- fecha : 06/09/2013
	-- DescripciÃ³n: Se modificaron todos las consultas para retornar el Monto de Cash Back.
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE viConsecutivo INTEGER;
	DEFINE vsNombreArchivo CHAR(23);
	DEFINE vsArchivoOrigen CHAR(3);
	DEFINE vsIntegridad CHAR(1);
	DEFINE vsIntegridadError CHAR(20);
	DEFINE vsNumTarjeta CHAR(16);
	DEFINE vsSecuencia CHAR(6);
	DEFINE vsIdComercio325 CHAR(9);
	DEFINE vsNomComercio325 CHAR(30);
	DEFINE vsReferencia23_325 CHAR(23);
	DEFINE vsMonto CHAR(13);
	DEFINE vsRfc325 CHAR(15);
	DEFINE vsDivisa325 CHAR(3);
	DEFINE vmMontoCashBack CHAR(13);
	DEFINE vsConciliacion CHAR(1);
	DEFINE viTipoConciliacion INTEGER;
	DEFINE vsSecuenciaExtendida CHAR(15);
	DEFINE vmMontoIntercard MONEY(16,2);
	DEFINE vsMovConciliado CHAR(1);
	DEFINE vsMovReversado CHAR(1);
	DEFINE vsAplicacion CHAR(1);
	DEFINE vsFolioAplica CHAR(16);
	DEFINE vsCodigoRetorno CHAR(5);
	
	DEFINE vsTipotransaccion325 CHAR(15);
	DEFINE vsMonto325 CHAR(13);
	DEFINE vsBanderaProceso CHAR(1);
	/* INICIALIZACION DE VARIABLES */

	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';
	
	LET  vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 40;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET viConsecutivo = 0;
	LET vsNombreArchivo ='';
	LET vsArchivoOrigen ='';
	LET vsIntegridad ='';
	LET vsIntegridadError ='';
	LET vsNumTarjeta ='';
	LET vsSecuencia ='';
	LET vsIdComercio325 = "";
	LET vsNomComercio325 = "";
	LET vsReferencia23_325 = "";
	LET vsMonto ='';
	LET vsRfc325 ='';
	LET vsDivisa325 ='';
	LET vmMontoCashBack ='';
	LET vsConciliacion ='';
	LET viTipoConciliacion =0;
	LET vsSecuenciaExtendida ='';
	LET vmMontoIntercard =0.0;
	LET vsMovConciliado ='';
	LET vsMovReversado ='';
	LET vsAplicacion ='';
	LET vsFolioAplica ='';
	LET vsCodigoRetorno = '';
	LET vsBanderaProceso = '';
	
	LET vsTipotransaccion325 = '';
	LET vsMonto325 = '';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || NVL(vssqlerr,'') ||' ISAM '|| NVL(isam_err,0) ||' INFORMIX '||TRIM(NVL(error_info,'')) || ' EN sp_concreing_consultamovpendientes';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
			

		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'');

	END EXCEPTION;

--	SET DEBUG FILE TO '/RESPALDOSNEW/movspen.txt';
--	TRACE ON;

	--REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--2011/10/24-ING-ALFONSO-CRUZ------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
		
	IF psCve_usuario NOT IN (SELECT cve_usuario 
	                         FROM   bditarjeta:"informix".td_usuarios_conciliacion
                             WHERE  activo = 'V' AND operacion = 'V' AND monitoreo = 'V' )  THEN -- Usuarios con capacidad de modificar registros a su criterio
	
		-- Se mantienen registros de todos los archivos 
		FOREACH 
		     SELECT SKIP psRecuperacion FIRST psRegistros a.consecutivo,  -- Sftk 0423
       				a.nombrearchivo, 
       				a.archivo_origen, 
       				a.integridad, 
	   				a.integridad_error, 
	   				a.numtarjeta, 
	   				a.secuencia325, 
	   				a.idcomercio325, 
	   		        REPLACE (REPLACE (a.nomcomercio325,"'", " "),'"' , ' '), 
	   				a.referencia23_325,
	   				a.monto325, 
	   				a.rfc325, 
	   				a.divisa325, 
	   				a.montocashback325, 
	   				a.conciliacion, 
	   				a.tipo_conciliacion,
	   				a.secuencia_extendida, 
	   				a.montointercard, 
	   				a.movconciliado, 
	   				a.movreversado, 
	   				a.aplicacion, 
	   				a.folio_mov,
	   				a.cod_retorno, 
	   				a.tipotransaccion325, 
	   				a.monto325, 
	   				a.bandera_proceso 
			INTO    viConsecutivo, 
				    vsNombreArchivo, 
					vsArchivoOrigen, 
					vsIntegridad, 
					vsIntegridadError, 
					vsNumTarjeta, 
					vsSecuencia,
				    vsIdComercio325, 
					vsNomComercio325, 
				    vsReferencia23_325, 
					vsMonto, 
					vsRfc325, 
					vsDivisa325, 
					vmMontoCashBack,
				    vsConciliacion, 
					viTipoConciliacion, 
					vsSecuenciaExtendida, 
					vmMontoIntercard, 
					vsMovConciliado, 
					vsMovReversado,
				    vsAplicacion, 
					vsFolioAplica, 
					vsCodigoRetorno, 
					vsTipotransaccion325, 
					vsMonto325, 
					vsBanderaProceso
			FROM bditarjeta:td_movimientos_conciliacion	a, bditarjeta:td_archivos_conciliacion b 
			where (a.integridad='F' OR a.conciliacion = 'F'	OR a.aplicacion =  'F') 
			and a.nombrearchivo = b.nombrearchivo
			and a.archivo_origen = b.archivo_origen
			and b.fecha_archivo =  psFecha
			
			/*SELECT SKIP psRecuperacion FIRST psRegistros consecutivo, nombrearchivo, archivo_origen, 
				integridad, 
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montocashback325, 
				conciliacion, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion =  'F') 
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)*/
			
			
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	ELSE
		FOREACH 
		    SELECT SKIP psRecuperacion FIRST psRegistros a.consecutivo,  -- Sftk 0423
       				a.nombrearchivo, 
       				a.archivo_origen, 
	   				a.integridad, 
	   				a.integridad_error, 
	   				a.numtarjeta, 
	   				a.secuencia325, 
	   				a.idcomercio325, 
	   				REPLACE (REPLACE (a.nomcomercio325,"'", " "),'"' , ' '), 
	   				a.referencia23_325,
	   				a.monto325, 
	   				a.rfc325, 
	   				a.divisa325, 
	   				a.montocashback325, 
	   				a.conciliacion, 
	   				a.tipo_conciliacion,
	   				a.secuencia_extendida, 
	   				a.montointercard, 
	   				a.movconciliado, 
	   				a.movreversado, 
	   				a.aplicacion, 
	   				a.folio_mov,
	  				a.cod_retorno, 
	   				a.tipotransaccion325, 
	   				a.monto325, 
	   				a.bandera_proceso 
            INTO viConsecutivo, 
				 vsNombreArchivo, 
				 vsArchivoOrigen, 
				 vsIntegridad, 
				 vsIntegridadError, 
				 vsNumTarjeta, 
				 vsSecuencia,
				 vsIdComercio325, 
				 vsNomComercio325, 
				 vsReferencia23_325, 
				 vsMonto, 
				 vsRfc325, 
				 vsDivisa325, 
				 vmMontoCashBack,
				 vsConciliacion, 
				 viTipoConciliacion, 
				 vsSecuenciaExtendida, 
				 vmMontoIntercard, 
				 vsMovConciliado, 
				 vsMovReversado,
				 vsAplicacion, 
				 vsFolioAplica, 
				 vsCodigoRetorno, 
				 vsTipotransaccion325, 
				 vsMonto325, 
				 vsBanderaProceso
			FROM bditarjeta:td_movimientos_conciliacion	a, bditarjeta:td_archivos_conciliacion b
			WHERE (a.integridad='F' OR a.conciliacion = 'F'	OR a.aplicacion <> 'V') 
			and    a.nombrearchivo = b.nombrearchivo
			and    a.archivo_origen = b.archivo_origen
			and    b.fecha_archivo = psFecha
			and    a.archivo_origen in ('VNC', 'VND', 'VID', 'VIC','MCC', 'MCD')
			/*SELECT SKIP psRecuperacion FIRST psRegistros consecutivo, nombrearchivo, archivo_origen, 
				--REPLACE (REPLACE (integridad,'P', 'F'),'V', 'F'), -- Cambia para poder reprocesar los registros con aplicacion en P
				integridad, -- Cambia para poder reprocesar los registros con aplicacion en P
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montocashback325, 
				conciliacion, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion <> 'V') -- Se mostrar los registros hasta que estos sean reprocesados por el cron 3
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)
					   and archivo_origen in ('VNC', 'VND', 'VID', 'VIC','MCC', 'MCD')*/
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA MOVIMIENTOS PENDIENTES.',
'Fecha: 2011/10/24',
'Version: 20111024.1712',
'BD: bditarjeta',
'',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA CAMPO BANDERA PROCESO.',
'Fecha: 2011/11/24',
'Version: 20111124.1712',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 40.',
'Fecha: 2012/08/03',
'Version: 20120803.1555',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA EXTRACCION DE DATOS PARA OMITIR CARACTERES ESPECIALES EN EL NOMRE DEL COMERCIO.',
'Fecha: 2012/10/23',
'Version: 20121023.1036',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez ',
'Descripcion: Se agrega IF para tener consulta de usuario especial y resto de los usuarios de sistema.',
'Fecha: 2012/11/08',
'Version: 20121108',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Perfiles para modificacion de devoluciones no aplicadas',
'Solicito: Evelio Chaparro Garcia ',
'Descripcion: Se agregaron usuarios especificos para que pueda modificar devoluciones no aplicadas por regla de negocio ',
'Fecha: 2013/02/20',
'Version: 20130220.2030',
'BD: BdiTarjeta',
'',
'MODIFICACION: Juan Francisco Ponce ',
'Proyecto: Se integra recuperaciÃ³n de monto cashback325 ',
'Solicito: Luis Antonio Gomez Santiago ',
'Descripcion: Se modifica seleccion para poder recuperar datos MontoCashBack325 en lugar de montosurcharge325',
'Fecha: 2013/09/06',
'Version: 20130906.1445',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: Proyecto Master Card IntegraciÃ³n ',
'Solicito: Luis Antonio Gomez Santiago ',
'Descripcion: Se integran archivos MCD y MCC para el proceso de revalidacion por integridad',
'Fecha: 2014/03/10',
'Version: 20140310.1400',
'BD: BdiTarjeta';

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