CREATE PROCEDURE "informix".sp_dskrgactasinform3anios3meses( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasConcentrada INTEGER;
    DEFINE vCuenta          CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vFechaUltimoDep  DATE;
    DEFINE vFechaUltimoRet  DATE;
    DEFINE vFechaAlta       DATE;
    DEFINE vFechaCompara    DATE;
    DEFINE vDiasSinTransacc INTEGER;    
    DEFINE vNomProducto     CHAR(40);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vNumTarjeta      CHAR(16);
    DEFINE vNombreCliente   CHAR(104);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(8);
    DEFINE vDireccion       CHAR(200);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    
    LET vFechaHoy        = '';
    LET vDiasConcentrada = 0;
    LET vCuenta          = '';   
    LET vStatusCta       = '';
    LET vSdoActual       = 0.00;
    LET vFechaUltimoDep  = '';
    LET vFechaUltimoRet  = '';
    LET vFechaAlta       = '';
    LET vFechaCompara    = '';
    LET vDiasSinTransacc = 0;
    LET vNomProducto     = '';
    LET vNumCliente      = '';
    LET vNumTarjeta      = '';
    LET vNombreCliente   = '';
    LET vsql             = '';
    LET vstmt            = '';
    LET vfecha           = '';
    LET vDireccion       = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios3meses.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios3meses.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasConcentrada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaConcentrad';
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.sdo_actual, mae.fecultdep, mae.fecultret, noc.fecha_alta, mae.producto||' '||TRIM(NVL(pro.nombre,' ')),
               NVL(tar.num_tarjeta, ' '), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)
          INTO vCuenta, vNumCliente, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumTarjeta, vNombreCliente
          FROM bdicheq:"informix".sc_maechq mae
         INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
         INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
         INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
         LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND 
                                                                 tar.cuenta = mae.cuenta AND 
                                                                 tar.tipo_tarjeta = 'T' AND
                                                                 tar.status_tar = 'A' AND 
                                                                 tar.secuencia = ( SELECT MAX(secuencia)
                                                                                     FROM bdicheq:"informix".sc_tarjeta
                                                                                    WHERE empresa = pEmpresa
                                                                                      AND cuenta = mae.cuenta
                                                                                      AND tipo_tarjeta = 'T'
                                                                                      AND status_tar = 'A' ) )
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta is not null
           AND mae.status_cta = '5'
		   AND mae.producto <> '1100'
           AND mae.sdo_actual > 0.00
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        -- // OBTIENE FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        IF ( vDiasSinTransacc > vDiasConcentrada ) THEN    --------RSV SE MODIFICA ANTERIORMENTE FUE >= AHORA NECESITAMOS QUE AL DIA 1097 CAMBIE EL ESTATUS 
            SELECT TRIM(NVL(calle.nombrecalle,  ' ')) ||' '|| 
                   TRIM(NVL(dir.numeroextcalle, ' ')) ||' '|| 
                   TRIM(NVL(dir.numerointcalle, ' ')) ||' '|| 
                   TRIM(NVL(dir.departamento,   ' ')) ||' '||
                   TRIM(NVL(zona.nombrezona,    ' ')) ||' '||
                   TRIM(NVL(zona.municipiozona, ' ')) ||' '||
                   TRIM(NVL(ciu.nombreciudad,   ' ')) ||' '||
                   TRIM(NVL(ciu.inicialestado,  ' ')) ||' '||
                   TRIM(NVL(dir.cod_postal,     ' '))     
              INTO vDireccion
              FROM bdinteg:si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
              LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
              LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
             WHERE dir.numcte = vNumCliente
               AND dir.tipo_dir = '1';
               
            IF vDireccion is null OR vDireccion = '' THEN
                SELECT TRIM(calle.nombrecalle)  ||' '|| 
                       TRIM(dir.numeroextcalle) ||' '|| 
                       TRIM(dir.numerointcalle) ||' '|| 
                       TRIM(dir.departamento)   ||' '||
                       TRIM(zona.nombrezona)    ||' '||
                       TRIM(zona.municipiozona) ||' '||
                       TRIM(ciu.nombreciudad)   ||' '||
                       TRIM(ciu.inicialestado)  ||' '||
                       TRIM(dir.cod_postal)     
                  INTO vDireccion
                  FROM bdinteg:si_direcciones_actual dir
                  LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                  LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                  LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                 WHERE dir.numcte = vNumCliente
                   AND dir.tipo_dir = '2';
                   
                IF vDireccion is null OR vDireccion = '' THEN
                    SELECT TRIM(calle.nombrecalle)  ||' '|| 
                           TRIM(dir.numeroextcalle) ||' '|| 
                           TRIM(dir.numerointcalle) ||' '|| 
                           TRIM(dir.departamento)   ||' '||
                           TRIM(zona.nombrezona)    ||' '||
                           TRIM(zona.municipiozona) ||' '||
                           TRIM(ciu.nombreciudad)   ||' '||
                           TRIM(ciu.inicialestado)  ||' '||
                           TRIM(dir.cod_postal)     
                      INTO vDireccion
                      FROM bdinteg:si_direcciones_actual dir
                      LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                      LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                      LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                     WHERE dir.numcte = vNumCliente
                       AND dir.tipo_dir = '3';
                    
                    IF vDireccion is null OR vDireccion = '' THEN
                        LET vDireccion = 'DIRECCION NO ENCONTRADA';
                    END IF;
                END IF;
            END IF;
             
            INSERT INTO sc_ctasinactinfor3anios3meses 
            ( num_cte, cliente, producto, cuenta, status_cta, sdo_actual, num_tarjeta, fech_ult_dep, fech_ult_ret, fech_inactividad, domicilio, fecha_rep )
            VALUES
            ( vNumCliente, vNombreCliente, vNomProducto, vCuenta, vStatusCta, vSdoActual, vNumTarjeta, vFechaUltimoDep, vFechaUltimoRet, vFechaCompara, vDireccion, vFechaHoy );
            
            LET vContador2 = vContador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
    END FOREACH;
	
	--RSV YA NO TIENE QUE DESCARGAR EL ARCHIVO  NUEVA FUNCIONALIDAD 
 /*
    LET vfecha = TO_CHAR(vFechaHoy, '%d%m%Y');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CtasInactivas3anios3meses_'||vfecha||'.txt '||
               'SELECT producto, num_cte, num_tarjeta, cuenta, cliente, sdo_actual, to_char(fech_ult_dep,'''||'%d/%m/%Y'||'''), to_char(fech_ult_ret,'''||'%d/%m/%Y'||'''), status_cta '||
               'FROM sc_ctasinactinfor3anios3meses WHERE fecha_rep = '''||vFechaHoy||''' " > /resplogifx/conciliachq/ctasinact33.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasinact33.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
 */
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
    
END PROCEDURE;