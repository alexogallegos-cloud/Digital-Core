CREATE PROCEDURE "informix".sp_higienedatos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50); 
     
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaHoy        DATE;
    DEFINE vCteMin          CHAR(20);
    DEFINE vCteMax          CHAR(20);
    DEFINE vNumCte          CHAR(20);
    DEFINE vTipoDir         CHAR(1);
    DEFINE vSecuencia       SMALLINT;
    DEFINE vCalle           CHAR(50);
    DEFINE vNumero          CHAR(20);
    DEFINE vColonia         CHAR(50);
    DEFINE vMunicipio       CHAR(50);
    DEFINE vCodPos          CHAR(5);
    DEFINE vCiudad          CHAR(50);
    DEFINE vEstado          CHAR(30);
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCredito      CHAR(20);
    DEFINE vExisteIdent     SMALLINT;
    DEFINE vExisteCompDom   SMALLINT;
    DEFINE vExisteContrato  SMALLINT;
    DEFINE vExistePortada   SMALLINT;
    DEFINE vFecha           CHAR(8);
    DEFINE vsql             CHAR(300);
    DEFINE vstmt            CHAR(100);
    
    LET Sql_Err	        = 0;
    LET Isam_Err        = 0;
    LET Desc_Err        = '';
    LET vCodRet1        = '';
    LET vCodRet2        = '';
    LET vCodRet3        = '';  
    LET vAbierto        = '0';
    LET vFechaHoy       = '';
    LET vCteMin         = '';
    LET vCteMax         = '';
    LET vNumCte         = '';
    LET vTipoDir        = '';
    LET vSecuencia      = 0;
    LET vCalle          = '';
    LET vNumero         = '';
    LET vColonia        = '';
    LET vMunicipio      = '';
    LET vCodPos         = '';
    LET vCiudad         = '';
    LET vEstado         = '';
    LET vCuenta         = '';
    LET vNumCredito     = '';
    LET vExisteIdent    = 0;
    LET vExisteCompDom  = 0;
    LET vExisteContrato = 0;
    LET vExistePortada  = 0;
    LET vFecha          = '';
    LET vsql            = '';
    LET vstmt           = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_higienedatos.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_higienedatos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdinteg:si_fechas
     WHERE empresa = pEmpresa;
     
    SELECT MIN(numcte), MAX(numcte)
      INTO vCteMin, vCteMax
      FROM bdinteg:si_cliente;
    
    FOREACH WITH HOLD
        SELECT FIRST 1000000 numcte
          INTO vNumCte
          FROM bdinteg:si_cliente
         WHERE numcte BETWEEN vCteMin AND vCteMax
           AND tipo_cliente = '1'
           
        BEGIN WORK;
        LET vAbierto = '1';
        
        FOREACH
            SELECT dir.tipo_dir, dir.secuencia, 
                   TRIM(NVL(calle.nombrecalle,  ' ')), 
                   TRIM(NVL(dir.numeroextcalle, ' ')), 
                   TRIM(NVL(zona.nombrezona,    ' ')),
                   TRIM(NVL(zona.municipiozona, ' ')), 
                   TRIM(NVL(dir.cod_postal,     ' ')), 
                   TRIM(NVL(ciu.nombreciudad,   ' ')),
                   TRIM(NVL(edo.nombre,         ' '))
              INTO vTipoDir, vSecuencia, vCalle, vNumero, vColonia, vMunicipio, vCodPos, vCiudad, vEstado
              FROM bdinteg:si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
              LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
              LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
              LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
             WHERE dir.numcte = vNumCte
             
            IF ( vCalle is null     OR vCalle = '' )     OR
               ( vNumero is null    OR vNumero = '' )    OR
               ( vColonia is null   OR vColonia = '' )   OR 
               ( vMunicipio is null OR vMunicipio = '' ) OR
               ( vCodPos is null    OR vCodPos = '' )    OR
               ( vCiudad is null    OR vCiudad = '' )    OR
               ( vEstado is null    OR vEstado = '' )    THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'A la secuencia '||vSecuencia||' de las direcciones del cliente le faltan datos', vFechaHoy);
            END IF;
        END FOREACH;
           
        -- // VERIFICA DOCUMENTOS DIGITALIZADOS - IDENTIFICACIONES
        SELECT COUNT(*)
          INTO vExisteIdent
          FROM bdidigital@coppelimg_tcp:dg_expediente a,
               bdidigital@coppelimg_tcp:dg_tipodocumento b
         WHERE a.cliente = vNumCte
           AND b.cod_docto = a.cod_docto
           AND b.cod_grupo = '001';
        
        IF vExisteIdent = 0 THEN
            INSERT INTO bdinteg:si_documentos_faltantes VALUES
            (vNumCte, 'El cliente no tiene identificaciones digitalizadas', vFechaHoy);
        END IF;
           
        -- // VERIFICA DOCUMENTOS DIGITALIZADOS - COMPROBANTES DOMICILIO
        SELECT COUNT(*)
          INTO vExisteCompDom
          FROM bdidigital@coppelimg_tcp:dg_expediente a,
               bdidigital@coppelimg_tcp:dg_tipodocumento b
         WHERE a.cliente = vNumCte
           AND b.cod_docto = a.cod_docto
           AND b.cod_grupo = '002';
        
        IF vExisteCompDom = 0 THEN
            INSERT INTO bdinteg:si_documentos_faltantes VALUES
            (vNumCte, 'El cliente no tiene comprobantes digitalizados', vFechaHoy);
        END IF;
            
        -- // VERIFICA SI EL CLIENTE TIENE CUENTAS DE CAPTACION
        FOREACH
            SELECT cuenta
              INTO vCuenta
              FROM bdicheq:sc_maechq
             WHERE empresa = pEmpresa
               AND num_cte = vNumCte
               AND status_cta IN('1','3','4','5')
               
            -- // VERIFICA SI LA CUENTA TIENE CONTRATO DIGITALIZADO
            SELECT COUNT(*)
              INTO vExisteContrato
              FROM bdidigital@coppelimg_tcp:dg_expediente
             WHERE cliente = vNumCte
               AND cuenta = vCuenta
               AND cod_docto = '0037';
            
            IF vExisteContrato = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'La cuenta '||TRIM(vCuenta)||' no tiene contrato digitalizado', vFechaHoy);
            END IF;
               
            -- // VERIFICA SI LA CUENTA TIENE PORTADA DIGITALIZADA
            SELECT COUNT(*)
              INTO vExistePortada
              FROM bdidigital@coppelimg_tcp:dg_expediente
             WHERE cliente = vNumCte
               AND cuenta = vCuenta
               AND cod_docto = '0039';
            
            IF vExistePortada = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'La cuenta '||TRIM(vCuenta)||' no tiene portada digitalizada', vFechaHoy);
            END IF;
        END FOREACH;
            
        -- // VERIFICA SI EL CLIENTE TIENE CREDITOS VIGENTES
		--IFRS Se contempla los nuevos estatus por etapas
        FOREACH
            SELECT num_credito
              INTO vNumCredito
              FROM bdicred:sd_maecred
             WHERE numcte = vNumCte
               AND status_cred IN('AA','BA','BT','E1','E2','E3')
               
            -- // VERIFICA SI EL CREDITO TIENE CONTRATO DIGITALIZADO
            SELECT COUNT(*)
              INTO vExisteContrato
              FROM bdidigital@coppelimg_tcp:dg_expediente
             WHERE cliente = vNumCte
               AND cuenta = vNumCredito
               AND cod_docto = '0036';
            
            IF vExisteContrato = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'El credito '||TRIM(vNumCredito)||' no tiene contrato digitalizado', vFechaHoy);
            END IF;
               
            -- // VERIFICA SI EL CREDITO TIENE PORTADA DIGITALIZADA
            SELECT COUNT(*)
              INTO vExistePortada
              FROM bdidigital@coppelimg_tcp:dg_expediente
             WHERE cliente = vNumCte
               AND cuenta = vNumCredito
               AND cod_docto = '0040';
            
            IF vExistePortada = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'El credito '||TRIM(vNumCredito)||' no tiene portada digitalizada', vFechaHoy);
            END IF;
        END FOREACH;
        
        COMMIT WORK;
        LET vAbierto = '0';
    END FOREACH;
    
    LET vFecha = TO_CHAR(vFechaHoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/HigieneDatosClientes_'||vFecha||'.txt '||
               'SELECT numcte, descripcion '||
               'FROM bdinteg:si_documentos_faltantes '||
               'WHERE fecha_con = '''||vFechaHoy||'''; " > /resplogifx/conciliachq/higdatos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/higdatos.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';
    
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3;
    
END PROCEDURE;