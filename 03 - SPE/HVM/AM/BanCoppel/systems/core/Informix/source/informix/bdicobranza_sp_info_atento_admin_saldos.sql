CREATE PROCEDURE "informix".sp_info_atento_admin_saldos()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--02-03-2012
--crea archivo con saldos que se muestran en pantalla cat con cliente con mora 1

/*
----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte			char(20);
DEFINE vnum_credito		char(20);
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
/*
DEFINE dIntVdo decimal(18,2);  DEFINE dIntMoratorio  decimal(18,2); DEFINE dIvaIntVdo decimal(18,2);DEFINE dIntMes decimal(18,2);
DEFINE dIvaSuc decimal(18,2);DEFINE dIntMoratorio_d decimal(18,2);DEFINE dIvaIntMoratorio decimal(18,2);DEFINE dSdoActCap decimal(18,2);   
DEFINE dSdoRetenido decimal(18,2);DEFINE dMontoFinanciado  decimal(18,2);DEFINE dpend_mes_ant decimal(18,2);
DEFINE	dSdoTotalLiq  decimal(18,2);DEFINE	dSdoActIvaInt decimal(18,2);
DEFINE	dintereses decimal(18,2);--DEFINE	dPagoMinimo decimal(18,2);DEFINE	dpago_periodo decimal(18,2);
*/

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(6);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(80);
/*
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
define vfecha_insert		DATE;
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

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02')  RETURNING P_COD_RET; 
        RETURN P_COD_RET;
    END EXCEPTION;
/*
----INICIALIZAN VARIABLES QUE VAN EN LA TABLA
LET vnumcte			='';
LET vnum_credito	= '';
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
LET vfecha_compac = date(1);
LET vsucursal = '';
LET vimporte  = 0;
LET vflag_pago = '';
/*
LET dIntVdo = 0;    LET dIntMoratorio  = 0;  LET dIvaIntVdo = 0;LET dIntMes = 0;LET dIvaSuc = 0;LET dIntMoratorio_d = 0;
LET dIvaIntMoratorio = 0;LET dSdoActCap = 0;   LET dSdoRetenido = 0;LET dMontoFinanciado  = 0;LET dpend_mes_ant = 0;
LET	dSdoTotalLiq  = 0;LET	dSdoActIvaInt = 0;LET	dintereses = 0;--LET	dPagoMinimo = 0;LET	dpago_periodo = 0;
*/

---INICIALIZAN VARIABLES PARA QUERYS
/*
LET  cSql		="";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
*/
Let P_cod_ret	= "000000";
--LET icontador 	= 0;
LET vproceso	='2062';
LET cMensaje    = 'PROCESO EXITOSO';
/*
let sPaso =0;
let cruta       ='';
let cdelimitador  ='';
let cnomarchivo  ='';
let cnomarchivo1  ='';
let cnombre ='';
let vfecha = date(1);
let vfecha_insert = date(1);


LET cCodTipCred       ='';		LET dtFechaOrigen     = DATE(1); LET dtFechaProxPago   = DATE(1); 			LET dPagoMinimo       = 0;
LET dtFechaUltPago    = DATE(1);			LET iPlazo            = 0;		LET iPagosRealizados  = 0;		LET dLineaOtorgada    = 0;
LET dTasaInteres      = 0;	LET dTasaMoratorios   = 0;	LET dMontoSBC         = 0;	LET dIvaIntDevengado      = 0;
LET dCapVig           = 0;	LET dCapTrans         = 0;	LET dCapVdoExig       = 0;	LET dCapVdoNoExig     = 0;
LET dSdoActCap        = 0;	LET dIntVig           = 0;	LET dIntVdo           = 0;	LET dIntMoratorio     = 0;
LET dIntMes           = 0;	LET dSdoActInt        = 0;	LET dPagosVdos 		 = 0;	LET cDescSitEspCred   ='';
LET dIvaIntVig        = 0;	LET dIvaIntVdo        = 0;	LET dIvaIntMoratorio  = 0;	LET dIvaIntMes        = 0;
LET dSdoActIvaInt     = 0;	LET dComPend          = 0;	LET dIvaCom           = 0;	LET dSdoRetenido      = 0;
LET dSdoTotalLiq      = 0;	LET dIntDevengado     = 0;	LET dLineaDisponible  = 0;	LET cCausaCred        = 0;	
LET cDescStatusCred   ='';		LET iIdUnidadProd     = 0;  		LET cDescBloqueoCta       ='';	LET cCodCaract2       ='';
LET cDescCausaBloqueoCta  ='';	LET cSitCte           ='';		LET cCausaCte             = 0;	LET cDescSitEspCte        ='';
LET cSitCred              ='';	
*/
 -- Set debug file to '/aplicacion/resplogifx/archivoscartera/cb_cat_atento_admin_saldos.out';
 -- trace on;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso,'000000', 'INICIA PROCESO EVALUA CTES CARTERA' ,'02' ) RETURNING P_COD_RET;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING P_COD_RET; 
	call bdicobranza:"informix".sp_cat_evalua_ctes_cartera('001','A') RETURNING P_COD_RET, cMensaje; --0090
     
/*	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_cat_atento_admin_saldos';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_cat_atento_admin_saldos;
            END IF;

	create table cb_cat_atento_admin_saldos
        (
        numcte			char(20),
		saldo_total		decimal(18,2),
		pago_min		decimal(18,2),
		pen_mes_ant		decimal(18,2),
		interes			decimal(18,2),
		pago_min_req	decimal(18,2),
		fecha_lim_pago	date,
		pagos_vencidos	smallint,
		ult_fecha_pago	date,
		monto_ult_pago	decimal(18,2),
		 fecha_compac date,
		 sucursal char(4),
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
	LET vfecha = today - 1 units day;
	
    set isolation to dirty read;
    set lock mode to wait 3;
	
	select max(a.fecha_insert) into vfecha_insert
	from bdicobranza:cb_cat_directorio_cte a
	where a.tipo_cobranza = 'A' 
		AND a.pago_venc = 1 
		AND a.status_cliente  ='AT'
		--AND nvl(a.saldo_total,0) > 0
		--AND a.status_cliente NOT IN ('EX','IN')
		AND a.call_c = 2;

	FOREACH
	
    select  trim(a.numcte)numcte,a.num_credito,  anex.prox_fecha_pago, a.pago_venc, anex.fecha_ult_pago, 
			d.sucursal
	INTO vnumcte,vnum_credito,vfecha_lim_pago,	vpagos_vencidos,	vult_fecha_pago	,cSucursal
	FROM bdicobranza:cb_cat_directorio_cte a , bdinteg:si_cliente d, 	bdicred:sd_maecredanexo anex
	WHERE a.empresa = d.empresa
		AND a.numcte = d.numcte
		AND a.empresa = anex.empresa
		AND a.num_credito = anex.num_credito
		AND a.tipo_cobranza = 'A' 
		AND a.pago_venc = 1 
		AND a.status_cliente  ='AT'
		--AND nvl(a.saldo_total,0) > 0
		--AND a.status_cliente  NOT IN ('EX','IN')
		and a.call_c = 2
		and a.fecha_insert = vfecha_insert

		select limit 1
		TRIM(NVL(fecha_compac,'')),TRIM(NVL(sucursal,'')),TRIM(NVL(importe,'')),TRIM(NVL(flag_pago,''))
		INTO vfecha_compac,vsucursal,vimporte,vflag_pago
        from bdicobranza:cb_compac_his where empresa = '001' and numcliente = vnumcte
        and fecha_compac = (select max(fecha_compac) from bdicobranza:cb_compac_his where empresa = '001' and numcliente = vnumcte);
		
		SELECT limit 1 NVL(monto,0) INTO vmonto_ult_pago
        FROM bdicred:sd_movhis WHERE codigo_fun in ('033','334','335','336','337','904') AND codigo_ref = 1
        AND fecha_mov = (select max(fecha_mov)from bdicred:sd_movhis where num_credito = vnum_credito )  
        AND reversado = 'N' AND num_credito = vnum_credito ;
		
	-----------------------------SALDOS-------------------------------------------------------	
	execute PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vnum_credito)
	into P_cod_ret,cMensaje,vnum_credito,cCodTipCred,dtFechaOrigen, dtFechaProxPago,
          dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
          dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
          dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
          dSdoActInt,dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio,dIvaIntMes, dSdoActIvaInt,
          dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
          dPagosVdos, cDescStatusCred, iIdUnidadProd,cDescBloqueoCta, cCodCaract2,
          cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte,cSitCred,
          cCausaCred,cDescSitEspCred;
		  

		LET vsaldo_total = dSdoTotalLiq;	
		LET vpen_mes_ant = dCapTrans;
		LET vinteres = dIntVdo + dIntMoratorio + dSdoActIvaInt;
		LET vpago_min_req = dPagoMinimo;
		LET vpago_min = vpago_min_req - (vinteres + vpen_mes_ant);
		
        INSERT INTO bdicobranza:cb_cat_atento_admin_saldos 
		(numcte,	saldo_total,	pago_min,pen_mes_ant	,interes,	pago_min_req,	
		fecha_lim_pago,	pagos_vencidos,	ult_fecha_pago	,monto_ult_pago	, fecha_compac,sucursal,importe,flag_pago)
	    VALUES (		nvl ( vnumcte,' ' ),
                        nvl ( replace ( replace( vsaldo_total , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vpago_min , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vpen_mes_ant , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vinteres , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vpago_min_req , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vfecha_lim_pago, date(1) ),
						nvl ( replace ( replace( vpagos_vencidos , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( vult_fecha_pago, date(1) ),
                        nvl ( replace ( replace( vmonto_ult_pago , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vfecha_compac , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vsucursal , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vimporte , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vflag_pago , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table bdicobranza:cb_cat_atento_admin_saldos;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
    End ForEach;

--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/Elizabeth/';
	let cnombre = 'reporte_admin_atento_saldos';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(vfecha,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(vfecha,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicobranza:cb_cat_atento_admin_saldos ";
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
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING P_COD_RET;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso,'000000', 'FINALIZA PROCESO EVALUA CTES CARTERA' ,'02' ) RETURNING P_COD_RET;
	 RETURN P_COD_RET;

end;
end procedure;