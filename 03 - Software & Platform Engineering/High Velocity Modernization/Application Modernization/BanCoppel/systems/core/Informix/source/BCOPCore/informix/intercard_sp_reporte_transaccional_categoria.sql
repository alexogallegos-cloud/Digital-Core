CREATE PROCEDURE "informix".sp_reporte_transaccional_categoria(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5))
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, INTEGER as vTotalTransacciones;
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(100);
    
    DEFINE vTotalTransacciones INTEGER;
    DEFINE vFechaHoy DATE;
    DEFINE vFechaInicio DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);
    DEFINE vHoraInicio CHAR(13);
    DEFINE vHoraFin CHAR(13);    
    
    DEFINE SQL_ERR SMALLINT;
    DEFINE ISAM_ERR SMALLINT;
    DEFINE ERROR_INFO VARCHAR(60);
    DEFINE vExecuteSQL LVARCHAR(500);
    DEFINE vCorreoPara VARCHAR(250);
    DEFINE vCorreoCC VARCHAR(250);

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      SET DEBUG FILE TO RUTA_ORIGEN||"excepcion_lecciones.err.out";
      TRACE ON;
      
      LET CODIGO_RETORNO = SQL_ERR   ||     ISAM_ERR     ||   ERROR_INFO;
      LET MENSAJE_RETORNO = 'Excepcion general';
      
      RETURN CODIGO_RETORNO,MENSAJE_RETORNO, vTotalTransacciones;
    END EXCEPTION;
 
    BEGIN
 
        LET CODIGO_RETORNO  = '00000';
        LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
        LET RUTA_ORIGEN = '/resplogifx/mon_trans_categoria/';
        LET vTotalTransacciones = 0;        
        LET vFechaHoy = '';
        LET vFechaInicio = '';
        LET vFechaFinal = ''; 
        LET vHoraInicio = '00:00:00.0000';
        LET vHoraFin  = '00:00:00.0000';
        LET vExecuteSQL = '';        
        LET vCorreoPara = 'cima_monitoreo@bancoppel.com, mromero@bancoppel.com';
        LET vCorreoCC = 'jjortiz@bancoppel.com, jpuebla@bancoppel.com, agarciao@bancoppel.com';
    
        --SET DEBUG FILE TO RUTA_ORIGEN || "ejecucion_sp_reporte_transaccional_categoria.out";
        --TRACE ON;        
        
        DROP TABLE IF EXISTS tmp_total_transacciones;
        DROP TABLE IF EXISTS tmp_categorias;	

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT fecha_hoy
            INTO vFechaHoy
        FROM bdinteg:si_fechas
            WHERE empresa = '001';
        
        if( CURRENT::DATE < vFechaHoy) THEN
            LET CODIGO_RETORNO  = '00001';
            LET MENSAJE_RETORNO = 'Fecha del servidor menor a la fecha actual';
            RETURN CODIGO_RETORNO ,MENSAJE_RETORNO, vTotalTransacciones; 
        END IF

        LET vFechaInicio = pFechaInicio;
        LET vFechaFinal  = pFechaFin;
        
        ---Paso 1. Obtener total de transacciones
        SELECT COUNT(*) as total_transacciones
            INTO vTotalTransacciones
        FROM intercard:movimiento mov 
            WHERE fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND transaccionorigen = '1234';
        
        --- Obtener la categoria de las transacciones
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
        WHERE fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND transaccionorigen = '1234'
        GROUP BY 1,2
        ORDER BY 1
            INTO TEMP tmp_categorias WITH NO LOG;
        
        
        INSERT INTO intercard:tbl_reporte_general
        SELECT 
            cod_categoria, nombre_categoria, trxs_por_categoria, vTotalTransacciones, 
            CAST( ((trxs_por_categoria*100)/vTotalTransacciones) as DECIMAL(5,2))||'%' as porcentaje, 
            vFechaInicio, vFechaFinal,
            current, '1' as horario_ejecutado
        FROM tmp_categorias ORDER BY 1;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_ORIGEN||'regs_reporte.unl ' ||
         ' SELECT * FROM intercard:tbl_reporte_general ' ||         
         ' WHERE horainicio_busqueda >= \"'||vFechaInicio||'\" AND horafin_busqueda <= \"'||vFechaFinal||'\" ' ||
         ' ORDER BY 6,1; ' ||         
         ' "> '||RUTA_ORIGEN||'script_regs_reporte.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL= ' dbaccess intercard '||RUTA_ORIGEN||'script_regs_reporte.sql';
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = " awk 'BEGIN { FS=""|""; print ""CategorÃ­a   ""   ""  Nombre de categorÃ­a    ""    ""  NÃºmero de Transacciones  "" ""  Total de transacciones  ""   ""  Porcentaje ""   ""  Fecha y hora de ejecuciÃ³n\n----------  ------------------------- ------------------------- ------------------------- -------------- --------------------------\n""} "||
                --"{ printf ""%6s"" ""%25s"" ""%26s"" ""%25s"" ""%14s"" ""%26s\n"", $1, $2, ""cantidad  ""$3, $4, $5, $6 }' "||RUTA_ORIGEN||"regs_reporte.unl > "||RUTA_ORIGEN||"salida.log";
                "{ printf ""%6s"" ""%25s"" ""%26s"" ""%25s"" ""%14s"" ""%26s\n"", $1, $2, $3, $4, $5, $6 }' "||RUTA_ORIGEN||"regs_reporte.unl > "||RUTA_ORIGEN||"salida.log";
                --"{ print $1, $2, ""cantidad  ""$3, $4, $5, $6 }' "||RUTA_ORIGEN||"regs_reporte.unl > "||RUTA_ORIGEN||"salida.log";
        SYSTEM vExecuteSQL;        
       
        /*
        LET vExecuteSQL = '';
        LET vExecuteSQL = " awk 'BEGIN { FS=""|""; print ""CategorÃ­a ""   ""  Nombre de categorÃ­a  ""    ""  NÃºmero de Transacciones  "" ""  Total de transacciones  ""   ""  Porcentaje ""   ""  Fecha y hora de ejecuciÃ³n""} "||
                "{ print $1,$2, ""cantidad  ""$3, $4, $5, $6 }' "||RUTA_ORIGEN||"regs_reporte.unl > "||RUTA_ORIGEN||"salida.log";
        SYSTEM vExecuteSQL;  
        */
        
        --LET vExecuteSQL = '';
        --LET vExecuteSQL = 'mailx -s"Reporte de transaccionalidad | OLTP" '||vCorreoPara||' -c '|| vCorreoCC||' <  '||RUTA_ORIGEN||'salida.log';
        --SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||'script_regs_reporte.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        --LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||'salida.log';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        --LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||'regs_reporte.unl';
        SYSTEM vExecuteSQL;
        
        
        RETURN CODIGO_RETORNO ,MENSAJE_RETORNO, vTotalTransacciones; 
        
    END
    
END PROCEDURE
--Descripcion: Reporte de transaccionalidad.
--Base de datos: intercard
--14 de diciembre del 2018 17:00pm
;

CREATE PROCEDURE "informix".sp_synmotor_agregar_parametroswsdl_mx2(vRegistro INTEGER, vOperacion CHAR(5))
RETURNING CHAR(5) AS CodRet, CHAR(5) As TranIAC, CHAR(100) AS Etiqueta,CHAR(1) AS Tipo, CHAR(250) AS Descripcion1, CHAR(100) AS Campo, INTEGER AS IdParam, INTEGER AS Antecesor, INTEGER AS IdCampo, CHAR (50) AS Descripcion2, INTEGER AS IdSPCampo, CHAR(250) AS ValorDefault;
 
/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_agregar_parametros                         */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vEtiqueta CHAR(100);
DEFINE vTipo     CHAR(1); 
DEFINE vDescripcion1 CHAR(250); 
DEFINE vCampo CHAR(100);
DEFINE vId_Param INTEGER;
DEFINE vAntecesor INTEGER;
DEFINE vId_Campo INTEGER;
DEFINE vDescripcion2 CHAR (50);
DEFINE vId_SPCampo INTEGER;
DEFINE vValorDefault CHAR(250);
DEFINE vTranIAC CHAR(5);

LET vCodRet= '000';
LET vEtiqueta =  ' ';
LET vTipo     = ' '; 
LET vDescripcion1 = ' '; 
LET vCampo = ' ';
LET vId_Param = 0;
LET vAntecesor = 0;
LET vId_Campo = 0;
LET vDescripcion2 = ' ';
LET vId_SPCampo = 0;
LET vValorDefault = ' ';
LET vTranIAC  = ' ';
BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN  vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault;
		END IF;
	END EXCEPTION;
 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
	FOREACH
              
		/*
		SELECT SKIP vRegistro FIRST 12 tia.tran_iac As TranIAC, pa.etiqueta, pa.tipo, pa.descripcion, CASE when cia.campo is null then '' else cia.campo end as campo, pa.id_param, pa.antecesor, CASE when cia.id_campo is null then -1 else cia.id_campo end as id_campo, spc.descripcion as sp, CASE when spc.id_sp_campo is null then -1 else spc.id_sp_campo end as id_sp_campo, CASE when valordefault = 'null' then '' else valordefault end as valordefault
		INTO vTranIAC,vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
		FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
		ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
		LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
		INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
		WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
		*/
		
		SELECT SKIP vRegistro FIRST 12 tia.tran_iac As TranIAC, pa.etiqueta, pa.tipo, pa.descripcion, cia.campo,pa.id_param, pa.antecesor, cia.id_campo,spc.descripcion as sp, spc.id_sp_campo,valordefault
		INTO vTranIAC,vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
		FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
		ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
		LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
		INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
		WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
		
		LET vCampo =  NVL(vCampo,''); --CASE WHEN vCampo IS NULL THEN '' ELSE vCampo END;
		LET vId_Campo =  NVL(vId_Campo,''); --CASE WHEN vId_Campo IS NULL THEN '' ELSE vId_Campo END;
		LET vId_SPCampo =  NVL(vId_SPCampo,''); --CASE WHEN vId_SPCampo IS NULL THEN '' ELSE vId_SPCampo END;
		LET vValorDefault =  NVL(vValorDefault,''); --CASE WHEN vValorDefault IS NULL THEN '' ELSE vValorDefault END;

		RETURN vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault WITH RESUME; 
 
	END FOREACH;  
END;
END PROCEDURE;