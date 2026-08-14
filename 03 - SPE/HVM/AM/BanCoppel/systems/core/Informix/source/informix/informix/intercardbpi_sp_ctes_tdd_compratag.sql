CREATE PROCEDURE "informix".sp_ctes_tdd_compratag( pNumeroMeses VARCHAR(2), pNumMesAnteriorSdo INTEGER )
    
    RETURNING VARCHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, 
        DATE as vFechaInicio, DATE as vFechaFinal;

    DEFINE CODIGO_RETORNO VARCHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE TIPO_PLANTILLA VARCHAR(15);
    DEFINE ID_PLANTILLA CHAR(1);
    DEFINE OCTUBRE CHAR(2);
    
    DEFINE vsql CHAR(1150);
    DEFINE vFechaInicio DATE;
    DEFINE vFechaFinal DATE;
    DEFINE vSaldoPromedio INTEGER;
    DEFINE vNumeroMeses VARCHAR(2);
    DEFINE vTotalRegistros INTEGER;
    DEFINE vNumInicioRegistros INTEGER;
    DEFINE vContadorArchivos VARCHAR(4);
    DEFINE vTotalInterna INTEGER;
    DEFINE vRegistrosMaxPorArchivo INTEGER;
    DEFINE vNumMesAnteriorSdo INTEGER; --Numero de meses anterior al mes actual (saldo promedio)
    DEFINE vAnyoMes CHAR(6);
    DEFINE vPrimerMesTrimestral CHAR(2);
    DEFINE vCamposFechaIntegral CHAR(20);
    DEFINE vPrimerDiaMes DATE;
BEGIN
    -- Los valores de las plantillas:  Valor 1 esta relacionado con la plantilla -> TP_CAPTA
    -- Valor 1 con la plantilla -> TP_CAPTA | Valor 2 con la plantilla -> TNP_CAPTA | Valor 3 con la plantilla -> TAG_CAPTA
    ---Valor 4 con la plantilla -> ATM_CAPTA | Valor 5 con la plantilla -> VENT_CAPTA
    ---Variables sin cambio de asignacion.
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_DESTINO = '/resplogifx/';
    LET TIPO_PLANTILLA = 'TAG_CAPTA';
    LET ID_PLANTILLA = '3';
    LET OCTUBRE = '10';
    
    --SET DEBUG FILE TO RUTA_DESTINO||"sp_ctes_tdd_compratag.out";
    --TRACE ON;
    
    --Variables empleadas en las consultas a la base de datos.
    LET vFechaInicio = '';
    LET vFechaFinal = '';
    LET vSaldoPromedio = 0;
    
    --Variables utilizadas en la creacion de los archivos.
    LET vContadorArchivos = '1';
    LET vNumeroMeses = pNumeroMeses;
    LET vNumInicioRegistros = 0;
    LET vRegistrosMaxPorArchivo = 1;
    LET vTotalRegistros = 0;    
    LET vTotalInterna = 0;
    LET vNumMesAnteriorSdo = pNumMesAnteriorSdo;
    LET vAnyoMes = '';
    LET vPrimerMesTrimestral = '';
    LET vCamposFechaIntegral = '';
    LET vPrimerDiaMes = '';
    
    -->Paso 00. Obtener el RANGO DE FECHAS
    SET ISOLATION TO dirty READ;
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)}
        MONTH(EXTEND(pri_dia_mes) - vNumeroMeses units month), pri_dia_mes
        INTO vPrimerMesTrimestral, vPrimerDiaMes
    FROM bdinteg:si_fechas
        WHERE empresa = '001';
    
    --Campos empleados para la ejecucion del reporte trimestral: abril, julio y octubre.
    LET vCamposFechaIntegral = YEAR(today)||LPAD(MONTH(EXTEND(vPrimerDiaMes) - vNumMesAnteriorSdo units month), 2, "0");

    IF ( vPrimerMesTrimestral = OCTUBRE ) THEN
        --Campos empleados para la ejecucion del reporte trimestral: enero | Cambio de anio.
        LET vCamposFechaIntegral = YEAR(today) - 1||LPAD(MONTH(EXTEND(vPrimerDiaMes) - vNumMesAnteriorSdo units month), 2, "0");
    END IF;
        
    SET ISOLATION TO dirty READ;
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)}
        EXTEND(pri_dia_mes) - vNumeroMeses units month,
        EXTEND(pri_dia_mes),
        vCamposFechaIntegral
        INTO vFechaInicio, vFechaFinal, vAnyoMes
    FROM bdinteg:si_fechas
        WHERE empresa = '001';

    --Paso 00. Obtener el SALDO PROMEDIO. Variable por utilizar en el Paso 3.
    -- vSaldoPromedio Valor inicial del requerimiento 200 (29.junio)
    SET ISOLATION TO dirty READ;
    SELECT valor1 
        INTO vSaldoPromedio 
    FROM bditarjeta:td_parametro
        WHERE clave = 'SDO_TDD_COMPRA_TAG';
    
    --Paso 00. Obtener el NUMERO MAXIMO DE REGISTROS POR ARCHIVO. 
    -- Variable por utilizar en el Paso 6.
    -- vRegistrosMaxPorArchivo Valor inicial del requerimiento 200 (29.junio)
    SET ISOLATION TO dirty READ;
    SELECT valor1
        INTO vRegistrosMaxPorArchivo 
    FROM bditarjeta:td_parametro
        WHERE clave = 'REGMAX_POR_ARCH';

    DROP TABLE IF EXISTS tmp_bines_debito;
    DROP TABLE IF EXISTS tmp_info_clientes;
    DROP TABLE IF EXISTS tmp_clientes_promedio;
    DROP TABLE IF EXISTS tmp_clientes_maestra;
    DROP TABLE IF EXISTS tmp_movimientos_actuales;
    DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
    DROP TABLE IF EXISTS tmp_movimientos_historicos;

    --Es necesario implementar la directiva para considerar los indices creados en la tabla especificada.
    --    {+AVOID_FULL (movimientohistorico)} | "No full-table scan on the listed table".
    
    SET ISOLATION TO dirty READ;
    SELECT
        {+AVOID_FULL (bines)}
        {+INDEX(bines idx_bines)}
        bin 
    FROM bines
    WHERE creditodebito = 'D'
    INTO TEMP tmp_bines_debito;
    
    --Paso 1. 
    --  Construccion de tabla temporal de movimientos historicos
    --  Construccion de tabla temporal de movimientos actuales
    --  Union de todos los registros coincidentes de movimientos y tarjetas
    
    SET ISOLATION TO DIRTY READ; 
    SELECT {+AVOID_FULL (movimientohistorico)}
    {+INDEX(movimientohistorico idx_movimiento3)}
    {+INDEX(movimientohistorico idx_movimiento4)}
    {+INDEX(tarjeta idx_tarjeta1)}

    DISTINCT t.numcliente, t.numtarjeta
    FROM movimientohistorico movh, tarjeta t
        WHERE movh.numtarjeta = t.numtarjeta
        AND fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND tipotransaccionposdigitada = 'TG'
        AND SUBSTR (movh.numtarjeta,0,6) IN 
            (
                SELECT bin
                FROM tmp_bines_debito
            )
        AND t.codstatustarjeta = 'ACT'
        AND t.titular IN ('T', 'A')
        AND codigoiso = '00'
        AND prodind = '02'
        AND metodocaptura IN ('01','81')
        AND codgironeg IN ('4784', '7523')
        ---Excluir los clientes que ya estan registrados en otras plantillas
        AND t.numcliente NOT IN 
            (
                SELECT
                {+AVOID_FULL (info_reporte_trimestral)}
                {+INDEX(info_reporte_trimestral idx_info_reporte_trimestral)}
                    cliente 
                FROM info_reporte_trimestral 
                WHERE plantilla IN ('1', '2')
            )
    INTO TEMP tmp_movimientos_historicos WITH NO LOG;
    
    --Movimientos actuales
    SET ISOLATION TO DIRTY READ; 
    SELECT {+AVOID_FULL (movimiento)}
    {+INDEX(movimiento idx_movimiento3a)}
    {+INDEX(movimiento idx_movimiento4a)}
    {+INDEX(tarjeta idx_tarjeta1)}

    DISTINCT t.numcliente, t.numtarjeta
    FROM movimiento mov, tarjeta t
    WHERE mov.numtarjeta = t.numtarjeta
        AND fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND tipotransaccionposdigitada = 'TG'
        AND SUBSTR (mov.numtarjeta,0,6) IN 
            (
                SELECT bin
                FROM tmp_bines_debito
            )
        AND t.codstatustarjeta = 'ACT'
        AND t.titular IN ('T', 'A')
        AND codigoiso = '00'
        AND prodind = '02'
        AND metodocaptura IN ('01','81')
        AND codgironeg IN ('4784', '7523')
        ---Excluir los clientes que ya estan registrados en el archivo tarjeta presente
        AND t.numcliente NOT IN 
            (
                SELECT
                {+AVOID_FULL (info_reporte_trimestral)}
                {+INDEX(info_reporte_trimestral idx_info_reporte_trimestral)}
                    cliente 
                FROM info_reporte_trimestral 
                WHERE plantilla IN ('1', '2')
            )
    INTO TEMP tmp_movimientos_actuales WITH NO LOG;
    
    --Union de registros de movimientos.
    SELECT DISTINCT numcliente
    FROM tmp_movimientos_historicos
        UNION ALL
    SELECT DISTINCT numcliente
    FROM tmp_movimientos_actuales 
    WHERE numcliente NOT IN (SELECT DISTINCT numcliente FROM tmp_movimientos_historicos)
        INTO TEMP tmp_movimientos_trimestrales WITH NO LOG;
    
    
    --Obtencion de cuentas activas y unicamente relacionadas con tarjetas de los clientes previamente seleccionados
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdicheq:sc_maechq)}
        {+INDEX(sc_maechq maecheques)}
    DISTINCT cuenta 
    FROM intercard:tarjetacuenta tarcta 
        INNER JOIN bdicheq:sc_maechq mcheq 
    ON (mcheq.cuenta = tarcta.numcuenta)    
    WHERE mcheq.status_cta = 1
        AND mcheq.num_cte IN (SELECT numcliente FROM tmp_movimientos_trimestrales)
    INTO TEMP tmp_clientes_maestra WITH NO LOG;
    
    
    /*
    Paso 3. TDD Presente
    Obtener a los clientes con un promedio mensual anterior MAYOR A 200
    
    Considerar que debe evitarse dividir entre dias cero (0) [ AND diacum > 0 ]
    Script lines: 1-3 -- An attempt was made to divide by zero
    */   
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdicheq:sc_sdodiarioc)}
        {+INDEX(sc_sdodiarioc isdodiario)}
    cuenta,
    CASE
        WHEN CAST((capvigacum/diacum) AS DECIMAL(10,0)) > vSaldoPromedio THEN 'S'
        ELSE 'N'
    END AS cte_promedio
    FROM bdicheq:sc_sdodiarioc 
        WHERE aniomes = vAnyoMes
        AND diacum > 0
        AND cuenta IN (SELECT cuenta FROM tmp_clientes_maestra) 
    INTO TEMP tmp_clientes_promedio WITH NO LOG;
    
    
    /*
    Paso 4. TDD Presente
    Los clientes tienen una cuenta activa y un correo valido (validacion por dominio (bdinteg)
    --indice para optimizar la busqueda en maech utilizando los campos: num_cte, status_cta
    */
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdinteg:si_correos)}
        {+INDEX(si_correos idx_corr_cte_cons)}
    DISTINCT
        mcheq.num_cte cliente,
        sicte.nombre1 nombre1, sicte.nombre2 nombre2,
        sicor.correo_elec correo_electronico
    FROM bdicheq:sc_maechq mcheq, bdinteg:si_cliente sicte, bdinteg:si_correos sicor
    WHERE mcheq.num_cte = sicte.numcte
        AND mcheq.num_cte = sicor.numcte
        AND sicor.tipo_correo = '1'
        AND sicor.status_correo = 'A'
        AND sicor.valido = '1'
        AND sicor.valida_correo = '200'
        AND mcheq.status_cta = 1
        --Instruccion para obtener unicamente cuentas de clientes con saldo promedio 
        --SELECT cuenta FROM tmp_clientes_promedio WHERE cte_promedio = 'S'
        AND mcheq.cuenta IN (SELECT cuenta FROM tmp_clientes_promedio WHERE cte_promedio = 'S')
    INTO TEMP tmp_info_clientes WITH NO LOG;

    /*
    Paso 6.
        Tratamiento de los datos para crear el disenio solicitado en la plantilla de 
        clientes con compras utilizando tarjeta presente.
        Por requerimiento si el nombre1 es menor a dos caracteres se debe imprimir el nombre2
        en el archivo generado.
    */
    --NOTA: Se utilizan los asteriscos para despues ser sustituidos por pipes ( sed -e 's/\*/|/g' )
    --en el momento que se genera el archivo mediante el comando sed, asi evitando
    --que en el archivo se impriman diagonales invertidas con pipes \|\|
    SET ISOLATION TO DIRTY READ;    
    INSERT INTO info_reporte_trimestral (plantilla, cliente, correo_electronico, titular)
    
    SELECT ID_PLANTILLA, cliente,
        LOWER(TRIM(correo_electronico)) correo_electronico,
        CASE
            WHEN LENGTH (nombre1) < 3 THEN '****'||TIPO_PLANTILLA||'*'||'nombre='||TRIM(nombre2)
            ELSE '****'||TIPO_PLANTILLA||'*'||'nombre='||TRIM(nombre1) 
        END AS titular
    FROM tmp_info_clientes;
    
    
    /*
    Paso 7. Conteo de registros y recorrido para crear los 'n' archivos correspondientes.
    */
    SET ISOLATION TO DIRTY READ;
    SELECT COUNT(*) conteo_total INTO vTotalRegistros FROM info_reporte_trimestral WHERE plantilla = ID_PLANTILLA;
    
        -- Sin registros en la tabla temporal tmp_info_clientes.
        -- Por requerimiento se debe generar el archivo indicando 
        -- en el total de registros con el valor cero (0)
        IF (vTotalRegistros = 0) THEN
            LET vsql = '';
            LET vsql = 'echo "BANCOPPEL|productos||mail1|'||TIPO_PLANTILLA||'|'||vTotalRegistros||'"> '||RUTA_DESTINO||TIPO_PLANTILLA||'_00.ready';
            SYSTEM vsql;
            
            LET vsql = '';
            LET vsql = 'echo "UNLOAD TO "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_00.unl SELECT * FROM info_reporte_trimestral WHERE plantilla = "'||ID_PLANTILLA||'";" > '||RUTA_DESTINO||'tdd_compra_tag.sql';
            SYSTEM vsql;
            
            LET vsql ='';
            LET vsql= 'dbaccess intercard '||RUTA_DESTINO||'tdd_compra_tag.sql';
            SYSTEM vsql;
            
            LET vsql = '';
            LET vsql ='rm '||RUTA_DESTINO||'tdd_compra_tag.sql';
            SYSTEM vsql;

            LET vsql ='';
            LET vsql = "sed 's/|s//g' "||RUTA_DESTINO||TIPO_PLANTILLA||"_00.unl >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_00.ready";
            SYSTEM vsql;
            
            --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
            LET vsql ='';
            LET vsql ='echo "<EOF>" >> '||RUTA_DESTINO||TIPO_PLANTILLA||"_00.ready";
            SYSTEM vsql;
            
            LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_00.unl';
            SYSTEM vsql;
            
            DROP TABLE IF EXISTS tmp_info_clientes;
            DROP TABLE IF EXISTS tmp_clientes_promedio;
            DROP TABLE IF EXISTS tmp_clientes_maestra;
            DROP TABLE IF EXISTS tmp_movimientos_actuales;
            DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
            DROP TABLE IF EXISTS tmp_movimientos_historicos;
            DROP TABLE IF EXISTS tmp_bines_debito;
            ----------------------------------------------------------------------------------------------------------------------------------------------------
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF;
        
        --La consulta tiene mas de un registro | Creacion de los 'n' archivos resultantes
        IF (vTotalRegistros >  0) THEN            
           
            WHILE (vTotalRegistros > 0 ) LOOP
                
                --Registros Base almacenado en la base de datos:bditarjeta / tabla:td_parametro / clave: REGMAX_POR_ARCH
                --La variable vRegistrosMaxPorArchivo = 20,000 | Requerimiento inicial 03 Julio
                
                LET vTotalInterna = vTotalRegistros - vRegistrosMaxPorArchivo;
                
                --Validacion interna vTotalInterna 
                --para restar los registros previamente almacenados en el archivo.
                --Cuando la previa operacion aritmetica tenga como resultado un cero o valor negativo
                --indicara que son los primeros o ultimos registros iterados para generar el archivo.
                IF (vTotalInterna <= 0) THEN
                    LET vTotalInterna = vTotalRegistros;
                ELIF (vTotalInterna > 0) THEN
                    LET vTotalInterna = vRegistrosMaxPorArchivo;
                END IF;
                
                IF (vContadorArchivos <= 99) THEN
                    LET vContadorArchivos = LPAD(vContadorArchivos, "2", 0);
                ELSE
                    LET vContadorArchivos = LPAD(vContadorArchivos, "3", 0);
                END IF;
                
                
                --La variable vTotalInterna se utiliza para indicar el total de registros almacenados por archivo.
                
                LET vsql = '';
                LET vsql = 'echo "BANCOPPEL|productos||mail1|'||TIPO_PLANTILLA||'|'||vTotalInterna||'"> "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_'||vContadorArchivos||'.ready';
                SYSTEM vsql;
                
                --Consulta utilizada para ir paginando los registros en cada archivo iniciando
                --del registro 0 hasta la base de la variable vRegistrosMaxPorArchivo en cada ciclo.
                ---SELECT SKIP '||vNumInicioRegistros||' FIRST  vRegistrosMaxPorArchivo
                
                LET vsql = '';
                LET vsql = 'echo "UNLOAD TO "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_'||vContadorArchivos||'.unl SELECT SKIP '||vNumInicioRegistros||' FIRST '||vRegistrosMaxPorArchivo||' correo_electronico, titular FROM info_reporte_trimestral WHERE plantilla = "'||ID_PLANTILLA||'";" > '||RUTA_DESTINO||'tdd_compra_tag.sql';
                SYSTEM vsql;
                
                LET vsql ='';
                LET vsql= 'dbaccess intercard '||RUTA_DESTINO||'tdd_compra_tag.sql';
                SYSTEM vsql;
                
                LET vsql = '';
                LET vsql ='rm '||RUTA_DESTINO||'tdd_compra_tag.sql';
                SYSTEM vsql;
            
                --Sustitucion del numero de asteriscos por pipes y eliminacion del ultimo pipe de cada registro.
                LET vsql ='';
                LET vsql = "sed -e 's/\*/|/g' -e 's/[|]*$//' "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".unl >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".tmp_ready";
                SYSTEM vsql;
                
                --Linea que genera los numeros de linea de cada uno de los registros obtenidos | No se hace en la base de datos para mejorar optimizacion.
                LET vsql ='';
                LET vsql = " sed = "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".tmp_ready | sed 'N;s/\n/|/' >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".ready";
                SYSTEM vsql;
                
                --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
                LET vsql ='';
                LET vsql ='echo "<EOF>" >> '||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".ready";
                SYSTEM vsql;
            
                LET vsql ='';
                LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vContadorArchivos||'.tmp_ready';
                SYSTEM vsql;
                
                LET vsql ='';
                LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vContadorArchivos||'.unl';
                SYSTEM vsql;
        
                --El numero vRegistrosMaxPorArchivo es la base de registros por archivo
                LET vNumInicioRegistros = vNumInicioRegistros + vRegistrosMaxPorArchivo;
                
                LET vContadorArchivos = vContadorArchivos::INTEGER + 1;
                --Se realiza una suma de la variable vNumInicioRegistros (cero) mas vRegistrosMaxPorArchivo
                --Para que en ciclo 2 el SKIP comience en el resultado de vNumInicioRegistros
               
               --Se actualiza la variable de registros faltantes por ingresar en el archivo.
                LET vTotalRegistros = vTotalRegistros - vTotalInterna;
            END LOOP;
        END IF;
            
        DROP TABLE IF EXISTS tmp_info_clientes;
        DROP TABLE IF EXISTS tmp_clientes_promedio;
        DROP TABLE IF EXISTS tmp_clientes_maestra;
        DROP TABLE IF EXISTS tmp_movimientos_actuales;
        DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
        DROP TABLE IF EXISTS tmp_movimientos_historicos;
        DROP TABLE IF EXISTS tmp_bines_debito;
    ----------------------------------------------------------------------------------------------------------------------------------------------------
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;

/*
-- Autor: [ agarciao@bancoppel.com ]
-- Modificado: 22.enero.2018 09:39:00am
-- Base de datos: intercard
-- Job: 533_REPORTE_TRIMESTRAL_CTES_CAPTA_INTERCARD_PRO
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente crea la tabla info_reporte_trimestral
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral
*/
END;
END PROCEDURE;