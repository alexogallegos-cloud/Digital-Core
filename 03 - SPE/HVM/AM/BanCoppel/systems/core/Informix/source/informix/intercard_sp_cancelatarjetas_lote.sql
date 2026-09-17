CREATE PROCEDURE "informix".sp_cancelatarjetas_lote()
RETURNING 	  char (5) AS COD_RET,
			  char(150) AS MENSAJE;

DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);
DEFINE CMENSAJE			CHAR(150);
DEFINE vmonto_aut 		MONEY(14,2);
DEFINE cFolio_canc 		CHAR(10);

DEFINE vclave_tipotarjeta	CHAR(2);
DEFINE vclave_sucursal		CHAR(5);
DEFINE vlote        		CHAR(5);
DEFINE vTipoTar				CHAR(1);
DEFINE vNumTrajetas			INTEGER;
DEFINE vnumcta				VARCHAR(13);
DEFINE vnumtarjeta			VARCHAR(16);
DEFINE vnumcte				VARCHAR(13);
DEFINE cRuta_repositorio	CHAR(100);
DEFINE vsmensaje_respuesta CHAR(150);
DEFINE vcodproductotarjeta CHAR(3);

DEFINE vTipoResult		CHAR(1);
DEFINE vFechaParam1 	DATETIME YEAR TO FRACTION (5);
DEFINE vNombreArchivo	VARCHAR (30) ;
DEFINE vsSQL 			CHAR (2204);

 --variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER;	

--SET DEBUG FILE TO "/informix/analy/sp_cancelatarjetas_lote.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
	IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET CMENSAJE = vErrorInfo;			
			RETURN cCodret, 'iIsamErr: '|| iIsamErr  || ' EN PASO: ' || vpaso|| ' ERR_DES ' || CMENSAJE ;
		END IF;
	END EXCEPTION;
	
	LET vTipoResult = '';
	LET vFechaParam1 = CURRENT ;
	LET vNumTrajetas = 0 ;
	let vnumcta = '';
	let vnumtarjeta = '';
	let vnumcte = '';
	LET cVarDataErr = '';
	LET cCodret='00000';
	let vsSQL = '' ;
	LET vsmensaje_respuesta = '';
	LET vcodproductotarjeta = '';
	LET vmonto_aut = 0;
	LET cFolio_canc  = "";
	

	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tmp_lotesaeliminar') THEN
		DROP TABLE tmp_lotesaeliminar;
	END IF ;
	LET vpaso = 1;
	
	CREATE TABLE intercard:tmp_lotesaeliminar(
		lote INTEGER);
			LET vpaso = 2;
			let vsmensaje_respuesta = 'Generar comando de carga.';
			
			LET vpaso = 3;
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			LET cRuta_repositorio = '/resplogifx/';
			let vssql = 'echo "load from '''|| trim(cRuta_repositorio) || 'lotes.unl' || "'" || ' insert into intercard:tmp_lotesaeliminar" > ' || trim(cRuta_repositorio) ||  'load_archivo.sql';
			system vssql;
			
			LET vpaso = 4;
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA tmp_lotesaeliminar
			let vssql = 'dbaccess intercard ' || trim(cRuta_repositorio) ||  'load_archivo.sql > '|| trim(cRuta_repositorio)|| 'load_archivo.out 2>&1';
			system vssql;
	
	---va a tomar las variables y el lote de la tabla temporal
	set isolation to dirty read;
	LET vpaso = 5;
	FOREACH cursor1	WITH HOLD FOR
	SELECT	cantidadtarjetassol, clave_tipotarjeta, clave_sucursal,numerolote 
	INTO	vNumTrajetas, vclave_tipotarjeta, vclave_sucursal, vlote
	FROM	intercard:lote 
	WHERE	numerolote in (select lote from tmp_lotesaeliminar)
	
		LET vpaso = 6;
	--- Se valida que el lote tecleado tenga la información necesaria para su cancelación.
		IF ( vNumTrajetas < 1 OR (vclave_sucursal = '' OR vclave_sucursal IS NULL) ) THEN	
			LET cCodret = '00001';
			LET cVarDataErr = 'EL LOTE DE TARJETAS NO ES VALIDO, FAVOR DE VERIFICAR' ;
			RETURN cCodret,cVarDataErr;
		END IF;
	
		LET vpaso = 7;
	--- se valida el tipo de tarjetas del lote C/D
		set isolation to dirty read;
		SELECT tipo 
		INTO vTipoTar
		FROM intercard:"informix".tipotarjeta 
		WHERE clave_tipotarjeta = vclave_tipotarjeta;
	
	--toma variables para enviar de parametros al sp
			LET vpaso = 8;
			FOREACH cursor2	WITH HOLD FOR
			SELECT tc.numcuenta, tar.numtarjeta, tar.codproductotarjeta, tar.numcliente
			INTO vnumcta, vnumtarjeta, vcodproductotarjeta, vnumcte
			FROM intercard:"informix".tarjeta  as tar, intercard:"informix".tarjetacuenta as tc
			WHERE tar.numtarjeta = tc.numtarjeta
			AND tar.numerolote = vLote AND tar.codstatustarjeta in('ACT', 'INA', 'BLT', 'BLO')
			
		--identifica las bases de datos de credito/debito y realiza la cancelacion
			LET vpaso = 9;
			IF (vTipoTar='D') THEN --Tarjetas de DEBITO
				LET vpaso = 10;
				EXECUTE PROCEDURE bdicheq:"informix".cancelatarjeta ('001', vnumcta, vnumtarjeta, vnumcte) INTO cCodret, vmonto_aut;
					
					LET vpaso = 11;
					UPDATE intercard:"informix".tarjeta 
						SET  codstatustarjeta = 'CAN', 
							 sefabricaplastico = 'V', 
							 seimprimenip = 'V', 
							 usuarioultmodif = 'informix', 
							 fechaultmodif = current
					WHERE numtarjeta = vnumtarjeta;
				
				LET vpaso = 12;
				INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta, fecha, resultado, descripcion, usuario)
				VALUES(vnumtarjeta,vcodproductotarjeta, current, '8', 'CANCELACION MASIVA DE TARJETAS DEL LOTE '||vLote|| ' POR PREVENCION DE FRAUDES','INFORMIX');
				LET vpaso = 13;
			ELIF (vTipoTar='C') THEN ----Tarjetas de CREDITO
				LET vpaso = 14;
				EXECUTE PROCEDURE bdicred:"informix".cancelatarjeta ('001', vnumcta, vnumtarjeta, vnumcte) INTO cCodret,vmonto_aut,cFolio_canc;
					LET vpaso = 15;
					UPDATE intercard:"informix".tarjeta 
						SET  codstatustarjeta = 'CAN', 
							 sefabricaplastico = 'V', 
							 seimprimenip = 'V', 
							 usuarioultmodif = 'informix', 
							 fechaultmodif = current
					WHERE numtarjeta = vnumtarjeta;
				
				LET vpaso = 16;
				INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta, fecha, resultado, descripcion, usuario)
				VALUES(vnumtarjeta,vcodproductotarjeta, current, '8', 'CANCELACION MASIVA DE TARJETAS DEL LOTE '||vLote|| ' POR PREVENCION DE FRAUDES','INFORMIX');
				
			ELSE
				LET vpaso = 17;
				LET cCodret = '00002';
				LET cVarDataErr = 'EL TIPO DE TARJETA ES INCORRECTO: '|| vTipoTar ;
				DROP TABLE tmp_lotesaeliminar;
				RETURN cCodret,cVarDataErr;
				
				
			END IF
			
				END FOREACH
	
		END FOREACH
	
	LET vpaso = 18;
	LET vNombreArchivo = 'CAN_TJT_LOTE_'||LPAD ( DAY ( today ), 2, '0')||LPAD ( MONTH ( today ), 2, '0')|| YEAR ( today )||'.txt';
	--LET cVarInfo = 'Se cancelaron '|| vNumTrajetas||' Tarjetas involucradas en lote comprometido';
	
	LET vpaso = 19;
	--Se crea archivo con encabezados.
	LET vsSQL = ' echo "Numero de tarjeta|Código producto-tarjeta|Fecha|Resumen|Descripción|Usuario">/resplogifx/'||TRIM(vNombreArchivo)||'';			 
	SYSTEM vsSQL; 

	--Se crea archivo con información de las tarjetas canceladas.                                                                                                                                         
	LET vpaso = 20;
	LET vsSQL = 'echo "UNLOAD TO /resplogifx/encab1.txt SELECT * FROM intercard:bitacoracancelaciontarjetas where resultado = 8 and usuario = ''INFORMIX'' and fecha >='''||vFechaParam1||''' " >/resplogifx/load_archivo.sql';             
	SYSTEM vsSQL;
	LET vpaso = 21;
    LET vsSQL = '';
	LET vsSQL = 'dbaccess intercard /resplogifx/load_archivo.sql';
	SYSTEM vsSQL;

	LET vpaso = 22;
	LET vsSQL = '';
	LET vsSQL= 'rm -f /resplogifx/load_archivo.sql';
	SYSTEM vsSQL;
	
	LET vpaso = 23;
	LET vsSQL = '';
	LET vsSQL= "sed 's/|$//g' /resplogifx/encab1.txt >>/resplogifx/"||TRIM(vNombreArchivo);
	SYSTEM vsSQL;

	LET vpaso = 24;	
    LET vsSQL = '';
	LET vsSQL= 'rm /resplogifx/encab1.txt';
	SYSTEM vsSQL;
	
	LET vpaso = 25;
	DROP TABLE tmp_lotesaeliminar;
	RETURN cCodret,cVarDataErr;
END
END PROCEDURE;