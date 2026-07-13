CREATE PROCEDURE "informix".sp_info_gen_edocta_dir(pempresa CHAR(3),pperiodo DATE)
--EXECUTE PROCEDURE sp_info_gen_edocta_dir('001',mdy('03','20','2025'));
RETURNING CHAR(5);

DEFINE v_ruta       VARCHAR(255);
DEFINE cod_ret      CHAR(5);
DEFINE cCodRetBit   CHAR(6);
DEFINE cProceso     CHAR(4);
DEFINE sql_err      INTEGER;
DEFINE isam_err     INTEGER;
DEFINE error_info   CHAR(80);
DEFINE cMensajeRet  CHAR(125);
DEFINE v_sql        CHAR(5550);
DEFINE v_sql1       CHAR(1350);
DEFINE v_sql2       CHAR(1050);
DEFINE v_sql3       CHAR(1050);
DEFINE v_sql4       CHAR(1050);
DEFINE v_sql5       CHAR(1050);
DEFINE v_sql6       CHAR(10000);
DEFINE v_periodo_tc_ini     DATE;       --periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  	--periodo_tc_fin
DEFINE v_periodo_anterior   DATE;		--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 	INTEGER;	--dias_periodo_tc
DEFINE v_cod_ret_otro		CHAR(5);
DEFINE v_FechaModificaZona  DATE;     
DEFINE pperiodoSdoInt1 		DATE;
DEFINE pperiodoSdoInt2 		DATE;
DEFINE vCuantosDirecEdcTdc	INTEGER;
DEFINE vCuantosDirecEdo		INTEGER;
DEFINE v_fileload  CHAR(50);
DEFINE v_fileload2  CHAR(50);




LET cod_ret 	= "000";
LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET v_sql6      = "";
LET v_periodo_tc_ini	= " ";	--periodo_tc_ini
LET v_periodo_tc_fin	= " ";	--periodo_tc_fin
LET v_periodo_anterior	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc	= 0;	--dias_periodo_tc
LET v_cod_ret_otro 		= "000";
LET cProceso 			= '0061';
LET cMensajeRet 		= 'PROCESO EXITOSO';
LET sql_err 			= 0;
LET isam_err 			= 0;
LET error_info 			= "";
LET v_FechaModificaZona = mdy('12','19','2012');
LET pperiodoSdoInt1 	= mdy(MONTH(pperiodo),1,year(pperiodo));
LET pperiodoSdoInt2 	= pperiodoSdoInt1;
LET vCuantosDirecEdcTdc = 0;
LET vCuantosDirecEdo	= 0;
LET v_fileload 			= "descargaDirecCred";
LET v_fileload2			= "DireccionCred";

set isolation to dirty read;
set lock mode to wait 3;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
--SET ISOLATION COMMITTED READ;
--set pdqpriority 20;

-- Fecha: 12/01/2020
-- Autor: 
-- Nodificacion: Informacion Base para la generacion de los Estados de Cuenta
-- Separando los querys.
-- Fecha update : 27/03/2025
-- Modificacion : Se actualiza  quitando la carga de tabla por un dbload
 
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;            
            LET cMensajeRet = error_info;
            --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cod_ret, cMensajeRet, '02') RETURNING cCodRetBit;
            RETURN cod_ret;
        END IF
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/c90260202/archivoscartera/sp_info_gen_edocta1.out";
    --TRACE ON;

    
    SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
	
	--let v_ruta = '/home/c90260202/archivoscartera/';
    
	    EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
                	INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
   
    LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
    LET v_periodo_tc_fin = pperiodo;
	EXECUTE PROCEDURE MONTHADD(pperiodoSdoInt1,-1) into pperiodoSdoInt2;
	
	SELECT COUNT(*) INTO vCuantosDirecEdo FROM direccioneedo;
	SELECT COUNT(*) INTO vCuantosDirecEdcTdc FROM sd_dir_edc_tdc;
	
	IF vCuantosDirecEdcTdc > 0 THEN 
		BEGIN;
			truncate table "informix".sd_dir_edc_tdc;
		COMMIT;
	END IF;
	
	IF vCuantosDirecEdo > 0 THEN
		BEGIN;	
			truncate table "informix".direccioneedo;
		COMMIT;
	END IF;


        -----------------DESCARGA DIRECCIONES-------------------------------------------------------------

        LET v_sql = ' echo "SET ISOLATION TO DIRTY READ; '
				|| ' UNLOAD TO '||v_ruta||'descargaDirecCred.unl ' 
                || ' SELECT numcte, fecha_apertura FROM bdicred:sd_maecred '
				|| ' WHERE empresa = ''001'' and status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') '
				|| ' and num_producto <> ''7800'' and campo_trab3 <> ''BAJA''; " >' ||v_ruta|| 'queryDIR.sql ';
		system v_sql;

        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryDIR.sql";		
		system v_sql;
		
		LET v_sql = '';		
		LET v_sql = ' echo "FILE '|| trim(v_ruta) || TRIM(v_fileload) || '.unl DELIMITER '''||'|'||''' 2; INSERT INTO "informix".sd_dir_edc_tdc; " > '|| trim(v_ruta) ||'query_dir_edc_tdc.sql';
		system v_sql;							

		LET v_sql = '';	
		LET v_sql = 'dbload -d bdicred -c '|| trim(v_ruta) ||'query_dir_edc_tdc.sql -l '|| trim(v_ruta) ||'sd_dir_edc_tdc.log -e 10000 -n 1000 -r';
		system v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDirecCred.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'query_dir_edc_tdc.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'sd_dir_edc_tdc.log ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryDIR.sql ';
        SYSTEM v_sql;
		

		LET v_sql1 = '';
        LET v_sql1 = ' echo "select numerociudad, numerocolonia from bdinteg:si_catzonas '  
                || ' into temp Catzonas with no log; ' 
                || ' create index indx_zonas on Catzonas (numerociudad, numerocolonia); '  
                || ' update statistics medium for table Catzonas; ' 
				|| ' UPDATE STATISTICS MEDIUM FOR TABLE sd_dir_edc_tdc; '
            	|| ' UNLOAD TO '||v_ruta||'DireccionCred.unl ' 
                || ' SELECT ''001'', a.numcte, b.numeroextcalle, b.numerointcalle, b.departamento, b.cod_postal, b.entre_calles, ' 
                || ' b.observaciones, b.numerociudad, b.numerocolonia, b.numerocalle, lpad(trim(b.estado),2,''0'') '
        		|| ' FROM sd_dir_edc_tdc a '
            	|| ' INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte and b.tipo_dir = ''1'' '
                || ' WHERE b.fecha_insert BETWEEN ''' || to_char(v_periodo_tc_ini,'%m-%d-%Y') ||''' AND ''' || to_char(v_periodo_tc_fin,'%m-%d-%Y') || '''' || '';
        LET v_sql2 =  ' UNION '
                || ' SELECT ''001'', a.numcte, b.numeroextcalle, b.numerointcalle, b.departamento, b.cod_postal, b.entre_calles, '
                || ' b.observaciones, b.numerociudad, b.numerocolonia, b.numerocalle, lpad(trim(b.estado),2,''0'') '
        	    || ' FROM sd_dir_edc_tdc a '
				|| ' INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte and b.tipo_dir = 1 '
                || ' WHERE  a.fecha_apertura BETWEEN ''' || to_char(v_periodo_tc_ini,'%m-%d-%Y') ||''' AND ''' || to_char(v_periodo_tc_fin,'%m-%d-%Y') || '''' || ''
                || ' UNION '
                || ' SELECT ''001'', b.numcte, b.numeroextcalle, b.numerointcalle, b.departamento,  b.cod_postal, b.entre_calles, '
                || ' b.observaciones, b.numerociudad, b.numerocolonia, b.numerocalle, lpad(trim(b.estado),2,''0'') '
        		|| ' FROM bdinteg:log_fusionclientes a '
				|| ' INNER JOIN bdinteg:si_direcciones_actual b ON a.cliente_tit = b.numcte '
				|| ' WHERE a.fecha_insert BETWEEN ''' || to_char(v_periodo_tc_ini,'%m-%d-%Y') ||''' AND ''' || to_char(v_periodo_tc_fin,'%m-%d-%Y') || '''' || ''
				|| ' and b.tipo_dir = 1 and UPPER(tabla) = ''SD_MAECRED'' '
				|| ' UNION ';
        LET v_sql3 = ' SELECT ''001'', a.numcte, b.numeroextcalle, b.numerointcalle,b.departamento,  b.cod_postal, b.entre_calles, '
                || ' b.observaciones, b.numerociudad, b.numerocolonia, b.numerocalle, lpad(trim(b.estado),2,''0'') '
        	    || ' FROM sd_dir_edc_tdc a, '
            	|| ' bdinteg:si_direcciones_actual b, Catzonas zon '
                || ' WHERE a.numcte = b.numcte and b.tipo_dir = 1 '
                || ' and zon.numerociudad = b.numerociudad and zon.numerocolonia = b.numerocolonia; " > ' || trim(v_ruta) ||'queryDIR2.sql';
        LET v_sql = rtrim(v_sql1)||rtrim(v_sql2)|| rtrim(v_sql3);
		system v_sql;

        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryDIR2.sql";		
		system v_sql;				
				

		LET v_sql = '';		
		LET v_sql = ' echo "FILE '|| trim(v_ruta) || TRIM(v_fileload2) || '.unl DELIMITER '''||'|'||''' 12; INSERT INTO "informix".direccioneedo; " > '|| trim(v_ruta) ||'direccioneedo.sql';
		system v_sql;							

		LET v_sql = '';	
		LET v_sql = 'dbload -d bdicred -c '|| trim(v_ruta) ||'direccioneedo.sql -l '|| trim(v_ruta) ||'direccioneedo.log -e 10000 -n 1000 -r';
		system v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'DireccionCred.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'direccioneedo.sql ';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'direccioneedo.log ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryDIR2.sql ';
        SYSTEM v_sql;

				
        LET v_sql4 = ' echo "UPDATE STATISTICS MEDIUM FOR TABLE direccioneedo; '||
				' SET ISOLATION TO DIRTY READ; '||
				' UNLOAD TO '||v_ruta||'descargaDIR.unl '||
				' SELECT a.empresa, a.numcte, b.numeroextcalle, replace(trim(b.numerointcalle),''|'',''''), replace(trim(b.departamento),''|'',''''), '||
                ' b.cod_postal,	replace(trim(b.entre_calles),''|'',''''), replace(trim(b.observaciones),''|'',''''), b.numerociudad, b.numerocolonia, '||
                ' zon.nombrezona, zon.centro, zon.jefegrupozona, zon.supervisorzona, zon.numerociudadcoppel, zon.numerocoloniacoppel, '||
                ' b.numerocalle, Trim(ca.nombrecalle), ci.nombreciudad, b.estado, es.nombre, '||
                ' Trim(nvl(cte.nombre1,'''')) || '' '' ||Trim(nvl(cte.nombre2,'''')) || '' '' || Trim(nvl(cte.apell_paterno,'''')) || '' '' ||Trim(nvl(cte.apell_materno,'''')), '||
				' decode(nvl(cte.rfc_alterno,''''),'''',cte.rfc,cte.rfc_alterno), NVL(SUBSTR(YEAR(cte.fecha_alta), 3, 2),''''), ';
        LET v_sql5 = ' TRIM(NVL(estado_civil,'''')), nvl(substr(TRIM(habita_en),1,1), ''P''), TRIM(NVL(sexo,'''')), '||
    			' NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'''') '||
                ' FROM bdicred:sd_maecred a '||
				' INNER JOIN bdinteg:si_cliente cte ON a.numcte = cte.numcte '||
				' INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte '||
         		' left outer join bdicred:direccioneedo b on (pf.numcte = b.numcte ) '||
                ' left outer join bdinteg:si_estados es on (es.pais = ''001'' and es.estado = b.estado ) '||
                ' left outer join bdinteg:si_catcalles ca on (b.numerocalle = ca.numerocalle) '||
                ' left outer join bdinteg:si_catzonas zon on (b.numerociudad = zon.numerociudad and b.numerocolonia = zon.numerocolonia) '||
            	' left outer join bdinteg:si_catciudades ci on (b.numerociudad = ci.numerociudad) '||
                ' WHERE a.status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') '|| 
				' and a.num_producto <> ''7800'' " >' ||v_ruta|| 'queryDIR3.sql ';

        LET v_sql = rtrim(v_sql4)||' '||rtrim(v_sql5);
        system v_sql;

        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryDIR3.sql";
        system v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaDIR.unl'||" >"||v_ruta||'descargaDIR1.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaDIR1.unl'||" >"||v_ruta||'descargaDIR2.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDIR.unl ';
        SYSTEM v_sql;

		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDIR1.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryDIR3.sql ';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaDIR2.unl'||" > " ||v_ruta||'Edocta_direcciones.unl';
        SYSTEM v_sql;

		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDIR2.unl ';
        SYSTEM v_sql;

END;

RETURN cod_ret;

END PROCEDURE;