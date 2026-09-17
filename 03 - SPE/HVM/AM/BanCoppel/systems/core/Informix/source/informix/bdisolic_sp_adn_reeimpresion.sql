CREATE PROCEDURE "informix".sp_adn_reeimpresion(pEmpresa CHAR(3), pSolicitud CHAR (20))
RETURNING CHAR(5)   		AS Codret,
			CHAR(9) 		AS NumCte,
			CHAR(100) 		AS NOMBRE,
			CHAR(20)  		AS NumCredito,
			CHAR(2)   		AS diasDeCorte,
			CHAR(12)  		AS cuenta,			
			DECIMAL (16,2)	AS MontoTotal,
			CHAR(2)   		AS Plazo,		
			CHAR(12)  		AS Fecha,
			CHAR(2) 		AS divisa,
			CHAR(13)        AS RFC;
		 

DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cNumCte 	CHAR(20);
DEFINE cNombre   		CHAR(100);
DEFINE cNumsol 	CHAR(20);
DEFINE iDiaCorte 	SMALLINT;
DEFINE cCuenta	CHAR(12);
DEFINE dLinea	MONEY(14,2);
DEFINE cPeriodicidad CHAR(1);
DEFINE dtFecha    DATE;
DEFINE cDivisa CHAR(2);
DEFINE cNumProd CHAR(4);
DEFINE cRFC CHAR(13);


LET cCodRet			= "00000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cNumCte 	= "";
LET cNombre   		= "";
LET cNumsol 	= "";
LET iDiaCorte 	=0;
LET cCuenta	= "";
LET dLinea	=0;
LET cPeriodicidad = "";
LET dtFecha   = DATE(1);
LET cDivisa = "";
LET cNumProd = "";
LET cRFC = "";

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN cCodRet ,cNumCte ,cNombre , pSolicitud,iDiaCorte, cCuenta,dLinea, cPeriodicidad,dtFecha,cDivisa,cRFC;
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/SMS/sp_adn_reeimpresion.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR  TRIM(NVL(pSolicitud,"")) = ""  THEN
		LET cCodRet  = "00001";
		RETURN cCodRet ,cNumCte ,cNombre , pSolicitud,iDiaCorte, cCuenta,dLinea, cPeriodicidad,dtFecha,cDivisa,cRFC;
	END IF;

	IF NOT EXISTS ( SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_credito = pSolicitud) THEN
			LET cCodret	='00120'; -- EL NÚMERO DE SOLICITUD NO EXISTE
			RETURN cCodRet ,cNumCte ,cNombre , pSolicitud,iDiaCorte, cCuenta,dLinea, cPeriodicidad,dtFecha,cDivisa,cRFC;
	END IF
	
	
		--SE OBTIENE LA FECHA  DEL DIA DEL REPORTE
		SELECT fecha_hoy 
		INTO dtFecha 
		FROM bdinteg:"informix".si_fechas;
				  
			
		SELECT numcte ,divisa ,num_producto
		INTO cNumCte,cDivisa , cNumProd
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = pSolicitud;

		SELECT dia_cuota
		INTO iDiaCorte
		FROM bdicred:"informix".sd_definicion
		WHERE num_producto = cNumProd;
		
		--SE OBTIENE EL DOMICILIO DEL CLIENTE
		SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre ,rfc
			INTO cNombre, cRFC
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = cNumCte;	

		SELECT cuenta_nomina, DECODE(frecuencia_pgo,'1','M','2','Q','3','S','M') , linea
		INTO cCuenta, cPeriodicidad , dLinea
		FROM  "informix".ss_adn_solicitudcuenta
		WHERE  num_solicitud = pSolicitud;
		
		RETURN cCodRet ,cNumCte ,cNombre , pSolicitud,iDiaCorte, cCuenta,dLinea, cPeriodicidad,dtFecha,cDivisa,cRFC;
 

END
END PROCEDURE
