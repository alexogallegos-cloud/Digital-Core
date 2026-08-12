CREATE PROCEDURE "informix".sp_rep_envio_sms_tc()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--08-27-2012
--crea archivo de sms y email enviados


----DATOS QUE VAN EN LA TABLA
DEFINE  vnumcte			char(20);
DEFINE  vnum_credito 	char(20);
DEFINE	vciudad 		char(6) ;
DEFINE	vestado 		char(6);
DEFINE	vcorreo_sms 	char(100) ;
DEFINE	vnombre1 		char(20) ;
DEFINE	vnombre2 		char(20);
DEFINE	vapell_p 		char(30) ;
DEFINE	vapell_m 		char(30);
DEFINE	vmora 			smallint;
DEFINE	vsdo_venc_int_mora  DECIMAL(18,2);
DEFINE	vpago_minimo_total  DECIMAL(18,2);
DEFINE	vpago_min_sin_vdo   DECIMAL(18,2) ;
DEFINE	vpago_vencido 		DECIMAL(18,2);
DEFINE	vpago_req_mail		DECIMAL(18,2);
DEFINE	vcosto 				decimal (18,2) ;
DEFINE	vfecha_envio 		datetime year to second;
DEFINE	vresultado 			char(10);
DEFINE	vpag1 decimal (18,2); DEFINE vpag2 decimal (18,2);
DEFINE	vpag3 decimal (18,2); DEFINE vpag4 decimal (18,2);
DEFINE	vpag5 decimal (18,2); DEFINE vpag6 decimal (18,2);
DEFINE	vtotal decimal (18,2);
DEFINE vestatus smallint;
--VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(5);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(80);

---VARIABLES PARA QUERYS
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE vsql					CHAR(2204);
DEFINE sPaso				integer;
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnombre				CHAR(100);
define vfecha				DATE;
define vfecha1				DATE;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02')RETURNING P_COD_RET;	
	RETURN P_COD_RET;
    END EXCEPTION;

----INICIALIZAN VARIABLES QUE VAN EN LA TABLA

LET  vnumcte 		="";
LET  vnum_credito	="";
LET	vciudad 		="";
LET	vestado 		="";
LET	vcorreo_sms 	="";
LET	vnombre1 		="";
LET	vnombre2 		="";
LET	vapell_p 		="";
LET	vapell_m 		="";
LET	vmora 			=0;
LET	vsdo_venc_int_mora  =0;
LET	vpago_minimo_total  =0;
LET	vpago_min_sin_vdo   =0;
LET	vpago_vencido 		=0;
LET	vpago_req_mail 		=0;
LET	vcosto 				=0;
LET	vfecha_envio 		=date(1);
LET	vresultado 			="";
LET	vpag1 =0; LET vpag2 =0;
LET	vpag3 =0; LET vpag4 =0;
LET	vpag5 =0; LET vpag6 =0;
LET	vtotal =0;
let vestatus =0;
---INICIALIZAN VARIABLES PARA QUERYS
LET  cSql			="";
LET cSQL1           = "";
LET cSQL2           = "";
LET cSQL3           = "";
let vsql			= '';
Let P_cod_ret		= "00000";
LET vproceso		='2076';
LET cMensaje   		= 'PROCESO EXITOSO';
let sPaso 			=0;
let cruta      		='';
let cdelimitador 	='';
let cnomarchivo  	='';
let cnomarchivo1 	='';
let cnombre 		='';
let vfecha			= date(1);
let vfecha1			= date(1);

  --Set debug file to 'moras.out';
  --trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'credito';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE credito;
            END IF;

	create table credito
	(numcte char(20), num_credito char(20),
	ciudad char(6), estado char(6),
	correo_sms char(100), 
	nombre1 char(20), nombre2 char(20),
	apell_p char(30), apell_m char(30),
	mora smallint,
	sdo_venc_int_mora  DECIMAL(18,2),pago_minimo_total   DECIMAL(18,2),
	pago_min_sin_vdo   DECIMAL(18,2), pago_vencido DECIMAL(18,2),
	pago_req_mail DECIMAL(18,2),
	costo decimal (18,2), fecha_envio date,
	resultado char(10),
	pag1 decimal (18,2),pag2 decimal (18,2),
	pag3 decimal (18,2),pag4 decimal (18,2),
	pag5 decimal (18,2),pag6 decimal (18,2),
	total decimal (18,2)
	);
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = '001'
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 2;
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET P_COD_RET= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = P_COD_RET;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
        Return P_COD_RET;
	END IF;
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 34;
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET P_COD_RET= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = P_COD_RET;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

         CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	     Return P_COD_RET;
	END IF;
--let cruta = '/informix/eli/';
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
--let vfecha = '06-01-2013'; --- PRUEBAS
	
    set isolation to dirty read;
    set lock mode to wait 3;	

---------------------------------------------------PREVENTIVA-------------------------------------------	
if (day(vfecha) = 22) then	
let vfecha = vfecha - 5 units day;
	
/*	select mov.num_credito, mov.fecha_mov , mov.monto
	from bdicobranza:cb_info_administrativa_his his, bdicred:sd_movhis mov
	where mov.empresa= '001' and mov.fecha_mov >= vfecha and mov.fecha_mov <= date(vfecha) + 4 units day 
		and his.credito =  mov.num_credito  
		and mov.codigo_fun in ('033','334','335','336','337','904')	and mov.codigo_ref = 1 	and mov.reversado = 'N'
		and his.num_campania = 18 and his.fecha_ejecucion = vfecha 
	into temp movhis_tc;
*/	
	select {+INDEX(bdicobranza:cb_info_administrativa_his idx_admin3_his)} {+INDEX(bdicred:sd_movhis inx_movhis)} mov.num_credito, mov.fecha_mov , mov.monto
	from bdicobranza:cb_info_administrativa_his his, bdicred:sd_movhis mov
	where 
		 his.num_campania = 18 and his.fecha_ejecucion = vfecha 
        and mov.empresa= '001' 
        and mov.fecha_mov >= vfecha and mov.fecha_mov <= date(vfecha) + 4 units day 
		and his.credito =  mov.num_credito  
		and mov.codigo_fun in ('033','334','335','336','337','904')	and mov.codigo_ref = 1 	and mov.reversado = 'N'
        and producto in ('6001','6600')
	into temp movhis_tc;

	create index idx_movhis_tc on movhis_tc(num_credito,fecha_mov);   UPDATE STATISTICS medium FOR TABLE movhis_tc; 
	
	select {+INDEX(bdimnsj:mnsjr_trx_batch inxb_id_mensaje)} *
	from bdimnsj:mnsjr_trx_batch where id_mensaje ='TC_PAGMINS'
		and date(fecha_hora_registro) = vfecha
	into temp latinia_tc;
	
	FOREACH
		select {+INDEX(bdicobranza:cb_info_administrativa_his idx_admin3_his)} his.cliente, his.credito, 
                his.t_celular, his.nombre1, his.nombre2 , his.apell_paterno  ,his.apell_materno , pago_venc,
--				nvl(his.sdo_venc_int_mora,0) , nvl(his.pago_min,0) , nvl(his.pago_min_sin_vdo,0) , nvl(his.pago_vencido,0) , nvl(his.pago_req_sms,0)
				his.sdo_venc_int_mora, his.pago_min, his.pago_min_sin_vdo, his.pago_vencido, his.pago_req_sms
		into  vnumcte,vnum_credito,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	vapell_m 	,	vmora 	,
				vsdo_venc_int_mora  ,vpago_minimo_total ,	vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail	
		from bdicobranza:cb_info_administrativa_his his
			where his.num_campania = 18
			and his.fecha_ejecucion = vfecha 
		
        if vsdo_venc_int_mora is null then let vsdo_venc_int_mora = 0; end if;
        if vpago_minimo_total is null then let vpago_minimo_total = 0; end if;
        if vpago_min_sin_vdo is null then let vpago_min_sin_vdo = 0; end if;
        if vpago_vencido is null then let vpago_vencido = 0; end if;
        if vpago_req_mail is null then let vpago_req_mail = 0; end if;

		select  est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
		into vciudad,vestado 
		from bdinteg:si_direcciones_actual act,  bdinteg:si_estados est,bdinteg:si_catciudades cid
		where act.estado = est.estado
			and act.ciudad = cid.numerociudad 
			and act.numcte = vnumcte
			and act.tipo_dir = 1;		
			
--		select limit 1 nvl(estatus,0),  date(fecha_hora_registro)
		select limit 1 estatus,  fecha_hora_registro
			into vestatus,vfecha_envio
		from latinia_tc
		where cliente = vnumcte  and   cuenta = vnum_credito;
		--	and date(ts_final) = vfecha; 

		if vestatus is null then let vestatus = 0;	end if;
		if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
		if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
		
--		select nvl(sum(monto),0) into vpag1
		select sum(monto) into vpag1
		from movhis_tc
		where num_credito = vnum_credito AND fecha_mov = vfecha;
		
        if vpag1 is null then let vpag1 = 0; end if;

--		select nvl(sum(monto),0) into vpag2
		select sum(monto) into vpag2
		from movhis_tc
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 1 units day;

        if vpag2 is null then let vpag2 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag3
		select sum(monto) into vpag3
		from movhis_tc
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 2 units day;

        if vpag3 is null then let vpag3 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag4
		select sum(monto) into vpag4
		from movhis_tc
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 3 units day;
		
        if vpag4 is null then let vpag4 = 0; end if;

--		select nvl(sum(monto),0) into vpag5
		select sum(monto) into vpag5
		from movhis_tc 
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 4 units day;

        if vpag5 is null then let vpag5 = 0; end if;
		
		let vtotal =  vpag1 + vpag2 + vpag3 + vpag4 + vpag5;
		if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
		if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
		
		
	insert into credito
	values( vnumcte,vnum_credito,vciudad,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	
	vapell_m ,	vmora ,vsdo_venc_int_mora  ,vpago_minimo_total ,vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail ,	
	0 ,	vfecha_envio ,	vresultado ,vpag1 ,vpag2 ,vpag3 , vpag4 ,vpag5 ,vpag6,vtotal );
	
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	let cnombre = 'rep_envio_sms_tc_prev_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'creditos.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from credito";
		LET cSQL3 = '">'||TRIM(cRuta)||'creditos.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'creditos.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'creditos.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'creditos.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"creditos.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'creditos.unl ' ;
		system vsql; 
end if;
------------------------------------------
TRUNCATE credito;

------------------------------------------------------MORAS---EMIAL---------------------------------------------
if(day(vfecha) = 1)then
	let vfecha = vfecha - 1 units month;
	let vfecha = mdy(month(vfecha),day(26),year(vfecha));
	
	select {+INDEX(bdimnsj:mnsjr_trx_batch inxb_id_mensaje)} *
	from bdimnsj:mnsjr_trx_batch where id_mensaje in ('TC_MORA1','TC_MORA2','TC_MORA3','TC_MORA4','TC_MORA5')
		and date(fecha_hora_registro) = vfecha
	into temp batch;
	
	select mov.num_credito, mov.fecha_mov , mov.monto
	from batch his, bdicred:sd_movhis mov
	where mov.empresa= '001' and mov.fecha_mov >= vfecha and mov.fecha_mov <= date(vfecha) + 4 units day 
		and his.cuenta =  mov.num_credito  
		and mov.codigo_fun in ('033','334','335','336','337','904')	and mov.codigo_ref = 1 	and mov.reversado = 'N'
	into temp movhis_tc_mora;
	
	create index idx_movhis_tc_mora on movhis_tc_mora(num_credito,fecha_mov);   UPDATE STATISTICS medium FOR TABLE movhis_tc_mora; 

FOREACH

	select his.numcte, his.num_credito,  
                his.email, his.pagos_vencidos,
--				nvl(his.sdo_venc_int_mora,0) , nvl(his.pago_minimo,0) , nvl(his.pago_min_sin_venc,0) , nvl(his.pago_venc,0) ,nvl(his.monto_convenio,0),
				his.sdo_venc_int_mora, his.pago_minimo, his.pago_min_sin_venc, his.pago_venc, his.monto_convenio,
--				bat.fecha_hora_registro, nvl(bat.estatus,0)
				bat.fecha_hora_registro, bat.estatus
		into  vnumcte,vnum_credito,vcorreo_sms ,vmora 	,
				vsdo_venc_int_mora  ,vpago_minimo_total ,	vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail,
				vfecha_envio, vestatus 	
		from bdicobranza:cb_mail_cliente_his his,batch bat
		where  his.numcte = bat.cliente and his.num_credito = bat.cuenta 
			and his.tipo_mensaje = 1 and his.pagos_vencidos <= 5
		--	and bat.id_mensaje in ('TC_MORA1','TC_MORA2','TC_MORA3','TC_MORA4','TC_MORA4')
			and his.fecha_insert = vfecha
			
        if vsdo_venc_int_mora is null then let vsdo_venc_int_mora = 0; end if;
        if vpago_minimo_total is null then let vpago_minimo_total = 0; end if;
        if vpago_min_sin_vdo is null then let vpago_min_sin_vdo = 0; end if;
        if vpago_vencido is null then let vpago_vencido = 0; end if;
        if vpago_req_mail is null then let vpago_req_mail = 0; end if;
        if vestatus is null then let vestatus = 0; end if;

		select cte.nombre1, cte.nombre2 , cte.apell_paterno  ,cte.apell_materno 
		into vnombre1 ,vnombre2 ,vapell_p ,vapell_m 
		from bdinteg:si_cliente cte
		where cte.empresa = '001' and cte.numcte = vnumcte;
		
		select  est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
		into vciudad,vestado 
		from bdinteg:si_direcciones_actual act,  bdinteg:si_estados est,bdinteg:si_catciudades cid
		where act.estado = est.estado
			and act.ciudad = cid.numerociudad 
			and act.numcte = vnumcte
			and act.tipo_dir = 1;
	
--		select nvl(sum(monto),0) into vpag1
		select sum(monto) into vpag1
		from movhis_tc_mora
		where num_credito = vnum_credito AND fecha_mov = vfecha;
		
        if vpag1 is null then let vpag1 = 0; end if;

--		select nvl(sum(monto),0) into vpag2
		select sum(monto) into vpag2
		from movhis_tc_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 1 units day;

        if vpag2 is null then let vpag2 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag3
		select sum(monto) into vpag3
		from movhis_tc_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 2 units day;
		
        if vpag3 is null then let vpag3 = 0; end if;

--		select nvl(sum(monto),0) into vpag4
		select sum(monto) into vpag4
		from movhis_tc_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha + 3 units day;

        if vpag4 is null then let vpag4 = 0; end if;

	if (month(vfecha) <> 2)then	
--		select nvl(sum(monto),0) into vpag5
		select sum(monto) into vpag5
		from movhis_tc_mora
		where  fecha_mov = vfecha + 4 units day and num_credito = vnum_credito;

        if vpag5 is null then let vpag5 = 0; end if;
	end if;	
		let vtotal =  vpag1 + vpag2 + vpag3 + vpag4 + vpag5;
		if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
		if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
	
	insert into credito
	values( vnumcte,vnum_credito,vciudad,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	
	vapell_m ,	vmora ,vsdo_venc_int_mora  ,vpago_minimo_total ,vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail ,	
	0 ,	vfecha_envio ,	vresultado ,vpag1 ,vpag2 ,vpag3 , vpag4 ,vpag5 ,vpag6,vtotal );
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	let cnombre = 'rep_envio_email_mora_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_sms.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from credito";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_sms.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_sms.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'archivo_sms.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_sms.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_sms.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_sms.unl ' ;
		system vsql; 
---------------------------		
TRUNCATE credito;  
end if;
---------------------------------------------------------MORA-----SMS-------------------------------------------------------
--	let 	vfecha = '09-05-2013';					-----------------PRUEBAS
if(day(vfecha) = 5)then
	let vfecha = vfecha - 1 units month;
--	if(day(vfecha)= 1) then let vfecha = mdy(month(vfecha),day(22),year(vfecha)); end if;
--	if(day(vfecha)= 2) then let vfecha = mdy(month(vfecha),day(23),year(vfecha)); end if;
--	if(day(vfecha)= 3) then let vfecha = mdy(month(vfecha),day(24),year(vfecha)); end if;
--	if(day(vfecha)= 4) then let vfecha = mdy(month(vfecha),day(25),year(vfecha)); end if;
	if(day(vfecha)= 5) then let vfecha = mdy(month(vfecha),day(22),year(vfecha)); end if;
	
--	select mov.num_credito, mov.fecha_mov , mov.monto
	select {+INDEX(bdicobranza:cb_info_administrativa_his idx_admin3_his)} {+INDEX(bdicred:sd_movhis inx_movhis)} mov.num_credito, mov.fecha_mov , mov.monto
	from bdicobranza:cb_info_administrativa_his his, bdicred:sd_movhis mov
	where 
            his.num_campania = 5 
		and his.fecha_ejecucion >= vfecha and his.fecha_ejecucion <= date(vfecha) + 4 units day  
        and mov.empresa= '001' and mov.fecha_mov >= vfecha and mov.fecha_mov <= date(vfecha) + 8 units day 
		and his.credito =  mov.num_credito  
		and mov.codigo_fun in ('033','334','335','336','337','904')	and mov.codigo_ref = 1 	and mov.reversado = 'N'
        and producto in ('6001','6600')
	into temp movhis_tc_sms_mora;
	
	create index idx_movhis_tc_sms_mora on movhis_tc_sms_mora(num_credito,fecha_mov);   UPDATE STATISTICS medium FOR TABLE movhis_tc_sms_mora; 
		
	select {+INDEX(bdimnsj:mnsjr_trx_batch_his inxb_id_mensaje_his)} * from bdimnsj:mnsjr_trx_batch_his 
	where id_mensaje in ('TC_MORA1S','TC_MORA2S') 
	and date(fecha_hora_registro) >= vfecha and date(fecha_hora_registro) <= date(vfecha) + 4 units day 
	into temp latinia_tc1;
	
	FOREACH

--		select his.cliente, his.credito, 
		select {+INDEX(bdicobranza:cb_info_administrativa_his idx_admin3_his)} his.cliente, his.credito, 
                his.t_celular, his.nombre1, his.nombre2 , his.apell_paterno  ,his.apell_materno , pago_venc,
--				nvl(his.sdo_venc_int_mora,0) , nvl(his.pago_min,0) , nvl(his.pago_min_sin_vdo,0) , nvl(his.pago_vencido,0) , nvl(his.pago_req_sms,0)
				his.sdo_venc_int_mora, his.pago_min, his.pago_min_sin_vdo, his.pago_vencido, his.pago_req_sms
		into  vnumcte,vnum_credito,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	vapell_m 	,	vmora 	,
				vsdo_venc_int_mora  ,vpago_minimo_total ,	vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail	
		from bdicobranza:cb_info_administrativa_his his
			where his.num_campania = 5
			and his.fecha_ejecucion >= vfecha and his.fecha_ejecucion <= date(vfecha) + 4 units day  

        if vsdo_venc_int_mora is null then let vsdo_venc_int_mora = 0; end if;
        if vpago_minimo_total is null then let vpago_minimo_total = 0; end if;
        if vpago_min_sin_vdo is null then let vpago_min_sin_vdo = 0; end if;
        if vpago_vencido is null then let vpago_vencido = 0; end if;
        if vpago_req_mail is null then let vpago_req_mail = 0; end if;
		
		select  est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
		into vciudad,vestado 
		from bdinteg:si_direcciones_actual act,  bdinteg:si_estados est,bdinteg:si_catciudades cid
		where act.estado = est.estado
			and act.ciudad = cid.numerociudad 
			and act.numcte = vnumcte
			and act.tipo_dir = 1;		
		
--		select limit 1 nvl(estatus,0),  date(fecha_hora_registro) 
		select limit 1 estatus,  fecha_hora_registro
			into vestatus,vfecha_envio
		from latinia_tc1
		where cliente = vnumcte and   cuenta  = vnum_credito;

        if vestatus is null then let vestatus = 0; end if;
			
		if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
		if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
		
--		select nvl(sum(monto),0) into vpag1
		select sum(monto) into vpag1
		from movhis_tc_sms_mora
		where num_credito = vnum_credito AND fecha_mov = vfecha_envio;

        if vpag1 is null then let vpag1 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag2
		select sum(monto) into vpag2
		from movhis_tc_sms_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha_envio + 1 units day;

        if vpag2 is null then let vpag2 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag3
		select sum(monto) into vpag3
		from movhis_tc_sms_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha_envio + 2 units day;
		
        if vpag3 is null then let vpag3 = 0; end if;

--		select nvl(sum(monto),0) into vpag4
		select sum(monto) into vpag4
		from movhis_tc_sms_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha_envio + 3 units day;

        if vpag4 is null then let vpag4 = 0; end if;
		
--		select nvl(sum(monto),0) into vpag5
		select sum(monto) into vpag5
		from movhis_tc_sms_mora
		where  num_credito = vnum_credito AND fecha_mov = vfecha_envio + 4 units day;

        if vpag5 is null then let vpag5 = 0; end if;
		
		let vtotal =  vpag1 + vpag2 + vpag3 + vpag4 + vpag5;
			
	insert into credito
	values( vnumcte,vnum_credito,vciudad,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	
	vapell_m ,	vmora ,vsdo_venc_int_mora  ,vpago_minimo_total ,vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail ,	
	0 ,	vfecha_envio ,	vresultado ,vpag1 ,vpag2 ,vpag3 , vpag4 ,vpag5 ,vpag6,vtotal );
	
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
--	LET  cruta = '/informix/eli/';
	let cnombre = 'rep_envio_sms_tc_mora_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'creditos.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from credito";
		LET cSQL3 = '">'||TRIM(cRuta)||'creditos.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'creditos.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'creditos.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'creditos.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"creditos.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'creditos.unl ' ;
		system vsql; 

end if;
--------------------------------------------------------------------------------------------------
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;