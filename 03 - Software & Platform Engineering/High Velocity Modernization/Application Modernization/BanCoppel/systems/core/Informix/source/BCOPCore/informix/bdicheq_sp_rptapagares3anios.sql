CREATE PROCEDURE "informix".sp_rptapagares3anios()
RETURNING CHAR(5), CHAR (60); --- CodigoRetorno, Mensaje 

    -- // Declaracion de Variables
    DEFINE vSqlError    SMALLINT;
    DEFINE vIsamError   SMALLINT;
    DEFINE vDescError   CHAR (50);
    DEFINE cCodRet      CHAR (5);
    DEFINE cCodRet2     CHAR (5);
    DEFINE cCodRet3     CHAR (50);
    DEFINE dFechaHoy    DATE;
    DEFINE dProxFecha   DATE;
    DEFINE cDiasxVencer CHAR (5);
    DEFINE cMensaje     CHAR (60);
    DEFINE vsql         CHAR(600);
    DEFINE vstmt        CHAR(250);
    DEFINE vfecha       CHAR(8);
    
    -- // Inicializacion de Variables
    LET vSqlError    = 0;
    LET vIsamError   = 0;
    LET vDescError   = '';
    LET cCodRet      = '00000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET dFechaHoy    = '';
    LET dProxFecha   = '';
    LET cDiasxVencer = '';
    LET cMensaje     = 'EL PROCESO SE EJECUTO EXITOSAMENTE';
    LET vsql         = '';
    LET vstmt        = '';
    LET vfecha       = '';

    BEGIN

    ON EXCEPTION SET vSqlError, vIsamError, vDescError
        SET DEBUG FILE TO "/tmp/sp_rptapagares3anios.err";
        TRACE ON;
        IF vSqlError <> 0 THEN
            LET cCodRet = vSqlError;
            LET cCodRet2 = vIsamError;
            LET cCodRet3 = vDescError;
            RETURN cCodRet, 'Ocurrio un Error Durante La Ejecucion Del Procedimiento';
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_rptapagares3anios.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // LIMPIAR LA TABLA
    IF EXISTS(SELECT tabname FROM bdicheq:systables WHERE tabname = 'sc_pagares3anios') THEN
        DROP TABLE sc_pagares3anios;
    END IF;

    CREATE TABLE sc_pagares3anios 
        ( 
            sucursal            CHAR(4)     NOT NULL, 
            promotor            CHAR(8)     NOT NULL,
            numcte              CHAR(9)     NOT NULL , 
            nombre_cte          CHAR(108),
            numcta              CHAR(20)    NOT NULL , 
            cta_eje             CHAR(20),
            fecha_apertura      DATE, 
            fecha_vencimiento   DATE, 
            telefono1           CHAR(15),
            telefono2           CHAR(15),
            telefono3           CHAR(15),
            extension           CHAR(5),
            correo_elect        CHAR(50)
        )
    EXTENT SIZE 2048 NEXT SIZE 1024 LOCK MODE ROW;
    CREATE INDEX idx_pagare3anios_suc ON sc_pagares3anios (sucursal) ONLINE;
    CREATE INDEX idx_pagare3anios_ven ON sc_pagares3anios (fecha_vencimiento) ONLINE;
    CREATE INDEX idx_pagare3anios_cta ON sc_pagares3anios (numcta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_pagares3anios;
    
    -- // Obtener Parametros
    SELECT fecha_hoy, prox_fecha  
      INTO dFechaHoy, dProxFecha 
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
     
    -- // OBTIENE PARAMETRO DE DIAS
    SELECT TRIM (valor) 
      INTO cDiasxVencer 
      FROM bdicheq:sc_param 
     WHERE empresa = "001"
       AND codparam = 'DiasRptsCtaIna3anios';	

    SELECT *
      FROM bdinvers:sv_maeinv
     WHERE empresa = '001'
       AND status_cta = '1'
      INTO TEMP tmp_invs WITH NO LOG;
    CREATE INDEX idx_pagare_tmp ON tmp_invs(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invs;
       
    -- // Proceso para el pagare
    INSERT INTO sc_pagares3anios
    SELECT inv.sucursal, inv.promotor, inv.num_cte,
           TRIM(cte.nombre1)||' '||TRIM(NVL(cte.nombre2,''))||' '||TRIM(cte.apell_paterno)||' '||TRIM(NVL(cte.apell_materno,'')), 
           inv.cuenta, inv.cta_cheques, inv.fecha_alta, tmp.fecha_venc, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, cor.correo_elec
      FROM bdinvers:sv_maeinv inv
     INNER JOIN tmp_invs tmp ON ( tmp.cuenta = inv.cuenta AND tmp.fecha_venc BETWEEN dProxFecha AND ( dProxFecha + cDiasxVencer::INTEGER ) )
     INNER JOIN bdinteg:si_cliente cte ON (cte.numcte = inv.num_cte) 
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = cte.numcte AND tel1.tipo_tel = 1)
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = cte.numcte AND tel2.tipo_tel = 2)
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = cte.numcte AND tel3.tipo_tel = 3)
      LEFT OUTER JOIN bdinteg:si_correos cor ON (cor.numcte = cte.numcte AND cor.tipo_correo = 1 AND cor.status_correo = 'A')
     WHERE inv.empresa = '001'
       AND inv.secuencia = 1
       AND dFechaHoy - inv.fecha_alta >= 1060;
       
    UPDATE STATISTICS MEDIUM FOR TABLE sc_pagares3anios;
    
    -- // GENERA EL ARCHIVO PARA OPERACIONES
    LET vfecha = TO_CHAR(dFechaHoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/Pagares3anios_'||vfecha||'.txt '||
               'SELECT * FROM sc_pagares3anios;" > /resplogifx/conciliachq/pagare3anios.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/pagare3anios.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
       
    RETURN cCodRet, cMensaje;
    
    END;
    
END PROCEDURE;