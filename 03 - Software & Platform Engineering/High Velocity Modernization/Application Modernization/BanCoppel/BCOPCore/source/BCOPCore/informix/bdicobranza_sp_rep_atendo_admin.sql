CREATE PROCEDURE "informix".sp_rep_atendo_admin()
returning char (5);
------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--02-03-2012
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1
----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte			char(20);
DEFINE vnum_credito		char(20);
DEFINE vnum_tarjeta		char(20);
DEFINE vint_moratorio	decimal(18,2);
DEFINE vsdo_tot_liq		decimal(18,2);
DEFINE vsdo_venc_tot	decimal(18,2);
DEFINE vmens_actual		decimal(18,2);
DEFINE vnum_venc_ini	smallint;
DEFINE vnum_venci_fin	smallint;
DEFINE vstatus_cred		char(2);
DEFINE vfecha_ult_pag	date;
DEFINE vpago_1_mora		decimal(18,2);
DEFINE vciudad			smallint;
DEFINE vdescripcion		char(40);
DEFINE vregion			char(30);
DEFINE vcallc			smallint;
DEFINE vnum_pagos		smallint;
DEFINE vmonto_pagos		decimal(18,2);
DEFINE vresultado_gestion smallint;


---VARIABLES PARA CAPTURAR ERRORES
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
DEFINE icontador 			  SMALLINT;
DEFINE sPaso integer;
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnombre				CHAR(100);
define vfecha				DATE;
define vfechas				DATE;
define keyx					integer;


	--Set debug file to '/informix/Elizabeth/cb_cat_atento_admin_reporte.out';
	--trace on;
BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02');
        RETURN P_COD_RET;
    END EXCEPTION;

----INICIALIZAN VARIABLES QUE VAN EN LA TABLA
LET vnumcte			='';
LET vnum_credito	='';
LET vnum_tarjeta	='';
LET vint_moratorio	=0;
LET vsdo_tot_liq	=0;
LET vsdo_venc_tot	=0;
LET vmens_actual	=0;
LET vnum_venc_ini	=0;
LET vnum_venci_fin	=0;
LET vstatus_cred	='';
LET vfecha_ult_pag	=date(1);
LET vpago_1_mora	=0;
LET vciudad			=0;
LET vdescripcion	='';
LET vregion			='';
LET vcallc			=0;
LET vnum_pagos		=0;
LET vmonto_pagos	=0;
LET vresultado_gestion	=0;


---INICIALIZAN VARIABLES PARA QUERYS
LET  cSql		="";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
Let P_cod_ret	= "00000";
LET icontador 	= 0;
LET vproceso	='2064';
LET cMensaje    = 'PROCESO EXITOSO';
let sPaso =0;
let cruta       ='';
let cdelimitador  ='';
let cnomarchivo  ='';
let cnomarchivo1  ='';
let cnombre ='';
let vfecha = date(1);
let vfechas = date(1);
let keyx	=0;


	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01');
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_cat_atento_admin_reporte';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_cat_atento_admin_reporte;
            END IF;

	create table cb_cat_atento_admin_reporte
        (numcte			char(20),
		num_credito		char(20),
		num_tarjeta		char(20),
		int_moratorio	decimal(18,2),
		sdo_tot_liq		decimal(18,2),
		sdo_venc_tot	decimal(18,2),
		mens_actual		decimal(18,2),
		num_venc_ini	smallint,
		num_venci_fin	smallint,
		status_cred		char(2),
		fecha_ult_pag	date,
		pago_1_mora		decimal(18,2),
		ciudad			smallint,
		descripcion		char(40),
		region			char(30),
		callc			smallint,
		num_pagos		smallint,
		monto_pagos		decimal(18,2),
		resultado_gestion smallint)  ;

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

        CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01');
        Return P_COD_RET;
	END IF;
	
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
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

        CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01');
        Return P_COD_RET;
	END IF;
	
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
--let vfecha = '04-21-2012';--pruebas
	let vfecha = mdy(month(vfecha),day(20),year(vfecha));
	LET vfechas = vfecha - 1 UNITS MONTH;
	LET vfechas = mdy(month(vfechas),day(21),year(vfechas));
	
    set isolation to dirty read;
    set lock mode to wait 3;
/*
	select tienda  
	from bdicobranza:cb_cat_movimientos 
		where horainicio <= date(vfecha) and horainicio >= date(vfechas)
		group by  tienda  into temp cat_movimientos;
	select tienda  
	from bdicobranza:cb_atento_movimientos 
		where horainicio <= date(vfecha) and horainicio >= date(vfechas)
		group by  tienda  into temp atento_movimientos;
*/	
	select num_credito tienda
	from cb_cat_directorio_cte_his 
	where pago_venc = 1 and fecha_insert = vfechas
	and tipo_cobranza = 'A'
	and call_c is null
	into temp cat_movimientos;
	
	select num_credito tienda
	from cb_cat_directorio_cte_his 
	where pago_venc = 1 and fecha_insert = vfechas
	and tipo_cobranza = 'A'
	and call_c = 2
	into temp atento_movimientos;
	
	FOREACH
		
		SELECT mae.numcte,t.tienda ,tar.num_tarjeta, maes.mto_fin_ven_trasp,mae.status_cred,anex.fecha_ult_pago,
				dir.ciudad,  ci.nombreciudadcoppel,r.nombre_region,1 call_c, maes.mto_venc_trasp
		INTO vnumcte, vnum_credito, vnum_tarjeta, vnum_venci_fin, vstatus_cred, vfecha_ult_pag,
				vciudad	,vdescripcion,vregion, vcallc,vsdo_venc_tot
		from  cat_movimientos t 
		JOIN bdicred:sd_maecred mae on (mae.num_credito = t.tienda)
		join bdicred:sd_maesdos maes on (maes.empresa =mae.empresa and maes.num_credito = mae.num_credito )
		join bdicred:sd_maecredanexo anex on (anex.empresa =mae.empresa and anex.num_credito = mae.num_credito)
		join bdinteg:si_direcciones_actual dir on (dir.numcte = mae.numcte and tipo_dir = 1)
		left join bdinteg:si_catciudades ci on (ci.numerociudad = dir.ciudad)
		left join bdinteg:si_regiones r on ( r.numero_region = ci.numero_region ) 
		left join bdicred:sd_tarjeta tar on (tar.num_credito = t.tienda and tar.secuencia = (select max(secuencia)
                                from bdicred:sd_tarjeta 
                                where empresa = '001'
                                and num_credito = t.tienda
                                and tipo_tarjeta ='T' and status_tar = 'A')
                                and tar.tipo_tarjeta ='T'  and tar.status_tar = 'A')  
		
		select first 1 max(keyx)keyx, finllamada  into keyx,vresultado_gestion
		from bdicobranza:cb_cat_movimientos 
		where cvemovimiento = 'L' and tipomovimiento =1
			and date(horainicio) <= vfecha
			and date(horainicio) >= vfechas           
			and tienda = vnum_credito
		group by finllamada;
	
		LET vnum_venc_ini = 1;
		
		SELECT  count(monto),SUM(MONTO) INTO Vnum_pagos	,Vmonto_pagos		
		FROM bdicred:sd_movhis 
		WHERE empresa= '001'
			and fecha_mov <= vfecha  --corre el 22
			and fecha_mov >=  vfechas
			AND num_credito = vnum_credito 
			and codigo_fun in ('033','334','335','336','337','904') AND codigo_ref = 1
			AND reversado = 'N';
		
	------------------------------SALDOS----------------------------------
	
		select pago_una_mora,mensualidad_actual,moratorio ,
		(sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid
		into vpago_1_mora, vmens_actual, vint_moratorio, vsdo_tot_liq
		from bdicred:sd_sdos_cartera_linea 
		where num_credito = vnum_credito;
	
	-----------------------------------------------------------------------
	
        INSERT INTO  bdicobranza:cb_cat_atento_admin_reporte 
		(numcte,num_credito	,num_tarjeta,int_moratorio,sdo_tot_liq,sdo_venc_tot,mens_actual,num_venc_ini,num_venci_fin,
			status_cred,fecha_ult_pag,pago_1_mora,ciudad,descripcion,region,callc,num_pagos,monto_pagos,resultado_gestion)
	    VALUES (		nvl ( vnumcte,' ' ),
                        nvl ( replace ( replace( vnum_credito , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_tarjeta , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vint_moratorio , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vsdo_tot_liq , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vsdo_venc_tot , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vmens_actual , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_venc_ini , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_venci_fin , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vstatus_cred , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vfecha_ult_pag, date(1) ),
						nvl ( replace ( replace( vpago_1_mora , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vciudad , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vdescripcion , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vregion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vcallc , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_pagos , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vmonto_pagos , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vresultado_gestion , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table bdicobranza:cb_cat_atento_admin_reporte;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
		
	LET vnumcte			='';
	LET vnum_credito	='';
	LET vnum_tarjeta	='';
	LET vint_moratorio	=0;
	LET vsdo_tot_liq	=0;
	LET vsdo_venc_tot	=0;
	LET vmens_actual	=0;
	LET vnum_venc_ini	=0;
	LET vnum_venci_fin	=0;
	LET vstatus_cred	='';
	LET vfecha_ult_pag	=date(1);
	LET vpago_1_mora	=0;
	LET vciudad			=0;
	LET vdescripcion	='';
	LET vregion			='';
	LET vcallc			=0;
	LET vnum_pagos		=0;
	LET vmonto_pagos	=0;
	LET vresultado_gestion	=0;
	
	END FOREACH;
	
LET vnumcte			='';
LET vnum_credito	='';
LET vnum_tarjeta	='';
LET vint_moratorio	=0;
LET vsdo_tot_liq	=0;
LET vsdo_venc_tot	=0;
LET vmens_actual	=0;
LET vnum_venc_ini	=0;
LET vnum_venci_fin	=0;
LET vstatus_cred	='';
LET vfecha_ult_pag	=date(1);
LET vpago_1_mora	=0;
LET vciudad			=0;
LET vdescripcion	='';
LET vregion			='';
LET vcallc			=0;
LET vnum_pagos		=0;
LET vmonto_pagos	=0;
LET vresultado_gestion	=0;	

	FOREACH
		
		SELECT mae.numcte,t.tienda ,tar.num_tarjeta, maes.mto_fin_ven_trasp,mae.status_cred,anex.fecha_ult_pago,
				dir.ciudad,  ci.nombreciudadcoppel,r.nombre_region,2 call_c, maes.mto_venc_trasp
		INTO vnumcte, vnum_credito, vnum_tarjeta, vnum_venci_fin, vstatus_cred, vfecha_ult_pag,
				vciudad	,vdescripcion,vregion, vcallc,vsdo_venc_tot
		from  atento_movimientos t 
		JOIN bdicred:sd_maecred mae on (mae.num_credito = t.tienda)
		join bdicred:sd_maesdos maes on (maes.num_credito = mae.num_credito )
		join bdicred:sd_maecredanexo anex on (anex.num_credito = mae.num_credito)
		join bdinteg:si_direcciones_actual dir on (dir.numcte = mae.numcte and tipo_dir = 1)
		left join bdinteg:si_catciudades ci on (ci.numerociudad = dir.ciudad)
		left join bdinteg:si_regiones r on ( r.numero_region = ci.numero_region ) 
		left join bdicred:sd_tarjeta tar on (tar.num_credito = t.tienda and tar.secuencia = (select max(secuencia)
                                from bdicred:sd_tarjeta 
                                where empresa = '001'
                                and num_credito = t.tienda
                                and tipo_tarjeta ='T' and status_tar = 'A')
                                and tar.tipo_tarjeta ='T'  and tar.status_tar = 'A') 
		
		select first 1 max(keyx)keyx, finllamada  into keyx,vresultado_gestion
		from bdicobranza:cb_cat_movimientos 
		where cvemovimiento = 'L' 
			and date(horainicio) <= vfecha
			and date(horainicio) >= vfechas           
			and tienda = vnum_credito
		group by finllamada;
	
		LET vnum_venc_ini = 1;
		
		SELECT  count(monto),SUM(MONTO) INTO Vnum_pagos	,Vmonto_pagos		
		FROM bdicred:sd_movhis 
		WHERE empresa= '001'
			and fecha_mov <= vfecha  --corre el 22
			and fecha_mov >=  vfechas
			AND num_credito = vnum_credito 
			and codigo_fun in ('033','334','335','336','337','904') AND codigo_ref = 1
			AND reversado = 'N';
		------------------------------SALDOS----------------------------------
		select pago_una_mora,mensualidad_actual,moratorio ,
			(sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid
		into vpago_1_mora, vmens_actual, vint_moratorio, vsdo_tot_liq
		from bdicred:sd_sdos_cartera_linea 
		where num_credito = vnum_credito;

	-----------------------------------------------------------------------
	
        INSERT INTO  bdicobranza:cb_cat_atento_admin_reporte 
		(numcte,num_credito	,num_tarjeta,int_moratorio,sdo_tot_liq,sdo_venc_tot,mens_actual,num_venc_ini,num_venci_fin,
			status_cred,fecha_ult_pag,pago_1_mora,ciudad,descripcion,region,callc,num_pagos,monto_pagos,resultado_gestion)
	    VALUES (		nvl ( vnumcte,' ' ),
                        nvl ( replace ( replace( vnum_credito , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_tarjeta , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vint_moratorio , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vsdo_tot_liq , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vsdo_venc_tot , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vmens_actual , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_venc_ini , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_venci_fin , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vstatus_cred , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vfecha_ult_pag, date(1) ),
						nvl ( replace ( replace( vpago_1_mora , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vciudad , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vdescripcion , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vregion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vcallc , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnum_pagos , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vmonto_pagos , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vresultado_gestion , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table bdicobranza:cb_cat_atento_admin_reporte;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
		
	LET vnumcte			='';
	LET vnum_credito	='';
	LET vnum_tarjeta	='';
	LET vint_moratorio	=0;
	LET vsdo_tot_liq	=0;
	LET vsdo_venc_tot	=0;
	LET vmens_actual	=0;
	LET vnum_venc_ini	=0;
	LET vnum_venci_fin	=0;
	LET vstatus_cred	='';
	LET vfecha_ult_pag	=date(1);
	LET vpago_1_mora	=0;
	LET vciudad			=0;
	LET vdescripcion	='';
	LET vregion			='';
	LET vcallc			=0;
	LET vnum_pagos		=0;
	LET vmonto_pagos	=0;
	LET vresultado_gestion	=0;
	
    END FOREACH;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/Elizabeth/';
	let cnombre = 'reporte_admin_atento_result';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(vfecha,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(vfecha,'%d%m%Y')||'.txt';
	 
		let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicobranza:cb_cat_atento_admin_reporte ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
		--SE COMPRIME EL ARCHIVO	
	LET cSql = "gzip " || trim(cruta) || trim(cnomarchivo); 
	system cSql;
	
	--Borra el archivo de control.
	LET cSQL = '';
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta.sql';
	SYSTEM cSQL;

    LET cSQL = ''; 
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 
	
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03');
    RETURN P_COD_RET;

end;
end procedure;