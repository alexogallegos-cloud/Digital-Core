CREATE PROCEDURE "informix".sp_carga_geolocalizacion_bpi2()
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
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(80);

--VARIABLES TABLA
DEFINE vconteo					INTEGER;
DEFINE vcount 					INTEGER;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(16);
DEFINE v_cuenta_origen 			CHAR(12);
DEFINE v_destino 				CHAR(18);
DEFINE v_ipusuario 				CHAR(15);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;


--SE INICIALIZAN VARIABLES
LET vpaso = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_bpi2 en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_bpi2');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_bpi2.out";
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
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_bpi2_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bpi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT  id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b
		INTO v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b
		FROM bdibpi:bpi_geolocalizacion
		WHERE fecha_oper >= v_fecha_menos_uno AND fecha_oper < v_fecha_hoy AND version_a IS NOT NULL AND referencia_23 IS NULL

		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		
		INSERT INTO "informix".bpi_geolocalizacion_paso (id_registro,id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b, fecha_registro)	
		VALUES(v_idregistro,v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b, v_fecha_menos_uno);
		
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
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bpi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
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
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_bpi2');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 09/01/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindscuentasrelacionadas_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CUENTASRELACIONADAS	VARCHAR(50);

--VARIABLE LAYOUT cta relacionada
DEFINE  v_idregistro				INTEGER;
DEFINE 	v_nocuenta					CHAR(20);
DEFINE 	v_cuentarelacionada			CHAR(20);
DEFINE	v_titularcuenta				CHAR(104);
DEFINE  v_propositocuenta			CHAR(10);
DEFINE  v_idestatuscargaminds		INTEGER;
DEFINE  v_notransaccion				INTEGER;
DEFINE  v_montomensual				DECIMAL(14,2);
DEFINE	v_idrelacion				INTEGER;
DEFINE	v_rfc						CHAR(13);
DEFINE  v_esdeposito				INTEGER;
DEFINE  v_esretiro					INTEGER;
DEFINE  v_eraconocida				INTEGER;
DEFINE	v_tipopersonarel			CHAR(2);
DEFINE  v_fecharegistro 			CHAR(10);
DEFINE 	v_fechaactualizacion		CHAR(10);
DEFINE 	v_idtipocuenta              CHAR(1);


--VARIABLES DE PASO
DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE v_apaterno				CHAR(26);
DEFINE v_amaterno 				CHAR(26);
DEFINE v_idsexo					CHAR(1);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_nocuenta = '';
LET v_cuentarelacionada= '';
LET v_propositocuenta = '5';
LET v_titularcuenta = null;
LET	v_rfc = '';
LET v_idrelacion = 0;
LET v_tipopersonarel = '';
LET v_esdeposito = 0;
LET v_esretiro = 0;
LET v_eraconocida = 0;
LET v_idregistro = 0;
LET v_notransaccion = 0;
LET v_montomensual = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idtipocuenta = '1';
LET v_idsexo = '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscuentasrelacionadas_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CUENTASRELACIONADAS,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscuentasrelacionadas_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscuentasrelacionadas_diario.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CUENTASRELACIONADAS = 'CargaCtaRelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cuentarelacionada_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT se.numcte,se.cuenta,sd.nombre1,sd.nombre2,sd.apell_paterno,sd.apell_materno,se.tipo_relacion,sd.rfc,se.parentesco,se.fecha_insert
		INTO v_nocuenta,v_cuentarelacionada,nombrepf1,nombrepf2,v_apaterno,v_amaterno,v_idrelacion,v_rfc,v_tipopersonarel,temp_fecharegistro
		FROM bdinteg:si_cterelacionado se
		LEFT JOIN bdinteg:si_cliente sd ON se.numcte = sd.numcte
		WHERE sd.tipo_cliente = '1'
		AND se.fecha_insert = v_fecha_ant
        AND se.sistema<>'SV'
		
		LET vpaso = 5;
		
		SELECT sexo
		INTO v_idsexo
		FROM bdinteg:si_ctepf 
		where numcte = v_nocuenta;
		
		LET vpaso = 6;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET v_titularcuenta = TRIM(nombrepf1)||' '||TRIM(nombrepf2)||' '||TRIM(v_apaterno)||' '||TRIM(v_amaterno);
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		IF (v_tipopersonarel IS NULL or v_tipopersonarel = '0' or v_tipopersonarel = '01' or v_tipopersonarel = 'S' 
			or v_tipopersonarel = 'O' or v_tipopersonarel = 'M' or v_tipopersonarel = 'K' or v_tipopersonarel = '') THEN
			LET v_tipopersonarel = '1';
		ELIF (v_tipopersonarel = 'A' ) THEN
			LET v_tipopersonarel = '2';
		ELIF (v_tipopersonarel = 'B' ) THEN
			LET v_tipopersonarel = '11';
		ELIF (v_tipopersonarel = 'C' ) THEN
			LET v_tipopersonarel = '12';
		ELIF (v_tipopersonarel = 'E' ) THEN
			LET v_tipopersonarel = '10';
		ELIF (v_tipopersonarel = 'H' ) THEN
			LET v_tipopersonarel = '6';
		ELIF (v_tipopersonarel = 'I' ) THEN
			LET v_tipopersonarel = '13';
		ELIF (v_tipopersonarel = 'J' ) THEN
			LET v_tipopersonarel = '5';
		ELIF (v_tipopersonarel = 'N' ) THEN
			LET v_tipopersonarel = '7';
		ELIF (v_tipopersonarel = 'R' ) THEN
			LET v_tipopersonarel = '9';
		ELIF (v_tipopersonarel = 'T' ) THEN
			LET v_tipopersonarel = '8';
		ELIF (v_tipopersonarel = 'U' ) THEN
			LET v_tipopersonarel = '14';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'M' ) THEN
			LET v_tipopersonarel = '3';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'F' ) THEN
			LET v_tipopersonarel = '4';
		END IF
			
		LET vpaso = 7;
		
		INSERT INTO "informix".tbl_cuentarelacionada_minds(idregistro,idtipocuenta,nocuenta,cuentarelacionada,titularcuenta,propositocuenta,idestatuscargaminds,fechaactualizacion,notransaccion,montomensual,idrelacion,rfc,esdeposito,esretiro,eraconocida,tipopersonarel,fecharegistro)
		VALUES(vconteo,v_idtipocuenta,v_cuentarelacionada,v_cuentarelacionada,v_titularcuenta,V_propositocuenta,v_idestatuscargaminds,v_fechaactualizacion,v_notransaccion,v_montomensual,v_idrelacion,v_rfc,v_esdeposito,v_esretiro,v_eraconocida,v_tipopersonarel,v_fecharegistro);
		
		LET vpaso = 8;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	LET vpaso = 9;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 10;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'.txt select * FROM bdiauditor:tbl_cuentarelacionada_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 11;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 12;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 13;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CUENTASRELACIONADAS);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscuentasrelacionadas_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;