CREATE PROCEDURE "informix".sp_bloqdesbloqcta(cEmpresa CHAR(3), cNumCuentaO CHAR (20), mMonto money (14,2), cUsuario CHAR (8), cTipo_Oper CHAR(1))

RETURNING CHAR(5), CHAR (5);

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCod_Ret CHAR(5);
DEFINE cCod_Ret2 CHAR (5);
DEFINE cStatus CHAR(1);
DEFINE cTipo_Prod CHAR(4);
DEFINE cEdad CHAR (5);
DEFINE dFecha_Nac DATE;
DEFINE cClave CHAR (5);

LET cCod_Ret = '000';
LET cCod_Ret2 = '000';
LET cStatus = '';
LET cTipo_Prod = '';
LET cEdad = '';
LET dFecha_Nac = '01-01-1900';
LET cClave = '';


/*SET DEBUG FILE to "/tmp/sp_BloqDesbloqCta.out";
TRACE ON;*/

BEGIN
    ON EXCEPTION SET iSqlErr,iIsamErr
        IF iSqlErr != 0 THEN
            LET cCod_Ret=iSqlErr;
            RETURN cCod_Ret, cCod_Ret2;
        END IF;
    END EXCEPTION;

IF cTipo_Oper = '1' THEN

        --Valida si la cuenta es Efectiva Niños y si el cliente titular es mayor de edad
        SELECT producto INTO cTipo_Prod
        FROM bdicheq:sc_maechq
        WHERE cuenta = cNumCuentaO;

        IF cTipo_Prod = '1500' THEN
                SELECT ctepf.fecha_nac,
                        SUBSTR((YEAR ( fech.fecha_hoy) +  MONTH(fech.fecha_hoy)/12 + DAY(fecha_hoy)/30/12) -
                        (YEAR ( ctepf.fecha_nac) +  MONTH(ctepf.fecha_nac)/12 +  DAY(fecha_nac)/30/12),0,4) edad
                INTO dFecha_nac, cEdad
                FROM bdicheq:sc_maechq mae
                        INNER JOIN bdinteg:si_ctepf ctepf ON ctepf.numcte = mae.num_cte
                        INNER JOIN bdicheq:sc_fechas fech ON  fech.fecha_hoy > ctepf.fecha_nac
                WHERE mae.cuenta = cNumCuentaO
                        AND (YEAR ( fech.fecha_hoy) +  MONTH(fech.fecha_hoy)/12 + DAY(fecha_hoy)/30/12) -
                                (YEAR ( ctepf.fecha_nac) +  MONTH(ctepf.fecha_nac)/12 +  DAY(fecha_nac)/30/12)> 0;

                IF cEdad < 18 THEN
                        LET cCod_Ret2 = '002';
                END IF;

        ELSE
                LET cCod_Ret2 = '001';
        END IF;

END IF;

IF cTipo_Oper = '2' THEN

        --Valida si el status de la cuenta es bloqueado
        CALL bloqueo_cta(cEmpresa, cNumCuentaO, 000.00, '00', 0, '1900-01-01', cUsuario,'','','','','')
        returning cCod_Ret2, cClave;
END IF;

IF cTipo_Oper = '3' THEN
        --Cambia el status de la cuenta a cancelada
        UPDATE sc_maechq SET status_cta = '2', fec_cancelac = CURRENT
        WHERE cuenta = cNumCuentaO;
END IF;

IF cTipo_Oper = '4' THEN
        -- Bloquea la cuenta en caso de error
        CALL bloqueo_cta(cEmpresa, cNumCuentaO, '0', '02', 4, '1900-01-01', cUsuario,'','','','','')
        returning cCod_Ret2, cClave;
END IF;

RETURN cCod_Ret, cCod_Ret2;
END;
END PROCEDURE
DOCUMENT
"Bloqueo y Desbloqueo de Status de Cuenta Efectiva Niños",
"Autor : Priscilla Mercado Campaña.",
"Fecha : 02-01-2009",
"ModIFico: Abigail Vasavilbazo Cañedo",
"ModIFicaciON: Se agregaron 2 parametros al llamado al procedimiento bloqueo_cta",
"ModIFico: Valentin Lopez Valenzuela",
"ModIFicacion: Se agregaron 4 parametros al llamado al procedimiento bloqueo_cta",
"Fecha : 20-09-2010",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_blqconsareasolicbloqueo(pClave CHAR(2), pCod CHAR(1))
RETURNING CHAR(6)  As Codret,
          CHAR(40) As Mensaje,
          CHAR(2)  As Clave,
          CHAR(1)  As Codigo,
          CHAR(20) As Descripcion,
          CHAR(38) As CodigoDescripcion,
          CHAR(38) As ClaveDescripcion; 
    
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensaje     CHAR(40);
    DEFINE cClave       CHAR(2);
    DEFINE cCodigo      CHAR(1);
    DEFINE cDescripcion CHAR(20);
    DEFINE iCont        INTEGER;
    DEFINE cCodDescrip	CHAR(38);
    DEFINE cCveDescrip	CHAR(38);

    LET iSqlErr         = 0;
    LET cCodRet         = "000000";
    LET cMensaje        = "PROCEDIMIENTO EXITOSO";
    LET cClave          = "";
    LET cCodigo         = "";
    LET cDescripcion    = "";
    LET cCodDescrip     = "";
    LET cCveDescrip     = "";
    LET iCont           = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --- SET DEBUG FILE TO "/dbexportb/vlv/sp_blqconsareasolicbloqueo.out";
    --- TRACE ON;

    -- // Consulta todas las areas de bloqueo
    IF (pClave = '' OR pClave IS NULL) AND (pCod = '' OR pCod IS NULL) THEN
        FOREACH 
            SELECT clave, codigo, descripcion, codigo||'  '||descripcion, clave||'  '||descripcion
              INTO cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip
              FROM bdicheq:sc_areabloqueo
             ORDER BY clave

            LET iCont = 1;

            RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip WITH RESUME;
        END FOREACH

    ELSE -- // Consulta por un variable especifica.

        LET pCod = UPPER(pCod);
        
        SELECT clave, codigo, descripcion, codigo||'  '||descripcion, clave||'  '||descripcion
          INTO cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip
          FROM bdicheq:sc_areabloqueo
         WHERE codigo = (CASE WHEN pCod = '' THEN codigo ELSE pCod END)
           AND clave = (CASE WHEN pClave = '' THEN clave ELSE pClave END);

        IF cClave IS NULL THEN
            Let cCodRet = '000001';
            Let cMensaje = 'No Existen Datos para los Parametros Recibidos';
        END IF;

        RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;

    END IF

    IF iCont = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje = 'No Hay Informacion En El Catalogo';
        RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Obtiene las Areas Solicitantes del Bloqueo', 
'AUTOR: Valentín López',
'FECHA: Septiembre 2010',
'VERSION: 201009.1216';

CREATE PROCEDURE "informix".sp_blqconsclavebloq(pCodbloq CHAR(2))
RETURNING CHAR(5), CHAR(40), CHAR(2), CHAR(35), CHAR(38);

    DEFINE cCodret  CHAR(5);
    DEFINE cSQL_ERR INTEGER;
    DEFINE iIsamErr CHAR(35);
    DEFINE cMensaje CHAR(40);
    DEFINE cCodigo CHAR(2);
    DEFINE cDescripcion CHAR(35);
    DEFINE cCodDescrip	CHAR(38);
    DEFINE iCont INTEGER;

    LET cCodRet     = '00000';
    LET cSql_Err    = 0;
    LET iIsamErr = '';
    LET cMensaje = 'Proceso ejecutado Exitosamente';
    LET cCodigo = '';
    LET cDescripcion = '';
    LET cCodDescrip	= '';
    LET iCont = 0;

    --- SET DEBUG FILE TO '/tmp/sp_blqconsclavebloq.out';
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET cSql_Err
        LET cCodRet = cSql_Err;
        LET cMensaje= 'Error de Informix';
        RETURN cCodret, cMensaje, cCodigo, cDescripcion, cCodDescrip;
    END EXCEPTION;

    IF pCodbloq = '' OR pCodbloq IS NULL THEN	
        FOREACH 
            SELECT codigo, descripcion, codigo||' '|| descripcion
              INTO cCodigo, cDescripcion, cCodDescrip
              FROM bdicheq:sc_bloqueo
             WHERE codigo <> '00'
               AND codigo < '50'
             ORDER BY codigo		

            LET iCont = 1;

            RETURN cCodret, cMensaje, cCodigo, cDescripcion, cCodDescrip WITH RESUME;
        END FOREACH;	
    ELSE			
        SELECT codigo, descripcion, codigo||' '|| descripcion
          INTO cCodigo, cDescripcion, cCodDescrip
          FROM bdicheq:sc_bloqueo
         WHERE codigo = pCodbloq;

        IF cCodigo IS NULL THEN
            LET cCodRet = '00002';
            LET cMensaje= 'No existe esa clave de bloqueo';			
        END IF;

        RETURN cCodret, cMensaje, cCodigo, cDescripcion, cCodDescrip;
    END IF;

    IF iCont = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje= 'No hay informacion en el catalogo';
        RETURN cCodret, cMensaje, cCodigo, cDescripcion, cCodDescrip;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Procedimiento encargado de llenar el combo de claves de bloqueo ',
'EJECUTADO POR: Sistema bloqueos',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA: 13/09/2010',
'VERSION: 20100913.1120',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_blqconsopcionbloq(pCodOpcion CHAR(2))
RETURNING CHAR(5), CHAR(40), INTEGER, CHAR(35), CHAR(38);

    DEFINE cCodret  CHAR(5);
    DEFINE cSQL_ERR INTEGER;
    DEFINE iIsamErr CHAR(35);
    DEFINE cMensaje CHAR(40);
    DEFINE iOpcion INTEGER;
    DEFINE cDescripcion CHAR(35);
    DEFINE cCodDescrip	CHAR(38);
    DEFINE iCont INTEGER;

    LET cCodRet     = '00000';
    LET cSql_Err    = 0;
    LET iIsamErr = '';
    LET cMensaje = 'PROCESO EJECUTADO EXITOSAMENTE';
    LET iOpcion = 0;
    LET cDescripcion = '';
    LET cCodDescrip	= '';
    LET iCont = 0;

    --- SET DEBUG FILE TO '/tmp/sp_blqconsopcionbloq.out';
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET cSql_Err
        LET cCodRet = cSql_Err;
        LET cMensaje= 'ERROR INESPERADO DE INFORMIX';
        RETURN cCodret, TRIM(cMensaje), iOpcion, TRIM(cDescripcion), TRIM(cCodDescrip);
    END EXCEPTION;

    IF pCodOpcion = '' OR pCodOpcion IS NULL THEN	
        FOREACH 
            SELECT opcion, descripcion, opcion ||' '|| descripcion
              INTO iOpcion, cDescripcion, cCodDescrip
              FROM bdicheq:sc_opcionbloqueo			
             ORDER BY opcion		

            LET iCont = 1;

            RETURN cCodret, TRIM(cMensaje), iOpcion, TRIM(cDescripcion), TRIM(cCodDescrip) WITH RESUME;
        END FOREACH;	
    ELSE
        LET pCodOpcion = pCodOpcion::INTEGER;

        SELECT opcion, descripcion, opcion ||' '|| descripcion
          INTO iOpcion, cDescripcion, cCodDescrip
          FROM bdicheq:sc_opcionbloqueo
         WHERE opcion = pCodOpcion;

        IF iOpcion IS NULL THEN
            LET cCodRet = '00002';
            LET cMensaje= 'NO EXISTE LA OPCION DE BLOQUEO';			
        END IF;

        RETURN cCodret, TRIM(cMensaje), iOpcion, TRIM(cDescripcion), TRIM(cCodDescrip);
    END IF;

    IF iCont = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje= 'NO HAY INFORMACION EN EL CATALOGO';
        RETURN cCodret, TRIM(cMensaje), iOpcion, TRIM(cDescripcion), TRIM(cCodDescrip);
    END IF;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento encargado de llenar el combo de opcion de bloqueo ',
'EJECUTADO POR: Sistema bloqueos',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA: 13/09/2010',
'VERSION: 20100913.1120',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_blqconstipobloqueo(pClave CHAR(2), pCod CHAR(1))
RETURNING CHAR(6)  As Codret,
          CHAR(40) As Mensaje,
          CHAR(2)  As Clave,
          CHAR(1)  As Codigo,
          CHAR(20) As Descripcion,
          CHAR(38) As CodigoDescripcion,
          CHAR(38) As ClaveDescripcion; 
    
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensaje     CHAR(40);
    DEFINE cClave       CHAR(2);
    DEFINE cCodigo      CHAR(1);
    DEFINE cDescripcion CHAR(20);
    DEFINE iCont        INTEGER;
    DEFINE cCodDescrip	CHAR(38);
    DEFINE cCveDescrip	CHAR(38);

    LET iSqlErr         = 0;
    LET cCodRet         = "000000";
    LET cMensaje        = "PROCEDIMIENTO EXITOSO";
    LET cClave          = "";
    LET cCodigo         = "";
    LET cDescripcion    = "";
    LET cCodDescrip     = "";
    LET cCveDescrip     = "";
    LET iCont           = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --- SET DEBUG FILE TO "/dbexportb/vlv/sp_blqconstipobloqueo.out";
    --- TRACE ON;

    IF (pClave = '' OR pClave IS NULL) AND (pCod = '' OR pCod IS NULL) THEN
        FOREACH
        --Consulta todas las areas de bloqueo
        SELECT clave, codigo, descripcion, codigo||'  '||descripcion, clave||'  '||descripcion
        INTO cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip
        FROM bdicheq:sc_tipobloqueo
        ORDER BY clave

        LET iCont = 1;

        RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip WITH RESUME;

        END FOREACH
    ELSE
        LET pCod = UPPER(pCod);

        -- // Consulta por un variable especifica.
        SELECT clave, codigo, descripcion, codigo||'  '||descripcion, clave||'  '||descripcion
          INTO cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip
          FROM bdicheq:sc_tipobloqueo
         WHERE codigo = (CASE WHEN pCod = '' THEN codigo ELSE pCod END)
           AND clave = (CASE WHEN pClave = '' THEN clave ELSE pClave END);

        IF cClave IS NULL THEN
            Let cCodRet = '000001';
            Let cMensaje = 'No Existen Datos para los Parametros Recibidos';
        END IF;

        RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;
    END IF

    IF iCont = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje = 'No Hay Informacion En El Catalogo';
        RETURN cCodRet, cMensaje, cClave, cCodigo, cDescripcion, cCodDescrip, cCveDescrip;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Muestra los Tipos de Bloqueos Que Existen en el Sistema',
'AUTOR: Valentín López',
'FECHA: Septiembre 2010',
'VERSION: 201009.1541';

CREATE PROCEDURE "informix".sp_blqgeneraarchivobloqueos(pFechaInicio DATE, pFechaFin DATE)
RETURNING CHAR(6) AS CODRET, CHAR(50) AS MENSAJE;
    
    -- // Declaracion de Variables
    DEFINE viSqlErr      INTEGER;
    DEFINE vsRepositorio CHAR(60);
    DEFINE cCodRet       CHAR(5);
    DEFINE cCuenta1      CHAR(20);
    DEFINE cFecha        CHAR(10);
    DEFINE cHora         CHAR(10);
    DEFINE cClave        CHAR(2);
    DEFINE cCuenta       CHAR(20);
    DEFINE cMensaje      CHAR(50);
    DEFINE cFechaHoy     CHAR(14);
    DEFINE vsArchTemp    CHAR(40);
    DEFINE vsSQL         CHAR(300);
    DEFINE iRegistro     INTEGER;
    DEFINE iRenglon      INTEGER;

    -- // Inicializacion de Varibles
    LET viSqlErr      = 0;
    LET vsRepositorio = '';
    LET cCodRet       = '000000';
    LET cCuenta1      = '';
    LET cFecha        = '';
    LET cHora         = '';
    LET cClave        = '';
    LET cCuenta       = '';
    LET cMensaje      = 'Archivo Generado';
    LET cFechaHoy     = '';
    LET vsArchTemp    = '';
    LET vsSQL         = '';
    LET iRegistro     = 0;
    LET iRenglon      = 0;

    --- SET DEBUG FILE TO "/dbexportb/vlv/sp_blqgeneraarchivobloqueos.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET viSqlErr  
        IF viSqlErr <> 0 THEN
            LET cCodRet = viSqlErr;
            LET cMensaje = '';
            RETURN TRIM(cCodRet), TRIM(cMensaje);
        END IF;
    END EXCEPTION;

    -- // Valor de la Ruta en donde se genera el archivo
    SELECT valor  
      INTO vsRepositorio
      FROM sc_param  
     WHERE empresa = '001'  
       AND codparam = 'rutadescargaPLD';  

    -- // Borra los registro que trae la tabla sc_blqCuentasBloqueadas para que no se acumuelen en el nuevo archivo.unl
    --- DELETE FROM sc_blqCuentasBloqueadas;
    TRUNCATE TABLE sc_blqCuentasBloqueadas;

    -- // Verifica si las fechas estan vacias consulta en la tabla sc_ctabloqueo sino consulta en la tabla sc_histbloq 
    IF (pFechaInicio = '' OR pFechaInicio IS NULL) AND (pFechaFin = '' OR pFechaFin IS NULL) THEN

        LET iRegistro = 1;
        LET iRenglon = 1;

        FOREACH -- // Inserta en la tabla sc_blqCuentasBloqueadas los registros que se encuentran en la tabla sc_ctabloqueo
            SELECT cod_area||cod_tipobloq, Cuenta
              INTO cClave, cCuenta
              FROM bdicheq:sc_ctabloqueo

            IF iRegistro = 1 THEN
            
                INSERT INTO sc_blqCuentasBloqueadas (Renglon, cve01, cuenta01, cve02, cuenta02, cve03, cuenta03, cve04, cuenta04, cve05, cuenta05)
                VALUES (iRenglon, cClave, cCuenta , '', '', '', '', '', '', '', '');				
            
            ELSE -- // Actualiza los registros en la tabla sc_blqCuentasBloqueadas y los genera en un archivo en 5 columnas
            
                UPDATE sc_blqCuentasBloqueadas
                   SET cve02    = DECODE(iRegistro,2,cClave  ,cve02),
                       cuenta02 = DECODE(iRegistro,2,cCuenta,cuenta02),
                       cve03    = DECODE(iRegistro,3,cClave  ,cve03),
                       cuenta03 = DECODE(iRegistro,3,cCuenta,cuenta03),
                       cve04    = DECODE(iRegistro,4,cClave  ,cve04),
                       cuenta04 = DECODE(iRegistro,4,cCuenta,cuenta04),
                       cve05    = DECODE(iRegistro,5,cClave  ,cve05),
                       cuenta05 = DECODE(iRegistro,5,cCuenta,cuenta05)
                 WHERE Renglon = iRenglon;

            END IF;

            IF iRegistro = 5 THEN
                LET iRegistro = 1;
                LET iRenglon  = iRenglon + 1;
            ELSE
                LET iRegistro = iRegistro + 1;
            END IF;
        END FOREACH

    ELSE

        IF pFechaInicio > pFechaFin THEN
            LET cCodRet = '000002';
            LET cMensaje = 'La Fecha Inicio No Debe Ser Mayor a la Fecha Fin';
            RETURN TRIM(cCodRet), TRIM(cMensaje);
        END IF

        LET iRegistro = 1;
        LET iRenglon = 1;

        FOREACH
            SELECT cuenta, MAX(fecha)
              INTO cCuenta1, cFecha
              FROM bdicheq:sc_histbloq 
             WHERE fecha >= pFechaInicio
               AND fecha <= pFechaFin
               AND tipo_mov = 'B'
             GROUP BY cuenta
             ORDER BY cuenta				

            -- // Genera el ultimo registro que tiene cada cuenta.
            SELECT cod_area||cod_tipobloq
              INTO cClave
              FROM bdicheq:sc_histbloq 
             WHERE cuenta = cCuenta1
               AND fecha = cFecha
               AND hora = (SELECT MAX(hora) FROM bdicheq:sc_histbloq WHERE cuenta = cCuenta1 AND fecha = cFecha);

            -- // Inserta en la tabla sc_blqCuentasBloqueadas los registros que se encuentran en la tabla sc_histbloq generados en la consulta anterior
            IF iRegistro = 1 THEN
            
                INSERT INTO sc_blqCuentasBloqueadas (Renglon ,cve01 ,cuenta01,cve02,cuenta02,cve03,cuenta03,cve04,cuenta04,cve05,cuenta05)
                VALUES (iRenglon,cClave,cCuenta1,''   ,''      ,''   ,''      ,''   ,''      ,''   ,'');			
            
            ELSE -- // Actualiza los registros en la tabla sc_blqCuentasBloqueadas y los genera en un archivo en 5 columnas
            
                UPDATE sc_blqCuentasBloqueadas
                   SET cve02    = DECODE(iRegistro,2,cClave  ,cve02),
                       cuenta02 = DECODE(iRegistro,2,cCuenta1,cuenta02),
                       cve03    = DECODE(iRegistro,3,cClave  ,cve03),
                       cuenta03 = DECODE(iRegistro,3,cCuenta1,cuenta03),
                       cve04    = DECODE(iRegistro,4,cClave  ,cve04),
                       cuenta04 = DECODE(iRegistro,4,cCuenta1,cuenta04),
                       cve05    = DECODE(iRegistro,5,cClave  ,cve05),
                       cuenta05 = DECODE(iRegistro,5,cCuenta1,cuenta05)
                 WHERE Renglon = iRenglon;
                
            END IF;

            IF iRegistro = 5 THEN
                LET iRegistro = 1;
                LET iRenglon =iRenglon + 1;
            ELSE
                LET iRegistro = iRegistro + 1;
            END IF;
        END FOREACH

    END IF;

    -- // Consulta la fecha y la hora actual para agregarla al nombre del archivo
    SELECT SUBSTR(Fecha_hoy, 7, 4) || 
           SUBSTR(Fecha_hoy, 1, 2) || 
           SUBSTR(Fecha_hoy, 4, 2) ||
           SUBSTR(CURRENT HOUR TO fraction, 1, 2) || 
           SUBSTR(CURRENT HOUR TO fraction, 4, 2) || 
           SUBSTR(CURRENT HOUR TO fraction, 7, 2)
      INTO cFechaHoy
      FROM bdicheq:sc_fechas;

    -- // Genera archivo.
    LET vsArchTemp = TRIM(cFechaHoy)||'cuentasbloqueadas.unl';

    LET vsSQL = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || TRIM (vsArchTemp) ||
                ' SELECT cve01, cuenta01, cve02, cuenta02, cve03, cuenta03, cve04, cuenta04, cve05, cuenta05' || 
                ' FROM sc_blqCuentasBloqueadas; " > ' || TRIM(vsRepositorio) || 'consulta.sql';
    SYSTEM vsSQL;

    --- LET vsSQL = 'dbaccess bdicheq ' || TRIM(vsRepositorio) || 'consulta.sql'; 
    LET vsSQL = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(vsRepositorio) || 'consulta.sql'; 
    SYSTEM vsSQL;

    RETURN TRIM(cCodRet), TRIM(cMensaje);

    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Genera un archivo.unl de las cuentas que se encuentran bloqueadas ya sea de la sc_histbloq o sc_ctabloqueo',
'AUTOR: Valentín López',
'LP:    Armando Mercado',
'FECHA: Septiembre 2010',
'VERSION: 20100921.1519';

CREATE PROCEDURE "informix".sp_blqgenerareportebloqueos(pAreaSolic CHAR(2), pTipoBloq CHAR(2), pFechaIni CHAR(10), pFechaFin CHAR(10))
RETURNING CHAR(6)  AS Codret,
          CHAR(60) AS Mensaje,
          CHAR(5)  AS Clave,
          CHAR(50) AS OpcionBloq,
          CHAR(20) AS NumCliente,
          CHAR(20) AS Cuenta,
          DATE AS FechaBloq,
          CHAR(20) AS AreaSolic,
          CHAR(20) AS TipoBloq,
          CHAR(8) AS Empleado,
          INTEGER AS CuentasTotales;
	
    DEFINE iSqlErr      INTEGER;
	DEFINE cErrorInfo   INTEGER;
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensaje     CHAR(60);
	DEFINE cClave       CHAR(5);
	DEFINE cOpcionBloq  CHAR(50);
	DEFINE cCliente     CHAR(20);
	DEFINE cCuenta      CHAR(20);
	DEFINE dFechaBloq   DATE;
	DEFINE cAreaSolic   CHAR(20);
	DEFINE cTipoBloq    CHAR(20);
	DEFINE cEmpleado    CHAR(8);
	DEFINE ibandera		INTEGER;
	DEFINE iNumctas		INTEGER;
	
    LET iSqlErr         = 0;
	LET cErrorInfo      = 0;
    LET cCodRet         = "000000";
    LET cMensaje        = "EL PROCESO TERMINO EXISTOSAMENTE";
    LET cClave          = "";
	LET cOpcionBloq     = "";
	LET cCliente        = "";
	LET cCuenta         = "";
	LET dFechaBloq      = "";
	LET cAreaSolic      = "";
	LET cTipoBloq       = "";
	LET cEmpleado       = "";
	LET ibandera        = 0;	
	LET iNumctas        = 0;
    
    BEGIN

    ON EXCEPTION SET iSqlErr,  cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodret = iSqlErr;
            LET cMensaje = cErrorInfo;
            RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cClave), TRIM(cOpcionBloq), TRIM(cCliente), 
                   TRIM(cCuenta), dFechaBloq, TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cEmpleado),iNumctas;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;

    --- SET DEBUG FILE TO "/dbexportb/vlv/sp_blqgenerareportebloqueos.out";
    --- TRACE ON;

    -- // Muestra el total de las cuentas  que se estan mostrando el reporte.
    SELECT count(cuenta)
      INTO iNumctas
      FROM sc_maechq
     WHERE empresa = '001'
       AND cuenta in (SELECT cuenta 
                        FROM bdicheq:sc_histbloq hist
                       WHERE hist.fecha >= pFechaIni 
                         AND hist.fecha <= pFechaFin 
                         AND hist.cve_area = (CASE WHEN pAreaSolic = '' THEN hist.cve_area  ELSE pAreaSolic END)
                         AND hist.cve_tipobloq = (CASE WHEN pTipoBloq = '' THEN hist.cve_tipobloq ELSE pTipoBloq END)
                         AND hist.status_blo = 'B'
                       GROUP BY cuenta);

    -- // Muestra una lista de todos los reportes que estan bloqueados en un determinado rango de fechas.
    FOREACH
        SELECT hist.clave, opcbloq.descripcion, maechq.num_cte, hist.cuenta, hist.fecha, areabloq.descripcion, tipbloq.descripcion, hist.usuario
          INTO cClave, cOpcionBloq, cCliente, cCuenta, dFechaBloq, cAreaSolic, cTipoBloq, cEmpleado
          FROM bdicheq:sc_histbloq hist
         INNER JOIN bdicheq:sc_opcionbloqueo opcbloq ON (hist.opcion = opcbloq.opcion)
         INNER JOIN bdicheq:sc_tipobloqueo  tipbloq ON (hist.cve_tipobloq = tipbloq.clave)
         INNER JOIN bdicheq:sc_areabloqueo  areabloq ON (hist.cve_area = areabloq.clave)
         INNER JOIN bdicheq:sc_maechq maechq  ON (hist.cuenta = maechq.cuenta) 
         WHERE hist.fecha >= pFechaIni 
           AND hist.fecha <= pFechaFin 
           AND hist.cve_area = (CASE WHEN pAreaSolic = '' THEN hist.cve_area  ELSE pAreaSolic END)
           AND hist.cve_tipobloq = (CASE WHEN pTipoBloq = '' THEN hist.cve_tipobloq ELSE pTipoBloq END)
           AND hist.tipo_mov = 'B'
         ORDER BY hist.fecha

        --- LET ibandera = 1;	--Comentado para Futuras Pruebas

        RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cClave), TRIM(cOpcionBloq), TRIM(cCliente), TRIM(cCuenta), 
               dFechaBloq, TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cEmpleado), iNumctas WITH RESUME;
    END FOREACH

    --Comentado solo para futuras pruebas
    /*
    IF ibandera = 0 THEN
        LET cCodRet = '000002';
        LET cMensaje = 'NO EXISTEN REGISTROS CON LOS CRITERIOS ESPECIFICADOS';
        RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cClave), TRIM(cOpcionBloq), TRIM(cCliente), 
               TRIM(cCuenta), dFechaBloq, TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cEmpleado);
    END IF;
    */
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera un Reporte en una Consulta de Bloqueo ',
'AUTOR: Valentín López',
'FECHA: Septiembre 2010',
'VERSION: 20100917.1815';

CREATE PROCEDURE "informix".sp_conscodret(pCodigo CHAR(3), pSistema CHAR(2))
RETURNING CHAR(5) AS CODIGO, CHAR(50) AS DESCRIPCION;
    
    DEFINE cCodRet  CHAR(5);
    DEFINE cSQL_ERR INTEGER;
    DEFINE cDescripcion CHAR(50);
    
    LET cCodRet     = '00000';
    LET cSql_Err    = 0;
    LET cDescripcion = '';

    --- SET DEBUG FILE TO '/tmp/sp_conscodret.out';
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET cSql_Err
        LET cCodRet = cSql_Err;
        RETURN cCodRet, cDescripcion;
    END EXCEPTION;	

    IF pCodigo = '' OR pCodigo IS NULL THEN
        LET cCodRet = '00001';
        LET cDescripcion = 'Falta el codigo del error';
        RETURN cCodRet, cDescripcion;
    END IF;

    IF pSistema = '' OR pSistema IS NULL THEN
        LET cCodRet = '00002';
        LET cDescripcion = 'Falta el codigo del sistema';
        RETURN cCodRet, cDescripcion;
    END IF;

    SELECT descripcion
      INTO cDescripcion
      FROM bdinteg:si_codret
     WHERE codigo_retorno = pCodigo
       AND sistema = pSistema;	

    IF cDescripcion IS NULL THEN
        LET cCodRet = '00003';
        LET cDescripcion = 'No existe el error solicitado';		
    END IF;

    RETURN cCodRet, cDescripcion;
    
    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la descripcion del error',
'EJECUTADO POR: Sistema bloqueos',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA: 14/09/2010',
'VERSION: 20100913.1613',
'BD: bdicheq';

create procedure "informix".sp_dia_primero_ultimo_mes_anio (pMes char(2), pAnio char(4))

returning char(6) , date, date

Define sAuxFecha   Char(10);
Define sAuxMes     Char(2);
Define sAuxAnio    Char(4);
Define dDiaprimero date;
Define dDiaUltimo  date;
Define vcCodRet    char(6);
define vsqlerr     integer;

    Begin
        ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                LET  vcCodRet  = vsqlerr;
                RETURN vcCodRet, date(1), date(1);
            END IF;
        END  EXCEPTION
		
		--set debug file to "/tmp/sp_dia_primero_ultimo_mes_anio.out";
        --trace on;

        Let vcCodRet = '000000';
        Let sAuxFecha   = lpad(trim(pMes), 2, '0') || '-01-' || pAnio ;
        Let dDiaprimero = sAuxFecha::Date;

        If pMes = '12' then
            Let sAuxMes = '01';
            Let sAuxAnio = pAnio + 1 ;
        Else
            Let sAuxMes = pMes + 1;
            Let sAuxMes = lpad(trim(sAuxMes), 2, '0');
            Let sAuxAnio = pAnio;
        End If;

        Let sAuxFecha  = sAuxMes || '-01-' || sAuxAnio ;
        Let dDiaUltimo = sAuxFecha::date - 1;
    End;

    Return vcCodRet , dDiaprimero, dDiaUltimo;
End procedure
DOCUMENT
'AUTOR      : Juan Andres Coronel',
'DESCRIPCION: Sp para devolver el díprimero y ultimo de un mes-añ-Para compilarse en la base de datos integral',
'Captacion',
'FECHA      : Febrero 2009',
'VERSION    : 200902',
'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_buscaporapellidocliente (pApellidoPaterno CHAR(60),pApellidoMaterno CHAR(60),iRegistro  INTEGER)
RETURNING CHAR(5), CHAR(9), CHAR (200), CHAR(20),INTEGER;
--Regresa el número de cliente. nombre o razon social y rfc

DEFINE cCodRet		CHAR(5);
DEFINE cNumCte		CHAR(9);
DEFINE cNombreCte	CHAR(200);
DEFINE cRFC			CHAR(20);
DEFINE iSqlerr		INTEGER;

BEGIN
    ON EXCEPTION SET iSqlerr
      IF iSqlerr <> 0 THEN
         let cCodRet = iSqlerr;
         Return cCodRet, cNumCte, cNombreCte, cRFC, iRegistro;
      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_Proac_BuscaPorApellidoCliente.out";
--TRACE ON;

LET cCodRet = '00000';
LET cNumCte = '';
LET cNombreCte = '';
LET cRFC = '';
	
	IF pApellidoMaterno IS NULL AND pApellidoPaterno IS NULL OR iRegistro IS NULL THEN
		LET cCodRet = '08382';
		Return cCodRet, cNumCte, cNombreCte, cRFC, iRegistro;
	END IF
	FOREACH 
		SELECT SKIP iRegistro FIRST 5
		numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre, rfc 
		INTO cNumCte,cNombreCte,cRFC
	    FROM bdinteg:si_cliente
		WHERE apell_paterno = TRIM(pApellidoPaterno)
		AND apell_materno  = TRIM(pApellidoMaterno)
		
		IF cNumCte IS NULL OR cNombreCte IS NULL OR cRFC IS NULL THEN
			LET cCodRet = '08383';
		END IF
		LET iRegistro = iRegistro + 1;
		Return cCodRet, TRIM(cNumCte), TRIM(cNombreCte), TRIM(cRFC), iRegistro WITH RESUME;
	END FOREACH;
	
	
END 
END PROCEDURE
DOCUMENT
'Autor: Antonio Bastidas',
'Descripcion: Se creo proceso para consulta por apellido de clientes',
'Version: 20090701.1731',
'Fecha: 01/07/2009',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_calc_proximoanio(pFecha_hoy date)
Returning CHAR(5),DATE,CHAR(30),CHAR(30);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE dFecha_prox_ano DATE;
DEFINE vAno,vAno2,vAno3		INTEGER;
DEFINE vMes,vMes2 	INTEGER;
DEFINE vDia,vDia2		Char(2);
DEFINE cNueFecha_hoy,cNueFecha_Prox CHAR(30);
DEFINE cMesNuevo CHAR(10);
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,dFecha_prox_ano,cNueFecha_hoy,cNueFecha_Prox;
      END IF;
END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_Calc_ProximoAnio.out";
--TRACE ON;
LET dFecha_prox_ano = '01-01-1900';
LET vAno3 = YEAR(pFecha_hoy);
LET vAno = MOD (YEAR(pFecha_hoy),4);
LET vMes = MONTH(pFecha_hoy);
LET vDia = LPAD(day(pFecha_hoy),2,0);

	IF vAno = 0 And vMes < 3 THEN
	IF vMes = 2 AND vDia = '29' THEN
		LET vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 365;
	END IF;
		let vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 366;
	ELSE
		LET vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 365;
	END IF;
	LET vAno2 = YEAR(dFecha_prox_ano);
	LET vMes2 = MONTH(dFecha_prox_ano);
	LET vDia2 = LPAD (day(dFecha_prox_ano),2,0);


	If vMes = 1 Then
		LET cMesNuevo = 'Enero';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;

	End If;
	If vMes = 2 Then
		LET cMesNuevo = 'Febrero';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 3 Then
		LET cMesNuevo = 'Marzo';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 4 Then
		LET cMesNuevo = 'Abril';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 5 Then
		LET cMesNuevo = 'Mayo';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 6 Then
		LET cMesNuevo = 'Junio';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 7 Then
		LET cMesNuevo = 'Julio';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 8 Then
		LET cMesNuevo = 'Agosto';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 9 Then
		LET cMesNuevo = 'Septiembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 10 Then
		LET cMesNuevo = 'Octubre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 11 Then
		LET cMesNuevo = 'Noviembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0)||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 12 Then
		LET cMesNuevo = 'Diciembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;

	Return vcodret,dFecha_prox_ano,cNueFecha_hoy,cNueFecha_Prox;
END
END PROCEDURE
DOCUMENT

    'AUTOR      : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Calcular La fecha que recibe de parametro un año más considerando el año bisiesto',
	              'Y da la fecha_hoy y la fecha proximo año en el formato 01 de enero de 2009',
    'FECHA      : Febrero de 2009',
	'VERSION    : 200902',
	'MODIFICO   : JOSE ALMEIDA',
	'DESCRIPCION: SE CAMBIO DE MAyo A Mayo',
	'FECHA      : JULIO 10 de 2009',
    'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_consultarincripcioncuentaproac(pCuenta CHAR(20))
Returning CHAR(5);

DEFINE vcodret 			CHAR(5);
DEFINE vsqlerr			INTEGER;


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret with resume;

      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ConsultarIncripcionCuentaProac";
--TRACE ON;
	LET vcodret = "00000"; -- si no existe manda 00000
	IF EXISTS (SELECT cta_eje FROM  bdicheq:sc_proac WHERE TRIM(sc_proac.cta_eje) = TRIM(pCuenta)) THEN----   si existe la cuenta manda 10000
		LET vcodret = "10000"; -- --- si existe la cuenta manda 10000
	END IF;
	Return vcodret;
END
END PROCEDURE
DOCUMENT
'Autor   		: César Valdéz Figueroa',
'DESCRIPCION		: Este procedimiento busca si existe una cuenta X en el campo cuenta_eje de la tabla PROAC',
'FECHA			: 01 de Julio 2009',
'VERSION		: 20090701',
'BD				: BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_reportectasinsocanc(pIndicador CHAR(1),pSucursal CHAR(4),pFechaIni CHAR(10),pFechaFin CHAR(10),pTipoCta CHAR(4),pStatus INTEGER)
Returning CHAR(5),CHAR(4),CHAR(20),DATE,CHAR(20),CHAR(4),CHAR(20),CHAR(20),CHAR(10);

DEFINE vcodret 						CHAR(5);
DEFINE vsqlerr,iExiste,iCteBusq		INTEGER;
DEFINE cCta_Eje,cNumCte,cTpoOpe		CHAR(20);
DEFINE dFecha_alta,dFecha_canc 		CHAR(10);
DEFINE iActiva,iCancelada,iBloqueada CHAR (1);
DEFINE cSucursal,cProducto			CHAR (4);
DEFINE cCuentaPROAC 				CHAR(20);
DEFINE cStatus_Cta					CHAR(1);
DEFINE cDescripcionStatus			CHAR(10);
DEFINE iSecuencia					INTEGER;
DEFINE iBand    					INTEGER;

BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with resume;

      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ReporteCtasInsOCanc.out";
--TRACE ON;
	LET vcodret = "00000";
	LET iSecuencia = 0;
	LET cCta_Eje = "";
	LET dFecha_alta = "";
	LET iActiva = "";
	LET iCancelada = "";
	LET iBloqueada = "";
	LET cSucursal = "";
	LET cProducto = "";
	LET cNumCte = "";
	LET cTpoOpe = "";
	LET dFecha_canc = "";
	LET cCuentaPROAC = "";
	LET cStatus_Cta = "";
	LET cDescripcionStatus = "";
	LET iBand = 0;
	If pIndicador = "1" THEN
		IF pStatus = 0 THEN
			LET iActiva = "1";
			LET iCancelada = "";
			LET iBloqueada = "3";
		ELIF pStatus = 1 OR pStatus = 4 THEN
			LET iActiva = "1";
			LET iCancelada = "";
			LET iBloqueada = "";
		ELIF pStatus = 3 THEN
			LET iActiva = "";
			LET iCancelada = "";
			LET iBloqueada = "3";
		END IF;
		LET cTpoOpe = "INSCRITAS";
		LET cTpoOpe= Trim(cTpoOpe);
	End if;
	If pIndicador = "2" THEN
		LET iActiva = "";
		LET iCancelada = "2";
		LET iBloqueada = "";
		LET cTpoOpe = "CANCELADAS";
		LET cTpoOpe= Trim(cTpoOpe);
	End if;
	IF pFechaIni Is Null Or pFechaIni = "" Then
		LET pFechaIni = "01/01/1900";
	End if;

	IF pFechaFin Is Null Or pFechaFin = ""  Then
		LET pFechaFin = "01/01/2999";
	End if;

	If pIndicador = "1" THEN----------         INSCRITAS
	  ForEach
		Select Distinct (pro.cta_eje),mae.producto,pro.sucursal,pro.fecha_alta,pro.num_cte ,pro.fecha_canc,pro.cuenta,pro.status_cta
		Into cCta_Eje,cProducto,cSucursal,dFecha_alta,cNumCte,dFecha_canc,cCuentaPROAC,cStatus_Cta
		From sc_proac as pro
		Inner Join sc_maechq as mae On mae.cuenta = pro.cta_eje
		Where pro.status_cta in (iActiva ,iCancelada,iBloqueada)
		And pro.sucursal =  CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTipoCta = "" THEN mae.producto  ELSE pTipoCta END
		And pro.fecha_alta >= trim(pFechaIni)
		And pro.fecha_alta <= trim(pFechaFin)
		Order by pro.sucursal,pro.fecha_alta,mae.producto,pro.num_cte ,pro.cta_eje
		---definir el status 1- Activa  3 - Bloqueada   Secuencia > 1 y Estado = 1 -- Reinscrita
		LET cDescripcionStatus = '';
		IF cStatus_Cta = 1 OR cStatus_Cta = 4 THEN ---si el status es 1
			LET cDescripcionStatus = 'INSCRITA';
			---Obtener la secuencia de la cuenta eje  si la tiene
			SELECT MAX(secuencia) into iSecuencia FROM sc_proac WHERE cta_eje = cCta_Eje;
			IF iSecuencia > 1 THEN ---si el status es 1 y la secuencia es  > a 1 es reincrita
				LET cDescripcionStatus = 'REINSCRITA';
			END IF;
			LET iBand = 0;
			IF  pStatus = 1 THEN --inscrita
				IF cDescripcionStatus = 'REINSCRITA' THEN
					LET iBand = 1;
				END IF;
			ELIF pStatus = 4 THEN --- reinscrita
				IF cDescripcionStatus = 'INSCRITA' THEN
					LET iBand = 1;
				END IF;
			END IF;
		ELSE---si no  el status es 3 bloqueada
			LET cDescripcionStatus = 'BLOQUEADA';
		END IF;
		IF iBand <> 1 THEN
			Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with Resume;
		END IF;
		LET iBand = 0;
	  End ForEach
	End if;
	If pIndicador = "2" THEN------------------------        CANCELADAS
	  ForEach
		Select Distinct (pro.cta_eje),mae.producto,pro.sucursal,pro.fecha_alta,pro.num_cte ,pro.fecha_canc,pro.cuenta
		Into cCta_Eje,cProducto,cSucursal,dFecha_alta,cNumCte,dFecha_canc,cCuentaPROAC
		From sc_proac as pro
		Inner Join sc_maechq as mae On mae.cuenta = pro.cta_eje
		Where pro.status_cta in (iActiva ,iCancelada,iBloqueada)
		And pro.sucursal =  CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTipoCta = "" THEN mae.producto  ELSE pTipoCta END
		And pro.fecha_canc >= trim(pFechaIni)
		And pro.fecha_canc <= trim(pFechaFin)
		Order by pro.sucursal,pro.fecha_alta,mae.producto,pro.num_cte ,pro.cta_eje
		LET dFecha_alta = dFecha_canc;
	  Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with Resume;
	  End ForEach
	End if;
END
END PROCEDURE
DOCUMENT

    'AUTOR      : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Mostrar las cuentas PROAC Activas & Bloqueadas  si el parametro de entrada es "pIndicador = 1"',
					', si el parametro de entrada es "pIndicador = 2" entonces te muestra las canceladas. La Informacion la Pasa a un rpt',
					', Junto a esto se puede hacer un filtrado por sucursal, rango de fechas (y/o) producto de la cuenta',
    'FECHA		: Febrero 2009',
	'VERSION	: 200902',
    'BD			: BDICHEQ',
	'Modifico   : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Se modifico el formato de la fecha el cual, en algunos servidores no funcionaba correctamente "MDY"',
    'FECHA		: Abril 2009',
	'VERSION	: 200904',
    'BD			: BDICHEQ',
	'Modifico   : César Valdéz Figueroa',
	'DESCRIPCION: Se modifico para que el reporte regresara unos datos mas como son cuenta PROAC y el estatus en lo que es cuentas inscritas',
	'             en cuentas canceladas solo regresara la cuenta PROAC, ademas se agrego un filtrado por status',
    'FECHA		: 30 de Junio 2009',
	'VERSION	: 20090630',
    'BD			: BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_reportemovpremiosredondeo(pSucursal CHAR(4),pFechaIni CHAR(10),pFechaFin CHAR(10), pTpoCta CHAR(4))
Returning CHAR(5),CHAR(4),CHAR(4),CHAR(20),CHAR(20),DATE,MONEY(14,2),MONEY(14,2),MONEY(14,2),SMALLINT;
--cuenta,tipo de cuenta,fecha de inscripcion,fecha de cancelacion y status

DEFINE vcodret 						CHAR(5);
DEFINE vsqlerr,iExiste,iCteBusq		INTEGER;
DEFINE cCuenta_Eje,cNumCte,	cCuenta_PROAC		CHAR(20);
DEFINE cProducto,cSucursal			CHAR (4);
DEFINE cFecha_alta					CHAR (10);
DEFINE cTransaccCargoPROAC,cTransaccPremioPROAC,cReg1 SMALLINT;
DEFINE sPromedio		 		MONEY(14,2);
DEFINE mAhorro, mPremio				MONEY(14,2);

  


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,cSucursal,cProducto,cNumCte,cCuenta_Eje,cFecha_alta,mAhorro,mPremio,sPromedio,cReg1;
		 
      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ReporteMovPremiosRedondeo.out";
--TRACE ON;
	LET vcodret = "00000";
	LET cCuenta_Eje = "";
	LET cProducto = "";
	LET cNumCte = "";
	LET cSucursal = "";
	LET cTransaccCargoPROAC = 0;
	LET cTransaccPremioPROAC = 0;
	LET sPromedio = 0;
	LET cReg1 = 0;
	LET cFecha_alta = "01/01/1900";
	LET mAhorro = 0;
	LET mPremio = 0;
	LET cCuenta_PROAC = "";
	
Select valor Into cTransaccCargoPROAC From sc_param Where codparam = 'PROACTRANSACCCARGO';
Select valor Into cTransaccPremioPROAC From sc_param Where codparam = 'PROACABONOPREMIO';

-- movimientos de los cargos por redondeo
	FOREACH --With Hold
	
		Select Distinct (pro.cta_eje),pro.num_cte,pro.sucursal,pro.fecha_alta,mae.producto,pro.cuenta
		Into cCuenta_Eje,cNumCte,cSucursal,cFecha_alta,cProducto,cCuenta_PROAC
		From sc_proac AS pro
		Inner Join sc_maechq  AS mae ON cta_eje = mae.cuenta
		Where pro.sucursal = CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTpoCta = "" THEN mae.producto  ELSE pTpoCta END
		And pro.status_cta in ('1', '3')
	
		LET cReg1 = 0;
		LET mAhorro = 0;
		LET mPremio = 0;
		
		-- movimientos de los abonos por Ahorrado
		
		Select NVL(Sum(monto_tot),0.00),COUNT(cuenta)
		Into mAhorro,cReg1
		From sc_movhis 
		Where empresa = '001'
		And cuenta=   cCuenta_Eje
		And fech_alt >=  pFechaIni
		And fech_alt <= pFechaFin
		And transacc = cTransaccCargoPROAC;


		-- movimientos de los abonos por premio

		Select NVL(Sum(monto_tot),0.00)
		Into mPremio
		From sc_movhis 
		Where empresa = '001'
		And cuenta=   cCuenta_PROAC
		And fech_alt >= pFechaIni
		And fech_alt <= pFechaFin
		And transacc =  cTransaccPremioPROAC;
		
		IF cReg1 = 0 THEN
			LET sPromedio = 0;
			Continue ForEach;
		ELSE
			LET sPromedio = mAhorro / cReg1 ;
		END IF
		Return vcodret,cSucursal,cProducto,cNumCte,cCuenta_Eje,cFecha_alta,mAhorro,mPremio,sPromedio,cReg1 With Resume;
	End ForEach
END
END PROCEDURE
DOCUMENT
    
    'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Llenar los datos del reporte de movimientos de premios y ahorros del cliente PROAC"',
    'FECHA		: Febrero de 2009',
	'VERSION	: 200902',
    'BD			: BDICHEQ',
	'Modificó	: Jesus Antonio Bastidas Lopez, Abigail Vasavilbazo Cañedo',
	'DESCRIPCION: Se valido status cuenta y se trajo premios de cuenta proac',
    'FECHA		: Marzo de 2009',
	'VERSION	: 200903',
    'BD			: BDICHEQ';

Create procedure "informix".sp_proac_traeparametros()
returning char(5),char(100),money,money,money,money,integer,integer,money,money,char(7),money (14,2);
-- Declaración de variables:
DEFINE iSqlerr,iPorcPremio1,iPorcPremio4 			 			 INTEGER;
DEFINE cCodret										 			 CHAR(5);
DEFINE cRangoEdad									 			 CHAR(7);
DEFINE i,iMax,ProductoAux 							 			 INTEGER;
DEFINE Prod,Recb  									 			 CHAR(300);
DEFINE ProductoAuxstr, Producto			   			 			 CHAR(20);
DEFINE cProdProac						   			 			 CHAR(4);
DEFINE mCompMayor, mPremioMaximo, mMontoAhorrado1 	 			 MONEY;
DEFINE mMontoAhorrado4, mMtoPremio1,mMtoPremio4,mMontoPromedio 	 MONEY;

begin
   on exception set iSqlerr
      if iSqlerr <> 0 then
         let cCodret = iSqlerr;
		 LET Recb = "";
         return cCodret,Recb,mCompMayor,mPremioMaximo,mMontoAhorrado1,mMontoAhorrado4,
				iPorcPremio1,iPorcPremio4,mMtoPremio1,mMtoPremio4,cRangoEdad,mMontoPromedio;
      end if;
	end exception;

	--SET DEBUG FILE TO "/tmp//hass/sp_PROAC_TraeParametros.out";
	--TRACE ON;
	
	-- Asignación de variables:
	
	LET iSqlerr =0;
	LET cCodret ='00000';
	LET i = 1 ;
	LET Producto = "";
	LET ProductoAux =0;
	LET mCompMayor = 0.00;
	LET mPremioMaximo = 0.00;
	LET mMontoAhorrado1 = 0.00;
	LET mMontoAhorrado4 = 0.00;
	LET iPorcPremio1 = 0;
	LET iPorcPremio4 = 0;
	LET mMtoPremio1 = 0.00;
	LET mMtoPremio4 = 0.00;
	LET mMontoPromedio = 0.00;
	LET cRangoEdad = "";
	LET cProdProac = "";
	
	Select Count(valor) Into  iMax
	From sc_param 
	Where substr(codparam,1,6) = 'PROAC_' ;
	If  i <= iMax then
		ForEach	 
		Select valor Into ProductoAux
		From sc_param 
		Where substr(codparam,1,6) = 'PROAC_'
		LET ProductoAuxstr = ProductoAux;
		LET producto = 'Producto'||i;
		LET producto = producto;
			Select nombre into Prod
			From sc_producto pr
			Where pr.producto = ProductoAuxstr;
			LET Prod = Prod;
			if i = 1 then
				LET Recb = nvl(trim(Prod),'');
			end if;
			if i > 1 and i < iMax  then
				LET Recb = nvl(trim(Recb),'') ||', '|| nvl(trim(Prod),'') ;		
			end if;
			if i = iMax  then
				LET Recb = nvl(trim(Recb),'') ||' Y '|| nvl(trim(Prod),'') ;		
			end if;
			LET i = i +1;
		End Foreach	
		Select valor Into mCompMayor From sc_param where codparam = 'PROACCOMMAYOR';
		Select valor Into mMontoPromedio From sc_param where codparam = 'PROACPROMREDONDEO';
		Select valor Into mPremioMaximo From sc_param where codparam = 'PROACMAXPREMIO';
		Select valor Into mMontoAhorrado1 From sc_param where codparam = 'PROACMTOAHO1-3';
		Select valor Into mMontoAhorrado4 From sc_param where codparam = 'PROACMTOAHO4-12';
		Select valor Into iPorcPremio1 From sc_param where codparam = 'PROACPORCPREM1-3';
		Select valor Into iPorcPremio4 From sc_param where codparam = 'PROACPORCPREM4-12';
		-- Se añade parametro para el proyecto de Parametrizacion del PROAC
		Select valor Into cProdProac From sc_param where codparam = 'PROACPRODUCTO';
		LET cProdProac = cProdProac;
	If mMontoAhorrado1 Is Not Null And mMontoAhorrado4 Is Not Null And  iPorcPremio1 Is Not Null And  iPorcPremio1 Is Not Null Then
		LET mMtoPremio1 = (mMontoAhorrado1 * iPorcPremio1 )/100;
		LET mMtoPremio4 = (mMontoAhorrado4 * iPorcPremio4 )/100;
	End If;
	Select edad_minima ||'-'||edad_maxima Into cRangoEdad From sc_producto pr where pr.producto = cProdProac;
	return cCodret,Recb,mCompMayor,mPremioMaximo,mMontoAhorrado1,mMontoAhorrado4,
		   iPorcPremio1,iPorcPremio4,mMtoPremio1,mMtoPremio4,cRangoEdad,mMontoPromedio ;
	End if	

	End
	End Procedure
	DOCUMENT	
	'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Genera La validacion de las cuentas PROAC, respecto a las cuenta eje maximo de cuentas ',
					' por numero de cliente y si el producto de la cuenta es participante.',
	'FECHA		: Febrero 2009',
	'MODIFICO   : Clemente Angulo Ballardo',
	'DESCRIPCION: Se parametriza el producto del PROAC',	
	'VERSION	: 20100504.1050',
	'BD			: BDICHEQ';

CREATE PROCEDURE "informix".sp_registraencabezadoedocta
		( pEmpresa 			CHAR(3),
		  pUsuario 			CHAR(8),
		  pCuenta			CHAR(20),
		  pProducto			CHAR(45),
		  pNumTarjeta		CHAR(16),
		  pClabe			CHAR(18),
		  pFechaIni			DATE,
		  pFechaFin			DATE,
		  pSaldoAnterior	MONEY(16,2),
		  pDepositos		MONEY(16,2),
		  pInteresesPagados	MONEY(16,2),
		  pRetiros			MONEY(16,2),
		  pOtrosCargos		MONEY(16,2),
		  pIvaOtrosCargos	MONEY(16,2),
		  pSaldoCorte		MONEY(16,2),
		  pSaldoPromedio	MONEY(16,2),
		  pRetencionISR		MONEY(16,2),
		  pInteresesNetos	MONEY(16,2),
		  pDias				INTEGER,
		  pTasaBruta		MONEY(16,2),
		  pNumCte			VARCHAR(20),
		  pNombreCte		VARCHAR(107),
		  pNumExterior		VARCHAR(10),
		  pNumInterior		VARCHAR(10),
		  pCalle			VARCHAR(30),
		  pColonia			VARCHAR(30),
		  pCiudad			VARCHAR(30),
		  pEstado			VARCHAR(30),
		  pCodPostal		VARCHAR(5),
		  pRFC				VARCHAR(13),
		  pCURP				VARCHAR(20),
		  pFechaAlta		DATE,
		  pSucursal			VARCHAR(40),
		  pRetMesAnt		MONEY(16,2),
		  pCongMesAnt		MONEY(16,2),
		  pSaldoRetenido	MONEY(16,2),
		  pSaldoCongelado	MONEY(16,2),
		  pSobreGiro		MONEY(16,2),
		  ptotOtrosCargos	MONEY(16,2),
		  pGat 				DECIMAL(9,4),
		  pTotretirosefe	money(16,2))
		  
		  
RETURNING  CHAR(5), INTEGER;

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iConsultaMaxima   INTEGER;
LET cCodRet 			= '00000';
LET iSqlErr				= 0;
LET iConsultaMaxima      = 0;

	--SET DEBUG FILE TO "/tmp/sp_RegistraEncabezadoEdoCta.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, iConsultaMaxima;
		END IF;
	END EXCEPTION;

	

	set isolation to dirty read;

	--DELETE {+ INDEX(bdicheq:vedocta idx_usu1)} FROM bdicheq:vedocta
	--WHERE cod_usuario = pUsuario;

	--DELETE {+ INDEX(bdicheq:vedoctamov idx_usu)} FROM bdicheq:vedoctamov
	--WHERE cod_usuario = pUsuario;

	SELECT MAX(consulta)
	INTO iConsultaMaxima
	FROM vedocta
	WHERE empresa = pEmpresa
	AND cod_usuario = pUsuario;
	--AND cuenta = pCuenta;
	
	IF iConsultaMaxima is null then
		LET iConsultaMaxima = 1 ;
	else
		LET iConsultaMaxima = iConsultaMaxima + 1;
	end if;	

	
	
	INSERT INTO vedocta
		(empresa, cod_usuario, Cuenta, Producto, tarjeta,Clabe, Fechaini, Fechafin, SaldoAnterior, Depositos,
		InteresesPagados, Retiros, OtrosCargos, IvaOtrosCargos, SaldoCorte,SaldoPromedio, RetencionIsr,
		InteresesNetos, Dias, TasaBruta,NumeroCliente, NombreCliente, NumeroExterior, NumeroInterior, Calle,
		Colonia, Ciudad, Estado, CodigoPostal, Rfc,CURP, FechaAlta, Sucursal,ret_mes_ant, cong_mes_ant,
		sdo_retenido, sdo_cong, sobregiro, consulta, tototroscargos, porcientogat, totretirosefec)
	VALUES
		(pEmpresa,pUsuario,pCuenta,pProducto,pNumTarjeta,pClabe,pFechaIni,pFechaFin,pSaldoAnterior,
		pDepositos,pInteresesPagados,pRetiros,pOtrosCargos,pIvaOtrosCargos,pSaldoCorte,pSaldoPromedio,
		pRetencionISR,pInteresesNetos,pDias,pTasaBruta,pNumCte,pNombreCte,pNumExterior,pNumInterior,
		pCalle,pColonia,pCiudad,pEstado,pCodPostal,pRFC,pCURP,pFechaAlta,pSucursal,pRetMesAnt,pCongMesAnt,
		pSaldoRetenido,pSaldoCongelado,pSobreGiro, iConsultaMaxima,ptotOtrosCargos, pGat, pTotretirosefe);

	IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet, iConsultaMaxima;
END
END PROCEDURE
Document
'DESCRIPCION: Procedimiento que genera el registro para el encabezado de estado de cuenta',
'AUTOR: Antonio Bastidas',
'FECHA: 06 de Enero de 2010',
'VERSION: 20100106.1031',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION: Se agrego validacion para que se obtenga el maximo de la consulta de la cuenta consultada, asi como tambien,  ',
'se agrego para que se regresara al termino del proceso ',
'AUTOR: Hector Bojorquez ',
'FECHA: 02 de Junio de 2010',
'VERSION: 20100602.1631',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION: Se agrego validacion para que se obtenga el maximo de la consulta de la cuenta consultada validando unicamente ',
'                          que la empresa y el usuario sean iguales a los de la consulta en proceso',
'AUTOR: Hector Bojorquez ',
'FECHA: 17 de Junio de 2010',
'VERSION: 20100617.1638',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION:Se agregaron los campos tototroscargos, totretirosefec y porcientogat en el insert a la tabla vedocta',
'AUTOR: Abigail Vasavilbazo Cañedo ',
'VERSION: 20101125.1109';

CREATE PROCEDURE "informix".sp_proac_edocta(pEvalua CHAR(1),pUsuario CHAR(8),pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT, pConsMax INTEGER)
RETURNING CHAR(5),CHAR(3), CHAR(10), CHAR(10), CHAR(20),CHAR(10), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),MONEY(14, 2),MONEY(14, 2),CHAR (10);
	--Declara las variables
	DEFINE vCodRet CHAR(5);
	DEFINE vSqlErr, vIsamErr, iAux INTEGER;
	DEFINE vCiclo SMALLINT;
	DEFINE sTransacAbonoRedondeo,sTransacAbonoPremio CHAR(4);
	DEFINE dFechaMov1 DATE;
	DEFINE dFechaMov,dFecha_canc CHAR(10);
	DEFINE cReferencia CHAR(40);
	DEFINE cDescripcion CHAR(50);
	DEFINE mRedondeo, mPremio, mSaldo, mMonto MONEY(14, 2);
	DEFINE mSaldo1, mSaldo2,mGranTotal,mSdo1,mSdo2 MONEY(14, 2);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cCuentaPROAC,cTransacc CHAR(20);

	--Inicializa las variables
	LET vCodRet = "000";
	LET dFechaMov = "";
	LET creferencia = "";
	LET cDescripcion = "";
	LET mRedondeo = 0;
	LET mPremio = 0;
	LET mSaldo = 0;
	LET vCiclo = 0;
	LET dFechaMov1 = "";
	LET cCuentaPROAC = "";
	LET sTransacAbonoRedondeo = "";
	LET sTransacAbonoPremio = "";
	LET cTransacc = "";
	LET mGranTotal = 0;
	LET mSaldo1 = 0;
	LET mSaldo2 = 0;
	LET mSdo1 = 0;
	LET mSdo2 = 0;
	LET dFecha_canc = '';
	
	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSaldo1,mPremio,
				mSaldo2,mGranTotal,dFecha_canc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_PROAC_edocta.out";
		--TRACE ON;

		--Limpia la tabla de movimientos para el reporte por el numero de usuario
		--Delete From vedoctamov_proac Where  cod_usuario = pUsuario;

		--consulta la cuenta proac y su fecha de cancelacion
		Select cuenta,fecha_canc INTO cCuentaPROAC,dFecha_canc From sc_proac Where cta_eje = pCuenta
		AND secuencia = (Select Max(secuencia)From sc_proac Where cta_eje = pCuenta And status_cta in ('1','3'))
		And status_cta in ('1','3');

		--valida que exista la cuenta proac.
		IF cCuentaPROAC is null THEN
			LET vCodRet = '10100';
			RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSaldo1,mPremio,
				mSaldo2,mGranTotal,dFecha_canc;
		End IF;

		Select valor INTO sTransacAbonoRedondeo From sc_param Where codparam = 'PROACTRANSACCABONO';
		Select valor INTO sTransacAbonoPremio   From sc_param Where codparam = 'PROACABONOPREMIO';
		LET pCuenta = pCuenta;
		LET pFechaInicial = pFechaInicial;
		LET pFechaFinal = pFechaFinal;

		--ciclo de busqueda de movimientos por la transaccion de redondeo y premio
		FOREACH
			SELECT
				mm.num_serial, mm.fech_alt,mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,mm.transacc
			INTO
				iAux, dFechaMov1, mMonto, cNaturaleza, mSaldo,cTransacc
			FROM
				bdicheq:sc_movhis AS mm
				Inner Join  bdinteg:si_transacc AS tr ON mm.transacc = tr.numero
			WHERE
				mm.empresa = pEmpresa AND
				mm.cuenta = cCuentaPROAC  AND
				mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
				mm.cancelad <> "S" AND
				mm.empresa = tr.empresa AND
				mm.transacc = tr.numero  AND
				mm.transacc in (sTransacAbonoRedondeo,sTransacAbonoPremio) AND
				tr.se_emite_edocta = "S"
			ORDER BY
				mm.fech_alt ,
				mm.num_serial

			LET mRedondeo = 0;
			LET mPremio = 0;

			--valida si la transaccion es la de redondeo
			IF cTransacc = sTransacAbonoRedondeo  THEN
				LET mRedondeo = mMonto;
				IF mRedondeo = 0.00 THEN
				Else
					--suma todos los redondeos obtenidos con mSaldo1
					LET mSaldo1 = mSaldo1 + mRedondeo;
					If mSdo1 <> mSaldo1 THEN
						LET mSdo1 = mSaldo1;
						LET mPremio = 0;
						LET mSdo2 = 0;
					Else
						LET mSdo1 = 0.00;
					END IF;
				END IF;
			END IF;

			--valida si la transaccion es la de premio
			IF cTransacc = sTransacAbonoPremio  THEN
				LET mPremio = mMonto;
				IF mPremio = 0.00 THEN
				Else
					--suma todos los premios obtenidos con mSaldo2
					LET mSaldo2 = mSaldo2 + mPremio;
					If mSdo2 <>mSaldo2 THEN
						LET mSdo2 = mSaldo2;
						LET mRedondeo = 0;
						LET mSdo1 = 0;
					Else
						LET mSdo2 = 0.00;
					END IF;
				END IF;

			END IF;

			LET vCiclo = vCiclo + 1;

			-- Valida de donde se mando ejecutar el sistema "S" sucursal "C" Central
			IF pEvalua = 'S' THEN
				-- PAGINACION
				IF vciclo <= pRegistro THEN
					CONTINUE FOREACH;
				END IF;
				IF mSaldo1 > 0.00 Then
					LET mGranTotal = mSaldo + mPremio + mRedondeo;
				END If
				IF mSaldo2 > 0.00 Then
					LET mGranTotal = mSaldo + mPremio + mRedondeo;
				END If
				RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				mSdo2,mGranTotal,dFecha_canc WITH RESUME;
			END IF;

			-- Valida de donde se mando ejecutar el sistema "S" sucursal "C" Central
			IF pEvalua = 'C' THEN
				IF pConsMax = 0 OR pConsMax IS NULL THEN
					LET vCodRet = '00001';					
					RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
							mSdo2,mGranTotal,dFecha_canc;
					EXIT FOREACH;
				END IF;

				--Genera el monto acumulado de la cuenta
				LET mGranTotal = mSaldo + mPremio + mRedondeo;

				--inserta los registros obtenidos.
				Insert Into vedoctamov_proac (empresa,cod_usuario,secuencia,cuenta,fechamov,
				importe_redondeo,saldo_redondeo,importe_premio,saldo_premio,total_acumulado,Fecha_canc, consulta)
				Values (pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				mSdo2,mGranTotal,dFecha_canc, pConsMax);
				--RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				--mSdo2,mGranTotal,dFecha_canc WITH RESUME;
			END IF;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : JESUS ANTONIO BASTIDAS LOPEZ',
'DESCRIPCION : LLENA SUB-REPORTE DEL ESTADO DE CUENTA PARA PROAC',
'FECHA       : MARZO DE 2009',
'VERSION     : 200903',
'BD          : BDICHEQ',
'CAMBIO      : JESUS ANTONIO BASTIDAS LOPEZ',
'DESCRIPCION : CORRECCION DEL MONTO ACUMULADO DE LA CUENTA EL CUAL NO SE CALCULABA CORRECTAMENTE',
'FECHA       : ABRIL DE 2009',
'CAMBIO      : CÉSAR ANDRÉS DE ANDA ALCÁNTARA',
'DESCRIPCION : CORRECIÓN EN LA VALIDACIÓN DONDE SE MANDA EJECUTAR EL SISTEMA, EN CASO DE SER "C" (CENTRAL)',
'FECHA       : SEPTIEMBRE DEL 2009',
'VERSION     : 200909',
'BD          : BDICHEQ',
'MODIFICO    : ABIGAIL VASAVILBAZO CAÑEDO',
'MODIFICACION: SE AGREGA PARAMETRO DE ENTRADA (PCONSMAX) Y SE ELIMINA CODIGO DE BORRADO DE LA TABLA VEDOCTAMOV_PROAC',                                                        
'FECHA		 : NOVIEMBRE 2010',
'VERSION	 : 20101103.1242';

Create Procedure "informix".sp_nominatotalivacomision( cNombreArchivo           Char(17),
                                                       mValorIva                Money(14,2),
                                                       mValorComisionDispercion Money(14,2) )
Returning Char(3), 
          Char(100), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3);
          
    --- Realizo   : Martín Valenzuela Ojeda
    --- Proyecto  : Dispercion Nomina BanCoppel
    --- Actividad : Calcula el Total del Iva y de la Comision de Disperción para todos los Empleados que hayan sido Aplicados (status = 1,3)
    --- Fecha     : Abril-2008
    
    Define mImporteTotalAplicado        Money(14,3);
    Define cCodRet                      Char(3);
    Define cMensaje                     Char(100);
    Define iNumeroRegistrosAplicados    Integer ;
    Define mTotaliva                    Money(14,3);
    Define mTotalComision               Money(14,3);
    Define mTotalPagado                 Money(14,3);
    Define mTotalCargo                  Money(14,3);
    Define mTotalNoPagado			    Money(14,3);
    DEFINE  vsqlerr                     Integer ;

    Let cCodRet = '000';
    Let cMensaje = "";
    Let mImporteTotalAplicado = 0;
    Let iNumeroRegistrosAplicados = 0;
    Let mTotaliva = 0;
    Let mTotalComision = 0;
    Let mTotalPagado = 0;
    Let mTotalCargo = 0;
    Let mTotalNoPagado = 0;

    --- Set debug file to "/tmp/sp_nominatotalivacomision.out";
    --- Trace on;

    Begin

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            Let cCodRet = vsqlerr;
            Let cMensaje  = "Error Marcado Por Informix";
            Return cCodRet, cMensaje, null, null, null, null, null;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    If (Trim(cNombreArchivo) <> "") And (mValorIva is not Null Or mValorComisionDispercion is not Null ) Then
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(Count(*),0) 
          Into iNumeroRegistrosAplicados
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And (status = '1' Or status = '3');  /* El valor 1 es de Aplicados y el 3 de Cuentas Bloqueadas */

        --- Let mTotaliva = iNumeroRegistrosAplicados * mValorIva;
        --- Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
        
        Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
        Let mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el Iva */
        Let cMensaje = "Calculos de Iva y Comision Efectuados Correctamente";

        /* Se saca el importe abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(sum(importe),0) 
          Into mTotalPagado
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And status = '1';

        /* Se saca el importe No abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(sum(importe),0) 
          Into mTotalNoPagado
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And status > '1';

        /* Se saca el cargo total, para evaluar el saldo */
        Let mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
    Else
        Let cCodRet = '170';
        Let cMensaje = "Error: Nombre de Archivo No Valido";
        Let mTotaliva = 0;
        Let mTotalComision = 0;
        
        Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
    End If

    Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
    
    End
    
End Procedure;