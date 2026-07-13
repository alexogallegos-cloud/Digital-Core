CREATE PROCEDURE "informix".sp_generaarchivocobranzacoppel(cId_convenio CHAR(5))

--DEFINICION DE VARIABLES

    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE iSucursal            INTEGER;
    DEFINE iImporte             INTEGER;
    DEFINE iCantidad            INTEGER;
    DEFINE i                    INTEGER;
    DEFINE cClave               CHAR(1);
    DEFINE cCategoria           CHAR(2);
    DEFINE cMes                 CHAR(2);
    DEFINE cDia                 CHAR(2);
    DEFINE cConvenio            CHAR(3);
    DEFINE cAnio                CHAR(4);
    DEFINE cExtUnl              CHAR(4);
    DEFINE cExtTxt              CHAR(4);
    DEFINE cNomArchCPL          CHAR(15);
    DEFINE cNomArchCPLF         CHAR(15);
    DEFINE cNomArchTot          CHAR(15);
    DEFINE cNomArchTotF         CHAR(15);
    DEFINE cRutaArchCoppelTmp   CHAR(20);
    DEFINE cRutaArchTotalTmp    CHAR(25);
    DEFINE cRuta                CHAR(40);
    DEFINE cRutaFC              CHAR(50);
    DEFINE cRutaFT              CHAR(50);
    DEFINE cSql                 CHAR(100);
    DEFINE cStmt                CHAR(100);
    DEFINE cSql_Stmt            CHAR(1250);
    DEFINE dFechaIni            DATE;
    DEFINE dFecha_Hoy           DATE;
    DEFINE bFlagSeguro          BOOLEAN;
    DEFINE bFlagMovto           BOOLEAN;
	DEFINE iFlagCen             INTEGER;
	DEFINE iFlagSuc             INTEGER;
	DEFINE cFolio               CHAR(16);
	DEFINE iCuantos             INTEGER;
	DEFINE dFecha_Pago           DATE;
	DEFINE cReferencia1          CHAR(20);

 --   SET DEBUG FILE TO "/informix/EPG/Coppel.out";
 --   TRACE ON;

    --INICIALIZACION DE VARIABLES
    LET cCodRet = '00000';
    LET cStmt = '' ;
    LET cNomArchCPL = '';
    LET cNomArchCPLF = '';
    LET cRuta = '';
    LET cSql = '';
    LET bFlagSeguro = 'f';
    LET bFlagMovto = 'f';
    LET iImporte = 0;
    LET iCantidad = 0;
    LET cExtUnl = ".unl";
    LET cExtTxt = ".txt";
    LET cCategoria = SUBSTRING(cId_convenio FROM 1 FOR 2);
    LET cConvenio = SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET iFlagCen      = 0;
	LET iFlagSuc      = 0;
	LET cFolio        ='';
	LET iCuantos      = 0;
	LET dFecha_Pago    = DATE(1);
	LET cReferencia1  		  = '';

    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;

                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;

                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GeneraArchivoCobranzaCoppel");
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        INSERT INTO bdisac:tmpSac_MovimientosDetalleHistorial (clave, tipomovimiento, sucursal, ciudad, cliente, clienteetp, caja, recibo, factura, importe, saldoinicial, saldofinal,
                           saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,
                           ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro, flagmontoseguro,
                           statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo,
                           areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo,
                           ruta, folio, cuenta, iva, telefono, compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal,
                           rpu, flagmovtosupervisor, interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto,
                           registropatronal, formaaportacionafore, ipcarteracliente, fechamovto, candidato, statusafore)
        SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura,importe * 100, saldoinicial, saldofinal, saldocuenta, vencidoinicial,
        minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera,
        anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros,
        cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste,
        ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono,
        compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor,
        interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore,
        ipcarteracliente, fechamovto, candidato, statusafore
        FROM bdisac:sac_movimientosdetallehistorial a, bdisac:sac_movimientoshistorial b
        WHERE a.fecha::date > dFechaIni
        AND a.fecha::date <= dFecha_Hoy
        AND a.cliente = b.referencia1
        AND a.recibo = b.referencia2
        AND b.numcategoria = cCategoria
        AND b.numconvenio = cConvenio
        AND NOT (status_cancelado = 'S' AND status_coppel = 0);

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0');

        SELECT TRIM(valor)
        INTO cRuta
        FROM bdisac:sac_param
        WHERE cod_param =  3;

        LET cNomArchCPL = "mvb"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchCPLF = "mvb"|| cDia||cMes||cAnio ||cExtTxt;
        LET cNomArchTot = "cfv"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchTotF = "cfv"|| cDia||cMes||cAnio ||cExtTxt;
        LET cRutaFC = TRIM(cRuta) || cNomArchCPL;
        LET cRutaFT = TRIM(cRuta) || cNomArchTot;

        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) ||''' SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura, ' ||
                        'importe, saldoinicial, saldofinal, saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, '||
                        'tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, '||
                        'flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, '||
                        'bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, '||
                        'comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono, compania, contrato, credito, '||
                        'fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor, interes, importeventa, '||
                        'folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore, '||
                        'ipcarteracliente, fechamovto, candidato, statusafore FROM bdisac:tmpSac_MovimientosDetalleHistorial ORDER BY sucursal, caja, recibo;"'||
                        '> /tmp/tmp.sql';
        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' " || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) || " > "|| TRIM(cRuta)||cNomArchCPLF;
        SYSTEM cSql;

        FOREACH
            SELECT DISTINCT(sucursal)
            INTO iSucursal
            FROM tmpSac_MovimientosDetalleHistorial
            ORDER BY sucursal

            FOR i = 1 TO 23
                    IF i = 1 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 2 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'I';
                    ELIF i = 3 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 4 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 18 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 19 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 21 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    END IF;

                    IF bFlagMovto = 't' THEN
                        IF bFlagSeguro= 't' THEN
                            IF i = 3 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro <> 'C'
                                                    AND sucursal = iSucursal));
                            ELIF i = 4 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        ELSE
                            IF i = 1 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '5', '6', '7', 'I', 'J', 'K', 'L', 'R', 'S')
                                                    AND sucursal = iSucursal));
                            ELIF i = 2 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '2', '3', '4')
                                                    AND sucursal = iSucursal));
                            ELIF i = 18 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'B'
                                                    AND sucursal = iSucursal));
                            ELIF i = 19 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'D'
                                                    AND sucursal = iSucursal));
                            ELIF i = 21 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        END IF;
                    END IF ;
                    INSERT INTO bdisac:sac_totalmovimientosdetallehistorial (tipo, importe, cantidad, sucursal, fecha, fecha_movto)
                    VALUES (i, iImporte, iCantidad, iSucursal, dFecha_hoy, CURRENT);
								
                    LET bFlagMovto = 'f';
                    LET bFlagSeguro= 'f';
                    LET cClave = '';
                    LET iImporte = 0;
                    LET iCantidad = 0;
            END FOR;
		END FOREACH;
		
		FOREACH
			SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
			FROM bdisac:sac_movimientoshistorial
			WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				
			IF iFlagCen = 0 or iFlagSuc =0 THEN
				SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
				IF iCuantos = 0 THEN
					SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				IF iCuantos > 0 THEN            
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
				END IF;
			END IF;
		END FOREACH;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFecha_Pago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFecha_Pago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;

        LET cSql_Stmt = '';
        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || ''' SELECT tipo, importe, cantidad, sucursal, fecha, fecha_movto ' ||
                        'FROM bdisac:sac_totalmovimientosdetallehistorial WHERE fecha = (SELECT fecha_hoy FROM bdisac:sac_fechas) " > /tmp/tmp.sql';

        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' "|| SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || " > " || TRIM(cRuta) || cNomArchTotF;
        SYSTEM cSql;

        DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;
        LET cStmt = 'rm -f /tmp/tmp.sql';
        SYSTEM cStmt;

        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Genera el archivo de cobranza Coppel de acuerdo a Layout proporcionado por la misma empresa',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Agosto de 2008',
'VERSION: 200808',
'BD    : bdisac',
'MODIFICACION: Se modifica el criterio de extraccin de la informacion de la tabla temporal para contemplar el numero de convenio coppel',
'FECHA : 01/06/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para que seleccione todos los movimientos sin importar si estan cancelados o no ',
'FECHA MODIFICACION: 19/06/2009',
'AUTOR MODIFICACION: Dulce Ramírez',
'MODIFICACION: Se modifica al contabilizar el número de movimientos se contemplen los CANCELADOS, pero la sumatoria de importes solo se hará de los ACTIVOS ',
'FECHA MODIFICACION: 17/07/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para contemplar en el archivo de cobranza los movimientos para tiempo aire y deuda bancoppel',
'FECHA MODIFICACION: 30/07/2009',
'AUTOR : Raul Rene Ruiz Rodriguez',
'MODIFICACION: Se modifica para contabilizar correctamente los movimientos de seguros ya que los movimientos de seguros afirme se estaban contemplando tambien dentro del conteo de los seguros club',
'FECHA MODIFICACION: 16/10/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para descartar los movimientos que no sean confirmados y esten cancelados(reversos automaticos)',
'FECHA MODIFICACION: 21/10/2009',
'AUTOR : Julio Cesar Polanco Inzunza',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzamastv(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;

    DEFINE cCveRegistro             CHAR;
    DEFINE cMes, cDia               CHAR(2);
	DEFINE cMesPag, cDiaPag         CHAR(2);
	DEFINE cAnioPag                 CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cAnio                    CHAR(4);

    ------------------------------------------------------------------------------------
    --	2010-12-28: A petición de MVS, se atualiza el Nombreempresa de MVS a BANCOPPEL -
    --	DEFINE cCveEmpresa              CHAR(3);
    DEFINE cCveEmpresa              CHAR(9);
    ------------------------------------------------------------------------------------
    
    DEFINE cReferencia1             CHAR(20);
    DEFINE cSucursal                CHAR(5);
    DEFINE cRutaArchmastv           CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Pago               DATE;
    
    DEFINE iImporte_Pago            INTEGER;
    DEFINE iTotalreg                INTEGER;
    DEFINE iImporteTotal            INTEGER;
    DEFINE iIdTransacc              INTEGER;
    DEFINE mImporteTotal            MONEY(16,2);
	
	DEFINE cFormaPago               CHAR(2);
    DEFINE cHorMinSec               DATETIME  HOUR TO FRACTION;
	DEFINE cConstante               INTEGER;
	
    DEFINE cFolio                   CHAR(16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
    DEFINE iCuantos                 INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
	LET cCveEmpresa = '';
    LET cCveRegistro = 'H';
    LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1 = '';
    LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
    LET iImporte_Pago = 0;
    LET iTotalReg = 0;
    LET iImporteTotal = 0;
    LET iIdTransacc = 0;
    LET mImporteTotal = 0;
	LET cConstante = '0';
    LET cFolio = '';                 
    LET cFlagCen = 0;                 
    LET cFlagSuc = 0;      
    LET iCuantos = 0;    	
	 
  -- SET DEBUG FILE TO "/ids10_uc9/tmp/mvs/sp_generaarchivocobranzamastv.out";
  -- TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
		SELECT {+INDEX (bdisac:sac_convenios 103_4)} TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchmastv
		FROM bdisac:sac_convenios
		WHERE TRIM(numcategoria)|| TRIM(numconvenio) = cId_Convenio;
 
        SELECT {+INDEX (bdisac:sac_param idxsc_par)} TRIM(valor)
		INTO cCveEmpresa
		FROM bdisac:sac_param 
		WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '1' 
		AND SUBSTRING (cod_param FROM 2 FOR 5)  = cId_Convenio;
		
		LET cRutaArchmastv = REPLACE(cRutaArchmastv,'YYYY',cAnio);
		LET cRutaArchmastv = REPLACE(cRutaArchmastv,'MM',cMEs);
		LET cRutaArchmastv = REPLACE(cRutaArchmastv,'DD',cDia);
		
        --Encabezado

        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || cCveEmpresa ||'" > ' || cRutaArchmastv;
        SYSTEM cStmt;

        LET cCveRegistro = '0';
        LET cStmt = '';

        --Detalle
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1, importe_pago * 100, LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
			  NVL(LPAD(id_sucursal,5,'0'),'00000'), forma_pago , fecha_insert::datetime HOUR TO SECOND,
              flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO   cReferencia1,  iImporte_Pago, cDiaPag , cMesPag , cAnioPag ,  cSucursal, cFormaPago, cHorMinSec, cFlagCen, cFlagSuc, cFolio, dFecha_Pago
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
            OR flag_confirmacion_sucursal = 1)
 
            IF TRIM(cFormaPago) ='1' THEN
                LET cFormaPago = 'EF';
			ELIF TRIM(cFormaPago) ='2' THEN	
			    LET cFormaPago = 'CA';
            ELIF TRIM(cFormaPago) ='3' THEN	
			    LET cFormaPago = 'MX';
            END IF;

            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
              END IF;
            END IF;
			
            LET iTotalReg = iTotalReg + 1;
            LET mImporteTotal = mImporteTotal + iImporte_Pago / 100;

            LET cStmt = 'echo "' || cCveRegistro || cConstante || LPAD(trim(cReferencia1), 13, ' ') || LPAD(iImporte_Pago, 6, '0') || cDiaPag  || cMesPag  || cAnioPag  ||  
						 cSucursal || SUBSTRING(cHorMinSec  FROM 1 FOR 2) || SUBSTRING(cHorMinSec  FROM 4 FOR 2) || SUBSTRING(cHorMinSec  FROM 7 FOR 2) || cFormaPago  || '" >> ' || cRutaArchmastv;
            SYSTEM cStmt;
        END FOREACH;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFecha_Pago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFecha_Pago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;

        LET iImporteTotal = mImporteTotal * 100;

        -- Sumario
        LET cCveRegistro = 'T';
        LET cStmt = '';

        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || LPAD(iTotalReg, 6, '0') || LPAD(iImporteTotal, 11, '0') || '" >> ' || cRutaArchmastv;
        SYSTEM cStmt;

        UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera el archivo de cobranza mastv de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 06 de Septiembre de 2010',
'VERSION: 20100906',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'BD    : bdisac', 
'FECHA: 02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzasolfi (pConvenio CHAR(5))

   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR(2);
	DEFINE cMes                     CHAR(2);
	DEFINE cAnio                    CHAR(4);
	DEFINE cDiaPago                 CHAR(2);
	DEFINE cMesPago                 CHAR(2);
    DEFINE cAnioPago                CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cReferencia1             CHAR(20);
    DEFINE cRutaArchSolfi           CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cFolio                   CHAR(16);
	DEFINE cTpoOperacion            CHAR(2);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Ant               DATE;
    DEFINE iImporte_Comision        DECIMAL(11,0);
    DEFINE iSumaImporte_Comision    DECIMAL(11,0);
	DEFINE iImporte_IVA_Comision    DECIMAL(11,0);
	DEFINE iSumaImporte_IVA_Comision DECIMAL(11,0);
	DEFINE iImporte_Pago          	DECIMAL(11,0);
	DEFINE iTotal_Pago              DECIMAL(11,0);
    DEFINE iFlagCen                 INTEGER;
    DEFINE iFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
	DEFINE iNumPagos                INTEGER;
	DEFINE cCuenta_Prestadora       CHAR(20);
	DEFINE cNomes					CHAR(15);	
	DEFINE cHora					CHAR(2);	
	DEFINE cMinuto	  				CHAR(2);
	DEFINE cSegundo					CHAR(2);
	DEFINE dFechaPago				DATE;	
--INICIALIZACION DE VARIABLES--
    LET cCodRet       		 	  	= "00000";
    LET iSqlErr       		 		= 0;
    LET cCategoria    		  		= SUBSTRING(pConvenio FROM 1 FOR 2);
    LET cConvenio     		  		= SUBSTRING(pConvenio FROM 3 FOR 3);
    LET cReferencia1  		  		= '';
    LET cDia          		  		= '';
    LET cMes          		  		= '';
    LET cAnio         		  		= '';
	LET cDiaPago       		  		= '';
	LET cMesPago       		  		= '';
    LET cAnioPago      		  		= '';
    LET iImporte_Pago 		  		= 0;
	LET iImporte_Comision 	  		= 0;
	LET iSumaImporte_Comision 		= 0;
	LET iImporte_IVA_Comision 		= 0;
	LET iSumaImporte_IVA_Comision 	= 0;
	LET iTotal_Pago  		  		= 0;
    LET cFolio        		  		= '';
    LET iFlagCen      		  		= 0;
    LET iFlagSuc      		  		= 0;
	LET cRutaArchSolfi  			= '';
	LET	iCuantos      		  		= 0;
	LET cStmt         		  		= '';
	LET dFechaIni     		  		= DATE(1);
	LET dFecha_Hoy    		  		= DATE(1);
	LET dFecha_Ant    		  		= DATE(1);
	LET cTpoOperacion         		= 'D ';
	LET iNumPagos             		= 0;
	LET cCuenta_Prestadora    		= '';
	LET cNomes						= '';
	LET cHora						= '';
	LET cMinuto						= '';
	LET cSegundo					= '';
	LET dFechaPago                  = DATE(1);
	
	--SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_pruebaernesto.out';
	--TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				UPDATE "informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

        SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
				
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM "informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
		--ASIGNA VALOR A LAS VARIABLES
        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');
			
		--PONE NOMBRE DEL MES
		IF cMes='12' THEN
			LET cNomes =' DE DICIEMBRE DE ';
		END IF;
		IF cMes='11' THEN
			LET cNomes =' DE NOVIEMBRE DE ';
		END IF;
		IF cMes='10' THEN
			LET cNomes =' DE OCTUBRE DE ';
		END IF;
		IF cMes='09' THEN
			LET cNomes =' DE SEPTIEMBRE DE ';
		END IF;
		IF cMes='08' THEN
			LET cNomes =' DE AGOSTO DE ';
		END IF;
		IF cMes='07' THEN
			LET cNomes =' DE JULIO DE ';
		END IF;
		IF cMes='06' THEN
			LET cNomes =' DE JUNIO DE ';
		END IF;
		IF cMes='05' THEN
			LET cNomes =' DE MAYO DE ';
		END IF;
		IF cMes='04' THEN
			LET cNomes =' DE ABRIL DE ';
		END IF;
		IF cMes='03' THEN
			LET cNomes =' DE MARZO DE ';
		END IF;
		IF cMes='02' THEN
			LET cNomes =' DE FEBRERO DE ';
		END IF;
		IF cMes='01' THEN
			LET cNomes =' DE ENERO DE ';
		END IF;

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchSolfi,cCuenta_Prestadora
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'AAAA',cAnio);
		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'MM',cMes);
		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'DD',cDia);
		
		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || 'SOLFI SA DE CV SOFOEM ENR' || '" >> ' || cRutaArchSolfi;
			SYSTEM cStmt;
		LET cStmt='echo "' || 'FECHA: ' ||cDia||" "||TRIM(cNomes)||" "||cAnio|| '" >> ' || cRutaArchSolfi;
			SYSTEM cStmt;
				
        FOREACH

            SELECT fecha_pago,
				   LPAD(DAY(fecha_pago::DATE), 2, '0'),
			       LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				   LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				   LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				   LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				   LPAD(SUBSTR(fecha_insert,18,2),2,'0'),				   
				   referencia1,
				   importe_pago*100,
				   importe_comision_convenio * 100,
                   iva_comision_convenio * 100,
			       flag_confirmacion_central,flag_confirmacion_sucursal,folio_suc
			INTO   dFechaPago, cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSegundo,cReferencia1,iImporte_Pago,iImporte_Comision,iImporte_IVA_Comision,iFlagCen,iFlagSuc,cFolio
            FROM "informix".sac_movimientoshistorial 
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
--EPG
--actualizacion de flag_confirmacion_sucursal = 1 en caso de que no se haya confirmado en sucursal por algun motivo
			IF iFlagCen = 0 OR iFlagSuc = 0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
	        END IF;

			IF iCuantos > 0 THEN
				INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
				VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);					
		    END IF;
--EPG			
			LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
			LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImporte_IVA_Comision;
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
			LET iNumPagos = iNumPagos + 1;
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cTpoOperacion ||"|"|| cDiaPago || cMesPago || cAnioPago || "|" || cHora || cMinuto || cSegundo || "|" || LPAD(cFolio, 16, '0') || "|" || LPAD(TRIM(cReferencia1), 9, '0') || "|" || LPAD(iImporte_Pago, 11, '0') || '" >> ' || cRutaArchSolfi;
            SYSTEM cStmt;
        END FOREACH;
		
			LET cReferencia1 = '';
			LET cFolio       = '';
			LET cHora		 = '';
			LET cMinuto		 = '';
			LET cSegundo	 = '';
		 
		--IMPRIME EL RENGLON COMISIONES
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';
			LET cStmt = 'echo "' || cTpoOperacion ||"|"|| cDiaPago || cMesPago || cAnioPago ||"|"||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSegundo), 2, '0') ||"|"||LPAD(TRIM(cFolio), 16, '0') ||"|"|| LPAD(TRIM(cReferencia1), 9, '0') || "|"|| LPAD(iSumaImporte_Comision, 11, '0') || '" >> ' || cRutaArchSolfi;
            SYSTEM cStmt;
		END IF;

		--IMPRIME EL RENGLON DEL IVA
		IF iSumaImporte_IVA_Comision <> 0 THEN
		    LET cTpoOperacion = 'I';
			LET cStmt = 'echo "' || cTpoOperacion ||"|"|| cDiaPago || cMesPago || cAnioPago || "|"||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSegundo), 2, '0')|| "|"||LPAD(TRIM(cFolio), 16, '0') ||"|"|| LPAD(TRIM(cReferencia1), 9, '0') ||"|"|| LPAD(iSumaImporte_IVA_Comision, 11, '0') || '" >> ' || cRutaArchSolfi;
            SYSTEM cStmt;
		END IF;
		
		--IMPRIME EL RENGLON DE TOTAL
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision);

			LET cStmt = 'echo "' || cTpoOperacion ||"|"|| cDiaPago || cMesPago || cAnioPago ||"|"||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSegundo), 2, '0')|| "|"||LPAD(TRIM(cFolio), 16, '0') ||"|"|| LPAD(TRIM(TO_CHAR(iNumPagos)), 9, '0')  || "|"|| LPAD(iTotal_Pago, 11, '0')|| '" >> ' || cRutaArchSolfi;
			SYSTEM cStmt;
		END IF;
		
		--SI NO SE ENCONTRARON REGISTROS SE IMPRIME TOTAL EN CEROS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		    LET cTpoOperacion = 'T';
			LET cStmt = 'echo "' || cTpoOperacion ||"|"|| LPAD(TRIM(cDia),2,'0') || LPAD(TRIM(cMes),2,'0') || LPAD(TRIM(cAnio),4,'0') || "|"||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSegundo), 2, '0')|| "|"||LPAD(TRIM(cFolio), 16, '0')|| "|"||LPAD(TRIM(cReferencia1), 9, '0') ||"|"|| LPAD(iTotal_Pago, 11, '0') || '" >> ' || cRutaArchSolfi;
            SYSTEM cStmt;
        END IF;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFechaPago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFechaPago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Ernesto Aguilera Inda.',
'DESCRIPCIÓN: SP que genera un archivo .txt donde se guardan las operacines de pagos SOLFI.',
'FOLIO:1426',
'FECHA:25/04/2014',
'VERSIÓN: 20140425.1622',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014',
'BASE DE DATOS: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacablemas(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia		        	CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE cReferencia1			CHAR(32);
DEFINE cRutaArchCablemas		CHAR(100);
DEFINE cNombreArchCablemas 		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iSumaImporte_IVA_Comision	DECIMAL(11,0);
DEFINE iImporte_Pago			DECIMAL(9,0);
DEFINE iTotal_Pago			DECIMAL(11,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE cNombreSuc			CHAR(25);
DEFINE cEstado				CHAR(2);
DEFINE cNombreCiu			CHAR(25);
DEFINE iFlagCopp			INTEGER;
DEFINE vDias                INTEGER;
DEFINE cCiudad				CHAR(3);

DEFINE cSPCodRet CHAR(5); 
DEFINE iMensaje CHAR(50);
DEFINE cid_ptf CHAR(5); 
DEFINE ccve_pais CHAR(3);
DEFINE cnompais CHAR(20);
DEFINE ccalle VARCHAR(100); 
DEFINE cnum_ext VARCHAR(6); 
DEFINE cnum_int VARCHAR(5); 
DEFINE ccve_col CHAR(8);
DEFINE cnomcol VARCHAR(100);
DEFINE ccve_mun CHAR(3);
DEFINE cnommunicipio VARCHAR(60);
DEFINE ccve_localidad CHAR(14);
DEFINE cnomlocalidad VARCHAR(60);
DEFINE ccp CHAR(5); 
DEFINE ccve_ciudad CHAR(3);
DEFINE cnomciudad VARCHAR(60);
DEFINE ccve_estado CHAR(2); 
DEFINE cnomestado VARCHAR(30);
DEFINE ctel1 VARCHAR(14); 
DEFINE ctel2 VARCHAR(14);
DEFINE ctipo VARCHAR(5);

/*VARIABLES PARA ELIMINAR SELECT DE IF*/
DEFINE cvalidaselif INTEGER;
LET cvalidaselif =0;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cMovimiento				= '';
LET cTipoMovimiento			= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iSumaImporte_IVA_Comision		= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchCablemas			= '';
LET cNombreArchCablemas			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= 'H';
LET iNumPagos				= 0;
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cNombreSuc				= '';
LET cEstado					= '';
LET cCiudad					= '';
LET cNombreCiu				= '';
LET iFlagCopp           	= 0;
LET vDias               	= 0;

LET cSPCodRet = '00000';
LET iMensaje = '';
LET cid_ptf = '';
LET ccve_pais = '';
LET cnompais = '';
LET ccalle = '';
LET cnum_ext = ''; 
LET cnum_int = '';
LET ccve_col = '';
LET cnomcol = '';
LET ccve_mun = '';
LET cnommunicipio = '';
LET ccve_localidad = '';
LET cnomlocalidad = '';
LET ccp = '';
LET ccve_ciudad = '';
LET cnomciudad = '';
LET ccve_estado = ''; 
LET cnomestado = '';
LET ctel1 = '';
LET ctel2 = '';
LET ctipo = '';	

	---SET DEBUG FILE TO  '/informix/rer/sp_generaarchivocobranzacablemas_aia.out';
	---TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";		
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 				
		
		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT ruta_archivo_cobranza,nombre_archivo_cobranza
		INTO cRutaArchCablemas,cNombreArchCablemas
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		LET cRutaArchCablemas = TRIM(cRutaArchCablemas)||TRIM(cNombreArchCablemas);
		
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'AA',cAnio);
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'MM',cMes);
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'DD',cDia);
		
		--Borramos evidencia de archivo generado anteriormente (En caso de existir)
		LET cStmt = 'rm -f ' || cRutaArchCablemas;
		SYSTEM cStmt;
		
		--OBTENGO VALOR DE DIAS DE GRACIA
		SELECT valor
		INTO   vDias
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
		
		--OBTENGO EL TIPO DE MOVIMIENTO
		SELECT movimiento, tipomovimiento
		INTO   cMovimiento, cTipoMovimiento
		FROM   sac_servicios_cpl
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;
		
		



			SELECT COUNT(*) INTO cvalidaselif
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  movimiento = cMovimiento
			AND    tipomovimiento = cTipoMovimiento
			AND    st_conciliado = '1';


		--Reviso si existe archivo importado correctamente del dÃ­a
		IF cvalidaselif > 0 THEN
			LET iFlagCopp = 1;
		END IF;
		
		LET cvalidaselif = 0;
		
		
		--TOTAL		
		FOREACH
			SELECT fecha_pago,			
			NVL(folio_suc,''),
			NVL(referencia1,''),
			NVL(importe_pago*100,0),
			NVL(flag_confirmacion_central,0),
			NVL(flag_confirmacion_sucursal,0)
			INTO dFechaPago,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
			FROM "informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio
			AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
			AND status_cancelado <> 'S'
			AND (flag_confirmacion_central = 1
			OR flag_confirmacion_sucursal = 1)
			AND origen                    != "CPL"

			--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
			IF iFlagCen = 0 OR iFlagSuc = 0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;

			IF iCuantos > 0 THEN
				INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
				VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
			END IF;

			LET iNumPagos = iNumPagos + 1;
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago;
			
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			--Detalle Coppel
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago*100,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria 
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
				END IF;
				
				LET iNumPagos = iNumPagos + 1;
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago;

			END FOREACH;
			
		END IF;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFechaPago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			LET cReferencia1 = TRIM (cReferencia1);
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFechaPago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;
		
		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || cTpoOperacion || ',' || cAnio || cMes || cDia || ',' || LPAD(iNumPagos,6,0) || ',' || LPAD(iTotal_Pago,11,0) || '" >> ' || cRutaArchCablemas;
		SYSTEM cStmt;	
			
		--DETALLE
		FOREACH

			SELECT fecha_pago,
			LPAD(DAY(fecha_pago::DATE), 2, '0'),
			LPAD(MONTH(fecha_pago::DATE), 2, '0'),
			LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			case when origen = 'CPL' then NVL(sucursal_cpl,'') else NVL(id_sucursal,'') end,
			NVL(folio_suc,''),
			NVL(referencia1,''),
			NVL(importe_pago*100,0),
			NVL(flag_confirmacion_central,0),
			NVL(flag_confirmacion_sucursal,0)
			INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
			FROM "informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio
			AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
			AND status_cancelado <> 'S'
			AND (flag_confirmacion_central = 1
			OR flag_confirmacion_sucursal = 1)
			AND origen                    != "CPL"

			IF iFlagCen = 0 OR iFlagSuc = 0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;

			IF iCuantos > 0 THEN
				UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago = dFechaPago
				AND folio_suc = cFolio
				AND referencia1 = cReferencia1
				AND status_cancelado <> 'S'
				AND flag_confirmacion_sucursal = 0;
			END IF;				
				
				
			SELECT COUNT(*)	INTO cvalidaselif
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			IF cvalidaselif > 0 THEN				
				SELECT NVL(REPLACE(nombre,',',' '),'')			
				INTO cNombreSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cSucursal;				
			ELSE			
				LET cNombreSuc = '';			
			END IF;
			
			LET cvalidaselif = 0;
			
			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			
			IF cSPCodRet != '00000' THEN
				LET cNombreCiu = '';	
			ELSE
				LET cNombreCiu = cnomciudad;
			END IF;		
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || 'D' || ',' || LPAD(cNombreCiu,25,' ') || ',' || LPAD(cNombreSuc,25,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '09:00' || ',' || cReferencia1 || ',' || LPAD(iImporte_Pago,9,0) || '" >> ' || cRutaArchCablemas;
			SYSTEM cStmt;
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			--Detalle Coppel
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				LPAD(DAY(sm.fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(sm.fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(sm.fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sm.sucursal_cpl,'') else NVL(sm.id_sucursal,'') end,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago*100,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria 
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFechaPago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
					AND status_cancelado <> 'S'
					AND flag_confirmacion_sucursal = 0;
				END IF;
				
				SELECT COUNT (*) INTO cvalidaselif 
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cSucursal;
				
				IF cvalidaselif > 0 THEN				
					SELECT NVL(estado,''), NVL(ciudad,''), NVL(REPLACE(nombre,',',' '),'')
					INTO cEstado, cCiudad, cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal; 
					
					SELECT REPLACE(NVL(nombre,''),',',' ')
					INTO cNombreCiu
					FROM bdinteg:"informix".si_ciudades 
					WHERE estado = cEstado AND ciudad = cCiudad;
					
				ELSE				
					LET cNombreCiu = '';
					LET cNombreSuc = '';
				END IF;
				
				LET cvalidaselif = 0;
				
				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || 'D' || ',' || LPAD(cNombreCiu,25,' ') || ',' || LPAD(cNombreSuc,25,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '09:00' || ',' || cReferencia1 || ',' || LPAD(iImporte_Pago,9,0) || '" >> ' || cRutaArchCablemas;
				SYSTEM cStmt;

			END FOREACH;
			
		END IF;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;