CREATE PROCEDURE "informix".sp_depura_sd_movhis_new()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_movhis_new_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT1';

	select date((pri_dia_mes - 2 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT1';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis_new 
			WHERE empresa = '001' and  num_credito = VlNumCredito and fecha_mov <= dFecha;
			delete from "informix".temp_creditos_depurar where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT1';

	RETURN cCod_ret;

	END;

END PROCEDURE;