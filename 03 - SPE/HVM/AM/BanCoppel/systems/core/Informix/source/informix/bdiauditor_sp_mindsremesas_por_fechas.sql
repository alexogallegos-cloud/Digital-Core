CREATE PROCEDURE "informix".sp_mindsremesas_por_fechas(pfecha_ini DATE)
RETURNING CHAR(6) AS cod_ret,
		  CHAR(90) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(90);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						LVARCHAR(900);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_REMESA	VARCHAR(50);
DEFINE fname					VARCHAR(200);

--VARIABLE LAYOUT REMESAS MINDS
DEFINE v_aliassucursal			INTEGER;
DEFINE v_numeroreferencia		CHAR(16);
DEFINE v_noempleado				CHAR(8);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_fecha_actualizacion	CHAR(10);
DEFINE v_monto					DECIMAL(18,2);
DEFINE v_depositante			CHAR(100);
DEFINE v_beneficiario			CHAR(100);
DEFINE v_cuentaorigen			CHAR(20);
DEFINE v_cuentadestino			CHAR(20);
DEFINE v_saldoinicial			DECIMAL(18,2);
DEFINE v_saldofinal				DECIMAL(18,2);
DEFINE v_clavemoneda 			CHAR(5);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_nocuenta				CHAR(20);
DEFINE v_clavesubproducto		CHAR(4);
DEFINE v_bancoorigen			CHAR(10);
DEFINE v_bancodestino			CHAR(10);
DEFINE v_idtipooperacion		CHAR(1);
DEFINE v_idconcepto				INTEGER;
DEFINE v_hora					CHAR(23);
DEFINE v_idinstrumentomonetario	CHAR(1);
DEFINE vconteo					INTEGER;
DEFINE v_claveinstrumento		CHAR(1);
DEFINE v_ref23 					CHAR(23);
DEFINE v_ciudad					INTEGER;
DEFINE v_estado				    INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_paisgeo				CHAR(2);
DEFINE v_pais_atm				CHAR(10);
DEFINE v_estado_suc				INTEGER;
DEFINE v_num_suc				INTEGER;
DEFINE v_pais_origen			CHAR(10);
DEFINE v_pais_destino			CHAR(10);
DEFINE v_moneda_destino			CHAR(10);
DEFINE v_abono_cuenta			CHAR(5);
DEFINE v_tipo_remesa			CHAR(5);
DEFINE v_ben_fec_nac			DATE;
DEFINE v_ben_direccion			CHAR(100);
DEFINE v_ben_nic				CHAR(20);
DEFINE v_ben_tpid				CHAR(5);
DEFINE v_ben_numid				CHAR(20);
DEFINE v_ben_estado				CHAR(5);
DEFINE v_ben_pais				CHAR(5);
DEFINE v_ben_telefono			CHAR(15);
DEFINE v_ben_ocupacion			CHAR(30);
DEFINE v_ord_direccion			CHAR(100);
DEFINE v_ord_ciudad				CHAR(100);
DEFINE v_ord_estado				CHAR(5);
DEFINE v_ord_pais				CHAR(5);
DEFINE v_ord_telefono			CHAR(15);
DEFINE v_ord_tipoid				CHAR(20);
DEFINE v_ord_numid				CHAR(20);
DEFINE v_fecha_envio			DATE;
DEFINE v_ben_fec_nac2			CHAR(10);
DEFINE v_fecha_envio2			CHAR(10);
DEFINE v_esempleado				INTEGER;

--VARIABLES DE PASO
DEFINE temp_fecha				DATE;
DEFINE temp_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_naturaleza				CHAR(1);
DEFINE v_num_cte				CHAR(20);
DEFINE v_tpo_persona			CHAR(2);
DEFINE v_ordenante_nombre1		CHAR(26);
DEFINE v_ordenante_nombre2		CHAR(26);
DEFINE v_ordenante_appaterno	CHAR(26);
DEFINE v_ordenante_apmaterno	CHAR(26);
DEFINE v_ord_nom_completo		CHAR(100);
DEFINE v_beneficiario_nombre1	CHAR(26);
DEFINE v_beneficiario_nombre2	CHAR(26);
DEFINE v_beneficiario_appaterno	CHAR(26);
DEFINE v_beneficiario_apmaterno	CHAR(26);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;

DEFINE cDiaI		  				CHAR(2);
DEFINE cMesI		  				CHAR(2);
DEFINE cAnoI		  				CHAR(4);
DEFINE cFechaI  					CHAR(8);
DEFINE cDiaF		  				CHAR(2);
DEFINE cMesF		  				CHAR(2);
DEFINE cAnoF		  				CHAR(4);
DEFINE cFechaF  					CHAR(8);

DEFINE ctransacc				CHAR(4);
DEFINE v_contadorcadena			INTEGER;
DEFINE v_posicioncoma			INTEGER;
DEFINE v_folio_suc				CHAR(30);
--DEFINE v_fechamh				DATE; --
DEFINE v_diasdif				DATE; --


--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_clavemoneda = '1';
LET v_idinstrumentomonetario = '3';
LET v_claveinstrumento = '1';
LET vconteo = 0;

LET cDiaI = '';
LET cMesI = '';
LET cAnoI = '';
LET cDiaF = '';
LET cMesF = '';
LET cAnoF = '';


BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsremesas_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_REMESA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsremesas_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	
	--SET DEBUG FILE TO '/ifxsif01/c90307913/sp_mindsremesas_diario.out';
    --TRACE ON;
	
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
		
	LET v_fecha_ant = pfecha_ini;
	LET v_fecha_hoy = pfecha_ini;
	
	--LET v_fecharegistro	= to_char(pfecha_fin, '%Y-%m-%d');
	
	LET vpaso = 2;
	
	
	LET cDiaI = LPAD(DAY(pfecha_ini), 2, '0');
	LET cMesI = LPAD(MONTH(pfecha_ini), 2, '0');
	LET cAnoI = YEAR(pfecha_ini);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaI = cAnoI||cMesI||cDiaI;
	
	/*LET cDiaF = LPAD(DAY(pfecha_fin), 2, '0');
	LET cMesF = LPAD(MONTH(pfecha_fin), 2, '0');
	LET cAnoF = YEAR(pfecha_fin);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaF = cAnoF||cMesF||cDiaF;*/
	
	LET RUTA_DESTINO	 	 = '/home/c90397017';  
	LET TIPO_PLANTILLA_REMESA	 = 'CargaRemesaMinds_'||TRIM(cFechaI);
	
	
	LET vpaso = 3; 
		
	--CREACION TABLA TEMPORAL 
	SELECT * FROM "informix".tbl_remesas_pld
	INTO TEMP tmp_tbl_remesas_minds_fechas 	WITH NO LOG;
	
	SELECT * FROM "informix".tbl_remesas_pld2
	INTO TEMP tmp_tbl_remesas_minds_fechas2 	WITH NO LOG;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT 
		a.sucursal,TO_CHAR(a.fech_alt, "%m") ||  TO_CHAR(a.fech_alt, "%y") || a.num_serial,a.usuario,a.fech_alt,a.monto_tot,a.fech_hor,a.sdo_cuenta,a.cuenta,a.producto,b.naturaleza,a.transacc,a.referencia_23,a.suc_cuen,a.folio_suc
		INTO v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,v_idconcepto,v_ref23,v_num_suc,v_folio_suc
		FROM bdicheq:sc_movhis a, bdiauditor:transacc_minds b -- se cambio por la sc_movhis cambiar cuando se terminen las pruebas
		WHERE a.fech_alt = v_fecha_ant
		--AND r.abono_cuenta = 'SI'
		AND a.cancelad <> 'S'
		AND b.tipo='DB' AND a.transacc=b.transacc
		AND a.transacc IN ('1110','1121','1122','1123','1325','1170','1181','1182','1183','1385')  -- NO EXTRAER INVERSION CRECIENTE
		--ORDER BY a.cuenta, a.num_serial
	
	LET vpaso = 5;
		
		INSERT INTO "informix".tmp_tbl_remesas_minds_fechas2 (aliassucursal,numeroreferencia,noempleado,fecha,monto,montomb,temp_hora,saldoinicial,nocuenta,clavesubproducto,naturaleza,idconcepto,referencia_23,cve_sucursal_apertura,folio_suc)
		VALUES (v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,v_idconcepto,v_ref23,v_num_suc,v_folio_suc);
		
	END FOREACH
	
	LET vpaso = 6;
	
	FOREACH WITH HOLD
	
		SELECT 
		re.aliassucursal,re.numeroreferencia,re.noempleado,re.fecha,re.monto,re.temp_hora,re.saldoinicial,re.nocuenta,re.clavesubproducto,re.naturaleza,re.idconcepto,re.referencia_23,re.cve_sucursal_apertura,r.tipo_remesa,r.abono_cuenta,
		r.beneficiario_fecha_nac,r.beneficiario_direccion,r.numero_de_cliente_benef,r.beneficiario_estado,r.cod_pais_benef,r.ocupacion_beneficiario,r.ordenante_direccion,r.ciudad_id_ordenante,r.tp_id_benef,r.num_id_benef,r.tel_benef,r.cod_edo_remitente,
		r.cod_pais_remitente,r.tel_remitente,r.tipo_id_ordenante,r.numero_id_ordenante,r.fecha_envio_remesa,r.cod_pais_origen,r.cod_pais_destino,r.cod_moneda_destino,r.ordenante_nombre1,r.ordenante_nombre2,r.ordenante_appaterno,r.ordenante_apmaterno,
		r.beneficiario_nombre1,r.beneficiario_nombre2,r.beneficiario_appaterno,r.beneficiario_apmaterno
		
		INTO v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,v_idconcepto,v_ref23,v_num_suc,v_tipo_remesa,v_abono_cuenta,
		v_ben_fec_nac,v_ben_direccion,v_ben_nic,v_ben_estado,v_ben_pais,v_ben_ocupacion,v_ord_direccion,v_ord_ciudad,v_ben_tpid,v_ben_numid,v_ben_telefono,v_ord_estado,v_ord_pais,v_ord_telefono,v_ord_tipoid,v_ord_numid,v_fecha_envio,v_pais_origen,v_pais_destino,v_moneda_destino,v_ordenante_nombre1,
		v_ordenante_nombre2,v_ordenante_appaterno,v_ordenante_apmaterno,v_beneficiario_nombre1,v_beneficiario_nombre2,v_beneficiario_appaterno,v_beneficiario_apmaterno
		
		
		FROM tmp_tbl_remesas_minds_fechas2 re, bdisac:sac_pld_remesas r
		WHERE r.fecha_remesa = v_fecha_ant
		and re.folio_suc = r.folio_sucursal  -- se agrego
		--ORDER BY re.nocuenta, re.numeroreferencia

			
		IF v_moneda_destino = 'MXP' THEN
			LET v_moneda_destino = 'MXN';
		END IF
		
		IF v_moneda_destino = '' THEN
			LET v_moneda_destino = '999';
		END IF 
		
		
----------------------------------------------------------------------------------------------------------------	
		LET vpaso = 7;		
		
		LET v_esempleado=0;
			
		IF SUBSTR(v_nocuenta,1,2) = 13 THEN

			SELECT MAX(fech_alt)
			INTO v_diasdif
			FROM bdicheq:sc_movhis -- se cambio por la sc_movhis cambiar cuando se terminen las pruebas
			where cuenta = v_nocuenta
			and transacc = '0287'
			and fech_alt<= v_fecha_ant;
									
			IF cast(temp_fecha as date) - cast(v_diasdif as date) <= 16 THEN 
				LET v_esempleado=1;
			END IF
		END IF	
		
------------------------------------------------------------------------------------------------------------------	
		----------------------------- Modifica Pais Beneficiario
        LET vpaso =8;
        
        IF v_ben_pais = 'HAI' THEN
        LET v_ben_pais = 'HT';
        END IF
        
        IF v_ben_pais = 'HON' THEN
        LET v_ben_pais = 'HN';
        END IF
        
        IF v_ben_pais = 'SPA' THEN
        LET v_ben_pais = 'ES';
        END IF
        
        IF v_ben_pais = 'GUA' THEN
        LET v_ben_pais = 'GT';
        END IF

		IF v_ben_pais = 'TOG' THEN
        LET v_ben_pais = 'TG';
        END IF
        
        IF v_ben_pais = 'SIE' THEN
        LET v_ben_pais = 'SL';
        END IF
        
        IF v_ben_pais = 'MAY' THEN
        LET v_ben_pais = 'MM';
        END IF
        
        IF v_ben_pais = 'MOR' THEN
        LET v_ben_pais = 'MA';
        END IF
        
        IF v_ben_pais = 'GER' THEN
        LET v_ben_pais = 'DE';
        END IF
        
        IF v_ben_pais = 'NIG' THEN
        LET v_ben_pais = 'NG';
        END IF
        
        
        -------------------Fecha Beneficiario nulo o vacio
        
        IF v_ben_fec_nac IS NULL OR v_ben_fec_nac ='' THEN 
        LET v_ben_fec_nac = '01011900';
        END IF
        
        -------------------Pais Destino N/A
        
         IF v_pais_destino ='' THEN
         LET v_pais_destino ='MEX';
         END IF	
		 
		 
		 ---------------------------------------------------------
		
		
		LET v_estado_suc = NULL;
		
		SELECT estado::INTEGER
		INTO v_estado_suc
		FROM  bdinteg:si_sucursales
		WHERE sucursal = v_num_suc;
			
		--VALIDA LOS ESTADOS
		IF v_estado_suc IS NULL THEN 
		LET v_estado_suc = '99999999';
		END IF
	
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		
		
		LET vpaso = 9;
			
		SELECT num_cte
		INTO v_num_cte
		FROM bdicheq:sc_maechq 
		WHERE cuenta = v_nocuenta; --EN CASO DE QUE MARQUE DUPLICADO EN EL RETORNO DE CLIENTES PONER LIMIT 1
		
		
		
		LET vpaso = 10; --NOMBRES COMPLETOS DE ORDENANTE Y BENEFICIARIO
		
		IF v_ordenante_nombre2 = '' OR v_ordenante_nombre2 IS NULL THEN
		LET v_depositante = TRIM(v_ordenante_nombre1) || " " || TRIM(v_ordenante_appaterno) || " " || TRIM(v_ordenante_apmaterno); --Nombre completo del Depositante-Ordenante
		ELSE 
		LET v_depositante = TRIM(v_ordenante_nombre1) || " " || TRIM(v_ordenante_nombre2) || " " || TRIM(v_ordenante_appaterno) || " " || TRIM(v_ordenante_apmaterno); --Nombre completo del Depositante-Ordenante
		END IF
		
		IF v_beneficiario_nombre2 = '' OR v_beneficiario_nombre2 IS NULL THEN 
		LET v_beneficiario = TRIM(v_beneficiario_nombre1) || " " || TRIM(v_beneficiario_appaterno) || " " || TRIM(v_beneficiario_apmaterno); --Nombre completo del Beneficiario
		ELSE
		LET v_beneficiario = TRIM(v_beneficiario_nombre1) || " " || TRIM(v_beneficiario_nombre2) || " " || TRIM(v_beneficiario_appaterno) || " " || TRIM(v_beneficiario_apmaterno); --Nombre completo del Beneficiario
		END IF
		
		
		LET vpaso = 11;
			
		IF v_naturaleza = 'A' THEN --ABONO
			LET v_idtipooperacion = '1';
			LET v_cuentadestino = v_nocuenta;
			LET v_cuentaorigen = NULL;
			LET v_saldofinal = v_saldoinicial + v_monto;
			LET v_bancodestino = 'BANCOPPEL';
			LET v_bancoorigen = NULL;
		ELIF v_naturaleza = 'C' THEN --CARGO
			LET v_idtipooperacion = '2';
			LET v_cuentadestino = NULL;
			LET v_cuentaorigen = v_nocuenta;
			LET v_saldofinal = v_saldoinicial - v_monto;
			LET v_bancodestino = NULL;
			LET v_bancoorigen = 'BANCOPPEL';
		END IF
		
		
		LET vpaso = 12;
			
		LET v_fecha_actualizacion	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_fecharegistro	= to_char(temp_fecha, '%Y-%m-%d');
			
		LET v_ben_fec_nac2 = to_char(v_ben_fec_nac, '%Y-%m-%d');
		LET v_fecha_envio2 = to_char(v_fecha_envio, '%Y-%m-%d');
			
		LET v_hora = to_char(temp_hora, '%I:%M:%S %p');
		LET vconteo = vconteo + 1;
		
		
		-- GEOLOCALIZACION
		LET v_ciudad = 0;
		LET v_estado = 0;
		LET v_cp = '';
		LET v_plaza = 0;
		LET v_paisgeo = '';
		LET v_contadorcadena = 1;
		LET v_posicioncoma = 0;
		
		IF ( v_aliassucursal IN (5011, 5003, 5008) ) AND ( ( LEN(v_ref23) - LEN(REPLACE(v_ref23, ',', '')) ) = 4 )
		
		THEN	
		
			WHILE v_contadorcadena <= 5 
			
				IF v_contadorcadena < 5 THEN
					LET v_posicioncoma = CHARINDEX(',', v_ref23);
				END IF
			
				-- CIUDAD
				IF v_contadorcadena = 1 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_ciudad = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- ESTADO
				ELIF v_contadorcadena = 3 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_estado = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- CP
				ELIF v_contadorcadena = 4 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_cp = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- PAIS
				ELIF v_contadorcadena = 5 THEN
					IF ( ( bdinteg:"informix".sp_esnumerico(v_ref23) = 'F' ) AND ( LEN(TRIM(v_ref23)) = 2) ) THEN
						LET v_paisgeo = TRIM(v_ref23);
					END IF
						
				END IF
				
				LET v_ref23 = SUBSTR(v_ref23, v_posicioncoma + 1);
				LET v_contadorcadena = v_contadorcadena + 1;
				
			END WHILE;
				
			SELECT localidad_banxico
			INTO v_plaza
			FROM bdinteg:si_ciudades
			WHERE ciudad = v_ciudad
			AND estado = v_estado;
			
		
		END IF
		
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
		
		----------------------------------------------------
		IF (v_idconcepto = '1110') or 
		   (v_idconcepto = '1121') or
		   (v_idconcepto = '1122') or
		   (v_idconcepto = '1123') or
		   (v_idconcepto = '1325') then 
		LET v_idinstrumentomonetario = '1';
		ELSE
		LET v_idinstrumentomonetario = '3';
		END IF
		------------------------------------------------------
		
		LET vpaso = 13;
			
			
		INSERT INTO "informix".tmp_tbl_remesas_minds_fechas (idregistro,aliassucursal,idtipooperacion,idinstrumentomonetario,idconcepto,numeroreferencia,noempleado,fecha,monto,montomb,depositante,beneficiario,
		hora,cuentaorigen,cuentadestino,saldoinicial,saldofinal,clavemoneda,nocuenta,clavesubproducto,idestatuscargaminds,bancoorigen,bancodestino,fecharegistro,idplaza,idciudadsepomex,idestado,cp,pais_geo,estado_sucursal,tiporemesa,abonocuenta,ben_fechanac,ben_direccion,
		ben_nic,ben_tpid,ben_numid,ben_estado,ben_pais,ben_telefono,ben_ocupacion,ord_direccion,ord_ciudad,ord_estado,ord_pais,ord_telefono,ord_tipoid,ord_numid,fechaenvio,paisorigen,paisdestino,monedadestino,es_empleado,cve_sucursal_apertura)
		
		VALUES (vconteo,v_aliassucursal,v_idtipooperacion,v_idinstrumentomonetario,v_idconcepto,v_numeroreferencia,v_noempleado,v_fecha_actualizacion,v_monto,v_monto,v_depositante,v_beneficiario,
		v_hora,v_cuentaorigen,v_cuentadestino,v_saldoinicial,v_saldofinal,v_clavemoneda,v_nocuenta,v_clavesubproducto,v_idestatuscargaminds,v_bancoorigen,v_bancodestino,v_fecharegistro,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo,v_estado_suc,v_tipo_remesa,
		v_abono_cuenta,v_ben_fec_nac2,v_ben_direccion,v_ben_nic,v_ben_tpid,v_ben_numid,v_ben_estado,v_ben_pais,v_ben_telefono,v_ben_ocupacion,v_ord_direccion,v_ord_ciudad,v_ord_estado,v_ord_pais,v_ord_telefono,v_ord_tipoid,v_ord_numid,v_fecha_envio2,v_pais_origen,v_pais_destino,v_moneda_destino,v_esempleado,v_num_suc);
		
		
		LET vpaso = 14;
			
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
		
	END FOREACH
	
	
	
	LET vpaso = 15;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 16;	
	LET fname = TRIM(RUTA_DESTINO||TIPO_PLANTILLA_REMESA) || '.txt'; 
	
	LET vsql = 'CREATE EXTERNAL TABLE tmp_tbl_remesas_minds_fechas_ext ' ||
               'SAMEAS tbl_remesas_pld USING ( DATAFILES("DISK:' ||
               TRIM(fname) ||
               '") );';
	
	EXECUTE IMMEDIATE vsql;
	
	LET vpaso = 17;
	
	INSERT INTO tmp_tbl_remesas_minds_fechas_ext SELECT * FROM tmp_tbl_remesas_minds_fechas;
	
	DROP TABLE tmp_tbl_remesas_minds_fechas_ext;
	DROP TABLE tmp_tbl_remesas_minds_fechas2;
	DROP TABLE tmp_tbl_remesas_minds_fechas;
	
	
	LET vpaso = 18;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_REMESA);	

	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Gilberto Francisco Naranjo Valles',
'FECHA: 31/07/2024',
'DESCRIPCION: se agrega instrumento monetario y consulta si es empleado activo, ',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_sucursales()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(90) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(90);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE vconteo					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						LVARCHAR(900);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_SUC		VARCHAR(50);
DEFINE vmaxlogid 				INTEGER;

--VARIABLE LAYOUT SUCURSALES MINDS
DEFINE	v_ESTADO				INTEGER;
DEFINE	v_IDCATALOGO			INTEGER;
DEFINE	v_IDREGION				INTEGER;
DEFINE	v_LOCALIDAD_BANXICO		INTEGER;
DEFINE	v_NOMBRE				LVARCHAR(500);
DEFINE	v_SUCURSAL				INTEGER;
DEFINE	v_ACTIVO				INTEGER;
DEFINE	v_D_CODIGO				LVARCHAR(500);

--VARIABLES DE PASO
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);


--SE INICIALIZAN VARIABLES
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
			LET vmensaje  = TRIM(ERROR_INFO)||' sp_sucursales en el paso '||vpaso;
			INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
			VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_SUC,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_sucursales');
			RETURN cod_ret, vmensaje;
			END EXCEPTION; --control de bitacora auditoria
	
			--SET DEBUG FILE TO '/ifxsif01/c91705134/sp_sucursales.out';
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
			LET TIPO_PLANTILLA_SUC = 'CargaSucMinds_'||TRIM(cFecha);
	
LET vpaso = 3;
	
			--Borrado de la tabla de paso
			BEGIN;
			TRUNCATE TABLE tbl_sucursal;   
			COMMIT;
	
LET vpaso = 4;
	
	FOREACH WITH HOLD	
		SELECT S.estado, C.localidad_banxico::INTEGER, S.nombre, S.sucursal::INTEGER, S.d_codigo
		INTO v_ESTADO, v_LOCALIDAD_BANXICO, v_NOMBRE, v_SUCURSAL, v_d_codigo
		FROM bdinteg:si_sucursales AS S
		LEFT JOIN bdinteg:si_ciudades AS  C
		ON s.estado = C.estado
		AND s.ciudad = C.ciudad 
		WHERE S.tipo='S'
        AND S.fecha_insert = v_fecha_ant
				
	
LET vpaso = 6;

		--INSERTA LOS VALORES EN LOS PARAMETROS DE LA TABLA DE PASO.
		INSERT INTO tbl_sucursal (estado,IDCATALOGO,IDREGION, localidad_banxico, nombre, sucursal,ACTIVO, d_codigo )			
		VALUES (v_estado,'0','0', v_localidad_banxico, v_nombre, v_sucursal, '1', v_d_codigo);
		
		
	END FOREACH		
	
LET vpaso = 7;	
		--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE BANCA TRADICIONAL
		LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_SUC||'.txt select * FROM bdiauditor:tbl_sucursal;">'||RUTA_DESTINO||TIPO_PLANTILLA_SUC||'_01.sql'; 
		system vsql;
		LET vsql = '';
	
LET vpaso = 8;
		--SE EJECUTA EL SCRIPT
		LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_SUC||'_01.sql';
		system vsql;
		LET vsql = '';
		LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_SUC||'_01.sql';
		system vsql;
	
LET vpaso = 9;
		--SE BORRA EL SCRIPT
		LET vsql = '';
		LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_SUC||'_01.sql';
		system vsql;
	
LET vpaso = 9;
		LET cod_ret = '00000';
		LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_SUC);
	
	INSERT INTO {+AVOID_FULL(bdiauditor:tbl_logextraccion_minds)} "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_sucursales');
	
	RETURN cod_ret, vmensaje;

END;	
END PROCEDURE
DOCUMENT 'AUTOR: Gilberto Fco. Naranjo Valles',
'FECHA: 05/02/2025',
'DESCRIPCION: Generacion de sucursales faltantes',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_busqueda_cte_listanegra(pNom1 CHAR(26),	
														pNom2 CHAR(26),	
														pApellpaterno CHAR(26),
														pApellmaterno CHAR(26),
														pFechanac DATE) 	
	RETURNING 	CHAR(6);	
	--Definicion de las variables
	DEFINE CodRet           CHAR(6);
	DEFINE iExiste      	SMALLINT;
	DEFINE iSql_err 		INT;
	DEFINE wNom1 			CHAR(26);	
	DEFINE wNom2 			CHAR(26);	
	DEFINE wApellpaterno 	CHAR(26);
	DEFINE wApellmaterno  	CHAR(26);
	
	--AsignaciÃ³n de las variables
	LET CodRet              = '000000';
	LET iExiste					=0;
	LET iSql_err 				= 0;
	
	LET wNom1 = UPPER(pNom1);
	LET wNom2 = UPPER(pNom2);
	LET wApellmaterno = UPPER(pApellmaterno);
	LET wApellpaterno = UPPER(pApellpaterno);
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET CodRet = iSql_err;
                RETURN CodRet;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO "/home/sysifx/JesusBueno/1449/sp_busqueda_cte_listanegra.out";
		--TRACE ON;
		
		IF NVL(pNom1,"") <> ""  AND NVL(pApellpaterno,"") <> "" THEN
			
			SELECT COUNT(rfc) INTO iExiste	
			FROM "informix".tbl_listainterna  
			WHERE  nombre1 = wNom1
			AND nombre2 = wNom2
			AND apell_paterno = wApellpaterno
			AND apell_materno = wApellmaterno
			AND fecha_nac = pFechanac::DATE;
			
			IF iExiste > 0 THEN
				LET CodRet = '000002';
			ELSE 
				LET CodRet = '000000'; --NO EXISTE EL CLIENTE EN LA LISTA NEGRA
			END IF
		ELSE 
			
			LET CodRet = '000001'; --NO RECIBE LOS PARAMETROS CORRECTOS
		
		END IF 	
		
		RETURN  CodRet;
		
	END;
END PROCEDURE
DOCUMENT
"AUTOR: Jesus Isaias Bueno",
"FECHA: 21-08-2014",
"DESCRIPCION: Busca por nombre y fecha de nacimiento en la lista negra guardados en la tabla tbl_listainterna",
"BD: bdiauditor";

CREATE PROCEDURE "informix".sp_mindsbancatradicional_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(90) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(90);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						LVARCHAR(900);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_BANCA	VARCHAR(50);
DEFINE vmaxlogid 				INTEGER;

--VARIABLE LAYOUT BANCA TRADICIONAL
DEFINE v_aliassucursal			CHAR(4);
DEFINE v_aliassucursal_trimmed	CHAR(4);
DEFINE v_numeroreferencia		CHAR(16);
DEFINE v_noempleado				CHAR(8);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_fecha_actualizacion	CHAR(10);
DEFINE v_monto					DECIMAL(18,2);
DEFINE v_depositante			CHAR(100);
DEFINE v_beneficiario			CHAR(100);
DEFINE v_cuentaorigen			CHAR(20);
DEFINE v_cuentadestino			CHAR(20);
DEFINE v_saldoinicial			DECIMAL(18,2);
DEFINE v_saldofinal				DECIMAL(18,2);
DEFINE v_clavemoneda 			CHAR(2);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_nocuenta				CHAR(20);
DEFINE v_nocuenta2				CHAR(20);
DEFINE v_clavesubproducto		CHAR(4);
DEFINE v_bancoorigen			CHAR(10);
DEFINE v_bancodestino			CHAR(10);
DEFINE v_idtipooperacion		CHAR(1);
DEFINE v_idconcepto				INTEGER;
DEFINE v_hora					CHAR(23);
DEFINE v_idinstrumentomonetario	CHAR(1);
DEFINE vconteo					INTEGER;
DEFINE v_claveinstrumento		CHAR(1);
DEFINE v_ref23 					CHAR(23);
DEFINE v_ciudad					INTEGER;
DEFINE v_estado				    INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_paisgeo				CHAR(2);
DEFINE v_cuenta_clabe			CHAR(20);
DEFINE v_num_tarjeta			CHAR(20);
DEFINE v_pais_atm				CHAR(10);
DEFINE v_secuencia_ext			CHAR(20);
DEFINE v_estado_suc				CHAR(10);
DEFINE v_num_suc				CHAR(10);

--VARIABLES DE PASO
DEFINE temp_fecha				DATE;
DEFINE temp_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_naturaleza				CHAR(1);
DEFINE v_num_cte				CHAR(20);
DEFINE v_tpo_persona			CHAR(2);
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE nombrepm 				CHAR(60);
DEFINE v_apell_paterno			CHAR(26);
DEFINE v_apell_materno			CHAR(26);
DEFINE v_nombrecompleto			CHAR(100);

DEFINE v_num_cte2				CHAR(20);
DEFINE v_tpo_persona2			CHAR(2);
DEFINE nombrepf12 				CHAR(26);
DEFINE nombrepf22 				CHAR(26);
DEFINE nombrepm2 				CHAR(60);
DEFINE v_apell_paterno2			CHAR(26);
DEFINE v_apell_materno2			CHAR(26);
DEFINE v_nombrecompleto2		CHAR(100);

DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE ctransacc				CHAR(4);
DEFINE v_claverastreo           CHAR(30);
DEFINE v_contadorcadena			INTEGER;
DEFINE v_posicioncoma			INTEGER;

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_clavemoneda = '1';
LET v_idinstrumentomonetario = '1';
LET v_claveinstrumento = '1';
LET vconteo = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vpaso = 0;
BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsbancatradicional_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_BANCA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsbancatradicional_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/c90307913/sp_mindsbancatradicional_diario.out';
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
	LET TIPO_PLANTILLA_BANCA = 'CargaBancaMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	--Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_bancatradicional_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT	 a.sucursal,TO_CHAR(a.fech_alt, "%m") ||  TO_CHAR(a.fech_alt, "%y") || a.num_serial,a.usuario,a.fech_alt,a.monto_tot,
		a.fech_hor,a.sdo_cuenta,a.cuenta,a.producto,b.naturaleza,a.transacc,a.referencia_23,a.num_tarjeta,a.folio_suc,a.sucursal, a.referencia
		INTO v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,
		v_idconcepto,v_ref23,v_num_tarjeta,v_secuencia_ext,v_num_suc,v_claverastreo
		FROM bdicheq:sc_movhis a, bdiauditor:transacc_minds b -- para los dias anteriores al 6 cambiar a la movhis_old
		WHERE a.fech_alt = v_fecha_ant
		AND a.cancelad <> 'S'
		AND b.tipo='DB' AND a.transacc=b.transacc
		AND a.producto <> '1100' -- NO EXTRAER INVERSION CRECIENTE
	
--		AND a.transacc in ('0289', '0329')
--		ORDER BY a.cuenta, a.num_serial ------

	
		LET vpaso = 5;

		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
			
		LET vpaso = 6;

		SELECT num_cte,cuenta_clabe
		INTO v_num_cte,v_cuenta_clabe
		FROM bdicheq:sc_maechq 
		WHERE cuenta = v_nocuenta;
		
		IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
		   
		   LET v_nocuenta2 = LEFT(v_claverastreo,11);
		   
		   SELECT num_cte
		   INTO v_num_cte2
		   FROM bdicheq:sc_maechq 
		   WHERE cuenta = v_nocuenta2;
		   	   
		END IF
		
		LET vpaso = 7;
		--Se agrega la si_ptf
		LET v_estado_suc = NULL;
		
		--************************************************
		SELECT ptf.cve_estado::INTEGER
		INTO v_estado_suc 
		from bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
		where ptf.cve_estado<='32' 
		and suc.sucursal=ptf.id_ptf 
		and suc.tipo=ptf.tipo 
		and suc.sucursal=v_num_suc;

		IF v_estado_suc is NULL  THEN  
			LET v_estado_suc = '99999999';
		End if
		--************************************************
		
		LET vpaso = 8;
		
		LET v_pais_atm = NULL;
		let v_secuencia_ext=SUBSTR(v_secuencia_ext, 2, 15);
		
		IF v_idconcepto = '0873' THEN 
		
				SELECT pais 
				INTO v_pais_atm
				FROM  intercard:movimiento
				WHERE numtarjeta = v_num_tarjeta 
				AND secuenciaextendida = v_secuencia_ext;
				
		END IF 
		
		IF (v_pais_atm IS NULL) OR (v_pais_atm = '') THEN
			LET v_pais_atm = 'N/A';
		END IF
		

		LET vpaso = 9;
		
		IF v_idconcepto IN ('0202','0223','0282','0318','0325','0402','0482','0491','0871','0873','0952') THEN  -- se agregaron 223,402,871,873,952
			LET v_idinstrumentomonetario = '1';
		else 
			LET v_idinstrumentomonetario = '3';
		END IF
		
		
		LET vpaso = 10;
		
			SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno
			INTO v_tpo_persona,nombrepf1,nombrepf2,nombrepm,v_apell_paterno,v_apell_materno
			FROM bdinteg:si_cliente
			WHERE numcte = v_num_cte;
			
			IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
			     SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno
			    INTO v_tpo_persona2,nombrepf12,nombrepf22,nombrepm2,v_apell_paterno2,v_apell_materno2
			    FROM bdinteg:si_cliente
			    WHERE numcte = v_num_cte2;				
			END IF
						
		
			
			IF v_tpo_persona IN('01','03') THEN --PERSONA FISICA    
			LET v_nombrecompleto = TRIM(nombrepf1) || " " || TRIM(nombrepf2) || " " || TRIM(v_apell_paterno) || " " || TRIM(v_apell_materno); 
			        ELIF v_tpo_persona IN('02','04','05') THEN --PERSONA MORAL        
            	LET v_nombrecompleto = TRIM(nombrepm);
			END IF        
			
			LET v_nombrecompleto2 = NULL;
			
			IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
				IF v_tpo_persona2 IN('01','03') THEN --PERSONA FISICA     
					LET v_nombrecompleto2 = TRIM(nombrepf12) || " " || TRIM(nombrepf22) || " " || TRIM(v_apell_paterno2) || " " || TRIM(v_apell_materno2);
				ELIF v_tpo_persona2 IN('02','04','05') THEN --PERSONA MORAL 
			LET v_nombrecompleto2 = TRIM(nombrepm2);
            END IF                
        END IF
			
			
		LET vpaso = 11;
			
		IF v_naturaleza = 'A' THEN --ABONO
			LET v_idtipooperacion = '1';
			LET v_depositante = NULL;
			LET v_beneficiario = v_nombrecompleto;
			LET v_cuentadestino = v_nocuenta;
			LET v_cuentaorigen = NULL;
			-----------------------------------------
			IF  v_idconcepto = '0329' THEN
				LET v_cuentaorigen = lEFT (v_claverastreo,11);
				LET v_depositante = v_nombrecompleto2;
			END IF
			-----------------------------------------
			IF  v_idconcepto = '0274' THEN
				LET v_cuentadestino = v_cuenta_clabe;
				LET v_cuentaorigen = NULL;
			END IF
			--------------------------------------------------------------------------------------	
				IF  v_idconcepto = '0273' THEN
					select first 1 vchrcuentaord, vchrnombreord
					into v_cuentaorigen, v_depositante
					FROM bdispei:tblhistpago
					where vchrclaverastreo = v_claverastreo
					and intcvetipopago=1;
					
					LET v_cuentadestino = v_cuenta_clabe;
				END IF
			---------------------------------------------------------------------------------------
			LET v_saldofinal = v_saldoinicial + v_monto;
			LET v_bancodestino = 'BANCOPPEL';
			LET v_bancoorigen = NULL;
		ELIF v_naturaleza = 'C' THEN --CARGO
			LET v_idtipooperacion = '2';
			LET v_depositante = v_nombrecompleto;
			LET v_beneficiario = NULL;
			LET v_cuentadestino = NULL;
			-----------------------------------------
 		    IF  v_idconcepto = '0289' THEN
				LET v_cuentadestino = LEFT (v_claverastreo,11);
				LET v_beneficiario = v_nombrecompleto2;
			END IF		
			LET v_cuentaorigen = v_nocuenta;
			-----------------------------------------
			IF  v_idconcepto = '0274' OR v_idconcepto = '0273' THEN
				LET v_cuentadestino = NULL;
				LET v_cuentaorigen = v_cuenta_clabe;
			END IF
			LET v_saldofinal = v_saldoinicial - v_monto;
			LET v_bancodestino = NULL;
			LET v_bancoorigen = 'BANCOPPEL';
		END IF
		
		LET vpaso = 12;

			
		LET v_fecha_actualizacion	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_fecharegistro	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_hora = to_char(temp_hora, '%I:%M:%S %p');
		LET vconteo = vconteo + 1;
			

		-- GEOLOCALIZACION
		LET v_ciudad = 0;
		LET v_estado = 0;
		LET v_cp = '';
		LET v_plaza = 0;
		LET v_paisgeo = '';
		LET v_contadorcadena = 1;
		LET v_posicioncoma = 0;
		

		IF ( v_aliassucursal IN ('5011', '5003', '5008') ) AND ( ( LEN(v_ref23) - LEN(REPLACE(v_ref23, ',', '')) ) = 4 )
		
			THEN	
		
			WHILE v_contadorcadena <= 5 
			
				IF v_contadorcadena < 5 THEN
					LET v_posicioncoma = CHARINDEX(',', v_ref23);
				END IF
			
				-- CIUDAD
				IF v_contadorcadena = 1 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_ciudad = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- ESTADO
				ELIF v_contadorcadena = 3 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_estado = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- CP
				ELIF v_contadorcadena = 4 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_cp = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- PAIS
				ELIF v_contadorcadena = 5 THEN
					IF ( ( bdinteg:"informix".sp_esnumerico(v_ref23) = 'F' ) AND ( LEN(TRIM(v_ref23)) = 2) ) THEN
						LET v_paisgeo = TRIM(v_ref23);
					END IF
						
				END IF
				
				LET v_ref23 = SUBSTR(v_ref23, v_posicioncoma + 1);
				LET v_contadorcadena = v_contadorcadena + 1;
				
			END WHILE;
			

			--PLAZA
			SELECT localidad_banxico
			INTO v_plaza
			FROM bdinteg:si_ciudades
			WHERE ciudad = v_ciudad
			AND estado = v_estado;
			
		END IF
		
		
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
				
		
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
			--PLAZA 
			--************************************************	
				SELECT ciu.localidad_banxico
				INTO v_plaza
				FROM bdinteg:si_ciudades ciu, bdinteg:si_ptf ptf
				where ptf.cve_estado=ciu.estado
				and ptf.tipo<>'C'
				and ptf.cve_estado<='32'
				and ptf.cve_ciudad=ciu.ciudad
				AND ptf.id_ptf = v_aliassucursal;
			--************************************************
		END IF
		
		LET vpaso = 13;	
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_plaza = 0) OR (v_plaza IS NULL) THEN  -- v_aliassucursal = 5011 or v_aliassucursal=5003 or v_aliassucursal= 5008 and
			LET v_plaza = 99999999;
		END IF
		
/*		IF v_aliassucursal <> '5011' AND v_aliassucursal <>5003 and v_aliassucursal <> 5008 then
					
						SELECT cve_estado
						INTO v_estado
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal 
						AND tipo in ('S', 'O');		
					
		END IF
		
			
		IF v_aliassucursal = 5011 or v_aliassucursal=5003 or v_aliassucursal= 5008 and (v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		end if
*/	
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
					
						SELECT cve_ciudad
						INTO v_ciudad
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
								
		END IF
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
								
						SELECT cp
						INTO v_cp
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
					
		END IF
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
			
				SELECT p.clave_pais 
				INTO v_paisgeo
				FROM bdinteg:si_ptf sp
				inner join bdinteg:si_paises p
				on sp.cve_pais=p.pais
				WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
	
		END IF
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_paisgeo = '') OR (v_paisgeo IS NULL) THEN
				LET v_paisgeo = 'ZZ';
		END IF	
		
		LET vpaso = 13;
		
		LET v_aliassucursal_trimmed= trim (leading '0' from v_aliassucursal);
			
		INSERT INTO "informix".tbl_bancatradicional_minds (idregistro,aliassucursal,idtipooperacion,idinstrumentomonetario,idconcepto,claveinstrumento,numeroreferencia,noempleado,fecha,monto,montomb,depositante,beneficiario,
		hora,cuentaorigen,cuentadestino,saldoinicial,saldofinal,clavemoneda,nocuenta,clavesubproducto,fechaactualizacion,idestatuscargaminds,bancoorigen,bancodestino,fecharegistro,idplaza,idciudadsepomex,idestado,cp,paisgeo,pais_atm,estado_suc)
		VALUES (vconteo,v_aliassucursal_trimmed,v_idtipooperacion,v_idinstrumentomonetario,v_idconcepto,v_claveinstrumento,v_numeroreferencia,v_noempleado,v_fecha_actualizacion,v_monto,v_monto,v_depositante,v_beneficiario,
		v_hora,v_cuentaorigen,v_cuentadestino,v_saldoinicial,v_saldofinal,v_clavemoneda,v_nocuenta,v_clavesubproducto,v_fecha_actualizacion,v_idestatuscargaminds,v_bancoorigen,v_bancodestino,v_fecharegistro,v_plaza,v_ciudad,v_estado_suc,v_cp,v_paisgeo,v_pais_atm,v_estado_suc);
		
		LET vpaso = 14;
			
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
		
	END FOREACH
	
	LET vpaso = 15;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 16;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE BANCA TRADICIONAL
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_BANCA||'.txt select * FROM bdiauditor:tbl_bancatradicional_minds ORDER BY nocuenta, numeroreferencia;">'||RUTA_DESTINO||TIPO_PLANTILLA_BANCA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 17;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_BANCA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_BANCA||'_01.sql';
	system vsql;
	
	LET vpaso = 18;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_BANCA||'_01.sql';
	system vsql;
	
	LET vpaso = 19;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_BANCA);
	
	INSERT INTO {+AVOID_FULL(bdiauditor:tbl_logextraccion_minds)} "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindsbancatradicional_diario');
	
	LET vpaso = 20;
	-- CIFRAS CONTROL CONTEO LINEAS TXT
	
	-- OBTENER ID DEL ULTIMO LOG INSERTADO
	SELECT MAX(idlog)
	INTO vmaxlogid
	FROM tbl_logextraccion_minds;
	
	LET vsql = '';
	LET vsql = "wc -l " || RUTA_DESTINO || TIPO_PLANTILLA_BANCA || ".txt |awk  'BEGIN {print "||'"update tbl_logextraccion_minds set regtxt="}' || '{print $1}{print "where fechaejecucion=' || "'\''" ||TO_CHAR(v_fecha_hoy,"%m%d%Y") || "'\''" || " and rutina='\''sp_mindsbancatradicional_diario'\'' and errorproceso is null and idlog=" || vmaxlogid || '"' || "}'" || ">" || RUTA_DESTINO || "update_cfbtlogminds.sql";
	system vsql;
	
	-- EJECTUAR SCRIPT CIFRAS CONTROL TXT
	LET vsql = '';
	LET vsql = 'chmod 777 ' || RUTA_DESTINO || 'update_cfbtlogminds.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor ' || RUTA_DESTINO || 'update_cfbtlogminds.sql';
	system vsql;
	
	-- BORRAR SCRIPT CIFRAS CONTROL TXT
	LET vsql = '';
	LET vsql = 'rm ' || RUTA_DESTINO || 'update_cfbtlogminds.sql';
	system vsql;
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: David Fernando Zazueta Ochoa',
'FECHA: 21/01/2025',
'DESCRIPCION: Se agrego la si_ptf para la consulta de estados, se agrego la idciudadsepomex,idestado,cp y pais geo',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindsbancatradicional_por_fechas_f2 (pfecha_ini DATE)
RETURNING CHAR(6) AS cod_ret,
		  CHAR(90) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(90);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						LVARCHAR(900);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_BANCA	VARCHAR(50);
DEFINE fname					VARCHAR(200);

--VARIABLE LAYOUT BANCA TRADICIONAL

DEFINE v_aliassucursal			CHAR(4);
DEFINE v_aliassucursal_trimmed	CHAR(4);
DEFINE v_numeroreferencia		CHAR(16);
DEFINE v_noempleado				CHAR(8);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_fecha_actualizacion	CHAR(10);
DEFINE v_monto					DECIMAL(18,2);
DEFINE v_depositante			CHAR(100);
DEFINE v_beneficiario			CHAR(100);
DEFINE v_cuentaorigen			CHAR(20);
DEFINE v_cuentadestino			CHAR(20);
DEFINE v_saldoinicial			DECIMAL(18,2);
DEFINE v_saldofinal				DECIMAL(18,2);
DEFINE v_clavemoneda 			CHAR(2);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_nocuenta				CHAR(20);
DEFINE v_nocuenta2				CHAR(20);
DEFINE v_clavesubproducto		CHAR(4);
DEFINE v_bancoorigen			CHAR(10);
DEFINE v_bancodestino			CHAR(10);
DEFINE v_idtipooperacion		CHAR(1);
DEFINE v_idconcepto				INTEGER;
DEFINE v_hora					CHAR(23);
DEFINE v_idinstrumentomonetario	CHAR(1);
DEFINE vconteo					INTEGER;
DEFINE v_claveinstrumento		CHAR(1);
DEFINE v_ref23 					CHAR(23);
DEFINE v_ciudad					INTEGER;
DEFINE v_estado				    INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_paisgeo				CHAR(2);
DEFINE v_cuenta_clabe			CHAR(20);
DEFINE v_num_tarjeta			CHAR(20);
DEFINE v_pais_atm				CHAR(10);
DEFINE v_secuencia_ext			CHAR(20);
DEFINE v_estado_suc				CHAR(10);
DEFINE v_num_suc				CHAR(10);

--VARIABLES DE PASO
DEFINE temp_fecha				DATE;
DEFINE temp_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_naturaleza				CHAR(1);
DEFINE v_num_cte				CHAR(20);
DEFINE v_tpo_persona			CHAR(2);
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE nombrepm 				CHAR(60);
DEFINE v_apell_paterno			CHAR(26);
DEFINE v_apell_materno			CHAR(26);
DEFINE v_nombrecompleto			CHAR(100);

DEFINE v_num_cte2				CHAR(20);
DEFINE v_tpo_persona2			CHAR(2);
DEFINE nombrepf12 				CHAR(26);
DEFINE nombrepf22 				CHAR(26);
DEFINE nombrepm2 				CHAR(60);
DEFINE v_apell_paterno2			CHAR(26);
DEFINE v_apell_materno2			CHAR(26);
DEFINE v_nombrecompleto2		CHAR(100);
DEFINE v_fecha_hoy					DATE;
--DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE cDiaF		  				CHAR(2);
DEFINE cMesF		  				CHAR(2);
DEFINE cAnoF		  				CHAR(4);
DEFINE cFechaI  					CHAR(8);
DEFINE ctransacc				CHAR(4);
DEFINE v_contadorcadena			INTEGER;
DEFINE v_posicioncoma			INTEGER;
DEFINE v_depositanteid			CHAR(100);
DEFINE v_cuentaorigenid			CHAR(20);
DEFINE v_claverastreo           CHAR(30);
DEFINE v_nocuentatemp			CHAR(16);
DEFINE v_numreftemp				CHAR(20);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_clavemoneda = '1';
LET v_idinstrumentomonetario = '1';
LET v_claveinstrumento = '1';
LET vconteo = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vpaso = 0;
BEGIN 
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsbancatradicional_por_fechas en el paso '||vpaso;
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindsbancatradicional_diario.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	SELECT FIRST 1 fecha_hoy
	INTO v_fecha_hoy
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
		
	LET cDia = LPAD(DAY(pfecha_ini), 2, '0');
	LET cMes = LPAD(MONTH(pfecha_ini), 2, '0');
	LET cAno = YEAR(pfecha_ini);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaI = cAno||cMes||cDia;
	
	
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/'; --  
	LET TIPO_PLANTILLA_BANCA = 'CargaBancaMindsF_'||TRIM(cFechaI);
	
	LET vpaso = 3;
		
	--CREACION TABLA TEMPORAL 
	SELECT * FROM "informix".tbl_bancatradicional_minds_fechas_f2
	WHERE idregistro IS NULL
	INTO TEMP tmp_tbl_banca_minds_fechas_f2 	WITH NO LOG;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT	 a.sucursal,TO_CHAR(a.fech_alt, "%m") ||  TO_CHAR(a.fech_alt, "%y") || a.num_serial,a.usuario,a.fech_alt,a.monto_tot,
		a.fech_hor,a.sdo_cuenta,a.cuenta,a.producto,b.naturaleza,a.transacc,a.referencia_23,a.num_tarjeta,a.folio_suc,a.sucursal, a.referencia
		INTO v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,
		v_idconcepto,v_ref23,v_num_tarjeta,v_secuencia_ext,v_num_suc,v_claverastreo
		FROM bdicheq:sc_movhis a, bdiauditor:transacc_minds b -- para los dias anteriores al 6 cambiar a la movhis_old
		WHERE a.fech_alt = pfecha_ini
		AND a.cancelad <> 'S'
		AND b.tipo='DB' AND a.transacc=b.transacc
		AND a.producto <> '1100' -- NO EXTRAER INVERSION CRECIENTE
--		AND a.transacc in ('0289', '0329')
--		ORDER BY a.cuenta, a.num_serial ------
		
	
		LET vpaso = 5;

		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
			
		LET vpaso = 6;

		SELECT num_cte,cuenta_clabe
		INTO v_num_cte,v_cuenta_clabe
		FROM bdicheq:sc_maechq 
		WHERE cuenta = v_nocuenta;
		
		IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
		   
		   LET v_nocuenta2 = LEFT(v_claverastreo,11);
		   
		   SELECT num_cte
		   INTO v_num_cte2
		   FROM bdicheq:sc_maechq 
		   WHERE cuenta = v_nocuenta2;
		   	   
		END IF
		
		LET vpaso = 7;
		--Se agrega la si_ptf
		LET v_estado_suc = NULL;
		
		--************************************************
		SELECT ptf.cve_estado::INTEGER
		INTO v_estado_suc 
		from bdinteg:si_sucursales suc, bdinteg:si_ptf ptf
		where ptf.cve_estado<='32' 
		and suc.sucursal=ptf.id_ptf 
		and suc.tipo=ptf.tipo 
		and suc.sucursal=v_num_suc;

		IF v_estado_suc is NULL  THEN  
			LET v_estado_suc = '99999999';
		End if
		--************************************************
		
		LET vpaso = 8;
		
		LET v_pais_atm = NULL;
		let v_secuencia_ext=SUBSTR(v_secuencia_ext, 2, 15);
		
		IF v_idconcepto = '0873' THEN 
		
				SELECT pais 
				INTO v_pais_atm
				FROM  intercard:movimiento
				WHERE numtarjeta = v_num_tarjeta 
				AND secuenciaextendida = v_secuencia_ext;
				
		END IF 
		
		IF (v_pais_atm IS NULL) OR (v_pais_atm = '') THEN
			LET v_pais_atm = 'N/A';
		END IF
		
		LET vpaso = 9;
		
		IF v_idconcepto IN ('0202','0223','0282','0318','0325','0402','0482','0491','0871','0873','0952') THEN  -- se agregaron 223,402,871,873,952
			LET v_idinstrumentomonetario = '1';
		else 
			LET v_idinstrumentomonetario = '3';
		END IF
		
		LET vpaso = 10;
		
			SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno
			INTO v_tpo_persona,nombrepf1,nombrepf2,nombrepm,v_apell_paterno,v_apell_materno
			FROM bdinteg:si_cliente
			WHERE numcte = v_num_cte;
			
			IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
			     SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno
			    INTO v_tpo_persona2,nombrepf12,nombrepf22,nombrepm2,v_apell_paterno2,v_apell_materno2
			    FROM bdinteg:si_cliente
			    WHERE numcte = v_num_cte2;				
			END IF
						
		
			
			IF v_tpo_persona IN('01','03') THEN --PERSONA FISICA    
			LET v_nombrecompleto = TRIM(nombrepf1) || " " || TRIM(nombrepf2) || " " || TRIM(v_apell_paterno) || " " || TRIM(v_apell_materno); 
			        ELIF v_tpo_persona IN('02','04','05') THEN --PERSONA MORAL        
            	LET v_nombrecompleto = TRIM(nombrepm);
			END IF        
			
			LET v_nombrecompleto2 = NULL;
			
			IF  (v_idconcepto = '0289') OR (v_idconcepto ='0329') THEN
				IF v_tpo_persona2 IN('01','03') THEN --PERSONA FISICA     
					LET v_nombrecompleto2 = TRIM(nombrepf12) || " " || TRIM(nombrepf22) || " " || TRIM(v_apell_paterno2) || " " || TRIM(v_apell_materno2);
				ELIF v_tpo_persona2 IN('02','04','05') THEN --PERSONA MORAL 
			LET v_nombrecompleto2 = TRIM(nombrepm2);
            END IF                
        END IF
			
			
		LET vpaso = 11;
			
		IF v_naturaleza = 'A' THEN --ABONO
			LET v_idtipooperacion = '1';
			LET v_depositante = NULL;
			LET v_beneficiario = v_nombrecompleto;
			LET v_cuentadestino = v_nocuenta;
			LET v_cuentaorigen = NULL;
			-----------------------------------------
			IF  v_idconcepto = '0329' THEN
				LET v_cuentaorigen = lEFT (v_claverastreo,11);
				LET v_depositante = v_nombrecompleto2;
			END IF
			-----------------------------------------
			IF  v_idconcepto = '0274' THEN
				LET v_cuentadestino = v_cuenta_clabe;
				LET v_cuentaorigen = NULL;
			END IF
			--------------------------------------------------------------------------------------	
				IF  v_idconcepto = '0273' THEN
					select first 1 vchrcuentaord, vchrnombreord
					into v_cuentaorigen, v_depositante
					FROM bdispei:tblhistpago
					where vchrclaverastreo = v_claverastreo
					and intcvetipopago=1;
					
					LET v_cuentadestino = v_cuenta_clabe;
				END IF
			---------------------------------------------------------------------------------------
			LET v_saldofinal = v_saldoinicial + v_monto;
			LET v_bancodestino = 'BANCOPPEL';
			LET v_bancoorigen = NULL;
		ELIF v_naturaleza = 'C' THEN --CARGO
			LET v_idtipooperacion = '2';
			LET v_depositante = v_nombrecompleto;
			LET v_beneficiario = NULL;
			LET v_cuentadestino = NULL;
			-----------------------------------------
 		    IF  v_idconcepto = '0289' THEN
				LET v_cuentadestino = LEFT (v_claverastreo,11);
				LET v_beneficiario = v_nombrecompleto2;
			END IF		
			LET v_cuentaorigen = v_nocuenta;
			-----------------------------------------
			IF  v_idconcepto = '0274' OR v_idconcepto = '0273' THEN
				LET v_cuentadestino = NULL;
				LET v_cuentaorigen = v_cuenta_clabe;
			END IF
			LET v_saldofinal = v_saldoinicial - v_monto;
			LET v_bancodestino = NULL;
			LET v_bancoorigen = 'BANCOPPEL';
		END IF
		
		
		LET vpaso = 12;

			
		LET v_fecha_actualizacion	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_fecharegistro	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_hora = to_char(temp_hora, '%I:%M:%S %p');
		LET vconteo = vconteo + 1;
			

		-- GEOLOCALIZACION
		LET v_ciudad = 0;
		LET v_estado = 0;
		LET v_cp = '';
		LET v_plaza = 0;
		LET v_paisgeo = '';
		LET v_contadorcadena = 1;
		LET v_posicioncoma = 0;
		

		IF ( v_aliassucursal IN ('5011','5003','5008') ) AND ( ( LEN(v_ref23) - LEN(REPLACE(v_ref23, ',', '')) ) = 4 )
		
			THEN	
		
			WHILE v_contadorcadena <= 5 
			
				IF v_contadorcadena < 5 THEN
					LET v_posicioncoma = CHARINDEX(',', v_ref23);
				END IF
			
				-- CIUDAD
				IF v_contadorcadena = 1 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_ciudad = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- ESTADO
				ELIF v_contadorcadena = 3 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_estado = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- CP
				ELIF v_contadorcadena = 4 THEN
					IF ( bdinteg:"informix".sp_esnumerico( LEFT(v_ref23, v_posicioncoma - 1) ) = 'V' )THEN
						LET v_cp = LEFT(v_ref23, v_posicioncoma - 1);
					END IF
				
				-- PAIS
				ELIF v_contadorcadena = 5 THEN
					IF ( ( bdinteg:"informix".sp_esnumerico(v_ref23) = 'F' ) AND ( LEN(TRIM(v_ref23)) = 2) ) THEN
						LET v_paisgeo = TRIM(v_ref23);
					END IF
						
				END IF
				
				LET v_ref23 = SUBSTR(v_ref23, v_posicioncoma + 1);
				LET v_contadorcadena = v_contadorcadena + 1;
				
			END WHILE;
			

			--PLAZA
			SELECT localidad_banxico
			INTO v_plaza
			FROM bdinteg:si_ciudades
			WHERE ciudad = v_ciudad
			AND estado = v_estado;
			
		END IF
		
		
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
				


			LET v_fecha_actualizacion	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_fecharegistro	= to_char(temp_fecha, '%Y-%m-%d');
		LET v_hora = to_char(temp_hora, '%I:%M:%S %p');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 12;
		
		-- GEOLOCALIZACION
		LET v_ciudad = 0;
		LET v_estado = 0;
		LET v_cp = '';
		LET v_plaza = 0;
		LET v_paisgeo = '';
		--LET v_contadorcadena = 1;
		--LET v_posicioncoma = 0;
		
		
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
			--PLAZA 
			--************************************************	
				SELECT ciu.localidad_banxico
				INTO v_plaza
				FROM bdinteg:si_ciudades ciu, bdinteg:si_ptf ptf
				where ptf.cve_estado=ciu.estado
				and ptf.tipo<>'C'
				and ptf.cve_estado<='32'
				and ptf.cve_ciudad=ciu.ciudad
				AND ptf.id_ptf = v_aliassucursal;
			--************************************************
		END IF
		
		LET vpaso = 13;	
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_plaza = 0) OR (v_plaza IS NULL) THEN  -- v_aliassucursal = 5011 or v_aliassucursal=5003 or v_aliassucursal= 5008 and
			LET v_plaza = 99999999;
		END IF
/*		
		IF v_aliassucursal <> 5011 AND v_aliassucursal <>5003 and v_aliassucursal <> 5008 then
					
						SELECT cve_estado
						INTO v_estado
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal 
						AND tipo in ('S', 'O');		
					
		END IF
		
			
		IF v_aliassucursal = 5011 or v_aliassucursal=5003 or v_aliassucursal= 5008 and (v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		end if
*/	
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
					
						SELECT cve_ciudad
						INTO v_ciudad
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
								
		END IF
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
								
						SELECT cp
						INTO v_cp
						FROM bdinteg:si_ptf
						WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
					
		END IF
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF v_aliassucursal <> '5011' AND v_aliassucursal <>'5003' and v_aliassucursal <> '5008' then
			
				SELECT p.clave_pais 
				INTO v_paisgeo
				FROM bdinteg:si_ptf sp
				inner join bdinteg:si_paises p
				on sp.cve_pais=p.pais
				WHERE id_ptf = v_aliassucursal AND tipo in ('S', 'O');
	
		END IF
		
		IF v_aliassucursal = '5011' or v_aliassucursal='5003' or v_aliassucursal= '5008' and (v_paisgeo = '') OR (v_paisgeo IS NULL) THEN
				LET v_paisgeo = 'ZZ';
		END IF	
			
		LET vpaso = 13;
		
		LET v_aliassucursal_trimmed= trim (leading '0' from v_aliassucursal);
			
		INSERT INTO "informix".tmp_tbl_banca_minds_fechas_f2 (idregistro,aliassucursal,idtipooperacion,idinstrumentomonetario,idconcepto,claveinstrumento,numeroreferencia,noempleado,fecha,monto,montomb,depositante,beneficiario,
		hora,cuentaorigen,cuentadestino,saldoinicial,saldofinal,clavemoneda,nocuenta,clavesubproducto,fechaactualizacion,idestatuscargaminds,bancoorigen,bancodestino,fecharegistro,idplaza,idciudadsepomex,idestado,cp,paisgeo,pais_atm,estado_suc)
		VALUES (vconteo,v_aliassucursal_trimmed,v_idtipooperacion,v_idinstrumentomonetario,v_idconcepto,v_claveinstrumento,v_numeroreferencia,v_noempleado,v_fecha_actualizacion,v_monto,v_monto,v_depositante,v_beneficiario,
		v_hora,v_cuentaorigen,v_cuentadestino,v_saldoinicial,v_saldofinal,v_clavemoneda,v_nocuenta,v_clavesubproducto,v_fecha_actualizacion,v_idestatuscargaminds,v_bancoorigen,v_bancodestino,v_fecharegistro,v_plaza,v_ciudad,v_estado_suc,v_cp,v_paisgeo,v_pais_atm,v_estado_suc);
			
		LET vpaso = 14;
			
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
		
	END FOREACH
	
	LET vpaso = 15;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	/*LET vpaso = 16;	
		
	LET fname = TRIM(RUTA_DESTINO||TIPO_PLANTILLA_BANCA) || '.txt'; 
	
	LET vsql = 'CREATE EXTERNAL TABLE tmp_tbl_banca_minds_fechas_f2_ext ' ||
               'SAMEAS tbl_bancatradicional_minds_fechas_f2 USING ( DATAFILES("DISK:' ||
               TRIM(fname) ||
               '") );';
	
	EXECUTE IMMEDIATE vsql;
	
	LET vpaso = 17;
	
	INSERT INTO tmp_tbl_banca_minds_fechas_f2_ext SELECT * FROM tmp_tbl_banca_minds_fechas_f2;
	
	DROP TABLE tmp_tbl_banca_minds_fechas_f2_ext;
	DROP TABLE tmp_tbl_banca_minds_fechas_f2;*/
	
	
	LET vpaso = 18;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_BANCA);
	
	RETURN cod_ret, vmensaje;

	
END;
END PROCEDURE
DOCUMENT 'AUTOR: David Fernando Zazueta Ochoa',
'FECHA: 21/01/2025',
'DESCRIPCION: Se agrego la si_ptf para la consulta de estados, se agrego la idciudadsepomex,idestado,cp y pais geo',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_busqueda_cte_listanegra(pNom1 CHAR(26),	
														pNom2 CHAR(26),	
														pApellpaterno CHAR(26),
														pApellmaterno CHAR(26),
														pFechanac DATE,
														pSucursal CHAR(4),
														pUsuario CHAR(8)) 	
	RETURNING 	CHAR(6);	
	--Definicion de las variables
	DEFINE CodRet           CHAR(6);
	DEFINE iExiste1			SMALLINT;
	DEFINE iExiste2			SMALLINT;
	DEFINE iSql_err 		INT;
	DEFINE uidWC			CHAR(15);
	DEFINE fecha			CHAR(25);
	DEFINE hora				CHAR(25);
	DEFINE vfechanac		CHAR(25);
	DEFINE vfirstName		CHAR(100);
	DEFINE vlastName		CHAR(100);
	DEFINE wNom1 			CHAR(26);	
	DEFINE wNom2 			CHAR(26);	
	DEFINE wApellpaterno 	CHAR(26);
	DEFINE wApellmaterno  	CHAR(26);
	
	--AsignaciÃ³n de las variables
	LET CodRet		= '000000';
	LET iExiste1	=0;
	LET iExiste2	=0;
	LET iSql_err	= 0;
	LET uidWC 		= "0";
	
	LET wNom1 = UPPER(pNom1);
	LET wNom2 = UPPER(pNom2);
	LET wApellmaterno = UPPER(pApellmaterno);
	LET wApellpaterno = UPPER(pApellpaterno);
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET CodRet = iSql_err;
                RETURN CodRet;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

    --SET DEBUG FILE TO '/informix/jmss/sp_bus_cte_lista_negra.out';
    --TRACE ON;
		

	
		IF NVL(pNom1,"") <> ""  AND NVL(pApellpaterno,"") <> "" THEN 
		
			LET vfechanac = substr(pFechanac,1,2) || "/" || substr(pFechanac,4,2) || "/" || substr(pFechanac,7,4);
			
			SELECT COUNT(rfc) INTO iExiste1
			FROM bdiauditor:"informix".tbl_listainterna  
			WHERE nombre1 = wNom1
			AND nombre2 = wNom2
			AND apell_paterno = wApellpaterno
			AND apell_materno = wApellmaterno
			AND fecha_nac = vfechanac::DATE;
			
			
			LET vfechanac = YEAR(pFechanac) || "-" || LPAD( MONTH(pFechanac),2,'0') || "-" || LPAD(DAY(pFechanac),2,'0') ;
			LET vfirstName = UPPER(trim(pNom1)) || " " || UPPER(trim(pNom2));
			LET vlastName = UPPER(trim(pApellpaterno)) || " " || UPPER(trim(pApellmaterno));
			LET vfirstName = trim(vfirstName);
			LET vlastName = trim(vlastName);
	
			select NVL(COUNT(uid),0), nvl(uid,"0") 
			INTO iExiste2,uidWC 
			from bdiauditor:"informix".worldcheck_compara
			where last_name = vlastName
			and first_name = vfirstName 
			and dob =  vfechanac
			and eliminado <> 'S' group by 2;
			
			if (iExiste2 is null) then
				LET iExiste2 = 0;
				LET uidWC = "0";
			end if
					
			IF ((iExiste1 > 0) or (iExiste2 > 0)) THEN
				LET CodRet = '000002';
			
			LET vfechanac = substr(current,1,10);  
			LET fecha = substr(vfechanac,6,2) || "/" || substr(vfechanac,9,2) || "/" || substr(vfechanac,1,4);
			LET hora = substr(current,12,8);
					
			INSERT INTO bdiauditor:"informix".bitacora_worldcheck (apell_pat,apell_mat,nombre1,nombre2,fecha_nac,sucursal,usuario,uid,lista_interna,fecha_proceso,hora_proceso)
				VALUES (pApellpaterno,pApellmaterno,pNom1,pNom2,pFechanac,pSucursal,pUsuario,uidWC,iExiste1,fecha,hora);
			

			ELSE 
				LET CodRet = '000000'; --NO EXISTE EL CLIENTE EN LA LISTA NEGRA
			END IF 

		ELSE 
			
			LET CodRet = '000001'; --NO RECIBE LOS PARAMETROS CORRECTOS
		
		END IF 	
		
		RETURN  CodRet;
		
		
	END;
END PROCEDURE
;