CREATE PROCEDURE "informix".sp_rpt_saldos_cierre_dia()
RETURNING CHAR(5) AS cod_ret, CHAR(100) AS msj_ret;
--VARIABLES DE CONTROL DE ERROR
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iPasoErr   INTEGER;
DEFINE cCod_ret	  CHAR(5);
DEFINE cMsj_ret	  CHAR(100);
--VARIABLES DE ARCHIVOS
DEFINE cCmd		  CHAR(2000);
DEFINE cRuta 	  CHAR(29);
DEFINE cPrefijo   CHAR(14);
DEFINE cExtension CHAR(4);
DEFINE cArchivo1   CHAR(55);
DEFINE cArchivo2   CHAR(55);
DEFINE cConsulta  CHAR(1500);
DEFINE dFechaAnt  DATE;
DEFINE cDia		  CHAR(2);
DEFINE cMes		  CHAR(2);
DEFINE cAno		  CHAR(4);
DEFINE cFechaRpt  CHAR(8);
DEFINE cFechaInf  CHAR(8);

LET iPasoErr = 0;
LET cCod_ret = '';
LET cMsj_ret = '';
LET cCmd = '';
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET cFechaRpt = '';
LET cRuta = '/RESPALDOSNEW/SaldosCierreCG/';
LET cExtension = '.txt';
LET cArchivo1 = '';
LET cArchivo2 = '';

--SET DEBUG FILE TO "/ifxsif01/jepolanco/sp_rpt_saldos_cierre_dia.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				RETURN iSqlErr, iIsamErr||' En paso: '||iPasoErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
		SELECT fecha_ant INTO dFechaAnt FROM bdinteg:"informix".si_fechas;
		LET cDia = LPAD(DAY(dFechaAnt), 2, '0');
		LET cMes = LPAD(MONTH(dFechaAnt), 2, '0');
		LET cAno = YEAR(dFechaAnt);
		
		--DA FORMATO 'AAAAMMDD' A LA FECHA
		LET cFechaRpt = cAno||cMes||cDia;
		LET cFechaInf = cMes||cDia||cAno;

		LET iPasoErr = 1;
		LET cPrefijo = 'Saldos_Caja_';
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo1 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cExtension);
		LET cArchivo2 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);
		LET cConsulta = '';
		LET cConsulta = 'SELECT TO_CHAR('||"'"||cFechaInf||"'"||'::DATE, '||"'"||'%d-%m-%Y'||"'"||'), cg.cod_proveedor, UPPER(TRIM(pro.descripcion)), ROUND(saldo_total,2), cantidad_1::INTEGER, cantidad_2::INTEGER, cantidad_3::INTEGER, cantidad_4::INTEGER, cantidad_5::INTEGER, cantidad_6::INTEGER, ROUND(cantidad_7,2), 0 FROM bdisuc:"informix".ss_cajageneral cg INNER JOIN bdisuc:"informix".ss_proveedores pro ON cg.cod_proveedor = pro.cod_proveedor;';
		LET cCmd= '';
		LET cCmd= 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchivo1)||" DELIMITER ',' "||TRIM(cConsulta)||' " >> '||TRIM(cRuta)||'unload_saldos_caja.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 2;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'unload_saldos_caja.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 3;
		LET cCmd = '';
		LET cCmd = 'awk '||"'"||'gsub(",$","")'||"' "||TRIM(cArchivo1)||' >> '||TRIM(cArchivo2);
		SYSTEM cCmd;
		
		LET iPasoErr = 4;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'unload_saldos_caja.sql '||TRIM(cArchivo1);
		SYSTEM cCmd;
		
		LET iPasoErr = 5;
		LET cPrefijo = 'ATMS_sucursal_';
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo1 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cExtension);
		LET cArchivo2 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);
		LET cConsulta = '';
		LET cConsulta = 'SELECT sdo.sucursal, TRIM(rel.id), TO_CHAR(sdo.fecha, '||"'"||'%d-%m-%Y'||"'"||'), saldo_total::INTEGER, cantidad_2::INTEGER, cantidad_3::INTEGER, cantidad_4::INTEGER, cantidad_5::INTEGER FROM bdisuc:"informix".ss_saldossuc sdo INNER JOIN bdisuc:"informix".ss_relacionccid rel ON sdo.sucursal = rel.cc WHERE sdo.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = '||"'"||'C'||"'"||' AND plaza_cajagen IS NOT NULL AND sucursal NOT IN (SELECT cod_atm FROM bdisuc:"informix".ss_atms_sucursal)) AND sdo.fecha = ' ||"'"||cFechaInf||"'"||';';
		LET cCmd= '';
		LET cCmd= 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchivo1)||" DELIMITER ',' "||TRIM(cConsulta)||' " >> '||TRIM(cRuta)||'unload_sucursales.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 6;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'unload_sucursales.sql';
		SYSTEM cCmd;

		LET iPasoErr = 7;
		LET cCmd = '';
		LET cCmd = 'awk '||"'"||'gsub(",$","")'||"' "||TRIM(cArchivo1)||' >> '||TRIM(cArchivo2);
		SYSTEM cCmd;
		
		LET iPasoErr = 8;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'unload_sucursales.sql '||TRIM(cArchivo1);
		SYSTEM cCmd;
		
		
		LET iPasoErr = 9;
		LET cPrefijo = 'Sucursales_';
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo1 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cExtension);
		LET cArchivo2 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);
		LET cConsulta = '';
		LET cConsulta = 'SELECT LTRIM(sdo.sucursal,'||"'"||'0'||"'"||'), TO_CHAR(sdo.fecha, '||"'"||'%d-%m-%Y'||"'"||'), ret.retiros, dep.depositos, ROUND(sdo.saldo_total,2), (sdo.cantidad_1*1000), (sdo.cantidad_2*500), (sdo.cantidad_3*200), (sdo.cantidad_4*100), (sdo.cantidad_5*50), (sdo.cantidad_6*20), ROUND(sdo.cantidad_7,2) FROM bdisuc:"informix".ss_saldossuc sdo LEFT OUTER JOIN (SELECT his.sucursal, SUM(his.monto_tot) AS retiros FROM bdicheq:"informix".sc_movhis his INNER JOIN bdinteg:"informix".si_transacc tra ON his.transacc = tra.numero WHERE his.cancelad <> '||"'"||'S'||"'"||' AND his.fech_alt = '||"'"||cFechaInf||"'"||' AND tra.naturaleza = '||"'"||'C'||"'"||' AND tra.sistema = '||"'"||'01'||"'"||' GROUP BY his.sucursal) ret ON sdo.sucursal = ret.sucursal LEFT OUTER JOIN (SELECT his.sucursal, SUM(his.monto_tot) AS depositos FROM bdicheq:"informix".sc_movhis his INNER JOIN bdinteg:"informix".si_transacc tra ON his.transacc = tra.numero WHERE his.cancelad <> '||"'"||'S'||"'"||' AND his.fech_alt = '||"'"||cFechaInf||"'"||' AND tra.naturaleza = '||"'"||'A'||"'"||' AND tra.sistema = '||"'"||'01'||"'"||' GROUP BY his.sucursal) dep ON sdo.sucursal = dep.sucursal WHERE sdo.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = '||"'"||'S'||"'"||' OR tipo = '||"'"||'S'||"'"||') AND sdo.fecha = '||"'"||cFechaInf||"'"||';';
		LET cCmd= '';
		LET cCmd= 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchivo1)||" DELIMITER ',' "||TRIM(cConsulta)||' " >> '||TRIM(cRuta)||'unload_atms_sucursal.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 10;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'unload_atms_sucursal.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 11;
		LET cCmd = '';
		LET cCmd = 'awk '||"'"||'gsub(",$","")'||"' "||TRIM(cArchivo1)||' >> '||TRIM(cArchivo2);
		SYSTEM cCmd;
		
		LET iPasoErr = 12;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'unload_atms_sucursal.sql '||TRIM(cArchivo1);
		SYSTEM cCmd;
		
		
		LET iPasoErr = 13;
		LET cPrefijo = 'Depositadores_';
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo1 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cExtension);
		LET cArchivo2 = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);
		LET cConsulta = '';
		LET cConsulta = 'SELECT atm.id_atm, TO_CHAR('||"'"||cFechaInf||"'"||'::DATE, '||"'%d-%m-%Y'"||'), NVL(ret.retiros,0), NVL(dep.depositos,0) FROM bdisuc:"informix".ss_atms_depositadores atm LEFT OUTER JOIN (SELECT idterminal, SUM(retiros) AS retiros FROM (SELECT SUBSTR(referencia, 16, 6) AS idterminal, SUM(monto_tot) AS retiros FROM bdicheq:"informix".sc_movhis WHERE transacc = '||"'"||'0952'||"'"||' AND cancelad <> '||"'"||'S'||"'"||' AND fech_alt = '||"'"||cFechaInf||"'"||' GROUP BY idterminal UNION ALL SELECT mov.idterminal, SUM(mov.monto) AS retiros FROM bdicred:"informix".sd_movhis his INNER JOIN intercard:movimiento mov ON his.folio_suc = '||"'"||'i'||"'"||'||mov.secuenciaextendida AND his.nro_tarjeta = mov.numtarjeta WHERE transacc_suc = '||"'"||'6952'||"'"||' AND reversado <> '||"'"||'S'||"'"||' AND fecha_mov = '||"'"||cFechaInf||"'"||' GROUP BY mov.idterminal) GROUP BY idterminal) ret ON atm.id_atm = ret.idterminal LEFT OUTER JOIN (SELECT SUBSTR(usuario, 3, 6) AS id_atm, SUM(monto_tot) AS depositos FROM bdicheq:"informix".sc_movhis WHERE transacc = '||"'"||'0318'||"'"||' AND fech_alt = '||"'"||cFechaInf||"'"||' GROUP BY id_atm) dep ON atm.id_atm = dep.id_atm;';
		LET cCmd= '';
		LET cCmd= 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchivo1)||" DELIMITER ',' "||TRIM(cConsulta)||' " >> '||TRIM(cRuta)||'unload_depositadores.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 14;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'unload_depositadores.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 15;
		LET cCmd = '';
		LET cCmd = 'awk '||"'"||'gsub(",$","")'||"' "||TRIM(cArchivo1)||' >> '||TRIM(cArchivo2);
		SYSTEM cCmd;
		
		LET iPasoErr = 16;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'unload_depositadores.sql '||TRIM(cArchivo1);
		SYSTEM cCmd;
		
		LET cCod_ret = '00000';
		LET cMsj_ret = 'REPORTES DE SALDOS AL CIERRE DEL DÃA '||cFechaRpt||' GENERADOS';
		RETURN cCod_ret, cMsj_ret;
		
	END;
END PROCEDURE;