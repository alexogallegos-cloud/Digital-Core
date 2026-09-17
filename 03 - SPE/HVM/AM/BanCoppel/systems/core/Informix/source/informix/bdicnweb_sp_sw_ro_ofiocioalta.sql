CREATE PROCEDURE "informix".sp_sw_ro_ofiocioalta(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRecepcion CHAR(10), pFechaOficio CHAR(10), pIdTipoOficio INT, pOficio CHAR(60),
                pExpediente CHAR(60), pInstitucion1n INT, pInstitucion2n INT, pTipoOperacion INT, pIdOficio INT, pIp CHAR(15), pMac CHAR(12))
        RETURNING CHAR(5) AS cCodRet,
                INT AS numOficio
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNumOficio INT;
        DEFINE iExiste INT;
        DEFINE pFechaRecepcion1 DATE;
        DEFINE pFechaOficio1 DATE;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNumOficio = 0;
        LET iExiste = 0;
        LET pFechaRecepcion1='';
        LET pFechaOficio1='';
        
        BEGIN
                ON EXCEPTION SET iSqlErr
					IF iSqlErr <> 0 then
							LET cCodRet = iSqlErr;
							RETURN cCodRet, iNumOficio;
					END IF;
                END EXCEPTION;

                -- Validaciones
                if pIdUsuario = '' or pIdFuncion = '' or pFechaRecepcion = '' or pFechaOficio = '' or pIdTipoOficio = '' or
                        pOficio = '' or pExpediente = '' or pInstitucion1n = '' or pIp = '' or pMac = '' or pTipoOperacion = '' then
                        
                        let cCodRet = '00003';
                        return cCodRet, iNumOficio;
                end if;
                
                execute function bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) into cCodRet;
                if cCodRet <> '00000' then
                        return cCodRet, iNumOficio;
                end if;
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                if pTipoOperacion not in(1,2) then
                        let cCodRet = '00087';
                        return cCodRet, iNumOficio;
                end if;

                let pFechaRecepcion1 = EXTEND(MDY(SUBSTR(pFechaRecepcion,6,2),SUBSTR(pFechaRecepcion,9,2),SUBSTR(pFechaRecepcion,1,4)), YEAR TO SECOND);
                let pFechaOficio1 =  EXTEND(MDY(SUBSTR(pFechaOficio,6,2),SUBSTR(pFechaOficio,9,2),SUBSTR(pFechaOficio,1,4)), YEAR TO SECOND);
                
                if pTipoOperacion = 1 then
                        if pInstitucion2n = 0 then
                                let pInstitucion2n = null;
                        end if;
                
                        insert into sw_ro_maeoficios(
                                        fecha_recepcion, fecha_oficio, id_tipooficio, oficio,  expediente,  id_institucion1n, id_institucion2n, 
                                        user_insert, fecha_insert, ip_insert, mac_insert)
                        values(pFechaRecepcion1, pFechaOficio1, pIdTipoOficio, pOficio, pExpediente, pInstitucion1n, pInstitucion2n, pIdUsuario, current, pIp, pMac);
                        
                        let iNumOficio = dbinfo('sqlca.sqlerrd1');
                        return cCodRet, iNumOficio;
                elif pTipoOperacion = 2 then
                        if pIdOficio = '' then
                                let cCodRet = '00003';
                                return cCodRet, iNumOficio;
                        end if;
                        
                        select count(id_oficio) into iExiste from sw_ro_maeoficios where id_oficio = pIdOficio;
                        
                        if iExiste = 0 then
                                let cCodRet = '00001';
                                return cCodRet, iNumOficio;
                        end if;

                        if pInstitucion2n = 0 then
                                let pInstitucion2n = null;
                        end if;
                        
                        update sw_ro_maeoficios
                        set fecha_recepcion = pFechaRecepcion1,
                                fecha_oficio = pFechaOficio1,
                                id_tipooficio = pIdTipoOficio,
                                oficio = pOficio,
                                expediente = pExpediente,
                                id_institucion1n = pInstitucion1n,
                                id_institucion2n = pInstitucion2n,
                                user_update = pIdUsuario,
                                fecha_update = current,
                                ip_update = pIp,
                                mac_update = pMac
                        where id_oficio = pIdOficio;
                        
                        return cCodRet, pIdOficio;
                end if;         
        end;
end procedure
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/10/2014',
'DESCRIPCION: Se agrega el metodo para la actualiaciÃ³n de datos del oficio';

CREATE PROCEDURE "informix".sp_catalogodomiciliocte(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_domicilio,
			CHAR(20) AS desc_domicilio;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescripcion CHAR(20);
	DEFINE cIdDomicilio CHAR(2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescripcion = '';
	LET cIdDomicilio = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDomicilio, UPPER(cDescripcion);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogodomiciliocte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDomicilio, UPPER(cDescripcion);
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDomicilio, UPPER(cDescripcion);
		END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT id_domicilio, desc_domicilio
			INTO cIdDomicilio, cDescripcion 
			FROM bdicnweb:"informix".sw_domicilio_cliente
			ORDER BY id_domicilio ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cIdDomicilio, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdDomicilio, UPPER(TRIM(cDescripcion));
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Madrid Corona',
'FECHA: 09/08/2016',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MANTENIMIENTO DOMICILIOS CLIENTE',
'DESCRIPCION: SPL que se encarga de consultar el detalle del catálogo domicilio del cliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotipoclientescli(pIdUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING
	CHAR(5)			AS COD_RET,
	SMALLINT 		AS clave_tipo,
	CHAR(100)		As descripcion_corta;

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
	DEFINE iSamErr              INTEGER;
	DEFINE clave_tipo			SMALLINT;
	DEFINE descripcion_corta	CHAR(100);
	
	
	---INICIALIZACIONES
	LET v_cod_ret 					= '00000';	
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL,NULL;
        END IF;
	END EXCEPTION;

	
	--SET DEBUG FILE TO "/tmp/sp_ConsultarReportePagosSPL.out";
	--TRACE ON;
	
		IF pIdUsuario = '' OR pIdFuncion = '' THEN
			LET v_cod_ret = '00003';
			RETURN v_cod_ret,NULL,NULL;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT clavetipo, descripcioncorta INTO clave_tipo, descripcion_corta FROM bdinteg:"informix".si_catcterelacionado ORDER BY clavetipo ASC
		
			RETURN v_cod_ret,NVL(clave_tipo,""),NVL(descripcion_corta,"") WITH RESUME;
		END FOREACH;
		
		

END
END PROCEDURE
DOCUMENT
'AUTOR: Saùl Ortiz Baeza',
'DESCRIPCION: Procedimiento que obtiene los campos para crear el catalogo de tipo de cliente',
'FECHA: Octubre 2013',
'VERSION: 20100120.1701',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscatalogostatuslote(pIdUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(15) AS descripcion_status;
		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cStatus CHAR(1);
	DEFINE cDescripcion CHAR(15);
	DEFINE iSqlErr INT;
	
	LET cCodRet = '00000';
	LET cStatus = '';
	LET cDescripcion = '';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cDescripcion;
		END EXCEPTION;
		
		IF pIdUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;
		
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
		FOREACH SELECT {+INDEX(bdicnweb:sw_tr_statuslotes idx_sw_tr_statuslotes)} id_status, descripcion
			INTO cStatus, cDescripcion
			FROM bdicnweb:"informix".sw_tr_statuslotes
			
			RETURN cCodRet, cStatus, cDescripcion WITH RESUME;
			
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 11/07/2013",
"DESCRIPCION: Consulta los estatus de los lotes que se trabajan en las cargas masivas";

CREATE PROCEDURE "informix".sp_conslotesmasivo(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCarga DATE, pSistemaCuenta char(2), pNombreArchivo CHAR(150), pStatusLote CHAR(1),
			pPagina int, pRegistros int)
	RETURNING CHAR(5) AS codret,
			DATE AS fecha_carga,
			CHAR(150) AS nombre_archivo,
			CHAR(15) AS status_lote,
			INT AS lote;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE dFechaCarga DATE;
	DEFINE cArchivoCarga CHAR(150);
	DEFINE cStatusLote CHAR(15);
	DEFINE iLote INT;
	DEFINE cDynamicQuery char(1500);
	DEFINE iRows int;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaCarga = '';
	LET cArchivoCarga = '';
	LET cStatusLote = '';
	LET iLote = 0;
	LET cDynamicQuery = '';
	LET iRows = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		END EXCEPTION;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pPagina = '' OR pRegistros = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
		LET cDynamicQuery = "SELECT SKIP "||pPagina||" FIRST "||pRegistros
				||" fecha_carga, nombre_archivo, DECODE(status_lote, 'P', 'EN PROCESO', 'T', 'TERMINADO', 'C', 'CARGADO') AS status_proceso, id_lote FROM 'informix'.sw_tr_totales_masivo WHERE usuario = '"
				||TRIM(pIdUsuario)||"' AND sistema_cuenta = '"||pSistemaCuenta||"' AND id_funcion ='"||TRIM(pIdFuncion)||"'";
				
		IF pFechaCarga IS NOT NULL THEN
			LET cDynamicQuery = TRIM(cDynamicQuery)||" AND DATE(fecha_carga) = '"||pFechaCarga||"'";
		END IF;
		
		IF pStatusLote IS NOT NULL AND TRIM(pStatusLote) <> '' THEN
			LET cDynamicQuery = TRIM(cDynamicQuery)||" AND status_lote = '"||pStatusLote||"'";
		END IF;
		
		IF pNombreArchivo IS NOT NULL AND TRIM(pNombreArchivo) <> '' THEN
			LET cDynamicQuery = TRIM(cDynamicQuery)||" AND LOWER(nombre_archivo) LIKE '%"||TRIM(LOWER(pNombreArchivo))||"%'";
		END IF;
		
		LET cDynamicQuery = TRIM(cDynamicQuery)||' order by id_lote';
		
		PREPARE lotesQry FROM TRIM(cDynamicQuery);
		DECLARE lotesCur CURSOR FOR lotesQry;
		OPEN lotesCur;
		
		FETCH lotesCur INTO dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		
		WHILE(SQLCODE == 0)
			LET iRows = iRows + 1;
			RETURN cCodRet, dFechaCarga, cArchivoCarga, cStatusLote, iLote WITH RESUME;
			FETCH lotesCur INTO dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		END WHILE;
		
		CLOSE lotesCur;
		FREE lotesCur;
		FREE lotesQry;
		
		
		IF iRows = 0 THEN
			IF pPagina = 0 THEN
				LET cCodRet = '00017'; -- No se obtuvieron resultados
			ELSE
				LET cCodRet = '1001';
			END IF;
			RETURN cCodRet, dFechaCarga, cArchivoCarga, cStatusLote, iLote;
		END IF;
		
	END;
			
END PROCEDURE
DOCUMENT "Autor: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRICION: Consulta de lotes para las funcionalidades masivas";

CREATE PROCEDURE "informix".sp_consultareportedetallesolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5)     AS codret, 
		CHAR(20)      AS num_solicitud, 
		CHAR(4)       AS sucursal, 
		CHAR(100)  AS nombre_cte, 
		DATE          AS fecha_sol, 
		DATE          AS fecha_cambio,
		CHAR(2)       AS revaluada,
		CHAR(20)      AS referencia_coppel,
		DECIMAL(18,2) AS eficiencia_coppel,
		SMALLINT          AS meses_coppel,
		DECIMAL(18,2) AS vencido_coppel,
		INTEGER       AS vencido_coppeludis,
		CHAR(2)       AS puntualidad,
		INTEGER       AS scoring1,
		INTEGER       AS scoring2,
		CHAR(40)      AS desc_status,
		CHAR(3)       AS causa_solic,
		CHAR(100)  AS comentario,
		CHAR(45)      AS analista,
		CHAR(10)      AS tipo_movto,
		CHAR(50)      AS nombre_producto,
		DATETIME HOUR TO SECOND AS hora_inicio,
		DATETIME HOUR TO SECOND AS hora_fin;
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumSolicitud CHAR(20);     
	DEFINE cSucursal CHAR(4);      
	DEFINE vNombreCte CHAR(100); 
	DEFINE dFechaSol DATE;         
	DEFINE dFechaCambio     DATE;         
	DEFINE cRevaluada CHAR(2);      
	DEFINE cReferenciaCoppel CHAR(20);     
	DEFINE dcEficienciaCoppel DECIMAL(18,2);
	DEFINE sMesesCoppel     SMALLINT;        
	DEFINE dcVencidoCoppel DECIMAL(18,2);
	DEFINE iVencidoCoppeludis INTEGER;      
	DEFINE cPuntualidad CHAR(2);      
	DEFINE iScoring1        INTEGER;      
	DEFINE iScoring2 INTEGER;      
	DEFINE cDescStatus CHAR(40);     
	DEFINE cCausaSolic CHAR(3);      
	DEFINE vComentario CHAR(100); 
	DEFINE cAnalista CHAR(45);     
	DEFINE cTipoMovto CHAR(10);     
	DEFINE cNombreProducto CHAR(50);     
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dHoraInicio DATETIME HOUR TO SECOND;
	DEFINE dHoraFin DATETIME HOUR TO SECOND;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cNumSolicitud = '';     
	LET cSucursal = '';      
	LET vNombreCte = ''; 
	LET dFechaSol = NULL;
	LET dFechaCambio = NULL;         
	LET cRevaluada = '';      
	LET cReferenciaCoppel = '';     
	LET dcEficienciaCoppel = NULL;
	LET sMesesCoppel = 0;    
	LET dcVencidoCoppel = NULL;
	LET iVencidoCoppeludis = 0;      
	LET cPuntualidad = '';      
	LET iScoring1 = 0;      
	LET iScoring2 = 0;     
	LET cDescStatus = '';     
	LET cCausaSolic = '';      
	LET vComentario = '';
	LET cAnalista = '';     
	LET cTipoMovto = '';    
	LET cNombreProducto = '';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET dHoraInicio = NULL;
	LET dHoraFin = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareportedetallesolicitudmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		END IF;
		
		FOREACH 
		
			SELECT SKIP pRegistros FIRST pRecuperacion codret_sp, num_solicitud, sucursal, nombre_cte, fecha_sol, fecha_cambio, revaluada, 
			referencia_coppel, ceficiencia_coppel, meses_coppel, vencido_coppel, vencido_coppel_udis, puntualidad, scoring1, scoring2, 
			desc_status, causa_solic, comentario, analista, tipo_movto, nombre_producto, hora_inicio, hora_fin
			INTO cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis, cPuntualidad, iScoring1, iScoring2, 
			cDescStatus, cCausaSolic, vComentario, cAnalista, cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin
			FROM "informix".sw_reportesolicitudmc
			WHERE usuario = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin WITH RESUME;
						
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/03/2014',
'DESCRIPCION: Genera un reporte del detalle de todas las solicitudes de credito que fueron analizadas por Mesa de Control Estatus = MC',
'AUTOR: Oscar Flores Conde',
'FECHA: 11/01/2016',
'DESCRIPCION: Se agrega la hora de inicio de atención de la solicitud y la hora de finalización',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 07/09/2018',
'DESCRIPCION: Se implementa tratado de volumetría.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_determinalincredtccjunk(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSol  CHAR(20), pCteNvo CHAR(1))
    RETURNING CHAR(5) AS codret,
		 MONEY(14,2) AS linea_cred,
         MONEY(14,2) AS capacidad_de_pago,
         INTEGER AS plazo;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE mLineaCred MONEY(14,2);
	DEFINE mCapacidadPago MONEY(14,2);
    DEFINE iPlazo INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET mLineaCred = 0.00;
	LET mCapacidadPago = 0.00;
    LET iPlazo = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, mLineaCred, mCapacidadPago, iPlazo;
			END IF;
		END EXCEPTION;
		
				SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_determinalincredtccjunk.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mLineaCred, mCapacidadPago, iPlazo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mLineaCred, mCapacidadPago, iPlazo;
		END IF;
		

		
		EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(cEmpresa, pNumSol, pCteNvo)
		INTO cCodRetSp, mLineaCred, mCapacidadPago, iPlazo;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:determina_lincred_tc_cjunk';
		ELIF cCodRetSp::INTEGER = 10 THEN
			LET cCodRet = '01107'; --CAPACIDAD DE PAGO SATURADA, VERIFIQUE
		ELIF cCodRetSp::INTEGER IN (451,452,453,454,455,456,457,463,466,470) THEN 
			LET cCodRet = '01108'; --EXISTEN PARÁMETROS NULOS PARA LA DEFINICIÓN DE LA LÍNEA
		ELIF cCodRetSp::INTEGER = 473 THEN
			LET cCodRet = '01109'; --LA EDAD ES MENOR AL MÍNIMO REQUERIDO, VERIFIQUE
		ELIF cCodRetSp::INTEGER = 474 THEN
			LET cCodRet = '01110'; --OCURRIÓ UN ERROR AL EJECUTAR EL PROCEDIMIENTO: bdisolic:"informix"sp_proyecta_prestamos
		END IF;
		
		RETURN cCodRet, mLineaCred, mCapacidadPago, iPlazo;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 10/09/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mantto MC',
'Descripcion: SPL encargado de validar el producto de la solicitud del cliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_actinfosol(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pNumCliente CHAR(20), pNumClienteRef CHAR(20))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_actinfosol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_mc_actinfosol(cEmpresa,pNumSolicitud,pNumCliente,pNumClienteRef)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_mc_actinfosol';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de actualizar la información de la solicitud con la respuesta de la consulta a coppel mediante el servicio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_acttdcgarantizada(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumCredito CHAR(20), pNumCliente CHAR(20), pGarantizada CHAR(2), pLinCred DECIMAL(18,2),
pNumCuenta CHAR(20), pFechaAlta CHAR(10), pFechaBaja CHAR(10), pMotivoBaja CHAR(11), pTpMovto CHAR(1))
    RETURNING CHAR(5) AS codret;
		
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMotivo CHAR(11);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMotivo = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_acttdcgarantizada.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pTpMovto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_actualizar_info_tdc_garantizada(cEmpresa,pNumCredito,pNumCliente,pGarantizada,pLinCred,pNumCuenta,pFechaAlta,pFechaBaja,pMotivoBaja,pTpMovto)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_actualizar_info_tdc_garantizada';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: TARJETA DE CRÉDITO GARANTIZADA',
'DESCRIPCION: SPL encargado de actualizar la información general del cliente y los saldos del credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_actualizainfocac(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumSolicitud CHAR(50), pIngreso DECIMAL(18,2), pOtrosCompromisos DECIMAL(18,2), pComprobanteValido CHAR(1))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_actualizainfocac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		

		
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_info_cac(cEmpresa,pNumSolicitud,pIngreso,pOtrosCompromisos,pComprobanteValido)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_actualiza_info_cac';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de actualizar la informacion de la solicitud en revision de linea de credito con la informacion capturada por el analista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_buscasoliccac_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cMensajeRet     		CHAR(80);
	DEFINE cNumSolic       		CHAR(20);
	DEFINE cSucursal            CHAR(4);
	DEFINE cNombreCte      		CHAR(107);
	DEFINE cRfcCte         		CHAR(13);
	DEFINE cEjec_autoriza		CHAR(8);
	DEFINE dtFechSolic          DATE;
	DEFINE cTieneOS             CHAR(1);
	DEFINE cNomPdcto            CHAR(40) ;
	DEFINE dLinCalculada        DECIMAL(18,2);
	DEFINE cNomAnalista         CHAR(45);
	DEFINE cConsulta            CHAR(2) ;
	DEFINE cStatus              CHAR(2);
	DEFINE iNumPag           	INTEGER;
	define cEjec_Atde           CHAR(8);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cMensajeRet         = '';
	LET cNumSolic          	= '';
	LET cSucursal           = '';
	LET cNombreCte         	= '';
	LET cRfcCte            	= '';
	LET cEjec_autoriza      = '';
	LET dtFechSolic         = DATE(1);
	LET cTieneOS            = '';
	LET cNomPdcto           = '';
	LET dLinCalculada       = 0.00;
	LET cNomAnalista       	= '';
	LET cConsulta           = '';
	LET cStatus             = '';
	LET iNumPag             = 0;
	LET cEjec_Atde          = '';
	
    BEGIN
	
		
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_buscasoliccac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_buscasoliccac_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_buscasoliccac WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_buscasoliccac(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_buscasoliccac
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_buscasoliccac
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		DELETE FROM bdicnweb:"informix".sw_mc_buscasoliccac WHERE usuario = pUsuario;
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_busca_solicitudes_cac(cEmpresa, pNumSolicitud, pUsuario, '0', '3', '1')
			INTO cCodRetSp, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada, cNomAnalista, cConsulta, cEjec_Atde, iNumPag, cEjec_autoriza
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_busca_solicitudes_cac';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				UPDATE "informix".status_buscasoliccac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017'; 
				UPDATE "informix".status_buscasoliccac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01073'; 
				UPDATE "informix".status_buscasoliccac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO bdicnweb:"informix".sw_mc_buscasoliccac VALUES(cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada, cNomAnalista, cConsulta, cEjec_Atde, iNumPag, cEjec_autoriza, pUsuario);
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM bdicnweb:"informix".sw_mc_buscasoliccac WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".status_buscasoliccac
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_buscasoliccac
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario; 
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 23/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LINEAS SUPERORES',
'DESCRIPCION: SPL encargado de consultar el número total de registros del Monitor de Líneas Superiores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_catmotivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
        SMALLINT AS id_motivo,
		CHAR(50) AS desc_motivo;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdMotivo SMALLINT;
	DEFINE cDescMotivo CHAR(50);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iIdMotivo = 0;
	LET cDescMotivo = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iIdMotivo,cDescMotivo;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_catmotivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdMotivo,cDescMotivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdMotivo,cDescMotivo;
		END IF;

		
		
		FOREACH
			SELECT id_motivo,desc_motivo
			INTO iIdMotivo,cDescMotivo
			FROM "informix".sw_mc_motivocancelacion
			WHERE id_motivo IN(1,2)
			ORDER BY id_motivo ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iIdMotivo,cDescMotivo WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdMotivo,cDescMotivo;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: TARJETA DE CRÉDITO GARANTIZADA',
'DESCRIPCION: SPL encargado de consultar el catálogo motivo de cancelación.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_cattiporeporte(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
        SMALLINT AS id_reporte,
		CHAR(50) AS desc_reporte;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdReporte SMALLINT;
	DEFINE cDescReporte CHAR(50);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iIdReporte = 0;
	LET cDescReporte = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iIdReporte,cDescReporte;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_cattiporeporte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdReporte,cDescReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdReporte,cDescReporte;
		END IF;

		
		FOREACH
			SELECT id_reporte,desc_reporte
			INTO iIdReporte,cDescReporte
			FROM "informix".sw_mc_tiporeporte
			WHERE id_reporte IN(1,2,3,4,5)
			ORDER BY desc_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iIdReporte,cDescReporte WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdReporte,cDescReporte;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 22/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el catálogo tipo reporte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_conssolicitudaleatoria(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2), pEjecutivo CHAR(8), pEjecucion CHAR(1), 
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		CHAR(100) as nom_cliente, 
		CHAR(80) as nom_analista, 
		DATETIME HOUR TO SECOND AS hora;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNum_solicitud CHAR(20); 
	DEFINE cNum_cliente CHAR(20); 
	DEFINE cNom_cliente CHAR(100);
	DEFINE cNom_analista CHAR(80);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNum_solicitud = ''; 
	LET cNum_cliente = '';
	LET cNom_cliente = '';
	LET cNom_analista = '';
	LET dHora = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_conssolicitudaleatoria.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pEjecutivo = '' OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
		
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion num_solicitud, num_cliente, nom_cliente, nom_analista, hora
			INTO cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora
			FROM "informix".sw_mc_solicitudaleatoria
			WHERE usuario_insert = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 29/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE OPERACIÓN EN LÍNEA',
'Descripcion: SPL encargado de consultar los registros correspondientes al panel seleccionado.',
'Donde: pEjecucion = se refiere a Solicitudes Pendientes, pEjecucion = se refiere a Solicitudes En Atención, pEjecucion = se refiere a Solicitudes Analistas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_conssolicitudaleatoria_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2), pEjecutivo CHAR(8), pEjecucion CHAR(1))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cNum_solicitud CHAR(20); 
	DEFINE cNum_cliente CHAR(20); 
	DEFINE cNom_cliente CHAR(100);
	DEFINE cNom_analista CHAR(80);
	DEFINE dHora DATETIME HOUR TO SECOND;	
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cNum_solicitud = ''; 
	LET cNum_cliente = '';
	LET cNom_cliente = '';
	LET cNom_analista = '';
	LET dHora = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_conssolicitudaleatoria_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pEjecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		
		
		DELETE FROM "informix".sw_mc_solicitudaleatoria WHERE usuario_insert = pUsuario AND fecha_insert < DATE(CURRENT);
		DELETE FROM "informix".sw_mc_solicitudaleatoria WHERE usuario_insert = pUsuario;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_asigna_solicitudaleatoria_mc(cEmpresa,pStatus,pEjecutivo,pEjecucion)
			INTO cCodRetSp, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_asigna_solicitudaleatoria_mc';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iNumRegistros;
			--ELIF cCodRetSp::INTEGER = 2 THEN
			ELIF cCodRetSp::INTEGER = 2 AND pEjecucion = 1 THEN
				LET cCodRet = '01105'; --NO EXISTEN SOLICITUDES CON ESTATUS PENDIENTE POR MOSTRAR
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 AND pEjecucion IN (2) THEN
				LET cCodRet = '01106'; --NO EXISTEN SOLICITUDES CON ESTATUS EN ATENCIÓN POR MOSTRAR
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 AND pEjecucion IN (4) THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO "informix".sw_mc_solicitudaleatoria VALUES(cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora, pUsuario, DATE(CURRENT));
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_solicitudaleatoria WHERE usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 29/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE OPERACIÓN EN LÍNEA',
'Descripcion: SPL encargado de consultar el número total de registros correspondientes al panel seleccionado.',
'Donde: pEjecucion = se refiere a Solicitudes Pendientes, pEjecucion = se refiere a Solicitudes En Atención, pEjecucion = se refiere a Solicitudes Analistas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_constdcgarantizada(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_credito,
		CHAR(20) AS num_cliente,
		CHAR(107) AS nombre_cliente,
		CHAR(10) AS fecha_solicitud,
		CHAR(2) AS garantizada,
		DECIMAL(18,2) AS linea_credito,
		CHAR(20) AS num_cuenta,
		CHAR(10) AS fecha_alta,
		CHAR(10) AS fecha_baja,
		CHAR(11) AS motivo_baja;
		
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombreCte CHAR(107);
	DEFINE dFechaSol CHAR(10);
	DEFINE cGarantizada CHAR(2);
	DEFINE dLineaCredito DECIMAL(18,2);
	DEFINE cNumCta CHAR(20);
	DEFINE dFechaAlta CHAR(10);
	DEFINE dFechaBaja CHAR(10);
	DEFINE cMotivoBaja CHAR(11);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCredito = '';
	LET cNumcte = '';
	LET cNombreCte = '';
	LET dFechaSol = '';
	LET cGarantizada = '';
	LET dLineaCredito = 0.00;
	LET cNumCta = '';
	LET dFechaAlta = '';
	LET dFechaBaja = '';
	LET cMotivoBaja = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumCredito,cNumcte,cNombreCte,dFechaSol,cGarantizada,dLineaCredito,cNumCta,dFechaAlta,dFechaBaja,cMotivoBaja;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_constdcgarantizada.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCredito,cNumcte,cNombreCte,dFechaSol,cGarantizada,dLineaCredito,cNumCta,dFechaAlta,dFechaBaja,cMotivoBaja;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCredito,cNumcte,cNombreCte,dFechaSol,cGarantizada,dLineaCredito,cNumCta,dFechaAlta,dFechaBaja,cMotivoBaja;
		END IF;
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consultar_info_tdc_garantizada(cEmpresa,pNumCredito)
		INTO cCodRetSp,cDescCodRetSp,cNumCredito,cNumcte,cNombreCte,dFechaSol,cGarantizada,dLineaCredito,cNumCta,dFechaAlta,dFechaBaja,cMotivoBaja;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_consultar_info_tdc_garantizada';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,cNumCredito,cNumcte,cNombreCte,dFechaSol,cGarantizada,dLineaCredito,cNumCta,dFechaAlta,dFechaBaja,cMotivoBaja;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: TARJETA DE CRÉDITO GARANTIZADA',
'DESCRIPCION: SPL encargado de consultar la información general del cliente y los saldos del credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_consultaperfilusuariomc(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING
        CHAR(5) AS COD_RET,
        CHAR(15) AS DESCRIPCION; 
    
	---DECLARACIONES
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensajeRet  CHAR(15);
	DEFINE cEstatus  	CHAR(8);
	DEFINE cEjecutivo  	CHAR(10);
    ---INICIALIZACIONES
    LET iSqlErr       = 0;
    LET iIsamErr      = 0;
    LET cCodRet       = '00000';
    LET cMensajeRet   = 'Proceso Exitoso';
	LET cEstatus	  = '';
	LET cEjecutivo	  = '';
BEGIN

   ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet, cMensajeRet;
	END EXCEPTION;
	
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/tmp/mfinis/sp_mc_consultaperfilusuariomc.out";
	---TRACE ON;
	
    IF pUsuario = '' OR pIdFuncion = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet, cMensajeRet;
	END IF;   
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, cMensajeRet;
	END IF;
	
	
    SELECT ejecutivo INTO cEjecutivo 	
	FROM bdisolic:"informix".ss_analistaenatencion WHERE ejecutivo = pUsuario;
	
	IF cEjecutivo = '' OR cEjecutivo IS NULL THEN
		LET cMensajeRet = 'ADMINISTRATIVO';
	ELSE
		LET cMensajeRet = 'OPERADOR';
	END IF;
	RETURN cCodRet, cMensajeRet;
END

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 01/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: Consulta si el Ejecutivo es Analista en la Mesa de Control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_consultasolicitudescac(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20))
    RETURNING CHAR(5) AS codret,
		CHAR(20) 		AS cuenta,
		CHAR(20) 		AS cNumCte,
		CHAR(107) 	AS cNombreCte,
		CHAR(13) 		AS cRfcCte,
		CHAR(6) 		AS cAntecBC,
		DECIMAL(18,2) AS deCompMensBC,
		CHAR(6) 		AS cAntecCC,
		DECIMAL(18,2) AS deCompMensCC,
		CHAR(20) 		AS cNumCteCop,
		SMALLINT 		AS smAntiguedad,
		CHAR(2)  		AS cPuntualidad,
		DECIMAL(18,2) AS deEficPago,
		DECIMAL(18,2) AS deAbonMensual,
		DECIMAL(18,2) AS deIngresoMen,
		DECIMAL(18,2) AS deMontoSolic,
		CHAR(300) 	AS Observaciones,
		DECIMAL(18,2) AS deCompromisos_cac,
		CHAR(1) 		AS cComprobante_val,
		CHAR(20) 		AS cFecha_insert,		  
		DECIMAL(18,2) AS deMontoSolic2,
		DECIMAL(18,2) AS deIngresoValMC,
		DECIMAL(18,2) AS deLineaCoppel,
		DECIMAL(18,2) AS dePagoMensBco;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumSolic CHAR(20);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombreCte CHAR(107);
	DEFINE cRfcCte CHAR(13);
	DEFINE cAntecBC CHAR(6);
	DEFINE deCompMensBC DECIMAL(18,2);
	DEFINE cAntecCC CHAR(6);
	DEFINE deCompMensCC DECIMAL(18,2);
	DEFINE cNumCteCop CHAR(20);
	DEFINE smAntiguedad SMALLINT;
	DEFINE cPuntualidad CHAR(2);
	DEFINE deEficPago DECIMAL(18,2);
	DEFINE deAbonMensual DECIMAL(18,2);
	DEFINE deIngresoMen DECIMAL(18,2);
	DEFINE deMontoSolic DECIMAL(18,2);
	DEFINE cObservaciones CHAR(300);
	DEFINE deCompromisos_cac DECIMAL(18,2);
	DEFINE cComprobante_val CHAR(1);
	DEFINE cFecha_insert CHAR(10);
	DEFINE deMontoSolic2 DECIMAL(18,2);
	DEFINE deIngresoValMC DECIMAL(18,2);
	DEFINE dLineaCop DECIMAL(18,2);
	DEFINE dPagoMensBco DECIMAL(18,2);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumSolic = '';
	LET cNumCte = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cAntecBC = '';
	LET deCompMensBC = 0.00;
	LET cAntecCC = '';
	LET deCompMensCC = 0.00;
	LET cNumCteCop = '';
	LET smAntiguedad = 0;
	LET cPuntualidad = '';
	LET deEficPago = 0.00;
	LET deAbonMensual = 0.00;
	LET deIngresoMen = 0.00;
	LET deMontoSolic = 0.00;
	LET cObservaciones = '';
	LET deCompromisos_cac = 0.00;
	LET cComprobante_val = '';
	LET cFecha_insert = '';
	LET deMontoSolic2 = 0.00;
	LET deIngresoValMC = 0.00;
	LET dLineaCop = 0.00;
	LET dPagoMensBco = 0.00;
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumSolic,cNumCte,cNombreCte,cRfcCte,cAntecBC,deCompMensBC,
				cAntecCC,deCompMensCC,cNumCteCop,smAntiguedad,cPuntualidad,deEficPago,
				deAbonMensual,deIngresoMen,deMontoSolic,cObservaciones,deCompromisos_cac,
				cComprobante_val,cFecha_insert,deMontoSolic2,deIngresoValMC,dLineaCop,dPagoMensBco;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_consultasolicitudescac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumSolic,cNumCte,cNombreCte,cRfcCte,cAntecBC,deCompMensBC,
			cAntecCC,deCompMensCC,cNumCteCop,smAntiguedad,cPuntualidad,deEficPago,
			deAbonMensual,deIngresoMen,deMontoSolic,cObservaciones,deCompromisos_cac,
			cComprobante_val,cFecha_insert,deMontoSolic2,deIngresoValMC,dLineaCop,dPagoMensBco;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumSolic,cNumCte,cNombreCte,cRfcCte,cAntecBC,deCompMensBC,
			cAntecCC,deCompMensCC,cNumCteCop,smAntiguedad,cPuntualidad,deEficPago,
			deAbonMensual,deIngresoMen,deMontoSolic,cObservaciones,deCompromisos_cac,
			cComprobante_val,cFecha_insert,deMontoSolic2,deIngresoValMC,dLineaCop,dPagoMensBco;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_consulta_solicitudes_cac(cEmpresa,pNumSolicitud)
		INTO cCodRetSp,cDescCodRetSp,cNumSolic,cNumCte,cNombreCte,cRfcCte,cAntecBC,deCompMensBC,
		cAntecCC,deCompMensCC,cNumCteCop,smAntiguedad,cPuntualidad,deEficPago,
		deAbonMensual,deIngresoMen,deMontoSolic,cObservaciones,deCompromisos_cac,
		cComprobante_val,cFecha_insert,deMontoSolic2,deIngresoValMC,dLineaCop,dPagoMensBco;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_consulta_solicitudes_cac';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '01074'; --EMPRESA NO VÁLIDA, VERIFIQUE
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '00411'; --LA SOLICITUD NO EXISTE O ES INCORRECTA, FAVOR DE VERIFICAR E INTENTAR NUEVAMENTE
		END IF;
		
		RETURN cCodRet,cNumSolic,cNumCte,cNombreCte,cRfcCte,cAntecBC,deCompMensBC,
		cAntecCC,deCompMensCC,cNumCteCop,smAntiguedad,cPuntualidad,deEficPago,
		deAbonMensual,deIngresoMen,deMontoSolic,cObservaciones,deCompromisos_cac,
		cComprobante_val,cFecha_insert,deMontoSolic2,deIngresoValMC,dLineaCop,dPagoMensBco;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de consultar la información de la solicitud de crédito CAC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_marcagrabatdcoro(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoEjecucion CHAR(1), pNvaLinea DECIMAL(18,2), pNumSolCred CHAR(20))
    RETURNING CHAR(5) AS codret,
		DECIMAL(18,2) AS nueva_linea,
		CHAR(20) AS num_sol_cred;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dNuevaLinea DECIMAL(18,2);
	DEFINE cNumSolCred CHAR(20);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET dNuevaLinea = 0.00;
	LET cNumSolCred = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,dNuevaLinea,cNumSolCred;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_marcagrabatdcoro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' OR pNvaLinea = '' OR pNumSolCred = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dNuevaLinea,cNumSolCred;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dNuevaLinea,cNumSolCred;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_marcagraba_tdc_oro(cEmpresa,pTipoEjecucion,pNvaLinea,pNumSolCred)
		INTO cCodRetSp,dNuevaLinea,cNumSolCred;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_marcagraba_tdc_oro';
		ELIF cCodRetSp IN ('000001','000002','000003') THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp = '0001' THEN
			LET cCodRet = '01091'; --LA SOLICITUD NO FUE GRABADA COMO PRE-CALIFICADA 
		END IF;
		
		RETURN cCodRet,dNuevaLinea,cNumSolCred;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de: opción 1 para determinar si el cliente es candidato para una TDC Oro',
'y opción 2 para clonar la información de la solicitud TDC clasica a un producto(8100).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reestablecersolicitudcac(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivo CHAR(8))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reestablecersolicitudcac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_reestablecer_solicitud_cac(cEmpresa,pNumSolicitud,pEjecutivo)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_reestablecer_solicitud_cac';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de restablecer la solicitud cuando el analista no realice afectaciones en la solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_registrasolrevisioncac(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivo CHAR(8))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_registrasolrevisioncac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_registra_sol_revision_cac(cEmpresa,pNumSolicitud,pEjecutivo)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_registra_sol_revision_cac';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '01089'; --LA SOLICITUD YA FUE ATENDIDA
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '01090'; --LA SOLICITUD ESTÁ SIENDO ATENDIDA
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de realizar la consulta para informar si existen o no solicitudes de CAC pendientes por atender.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacanalista(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(80) AS descripcion,
		CHAR(8) AS num_empleado ,
		CHAR(45) AS nom_empleado,
		INTEGER AS num_atendidas,
		DECIMAL(5,2) AS porc_atendidas,
		INTEGER AS num_compingval,
		DECIMAL(5,2) AS porc_compingval,
		INTEGER AS num_compingnoval,
		DECIMAL(5,2) AS porc_compingnoval,
		DECIMAL(18,2) AS lincredprom;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(80);
	DEFINE cNum_empleado CHAR(8);
    DEFINE cNom_empleado CHAR(45);
    DEFINE iNum_atendidas INTEGER;
    DEFINE dPorc_atendidas DECIMAL(5,2);
    DEFINE iNum_compingval INTEGER;
    DEFINE dPorc_compingval DECIMAL(5,2);
    DEFINE iNum_compingnoval INTEGER;
    DEFINE dPorc_compingnoval DECIMAL(5,2);
	DEFINE dLincredprom DECIMAL(18,2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
	LET cNum_empleado = '';
    LET cNom_empleado = '';
    LET iNum_atendidas = 0;
    LET dPorc_atendidas = 0.00;
    LET iNum_compingval = 0;
    LET dPorc_compingval = 0.00;
    LET iNum_compingnoval = 0;
    LET dPorc_compingnoval = 0.00;
	LET dLincredprom = 0.00;

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacanalista.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
		END IF;
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion descripcion, num_empleado, nom_empleado, num_atendidas, porc_atendidas, num_compingval, porc_compingval, num_compingnoval, porc_compingnoval, lincredprom
				INTO cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom
			    FROM "informix".sw_mc_rep_cac_analista
				WHERE usuario = pUsuario
				
				LET iRecuperacion = iRecuperacion + 1;
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					TRIM(UPPER(NVL(cDescripcion, ''))),
			        TRIM(UPPER(NVL(cNum_empleado, ''))), 
					TRIM(UPPER(NVL(cNom_empleado, ''))), 
					NVL(iNum_atendidas, 0),
					NVL(dPorc_atendidas, 0.00),
					NVL(iNum_compingval, 0),
					NVL(dPorc_compingval, 0.00), 
					NVL(iNum_compingnoval, 0),
					NVL(dPorc_compingnoval, 0.00),
                    NVL(dLincredprom, 0.00)
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 21/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar los registros del reporte por analista de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacanalista_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cDescripcion CHAR(80);
	DEFINE cNum_empleado CHAR(8);
    DEFINE cNom_empleado CHAR(45);
    DEFINE iNum_atendidas INTEGER;
    DEFINE dPorc_atendidas DECIMAL(5,2);
    DEFINE iNum_compingval INTEGER;
    DEFINE dPorc_compingval DECIMAL(5,2);
    DEFINE iNum_compingnoval INTEGER;
    DEFINE dPorc_compingnoval DECIMAL(5,2);
	DEFINE dLincredprom DECIMAL(18,2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cDescripcion = '';
	LET cNum_empleado = '';
    LET cNom_empleado = '';
    LET iNum_atendidas = 0;
    LET dPorc_atendidas = 0.00;
    LET iNum_compingval = 0;
    LET dPorc_compingval = 0.00;
    LET iNum_compingnoval = 0;
    LET dPorc_compingnoval = 0.00;
	LET dLincredprom = 0.00;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_rep_analista
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacanalista_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_analista WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_analista(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_rep_analista
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_rep_analista
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		
		
		DELETE FROM "informix".sw_mc_rep_cac_analista WHERE usuario = pUsuario;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_analista(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:sp_reporte_cac_analista';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				UPDATE "informix".status_rep_analista
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154';
				UPDATE "informix".status_rep_analista
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
				UPDATE "informix".status_rep_analista
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO "informix".sw_mc_rep_cac_analista VALUES(cDescripcion, cNum_empleado, cNom_empleado, iNum_atendidas, dPorc_atendidas, iNum_compingval, dPorc_compingval, iNum_compingnoval, dPorc_compingnoval, dLincredprom, pUsuario);
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_analista WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			UPDATE "informix".status_rep_analista
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_rep_analista
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;  
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar el número total de registros del reporte analista de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecaccompingreso(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(80) AS descripcion,
		CHAR(4) AS cod_docto,
		CHAR(50) AS descripcion_grupo,
		INTEGER AS numero_doctos,
		DECIMAL(5,2) AS porcentaje_total_grupos,
		INTEGER AS validos_grupo,
		DECIMAL(5,2) AS porcentaje_validos_grupo,
		INTEGER AS invalidos_grupo,
		DECIMAL(5,2) AS porcentaje_invalidos_grupo,
		DECIMAL(5,2) AS porcentaje_final_grupo,
		INTEGER AS indice_grupo; 
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescripcion CHAR(80);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDescripcion_grupo CHAR(50);	
	DEFINE iNumero_doctos INTEGER;
	DEFINE dPorcentaje_total_grupos DECIMAL(5,2);
	DEFINE iValidos_grupo INTEGER;
	DEFINE dPorcentaje_validos_grupo DECIMAL(5,2);
	DEFINE iInvalidos_grupo INTEGER;
	DEFINE dPorcentaje_invalidos_grupo DECIMAL(5,2);
	DEFINE dPorcentaje_final_grupo DECIMAL(5,2);
	DEFINE iIndice_grupo INTEGER;
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cDescripcion = '';
	LET cCod_docto = '';
	LET cDescripcion_grupo = '';	
	LET iNumero_doctos = 0;
	LET dPorcentaje_total_grupos = 0.00;
	LET iValidos_grupo = 0;
	LET dPorcentaje_validos_grupo = 0.00;
	LET iInvalidos_grupo = 0;
	LET dPorcentaje_invalidos_grupo = 0.00;
	LET dPorcentaje_final_grupo = 0.00;
	LET iIndice_grupo = 0;
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecaccompingreso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
		END IF;
		
		
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion descripcion, cod_docto, descripcion_grupo, numero_doctos, porcentaje_total_grupos, validos_grupo, porcentaje_validos_grupo, invalidos_grupo, porcentaje_invalidos_grupo, porcentaje_final_grupo, indice_grupo
			INTO cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo
			FROM "informix".sw_mc_rep_cac_compingreso
			WHERE usuario = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'Descripcion: SPL encargado de consultar los registros del reporte comprobante de ingresos de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacdetallado(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(80) AS descripcion,
		CHAR(10) AS fecha_autorizacion,
        CHAR(20) AS num_solicitud,
        CHAR(4) AS num_sucursal,
        CHAR(20) AS num_cliente,
        CHAR(104) AS nombre_cte,
        CHAR(2) AS comp_ingreso_valido,
        CHAR(1) AS grupo_cte,
        DECIMAL(20,2) AS ingreso_declarado,
        DECIMAL(20,2) AS compromisos_sic,
        DECIMAL(20,2) AS compromisos_bco,
        DECIMAL(20,2) AS compromisos_cop,
        DECIMAL(20,2) AS linea_coppel,
        DECIMAL(20,2) AS linea_sug,
        DECIMAL(20,2) AS ingreso_valido_mc,
        DECIMAL(20,2) AS linea_sug_mc,
        CHAR(20) AS status_final,
        CHAR(45) AS analista_cac_atend,
        CHAR(300) AS observaciones; 
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescripcion CHAR(80);
	DEFINE cFecha_autorizacion CHAR(10);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_sucursal CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNombre_cte CHAR(104);
	DEFINE cComp_ingreso_valido CHAR(2);
	DEFINE cGrupo_cte CHAR(1);
	DEFINE dIngreso_declarado DECIMAL(20,2);
	DEFINE dCompromisos_sic DECIMAL(20,2);
	DEFINE dCompromisos_bco DECIMAL(20,2);
	DEFINE dCompromisos_cop DECIMAL(20,2);
	DEFINE dLinea_coppel DECIMAL(20,2);
	DEFINE dLinea_sug DECIMAL(20,2);
	DEFINE dIngreso_valido_mc DECIMAL(20,2);
	DEFINE dLinea_sug_mc DECIMAL(20,2);
	DEFINE cStatus_final CHAR(20);
	DEFINE cAnalista_cac_atend CHAR(45);
	DEFINE cObservaciones CHAR(300);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cDescripcion = '';
	LET cFecha_autorizacion = '';
	LET cNum_solicitud = '';
	LET cNum_sucursal = '';
	LET cNum_cliente = '';
	LET cNombre_cte = '';
	LET cComp_ingreso_valido = '';
	LET cGrupo_cte = '';
	LET dIngreso_declarado = 0.00;
	LET dCompromisos_sic = 0.00;
	LET dCompromisos_bco = 0.00;
	LET dCompromisos_cop = 0.00;
	LET dLinea_coppel = 0.00;
	LET dLinea_sug = 0.00;
	LET dIngreso_valido_mc = 0.00;
	LET dLinea_sug_mc = 0.00;
	LET cStatus_final = '';
	LET cAnalista_cac_atend = '';
	LET cObservaciones = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
				dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacdetallado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
		END IF;
		
		
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion descripcion, fecha_autorizacion, num_solicitud, num_sucursal, num_cliente, nombre_cte, comp_ingreso_valido, grupo_cte, 
			ingreso_declarado, compromisos_sic, compromisos_bco, compromisos_cop, linea_coppel, linea_sug, ingreso_valido_mc, linea_sug_mc, status_final, analista_cac_atend, observaciones
			INTO cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones
			FROM "informix".sw_mc_rep_cac_detallado
			WHERE usuario = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'Descripcion: SPL encargado de consultar los registros del reporte detallado de las solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacgeneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(80) AS descripcion,
		CHAR(50) AS estado_sol,
		INTEGER AS total_casos,
		DECIMAL(5,2) AS porc_tot_casos,
		INTEGER AS grupo1,
		DECIMAL(5,2) AS porc_grupo1,
		INTEGER AS grupo2,
		DECIMAL(5,2) AS porc_grupo2,
		INTEGER AS grupo3,
		DECIMAL(5,2) AS porc_grupo3; 
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cdescripcion CHAR(80);
	DEFINE cestadoSol  CHAR(50);	
	DEFINE itotalCasos INTEGER;
	DEFINE dporcTotCasos DECIMAL(5,2);
	DEFINE igrupo1 INTEGER;
	DEFINE dporcGrupo1 DECIMAL(5,2);
	DEFINE iGrupo2 INTEGER;
	DEFINE dporcGrupo2 DECIMAL(5,2);
	DEFINE iGrupo3 INTEGER;
	DEFINE dporcGrupo3 DECIMAL(5,2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cdescripcion = '';
	LET cestadoSol = '';
	LET itotalCasos = 0;
	LET dporcTotCasos = 0.00;
	LET igrupo1 = 0;
	LET dporcGrupo1 = 0.00;
	LET iGrupo2 = 0;
	LET dporcGrupo2 = 0.00;
	LET iGrupo3  = 0;
	LET dporcGrupo3 = 0.00;

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacgeneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion descripcion, estado_sol,	total_casos, porc_tot_casos, grupo1, porc_grupo1, grupo2, porc_grupo2, grupo3, porc_grupo3 
				INTO cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3
			    FROM "informix".sw_mc_rep_cac_general
				WHERE usuario = pUsuario
				
				LET iRecuperacion = iRecuperacion + 1;
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					TRIM(UPPER(NVL(cdescripcion, ''))),
			        TRIM(UPPER(NVL(cestadoSol, ''))), 
					NVL(itotalCasos, 0),
					NVL(dporcTotCasos, 0.00),
					NVL(igrupo1, 0),
					NVL(dporcGrupo1, 0.00), 
					NVL(iGrupo2, 0),
					NVL(dporcGrupo2, 0.00),
					NVL(iGrupo3, 0),
                    NVL(dporcGrupo3, 0.00)
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar los registros del reporte general de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacgeneral_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cdescripcion CHAR(80);
	DEFINE cestadoSol  CHAR(50);	
	DEFINE itotalCasos INTEGER;
	DEFINE dporcTotCasos DECIMAL(5,2);
	DEFINE igrupo1 INTEGER;
	DEFINE dporcGrupo1 DECIMAL(5,2);
	DEFINE iGrupo2 INTEGER;
	DEFINE dporcGrupo2 DECIMAL(5,2);
	DEFINE iGrupo3 INTEGER;
	DEFINE dporcGrupo3 DECIMAL(5,2); 
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cdescripcion = '';
	LET cestadoSol = '';
	LET itotalCasos = 0;
	LET dporcTotCasos = 0.00;
	LET igrupo1 = 0;
	LET dporcGrupo1 = 0.00;
	LET iGrupo2 = 0;
	LET dporcGrupo2 = 0.00;
	LET iGrupo3  = 0;
	LET dporcGrupo3 = 0.00;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_rep_general
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacgeneral_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_general WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_general(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_rep_general
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_rep_general
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		
		
		DELETE FROM "informix".sw_mc_rep_cac_general WHERE usuario = pUsuario;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_general(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2, dporcGrupo2, iGrupo3, dporcGrupo3
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_reporte_cac_general';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				UPDATE "informix".status_rep_general
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154'; 
				UPDATE "informix".status_rep_general
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
				UPDATE "informix".status_rep_general
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO "informix".sw_mc_rep_cac_general VALUES(cdescripcion, cestadoSol, itotalCasos, dporcTotCasos, igrupo1, dporcGrupo1, iGrupo2,  dporcGrupo2, iGrupo3, dporcGrupo3, pUsuario);
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_general WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			UPDATE "informix".status_rep_general
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_rep_general
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;  
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 16/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar el número total de registros del reporte general de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecaclineacred(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(80) AS descripcion,
		CHAR(50) AS estado_sol,
		INTEGER AS grupo1,
		DECIMAL(18,2) AS linprom_grupo1,
		INTEGER AS grupo2,
		DECIMAL(18,2) AS linprom_grupo2,
		INTEGER AS grupo3,
		DECIMAL(18,2) AS linprom_grupo3,
		INTEGER AS lineas_totales,
		DECIMAL(18,2) AS linprom_total,
		DECIMAL(18,2) AS monto_totasig; 
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(80);
	DEFINE cEstadoSol CHAR(50);
	DEFINE iGrupo1 INTEGER;
	DEFINE dLinpromGrupo1 DECIMAL(18,2);
	DEFINE iGrupo2 INTEGER;
	DEFINE dLinpromGrupo2 DECIMAL(18,2);
	DEFINE iGrupo3 INTEGER;
	DEFINE dLinpromGrupo3 DECIMAL(18,2);
	DEFINE iLineasTotales INTEGER;
	DEFINE dLinpromTotal DECIMAL(18,2);
	DEFINE dMontoTotAsig DECIMAL(18,2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
	LET cEstadoSol = '';
	LET iGrupo1 = 0;
	LET dLinpromGrupo1 = 0.00;
	LET iGrupo2 = 0;
	LET dLinpromGrupo2 = 0.00;
	LET iGrupo3 = 0;
	LET dLinpromGrupo3 = 0.00;
	LET iLineasTotales = 0;
	LET dLinpromTotal = 0.00;
	LET dMontoTotAsig = 0.00;

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecaclineacred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion descripcion, estado_sol, grupo1, linprom_grupo1, grupo2, linprom_grupo2, grupo3, linprom_grupo3, lineas_totales, linprom_total, monto_totasig
				INTO cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig
			    FROM "informix".sw_mc_rep_cac_lincred
				WHERE usuario = pUsuario
				
				LET iRecuperacion = iRecuperacion + 1;
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					TRIM(UPPER(NVL(cDescripcion, ''))),
			        TRIM(UPPER(NVL(cEstadoSol, ''))), 
					NVL(iGrupo1, 0),
					NVL(dLinpromGrupo1, 0.00),
					NVL(iGrupo2, 0),
					NVL(dLinpromGrupo2, 0.00),
					NVL(iGrupo3, 0),
                    NVL(dLinpromGrupo3, 0.00),
					NVL(iLineasTotales, 0),
                    NVL(dLinpromTotal, 0.00),
                    NVL(dMontoTotAsig, 0.00)
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDescripcion, cEstadoSol, iGrupo1, dLinpromGrupo1, iGrupo2, dLinpromGrupo2, iGrupo3, dLinpromGrupo3, iLineasTotales, dLinpromTotal, dMontoTotAsig;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 20/08/2018',
'MODULO: CRÉITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar los registros del reporte de linea de credito de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecaclineacred_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cdescripcion CHAR(80);
	DEFINE cestado_sol CHAR(50);
	DEFINE igrupo1 INTEGER;
	DEFINE dlinprom_grupo1 DECIMAL(18,2);
	DEFINE igrupo2 INTEGER;
	DEFINE dlinprom_grupo2 DECIMAL(18,2);
	DEFINE igrupo3 INTEGER;
	DEFINE dlinprom_grupo3 DECIMAL(18,2);
	DEFINE ilineas_totales INTEGER;
	DEFINE dlinprom_total DECIMAL(18,2);
	DEFINE dmonto_totasig DECIMAL(18,2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cdescripcion = '';
	LET cestado_sol = '';
	LET igrupo1 = 0;
	LET dlinprom_grupo1 = 0.00;
	LET igrupo2 = 0;
	LET dlinprom_grupo2 = 0.00;
	LET igrupo3 = 0;
	LET dlinprom_grupo3 = 0.00;
	LET ilineas_totales = 0;
	LET dlinprom_total = 0.00;
	LET dmonto_totasig = 0.00;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_rep_lincred
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecaclineacred_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_lincred WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_lincred(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_rep_lincred
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_rep_lincred
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		
		
		DELETE FROM "informix".sw_mc_rep_cac_lincred WHERE usuario = pUsuario;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_lineacredito(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cdescripcion, cestado_sol, igrupo1, dlinprom_grupo1, igrupo2, dlinprom_grupo2, igrupo3, dlinprom_grupo3, ilineas_totales, dlinprom_total, dmonto_totasig
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_reporte_cac_lineacredito';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				UPDATE "informix".status_rep_lincred
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154'; 
				UPDATE "informix".status_rep_lincred
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE 
				UPDATE "informix".status_rep_lincred
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO "informix".sw_mc_rep_cac_lincred VALUES(cdescripcion, cestado_sol, igrupo1, dlinprom_grupo1, igrupo2, dlinprom_grupo2, igrupo3, dlinprom_grupo3, ilineas_totales, dlinprom_total, dmonto_totasig, pUsuario);
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_lincred WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			UPDATE "informix".status_rep_lincred
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
		END IF;
		
		UPDATE "informix".status_rep_lincred
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario; 
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 20/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'Descripcion: SPL encargado de consultar el número total de registros del reporte linea de credito de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusbuscasoliccac(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusbuscasoliccac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_buscasoliccac WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/09/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LINEAS SUPERORES',
'DESCRIPCION: SPL encargado verificar el status de la consulta del Monitor de Líneas Superiores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepanalista(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepanalista.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_analista WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte analista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepcompingreso(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepcompingreso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_compingreso WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte comprobante de ingresos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepdetallado(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepdetallado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_detallado WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte detallado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepgeneral(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepgeneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_general WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte general.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusreplincred(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusreplincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_lincred WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte linea de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_combostatusmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(2) AS id,
		CHAR(50) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cId CHAR(2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
    LET cId = '';

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cId, cDescripcion;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_combostatusmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion id, descripcion 
				INTO   cId, cDescripcion 
			    FROM   bdicnweb:"informix".sw_mc_combostatus
				WHERE id in ('AT','EE','CM','RT')
				
				LET iRecuperacion = iRecuperacion + 1;
                   
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					TRIM(UPPER(NVL(cId, ''))), 
			        TRIM(UPPER(NVL(cDescripcion, '')))
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01086';
			RETURN cCodRet, cId, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTES MESA CONTROL',
'Descripcion: SPL encargado de consultar los registros para el llenado del combo de status Solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_gralsino(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		SMALLINT AS id,
		CHAR(50) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE sId SMALLINT;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
    LET sId = 0;

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sId, cDescripcion;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_gralsino.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion id, descripcion 
				INTO   sId, cDescripcion 
			    FROM   bdicnweb:"informix".sw_gral_sino
				WHERE id in(1,2)
				
				LET iRecuperacion = iRecuperacion + 1;
                   
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					NVL(sId, 0),
			        TRIM(UPPER(NVL(cDescripcion, '')))
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01086';
			RETURN cCodRet, sId, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: DATOS DE LA SOLICITUD',
'Descripcion: SPL encargado de consultar los registros para el llenado del combo de comprobante de ingresos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusrepdetsolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusrepdetsolicitudmc.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_repsolicitudmc WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/09/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte solicitud mc.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarreportes_tef_mx(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pTipoArchivo CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pTipoReporte SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                CHAR(10) AS fecha_presentacion,
                                CHAR(20) AS nombre_arch,
                                CHAR(2) AS cod_operacion,
                                CHAR(4) AS no_sucursal,
                                CHAR(40) AS nombre_ord,
                                CHAR(20)AS num_cta_ord,
                                CHAR(50) AS tipo_operacion,
                                CHAR(7) AS ref_numerica,
                                DECIMAL(11,2) AS importe,
                                CHAR(40) AS nombre_rec,
                                CHAR(20) AS num_cta_rec,
                                CHAR(7) AS num_secuencia,
                                CHAR(40) AS tipo_cta_destino,
                                CHAR(40) AS bancodestino,
                                CHAR(20) AS status,
                                DECIMAL(18,2) AS imp_operaciones,
                                CHAR(8) AS fecha_presentacion2,
                                CHAR(2) AS motivo_dev,
                                CHAR(50) AS descripcion,
                                INTEGER AS registrosCod61,
                                DECIMAL(18,2) AS totalImporteCod61,
                                INTEGER AS registrosCod62,
                                DECIMAL(18,2) AS totalImporteCod62;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cFechaInicio CHAR(8);
        DEFINE cFechaFin CHAR(8);
        DEFINE iNoRegistros INTEGER;
        DEFINE cFechaPresentacion CHAR(10);
        DEFINE cNombreArch CHAR(20);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cNoSucursal CHAR(4);
        DEFINE cNombreOrd CHAR(40);
        DEFINE cNumCtaOrd CHAR(20);
        DEFINE cTipoOperacion CHAR(50);
        DEFINE cRefNumerica CHAR(7);
        DEFINE dImporte DECIMAL(11,2);
        DEFINE cNombreRec CHAR(40);
        DEFINE cNumCtaRec CHAR(20);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cTipoCtaDestino CHAR(40);
        DEFINE cBancoDestino CHAR(40);
        DEFINE cStatus CHAR(20);
        DEFINE dImpOperaciones DECIMAL(18,2);
        DEFINE cFechaPresentacion2 CHAR(8);
        DEFINE cMotivoDev CHAR(2);
        DEFINE cDescripcion CHAR(50);
        DEFINE iRegistrosCod61 INTEGER;
        DEFINE dTotalImporteCod61 DECIMAL(18,2);
        DEFINE iRegistrosCod62 INTEGER;
        DEFINE dTotalImporteCod62 DECIMAL(18,2);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cFechaInicio = '';
        LET cFechaFin = '';
        LET iNoRegistros = 0;
        LET cFechaPresentacion = '';
        LET cNombreArch = '';
        LET cCodOperacion = '';
        LET cNoSucursal = '';
        LET cNombreOrd = '';
        LET cNumCtaOrd = '';
        LET cTipoOperacion = '';
        LET cRefNumerica = '';
        LET dImporte = NULL;
        LET cNombreRec = '';
        LET cNumCtaRec = '';
        LET cNumSecuencia = '';
        LET cTipoCtaDestino = '';
        LET cBancoDestino = '';
        LET cStatus = '';
        LET dImpOperaciones = NULL;
        LET cFechaPresentacion2 = '';
        LET cMotivoDev = '';
        LET cDescripcion = '';
        LET iRegistrosCod61 = 0;
        LET dTotalImporteCod61 = NULL;
        LET iRegistrosCod62 = 0;
        LET dTotalImporteCod62 = NULL;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END EXCEPTION;

                 --SET DEBUG FILE TO '/tmp/ALAN/sp_generarreportes_tef.out';
                 --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pTipoArchivo = '' OR pTipoReporte IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                IF LENGTH(pNombreArchivo) > 15 THEN
                        LET pFechaInicial = NULL;
                        LET pFechaFinal = NULL;
                ElIF LENGTH(pTipoArchivo) = 2 THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                        cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                        cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                        dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                        END IF;

                        LET pNombreArchivo = '';
                        LET cFechaInicio = YEAR(DATE(pFechaInicial))||LPAD(MONTH(DATE(pFechaInicial)), 2, '0')||LPAD(DAY(DATE(pFechaInicial)), 2, '0');
                        LET cFechaFin = YEAR(DATE(pFechaFinal))||LPAD(MONTH(DATE(pFechaFinal)), 2, '0')||LPAD(DAY(DATE(pFechaFinal)), 2, '0');
                END IF;

                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                FOREACH EXECUTE PROCEDURE bditef:"informix".sp_reportearchivos_tef2(pNombreArchivo, pTipoArchivo, cFechaInicio, cFechaFin, pTipoReporte, pRegistros, pRecuperacion)
                        INTO cCodRetSp, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:"informix".sp_reportearchivos_tef2';
                        ELIF iCodRetSp = 1 THEN
                                LET cCodRet = '00003';
                        END IF;

                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62 WITH RESUME;

                END FOREACH;

                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/08/2015',
'MODULO: TEF',
'FUNCIONALIDAD: Reportes de archivos tef',
'DESCRIPCION: Consulta de la informaciÃÂ³n para el llenado de los reportes de TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarreportes_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pTipoArchivo CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pTipoReporte SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                CHAR(10) AS fecha_presentacion,
                                CHAR(20) AS nombre_arch,
                                CHAR(2) AS cod_operacion,
                                CHAR(4) AS no_sucursal,
                                CHAR(40) AS nombre_ord,
                                CHAR(20)AS num_cta_ord,
                                CHAR(50) AS tipo_operacion,
                                CHAR(7) AS ref_numerica,
                                DECIMAL(11,2) AS importe,
                                CHAR(40) AS nombre_rec,
                                CHAR(20) AS num_cta_rec,
                                CHAR(7) AS num_secuencia,
                                CHAR(40) AS tipo_cta_destino,
                                CHAR(40) AS bancodestino,
                                CHAR(20) AS status,
                                DECIMAL(18,2) AS imp_operaciones,
                                CHAR(8) AS fecha_presentacion2,
                                CHAR(2) AS motivo_dev,
                                CHAR(50) AS descripcion,
                                INTEGER AS registrosCod61,
                                DECIMAL(18,2) AS totalImporteCod61,
                                INTEGER AS registrosCod62,
                                DECIMAL(18,2) AS totalImporteCod62;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cFechaInicio CHAR(8);
        DEFINE cFechaFin CHAR(8);
        DEFINE iNoRegistros INTEGER;
        DEFINE cFechaPresentacion CHAR(10);
        DEFINE cNombreArch CHAR(20);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cNoSucursal CHAR(4);
        DEFINE cNombreOrd CHAR(40);
        DEFINE cNumCtaOrd CHAR(20);
        DEFINE cTipoOperacion CHAR(50);
        DEFINE cRefNumerica CHAR(7);
        DEFINE dImporte DECIMAL(11,2);
        DEFINE cNombreRec CHAR(40);
        DEFINE cNumCtaRec CHAR(20);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cTipoCtaDestino CHAR(40);
        DEFINE cBancoDestino CHAR(40);
        DEFINE cStatus CHAR(20);
        DEFINE dImpOperaciones DECIMAL(18,2);
        DEFINE cFechaPresentacion2 CHAR(8);
        DEFINE cMotivoDev CHAR(2);
        DEFINE cDescripcion CHAR(50);
        DEFINE iRegistrosCod61 INTEGER;
        DEFINE dTotalImporteCod61 DECIMAL(18,2);
        DEFINE iRegistrosCod62 INTEGER;
        DEFINE dTotalImporteCod62 DECIMAL(18,2);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cFechaInicio = '';
        LET cFechaFin = '';
        LET iNoRegistros = 0;
        LET cFechaPresentacion = '';
        LET cNombreArch = '';
        LET cCodOperacion = '';
        LET cNoSucursal = '';
        LET cNombreOrd = '';
        LET cNumCtaOrd = '';
        LET cTipoOperacion = '';
        LET cRefNumerica = '';
        LET dImporte = NULL;
        LET cNombreRec = '';
        LET cNumCtaRec = '';
        LET cNumSecuencia = '';
        LET cTipoCtaDestino = '';
        LET cBancoDestino = '';
        LET cStatus = '';
        LET dImpOperaciones = NULL;
        LET cFechaPresentacion2 = '';
        LET cMotivoDev = '';
        LET cDescripcion = '';
        LET iRegistrosCod61 = 0;
        LET dTotalImporteCod61 = NULL;
        LET iRegistrosCod62 = 0;
        LET dTotalImporteCod62 = NULL;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END EXCEPTION;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;

                 --SET DEBUG FILE TO '/tmp/ALAN/sp_generarreportes_tef.out';
                 --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pTipoArchivo = '' OR pTipoReporte IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                IF LENGTH(pNombreArchivo) > 15 THEN
                        LET pFechaInicial = NULL;
                        LET pFechaFinal = NULL;
                ElIF LENGTH(pTipoArchivo) = 2 THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                        cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                        cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                        dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                        END IF;

                        LET pNombreArchivo = '';
                        LET cFechaInicio = YEAR(DATE(pFechaInicial))||LPAD(MONTH(DATE(pFechaInicial)), 2, '0')||LPAD(DAY(DATE(pFechaInicial)), 2, '0');
                        LET cFechaFin = YEAR(DATE(pFechaFinal))||LPAD(MONTH(DATE(pFechaFinal)), 2, '0')||LPAD(DAY(DATE(pFechaFinal)), 2, '0');
                END IF;

                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                FOREACH EXECUTE PROCEDURE bditef:"informix".sp_reportearchivos_tef2(pNombreArchivo, pTipoArchivo, cFechaInicio, cFechaFin, pTipoReporte, pRegistros, pRecuperacion)
                        INTO cCodRetSp, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:"informix".sp_reportearchivos_tef2';
                        ELIF iCodRetSp = 1 THEN
                                LET cCodRet = '00003';
                        END IF;

                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62 WITH RESUME;

                END FOREACH;

                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/08/2015',
'MODULO: TEF',
'FUNCIONALIDAD: Reportes de archivos tef',
'DESCRIPCION: Consulta de la informaciÃÂ³n para el llenado de los reportes de TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatalogocausastatusmc(pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
        RETURNING CHAR(5) AS codret,
                        CHAR(2) AS status,
                        CHAR(40) AS descripcion_status,
                        CHAR(3) AS causa,
                        CHAR(100) AS descripcion_causa,
						CHAR(100) AS justificacion;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cStatus CHAR(2);
        DEFINE cDescripcionStatus CHAR(40);
        DEFINE cCausa CHAR(3);
        DEFINE cDescripcionCausa CHAR(100);
		DEFINE cJustificacion CHAR(100);
		DEFINE iNoRegitros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cStatus = '';
        LET cDescripcionStatus = '';
        LET cCausa = '';
        LET cDescripcionCausa = '';
		LET cJustificacion = '';
		LET iNoRegitros = 0;
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
                END EXCEPTION;
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogocausastatusmc.out';
                -- TRACE ON;
				
				--SET LOCK MODE TO WAIT 3;
				
				IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
		
				-- VALIDACION DE LA PAGINACION
				IF pRegistros < 0 OR pRecuperacion < 0 THEN
					LET cCodRet = '00098';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion codret, status, descripcion_status, causa, descripcion_causa, justificacion
						INTO cCodRetSp, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion
						FROM TABLE(PROCEDURE bdicred:'informix'.sp_consultarcausastatussoc(pStatus))
							AS consultarcausastatus_tmp(codret, status, descripcion_status, causa, descripcion_causa, justificacion)
					IF cCodRetSp::SMALLINT = 1 THEN
						LET cCodRet = '00017';
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
					ELSE
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion WITH RESUME;
						LET iNoRegitros = iNoRegitros + 1;
					END IF;
				END FOREACH;
				
				IF iNoRegitros = 0 THEN
					IF pRegistros = 0 THEN
						LET cCodRet = '00017';
					ELIF pRegistros > 0 THEN
						LET cCodRet = '1001';
					END IF;
					
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
        END;
        
END PROCEDURE
DOCUMENT 
"AUTOR: Johnattan Esquivel Sánchez",
"FECHA: 01/08/2018",
"DESCRIPCION: Se aplica mantto MC",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_ope_catsucaralreporte(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(4) AS sucursal,
				CHAR(40) AS nombre,
				CHAR(3) AS plaza,
				CHAR(3) AS pais,
				CHAR(2) AS estado;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cSucursal 		CHAR(40);
	DEFINE cNombre 			CHAR(40);
	DEFINE cPlaza 			CHAR(3);
	DEFINE cPais 			CHAR(3);
	DEFINE cEstado 			CHAR(2);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iRegistros 		INTEGER;
	DEFINE iRecuperacion 	INTEGER;

	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cSucursal 			= '';
	LET cNombre 			= '';
	LET cPlaza 				= '';
	LET cPais 				= '';
	LET cEstado 			= '';
	LET iNoRegistros 		= 0;
	LET iRegistros 			= 0;
	LET iRecuperacion 		= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/yoselin/bdicnweb/sp_ope_catsucaralreporte.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,  cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;				
					
		FOREACH SELECT {+AVOID_FULL(bdinteg:"informix".si_sucursales)} SKIP pRegistros FIRST pRecuperacion sucursal, nombre, plaza_cajagen, pais, estado
				INTO cSucursal, cNombre, cPlaza, cPais, cEstado
				FROM bdinteg:"informix".si_sucursales   
				ORDER BY sucursal::INTEGER

				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cSucursal, UPPER(TRIM(cNombre)), cPlaza, cPais, cEstado WITH RESUME;
		END FOREACH

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Uriel CaamaÃ±o Mejia',
'FECHA: 17/02/2016',
'MODULO: OPERACION',
'FUNCIONALIDAD: Reportes Convenios SAC',
'DESCRIPCION: SPL que realiza la consulta de las sucursales.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 21/04/2016',
'DESCRIPCION:  Se realizo una modificacion a el campo plaza por plaza_cajagen.',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 22/03/2017',
'DESCRIPCION:  Se realizo una modificacion al SPL para optimizar la respuesta haciendo un cruce directo con la tabla bdinteg:si_ptf.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consanalistadictamen(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS numero,
			CHAR(45) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE numAnalista CHAR(8);
	DEFINE nomAnalista CHAR(45);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET numAnalista = '';
	LET nomAnalista = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, numAnalista, nomAnalista;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consanalistadictamen.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, numAnalista, nomAnalista;
		END IF;				
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, numAnalista, nomAnalista;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consanalistadictamen()
			INTO cCodRetSp, numAnalista, nomAnalista
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, numAnalista, nomAnalista;
			END IF;
			
			RETURN cCodRet, numAnalista, UPPER(nomAnalista) WITH RESUME;
		END FOREACH;
		
		 -- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00017';
			RETURN cCodRet, TRIM(NVL(numAnalista,'')), TRIM(NVL(nomAnalista,''));
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 12/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos del analista de comparación de huellas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consexpedientehuella(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(4), pCliente CHAR(9), pNumRegs SMALLINT)
		RETURNING CHAR(5) AS codret,
			  CHAR(20) AS cuenta,
			  CHAR(40) AS prod_nombre,
			  CHAR(4) AS cod_docto,
			  DATE AS fecha_alta,
			  CHAR(3) AS cod_grupo,
			  CHAR(30) AS descrip_gpo,
			  CHAR(35) AS descrip_docto,
			  CHAR(30) AS descrip2,
			  CHAR(1) AS multi_img,
			  SMALLINT AS secuencia,
			  CHAR(1) AS ima_esnula;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;	
	DEFINE cCuenta CHAR(20);
    DEFINE cProdNombre CHAR(40);
    DEFINE cCodDocto CHAR(4);
    DEFINE dFechAlta DATE;
    DEFINE cCodGrupo CHAR(3);
    DEFINE cDescripGpo CHAR(30);
    DEFINE cDescripDocto CHAR(35);
    DEFINE cDescrip2 CHAR(30);
    DEFINE cMultImg CHAR(1); 
    DEFINE cSecuencia SMALLINT;   
    DEFINE cImaEsnula CHAR(1);
	DEFINE iCont SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCuenta= '';
    LET cProdNombre = '';
    LET cCodDocto = '';
    LET dFechAlta = '';
    LET cCodGrupo = '';
    LET cDescripGpo = '';
    LET cDescripDocto = '';
    LET cDescrip2 = '';
    LET cMultImg = '';   
    LET cSecuencia = 0;   
    LET cImaEsnula = '';   
	LET iCont = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consexpedientehuella.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pCliente = '' OR pNumRegs IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdidigital:"informix".cons_expediente_huella(pEmpresa,pCliente,pNumRegs) 
			INTO cCodRetSp, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula
			
			LET iCont = iCont + 1;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital@coppelimg_tcp:"informix".cons_expediente_huella';
			ELIF iCodRetSp = 110 THEN
				LET cCodRet = '00003';
			END IF;
			
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula WITH RESUME;
		END FOREACH;
		
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el expediente de documentos de identificacion del cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultacalles(pUsuario CHAR(8), pIdFuncion CHAR(10), pCalle INTEGER ,pNombre CHAR(30))
		RETURNING CHAR(5) AS codret,
		  CHAR(80) AS mensaje_Retorno,
		  INTEGER  AS calle,
		  CHAR(30) AS nombre;    
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE iCalle INTEGER;
	DEFINE cNombre CHAR(30);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET iCalle = '';
	LET cNombre = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultacalles.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCalle IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultacalles(pCalle, pNombre, 0)
			INTO cCodRetSp, cMensajeRet, iCalle, cNombre
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultacalles';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cMensajeRet, iCalle, cNombre WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta la calle del Cliente Coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultacatdictamen(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS tipo_dictamen,
			CHAR(100) AS descripcion_dictamen;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoDictamen CHAR(1);
	DEFINE cDescDictamen CHAR(100);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoDictamen = '';
	LET cDescDictamen = '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultacatdictamen.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;
		
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consultacatdictamen()
			INTO cCodRetSp, cTipoDictamen, cDescDictamen 
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_consultacatdictamen()';		
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';			
			END IF;
			
			RETURN cCodRet, cTipoDictamen, TRIM(UPPER(cDescDictamen)) WITH RESUME;
		END FOREACH;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 07/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTA - INFORME DE DICTAMENES',
'DESCRIPCION: SPL que consulta los tipos de dictamenes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultactecoincidencia(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pEmpresa CHAR(3), pTpDireccion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(40) AS nombre1,
			CHAR(40) AS nombre2,
			CHAR(40) AS ap_paterno,
			CHAR(40) AS ap_materno,
			CHAR(13) AS rfc,
			CHAR(10) AS fecha_naci,
			CHAR(1)  AS sexo,
			CHAR(20) AS tipo_persona,
			CHAR(10) AS fecha_alta,
			CHAR(4)  AS sucursal,
			CHAR(30) AS nom_calle,
			CHAR(10) AS num_ext,
			CHAR(10) AS num_int,
			CHAR(6)  AS depto,
			CHAR(30) AS nom_colonia,
			CHAR(30) AS nom_municipio,
			CHAR(30) AS nom_ciudad,
			CHAR(30) AS nom_estado,
			CHAR(10) AS tel_particular,
			CHAR(10) AS tel_celular,
			CHAR(10) AS tel_trabajo,
			CHAR(5)  AS extencion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre1 CHAR(40);
	DEFINE cNombre2 CHAR(40);
	DEFINE cApPaterno CHAR(40);
	DEFINE cApMaterno CHAR(40);
	DEFINE cRFC CHAR(13);
	DEFINE cFechNacimiento CHAR(10);
	DEFINE cSexo CHAR(1);
	DEFINE cDescTpPersona CHAR(20);
	DEFINE cFechaAlta CHAR(10);
	DEFINE cSucursal CHAR(4);
	DEFINE cNomCalle CHAR(30);
	DEFINE cNumeroExt CHAR(10);
	DEFINE cNumeroInt CHAR(10);
	DEFINE cDepto CHAR(6);
	DEFINE cNomColonia CHAR(30);
	DEFINE cNomMunicipio CHAR(30);	
	DEFINE cNomCiudad CHAR(30);
	DEFINE cNomEstado CHAR(30);		
	DEFINE cTelParticular CHAR(10);
	DEFINE cTelCelular CHAR(10);
	DEFINE cTelTrabajo CHAR(10);
	DEFINE cExtencion CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRFC = '';
	LET cFechNacimiento = '';
	LET cSexo = '';	
	LET cDescTpPersona = '';
	LET cFechaAlta = '';
	LET cSucursal = '';
	LET cNomCalle = '';
	LET cNumeroExt = '';
	LET cNumeroInt = '';
	LET cDepto = '';	
	LET cNomColonia = '';	
	LET cNomMunicipio = '';	
	LET cNomEstado = '';	
	LET cNomCiudad = '';
	LET cTelParticular = '';
	LET cTelCelular = '';
	LET cTelTrabajo = '';
	LET cExtencion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultactecoincidencia.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pEmpresa = '' OR pTpDireccion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END IF;
				
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultactecoincidencia(pNumCte, pEmpresa, pTpDireccion)
		INTO cCodRetSp,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultactecoincidencia';
		ELIF iCodRetSp =  1 THEN
			LET cCodRet = '00003';			
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00020';
		END IF;
		
		RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos y dirección del cliente coincidencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaempleadoiccat(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR (3), pNumEmp CHAR(8))
		RETURNING CHAR(5) AS codret,
		CHAR(45) AS nomEmpleado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNomEmpleado CHAR(45);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNomEmpleado = '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomEmpleado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaempleadoiccat.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomEmpleado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomEmpleado;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_empleado_iccat(pEmpresa, pNumEmp)
		INTO cCodRetSp, cNomEmpleado;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consulta_empleado_iccat';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00072';
		END IF;
		
		RETURN cCodRet, cNomEmpleado;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 28/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que retorna el nombre del empleado iccat',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaestados(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2),pNombre CHAR(30))
		RETURNING CHAR(5) AS codret,
		CHAR(80) AS mensaje_Retorno,
		CHAR(2)  AS estado,
		CHAR(30) AS nombre;    
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE cEstado CHAR(2);
	DEFINE cNombre CHAR(30);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET cEstado = '';
	LET cNombre = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaestados.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEstado IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultaestados(pEstado, pNombre, 0)
			INTO cCodRetSp, cMensajeRet, cEstado, cNombre
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultaestados';
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '1001';
			END IF;
			RETURN cCodRet, cMensajeRet, cEstado, cNombre WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el estado del Cliente Coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultalertacomph(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pSkyp INTEGER,
			pStatus CHAR (1),pNumctenvo CHAR (20),pFechaIni DATE,pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS statusAlerta,
			CHAR(4) AS sucursal,
			CHAR(20) AS cliente,
			SMALLINT AS matches,
			DATE AS fechaInsert,
			CHAR (1) AS origen,
			INTEGER	AS totalComparaciones,
			CHAR(5)	AS hora,
			CHAR(8)	AS analistaFraudes,
			CHAR(30) AS descripcionOrigen;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cStatusAlerta CHAR(1);
	DEFINE cSucursal CHAR (4);
	DEFINE cCliente CHAR (20);
	DEFINE cMatches SMALLINT;
	DEFINE dFechaInsert DATE;
	DEFINE cOrigen CHAR (1);
	DEFINE iTotalComparaciones INTEGER;
	DEFINE cHora CHAR(5);
	DEFINE cAnalistaFraudes CHAR(8);
	DEFINE cDescripcionOrigen CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cStatusAlerta = '';
	LET cSucursal = '';
	LET cCliente = '';
	LET cMatches = 0;
	LET dFechaInsert = '';
	LET cOrigen = '';
	LET iTotalComparaciones = 0;
	LET cHora = '';
	LET cAnalistaFraudes = '';
	LET iNoRegistros = 0;
	LET cDescripcionOrigen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultalertacomph.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pModo IS NULL OR pModo NOT IN (1,2) THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		IF pModo = '2' AND pNumctenvo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;	

		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consultalertacomph2(pModo, pSkyp, pStatus, pNumctenvo, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_dicta_consultalertacomph2';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;

			IF iNoRegistros > 0 THEN
				LET iCodRetSp = '00000';
			END IF;

			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen WITH RESUME;
		END FOREACH;
				
		IF iNoRegistros = 0 AND pRegistros = 0 THEN	
			LET cCodRet = '00017';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN 
			LET cCodRet = '1001';	
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la consulta para el llenado del buzon de alertas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultamatchhuellacte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNvoCteBco CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS numcte_match,
			CHAR(4) AS empresa,
			CHAR(25) AS descripcion,
			CHAR(4) AS sucursal,
			SMALLINT AS bandera;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cClienteMatch CHAR(20);
	DEFINE cEmpresa CHAR(4);
	DEFINE cDescripcion CHAR(25);
	DEFINE sCteExiste SMALLINT;
	DEFINE cSucursal CHAR(4);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cClienteMatch = '';
	LET cEmpresa = '';
	LET cDescripcion = '';
	LET sCteExiste = 0;
	LET cSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultamatchhuellacte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNvoCteBco = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_matcheshuellacte(pNvoCteBco)
			INTO cCodRetSp, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consulta_matcheshuellacte';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '1001'; --NO HAY RESPUESTA DE LA COMPARACION DE HUELLAS
			--ELIF iCodRetSp = 2 THEN
			--	LET cCodRet = '00017'; --OCURRIO UN PROBLEMA DE AMBIENTACION
			END IF;
			
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal WITH RESUME;
		END FOREACH;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Verifica si ha habido respuesta de la comparacion de huellas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaparamdigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pCodParam SMALLINT)
		RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_param,
			CHAR(50) AS des_param;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cValorParam CHAR(100);
	DEFINE cDesParam CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cValorParam = '';
	LET cDesParam = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorParam, cDesParam;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaparamdigitalizacion.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pCodParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion(pEmpresa, pCodParam)
		INTO cCodRetSp, cValorParam, cDesParam;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';			
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00367';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01071';
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00017';
		END IF;
		RETURN cCodRet, cValorParam, cDesParam;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los parametros IP y Puerto del servidor de imagenes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultarcatsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS empresa, 
			CHAR(4) AS sucursal, 
			CHAR(40) AS nombre, 
			CHAR(40) AS direccion1, 
			CHAR(40) AS direccion2, 
			CHAR(14) AS telefono,
			CHAR(40) AS gerente, 
			CHAR(40) AS subgerente, 
			CHAR(2) AS tpo_sucursal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE cDireccion1 CHAR(40);
	DEFINE cDireccion2 CHAR(40);
	DEFINE cTelefono1 CHAR(14);
	DEFINE cGerente CHAR(40);
	DEFINE cSubgerente CHAR(40);
	DEFINE cTipoSucursal CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '';
	LET cSucursal = '';
	LET cNombre = '';
	LET cDireccion1 = '';
	LET cDireccion2 = '';
	LET cTelefono1 = '';
	LET cGerente = '';
	LET cSubgerente = '';
	LET cTipoSucursal = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultarcatsucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa= '' OR pSucursal= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatsucursales(pEmpresa, pSucursal)
			INTO cCodRetSp, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultarcatsucursales';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
			END IF;
	
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultasucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSuc CHAR(40);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSuc = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultasucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		SELECT nombre 
		INTO cNombreSuc 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF NVL(cNombreSuc,'') = '' THEN
			LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
		END IF;
		
		RETURN cCodRet,TRIM(UPPER(cNombreSuc));
		
	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 12/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Spl que consulta el nombre de la sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_correciondatoscte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pTipoSol CHAR(20), pNombreInc CHAR (104), pFechaNacInc DATE, 
									pNumCteCorr CHAR(20), pNombreCorr CHAR(104), pFechaNacCorr DATE, pSucursal CHAR(4), pOrigen CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_correciondatoscte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pTipoSol = '' OR pNombreInc = '' OR pFechaNacInc IS NULL 
		  OR pNumCteCorr = '' OR pNombreCorr = '' OR pFechaNacCorr IS NULL OR pSucursal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_bit_solicitudessos_sif(pNumCte, pTipoSol, pNombreInc, pFechaNacInc, pNumCteCorr, pNombreCorr, pFechaNacCorr, pSucursal, pUsuario, pOrigen)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_bit_solicitudessos_sif';
		--ELIF iCodRetSp =  THEN
		--	LET cCodRet = '';
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la correción de los datos de clientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_enviarmonitoralertas(pUsuario CHAR(8), pIdFuncion CHAR(10),pTramaEnvios CHAR(250))
		RETURNING CHAR(5) AS codRet;
   
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cNumCte CHAR(9); 
   DEFINE iNoRegistros INTEGER;   
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cNumCte = '';
   LET iNoRegistros = 0;   
   
   BEGIN

	  ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
	  		RETURN cCodRet;
	  	END IF;
	  END EXCEPTION;
		
	  --SET DEBUG FILE TO '/tmp/mfinis/sp_dic_enviarmonitoralertas.out';
	  --TRACE ON;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
		
	  IF pUsuario = '' OR pIdFuncion = '' OR pTramaEnvios = '' THEN
		LET cCodRet = '00003';	
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
		RETURN cCodRet;
	  END IF;
		
	  EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	  IF cCodRet <> '00000' THEN
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
	  	RETURN cCodRet;
	  END IF;

	  DELETE FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
	  INSERT INTO bdicnweb:"informix".sw_dic_statusbuzonenvmonitor(usuario,total_registros,status,error_proceso,error_code)
      VALUES(pUsuario, iNoRegistros,'I','', ''); 
	  
	  FOREACH
	  
		EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEnvios, '|')
		INTO cNumCte
		--ACTUALIZA ES ESTATUS DE 5 A 1
		update bdinteg:'informix'.si_bitacora_comparaciones 
	    set status_alerta = '1' 
	    where numcte = cNumCte 
	    and status_alerta = '5';
		
		 LET iNoRegistros = iNoRegistros + 1;
		 
	  END FOREACH;
	  
	  UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
      SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
	  
	  RETURN cCodRet;
   END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SP que se encarga de regersar las alertas del buzon de pendientes al monitor de alertas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_reevdparam(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5)  AS codret,
			      CHAR(8)  AS  cTotalRegEncon,
			      CHAR(8)  AS cTotalRegenDep,
			      CHAR(8)  AS  cTotalRegPen;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTotalRegEncon CHAR(8);
	DEFINE cTotalRegenDep CHAR(8);
	DEFINE cTotalRegPen CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTotalRegEncon = '';
	LET cTotalRegenDep = '';
	LET cTotalRegPen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_reevdparam.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;				
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_reevdparam()
		INTO cCodRetSp, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_reevdparam';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza el proceso de revaluación de los registros ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusbuzonenvmonitor(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusbuzonenvmonitor.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del buzon de pendientes al monitor de alertas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsctesdichawk(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsctesdichawk.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsctesdichawk WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 11/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados Hawk de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsultahuellas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS total_registros,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cError = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsultahuellas.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cError = '00003';
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cError;
		IF cError <> '00000' THEN
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsultahuellas WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			RETURN cCodRet,iTotalReg,'I',cErrorProceso,cError;		
		ELSE 			
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 07/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTA HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusenviobuzon(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusenviobuzon.out';
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusenviobuzon WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del Monitor de Alertas al Buzon de pendientes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscapersona_pba(pId_UsuarioC CHAR(8), 
									pId_FuncionC CHAR(10), 
									pTipoBusqueda SMALLINT, 
									pIdOficio INT, 
									pNombre1 CHAR(60), 
									pNombre2 CHAR(26), 
									pApPaterno CHAR(26), 
									pApMaterno CHAR(26), 
									pPagina SMALLINT, 
									pRegistros SMALLINT, 
									pIp CHAR(15), 
									pMacAddress CHAR(12))

RETURNING CHAR(5) AS codRet, 
	CHAR(20) AS numeroCliente, 
	CHAR(15) AS rfc,
	CHAR(26) AS nombre1, 
	CHAR(26) AS nombre2, 
	CHAR(26) AS apPaterno, 
	CHAR(26) AS apMaterno, 
	CHAR(60) AS razonSocial,
	CHAR(20) AS noCuenta,
	CHAR(20) AS noTarjeta,
	CHAR(2) AS tipoPersona, 
	CHAR(1) AS tipoCliente, 
	INT AS status, 
	CHAR(20) AS descStatusBusqueda,
	CHAR(1) AS ind_omitido,
	CHAR(1) AS ind_bloqueocta,
	CHAR(1) AS ind_terminado,
	INT AS id_busqueda,
	INT AS id_resulcte,
	CHAR(2) AS tipoCuenta,
	CHAR(1) AS ind_rfc,
	CHAR(1) AS ind_dir_empleo,
	CHAR(1) AS ind_domicilio,
	CHAR(1) AS ind_nacionalidad
-- Definición de variables
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNumeroCuenta CHAR(20);
	DEFINE cNumeroTarjeta CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE iIdNumConsulta INT;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE iExiste INT;
	DEFINE cCriterio CHAR(60);
	DEFINE iIdBusqueda INT;
	DEFINE cTipoBusquedaPersona CHAR(1);
	DEFINE cTipoPersona CHAR(2);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cIdEncontrado INT;
	DEFINE iStatusBusqueda INT;
	DEFINE cDescStatusBusqueda CHAR(20);
	DEFINE iRegsProc INT;
	DEFINE cOmitido CHAR(1);
	DEFINE cBloqueado CHAR(1);
	DEFINE cTerminado CHAR(1);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cIndRfc CHAR(1);
	DEFINE cIndEmpleo CHAR(1);
	DEFINE cIndDomicilio CHAR(1);
	DEFINE cIndNacionalidad CHAR(1);
	-- ETIQUETAS
	DEFINE cHomonimo CHAR(15);
	DEFINE cEncontrado CHAR(15);
	DEFINE cNoEncontrado CHAR(15);
	--Inicialización de variables
	LET cCodRet	= '00000';
	LET cCodRetSp = '00000';
	LET cNumeroCliente = '';
	LET cRfc = '';
	LET iIdNumConsulta = 0;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET iSqlErr = 0;
	LET cHomonimo = 'HOMONIMO';
	LET cEncontrado = 'LOCALIZADO';
	LET cNoEncontrado = 'NO LOCALIZADO';
	LET iExiste = 0;
	LET cCriterio = '';
	LET iIdBusqueda = 0;
	LET cTipoPersona = '';
	LET cTipoCliente = '';
	LET iStatusBusqueda = 0;
	LET cDescStatusBusqueda = '';
	LET cIdEncontrado = 0;
	LET iRegsProc = 0;
	LET cNumeroCuenta = '';
	LET cNumeroTarjeta = '';
	LET cOmitido = '0';
	LET cBloqueado = '0';
	LET cTerminado = '0';
	LET cTipoCuenta = '';
	LET cIndRfc = '0';
	LET cIndEmpleo = '0';
	LET cIndDomicilio = '0';
	LET cIndNacionalidad = '0';
	
	BEGIN
		-- Validaciones
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, cIdEncontrado, 
						0, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			END IF;
		END EXCEPTION;

	  --SET DEBUG FILE TO "/RESPALDOS/sp_sw_ro_buscapersona.out";
	  --TRACE ON;

		-- Validación del numero de oficio
		IF pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroCliente, cRfc, 
					cNombre1, cNombre2, cApPaterno, 
					cApMaterno, cRazonSocial, cNumeroCuenta, 
					cNumeroTarjeta, cTipoPersona, cTipoCliente, 
					iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
					cBloqueado, cTerminado, cIdEncontrado,
					0, cTipoCuenta, cIndRfc, 
					cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		-- Busqueda del numero de oficio
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_oficio) 
		INTO iExiste 
		FROM sw_ro_maeoficios 
		WHERE id_oficio = pIdOficio;
		IF iExiste = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido,
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc, 
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		IF pTipoBusqueda NOT IN (1,2,3,4,5,6) THEN
			LET cCodRet = '00087';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc,
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		ELSE
			-- Se INSERTa el criterio de busqueda en la tabla sw_ro_buscaper
			-- Criterio de busqueda por Nombre
			IF pTipoBusqueda = 1 THEN
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno,
																pApMaterno, pNombre1, pNombre2,
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '1';
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda, 
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															'', cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, iIdBusqueda, 
						cIdEncontrado, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad
						WITH resume;
				END FOREACH;
			END IF;
			-- Criterio de busqueda por Razón Social
			IF pTipoBusqueda = 2 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																cCriterio, '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																	pApMaterno, pNombre1, pNombre2, 
																	cCriterio, '', '', 
																	'', '', pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '2';
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda,
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															cCriterio, cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
				END FOREACH;
			END IF;
			-- Busqueda por RFC
			IF pTipoBusqueda = 3 THEN
				LET cCriterio = TRIM(pNombre1);
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '',
																'', '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} COUNT(*)
				INTO iRegsProc
				FROM bdinteg:si_cliente WHERE rfc like trim(cCriterio)||"%";
				--FROM bdinteg:si_cliente WHERE rfc_alterno = cCriterio;
				IF iRegsProc = 0 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)}  COUNT(*)
					INTO iRegsProc
					FROM bdinteg:si_cliente WHERE rfc_alterno like trim(cCriterio)||"%";
					--FROM bdinteg:si_cliente WHERE rfc = cCriterio;
				END IF;
				IF iRegsProc = 0 THEN
					LET cRfc = cCriterio;
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cRazonSocial = '';
					-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																	'', '', '', '', 
																	'', cRfc, 
																	cNumeroCliente, '', '', '',
																	cTipoCliente, iStatusBusqueda, pIp, pMacAddress)
																	INTO cCodRetSp, iRegsProc;					
					RETURN cCodRet, cNumeroCliente, cRfc, 
							cNombre1, cNombre2, cApPaterno, 
							cApMaterno, cRazonSocial, cNumeroCuenta, 
							cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
							cBloqueado, cTerminado, iIdBusqueda, 
							cIdEncontrado, cTipoCuenta, cIndRfc, 
							cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					LET iRegsProc = 0;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxrfc2(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																cCriterio, pPagina, pRegistros, pIp, 
																pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda,
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cliente
			IF pTipoBusqueda = 4 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT SUBSTRING(tpo_persona FROM 2) AS tpo_persona, apell_paterno, apell_materno, nombre1, 
														nombre2, razon_social
				INTO cTipoBusquedaPersona, pApPaterno, pApMaterno, pNombre1, 
						pNombre2, cRazonSocial
				FROM bdinteg:si_cliente 
				WHERE numcte = cCriterio;
				IF cTipoBusquedaPersona is null THEN
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cNumeroCliente = cCriterio;
					LET cRazonSocial = '';
				-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, '', 
																	'', '', '', '', 
																	'', cNumeroCliente, '', '', 
																	'', cTipoCliente, iStatusBusqueda, pIp,
																	pMacAddress)
					INTO cCodRetSp, iRegsProc;
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					SET ISOLATION TO DIRTY READ;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																	1, cCriterio, pRegistros, pIp, 
																	pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado,
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 5 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(1, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno, 
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																		'', '', '', '', 
																		'', '', '', cCriterio, 
																		'', '', cTipoCliente, iStatusBusqueda, 
																		pIp, pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																		2, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
									cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET cuenta = cCriterio
							WHERE id_busqueda = iIdBusqueda 
									AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
									cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
									cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
									cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
									cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
									WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 6 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', '', cCriterio, pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																	pNombre1, pNombre2, '', '', 
																	'', '', cCriterio, pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(2, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno,
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio,'',
																		'', '', '', '',
																		'', '', '', cCriterio,
																		'',	cTipoCliente, iStatusBusqueda, pIp, 
																		pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta,
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad  
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																		3, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET num_tarjeta = cCriterio
							WHERE id_busqueda = iIdBusqueda AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
							WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
		END IF;
	END
END PROCEDURE;