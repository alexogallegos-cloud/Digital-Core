CREATE PROCEDURE "informix".sp_generar_reporte_sos()
RETURNING 	VARCHAR(6) AS cCodRet,
			VARCHAR(40) AS cMensaje;
			--VARCHAR(40) AS cRegistros;
			
		  
/*DEFINICION DE VARIABLES */

DEFINE 	cCodRet      	  VARCHAR(6);
DEFINE 	cMensaje      	  VARCHAR(40);
DEFINE 	cRegistros     	  VARCHAR(40);
DEFINE 	vsNombreArchivo   VARCHAR(50);
DEFINE 	vsNombreArchivo2  VARCHAR(50);
DEFINE  cSQL			  VARCHAR(250);
DEFINE  cSQL1			  LVARCHAR(500);
DEFINE  cSQL2			  LVARCHAR(500);
DEFINE  cSQL3			  LVARCHAR(500);
DEFINE  iCont			  INTEGER;	
DEFINE  iSqlErr			  INTEGER;
DEFINE	dFecha		      DATE;
DEFINE  vNumcte		      VARCHAR(20);
DEFINE  vNumcte2		  VARCHAR(20);
DEFINE  vNomCorr		      VARCHAR(104);
DEFINE  vNomINC		      VARCHAR(104);
DEFINE  vFechaNacCor	  DATE;
DEFINE  vFechaNacINC	  DATE;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet   = 0;
LET cMensaje   = '';
LET cRegistros = '';
LET vsNombreArchivo = '';
LET vsNombreArchivo2 = '';
LET cSQL	    = '';
LET cSQL1	    = '';
LET cSQL2	    = '';
LET cSQL3	    = '';	  
LET iCont	    = 0;	  
LET iSqlErr     = 0;
LET dFecha = DATE(0);
LET vNumcte	= '';
LET vNumcte2	= '';
LET vNomCorr	= '';
LET vNomINC	= '';
LET vFechaNacCor = DATE(0);
LET vFechaNacINC = DATE(0);




BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
		
			RETURN cCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	

	
	
	--Nombre del archivo
	LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
	LET vsNombreArchivo2 = '/RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
						

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_correcciones_sos.sql';
		SYSTEM cSQL;

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_fusion_sos.sql';
		SYSTEM cSQL;
		
		LET cSQL2='zip /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
		SYSTEM cSQL2;
		
		LET cSQL3='zip /RESPALDOSNEW/REPORTE_FUSION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
		SYSTEM cSQL3;
		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
		LET cCodRet = '000000';

	RETURN cCodRet,cMensaje;
END;
END PROCEDURE;