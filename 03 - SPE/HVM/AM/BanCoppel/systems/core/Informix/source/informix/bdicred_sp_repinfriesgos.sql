CREATE PROCEDURE "informix".sp_repinfriesgos()

RETURNING CHAR(6);

DEFINE cCodret          CHAR(6);
DEFINE sql_err          INTEGER;
DEFINE cNombre_Archivo  CHAR(100);
DEFINE cSql             CHAR(2024);
DEFINE Nom_mes          CHAR(10);
DEFINE Num_mes          INTEGER;
DEFINE Num_anio         INTEGER;
DEFINE cRutaArch        CHAR(50);
DEFINE v_fecha_inicio	DATE;
DEFINE v_fecha_fin		DATE;
DEFINE v_num_credito	CHAR(20);
DEFINE v_sucursal		CHAR(4);
DEFINE v_monto			DECIMAL(18,2);
DEFINE v_codigo_fun		CHAR(3);
DEFINE v_codigo_ref		INTEGER;
DEFINE v_fecha_mov		DATE;

LET cCodret   =  "000000";
LET sql_err   = 0;
LET cNombre_Archivo= "";
LET cSql      = "";
LET Num_anio = 0;
LET Num_mes  =0;
LET Nom_mes  ="";
LET cRutaArch = "";
LET v_fecha_inicio = DATE(1);
LET v_fecha_fin = DATE(1);
LET v_num_credito = '';
LET v_sucursal = '';
LET v_monto = 0;
LET v_codigo_fun = '';
LET v_codigo_ref = 0;
LET v_fecha_mov = DATE(1);

BEGIN

	ON EXCEPTION SET sql_err
		LET cCodret = sql_err;
		RETURN cCodret;
	END EXCEPTION;

	-- SET DEBUG FILE TO "/aplicacion/Carlos/sp_repinfriesgos.out";
	-- TRACE ON;

	LET Num_mes = month(today);
	LET Num_anio = year(today);

	IF Num_mes = 1 THEN
	   LET Nom_mes = 'Diciembre';
	   LET Num_anio = year(today)-1;
	END IF;
	IF Num_mes = 2 THEN
	   LET Nom_mes = 'Enero';
	END IF;
	IF Num_mes = 3 THEN
	   LET Nom_mes = 'Febrero';
	END IF;
	IF Num_mes = 4 THEN
	   LET Nom_mes = 'Marzo';
	END IF;
	IF Num_mes = 5 THEN
	   LET Nom_mes = 'Abril';
	END IF;
	IF Num_mes = 6 THEN
	   LET Nom_mes = 'Mayo';
	END IF;
	IF Num_mes = 7 THEN
	   LET Nom_mes = 'Junio';
	END IF;
	IF Num_mes = 8 THEN
	   LET Nom_mes = 'Julio';
	END IF;
	IF Num_mes = 9 THEN
	   LET Nom_mes = 'Agosto';
	END IF;
	IF Num_mes = 10 THEN
	   LET Nom_mes = 'Septiembre';
	END IF;
	IF Num_mes = 11 THEN
	   LET Nom_mes = 'Octubre';
	END IF;
	IF Num_mes = 12 THEN
	   LET Nom_mes = 'Noviembre';
	END IF;

	LET  cNombre_Archivo= 'HisMov_' || trim(Nom_mes) || Num_anio || '.txt';

--ejecuta el Spl que trae la fecha inicial y fecha final del año, mes que se mete como parametro
--EXECUTE PROCEDURE "informix".sp_calcfechas (panio,pmes) INTO v_fch_ini,v_fch_fin;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

	TRUNCATE TABLE "informix".sd_reportinfriesgos DROP STORAGE;

    -- Obtiene la ruta en donde depositar el  archivo
    SELECT valor 
	INTO cRutaArch 
	FROM "informix".sd_param 
	WHERE cod_param  = '49';
	
	LET v_fecha_inicio = MDY(MONTH(MDY(MONTH(TODAY),'01',YEAR(TODAY)) - 1),'01',YEAR(MDY(MONTH(TODAY),'01',YEAR(TODAY)) - 1));
	LET v_fecha_fin = MDY(MONTH(MDY(MONTH(TODAY),'01',YEAR(TODAY)) - 1),DAY(MDY(MONTH(TODAY),'01',YEAR(TODAY)) - 1),YEAR(MDY(MONTH(TODAY),'01',YEAR(TODAY)) - 1));
	
	FOREACH WITH HOLD
    
		SELECT num_credito, sucursal, monto, codigo_fun, codigo_ref,fecha_mov
		INTO v_num_credito, v_sucursal, v_monto, v_codigo_fun, v_codigo_ref, v_fecha_mov
		FROM "informix".sd_movhis
		WHERE empresa = '001' 
		AND reversado = 'N'
		AND fecha_mov BETWEEN v_fecha_inicio AND v_fecha_fin
		AND (codigo_fun = '002' AND codigo_ref IN ('30','34','35','36','37','38','39','40','41','42','50','937','938')
		OR codigo_fun = '033' AND codigo_ref ='1'
		OR codigo_fun = '333' AND codigo_ref IN ('4','3')
		OR codigo_fun = '335' AND codigo_ref = '1'
		OR codigo_fun = '336' AND codigo_ref IN ('1','23','24')
		OR codigo_fun = '337' AND codigo_ref = '1'
		OR codigo_fun = '339' AND codigo_ref IN ('1','3','6','7','8','9','10','11','12','14','17','18','19','20','21','22','24','25','26','50','51','993','994','995','996')
		OR codigo_fun = '340' AND codigo_ref IN ('1','2','4','6','20','21','22','23','25','26')
		OR codigo_fun = '604' AND codigo_ref IN ('2','7001')
		OR codigo_fun = '605' AND codigo_ref IN ('2','3','125','126','127','128')
		OR codigo_fun = '606' AND codigo_ref IN ('1','7018','7034','7035')
		OR codigo_fun = '607' AND codigo_ref = '1')
		--Se genera archivo con la informacion del reporte

		BEGIN WORK;
			INSERT INTO "informix".sd_reportinfriesgos (num_credito, sucursal, monto, codigo_fun, codigo_ref, fecha_mov)
			VALUES (v_num_credito, v_sucursal, v_monto, v_codigo_fun, v_codigo_ref, v_fecha_mov);
		COMMIT WORK;
		
		LET v_num_credito, v_sucursal, v_monto, v_codigo_fun, v_codigo_ref, v_fecha_mov = '', '', 0, '', 0, DATE(1);

	END FOREACH;
		
    LET cSql = '';
    LET cSql = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || 'ReporteHisCredRegistros.unl' || ' DELIMITER ' || '''|''' || 
               ' SELECT * FROM "informix".sd_reportinfriesgos;' || 
               ' " > ' || TRIM(cRutaArch) || 'ReporteInformacionRegistros.sql';
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = 'dbaccess bdicred ' || TRIM(cRutaArch) || 'ReporteInformacionRegistros.sql';
    SYSTEM cSql;

    LET cSql = "sed 's/|$//g' " || TRIM(cRutaArch) || "ReporteHisCredRegistros.unl > " || TRIM(cRutaArch) || cNombre_Archivo;
    SYSTEM cSql;

    LET cSql = '';
    LET cSQL = 'rm ' || TRIM(cRutaArch) || 'ReporteInformacionRegistros.sql ' || TRIM(cRutaArch) ||'ReporteHisCredRegistros.unl';
    SYSTEM cSql;

    -- comprime el archivo
    LET cSql = '';
    LET cSql = " gzip " || TRIM(cRutaArch)|| cNombre_Archivo;
    SYSTEM cSql;

    RETURN cCodret;

END
END PROCEDURE;