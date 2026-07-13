CREATE PROCEDURE "informix".sp_histmovcheqcomp8(pempresa CHAR(3))
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
	DEFINE vcuenta_ini   CHAR(20);
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
	LET vcuenta_ini   = '';
    LET vcuenta_fin   = '';

    
    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheqcomp8.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheqcomp8.out";
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
/*   
    -- // LLAMA AL PROCESO PARA EL RANGO DE CUENTAS
    CALL sp_actparamhistmovchq(pempresa)
    RETURNING vcodretparam;
    
    IF vcodretparam = '000' THEN
        UPDATE sc_contproc
           SET fecha = vfecha_hoy
         WHERE empresa = pempresa
           AND proceso = 'inicio_histmovcheq';
    END IF;
*/	 
	    -- // VALIDA BANDERA DE PROCESAMIENTO
    WHILE vinicio_proceso = 0         
        SELECT COUNT(*)
          INTO vinicio_proceso
          FROM sc_contproc
         WHERE empresa = pempresa 
           AND proceso = 'inicio_histmovcheq'
           AND fecha = vfecha_hoy;
    END WHILE;
    
	SELECT valor 
      INTO vcuenta_ini
      FROM sc_param
     WHERE empresa = pempresa
	   AND codparam = 'CtaIniRepHisChqComp1';
	   
    SELECT valor 
      INTO vcuenta_fin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniRepHisChqComp2';
    
    LET vfecha = TO_CHAR(vfecha_ant, '%d%m%Y');
    
    -- // DESCARGA MOVIMIENTOS POS - BANCO
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_POS8_'||vfecha||'.txt '||
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
			   'AND mov.cuenta >= '''||vcuenta_ini||''' AND mov.cuenta < '''||vcuenta_fin||''';" > /resplogifx/conciliachq/histmovcheq_POS8.sql';
			   
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheq_POS8.sql"; 
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