CREATE PROCEDURE "informix".sp_calculagat_morales()

-- ******************************************************************************************
-- Realizo   : Daniel Perez
-- Proyecto  : RQM GAT Automatizada
-- Actividad : Calcular automaticamente la GAT para el producto 1200
--                 
-- Fecha     : 23 de Agosto de 2023
-- ******************************************************************************************

RETURNING CHAR(5) AS codRet,
CHAR(100) AS gatNominal,
CHAR(100) AS gatReal;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vValor 					DECIMAL(9,6);
DEFINE vGatReal					DECIMAL(9,6);
DEFINE vMedianaInflacion  		DECIMAL(9,6);
DEFINE vCadenaGatNominal        VARCHAR(100);
DEFINE vCadenaGatReal        	VARCHAR(100);
DEFINE vDelimitador				CHAR(1);
DEFINE vCodRet					CHAR(5);

-- Valores iniciales
LET vValor	 					= 0;
LET vGatReal					= 0;
LET vMedianaInflacion     		= 0;
LET vCadenaGatNominal 			= '';
LET vCadenaGatReal 				= '';
LET vDelimitador 				= '';
LET vCodRet           			= '00000';

BEGIN

	ON EXCEPTION SET SQL_ERR
		IF SQL_ERR <> 0 THEN
			LET vCodRet = SQL_ERR;
			RETURN vCodRet, vCadenaGatNominal, vCadenaGatReal;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/sp_puebas/gat_automatizada/sp_crea_temp_morales.out';
    --TRACE ON;

	SELECT med_inflacion
		INTO vMedianaInflacion
		FROM sc_medianainflacion
		WHERE fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM sc_medianainflacion);

	FOREACH 
	SELECT valor 
	INTO vValor
	FROM bdinteg:si_tasavlor 
	WHERE  tasa = 'EJEMP' AND valor <> 0 
	ORDER BY valor

		LET vCadenaGatNominal = vCadenaGatNominal || vDelimitador || TO_CHAR(vValor, "<<<.<<");

		IF vMedianaInflacion IS NOT NULL THEN
			LET vGatReal = ROUND(((((1 + (vValor/100)) / (1 + (vMedianaInflacion/100)))-1)*100),2);
			LET vCadenaGatReal = vCadenaGatReal || vDelimitador || TO_CHAR(vGatReal, "-&.<<");
		END IF;

		LET vDelimitador = '|';


	END FOREACH;

	RETURN vCodRet, vCadenaGatNominal, vCadenaGatReal;
	
END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se encarga de hacer el calculo de la GAT nominal y real para el producto 1200',
'AUTOR : Daniel Perez',
'FECHA : 23/Agosto/2023',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_calculagat()

-- ******************************************************************************************
-- Realizo   : Roberto Castro
-- Proyecto  : RQM GAT Automatizada
-- Actividad : Calcular automaticamente la GAT para las cuentas de captacion
--             
--             
--             
--             
--             
--             
-- Fecha     : Abril de 2023
-- ******************************************************************************************

RETURNING CHAR(5);
--RETURNING DECIMAL(9,6);

-- // DefiniciÃ³n de Variables

-- // Variables del sp
DEFINE v_cCodRet			CHAR(5);
DEFINE v_cCodRetGatMorales 	CHAR(5);
DEFINE vsqlerr				INTEGER ;
DEFINE cProducto			CHAR(4);
DEFINE dTasa				DECIMAL(9,6);
DEFINE cPeriodo				CHAR(3);
DEFINE dMedInflacion		DECIMAL(9,6);
DEFINE cGatNominal			CHAR(100);
DEFINE cGatReal				CHAR(100);

-- // VALORES INICIALES
LET cProducto = '';
LET dTasa = 2;
LET cPeriodo = '0';
LET dMedInflacion = 0;

--SET DEBUG FILE TO '/home/informix/ivonne/sp_calculagat.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET v_cCodRet = vsqlerr;
			RETURN v_cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO CURSOR STABILITY;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	--GAT NOMINAL
	update bdicheq:sc_gat
		set gat_nominal = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 100, 2),
			fecha_publicacion = TODAY;
	
	--PAGARE
	update bdinvers:sv_gat
		set gat_nomina = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 100, 2),
			fecha_publicacion = TODAY;
		
	IF EXISTS (SELECT med_inflacion FROM sc_medianainflacion) THEN
		
		SELECT (med.med_inflacion/100) INTO dMedInflacion 
		FROM sc_medianainflacion med 
		WHERE med.fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM sc_medianainflacion);

		update bdicheq:sc_gat
			set gat_real = ROUND(((((1 + (gat_nominal/100)) / (1 + dMedInflacion))-1)*100),2);
		
		update bdinvers:sv_gat
			set gat_real = ROUND(((((1 + (gat_nomina/100)) / (1 + dMedInflacion))-1)*100),2);
		
		LET v_cCodRet = '00000';
	ELSE
		LET v_cCodRet = '00001'; --No existe mediana Inflacion
	END IF;

	EXECUTE PROCEDURE bdicheq:sp_calculagat_morales()
		INTO v_cCodRetGatMorales, cGatNominal, cGatReal;

	IF v_cCodRetGatMorales = '00000' THEN 
		IF v_cCodRet <> '00001' THEN 
			UPDATE bdicnweb:sw_infocaratula SET gat_nominal = cGatNominal, gat_real = cGatReal WHERE num_producto = 1200;
		ELSE 
			UPDATE bdicnweb:sw_infocaratula SET gat_nominal = cGatNominal WHERE num_producto = 1200;
		END IF;
	END IF;

	RETURN v_cCodRet;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Calcula automaticamente la GAT para las cuentas de captacion',
'AUTOR : Roberto Castro',
'FECHA : Abril de 2023',
'BD    : BDICHEQ',
'MODIFICACION: Se agrega llamado al procedimiento sp_calculagat_morales, ',
' se actualizan los campos para la sw_infocaratula',
' y se actualizan las fechas de publicacion',
'MODIFICO : Daniel Perez.',
'FECHA : 23/Agosto/2023',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_histmovcheq(pempresa CHAR(3))
RETURNING CHAR(5)  AS vcodret1, 
          CHAR(5)  AS vcodret2, 
          CHAR(50) AS vcodret3;

    DEFINE vcodret1      CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      CHAR(50);
    DEFINE sql_err       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE desc_err      CHAR(50);
    DEFINE vcomienza     SMALLINT;
    DEFINE ventransacc   SMALLINT;
    DEFINE vcontador     INTEGER;
    DEFINE vfecha_ant    DATE;
    DEFINE vfecha_hoy    DATE;
    DEFINE vpasomovshist DATE;
    DEFINE vsistema      CHAR(2);
    DEFINE vfecha        CHAR(8);
    DEFINE vsql          CHAR(2000);
    DEFINE vstmt         CHAR(100);
    DEFINE vcodretparam  CHAR(5);
    DEFINE vinicio_proceso SMALLINT;
	DEFINE vcuenta_fin   CHAR(20);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = ''; 
    LET vcomienza     = -1;
    LET ventransacc   = 0;
    LET vcontador     = 0;
    LET vfecha_ant    = '';
    LET vfecha_hoy    = '';
    LET vpasomovshist = '';
    LET vsistema      = '01';
    LET vfecha        = ''; 
    LET vsql          = '';
    LET vstmt         = '';
    LET vcodretparam  = '';
    LET vinicio_proceso = 0;
	LET vcuenta_fin   = '';
    
    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheq.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheq.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_ant, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    SELECT fecha 
      INTO vpasomovshist
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist";

    IF vpasomovshist <> vfecha_ant THEN
        LET vcodret1 = "953";
        LET vcodret2 = "953";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // LLAMA AL PROCESO PARA EL RANGO DE CUENTAS
    CALL sp_actparamhistmovchq(pempresa)
    RETURNING vcodretparam;
    
    IF vcodretparam = '000' THEN
        UPDATE sc_contproc
           SET fecha = vfecha_hoy
         WHERE empresa = pempresa
           AND proceso = 'inicio_histmovcheq';
    END IF;
	
	SELECT valor 
      INTO vcuenta_fin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniRepHisChqComp1';
    
    
    LET vfecha = TO_CHAR(vfecha_ant, '%d%m%Y');
    
    -- // DESCARGA MOVIMIENTOS POS - BANCO
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_POS7_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.num_cte, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector), '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector), '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bdicheq:sc_maechq mae ON ( mov.empresa = mae.empresa AND mov.cuenta = mae.cuenta ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.num_cte ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN("0952", "0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.transacc in(''0801'', ''0952'', ''0479'') and mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'' ' ||
			   'AND mov.cuenta < '''||vcuenta_fin||''';" > /resplogifx/conciliachq/histmovcheq_POS7.sql';

	SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheq_POS7.sql"; 
    SYSTEM vstmt;
    
    
    LET vsql = '';
    LET vstmt = '';
/*    
    -- // DESCARGA MOVIMIENTOS POS - TRANSFER
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_transfer_POS_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.numcte_tf, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(pro.c_sector) END, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(pro.a_sector) END, '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bditransfer:tf_maecte mae ON ( mov.cuenta = mae.cuenta_tf ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
               'LEFT OUTER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN("0952", "0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.transacc in(''0801'', ''0952'', ''0479'') and mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'';" > /resplogifx/conciliachq/histmovcheqtrf_POS.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheqtrf_POS.sql"; 
    SYSTEM vstmt;
    
    
    -- // DESCARGA MOVIMIENTOS TRANSFER
    LET vsql = '';
    LET vstmt = '';
    
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_transfer_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.numcte_tf, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(pro.c_sector) END, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(pro.a_sector) END, '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bditransfer:tf_maecte mae ON ( mov.cuenta = mae.cuenta_tf ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
               'LEFT OUTER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN ("0800","0871","0873","0890","0893","0952","0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'';" > /resplogifx/conciliachq/histmovcheqtrf.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheqtrf.sql"; 
	
	
    SYSTEM vstmt;
    LET vstmt = '';
*/
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;