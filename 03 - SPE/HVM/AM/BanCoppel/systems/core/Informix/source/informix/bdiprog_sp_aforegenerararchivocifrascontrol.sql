CREATE PROCEDURE "informix".sp_aforegenerararchivocifrascontrol(pNombreArchivo CHAR(30),pUser_Insert CHAR(8))
	RETURNING CHAR(5);
-------------------------------------------------------------------------------------------------
------------------------------------GENERALES -----------------------------------------------
DEFINE cTipoRegistro 				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE iSqlErr              		INTEGER;
DEFINE cCodRet              		CHAR(5);
DEFINE dFecha_Hoy           		DATE;
Define cSQL                 		CHAR(200);
DEFINE cProceso						CHAR(10);
DEFINE cNombreArchivoSalida 		CHAR(30);
DEFINE cRenglon						CHAR(30);
DEFINE cStatus						CHAR(1);
-----------------------------------------------------
--Encabezado		
DEFINE cFechaGeneracion	CHAR(8);  
DEFINE cFechaMovimientos CHAR(8); 
--detalle
DEFINE cEstatus	CHAR(2);
DEFINE cNumeroMovimientos INTEGER;
DEFINE cMonto BIGINT;
--sumario
DEFINE cNumeroRegistrosDetalle INTEGER;
DEFINE cMontoGlobal BIGINT;
DEFINE iSuma BIGINT;
DEFINE iSuma2 INTEGER;
DEFINE iContRegDet INTEGER;
DEFINE dHora  datetime HOUR TO SECond;
DEFINE cRuta CHAR(20);
DEFINE cRelleno CHAR(10);
DEFINE cRelleno1 CHAR(12);
DEFINE cRelleno2 CHAR(2);
DEFINE cRelleno3 CHAR(4);
---------------------------ECRIPTACION---------------------------
DEFINE cRetEncripcion		CHAR(6);
DEFINE cMsgEncripcion		CHAR(100);
DEFINE cLlave				CHAR(200);
DEFINE cNombreArchivo		CHAR(50);
DEFINE cRutaArchivoOrigen	CHAR(100);
DEFINE cRutaArchivoDestino	CHAR(100);
DEFINE cRutaRespaldo		CHAR(100);
DEFINE cUsuario				CHAR(20);

-----------------------------------------------------
/*	01 Por aplicar
	02 Aplicado exitosamente
	03 Fondos insuficientes en la cuenta de Afore
	04 El nÃÂº de cuenta no existe en el sistema
	05 Cuenta bloqueada por mandato judicial
	06 Cuenta cancelada o bloqueada por peticiÃÂ³el cliente
	07 RFC incorrecto                             
*/

DEFINE cCodRetInterno CHAR(5);
DEFINE cMensaje CHAR(200);


LET cCodRetInterno = '00000';
LET cRelleno = '';
LET cRelleno1 = '';
LET cRelleno2 = '';
LET cRelleno3 = '';
LET cTipoRegistro = '';
LET cFinLinea = '';
LET iSqlErr = '';
LET cCodRet = '';
LET dFecha_Hoy = '';
LET cSQL = '';
LET cProceso = '';
LET cStatus = '';
LET cNombreArchivoSalida = '';
LET cRenglon = '';
------------------------------------------------------------------------
LET cFechaGeneracion	= '';  
LET cFechaMovimientos = ''; 
LET cEstatus	= '';
LET cNumeroMovimientos = '';
LET cMonto = '';
LET cNumeroRegistrosDetalle = '';
LET cMontoGlobal = '';
LET iSuma = '0';
LET iSuma2= '0';
LET iContRegDet = 0;
---------------------------ECRIPTACION---------------------------
LET cRetEncripcion = '';
LET cMsgEncripcion = '';
LET cLlave = '';
LET cNombreArchivo = '';
LET cRutaArchivoOrigen = '';
LET cRutaArchivoDestino = '';
LET cRutaRespaldo = '';
LET cUsuario = '';
------------------------------------------------------------------------
LET cRuta = '';
LET cSQL 		= '';
LET dFecha_Hoy 	= '';
LET cCodRet 	= "00000";
LET cProceso = 'AforGACC';
LET cStatus  = '1';
LET dhora = CURRENT HOUR TO SECOND;

	--set debug file to "/informix/josea/sp_AforeGenerarArchivoCifrasControl2.out";
	--Trace on;


BEGIN

		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
			-------Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			    VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		on exception in (-668)
			Let cCodRet = '10010';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet;
	    END exception with resume;	
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 	---se valida si se recivio el parametro          pUser_Insert
		IF TRIM(pUser_Insert) = '' THEN
			LET pUser_Insert = 'informix';
		END IF;
		LET dhora = CURRENT;
		/*---------------------ERRORES
			
			LET cCodRet = '10011';-- El Archivo ya fue procesado
			LET cCodRet = '10013';--No existe el archivo
			LET cCodRet = '10024';--mensaje de error ya que no se Ejecuto el proceso Anterior
		*/
		------------- Se  obtiene la fecha del sistema   
		SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;
		
		---------Se crea el nombre del proceso con el consecutivo 01------------------
		LET cProceso = 'AforGACC' || '01';
		--Crear el nombre del archivo con el consecutivo 01 		    
		LET cNombreArchivoSalida = 'CONT' || lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy)  || '.BCOPPEL.01';
		--por si no  me envian el nombre del archivo
		IF TRIM(pNombreArchivo) <> '' THEN-- Hay que tomar el consecutivo del nombre del archivo
			LET cProceso = 'AforGACC' || SUBSTR(pNombreArchivo,23,2);
			LET cNombreArchivoSalida = 'CONT' || lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy)  || '.BCOPPEL.'||SUBSTR(pNombreArchivo,23,2);
		END IF;
			------------- Validar  que ya este Ejecutado el proceso de Generacionde Archivo de Confirmacion y concluido satisfactoriamente.
		IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = ('AforeGAC'|| SUBSTR(pNombreArchivo,23,2)) AND pp_Procesos.fech_proceso = dFecha_Hoy and  pp_Procesos.status = '2') THEN
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------Validar si ya se ejecuto el proceso de Generar Archivo De Cifras De Control
			IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy) THEN
				SELECT status INTO cStatus FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy;
				IF cStatus != '1' THEN--El Archivo ya fue procesado
					--- el estatus es  02
					LET cCodRet = '10011';
					CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
					INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
					VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);		
					RETURN cCodRet;
				END IF;
			ELSE
				--- guardar el inicio del proceso y se ejecuta
				INSERT INTO bdiprog:pp_Procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
				VALUES (cProceso,dFecha_hoy,cStatus,pUser_Insert,dFecha_Hoy);		
			END IF;
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ELSE
			--- mensaje de error ya que se devio haber Ejecutado el proceso de Generacion de archivos de control
				LET cCodRet = '10024';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);	
				RETURN cCodRet;
		END IF;

		--------
		DELETE FROM pp_archcifras;
		--o	Se leerÃÂ¡e la tabla de parÃÂ¡tros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, nÃÂº de contrato, etc.).
		select valor into cRuta from  bdiprog:pp_Parametros where cve_param = '100';
		
		--datos del encabezado
		LET cTipoRegistro = 'E';
		LET cFechaGeneracion = lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy);
		LET cFechaMovimientos = lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy);
		
		LET cRenglon = cTipoRegistro || cFechaGeneracion || cFechaMovimientos;
		
		INSERT INTO bdiprog:pp_archcifras (columna)
		VALUES (cRenglon);			
		
		--se obtienen los datos de Detalle
		IF EXISTS (SELECT status FROM pp_detalle WHERE pp_detalle.nombre_arch  = pNombreArchivo) THEN
			FOREACH
				Select distinct(status), count(status), sum(imp_netopagar * 100)
				Into cEstatus,cNumeroMovimientos,cMonto
				From bdiprog:pp_detalle
				Where bdiprog:pp_detalle.nombre_arch  = pNombreArchivo
				Group by status		
				
				LET cTipoRegistro = 'D';
				LET cRelleno = lpad(cMonto,10,'0');
				LET cRelleno3 =  lpad(cNumeroMovimientos,4,'0');
				LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cRelleno3 || cRelleno;
				
				INSERT INTO bdiprog:pp_archcifras (columna)
				VALUES (cRenglon);		
			
				LET iSuma = iSuma + cMonto;
				LET iSuma2 = iSuma2 + cNumeroMovimientos;
				LET iContRegDet = iContRegDet + 1;
			END FOREACH;
		ELSE
				LET cTipoRegistro = 'D';
				LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cNumeroMovimientos || cMonto;
				
				INSERT INTO bdiprog:pp_archcifras (columna)
				VALUES (cRenglon);	
		END IF
		-- se obtienen lo datos del sumario
		LET cTipoRegistro = 'S';
		LET cMontoGlobal = iSuma;
		LET cRelleno1 = lpad(cMontoGlobal,12,'0');
		LET cNumeroRegistrosDetalle = iContRegDet;
		LET cRelleno2 = LPAD(cNumeroRegistrosDetalle,2,'0');
		LET cRenglon = cTipoRegistro || cRelleno2 || cRelleno1;
			
		INSERT INTO bdiprog:pp_archcifras (columna)
		VALUES (cRenglon);		
		
	    /* _  */	---------Se Almacena toda la informacion en un archivo implementando un (UNLOAD)---------
				
		LET cSQL = ''; -- Genero archivo con Unload
		LET  cSQL = 'echo "UNLOAD TO '||TRIM(cRuta)||'temporal.unl ' ||
					'select columna from pp_archcifras; " > '||TRIM(cRuta)||'query3.sql';						
		SYSTEM cSQL;
		
		--LET cSQL = 'chmod 777 '||TRIM(cRuta)||'query3.sql';
		--SYSTEM cSQL;
		
		-- Ejecuto el unload
		--LET cSQL = 'dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; --Se activa para desarrollo   
		LET cSQL = '/ifxsif01/bin/dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; --Se activa para Produccion 
		SYSTEM cSQL;

		-- Le quita el ultimo | al archivo .txt y se renombra con estandar del nombre
		LET cSQL = "sed 's/|$//g' "||TRIM(cRuta)||"temporal.unl > " 
			 || TRIM(cRuta) || cNombreArchivoSalida;
		SYSTEM cSQL;

		--Se borra archivo temp una vez generado
		LET cSQL = 'rm -rf '||TRIM(cRuta)||'temporal.unl';
		SYSTEM cSQL;
		
		LET cSQL = 'rm -f '||TRIM(cRuta)||'query3.sql';
		SYSTEM cSQL;

        -- Se dan permisos al archivo generado
		LET cSQL = 'chmod 777 ' || TRIM(cRuta) || TRIM (cNombreArchivoSalida);
		SYSTEM cSQL ;
			
		-- Almacenar en pp_arch_afore (status .01., y tipo de archivo .T.), 
		INSERT INTO bdiprog:pp_arch_afore (nombre_arch   ,tipo,fecha_generado,fecha_procesado,status,user_insert,fecha_insert)
		VALUES (cNombreArchivoSalida ,'T' ,dFecha_Hoy,dFecha_Hoy,'01'  ,pUser_Insert,dFecha_Hoy);		
		--Registrar el final del proceso en la tabla pp_proceso
		UPDATE bdiprog:pp_Procesos SET status = '2'
		WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy ;
		
		--Obtiene parametros de encriptacion
		SELECT llave, ruta_origen, ruta_destino, ruta_originales, usuario
		INTO cLlave, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cUsuario
		FROM bdinteg:si_configura_pgp
		WHERE codigo = 'AFORE_02';
		
		LET cNombreArchivo = cNombreArchivoSalida;
		--Se encripta el archivo		
		EXECUTE PROCEDURE bdiprog:"informix".sp_encriptaarchivo(cUsuario, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cNombreArchivo, cLlave)
		INTO cRetEncripcion, cMsgEncripcion;
		
		IF cRetEncripcion <> '000000' THEN
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,cNombreArchivo,cRetEncripcion,cMsgEncripcion,pUser_Insert,dFecha_Hoy,dhora);
		END IF;
		
		RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: el objetivo de este Sp es el de Generar un archivo del total de pagos procesados.', 
'..........................................................',
'Solicito : Armando Mercado',	
'AUTOR: CÃÂ©r ValdÃÂ©Figueroa',
'FECHA: Mayo 2009',
'VERSION: 200905',
'BD: BDIPROG',
'CAMBIOS: Este Sp se modifico para que guarde los errores no controlados en bitacora, ademas de que se aplica una multiplicacion * 100',
'         esto con el fin de obtener lo decimales solo que los redondeaba, por lo que la multiplicacion se realizo antes en un select',
'		  con el fin de eliminar ese detalle. ',
'MODIFICO: CÃÂ©sar ValdÃÂ©z Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616';

CREATE PROCEDURE "informix".sp_obt_cant_reg_referencias_bex(pNumCliente char(20), pCveCuenta char(2),pCveBanco char(3))
        RETURNING char(5), integer;

       DEFINE vcodret   char(5);
       DEFINE vCantidad  integer;
       DEFINE sql_err       integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '00000';
LET vCantidad = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;

BEGIN
	SELECT COUNT(cuenta) AS cantidad
	INTO vCantidad
	FROM bdiprog:pp_ctasterceros_bex
	WHERE num_cte=TRIM(pNumCliente)
	AND cve_banco=TRIM(pCveBanco)
	AND cve_cuenta=TRIM(pCveCuenta)
	AND cve_estado='01';
	--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00';

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;