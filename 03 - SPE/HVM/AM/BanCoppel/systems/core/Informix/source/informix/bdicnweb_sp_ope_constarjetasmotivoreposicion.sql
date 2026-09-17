CREATE PROCEDURE "informix".sp_ope_constarjetasmotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    INTEGER AS id_tipo, 
			CHAR(60) AS desc_reposicion;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipo, cDescripcion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constarjetasmotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;					
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT id_tipo, descripcion
			INTO iTipo, cDescripcion
			--FROM bdiatmist:"informix".atm_tipo_reposicion
			FROM bdiatmist@stag_ids1170:"informix".atm_tipo_reposicion
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iTipo, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTipo, cDescripcion;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Tipo de Reposicion para llenado de combo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)							
		RETURNING CHAR(5) AS codret,
			CHAR(19) AS tarjeta_sustituir,
			CHAR(19) AS tarjeta_sustituta,
			CHAR(5) AS fecha_expira;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDisponibles INTEGER;
	DEFINE cTarjetaSustituir CHAR(19);
	DEFINE cTarjetaSutituta CHAR(19);
	DEFINE cBin CHAR(10);	
	DEFINE cTotalRango CHAR(4);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	DEFINE cFechaExp CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iTotalDisponibles = 0;
	LET cTarjetaSustituir = '';
	LET cTarjetaSutituta = '';
	LET cBin = '';		
	LET cTotalRango = pTotalRango;
	LET cDe = ''; 
	LET cHasta = '';	
	LET cFechaExp = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;					
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;		
		
		--OBTENER VALOR DE CODIGO BIN
		SELECT valor
	        INTO cBin
		--FROM  bdiatmist:"informix".atm_param 
		FROM  bdiatmist@stag_ids1170:"informix".atm_param 
		WHERE cod_param = 1;
		
		LET pRangoDe = TRIM(cBin) || pRangoDe;
		LET pRangoHasta = TRIM(cBin) || pRangoHasta;
		
		LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
		LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
		
		-- VALIDACION QUE EXISTAN TARJETAS PARA REALIZAR REPOSICION	
		SELECT COUNT(*) 
			INTO iTotalDisponibles
		---FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE estatus = 'ENT';
		
		SELECT COUNT(*) 
			INTO cTotalRango
		--FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE numtarjetadmin 
		BETWEEN cDe AND cHasta	
		AND numtarjetasustituta = ''
		AND estatus <> 'ENT';
		
		IF iTotalDisponibles <  cTotalRango THEN 
			LET cCodRet = '00891';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
		
		--REALIZO SOLO LA CONSULTA A atm_tarjeta_admin
		IF pOperacion = 1  THEN
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
						INTO cTarjetaSustituir, cFechaExp
					--FROM  bdiatmist:"informix".atm_tarjeta_admin  
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND estatus IN ('SOL','ACT')
					AND numtarjetasustituta = ''
					ORDER BY numtarjetadmin											
				FOREACH cTarjetaSustituir FOR			
					SELECT numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT' 						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC														
				END FOREACH; 
			
				LET iNoRegistros = iNoRegistros + 1;
			
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;
			END FOREACH;				
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			END IF;	
		END IF;
	
		--Realiza actualizacion de Estatus 
		IF pOperacion = 2 THEN			
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
					INTO cTarjetaSustituir, cFechaExp
				--FROM  bdiatmist:"informix".atm_tarjeta_admin
                  FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin  				
				WHERE numtarjetadmin 
				BETWEEN cDe AND cHasta 
				AND estatus IN ('SOL','ACT')
				AND numtarjetasustituta = ''
				ORDER BY numtarjetadmin									
				
				FOREACH cTarjetaSustituir FOR					
					SELECT  numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT'						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC
					
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin  
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					SET fechacancelacion = CURRENT,
						numtarjetasustituta = cTarjetaSutituta,
						estatus = 'CAN',							
						descripcion_coment = pComentario
					WHERE numtarjetadmin =	cTarjetaSustituir;																	
				END FOREACH; 
				
				FOREACH 
					SELECT  numtarjetasustituta	
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin
                    FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 					
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND numtarjetasustituta IS NOT NULL
					AND numtarjetasustituta <> ''
					AND estatus = 'CAN'   
				
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
					SET  estatus = 'ACT'
					WHERE numtarjetadmin = cTarjetaSutituta
					AND numtarjetasustituta = ''
					AND estatus = 'ENT';	
				END FOREACH;									
	
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;				
			
			END FOREACH;	
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que realiza Consulta para Reposicion de Tarjetas',	
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp para realizar sustitucion de tarjetas con tarjetas con estatus ENT',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1))							
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS num_porasignar;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegPorAsignar INTEGER;
	DEFINE cStatus CHAR(3);
    DEFINE cNumeroTarjeta CHAR(3);	
	DEFINE dFecha DATE;
	DEFINE cBin CHAR(10);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegPorAsignar = 0;
	LET cBin = '';		
	LET cDe = ''; 
	LET cHasta = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion_totales.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pOperacion = 1 THEN	
		
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
           -- FROM bdiatmist:"informix".atm_tarjeta_admin;  
		     FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin;  
		
		ELIF pOperacion = 2 THEN 
		
			--OBTENER VALOR DE CODIGO BIN
			SELECT valor
			INTO cBin
			--FROM bdiatmist:"informix".atm_param 
			FROM bdiatmist@stag_ids1170:"informix".atm_param 
			WHERE cod_param = 1;
		
			LET pRangoDe = TRIM(cBin) || pRangoDe;
			LET pRangoHasta = TRIM(cBin) || pRangoHasta;
			LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
			LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
			
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			INTO iNoRegistros, iNoRegPorAsignar
			--FROM bdiatmist:"informix".atm_tarjeta_admin
			FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE numtarjetasustituta = '' AND numtarjetadmin 
			BETWEEN cDe AND cHasta; 
			
		END IF;			 				
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00000';
			LET iNoRegistros = 0;
			LET iNoRegPorAsignar = 0;
		END IF;	
		
		RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Totales de Tarjetas Administrativas',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_portanom_obtieneruta(pUsuario CHAR(8), pIdFuncion CHAR(10), pOperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(50) AS ruta_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRutaArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_obtieneruta.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		IF pOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_obtrutasportabilidad(pOperacion)
		INTO cCodRetSp, cRutaArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP ";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00044';
		END IF;
		
		RETURN cCodRet, cRutaArchivo;
	
	END;
	
END PROCEDURE;