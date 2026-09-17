CREATE PROCEDURE "informix".sp_identifica_exclusiones(pempresa CHAR(3), pnum_credito CHAR(20), pnumcte CHAR(20))

RETURNING 	CHAR(6) AS codigo_retorno, 
			CHAR(1) AS valor_exclusion;
/*
___________________________________________________________________________________________________________________________________________________________________________
	Creado: Carlos Valenzuela
	FECHA: -03-2018.
	DESCRIPCION: Proceso para saber si un credito tiene algun excluido
				0. Cuenta no excluida.
				1. Seran exceptuados los Clientes que esten reportados como Fallecidos, ya que se consideran irrecuperables o incobrables (F42).
				2. Los Clientes que se encuentren en proceso de "Aclaracion" (I13).
				3. Los Clientes con un "Convenio Activo".
				4. Los Creditos con saldo vencido menor a 100 pesos.
	BASE DE DATOS: bdicobranza.
*/

--EXECUTE PROCEDURE "informix".sp_identifica_exclusiones("000", "630111397919", "000123998");

--DECLARACION DE VARIABLES
DEFINE sql_err					INTEGER;
DEFINE isam_err					INTEGER;
DEFINE error_info				CHAR(80);
DEFINE cCod_ret					CHAR(6);
DEFINE cproceso     			CHAR(4);
DEFINE vvcCod_ret				CHAR(6);
DEFINE cMensaje					CHAR(80);
DEFINE vexclusion				CHAR(1);

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vvcCod_ret;
		RETURN cCod_ret, vexclusion;	    
	END EXCEPTION;

	--SET DEBUG FILE TO "sp_identifica_exclusiones.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET sql_err   				= 0;
	LET isam_err				= 0;
	LET error_info				= "";
	LET cCod_ret  				= "000000";
	LET cproceso    			= "2013";
	LET vvcCod_ret				= "000000";
	LET cMensaje  				= "PROCESO EXITOSO";
	LET vexclusion				= "";

	--VALIDACIONES PARA REALIZAR LAS EXCLUSIONES
	IF EXISTS(SELECT numcte FROM bdisitesp:"informix".se_ctessitespcte 
				WHERE numcte = pnumcte AND situacion = "F" AND causa = 42) THEN
		LET vexclusion = "1";
	ELIF EXISTS(SELECT num_cliente FROM bdiaclaracion:"informix".acl_aclaracion 
				WHERE num_cliente = pnumcte AND fky_estatus_aclaracion in ("1","2")) THEN
		LET vexclusion = "2";
	ELIF EXISTS(SELECT numcuenta FROM "informix".cb_compac 
				WHERE empresa = pempresa AND numcuenta = pnum_credito) THEN
		LET vexclusion = "3";
	ELIF EXISTS(SELECT num_credito FROM bdicred:"informix".sd_maesdoscrd 
				WHERE empresa = pempresa AND num_credito = pnum_credito AND mto_venc_trasp < 100) THEN
		LET vexclusion = "4";
	ELIF EXISTS(SELECT num_credito FROM bdicred:"informix".sd_maesdos 
				WHERE empresa = pempresa AND num_credito = pnum_credito AND mto_venc_trasp < 100) THEN
		LET vexclusion = "4";
	ELSE
		LET vexclusion = "0";
	END IF;

	RETURN cCod_ret, vexclusion;

END;
END PROCEDURE;