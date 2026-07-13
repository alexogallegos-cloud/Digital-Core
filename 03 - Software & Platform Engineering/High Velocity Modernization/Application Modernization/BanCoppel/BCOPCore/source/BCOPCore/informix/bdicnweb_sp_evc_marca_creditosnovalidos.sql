CREATE PROCEDURE "informix".sp_evc_marca_creditosnovalidos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))

RETURNING CHAR(5) AS codret;
-- Control de Cambios
-----------------------------------------------------------------------------------
----Marco Valenzuela
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);
DEFINE iSqlErr INT;
DEFINE dFechaRep DATE;
DEFINE cNumCredito	CHAR(20);
DEFINE cMotivo	CHAR(1);
DEFINE iNumLote INTEGER;
DEFINE iLote INTEGER;
DEFINE iNumReg INTEGER;
DEFINE cStatus	CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "00000";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";
LET iSqlErr = 0;
LET dFechaRep = DATE(1);
LET cNumCredito = '';
LET cMotivo = '';
LET iNumLote = 0;
LET iLote = 0;
LET iNumReg = 0;
LET cStatus = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
	--Sacando fecha del ultimo reporte
	Select max(fechareporte) INTO dFechaRep
	from bdicobranza:cb_rep_cart_quebrantar;

	--Sacando el ultimo lote generado
	Select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)}
	max(lote) INTO iNumLote
	from bdicnweb:sw_evc_excluidos
	where lote<>'0';
	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

	IF trim(cCodRet) <> "00000" THEN
		RETURN trim(cCodRet);
	END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

----SET DEBUG FILE TO "/informix/marcov/sp_evc_marca_creditosnovalidos.out";
----TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
set isolation to dirty read;
	FOREACH
		SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} a.cuenta, a.motivo, a.lote, a.id_registro,a.status
		INTO cNumCredito, cMotivo, iLote, iNumReg, cStatus
		FROM bdicnweb:sw_evc_excluidos a
		WHERE a.lote = iNumLote
		
		
		
		IF cNumCredito IN (select num_credito from bdicred:sd_maecred where status_cred = 'CV') 
			OR cNumCredito IN (select num_credito from bdicred:sd_maecredcrd where status_cred = 'CV') THEN

			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Vendido',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
			
		ELIF cNumCredito IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where nvl(excluido, '') <> '' and FechaReporte = dFechaRep ) THEN
		
			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Ya Excluido',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
		
		ELIF cNumCredito NOT IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where FechaReporte = dFechaRep ) THEN	
			
			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito No Existe',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
			
			
		ELIF iNumReg NOT IN(SELECT MAX(id_registro) FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta) AND cStatus <> 'P' THEN

			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Repetido',
			status = 'E'
			WHERE cuenta = cNumCredito
			AND id_registro NOT IN(SELECT MAX(id_registro) FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta) AND cStatus <> 'P';
			
		END IF;
		
	END FOREACH;	
		
 
RETURN trim(cCodRet);
END;
 
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para actualizar con estatus E y poner motivo de rechazo, a los créditos no validos por no pasar los filtros de validación en la carga masiva',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 27/Sep/2013',
'BD    : BDICNWEB';

CREATE PROCEDURE "informix".sp_reversocargomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(6);
	DEFINE cFolioGen	CHAR(16);
	DEFINE dFechaProc	DATETIME YEAR TO FRACTION;
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	DEFINE cResultadoSp	CHAR(100);
	DEFINE cResultado	CHAR(15);
	DEFINE iIdRegistro	INTEGER;
	DEFINE cStatus		CHAR(1);
	DEFINE wBegin		SMALLINT;
	DEFINE iReversar 	SMALLINT;
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	DEFINE iTotalRegs	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE iTotalRever	INTEGER;
	DEFINE iTotNoRever	INTEGER;
	
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cFolioGen = '';
	LET cResultado = '';
	LET dFechaProc = NULL;
	LET iIdRegistro	= 0;
	LET iNoRegs = 0;
	LET cStatus = '';
	LET cResultadoSp = '';
	LET wBegin = 0;
	LET iReversar = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535)
			LET wBegin = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenmos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:sw_tr_cargamasiva_cargo_hist
		WHERE lote = pLote;
		
		BEGIN;
			UPDATE   bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se coloca el estatus de todos los movimientos para ser reversados
		BEGIN;
			UPDATE {+INDEX (bdicnweb:sw_tr_cargamasiva_cargo_hist idx_status)} bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'R'
			WHERE status = 'S';
		COMMIT;
		
		-- Se recorre el lote
		FOREACH WITH HOLD SELECT id_registro, folio
			INTO iIdRegistro, cFolioGen
			FROM bdicnweb:sw_tr_cargamasiva_cargo_hist
			WHERE lote = pLote AND status = 'R'
			
			BEGIN;
				EXECUTE PROCEDURE bdicred:"informix".sp_grabarreversocargosmasivos(cFolioGen)
				INTO cCodRetSp, cResultadoSp;
			COMMIT;
			
			IF cCodRetSp <> '000000' THEN
				LET cResultado = 'NO REVERSADO';
				LET cStatus = 'S';
			ELIF cCodRetSp = '000000' THEN
				LET cResultado = 'REVERSADO';
				LET cStatus = 'R';
			END IF;
				
			BEGIN;	
				UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
				SET fecha_reverso = dFechaProc,
					resultado_reverso = cResultado,
					codret_reverso = cCodRetSp,
					status = cStatus,
					comentario_reverso = cResultadoSp
				WHERE lote = pLote AND id_registro = iIdRegistro;
				
				LET iNoRegs = iNoRegs + 1;
			COMMIT;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizamos los estatus a inactivos
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'I'
			WHERE codret_reverso <> '000000'
				AND lote = pLote;
		COMMIT;
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'I'
			WHERE codret_reverso = '000000'
				AND lote = pLote;
		COMMIT;
			
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'S', resultado = 'APLICADO'
			WHERE lote = pLote AND status = 'NP';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'T'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_constotalesreversocargocre(pUsuario, pIdFuncion, pLote)
		INTO cCodRetSp, iTotalRegs, mTotalMonto, iTotalRever, iTotNoRever;
		
		IF cCodRetSp <> '00000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, iNoRegs;
		END IF;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
					
		IF wBegin = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el reverso de un lote masivo de cargo de credito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_sw_ro_consctesimgsctas(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT)
	RETURNING CHAR(5) AS codret,
			INT AS id_cliente,
			CHAR(164) AS nombre
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iIdCte INT;
	DEFINE cNombreCte CHAR(164);
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET iIdCte = 0;
	LET cNombreCte = '';
	LET iNoRows = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdCte, cNombreCte;
			END IF;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''OR pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} COUNT(*)
		INTO iNoRows
		FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1');
		IF iNoRows = 0 THEN
			LET cCodRet = '00111';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		LET iNoRows = 0; 
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} b.id_resulcte, TRIM(TRIM(a.nombre1)||' '||
										TRIM(a.nombre2)||' '||
										TRIM(a.apell_paterno)||' '||
										TRIM(a.apell_materno)||' '||
										TRIM(a.razon_social)) AS nombre
			INTO iIdCte, cNombreCte
			FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1')
			LET iNoRows = iNoRows + 1;
			RETURN cCodRet, iIdCte, cNombreCte WITH resume;
		END FOREACH;
		IF iNoRows = 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
	END
END PROCEDURE;