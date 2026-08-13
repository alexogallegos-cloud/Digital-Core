CREATE PROCEDURE "informix".sp_rptclienteslargos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vComienza        SMALLINT;
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaAnt        DATE;
    DEFINE vFechaHoy        DATE;
    DEFINE vPriDiaMes       DATE;
    DEFINE vUltDiaMesAnt    DATE;
    DEFINE vAnioMes         CHAR(6);
    DEFINE vNumCte          CHAR(20);
    DEFINE vCuenta          CHAR(20);
    DEFINE vSdoProm         DECIMAL(18,2);
    DEFINE vExisteNomiPlus  SMALLINT;
    DEFINE vExisteCredito   SMALLINT;
    DEFINE vExisteOCredito  SMALLINT;
    DEFINE vExisteSolicitud SMALLINT;
    DEFINE vNombre1         CHAR(26);
    DEFINE vNombre2         CHAR(26);
    DEFINE vApellPat        CHAR(26);
    DEFINE vApellMat        CHAR(26);
    DEFINE vCorreo          CHAR(100);
    DEFINE vCalle           CHAR(30);
    DEFINE vNumero          CHAR(10);
    DEFINE vColonia         CHAR(30);
    DEFINE vCiudad          CHAR(60);
    DEFINE vCodPos          CHAR(5);
    DEFINE vEstado          CHAR(30);
    DEFINE vTelCasa         CHAR(13);
    DEFINE vTelMovil        CHAR(13);
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(8);
	
    LET Sql_Err	         = 0;
    LET Isam_Err         = 0;
    LET Desc_Err         = '';
    LET vCodRet1         = '000';
    LET vCodRet2         = '';
    LET vCodRet3         = '';  
    LET vContador1       = 0;
    LET vContador2       = 0;
    LET vComienza        = -1;
    LET vAbierto         = '0';
    LET vFechaAnt        = '';
    LET vFechaHoy        = '';
    LET vPriDiaMes       = '';
    LET vUltDiaMesAnt    = '';
    LET vAnioMes         = '';
    LET vNumCte          = '';
    LET vCuenta          = '';
    LET vSdoProm         = 0.00;
    LET vExisteNomiPlus  = 0;
    LET vExisteCredito   = 0;
    LET vExisteOCredito  = 0;
    LET vExisteSolicitud = 0;
    LET vNombre1         = '';
    LET vNombre2         = '';
    LET vApellPat        = '';
    LET vApellMat        = '';
    LET vCorreo          = '';
    LET vCalle           = '';
    LET vNumero          = '';
    LET vColonia         = '';
    LET vCiudad          = '';
    LET vCodPos          = '';
    LET vEstado          = '';
    LET vTelCasa         = '';
    LET vTelMovil        = '';
    LET vsql             = '';
    LET vstmt            = '';
    LET vfecha           = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptclienteslargos.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptclienteslargos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES 
    SELECT fecha_ant, fecha_hoy, pri_dia_mes
      INTO vFechaAnt, vFechaHoy, vPriDiaMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    LET vUltDiaMesAnt = vPriDiaMes - 1 UNITS DAY;
    LET vAnioMes = YEAR(vUltDiaMesAnt)||LPAD(MONTH(vUltDiaMesAnt),2,'0');
    
    -- // CREA TABLA DE TRABAJO
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_cteslargos') THEN
        DROP TABLE "informix".sc_cteslargos;        
    END IF;
    
    CREATE TABLE "informix".sc_cteslargos(
        numcte      CHAR(20),
        cuenta      CHAR(20),
        nombre1     CHAR(26),
        nombre2     CHAR(26),
        apell_pat   CHAR(26),
        apell_mat   CHAR(26),
        correo      CHAR(100),
        calle       CHAR(30),
        numero      CHAR(10),   
        colonia     CHAR(30),
        ciudad      CHAR(60),
        codpos      CHAR(5),
        estado      CHAR(30),
        tel_casa    CHAR(13),
        tel_movil   CHAR(13),
        sdo_prom    DECIMAL(18,2) )
    EXTENT SIZE 256000 NEXT SIZE 32000 LOCK MODE ROW;
    
    -- // OBTIENE CLIENTES LARGOS
    FOREACH WITH HOLD
        SELECT mae.num_cte, mae.cuenta, TRUNC((sdo.capvigacum / sdo.diacum),2) 
          INTO vNumCte, vCuenta, vSdoProm
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_sdodiarioc sdo
         WHERE mae.producto IN('1100','1400','1700','1900','2000')
           AND mae.status_cta IN('1','3','4','5')
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta < vPriDiaMes
           AND sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vAnioMes
           AND TRUNC((sdo.capvigacum / sdo.diacum), 2) >= 2500.00
           AND sdo.diacum > 0
        UNION
        SELECT num_cte, cuenta, capital
          FROM bdinvers:sv_maeinv
         WHERE status_cta = '1'
           AND capital >= 2500.00
           AND fecha_alta < vPriDiaMes
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        -- // VALIDA PRODUCTOS NOMINA Y PLUS
        SELECT COUNT(*)
          INTO vExisteNomiPlus
          FROM sc_maechq
         WHERE producto IN('1300','1800')
           AND status_cta IN('1','3','4','5')
           AND num_cte = vNumCte;
        
        -- // VALIDA TARJETA DE CREDITO
        SELECT COUNT(*)
          INTO vExisteCredito
          FROM bdicred:sd_maecred
         WHERE status_cred in('AA','BA','BT','FF','FC','CV','E1','E2','E3')
           AND numcte = vNumCte;
        
        -- // VALIDA OTROS CREDITOS
        SELECT COUNT(*)
          INTO vExisteOCredito
          FROM bdicred:sd_maecredcrd
         WHERE status_cred in('AA','BA','BT','FF','FC','CV','E1','E2','E3')
           AND numcte = vNumCte;
        
        -- // VALIDA SOLICITUDES RECHAZADAS
        SELECT COUNT(*)
          INTO vExisteSolicitud
          FROM bdisolic:ss_solicitudes
         WHERE status_solicitud = 'RT'
           AND numcte = vNumCte;
           
        IF ( vExisteNomiPlus > 0 OR vExisteCredito > 0 OR vExisteOCredito > 0 OR vExisteSolicitud > 0 ) THEN
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;
            CONTINUE FOREACH;
        END IF;
        
        -- // OBTIENE DATOS DEL CLIENTE
        SELECT FIRST 1 cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, mail.correo_elec, 
               ciu.nombre, dir.cod_postal, edo.nombre, tel1.telefono, tel2.telefono, 
               calle.nombrecalle, dir.numeroextcalle, zona.nombrezona
          INTO vNombre1, vNombre2, vApellPat, vApellMat, vCorreo, vCiudad, vCodPos, vEstado, vTelCasa, vTelMovil, vCalle, vNumero, vColonia
          FROM bdinteg:si_cliente cte 
         INNER JOIN bdinteg:si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = 1 )
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
          LEFT OUTER JOIN bdinteg:si_ciudades ciu ON ( ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado )
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 )
         WHERE cte.numcte = vNumCte;
        
        -- // GUARDA DATOS EN TABLA DE TRABAJO
        INSERT INTO sc_cteslargos 
        (numcte, cuenta, nombre1, nombre2, apell_pat, apell_mat, correo, calle, numero, colonia, ciudad, codpos, estado, tel_casa, tel_movil, sdo_prom)
        VALUES
        (vNumCte, vCuenta, vNombre1, vNombre2, vApellPat, vApellMat, vCorreo, vCalle, vNumero, vColonia, vCiudad, vCodPos, vEstado, vTelCasa, vTelMovil, vSdoProm);
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 5000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
                   
        LET vNumCte          = '';
        LET vCuenta          = '';
        LET vSdoProm         = 0.00;
        LET vExisteNomiPlus  = 0;
        LET vExisteCredito   = 0;
        LET vExisteOCredito  = 0;
        LET vExisteSolicitud = 0;
        LET vNombre1         = '';
        LET vNombre2         = '';
        LET vApellPat        = '';
        LET vApellMat        = '';
        LET vCorreo          = '';
        LET vCalle           = '';
        LET vNumero          = '';
        LET vColonia         = '';
        LET vCiudad          = '';
        LET vCodPos          = '';
        LET vEstado          = '';
        LET vTelCasa         = '';
        LET vTelMovil        = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    -- // DESCARGA INFORMACION
    LET vfecha = TO_CHAR(vFechaHoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/Clientes_Largos_Captacion_'||vfecha||'.txt '||
               'SELECT * FROM sc_cteslargos;" > /resplogifx/conciliachq/cteslargos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cteslargos.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    -- // ESTABLECE PERMISOS 777
    LET vstmt = '';
    LET vstmt = '/usr/bin/chmod 777 /resplogifx/conciliachq/Clientes_Largos_Captacion_'||vfecha||'.txt'; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    -- // COMPRIME ARCHIVO DESCARGADO
    LET vstmt = '';
    LET vstmt = '/usr/bin/gzip -9 /resplogifx/conciliachq/Clientes_Largos_Captacion_'||vfecha||'.txt'; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;