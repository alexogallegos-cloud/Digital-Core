CREATE PROCEDURE "informix".sp_rep_envio_mail_compromiso()
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
LET vproceso		='2100';
LET cMensaje   		= 'PROCESO EXITOSO';
let sPaso 			=0;
let cruta      		='';
let cdelimitador 	='';
let cnomarchivo  	='';
let cnomarchivo1 	='';
let cnombre 		='';
let vfecha			= date(1);
let vfecha1			= date(1);



--  Set debug file to 'comprmisos.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'compromisos';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE compromisos;
            END IF;

	create table compromisos
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
	
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
	let vfecha = vfecha - 5 units day;
	
    set isolation to dirty read;
    set lock mode to wait 3;
	
	select mov.num_credito, mov.fecha_mov , mov.monto
	from bdimnsj:mnsjr_trx_batch bat, bdicred:sd_movhis mov
	where mov.empresa= '001' and mov.fecha_mov >= vfecha and mov.fecha_mov <= date(vfecha) + 4 units day 
		and bat.cuenta =  mov.num_credito  
		and mov.codigo_fun in ('033','334','335','336','337','904')	and mov.codigo_ref = 1 	and mov.reversado = 'N'
		and bat.id_mensaje in ('COMPAC_ADE','COMPAC_SIN','COMPAC_PAG','COMPAC_FRA')
		and date(bat.fecha_hora_registro) =  vfecha
	into temp mov_compromiso;
	
	create index idx_mov_compromiso on mov_compromiso(num_credito,fecha_mov);   UPDATE STATISTICS medium FOR TABLE mov_compromiso; 

	
	FOREACH
		select his.numcte, his.num_credito,  est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad,
                his.email, cte.nombre1, cte.nombre2 , cte.apell_paterno  ,cte.apell_materno , his.pagos_vencidos,
				nvl(his.sdo_venc_int_mora,0) , nvl(his.pago_minimo,0) , nvl(his.pago_min_sin_venc,0) , nvl(his.pago_venc,0) , nvl(his.monto_convenio,0),
				bat.fecha_hora_registro, nvl(bat.estatus,0)
		into  vnumcte,vnum_credito,vciudad,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	vapell_m 	,	vmora 	,
				vsdo_venc_int_mora  ,vpago_minimo_total ,	vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail,
				vfecha_envio, vestatus 	
		from bdicobranza:cb_mail_cliente_his his, bdinteg:si_cliente cte,
			bdinteg:si_direcciones_actual act , bdinteg:si_estados est,bdinteg:si_catciudades cid,
			bdimnsj:mnsjr_trx_batch bat
		where his.empresa = cte.empresa and his.numcte = cte.numcte
			and his.numcte = bat.cliente and his.num_credito = bat.cuenta 
			and his.numcte = act.numcte
			and act.estado = est.estado
			and act.ciudad = cid.numerociudad
			and act.tipo_dir = 1
			and his.tipo_mensaje = 3
			and bat.id_mensaje in ('COMPAC_ADE','COMPAC_SIN','COMPAC_PAG','COMPAC_FRA')
			and his.fecha_compac = vfecha 
		
		select nvl(sum(monto),0) into vpag1
		from mov_compromiso
		where  num_credito = vnum_credito and fecha_mov = vfecha;
			
		select nvl(sum(monto),0) into vpag2
		from mov_compromiso
		where  num_credito = vnum_credito and fecha_mov = vfecha + 1 units day;
			
		
		select nvl(sum(monto),0) into vpag3
		from mov_compromiso 
		where num_credito = vnum_credito and fecha_mov = vfecha + 2 units day;
		
		select nvl(sum(monto),0) into vpag4
		from mov_compromiso 
		where num_credito = vnum_credito and fecha_mov = vfecha + 3 units day;
		
		select nvl(sum(monto),0) into vpag5
		from mov_compromiso 
		where  num_credito = vnum_credito and fecha_mov = vfecha + 4 units day;
		
		let vtotal =  vpag1 + vpag2 + vpag3 + vpag4 + vpag5;
		if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
		if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
		
		
	insert into compromisos
	values( vnumcte,vnum_credito,vciudad,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 ,vapell_p 	,	
	vapell_m ,	vmora ,vsdo_venc_int_mora  ,vpago_minimo_total ,vpago_min_sin_vdo  ,vpago_vencido ,vpago_req_mail ,	
	0 ,	vfecha_envio ,	vresultado ,vpag1 ,vpag2 ,vpag3 , vpag4 ,vpag5 ,vpag6,vtotal );
	
	LET  vnumcte 		="";LET  vnum_credito	="";LET	vciudad 		="";LET	vestado 		="";LET	vcorreo_sms 	="";LET	vnombre1 		="";
	LET	vnombre2 		="";LET	vapell_p 		="";LET	vapell_m 		="";LET	vmora 			=0;LET	vsdo_venc_int_mora  =0;
	LET	vpago_minimo_total  =0;LET	vpago_min_sin_vdo   =0;LET	vpago_vencido 		=0;LET	vpago_req_mail 		=0;
	LET	vfecha_envio 		=date(1);LET	vresultado 			="";LET	vpag1 =0; LET vpag2 =0;LET	vpag3 =0; LET vpag4 =0;
	LET	vpag5 =0; LET vpag6 =0;LET	vtotal =0;let vestatus =0;
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
--	let cruta = '/informix/eli/';
	let cnombre = 'rep_envio_email_compromiso_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_compromiso.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from compromisos";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_compromiso.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_compromiso.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'archivo_compromiso.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_compromiso.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_compromiso.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_compromiso.unl ' ;
		system vsql; 
------------------------------------------

	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;