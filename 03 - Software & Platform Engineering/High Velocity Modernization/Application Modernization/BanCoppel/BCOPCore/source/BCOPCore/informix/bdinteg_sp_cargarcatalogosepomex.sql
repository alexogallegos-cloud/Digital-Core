CREATE PROCEDURE "informix".sp_cargarcatalogosepomex()
        RETURNING CHAR(5), CHAR(80);

--Elaboró: Bernardo Báez
--Fecha: 10-12-2009
--Se creo un proceso que permitirá la carga de archivos a la base de datos bdinteg:si_catSEPOMEX
--Este proceso registrará su actividad en la bitacora si_bitacora_dom
--la ruta y nombre de archivo se tomaran de la tabla si_param_dom para los codigos 6 y 7
--la fecha del proceso 
--se eliminaran los archivos anteriores de la ruta

--Modifico: Jesus Adilene Lara Armenta
--Fecha: 15-02-2010
--Se modifico para que al momento de cargar el archivo txt con los domicilios actuales, 
--si el registro tiene un valor NULL en el campo d_ciudad se inserte el valor contenido en el campo d_mnpio y
--se valide que el campo d_codigo tenga una longitud de 5 digitos y se agrega un 0 a la izquierda en los casos donde solo es de 4

--Modifico: Mohamed Carreón
--Fecha: 06-04-2010
--Se modifico conveniente al folio cmmi 1148 de SEPOMEX, 
--1.- Quitar el borrado de la tabla de catalogo de sepomex.
--2.- Insertar solo los registros nuevos.
--3.- Actualizar solo los codigos postales que cambiaron.

-- Modificó: Adrian Lara
-- Fecha: 21/06/2010
-- Se modifica la forma de reemplazar las minusculas por mayusculas, y la letra ñ para que se realice desde la consola

--Modificó: MACF
--Fecha: 20111124 - 20100803

DEFINE vCodRet                  CHAR(5);
DEFINE vMensaje                 CHAR(80);
--DEFINE vMensaje                 CHAR(200);  -- solo test MACF
DEFINE SQL_ERR                  INTEGER;
DEFINE ISAM_ERR                 INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE cNombreProceso           CHAR(30);
DEFINE iRegistros               INTEGER;
DEFINE cCadena                  CHAR(2000);
DEFINE cEmpresa                 CHAR(3);
DEFINE iParamRuta               INTEGER;
DEFINE iParamNombre             INTEGER;
DEFINE cRuta                    CHAR(100);
DEFINE cNombre                  CHAR(100);
DEFINE cNombre2                 CHAR(100);
DEFINE cNombreBase              CHAR(100);
DEFINE cNombreBase2              CHAR(100);
DEFINE v_fecha                  DATE;
DEFINE v_dia                    CHAR(2);
DEFINE v_mes                    CHAR(2);
DEFINE v_anio                   CHAR(4);
DEFINE v_d_codigo           CHAR(5);
DEFINE v_d_asenta			CHAR(60);
DEFINE v_d_tipo_asenta		CHAR(25);		
DEFINE v_d_mnpio			CHAR(40);	
DEFINE v_d_estado			CHAR(60);
DEFINE v_d_ciudad			CHAR(100);
DEFINE v_c_estado			CHAR(2);
DEFINE v_paso               INTEGER;
DEFINE v_Status				INTEGER;
DEFINE v_Band1				CHAR(1);

DEFINE s_d_asenta			CHAR(60);
DEFINE s_d_tipo_asenta		CHAR(25);
DEFINE s_d_mnpio			CHAR(40);
DEFINE s_d_estado			CHAR(60);
DEFINE s_d_ciudad			CHAR(100);
DEFINE i_d_cp				INTEGER;
DEFINE s_c_estado			INTEGER;
DEFINE s_d_codigo           CHAR(5);
DEFINE iNumDuplic           INTEGER;
DEFINE s_d_tipo_asenta_unico CHAR(25);
DEFINE i_estado             INTEGER;

DEFINE v_d_asenta_2			CHAR(60);
DEFINE v_d_ciudad_2			CHAR(100);
DEFINE v_c_estado_2			CHAR(2);
DEFINE v_d_codigo_2         CHAR(5);
DEFINE v_d_codigo_1         CHAR(5);
DEFINE s_d_mnpio_2			CHAR(40);
DEFINE v_fecha_baja         DATE;

LET cNombreProceso  = 'CARGA DE CATALOGOS SEPOMEX';
LET vCodRet         = '11111';
LET vMensaje        = 'PROCESO INICIALIZADO';
LET iRegistros      = 0;
LET cCadena         = '';
LET cEmpresa        = '001';
LET iParamRuta      = 6;
LET iParamNombre    = 7;
LET cRuta           = '';
LET cNombre         = '';
LET v_fecha         = DATE(1);
LET v_Status		= 0;
LET v_Band1			= "0";

LET s_d_asenta			= "";
LET s_d_tipo_asenta		= "";
LET s_d_mnpio			= "";
LET s_d_estado			= "";
LET s_d_ciudad			= "";
LET i_d_cp				= 0;
LET s_c_estado			= 0;
LET s_d_codigo          = "";
LET iNumDuplic          = 0;
LET s_d_tipo_asenta_unico = "";
LET i_estado              = 0;
LET v_d_asenta_2		 = '';
LET v_d_ciudad_2		 = '';
LET v_c_estado_2		 = '';
LET v_d_codigo_2         = '';
LET s_d_mnpio_2			 = '';
LET v_d_codigo_1         = '';
LET v_c_estado			 = '';
LET v_d_estado           = '';
LET v_d_ciudad           = '';
LET v_d_mnpio            = '';
LET v_d_tipo_asenta      = '';
LET v_d_asenta           = '';
LET v_d_codigo           = '';
LET v_fecha_baja         = date(1);

  --SET DEBUG FILE TO "/ifxsif01/macf/sp_CargarCatalogoSEPOMEX.out";    
  --TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET pdqpriority 20;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;

        IF vCodRet = '-668' and v_paso = 1 then
            LET vCodRet = '00003';
            LET vMensaje = 'NO EXISTE LA RUTA QUE SE INDICA EN LOS PARAMETROS';
        ELIF vCodRet = '-668' and v_paso = 6 then
            LET vCodRet = '00004';
            LET vMensaje = 'LA ESTRUCTURA DE LOS DATOS DEL ARCHIVO ES INCORRECTA';
        END IF; 

		--LET vMensaje = trim(vMensaje) || 'Paso: ' || v_paso || ' ' || trim(v_d_codigo) || ' ' || trim(v_d_asenta) || ' ' || trim(v_d_mnpio) || ' ' || trim(v_d_ciudad) || ' ' || v_c_estado;  -- Solo test MACF
		LET vMensaje = trim(vMensaje) || 'Paso: ' || v_paso;
		
        --insertar control de procesos
        INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

        RETURN vCodRet, vMensaje;
    END EXCEPTION;

UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:si_catsepomex;

SELECT fecha_hoy 
into v_fecha
from bdinteg:si_fechas
where empresa = cEmpresa;

 /*LET v_fecha = mdy('08','12','2022');  -- SOLO TEST MACF*/

INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_valida_catsepomex'  AND dbsname = 'bdinteg') THEN
        DROP TABLE tmp_valida_catsepomex;
END IF;

IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_si_catsepomex'  AND dbsname = 'bdinteg') THEN
         DROP TABLE tmp_si_catsepomex;
END IF;

IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_si_catsepomex_duplicados'  AND dbsname = 'bdinteg') THEN
          DROP TABLE tmp_si_catsepomex_duplicados;
END IF;


IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_si_catsepomex_dup_07'  AND dbsname = 'bdinteg') THEN
          DROP TABLE tmp_si_catsepomex_dup_07;
END IF;

IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_si_catsepomex_dup_04'  AND dbsname = 'bdinteg') THEN
          DROP TABLE tmp_si_catsepomex_dup_04;
END IF;

IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_si_catsepomex_notexist'  AND dbsname = 'bdinteg') THEN
          DROP TABLE tmp_si_catsepomex_notexist;
END IF;




CREATE TABLE tmp_si_catsepomex
(
	d_codigo            CHAR(5),
	d_asenta            CHAR(60),
	d_tipo_asenta       CHAR(25),
	d_mnpio             CHAR(40),
	d_estado            CHAR(60),
	d_ciudad            CHAR(100),
	d_cp                INTEGER,
	c_estado            INTEGER
);

CREATE TABLE tmp_valida_catsepomex
(
	valor CHAR(200)
);

CREATE TABLE tmp_si_catsepomex_duplicados
(
	d_asenta            CHAR(60),
	d_tipo_asenta       CHAR(25),
	d_mnpio             CHAR(40),
	d_estado            CHAR(60),
	d_ciudad            CHAR(100),
	d_cp                INTEGER,
	c_estado            INTEGER
);


CREATE INDEX tmpSiCatsepomex ON tmp_si_catsepomex
(d_codigo) USING btree ;


CREATE INDEX tmpSiCatsepomexDup ON tmp_si_catsepomex_duplicados
(d_cp) USING btree ;















CREATE TABLE tmp_si_catsepomex_dup_07
(
	d_codigo            CHAR(5),
	d_asenta            CHAR(60),
	--d_tipo_asenta       CHAR(25),  -- habilitar MACF 2022-07-18
	d_mnpio             CHAR(40),
	d_estado            CHAR(60),
	d_ciudad            CHAR(100),
	c_estado            INTEGER,
	cantidad            integer
);


CREATE INDEX tmpSiCatsepomex_dup_07 ON tmp_si_catsepomex_dup_07
(d_codigo) USING btree ;
----- Tabla temp para quitar los duplicados MACF

CREATE TABLE tmp_si_catsepomex_dup_04
(
	d_asenta            CHAR(60),
	d_mnpio             CHAR(40),
	d_ciudad            CHAR(100),
	c_estado            INTEGER,
	cantidad            integer
);

CREATE INDEX tmpSiCatsepomex_dup_04 ON tmp_si_catsepomex_dup_04
(d_asenta,d_mnpio,d_ciudad,c_estado) USING btree ;










 
/*IF day(v_fecha) < 10 then
	LET v_dia = '0' || day(v_fecha);
ELSE
	LET v_dia = day(v_fecha);
END IF;

IF month(v_fecha) < 10 then
	LET v_mes = '0' || month(v_fecha);
ELSE
	LET v_mes = month(v_fecha);
END IF;

LET v_anio = year(v_fecha);*/

SELECT valor 
INTO cRuta
FROM bdinteg:si_param_dom 
where empresa = cEmpresa 
	and cod_param = iParamRuta;

SELECT valor 
INTO cNombre
FROM bdinteg:si_param_dom 
where empresa = cEmpresa 
	and cod_param = iParamNombre;

IF (cRuta is not null) and (cNombre is not null) and (cRuta <> '') and (cNombre <> '') then

    --LET cNombreBase = trim(cNombre) || '*.txt';
    LET cNombreBase = SUBSTR(cNombre,1,LENGTH(cNombre)) || '*.txt';
    --LET cNombreBase2 = trim(cNombre) || 'BASE2.txt';
    LET cNombreBase2 = SUBSTR(cNombre,1,LENGTH(cNombre)) || 'BASE2.txt';

	--LET cNombre2 = trim(cNombre) || v_dia || v_mes || v_anio || '_res.txt';
    --LET cNombre2 = SUBSTR(cNombre,1,LENGTH(cNombre)) || v_dia || v_mes || v_anio || '_res.txt';  -- 20210423 MACF
    --LET cNombre = trim(cNombre) || v_dia || v_mes || v_anio || '.txt';
    --LET cNombre = SUBSTR(cNombre,1,LENGTH(cNombre)) || v_dia || v_mes || v_anio || '.txt';  -- 20210423 MACF

	LET cNombre2 = SUBSTR(cNombre,1,LENGTH(cNombre)) || LPAD(day(v_fecha),2,0) ||  LPAD(month(v_fecha),2,0) || year(v_fecha) || '_res.txt'; -- 20210423 MACF
	LET cNombre  = SUBSTR(cNombre,1,LENGTH(cNombre)) || LPAD(day(v_fecha),2,0) ||  LPAD(month(v_fecha),2,0) || year(v_fecha) || '.txt';     -- 20210423 MACF
	
    LET v_paso = 1;
    --let cCadena = 'touch ' || trim(cRuta) || trim(cNombreBase2);
    let cCadena = 'touch ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombreBase2,1,LENGTH(cNombreBase2)); 
    System SUBSTR(cCadena,1,LENGTH(cCadena));

    LET v_paso = 2;
    --let cCadena = 'ls ' || trim(cRuta) || trim(cNombreBase) || ' > /tmp/validaSEPOMEX.txt';
    let cCadena = 'ls ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombreBase,1,LENGTH(cNombreBase)) || ' > /tmp/validaSEPOMEX.txt';
    System SUBSTR(cCadena,1,LENGTH(cCadena));  
	
    LET v_paso = 3;
    LET cCadena = 'echo "load from ''' || '/tmp/validaSEPOMEX.txt''' ||
    ' insert into bdinteg:tmp_valida_catsepomex" > /tmp/importa_si_catsepomex.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena)); 
	
    LET v_paso = 4;
    let cCadena = 'dbaccess bdinteg /tmp/importa_si_catsepomex.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));

    IF EXISTS (SELECT VALOR FROM tmp_valida_catsepomex where valor = trim(cRuta) || trim(cNombre)) THEN
		--CONVIERTE EL ARCHIVO DE MINUSCULAS A MAYUSCULAS Y LO GUARDA EN UN  ARCHIVO NUEVO.
		LET v_paso = 41;
		--LET cCadena = '/usr/bin/cat ' || TRIM(cRuta) || TRIM(cNombre) || "|" || " tr '''[:lower:]''' '''[:upper:]''' > /tmp/" || TRIM(cNombre) ||'';
        LET cCadena = '/usr/bin/cat ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || "|" || " tr '''[:lower:]''' '''[:upper:]''' > /tmp/" || SUBSTR(cNombre,1,LENGTH(cNombre)) ||'';
		System SUBSTR(cCadena,1,LENGTH(cCadena));
		
		--QUITA LOS ACENTOS DE LAS LETRAS DEL NUEVO ARCHIVO Y LO GUARDA EN OTRO.
		LET v_paso = 42;
		--LET cCadena = '/usr/bin/cat /tmp/' || TRIM(cNombre) || 
		--"|" || " tr '''[Á]''' '''[A]''' " || "|" || " tr '''[É]''' '''[E]''' " || "|" || " tr '''[Í]''' '''[I]''' " || 
		--"|" || " tr '''[Ó]''' '''[O]''' " || "|" || " tr '''[Ú]''' '''[U]''' " || "|" || " tr '''[ñ]''' '''[Ñ]''' > /tmp/" || TRIM(cNombre2) ||'';
        LET cCadena = '/usr/bin/cat /tmp/' || SUBSTR(cNombre,1,LENGTH(cNombre)) || 
		"|" || " tr '''[Á]''' '''[A]''' " || "|" || " tr '''[É]''' '''[E]''' " || "|" || " tr '''[Í]''' '''[I]''' " || 
		"|" || " tr '''[Ó]''' '''[O]''' " || "|" || " tr '''[Ú]''' '''[U]''' " || "|" || " tr '''[ñ]''' '''[Ñ]''' " || "|" || " tr '''[Ü]''' '''[U]''' > /tmp/" || SUBSTR(cNombre2,1,LENGTH(cNombre2)) ||'';  --Agregar la Ü
		--"|" || " tr '''[Ó]''' '''[O]''' " || "|" || " tr '''[Ú]''' '''[U]''' " || "|" || " tr '''[ñ]''' '''[Ñ]''' > /tmp/" || SUBSTR(cNombre2,1,LENGTH(cNombre2)) ||'';
		System SUBSTR(cCadena,1,LENGTH(cCadena));
		
        LET v_paso = 5;
        
		--LET cCadena = 'echo "load from ''' || TRIM(cRuta) || TRIM(cNombre) || 
		--LET cCadena = 'echo "load from ''' || "/tmp/" || TRIM(cNombre2) || 
        --''' delimiter ''	'' insert into bdinteg:tmp_si_catsepomex" > /tmp/importa_si_catsepomex.sql';
        LET cCadena = 'echo "load from ''' || "/tmp/" || SUBSTR(cNombre2,1,LENGTH(cNombre2)) || 
        ''' delimiter ''	'' insert into bdinteg:tmp_si_catsepomex" > /tmp/importa_si_catsepomex.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
		
        LET v_paso = 6;
        let cCadena = 'dbaccess bdinteg /tmp/importa_si_catsepomex.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
        LET v_paso = 7;
        let cCadena = 'rm /tmp/importa_si_catsepomex.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
        LET v_paso = 8;
	
		--- /// Mohamed Carreón  >>>  Modificación 1.
        --- DELETE FROM bdinteg:si_catsepomex;
			
		--- LE PONE EL CERO A LA IZQUIERDA AL CODIGO POSTAL Y ACTUALIZA LA CIUDAD CON EL VALOR DEL MUNICIPIO EN CASO DE QUE NO LA TRAIGA
		UPDATE bdinteg:tmp_si_catsepomex
		SET d_codigo = LPAD(TRIM(d_codigo),5,"0"),
			d_ciudad = DECODE(d_ciudad,NULL,d_mnpio,d_ciudad);
		
		LET v_d_codigo = ""; LET s_d_asenta = "";  LET s_d_tipo_asenta = ""; LET s_d_mnpio = "";  LET s_d_estado = "";  LET s_d_ciudad = "";
		LET i_d_cp = 0 ;     LET s_c_estado = 0;   LET iNumDuplic = 0;
		
		
        LET v_paso = 81;		
		-- 2o BUSCAR LOS DUPLICADOS CONSIDERANDO LOS 7 CAMPOS (d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, d_cp, c_estado, cantidad)
		INSERT INTO tmp_si_catsepomex_dup_07
		SELECT d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, LPAD(c_estado,2,'0') c_estado, count(*) cantidad
          FROM bdinteg:tmp_si_catsepomex
         GROUP BY c_estado, d_estado, d_mnpio, d_ciudad, d_asenta, d_codigo;
        --HAVING COUNT(*)> 1;
		
		/*LET v_paso = 82;
		FOREACH WITH HOLD
			SELECT d_codigo, d_asenta, d_mnpio, d_ciudad, c_estado, d_estado, cantidad
			INTO v_d_codigo, s_d_asenta, s_d_mnpio, s_d_ciudad, v_c_estado, s_d_estado, iNumDuplic
			FROM tmp_si_catsepomex_dup_07
		    ORDER BY c_estado, d_mnpio, d_ciudad, d_asenta, d_codigo
		

				IF iNumDuplic = 2 THEN
				   SELECT limit 1 d_tipo_asenta INTO s_d_tipo_asenta_unico
			         FROM bdinteg:tmp_si_catsepomex 
			        WHERE d_codigo = v_d_codigo AND d_asenta = s_d_asenta AND d_mnpio = s_d_mnpio
		              AND d_ciudad = s_d_ciudad and c_estado = v_c_estado;
					  
					begin;
					   DELETE bdinteg:tmp_si_catsepomex WHERE d_codigo = v_d_codigo and d_asenta = s_d_asenta and d_mnpio = s_d_mnpio
					   and d_ciudad = s_d_ciudad and c_estado = v_c_estado;
					commit;
					
					begin;
					   INSERT INTO bdinteg:tmp_si_catsepomex(d_codigo, d_asenta, d_tipo_asenta, d_mnpio, d_estado, d_ciudad, d_cp, c_estado)
					   VALUES(v_d_codigo, s_d_asenta, s_d_tipo_asenta_unico, s_d_mnpio, s_d_estado, s_d_ciudad, 0, v_c_estado);
					commit;
			    ELIF iNumDuplic > 2 THEN
				   
					FOREACH WITH HOLD
					   SELECT d_codigo, d_asenta, d_ciudad, c_estado, d_mnpio
						 INTO v_d_codigo_2, v_d_asenta_2, v_d_ciudad_2, v_c_estado_2, s_d_mnpio_2
						 FROM bdinteg:tmp_si_catsepomex
						WHERE d_codigo = v_d_codigo 
						  AND d_asenta = s_d_asenta
						  AND d_ciudad = s_d_ciudad
						  AND c_estado = v_c_estado
						  AND d_mnpio = s_d_mnpio 
						  
						  IF s_d_asenta = v_d_asenta_2 AND s_d_ciudad = v_d_ciudad_2 AND v_c_estado = v_c_estado_2 AND  v_d_codigo = v_d_codigo_2 and s_d_mnpio = s_d_mnpio_2 THEN
							 begin;
							   DELETE bdinteg:tmp_si_catsepomex WHERE d_codigo = v_d_codigo and d_asenta = s_d_asenta and d_mnpio = s_d_mnpio
							 and d_ciudad = s_d_ciudad and  c_estado = v_c_estado;
							 commit;
						  END IF;	  
						  
						  
						LET v_d_asenta_2 = ''; 
						LET v_d_ciudad_2 = '';
						LET v_c_estado_2 = '';
						LET v_d_codigo_2 = '';
						LET s_d_mnpio_2  = '';
			        END FOREACH;
				
				END IF;
			
		
		END FOREACH;
		*/
		
		---- SE ELIMNA ESTE BLOQUE DE DEPURADO DE CAMPOS REPETIDOS 2022-06-29
		/*LET v_paso = 83;
		  {3o BUSCAR LOS REPETIDOS CONSIDERANDO LOS 4 CAMPOS}
		  {Hacer rutina de encontrar las otras colonias duplicadas. Campos: d_asenta, d_mnpio, c_estado, d_ciudad (solo con esos)}
		truncate tmp_si_catsepomex_dup_07;
		
	    LET v_paso = 84;
		INSERT INTO tmp_si_catsepomex_dup_04
		SELECT d_asenta, d_mnpio, d_ciudad, c_estado, count(*) cantidad
          FROM bdinteg:tmp_si_catsepomex
         GROUP BY 1,2,3,4 
        HAVING COUNT(*)> 1;
		
		LET v_paso = 85;
		FOREACH WITH HOLD
		    SELECT d_asenta, d_mnpio, d_ciudad, c_estado, cantidad
			INTO s_d_asenta, s_d_mnpio, s_d_ciudad, s_c_estado, iNumDuplic
			FROM tmp_si_catsepomex_dup_04
 
			SELECT limit 1 d_codigo, d_tipo_asenta, d_estado INTO v_d_codigo, s_d_tipo_asenta_unico, s_d_estado
			  FROM bdinteg:tmp_si_catsepomex 
			 WHERE d_asenta = s_d_asenta AND d_mnpio = s_d_mnpio
		       AND d_ciudad = s_d_ciudad and c_estado = s_c_estado;
		
		    IF iNumDuplic > 1 THEN
				begin;
				   DELETE bdinteg:tmp_si_catsepomex WHERE d_asenta = s_d_asenta AND d_mnpio = s_d_mnpio
				   AND d_ciudad = s_d_ciudad AND c_estado = s_c_estado;
				commit;
				
				begin;
				   INSERT INTO bdinteg:tmp_si_catsepomex(d_codigo, d_asenta, d_tipo_asenta, d_mnpio, d_estado, d_ciudad, d_cp, c_estado)
				   VALUES(v_d_codigo, s_d_asenta, s_d_tipo_asenta_unico, s_d_mnpio, s_d_estado, s_d_ciudad, 0, s_c_estado);
				commit;
			
            END IF;		
		    
			LET s_d_tipo_asenta_unico = "";
		
		END FOREACH
		*/
		
		/*
		--- /// Mohamed Carreón  >>>  SE AGREGO VALIDACION PARA BORRAR LOS REGISTROS DUPLICADOS Y DEJAR LA PRIMER COLONIA
		--- PONE LOS REGISTROS DUPLICADOS EN LA TABLA TEMPORAL
		INSERT INTO tmp_si_catsepomex_duplicados
		SELECT d_asenta,d_tipo_asenta,d_mnpio,d_estado,d_ciudad,d_cp,c_estado  
		FROM bdinteg:tmp_si_catsepomex 
		GROUP BY d_asenta,d_tipo_asenta,d_mnpio,d_estado,d_ciudad,d_cp,c_estado
		HAVING COUNT(d_asenta) > 1;
		
		--- CICLO PARA BARRER LOS REGSITROS QUE SE ENCONTRARON DUPLICADOS
		FOREACH
			SELECT d_asenta, d_tipo_asenta, d_mnpio, d_estado, d_ciudad, d_cp, c_estado
			INTO s_d_asenta, s_d_tipo_asenta, s_d_mnpio, s_d_estado, s_d_ciudad, i_d_cp, s_c_estado
			FROM tmp_si_catsepomex_duplicados
			
			SELECT MIN(d_codigo) 
			INTO s_d_codigo
			FROM tmp_si_catsepomex 
			WHERE d_asenta = s_d_asenta AND d_tipo_asenta = s_d_tipo_asenta AND d_mnpio = s_d_mnpio 
			AND d_estado = s_d_estado AND d_ciudad = s_d_ciudad AND d_cp = i_d_cp AND c_estado = s_c_estado;
			
			--- BORRAR LOS REGISTROS DUPLICADOS Y DEJA EL QUE TIENE EL CODIGO POSTAL MAS NUEVO
			DELETE bdinteg:tmp_si_catsepomex 
			WHERE d_asenta = s_d_asenta AND d_tipo_asenta = s_d_tipo_asenta AND d_mnpio = s_d_mnpio 
			AND d_estado = s_d_estado AND d_ciudad = s_d_ciudad AND d_cp = i_d_cp AND c_estado = s_c_estado
			AND d_codigo <> s_d_codigo;
		END FOREACH
		*/ 
		LET v_paso = 86;
		--- VALIDA SI LA TABLA DE CATALOGO DE SEPOMEX ESTA VACIA
		IF (SELECT COUNT(d_codigo) FROM bdinteg:si_catsepomex) = 0 THEN
			LET v_Band1 = "1";
		END IF
		
		LET v_paso = 87;
		LET v_d_codigo_2 = '';
		LET v_d_codigo_1 = '';
		
        FOREACH
		SELECT TRIM(d_codigo), TRIM(d_asenta), TRIM(d_mnpio), TRIM(d_ciudad), LPAD(c_estado,2,'0'), TRIM(d_estado)
		  into v_d_codigo, v_d_asenta, v_d_mnpio, v_d_ciudad, v_c_estado, v_d_estado
        --FROM bdinteg:tmp_si_catsepomex
		 FROM tmp_si_catsepomex_dup_07

			
			--- VALIDA BANDERA DE EXISTENCIA DE DATOS DE LA TABLA DE CATALOGO DE SEPOMEX
			IF v_Band1 = "1" THEN
				LET v_Status = 2;
			ELSE
			

					--- VALIDA QUE EXISTA EN EL CATALOGO DE SEPOMEX (con CP y todos sus demás datos)





					 SELECT d_codigo INTO v_d_codigo_1		
					   FROM bdinteg:si_catsepomex WHERE d_codigo = v_d_codigo
					   AND d_asenta = v_d_asenta AND d_mnpio = v_d_mnpio
					   AND c_estado = v_c_estado AND d_ciudad = v_d_ciudad AND nvl(fecha_baja,'') = ''; -- pend validar si se agrega la fecha_baja
						
						LET v_Status = 1;
						
						IF NVL(v_d_codigo_1,'') <> '' THEN
							UPDATE bdinteg:si_catsepomex
							SET estatus = v_Status --, fecha_ejecucion = v_fecha (ya no actualizar la fecha_ejecucion)
							WHERE d_codigo = v_d_codigo        
							AND d_asenta = v_d_asenta --AND d_tipo_asenta = v_d_tipo_asenta   -- 20210609 Ya no considerar el d_tipo_asenta
							AND c_estado = v_c_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio;


							LET v_d_codigo_1 = '';
							
                            CONTINUE FOREACH;
							
						ELSE

						    SELECT d_codigo, fecha_baja into v_d_codigo_2, v_fecha_baja
						      FROM bdinteg:si_catsepomex 
						     WHERE d_codigo = v_d_codigo 
							   AND d_asenta = v_d_asenta 
						       AND c_estado = v_c_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio 
						       AND nvl(fecha_baja,'') <> ''; 

						       LET v_Status = 5;	--- Se identificará con este estatus para que el sp_conciliarcolonias_sepomex la tome como una "actualización" y la reactive
                                                    --- ya que existira en si_catzonas con los campos nomzona_spmx, pobzona_spmx y mnpio_spmx vacías
						
							IF NVL(v_d_codigo_2,'') <> '' THEN
						
									UPDATE bdinteg:si_catsepomex
									SET estatus = v_Status, fecha_alta = v_fecha, fecha_baja = null
									WHERE d_codigo = v_d_codigo 
									AND d_asenta = v_d_asenta 
									AND c_estado = v_c_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio;
								
									LET v_d_codigo_2 = '';
								
									LET iRegistros = DBINFO("sqlca.sqlerrd2");
									
									IF iRegistros > 0 THEN 
									   
									   INSERT INTO bdinteg:si_catsepomex_his(d_codigo, d_asenta,d_mnpio, d_estado, d_ciudad, c_estado, estatus, fecha_baja, fecha_reactiva)
									   VALUES(v_d_codigo,v_d_asenta,v_d_mnpio,v_d_estado,v_d_ciudad,v_c_estado,v_Status,v_fecha_baja,v_fecha); 
										
									END IF;
									
									CONTINUE FOREACH;
							
						     ELSE 
							    /*
							    SELECT d_codigo, fecha_baja into v_d_codigo_3, v_fecha_baja
						          FROM bdinteg:si_catsepomex 
						         WHERE d_codigo = v_d_codigo  AND d_asenta = v_d_asenta AND d_mnpio = v_d_mnpio
						           AND c_estado = v_c_estado AND d_ciudad = v_d_ciudad 
						           AND nvl(fecha_baja,'') <> '';
							 
							 
							    IF NVL(v_d_codigo_3,'') <> '' AND NVL(v_fecha_baja,'') <> '' THEN
							 
							       INSERT INTO bdinteg:si_casepomex_his(d_codigo, d_asenta, d_tipo_asenta, d_mnpio, d_estado, d_ciudad, c_estado, estatus, fecha_ejecucion, fecha_baja)
								     VALUES(v_d_codigo_3, v_d_asenta, v_d_tipo_asenta, v_d_mnpio, v_d_estado, v_d_ciudad, v_c_estado, v_Status, v_fecha, v_fecha);

                                END IF;*/
							 
                                 LET v_Status = 2;
								 
						 
						     END IF;
						END IF;
						
					    --ELSE
						--- CUANDO CAMBIA EL CODIGO POSTAL (si es el mismo asentamiento)
						/*IF EXISTS(SELECT d_codigo FROM bdinteg:si_catsepomex 
								   WHERE d_asenta = v_d_asenta AND d_tipo_asenta = v_d_tipo_asenta   -- 20210609 Ya no considerar el d_tipo_asenta
								   AND d_estado = v_d_estado AND d_ciudad = v_d_ciudad 
								) THEN*/

							--LET v_Status = 3;
							
						

				--ELSE
							--- CUANDO ES UN CODIGO POSTAL NUEVO
							--LET v_Status = 2;
						---END IF				
					--END IF	
					
					
				/*ELSE
			    	
					--- VALIDA QUE EXISTA EN EL CATALOGO DE SEPOMEX (2) EDO =9
					IF EXISTS (SELECT d_codigo FROM bdinteg:si_catsepomex WHERE d_codigo = v_d_codigo 
							--AND d_asenta = v_d_asenta AND d_tipo_asenta = v_d_tipo_asenta   -- 20210609 Ya no considerar el d_tipo_asenta
							AND d_asenta = v_d_asenta 
							AND d_estado = v_d_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio
							) THEN
						LET v_Status = 1;
						
						UPDATE bdinteg:si_catsepomex
						SET estatus = v_Status , fecha_ejecucion = v_fecha
						WHERE d_codigo = v_d_codigo        
						AND d_asenta = v_d_asenta --AND d_tipo_asenta = v_d_tipo_asenta -- 20210609 Ya no considerar el d_tipo_asenta
						AND d_estado = v_d_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio;
						
						CONTINUE FOREACH;
					ELSE
						--- CUANDO CAMBIA EL CODIGO POSTAL (2)
						IF EXISTS(SELECT d_codigo FROM bdinteg:si_catsepomex 
								--WHERE d_asenta = v_d_asenta AND d_tipo_asenta = v_d_tipo_asenta  -- 20210609 Ya no considerar el d_tipo_asenta
								WHERE d_asenta = v_d_asenta 
								AND d_estado = v_d_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio
								) THEN
							LET v_Status = 3;
						
							UPDATE bdinteg:si_catsepomex
							SET estatus = v_Status, d_codigo = v_d_codigo, fecha_ejecucion = v_fecha
							WHERE d_asenta = v_d_asenta --AND d_tipo_asenta = v_d_tipo_asenta   -- 20210609 Ya no considerar el d_tipo_asenta
							AND d_estado = v_d_estado AND d_ciudad = v_d_ciudad AND d_mnpio = v_d_mnpio;
							
							CONTINUE FOREACH;
						ELSE
							--- CUANDO ES UN CODIGO POSTAL NUEVO (2)
							LET v_Status = 2;
						END IF				
					END IF	
					
				*/	
			END IF;
			
			LET i_estado = 0;
            let v_c_estado = lpad(trim(v_c_estado), 2, '0');
            LET iRegistros = iRegistros + 1;
            LET v_d_asenta = upper(v_d_asenta);
            LET v_d_tipo_asenta = upper(v_d_tipo_asenta);
            LET v_d_mnpio  = upper(v_d_mnpio);
            LET v_d_estado = upper(v_d_estado);
            LET v_d_ciudad = upper(v_d_ciudad);            
            LET v_d_codigo = lpad(trim(v_d_codigo),5,"0");
			
            INSERT INTO bdinteg:si_catsepomex (d_codigo,d_asenta,d_tipo_asenta,d_mnpio,d_estado,d_ciudad,c_estado,estatus,fecha_ejecucion,fecha_alta)
            VALUES(v_d_codigo, v_d_asenta, v_d_tipo_asenta, v_d_mnpio, v_d_estado, v_d_ciudad, v_c_estado, v_Status, v_fecha, v_fecha);
            LET iRegistros = iRegistros;
        END FOREACH;
		

		---BUSCAR cols que están en si_catsepomex y ya no en archivo que se está cargando, para darlas de baja  --METODO INDICADO POR PAM
		/*INSERT INTO tmp_si_catsepomex_notexist
		SELECT a.d_codigo, a.d_asenta, a.d_mnpio, a.d_ciudad, a.c_estado
		  FROM bdinteg:si_catsepomex a
		        left join tmp_si_catsepomex_dup_07 b on a.d_codigo = b.d_codigo and a.d_asenta = b.d_asenta and a.d_mnpio = b.d_mnpio
                                                        and a.d_ciudad = b.d_ciudad and a.c_estado = b.c_estado				
		  WHERE nvl(a.fecha_baja,'') = '';
		  --INTO temp tmp_si_catsepomex_notexist with no log;
		  
		FOREACH 
 		 select d_codigo, d_asenta, d_mnpio, d_ciudad, c_estado
		    into v_d_codigo, v_d_asenta, v_d_mnpio, v_d_ciudad, v_c_estado
		    from tmp_si_catsepomex_notexist
		
		    IF NVL(v_d_codigo,'') <> '' THEN
		       UPDATE bdinteg:si_catsepomex SET estatus = 4, fecha_baja = v_fecha
		       WHERE d_codigo = v_d_codigo AND d_asenta = v_d_asenta AND d_mnpio= v_d_mnpio AND d_ciudad = v_d_ciudad AND c_estado = v_c_estado;
		    END IF;
			
		END FOREACH;  */

		--PROBAR ahora barriendo la tabla, así si funciona
		IF v_Band1 <> "1" THEN
			FOREACH WITH HOLD
			   SELECT a.d_codigo, a.d_asenta, a.d_mnpio, a.d_ciudad, a.c_estado
				 into v_d_codigo, v_d_asenta, v_d_mnpio, v_d_ciudad, v_c_estado  
				 FROM bdinteg:si_catsepomex a
				 WHERE nvl(a.fecha_baja,'') = ''
			
				SELECT d_codigo into v_d_codigo_1
				  FROM tmp_si_catsepomex_dup_07		
				  WHERE d_codigo = v_d_codigo 
					and d_asenta = v_d_asenta 
					and d_mnpio = v_d_mnpio
					and d_ciudad = v_d_ciudad 
					and c_estado = v_c_estado;

				IF NVL(v_d_codigo_1,'') = '' THEN
				   UPDATE bdinteg:si_catsepomex SET estatus = 4, fecha_baja = v_fecha
				   WHERE d_codigo = v_d_codigo AND d_asenta = v_d_asenta AND d_mnpio= v_d_mnpio AND d_ciudad = v_d_ciudad AND c_estado = v_c_estado;
				END IF;
			
			
			END FOREACH;
		END IF;
		
		---  **************
        ---DROP TABLE bdinteg:tmp_si_catsepomex;
        LET vCodRet         = '00000';
        LET vMensaje        = 'PROCESO EXITOSO';

        LET v_paso = 9;
        --let cCadena = 'find /tmp/' || trim(cNombre) || ' -exec rm {} \;';
        let cCadena = 'find /tmp/' || SUBSTR(cNombre,1,LENGTH(cNombre)) || ' -exec rm {} \;';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
		
        LET v_paso = 10;
		--let cCadena = 'find /tmp/' || trim(cNombre2) || ' -exec rm {} \;';
        let cCadena = 'find /tmp/' || SUBSTR(cNombre2,1,LENGTH(cNombre2)) || ' -exec rm {} \;';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
		
    ELSE
        LET v_paso = 11;
        --let cCadena = 'rm ' || trim(cRuta) || trim(cNombreBase2);
        let cCadena = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre2,1,LENGTH(cNombre2));
        System SUBSTR(cCadena,1,LENGTH(cCadena));
      
        LET vCodRet         = '00002';
        LET vMensaje        = 'NO EXISTE EL ARCHIVO EN LA RUTA QUE INDICADA EN LOS PARAMETROS';
    END IF;
ELSE
    LET vCodRet         = '00001';
    LET vMensaje        = 'FALTAN PARAMETROS EN TABLA bdinteg:SI_PARAM_DOM';
END IF

UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:si_catsepomex;

INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

RETURN vCodRet, vMensaje;
END 
END PROCEDURE;