CREATE PROCEDURE "informix".sp_mindsbancatradicional_por_fechas(pfecha_ini DATE, pfecha_fin DATE)
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
DEFINE vsql						LVARCHAR(600);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_BANCA	VARCHAR(100);
DEFINE fname					VARCHAR(200);

--VARIABLE LAYOUT BANCA TRADICIONAL
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
DEFINE v_clavemoneda 			CHAR(2);
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
DEFINE v_fecha_hoy				DATE;
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
--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_clavemoneda = '1';
LET v_idinstrumentomonetario = '1';
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
	
	LET cDiaI = LPAD(DAY(pfecha_ini), 2, '0');
	LET cMesI = LPAD(MONTH(pfecha_ini), 2, '0');
	LET cAnoI = YEAR(pfecha_ini);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaI = cAnoI||cMesI||cDiaI;
	
	LET cDiaF = LPAD(DAY(pfecha_fin), 2, '0');
	LET cMesF = LPAD(MONTH(pfecha_fin), 2, '0');
	LET cAnoF = YEAR(pfecha_fin);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaF = cAnoF||cMesF||cDiaF;
	
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_BANCA = 'CargaBancaMinds_'||TRIM(cFechaI)||'_'||TRIM(cFechaF);
	
	LET vpaso = 2;
	
	--CREACION TABLA TEMPORAL 
	SELECT * FROM "informix".tbl_bancatradicional_minds_fechas
	WHERE idregistro IS NULL
	INTO TEMP tmp_tbl_bancatradicional_minds_fechas 	WITH NO LOG;
	
	LET vpaso = 3;
	
	FOREACH WITH HOLD
		SELECT {+AVOID_FULL(bdicheq:sc_movhis)} {+AVOID_FULL(bdiauditor:transacc_minds)} a.sucursal,TO_CHAR(a.fech_alt, "%m") ||  TO_CHAR(a.fech_alt, "%y") || a.num_serial,a.usuario,a.fech_alt,a.monto_tot,
		a.fech_hor,a.sdo_cuenta,a.cuenta,a.producto,b.naturaleza,a.transacc,a.referencia_23
		INTO v_aliassucursal,v_numeroreferencia,v_noempleado,temp_fecha,v_monto,temp_hora,v_saldoinicial,v_nocuenta,v_clavesubproducto,v_naturaleza,v_idconcepto,v_ref23
		FROM bdicheq:sc_movhis a, bdiauditor:transacc_minds b
		WHERE a.fech_alt BETWEEN pfecha_ini AND pfecha_fin
		AND a.cancelad <> 'S'
		AND b.tipo='DB' AND a.transacc=b.transacc
		AND a.producto <> '1100' -- NO EXTRAER INVERSION CRECIENTE
		--IF ctransacc = bdauditor:transacc_minds.transacc 
		--IN ('0202','0204','0205','0206','0210','0211','0213','0215','0216','0223','0243','0250','0271','0272','0273','0274','0275',
		--	'0300','0305','0309','0310','0312','0313','0318','0325','0329','0330','0402','0403','0404','0405','0406','0407','0426',
		--	'0427','0473','0485','0612','0705','0706','0707','0755','0756','0800','0814','0817','0818','0819','0830','0832','0833',
		--	'0840','0871','0872','0873','0887','1104','1110','1113','1114','1121','1122','1123','1134','1140','1151','1152','1153',
		--	'1164','1170','1181','1182','1183','1191','1193','1194','1195','1196','1197','3016','3017','3018','3240','3241','3244',
		--	'3245','3246','0282','6282','8105','8112','8104','0407','0402','0403','0404','0405','0406','0482','0289') THEN*/
			
		LET vpaso = 4;
			
			--SELECT naturaleza
			--INTO v_naturaleza
			--FROM bdinteg:si_transacc
			--WHERE numero = ctransacc;
			
			
		LET vpaso = 5;
			
		SELECT num_cte 
		INTO v_num_cte
		FROM bdicheq:sc_maechq 
		WHERE cuenta = v_nocuenta;
			
		LET vpaso = 6;
			
		SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno
		INTO v_tpo_persona,nombrepf1,nombrepf2,nombrepm,v_apell_paterno,v_apell_materno
		FROM bdinteg:si_cliente
		WHERE numcte = v_num_cte;
			
		IF v_tpo_persona IN('01','03') THEN --PERSONA FISICA
			
			LET v_nombrecompleto = TRIM(v_num_cte) || " - " || TRIM(nombrepf1) || " " || TRIM(nombrepf2) || " " || TRIM(v_apell_paterno) || " " || TRIM(v_apell_materno);
			
		ELIF v_tpo_persona IN('02','04','05') THEN --PERSONA MORAL
				
			LET v_nombrecompleto = TRIM(nombrepm);
			
		END IF
			
		LET vpaso = 7;
			
		IF v_naturaleza = 'A' THEN --ABONO
			LET v_idtipooperacion = '1';
			LET v_depositante = NULL;
			LET v_beneficiario = v_nombrecompleto;
			LET v_cuentadestino = v_nocuenta;
			LET v_cuentaorigen = NULL;
			LET v_saldofinal = v_saldoinicial + v_monto;
			LET v_bancodestino = 'BANCOPPEL';
			LET v_bancoorigen = NULL;
		ELIF v_naturaleza = 'C' THEN --CARGO
			LET v_idtipooperacion = '2';
			LET v_depositante = v_nombrecompleto;
			LET v_beneficiario = NULL;
			LET v_cuentadestino = NULL;
			LET v_cuentaorigen = v_nocuenta;
			LET v_saldofinal = v_saldoinicial - v_monto;
			LET v_bancodestino = NULL;
			LET v_bancoorigen = 'BANCOPPEL';
		END IF
			
		LET vpaso = 8;
			
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
		
			
		LET vpaso = 9;
			
		INSERT INTO "informix".tmp_tbl_bancatradicional_minds_fechas (idregistro,aliassucursal,idtipooperacion,idinstrumentomonetario,idconcepto,claveinstrumento,numeroreferencia,noempleado,fecha,monto,montomb,depositante,beneficiario,
		hora,cuentaorigen,cuentadestino,saldoinicial,saldofinal,clavemoneda,nocuenta,clavesubproducto,fechaactualizacion,idestatuscargaminds,bancoorigen,bancodestino,fecharegistro,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_aliassucursal,v_idtipooperacion,v_idinstrumentomonetario,v_idconcepto,v_claveinstrumento,v_numeroreferencia,v_noempleado,v_fecha_actualizacion,v_monto,v_monto,v_depositante,v_beneficiario,
		v_hora,v_cuentaorigen,v_cuentadestino,v_saldoinicial,v_saldofinal,v_clavemoneda,v_nocuenta,v_clavesubproducto,v_fecha_actualizacion,v_idestatuscargaminds,v_bancoorigen,v_bancodestino,v_fecharegistro,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);
			
		LET vpaso = 10;
			
	END FOREACH
	
	LET vpaso = 11;
	
	LET fname = TRIM(RUTA_DESTINO||TIPO_PLANTILLA_BANCA) || '.txt'; 
	
	LET vsql = 'CREATE EXTERNAL TABLE tmp_tbl_bancatradicional_minds_fechas_ext ' ||
               'SAMEAS tbl_bancatradicional_minds_fechas USING ( DATAFILES("DISK:' ||
               TRIM(fname) ||
               '") );';
	
	EXECUTE IMMEDIATE vsql;
	
	LET vpaso = 12;
	
	INSERT INTO tmp_tbl_bancatradicional_minds_fechas_ext SELECT * FROM tmp_tbl_bancatradicional_minds_fechas;
	
	DROP TABLE tmp_tbl_bancatradicional_minds_fechas_ext;
	DROP TABLE tmp_tbl_bancatradicional_minds_fechas;
	
	
	LET vpaso = 13;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_BANCA);
	
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Fernando Torres Soto',
'FECHA: 18/01/2023',
'DESCRIPCION:  Generación de información de captacion para sistemas MINDS PLD por rango de fechas bajo demanda',
'BD: bdiauditor';

CREATE FUNCTION "informix".fn_formateo_chqcajas(pcadena lvarchar)
RETURNING lvarchar AS cadena;
  DEFINE cadena lvarchar;
  LET cadena = UPPER(TRIM(pcadena));
  
  LET cadena =  REPLACE(cadena, 'Á', 'A');
  LET cadena =  REPLACE(cadena, 'É', 'E');
  LET cadena =  REPLACE(cadena, 'Í', 'I');
  LET cadena =  REPLACE(cadena, 'Ó', 'O');
  LET cadena =  REPLACE(cadena, 'Ú', 'U');
  LET cadena =  REPLACE(cadena, 'Ñ', 'N');
  LET cadena =  REPLACE(cadena, 'À', 'A');
  LET cadena =  REPLACE(cadena, 'È', 'E');
  LET cadena =  REPLACE(cadena, 'Ì', 'I');
  LET cadena =  REPLACE(cadena, 'Ò', 'O');
  LET cadena =  REPLACE(cadena, 'Ù', 'U');
  LET cadena =  REPLACE(cadena, 'Ç', 'C');

  LET cadena =  REPLACE(cadena, 'á', 'A');
  LET cadena =  REPLACE(cadena, 'é', 'E');
  LET cadena =  REPLACE(cadena, 'í', 'I');
  LET cadena =  REPLACE(cadena, 'ó', 'O');
  LET cadena =  REPLACE(cadena, 'ú', 'U');
  LET cadena =  REPLACE(cadena, 'ñ', 'N');
  LET cadena =  REPLACE(cadena, 'à', 'A');
  LET cadena =  REPLACE(cadena, 'è', 'E');
  LET cadena =  REPLACE(cadena, 'ì', 'I');
  LET cadena =  REPLACE(cadena, 'ò', 'O');
  LET cadena =  REPLACE(cadena, 'ù', 'U');
  LET cadena =  REPLACE(cadena, 'ç', 'C');

  LET cadena =  REPLACE(cadena, '&', '');
  LET cadena =  REPLACE(cadena, ',', '');
  LET cadena =  REPLACE(cadena, '"', '');
  LET cadena =  REPLACE(cadena, "'", '');
  LET cadena =  REPLACE(cadena, '/', '');
  LET cadena =  REPLACE(cadena, '(', '');
  LET cadena =  REPLACE(cadena, ')', '');
  LET cadena =  REPLACE(cadena, ';', '');
  LET cadena =  REPLACE(cadena, '=', '');
  LET cadena =  REPLACE(cadena, '$', '');
  LET cadena =  REPLACE(cadena, '#', '');
 
  RETURN cadena;
END FUNCTION;