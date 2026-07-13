CREATE PROCEDURE "informix".sp_genrepremesasbts()

RETURNING CHAR(5) AS CodRetorno, CHAR(200) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: REPORTE DE REMESAS BTS
-- SOLICITA: Feliciano Ceniceros Aguilera
-- AUTOR : ING ALFONSO CRUZ
-- FECHA : 06/09/2011
-- BD: BDISAC
-- SISTEMA : BTS
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno CHAR (5);
DEFINE vsMensaje CHAR(200);
DEFINE isam_error INTEGER;
DEFINE visam_error INTEGER;
DEFINE vdFechaHoy DATETIME YEAR TO FRACTION(5);
DEFINE vsDia CHAR(2);
DEFINE vsMes CHAR(2);
DEFINE vsAnio CHAR(2);
DEFINE vdFechaPri DATE;
DEFINE vdFechaFin VARCHAR(10);
DEFINE vsDdi CHAR(2);
DEFINE vsDdf CHAR(2);
DEFINE vsMesR CHAR(2);
DEFINE vsAnioR CHAR(2);
DEFINE vsAnio4 VARCHAR(4);
DEFINE vsNombreArchivo CHAR(50);
DEFINE vsRutaArchRep CHAR(500);
DEFINE cStmt CHAR(1500);
DEFINE viRegistros INTEGER;

/*VARIABLES DEL REPORTE*/
DEFINE vsFolioSuc CHAR(16);
DEFINE vsReferencia1 CHAR(11); 
DEFINE vsFechaPago CHAR(8);
DEFINE vsPayFirstName CHAR(40);
DEFINE vsPayMiddleName CHAR(40);
DEFINE vsPayLastName CHAR(40);
DEFINE vsPayMotherName CHAR(40);
DEFINE vsPayFechaNac CHAR(8);
DEFINE vsPayNomCalle CHAR(50);
DEFINE vsPayNumExt CHAR(5);
DEFINE vsPayNumInt CHAR(5);
DEFINE vsPayDepto CHAR(10);
DEFINE vsPayColonia CHAR(80);
DEFINE vsPayCp CHAR(5);
DEFINE vsPayMunicipio CHAR(50);
DEFINE vsPayCiudad CHAR(50);
DEFINE vsPayEstado CHAR(50);
DEFINE vsPayBranch CHAR(4);
DEFINE valproceso INTEGER;
DEFINE valruta    INTEGER;
DEFINE vsNomSucursal CHAR(40);
DEFINE vsLocSucursal CHAR(25);
DEFINE vsSFirstName CHAR(40); 
DEFINE vsSMiddleName  CHAR(40); 
DEFINE vsSLastName  CHAR(40); 
DEFINE vsSMotherName  CHAR(40); 
DEFINE vsOriginAm  CHAR(20);
DEFINE vsDestinationAm  CHAR(20);
DEFINE vsStCancelado CHAR(1);

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

LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET isam_error = 0;
LET visam_error = 0;
LET valproceso = 0;
LET valruta = 0;
LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET vdFechaPri = DATE('01/01/1900');
LET vdFechaFin = '';
LET vsDdi = '';
LET vsDdf = '';
LET vsMesR = '';
LET vsAnioR = '';
LET vsAnio4 = '';
LET vsNombreArchivo = '';
LET cStmt = '';
LET vsRutaArchRep = '';
LET viRegistros = 0;

/*VARIABLES DEL REPORTE*/
LET vsFolioSuc ='' ;
LET vsReferencia1 =''; 
LET vsFechaPago  ='';
LET vsPayFirstName  ='';
LET vsPayMiddleName  ='';
LET vsPayLastName  ='';
LET vsPayMotherName  ='';
LET vsPayFechaNac  ='';
LET vsPayNomCalle  ='';
LET vsPayNumExt  ='';
LET vsPayNumInt  ='';
LET vsPayDepto  ='';
LET vsPayColONia  ='';
LET vsPayCp  ='';
LET vsPayMunicipio  ='';
LET vsPayCiudad  ='';
LET vsPayEstado  ='';
LET vsPayBranch  ='';

/*BDINTEG*/
LET vsNomSucursal ='';
LET vsLocSucursal ='';
LET vsSFirstName ='';
LET vsSMiddleName ='';
LET vsSLastName ='';
LET vsSMotherName ='';
LET vsOriginAm ='';
LET vsDestinationAm ='';
LET vsStCancelado = '';

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
				VALUES (vsCodRetorno, visam_error, vsMensaje, 'sp_genRepRemesasBTS', vdFechaHoy,CURRENT);
				RETURN vsCodRetorno, vsMensaje;
			
		END IF;
	END EXCEPTION;
	
		--	SET DEBUG FILE TO "/home/informix/bdisac/sp_genrepremesasbts.out";
		--	TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT FIRST 1 CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),
		SUBSTR(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),9,2),
		SUBSTR(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),6,2), 
		SUBSTR(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),3,2)
	INTO vdFechaHoy, vsDia, vsMes, vsAnio 
	FROM BDISAC:"informix".sac_fechas;
	
	LET vsAnio4 = (SUBSTR(vdFechaHoy,1,4));
	
	
	SELECT COUNT (fecha_proceso) into valproceso
		FROM BDISAC:SAC_PROCESOS 
		WHERE proceso = 'GEN_REPBTS' AND fecha_proceso = vdFechaHoy AND status = '1';
		
	if (valproceso) > 0 then
		LET vsCodRetorno = '99999';
		LET vsMensaje  = 'ERROR: EL PROCESO YA HA SIDO EJECUTADO DE MANERA EXITOSA EL DIA DE HOY, NO PUEDE EJECUTARSE NUEVAMENTE.';
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripciON, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepRemesasBTS',vdFechaHoy, current);
		RETURN vsCodRetorno, vsMensaje;
	else
		delete from BDISAC:SAC_PROCESOS 
		WHERE proceso = 'GEN_REPBTS' AND fecha_proceso = vdFechaHoy AND status = '0';
	end if;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	insert into bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
	values ('GEN_REPBTS', vdFechaHoy, '0', 'informix', current);

	select count (valor) into valruta from bdisac:sac_param WHERE cod_param = '230002';
	if valruta = 0 then
		LET vsCodRetorno = '99998';
		LET vsMensaje  = 'ERROR: LA RUTA DEPOSITO DEL ARCHIVO NO EXISTE, FAVOR DE VALIDAR.';
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripciON, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepRemesasBTS',vdFechaHoy, current);
		RETURN vsCodRetorno, vsMensaje;
	end if;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF (vsDia = '16') THEN 
		LET vdFechaPri = (vsMes || "/" || "01" || "/" || vsAnio4)::DATE;
		LET vdFechaFin = ( vsMes|| "/" || "15" || "/" || vsAnio4)::DATE;
		LET vsDdi = '01';
		LET vsDdf = '15';
		LET vsMesR = vsMes;
		LET vsAnioR = vsAnio;
	ELIF (vsDia = '01') THEN 
		/*CONSULTAR DEL 16 AL FIN DEL MES ANTERIOR*/
		SELECT (fecha_hoy-1)::DATE 
		INTO vdFechaFin
		FROM BDISAC:"informix".sac_fechas;
		
		LET vdFechaPri = ( MONTH(vdFechaFin::DATE) || "/" || "16" || "/" || (YEAR(vdFechaFin::DATE)))::DATE;
		
		LET vsDdi = '16';
		LET vsDdf = SUBSTR(REPLACE(vdFechaFin::DATE,'/',''),3,2);
		LET vsMesR = SUBSTR(REPLACE(vdFechaFin::DATE,'/',''),1,2);
		LET vsAnioR = SUBSTR(REPLACE(vdFechaFin::DATE,'/',''),7,2);
	ELSE 
		/*ERROR HOY NO SE PUEDE EJECUTAR EL REPORTE*/
		LET vsCodRetorno = '00100';
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	/*SI LA FECHA DE EJECUCION ES VALIDA*/
	IF (vsCodRetorno='00000') THEN
		LET vsNombreArchivo = 'Transferencias_BTS_'|| NVL(vsDdi,'01') || '-' || NVL(vsDdf,'01') || NVL(vsMesR,'01') || NVL(vsAnioR,'01') || '.txt';
		
		SELECT FIRST 1 TRIM(VALOR)||'/'||TRIM(vsNombreArchivo)
		INTO vsRutaArchRep 
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '230002';
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--CONSULTA DE REMESAS BTS
			SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				SUBSTR(NVL(mov.referencia1,''),1,11), 
				SUBSTR(NVL(mov.folio_suc,''),1,16),
				SUBSTR(CAST(fecha_pago AS DATETIME YEAR TO FRACTION(5)),9,2)||
				SUBSTR(CAST(fecha_pago AS DATETIME YEAR TO FRACTION(5)),6,2)||
				SUBSTR(CAST(fecha_pago AS DATETIME YEAR TO FRACTION(5)),0,4),
				payi.r_first_name, 
				payi.r_middle_name, 
				payi.r_last_name, 
				payi.r_mother_m_name, 
				SUBSTR(NVL(payi.r_fecha_nac,'01'),7,2)||
				SUBSTR(NVL(payi.r_fecha_nac,'01'),5,2)||
				SUBSTR(NVL(payi.r_fecha_nac,'1990'),1,4),
				payi.r_nom_calle,
				payi.r_num_ext, 
				payi.r_num_int, 
				payi.r_depto, 
				payi.r_colonia, 
				payi.r_cp,
				payi.r_mncpo_deleg, 
				payi.r_ciudad, 
				payi.r_estado, 
				payi.branch_sd,
				mov.status_cancelado
			INTO vsReferencia1, 
				vsFolioSuc, 
				vsFechaPago, 
				vsPayFirstName, 
				vsPayMiddleName, 
				vsPayLastName, 
				vsPayMotherName, 
				vsPayFechaNac, 
				vsPayNomCalle, 
				vsPayNumExt, 
				vsPayNumInt, 
				vsPayDepto, 
				vsPayColonia, 
				vsPayCp, 
				vsPayMunicipio, 
				vsPayCiudad, 
				vsPayEstado, 
				vsPayBranch, 
				vsStCancelado
			FROM bdisac:"informix".sac_movimientoshistorial AS mov
			INNER JOIN bdisac:"informix".sac_bts_payi AS payi ON
			(mov.folio_suc=payi.bank_ref_nm AND 
			mov.referencia1=payi.confirmation_nm)
			WHERE 
			mov.numcategoria='07' AND
			mov.numcONvenio='004' AND 
			mov.fecha_pago BETWEEN DATE(vdFechaPri) AND DATE(vdFechaFin) AND
			mov.status_cancelado <> 'S' AND
			mov.flag_confirmacion_central = 1 AND
			mov.flag_confirmacion_sucursal  = 1
			order by mov.fecha_pago,mov.referencia1 
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 {+INDEX (bdisac:bdisac:sac_bts_qryi idx_btsqryi)}
			replace(s_first_name,'`',' '),
			replace(s_middle_name,'`',' '),
			replace(s_last_name,'`',' '), 
			replace(s_mother_m_name,'`',' '),
			origin_am, 
			destinatiON_am 
			INTO vsSFirstName, 
				vsSMiddleName, 
				vsSLastName, 
				vsSMotherName, 
				vsOriginAm, 
				vsDestinationAm
			FROM bdisac:sac_bts_qryi 
			WHERE 
				opcode = '1000' and 
				confirmation_nm = SUBSTR(vsReferencia1,0,11);
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 suc.nombre
			INTO vsNomSucursal
			from bdinteg:si_sucursales SUC
			where SUC.sucursal = vsPayBranch;
			
			IF vsNomSucursal is NULL THEN
				LET vsNomSucursal = '';
			END IF;
						
			execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(vsPayBranch)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,vsLocSucursal,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			IF cSPCodRet <> '00000' THEN
				LET vsLocSucursal = '';			
			END IF;
			
			LET cStmt = 'echo "' || RPAD(NVL(vsReferencia1,' '),11,' ') ||'|'|| 
				RPAD(NVL(vsSFirstName,' '),40,' ') ||'|'|| RPAD(NVL(vsSMiddleName,' '),40,' ') ||'|'|| 
				RPAD(NVL(vsSLastName,' '),40,' ') ||'|'|| 
				RPAD(NVL(vsSMotherName,' '),40,' ') ||'|'|| 'PAGADA' ||'|'|| 
				RPAD(NVL(vsFechaPago,' '),8,' ') ||'|'|| 
				LPAD(NVL(vsOriginAm ,'0'),20,' ') ||'|'|| 
				LPAD(NVL(vsDestinationAm ,'0'),20,' ') ||'|'||
				RPAD(NVL(vsPayFirstName,' '),40,' ') ||'|'|| 
				RPAD(NVL(vsPayMiddleName,''),40,' ') ||'|'|| 
				RPAD(NVL(vsPayLastName,''),40,' ') ||'|'|| 
				RPAD(NVL(vsPayMotherName,''),40,' ') ||'|'|| 
				RPAD(NVL(vsPayFechaNac,''),8,' ') ||'|'|| 
				RPAD(NVL(vsPayNomCalle,''),50,' ') ||'|'|| 
				RPAD(NVL(vsPayNumExt,''),5,' ') ||'|'|| 
				RPAD(NVL(vsPayNumInt,''),5,' ') ||'|'|| 
				RPAD(NVL(vsPayDepto,''),10,' ') ||'|'|| 
				RPAD(NVL(vsPayColonia,''),80,' ') ||'|'|| 
				LPAD(TRIM(NVL(vsPayCp,'')),5,' ') ||'|'|| 
				RPAD(NVL(vsPayMunicipio,''),50,' ') ||'|'|| 
				RPAD(NVL(vsPayCiudad,''),50,' ') ||'|'|| 
				RPAD(NVL(vsPayEstado,''),50,' ') ||'|'|| 
				vsPayBranch ||'|'|| 
				RPAD(NVL(vsNomSucursal,''),40,' ') ||'|'|| 
				RPAD(NVL(vsLocSucursal,''),25,' ') ||'|'|| '" >> ' || vsRutaArchRep;
		
			SYSTEM cStmt;
			
			LET viRegistros = viRegistros + 1 ;
		
		END FOREACH;
		
		IF (viRegistros=0) THEN
		/*SE CREA EL ARCHIVO POR SI LA CONSULTA NO DEVUELVE RESULTADOS*/
			LET cStmt = 'echo "">>' || vsRutaArchRep;
			SYSTEM cStmt;
			
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--SI EL PROCESO TERMINA SATISFACTORIAMENTE 
		UPDATE bdisac:"informix".sac_procesos 
		SET status='1',fecha_proceso=vdFechaHoy
		WHERE proceso = 'GEN_REPBTS'
			and fecha_proceso=vdFechaHoy;
		
		LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE CON '|| viRegistros || ' REGISTROS';
	ELSE
		LET vsMensaje  = 'ERROR: EL DIA NO ES VALIDO PARA LA GENERACION DE REPORTES';
		INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripciON, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,'0',vsMensaje,'sp_genRepRemesasBTS', vdFechaHoy, CURRENT);
	END IF;
	
	RETURN vsCodRetorno, vsMensaje ;

END;
END PROCEDURE;