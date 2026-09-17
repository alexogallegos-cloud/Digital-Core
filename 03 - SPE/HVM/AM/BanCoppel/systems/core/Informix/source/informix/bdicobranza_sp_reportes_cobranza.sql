CREATE PROCEDURE "informix".sp_reportes_cobranza() 
RETURNING char(6), char(150);

-- EXECUTE PROCEDURE "informix".sp_reportes_cobranza();

define cCod_ret             CHAR(6);
define sql_err				INTEGER;
define isam_err				INTEGER;
define error_info			CHAR(80);
define cMensaje				CHAR(150);
define cproceso				CHAR(4);
define cSql          	  	CHAR(2024);
define vruta				char(100);
define dFechaFin			date;
define dFechaIni			date;
define Vtipocampania		char(20);
define iTotalRreal			integer;
define iTotalEnvios1		integer;
define iTotalEnvios2		integer;
define cNombre_Archivo		char(100);
define vnum_convenios1 		integer;
define vmonto1				decimal(18,2);
define vnum_convenios2 		integer;
define vmonto2				decimal(18,2);
define vejecutivo			char(20);
define vproducto			char(4);
define vnum_credito			char(20);
define vestatus_banco		char(20);
define vestatus_coppel		char(20);
define vmonto_conv			decimal(18,2);
define vmonto_recup			decimal(18,2);
define dPriDiaMes			date;
define dPriDiaMes1			date;
define vnum_convenios  		integer;
define vmonto 				decimal(18,2);
define vdescripcion  		char(100);
define vtipologica			smallint;
define sPaso 				smallint;
define dFechaHoy 			date;
define iTotalSinteloSinmail	integer;
define iTotalCuentasConConv	integer;
define iTotalPagoMinRecup   integer;
define iTotalMontoRecup		integer;
define dFechaInsert			date;

--SET DEBUG FILE TO '/aplicacion/resplogifx/archivoscartera/cobranza/reportes_cobranza.out';
--TRACE ON;

let cCod_ret		= '000000';
let sql_err			= 0;
let isam_err		= 0;
let error_info		= '';
let cMensaje		= 'El proceso de REPORTE CAMPAÑAS se realizó correctamente.';
let cproceso		= '2095';
let cSql			= "";
let vruta			= '';
let dFechaFin		= date(1);
let dFechaIni		= date(1);
let Vtipocampania	= "";
let iTotalRreal		= 0;
let iTotalEnvios1	= 0;
let iTotalEnvios2	= 0;
let cNombre_Archivo = '';
let vnum_convenios1 = 0;
let vmonto1			= 0;
let vnum_convenios2 = 0;
let vmonto2			= 0;
let vejecutivo		= '';
let vproducto		= '';
let vnum_credito	= '';
let vestatus_banco	= '';
let vestatus_coppel	= '';
let vmonto_conv		= 0;
let vmonto_recup	= 0;
let dPriDiaMes		= date(1);
let dPriDiaMes1		= date(1);
let vnum_convenios  = 0;
let vmonto  		= 0;
let vdescripcion 	= '';
let vtipologica 	= 0;
let sPaso 			= 0;
let dFechaHoy 		= date(1);
let iTotalSinteloSinmail	= 0;
let iTotalCuentasConConv	= 0;
let iTotalPagoMinRecup		= 0;
let iTotalMontoRecup		= 0;
let dFechaInsert	= date(1);

	
    BEGIN        
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
    	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '02') RETURNING cCod_ret; 
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 

    if cCod_ret != '000000' then
       let cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN cCod_ret,cMensaje;
    end if;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
		
	SELECT TRIM(valor_alfabetico)
        INTO vruta
        FROM bdicobranza:cb_param_campania
        WHERE empresa = '001'
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 34;

	select pri_dia_mes,fecha_hoy into dPriDiaMes,dFechaHoy from bdicred:sd_fechas where empresa = '001';

--temporal solo para pruebas
--let vruta = '/pisa/ricardo/campanas/';		

--let dPriDiaMes = mdy('06','08','2016');	
--let dFechaHoy = mdy('06','08','2016');	
--temporal solo para pruebas
	
if day(dFechaHoy) >= 1 and day(dFechaHoy) <= 20 then 
	let dFechaFin = dPriDiaMes - 1 units day;
	let dFechaIni = mdy(month(dFechaFin),1,year(dFechaFin));

	----------------------------------------REPORTE EMAIL
	FOREACH
		select id_campania,sum(total),sum(total_sintel_o_sinmail) INTO Vtipocampania, iTotalRreal, iTotalSinteloSinmail
		from cb_totalcte_campania2
		where empresa = '001' and fecha_insert >= dFechaIni and fecha_insert <= dFechaFin
			and id_campania in ('COMPAC_ADE','COMPAC_FRA','COMPAC_PAG', 'COMPAC_SIN', 'PP_MORA1', 'PP_AUTORIZ',  
			'PP_ULTAVPA', 'REST_MORA1', 'REST_MORA2',	'REST_PREV', 'TC_MORA1', 'TC_MORA2', 'TC_MORA3', 'TC_MORA4', 
            'TC_MORA5','TC_PRIMERC','TCP_PRIMER','TCP_MORA1','TCP_MORA2','TCP_MORA3','TCP_MORA4','TCP_MORA5','TCP_PREVEN','TC_PREVEN','TCO_PREVEN',
	/*Oro*/	'TCO_PRIMER','TCO_MORA1','TCO_MORA2','TCO_MORA3','TCO_MORA4','TCO_MORA5','TCO_COMPAG','TCO_COMFRA','TCO_COMADE','TCO_COMSIN')
        group by 1


/*		select id_campania,total INTO Vtipocampania, iTotalRreal
		from cb_totalcte_campania2
		where empresa = '001' and fecha_insert >= dFechaIni and fecha_insert <= dFechaFin
			and id_campania in ('COMPAC_ADE','COMPAC_FRA','COMPAC_PAG', 'COMPAC_SIN', 'PP_MORA1', 'PP_AUTORIZ',  
			'PP_ULTAVPA', 'REST_MORA1', 'REST_MORA2',	'REST_PREV', 'TC_MORA1', 'TC_MORA2', 'TC_MORA3', 'TC_MORA4', 'TC_MORA5','TC_PRIMERC')
*/		
		select descripcion into vdescripcion
		from cb_catalogo_campania_latinia where id_campania = Vtipocampania;
		
		select count(*) into iTotalEnvios1
		from bdimnsj:mnsjr_trx_batch
		where id_mensaje = vtipocampania 
		  and cuenta is not null
		  and date(fecha_hora_registro) >= dFechaIni and date(fecha_hora_registro) <= dFechaFin;
		
        if iTotalEnvios1 is null or iTotalEnvios1 = '' then let iTotalEnvios1 = 0; end if;

		select count(*) into iTotalEnvios2
		from bdimnsj:mnsjr_trx_batch_his
		where id_mensaje = vtipocampania 
            and cuenta is not null
			and date(fecha_hora_registro) >= dFechaIni and date(fecha_hora_registro) <= dFechaFin;

        if iTotalEnvios2 is null or iTotalEnvios2 = '' then let iTotalEnvios2 = 0; end if;
		
		let iTotalEnvios1 = iTotalEnvios1 + iTotalEnvios2;

		INSERT INTO cb_reportes_latinia(empresa,id_mensaje,descripcion,num_envios,num_real,fecha,total_sintel_o_sinmail)
		VALUES('001',Vtipocampania,vdescripcion,iTotalEnvios1,iTotalRreal,today,iTotalSinteloSinmail);

		end FOREACH
	
	--Se genera archivo con la informacion del reporte 
	let cNombre_Archivo = 'REP_ENVIOS_LATINIA_EMAIL'||'_'||to_char(dFechaFin,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' || trim(vruta) || 'Reportecobranza.unl' || ' DELIMITER ' || '''|'''|| 
			   '  select descripcion , num_envios , num_real, total_sintel_o_sinmail '|| 
			   ' from cb_reportes_latinia '|| 
			   ' where empresa = ''001'' and id_mensaje in (''COMPAC_ADE'',''COMPAC_FRA'',''COMPAC_PAG'', ''COMPAC_SIN'', ''PP_MORA1'', ''PP_AUTORIZ'',  '|| 
			   ' ''PP_ULTAVPA'', ''REST_MORA1'', ''REST_MORA2'',''REST_PREV'',''TC_MORA1'',''TC_MORA2'',''TC_MORA3'',''TC_MORA4'',''TC_MORA5'',''TC_PRIMERC'',  '|| 
               ' ''TCP_PRIMER'',''TCP_MORA1'',''TCP_MORA2'',''TCP_MORA3'',''TCP_MORA4'',''TCP_MORA5'',''TCP_PREVEN'',''TC_PREVEN'',''TCO_PREVEN'',  '||
			   ' ''TCO_PRIMER'',''TCO_MORA1'',''TCO_MORA2'',''TCO_MORA3'',''TCO_MORA4'',''TCO_MORA5'',''TCO_COMPAG'',''TCO_COMFRA'',''TCO_COMADE'',''TCO_COMSIN'') and fecha = today ; '||
--			   ' ''PP_ULTAVPA'', ''REST_MORA1'', ''REST_MORA2'',''REST_PREV'',''TC_MORA1'',''TC_MORA2'',''TC_MORA3'',''TC_MORA4'',''TC_MORA5'',''TC_PRIMERC'') and fecha = today ; '||	
			   ' " > '|| trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecobranza.unl' || " > " || trim(vruta) || cNombre_Archivo;
	SYSTEM cSql;
		 
	LET cSql = '';
	LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza.sql ' || trim(vruta) || 'Reportecobranza.unl';
	SYSTEM cSql;

	----------------------------------------REPORTE SMS
	LET iTotalRreal		 = 0;	LET iTotalEnvios1	 = 0;	LET iTotalEnvios2	 = 0;	
	FOREACH
		select id_campania,sum(total),sum(total_sintel_o_sinmail) INTO Vtipocampania, iTotalRreal, iTotalSinteloSinmail
		from cb_totalcte_campania2
		where empresa = '001' 
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('TC_MORA1S','TC_MORA2S','TC_COMPACS','TC_PAGMINS','PP_APERTUS','PP_MORAS1S','PP_MORAS2S',
			'PP_PAGCOMS','REST_APES','REST_MOR1S','REST_MOR2S','REST_PAGS','TC_PAGMINS','TCP_PAGMIS','TCP_PRIMES','TCP_MORA1S','TCP_MORA2S',
	/*Oro*/ 'TCO_PRIMES','TCO_PAGMIS','TCO_MORA1S','TCO_MORA2S','TCO_COPACS')
        group by 1

/*
		select id_campania,total INTO Vtipocampania, iTotalRreal
		from cb_totalcte_campania2
		where empresa = '001' 
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('TC_MORA1S','TC_MORA2S','TC_COMPACS','TC_PAGMINS','PP_APERTUS','PP_MORAS1S','PP_MORAS2S',
			'PP_PAGCOMS','REST_APES','REST_MOR1S','REST_MOR2S','REST_PAGS')
*/		
		select descripcion into vdescripcion
		from cb_catalogo_campania_latinia where id_campania = Vtipocampania;
		
		select count(*) into iTotalEnvios1
		from bdimnsj:mnsjr_trx_batch
		where id_mensaje = vtipocampania 
		  and cuenta is not null
		  and date(fecha_hora_registro) >= dFechaIni and date(fecha_hora_registro) <= dFechaFin;

        if iTotalEnvios1 is null or iTotalEnvios1 = '' then let iTotalEnvios1 = 0; end if;
		
		select count(*) into iTotalEnvios2
		from bdimnsj:mnsjr_trx_batch_his
		where id_mensaje = vtipocampania
            and cuenta is not null 
			and date(fecha_hora_registro) >= dFechaIni and date(fecha_hora_registro) <= dFechaFin;

        if iTotalEnvios2 is null or iTotalEnvios2 = '' then let iTotalEnvios2 = 0; end if;
		
		let iTotalEnvios1 = iTotalEnvios1 + iTotalEnvios2;

		INSERT INTO cb_reportes_latinia(empresa,id_mensaje,descripcion,num_envios,num_real,fecha,total_sintel_o_sinmail)
		VALUES('001',Vtipocampania,vdescripcion,iTotalEnvios1,iTotalRreal,today,iTotalSinteloSinmail);
		
	end FOREACH
	
	--Se genera archivo con la informacion del reporte 
	let cNombre_Archivo = 'REP_ENVIOS_LATINIA_SMS'||'_'||to_char(dFechaFin,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' || trim(vruta) || 'Reportecobranza.unl' || ' DELIMITER ' || '''|'''|| 
			   '  select descripcion , num_envios , num_real, total_sintel_o_sinmail '|| 
			   ' from cb_reportes_latinia '|| 
			   ' where empresa = ''001'' and id_mensaje in (''TC_MORA1S'',''TC_MORA2S'',''TC_COMPACS'',''TC_PAGMINS'',''PP_APERTUS'',''PP_MORAS1S'',''PP_MORAS2S'', '||
			   ' ''PP_PAGCOMS'',''REST_APES'',''REST_MOR1S'',''REST_MOR2S'',''REST_PAGS'', '||
               ' ''TCP_PAGMIS'',''TCP_PRIMES'',''TCP_MORA1S'',''TCP_MORA2S'', '||
		/*Oro*/' ''TCO_PRIMES'',''TCO_PAGMIS'',''TCO_MORA1S'',''TCO_MORA2S'',''TCO_COPACS'') and fecha = today; '||
--			   ' ''PP_PAGCOMS'',''REST_APES'',''REST_MOR1S'',''REST_MOR2S'',''REST_PAGS''
			   ' " > '|| trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecobranza.unl' || " > " || trim(vruta) || cNombre_Archivo;
	SYSTEM cSql;
		 
	LET cSql = '';
	LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza.sql ' || trim(vruta) || 'Reportecobranza.unl';
	SYSTEM cSql;

	----------------------------------------REPORTE CAT CONVENIOS
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_temp_rep_convenios';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_temp_rep_convenios;
			END IF;
			create  table cb_temp_rep_convenios (empresa char(3),monto decimal(18,2),ejecutivo char(20),producto char(4),
			num_credito char(20),estatus_banco	char(20), estatus_coppel char(20),monto_recup decimal(18,2),fecha_pago date);

--		let dPriDiaMes1 = dPriDiaMes - 1 units month ;
--		let dPriDiaMes = dPriDiaMes - 1 units day;
		
	FOREACH

		select empleado_captura, numcuenta, importe, imp_pagado, fecha_insert
			into  vejecutivo,vnum_credito,vmonto_conv,vmonto_recup,dFechaInsert  --RQM 09 352 - 3 Adendum seguimiento de campañas de cobranza (parte 3 se adiciona fecha de pago del convenio) 
		from bdicobranza:cb_compac_his
		where origen = 3 
		and fecha_insert >= dFechaIni and fecha_insert <=  dFechaFin

		--validar el estatus bancoppel
		if (vmonto_recup >=  vmonto_conv/2) then
			let vestatus_banco = 'CUMPLIDO';
		else 
			let vestatus_banco = 'NO CUMPLIDO';
		end if;
	
		--validar el estatus coppel
		IF (vmonto_recup >= 1 ) THEN
			LET vestatus_coppel = 'CUMPLIDO';
		ELSE
			LET vestatus_coppel = 'NO CUMPLIDO';
		END IF;

		select num_producto into vproducto
		from bdicred:sd_maecred
		where empresa= '001' and  num_credito =  vnum_credito;
			
		INSERT INTO cb_temp_rep_convenios(empresa,monto,ejecutivo,producto,num_credito,estatus_banco,estatus_coppel,monto_recup,fecha_pago)
		VALUES('001',vmonto_conv,vejecutivo,vproducto,vnum_credito,vestatus_banco,vestatus_coppel,vmonto_recup,case when vmonto_recup > 0 then dFechaInsert else null end);
	
	end FOREACH 
	--Se genera archivo con la informacion del reporte 
	let cNombre_Archivo = 'REP_ENVIOS_LATINIA_CONVENIOS'||'_'||to_char(dFechaFin,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' || trim(vruta) || 'Reportecobranza.unl' || ' DELIMITER ' || '''|'''|| 
			   '  select ejecutivo,producto,num_credito,estatus_banco,estatus_coppel,monto, monto_recup, fecha_pago '|| 
			   ' from cb_temp_rep_convenios; '|| 
			   ' " > '|| trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecobranza.unl' || " > " || trim(vruta) || cNombre_Archivo;
	SYSTEM cSql;
		 
	LET cSql = '';
	LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza.sql ' || trim(vruta) || 'Reportecobranza.unl';
	SYSTEM cSql;
	
	----------------------------------------REPORTE IVR
	
	LET iTotalRreal	= 0;	LET iTotalEnvios1	 = 0;	let vdescripcion = '';
	FOREACH
		select id_campania,sum(total),sum(total_sintel_o_sinmail) INTO Vtipocampania, iTotalEnvios1, iTotalSinteloSinmail
		from cb_totalcte_campania2
		where empresa = '001' 
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('IVR_MORA1','IVR_MORA2','IVR_PREV1','IVR_PREV2', 'IVR_PP', 'IVR_PP18',
								'IVR_PP24', 'IVR_REEST','IVR_PREV10','IVR_PREV15','IVR_MORAO1','IVR_MORAO2')
        group by 1
/*	
		select id_campania,total INTO Vtipocampania, iTotalEnvios1
		from cb_totalcte_campania2
		where empresa = '001' 
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('IVR_MORA1','IVR_MORA2','IVR_PREV1','IVR_PREV2', 'IVR_PP','IVR_REEST')
*/		
		select descripcion into vdescripcion
		from cb_catalogo_campania_latinia where id_campania = Vtipocampania;

		select numero_envios into iTotalRreal
		from cb_movimientos_ivr
		where  id_campania = Vtipocampania 
			and date(fecha) >= dFechaIni and date(fecha) <= dFechaFin;
		
        if iTotalRreal is null or iTotalRreal = '' then let iTotalRreal = 0; end if;

		INSERT INTO cb_reportes_latinia(empresa,id_mensaje,descripcion,num_envios,num_real,fecha,total_sintel_o_sinmail)
		VALUES('001',Vtipocampania,vdescripcion,iTotalEnvios1,iTotalRreal,today,iTotalSinteloSinmail);

		
	end FOREACH 
	--Se genera archivo con la informacion del reporte 
	let cNombre_Archivo = 'REP_ENVIOS_IVR'||'_'||to_char(dFechaFin,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' || trim(vruta) || 'Reportecobranza.unl' || ' DELIMITER ' || '''|'''|| 
			   ' select descripcion , num_envios , num_real, total_sintel_o_sinmail '|| 
			   ' from cb_reportes_latinia '|| 
			   ' where empresa = ''001'' and id_mensaje in (''IVR_MORA1'',''IVR_MORA2'',''IVR_PREV1'',''IVR_PREV2'', ''IVR_PP'',''IVR_PP18'',	'||
			   ' ''IVR_PP24'',''IVR_REEST'',''IVR_PREV10'',''IVR_PREV15'',''IVR_MORAO1'',''IVR_MORAO2'') and fecha = today ;'||	
			   ' " > '|| trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecobranza.unl' || " > " || trim(vruta) || cNombre_Archivo;
	SYSTEM cSql;
		 
	LET cSql = '';
	LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza.sql ' || trim(vruta) || 'Reportecobranza.unl';
	SYSTEM cSql;

elif day(dFechaHoy) >= 21 and day(dFechaHoy) <= 31 then  
	let dFechaFin = dPriDiaMes - 1 units day;
	let dFechaIni = mdy(month(dFechaFin),21,year(dFechaFin));
	let dFechaFin = mdy(month(dFechaIni),20,year(dFechaIni)) + 1 units month;

--RETURN cCod_ret, cMensaje;

	LET iTotalRreal		 = 0;	LET iTotalEnvios1	 = 0;	LET iTotalEnvios2	 = 0;	let vdescripcion ='';
	----------------------------------------REPORTE CAT
/*
tipo_cobranza pp y reestr
E - PREVENTIVO
R - ADMINISTRATIVO */

    SELECT num_credito,numcte,tipo_logica,fecha_insert
    FROM bdicobranza:cb_cat_directorio_cte_his
    where empresa='001' and tipo_cobranza = 'A'
    and fecha_insert = mdy(month(dFechaIni),20,year(dFechaIni))
--    and fecha_insert <= dFechaFin
    into temp cuentas_cat with no log;

    insert into cuentas_cat 
    SELECT num_credito,numcte,tipo_logica,fecha_insert 
    FROM bdicobranza:cb_cat_directorio_cte
    where empresa='001' and tipo_cobranza = 'R'
    and fecha_insert >= dFechaIni
    and fecha_insert <= dFechaFin;

    CREATE INDEX inx_indicetmp ON cuentas_cat(num_credito,tipo_logica);
    update statistics medium for table cuentas_cat;
	
	FOREACH
		select id_campania,sum(total),sum(total_sintel_o_sinmail) INTO Vtipocampania, iTotalRreal, iTotalSinteloSinmail
		from cb_totalcte_campania2
		where empresa = '001'  
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('TDC_ADM1','TDC_ADM2','TDC_ADM3','REEST_ADM1','TCO_ADM1','TCO_ADM2','TCO_ADM3')
         group by 1
/*
		select id_campania,total INTO Vtipocampania, iTotalRreal
		from cb_totalcte_campania2
		where empresa = '001'  
			and date(fecha_insert) >= dFechaIni and date(fecha_insert) <= dFechaFin
			and id_campania in ('TDC_ADM1','TDC_ADM2','TDC_ADM3','REEST_ADM1')
*/		
		select descripcion into vdescripcion
		from cb_catalogo_campania_latinia where id_campania = Vtipocampania;
		
		
		
		if (Vtipocampania = 'TCO_ADM1') then
			LET vtipologica = 10; 
		elif(Vtipocampania = 'TCO_ADM2') then
			LET vtipologica = 20; 
		elif(Vtipocampania = 'TCO_ADM3') then
			LET vtipologica = 30;
 /*if*/ elif(Vtipocampania = 'TDC_ADM1') then
			LET vtipologica = 1; 
		elif(Vtipocampania = 'TDC_ADM2') then
			LET vtipologica = 2; 
		elif(Vtipocampania = 'TDC_ADM3') then
			LET vtipologica = 3; 
		else
			LET vtipologica = 6; 
		end if;

        if vtipologica <> 6 then
            select count(*) into iTotalEnvios1
            from bdicobranza:cb_cat_movimientos a
            inner join cuentas_cat b on b.num_credito = a.tienda and b.tipo_logica = a.tipologica
            where a.cliente>=0
              and a.tipologica = vtipologica
              and a.empresa = '001'
              and a.finllamada in (1,2,3,4,5,6,7,8)
              and date(a.fechacartera) = mdy(month(dFechaIni),20,year(dFechaIni));
        else
            select count(*) into iTotalEnvios1
            from bdicobranza:cb_cat_movimientos a
            inner join cuentas_cat b on b.num_credito = a.tienda and b.tipo_logica = a.tipologica
            where a.cliente>=0
              and a.tipologica = vtipologica
              and a.empresa = '001'
              and a.finllamada in (1,2,3,4,5,6,7,8)
              and date(a.fechacartera) >= dFechaIni
              and date(a.fechacartera) <= dFechaFin;
        end if;

		select count(*),sum(importe) into vnum_convenios, vmonto
		from bdicobranza:cb_compac_his a
        inner join cuentas_cat b on b.num_credito = a.numcuenta and b.tipo_logica = vtipologica
		where a.empresa = '001' and a.origen = 3 
			and date(a.fecha_compac) >= dFechaIni and date(a.fecha_compac) <= dFechaFin;
			
--RQM 09 352 - 3 Adendum seguimiento de campañas de cobranza (parte 2) 
		LET sPaso = 0;
		SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_temp_recuperado_convenios';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_temp_recuperado_convenios;
			END IF;

		select a.numcuenta,b.fecha_insert,a.importe,a.imp_pagado,
			case when a.pago_minimo >= a.importe then 
				case when a.importe <= a.imp_pagado then a.importe else a.imp_pagado end
			else
				a.pago_minimo
			end monto_pagomin_recup
		from bdicobranza:cb_compac_his a
		inner join cuentas_cat b on b.num_credito = a.numcuenta and b.tipo_logica = vtipologica
		--inner join bdicobranza:cb_cartera_linea c on c.num_credito = a.numcuenta and c.fecha = b.fecha_insert
		where a.empresa = '001' and a.origen = 3 
		and a.fecha_compac >= dFechaIni and a.fecha_compac <= dFechaFin
		and a.importe > 0 and a.imp_pagado > 0
		into temp cb_temp_recuperado_convenios with no log;

		update statistics medium for table cb_temp_recuperado_convenios;

		select count(*), round(sum(monto_pagomin_recup)), round(sum(imp_pagado)) into iTotalCuentasConConv, iTotalPagoMinRecup, iTotalMontoRecup
		from cb_temp_recuperado_convenios;

/*		
		select count(*),sum(importe) into vnum_convenios1, vmonto1
		from bdicobranza:cb_compac
		where empresa = '001' and origen = 3 
			and date(fecha_compac) >= dFechaIni and date(fecha_compac) <= dFechaFin;

        if vnum_convenios1 is null or vnum_convenios1 = '' then let vnum_convenios1 = 0; end if;
			 
		select count(*),sum(importe) into vnum_convenios2, vmonto2
		from bdicobranza:cb_compac_his
		where empresa = '001' and origen = 3 
			and date(fecha_compac) >= dFechaIni and date(fecha_compac) <= dFechaFin;

        if vnum_convenios2 is null or vnum_convenios2 = '' then let vnum_convenios2 = 0; end if;
	
		let dFechaFin = mdy(month(dFechaFin), '20', year(dFechaFin));
		select count(*) into iTotalEnvios1
		from bdicobranza:cb_cat_movimientos
		where date(fechacartera) = dFechaFin
		and finllamada in (1,2,3,4,5,6,7,8)
		and tipologica = vtipologica;
		
		let vnum_convenios = vnum_convenios1 + vnum_convenios2;
		let vmonto	= vmonto1 + vmonto2;
*/
		INSERT INTO cb_reportes_latinia(empresa,id_mensaje,descripcion,num_envios,num_real,num_convenios,monto,fecha,total_sintel_o_sinmail,cta_conconv_conpago,pago_minimo_recup,monto_total_recup)
		VALUES('001',Vtipocampania,vdescripcion,iTotalRreal,iTotalEnvios1,vnum_convenios,vmonto,today,iTotalSinteloSinmail,iTotalCuentasConConv,iTotalPagoMinRecup,iTotalMontoRecup);
		
		let iTotalSinteloSinmail	= 0;
		let iTotalCuentasConConv	= 0;
		let iTotalPagoMinRecup		= 0;
		let iTotalMontoRecup		= 0;
		drop table cb_temp_recuperado_convenios;
	end FOREACH 

	--Se genera archivo con la informacion del reporte 
	let cNombre_Archivo = 'REP_CAT'||'_'||to_char(dFechaFin,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' || trim(vruta) || 'Reportecobranza.unl' || ' DELIMITER ' || '''|'''|| 
--			   '  select descripcion , num_envios , num_real , num_convenios , monto '|| 
			   '  select descripcion , num_envios , num_real , num_convenios , monto , cta_conconv_conpago,pago_minimo_recup,monto_total_recup'|| 
			   ' from cb_reportes_latinia '|| 
			   ' where empresa = ''001'' and id_mensaje in (''TDC_ADM1'',''TDC_ADM2'',''TDC_ADM3'',''REEST_ADM1'', '||
			   ' ''TCO_ADM1'',''TCO_ADM2'',''TCO_ADM3'') and fecha = today; '||
			   ' " > '|| trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecobranza.unl' || " > " || trim(vruta) || cNombre_Archivo;
	SYSTEM cSql;
		 
	LET cSql = '';
	LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza.sql ' || trim(vruta) || 'Reportecobranza.unl';
	SYSTEM cSql;
    drop table cuentas_cat;

end if;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret; 

if cCod_ret != '000000' then
--   let P_COD_RET = cCod_ret;
   let cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN cCod_ret,cMensaje;
end if;

RETURN cCod_ret, cMensaje;
END
END PROCEDURE

;