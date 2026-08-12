CREATE PROCEDURE "informix".sp_encripta_archivosautoafore(cUsuario CHAR(50))
RETURNING CHAR(6), CHAR(100);

    /*DEFINICION DE VARIABLES*/
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cComando             CHAR(600);
    DEFINE cMensaje             CHAR(100);
    DEFINE iExisteSH            SMALLINT;
    DEFINE cDia                 CHAR(2);
    DEFINE cMes                 CHAR(2);
    DEFINE cAnio                CHAR(4);
    DEFINE cNombreArchivo       CHAR(50);
    DEFINE cIni                 CHAR(6);     
    DEFINE cIniOB               CHAR(2);
    DEFINE cCons                CHAR(40);
    DEFINE cNombreArchivoRes    CHAR(30);
    DEFINE cConsecutivo         CHAR(2);
    DEFINE cRutaArchivoOrigen   CHAR(100);
    DEFINE cLlave               CHAR(200);
    DEFINE iReg                 INTEGER;    
    DEFINE cHoraActual          DATETIME HOUR TO SECOND;
    

    /*INICIALIZACION DE VARIABLES*/
    LET cCodRet             = '00000';
    LET cMensaje            = 'ENCRIPTACION CORRECTA';
    LET cComando            = '';
    LET iExisteSH           = 0;
    LET cDia                = '';
    LET cMes                = '';
    LET cAnio               = '';
    LET cNombreArchivo      = '';
    LET cIni                = '';
    LET cIniOB              = '';
    LET cCons               = '--armor --compression --output .';
    LET cNombreArchivoRes   = '';
    LET cConsecutivo        = '';
    LET cRutaArchivoOrigen  = '';
    LET cLlave              = '';
    LET iReg                = 0;
    LET cHoraActual         = CURRENT HOUR TO SECOND;


    --SET DEBUG FILE TO '/informix/alex/sp_encripta_archivosautoafore.out';
    --TRACE ON;

    BEGIN
      
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN

                INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
                VALUES ('EncArchAutoAfore',cNombreArchivoRes,iSqlErr,'El comando del sistema no puede ser ejecutado',cUsuario,today,cHoraActual);

                LET cCodRet = '00000';
                LET cMensaje = 'ENCRIPTACION CORRECTA';
                RETURN cCodRet, cMensaje;
            END IF            
        END EXCEPTION;

        ON EXCEPTION SET iSqlErr
            IF iSqlErr = '-668' THEN
           
                INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
                VALUES ('EncArchAutoAfore',cNombreArchivoRes,iSqlErr,'El comando del sistema no puede ser ejecutado',cUsuario,today,cHoraActual);
                
                IF TRIM(cIni) = 'CONF' OR TRIM(cIni) = 'CONT' THEN
                    FOREACH

                        SELECT nombre_arch INTO cNombreArchivo
                        FROM pp_arch_afore WHERE fecha_insert = TODAY and nombre_arch like '%OB%'

                        LET cIni = SUBSTR(cNombreArchivo,1,4) || 'OB';
                        LET cConsecutivo = SUBSTR(cNombreArchivo, 24,2); 
                        
                        LET cNombreArchivoRes = TRIM(cIni) || cDia || cMes || cAnio || '.BCOPPEL.' || cConsecutivo;

                         --Genera el archivo "encripta_archivosautoafore.sh" en la ruta origen que se recibio como parametro en el cual escribe los comandos necesarios
                        --para exportar las variables de ambiente PATH y HOME, que se necesitan para poder encriptar archivos con PGP
                        LET cComando = 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(cUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/sysafore/bin">' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando; 

                        LET cComando = 'echo "export HOME=/home/' || TRIM(cUsuario) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando;

                        --Escribe en "encripta_archivosautoafore.sh" el comando para encriptar el archivo		
                        LET cComando = 'echo "/opt/pgp/bin/pgp --encrypt -i ' || TRIM(cNombreArchivoRes) || ' -r ' || '''' || TRIM(cllave) ||''''|| ' ' || TRIM(cCons) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando;

                        --Asigna permisos a "encripta_archivosautoafore.sh"
                        LET cComando = 'chmod 777 ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando;

                        --Ejecuta el bash "encriptaarchivo.sh"
                        LET cComando = '/usr/bin/sh ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        --|| TRIM(cRutaArchivoOrigen) ||'salida.out 2>&1" sysafore';
                        SYSTEM cComando;

                    END FOREACH;    
                END IF

                IF TRIM(cIni) = 'CONFOB' OR TRIM(cIni) = 'CONTOB' THEN
                    FOREACH

                        SELECT nombre_arch INTO cNombreArchivo
                        FROM pp_arch_afore WHERE fecha_insert = TODAY and nombre_arch not like '%OB%' and nombre_arch not LIKE '%PA%'

                        LET cDia = LPAD(DAY(today::DATE), 2, '0');
                        LET cMes = LPAD(MONTH(today::DATE), 2, '0');
                        LET cAnio = LPAD(YEAR(today::DATE),4,'0');

                        LET cIni = SUBSTR(cNombreArchivo,1,4);
                        LET cConsecutivo = SUBSTR(cNombreArchivo, 22,2); 
                        
                        LET cNombreArchivoRes = TRIM(cIni) || cDia || cMes || cAnio || '.BCOPPEL.' || cConsecutivo;

                         --Genera el archivo "encripta_archivosautoafore.sh" en la ruta origen que se recibio como parametro en el cual escribe los comandos necesarios
                        --para exportar las variables de ambiente PATH y HOME, que se necesitan para poder encriptar archivos con PGP
                        LET cComando = 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(cUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/sysafore/bin">' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando; 

                        LET cComando = 'echo "export HOME=/home/' || TRIM(cUsuario) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando;

                        --Escribe en "encripta_archivosautoafore.sh" el comando para encriptar el archivo		
                        LET cComando = 'echo "/opt/pgp/bin/pgp --encrypt -i ' || TRIM(cNombreArchivoRes) || ' -r ' || '''' || TRIM(cllave) ||''''|| ' ' || TRIM(cCons) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        SYSTEM cComando;

                        --Asigna permisos a "encripta_archivosautoafore.sh"
                        LET cComando = 'chmod 777 ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh'; 
                        SYSTEM cComando;

                        --Ejecuta el bash "encriptaarchivo.sh"
                        LET cComando = '/usr/bin/sh ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                        --|| TRIM(cRutaArchivoOrigen) ||'salida.out 2>&1" sysafore';
                        SYSTEM cComando;

                    END FOREACH;    
                END IF

                LET cCodRet = '00000';
                LET cMensaje = 'ENCRIPTACION CORRECTA';

                RETURN cCodRet, cMensaje;
           
            END IF
        END EXCEPTION;


        -- Se verifica el usuario
        IF cUsuario <> 'sysafore' THEN
            LET cCodRet = '00001';
            LET cMensaje = 'USUARIO NO VALIDO';
            RETURN cCodRet, cMensaje;
        END IF    

        -- Se verifica si existen archivos del dia actual
        SELECT COUNT(*) INTO iReg FROM pp_arch_afore WHERE fecha_insert = TODAY;
        IF iReg = 0 THEN
            LET cCodRet = '00002';
            LET cMensaje = 'NO EXISTEN ARCHIVOS POR ENCRIPTAR';
            RETURN cCodRet, cMensaje;
        END IF

        LET cDia = LPAD(DAY(today::DATE), 2, '0');
        LET cMes = LPAD(MONTH(today::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(today::DATE),4,'0');

        -- Se extrae la ruta de los archivos de Afore
        SELECT valor INTO cRutaArchivoOrigen 
        FROM bdiprog:pp_parametros where cve_param = '100';

        -- Se extrae la llave de encriptacion
        SELECT llave INTO cLlave
        FROM bdinteg:si_configura_pgp WHERE codigo = 'AFORE_01';

        -- Se recorren los archivos, los que sean de tipo CONT, CONF, CONTOB y CONFOB serán encriptados
        FOREACH

            -- Se recorren los archivos del día actual
            SELECT nombre_arch INTO cNombreArchivo
            FROM pp_arch_afore WHERE fecha_insert = TODAY 

            LET cIni  = '';
            LET cIni =  SUBSTR(cNombreArchivo,1,4);
            LET cIniOB =  SUBSTR(cNombreArchivo,5,2);

            -- Se verifica si el archivo es de tipo OB
            IF TRIM(cIniOB) = 'OB' THEN
                LET cIni = TRIM(cIni) || TRIM(cIniOB);
                LET cConsecutivo = SUBSTR(cNombreArchivo, 24,2);
            ELSE
                LET cConsecutivo = SUBSTR(cNombreArchivo, 22,2);
            END IF

            IF TRIM(cIni) = 'CONT' OR TRIM(cIni) = 'CONF' OR TRIM(cIni) = 'CONFOB' OR TRIM(cIni) = 'CONTOB' THEN

                LET cNombreArchivoRes = TRIM(cIni) || cDia || cMes || cAnio || '.BCOPPEL.' || cConsecutivo ;
           
                --Genera el archivo "encripta_archivosautoafore.sh" en la ruta origen que se recibio como parametro en el cual escribe los comandos necesarios
                --para exportar las variables de ambiente PATH y HOME, que se necesitan para poder encriptar archivos con PGP
                LET cComando = 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(cUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/sysafore/bin">' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                SYSTEM cComando; 

                LET cComando = 'echo "export HOME=/home/' || TRIM(cUsuario) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                SYSTEM cComando;

                --Escribe en "encripta_archivosautoafore.sh" el comando para encriptar el archivo		
                LET cComando = 'echo "/opt/pgp/bin/pgp --encrypt -i ' || TRIM(cNombreArchivoRes) || ' -r ' || '''' || TRIM(cllave) ||''''|| ' ' || TRIM(cCons) || '">>' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                SYSTEM cComando;

                --Asigna permisos a "encripta_archivosautoafore.sh"
                LET cComando = 'chmod 777 ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                SYSTEM cComando;

                --Ejecuta el bash "encriptaarchivo.sh"
                LET cComando = '/usr/bin/sh ' || TRIM(cRutaArchivoOrigen) || 'encripta_archivosautoafore_' || TRIM(cIni) || '.sh';
                --|| TRIM(cRutaArchivoOrigen) ||'salida.out 2>&1" sysafore';
                SYSTEM cComando;

            ELSE
                CONTINUE FOREACH;
            END IF

        END FOREACH;
       
        RETURN cCodRet, cMensaje;
    END
END PROCEDURE;