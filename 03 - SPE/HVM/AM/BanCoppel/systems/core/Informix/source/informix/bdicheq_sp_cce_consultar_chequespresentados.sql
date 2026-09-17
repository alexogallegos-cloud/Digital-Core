CREATE PROCEDURE "informix".sp_cce_consultar_chequespresentados
(
pEmpresa    CHAR(3),
pFecha      CHAR(8),
pNomArchivo CHAR(22)
)
RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(3) 		AS banco,
	CHAR(40) 		AS nom_banco,
	CHAR(40) 		AS referencia,
	INTEGER 		AS num_cheque,
	DECIMAL(14,2) 	AS monto_orig,
	CHAR(20) 		AS cuenta,
	CHAR(44) 		AS sucursal,
	CHAR(4) 		AS transacc
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	
	DEFINE cBanco			CHAR(3);
	DEFINE cNomBanco		CHAR(40);
	DEFINE cReferencia		CHAR(40);
	DEFINE iNumCheque		INTEGER;
	DEFINE dMontoOrig		DECIMAL(14,2);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(44);
	DEFINE cTransacc		CHAR(4);



	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo			= "";
	LET cCodRet             = "000000";
	
	LET cBanco				= "";
	LET cNomBanco			= "";
	LET cReferencia			= "";
	LET iNumCheque			= 0;
	LET dMontoOrig			= 0.0;
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET cTransacc			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequespresentados.out';
--	TRACE ON;



	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR NVL(pNomArchivo,"") = "" THEN
        -- FALTAN UNO O MAS PARAMETROS
        LET cCodRet = "000001";
		RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
	ELSE
        FOREACH WITH HOLD
			SELECT ba.banco, ba.descripcion, doc.referencia, doc.num_chq, doc.monto_ori, doc.cuenta, suc.sucursal || " " || suc.nombre,doc.transacc  
			INTO cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc
			FROM bdicheq:sc_docret_sbc doc, 
                 bdinteg:si_bancos ba, 
                 bdinteg:si_sucursales suc, 
                 bditef:cce_detalle cce
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco  
			AND doc.sucursal = suc.sucursal  
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban)  
			AND doc.cancelado = "T"
			AND doc.banco = cce.bco_receptor
			AND doc.numcuenta::INT8 = cce.num_cuenta::INT8
			AND doc.num_chq = cce.num_cheque::INTEGER
            AND doc.cuenta = cce.cuenta_dep
			AND cce.fecha_transfer = pFecha  
			AND cce.cod_operacion = "40"
			AND cce.nombrearchivo= pNomArchivo
		
            RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta los cheques presentados a la cámara de compensación eletrónica',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_eliminar_cheques
(
pEmpresa	CHAR(3),
pCtaDep		CHAR(20),
pCveBanco	CHAR(3),
pNumCheque	INTEGER,
pMonto		DECIMAL(14,2)
)
		  

RETURNING
	CHAR(6) 		AS cod_ret
	

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
	LET cCodRet				= "000000";
	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_eliminar_cheques.out';
	--TRACE ON;
	
	IF NVL(pEmpresa,"") = "" OR NVL(pCtaDep,"") = "" OR NVL(pCveBanco,"") = "" OR NVL(pNumCheque,0) = 0 OR NVL(pMonto,0.0) = 0.0 THEN
        -- FALTAN LA EMPRESA O LA FECHA
        LET cCodRet = "000001";
	ELSE
		-- ACTUALIZA LA TABLA DE CHEQUES SBC A CANCELADO
		UPDATE bdicheq:"informix".sc_docret_sbc
		SET cancelado = "S"
		WHERE cuenta = pCtaDep
		AND banco = pCveBanco
		AND num_chq = pNumCheque
		AND monto_ori = pMonto;
			  
		-- ACTUALIZA EL IMPORTE DE CHEQUES SBC DEL MAESTRO DE CHEQUES 
		UPDATE bdicheq:"informix".sc_maechq
		SET imp_chq_sbc = imp_chq_sbc - pMonto
		WHERE empresa = pEmpresa 
		AND cuenta = pCtaDep;

	END IF
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques del código 40', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_arch_cartera_pyr_pba()
RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--21-03-2012
--Proceso para la generación de archivo cartera reestructura y prestamo personal saldos e intereses

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
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
define sPaso				integer;
define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);

-- SET DEBUG FILE TO "pagosydisposicionescrd.out";
-- TRACE ON; 

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cSQL                    = "";
LET cCod_RetIB              = "000000";
let vproceso				='2069';
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

--LET cNombreArchivo1= 'DirectorioCtesBancoppel' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
--LET cNombreArchivo ='cartera_reestructura_prestamo' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
        

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
	
	select fecha_hoy, fecha_hoy - 1 units day --fecha_ant, pri_dia_mes 
	into pfechacorte,Vult_dia_mes -- ,Vpri_dia_mes 
	from bdicred:sd_fechas where empresa = '001';
--let pfechacorte = '01-18-2012';
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_pagosydisposicionescrd_cartera';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_pagosydisposicionescrd_cartera;
            END IF;


    create table sd_pagosydisposicionescrd_cartera
    (
	num_producto	char(4),
    numcreditortc	char(20),
    numcreditotdc	char(20),
    numcuentartc	char(20),
	numtarjetatdc   char(20),
	numcte          char(20),
	numsucursal     char(4),
	numciudad		char(4),
    fechareestructura   date,
    saldoactual     decimal(18,2),
    interes       	decimal(18,2),
    saldovencido    decimal(18,2),
    interesvencido  decimal(18,2),
	interes_moratorio	decimal(18,2),
    abonobase           decimal(18,2),
    abonosvencidos      smallint,
    estadocredito       char(2),
    plazortc    		smallint,
    tasainteres    		decimal(18,2),
    fechalimitedepago 	date,
	fechaultmov 		date,
    tipoultimomov		char(2),
    fechacorte          date);
	
	
	if (day(pfechacorte) in(3,18)) then
		let Vprod = '6011'; 	end if;
	if (day(pfechacorte) = 21 ) then
		let Vprod = '6300'; 	end if;
	let Vfechacorte = pfechacorte - 1 units day;
	
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(Vfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(Vfechacorte,'%d%m%Y')||'.txt';
  
	FOREACH
	
	select  nvl(a.num_producto,0),nvl(a.num_credito,0),nvl(a.credito_externo,0),nvl(cta.num_cta,0),nvl(tar.num_tarjeta,0), nvl(a.numcte,0),nvl(a.sucursal,0),nvl(s.ciudad,0),a.fecha_apertura,
			nvl(b.sdo_capital,0) + nvl(b.monto_vencido,0) + nvl(b.mto_venc_trasp,0) + nvl(b.cap_tras_no_venci,0)
			,nvl(b.mto_fin_ven_trasp,0),nvl(a.status_cred,''),nvl(a.plazo,0),nvl(a.tasa_interes,0) ,nvl(c.prox_fecha_pago,'01/01/1900')
			,c.fecha_ult_pago--,today--,(b.sdo_exig_int + b.mto_venc_tra_int)
	INTO 	Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc,Vnumtarjetatdc ,Vnumcte,	Vnumsucursal,Vnumciudad, Vfechareestructura ,     
			Vsaldoactual,Vabonosvencidos ,Vestadocredito ,Vplazortc,Vtasainteres,Vfechalimitedepago,
			Vfechaultmov--,   Vfechacorte -- ,Vinteresvencido
	FROM bdicred:sd_maecredcrd a
		left join bdicred:sd_maesdoscrd b on (a.empresa = b.empresa and a.num_credito = b.num_credito)
		left join bdicred:sd_ctascarg cta on(a.num_credito = cta.num_credito and cta.naturaleza = 'A')
		left join bdicred:sd_tarjeta tar on (a.empresa = tar.empresa and a.credito_externo = tar.num_credito and tar.tipo_tarjeta ='T' and tar.secuencia = (select max(tar2.secuencia)
			 			from bdicred:sd_tarjeta tar2
			 			where tar2.empresa = '001' 
						and tar2.num_credito = a.credito_externo
						and tar2.tipo_tarjeta ='T' ))
		left join bdinteg:si_sucursales s on (a.empresa = s.empresa and a.sucursal = s.sucursal)
		left join bdicred:sd_maecredanexocrd c on(a.empresa = c.empresa and a.num_credito = c.num_credito)
	where a.empresa ='001'
		and a.num_producto = Vprod
	
	-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
	IF (Vprod = '6300') THEN
		if exists(select num_credito 
			from bdicred:sd_movhiscrd 
			where empresa = '001'
			and num_credito = Vnumcreditortc
			and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028')
			and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
			AND num_producto = '6300' )then 
	
			LET Vtipoultimomov = 'P';
		elif
		exists(select num_credito 
			from bdicred:sd_movhiscrd 
			where empresa = '001'
			and num_credito = Vnumcreditortc
			and codigo_ref = 3 and codigo_fun  = '001'
			and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 3 and codigo_fun  = '001' and num_credito = Vnumcreditortc)
			AND num_producto = '6300') then
	
			LET Vtipoultimomov = 'A';
			LET Vfechaultmov = Vfechareestructura;
		elif
		exists(select num_credito 
			from bdicred:sd_movhiscrd 
			where empresa = '001'
			and num_credito = Vnumcreditortc
			and codigo_ref = 66 and codigo_fun  ='002'
			and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
			AND num_producto = '6300') then
			
			select LIMIT 1 fecha_mov into  Vfechaultmov
			from bdicred:sd_movhiscrd 
			where empresa = '001'	and num_credito = Vnumcreditortc	and codigo_ref = 66 and codigo_fun  ='002'
			and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref = 66 and codigo_fun  ='002' and num_credito = Vnumcreditortc)
			AND num_producto = '6300';
	
			LET Vtipoultimomov = 'D';
			LET Vfechaultmov = Vfechaultmov;
		end if;
	end if;			
	IF (Vprod = '6011') THEN
	
	--obtienes el interes vencido cargado a la reestruc   --intereses moratorios
		select limit 1 nvl(monto,0) into vmontor1
		FROM bdicred:sd_movhis 
		where empresa = '001' and num_credito = Vnumcreditortc 
		and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N'
		and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 21 and reversado = 'N');
	
		select limit 1 nvl(monto,0) into vmontor2
		FROM bdicred:sd_movhis 
		where empresa = '001' and num_credito = Vnumcreditortc 
		and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'
		and fecha_mov = (select max(fecha_mov) from bdicred:sd_movhis  where num_credito = Vnumcreditortc and codigo_fun = '338' and codigo_ref = 22 and reversado = 'N'); 
		
		let Vinteres = vmontor1 + vmontor2;
		if   Vinteres is null then let Vinteres = 0; end if;
		
		if exists(select num_credito 
			from bdicred:sd_movhiscrd 
			where empresa = '001'
			and num_credito = Vnumcreditortc
			and codigo_fun in ('225','222')	and codigo_ref = 1
			and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
			AND num_producto = '6011') then
	
			LET Vtipoultimomov = 'P';
		elif
		exists(select num_credito 
			from bdicred:sd_movhiscrd 
			where empresa = '001'
			and num_credito = Vnumcreditortc
			and codigo_ref in(1,2) and codigo_fun  in ('001','002')
			and fecha_mov = (select max(fecha_mov)from bdicred:sd_movhiscrd where codigo_ref in(1,2) and codigo_fun  in ('001','002') and num_credito = Vnumcreditortc)
			AND num_producto = '6011') then
	
			LET Vtipoultimomov = 'A';
			LET Vfechaultmov = Vfechareestructura;
		elif
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
			
			LET Vtipoultimomov = 'L';
			LET Vfechaultmov = Vfechaultmov;
		end if;
	end if;
	
	select NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0) 
		into Vsaldovencido
	from sd_maesdoscrd 
	where empresa = '001'
		and num_credito = Vnumcreditortc;
	
	select nvl(capital_mto_cuota,0)
	into Vabonobase
	from bdicred:sd_amortiza_creditocrd 
	where num_credito = Vnumcreditortc
		and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);
	
	if (Vabonobase = '') then 
		LET Vabonobase = 0; 
	end if;
	
	SELECT nvl(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
		       nvl(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
	INTO Vinteresvencido,
		  vinteres_moratorio
	FROM "informix".sd_amortiza_creditocrd
	WHERE empresa     = '001'
		AND num_credito = Vnumcreditortc
		AND capital_status IN ('2','7')
		AND fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);
	
	INSERT INTO sd_pagosydisposicionescrd_cartera  VALUES
	(Vprod,Vnumcreditortc, Vnumcreditotdc, Vnumcuentartc,	Vnumtarjetatdc ,Vnumcte ,Vnumsucursal,Vnumciudad, 
	Vfechareestructura ,Vsaldoactual  ,Vinteres   ,Vsaldovencido ,Vinteresvencido,vinteres_moratorio,
	Vabonobase ,Vabonosvencidos ,Vestadocredito , Vplazortc ,Vtasainteres , 	
	Vfechalimitedepago, Vfechaultmov ,Vtipoultimomov, Vfechacorte );
	
		LET	Vnumcreditortc			= '';LET Vnumcreditotdc			= '';LET Vnumcuentartc			= '';
	LET	Vnumtarjetatdc			= '';LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0;
	LET	Vnumciudad	            = '';LET Vfechareestructura		= DATE(1);LET Vsaldoactual			= 0;LET Vinteres                = 0;
	LET Vsaldovencido           = 0;LET Vinteresvencido         = 0;LET Vabonobase              = 0;LET Vabonosvencidos         = 0;
	LET vinteres_moratorio		= 0;LET Vestadocredito          = 0;LET Vplazortc      			= 0;LET Vtasainteres   		    = 0;
	LET Vfechalimitedepago      = DATE(1);LET	Vfechaultmov            = DATE(1);LET Vtipoultimomov          = '';
	let vmontor1				= 0;let vmontor2				= 0;
				
	END FOREACH

	if (day(pfechacorte) in(3,18,21)) then --CREAR  ARCHIVO
	
		 
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''  ||
                ' select * from sd_pagosydisposicionescrd_cartera;'||
                ' " > /resplogifx/archivoscartera/Pagosydisposiciones2crd.sql';

              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2crd.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';
              LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2crd.sql";
              SYSTEM cSql;
	
	
		 -- para Generar el archvio de Cifras.
             LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                ' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte  FROM bdicred:sd_pagosydisposicionescrd_cartera group by fechacorte ' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql';

              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo2);
              SYSTEM cSql;

              let cSql = '';
              LET cSql = "rm /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql";
              SYSTEM cSql;

	end if;

	
	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');

	RETURN cCod_ret;

	
END;
END PROCEDURE;