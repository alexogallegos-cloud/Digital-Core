CREATE PROCEDURE "informix".sp_respalda_ss_detalle_modelo()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cMensaje 		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE vrowid           INTEGER;
DEFINE VlNumCredito     CHAR(20);
DEFINE iCont			INTEGER;
DEFINE cValor			CHAR(1);
DEFINE dFecha			DATE;	
DEFINE cSql 			CHAR(1000);

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';
	LET cSql 		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		delete from bdicred:"informix".temp_creditos_depurar3;
		update bdicred:"informix".sd_param set valor = '0'
		where empresa = '001' and cod_param = 'DT3';
		LET cSql = '';
		LET cSql = 'echo "" >> /RESPALDOSNEW/instruccion1.sql';
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	--SET DEBUG FILE TO "/RESPALDOSNEW/sp_respalda_ss_detalle_modelo.out";
    --TRACE ON; 
	
	select trim(valor) into cValor 
	from bdicred:"informix".sd_param 
	where empresa = '001' and cod_param = 'DT3';

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from bdicred:"informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdicred:"informix".temp_creditos_depurar3;

	if iCont = 0 and cValor = '0' then

		insert into bdicred:"informix".temp_creditos_depurar3
		select num_solicitud 
		from "informix".ss_solicitudes
		where empresa = '001';

		update bdicred:"informix".sd_param set valor = '1'
		where empresa = '001' and cod_param = 'DT3';

	else

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

	--DESCARGA EL RESPALDO
	LET cSql = '';
	LET cSql = 'echo "unload to /RESPALDOSNEW/respaldo_ss_detalle_modelo_resp.unl' || ' select * FROM "informix".ss_detalle_modelo WHERE empresa = "001" and num_solicitud in (select num_credito from bdicred:"informix".temp_creditos_depurar3 ) and fecha_insert <= MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ')" >> /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'dbaccess bdisolic /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	-- CARGA EN LA TABLA ESPEJO
	LET cSql = '';
	LET cSql = 'dbload -d bdisolic -c /ifxsif01/scripts/pro_206_13_5_respaldo_detalle_modelo.sql -l adviser.log -n 1000 -k';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'chmod 777 /RESPALDOSNEW/respaldo_ss_detalle_modelo_resp.unl';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/respaldo_ss_detalle_modelo_resp.unl';
	SYSTEM cSql;

	RETURN cCod_ret;

	END;

END PROCEDURE;