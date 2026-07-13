CREATE PROCEDURE "informix".sp_reporte_huellas_aut_diario()
	RETURNING
		CHAR(6) 	AS 	COD_RET,
		CHAR(80) 	AS MENSAJE_RET;
		
	--DECLARACION DE VARIABLES
	DEFINE cCodret 		 	CHAR(6);
	DEFINE iSqlErr        	INTEGER;
	DEFINE cMensaje       	CHAR(80);
	DEFINE dFechaAdul		DATE;
	DEFINE dFechaPro		DATE;
	DEFINE cFechaArc		CHAR(8);
	DEFINE cRuta			CHAR(80);
	DEFINE cSelectQry		CHAR(1000);
	DEFINE cCmd1			CHAR(1000);
	
	--INICIALIZACION DE VARIABLES
	LET cCodret			= '00000';
	LET iSqlErr 		= 0;
	LET cMensaje		= 'PROCESO EXITOSO';
	LET dFechaAdul		= DATE(1);
	LET dFechaPro		= DATE(1);
	LET cRuta			= '';
	LET cSelectQry		= '';
	LET cCmd1			= '';
	LET cFechaArc		= '';

BEGIN
	-----Control de Errores de Informix
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET cMensaje = "ERROR NO CONTROLADO";
			RETURN cCodret, cMensaje;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Obtener la fecha a procesar y la fecha para la mayoria de edad
	SELECT fecha_ant, date(fecha_ant - interval(18) YEAR TO YEAR),TO_CHAR(fecha_ant, "%Y%m%d")
	INTO  dFechaPro,dFechaAdul,cFechaArc 
	FROM bdinteg:si_fechas
	WHERE empresa = '001';	
	
	--SET DEBUG FILE TO "/informix/cristol/sp_reporte_huellas_aut_diario.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	
	-- Se realiza optimizacion de consulta utilizando tablas temporales de paso
	SELECT DISTINCT LPAD(TRIM(cliente::CHAR(9)), 9,'0') numcte2,ticket, fecha
	FROM si_huella_linea_resultado
	WHERE fecha = dFechaPro   -- parametro de entrada
	AND num_mensaje = '602' AND cliente <> '0' AND empresa = '5'
	
	INTO temp huella_linea_resul WITH NO LOG;
	
	SELECT a.numcte2, a.ticket, a.fecha, cte1.apell_paterno apell_pat_2, cte1.apell_materno apell_mat_2, cte1.nombre1 nom1_2, cte1.nombre2 nom2_2, cte1.sucursal sucursal_2, cte1.ejecutivo ejecutivo_2,cte1.rfc rfc_2, pf.fecha_nac fecha_nac2
	FROM huella_linea_resul a,  si_cliente cte1, si_ctepf pf
	WHERE pf.fecha_nac <= dFechaAdul
	AND numcte2 = cte1.numcte AND numcte2 = pf.numcte

	INTO temp clientes_bcpl_dupl_2 WITH NO LOG;
	
	
	
	SET ISOLATION TO DIRTY READ;
	SELECT a.numcte numcte1, a.fecha_consulta, a.ticket, cte1.apell_paterno apell_pat_1, cte1.apell_materno apell_mat_1, cte1.nombre1 nom1_1, cte1.nombre2 nom2_1, cte1.sucursal sucursal_1, cte1.ejecutivo ejecutivo_1,cte1.rfc rfc_1, pf.fecha_nac fecha_nac1
	FROM si_huella_linea a, si_cliente cte1, si_ctepf pf
	WHERE fecha_consulta = dFechaPro  AND ticket IN
	(SELECT ticket FROM clientes_bcpl_dupl_2) AND a.numcte = cte1.numcte  AND a.numcte = pf.numcte
	
	INTO temp clientes_bcpl_dupl_1 WITH NO LOG;
	
	INSERT INTO si_clientes_huellas_dupl(numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1,sucursal_1,ejecutivo_1, rfc_1, fecha_nac1, numcte2, apell_pat_2, apell_mat_2, nom1_2, nom2_2, sucursal_2, ejecutivo_2,rfc_2, fecha_nac2, ticket, fecha_consulta, fecha_insert)
		SELECT a.numcte1, a.apell_pat_1, a.apell_mat_1, a.nom1_1, a.nom2_1,a.sucursal_1,a.ejecutivo_1, a.rfc_1, a.fecha_nac1, b.numcte2, b.apell_pat_2, b.apell_mat_2, b.nom1_2, b.nom2_2,b.sucursal_2, b.ejecutivo_2,b.rfc_2, b.fecha_nac2, a.ticket, a.fecha_consulta, CURRENT AS fecha_insert
		FROM clientes_bcpl_dupl_1 a, clientes_bcpl_dupl_2 b
		WHERE a.ticket = b.ticket 
		AND b.fecha = a.fecha_consulta;
		
		
	EXECUTE PROCEDURE "informix".sp_compara_nombres()
	INTO cCodret;
	
	set isolation to dirty read;   
	set lock mode to wait 4;  
	
	-- Proceso para generar reporte de resultados diario en archivo plano
	SELECT LIMIT 1 TRIM(VALOR)
	INTO cRuta 
	FROM bdimnsj:"informix".mnsj_param
	WHERE cod_param = '3';
	
	
	LET cSelectQry = "select ""numcte1"",""apell_pat_1"",""apell_mat_1"",""nom1_1"",""nom2_1"",""sucursal_1"",""ejecutivo_1"",""rfc_1"",""fecha_nac1"","||
	" ""numcte2"",""apell_pat_2"",""apell_mat_2"",""nom1_2"",""nom2_2"",""sucursal_2"",""ejecutivo_2"",""rfc_2"",""fecha_nac2"",""fecha_consulta"","||
	" ""porce_simil"" from bdinteg:""informix"".si_fechas union all select * from table (multiset (select numcte1,apell_pat_1,apell_mat_1,nom1_1,nom2_1,sucursal_1,ejecutivo_1,rfc_1,"||
	" TRIM(fecha_nac1::CHAR(10)), numcte2,apell_pat_2, apell_mat_2, nom1_2, nom2_2, sucursal_2, ejecutivo_2, rfc_2, TRIM(fecha_nac2::CHAR(10)),"||
	" TRIM(fecha_consulta::CHAR(10)),TRIM(porce_simil::CHAR(6)) from bdinteg:""informix"".si_clientes_huellas_dupl where fecha_consulta = """||dFechaPro||""" and numcte1 <> numcte2  order by porce_simil desc, numcte1));";		
		
	LET cCmd1 = "echo 'UNLOAD TO """||TRIM(cRuta)||"/rephuella_"||cFechaArc||".txt"" "||TRIM(cSelectQry)||"'| dbaccess sysmaster > """||TRIM(cRuta)||"/rephuella_diario.log""  2>&1";
	SYSTEM TRIM(cCmd1);
	
	RETURN cCodret, cMensaje;
END
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: GENERA REPORTE DIARIO DE HUELLAS DUPLICADAS',
'FECHA DE CREACIÃN: 29-JULIO-2013',
'FECHA DE MODIFICACIÃN: 07-AGOSTO-2013',
'BASE DE DATOS: BDINTEG',
'VERSION: 20130807.1000';

CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_dia_corporativo(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_numeroCliente CHAR(20), p_skip INT, p_sTarjeta CHAR(30), p_sEmpresa CHAR(4))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, 
                CHAR(30) AS folioSuc, CHAR(40) AS nombreSucursal, CHAR(40) AS tipo, CHAR(1) AS reversado, 
                CHAR(10) AS id, CHAR(20) AS cuenta, CHAR(1) AS naturaleza,CHAR(40) AS referencia,CHAR(20) AS tarjeta;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento 	DATE;
	DEFINE resultado_monto			money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc		CHAR(30);
    	DEFINE resultado_nombreSucursal 	CHAR(40);
	DEFINE resultado_tipo   		CHAR(40);
   	DEFINE resultado_reversado          CHAR(1);
   	DEFINE resultado_id                 CHAR(10);
    	DEFINE resultado_cuenta             CHAR(20);
    	DEFINE resultado_naturaleza         CHAR(1);
    	DEFINE resultado_referencia         CHAR(40);
   	DEFINE resultado_tarjeta            CHAR(20);
    	DEFINE cuenta_temp                  CHAR(20);
    	DEFINE iSqlErr                      INTEGER;
     
     -- InicializaciÃÂ³n de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
    LET resultado_nombreSucursal = '';
	LET resultado_tipo = '';
    LET resultado_reversado = '';
    LET resultado_id = '';
    LET resultado_cuenta = '';
    LET resultado_naturaleza = '';
    LET resultado_referencia = '';
    LET resultado_tarjeta = '';

    SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_nombreSucursal = '';
                    LET resultado_tipo = '';
                    LET resultado_reversado = '';
                    LET resultado_id = '';
                    LET resultado_cuenta = '';                    
                    LET resultado_naturaleza = '';
                    LET resultado_referencia = '';
                    LET resultado_tarjeta = '';
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, 
                            resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, 
                            resultado_cuenta,resultado_naturaleza,resultado_referencia,resultado_tarjeta;
                END IF;
        END EXCEPTION;

            IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
                select distinct numcuenta
                    into cuenta_temp
                    from intercard:tarjetacuenta 
                    where numtarjeta = p_sTarjeta;

                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, num_credito, bdinteg:si_transacc.naturaleza,referencia,nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
                          FROM bdicred:sd_movdia 
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movdia.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND nro_tarjeta = p_sTarjeta
                            AND bdicred:sd_movdia.empresa = p_sEmpresa
                            AND num_credito = cuenta_temp
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
            ELSE
                IF (p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '') THEN
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, num_credito,bdinteg:si_transacc.naturaleza,referencia, nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
                          FROM bdicred:sd_movdia
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movdia.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND num_credito = p_sNumeroCuenta
                            AND bdicred:sd_movdia.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza,resultado_referencia,resultado_tarjeta WITH RESUME;
                    END FOREACH;
                ELSE
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, bdicred:sd_movdia.num_credito,bdinteg:si_transacc.naturaleza,referencia, nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
                          FROM bdicred:sd_movdia 
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movdia.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                            LEFT JOIN bdicred:sd_maecred ON (bdicred:sd_movdia.num_credito = bdicred:sd_maecred.num_credito AND bdicred:sd_maecred.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND numcte = p_numeroCliente
                            AND bdicred:sd_movdia.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
                END IF;
           END IF;
	END 
END PROCEDURE;