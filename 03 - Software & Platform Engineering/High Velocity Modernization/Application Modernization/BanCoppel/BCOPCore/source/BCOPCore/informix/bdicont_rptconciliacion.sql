CREATE PROCEDURE "informix".rptconciliacion(pv_empresa	CHAR(3),pd_fechaRep date ,pv_currentusr VARCHAR(10))
   RETURNING INTEGER, VARCHAR(10);
	DEFINE ln_err INTEGER;
	DEFINE lv_paso VARCHAR(10);
	--Variables de actualizacion de datos
	DEFINE ld_fecha_proceso date;
  DEFINE lv_sistema   char(2);
  DEFINE lv_empresa char(3);
  DEFINE lv_ccmayor char(10);
  DEFINE lv_ccsub char(10);
  DEFINE lv_ccsubsub char(10);
  DEFINE lv_ccssubsub char(10);
  DEFINE lv_ccsssubsub char(10);
  DEFINE lv_sector char(10);
  DEFINE lv_cta_Cliente  char(11);
  DEFINE lv_ciudad char(3);
  DEFINE lv_folio  char(16);
  DEFINE lv_sucursal  char(04);
  DEFINE ln_debitos money(18,2);
  DEFINE ln_creditos money(18,2);
  DEFINE ln_debitos_suc money(18,2);
  DEFINE ln_creditos_suc money(18,2);
  DEFINE lv_descripcion_det char(80);
  DEFINE lv_ccosto_dest char(4);
  DEFINE lv_moneda char(2);
  DEFINE ln_nDebitos INTEGER;
  DEFINE ln_nCreditos INTEGER;
  DEFINE ln_nDebitos_suc INTEGER;
  DEFINE ln_nCreditos_suc INTEGER;
  DEFINE ln_nDiferencia money(18,2);
  DEFINE ln_nDiferencia_suc money(18,2);
  DEFINE lv_nOrigen	CHAR(1);   -- 1. sUCURSALES, 2. CENTRALES
  DEFINE ld_fechaSis 	DATE;
   ON EXCEPTION
    SET ln_err
      RETURN ln_err, lv_paso;
   END EXCEPTION;

	LET ln_err = 0;
	LET lv_paso = 'Paso 0' ;
--SET DEBUG FILE TO "/tmp/con.out";
--TRACE ON;
  
  	truncate co_audconresum;
  	truncate co_auditerr_cint;
  
	--Transferencia de polizas de usuario

	SELECT fecha_hoy
	INTO  ld_fechaSis
	FROM bdicont:co_fechas
	WHERE empresa = pv_empresa;

	IF MONTH(ld_fechaSis) = MONTH(pd_fechaRep) AND YEAR(ld_fechaSis) = YEAR(pd_fechaRep) THEN
	LET lv_paso = 'Paso 1';
  		INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos,creditos,descripcion_det,
			  ccosto_dest,moneda,nDebitos,nCreditos, nDiferencia,
			  nOrigen,currentuser)
  	select
  		fecha_valida,
  		decode( upper(trim(usuario)),
  		upper('chqinfor'),'01',
  		upper('invinfor'),'03',
  		upper('credito'),'06',
  		upper('spei'),'01',
  			'07') sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'2',pv_currentusr
  		 from co_mensual
  		 WHERE upper(trim(usuario)) in (upper('chqinfor'),upper('credito'))
  		 AND fecha_captura >= pd_fechaRep
         AND substr(ccmayor,1,2) = '95'
         AND empresa = pv_empresa
		 AND fecha_valida = pd_fechaRep;

  		  --Transferencia de datos de tabla de paso
  		LET lv_paso = 'Paso 2';
			LET pd_fechaRep = pd_fechaRep;
			LET pv_empresa = pv_empresa;

			  INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos_suc,creditos_suc,descripcion_det,
			  ccosto_dest,moneda,nDebitos_suc,nCreditos_suc, nDiferencia_suc,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  			(select sistema
  			from tbEnlaceSis ten
  			where
  			ten.ccmayor       = cod.ccmayor
  			and ten.ccsub         = cod.ccsub
  			and ten.ccsubsub      = cod.ccsubsub
  			and ten.ccssubsub     = cod.ccssubsub
  			and ten.ccsssubsub    = cod.ccsssubsub
  			and ten.sector        = cod.sector) sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
			sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'1',pv_currentusr
  		 from co_mensual cod
  		 WHERE length(trim(usuario)) = 4
  		 AND fecha_captura >= pd_fechaRep
         AND substr(ccmayor,1,2) = '95'
         AND empresa = pv_empresa
		 AND fecha_valida = pd_fechaRep;

	ELSE

			LET lv_paso = 'Paso 3';
  		INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos,creditos,descripcion_det,
			  ccosto_dest,moneda,nDebitos,nCreditos, nDiferencia,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  		decode( upper(trim(usuario)),
  		upper('chqinfor'),'01',
  		upper('invinfor'),'03',
  		upper('credito'),'06',
  		upper('spei'),'01',
  		'07') sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'2',pv_currentusr
  		from co_historico
  		WHERE upper(trim(usuario)) in (upper('chqinfor'),upper('credito'))
        AND control_poliza IS NOT NULL
  		AND fecha_captura >= pd_fechaRep
        AND secuencia > 0
        AND empresa = pv_empresa
        AND ccmayor  like '95%'
        AND ccsub IS NOT NULL
        AND ccsubsub IS NOT NULL
        AND ccssubsub IS NOT NULL
        AND ccsssubsub IS NOT NULL
        AND sector IS NOT NULL
        AND ciudad IS NOT NULL
        AND sucursal IS NOT NULL
        AND nro_auxiliar IS NOT NULL
		AND fecha_valida = pd_fechaRep
        AND moneda IS NOT NULL ;

  		  --Transferencia de datos de tabla de paso
  		LET lv_paso = 'Paso 4';
			LET pd_fechaRep = pd_fechaRep;
			LET pv_empresa = pv_empresa;

			  INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos_suc,creditos_suc,descripcion_det,
			  ccosto_dest,moneda,nDebitos_suc,nCreditos_suc, nDiferencia_suc,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  			(select sistema
  			from tbEnlaceSis ten
  			where
  			ten.ccmayor       = cod.ccmayor
  			and ten.ccsub         = cod.ccsub
  			and ten.ccsubsub      = cod.ccsubsub
  			and ten.ccssubsub     = cod.ccssubsub
  			and ten.ccsssubsub    = cod.ccsssubsub
  			and ten.sector        = cod.sector) sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'1',pv_currentusr
  		from co_historico cod
  		WHERE length(trim(usuario)) = 4
        AND control_poliza IS NOT NULL
  		AND fecha_captura >= pd_fechaRep
        AND secuencia > 0
        AND empresa = pv_empresa
        AND ccmayor  like '95%'
        AND ccsub IS NOT NULL
        AND ccsubsub IS NOT NULL
        AND ccssubsub IS NOT NULL
        AND ccsssubsub IS NOT NULL
        AND sector IS NOT NULL
        AND ciudad IS NOT NULL
        AND sucursal IS NOT NULL
        AND nro_auxiliar IS NOT NULL
		AND fecha_valida = pd_fechaRep
        AND moneda IS NOT NULL ;
	END IF;

	DELETE FROM co_auditerr_cint WHERE ccmayor ='9512' AND ccsub NOT IN ('01','04','07','10');
    DELETE FROM co_auditerr_cint WHERE ccmayor ='9513' AND ccsub NOT IN ('10','11') ;
	DELETE FROM co_auditerr_cint WHERE ccmayor NOT IN ('9512','9513');

    DELETE FROM bdicont:co_auditerr_cint 
		  WHERE sucursal NOT IN (SELECT sucursal FROM bdinteg:si_sucursales 
						  				        WHERE tpo_sucursal='S' 
												  AND pais='001' 
												  AND estado!='0'
												  AND ciudad!='0');

	  LET lv_paso = 'Paso 5' ;
    insert into co_audconresum
    (fecha_proceso,sistema,empresa,ccmayor,cta_Cliente,ciudad,folio,
    sucursal,descripcion_det, moneda,nDiferencia,nDiferencia_suc,currentuser)
    select a.fecha_proceso,a.sistema,a.empresa,TRIM(a.ccmayor)||' '||TRIM(a.ccsub)||' '||TRIM(a.ccsubsub)||' '||
    TRIM(a.ccssubsub)||' '||TRIM(a.ccsssubsub)||' '||TRIM(a.sector) cuenta,a.cta_Cliente,' ',a.folio,
    a.sucursal,b.nombre,a.moneda,sum(nvl(a.creditos,0) - nvl(a.debitos,0)),sum(nvl(a.debitos_suc,0) - nvl(a.creditos_suc,0)),a.currentuser
    from co_auditerr_cint a, bdinteg:si_catalog b
    where currentuser = pv_currentusr
    AND a.empresa       = pv_empresa
    AND a.ccmayor       = b.ccmayor
  	and a.ccsub         = b.ccsub
  	and a.ccsubsub      = b.ccsubsub
  	and a.ccssubsub     = b.ccssubsub
  	and a.ccsssubsub    = b.ccsssubsub
  	and a.sector        = b.sector
    group by 1,2,3,4,5,7,8,9,10,13;

    DELETE
    FROM co_audconresum
    WHERE nDiferencia = nDiferencia_suc
    or sistema is null
    or sistema = '';

    --order by cuenta;
	  LET lv_paso = 'Paso 6' ;
--trace off;
   RETURN ln_err, lv_paso;
END PROCEDURE;