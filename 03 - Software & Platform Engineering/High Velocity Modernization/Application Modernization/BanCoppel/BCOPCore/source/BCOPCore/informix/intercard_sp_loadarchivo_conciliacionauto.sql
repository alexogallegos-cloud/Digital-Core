CREATE PROCEDURE "informix".sp_loadarchivo_conciliacionauto ( psRuta_Repositorio VARCHAR (90), psNomArchivo VARCHAR (30), psRuta_Procesos VARCHAR (90) )

RETURNING INTEGER AS Retorno ;

--****************************************************************************************************
-- DESCRIPCION:  CARGA LOS REGISTROS DEL ARCHIVO A LA TABLA Archivos_Conciliacion PARA SER PROCESADO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 20/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 14/12/2009 Casanova Edeza Hector Juan.  
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsSQL VARCHAR (200) ;
DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vsSQL = '' ;
LET visqlerr = 0;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado        
				
		RETURN visqlerr ;
		
    END EXCEPTION;
			--SET DEBUG FILE TO '/home/informix/rrm/TraceLOAD.txt'; 
			--TRACE ON;
	IF psNomArchivo LIKE 'REDTCAT%' THEN 
		DELETE FROM intercard:Archivos_Conciliacion;
		--CREA ARCHIIVO DE INSTRUCCION DE CARGA
			LET vsSQL = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || "'" ||" DELIMITER "  ||"','"|| ' INSERT INTO archivos_conciliacion" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsSQL = 'dbaccess intercard ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
		
		RETURN visqlerr;
	ELSE
		DELETE FROM intercard:Archivos_Conciliacion;
		--CREA ARCHIVO DE INSTRUCCION DE CARGA
			LET vsSQL = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || "'" || ' INSERT INTO archivos_conciliacion" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsSQL = 'dbaccess intercard ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		RETURN visqlerr;
	END IF;

END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Carga un archivo de conciliacion a la tabla de trabajo (Archivos_Conciliacion) para ser procesado.',
'Fecha: 2008/08/20',
'Version: 20080820.0933',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se limpia la tabla de trabajo (Archivos_Conciliacion) antes de cargar un nuevo archivo.',
'Fecha: 2010/01/20',
'Version: 20100120.1225',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1308',
'BD: Intercard'
'Modificado: Resendiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 30 caracteres y se agrega ciclo para que los archivos REDTCAT137DYYMMDDEDCC.DAT los cargue ignorando el delimitador "|" ',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard';*/;

CREATE PROCEDURE "informix".sp_obtregmonitorconciliacionaut
(
psArchivoOrigen CHAR(3),
pdFechaInicial DateTime  YEAR TO fraction(5), 
pdFechaFinal DateTime  YEAR TO fraction(5)
)

RETURNING INTEGER AS X, CHAR(3) AS Archivo, DATE AS Fecha_Conciliacion, CHAR(8) AS Usuario, CHAR(30) AS Nombre_Archivo, CHAR(1) AS Transferir_Archivo_Win_Aix, DATETIME YEAR TO FRACTION(5) AS Trans_Hora,
		  CHAR(1) AS Obtener_Archivo, DATETIME YEAR TO FRACTION(5) AS ObtArch_Hora, CHAR(1) AS Integro, DATETIME YEAR TO FRACTION(5)AS Integridad_Hora, CHAR(1) AS Cargar_Tabla,
          DATETIME YEAR TO FRACTION(5) AS Cargar_Tabla_Hora, INTEGER AS Numero_Registros, CHAR(1) AS Conciliacion, DATETIME YEAR TO FRACTION(5) AS Conc_Hora,
		  INTEGER AS Numero_Registros_Conciliados, CHAR(11) AS Exportar_Registros_Central, DATETIME YEAR TO FRACTION(5) AS ExpRegCentral_Hora,
		  INTEGER AS Numero_Registros_Exportados, CHAR(1) AS Configurar_Central, DATETIME YEAR TO FRACTION(5) AS ConfigCentral_Hora, CHAR(1) AS Aplicar_Saldos, DATETIME YEAR TO FRACTION(5)AS AplicarSaldos_Hora, DATE AS Fecha_Termino;
		  
		  
--****************************************************************************************************
-- DESCRIPCION: Obtiene informacion de la tabla monitor_conciliacionaut
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 10/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--MODIFICADO: ROCHIN ROCHA EDGAR IVAN 18/09/2008
--***************************************************************************************************

		  
DEFINE cCodRet CHAR(3);
DEFINE viLlave INTEGER ;
DEFINE vsArchivoO CHAR(3);
DEFINE vdFechaCon DateTime  YEAR TO fraction(5);
DEFINE vsUsuario CHAR(8) ;
DEFINE vsNomArch CHAR(30) ;
DEFINE vsTransferirArchWin_Aix CHAR(1) ;
DEFINE vdTransferirArchWin_AixHora Datetime year to fraction (5); 
DEFINE vsObtArchivo CHAR(1);
DEFINE vdObtenerArchivoHora DateTime YEAR TO fraction(5);
DEFINE vsIntegro CHAR(1) ;
DEFINE vdIntegridadHora DateTime YEAR TO fraction(5);
DEFINE vsCargarT CHAR(1) ;
DEFINE vdCargarTablaHora DateTime YEAR TO fraction(5);
DEFINE viNumReg INTEGER ;
DEFINE vsConci CHAR(1);
DEFINE vdConciliacionHora DateTime YEAR TO fraction(5);
DEFINE viNumRegCon INTEGER ;
DEFINE vsExpRegCent CHAR(11) ;
DEFINE vdExportarCentralHora DateTime YEAR TO fraction(5);
DEFINE viNumRegExp INTEGER ;
DEFINE vsConfigCen CHAR(1) ;
DEFINE vdConfigurarCentralHora DateTime YEAR TO Fraction(5);
DEFINE vsAplicarSal CHAR(1) ;
DEFINE vdAplicarSaldosHora DateTime YEAR TO Fraction(5);
DEFINE vdFecTermino DateTime  YEAR TO fraction(5);

DEFINE visqlerr INTEGER ;

Let viLlave  = 0;
Let vsArchivoO = "";
Let vdFechaCon = CURRENT ;
Let vsUsuario = '';
Let vsNomArch = '';
LET vsTransferirArchWin_Aix = '' ;
LET vdTransferirArchWin_AixHora = CURRENT ;
Let vsObtArchivo = '';
LET vdObtenerArchivoHora = CURRENT ;
Let vsIntegro = "" ;
LET vdIntegridadHora = CURRENT ;
Let vsCargarT = "" ;
LET vdCargarTablaHora = CURRENT ;
Let viNumReg = 0 ;
Let vsConci = "" ;
LET vdConciliacionHora = CURRENT ;
Let viNumRegCon = 0 ;
Let vsExpRegCent = "" ;
LET vdExportarCentralHora = CURRENT ;
Let viNumRegExp = 0 ;
Let vsConfigCen = "" ;
LET vdConfigurarCentralHora = CURRENT ;
Let vsAplicarSal = "" ;
LET vdAplicarSaldosHora = CURRENT ;
Let vdFecTermino = CURRENT ;
LET cCodRet = "000";

LET visqlerr = 0 ;
--set debug file to "/tmp/sp_ObtRegMonitorConciliacion.out";
--Trace on;
BEGIN


ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN             

            RETURN visqlerr, vsArchivoO, vdFechaCon, vsUsuario, TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora, vsIntegro, vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora, viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;

        END IF ; 
    END EXCEPTION ;

 



IF(pdFechaInicial = "") OR (pdFechaInicial is NULL) THEN
    LET visqlerr = 1 ;
    RETURN  visqlerr, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;
END IF ;

IF (pdFechaFinal = "") OR (pdFechaFinal IS NULL) THEN
    LET visqlerr = 2;
    RETURN  visqlerr, vsArchivoO, vdFechaCon, vsUsuario,  TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;
END IF ;


IF (psArchivoOrigen = '')  THEN
        
        SET ISOLATION TO DIRTY READ ;
        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Nom_Archivo, TransferirArchWin_Aix, TransferirArchWin_AixHora, Obtener_Archivo, ObtenerArchivoHora, Integridad, IntegridadHora,
			Cargar_Tabla, CargarTablaHora, Num_Registros, Conciliacion, ConciliacionHora, Num_Registros_Conciliados, Exportar_Registros_A_Central, ExportarCentralHora,
			Num_Registros_Exportados, Configurar_Central, ConfigurarCentralHora, Aplicar_Saldos, AplicarSaldosHora,  Fecha_Termino
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora,  vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino
            FROM monitor_conciliacionaut WHERE FechaConciliacion >=  pdFechaInicial  AND Fecha_Termino <= pdFechaFinal ORDER BY KeyX
			
		            
               RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario, TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino  WITH RESUME ;

        END ForEach
ELSE
        
        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Nom_Archivo, TransferirArchWin_Aix, TransferirArchWin_AixHora, Obtener_Archivo, ObtenerArchivoHora, Integridad, IntegridadHora,
			Cargar_Tabla, CargarTablaHora, Num_Registros, Conciliacion, ConciliacionHora, Num_Registros_Conciliados, Exportar_Registros_A_Central, ExportarCentralHora,
			Num_Registros_Exportados, Configurar_Central, ConfigurarCentralHora, Aplicar_Saldos, AplicarSaldosHora,  Fecha_Termino 
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino  
            FROM monitor_conciliacionaut WHERE ArchivoOrigen = psArchivoOrigen AND FechaConciliacion >=  pdFechaInicial  AND Fecha_Termino <= pdFechaFinal ORDER BY keyx
            
                RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario,  TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino  WITH RESUME ;          

        END ForEach

END IF ;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE INFORMACION DE LA TABLA MONITOR_CONCILIACIONAUT.',
'Fecha: 2008/09/10',
'Version: 20080910.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable correspondiente al nombre del archivo.',
'Fecha: 2010/04/13',
'Version: 20100413.0913',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1316',
'BD: Intercard'
''
'Modificado: Resendiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 30 caracteres.',
'Fecha: 2010/10/13',
'Version: 20111013.1400',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_esnumericoneg( psCadena CHAR (20))

RETURNING CHAR (1) AS Munerico ;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS NEGATIVOS
-- CLONACION : Reséndiz Martinez Ricardo  
-- FECHA : 13/10/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRespuesta CHAR (1) ;

DEFINE visqlerr INTEGER ;
/* INICIALIZACION DE VARIABLES */

LET vsRespuesta = 'F' ;

LET visqlerr = 0;

BEGIN

  ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
  
        IF visqlerr = -1213 THEN             
			LET vsRespuesta = 'F' ;	
		ELSE
			LET vsRespuesta = ' ' ;	
        END IF; 
		
		RETURN vsRespuesta ;
		
    END EXCEPTION;
	
	IF (psCadena <= 0) THEN 
		LET vsRespuesta = 'V';
	ELSE
		LET vsRespuesta = 'F';
	END IF  ;
	
	RETURN vsRespuesta ;
	
END

END PROCEDURE
;