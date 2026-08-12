CREATE PROCEDURE "informix".sp_carga_geolocalizacion_net2()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(50);
DEFINE vconteo					INTEGER;
DEFINE v_fecha_hr_oper 			DATE;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_num_cliente 			CHAR(9);
DEFINE v_id_usuario 			INTEGER;
DEFINE v_ip_usuario 			CHAR(15);
DEFINE v_fecha_aplic 			DATE;
DEFINE v_referencia 			CHAR(40); 
DEFINE v_latitud 				VARCHAR(10);
DEFINE v_longitud 				VARCHAR(11);
DEFINE v_plataforma 			CHAR(20);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);
DEFINE v_fecha_completa			CHAR(20);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;
DEFINE vcount 					INTEGER;

--SE INICIALIZAN VARIABLES
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET vpaso = 0;


BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_net2 en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_net2');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_net2.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_net2_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	
		---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bei_geolocalizacion_paso;
	COMMIT;
	
	
	
	LET vpaso = 4;
	
	
	LET vcount = 1;

	FOREACH WITH HOLD
	SELECT fecha_hr_oper,id_operacion,num_cliente,id_usuario,ip_usuario,fecha_aplic,referencia,latitud,longitud,plataforma,referencia_23,cve_geo,version_a,version_b
	INTO v_fecha_hr_oper,v_id_operacion,v_num_cliente,v_id_usuario,v_ip_usuario,v_fecha_aplic,v_referencia,v_latitud,v_longitud,v_plataforma,v_referencia_23,v_cve_geo,v_version_a,v_version_b
	FROM  bdibei:bei_bitacora_geolocalizacion
	WHERE fecha_hr_oper >= v_fecha_menos_uno AND fecha_hr_oper < v_fecha_hoy AND version_a IS NOT NULL AND referencia_23 IS NULL
		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		LET v_fecha_completa = year(v_fecha_aplic)||'-'||lpad(month(v_fecha_aplic),2,0)||'-'||lpad(day(v_fecha_aplic),2,0)||' 00:00:00';
		
		INSERT INTO bdiauditor:bei_geolocalizacion_paso (id_registro,fecha_hr_oper,id_operacion,num_cliente,id_usuario,ip_usuario,fecha_aplic,referencia,latitud,longitud,plataforma,referencia_23,cve_geo,version_a,version_b,fecha_registro)	
		VALUES(v_idregistro,v_fecha_hr_oper,v_id_operacion,v_num_cliente,v_id_usuario,v_ip_usuario,v_fecha_completa,v_referencia,v_latitud,v_longitud,v_plataforma,v_referencia_23,v_cve_geo,v_version_a,v_version_b,v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bei_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_net2');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 27/02/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD de EMPRESANET',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_rpt_general_remesas()
RETURNING CHAR(5) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(5);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE cArchivo  				CHAR(50);
DEFINE cRuta					CHAR(50);

DEFINE vnum_confirmacion		VARCHAR (20);
DEFINE vfecha_remesa 			DATE;
DEFINE vhora_remesa 			VARCHAR(8);
DEFINE vordenante_nombre1 		VARCHAR(40);
DEFINE vordenante_nombre2		VARCHAR(40);
DEFINE vordenante_appaterno 	VARCHAR(40);
DEFINE vordenante_apmaterno 	VARCHAR(40);
DEFINE vordenante_direccion		VARCHAR(100);
DEFINE vcolonia_ordenante 		VARCHAR(100);
DEFINE vcp_remitente			VARCHAR(10);
DEFINE vcd_remitente 			VARCHAR(40);
DEFINE vcod_edo_remitente 		VARCHAR(3);
DEFINE vcod_pais_remitente 		VARCHAR(3);
DEFINE vtel_remitente 			VARCHAR(15);
DEFINE vtipo_id_ordenante 		VARCHAR(20);
DEFINE vnumero_id_ordenante 	VARCHAR(30);
DEFINE vciudad_id_ordenante		VARCHAR(40);
DEFINE vcod_pais_origen 		VARCHAR(3);
DEFINE vcod_moneda_origen 		VARCHAR(3);
DEFINE vmonto_dolares 			MONEY(18,2);
DEFINE vmonto_pesos 			MONEY(18,2);
DEFINE vbeneficiario_nombre1 	VARCHAR(30);
DEFINE vbeneficiario_nombre2 	VARCHAR(30);
DEFINE vbeneficiario_appaterno	VARCHAR(30);
DEFINE vbeneficiario_apmaterno 	VARCHAR(30);
DEFINE vbeneficiario_fecha_nac 	DATE;
DEFINE vcod_pais_benef 			VARCHAR(3);
DEFINE vcod_moneda_destino 		VARCHAR(3);
DEFINE vnumero_de_cliente_benef VARCHAR(20);
DEFINE vcuenta_benef 			VARCHAR(30);
DEFINE vbeneficiario_direccion 	VARCHAR(100);
DEFINE vbeneficiario_colonia	VARCHAR(80);
DEFINE vbeneficiario_cp 		VARCHAR(9);	
DEFINE vbeneficiario_ciudad 	VARCHAR(50);
DEFINE vbeneficiario_estado 	VARCHAR(50);
DEFINE vtel_benef 				VARCHAR(15);
DEFINE vtp_id_benef 			VARCHAR(3);
DEFINE vnum_id_benef 			VARCHAR(20);
DEFINE vocupacion_beneficiario 	VARCHAR(30);
DEFINE vsucursal				VARCHAR(4);
DEFINE vnom_sucursal_pagadora   VARCHAR(40);
DEFINE vlocalidad               VARCHAR(81);
DEFINE vestado                  VARCHAR(30);
DEFINE vempleado                VARCHAR(8);
DEFINE vname_benef_suc			VARCHAR(50);
DEFINE vnum_id_benef_suc		VARCHAR(30);
DEFINE vfecha_envio_remesa		DATE;
DEFINE vcta_tar_ctaclabe		CHAR(20);
DEFINE vcuenta					CHAR(20);
DEFINE vcuenta_sucursal			CHAR(4);
DEFINE vnombre_sucursal			CHAR(40);
DEFINE vestado_sucursal			CHAR(30);
DEFINE vciudad_sucursal			VARCHAR(60);
DEFINE vid_estado				CHAR(2);
DEFINE vid_ciudad				CHAR(3);


--VARIABLE DE PASO
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_inicio			DATE;
DEFINE v_fecha_fin				DATE;
DEFINE cDiaI		  			CHAR(2);
DEFINE cMesI		  			CHAR(2);
DEFINE cAnoI		  			CHAR(4);
DEFINE cDiaF		  			CHAR(2);
DEFINE cMesF		  			CHAR(2);
DEFINE cAnoF		  			CHAR(4);
DEFINE cFechaI  				CHAR(8);
DEFINE cFechaF  				CHAR(8);
DEFINE vconteo					INTEGER;

--SE INICIALIZAN VARIABLES
LET vcommit = 0;
LET cRuta	= '/RESPALDOSNEW/'; 

let vnum_confirmacion		 = '';
let vfecha_remesa 			 = '01/01/1900';
let vhora_remesa 			 = '';
let vordenante_nombre1 		 = '';
let vordenante_nombre2		 = '';
let vordenante_appaterno 	 = '';
let vordenante_apmaterno 	 = '';
let vordenante_direccion	 = '';
let vcolonia_ordenante 		 = '';
let vcp_remitente			 = '';
let vcd_remitente 			 = '';
let vcod_edo_remitente 		 = '';
let vcod_pais_remitente 	 = '';
let vtel_remitente 			 = '';
let vtipo_id_ordenante 		 = '';
let vnumero_id_ordenante 	 = '';
let vciudad_id_ordenante	 = '';
let vcod_pais_origen 		 = '';
let vcod_moneda_origen 		 = '';
let vmonto_dolares 			 = 0;
let vmonto_pesos 			 = 0;
let vbeneficiario_nombre1 	 = '';
let vbeneficiario_nombre2 	 = '';
let vbeneficiario_appaterno	 = '';
let vbeneficiario_apmaterno  = '';
let vbeneficiario_fecha_nac  = '01/01/1900';
let vcod_pais_benef 		 = '';
let vcod_moneda_destino 	 = '';
let vnumero_de_cliente_benef = '';
let vcuenta_benef 			 = '';
let vbeneficiario_direccion  = '';
let vbeneficiario_colonia	 = '';
let vbeneficiario_cp 		 = '';	
let vbeneficiario_ciudad 	 = '';
let vbeneficiario_estado 	 = '';
let vtel_benef 				 = '';
let vtp_id_benef 			 = '';
let vnum_id_benef 			 = '';
let vocupacion_beneficiario  = '';
let vsucursal				 = '';
let vnom_sucursal_pagadora   = '';
let vlocalidad               = '';
let vestado                  = '';
let vempleado                = '';
let vname_benef_suc			 = '';
let vnum_id_benef_suc		 = '';
let vfecha_envio_remesa		 = '01/01/1900';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
        LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_rpt_general_remesas en el paso '||vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/sp_rpt_general_remesas.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET v_fecha_inicio = v_fecha_hoy - 7;
	LET v_fecha_fin = v_fecha_ant;
	
	LET cDiaI = LPAD(DAY(v_fecha_inicio), 2, '0');
	LET cMesI = LPAD(MONTH(v_fecha_inicio), 2, '0');
	LET cAnoI = YEAR(v_fecha_inicio);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaI = cAnoI||cMesI||cDiaI;
	
	LET cDiaF = LPAD(DAY(v_fecha_fin), 2, '0');
	LET cMesF = LPAD(MONTH(v_fecha_fin), 2, '0');
	LET cAnoF = YEAR(v_fecha_fin);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaF = cAnoF||cMesF||cDiaF;
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
		TRUNCATE TABLE "informix".rpt_remesasbtsefectivo_temp;
		TRUNCATE TABLE "informix".rpt_remesasbtsabonocuenta_temp;
		TRUNCATE TABLE "informix".rpt_remesasappefectivo_temp;
		TRUNCATE TABLE "informix".rpt_remesasappabonocuenta_temp;
		TRUNCATE TABLE "informix".rpt_remesasovaefectivo_temp;
		TRUNCATE TABLE "informix".rpt_remesasvigefectivo_temp;
		TRUNCATE TABLE "informix".rpt_remesaswunefectivo_temp;
	
	LET vpaso = 4;
	LET cArchivo = TRIM('RemesasBTSef_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX(bdinteg:si_ptf ' 23739_160226'), +INDEX(bdinteg:si_sucursales idx_si_sucursal_tipo), +INDEX (bdisac:sac_pld_remesas idxsac_pld_fecha_tipo_abono)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2), 
		   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante, 
		   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante, 
		   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total, 
		   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno), rm.beneficiario_fecha_nac, rm.cod_pais_benef, 
		   rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef, rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad, rm.beneficiario_estado,
		   rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario,  rm.sucursal, suc.nombre, ciu.nombre, /*TRIM(suc.direccion1) ||' '|| TRIM(suc.direccion2),*/ es.nombre, rm.usuario, rm.name_benef_suc, 
		   rm.num_id_benef_suc, rm.fecha_envio_remesa
		   INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
		   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
		   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
		   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
		   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp, 
		   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, 
		   vnum_id_benef_suc, vfecha_envio_remesa
		   FROM bdisac:sac_pld_remesas rm 
		JOIN bdinteg:si_ptf ptf ON (rm.sucursal = ptf.id_ptf and ptf.tipo='S')  
		JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal and ptf.tipo = suc.tipo)
		JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado )
		WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin
		AND rm.tipo_remesa = 'BTS' 
		AND rm.abono_cuenta = 'NO'
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasbtsefectivo_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa);	
		
		LET vpaso = 6;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 7;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 8;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasbtsefectivo_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 9;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 10;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 11;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 12;
	LET cArchivo = TRIM('RemesasBTSab_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX(bdinteg:si_ptf ' 23739_160226'), +INDEX(bdinteg:si_sucursales idx_si_sucursal_tipo), +INDEX (bdisac:sac_pld_remesas idxsac_pld_fecha_tipo_abono)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2), 
		   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante, 
		   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante, 
		   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total, 
		   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno), 
		   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef, 
		   rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad, rm.beneficiario_estado,
		   rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario, rm.sucursal, suc.nombre, 
		   --TRIM(suc.direccion1) ||' '|| TRIM(suc.direccion2), 
		   ciu.nombre, es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
		   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
		   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
		   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
		   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
		   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
		   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		FROM bdisac:sac_pld_remesas rm 
		join bdinteg:si_ptf ptf ON (rm.sucursal = ptf.id_ptf)
		JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado )
		WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin
		AND rm.tipo_remesa = 'BTS' 
		AND rm.abono_cuenta = 'SI'
		
		LET vcta_tar_ctaclabe = TRIM(vcuenta_benef);
		
		IF SUBSTR(vcta_tar_ctaclabe,1,6) IN ('400819','559471','521595','416916') THEN
			SELECT cuenta INTO vcuenta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = vcta_tar_ctaclabe;
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcuenta;
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;
		
		ELIF SUBSTR(vcta_tar_ctaclabe,1,6) IN ('426807','554948','510148') THEN
		    SELECT num_credito INTO vcuenta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = vcta_tar_ctaclabe;
			SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE num_credito = vcuenta;
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------			
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;

		ELIF SUBSTR(vcta_tar_ctaclabe,1,3) = '137' THEN
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe = vcta_tar_ctaclabe;
			IF NVL(vcuenta_sucursal,'') = '' THEN
				SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE cuenta_clabe = vcta_tar_ctaclabe;
			END IF
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------		
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;
		ELSE
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_tar_ctaclabe;
			IF NVL(vcuenta_sucursal,'') = '' THEN
				SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE num_credito = vcta_tar_ctaclabe;
			END IF
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------		
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;			
		END IF;
		
		LET vpaso = 13;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasbtsabonocuenta_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa, cuenta_sucursal,nombre_sucursal,ciudad_sucursal,estado_sucursal)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa, vcuenta_sucursal, vnombre_sucursal, vciudad_sucursal, vestado_sucursal);	
		
		LET vpaso = 14;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 15;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 16;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasbtsabonocuenta_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 17;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 18;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 19;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 20;
	LET cArchivo = TRIM('RemesasAPPef_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX(bdinteg:si_ptf ' 23739_160226'), +INDEX(bdinteg:si_sucursales idx_si_sucursal_tipo), +INDEX (bdisac:sac_pld_remesas idxsac_pld_fecha_tipo_abono)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2),
			   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante,
			   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante,
			   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total,
			   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno),
			   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef,
			   rm.beneficiario_calle || ' ' || rm.beneficiario_direccion, 
			   rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad,
			   rm.beneficiario_estado, rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, 
			   rm.ocupacion_beneficiario, 
			   rm.sucursal, 
			   suc.nombre,
			   --TRIM(suc.direccion1) ||' '|| TRIM(suc.direccion2),
			   ciu.nombre,
			   es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		  INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac, vcod_pais_benef,
			   vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp,
			   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, 
			   vsucursal,
			   vnom_sucursal_pagadora, 
			   vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		  FROM bdisac:sac_pld_remesas rm 
		  JOIN bdinteg:si_ptf ptf ON (rm.abono_cuenta = 'NO' AND rm.sucursal = ptf.id_ptf and ptf.tipo='S')
		  JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		  JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		  JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado ) 
		 WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin 
		   AND rm.tipo_remesa = 'APP'
		   AND rm.abono_cuenta = 'NO'
		
		LET vpaso = 21;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasappefectivo_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa);	
		
		LET vpaso = 22;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 23;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 24;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasappefectivo_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 25;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 26;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 27;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 28;
	LET cArchivo = TRIM('RemesasAPPab_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX(bdinteg:si_ptf ' 23739_160226'), +INDEX(bdinteg:si_sucursales idx_si_sucursal_tipo), +INDEX (bdisac:sac_pld_remesas idxsac_pld_fecha_tipo_abono), 
		+INDEX (bdinteg:si_ciudades idx_2365b)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2),
			   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante,
			   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante,
			   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total,
			   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno),
			   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef,
			   rm.beneficiario_calle || ' ' || rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad,
			   rm.beneficiario_estado, rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario, rm.sucursal, suc.nombre,
			   ciu.nombre, es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		  INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac, vcod_pais_benef,
			   vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp,
			   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, vsucursal,
			   vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		  FROM bdisac:sac_pld_remesas rm 
		  JOIN bdinteg:si_ptf ptf ON (rm.abono_cuenta = 'SI' AND rm.sucursal = ptf.id_ptf)
		  JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		  JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		  JOIN bdinteg:si_ciudades ciu ON (ptf.cve_estado = ciu.estado AND ptf.cve_ciudad = ciu.ciudad) --******************************
		 WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin 
		   AND rm.tipo_remesa = 'APP'
		   AND rm.abono_cuenta = 'SI'
		   	
		LET vcta_tar_ctaclabe = TRIM(vcuenta_benef);
		
		IF SUBSTR(vcta_tar_ctaclabe,1,6) IN ('400819','559471','521595','416916') THEN
			SELECT cuenta INTO vcuenta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = vcta_tar_ctaclabe;
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcuenta;
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------		
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;
		
		ELIF SUBSTR(vcta_tar_ctaclabe,1,6) IN ('426807','554948','510148') THEN
		    SELECT num_credito INTO vcuenta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = vcta_tar_ctaclabe;
			SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE num_credito = vcuenta;
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------		
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;

		ELIF SUBSTR(vcta_tar_ctaclabe,1,3) = '137' THEN
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe = vcta_tar_ctaclabe;
			IF NVL(vcuenta_sucursal,'') = '' THEN
				SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE cuenta_clabe = vcta_tar_ctaclabe;
			END IF
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------		
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;
		ELSE
			SELECT sucursal INTO vcuenta_sucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_tar_ctaclabe;
			IF NVL(vcuenta_sucursal,'') = '' THEN
				SELECT sucursal INTO vcuenta_sucursal FROM bdicred:"informix".sd_maecred WHERE num_credito = vcta_tar_ctaclabe;
			END IF
			----------------
			SELECT suc.nombre, cve_estado, cve_ciudad
			INTO vnombre_sucursal, vid_estado, vid_ciudad  
			FROM  bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
			WHERE suc.sucursal=ptf.id_ptf and suc.tipo=ptf.tipo and suc.sucursal = vcuenta_sucursal;
			----------------			
			SELECT nombre INTO vestado_sucursal FROM bdinteg:"informix".si_estados WHERE estado = vid_estado;
			SELECT nombre INTO vciudad_sucursal FROM bdinteg:"informix".si_ciudades WHERE estado = vid_estado AND ciudad = vid_ciudad;			
		END IF;	   
		
		LET vpaso = 29;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasappabonocuenta_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa, cuenta_sucursal,nombre_sucursal,ciudad_sucursal,estado_sucursal)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa, vcuenta_sucursal, vnombre_sucursal, vciudad_sucursal, vestado_sucursal);	
		
		LET vpaso = 30;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 31;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 32;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasappabonocuenta_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 33;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 34;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 35;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 36;
	LET cArchivo = TRIM('RemesasOVAef_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX (bdinteg:si_ptf), +INDEX (bdinteg:si_sucursales)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2),
			   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante,
			   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante,
			   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total,
			   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno),
			   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef,
			   rm.beneficiario_calle || ' ' || rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad,
			   rm.beneficiario_estado, rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario, rm.sucursal, suc.nombre,
			   ciu.nombre, es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		  INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac, vcod_pais_benef,
			   vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp,
			   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, vsucursal,
			   vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		  FROM bdisac:sac_pld_remesas rm 
		  JOIN bdinteg:si_ptf ptf ON (rm.sucursal = ptf.id_ptf and ptf.tipo='S')
		  JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		  JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		  JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado )
		 WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin 
		   AND rm.tipo_remesa = 'OVA'
		
		LET vpaso = 37;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasovaefectivo_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa);	
		
		LET vpaso = 38;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 39;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 40;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasovaefectivo_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 41;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 42;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 43;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 44;
	LET cArchivo = TRIM('RemesasVIGef_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX (bdinteg:si_ptf), +INDEX (bdinteg:si_sucursales)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2),
			   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante,
			   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante,
			   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total,
			   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno),
			   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef,
			   rm.beneficiario_calle || ' ' || rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad,
			   rm.beneficiario_estado, rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario, rm.sucursal, suc.nombre,
			   ciu.nombre, es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		  INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac, vcod_pais_benef,
			   vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp,
			   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, vsucursal,
			   vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		  FROM bdisac:sac_pld_remesas rm 
		  JOIN bdinteg:si_ptf ptf ON (rm.sucursal = ptf.id_ptf and ptf.tipo='S')
		  JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		  JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		  JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado )
		 WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin 
		   AND rm.tipo_remesa = 'VIG'
		
		LET vpaso = 45;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesasvigefectivo_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa);	
		
		LET vpaso = 46;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 47;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 48;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesasvigefectivo_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 49;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 50;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 51;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET vpaso = 52;
	LET cArchivo = TRIM('RemesasWUNef_'||TRIM(cFechaI)||'_'||TRIM(cFechaF)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+INDEX (bdinteg:si_ptf), +INDEX (bdinteg:si_sucursales)} rm.num_confirmacion, rm.fecha_remesa, rm.hora_remesa, TRIM(rm.ordenante_nombre1), TRIM(rm.ordenante_nombre2),
			   TRIM(rm.ordenante_appaterno), TRIM(rm.ordenante_apmaterno), rm.ordenante_direccion, rm.colonia_ordenante,
			   rm.cp_remitente, rm.cd_remitente, rm.cod_edo_remitente, rm.cod_pais_remitente, rm.tel_remitente, rm.tipo_id_ordenante,
			   rm.numero_id_ordenante, rm.ciudad_id_ordenante, rm.cod_pais_origen, rm.cod_moneda_origen, rm.monto_dolares, rm.monto_total,
			   TRIM(rm.beneficiario_nombre1), TRIM(rm.beneficiario_nombre2), TRIM(rm.beneficiario_appaterno), TRIM(rm.beneficiario_apmaterno),
			   rm.beneficiario_fecha_nac, rm.cod_pais_benef, rm.cod_moneda_destino, rm.numero_de_cliente_benef, rm.cuenta_benef,
			   rm.beneficiario_calle || ' ' || rm.beneficiario_direccion, rm.beneficiario_colonia, rm.beneficiario_cp, rm.beneficiario_ciudad,
			   rm.beneficiario_estado, rm.tel_benef, rm.tp_id_benef, rm.num_id_benef, rm.ocupacion_beneficiario, rm.sucursal, suc.nombre,
			   ciu.nombre, es.nombre, rm.usuario, rm.name_benef_suc, rm.num_id_benef_suc, rm.fecha_envio_remesa
		  INTO vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac, vcod_pais_benef,
			   vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia, vbeneficiario_cp,
			   vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario, vsucursal,
			   vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa
		  FROM bdisac:sac_pld_remesas rm 
		  JOIN bdinteg:si_ptf ptf ON (rm.sucursal = ptf.id_ptf and ptf.tipo='S')
		  JOIN bdinteg:si_sucursales suc ON ( ptf.id_ptf = suc.sucursal )
		  JOIN bdinteg:si_estados es ON ( ptf.cve_estado = es.estado )
		  JOIN bdinteg:si_ciudades ciu ON ( ptf.cve_ciudad = ciu.ciudad and ptf.cve_estado = ciu.estado ) --
		 WHERE rm.fecha_remesa BETWEEN v_fecha_inicio AND v_fecha_fin 
		   AND rm.tipo_remesa = 'WUN'
		
		LET vpaso = 53;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		INSERT INTO "informix".rpt_remesaswunefectivo_temp (num_confirmacion,fecha_remesa,hora_remesa,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,
															ordenante_direccion,colonia_ordenante,cp_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,tel_remitente,
															tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,monto_dolares,monto_total,
															beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,
															cod_pais_benef,cod_moneda_destino,numero_de_cliente_benef,cuenta_benef,beneficiario_direccion,beneficiario_colonia,
															beneficiario_cp,beneficiario_ciudad,beneficiario_estado,tel_benef,tp_id_benef,num_id_benef,ocupacion_beneficiario,
															sucursal,nom_sucursal_pagadora,localidad,estado,empleado,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
		VALUES (vnum_confirmacion, vfecha_remesa, vhora_remesa, vordenante_nombre1, vordenante_nombre2, vordenante_appaterno, vordenante_apmaterno,
			   vordenante_direccion, vcolonia_ordenante, vcp_remitente, vcd_remitente, vcod_edo_remitente, vcod_pais_remitente, vtel_remitente,
			   vtipo_id_ordenante, vnumero_id_ordenante, vciudad_id_ordenante, vcod_pais_origen, vcod_moneda_origen, vmonto_dolares, vmonto_pesos,
			   vbeneficiario_nombre1, vbeneficiario_nombre2, vbeneficiario_appaterno, vbeneficiario_apmaterno, vbeneficiario_fecha_nac,
			   vcod_pais_benef, vcod_moneda_destino, vnumero_de_cliente_benef, vcuenta_benef, vbeneficiario_direccion, vbeneficiario_colonia,
			   vbeneficiario_cp, vbeneficiario_ciudad, vbeneficiario_estado, vtel_benef, vtp_id_benef, vnum_id_benef, vocupacion_beneficiario,
			   vsucursal, vnom_sucursal_pagadora, vlocalidad, vestado, vempleado, vname_benef_suc, vnum_id_benef_suc, vfecha_envio_remesa);	
		
		LET vpaso = 54;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 55;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 56;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdiauditor:rpt_remesaswunefectivo_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 57;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 58;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 59;
	
	INSERT INTO "informix".tbl_logremesas_pld(fechaejecucion,archivo,fechainicio,fechafin)
	VALUES (v_fecha_hoy,cArchivo,v_fecha_inicio,v_fecha_fin);
	
	LET cod_ret = '00000';
    LET vmensaje = 'PROCESO EXITOSO';
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 30/10/2020',
'DESCRIPCION: GeneraciÃ?Â³n de remesadoras para el area de PLD',
'BD: bdiauditor',
'AUTOR: Gilberto Fco. Naranjo Valles',
'FECHA: 28/05/2024',
'DESCRIPCION: Se agrega el nombre de las ciudades',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_inserta_spei (
                                                    sppld_insertaspei_e_opcion               INTEGER
                                                  , sppld_insertaspei_e_dtfechaproceso       CHAR    (10)
                                                  , sppld_insertaspei_e_chrproceso           CHAR    (20)
                                                  , sppld_insertaspei_e_chrproducto          CHAR    (20)
                                                  , sppld_insertaspei_e_ctl_chrstatus        CHAR    (01)
                                                  , sppld_insertaspei_e_ctl_intregprocesados INTEGER
                                                  , sppld_insertaspei_e_ctl_vchrultregcommit CHAR    (50)
                                                  , sppld_insertaspei_e_ctl_dtinicio         CHAR    (30)
                                                  , sppld_insertaspei_e_ctl_intsecuencia     INTEGER
                                                  , sppld_insertaspei_e_ctl_dtfin            CHAR    (30)
                                                  , sppld_insertaspei_e_ctl_inttransefe      INTEGER
                                                  , sppld_insertaspei_e_ctl_inttransale      INTEGER
                                                  , sppld_insertaspei_e_ctl_mnytransefe      DECIMAL (19,2)
                                                  , sppld_insertaspei_e_ctl_mnytransale      DECIMAL (19,2)
                                                  , sppld_insertaspei_e_prm_chrperiodicidad  CHAR    (01)
                                                  , sppld_insertaspei_e_prm_intdiaejec       INTEGER
                                                  , sppld_insertaspei_e_prm_intregcommit     INTEGER
                                                  , sppld_insertaspei_e_prm_chrparam         CHAR    (80)
                                                  )
       RETURNING
                                                    INTEGER        AS sppld_insertaspei_s_returncode
                                                  , CHAR    (99)   AS sppld_insertaspei_s_mensaje
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_intregprocesados
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_inttransefe
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_inttransale
                                                  , DECIMAL (19,2) AS sppld_insertaspei_s_ctl_mnytransefe
                                                  , DECIMAL (19,2) AS sppld_insertaspei_s_ctl_mnytransale
                                                  ;


-- Declaracion de Excepciones
    define sql_err      integer;
    DEFINE sppld_insertaspei_s_returncode          INTEGER         ;
    DEFINE sppld_insertaspei_s_mensaje             CHAR    (99)    ;
    DEFINE sppld_insertaspei_s_ctl_intregprocesados INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_inttransefe      INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_inttransale      INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_mnytransefe      DECIMAL (19,2) ;
    DEFINE sppld_insertaspei_s_ctl_mnytransale      DECIMAL (19,2) ;

-- Declaracin de Variables para el cursor principal

    define c_dtfechavalor      date;    
    define c_intpkpago         integer;
    define c_cvecesifbcoord    integer;
    define c_cvecesifbcodest   integer;
    define c_vchrnombreord     char(40);
    define c_vchrcuentaord     char(20);
    define c_vchrnombrebenef   char(40);
    define c_vchrcuentabenef   char(20);
    define c_mnyimporte        decimal(19,2);
    define c_vchrconceptopago2  char(210);
    define c_intcvetipopago    integer;
    define c_chrestatusenvio   char(01);  
	define c_chrsentidopago    char(01); -- variables agregadas para detectar confirmacion CEP



-- declaracion de variables de trabajo
    define wk_num_cte    char(20);
    define wk_transacc_efectuadas integer;
    define wk_monto_total_efectuado decimal(18,2);
    define wk_periodo        char(6);
    define wk_periodo_num    integer;
    define wk_intpkpago      integer;
    define wk_dtfechavalor   char(10);
    define wk_monto_tot      decimal(19,2);
    define wk_tipo_per       char(10);
    define wk_alertado       char(10);
    define s1_num_serial integer;
    define s1_folio_suc  char(16);
    define s1_fech_alt   date;
    define s1_cuenta     char(20);
    define s1_monto_tot  decimal(18,2);
    define s1_referencia char(40);
    define s1_transacc   char(04);
    define s1_cancelad   char(01);
    define s1_usuautoriza   char(08);
    define s2_num_cte    char(20);
    define s2_sucursal   char(04);
    define s3_num_cte    char(20);
    define s4_monto_acumulado decimal(18,2);
    define s4_transaccion_total integer;
    define s5_numcte    char(20);
    define s6_monto_acumulado decimal(19,2);
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    DEFINE wk_cuenta                     CHAR (20)               ;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    DEFINE wk_dtfechaproceso             DATE                    ;
    DEFINE wk_intregcommit               INTEGER                 ;
    DEFINE err_excepcion                 INTEGER                 ;
    DEFINE err_referencia                CHAR (99)               ;

-- Inicializamos el codigo de retorno con valor de OK para que en caso de que no ocurra ningun error este permanezca con el valor de OK

LET sppld_insertaspei_s_returncode   = 0   ;
LET sppld_insertaspei_s_mensaje      = "OK";

-- Validar que los parametros que necesita no vengan nulos o sin informacion (vacios segun su naturaleza)

IF sppld_insertaspei_e_opcion IS NULL THEN
   LET sppld_insertaspei_s_returncode = 1;
   LET sppld_insertaspei_s_mensaje = "Campo opcion viene nulo";
   RETURN   sppld_insertaspei_s_returncode
          , sppld_insertaspei_s_mensaje
          , 0
          , 0
          , 0
          , 0
          , 0
          ;
ELSE
   IF NOT sppld_insertaspei_e_opcion = 1 THEN
      LET sppld_insertaspei_s_returncode = 2;
      LET sppld_insertaspei_s_mensaje    = "Campo opcion valor invalido";
      RETURN   sppld_insertaspei_s_returncode
             , sppld_insertaspei_s_mensaje
             , 0
             , 0
             , 0
             , 0
             , 0
             ;
   END IF;
END IF;
IF sppld_insertaspei_e_dtfechaproceso IS NULL THEN
   LET sppld_insertaspei_s_returncode = 1;
   LET sppld_insertaspei_s_mensaje = "Campo fecha de inicio viene nulo";
   RETURN   sppld_insertaspei_s_returncode
          , sppld_insertaspei_s_mensaje
          , 0
          , 0
          , 0
          , 0
          , 0
          ;
ELSE
   IF sppld_insertaspei_e_dtfechaproceso = "" THEN
      LET sppld_insertaspei_s_returncode = 2;
      LET sppld_insertaspei_s_mensaje    = "Campo fecha de inicio tiene un valor invalido";
      RETURN   sppld_insertaspei_s_returncode
             , sppld_insertaspei_s_mensaje
             , 0
             , 0
             , 0
             , 0
             , 0
             ;
   END IF;
END IF;

-- Inicializar todos los campos que regresa segun su naturaleza para evitar una respuesta nula

LET sppld_insertaspei_s_ctl_intregprocesados = 0   ;
LET sppld_insertaspei_s_ctl_inttransefe      = 0   ;
LET sppld_insertaspei_s_ctl_inttransale      = 0   ;
LET sppld_insertaspei_s_ctl_mnytransefe      = 0   ;
LET sppld_insertaspei_s_ctl_mnytransale      = 0   ;

-- Inicializar los campos de trabajo segun su naturaleza o su valor inicial para evitar nulos

LET wk_intregcommit      = 0   ;
LET err_excepcion        = 0   ;
LET err_referencia       = " " ;

BEGIN

-- Se declara las instrucciones para las excepciones

   ON EXCEPTION SET err_excepcion
      IF err_excepcion <> 0 THEN
         IF (err_excepcion = -1204) OR (err_excepcion = -1205) OR (err_excepcion = -1206) OR (err_excepcion = -1218) THEN
            LET sppld_insertaspei_s_returncode = 3;
            LET sppld_insertaspei_s_mensaje    = "Formato invalido en fecha de operador";
            ROLLBACK WORK;
            RETURN   sppld_insertaspei_s_returncode
                   , sppld_insertaspei_s_mensaje
                   , 0
                   , 0
                   , 0
                   , 0
                   , 0
                   ;
         ELSE
            LET sppld_insertaspei_s_returncode = 99;
            LET sppld_insertaspei_s_mensaje    = "Error " || err_excepcion || " " || err_referencia;
           ROLLBACK WORK;
            RETURN   sppld_insertaspei_s_returncode
                   , sppld_insertaspei_s_mensaje
                   , 0
                   , 0
                   , 0
                   , 0
                   , 0
                   ;
         END IF;
      END IF;
   END EXCEPTION;

   BEGIN WORK;

-- Validamos que la fecha que nos envio el operador sea valida asignandola a un campo declarado como tipo fecha

      LET wk_dtfechaproceso = sppld_insertaspei_e_dtfechaproceso;

LET wk_periodo = YEAR(DATE(sppld_insertaspei_e_dtfechaproceso)) || MONTH(DATE(sppld_insertaspei_e_dtfechaproceso)); 
LET wk_periodo_num = wk_periodo;
 

LET wk_transacc_efectuadas = 0;

LET wk_intpkpago = sppld_insertaspei_e_ctl_vchrultregcommit;


LET s2_num_cte = ' ';
LET s3_num_cte = ' ';


FOREACH cur1 WITH HOLD FOR SELECT
                           {+INDEX(bdispei:tblhistpago idx_hfv)}
                             dtfechavalor                           
                           , intpkpago
                           , cvecesifbcoord
                           , cvecesifbcodest
                           , vchrnombreord
                           , vchrcuentaord
                           , vchrnombrebenef
                           , vchrcuentabenef
                           , mnyimporte
                           , vchrconceptopago2
                           , intcvetipopago
                           , chrestatusenvio
						   , chrsentidopago  --CJACO modificacion 03/07/2012  se agrego la extraccion de este campo para identificar si es recibido por partes de 3eros
                       INTO  c_dtfechavalor                           
                           , c_intpkpago
                           , c_cvecesifbcoord
                           , c_cvecesifbcodest
                           , c_vchrnombreord
                           , c_vchrcuentaord
                           , c_vchrnombrebenef
                           , c_vchrcuentabenef
                           , c_mnyimporte
                           , c_vchrconceptopago2
                           , c_intcvetipopago
                           , c_chrestatusenvio
						   , c_chrsentidopago --CJACO modificacion 03/07/2012  se agrego una variable para identificar si es recibido por parte 3eros
                   FROM bdispei:tblhistpago
                   WHERE dtfechavalor = wk_dtfechaproceso
                     AND intpkpago > wk_intpkpago
					group by 1,3,4,5,6,7,8,9,10,11,12,13,intpkpago having count(*) = 1
                   ORDER BY intpkpago ASC

LET err_referencia = "bdispei:tblhistpago " || "SELECT " || c_intpkpago ;

---CJACO Modificacion 03/07/2012  
if c_chrsentidopago = 'R' then 
	if c_chrestatusenvio = 'C' then
	 let c_chrestatusenvio ='L';
	end if;
end if;

--CJACO fin modificacion  03/07/2012 


IF (c_intcvetipopago in (1,7,5) AND (c_chrestatusenvio = "A" OR c_chrestatusenvio = "L")) THEN   
 

    IF c_vchrconceptopago2 is null THEN
       LET c_vchrconceptopago2 = " ";
    END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
-- En esta condicion procesamos cuando el banco ordenante es BanCoppel

    IF c_cvecesifbcoord = 40137 THEN
       IF SUBSTR(c_vchrcuentaord,1,3) = '137' AND SUBSTR(c_vchrcuentaord,18,1) <> ' ' THEN
          LET err_referencia = "bdicheq:sc_maechq " || "cuenta_clabe" || "SELECT " || c_vchrcuentaord ; 
-- Se comentariza este acceso por que cuenta_clabe no es indice por lo cual extraemos la cuenta de cuenta_clabe
--          SELECT   num_cte
--                 , cuenta
--            INTO   s2_num_cte
--                 , wk_cuenta
--            FROM bdicheq:sc_maechq
--           WHERE cuenta_clabe = c_vchrcuentaord;
          LET wk_cuenta = SUBSTR(c_vchrcuentaord,7,11);
          SELECT
               {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                 num_cte
            INTO s2_num_cte
            FROM bdicheq:sc_maechq
           WHERE empresa = '001'
             AND cuenta = wk_cuenta;
          IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
             LET s2_num_cte = "no encontrado mod 1";
          ELSE
             LET c_vchrcuentaord = wk_cuenta;
          END IF; 
       ELSE
          IF SUBSTR(c_vchrcuentaord,1,6) = '400819' AND SUBSTR(c_vchrcuentaord,1,16) <> ' ' THEN
             LET err_referencia = "bdicheq:sc_tarjeta " || "SELECT " || c_vchrcuentaord ; 
             SELECT
                    {+INDEX(bdicheq:sc_tarjeta ix_tarjeta2)}
                      numcte
                    , cuenta
               INTO   s2_num_cte
                    , wk_cuenta
               FROM bdicheq:sc_tarjeta
              WHERE empresa = '001'
                AND num_tarjeta = c_vchrcuentaord;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 2";
             ELSE
                LET c_vchrcuentaord = wk_cuenta;
             END IF; 
          ELSE
             LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentaord ; 
             SELECT
                  {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                    num_cte
               INTO s2_num_cte
               FROM bdicheq:sc_maechq
              WHERE empresa = '001'
                AND cuenta = c_vchrcuentaord;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 3";
             END IF; 
          END IF;
       END IF;
    END IF;
-- En esta condicion procesamos cuando el banco beneficiaro es BanCoppel
    IF c_cvecesifbcodest = 40137 THEN
       IF SUBSTR(c_vchrcuentabenef,1,3) = '137' AND SUBSTR(c_vchrcuentabenef,18,1) <> ' ' THEN
          LET err_referencia = "bdicheq:sc_maechq " || "cuenta_clabe" || "SELECT " || c_vchrcuentabenef ; 
-- Se comentariza este acceso por que cuenta_clabe no es indice por lo cual extraemos la cuenta de cuenta_clabe
--          SELECT   num_cte
--                 , cuenta
--            INTO   s2_num_cte
--                 , wk_cuenta
--            FROM bdicheq:sc_maechq
--           WHERE cuenta_clabe = c_vchrcuentabenef;
          LET wk_cuenta = SUBSTR(c_vchrcuentabenef,7,11);
          SELECT
               {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                 num_cte
            INTO s2_num_cte
            FROM bdicheq:sc_maechq
           WHERE empresa = '001'
             AND cuenta = wk_cuenta;
         IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
             LET s2_num_cte = "no encontrado mod 4";
         ELSE
            LET c_vchrcuentabenef = wk_cuenta;
         END IF; 
       ELSE
          IF SUBSTR(c_vchrcuentabenef,1,6) = '400819' AND SUBSTR(c_vchrcuentabenef,1,16) <> ' ' THEN
             LET err_referencia = "bdicheq:sc_tarjeta " || "SELECT " || c_vchrcuentabenef ; 
             SELECT
                    {+INDEX(bdicheq:sc_tarjeta ix_tarjeta2)}
                      numcte
                    , cuenta
               INTO   s2_num_cte
                    , wk_cuenta
               FROM bdicheq:sc_tarjeta
              WHERE empresa = '001'
                AND num_tarjeta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 5";
             ELSE
                LET c_vchrcuentabenef = wk_cuenta;
             END IF; 
          ELSE
             LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentabenef ; 
             SELECT
                  {+INDEX(sc_maechq idx_maechq1)}
                    num_cte
               INTO s2_num_cte
               FROM bdicheq:sc_maechq
              WHERE empresa = '001'
                AND cuenta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 6";
             END IF; 
          END IF;
       END IF;
    END IF;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    LET err_referencia = "bdiauditor:tblpldtranspei " || "INSERT " || c_dtfechavalor || " " || c_intpkpago || " " || c_cvecesifbcoord || " " || c_cvecesifbcodest || " " || c_vchrnombreord || " " || c_vchrcuentaord || " " || c_vchrnombrebenef || " " || c_vchrcuentabenef || " " || c_mnyimporte || " " || c_vchrconceptopago2;
    INSERT INTO bdiauditor:tblpldtranspei
         (  dtfechavalor          
          , intpkpago
          , cvecesifbcoord
          , cvecesifbcodest
          , vchrnombreord
          , vchrcuentaord
          , vchrnombrebenef
          , vchrcuentabenef
          , mnyimporte
          , vchrconceptopago   )
          VALUES
         (  c_dtfechavalor          
          , c_intpkpago
          , c_cvecesifbcoord
          , c_cvecesifbcodest
          , nvl(c_vchrnombreord,' ')
          , nvl(c_vchrcuentaord,' ')
          , nvl(c_vchrnombrebenef,' ')
          , nvl(c_vchrcuentabenef,' ')
          , c_mnyimporte
          , c_vchrconceptopago2   )
          ;
          LET sppld_insertaspei_e_ctl_intregprocesados = sppld_insertaspei_e_ctl_intregprocesados + 1 ;
          LET wk_intregcommit = wk_intregcommit + 1 ;
          IF (dbinfo('sqlca.sqlerrd2') <> 1)  THEN
                LET sppld_insertaspei_s_returncode = 1;
                LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtranspei";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                ROLLBACK WORK;
                RETURN   sppld_insertaspei_s_returncode
                       , sppld_insertaspei_s_mensaje
                       , 0
                       , 0
                       , 0
                       , 0
                       , 0
                       ;
          END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
-- Solo se graban en totales cuando la cuenta beneficiaria es de BanCoppel
       IF c_cvecesifbcodest = 40137 THEN
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
          IF (dbinfo('sqlca.sqlerrd2')=1)  THEN
             LET err_referencia = "bdiauditor:tblpldtotspei " || "SELECT " || c_vchrcuentabenef ;
             SELECT
                  {+INDEX(bdiauditor:tblpldtotspei indpldtotspei)}
                    monto_acumulado
                   ,transaccion_total
               INTO s4_monto_acumulado 
                   ,s4_transaccion_total
               FROM bdiauditor:tblpldtotspei
              WHERE periodo = wk_periodo_num  AND
                    cuenta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')=1)  THEN
                LET err_referencia = "bdiauditor:tblpldtotspei " || "UPDATE " || c_vchrcuentabenef || " " || s4_monto_acumulado || " " || c_mnyimporte || " " || s4_transaccion_total;
                UPDATE
                     {+INDEX(bdiauditor:tblpldtotspei indpldtotspei)}
                       bdiauditor:tblpldtotspei 
                   SET monto_acumulado = s4_monto_acumulado + c_mnyimporte
                      ,transaccion_total = s4_transaccion_total + 1
                 WHERE periodo = wk_periodo_num  AND
                       cuenta = c_vchrcuentabenef;
                IF (dbinfo('sqlca.sqlerrd2')<>1) THEN
                  LET sppld_insertaspei_s_returncode = 1;
                  LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtotspai";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                  ROLLBACK WORK;
                  RETURN   sppld_insertaspei_s_returncode
                         , sppld_insertaspei_s_mensaje
                         , 0
                         , 0
                         , 0
                         , 0
                         , 0
                         ;   
                  END IF;
             ELSE 
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
--               LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentabenef ; 
--               SELECT num_cte
--                 INTO s2_num_ctE
--                 FROM bdicheq:sc_maechq
--                WHERE cuenta = c_vchrcuentabenef;
--               IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
--                  LET s2_num_ctE = "no encontrado mod 7";
--               END IF; 
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
                  LET err_referencia = "bdiauditor:tblpldtotspei " || "INSERT " || wk_periodo_num || " " || c_vchrcuentabenef || " " || s2_num_cte || " " || c_mnyimporte || " " || "N" || " " || "1";                                  
                 if c_intcvetipopago <> 7 then
				  INSERT INTO bdiauditor:tblpldtotspei
                       (  periodo
                        , cuenta 
                        , num_cte
                        , monto_acumulado
                        , alertado
                        , transaccion_total)
                   VALUES
                        ( wk_periodo_num
                        , c_vchrcuentabenef
                        , s2_num_cte
                        , c_mnyimporte
                        , "N"
                        ,  1)
                        ;
               IF (dbinfo('sqlca.sqlerrd2')<>1) THEN
                LET sppld_insertaspei_s_returncode = 1;
                LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtotspai";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                ROLLBACK WORK;
                RETURN   sppld_insertaspei_s_returncode
                       , sppld_insertaspei_s_mensaje
                       , 0
                       , 0
                       , 0
                       , 0
                       , 0
                       ;  
               END IF;
			   end if;
             END IF;  
          END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
       END IF;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
END IF;

-- validamos si es momento de hacer COMMMIT de acuerdo a los parametros

         IF wk_intregcommit >= sppld_insertaspei_e_prm_intregcommit THEN
            LET err_referencia = "bdiauditor:tblpldcontrol " || "UPDATE CICLO " || sppld_insertaspei_e_chrproceso || " " || sppld_insertaspei_e_chrproducto ;
            UPDATE
                   {+INDEX(bdiauditor:tblpldcontrol indpldcontrol)}
                     bdiauditor:tblpldcontrol
               SET   intregprocesados = sppld_insertaspei_e_ctl_intregprocesados
-- NOTA: Aqui debemos de guardar la clave por la que esta ordenada el cursor para poder tener el punto de reinicio
                   , vchrultregcommit = c_intpkpago
-- Fin de NOTA
                   , dtfin            = CURRENT
                   , inttransefe      = sppld_insertaspei_e_ctl_inttransefe
                   , inttransale      = sppld_insertaspei_e_ctl_inttransale
                   , mnytransefe      = sppld_insertaspei_e_ctl_mnytransefe
                   , mnytransale      = sppld_insertaspei_e_ctl_mnytransale
             WHERE   chrproceso       = sppld_insertaspei_e_chrproceso
               AND   chrproducto      = sppld_insertaspei_e_chrproducto
                   ;
            COMMIT WORK;
            BEGIN WORK;
            LET wk_intregcommit = 0;
         END IF;

END FOREACH;

--Se modifica proceso para reemplazar datos con caracteres extraÃÂ±os que vengan de la bdspei. GLI 21/02/2013

		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã?Ã?%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã?Ã?','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã?Ã?%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã?Ã?%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã?Ã?','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã?Ã?%';
		
		end if 
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã¿%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã¿','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã¿%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã¿%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã¿','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã¿%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%ÃÂ­%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'ÃÂ­','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%ÃÂ­%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%ÃÂ­%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'ÃÂ­','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%ÃÂ­%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã%';
		
		end if 
				
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%?%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '?',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%?%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%?%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '?',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%?%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%#%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '#',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%#%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%#%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '#',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%#%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%"%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '"',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%"%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%"%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '"',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%"%';
		
		end if 
		-------------------
		
				if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%/%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '/',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%/%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%/%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '/',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%/%';
		
		end if 

		
-- Ejecutamos ultimo COMMIT

      IF wk_intregcommit > 0 THEN
         LET err_referencia = "bdiauditor:tblpldcontrol " || "UPDATE FINAL " || sppld_insertaspei_e_chrproceso || " " || sppld_insertaspei_e_chrproducto ;
         UPDATE
                {+INDEX(bdiauditor:tblpldcontrol indpldcontrol)} 
                  bdiauditor:tblpldcontrol
            SET   intregprocesados = sppld_insertaspei_e_ctl_intregprocesados
-- NOTA: Aqui debemos de guardar la clave por la que esta ordenada el cursor para poder tener el punto de reinicio
                , vchrultregcommit = c_intpkpago
-- Fin de NOTA
                , dtfin            = CURRENT
                , inttransefe      = sppld_insertaspei_e_ctl_inttransefe
                , inttransale      = sppld_insertaspei_e_ctl_inttransale
                , mnytransefe      = sppld_insertaspei_e_ctl_mnytransefe
                , mnytransale      = sppld_insertaspei_e_ctl_mnytransale
          WHERE   chrproceso       = sppld_insertaspei_e_chrproceso
            AND   chrproducto      = sppld_insertaspei_e_chrproducto
                ;
      END IF;
      COMMIT WORK;

END;

-- Regresamos el control con el codigo de retorno
RETURN   sppld_insertaspei_s_returncode
       , sppld_insertaspei_s_mensaje
       , sppld_insertaspei_s_ctl_intregprocesados
       , sppld_insertaspei_s_ctl_inttransefe
       , sppld_insertaspei_s_ctl_inttransale
       , sppld_insertaspei_s_ctl_mnytransefe
       , sppld_insertaspei_s_ctl_mnytransale
       ;

END PROCEDURE;