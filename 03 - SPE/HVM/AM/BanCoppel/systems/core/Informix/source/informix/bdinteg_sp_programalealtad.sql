CREATE PROCEDURE "informix".sp_programalealtad( pEmpresa char(3) )
RETURNING CHAR(5);
    
    DEFINE cCodRet              CHAR(5);
    DEFINE cCodRet2             CHAR(5);
    DEFINE cCodRet3             CHAR(50);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE iDesErr              CHAR(50);
    DEFINE dFechaHoy            DATE;
    DEFINE dFechaAnt            DATE;
    DEFINE dPri_Dia_Mes         DATE;
    DEFINE dPriHabMes           DATE;
    DEFINE dPriDiaMes           DATE;
    DEFINE dUltDiaMes           DATE;
    DEFINE dPriDiaMesAnt        DATE;
    DEFINE dUltDiaMesAnt        DATE;
    DEFINE cFechConMovHis       DATE;
    DEFINE cFechConMovHisOld    DATE;
    DEFINE cNumCte              CHAR(20);
    DEFINE cSucursalCte         CHAR(4);
    DEFINE cNombreSuc           CHAR(40);
    DEFINE cNombre1             CHAR(26);
    DEFINE cNombre2             CHAR(26);
    DEFINE cApellPat            CHAR(26);
    DEFINE cApellMat            CHAR(26);
    DEFINE dFechaNac            DATE;
    DEFINE cRfc                 CHAR(13);
    DEFINE cCodPos              CHAR(5);
    DEFINE cMail                CHAR(100);
    DEFINE cTelCasa             CHAR(15);
    DEFINE cTelCelular          CHAR(15);
    DEFINE cTelOficina          CHAR(15);
    DEFINE cCuenta              CHAR(20);
    DEFINE cSucursalCta         CHAR(4);
    DEFINE cTarjeta             CHAR(16);
    DEFINE cTipoTarj            CHAR(3);
    DEFINE cStatusTrj           CHAR(3);
    DEFINE dFechExpira          DATE;
    DEFINE cTipoTrj             CHAR(1);
    DEFINE dFechAsig            DATE;
    DEFINE mSdoCuenta           DECIMAL(14,2);
    DEFINE cTipoTrjCte          CHAR(1);
    DEFINE cStatusCta           CHAR(2);
    DEFINE dFechUltCompra       DATE;
    DEFINE dFechUltCompra1      DATE;
    DEFINE dFechUltCompra2      DATE;
    DEFINE iNoCompras           INTEGER;
    DEFINE iNoCompras1          INTEGER;
    DEFINE iNoCompras2          INTEGER;
    DEFINE mMtoCompras          DECIMAL(18,2);
    DEFINE mMtoCompras1         DECIMAL(18,2);
    DEFINE mMtoCompras2         DECIMAL(18,2);
    DEFINE cSucursal            CHAR(4);
    DEFINE iNoCuentas           INTEGER;
    DEFINE mSdoCuentas          DECIMAL(18,2);
    DEFINE mMontoCompras        DECIMAL(18,2);
    DEFINE mSdoPromCtas         DECIMAL(18,2);
    DEFINE cFechaDesc           CHAR(8);
    DEFINE cAnioMesDesc         CHAR(6);
    DEFINE vsql                 CHAR(600);
    DEFINE mCarteraTot          DECIMAL(18,2);
    DEFINE mCarteraVig          DECIMAL(18,2);
    DEFINE mCarteraVenc         DECIMAL(18,2);
    DEFINE iCredsNunca          INTEGER;
    DEFINE iCredsInact          INTEGER;
    DEFINE cStatusCuenta        CHAR(20);
    DEFINE iNoComprasAnt        INTEGER;
    DEFINE mMtoComprasAnt       DECIMAL(18,2);
    
    LET cCodRet = '000';               
    LET cCodRet2 = '000';
    LET cCodRet3 = 'PROCESO FINALIZADO';
    LET iSqlErr = 0;                   
    LET iSamErr = 0;
    LET iDesErr = '';              
    LET dFechaHoy = '';
    LET dFechaAnt = '';  
    LET dPri_Dia_Mes = '';
    LET dPriHabMes = '';
    LET dPriDiaMes = '';  
    LET dUltDiaMes = '';  
    LET dPriDiaMesAnt = '';
    LET dUltDiaMesAnt = '';  
    LET cFechConMovHis = '';  
    LET cFechConMovHisOld = '';  
    LET cNumCte = '';
    LET cSucursalCte = '';
    LET cNombreSuc = '';
    LET cNombre1 = '';
    LET cNombre2 = '';
    LET cApellPat = '';
    LET cApellMat = '';
    LET dFechaNac = '';
    LET cRfc = '';
    LET cCodPos = '';
    LET cMail = '';
    LET cTelCasa = '';
    LET cTelCelular = '';
    LET cTelOficina = '';
    LET cSucursalCta = '';
    LET cCuenta = '';
    LET cTarjeta = '';
    LET cTipoTarj = '';
    LET cStatusTrj = '';
    LET dFechExpira = '';
    LET cTipoTrj = '';
    LET dFechAsig = '';
    LET mSdoCuenta = 0.00;
    LET cTipoTrjCte = '';
    LET cStatusCta = '';
    LET dFechUltCompra = '';
    LET dFechUltCompra1 = '';
    LET dFechUltCompra2 = '';
    LET iNoCompras = 0;
    LET iNoCompras1 = 0;
    LET iNoCompras2 = 0;
    LET mMtoCompras = 0.00;
    LET mMtoCompras1 = 0.00;
    LET mMtoCompras2 = 0.00;
    LET cSucursal = '';
    LET iNoCuentas = 0;
    LET mSdoCuentas = 0.00;
    LET mMontoCompras = 0.00;
    LET mSdoPromCtas = 0.00;
    LET cFechaDesc = '';
    LET cAnioMesDesc = '';
    LET vsql = '';
    LET mCarteraTot = 0.00;
    LET mCarteraVig = 0.00;
    LET mCarteraVenc = 0.00;
    LET iCredsNunca = 0;
    LET iCredsInact = 0;
    LET cStatusCuenta = '';
    LET iNoComprasAnt = 0;
    LET mMtoComprasAnt = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_programalealtad.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_programalealtad.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS A UTILIZAR
    SELECT fecha_hoy, fecha_ant, pri_dia_mes, pri_hab_mes
      INTO dFechaHoy, dFechaAnt, dPri_Dia_Mes, dPriHabMes 
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
    
    -- // PARAMETROS PARA LAS CONSULTAS DE MOVIMIENTOS HISTORICOS
    SELECT valor 
      INTO cFechConMovHis
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
    
    SELECT valor 
      INTO cFechConMovHisOld
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    TRUNCATE TABLE si_lealtad_clientes;
    TRUNCATE TABLE si_lealtad_tarjetas;
    --IFRS Se contemplan los nuevos estatus de crÃ©dito por etapas
    SELECT mae.num_cte AS numcte
      FROM bdicheq:sc_maechq mae
     INNER JOIN bdicheq:sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta AND noc.fecha_alta = dFechaAnt )
     INNER JOIN bdicheq:sc_tarjeta tar ON ( tar.cuenta = mae.cuenta AND tar.tipo_tarjeta IN('T','A') AND tar.status_tar = 'A' )
     INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
     INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.num_cte )
     INNER JOIN bdinteg:si_ctepf pf ON ( pf.numcte = cte.numcte )
     INNER JOIN bdinteg:si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = '1' )
     INNER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado AND edo.estado = '13' )
     WHERE mae.producto NOT IN('1100','1500','1800')
       AND ( mae.fecha_proceso >= dFechaHoy OR mae.status_cta IN('1','3','4','5') )      
    UNION
    SELECT mae.numcte AS numcte
      FROM bdicred:sd_maecred mae 
     INNER JOIN bdicred:sd_tarjeta tar ON ( tar.num_credito = mae.num_credito AND tar.tipo_tarjeta IN('T','A') AND tar.status_tar = 'A' )
     INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
     INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte )
     INNER JOIN bdinteg:si_ctepf pf ON ( pf.numcte = cte.numcte )
     INNER JOIN bdinteg:si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = '1' )
     INNER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado AND edo.estado = '13' )
     WHERE mae.fecha_apertura = dFechaAnt
	 AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
	 --AND mae.status_cred IN('AA','BA','BT')
       AND mae.num_producto = '6001' 
    INTO TEMP tmp_ctes_hidalgo WITH NO LOG;
    CREATE INDEX idxtmp_ctehidalgo_cte ON tmp_ctes_hidalgo(numcte) ONLINE;
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctes_hidalgo;
    
    SELECT UNIQUE numcte
      FROM tmp_ctes_hidalgo
     WHERE numcte >= '000001001'
    INTO TEMP tmp_clientes_hidalgo WITH NO LOG;
    CREATE INDEX idxtmp_clientehidalgo_cte ON tmp_clientes_hidalgo(numcte) ONLINE;
    UPDATE STATISTICS HIGH FOR TABLE tmp_clientes_hidalgo;
    
    FOREACH
        SELECT numcte 
          INTO cNumCte
          FROM tmp_clientes_hidalgo
         WHERE numcte >= '000001001'
        
        SELECT cte.sucursal, TRIM(suc.nombre), NVL(TRIM(cte.nombre1),''), NVL(TRIM(cte.nombre2),''), NVL(TRIM(cte.apell_paterno),''), NVL(TRIM(cte.apell_materno),''), pef.fecha_nac,
               NVL(TRIM(cte.rfc),''), NVL(dir.cod_postal,''), NVL(TRIM(mail.correo_elec),''), NVL(TRIM(tel1.telefono),''), NVL(TRIM(tel2.telefono),''), NVL(TRIM(tel3.telefono),'') 
          INTO cSucursalCte, cNombreSuc, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cCodPos, cMail, cTelCasa, cTelCelular, cTelOficina
          FROM bdinteg:si_cliente cte 
         INNER JOIN bdinteg:si_ctepf pef on ( pef.numcte = cte.numcte )
         INNER JOIN bdinteg:si_sucursales suc on ( suc.sucursal = cte.sucursal )
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir on ( dir.numcte = cte.numcte and dir.tipo_dir = '1' )
          LEFT OUTER JOIN bdinteg:si_correos mail on ( mail.numcte = cte.numcte and mail.tipo_correo = 1 and mail.status_correo = 'A' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 on ( tel1.numcte = cte.numcte and tel1.tipo_tel = 1 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 on ( tel2.numcte = cte.numcte and tel2.tipo_tel = 2 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 on ( tel3.numcte = cte.numcte and tel3.tipo_tel = 3 )
         WHERE cte.numcte = cNumCte;
         
        INSERT INTO si_lealtad_clientes VALUES 
        ( dFechaAnt, cSucursalCte, cNombreSuc, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cCodPos, cMail, cTelCasa, cTelCelular, cTelOficina );
        
        -- // TARJETAS DE DEBITO
        FOREACH 
            SELECT mae.cuenta, cte.sucursal, tar.num_tarjeta, 'TDD', trj.codstatustarjeta, NVL(tar.expiracion,''), tar.tipo_tarjeta, 
                   CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE tar.fecha_insert END
              INTO cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig
              FROM bdicheq:sc_maechq mae
             INNER JOIN bdicheq:sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta AND noc.fecha_alta = dFechaAnt )
             INNER JOIN si_cliente cte ON ( cte.numcte = mae.num_cte )
             INNER JOIN bdicheq:sc_tarjeta tar ON ( tar.cuenta = mae.cuenta AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicheq:sc_tarjeta WHERE cuenta = mae.cuenta AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
             INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
             WHERE mae.num_cte = cNumCte
               AND mae.producto NOT IN('1100','1500','1800')
               AND ( mae.fecha_proceso >= dFechaHoy OR mae.status_cta IN('1','3','4','5') )
              
            INSERT INTO si_lealtad_tarjetas VALUES
            ( dFechaAnt, cNumCte, cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig );
            
            LET cCuenta = ''; LET cSucursalCte = ''; LET cTarjeta = ''; LET cTipoTarj = ''; LET cStatusTrj = ''; LET dFechExpira = ''; LET cTipoTrj = ''; LET dFechAsig = '';
        END FOREACH;
        
        -- // TARJETAS DE CREDITO
        FOREACH 
            SELECT mae.num_credito, cte.sucursal, tar.num_tarjeta, 'TDC', trj.codstatustarjeta, NVL(tar.expiracion,''), tar.tipo_tarjeta, 
                   CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE mae.fecha_apertura END
              INTO cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig
              FROM bdicred:sd_maecred mae
             INNER JOIN si_cliente cte ON ( cte.numcte = mae.numcte )
             INNER JOIN bdicred:sd_tarjeta tar ON ( tar.num_credito = mae.num_credito AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = mae.num_credito AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
             INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
             WHERE mae.numcte = cNumCte
               AND mae.num_producto = '6001'
               AND mae.fecha_apertura = dFechaAnt
			   AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
			 --AND mae.status_cred IN('AA','BA','BT')			   
              
            INSERT INTO si_lealtad_tarjetas VALUES
            ( dFechaAnt, cNumCte, cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig );
            
            LET cCuenta = ''; LET cSucursalCte = ''; LET cTarjeta = ''; LET cTipoTarj = ''; LET cStatusTrj = ''; LET dFechExpira = ''; LET cTipoTrj = ''; LET dFechAsig = '';   
        END FOREACH;
        
        LET cNumCte = ''; LET cSucursalCte = ''; LET cNombreSuc = ''; LET cNombre1 = ''; LET cNombre2 = ''; LET cApellPat = ''; LET cApellMat = ''; 
        LET dFechaNac = ''; LET cRfc = ''; LET cCodPos = ''; LET cMail = ''; LET cTelCasa = ''; LET cTelCelular = ''; LET cTelOficina = ''; 
    END FOREACH;
    
    UPDATE STATISTICS HIGH FOR TABLE si_lealtad_clientes;
    UPDATE STATISTICS HIGH FOR TABLE si_lealtad_tarjetas;
    
    LET cFechaDesc = TO_CHAR(dFechaAnt, '%d%m%Y');
    
    -- // CLIENTES HIDALGO
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CLIENTE_HIDALGO_DIARIO_'||cFechaDesc||'.txt '||
               'SELECT sucursal, TRIM(nombre_suc), TRIM(numcte), TRIM(nombre1_cte), TRIM(nombre2_cte), TRIM(apepat_cte), TRIM(apemat_cte), fecha_nac, TRIM(rfc), codpos, TRIM(mail), TRIM(tel_casa), TRIM(tel_movil), TRIM(tel_oficina) '||
               'FROM si_lealtad_clientes;" > /resplogifx/conciliachq/cteshidalgo.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/cteshidalgo.sql"; 
    SYSTEM vsql;
    
    -- // TARJETAS HIDALGO
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/TARJETAS_HIDALGO_DIARIO_'||cFechaDesc||'.txt '||
               'SELECT TRIM(numcte), TRIM(tpo_tarjeta), SUBSTR(num_tarjeta, LENGTH(num_tarjeta) -3, 4) '||
               'FROM si_lealtad_tarjetas;" > /resplogifx/conciliachq/tarjshidalgo.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/tarjshidalgo.sql";
    SYSTEM vsql;
    
    -- // PROCESO HISTORICO - PRIMER DIA HABIL DE CADA MES
    IF dFechaHoy = dPriHabMes THEN
            
        TRUNCATE TABLE si_lealtad_clientes;
        TRUNCATE TABLE si_lealtad_tarjetas;
        TRUNCATE TABLE si_lealtad_cuentas;
        TRUNCATE TABLE si_lealtad_seguim_tdd;
        TRUNCATE TABLE si_lealtad_seguim_tdc;
        
        DROP TABLE tmp_ctes_hidalgo;
        DROP TABLE tmp_clientes_hidalgo;
    
        SELECT mae.num_cte AS numcte
          FROM bdicheq:sc_maechq mae
         INNER JOIN bdicheq:sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta AND noc.fecha_alta <= dFechaAnt )
         INNER JOIN bdicheq:sc_tarjeta tar ON ( tar.cuenta = mae.cuenta AND tar.tipo_tarjeta IN('T','A') AND tar.status_tar = 'A' )
         INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
         INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.num_cte )
         INNER JOIN bdinteg:si_ctepf pf ON ( pf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = '1' )
         INNER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado AND edo.estado = '13' )
         WHERE mae.producto NOT IN('1100','1500','1800')
           AND ( mae.fecha_proceso >= dFechaHoy OR mae.status_cta IN('1','3','4','5') )      
        UNION
        SELECT mae.numcte AS numcte
          FROM bdicred:sd_maecred mae 
         INNER JOIN bdicred:sd_tarjeta tar ON ( tar.num_credito = mae.num_credito AND tar.tipo_tarjeta IN('T','A') AND tar.status_tar = 'A' )
         INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
         INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte )
         INNER JOIN bdinteg:si_ctepf pf ON ( pf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = '1' )
         INNER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado AND edo.estado = '13' )
         WHERE mae.fecha_apertura <= dFechaAnt
			AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
          -- AND mae.status_cred IN('AA','BA','BT')
           AND mae.num_producto = '6001' 
        INTO TEMP tmp_ctes_hidalgo WITH NO LOG;
        CREATE INDEX idxtmp_ctehidalgo_cte ON tmp_ctes_hidalgo(numcte) ONLINE;
        UPDATE STATISTICS HIGH FOR TABLE tmp_ctes_hidalgo;
        
        SELECT UNIQUE numcte
          FROM tmp_ctes_hidalgo
         WHERE numcte >= '000001001'
        INTO TEMP tmp_clientes_hidalgo WITH NO LOG;
        CREATE INDEX idxtmp_clientehidalgo_cte ON tmp_clientes_hidalgo(numcte) ONLINE;
        UPDATE STATISTICS HIGH FOR TABLE tmp_clientes_hidalgo;
        
        FOREACH
            SELECT numcte 
              INTO cNumCte
              FROM tmp_clientes_hidalgo
             WHERE numcte >= '000001001'
            
            SELECT cte.sucursal, TRIM(suc.nombre), NVL(TRIM(cte.nombre1),''), NVL(TRIM(cte.nombre2),''), NVL(TRIM(cte.apell_paterno),''), NVL(TRIM(cte.apell_materno),''), pef.fecha_nac,
                   NVL(TRIM(cte.rfc),''), NVL(dir.cod_postal,''), NVL(TRIM(mail.correo_elec),''), NVL(TRIM(tel1.telefono),''), NVL(TRIM(tel2.telefono),''), NVL(TRIM(tel3.telefono),'') 
              INTO cSucursalCte, cNombreSuc, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cCodPos, cMail, cTelCasa, cTelCelular, cTelOficina
              FROM bdinteg:si_cliente cte 
             INNER JOIN bdinteg:si_ctepf pef on ( pef.numcte = cte.numcte )
             INNER JOIN bdinteg:si_sucursales suc on ( suc.sucursal = cte.sucursal )
              LEFT OUTER JOIN bdinteg:si_direcciones_actual dir on ( dir.numcte = cte.numcte and dir.tipo_dir = '1' )
              LEFT OUTER JOIN bdinteg:si_correos mail on ( mail.numcte = cte.numcte and mail.tipo_correo = 1 and mail.status_correo = 'A' )
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 on ( tel1.numcte = cte.numcte and tel1.tipo_tel = 1 )
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 on ( tel2.numcte = cte.numcte and tel2.tipo_tel = 2 )
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 on ( tel3.numcte = cte.numcte and tel3.tipo_tel = 3 )
             WHERE cte.numcte = cNumCte;
             
            INSERT INTO si_lealtad_clientes VALUES 
            ( dFechaAnt, cSucursalCte, cNombreSuc, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cCodPos, cMail, cTelCasa, cTelCelular, cTelOficina );
            
            -- // TARJETAS DE DEBITO
            FOREACH 
                SELECT mae.cuenta, cte.sucursal, tar.num_tarjeta, 'TDD', trj.codstatustarjeta, NVL(tar.expiracion,''), tar.tipo_tarjeta, 
                       CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE tar.fecha_insert END
                  INTO cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig
                  FROM bdicheq:sc_maechq mae
                 INNER JOIN bdicheq:sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta AND noc.fecha_alta <= dFechaAnt )
                 INNER JOIN si_cliente cte ON ( cte.numcte = mae.num_cte )
                 INNER JOIN bdicheq:sc_tarjeta tar ON ( tar.cuenta = mae.cuenta AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicheq:sc_tarjeta WHERE cuenta = mae.cuenta AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
                 INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
                 WHERE mae.num_cte = cNumCte
                   AND mae.producto NOT IN('1100','1500','1800')
                   AND ( mae.fecha_proceso >= dFechaHoy OR mae.status_cta IN('1','3','4','5') )
                  
                INSERT INTO si_lealtad_tarjetas VALUES
                ( dFechaAnt, cNumCte, cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig );
                
                LET cSucursalCte = ''; 
                LET cCuenta = ''; 
                LET cTarjeta = ''; 
                LET cTipoTarj = ''; 
                LET cStatusTrj = ''; 
                LET dFechExpira = ''; 
                LET cTipoTrj = ''; 
                LET dFechAsig = '';
            END FOREACH;
            
            -- // TARJETAS DE CREDITO
            FOREACH 
                SELECT mae.num_credito, cte.sucursal, tar.num_tarjeta, 'TDC', trj.codstatustarjeta, NVL(tar.expiracion,''), tar.tipo_tarjeta, 
                       CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE mae.fecha_apertura END
                  INTO cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig
                  FROM bdicred:sd_maecred mae
                 INNER JOIN si_cliente cte ON ( cte.numcte = mae.numcte )
                 INNER JOIN bdicred:sd_tarjeta tar ON ( tar.num_credito = mae.num_credito AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = mae.num_credito AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
                 INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
                 WHERE mae.numcte = cNumCte
                   AND mae.num_producto = '6001'
                   AND mae.fecha_apertura <= dFechaAnt
				 AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
				 --AND mae.status_cred IN('AA','BA','BT')
                  
                INSERT INTO si_lealtad_tarjetas VALUES
                ( dFechaAnt, cNumCte, cCuenta, cSucursalCte, cTarjeta, cTipoTarj, cStatusTrj, dFechExpira, cTipoTrj, dFechAsig );
                
                LET cSucursalCte = ''; 
                LET cCuenta = ''; 
                LET cTarjeta = ''; 
                LET cTipoTarj = ''; 
                LET cStatusTrj = ''; 
                LET dFechExpira = ''; 
                LET cTipoTrj = ''; 
                LET dFechAsig = '';
            END FOREACH;
            
            LET cSucursalCte = ''; 
            LET cNombreSuc = ''; 
            LET cNombre1 = ''; 
            LET cNombre2 = ''; 
            LET cApellPat = ''; 
            LET cApellMat = ''; 
            LET dFechaNac = '';
            LET cRfc = ''; 
            LET cCodPos = ''; 
            LET cMail = ''; 
            LET cTelCasa = ''; 
            LET cTelCelular = ''; 
            LET cTelOficina = ''; 
            LET cNumCte = '';
        END FOREACH;
        
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_clientes;
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_tarjetas;
        
        LET dPriDiaMes = dPri_Dia_Mes - 1 UNITS MONTH;
        LET dUltDiaMes = dPri_Dia_Mes - 1 UNITS DAY;
        LET dPriDiaMesAnt = dPri_Dia_Mes - 2 UNITS MONTH;
        LET dUltDiaMesAnt = dPriDiaMes - 1 UNITS DAY;
        
        -- // CUENTAS DE DEBITO
        FOREACH
            SELECT tmp.numcte, cte.sucursal, mae.cuenta, trj.codstatustarjeta, tar.expiracion, mae.sdo_actual, tar.num_tarjeta, 'TDD', tar.tipo_tarjeta, 
                   CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE tar.fecha_insert END, mae.status_cta
              INTO cNumCte, cSucursalCte, cCuenta, cStatusTrj, dFechExpira, mSdoCuenta, cTarjeta, cTipoTrj, cTipoTrjCte, dFechAsig, cStatusCta
              FROM tmp_clientes_hidalgo tmp
             INNER JOIN si_cliente cte ON ( cte.numcte = tmp.numcte )
             INNER JOIN bdicheq:sc_maechq mae ON ( cte.numcte = mae.num_cte AND mae.producto NOT IN('1100','1500','1800') AND ( mae.fecha_proceso >= dFechaHoy OR mae.status_cta IN('1','3','4','5') ) )
             INNER JOIN bdicheq:sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta AND noc.fecha_alta <= dFechaAnt )
             INNER JOIN bdicheq:sc_tarjeta tar ON ( tar.cuenta = mae.cuenta AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicheq:sc_tarjeta WHERE cuenta = mae.cuenta AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
             INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
             WHERE tmp.numcte >= '000001001'
            
            -- // OBTIENE LA FECHA MAS RECIENTE DE COMPRA
            SELECT NVL(MAX(fech_alt),'01/01/1900')
              INTO dFechUltCompra1
              FROM bdicheq:sc_movhis 
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt BETWEEN dPriDiaMes AND dUltDiaMes
               AND fech_alt >= cFechConMovHis
               AND cancelad <> 'S'
               AND transacc in('0830','0887');
               
            SELECT NVL(MAX(fech_alt),'01/01/1900')
              INTO dFechUltCompra2
              FROM bdicheq:sc_movhis_old 
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt BETWEEN dPriDiaMes AND dUltDiaMes
               AND fech_alt >= cFechConMovHisOld
               AND fech_alt < cFechConMovHis
               AND cancelad <> 'S'
               AND transacc in('0830','0887');
               
            IF dFechUltCompra1 >= dFechUltCompra2 THEN
                LET dFechUltCompra = dFechUltCompra1;
            ELSE
                LET dFechUltCompra = dFechUltCompra2;
            END IF;
            
            IF dFechUltCompra = '01/01/1900' THEN
                LET dFechUltCompra = '';
            END IF;
                  
            -- // OBTIENE EL NUMERO Y MONTO DE LAS COMPRAS REALIZADAS DURANTE EL MES ANTERIOR
            SELECT COUNT(*), NVL(SUM(monto_tot),0.00)
              INTO iNoCompras1, mMtoCompras1
              FROM bdicheq:sc_movhis 
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt BETWEEN dPriDiaMes AND dUltDiaMes
               AND fech_alt >= cFechConMovHis
               AND cancelad <> 'S'
               AND transacc in('0830','0887');
               
            SELECT COUNT(*), NVL(SUM(monto_tot),0.00)
              INTO iNoCompras2, mMtoCompras2
              FROM bdicheq:sc_movhis_old 
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt BETWEEN dPriDiaMes AND dUltDiaMes
               AND fech_alt >= cFechConMovHisOld
               AND fech_alt < cFechConMovHis
               AND cancelad <> 'S'
               AND transacc in('0830','0887');
               
            LET iNoCompras = iNoCompras1 + iNoCompras2;
            LET mMtoCompras = mMtoCompras1 + mMtoCompras2;
            
            -- // OBTIENE EL NUMERO Y MONTO DE LAS COMPRAS REALIZADAS DURANTE EL MES ANTERIOR-ANTERIOR
            SELECT COUNT(*), NVL(SUM(monto_tot),0.00)
              INTO iNoComprasAnt, mMtoComprasAnt
              FROM bdicheq:sc_movhis_old 
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt BETWEEN dPriDiaMesAnt AND dUltDiaMesAnt
               AND fech_alt >= cFechConMovHisOld
               AND fech_alt < cFechConMovHis
               AND cancelad <> 'S'
               AND transacc in('0830','0887');
            
            -- // DETERMINA EL ESTATUS DE LA CUENTA
            IF   cStatusCta = '1' THEN 
                LET cStatusCuenta = 'ACTIVA';
            ELIF cStatusCta = '3' THEN 
                LET cStatusCuenta = 'BLOQUEADA';
            ELIF cStatusCta = '4' THEN 
                LET cStatusCuenta = 'INACTIVA';
            ELIF cStatusCta = '5' THEN 
                LET cStatusCuenta = 'INFORMADA';
            END IF;
            
            INSERT INTO si_lealtad_cuentas VALUES
            ( dFechaAnt, cSucursalCte, cNumCte, cCuenta, cStatusCuenta, cTarjeta, cTipoTrjCte, cTipoTrj, dFechAsig, 
              cStatusTrj, dFechExpira, dFechUltCompra, mSdoCuenta, iNoCompras, mMtoCompras, iNoComprasAnt, mMtoComprasAnt );    
              
            LET cSucursalCte = ''; 
            LET cCuenta = ''; 
            LET cStatusTrj = ''; 
            LET dFechExpira = ''; 
            LET mSdoCuenta = 0.00; 
            LET cTarjeta = ''; 
            LET cTipoTrj = '';
            LET cTipoTrjCte = ''; 
            LET dFechAsig = ''; 
            LET cStatusCta = ''; 
            LET dFechUltCompra = ''; 
            LET dFechUltCompra1 = ''; 
            LET dFechUltCompra2 = '';
            LET iNoCompras = 0; 
            LET iNoCompras1 = 0; 
            LET iNoCompras2 = 0; 
            LET mMtoCompras = 0.00; 
            LET mMtoCompras1 = 0.00; 
            LET mMtoCompras2 = 0.00;
            LET cStatusCuenta = ''; 
            LET iNoComprasAnt = 0; 
            LET mMtoComprasAnt = 0.00;
        END FOREACH;
        
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_cuentas;
        
        -- // SEGUIMIENTO AL PROGRAMA DE LEALTAD DE TDD
        FOREACH
            SELECT cta.sucursal, suc.nombre, COUNT(*), ROUND(SUM(cta.sdo_cuenta),2), ROUND(SUM(cta.no_compras),2), ROUND(SUM(cta.monto_compras),2)
              INTO cSucursal, cNombreSuc, iNoCuentas, mSdoCuentas, iNoCompras, mMontoCompras
              FROM si_lealtad_cuentas cta,
                   si_sucursales suc
             WHERE cta.sucursal = suc.sucursal
               AND cta.cuenta NOT LIKE '6%'
             GROUP BY 1, 2
             
            LET mSdoPromCtas = ROUND((mSdoCuentas/iNoCuentas),2);
             
            INSERT INTO si_lealtad_seguim_tdd VALUES
            ( dFechaAnt, cSucursal, cNombreSuc, mSdoPromCtas, iNoCuentas, iNoCompras, mMontoCompras );
            
            LET cSucursal = ''; 
            LET cNombreSuc = ''; 
            LET iNoCuentas = 0; 
            LET mSdoCuentas = 0.00; 
            LET iNoCompras = 0; 
            LET mMontoCompras = 0.00; 
            LET mSdoPromCtas = 0.00;
        END FOREACH;
        
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_seguim_tdd;
        
        -- // CUENTAS DE CREDITO
        FOREACH
            SELECT tmp.numcte, cte.sucursal, mae.num_credito, trj.codstatustarjeta, tar.expiracion, 
                   CASE WHEN (mae.status_cred = 'AA' OR (mae.status_cred = 'E1' AND sdo.monto_vencido=0) )THEN sdo.sdo_cap_insoluto WHEN (mae.status_cred IN('BA','BT') OR (mae.status_cred IN( 'E1','E2','E3')  AND sdo.monto_vencido>0) )THEN sdo.monto_vencido + sdo.mto_venc_trasp ELSE 0.00 END,
                   tar.num_tarjeta, 'TDC', tar.tipo_tarjeta, CASE WHEN trj.fechaasignacion is not null THEN trj.fechaasignacion::date ELSE mae.fecha_apertura END, mae.status_cred
              INTO cNumCte, cSucursalCte, cCuenta, cStatusTrj, dFechExpira, mSdoCuenta, cTarjeta, cTipoTrj, cTipoTrjCte, dFechAsig, cStatusCta
              FROM tmp_clientes_hidalgo tmp
             INNER JOIN si_cliente cte ON ( cte.numcte = tmp.numcte )
             INNER JOIN bdicred:sd_maecred mae ON ( mae.numcte = cte.numcte AND mae.num_producto = '6001' AND mae.fecha_apertura <= dFechaAnt AND mae.status_cred IN('AA','BA','BT','E1','E2','E3') )
			 --INNER JOIN bdicred:sd_maecred mae ON ( mae.numcte = cte.numcte AND mae.num_producto = '6001' AND mae.fecha_apertura <= dFechaAnt AND mae.status_cred IN('AA','BA','BT') )
             INNER JOIN bdicred:sd_maecredcont crd ON ( crd.empresa = mae.empresa AND crd.num_credito = mae.num_credito AND crd.fecha = dUltDiaMes )
             INNER JOIN bdicred:sd_maesdoscont sdo ON ( sdo.empresa = mae.empresa AND sdo.num_credito = mae.num_credito AND sdo.fecha = dUltDiaMes )
             INNER JOIN bdicred:sd_tarjeta tar ON ( tar.num_credito = mae.num_credito AND tar.tipo_tarjeta in('T','A') AND tar.status_tar = 'A' AND tar.secuencia = ( SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = mae.num_credito AND tipo_tarjeta = tar.tipo_tarjeta AND status_tar = tar.status_tar ) )
             INNER JOIN intercard:tarjeta trj ON ( trj.numtarjeta = tar.num_tarjeta )
             WHERE tmp.numcte >= '000001001'
            
            -- // OBTIENE LA FECHA MAS RECIENTE DE COMPRA
            SELECT NVL(MAX(fecha_mov),'')
              INTO dFechUltCompra
              FROM bdicred:sd_movhis 
             WHERE empresa = pEmpresa
               AND num_credito = cCuenta
               AND fecha_mov BETWEEN dPriDiaMes AND dUltDiaMes
               AND reversado = 'N'
               AND codigo_fun = '002'
               AND codigo_ref IN (37,57,937,938);
                           
            -- // OBTIENE EL NUMERO Y MONTO DE LAS COMPRAS REALIZADAS DURANTE EL MES ANTERIOR
            SELECT COUNT(*), NVL(SUM(monto),0.00)
              INTO iNoCompras, mMtoCompras
              FROM bdicred:sd_movhis 
             WHERE empresa = pEmpresa
               AND num_credito = cCuenta
               AND fecha_mov BETWEEN dPriDiaMes AND dUltDiaMes
               AND reversado = 'N'
               AND codigo_fun = '002'
               AND codigo_ref IN (37,57,937,938);
               
            -- // OBTIENE EL NUMERO Y MONTO DE LAS COMPRAS REALIZADAS DURANTE EL MES ANTERIOR-ANTERIOR
            SELECT COUNT(*), NVL(SUM(monto),0.00)
              INTO iNoComprasAnt, mMtoComprasAnt
              FROM bdicred:sd_movhis 
             WHERE empresa = pEmpresa
               AND num_credito = cCuenta
               AND fecha_mov BETWEEN dPriDiaMesAnt AND dUltDiaMesAnt
               AND reversado = 'N'
               AND codigo_fun = '002'
               AND codigo_ref IN (37,57,937,938);
            
            -- // DETERMINA EL ESTATUS DE LA CUENTA
			--IF cStatusCta = 'AA' THEN 
            IF cStatusCta = 'AA' THEN 
                LET cStatusCuenta = 'VIGENTE';
            ELIF cStatusCta = 'BA' THEN 
                LET cStatusCuenta = 'TRANSITORIO';
            ELIF cStatusCta = 'BT' THEN 
                LET cStatusCuenta = 'TRASPASADO';
			ELIF cStatusCta= 'E1' THEN
				LET cStatusCuenta = 'ETAPA 1';
			ELIF cStatusCta= 'E2' THEN
				LET cStatusCuenta = 'ETAPA 2';
			ELIF cStatusCta= 'E3' THEN
				LET cStatusCuenta = 'ETAPA 3';
            END IF;
            
            INSERT INTO si_lealtad_cuentas VALUES
            ( dFechaAnt, cSucursalCte, cNumCte, cCuenta, cStatusCuenta, cTarjeta, cTipoTrjCte, cTipoTrj, dFechAsig, 
              cStatusTrj, dFechExpira, dFechUltCompra, mSdoCuenta, iNoCompras, mMtoCompras, iNoComprasAnt, mMtoComprasAnt );    
              
            LET cSucursalCte = ''; 
            LET cCuenta = ''; 
            LET cStatusTrj = ''; 
            LET dFechExpira = ''; 
            LET mSdoCuenta = 0.00; 
            LET cTarjeta = ''; 
            LET cTipoTrj = '';
            LET cTipoTrjCte = ''; 
            LET dFechAsig = ''; 
            LET cStatusCta = ''; 
            LET dFechUltCompra = ''; 
            LET dFechUltCompra1 = ''; 
            LET dFechUltCompra2 = '';
            LET iNoCompras = 0; 
            LET iNoCompras1 = 0; 
            LET iNoCompras2 = 0; 
            LET mMtoCompras = 0.00; 
            LET mMtoCompras1 = 0.00; 
            LET mMtoCompras2 = 0.00;
            LET cStatusCuenta = ''; 
            LET iNoComprasAnt = 0; 
            LET mMtoComprasAnt = 0.00;
        END FOREACH;
        
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_cuentas;
        
        -- // TABLA TEMPORAL DE MOVIMIENTOS DE CREDITO PARA OBTENER LOS CREDITOS INACTIVOS
        SELECT DISTINCT a.num_credito, a.sucursal, a.fecha_mov, a.secuencia, a.monto, a.codigo_fun, a.codigo_ref
          FROM bdicred:sd_movhis a
         WHERE a.empresa = '001'
           AND a.num_credito IN( SELECT cuenta FROM si_lealtad_cuentas WHERE cuenta LIKE '6%' )
           AND a.codigo_fun = '002'
           AND a.codigo_ref IN(37,57,937,938)
           AND a.reversado = 'N'
           AND a.fecha_mov BETWEEN dPriDiaMes AND dUltDiaMes 
        UNION ALL
        SELECT DISTINCT a.num_credito, a.sucursal, a.fecha_mov, a.secuencia, a.monto, a.codigo_fun, a.codigo_ref
          FROM bdicred:sd_movhis a
         WHERE a.empresa = '001'
           AND a.num_credito IN( SELECT cuenta FROM si_lealtad_cuentas WHERE cuenta LIKE '6%' )
           AND a.codigo_fun = '002'
           AND a.codigo_ref IN( 50, 30, 40, 41, 42, 34, 35, 36, 60, 61, 62, 63, 64, 65 )
           AND a.reversado = 'N'
           AND a.fecha_mov BETWEEN dPriDiaMes AND dUltDiaMes 
        UNION ALL
        SELECT DISTINCT a.num_credito, a.sucursal, a.fecha_mov, a.secuencia, a.monto, a.codigo_fun, a.codigo_ref
          FROM bdicred:sd_movhis a
         WHERE a.empresa = '001'
           AND a.num_credito IN( SELECT cuenta FROM si_lealtad_cuentas WHERE cuenta LIKE '6%' )
           AND codigo_fun IN( SELECT cod_fun FROM bdicred:sd_conceptospagomanual )
           AND codigo_ref = 1
           AND a.reversado = 'N'
           AND a.fecha_mov BETWEEN dPriDiaMes AND dUltDiaMes 
        INTO TEMP temp_movs_cred WITH NO LOG;
        CREATE INDEX idxtmp_temp_movs_cred ON temp_movs_cred(num_credito) ONLINE;
        UPDATE STATISTICS HIGH FOR TABLE temp_movs_cred;
        
        -- // TABLA TEMPORAL DE INDICADORES DE CREDITOS NUNCA PARA OBTENER LOS CREDITOS NUNCA
        SELECT num_credito 
          FROM bdicred:sd_indicador_cred
         WHERE empresa = '001'
           AND num_credito IN( SELECT cuenta FROM si_lealtad_cuentas WHERE cuenta LIKE '6%' )
           AND f_primer_compra = mdy(01,01,1900) 
           AND f_primer_disp = mdy(01,01,1900) 
        INTO TEMP temp_creditos_nunca WITH NO LOG;
        CREATE INDEX inx_temp_creditos_nunca ON temp_creditos_nunca(num_credito) ONLINE;
        UPDATE STATISTICS HIGH FOR TABLE temp_creditos_nunca;
        
        -- // SEGUIMIENTO AL PROGRAMA DE LEALTAD DE TDC
        FOREACH
            SELECT cta.sucursal, suc.nombre, COUNT(*), ROUND(SUM(cta.sdo_cuenta),2), ROUND(SUM(cta.no_compras),2), ROUND(SUM(cta.monto_compras),2)
              INTO cSucursal, cNombreSuc, iNoCuentas, mSdoCuentas, iNoCompras, mMontoCompras
              FROM si_lealtad_cuentas cta,
                   si_sucursales suc
             WHERE cta.sucursal = suc.sucursal
               AND cta.cuenta LIKE '6%'
             GROUP BY 1, 2
             --IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas
            SELECT NVL(ROUND(SUM(sdo_cuenta),2),0.00)
              INTO mCarteraTot
              FROM si_lealtad_cuentas
             WHERE sucursal = cSucursal
				AND status_cta IN('AA','BA','BT','E1','E2','E3');
               --AND status_cta IN('AA','BA','BT');
			   
             --IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas
            SELECT NVL(ROUND(SUM(a.sdo_cuenta),2),0.00)
              INTO mCarteraVig
              FROM si_lealtad_cuentas a
			  INNER JOIN bdicred:sd_maesdos sdo ON (a.cuenta = sdo.num_credito)
             WHERE a.sucursal = cSucursal
			   AND a.status_cta IN ('AA','E1')   
			   AND (sdo.monto_vencido + sdo.mto_venc_trasp) = 0;
              -- AND status_cta = 'AA';
               
            SELECT NVL(ROUND(SUM(sdo.sdo_cuenta),2),0.00)
              INTO mCarteraVenc
              FROM si_lealtad_cuentas a
			  INNER JOIN bdicred:sd_maesdos sdo ON (a.cuenta = sdo.num_credito)
             WHERE sucursal = cSucursal
			   AND status_cta IN('BA','BT','E1','E2','E3')
			   AND (sdo.monto_vencido + sdo.mto_venc_trasp) > 0;
               --AND status_cta IN('BA','BT');
               
            SELECT NVL(COUNT(*),0)
              INTO iCredsNunca
              FROM si_lealtad_cuentas
             WHERE sucursal = cSucursal
               AND cuenta LIKE '6%'
               AND cuenta IN( SELECT num_credito FROM temp_creditos_nunca );
             
            SELECT NVL(COUNT(*),0)
              INTO iCredsInact
              FROM si_lealtad_cuentas
             WHERE sucursal = cSucursal
               AND cuenta LIKE '6%'
               AND cuenta NOT IN( SELECT num_credito FROM temp_movs_cred );
             
            INSERT INTO si_lealtad_seguim_tdc VALUES
            ( dFechaAnt, cSucursal, cNombreSuc, mCarteraTot, mCarteraVig, mCarteraVenc, iNoCuentas, iCredsNunca, iCredsInact, mSdoCuentas, iNoCompras, mMontoCompras );
            
            LET cSucursal = ''; 
            LET cNombreSuc = ''; 
            LET iNoCuentas = 0; 
            LET mSdoCuentas = 0.00; 
            LET iNoCompras = 0; 
            LET mMontoCompras = 0.00;
            LET mSdoPromCtas = 0.00; 
            LET mCarteraTot = 0.00; 
            LET mCarteraVig = 0.00; 
            LET mCarteraVenc = 0.00; 
            LET iCredsNunca = 0; 
            LET iCredsInact = 0;
        END FOREACH;
        
        UPDATE STATISTICS HIGH FOR TABLE si_lealtad_seguim_tdc;
        
        LET cAnioMesDesc = TO_CHAR(dUltDiaMes, '%m%Y');
        
        -- // CLIENTES HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CLIENTE_HIDALGO_MENSUAL_'||cAnioMesDesc||'.txt '||
                   'SELECT sucursal, TRIM(nombre_suc), TRIM(numcte), TRIM(nombre1_cte), TRIM(nombre2_cte), TRIM(apepat_cte), TRIM(apemat_cte), fecha_nac, TRIM(rfc), codpos, TRIM(mail), TRIM(tel_casa), TRIM(tel_movil), TRIM(tel_oficina) '||
                   'FROM si_lealtad_clientes;" > /resplogifx/conciliachq/cteshidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/cteshidalgo.sql"; 
        SYSTEM vsql;
        
        -- // TARJETAS HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/TARJETAS_HIDALGO_MENSUAL_'||cAnioMesDesc||'.txt '||
                   'SELECT TRIM(numcte), TRIM(tpo_tarjeta), SUBSTR(num_tarjeta, LENGTH(num_tarjeta) -3, 4) '||
                   'FROM si_lealtad_tarjetas;" > /resplogifx/conciliachq/tarjshidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/tarjshidalgo.sql"; 
        SYSTEM vsql;
        
        -- // CUENTAS HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CUENTAS_HIDALGO_MENSUAL_'||cAnioMesDesc||'.txt '||
                   'SELECT sucursal, TRIM(cuenta), TRIM(status_cta), TRIM(numcte), fecha_activ, TRIM(status_tarj), fecha_venc, fecha_ult_compra, sdo_cuenta, no_compras, monto_compras '||
                   'FROM si_lealtad_cuentas;" > /resplogifx/conciliachq/ctashidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ctashidalgo.sql"; 
        SYSTEM vsql;
        
        -- // SEGUIMIENTO TDC HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/SEGUIMIENTO_PROGRAMA_TDC_'||cAnioMesDesc||'.txt '||
                   'SELECT sucursal, TRIM(nombre_suc), cartera_total, cartera_vigente, cartera_vencida, no_creds_total, no_creds_nunca, no_creds_inactiv, saldo_sucursal, no_compras, monto_compras '||
                   'FROM si_lealtad_seguim_tdc;" > /resplogifx/conciliachq/seguimtdchidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/seguimtdchidalgo.sql"; 
        SYSTEM vsql;
        
        -- // SEGUIMIENTO TDD HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/SEGUIMIENTO_PROGRAMA_TDD_'||cAnioMesDesc||'.txt '||
                   'SELECT sucursal, TRIM(nombre_suc), sdo_promedio, no_cuentas, no_compras, monto_compras '||
                   'FROM si_lealtad_seguim_tdd;" > /resplogifx/conciliachq/seguimtddhidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/seguimtddhidalgo.sql"; 
        SYSTEM vsql;
        
        -- // DETERMINACION DE NIVEL CLIENTES HIDALGO
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/DETERMINACION_NIVEL_'||cAnioMesDesc||'.txt '||
                   'SELECT sucursal, numcte, SUM(no_compras), SUM(no_compras_ant) '||
                   'FROM si_lealtad_cuentas GROUP BY 1, 2;" > /resplogifx/conciliachq/determnivelhidalgo.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/determnivelhidalgo.sql"; 
        SYSTEM vsql;
    
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;