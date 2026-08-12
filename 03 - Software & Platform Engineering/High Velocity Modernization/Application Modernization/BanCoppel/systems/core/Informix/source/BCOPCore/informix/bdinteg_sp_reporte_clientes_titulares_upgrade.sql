CREATE PROCEDURE "informix".sp_reporte_clientes_titulares_upgrade() RETURNING CHAR(5), CHAR(100);


--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE cMsjCodRet 	    VARCHAR(100);
DEFINE cMensaje		    VARCHAR(100);
DEFINE vsqlerr 			INTEGER;		-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr 		INTEGER;	 	-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 		VARCHAR(80);  	-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR

DEFINE cRutaRepor		VARCHAR(50);
DEFINE cNombreRepExc	VARCHAR(50);   
DEFINE cRutaEjecc 		VARCHAR(50); 
DEFINE cSystem			LVARCHAR (2000);
DEFINE iPaso			SMALLINT;
DEFINE dFechaActual	  	DATE;
DEFINE nContador        INT;
DEFINE nContador2       INT;
DEFINE dFechaHoy		DATE;
DEFINE cYear			CHAR(4);
DEFINE cMes 			CHAR(2);
DEFINE cDia 			CHAR(2);


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET cMsjCodRet 		    = 'EL REPORTE DE CLIENTES TITULARES SE HA GENERADO CORRECTAMENTE';
LET cMensaje		    = 'ERROR EN PASO: ';
LET vsqlerr 			= 0;
LET iIsamErr 			= 0;
LET cErrorInfo 			= "";
LET cSystem				= '';
LET iPaso               = 0;
LET dFechaActual		= TODAY-1; 
LET nContador       	= 0;
LET nContador2     		= 0;
LET dFechaHoy			= '';
LET cYear				= '';
LET cMes 				= '';
LET cDia 				= '';

--DESARROLLO
--LET cRutaRepor		= '/home/procesos/';
--PRODUCCION
LET cRutaRepor			= '/RESPALDOSNEW/procesos/';
--DESARROLLO
--LET cRutaEjecc        = '/informix/bin/dbaccess bdinteg ';
--PRODUCCION
LET cRutaEjecc        	= '/ifxsif01/bin/dbaccess bdinteg ';
LET cNombreRepExc 		= 'REPORTE_CLIENTES_TITULARES_UPGRADE.csv';



BEGIN

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
	
		IF vsqlerr <> 0  THEN
		
			LET  vCodRet  = vsqlerr;
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			RETURN vCodRet, cMensaje;

		END IF;
	END  EXCEPTION
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_reporte_clientes_titulares_upgrade.out";
	--TRACE ON;
	
	--OBTENCION DE FECHA DEL DIA DE HOY
		/*SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas;*/
		
		LET cYear = LPAD(YEAR(dFechaActual), 4, 0);
		LET cMes = LPAD(MONTH(dFechaActual), 2, 0);
		LET cDia = LPAD(DAY(dFechaActual), 2, 0);
		
		LET cNombreRepExc = 'REPORTE_CLIENTES_TITULARES_UPGRADE_'||cYear||cMes||cDia||'.csv';
	
	LET iPaso = 0;
	
		LET cSystem = 'rm -f ' || cRutaRepor || cNombreRepExc;
		SYSTEM cSystem; 
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	LET iPaso = 1;
	
		DROP TABLE IF EXISTS TMP_CLIENTES_TIT_1;
		DROP TABLE IF EXISTS TMP_CLIENTES_TIT_2;
		
		LET cSystem =  'echo "' || 'FECHA' || ',' || 'CLIENTES TITULARES' || ',' || 'UPGRADE' || ',' || 'TOTAL DE CLIENTES TITULARES' || ',' || 'P-109' || ',' || 'U-3' || ',' || 'U-60' || ',' || 'U-61' || ',' || 'U-62' || ',' || 'TOTAL DE SITUACIONES ESPECIALES' /*|| ',' || 'CLIENTES PROSPECTO POR SOLICITUDES DE COBRANZA' || ',' || 'CLIENTES PROSPECTO POR SOLICITUDES DE ALTA WEB' || ',' || 'CLIENTES TOTAL PROSPECTO'*/ || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		SYSTEM cSystem;
	
	LET iPaso = 2;

		--CLIENTES TITULARES
		SELECT numcte, '     ' AS SITESP
		FROM bdinteg:"informix".si_cliente
		WHERE fecha_insert = dFechaActual
		AND fecha_alta = fecha_insert
		AND tipo_cliente = '1'
		INTO TEMP TMP_CLIENTES_TIT_1 WITH NO LOG;
		
		CREATE INDEX "informix".idx_TMP_CLIENTES_TIT_1 ON TMP_CLIENTES_TIT_1(numcte);
	
	LET iPaso = 3;

		--CLIENTES UPGRADE
		SELECT DISTINCT cte.numcte, '     ' AS SITESP
		--INSTANCIA DESARROLLO
		--FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex JOIN bdinteg:"informix".si_cliente cte
		--INSTANCIA PRODUCTIVA
		FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex JOIN bdinteg:"informix".si_cliente cte
		ON ex.cliente = cte.numcte
		AND cte.tipo_cliente = '1'
		AND ex.fecha_alta <> cte.fecha_insert
		WHERE ex.fecha_alta = dFechaActual
		AND ex.cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033','0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')
		AND ex.secuencia = 1
		AND ex.prod_nombre IN ('ALTA CLIENTES', 'ALTA CLIENTES MENORES DE EDAD')
		AND ex.empresa = '001'		
		INTO TEMP TMP_CLIENTES_TIT_2 WITH NO LOG;
		
		CREATE INDEX "informix".idx_TMP_CLIENTES_TIT_2 ON TMP_CLIENTES_TIT_2(numcte);
	
	LET iPaso = 4;

		--CLIENTE TITULARES
		SELECT COUNT(*) INTO nContador FROM TMP_CLIENTES_TIT_1;

		LET cSystem =  'echo "' || TRIM( TO_CHAR(dFechaActual, '%d/%m/%Y')) || ',';
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 5;

		--CLIENTE UPGRADE
		SELECT COUNT(*) INTO nContador FROM TMP_CLIENTES_TIT_2;
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 6;

		--CLIENTE TITULARES + UPGRADE
		SELECT SUM(NUMCTE)
		INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1
		 UNION
	     SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2);
	
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 7;

		UPDATE TMP_CLIENTES_TIT_1
		SET SITESP = ( SELECT X.SITUACION||X.CAUSA FROM BDISITESP:SE_CTESSITESPCTE X WHERE X.NUMCTE = TMP_CLIENTES_TIT_1.NUMCTE );
	
	LET iPaso = 8;

		UPDATE TMP_CLIENTES_TIT_2
		SET SITESP = ( SELECT X.SITUACION||X.CAUSA FROM BDISITESP:SE_CTESSITESPCTE X WHERE X.NUMCTE = TMP_CLIENTES_TIT_2.NUMCTE );
	
	LET iPaso = 9;

		--SITUACION P109
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'P109'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'P109');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 10;
	
		--SITUACION U3
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U3'
		 UNION
	     SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U3');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 11;
	
		--SITUACION U60
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U60'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U60');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 12;
	
		--SITUACION U61
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U61'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U61');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 13;

		--SITUACION U62
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U62'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U62');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 14;

		--SUMA DE SITUACIONES
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP IN( 'P109', 'U3', 'U60', 'U61', 'U62' )
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP IN( 'P109', 'U3', 'U60', 'U61', 'U62' ));
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) );
	
	/*LET iPaso = 15;

		SELECT COUNT(*) INTO nContador
		FROM bdinteg:"informix".si_cliente A JOIN BDIPROSPECTOS:pr_cliente B
		ON A.NUMCTE = B.NUMCTE
		WHERE A.fecha_insert = dFechaActual
		AND A.tipo_cliente = '2'
		AND B.sucursal = '0800';
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 16;

		SELECT COUNT(*) INTO nContador2
		FROM bdinteg:"informix".si_cliente A JOIN BDIPROSPECTOS:pr_cliente B
		ON A.NUMCTE = B.NUMCTE
		WHERE A.fecha_insert = dFechaActual
		AND A.tipo_cliente = '2'
		AND B.sucursal != '0800';
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador2 ) ) || ',';*/
	
	
	LET iPaso = 17;
	
		--LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador + nContador2 ) ) || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		LET cSystem =  TRIM( cSystem ) || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		SYSTEM cSystem;
	
	LET iPaso = 18;

		RETURN vCodRet, cMsjCodRet;

END;
END PROCEDURE
;