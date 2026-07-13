CREATE PROCEDURE "informix".sp_totalcte_correo()
RETURNING 	VARCHAR(6) AS cCodRet,
			VARCHAR(40) AS cMensaje;
			--VARCHAR(40) AS cRegistros;
		  
/*DEFINICION DE VARIABLES */

DEFINE 	cCodRet      	  VARCHAR(6);
DEFINE 	cCodRet2      	  VARCHAR(6);
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
DEFINE  vNomCorr		  VARCHAR(104);
DEFINE  vNomINC		      VARCHAR(104);
DEFINE  vFechaNacCor	  DATE;
DEFINE  vFechaNacINC	  DATE;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet				= 0;
LET cCodRet2			= 0;
LET cMensaje			= '';
LET cRegistros			= '';
LET vsNombreArchivo		= '';
LET vsNombreArchivo2	= '';
LET cSQL				= '';
LET cSQL1				= '';
LET cSQL2				= '';
LET cSQL3				= '';	  
LET iCont				= 0;	  
LET iSqlErr				= 0;
LET dFecha				= DATE(0);
LET vNumcte				= '';
LET vNumcte2			= '';
LET vNomCorr			= '';
LET vNomINC				= '';
LET vFechaNacCor		= DATE(0);
LET vFechaNacINC		= DATE(0);

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
		
			RETURN cCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/emm/sp_totalcte_correo.out";
	--TRACE ON;
	--Nombre del archivo
	--LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_TOTALCTE_CORREO.csv';
	--LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_totalcte_correo.sql';
	--SYSTEM cSQL;

	SELECT count(*) 
	INTO iCont
	FROM bdinteg:'informix'.si_correos 
	WHERE  status_correo ='A' 
	AND fecha_hora::DATETIME YEAR TO FRACTION::DATE < TODAY;
	
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','MON_ALERT','CTES_CORREO','000000000','','','1','','','','',iCont,'','','','','','kjbojorquez@bancoppel.com','',1,0,0,0,0,'','')
	INTO cCodRet2;
	
	IF cCodRet2 = '00000' THEN		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';		
		LET cCodRet = '000000';
		
	ELSE
	LET cMensaje  = 'SE PRESENTO UN PROBLEMA AL GENERAR EL REPORTE';		
		LET cCodRet = '000000';
	END IF;

	RETURN cCodRet,cMensaje;
END;
END PROCEDURE;