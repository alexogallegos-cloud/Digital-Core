CREATE PROCEDURE "informix".sp_descarga_previa()

RETURNING 
CHAR(6) AS COD_RET,
CHAR(80) AS MENSAJE_RET;
		  
--DEFINICIÓN DE VARIABLES--		  
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);

DEFINE cRuta				CHAR(1024);
DEFINE cNomarchivoAux		CHAR(100);
DEFINE cNomarchivoAux1		CHAR(1024);
DEFINE cDelimitador		CHAR(1);
DEFINE Ejec_GenArch		CHAR(100);
DEFINE cQuery		CHAR(1024);
DEFINE cSQL		CHAR(1024);
DEFINE cSQL1		CHAR(1024);
DEFINE cSQL2		CHAR(1024);
DEFINE cSQL3		CHAR(1024);
DEFINE iSecuencia	INTEGER;
DEFINE iBandera	INTEGER;




--INICIALIZACIÓN DE VARIABLES--
LET iSqlErr               	= 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= 'PROCESO EXITOSO';
LET cCodRet               	= '000000';

LET cRuta               	= '/informix/';
LET cNomarchivoAux          = 'pruebas.unl';
LET cNomarchivoAux1          = 'pruebas.unl';
LET cDelimitador          = '|';
LET Ejec_GenArch          = '';
LET cQuery          = '';
LET cSQL           = '';
LET cSQL1          = '';
LET cSQL2          = '';
LET cSQL3          = '';
LET iSecuencia 	   = 0;
LET iBandera 	   = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;		 
		  RETURN cCodRet,  NVL(cErrorInfo,'');
		END IF;
	END EXCEPTION;
		  
	--SET DEBUG FILE TO "/informix/jesus/sp_descarga_previa.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
		
		
		SELECT COUNT(generar) INTO iBandera FROM "informix".sd_descarga_datos WHERE  generar = 0 AND   activo = 1;		
		
		IF iBandera > 0 THEN			
			TRUNCATE TABLE "informix".sd_maecred_descarga;
			
			INSERT INTO sd_maecred_descarga 
			SELECT empresa,numcte,num_credito FROM bdicred:"informix".sd_maecred 
			WHERE empresa = '001' AND sucursal = '0002';			
				
		END IF;	
		

		---maecred                 
		
		FOREACH WITH HOLD
			SELECT query,nombre_archivo,ruta_archivo,secuencia
				INTO cQuery,cNomarchivoAux,cRuta,iSecuencia
			FROM "informix".sd_descarga_datos
			WHERE empresa ='001'
			AND  activo = 1
			AND generar = 1
			ORDER BY secuencia			
					
			
			LET cNomarchivoAux =TRIM(cNomarchivoAux)||month(TODAY)||"20"||".unl";
			LET cQuery =" "||cQuery;
			LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomarchivoAux); 
			LET cSQL2 = cQuery;
			LET cSQL3 = '">'||TRIM(cRuta)||'Ejec_GenArch.sql';
			
			LET cSql = RTRIM(cSQL1)||RTRIM(cSQL2)||RTRIM(cSQL3);
			SYSTEM TRIM(cSql);
			LET cSql = '';
			LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'Ejec_GenArch.sql';
			SYSTEM TRIM(cSql);
				
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejec_GenArch.sql' ;
			SYSTEM cSQL;
			LET cSQL = '' ;
			
			UPDATE  "informix".sd_descarga_datos
				SET generar =0
			WHERE empresa ='001'
			AND  activo = 1
			AND generar = 1
			AND secuencia=iSecuencia ;	
	
			
		END FOREACH;
		
		SELECT COUNT(generar) INTO iBandera FROM "informix".sd_descarga_datos WHERE  generar = 1 AND   activo = 1;		
		IF iBandera = 0 THEN			
			UPDATE  "informix".sd_descarga_datos SET generar = 1 WHERE activo = 1;				
		END IF;
	
	
	RETURN cCodRet,  NVL(cErrorInfo,'');
END
END PROCEDURE;