CREATE PROCEDURE "informix".sp_consregresasaldosmovccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pTipoProd INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(60) 	AS  descripcion,
		CHAR(60)	 AS num_ccl,
		MONEY(18,2)  AS cargos_dia,
		MONEY(18,2)  AS abonos_dia, 
		MONEY(18,2)  AS saldo_inicio_dia,
		MONEY(18,2)  AS saldo_fin_de_dia;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE cNumCcl CHAR(60);
	DEFINE cCargosDia MONEY(18,2);
	DEFINE mAbonosDia MONEY(18,2); 
	DEFINE mSaldoInicioDia MONEY(18,2);
	DEFINE mSaldoFinDia MONEY(18,2);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cDescripcion = '';
	LET cNumCcl = '';
	LET cCargosDia = 0.0;
	LET mAbonosDia = 0.0; 
	LET mSaldoInicioDia = 0.0;
	LET mSaldoFinDia = 0.0;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion, cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consregresasaldosmovccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFecha IS NULL OR pTipoProd IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion,cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDescripcion, cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_conciliar_saldos_hist('001',pFecha, pTipoProd)
			INTO cCodRetSp, cDescripcion,cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_conciliar_saldos_hist";
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';			
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(TRIM(cDescripcion)),cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia  WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cDescripcion, cNumCcl,cCargosDia,mAbonosDia,mSaldoInicioDia,mSaldoFinDia;
		END IF;		
		END;		
END PROCEDURE

DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 21/10/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD:CONCILIACIÓN SALDOS Y MOVIMIENTOS DE CRÉDITO',
'DESCRIPCION: SPL que regresa la conciliacion de los saldos y movimientos de credito vs la balanza contable ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteconccreditoccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(25)	AS id_producto,
		CHAR(40)	AS concepto, 
		CHAR(14)	AS nivel_contable, 
		MONEY(18,2)	AS saldo_operativo, 
		MONEY(18,2)	AS saldo_contable, 
		MONEY(18,2)	AS saldo_diferente;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdProducto	CHAR(25);
	DEFINE cConcepto	CHAR(40);
	DEFINE cNivelContable 	CHAR(14);
	DEFINE mSaldoOperativo	MONEY(18,2);
	DEFINE mSaldoContable 	MONEY(18,2);
	DEFINE mSaldoDiferente	MONEY(18,2);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cIdProducto		= '';
	LET cConcepto		= '';
	LET cNivelContable 	= '';
	LET mSaldoOperativo	= 0.00;
	LET mSaldoContable 	= 0.00;
	LET mSaldoDiferente	= 0.00;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteconccreditoccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente ;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente ;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rconcilsdoscred2('001',pRegistros, pRecuperacion)
			INTO cCodRetSp, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicred:sp_rconcilsdoscred2';
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2  THEN
				LET cCodRet = '00105';
			END IF;			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProducto,cConcepto,cNivelContable,mSaldoOperativo,mSaldoContable,mSaldoDiferente;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 21/10/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD:CONCILIACIÓN SALDOS Y MOVIMIENTOS DE CRÉDITO',
'DESCRIPCION: SPL que genera el reporte de conciliacion de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteconcreditomovccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(25) 	AS 	id_producto,
		CHAR(40)	AS	descripcion,
		CHAR(14)	AS	nivel_contable, 
		MONEY(18,2)	AS	abono_operativo,
		MONEY(18,2)	AS	cargo_operativo, 
		MONEY(18,2)	AS	abono_conta, 
		MONEY(18,2)	AS	cargo_conta, 
		MONEY(18,2)	AS	abonos_dif, 
		MONEY(18,2)	AS	cargos_dif;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdProducto	CHAR(25);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cNivelContable 	CHAR(14);
	DEFINE mAbonoOperativo	MONEY(18,2);
	DEFINE mCargoOperativo	MONEY(18,2);
	DEFINE mAbonoConta 	MONEY(18,2);
	DEFINE mCargoConta 	MONEY(18,2);
	DEFINE mAbonosDif 	MONEY(18,2);
	DEFINE mCargosDif	MONEY(18,2);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cIdProducto		= '';
	LET cDescripcion	= '';
	LET cNivelContable 	= '';
	LET mAbonoOperativo	= 0.00;
	LET mCargoOperativo	= 0.00;
	LET mAbonoConta 	= 0.00;
	LET mCargoConta 	= 0.00;
	LET mAbonosDif 		= 0.00;
	LET mCargosDif		= 0.00;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteconcreditomovccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rconcilsdoscredmov2('001',pRegistros, pRecuperacion)
			INTO cCodRetSp, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicred:sp_rconcilsdoscredmov2';
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2  THEN
				LET cCodRet = '00105';
			END IF;			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProducto, cDescripcion, cNivelContable, mAbonoOperativo, mCargoOperativo, mAbonoConta, mCargoConta, mAbonosDif, mCargosDif;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 21/10/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD:CONCILIACIÓN SALDOS Y MOVIMIENTOS DE CRÉDITO',
'DESCRIPCION: SPL que genera el reporte de conciliacion de movimientos de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertacreditocontaccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE,pNivelCcl CHAR(14),pSaldoConta MONEY(18,2),pSdoCargosConta MONEY(18,2), pSdoAbonosConta MONEY(18,2), pSdoFinDia MONEY(18,2), pSdoAbonos MONEY(18,2), pSdoCargos MONEY(18,2), pDescripcion CHAR(50), pTipoProd INTEGER)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertacreditocontaccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR  pNivelCcl = '' OR  pTipoProd IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_inserta_conciliador_cred_vs_conta(pFecha,pNivelCcl,pSaldoConta,pSdoCargosConta, pSdoAbonosConta, pSdoFinDia, pSdoAbonos, pSdoCargos, pDescripcion, pTipoProd)
		INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_inserta_conciliador_cred_vs_conta";
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';			
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;		
				
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
		END;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 21/10/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD:CONCILIACIÓN SALDOS Y MOVIMIENTOS DE CRÉDITO',
'DESCRIPCION: SPL que inserta en la tabla sd_conciliacredito, los cargos, abonos, saldo inicio y saldo final',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ss_cnsif_confirmaejecutivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_cnsif_confirmaejecutivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE  bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,pIdFuncion)
		INTO cCodRetSp;	
		
			IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_confirmaejecutivo";
			ELIF cCodRetSp::INTEGER = 28  THEN
				LET cCodRet = '00028';
			END IF;
	
		RETURN cCodRet;
	END;	
		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 08/01/2016',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION:SPL que verifica la existencia del usuario y si cuenta con permisos de ejecucion del SP',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaestatuscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pNumCte CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS status;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(1);
	DEFINE cNumCte CHAR(20);
	DEFINE cFecha  CHAR(20);
	DEFINE cSecuencia INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';
	LET cNumCte = '';
	LET cFecha = '';
	LET cSecuencia = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaestatuscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		IF pNumCte <> ''  THEN 		
			SELECT MAX (secuencia)
			INTO  cSecuencia
			FROM bdisolic:"informix".ss_clientes_exentos_rgc
			WHERE numcte = pNumCte;
			
			
		ELIF pNumSolicitud <> '' THEN 
			SELECT  MAX (secuencia)
			INTO  cSecuencia
			FROM bdisolic:"informix".ss_clientes_exentos_rgc
			WHERE  num_solicitud  = pNumSolicitud;
		END IF 
						
				SELECT activo
				INTO cStatus
				FROM bdisolic:"informix".ss_clientes_exentos_rgc 
				WHERE secuencia = cSecuencia;
				
				
		RETURN cCodRet, cStatus;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'cFecha: 12/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la búsqueda por número de solicitud o número de cliente para que muestre el estatus del credito grupo coppel..',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultavalidapermisoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(8))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iRecuperacion = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultavalidapermisoscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicred:"informix".sp_validarpermisousuariocac2(pEjecutivo)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP baicred:sp_validarpermisousuariocac2';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00796';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00797';
		END IF;
		
		LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet;
		
		IF iRecuperacion = 0  THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez ',
'FECHA: 03/05/2015',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la validación de los ejecutivos ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_genreportevalidacionhuellacoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIncio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		DATE AS  fecha,
		CHAR(20) AS no_solicitud,
		CHAR(20) AS no_cte,
		CHAR(104) AS nombre_cte,
		CHAR(4) AS sucursal,
		DATE AS fecha_solitud,
		CHAR(80) AS nombre_aut1,
		CHAR(80) AS nombre_aut2;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE cNoSolicitud CHAR(20);
	DEFINE cNoCte CHAR(20);
	DEFINE cNombreCte CHAR(104);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSol DATE ;
	DEFINE cNombreAut1 CHAR(80);
	DEFINE cNombreAut2 CHAR(80);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha= '';
	LET cNoSolicitud = '';
	LET cNoCte = '';
	LET cNombreCte = '';
	LET cSucursal = '';
	LET dFechaSol = '';
	LET cNombreAut1 = '';
	LET cNombreAut2 = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreportevalidacionhuellacoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIncio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		 FOREACH SELECT SKIP pRegistros FIRST pRecuperacion fecha_insert, num_solicitud, numcte, nombre_cte, sucursal, fecha_sol
			, nombre_autorizador1, nombre_autorizador2
				INTO dFecha, cNoSolicitud, cNoCte, cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2
			FROM bdisolic:"informix".ss_clientes_exentos_rgc
			WHERE fecha_insert BETWEEN pFechaIncio AND pFechaFin
			ORDER BY 1
		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte, UPPER(TRIM(cNombreCte)), cSucursal, dFechaSol, UPPER(TRIM(cNombreAut1)), UPPER(TRIM(cNombreAut2)) WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cNoSolicitud, cNoCte,cNombreCte, cSucursal, dFechaSol, cNombreAut1, cNombreAut2;
        END IF;         
        
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE VALIDACIÓN HUELLA EN LÍNEA',
'DESCRIPCION:SPL que realiza consulta los clientes que tiene credito grupo coppel para la generación del reporte validacion huella en línea.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_genreportevalidacionhuellacoppel_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIncio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
		BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreportevalidacionhuellacoppel_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIncio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT  COUNT(*)
			INTO iNoRegistros
			FROM bdisolic:"informix".ss_clientes_exentos_rgc
			WHERE fecha_insert BETWEEN pFechaIncio AND pFechaFin;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE VALIDACIÓN HUELLA EN LÍNEA',
'DESCRIPCION:SPL que consulta el total de los clientes que tiene credito grupo coppel para la generación del reporte validacion huella en línea.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abonotransfersoc( pSucursal   CHAR(4), 
                                                 pUsuario    CHAR(8),
                                                 pTransacc   CHAR(4),
                                                 pCuenta     CHAR(20),
                                                 pCheque     INTEGER,
                                                 pMonto      DECIMAL(14,2),
                                                 pReferencia CHAR(40),
                                                 pTarjeta    CHAR(16) )
RETURNING CHAR(5), CHAR(40);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(40);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cProceso     CHAR(10);
    DEFINE cStatusTar   CHAR(1);
    DEFINE cHora        CHAR(15);
    DEFINE cFolio       CHAR(16);
    DEFINE cCodRet4     CHAR(5);
    
    LET cCodRet1   = '';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET cProceso   = '';
    LET cStatusTar = '';
    LET cHora      = '';
    LET cFolio     = '';
    LET cCodRet4   = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_abonotransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cCodRet3;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_abonotransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pMonto     is null OR pMonto <= 0.00 ) OR
       ( pSucursal  is null OR pSucursal = '' OR LENGTH(pSucursal) <> 4 ) OR
       ( pUsuario   is null OR pUsuario  = '' OR LENGTH(pUsuario)  <> 8 ) OR
       ( pTransacc  is null OR pTransacc = '' OR LENGTH(pTransacc) <> 4 ) OR
       ( ( pCuenta  is null OR pCuenta   = '' OR LENGTH(pCuenta)   <> 11 ) AND 
         ( pTarjeta is null OR pTarjeta  = '' OR LENGTH(pTarjeta)  <> 16 ) ) THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PARAMETROS INSUFICENTES';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // VALIDA PROCESO DE LA TRANSACCION
    SELECT proceso
      INTO cProceso
      FROM bdicheq:sc_trxtrfabonosoc
     WHERE transacc = pTransacc;
     
    IF cProceso is null OR cProceso = '' THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // OBTIENE CUENTA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pCuenta is null OR pCuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pCuenta, cStatusTar
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pTarjeta;
           
        IF pCuenta is null OR cStatusTar is null OR cStatusTar <> 'A' THEN
            LET cCodRet1 = '200';
            LET cCodRet3 = 'CUENTA CANCELADA';
            RETURN cCodRet1, cCodRet3;
        END IF;
    END IF;
    
    -- // OBTIENE TARJETA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pTarjeta is null OR pTarjeta = '' THEN
        SELECT num_tarjeta
          INTO pTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pCuenta
           AND secuencia = (SELECT MAX(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pCuenta)
           AND status_tar = 'A';
           
        IF pTarjeta is null THEN
            LET pTarjeta = '';
        END IF;
    END IF;
    
    -- // APLICA EL ABONO EN LA CUENTA
    IF cProceso = 'abono_ref' THEN
        
        LET cHora = CURRENT HOUR TO FRACTION;
        LET cFolio = pUsuario||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
        
        CALL bdicheq:abono_ref( '001', pSucursal, pUsuario, pTransacc, '0000', cFolio, pCuenta, 0, pMonto, pMonto, 0, 0, 0, '01', pReferencia, pTarjeta, pUsuario ) 
        RETURNING cCodRet4;
        
        IF cCodRet4 <> '000' THEN
            LET cCodRet1 = cCodRet4;
            LET cCodRet3 = 'ERROR EN EL PROCESO DE ABONO';
            RETURN cCodRet1, cCodRet3;
        END IF;
        
    ELSE
        
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO DE ABONO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
        
    END IF;
    
    LET cCodRet1 = '000';
    LET cCodRet3 = 'DEPOSITO REALIZADO CORRECTAMENTE';
    
    END;
    
    RETURN cCodRet1, cCodRet3;
    
END PROCEDURE;