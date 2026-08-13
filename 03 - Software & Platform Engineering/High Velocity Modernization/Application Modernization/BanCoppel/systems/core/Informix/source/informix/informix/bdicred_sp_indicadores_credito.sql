CREATE PROCEDURE "informix".sp_indicadores_credito()
RETURNING CHAR(5) 
/*  Declaracion de Variables Globales  */
   DEFINE v_codret               CHAR(100);
   DEFINE sql_err                SMALLINT;
   DEFINE v_sql                  CHAR(10000);
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (100);
   DEFINE v_ruta                 CHAR(100);
   DEFINE v_sql1   			     CHAR(2800);
   DEFINE v_sql2   			     CHAR(2800);
   DEFINE wdir                   CHAR(500);
   DEFINE lim_inicio			 SMALLINT;
   DEFINE lim_fin  				 SMALLINT;
   DEFINE fecha_inicio			 DATE;
   DEFINE fecha_fin 			 DATE;
   LET v_sql                     = '';
   LET v_sql1                    = '';
   LET v_sql2                    = '';
   LET v_codret                  = "00000";
   LET v_ruta                    = '/resplogifx/archivoscredito/';
   LET wdir                      ='';

BEGIN
	
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "ErrIndicadores.err";
		TRACE " * "||sql_err||" * "||isam_err||" * "||error_info;
		IF sql_err <> 0  THEN
			LET v_codret = sql_err;
			RETURN v_codret;
		END IF
	END EXCEPTION;
	
	-- SET DEBUG FILE TO '/ifxsif01/ciaguilar/Indicadores_SADA/spindicadoresDebug.out';
	-- TRACE ON; 
	
	/* CALCULO DE RANGO DE FECHAS PARA EL REPORTE DE INDICADORES*/
	-- Obtencion del parametro para restar los dias a partir de la fecha de ejecucion (today)
	SELECT substr(valor,1,3), substr(valor,5,3)
	INTO lim_fin, lim_inicio
	FROM bdicred:sd_param 
	WHERE empresa 	= '001' 
	AND cod_param	= 'RI0';
	
	LET fecha_inicio = today - lim_inicio units day;
	LET fecha_fin = today - lim_fin units day;
	
	/* FIN CALCULO FECHA*/
	
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'reporte_indicadores.txt';
    SYSTEM wdir;
	
	/*  SOLICITUDES  */
	LET v_sql1 = ' echo "UNLOAD TO '||TRIM(v_ruta)||'Solicitudes.unl';
    LET v_sql2 = ' select to_char(a.fecha_insert, ''%d-%m-%Y''),sum(case when a.num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA,sum(case when a.num_producto = ''6400'' then 1 else 0 end) '||
	'PRESTAMO_DIRECTO_NOMINA,sum(case when a.num_producto = ''7800'' then 1 else 0 end) ANTICIPO_NOMINA,sum(case when a.num_producto = ''6800'' then 1 else 0 end) PRESTAMO_FLEXIBLE,sum(case when a.num_producto = ''7700'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL_24,'||
	'sum(case when a.num_producto = ''7600'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL_18, sum(case when a.num_producto = ''6300'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL, sum(case when a.num_producto = ''6011'' then 1 else 0 end) REESTRUCTURA_TARJETA_CREDITO,sum(case when a.num_producto = ''6500'' then 1 else 0 end) TARJETA_CREDITO_COPPEL '||
	'from bdisolic:ss_solicitudes a left outer join bdicred:sd_definicion b on (a.empresa=b.empresa and a.num_producto=b.num_producto) where a.empresa=''001'' and a.fecha_insert >= '''|| fecha_inicio ||''' and '||
	'a.fecha_insert <= '''|| fecha_fin ||''' group by 1 order by 1;" >'||TRIM(v_ruta)||'querySolicitudes.sql';
	LET v_sql = TRIM(v_sql1) || v_sql2;
	system v_sql;
	LET v_sql = "dbaccess bdicred "||TRIM(v_ruta)||"querySolicitudes.sql";
	system v_sql;
	/* FIN SOLICITUDES  */

	/*  APERTURAS  */
	LET v_sql2 = 'echo "select a.fecha_apertura,sum(case when a.num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA,sum(case when a.num_producto = ''8100'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_ORO,sum(case when a.num_producto = ''7000'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_PLATINUM,sum(case when a.num_producto = ''7800'' then 1 else 0 end) ANTICIPO_NOMINA '||
	'from bdicred:sd_maecred a left outer join bdicred:sd_definicion b on (a.empresa=b.empresa and a.num_producto=b.num_producto) where a.empresa=''001'' and a.fecha_apertura>= '''|| fecha_inicio||''' and a.fecha_apertura<= '''|| fecha_fin||''' group by 1 INTO temp tmp_maecred with no log;" > '|| TRIM(v_ruta)||'queryAperturas.sql';
	system v_sql2;
	LET v_sql2 = 'echo "CREATE INDEX idx_maecred ON tmp_maecred (fecha_apertura);" >> '|| TRIM(v_ruta)||'queryAperturas.sql';
	system v_sql2;
	LET v_sql2 = ' echo "select a.fecha_apertura,sum(case when a.num_producto = ''6400'' then 1 else 0 end) DIRECTO_NOMINA,sum(case when a.num_producto = ''6800'' then 1 else 0 end) PRESTAMO_FLEXIBLE,sum(case when a.num_producto = ''7700'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL_24,sum(case when a.num_producto = ''7600'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL_18,sum(case when a.num_producto = ''6300'' then 1 else 0 end) PRESTAMO_PERSONAL_BANCOPPEL,sum(case when a.num_producto = ''6011'' then 1 else 0 end) REESTRUCTURA_TARJETA_CREDITO from bdicred:sd_maecredcrd a left outer join bdicred:sd_definicion b on (a.empresa=b.empresa and a.num_producto=b.num_producto) where a.empresa=''001'' and a.fecha_apertura>= '''|| fecha_inicio||''' and a.fecha_apertura <= '''|| fecha_fin||''' group by 1 INTO temp tmp_maecred_crd with no log;" >> '|| TRIM(v_ruta)||'queryAperturas.sql';
	system v_sql2;
	LET v_sql2 = ' echo "CREATE INDEX idx_maecred_crd ON tmp_maecred_crd (fecha_apertura);" >> '|| TRIM(v_ruta)||'queryAperturas.sql';
	system v_sql2;
	LET v_sql1 = ' echo "UNLOAD TO '||TRIM(v_ruta)||'Aperturas.unl';
	LET v_sql2 = ' select to_char(a.fecha_apertura,''%d-%m-%Y''),a.TARJETA_CREDITO_BANCOPPEL_VISA,a.TARJETA_CREDITO_BANCOPPEL_ORO, a.TARJETA_CREDITO_BANCOPPEL_PLATINUM, a.ANTICIPO_NOMINA,b.DIRECTO_NOMINA,b.PRESTAMO_FLEXIBLE,b.PRESTAMO_PERSONAL_BANCOPPEL_24,b.PRESTAMO_PERSONAL_BANCOPPEL_18,b.PRESTAMO_PERSONAL_BANCOPPEL,b.REESTRUCTURA_TARJETA_CREDITO from tmp_maecred a full outer join tmp_maecred_crd b on a.fecha_apertura=b.fecha_apertura order by 1;" >>'|| TRIM(v_ruta)||'queryAperturas.sql';

	LET v_sql = TRIM(v_sql1)|| v_sql2;
	system v_sql;
	LET v_sql = "dbaccess bdicred "||TRIM(v_ruta)||"queryAperturas.sql";
	system v_sql;
	/*  FIN APERTURAS  */
	
	/*  DISPOSICIONES  */
	LET v_sql1 = ' echo "UNLOAD TO '||TRIM(v_ruta)||'Disposiciones.unl';
    LET v_sql2 = ' select ''Ventanilla'' as Ventanilla,to_char(fecha_mov,''%d-%m-%Y''),sum(case when num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA, sum(case when num_producto = ''7000'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_PLATINUM,'||
	'sum(case when num_producto = ''8100'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_ORO from bdicred:sd_movhis where empresa = ''001'' and fecha_mov >= '''||fecha_inicio||''' and fecha_mov <= '''|| fecha_fin||''' and codigo_fun in (''002'') and codigo_ref in (50,60) and reversado = ''N'' and num_producto in(''6001'',''7000'',''8100'') group by 1,2'||
	' union all select ''Cajeros'' as Cajeros,to_char(fecha_mov,''%d-%m-%Y''), sum(case when num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA, sum(case when num_producto = ''7000'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_PLATINUM,'
	||'sum(case when num_producto = ''8100'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_ORO from bdicred:sd_movhis where empresa = ''001'' and fecha_mov >='''|| fecha_inicio ||''' and fecha_mov <= '''|| fecha_fin||''' and codigo_fun in (''002'') and codigo_ref in (30,40,41,42,61,62,63,64) and reversado = ''N'' and num_producto in(''6001'',''7000'',''8100'') group by 1,2'||
	' union all select ''Corresponsales'' as Corresponsales,to_char(fecha_mov,''%d-%m-%Y''), sum(case when num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA,  sum(case when num_producto = ''7000'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_PLATINUM, sum(case when num_producto = ''8100'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_ORO from bdicred:sd_movhis a where a.empresa=''001'' and'||
	' a.reversado = ''N'' and codigo_fun =''002'' and codigo_ref in (109,110) and a.num_producto in(''6001'',''7000'',''8100'') and a.fecha_mov >= '''|| fecha_inicio ||''' and fecha_mov <= '''||fecha_fin||''' group by 1,2 union all select ''Pos'' as Pos,to_char(fecha_mov,''%d-%m-%Y''), sum(case when num_producto = ''6001'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_VISA,'||
	'sum(case when num_producto = ''7000'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_PLATINUM,sum(case when num_producto = ''8100'' then 1 else 0 end) TARJETA_CREDITO_BANCOPPEL_ORO from bdicred:sd_movhis where empresa = ''001'' and fecha_mov >= '''|| fecha_inicio ||''' and fecha_mov <= '''|| fecha_fin||''' and codigo_fun =''002'' and codigo_ref in (37) and reversado = ''N'' and num_producto in (''6001'',''7000'',''8100'') group by 1,2 order by 1,2;" >' ||TRIM(v_ruta)||'queryDisposiciones.sql';
	LET v_sql = TRIM(v_sql1) || v_sql2;
	system v_sql;
	LET v_sql = "dbaccess bdicred "||TRIM(v_ruta)||"queryDisposiciones.sql";
	system v_sql;
	/*  FIN DISPOSICIONES  */
	
	
	/*  ANTICIPO NOMINA    */
	LET v_sql2 = ' echo "UNLOAD TO '||TRIM(v_ruta)||'AnticipoNomina.unl';
    LET v_sql1 = ' select ''Anticipo de Nomina'', to_char(fecha_mov,''%d-%m-%Y''), count(*) from bdicred:sd_movhis a inner join bdicred:sd_transfun b on a.codigo_fun=b.codigo_fun and a.codigo_ref=b.codigo_ref where fecha_mov >='''||fecha_inicio||''' and fecha_mov <= '''||fecha_fin||''' and a.codigo_fun =''002'' and a.codigo_ref in (111) and reversado=''N'' group by 1,2 order by 1,2;" >'||TRIM(v_ruta)||'queryAnticipoNomina.sql';
	LET v_sql = TRIM(v_sql2) || v_sql1;
	system v_sql;
	LET v_sql = "dbaccess bdicred "||TRIM(v_ruta)||"queryAnticipoNomina.sql";
	system v_sql;
	/*  FIN ANTICIPO NOMINA  */
	
	/*	CONSTRUCCION DEL ARCHIVO SOLICITUDES*/
	LET v_sql1='awk ''BEGIN {FS="|"; printf "%10s" "%5s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%15s" "%2s" "%16s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%8s" "%4s\n","Fecha", "|","TDC Bancoppel Visa","|","TDC Bancoppel Oro", "|","TDC Bancoppel Platinum","|","Directo Nomina","|","Anticipo Nomina", "|","Prestamo Flexible","|","PP Bancoppel 24","|","PP Bancoppel 18","|","PP Bancoppel","|","Reestructura TDC","|","Tarj. Coppel","|","Total","|"}{sumVisa+=$2;sumOro+=$3;sumPlat+=$4;sumDN+=$3;sumAN+=$4;sumPF+=$5;sumB24+=$6;sumB18+=$7;sumB+=$8;sumRees+=$9;sumCopp+=$10;total=$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12;totalT+=total;printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%15s" "%2s" "%16s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n",$1,"|",$2,"|","0","|","0","|",$3,"|",$4,"|",$5,"|",$6,"|",$7,"|",$8,"|",$9,"|",$10,"|",total, "|"}END {printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%15s" "%2s" "%16s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n", "Total" , "|" , sumVisa,"|", "0","|","0","|",sumDN,"|",sumAN,"|",sumPF,"|",sumB24,"|",sumB18,"|",sumB,"|",sumRees,"|",sumCopp,"|",totalT,"|"} END {avgVisa = sumVisa/(NR);avgOro=sumOro/(NR);avgPlat=sumPlat/(NR);avgDN=sumDN/(NR);avgAN=sumAN/(NR);avgPF=sumPF/(NR);avgB24=sumB24/(NR);avgB18=sumB18/(NR);avgB=sumB/(NR);avgRees=sumRees/(NR);avgCopp=sumCopp/(NR); avgTotal=totalT/NR;printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%15s" "%2s" "%16s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n","Promedio","|",avgVisa,"|","0","|","0" ,"|",avgDN,"|",avgAN,"|",avgPF,"|",avgB24,"|",avgB18,"|",avgB,"|",avgRees,"|",avgCopp,"|",avgTotal,"|"}'' '||TRIM(v_ruta)||"Solicitudes.unl >> "||TRIM(v_ruta)||"reporte_indicadores.txt;";
	LET v_sql2 =  'if [ "`wc -l '||TRIM(v_ruta)||'Solicitudes.unl | awk ''{print $1}''`" -gt "0" ]; then ' ||
		'echo "SOLICITUDES del periodo:\n " > '||TRIM(v_ruta)||'reporte_indicadores.txt;'||
		TRIM(v_sql1)||
		'else'||
		' echo "Sin registros de Solicitudes para el periodo.\n" > '||TRIM(v_ruta)|| 'reporte_indicadores.txt; '||
		'fi';
	SYSTEM v_sql2;
	/*	FIN CONSTRUCCION DEL ARCHIVO SOLICITUDES*/
	
	/*	CONSTRUCCION DEL ARCHIVO APERTURAS*/
	LET v_sql1='awk ''BEGIN {FS="|"; printf "%10s" "%5s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%16s" "%2s" "%15s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%8s" "%4s\n","Fecha", "|","TDC Bancoppel Visa","|","TDC Bancoppel Oro", "|","TDC Bancoppel Platinum","|","Anticipo Nomina","|","Directo Nomina","|","Prestamo Flexible","|","PP Bancoppel 24","|","PP Bancoppel 18","|","PP Bancoppel","|","Reestructura TDC","|","Tarj. Coppel","|","Total","|"}{sumVisa+=$2;sumOro+=$3;sumPlat+=$4;sumDN+=$5;sumAN+=$6;sumPF+=$7;sumB24+=$8;sumB18+=$9;sumB+=$10;sumRees+=$11;sumCopp+=$12;total=$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12;totalT+=total;printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%16s" "%2s" "%15s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n",$1,"|",$2,"|",$3,"|",$4,"|",$5,"|",$6,"|",$7,"|",$8,"|",$9,"|",$10,"|",$11,"|","0","|",total,"|"} END {printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%16s" "%2s" "%15s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n","Total" , "|" , sumVisa,"|", sumOro,"|",sumPlat,"|",sumDN,"|",sumAN,"|",sumPF,"|",sumB24,"|",sumB18,"|",sumB,"|",sumRees,"|",sumCopp,"|",totalT,"|"}END {avgVisa = sumVisa/(NR);avgOro=sumOro/(NR);avgPlat=sumPlat/(NR);avgDN=sumDN/(NR);avgAN=sumAN/(NR);avgPF=sumPF/(NR);avgB24=sumB24/(NR);avgB18=sumB18/(NR);avgB=sumB/(NR);avgRees=sumRees/(NR);avgCopp=sumCopp/(NR); avgTotal=totalT/NR;printf "%12s" "%3s" "%19s" "%2s" "%18s" "%2s" "%23s" "%2s" "%16s" "%2s" "%15s" "%2s" "%18s" "%2s" "%16s" "%2s" "%16s" "%2s" "%13s" "%2s" "%17s" "%2s" "%13s" "%2s" "%10s" "%2s\n","Promedio","|",avgVisa ,"|", avgOro ,"|", avgPlat,"|",avgDN,"|",avgAN,"|",avgPF,"|",avgB24,"|",avgB18,"|",avgB,"|",avgRees,"|",avgCopp,"|",avgTotal,"|"}'' '||TRIM(v_ruta)||"Aperturas.unl >> "||TRIM(v_ruta)||"reporte_indicadores.txt;";
	LET v_sql2 = 'if [ "`wc -l ' ||TRIM(v_ruta)||'Aperturas.unl | awk ''{print $1}''`" -gt "0" ]; then ' ||
		'echo "\nAPERTURAS del periodo:\n " >> '||TRIM(v_ruta)||'reporte_indicadores.txt;'||
		TRIM(v_sql1)||
		'else'||
		' echo "Sin registros de Aperturas para el periodo.\n" >>'||TRIM(v_ruta)||'reporte_indicadores.txt; '||
		'fi';
	SYSTEM v_sql2;
	/*	FIN CONSTRUCCION DEL ARCHIVO APERTURAS*/
	
	/*	CONSTRUCCION DEL ARCHIVO DISPOSICIONES*/
	LET v_sql1= 'awk ''BEGIN {FS="|";printf "%10s" "%7s" "%9s" "%6s" "%9s" "%7s" "%12s" "%6s" "%8s" "%6s\n","Canal","|","Fecha","|","TDC","|","Platino","|","Oro","|"}{sumTDC+=$3;sumPlat+=$4;sumOro+=$5;if($1=="Cajeros"){sumCajTDC+=$3;sumCajPlat+=$4;sumCajOro+=$5;regCaj+=1}else if($1=="Corresponsales"){sumCorrTDC+=$3;sumCorrPlat+=$4;sumCorrOro+=$5;regCorr+=1;}else if ($1=="Pos"){sumPosTDC+=$3;sumPosPlat+=$4;sumPosOro+=$5;regPos+=1;} else if($1=="Ventanilla"){sumVenTDC+=$3;sumVenPlat+=$4;sumVenOro+=$5;regVen+=1};printf "%15s" "%2s" "%13s" "%2s" "%14s" "%2s" "%16s" "%2s" "%12s" "%2s\n",$1,"|",$2,"|",$3,"|",$4,"|",$5,"|"}END{avgTDC=sumTDC/(NR);avgPlat=sumPlat/(NR);avgOro=sumOro/(NR);printf "%15s" "%2s" "%13s" "%2s" "%14s" "%2s" "%16s" "%2s" "%12s" "%2s\n","Total","|"," ","|",sumTDC,"|",sumPlat,"|",sumOro,"|"}END {printf"%13s" "%4s" "%15s" "%2s" "%16s" "%2s" "%17s" "%2s" "%12s" "%2s" "%14s" "%2s" "%13s" "%2s\n" ,"Canal","|","Total TDC","|","Promedio TDC","|","Total Platino","|","Promedio Platino","|","Total Oro","|","Promedio Oro","|"}END {if(regCorr==0){regCorr=1};avgCorTDC =sumCorrTDC/(regCorr);avgCorPlat=sumCorrPlat/(regCorr);avgCorrOro=sumCorrOro/(regCorr);printf "%15s" "%2s" "%15s" "%2s" "%16s" "%2s" "%17s" "%2s" "%16s" "%2s" "%14s" "%2s" "%13s" "%2s\n","Corresponsales","|",sumCorrTDC,"|",avgCorTDC,"|",sumCorrPlat,"|",avgCorPlat,"|",sumCorrOro,"|",avgCorrOro,"|"} END {if(regCaj==0){regCaj=1};avgCajTDC=sumCajTDC/(regCaj);avgCajPlat=sumCajPlat/(regCaj);avgCajOro=sumCajOro/(regCaj);printf"%15s" "%2s" "%15s" "%2s" "%16s" "%2s" "%17s" "%2s" "%16s" "%2s" "%14s" "%2s" "%13s" "%2s\n","Cajeros","|",sumCajTDC,"|",avgCajTDC,"|",sumCajPlat,"|",avgCajPlat,"|",sumCajOro,"|",avgCajOro,"|"}END {if(regPos==0){regPos=1};avgPosTDC=sumPosTDC/(regPos);avgPosPlat=sumPosPlat/(regPos);avgPosOro=sumPosOro/(regPos);printf "%15s" "%2s" "%15s" "%2s" "%16s" "%2s" "%17s" "%2s" "%16s" "%2s" "%14s" "%2s" "%13s" "%2s\n" ,"Pos","|",sumPosTDC,"|",avgPosTDC,"|",sumPosPlat,"|",avgPosPlat,"|",sumPosOro,"|",avgPosOro,"|"}END{if(regVen==0){regVen=1};avgVenTDC=sumVenTDC/(regVen);avgVenPlat=sumVenPlat/(regVen);avgVenOro=sumVenOro/(regVen);printf"%15s" "%2s" "%15s" "%2s" "%16s" "%2s" "%17s" "%2s" "%16s" "%2s" "%14s" "%2s" "%13s" "%2s\n" ,"Ventanilla","|",sumVenTDC,"|",avgVenTDC,"|",sumVenPlat,"|",avgVenPlat,"|",sumVenOro,"|",avgVenOro,"|"}'' '||TRIM(v_ruta)||"Disposiciones.unl >> "||TRIM(v_ruta)||"reporte_indicadores.txt;";
	LET v_sql2 = 'if [ "`wc -l '||TRIM(v_ruta)||'Disposiciones.unl | awk ''{print $1}''`" -gt "0" ];then ' ||
		'echo "\nDISPOSICIONES del periodo:\n " >>'||TRIM(v_ruta)||'reporte_indicadores.txt;'||
		TRIM(v_sql1)||
		'else'||
		' echo "Sin registros de Disposiciones para el periodo.\n" >>'||TRIM(v_ruta)||'reporte_indicadores.txt; '||
		'fi';
	SYSTEM v_sql2;
	/*	FIN CONSTRUCCION DEL ARCHIVO DISPOSICIONES*/
	
	/*	CONSTRUCCION DEL ARCHIVO ANTICIPO*/
	LET v_sql1= 'awk ''BEGIN {FS="|"; printf "%14s" "%6s" "%9s" "%5s" "%7s" "%3s\n","Producto", "|","Fecha","|","Total","|"}{suma+=$3; printf "%18s" "%2s" "%12s" "%2s" "%8s" "%2s\n",$1,"|",$2,"|",$3,"|"}END {printf "%18s" "%2s" "%12s" "%2s" "%8s" "%2s\n","Total","|", " ","|",suma, "|"}END {avgTotal= suma/(NR); printf "%18s" "%2s" "%12s" "%2s" "%8s" "%2s\n","Promedio","|", " ","|",avgTotal, "|"}'' ' ||TRIM(v_ruta)||"AnticipoNomina.unl >> " ||TRIM(v_ruta)||"reporte_indicadores.txt;";
	LET v_sql2 = 'if [ "`wc -l '||TRIM(v_ruta)||'AnticipoNomina.unl | awk ''{print $1}''`" -gt "0" ]; then ' ||
		'echo "\nANTICIPO del periodo:\n " >> '||TRIM(v_ruta)||'reporte_indicadores.txt;'||
		TRIM(v_sql1)||
		'else'||
		' echo "Sin registros de Anticipo Nomina para el periodo.\n" >>' ||TRIM(v_ruta)||'reporte_indicadores.txt; '||
		'fi';
	SYSTEM v_sql2;
	/*	FIN CONSTRUCCION DEL ARCHIVO ANTICIPO*/
	
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'querySolicitudes.sql';
	SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'queryAperturas.sql';
	SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'queryDisposiciones.sql';
    SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'queryAnticipoNomina.sql';
    SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'Solicitudes.unl';
    SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'Aperturas.unl';
	SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'Disposiciones.unl';
    SYSTEM wdir;
	LET wdir = 'rm -f ' || TRIM(v_ruta)|| 'AnticipoNomina.unl';
	SYSTEM wdir;

END

RETURN v_codret;
END PROCEDURE
DOCUMENT
'MODIFICACION: Se agrego validacion en disposiciones cuando no existan registros',
'AUTOR: Cinthia Aguilar',
'FECHA: MAYO 2024';

CREATE PROCEDURE "informix".sp_calculo_cat_publicidad_rep() 
    RETURNING CHAR(5) AS CodRet, CHAR(50) AS RUTA;     
    
    DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet 	    CHAR(5);
	
	/* Variables para generar el reporte */
	DEFINE cCmd1								CHAR(2500);
	DEFINE pRutaDescarga						CHAR(100);
	DEFINE cRutaGral							CHAR(150);
	DEFINE bInTransaction						BOOLEAN;
	DEFINE ven_transacc							SMALLINT;
	DEFINE cSql									CHAR(2500);
	DEFINE dFechaHoy							DATE;
	DEFINE cFechaArchivo						CHAR(15);
	DEFINE cNombreArchivo						CHAR(50);
	
	DEFINE vProducto        CHAR(4);
DEFINE dlimite_credito     DECIMAL;
    DEFINE cnum_producto       CHAR(4);
DEFINE vcat    DECIMAL;
    /*-------------------------------------------------------*/
    
    LET cCodRet 	   = '00000';
    	/* Variables para generar el reporte */
	LET cCmd1								= '';
	LET pRutaDescarga						= '/resplogifx/archivoscredito/'; 
    	--LET pRutaDescarga                       = '/ifxsif01/aastorga/archivoscredito/'; 
	LET cRutaGral							= '';
	LET bInTransaction						= 'f';
	LET ven_transacc						= 0;
	LET cSql								= '';
	LET dFechaHoy							= '';
	LET cFechaArchivo						= '';
	LET cNombreArchivo						= '';
    /*-------------------------------------------------------*/
	
    BEGIN
        
		/* En caso de error regresa el codigo correspondiente, y se agregan excepciones */
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cRutaGral;
			END IF;
		END EXCEPTION;
	
	    -- SET DEBUG FILE TO '/ifxsif01/aastorga/sp_calculo_cat_publicidad_rep.out';
        -- TRACE ON;
		/*-------------------------------------------------------*/
        /* GENERAR REPORTES POR PRODUCTO */
		LET dFechaHoy = TODAY;
		LET cFechaArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy);

        FOREACH WITH HOLD
            SELECT producto 
            INTO vProducto 
            FROM sd_calc_cat_publi
	    GROUP BY producto 
	    ORDER BY producto DESC
        
            
              -- Iniciar el bucle para cada producto
            LET cNombreArchivo  = TRIM(vProducto)||'_CAT_'||TRIM(cFechaArchivo);
            LET cRutaGral       = TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.txt';
                               
            LET cCmd1 = "SELECT  "
                    ||"scci.numcte, "
                    ||"scci.num_credito, "
                    ||"YEAR(scci.fecha_apertura)||'-'||LPAD(MONTH(scci.fecha_apertura),2,'0')||'-'||LPAD(DAY(scci.fecha_apertura),2,'0'), "
                    ||"scci.num_producto,       "
                    ||"scci.limite_credito ,    "
                    ||"scci.linea_autorizada ,  "
                    
                    ||"scch.tasa , "
                    ||"scch.anualidad ,         "
                    ||"scch.comision ,          "
                    ||"scch.catorigina *100 "
                    
                    ||"FROM bdicred:sd_calc_cat_insumos AS scci "
                    ||"INNER JOIN sd_calc_cat_historico AS scch  "     
                    ||"ON scci.num_producto = scch.producto "
                    ||"AND scci.limite_credito= scch.limite_credito "
                    ||"WHERE num_producto = " ||  TRIM(vProducto) ||"  ; ";

            -- Se crea el query
            LET cSql = '';
            LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query_sd_calc_cat_insumos_'||TRIM(vProducto)||'.sql';
            SYSTEM TRIM(cSql);
            
            -- Asignacion de permisos de acceso
            LET cSql = '';
            LET cSql = 'chmod 777 '||TRIM(pRutaDescarga)||'query_sd_calc_cat_insumos_'||TRIM(vProducto)||'.sql';
            SYSTEM TRIM(cSql);	
            
            -- Se ejecuta el query
            LET cSql = '';
            LET cSql = 'dbaccess bdicred '||TRIM(pRutaDescarga)||'query_sd_calc_cat_insumos_'||TRIM(vProducto)||'.sql';
            SYSTEM TRIM(cSql);
            
            -- Se elimina el query
            LET cSql = '';
            LET cSql = 'rm -rf '||TRIM(pRutaDescarga)||'query_sd_calc_cat_insumos_'||TRIM(vProducto)||'.sql';
            SYSTEM TRIM(cSql);
            
            -- Asignacion de permisos de acceso
            LET cSql = '';
            LET cSql = 'chmod 777 '||TRIM(cRutaGral);
            SYSTEM TRIM(cSql);

            RETURN cCodRet,cRutaGral WITH RESUME;
           
        END FOREACH; -- Fin del bucle para cada producto

        /* GENERAR REPORTE CAT_PUBLICIDAD */
        LET cNombreArchivo = 'CAT_PUBLICIDAD_'||TRIM(cFechaArchivo);
	
        LET cCmd1 = " SELECT producto , cat_origina FROM sd_calc_cat_publi; ";
        LET cRutaGral       = TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.txt';

                
        -- Se crea el query
        LET cSql = '';
        LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query_sd_calc_cat_publit.sql';
        SYSTEM TRIM(cSql);
        
        -- Asignacion de permisos de acceso
        LET cSql = '';
        LET cSql = 'chmod 777 '||TRIM(pRutaDescarga)||'query_sd_calc_cat_publit.sql';
        SYSTEM TRIM(cSql);	
        
        -- Se ejecuta el query
        LET cSql = '';
        LET cSql = 'dbaccess bdicred '||TRIM(pRutaDescarga)||'query_sd_calc_cat_publit.sql';
        SYSTEM TRIM(cSql);
        
        --Se elimina el query
        LET cSql = '';
        LET cSql = 'rm -rf '||TRIM(pRutaDescarga)||'query_sd_calc_cat_publit.sql';
        SYSTEM TRIM(cSql);
        
        -- Asignacion de permisos de acceso
        LET cSql = '';
        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
        SYSTEM TRIM(cSql);
        
        RETURN cCodRet,cRutaGral;
        
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento que Genera Reporte con los Clientes y el CAT actualizado', 
'AUTOR : Adrian Curiel',
'Folio: RQM 10 1491 Automatizacion Calculo de CAT publicitario',
'Solicita: Christian Yair Rojas Velazquez',
'FECHA : 25/01/2024',

'MODIFICO :Jorge Arturo Astorga Martinez',
'DESCRIPCION:  Se agrego agrupacion para una busqueda indexada.',
'FECHA : 14/05/2024',

'MODIFICO :Jorge Arturo Astorga Martinez',
'DESCRIPCION:  Se forzo el formato AAAA-MM-DD en la propiedad fecha de apertura.',
'FECHA : 18/06/2024';

CREATE PROCEDURE "informix".altatarcred(pempresa CHAR(3),
					pnum_credito CHAR(20),
					pnumtarjeta	CHAR(20),
					pnumcte	CHAR(20),
					pexpiracion	DATE,
					ptipo_tar CHAR(1),
					pstatus	CHAR(1),
					plimite_aut	money (14,2),
					pprodtarjeta CHAR(3),
					pnombre	CHAR(104))

----------DATOS QUE REGRESA
RETURNING CHAR(5) AS CodigoRetorno;

--DECLARACION DE VARIABLES
DEFINE vcodret		CHAR(5);
DEFINE vsiguiente	INTEGER;
DEFINE vexiste		INTEGER;
DEFINE vsqlerr		INTEGER;
DEFINE vtarjeta     CHAR(20);
DEFINE vlExpiracion DATE;
DEFINE cNumProd		CHAR(3);

--INICIALIZANDO VARIABLES
LET vcodret    = "";
LET vsiguiente = 0;
LET vexiste    = 0;
LET vsqlerr    = 0;
LET vtarjeta   = "";
LET cNumProd   = "";

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- SET DEBUG FILE TO '/respaldosbd/mario/altatarcred.out';
	-- SET DEBUG FILE TO '/pisa/pisabanco/altatarcred.out';
	-- TRACE ON;

	IF pnum_credito IS NULL OR pnum_credito = "" THEN
		LET vcodret = "100";
		RETURN vcodret;
	END IF;

	IF pnumtarjeta IS NULL OR pnumtarjeta = "" THEN
		LET vcodret = "101";
		RETURN vcodret;
	END IF;

	IF pnumcte IS NULL OR pnumcte = "" THEN
		LET vcodret = "102";
		RETURN vcodret;
	END IF;

	SELECT num_tarjeta INTO vtarjeta
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_tarjeta = pnumtarjeta;

	IF vtarjeta IS NOT NULL THEN
		LET vcodret = "430";
		RETURN vcodret;
	END IF

	LET vcodret = "000";

	SELECT max(secuencia) + 1 INTO vsiguiente
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_credito = pnum_credito;

	IF vsiguiente IS NULL THEN
		LET vsiguiente = 1;
	END IF;

	--fmj enero 2012, Fecha Expiracion al dia ultimo de mes
	LET vlExpiracion = DATE(mdy(MONTH(pexpiracion), '01', YEAR(pexpiracion)) + 1 units MONTH) - 1; 

	--Se valida que el numero de crédito y tarjeta sean de 12 y 16 digitos respectivamente y solo sean numeros
	IF LENGTH(pnum_credito) = 12 AND LENGTH(pnumtarjeta) = 16 AND bdinteg:"informix".val_num(pnum_credito) AND bdinteg:"informix".val_num(pnumtarjeta) THEN
		INSERT INTO bdicred:"informix".sd_tarjeta
		(empresa,num_credito,secuencia,num_tarjeta,numcte,expiracion,tipo_tarjeta,status_tar,limite_aut,prodtarjeta,nombre)
		VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),pprodtarjeta,pnombre);
	ELSE
		LET vcodret = "242";
		RETURN vcodret;	
	END IF

	SELECT 1 INTO vexiste
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_credito = pnum_credito
	AND numcte = pnumcte AND num_tarjeta = pnumtarjeta;

	IF vexiste IS NULL THEN
		LET vcodret = "104";
	ELSE
	
	
		/*SELECT distinct codproductotarjeta INTO cNumProd
		FROM intercard:"informix".tipotarjeta
		WHERE bin = SUBSTR(pnumtarjeta,1,6);*/
		
		SELECT t.codproductotarjeta INTO cNumProd
		FROM intercard:"informix".tipotarjeta t, intercard:"informix".lote l, intercard:"informix".tarjeta tar
		WHERE t.clave_tipotarjeta = l.clave_tipotarjeta
		AND tar.numerolote = l.numerolote
		AND bin = SUBSTR(pnumtarjeta,1,6)
		AND tar.numtarjeta =pnumtarjeta;
		
		
		IF NVL(cNumProd,'') = '' THEN
		
			SELECT LIMIT 1 TRIM(num_prod) INTO cNumProd
			FROM bdicred:"informix".sd_segmentos				
			WHERE empresa = '001' 
			AND limite_max >= NVL(plimite_aut,0) 
			AND limite_min <= NVL(plimite_aut,0);

			IF NVL(cNumProd,'') = '' THEN
				LET vcodret = "001";
			END IF
			
		END IF
		
		IF vcodret = "000" THEN
		
			UPDATE intercard:"informix".tarjeta
			SET codproductotarjeta = cNumProd
			WHERE numtarjeta = TRIM(pnumtarjeta);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET vcodret= "000";
			END IF
			
		END IF
	END IF

	RETURN vcodret;
END
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDURE QUE INSERTA EN LA TABLA sd_tarjeta, LOS DATOS PRINCIPALES DE LA TDC, ACTUALIZA LA BD INTERCARD',
'CON EL PRODUCTO DE LA SD_SEGMENTOS',
'FECHA DE MODIFICACIÓN: 07-12-2012',
'BASE DE DATOS: BDICRED',
'MODIFICÓ: RIGOBERTO GONZALEZ',
'VERSION: 20121207.1659',
'---------------------------------------------------------------------------------------------------------------------',
'Descripcion: Se agrega validacion para que consulte el numero de producto de la tabla intercard:"informix".tipotarjeta',
'Fecha: 22-02-2018',
'Modifico: Mario Gallardo',
'Folio: 351';

CREATE PROCEDURE "informix".altatarcred_web(pempresa CHAR(3),
					pnum_credito CHAR(20),
					pnumtarjeta	CHAR(20),
					pnumcte	CHAR(20),
					pexpiracion	DATE,
					ptipo_tar CHAR(1),
					pstatus	CHAR(1),
					plimite_aut	money (14,2),
					pprodtarjeta CHAR(3),
					pnombre	CHAR(104))

----------DATOS QUE REGRESA
RETURNING CHAR(5) AS CodigoRetorno;

--DECLARACION DE VARIABLES
DEFINE vcodret		CHAR(5);
DEFINE vsiguiente	INTEGER;
DEFINE vexiste		INTEGER;
DEFINE vsqlerr		INTEGER;
DEFINE vtarjeta     CHAR(20);
DEFINE vlExpiracion DATE;
DEFINE cNumProd		CHAR(3);

--INICIALIZANDO VARIABLES
LET vcodret    = "";
LET vsiguiente = 0;
LET vexiste    = 0;
LET vsqlerr    = 0;
LET vtarjeta   = "";
LET cNumProd   = "";

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- SET DEBUG FILE TO '/respaldosbd/mario/altatarcred.out';
	-- TRACE ON;

	IF pnum_credito IS NULL OR pnum_credito = "" THEN
		LET vcodret = "00100";
		RETURN vcodret;
	END IF;

	IF pnumtarjeta IS NULL OR pnumtarjeta = "" THEN
		LET vcodret = "00101";
		RETURN vcodret;
	END IF;

	IF pnumcte IS NULL OR pnumcte = "" THEN
		LET vcodret = "00102";
		RETURN vcodret;
	END IF;

	SELECT num_tarjeta INTO vtarjeta
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_tarjeta = pnumtarjeta;

	IF vtarjeta IS NOT NULL THEN
		LET vcodret = "00430";
		RETURN vcodret;
	END IF

	LET vcodret = "00000";

	SELECT max(secuencia) + 1 INTO vsiguiente
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_credito = pnum_credito;

	IF vsiguiente IS NULL THEN
		LET vsiguiente = 1;
	END IF;

	--fmj enero 2012, Fecha Expiracion al dia ultimo de mes
	LET vlExpiracion = DATE(mdy(MONTH(pexpiracion), '01', YEAR(pexpiracion)) + 1 units MONTH) - 1; 

	--Se valida que el numero de crÃ©dito y tarjeta sean de 12 y 16 digitos respectivamente y solo sean numeros
	IF LENGTH(pnum_credito) = 12 AND LENGTH(pnumtarjeta) = 16 AND bdinteg:"informix".val_num(pnum_credito) AND bdinteg:"informix".val_num(pnumtarjeta) THEN
		INSERT INTO bdicred:"informix".sd_tarjeta
		(empresa,num_credito,secuencia,num_tarjeta,numcte,expiracion,tipo_tarjeta,status_tar,limite_aut,prodtarjeta,nombre)
		VALUES(pempresa,pnum_credito,vsiguiente,pnumtarjeta,pnumcte,vlExpiracion,ptipo_tar,pstatus,NVL(plimite_aut,0),pprodtarjeta,pnombre);
	ELSE
		LET vcodret = "00242";
		RETURN vcodret;	
	END IF

	SELECT 1 INTO vexiste
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa = pempresa AND num_credito = pnum_credito
	AND numcte = pnumcte AND num_tarjeta = pnumtarjeta;

	IF vexiste IS NULL THEN
		LET vcodret = "00104";
	ELSE
	
	
		--SELECT distinct codproductotarjeta INTO cNumProd
		--FROM intercard:"informix".tipotarjeta
		--WHERE bin = SUBSTR(pnumtarjeta,1,6);
		
		
		SELECT t.codproductotarjeta INTO cNumProd
		FROM intercard:"informix".tipotarjeta t, intercard:"informix".lote l, intercard:"informix".tarjeta tar
		WHERE t.clave_tipotarjeta = l.clave_tipotarjeta
		AND tar.numerolote = l.numerolote
		AND bin = SUBSTR(pnumtarjeta,1,6)
		AND tar.numtarjeta =pnumtarjeta;
		
		IF NVL(cNumProd,'') = '' THEN
		
			SELECT LIMIT 1 TRIM(num_prod) INTO cNumProd
			FROM bdicred:"informix".sd_segmentos				
			WHERE empresa = '001' 
			AND limite_max >= NVL(plimite_aut,0) 
			AND limite_min <= NVL(plimite_aut,0);

			IF NVL(cNumProd,'') = '' THEN
				LET vcodret = "00001";
			END IF
			
		END IF
		
		IF vcodret = "00000" THEN
		
			UPDATE intercard:"informix".tarjeta
			SET codproductotarjeta = cNumProd
			WHERE numtarjeta = TRIM(pnumtarjeta);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET vcodret= "00000";
			END IF
			
		END IF
	END IF

	RETURN vcodret;
END
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDURE QUE INSERTA EN LA TABLA sd_tarjeta, LOS DATOS PRINCIPALES DE LA TDC, ACTUALIZA LA BD INTERCARD',
'CON EL PRODUCTO DE LA SD_SEGMENTOS',
'FECHA DE MODIFICACIÃN: 07-12-2012',
'BASE DE DATOS: BDICRED',
'MODIFICÃ: RIGOBERTO GONZALEZ',
'VERSION: 20121207.1659',
'---------------------------------------------------------------------------------------------------------------------',
'Descripcion: Se agrega validacion para que consulte el numero de producto de la tabla intercard:"informix".tipotarjeta',
'Fecha: 22-02-2018',
'Modifico: Mario Gallardo',
'Folio: 351';

CREATE PROCEDURE "informix".sp_venta_cartera(pEmpresa char(3))
returning char (87);

--  Autor: Paul Ivan Quintero Varela.
--  Fecha: 05/03/2008.
--  Observaciones: Se creaÂ¡ un sp_para el proceso de la Venta de la Cartera.


--  Autor: Paul Ivan Quintero Varela.
--  Fecha: 18/12/2008.
--  Observaciones: Se modifica procedimiento para la solucion de la incidencia
--                 de la baja de cartera en relacion al rubro de reservas.


DEFINE cNumCredito                  Char(20);
DEFINE cNumCte                      Char(20);
DEFINE cNumProducto                 Char(4);
DEFINE dFecha                       Date;
DEFINE dpri_dia_mes					Date;
DEFINE ddia_corte				char(2);
DEFINE cFolio                       Char(16);
DEFINE cSucursal                    Char(4);
DEFINE cDivisa                      Char(2);
DEFINE vPeriodicidad                Char(1);
DEFINE vCalif_Riesgo                Char(2);
DEFINE vMontoLineaNoDispuesta       Decimal(16,2);
DEFINE vMontoVencidoExigible        Decimal(16,2);
DEFINE vMontoVencidoNoExigible      Decimal(16,2);
DEFINE vMontoVencidoPorCobrar       Decimal(14,2);
DEFINE vMontoReservado              Decimal(16,2);
DEFINE vCapitalVig                  Money(14,2);
DEFINE vCapitalVen                  Money(14,2);
--DEFINE pFecha                       Date;
DEFINE vCredito                     Char(20);
DEFINE vTotal                       Money(16,2);
DEFINE vPeriodo                     Char(1);
DEFINE vNum_Periodo                 Smallint;
DEFINE vInteres_venc                Money(16,2);
DEFINE vGrado                       Char(2);
DEFINE vProducto                    Char(4);
DEFINE vSucursal                    Char(4);
DEFINE vDivisa                      Char(2);
DEFINE vIntMora                     Decimal(14,2);
DEFINE vIvaIntMora                  Decimal(14,2);
DEFINE vPorcIva                     Decimal(14,2);
DEFINE vPorcIva_rees                Decimal(14,2);
DEFINE vImporteReserva              Money(16,2);
DEFINE vPorcentajeReserva           Decimal(14,2);
DEFINE vGrado_Aplicar               Char(2);
DEFINE vCalificacion                Char(2);
DEFINE vMontoExigyNoExig            Decimal(16,2);
DEFINE cEvaluaCC                    Char(1);
DEFINE vImporteReservaBuroCC        Money(16,2);
DEFINE vNvoPeriodo                  Smallint;
DEFINE vNvoPeriodo2                 Smallint;
DEFINE vNvoPeriodo3                 Smallint;
DEFINE vfechaini                    Date;
--DEFINE vfechafin                    Date;
DEFINE vcuotasvenc                  smallint;
DEFINE vtotal_dias                  smallint;
DEFINE vtotal_capitalizado          Money(16,2);
DEFINE vmonto_capitalizado          Money(16,2);
DEFINE vMontoCompara                Money(16,2);
DEFINE vcodigo_ref                  INTEGER;
DEFINE fechafinmesant               DATE;
DEFINE vencifinmes                  SMALLINT;
DEFINE vtarjeta                     CHAR(20);
DEFINE cproduto                     VARCHAR(3);

DEFINE CodRet              CHAR(5);
DEFINE Mensaje             CHAR(80);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE nRows               SMALLINT;

--- variables para procesar reestructuras SDFM 22/02/2012
DEFINE vMontoVencidoExigible_rees DECIMAL(16,2);
DEFINE vMontoVencidoNoExigible_rees DECIMAL(16,2);
DEFINE vInteresVencido DECIMAL(16,2);
DEFINE vInteresVencido_rees DECIMAL(16,2);
DEFINE vInteresVencido_ant DECIMAL(16,2);
DEFINE vIvaInteresVencido DECIMAL(16,2);
DEFINE vIvaInteresVencido_rees DECIMAL(16,2);
DEFINE vIvaInteresVencido_ant DECIMAL(16,2);
DEFINE vCapitalVig_rees DECIMAL(16,2);
DEFINE vCapitalVen_rees DECIMAL(16,2);
DEFINE cStatusCred          CHAR(02);
define dproxfechapago, dfechaproceso date;
DEFINE dfecha_vencto61 DATE;
DEFINE dfecha_vencto63 DATE;
DEFINE vFechaHoy            DATE;
DEFINE vNumCredito          Char(20);
DEFINE vNumCte              Char(20);
DEFINE vStatus              CHAR(2);
DEFINE vSecCred             SMALLINT;
DEFINE vFechaOtorga            DATE;
DEFINE vFechaVencCred            DATE;
DEFINE vFechaCancela            DATE;
DEFINE vFechaUltMod            DATE;
DEFINE vMontoDisp           DECIMAL(18,2);
DEFINE vLineaDisp           DECIMAL(18,2);
DEFINE vCancelPf            CHAR(1);
DEFINE vFechaUltPf          DATE;
DEFINE pEjecutivo       VARCHAR(8);
DEFINE cCodRet2         CHAR(6);
DEFINE cNumeroFolio         CHAR(16);
DEFINE COD_RET			VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE cCodRet      	CHAR(6);
DEFINE cErrorInfo   	VARCHAR(255,1);
DEFINE psaldoInteresTrasApoyo DECIMAL(14,2);
DEFINE psaldoIvaIntTrasApoyo DECIMAL(14,2);

---DECLARAR VARIABLES vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf 
---pEjecutivo,cCodRet2, cNumeroFolio,COD_RET,P_MENSAJE,cCodRet, cErrorInfo



-- Set debug file to '/RESPALDOSNEW/sp_Proceso_Venta_Cartera.out';
-- trace on;

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
     Rollback Work;
	 SET DEBUG FILE TO "Proceso_Venta_de_Cartera_Info.err";
      TRACE sql_err|| " * "||isam_err|| " * " ||error_info;
      LET CodRet = sql_err;
      RETURN CodRet|| ' ERROR en el proceso VENTA DE CARTERA ' || cNumCredito;
   END EXCEPTION;

--SET DEBUG FILE TO '/informix/sp_venta_cartera_v01.out';
--TRACE ON;

let vcodigo_ref = 0;

--- variables para procesar reestructuras SDFM 22/02/2012
LET vSucursal = '';
LET vMontoVencidoExigible_rees = 0;
LET vMontoVencidoNoExigible_rees = 0;
LET vInteresVencido = 0;
LET vInteresVencido_rees = 0;
LET vInteresVencido_ant = 0;
LET vIvaInteresVencido = 0;
LET vIvaInteresVencido_rees = 0;
LET vIvaInteresVencido_ant = 0;
LET vCapitalVig_rees = 0;
LET vCapitalVen_rees = 0;
LET cStatusCred = '';
let dproxfechapago = date(0);
let dfechaproceso   = date(0);
LET dfecha_vencto61 = DATE(0);
LET dfecha_vencto63 = DATE(0);
LET vFechaHoy               = '';

LET vNumCredito         ='';
LET vNumCte              ='';
LET vStatus              ='';
LET vSecCred             =0;
LET vFechaOtorga            =DATE(0);
LET vFechaVencCred           = DATE(0);
LET vFechaCancela           = DATE(0);
LET vFechaUltMod           = DATE(0);
LET vMontoDisp           = 0;
LET vLineaDisp           =0;
LET vCancelPf            ='';
LET vFechaUltPf          =DATE(0);
LET pEjecutivo       ='';
LET cCodRet2         ='';
LET cNumeroFolio        ='';
LET COD_RET			='';
LET P_MENSAJE		='';
LET cCodRet      	='';
LET cErrorInfo   	='';

LET psaldoInteresTrasApoyo  = 0;
LET psaldoIvaIntTrasApoyo = 0;

/*
Select fecha_hoy,fecha_hoy --Obtiene la Fecha del Dia
Into vfechafin,dFecha--, vult_hab_mes, vpri_hab_mes
*/
Select pri_dia_mes, fecha_hoy  --Obtiene la Fecha del Dia
Into dpri_dia_mes, dFecha--, vult_hab_mes, vpri_hab_mes
From bdicred:sd_fechas
Where empresa = pEmpresa;

-- temporal para pruebas
--let dFecha = mdy('02','28','2012');
-- temporal para pruebas

ForEach With hold
		
        Select num_credito, numcte, num_producto, status_cred
        Into cNumCredito, cNumCte, cNumProducto, cStatusCred
		From bdicred:sd_maecred
        where --empresa = pempresa and
         status_cred in  ('BT','E2' ,'E3')--VENCIDA TRASPASADA
        and id_unidad_prod = 1 --CREDITO BLOQUEADO
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
							where fechareporte = (Select max(fechareporte)
												  From bdicobranza:cb_rep_cart_quebrantar
												  where producto in ('6001','8100','7000','8500')--Se agregan productos (8100,7000)
												  )
							)
		union all
		Select num_credito, numcte, num_producto, status_cred
        From bdicred:sd_maecredcrd
        where --empresa = pempresa and
         id_origen = '1'
		and status_cred != 'CV'--CARTERA VENDIDA
        and num_producto = '6011'
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
		                     where fechareporte = (Select max(fechareporte)
													From bdicobranza:cb_rep_cart_quebrantar
													where producto = '6011'
												   )
						    )
        union all
		Select num_credito, numcte, num_producto, status_cred
		From bdicred:sd_maecredcrd
        where --empresa = pempresa and
         id_origen = '1'
		and status_cred != 'CV'
        and num_producto IN ('6300','7600','7700','6400','6800') ---> AGREGAR 6800 --AAME 20150622 RQM 09 393 Se contempla prestamos(7600,7700)
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
		                    where fechareporte = (Select max(fechareporte)
												  From bdicobranza:cb_rep_cart_quebrantar
												  where producto IN ('6300','7600','7700','6400','6800') ---> AGREGAR 6800 
												 )
							)
		
        Begin Work;

	 

	IF cNumProducto in ('6001','8100','7000','8500')THEN --Se agregan productos (8100,7000) 

        -- Se Replica la informacion de los creditos por Vender a la tabla bdicred:sd_maecred_vendida.
		
		
			--insert a la tabla duplicada de la original
        	--Insert into bdicred:sd_maecred_vendida
			Insert into bdicred:sd_maecred_vend_total(fecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo)
			--Select current, * From bdicred:sd_maecred Where empresa = pEmpresa and num_credito= cNumCredito;
			Select current,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo From bdicred:sd_maecred Where --empresa = pEmpresa and 
																											num_credito= cNumCredito;
			--insert a la tabla normal
			Insert into bdicred:sd_maecred_vendida
			Select current, * From bdicred:sd_maecred Where empresa = pEmpresa and num_credito= cNumCredito;
			
		-- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
		    Update bdicred:sd_maecred Set status_cred= 'CV' Where empresa = pEmpresa and num_credito= cNumCredito;

		-- Se Actualiza la fecha de proceso por estar bloqueados los creditos
		    Update bdicred:sd_maecredanexo Set fecha_proceso = current Where empresa=pEmpresa And num_credito= cNumCredito;

		-- Se realiza el Bloqueo de la tarjeta.
            foreach
                select num_tarjeta
                  into vtarjeta
                from bdicred:sd_tarjeta
                where --empresa=pEmpresa and
                   num_credito=cNumCredito
                  and tipo_tarjeta<>'0'
                  and status_tar <> 'C'

                  select codproductotarjeta
                    into cproduto
                  from intercard:tarjeta
                  where numtarjeta=vtarjeta;

                  execute procedure intercard:"informix".sp_cancelacion_tarjeta
                  (vtarjeta,cproduto,'informix') INTO CodRet, Mensaje;

                  if CodRet='001' or CodRet='002' then
                     LET CodRet = '000000';
                     LET Mensaje= " ";
                  end if;
            end foreach;

			Update bdicred:sd_tarjeta Set status_tar= 'C', limite_aut = 0, motivo = 'CV' Where empresa= pEmpresa And num_credito= cNumCredito and status_tar <> 'C';

		-- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
		    Insert into bdicred:sd_maesdos_vendida
			Select current, * From bdicred:sd_maesdos Where empresa=pEmpresa And num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        	Insert into bdicred:sd_amortiza_credito_vendida
			Select current, * From bdicred:sd_amortiza_credito Where empresa= pEmpresa And num_credito= cNumCredito and fecha_cuota >= date(0);

            SELECT
--                a.num_producto, c.fecha_hoy, a.sucursal, a.divisa, a.periodo_plazo, calificacion_riesgo,
                a.num_producto, a.sucursal, a.divisa, a.periodo_plazo, calificacion_riesgo,
                b.monto_otorgado - (b.sdo_capital + b.monto_vencido + b.mto_venc_trasp + b.cap_tras_no_venci),-- Se obtiene el monto de la LINEA DE CREDITO NO DISPUESTA
                (b.monto_vencido + b.Mto_venc_trasp), (b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig, b.monto_reservado,
                b.sdo_capital, b.sdo_cap_insoluto
            INTO
--                cNumProducto,dFecha, cSucursal, cDivisa, vPeriodicidad, vCalif_Riesgo,
                cNumProducto, cSucursal, cDivisa, vPeriodicidad, vCalif_Riesgo,
                vMontoLineaNoDispuesta,
                vMontoVencidoExigible, vMontoVencidoNoExigible,vInteresVencido, vMontoReservado,
                vCapitalVig, vCapitalVen
            FROM
--                sd_maecred a, sd_maesdos b, sd_fechas c, sd_definicion d,
                sd_maecred a, sd_maesdos b, sd_definicion d,
                bdinteg:si_sucursales e
            WHERE a.empresa        = pEmpresa
              AND a.num_credito      = cNumCredito
              AND a.bandera_ministra = 'M'
              AND b.empresa          = a.empresa
              AND b.num_credito      = a.num_credito
--              AND c.empresa          = a.empresa
              AND d.empresa          = a.empresa
              AND d.num_producto     = a.num_producto
              AND e.empresa			= a.empresa
              AND e.sucursal         = a.sucursal;

            If vMontoLineaNoDispuesta >= 0 Then
                -- Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA  
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 1,
                                "444", dFecha, vMontoLineaNoDispuesta, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING --generacion de moviientos y detale contable
                                CodRet, Mensaje;
            Else
                let vMontoLineaNoDispuesta = abs(vMontoLineaNoDispuesta);
                -- Saldo Negativo Inversa de la Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 2,
                                "444", dFecha, vMontoLineaNoDispuesta, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            End If;


                IF cStatusCred ='E2'  THEN
                    --IPCB: Crear trasnaccion E2
                     -- Por la venta de la cartera vencida EXIGIBLE
                        CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 71,--23,
                                    "444", dFecha, vMontoVencidoExigible, "CarVendida",
                                    cSucursal, cDivisa, "0000") RETURNING
                                    CodRet, Mensaje;
    
                    -- Por la venta de la cartera vencida NO EXIGIBLE
                        CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 72,--24,
                                    "444", dFecha, vMontoVencidoNoExigible, "CarVendida",
                                    cSucursal, cDivisa, "0000") RETURNING
                                    CodRet, Mensaje;
    
                    -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
                           CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 73,--25,
                                       "444", dFecha, vInteresVencido, "CarVendida",
                                       cSucursal, cDivisa, "0000") RETURNING
                                       CodRet, Mensaje;
                ELSE
                    -- Por la venta de la cartera vencida EXIGIBLE
                        CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 3,
                                    "444", dFecha, vMontoVencidoExigible, "CarVendida",
                                    cSucursal, cDivisa, "0000") RETURNING
                                    CodRet, Mensaje;
    
                    -- Por la venta de la cartera vencida NO EXIGIBLE
                        CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 4,
                                    "444", dFecha, vMontoVencidoNoExigible, "CarVendida",
                                    cSucursal, cDivisa, "0000") RETURNING
                                    CodRet, Mensaje;
    
                    -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
                         CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 5,
                                       "444", dFecha, vInteresVencido, "CarVendida",
                                       cSucursal, cDivisa, "0000") RETURNING
                                       CodRet, Mensaje;
                  END IF;
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias Moratorios

             --SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_ordi+mora_provi_cope-mora_sdo_cope_pag))
             SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
             INTO vIntMora
             FROM sd_amortiza_credito
             WHERE  empresa = pEmpresa
             AND num_credito = cNumCredito
             AND capital_status IN ("2","7","6");

             IF  vIntMora IS NULL OR  vIntMora < 0 THEN
                LET vIntMora = 0;
             END IF;

               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 6,
                           "444", dFecha, vIntMora , "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

        -- Iva Vencido por Cobrar
             Select
                Sum(iva_debe - iva_pagado)
             Into
                vMontoVencidoPorCobrar
             From
                sd_amortiza_credito
             Where empresa= pEmpresa
               And num_credito= cNumCredito
               and capital_status <> '5';


            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 7,
                           "444", dFecha, vMontoVencidoPorCobrar, "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias MORATORIOS

                    -- Se obtiene el iva de la sucursal
                    SELECT iva
                    INTO vPorcIva
                    FROM bdinteg:si_sucursales
                    WHERE empresa = pEmpresa
                    AND sucursal = cSucursal;

                    IF vPorcIva IS NULL THEN
                        LET vPorcIva=0;
                    END IF;

                 SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * vPorcIva)-mora_iva_pagado)
                 INTO vIvaIntMora
                 FROM sd_amortiza_credito
                 WHERE  num_credito = cNumCredito
                 AND empresa = pEmpresa
                 AND capital_status IN ("2","7","6")
                 AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

                 IF  (vIvaIntMora  IS NULL) OR (vIvaIntMora < 0) or (vIntMora <= 0) THEN
                        LET vIvaIntMora = 0;
                 END IF;

                CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 8,
                           "444", dFecha, vIvaIntMora, "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

        -- Proceso de la Calificacion de la Cartera Vendida
                    Select fecha_vencto
                    Into vfechaini
                    From bdicred:sd_maecredanexo
                    Where empresa     = pEmpresa
                    And	  num_credito = cNumCredito;

                    If Not vfechaini Is Null Then

                        LET vcuotasvenc = ((Year(dFecha) - Year(vfechaini)) * 12) + Month(dFecha) - Month(vfechaini);
                        if (day(dFecha) <= 20) then let vcuotasvenc = vcuotasvenc - 1; end if;

                        If vcuotasvenc Is Null Then
                            let vcuotasvenc = 0;
                        End If
                        If vcuotasvenc < 0 Then
                            let vcuotasvenc = 0;
                        End If
                    else
                        LET vcuotasvenc = 0;
                    End if

                    let fechafinmesant=date(mdy(month(dFecha),'01',year(dFecha))-1);

                    select num_periodos into vencifinmes
                    from bdicred:sd_histvalcon
                    where empresa=pEmpresa
                      and num_credito=cNumCredito
                      and fecha_alta=fechafinmesant;

                      if vencifinmes is null then let vencifinmes=0; end if;

                      IF vcuotasvenc>0 AND vcuotasvenc>vencifinmes THEN
                        LET vcuotasvenc=vencifinmes;
                      END IF;

                LET vTotal =  vCapitalVen + vInteresVencido;

    -- Procesa de la Calificacion
            /*
			-- Elimina el Movimiento Generado de la Calificacion anterior
			 --  DELETE FROM sd_movcalcval
			 --  WHERE empresa = pEmpresa;

			-- Elimina el Movimiento del Dia en Historico
			  -- DELETE FROM sd_histvalcon
			  -- WHERE empresa = pEmpresa and
              -- year(fecha_alta) = Year(pFecha) and
              -- month(fecha_alta) = Month(pFecha);
			*/
			-- Determina la Periodicidad del Credito
				IF UPPER(vPeriodicidad) = "S" THEN
						IF vcuotasvenc > 18 THEN
							LET vcuotasvenc = 18;
						END IF
				END IF

				IF UPPER(vPeriodicidad) = "Q" THEN
					IF vcuotasvenc > 13 THEN
						LET vcuotasvenc = 13;
					END IF
				END IF

				IF UPPER(vPeriodicidad) = "M" THEN
					IF vcuotasvenc > 9 THEN
						LET vcuotasvenc = 9;
					END IF
				END IF

			 -- Extrae el Numero de Periodos Vencidos
				SELECT porcentaje, grado, grado
				INTO vPorcentajeReserva, vGrado_Aplicar, vCalificacion
				FROM sd_porc_reserva
				WHERE empresa = pEmpresa and
					periodo = vPeriodicidad and
					num_periodo = vcuotasvenc and
					tipocredito = "01";

             -- No se toman los intereses en cuenta para creditos con mas de 1 pago vencido
				IF UPPER(vPeriodicidad) = "M" THEN
					IF vInteresVencido > 1 THEN
						LET vTotal = vTotal - vInteresVencido;
					END IF
				END IF

			-- Calcula el Importe de la Reserva
				LET vImporteReserva = vTotal * (vPorcentajeReserva / 100);

			-- Inserta informacion Calculada
				INSERT INTO sd_movcalcval  (empresa,
											num_credito,
											periodo,
											num_periodo,
											grado_riesgo,
											importe,
											porcentaje,
											imp_reservas,
											calificacion,
											fecha)
									VALUES (pEmpresa,
											cNumCredito,
											vPeriodicidad,
											vcuotasvenc,
											vGrado_Aplicar,
											vTotal,
											vPorcentajeReserva,
											vImporteReserva,
											vCalificacion,
											dFecha);


			  -- Actualiza Maestro de Credito Central
                                UPDATE sd_maecred
                                   SET calificacion_riesgo = vCalificacion
				                 WHERE empresa = pEmpresa
                                   And  num_credito = cNumCredito;

 			-- Graba Movimiento en Historico de Calificaciones
     			INSERT INTO sd_histvalcon (empresa,
	 									   num_credito,
										   fecha_alta,
										   calif_ant,
										   calif_actual,
										   porcentaje,
										   num_periodos,
										   importe,
										   importe_reserva)
								   VALUES (pEmpresa,
                                            cNumCredito,
										    dFecha,
										    vCalif_Riesgo,
										    vCalificacion,
										    vPorcentajeReserva,
										    vcuotasvenc,
										    vTotal,
										    vImporteReserva);


            -- Se Actualizan los saldos
               Update sd_maesdos
                  Set mto_venc_trasp=0, monto_vencido=0,
                      cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0,
                      sdo_capital=0, sdo_cap_insoluto=0, monto_otorgado = 0,
                      monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito;

            -- Se Actualizan las amortizaciones

               Update sd_amortiza_credito
                  Set capital_status = 5,
                      iva_pagado = iva_debe,
                      mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_provi_ordi = 0,
                      mora_provi_cope = 0,
                      capital_pagado  = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito
                   and (capital_status in ('2','7','6') or interes_debe <> 0);

      --FMV 23may13 Actualiza dias de atraso para el indicador de buro en tarjeta
              UPDATE "informix".sd_indicador_cred 
                 SET dias_atraso   = (dFecha - nvl(vfechaini,dFecha) + 1)
               WHERE num_credito   = cNumCredito
                 AND empresa       = pEmpresa;




	ELIF cNumProducto = '6011' THEN
        -- Se Replica la informacion de los creditos (REESTRUCTURA) por Vender a la tabla bdicred:sd_maecred_vendida.
        --INSERT INTO bdicred:sd_maecredcrd_vendida
		 INSERT INTO bdicred:sd_maecredcrd_vend_total(fecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo)
        --SELECT CURRENT, * FROM bdicred:sd_maecredcrd
		SELECT CURRENT,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo FROM bdicred:sd_maecredcrd
        WHERE --empresa = pEmpresa AND
           num_credito = cNumCredito;

		   
		--insert a la tabla original
		INSERT INTO bdicred:sd_maecredcrd_vendida
		SELECT CURRENT, * FROM bdicred:sd_maecredcrd
		WHERE empresa = pEmpresa AND num_credito = cNumCredito;
		 
		 
        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'CV'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


        -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6011           
        	SELECT fecha_vencto
			  INTO dfecha_vencto61
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto61,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;




        -- Se Actualiza la fecha de proceso por estar bloqueados los creditos
        UPDATE bdicred:sd_maecredanexocrd   
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;

        -- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito
        AND fecha_cuota >= date(1);

        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees
        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra IN ('M','Q')
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal;
     IF cStatusCred = 'E2' THEN --IPCB
        -- Por la venta de la cartera vencida EXIGIBLE       
		IF vMontoVencidoExigible_rees > 0 THEN
           
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 21, "445", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                    IF CodRet != '00000' THEN
                       LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                    END IF;		
		END IF;

        -- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN           
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 22, "445", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                     IF CodRet != '00000' THEN
                        LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                     END IF;                                        
		END IF;
	ELSE
	 -- Por la venta de la cartera vencida EXIGIBLE       
		IF vMontoVencidoExigible_rees > 0 THEN
           
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "445", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                    IF CodRet != '00000' THEN
                       LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                    END IF;		
		END IF;

        -- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN           
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "445", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                     IF CodRet != '00000' THEN
                        LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                     END IF;                                        
		END IF;
    END IF; --status ipcb		
-------------------------
        --IF cStatusCred = 'BT' OR (cStatusCred in ('E2','E3')) THEN
            --creditos BT
            --balanza
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and campo_trabajo3 = ''; 
          /*  and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');  --Fecha en que entre a BT*/

            --orden
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and campo_trabajo3 = 'V';
           /* and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');*/

       /* ELSE
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            FROM bdicred:sd_amortiza_creditocrd
            WHERE empresa = pEmpresa
            AND num_credito= cNumCredito
            AND capital_status in ('2','7','6');*/

       -- END IF;

-------------------------
       IF vInteresVencido_rees > 0 THEN
            IF cStatusCred = 'E2' THEN
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 23, "445", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto,24, "445", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
			ELSE
					  -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 3, "445", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto,4, "445", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
			END IF;
		END IF;

        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 5, "445", dFecha, vInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 6, "445", dFecha, vIvaInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;

		END IF;

        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
               ---- se agregan campos para que Juan Olivares valide
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0, atr = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;

        -- Se Actualizan las amortizaciones

        UPDATE sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7','6') or interes_debe <> 0);


	ELSE			---	PRESTAMO PERSONAL

        -- Se Replica la informacion de los creditos (PRESTAMO PERSONAL) por Vender a la tabla bdicred:sd_maecred_vendida.
        --INSERT INTO bdicred:sd_maecredcrd_vendida
		INSERT INTO bdicred:sd_maecredcrd_vend_total(fecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo)
        --SELECT CURRENT, * FROM bdicred:sd_maecredcrd
		SELECT CURRENT,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo FROM bdicred:sd_maecredcrd
        WHERE --empresa = pEmpresa AND
           num_credito = cNumCredito;

		--insert a la tabla original
		INSERT INTO bdicred:sd_maecredcrd_vendida
		SELECT CURRENT, * FROM bdicred:sd_maecredcrd
		WHERE empresa = pEmpresa AND num_credito = cNumCredito;
		   
		   
        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'CV'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


     -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6300           
        	SELECT fecha_vencto
			  INTO dfecha_vencto63
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto63,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;






        -- Se Actualiza la fecha de proceso por estar bloqueados los creditos
        UPDATE bdicred:sd_maecredanexocrd
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;

        -- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito
        AND fecha_cuota >= date(1);

        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto,
			e.dia_corte
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees,
			ddia_corte

        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d, bdicred:sd_maecredanexocrd e
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra IN ('M','Q')
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal
		  AND e.empresa 		 = a.empresa
		  AND e.num_credito      = a.num_credito;

        -- Por la venta de la cartera vencida EXIGIBLE
        IF cStatusCred = 'E2' THEN
            IF vMontoVencidoExigible_rees > 0 THEN
    
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 21, "446", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                    IF CodRet != '00000' THEN
                       LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                    END IF;
    
            END IF;
    
                        -- Por la venta de la cartera vencida NO EXIGIBLE
            IF vMontoVencidoNoExigible_rees > 0 THEN
    
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 22, "446", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                     IF CodRet != '00000' THEN
                        LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                     END IF;
    
            END IF;
        ELSE
            IF vMontoVencidoExigible_rees > 0 THEN
    
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "446", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                    IF CodRet != '00000' THEN
                       LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                    END IF;
    
            END IF;
    
                        -- Por la venta de la cartera vencida NO EXIGIBLE
            IF vMontoVencidoNoExigible_rees > 0 THEN
    
                CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "446", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                     RETURNING CodRet, Mensaje;
    
                     IF CodRet != '00000' THEN
                        LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                        RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                     END IF;
    
            END IF;
        END IF;            
-------------------------
       -- IF cStatusCred = 'BT' THEN
            --creditos BT
            --balanza
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and campo_trabajo3 = '' ;
            /*and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');*/

            --orden
            --select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido 08/06/2012 PARA PP POR RSS
			select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and campo_trabajo3 = 'V' ;
            /*and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');*/
		/*
			SELECT iva
			INTO vPorcIva
			FROM bdinteg:si_sucursales
			WHERE empresa = pEmpresa
			AND sucursal = vSucursal;

			IF vPorcIva IS NULL THEN
				LET vPorcIva=0;
			END IF;

			LET vIvaInteresVencido = vInteresVencido * vPorcIva;
        ELSE
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            FROM bdicred:sd_amortiza_creditocrd
            WHERE empresa = pEmpresa
            AND num_credito= cNumCredito
            AND capital_status in ('2','7');
        END IF;*/

-------------------------

      --  IF cStatusCred = 'BT' THEN
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
        
			IF vInteresVencido_rees > 0 THEN
                IF cStatusCred = 'E2' THEN
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 23, "446", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
    
                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;
			

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

			--IF vIvaInteresVencido_rees > 0 THEN

                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 24, "446", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
    
                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;
                ELSE
                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 3, "446", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
    
                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;
			

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

			--IF vIvaInteresVencido_rees > 0 THEN

                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 4, "446", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
    
                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;                             
                END IF;
			END IF;

			--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
			SELECT monto
				INTO psaldoInteresTrasApoyo
			FROM bdicred:sd_maeretenido 
			WHERE num_credito = cNumCredito
				AND transacc = '8374'
				AND estatus = 'R';

				IF psaldoInteresTrasApoyo IS NULL THEN
					LET psaldoInteresTrasApoyo = 0;
				END IF;
				
			IF psaldoInteresTrasApoyo > 0 THEN
                IF cStatusCred = 'E2' THEN
					CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 29, "446", dFecha, psaldoInteresTrasApoyo, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
				ELSE 
					 CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 9, "446", dFecha, psaldoInteresTrasApoyo, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
				END IF;	 

			END IF;
			
			--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
			SELECT monto
				INTO psaldoIvaIntTrasApoyo
			FROM bdicred:sd_maeretenido 
			WHERE num_credito = cNumCredito
				AND transacc = '8375'
				AND estatus = 'R';

				IF psaldoIvaIntTrasApoyo IS NULL THEN
					LET psaldoIvaIntTrasApoyo = 0;
				END IF;
				
			IF psaldoIvaIntTrasApoyo > 0 THEN
                IF cStatusCred = 'E2' THEN  --Validar si existe el 20
					CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 20, "446", dFecha, psaldoIvaIntTrasApoyo, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
				ELSE
				     CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 10, "446", dFecha, psaldoIvaIntTrasApoyo, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;

				END IF;	 

			END IF;
			
      --  END IF;

		---------------  Baja de intereses provisionados antes de la fecha de la provision de este mes

        	select prox_fecha_pago, fecha_proceso
			INTO dproxfechapago, dfechaproceso
			from bdicred:sd_maecredanexocrd
			where empresa = pEmpresa
			and num_credito = cNumCredito;

            if (month(dproxfechapago) = month(dfechaproceso) and year(dproxfechapago) = year(dfechaproceso)) then

                select nvl(sum(monto),0)
                INTO vInteresVencido_ant
                from bdicred:sd_movhiscrd
                where empresa = pEmpresa
                and fecha_mov = dpri_dia_mes - 1
                and num_credito = cNumCredito
                and codigo_fun = '606'
                and codigo_ref = 8
                and reversado = 'N';

                if nvl(vInteresVencido_ant,0) = 0 then
                    let vInteresVencido_ant = 0;
                else
                    IF cStatusCred = 'E2' THEN
                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 27, "446", dFecha, vInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                             RETURNING CodRet, Mensaje;
    
                             IF CodRet != '00000' THEN
                                LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                                RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                             END IF;
                     ELSE
                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 7, "446", dFecha, vInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                             RETURNING CodRet, Mensaje;
    
                             IF CodRet != '00000' THEN
                                LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                                RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                             END IF;                     
                     END IF;    
                end if;

                select nvl(sum(monto),0)
                INTO vIvaInteresVencido_ant
                from bdicred:sd_movhiscrd
                where empresa = pEmpresa
                and fecha_mov = dpri_dia_mes - 1
                and num_credito = cNumCredito
                and codigo_fun = '606'
                and codigo_ref = 9
                and reversado = 'N';

                if nvl(vIvaInteresVencido_ant,0) = 0 then
                    let vIvaInteresVencido_ant = 0;
                else
                    IF cStatusCred = 'E2' THEN                    
                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 28, "446", dFecha, vIvaInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                             RETURNING CodRet, Mensaje;
    
                             IF CodRet != '00000' THEN
                                LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                                RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                             END IF;
                    ELSE
                        CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 8, "446", dFecha, vIvaInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                             RETURNING CodRet, Mensaje;
    
                             IF CodRet != '00000' THEN
                                LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                                RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                             END IF;                    
                    END IF;         
                end if;

            else
                LET vInteresVencido_ant = 0;
                LET vIvaInteresVencido_ant = 0;
            end if;

		-----------------

        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN
			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 5, "446", dFecha, vInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;
		END IF;

		IF vIvaInteresVencido > 0 THEN
			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 6, "446", dFecha, vIvaInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;
		END IF;

        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
               ---- se agregan campos para que Juan Olivares valide
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0, atr = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;
        
        -- Se Actualizan las amortizaciones

        UPDATE sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7','6') or interes_debe <> 0);

	END IF;
	
	IF cNumProducto='6800' THEN
	    SELECT fecha_hoy INTO vFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

        SELECT {+AVOID_FULL(bdicred:"informix".sd_linea_prestamo)} pres.num_credito, crd.numcte, crd.status_cred, crd.sucursal, pres.sec_credito, pres.fecha_otorga, crd.fecha_vencim, pres.fecha_cancela, pres.fecha_ult_mod, 
        pres.monto_linea, pres.linea_disponible , pres.cancel_pf, pres.fecha_ult_pf 
        INTO vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf 
        FROM bdicred:"informix".sd_linea_prestamo pres
        JOIN bdicred:"informix".sd_maecredcrd crd ON (pres.num_credito = crd.num_credito)		
        WHERE pres.num_credito = cNumCredito;
	    -- SE GENERA EL FOLIO
		LET pEjecutivo = 'informix';
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

		IF cCodRet2::integer  <> '000' THEN
			LET COD_RET = "00002";  --Error en sp_generafolionomina
			LET P_MENSAJE = 'Error en la generacion de folio del movimiento';
			RETURN COD_RET || P_MENSAJE;			   
		ELSE
			-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
			EXECUTE PROCEDURE bdicred:genmovcrd(pEmpresa,cNumCredito, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;					
			
			IF cCodRet::integer  <> '000000' THEN
				LET COD_RET = "00004"; --Error en genmovcrd
				LET P_MENSAJE = 'Error en la generacion del movimiento';
				RETURN COD_RET || P_MENSAJE;
			ELSE
				UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = cNumCredito;
			END IF;					
		END IF;	
	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',1,cNumCte, USER)
	INTO CodRet, Mensaje;
	
    LET vInteresVencido_rees = 0;
    LET vIvaInteresVencido_rees = 0;
    LET vInteresVencido = 0;
    LET vIvaInteresVencido = 0;
	LET vInteresVencido_ant = 0;
	LET vIvaInteresVencido_ant = 0;
	LET cStatusCred = '';
	LET psaldoInteresTrasApoyo  = 0;
	LET psaldoIvaIntTrasApoyo = 0;

    Commit Work;

End Foreach;

LET CodRet = '00000';
RETURN CodRet || ' El proceso de VENTA DE CARTERA se ejecuto exitosamente.';

end;
end procedure;