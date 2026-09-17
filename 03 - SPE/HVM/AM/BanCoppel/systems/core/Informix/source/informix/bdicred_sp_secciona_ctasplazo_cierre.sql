CREATE PROCEDURE "informix".sp_secciona_ctasplazo_cierre(cEmpresa CHAR(3), pCodTipCred CHAR(2))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

--EXECUTE PROCEDURE "informix".sp_cierre_diario_pp('001','05');
   
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
DEFINE iCantRegs      INTEGER;

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
LET iCantRegs       = 0;

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

      UPDATE "informix".sd_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             cod_ret     = cCodRet,
             mensaje     = cMensajeRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

      UPDATE bdinteg:sx_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             codret      = cCodRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

/*	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_pp;
	  END IF;*/

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO '/ifxsif01/macf/sp_secciona_ctasplazo_cierre.out';
 --TRACE ON;

-- *******************************************************
--  VALIDACIONES DE EJECUCIÓN DE PROCESO                 *
-- *******************************************************
/*SELECT a.empresa
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = cEmpresa;

IF NVL(cEmpresa,"") = "" THEN
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;
*/


SELECT fecha_hoy
  INTO dtFechaHoy
  FROM bdicred:sd_fechas
 WHERE empresa = cEmpresa;

--temporal solo para pruebas
--let dtFechaHoy = mdy('01','03','2022');
--temporal solo para pruebas

-- *******************************************************
--  INSERTA PARA EJECUCIÓN DE PROCESO                 *
-- *******************************************************

    SELECT status_proc
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    if (intecontproc='F') then
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCodRet,cMensajeRet;
     end if;

    SELECT status_proc
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
      VALUES ('001','CierrePrest',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;

    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierrePrest',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;

    UPDATE bdinteg:sx_contproc
       SET status_proc='I'
     WHERE fecha= dtFechaHoy
       and proceso ='CierrePrest';

     UPDATE bdicred:sd_contproc
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy
        and proceso ='CierrePrest';

SELECT a.cod_tipcred
  INTO cCodTipCred
  FROM bdicred:sd_tipcred a
 WHERE a.cod_tipcred  = pCodTipCred
   AND a.empresa      = cEmpresa;

IF NVL(cCodTipCred,"") = "" THEN
     LET cCodRet     = "000002";
     LET cMensajeRet = "El tipo de crédito indicado no existe";
     RETURN cCodRet, cMensajeRet;
END IF;


-- *******************************************************
--  SELECCIÓN DE CRÉDITOS PARA PROCESAR                  *
-- *******************************************************

-- INI    REALIZA SEGMENTACION DE CREDITOS
SELECT nvl(valor::integer,0)
  INTO pprocesos
  FROM bdicred:sd_param
 WHERE cod_param = '919';

 
  SELECT mae.num_credito num_credito
    FROM bdicred:sd_maecredcrd mae
    INNER JOIN bdicred:sd_maecredanexocrd mcx on mcx.empresa = mae.empresa AND mcx.num_credito = mae.num_credito AND fecha_proceso = dtFechaHoy
   WHERE mae.empresa = cEmpresa
    AND mae.num_credito>=''
    AND mae.num_producto NOT IN('6011','8600')
    INTO TEMP paso_creds WITH NO LOG;

	create unique index inx_paso_creds on paso_creds(num_credito);
    update statistics medium for table paso_creds;
	
	SELECT count(*) into iCantRegs 
	  FROM paso_creds;
	
	LET pcuenta = ROUND(iCantRegs/pprocesos,0);
 
    LET pcuenta_aux3 = pcuenta;

FOR pcontador = 1 TO  pprocesos
	FOREACH
		
		SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_credito,'')
		  INTO cNumCreditoFin
		  FROM paso_creds
		  ORDER BY num_credito
		  
	END FOREACH
       
	IF pcontador = 1 THEN
		LET prango = '000000000000'||'-'|| trim(nvl(cNumCreditoFin,''));
        LET cNumCreditoIni = cNumCreditoFin;
        LET pparametro = '920';
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
                   
	UPDATE bdicred:sd_param 
       SET valor = prango
	 WHERE empresa = cEmpresa
	   AND cod_param = pparametro;
END FOR;
-- FIN    REALIZA SEGMENTACION DE CREDITOS

-----------------  RANGOS PARA TRIAD
  LET pcuenta = 0;
  LET pcuenta_aux3 = 0;
  LET pprocesos = 0;
  
  SELECT nvl(valor::integer,0)
    INTO pprocesos
    FROM bdicred:sd_param
   WHERE cod_param = '971';

 LET pcuenta = ROUND(iCantRegs/pprocesos,0);
 
 LET pcuenta_aux3 = pcuenta;
 
FOR pcontador = 1 TO  pprocesos
	FOREACH
	
		SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_credito,'')
		  INTO cNumCreditoFin
		  FROM paso_creds
		  ORDER BY num_credito
		
	END FOREACH
       
	IF pcontador = 1 THEN
		LET prango = '000000000000'||'-'|| trim(nvl(cNumCreditoFin,''));
        LET cNumCreditoIni = cNumCreditoFin;
        LET pparametro = '972';
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
                   
	UPDATE bdicred:sd_param 
       SET valor = prango
	 WHERE empresa = cEmpresa
	   AND cod_param = pparametro;
END FOR;

----------------- RANGOS PARA TRIAD


    UPDATE "informix".sd_contproc
       SET status_proc = "F", hora_fin    = CURRENT,
           cod_ret = cCodRet, 	mensaje  = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F", hora_fin = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

/*	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_pp;
	       LET cBanTemp ='N';
	   END IF;*/

	   
RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;