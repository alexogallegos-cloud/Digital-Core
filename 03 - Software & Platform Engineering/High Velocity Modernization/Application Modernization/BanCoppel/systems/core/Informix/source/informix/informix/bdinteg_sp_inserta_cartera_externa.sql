CREATE PROCEDURE "informix".sp_inserta_cartera_externa(
    pCte        CHAR(20),   -- ParÃ¡metro de entrada: NÃºmero de cliente
    pRfc        CHAR(13),   -- ParÃ¡metro de entrada: RFC del cliente (clave de bÃºsqueda)
    pModulo     CHAR(1)     -- ParÃ¡metro de entrada: MODULO para identificar de donde se esta consultando Cartera Externa
)
    RETURNING
    CHAR(6);   -- CÃ³digo de Retorno de la operaciÃ³n

    -- #################################
    -- # 1. DECLARACIÃN DE VARIABLES
    -- #################################
    DEFINE vCodRet          CHAR(6);    -- Almacena el cÃ³digo de retorno de la operaciÃ³n
    DEFINE iSqlErr          INTEGER;    -- Almacena el SQLCODE en caso de error
    DEFINE iSamErr          INTEGER;    -- Almacena el ISAMCODE en caso de error
    DEFINE cVarDataErr      VARCHAR(64);    
    -- Variables para capturar datos existentes antes de historizar
    DEFINE l_numcte_exist   CHAR(20);
    DEFINE l_rfc_exist      CHAR(13);
    DEFINE l_modulo_exist   CHAR(1);    -- Asumiendo '001' es CHAR(3)
    DEFINE l_fecha_exist    DATETIME YEAR TO SECOND;       -- Asumiendo 'fecha' es de tipo DATE

BEGIN
    -- #################################
    -- # 2. MANEJO DE EXCEPCIONES GENERAL
    -- #################################
    -- Este bloque ON EXCEPTION captura cualquier error SQL inesperado que ocurra
    -- dentro del procedimiento. Asigna el SQLCODE como cÃ³digo de retorno.
    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        -- Asignar el SQLCODE como cÃ³digo de retorno, rellenando con ceros a la izquierda
        LET vCodRet = LPAD(iSqlErr::VARCHAR(6), 6, '0');
        RETURN vCodRet;
    END EXCEPTION;

    -- #################################
    -- # 3. INICIALIZACIÃN DE VARIABLES
    -- #################################
    -- Establecer el cÃ³digo de retorno por defecto a Ã©xito
    LET vCodRet = '000000';

    -- ConfiguraciÃ³n de sesiÃ³n para rendimiento (si es necesario)
        SET OPTIMIZATION HIGH;
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
    -- #################################
    -- # 4. VALIDACIÃN DE PARÃMETROS DE ENTRADA
    -- #################################
    -- Verificar que AL MENOS UNO de los parÃ¡metros esenciales (pCte o pRfc) no estÃ© vacÃ­o.
    IF (pCte IS NULL OR TRIM(pCte) = '') AND (pRfc IS NULL OR TRIM(pRfc) = '') THEN
        LET vCodRet = '000001'; -- CÃ³digo de error: Ambos parÃ¡metros de bÃºsqueda estÃ¡n vacÃ­os        
        RETURN vCodRet;
    END IF;

    -- #################################
    -- # 5. LÃGICA DE INSERCIÃN O ACTUALIZACIÃN (CON HISTORIAL)
    -- #################################
    -- Se intenta encontrar el registro por RFC para determinar si ya existe.
    -- El bloque ON EXCEPTION IN (100) gestionarÃ¡ el escenario de "no data found".
    BEGIN
        ON EXCEPTION IN (100) -- SQLCODE 100 es para "no data found"
            -- Si NO se encontrÃ³ el registro con el RFC, es una nueva inserciÃ³n.
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (pCte, pRfc, CURRENT, pModulo); -- Se asume 'fecha' y se usa TODAY.
                 
            
            RETURN vCodRet; -- Retorna '000000' (Ã©xito) y finaliza el SP.
        END EXCEPTION;
        
        -- Si llegamos aquÃ­, el registro con el RFC EXISTE.
        -- Se capturan los datos actuales para el historial antes de modificarlo.
        SELECT numcte, rfc, fecha, Modulo
        INTO l_numcte_exist, l_rfc_exist, l_fecha_exist, l_modulo_exist
        FROM bdinteg:si_cartera_externa
        WHERE 1 = 1 -- CondiciÃ³n base, siempre verdadera, para encadenar las siguientes
        AND (
            -- BÃºsqueda por RFC (si pRfc tiene valor)
            (TRIM(pRfc) <> '' AND TRIM(rfc) = TRIM(pRfc))
            OR
            -- BÃºsqueda por NÃºmero de Cliente (si pCte tiene valor)
            (TRIM(pCte) <> '' AND TRIM(numcte) = TRIM(pCte))
        );

        -- #################################
        -- # 5.1. VALIDACIÃN DE DATOS PARA HISTORIAL (opcional, si los campos pueden ser NULL)
        -- #################################
        -- Asegurar que los datos para el historial no sean nulos si las columnas no lo permiten
        IF l_numcte_exist IS NULL OR TRIM(l_numcte_exist) = '' THEN
            LET l_numcte_exist = TRIM(pCte); -- Usar el nuevo cliente si el viejo era nulo/vacÃ­o
            
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc,  fecha, Modulo)
            VALUES (pCte, pRfc,  CURRENT, pModulo);
        ELSE
       
            IF l_fecha_exist IS NULL THEN
                LET l_fecha_exist = CURRENT; -- Usar la fecha actual si la fecha del registro era nula
            END IF;
   
            -- #################################
            -- # 5.2. MOVER A HISTORIAL, BORRAR Y RE-INSERTAR
            -- #################################
            -- 1. Insertar el registro existente en la tabla de historial
            INSERT INTO si_his_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (l_numcte_exist, l_rfc_exist, l_fecha_exist, l_modulo_exist); -- Usamos los datos capturados y validados
            -- 2. Eliminar el registro de la tabla principal.
            --    La clÃ¡usula WHERE se adapta para buscar por pCte, pRfc, o ambos,
            --    utilizando la misma lÃ³gica de identificaciÃ³n que en el SELECT.
            DELETE FROM bdinteg:si_cartera_externa
            WHERE 1 = 1 -- CondiciÃ³n base, siempre verdadera, para encadenar las siguientes
            AND TRIM(numcte) = TRIM(pCte);
            
            -- 3. Insertar el nuevo registro (o la "actualizaciÃ³n") en la tabla principal
            -- La fecha del nuevo registro siempre serÃ¡ TODAY.
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (pCte, pRfc,  current, pModulo);
            
        END IF;
    END; -- Fin del bloque BEGIN/END que maneja la lÃ³gica de existencia

    -- #################################
    -- # 6. RETORNO FINAL
    -- #################################
    -- Si el SP llega a este punto, significa que la operaciÃ³n se completÃ³ exitosamente.
    RETURN vCodRet; -- Retorna '000000' (Ã©xito)
END
END PROCEDURE
DOCUMENT
'Nombre              : sp_inserta_cartera_externa',
'DescripciÃ³n         : Este procedimiento almacenado maneja la inserciÃ³n de nuevos clientes',
'                      o la actualizaciÃ³n de clientes existentes en la tabla "si_cartera_externa".',
'                      Si el cliente ya existe (validado por RFC), su registro actual es movido a',
'                      "si_his_cartera_externa" (historial) y luego se inserta el nuevo registro.',
'                      Si el cliente no existe, se inserta directamente en "si_cartera_externa".',
'Autor               : 99801890 - Miguel Angel Blanco Arechiga',
'Fecha de CreaciÃ³n   : 16/09/2025',
'Solicitado por      : Miguel Esquivel / Estephany Ley',
'Base de Datos       : bdinteg',
'Historial de Cambios: ',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | Fecha        | Autor                               | DescripciÃ³n del Cambio                                                     |',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | 16/09/2025   | M.A. Blanco Arechiga                | CreaciÃ³n inicial del procedimiento.                                        |',
' -----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_insbitsmstelcte(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5), pdigito_ver CHAR(4), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
RETURNING char(5) as codret;
DEFINE iSqlErr			INTEGER;
DEFINE sNumRnd          INTEGER;
DEFINE sNumRnd2         DECIMAL(10,0);
DEFINE sCodigo          CHAR(4);
DEFINE sCodSp           CHAR(5);
DEFINE iMinutos         INTEGER;
DEFINE iReintentos      INTEGER;
DEFINE iEnviados        INTEGER;
DEFINE iMinTrans        INTEGER;
DEFINE sDiferencia      CHAR(30);
DEFINE iExiste          SMALLINT;
DEFINE pCte             CHAR(20);
DEFINE sCodSp2          CHAR(5);
DEFINE sCorreo          CHAR(100);
DEFINE pfecha           DATETIME YEAR TO FRACTION;

LET sNumRnd     =   0;
LET sNumRnd2    =   0;
LET sCodigo     =   '';
LET sCodSp      =   '00000';
LET iMinutos    =   0;
LET iReintentos =   0;
LET iEnviados   =   0;
LET iMinTrans   =   0;
LET sDiferencia =   '';
LET iExiste     =   0;
LET pCte        =   '';
LET pfecha      =   '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

SET ISOLATION TO DIRTY READ;
--SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO '/tmp/anj/sp_insbitsmstel.sql';
--TRACE ON;

IF popcion='1' THEN		
--*****OPCION 1 DE INSERCION*****--



       --IF NOT EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current)) THEN
       SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       LET iExiste = dbinfo("sqlca.sqlerrd2");
       IF iExiste=0 THEN
           INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
	   ELSE
			SELECT FIRST 1 digito_ver INTO pdigito_ver FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       END IF;

       EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
            SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
            IF NVL(sCorreo,'')<>'' THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
            END IF;
       --***ATENCION DEL RQI 63 421***--
        
ELIF popcion='2' THEN
--*****OPCION 2 INSERTAR CODIGO INCORRECTO*****--
        SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
        UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut = pteclea_ejecut
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, bandera, fecha) 
            VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pbandera, current);
ELIF popcion='3' THEN
--*****OPCION 3 ACTUALIZACION CODIGO CORRECTO*****--
        --IF EXISTS (SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL) THEN 
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
            UPDATE si_bitsmstels SET teclea_ejecut=pteclea_ejecut, bandera=pbandera, fecha=CURRENT
                WHERE numcte = pnumcte AND ejecutivo = pejecutivo AND sucursal = psucursal AND fecha = pfecha AND teclea_ejecut IS NULL;
        ELSE
            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, bandera, fecha) 
                              VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pteclea_ejecut, pbandera, current);
        END IF;
        --AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
        IF pbandera<>'F' or pbandera<>'f' THEN
            UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
            UPDATE si_telefonos SET verificado="F" WHERE numcte<> pnumcte and telefono=ptelefono;
        END IF;

ELIF popcion='5' THEN
	--Realizar el ReenvÃÂ­o de nuevo cuando es mantenimiento

        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
        VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);


        EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
			INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
        SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
        IF NVL(sCorreo,'')<>'' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
        END IF;
       --***ATENCION DEL RQI 63 421***--

ELSE
--*****OPCION 4 ENVIO DEL SMS DE NUEVA CUENTA*****--

  --OBTENIENDO LOS PARAMETROS
    --MINUTOS MAXIMO PARA REENVIAR EL SMS
    SELECT TRIM(valor) INTO iMinutos FROM si_param WHERE cod_param='382';
    --CANTIDAD DE REINTENTOS MAXIMOS POR DIA (SOLO REENVIO)
    SELECT TRIM(valor) INTO iReintentos FROM si_param WHERE cod_param='383';


  --OBTENIENDO LA CANTIDAD DE REENVIOS DEL DIA POR CTE-TELEFONO
    SELECT COUNT(*) INTO iEnviados
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND TRIM(teclea_ejecut)='REENVIO SMS'
        AND DATE(fecha)=DATE(current);

  --SI SE SUPERA EL MAXIMO DE SMS REENVIADOS SE DA POR TERMINADO EL SP
    IF  iEnviados>=iReintentos THEN
        RETURN sCodSp;
    END IF;

  --OBTENIENDO LOS MINUTOS QUE HAN TRANSCURRIDO DEL ULTIMO MENSAJE
    SELECT CURRENT-MIN(fecha) INTO sDiferencia
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND DATE(fecha)=DATE(current) AND digito_ver = pdigito_ver;

    IF LENGTH(TRIM(sDiferencia))=16 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 8 for 2) INTO iMinTrans FROM si_fechas;
    ELIF LENGTH(TRIM(sDiferencia))=15 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 7 for 2) INTO iMinTrans FROM si_fechas;   
    ELSE
        select SUBSTRING((TRIM(sDiferencia))  from 6 for 2) INTO iMinTrans FROM si_fechas;   
    END IF;

   --SI LOS MINUTOS OBTENIDOS SON MENORES AL RANGO ESTABLECIDO NO SE ENVIA MENSAJE
   IF iMinTrans<iMinutos THEN
      RETURN sCodSp;
   END IF;

        --IF EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL) THEN
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            --
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels WHERE numcte = pnumcte AND telefono = ptelefono;
            
            UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut='REENVIO SMS'
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        ELSE
            INSERT INTO bdinteg:"informix".si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono,'REENVIO SMS', current);
        END IF;

            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);

            EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL3','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;
            
            --***ATENCION DEL RQI 63 421***--
                --EXTRAYENDO EL E-MAIL DEL CLIENTE
                SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
                IF NVL(sCorreo,'')<>'' THEN
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
                END IF;
            --***ATENCION DEL RQI 63 421***--
        
END IF;  
       RETURN sCodSp;
	END
END PROCEDURE;