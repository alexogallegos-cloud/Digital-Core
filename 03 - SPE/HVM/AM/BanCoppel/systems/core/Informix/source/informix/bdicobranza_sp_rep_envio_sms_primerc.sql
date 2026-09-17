CREATE PROCEDURE "informix".sp_rep_envio_sms_primerc()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--08-27-2012
--crea archivo de sms y email enviados


----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte 			char(20);
DEFINE vnum_credito 	char(20);
DEFINE vciudad 			char(6);
DEFINE vestado 			char(6);
DEFINE vcorreo_sms 		char(100);
DEFINE vnombre1 		char(20);
DEFINE vnombre2 		char(20);
DEFINE vapell_p 		char(30);
DEFINE vapell_m 		char(30);
DEFINE vcosto 			decimal (18,2) ;
DEFINE vfecha_envio	 	date;
DEFINE vresultado 		char(10);
DEFINE vmora 			smallint ;
DEFINE vfecha_apertura 	date;
DEFINE vfecha_pricon 	date;
DEFINE vlinea_cred 		decimal (18,2);
DEFINE vtipo_trans 		char(30);
DEFINE vmonto_trans  	decimal(18,2);
DEFINE vporcentaje_uso 	decimal(18,2);
define vtrans_primer_compra char(4);
define vdescripcion		char(30);
define vcodigo_fun 		char(3);
define vcodigo_ref		smallint;
define vestatus 		smallint;
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
define vfecha_ejecucion		date;
define vfecha3 			date;
define vfecha2 			date;
define vimporte1		DECIMAL(18,2);
define vimporte2 		DECIMAL(18,2); 

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02')RETURNING P_COD_RET;	
	RETURN P_COD_RET;
    END EXCEPTION;

----INICIALIZAN VARIABLES QUE VAN EN LA TABLA
LET vnumcte 			="";
LET vnum_credito 		="";
LET vciudad 			="";
LET vestado 			="";
LET vcorreo_sms 		="";
LET vnombre1 			="";
LET vnombre2 			="";
LET vapell_p 			="";
LET vapell_m 			="";
LET vcosto 				=0;
LET vfecha_envio	 	=date(1);
LET vresultado 			="";
LET vmora 				=0;
LET vfecha_apertura 	=date(1);
LET vfecha_pricon 		=date(1);
LET vlinea_cred 		=0;
LET vtipo_trans 		="";
LET vmonto_trans  		=0;
LET vporcentaje_uso 	=0;
let vtrans_primer_compra = '';
let vdescripcion		="";
let vcodigo_fun 		="";
let vcodigo_ref			=0;
let vestatus			 =0;
---INICIALIZAN VARIABLES PARA QUERYS
LET  cSql			="";
LET cSQL1           = "";
LET cSQL2           = "";
LET cSQL3           = "";
let vsql			= '';
Let P_cod_ret		= "00000";
LET vproceso		='2075';
LET cMensaje   		= 'PROCESO EXITOSO';
let sPaso 			=0;
let cruta      		='';
let cdelimitador 	='';
let cnomarchivo  	='';
let cnomarchivo1 	='';
let cnombre 		='';
let vfecha			= date(1);
let vfecha1			= date(1);
let vfecha_ejecucion = date(1);
let vfecha3 		= date(1);
let vfecha2 		= date(1);
let vimporte1		= 0;
let vimporte2 		= 0; 



--  Set debug file to 'rep_primerc.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'primer_consumo';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE primer_consumo;
            END IF;

	create table primer_consumo
	(numcte char(20), num_credito char(20),
	ciudad char(6), estado char(6),
	correo_sms char(100), 
	nombre1 char(20), nombre2 char(20),
	apell_p char(30), apell_m char(30),
	costo decimal (18,2), fecha_envio date,
	resultado char(10),
	mora smallint, fecha_apertura date,
	fecha_pricon date, linea_cred decimal (18,2),
	tipo_trans char(30), monto_trans  decimal(18,2),
	porcentaje_uso decimal(18,2)) ;

	
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
	let vfecha1 = vfecha - 1 units month;
	
    set isolation to dirty read;
    set lock mode to wait 3;
	
	select *
	from bdimnsj:mnsjr_trx_batch where id_mensaje = 'TC_PRIMERS'
		and date(fecha_hora_registro) >= vfecha1 and  date(fecha_hora_registro) < vfecha
	into temp sms_latinia_pc;
	
	select *
	from bdicred:sd_movhis 
	where num_credito in (select credito from bdicobranza:cb_info_administrativa_his where num_campania = 16 
																and	fecha_ejecucion >= vfecha1 	and fecha_ejecucion < vfecha)
		and fecha_mov >= vfecha1 
		and fecha_mov < vfecha 
		and reversado = 'N'
	into temp movhis_pc;
	
	FOREACH
	select his.cliente, his.credito, his.t_celular, his.nombre1, his.nombre2 , his.apell_paterno  ,his.apell_materno ,
           dos.mto_fin_ven_trasp,dos.monto_otorgado, his.fecha_ejecucion
	into vnumcte,vnum_credito,vcorreo_sms,vnombre1,vnombre2,vapell_p,vapell_m,
		 vmora,vlinea_cred,vfecha_ejecucion
	from bdicobranza:cb_info_administrativa_his his, bdicred:sd_maesdos dos
	where his.empresa = dos.empresa and his.credito = dos.num_credito
        and his.num_campania = 16
		and his.fecha_ejecucion >= vfecha1 
		and his.fecha_ejecucion < vfecha
	
	select limit 1 ind.fecha_alta, ind.f_primer_compra ,ind.monto_primer_compra,ind.f_primer_disp, ind.monto_primer_disp, ind.trans_primer_compra
	into vfecha_apertura, vfecha2,vimporte1,vfecha3,vimporte2, vtrans_primer_compra
	from bdicred:sd_indicador_cred ind
	where ind.empresa = '001' and ind.num_credito = vnum_credito ;
	
	if (vfecha2 >= vfecha3) then let vmonto_trans = vimporte1; let vfecha_pricon = vfecha2; end if;
	if (vfecha3 > vfecha2) then let vmonto_trans = vimporte2; let vfecha_pricon = vfecha3; end if;
	
	let vporcentaje_uso = (vmonto_trans/vlinea_cred)*100;
		
	select limit 1 est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
	into vestado,vciudad
	from  bdinteg:si_direcciones_actual act , bdinteg:si_estados est,bdinteg:si_catciudades cid
	where act.estado = est.estado
        and act.ciudad = cid.numerociudad
		and act.tipo_dir = '1'
		and act.numcte = vnumcte;
		
	select limit 1 nvl(estatus,0),  date(fecha_hora_registro) 
			into vestatus,vfecha_envio
		from sms_latinia_pc
		where cliente = vnumcte and   cuenta  = vnum_credito
			and date(fecha_hora_registro) = date(vfecha_ejecucion);
			
	if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
	if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
		
	select limit 1 codigo_fun, codigo_ref into vcodigo_fun, vcodigo_ref
	from movhis_pc 
	where num_credito = vnum_credito
		and fecha_mov = vfecha_pricon and transacc_suc = vtrans_primer_compra and reversado = 'N';

	select descripcion into vdescripcion
	from bdicred:sd_transfun where codigo_fun = vcodigo_fun and codigo_ref = vcodigo_ref;
	
 	let vtipo_trans = vdescripcion;

	insert into primer_consumo
	values(vnumcte ,vnum_credito ,vciudad 	,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 , vapell_p ,vapell_m 	,0 ,vfecha_envio,
	vresultado ,vmora ,vfecha_apertura , vfecha_pricon 	,vlinea_cred ,vtipo_trans ,vmonto_trans ,vporcentaje_uso );
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	let cnombre = 'rep_envio_sms_primerc_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_sms.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from primer_consumo";
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
------------------------------------------
truncate primer_consumo;
LET vnumcte 			="";LET vnum_credito 		="";LET vciudad 			="";LET vestado 			="";
LET vcorreo_sms 		="";LET vnombre1 			="";LET vnombre2 			="";LET vapell_p 			="";
LET vapell_m 			="";LET vcosto 				=0;LET vfecha_envio	 	=date(1);LET vresultado 			="";
LET vmora 				=0;LET vfecha_apertura 	=date(1);LET vfecha_pricon 		=date(1);LET vlinea_cred 		=0;
LET vtipo_trans 		="";LET vmonto_trans  		=0;LET vporcentaje_uso 	=0;let vtrans_primer_compra = '';
let vdescripcion		="";let vcodigo_fun 		="";let vcodigo_ref			=0;
------------------------------------------	
																
select * 
from bdimnsj:mnsjr_trx_batch  bat
where bat.fecha_hora_registro >= vfecha1 
	and bat.fecha_hora_registro < vfecha
	and bat.id_mensaje ='TC_PRIMERC'
into temp trx_batch_pc;

select *
	from bdicred:sd_movhis 
	where num_credito in (select cuenta from trx_batch_pc)
		and fecha_mov >= vfecha1 
		and fecha_mov < vfecha 
		and reversado = 'N'
	into temp movhis_pc1;

FOREACH
	
	select his.numcte, his.num_credito, his.email,
           dos.mto_fin_ven_trasp, dos.monto_otorgado, nvl(his.saldo_total,0),
          (his.saldo_total/dos.monto_otorgado)*100
	into vnumcte,vnum_credito,vcorreo_sms,
		 vmora,vlinea_cred,vmonto_trans,vporcentaje_uso
	from bdicobranza:cb_mail_cliente_his his, bdicred:sd_maesdos dos
	where his.empresa = dos.empresa and his.num_credito = dos.num_credito
        and his.tipo_mensaje = 1 and his.pagos_vencidos = 10
		and his.fecha_insert >= vfecha1 
		and his.fecha_insert < vfecha
	
	select limit 1 ind.fecha_alta, ind.f_primer_compra ,ind.f_primer_disp, ind.trans_primer_compra
	into vfecha_apertura, vfecha2,vfecha3, vtrans_primer_compra
	from bdicred:sd_indicador_cred  ind
	where ind.empresa = '001' and ind.num_credito = vnum_credito ;
	
		if (vfecha2 >= vfecha3) then let vfecha_pricon = vfecha2; end if;
		if (vfecha3 > vfecha2) then  let vfecha_pricon = vfecha3; end if;
		
	select  limit 1 cte.nombre1, cte.nombre2 , cte.apell_paterno  ,cte.apell_materno 
	into vnombre1,vnombre2,vapell_p,vapell_m
	from bdinteg:si_cliente cte
	where cte.numcte  = vnumcte;
		
	select limit 1 est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
	into vestado,vciudad
	from  bdinteg:si_direcciones_actual act , bdinteg:si_estados est,bdinteg:si_catciudades cid
	where act.estado = est.estado
        and act.ciudad = cid.numerociudad
		and act.tipo_dir = '1'
		and act.numcte = vnumcte;
		
	select limit 1 codigo_fun, codigo_ref into vcodigo_fun, vcodigo_ref
	from movhis_pc1
	where num_credito = vnum_credito
		and fecha_mov = vfecha_pricon and transacc_suc = vtrans_primer_compra;

	select descripcion into vdescripcion
	from bdicred:sd_transfun where codigo_fun = vcodigo_fun and codigo_ref = vcodigo_ref;
	
 	let vtipo_trans = vdescripcion;
	
	select limit 1 bat.fecha_hora_registro, nvl(bat.estatus,0)
	into  vfecha_envio,	vestatus
	from trx_batch_pc  bat
	where cliente = vnumcte 
		and cuenta = vnum_credito;
	
	if (vestatus = 1 )then	let vresultado = 'COMPLETO';	end if;
	if (vestatus <> 1 )then	let vresultado = 'INCOMPLETO';	end if;
  	
	insert into primer_consumo
	values(vnumcte ,vnum_credito ,vciudad 	,vestado ,vcorreo_sms ,vnombre1 ,vnombre2 , vapell_p ,vapell_m 	,vcosto ,vfecha_envio,
	vresultado ,vmora ,vfecha_apertura , vfecha_pricon 	,vlinea_cred ,vtipo_trans ,vmonto_trans ,vporcentaje_uso );
		
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	let cnombre = 'rep_envio_email_primerc_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_sms.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from primer_consumo";
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
------------------------------
drop table primer_consumo;
------------------------------
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;