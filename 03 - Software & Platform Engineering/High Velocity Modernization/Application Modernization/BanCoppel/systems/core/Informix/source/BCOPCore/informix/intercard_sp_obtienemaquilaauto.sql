CREATE PROCEDURE "informix".sp_obtienemaquilaauto()
RETURNING CHAR(6);

DEFINE iSqlErr  		INTEGER;
DEFINE cCodRet  		CHAR(6);
DEFINE cSql				CHAR(1000);
DEFINE cRuta			CHAR(50);
DEFINE cSucursal		CHAR(4);
DEFINE cNomSuc 			CHAR(40);
DEFINE cMes				CHAR(2);
DEFINE cDia				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE cFechaHoy		CHAR(20);
DEFINE cNomArch			CHAR(100);
DEFINE cRutaArchivo		CHAR(200);
DEFINE iGCB				INTEGER;
DEFINE iNumTarSoli		INTEGER;
DEFINE iNumTarCteNvo	INTEGER;
DEFINE iNumTarRepo		INTEGER;
DEFINE iTotal			INTEGER;
DEFINE cFechaMesAnt		CHAR(20);

LET iSqlErr			= 0;
LET cCodRet 		= '000000';
LET cSql 			= '';
LET cRuta 			= '';
LET cNomSuc			= '';
LET	cSucursal		= '';
LET cFechaHoy		= '';
LET cNomArch		= '';
LET cRutaArchivo	= '';
LET cMes			= '';
LET cDia			= '';
LET cAnio			= '';
LET iGCB			= 0;
LET iNumTarSoli		= 0;
LET iNumTarCteNvo	= 0;
LET iNumTarRepo		= 0;
LET iTotal			= 0;
LET cFechaMesAnt	= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_obtienemaquilaauto.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO cRuta FROM bdicred:"informix".sd_param WHERE cod_param = '130' AND empresa = '001';
	SELECT valor INTO cNomArch FROM bdicred:"informix".sd_param WHERE cod_param = '132' AND empresa = '001';
	
	IF TRIM(NVL(cRuta,'')) != '' AND TRIM(NVL(cNomArch,'')) != '' THEN
		SELECT fecha_hoy, ADD_MONTHS(fecha_hoy, -1)
		INTO cFechaHoy, cFechaMesAnt
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = '001';
		
		LET cDia = LPAD(DAY(cFechaHoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(cFechaHoy::DATE), 2, '0');
		LET cAnio = YEAR(cFechaHoy);
		
		LET cNomArch = REPLACE(cNomArch,'dd',cDia);
		LET cNomArch = REPLACE(cNomArch,'mm',cMes);
		LET cNomArch = REPLACE(cNomArch,'aaaa',cAnio);
		LET cNomArch = TRIM(cNomArch) || '.txt';
		
		LET cRutaArchivo = TRIM(cRuta) || TRIM(cNomArch);
		
		--Elimina archivo
		LET cSQL = 'rm -rf ' || TRIM(cRutaArchivo);		
		SYSTEM cSQL;	
		--Crea archivo vacio
		LET cSQL = 'touch ' || TRIM(cRutaArchivo);
		SYSTEM cSQL;
		
		FOREACH
			SELECT TRIM(nombre), sucursal ,id_gerencia_rh AS GCB 
			INTO cNomSuc, cSucursal, iGCB
			FROM bdinteg:"informix".si_sucursales 
			WHERE nombre LIKE 'SUC%'
			ORDER BY sucursal
			
			--No. de tarjetas solicitadas
			SELECT lot.cantidadtarjetassol AS TarjetasSolicitadas	
			INTO iNumTarSoli
			FROM intercard:"informix".sucursal suc, intercard:"informix".lote lot , 
				intercard:"informix".flujolote flulot, intercard:"informix".tipotarjeta tipotar 
			WHERE suc.clave_sucursal = cSucursal
			AND suc.clave_sucursal = lot.clave_sucursal 
			AND lot.numerolote = flulot.numerolote
			AND tipotar.clave_tipotarjeta = '007'
			AND lot.clave_tipotarjeta = tipotar.clave_tipotarjeta
			AND lot.fechageneracion::DATE = cFechaMesAnt
			GROUP BY suc.clave_sucursal, lot.cantidadtarjetassol;
			
			--No. de tarjetas entregadas a clientes nuevos
			SELECT COUNT(tar.num_tarjeta)
			INTO iNumTarCteNvo
			FROM bdicred:"informix".sd_tarjeta AS tar
			LEFT JOIN bdicred:"informix".sd_maecred AS cred ON tar.numcte = cred.numcte
			LEFT JOIN bdisolic:"informix".ss_solicitudes AS sol ON sol.numcte = tar.numcte AND sol.num_solicitud = cred.num_credito
			WHERE tar.prodtarjeta = '8100'
			AND sol.status_solicitud = 'AP'
			AND sol.fecha_insert = cFechaMesAnt
			AND sol.sucursal = cSucursal
			GROUP BY sol.sucursal;
			
			--No. de tarjetas entregadas a clientes por reposiciones
			SELECT COUNT(tar.num_tarjeta)
			INTO iNumTarRepo
			FROM bdicred:"informix".sd_tarjeta tar, bdisolic:"informix".ss_solicitudes sol
			WHERE sol.num_solicitud = tar.num_credito
			AND sol.fecha_insert = cFechaMesAnt
			AND tar.prodtarjeta = '8100'
			AND tar.secuencia > 1
			AND sol.sucursal = cSucursal
			AND sol.status_solicitud = 'AP';
			
			LET iTotal = (NVL(iNumTarSoli,0) + NVL(iNumTarCteNvo,0) + NVL(iNumTarRepo,0));
			
			--Escribe en archivo
			LET cSQL = 'echo "' || TRIM(cNomSuc) || ' | ' || TRIM(cSucursal) || ' | ' || NVL(iGCB,0) || ' | ' || NVL(iNumTarSoli,0) || ' | ' || NVL(iNumTarCteNvo,0) || ' | ' || NVL(iNumTarRepo,0) || ' | ' || iTotal || '" >> ' || cRutaArchivo;
			SYSTEM cSQL;
			
		END FOREACH;		
	ELSE
		LET cCodret = '000001';
	END IF;	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para la creacion de txt para proceso de abastecimiento automÃ¡tico.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 08/05/2021',
'BD    : INTERCARD';

CREATE PROCEDURE "informix".sp_monitor_volumen_tablas()
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (80) as rMENSAJE_RETORNO, 
				DECIMAL(19,2) as rPorcentaje, VARCHAR(100)  as rAcotacion;
	
    DEFINE SQLERR INTEGER;
	DEFINE ISAM_ERR INTEGER;
	DEFINE ERROR_INFO VARCHAR(80);    
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE vPrefijoArchivoUNL VARCHAR(10);
    DEFINE vPrefijoScripts VARCHAR(10);
    DEFINE vPrefijoScriptsSalida VARCHAR(10);
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRespuesta VARCHAR(80);
    DEFINE vTabId INTEGER;
    DEFINE vGrupoBD VARCHAR(6);
    DEFINE vNombreBD VARCHAR(15);
    DEFINE vNombreTabla VARCHAR(50);
    DEFINE vExecuteSQL LVARCHAR(800);    
    DEFINE vConteoReg INTEGER;
    DEFINE vExisteRegistro INTEGER;
    DEFINE vValorPorcentaje VARCHAR(5);
    DEFINE vIndicadorPorcentaje DECIMAL(19,2);
    DEFINE vDescripcionPorcentaje VARCHAR(100);
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';    
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET vCodigoRetorno = '00000';
    LET vMensajeRespuesta = 'Iniciando el proceso';
    LET vTabId = '';
    LET vGrupoBD = '';
    LET vNombreBD = '';
    LET vNombreTabla = '';
    LET vExecuteSQL = '';
    LET vPrefijoArchivoUNL = 'mnt_trx_';
    LET vPrefijoScripts = 'scpt_mnt_';
    LET vPrefijoScriptsSalida = 'scpt_sal_';
    LET vConteoReg = 0;
    LET vExisteRegistro = 0;    
    LET vValorPorcentaje = 0;
    LET vIndicadorPorcentaje = 0;    
    LET vDescripcionPorcentaje = '';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS|| 'debug_sp_monitor_volumen_tablas.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_monitor_volumen_tablas.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRespuesta = vMensajeRespuesta;
                RETURN vCodigoRetorno, vMensajeRespuesta, vIndicadorPorcentaje, vDescripcionPorcentaje;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        ---Eliminacion de archivos con ejecucion previa del proceso.
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'*';
        SYSTEM vExecuteSQL;

        ---Inicializar los tabids por si en algún momento las tablas fueron previamente renombradas.
        FOREACH curTabId WITH HOLD FOR 
            
            SELECT {+AVOID_FULL(intercard:"informix".tbl_monitor_tablas_transacc)}
                    grupo_bd, tabid, nombre_bd, nombre_tabla
                INTO vGrupoBD, vTabId, vNombreBD, vNombreTabla
            FROM intercard:"informix".tbl_monitor_tablas_transacc
            ORDER BY nombre_bd, nombre_tabla
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            '   MERGE INTO intercard:tbl_monitor_tablas_transacc as b ' ||
            '     USING  '||
            '       (  '||
            "         SELECT * "||
            "            FROM "||vNombreBD||":systables   "||
            "         WHERE tabname = '"||vNombreTabla||"'"||
            "           AND owner = 'informix' "||
            '       )as sys  '||
            '       ON (b.nombre_tabla = sys.tabname)  '||
            '   WHEN MATCHED THEN UPDATE  '||
            '    SET b.tabid = sys.tabid;'||
            '" >'||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'chmod 777 ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql';
            SYSTEM vExecuteSQL;

            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql 2>> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'curtabid.log';
            SYSTEM vExecuteSQL;
            
            LET vCodigoRetorno ='00000';
            LET vMensajeRespuesta ='Ejec #1:'||vNombreTabla;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||'*';
            SYSTEM vExecuteSQL; 
            
        END FOREACH
        
        FOREACH curTotalReg WITH HOLD FOR 
            
            SELECT {+AVOID_FULL(intercard:"informix".tbl_monitor_tablas_transacc)} 
                    tabid, nombre_bd, nombre_tabla
                INTO vTabId, vNombreBD, vNombreTabla
            FROM intercard:"informix".tbl_monitor_tablas_transacc
                WHERE habilitada = 'S'
            ORDER BY nombre_bd, nombre_tabla
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            "   UPDATE  intercard:tbl_monitor_tablas_transacc "||
            "      SET total_registros =  (SELECT COUNT(*) as total_registros FROM "||vNombreBD||":"||vNombreTabla||") "||
            "   WHERE nombre_bd = '"||vNombreBD||"' AND  nombre_tabla = '"||vNombreTabla||"'"||
            '  ;'||            
            '" >'||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'chmod 777 ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql  2> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'curtotalreg.log';
            SYSTEM vExecuteSQL;
            
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta ='Ejec #2:'||vNombreTabla;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'*';
            --SYSTEM vExecuteSQL;
            
        END FOREACH
        
        MERGE INTO "informix".tbl_monitor_tablas_transacc as cmp
            USING
                ( 
                SELECT {+AVOID_FULL (sysmaster:systabnames)} 
                        st.tabname, st.dbsname,
                        format_units(SUM(i.ti_nptotal), MAX(sd.pagesize)) total_size,
                        format_units(SUM(i.ti_npused), MAX(sd.pagesize)) used_size
                    FROM
                        sysmaster:systabnames st INNER JOIN intercard:"informix".tbl_monitor_tablas_transacc b
                    ON (st.tabname = b.nombre_tabla AND st.tabname = b.nombre_tabla) INNER JOIN sysmaster:sysdbspaces sd
                        ON (sd.dbsnum = TRUNC(st.partnum/1048576) ) INNER JOIN sysmaster:systabinfo i
                            ON ( st.partnum = i.ti_partnum )
                        WHERE sd.owner = 'informix'
                            AND st.owner = 'informix'
                                AND st.dbsname = b.nombre_bd
                    GROUP BY 1,2
                ) as tmp_reg
                ON tmp_reg.tabname = cmp.nombre_tabla AND tmp_reg.dbsname = cmp.nombre_bd
            WHEN MATCHED THEN
                UPDATE
                    SET cmp.total_size = tmp_reg.total_size, 
                            cmp.used_size = tmp_reg.used_size;

        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Obtener parametro porcentaje';
        
        SELECT valores
            INTO vValorPorcentaje
        FROM intercard:"informix".tbl_inter_parametros
            WHERE cond_busqueda = 'ind_pcte_vol'
                AND empresa = '001';
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Obtener descripcion porcentaje';
        
		SELECT descripcion 
			INTO vDescripcionPorcentaje
		FROM tbl_inter_parametros 
			WHERE cond_busqueda = 'msj_monitor_volumen';
            
        LET vIndicadorPorcentaje = vValorPorcentaje::DECIMAL(19,2);

        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Descargar informacion';
        
        FOREACH curTotalReg WITH HOLD FOR 
        
            SELECT {+AVOID_FULL (intercard:"informix".tbl_monitor_tablas_transacc)}
                   DISTINCT nombre_bd
                INTO vNombreBD
            FROM intercard:"informix".tbl_monitor_tablas_transacc
                WHERE habilitada = 'S'
            
            LET vExecuteSQL	= '';
            LET vExecuteSQL = 'echo " '||
            '  SET ISOLATION TO DIRTY READ; '||
            '  SET LOCK MODE TO WAIT 3; '||
            '    UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||'monitor_tbls_'||vNombreBD||'.unl'||
            '      SELECT nombre_bd, nombre_tabla, total_registros, total_size, used_size, '  ||
            '           SUBSTR(total_size, CHAR_LENGTH(total_size) - 1, CHAR_LENGTH(total_size)) as T, '  ||
            '           SUBSTR(used_size, CHAR_LENGTH(used_size) - 1, CHAR_LENGTH(used_size)) as U, '  ||
            '           '||vIndicadorPorcentaje||
            '      FROM intercard:"informix".tbl_monitor_tablas_transacc ' ||
            "     WHERE nombre_bd = '"||vNombreBD||"'"||
            "       AND habilitada = 'S' "||
            "     ORDER BY 3 DESC "||
             '" >'||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql';
            SYSTEM vExecuteSQL;        
            
            LET vExecuteSQL   = '';
            LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql 2> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'err_unload.log';
            SYSTEM vExecuteSQL;
        
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta ='Descarga' ||vNombreBD;
        
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql';
            SYSTEM vExecuteSQL;
            
        END FOREACH
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Proceso Finalizado';
        
        RETURN vCodigoRetorno, vMensajeRespuesta, vIndicadorPorcentaje, vDescripcionPorcentaje;
    END

END PROCEDURE
DOCUMENT
'Armando García Ortiz',
'Monitoreo de Volumen de Informacion | Coordinación de Tarjetas',
'Modificacion...02 de agosto del 2021',
'#2',
'Modificacion...10 de enero del 2022',
'Se agrega el codigo de retorno, respuesta y el archivo de salida en cada ciclo para identificar un posible error de ejecucion',
'#3',
'Modificacion: 18 de enero del 2022',
'Se agrega set isolation y set lock en cada actualizacion de la tabla registrada en el catálogo. Cursor curTotalReg'
;

CREATE PROCEDURE "informix".sp_manntto_bitacoraspinoffline (pe_sysdate DATETIME YEAR TO FRACTION(5))
RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(300) AS MENSAJE_RETORNO;

    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       CHAR(40);
    DEFINE CODIGO_RETORNO 	CHAR(5);
    DEFINE MENSAJE_RETORNO 	CHAR(150);
    DEFINE ANIO_MES		CHAR (06);
    DEFINE RUTA_ORIGEN	CHAR (80);
    DEFINE dtfechahoy	DATETIME YEAR TO FRACTION(5);
    DEFINE canio		CHAR (04);
    DEFINE cmes		CHAR (02);
    DEFINE cdia		CHAR (02);
    DEFINE cnombretabla1 	CHAR (50);
    DEFINE cnombretabla2 	CHAR (50);
    DEFINE vExecuteSQL 	CHAR (1500);
    DEFINE cbandera		CHAR (50);
    DEFINE cnombretablapivote1 	CHAR (20);
    DEFINE cnombretablapivote2 	CHAR (20);
    DEFINE crenombratabla1	CHAR (20);
	
    --	SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
    --	TRACE ON; 
	
    let SQL_ERR = 0;
    let ISAM_ERR = 0;
    let ERROR_INFO = '';
    let CODIGO_RETORNO = '00000';
    let MENSAJE_RETORNO = 'sp_manntto_bitacoraspinoffline ejecutado exitosamente.';
    let dtfechahoy = pe_sysdate;
    let canio = substr (dtfechahoy, 1, 4);
    let cmes = substr (dtfechahoy, 6, 2);
    let cdia = substr (dtfechahoy, 9, 2); 
    let cnombretabla1 = '';
    let cnombretabla2 = '';
    let vExecuteSQL = '';
    let cbandera = '';
    let cnombretablapivote1 = '';
    let cnombretablapivote2 = '';
    let crenombratabla1 = '';
	
BEGIN        
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
        TRACE ON;
        LET CODIGO_RETORNO = SQL_ERR;
        LET MENSAJE_RETORNO = ISAM_ERR||ERROR_INFO;            
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
    END EXCEPTION;        

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
/*
    SELECT 
		fecha_hoy, YEAR (fecha_hoy), month (fecha_hoy), day (fecha_hoy) 
		into dtfechahoy, canio, cmes, cdia
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
*/
	drop table if exists "informix".bitacorapinoffline_pivoterepo;
	drop table if exists "informix".bitpinoffline_pivoterepo;
		
--	TablaPivote1: bitacorapinoffline_pivoterepo:
	CREATE TABLE "informix".bitacorapinoffline_pivoterepo 
	( 
		numtarjeta       	CHAR(16) NOT NULL,
		fechageneracion  	DATETIME YEAR to FRACTION(5) NOT NULL,
		transaccionorigen	VARCHAR(4) NOT NULL,
		estatusscripting 	INTEGER,
		secuenciaorig    	VARCHAR(6),
		respuestatlv     	VARCHAR(255),
		tag_9f5b         	VARCHAR(11),
		idterminal       	VARCHAR(16),
		PRIMARY KEY(fechageneracion,numtarjeta,transaccionorigen)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;

	
--	TablaPivote2: bitpinoffline_pivoterepo:
	CREATE TABLE "informix".bitpinoffline_pivoterepo 
	( 
		numtarjeta        	CHAR(16) NOT NULL,
		tarjeta_edoinicial	CHAR(1) NOT NULL,
		tarjeta_edofinal  	CHAR(1) NOT NULL,
		sucursal          	CHAR(4) NOT NULL,
		ip_pc             	CHAR(15) NOT NULL,
		ejecutivo         	CHAR(8) NOT NULL,
		fechahora_insert  	DATETIME YEAR to FRACTION(5) NOT NULL,
		PRIMARY KEY(fechahora_insert,numtarjeta)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;


	--	Renombrado de tablas actuales a <_aniomes>:
		let cnombretabla1 = 'bitacorapinoffline_'||canio||cmes; 

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline TO "'||cnombretabla1||'> renombratabla1.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla1.sql';
		SYSTEM vExecuteSQL;

		let cnombretabla2 = 'bitpinoffline_'||canio||cmes; 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bit_pinoffline TO "'||cnombretabla2||'> renombratabla2.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla2.sql';
		SYSTEM vExecuteSQL;


	--	Renombrado de tablas pivote a limpias:
			--	LET cnombretablapivote1 = 'bitacorapinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline_pivoterepo TO bitacorapinoffline"> renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			--	LET cnombretablapivote2 = 'bit_pinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitpinoffline_pivoterepo TO bit_pinoffline"> renombratablapivote2.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
			
			LET vExecuteSQL = '';
			LET vExecuteSQL ='rm -f renombratabla1.sql renombratabla2.sql renombratablapivote1.sql renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
	
	
    RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');

    END
END PROCEDURE
DOCUMENT
'AUTOR: FRG',
'Proyecto: RQI nn ccc Depuracion tablas <intercard:bitacorapinoffline> e <intercard:bit_pinoffline>',
'Fecha de creacion: 30.Enero.2021',
'Fecha de modificacion: N/A.',
'Invocacion: execute procedure "informix".sp_manntto_bitacoraspinoffline (current);', 
'Base de datos: intercard'
;

CREATE PROCEDURE "informix".sp_obtiene_cte_contacto_cap ( 
                                                           pNumEmpCoppel   CHAR(9), 
														   pCuenta         VARCHAR(4)
														)

RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO, CHAR(1) as VC_TIPOENVIO, VARCHAR(10) AS ALERTA, VARCHAR(15) AS ID_PLANTILLA, CHAR(20) AS NUMCTE;	
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80); 
    DEFINE RUTA_DESTINO VARCHAR(80);	
	
	DEFINE valerta1             varchar(10);
    DEFINE valerta2             varchar(10);
	DEFINE ALERTA                varchar(10);
    DEFINE vIdPlantilla1        varchar(15); 
    DEFINE vIdPlantilla2        varchar(15); 
	DEFINE ID_PLANTILLA         varchar(15); 
	DEFINE VC_TIPOENVIO          char(1); 
   
    DEFINE VC_NUMCTE 	        CHAR (20);
    DEFINE vstelefono	        INTEGER;
    DEFINE vscorreo			    INTEGER;
	DEFINE vCuentaComp VARCHAR(13);
	DEFINE vempleado CHAR(9);
	DEFINE vcuenta VARCHAR(13);
	DEFINE vcuentacorta Varchar(4);
	
	LET RUTA_DESTINO  = '/RESPALDOSNEW/';
    LET vstelefono         = 0;
    LET VC_NUMCTE           = '';
    LET vscorreo           = 0;
	LET codigo_retorno  = '00000';
	LET MENSAJE_RETORNO     = '';
	LET VC_TIPOENVIO = '';
	LET vCuentaComp = ''; 
	LET vempleado = '';
	LET vcuenta = '';
	LET vcuentacorta = '';
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap.out";
    --TRACE ON;        	
	
BEGIN 
	
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap_e.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN			  
			      DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;			
                  LET CODIGO_RETORNO = SQLERR;
                  LET MENSAJE_RETORNO = ERROR_INFO;                
                 RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,vIdPlantilla2,NVL(VC_NUMCTE,'0');
            END IF;
			
        END EXCEPTION;	

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
------------------------------------------------------------------------------------------------------------------------
		 LET codigo_retorno  = '00000';
		 LET mensaje_retorno = 'PROCESO EXITOSO';
		 LET vIdPlantilla1 ='D_CAPP_EMAIL';    -- plantilla email   
		 LET valerta1      ='CMPC_BATCH';    -- alerta email 
		
		 LET vIdPlantilla2 ='D_CAPP_SMS';    -- plantilla sms     
         LET valerta2      ='CMPS_BATCH';    -- alerta sms 
		 
		LET ALERTA = '';
     	LET ID_PLANTILLA = '';

		--DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;

	   --Creacion de tabla de paso   
	     CREATE TEMP TABLE ctas_nomina_emp_paso
         (
            num_empleado       CHAR(9),
            cuenta             VARCHAR(13),
            cuenta_corta      VARCHAR(4)
         ) WITH NO LOG LOCK MODE ROW;

		    CREATE INDEX "informix".idx_ctas_nomina_emp_paso_1 ON "informix".ctas_nomina_emp_paso(num_empleado) ;
 
		    foreach cur_F1_main WITH hold for
		
		         Select  num_empleado,cuenta INTO vempleado,vcuenta from intercard:ctas_nomina_empleado where num_empleado = pNumEmpCoppel	 
  
		          LET vcuentacorta = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
 
			     INSERT INTO "informix".ctas_nomina_emp_paso  (num_empleado,cuenta,cuenta_corta)
		         VALUES  (vempleado,vcuenta,vcuentacorta );

		   end foreach; 
		----------
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_nomina_emp_paso;  
		----------
		Select limit 1 cuenta into vCuentaComp from ctas_nomina_emp_paso where num_empleado = pNumEmpCoppel and  cuenta_corta  = pCuenta;
		----------
		--Obtiene el num. de cte. 
		----------
		  SELECT limit 1 num_cte  INTO VC_NUMCTE
          FROM bdicheq:sc_maechq 
          WHERE  empresa = '001' 
          AND  cuenta = vCuentaComp; 
		  
		  IF VC_NUMCTE IS NULL THEN 

		                 DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
		  
		  					LET MENSAJE_RETORNO = 'EMP-CTA NO ENCONTRADO EN CATALOGO COPPEL';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
		      RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');
		  END IF;
		  
		----------
		  Select  COUNT(*) INTO  vscorreo
		  from   bdinteg:"informix".si_correos sic 
          Where  sic.tipo_correo = '1'
          and sic.status_correo = 'A'
          and numcte =  VC_NUMCTE; 
 
		  Select  COUNT(*) INTO vstelefono 
          from  bdinteg:"informix".si_telefonos_actual sit 
          where sit.status_tel = 'A' 
          AND sit.tipo_tel = '2'
          AND numcte = VC_NUMCTE ; 
 
            IF    (vscorreo = '0' and vstelefono = '0')   THEN 

							LET MENSAJE_RETORNO = 'CLIENTE SIN DATOS DE CONTACTO';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
			    
			ELIF ( (vscorreo <> '0' AND vscorreo is not null) ) THEN 	
			       --email 
			            LET  VC_TIPOENVIO   = '1';
						LET  MENSAJE_RETORNO     = 'OK EMAIL';
				     	LET ALERTA = valerta1;
			         	LET ID_PLANTILLA = vIdPlantilla1;
 
            ELIF   ( (vstelefono <> '0' AND vstelefono is not null) ) THEN  
		
					-- sms 
					    LET  VC_TIPOENVIO   = '2';
						LET  MENSAJE_RETORNO     = 'OK SMS';
				     	LET ALERTA = valerta2;
			         	LET ID_PLANTILLA = vIdPlantilla2;
 
			END IF; 
 
           DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
------------------------------------------------------------------------------------------------------------------------

    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');


END;
END PROCEDURE;