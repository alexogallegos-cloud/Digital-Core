CREATE PROCEDURE "informix".sp_obtenerconceptocargomanualescre(pUsuario CHAR(8), pIdFuncion CHAR(10), pConceptoPago CHAR(2), pTransaccion CHAR(4))
	returning CHAR(5) AS codret,
				CHAR(2) AS codigo_pago,
				CHAR(50) AS descripcion,
				CHAR(4) AS transaccion;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCodPago CHAR(2);
	DEFINE cDescricpion CHAR(50);
	DEFINE cTransaccion CHAR(4);
	DEFINE iSqlErr int;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cCodPago = '';
	LET cDescricpion = '';
	LET cTransaccion = '';
	LET iSqlErr = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodPago, cDescricpion, cTransaccion;
		END EXCEPTION;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodPago, cDescricpion, cTransaccion;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodPago, cDescricpion, cTransaccion;
		END IF;

		FOREACH EXECUTE PROCEDURE bdicred:sp_obtenerconceptocargomanuales(pConceptoPago, pTransaccion)
			INTO cCodRetSP, cCodPago, cDescricpion, cTransaccion

			IF cCodRetSP <> '00000' THEN
				LET cCodRet = cCodRetSP;
				RETURN cCodRet, cCodPago, cDescricpion, cTransaccion;
			END IF;

			RETURN cCodRet, cCodPago, cDescricpion, cTransaccion WITH resume;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 02/07/2013",
"DESCRIPCION: Sp qiue consulta los conceptos de cargos para una cuenta de credito";

CREATE PROCEDURE "informix".sp_obtienesiguientelote(pIdUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			INT AS lote;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iLote INT;
	DEFINE iSqlErr INT;
	
	LET cCodRet = '00000';
	LET iLote = 0;
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iLote;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT folio
		INTO iLote
		FROM sw_tr_foliador_lotes
		WHERE id_funcion = pIdFuncion;
		
		IF iLote IS NULL THEN
			LET cCodRet = '00153'; -- La funcionalidad no usa lotes
			RETURN cCodRet, iLote;
		ELSE
			LET iLote = iLote + 1;
			
			-- Actualizamos el lote
			UPDATE sw_tr_foliador_lotes
			SET folio = iLote
			WHERE id_funcion = pIdFuncion;
			
			RETURN cCodRet, iLote;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 06/06/2013",
"Descripcion: Consulta el ultimo folio asignado a una funcionalidad";

CREATE PROCEDURE "informix".sp_reportecargoindividualcredito(pIdUsuario CHAR(8), pIdFuncion CHAR(10),pTipoReporte CHAR(6),pReversado CHAR(1),pFech_Ini CHAR(10),pFech_Fin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
 RETURNING
	CHAR(5) AS cod_ret, 
	CHAR(80) AS desc_ret,
	CHAR(100)	As concepto,
	CHAR(20)	AS num_credito,
	CHAR(104)	AS nomcte,	
	MONEY(18,2)	AS importe_cargo,	
	MONEY(18,2)	AS cap_vigente,
	MONEY(18,2)	AS cap_transitorio,
	MONEY(18,2)	AS cap_vencido,
	MONEY(18,2)	AS cap_vdo_noexigible,
	MONEY(18,2) AS capital_total,
	MONEY(18,2)	AS int_vigente,
	MONEY(18,2)	AS iva_intvigente,
	MONEY(18,2)	AS interes_vencido,
	MONEY(18,2)	AS iva_interesvencido,
	MONEY(18,2)	AS int_moratorio,
	MONEY(18,2)	AS iva_intmoratorio,
	DATE		AS fecha_mov,
	CHAR(4)		AS transaccion,	
	CHAR(50)	AS descripcion,	
	CHAR(16) AS folio_grupo, 
	CHAR(3) AS cod_cargo, 
	CHAR(16) AS folio_mov, 
	MONEY(14,2) AS sdo_ant_rev,
	MONEY(14,2) AS sdo_post_rev;
	
	
	DEFINE cCodRetSp	     CHAR(6);
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr           INTEGER;
	DEFINE cMensajeRet       CHAR(80);	
	DEFINE cFolio_Grupo      CHAR(16);
	DEFINE mImporte          MONEY(14,2);
	DEFINE cNum_credito	     CHAR(20);
	DEFINE cCodigo_cargo     CHAR(2);
	DEFINE cDesc_cargo       CHAR(100);
	DEFINE cFolio            CHAR(16);
	DEFINE dFecha_Aplic      DATE;
	DEFINE mSaldoAntRev      MONEY(14,2);
	DEFINE mSaldoPostRev     MONEY(14,2);
	DEFINE cTransaccion 			CHAR(4);
	DEFINE m_cap_vigente			MONEY(18,2);
	DEFINE m_cap_transitorio		MONEY(18,2);
	DEFINE m_cap_vencido			MONEY(18,2);
	DEFINE m_cap_vdo_noexigible		MONEY(18,2);
	DEFINE m_int_vigente			MONEY(18,2);
	DEFINE m_iva_intvigente			MONEY(18,2);
	DEFINE m_interes_vencido		MONEY(18,2);
	DEFINE m_iva_interesvencido		MONEY(18,2);
	DEFINE m_int_moratorio			MONEY(18,2);
	DEFINE m_iva_intmoratorio		MONEY(18,2);
	DEFINE m_capital_anterior		MONEY(18,2);
	DEFINE m_capital_actual		    MONEY(18,2);
	DEFINE cNomCte					VARCHAR(80);
	DEFINE mCapital_total			MONEY(18,2);
	DEFINE cObservaciones			CHAR(200);
	DEFINE iReg              INTEGER;
	DEFINE dtFechaHoy        DATE;	
	DEFINE dFechaIni      DATE;
	DEFINE dFechaFin      DATE;
	DEFINE dFecha_AplicRev   DATE;
	DEFINE cNumcte	   		 CHAR(20);
	DEFINE cObservacionesRev	    CHAR(200);
	
	LET cCodRet = '00000'; 
	LET iSqlErr = 0;
	LET cMensajeRet = "";
	LET cNum_credito = ''; 
	LET cFolio_Grupo = ''; 
	LET mImporte = 0.0; 
	LET cCodigo_cargo = ''; 
	LET cDesc_cargo = ''; 
	LET cFolio = ''; 
	LET dFecha_Aplic = DATE(1); 
	LET mSaldoAntRev   = 0.0; 
	LET mSaldoPostRev   = 0.0; 
	LET cTransaccion = ""; 
	LET m_cap_vigente = 0.0; 
	LET m_cap_transitorio = 0.0; 
	LET m_cap_vencido = 0.0; 
	LET m_cap_vdo_noexigible = 0.0;
	LET m_int_vigente = 0.0;
	LET m_iva_intvigente = 0.0; 
	LET m_interes_vencido = 0.0; 
	LET m_iva_interesvencido = 0.0; 
	LET m_int_moratorio = 0.0; 
	LET m_iva_intmoratorio = 0.0; 
	LET m_capital_anterior = 0.0;
	LET m_capital_actual = 0.0;
	LET cNomCte = ""; 
	LET mCapital_total = 0.0; 
	LET cObservaciones = ''; 
	LET iReg = 0;
	LET dtFechaHoy = DATE(1);
	LET dFechaIni = DATE(1);
	LET dFechaFin = DATE(1);
	LET dFecha_AplicRev = DATE(1);
	LET cNumcte = '';
	LET cObservacionesRev = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		END EXCEPTION;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pTipoReporte='' OR pReversado = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		END IF;
		
		--Se obtiene la fecha del dia
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:sd_fechas
		WHERE empresa = "001";
		
		--Valida si las fechas recibidas son nulas y si lo es asi las iguala a la fecha del dia
		IF NVL(pFech_Ini,'') =  '' THEN
			LET dFechaIni = dtFechaHoy;		
		ELSE
			LET dFechaIni =  pFech_Ini::DATE;
		END IF;
		
		IF NVL(pFech_Fin,'') =  '' THEN
			LET dFechaFin = dtFechaHoy;
		ELSE
			LET dFechaFin =  pFech_Fin::DATE;
		END IF
		
			
		-- valida que la fecha ini no sea mayor que la fecha fin
		IF dFechaIni > dFechaFin THEN
			LET cCodRet='00154';
			LET cMensajeRet = "LA FECHA INICIAL ES MAYOR A LA FECHA FINAL";
			RETURN cCodRet,cMensajeRet ,cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		END IF; 
		-- Valida que la fecha fin no sea mayor que la fecha actual
		IF dFechaFin > dtFechaHoy THEN
			LET cCodRet='00155';
			LET cMensajeRet = "LA FECHA FINAL ES MAYOR A LA FECHA ACTUAL";
			RETURN cCodRet,cMensajeRet , cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		END IF;
		
		IF pTipoReporte = 'Masivo' THEN	
			FOREACH WITH HOLD 		
				SELECT SKIP pRegistros FIRST pRecuperacion folio_grupo, num_credito, importe_cargo, cod_cargo, desc_cargo, folio, fecha_cargo,
						fecha_reverso,cap_total_pos,cap_total_ant
					INTO cFolio_Grupo, cNum_credito, mImporte, cCodigo_cargo, cDesc_cargo, cFolio, dFecha_Aplic,
						dFecha_AplicRev,mSaldoAntRev,mSaldoPostRev
				FROM bdicred:sd_bitacora_cargos
				WHERE reverso =  pReversado 
				AND folio_grupo <> ""
				AND fecha_cargo BETWEEN dFechaIni AND dFechaFin			
				
				IF pReversado = "S" THEN
					LET dFecha_Aplic = dFecha_AplicRev;
				END IF;
				
				LET iReg = iReg + 1;
				RETURN cCodRet,cMensajeRet,  cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
					NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
					NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
					NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
					NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
					NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
			END FOREACH;	
		ELIF pTipoReporte = 'Manual' THEN
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion cod_cargo,desc_cargo,numcte,num_credito,importe_cargo,cap_vig_pos,
						cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos,
						int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant,
						int_mora_ant, iva_int_mora_ant,fecha_cargo, fecha_reverso,observaciones, observaciones_rev, folio,
						cap_total_ant, cap_total_pos
				INTO  cCodigo_cargo,cDesc_cargo,cNumcte, cNum_credito,mImporte,m_cap_vigente,m_cap_transitorio,m_cap_vencido,
						m_cap_vdo_noexigible,mCapital_total,m_int_vigente,m_iva_intvigente,m_interes_vencido,
						m_iva_interesvencido,m_int_moratorio,m_iva_intmoratorio,dFecha_Aplic,dFecha_AplicRev,cObservaciones,cObservacionesRev, cFolio,
						m_capital_anterior, m_capital_actual
				FROM bdicred:sd_bitacora_cargos 
				WHERE reverso = pReversado
				AND folio_grupo = ""
				AND fecha_cargo  BETWEEN dFechaIni AND dFechaFin	
				
				IF pReversado = "S" THEN
					LET cObservaciones = cObservacionesRev;
					LET dFecha_Aplic = dFecha_AplicRev;
				ELIF pReversado = "N" THEN
					LET mSaldoAntRev = m_capital_anterior;
					LET mSaldoPostRev = m_capital_actual;
				END IF;
				
				--se obtiene el nombre del cliente			
				SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
				INTO cNomCte
				FROM bdinteg:si_cliente
				WHERE numcte = cNumcte;
				--se obtiene la transaccion relacionada al concepto
				SELECT transacc
				INTO  cTransaccion
				FROM bdicred:sd_conceptoscargoscredito
				WHERE codigo = cCodigo_cargo;

				LET iReg = iReg + 1;
				RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
					NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
					NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
					NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
					NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
					NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
			END FOREACH;
		END IF;
		
		IF pRegistros = 0 AND iReg = 0 THEN
			LET cCodRet='00151';
			RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		ELIF pRegistros > 0 AND iReg = 0 THEN
			LET cCodRet='1001';
			RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
				NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
				NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
				NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
				NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
				NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/07/2013",
"DESCRIPCION: Procedimiento que consulta los movimientos para el reporte de los cargos Masivos e individuales reversados o no de las cuentas de credito";

CREATE PROCEDURE "informix".sp_consultarreportepagossplcre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), p_FechaIni CHAR(10), p_FechaFin CHAR(10), p_Tipo CHAR(1), p_Folio CHAR(16), pRegistros int, pRecuperacion int)
        RETURNING
        CHAR(5)                 AS COD_RET,
        INTEGER        As reg,
        CHAR(2)                 As Secuencia,
        CHAR(20)                AS num_credito,
        DATE                    AS fecha_mov,
        CHAR(80)                AS nomcte,
        CHAR(4)                 AS sucursal,
        CHAR(4)                 AS num_producto,
        CHAR(16)                AS folio,
        CHAR(50)                AS concepto_mov,
        CHAR(50)                AS desc_pago,
        CHAR(50)                AS desc_rev,
        MONEY(18,2)             AS importe_pago,
        CHAR(4)                 AS transaccion,
        MONEY(18,2)             AS cap_vigente,
        MONEY(18,2)             AS cap_transitorio,
        MONEY(18,2)             AS cap_vencido,
        MONEY(18,2)             AS cap_vdo_noexigible,
        MONEY(18,2)     AS cCapital_total,
        MONEY(18,2)             AS int_vigente,
        MONEY(18,2)             AS iva_intvigente,
        MONEY(18,2)             AS interes_vencido,
        MONEY(18,2)             AS iva_interesvencido,
        MONEY(18,2)             AS int_moratorio,
        MONEY(18,2)             AS iva_intmoratorio,
        MONEY(14,2)             AS sdo_ant_rev,
        MONEY(14,2)     AS sdo_post_rev;

        ---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;        
        DEFINE s_num_credito                    CHAR(20);
        DEFINE d_fecha_mov                              DATE;
        DEFINE s_numcte                                 CHAR(20);
        DEFINE s_sucursal                               CHAR(4);
        DEFINE s_num_producto                   CHAR(4);
        DEFINE s_folio                                  CHAR(16);
        DEFINE s_concepto_mov                   CHAR(50);
        DEFINE s_desc_pago                              CHAR(50);
        DEFINE s_desc_rev                               CHAR(50);
        DEFINE m_importe_pago                   MONEY(18,2);
        DEFINE s_transaccion                    CHAR(4);
        DEFINE m_cap_vigente                    MONEY(18,2);
        DEFINE m_cap_transitorio                MONEY(18,2);
        DEFINE m_cap_vencido                    MONEY(18,2);
        DEFINE m_cap_vdo_noexigible             MONEY(18,2);
        DEFINE m_int_vigente                    MONEY(18,2);
        DEFINE m_iva_intvigente                 MONEY(18,2);
        DEFINE m_interes_vencido                MONEY(18,2);
        DEFINE m_iva_interesvencido             MONEY(18,2);
        DEFINE m_int_moratorio                  MONEY(18,2);
        DEFINE m_iva_intmoratorio               MONEY(18,2);
        DEFINE s_NomCte                                 CHAR(80);
        DEFINE iReg                                             INTEGER;
        DEFINE cFolio1                                  CHAR(16);
        DEFINE cFolio2                                  CHAR(16);
        DEFINE cCapital_total                   MONEY(18,2);
        DEFINE cSecuencia                               CHAR(2);
        DEFINE mSaldoAntRev                     MONEY(14,2);
        DEFINE mSaldoPostRev                    MONEY(14,2);
        DEFINE iExiste                                  SMALLINT;
        DEFINE iNoRegs                                  INTEGER;

        ---INICIALIZACIONES
        LET v_cod_ret                                   = '00000';      
        LET s_num_credito                               = "";
        LET d_fecha_mov                                 = MDY(1,1,1900);
        LET s_numcte                                    = "";
        LET s_sucursal                                  = "";
        LET s_num_producto                              = "";
        LET s_folio                                             = "";
        LET s_concepto_mov                              = "";
        LET s_desc_pago                                 = "";
        LET s_desc_rev                                  = "";
        LET m_importe_pago                              = 0.0;
        LET s_transaccion                               = "";
        LET m_cap_vigente                               = 0.0;
        LET m_cap_transitorio                   = 0.0;
        LET m_cap_vencido                               = 0.0;
        LET m_cap_vdo_noexigible                = 0.0;
        LET m_int_vigente                               = 0.0;
        LET m_iva_intvigente                    = 0.0;
        LET m_interes_vencido                   = 0.0;
        LET m_iva_interesvencido                = 0.0;
        LET m_int_moratorio                     = 0.0;
        LET m_iva_intmoratorio                  = 0.0;
        LET s_NomCte                                    = "";
        LET iReg                                                = 0;
        LET cFolio1                                             = '';
        LET cFolio2                                             = '';
        LET cCapital_total                              = 0.0;
        LET cSecuencia                                  = '';
        LET mSaldoAntRev                                = 0.0; 
        LET mSaldoPostRev                       = 0.0; 
        LET iExiste                                             =0;
        LET iNoRegs = 0;
        
BEGIN

        ON EXCEPTION SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
			END IF;
                
			RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
		END EXCEPTION;

        IF pIdUsuario = '' OR pIdFuncion = '' THEN
                LET v_cod_ret = '00003';
                RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
        
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO v_cod_ret;
                IF v_cod_ret <> '00000' THEN
                        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
        
        --SET DEBUG FILE TO "/tmp/sp_ConsultarReportePagosSPL.out";
        --TRACE ON;

        IF p_Folio IS NULL OR p_Folio = '' THEN
        
                IF (p_FechaIni IS NULL OR p_FechaIni = '' OR p_FechaFin IS NULL OR p_FechaFin ='' OR p_Tipo IS NULL OR p_Tipo= '') THEN
                        LET v_cod_ret = '00001';
                        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
                END IF
                
                SELECT COUNT(*) INTO iExiste FROM bdicred: sd_bitacorapagos WHERE fecha_mov BETWEEN p_FechaIni AND p_FechaFin AND status = p_Tipo;
                
                IF iExiste = 0 THEN
                        LET v_cod_ret = '00151'; 
                        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
                END IF
                
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion registro,secuencia, num_credito,fecha_mov,numcte,sucursal,num_producto,folio,concepto_mov,descripcion_pago,descripcion_rev,importe_pago,
                        transaccion,capital_vigente,capital_transitorio,capital_vencido,capital_vencido_noexigible,capital_total,interes_vigente,iva_interesvigente,
                        interes_vencido,iva_interesvencido,interes_moratorio,iva_interesmoratorio
                        INTO iReg,cSecuencia, s_num_credito,d_fecha_mov,s_numcte,s_sucursal,s_num_producto,s_folio,s_concepto_mov,s_desc_pago,s_desc_rev,
                                m_importe_pago,s_transaccion,m_cap_vigente,m_cap_transitorio,m_cap_vencido,m_cap_vdo_noexigible,cCapital_total,m_int_vigente,
                                m_iva_intvigente,m_interes_vencido,m_iva_interesvencido,m_int_moratorio,m_iva_intmoratorio
                        FROM bdicred: sd_bitacorapagos
                        WHERE fecha_mov BETWEEN p_FechaIni AND p_FechaFin AND status = p_Tipo
							AND secuencia = 1
                        ORDER BY fecha_mov, registro, secuencia
                        
                        SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
                        INTO s_NomCte
                        FROM bdinteg: si_cliente
                        WHERE numcte = s_numcte;
                        
                        IF p_Tipo = 'R' THEN
							LET mSaldoAntRev = m_cap_vigente - m_importe_pago;
						ELSE
							LET mSaldoAntRev = m_cap_vigente + m_importe_pago;
						END IF;
                        LET mSaldoPostRev = m_cap_vigente;
                        
                        LET iNoRegs = iNoRegs + 1;
                        
                        RETURN v_cod_ret, iReg,cSecuencia, NVL(s_num_credito,""),NVL(d_fecha_mov,MDY(1,1,1900)),NVL(s_NomCte,""),NVL(s_sucursal,""),NVL(s_num_producto,""),
                                NVL(s_folio,""),NVL(s_concepto_mov,""),NVL(s_desc_pago,""),NVL(s_desc_rev,""),NVL(m_importe_pago,0.0),NVL(s_transaccion,0.0),
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),NVL(cCapital_total,0.0),NVL(m_int_vigente,0.0),
                                NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),
                                NVL(m_iva_intmoratorio,0.0),NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
                END FOREACH;
                
                IF iNoRegs = 0 AND pRegistros > 0 THEN
                        LET v_cod_ret = '1001';
                        RETURN v_cod_ret, iReg,cSecuencia, NVL(s_num_credito,""),NVL(d_fecha_mov,MDY(1,1,1900)),NVL(s_NomCte,""),NVL(s_sucursal,""),NVL(s_num_producto,""),
                                NVL(s_folio,""),NVL(s_concepto_mov,""),NVL(s_desc_pago,""),NVL(s_desc_rev,""),NVL(m_importe_pago,0.0),NVL(s_transaccion,0.0),
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),NVL(cCapital_total,0.0),NVL(m_int_vigente,0.0),
                                NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),
                                NVL(m_iva_intmoratorio,0.0),NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
                END IF;

        ELSE 
                LET iExiste = 0;
                LET iNoRegs=0;
                SELECT COUNT(*) INTO iExiste FROM bdicred: sd_bitacorapagos WHERE folio = p_Folio;
                
                IF iExiste = 0 THEN
                        LET v_cod_ret = '00092'; 
                        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
                END IF
        
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion registro,secuencia, num_credito,fecha_mov,numcte,sucursal,num_producto,folio,concepto_mov,descripcion_pago,descripcion_rev,importe_pago,
                        transaccion,capital_vigente,capital_transitorio,capital_vencido,capital_vencido_noexigible,capital_total,interes_vigente,iva_interesvigente,
                        interes_vencido,iva_interesvencido,interes_moratorio,iva_interesmoratorio
                        INTO iReg, cSecuencia,s_num_credito,d_fecha_mov,s_numcte,s_sucursal,s_num_producto,s_folio,s_concepto_mov,s_desc_pago,s_desc_rev,
                                m_importe_pago,s_transaccion,m_cap_vigente,m_cap_transitorio,m_cap_vencido,m_cap_vdo_noexigible,cCapital_total,m_int_vigente,
                                m_iva_intvigente,m_interes_vencido,m_iva_interesvencido,m_int_moratorio,m_iva_intmoratorio
                        FROM bdicred: sd_bitacorapagos
                        WHERE folio = p_Folio AND status = p_Tipo AND secuencia = 1
                        ORDER BY fecha_mov, registro, secuencia
                        
                        SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
                        INTO s_NomCte
                        FROM bdinteg:si_cliente
                        WHERE numcte = s_numcte;
                        
                        IF p_Tipo = 'R' THEN
							LET mSaldoAntRev = m_cap_vigente - m_importe_pago;
						ELSE
							LET mSaldoAntRev = m_cap_vigente + m_importe_pago;
						END IF;
                        LET mSaldoPostRev = m_cap_vigente;
                        
                        RETURN v_cod_ret,iReg, cSecuencia,NVL(s_num_credito,""),NVL(d_fecha_mov,MDY(1,1,1900)),NVL(s_NomCte,""),NVL(s_sucursal,""),NVL(s_num_producto,""),
                                NVL(s_folio,""),NVL(s_concepto_mov,""),NVL(s_desc_pago,""),NVL(s_desc_rev,""),NVL(m_importe_pago,0.0),NVL(s_transaccion,0.0),
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),NVL(cCapital_total,0.0),NVL(m_int_vigente,0.0),
                                NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),
                                NVL(m_iva_intmoratorio,0.0),NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
                END FOREACH;
                
                IF iNoRegs = 0 AND pRegistros > 0 THEN
                        LET v_cod_ret = '1001';
                        RETURN v_cod_ret, iReg,cSecuencia, NVL(s_num_credito,""),NVL(d_fecha_mov,MDY(1,1,1900)),NVL(s_NomCte,""),NVL(s_sucursal,""),NVL(s_num_producto,""),
                                NVL(s_folio,""),NVL(s_concepto_mov,""),NVL(s_desc_pago,""),NVL(s_desc_rev,""),NVL(m_importe_pago,0.0),NVL(s_transaccion,0.0),
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),NVL(cCapital_total,0.0),NVL(m_int_vigente,0.0),
                                NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),
                                NVL(m_iva_intmoratorio,0.0),NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
                END IF;

        END IF;
                

END
END PROCEDURE
DOCUMENT
'AUTOR: Saúl Ortiz Baeza.',
'DESCRIPCION: Procedimiento que obtiene el reporte de pagos manuales y pagos reversados manuales, ya sea por fecha, diario o por folio',
'FECHA: JULIO 2013',
'VERSION: 20100120.1702',
'BD: Bdicred';

CREATE PROCEDURE "informix".sp_grabarreversocargomancre (pUsuario CHAR(8), pIdFuncion CHAR(10), pFolio CHAR(16), pEjecutivo CHAR(8),  pObservacionRev CHAR(200))
RETURNING  CHAR(5);

DEFINE cCodRet 		CHAR(5);
DEFINE vCodRetSp	CHAR(6);
DEFINE iSqlErr		INTEGER;
BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_grabarreversocargoman.out";
	--TRACE ON;

	LET cCodRet   = '00000';
	LET iSqlErr	  = 0;		
	LET vCodRetSp = '000000';
	
	IF pUsuario = '' OR pIdFuncion = '' OR pFolio = '' OR pEjecutivo = ''  OR pObservacionRev = ''THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;


	EXECUTE PROCEDURE bdicred: sp_grabarreversocargoman(pFolio,pEjecutivo,pObservacionRev)
	INTO vCodRetSp;
		--La reversion no se realizo exitosamente
		IF vCodRetSp = '10000' THEN
			LET cCodRet = '00165';
		ELIF  vCodRetSp = '000' THEN
			LET cCodRet = '00000';	
		ELIF vCodRetSp <> '00000' THEN
			LET cCodRet = vCodRetSp;	
		END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE
DOCUMENT
'EFECTUA EL REVERSADO',
'AUTOR: SAÚL ORTIZ BAEZA',
'FECHA: JULIO 2013',
'VERSION: 20100122.1403',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_grabarreversopagosmancre (pUsuario CHAR(8), pIdFuncion CHAR(10),pFolio CHAR(16), pEjecutivo CHAR(8),  pObservacionRev CHAR(50))
RETURNING  CHAR(5);

DEFINE cCodRet 		CHAR(5);
DEFINE vCodRetSp	CHAR(6);
DEFINE iSqlErr		INTEGER;
BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_grabarreversopagosman.out";
	--TRACE ON;

	LET cCodRet   = '00000';
	LET iSqlErr	  = 0;		
	LET vCodRetSp = '000000';
	
	IF pUsuario = '' OR pIdFuncion = '' OR pFolio = '' OR pEjecutivo = ''  OR pObservacionRev = ''THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;


	EXECUTE PROCEDURE bdicred: sp_grabarreversopagosman(pFolio,pEjecutivo,pObservacionRev)
	INTO vCodRetSp;
		--La reversion no se realizo exitosamente
		IF vCodRetSp = '10000' THEN
			LET cCodRet = '00165';
		ELIF  vCodRetSp = '000' THEN
			LET cCodRet = '00000';
		ELIF vCodRetSp <> '00000' THEN
			LET cCodRet = vCodRetSp;
		END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE
DOCUMENT
'EFECTUA EL REVERSO DEL MOVIMIENTO',
'AUTOR: SAÚL ORTIZ BAEZA',
'FECHA: JULIO 2013',
'VERSION: 20100122.1403',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_reportecargotarjetareversadomanualcre(pIdUsuario CHAR(8), pIdFuncion CHAR(10),pTipoReporte CHAR(6),pReversado CHAR(1),pFech_Ini CHAR(10),pFech_Fin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
 RETURNING
        CHAR(5) AS cod_ret, 
        CHAR(80) AS desc_ret,
        CHAR(100)       As concepto,
        CHAR(20)        AS num_credito,
        CHAR(104)       AS nomcte,      
        MONEY(18,2)     AS importe_cargo,       
        MONEY(18,2)     AS cap_vigente,
        MONEY(18,2)     AS cap_transitorio,
        MONEY(18,2)     AS cap_vencido,
        MONEY(18,2)     AS cap_vdo_noexigible,
        MONEY(18,2) AS capital_total,
        MONEY(18,2)     AS int_vigente,
        MONEY(18,2)     AS iva_intvigente,
        MONEY(18,2)     AS interes_vencido,
        MONEY(18,2)     AS iva_interesvencido,
        MONEY(18,2)     AS int_moratorio,
        MONEY(18,2)     AS iva_intmoratorio,
        DATE            AS fecha_mov,
        CHAR(4)         AS transaccion, 
        CHAR(50)        AS descripcion, 
        CHAR(16)        AS folio_grupo, 
        CHAR(3)         AS cod_cargo, 
        CHAR(16)        AS folio_mov, 
        MONEY(14,2) AS sdo_ant_rev,
        MONEY(14,2) AS sdo_post_rev,
        CHAR(12) AS cNoCuenta;
        
        
        DEFINE cCodRetSp             CHAR(6);
        DEFINE cCodRet               CHAR(5);
        DEFINE iSqlErr           INTEGER;
        DEFINE cMensajeRet       CHAR(80);      
        DEFINE cFolio_Grupo      CHAR(16);
        DEFINE mImporte          MONEY(14,2);
        DEFINE cNum_credito          CHAR(20);
        DEFINE cCodigo_cargo     CHAR(2);
        DEFINE cDesc_cargo       CHAR(100);
        DEFINE cFolio            CHAR(16);
        DEFINE dFecha_Aplic      DATE;
        DEFINE mSaldoAntRev      MONEY(14,2);
        DEFINE mSaldoPostRev     MONEY(14,2);
        DEFINE cTransaccion                     CHAR(4);
        DEFINE m_cap_vigente                    MONEY(18,2);
        DEFINE m_cap_transitorio                MONEY(18,2);
        DEFINE m_cap_vencido                    MONEY(18,2);
        DEFINE m_cap_vdo_noexigible             MONEY(18,2);
        DEFINE m_int_vigente                    MONEY(18,2);
        DEFINE m_iva_intvigente                 MONEY(18,2);
        DEFINE m_interes_vencido                MONEY(18,2);
        DEFINE m_iva_interesvencido             MONEY(18,2);
        DEFINE m_int_moratorio                  MONEY(18,2);
        DEFINE m_iva_intmoratorio               MONEY(18,2);
        DEFINE m_capital_anterior               MONEY(18,2);
        DEFINE m_capital_actual             MONEY(18,2);
        DEFINE cNomCte                                  VARCHAR(80);
        DEFINE mCapital_total                   MONEY(18,2);
        DEFINE cObservaciones                   CHAR(200);
        DEFINE iReg              INTEGER;
        DEFINE dtFechaHoy        DATE;  
        DEFINE dFechaIni      DATE;
        DEFINE dFechaFin      DATE;
        DEFINE dFecha_AplicRev   DATE;
        DEFINE cNumcte                   CHAR(20);
        DEFINE cObservacionesRev            CHAR(200);
        DEFINE cNoCuenta CHAR(12);
        
        LET cCodRet = '00000'; 
        LET iSqlErr = 0;
        LET cMensajeRet = "";
        LET cNum_credito = ''; 
        LET cFolio_Grupo = ''; 
        LET mImporte = 0.0; 
        LET cCodigo_cargo = ''; 
        LET cDesc_cargo = ''; 
        LET cFolio = ''; 
        LET dFecha_Aplic = DATE(1); 
        LET mSaldoAntRev   = 0.0; 
        LET mSaldoPostRev   = 0.0; 
        LET cTransaccion = ""; 
        LET m_cap_vigente = 0.0; 
        LET m_cap_transitorio = 0.0; 
        LET m_cap_vencido = 0.0; 
        LET m_cap_vdo_noexigible = 0.0;
        LET m_int_vigente = 0.0;
        LET m_iva_intvigente = 0.0; 
        LET m_interes_vencido = 0.0; 
        LET m_iva_interesvencido = 0.0; 
        LET m_int_moratorio = 0.0; 
        LET m_iva_intmoratorio = 0.0; 
        LET m_capital_anterior = 0.0;
        LET m_capital_actual = 0.0;
        LET cNomCte = ""; 
        LET mCapital_total = 0.0; 
        LET cObservaciones = ''; 
        LET iReg = 0;
        LET dtFechaHoy = DATE(1);
        LET dFechaIni = DATE(1);
        LET dFechaFin = DATE(1);
        LET dFecha_AplicRev = DATE(1);
        LET cNumcte = '';
        LET cObservacionesRev = '';
        LET cNoCuenta='';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0),NVL(cNoCuenta,'');
                END EXCEPTION;
                
                IF pIdUsuario = '' OR pIdFuncion = '' OR pTipoReporte='' OR pReversado = '' OR pRegistros = '' OR pRecuperacion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'');
                END IF;
                
                --Se obtiene la fecha del dia
                SELECT fecha_hoy
                INTO dtFechaHoy
                FROM bdicred:sd_fechas
                WHERE empresa = "001";
                
                --Valida si las fechas recibidas son nulas y si lo es asi las iguala a la fecha del dia
                IF NVL(pFech_Ini,'') =  '' THEN
                        LET dFechaIni = dtFechaHoy;             
                ELSE
                        LET dFechaIni =  pFech_Ini::DATE;
                END IF;
                
                IF NVL(pFech_Fin,'') =  '' THEN
                        LET dFechaFin = dtFechaHoy;
                ELSE
                        LET dFechaFin =  pFech_Fin::DATE;
                END IF
                
                        
                -- valida que la fecha ini no sea mayor que la fecha fin
                IF dFechaIni > dFechaFin THEN
                        LET cCodRet='00154';
                        LET cMensajeRet = "LA FECHA INICIAL ES MAYOR A LA FECHA FINAL";
                        RETURN cCodRet,cMensajeRet ,cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'');
                END IF; 
                -- Valida que la fecha fin no sea mayor que la fecha actual
                IF dFechaFin > dtFechaHoy THEN
                        LET cCodRet='00155';
                        LET cMensajeRet = "LA FECHA FINAL ES MAYOR A LA FECHA ACTUAL";
                        RETURN cCodRet,cMensajeRet , cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),        
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'');
                END IF;
                
                IF pTipoReporte = 'Masivo' THEN 
                        FOREACH WITH HOLD               
                                SELECT SKIP pRegistros FIRST pRecuperacion folio_grupo, num_credito, importe_cargo, cod_cargo, desc_cargo, folio, fecha_cargo,
                                                fecha_reverso,cap_total_pos,cap_total_ant
                                        INTO cFolio_Grupo, cNum_credito, mImporte, cCodigo_cargo, cDesc_cargo, cFolio, dFecha_Aplic,
                                                dFecha_AplicRev,mSaldoAntRev,mSaldoPostRev
                                FROM bdicred:sd_bitacora_cargos
                                WHERE reverso =  pReversado 
                                AND folio_grupo <> ""
                                AND fecha_cargo BETWEEN dFechaIni AND dFechaFin                 
                                
                                IF pReversado = "S" THEN
                                        LET dFecha_Aplic = dFecha_AplicRev;
                                END IF;
                                
                                LET iReg = iReg + 1;
                                SELECT num_credito INTO cNoCuenta FROM bdicred:sd_bitacorapagos WHERE folio = cFolio;
                                
                                RETURN cCodRet,cMensajeRet,  cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),        
                                        NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                        NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                        NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                        NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                        NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'') WITH RESUME;
                        END FOREACH;    
                ELIF pTipoReporte = 'Manual' THEN
                        FOREACH
                                SELECT SKIP pRegistros FIRST pRecuperacion cod_cargo,desc_cargo,numcte,num_credito,importe_cargo,cap_vig_pos,
                                                cap_tran_pos, cap_venc_pos,     cap_venc_noexi_pos, cap_total_pos,
                                                int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant,
                                                int_mora_ant, iva_int_mora_ant,fecha_cargo, fecha_reverso,observaciones, observaciones_rev, folio,
                                                cap_total_ant, cap_total_pos
                                INTO  cCodigo_cargo,cDesc_cargo,cNumcte, cNum_credito,mImporte,m_cap_vigente,m_cap_transitorio,m_cap_vencido,
                                                m_cap_vdo_noexigible,mCapital_total,m_int_vigente,m_iva_intvigente,m_interes_vencido,
                                                m_iva_interesvencido,m_int_moratorio,m_iva_intmoratorio,dFecha_Aplic,dFecha_AplicRev,cObservaciones,cObservacionesRev, cFolio,
                                                m_capital_anterior, m_capital_actual
                                FROM bdicred:sd_bitacora_cargos 
                                WHERE reverso = pReversado
                                AND folio_grupo = ""
                                AND fecha_cargo  BETWEEN dFechaIni AND dFechaFin        
								
								LET cNoCuenta = cNum_credito;
								
                                IF pReversado = "S" THEN
                                        LET cObservaciones = cObservacionesRev;
                                        LET dFecha_Aplic = dFecha_AplicRev;
										LET mSaldoAntRev = m_capital_anterior;
                                        LET mSaldoPostRev = m_capital_actual;
										
										-- Obtenemos los saldos actuales
										SELECT cap_vig_ant, cap_total_ant
										INTO m_cap_vigente, mCapital_total
										FROM bdicred:sd_bitacora_cargos 
										WHERE reverso = pReversado AND folio = cFolio;
										
                                ELIF pReversado = "N" THEN
                                        LET mSaldoAntRev = m_capital_anterior;
                                        LET mSaldoPostRev = m_capital_actual;
                                END IF;
                                
                                --se obtiene el nombre del cliente                      
                                SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
                                INTO cNomCte
                                FROM bdinteg:si_cliente
                                WHERE numcte = cNumcte;
                                --se obtiene la transaccion relacionada al concepto
                                SELECT transacc
                                INTO  cTransaccion
                                FROM bdicred:sd_conceptoscargoscredito
                                WHERE codigo = cCodigo_cargo;

                                LET iReg = iReg + 1;
                                
                                RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                        NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                        NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                        NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                        NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                        NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'') WITH RESUME;
                        END FOREACH;
                END IF;
                
                IF pRegistros = 0 AND iReg = 0 THEN
                        LET cCodRet='00151';
                        SELECT num_credito INTO cNoCuenta FROM bdicred:sd_bitacorapagos WHERE folio = cFolio;
                        RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'');
                ELIF pRegistros > 0 AND iReg = 0 THEN
                        LET cCodRet='1001';
                        SELECT num_credito INTO cNoCuenta FROM bdicred:sd_bitacorapagos WHERE folio = cFolio;
                        RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0), 
                                NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
                                NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
                                NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
                                NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
                                NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0), NVL(cNoCuenta,'');
                END IF;
        
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Saul Ortiz Baeza",
"FECHA: 05/07/2013",
"DESCRIPCION: Procedimiento que consulta los movimientos para el reporte de los cargos Masivos e individuales reversados o no de las cuentas de credito";

CREATE PROCEDURE "informix".sp_bloquealotemasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre CHAR(10), pLote INTEGER, pOpcBloqueo INTEGER)
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cStatusLote CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cStatusLote = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdFuncionPadre = '' OR pLote = '' OR pOpcBloqueo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF pOpcBloqueo NOT IN (0,1,2) THEN
			LET cCodRet = '00108';
			RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se busca el lote en la tabla de los masivos
		SELECT COUNT(id_lote)
		INTO iExiste
		FROM bdicnweb:sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncionPadre;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet;
		ELSE
			IF pOpcBloqueo = 0 THEN -- Desbloqiueo del lote, 'CARGADO'
				LET cStatusLote = 'C';
			ELIF pOpcBloqueo = 1 THEN -- Bloqueo del lote, 'PROCESANDO'
				LET cStatusLote = 'P';
			ELIF pOpcBloqueo = 2 THEN -- Desbloqiueo del lote, 'TERMINADO'
				LET cStatusLote = 'T';
			END IF;
			
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = cStatusLote
			WHERE id_lote = pLote AND id_funcion = pIdFuncionPadre;
			
			RETURN cCodRet;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Cambia el estatus de un lote de la aplicaciÃ³n CNWEB";

CREATE PROCEDURE "informix".sp_blqconsultabloqueocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTipoMov CHAR(1))
	RETURNING CHAR(5) AS codret,
			CHAR(5) AS codretsp,
			CHAR(50) AS desc_bloqueo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDesBloqueo CHAR(50);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesBloqueo = '';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pTipoMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		IF pTipoMov NOT IN ('D', 'B') THEN
			LET cCodRet = '00005';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		-- Busqueda del estatus de la cuenta
		EXECUTE PROCEDURE bdicheq:sp_blqvalbloqueocta(pCuenta) INTO cCodRetSp, cDesBloqueo;
		
		IF pTipoMov = 'B' THEN
			IF cCodRetSp = '10000' THEN
				LET cCodRet = '00173';
			END IF;
		ELIF pTipoMov = 'D' THEN
			IF cCodRetSp <> '10000' THEN
				LET cCodRet = '00172';
			END IF;
		END IF;
		
		RETURN cCodRet, cCodRetSp, cDesBloqueo;
		
	END;
	
END PROCEDURE;