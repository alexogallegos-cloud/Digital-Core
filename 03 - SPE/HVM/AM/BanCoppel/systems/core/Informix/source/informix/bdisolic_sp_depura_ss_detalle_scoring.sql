CREATE PROCEDURE "informix".sp_depura_ss_detalle_scoring()
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
DEFINE dFechat  	date;
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_detalle_edoctacrd_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';
    LET VlNumCredito = '';
    let dFechat  	= null;

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;


    select date(num_credito) 
    into dFechat
    from bdicred:"informix".sd_param_movhis_dep  
    where proceso = 15;

    IF dFechat IS NULL THEN 
       LET dFechat = date(1); 
       INSERT INTO bdicred:"informix".sd_param_movhis_dep VALUES(15,dFechat);
    END IF;


    FOREACH WITH HOLD

        select num_solicitud
		into VlNumCredito  
        from bdisolic:ss_solicitudes 
        where fecha_insert < mdy(month(today),1,year(today)) - 11 units month
          and fecha_insert >= dFechat
        order by fecha_insert

		BEGIN WORK;

            insert into bdisolic:ss_detalle_scoring_2021
            select * from bdisolic:ss_detalle_scoring where empresa = '001' and num_solicitud = VlNumCredito;

            DELETE from bdisolic:ss_detalle_scoring where empresa = '001' and num_solicitud = VlNumCredito;

            update bdicred:"informix".sd_param_movhis_dep set num_credito = dFechat where proceso = 15;

		COMMIT WORK;

	END FOREACH;


	RETURN cCod_ret;

	END;

END PROCEDURE;