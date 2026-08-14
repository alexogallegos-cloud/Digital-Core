CREATE PROCEDURE "informix".sp_depura_ss_detalle_scoring_rechazo()
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

	--SET DEBUG FILE TO "/resplogifx/archivoscartera/Cut/sp_depura_ss_detalle_scoring_rechazo.out";
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
	from bdicred:"informix".sd_param 
	where empresa = '001' and cod_param = 'DT8';

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from bdicred:"informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdicred:"informix".temp_creditos_depurar8;

	if iCont > 0 and cValor = '1' then

		update bdicred:"informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT8';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from bdicred:"informix".temp_creditos_depurar8

		BEGIN WORK;

			DELETE FROM "informix".ss_detalle_scoring_rechazo 
			WHERE empresa = '001' and  num_solicitud = VlNumCredito and fecha_insert <= dFecha;
			delete from bdicred:"informix".temp_creditos_depurar8 where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update bdicred:"informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT8';

	RETURN cCod_ret;

	END;

END PROCEDURE;