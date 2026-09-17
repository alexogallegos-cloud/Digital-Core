CREATE PROCEDURE "informix".sp_respalda_bitacora_bpi()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cMensaje 		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_ret2         CHAR(6);
DEFINE vrowid           INTEGER;
DEFINE VlNumCredito     CHAR(20);
DEFINE iCont			INTEGER;
DEFINE cValor			CHAR(1);
DEFINE dFecha			DATE;	
DEFINE cSql 			CHAR(1000);

	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_respalda_bitacora_bpi.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET cCod_ret2    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';
	LET cSql 		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		truncate table temp_bpi_bitacora_depurar;
		update bdibpi:"informix".bpi_param set valor = '0'
		where id_param = '19';
		LET cSql = '';
		LET cSql = 'echo "" >> /RESPALDOSNEW/instruccionbpi.sql';
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from bdibpi:"informix".bpi_param
	where id_param = '19';

	select date(fecha_hoy - 1 units day) into dFecha 
	from bdicheq:"informix".sc_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdibpi:"informix".temp_bpi_bitacora_depurar;

	if iCont = 0 and cValor = '0' then

		insert into bdibpi:"informix".temp_bpi_bitacora_depurar
		select id_oper 
		from bdibpi:"informix".bpi_cat_operaciones;

		update bdibpi:"informix".bpi_param set valor = '1'
		where id_param = '19';

	else

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

	--DESCARGA EL RESPALDO
	LET cSql = '';
	LET cSql = 'echo "unload to /RESPALDOSNEW/respaldo_bpi_bitacora.unl' || ' select * FROM bdibpi:"informix".bpi_bitacora WHERE id_operacion in (select id_oper from bdibpi:"informix".temp_bpi_bitacora_depurar ) and EXTEND(fecha_oper,YEAR to day) <= MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ')" >> /RESPALDOSNEW/instruccionbpi.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'dbaccess bdibpi /RESPALDOSNEW/instruccionbpi.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/instruccionbpi.sql';
	SYSTEM cSql;
	-- CARGA EN LA TABLA ESPEJO
	LET cSql = '';
	LET cSql = 'dbload -d bdibpi -c /ifxsif01/scripts/pro_677_depuracion_bitacora_bpi.sql -l adviserbpi.log -n 1000 -r'; 
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'chmod 777 /RESPALDOSNEW/respaldo_bpi_bitacora.unl';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/respaldo_bpi_bitacora.unl';
	SYSTEM cSql;

	EXECUTE PROCEDURE bdibpi:"informix".sp_depura_bitacora_bpi() INTO cCod_ret2;
	if cCod_ret2='000001' THEN
		LET cCod_ret='000002'; --Fallo el eliminado a la tabla bpi_bitacora
	end if;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;