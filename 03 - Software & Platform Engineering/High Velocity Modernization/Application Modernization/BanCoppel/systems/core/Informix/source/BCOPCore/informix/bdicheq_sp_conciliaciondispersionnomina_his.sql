CREATE PROCEDURE "informix".sp_conciliaciondispersionnomina_his(pNombreArchivo CHAR(17))
RETURNING CHAR(5),CHAR(18);  
    
    DEFINE v_cCodRet         		CHAR(5);
    DEFINE v_cNumEmpleado    		CHAR(10);
    DEFINE v_cCuentaAbono    		CHAR(20);
    DEFINE v_cNumTarjeta     		CHAR(20);
    DEFINE v_mImporte        		MONEY(18,2);
    DEFINE v_cStatus         		CHAR(1);
    DEFINE v_mComDis         		MONEY(18,2);
    DEFINE v_mIvaDis         		MONEY(18,2);
    DEFINE v_cHoraAplicada   		CHAR(8);
    DEFINE v_cNomArchivo     		CHAR(18);
    DEFINE v_cdirectorio     		CHAR(100);
    DEFINE v_cvsql           		CHAR(600);
    DEFINE vSqlErr           		SMALLINT;
    DEFINE v_iSqlErr         		INTEGER;
    DEFINE cNumeroEmpresa    		CHAR(3);
    DEFINE cFolioDispersion  		CHAR(16);
    DEFINE dFechaAplicado    		Date ;
    DEFINE cHoraAplicado     		DateTime Hour to Second;
    DEFINE cImporteTotalAplicadoCh 	CHAR(19);
    DEFINE cComisionAplicadoCh 		CHAR(19);
    DEFINE cIvaAplicadoCh 			CHAR(19);
    DEFINE sTipoEmpresa   			SMALLINT;
    DEFINE cPunto 					CHAR(1);
    DEFINE cConcepto         		INTEGER;
    
    LET cConcepto  				= 0;
    LET sTipoEmpresa			= 0;
    LET cNumeroEmpresa  		= "";
    LET cFolioDispersion  		= "";
    LET dFechaAplicado  		= '';
    LET cHoraAplicado  			= current;
    LET cImporteTotalAplicadoCh = "";
    LET cComisionAplicadoCh 	= "";
    LET cIvaAplicadoCh 			= "";
    LET v_cCodRet 				= "000";
    LET v_cNumEmpleado 			= "";
    LET v_cCuentaAbono 			= "";
    LET v_cNumTarjeta  			= "";
    LET v_mImporte  			= 0;
    LET v_cStatus 				= "";
    LET v_mComDis 				= 0.00;
    LET v_mIvaDis  				= 0.00;
    LET v_cHoraAplicada 		= "";
    LET v_cNomArchivo  			= "";
    LET v_cdirectorio 			= "";
    LET v_cvsql 				= "";
    LET vSqlErr 				= 0;
    LET v_iSqlErr  				= 0;
    LET cPunto					= "";

    BEGIN
    
    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            LET v_cCodRet  = vSqlErr;
            RETURN  v_cCodRet,v_cNomArchivo; --Se quitaron  los valores de retoorno v_mComDis, v_mIvaDis, v_cHoraAplicada ;
        END IF
    END EXCEPTION
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --- SET DEBUG FILE TO "/tmp/sp_ConciliacionDispersionNomina.out";
    --- TRACE ON;

    IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'sc_tmpconciliacion_nomina') THEN
        DROP TABLE sc_tmpconciliacion_nomina;
    END IF;

    CREATE TABLE sc_tmpconciliacion_nomina
    (
        empleado      CHAR(10), 
        cuenta        CHAR(20), 
        tarjeta       CHAR(20), 
        importe       MONEY, 
        status        CHAR(1), 
        apell_paterno CHAR(26), 
        apell_materno CHAR(26), 
        nombre1       CHAR(26), 
        nombre2       CHAR(26)
    );

    /* Valida que el nombre de archivo  sea correcto */
    LET cPunto = substr(pNombreArchivo, 14, 1);

    /* Valida el parametro de entrada */
    IF Length(pNombreArchivo) <> 17 or cPunto <> '.' THEN  
        LET v_cCodRet = "110"; /* datos insuficientes */
        DROP TABLE sc_tmpconciliacion_nomina;
        RETURN v_cCodRet,v_cNomArchivo;
    END IF;

    /* Obtener los datos para la generacion del archivo */
    /* Se agrego el nombre del cliente */
    INSERT INTO sc_tmpconciliacion_nomina (empleado, cuenta, tarjeta, importe, status, apell_paterno, apell_materno, nombre1, nombre2)
    SELECT nommov.num_empleado, nommov.cuenta_abono, NVL(tar.num_tarjeta, ''), nommov.importe, nommov.status, nvl(cli.apell_paterno, ''), nvl(cli.apell_materno, ''), nvl(cli.nombre1,''), nvl(cli.nombre2,'')
      FROM bdicheq:sc_nominamovimientoshist nommov 
      LEFT outer JOIN bdicheq:sc_maechq chq  ON (chq.cuenta = nommov.cuenta_abono)
      LEFT outer JOIN bdinteg:si_cliente cli ON (cli.numcte = chq.num_cte)
      LEFT outer JOIN bdicheq:sc_tarjeta tar ON (tar.empresa = '001' AND tar.numcte = cli.numcte AND tar.cuenta = nommov.cuenta_abono AND tar.tipo_tarjeta = 'T' AND tar.status_tar = 'A')
     WHERE nombre_archivo = pNombreArchivo;

    /* Generar el nombre de archivo .dat */
    LET v_cNomArchivo = "C" || TRIM(pNombreArchivo);

    /* Generar Archivo Plano */
    LET v_cdirectorio = "/tmp/traspasobanco/archivosnomina/conciliacion/" || TRIM(v_cNomArchivo);
    LET v_cvsql = '';
    LET v_cvsql = 'echo "UNLOAD TO ' || TRIM(v_cdirectorio) ||
                  ' SELECT empleado, cuenta, tarjeta, importe, status, apell_paterno, apell_materno, nombre1, nombre2 FROM sc_tmpconciliacion_nomina;" > /tmp/querydisnom.sql';

    SYSTEM v_cvsql;
    LET v_cvsql = '';
    LET v_cvsql = "/ifxsif01/bin/dbaccess bdicheq /tmp/querydisnom.sql "; /* Produccion, se debe quitar lo comentariado cuando pase a produccion */
    --- LET v_cvsql = "dbaccess bdicheq /tmp/querydisnom.sql "; /* Desarrollo, se debe comentar esta linea al pasar a produccion */
    SYSTEM v_cvsql;
    
    /* Obtener los datos para guardar en la tabla  sc_nominaresultadosdispercionautomatica */
    SELECT {+INDEX(bdicheq:sc_nominaencabezadosumario idx_sc_nomencsum)}
           empresa, folio_dispersion, fecha_aplicado, importe_aplicado, comision, iva
      INTO cNumeroEmpresa, cFolioDispersion, dFechaAplicado, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh
      FROM bdicheq:sc_nominaencabezadosumario
     WHERE nombre_archivo = pNombreArchivo 
       AND status in ("2", "3");

    /* Obtiene el tipo de empresa, para de este establecer si pertenece o no al Grupo Coppel, (interna o externa) */
    SELECT tipo_empresa 
      INTO sTipoEmpresa 
      FROM sc_nominaempresas 
     WHERE codigo = cNumeroEmpresa;
    
    /* OBTENER EL CONCEPTO PARA VALIDARLO */
    SELECT {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos1)}
           LIMIT 1 concepto 
      INTO cConcepto 
      FROM bdicheq:sc_nominamovimientos 
      WHERE nombre_archivo = pNombreArchivo;
    
    /* Valida que el tipo de empresa partenece al Grupo Coppel, y guarda los datos del resultado de la dispersion */
    IF sTipoEmpresa < 3  AND cConcepto <> 5 THEN
        INSERT INTO bdicheq:sc_nominaresultadosdispercionautomatica 
        (Codigo_Retorno, Mensaje, Folio_Dispercion, Importe_Total_Aplicado, Comision_Aplicada, Iva_Aplicado, Nombre_Archivo_Conciliacion, hora_aplicado)
        Values(v_cCodRet,'DispersiÃ³n ejecutada correctamente', cFolioDispersion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, v_cNomArchivo, cHoraAplicado);
    END IF
    
    --- Se implementara hasta que se modiquen los reportes de nomina. 
    /* 
    --- Guarda historial de la  tabla encabezado sumario
    INSERT INTO sc_nominaencabezadosumariohist (empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros,
    importe_tot, status, fecha_insert, importe_aplicado, importe_no_aplicado, folio_acuserecibo, folio_dispersion, iva, comision, fecha_aplicado, hora_aplicado)
    SELECT empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot, status, fecha_insert,
    importe_aplicado, importe_no_aplicado, folio_acuserecibo, folio_dispersion, iva, comision, fecha_aplicado, hora_aplicado
    FROM bdicheq:sc_nominaencabezadosumario WHERE nombre_archivo = pNombreArchivo AND status > 1;

    --- Limpia la tabla base de encabezado sumario
    DELETE FROM bdicheq:sc_nominaencabezadosumario WHERE status > 1;

    --- Guarda historial de la tabla de movimientos
    INSERT INTO sc_nominamovimientoshist (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
    SELECT nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status
    FROM bdicheq:sc_nominamovimientos WHERE nombre_archivo = pNombreArchivo AND status > 0;

    --- Limpia la tabla base de movimientos
    DELETE FROM bdicheq:sc_nominamovimientos WHERE nombre_archivo = pNombreArchivo AND status > 0;
    */
    
    DROP TABLE sc_tmpconciliacion_nomina;
    
    RETURN  v_cCodRet,v_cNomArchivo; /* Se quitaron  los valores de retoorno v_mComDis,   v_mIvaDis, v_cHoraAplicada ; */
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa que genera archivo de conciliacion de Nomina,Gastos,Fondo,Capacitacion',
'EJECUTADO O LLAMADO POR: Dispersion de Nomina Automatica/Manual',
'AUTOR: Armando Mercado Figueroa',
'FECHA: 00/2008',
'BD: BDCHEQ',
'CAMBIOS: Se agrego validacion de status a la tarjeta de cliente',
'AUTOR: Armando Mercado Figueroa',
'Fecha: 15/Enero/2009',

'CAMBIOS: valida que la empresa sea externa para registrar en la tabla de dispersion de nomina automatica ',
'y genera un historial de procesos de movimientos y encabezado',
'Modifico: Cristian Valentina Aguilar, Antonio Bastidas Lopez',
'Fecha: 23/Abril/2009',
'BD: BDCHEQ',

'CAMBIOS: Se modifico la tabla temporal para que reciba el nombre del cliente, para que se guarde en el archivo',
'Modifico: Abraham Ayala Aguilar',
'Fecha: 24/Abril/2009',

'CAMBIOS: Se modifico para que cuando el archivo sea de concepto 5 no se mande a la tabla sc_nominaresultadosdispercionautomatica',
'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Fecha: 14/Octubre/2009',
'BD: BDICHEQ',
'VERSION: 20091014.0630';

CREATE PROCEDURE "informix".borramovsduplicados(pempresa CHAR(3), pfecha DATE)
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsduplicados.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsduplicados.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    select {+index(sc_movhis_old2 idx_movhisnew6_old2)}
           num_serial, count(*) cuantos
      from sc_movhis_old2
     where fech_alt = pfecha
     group by 1
      into temp tmp_serial with no log;
    create index idxtmp_serial on tmp_serial(num_serial) using btree fillfactor 99;
    update statistics medium for table tmp_serial;
      
    select *
      from tmp_serial
     where cuantos > 1
      into temp tmp_movs_dupl with no log;
    create index idxtmp_movs on tmp_movs_dupl(num_serial) using btree fillfactor 99;
    update statistics medium for table tmp_movs_dupl;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT {+index(sc_movhis_old2 idx_movhisnew6_old2)} num_serial
          INTO vnum_serial
          FROM sc_movhis_old2
         WHERE fech_alt = pfecha
           AND num_serial IN(SELECT num_serial FROM tmp_movs_dupl)
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_movhis_old2
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;