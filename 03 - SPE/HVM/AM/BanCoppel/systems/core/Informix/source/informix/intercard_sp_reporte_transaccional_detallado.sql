CREATE PROCEDURE "informix".sp_reporte_transaccional_detallado(
    pFechaInicio DATETIME YEAR TO FRACTION(5), 
    pFechaFin DATETIME YEAR TO FRACTION(5),
    pTotalTrxsCatGral INTEGER,
    pTopRegistros SMALLINT
)
    
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE LEYENDA_MOTIVO_OTROS CHAR(5);
    DEFINE vTotalTransacciones INTEGER;
    DEFINE vTotalTransacDetalle INTEGER;
    DEFINE vFechaInicioDet DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinalDet DATETIME YEAR TO FRACTION(5);

    DEFINE SQL_ERR SMALLINT;
    DEFINE ISAM_ERR SMALLINT;
    DEFINE ERROR_INFO VARCHAR(60);
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE vCategoriaPadre CHAR(2);
    DEFINE vPctGral MONEY;
    DEFINE vPctGralSum MONEY;
    DEFINE vCodCategoria CHAR(2);
    DEFINE vDescMotivo VARCHAR(70);
    DEFINE vPctDetalle MONEY;
    DEFINE vConteoTrxsPadre INTEGER;
    DEFINE vNumeroTrxsDet INTEGER;
    DEFINE vConteoTrxsSum INTEGER;
    DEFINE vNumInicioRegistros INTEGER;
    DEFINE vNumOrdenamiento SMALLINT;
    DEFINE vTotalTempTrxs SMALLINT;
    DEFINE vTotalPcte MONEY;

    DEFINE vConteoTrxsHijo INTEGER;
    DEFINE vPcteHijo MONEY;
    DEFINE vFechaHoraActual DATETIME YEAR TO FRACTION(5);


    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO RUTA_ORIGEN||"excepcion_sp_reporte_transaccional_detallado.err.out";
        TRACE ON;
      
        LET CODIGO_RETORNO = SQL_ERR   ||     ISAM_ERR     ||   ERROR_INFO;
        LET MENSAJE_RETORNO = 'Excepcion reporte detallado';
      
        RETURN CODIGO_RETORNO,MENSAJE_RETORNO;
    END EXCEPTION;
 
    BEGIN
 
        LET CODIGO_RETORNO  = '00000';
        LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
        LET RUTA_ORIGEN = '/RESPALDOSNEW/monitoreo_transaccional/eglobal/';
        LET LEYENDA_MOTIVO_OTROS = 'Otros';
        LET vTotalTransacciones = 0;
        LET vTotalTransacDetalle = 0;
        LET vFechaInicioDet = '';
        LET vFechaFinalDet = '';
        LET vCategoriaPadre = '';
        LET vPctGral = 0.00;
        LET vPctGralSum = 0.00;
        LET vConteoTrxsPadre = 0;
        LET vPctDetalle = 0.00;
        LET vNumeroTrxsDet = 0;
        LET vConteoTrxsSum = 0;
        LET vCodCategoria = '';
        LET vDescMotivo = '';
        LET vNumInicioRegistros = 0;
        LET vNumOrdenamiento = 0;
        LET vTotalTempTrxs = 0;
        LET vTotalPcte = 0.00;

        LET vConteoTrxsHijo = 0;
        LET vConteoTrxsPadre = 0;
        LET vPcteHijo = 0.00;
        LET vFechaHoraActual = CURRENT;
        
        
        --SET DEBUG FILE TO RUTA_ORIGEN || "ejecucion_sp_reporte_transaccional_detallado.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        LET vFechaInicioDet = pFechaInicio;
        LET vFechaFinalDet  = pFechaFin;

        DROP TABLE IF EXISTS tbl_tmp_movs_detalle_motivos;
        SELECT
            CASE
                WHEN mov.codigoiso IN ('12', '14', '82', '96') THEN '01'
                WHEN mov.codigoiso IN ('04', '57', '59', '62', '75') THEN '02'
                WHEN mov.codigoiso IN ('05') THEN '03'
                WHEN mov.codigoiso IN ('51', '54', '55') THEN '04'
                WHEN mov.codigoiso IN ('00') THEN '05'
            END cod_categoria,
            motivo,
            COUNT(*) as trxs_por_categoria
        FROM intercard:movimiento mov
            WHERE fechahorainauth BETWEEN vFechaInicioDet AND vFechaFinalDet
        AND transaccionorigen = '1234'
            GROUP BY 1,2
            ORDER BY 1
        INTO TEMP tbl_tmp_movs_detalle_motivos WITH NO LOG;
        
        CREATE INDEX "informix".idx_tbl_tmp_movs_detalle_categoria_pad
            ON "informix".tbl_tmp_movs_detalle_motivos(cod_categoria) ONLINE;
    
        FOREACH cat_detallado FOR
        
            SELECT cod_categoria 
                INTO vCategoriaPadre
            FROM intercard:tbl_reporte_general
                WHERE horainicio_busqueda >= vFechaInicioDet
            AND horafin_busqueda <= vFechaFinalDet

            FOREACH cat_inner_detallado FOR
                SELECT
                        tmov.cod_categoria, tmov.motivo, tmov.trxs_por_categoria as trxs_hijo,
                            gral.trxs_por_categoria as trxs_categoria_padre,
                        (tmov.trxs_por_categoria * gral.resultado)/gral.trxs_por_categoria  as pctj_hijo,
                            gral.horainicio_busqueda, gral.horafin_busqueda
                    INTO vCodCategoria, vDescMotivo, vConteoTrxsHijo, 
                            vConteoTrxsPadre, vPcteHijo,
                        vFechaInicioDet, vFechaFinalDet 
                    FROM intercard:tbl_reporte_general gral 
                        INNER JOIN tbl_tmp_movs_detalle_motivos tmov 
                            ON (gral.cod_categoria = tmov.cod_categoria)
                    WHERE gral.horainicio_busqueda >= vFechaInicioDet
                       AND gral.horafin_busqueda <=  vFechaFinalDet
                            AND gral.cod_categoria = vCategoriaPadre
            
                INSERT INTO intercard:tbl_reporte_detallado( 
                                cod_categoria, descripcion_motivo, trxs_por_categoria, total_transacciones, 
                                resultado, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion)
                    VALUES(vCodCategoria, vDescMotivo, vConteoTrxsHijo, vConteoTrxsPadre,
                             vPcteHijo,vFechaInicioDet, vFechaFinalDet, vFechaHoraActual);
            END FOREACH
            
        END FOREACH

        -- Iterar la consulta por cada una de las categorias 01, 02, 03, 04, 05
        FOREACH catpadre FOR

            SELECT cod_categoria 
                INTO vCategoriaPadre
            FROM intercard:tbl_reporte_general
                WHERE horainicio_busqueda 
            BETWEEN vFechaInicioDet AND vFechaFinalDet
                AND horafin_busqueda 
            BETWEEN vFechaInicioDet AND vFechaFinalDet

            --Construccion por categoria para obtener los motivos detallados
            DROP TABLE IF EXISTS tmp_transacciones_motivos;
            
            SELECT
                gral.resultado as pctgral, gral.trxs_por_categoria as trxs_padre, 
                    tmo.cod_categoria, tmo.descripcion_motivo,
                        tmo.resultado as pctdetalle, tmo.trxs_por_categoria as trxs_detalle
                FROM intercard:tbl_reporte_general gral 
            INNER JOIN intercard:tbl_reporte_detallado tmo
                ON(gral.cod_categoria = tmo.cod_categoria)
            WHERE gral.horainicio_busqueda = tmo.horainicio_busqueda 
                AND gral.horafin_busqueda = tmo.horafin_busqueda
                AND gral.horainicio_busqueda
                    BETWEEN vFechaInicioDet AND vFechaFinalDet
                AND gral.horafin_busqueda 
                    BETWEEN vFechaInicioDet AND vFechaFinalDet
                AND gral.cod_categoria = vCategoriaPadre
            INTO TEMP tmp_transacciones_motivos WITH NO LOG;

            CREATE INDEX "informix".idx_tbl_tmp_transacciones_motivos_categoria_pad
                ON "informix".tmp_transacciones_motivos(cod_categoria) ONLINE;
            
            SELECT 
                COUNT(*) 
                    INTO vTotalTransacDetalle 
            FROM tmp_transacciones_motivos
                WHERE cod_categoria = vCategoriaPadre;
            
            IF (vTotalTransacDetalle >  0) THEN
                                    
                FOREACH cathijo WITH HOLD FOR
                        
                    SELECT pctgral, trxs_padre, cod_categoria, descripcion_motivo, pctdetalle, trxs_detalle
                        INTO vPctGral, vConteoTrxsPadre, vCodCategoria, vDescMotivo, vPctDetalle, vNumeroTrxsDet
                    FROM tmp_transacciones_motivos 
                        WHERE cod_categoria = vCategoriaPadre
                    ORDER BY 3, 6 DESC
                    
                     --Es el numero guardado en el archivo que se genera para enviar por correo electronico
                     ---Ruta: /resplogifx/mon_trans_categoria/rpte_detalle_trxs.unl
                    LET vNumOrdenamiento = vNumOrdenamiento + 1;
                    
                    --Conteo para validar si existen mas registros por motivos detallados
                    LET vTotalTransacDetalle = vTotalTransacDetalle-1;
                    
                    ---Variable para comparar contra el TOP enviado como parametro 
                    ---del sp padre sp_reporte_transaccional_categoria_notif
                    LET vNumInicioRegistros = vNumInicioRegistros + 1;
                    
                    ---pTopRegistros(3): Parametro enviado por el sp_reporte_transaccional_categoria_notif
                    
                    IF (vNumInicioRegistros < pTopRegistros AND vNumInicioRegistros < vTotalTransacDetalle) THEN
                        
                        LET vPctGralSum = vPctGral - vPctDetalle;
                        LET vTotalTempTrxs = vTotalTempTrxs + vNumeroTrxsDet;
                        LET vConteoTrxsSum = vConteoTrxsPadre - vNumeroTrxsDet;
                        LET vTotalPcte = vTotalPcte + vPctDetalle;
                        
                    END IF  
                    
                    IF(vNumInicioRegistros = pTopRegistros ) THEN
                        
                        ---Si el registro corresponde con el TOP y si la suma de los registros faltantes
                        ---excede el 50 por ciento del total por categoria padre (vConteoTrxsPadre)
                        ---debe mostrarse el registro con mas transacciones
                        IF (vTotalTempTrxs > (vConteoTrxsPadre/2) AND vTotalTransacDetalle > 0) THEN
                            
                            LET vPctDetalle = vPctGral - vTotalPcte;
                            LET vNumeroTrxsDet = vConteoTrxsPadre - vTotalTempTrxs;
                            
                            INSERT INTO intercard:tbl_reporte_monitoreo_trx
                                ( pctgral, cod_categoria, descripcion_motivo, pctdetalle, 
                                    trxs_detalle, orden, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion)
                            VALUES (vPctGral, vCodCategoria, LEYENDA_MOTIVO_OTROS, vPctDetalle, 
                                        vNumeroTrxsDet, LPAD(vNumOrdenamiento,'2',0), vFechaInicioDet, vFechaFinalDet, current);
                        
                        ELSE
                        
                            INSERT INTO intercard:tbl_reporte_monitoreo_trx
                                ( pctgral, cod_categoria, descripcion_motivo, pctdetalle, 
                                    trxs_detalle, orden, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion)
                            VALUES (vPctGral, vCodCategoria, vDescMotivo, vPctDetalle, 
                                        vNumeroTrxsDet, LPAD(vNumOrdenamiento,'2',0), vFechaInicioDet, vFechaFinalDet, current);
                        
                            --Si aÃºn quedan transacciones detalladas se agrupan en el registro "Otros"
                            --para completar el porcentaje general de la categoria padre
                            IF(vTotalTransacDetalle > 0) THEN
                                
                                LET vNumOrdenamiento = vNumOrdenamiento + 1;
                                LET vPctDetalle = vPctGral-vTotalPcte - vPctDetalle;
                                LET vNumeroTrxsDet = vConteoTrxsPadre - vTotalTempTrxs - vNumeroTrxsDet;
                                
                                INSERT INTO intercard:tbl_reporte_monitoreo_trx
                                        ( pctgral, cod_categoria, descripcion_motivo, pctdetalle, 
                                            trxs_detalle, orden, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion)
                                VALUES ( vPctGral, vCodCategoria, LEYENDA_MOTIVO_OTROS, vPctDetalle, 
                                            vNumeroTrxsDet, LPAD(vNumOrdenamiento,'2',0), vFechaInicioDet, vFechaFinalDet, current);
                                
                            END IF
                            
                        END IF
                                                
                        ---Asignar a cero para darle salida al foreach y continue con las siguientes categorias padre
                        LET vConteoTrxsPadre = 0;
                        LET vPctGralSum = 0.00;
                        LET vConteoTrxsSum = 0;
                        LET vDescMotivo = '';
                        LET vNumeroTrxsDet = 0;
                        LET vNumInicioRegistros = 0;
                        LET vTotalTempTrxs = 0;
                        LET vTotalPcte = 0.00;
                        LET vTotalTransacDetalle = 0;
                        
                        EXIT FOREACH;
                        
                    END IF;

                    --Registro del TOP 1 y TOP 2 por categoria padre.
                    INSERT INTO intercard:tbl_reporte_monitoreo_trx
                        ( pctgral, cod_categoria, descripcion_motivo, pctdetalle, 
                            trxs_detalle, orden, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion) 
                        VALUES ( vPctGral, vCodCategoria, vDescMotivo, vPctDetalle, 
                                    vNumeroTrxsDet, LPAD(vNumOrdenamiento,'2',0), vFechaInicioDet, vFechaFinalDet, current);
  
                END FOREACH;
                
            END IF;

		END FOREACH

        ---El archivo rpte_detalle_trxs.unl nunca se borra porque el shell ' pro_reporte_trx_monitoreo.sh ' 
        --- lo utiliza mediante el comando awk para la salida a monitoreo y otro shell para crear un archivo xml
        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||'rpte_detalle_trxs.unl ' ||
         ' SELECT mon.orden, gral.cod_categoria, gral.nombre_categoria, gral.trxs_por_categoria, gral.resultado as pctjgral, ' ||
         '    mon.descripcion_motivo, mon.trxs_detalle, mon.pctdetalle ' ||
         ' FROM intercard:tbl_reporte_general gral INNER JOIN intercard:tbl_reporte_monitoreo_trx mon ' ||
         '    ON(gral.cod_categoria = mon.cod_categoria) ' ||
         ' WHERE (gral.horainicio_busqueda = mon.horainicio_busqueda AND gral.horafin_busqueda = mon.horafin_busqueda) ' ||
         '    AND gral.horainicio_busqueda >= \"'||vFechaInicioDet||'\" AND gral.horafin_busqueda <= \"'||vFechaFinalDet||'\" ' ||
         ' ORDER BY 1,2; ' ||
         ' "> '||RUTA_ORIGEN||'script_rpte_detalle_trxs.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL= ' dbaccess intercard '||RUTA_ORIGEN||'script_rpte_detalle_trxs.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||'script_rpte_detalle_trxs.sql';
        SYSTEM vExecuteSQL;
        
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO; 
        
    END
    
END PROCEDURE

--Descripcion: Reporte de transaccionalidad para registrar el detalle de cada categoria padre
--Base de datos: intercard
--Fecha de creacion: 01 de febrero del 2019
--Fecha de modificacion: 29 de julio del 2019 | Se agrega funcionalidad para el acumulado por dia
;

CREATE PROCEDURE "informix".sp_procesar_tarjetas_maquila( )
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RESPUESTA;

    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    
    DEFINE vConsecutivo INTEGER;
    DEFINE vClaveSucursal VARCHAR(5);
    DEFINE vIndicadorTipoProceso CHAR(1);
    DEFINE vClaveTipoTarjeta INTEGER;
    DEFINE vFechaExp VARCHAR(4);
    DEFINE vCodProdTarjeta VARCHAR(3);
    DEFINE vCantidad INTEGER;
    DEFINE vFechaGeneracion DATETIME YEAR to FRACTION(3);
    DEFINE vNombreCliente VARCHAR(21);
    DEFINE vFlagProcesoRealizado CHAR(1);
    DEFINE vUsuario VARCHAR(8);
    DEFINE vTipoMaquila VARCHAR(1);
    DEFINE vFlagDisenio CHAR(1);
    DEFINE vIdDisenio INTEGER;
    
    DEFINE vContadorMaxSolMaquila INTEGER;
    DEFINE vContadorMaxSolTarjeta INTEGER;
    
    DEFINE vtEmpresa CHAR(3);
    DEFINE vtNumCredito VARCHAR(16);
    DEFINE vtNumCliente VARCHAR(13);
    DEFINE vtSucursal VARCHAR(5);
    DEFINE vtApellPaterno CHAR(26);
    DEFINE vtApellMaterno CHAR(26);
    DEFINE vtNombre1 CHAR(26);
    DEFINE vtNombre2 CHAR(26);
    DEFINE vtNombreCompleto VARCHAR(104);
    DEFINE vtNombreEmbozado VARCHAR(50);
    DEFINE vtNumProducto CHAR(4);
    DEFINE vtMemberSince CHAR(2);
    DEFINE vtWelcomeKit CHAR(1);
    DEFINE vtTitular CHAR(1);
    DEFINE vtPrimeraSubsecuente CHAR(1);
    DEFINE vtNotificacion CHAR(1);
    DEFINE vtTipoDeEnvio CHAR(1);
    DEFINE vtSolicitudRegistrada CHAR(1);
    DEFINE ENVIO_A_DOMICILIO CHAR(1);
    
    DEFINE vDireccionCalle1  VARCHAR(50);
    DEFINE vDireccionCalle2 VARCHAR(50);
    DEFINE vDireccionColonia VARCHAR(50);
    DEFINE vDireccionMunicipio VARCHAR(50);
    DEFINE vDireccionEstado VARCHAR(30);
    DEFINE vDireccionCP CHAR(6);
    DEFINE vFechaExpiracion CHAR(4);
    DEFINE vFechaServidor DATETIME YEAR TO FRACTION (5);
    
    LET vtEmpresa = '';
    LET vtNumCredito = '';
    LET vtNumCliente = '';
    LET vtSucursal = '';
    LET vtApellPaterno = '';
    LET vtApellMaterno = '';
    LET vtNombre1 = '';
    LET vtNombre2 = '';
    LET vtNombreCompleto = '';
    LET vtNombreEmbozado = '';
    LET vtNumProducto = '';
    LET vtMemberSince = '';
    LET vtWelcomeKit = '';
    LET vtTitular = '';
    LET vtPrimeraSubsecuente = '';
    LET vtTipoDeEnvio = '';
    LET vtNotificacion = '';
    LET vtSolicitudRegistrada = '';
    LET ENVIO_A_DOMICILIO = 'D';
    
    LET CODIGO_RETORNO = "00000";
    LET MENSAJE_RESPUESTA = 'Ejecucion exitosa';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET vContadorMaxSolMaquila = 0;
    LET vContadorMaxSolTarjeta = 0;    
    LET vFechaExpiracion= '2408';
    LET vFechaServidor = (CURRENT - 12 units hour);    
    
    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_procesar_tarjetas_maquila.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
            END IF;
            
        END EXCEPTION;
        
        --SET DEBUG FILE TO RUTA_ORIGEN||'sp_procesar_tarjetas_maquila.out';
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT 
            MAX(consecutivo)
                INTO vContadorMaxSolMaquila
        FROM intercard:solicitud_maquila;
        
        SELECT 
            MAX(idsolicitud) 
                INTO vContadorMaxSolTarjeta
            FROM intercard:solicitudtarjeta;
        
        FOREACH cursorMaquila WITH HOLD FOR
            
           SELECT 
                t_empresa, t_num_credito, t_num_cliente, t_num_sucursal, t_apell_paterno,
                 t_apell_materno, t_nombre1, t_nombre2, t_nombrecompleto, t_nombre_embozado,
                  t_num_producto, t_member_since, t_welcome_kit, t_titular, t_primera_subsecuente, 
                   t_notificacion, t_tipo_envio, t_solicitud_registrada
                INTO 
                    vtEmpresa, vtNumCredito, vtNumCliente, vtSucursal,  vtApellPaterno,
                        vtApellMaterno, vtNombre1, vtNombre2, vtNombreCompleto, vtNombreEmbozado,
                            vtNumProducto, vtMemberSince, vtWelcomeKit, vtTitular, vtPrimeraSubsecuente,
                                vtNotificacion, vtTipoDeEnvio, vtSolicitudRegistrada
            FROM intercard:tbl_clientes_tarjeta_oro
                WHERE t_empresa = '001'
                     AND t_solicitud_registrada = 'F'
            
            
            BEGIN WORK;
            
                LET vContadorMaxSolMaquila = vContadorMaxSolMaquila + 1;
                
                INSERT INTO intercard:solicitud_maquila( 
                    consecutivo, clave_sucursal, indicadortipoproceso, clave_tipotarjeta, 
                        fechaexp, codproductotarjeta, cantidad, fecha_generacion, 
                            nom_cliente, flagprocesorealizado, usuario, tipomaquila, 
                                flagdiseno, id_diseno)
                    VALUES(vContadorMaxSolMaquila, vtSucursal, 'P', '10', 
                                vFechaExpiracion, '005', 1, vFechaServidor,
                                    vtNombreCompleto, 'F', '97839876', 'E', '', 0);
                
                
                    LET vDireccionCalle1 = '';
                    LET vDireccionCalle2 = '';
                    LET vDireccionColonia = '';
                    LET vDireccionMunicipio = '';
                    LET vDireccionEstado = '';
                    LET vDireccionCP = '';
            
                IF ( vtTipoDeEnvio = ENVIO_A_DOMICILIO ) THEN
                
                    SELECT (calle.numerocalle ||' '|| calle.nombrecalle) as direccion_calle1,
                            dir.numeroextcalle as direccion_calle2, (zona.numerocolonia ||' '|| zona.nombrezona) as direccion_colonia,
                            zona.municipiozona as direccion_municipio,
                            (edo.estado ||' ' ||edo.nombre) as direccion_estado,
                            dir.cod_postal as direccion_cp
                        INTO vDireccionCalle1, vDireccionCalle2,
                                vDireccionColonia, vDireccionMunicipio,  vDireccionEstado, vDireccionCP
                    FROM bdinteg:"informix".si_direcciones_actual dir
                            LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle 
                                ON ( calle.numerocalle = dir.numerocalle )
                            LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona 
                                ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
                            LEFT OUTER JOIN bdinteg:"informix".si_catciudades cd 
                                ON ( cd.numerociudad = dir.numerociudad )
                            LEFT OUTER JOIN bdinteg:"informix".si_estados edo 
                                ON ( edo.estado = dir.estado )
                        WHERE
                            dir.numcte = vtNumCliente AND dir.tipo_dir = '1';
                END IF;
                
            
                LET vContadorMaxSolTarjeta = vContadorMaxSolTarjeta + 1;
            
                INSERT INTO intercard:solicitudtarjeta( 
                    idsolicitud, numcliente, numcuenta, 
                        nombre1, nombre2, apaterno, amaterno, 
                            direccion_calle1, direccion_calle2, direccion_colonia, direccion_municipio, 
                                direccion_estado, direccion_cp, clave_tipotarjeta, codprodcta, 
                                    codproductotarjeta, titular, tipoenvio, nombretarjeta, 
                                            fechaexp, numtarjeta, flagdiseno, id_diseno, 
                                                    flagmaster, flagemision, membersince, wkit, 
                                                        cat, intanuord, intanumor, lineacredito, 
                                                            flagsms, tipomaquila, usuario, canal, 
                                                                sucursal, fechasolicitud, estatusproceso)
                    VALUES (
                        vContadorMaxSolTarjeta, vtNumCliente, vtNumCredito,
                            vtNombre1, vtNombre2,  vtApellPaterno, vtApellMaterno,
                                vDireccionCalle1, vDireccionCalle2, vDireccionColonia,vDireccionMunicipio, 
                                    vDireccionEstado, vDireccionCP, '10', '8100', 
                                        '005', vtTitular, vtTipoDeEnvio, vtNombreEmbozado,
                                            vFechaExpiracion, '', '', '0',
                                                'V', 'S', vtMemberSince, vtWelcomeKit,
                                                    NULL, NULL, NULL, NULL,
                                                        'V', 'E', '97839876','Proceso Especial',
                                                            vtSucursal, vFechaServidor, 'F');


                    UPDATE intercard:tbl_clientes_tarjeta_oro
                        SET t_solicitud_registrada = 'V'
                    WHERE t_num_credito = vtNumCredito
                    AND t_num_cliente = vtNumCliente;

            COMMIT WORK;
            
            LET vFechaServidor = (vFechaServidor + 1 units second);
            
        END FOREACH
        
        LET vContadorMaxSolTarjeta = 0;
        SELECT MAX(idsolicitud) 
            INTO vContadorMaxSolTarjeta
        FROM intercard:solicitudtarjeta;
        
        UPDATE intercard:paraminventarios
                SET idsolicitudtarjeta= vContadorMaxSolTarjeta + 1
            WHERE nummesesinvsuc = 0;

        RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
        
    END
    
END PROCEDURE
---Base de datos: intercard
---Fecha de creacion: 18 de junio del 2019
---Fecha de modificacion: 16 de agosto del 2019
---Proceso para insertar registros y posteriormente generar un archivo de maquila
;

CREATE PROCEDURE "informix".sp_cons_edotarjeta(pNumeroTarjeta char(20))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(3); -- # Estado


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
    DEFINE vStatus      CHAR(3);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "00000";
	LET vStatus = "";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- CONSULTA --
	SELECT
        codstatustarjeta
	INTO
       vStatus
	FROM
		"informix".tarjeta
	WHERE
         numtarjeta = pNumeroTarjeta;

	IF vStatus IS NULL THEN
		LET vCodRet	    = "00002"; 
    END IF

	RETURN vCodRet, vStatus;

END PROCEDURE
DOCUMENT
"Modificó: Jesús Alberto Rubio Lugo",
"Descripción Se crea sp para consultar el estado de las tarjetas en la base de datos y tabla intercard: tarjeta",
"Fecha: 26/02/2019",
"Folio: 527- NO permitir el cambio de NIP a una tarjeta bloqueada",
"BD: intercard",
"Solicita: Cutberto Gonzales";

CREATE PROCEDURE "informix".sp_rpt_reporte_parametrico
(
     pdtFechaIni DATE, --Fecha Inicio del Periodo '<mm-dd-aaaa'>
	 pdtFechaFin DATE, --Fecha Final del Periodo  '<mm-dd-aaaa'>
	 psEstado CHAR(2), --Codigo de bdinteg:si_estados.estado 
	 psCiudad CHAR(3), --Código de bdinteg:si_ciudades.ciudad 
	 psOrigen CHAR(1), --'N'-Nacional, 'I'-Internacional o en blanco cualquiera. 
	 psProdInd CHAR(1),--'A' - ATM, 'P' - POS y vacio para ambos.	 
	 psBin CHAR(6),    --Bin de acuerdo al catálogo intercard:bines.bin
	 psSubBin CHAR(2), -- Imagen de la tarjeta
	 psChipBanda CHAR(1), -- 'C' - Chip, 'B' - Banda, espacio en blanco todos.
	 psProductoInterCard CHAR(3), --Código de intercard:productotarjeta.codproductotarjeta  
	 psFechaExp CHAR(4), --Formato AAMM, 
	 psProducto CHAR(1), --  'C' - Crédito, 'D' - Débito. 
     psMetodoCaptura CHAR(2), -- Se recibirá '00', '01'-Digitada,, '02'-ATM, '05'-Chip, '09', '80' - Fall Back, '81'-Digitada, '90'-Banda, '92'-ContactLess	 
	 psTipoTransaccionposDigitada CHAR(2), --intercard:movimiento.tipotransaccionposdigitada
     psGiroComercio CHAR(4), --Código de intercard:gironegocio.codgironeg 
	 psIDTerminalRetailer CHAR(19), --No de afiliación o de cajero.
	 psCodigoIso CHAR(2) --  intercard:respuestaiso.codigoiso
)
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR(100) AS MENSAJE_RESPUESTA, INTEGER AS tot_registros;

    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
 
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(100);
    DEFINE RUTA_ORIGEN  VARCHAR(80);

    
    DEFINE vitotalregistros INTEGER;
    DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
    DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaMinimaMov DATETIME YEAR TO FRACTION(5);  
    DEFINE vExecuteSQL LVARCHAR(4000);

    DEFINE det_estado CHAR(2);
    DEFINE det_Ciudad CHAR(3);
    DEFINE det_Origen CHAR(1);
    DEFINE det_Origen2 CHAR(1);
    DEFINE det_ProdInd CHAR(2);
    DEFINE det_ProdInd2 CHAR(2);
    DEFINE det_ChipBanda CHAR(1);
    DEFINE det_MetodoCaptura CHAR;
    DEFINE det_TipoTransaccionposDigitada CHAR(2);
    DEFINE det_Bin CHAR(6);
    DEFINE det_SubBin CHAR(2);
    DEFINE det_ProductoInterCard CHAR(3);
    DEFINE det_Producto CHAR(1);
    DEFINE det_FechaExp CHAR(4);
    DEFINE det_GiroComercio CHAR(4);
    DEFINE det_CodigoIso CHAR(2);
    DEFINE det_IDTerminalRetailer CHAR(1); 
    DEFINE det_TerminalRetailer CHAR(1);
    DEFINE det_ChipBanda2 CHAR(1);
      

    DEFINE vicontadorregistros integer;
    DEFINE vnumcliente  varchar(13);
    DEFINE vestado char(2);
    DEFINE vnombreestado char(30) ;
    DEFINE vnumciudad char(3) ;
    DEFINE vnombreCiudad VARCHAR(60,1);
    DEFINE vcanal varchar(3);
    DEFINE vChipBanda varchar(5);
    DEFINE vbin varchar(6);
    DEFINE vsubbin varchar(2) ;
    DEFINE vproductoInterCard varchar(3) ;
    DEFINE vdescproductoInterCard varchar(30) ;
    DEFINE vproducto varchar(7) ;
    DEFINE vCuentaProducto varchar(13) ;
    DEFINE vmetodocaptura varchar(2) ;
    DEFINE vtipotransaccionposdigitada varchar(2);
    DEFINE vterminaTarjeta varchar(16); --4
    DEFINE vfechaexp varchar(4) ;
    DEFINE vFecha date;
    DEFINE vtxnOrigen  varchar(3) ;
    DEFINE vcomercio  varchar(40) ;
    DEFINE vgiroComercio varchar(4) ;
    DEFINE vdescGiroComercio varchar(80) ;
    DEFINE vafiliacionTerminal  varchar(19) ;
    DEFINE vTipoTransaccion  varchar(12) ; 
    DEFINE vmontoTxn DECIMAL(19,4);
    DEFINE vmontoCashBack DECIMAL(19,4);
    DEFINE vmontoSurcharge DECIMAL(19,4);
    DEFINE vcodigoiso varchar(2);
    DEFINE vmotivo  VARCHAR(70);

     DEFINE vnumtarjeta  VARCHAR(16);
     DEFINE vformato     VARCHAR(4);
     DEFINE vcodreversa  VARCHAR(1); 
     DEFINE vidreceptor  VARCHAR(4);
     DEFINE vidterminal  VARCHAR(16);
     DEFINE vidretailer  CHAR(19);
     DEFINE vcodtran     VARCHAR(2);
     DEFINE vmonto        DECIMAL(19,4);
     DEFINE vmontorealrevfzda    DECIMAL(19,4);
     DEFINE vedonombre VARCHAR(30);
     DEFINE vcodgironeg VARCHAR(4);
     DEFINE pstipocarga CHAR(1);

    DEFINE vcFechaCompInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vcFechaCompFinal DATETIME YEAR TO FRACTION(5);
    
    
    
    ---Inicializar
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'Ejecucion correcta.'; 
    LET RUTA_ORIGEN = '/RESPALDOSNEW/'; -- Producción  
    --LET RUTA_ORIGEN = '/ifxsif01/_argoz/parametrico/'; -- Desarrollo
    LET vitotalregistros = 0;
    LET vExecuteSQL = '';
    LET det_estado = '';
    LET det_Ciudad = '';
    LET det_Origen = '';
    LET det_Origen2 = '';
    LET det_ProdInd = '';
    LET det_ProdInd2 = '';
    LET det_ChipBanda = '';
    LET det_MetodoCaptura = '';
    LET det_TipoTransaccionposDigitada = '';
    LET det_Bin = '';
    lET det_SubBin = '';
    LET det_ProductoInterCard = '';
    LET det_Producto = '';
    LET det_FechaExp = '';
    LET det_GiroComercio = '';
    LET det_CodigoIso = '';
    LET det_IDTerminalRetailer = '';
    LET det_TerminalRetailer = ''; 
    LET det_ChipBanda2 = '';

    LET vnumcliente = '';
    LET vestado  = '';
    LET vnombreestado = '';
    LET vnumciudad = '';
    LET vnombreCiudad = '';
    LET vcanal = '';
    LET vChipBanda = '';
    LET vbin  = '';
    LET vsubbin = '';
    LET vproductoInterCard = '';
    LET vdescproductoInterCard = '';
    LET vproducto = '';
    LET vCuentaProducto = '';
    LET vmetodocaptura = '';
    LET vtipotransaccionposdigitada = '';
    LET vterminaTarjeta = '';
    LET vfechaexp = '';
    LET vFecha = '';
    LET vtxnOrigen  = '';
    LET vcomercio = '';
    LET vgiroComercio = '';
    LET vdescGiroComercio = '';
    LET vafiliacionTerminal = '';
    LET vTipoTransaccion  = '';
    LET vmontoTxn = '';
    LET vmontoCashBack = '';
    LET vmontoSurcharge  = '';
    LET vcodigoiso  = '';
    LET vmotivo   = '';
 
    LET vnumtarjeta  = '';
    LET vformato     = '';
    LET vcodreversa  = '';
    LET vidreceptor  = '';
    LET vidterminal  = '';
    LET vidretailer  = '';
    LET vcodtran     = '';
    LET vmonto               = 0;
    LET vmontorealrevfzda    = 0;
    LET vedonombre  = '';
    LET vcodgironeg = '';
    LET pstipocarga = '';

    LET vcFechaCompInicial = '';
    LET vcFechaCompFinal = '';
    
    --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_reporte_parametrico.out";
    --TRACE ON;
 
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_rpt_reporte_parametrico.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        ---Validar fechas
        EXECUTE PROCEDURE "informix".sp_rpt_validar_fechas_reporte (pdtFechaIni, pdtFechaFin)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vcFechaCompInicial, vcFechaCompFinal;
    
        IF(CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = MENSAJE_RESPUESTA||'ingresa a sp_rpt_validar_fechas_reporte';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
        END IF;

        ---Validar parametros
        EXECUTE PROCEDURE "informix".sp_rpt_calcular_parametros (psEstado,  psCiudad,  psOrigen,  psProdInd,  psBin, psSubBin,  psChipBanda,  psProductoInterCard,
                                                      psFechaExp,  psProducto,  psMetodoCaptura,  psTipoTransaccionposDigitada, psGiroComercio,  psIDTerminalRetailer,  psCodigoIso)  

            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA,det_estado, det_Ciudad,det_Origen,det_Origen2,det_ProdInd, det_ProdInd2,det_ChipBanda,det_MetodoCaptura,det_TipoTransaccionposDigitada,
	             det_Bin,det_SubBin,det_ProductoInterCard,det_FechaExp,det_GiroComercio,det_CodigoIso,det_IDTerminalRetailer,det_TerminalRetailer,det_ChipBanda2;
        
        IF(CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = MENSAJE_RESPUESTA||'ingresa a sp_rpt_calcular_parametros';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
        END IF

        TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;
        TRUNCATE TABLE intercard:"informix".rptdinamico;

        LET vdtFechaIni = pdtFechaIni;
        LET vdtFechaFin = pdtFechaFin; 
        LET vFechaMinimaMov = CURRENT;
  
        --OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS  EJ:  01/NOV/2017
        SELECT MIN(FechaHoraInAuth) 
            INTO vFechaMinimaMov
        FROM intercard:"informix".movimiento;
 
        -- A ===> Bandera para indicar que la busqueda se realice en intercard:movimiento 
        -----===>  e intercard:movimientohistorico
        LET pstipocarga = 'A';
 
        --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTO>	 
        IF ( (pdtFechaIni >= vFechaMinimaMov::DATE AND pdtFechaIni <= CURRENT::DATE)    -- EJ: 15/NOV/2017 >= 01/NOV/2017  AND 15/NOV/2017 <= 28/DIC/2017 (ACTUAL) 
                AND 
                (pdtFechaFin >= vFechaMinimaMov::DATE AND pdtFechaFin <= CURRENT::DATE)    -- EJ: 30/NOV/2017 >= 01/NOV/2017  AND 30/NOV/2017 <= 28/DIC/2017 (ACTUAL)
            ) THEN

                -- M ===> Bandera para indicar que la busqueda se realice en intercard:movimiento
                LET pstipocarga = 'M';

            ELIF ( (pdtFechaIni < vFechaMinimaMov::DATE) -- EJ: 01/OCT/2017  <  01/NOV/2017
                        AND (pdtFechaFin < vFechaMinimaMov::DATE) -- EJ: 31/OCT/2017  <  01/NOV/2017
                            
                ) THEN

                -- H  ===> Bandera para indicar que la busqueda se realice en intercard:movimientohistorico
                LET pstipocarga = 'H';

            END IF;

            EXECUTE PROCEDURE "informix".sp_rpt_obtener_transacciones (vcFechaCompInicial, vcFechaCompFinal, pstipocarga )
                    INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;

            IF(CODIGO_RETORNO <> '00000') THEN
            
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF

      -- Genera reporte final en base a la tabla de paso y con las tablas auxiliares para obtener los datos complementarios de la transacción
        ---	  (Tarjeta, cliente, estado etc):
            EXECUTE PROCEDURE "informix".sp_rpt_filtrado_param
                        (vcFechaCompInicial, vcFechaCompFinal, psEstado,         psCiudad,  psOrigen,  psProdInd,  psBin, psSubBin,  psChipBanda,  psProductoInterCard,
                         psFechaExp,  psProducto,  psMetodoCaptura,  psTipoTransaccionposDigitada, psGiroComercio,  psIDTerminalRetailer,  psCodigoIso,
                         det_estado, det_Ciudad,det_Origen,det_Origen2,det_ProdInd, det_ProdInd2,det_ChipBanda,det_MetodoCaptura,det_TipoTransaccionposDigitada,
                         det_Bin,det_SubBin,det_ProductoInterCard,det_FechaExp,det_GiroComercio,det_CodigoIso,det_IDTerminalRetailer,det_TerminalRetailer,det_ChipBanda2)
                INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;
 	
            IF(CODIGO_RETORNO <> '00000') THEN
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA||'error sp_rpt_filtrado_param';
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;

		    EXECUTE PROCEDURE "informix".sp_rpt_generar_archivo( RUTA_ORIGEN )
                INTO  CODIGO_RETORNO, MENSAJE_RESPUESTA;

            IF ( CODIGO_RETORNO <> '00000' ) THEN
            
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA||'error sp_rpt_generar_archivo';
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;
 
		 	--Obtiene el numero de registros procesados en el archivo resultante
		    SELECT COUNT(*) 
                INTO vitotalregistros 
            FROM intercard:"informix".rptdinamico;
		 	
		    TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;
		    TRUNCATE TABLE intercard:"informix".rptdinamico;

		 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);


	END;
END PROCEDURE;