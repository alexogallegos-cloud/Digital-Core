CREATE PROCEDURE "informix".sp_rep_transac_1eruso_tdc(pEmpresa CHAR(3))

RETURNING
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

-- Sep 2012.- MAHR Reporte de transacciÃ³n de 1er uso de TDC. Reporte con la informacion de la primer compra o disposicion en efectivo del cliente.
-- Nov 2012.- MAHR Se consultarÃ¡ la tabla mov_dia, para registros cuya operaciÃ³n, es del dÃ­a.

DEFINE vproceso         CHAR(4);
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaIni        DATE;
DEFINE dFechaFin        DATE;
DEFINE dFechaMov        DATE;
DEFINE cdelimitador     CHAR(1);
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(6204);
DEFINE cSQL2            CHAR(500);
DEFINE cSQL3            CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cNumCredito      CHAR(20);
DEFINE cNumTarjeta      CHAR(20);
DEFINE cgiro            CHAR(4);
DEFINE crfc             CHAR(13);
DEFINE cnomb_estab      CHAR(40);
DEFINE cfoliosuc        CHAR(16);
DEFINE cSecuencExt      CHAR(16);
DEFINE sPaso			SMALLINT;
DEFINE dSumMontoCompras DECIMAL(18,2);
DEFINE iNumTransCompras INTEGER;
DEFINE dSumMontoDispos  DECIMAL(18,2);
DEFINE iNumTransDispos	 INTEGER;

--SET DEBUG FILE TO "sp_rep_transac_1eruso_tdc.out";
--TRACE ON;

LET vproceso        = '0064';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0);
LET dFechaIni       = DATE(0);
LET dFechaFin       = DATE(0);
LET dFechaMov       = DATE(0);
LET cdelimitador    = '';
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';
LET cNomArchEjecSql = '';
LET cNumCredito     = '';
LET cNumTarjeta     = '';
LET cgiro           = '';
LET crfc            = '';
LET cnomb_estab     = '';
LET cfoliosuc       = '';
LET cSecuencExt     = '';
LET sPaso           = 0;
lET 	dSumMontoCompras = 0;
leT		iNumTransCompras = 0;
let		dSumMontoDispos = 0;
let		iNumTransDispos = 0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tmp_rep_trans1eruso';
        IF NVL(sPaso,0) > 0 THEN
            DROP TABLE tmp_rep_trans1eruso;
        END IF;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

    SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tmp_rep_trans1eruso';
    IF NVL(sPaso,0) > 0 THEN
        DROP TABLE tmp_rep_trans1eruso;
    END IF;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005';
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013';
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    -- Rango de fechas de 9 del mes anterior al 8 de este mes. (amanece el dia 10 el archivo) Para no repetir en el reporte los datos del 9 en el sig.
    --LET dFechaIni = mdy(month(dFechaHoy - 1 units month), day(dFechaHoy), year(dFechaHoy));
    LET dFechaIni = dFechaHoy - 1 units month;
    LET dFechaFin = dFechaHoy - 1 units day;
	
    SELECT trim(valor_alfabetico) INTO cRutaArch      -- Ruta destino del archivo
        FROM bdicred:sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 28;

	IF NVL (cRutaArch,'') = '' THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor_alfabetico) INTO cNomArchivo    -- Nombre de Archivo
        FROM bdicred:sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 29;
	
	IF NVL (cNomArchivo,'') = '' THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania  	--Obtiene caracter delimitador
        WHERE empresa = pempresa AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
	
	IF NVL (cdelimitador,'') = '' THEN
        LET cCodRet= '104004';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    CREATE TABLE "informix".tmp_rep_trans1eruso(
        num_credito CHAR(20),       fecha_activacion DATE,      fecha_1er_transac DATE,     giro CHAR(80),
        RFC CHAR(13),                nombre_establec CHAR(40),   monto DECIMAL(18,2),
		num_compras  int, sum_monto_compras decimal(18,2), num_disposiciones int, sum_monto_diposicion decimal(18,2));
        create index "informix".inx_tmp_rep_trans1eruso on tmp_rep_trans1eruso(num_credito);


    INSERT INTO "informix".tmp_rep_trans1eruso
        SELECT  num_credito, fecha_alta,
            (case when (nvl(f_primer_disp,date(1)) < nvl(f_primer_compra,date(1)) and nvl(f_primer_disp,date(1)) = date(1)) then nvl(f_primer_compra,date(1))
		when (f_primer_disp < f_primer_compra and nvl(f_primer_disp,date(1)) > date(1)) then nvl(f_primer_disp,date(1))
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) = date(1)) then nvl(f_primer_disp,date(1))
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) > date(1)) then nvl(f_primer_compra,date(1))
		else nvl(f_primer_compra,date(1)) end) Fecha_1er_transac,
	'DisposiciÃ³n en efectivo' Giro,
	(case when (nvl(f_primer_disp,date(1)) < nvl(f_primer_compra,date(1)) and  nvl(f_primer_disp,date(1)) = date(1)) then 'RFC' when (f_primer_disp < f_primer_compra and nvl(f_primer_disp,date(1)) > date(1)) then ''
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) = date(1)) then '' when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) > date(1)) then 'RFC'
		else 'RFC' end) rfc,
	'DisposiciÃ³n en efectivo' Nombre_estab,
	(case when (nvl(f_primer_disp,date(1)) < nvl(f_primer_compra,date(1)) and nvl(f_primer_disp,date(1)) = date(1)) then monto_primer_compra when (f_primer_disp < f_primer_compra and nvl(f_primer_disp,date(1)) > date(1) ) then monto_primer_disp
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) = date(1)) then monto_primer_disp when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) > date(1) ) then monto_primer_compra
		else monto_primer_compra end) monto,0,0,0,0
	FROM bdicred:sd_indicador_cred
	WHERE
		(case when (nvl(f_primer_disp,date(1)) < nvl(f_primer_compra,date(1)) and nvl(f_primer_disp,date(1)) = date(1)) then nvl(f_primer_compra,date(1))
		when (f_primer_disp < f_primer_compra and nvl(f_primer_disp,date(1)) > date(1)) then nvl(f_primer_disp,date(1))
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) = date(1)) then nvl(f_primer_disp,date(1))
		when (nvl(f_primer_compra,date(1)) < nvl(f_primer_disp,date(1)) and nvl(f_primer_compra,date(1)) > date(1) ) then nvl(f_primer_compra,date(1))
		else nvl(f_primer_compra,date(1)) end) BETWEEN dFechaIni AND dFechaFin;

	
	
    FOREACH
	
	
		SELECT num_credito, fecha_1er_transac, rfc INTO cNumCredito, dFechaMov, cRfc  FROM tmp_rep_trans1eruso --WHERE rfc = 'RFC'
	
		--obtiene numero de Compras y la suma del monto 
		SELECT NVL(sum(monto), 0) as monto, NVL(count(num_credito), 0) as cantidad 
		INTO dSumMontoCompras, iNumTransCompras
		FROM bdicred:sd_movhis 
		WHERE empresa = '001' 
		AND num_credito = cNumCredito 
		AND fecha_mov BETWEEN dFechaIni::date 
		AND  dFechaFin::date
		AND codigo_fun = '002' 
		AND codigo_ref in (37,57,937,938)
		AND reversado = 'N';
		--------------
		--Se obtiene el numero de disposiciones y la suma del monto 
		SELECT nvl(sum(monto), 0) as monto, NVL(count(num_credito), 0) as cantidad 
		INTO dSumMontoDispos, iNumTransDispos
		FROM bdicred:sd_movhis 
		where empresa = '001' 
		AND num_credito = cNumCredito 
		AND fecha_mov BETWEEN dFechaIni::date
		AND dFechaFin::date
		AND codigo_fun = '002' 
		AND codigo_ref in (50,30,40,41,42,34,35,36,60,61,62,63,64,65)
		AND reversado = 'N';
	
		IF(cRfc = 'RFC') THEN
			-- Obtiene el RFC y Nombre del establecimiento en donde se realizo la compra y No de tarjeta.
			SELECT first 1 nvl(rfc_comer, ''), nvl(trim(SUBSTR(referencia, length(folio_suc)+1, length(referencia)-length(folio_suc) )),''), folio_suc, nro_tarjeta
				INTO crfc, cnomb_estab, cfoliosuc, cNumTarjeta
				FROM bdicred:sd_movhis WHERE empresa = pEmpresa AND fecha_mov = dFechaMov AND num_credito = cNumCredito;

			-- Obtiene la informacion del comercio, si la transacciÃ³n no esta registrada en la tabla historica (mov_his)
			IF ((NVL(crfc, '') = '' AND NVL(cnomb_estab,'') = '') OR (trim(crfc) = '' AND trim(cnomb_estab) = '')) THEN
				SELECT first 1 nvl(rfc_comer, ''), nvl(trim(SUBSTR(referencia, length(folio_suc)+1, length(referencia)-length(folio_suc) )),''), folio_suc, nro_tarjeta
					INTO crfc, cnomb_estab, cfoliosuc, cNumTarjeta
					FROM bdicred:sd_movdia WHERE empresa = pEmpresa AND fecha_mov = dFechaMov AND num_credito = cNumCredito;
			END IF;

			-- Obtiene la descripcion del giro del negocio en donde se realizo la primera compra.
			LET cSecuencExt =  TRIM(SUBSTR(trim(cfoliosuc), 2, length(trim(cfoliosuc))-1));
				-- obtiene la descripcion del giro del negocio
			/*SELECT nvl(a.descgironeg, '') INTO cgiro FROM intercard:gironegocio a, intercard:movimientohistorico mov
				WHERE a.codgironeg = mov.codgironeg and mov.numtarjeta = cNumTarjeta and mov.secuenciaextendida = trim(cSecuencExt);*/
				-- Obtiene el codigo del giro del negocio.
			SELECT nvl(codgironeg, '') INTO cgiro FROM intercard:movimientohistorico WHERE numtarjeta = cNumTarjeta
					and secuenciaextendida = trim(cSecuencExt);
			UPDATE tmp_rep_trans1eruso 
			SET giro = cgiro, RFC = crfc, nombre_establec = cnomb_estab,
				sum_monto_compras = dSumMontoCompras, num_compras = iNumTransCompras,
				sum_monto_diposicion = dSumMontoDispos, num_disposiciones = iNumTransDispos  
			WHERE num_credito = cNumCredito;
		ELSE
			UPDATE tmp_rep_trans1eruso 
			SET sum_monto_compras = dSumMontoCompras, num_compras = iNumTransCompras,
				sum_monto_diposicion = dSumMontoDispos, num_disposiciones = iNumTransDispos  
			WHERE num_credito = cNumCredito;
		END IF;



    END FOREACH;

    -- Elimina registros que nose haya obtenido informacion del comercio.
   -- DELETE FROM "informix".tmp_rep_trans1eruso WHERE NVL(giro,'') = '' AND NVL(RFC,'') = '' AND NVL(nombre_establec,'') = '';

    IF (SELECT count(*) FROM tmp_rep_trans1eruso ) = 0 THEN
        LET cMensajeRet = 'SIN INFORMACION';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
    END IF;

    -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
    LET cNomArch1 =  trim(cNomArchivo)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
    LET cNomArch  =  trim(cNomArchivo)||substr(year(dFechaHoy),3)||to_char( dFechaHoy,'%m%d')||'.txt';
    LET cNomArchEjecSql = 'Ejecuta_rep_tran_1er_uso_tdc.sql';

    LET cSQL='';
    LET cSQL = 'echo "Numero Credito'||';'||'Fecha activacion tarjeta'||';'||'Fecha primera transaccion'||';'||'Giro establecimiento'||';'||'RFC'||';'
                        ||'Nombre establecimiento'||';'|| 'Monto'||';'||'Txn compras acum mes'||';'||'Monto compras acum mes'||';'||'Txn disp acum mes'||';'||'Monto disp acum mes'||';'|| ' " >' ||TRIM(cRutaArch)|| TRIM(cNomArch);

    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
    LET cSQL2 = " SELECT * FROM tmp_rep_trans1eruso ";

    LET cSQL3 = '">'||TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql) || ' ' || TRIM(cRutaArch) || TRIM(cNomArch1);
    SYSTEM cSQL;

    DROP TABLE tmp_rep_trans1eruso;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;