CREATE PROCEDURE "informix".sp_mindsperfil_diario()
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
DEFINE TIPO_PLANTILLA_PERFIL	VARCHAR(50);

--VARIABLE LAYOUT BANCA TRADICIONAL
DEFINE v_idtipooperacion    	CHAR(10);
DEFINE v_nocuenta           	CHAR(50);
DEFINE v_notransacciones    	INTEGER;
DEFINE v_montomensual       	MONEY;
DEFINE v_fechaactualizacion 	CHAR(10);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_num_cte				CHAR(20);
DEFINE vconteo					INTEGER;
DEFINE v_fecha					CHAR(10);
--VARIABLES DE PASO
DEFINE temp_fecha				DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET vconteo = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsperfil_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_PERFIL,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsperfil_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindsperfil_his.out';
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
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_PERFIL = 'CargaPerfilMinds_'||TRIM(cFecha);
    
	
	LET vpaso = 3;
	---Eliminacion de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_perfil_minds;
	COMMIT;
			
	LET vpaso = 4;
	
	FOREACH WITH HOLD
			SELECT {+INDEX(bdicheq:sc_maechq idx_maechq1)} 
			'1' AS operacion, sc.cuenta, sit.a AS cantidad, si.a AS monto,noc.fecha_alta
			INTO v_idtipooperacion,v_nocuenta,v_notransacciones,v_montomensual,temp_fecha
			FROM bdicheq:sc_maechq sc, bdinteg:si_tipo_montomov si, bdinteg:si_tipo_nummov sit, bdicheq:sc_maenoc noc
			WHERE sc.empresa = '001'
			AND sc.depositos_monto = si.codnummonto
			AND sc.depositos_cantidad = sit.codnummo
			AND sc.cuenta = noc.cuenta
			AND noc.fecha_alta = v_fecha_ant
			UNION ALL
			SELECT {+INDEX(bdicheq:sc_maechq idx_maechq1)} 
			'2' AS operacion, sc.cuenta, sit.a AS cantidad, si.a AS monto,noc.fecha_alta
			--INTO v_idtipooperacion,v_nocuenta,v_notransacciones,v_montomensual,temp_fecha
			FROM bdicheq:sc_maechq sc, bdinteg:si_tipo_montomov si, bdinteg:si_tipo_nummov sit, bdicheq:sc_maenoc noc
			WHERE sc.empresa = '001'
			AND sc.retiros_monto = si.codnummonto
			AND sc.retiros_cantidad = sit.codnummo
			AND sc.cuenta = noc.cuenta 
			AND noc.fecha_alta = v_fecha_ant
	
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET vpaso = 5;
		
		IF v_notransacciones = 99999999 THEN
			LET v_notransacciones = 9999;
		END IF
		
		LET vpaso = 6;
		
		IF temp_fecha IS NULL THEN
			LET v_fechaactualizacion = '1900-01-01';
		ELSE
			LET v_fechaactualizacion = to_char(temp_fecha, '%Y-%m-%d');
		END IF
		
		LET v_fecha	= to_char(v_fecha_ant, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 7;
		
		INSERT INTO "informix".tbl_perfil_minds (idregistro,idtipooperacion,nocuenta ,notransacciones,montomensual,idestatuscargaminds,fechaactualizacion,fecharegistro)
		VALUES (vconteo,v_idtipooperacion,v_nocuenta ,v_notransacciones,v_montomensual,v_idestatuscargaminds,v_fechaactualizacion,v_fecha);
		
		LET vpaso = 8;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 9;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE BANCA TRADICIONAL
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_PERFIL||'.txt select * FROM bdiauditor:tbl_perfil_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_PERFIL||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 10;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_PERFIL||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_PERFIL||'_01.sql';
	system vsql;
	
	LET vpaso = 11;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_PERFIL||'_01.sql';
	system vsql;
	
	LET vpaso = 12;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_PERFIL);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindsperfil_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;