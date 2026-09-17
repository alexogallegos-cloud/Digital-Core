CREATE PROCEDURE "informix".sp_arch_cartera_pyr_opt()
RETURNING CHAR(6),
		  CHAR(150);

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE cSQL                 CHAR(2204);
DEFINE cCod_RetIB           CHAR(6);
define pfechacorte 			date;
define Vpri_dia_mes			date;
define Vult_dia_mes			date;
define vproceso				char(4);
--variables
DEFINE Vnumcreditortc       char(20);
DEFINE Vnumcreditotdc       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumtarjetatdc       char(20);
DEFINE Vnumcte        		char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vnumciudad			char(4);
DEFINE Vfechareestructura 	date;
DEFINE Vsaldoactual      	decimal(18,2);
DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE Vtasainteres			decimal(18,2);
DEFINE Vfechalimitedepago	date;
DEFINE Vfechaultmov			date;
DEFINE Vtipoultimomov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
define cNombreArchivoNvo	char(70);
define sPaso				integer;
define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
-- RQM 09 440
DEFINE VsaldoCapital		decimal(18,2);
DEFINE VsaldoTrasp			decimal(18,2);
DEFINE VvenciNoExig			decimal(18,2);
DEFINE VvenciExig			decimal(18,2);
DEFINE VintVigente			decimal(18,2);
DEFINE VintVencido			decimal(18,2);
DEFINE dFechaInicio			date;

DEFINE iTotalCuentasProcesadas	INTEGER;
DEFINE iCuentasInsertadas		INTEGER;
DEFINE iCuentasActualizadas		INTEGER;


DEFINE Vppyrnumcreditortc	char(20);
DEFINE Vppyrestadocredito	char(02);
DEFINE Vppyrtipoultimomov	char(02);
DEFINE Vppyrfechaultmov		date;
DEFINE dfechaultpago		date;
DEFINE vfecha_apertura		date;
DEFINE cNumCredito			char(20);

DEFINE cMensajeBitacora 	CHAR(80);

--SET DEBUG FILE TO "sp_arch_cartera_pyr_opt.out";
--TRACE ON; 

--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_ret2				= "000000";
LET cMensaje                = 'PROCESO EXITOSO.';
LET cSQL                    = "";
LET cCod_RetIB              = "000000";
let vproceso				='2071'; --'2069';
--variables
LET	Vnumcreditortc			= '';
LET Vnumcreditotdc			= '';
LET Vnumcuentartc			= '';
LET	Vnumtarjetatdc			= '';
LET	Vnumcte           	    = '';
LET	Vnumsucursal			= 0;
LET	Vnumciudad	            = '';
LET Vfechareestructura		= DATE(1);
LET Vsaldoactual			= 0;
LET Vinteres                = 0;
LET Vsaldovencido           = 0;
LET Vinteresvencido         = 0;
LET Vabonobase              = 0;
LET Vabonosvencidos         = 0;
LET vinteres_moratorio		= 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET Vtasainteres   		    = 0;
LET Vfechalimitedepago      = DATE(1);
LET	Vfechaultmov            = DATE(1);
LET Vtipoultimomov          = '';
LET Vfechacorte             = DATE(1);
let cempresa 				= '001';
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
-- RQM 09 440
LET VsaldoCapital			= 0;
LET VsaldoTrasp				= 0;
LET VvenciNoExig			= 0;
LET VvenciExig				= 0;
LET VintVigente				= 0;
LET VintVencido				= 0;
LET dFechaInicio			= DATE(1);
LET iTotalCuentasProcesadas	= 0;
LET iCuentasInsertadas		= 0;
LET iCuentasActualizadas	= 0;

LET Vppyrnumcreditortc		= '';
LET Vppyrestadocredito		= '';
LET Vppyrtipoultimomov		= '';
LET Vppyrfechaultmov		= DATE(1);
LET dfechaultpago			= DATE(1);
LET vfecha_apertura			= DATE(1);
LET cNumCredito				= '';
LET cMensajeBitacora 		= '';

--LET cNombreArchivo1= 'DirectorioCtesBancoppel' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo ='cartera_reestructura_prestamo' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
        

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
--            LET cMensaje = error_info;
			LET cMensaje = 'ERROR en el proceso: ' || TRIM(cNumCredito) || '   ' || 'columna ' || TRIM(error_info);
--            CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02');
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	SELECT fecha_hoy, fecha_hoy - 1 units DAY --fecha_ant, pri_dia_mes 
	INTO pfechacorte,Vult_dia_mes -- ,Vpri_dia_mes 
	FROM bdicred:sd_fechas WHERE empresa = '001';
--temporal solo para pruebas
--let pfechacorte = mdy('06','03','2024');
--temporal solo para pruebas
	-- corre dias 3, 18 y 21
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'productos';
		IF NVL(sPaso,0) > 0 THEN
			DROP TABLE productos;
		END IF;
	
	CREATE TEMP TABLE productos(
	num_producto	CHAR(4)) WITH NO LOG;
	
	IF (day(pfechacorte) in(3,18)) OR ( day(pfechacorte) <= 20 ) THEN
		INSERT INTO productos VALUES ('6011');
		IF ( DAY(pfechacorte) < 17 ) THEN
		  let Vfechacorte = 2;
		ELSE 
		  let Vfechacorte = 17;
		END IF;
--		let Vfechainicio = Vfechacorte - 1 units MONTH;
	END IF;
	IF ( day(pfechacorte) > 20 ) THEN
		INSERT INTO productos VALUES ('6300');
		INSERT INTO productos VALUES ('7600');
		INSERT INTO productos VALUES ('7700');
		let Vfechacorte = 20;	
	END IF;

	let Vfechacorte = mdy(MONTH(pfechacorte), DAY(Vfechacorte), YEAR(pfechacorte));

	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(Vfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(Vfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(Vfechacorte,'%d%m%Y')||'_Ant.txt';
  
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH WITH HOLD
		SELECT  NVL(a.num_producto,0),NVL(a.num_credito,0),NVL(a.credito_externo,0),NVL(cta.num_cta,0),NVL(tar.num_tarjeta,0), NVL(a.numcte,0),NVL(a.sucursal,0),NVL(s.ciudad,0),a.fecha_apertura,
				NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)
				,NVL(b.mto_fin_ven_trasp,0),NVL(a.status_cred,''),NVL(a.plazo,0),NVL(a.tasa_interes,0) ,NVL(c.prox_fecha_pago,'01/01/1900')
				,c.fecha_ult_pago, 
				(CASE WHEN (a.status_cred IN ('AA','E1')) THEN (sdo_intereses + sdo_no_exig) ELSE 0 END),
				(CASE WHEN (a.status_cred NOT IN ('AA','E1')) THEN (sdo_intereses + sdo_no_exig + int_tra_no_exig) ELSE 0 END) --,today--,(b.sdo_exig_int + b.mto_venc_tra_int)
		INTO 	Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc,Vnumtarjetatdc ,Vnumcte,	Vnumsucursal,Vnumciudad, Vfechareestructura ,     
				Vsaldoactual,Vabonosvencidos ,Vestadocredito ,Vplazortc,Vtasainteres,Vfechalimitedepago,
				Vfechaultmov,Vinteres, Vinteresvencido   --Vfechacorte -- ,Vinteresvencido
		FROM bdicred:sd_maecredcrd a
			LEFT JOIN bdicred:sd_maesdoscrd b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
			LEFT JOIN bdicred:sd_ctascarg cta ON a.num_credito = cta.num_credito AND cta.naturaleza = 'A'
			LEFT JOIN bdicred:sd_tarjeta tar ON  a.empresa = tar.empresa AND a.credito_externo = tar.num_credito AND tar.tipo_tarjeta ='T' AND tar.secuencia = (SELECT MAX(tar2.secuencia)
							FROM bdicred:sd_tarjeta tar2
							WHERE tar2.empresa = '001' 
							AND tar2.num_credito = a.credito_externo
							AND tar2.tipo_tarjeta ='T' )
			LEFT JOIN bdinteg:si_sucursales s ON (a.empresa = s.empresa AND a.sucursal = s.sucursal)
			LEFT JOIN bdicred:sd_maecredanexocrd c ON(a.empresa = c.empresa AND a.num_credito = c.num_credito)
		WHERE a.empresa ='001'
			AND a.num_producto IN (SELECT num_producto FROM productos)
			AND a.status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
			AND a.campo_trab3 <> 'BAJA'
	
	
		IF Vnumcreditortc IS NULL OR Vnumcreditortc = '' THEN CONTINUE FOREACH; END IF;
		IF Vfechaultmov IS NULL OR Vfechaultmov = '' THEN LET Vfechaultmov = DATE(1); END IF;
		IF Vfechareestructura IS NULL OR Vfechareestructura = '' THEN LET Vfechareestructura = DATE(1); END IF;
		IF Vppyrnumcreditortc IS NULL OR Vppyrnumcreditortc = '' THEN LET Vppyrnumcreditortc = ''; END IF;
		IF Vppyrestadocredito IS NULL OR Vppyrestadocredito = '' THEN LET Vppyrestadocredito = ''; END IF;
		IF Vppyrtipoultimomov IS NULL OR Vppyrtipoultimomov = '' THEN LET Vppyrtipoultimomov = ''; END IF;
		IF Vppyrfechaultmov IS NULL OR Vppyrfechaultmov = '' THEN LET Vppyrfechaultmov = DATE(1); END IF;
		
		LET cNumCredito = Vnumcreditortc;
		LET iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;
	
		SELECT ppyr.numcreditortc,ppyr.estadocredito,ppyr.tipoultimomov,ppyr.fechaultmov
		INTO Vppyrnumcreditortc,Vppyrestadocredito,Vppyrtipoultimomov,Vppyrfechaultmov
		FROM bdicred:sd_pagosydisposicionescrd_carteras ppyr 
		WHERE ppyr.numcreditortc = Vnumcreditortc;

		IF Vppyrnumcreditortc IS NULL OR Vppyrnumcreditortc = '' THEN LET Vppyrnumcreditortc = '-1';  END IF;
		IF Vppyrestadocredito IS NULL OR Vppyrestadocredito = '' THEN LET Vppyrestadocredito = '';    END IF;
		IF Vppyrtipoultimomov IS NULL OR Vppyrtipoultimomov = '' THEN LET Vppyrtipoultimomov = '';    END IF;
		IF Vppyrfechaultmov   IS NULL OR Vppyrfechaultmov = ''   THEN LET Vppyrfechaultmov = DATE(1); END IF;
		
		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
		IF (Vprod = '6300' OR Vprod = '7600' OR Vprod = '7700') THEN
	/*		if exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028')
				and fecha_mov = Vfechaultmov 
				AND num_producto in ('6300','7600','7700'))then */
			IF dFechaUltPago >= dFechaInicio AND dFechaUltPago <= Vfechacorte THEN
				LET Vtipoultimomov = 'P'; -- Pago
			ELSE
				IF Vfechareestructura >= dFechaInicio AND Vfechareestructura <= Vfechacorte THEN
		/*		elif 
				exists(select num_credito 
					from bdicred:sd_movhiscrd 
					where empresa = '001'
					and num_credito = Vnumcreditortc
					and codigo_ref = 3 and codigo_fun  = '001'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 3 and codigo_fun  = '001' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700')) then*/
			
					LET Vtipoultimomov = 'A'; -- Apertura
					LET Vfechaultmov = Vfechareestructura;
		/*		elif
				exists(select num_credito 
					from bdicred:sd_movhiscrd 
					where empresa = '001'
					and num_credito = Vnumcreditortc
					and codigo_ref = 66 and codigo_fun  ='002'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700')) then
					
					select LIMIT 1 fecha_mov into  Vfechaultmov
					from bdicred:sd_movhiscrd 
					where empresa = '001'	and num_credito = Vnumcreditortc	and codigo_ref = 66 and codigo_fun  ='002'
					and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
					AND num_producto in ('6300','7600','7700');

					LET Vtipoultimomov = 'D'; -- DisposiciÃ³n
					LET Vfechaultmov = Vfechaultmov;*/

--					LET Vtipoultimomov = ''; -- Sin movimiento
--					LET Vfechaultmov = '';*/
				END IF;
			END IF;
		END IF;			

		IF (Vprod = '6011') THEN
		--obtienes el interes vencido cargado a la reestruc   --intereses moratorios
		/*
			select limit 1 NVL(monto,0) into vmontor1
			FROM bdicred:sd_movhis 
			where empresa = '001' and num_credito = Vnumcreditortc 
			and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N'
			and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N');
		
			select limit 1 NVL(monto,0) into vmontor2
			FROM bdicred:sd_movhis 
			where empresa = '001' and num_credito = Vnumcreditortc 
			and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'
			and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'); 
			*/
			--let Vinteres = vmontor1 + vmontor2;
			--if   Vinteres is null then let Vinteres = 0; end if;
			IF dFechaUltPago >= dFechaInicio AND dFechaUltPago <= Vfechacorte THEN
	/*		if exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_fun in ('225','222')	and codigo_ref = 1
				and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
				AND num_producto = '6011') then*/
				LET Vtipoultimomov = 'P'; -- Pago
			ELSE
				IF vfecha_apertura >= dFechaInicio AND vfecha_apertura <= pfechacorte THEN
	/*		elif
			exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref in(1,2) and codigo_fun  in ('001','002')
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref in(1,2) and codigo_fun  in ('001','002') and num_credito = Vnumcreditortc)
				AND num_producto = '6011') then*/
		
					LET Vtipoultimomov = 'A'; -- Apertura
	--			LET Vfechaultmov = Vfechareestructura;
/*			elif
			exists(select num_credito 
				from bdicred:sd_movhiscrd 
				where empresa = '001'
				and num_credito = Vnumcreditortc
				and codigo_ref = 4 and codigo_fun  ='001'
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 4 and codigo_fun  ='001' and num_credito = Vnumcreditortc) 
				AND num_producto = '6011') then
				
				select LIMIT 1 fecha_mov INTO Vfechaultmov
				from bdicred:sd_movhiscrd 
				where empresa = '001'	and num_credito = Vnumcreditortc	and codigo_ref = 4 and codigo_fun  ='001'
				and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 4 and codigo_fun  ='001' and num_credito = Vnumcreditortc) 
				AND num_producto = '6011';
				
				LET Vtipoultimomov = 'L'; -- LiquidaciÃ³n TC por Reestructura
				LET Vfechaultmov = Vfechaultmov;
				LET Vtipoultimomov = ''; -- Sin movimiento
				LET Vfechaultmov = '';*/
				END IF;
			END IF;
		END IF;
		
		SELECT NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0) 
			,NVL(sdo_capital,0)
			,NVL(monto_vencido,0)
			,NVL(cap_tras_no_venci,0)
			,NVL(mto_venc_trasp,0)
			,NVL(sdo_intereses,0) + NVL(sdo_no_exig,0)
			,NVL(int_tra_no_exig,0)
		INTO Vsaldovencido
			,VsaldoCapital
			,VsaldoTrasp
			,VvenciNoExig
			,VvenciExig
			,VintVigente
			,VintVencido
		FROM sd_maesdoscrd 
		WHERE empresa = '001'
		  AND num_credito = Vnumcreditortc;
		
		SELECT NVL(capital_mto_cuota,0)
		INTO Vabonobase
		FROM bdicred:sd_amortiza_creditocrd 
		WHERE num_credito = Vnumcreditortc
		  AND fecha_cuota = (SELECT MAX(fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = Vnumcreditortc);
		
		IF (Vabonobase = '') THEN 
			LET Vabonobase = 0; 
		END IF;
		
		SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
				   NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
		INTO Vinteresvencido,
			  vinteres_moratorio
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = '001'
			AND num_credito = Vnumcreditortc
			AND capital_status IN ('2','7','6')
			AND fecha_cuota = (SELECT MAX(fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = Vnumcreditortc);

		IF Vppyrnumcreditortc = '-1' THEN
			INSERT INTO sd_pagosydisposicionescrd_carteras  
				(num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad,
				fechareestructura, saldoactual, interes, saldovencido, interesvencido, interes_moratorio,
				abonobase, abonosvencidos, estadocredito, plazortc, tasainteres,
				fechalimitedepago, fechaultmov, tipoultimomov, fechacorte,
				sdo_cap_vigente, sdo_cap_trasp_vigente, sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido)
			VALUES
				(Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc, Vnumtarjetatdc, Vnumcte, Vnumsucursal, Vnumciudad,
				Vfechareestructura, Vsaldoactual, Vinteres, Vsaldovencido, Vinteresvencido, vinteres_moratorio,
				Vabonobase, Vabonosvencidos, Vestadocredito, Vplazortc, Vtasainteres,
				Vfechalimitedepago, Vfechaultmov, Vtipoultimomov, Vfechacorte,
				VsaldoCapital, VsaldoTrasp, VvenciNoExig, VvenciExig, VintVigente, VintVencido);
			
			LET iCuentasInsertadas = iCuentasInsertadas + 1;
		ELSE
			UPDATE bdicred:sd_pagosydisposicionescrd_carteras 
				SET
					numcreditotdc	= Vnumcreditotdc,
					numcuentartc	= Vnumcuentartc,
					numtarjetatdc	= Vnumtarjetatdc ,
					numcte			=	Vnumcte ,
				--	numsucursal		=	Vnumsucursal,
					numciudad		= Vnumciudad,
					fechareestructura	= Vfechareestructura , 
					saldoactual		= Vsaldoactual  ,
					interes			= Vinteres   ,
					saldovencido	= Vsaldovencido ,
					interesvencido	= Vinteresvencido,
					interes_moratorio	= vinteres_moratorio,
					abonobase		= Vabonobase ,
					abonosvencidos	= Vabonosvencidos ,
					estadocredito	= Vestadocredito ,
					plazortc		= Vplazortc ,
					tasainteres		= Vtasainteres ,
					fechalimitedepago	= Vfechalimitedepago,
					fechaultmov		= Vfechaultmov,
					tipoultimomov	= Vtipoultimomov, 
					fechacorte		= Vfechacorte, 
					sdo_cap_vigente	= VsaldoCapital, 
					sdo_cap_trasp_vigente	= VsaldoTrasp,
					 sdo_cap_noexig_vencido	= VvenciNoExig, 
					 sdo_cap_exig_vencido	= VvenciExig, 
					 sdo_int_vigente		= VintVigente, 
					 sdo_int_vencido		= VintVencido
				WHERE numcreditortc = Vnumcreditortc;
				LET iCuentasActualizadas	= iCuentasActualizadas + 1;
		END IF;
		
		LET	Vnumcreditortc		= '';	LET Vnumcreditotdc		= '';	LET Vnumcuentartc		= '';
		LET	Vnumtarjetatdc		= '';	LET	Vnumcte           	= '';	LET	Vnumsucursal		= 0;
		LET	Vnumciudad	        = '';	LET Vfechareestructura	= DATE(1);	LET Vsaldoactual	= 0;	LET Vinteres        = 0;
		LET Vsaldovencido       = 0;	LET Vinteresvencido     = 0;	LET Vabonobase          = 0;	LET Vabonosvencidos	= 0;
		LET vinteres_moratorio	= 0;	LET Vestadocredito      = 0;	LET Vplazortc      		= 0;	LET Vtasainteres   	= 0;
		LET Vfechalimitedepago  = DATE(1);	LET	Vfechaultmov    = DATE(1);	LET Vtipoultimomov  = '';
		LET vmontor1			= 0;	LET vmontor2			= 0;
		
		LET VsaldoCapital		= 0;	LET VsaldoTrasp			= 0;	LET VvenciNoExig		= 0;	LET VvenciExig		= 0;
		LET VintVigente			= 0;	LET VintVencido			= 0;	LET dFechaInicio		= DATE(1);

		LET Vppyrnumcreditortc	= '';	LET Vppyrestadocredito	= ''; LET vfecha_apertura		= DATE(1);
		LET Vppyrtipoultimomov	= '';	LET Vppyrfechaultmov	= DATE(1);	LET dfechaultpago	= DATE(1);

	END FOREACH

    let cMensajeBitacora = 'TOTAL Cuentas procesadas : ' || iTotalCuentasProcesadas;
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensajeBitacora, '02') returning cCod_ret2;
    let cMensajeBitacora = 'Cuentas insertadas: ' || iCuentasInsertadas;
    let cMensajeBitacora = trim(cMensajeBitacora) ||'    Cuentas actualizadas: ' || iCuentasActualizadas;
--    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensajeBitacora, '02') returning cCod_ret2;

--	if (day(pfechacorte) in(3,18,21)) then --CREAR  ARCHIVO
	if (day(pfechacorte) in (3,18)) then --CREAR  ARCHIVO
		 
             LET cSql = '';
             --LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''  ||
			 LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/cart_reest_prest_temp.unl''' || ' DELIMITER ' || '''|'''  || 
--                ' select * from sd_pagosydisposicionescrd_carteras;'||
				' select num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad, fechareestructura, '||
				' saldoactual, interes, saldovencido, interesvencido, interes_moratorio, abonobase, abonosvencidos, estadocredito, plazortc, tasainteres, '||
				' fechalimitedepago, fechaultmov, tipoultimomov, '|| ''''|| Vfechacorte || ''''||', sdo_cap_vigente, sdo_cap_trasp_vigente, '||
				' sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido '||
                ' from sd_pagosydisposicionescrd_carteras where num_producto = "6011";'||
                ' " > /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              --LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
			  LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/cart_reest_prest_temp.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';
              --LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
			  LET cSql = "rm /resplogifx/archivoscartera/cart_reest_prest_temp.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
              SYSTEM cSql;
	
		 -- para Generar el archvio de Cifras.
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte  FROM bdicred:sd_pagosydisposicionescrd_carteras group by fechacorte ' ||
                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), '|| ''''|| Vfechacorte || ''''||'  FROM bdicred:sd_pagosydisposicionescrd_carteras WHERE num_producto = "6011" ' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
              SYSTEM cSql;

	elif (day(pfechacorte) in (21)) then --CREAR  ARCHIVO
             LET cSql = '';
             --LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''  ||
			 LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/cart_reest_prest_temp.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' select * from sd_pagosydisposicionescrd_carteras;'||
				' select num_producto, numcreditortc, numcreditotdc, numcuentartc, numtarjetatdc, numcte, numsucursal, numciudad, fechareestructura, '||
				' saldoactual, interes, saldovencido, interesvencido, interes_moratorio, abonobase, abonosvencidos, estadocredito, plazortc, tasainteres, '||
				' fechalimitedepago, fechaultmov, tipoultimomov, '|| ''''|| Vfechacorte || ''''||', sdo_cap_vigente, sdo_cap_trasp_vigente, '||
				' sdo_cap_noexig_vencido, sdo_cap_exig_vencido, sdo_int_vigente, sdo_int_vencido '||
                ' from sd_pagosydisposicionescrd_carteras where num_producto in ("6300","7600","7700");'||
                ' " > /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql';
              SYSTEM cSql;

              LET cSql = '';
              --LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
			  LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/cart_reest_prest_temp.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';
              --LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
			  LET cSql = "rm /resplogifx/archivoscartera/cart_reest_prest_temp.unl /resplogifx/archivoscartera/Pagosydisposiciones2crdClon.sql";
              SYSTEM cSql;
	
	
		 -- para Generar el archvio de Cifras.
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
--                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte  FROM bdicred:sd_pagosydisposicionescrd_carteras group by fechacorte ' ||
                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), '|| ''''|| Vfechacorte || ''''||'  FROM bdicred:sd_pagosydisposicionescrd_carteras WHERE num_producto in ("6300","7600","7700")' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
              SYSTEM cSql;
	end if;

	if (day(pfechacorte) in(3,18,21)) then
		LET cSql = '';
		LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo2);
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "rm /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl /resplogifx/archivoscartera/DirectorioCifrasControlQuerysClon.sql";
		SYSTEM cSql;
				  
		LET cSql = '';
		LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' /resplogifx/archivoscartera/" || trim(cNombreArchivo) || " > /resplogifx/archivoscartera/" || trim(cNombreArchivoNvo);
		SYSTEM cSql;
		
        LET cSql = '';
        LET cSql = "gzip /resplogifx/archivoscartera/" || trim(cNombreArchivo);
        SYSTEM cSql;

        LET cSql = '';
        LET cSql = "gzip /resplogifx/archivoscartera/" || trim(cNombreArchivoNvo);
        SYSTEM cSql;
	end if;
		
--	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;

	let cMensaje = trim(cMensaje) || ' TOTAL Cuentas procesadas: '|| iTotalCuentasProcesadas;
	
	RETURN cCod_ret,cMensaje;

	
END;
END PROCEDURE;