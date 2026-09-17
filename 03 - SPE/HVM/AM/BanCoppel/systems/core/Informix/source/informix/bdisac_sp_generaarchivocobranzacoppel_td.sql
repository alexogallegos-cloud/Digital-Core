CREATE PROCEDURE "informix".sp_generaarchivocobranzacoppel_td(cId_convenio CHAR(5))
	RETURNING CHAR(5); 

--DEFINICION DE 
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE cCategoria           CHAR(2);
    DEFINE cMes                 CHAR(2);
    DEFINE cDia                 CHAR(2);
    DEFINE cConvenio            CHAR(3);
    DEFINE cAnio                CHAR(4);
    DEFINE cExtUnl              CHAR(4);
    DEFINE cExtTxt              CHAR(4);
    DEFINE cNomArchCPL          CHAR(16);
    DEFINE cNomArchCPLF         CHAR(16);
    DEFINE cNomArchTot          CHAR(16);
    DEFINE cNomArchTotF         CHAR(16);
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
	DEFINE iFlagCen             INTEGER;
	DEFINE iFlagSuc             INTEGER;
	DEFINE cFolio               CHAR(16);
	DEFINE iCuantos             INTEGER;
	DEFINE dFecha_Pago           DATE;
	DEFINE cReferencia1          CHAR(20);
	
	DEFINE auxFechaIni            CHAR(15);
	DEFINE auxFecha_Hoy           CHAR(15);

	--SET DEBUG FILE TO "/informix/LuisBeltran/BDISAC/sp_generaarchivocobranzacoppel_td.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --INICIALIZACION DE VARIABLES
    LET cCodRet = '00000';
    LET cStmt = '' ;
    LET cNomArchCPL = '';
    LET cNomArchCPLF = '';
    LET cRuta = '';
    LET cSql = '';
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
               
                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;

                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GeneraArchivoCobranzaCoppel");
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0');
		
		LET auxFecha_Hoy = 'MDY('||LPAD(MONTH(dFecha_Hoy::DATE), 2, '0')||','||LPAD(DAY(dFecha_Hoy::DATE), 2, '0')||','||LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0')||')';
		LET auxFechaIni = 'MDY('||LPAD(MONTH(dFechaIni::DATE), 2, '0')||','||LPAD(DAY(dFechaIni::DATE), 2, '0')||','||LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0')||')';

        SELECT TRIM(valor)
        INTO cRuta
        FROM bdisac:sac_param
        WHERE cod_param =  3;
		
		LET cNomArchCPL = "mvbd"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchCPLF = "mvbd"|| cDia||cMes||cAnio ||cExtTxt;
        --LET cNomArchTot = "cfvd"|| cDia||cMes||cAnio ||cExtUnl;
        --LET cNomArchTotF = "cfvd"|| cDia||cMes||cAnio ||cExtTxt;
        LET cRutaFC = TRIM(cRuta) || cNomArchCPL;
        --LET cRutaFT = TRIM(cRuta) || cNomArchTot;
		
		
        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) ||''' SELECT cliente,folio_abono,subfolio,cartera,factura,tipo_cuenta,importe,fecha_abono,tienda,sucursal  ' ||
                        'FROM bdisac: sac_movimientos_detalle_td_historial a ,bdisac:sac_movimientoshistorial b '||
						'WHERE a.fecha_abono > '||auxFechaIni||' AND a.fecha_abono <= '||auxFecha_Hoy||' AND a.cliente::integer = b.referencia1 '||
						'AND a.folio_abono = b.referencia2 AND b.numcategoria = '||cCategoria||' AND b.numconvenio = '||cConvenio||' AND NOT (status_cancelado = ''S'' AND status_coppel = 0);"'||
                        '> /tmp/tmpAbonosCoppel.sql';
        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmpAbonosCoppel.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' " || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) || " > "|| TRIM(cRuta)||cNomArchCPLF;
        SYSTEM cSql;
   

        --LET cSql_Stmt = '';
        --LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || ''' SELECT tipo, importe, cantidad, sucursal, fecha, fecha_movto ' ||
         --               'FROM bdisac:sac_totalmovimientosdetallehistorial WHERE fecha = (SELECT fecha_hoy FROM bdisac:sac_fechas) " > /tmp/tmp.sql';

        --SYSTEM cSql_Stmt;

        --LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        --SYSTEM cStmt;

        --LET cSql = "sed 's/|$//g' "|| SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || " > " || TRIM(cRuta) || cNomArchTotF;
        --SYSTEM cSql;
		
        LET cStmt = 'rm -f /tmp/tmpAbonosCoppel.sql';
        SYSTEM cStmt;
		
		LET cStmt = 'rm -f '||TRIM(cRuta) ||cNomArchCPL;
        SYSTEM cStmt;
		
		


        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
	RETURN cCodRet;
END PROCEDURE
DOCUMENT
'==========================================================================',
'AUTOR : Luis Alberto Beltran Rodriguez',
'DESCRIPCION: Genera el archivo de cobranza Coppel',
' de acuerdo a Layout proporcionado por carteras y los nuevos servicios omnicanales',
'EJECUTADO O LLAMADO POR:',
'sp_procesocierresac()',
'FECHA : Marzo de 2022',
'VERSION: 202203',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_obtienerecibo(p_Sucursal CHAR(4), p_FolioSuc VARCHAR(16))
RETURNING
     CHAR(5), ---cod_ret
	 CHAR(20), ---Recibo
	 CHAR(1), ---Status Coppel
     CHAR(20); ---Cliente Coppel
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);

	DEFINE v_Recibo				VARCHAR(20);
	DEFINE v_Status				VARCHAR(20);
    DEFINE v_Cliente			VARCHAR(20);

	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
        RETURN v_cod_ret, NULL, NULL,NULL;
    END EXCEPTION;


	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET vDesErr = '';
	LET v_Recibo 				= "";
	LET v_Status				= "";
    LET v_Cliente				= "";

	IF (p_Sucursal IS NULL OR p_Sucursal = '')  THEN 
		RETURN '00001', NULL, NULL,NULL;
	ELSE
		IF (p_FolioSuc IS NULL OR p_FolioSuc = '')  THEN 
			RETURN '00002', NULL, NULL,NULL;
		ELSE
			SELECT DISTINCT mov.referencia2, movdet.status_coppel,mov.referencia1
			INTO v_Recibo, v_Status,v_Cliente
			FROM bdisac: sac_movimientos mov, bdisac: sac_movimientos_detalle_td movdet
			WHERE mov.referencia2 = movdet.folio_abono
			AND mov.id_sucursal = p_Sucursal AND mov.folio_suc = p_FolioSuc;

			LET v_Recibo 		= NVL(v_Recibo,"");
			LET v_Cliente 		= NVL(v_Cliente,"");
		END IF
	END IF

	RETURN v_cod_ret, v_Recibo, v_Status,v_Cliente;

END;
--##############################################################################
--## Procedimiento   : sp_ObtieneRecibo
--## Base de Datos   : bdisac
--## Version         : 1.0
--## Creado por      : Enrique Dorantes
--## Fecha creacion  : Junio de 2009
--##Descripcion : Procedimiento para obtener el recibo de un pago coppel atraves del folio de sucursal
--##############################################################################

--PeticiÃ³n:	821.1
--Nombre:	Requerimiento Pagos Cruzados en Sucursal Web FRONT
--Empleado: 98640909 - Luis Alberto Beltran Rodriguez
--Fecha: 20-01-2022
--Database: bdisac

END PROCEDURE;