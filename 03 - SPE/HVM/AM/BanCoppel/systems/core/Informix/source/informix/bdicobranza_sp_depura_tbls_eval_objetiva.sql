CREATE PROCEDURE "informix".sp_depura_tbls_eval_objetiva(pTipoEjec char(1), pFechaIni date, pFechaFin date)

RETURNING CHAR(6), char(80);
  -- vers 1.0.0 20190901
  DEFINE vcCodRet CHAR(5);
  DEFINE viSqlErr INTEGER;
  define vDataErr	      varchar(64);
  DEFINE vcEsTransaccion  CHAR(1);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(120);
  define vEmpresa         char(3);
  define vFechahoy        date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dtHora_insert    DATETIME HOUR to FRACTION(3);
  define dtFecha_convenio date;
  define cSucursal_pago   char(4);
  define cSucursal_pago_2 char(4);
  define vNum_credito_2   char(20);
  define iNum_pm_realizados    integer;
  define iNum_pm_no_realizados integer;
  define cCalificacion         char(1);
  define dTotal_importe        decimal(18,2);
  define dImp_pagado_acum      decimal(18,2); 
  define dFecha_vencim    date;
  
  define vPlazo           char(2);
  define iCteAsisteSuc    integer;
  define cOrigen          char(10);
  define pSucursalOrig    char(4);
  define psucursal        char(4);
  define pfechasistema    date;
  define pefectuo_compac  integer;
  define pnombre_efectuo  char(40);
  define pnumcuenta       char(20);
  define pnumproducto		char(4); 
  define pplazo           char(2);
  define porigen	        smallint;
  define ptipo_compac     char(1);
  define pimporte         decimal(18,2);
  define dImp_pagado      decimal(18,2);
  define cUsuario_pago    char(8);
  define cNomUsuario_pago char(45);
  
  define dtFecha_hoy      date;
  define dt_pri_dia_mes   date;
  define dt_ult_dia_mes   date;  
  define dtFecha_ini      date;
  define dtFecha_fin      date;
  define dtFecha_insert   date;
  define iNumConvenios    integer;
  define cReinicio		  char(1);
  define cMensajeRet	  char(80);
  define iCuentasEliminadas     integer; 
  define iCuentasIns_crd        integer;
  define iCuentasEliminadas_crd integer;
  define dMonto_pagomin         decimal(18,2);
  define dMonto_recup_pm        decimal(18,2); 
  define dMonto_saldo_vencido   decimal(18,2); 
  define dMonto_recup_sv        decimal(18,2);
  define iNum_sv_realizados     integer;
  define iNum_sv_no_realizados  integer;
  define iCuentasIns_evalobj_nvahis  integer;
  define iCuentasIns_evalobj_crd     integer;
  define iCuentasEliminadas_evalobj_nvahis integer;
  define iCuentasEliminadas_evalobj_crd    integer;
  define cTipoEjec      char(1);
  
  define dPct_cump_pm     decimal(8,2);   
  define dPct_cump_sv     decimal(8,2);
  define cEfectuo_compac  char(8);
  
  define dFecha_ctetit    date;    -- Para depurar cb_cob_vent_cliente_titular
  define cSucursal_ctetit char(4);
  define cEmpleado_ctetit char(8);
  define iCont_si         integer;
  define iCont_no         integer;
  
  define dtFecha_ini_mes_ant      date;
  define dtFecha_fin_mes_ant      date;
  define iCuentasIns_ctetit        integer; 
  define iCuentasEliminadas_ctetit integer;
  define iCuentasEliminadas_ctetit_his integer;
  define iRegsABorrar    integer;
  define dtFecha_ini_mes_ant_2m      date;
  define dtFecha_fin_mes_ant_2m      date;
  define iCuentasEliminadas_ctetit_operativa integer;
    
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';	  
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let cNumCte           = '';
  let cProceso          = '0088';
  let cCod_ret_2        = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dtHora_insert     = CURRENT;
  let dtFecha_convenio  = date(1);
  let cSucursal_pago    = ''; 
  let cSucursal_pago_2  = '';
  let vNum_credito_2    = '';
  let iNum_pm_realizados = 0;
  let iNum_pm_no_realizados = 0;
  let cCalificacion      = '';
  let dTotal_importe     = 0;

  let iCteAsisteSuc    = 0;
  let cOrigen          = '';
  let pSucursalOrig    = '';
  let psucursal        = ''; 
  let pfechasistema    = date(1); 
  let pefectuo_compac  = 0;
  let pnombre_efectuo  = '';
  let pnumcuenta       = '';
  let pnumproducto     = '';
  let pplazo           = '';
  let porigen          = 0;
  let ptipo_compac     = '';
  let pimporte         = 0;  
  let dImp_pagado      = 0;
  let vPlazo           = '';
  let dImp_pagado_acum = 0;
  
  let vcCodRet  = '00000';
  let viSqlErr  = 0;
  let vDataErr	= '';
  let vcEsTransaccion = '';
  let dFecha_vencim = date(1);
  let cUsuario_pago = '';
  let cNomUsuario_pago = '';
  
  let dtFecha_hoy     = date(1); 
  let dt_pri_dia_mes  = date(1); 
  let dt_ult_dia_mes  = date(1);
  let dtFecha_ini     = date(1);
  let dtFecha_fin     = date(1);
  let dtFecha_insert  = date(1);
  let iNumConvenios   = 0;
  let cReinicio       = '';
  let iCuentasEliminadas = 0;
  let iCuentasIns_crd    = 0;
  let iCuentasEliminadas_crd = 0;
  let dMonto_pagomin     = 0;
  let dMonto_recup_pm    = 0;
  let dMonto_saldo_vencido  = 0; 
  let dMonto_recup_sv       = 0;
  let iNum_sv_realizados    = 0;
  let iNum_sv_no_realizados = 0;
  let iCuentasIns_evalobj_nvahis = 0;
  let iCuentasIns_evalobj_crd = 0;
  let iCuentasEliminadas_evalobj_nvahis = 0;
  let iCuentasEliminadas_evalobj_crd = 0;
  
  let cTipoEjec = pTipoEjec;
  let dPct_cump_pm  = 0;
  let dPct_cump_sv  = 0;
  let cEfectuo_compac = '';

  let dFecha_ctetit    = date(1);   
  let cSucursal_ctetit = ''; 
  let cEmpleado_ctetit = '';
  let iCont_si         = 0; 
  let iCont_no         = 0; 
  
  let dtFecha_ini_mes_ant = date(1);
  let dtFecha_fin_mes_ant = date(1);
  let iCuentasIns_ctetit  = 0;
  let iCuentasEliminadas_ctetit = 0; 
  let iCuentasEliminadas_ctetit_his = 0;
  let iRegsABorrar  = 0;
  let dtFecha_ini_mes_ant_2m = date(1);
  let dtFecha_fin_mes_ant_2m = date(1);
  let iCuentasEliminadas_ctetit_operativa = 0;
  let iCuentasEliminadas_ctetit_his = 0;
  
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = trim(cCodRet) || ' ' || vNum_credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_depura_tbls_eval_objetiva.out";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
    -- Se depurará cada mes lo del meses anterior
    -- correrá al cierre del día 1
	
	if cTipoEjec = 'A' then
	
		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes 
		  INTO dtFecha_hoy, dt_pri_dia_mes, dt_ult_dia_mes
		  FROM bdinteg:si_fechas
		 WHERE empresa = vEmpresa;
	   
         --LET dtFecha_hoy = MDY(11,2,2020);     -- SOLO TEST
		 --LET dt_pri_dia_mes = MDY(11,1,2020);  -- SOLO TEST
		 --LET dt_ult_dia_mes = MDY(11,30,2020); -- SOLO TEST
		 
		 let dtFecha_fin = date(dt_pri_dia_mes -1 units day);
		 let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);
		 		 
         let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		 let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
		 
		 let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		 let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
		 
    elif cTipoEjec = 'M' then
	     if (pFechaIni = '' or pFechaIni = '01/01/1900') or (pFechaFin = '' or pFechaFin = '01/01/1900') then
             LET cCodRet     = "000018";
		     LET cMensajeRet = "Error al obtener las fechas";
		     RETURN cCodRet, cMensajeRet;
	     else
	         let dtFecha_ini = pFechaIni;
             let dtFecha_fin = pFechaFin;
			 
			 let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		     let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
			 
		     let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		     let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
			 
	     end if; 
    end if;	

	--let dtFecha_hoy = mdy(9,2,2019);     -- SOLO TEST
	--let dt_pri_dia_mes = mdy(9,1,2019);   -- SOLO TEST
	--let dtFecha_fin = date(dt_pri_dia_mes -1 units day);              -- SOLO TEST
    --let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);  -- SOLO TEST
	

	
   SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = vEmpresa AND cod_param = 6;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;
   
   IF cReinicio = '0' THEN
	   FOREACH WITH HOLD
		   SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		          a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				  a.fecha_compac, a.fecha_vencim
			 INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			 ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados,
				   cCalificacion, dtFecha_convenio, dFecha_vencim
			 FROM bdicobranza:cb_evaluacion_objetiva_convenios a
			 WHERE a.fecha_vencim between dtFecha_ini and dtFecha_fin
			   AND a.num_credito not in(select num_credito from cb_evaluacion_objetiva_convenios_his 
			                             where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)

	        
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
							   num_producto, plazo,	origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
							   num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																							 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, ptipo_compac, 
					   dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio, dFecha_vencim);
		
		        let iContGral_2 = iContGral_2 + 1;

				DELETE bdicobranza:cb_evaluacion_objetiva_convenios
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas = iCuentasEliminadas +1;
		         
			commit work; 
	   
		END FOREACH   
    
	    IF iContGral_2 > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs: ' || iContGral_2;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica: ' || iContGral_2;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs: ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;     
	
	    let cReinicio = '1';
	    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;

	END IF;
    		
   

    IF cReinicio = '1' THEN
      FOREACH WITH HOLD
		  
		  SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		         a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				 a.fecha_compac, a.fecha_vencim 
            INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			     ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, 
				 dtFecha_convenio, dFecha_vencim
			FROM bdicobranza:cb_evaluacion_objetiva_convenios_crd a
           WHERE fecha_vencim between dtFecha_ini and dtFecha_fin
			 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_convenios_crd_his 
			                          where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)   

		begin work;
			   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
			                                                                num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
																			num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
			                                                          
																	 
			 																 
			   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, pnombre_efectuo,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
			           dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio,dFecha_vencim);
        
				let iCuentasIns_crd = iCuentasIns_crd + 1;
		
				DELETE bdicobranza:cb_evaluacion_objetiva_convenios_crd
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas_crd = iCuentasEliminadas_crd +1;
		
		commit work;
		

 	  END FOREACH   
	  
	  IF iCuentasIns_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs CRD: ' || iCuentasIns_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica CRD: ' || iCuentasIns_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs CRD: ' || iCuentasEliminadas_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	  END IF;     
	
	  let cReinicio = '2';
      UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	  
	END IF;

		
	IF cReinicio = '2' THEN
		FOREACH WITH HOLD
	
			SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			       a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv
			  --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			  INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			  FROM bdicobranza:cb_evaluacion_objetiva_nueva a
			  WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
               AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_nueva_his 
			                             where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
										 
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_nueva_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv)					   

				 --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
				 VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
 			           iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv); 
			
			    let iCuentasIns_evalobj_nvahis = iCuentasIns_evalobj_nvahis + 1;
			
	            DELETE bdicobranza:cb_evaluacion_objetiva_nueva
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;
	            
				let iCuentasEliminadas_evalobj_nvahis = iCuentasEliminadas_evalobj_nvahis + 1;
	
	        commit work;
					
		END FOREACH
		
		IF iCuentasIns_evalobj_nvahis > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Nva: ' || iCuentasIns_evalobj_nvahis;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a Nva histórica: ' || iCuentasIns_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Nva: ' || iCuentasEliminadas_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		

	let cReinicio = '3';
    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	
	END IF;	

	
	IF cReinicio = '3' THEN
		FOREACH WITH HOLD
	
	         SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			        a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv 
               --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			   INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			   FROM bdicobranza:cb_evaluacion_objetiva_crd a
			   WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
                 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_crd_his 
			                               where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
	
	         begin work;
			    INSERT INTO bdicobranza:cb_evaluacion_objetiva_crd_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv) 
	            --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, 
				       dPct_cump_pm, dPct_cump_sv);   
		    
			    let iCuentasIns_evalobj_crd = iCuentasIns_evalobj_crd + 1;
				
  			    DELETE bdicobranza:cb_evaluacion_objetiva_crd
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;

                let iCuentasEliminadas_evalobj_crd = iCuentasEliminadas_evalobj_crd	+ 1;
				
			commit work;
		END FOREACH
		
		IF iCuentasIns_evalobj_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj CRD: ' || iCuentasIns_evalobj_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a CRD histórica: ' || iCuentasIns_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj CRD: ' || iCuentasEliminadas_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		
		let cReinicio = '4';
		UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
	
			
	END IF;	
	
	-- dtFecha_fin = 01/10  dtFecha_ini= 31/10    dtFecha_fin_mes_ant= 30/09   dtFecha_ini_mes_ant= 01/09
	
	IF cReinicio = '4' THEN
        -- Ejem cuando corra en nov, dtFecha_hoy = 02/11, dt_pri_dia_mes= 01/11, dt_ult_dia_mes= 30/11  (bdinteg:si_fechas)
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 
			 BEGIN WORK;
			    INSERT INTO bdicobranza:cb_cob_vent_cliente_titular_his(fecha, sucursal, empleado, cont_si, cont_no) 
	              VALUES(dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no);

				let iCuentasIns_ctetit  = iCuentasIns_ctetit +1;
				
			 COMMIT WORK;
			 
		END FOREACH
		
  		
		let iCuentasEliminadas_ctetit = 0;
		
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular
			 WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_operativa = iCuentasEliminadas_ctetit;
		let iCuentasEliminadas_ctetit = 0;
			
	
		---- HIS
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
			 WHERE fecha between dtFecha_ini_mes_ant_2m and dtFecha_fin_mes_ant_2m
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit;
				
		
		/*
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
		
		    BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				 WHERE fecha = dFecha_ctetit,
				   AND sucursal = cSucursal_ctetit, empleado = cEmpleado_ctetit;
			COMMIT WORK;   
			
			let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit_his +1;
				 
		END FOREACH		
	    */
		
		IF iCuentasIns_ctetit > 0 THEN
		   
		   --LET cMensaje = 'TOTAL Ctas PROCS. Cliente Titular: ' || iCuentasIns_ctetit;
	       LET cMensaje = ' TOTAL Ctas Cte Titular INSERT a histórica: ' || iCuentasIns_ctetit;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular ELIMINADAS: ' || iCuentasEliminadas_ctetit_operativa;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		
		IF iCuentasEliminadas_ctetit_his > 0 THEN
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular His ELIMINADAS: ' || iCuentasEliminadas_ctetit_his;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		let cReinicio = '0';
        UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
		
	END IF;
	
	
	
 --let cContGral = iContGral;
 LET cMensaje = 'PROCESO EXITOSO';
 --LET cMensaje = trim(cMensaje) || '. ' || iContGral || ' UPDs - ' || iContGral_2 || ' Inserts.' ;
 CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE
DOCUMENT
'BD: bdicobranza',
'Ver: 1.0.0', 
'Autor: Marco A. Campos',
'Fecha: 20190901',
'DESCRIPCION: Depuración mensual de tablas de evaluación objetiva',
'Ver: 1.0.1',
'Autor: Marco A. Campos',
'Fecha: 20200802',
'Descripción: Modif para resolver incidencia error -1213 por tipo de dato en var. pefectuo_compac';

CREATE PROCEDURE "informix".sp_mail_primerconsumo()
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte		char(20);
define vnumcredito	char(20);
define vnumtarjeta	char(20);
define vimporte		decimal(18,2);
define vfecha		date;
define vfechas		date;


---DECLARACIONES
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado 		CHAR(20);
DEFINE cNomCiudad 		CHAR(20);
DEFINE iPagoVenc 		INTEGER;
DEFINE vSdoTotal1  		DECIMAL(18,2);
DEFINE vMtoVencido1  	DECIMAL(18,2);
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE vSdoTotal2  		DECIMAL(18,2);
DEFINE vMtoVencido2 	DECIMAL(18,2);
DEFINE vsaldo_total 	DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
define vpago 			DECIMAL(18,2);
DEFINE Vfecha_apertura 	DATE;
DEFINE iCel 			SMALLINT;
DEFINE vdia_pago 		smallint;
DEFINE vmail 			char(100);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
define vregistrostotal	integer;
define vfecha1 			date;
define vfecha2 			date;
define vimporte1		DECIMAL(18,2);
define vimporte2 		DECIMAL(18,2);     

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET     	VARCHAR(6);
DEFINE P_MENSAJE     	VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(150);
DEFINE vpago_vencido	DECIMAL(18,2);
DEFINE vcontador		INTEGER;
define vpri_dia_mes		date;
define vapell_paterno 	char(30);
--define vcount 			INTEGER;
define iCount_TC_PRIMERC INTEGER; --A.L.L.
define iCount_TC_PRIMERS INTEGER; --A.L.L.
	define vvalor smallint;
define i integer;
define num smallint;
define vNumIniciudad 	char(8); --A.L.L
define vEstadoSiglas	char(10); --A.L.L
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
--DEFINE iCuentasExcluidasXSdosVencidos integer;
--DEFINE dFechaCarLinea   date;
DEFINE iOtrasExclusiones integer;
DEFINE cNumProducto 	 char(04);
DEFINE iCuentasExcluidasXCel	INTEGER;

---INICIALIZACIONES
LET cNumCta				= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado = '';
LET cNomCiudad = '';
LET iPagoVenc = 0;
LET vSdoTotal1 = 0;
LET vMtoVencido1 = 0;
LET vMensualidad = 0;
LET vSdoTotal2 = 0;
LET vMtoVencido2 = 0;
LET vsaldo_total = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
let vpago = 0;
LET iCel = 0;
LET vdia_pago = 0;
LET vpago_vencido = 0;

let vnumcte = '';
let vnumcredito = '';
let vnumtarjeta = '';
let vimporte	=0;
let vfecha		= date(1);
let vfechas		= date(1);

let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_COD_RET	= '000000';
--let P_MENSAJE	= 'PROCESO EXITOSO';
let P_MENSAJE	= 'El proceso de las campañas XX TDC PRIMER CONSUMO se realizó correctamente.';
let vproceso	= '2034';
let cMensaje	= '';
let vmail 		= '';
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vregistrostotal = 0;
let vcontador 		= 0;
let vfecha1 		= date(1);
let vfecha2 		= date(1);
let vimporte1		= 0;
let vimporte2 		= 0; 
let vpri_dia_mes = date(1);
let vapell_paterno = '';
--let vcount = 0;
let iCount_TC_PRIMERC = 0; --A.L.L.
let iCount_TC_PRIMERS = 0; --A.L.L.
let i = 0;
LET num = 0;
let vNumIniciudad	='';
let vEstadoSiglas	='';
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
--let iCuentasExcluidasXSdosVencidos = 0;
--let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;
let cNumProducto 	= '';
let iCuentasExcluidasXCel = 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02')RETURNING P_COD_RET;	
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

--  Set debug file to 'sp_mail_primerconsumo.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	select fecha_ant into vfecha from bdicred:sd_fechas where empresa = '001';
--temporal para pruebas	
	--let vfecha = today;
--temporal para pruebas
	let vpri_dia_mes = mdy(month(vfecha),day(1),year(vfecha));
    set isolation to dirty read;
	
--	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= today and num_campania = 16; 
		select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)		
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TC_PRIMERC',numcte,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				
			let num = num + 10;
	end for
		
--------------------------------------------------------EMAIL------------------------------------------------------------------   
	FOREACH
	
		SELECT  
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b 
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
/*			select  apell_paterno into vapell_paterno
			from bdinteg:si_cliente where empresa = '001' and numcte = vnumcte ;*/
		  
			let vmail = '';
			select limit 1 cte.correo_elec into vmail 
			from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = vnumcte and cte.status_correo ='A'
			and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = vnumcte and status_correo ='A');		

			if vmail is null or vmail = '' then 
		       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
		       continue foreach; 
		    end if;

			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
--			if (vmail <> '') then	
--				if nvl(vnumcte,'') <> '' then
				--A.L.L.
				LET iCount_TC_PRIMERC = iCount_TC_PRIMERC +1;
				call bdimnsj:"informix".sp_registra_evento (1, 'TC_PRIMERC' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',vimporte,0,0,0,0, today, '')RETURNING P_COD_RET;

				call "informix".sp_inserta_info_rep_envios ('001','EMAIL',1009, vnumcredito, vnumcte, cNumProducto, today, vmail, '','', 0) returning P_COD_RET;
--				end if;
--			end if;
		end if;
	END FOREACH

		--A.L.L.
	IF iCount_TC_PRIMERC > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCount_TC_PRIMERC) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	END IF;
	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERC : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERC : ' ||iCount_TC_PRIMERC;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	   end if;
--Genera cifras de control

	
---------------------------------------------------------SMS-------------------------------------------------------	
	let vfecha1 = date(1);		let vfecha2 = date(1);		let vimporte1 = 0;		let vimporte2 = 0; 
	let iCuentasProcesadas = 0;
	--- foreach para sms 
	let vfechas = date(vfecha)	+ 1 units day;
	select valor_numerico 
			into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 1;
		
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
		
		---- consulta para saber cuantos registros faltan por buscar al mes	
		let vregistrostotal = vvalor_numerico - vtotal;
		
		LET vtotal = vtotal;
		if (day(vfechas) = 1 ) then 
			let vtotal = 0; 
			let vregistrostotal = vvalor_numerico;
		end if;
		
if(vtotal < vvalor_numerico) then 
	FOREACH
	
		SELECT 
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b --, bdinteg:si_correos d
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
			LET iPagoVenc = 0;		
		
			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
/*			SELECT limit 1  e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
		    INTO  cNomEstado, cNomCiudad  --cEstado, cCiudad
		    FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= vnumcte
		     AND d.tipo_dir= '1'
		     AND d.estado = e.estado
		     AND d.ciudad = c.ciudad
		     AND c.estado = e.estado;*/
			 
			SELECT limit 1 d.telefono
		    INTO cCel
		    FROM bdinteg:"informix".si_telefonos_actual d
		    WHERE d.numcte= vnumcte
		     AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

			if cCel is null or cCel = '' then 
		       let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
		       continue foreach; 
		    end if;

--			if (cCel <> '') then
		
				LET iCel = LENGTH(cCel) + 1 - 10;
    
--				IF cCel <> '' then
					IF ( LENGTH(cCel) > 10 ) THEN
						LET cCel = SUBSTR(cCel,iCel,10);
					ELIF ( LENGTH(cCel) < 10 ) THEN
						LET cCel =''; 
					END IF;		
--				END IF;
			
/*				SELECT NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
				INTO cNombre1, cNombre2, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte= vnumcte;		*/
		
				SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
				INTO cSituacion, iCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = vnumcte;
			
				IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
				IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
--				IF cCel <> '' then
--					if (vnumcredito is not null) then
/*					INSERT INTO bdicobranza:"informix".cb_info_administrativa
						(empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
						nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, 
						pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, causa,situacion,
						pago_vencido ,pago_req_sms, cidad, estado)
					VALUES ('001', 16, '6001', today, vnumcte, vnumcredito, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, 
						cNombre1, cNombre2, cApellPat, cApellMat, cCel, 0,
						0, '', 0, iPagoVenc, 0, iCausa,cSituacion,0,vimporte, vNumIniciudad, vEstadoSiglas );*/
					--A.L.L.
					LET iCount_TC_PRIMERS = iCount_TC_PRIMERS +1;
					call bdimnsj:"informix".sp_registra_evento (2, 'TC_PRIMERS' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
							
					let vcontador = vcontador + 1;			
					call "informix".sp_inserta_info_rep_envios ('001','SMS',16, vnumcredito, vnumcte, cNumProducto, today, cCel, '','', 0) returning P_COD_RET;
					end if; 
--				end if;
--			end if;
			if (vcontador = vregistrostotal) then exit FOREACH; end if;
--		end if;
	END FOREACH
end if;
	
	if (vcontador >= 1) then 
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1)
		select  2, 'TC_PRIMERS',numcte,current,apell_paterno
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for
	end if;
	
	-------------------------------------------contadores------------------------------------	

		--A.L.L.
		IF iCount_TC_PRIMERS > 0 THEN
--            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCount_TC_PRIMERS) RETURNING P_COD_RET;
            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING P_COD_RET;
		END IF;
		
--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERS : ' ||iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERS : ' ||iCount_TC_PRIMERS;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	       let cMensaje = 'Cuentas excluidas por error cel : ' ||iCuentasExcluidasXCel;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	    end if;
--Genera cifras de control
		
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING P_COD_RET;	
--    RETURN P_COD_RET;

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;
    
	RETURN P_COD_RET,P_MENSAJE;
end;
end procedure;