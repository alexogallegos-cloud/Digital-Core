CREATE PROCEDURE "informix".sp_generaarchivoconciliacion(psNumEmpleado CHAR (8))
RETURNING
	CHAR(5); ---cod_ret
	
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(95);
	DEFINE vsRepositorio 		CHAR(100);
	DEFINE vsArchivo			CHAR(21);
	DEFINE vsSQL				CHAR (2204);
	DEFINE vsSQL1				CHAR(100);
	DEFINE vsSQL2 				CHAR(1004);
	DEFINE vsSQL3 				CHAR(100);
	DEFINE vsSQL4				CHAR(100);
	DEFINE v_Terminal			CHAR(4);
	DEFINE v_FechaConciliacion	DATETIME YEAR TO FRACTION (5);
	DEFINE v_Monto				MONEY(16,6);
	DEFINE v_MontoComision		MONEY(16,6);
	DEFINE v_MontoIva			MONEY(16,6);
	DEFINE v_TotReg				INTEGER;
	DEFINE v_ComisionTCD		DECIMAL(16,6);
	DEFINE v_ComisionTCC		DECIMAL(16,6);
	DEFINE v_IVATCD				DECIMAL(16,6);
	DEFINE v_IVATCC				DECIMAL(16,6);
	DEFINE v_cod_ret2			CHAR(5);
	DEFINE v_BandBA				CHAR(1);
	DEFINE vsMensaje			CHAR (500);
	DEFINE viBitacora			INTEGER;

	---INICIALIZACIONES
	LET v_cod_ret 				= '00000';
	LET sDescMensajeError		= "";
	LET vsRepositorio 			= "";
	LET vsArchivo = 'concitarj'||REPLACE (SUBSTRING (CURRENT::DATE - 1 FROM 1 FOR 10), '/', '' )||'.txt';
	LET vsSQL					= "";
	LET vsSQL1					= "";
	LET vsSQL2 					= "";
	LET vsSQL3 					= "";
	LET vsSQL4					= "";
	LET v_Terminal				= "";
	LET v_FechaConciliacion		= MDY(1,1,1900);
	LET v_Monto					= 0.0;
	LET v_MontoComision			= 0.0;
	LET v_MontoIva				= 0.0;
	LET v_TotReg				= 0;
	LET v_ComisionTCD			= 0.0;
	LET v_ComisionTCC			= 0.0;
	LET v_IVATCD				= 0.0;
	LET v_IVATCC				= 0.0;
	LET v_cod_ret2				= "00000";
	LET v_BandBA				= "";
	LET vsMensaje 				= '';
	LET viBitacora 				= 0;

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
		LET vsMensaje = '(' || v_cod_ret || ') ERROR NO CONTROLADO INFORMIX';
		
		EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora ( psNumEmpleado, 'GAC', 'GENARCH CONCITARJ', vsMensaje) INTO viBitacora;
		
        RETURN v_cod_ret;
    END EXCEPTION;

	
	---SET DEBUG FILE TO "/tmp/has/sp_generaarchivoconciliacion.out";
	----TRACE ON;
	
	--VALIDACION DE TABLAS TEMPORALES
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_conciliacion' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:tmp_conciliacion;
	END IF;
	CREATE TABLE intercard:tmp_conciliacion(
		keyx SERIAL,
		IdTerminal CHAR(4),
		Fechamov DATETIME YEAR TO FRACTION(5),
		Monto MONEY(16,6),
		Comision MONEY(16,6),
		ComisionIva MONEY(16,6)
	);
	
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_conciliacion2' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:tmp_conciliacion2;
	END IF;
	CREATE TABLE intercard:tmp_conciliacion2(
		keyx SERIAL,
		IdTerminal CHAR(4),
		Fechamov DATETIME YEAR TO FRACTION(5),
		Monto MONEY(16,6),
		Comision MONEY(16,6),
		ComisionIva MONEY(16,6)
	);
	
	--- OBTENER EL PARAMETRO DEL VALOR DE LA COMISION DE TARJETA COPPEL DEBITO EN MN
	SELECT TRIM(valor)
	INTO v_ComisionTCD
	FROM param_conciliacionauto 
	WHERE descripcion = "COMISION TARJETA COPPEL DEBITO";

	--- OBTENER EL PARAMETRO DEL PORCENTAJE DE LA COMISION DE TARJETA COPPEL CREDITO
	SELECT TRIM(valor)
	INTO v_ComisionTCC
	FROM param_conciliacionauto 
	WHERE descripcion = "% COMI. TARJETA COPPEL CREDITO";
	
	LET v_ComisionTCC = v_ComisionTCC / 100;
	
	--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL DEBITO 
	SELECT TRIM(valor)
	INTO v_IVATCD
	FROM  param_conciliacionauto 
	WHERE descripcion = "% IVA TARJETA COPPEL DEBITO";
	
	--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL CREDITO 
	SELECT TRIM(valor)
	INTO v_IVATCC
	FROM  param_conciliacionauto 
	WHERE descripcion = "% IVA TARJETA COPPEL CREDITO";
	
	--- BARRIDO DE MOVIMIENTOS
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		---- MOVIMIENTOS TARJETA COPPEL DEBITO CON COMISION
		SELECT --{+INDEX(intercard:log_pos idx_log_pos1)} {+INDEX(bditarjeta:td_conposvnd idx_td_conposvnd1)} 
		SUBSTR(lp.idterminal,1,4) AS idterminal, vnd.fecha AS fecha, SUM(lp.monto + lp.montocashback) AS monto, SUM(v_ComisionTCD) AS montocomision, SUM(v_ComisionTCD * (v_IVATCD / 100)) AS montoiva
		INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
		FROM intercard: log_pos lp, bditarjeta: td_conposvnd vnd
		WHERE lp.fechaconciliacion BETWEEN TODAY AND TODAY + 1
		AND lp.archivoorigen = "TCD"
		AND (lp.codigoiso = "00" OR TRIM(lp.codigoiso) = "")
		AND lp.numtarjeta = vnd.cuenta
		AND SUBSTR(lp.registrocentral1,15,15) = vnd.folio_mov 
		AND SUBSTR(vnd.archivo,1,3) = "TCD"
		AND vnd.fecha = today
		AND vnd.cod_retorno::INT = 0
		GROUP BY lp.idterminal, vnd.fecha
		
		INSERT INTO intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
		VALUES (v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva);
	END FOREACH
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		---- MOVIMIENTOS TARJETA COPPEL DEBITO SIN COMISION
		SELECT --{+INDEX(intercard:log_pos idx_log_pos1)} {+INDEX(bditarjeta:td_conposvnd idx_td_conposvnd1)} 
		SUBSTR(lp.idterminal,1,4) AS idterminal, vnd.fecha AS fecha, SUM(lp.monto + lp.montocashback) AS monto, 0, 0
		INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
		FROM intercard: log_pos lp, bditarjeta: td_conposvnd vnd
		WHERE lp.fechaconciliacion BETWEEN TODAY AND TODAY + 1
		AND lp.archivoorigen = "TCD"
		AND (lp.codigoiso = "00" OR TRIM(lp.codigoiso) = "")
		AND lp.numtarjeta = vnd.cuenta
		AND SUBSTR(lp.registrocentral2,15,15) = vnd.folio_mov
		AND SUBSTR(vnd.archivo,1,3) = "TCD"
		AND vnd.fecha = today
		AND vnd.cod_retorno::INT = 0
		GROUP BY lp.idterminal, vnd.fecha
		
		INSERT INTO intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
		VALUES (v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva);
	END FOREACH
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		---- MOVIMIENTOS TARJETA COPPEL CREDITO CON COMISION
		SELECT --{+INDEX(intercard:log_pos idx_log_pos1)} {+INDEX(bditarjeta:td_conposvnc idx_td_conposvnc1)} 
		SUBSTR(lp.idterminal,1,4), vnc.fecha, SUM(lp.monto + lp.montocashback), SUM(v_ComisionTCC * (lp.monto + lp.montocashback)), SUM((v_ComisionTCC * (lp.monto + lp.montocashback)) * (v_IVATCC/100))
		INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
		FROM intercard: log_pos lp, bditarjeta: td_conposvnc vnc
		WHERE lp.fechaconciliacion BETWEEN TODAY AND TODAY + 1
		AND lp.archivoorigen = "TCC"
		AND (lp.codigoiso = "00" OR TRIM(lp.codigoiso) = "")
		AND lp.numtarjeta = vnc.cuenta
		AND SUBSTR(lp.registrocentral1,15,15) = vnc.folio_mov
		AND SUBSTR(vnc.archivo,1,3) = "TCC"
		AND vnc.fecha = today
		AND vnc.cod_retorno::INT = 0
		GROUP BY lp.idterminal, vnc.fecha
	
		INSERT INTO intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
		VALUES (v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva);
	END FOREACH
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		---- MOVIMIENTOS TARJETA COPPEL CREDITO SIN COMISION
		SELECT --{+INDEX(intercard:log_pos idx_log_pos1)} {+INDEX(bditarjeta:td_conposvnc idx_td_conposvnc1)} 
		SUBSTR(lp.idterminal,1,4), vnc.fecha, SUM(lp.monto + lp.montocashback), 0, 0
		INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
		FROM intercard: log_pos lp, bditarjeta: td_conposvnc vnc
		WHERE lp.fechaconciliacion BETWEEN TODAY AND TODAY + 1
		AND lp.archivoorigen = "TCC"
		AND (lp.codigoiso = "00" OR TRIM(lp.codigoiso) = "")
		AND lp.numtarjeta = vnc.cuenta
		AND SUBSTR(lp.registrocentral2,15,15) = vnc.folio_mov
		AND SUBSTR(vnc.archivo,1,3) = "TCC"
		AND vnc.fecha = today
		AND vnc.cod_retorno::INT = 0
		GROUP BY lp.idterminal, vnc.fecha
	
		INSERT INTO intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
		VALUES (v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva);
	END FOREACH
	
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT idterminal,fechamov,SUM(monto),SUM(comision),SUM(comisioniva)
		INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
		FROM tmp_conciliacion
		GROUP BY idterminal,fechamov
		
		INSERT INTO intercard:tmp_conciliacion2(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
		VALUES (v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva);
	END FOREACH
	
	---  SE ACTUALIZA LA FECHA DE LOS MOVIMIENTOS A UN DIA ANTERIOR AL DE LA FECHA DE HOY
	UPDATE intercard:tmp_conciliacion2
	SET fechamov = TODAY - 1;
	
	SELECT COUNT(*)
	INTO v_TotReg
	FROM intercard:tmp_conciliacion2;
	
	INSERT INTO intercard:tmp_conciliacion2(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
	VALUES ("0000", TODAY - 1, v_TotReg, 0.0, 0.0);
	
	---OBTIENE REPOSITORIO.
	SELECT TRIM(valor) INTO vsRepositorio FROM intercard:param_conciliacionauto WHERE descripcion = 'generaarchivoconciliacion';
	
	 --GENERA EL ARCHIVO DE INTERCAMBIO 
	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio)||'/tmp_concitarj.txt DELIMITER ' || '''?''';
    LET vsSQL2 = "select TRIM(idterminal) || '|' || TRIM(lpad(month(fechamov),2,'0') || '/' || lpad(day(fechamov),2,'0') || '/' ||" 
    || " year(fechamov)) || '|' || TRIM(REPLACE (SUBSTRING (monto FROM 1 FOR 20), '$','')) || '|' ||"
	|| " TRIM(REPLACE (SUBSTRING (comision FROM 1 FOR 20), '$',''))|| '|' || TRIM(REPLACE (SUBSTRING (comisioniva FROM 1 FOR 20), '$', '')) "
    || " from intercard:tmp_conciliacion2 order by keyx";
	LET vsSQL3 = '">'||TRIM(vsRepositorio)||'/tmp_consiliacion.sql';
	
	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				
	IF ( vsSQL <> '' ) THEN 
		SYSTEM vsSQL ;
		LET vsSQL4 = '' ;
		LET vsSQL4= 'dbaccess intercard ' || TRIM(vsRepositorio) ||'/tmp_consiliacion.sql';
		SYSTEM vsSQL4;
	END IF;

	LET vsSQL4 = '' ;
	LET vsSQL4 =  "rem_signo.sh";
	SYSTEM vsSQL4;
	
	EXECUTE PROCEDURE intercard:sp_con_buscararchivo(TRIM(vsRepositorio), TRIM(vsArchivo))
	INTO v_cod_ret2,v_BandBA;
	
	IF v_cod_ret2 <> "00000" THEN
		--RETURN "00001";
		LET v_cod_ret = "00001";
		LET vsMensaje = '(' || v_cod_ret || ') Error en sp_con_buscararchivo (' || vsRepositorio || ', ' || vsArchivo || ')';
	ELIF v_cod_ret2 = "00000" AND v_BandBA = "F" THEN
		--RETURN "00002";
		LET v_cod_ret = "00002";
		LET vsMensaje = '(' || v_cod_ret || ') No se encontro el archivo ' || vsArchivo || ' en la ruta: ' || vsRepositorio;
	ELIF v_cod_ret2 = "00000" AND v_BandBA = "V" THEN
		--RETURN v_cod_ret;
		LET v_cod_ret = v_cod_ret;
		LET vsMensaje = '';
	END IF
	
	EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora ( psNumEmpleado, 'GAC', 'GENARCH CONCITARJ', vsMensaje) INTO viBitacora;
	
	RETURN v_cod_ret;
END;
--##############################################################################
--## Procedimiento   : sp_generaarchivoconciliacion
--## Base de Datos   : Intercard
--## Version         : 1.0
--## Creado por      : Mohamed Carreón 
--## Fecha creacion  : 28 Octubre de 2009
--##Descripcion : Procedimiento de obtiene los movimientos de tarjeta coppel credito y debito.
--##############################################################################
END PROCEDURE;