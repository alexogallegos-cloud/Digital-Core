CREATE PROCEDURE "informix".sp_consulta_dom_upgrade(pTpoEjec CHAR(1))

RETURNING CHAR(6) AS cod_ret,
		  CHAR(4) AS TipoDir,
		  CHAR(40) AS DescTipoDir;

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************

DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE ccodret          CHAR(6);
DEFINE cMensaje			CHAR(80);
DEFINE cTipoDir 		CHAR(4);
DEFINE cDescTipoDir 	CHAR(40);

--Set debug file to  '/informix/Malena/sp_consulta_dom_upgrade.out';
--trace on;

--***********************
--INICIALIZA VARIABLE
--***********************

LET ccodret      	= '000000';
LET cTipoDir 		= ""; -- Tipo de domicilio
LET cDescTipoDir 	= ""; -- Descripción de tipo de domicilio

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET cCodRet    = SQL_ERR;
         LET cMensaje  = ERROR_INFO;

         RETURN cCodRet,cTipoDir,cDescTipoDir;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pTpoEjec="1" THEN
		FOREACH WITH HOLD
			SELECT tipo_dir,desc_tipo_dir
			INTO cTipoDir,cDescTipoDir
			FROM bdinteg:"informix".si_tipo_dir_upg
			WHERE empresa='001'

			RETURN cCodRet, NVL(cTipoDir,''), NVL(cDescTipoDir,'') WITH RESUME;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		   LET cCodRet= '000001'; --No hay datos con la información indicada
		   RETURN cCodRet,cTipoDir,cDescTipoDir;
		END IF;
	ELIF pTpoEjec="2" THEN
		FOREACH WITH HOLD
			SELECT sucursal,nombre
			INTO cTipoDir,cDescTipoDir
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa='001'

			RETURN cCodRet, NVL(cTipoDir,''), NVL(cDescTipoDir,'') WITH RESUME;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		   LET cCodRet= '000002'; --No hay datos en catalogo de Sucursales
		   RETURN cCodRet,cTipoDir,cDescTipoDir;
		END IF;
	END IF;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener los tipo de domicilios registrados en el catalogo creado para upgrade',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 10/10/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_status_upgrade()
RETURNING CHAR(6)         AS codigo_retorno,
		  INTEGER 		 AS numparametro,
          VARCHAR(100,1)  AS estatus;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE ccStatus   VARCHAR(100,1);
DEFINE iNumParametro INTEGER;


LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET ccStatus   	  = '';
LET iNumParametro = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      RETURN cCodRet,NVL(iNumParametro,0), NVL(ccStatus,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_rep_status_upgrade';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

FOREACH
	SELECT num_parametro,valor_alfabetico
	INTO iNumParametro,ccStatus
	FROM "informix".sd_param_campania
	WHERE empresa = '001'
    AND tipo_campania='68'
	AND grupo_parametro='REPESTATUS'

	RETURN cCodRet,NVL(iNumParametro,0),NVL(ccStatus,'') WITH RESUME;
END FOREACH;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
   LET cCodRet= '000001';
   RETURN cCodRet,NVL(iNumParametro,0),NVL(ccStatus,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener la información que alimentará el combo de estatus',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/10/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_mueve_factura(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE pfecha       date;    
    DEFINE vrowid       integer;
    DEFINE vsSQL1		CHAR(100);
    DEFINE wBandera     CHAR(01);
    DEFINE cSql         CHAR(200);
	DEFINE vnumcredito  CHAR(20);
    LET credcontproc    = "";
    LET intecontproc    = "";
    LET pfecha          = DATE(1);
    LET vsSQL1	        = "";
    LET wBandera        = "";
    LET cSql = '';
	LET vnumcredito    = "";
  

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid       = 0;
--  SET DEBUG FILE TO "/pisa/leo/sp_mueve_factura.out";
--  TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

    SELECT fecha_hoy  
    INTO pfecha
    FROM bdicred:sd_fechas;

    SELECT NVL(status_proc,'')
      INTO wBandera
      FROM bdinteg:sx_contproc
     WHERE fecha= pfecha 
       AND proceso ='Trasl_Dia';

       IF wBandera = '' OR wBandera is NULL THEN
          LET wBandera = '';
       END IF;

    WHILE wBandera <> 'F'

        LET cSql = '';
        LET wBandera = '';
        LET cSQL = 'sleep 180';
        SYSTEM cSql;

        SELECT NVL(status_proc,'')
          INTO wBandera
          FROM bdinteg:sx_contproc
         WHERE fecha= pfecha 
           AND proceso = 'Trasl_Dia';

           IF wBandera = '' OR wBandera is NULL THEN
              LET wBandera = '';
           END IF;

    END WHILE;


            SELECT num_credito
              FROM bdicred:sd_movdia
             WHERE empresa = pEmpresa
               AND fecha_mov = pfecha
             GROUP BY num_credito
              INTO temp paso_factura WITH NO LOG;

              CREATE UNIQUE INDEX inx_paso_factura ON paso_factura(num_credito);
              UPDATE STATISTICS MEDIUM FOR TABLE paso_factura;

           FOREACH WITH HOLD 
                SELECT num_credito
                 INTO vnumcredito
                 FROM paso_factura

                   BEGIN WORK;
                      INSERT INTO bdicred:sd_movhis
                      SELECT * FROM bdicred:sd_movdia 
                       WHERE fecha_mov = pfecha
                         AND num_credito = vnumcredito;

                      DELETE FROM bdicred:sd_movdia                
                       WHERE fecha_mov = pfecha
                         AND num_credito = vnumcredito;
                   COMMIT WORK;

           END FOREACH;

  END;

 RETURN cCodRet,cMensaje;

END PROCEDURE;