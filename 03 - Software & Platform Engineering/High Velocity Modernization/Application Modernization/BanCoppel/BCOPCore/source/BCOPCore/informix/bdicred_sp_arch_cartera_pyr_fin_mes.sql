CREATE PROCEDURE "informix".sp_arch_cartera_pyr_fin_mes()
RETURNING CHAR(6),
		  CHAR(150);

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE cMensajeBitacora 	CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechacorte date;
DEFINE Vult_dia_mes DATE;
--Structura
DEFINE Vcreditoexterno          char(20);
DEFINE Vproducto     		char(4);
DEFINE Vnum_credito         char(20);
DEFINE cNumCredito			char(20);
DEFINE  Vnumcte				char(20);
DEFINE Vnum_tarjeta         char(20);
DEFINE Vnum_sucursal		char(4);
DEFINE  Vnom_suucursal		char(40);
DEFINE  Vingreso_mensual    money;
DEFINE  Vmonto_apertura      decimal(18,2); 
DEFINE  Vfecha_apertura      date;

DEFINE  Vplazo smallint;
DEFINE Vestatus char (2);
DEFINE  Vsaldo_insoluto	decimal(18,2);
DEFINE  Vcapital_vigente	decimal(18,2);
DEFINE Vcapital_transitorio	decimal(18,2);
DEFINE Vsaldo_vencido_exigible	decimal(18,2);
DEFINE Vsaldo_vencido_no_exigible	decimal(18,2);
DEFINE Vsaldo_actual decimal(18,2); 
DEFINE  Vsaldo_cierre decimal(18,2); 
DEFINE Vmes_vencido decimal(18,2); 
DEFINE Vtipo_mov cHAR (1);
DEFINE Vfecha_mov DATE;

DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vtasainteres			decimal(10,2);

DEFINE Vsexo char (1);
DEFINE Vfecha_nac date;
DEFINE Vnombre1 char(26);
DEFINE Vnombre2 char(26);
DEFINE Vapellido_p char(26);
DEFINE Vapellido_m char(26);
DEFINE Vmail char (60);
DEFINE Vdir_calle char(30);
DEFINE Vdir_numero char(20);
DEFINE Vdir_colonia char(32);
DEFINE Vcp char(5);

DEFINE Vdir_municipio char(60);
DEFINE Vnum_estado smallint;
DEFINE Vdir_estado char(30);
DEFINE Vnum_cd_coppel smallint;
DEFINE Vcd_coppel char(32);
DEFINE Vnum_cd_banco smallint;
DEFINE  Vcd_banco char(32);
DEFINE Vtel1 char(13);
DEFINE  Vtel2 char(13);
DEFINE Vtel3 char(13);
DEFINE Vext char(5);

DEFINE Vref_coppel char(20);
DEFINE Vficiencia decimal(5,2);
DEFINE Vmeses_historia smallint;
DEFINE Vhit char(6);
DEFINE Vsecc1 char (4);
DEFINE Vsecc2 decimal(10,4);
DEFINE Vpri_dia_mes DATE;

	  --variables
DEFINE Vnumcreditortc       char(20);
DEFINE VcreditoConsulta       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE dFechaUltPago		date;
DEFINE dFechaUltimoPago		date;
DEFINE vppyrfechaultmov		date;
DEFINE vPpyrTipoUltimoMov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
define cNombreArchivoNvo	char(70);
--define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
DEFINE cMotivo	char(5);
-- RQM 09 440

DEFINE dBcScore DECIMAL(5,2);
DEFINE dScoreProp DECIMAL(5,2);
DEFINE dFico DECIMAL(5,2);
DEFINE dFicoExtended DECIMAL(5,2);
DEFINE dIcc DECIMAL(5,2);
DEFINE v_selectcredito char(20);
DEFINE cFlag2Credito   VARCHAR(120,1);
DEFINE cStatus_Ini CHAR(2);
DEFINE cRevisado CHAR(2);
DEFINE cIdbox smallint;
DEFINE cIfe CHAR(2);
DEFINE cGrupo	CHAR(01);
DEFINE sMesesVencidos SMALLINT;
DEFINE sNumPagos	SMALLINT;
DEFINE dMontoPagos	decimal(18,2);
DEFINE dFechaVencido DATE;
DEFINE cPpyrNumCredito CHAR(20);

DEFINE iTotalCuentasProcesadas	INTEGER;
DEFINE iCuentasInsertadas		INTEGER;
DEFINE iCuentasActualizadas		INTEGER;
DEFINE dFechaInicio		DATE;
DEFINE Vnumtarjetatdc       char(20);
DEFINE Vnumciudad			char(4);
DEFINE Vfechalimitedepago	date;
DEFINE VintVigente			decimal(18,2);
DEFINE VintVencido			decimal(18,2);
DEFINE VintVenc28			decimal(18,2);
DEFINE VintVenc29			decimal(18,2);
DEFINE VintVenc30			decimal(18,2);
DEFINE VintVenc31			decimal(18,2);

--Inicializacion de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_Ret2                = "000000";
LET cMensaje                = 'PROCESO EXITOSO.';
LET cMensajeBitacora		= '';
LET vproceso	            = '2059'; --'2060';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte = DATE(1);
LET Vult_dia_mes = DATE(1);
LET Vpri_dia_mes = DATE(1);

-----VARIABLES
LET Vcreditoexterno = '';
LET Vproducto     		='';
LET Vnum_credito         = '';
LET cNumCredito			= '';
LET VcreditoConsulta         = '';
LET  Vnumcte				='';
LET Vnum_tarjeta         ='';
LET Vnum_sucursal		='';
LET  Vnom_suucursal		='';
LET  Vingreso_mensual    = 0;
LET  Vmonto_apertura      = 0;
LET  Vfecha_apertura     = DATE(1);

LET  Vplazo = 0;
LET Vestatus ='';
LET  Vsaldo_insoluto	= 0;
LET  Vcapital_vigente	= 0;
LET Vcapital_transitorio	= 0;
LET Vsaldo_vencido_exigible	= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual = 0;
LET  Vsaldo_cierre = 0;
LET Vmes_vencido = 0;
LET Vtipo_mov ='';
LET Vfecha_mov = DATE(1);
LET vppyrfechaultmov = DATE(1);

LET Vinteres       		= 0;
LET Vsaldovencido     	= 0;
LET Vinteresvencido   	= 0;
LET vinteres_moratorio	= 0;
LET Vabonobase			= 0;
LET Vtasainteres		= 0;

LET Vsexo ='';
LET Vfecha_nac = date(1);
LET Vnombre1 ='';
LET Vnombre2 ='';
LET Vapellido_p ='';
LET Vapellido_m ='';
LET Vmail ='';
LET Vdir_calle ='';
LET Vdir_numero ='';
LET Vdir_colonia ='';
LET Vcp = '';

LET Vdir_municipio ='';
LET Vnum_estado = 0;
LET Vdir_estado ='';
LET Vnum_cd_coppel= 0;
LET Vcd_coppel ='';
LET Vnum_cd_banco = 0;
LET  Vcd_banco ='';
LET Vtel1 ='';
LET  Vtel2 ='';
LET Vtel3 ='';
LET Vext ='';

LET Vref_coppel ='';
LET Vficiencia = 0;
LET Vmeses_historia = 0;
LET Vhit ='';
LET Vsecc1 = '';
LET Vsecc2 = 0;

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
LET	Vnumsucursal			= 0;
LET Vabonosvencidos         = 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET	dFechaUltPago           = DATE(1);
LET dFechaUltimoPago		= DATE(1);
LET vPpyrTipoUltimoMov          = '';
LET Vfechacorte             = DATE(1);
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo = '';

LET dScoreProp = "";
LET dBcScore = "";
LET dFico = "";
LET dFicoExtended = "";
LET dIcc  = "";
let  v_selectcredito = "";
LET cFlag2Credito = "" ;
LET cStatus_Ini = "";
LET cRevisado = "";
LET cIdbox = 0;
LET cIfe = "";
LET cGrupo = '';
LET sMesesVencidos	= 0;
LET sNumPagos = 0;
LET dMontoPagos = 0;
LET dFechaVencido = DATE(1);
LET cPpyrNumCredito = '';

LET iTotalCuentasProcesadas	= 0;
LET iCuentasInsertadas		= 0;
LET iCuentasActualizadas	= 0;
LET dFechaInicio	= DATE(1);
LET Vnumtarjetatdc   = '';
LET Vnumciudad		= '';
LET Vfechalimitedepago	= DATE(1);
LET VintVigente		= 0;
LET VintVencido		= 0;
LET VintVenc28		= 0;
LET VintVenc29		= 0;
LET VintVenc30		= 0;
LET VintVenc31		= 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            --LET cMensaje = error_info;
			LET cMensaje = 'ERROR en el proceso: ' || TRIM(cNumCredito) || '   ' || 'columna ' || TRIM(error_info);
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

--	SET DEBUG FILE TO "sp_arch_cartera_pyr_fin_mes.out";
--	TRACE ON;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_ret,cMensaje;
	END IF;
	
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_ret,cMensaje;
	END IF;
	
	-------------------------------GENERA TABLA-------------------------------------
	
/*	select max(fecha)
	into pfechacorte
	from bdicred:sd_maecredcontcrd
	where num_producto in ( '6011','6300','7600','7700');*/
	
	LET pfechacorte = mdy(month(today),1,year(today)) - 1; -- ejecutarse al cambio de fechas de Cré¤©to y/o despué³ de la 1.30 hrs. CDMX para que tome la fecha del nuevo dð£	
--temporal solo para pruebas	
--LET pfechacorte = mdy('12','01','2018') - 1;
--temporal solo para pruebas

	LET dFechaInicio = mdy(month(pfechacorte),1,year(pfechacorte));
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Genera tabla temporal', '02') returning cCod_ret2;
	
	SELECT crd.num_credito, crd.fecha_apertura, crd.numcte , crd.num_producto, crd.credito_externo, crd.sucursal, crd.plazo, crd.status_cred, ppyr.numcreditortc ppyr_num_credito,
			b.monto_otorgado, b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci,b.mto_fin_ven_trasp,
			--(CASE WHEN crd.status_cred IN ('AA','BA') THEN (b.sdo_intereses + b.sdo_no_exig) ELSE 0 END) interes,
			--(CASE WHEN crd.status_cred NOT IN ('AA','BA') THEN (b.sdo_intereses + b.sdo_no_exig + b.int_tra_no_exig) ELSE 0 END ) interes_vencido, crd.tasa_interes,
			(CASE WHEN (b.int_tra_no_exig <= 0) THEN (b.sdo_intereses + b.sdo_no_exig) ELSE 0 END) interes,
			(CASE WHEN (b.int_tra_no_exig >  0) THEN (b.sdo_intereses + b.sdo_no_exig + b.int_tra_no_exig) ELSE 0 END ) interes_vencido, crd.tasa_interes,
			b.sdo_intereses + b.sdo_no_exig sdo_interes,ppyr.tipoultimomov,ppyr.fechaultmov,
			NVL(b.sdo_moratorio + b.sdo_contab_mora,0) interes_moratorio
	  FROM bdicred:sd_maecredcontcrd crd 
      INNER JOIN bdicred:sd_maesdoscontcrd b ON b.fecha = crd.fecha AND b.empresa = crd.empresa AND b.num_credito = crd.num_credito
	  LEFT OUTER JOIN bdicred:sd_pagosydisposicionescrd_carteras ppyr ON ppyr.numcreditortc = crd.num_credito
	 WHERE crd.fecha =pfechacorte 
	   AND crd.empresa = cempresa
	   AND crd.num_producto IN ('6300','6011','7600','7700') 
---quitar status FI
	   AND crd.status_cred != 'FI'
	   AND crd.campo_trab3 <> 'BAJA'
	INTO temp CreditosCrd WITH NO LOG;

	CREATE INDEX indx_creditos ON CreditosCrd (num_credito) using btree in dbs_movhis_idx5 ONLINE;
	UPDATE statistics medium FOR TABLE CreditosCrd;
	
/*	select  crd.num_credito ,fecha_mov, codigo_fun, codigo_ref, monto
	 from CreditosCrd crd 
	 inner join bdicred:sd_movhiscrd mov on mov.empresa = '001' and mov.num_credito = crd.num_credito 	 
	        and    ((codigo_fun = '338' and codigo_ref = 21) or (codigo_fun = '338' and codigo_ref = 22) or (codigo_fun in ('020','021','022','023','024','025','027','028','222','225') and codigo_ref = 1)
				 or (codigo_fun = '001' and codigo_ref  in (3,4)) or (codigo_fun in ('001','002') and codigo_ref in (1,2,66))) 
			and reversado = 'N'             
*/
/*	  from bdicred:sd_movhiscrd mov
	 inner join CreditosCrd crd on crd.num_credito = mov.num_credito and crd.fecha_apertura >= mov.fecha_mov 
	 where mov.empresa = '001'
	   and mov.num_credito >= ''
       and    ((codigo_fun = '338' and codigo_ref = 21)
            or (codigo_fun = '338' and codigo_ref = 22)
            or (codigo_fun in ('020','021','022','023','024','025','027','028','222','225') and codigo_ref = 1)
            or (codigo_fun = '001' and codigo_ref  in (3,4))
            or (codigo_fun in ('001','002') and codigo_ref in (1,2,66))) 
	   and reversado = 'N'             
	into temp MovtosCred with no log;
	
	create index indx_mov on MovtosCred (num_credito );
	update statistics medium for table MovtosCred;*/
	
/*	select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
	DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
	from CreditosCrd crd
	inner join bdisolic:ss_resum_scor_fin scor on scor.empresa = crd.empresa and scor.num_solicitud = crd.num_credito
	where crd.num_producto in ('6011','6300','7600','7700')
	into temp scorfin with no log;

	create index indx_scor on scorfin (num_solicitud );
	update statistics medium for table scorfin;*/
	
	--------------------INSERTAR EN TABLA-----------------------------------
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH WITH HOLD
		SELECT a.num_credito, a.fecha_apertura, a.numcte, a.num_producto, a.credito_externo, a.sucursal, a.plazo, a.status_cred, a.ppyr_num_credito,
			a.monto_otorgado, a.sdo_cap_insoluto, a.sdo_capital, a.monto_vencido, a.mto_venc_trasp, a.cap_tras_no_venci, a.mto_fin_ven_trasp,
			c.fecha_ult_pago, suc.ciudad, NVL(a.monto_vencido,0) + NVL(a.mto_venc_trasp,0) + NVL(a.cap_tras_no_venci,0), a.interes, a.interes_vencido, a.tasa_interes,
			c.prox_fecha_pago, a.sdo_interes, a.tipoultimomov, a.fechaultmov,
			a.interes_moratorio
		  INTO   Vnum_credito, vfecha_apertura, Vnumcte, Vproducto, Vcreditoexterno, Vnum_sucursal, vplazo, vestatus, cPpyrNumCredito,
		    vmonto_apertura, vsaldo_insoluto, vcapital_vigente, vcapital_transitorio, vsaldo_vencido_exigible, vsaldo_vencido_no_exigible, vmes_vencido,
			dFechaUltPago, Vnumciudad, Vsaldovencido, Vinteres, Vinteresvencido, Vtasainteres,
			Vfechalimitedepago, VintVigente, vPpyrTipoUltimoMov, vPpyrFechaUltMov,
			vinteres_moratorio
		  FROM CreditosCrd a 
		INNER JOIN bdicred:sd_maecredanexocrd c ON c.empresa = cempresa AND c.num_credito = a.num_credito
		LEFT OUTER JOIN bdinteg:si_sucursales suc ON suc.empresa = c.empresa AND suc.sucursal = a.sucursal

		BEGIN WORK;
		  
		IF dFechaUltPago IS NULL OR dFechaUltPago = '' THEN let dFechaUltPago = DATE(1); END IF;
		IF cPpyrNumCredito IS NULL OR cPpyrNumCredito = '' THEN let cPpyrNumCredito = '-1'; END IF;
		IF vPpyrTipoUltimoMov IS NULL OR vPpyrTipoUltimoMov = '' THEN let vPpyrTipoUltimoMov = ''; END IF;
		IF vPpyrFechaUltMov IS NULL OR vPpyrFechaUltMov = '' THEN let vPpyrFechaUltMov = DATE(1); END IF;
		
		let cNumCredito = Vnum_credito;
		let iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;

		
		IF (Vproducto = '6011') THEN 				
			SELECT nvl(tar.num_tarjeta,0)
				INTO Vnumtarjetatdc 
			FROM bdicred:sd_tarjeta tar 
			WHERE tar.empresa =cempresa
			and tar.num_credito = Vcreditoexterno
			and tar.tipo_tarjeta ='T' 
			and tar.secuencia = (select max(tar2.secuencia)
								from bdicred:sd_tarjeta tar2
								where tar2.empresa = '001' 
								and tar2.num_credito = Vcreditoexterno
								and tar2.tipo_tarjeta ='T' );						
		END IF;

/*
		IF vestatus in ('BA','BT','E1','E2','E3') and (dMnto_vencido + dMto_venc_trasp) > 0 THEN
			SELECT --nvl(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
			nvl(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
			INTO --Vinteresvencido,
			  vinteres_moratorio
			FROM "informix".sd_amortiza_creditocrd
			WHERE empresa     = '001'
			AND num_credito = Vnum_credito
			AND capital_status IN ('2','7','6')
			AND fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);
		end IF;
*/
		select nvl(capital_mto_cuota,0)
		into Vabonobase
		from bdicred:sd_amortiza_creditocrd 
		where num_credito = Vnum_credito
		and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnum_credito);

/*
		select int_venc_bal28,int_venc_bal29,int_venc_bal30,int_venc_bal31
		into VintVenc28,VintVenc29,VintVenc30,VintVenc31
		from bdicred:sd_sdodiariocrd 
		where fecha = MDY(month(pfechacorte), 1,year(pfechacorte))
		and num_credito = Vnum_credito;
		
		IF to_char(pfechacorte, "%d") = 28 THEN 
			Let VintVencido = VintVenc28;
		ELIF to_char(pfechacorte, "%d") = 29 THEN 
			Let VintVencido = VintVenc29;
		ELIF to_char(pfechacorte, "%d") = 30 THEN
			Let VintVencido = VintVenc30;
		ELIF to_char(pfechacorte, "%d") = 31 THEN 
			Let VintVencido = VintVenc31;
		END IF;
*/		
--		IF Vproducto = '6011' THEN
--			IF vestatus IN ('BT','VP','E2','E3') and (dMnto_vencido + dMto_venc_trasp) > 0 THEN
			Let VintVencido = Vinteresvencido;
--			END IF;
--		END IF;
			
		SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,cd.nombre as dir_mun,
		es.estado as num_estado,es.nombre as dir_estado,cd.ciudad_coppel as cd_coppel,cd.nombre ,
		zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
		INTO vdir_calle,vdir_numero,vdir_colonia,vcp
		,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
		FROM bdinteg:si_direcciones_actual dir 
		inner join bdinteg:si_catcalles ca on (ca.numerocalle = dir.numerocalle)
		inner join bdinteg:si_catzonas zo on (zo.numerociudad = dir.numerociudad and zo.numerocolonia = dir.numerocolonia)
		inner join bdinteg:si_ciudades cd on (cd.estado  = dir.estado and cd.ciudad = dir.ciudad)
		inner join bdinteg:si_estados es on (es.estado = dir.estado)
		WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;

		SELECT LIMIT 1 correo_elec
		  INTO Vmail
		  FROM bdinteg:si_correos
		 WHERE numcte = Vnumcte
		   AND status_correo = 'A';
		
		/*SELECT LIMIT 1 a.telefono, b.telefono ,d.telefono,d.extension
		  INTO Vtel1 , Vtel2 ,Vtel3 ,Vext
		  FROM bdinteg:si_telefonos_actual a
		LEFT OUTER JOIN bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
		LEFT OUTER JOIN bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
		 WHERE a.empresa = cempresa
		   AND a.numcte = vnumcte 
		   AND a.tipo_tel = 1
		   AND a.status_tel = 'A' 
		   AND a.cofetel = 'V' ;*/
		   
		SELECT LIMIT 1 a.telefono, d.telefono,d.extension
			INTO Vtel1 , Vtel3 ,Vext
        FROM bdinteg:si_telefonos_actual a
--    LEFT OUTER JOIN bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
      LEFT OUTER JOIN bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
       WHERE a.empresa = cempresa
         AND a.numcte = vnumcte
         AND a.tipo_tel = 1
         AND a.status_tel = 'A' 
         AND a.cofetel = 'V' ;   

      SELECT LIMIT 1 a.telefono
			INTO Vtel2
        FROM bdinteg:si_telefonos_actual a
--      LEFT OUTER JOIN bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
--    LEFT OUTER JOIN bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
       WHERE a.empresa = cempresa
         AND a.numcte = vnumcte
         AND a.tipo_tel = 2
         AND a.status_tel = 'A' 
         AND a.cofetel = 'V' ;  
		   


/*		IF vestatus in ('AA','E1') and (dMnto_vencido + dMto_venc_trasp) = 0 THEN
			let Vsaldo_cierre =  Vcapital_vigente + vsaldo_vencido_exigible;	
		elif vestatus in ('BA','E1') and (dMnto_vencido + dMto_venc_trasp) > 0 THEN
			let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;	
		elif vestatus in ('BT','VP','E2','E3') and (dMnto_vencido + dMto_venc_trasp) > 0 THEN
			let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
		elif (vestatus <> 'FF') THEN 
*/		
		IF (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		else 
			LET Vsaldo_cierre = 0; 
		end IF;

		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------

--		let dFechaUltimoPago = date(1);
		
		IF dFechaUltPago >= dFechaInicio and dFechaUltPago <= pfechacorte THEN
			LET vPpyrTipoUltimoMov = 'P'; -- Pago
		else 
/*			select max(fecha_mov) into dFechaUltimoPago
			  from MovtosCred
			 where num_credito = Vnum_credito
			   and codigo_ref  in (3,4) and codigo_fun  = '001';*/

/*			select max(fecha_mov) into dFechaUltimoPago			   
			from bdicred:sd_movhiscrd mov 
			where mov.empresa = cempresa
			and mov.num_credito = Vnum_credito
			and mov.fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
			and mov.fecha_mov <= pfechacorte
	        and (codigo_fun = '001' and codigo_ref  in (3,4))
			and reversado = 'N';
			   
			IF dFechaUltimoPago IS NULL OR dFechaUltimoPago = '' THEN let dFechaUltimoPago = date(1); end IF;*/

			IF vfecha_apertura >= dFechaInicio and vfecha_apertura <= pfechacorte THEN
/*				IF Vproducto = '6011' THEN 
					LET vPpyrTipoUltimoMov = 'L'; -- Liquidació® C por Reestructura
					LET dFechaUltPago = vfecha_apertura;
				ELSE*/
					LET vPpyrTipoUltimoMov = 'A'; -- Apertura
--				END IF;		
			else 
/*				select max(fecha_mov) into dFechaUltimoPago
				from MovtosCred 
				where num_credito = Vnumcreditortc
				and codigo_ref in (1,2,66) and codigo_fun  in ('001','002') ;*/
--PENDIENTE POR DEFINIR YA QUE UNA REESTRUCTURA O PRÉTAMOS NO TIENEN DISPOSICIONES, SOLO APERTURAS
/*				select max(fecha_mov) into dFechaUltimoPago			   
				from bdicred:sd_movhiscrd mov 
				where mov.empresa = cempresa
				and mov.num_credito = Vnum_credito
				and mov.fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
				and mov.fecha_mov <= pfechacorte
				and (codigo_fun in ('001','002') and codigo_ref  in (1,2,66))
				and reversado = 'N';

				IF dFechaUltimoPago IS NULL OR dFechaUltimoPago = '' THEN let dFechaUltimoPago = date(1); end IF;
			
				IF dFechaUltimoPago != date(1) THEN
					IF  (Vproducto = '6011') THEN 
						LET vPpyrTipoUltimoMov = 'A'; -- Apertura
					ELSE
						LET vPpyrTipoUltimoMov = 'D'; -- Disposició®					END IF;
				end IF;*/
--				LET vPpyrTipoUltimoMov = ''; -- Sin movimiento
				LET dFechaUltPago = vPpyrFechaUltMov;
			end IF;
		end IF;

        SELECT COUNT(*),SUM(monto) INTO sNumPagos,dMontoPagos
          FROM bdicred:sd_movhiscrd
         WHERE empresa = cempresa
           AND fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
           AND fecha_mov <= pfechacorte
           AND num_credito = Vnum_credito
           AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
           AND codigo_ref = 1 
           AND reversado = 'N';

		IF dMontoPagos IS NULL OR dMontoPagos = '' THEN
			LET sNumPagos = 0;
			LET dMontoPagos = 0;
		END IF;
			
--Si es cuenta nueva se inserta registro nuevo en tabla, de lo contrario se actualizan datos a cuentas existentes
		IF cPpyrNumCredito = '-1' THEN
			SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
			INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
			FROM  bdinteg:si_cliente cte 
			INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
			WHERE cte.numcte = Vnumcte;
		
			SELECT nvl(cta.num_cta,0) 
			  INTO Vnum_tarjeta 
			  FROM bdicred:sd_ctascarg cta
			 WHERE empresa = cempresa
			   AND cta.num_credito = Vnum_credito;
			
			LET Vnumcuentartc = Vnum_tarjeta;	
		
			SELECT LIMIT 1 nvl(sc01,'')
			  INTO  Vsecc1
			  FROM bdiburo:br_sc  br 
			 WHERE  br.num_cliente = Vnumcte;			

			SELECT limit 1 nvl(sum(valor),0) into Vsecc2
			  FROM bdisolic:ss_detalle_scoring 
			 WHERE empresa = cempresa
			   AND num_solicitud = Vnum_credito;

---------------------
			select nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
			INTO Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, cGrupo
			from bdisolic:ss_resum_scor_fin scor
			where scor.empresa = cempresa
			and scor.num_solicitud = Vnum_credito;

 /*			SELECT limit 1  nvl(ingreso_mensual,0), nvl(situacion_pago,0), nvl(meses_historia,0), evalua_cc, nvl(grupo,'')
			  INTO Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, cGrupo
			  FROM scorfin
			 WHERE num_solicitud = Vnum_credito;*/
---------------------

		--obtener causa solicitud
			IF Vproducto != '6011' THEN
				select limit 1 nvl(a.causa_solicitud,'') into cMotivo
				from bdisolic:ss_autorizacion a
				where a.empresa = cempresa
				and a.num_solicitud = vNum_Credito
				and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = vNum_Credito and status_solicitud = 'AT')
				and a.status_solicitud = 'AT';
			ELSE
				let cMotivo = '';
			END IF;	
		
------------Obtenemos los valores de scores de originacion
			IF Vproducto = '6011' THEN
				let v_selectcredito = Vcreditoexterno;
			else 
				let v_selectcredito = Vnum_credito;
			end IF
			
			select evaluacion,
					(select evaluacion from bdisolic:ss_resumen_scoring where empresa = cempresa and num_solicitud = v_selectcredito and seccion= 2 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where empresa = cempresa and num_solicitud = v_selectcredito and seccion= 3 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where empresa = cempresa and num_solicitud = v_selectcredito and seccion= 4 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where empresa = cempresa and num_solicitud = v_selectcredito and seccion= 5 )
			 into dBcScore, dScoreProp, dFico, dFicoExtended, dIcc
			 from bdisolic:ss_resumen_scoring 
			where empresa = cempresa
			  and num_solicitud = v_selectcredito
			  and seccion = 1;
			
			SELECT LIMIT 1 DECODE(flag2creditoicc,'1','Evaluacion de segundo producto de credito en adelante','')
				INTO cFlag2Credito
				FROM bdisolic:"informix".ss_revision_determinacion
			   WHERE empresa = cempresa
			  AND num_solicitud = v_selectcredito;

			IF cFlag2Credito IS NULL THEN 
			   LET cFlag2Credito = ' ';
			END IF;
			
		-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini,CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cStatus_Ini,cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = cempresa
			 AND num_solicitud = v_selectcredito;
				 
			IF cStatus_Ini IS NULL OR cStatus_Ini = '' THEN LET cStatus_Ini = ' '; END IF;
			IF cRevisado IS NULL  or cRevisado = '' THEN LET cRevisado = ' '; END IF;			 
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = cempresa
			 AND num_solicitud = v_selectcredito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
		-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
			--IF vestatus != 'AA' OR (vestatus = 'VP' AND vmes_vencido > 0) THEN
			IF (vcapital_transitorio + vsaldo_vencido_exigible) > 0 THEN
--			IF vestatus != 'AA' OR (vestatus = 'VP' AND vmes_vencido > 0) OR ((dMnto_vencido + dMto_venc_trasp) > 0) THEN


				SELECT fecha_vencido INTO dFechaVencido
				FROM bdicred:sd_indicador_cred_crd
				WHERE empresa = cempresa
				AND num_credito = Vnum_credito;
					
				LET sMesesVencidos = TRUNC((pfechacorte - dFechaVencido)/30.4);
			ELSE
				LET sMesesVencidos = 0;
			END IF;

			INSERT INTO sd_pagosydisposicionescrd_carteras
				(num_producto,numcreditortc,numcreditotdc,numcuentartc,numtarjetatdc,numcte,numsucursal,numciudad,
				fechareestructura,saldoactual,interes,saldovencido,interesvencido,interes_moratorio,
				abonobase,abonosvencidos,estadocredito,plazortc,tasainteres,fechalimitedepago,fechaultmov,tipoultimomov,fechacorte,
				sdo_cap_vigente,sdo_cap_trasp_vigente,sdo_cap_noexig_vencido,sdo_cap_exig_vencido,sdo_int_vigente,sdo_int_vencido)
			VALUES
				(Vproducto,Vnum_credito,Vcreditoexterno,Vnumcuentartc,Vnumtarjetatdc,Vnumcte,Vnum_sucursal,Vnumciudad, 
				vfecha_apertura,Vsaldo_insoluto,Vinteres,Vsaldovencido,Vinteresvencido,vinteres_moratorio,
				Vabonobase,vmes_vencido,Vestatus,vplazo,Vtasainteres,Vfechalimitedepago,dFechaUltPago,vPpyrTipoUltimoMov,pfechacorte,
				vcapital_vigente,vcapital_transitorio,vsaldo_vencido_no_exigible,vsaldo_vencido_exigible,VintVigente,VintVencido);	
--			VsaldoCapital,VsaldoTrasp,VvenciNoExig,VvenciExig,VintVigente,VintVencido);	

--  vsaldo_insoluto, vcapital_vigente, vcapital_transitorio, vsaldo_vencido_exigible, vsaldo_vencido_no_exigible
--a.sdo_cap_insoluto,   a.sdo_capital, a.monto_vencido,       a.mto_venc_trasp,        a.cap_tras_no_venci,
			
			let iCuentasInsertadas = iCuentasInsertadas + 1;
		else
			update bdicred:sd_pagosydisposicionescrd_carteras
			   set	
--					numcreditortc		= Vnum_credito,
					numcreditotdc		= Vcreditoexterno,
--					numcuentartc		= Vnumcuentartc,
--					numtarjetatdc		= Vnumtarjetatdc,
					fechareestructura   = vfecha_apertura,
					saldoactual			= Vsaldo_insoluto,
					interes				= Vinteres,
					saldovencido		= Vsaldovencido,
					interesvencido		= Vinteresvencido,
					interes_moratorio	= vinteres_moratorio,
					abonobase			= Vabonobase,
					abonosvencidos		= vmes_vencido,
					estadocredito		= Vestatus,
					plazortc			= vplazo,
					tasainteres			= Vtasainteres,
					fechalimitedepago	= Vfechalimitedepago,
					fechaultmov			= dFechaUltPago,
					tipoultimomov		= vPpyrTipoUltimoMov,
					fechacorte			= pfechacorte,
					sdo_cap_vigente 	= vcapital_vigente,
					sdo_cap_trasp_vigente 	= vcapital_transitorio,
					sdo_cap_noexig_vencido 	= vsaldo_vencido_no_exigible,
					sdo_cap_exig_vencido 	= vsaldo_vencido_exigible,
					sdo_int_vigente 		= VintVigente,
					sdo_int_vencido 		= VintVencido
			   where numcreditortc = Vnum_credito;
			
			let iCuentasActualizadas = iCuentasActualizadas + 1;
		end IF;

		COMMIT WORK;
		
		LET	Vnumcreditortc			= '';LET Vcreditoexterno			= '';LET Vnumcuentartc			= ''; LET Vnumtarjetatdc   = '';
		LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0; LET Vnumciudad		= '';
		LET Vtasainteres		= 0;	LET vPpyrFechaUltMov = DATE(1);
		LET Vabonosvencidos         = 0; LET VintVigente		= 0;
		LET Vestadocredito          = 0;LET Vplazortc      			= 0;
		LET vPpyrTipoUltimoMov          = '';
		let Vprod					='';let vmontor1				= 0;let vmontor2				= 0;

		LET VintVencido		= 0; LET VintVenc28		= 0; LET VintVenc29		= 0; LET VintVenc30		= 0; LET VintVenc31		= 0;
		
		LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
		LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
		LET Vinteres       		= 0;	LET Vsaldovencido     	= 0;	LET Vinteresvencido   	= 0;
		LET vinteres_moratorio	= 0;	LET Vabonobase			= 0; LET	dFechaUltPago           = DATE(1); 

		LET Vproducto     		='';     LET Vnum_credito         = '';	 
		LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_suucursal		='';	 LET  Vingreso_mensual    = 0;
		LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
		LET Vestatus ='';	  
		LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfecha_mov = DATE(1);
		LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
		LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
		LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
		LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
		LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
		LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;	LET cMotivo = ''; LET Vfechalimitedepago	= DATE(1);
		
    END FOREACH;	
	
    let cMensajeBitacora = 'TOTAL Cuentas procesadas : ' || iTotalCuentasProcesadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;
    let cMensajeBitacora = 'Cuentas insertadas: ' || iCuentasInsertadas;
    let cMensajeBitacora = trim(cMensajeBitacora) ||'    Cuentas actualizadas: ' || iCuentasActualizadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;

--	SET DEBUG FILE TO "sp_arch_cartera_pyr_fin_mes.out";
--	TRACE ON;
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------

	--CREAR  ARCHIVO
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'_Ant.txt';
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) ||'Pagosydisposicionesmensual.unl' || ' DELIMITER ' || '''|'''  ||
--	' select * from sd_pagosydisposicionescrd_carteras;'||
	' select num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad, fechareestructura, '||
	' saldoactual, interes, saldovencido, interesvencido, interes_moratorio, abonobase, abonosvencidos, estadocredito, plazortc, tasainteres, '||
	' fechalimitedepago, fechaultmov, tipoultimomov, '|| ''''|| pfechacorte || ''''||', sdo_cap_vigente, sdo_cap_trasp_vigente, '||
	' sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido '||
	' from sd_pagosydisposicionescrd_carteras where fechacorte = '|| ''''|| pfechacorte || ''''||' ;'||
	' " > '|| TRIM(cruta) || 'Pagosydisposicionesmensual.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'Pagosydisposicionesmensual.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) || 'Pagosydisposicionesmensual.unl >' || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) || 'Pagosydisposicionesmensual.unl ' || TRIM(cruta) || 'Pagosydisposicionesmensual.sql';
	SYSTEM cSql;

	-- para Generar el archvio de Cifras.
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) || 'DirectorioCifrasControlRegistrosMens.unl'|| ' DELIMITER ' || '''|'''  ||
	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), '|| ''''|| pfechacorte || ''''||' FROM bdicred:sd_pagosydisposicionescrd_carteras where fechacorte = '|| ''''|| pfechacorte || ''''||' ' ||
--	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte FROM bdicred:sd_pagosydisposicionescrd_carteras group by fechacorte ' ||
	' " > '|| TRIM(cruta) || 'DirectorioCifrasControlQuerysMens.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) ||'DirectorioCifrasControlQuerysMens.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'DirectorioCifrasControlRegistrosMens.unl > '|| TRIM(cruta) || trim(cNombreArchivo2);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) ||'DirectorioCifrasControlRegistrosMens.unl ' || TRIM(cruta) ||'DirectorioCifrasControlQuerysMens.sql';
	SYSTEM cSql;
	
	LET cSql = '';
	LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' " || TRIM(cruta) || trim(cNombreArchivo) || ' >' || TRIM(cruta) || trim(cNombreArchivoNvo);
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "gzip " || TRIM(cruta) || trim(cNombreArchivoNvo);
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "gzip " || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;

	let cMensaje = trim(cMensaje) || ' TOTAL Cuentas procesadas: '|| iTotalCuentasProcesadas;

	RETURN cCod_ret,cMensaje;
	
END;
END PROCEDURE;