create procedure "informix".sp_rep_crednorevolventes_pbajj()
-- execute procedure "informix".sp_rep_crednorevolventes_pbajj();
returning VARCHAR(6), char(50);  
-- returning VARCHAR(6),char(50);--pruebas

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE cProceso  char(4);
DEFINE cMensaje  char (50);
DEFINE cCod_ret  smallint;
DEFINE sPaso				integer;
DEFINE cSQL                 CHAR(2204);
DEFINE vsql					CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnombre          CHAR(100);

DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE vsdoprin      DECIMAL(18,2);
define vpagmes 		 DECIMAL(18,2);
define vparteprin	 DECIMAL(18,2);
define vparteint 	 DECIMAL(18,2);
define vtasaint 	 DECIMAL(6,2);
DEFINE vfecha_venci	date;
DEFINE vstatus		char(2);
DEFINE vgrado		char(2);
DEFINE vnumprod		char(4);
define pfechahoy   	 date;
define vpri_dia_mes   date;
define vfecha		 date;
define vdia_corte	smallint;
define vfecha_rev	date;
define vcred		char(20);
define vult_dia_mes  date;
--IPCB 10062014: nuevas variables campos requeridos RQM 07 263-2
define v_saldototal      decimal(18,2);
define v_partecapital_act decimal(18,2);
define v_partecapital_ven decimal(18,2);
define v_partecapital    decimal(18,2);
define v_intvig decimal(18,2);
define v_invenc decimal(18,2);
define v_parteinteres    decimal(18,2);
define vfecha_apertura   date;
define vbandera_anticipo smallint;

	let P_COD_RET = '000000';
	let cCod_ret = '';
  let cMensaje = 'PROCESO EXITOSO';
	let cproceso = '2081';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let sPaso 			=0;
let cSQL            = '';
let vsql			= '';
let cSQL1           = '';
let cSQL2           = '';
let cSQL3           = '';
let cruta           = '';
let cdelimitador    = '|';
let cnombre         = '';
	
let pnumcredito  	= '';
let pnumcte			= '';
let vsdoprin    	=0;
let vpagmes 		=0;
let vparteprin		=0;
let vparteint 		=0;
let vtasaint 		=0;
let vfecha_venci	=date(1);
let vstatus			= '';
let vgrado			= '';
let vnumprod		= '';
let pfechahoy   	 = date(1);
let vpri_dia_mes	 = date(1);
let vfecha			 = date(1);
let vdia_corte 		= 0;
let vfecha_rev		= date(1);
let vcred			= '';
let vult_dia_mes	= date(1);
--IPCB 10062014: nuevas variables campos requeridos RQM 07 263-2
let v_saldototal      = 0;
let v_partecapital_act = 0;
let v_partecapital_ven = 0;
let v_partecapital    = 0;
let v_intvig		  = 0;	
let v_invenc          = 0;
let v_parteinteres    = 0;
let vfecha_apertura   = date(1);
let vbandera_anticipo = 0;
	

BEGIN 
  

  ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
   /* CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;*/
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        --RETURN P_COD_RET;
        RETURN P_COD_RET, trim(pnumcte) || " - " || trim(pnumcredito); 
     END exception;
	 
-- SET DEBUG FILE TO 'repnorev.out';
-- TRACE ON;	
	
	--seleccionar la ruta del archivo
	select trim(valor) into cruta
	from bdicred:sd_param
	where empresa = '001'
	and cod_param = '49';
			
  /*  CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;*/ 

	set isolation to dirty read;

	
	select date(pri_dia_mes) - 1 units day,fecha_hoy, ult_dia_mes 
		into vpri_dia_mes,pfechahoy ,vult_dia_mes
	 from bdicred:sd_fechas where empresa = '001';
--let pfechahoy = '10-06-2014';   -- pruebas
--let vpri_dia_mes = '09-30-2014'; -- pruebas
--let vult_dia_mes = '10-31-2014'; -- pruebas	
if not exists (select fecha from sd_cred_revolventes where fecha = vpri_dia_mes) then
		truncate sd_cred_revolventes;
	end if;
	
--IPCB 10062014: universo créditos con pago anticipado RQM 07 263-2
select {+INDEX(bdicred:sd_movhiscrd inx_movcrd)} num_credito
from bdicred:sd_movhiscrd
where empresa = '001'
--and fecha_mov between date(1) and vpri_dia_mes
and fecha_mov <= vpri_dia_mes
and num_credito >= ''
and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
and codigo_ref = 1
and reversado = 'N'
and referencia = 'ANTICIPO'
INTO temp cred_anticipo WITH NO LOG;

begin;
create index idx_cred_anticipo on cred_anticipo(num_credito) online;
update statistics high for table cred_anticipo;
commit;

	
	foreach WITH HOLD
--IPCB 10062014: Se integran nuevos campos solicitados, fecha apertura RQM 07 263-2
	select  mae.num_credito,mae.numcte,/*maes.sdo_capital,*/NVL(maes.sdo_cap_insoluto,0) vsdoprin,mae.tasa_interes,mae.fecha_vencim,
			mae.status_cred,mae.num_producto,anex.dia_corte,mae.fecha_apertura
	into pnumcredito,pnumcte,vsdoprin,vtasaint,vfecha_venci,vstatus,vnumprod,vdia_corte,vfecha_apertura
	from bdicred:sd_maecredcontcrd mae,bdicred:sd_maesdoscontcrd maes,bdicred:sd_maecredanexocrd anex
	where mae.fecha = vpri_dia_mes and mae.fecha = maes.fecha 
	and mae.empresa = maes.empresa and mae.num_credito = maes.num_credito
	and anex.empresa = mae.empresa and anex.num_credito = mae.num_credito 
	and mae.num_producto in ('6011','6300','6400') 
    And mae.campo_trab3 <> 'BAJA'
	and mae.num_credito not in (select num_credito from sd_cred_revolventes)
--pruebas
--and mae.sucursal in ('0223','0392','0109')


  if pnumcredito is null or pnumcredito = '' then
     continue foreach; 
  end if

	
	let vbandera_anticipo = 0;
		
	if (vdia_corte > day(vult_dia_mes)) then
			let vdia_corte = day(vult_dia_mes);
    end if;
	
	let vfecha = mdy(month(pfechahoy),vdia_corte,year(pfechahoy));
	
	select limit 1 capital_mto_cuota, capital_debe, interes_debe 
	into vpagmes,vparteprin,vparteint
	from bdicred:sd_amortiza_creditocrd 
	where empresa = '001' and num_credito = pnumcredito
		and fecha_cuota = vfecha;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
		select status_cred into vstatus
		from  bdicred:sd_maecredcrd where empresa = '001' and num_credito = pnumcredito;
	end if;
	
--IPCB 10062014: Asignación de parte parte de capital y de interes RQM 07 263-2	(sol_correo)
IF vnumprod <> '6011' THEN
	--IF DBINFO("sqlca.sqlerrd2") = 1 THEN  
		select his.grado_riesgo, saldo_cierre ,saldo_insoluto, (intereses_vigente+intereses_devengados+intereses_vencidos),pago_minimo
        into vgrado,v_saldototal, v_partecapital,v_parteinteres,vpagmes
		from bdicred:sd_hist_reserva_cnr his 
		where his.empresa= '001' and his.num_credito = pnumcredito and his.fecha_cierre = vpri_dia_mes;
	--end if;
END IF
			
	if exists (select num_credito from cred_anticipo where num_credito = pnumcredito) then
	   let vbandera_anticipo= 1;
	end if;
	
--IPCB 10062014: Se modifica el insert a la sd_cred_revolventes RQM 07 263-2		
	begin work;	
		INSERT INTO bdicred:sd_cred_revolventes 
		VALUES('001',pnumcredito,pnumcte,vsdoprin,vpagmes,vparteprin,vparteint,vtasaint,vfecha_venci,vstatus,vgrado,vnumprod,vpri_dia_mes,v_saldototal,v_partecapital,v_parteinteres,vfecha_apertura,vbandera_anticipo);
	commit work;
	 
	end foreach 

	--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
--let cruta = '/informix/eli/'; -- pruebas

	
	let cnombre = 'rep_creditonorevolvente_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_revolventes.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		--LET cSQL2 = " select num_credito,numcte,sdoprincipal,pagomes,parteprincipal,parteinteres,tasainteres,fecha_vencimiento,status,grado_riesgo,num_producto from sd_cred_revolventes;";
		LET cSQL2 = " select num_credito,numcte,sdototal,capmes,intmes,pagomes,parteprincipal,parteinteres,tasainteres,fecha_apertura,fecha_vencimiento,status,grado_riesgo,num_producto, pago_ant from sd_cred_revolventes;";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_revolventes.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_revolventes.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicred ' || TRIM(cruta)||'archivo_revolventes.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_revolventes.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_revolventes.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_revolventes.unl ' ;
		system vsql; 
		--SE COMPRIME EL ARCHIVO	
		LET vsql='chmod 777 '|| TRIM(cRuta)||cnombre;
		System vsql;
		LET cSql = "gzip " || trim(cruta) || trim(cnombre); 
		system cSql;

	/*CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '03')
  let cMensajeFin = cnombre  ;
    RETURNING P_COD_RET;*/
	
end
RETURN P_COD_RET, cMensaje;
--RETURN P_COD_RET,cnombre; --Pruebas
END PROCEDURE;