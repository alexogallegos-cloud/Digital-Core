CREATE PROCEDURE "informix".sp_obtregmonitorconciliacionman
(
psArchivoOrigen CHAR(3),
psFechaInicial DateTime  YEAR TO fraction(5), 
psFechaFinal DateTime  YEAR TO fraction(5)
)

RETURNING INTEGER AS X, CHAR(3) AS ArchivoOrigen, DATE AS FechaConciliacion, CHAR(8) AS Usuario, CHAR(1) AS Integridad, CHAR(1) AS CargarArchivo,
		  CHAR(1) AS Conciliacion, CHAR(1) AS ExportarRegCentral, CHAR(1) AS ConfigurarCentral, CHAR(1) AS AplicarSaldos;
		  
		  
--****************************************************************************************************
-- DESCRIPCION: Obtiene informacion de la tabla monitor_conciliacionman
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 29/10/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--***************************************************************************************************

		  
DEFINE cCodRet CHAR(3);
DEFINE viLlave INTEGER ;
DEFINE vsArchivoO CHAR(3);
DEFINE vdFechaCon DateTime  YEAR TO fraction(5);
DEFINE vsUsuario CHAR(8) ;
DEFINE vsIntegro CHAR(1) ;
DEFINE vsCargarArchivo CHAR(1) ;
DEFINE vsConciliacion CHAR(1);
DEFINE vsExpRegCent CHAR(1) ;
DEFINE vsConfigCen CHAR(1) ;
DEFINE vsAplicarSal CHAR(1) ;
DEFINE visqlerr INTEGER ;

LET viLlave  = 0;
LET vsArchivoO = "";
LET vdFechaCon = CURRENT ;
LET vsUsuario = '';
LET vsIntegro = "" ;
LET vsCargarArchivo = "" ;
LET vsConciliacion = "" ;
LET vsExpRegCent = "" ;
LET vsConfigCen = "" ;
LET vsAplicarSal = "" ;
LET cCodRet = "000";
LET visqlerr = 0 ;

--set debug file to "/tmp/sp_ObtRegMonitorConciliacion.out";
--Trace on;

BEGIN


ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF visqlerr <> 0 THEN             

    RETURN visqlerr, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent,
	vsConfigCen, vsAplicarSal; 

    END IF ; 
END EXCEPTION ;

IF(psFechaInicial = "") OR (psFechaInicial is NULL) THEN
    LET visqlerr = 1 ;
	
    RETURN visqlerr, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent,
		   vsConfigCen, vsAplicarSal;
END IF ;

IF (psFechaFinal = "") OR (psFechaFinal IS NULL) THEN
    LET visqlerr = 2;
	
    RETURN visqlerr, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent,
		   vsConfigCen, vsAplicarSal;
		   
END IF ;


IF (psArchivoOrigen = '')  THEN
        

        SET ISOLATION TO DIRTY READ ;
        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Integridad, Cargar_Archivo, Conciliacion, Exportar_Registros_A_Central,                     
			Configurar_Central, Aplicar_Saldos 
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent, vsConfigCen, vsAplicarSal
            FROM monitor_conciliacionman WHERE FechaConciliacion >=  pdFechaInicial  AND FechaConciliacion <= pdFechaFinal
			
		    RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent, vsConfigCen, vsAplicarSal  WITH RESUME ;

        END ForEach
ELSE
        

        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Integridad, Cargar_Archivo, Conciliacion, Exportar_Registros_A_Central,                     
			Configurar_Central, Aplicar_Saldos 
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent, vsConfigCen, vsAplicarSal
            FROM monitor_conciliacionman WHERE ArchivoOrigen = psArchivoOrigen AND FechaConciliacion >=  pdFechaInicial  AND FechaConciliacion <= pdFechaFinal
            
            RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario, vsIntegro, vsCargarArchivo, vsConciliacion, vsExpRegCent, vsConfigCen, vsAplicarSal  WITH RESUME ;

        END ForEach

END IF ;

END
END PROCEDURE;