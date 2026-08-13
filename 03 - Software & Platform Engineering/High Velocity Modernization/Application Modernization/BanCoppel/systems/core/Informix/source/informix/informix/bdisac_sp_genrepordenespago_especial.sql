CREATE PROCEDURE "informix".sp_genrepordenespago_especial (vFechaInicial DATE, vFechaFinal DATE)

RETURNING CHAR(5) AS CodRetorno, CHAR(200) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: REPORTE DE ORDENES DE PAGO EXTRAORDINARIO
-- SOLICITA: Luis Monzón
-- AUTOR : FRG
-- FECHA : 02/07/2012
-- BD: BDISAC
-- SISTEMA : DINYA
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno CHAR (5);
DEFINE vsMensaje CHAR(200);
DEFINE isam_error INTEGER;
DEFINE visam_error INTEGER;

/*DSB ALFONSO CRUZ*/
--	DEFINE vdFechaHoy DATETIME YEAR TO FRACTION(5);
DEFINE vsDia CHAR(2);
DEFINE vsMes CHAR(2);
DEFINE vsAnio CHAR(2);
DEFINE vdFechaPri DATE;
DEFINE vdFechaFin DATE;
DEFINE vsDdi CHAR(2);
DEFINE vsDdf CHAR(2);
DEFINE vsMesR CHAR(2);
DEFINE vsAnioR CHAR(2);
DEFINE vsAnio4 VARCHAR(4);
DEFINE vsNombreArchivo CHAR(50);
DEFINE vsRutaArchRep CHAR(150);
DEFINE cStmt CHAR(1500);
DEFINE viRegistros INTEGER;
DEFINE vdFechaHoy DATE;

/*VARIABLES DEL REPORTE*/
DEFINE vsFechaEnvio CHAR(8);
DEFINE vsNumeroControl CHAR(12);
DEFINE vsPriNombreOrdenante CHAR(26);
DEFINE vsSegNombreOrdenante CHAR(26);
DEFINE vsApePatOrdenante CHAR(26);
DEFINE vsApeMatOrdenante CHAR(26);
DEFINE vsDomicilioOrdenante CHAR(80);
DEFINE vsSucursalOrigen CHAR(4);
DEFINE vsNombreSucursalOrigen CHAR(40);
DEFINE vsLocalidadSucursalOrigen CHAR(25);
DEFINE vsEstatus CHAR(10);
DEFINE vsImportePagado CHAR(18);
DEFINE vsFechaPago CHAR(8);
DEFINE vsPriNombreBeneficiario CHAR(26);
DEFINE vsSegNombreBeneficiario CHAR(26);
DEFINE vsApePatBeneficiario CHAR(26);
DEFINE vsApeMatBeneficiario CHAR(26);
DEFINE vsDomicilioBeneficiario CHAR(80);
DEFINE vsSucursalPagadora CHAR(4);
DEFINE vsNombreSucursalPagadora CHAR(40);
DEFINE vsLocalidadSucursalPagadora CHAR(25);
DEFINE valproceso INTEGER;
DEFINE valruta    INTEGER;

DEFINE cSPCodRet CHAR(5); 
DEFINE iMensaje CHAR(50);
DEFINE cid_ptf CHAR(5); 
DEFINE ccve_pais CHAR(3);
DEFINE cnompais CHAR(20);
DEFINE ccalle VARCHAR(100); 
DEFINE cnum_ext VARCHAR(6); 
DEFINE cnum_int VARCHAR(5); 
DEFINE ccve_col CHAR(8);
DEFINE cnomcol VARCHAR(100);
DEFINE ccve_mun CHAR(3);
DEFINE cnommunicipio VARCHAR(60);
DEFINE ccve_localidad CHAR(14);
DEFINE cnomlocalidad VARCHAR(60);
DEFINE ccp CHAR(5); 
DEFINE ccve_ciudad CHAR(3);
DEFINE cnomciudad VARCHAR(60);
DEFINE ccve_estado CHAR(2); 
DEFINE cnomestado VARCHAR(30);
DEFINE ctel1 VARCHAR(14); 
DEFINE ctel2 VARCHAR(14);
DEFINE ctipo VARCHAR(5);

	--	SET DEBUG FILE TO "/informix/frg/sp_genrepordenespago_especial.out";
	--	TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET isam_error = 0;
LET visam_error = 0;

/*DSB ALFONSO CRUZ*/
--	LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET vdFechaPri = vFechaInicial;
LET vdFechaFin = vFechaFinal;
LET vsDdi = '';
LET vsDdf = '';
LET vsMesR = '';
LET vsAnioR = '';
LET vsAnio4 = '';
LET vdFechaHoy = '01/01/1900';

LET vsNombreArchivo = '';
LET cStmt = '';
LET vsRutaArchRep = '';
LET viRegistros = 0;

/*VARIABLES DEL REPORTE*/
LET vsFechaEnvio = '';
LET vsNumeroControl = '';
LET vsPriNombreOrdenante = '';
LET vsSegNombreOrdenante = '';
LET vsApePatOrdenante = '';
LET vsApeMatOrdenante = '';
LET vsDomicilioOrdenante = '';
LET vsSucursalOrigen = '';
LET vsNombreSucursalOrigen = '';
LET vsLocalidadSucursalOrigen = '';
LET vsEstatus = '';
LET vsImportePagado = '';
LET vsFechaPago = '';
LET vsPriNombreBeneficiario = '';
LET vsSegNombreBeneficiario = '';
LET vsApePatBeneficiario = '';
LET vsApeMatBeneficiario = '';
LET vsDomicilioBeneficiario = '';
LET vsSucursalPagadora = '';
LET vsNombreSucursalPagadora = '';
LET vsLocalidadSucursalPagadora = '';
LET valproceso = 0;
LET valruta = 0;

LET cSPCodRet = '00000';
LET iMensaje = '';
LET cid_ptf = '';
LET ccve_pais = '';
LET cnompais = '';
LET ccalle = '';
LET cnum_ext = ''; 
LET cnum_int = '';
LET ccve_col = '';
LET cnomcol = '';
LET ccve_mun = '';
LET cnommunicipio = '';
LET ccve_localidad = '';
LET cnomlocalidad = '';
LET ccp = '';
LET ccve_ciudad = '';
LET cnomciudad = '';
LET ccve_estado = ''; 
LET cnomestado = '';
LET ctel1 = '';
LET ctel2 = '';
LET ctipo = '';

BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno, visam_error, vsMensaje, 'sp_genRepOrdenesPago', vdFechaHoy,CURRENT);
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	select fecha_hoy
	into vdFechaHoy
	from "informix".sac_fechas;

-- Se valida si el proceso ya corrio el día indicado y si fue exitosa su ejecución:
	SELECT COUNT (fecha_proceso) into valproceso
		FROM BDISAC:SAC_PROCESOS
		WHERE proceso = 'GEN_REPORD' AND fecha_proceso = vdFechaHoy AND status = '1';

	if (valproceso) > 0 then
		LET vsCodRetorno = '99999';
		LET vsMensaje  = 'ERROR: EL PROCESO YA HA SIDO EJECUTADO DE MANERA EXITOSA EL DIA DE HOY, NO PUEDE EJECUTARSE NUEVAMENTE.';
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepOrdenesPago',vdFechaHoy,CURRENT );
		RETURN vsCodRetorno, vsMensaje;
		else
		delete from BDISAC:SAC_PROCESOS
		WHERE proceso = 'GEN_REPORD' AND fecha_proceso = vdFechaHoy AND status = '0';
	end if;

	DELETE FROM bdisac:"informix".sac_procesos WHERE fecha_proceso = vdFechaHoy AND proceso = 'GEN_REPORD';
	insert into bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
	values ('GEN_REPORD', vdFechaHoy, '0', 'informix', current);

--	Se valida si existe la ruta deposito del archivo:
	select count (valor) into valruta from bdisac:sac_param WHERE cod_param = '230001';
	if valruta = 0 then
		LET vsCodRetorno = '99998';
		LET vsMensaje  = 'ERROR: LA RUTA DEPOSITO DEL ARCHIVO NO EXISTE, FAVOR DE VALIDAR.';
		insert into bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
		values ('GEN_REPORD', vdFechaHoy, '0', 'informix', current);
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepOrdenesPago',vdFechaHoy,CURRENT );
		RETURN vsCodRetorno, vsMensaje;
	end if;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

-- Se definen valores en base a las fechas de entrada:
	LET vsDdi = SUBSTR (vFechaInicial, 4, 2);
	LET vsDdf = SUBSTR (vFechaFinal, 4, 2);
	LET vsMesR = SUBSTR (vFechaFinal, 1, 2);
	LET vsAnioR = SUBSTR (vFechaFinal, 9, 2);

	IF (vsCodRetorno='00000') THEN
		LET vsNombreArchivo = TRIM('Ordenes_de_Pago_'|| NVL(vsDdi,'01') || '-' || NVL(vsDdf,'01') || NVL(vsMesR,'01') || NVL(vsAnioR,'01') || '.txt');

	SELECT FIRST 1 VALOR||'/'||vsNombreArchivo
	INTO vsRutaArchRep FROM bdisac:"informix".sac_param
	WHERE cod_param = '230001';
	
	
	LET vsRutaArchRep = TRIM(vsRutaArchRep);
	

	FOREACH
		SELECT  SUBSTR(replace(fecha_envio::date,'/',''),3,2)||
			SUBSTR(replace(fecha_envio::date,'/',''),1,2)||
			SUBSTR(replace(fecha_envio::date,'/',''),5,4) as fechaEnvio,
			no_control as no_control,
			SUBSTR(NVL(pri_nom_rem,''),1,26) as priNomRem,
			SUBSTR(NVL(seg_nom_rem,''),1,26) as segNomRem,
			SUBSTR(NVL(apell_pat_rem,''),1,26) as apellPatRem,
			SUBSTR(apell_mat_rem,1,26) as apeMatRem,
			SUBSTR(direc_rem,1,80) as direcRem,
			SUBSTR(suc_origen,1,4) as sucOrigen,
			SUBSTR(suc.nombre,1,40) as nomSucursal,
			--SUBSTR(ciu.nombre,1,25) as nomCiudad,
			CASE
				WHEN  (estatus = '01' ) THEN 'PENDIENTE'
				WHEN  (estatus = '04' ) THEN 'PAGADA'
				ELSE ''
			END,
               importe_pago as importePago,
			(SUBSTR(replace(fecha_pago::date,'/',''),1,2)||
				SUBSTR(replace(fecha_pago::date,'/',''),3,2)||
				SUBSTR(replace(fecha_pago::date,'/',''),5,4)) as fechaPago,
			SUBSTR(pri_nom_ben,1,26) as priNomBene,
			SUBSTR(seg_nom_ben,1,26) as segNomBene,
			SUBSTR(apell_pat_ben,1,26) as apellPatBene,
			SUBSTR(apell_mat_ben,1,26) as apellMatBene,
			SUBSTR(direc_ben,1,80) as direcBene,
			SUBSTR(suc_cobropago,1,4) as sucCobro,
--	Busca el pais y el estado de la sucursal pagadora:
			SUBSTR(suc.nombre,1,40) as nomSuc
			--SUBSTR(ciu.nombre,1,25) as nomCiu
		INTO vsFechaEnvio, vsNumeroControl, vsPriNombreOrdenante, vsSegNombreOrdenante, vsApePatOrdenante,
			vsApeMatOrdenante, vsDomicilioOrdenante, vsSucursalOrigen, vsNombreSucursalOrigen,
			vsEstatus, vsImportePagado, vsFechaPago, vsPriNombreBeneficiario,
			vsSegNombreBeneficiario, vsApePatBeneficiario, vsApeMatBeneficiario, vsDomicilioBeneficiario,
			vsSucursalPagadora, vsNombreSucursalPagadora
		FROM bdisac:"informix".sac_enviosdineroya env
		INNER JOIN bdinteg:"informix".si_sucursales AS suc ON
		env.suc_origen = suc.sucursal
		INNER JOIN bdinteg:"informix".si_ciudades AS ciu ON
		suc.ciudad = ciu.ciudad and env.suc_origen = suc.sucursal
		WHERE estatus IN ('04','01') AND
		ciu.pais=suc.pais AND
		ciu.estado = suc.estado AND
		fecha_envio BETWEEN date(vdFechaPri) AND date(vdFechaFin)
UNION
	SELECT  SUBSTR(replace(fecha_envio::date,'/',''),3,2)||
	SUBSTR(replace(fecha_envio::date,'/',''),1,2)||
	SUBSTR(replace(fecha_envio::date,'/',''),5,4) as fechaEnvio,
		no_control as no_control,
		SUBSTR(NVL(pri_nom_rem,''),1,26) as priNomRem,
		SUBSTR(NVL(seg_nom_rem,''),1,26) as segNomRem,
		SUBSTR(NVL(apell_pat_rem,''),1,26) as apellPatRem,
		SUBSTR(apell_mat_rem,1,26) as apeMatRem,
		SUBSTR(direc_rem,1,80) as direcRem,
		SUBSTR(suc_origen,1,4) as sucOrigen,
		SUBSTR(suc.nombre,1,40) as nomSucursal,
		--SUBSTR(ciu.nombre,1,25) as nomCiudad,
		CASE
			WHEN  (estatus = '01' ) THEN 'PENDIENTE'
			WHEN  (estatus = '04' ) THEN 'PAGADA'
			ELSE ''
		END,
           importe_pago as importePago,
		(SUBSTR(replace(fecha_pago::date,'/',''),1,2)||
		SUBSTR(replace(fecha_pago::date,'/',''),3,2)||
		SUBSTR(replace(fecha_pago::date,'/',''),5,4)) as fechaPago,
		SUBSTR(pri_nom_ben,1,26) as priNomBene,
		SUBSTR(seg_nom_ben,1,26) as segNomBene,
		SUBSTR(apell_pat_ben,1,26) as apellPatBene,
		SUBSTR(apell_mat_ben,1,26) as apellMatBene,
		SUBSTR(direc_ben,1,80) as direcBene,
		SUBSTR(suc_cobropago,1,4) as sucCobro,
--	Busca el pais y el estado de la sucursal pagadora:
		SUBSTR(succ.nombre,1,40) as nomSuc
		--SUBSTR(ciuu.nombre,1,25) as nomCiu
		FROM bdisac:"informix".sac_enviosdineroyahis env
		INNER JOIN bdinteg:"informix".si_sucursales AS suc ON
		env.suc_origen = suc.sucursal
		INNER JOIN bdinteg:"informix".si_sucursales AS succ ON
		env.suc_cobropago = succ.sucursal
		INNER JOIN bdinteg:"informix".si_ciudades AS ciu ON
		suc.ciudad = ciu.ciudad and env.suc_origen = suc.sucursal
		INNER JOIN bdinteg:"informix".si_ciudades AS ciuu ON
		succ.ciudad = ciuu.ciudad and env.suc_cobropago = succ.sucursal
		WHERE estatus IN ('04','01') AND
		ciu.pais=suc.pais AND
		ciu.estado = suc.estado AND
		ciuu.pais=succ.pais AND
		ciuu.estado = succ.estado AND
           fecha_envio BETWEEN date(vdFechaPri) AND date(vdFechaFin)
		order by fechaEnvio,no_control
		
		--Nombre Ciudad Suc Origen
		execute procedure bdisac:"informix".sp_sac_consucursales(vsSucursalOrigen) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,vsLocalidadSucursalOrigen,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
		--Nombre Ciudad Suc Pagadora
		IF TRIM(vsEstatus) = 'PENDIENTE' THEN
			execute procedure bdisac:"informix".sp_sac_consucursales(vsSucursalOrigen) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,vsLocalidadSucursalPagadora,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
		ELSE
			execute procedure bdisac:"informix".sp_sac_consucursales(vsSucursalPagadora) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,vsLocalidadSucursalPagadora,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
		END IF;	

		if vsSucursalPagadora IS NULL then
			let vsNombreSucursalPagadora = '' ;
			let vsLocalidadSucursalPagadora = '';
			else
			let vsNombreSucursalPagadora = vsNombreSucursalPagadora;
			let vsLocalidadSucursalPagadora = vsLocalidadSucursalPagadora;
		end if;
			LET cStmt = 'echo "' || RPAD(NVL(vsFechaEnvio,' '),8,' ') ||'|'||
			NVL(vsNumeroControl,'            ') ||'|'||
			RPAD(NVL(vsPriNombreOrdenante,''),26,' ') ||'|'||
			RPAD(NVL(vsSegNombreOrdenante,''),26,' ') ||'|'||
			RPAD(NVL(vsApePatOrdenante,''),26,' ') ||'|'||
			RPAD(NVL(vsApeMatOrdenante,''),26,' ') ||'|'||
			RPAD(NVL(vsDomicilioOrdenante,''),80,' ') ||'|'||
			LPAD(NVL(vsSucursalOrigen,''),4,'0') ||'|'||
			RPAD(NVL(vsNombreSucursalOrigen,''),40,' ') ||'|'||
			RPAD(NVL(vsLocalidadSucursalOrigen,''),25,' ') ||'|'||
			RPAD(NVL(vsEstatus,''),10,' ') ||'|'||
			LPAD(NVL(vsImportePagado,'0'),18,'0') ||'|'||
			RPAD(NVL(vsFechaPago,''),8,' ') ||'|'||
			RPAD(NVL(vsPriNombreBeneficiario,''),26,' ') ||'|'||
			RPAD(NVL(vsSegNombreBeneficiario,''),26,' ') ||'|'||
			RPAD(NVL(vsApePatBeneficiario,''),26,' ') ||'|'||
			RPAD(NVL(vsApeMatBeneficiario,''),26,' ') ||'|'||
			RPAD(NVL(vsDomicilioBeneficiario,''),80,' ') ||'|'||
			LPAD(NVL(vsSucursalPagadora,''),4,'0') ||'|'||
			RPAD(NVL(vsNombreSucursalPagadora,''),40,' ') ||'|'||
			RPAD(NVL(vsLocalidadSucursalPagadora,''),25,' ') ||'|'|| '" >> ' || vsRutaArchRep;

			SYSTEM cStmt;

			LET viRegistros = viRegistros + 1 ;
	END FOREACH;
		IF (viRegistros=0)THEN

			/*SE CREA EL ARCHIVO POR SI LA CONSULTA NO DEVUELVE RESULTADOS*/
			LET cStmt = 'echo "">>' || vsRutaArchRep;
			SYSTEM cStmt;

		END IF;

		--SI EL PROCESO TERMINA SATISFACTORIAMENTE
		UPDATE bdisac:"informix".sac_procesos SET status='1',fecha_proceso=vdFechaHoy
		WHERE proceso = 'GEN_REPORD'
			and fecha_proceso=vdFechaHoy;
		LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE CON '|| viRegistros || ' REGISTROS';
	ELSE
		LET vsMensaje  = 'ERROR: EL DIA NO ES VALIDO PARA LA GENERACION DE REPORTES';
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepOrdenesPago',vdFechaHoy,CURRENT );
	END IF;
	RETURN vsCodRetorno, vsMensaje ;

END;
END PROCEDURE;