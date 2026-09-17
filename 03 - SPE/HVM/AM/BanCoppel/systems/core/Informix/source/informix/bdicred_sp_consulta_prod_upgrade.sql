CREATE PROCEDURE "informix".sp_consulta_prod_upgrade(pEmpresa CHAR(3), pSiglaProd CHAR(2) ,pSiglaProdUp CHAR(2))
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno,
          VARCHAR(100,1)  AS nombre_producto,
		  CHAR(4)         AS numero_producto;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se consultó con exito.';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, NVL(cNomProducto,''), NVL(cNumProducto,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_consulta_prod_upgrade';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pSiglaProd,'')) = ''  THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet, NVL(cNomProducto,''), NVL(cNumProducto,'');
END IF;

FOREACH
	SELECT b.producto_nuevo
	INTO cNumProducto
	FROM "informix".sd_definicion a,
	"informix".sd_cambio_producto b
	WHERE a.empresa = '001'
    AND a.empresa=b.empresa
	AND a.num_producto = b.producto_actual
	AND a.siglas = pSiglaProd
	AND substr(b.producto_nuevo,1,2)  = CASE WHEN NVL(pSiglaProdUp,'') <> '' THEN pSiglaProdUp ELSE substr(b.producto_nuevo,1,2) END

	SELECT nombre_prod
	INTO cNomProducto
	FROM "informix".sd_definicion
	WHERE empresa = '001'
	AND num_producto = cNumProducto;

	RETURN cCodRet, cMensajeRet, NVL(cNomProducto,''), NVL(cNumProducto,'') WITH RESUME;
END FOREACH;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
   LET cCodRet= '000002';
   LET cMensajeRet= 'No hay datos con la información indicada';
   RETURN cCodRet, cMensajeRet, NVL(cNomProducto,''), NVL(cNumProducto,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener los productos permitidos para realizar el upgrade de un producto ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_prod_upgrade(pEmpresa CHAR(3),
pFechaIni DATE ,
pFechaFin DATE ,
pTipo CHAR(1) ,
pStatus CHAR(1) ,
pArchivo CHAR(100)
)
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(100,1) AS mensaje_retorno,
		  VARCHAR(100,1) AS nombre_archivo,
          VARCHAR(20,1)  AS cNumCredito,
          VARCHAR(10,1)  AS Tipo_Tarjeta,
          CHAR(2)		 AS miembro,
		  DATE 			 AS fecha,
          CHAR(15) 		 AS resultado;




DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);
DEFINE cNombre       CHAR(100);
DEFINE cnombre_embozado CHAR(21);
DEFINE cNumCredito   CHAR(20);
DEFINE cTipo_Tarjeta  CHAR(10);
DEFINE cmiembro       CHAR(2);
DEFINE cfecha		  DATE;
DEFINE cresultado     CHAR(15);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET cNombre  = '';
LET cnombre_embozado = '';
LET cNumCredito = '';
LET cTipo_Tarjeta = '';
LET cmiembro = '';
LET cfecha = date(1);
LET cresultado = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet,"","","","","","";
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/Malena/sp_graba_prod_upgrade';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = ''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet,"","","","","","";
END IF;

IF  pTipo = '1' then

	IF NVL(pArchivo,'') ='' THEN
		FOREACH WITH HOLD


			SELECT distinct (nombre_archivo)
			INTO cNombre
			FROM "informix".sd_credito_upgrade
			WHERE empresa = pEmpresa
			AND fecha_insert::DATE BETWEEN pFechaIni and pFechaFin


			RETURN cCodRet, cMensajeRet,cNombre,"","","","","" WITH resume;

		END FOREACH;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			   LET cCodRet= '000002';
			   LET cMensajeRet= 'No existen archivos cargados en el periodo especificado';
			      RETURN cCodRet, cMensajeRet,"","","","","","";
		END IF;
	ELSE

		FOREACH WITH HOLD

			SELECT num_credito,DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),nombre_embosado,miembro,fecha_insert,DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cTipo_Tarjeta,cnombre_embozado,cmiembro,cfecha,cresultado
			FROM "informix".sd_credito_upgrade
			WHERE empresa = pEmpresa
			AND fecha_insert::DATE BETWEEN pFechaIni and pFechaFin
			AND nombre_archivo = pArchivo

			RETURN cCodRet, cMensajeRet,cnombre_embozado,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			   LET cCodRet= '000002';
			   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
			   RETURN cCodRet, cMensajeRet,"","","","","","";
		END IF;
	END IF;
ELIF pTipo = '2' THEN

		FOREACH WITH HOLD

			SELECT num_credito,DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),nombre_embosado,miembro,fecha_insert,DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cTipo_Tarjeta,cnombre_embozado,cmiembro,cfecha,cresultado
			FROM "informix".sd_credito_upgrade
			WHERE empresa = pEmpresa
			AND fecha_insert::DATE BETWEEN pFechaIni and pFechaFin
			AND Resultado = pStatus

			RETURN cCodRet, cMensajeRet,cnombre_embozado,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		   LET cCodRet= '000002';
		   LET cMensajeRet= 'No existe información con este estatus en el periodo seleccionado';
		      RETURN cCodRet, cMensajeRet,"","","","","","";
		END IF;

END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener información de reportería para realizar el upgrade de un producto ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_nom_embozado_upgrade(
			 P_EMPRESA       VARCHAR(3),
                         P_NUMCTE 	VARCHAR(20))

RETURNING CHAR(6) AS cod_ret,
	CHAR(26) AS Nombre_1, -- Primer nombre del cte
	CHAR(26) AS Nombre_2, -- Segundo nombre del cte
	CHAR(26) AS Apellido_Pat,--Primer apellido del cte
	CHAR(26) AS Apellido_Mat,--Segundo Apellido del cte
	CHAR(1) AS Nom1_ini,     --Inicial del primer Nombre
	CHAR(1) AS Nom2_ini,     --Inicial del Segundo Nombre
	CHAR(1) AS ApellPat_ini, --Inicial del Apellido Paterno
	CHAR(1) AS ApellMat_ini; --Inicial del Apellido Materno


--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************

DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE ccodret          CHAR(6);
DEFINE cMensaje			CHAR(80);
DEFINE cNumCte          CHAR(20);
DEFINE cNombre1 		CHAR(26); -- Primer nombre del cte
DEFINE cNombre2 		CHAR(26); -- Segundo nombre del cte
DEFINE capell_paterno 	CHAR(26);
DEFINE capell_materno 	CHAR(26);
DEFINE cNom1_ini 		CHAR(1);     --Inicial del primer Nombre
DEFINE cNom2_ini 		CHAR(1);     --Inicial del Segundo Nombre
DEFINE cApellPat_ini 	CHAR(1); --Inicial del Apellido Paterno
DEFINE cApellMat_ini 	CHAR(1); --Inicial del Apellido Materno


--Set debug file to  '/informix/Malena/sp_nom_embozado_upgrade.out';
--trace on;

--***********************
--INICIALIZA VARIABLE
--***********************

LET ccodret      	= '000000';
LET cMensaje    	= 'PROCESO EXITOSO';
LET cNumCte  		= P_NUMCTE;
LET cNombre1 		= ""; -- Primer nombre del cte
LET cNombre2 		= ""; -- Segundo nombre del cte
LET capell_paterno	= ""; -- Primer apellido del cte
LET capell_materno 	= ""; -- Segundo Apellido del cte
LET cNom1_ini 		= ""; -- Inicial del primer Nombre
LET cNom2_ini 		= ""; -- Inicial del Segundo Nombre
LET cApellPat_ini 	= ""; -- Inicial del Apellido Paterno
LET cApellMat_ini 	= ""; -- Inicial del Apellido Materno


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET ccodret    = SQL_ERR;
         LET cMensaje  = ERROR_INFO;

         RETURN ccodret,NVL(cNombre1,''),NVL(cNombre2,''),NVL(capell_paterno,''),NVL(capell_materno,''),NVL(cNom1_ini,''),NVL(cNom2_ini,''),NVL(cApellPat_ini,''),NVL(cApellMat_ini,'');
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT TRIM(nvl(nombre1,'')),
	TRIM(nvl(nombre2,'')),
	TRIM(nvl(apell_paterno,'')),
	TRIM(nvl(apell_materno,'')),
    SUBSTR (TRIM(NVL(nombre1,'')),1,1),
	SUBSTR (TRIM(NVL(nombre2,'')),1,1),
	SUBSTR (TRIM(NVL(apell_paterno,'')),1,1),
	SUBSTR (TRIM(NVL(apell_materno,'')),1,1)
	INTO cNombre1,cNombre2,capell_paterno,capell_materno,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini
	FROM bdinteg:"informix".si_cliente
	WHERE empresa= P_EMPRESA
	AND numcte = cNumCte;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet= '000001';
	   RETURN cCodRet,NVL(cNombre1,''),NVL(cNombre2,''),NVL(capell_paterno,''),NVL(capell_materno,''),NVL(cNom1_ini,''),NVL(cNom2_ini,''),NVL(cApellPat_ini,''),NVL(cApellMat_ini,'');
	END IF;

    RETURN cCodRet,NVL(cNombre1,''),NVL(cNombre2,''),NVL(capell_paterno,''),NVL(capell_materno,''),NVL(cNom1_ini,''),NVL(cNom2_ini,''),NVL(cApellPat_ini,''),NVL(cApellMat_ini,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para consultar los datos del nombre del cliente y sus iniciales para la selección del nombre de embozado',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 07/10/2016',
'BD    : BDICRED';

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