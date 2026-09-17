CREATE PROCEDURE "informix".sp_gen_arch_datos_contacto_bei()
    RETURNING CHAR(5), VARCHAR(80);
    -- ******************************************************************************************************************************
    -- DESCRIPCION: SP que generar un archivo a partir de los resultados de la tabla de datos de contacto de los clientes de empresanet
    -- AUTOR: Marco Tinajero
    -- FECHA : 29/08/2024
    -- SOLICITO : Armando Barrientos
    -- ESQUEMA DE BD: bdibei
    -- ******************************************************************************************************************************

    -- VARIABLES DE CONTROL
    DEFINE iSqlErr INTEGER;
    DEFINE cMensaje VARCHAR(80);
    DEFINE cCodResp CHAR(5);

    -- VARIABLES DE EJECUCION
    DEFINE vNombreDeArchivo VARCHAR(50);
    DEFINE cComandoEjec CHAR(1000);
    DEFINE vNombreArchivoSql VARCHAR(200);
    DEFINE vRutaDir CHAR(50);

    -- INIT VARIABLES
    LET cCodResp = '00000';
    LET iSqlErr = 0;
    LET cMensaje = 'PROCESO EXITOSO';
    LET vNombreDeArchivo = '';
    LET cComandoEjec = '';
    LET vNombreArchivoSql = '';
    LET vRutaDir = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
            LET cCodResp = iSqlErr;
            LET cMensaje = 'ERROR AL EJECUTAR EL PROCESO';

            RETURN cCodResp, cMensaje;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- Consultar directorio para crear el archivo
        SELECT valor INTO vRutaDir
        FROM bdibpi:"informix".enet_parametros
        WHERE id_param = 1013;

        -- Validar que exista la configuracion del parametro con la ruta destino para la creacion del archivo, sino genera un error de salida y se omite la ejecucion de las siguientes lineas de codigo
        IF NVL(vRutaDir, '') = '' THEN 
            LET cCodResp = '00001';
            LET cMensaje = 'FALTA LA CONFIGURACION DE RUTA DESTINO EN CENTRAL';
            RETURN cCodResp, cMensaje;
        END IF;

        -- Nombre archivo reporte_datos_contacto_empnet_ddmmyyy.csv
        LET vNombreDeArchivo = 'reporte_datos_contacto_empnet_' || CAST(TO_CHAR(CURRENT, '%d%m%Y') AS CHAR(8)) || '.csv'; 

        -- Archivo SQL que contiene la ejecucion UNLOAD
        LET vNombreArchivoSql = TRIM(vRutaDir) || 'reporteDatContEmpnet.sql';

        --Generar la sentencia de creacion en archivo SQL
        LET cComandoEjec = 'echo " UNLOAD TO '|| TRIM(vRutaDir) || vNombreDeArchivo || ' DELIMITER ' || ''','' ' ||
        'SELECT ' || '''No. Cliente'', ' || '''No. Cuenta'', ' || '''Nombre de la Empresa'', ' || '''Nombre del Contacto'', ' || '''Telefono Fijo'', ' ||
        '''Telefono Celular'', ' || '''Correo Electronico'', ' || '''Correo Electronico Alterno'', ' || '''Pagina de Internet'', ' || '''RFC'' ' ||
        'FROM systables WHERE tabid = 1 ' ||
        'UNION ALL ' ||
        'SELECT cte.numcte, cta.cuenta, cte.razon_social, TRIM(dtc.representante_legal), dtc.tel_fijo, dtc.tel_celular, '||
            'dtc.correo, dtc.correo_alternativo, dtc.pagina_internet, cte.rfc ' ||
        'FROM bei_datos_empnet dtc ' ||
        'INNER JOIN bdinteg:si_cliente cte ON cte.numcte = dtc.id_cliente ' ||
        'INNER JOIN bdicheq:sc_maechq cta ON cte.numcte = cta.num_cte " > ' || vNombreArchivoSql;

        -- Ejecutar sentencia UNIX para crear el archivo SQL
        SYSTEM cComandoEjec;
        -- Sobreescribir el valor de la variable ahora por sentencia dbaccess
        LET cComandoEjec = 'dbaccess bdibei ' || vNombreArchivoSql;
        -- Ejecutar sentencia dbaccess para crear el archivo CSV
        SYSTEM cComandoEjec;
        -- Sobreescribir el valor de la variable para eliminar el archivo sql generado
        LET cComandoEjec = 'rm -r ' || vNombreArchivoSql;
        -- Ejecutar sentencia de eliminacion del archivo sql
        SYSTEM cComandoEjec;

        RETURN cCodResp, cMensaje;
    END;
END PROCEDURE;