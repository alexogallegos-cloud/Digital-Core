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