CREATE PROCEDURE "informix".sp_convierte_ctetipo2()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cMensaje 		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE vrowid           INTEGER;
DEFINE VlNumCredito     CHAR(9);
DEFINE cSql 			CHAR(200);

	--SET DEBUG FILE TO "/informix/c91691184/sp_convierte_ctetipo2.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info  = '';
	LET cSql 		= '';
	LET cMensaje    = 'PROCESO EXITOSO';

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret;
	    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname MATCHES 'tmp_convierte_ctetipo2') THEN
		DROP TABLE "informix".tmp_convierte_ctetipo2;
	END IF;

	CREATE TABLE "informix".tmp_convierte_ctetipo2 
		( 	
			numcte		CHAR(9),
			fecha		CHAR(10)
		);
	--Set pdqpriority 10;
	begin;
	CREATE UNIQUE INDEX "informix".inx_tmp_ctes ON "informix".tmp_convierte_ctetipo2(numcte) online;
	commit;
	update statistics medium for table "informix".tmp_convierte_ctetipo2;


	LET cSql = '';
	LET cSql = 'echo "LOAD FROM /resplogifx/archivoscartera/clientes_sin.unl INSERT INTO tmp_convierte_ctetipo2" > /resplogifx/archivoscartera/inst_carga.sql;';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/inst_carga.sql';
	SYSTEM cSql;

    FOREACH WITH HOLD

		select cte.numcte
		into VlNumCredito
		from "informix".si_cliente as cte
		inner join "informix".tmp_convierte_ctetipo2 as tmp on
		(cte.numcte = tmp.numcte)
		where cte.empresa = '001' 
		and cte.tipo_cliente = '1'
		and cte.numcte not IN (SELECT numcte FROM "informix".si_cte_huella WHERE numcte = cte.numcte)
		and cte.numcte not IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE empresa = cte.empresa AND num_cte = cte.numcte)
		and cte.numcte not IN (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE empresa = cte.empresa AND num_cte = cte.numcte)
		and cte.numcte not IN (SELECT numcte FROM bdicred:"informix".sd_maecred WHERE empresa = cte.empresa AND numcte = cte.numcte)
		and cte.numcte not IN (SELECT numcte FROM bdisolic:"informix".ss_solicitudes WHERE empresa = cte.empresa AND numcte = cte.numcte)
		and cte.numcte not IN (SELECT numcte FROM bdicheq:"informix".sc_firmantes WHERE empresa = cte.empresa AND numcte = cte.numcte)

		BEGIN WORK;

			update "informix".si_cliente set tipo_cliente = '2' WHERE empresa = '001' and numcte = VlNumCredito;
			delete from "informix".tmp_convierte_ctetipo2 where numcte = VlNumCredito;

		COMMIT WORK;

	END FOREACH;  

	drop table "informix".tmp_convierte_ctetipo2;

	RETURN cCod_ret;

	END;

END PROCEDURE;