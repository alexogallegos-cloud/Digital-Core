CREATE PROCEDURE "informix".sp_carga_movimientos_ivr ()
RETURNING CHAR(6), CHAR(80);


--DECLARACION DE VARIABLES
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(80);
	DEFINE cCod_ret		CHAR(6);
	DEFINE vempresa     CHAR(3);
	DEFINE cproceso     CHAR(4);
	DEFINE vvcCod_ret   CHAR(6);
	DEFINE cMensaje		CHAR(80);
	DEFINE cCadena		CHAR(500);
	DEFINE vRuta		CHAR(100);
	DEFINE cSql         CHAR(2204);
	DEFINE pNomArch 	CHAR(100);
	DEFINE vNomArch		CHAR(100);
	DEFINE X 			CHAR(100);
	DEFINE vfecha 		DATE;
	DEFINE vfecha_cat 	DATE;

	----variables
	DEFINE vnumcte					CHAR(20);
	DEFINE vtelefonoreconstruido	CHAR(13);
	DEFINE vtipotelefono			SMALLINT;
	DEFINE vsecuencia				SMALLINT;
	DEFINE vnumext					CHAR(5);
	DEFINE vfinllamada				SMALLINT;
	DEFINE vnumempleado				CHAR(8);
	DEFINE vnumcuenta				CHAR(20);
	DEFINE vplazo					CHAR(2);
	DEFINE vimporte					DECIMAL(18,2);
	DEFINE vtipoconvenio			CHAR(1);
	DEFINE vhorainicio				DATE;

	--SET DEBUG FILE TO "carga_ivr.out ";
	--TRACE ON;

--DEFINICIAON DE VARIABLES
	LET cCod_ret  	= "000000";
	LET sql_err   	= 0;
	LET cMensaje  	= "PROCESO EXITOSO";
	LET cCadena   	= "";
	LET vRuta     	= "";
	LET cSql      	= "";
	LET vempresa    = '001';
	LET cproceso    = '2077';
	LET pNomArch 	= '';
	let vfecha 		= DATE(1);
	let vfecha_cat	= date(1);
	let vNomArch	= '';
	let X ='';

	---VARIABLES
	LET vnumcte					='';
	LET vtelefonoreconstruido	='';
	LET vtipotelefono			=0;
	LET vsecuencia				=0;
	LET vnumext					='';
	LET vfinllamada				=0;
	LET vnumempleado			='';
	LET vnumcuenta				='';
	LET vplazo					='';
	LET vimporte				=0;
	LET vtipoconvenio			='';
	LET vhorainicio				=DATE(1);

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
			LET cMensaje = error_info;
LET cCod_ret  	= "000000";
		    RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;



	--SELECCIONAMOS LA FECHA DEL DIA
	select fecha_hoy
		into vfecha
	from bdicred:sd_fechas
	where empresa = '001';

		--SELECCIONAMOS LA RUTA
    select valor_alfabetico
		  into vRuta
    from bdicobranza:cb_param_campania
    where empresa = '001'
		and tipo_campania = 1
		and grupo_parametro = 'ARCHIVOS'
		and num_parametro = 36;

--let vfecha = '12-05-2012';
--let vRuta ='/informix/eli/';
	---------------------------------------------CARGAR ARCHIVO A LA TABLA	---------------------------------------------------------------------

		--ASIGNAMOS NOMBRE AL ARCHIVO
/*		LET pNomArch = 'archivo_ivr_cobranza.txt';--|| to_char(vfecha,'%d%m%Y')||'.txt';
		let vNomArch = pNomArch;

		LET cCadena = 'echo " load from ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(vNomArch,1,
			LENGTH(vNomArch))  || ' insert into bdicobranza:cb_movimientos_ivr " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'ivrmovimientos.sql';
			System SUBSTR(cCadena,1,LENGTH(cCadena));
			let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'ivrmovimientos.sql';
		System SUBSTR(cCadena,1,LENGTH(cCadena));

		--BORRA EL ARCHIVO
        let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'ivrmovimientos.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));

		--SE COMPRIME DE NUEVO EL ARCHIVO
		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch);
		system cSql;
*/
LET cCod_ret  	= "000000";

RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;