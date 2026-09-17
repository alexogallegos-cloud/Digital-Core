CREATE PROCEDURE "informix".sp_consultarjetas_reportadas(pIdUsuario char(9), pTipoTarjeta char(1))
RETURNING char(5),char(16),char(100),DATETIME YEAR TO DAY,char(18),char(15),char(40);   

-- CreaciÃ³n: Solser Sistem
-- Fecha CreaciÃ³n: 04/05/2020
-- DescripciÃ³n: sp que realiza la consulta de las tarjetas reportadas en los Ãºltimos 3 meses 
-- SolicitÃ³: BanCoppel

-- Variables para el manejo de errores y codigo de retorno
DEFINE codRetorno char(5);
DEFINE isql_err integer;
-- Variables para retornar los datos de la consulta
DEFINE vFolio char(16);
DEFINE vTipoReporte char(100);
DEFINE vFechaOper DATETIME YEAR to DAY;
DEFINE vTarjeta char(18);
DEFINE vEstatus char(15);
DEFINE vNombreProd char(40);
-- Contadores
DEFINE contador integer;
DEFINE totalReg integer;
-- Variables para filtrar registros por rango de fecha
DEFINE vFechaInicio DATETIME YEAR TO DAY;
DEFINE vFechaFin DATETIME YEAR TO DAY;


-- INICIALIZACION DE VARIABLES
LET codRetorno = '00000';
LET vFolio = '';
LET vTipoReporte = '';
LET vFechaOper = '';
LET vTarjeta = '';
LET vEstatus = '';
LET vNombreProd = '';

LET contador = 0;
LET totalReg = 0;

LET vFechaInicio = ADD_MONTHS(CURRENT, -3);
LET vFechaFin = CURRENT;


BEGIN

    ON EXCEPTION SET isql_err
        IF isql_err <> 0 THEN
            LET codRetorno = isql_err;
            RETURN codRetorno, vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd;
        END IF;
    END EXCEPTION;
   
    --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consultarjetas_reportadas.out";
	--TRACE ON;
	
    -- Validacion de parametros de entrada
    IF (pIdUsuario IS NULL OR pTipoTarjeta IS NULL) THEN		
        LET codRetorno = '00001'; -- Los parametros de entrada no son validos
		RETURN codRetorno, vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd;
	END IF;

    
    IF (pTipoTarjeta = 'D') THEN -- TARJETA DE DEBITO
        FOREACH
            SELECT folio, --referencia as tipoReporte
            CASE
              WHEN referencia = "Reporte por cargos no reconocidos de tarjeta" THEN "Por cargo no reconocido"
              WHEN referencia = "Reporte por robo de tarjeta" THEN "Por robo"
              WHEN referencia = "Reporte por extravio de tarjeta" THEN "Por extravio"
              ELSE ""
            END as tipoReporte, 
            fecha_oper, destino as tarjeta, 'Cancelada' as estatus, pr.nombre
            INTO vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd
            FROM bdibpi:bpi_bitacora bi
            JOIN bdicheq:'informix'.sc_tarjeta tr ON (bi.destino = tr.num_tarjeta)
            JOIN bdicheq:'informix'.sc_producto pr ON (tr.prodtarjeta = pr.producto)
            WHERE id_operacion= '6007' AND id_usuario= pIdUsuario
            --AND fecha_oper::DATE BETWEEN vFechaInicio AND vFechaFin
            ORDER BY fecha_oper DESC
            
            LET contador = contador + 1;
            IF (contador <= 10) THEN
                RETURN codRetorno, vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd WITH RESUME;
            END IF;
        END FOREACH
    ELIF (pTipoTarjeta = 'C') THEN -- TARJETA DE CREDITO
        FOREACH
            SELECT folio, --referencia as tipoReporte
            CASE
              WHEN referencia = "Reporte por cargos no reconocidos de tarjeta" THEN "Por cargo no reconocido"
              WHEN referencia = "Reporte por robo de tarjeta" THEN "Por robo"
              WHEN referencia = "Reporte por extravio de tarjeta" THEN "Por extravio"
              ELSE ""
            END as tipoReporte, 
            fecha_oper, destino as tarjeta, 'Cancelada' as estatus, df.nombre_prod
            INTO vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd
            FROM bdibpi:bpi_bitacora bi
            JOIN bdicred:"informix".sd_tarjeta tr ON (bi.destino = tr.num_tarjeta)
            JOIN bdicred:"informix".sd_definicion df ON (df.num_producto = tr.prodtarjeta)
            WHERE id_operacion= '6004' AND id_usuario= pIdUsuario
            --AND fecha_oper::DATE BETWEEN vFechaInicio AND vFechaFin
            ORDER BY fecha_oper DESC

            LET contador = contador + 1;
            IF (contador <= 10) THEN
                RETURN codRetorno, vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd WITH RESUME;
            END IF;
        END FOREACH
    END IF;
	
	LET totalReg = contador;

	IF (totalReg = 0) THEN
		LET codRetorno = '00001'; -- No hay registros
		RETURN codRetorno, vFolio, vTipoReporte, vFechaOper, vTarjeta, vEstatus, vNombreProd;
	END IF;

END

END PROCEDURE;