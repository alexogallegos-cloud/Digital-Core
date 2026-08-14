CREATE PROCEDURE "informix".sp_rep_estadisticas_tdc(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
--GEV Junio 2013 Se unen los archivos enviados al CAT en uno solo, se hace la union del nombre en un solo campo,
--se unen los telefonos, y solo se toman en cuenta las tarjetas de credito.          
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cCodRetornoCall	CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cNomArchivo      CHAR(100);
DEFINE vsql             CHAR(4000);
DEFINE cNum_dia         char(2);
DEFINE cNum_mes         char(2);
DEFINE cNum_anio        char(4);
DEFINE dtFecha           DATE;
DEFINE dtFechaIni        DATE;
DEFINE dtFechaFin        DATE;
DEFINE iTarjetaActSinSaldo      INTEGER;
DEFINE iTarjetasNunca           INTEGER;
DEFINE iTarjetaTopadaNoVencido  INTEGER;
DEFINE iTotalRegistros   integer;
define vregistros		integer;
define sPaso			smallint;
define vproceso			char(4);
DEFINE viPrioridad      INTEGER;
DEFINE cNum_cte         CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE  vlvalor         CHAR(50);
DEFINE  vFechaHoy30     DATE;
DEFINE cnombre				CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cConstanteSOL		CHAR(03); 
DEFINE cConstanteTipoLogica	CHAR(01);
DEFINE cConstantePrioridad	CHAR(01);
DEFINE dFechaRecoger	DATE;
DEFINE dFechaInsert		DATE;
DEFINE cTel1			CHAR(13);
DEFINE cTel2			CHAR(13);
DEFINE cTel3			CHAR(13);
DEFINE cTel4			CHAR(13);
DEFINE cTipored1		CHAR(13);
DEFINE cTipored2		CHAR(13);
DEFINE cTipored3		CHAR(13);
DEFINE cTipored4		CHAR(13);
DEFINE cExt				CHAR(05);
DEFINE cCorreoElec		CHAR(100);
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumcte			CHAR(20);
DEFINE cNombreCliente	CHAR(104);
DEFINE cSexo			CHAR(01);
DEFINE cEstadoCivil		CHAR(01);
DEFINE cNombreEstado	CHAR(30);
DEFINE cNir				CHAR(03);
DEFINE cSerie			CHAR(03);
DEFINE ctipored			CHAR(10);
DEFINE dFechaMov		DATE; 
DEFINE dMonto			DECIMAL(18,2); 
DEFINE iCantidad		INTEGER;



let vproceso	='2083';
 
LET iSqlErr    = 0;
LET iIsamErr   = 0;
LET cErrorInfo = "";
LET cCodRet    = '000000';
LET cCodRetornoCall = '';
LET cMensajeRet= 'El reporte de ESTADISTICAS TDC se realizÃ?Â³ correctamente';
LET cNum_dia    = '';
LET cNum_mes    = '';
LET cNum_anio   = '';
LET dtFecha     = DATE(0);     
LET cNomArchivo = '';
LET vsql        = '';
LET iTarjetaActSinSaldo     = 0;
LET iTarjetasNunca          = 0;
LET iTarjetaTopadaNoVencido = 0;
LET iTotalRegistros = 0;
let vregistros		=0;
let sPaso					=0;
LET viPrioridad     = 0;
LET cNum_cte        = '';
LET cNum_cred       = '';
LET vlvalor         = '120';
LET vFechaHoy30     = DATE(0);
LET cnombre					= "";
LET cdelimitador            = "";
LET cConstanteSOL			= ''; 
LET cConstanteTipoLogica	= '';
LET cConstantePrioridad		= '';
LET dFechaRecoger	= DATE(1);
LET dFechaInsert	= DATE(1);
LET cTel1			= '';
LET cTel2			= '';
LET cTel3			= '';
LET cTel4			= '';
LET cTipored1		= '';
LET cTipored2		= '';
LET cTipored3		= '';
LET cTipored4		= '';
LET cExt			= '';
LET cCorreoElec		= '';
LET cNumSolicitud	= '';
LET cNumcte			= '';
LET cNombreCliente	= '';
LET cSexo			= '';
LET cEstadoCivil	= '';
LET cNombreEstado	= '';
LET cNir			= '';
LET cSerie			= '';
LET ctipored		= '';
LET dFechaMov		= DATE(1); 
LET dMonto			= 0; 
LET iCantidad		= 0;




BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'ERROR en la ejecucion del reporte de ESTADISTICAS TDC --> ' || cNumSolicitud;
	  CALL "informix".sp_inserta_bitacora('001', vproceso, cCodRet, cMensajeRet, '02')RETURNING cCodRetornoCall;
      RETURN cCodRet, cMensajeRet;
   END IF;

END EXCEPTION;
  CALL "informix".sp_inserta_bitacora('001', vproceso, cCodRet, cMensajeRet, '01')RETURNING cCodRetornoCall;
    
--SET DEBUG FILE TO "sp_rep_estadisticas_tdc.out";
--TRACE ON;

SELECT a.fecha_hoy
   INTO dtFecha
   FROM bdicred:sd_fechas a
  WHERE a.empresa = pempresa;
  
--let dtFecha = mdy('08','05','2019');

  LET dtFechaIni = mdy(month(dtFecha),'01',year(dtFecha)) - 1 units month;
  LET dtFechaFin = mdy(month(dtFecha),'01',year(dtFecha)) - 1 units day;
  LET cNum_dia  = lpad(day(dtFecha),2,'0');
  LET cNum_mes  = lpad(month(dtFecha),2,'0');
  LET cNum_anio = lpad(year(dtFecha),4,'0');
  LET cNum_anio = substr(year(dtFecha),3,2);

  SET ISOLATION TO dirty READ;
  SET LOCK MODE TO WAIT 3;

  
/*  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'temp_disposiciones';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE temp_disposiciones;
            END IF;*/

	TRUNCATE TABLE temp_solicitudes_preautorizadas DROP storage;
	TRUNCATE TABLE temp_disposiciones DROP storage;
			
-- Solicitudes preautorizadas
/*
  CREATE TABLE "informix".temp_disposiciones (
	tipo_promocion char(3),
	tipo_logica smallint,
	fecha date,
      num_solicitud        CHAR(20),
     sucursal             CHAR(04),
	numcte1 char(20),
	ult_4dig char(4),
	status smallint,
	prioridad integer, 
      apell_paterno        CHAR(26),
      apell_materno        CHAR(26),
      nombre1              CHAR(106),
      nombre2              CHAR(26),
      sexo                 CHAR(10),
      estado_civil         CHAR(12),
	correo char(60),
      estado               CHAR(30),
      municipio            CHAR(30),
	num_solicitud2        CHAR(20),
    numcte2 char(20),
      fecha_autorizacion   DATE,
      fecha_lim_recoger    DATE,
	  telefono1            CHAR(13),
      telefono2            CHAR(13),
      telefono3            CHAR(13),
	  telefono4            CHAR(13),
      extension            CHAR(05)) 
	  extent size 43000 next size 4300 lock mode row;

  create index "informix".idx_temp_disposiciones on temp_disposiciones (num_solicitud, numcte1) online;
*/
  	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania
	where tipo_campania = 50 and num_parametro= 50;
	
	select trim(valor_alfabetico)
	into cnombre
	from bdicred:"informix".sd_param_campania
	where empresa = pempresa
	and tipo_campania = 61
	and grupo_parametro = 'ARCH1AUTOR'
	and num_parametro = 335;
	
	select trim(valor_alfabetico) 
	into cdelimitador 
	from bdicred:"informix".sd_param_campania 
	where empresa = pempresa
    and tipo_campania = 61 
	and grupo_parametro = 'ARCHIVOSEP' 
	and num_parametro = 336;
	
	select valor into vlvalor
	from bdisolic:ss_param where secuencia = '21';

	select sol.num_solicitud,sol.numcte, sol.empresa, sol.status_solicitud, aut.fecha_insert
	  FROM bdisolic:ss_solicitudes sol 
	  inner join bdisolic:ss_autorizacion aut on aut.empresa = sol.empresa and aut.num_solicitud = sol.num_solicitud and aut.status_solicitud = sol.status_solicitud and
												 aut.status_solicitud = 'AT' and date(aut.fecha_insert + 120 units day) >= dtFecha and aut.fecha_entrada <= dtFecha
	  where sol.empresa = '001'
		and sol.num_producto = '6001'
	  into temp SSSolicitudes with no log;

--  INSERT INTO informix.temp_disposiciones (tipo_promocion,tipo_logica,num_solicitud,numcte1,prioridad,nombre1,sexo,estado_civil,
--	correo,estado,fecha_autorizacion,fecha_lim_recoger,telefono1,telefono2,telefono3,telefono4,extension)
	
	FOREACH WITH HOLD
		SELECT 'SOL', 1, sol.num_solicitud, sol.numcte, 1 prioridad, trim(cte.apell_paterno)||' '||trim(cte.apell_materno)||' '||trim(cte.nombre1)||' '||trim(cte.nombre2),
				ctf.sexo, ctf.estado_civil, es.nombre, sol.fecha_insert, date(sol.fecha_insert + (select valor from bdisolic:ss_param where secuencia = '21') units day)
		INTO cConstanteSOL, cConstanteTipoLogica, 	cNumSolicitud, cNumcte, cConstantePrioridad, cNombreCliente,
				cSexo, cEstadoCivil, cNombreEstado, dFechaInsert, dFechaRecoger
		FROM SSSolicitudes sol 
		JOIN bdinteg:si_cliente cte ON cte.numcte = sol.numcte
		JOIN bdinteg:si_ctepf ctf ON ctf.numcte = sol.numcte
		JOIN bdinteg:si_direcciones_actual dir1 ON dir1.numcte = sol.numcte AND dir1.tipo_dir = '1'  
		JOIN bdinteg:si_estados es on es.estado = dir1.estado
		JOIN bdinteg:si_catzonas cat ON cat.numerociudad = dir1.numerociudad and cat.numerocolonia = dir1.numerocolonia

		WHERE sol.num_solicitud not in (select num_solicitud from bdicred:temp_solicitudes_preautorizadas)
		
		
		LET iTotalRegistros = iTotalRegistros + 1;
-------------------------------------------------------------------
/*		SELECT LIMIT 1 a.telefono, d.telefono,d.extension
			INTO cTel1 , cTel3 ,cExt
        FROM bdinteg:si_telefonos_actual a
--    LEFT OUTER JOIN bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
      LEFT OUTER JOIN bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
       WHERE a.empresa = cempresa
         AND a.numcte = cNumcte
         AND a.tipo_tel = 1
         AND a.status_tel = 'A' 
         AND a.cofetel = 'V' ;   */
-------------------------------------------------------------------

		SELECT LIMIT 1 tel1.telefono, tel3.telefono, tel3.extension
		  INTO cTel1, cTel3 ,cExt
          FROM bdinteg:si_telefonos_actual tel1
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 on tel3.numcte = tel1.numcte and tel3.tipo_tel = 3 and tel3.cofetel = 'V' 
		 WHERE tel1.numcte = cNumcte
		   AND tel1.tipo_tel = 1
           AND tel1.cofetel = 'V' ;   
		
		SELECT LIMIT 1 tel2.telefono, tel4.telefono
		  INTO cTel2 , cTel4
          FROM bdinteg:si_telefonos_actual tel2
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel4 on tel4.numcte = tel2.numcte and tel4.tipo_tel = 4 and tel4.cofetel = 'V' 
		 WHERE tel2.numcte = cNumcte
           AND tel2.tipo_tel = 2
           AND tel2.cofetel = 'V' ;   
		
--No aplica en el join
/*		SELECT LIMIT 1
		  FROM bdicred:sd_tarjeta 
         WHERE tar.empresa = '001'
		   AND tar.num_credito = sol.num_solicitud 
           AND tar.tipo_tarjeta ='T' 
		   AND tar.status_tar = 'A';*/
--No aplica en el join

		SELECT limit 1 nvl( trim(correo_elec), '') 
		  INTO cCorreoElec
          FROM bdinteg:si_correos
         WHERE numcte = cNumcte
           AND status_correo = 'A';

		LET cTel1 = nvl(substr(cTel1,length(cTel1)-9,10),'');
		LET cTel2 = nvl(substr(cTel2,length(cTel2)-9,10),'');
		LET cTel3 = nvl(substr(cTel3,length(cTel3)-9,10),'');
		LET cTel4 = nvl(substr(cTel4,length(cTel4)-9,10),'');

		IF nvl(cTel1,'') = '' AND nvl(cTel2,'') = '' AND nvl(cTel3,'') = '' AND nvl(cTel4,'')='' THEN
			CONTINUE FOREACH;
		END IF;

		IF nvl(cTel1,'') = nvl(cTel2,'') THEN
			LET cTel2 = '';
		END IF;

		IF nvl(cTel3,'') = nvl(cTel2,'') OR nvl(cTel3,'') = nvl(cTel1,'') THEN
			LET cTel3 = '';
		END IF;

		IF nvl(cTel1,'') = nvl(cTel4,'') OR nvl(cTel2,'') = nvl(cTel4,'') OR nvl(cTel3,'') = nvl(cTel4,'') THEN
			LET cTel4 = '';
		END IF;

		
		IF SUBSTR(cTel4,1,2) in ('55','33','81')  THEN 
			LET cNir = SUBSTR(cTel4,1,2);
			LET cSerie = SUBSTR(cTel4,3,4);
		ELSE 
			LET cNir = SUBSTR(cTel4,1,3);
			LET cSerie = SUBSTR(cTel4,4,3);
		END IF; 
		
		SELECT  limit 1 decode(trim(a.tipored),'MOVIL','1','')||cTel4 INTO cTipored4 
		  FROM bdinteg:si_cattelefono a 
		 WHERE a.nir = cNir
		   AND a.serie = cSerie
		   AND (SUBSTR(cTel4,7,4)*1)*1 >= a.numeracion_inicial 
		   AND (SUBSTR(cTel4,7,4)*1)*1 <= a.numeracion_final;
		   
		IF SUBSTR(cTel1,1,2) in ('55','33','81')  THEN 
			LET cNir = SUBSTR(cTel1,1,2);
			LET cSerie = SUBSTR(cTel1,3,4);
		ELSE 
			LET cNir = SUBSTR(cTel1,1,3);
			LET cSerie = SUBSTR(cTel1,4,3);
		END IF; 

		SELECT  limit 1 decode(trim(a.tipored),'MOVIL','1','')||cTel1 INTO cTipored1 
		  FROM bdinteg:si_cattelefono a 
		 WHERE a.nir = cNir
		   AND a.serie = cSerie
		   AND (SUBSTR(cTel1,7,4)*1)*1 >= a.numeracion_inicial 
		   AND (SUBSTR(cTel1,7,4)*1)*1 <= a.numeracion_final;

		IF SUBSTR(cTel2,1,2) in ('55','33','81')  THEN 
			LET cNir = SUBSTR(cTel2,1,2);
			LET cSerie = SUBSTR(cTel2,3,4);
		ELSE 
			LET cNir = SUBSTR(cTel2,1,3);
			LET cSerie = SUBSTR(cTel2,4,3);
		END IF; 

		SELECT  limit 1 decode(trim(a.tipored),'MOVIL','1','')||cTel2 INTO cTipored2 
		  FROM bdinteg:si_cattelefono a 
		 WHERE a.nir = cNir
		   AND a.serie = cSerie
		   AND (SUBSTR(cTel2,7,4)*1)*1 >= a.numeracion_inicial 
		   AND (SUBSTR(cTel2,7,4)*1)*1 <= a.numeracion_final;
		   

   		IF SUBSTR(cTel3,1,2) in ('55','33','81')  THEN 
			LET cNir = SUBSTR(cTel3,1,2);
			LET cSerie = SUBSTR(cTel3,3,4);
		ELSE 
			LET cNir = SUBSTR(cTel3,1,3);
			LET cSerie = SUBSTR(cTel3,4,3);
		END IF; 
		
		SELECT  limit 1 decode(trim(a.tipored),'MOVIL','1','')||cTel3 INTO cTipored3 
		  FROM bdinteg:si_cattelefono a 
		 WHERE a.nir = cNir
		   AND a.serie = cSerie
		   AND (SUBSTR(cTel3,7,4)*1)*1 >= a.numeracion_inicial 
		   AND (SUBSTR(cTel3,7,4)*1)*1 <= a.numeracion_final;

		BEGIN;
		INSERT INTO bdicred:temp_solicitudes_preautorizadas 
				(tipo_promocion, tipo_logica,  num_solicitud, numcte1,		     prioridad, 	  nombre1,
				  sexo, estado_civil, 	   correo,	estado, fecha_autorizacion, fecha_lim_recoger,  telefono1,  telefono2,  telefono3,  telefono4,  extension)
		VALUES 	(cConstanteSOL,			  1,   cNumSolicitud, cNumcte, cConstantePrioridad, cNombreCliente,
				cSexo,  cEstadoCivil, cCorreoElec, cNombreEstado, 	  dFechaInsert, 	dFechaRecoger,		cTipored1,		cTipored2, 		cTipored3,		cTipored4,		 cExt);
		COMMIT;
	END FOREACH;

    LET viPrioridad = 1;
    FOREACH WITH HOLD
        SELECT numcte1, num_solicitud INTO cNum_cte, cNum_cred 
        FROM bdicred:"informix".temp_solicitudes_preautorizadas WHERE tipo_promocion = 'SOL'
        ORDER BY fecha_autorizacion, fecha_lim_recoger ASC

		BEGIN;
        UPDATE bdicred:"informix".temp_solicitudes_preautorizadas SET prioridad = viPrioridad 
            WHERE numcte1 = cNum_cte AND num_solicitud = cNum_cred;
		COMMIT;

        LET viPrioridad = viPrioridad + 1;
    END FOREACH;

   --Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud
/*    LET viPrioridad = 1;
    FOREACH WITH HOLD
        SELECT numcte1, num_solicitud INTO cNum_cte, cNum_cred 
        FROM bdicred:"informix".temp_disposiciones WHERE tipo_promocion = 'SOL'
        ORDER BY fecha_autorizacion, fecha_lim_recoger ASC

		BEGIN;
        UPDATE bdicred:"informix".temp_disposiciones SET prioridad = viPrioridad 
            WHERE numcte1 = cNum_cte AND num_solicitud = cNum_cred;
        COMMIT;
		
        LET viPrioridad = viPrioridad + 1;
    END FOREACH;*/
   
   
	LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Rep_solicitudes_preaut.unl''' || ' DELIMITER ' || ''''|| cdelimitador || ''''|| 
		' select tipo_promocion,tipo_logica,num_solicitud,numcte1,prioridad,nombre1,sexo,estado_civil,correo,'||
		' estado,fecha_autorizacion,fecha_lim_recoger,'||		
		' telefono1,telefono2,telefono3,telefono4,extension'||
		' from bdicred:temp_solicitudes_preautorizadas '||
		' order by prioridad;'||
             ' " > /resplogifx/archivoscartera/Rep_solicitudes_preaut.sql';
	SYSTEM vsql;

  LET vSql = '';
  LET vSql = 'dbaccess bdicred /resplogifx/archivoscartera/Rep_solicitudes_preaut.sql';
  SYSTEM vSql;

------------- contar el numero de registros resultantes del archivo------------
--SELECT COUNT(*) INTO iTotalRegistros FROM temp_disposiciones;

	INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total)
	VALUES('001', dtFecha , 'TDC_AUT_SINRECOGER', iTotalRegistros);

    LET cNomArchivo = TRIM(cnombre) || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || 'R' || iTotalRegistros || '.txt';

	LET vsql = '';
	let vsql = ' echo "TIPO_PROMOCION'|| cdelimitador ||'TIPO_LOGICA'|| cdelimitador ||'NUMERO_CREDITO'|| cdelimitador ||'NUMERO_CLIENTE'|| cdelimitador ||'PRIORIDAD'|| cdelimitador ||
	'NOMBRE'|| cdelimitador ||'SEXO'|| cdelimitador ||'ESTADO CIVIL'|| cdelimitador ||'EMAIL'|| cdelimitador ||'ESTADO'|| cdelimitador ||
	'FECHA_AUTORIZACION'|| cdelimitador ||'FECHA_LIMITE_RECOGER_TDC'|| cdelimitador ||'TEL_CONS_TIPO_1'|| cdelimitador ||
	'TEL_CONS_TIPO_2'|| cdelimitador ||'TEL_CONS_TIPO_3'|| cdelimitador ||'TEL_CONS_TIPO_4'|| cdelimitador ||'EXTENSION'|| cdelimitador ||'">/resplogifx/archivoscartera/'|| cNomArchivo;
	system vsql;
	let vsql = '';

  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_solicitudes_preaut.unl >> /resplogifx/archivoscartera/" || cNomArchivo;
  SYSTEM vSql;
     
  LET vSql = '';
  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_solicitudes_preaut.sql /resplogifx/archivoscartera/Rep_solicitudes_preaut.unl';
  SYSTEM vSql;
  
	let sPaso = 0;

--	DROP TABLE temp_disposiciones;
	
	
	IF cNum_dia < 8 THEN
	-- Disposiciones ventanilla
	/*  CREATE TABLE informix.temp_disposiciones ( 
		  fecha_mov  	DATE,
		  creditos      INTEGER, 
		  monto         DECIMAL(18,2),
		  cantidad      INTEGER
	  );*/

	  LET cNomArchivo = 'Rep_disp_ventanilla_TDC_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';

	 
	/*  INSERT INTO informix.temp_disposiciones 
	  SELECT fecha_mov, 1 creditos, sum(monto) monto, count(*) cantidad  
	  FROM bdicred:sd_movhis 
	  WHERE empresa = pEmpresa
	  AND fecha_mov >= dtFechaIni 
	  AND fecha_mov <= dtFechaFin
	  AND codigo_fun = '002'
	  AND codigo_ref in (50,60)
	  AND reversado = 'N'
	  GROUP BY fecha_mov, num_credito;*/

	  FOREACH WITH HOLD
		  SELECT fecha_mov, sum(monto) monto, count(*) cantidad  
		  INTO 	 dFechaMov, dMonto, iCantidad
		  FROM bdicred:sd_movhis 
		  WHERE empresa = pEmpresa
		  AND fecha_mov >= dtFechaIni 
		  AND fecha_mov <= dtFechaFin
		  AND codigo_fun = '002'
		  AND codigo_ref in (50,60)
		  AND reversado = 'N'
		  GROUP BY fecha_mov, num_credito

			BEGIN;
			INSERT INTO bdicred:temp_disposiciones
						(fecha_mov, creditos, monto, cantidad)
				 VALUES (dFechaMov, 	  1, dMonto, iCantidad);
			COMMIT;
		END FOREACH;
	  
	  LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.unl''' || ' DELIMITER ' || '''|'''|| 
				 ' select fecha_mov, sum(creditos), sum(monto), sum(cantidad) from bdicred:temp_disposiciones group by 1;'|| 
				 ' " > /resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.sql';
	  SYSTEM vsql;

	  LET vSql = '';
	  LET vSql = 'dbaccess bdicred /resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.sql';
	  SYSTEM vSql;

	  LET vsql = 'echo "FECHA MOVTO.'|| '|'|| 'NUM. CREDITOS'|| '|'|| 'MONTOS'|| '|'|| 'NUM. TRANSACCIONES' || 
				 ' " > /resplogifx/archivoscartera/'|| cNomArchivo;
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.unl >> /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;
		 
	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.sql /resplogifx/archivoscartera/Rep_disp_ventanilla_TDC.unl';
	  SYSTEM vSql;

	--  DROP TABLE temp_disposiciones;

	-- Disposiciones cajero (ATM)
	/*  CREATE TABLE informix.temp_disposiciones ( 
		  fecha_mov  	DATE,
		  creditos      INTEGER, 
		  monto         DECIMAL(18,2),
		  cantidad      INTEGER
	  );*/
	  
	  TRUNCATE TABLE bdicred:temp_disposiciones DROP storage;

	  LET vsql        ='';
	  LET cNomArchivo = 'Rep_disp_ventanilla_ATM_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';

	/*  INSERT INTO informix.temp_disposiciones 
	  SELECT fecha_mov, 1 creditos, sum(monto) monto, count(*) cantidad  
	  FROM bdicred:sd_movhis b 
	  WHERE empresa = pEmpresa 
	  AND fecha_mov >= dtFechaIni 
	  AND fecha_mov <= dtFechaFin
	  AND codigo_fun = '002'
	  AND codigo_ref in (30,40,41,42,61,62,63,64)
	  AND reversado = 'N'
	  GROUP BY fecha_mov, num_credito;*/

	  LET dFechaMov = DATE(1);
	  LET dMonto 	= 0;
	  LET iCantidad = 0;
	  
		FOREACH WITH HOLD
			SELECT fecha_mov,  sum(monto) monto, count(*) cantidad  
			  INTO 	dFechaMov, dMonto, iCantidad
			  FROM bdicred:sd_movhis b 
			 WHERE empresa = pEmpresa 
			   AND fecha_mov >= dtFechaIni 
			   AND fecha_mov <= dtFechaFin
			   AND codigo_fun = '002'
			   AND codigo_ref in (30,40,41,42,61,62,63,64)
			   AND reversado = 'N'
			 GROUP BY fecha_mov, num_credito

			BEGIN;
			INSERT INTO bdicred:temp_disposiciones
						(fecha_mov, creditos, monto, cantidad)
				 VALUES (dFechaMov, 	  1, dMonto, iCantidad);
			COMMIT;
		END FOREACH;

			
	  LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Rep_transacciones_ATM.unl''' || ' DELIMITER ' || '''|'''|| 
				 ' select fecha_mov, sum(creditos), sum(monto), sum(cantidad) from bdicred:temp_disposiciones group by 1;'|| 
				 ' " > /resplogifx/archivoscartera/Rep_transacciones_ATM.sql';
	  SYSTEM vsql;

	  LET vSql = '';
	  LET vSql = 'dbaccess bdicred /resplogifx/archivoscartera/Rep_transacciones_ATM.sql';
	  SYSTEM vSql;

	  LET vsql = 'echo "FECHA MOVTO.'|| '|'|| 'NUM. CREDITOS'|| '|'|| 'MONTOS'|| '|'|| 'NUM. TRANSACCIONES' || 
				 ' " > /resplogifx/archivoscartera/'|| cNomArchivo;
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_transacciones_ATM.unl >> /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;
		 
	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_transacciones_ATM.sql /resplogifx/archivoscartera/Rep_transacciones_ATM.unl';
	  SYSTEM vSql;

	--  DROP TABLE temp_disposiciones;
	  TRUNCATE TABLE bdicred:temp_disposiciones DROP storage;
	  
	-- Compras por mes (POS)
	/*  CREATE TABLE informix.temp_disposiciones ( 
		  fecha_mov  	DATE,
		  creditos      INTEGER, 
		  monto         DECIMAL(18,2),
		  cantidad      INTEGER
	  );*/

	  LET vsql        ='';
	  LET cNomArchivo = 'Rep_compras_TDC_enPOS_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';

	/*  INSERT INTO informix.temp_disposiciones 
	  SELECT fecha_mov, 1 creditos, sum(monto) monto, count(*) cantidad  
	  FROM bdicred:sd_movhis 
	  WHERE empresa = pEmpresa 
	  AND fecha_mov >= dtFechaIni 
	  AND fecha_mov <= dtFechaFin
	  AND codigo_fun = '002'
	  AND codigo_ref = 37
	  AND reversado = 'N'
	  GROUP BY fecha_mov, num_credito;*/

	  LET dFechaMov = DATE(1);
	  LET dMonto 	= 0;
	  LET iCantidad = 0;
	  
		FOREACH WITH HOLD
			SELECT fecha_mov,  sum(monto) monto, count(*) cantidad  
			  INTO 	dFechaMov, dMonto, iCantidad
			  FROM bdicred:sd_movhis 
			 WHERE empresa = pEmpresa 
			   AND fecha_mov >= dtFechaIni 
			   AND fecha_mov <= dtFechaFin
			   AND codigo_fun = '002'
			   AND codigo_ref in (37,937,938)
			   AND reversado = 'N'
			 GROUP BY fecha_mov, num_credito

			BEGIN;
			INSERT INTO bdicred:temp_disposiciones
						(fecha_mov, creditos, monto, cantidad)
				 VALUES (dFechaMov, 	  1, dMonto, iCantidad);
			COMMIT;
		END FOREACH;

	  
	  LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Rep_compras_TDC_enPOS.unl''' || ' DELIMITER ' || '''|'''|| 
				 ' select fecha_mov, sum(creditos), sum(monto), sum(cantidad) from temp_disposiciones group by 1;'|| 
				 ' " > /resplogifx/archivoscartera/Rep_compras_TDC_enPOS.sql';
	  SYSTEM vsql;

	  LET vSql = '';
	  LET vSql = 'dbaccess bdicred /resplogifx/archivoscartera/Rep_compras_TDC_enPOS.sql';
	  SYSTEM vSql;

	  LET vsql = 'echo "FECHA MOVTO.'|| '|'|| 'NUM. CREDITOS'|| '|'|| 'MONTOS'|| '|'|| 'NUM. TRANSACCIONES' || 
				 ' " > /resplogifx/archivoscartera/'|| cNomArchivo;
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_compras_TDC_enPOS.unl >> /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;
	 
	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_compras_TDC_enPOS.sql /resplogifx/archivoscartera/Rep_compras_TDC_enPOS.unl';
	  SYSTEM vSql;

	--  DROP TABLE temp_disposiciones;
	  TRUNCATE TABLE bdicred:temp_disposiciones DROP storage;

	-- TDC activas (con saldo) sin vencido 
	  LET vsql        ='';
	  LET cNomArchivo = 'Rep_cifras_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';

	--  SELECT {+INDEX (bdicred:sd_maesdos idx_sd_maesdos1)} count(*) INTO iTarjetaActSinSaldo
	  SELECT count(*) INTO iTarjetaActSinSaldo
	  FROM bdicred:sd_maecred a,
		   bdicred:sd_maesdos b
	  WHERE a.empresa = pEmpresa
		AND a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		AND a.status_cred <> 'CV'
		AND b.sdo_cap_insoluto > 0
		AND b.sdo_capital = b.sdo_cap_insoluto;

	  LET vsql = 'echo "NÃ?Âºmero de TDC activas con saldo sin vencido ==> '|| iTarjetaActSinSaldo || 
				 ' " > /resplogifx/archivoscartera/Rep_TDC_activas_sinsaldo.sql';
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_TDC_activas_sinsaldo.sql > /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;

	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_TDC_activas_sinsaldo.sql';
	  SYSTEM vSql;

	-- TDC que nunca se han usado
	/*  CREATE TABLE informix.temp_disposiciones ( 
		  creditos      char(20)
	  );

	  CREATE UNIQUE INDEX inx_paso ON temp_disposiciones(creditos);
	  UPDATE STATISTICS HIGH FOR TABLE temp_disposiciones;

	  LET vsql        ='';

	  INSERT INTO informix.temp_disposiciones 
	  SELECT a.num_credito
		FROM bdicred:sd_maecred a,
			 bdicred:sd_maesdos b
	  WHERE a.empresa = pEmpresa
		AND a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		AND a.status_cred <> 'CV'
		AND b.sdo_cap_insoluto = 0; 
		
	  SELECT count(*) INTO iTarjetasNunca
		FROM temp_disposiciones a
	   WHERE (
	  SELECT count(*) FROM bdicred:sd_movhis 
	   WHERE empresa = pEmpresa AND a.creditos = num_credito AND codigo_fun <> pEmpresa AND folio_suc NOT IN ('CalifCartReserva','CalifCart')) = 0;
	*/

	 SELECT COUNT(*) INTO iTarjetasNunca
		FROM bdicred:sd_maecred a
		INNER JOIN bdicred:sd_maesdos b ON b.empresa = a.empresa AND b.num_credito = a.num_credito AND b.sdo_cap_insoluto = 0
		INNER JOIN bdicred:sd_indicador_cred c ON c.empresa = a.empresa AND c.num_credito = a.num_credito 
			AND nvl(monto_primer_compra,0) = 0
			AND nvl(monto_primer_disp,0) = 0
			AND nvl(monto_ultimo_pago,0) = 0
	  WHERE a.empresa = '001'
		AND a.num_producto='6001' 
		AND a.status_cred IN ('AA','E1');


	  LET vsql = 'echo "Numero de TDC nunca ==> '|| iTarjetasNunca || 
				 ' " > /resplogifx/archivoscartera/Rep_TDC_nunca.sql';
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_TDC_nunca.sql >> /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;

	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_TDC_nunca.sql';
	  SYSTEM vSql;

	--  DROP TABLE temp_disposiciones;

	-- TDC que tienen topada su LC pero no estÃ?Â¡n en vencido 
	  LET vsql        ='';

	--  SELECT {+INDEX (bdicred:sd_maesdos idx_sd_maesdos1)} count(*) INTO iTarjetaTopadaNoVencido
	  SELECT count(*) INTO iTarjetaTopadaNoVencido
	   FROM bdicred:sd_maecred a,
			bdicred:sd_maesdos b
	  WHERE a.empresa = pEmpresa
		AND a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		AND sdo_cap_insoluto > 0
		AND sdo_capital = sdo_cap_insoluto
		AND sdo_cap_insoluto >= monto_otorgado;

	  LET vsql = 'echo "NÃ?Âºmero de TDC con lÃ?Â­nea de crÃ?Â©dito topada pero no estÃ?Â¡n vencidas ==> '|| iTarjetaTopadaNoVencido || 
				 ' " > /resplogifx/archivoscartera/Rep_TDC_lincred_topada_NoVencido.sql';
	  SYSTEM vsql;

	  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_TDC_lincred_topada_NoVencido.sql >> /resplogifx/archivoscartera/" || cNomArchivo;
	  SYSTEM vSql;

	  LET vSql = '';
	  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_TDC_lincred_topada_NoVencido.sql';
	  SYSTEM vSql;

	END IF;

  CALL "informix".sp_inserta_bitacora('001', vproceso, cCodRet, cMensajeRet, '03')RETURNING cCodRetornoCall;
  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;