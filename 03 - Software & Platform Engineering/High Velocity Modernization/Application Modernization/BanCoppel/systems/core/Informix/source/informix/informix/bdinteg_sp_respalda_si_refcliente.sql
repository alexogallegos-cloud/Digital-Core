CREATE PROCEDURE "informix".sp_respalda_si_refcliente()
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
		truncate table tmp_ref_cliente;
		LET cSql = '';
		LET cSql = 'echo "" >> /RESPALDOSNEW/instruccion1.sql';
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	--SET DEBUG FILE TO "/RESPALDOSNEW/sp_respalda_si_refcliente.out";
    --TRACE ON; 

	select count(*) 
	into iCont
	from tmp_ref_cliente;

	if iCont = 0 then

		--DESCARGA EL PIVOTE
		LET cSql = '';
		LET cSql = 'echo "unload to /RESPALDOSNEW/tmp_ref_cliente.unl' || ' select numcte from si_cliente" >> /RESPALDOSNEW/instruccion1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql = 'dbaccess bdinteg /RESPALDOSNEW/instruccion1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql ='rm /RESPALDOSNEW/instruccion1.sql';
		SYSTEM cSql;
		-- CARGA EL PIVOTE
		LET cSql = '';
		LET cSql = 'dbload -d bdinteg -c /RESPALDOSNEW/02_carga.sql -l adviser.log -n 2000 -k';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql = 'chmod 777 /RESPALDOSNEW/tmp_ref_cliente.unl';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql ='rm /RESPALDOSNEW/tmp_ref_cliente.unl';
		SYSTEM cSql;

	end if;

	FOREACH WITH HOLD

		select cliente
		into VlNumCredito  
		from "informix".tmp_ref_cliente

		BEGIN WORK;

			DELETE FROM "informix".si_refclientes 
			WHERE empresa = '001' and  numcte = VlNumCredito and fecha_insert <= mdy('12','31','2017');
			delete from "informix".tmp_ref_cliente where cliente = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	RETURN cCod_ret;

	END;

END PROCEDURE;