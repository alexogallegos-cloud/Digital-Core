CREATE PROCEDURE "informix".sp_obtienecbparam(pcodigoparametro INTEGER)
RETURNING CHAR(6),CHAR(100);

	--Definición de Variables
	DEFINE	iSQLerr				INTEGER;
	DEFINE	iExiste				INTEGER;
	DEFINE	cCodRet 			CHAR(6);
	DEFINE	cValorParam			CHAR(100);
	
	--Inicializa VAriables
	LET iSQLerr				= 0;
	LET iExiste				= 0;
	LET	cCodRet 			= '000000';
	LET cValorParam			= '';

	--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtienecbparam.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr !=0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValorParam;
			END IF;
		END EXCEPTION;
  
	
		SELECT 1,valor 
		INTO iExiste,cValorParam
		FROM bdicobranza:"informix".cb_param 
		WHERE empresa = "001"
		  AND cod_param = pCodigoParametro;
		
		IF iExiste IS NULL THEN
			LET cCodRet = '000001';
		END IF;
		
	RETURN cCodRet,cValorParam;
  END
END PROCEDURE
DOCUMENT
'AUTOR: Héctor Manuel Bojorquez Ruelas',
'Descripcion: Consulta los parametros encontrados en la cb_param,',
'Fecha: 2012/Abril/26',
'Version: 20120426.1258',
'BD: BDICOBRANZA';

CREATE PROCEDURE "informix".sp_info_atento_admin()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--02-03-2012
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1
/*
----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte			char(20);
DEFINE vnomcte			char(70);
DEFINE vgenero  		char(1);
DEFINE vestado_civil		char(2);
DEFINE vedad			smallint;
DEFINE vantiguedad		DATE;
DEFINE vsueldo_mensual	decimal(18,2);
DEFINE vtipo_casa		char(2);
--DEFINE vdom_cliente		char(100);
DEFINE vnombrecalle char(30);
DEFINE vnumeroextcalle char(10);
DEFINE vnumerointcalle char(10);
DEFINE vnombrezonacoppel char(32);
DEFINE vnombrec char(30);
DEFINE vnombre char(30);
--DEFINE vdom_trabajo		char(100);
DEFINE vnombrecalle2 char(30);
DEFINE vnumeroextcalle2 char(10);
DEFINE vnumerointcalle2 char(10);
DEFINE vnombrezonacoppel2 char(32);
DEFINE vnombrec2 char(30);
DEFINE vnombre2 char(30);
DEFINE vnom_ref			char(70);
DEFINE vtelcasa			char(13);
DEFINE vtelcel			char(13);
DEFINE vteltrab			char(13);
DEFINE vtelref			char(13);
DEFINE vnum_credito		char(20);
DEFINE vproducto		char(40);
DEFINE vsaldo_total		decimal(18,2);
DEFINE vpago_min		decimal(18,2);
DEFINE vpen_mes_ant		decimal(18,2);
DEFINE vinteres			decimal(18,2);
DEFINE vpago_min_req	decimal(18,2);
DEFINE vfecha_lim_pago	date;
DEFINE vpagos_vencidos	smallint;
DEFINE vult_fecha_pago	date;
DEFINE vmonto_ult_pago	decimal(18,2);
DEFINE vultimo_compromiso char(100);
define cSucursal char(4);

DEFINE vfecha_compac date;
DEFINE vsucursal char(4);
DEFINE vimporte decimal(18,2);
DEFINE vflag_pago char(1);
define vmaxf	date;
/*
--return
DEFINE cCodTipCred       CHAR(2);		DEFINE dtFechaOrigen     DATE; 			DEFINE dtFechaProxPago   DATE; 			DEFINE dPagoMinimo       DECIMAL(18,2);
DEFINE dtFechaUltPago    DATE;			DEFINE iPlazo            INTEGER;		DEFINE iPagosRealizados  INTEGER;		DEFINE dLineaOtorgada    DECIMAL(18,2);
DEFINE dTasaInteres      DECIMAL(9,6);	DEFINE dTasaMoratorios   DECIMAL(9,6);	DEFINE dMontoSBC         DECIMAL(14,2);	DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dCapVig           DECIMAL(18,2);	DEFINE dCapTrans         DECIMAL(18,2);	DEFINE dCapVdoExig       DECIMAL(18,2);	DEFINE dCapVdoNoExig     DECIMAL(18,2);
DEFINE dSdoActCap        DECIMAL(18,2);	DEFINE dIntVig           DECIMAL(18,2);	DEFINE dIntVdo           DECIMAL(18,2);	DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIntMes           DECIMAL(18,2);	DEFINE dSdoActInt        DECIMAL(18,2);	DEFINE dPagosVdos 		 DECIMAL(18,2);	DEFINE cDescSitEspCred       CHAR(75);
DEFINE dIvaIntVig        DECIMAL(18,2);	DEFINE dIvaIntVdo        DECIMAL(18,2);	DEFINE dIvaIntMoratorio  DECIMAL(18,2);	DEFINE dIvaIntMes        DECIMAL(18,2);
DEFINE dSdoActIvaInt     DECIMAL(18,2);	DEFINE dComPend          DECIMAL(18,2);	DEFINE dIvaCom           DECIMAL(18,2);	DEFINE dSdoRetenido      DECIMAL(18,2);
DEFINE dSdoTotalLiq      DECIMAL(18,2);	DEFINE dIntDevengado     DECIMAL(18,2);	DEFINE dLineaDisponible  DECIMAL(18,2);	DEFINE cCausaCred        INTEGER;	
DEFINE cDescStatusCred   CHAR(60);		DEFINE iIdUnidadProd     INTEGER;  		DEFINE cDescBloqueoCta       CHAR(60);	DEFINE cCodCaract2       CHAR(3);
DEFINE cDescCausaBloqueoCta  CHAR(50);	DEFINE cSitCte           CHAR(1);		DEFINE cCausaCte             INTEGER;	DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);		
*/	

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(6);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(150);
---VARIABLES PARA QUERYS
/*
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
define vfecha_insert		DATE;
define vcd 					SMALLINT;
define vcid 				SMALLINT;
define vmax					smallint;
*/
BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02');
        RETURN P_COD_RET;
    END EXCEPTION;
/*
----INICIALIZAN VARIABLES QUE VAN EN LA TABLA
LET vnumcte			='';
LET vnomcte			='';
LET vgenero  		='';
LET vestado_civil	='';
LET vedad			= 0;
LET vantiguedad		= DATE(1);
LET vsueldo_mensual	= 0;
LET vtipo_casa		='';
--LET vdom_cliente		='';
LET vnombrecalle ='';
LET vnumeroextcalle ='';
LET vnumerointcalle ='';
LET vnombrezonacoppel ='';
LET vnombrec ='';
LET vnombre ='';
LET vnombrecalle2 ='';
LET vnumeroextcalle2 ='';
LET vnumerointcalle2 ='';
LET vnombrezonacoppel2 ='';
LET vnombrec2 ='';
LET vnombre2 ='';
--LET vdom_trabajo		='';
LET vnom_ref			='';
LET vtelcasa		='';
LET vtelcel			='';
LET vteltrab		='';
LET vtelref			='';
LET vnum_credito	='';
LET vproducto		='';
LET vsaldo_total	= 0;
LET vpago_min		= 0;
LET vpen_mes_ant	= 0;
LET vinteres		= 0;
LET vpago_min_req	= 0;
LET vfecha_lim_pago	=date(1);
LET vpagos_vencidos	= 0;
LET vult_fecha_pago	=date(1);
LET vmonto_ult_pago	= 0;
LET vultimo_compromiso ='';
let cSucursal = '';
let vmaxf 			=date(1);

---INICIALIZAN VARIABLES PARA QUERYS
LET  cSql		="";
LET cSQL1       = "";
LET cSQL2       = "";
LET cSQL3       = "";
*/
Let P_cod_ret	= "000000";
--LET icontador 	= 0;
LET vproceso	='2061';
LET cMensaje    = 'PROCESO EXITOSO';
/*
let sPaso		=0;
let cruta       ='';
let cdelimitador 	='';
let cnomarchivo  	='';
let cnomarchivo1 	='';
let cnombre			='';
let vfecha 			= date(1);
let vfecha_insert 	= date(1);
let vcd = 0;
let vcid = 0;
*/
 -- Set debug file to '/informix/Elizabeth/cb_cat_atento_admin.out';
  --trace on;
    CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01');
	call bdicobranza:"informix".sp_cat_gen_info_admin(0,0) RETURNING P_COD_RET,cMensaje; --00001
	
CALL bdicobranza:"informix".sp_cat_prioridadcte('A') returning P_COD_RET, cMensaje;
	
--	call bdicobranza:"informix".sp_actualiza_catdirectoriocte('A',today ) RETURNING cMensaje; --0050
/*	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_cat_atento_admin';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_cat_atento_admin;
            END IF;

create table cb_cat_atento_admin
        (
        numcte			char(20),
		nomcte			char(70),
		genero  		char(1),
		estado_civil		char(2),
		edad			smallint,
		antiguedad		DATE,
		sueldo_mensual	decimal(18,2),
		tipo_casa		char(2),
		--dom_cliente		char(100),
		--dom_trabajo		char(100),
		 nombrecalle char(30),
		numeroextcalle char(10),
		numerointcalle char(10),
		nombrezonacoppel char(32),
		nombrec char(30),
		nombre char(30),
		 nombrecalle2 char(30),
		numeroextcalle2 char(10),
		numerointcalle2 char(10),
		nombrezonacoppel2 char(32),
		nombrec2 char(30),
		nombre2 char(30),
		nom_ref			char(70),
		telcasa			char(13),
		telcel			char(13),
		teltrab			char(13),
		telref			char(13),
		num_credito		char(20),
		producto		char(40),
		saldo_total		decimal(18,2),
		pago_min		decimal(18,2),
		pen_mes_ant		decimal(18,2),
		interes			decimal(18,2),
		pago_min_req	decimal(18,2),
		fecha_lim_pago	date,
		pagos_vencidos	smallint,
		ult_fecha_pago	date,
		monto_ult_pago	decimal(18,2),
	--	ultimo_compromiso char(100)) ;
		fecha_compac date,
		sucursal_c char(4),
		importe decimal(18,2),
		flag_pago char(1)) ;

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
	
	--select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
	let vfecha = today - 1 units day;
	
    set isolation to dirty read;
    set lock mode to wait 3;
	
	select max(a.fecha_insert) into vfecha_insert
	from bdicobranza:cb_cat_directorio_cte a
	where a.tipo_cobranza = 'A' 
		AND a.pago_venc = 1 
		AND a.status_cliente  ='AC';
		--AND nvl(a.saldo_total,0) > 0;
		
	FOREACH
		
		select ciudad,count(*) into vcd,vcid
		from bdicobranza:cb_cat_directorio_cte
		where tipo_cobranza = 'A' 
		AND pago_venc = 1 
		AND status_cliente  ='AC'
		--AND nvl(saldo_total,0) > 0
		and fecha_insert = vfecha_insert
		group by ciudad
        order by ciudad 
			
		LET vcid = round(vcid/2);
		
	FOREACH
	select limit vcid 
	trim(a.numcte)numcte,  trim(d.nombre1)|| ' '|| trim(d.nombre2)|| ' '|| 
	trim(d.apell_paterno) || ' '|| trim(d.apell_materno )nombre,b.sexo ,estado_civil, 
         to_char(today,'%Y')::integer - to_char(fecha_nac,'%Y')::integer  edad,fecha_alta,
		(( SELECT ingreso_mensual     FROM bdisolic:ss_resum_scor_fin  WHERE empresa = '001' AND num_solicitud = a.num_credito )
			/ (SELECT NVL(valor,0) * 1   FROM bdisolic:ss_param  WHERE secuencia = 303     AND empresa   = '001'))::integer,
		habita_en,
		(SELECT  nombre_ref FROM bdisolic:ss_refpersonales
		WHERE empresa       = '001'
			AND num_solicitud = a.num_credito   AND numcte  = a.numcte   AND numcte_ref    = 'R1'),
		case when (length (e.telefono1)<10) then ''  else (substr(e.telefono1,length(e.telefono1)-9,10)) end  , 
		case when (length (e.telefono2)<10) then '' else (substr(e.telefono2,length(e.telefono2)-9,10)) end  , 
		case when (length (e.telefono3)<10) then '' else (substr(e.telefono2,length(e.telefono3)-9,10)) end , 
		nvl(( SELECT telefono_ref 
        FROM bdisolic:"informix".ss_refpersonales
        WHERE empresa = '001'
			AND num_solicitud =a.num_credito
			AND numcte =  a.numcte
            AND numcte_ref = 'R1'),''),
		trim(a.num_credito),
		(select descrip_prod from bdicred:sd_tipprod where empresa ='001' and abrevia_prod =a.num_producto  ),
		--saldo_total,pago_minimo,
		--100,10,saldo_total,
		anex.prox_fecha_pago, a.pago_venc, anex.fecha_ult_pago, 	
		d.sucursal
	INTO vnumcte,	vnomcte,	vgenero , vestado_civil,	vedad,	vantiguedad	,	vsueldo_mensual,	vtipo_casa,	
		--vdom_cliente,vdom_trabajo,		
		vnom_ref	,vtelcasa,	vtelcel,	vteltrab	,	vtelref,	vnum_credito	,	vproducto,/*vsaldo_tatal,	vpago_min,
		vpen_mes_ant	,vinteres,	vpago_min_req,	*//*vfecha_lim_pago,	vpagos_vencidos,	vult_fecha_pago	,cSucursal
		--vultimo_compromiso ,
	FROM bdicobranza:cb_cat_directorio_cte a ,  bdinteg:si_ctepf b, bdinteg:si_cliente d, bdinteg:si_direcciones_actual e,	
	bdicred:sd_maecredanexo anex
	WHERE a.empresa = b.empresa
		AND a.numcte = b.numcte
		AND a.empresa = d.empresa
		AND a.numcte = d.numcte
		AND a.numcte = e.numcte
		AND a.empresa = anex.empresa
		AND a.num_credito = anex.num_credito
		AND e.tipo_dir = 1
		AND a.tipo_cobranza = 'A' 
		AND a.pago_venc = 1 
		AND a.status_cliente  ='AC'
		--AND nvl(a.saldo_total,0) > 0
		and a.fecha_insert = vfecha_insert
		and a.ciudad = vcd
		
		SELECT limit 1 {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} 
			TRIM(NVL(cal.nombrecalle,'')),TRIM(NVL(dir.numeroextcalle,'')),TRIM(NVL(dir.numerointcalle,'')),
			TRIM(NVL(zon.nombrezonacoppel,'')),TRIM(NVL(ciu.nombre,'')),TRIM(NVL(edo.nombre,''))
		INTO vnombrecalle,vnumeroextcalle,vnumerointcalle,vnombrezonacoppel,vnombrec,vnombre
		FROM bdinteg:si_direcciones_actual dir
			LEFT JOIN bdinteg:si_estados     edo ON(edo.pais = "001" AND edo.estado = dir.estado)
			LEFT JOIN bdinteg:si_ciudades    ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
			LEFT JOIN bdinteg:si_catzonas    zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
			LEFT JOIN bdinteg:si_catcalles   cal ON(cal.numerocalle  = dir.numerocalle)
			LEFT JOIN bdinteg:si_catciudades cdc ON(cdc.numerociudad = dir.numerociudad)
		WHERE dir.numcte    = vnumcte
		AND dir.tipo_dir  = '1';
		
		SELECT limit 1 {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} 
			TRIM(NVL(cal.nombrecalle,'')),TRIM(NVL(dir.numeroextcalle,'')),TRIM(NVL(dir.numerointcalle,'')),
			TRIM(NVL(zon.nombrezonacoppel,'')),TRIM(NVL(ciu.nombre,'')),TRIM(NVL(edo.nombre,''))
		INTO vnombrecalle2,vnumeroextcalle2,vnumerointcalle2,vnombrezonacoppel2,vnombrec2,vnombre2
        FROM bdinteg:si_direcciones_actual dir
			LEFT JOIN bdinteg:si_estados   edo ON(edo.estado = dir.estado AND edo.pais = "001")
			LEFT JOIN bdinteg:si_ciudades  ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
			LEFT JOIN bdinteg:si_catzonas  zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
			LEFT JOIN bdinteg:si_catcalles cal ON(cal.numerocalle = dir.numerocalle)
		WHERE dir.numcte    = vnumcte
			AND dir.tipo_dir  = '2';
			
		select limit 1 max(fecha_compac) into vmaxf from bdicobranza:cb_compac_his where empresa = '001' and numcliente = vnumcte;
		select limit 1 TRIM(NVL(fecha_compac,'')),TRIM(NVL(sucursal,'')),TRIM(NVL(importe,'')),TRIM(NVL(flag_pago,''))
		INTO vfecha_compac,vsucursal,vimporte,vflag_pago
        from bdicobranza:cb_compac_his where empresa = '001' and numcliente = vnumcte
		and fecha_compac = vmaxf;
        --and fecha_compac= (select max(fecha_compac) from bdicobranza:cb_compac_his where empresa = '001' and numcliente = vnumcte);
		
		SELECT limit 1 NVL(monto,0) INTO vmonto_ult_pago
        FROM bdicred:sd_movhis WHERE codigo_fun in ('033','334','335','336','337','904') AND codigo_ref = 1
        --AND fecha_mov = (select max(fecha_mov)from bdicred:sd_movhis where num_credito = vnum_credito ) 
		AND fecha_mov = vult_fecha_pago		
        AND reversado = 'N' AND num_credito = vnum_credito ;
		
	-----------------------------SALDOS-------------------------------------------------------	
	--LET vsaldo_total = dSdoTotalLiq;	--(sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva )sdo_tot_liquid
	--LET vpen_mes_ant = dCapTrans;--mto_venc_trasp
	--LET vinteres = dIntVdo + dIntMoratorio + dSdoActIvaInt;--interes_iva + moratorio
	--LET vpago_min_req = dPagoMinimo;--(monto_vencido + mto_venc_trasp + interes_iva + moratorio) + mensualidad_actual
	--LET vpago_min = vpago_min_req - (vinteres + vpen_mes_ant);--mensualidad_actual
	
		select (sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva )sdo_tot_liquid,
				mensualidad_actual,
				mto_venc_trasp, interes_iva + moratorio, 
				(monto_vencido + mto_venc_trasp + interes_iva + moratorio) + mensualidad_actual pago_req
		into vsaldo_total,vpago_min,vpen_mes_ant,vinteres,vpago_min_req
		from bdicred:sd_sdos_cartera_linea 
		where num_credito = vnum_credito;
	
		INSERT INTO bdicobranza:cb_cat_atento_admin 
		(numcte,	nomcte,	genero , estado_civil,	edad,	antiguedad	,	sueldo_mensual,	tipo_casa,	--dom_cliente,dom_trabajo	,	
		nombrecalle,numeroextcalle,numerointcalle,nombrezonacoppel,nombrec,nombre,
		nombrecalle2,numeroextcalle2,numerointcalle2,nombrezonacoppel2,nombrec2,nombre2,
		nom_ref	,telcasa,	telcel,	teltrab	,	telref,	num_credito	,	producto,saldo_total,	pago_min,
		pen_mes_ant	,interes,	pago_min_req,	fecha_lim_pago,	pagos_vencidos,	ult_fecha_pago	,monto_ult_pago	,
		fecha_compac,sucursal_c,importe,flag_pago)
	    VALUES (		nvl ( vnumcte,' ' ),
                        nvl ( replace ( replace( vnomcte , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vgenero , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vestado_civil , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vedad , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vantiguedad , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vsueldo_mensual , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vtipo_casa , '|' , ' ' ), '\' , ' ' ), ' ' ),
                     	--nvl ( replace ( replace( vdom_cliente , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        --nvl ( replace ( replace( vdom_trabajo , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrecalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnumeroextcalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnumerointcalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrezonacoppel , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrec , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnombre , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrecalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnumeroextcalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnumerointcalle , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrezonacoppel , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnombrec , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vnombre , '|' , ' ' ), '\' , ' ' ), ' ' ),
						
						nvl ( replace ( replace( vnom_ref , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vtelcasa , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vtelcel , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vteltrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vtelref , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vnum_credito , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vproducto , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vsaldo_total , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vpago_min , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vpen_mes_ant , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vinteres , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vpago_min_req , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vfecha_lim_pago, date(1) ),
						nvl ( replace ( replace( vpagos_vencidos , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vult_fecha_pago, date(1) ),
                        nvl ( replace ( replace( vmonto_ult_pago , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        --nvl ( replace ( vultimo_compromiso, '\' , ' ' ), ' ' ));
						nvl ( replace ( replace( vfecha_compac , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vsucursal , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vimporte , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vflag_pago , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table bdicobranza:cb_cat_atento_admin;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
		
		--COLOCAR REGISTRO CON CALL_C = 2 QUE IDENTIFIQUE QUE EL CLIENTE ES PARA CAT ATENTO
		update bdicobranza:cb_cat_directorio_cte 
			set call_c = 2, status_cliente = 'AT'
		where empresa = '001'
			and numcte = vnumcte
			and num_credito = vnum_credito
			and tipo_cobranza = 'A' 
			and pago_venc = 1 
			and status_cliente  ='AC'
			and fecha_insert = vfecha_insert;
		
    End ForEach;
		
	End ForEach;
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/Elizabeth/';
	let cnombre = 'reporte_admin_atento';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(vfecha,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(vfecha,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicobranza:cb_cat_atento_admin ";
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
/*	
	--SE COMPRIME  EL ARCHIVO	
	LET cSql = "gzip " || trim(cruta) || trim(cnomarchivo); 
	system cSql;
*/	
	--Borra el archivo de control.
/*	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 
*/	
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03');
    RETURN P_COD_RET;

end;
end procedure;