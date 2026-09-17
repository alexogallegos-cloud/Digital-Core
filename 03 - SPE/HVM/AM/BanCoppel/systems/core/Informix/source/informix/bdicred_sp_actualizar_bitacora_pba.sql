CREATE PROCEDURE "informix".sp_actualizar_bitacora_pba(pEmpresa char(3))
returning char(06) AS codret,
          char(80) AS mensaje;


--definicion de variables
--DEFINE pEmpresa char(3);
DEFINE cMensajeRet  CHAR(80);
DEFINE cNumproducto char(4);
DEFINE cNumCredito, cNumCte char(20);
DEFINE dFechaHoy date;
DEFINE cMesesVencidos Integer;
DEFINE fSaldoMesActual decimal(14,2);
DEFINE mIntVencido_ord, mIvaIntVencido_ord decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE cNombreArchivo1 CHAR(100);
DEFINE pMonto_otorgado decimal(14,2);
DEFINE sFechadeCorte, cFechaApertura date;
DEFINE utili_80, vmotivo_exclusion  smallint;
DEFINE vfechaexclusion,vfecha_alta date;
DEFINE vcodret char(6);
DEFINE vmensaje char(80);
DEFINE cNumSucursal char(4);
DEFINE cSql	CHAR(2024);

DEFINE dFechaExclusion date;
DEFINE cStatusCred   CHAR(02);

--SET DEBUG FILE TO '/pisa/ricardo/ventacartera/sp_actualizar_bitacora.out';
--TRACE ON;

--LET pEmpresa = '';
LET cMensajeRet  = '' ;
LET cNumProducto, cNumCredito, cNumCte = '', '', '';
LET mIntVencido_ord, mIvaIntVencido_ord= 0,0;
LET pMonto_otorgado = 0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET utili_80, vmotivo_exclusion  = 0, 0;
LET vfechaexclusion = "";
LET P_COD_RET = '000000';
LET vfecha_alta = null;
LET cNumSucursal = '0000';
    LET cNombreArchivo1= '/resplogifx/archivoscartera/bitacora_exclusiones_vta' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';
LET cSql="";
LET dFechaExclusion =date(1);
LET cStatusCred = '';

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			IF SQL_ERR != 0 THEN
                LET vcodret = SQL_ERR;
                LET vmensaje = 'ERROR en la ejecución del REPORTE DE EXCEPCIONES VENTA CARTERA';
			END IF;
			RETURN vcodret,vmensaje;
	END EXCEPTION;

    select max(fecha_exclusion) into dFechaExclusion
    from bdicred:sd_exclusiones_ventacartera;


	FOREACH WITH hold

		SELECT {+INDEX(sd_exclusiones_ventacartera idx_fecha_exclusion)} num_producto, num_credito, numcte, motivo_exclusion
		INTO cNumProducto, cNumCredito, cNumCte, vmotivo_exclusion
		FROM bdicred:sd_exclusiones_ventacartera
        WHERE date(fecha_exclusion) = dFechaExclusion

		IF  cNumProducto = '6001' then


	--monto_otorgado y meses vencidos
			SELECT monto_otorgado, mto_fin_ven_trasp
			INTO pMonto_otorgado, cMesesVencidos
			FROM bdicred:sd_maesdos
			WHERE empresa  ='001'
			AND num_credito = cNumCredito;

	--Para saldo_actual
			SELECT
			NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual
			FROM bdicred:sd_maesdos b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito;

	--para intereses
	-- Se obtiene los Intereses orden
			SELECT d.int_tra_no_exig
			INTO mIntVencido_ord
			FROM bdicred:sd_maesdos d
			WHERE d.empresa= pEmpresa
			AND d.num_credito= cNumCredito;

    --  Se obtiene el Iva de los Intereses Vigentes
			SELECT SUM(iva_debe - iva_pagado)
			INTO mIvaIntVencido_ord
			FROM sd_amortiza_credito d
			WHERE d.empresa = pEmpresa
			AND d.num_credito = cNumCredito
			AND capital_status IN ('1','2','7');

	--fecha apertura

			SELECT NVL(fecha_apertura,date(1))
			INTO   cFechaApertura
			FROM sd_maecred b
			WHERE b.empresa = pEmpresa
			AND b.num_credito = cNumCredito;

	--reestructuras
        ELSE


	--monto_otorgado
			SELECT monto_otorgado, mto_fin_ven_trasp
			INTO pMonto_otorgado, cMesesVencidos
			FROM bdicred:sd_maesdoscrd
			WHERE empresa  ='001'
			AND num_credito = cNumCredito;

	--Para saldo_actual
			SELECT
			NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito;

	--intereses
	--balanza
				IF cNumProducto = '6011' THEN
                    IF cStatusCred = 'BT' THEN

                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
                        INTO mIntVencido_bal, mIvaIntVencido_bal
                        from bdicred:sd_amortiza_creditocrd
                        where empresa = pEmpresa
                        and num_credito = cNumCredito
                        and capital_status in ('2','7')
                        and fecha_cuota <= (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');

    --orden
                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
                        INTO mIntVencido_ord, mIvaIntVencido_ord
                        from bdicred:sd_amortiza_creditocrd
                        where empresa = pEmpresa
                        and num_credito = cNumCredito
                        and capital_status in ('2','7')
                        and fecha_cuota > (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');
                    ELSE
                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                        INTO mIntVencido_ord, mIvaIntVencido_ord
                        FROM bdicred:sd_amortiza_creditocrd
                        WHERE empresa = pEmpresa
                        AND num_credito= cNumCredito
                        AND capital_status in ('2','7');
                    END IF;

				ELIF cNumProducto = '6300' THEN
            --balanza
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
					INTO mIntVencido_bal, mIvaIntVencido_bal
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCredito
					and capital_status in ('2','7')
					and fecha_cuota <= (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
            --orden
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
					INTO mIntVencido_ord, mIvaIntVencido_ord
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCredito
					and capital_status in ('2','7')
					and fecha_cuota > (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
				END IF;
	--fecha apertura

			SELECT sucursal, NVL(fecha_apertura,date(1))
			INTO cNumSucursal, cFechaApertura
			FROM sd_maecredcrd b
			WHERE b.empresa = pEmpresa
			AND b.num_credito = cNumCredito;

		END IF;

	--fecha manteniemiento

			IF vmotivo_exclusion = '13' then
				select limit 1 date(fecha_alta)
				into vfecha_alta
				from bdinteg:si_huella_temp a where a.numcte = cNumCte
				and a.secuencia = (select max(secuencia)
				from bdinteg:si_huella_temp b where b.numcte = a.numcte)
				and status = 'M';
			END IF;

		--meses de utilizacion
			Select count(*) into utili_80
			from bdicred:"informix".sd_hist_reserva
			where empresa = '001' 
			and num_credito  = cNumCredito and fecha_cierre >= date(1)
--			and num_credito  = cNumCredito and fecha_cierre = mdy(month(dFechaExclusion),1,year(dFechaExclusion)) - 1 units day
			and porcentaje_uso >= 80;


			UPDATE bdicred:sd_exclusiones_ventacartera set linea_credito = pMonto_otorgado , saldo_actual = fSaldoMesActual,
			int_vencido_ord = mIntVencido_ord, iva_int_vencido_ord = mIvaIntVencido_ord, int_vencido_bal = mIntVencido_bal,
			iva_int_vencido_bal = mIvaIntVencido_bal, meses_vencidos = cMesesVencidos, fecha_apertura = cFechaApertura,
			fecha_mantenimiento = vfecha_alta, meses_utilizacion = utili_80
			WHERE fecha_exclusion = dFechaExclusion and num_credito  = cNumCredito and empresa = '001';

            LET cStatusCred = '';
            LET vfecha_alta = null;
            let mIntVencido_ord = 0;
            let mIvaIntVencido_ord = 0;
            let mIntVencido_bal = 0;
            let mIvaIntVencido_bal = 0;

	END FOREACH;

--Generacion de bitacora_exclusiones_vta
			  LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
								' a.num_producto, ' ||
								' a.num_credito, ' ||
                                ' a.numcte, ' ||
                                ' a.fecha_exclusion, ' ||
								' (select trim(descripcion) from sd_cat_exclusiones_vc where empresa="001" and codigo_exclusion = a.motivo_exclusion), ' ||
								' a.linea_credito, ' ||
								' a.saldo_actual, ' ||
								' a.int_vencido_ord, ' ||
								' a.iva_int_vencido_ord, ' ||
								' a.int_vencido_bal, ' ||
								' a.iva_int_vencido_bal, ' ||
								' a.meses_vencidos, ' ||
								' a.fecha_apertura, ' ||
                                '  nvl(a.fecha_mantenimiento,'''||' '||'''), ' ||
--								' (case when a.fecha_mantenimiento = date(1) then '' else a.fecha_mantenimiento end), ' ||
								' a.meses_utilizacion ' ||
--                                ' FROM bdicred:sd_exclusiones_ventacartera a where month(fecha_exclusion) = month(today - 1 units month) ' ||
                                ' FROM bdicred:sd_exclusiones_ventacartera a ' ||
								' WHERE date(fecha_exclusion) = ''' || dFechaExclusion || ''' ; ' ||
--								' and year(fecha_exclusion) = year(today - 1 units month)' ||
                                '" > /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl > " || cNombreArchivo1;
              SYSTEM cSql;

              LET cSql = '';

--              LET cSQL = 'rm /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl';
              SYSTEM cSql;


			LET cMensajeRet = 'El proceso REPORTE DE EXCEPCIONES VENTA CARTERA terminó exitosamente';
			LET P_COD_RET = '000000';

			RETURN P_COD_RET,cMensajeRet;
END;
END PROCEDURE;