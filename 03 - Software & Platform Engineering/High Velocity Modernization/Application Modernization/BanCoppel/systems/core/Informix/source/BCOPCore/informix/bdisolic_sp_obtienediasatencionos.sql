CREATE PROCEDURE "informix".sp_obtienediasatencionos(pEmpresa CHAR(3), pTpConsulta CHAR(2), pFiltro VARCHAR(4), pProducto CHAR(4), pFechaIni DATE, pFechaFin DATE ) 

RETURNING
	CHAR(6)         AS CodRet,
	CHAR(60)		AS DiasRespuesta,
	INTEGER			AS CantidadOs,
	DECIMAL(18,2)	AS Porcentaje;
	


-- DECLARACION DE VARIABLES
DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cDescripcion     CHAR(60);

DEFINE cEmpresa			CHAR(3);
DEFINE i12D				INTEGER;
DEFINE i34D				INTEGER;
DEFINE i56D				INTEGER;
DEFINE i78D				INTEGER;
DEFINE i910D			INTEGER;
DEFINE iM10D			INTEGER;
DEFINE iTotalOS			INTEGER;
DEFINE dPorcPeriodo		DECIMAL(18,2);
DEFINE dSumPorcOS		DECIMAL(18,2);
DEFINE cSucursal		CHAR(4);
DEFINE cCiudad			CHAR(4);
DEFINE cEstado			CHAR(4);
DEFINE iRegion			INTEGER;


-- INICIALIZACION
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '000000';
LET cDescripcion        = '';

LET cEmpresa	        = '';
LET i12D				= 0; 
LET i34D				= 0;
LET i56D				= 0;
LET i78D				= 0;
LET i910D				= 0;
LET iM10D				= 0;
LET iTotalOS			= 0;
LET dPorcPeriodo		= 0;
LET dSumPorcOS			= 0;
LET cSucursal			= '';
LET cCiudad				= '';
LET cEstado				= '';
LET iRegion 			= 0;


BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cDescripcion= cErrorInfo;
		  
		  -- ELIMINAMOS LA TABLA TEMPORAL.
		  DROP TABLE ss_Dias_AtencionOS;
		  
		  RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	   END IF;
	END EXCEPTION;
	 
  --SET DEBUG FILE TO "/respaldosbd/jasmin/sp_constelefonofechaact.out"; 
  --TRACE ON;
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	 
	IF NVL(pEmpresa,'') = '' THEN
	   LET cCodRet     = '000001';
	   LET cDescripcion = 'Es necesario indicar la empresa para ejecutar el proceso';
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	
	SELECT empresa
	INTO cEmpresa
	FROM bdinteg:"informix".si_empresas
	WHERE empresa = pEmpresa;
	
	IF NVL(cEmpresa,'') = '' THEN
	   LET cCodRet     = '000002';
	   LET cDescripcion = 'La empresa indicada no es valida';
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	
	IF NVL(pTpConsulta,"") = "" THEN
		LET cCodRet = "000003";
		LET cDescripcion = "Es necesario indicar el tipo de consulta a realizar";
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	
	IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
		LET cCodRet = "000004";
		LET cDescripcion = "Es necesario indicar al menos una fecha";
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;

	IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
		LET cCodRet = "000005";
		LET cDescripcion = "La fecha inicial no debe ser mayor a la fecha final";
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	
	IF pTpConsulta NOT IN ('01','02','03','04') THEN
		LET cCodRet = "000006";
		LET cDescripcion = "No es un tipo de consulta valido.";
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	
	IF NVL(pProducto,"") = "" THEN
		LET cCodRet = "000008";
		LET cDescripcion = "Es necesario indicar el producto que se desea consultar.";
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF;
	 
	IF pFechaIni IS NULL THEN
	   LET pFechaIni = DATE(1);
	END IF;

	IF pFechaFin IS NULL THEN
		LET pFechaFin = pFechaIni;
	END IF;

	-- VALIDAMOS SI YA SE ENCUENTRA CREADA LA TABLA.
	IF EXISTS( SELECT tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'ss_Dias_AtencionOS' ) THEN
		DROP TABLE ss_Dias_AtencionOS;
	ELSE

	  -- SE CREA UNA TABLA TEMPORAL PARA ALMACENAR LOS REGISTROS DE LOS RESULTADOS DE OS CALLE.
		CREATE TEMP TABLE ss_Dias_AtencionOS
		( 
			Descripcion        		CHAR(40), 
			CantidadOS				INTEGER, 
			Porcentaje_OS			DECIMAL(18,2)
		) WITH NO LOG;

	END IF
	
	-- VALIDAMOS EL PARAMETRO POREL CUAL SE REALIZARA LA CONSULTA.
	IF pTpConsulta    = '04' THEN
		LET cSucursal = pFiltro::CHAR(4);
		LET cSucursal = TRIM(cSucursal);
	ELIF pTpConsulta  = '01' THEN
		LET cEstado   = pFiltro::CHAR(4) ;
		LET cEstado   = TRIM(cEstado);
	ELIF pTpConsulta  = '02' THEN
		LET cCiudad   = pFiltro::CHAR(4) ;
		LET cCiudad   = TRIM(cCiudad);
	ELIF pTpConsulta  = '03' THEN
		 IF NVL(pFiltro,'') = '' THEN
			LET iRegion = 0;
		 ELSE 
		    LET iRegion = pFiltro::INTEGER;
		 END IF
	END IF
	 
	-- CONSULTAMOS LOS DIAS DE ATENCION DE OS POR CADA PERIODO DE DIAS.
    SELECT 
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(1,2) THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(3,4) THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(5,6) THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(7,8) THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(9,10) THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud > 10 THEN 1 ELSE 0 END ),
        SUM( CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(1,2) THEN 1 ELSE 0 END +
             CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(3,4) THEN 1 ELSE 0 END +
             CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(5,6) THEN 1 ELSE 0 END +
             CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(7,8) THEN 1 ELSE 0 END +
             CASE WHEN a.fecha_respuesta - a.fecha_solicitud IN(9,10) THEN 1 ELSE 0 END +
             CASE WHEN a.fecha_respuesta - a.fecha_solicitud > 10 THEN 1 ELSE 0 END ) total    
    INTO  i12D, i34D, i56D, i78D, i910D, iM10D, iTotalOS
    FROM bdisolic:"informix".ss_solicitud_os a ,
          bdisolic:"informix".ss_resum_scor_fin b,
          bdinteg:"informix".si_sucursales s,
          bdinteg:"informix".si_ciudades c,
          bdinteg:"informix".si_catciudades t,
          bdinteg:"informix".si_regiones r,
          bdisolic:"informix".ss_solicitudes ss
    WHERE a.empresa = b.empresa
	AND a.fecha_solicitud >=  pFechaIni 
	AND a.fecha_solicitud <=  pFechaFin
	AND ss.num_producto = pProducto
    AND a.status IN( 'A', 'R', 'D' )
    AND r.numero_region = DECODE(iRegion,0,r.numero_region,iRegion)
    AND c.estado = DECODE(cEstado,'',c.estado,cEstado)
    AND c.ciudad = DECODE(cCiudad,'',c.ciudad,cCiudad)
    AND ss.sucursal = DECODE(cSucursal,'',ss.sucursal,cSucursal) 
    AND a.num_solicitud = b.num_solicitud
    AND a.num_solicitud = ss.num_solicitud
    AND ss.sucursal = s.sucursal
    AND s.tpo_sucursal      = "S"
    AND s.ciudad            = c.ciudad
    AND s.pais              = c.pais
    AND s.estado            = c.estado
    AND c.ciudad_coppel     = t.numerociudad
    AND t.numero_region     = r.numero_region;
	 
	 
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO DE DIAS.
	IF iTotalOS > 0 THEN
		LET dPorcPeriodo = ROUND(((i12D) / (iTotalOS)) * 100,2);
	ELSE
		LET cCodRet = "000009";
		LET cDescripcion = "No se encuentran registros en la fecha que desea consultar.";
		-- ELIMINAMOS LA TABLA TEMPORAL.
		DROP TABLE ss_Dias_AtencionOS;
		RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0);
	END IF
	 
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '1-2', i12D , dPorcPeriodo ); 
	
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO
	LET dPorcPeriodo = ROUND(( (i34D) / (iTotalOS)) * 100,2);
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '3-4', i34D , dPorcPeriodo ); 
	
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO
	LET dPorcPeriodo = ROUND(( (i56D) / (iTotalOS)) * 100,2);  
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '5-6', i56D , dPorcPeriodo ); 
	
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO
	LET dPorcPeriodo = ROUND(( (i78D) / (iTotalOS)) * 100,2);  
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '7-8', i78D , dPorcPeriodo ); 
	
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO
	LET dPorcPeriodo = ROUND(( (i910D) / (iTotalOS)) * 100,2);  
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '9-10', i910D , dPorcPeriodo ); 
	
	-- CALCULAMOS LOS PORCENTAJES POR CADA PERIODO
	LET dPorcPeriodo = ROUND(( (iM10D) / (iTotalOS)) * 100,2);
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( '> 10', iM10D , dPorcPeriodo ); 
	
	-- SACAMOS EL TOTAL DE LA SUMA DE TODOS LOS PORCENTAJES.
	SELECT  SUM(Porcentaje_OS)	INTO dSumPorcOS
	FROM ss_Dias_AtencionOS;
	
	IF dSumPorcOS > 100 OR dSumPorcOS < 100 THEN
		LET dSumPorcOS = 100;
	END IF
	
	
	-- INSERTAMOS  LAS CONSULTAS DE LOS PERIODOS EN LA TABLA TEMPORAL.
	INSERT INTO ss_Dias_AtencionOS ( Descripcion, CantidadOS, Porcentaje_OS )
	VALUES     					  ( 'Total', iTotalOS , dSumPorcOS ); 
	  
	-- INICIALIZAMOS LAS VARIABLES QUE SE REGISTRARON EN LA TABLA TEMPORAL.
	LET iTotalOS	= 0;
	LET dSumPorcOS	= 0;
	  
	-- SE GENERA EL REPORTE DE RESULTADOS DE OS CALLE
	FOREACH WITH HOLD
	   SELECT Descripcion, CantidadOS, Porcentaje_OS
		 INTO cDescripcion, iTotalOS, dSumPorcOS
	   FROM ss_Dias_AtencionOS
	   
	   RETURN cCodRet, NVL(cDescripcion,''), NVL(iTotalOS,0), NVL(dSumPorcOS,0) WITH RESUME; 
	END FOREACH;
	  
  -- ELIMINAMOS LA TABLA TEMPORAL	
	DROP TABLE ss_Dias_AtencionOS;

END
END PROCEDURE
