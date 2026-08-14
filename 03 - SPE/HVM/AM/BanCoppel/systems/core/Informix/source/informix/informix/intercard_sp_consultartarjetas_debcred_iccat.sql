CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_iccat(pempresa char(3), pnumcte char(9), pstatus char (3),pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(3), char(20), char(60), char(1), char(1), char(1);   

DEFINE ccodret char(9);
DEFINE isql_err integer;
DEFINE cvnumcte char (20);
DEFINE cvnomcliente char (104);
DEFINE cvnumtarjeta char (16);
DEFINE cvestatus_tar char (3);
DEFINE cvnumcuenta char (20);
DEFINE cvstatuscuenta char (60);
DEFINE cvtitular char (1);
DEFINE cvradiobuton char(1);
DEFINE cvtipotar char(1);
DEFINE cstatus_tarjeta char(1);

--@comment: Declaracion variables para tabla temporal 
DEFINE cv_trjasig_num_cte char (20);
DEFINE cv_cta_cuenta char (20);
DEFINE cv_ctast_descripcion char (60);
DEFINE cv_astrj_num_tarjeta char (16);
DEFINE cv_astrj_status_tar char(1);
DEFINE cv_trj_nombre char (104);
DEFINE cv_trj_codstatustarjeta char (3);
DEFINE cv_trj_titular char (1);

LET ccodret = "000000001"; -- NO TIENE TARJETAS 
LET cvnumcte = "";
LET cvnomcliente = "";
LET cvnumtarjeta = "";
LET cvestatus_tar = "";
LET cvnumcuenta = "";
LET cvstatuscuenta = "";
LET cvtitular = "";
LET cvradiobuton = "T";
LET cvtipotar = '';
LET cstatus_tarjeta = '';

--@comment: Inicializar variables para tabla temporal 
LET cv_trjasig_num_cte = "";
LET cv_cta_cuenta = "";
LET cv_ctast_descripcion = "";
LET cv_astrj_num_tarjeta = "";
LET cv_astrj_status_tar = '';
LET cv_trj_nombre = "";
LET cv_trj_codstatustarjeta = "";
LET cv_trj_titular = "";

BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION DIRTY READ;
	--SET DEBUG FILE TO '/informix/tmp/sp_consultartarjetas_debcred_iccat.out';
	--TRACE ON;

	--Validar y crear tabla temporal intercard:tmp_tarjetas_debcret_iccat
	--SET ISOLATION TO DIRTY READ;
	/*IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_tarjetas_debcret_iccat' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".tmp_tarjetas_debcret_iccat;
	END IF;*/
	DROP TABLE IF EXISTS tmp_tarjetas_debcret_iccat;

	CREATE TEMP TABLE tmp_tarjetas_debcret_iccat(
		numcte char(20), 
		nombre varchar(104), 
		num_tarjeta char(20),
		codstatustarjeta varchar(3),
		num_cuenta_credito char(20),
		descripcion char(60),
		titular varchar(1),
		habilitado char(1),
		tipo_tarjeta char(1),
		status_tar char(1)
	);

	--Obtener tarjetas de debito de las que el cliente es titular
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'		
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito de otros clientes de la que el cliente es adicional
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'		
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de credito de las que el cliente es titular
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de credito de otros clientes de la que el cliente es adicional
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Asignar en tabla temporal bandera de tarjeta habilitado/deshabilitado para activación
	UPDATE tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'T';
	UPDATE tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'A';
	--UPDATE intercard:"informix".tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'F' WHERE tmp.numcte <> pnumcte AND tmp.titular = 'T';

	--Retornar todas las tarjetas en la tabla temporal
	SET LOCK MODE TO WAIT 3;
	FOREACH 
		SELECT SKIP pNumRegistros FIRST 10 nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar
		INTO cvnomcliente, cvnumtarjeta, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cvtipotar, cstatus_tarjeta
		FROM tmp_tarjetas_debcret_iccat
		
		LET ccodret = '000000000';
		
		RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta WITH RESUME;
                --DROP TABLE tmp_tarjetas_debcret_iccat;
	END FOREACH;

	IF (ccodret = '000000001') THEN
		RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
                DROP TABLE tmp_tarjetas_debcret_iccat;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Consulta tarjetas inactivas de débito platino y crédito',
'AUTOR:		Felipe Monzón Mendoza',
'FECHA : 	26/05/2017',
'BD : 		intercard',

'OBJETIVO: 	Se retorna el campo: status_tar',
'MODIFICÓ:	Keevyn Adrian Gil Valenzuela',
'FECHA : 	21/08/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica codigo para dismunuir costo',
'MODIFICÓ:	Ruben Antonio Ojeda Milan',
'FECHA : 	19/10/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica código para validar producto desde sc_maechq en Débito y sd_maecred en Crédito',
'MODIFICÓ:	José Luis Polanco B.',
'FECHA : 	31/05/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica código para Excluir Tarjetas de Crédito Clásica e Inhibir borrado de tabla temporal',
'MODIFICÓ:	José Luis Polanco B.',
'FECHA : 	18/09/2019',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_rpt_trim_generar_archivos(    
    pRUTA_ORIGEN VARCHAR(30),
    pRUTA_UNLOAD VARCHAR(30),
    pTipoPlantilla VARCHAR(15),
    pIdPlantilla CHAR(1)
    )
    
    RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;

    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(100);
    DEFINE CODIGO_RETORNO CHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);        
    DEFINE vTotalRegistros INTEGER;
    DEFINE vTotalInterna INTEGER;
    DEFINE vRegistrosMaxPorArchivo INTEGER;
    DEFINE vExecuteSQL CHAR(1150);
    DEFINE vContadorArchivos VARCHAR(4);
    DEFINE vNumInicioRegistros INTEGER;    
    DEFINE vNombreScript CHAR(30);    
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET vTotalRegistros = 0;
    LET vTotalInterna = 0;
    LET vRegistrosMaxPorArchivo = 1;
    LET vContadorArchivos = '1';
    LET vNumInicioRegistros = 0;
    LET vNombreScript = 'script_rpt_trim_archivos.sql';
    
    --SET DEBUG FILE TO pRUTA_ORIGEN||"sp_rpt_trim_generar_archivos.out";
    --TRACE ON;    
    
    BEGIN    
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO pRUTA_ORIGEN || "excepcion_sp_rpt_trim_generar_archivos.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;            
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT COUNT(*) conteo_total 
            INTO vTotalRegistros 
        FROM info_reporte_trimestral 
            WHERE plantilla = pIdPlantilla;
    
        --Obtener el NUMERO MAXIMO DE REGISTROS POR ARCHIVO. 
        --vRegistrosMaxPorArchivo: Valor inicial del requerimiento 200 (29.junio)
        
        SELECT valor1
            INTO vRegistrosMaxPorArchivo 
        FROM bditarjeta:td_parametro
            WHERE clave = 'REGMAX_POR_ARCH';
        
        -- Sin registros en la tabla info_reporte_trimestral
        -- Por requerimiento se debe generar el archivo indicando 
        -- en el total de registros con el valor cero (0)
        IF (vTotalRegistros = 0) THEN
        
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "BANCOPPEL|productos||mail1|'||pTipoPlantilla||'|'||vTotalRegistros||'"> '||pRUTA_UNLOAD||pTipoPlantilla||'_00.ready';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "'||pRUTA_UNLOAD||pTipoPlantilla||'"_00.unl SELECT * FROM info_reporte_trimestral WHERE plantilla = "'||pIdPlantilla||'";" >'||pRUTA_UNLOAD||vNombreScript;
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard '||pRUTA_UNLOAD||vNombreScript;
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL ='rm '||pRUTA_UNLOAD||vNombreScript;
            SYSTEM vExecuteSQL;
        
            LET vExecuteSQL ='';
            LET vExecuteSQL = "sed 's/|s//g' "||pRUTA_UNLOAD||pTipoPlantilla||"_00.unl >> "||pRUTA_UNLOAD||pTipoPlantilla||"_00.ready";
            SYSTEM vExecuteSQL;
            
            --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
            LET vExecuteSQL ='';
            LET vExecuteSQL ='echo "<EOF>" >> '||pRUTA_UNLOAD||pTipoPlantilla||"_00.ready";
            SYSTEM vExecuteSQL; 
                
            LET vExecuteSQL ='';
            LET vExecuteSQL ='rm '||pRUTA_UNLOAD||pTipoPlantilla||'_00.unl';
            SYSTEM vExecuteSQL;
            
            ----------------------------------------------------------------------------------------------------------------------------------------------------
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
            
        END IF;       
        
        --La consulta tiene mas de un registro | Creacion de los 'n' archivos resultantes
        IF (vTotalRegistros >  0) THEN            
           
            WHILE (vTotalRegistros > 0 ) LOOP
                
                --Registros Base almacenado en la base de datos:bditarjeta / tabla:td_parametro / clave: REGMAX_POR_ARCH
                --La variable vRegistrosMaxPorArchivo = 20,000 | Requerimiento inicial 03 Julio
                
                LET vTotalInterna = vTotalRegistros - vRegistrosMaxPorArchivo; -- 20,000 es la base
                
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
                
                LET vExecuteSQL = '';
                LET vExecuteSQL = 'echo "BANCOPPEL|productos||mail1|'||pTipoPlantilla||'|'||vTotalInterna||'"> "'||pRUTA_UNLOAD||pTipoPlantilla||'"_'||vContadorArchivos||'.ready';
                SYSTEM vExecuteSQL;
                
                --Consulta utilizada para ir paginando los registros en cada archivo iniciando
                --del registro 0 hasta la base de la variable vRegistrosMaxPorArchivo en cada ciclo.
                ---SELECT SKIP '||vNumInicioRegistros||' FIRST  vRegistrosMaxPorArchivo                
                
                LET vExecuteSQL = '';
                LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "'||pRUTA_UNLOAD||pTipoPlantilla||'"_'||vContadorArchivos||'.unl SELECT SKIP '||vNumInicioRegistros||' FIRST '||vRegistrosMaxPorArchivo||' correo_electronico, titular FROM info_reporte_trimestral WHERE plantilla = "'||pIdPlantilla||'";" >'||pRUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL ='';
                LET vExecuteSQL= 'dbaccess intercard '||pRUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL = '';
                LET vExecuteSQL ='rm '||pRUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;
            
                --Sustitucion del numero de asteriscos por pipes y eliminacion del ultimo pipe de cada registro.
                LET vExecuteSQL ='';
                LET vExecuteSQL = "sed -e 's/\*/|/g' -e 's/[|]*$//' "||pRUTA_UNLOAD||pTipoPlantilla||"_"||vContadorArchivos||".unl >> "||pRUTA_UNLOAD||pTipoPlantilla||"_"||vContadorArchivos||".tmp_ready";
                SYSTEM vExecuteSQL;
                
                --Linea que genera los numeros de linea de cada uno de los registros obtenidos | No se hace en la base de datos para mejorar optimizacion.
                LET vExecuteSQL ='';
                LET vExecuteSQL = " sed = "||pRUTA_UNLOAD||pTipoPlantilla||"_"||vContadorArchivos||".tmp_ready | sed 'N;s/\n/|/' >> "||pRUTA_UNLOAD||pTipoPlantilla||"_"||vContadorArchivos||".ready";
                SYSTEM vExecuteSQL;
                
                --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
                LET vExecuteSQL ='';
                LET vExecuteSQL ='echo "<EOF>" >> '||pRUTA_UNLOAD||pTipoPlantilla||"_"||vContadorArchivos||".ready";
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL ='';
                LET vExecuteSQL ='rm '||pRUTA_UNLOAD||pTipoPlantilla||'_'||vContadorArchivos||'.tmp_ready';
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL ='';
                LET vExecuteSQL ='rm '||pRUTA_UNLOAD||pTipoPlantilla||'_'||vContadorArchivos||'.unl';
                SYSTEM vExecuteSQL;
                
                --El numero vRegistrosMaxPorArchivo es la base de registros por archivo
                LET vNumInicioRegistros = vNumInicioRegistros + vRegistrosMaxPorArchivo;
                
                LET vContadorArchivos = vContadorArchivos::INTEGER + 1;
                --Se realiza una suma de la variable vNumInicioRegistros (cero) mas vRegistrosMaxPorArchivo
                --Para que en ciclo 2 el SKIP comience en el resultado de vNumInicioRegistros
               
               --Se actualiza la variable de registros faltantes por ingresar en el archivo.
                LET vTotalRegistros = vTotalRegistros - vTotalInterna;
            END LOOP;
            
        END IF;       
       
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
    
    END
    
END PROCEDURE
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Fecha de creacion: 10.septiembre.2019
-- Base de datos: intercard
-- Descripcion:
-- El procedimiento almacenado es utilizado por los jobs 533_00, 533_01, 533_02, 533_03 y 533_04
-- Para crear los archivos de cada reporte de los jobs y con extension .ready
*/
;

CREATE PROCEDURE "informix".sp_rpt_trim_obtener_parametros( pRutaOrigen VARCHAR(80), pTipoReporte VARCHAR(16),
    pNumeroMeses VARCHAR(2), pNumMesAnteriorSdo INTEGER
)    
RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO,
        CHAR(2) as rPrimerMesTrimestral, DATE as rPrimerDiaMes, 
            DATE as rFechaInicio, DATE as rFechaFinal, CHAR(6) as rAnyoMes, INTEGER as rSaldoPromedio;
    
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(100);
    DEFINE CODIGO_RETORNO CHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE OCTUBRE CHAR(2);
    DEFINE vFechaInicio DATE;
    DEFINE vFechaFinal DATE;
    DEFINE vSaldoPromedio INTEGER;
    DEFINE vAnyoMes CHAR(6);    
    DEFINE vPrimerMesTrimestral CHAR(2);
    DEFINE vPrimerDiaMes DATE;
    
    DEFINE RPT_TARJ_PRESENTE VARCHAR(20);
    DEFINE RPT_TARJ_NO_PRESENTE VARCHAR(20);
    DEFINE RPT_TARJ_TAG VARCHAR(20);
    DEFINE RPT_TARJ_ATM VARCHAR(20);
    DEFINE RPT_TARJ_VENT VARCHAR(20);
    DEFINE CVE_SALDO_REPORTE VARCHAR(20);
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET OCTUBRE = '10';
    LET vFechaInicio = '';
    LET vFechaFinal = ''; 
    LET vSaldoPromedio = 0;
    LET vAnyoMes = '';    
    LET vPrimerMesTrimestral = '';    
    LET vPrimerDiaMes = '';
    
    LET RPT_TARJ_PRESENTE = 'TP_CAPTA';    
    LET RPT_TARJ_NO_PRESENTE = 'TNP_CAPTA';
    LET RPT_TARJ_TAG = 'TAG_CAPTA';
    LET RPT_TARJ_ATM = 'ATM_CAPTA';
    LET RPT_TARJ_VENT = 'VENT_CAPTA';
    LET CVE_SALDO_REPORTE = '';  
    
    --SET DEBUG FILE TO pRutaOrigen||"sp_rpt_trim_obtener_parametros.out";
    --TRACE ON;        
        
    BEGIN
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO            
            SET DEBUG FILE TO pRutaOrigen || "excepcion_sp_rpt_trim_obtener_params.err.out";
            TRACE ON;            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;
                RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vPrimerMesTrimestral, vPrimerDiaMes, vFechaInicio, vFechaFinal, vAnyoMes , vSaldoPromedio;
            END IF;            
        END EXCEPTION;        

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
        SELECT 
            MONTH(EXTEND(pri_dia_mes) - pNumeroMeses units month), pri_dia_mes, 
                    EXTEND(pri_dia_mes) - pNumeroMeses units month, EXTEND(pri_dia_mes)
                INTO vPrimerMesTrimestral, vPrimerDiaMes, vFechaInicio, vFechaFinal  
        FROM bdinteg:si_fechas        
            WHERE empresa = '001';
    
        --Campos empleados para la ejecucion del reporte trimestral: abril, julio y octubre.
        LET vAnyoMes = YEAR(today)||LPAD(MONTH(EXTEND(vPrimerDiaMes) - pNumMesAnteriorSdo units month), 2, "0");

        IF ( vPrimerMesTrimestral = OCTUBRE ) THEN
            --Campos empleados para la ejecucion del reporte trimestral: enero | Cambio de anio.
            LET vAnyoMes = YEAR(today) - 1||LPAD(MONTH(EXTEND(vPrimerDiaMes) - pNumMesAnteriorSdo units month), 2, "0");
        END IF;
        
        
        IF ( pTipoReporte = RPT_TARJ_PRESENTE ) THEN
            LET CVE_SALDO_REPORTE = 'SDO_TDD_PRESENTE';
        ELIF ( pTipoReporte = RPT_TARJ_NO_PRESENTE ) THEN
            LET CVE_SALDO_REPORTE = 'SDO_TDD_NOPRESENTE';
        ELIF ( pTipoReporte = RPT_TARJ_TAG ) THEN
            LET CVE_SALDO_REPORTE = 'SDO_TDD_COMPRA_TAG';
        ELIF ( pTipoReporte = RPT_TARJ_ATM ) THEN
            LET CVE_SALDO_REPORTE = 'SDO_TDD_RETIRO_ATM';
        ELIF ( pTipoReporte = RPT_TARJ_VENT ) THEN
            LET CVE_SALDO_REPORTE = 'SDO_TDD_VENTANILLA';
        END IF

        SELECT valor1 
            INTO vSaldoPromedio 
        FROM bditarjeta:td_parametro
            WHERE clave = CVE_SALDO_REPORTE;

        IF (vPrimerMesTrimestral IS NULL OR vPrimerMesTrimestral = '') OR
            (vPrimerDiaMes IS NULL OR vPrimerDiaMes = '') OR
            (vFechaInicio IS NULL OR vFechaInicio = '') OR
            (vFechaFinal IS NULL OR vFechaFinal = '') OR
            (vAnyoMes IS NULL OR vAnyoMes = '') OR
            (vSaldoPromedio IS NULL OR vSaldoPromedio = '') THEN
               
               LET CODIGO_RETORNO = '00001';
               LET MENSAJE_RETORNO = 'Faltan parametros|sp_rpt_trim_obtener_parametros';
               
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vPrimerMesTrimestral, vPrimerDiaMes, vFechaInicio, vFechaFinal, vAnyoMes , vSaldoPromedio;
            
        END IF
       
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vPrimerMesTrimestral, vPrimerDiaMes, vFechaInicio, vFechaFinal, vAnyoMes , vSaldoPromedio;
    
    END
    
END PROCEDURE
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Fecha de creacion: 10.septiembre.2019
-- Base de datos: intercard
-- El procedimiento almacenado es utilizado por los jobs 533_00, 533_01, 533_02, 533_03 y 533_04
-- Validar y obtener los parametros indispensables para cada reporte.
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral
*/
;

CREATE PROCEDURE "informix".sp_tarj_det_vcas_test()
RETURNING VARCHAR(10), VARCHAR(255)

	DEFINE vfecha			DATETIME YEAR TO FRACTION(5);
	
	
	DEFINE vstatus_proc		CHAR(1);
	
	DEFINE vcod_ret         VARCHAR(10); 
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE error_info       CHAR(40);
	
	DEFINE v_dia        	CHAR(2);
    DEFINE v_mes        	CHAR(2);
    DEFINE v_ano        	CHAR(4); 
	DEFINE v_hora			DATETIME HOUR TO SECOND;
    DEFINE v_hora2			CHAR(8);
    DEFINE v_sql        	CHAR(250);
    DEFINE cEncabezado  	CHAR(250);
	
	DEFINE cRuta			CHAR(250);
    DEFINE cRuta2			CHAR(250);
	DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
	DEFINE var_numtarjeta   VARCHAR(16);
	DEFINE var_telefono     CHAR(13);
	DEFINE var_correo_elec 	CHAR(100);
	DEFINE var_fecha        DATETIME YEAR to SECOND;
	
	DEFINE iContador_pay    SMALLINT;
    
	DEFINE vreg_ins 		INTEGER;

	--MANEJO DEL ERROR.
       ON EXCEPTION
		SET sql_err, isam_err, error_info
			
			UPDATE intercard:ctrl_info_ctes_vcas
			  SET status_proc = '0';

           IF sql_err <> 0 THEN
              LET vcod_ret=sql_err;
			  UPDATE intercard:ctrl_info_ctes_vcas 
					SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
              RETURN vcod_ret, isam_err||' ' ||error_info;
           END IF;
       END EXCEPTION;
	
	--set debug file to "/tmp/sp_tarj_det_vcas.out";
	--TRACE ON;
				
	LET vfecha = TODAY;	
	LET vstatus_proc = '';
	
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	LET iContador_pay = 0;
	
	LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
	LET v_hora			= CURRENT;
    LET v_hora2			= "";
    LET v_sql           = "";
	
    LET cEncabezado     = "";
	
	LET cRuta	= "/tmp/";
    LET cRuta2	= "/RESPALDOSNEW/VCAS_resultados/";
	LET cNombreArchivo	= "";
    LET cNombreArchivo1	= "";
    LET cNombreArchivo2	= "";

    LET var_action 			= "";
	LET var_numtarjeta      = "";
	LET var_telefono       	= "";
	LET var_correo_elec 	= "";
	LET var_fecha          	= CURRENT;
		
	LET vreg_ins = 0;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
	SELECT status_proc 
	INTO vstatus_proc
	FROM intercard:ctrl_info_ctes_vcas;

	IF(vstatus_proc = '1') THEN
		UPDATE intercard:ctrl_info_ctes_vcas 
			SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
		RETURN vcod_ret, 'DESCARGA EN PROCESO';
	END IF;
    
    UPDATE intercard:ctrl_info_ctes_vcas
	SET status_proc = '1';  
	  
	SELECT fecha
	INTO vfecha	
    FROM intercard:ctrl_info_ctes_vcas;			 	
	
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
     TRUNCATE TABLE intercard:ctas_vcas;
	 
  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion>=vfecha
    INTO temp tmptarj with no log;

	CREATE INDEX "informix".tmp_tartarj_vcas
    ON tmptarj(numtarjeta);
	
	SELECT bin 
	FROM intercard:bines WHERE marca ='VS'
	INTO temp BIN_VISA with no log;

    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta 
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt
        ON tmpctestarj(numcte);

    CREATE INDEX "informix".tmp_tarj_pt
        ON tmpctestarj(num_tarjeta);

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta 
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);
	
    -- TABLA TELEONOS TIPO 2
	SELECT {+AVOID_FULL(bdinteg:si_telefonos_actual)} telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    WHERE tipo_tel = 2 
    INTO temp tmptelefono_tipo2 with no log;
	
	CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora); 
    CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte); 
	

    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfecha
    GROUP BY telefono, numcte
    UNION 
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte 
    INTO temp tmptelefono with no log;
	
	CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(telefono);
    CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte);


    -- TABLA CORREOS  TIPO 1
	SELECT {+AVOID_FULL(bdinteg:si_correos)} tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 
	INTO temp tmpsi_correos with no log;
	
	CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);
	
	--TEMPORAL DE CORREOS
	
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfecha AND C.valido = 1 
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas
    ON tmpcorreo(correo_elec);

    CREATE INDEX "informix".tmp_numctecorr_vcas
    ON tmpcorreo(numcte);

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta 
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts
        ON tmpctestarjfin(numcte);

    CREATE INDEX "informix".tmp_tarj_pts
        ON tmpctestarjfin(num_tarjeta);

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta 
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas
    ON tmptarjeta(numtarjeta);

    CREATE INDEX "informix".tmp_numclient_vcas
    ON tmptarjeta(numcte);

    CREATE INDEX "informix".tmp_fechasig_vcas
    ON tmptarjeta(fechaasignacion);
    
	-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
		BEGIN WORK;
		FOREACH WITH HOLD
            SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
				A.numtarjeta, 
				B.telefono AS telefono, 
				C.correo_elec AS correo_elec, 
				CURRENT AS fecha
            INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
            LEFT JOIN tmptelefono B ON A.numcte=B.numcte
            LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
			AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action
			
			LET iContador_pay = iContador_pay + 1;
			
			INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha) 
                    VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
        
          IF iContador_pay = 1000 THEN
		  COMMIT;
		  LET	iContador_pay = 0;
		  BEGIN WORK;
		  END IF;
		END FOREACH;	
		COMMIT; 
		
	-- DESCARGAR ARCHIVO.
		   LET v_dia = LPAD(DAY(CURRENT),2,'0');  
		   LET v_mes = LPAD(MONTH(CURRENT),2,'0');
		   LET v_ano = year(CURRENT);
           LET v_hora2 = v_hora::CHAR(8);
		   LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
           LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
           LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
		          
		   -- DESCARGA DEL ARCHIVO .CSV.
			LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
            System cEncabezado;

			LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
			System v_sql;

            LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';						
			System v_sql;
						
			LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
			System v_sql;

			LET v_sql="";
			
		   --SE AÃADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
			LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            LET v_sql="";

			LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
            LET v_sql = "";
            LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
            SYSTEM v_sql;

			--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo1);	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo2);	
            SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	  INTO vfecha 	
	  FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN 
	     LET vfecha = CURRENT;
	END IF 
	 
	-- CONTEO DE REGISTROS.
	SELECT COUNT(*) 
	  INTO vreg_ins
	  FROM intercard:ctas_vcas;
				
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
     TRUNCATE TABLE intercard:ctas_vcas;
	 
	 DROP TABLE BIN_VISA;
	 DROP TABLE tmpctestarj;
     DROP TABLE tmptelefono;
     DROP TABLE tmpcorreo;
	 DROP TABLE tmptarjeta;	
     DROP TABLE tmptarj;
     DROP TABLE tmpctestarjfin;
	 		
	-- ACTUALIZAR TABLA CONTROL.
	  UPDATE intercard:ctrl_info_ctes_vcas
	    SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);		

			  
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;