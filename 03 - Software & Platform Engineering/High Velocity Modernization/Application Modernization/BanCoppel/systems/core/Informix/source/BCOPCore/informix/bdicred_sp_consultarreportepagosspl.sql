CREATE PROCEDURE "informix".sp_consultarreportepagosspl(p_FechaIni 	CHAR(10), --FECHA INICIO
														p_FechaFin 	CHAR(10), --FECHA FIN
														pStatus 	CHAR(1),  --ESTATUS A(ACTIVO)R(REVERSADO)N(ACTIVO)S(REVERSADO)
														pFolio	 	CHAR(16), --FOLIO
														pAplicacion SMALLINT, --APLICACION 1(MANUAL)2(MASIVO)
														pConsulta 	SMALLINT, -----------------------
														pProducto 	CHAR (4)) --CODIGO PRODUCTO     |
		----------------------------------------------------------------------						|					
		--	pConsulta = 1 (pagos aplicados por dia.)						--						|
		--	pConsulta = 2 (pagos aplicados por rango de fechas.)			--  <--------------------
		--	pConsulta = 3 (Condonaciones aplicadas por dia.)				--	
		--	pConsulta = 4 (Condonaciones aplicadas por rango de fechas.)	--
		--	pConsulta = 5 (Consulta de reverso masivo por folio.)	--
		----------------------------------------------------------------------												
	RETURNING
	CHAR(6)			AS COD_RET,							
	CHAR(3)         As reg,                            
	CHAR(1)			As Secuencia,                      
	CHAR(30)		As Descr_secuencia,                
	CHAR(20)		AS num_credito,                    
	CHAR(104)		AS nomcte,                         
	MONEY(18,2)		AS importe,                        
	MONEY(18,2)		AS cap_vigente,                    
	MONEY(18,2)		AS cap_transitorio,                
	MONEY(18,2)		AS cap_vencido,                    
	MONEY(18,2)		AS cap_vdo_noexigible,             
	MONEY(18,2)     AS Capital_Total,                  
	MONEY(18,2)		AS int_vigente,                    
	MONEY(18,2)		AS iva_intvigente,                 
	MONEY(18,2)		AS interes_vencido,                
	MONEY(18,2)		AS iva_interesvencido,             
	MONEY(18,2)		AS interes_mora_base,              
	MONEY(18,2)		AS interes_mora_copete,            
	MONEY(18,2)		AS iva_intmoratorio,               
	DATE			AS fecha_movimiento,               
	CHAR(2)			AS codigo_pago,                    
	CHAR(50)		AS descrip_cod_pago,               
	CHAR(16)		AS folio_grupo,                    
	CHAR(16)		AS folio,                          
	CHAR(8)			AS usuario,
	CHAR(4)			AS sucursal,
	CHAR(50)		AS descrip_reverso,
	CHAR(4)			AS codigo_producto,
	CHAR(50)		AS descripcion_pago,
	CHAR(4)			AS transaccion,
	MONEY(18,2)     AS interes_moratorio,              
	MONEY(18,2)     AS iva_int_morabase,               
    MONEY(18,2)     AS iva_int_moracopete;

	---DECLARACIONES                                   
    DEFINE cCodret            		CHAR(6);           
    DEFINE iSqlErr              	INTEGER;           
    DEFINE iSamErr              	INTEGER;	       
	DEFINE cNumCredito				CHAR(20);          
	DEFINE dt_FechaMov				DATE;              
	DEFINE cNumcte					CHAR(20);
	DEFINE cSucursal				CHAR(4);
	DEFINE cCodProducto				CHAR(4);
	DEFINE cFolio					CHAR(16);
	DEFINE cConceptoMov				CHAR(20);
	DEFINE c_DescriPago				CHAR(50);
	DEFINE cDescRev					CHAR(50);
	DEFINE m_ImportePago			MONEY(18,2);
	DEFINE cTransaccion				CHAR(4);
	DEFINE mCapVigente				MONEY(18,2);
	DEFINE mCapTransitorio			MONEY(18,2);
	DEFINE mCapVencido				MONEY(18,2);
	DEFINE mCapVdoNoExigible		MONEY(18,2);
	DEFINE mIntVigente				MONEY(18,2);
	DEFINE mIvaIntVigente			MONEY(18,2);
	DEFINE mInteresVencido			MONEY(18,2);
	DEFINE mIvaIntVencido			MONEY(18,2);
	DEFINE mIntMoratorio			MONEY(18,2);
	DEFINE mIntMoraBase				MONEY(18,2);
	DEFINE mIntMoraCopete			MONEY(18,2);
	DEFINE mIvaIntMoratorio			MONEY(18,2);
	DEFINE mIvaIntMoraBase			MONEY(18,2);
	DEFINE mIvaIntMoraCopete		MONEY(18,2);
	DEFINE cNombreCte				CHAR(104);
	DEFINE cReg						CHAR(3);
	DEFINE cUsuario					CHAR(8);
	DEFINE cFolioGrupo				CHAR(16);
	DEFINE mCapitalTotal			MONEY(18,2);
	DEFINE cSecuencia				CHAR(1);
	DEFINE cCodigo					CHAR(2);
	DEFINE cDescripcionpag			CHAR(50);
	DEFINE dtFechaHoy				DATE;
	DEFINE cNombreCte_Aux			CHAR(104);
	DEFINE cConcepto				CHAR(30);
	DEFINE iContReg              	INTEGER; 
	DEFINE cFolioMas           		CHAR (16); 
	
	---INICIALIZACIONES
	LET	cCodret            	= '000000';
	LET	iSqlErr             = 0;
	LET	iSamErr             = 0; 
	LET	cNumCredito			= '';
	LET	dt_FechaMov			= '';
	LET	cNumcte				= '';
	LET	cSucursal			= '';
	LET	cCodProducto		= '';	
	LET	cFolio				= '';
	LET	cConceptoMov		= '';	
	LET	c_DescriPago		= '';	
	LET	cDescRev			= '';	
	LET m_ImportePago		= 0.0;
	LET cTransaccion		= '';	
	LET mCapVigente			= 0.0;
	LET mCapTransitorio		= 0.0;
	LET mCapVencido			= 0.0;
	LET mCapVdoNoExigible	= 0.0;
	LET mIntVigente			= 0.0;
	LET mIvaIntVigente		= 0.0;
	LET mInteresVencido		= 0.0;
	LET mIvaIntVencido		= 0.0;
	LET mIntMoratorio		= 0.0;
	LET mIntMoraBase		= 0.0;	
	LET mIntMoraCopete		= 0.0;
	LET mIvaIntMoratorio	= 0.0;	
	LET mIvaIntMoraBase		= 0.0;
	LET mIvaIntMoraCopete	= 0.0;
	LET cNombreCte			= '';
	LET cReg				= '000';	
	LET cUsuario			= '';	
	LET cFolioGrupo			= '';
	LET mCapitalTotal		= 0.0;
	LET cSecuencia			= '';
	LET cCodigo				= '';
	LET cDescripcionpag		= '';
	LET dtFechaHoy			= DATE(1);
	LET cNombreCte_Aux		= '';
	LET cConcepto			= '';
	LET iContReg			= 0;
	LET cFolioMas			= '';


	BEGIN
		--VALIDACION DE ERRORES NO CONTROLADOS.
		ON EXCEPTION
			SET iSqlErr, iSamErr
			
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cReg, cSecuencia, TRIM(NVL(cConcepto,'')), NVL(cNumCredito,''), NVL(cNombreCte,''), NVL(m_ImportePago,0.0),
					NVL(mCapVigente,0.0), NVL(mCapTransitorio,0.0), NVL(mCapVencido,0.0), NVL(mCapVdoNoExigible,0.0), NVL(mCapitalTotal,0.0),
					NVL(mIntVigente,0.0), NVL(mIvaIntVigente,0.0), NVL(mInteresVencido,0.0), NVL(mIvaIntVencido,0.0),
					NVL(mIntMoraBase,0.0), NVL(mIntMoraCopete,0.0), NVL(mIvaIntMoratorio,0.0), NVL(dt_FechaMov,''), NVL(cCodigo,''),
					NVL(cDescripcionpag,''), NVL(cfoliogrupo,''), NVL(cFolio,''), NVL(cUsuario,''), NVL(cSucursal,''),
					NVL(cDescRev,''), NVL(cCodProducto,''), NVL(c_DescriPago,''), NVL(cTransaccion,''), NVL(mIntMoratorio,0.0),
					NVL(mIvaIntMoraBase,0.0), NVL(mIvaIntMoraCopete,0.0);
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consultarreportepagosspl.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDA PARAMETROS
		IF NVL(pStatus,'')= '' OR NVL (pConsulta,0) NOT IN (1,2,3,4,5) OR NVL(pAplicacion,0) NOT IN (1,2) THEN
			LET cCodret = '000001';
				RETURN cCodret, cReg, cSecuencia, TRIM(NVL(cConcepto,'')), NVL(cNumCredito,''), NVL(cNombreCte,''), NVL(m_ImportePago,0.0),
					NVL(mCapVigente,0.0), NVL(mCapTransitorio,0.0), NVL(mCapVencido,0.0), NVL(mCapVdoNoExigible,0.0), NVL(mCapitalTotal,0.0),
					NVL(mIntVigente,0.0), NVL(mIvaIntVigente,0.0), NVL(mInteresVencido,0.0), NVL(mIvaIntVencido,0.0),
					NVL(mIntMoraBase,0.0), NVL(mIntMoraCopete,0.0), NVL(mIvaIntMoratorio,0.0), NVL(dt_FechaMov,''), NVL(cCodigo,''),
					NVL(cDescripcionpag,''), NVL(cfoliogrupo,''), NVL(cFolio,''), NVL(cUsuario,''), NVL(cSucursal,''),
					NVL(cDescRev,''), NVL(cCodProducto,''), NVL(c_DescriPago,''), NVL(cTransaccion,''), NVL(mIntMoratorio,0.0),
					NVL(mIvaIntMoraBase,0.0), NVL(mIvaIntMoraCopete,0.0);
		END IF
	

		--ADQUIRIR FECHA HOY
		SELECT fecha_hoy 
		INTO dtfechahoy 
		FROM 'informix'.sd_fechas
		WHERE empresa = '001';
		
		
		--VALIDACION DE FECHAS
		IF NVL(p_FechaIni,'') = '' OR NVL (p_FechaFin,'') = ''  THEN
			LET p_FechaIni = dtfechahoy;
			LET p_FechaFin = dtfechahoy;
			
		ELIF p_FechaFin::DATE < p_FechaIni::DATE THEN
			LET cCodret = '000002';
			
		ELIF p_FechaFin::DATE > dtfechahoy::DATE THEN
			LET cCodret = '000003';
			
		END IF;
		
		-- VALIDA CODIGO DE RECORTNO POR SI SALE ALGUN ERROR.
		IF cCodret::INTEGER <> 0 THEN
				RETURN cCodret, cReg, cSecuencia, TRIM(NVL(cConcepto,'')), NVL(cNumCredito,''), NVL(cNombreCte,''), NVL(m_ImportePago,0.0),
					NVL(mCapVigente,0.0), NVL(mCapTransitorio,0.0), NVL(mCapVencido,0.0), NVL(mCapVdoNoExigible,0.0), NVL(mCapitalTotal,0.0),
					NVL(mIntVigente,0.0), NVL(mIvaIntVigente,0.0), NVL(mInteresVencido,0.0), NVL(mIvaIntVencido,0.0),
					NVL(mIntMoraBase,0.0), NVL(mIntMoraCopete,0.0), NVL(mIvaIntMoratorio,0.0), NVL(dt_FechaMov,''), NVL(cCodigo,''),
					NVL(cDescripcionpag,''), NVL(cfoliogrupo,''), NVL(cFolio,''), NVL(cUsuario,''), NVL(cSucursal,''),
					NVL(cDescRev,''), NVL(cCodProducto,''), NVL(c_DescriPago,''), NVL(cTransaccion,''), NVL(mIntMoratorio,0.0),
					NVL(mIvaIntMoraBase,0.0), NVL(mIvaIntMoraCopete,0.0);
		END IF
		--HACER MAYUSTULA LA LETRA DEL ESTATUS.
		LET pStatus = UPPER(pStatus);
			
		-- CONSULTA POR PAGOS.	
		IF pConsulta IN (1,2) THEN
			LET cReg = '001';
			FOREACH
				SELECT secuencia, num_credito,fecha_mov,numcte,sucursal,num_producto,folio,concepto_mov,descripcion_pago,
				descripcion_rev,importe_pago,transaccion,capital_vigente,capital_transitorio,capital_vencido,
				capital_vencido_noexigible,capital_total,interes_vigente,iva_interesvigente,
				interes_vencido,iva_interesvencido,interes_moratorio,iva_interesmoratorio,interes_moratorio_base,interes_moratorio_copete,
				iva_interesmoratoriobase,iva_interesmoratoriocopete,usuario
				INTO cSecuencia,cNumCredito,dt_FechaMov,cNumcte,cSucursal,cCodProducto,cFolio,cConceptoMov,c_DescriPago,
				cDescRev,m_ImportePago,cTransaccion,mCapVigente,mCapTransitorio,mCapVencido,mCapVdoNoExigible,mCapitalTotal,
				mIntVigente,mIvaIntVigente,mInteresVencido,mIvaIntVencido,mIntMoratorio,mIvaIntMoratorio,mIntMoraBase,
				mIntMoraCopete,mIvaIntMoraBase,mIvaIntMoraCopete,cUsuario
				FROM "informix".sd_bitacorapagos
				WHERE fecha_mov BETWEEN p_FechaIni AND p_FechaFin 
				AND status = pStatus
				AND num_producto = DECODE (pProducto,'',num_producto,pProducto)
				AND tipo_aplic = DECODE (pAplicacion,0,tipo_aplic,pAplicacion)
				AND folio LIKE DECODE (pFolio,'',folio, ('%'|| TRIM(pFolio) ||'%'))
				AND transaccion IN (SELECT DISTINCT (a.transacc) FROM "informix".sd_conceptospagomanual a 
									WHERE a.codigo NOT IN ('27', '28')
									UNION ALL
									SELECT DISTINCT (b.transacc) FROM "informix".sd_conceptospagomanualcrd b 
									WHERE b.codigo NOT IN ('17', '18', '19', '20', '21', '22'))

				
				--CONTADOR DE REGISTROS.
				LET iContReg =iContReg +1;
				
				IF iContReg >= 3 AND cSecuencia = '1' THEN
					LET iContReg = 0;
					LET cReg = cReg::INTEGER +1;
				END IF
				LET cReg = LPAD(TRIM(cReg),3,'0');
				
				-- LIMPIA LAS VARIABLES QUE NO SE DEBEN MOSTRAR EN ESTAS FILAS Y ADQUIERE EL NOMBRE DEL CLIENTE.
				IF cSecuencia IN ('1','3')THEN
					LET cNombreCte = '';
					LET dt_FechaMov = '';
					LET cFolio = '';
					LET cfoliogrupo = '';
					LET cUsuario = '';
					LET m_ImportePago = NULL;
					LET cCodigo = '';
					LET cDescripcionpag = '';
					IF cSecuencia = 1 THEN
						--SACA EL NOMBRE DEL CLIENTE.
						SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
						INTO cNombreCte
						FROM bdinteg:"informix".si_cliente
						WHERE numcte = TRIM(cNumcte);
						
						LET cNombreCte_Aux = cNombreCte;
						LET cConcepto = 'Saldo Anterior';
						LET cCodigo = '';
						LET cDescripcionpag = '';
						
					ELSE
						LET cNombreCte = cNombreCte_Aux;
						LET cNombreCte_Aux = '';
						LET cConcepto = 'Saldo Nuevo';
						LET cCodigo = '';
						LET cDescripcionpag = '';
						
					END IF
				--Secuencia 2
				ELSE
					LET cConcepto = 'Importe Aplicado';
					LET cNombreCte = '';
					--ADQUIERE EL CODIGO DE PAGO Y SU DESCRIPCION.
					--AAME 21062018 RQM 06 590 - 591 Se contemplan prodcutos Oro y Platino, se agrega TDC GP
					IF cCodProducto IN ('6001','7000','8100','8500') THEN
						SELECT LIMIT 1 Codigo,concepto
						INTO cCodigo,cDescripcionpag
						FROM "informix".sd_conceptospagomanual
						WHERE transacc = cTransaccion
						AND cod_fun IN (SELECT codigo_fun FROM "informix".sd_movdia WHERE num_credito = cNumCredito 
										AND folio_suc = cFolio AND transacc_suc = cTransaccion
										UNION ALL
										SELECT codigo_fun FROM "informix".sd_movhis WHERE num_credito = cNumCredito 
										AND folio_suc = cFolio AND transacc_suc = cTransaccion);
					
					ELSE
						SELECT codigo,concepto
						INTO cCodigo,cDescripcionpag
						FROM "informix".sd_conceptospagomanualcrd
						WHERE transacc = cTransaccion
						AND num_producto= cCodProducto;
					END IF;
					
					--OBTIEBE LOS FOLIOS CUANDO ES MASIVO.
					IF pAplicacion = 2 THEN
						SELECT folio, folio_grupo
						INTO cFolio, cfoliogrupo
						FROM "informix".sd_bitacora_pagos
						WHERE num_credito = TRIM(cNumCredito)
						AND folio = TRIM(cFolio)
						AND fecha_pago = dt_FechaMov;
					END IF
					
				END IF

				
				RETURN cCodret, cReg, cSecuencia,cConcepto,cNumCredito, cNombreCte, m_ImportePago,
					mCapVigente, mCapTransitorio, mCapVencido, mCapVdoNoExigible, mCapitalTotal,
					mIntVigente, mIvaIntVigente, mInteresVencido, mIvaIntVencido,
					mIntMoraBase, mIntMoraCopete, mIvaIntMoratorio, dt_FechaMov, cCodigo,
					cDescripcionpag, cfoliogrupo, cFolio, cUsuario, cSucursal,
					cDescRev, cCodProducto, c_DescriPago, cTransaccion, mIntMoratorio,
					mIvaIntMoraBase,mIvaIntMoraCopete WITH RESUME;
			END FOREACH;
			
			--VALIDA SI ENCUENTRA INFORMACION.
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cReg = '000';
				LET cCodret = '000004';
			END IF
			
			
		--SI LA CONSULTA ES POR CONDONACION.
		ELIF pConsulta IN (3,4) THEN
			LET cReg ='1';
			FOREACH
				SELECT secuencia, num_credito,fecha_mov,numcte,sucursal,num_producto,folio,concepto_mov,descripcion_pago,
				descripcion_rev,importe_pago,transaccion,capital_vigente,capital_transitorio,capital_vencido,
				capital_vencido_noexigible,capital_total,interes_vigente,iva_interesvigente,
				interes_vencido,iva_interesvencido,interes_moratorio,iva_interesmoratorio,interes_moratorio_base,interes_moratorio_copete,
				iva_interesmoratoriobase,iva_interesmoratoriocopete,usuario
				INTO  cSecuencia,cNumCredito,dt_FechaMov,cNumcte,cSucursal,cCodProducto,cFolio,cConceptoMov,c_DescriPago,
				cDescRev,m_ImportePago,cTransaccion,mCapVigente,mCapTransitorio,mCapVencido,mCapVdoNoExigible,mCapitalTotal,
				mIntVigente,mIvaIntVigente,mInteresVencido,mIvaIntVencido,mIntMoratorio,mIvaIntMoratorio,mIntMoraBase,
				mIntMoraCopete,mIvaIntMoraBase,mIvaIntMoraCopete,cUsuario
				FROM "informix".sd_bitacorapagos
				WHERE fecha_mov BETWEEN p_FechaIni AND p_FechaFin 
				AND status = pStatus
				AND num_producto = DECODE (pProducto,'',num_producto,pProducto)
				AND tipo_aplic = DECODE (pAplicacion,0,tipo_aplic,pAplicacion)
				AND folio LIKE DECODE (pFolio,'',folio, ('%'|| TRIM(pFolio) ||'%'))
				AND transaccion IN (SELECT DISTINCT (a.transacc) FROM "informix".sd_conceptospagomanual a 
									WHERE a.codigo IN ('27', '28')
									UNION ALL
									SELECT DISTINCT (b.transacc) FROM "informix".sd_conceptospagomanualcrd b 
									WHERE b.codigo IN ('17', '18', '19', '20', '21', '22'))

				
				--CONTADOR DE REGISTROS.
				LET iContReg =iContReg +1;
				
				IF iContReg >= 3 AND cSecuencia = '1' THEN
					LET iContReg = 0;
					LET cReg = cReg::INTEGER +1;
				END IF
				LET cReg = LPAD(TRIM(cReg),3,'0');
								-- LIMPIA LAS VARIABLES QUE NO SE DEBEN MOSTRAR EN ESTAS FILAS Y ADQUIERE EL NOMBRE DEL CLIENTE.
				IF cSecuencia IN ('1','3')THEN
					LET cNombreCte = '';
					LET dt_FechaMov = '';
					LET cFolio = '';
					LET cfoliogrupo = '';
					LET cUsuario = '';
					LET m_ImportePago = NULL;
					LET cCodigo = '';
					LET cDescripcionpag = '';
					IF cSecuencia = 1 THEN
						--SACA EL NOMBRE DEL CLIENTE.
						SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
						INTO cNombreCte
						FROM bdinteg:"informix".si_cliente
						WHERE numcte = TRIM(cNumcte);
						
						LET cNombreCte_Aux = cNombreCte;
						LET cConcepto = 'Saldo Anterior';
						LET cCodigo = '';
						LET cDescripcionpag = '';
						
					ELSE
						LET cNombreCte = cNombreCte_Aux;
						LET cNombreCte_Aux = '';
						LET cConcepto = 'Saldo Nuevo';
						LET cCodigo = '';
						LET cDescripcionpag = '';
						
					END IF
				--Secuencia 2
				ELSE
					LET cConcepto = 'Importe Aplicado';
					LET cNombreCte = '';
					--ADQUIERE EL CODIGO DE PAGO Y SU DESCRIPCION.
					--AAME 21062018 RQM 06 590 - 591 Se contemplan prodcutos Oro y Platino, se agrega TDC GP
					IF cCodProducto IN ('6001','7000','8100','8500') THEN
												
						SELECT LIMIT 1 Codigo,concepto
						INTO cCodigo,cDescripcionpag
						FROM "informix".sd_conceptospagomanual
						WHERE transacc = cTransaccion
						AND cod_fun IN (SELECT codigo_fun FROM "informix".sd_movdia WHERE num_credito = cNumCredito 
										AND folio_suc = cFolio AND transacc_suc = cTransaccion
										UNION ALL
										SELECT codigo_fun FROM "informix".sd_movhis WHERE num_credito = cNumCredito 
										AND folio_suc = cFolio AND transacc_suc = cTransaccion);

					ELSE
						SELECT codigo,concepto
						INTO cCodigo,cDescripcionpag
						FROM "informix".sd_conceptospagomanualcrd
						WHERE transacc = cTransaccion
						AND num_producto= cCodProducto;
					
					END IF;
					
					--OBTIEBE LOS FOLIOS CUANDO ES MASIVO.
					IF pAplicacion = 2 THEN
						SELECT folio, folio_grupo
						INTO cFolio, cfoliogrupo
						FROM "informix".sd_bitacora_pagos
						WHERE num_credito = TRIM(cNumCredito)
						AND folio = TRIM(cFolio)
						AND fecha_pago = dt_FechaMov;
					END IF
				END IF
				

				
				RETURN cCodret, cReg, cSecuencia,cConcepto,cNumCredito, cNombreCte, m_ImportePago,
					mCapVigente, mCapTransitorio, mCapVencido, mCapVdoNoExigible, mCapitalTotal,
					mIntVigente, mIvaIntVigente, mInteresVencido, mIvaIntVencido,
					mIntMoraBase, mIntMoraCopete, mIvaIntMoratorio, dt_FechaMov, cCodigo,
					cDescripcionpag, cfoliogrupo, cFolio, cUsuario, cSucursal,
					cDescRev, cCodProducto, c_DescriPago, cTransaccion, mIntMoratorio,
					mIvaIntMoraBase,mIvaIntMoraCopete WITH RESUME;
			END FOREACH;
			--VALIDA SI ENCUENTRA INFORMACION.
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000004';
			END IF
		ELIF pConsulta = 5 THEN
			IF NVL(pFolio,'') = '' OR pAplicacion = 1 THEN
			-- CONSULTA POR FOLIO MASIVO, Y EL PARAMETRO DE FOLIO ESTA VACIO.
				LET cCodret = '000005';
			ELSE
				LET cReg = '001';				

				FOREACH
					SELECT folio,folio_grupo
					INTO cFolioMas,cfoliogrupo
					FROM "informix".sd_bitacora_pagos
					WHERE folio_grupo = TRIM(pFolio)
					ORDER BY folio_grupo, folio				
					
					FOREACH
						SELECT secuencia, num_credito,fecha_mov,numcte,sucursal,num_producto,folio,concepto_mov,descripcion_pago,
						descripcion_rev,importe_pago,transaccion,capital_vigente,capital_transitorio,capital_vencido,
						capital_vencido_noexigible,capital_total,interes_vigente,iva_interesvigente,
						interes_vencido,iva_interesvencido,interes_moratorio,iva_interesmoratorio,interes_moratorio_base,interes_moratorio_copete,
						iva_interesmoratoriobase,iva_interesmoratoriocopete,usuario
						INTO  cSecuencia,cNumCredito,dt_FechaMov,cNumcte,cSucursal,cCodProducto,cFolio,cConceptoMov,c_DescriPago,
						cDescRev,m_ImportePago,cTransaccion,mCapVigente,mCapTransitorio,mCapVencido,mCapVdoNoExigible,mCapitalTotal,
						mIntVigente,mIvaIntVigente,mInteresVencido,mIvaIntVencido,mIntMoratorio,mIvaIntMoratorio,mIntMoraBase,
						mIntMoraCopete,mIvaIntMoraBase,mIvaIntMoraCopete,cUsuario
						FROM "informix".sd_bitacorapagos
						WHERE fecha_mov BETWEEN p_FechaIni AND p_FechaFin 
						AND status = pStatus
						AND tipo_aplic = pAplicacion
						AND folio = TRIM(cFolioMas)
					
						--CONTADOR DE REGISTROS.
						LET iContReg =iContReg +1;
						
						IF iContReg >= 3 AND cSecuencia = '1' THEN
							
							LET iContReg = 0;
							LET cReg = cReg::INTEGER +1;
							
						END IF
				
						LET cReg = LPAD(TRIM(cReg),3,'0');
						-- LIMPIA LAS VARIABLES QUE NO SE DEBEN MOSTRAR EN ESTAS FILAS Y ADQUIERE EL NOMBRE DEL CLIENTE.
						IF cSecuencia IN ('1','3')THEN
							LET cNombreCte = '';
							LET dt_FechaMov = '';
							LET cFolio = '';
							LET cfoliogrupo = '';
							LET cUsuario = '';
							LET m_ImportePago = NULL;
							LET cCodigo = '';
							LET cDescripcionpag = '';
							IF cSecuencia = 1 THEN
								--SACA EL NOMBRE DEL CLIENTE.
								SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
								INTO cNombreCte
								FROM bdinteg:"informix".si_cliente
								WHERE numcte = TRIM(cNumcte);
								
								LET cNombreCte_Aux = cNombreCte;
								LET cConcepto = 'Saldo Anterior';
								LET cCodigo = '';
								LET cDescripcionpag = '';
								
							ELSE
								LET cNombreCte = cNombreCte_Aux;
								LET cNombreCte_Aux = '';
								LET cConcepto = 'Saldo Nuevo';
								LET cCodigo = '';
								LET cDescripcionpag = '';
								
							END IF
						--Secuencia 2
						ELSE
							LET cConcepto = 'Importe Aplicado';
							LET cNombreCte = '';
							LET cfoliogrupo = TRIM(pFolio);
							--ADQUIERE EL CODIGO DE PAGO Y SU DESCRIPCION.
							--AAME 21062018 RQM 06 590 - 591 Se contemplan prodcutos Oro y Platino, se agrega TDC GP
							IF cCodProducto IN ('6001','7000','8100','8500') THEN
														
								SELECT LIMIT 1 Codigo,concepto
								INTO cCodigo,cDescripcionpag
								FROM "informix".sd_conceptospagomanual
								WHERE transacc = cTransaccion
								AND cod_fun IN (SELECT codigo_fun FROM "informix".sd_movdia WHERE num_credito = cNumCredito 
												AND folio_suc = cFolio AND transacc_suc = cTransaccion
												UNION ALL
												SELECT codigo_fun FROM "informix".sd_movhis WHERE num_credito = cNumCredito 
												AND folio_suc = cFolio AND transacc_suc = cTransaccion);

							ELSE
								SELECT codigo,concepto
								INTO cCodigo,cDescripcionpag
								FROM "informix".sd_conceptospagomanualcrd
								WHERE transacc = cTransaccion
								AND num_producto= cCodProducto;
							
							END IF;
						END IF;
					
						RETURN cCodret, cReg, cSecuencia,cConcepto,cNumCredito, cNombreCte, m_ImportePago,
						mCapVigente, mCapTransitorio, mCapVencido, mCapVdoNoExigible, mCapitalTotal,
						mIntVigente, mIvaIntVigente, mInteresVencido, mIvaIntVencido,
						mIntMoraBase, mIntMoraCopete, mIvaIntMoratorio, dt_FechaMov, cCodigo,
						cDescripcionpag, cfoliogrupo, cFolio, cUsuario, cSucursal,
						cDescRev, cCodProducto, c_DescriPago, cTransaccion, mIntMoratorio,
						mIvaIntMoraBase,mIvaIntMoraCopete WITH RESUME;
					END FOREACH
				END FOREACH
				
				--VALIDA SI ENCUENTRA INFORMACION.
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '000004';
				END IF;
			END IF;
		END IF;
		--VALIDA QUE EL CODIGO DE RETORNO VENGA EXCELENTEMENTE BIEN.
		IF cCodret::INTEGER <> 0 THEN
			LET cReg = '000';
			RETURN cCodret, cReg, cSecuencia, TRIM(NVL(cConcepto,'')), NVL(cNumCredito,''), NVL(cNombreCte,''), NVL(m_ImportePago,0.0),
					NVL(mCapVigente,0.0), NVL(mCapTransitorio,0.0), NVL(mCapVencido,0.0), NVL(mCapVdoNoExigible,0.0), NVL(mCapitalTotal,0.0),
					NVL(mIntVigente,0.0), NVL(mIvaIntVigente,0.0), NVL(mInteresVencido,0.0), NVL(mIvaIntVencido,0.0),
					NVL(mIntMoraBase,0.0), NVL(mIntMoraCopete,0.0), NVL(mIvaIntMoratorio,0.0), NVL(dt_FechaMov,''), NVL(cCodigo,''),
					NVL(cDescripcionpag,''), NVL(cfoliogrupo,''), NVL(cFolio,''), NVL(cUsuario,''), NVL(cSucursal,''),
					NVL(cDescRev,''), NVL(cCodProducto,''), NVL(c_DescriPago,''), NVL(cTransaccion,''), NVL(mIntMoratorio,0.0),
					NVL(mIvaIntMoraBase,0.0), NVL(mIvaIntMoraCopete,0.0);
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Mohamed Carreón, Abigail Vasavilbazo C',
'DESCRIPCION: Procedimiento que obtiene el reporte de pagos manuales y pagos reversados manuales, ya sea por fecha, diario o por folio',
'FECHA: ENERO 2010',
'VERSION: 20100120.1701',
'BD: Bdicred',
'AUTOR: Mario Gamaliel Olivo Urias',
'DESCRIPCION: Se modifica procedimiento para agregarle la consulta para el reporte (masivo y manual) y la consulta para los nuevos ',
'			  conceptoslos cuales son Condonacion y Condonacion por fallecimiento englobados como condonacion, asi como tambien se le ',
'			  agregan mas parametros de entrada y de salida para los nuevos filtros de consulta e informacion para el nuevo reporte.',
'			  Tambien se le agregaron las reglas de informix.',
'FECHA: Diciembre 2013',
'VERSION: 20140114.1803',
'FOLIO:1395',
'BD: Bdicred',
'AUTOR: Mario Gamaliel Olivo Urias',
'DESCRIPCION: Se modifica para agregar la consulta por medio de folio masivo.',
'FECHA: Febrero 2014',
'VERSION: 20140217.1307',
'FOLIO:1395',
'BD: Bdicred';

create procedure "informix".sp_depura_infoedocta_calif()
       returning char(5),CHAR(100),char(60);

    DEFINE vcodret          CHAR(5);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       CHAR(100);
	DEFINE cMensajeRet    	CHAR(100);
		
    DEFINE vsql             CHAR(1500);
	DEFINE vsql2            CHAR(1500);
	DEFINE vsh             CHAR(1500);
	
	DEFINE vfecha_depura				DATE;

	DEFINE nom_arch			CHAR(100);
	DEFINE nom_sql			CHAR(100);
	DEFINE nom_sh			CHAR(100);
	DEFINE bandera_arch CHAR(1);
	DEFINE bandera_periodo  CHAR(6);
	DEFINE ruta_archivo		CHAR(100);
	DEFINE ruta_script		CHAR(100);
	DEFINE cred_del   VARCHAR(20);
	DEFINE fec_del 	 	DATE;
	DEFINE v_periodo CHAR(6);
	DEFINE ctas_dep		integer;
	DEFINE cMensajeRet2    	CHAR(60); DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); 
	
    LET vcodret     = "00111";
	LET cMensajeRet = "Erro:No se realizo la depuracion";
    LET vsql = "";
	LET v_periodo = "";
	LET nom_arch="";
	LET ctas_dep= 0;

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
	  LET vcodret=  iSqlErr;
	  LET cMensajeRet2 = '';
    RETURN vcodret,cMensajeRet,cMensajeRet2;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/ipcb/EDOCTAS/pruebas/sp_depura_infoedocta_calif.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;

	SELECT mdy(month(fecha_hoy),'20',year(fecha_hoy))
	INTO vfecha_depura
	FROM sd_fechas;
	
	LET vfecha_depura = vfecha_depura - 5 units MONTH;
	
	LET v_periodo = lpad(MONTH(vfecha_depura),2,0)||year(vfecha_depura);
	LET ruta_archivo = "/resplogifx/archivoscartera/";
	LET ruta_script = "/resplogifx/archivoscartera/";
	
	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision <= vfecha_depura ) > 0 THEN
			
		SELECT num_credito ,fecha_emision
		FROM sd_info_edocta_calif
		WHERE fecha_emision <= vfecha_depura
		into temp ctas_del with no log;
		
		begin;
		CREATE INDEX idx_ctas_del ON ctas_del (num_credito) ONLINE;
		commit;
	
		FOREACH WITH HOLD
			SELECT num_credito , fecha_emision
			INTO cred_del, fec_del
			FROM ctas_del
			
			BEGIN WORK;
				DELETE FROM sd_info_edocta_calif
	             WHERE fecha_emision  = fec_del
                   AND num_credito = cred_del;		
			COMMIT WORK;
			
			LET ctas_dep = ctas_dep +1;				
		END FOREACH;  
		
		DROP TABLE ctas_del;
		
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;	
		
		LET vcodret     = "00000";
		LET cMensajeRet = "INFORMACION EDOCTA CALIF DEPURADA "||ctas_dep|| " Ok.";	
	END IF;
	
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
  LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;
	
   RETURN vcodret, cMensajeRet,cMensajeRet2;

END;
END PROCEDURE;