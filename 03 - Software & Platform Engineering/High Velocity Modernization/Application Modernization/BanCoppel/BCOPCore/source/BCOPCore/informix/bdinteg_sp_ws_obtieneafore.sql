CREATE PROCEDURE "informix".sp_ws_obtieneafore(pcLimit INTEGER)

RETURNING 	CHAR(4) AS cCodRet,CHAR(8) AS cEjecutivo,CHAR(4) AS cSucursal,CHAR(18) AS cCurp,
			CHAR(26) AS cApell_paterno,CHAR(26) AS cApell_materno,CHAR(26) AS cNombre1,
			CHAR (26) AS cNombre2,CHAR(10) AS cFecha,CHAR(2) AS cLugar_nac,CHAR(1) AS cSexo,
			CHAR(20) AS cNumcte;
			
			/*
				SPS UTILIZADO PARA LA OBTENCION DE INFORMACIÃ?N EN DE LA TABLA MOMENTANEA
				si_ws_mensajeafore Y SER ACTUALIZADOS AL MISMO TIEMPO.
				SU FINALIDAD ES ENVIAR DICHOS DATOS A UN WEBSERVICES DE AFORE
			*/
			
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		  	INTEGER;
DEFINE cCodRet 		  	CHAR(5);
DEFINE cNumcte			CHAR(20);
DEFINE cEjecutivo		CHAR(8);
DEFINE cSucursal  		CHAR(4);
DEFINE cCurp			CHAR(20);
DEFINE cApell_paterno	CHAR(26);
DEFINE cApell_materno	CHAR(26);
DEFINE cNombre1			CHAR(26);	
DEFINE cNombre2			CHAR(26);
DEFINE dFecha_nac		DATE;
DEFINE cLugar_nac		CHAR(2);
DEFINE cSexo			CHAR(1);
DEFINE cFecha			CHAR(10);

			
--INICIALIZACION DE VARIABLES
LET iSqlErr 		= 0;
LET cCodRet 		= '0000';	
LET cEjecutivo		= '';
LET cSucursal		= '';	
LET cCurp			= '';	
LET cApell_paterno	= '';
LET cApell_materno	= '';
LET cNombre1		= '';
LET cNombre2		= '';
LET dFecha_nac		= CURRENT;
LET cLugar_nac		= '';
LET	cSexo			= '';
LET cNumcte			= '';
LET cFecha 			= '';
			
			
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','','','','','';
		END IF;
	END EXCEPTION;



	--SET DEBUG FILE TO '/informix/mijail/sp_ws_obtieneafore.out';
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH sal_cursor WITH HOLD FOR
	
			SELECT first pcLimit numcte,ejecutivo,sucursal,curp,apell_paterno,apell_materno,nombre1,nombre2,fecha_nac,lugar_nac,sexo
				INTO cNumcte,cEjecutivo,cSucursal,cCurp,cApell_paterno,cApell_materno,cNombre1,cNombre2,dFecha_nac,cLugar_nac,cSexo
			FROM "informix".si_ws_mensajeafore
			WHERE notificado=0 AND 
				  fecha_insert > CURRENT - 1 units MINUTE and ejecutivo<>''
				  --fecha_insert > TODAY
				  --sucursal IN ('0239','0490','0007','0002') AND
				  
			
			
			--ACTUALIZACION DE CAMPOS NOTIFICADO=1 Y FECHA_NOTIFICA=CURRENT	
			UPDATE "informix".si_ws_mensajeafore SET fecha_notifica = CURRENT , notificado = 1  WHERE CURRENT OF sal_cursor;
		
		LET cFecha = (YEAR(dFecha_nac)||'-'||LPAD(MONTH(dFecha_nac),2,'0'))||'-'||LPAD(DAY(dFecha_nac),2,'0');
		
		RETURN  cCodRet,cEjecutivo,cSucursal, cCurp,cApell_paterno, cApell_materno, cNombre1,cNombre2,cFecha,cLugar_nac,cSexo,cNumcte WITH RESUME;
	
	END FOREACH;

END;
END PROCEDURE;