CREATE PROCEDURE "informix".sp_muestra_servicios_mov(pEmpresa CHAR(3),pNumCte CHAR(9),pNumCel CHAR(10))
	RETURNING	CHAR(9) AS CodRet,
				CHAR(100) AS NombreServicio,
				CHAR(10) AS Estatus,
				CHAR(50) AS imei,
				CHAR(50) AS udid;
	

	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetorno		CHAR(9);
	DEFINE cNombreServicio	CHAR(100);
	DEFINE cEstatus		CHAR(10);
	DEFINE cImei		CHAR(50);
	DEFINE cUdid		CHAR(50);
	DEFINE cNumCte		CHAR(9);
	 
	LET iSqlErr				= 0;
	LET cCodRetorno			= '000000000';
	LET cNombreServicio		= '';
	LET cEstatus 			= '';
	LET cImei 				= '';
	LET cUdid 				= '';
	LET cNumCte 			= '';
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/tmp/sp_muestra_servicios_mov.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRetorno = iSqlErr;
				LET cNombreServicio = 'ERROR';
				RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid;
			END IF;
		END EXCEPTION;	
	
		IF pEmpresa = '' OR pNumCte = '' OR pNumCel = '' THEN
		
			LET cCodRetorno = '000000002';
		
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid;
		
		ELSE
			--Consulta servicio BanCoppel Mpvil
			LET cNombreServicio = 'BanCoppel Movil';
			
			SELECT num_cliente
			INTO cNumCte
			FROM bdibpi:"informix".bpi_reg_dispo_apps 
			WHERE num_cliente = pNumCte AND no_celular = pNumCel AND dispo_act = '1';
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
			END IF;
			LET cNumCte = '';
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			
			
			--Consulta servicio BanCoppel Express
			LET cNombreServicio = 'BanCoppel Express';
			
			SELECT num_cliente, imei, udid 
			INTO cNumCte, cImei, cUdid
			FROM bdibpi:"informix".bpi_registro_bex 
			WHERE num_cliente = pNumCte 
			AND no_celular = pNumCel AND servicio = 'activo';
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
				LET cImei = '';
				LET cUdid = '';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			LET cImei = '';
			LET cUdid = '';
			LET cNumCte = '';
			
			--Consulta servicio Token Digital
			LET cNombreServicio = 'Token Digital';
			
			SELECT num_cliente
			INTO cNumCte
			FROM bdinteg:"informix".si_bpitoken
			WHERE num_cliente = pNumCte  
			AND id_status_token = 140
			AND tipo_token = 2;
			
			IF cNumCte <> '' THEN
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
				LET cImei = '';
				LET cUdid = '';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			LET cImei = '';
			LET cUdid = '';
			LET cNumCte = '';
			
			--Consulta servicio CVV2 Dinamico (Compras en Linea)
			LET cNombreServicio = 'CVV2 Dinamico (Compras en Linea)';
			
			SELECT tar.numcliente
			INTO cNumCte
			FROM intercard:"informix".tarjeta tar, intercard:"informix".tarjeta_indicadores tarind
			WHERE tar.numcliente = pNumCte
			AND tar.codstatustarjeta = 'ACT'
			AND tar.titular = 'T'
			AND tarind.cvv2dinamico = 'V'
			AND tar.numtarjeta = tarind.numtarjeta;
			
			IF cNumCte <> '' THEN			
				LET cEstatus = 'ACTIVO';
			ELSE
				LET cEstatus = 'INACTIVO';
			END IF;
			RETURN cCodRetorno,cNombreServicio,cEstatus,cImei,cUdid WITH RESUME;
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 437 ICCAT - CVV2 DINAMICO - Adendum',
'AUTOR: Juan Pablo Soto',
'FECHA: 11/05/2018',
'SE CREA PROCEDIMIENTO PARA VALIDAR Y MOSTRAR LOS SERVICIOS MÓVILES ACTIVOS DEL CLIENTE.',
'DB: INTERCARD';

CREATE PROCEDURE "informix".sp_contador_dias_incidencia()
    RETURNING  DATE as vFecha_Retorno, INTEGER as v_Numero_Dias;

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    DEFINE vFechaDeIncidencia  DATE;
    DEFINE vNumeroDias  INTEGER;
    DEFINE vExecuteSQL LVARCHAR(2000);
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'Ejecucion exitosa';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/monitoreo_transaccional/eglobal/';    
    LET vFechaDeIncidencia  = '';
    LET vNumeroDias = '';
    LET vExecuteSQL = '';
    
    BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO        
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_generar_acum_corresponsal_mc.err.out";
            TRACE ON;            
            IF ( SQL_ERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQL_ERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN vFechaDeIncidencia, vNumeroDias;
            END IF;            
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; '||
        '       UNLOAD TO '||RUTA_ORIGEN||'rpte_contador_incidencias.unl' ||
         ' SELECT TO_CHAR(EXTEND(fecha, YEAR TO FRACTION(3)),\"%d-%m-%Y %H:%M:%S\"), '||
         '       TRIM(SUBSTR(current-fecha, 5, 5 )) as numero_dias, '||
         '        TRIM(SUBSTR(current-fecha, 10, 3 )) as horas, ' ||
         '       TRIM(SUBSTR(current-fecha, 14, 2 )) as minutos,' ||
         '       TRIM(SUBSTR(current-fecha, 17, 2 )) as segundos ' ||
         '  FROM intercard:tbl_contador_dias_incidencias ' ||
         ' WHERE estatus_dia = \"S\" '||         
         ' "> '||RUTA_ORIGEN||'script_rpte_contador_inc.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||'script_rpte_contador_inc.sql';
        SYSTEM vExecuteSQL;
    

    END;

    RETURN vFechaDeIncidencia, vNumeroDias;

END PROCEDURE
--Descripcion: Informacion para mostrar el numero de dias transcurridos de acuerdo a la ultima fecha de incidencia.
--Base de datos: intercard
--Fecha de creacion: 05 de marzo del 2020 19:00pm
--El shell pro_contador_incidencias.sh es el que usará el archivo rpte_contador_incidencias.unl
;

CREATE PROCEDURE "informix".sp_reporte_transaccional_categoria_notif(
            pFechaInicio DATETIME YEAR TO FRACTION(5),
            pFechaFin DATETIME YEAR TO FRACTION(5),
            pTopMotivos SMALLINT
    )
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, INTEGER as vTotalTransacciones;
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE vTotalTransacciones INTEGER;
    DEFINE vTransaccionesPorTiempo INTEGER;
    DEFINE vFechaInicialDate DATE;
    DEFINE vFechaIntegralHoy DATE;
    DEFINE vFechaAutorizadasDia DATE;
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5); 
    DEFINE vActualizarAcumulado CHAR(2);
    DEFINE SQL_ERR SMALLINT;
    DEFINE ISAM_ERR SMALLINT;
    DEFINE ERROR_INFO VARCHAR(60);
    DEFINE vExecuteSQL LVARCHAR(2000);
    DEFINE vTopMotivos SMALLINT;
    DEFINE vConteoRegPendiente SMALLINT;

    DEFINE vCodCategoria CHAR(2);
    DEFINE vNombreCategoria CHAR(25);
    DEFINE vNumTrxsCatPadre INTEGER;
    DEFINE vTotalPcte DECIMAL(19,2);
    DEFINE vFechaHoraActual DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaServidor DATE;
    DEFINE primera_hora_dia DATETIME YEAR TO FRACTION(5);
    DEFINE ultima_hora_dia DATETIME YEAR TO FRACTION(5);
    
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        
        SET DEBUG FILE TO RUTA_ORIGEN||"excepcion_sp_reporte_transaccional_categoria_notif.err.out";
        TRACE ON;
      
        LET CODIGO_RETORNO = SQL_ERR;
        LET MENSAJE_RETORNO = 'Excepcion general' || ISAM_ERR  || ERROR_INFO;
      
        RETURN CODIGO_RETORNO,MENSAJE_RETORNO, vTotalTransacciones;
        
    END EXCEPTION;
 
    BEGIN
 
        LET CODIGO_RETORNO  = '00000';
        LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
        LET RUTA_ORIGEN = '/RESPALDOSNEW/monitoreo_transaccional/eglobal/';
        LET vTotalTransacciones = 0;
        LET vTransaccionesPorTiempo = 0;
        LET vFechaInicialDate = '';
        LET vFechaAutorizadasDia = '';
        LET vFechaInicial = '';
        LET vFechaFinal = ''; 
        LET vExecuteSQL = '';
        LET vTopMotivos = pTopMotivos;
        LET vCodCategoria = '';
        LET vNombreCategoria = '';
        LET vNumTrxsCatPadre = 0;
        LET vTotalPcte = 0.00;
        LET vFechaHoraActual = CURRENT;
        LET vFechaServidor = CURRENT::DATE;
        LET vActualizarAcumulado = 'NO';
        LET primera_hora_dia = '';
        LET ultima_hora_dia = '';
        LET vConteoRegPendiente = 0;
        LET vFechaIntegralHoy = '';
    
        --SET DEBUG FILE TO RUTA_ORIGEN || "ejecucion_sp_reporte_transaccional_categoria_notif.out";
        --TRACE ON;
        
        DROP TABLE IF EXISTS tmp_categorias;
        DROP TABLE IF EXISTS tmp_trxs_tipo;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT fecha_hoy
            INTO vFechaIntegralHoy
        FROM bdinteg:si_fechas
            WHERE empresa = '001';
        
        IF( CURRENT::DATE < vFechaIntegralHoy) THEN
            LET CODIGO_RETORNO  = '00001';
            LET MENSAJE_RETORNO = 'Fecha del servidor menor a la fecha actual';
            RETURN CODIGO_RETORNO ,MENSAJE_RETORNO, vTotalTransacciones; 
        END IF

        LET vFechaInicial = pFechaInicio;
        LET vFechaFinal  = pFechaFin;
        
        ---Paso 1. Obtener el rango de tiempo en fechas enviadas por el shell
        ---Shell: monitor_transaccional_categoria.sh
        SELECT
            fechahorainauth::DATE as autorizadas_dia, prodind as tipo, COUNT(*) as cantidad
        FROM intercard:movimiento
            WHERE fechahorainauth BETWEEN vFechaInicial AND vFechaFinal
                AND transaccionorigen = '1234'
        GROUP BY 1, 2
            ORDER BY 1, 2
        INTO TEMP tmp_trxs_tipo WITH NO LOG;
        
        CREATE INDEX "informix".idx_tbl_tmp_trxs_tipo_autorizadas
            ON "informix".tmp_trxs_tipo(autorizadas_dia) ONLINE;        
        
        LET vFechaInicialDate = vFechaInicial::DATE;
        
        --Validacion para actualizar el acumulado total de transacciones por dia
        IF ( vFechaIntegralHoy <> vFechaServidor ) THEN
        
            SELECT COUNT(*)
                INTO vConteoRegPendiente
            FROM intercard:tbl_reporte_acumulado_trx
                    WHERE fecha_ejecucion = (EXTEND (vFechaServidor - 1 units DAY))::DATE
            AND acumulado_actualizado = 'N';
        
            --Fin de dia | Se actualizan los registros por tipo 
            IF ( vConteoRegPendiente > 0 ) THEN
        
                DROP TABLE IF EXISTS tmp_transacc_acum_dia;
                
                LET primera_hora_dia = (EXTEND (vFechaServidor - 1 units DAY))::DATE;
                LET primera_hora_dia = SUBSTRING(primera_hora_dia FROM 1 FOR 10) || ' 00:00:00.0000';
                
                LET ultima_hora_dia = (EXTEND (vFechaServidor - 1 units DAY))::DATE;
                LET ultima_hora_dia = SUBSTRING(ultima_hora_dia FROM 1 FOR 10) || ' 23:59:59.99999';
            
                SELECT 
                    fechahorainauth::DATE as autorizadas_acum_dia, 
                        prodind as tipo, 
                            COUNT(*) as cantidad
                    FROM intercard:movimiento
                        WHERE fechahorainauth BETWEEN primera_hora_dia AND ultima_hora_dia
                            AND transaccionorigen = '1234'
                        GROUP BY 1, 2
                            ORDER BY 1, 2
                INTO TEMP tmp_transacc_acum_dia WITH NO LOG;
    
                CREATE INDEX "informix".idx_tbl_tmp_transacc_acum_dia
                        ON "informix".tmp_transacc_acum_dia(autorizadas_acum_dia) ONLINE;
                
                MERGE INTO "informix".tbl_reporte_acumulado_trx as rpt_acum
                    USING
                        (
                            SELECT autorizadas_acum_dia, tipo, cantidad
                                FROM intercard:tmp_transacc_acum_dia
                            WHERE autorizadas_acum_dia =  (EXTEND (vFechaServidor - 1 units DAY))::DATE
                        ) as tmp_t
                        ON (rpt_acum.fecha_ejecucion = tmp_t.autorizadas_acum_dia)
                        AND rpt_acum.tipo_prodind = tmp_t.tipo
                            AND rpt_acum.acumulado_actualizado = 'N'
                WHEN MATCHED THEN UPDATE
                    SET rpt_acum.total_transacciones =  cantidad, 
                        rpt_acum.acumulado_actualizado = 'S';
                    
                DROP TABLE IF EXISTS tmp_transacc_acum_dia;
            
            END IF
            
        END IF

        ---Insertar o actualizar el acumulado por dia de ejecucion
        MERGE INTO "informix".tbl_reporte_acumulado_trx as rpt_acum
            USING
                (
                    SELECT autorizadas_dia, tipo, cantidad
                        FROM intercard:tmp_trxs_tipo
                    WHERE autorizadas_dia = vFechaInicialDate
                ) as tmp_t
                ON (rpt_acum.fecha_ejecucion = tmp_t.autorizadas_dia)
                AND rpt_acum.tipo_prodind = tmp_t.tipo
        WHEN MATCHED THEN UPDATE
            SET rpt_acum.total_transacciones =  rpt_acum.total_transacciones + tmp_t.cantidad
        WHEN NOT MATCHED THEN
            INSERT (rpt_acum.fecha_ejecucion , rpt_acum.tipo_prodind, rpt_acum.total_transacciones, rpt_acum.acumulado_actualizado)
                VALUES (tmp_t.autorizadas_dia, tmp_t.tipo , tmp_t.cantidad, 'N');


        ---Transacciones de TODO el dia
        SELECT SUM(total_transacciones) as trxs_al_dia
            INTO vTotalTransacciones        
        FROM intercard:tbl_reporte_acumulado_trx
            WHERE fecha_ejecucion = vFechaInicialDate;
            
        SELECT SUM(cantidad) as trxs_al_dia
            INTO vTransaccionesPorTiempo        
        FROM tmp_trxs_tipo
            WHERE autorizadas_dia = vFechaInicialDate;            
            
        --- Obtener la categoria general de las transacciones
        SELECT
            CASE
                WHEN mov.codigoiso IN ('12', '14', '82', '96') THEN '01'
                WHEN mov.codigoiso IN ('04', '57', '59', '62', '75') THEN '02'
                WHEN mov.codigoiso IN ('05') THEN '03'
                WHEN mov.codigoiso IN ('51', '54', '55') THEN '04'
                WHEN mov.codigoiso IN ('00') THEN '05'
            END cod_categoria,
            CASE
                WHEN mov.codigoiso IN ('12', '14', '82', '96') THEN 'Errores Tecnicos'
                WHEN mov.codigoiso IN ('04', '57', '59', '62', '75') THEN 'Errores Operativos'
                WHEN mov.codigoiso IN ('05') THEN 'Normativos'
                WHEN mov.codigoiso IN ('51', '54', '55') THEN 'Cliente'
                WHEN mov.codigoiso IN ('00') THEN 'Aprobadas'
            END nombre_categoria,
		COUNT(*) as trxs_por_categoria
            FROM intercard:movimiento mov
        WHERE fechahorainauth BETWEEN vFechaInicial AND vFechaFinal
            AND transaccionorigen = '1234'
        GROUP BY 1,2
            ORDER BY 1
                INTO TEMP tmp_categorias WITH NO LOG;
        
        CREATE INDEX "informix".idx_tbl_tmp_categorias_padre
            ON "informix".tmp_categorias(cod_categoria) ONLINE;

        FOREACH rpt_general FOR
            SELECT
                cod_categoria, nombre_categoria, trxs_por_categoria,
                CAST( ((trxs_por_categoria*100)/vTransaccionesPorTiempo) as DECIMAL(5,2)) as porcentaje, 
                vFechaInicial, vFechaFinal
            INTO vCodCategoria, vNombreCategoria, vNumTrxsCatPadre,
                        vTotalPcte, vFechaInicial, vFechaFinal
                FROM tmp_categorias
            ORDER BY 1

            INSERT INTO intercard:tbl_reporte_general(cod_categoria, nombre_categoria, trxs_por_categoria, total_transacciones,
                    resultado, horainicio_busqueda, horafin_busqueda, fechahora_ejecucion, horario_ejecutado)
                VALUES (vCodCategoria, vNombreCategoria, vNumTrxsCatPadre, vTransaccionesPorTiempo, 
                            vTotalPcte, vFechaInicial, vFechaFinal, vFechaHoraActual, '1');

        END FOREACH

        EXECUTE PROCEDURE "informix".sp_reporte_transaccional_detallado(vFechaInicial, vFechaFinal, vTransaccionesPorTiempo, vTopMotivos)
            INTO CODIGO_RETORNO, MENSAJE_RETORNO;

        ---El doble cero es para indicar la primera linea del archivo.
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'echo '||'00\|'|| TO_CHAR(vFechaInicial, '%d.%m.%Y %R')||'\|'||TO_CHAR(vFechaFinal, '%d.%m.%Y %R')||'\|'||
        ' >'||RUTA_ORIGEN||'hora_rpte_detalle_trxs.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||'rpte_acumulado_por_dia.unl ' ||
         ' SELECT tipo_prodind, total_transacciones ' ||
         '  FROM intercard:tbl_reporte_acumulado_trx ' ||
         ' WHERE fecha_ejecucion = \"'||vFechaInicialDate||'\" '||
         ' ORDER BY 1,2; ' ||
         ' "> '||RUTA_ORIGEN||'script_rpte_acumulado_dia.sql';
        SYSTEM vExecuteSQL;
                
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||'script_rpte_acumulado_dia.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'cat '||RUTA_ORIGEN||'rpte_acumulado_por_dia.unl ' ||
        ' >>'||RUTA_ORIGEN||'hora_rpte_detalle_trxs.txt';
        SYSTEM vExecuteSQL;
        
        ---El 03 es un indicador para la suma de transacciones totales del dia.
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'echo '||'03\|'||NVL(vTotalTransacciones,0)||'\|'||
        ' >>'||RUTA_ORIGEN||'hora_rpte_detalle_trxs.txt';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||'script_rpte_acumulado_dia.sql';
        SYSTEM vExecuteSQL;
        
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO, vTotalTransacciones; 
        
    END
    
END PROCEDURE

--Descripcion: Reporte de transaccionalidad.
--Base de datos: intercard
--Fecha de creacion: 14 de diciembre del 2018 19:00pm
--Fecha de modificacion: 10 de marzo del 2019  | Se agrega funcionalidad para el acumulado por dia
;

CREATE PROCEDURE "informix".sp_move_lotedesucursal(p_numerolote integer, p_clave_suc_ori varchar(5), p_clave_suc_des varchar(5))
RETURNING varchar(6), varchar(80);
-- Cambiar Lote de Sucursal
/**************************************************************************/
/* Fecha: 27/02/2009                                                      */
/* SPL: "informix".sp_move_lotedesucursal()                               */
/* Actividad: Se encarga de mover una tarjeta de sucursal                 */
/* Realizado por: Aaron Quiroz /Syndein                                   */
/* Modificado:25/04/2009 para crear la relacion sucursaltipotarjeta       */
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  cCodRet                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  c_mensaje                   varchar(80);


DEFINE v_cant_tarjetas_x_lote      integer;
DEFINE v_clave_tipotarjeta         integer;
DEFINE v_Cuantas                   integer;
BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                    ROLLBACK WORK;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
BEGIN work;
       
    /*Se obtiene la clave del tipo de tarjeta*/
    SELECT clave_tipotarjeta INTO v_clave_tipotarjeta
    FROM lote
    WHERE
        numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori;


    /*Obtiene el numero lote y Sucursal de una Tarjeta*/
   /* SELECT lt.clave_sucursal,lt.numerolote 
                      FROM tarjeta t, lote lt 
                      WHERE t.numerolote = lt.numerolote 
                      AND t.numtarjeta = '';*/



    /*Se obtiene el numero de tarjetas INA y NOA del lote (Existencias en Inventario)*/
    SELECT count(numtarjeta) into v_cant_tarjetas_x_lote
                      FROM tarjeta t, lote lt 
                      WHERE t.numerolote = lt.numerolote 
		      AND  t.CodStatusAsignada = 'NOA' 
                      AND t.codstatustarjeta = 'INA'
		      AND lt.clave_sucursal = p_clave_suc_ori
		      AND lt.numerolote = p_numerolote;

    /*Validar que tenga tarjetas INA y NOA*/

   /*Validar que exista el lote*/
   SELECT COUNT(*) INTO v_Cuantas FROM lote WHERE  numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori ;

   if v_Cuantas <= 0 THEN
      LET vcodret = '001';
      LET p_mensaje = 'No existe la relacion sucursal origen con numero de lote.';
      ROLLBACK WORK;
      RETURN vcodret, p_mensaje;
    END IF;

    /*Se cambia el lote de sucursal */
    UPDATE lote SET clave_sucursal = p_clave_suc_des 
    WHERE  numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori ;

    /*Validar que exista la relacion Sucursal origen tipo de tarjeta*/
    SELECT COUNT(*) INTO v_Cuantas FROM sucursal_tipotarjeta 
    WHERE clave_sucursal = p_clave_suc_ori AND clave_tipotarjeta = v_clave_tipotarjeta;
    if v_Cuantas <= 0 THEN
      LET vcodret = '002';
      LET p_mensaje = 'No existe la relacion sucursal  tipotarjeta origen.';
      ROLLBACK WORK;
      RETURN vcodret, p_mensaje;
    END IF;

     /*Se decrementa la existencia*/
    UPDATE sucursal_tipotarjeta set existencia = existencia - v_cant_tarjetas_x_lote 
    WHERE clave_sucursal = p_clave_suc_ori AND clave_tipotarjeta = v_clave_tipotarjeta;

    /*Validar que exista la relacion sucursal destino y tipo de tarjeta*/
    SELECT COUNT(*) INTO v_Cuantas FROM sucursal_tipotarjeta 
    WHERE clave_sucursal = p_clave_suc_des AND clave_tipotarjeta = v_clave_tipotarjeta;
    if v_Cuantas <= 0 THEN
     /*Si no existe crearla*/
      insert into sucursal_tipotarjeta (clave_sucursal,  clave_tipotarjeta,  existencia,  solicitadas)
	values(p_clave_suc_des,v_clave_tipotarjeta,0,0);
    END IF;

     /*Se incrementa la existencia*/
    UPDATE sucursal_tipotarjeta set existencia = existencia + v_cant_tarjetas_x_lote 
    WHERE clave_sucursal = p_clave_suc_des AND clave_tipotarjeta = v_clave_tipotarjeta;


  
    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';
    COMMIT WORK;
RETURN vcodret, p_mensaje;
END;
END PROCEDURE;