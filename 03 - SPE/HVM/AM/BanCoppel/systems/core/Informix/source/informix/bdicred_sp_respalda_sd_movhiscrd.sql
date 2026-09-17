CREATE PROCEDURE "informix".sp_respalda_sd_movhiscrd()
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

	--SET DEBUG FILE TO "/RESPALDOSNEW/sp_respalda_sd_movhiscrd_trace.out";
    --TRACE ON; 

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
		truncate table temp_creditos_depurar2;
		update "informix".sd_param set valor = '0'
		where empresa = '001' and cod_param = 'DT2';
		LET cSql = '';
		LET cSql = 'echo "" >> /RESPALDOSNEW/instruccion1.sql';
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT2';

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar2;

	if iCont = 0 and cValor = '0' then

		insert into "informix".temp_creditos_depurar2
		select num_credito 
		from bdicred:"informix".sd_maecred
		where empresa = '001';

		update "informix".sd_param set valor = '1'
		where empresa = '001' and cod_param = 'DT2';

	else

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

	--DESCARGA EL RESPALDO
	LET cSql = '';
	LET cSql = 'echo "unload to /RESPALDOSNEW/respaldo_sd_movhiscrd.unl' || ' select * FROM bdicred:"informix".sd_movhiscrd WHERE empresa = "001" and num_credito in (select num_credito from "informix".temp_creditos_depurar2 ) and fecha_mov <= MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ')" >> /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'dbaccess bdicred /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	-- CARGA EN LA TABLA ESPEJO
	LET cSql = '';
	LET cSql = 'dbload -d bdicred -c /ifxsif01/scripts/pro_206_15_15_respaldo_movhiscrd.sql -l adviser.log -n 1000 -k';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'chmod 777 /RESPALDOSNEW/respaldo_sd_movhiscrd.unl';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/respaldo_sd_movhiscrd.unl';
	SYSTEM cSql;

	RETURN cCod_ret;

	END;

END PROCEDURE;