CREATE PROCEDURE "informix".sp_obtieneinfocierrediariosucpba(p_sSucursal CHAR(4), p_sEjecutivo CHAR(8), p_sTipoEjecutivo CHAR(1),p_dFechaSucursal DATE, p_sProceso CHAR(1),siRegistros SMALLINT)
RETURNING
CHAR(5) AS CodRet,
INTEGER AS TipoReg,
CHAR(3) AS Empresa,
CHAR(4) AS Sucursal,
CHAR(8) AS Ejecutivo,
CHAR(45) AS Nombre,
CHAR(4) AS Producto,
CHAR(10) AS FechaCierre,
INTEGER AS NumCtasDia,
INTEGER AS MetasCtasDia,
MONEY(18,2) AS MetasCtasCumplidas,
MONEY(18,2) AS MontoCtasDia,
MONEY(18,2) AS MontoIncrementoDia,
MONEY(18,2) AS MetaIncremento,
MONEY(18,2) AS SaldoCumprido,
INTEGER AS NumAbonoCtasCap,
INTEGER AS NumAbonoCtasCred,
MONEY(18,2) AS RecVsPagoMin,
MONEY(18,2) AS RecVsVencido,
INTEGER AS  NumCteAct,
INTEGER AS NumComPago,
INTEGER AS NumAcuerdoPago,
INTEGER AS NumConsEdoCta,
INTEGER AS NumRetiroCaptacion,
INTEGER AS NumRetiroColocacion,
MONEY(18,2) AS v_mMontoAbonoCtasCap,
MONEY(18,2) AS v_mMontoAbonoCtasCred,
MONEY(18,2) AS v_mMontoRetiroCaptacion,
MONEY(18,2) AS v_mMontoRetiroColocacion;

--Declaracion de variables
DEFINE v_sEstatus CHAR(1);
DEFINE v_sCodRet CHAR(5);
DEFINE v_iTipoReg INTEGER;
DEFINE v_sEmpresa CHAR(3);
DEFINE v_sEjecutivo CHAR(8);
DEFINE v_sNombre CHAR(45);
DEFINE v_sProducto CHAR(4);
DEFINE v_sSucursal CHAR(4);
DEFINE v_dFechaCierre CHAR(10);
DEFINE v_iNumCtasDia INTEGER;
DEFINE v_iMetasCtasDia INTEGER;
DEFINE v_mMetasCtasCumplidas MONEY(18,2);
DEFINE v_mMontoCtasDia MONEY(18,2);
DEFINE v_mMontoIncrementoDia MONEY(18,2);
DEFINE v_mMetaIncremento MONEY(18,2);
DEFINE v_mSaldoCumprido MONEY(18,2);
DEFINE v_iNumAbonoCtasCap INTEGER;
DEFINE v_iNumAbonoCtasCred INTEGER;
DEFINE v_mRecVsPagoMin MONEY(18,2);
DEFINE v_mRecVsVencido MONEY(18,2);
DEFINE v_iNumCteAct INTEGER;
DEFINE v_iNumComPago INTEGER;
DEFINE v_iNumAcuerdoPago INTEGER;
DEFINE v_iNumConsEdoCta INTEGER;
DEFINE v_iNumRetiroCaptacion INTEGER;
DEFINE v_iNumRetiroColocacion INTEGER;
DEFINE v_mMontoAbonoCtasCap MONEY(18,2);
DEFINE v_mMontoAbonoCtasCred MONEY(18,2);
DEFINE v_mMontoRetiroCaptacion MONEY(18,2);
DEFINE v_mMontoRetiroColocacion MONEY(18,2);
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_sAnioMes CHAR(6);
DEFINE dMaxFecha    DATE;
DEFINE v_sEstatusSuc CHAR(1);

--Inicializar Variables
LET v_sEstatus = '';
LET v_sCodRet = '00000';
LET v_iTipoReg = 0;
LET v_sEmpresa = '';
LET v_sEjecutivo = '';
LET v_sSucursal = '';
LET v_sNombre = '';
LET v_sProducto = '';
LET v_dFechaCierre = '01-01-1900';
LET v_iNumCtasDia = 0;
LET v_iMetasCtasDia = 0;
LET v_mMetasCtasCumplidas = 0;
LET v_mMontoCtasDia = 0;
LET v_mMontoIncrementoDia = 0;
LET v_mMetaIncremento = 0;
LET v_mSaldoCumprido = 0;
LET v_iNumAbonoCtasCap = 0;
LET v_iNumAbonoCtasCred = 0;
LET v_mRecVsPagoMin = 0;
LET v_mRecVsVencido = 0;
LET v_iNumCteAct = 0;
LET v_iNumComPago = 0;
LET v_iNumAcuerdoPago  = 0;
LET v_iNumConsEdoCta = 0;
LET v_iNumRetiroCaptacion = 0;
LET v_iNumRetiroColocacion = 0;
LET v_mMontoAbonoCtasCap = 0;
LET v_mMontoAbonoCtasCred = 0;
LET v_mMontoRetiroCaptacion = 0;
LET v_mMontoRetiroColocacion = 0;
LET v_iAnio = 0;
LET v_iMes = 0;
LET v_sAnioMes = '';
LET v_sEstatusSuc = '';
BEGIN

Set debug file to "/pisa/pisabanco/sp_obtieneinfocierrediariosuc.out";
Trace on;

LET v_iAnio = YEAR(p_dFechaSucursal);
LET v_iMes = LPAD(MONTH(p_dFechaSucursal),2,0);
LET v_sAnioMes = v_iAnio||LPAD((v_iMes),2,0);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SET ISOLATION TO DIRTY READ;
    SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';

	IF (v_sEstatus = 'V') THEN

		SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = p_sSucursal AND fecha_rptcierre IS NOT NULL;

		IF p_dFechaSucursal = dMaxFecha THEN
			SELECT NVL(estatus,'') INTO v_sEstatusSuc FROM bdmis:mi_rptcierresucestatus WHERE sucursal = p_sSucursal AND fecha_rptcierre = p_dFechaSucursal;
		--ELIF p_dFechaSucursal < dMaxFecha THEN
		--	LET v_sEstatusSuc = 'M';
		ELSE
			LET v_sEstatusSuc = '';
		END IF;

	IF (v_sEstatusSuc <> 'C') AND (p_sTipoEjecutivo = 'E') THEN
        LET v_sCodRet = '00006';
    END IF;



		IF (p_sTipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) or (p_sTipoEjecutivo = 'A'  AND v_sEstatusSuc = 'C') THEN

			IF v_sEstatusSuc = ''  OR p_sProceso = '2' OR siRegistros > 0 THEN  --Se valida que exista algun dato para los datos proporcionados

                IF EXISTS(SELECT Empresa FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND fechacierre = p_dFechaSucursal) THEN
                 foreach
                    SELECT SKIP siRegistros  FIRST 21 v_sCodRet, tipo_reg, empresa, sucursal, ejecutivo, nombre, producto, fechacierre, numctasdia, metactasdia, cumpmetactas,
                       montoctasdia, montoincrementodia, metaincremento, cumpsaldo, numabonosctascap, numabonosctascred, recvspagomin, recvspagovencido,
                       numclientelact, numcompago, numacuerdopago, numconsedocta, numretirocapta, numretirocoloca, montoabonosctascap, montoabonosctascred,
                       montoretirocapta, montoretirocoloca
                    INTO v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                       v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                       v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                       v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion
                    FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND fechacierre = p_dFechaSucursal

                    RETURN  v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                        v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                        v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                        v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion WITH RESUME;
                 end foreach;
                ELSE
				--FOREACH
    				INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
							--Información de Cierre al ultimo corte
							SELECT {+ INDEX(mi_rptcierresuc idx_mi_rptcierresuc)} DISTINCT DECODE(producto, '9999', '3', '1100','1', '2000', '1','1100','1','1300','1','1400','1','1200','1',
                                '1600','1','1800','1','1500','1','1700','1','3000','1','6001','2'),p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
                                TRIM(NVL(nombre,'')),NVL(producto,0),NVL(fecha_cierre,'01-01-1900'),NVL(num_ctasdia,0),NVL(meta_ctasdia,0),
                                NVL(p_cumpmetactas,0),NVL(monto_ctasdia,0),NVL(monto_incrementodia,0),NVL(meta_incremento,0),NVL(p_cumpsaldo,0),
                                NVL(num_abonosctascap,0),NVL(num_abonosctascred,0),NVL(p_rec_vs_pagomin,0),NVL(p_rec_vs_vencido,0),
                                NVL(num_clientel_act,0),NVL(num_compago,0),NVL(num_acuerdopago,0),NVL(num_cons_edocta,0),NVL(num_retirocapta,0),
                                NVL(num_retirocoloca,0),NVL(monto_abonosctascap,0),NVL(monto_abonosctascred,0),NVL(monto_retirocapta,0),
                                NVL(monto_retirocoloca,0)
							FROM bdmis:mi_rptcierresuc
							WHERE empresa IS NOT NULL AND sucursal = p_sSucursal
							AND ejecutivo IS NOT NULL AND  producto IS NOT NULL
							AND fecha_cierre = p_dFechaSucursal;
						--UNION ALL --Información de Cierre en el historial
        			INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
                            SELECT {+ INDEX(mi_rptcierresuchis idx_mi_rptcierresuchis)} DISTINCT DECODE(producto, '9999', '3', '1100','1', '2000', '1','1100','1','1300','1','1400','1','1200','1',
                                '1600','1','1800','1','1500','1','1700','1','3000','1','6001','2'),p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
                                TRIM(NVL(nombre,'')),NVL(producto,0),NVL(fecha_cierre,'01-01-1900'),NVL(num_ctasdia,0),NVL(meta_ctasdia,0),
                                NVL(p_cumpmetactas,0),NVL(monto_ctasdia,0),NVL(monto_incrementodia,0),NVL(meta_incremento,0),NVL(p_cumpsaldo,0),
                                NVL(num_abonosctascap,0),NVL(num_abonosctascred,0),NVL(p_rec_vs_pagomin,0),NVL(p_rec_vs_vencido,0),
                                NVL(num_clientel_act,0),NVL(num_compago,0),NVL(num_acuerdopago,0),NVL(num_cons_edocta,0),NVL(num_retirocapta,0),
                                NVL(num_retirocoloca,0),NVL(monto_abonosctascap,0),NVL(monto_abonosctascred,0),NVL(monto_retirocapta,0),
                                NVL(monto_retirocoloca,0)
  							FROM bdmis:mi_rptcierresuchis
							WHERE empresa IS NOT NULL AND sucursal = p_sSucursal
							AND ejecutivo IS NOT NULL AND producto IS NOT NULL
							AND fecha_cierre =  p_dFechaSucursal;
            		INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
--						UNION ALL --Registro de porcentaje
                            SELECT {+ INDEX(mi_rptcierresucpgeneral idx_mi_rptcierresucpgeneral)} DISTINCT 4,p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),TRIM(NVL(nombre,'')),'',NVL(fecha_cierre,'01-01-1900'),
                                0,0,NVL(p_cumdia_capta,0),NVL(p_cumdia_coloca,0),NVL(p_cumdia_saldo,0),NVL(p_cumdia_general,0),NVL(p_cummes_capta,0),0,
                                0,NVL(p_cummes_coloca,0),NVL(p_cummes_saldo,0),0,0,0,0,0,0,NVL(p_cummes_general,0),0,0,0
						    FROM  bdmis:mi_rptcierresucpgeneral
							WHERE empresa = empresa and sucursal = p_sSucursal
							AND ejecutivo IS NOT NULL AND fecha_cierre = p_dFechaSucursal;
                	INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
						--UNION ALL --Registro Acumulado
							SELECT {+ INDEX(mi_rptcierresucacumulejecut idx_mi_rptcierresucacumulejecut)} DISTINCT DECODE(producto, '9999', '7', '1100','5', '2000', '5','1100','5','1300','5','1400','5','1200','5',
							'1600','5','1800','5','1500','5','1700','5','3000','5','6001','6') ,p_sEjecutivo, empresa,sucursal,ejecutivo as eje4,
							TRIM(nombre) ,producto,NVL(aniomes || 01,0) ,num_ctasmes,meta_ctasmes,p_cumpmetactasmes,monto_ctasmes,monto_incrementomes,meta_incrementomes,
							p_cumpsaldomes,num_abonosctascapmes,num_abonosctascredmes,p_rec_vs_pagominmes,p_rec_vs_vencidomes,num_clientel_actmes,num_compagomes,
							num_acuerdopagomes,num_cons_edoctames,num_retirocaptames,num_retirocolocames,monto_abonosctascapmes,
							monto_abonosctascredmes,monto_retirocaptames,monto_retirocolocames
							FROM bdmis:mi_rptcierresucacumulejecut
							WHERE empresa IS NOT NULL AND sucursal = p_sSucursal AND ejecutivo IS NOT NULL AND producto IS NOT NULL
							AND aniomes = v_sAnioMes;
					--))
            foreach
                    SELECT SKIP siRegistros  FIRST 21 v_sCodRet, tipo_reg, empresa, sucursal, ejecutivo, nombre, producto, fechacierre, numctasdia, metactasdia, cumpmetactas,
                           montoctasdia, montoincrementodia, metaincremento, cumpsaldo, numabonosctascap, numabonosctascred, recvspagomin, recvspagovencido,
                           numclientelact, numcompago, numacuerdopago, numconsedocta, numretirocapta, numretirocoloca, montoabonosctascap, montoabonosctascred,
                           montoretirocapta, montoretirocoloca
                    INTO   v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                           v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                           v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                           v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion
                    FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND fechacierre = p_dFechaSucursal

                    RETURN  v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                        v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                        v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                        v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion WITH RESUME;
             end foreach;
                END IF;
			--	END FOREACH;
    			  if v_sEmpresa = '' then
                        LET v_sCodRet = '00005';
                        LET v_sNombre =  'No existe información del reporte del cierre diario de la sucursal';
                  end if;

                  IF v_sEstatusSuc IS NULL OR v_sEstatusSuc = '' THEN
                        SET LOCK MODE TO WAIT 3;
                        UPDATE bdmis:mi_rptcierresucestatus
                        SET ejecutivo = p_sEjecutivo, estatus = 'C', hora = CURRENT HOUR TO MINUTE
                        WHERE sucursal = p_sSucursal
                        AND fecha_rptcierre = p_dFechaSucursal ;
                  END IF;

			ELSE
					IF  p_sProceso = '1' AND v_sEstatusSuc = 'C' THEN
                        LET v_sCodRet = '00004';
						LET v_sNombre = 'El reporte ya fué revisado por la sucursal';

					END IF;
			END IF;

		ELIF  dMaxFecha IS NULL AND p_sTipoEjecutivo = 'A'  THEN
					LET v_sCodRet = '00005';
					LET v_sNombre =  'No existe información del reporte del cierre diario de la sucursal';
					IF v_sEstatusSuc IS NULL THEN
						SET LOCK MODE TO WAIT 3;
						UPDATE bdmis:mi_rptcierresucestatus
						SET ejecutivo = p_sEjecutivo, estatus = 'C', hora = CURRENT HOUR TO MINUTE
						WHERE sucursal = p_sSucursal
						AND fecha_rptcierre = p_dFechaSucursal ;
					END IF;
		END IF;

	ELIF (v_sEstatus = '') OR (v_sEstatus IS NULL) THEN
        LET v_sCodRet = '00002';
		LET v_sNombre = 'Parámetro de servicio no establecido';
    ELSE
		LET v_sCodRet = '00003';
		LET v_sNombre = 'Servicio no disponible';
	END IF;

    IF v_sCodRet <> '00000' THEN
		RETURN  v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
				v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
				v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
				v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion;
	END IF;

END;
END PROCEDURE;