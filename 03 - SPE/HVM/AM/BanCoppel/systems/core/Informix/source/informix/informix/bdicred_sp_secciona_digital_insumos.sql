CREATE PROCEDURE "informix".sp_secciona_digital_insumos()
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

--EXECUTE PROCEDURE "informix".sp_secciona_digital_insumos();
   
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(125);

DEFINE cBegin         CHAR(1);
DEFINE cFolio         CHAR(16);
DEFINE cNumCredito    CHAR(20);
DEFINE cNumProducto   CHAR(4);
DEFINE cCodTipCred    CHAR(2);
DEFINE pprocesos	  SMALLINT;
DEFINE pcontador      SMALLINT;
DEFINE pcuenta		  INTEGER;
DEFINE pcuenta_aux3   INTEGER;
DEFINE prango         CHAR(50);
DEFINE pparametro	  CHAR(3);
DEFINE dTotalLimite		INTEGER;
DEFINE cNumCreditoIni	CHAR(20);
DEFINE cNumCreditoFin	CHAR(20);
DEFINE dtFechaHoy		DATE;
DEFINE intecontproc 	char(1);
DEFINE credcontproc 	char(1);
DEFINE totalCuentas INTEGER;

LET cBegin          = "N";
LET cFolio         	= "";
LET cNumCredito     = "";
LET cNumProducto   	= "";
LET cCodTipCred     = "";
LET pprocesos		= 0;
LET pcontador		= 0;
LET pcuenta			= 0;
LET pcuenta_aux3 	= 0;
LET prango			= '';
LET pparametro		= '';
LET dTotalLimite	= 0;
LET cCodRet 		= "000000";   
LET cMensajeRet 	= "PROCESO CONCLUIDO";
LET cNumCreditoIni	= "";
LET cNumCreditoFin	= "";
LET dtFechaHoy   		= DATE(1);
LET intecontproc 	= '';
LET credcontproc 	= '';
LET totalCuentas = 0;

SET ISOLATION TO DIRTY READ;
---SET PDQPRIORITY 3; HMD-INCIDENCIA-20220224

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= trim(cNumCreditoIni) || ' - ' || trim(cNumCreditoFin) || ' - ' || pparametro || ' - ' || cErrorInfo;

      IF cBegin = "S" THEN
          ROLLBACK WORK;
       END IF;

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/sp_secciona_ctasplazo_cierre.out';
--TRACE ON;

-- *******************************************************
--  VALIDACIONES DE EJECUCIÃÂN DE PROCESO                 *
-- *******************************************************
/*
SELECT fecha_hoy
  INTO dtFechaHoy
  FROM bdicred:sd_fechas
  WHERE empresa='001';*/
  
  SELECT  pri_dia_mes - 1 units day
	  INTO  dtFechaHoy
	  FROM sd_fechas
	 WHERE empresa='001';

 --LET dtFechaHoy = mdy(09,30,2021);

-- *******************************************************
--  SELECCIÃÂN DE CRÃÂDITOS PARA PROCESAR                  *
-- *******************************************************

-- INI    REALIZA SEGMENTACION DE CREDITOS
SELECT nvl(valor::integer,0)
  INTO pprocesos
  FROM bdicred:sd_param
 WHERE cod_param = '811';

/*  SELECT ROUND(COUNT(*) / pprocesos,0)     
    INTO pcuenta
    FROM sd_maecredcontcrd a
      INNER JOIN sd_maesdoscontcrd b ON (--a.empresa = b.empresa and 
										a.num_credito = b.num_credito and a.fecha = b.fecha) 
      INNER JOIN sd_maecredanexocrd e ON (--a.empresa = e.empresa and
										 a.num_credito = e.num_credito)
      WHERE a.fecha= dtFechaHoy
      AND a.num_producto = '6800'
      and a.num_credito >= '';  */	  
	  
	SELECT COUNT(*)   
    INTO totalCuentas
    FROM sd_maecredcontcrd a
      INNER JOIN sd_maesdoscontcrd b ON (a.fecha = b.fecha --and a.empresa = b.empresa
										and a.num_credito = b.num_credito  ) 
      INNER JOIN sd_maecredanexocrd e ON (--a.empresa = e.empresa and
										 a.num_credito = e.num_credito)
      WHERE a.fecha= dtFechaHoy
      AND a.num_producto = '6800';
     -- and a.num_credito >= '';
	  

	  
LET pcuenta = ROUND (totalCuentas/pprocesos,0);
LET pcuenta_aux3 = pcuenta;   

FOR pcontador = 1 TO  pprocesos
	FOREACH
		SELECT SKIP pcuenta_aux3 FIRST 1 nvl(a.num_credito,'')
		  INTO cNumCreditoFin
		  FROM sd_maecredcontcrd a
      INNER JOIN sd_maesdoscontcrd b ON (a.fecha = b.fecha and --a.empresa = b.empresa and 
										a.num_credito = b.num_credito  ) 
      INNER JOIN sd_maecredanexocrd e ON (--a.empresa = e.empresa and 
										a.num_credito = e.num_credito)
      WHERE a.fecha= dtFechaHoy
        AND a.num_producto = '6800'
      --  and a.num_credito >= '' 
		ORDER BY a.num_credito
	END FOREACH
       
	IF pcontador = 1 THEN
		LET prango = '000000000000'||'-'|| trim(nvl(cNumCreditoFin,'')); 
        LET cNumCreditoIni = cNumCreditoFin;
        LET pparametro = '812';
	ELSE
        IF pcontador = pprocesos THEN
            LET prango = trim(nvl(cNumCreditoIni,''))||'-'|| '999999999999';
        ELSE    
            LET prango = trim(nvl(cNumCreditoIni,''))||'-'|| trim(nvl(cNumCreditoFin,''));
            LET cNumCreditoIni = cNumCreditoFin;
        END IF;

        LET pparametro = (pparametro::integer + 1)::varchar(3); 
	END IF;

	LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;
    
BEGIN;
	UPDATE bdicred:sd_param 
       SET valor = prango
	 WHERE cod_param = pparametro;
COMMIT;
END FOR;


RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;