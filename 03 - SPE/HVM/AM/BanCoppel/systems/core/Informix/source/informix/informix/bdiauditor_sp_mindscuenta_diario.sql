CREATE PROCEDURE "informix".sp_mindscuenta_diario()
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
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(50);

--VARIABLE LAYOUT CUENTA
DEFINE v_nic					CHAR(20);
DEFINE v_nocuenta				CHAR(20);
DEFINE v_fechaapertura			CHAR(10);
DEFINE v_clavemoneda 			INTEGER;
DEFINE v_activo					INTEGER;
DEFINE v_clabe					CHAR(18);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_idpropositocuenta		CHAR(2);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_idplazopago			INTEGER;
DEFINE v_total_cr_amt			DECIMAL(18,2);
DEFINE v_fechavencimiento		CHAR(10);
DEFINE v_monto_aportacion		DECIMAL(18,2);
DEFINE vconteo					INTEGER;
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_sucursal				CHAR(5);
DEFINE v_estado					INTEGER;
DEFINE v_ciudad					INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_ipaisgeo				CHAR(3);
DEFINE v_paisgeo				CHAR(2);

--VARIABLES DE PASO
DEFINE v_status					CHAR(2);
DEFINE temp_fechaapertura		DATE;
DEFINE temp_fechavencimiento	DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE v_opinternacional		CHAR(1);
DEFINE cVenMon					DECIMAL(18,2);

--SE INICIALIZAN VARIABLES
LET v_activo = 0;
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_monto_aportacion = 0;
LET v_clavemoneda = 1;
LET v_opinternacional = 0;
LET cVenMon = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscuenta_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscuenta_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscliente_his.out';
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
	LET TIPO_PLANTILLA_CTA	 = 'CargaCtaMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cuenta_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		--bdicheq:sc_maenoc noc es el detalle bienen datos de la cuenta , bdicheq:sc_maechq chq informacion de saldos 
		SELECT chq.num_cte,chq.cuenta,chq.status_cta,chq.cuenta_clabe,chq.proced_mantenercta,noc.fecha_alta,chq.sucursal
		INTO v_nic,v_nocuenta,v_status,v_clabe,v_idpropositocuenta,temp_fechaapertura,v_sucursal
		FROM bdicheq:sc_maechq chq, bdicheq:sc_maenoc noc, bdinteg:si_cliente cli
		WHERE chq.cuenta = noc.cuenta
		AND chq.producto <> '1100' -- NO TRAER INVERSION CRECIENTE
		AND cli.numcte = chq.num_cte
		AND cli.tipo_cliente = '1'
		AND noc.fecha_alta = v_fecha_ant
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		IF v_status = '1' THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		IF (v_idpropositocuenta IS NULL) or (v_idpropositocuenta = '') THEN
			LET v_idpropositocuenta = 5;
		ELSE
			LET v_idpropositocuenta = v_idpropositocuenta::INTEGER;
		END IF
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF
		
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 6;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,clavemoneda,opinternacional,activo,clabe,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_clavemoneda,v_opinternacional,v_activo,v_clabe,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 7;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF	
		
	END FOREACH
	
	LET vpaso = 8;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 9;
	
	FOREACH WITH HOLD
		--bdicred:sd_maecred tabla creditos
		SELECT sd.numcte,sd.num_credito,sd.fecha_apertura,sd.fecha_vencim,sd.divisa,sd.status_cred,sd.plazo,sd.sucursal
		INTO v_nic,v_nocuenta,temp_fechaapertura,temp_fechavencimiento,v_clavemoneda,v_status,v_idplazopago,v_sucursal
		FROM bdicred:sd_maecred sd, bdinteg:si_cliente cli
		WHERE sd.numcte = cli.numcte
		AND cli.tipo_cliente = '1'
		AND fecha_apertura = v_fecha_ant
		
		LET cVenMon = 0;
		LET vpaso = 10;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
	
		LET vpaso = 11;
		
		SELECT monto_otorgado,monto_reservado, NVL(monto_vencido + mto_venc_trasp,0)
		INTO v_total_cr_amt,v_monto_aportacion, cVenMon
		FROM bdicred:sd_maesdos
		WHERE num_credito = v_nocuenta;

		IF v_status IN ('AM','AA','AC','AE','AR','E1') AND cVenMon = 0 THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF

		
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechavencimiento = to_char(temp_fechavencimiento, '%Y-%m-%d');
		LET v_monto_aportacion = NVL(v_monto_aportacion,0);
		LET vconteo = vconteo + 1;
		LET v_idpropositocuenta = 5; 
		
		LET vpaso = 12;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,fechavencimiento,clavemoneda,opinternacional,activo,total_cr_amt,idplazopago,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_fechavencimiento,v_clavemoneda,v_opinternacional,v_activo,v_total_cr_amt,v_idplazopago,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 13;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	
	END FOREACH
	
	LET vpaso = 14;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 15;
	
	FOREACH WITH HOLD
		SELECT crd.numcte,crd.num_credito,crd.fecha_apertura,crd.fecha_vencim,crd.divisa,crd.status_cred,crd.plazo,crd.sucursal
		INTO v_nic,v_nocuenta,temp_fechaapertura,temp_fechavencimiento,v_clavemoneda,v_status,v_idplazopago,v_sucursal
		FROM bdicred:sd_maecredcrd crd, bdinteg:si_cliente cli
		WHERE cli.numcte = crd.numcte
		AND cli.tipo_cliente = '1'
		AND fecha_apertura = v_fecha_ant
		
		LET cVenMon = 0;
		LET vpaso = 16;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		SELECT monto_otorgado,monto_reservado,NVL(monto_vencido + mto_venc_trasp,0)
		INTO v_total_cr_amt,v_monto_aportacion,cVenMon
		FROM bdicred:sd_maesdoscrd
		WHERE num_credito = v_nocuenta;
		
		IF v_status IN ('AM','AA','AC','AE','AR','E1') AND cVenMon = 0 THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		LET vpaso = 17;
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF
	
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechavencimiento = to_char(temp_fechavencimiento, '%Y-%m-%d');
		LET v_monto_aportacion = NVL(v_monto_aportacion,0);
		LET vconteo = vconteo + 1;
		LET v_idpropositocuenta = 5; 
		
		LET vpaso = 18;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,fechavencimiento,clavemoneda,activo,total_cr_amt,idplazopago,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_fechavencimiento,v_clavemoneda,v_activo,v_total_cr_amt,v_idplazopago,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 19;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	
	END FOREACH
	
	LET vpaso = 20;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 21;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * FROM bdiauditor:tbl_cuenta_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 22;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 23;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 24;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscuenta_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 11/09/2019',
'DESCRIPCION: Generación de información cuentas para sistemas MINDS PLD',
'BD: bdiauditor',
'AUTOR: Fernando Torres Soto',
'FECHA: 26/12/2022',
'DESCRIPCION: Se agrega los campos correspondietnes al requerimiento de geolocalizacion',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_chq_crg_xml_head()
RETURNING	CHAR(08)	AS	cod_ret 		 ,
			CHAR(120)	AS	mensaje			 ,
			CHAR(10)	AS	vercion 		 ,
			CHAR(06)	AS	org_regulador	 ,
			CHAR(06)	AS	cve_entidad		 ;
			
			
--variables de retorno
	DEFINE	cod_ret			CHAR(08); 		
	DEFINE	mensaje			CHAR(80);
	DEFINE	vvercion 		CHAR(10);
	DEFINE	vorg_regulador	CHAR(06);
	DEFINE	vcve_entidad	CHAR(06);
	
	
--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER; 	
	
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			RETURN 	 cod_ret
					,'iIsamErr: '|| iIsamErr || 'vErrorInfo: sp_pld_chq_crg_xml_head ' || vErrorInfo || ' En paso: ' || vpaso 
					,""
					,""
					,""
			;
			
		END IF;
	END EXCEPTION;

	--inicializciÃ³n de variables
	LET cod_ret			='00000000';
	LET	mensaje			='PROCESO EXITOSO';
	LET	vvercion		='';
	LET	vorg_regulador	='';
	LET	vcve_entidad	='';
	
	SET ISOLATION TO DIRTY READ;
	
	LET vpaso =1;
	
	--obtenemos la verciÃ³n
	SELECT valor INTO vvercion FROM param WHERE llave = 'VERSION_XML';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		LET	vvercion = '1.0';
	END IF
	
	LET vpaso =2;
	--obtenemos el organismo regulador
	SELECT valor INTO vorg_regulador FROM param WHERE llave = 'CVE_ORGANO_REGULADOR';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000002','NO SE ENCONTRO EL ORGANISMO REGULADOR EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF

	LET vpaso =3;
	--obtenemos la clave de la entidad
	SELECT valor INTO vcve_entidad FROM param WHERE llave = 'CVE_ENTIDAD';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000003','NO SE ENCONTRO LA CLAVEDE LA ENTIDAD EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF
	
	RETURN cod_ret,mensaje,vvercion,vorg_regulador,vcve_entidad;
	
END
END PROCEDURE	
	
	;