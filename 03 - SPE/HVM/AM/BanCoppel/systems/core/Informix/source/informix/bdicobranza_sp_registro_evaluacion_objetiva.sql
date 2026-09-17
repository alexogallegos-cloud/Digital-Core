CREATE PROCEDURE "informix".sp_registro_evaluacion_objetiva(pEmpresa char(3), pFecha date)

RETURNING CHAR(6), char(80);
  -- vers 1.0.0 20190515
  define vcCodRet CHAR(5);
  define viSqlErr INTEGER;
  define vDataErr	      varchar(64);
  define vcEsTransaccion  CHAR(1);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(80);
  define vEmpresa         char(3);
  define vFechahoy        date;
  define vFechaDiaAnt     date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define vFechaMesAnterior date;
  define cNumCte_movs     char(20);
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dSuma_importe    decimal(18,2);
  define dSuma_importe_2  decimal(18,2);
  define dSuma_importe_his decimal(18,2);
  define dSuma_importe_total decimal(18,2);
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
  define cCalificado      char(1);

  define dtFecha_ant      date;
  define dPago_minimo_guardado              DECIMAL(18,2);
  define dSaldo_vencido_guardado            DECIMAL(18,2);
  define dPago_minimo_recuperado_guardado   DECIMAL(18,2);
  define dSaldo_vencido_recuperado_guardado DECIMAL(18,2);
  
  define dtFecha_insert   date;
  define dtFecha_insert_guardada   date;    
  define cSucursal        char(4);
  define cUsuario         char(8);
  define cNum_producto    char(4);
  define dPago_minimo     decimal(18,2);
  define dPago_realizado  decimal(18,2);
  define dPct_cump_pm     decimal(8,2);   
  define dPct_cump_sv     decimal(8,2);
  define iNum_pago_completo_pm  integer;
  define iNum_pago_parcial_pm   integer;
  define dMonto_vencido   decimal(18,2);
  define iNum_pago_completo_sv  integer;
  define iNum_pago_parcial_sv   integer;
  define dPct_rec_cartera    decimal(8,2);
  define cSucursal_origen    char(4);  
  define cNombre_cajero      char(45);
  define cNum_credito_evobj  char(20);
  define dPct_cump_pm_new    decimal(8,2);
  define dPct_cump_sv_new    decimal(8,2);
  define dPago_realizado_sv  decimal(18,2);
  define dPago_realizado_2   decimal(18,2); 
  
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let vFechaDiaAnt      = date(1);
  let cNumCte           = '';
  let cProceso          = '0089';
  let cCod_ret_2        = '';
  let vFechaMesAnterior = date(1);
  let cNumCte_movs      = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dSuma_importe     = 0;
  let dSuma_importe_2   = 0;
  let dSuma_importe_his = 0;
  let dSuma_importe_total = 0; 
  
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
  let cCalificado   = '';  
  
  let dtFecha_ant   = date(1);
  let dPago_minimo_guardado  = 0;
  let dSaldo_vencido_guardado = 0;
  let dtFecha_insert = date(1);
  let dtFecha_insert_guardada = date(1);
  let cSucursal = '';
  let cUsuario = '';
  let cNum_producto = '';
  let dPago_minimo = 0;
  let dPago_realizado = 0;
  let dPct_cump_pm    = 0.00;
  let dPct_cump_sv    = 0.00;
  let iNum_pago_completo_pm  = 0;
  let iNum_pago_parcial_pm   = 0;
  let dMonto_vencido = 0;  
  let iNum_pago_completo_sv  = 0;
  let iNum_pago_parcial_sv   = 0;
  let dPct_rec_cartera       = 0;
  let cSucursal_origen       = '';
  let cNombre_cajero         = '';
  let cNum_credito_evobj     = '';
  let dPago_minimo_recuperado_guardado    = 0;
  let dSaldo_vencido_recuperado_guardado  = 0;
  let dPct_cump_pm_new       = 0;
  let dPct_cump_sv_new       = 0; 
  let dPago_realizado_sv     = 0;
  let dPago_realizado_2      = 0; 
  
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

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_registro_evaluacion_objetiva.trc";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
   IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET cCodRet = '000001';
		LET iSqlErr = '000001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
		RETURN cCodRet, trim(cMensaje);
	ELSE
		IF pFecha IS NULL OR pFecha = "" THEN 
			SELECT  fecha_hoy, fecha_ant
			 INTO vFechaHoy, dtFecha_ant
			 FROM BDINTEG:SI_FECHAS
			WHERE empresa = pEmpresa;
			
			--LET vFechaHoy = vFechaHoy;
		ELSE
			LET vFechaHoy = pFecha;
		END IF;
	END IF;
	
	--let vFechaHoy = mdy(8,19,2019); 
	
	FOREACH WITH HOLD
	
	    SELECT a.sucursal, a.fecha_insert, a.usuario, a.num_credito, b.num_producto, a.pago_min, a.pago_realizado,  round(a.pct_cump_pm,2), 
               case when a.pago_realizado >= a.pago_min then 1 else 0 end num_pago_completo_pm, 
               case when a.pago_realizado < a.pago_min then 1 else 0 end num_pago_parcial_pm,  
               nvl(a.saldo_vencido,0), round(a.pct_cump_sv,2), 
               case when a.pago_realizado >= nvl(a.saldo_vencido,0) then 1 else 0 end num_pago_completo_sv,
               case when a.pago_realizado < nvl(a.saldo_vencido,0) then 1 else 0 end num_pago_parcial_sv, 
			   b.sucursal, c.nombre --, round((a.pct_cump_pm + a.pct_cump_sv)/2,2)  pct_rec_cartera, 
			   INTO cSucursal, dtFecha_insert, cUsuario, vNum_credito, cNum_producto, dPago_minimo, dPago_realizado, dPct_cump_pm,
			   iNum_pago_completo_pm, iNum_pago_parcial_pm, dMonto_vencido, dPct_cump_sv,
			   iNum_pago_completo_sv, iNum_pago_parcial_sv, cSucursal_origen, cNombre_cajero -- dPct_rec_cartera
         FROM  BDICOBRANZA:CB_EVALUACION_OBJETIVA_HIS a, BDICRED:SD_MAECRED b, BDINTEG:SI_EJECUT c, BDINTEG:SI_SUCURSALES d
         WHERE a.num_credito = b.num_credito
           AND a.fecha_insert = vFechaHoy 
		   AND a.pago_min > 0 
		   AND a.usuario = c.ejecutivo AND c.sucursal = d.sucursal AND d.tipo = 'S'
		   AND c.ejecutivo NOT IN('informix','interact')
           AND a.num_credito NOT IN( SELECT num_credito FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA 
		                              WHERE fecha_insert = vFechaHoy)
		   AND a.reversado = 'N'
		   ORDER by a.fecha_insert, a.hora_mov 
	
	
	    --SELECT nombre INTO cNombre_cajero 
		--  FROM BDINTEG:SI_EJECUT WHERE ejecutivo = cUsuario;
		
		let cNombre_cajero = NVL(cNombre_cajero,'');
	 
		SELECT num_credito, fecha_insert, nvl(monto_pago_minimo,0), nvl(monto_recup_pm,0), nvl(monto_saldo_vencido,0), nvl(monto_recup_sv,0) 
		  INTO cNum_credito_evobj, dtFecha_insert_guardada, dPago_minimo_guardado, dPago_minimo_recuperado_guardado, 
		       dSaldo_vencido_guardado, dSaldo_vencido_recuperado_guardado
		  FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA
		 WHERE num_credito = vNum_credito
		   AND fecha_insert = dtFecha_insert;
		 
		 
		 if dMonto_vencido <= 0 then 
		    let dPago_realizado_sv = 0;
			let iNum_pago_completo_sv = 0;
			let iNum_pago_parcial_sv = 0;
	     elif dPago_realizado > dMonto_vencido then --20190820
		    let dPago_realizado_sv = dMonto_vencido;  
		 else
		    let dPago_realizado_sv = dPago_realizado;
		 end if;
		 

		IF NVL(cNum_credito_evobj,'') <> '' THEN
		    --Antes que nada si el PM guardado con anterioridad es diferente al pago minimo de hoy, 
		    --no debe hacer nada pq los calculos hasta el momento son de un pm anterior. Esto debe pedir el Usuario corregirlo pq lo correcto es de corte a corte 
		 	--IF dPago_minimo_guardado = dPago_minimo  then	
            -- dPago_realizado_2 (crearlo solo para calcular el porcentaje cump pm)  -- 20191024
			IF dtFecha_insert = dtFecha_insert_guardada then
			    if dPago_realizado >= dPago_minimo then let dPago_realizado_2 = dPago_minimo; end if; -- 20191024
				let dPct_cump_pm_new = round(((dPago_realizado_2 + dPago_minimo_recuperado_guardado) / dPago_minimo_guardado) * 100,2); -- 20191024
				
				if dSaldo_vencido_guardado <= 0 then
				   let dPct_cump_sv_new = 0;
				--elif (dSaldo_vencido_recuperado_guardado - dSaldo_vencido_guardado) > 0 then --- 20191024
				--     if dPago_realizado_sv > 0 then
				else
				   let dPct_cump_sv_new = round(((dPago_realizado_sv + dSaldo_vencido_recuperado_guardado) / dSaldo_vencido_guardado) * 100,2); -- 20191024
				end if;
				
				if dPct_cump_pm_new > 100 then let dPct_cump_pm_new = 100; end if;
				if dPct_cump_sv_new > 100 then let dPct_cump_sv_new = 100; end if;
				
				if dSaldo_vencido_recuperado_guardado >= dSaldo_vencido_guardado then
				   let dPago_realizado_sv = 0;
				   let iNum_pago_completo_sv = 0;
				   let iNum_pago_parcial_sv = 0;
				else 
				   let dPago_realizado_sv = dPago_realizado;
				end if;
				
				BEGIN;  
					  UPDATE BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA set sucursal_pago = cSucursal, fecha_insert = dtFecha_insert, cajero = cUsuario, 
																	   nom_cajero = cNombre_cajero,
																	   --monto_pago_minimo = dPago_minimo,
																	   monto_recup_pm = monto_recup_pm + dPago_realizado,
																	   num_pm_realizados = num_pm_realizados + iNum_pago_completo_pm,
																	   num_pm_no_realizados = num_pm_no_realizados + iNum_pago_parcial_pm,
																	   --monto_saldo_vencido = dMonto_vencido,
																	   monto_recup_sv = monto_recup_sv + dPago_realizado_sv, 
																	   num_sv_realizados = num_sv_realizados + iNum_pago_completo_sv,
																	   num_sv_no_realizados = num_sv_no_realizados + iNum_pago_parcial_sv,
																	   --PCT_CUMP_PM = (dPago_realizado+monto_recup_pm)/monto_pago_minimo,
																	   --PCT_CUMP_SV = (dPago_realizado+monto_recup_sv)/monto_saldo_vencido
																	   PCT_CUMP_PM = dPct_cump_pm_new,
																	   PCT_CUMP_SV = dPct_cump_sv_new
																	   
					  WHERE num_credito = cNum_credito_evobj and fecha_insert = dtFecha_insert_guardada;
				   COMMIT;
				   LET iContGral_2 = iContGral_2 +1;
			END IF;
		ELSE   
		   -- NUEVO		
			   BEGIN;
				  INSERT INTO BDICOBRANZA:CB_EVALUACION_OBJETIVA_NUEVA(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				                 monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados,
								 num_sv_no_realizados, pct_cump_pm, pct_cump_sv)

				  VALUES (vNum_credito, cSucursal_origen, cSucursal, dtFecha_insert, cUsuario, cNombre_cajero, cNum_producto, dPago_minimo, dPago_realizado, iNum_pago_completo_pm,
                          iNum_pago_parcial_pm, dMonto_vencido, dPago_realizado_sv, iNum_pago_completo_sv, iNum_pago_parcial_sv, dPct_cump_pm, dPct_cump_sv);
					   
			   COMMIT;
			   
			   LET iContGral = iContGral +1;
		END IF;
		 
	
	END FOREACH;
	
 --let cContGral = iContGral;
 LET cMensaje = trim(cMensaje) || '. UPDS: ' || iContGral_2 || ' INS: ' || iContGral;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE;