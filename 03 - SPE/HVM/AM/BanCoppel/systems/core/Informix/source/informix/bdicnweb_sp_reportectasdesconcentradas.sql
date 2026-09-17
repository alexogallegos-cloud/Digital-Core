CREATE PROCEDURE "informix".sp_reportectasdesconcentradas(cID_USUARIOC CHAR(8),
                                                     	  cID_FUNCIONC CHAR(10),
							  pIfechaProceso DATE,
							  pFfechaProceso DATE,
							  pArchivoDescarga CHAR(100))
       RETURNING CHAR(5) AS codRet;
--
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INTEGER;

DEFINE cEmpresa			CHAR(3);
DEFINE iExiste           	INTEGER;

DEFINE cCmd      		CHAR(355);
DEFINE cCmd1     		CHAR(355);
DEFINE cCmd2     		CHAR(355);
DEFINE cCmd3     		CHAR(355);
DEFINE cCmd4     		CHAR(355);
DEFINE cCmd5     		CHAR(355);
DEFINE cCmd6     		CHAR(355);
DEFINE cCmd7     		CHAR(355);

DEFINE vFechaHoy            	DATE;
DEFINE vCuenta              	CHAR(20);
DEFINE vStatusCta           	CHAR(1);
DEFINE vSucursal            	CHAR(4);
DEFINE vSdoActual           	DECIMAL(18,2);
DEFINE vSdoRetenido         	DECIMAL(18,2);
DEFINE vSdoCongelado        	DECIMAL(18,2);
DEFINE vSdoSobregirado      	DECIMAL(18,2);
DEFINE vSdoDispCuenta       	DECIMAL(18,2);
DEFINE vFechaUltimoDep      	DATE;
DEFINE vFechaUltimoRet      	DATE;
DEFINE vFechaAlta           	DATE;
DEFINE vFechaCompara        	DATE;
DEFINE vNomProducto         	CHAR(40);
DEFINE vNumCliente          	CHAR(20);
DEFINE vNumTarjeta          	CHAR(16);
DEFINE vcNombreCliente      	VARCHAR(107);
DEFINE cRazonSocial	       	CHAR(60);
DEFINE vexistecta           	SMALLINT;
DEFINE vFechaUltMov         	DATE;
DEFINE vProducto	       	CHAR(4);
DEFINE vNomSucursal	       	CHAR(40);
DEFINE vFechaProceso         	DATE;

DEFINE vResultado	       	SMALLINT;
DEFINE vFolio               	CHAR(16);
DEFINE vSdoConcentrado       	DECIMAL(18,2);
DEFINE vFechaConcentra         	DATE;

    -- // INICIALIZACION DE VARIABLES.
LET cCodRet 			= "00000";
LET iSql_err 			= 0 ;

LET cEmpresa			= '001';
LET iExiste			= 0;

LET cCmd      			= '';
LET cCmd1     			= '';
LET cCmd2     			= '';
LET cCmd3     			= '';
LET cCmd4     			= '';
LET cCmd5     			= '';
LET cCmd6     			= '';
LET cCmd7     			= '';

LET vFechaHoy         		= '';
LET vCuenta           		= '';
LET vStatusCta        		= '';
LET vSucursal         		= '';
LET vSdoActual        		= 0.00;
LET vSdoRetenido      		= 0.00;
LET vSdoCongelado     		= 0.00;
LET vSdoSobregirado   		= 0.00;
LET vSdoDispCuenta    		= 0.00;
LET vFechaUltimoDep   		= '';
LET vFechaUltimoRet   		= '';
LET vFechaAlta        		= '';
LET vFechaCompara     		= '';
LET vFolio            		= '';
LET vNomProducto      		= '';
LET vNumCliente       		= '';
LET vNumTarjeta       		= '';
LET vcNombreCliente    		= '';
LET cRazonSocial    		= '';
LET vexistecta                  = 0;

LET vFechaUltMov      		= '';
LET vProducto	    		= '';
LET vNomSucursal    		= '';
LET vFechaProceso     		= '';

LET vResultado	    		= 0;
LET vFolio               	= '';
LET vSdoConcentrado       	= 0;
LET vFechaConcentra         	= '';

SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_reportectasdesconcentradasout.sql';
	--TRACE ON;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = ''   	OR
		pIfechaProceso = ''   	OR
		pFfechaProceso = ''   	OR
		pArchivoDescarga = ''   THEN
		LET cCodRet = "00036";
		RETURN cCodRet;
	END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,
                                                                       cID_FUNCIONC)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
		RETURN cCodRet;
        END IF;
--
	SELECT count(*)
	INTO iExiste
	FROM bdicheq:"informix".sc_maechq mae INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = mae.num_cte)
		INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = mae.sucursal)
		LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON (tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = "T" AND tar.status_tar = "A" 
			AND tar.secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND cuenta = mae.cuenta AND tipo_tarjeta = "T" AND status_tar = "A"))
		LEFT OUTER JOIN bdicheq:"informix".sc_cuentas_concentradas cco ON (cco.grupo = mae.empresa AND cco.cuenta = mae.cuenta) WHERE mae.empresa = cEmpresa 
			AND mae.fecha_proceso BETWEEN pIfechaProceso AND pFfechaProceso AND mae.status_cta = "8";

	IF iExiste = 0 THEN
		LET cCodRet = "00151";
		RETURN cCodRet;
	END IF;
	-- // OBTIENE DATOS DE LA CUENTA
	LET cCmd1 = 'SELECT mae.num_cte,TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno),mae.cuenta, mae.sucursal||" "||suc.nombre,NVL(num_tarjeta," "),';

	LET cCmd2 = '(select producto||" "||nombre from bdicheq:sc_producto where producto = mae.producto) as producto, to_char(mae.fec_ult_mov, "%d/%m/%Y"), to_char(mae.fecultdep, "%d/%m/%Y"), to_char(mae.fecultret, "%d/%m/%Y"), nvl(trim(to_char(cco.sdo_concentrado, "#,###,###,###,##&.&&")), ""), "EXITOSO",';

	LET cCmd4 = '(select upper(descripcion) from bdicheq:sc_mae_estatus where cod_estatus = mae.status_cta),cco.folio, to_char(cco.fecha_concentra, "%d/%m/%Y") FROM bdicheq:"informix".sc_maechq mae INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = mae.num_cte) ';

	LET cCmd5 = 'INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = mae.sucursal) LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON (tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = "T" AND tar.status_tar = "A" AND ';

	LET cCmd6 = 'tar.secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND cuenta = mae.cuenta AND tipo_tarjeta = "T" AND status_tar = "A")) LEFT OUTER JOIN bdicheq:"informix".sc_cuentas_concentradas cco ON ';

	LET cCmd7 = '(cco.grupo = mae.empresa AND cco.cuenta = mae.cuenta) WHERE mae.empresa = "'||cEmpresa||'" AND mae.fecha_proceso BETWEEN "'||pIfechaProceso||'" AND "'||pFfechaProceso||'" AND mae.status_cta = "8" ';
	
	system trim("echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO "||trim(pArchivoDescarga)||" "||cCmd1||cCmd2||cCmd3||cCmd4||cCmd5||cCmd6||cCmd7||"' | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1");
	
	RETURN cCodRet;

END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCIPCION: Raliza el reporte en txt (unload) de las cuentas procesadas del traspaso a la cuenta global";

CREATE PROCEDURE "informix".sp_reportedepositoctasmasivo(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date, 
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
		
		--SET DEBUG FILE TO '/tmp/sp_reportedepositoctasmasivoOUT.sql';
		--TRACE ON;
		
		LET cCmd1 = "select *";
		LET cCmd2 = " from (((((bdicnweb:'informix'.sw_tr_cargamasiva_deposito cm LEFT JOIN bdinteg:'informix'.si_cliente c ON c.numcte = cm.numcte) LEFT JOIN bdicheq:'informix'.sc_maechq mc ON mc.cuenta = cm.cuenta) LEFT JOIN bdinteg:'informix'.si_sucursales suc ON suc.sucursal = mc.sucursal) LEFT JOIN bdicheq:'informix'.sc_producto sp ON sp.producto = mc.producto) LEFT JOIN bdicheq:'informix'.sc_mae_estatus sme ON sme.cod_estatus = mc.status_cta) LEFT JOIN bdinteg:'informix'.si_transacc st ON st.sistema = '01' AND st.numero = cm.transaccion where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(cm.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL THEN
			LET cCmd2 = " "||TRIM(cCmd2)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
		END IF;
		
		LET cCmd3 = "select *";
		LET cCmd4 = " from (((((bdicnweb:'informix'.sw_tr_cargamasiva_deposito_hist cm LEFT JOIN bdinteg:'informix'.si_cliente c ON c.numcte = cm.numcte) LEFT JOIN bdicheq:'informix'.sc_maechq mc ON mc.cuenta = cm.cuenta) LEFT JOIN bdinteg:'informix'.si_sucursales suc ON suc.sucursal = mc.sucursal) LEFT JOIN bdicheq:'informix'.sc_producto sp ON sp.producto = mc.producto) LEFT JOIN bdicheq:'informix'.sc_mae_estatus sme ON sme.cod_estatus = mc.status_cta) LEFT JOIN bdinteg:'informix'.si_transacc st ON st.sistema = '01' AND st.numero = cm.transaccion where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(cm.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		IF pLote IS NOT NULL THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND lote = "||pLote;
		END IF;
		IF pUsuarioC <> '' THEN
			LET cCmd4 = " "||TRIM(cCmd4)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
			LET cUser = pUsuarioC;
		END IF;
		IF pLote IS NULL THEN
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
		
		LET cCmd1 = "select cm.id_registro, lote, trim(nvl(cm.numcte, '')) as numcte, nvl(trim(trim(trim(c.nombre1)||' '||trim(c.nombre2))||' '||trim(apell_paterno)||' '||trim(apell_materno)), '') as nombre_cte, cm.cuenta, mc.sdo_actual as saldo_actual, nvl(suc.sucursal||' '||trim(suc.nombre), '') as sucursal, nvl(sp.producto||' '||sp.nombre, '') as producto, upper(nvl(sme.descripcion, '')) as estatus_cuenta, nvl(to_CHAR(mc.fec_ult_mov, '%d/%m/%Y'), '') as fecha_ult_mov, nvl(st.numero||' '||st.descripcion, '') as transaccion, trim(cm.descripcion1)::INTEGER as doctocheque, cm.monto_importe, trim(cm.descripcion2) as referencia, nvl(cm.resultado, '') as resultado, nvl(cm.codret_proceso, '') as codret_proceso, nvl(cm.motivo_rechazo, '') as motivo_rechazo, nvl(trim(cm.folio), '') as folio, to_CHAR(date(cm.fecha_proceso), '%d/%m/%Y') as fecha_aplicacion, to_CHAR(date(cm.fecha_carga), '%d/%m/%Y') as fecha_operacion";
		LET cCmd3 = "lote, numcte, nombre_cte, cuenta, nvl(to_char(saldo_actual, '#,###,###,###,###,##&.&&'), '') as saldo_actual, sucursal, producto, estatus_cuenta, fecha_ult_mov, transaccion, doctocheque, nvl(to_char(monto_importe, '#,###,###,###,##&.&&'), '') as monto_importe, referencia, resultado, codret_proceso, motivo_rechazo, folio, fecha_aplicacion, fecha_operacion";
		
		SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||' UNION '||TRIM(TRIM(cCmd1)||cCmd4)||') order by id_registro;" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1');
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: GeneraciÃ³n del reporte de las cuentas que fueron procesadas en el deposito masivo de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_reportedesbloqueoctascap(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date, 
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
		
		--SET DEBUG FILE TO '/tmp/sp_reportedesbloqueoctascapout.sql';
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
		LET cCmd2 = " from (((((((bdicnweb:sw_tr_cargamasiva_desbloqueocap a left join bdinteg:si_cliente b on b.numcte = a.numcte) left join bdicheq:sc_maechq c on c.cuenta = a.cuenta) left join bdinteg:si_sucursales d on d.sucursal = c.sucursal) left join bdicheq:sc_producto e on e.producto = c.producto) left join bdicheq:sc_mae_estatus f on f.cod_estatus = c.status_cta) left join bdicheq:sc_histbloq g on g.cuenta = a.cuenta and g.fecha = date(a.fecha_proceso) and g.hora = (select max(cc.hora) from bdicheq:sc_histbloq cc where cc.cuenta = g.cuenta and cc.fecha = g.fecha) and g.tipo_mov = 'D') left join bdicheq:sc_areabloqueo j on j.clave = a.area_solic) left join bdicheq:sc_tipobloqueo k on k.clave = a.motivo_bloqueo where a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
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
		LET cCmd4 = " from (((((((bdicnweb:sw_tr_cargamasiva_desbloqueocap_hist a left join bdinteg:si_cliente b on b.numcte = a.numcte) left join bdicheq:sc_maechq c on c.cuenta = a.cuenta) left join bdinteg:si_sucursales d on d.sucursal = c.sucursal) left join bdicheq:sc_producto e on e.producto = c.producto) left join bdicheq:sc_mae_estatus f on f.cod_estatus = c.status_cta) left join bdicheq:sc_histbloq g on g.cuenta = a.cuenta and g.fecha = date(a.fecha_proceso) and g.hora = (select max(cc.hora) from bdicheq:sc_histbloq cc where cc.cuenta = g.cuenta and cc.fecha = g.fecha) and g.tipo_mov = 'D') left join bdicheq:sc_areabloqueo j on j.clave = a.area_solic) left join bdicheq:sc_tipobloqueo k on k.clave = a.motivo_bloqueo where a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
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
		
		LET cCmd1 = "select a.id_registro, a.lote, nvl(a.numcte, '') as numcte, nvl(trim(trim(trim(b.nombre1)||' '||trim(b.nombre2))||' '||trim(trim(b.apell_paterno)||' '||trim(b.apell_materno))), '') as nombre, nvl(a.cuenta, '') as cuenta, c.sdo_actual, trim(d.sucursal)||' '||trim(d.nombre) as sucursal, trim(e.producto)||' '||trim(e.nombre) as producto, f.descripcion as status_cuenta, c.fec_ult_mov, a.monto_importe, trim(j.clave||' '||j.descripcion) as area_solic, trim(k.clave||' '||k.descripcion) as motivo_bloq, a.resultado, a.codret_proceso, a.motivo_rechazo, g.folio_suc, g.fecha, a.fecha_carga, a.usuario, trim(decode(g.tipo_mov, 'B', 'BLOQUEADA', 'D', 'DESBLOQUEADA')) as status_cta";
		LET cCmd3 = "lote, trim(numcte), trim(nombre), trim(cuenta), nvl(trim(to_char(sdo_actual, '#,###,###,###,##&.&&')), ''), sucursal, producto, upper(status_cuenta), nvl(to_char(fec_ult_mov, '%d/%m/%Y'), ''), nvl(area_solic, ''), nvl(motivo_bloq, ''), trim(nvl(resultado, '')), trim(nvl(codret_proceso, '')), trim(nvl(motivo_rechazo, '')), trim(nvl(folio_suc, '')), nvl(to_char(fecha, '%d/%m/%Y'), ''), nvl(to_char(fecha_carga, '%d/%m/%Y'), ''), usuario, status_cta";
		
		SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||' UNION '||TRIM(TRIM(cCmd1)||cCmd4)||') order by id_registro;" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1');
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: GeneraciÃ³n del reporte de las cuentas que fueron procesadas en el bloqueo masivo de cuentas de captaciÃ³n de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_abono_ref_masivo(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pIdPlantilla CHAR(25), pTituloPlantilla char(255))
	RETURNING CHAR(5) AS codret,
			INT AS registros_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE cTransaccion CHAR(4);
	DEFINE iDoctoCheque INT;
	DEFINE mImporte money(14,2);
	DEFINE cReferencia CHAR(40);
	DEFINE iRegistro INT;
	DEFINE cCuenta CHAR(20);
	DEFINE cFolio CHAR(16);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cResultado CHAR(15);
	DEFINE iRegistrosExito INT;
	DEFINE iRegistrosError INT;
	DEFINE dFechaProceso DATETIME YEAR TO FRACTION(3);
	DEFINE cMotivoRechazo char(100);
	DEFINE iRegProc int;
	DEFINE iTransaccionPrev int;
	DEFINE iTransaccion int;
	DEFINE cFechaCargaLote date;
	DEFINE iTotalRegsLote int;
	DEFINE mMontoLote money(14,2);
	DEFINE iRegsAceptadosLote int;
	DEFINE iRegsRechazoLote int;
	DEFINE cArchivo char(150);
	DEFINE cStatus char(1);
	DEFINE mSaldoActual MONEY(14, 2);
	DEFINE cStatusLote CHAR(1);
	DEFINE dHoy DATETIME YEAR TO SECOND;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cTransaccion = '';
	LET iDoctoCheque = 0;
	LET mImporte = 0;
	LET cReferencia = '';
	LET iRegistro = 0;
	LET cCuenta = '';
	LET cFolio = '';
	LET cCodRetSp = '';
	LET cResultado = '';
	LET iRegistrosExito = 0;
	LET iRegistrosError = 0;
	LET dFechaProceso = '';
	LET cMotivoRechazo = '';
	LET iRegProc = 0;
	LET iTransaccionPrev = 0;
	LET iTransaccion = 0;
	LET cStatus = '';
	LET mSaldoActual = NULL;
	LET cStatusLote = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegProc;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET iTransaccionPrev = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-284)
			LET iRegistrosError = iRegistrosError - 1;
		END EXCEPTION WITH RESUME;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegProc;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegProc;
		END IF;
		
		-- Busqueda del lote
		SELECT count(lote)
		INTO iExiste
		FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito
		WHERE lote = pLote;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00002';
			RETURN cCodRet, iRegProc;
		END IF;
		
		-- Actualizamos los estatus a 'P' de los registros que se van a procesar del lote
		BEGIN WORK;
			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET status_lote = 'P'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT WORK;
		
		SELECT FIRST 1 CURRENT 
		INTO dFechaProceso
		FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito where lote<>'';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH WITH HOLD SELECT id_registro, transaccion, cuenta, TRIM(descripcion1)::INTEGER AS docto, monto_importe, TRIM(descripcion2) AS referencia
				INTO iRegistro, cTransaccion, cCuenta, iDoctoCheque, mImporte, cReferencia
				FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito
				WHERE lote = pLote AND status = 'C'
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_abono_ref(pIdUsuario, pIdFuncion, cTransaccion, cCuenta, iDoctoCheque, mImporte, cReferencia) INTO cCodRetSp, cFolio;
					BEGIN WORK;
				
					IF cCodRetSp <> '00000' THEN
						LET cResultado = 'NO APLICADO';
						LET cStatus = 'P';
						LET iRegistrosError = iRegistrosError + 1;
						LET cMotivoRechazo = NULL;
						LET cFolio = NULL;
					ELSE
						LET cResultado = 'APLICADO';
						LET cStatus = 'S';
						LET iRegistrosExito = iRegistrosExito + 1;
						LET cMotivoRechazo = null;
						LET cFolio = cFolio;
					END IF;
					
					SELECT sdo_actual
					INTO mSaldoActual
					FROM bdicheq:sc_maechq
					WHERE cuenta = cCuenta;
					
					UPDATE bdicnweb:"informix".sw_tr_cargamasiva_deposito
					SET fecha_proceso = dFechaProceso,
						codret_proceso = cCodRetSp,
						resultado = cResultado,
						folio = cFolio,
						motivo_rechazo = cMotivoRechazo,
						status = cStatus,
						monto1 = mSaldoActual
					WHERE id_registro = iRegistro;
					
					
					IF cCodRetSp = '00000' THEN
							INSERT INTO bdicnweb:"informix".sw_tr_cargamasiva_deposito_hist
							SELECT * FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito WHERE id_registro = iRegistro;
					END IF;
					
					LET iRegProc = iRegProc + 1;
					COMMIT WORK;
				CONTINUE FOREACH;
		END FOREACH;
		
		-- Actualizamos el estatus en la tabla de los reusmenes masivos
		EXECUTE PROCEDURE "informix".sp_totalesdepositocap(pIdUsuario, pIdFuncion, pLote)
		INTO cCodRetSp, cFechaCargaLote, iTotalRegsLote, mMontoLote, iRegsAceptadosLote, iRegsRechazoLote, cArchivo, cStatusLote;
		
		SELECT COUNT(id_registro)
		INTO iRegsRechazoLote
		FROM bdicnweb:sw_tr_cargamasiva_deposito 
		WHERE lote = pLote AND (codret_proceso <> '00000' OR status = 'E');

		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET status_lote = 'T',
				registros_rechazados = iRegsRechazoLote,
				registros_aceptados = iTotalRegsLote - (iRegsRechazoLote)
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Actulización de estatus de los regitros excluidos a cargados
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_deposito 
			SET status = 'C'
			WHERE status = 'U' AND lote = pLote;
		COMMIT;
		
		SET LOCK MODE TO WAIT 3;
		BEGIN WORK;
			DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_deposito WHERE status = 'S' and lote = pLote and codret_proceso = '00000';
		COMMIT;
		
		-- Notificación de correo electrónico
		-- Se llama al procedimiento del registro del event
		LET dHoy = current;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1', 
			TRIM(pIdPlantilla),
			TRIM(pIdPlantilla), 
			pIdUsuario, 
			'',
			'', 
			'1', 
			pLote,
			NVL(iTotalRegsLote, 0),
			TRIM(TO_CHAR(NVL(mMontoLote, 0.00), "#,###,###,###,###.##")),
			'',
			'',
			'',
			'',
			'',
			'',
			TRIM(pTituloPlantilla),
			'',
			'',
			'0',
			'0',
			'0',
			'0',
			'0',
			dHoy,
			dHoy) INTO cCodRetSp;
			
			IF iTransaccionPrev = 1 THEN
				BEGIN;
			END IF;
		
		RETURN cCodRet, iRegProc;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el deposito masivo de la aplicacion CNWEB";

CREATE PROCEDURE "informix".sp_bloquemasivocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCodRetSpSaldo CHAR(5);
	DEFINE dFechaProc DATETIME YEAR TO SECOND;
	DEFINE cResSp CHAR(5);
	DEFINE dFechaBloqueo DATETIME YEAR TO SECOND;
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE mImporte MONEY(14,2);
	DEFINE cClaveBloq CHAR(2);
	DEFINE cOpcBloque CHAR(2);
	DEFINE cAreaSolic CHAR(2);
	DEFINE cMotivoBloq CHAR(2);
	DEFINE cClaveAreaSolic CHAR(1);
	DEFINE cTipoBloqueo CHAR(1);
	DEFINE cResultado CHAR(15);
	DEFINE cStatus CHAR(1);
	DEFINE iInTrans INTEGER;
	DEFINE iRegRechazados INTEGER;
	DEFINE iTotalRegs INTEGER;
	DEFINE mTotalMonto MONEY(14,2);
	DEFINE dFechaMail DATETIME YEAR TO SECOND;
	DEFINE cFolio CHAR(16);
	DEFINE mSaldo MONEY(14,2);
	
	
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFechaProc = NULL;
	LET cCodRet = '00000';
	LET cCodRetSpSaldo = '';
	LET iSqlErr = 0;
	LET iNoRegs = 0;
	LET iIdRegistro = 0;
	LET cCuenta = '';
	LET mImporte = NULL;
	LET cClaveBloq = '';
	LET cOpcBloque = '';
	LET cAreaSolic = '';
	LET cMotivoBloq = '';
	LET cClaveAreaSolic = '';
	LET cTipoBloqueo = '';
	LET cResultado = '';
	LET cStatus = '';
	LET iInTrans = 0;
	LET iRegRechazados = 0;
	LET iTotalRegs = 0;
	LET mTotalMonto = NULL;
	LET dFechaMail = NULL;
	LET cFolio = '';
	LET mSaldo = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bloquemasivocap.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenemos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap
		WHERE lote = pLote;
		
		-- Se actualiza el estatus de los registros
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_bloqueocap
			SET status = 'P',
				fecha_proceso = current
			WHERE lote = pLote AND status = 'C';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P',
				fecha_proceso = current
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se recorre el lote
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD SELECT id_registro, cuenta, monto_importe, clave_bloqueo, opcion_bloqueo, area_solic, motivo_bloqueo
			INTO iIdRegistro, cCuenta, mImporte, cClaveBloq, cOpcBloque, cAreaSolic, cMotivoBloq
			FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap
			WHERE lote = pLote AND usuario = pUsuario AND status = 'P'

			-- Obtenemos el codigo de area solicitante
			SELECT {+INDEX(bdicheq:"informix".sc_areabloqueo index_areabloq)} codigo
			INTO cClaveAreaSolic
			FROM bdicheq:"informix".sc_areabloqueo
			WHERE TRIM(clave) = TRIM(cAreaSolic);
			
			-- Obtenemos la opcion de motivo de bloqueo
			SELECT {+INDEX(bdicheq:"informix".sc_tipobloqueo index_tipobloq)} codigo
			INTO cTipoBloqueo
			FROM bdicheq:"informix".sc_tipobloqueo
			WHERE TRIM(clave) = TRIM(cMotivoBloq);
			
			
			-- Ejecutamos el bloqueo de la cuenta
			EXECUTE PROCEDURE bdicheq:bloqueo_cta(cEmpresa, cCuenta, mImporte, cClaveBloq, TRIM(cOpcBloque), 
								DATE(dFechaProc), pUsuario, ' ', cAreaSolic, cClaveAreaSolic, cMotivoBloq, cTipoBloqueo)
			INTO cCodRetSp, cResSp;
			
			IF cCodRetSp = '000' THEN
				LET dFechaBloqueo = dFechaProc;
				LET cResultado = 'APLICADO';
				LET cStatus = 'S';
			ELSE
				LET dFechaBloqueo = NULL;
				LET cResultado = 'NO APLICADO';
				LET cStatus = 'P';
			END IF;
			
			BEGIN;
				SET ISOLATION TO DIRTY READ;
				-- Busqueda del folio generado
				SELECT folio_suc
				INTO cFolio
				FROM bdicheq:"informix".sc_histbloq a
				WHERE a.fecha = DATE(dFechaProc)
					AND a.cuenta = cCuenta
					AND a.tipo_mov = 'B'
					AND a.hora =(SELECT MAX(b.hora) FROM bdicheq:"informix".sc_histbloq b WHERE b.cuenta = a.cuenta 
							AND a.tipo_mov = b.tipo_mov AND b.fecha = a.fecha);
				
				EXECUTE PROCEDURE bdicnweb:sp_consaldodisp(pUsuario, pIdFuncion, cCuenta, '01') INTO cCodRetSpSaldo, mSaldo;
				
				UPDATE bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap
				SET fecha_proceso = dFechaProc,
					fecha_bloqueo = dFechaBloqueo,
					resultado = cResultado,
					codret_proceso = cCodRetSp,
					folio = cFolio,
					saldo = mSaldo,
					status = cStatus
				WHERE lote = pLote AND id_registro = iIdRegistro;
		
				LET iNoRegs = iNoRegs + 1;
			COMMIT WORK;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizacion de los procesados y de los que no
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iRegRechazados
		FROM bdicnweb:sw_tr_cargamasiva_bloqueocap
		WHERE lote = pLote AND status NOT IN ('U', 'S');
		
		BEGIN;
			INSERT INTO bdicnweb:sw_tr_cargamasiva_bloqueocap_hist
			SELECT * FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap WHERE lote = pLote AND status = 'S';
						
			DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap WHERE lote = pLote AND status = 'S';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET registros_rechazados = iRegRechazados
				, status_lote = 'T'
				, registros_aceptados = total_registros - iRegRechazados
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_cargamasiva_bloqueocap
			SET status = 'C'
			WHERE lote = pLote AND status = 'U';
		COMMIT;
		
		-- Notificación de correo electronico
		SELECT total_registros, total_monto
		INTO iTotalRegs, mTotalMonto
		FROM "informix".sw_tr_totales_masivo
		WHERE id_funcion = pIdFuncion AND id_lote = pLote;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
		
		IF iInTrans = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el pago masivo de cuentas de crédito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_cancelarcreditomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCodRetSpSaldo CHAR(5);
	DEFINE dFechaProc DATETIME YEAR TO SECOND;
	DEFINE dFechaCancelacion DATETIME YEAR TO SECOND;
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cStatus CHAR(1);
	DEFINE iInTrans INTEGER;
	DEFINE iRegRechazados INTEGER;
	DEFINE iTotalRegs INTEGER;
	DEFINE mTotalMonto MONEY(14,2);
	DEFINE dFechaMail DATETIME YEAR TO SECOND;
	DEFINE mSaldo MONEY(14,2);
	DEFINE cCodigoCancelacion CHAR(3);
	DEFINE cTipoCancelacion CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cFolioSuc CHAR(16);
	DEFINE iClaveCancelacion SMALLINT;
	DEFINE cMotivoCancelacion CHAR(45);
	
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFechaProc = NULL;
	LET cCodRet = '00000';
	LET cCodRetSpSaldo = '';
	LET iSqlErr = 0;
	LET iNoRegs = 0;
	LET iIdRegistro = 0;
	LET cCuenta = '';
	LET dFechaCancelacion = NULL;
	LET cResultado = '';
	LET cStatus = '';
	LET iInTrans = 0;
	LET iRegRechazados = 0;
	LET iTotalRegs = 0;
	LET mTotalMonto = NULL;
	LET dFechaMail = NULL;
	LET mSaldo = NULL;
	LET cCodigoCancelacion = '';
	LET cTipoCancelacion = '2';
	LET cSucursal = '9250';
	LET cFolioSuc = '';
	LET iClaveCancelacion = 0;
	LET cMotivoCancelacion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cancelarcreditomasivocre.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenemos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
		WHERE lote = pLote;
		
		-- Se actualiza el estatus de los registros
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cancelacioncre
			SET status = 'P',
				fecha_proceso = current
			WHERE lote = pLote AND status = 'C';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P',
				fecha_proceso = current
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se recorre el lote
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD SELECT id_registro, cuenta, codigo_cancelacion
			INTO iIdRegistro, cCuenta, cCodigoCancelacion
			FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
			WHERE lote = pLote AND usuario = pUsuario AND status = 'P'
			
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_catalogomotivoscancelacioncre(pUsuario, pIdFuncion, '', cCodigoCancelacion)
				INTO cCodRetSp, iClaveCancelacion, cCodigoCancelacion, cMotivoCancelacion
			END FOREACH;
			
			IF cCodRetSp = '00017' THEN
				LET iClaveCancelacion = NULL;
			END IF;
			
			-- Ejecutamos la cancelación de la cuenta
			EXECUTE PROCEDURE bdicred:"informix".sp_cancelarcredito(cEmpresa, cCuenta, iClaveCancelacion, pUsuario, pUsuario, cTipoCancelacion, cSucursal) INTO cCodRetSp, cFolioSuc;
			
			IF cCodRetSp = '00000' THEN
				LET dFechaCancelacion = dFechaProc;
				LET cResultado = 'APLICADO';
				LET cStatus = 'S';
			ELSE
				LET dFechaCancelacion = NULL;
				LET cResultado = 'NO APLICADO';
				LET cStatus = 'P';
			END IF;
			
			BEGIN;
				SET ISOLATION TO DIRTY READ;
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consaldodisp(pUsuario, pIdFuncion, cCuenta, '06') INTO cCodRetSpSaldo, mSaldo;
				
				UPDATE bdicnweb:sw_tr_cargamasiva_cancelacioncre
				SET fecha_proceso = dFechaProc,
					fecha_cancelacion = dFechaCancelacion,
					resultado = cResultado,
					codret_proceso = cCodRetSp,
					folio = cFolioSuc,
					saldo = mSaldo,
					status = cStatus
				WHERE lote = pLote AND id_registro = iIdRegistro;
		
				LET iNoRegs = iNoRegs + 1;
			COMMIT WORK;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizacion de los procesados y de los que no
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iRegRechazados
		FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre
		WHERE lote = pLote AND status NOT IN ('U', 'S');
		
		BEGIN;
			INSERT INTO bdicnweb:sw_tr_cargamasiva_cancelacioncre_hist
			SELECT * FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre WHERE lote = pLote AND status = 'S';
						
			DELETE FROM bdicnweb:sw_tr_cargamasiva_cancelacioncre WHERE lote = pLote AND status = 'S';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET registros_rechazados = iRegRechazados
				, status_lote = 'T'
				, registros_aceptados = total_registros - iRegRechazados
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cancelacioncre
			SET status = 'C'
			WHERE lote = pLote AND status = 'U';
		COMMIT;
		
		-- Notificación de correo electronico
		SELECT total_registros, total_monto
		INTO iTotalRegs, mTotalMonto
		FROM sw_tr_totales_masivo
		WHERE id_funcion = pIdFuncion AND id_lote = pLote;
		
		LET dFechaMail = current;
		
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###,##&.&&"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
		
		IF iInTrans = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el pago masivo de cuentas de crédito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_cargomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE vUsuario		CHAR(10);
	DEFINE cFolioGrupo	CHAR(16);	
	DEFINE dFechaHoy    DATE;
	DEFINE cEmpresa		CHAR(3);
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(6);
	DEFINE cCodRetSpSal	CHAR(6);
	DEFINE cCodPago		CHAR(2);
	DEFINE cDescPago	CHAR(50);
	DEFINE cCodFuncion	CHAR(3);
	DEFINE cConcepto	CHAR(50);
	DEFINE cFolioGen	CHAR(16);
	DEFINE dFechaProc	DATETIME YEAR TO FRACTION;
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	-- Varibles de la tabla masiva
	DEFINE cCredito		CHAR(16);
	DEFINE mImportePago	MONEY(14,2);
	DEFINE cTransaccion	CHAR(4);
	DEFINE cResultado	CHAR(15);
	DEFINE iIdRegistro	INTEGER;
	DEFINE cStatus		CHAR(1);
	DEFINE iInTrans		INTEGER;
	DEFINE iRegRechazados	INTEGER;
	DEFINE mSaldoCuenta	MONEY(14,2);
	DEFINE iTotalRegs 	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	
	LET iSqlErr = 0;
	LET vUsuario = 'informix';
	LET cFolioGrupo = '';
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cCodRetSpSal = '';
	LET cEmpresa = '001';
	LET cCredito = '';
	LET mImportePago = NULL;
	LET cTransaccion = '';
	LET cCodPago = '';
	LET cDescPago = '';
	LET cCodFuncion	= '';
	LET cConcepto = '';
	LET cFolioGen = '';
	LET cResultado = '';
	LET dFechaProc = NULL;
	LET iIdRegistro	= 0;
	LET iNoRegs = 0;
	LET cStatus = '';
	LET iInTrans = 0;
	LET iRegRechazados = 0;
	LET mSaldoCuenta = NULL;
	LET iTotalRegs = 0;
	LET mTotalMonto	= NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;

		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN;
		END EXCEPTION WITH RESUME;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Se genera el folio
		SELECT FIRST 1 'carmas'||TO_CHAR(CURRENT, '%d%m%H%M%S')
		INTO cFolioGrupo
		FROM bdicnweb:sw_tr_cargamasiva_cargo
		WHERE lote = pLote;
		
		-- Obtenmos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:sw_tr_cargamasiva_cargo
		WHERE lote = pLote;
		
		-- Se actualiza el estatus de los registros
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo
			SET status = 'P',
				fecha_proceso = current
			WHERE lote = pLote AND status = 'C';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P',
				fecha_proceso = current
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se recorre el lote
		FOREACH WITH HOLD SELECT id_registro, cuenta, monto_importe, transaccion, descripcion1
			INTO iIdRegistro, cCredito, mImportePago, cTransaccion, cConcepto
			FROM bdicnweb:sw_tr_cargamasiva_cargo
			WHERE lote = pLote AND status = 'P'
			
			-- Obtenemos los datos de la transaccion
			FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_obtenerconceptocargomanuales(TRIM(cTransaccion),'')
				INTO cCodRetSp, cCodPago, cDescPago, cTransaccion
			END FOREACH;
			
			EXECUTE PROCEDURE bdicred:"informix".sp_grabarcargosmasivos(cEmpresa, pUsuario,   cFolioGrupo,      cCredito,      mImportePago, cTransaccion, cCodPago, TRIM(cConcepto), cDescPago)
			INTO cCodRetSp, cFolioGen;
			
				BEGIN;
				
					IF cCodRetSp <> '000000' THEN
						LET cFolioGen = '';
						LET cResultado = 'NO APLICADO';
						LET cStatus = 'P';
					ELIF cCodRetSp = '000000' THEN
						LET cResultado = 'APLICADO';
						LET cStatus = 'S';
					END IF;
					
					EXECUTE PROCEDURE bdicnweb:"informix".sp_consaldodisp(pUsuario, pIdFuncion, cCredito, '06') 
					INTO cCodRetSpSal, mSaldoCuenta;
					
					UPDATE bdicnweb:sw_tr_cargamasiva_cargo
					SET fecha_proceso = dFechaProc,
						resultado = cResultado,
						folio = cFolioGen,
						codret_proceso = cCodRetSp,
						status = cStatus,
						monto1 = mSaldoCuenta
					WHERE lote = pLote AND id_registro = iIdRegistro;
					
					LET iNoRegs = iNoRegs + 1;
				COMMIT;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizacion de los procesados y de los que no
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iRegRechazados
		FROM sw_tr_cargamasiva_cargo
		WHERE lote = pLote AND status NOT IN ('U', 'S');
		
		BEGIN;
			INSERT INTO bdicnweb:sw_tr_cargamasiva_cargo_hist(id_registro, id_funcion, fecha_carga, lote, archivo, usuario, fecha_proceso, status,
					resultado, codret_proceso, motivo_rechazo, cuenta, numcte, monto_importe, folio, transaccion,
					indicador1, indicador2, indicador3, descripcion1, descripcion2, monto1, monto2, monto3)
			SELECT id_registro, id_funcion, fecha_carga, lote, archivo, usuario, fecha_proceso, status,
					resultado, codret_proceso, motivo_rechazo, cuenta, numcte, monto_importe, folio, transaccion,
					indicador1, indicador2, indicador3, descripcion1, descripcion2, monto1, monto2, monto3 
			FROM bdicnweb:sw_tr_cargamasiva_cargo WHERE lote = pLote AND status = 'S';
						
			DELETE FROM bdicnweb:sw_tr_cargamasiva_cargo WHERE lote = pLote AND status = 'S';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET registros_rechazados = iRegRechazados
				, status_lote = 'T'
				, registros_aceptados = total_registros - iRegRechazados
				, folio_grupo = cFolioGrupo
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo
			SET status = 'C'
			WHERE lote = pLote AND status = 'U';
		COMMIT;
		
		-- Notificación de correo electronico
		SELECT total_registros, total_monto
		INTO iTotalRegs, mTotalMonto
		FROM sw_tr_totales_masivo
		WHERE id_funcion = pIdFuncion AND id_lote = pLote;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
		
		IF iInTrans = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realización de los cargos masivos a cuentas de credito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_desbloquemasivocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCodRetSpSaldo CHAR(5);
	DEFINE dFechaProc DATETIME YEAR TO SECOND;
	DEFINE cResSp CHAR(5);
	DEFINE dFechaBloqueo DATETIME YEAR TO SECOND;
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE mImporte MONEY(14,2);
	DEFINE cClaveBloq CHAR(2);
	DEFINE cOpcBloque CHAR(2);
	DEFINE cAreaSolic CHAR(2);
	DEFINE cMotivoBloq CHAR(2);
	DEFINE cClaveAreaSolic CHAR(1);
	DEFINE cTipoBloqueo CHAR(1);
	DEFINE cResultado CHAR(15);
	DEFINE cStatus CHAR(1);
	DEFINE iInTrans INTEGER;
	DEFINE iRegRechazados INTEGER;
	DEFINE mSaldoDisp MONEY(14,2);
	DEFINE mSaldoRet MONEY(14,2);
	DEFINE mSaldoCuenta MONEY(14,2);
	DEFINE cDescripcion CHAR(40);
	DEFINE mSaldoCong MONEY(14,2);
	DEFINE cClabe CHAR(18);
	DEFINE iTotalRegs INTEGER;
	DEFINE mTotalMonto MONEY(14,2);
	DEFINE dFechaMail DATETIME YEAR TO SECOND;
	DEFINE cFolio CHAR(16);
	DEFINE mSaldo MONEY(14,2);
	
	
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFechaProc = NULL;
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegs = 0;
	LET iIdRegistro = 0;
	LET cCuenta = '';
	LET mImporte = NULL;
	LET cClaveBloq = '00';
	LET cOpcBloque = '0';
	LET cAreaSolic = '';
	LET cMotivoBloq = '';
	LET cClaveAreaSolic = '';
	LET cTipoBloqueo = '';
	LET cResultado = '';
	LET cStatus = '';
	LET iInTrans = 0;
	LET iRegRechazados = 0;
	LET mSaldoDisp = NULL;
	LET mSaldoRet = NULL;
	LET mSaldoCuenta = NULL;
	LET cDescripcion = '';
	LET mSaldoCong = NULL;
	LET cClabe = '';
	LET iTotalRegs = 0;
	LET mTotalMonto = NULL;
	LET dFechaMail = NULL;
	LET cFolio = '';
	LET mSaldo = NULL;
	LET cCodRetSpSaldo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_desbloquemasivocap.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenemos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
		WHERE lote = pLote;
		
		-- Se actualiza el estatus de los registros
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
			SET status = 'P',
				fecha_proceso = current
			WHERE lote = pLote AND status = 'C';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET status_lote = 'P',
				fecha_proceso = current
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se recorre el lote
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD SELECT id_registro, cuenta, monto_importe, area_solic, motivo_bloqueo
			INTO iIdRegistro, cCuenta, mImporte, cAreaSolic, cMotivoBloq
			FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
			WHERE lote = pLote AND usuario = pUsuario AND status = 'P'

			-- Obtenemos el codigo de area solicitante
			SELECT {+INDEX(bdicheq:"informix".sc_areabloqueo index_areabloq)} codigo
			INTO cClaveAreaSolic
			FROM bdicheq:"informix".sc_areabloqueo
			WHERE TRIM(clave) = TRIM(cAreaSolic);
			
			-- Obtenemos la opcion de motivo de bloqueo
			SELECT {+INDEX(bdicheq:"informix".sc_tipobloqueo index_tipobloq)} codigo
			INTO cTipoBloqueo
			FROM bdicheq:"informix".sc_tipobloqueo
			WHERE TRIM(clave) = TRIM(cMotivoBloq);
			
			-- Consulta del saldo congelado de la cuenta
			EXECUTE PROCEDURE bdicheq:"informix".cons_sdoschq_bpi(cEmpresa, cCuenta, '') 
			INTO cCodRetSp, mSaldoDisp, mSaldoRet, mSaldoCuenta, cDescripcion, mSaldoCong, cClabe;
			
			-- Ejecutamos el bloqueo de la cuenta
			EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(cEmpresa, cCuenta, mImporte, cClaveBloq, TRIM(cOpcBloque), 
								DATE(dFechaProc), pUsuario, ' ', cAreaSolic, cClaveAreaSolic, cMotivoBloq, cTipoBloqueo)
			INTO cCodRetSp, cResSp;
			
			IF cCodRetSp = '000' THEN
				LET dFechaBloqueo = dFechaProc;
				LET cResultado = 'APLICADO';
				LET cStatus = 'S';
			ELSE
				LET dFechaBloqueo = NULL;
				LET cResultado = 'NO APLICADO';
				LET cStatus = 'P';
			END IF;
			
			BEGIN;
				SET ISOLATION TO DIRTY READ;
				-- Busqueda del folio generado
				SELECT folio_suc
				INTO cFolio
				FROM bdicheq:"informix".sc_histbloq a
				WHERE a.fecha = DATE(dFechaProc)
					AND a.cuenta = cCuenta
					AND a.tipo_mov = 'D'
					AND a.hora =(SELECT MAX(b.hora) FROM bdicheq:"informix".sc_histbloq b WHERE b.cuenta = a.cuenta 
							AND a.tipo_mov = b.tipo_mov AND b.fecha = a.fecha);
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consaldodisp(pUsuario, pIdFuncion, cCuenta, '01') INTO cCodRetSpSaldo, mSaldo;
				
				UPDATE bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
				SET fecha_proceso = dFechaProc,
					fecha_bloqueo = dFechaBloqueo,
					resultado = cResultado,
					codret_proceso = cCodRetSp,
					status = cStatus,
					folio = cFolio, 
					monto_importe = mImporte,
					saldo = mSaldo
				WHERE lote = pLote AND id_registro = iIdRegistro;
		
				LET iNoRegs = iNoRegs + 1;
			COMMIT WORK;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizacion de los procesados y de los que no
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iRegRechazados
		FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
		WHERE lote = pLote AND status NOT IN ('U', 'S');
		
		BEGIN;
			INSERT INTO bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap_hist
			SELECT * FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap WHERE lote = pLote AND status = 'S';
						
			DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap WHERE lote = pLote AND status = 'S';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET registros_rechazados = iRegRechazados
				, status_lote = 'T'
				, registros_aceptados = total_registros - iRegRechazados
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocap
			SET status = 'C'
			WHERE lote = pLote AND status = 'U';
		COMMIT;
		
		-- Notificación de correo electronico
		SELECT total_registros, total_monto
		INTO iTotalRegs, mTotalMonto
		FROM bdicnweb:"informix".sw_tr_totales_masivo
		WHERE id_funcion = pIdFuncion AND id_lote = pLote;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
		
		IF iInTrans = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el pago masivo de cuentas de crédito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_reversopagomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(6);
	DEFINE cFolioGen	CHAR(16);
	DEFINE dFechaProc	DATETIME YEAR TO FRACTION;
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	DEFINE cResultadoSp	CHAR(100);
	DEFINE cResultado	CHAR(15);
	DEFINE iIdRegistro	INTEGER;
	DEFINE cStatus		CHAR(1);
	DEFINE wBegin		SMALLINT;
	DEFINE iReversar 	SMALLINT;
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	DEFINE iTotalRegs	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE iTotalRever	INTEGER;
	DEFINE iTotNoRever	INTEGER;
	
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cFolioGen = '';
	LET cResultado = '';
	LET dFechaProc = NULL;
	LET iIdRegistro	= 0;
	LET iNoRegs = 0;
	LET cStatus = '';
	LET cResultadoSp = '';
	LET wBegin = 0;
	LET iReversar = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535)
			LET wBegin = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenmos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:sw_tr_cargamasiva_pago_hist
		WHERE lote = pLote;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se coloca el estatus de todos los movimientos para ser reversados
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_pago_hist
			SET status = 'R'
			WHERE status = 'S' and lote = pLote;
		COMMIT;
		
		-- Se recorre el lote
		FOREACH WITH HOLD SELECT id_registro, folio
			INTO iIdRegistro, cFolioGen
			FROM bdicnweb:sw_tr_cargamasiva_pago_hist
			WHERE lote = pLote AND status = 'R'
			
			BEGIN;
				EXECUTE PROCEDURE bdicred:"informix".sp_grabarreversopagosmasivos(cFolioGen)
				INTO cCodRetSp, cResultadoSp;
			COMMIT;
			
			IF cCodRetSp <> '000000' THEN
				LET cResultado = 'NO REVERSADO';
				LET cStatus = 'S';
			ELIF cCodRetSp = '000000' THEN
				LET cResultado = 'REVERSADO';
				LET cStatus = 'R';
			END IF;
			
			BEGIN;
				UPDATE bdicnweb:sw_tr_cargamasiva_pago_hist
				SET fecha_reverso = dFechaProc,
					resultado_reverso = cResultado,
					codret_reverso = cCodRetSp,
					status = cStatus,
					comentario_reverso = cResultadoSp
				WHERE lote = pLote AND id_registro = iIdRegistro;
				
				LET iNoRegs = iNoRegs + 1;
			COMMIT;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizamos los estatus a incativos
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_pago_hist
			SET status = 'I'
			WHERE codret_reverso <> '000000'
				AND lote = pLote;
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_pago_hist
			SET status = 'I'
			WHERE codret_reverso = '000000'
				AND lote = pLote;
		COMMIT;
			
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_pago_hist
			SET status = 'S', resultado = 'APLICADO'
			WHERE lote = pLote AND status = 'NP';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'T'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_constotalesreversopagocre(pUsuario, pIdFuncion, pLote)
		INTO cCodRetSp, iTotalRegs, mTotalMonto, iTotalRever, iTotNoRever;
		
		IF cCodRetSp <> '00000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, iNoRegs;
		END IF;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
		
		
		IF wBegin = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el reverso de los pagos masivos de credito de la aplicación CNWEB";

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