CREATE PROCEDURE "informix".sp_cancelatarjetas_rob_frau_ext (eTipo_cancela CHAR(3), eLote INTEGER)
returning
char (5),
char(150);

--############################################################################################################
--### Creado por: JUAN FCO. PONCE DAMIAN														  			##
--##  Fecha: 06/06/2013																			 			##
--##  Descripcion: Se actualiza el estatus de la tarjetas por lote, dependiendo del tipo de cancelacion     ##
--##  requerida: (ROB (Robo de ruta) / FRD (Prevención de Fraude) / EXT (Extravió en Sucursal))	  			##
--############################################################################################################
--### Modificado por: JUAN FCO. PONCE DAMIAN														  		##
--##  Fecha: 10/06/2013																			 			##
--##  Descripcion: Se integra  insert a la tabla de bitacorra de cancelacion de tarjetas y se genera        ##
--##  un archivo .txt con los cambios realizados para entregar al usuario.   								##
--############################################################################################################
--### Modificado por: JUAN FCO. PONCE DAMIAN														  		##
--##  Fecha: 18/06/2013																			 			##
--##  Descripcion: Se integra validación para sólo cancelar tarjetas != CAN para los casos de ROB o EXT.    ##
--############################################################################################################



DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);

DEFINE vclave_tipotarjeta	CHAR(2);
DEFINE vclave_sucursal		CHAR(5);
DEFINE vTipoTar				CHAR(1);
DEFINE vNumTrajetas			INTEGER;

DEFINE vTipoResult		CHAR(1);
DEFINE vFechaParam1 	DATETIME YEAR TO FRACTION (5);
DEFINE vNombreArchivo	VARCHAR (30) ;
DEFINE vsSQL 			VARCHAR (200) ;

DEFINE cVarInfo      	CHAR(100);




	ON EXCEPTION SET iSqlErr
		
        LET cCodret = iSqlErr;
		LET cVarDataErr = 'ERROR NO CONTROLADO ';
        RETURN cCodret, cVarDataErr;
  
	END EXCEPTION;
	
	LET vTipoResult = '';
	LET vFechaParam1 = CURRENT ;
	LET vNumTrajetas = 0 ;

--Set debug file to "/informix/pruebasconciliacion/sp_cancelatarjetas_rob_frau_ext.sql";
--trace on;
	
	set isolation to dirty read;
	SELECT cantidadtarjetassol, clave_tipotarjeta, clave_sucursal INTO vNumTrajetas, vclave_tipotarjeta, vclave_sucursal
	FROM intercard:lote WHERE numerolote = eLote;
	
	-- Se valida que el lote tecleado tenga la información necesaria para su cancelación.
	IF ( vNumTrajetas < 1 OR (vclave_sucursal = '' OR vclave_sucursal IS NULL) ) THEN
	
		LET cCodret = '00001';
		LET cVarDataErr = 'EL LOTE DE TARJETAS NO ES VALIDO, FAVOR DE VERIFICAR' ;
		RETURN cCodret,cVarDataErr;
	
	END IF;
	
	set isolation to dirty read;
	SELECT tipo INTO vTipoTar--D
	FROM intercard:"informix".tipotarjeta 
	WHERE clave_tipotarjeta = vclave_tipotarjeta;
	
	-- "Robo en ruta de la mensajería"
	IF (eTipo_cancela='ROB') THEN
		
		LET vTipoResult = '1';
		
		SELECT COUNT(numtarjeta) INTO vNumTrajetas FROM intercard:"informix".tarjeta 
		WHERE numerolote = eLote AND codstatustarjeta != 'CAN';
		
		UPDATE intercard:"informix".tarjeta
		SET   codstatustarjeta = 'CAN' , 
                      codstatusasignada = 'NOA',
		      seimprimenip = 'F',
		      usuarioultmodif = 'informix',
		      fechaultmodif = current
		WHERE numerolote = eLote AND codstatustarjeta != 'CAN';

		
		
		UPDATE intercard:"informix".sucursal_tipotarjeta
		SET solicitadas = (solicitadas - vNumTrajetas)
		WHERE clave_sucursal = vclave_sucursal
		AND clave_tipotarjeta = vclave_tipotarjeta;

		INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta, fecha, resultado, descripcion, usuario)
		SELECT numtarjeta, codproductotarjeta, current, '1', 'Cancelación Masiva del lote '||eLote|| ' por Robo o Siniestro en Ruta','INFORMIX' 
		FROM intercard:"informix".tarjeta WHERE numerolote = eLote and codstatustarjeta = 'CAN' and usuarioultmodif = 'informix' and fechaultmodif >= vFechaParam1 ;
		
		LET vNombreArchivo = 'CAN_TJT_ROB_'||eLote||'_'||LPAD ( DAY ( today ), 2, '0')||LPAD ( MONTH ( today ), 2, '0')|| YEAR ( today )||'.txt';
		LET cVarInfo = 'Se cancelaron '|| vNumTrajetas||' Tarjetas por Robo o Siniestro en ruta';
		
	-- "Detección de posible Fraude"
	ELIF (eTipo_cancela='FRD') THEN		
	
		LET vTipoResult = '2';
		
		IF (vTipoTar='D') THEN --Tarjetas de DEBITO
			UPDATE  bdicheq:"informix".sc_tarjeta
			set status_tar = 'C'
			where  num_tarjeta IN ( select numtarjeta from intercard:tarjeta where numerolote = eLote and 
                                                codstatustarjeta in('ACT','BLO','BLT'))
			and status_tar <> 'C';
		ELIF (vTipoTar='C') THEN ----Tarjetas de CREDITO
			UPDATE  bdicred:"informix".sd_tarjeta
			set status_tar = 'C'
			where  num_tarjeta IN ( select numtarjeta from intercard:tarjeta where numerolote = eLote and 
                                                codstatustarjeta in('ACT','BLO','BLT') )
			and status_tar <> 'C';
		ELSE
			LET cCodret = '00002';
			LET cVarDataErr = 'EL TIPO DE TARJETA ES INCORRECTO: '|| vTipoTar ;
			RETURN cCodret,cVarDataErr;
		END IF;
		
		SELECT COUNT(numtarjeta) INTO vNumTrajetas FROM intercard:"informix".tarjeta 
		WHERE numerolote = eLote
		AND codstatustarjeta in('ACT','BLO','BLT');
		
        UPDATE intercard:"informix".tarjeta
		SET  codstatustarjeta = 'CAN', 
                     sefabricaplastico = 'V', 
                     seimprimenip = 'V', 
                     usuarioultmodif = 'informix', 
                     fechaultmodif = current
		WHERE numerolote = eLote
		AND codstatustarjeta in('ACT','BLO','BLT');
		
		INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta, fecha, resultado, descripcion, usuario)
		SELECT numtarjeta, codproductotarjeta, current, '2', 'Cancelación Masiva del lote '||eLote|| ' por Reporte de Fraude','INFORMIX' 
		FROM intercard:"informix".tarjeta WHERE numerolote = eLote and codstatustarjeta = 'CAN' and usuarioultmodif = 'informix' and fechaultmodif >= vFechaParam1 ;
		
		LET vNombreArchivo = 'CAN_TJT_FRD_'||eLote||'_'||LPAD ( DAY ( today ), 2, '0')||LPAD ( MONTH ( today ), 2, '0')|| YEAR ( today )||'.txt';
		LET cVarInfo = 'Se cancelaron '|| vNumTrajetas||' Tarjetas involucradas en Fraude';
	-- "Extravió en Sucursal"	
	ELIF (eTipo_cancela='EXT') THEN
		
		LET vTipoResult = '3';
		
		SELECT COUNT(numtarjeta) INTO vNumTrajetas FROM intercard:"informix".tarjeta 
		WHERE numerolote = eLote AND codstatustarjeta != 'CAN';
		
		UPDATE intercard:"informix".tarjeta
		SET   codstatustarjeta = 'CAN' ,
		      seimprimenip = 'F',
		      usuarioultmodif = 'informix',
		      fechaultmodif = current
		WHERE numerolote = eLote AND codstatustarjeta != 'CAN';
		
		UPDATE intercard:"informix".sucursal_tipotarjeta
		SET solicitadas = (solicitadas - vNumTrajetas)
		WHERE clave_sucursal = vclave_sucursal
		AND clave_tipotarjeta = vclave_tipotarjeta;
		
		INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta, fecha, resultado, descripcion, usuario)
		SELECT numtarjeta, codproductotarjeta, current, '3', 'Cancelación Masiva del lote '||eLote|| ' por Extravio en Sucursal','INFORMIX' 
		FROM intercard:"informix".tarjeta WHERE numerolote = eLote and codstatustarjeta = 'CAN' and usuarioultmodif = 'informix' and fechaultmodif >= vFechaParam1 ;
		
		LET vNombreArchivo = 'CAN_TJT_EXT_'||eLote||'_'||LPAD ( DAY ( today ), 2, '0')||LPAD ( MONTH ( today ), 2, '0')|| YEAR ( today )||'.txt';
		LET cVarInfo = 'Se cancelaron '|| vNumTrajetas||' Tarjetas por extravio en sucursal';
		
	ELSE
		LET cCodret = '00003';
		LET cVarDataErr = 'ESE TIPO DE CANCELACION NO EXISTE' ;
		RETURN cCodret,cVarDataErr;
	END IF;
	--Se crea archivo con el encabezados.
	LET vsSQL = 'echo "Numero de tarjeta|Código producto-tarjeta|Fecha|Resumen|Descripción|Usuario" > '|| TRIM(vNombreArchivo);			 
	SYSTEM vsSQL; 

	--Se crea archivo con información de las tarjetas canceladas.
	LET vsSQL = 'echo "UNLOAD TO encab1.txt SELECT * FROM intercard:bitacoracancelaciontarjetas where resultado = ' || vTipoResult ||  ' and usuario = ''INFORMIX'' and fecha >='''||vFechaParam1||''' " > load_archivo.sql' ;             
	SYSTEM vsSQL;

	LET vsSQL = 'dbaccess intercard load_archivo.sql';
	SYSTEM vsSQL;
	
	LET vsSQL= "sed 's/|$//g' encab1.txt >> "||TRIM(vNombreArchivo)|| " ; " ;
	SYSTEM vsSQL;

	LET vsSQL= "rm -f encab1.txt " ;
	SYSTEM vsSQL;
	
	LET cCodret = '00000';
	LET cVarDataErr = 'PROCESO EXITOSO: '||cVarInfo ;
		
RETURN cCodret,cVarDataErr;
END PROCEDURE;