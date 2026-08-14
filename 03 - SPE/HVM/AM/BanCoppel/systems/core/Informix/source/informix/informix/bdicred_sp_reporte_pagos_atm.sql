CREATE PROCEDURE "informix".sp_reporte_pagos_atm()
RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
		    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cRuta 			CHAR(80);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 

DEFINE cSql            	CHAR(2600);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2300);
DEFINE cEncabezado		CHAR(2300);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cRuta 				= "";
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";
LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
	  LET cCodRet = iSqlErr;
	  LET cMensajeRet = iIsamErr;
	  RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/IvanZazueta/sp_reporte_pagos_atm.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;
--SET ISOLATION COMMITTED READ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

--RUTA PARA GENERAR EL ARCHIVO
SELECT valor
INTO cRuta
FROM "informix".sd_param  
WHERE empresa = '001' 
AND cod_param='49';

--SINO EXISTE LA RUTA DEL ARCHIVO	
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '00001';
	LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
	RETURN cCodRet,cMensajeRet;
END IF;	 

--GENERA EL NOMBRE DEL ARCHIVO
LET cNombreArchivo = TRIM('concil_cob_atm_')||TO_CHAR(TODAY - 1,'%y%m%d')|| '.txt';
--LET cNombreArchivo1 = TRIM('SaldosInmateriales_aux')||TO_CHAR(TODAY,'%d%m%y')|| '.txt';
		
--SELECCIONA LOS DATOS QUE FUERON INSERTADOS EN LA TABLA 
LET cConsulta = "SELECT a.fecha, a.cajero, a.hora, a.folio, a.num_credito, a.monto_pagado, " 
				|| "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "'Pago en Efectivo'" || " ELSE " 
                || " a.num_cuenta_tdd " || " END, " 
                || "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "0.00" || " ELSE " 
                || " a.monto_pagado " || " END,0 " 
				|| "FROM bdicred:sd_pagos_reporte_atm a INNER JOIN bdicred:sd_definicion b ON b.num_producto = a.num_producto " 
				|| "WHERE fecha = TODAY - 1 AND a.codigo_retorno_bd = '00000' ORDER BY a.secuencia; " ;

--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo)||' DELIMITER '||'''|'''||' '||TRIM(cConsulta)||' "> '|| TRIM(cRuta) ||'pagos_atm.sql';
SYSTEM TRIM(cSql);

LET cSql = '';
LET cSql = "dbaccess bdicred "|| TRIM(cRuta) || "pagos_atm.sql";
SYSTEM TRIM(cSql);

/*
LET cSql = cSql;
LET cSql = "sed 's/|$SYSTEM cSql;
*/
	
--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSQL = "rm "||TRIM(cRuta)||'pagos_atm.sql';		
SYSTEM TRIM(cSql); 
/*
LET cSQL = '' ;
LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
SYSTEM cSQL;   
*/
RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
;