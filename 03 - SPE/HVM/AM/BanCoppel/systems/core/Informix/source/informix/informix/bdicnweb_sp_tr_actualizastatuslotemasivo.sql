CREATE PROCEDURE "informix".sp_tr_actualizastatuslotemasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2), pIdLote INTEGER, pUsarHistorico CHAR(1))
        RETURNING
                CHAR(5) AS codret,
                INT AS exitosos;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExitosos INT;
        DEFINE cBaseDatos CHAR(50);
        DEFINE cTablaDst CHAR(50);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iExitosos = 0;
        LET cBaseDatos = '';
        LET cTablaDst = '';

        BEGIN
			ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iExitosos;
				END IF;
			END EXCEPTION;

			IF pUsuario = '' OR pIdFunciON = '' OR pStatus = '' OR pIdLote IS NULL OR pUsarHistorico = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iExitosos;
			END IF;
			
			IF pUsarHistorico NOT IN ('0', '1') THEN
				LET cCodRet = '00102';
				RETURN cCodRet, iExitosos;
			END IF;

			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iExitosos;
			END IF;

			SET ISOLATION TO DIRTY READ;
			SELECT base_datos, tabla
			INTO cBaseDatos, cTablaDst
			FROM sw_tr_info_tablas WHERE id_funcion = pIdFuncion;           

			IF cBaseDatos IS NULL OR cBaseDatos = '' THEN
				LET cCodRet = '00154';
				RETURN cCodRet, iExitosos;
			END IF;
			
			IF pUsarHistorico = '1' THEN
				LET cTablaDst = TRIM(cTablaDst)||'_hist';
			END IF;
			
			EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status = '"|| TRIM(pStatus) ||"' WHERE id_lote = " || pIdLote;
			LET iExitosos = DBINFO('sqlca.sqlerrd2');
			
			RETURN cCodRet, iExitosos;
        END

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2015',
'DESCRIPCION: Actualiza el estatus de un lote completo, para el uso en procesos masivos';

CREATE PROCEDURE "informix".sp_validacodigoproveedorcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodProveedor CHAR(4))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_validacodigoproveedorcaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodProveedor = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet; 
			END IF;
		 
			-- VALIDA CÃDIGO
			IF EXISTS (SELECT cod_proveedor FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pCodProveedor) THEN
				LET cCodRet = '00466'; --NO SE PERMITEN CÃDIGOS DE CAJA GENERAL DUPLICADOS EN UNA MISMA PLAZA
				RETURN cCodRet;		
			ELSE 
				RETURN cCodRet;	
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/03/2015',
'DESCRIPCION: SPL que valida que el cÃ³digo de proveedor no se encuentre duplicado dentro de una misma plaza.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportemensualremesasac(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5))
	RETURNING
		CHAR(5) AS codigoRetorno,
		INTEGER AS dia,
		INTEGER AS totOperaciones, 
		MONEY(16,2) AS monto;

	DEFINE cCodRet CHAR(5);
	DEFINE iDia INTEGER;
	DEFINE iTotOperaciones INTEGER;
	DEFINE mMonto MONEY(16,2);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE cNumConvenio CHAR(3);
	DEFINE iNumRows INTEGER;
	
	LET cCodRet = '00000';
	LET iDia = 0;
	LET iTotOperaciones = 0;
	LET mMonto = 0;
	LET iRegistros = 0;
	LET cNumConvenio = '';
	LET iNumRows = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportemensualremesasac.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pPeriodo = '' OR pConvenio = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iDia, iTotOperaciones, mMonto;
			END IF;
		
		IF pConvenio = '07004' THEN
			LET cNumConvenio = '004';
		ELIF pConvenio = '07006' THEN
			LET cNumConvenio = '006';
		ELIF pConvenio = '07007' THEN
			LET cNumConvenio = '007';
		ELIF pConvenio = '07008' THEN
			LET cNumConvenio = '008';
		END IF;		
		
		SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_movimientoshistorial
		WHERE MONTH(Fecha_Pago) = MONTH(pPeriodo)
		AND YEAR(Fecha_Pago) = YEAR(pPeriodo)
		AND NumConvenio = cNumConvenio
		AND status_cancelado = 'N';
		IF iNumRows <> 0 THEN
			IF pConvenio = '07004' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_mensual(pPeriodo)
					INTO iDia, iTotOperaciones, mMonto
					RETURN cCodRet, iDia, iTotOperaciones, mMonto WITH RESUME;
				END FOREACH;
			ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_mensual(pPeriodo, pConvenio)
					INTO iDia, iTotOperaciones, mMonto
					RETURN cCodRet, iDia, iTotOperaciones, mMonto WITH RESUME;
				END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR Esparza Brenis Fernando Martin';

CREATE PROCEDURE "informix".sp_procesarsolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pTipoMotivo SMALLINT)
		RETURNING CHAR(5) AS codret,
				CHAR(80) AS nombre_atiende;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreAtiende CHAR(80);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreAtiende = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreAtiende;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_procesarsolicitudmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pTipoMotivo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreAtiende;
		END IF;
		
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreAtiende;
		END IF;
		
		BEGIN WORK;
		-- BLOQUEO DE TABLA
		SET LOCK MODE TO WAIT;
		SET ISOLATION TO COMMITTED READ;
		
--		-- SE CONSULTA LA SOLICITUD
		EXECUTE FUNCTION bdicnweb:'informix'.sp_consultasolicitudprocesomc (pUsuario, pIdFuncion, pNumCliente)
		INTO cCodRetSp, cNombreAtiende;
        
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_solicitudprocesandomc';
		ELIF iCodRetSp = 0 THEN
		
			SET LOCK MODE TO WAIT;
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_solicitudprocesandomc(pUsuario, pIdFuncion, pNumCliente, pTipoMotivo)
			INTO cCodRetSp, cNombreAtiende;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				IF iCodRetSp = -268 THEN
					SELECT nombre
					INTO cNombreAtiende
					FROM bdinteg:'informix'.si_ejecut
					WHERE ejecutivo = (SELECT usuario FROM bdisolic:ss_cte_procesando WHERE numcte = pNumCliente);
					
					LET cCodRet = '90000';
				ELSE
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_solicitudprocesandomc';
				END IF;
			ELSE
				LET cCodRet = cCodRetSp;
			END IF;
		ELSE
			LET cCodRet = cCodRetSp;
		END IF;
		
		COMMIT WORK;
		
		IF bInTransaction THEN
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, cNombreAtiende;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 20/05/2015',
'MODULO: Mesa de Control',
'FUNCIONALIDAD: Monior de solicitudes/Cambio de estatus',
'DESCRIPCION: Consulta y bloquea la solicitud para un usuario',
'FECHA: 16/06/2015',
'DESCRIPCION: Se establecen un modo de bloqueo de las tablas hasta que los datos sean comprometidos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultasolicitudprocesomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
        RETURNING CHAR(5) AS codret,
                        CHAR(45) AS nombre_ejecutivo;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cEjecutivo CHAR(8);
        DEFINE cNombreEjecutivo CHAR(45);
        DEFINE iNoRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cEjecutivo = '';
        LET cNombreEjecutivo = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNombreEjecutivo;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultasolicitudprocesomc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                -- BORRA REGISTROS DEL USUARIO
                DELETE FROM bdisolic:ss_cte_procesando where usuario = pUsuario;
                
                -- DESBLOQUEO DE LAS SOLICITUDES TRABAJADAS POR EL ANALISTA QUE QUEDAON BLOQUEADAS POR ERRROR
                UPDATE bdisolic:ss_solicitudes_mc
                SET ejecutivo_atiende = ''
                WHERE ejecutivo_atiende = pUsuario
                        AND status_fin = ''
                        AND revisado <> 'S';
                
                -- CONSULTAMOS EL NUMERO DE SOLICITUD
                SELECT usuario
                INTO cEjecutivo
                FROM bdisolic:ss_cte_procesando
                WHERE numcte = pNumCliente;
                
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                IF iNoRegistros > 0 THEN
                        SELECT nombre
                        INTO cNombreEjecutivo
                        FROM bdinteg:'informix'.si_ejecut
                        WHERE ejecutivo = cEjecutivo;
                        
                        LET cCodRet = '90000';
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                RETURN cCodRet, cNombreEjecutivo;
                
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 18/12/2013",
"DESCRIPCION: Revisa que una solicitud no este siendo ya atendida por otro ejecutivo",
"AUTOR: Oscar Flores Conde",
"FECHA: 16/06/2015",
"DESCRIPCION: Se elimina la lectura sucia para manejo de la concurrencia",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_reportetraspasoctabeneficencia( pUsuario         CHAR(8), 
                                                               pIdFuncion       CHAR(10), 
                                                               pIdFuncionPadre  CHAR(10), 
                                                               pFechaInicio     DATE, 
                                                               pFechaFin        DATE, 
                                                               pArchivoDescarga CHAR(255) )
RETURNING CHAR(5) AS codret,
          INTEGER AS no_registros;
    
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE cCodRetSp CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE iNoRegistros INTEGER;
    DEFINE vsql CHAR(500);
    DEFINE vstmt CHAR(300);

    LET cCodRet = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET cCodRetSp = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
    LET iNoRegistros = 0;
    LET vsql = '';
    LET vstmt = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/sp_reportetraspasoctabeneficencia.err'; 
        TRACE ON;
        LET cCodRet = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet, iNoRegistros;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/sp_reportetraspasoctabeneficencia.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchivoDescarga = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
    EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- // VALIDA QUE HAYA REGISTROS POR DESCARGAR
    SELECT COUNT(*)
      INTO iNoRegistros
      FROM bdicheq:sc_cuentas_traspbenef
     WHERE fecha_traspaso BETWEEN pFechaInicio AND pFechaFin;
     
    IF iNoRegistros = 0 THEN
        LET cCodRet = '00017';
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- // GENERA ARCHIVO DE DESCARGA
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchivoDescarga)||' '||
               'SELECT * FROM sc_cuentas_traspbenef WHERE fecha_traspaso BETWEEN '''||pFechaInicio||''' AND '''||pFechaFin||''';" > /tmp/ctastraspbenef.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /tmp/ctastraspbenef.sql"; 
    SYSTEM vstmt;    
    
    -- Ejecución del SP para la carga de los encabezados
    EXECUTE PROCEDURE bdicnweb:sp_obtieneencabezadomasivo(pIdFuncionPadre, pArchivoDescarga) 
    INTO cCodRetSp;
    
    IF cCodRetSp::INTEGER < 0 THEN
        RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
    END IF;
    
    IF cCodRetSp::INTEGER > 0 THEN
        RETURN cCodRetSp, iNoRegistros;
    END IF;
    
    RETURN cCodRet, iNoRegistros;
            
    END;
        
END PROCEDURE 
    
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/03/2015',
'DESCRIPCION: Generacion de reporte de cuentas transferidas a la beneficencia publica',
'MODULO: Debito',
'FUNCIONALIDAD: Traspaso a beneficencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_bancoctaclabe( pUsuario CHAR(8), pIdFuncion CHAR(10), pCtaClabe CHAR(18) )
RETURNING CHAR(5) AS codret,
		  CHAR(25) AS descCortaBanco,
		  INTEGER AS cvecesif;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreCorto CHAR(25);
	DEFINE iCveCeSif INTEGER; 
	DEFINE cCodCtaCbe CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cNombreCorto = '';
	LET iCveCeSif = 0;
	LET cCodCtaCbe ='';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr
        LET cCodRet = iSqlErr;
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/mfinis/sp_valida_bancoctaclabe.out';
    --- TRACE ON;
    
    IF pUsuario = '' OR pIdFuncion = '' OR  pCtaClabe = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END IF;
    
    EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END IF;
    
    LET cCodCtaCbe = SUBSTRING(pCtaClabe FROM 1 FOR 3);
    
    SELECT vchrnombrecorto, cvecesif 
      INTO cNombreCorto, iCveCeSif 
      FROM bdinteg:si_bancos 
     WHERE banco = cCodCtaCbe;
    
    IF DBINFO('sqlca.sqlerrd2')= 0 THEN
        LET cCodRet = '00431';
    END IF;
    
    RETURN cCodRet, cNombreCorto, iCveCeSif;
    
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 23/02/2014',
'DESCRIPCION: valida si existe el banco en tabla respecto a la cuenta clabe',
'MODULO: Traspaso a Cta Beneficiencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteestadocuentasac_pba(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE, pConvenio CHAR(5), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING
		CHAR(5)  AS codRetorno,
		CHAR(10) AS fecha, 
		CHAR(14) AS saldoInicial,
		CHAR(10) AS totalAbonos,
		CHAR(14) AS montoTotalAbonos,
		CHAR(10) AS totalCargos,
		CHAR(14) AS montoTotalCargos,
		CHAR(14) AS saldoFinal,
		CHAR(20) AS cuentaConcentradora,
		CHAR(18) AS cuentaClabe;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFecha CHAR(10);
	DEFINE cSaldoInicial CHAR(14);
	DEFINE cTotalAbonos CHAR(10);
	DEFINE cMontoTotalAbonos CHAR(14);
	DEFINE cTotalCargos CHAR(10);
	DEFINE cMontoTotalCargos CHAR(14);
	DEFINE cSaldoFinal CHAR(14);
	DEFINE cCtaConcentradora CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = "00000";
	LET cCodRetSp = "";
	LET iSqlErr = 0;
	LET cFecha = "";
	LET cSaldoInicial = "";
	LET cTotalAbonos = "";
	LET cMontoTotalAbonos = "";
	LET cTotalCargos = "";
	LET cMontoTotalCargos = "";
	LET cSaldoFinal = "";
	LET cCtaConcentradora = "";
	LET cCtaClabe = "";	
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
	LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/mfinis/bdicnweb/sac/sp_reporteestadocuentasac2.out";
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pConvenio = '' OR pRegistros = '' OR pRecuperacion = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
		
		IF pConvenio = '07004' THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_edocta(pFechaIni, pFechaFin)
			INTO cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, cCodRetSp
				IF cCodRetSp = '0' THEN
					IF iRegistros >=  pRegistros THEN
						IF  iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN  cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
				END IF;
			END FOREACH;
		ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN  -- CONVENIO
			FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_edocta(pFechaIni, pFechaFin,  pConvenio)
			INTO cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, cCodRetSp
				IF cCodRetSp = '0' THEN
					IF iRegistros >=  pRegistros THEN
						IF  iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
				END IF ;
			END FOREACH;
		END IF;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Convenios 07004 GENERA REPORTE DE ESTADO DE CUENTA, 707006,07007,07008 GENERA REPORTE DE ESTADO DE CUENTA PARA WU',
'Fecha: 2013/12/12';

CREATE PROCEDURE "informix".sp_gs_notificacioncorreoelectronico(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcionEnvio CHAR(1), pTipoOperacion SMALLINT, pIdSolicitud INTEGER, pPlantilla CHAR(10), pTitulo CHAR(60))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cJefeAreaUsuarioSolic CHAR(8);
	DEFINE cUsuarioSolic CHAR(8);
	DEFINE cUsuarioResponsable CHAR(8);
	DEFINE iIdAreaResponsable INTEGER;
	DEFINE cJefeUsuarioResponsable CHAR(8);
	DEFINE iIdSolicitudAnterior INTEGER;
	
	-- VARIABLES PARA EL SP DE NOTIFICACIÃ?N
	DEFINE cTipoMsj CHAR(1);
	DEFINE cIdMsj CHAR(10);
	DEFINE cNumclt CHAR(20);
	DEFINE cNumcta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cTipoproc CHAR(1);
	DEFINE cStr1 CHAR(30);
	DEFINE cStr2 CHAR(30);
	DEFINE cStr3 CHAR(30);
	DEFINE cStr4 CHAR(30);
	DEFINE cStr5 CHAR(150);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(15);
	DEFINE cStr10 CHAR(100);
	DEFINE cCorreoAlterno CHAR(100);
	DEFINE cCelularAlterno CHAR(10);
	DEFINE mImporte1 MONEY(16,2);
	DEFINE mImporte2 MONEY(16,2);
	DEFINE mImporte3 MONEY(16,2);
	DEFINE mImporte4 MONEY(16,2);
	DEFINE mImporte5 MONEY(16,2);
	DEFINE dFecha1 DATETIME YEAR TO FRACTION(3);
	DEFINE dFecha2 DATETIME YEAR TO FRACTION(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cJefeAreaUsuarioSolic = '';
	LET cUsuarioSolic = '';
	LET cUsuarioResponsable = '';
	LET iIdAreaResponsable = 0;
	LET cJefeUsuarioResponsable = '';
	LET iIdSolicitudAnterior = 0;
	-- VARIABLES DEL SP DE NOTIFICACIÃ?N
	LET cTipoMsj = '1';
	LET cIdMsj = pPlantilla;
	LET cNumclt = '';
	LET cNumcta = '';
	LET cNumTarjeta = '';
	LET cTipoproc = '1';
	LET cStr1 = '';
	LET cStr2 = '';
	LET cStr3 = '';
	LET cStr4 = '';
	LET cStr5 = '';
	LET cStr6 = '';
	LET cStr7 = pTitulo;
	LET cStr8 = '';
	LET cStr9 = '';
	LET cStr10 = '';
	LET cCorreoAlterno = '';
	LET cCelularAlterno = '';
	LET mImporte1 = 1;
	LET mImporte2 = 0.00;
	LET mImporte3 = 0.00;
	LET mImporte4 = 0.00;
	LET mImporte5 = 0.00;
	LET dFecha1 = NULL;
	LET dFecha2 = NULL;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_notificacioncorreoelectronico.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pPlantilla = '' OR pIdSolicitud IS NULL OR pTitulo = '' OR pOpcionEnvio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pOpcionEnvio NOT IN ('S', 'R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		
		IF pOpcionEnvio = 'S' THEN
			IF pTipoOperacion IN (1, 3, 4) THEN -- ENVIO DE SOLICITUD, REINTENTO, CANCELACIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					EXTEND(fecha_solicitud, hour to second) as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (1, 3, 4) THEN
			
				FOREACH SELECT usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
			
		ELIF pOpcionEnvio = 'R' THEN
			IF pTipoOperacion IN (4,5) THEN -- CANCELACIÃ?N O ATENCIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (4,5) THEN
			
				FOREACH SELECT usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/08/2014',
'DESCRIPCION: pTipoOperacion = 1: Envio de solicitud; 2: ReasignaciÃ³n de solicitud, 3: Reintento, 4: Cancelacion, 5: Atencion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteconciliacionconveniosucursal_pba(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno,
	CHAR(4) AS idsucursal,
	INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importepago, 
	MONEY(16,2) AS importecomisionconvenio,
	MONEY(16,2) AS ivacomisionconvenio, 
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS iva_comisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cIdSucursal CHAR(5);
	DEFINE cNumPagos INTEGER; 
	DEFINE cNomconvenio CHAR(40); 
	DEFINE mImportePago MONEY(16,2); 
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cIdSucursal = '';
	LET cNumPagos = 0;
	LET cNomconvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteconciliacionconveniosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_sacreporteconciliacionconveniosucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF 	NVL(cIdSucursal, '') = '' AND 
				NVL(cNumPagos, '') = '' AND 
				NVL(cNomconvenio, '')  = '' AND 
				NVL(mImportePago, '') = ''  AND 
				NVL(mImporteComisionConvenio, '') = '' AND
				NVL(mIvaComisionConvenio, '') = '' AND 
				NVL(mImporteComisionCte, '') = '' AND 
				NVL(mIvaComisionCte,'') = '' AND 
				NVL(iFlagConfirmacionCentral,'') = '' AND 
				NVL(iFlagConfirmacionSucursal,'') = '' THEN
				
				LET cCodRet = '00017';
				RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
			ELSE
				IF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte,
					iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio,
							mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		 IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR:Esparza Brenis Fernando Martin",
"FECHA: 12/12/2013",
"DESCRIPCION: SP para el reporte de conciliaciÃ³n por convenios",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_reversioncap_pba(pUsuario char(10), 
					    pIdFuncion char(10), 
					    pFolioMovimiento char(16), 
					    pSucursalFolio char(4),
						pTransacc char(4))
       RETURNING char(5) as codret;
	
DEFINE cCodRet char(5);
DEFINE cConstante char(1);
DEFINE cEmpresa char(3);
DEFINE iSqlErr int;
DEFINE cReversable char(1);
	
LET cCodRet = '00000';
LET cConstante = 'M';
LET cEmpresa = '001';
LET iSqlErr = 0;
LET cReversable = '';
	
BEGIN
		
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;


	IF pUsuario = ''
	 OR pIdFuncion = '' 
	 OR pFolioMovimiento = '' 
	 OR pSucursalFolio = ''  
	 OR pTransacc = ''
	THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
		
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, 
							               pIdFuncion) 
		INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	-- Validacion de la transaccion para ver si puede ser reversable
	SELECT reversable
	INTO cReversable
	FROM bdinteg:"informix".si_transacc
	WHERE numero = pTransacc;

	IF cReversable IS NULL OR cReversable='' THEN
		LET cReversable='N';
	END IF;
	
	IF cReversable <> "S" THEN
		LET cCodRet = '00152'; -- No se permite realizar un reverso de esta transaccion
		RETURN cCodRet;
	END IF;
		
	EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, 
					    		pSucursalFolio, 
					    		pUsuario, 
					    		pFolioMovimiento, 
					    		cConstante) 
		INTO cCodRet;
		
	IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '170' THEN
		LET cCodRet = '00112';
	END IF;
	IF cCodRet = '413' THEN
		LET cCodRet = '00113';
	END IF;
	IF cCodRet = '00036' THEN
		LET cCodRet = '00003';
	END IF;
	IF cCodRet = '00030' THEN
		LET cCodRet = '00114';
	END IF;
	IF cCodRet = '00037' THEN
		LET cCodRet = '00115';
	END IF;
	IF cCodRet = '00035' THEN
		LET cCodRet = '00116';
	END IF;
	IF cCodRet = '001' THEN
		LET cCodRet = '00117';
	END IF;
		
	RETURN cCodRet;
		
END;

END PROCEDURE;