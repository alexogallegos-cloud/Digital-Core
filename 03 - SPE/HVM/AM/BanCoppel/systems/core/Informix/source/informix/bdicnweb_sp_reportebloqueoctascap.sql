CREATE PROCEDURE "informix".sp_reportebloqueoctascap(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date, 
	pArchDescarga CHAR(150), pLote int, pUsuarioC char(8))
	returning CHAR(5) as codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE cCmd1 CHAR(1500);
	DEFINE cCmd2 CHAR(1500);
	DEFINE cCmd3 CHAR(1500);
	DEFINE cCmd4 CHAR(1500);
	DEFINE cUser CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cCmd3 = '';
	LET cCmd4 = '';
	LET cUser = pIdUsuario;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportebloqueoctascapOUT.sql';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		LET cCmd1 = "select id_registro";
		LET cCmd2 = " from (((((((((bdicnweb:sw_tr_cargamasiva_bloqueocap a left join bdinteg:si_cliente b on b.numcte = a.numcte) left join bdicheq:sc_maechq c on c.cuenta = a.cuenta) left join bdinteg:si_sucursales d on d.sucursal = c.sucursal) left join bdicheq:sc_producto e on e.producto = c.producto) left join bdicheq:sc_mae_estatus f on f.cod_estatus = c.status_cta) left join bdicheq:sc_histbloq g on g.cuenta = a.cuenta and g.fecha = date(a.fecha_proceso) and g.hora = (select max(cc.hora) from bdicheq:sc_histbloq cc where cc.cuenta = g.cuenta and cc.fecha = g.fecha) and g.tipo_mov = 'B') left join bdicheq:sc_bloqueo h on h.codigo = a.clave_bloqueo) left join bdicheq:sc_opcionbloqueo i on i.opcion = a.opcion_bloqueo) left join bdicheq:sc_areabloqueo j on j.clave = a.area_solic) left join bdicheq:sc_tipobloqueo k on k.clave = a.motivo_bloqueo where a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND a.lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND a.usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL OR pUsuarioC = '' THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND a.lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
		END IF;
		
		LET cCmd3 = "select id_registro";
		LET cCmd4 = " from (((((((((bdicnweb:sw_tr_cargamasiva_bloqueocap_hist a left join bdinteg:si_cliente b on b.numcte = a.numcte) left join bdicheq:sc_maechq c on c.cuenta = a.cuenta) left join bdinteg:si_sucursales d on d.sucursal = c.sucursal) left join bdicheq:sc_producto e on e.producto = c.producto) left join bdicheq:sc_mae_estatus f on f.cod_estatus = c.status_cta) left join bdicheq:sc_histbloq g on g.cuenta = a.cuenta and g.fecha = date(a.fecha_proceso) and g.hora = (select max(cc.hora) from bdicheq:sc_histbloq cc where cc.cuenta = g.cuenta and cc.fecha = g.fecha) and g.tipo_mov = 'B') left join bdicheq:sc_bloqueo h on h.codigo = a.clave_bloqueo) left join bdicheq:sc_opcionbloqueo i on i.opcion = a.opcion_bloqueo) left join bdicheq:sc_areabloqueo j on j.clave = a.area_solic) left join bdicheq:sc_tipobloqueo k on k.clave = a.motivo_bloqueo where a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND a.lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND a.usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL OR pUsuarioC = '' THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND a.lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
		END IF;
		
		PREPARE lotesQry FROM "select count(*) from ("||TRIM(TRIM(cCmd1)||cCmd2)||" UNION "||TRIM(TRIM(cCmd3)||cCmd4)||")";
		DECLARE lotesCur CURSOR FOR lotesQry;
		OPEN lotesCur;
		
		FETCH lotesCur INTO iExiste;
		
		CLOSE lotesCur;
		FREE lotesCur;
		FREE lotesQry;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00151';
			RETURN cCodRet;
		END IF;
		
		LET cCmd1 = "select a.id_registro, a.lote, nvl(a.numcte, '') as numcte, nvl(trim(trim(trim(b.nombre1)||' '||trim(b.nombre2))||' '||trim(trim(b.apell_paterno)||' '||trim(b.apell_materno))), '') as nombre, nvl(a.cuenta, '') as cuenta, c.sdo_actual, trim(d.sucursal)||' '||trim(d.nombre) as sucursal, trim(e.producto)||' '||trim(e.nombre) as producto, f.descripcion as status_cuenta, c.fec_ult_mov, trim(h.codigo||' '||h.descripcion) as clave_bloqueo, trim(i.opcion||' '||i.descripcion) as opcion_bloqueo, a.monto_importe, trim(j.clave||' '||j.descripcion) as area_solic, trim(k.clave||' '||k.descripcion) as motivo_bloq, a.resultado, a.codret_proceso, a.motivo_rechazo, g.folio_suc, g.fecha, a.fecha_carga, a.usuario, trim(decode(g.tipo_mov, 'B', 'BLOQUEADA', 'D', 'DESBLOQUEADA')) as status_cta";
		LET cCmd3 = "lote, numcte, nombre, cuenta, nvl(trim(to_char(sdo_actual, '#,###,###,###,##&.&&')), ''), sucursal, producto, upper(status_cuenta), nvl(to_char(fec_ult_mov, '%d/%m/%Y'), ''), nvl(clave_bloqueo, ''), nvl(opcion_bloqueo, ''), nvl(trim(to_char(monto_importe, '#,###,###,###,##&.&&')), ''), nvl(area_solic, ''), nvl(motivo_bloq, ''), nvl(resultado, ''), nvl(codret_proceso, ''), nvl(motivo_rechazo, ''), nvl(folio_suc, ''), nvl(to_char(fecha, '%d/%m/%Y'), ''), nvl(to_char(fecha_carga, '%d/%m/%Y'), ''), usuario, status_cta";
		
		SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||' UNION '||TRIM(TRIM(cCmd1)||cCmd4)||') order by id_registro;" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1');
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: GeneraciÃ³n del reporte de las cuentas que fueron procesadas en el bloqueo masivo de cuentas de captaciÃ³n de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_reporteretiroctasmasivo(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date,
	pArchDescarga CHAR(150), pLote int, pUsuarioC char(8))
	returning CHAR(5) as codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE cCmd1 CHAR(1500);
	DEFINE cCmd2 CHAR(1500);
	DEFINE cCmd3 CHAR(1500);
	DEFINE cCmd4 CHAR(1500);
	DEFINE cUser CHAR(8);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cCmd3 = '';
	LET cCmd4 = '';
	LET cUser = pIdUsuario;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;


		--SET DEBUG FILE TO '/tmp/sp_reporteretiroctasmasivoOUT.sql';
		--TRACE ON;
		
		LET cCmd1 = "select *";
		LET cCmd2 = " from (((((bdicnweb:sw_tr_cargamasiva_retiro cm LEFT JOIN bdinteg:si_cliente c ON c.numcte = cm.numcte) LEFT JOIN bdicheq:sc_maechq mc ON mc.cuenta = cm.cuenta) LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal = mc.sucursal) LEFT JOIN bdicheq:sc_producto sp ON sp.producto = mc.producto) LEFT JOIN bdicheq:sc_mae_estatus sme ON sme.cod_estatus = mc.status_cta) LEFT JOIN bdinteg:si_transacc st ON st.sistema = '01' AND st.numero = cm.transaccion where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(cm.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL OR pUsuarioC = '' THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
		END IF;

		LET cCmd3 = "select *";
		LET cCmd4 = " from (((((bdicnweb:sw_tr_cargamasiva_retiro_hist cm LEFT JOIN bdinteg:si_cliente c ON c.numcte = cm.numcte) LEFT JOIN bdicheq:sc_maechq mc ON mc.cuenta = cm.cuenta) LEFT JOIN bdinteg:si_sucursales suc ON suc.sucursal = mc.sucursal) LEFT JOIN bdicheq:sc_producto sp ON sp.producto = mc.producto) LEFT JOIN bdicheq:sc_mae_estatus sme ON sme.cod_estatus = mc.status_cta) LEFT JOIN bdinteg:si_transacc st ON st.sistema = '01' AND st.numero = cm.transaccion where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(cm.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL OR pUsuarioC = '' THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
		END IF;

		PREPARE lotesQry FROM "select count(*) from ("||TRIM(TRIM(cCmd1)||cCmd2)||" UNION "||TRIM(TRIM(cCmd3)||cCmd4)||")";
		DECLARE lotesCur CURSOR FOR lotesQry;
		OPEN lotesCur;

		FETCH lotesCur INTO iExiste;

		CLOSE lotesCur;
		FREE lotesCur;
		FREE lotesQry;

		IF iExiste = 0 THEN
			LET cCodRet = '00151';
			RETURN cCodRet;
		END IF;

		LET cCmd1 = "select cm.id_registro, lote, trim(nvl(cm.numcte, '')) as numcte, nvl(trim(trim(trim(c.nombre1)||' '||trim(c.nombre2))||' '||trim(apell_paterno)||' '||trim(apell_materno)), '') as nombre_cte, cm.cuenta, mc.sdo_actual as saldo_actual, nvl(suc.sucursal||' '||trim(suc.nombre), '') as sucursal, nvl(sp.producto||' '||sp.nombre, '') as producto, upper(nvl(sme.descripcion, '')) as estatus_cuenta, nvl(to_CHAR(mc.fec_ult_mov, '%d/%m/%Y'), '') as fecha_ult_mov, nvl(st.numero||' '||st.descripcion, '') as transaccion, cm.doc_cheque, cm.monto_importe, trim(cm.referencia) as referencia, nvl(cm.resultado, '') as resultado, nvl(cm.codret_proceso, '') as codret_proceso, nvl(cm.motivo_rechazo, '') as motivo_rechazo, nvl(trim(cm.folio), '') as folio, to_CHAR(date(cm.fecha_proceso), '%d/%m/%Y') as fecha_aplicacion, to_CHAR(date(cm.fecha_carga), '%d/%m/%Y') as fecha_operacion";
		LET cCmd3 = "lote, numcte, nombre_cte, cuenta, nvl(trim(to_char(saldo_actual, '#,###,###,##&.&&')), '') as saldo_actual, sucursal, producto, estatus_cuenta, fecha_ult_mov, transaccion, doc_cheque, nvl(trim(to_char(monto_importe, '#,###,###,##&.&&')), '') as monto_importe, referencia, resultado, codret_proceso, motivo_rechazo, folio, fecha_aplicacion, fecha_operacion";


		SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||' UNION '||TRIM(TRIM(cCmd1)||cCmd4)||') order by id_registro;" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1');
																																												
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: GeneraciÃ³n del reporte de las cuentas que fueron procesadas en el retiro masivo de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_consultadetlide(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13))
	RETURNING CHAR(5) AS codret,
			CHAR(6) AS aniomes,
			CHAR(20) AS numcte,
			CHAR(20) AS referencia_retencion,
			DATE AS fecha_ret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAnioMes CHAR(6);
	DEFINE cNumCliente CHAR(20);
	DEFINE cReferenciaRetencion CHAR(20);
	DEFINE dFechaRet DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAnioMes = '';
	LET cNumCliente = '';
	LET cReferenciaRetencion = '';
	LET dFechaRet = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetlide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
		END IF;
		
		SELECT aniomes, num_cte, ref_ret, fecha_ret
		INTO cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet
		FROM bdilide:"informix".sl_detlide
		WHERE rfc = pRfc;
		
		IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
			LET cCodRet = '00030';
		END IF;
		
		RETURN cCodRet, cAnioMes, cNumCliente, cReferenciaRetencion, dFechaRet;
	
	END;
			
END PROCEDURE;