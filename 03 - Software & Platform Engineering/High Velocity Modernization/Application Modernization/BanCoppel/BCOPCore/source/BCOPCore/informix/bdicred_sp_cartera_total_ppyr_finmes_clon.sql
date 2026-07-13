CREATE PROCEDURE "informix".sp_cartera_total_ppyr_finmes_clon()
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
DEFINE pfechacorte 			DATE;
DEFINE Vult_dia_mes 		DATE;
--Structura
DEFINE Vcreditoexterno      CHAR(20);
DEFINE Vproducto     		CHAR(4);
DEFINE Vnum_credito         CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE  Vnumcte				CHAR(20);
DEFINE Vnum_tarjeta         CHAR(20);
DEFINE Vnum_sucursal		CHAR(4);
DEFINE  Vnom_sucursal		CHAR(40);
DEFINE  Vingreso_mensual    MONEY;
DEFINE  Vmonto_apertura     DECIMAL(18,2); 
DEFINE  Vfecha_apertura     DATE;

DEFINE  Vplazo 				SMALLINT;
DEFINE Vestatus 			CHAR (2);
DEFINE  Vsaldo_insoluto		DECIMAL(18,2);
DEFINE  Vcapital_vigente	DECIMAL(18,2);
DEFINE Vcapital_transitorio	DECIMAL(18,2);
DEFINE Vsaldo_vencido_exigible		DECIMAL(18,2);
DEFINE Vsaldo_vencido_no_exigible	DECIMAL(18,2);
DEFINE Vsaldo_actual 		DECIMAL(18,2); 
DEFINE  Vsaldo_cierre 		DECIMAL(18,2); 
DEFINE Vmes_vencido 		DECIMAL(18,2); 
DEFINE Vtipo_mov 			CHAR (1);
DEFINE Vfecha_mov 			DATE;

DEFINE Vsexo 				CHAR (1);
DEFINE Vfecha_nac 			DATE;
DEFINE Vnombre1 			CHAR(26);
DEFINE Vnombre2 			CHAR(26);
DEFINE Vapellido_p 			CHAR(26);
DEFINE Vapellido_m 			CHAR(26);
DEFINE Vmail 				CHAR (60);
DEFINE Vdir_calle 			CHAR(30);
DEFINE Vdir_numero 			CHAR(20);
DEFINE Vdir_colonia 		CHAR(32);
DEFINE Vcp 					CHAR(5);

DEFINE Vdir_municipio 		CHAR(60);
DEFINE Vnum_estado 			SMALLINT;
DEFINE Vdir_estado 			CHAR(30);
DEFINE Vnum_cd_coppel 		SMALLINT;
DEFINE Vcd_coppel 			CHAR(32);
DEFINE Vnum_cd_banco 		SMALLINT;
DEFINE  Vcd_banco 			CHAR(32);
DEFINE Vtel1 				CHAR(13);
DEFINE  Vtel2 				CHAR(13);
DEFINE Vtel3 				CHAR(13);
DEFINE Vext 				CHAR(5);

DEFINE Vref_coppel 			CHAR(20);
DEFINE Vficiencia 			DECIMAL(5,2);
DEFINE Vmeses_historia 		SMALLINT;
DEFINE Vhit 				CHAR(6);
DEFINE Vsecc1 				CHAR (4);
DEFINE Vsecc2 				DECIMAL(10,4);
DEFINE Vpri_dia_mes 		DATE;

	  --variables
DEFINE Vnumcreditortc       CHAR(20);
DEFINE VcreditoConsulta     CHAR(20);
DEFINE Vnumcuentartc      	CHAR(20);
--DEFINE Vnumcte        		CHAR(20);
DEFINE Vnumsucursal     	CHAR(4);
DEFINE Vsaldoactual      	DECIMAL(18,2);
DEFINE Vabonosvencidos		SMALLINT;
DEFINE Vestadocredito		CHAR(2);
DEFINE Vplazortc			SMALLINT;
DEFINE dFechaUltPago		DATE;
DEFINE dFechaUltimoPago		DATE;
DEFINE Vtipoultimomov		CHAR(2);
DEFINE Vfechacorte			DATE;
define cNombreArchivo		CHAR(70);
define cNombreArchivo2		CHAR(70);
define cNombreArchivoNvo	CHAR(70);
--define cempresa				CHAR(3);
define Vprod				CHAR(4);
define vmontor1				DECIMAL(18,2);
define vmontor2				DECIMAL(18,2);
DEFINE cMotivo				CHAR(5);
-- RQM 09 440

DEFINE dBcScore 			DECIMAL(5,2);
DEFINE dScoreProp 			DECIMAL(5,2);
DEFINE dFico 				DECIMAL(5,2);
DEFINE dFicoExtended 		DECIMAL(5,2);
DEFINE dIcc 				DECIMAL(5,2);
DEFINE v_selectcredito 		CHAR(20);
DEFINE cFlag2Credito   		VARCHAR(120,1);
DEFINE cStatus_Ini 			CHAR(2);
DEFINE cRevisado 			CHAR(2);
DEFINE cIdbox 				SMALLINT;
DEFINE cIfe 				CHAR(2);
DEFINE cGrupo				CHAR(01);
DEFINE sMesesVencidos 		SMALLINT;
DEFINE sNumPagos			SMALLINT;
DEFINE dMontoPagos			DECIMAL(18,2);
DEFINE dFechaVencido 		DATE;
DEFINE cPpyrNumCredito 		CHAR(20);

DEFINE iTotalCuentasProcesadas	INTEGER;
DEFINE iCuentasInsertadas		INTEGER;
DEFINE iCuentasActualizadas		INTEGER;
DEFINE dFechaInicio				DATE;
DEFINE vfecha_vencim		DATE;
DEFINE dFechaFin			DATE;
DEFINE dFecha				DATE;

DEFINE v_pago_mensual 		DECIMAL(18,2);

--Inicializacion de variables

LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET cCod_Ret				= "000000";
LET cCod_Ret2				= "000000";
LET cMensaje				= 'PROCESO EXITOSO.';
LET cMensajeBitacora		= '';
LET vproceso	            = '2070'; --'2060';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    		= "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte 			= DATE(1);
LET Vult_dia_mes 			= DATE(1);
LET Vpri_dia_mes 			= DATE(1);

-----VARIABLES
LET Vcreditoexterno			= '';
LET Vproducto				= '';
LET Vnum_credito			= '';
LET cNumCredito				= '';
LET VcreditoConsulta		= '';
LET  Vnumcte				= '';
LET Vnum_tarjeta			= '';
LET Vnum_sucursal			= '';
LET  Vnom_sucursal			= '';
LET  Vingreso_mensual		= 0;
LET  Vmonto_apertura		= 0;
LET  Vfecha_apertura		= DATE(1);

LET Vplazo						= 0;
LET Vestatus					= '';
LET Vsaldo_insoluto				= 0;
LET Vcapital_vigente			= 0;
LET Vcapital_transitorio		= 0;
LET Vsaldo_vencido_exigible		= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual				= 0;
LET Vsaldo_cierre				= 0;
LET Vmes_vencido				= 0;
LET Vtipo_mov					= '';
LET Vfecha_mov					= DATE(1);

LET Vsexo					= '';
LET Vfecha_nac				= DATE(1);
LET Vnombre1 				= '';
LET Vnombre2 				= '';
LET Vapellido_p 			= '';
LET Vapellido_m 			= '';
LET Vmail 					= '';
LET Vdir_calle 				= '';
LET Vdir_numero 			= '';
LET Vdir_colonia 			= '';
LET Vcp 					= '';

LET Vdir_municipio			= '';
LET Vnum_estado				= 0;
LET Vdir_estado				= '';
LET Vnum_cd_coppel			= 0;
LET Vcd_coppel				= '';
LET Vnum_cd_banco			= 0;
LET Vcd_banco				= '';
LET Vtel1					= '';
LET Vtel2					= '';
LET Vtel3					= '';
LET Vext					= '';

LET Vref_coppel				= '';
LET Vficiencia				= 0;
LET Vmeses_historia			= 0;
LET Vhit					= '';
LET Vsecc1					= '';
LET Vsecc2					= 0;

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
--LET	Vnumcte     		= '';
LET	Vnumsucursal			= 0;
LET Vsaldoactual			= 0;
LET Vabonosvencidos			= 0;
LET Vestadocredito			= 0;
LET Vplazortc				= 0;
LET	dFechaUltPago			= DATE(1);
LET dFechaUltimoPago		= DATE(1);
LET Vtipoultimomov			= '';
LET Vfechacorte				= DATE(1);
let Vprod					= '';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo					= '';

LET dScoreProp				= "";
LET dBcScore				= "";
LET dFico					= "";
LET dFicoExtended			= "";
LET dIcc					= "";
let v_selectcredito 		= "";
LET cFlag2Credito			= "";
LET cStatus_Ini				= "";
LET cRevisado				= "";
LET cIdbox					= 0;
LET cIfe					= "";
LET cGrupo					= '';
LET sMesesVencidos			= 0;
LET sNumPagos				= 0;
LET dMontoPagos				= 0;
LET dFechaVencido			= DATE(1);
LET cPpyrNumCredito			= '';

LET iTotalCuentasProcesadas	= 0;
LET iCuentasInsertadas		= 0;
LET iCuentasActualizadas	= 0;
LET dFechaInicio			= DATE(1);
LET vfecha_vencim			= DATE(1);
LET dFechaFin				= DATE(1);
LET dFecha					= DATE(1);
LET v_pago_mensual			= 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            --LET cMensaje = error_info;
			LET cMensaje = 'ERROR en el proceso: ' || cNumCredito || '   ' || trim(error_info);
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

--	SET DEBUG FILE TO "sp_cartera_total_ppyr_finmes.out";
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
	
	LET pfechacorte = mdy(month(today),1,year(today)) - 1; -- Ejecuta_finmesrse al cambio de fechas de CrÃÂ¯ÃÂ¿ÃÂ½dito y/o despuÃÂ¯ÃÂ¿ÃÂ½s de la 1.30 hrs. CDMX para que tome la fecha del nuevo dÃÂ¯ÃÂ¿ÃÂ½a
	
--temporal solo para pruebas	
--LET pfechacorte = mdy('01','01','2019') - 1;
--temporal solo para pruebas

	LET dFechaInicio = mdy(month(pfechacorte),1,year(pfechacorte));
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Genera tabla temporal', '02') returning cCod_ret2;
	
	select crd.num_credito, crd.fecha_apertura, crd.numcte , crd.num_producto, crd.credito_externo, crd.sucursal, crd.plazo, crd.status_cred, ppyr.num_credito ppyr_num_credito,
			b.monto_otorgado, b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci,b.mto_fin_ven_trasp, crd.fecha_vencim, ppyr.fecha,
			ppyr.pago_mensual
	  from bdicred:sd_maecredcontcrd crd 
      inner join bdicred:sd_maesdoscontcrd b on b.fecha = crd.fecha and b.empresa = crd.empresa and b.num_credito = crd.num_credito
	  left outer join bdicred:sd_cartera_total_ppyr_finmes ppyr on ppyr.num_credito = crd.num_credito
	 where crd.fecha =pfechacorte 
	   and crd.empresa = '001'
	   and crd.num_producto in ('6300','6011','7600','7700','6800') 
---quitar status FI
	   and crd.status_cred != 'FI'
	   and crd.campo_trab3 = 'BAJA'
	   -- and crd.campo_trab3 <> 'BAJA'
--and crd.num_credito='610002828016'
	into temp CreditosCrd with no log;

	create index indx_creditos on CreditosCrd (num_credito) using btree in dbs_movhis_idx5 ONLINE;
	update statistics medium for table CreditosCrd;
	
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
		select a.num_credito, a.fecha_apertura, a.numcte, a.num_producto, a.credito_externo, a.sucursal, suc.nombre, a.plazo, a.status_cred, a.ppyr_num_credito,
			a.monto_otorgado, a.sdo_cap_insoluto, a.sdo_capital, a.monto_vencido, a.mto_venc_trasp, a.cap_tras_no_venci, a.mto_fin_ven_trasp,
			c.fecha_ult_pago, NVL(a.fecha_vencim,DATE(1)), a.fecha
		  into   Vnum_credito, vfecha_apertura, Vnumcte, Vproducto, Vcreditoexterno, Vnum_sucursal, vnom_sucursal, vplazo, vestatus, cPpyrNumCredito,
		    vmonto_apertura, vsaldo_insoluto, vcapital_vigente, vcapital_transitorio, vsaldo_vencido_exigible, vsaldo_vencido_no_exigible, vmes_vencido,
			dFechaUltPago, vfecha_vencim, dFecha
		  from CreditosCrd a 
		 inner join bdicred:sd_maecredanexocrd c on c.empresa = cempresa and c.num_credito = a.num_credito
		 left outer join bdinteg:si_sucursales suc on suc.empresa = cempresa and suc.sucursal = a.sucursal

  
		if dFechaUltPago is null or dFechaUltPago = '' then let dFechaUltPago = date(1); end if;
		if cPpyrNumCredito is null or cPpyrNumCredito = '' then let cPpyrNumCredito = '-1'; end if;
		if dFecha is null or dFecha = '' then let dFecha = date(1); end if;

		if dFecha = pfechacorte then CONTINUE FOREACH; end if;

		BEGIN WORK;
	
		let cNumCredito = Vnum_credito;
		let iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;

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

		if vestatus = 'AA' then
			let Vsaldo_cierre =  Vcapital_vigente + vsaldo_vencido_exigible;	
		elif vestatus = 'BA' then
			let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;	
		elif vestatus in ('BT','VP') then
			let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
		elif (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		else 
			LET Vsaldo_cierre = 0; 
		end if;

		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------

--		let dFechaUltimoPago = date(1);
		
		if dFechaUltPago >= dFechaInicio and dFechaUltPago <= pfechacorte then
			LET Vtipoultimomov = 'P'; -- Pago
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
			   
			if dFechaUltimoPago is null or dFechaUltimoPago = '' then let dFechaUltimoPago = date(1); end if;*/

			if vfecha_apertura >= dFechaInicio and vfecha_apertura <= pfechacorte then
/*				IF Vproducto = '6011' THEN 
					LET Vtipoultimomov = 'L'; -- LiquidaciÃÂ¯ÃÂ¿ÃÂ½n TC por Reestructura
					LET dFechaUltPago = vfecha_apertura;
				ELSE*/
					LET Vtipoultimomov = 'A'; -- Apertura
--				END IF;		
			else 
/*				select max(fecha_mov) into dFechaUltimoPago
				from MovtosCred 
				where num_credito = Vnumcreditortc
				and codigo_ref in (1,2,66) and codigo_fun  in ('001','002') ;*/
--PENDIENTE POR DEFINIR YA QUE UNA REESTRUCTURA O PRÃÂ¯ÃÂ¿ÃÂ½STAMOS NO TIENEN DISPOSICIONES, SOLO APERTURAS
/*				select max(fecha_mov) into dFechaUltimoPago			   
				from bdicred:sd_movhiscrd mov 
				where mov.empresa = cempresa
				and mov.num_credito = Vnum_credito
				and mov.fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
				and mov.fecha_mov <= pfechacorte
				and (codigo_fun in ('001','002') and codigo_ref  in (1,2,66))
				and reversado = 'N';

				if dFechaUltimoPago is null or dFechaUltimoPago = '' then let dFechaUltimoPago = date(1); end if;
			
				if dFechaUltimoPago != date(1) then
					IF  (Vproducto = '6011') THEN 
						LET Vtipoultimomov = 'A'; -- Apertura
					ELSE
						LET Vtipoultimomov = 'D'; -- DisposiciÃÂ¯ÃÂ¿ÃÂ½n
					END IF;
				end if;*/
				LET Vtipoultimomov = ''; -- Sin movimiento
			end if;
		end if;

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
		

		SELECT pago_mens
			INTO v_pago_mensual
			FROM bdisolic:ss_revision_determinacion
			WHERE num_solicitud = Vnum_credito;
			
		IF v_pago_mensual IS NULL OR v_pago_mensual = '' THEN
			LET v_pago_mensual = 0;
		END IF;

	-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
		IF vestatus != 'AA' OR (vestatus = 'VP' AND vmes_vencido > 0) THEN
/*				SELECT fecha_vencido INTO dFechaVencido
			FROM bdicred:sd_indicador_cred_crd
			WHERE empresa = cempresa
			AND num_credito = Vnum_credito;
					
			LET sMesesVencidos = TRUNC((pfechacorte - dFechaVencido)/30.4);*/

			-- RQM 09 476 - 2 ADENDUM 				
			IF pfechacorte <= vfecha_vencim THEN 	
				LET sMesesVencidos = vmes_vencido; -- sd_maesdosCONTcrd
			ELSE
						
				--Caso donde el credito vencio: cuenta meses en la actual + meses historicos 
				--BIS 2008,2012,2016,2020,2024
				IF month(vfecha_vencim)in ('01','03','05','07','08','10','12') then 
					Let dFechaFin = mdy(month(vfecha_vencim),'31',year(vfecha_vencim));
				ELIF month(vfecha_vencim)in ( '04','06','09','11') then 
					Let dFechaFin = mdy(month(vfecha_vencim),'30',year(vfecha_vencim));
				ELIF month(vfecha_vencim) = '02' then 
					--IF mod(year(vfecha_vencim),4) = 0 AND ((mod(year(vfecha_vencim),4,100)) <> 0 OR (mod(year(vfecha_vencim),400) = 0)) THEN
					IF year(vfecha_vencim) IN ('2008','2012','2016','2020','2024','2028') then 
						Let dFechaFin = mdy(month(vfecha_vencim),'29',year(vfecha_vencim));
					ELSE
						Let dFechaFin = mdy(month(vfecha_vencim),'28',year(vfecha_vencim));
					END IF;
				END IF;
				
				SELECT (year((pfechacorte)+1 units month) - year(dFechaFin)) * 12 + ( month((pfechacorte)+1 units month) - month(dFechaFin))
				INTO sMesesVencidos
				FROM bdicred:sd_maesdoscontcrd 
				WHERE num_credito = Vnum_credito
				AND fecha= pfechacorte;
			END IF;
		ELSE
			LET sMesesVencidos = 0;
		END IF;
	
		
--Si es cuenta nueva se inserta registro nuevo en tabla, de lo contrario se actualizan datos a cuentas existentes
		if cPpyrNumCredito = '-1' then
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
			if Vproducto = '6011' then
				let v_selectcredito = Vcreditoexterno;
			else 
				let v_selectcredito = Vnum_credito;
			end if
			
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
				 
			IF cStatus_Ini IS NULL or cStatus_Ini = '' THEN LET cStatus_Ini = ' '; END IF;
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

			INSERT INTO bdicred:sd_cartera_total_ppyr_finmes 
					(fecha, producto, num_credito, numcte, num_tarjeta, num_sucursal, nom_sucursal, ingreso_mensual,
					monto_apertura, fecha_apertura, plazo, estatus, saldo_insoluto, capital_vigente,
					capital_transitorio, saldo_vencido_exigible, saldo_vencido_no_exigible, saldo_actual, 
					saldo_cierre, mes_vencido, tipo_mov, fecha_mov, sexo, fecha_nac, nombre1, Nombre2, apellido_p,
					apellido_m, mail, dir_calle, dir_numero, dir_colonia, cp, dir_municipio, num_estado,
					dir_estado, num_cd_coppel, cd_coppel, num_cd_banco, cd_banco, tel1, tel2, tel3, ext, ref_coppel,
					eficiencia, meses_historia, hit, secc1, secc2, motivo, bc_score, score_prop, fico, fico_extended,
					icc, flag2credito, status, revisado, ife, grupo, meses_vencidos, num_pagos, monto_pagos,pago_mensual)
			VALUES
					(pfechacorte, Vproducto, Vnum_credito, Vnumcte, Vnum_tarjeta, Vnum_sucursal, Vnom_sucursal, nvl(Vingreso_mensual,''),
					Vmonto_apertura, Vfecha_apertura, Vplazo, Vestatus, Vsaldo_insoluto, Vcapital_vigente,
					Vcapital_transitorio, Vsaldo_vencido_exigible, Vsaldo_vencido_no_exigible, Vsaldo_actual,
					Vsaldo_cierre, Vmes_vencido, Vtipoultimomov, dFechaUltPago, Vsexo, Vfecha_nac, Vnombre1, Vnombre2, Vapellido_p,
					Vapellido_m, nvl(Vmail,''), Vdir_calle, Vdir_numero, Vdir_colonia, Vcp, Vdir_municipio, Vnum_estado,
					Vdir_estado, Vnum_cd_coppel, Vcd_coppel, Vnum_cd_banco, Vcd_banco, nvl(Vtel1,''), nvl(Vtel2,''), nvl(Vtel3,''),nvl(Vext,''), Vref_coppel,
					Vficiencia, Vmeses_historia, Vhit, Vsecc1, Vsecc2, cMotivo, nvl(dBcScore,''), nvl(dScoreProp,''), nvl(dFico,''), nvl(dFicoExtended,''), 
					nvl(dIcc,''), cFlag2Credito, cStatus_Ini, cRevisado, cIfe, nvl(cGrupo,''), nvl(sMesesVencidos,0), nvl(sNumPagos,0), nvl(dMontoPagos,0),
					v_pago_mensual);

			let iCuentasInsertadas = iCuentasInsertadas + 1;
		else
			update bdicred:sd_cartera_total_ppyr_finmes
			   set	
					fecha = pfechacorte, estatus = vestatus, saldo_insoluto = Vsaldo_insoluto, capital_vigente = Vcapital_vigente, 
					capital_transitorio = Vcapital_transitorio, saldo_vencido_exigible = Vsaldo_vencido_exigible,
					saldo_vencido_no_exigible = Vsaldo_vencido_no_exigible, saldo_actual = Vsaldo_actual, saldo_cierre = Vsaldo_cierre,
					mes_vencido = Vmes_vencido, tipo_mov = Vtipoultimomov, fecha_mov = dFechaUltPago, mail = nvl(Vmail,''),
					dir_calle = Vdir_calle, dir_numero = Vdir_numero, dir_colonia = Vdir_colonia, cp = Vcp, dir_municipio = Vdir_municipio,
					num_estado = Vnum_estado, dir_estado = Vdir_estado, num_cd_coppel = Vnum_cd_coppel, cd_coppel = Vcd_coppel, 
					num_cd_banco = Vnum_cd_banco, cd_banco = Vcd_banco, tel1 = nvl(Vtel1,''), tel2 = nvl(Vtel2,''), tel3 = nvl(Vtel3,''),
					ext = nvl(Vext,''), meses_vencidos = nvl(sMesesVencidos,0), num_pagos = nvl(sNumPagos,0), monto_pagos = nvl(dMontoPagos,0),
					pago_mensual = v_pago_mensual
			where num_credito = Vnum_credito;
			
			let iCuentasActualizadas = iCuentasActualizadas + 1;
		end if;

		COMMIT WORK;
		
		LET	Vnumcreditortc			= '';LET Vcreditoexterno			= '';LET Vnumcuentartc			= '';
		LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0;
		LET Vsaldoactual			= 0;
		LET Vabonosvencidos         = 0;
		LET Vestadocredito          = 0;LET Vplazortc      			= 0;
		LET Vtipoultimomov          = '';
		let Vprod					='';let vmontor1				= 0;let vmontor2				= 0;
					
			
		LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
		LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
		LET Vproducto     		='';     LET Vnum_credito         = '';	 LET  Vnumcte				='';
		LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_sucursal		='';	 LET  Vingreso_mensual    = 0;
		LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
		LET Vestatus ='';	  
		LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfecha_mov = DATE(1);
		LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
		LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
		LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
		LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
		LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
		LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;	LET cMotivo = '';
		
    END FOREACH;	
	
    let cMensajeBitacora = 'TOTAL Cuentas procesadas : ' || iTotalCuentasProcesadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;
    let cMensajeBitacora = 'Cuentas insertadas: ' || iCuentasInsertadas;
    let cMensajeBitacora = trim(cMensajeBitacora) ||'    Cuentas actualizadas: ' || iCuentasActualizadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;

--SET DEBUG FILE TO "prueba12052017-1.out";
--TRACE ON;	
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/jorger/pruebas/';
	--let cruta = '/aplicacion/Jorge/Adendum_Reporte_Cartera/Nuevo/';
	let cnombre = 'Cartera_Total_FinMes';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
--	LET cSQL2 = " select * from bdicred:sd_cartera_total_ppyr_finmes ";
	LET cSQL2 = ' select producto,num_credito,numcte,num_tarjeta,num_sucursal,nom_sucursal,ingreso_mensual,monto_apertura,fecha_apertura,plazo,estatus,saldo_insoluto,capital_vigente,'||
	' capital_transitorio,saldo_vencido_exigible,saldo_vencido_no_exigible,saldo_actual,saldo_cierre,mes_vencido,tipo_mov,fecha_mov,sexo,fecha_nac,'||
	' nombre1,nombre2,apellido_p,apellido_m,mail,dir_calle,dir_numero,dir_colonia,cp,dir_municipio,num_estado,dir_estado,num_cd_coppel,cd_coppel,num_cd_banco,cd_banco,'||
	' tel1,tel2,tel3,ext,ref_coppel,eficiencia,meses_historia,hit,secc1,secc2,motivo,bc_score,score_prop,fico,fico_extended,icc,flag2credito,status,revisado,ife,'||
	' grupo,meses_vencidos,num_pagos,monto_pagos,pago_mensual'||
	' from bdicred:sd_cartera_total_ppyr_finmes where fecha = '|| ''''|| pfechacorte || ''''||'';
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_finmes.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_finmes.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_finmes.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " > " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSql = cSql;
    LET cSql = "gzip "|| TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_finmes.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 

/*
	--segundo archivo
	--CREAR  ARCHIVO
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'_Ant.txt';
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) ||'Pagos1.unl' || ' DELIMITER ' || '''|'''  ||
	' select * from sd_pagosydisposicionescrd_cartera;'||
	' " > '|| TRIM(cruta) || 'Pagosydisposiciones2crd.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) || 'Pagos1.unl >' || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;

	let cSql = '';

	LET cSql = "rm " || TRIM(cruta) || 'Pagos1.unl ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	-- para Generar el archvio de Cifras.
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) || 'DirectorioCifrasControlRegistros.unl'|| ' DELIMITER ' || '''|'''  ||
	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte FROM bdicred:sd_pagosydisposicionescrd_cartera group by fechacorte ' ||
	' " > '|| TRIM(cruta) || 'DirectorioCifrasControlQuerys.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl > '|| TRIM(cruta) || trim(cNombreArchivo2);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;
	
	LET cSql = '';
	LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' " || TRIM(cruta) || trim(cNombreArchivo) || ' >' || TRIM(cruta) || trim(cNombreArchivoNvo);
	SYSTEM cSql;
*/	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;

	let cMensaje = trim(cMensaje) || ' TOTAL Cuentas procesadas: '|| iTotalCuentasProcesadas;

	RETURN cCod_ret,cMensaje;
	
END;
END PROCEDURE;