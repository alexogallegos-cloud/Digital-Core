CREATE PROCEDURE "informix".sp_guardarstatusconciliacion
(
psArchivoOrigen CHAR(3), pdFechaConciliacion Datetime year to fraction(5), 
psUsuario CHAR(8), psNom_Archivo CHAR(30), 
psTransferirArchWin_Aix CHAR(1), pdTransferirArchWin_AixHora Datetime year to fraction(5),
psObtener_Archivo CHAR(1), pdObtenerArchivoHora Datetime year to fraction(5), psIntegridad CHAR(1), 
pdIntegridadHora Datetime year to fraction(5),
psCargar_Tabla CHAR(1), pdCargarTablaHora Datetime year to fraction(5), piNum_Registros INTEGER, 
psConciliacion CHAR(1), pdConciliacionHora Datetime year to fraction(5),
piNum_Registros_Conciliados INTEGER, psExportar_Registros_A_Central CHAR(1), 
pdExportarCentralHora Datetime year to fraction(5),
piNum_Registros_Exportados INTEGER, psConfigurar_Central CHAR(1), 
pdConfigurarCentralHora Datetime year to fraction(5),
psAplicar_Saldos CHAR(1), pdAplicarSaldosHora Datetime year to fraction(5), 
pdFecha_Termino Datetime year to fraction(5), psActividad CHAR (25), 
psDescripcionError CHAR (500),  psFlagFinExito CHAR(1)
)
-- Devuelve un numero de error controlado
RETURNING INTEGER ;

--****************************************************************************************************
-- DESCRIPCION: Guarda informacion en la tabla monitor_conciliacionaut
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 28/10/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--MODIFICADO : 2010/01/20  CASANOVA EDEZA HECTOR JUAN se modifico para que al presentarse un error en la integridad permita continuar con la conciliacion.',
--MODIFICADO : 2010/02/10  CASANOVA EDEZA HECTOR JUAN se modifico para que mantengan ligados los registros de la tabla de monitor con sus respctivos registros de error de la syserror para el caso de reg. con error de integridad y error en otrop paso o finalizacion correcta',
--MODIFICADO : 2010/02/15  CASANOVA EDEZA HECTOR JUAN SE MODIFICO EL FILTRO CON EL QUE SE ACTUALIZA LA TABLA MONITOR_CONCILIACIONAUT DEBIDO A QUE EL NOMBRE DEL ARCHIVO PUEDE VARIAR ENTRE MAYUSCULAS Y MINUSCULAS POLO QUE SE LE APLICA UN UPPER AL GUARDAR/ACTUALIZAR Y AL PARAMETRO DE ENTRADA DEL SP.',
--MODIFICADO : 2010/02/18  CASANOVA EDEZA HECTOR JUAN SE MODIFICO EL FILTRO CON EL QUE SE ACTUALIZA LA TABLA SYSERROR_CONCILIACION PARA INCLUIR UN NUEVO CAMPO "NOMBREARCHIVO" EN LOS FILTROS PARA LAS BUSQUEDAS Y ACTUALIZACIONES.
--MODIFICADO : 2011/10/13  CASANOVA EDEZA HECTOR JUAN Se aumenta el tamaño de la variable del nombre de los archivos de 23 a 30 caracteres..
--***************************************************************************************************

--Declaracion de variables
DEFINE viKeyxBitCon INTEGER ;
DEFINE viInsertaBitacora INTEGER ;
DEFINE viSQLerr INTEGER ;
DEFINE viSecBitacora INTEGER ;

DEFINE viKeyxBitConAUX INTEGER ;

DEFINE vsActividad CHAR(100);


--Asignacion de variables
LET viKeyxBitCon =0 ;
LET viInsertaBitacora = 0;
LET viSecBitacora = 0 ;
LET viSQLerr = 0 ;
LET vsActividad = '';

LET viKeyxBitConAUX = 0;


--Inicio del cuerpo
BEGIN

--Controlador de errores de informix
  ON EXCEPTION SET viSQLerr
        IF viSQLerr <> 0 THEN
            RETURN viSQLerr ;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	
	IF ( psDescripcionError <> '') OR ( psFlagFinExito = 'V') THEN	
		
	--Llamado al sp_insertar_bitacora
		EXECUTE PROCEDURE intercard:"informix".sp_insertar_bitacora( psUsuario, psArchivoOrigen, psActividad , psDescripcionError  ) INTO viInsertaBitacora ;
		
		IF ((psIntegridad <> 'W') AND (psFlagFinExito = 'V')) THEN -- TERMINO OK 
			LET vsActividad = 'TERMINA OK';
			--SE OBTIENE KEY X NOMALMENTE
			SELECT MAX(Keyx) INTO viKeyxBitCon FROM intercard:"informix".bitacora_conciliacion WHERE ArchivoOrigen = psArchivoOrigen 
			AND FechaConciliacion::DATE = CURRENT::DATE AND Actividad = psActividad;
			
		ELIF ((psIntegridad = 'W') AND (psFlagFinExito = 'F')) THEN -- ERROR DE INTEGRIDAD AUN NO TERMINA
			
			LET vsActividad = 'WARNING INTEGRIDAD';
			--SE OBTIENE KEY X NOMALMENTE
			SELECT MAX(Keyx) INTO viKeyxBitCon FROM intercard:"informix".bitacora_conciliacion WHERE ArchivoOrigen = psArchivoOrigen 
			AND FechaConciliacion::DATE = CURRENT::DATE AND Actividad = psActividad;
			
			--OBTIENE EL ULTIMON
			SELECT MAX(Keyx) INTO viKeyxBitConAUX FROM intercard:"informix".SysError_Conciliacion WHERE Fecha::DATE = CURRENT::DATE AND TRIM(UPPER (NVL(NombreArchivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			
			--UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viKeyxBitCon WHERE Keyx = viKeyxBitConAUX AND Fecha::DATE = CURRENT::DATE AND NombreArchivo = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viKeyxBitCon WHERE Fecha::DATE = CURRENT::DATE AND TRIM(UPPER (NVL(NombreArchivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			
			
		ELIF ((psIntegridad = 'W') AND (psFlagFinExito = 'V')) THEN -- TERMINO OK PERO CON WARNING     -- SE DEJA EL KEYX DE W ( NO SE OBTIENE KEYX NUEVO)  	--SE OBTIENE EL KEYX ACTUAL DE CONCILIACION Y SE ACTUALIZA EL DE SYSERROR
			
			LET vsActividad = 'TERMINO OK PERO CON WARNING';
			
			---OBTIENEN EL NUEVO KEYX DE SYSERROR (NUEVO)
			SELECT MAX(Keyx) INTO viKeyxBitConAUX FROM intercard:"informix".bitacora_conciliacion WHERE ArchivoOrigen = psArchivoOrigen 
			AND FechaConciliacion::DATE = CURRENT::DATE AND Actividad = psActividad;
			
			--OBTIENE EL KEYX DE LA TABLA MONITOR CONCILIACION (ACTUAL)
			SELECT FIRST 1 SecuenciaBitacora INTO viSecBitacora FROM intercard:"informix".Monitor_ConciliacionAut WHERE ArchivoOrigen = psArchivoOrigen AND FechaConciliacion::DATE = pdFechaConciliacion::DATE AND TRIM (UPPER (NVL(Nom_Archivo, ''))) = TRIM (UPPER (NVL(psNom_Archivo, ''))); 
			
			--ACTUALIZA EL KEYX DE SYSERROR
			--UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viSecBitacora WHERE SecuenciaBitacora = viKeyxBitConAUX AND NombreArchivo = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;;
			UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viSecBitacora WHERE Fecha::DATE = CURRENT::DATE AND TRIM(UPPER (NVL(NombreArchivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			
			LET viKeyxBitCon = viSecBitacora;
			
		ELIF ((psDescripcionError <> '') AND (psIntegridad <> 'W') )THEN -- ERROR DE CONCILIACION ANTES DE LA INTEGRIDAD O DESPUES PERO CON INTEGRIDAD  OK
			LET vsActividad = 'ERROR DE CONCILIACION ANTES DE LA INTEGRIDAD O DESPUES PERO CON INTEGRIDAD  OK';
			
			--SE OBTIENE KEY X NOMALMENTE
			SELECT MAX(Keyx) INTO viKeyxBitCon FROM intercard:"informix".bitacora_conciliacion WHERE ArchivoOrigen = psArchivoOrigen 
			AND FechaConciliacion::DATE = CURRENT::DATE AND Actividad = psActividad;
			
			UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viKeyxBitCon WHERE Fecha::DATE = CURRENT::DATE AND TRIM(UPPER (NVL(NombreArchivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			
		ELIF ((psDescripcionError <> '') AND (psIntegridad = 'W') AND (psCargar_Tabla <> '') )THEN -- ERROR DE CONCILIACION DESPUES DE LA INTEGRIDAD CON WARNING
			LET vsActividad = 'ERROR DE CONCILIACION DESPUES DE LA INTEGRIDAD CON WARNING';
			---OBTIENEN EL NUEVO KEYX DE SYSERROR (NUEVO)
			
			SELECT MAX(Keyx) INTO viKeyxBitConAUX FROM intercard:"informix".bitacora_conciliacion WHERE ArchivoOrigen = psArchivoOrigen 
			AND FechaConciliacion::DATE = CURRENT::DATE AND Actividad = psActividad;
			
			--OBTIENE EL KEYX DE LA TABLA MONITOR CONCILIACION (ACTUAL)
			SELECT FIRST 1 SecuenciaBitacora INTO viSecBitacora FROM intercard:"informix".Monitor_ConciliacionAut WHERE ArchivoOrigen = psArchivoOrigen AND FechaConciliacion::DATE = pdFechaConciliacion::DATE AND TRIM (UPPER (NVL(Nom_Archivo, ''))) = TRIM (UPPER (NVL(psNom_Archivo, ''))); 
			--ACTUALIZA EL KEYX DE SYSERROR
			UPDATE intercard:"informix".SysError_Conciliacion SET SecuenciaBitacora = viSecBitacora WHERE Fecha::DATE = CURRENT::DATE AND TRIM(UPPER (NVL(NombreArchivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))) ;
			
			
			
			LET viKeyxBitCon = viSecBitacora;
		ELSE
			LET vsActividad = 'NO CONTEMPLADO';
			
		END IF;
		
		
	END IF;
	
	-- Si existe ya existe un registro con el archivo origen solamente actualizara la informacion	
	IF EXISTS (SELECT ArchivoOrigen, FechaConciliacion FROM intercard:"informix".monitor_conciliacionaut WHERE ArchivoOrigen = UPPER (NVL(psArchivoOrigen, '' )) AND FechaConciliacion::DATE = pdFechaConciliacion::DATE AND TRIM( UPPER(NVL(Nom_Archivo, ''))) = UPPER(TRIM(NVL(psNom_Archivo, '' ))) ) THEN
		
		
		IF (viKeyxBitCon <> 0) THEN
			UPDATE intercard:"informix".monitor_conciliacionaut SET  SecuenciaBitacora = viKeyxBitCon, TransferirArchWin_Aix = psTransferirArchWin_Aix, TransferirArchWin_AixHora = pdTransferirArchWin_AixHora,  Obtener_Archivo = psObtener_Archivo, ObtenerArchivoHora = pdObtenerArchivoHora,
					Integridad = psIntegridad, IntegridadHora = pdIntegridadHora , Cargar_Tabla = psCargar_Tabla, CargarTablaHora = pdCargarTablaHora, Num_Registros = piNum_Registros, Conciliacion = psConciliacion, ConciliacionHora = pdConciliacionHora,
					Num_Registros_Conciliados = piNum_Registros_Conciliados, Exportar_Registros_A_Central = psExportar_Registros_A_Central, ExportarCentralHora = pdExportarCentralHora, Num_Registros_Exportados = piNum_Registros_Exportados,
					Configurar_Central = psConfigurar_Central, ConfigurarCentralHora = pdConfigurarCentralHora, Aplicar_Saldos = psAplicar_Saldos, AplicarSaldosHora = pdAplicarSaldosHora, Fecha_Termino = pdFecha_Termino
					WHERE ArchivoOrigen = UPPER (NVL(psArchivoOrigen, '' )) AND FechaConciliacion::DATE = pdFechaConciliacion::DATE AND TRIM (UPPER (NVL(Nom_Archivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))); 
		ELSE
			UPDATE intercard:"informix".monitor_conciliacionaut SET  TransferirArchWin_Aix = psTransferirArchWin_Aix, TransferirArchWin_AixHora = pdTransferirArchWin_AixHora,  Obtener_Archivo = psObtener_Archivo, ObtenerArchivoHora = pdObtenerArchivoHora,
				Integridad = psIntegridad, IntegridadHora = pdIntegridadHora , Cargar_Tabla = psCargar_Tabla, CargarTablaHora = pdCargarTablaHora, Num_Registros = piNum_Registros, Conciliacion = psConciliacion, ConciliacionHora = pdConciliacionHora,
				Num_Registros_Conciliados = piNum_Registros_Conciliados, Exportar_Registros_A_Central = psExportar_Registros_A_Central, ExportarCentralHora = pdExportarCentralHora, Num_Registros_Exportados = piNum_Registros_Exportados,
				Configurar_Central = psConfigurar_Central, ConfigurarCentralHora = pdConfigurarCentralHora, Aplicar_Saldos = psAplicar_Saldos, AplicarSaldosHora = pdAplicarSaldosHora, Fecha_Termino = pdFecha_Termino
				WHERE ArchivoOrigen = UPPER (NVL(psArchivoOrigen, '' )) AND FechaConciliacion::DATE = pdFechaConciliacion::DATE AND TRIM (UPPER (NVL(Nom_Archivo, ''))) = TRIM(UPPER (NVL(psNom_Archivo, ''))); 
		END IF;
				
	-- Si no existe ese archivo origen lo insertara en la tabla
	ELSE	
		
		
		--Inserto el valor de los parametros de entrada en la tabla monitor_conciliacion
		INSERT INTO intercard:"informix".monitor_conciliacionaut
		(
		    ArchivoOrigen,
			FechaConciliacion,
			SecuenciaBitacora,
			Usuario,
			Nom_Archivo,
			TransferirArchWin_Aix,
			TransferirArchWin_AixHora, 	
			Obtener_Archivo,
			ObtenerArchivoHora,
			Integridad,
			IntegridadHora,
			Cargar_Tabla,
			CargarTablaHora,
			Num_Registros,
			Conciliacion,
			ConciliacionHora,
			Num_Registros_Conciliados,
			Exportar_Registros_A_Central,
			ExportarCentralHora,
			Num_Registros_Exportados,
			Configurar_Central,
			ConfigurarCentralHora,
			Aplicar_Saldos,
			AplicarSaldosHora,
			Fecha_Termino 
		)
		VALUES
		(
		    UPPER (NVL(psArchivoOrigen, '' )),
		    NVL(pdFechaConciliacion, CURRENT),
		    NVL(viKeyxBitCon, 0),
		    NVL(psUsuario, ''),
		    UPPER (TRIM(NVL(psNom_Archivo, ''))),
			UPPER (NVL(psTransferirArchWin_Aix, '')),
			NVL(pdTransferirArchWin_AixHora, CURRENT),
		    UPPER (NVL(psObtener_Archivo, '')),
			NVL(pdObtenerArchivoHora, CURRENT),
		    UPPER (NVL(psIntegridad, '')),
			NVL(pdIntegridadHora, CURRENT),
		    UPPER (NVL(psCargar_Tabla, '')),
			NVL(pdCargarTablaHora, CURRENT),
		    NVL(piNum_Registros, 0),
		    UPPER (NVL(psConciliacion, '')),
			NVL(pdConciliacionHora, CURRENT),
		    NVL(piNum_Registros_Conciliados, 0),
		    UPPER(NVL(psExportar_Registros_A_Central, '')),
			NVL(pdExportarCentralHora, CURRENT),
		    NVL(piNum_Registros_Exportados, 0),
		    UPPER (NVL(psConfigurar_Central, '')),
			NVL(pdConfigurarCentralHora, CURRENT),
		    UPPER (NVL(psAplicar_Saldos, '')),
			NVL(pdAplicarSaldosHora, CURRENT),
		    NVL(pdFecha_Termino, CURRENT)
		);
						
	END IF;

--Regresa valor de error
RETURN viSQLerr ;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Guarda informacion en la tabla monitor_conciliacionaut.',
'Fecha: 2008/10/28',
'Version: 20081028.1025',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se modifico para que al presentarse un error en la integridad permita continuar con la conciliacion.',
'Fecha: 2010/01/20',
'Version: 20100120.1625',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se modifico para que mantengan ligados los registros de la tabla de monitor con sus respctivos registros de error de la syserror para el caso de reg. con error de integridad y error en otrop paso o finalizacion correcta',
'Fecha: 2010/02/10',
'Version: 20100210.0922',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO EL FILTRO CON EL QUE SE ACTUALIZA LA TABLA MONITOR_CONCILIACIONAUT DEBIDO A QUE EL NOMBRE DEL ARCHIVO PUEDE VARIAR ENTRE MAYUSCULAS Y MINUSCULAS POLO QUE SE LE APLICA UN UPPER AL GUARDAR/ACTUALIZAR Y AL PARAMETRO DE ENTRADA DEL SP.',
'Fecha: 2010/02/15',
'Version: 20100215.01622',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO EL FILTRO CON EL QUE SE ACTUALIZA LA TABLA SYSERROR_CONCILIACION PARA INCLUIR UN NUEVO CAMPO "NOMBREARCHIVO" EN LOS FILTROS PARA LAS BUSQUEDAS Y ACTUALIZACIONES.',
'Fecha: 2010/02/18',
'Version: 20100218.01835',
'BD: Intercard''',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1234',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Transferencia de pagos',
'Folio: ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se aumenta el tamaño de la variable del nombre de los archivos de 23 a 30 caracteres.',
'Fecha: 2011/10/13',
'Version: 20111013.1206',
'BD: Intercard'
;

CREATE PROCEDURE "informix".sp_cons_fechaexp(p_sEmpresa CHAR(3), p_sNumTar CHAR(20))

RETURNING CHAR(5), CHAR(20);

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE v_sFechaExp CHAR(4);

--****************************************************************************************************
-- DESCRIPCION: Consulta Fecha de Expiracion de Tarjeta.
-- AUTOR : RGH
-- FECHA : 01/12/2011
-- SISTEMA : OFI
--****************************************************************************************************

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET v_sFechaExp = '';

--set debug file to "/tmp/sp_cons_fechaexp.out";
--Trace on;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;

	BEGIN
	
		ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF viSqlErr <> 0 THEN
				RETURN viSqlErr,'';
			END IF;
		END EXCEPTION;
		
		--Valida que la tarjeta exista, si existe consulta su fecha de expiración sino manda el codigo de retorno 1
		IF EXISTS (SELECT 1 FROM tarjeta WHERE numtarjeta = p_sNumTar) THEN
			SELECT fechaexp
			INTO v_sFechaExp
			FROM tarjeta
			WHERE numtarjeta = p_sNumTar;
		ELSE 
			LET vsCodRet = '00001';
		END IF;
		
		RETURN vsCodRet,v_sFechaExp;
	
	END
END PROCEDURE;