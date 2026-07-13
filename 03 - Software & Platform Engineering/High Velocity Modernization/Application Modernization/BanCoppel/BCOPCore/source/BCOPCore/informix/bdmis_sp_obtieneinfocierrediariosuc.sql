CREATE PROCEDURE "informix".sp_obtieneinfocierrediariosuc(p_sSucursal CHAR(4), p_sEjecutivo CHAR(8), p_sTipoEjecutivo CHAR(1),p_dFechaSucursal DATE, p_sProceso CHAR(1),siRegistros SMALLINT)
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
MONEY(9,3) AS MetasCtasDia,
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
MONEY(18,2) AS v_mMontoRetiroColocacion,
INTEGER AS NumCtasDiaTDC,
MONEY(9,3) AS MetasCtasDiaTDC,
MONEY(18,2) AS MetasCtasCumplidasTDC;

--Declaracion de variables
DEFINE v_sEstatus CHAR(1);
DEFINE v_sEstatus2 CHAR(1);
DEFINE v_sCodRet CHAR(5);
DEFINE v_iTipoReg INTEGER;
DEFINE v_sEmpresa CHAR(3);
DEFINE v_sEjecutivo CHAR(8);
DEFINE v_sNombre CHAR(45);
DEFINE v_sProducto CHAR(4);
DEFINE v_sSucursal CHAR(4);
DEFINE v_dFechaCierre CHAR(10);
DEFINE v_iNumCtasDia INTEGER;
DEFINE v_iMetasCtasDia MONEY(9,3);
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
DEFINE v_idia CHAR(2);
DEFINE v_sAnioMesDia CHAR(10);
DEFINE v_iMesc CHAR(2);
DEFINE v_iAnioMax INTEGER;
DEFINE v_iMesMax INTEGER;
DEFINE v_sAnioMesMax CHAR(6);
--MANUEL OSUNA
DEFINE v_iNumCtasDiaTDC INTEGER;
DEFINE v_iMetasCtasDiaTDC MONEY(9,3);
DEFINE v_mMetasCtasCumplidasTDC MONEY(18,2);
-- GLI
DEFINE vparam integer;

--Inicializar Variables
LET v_sEstatus = '';
LET v_sEstatus2 = '';
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
LET v_idia = 0;
LET v_sAnioMesDia = 0;
LET v_iMesc = '01';
LET v_iAnioMax = 0;
LET v_iMesMax = 0;
LET v_sAnioMesMax = '';

LET v_iNumCtasDiaTDC = 0;
LET v_iMetasCtasDiaTDC = 0;
LET v_mMetasCtasCumplidasTDC = 0;

BEGIN
--**************************************************************
-- Modificado por Manuel Osuna Valencia
--fecha: 2011-05-06
--Solicito: Jose Luis Puebla Salinas
--Se modifica stored para agregar a la consulta de OFI el producto TDC Entregadas,
--y quitar el promotor virtual
--****************
        -- 
--set debug file to "sp_ObtieneInfoCierreDiarioSuc.out";
--Trace on;

LET v_iAnio = YEAR(p_dFechaSucursal);
LET v_iMes = LPAD(MONTH(p_dFechaSucursal),2,0);
LET v_sAnioMes = v_iAnio||LPAD((v_iMes),2,0);

LET v_idia = LPAD(DAY(p_dFechaSucursal),2,0);

/*if v_idia < 10 then 
    LET v_idia= 0||v_idia;
end if;
*/
if v_iMes < 10 then 
    LET v_iMesc= 0||v_iMes;
else 
    LET v_iMesc= v_iMes;
end if;

LET v_sAnioMesDia = v_iMesc||'/'||v_idia||'/'||v_iAnio;


Let v_idia= v_idia;
LET v_sAnioMesDia = v_sAnioMesDia;
let vparam = p_sSucursal;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;



	SET ISOLATION TO DIRTY READ;
    SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';
	--SELECT rcda INTO v_sEstatus FROM bdmis:mi_sucursalesinfo where num_sucursal = p_sSucursal;
	let vparam = p_sSucursal;
      
	/* 
	SELECT  estatus 
	INTO v_sEstatus2
	FROM bdmis:mi_param 
	WHERE parametro = vparam and descripcion = 'Suc Autorizada';*/
	
	
	IF (v_sEstatus = 'V' /*and v_sEstatus2 = 'V'*/) THEN

		SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = p_sSucursal AND fecha_rptcierre IS NOT NULL;

        LET v_iAnioMax = YEAR(dMaxFecha);
        LET v_iMesMax = LPAD(MONTH(dMaxFecha),2,0);
        LET v_sAnioMesMax = v_iAnioMax||LPAD((v_iMesMax),2,0);

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



		IF (p_sTipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) or (p_sTipoEjecutivo = 'A'  AND v_sEstatusSuc = 'C') or
		(p_sTipoEjecutivo = 'Z'  AND dMaxFecha IS NOT NULL) or (p_sTipoEjecutivo = 'Z'  AND v_sEstatusSuc = 'C') THEN

--                        LET p_dFechaSucursal = p_dFechaSucursal;
--                        LET v_sAnioMes = v_sAnioMes;


			IF v_sEstatusSuc = ''  OR p_sProceso = '2' OR siRegistros > 0 THEN  --Se valida que exista algun dato para los datos proporcionados

                IF EXISTS(SELECT Empresa FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND fechacierre = v_sAnioMesDia) THEN
                 foreach
                    SELECT SKIP siRegistros  FIRST 21 v_sCodRet, tipo_reg, empresa, sucursal, ejecutivo, nombre, producto, fechacierre, numctasdia, metactasdia, cumpmetactas,
                       montoctasdia, montoincrementodia, metaincremento, cumpsaldo, numabonosctascap, numabonosctascred, recvspagomin, recvspagovencido,
                       numclientelact, numcompago, numacuerdopago, numconsedocta, numretirocapta, numretirocoloca, montoabonosctascap, montoabonosctascred,
                       montoretirocapta, montoretirocoloca,numtdc,metanumtdc,cumpmetatdc
                    INTO v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                       v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                       v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                       v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion,v_iNumCtasDiaTDC,v_iMetasCtasDiaTDC,v_mMetasCtasCumplidasTDC
                    FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND (fechacierre = v_sAnioMesDia  or fechacierre = v_sAnioMes or fechacierre = v_sAnioMesDia)
                    /*and not (trim(nombre) = 'PROMOTOR VIRTUAL' and fechacierre = v_sAnioMesDia)*/

                    RETURN  v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                        v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                        v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                        v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion,v_iNumCtasDiaTDC,v_iMetasCtasDiaTDC,v_mMetasCtasCumplidasTDC WITH RESUME;
                 end foreach;
                ELSE
              
				--FOREACH
--JYDG 06/05/2010
/*
    				INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuar io,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
							--Información de Cierre al ultimo corte
							SELECT {+ INDEX(mi_rptcierresuc idx_mi_rptcierresuc)} DISTINCT DECODE(producto, '9999', '3', '1100','1', '2000', '1','1100','1','1300','1','1400','1','1200','1',
                                '1600','1','1800','1','1500','1','1700','1','3000','1','6001','2','6011','6'),p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
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
                                '1600','1','1800','1','1500','1','1700','1','3000','1','6001','2','6011','6'),p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
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
                   IF (v_sAnioMesMax = v_sAnioMes ) THEN
            		INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
--						UNION ALL --Registro de porcentaje
                            SELECT {+ INDEX(mi_rptcierresucpgeneral idx_mi_rptcierresucpgeneral)} DISTINCT 4,p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),TRIM(NVL(nombre,'')),'',NVL(v_sAnioMesDia,'01-01-1900'),
                                0,0,NVL(p_cumdia_capta,0),NVL(p_cumdia_coloca,0),NVL(p_cumdia_saldo,0),NVL(p_cumdia_general,0),NVL(p_cummes_capta,0),0,
                                0,NVL(p_cummes_coloca,0),NVL(p_cummes_saldo,0),0,0,0,0,0,0,NVL(p_cummes_general,0),0,0,0
						    FROM  bdmis:mi_rptcierresucpgeneral
							WHERE empresa = empresa and sucursal = p_sSucursal
							AND ejecutivo IS NOT NULL AND fecha_cierre = dMaxFecha;
                   end if;
*/

/*                	INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca)
						--UNION ALL --Registro Acumulado
							 SELECT DISTINCT DECODE(producto, '9999', '7', '1100','5', '2000', '5','1100','5','1300','5','1400','5','1200','5',
                                '1600','5','1800','5','1500','5','1700','5','3000','5','6001','6'),p_sEjecutivo, NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
                                TRIM(NVL(nombre,'')),NVL(producto,0),NVL(aniomes,0),NVL(num_ctasmes,0),NVL(meta_ctasmes,0),NVL(p_cumpmetactasmes,0),
                                NVL(monto_ctasmes,0),NVL(monto_incrementomes,0),NVL(meta_incrementomes,0),NVL(p_cumpsaldomes,0),
                                NVL(num_abonosctascapmes,0),NVL(num_abonosctascredmes,0),NVL(p_rec_vs_pagominmes,0),NVL(p_rec_vs_vencidomes,0),
                                NVL(num_clientel_actmes,0),NVL(num_compagomes,0),NVL(num_acuerdopagomes,0),NVL(num_cons_edoctames,0),
                                NVL(num_retirocaptames,0),NVL(num_retirocolocames,0),NVL(monto_abonosctascapmes,0),NVL(monto_abonosctascredmes,0),
                                NVL(monto_retirocaptames,0),NVL(monto_retirocolocames,0)
							FROM bdmis:mi_rptcierresucacumulejecut
							WHERE empresa IS NOT NULL AND sucursal = p_sSucursal AND ejecutivo IS NOT NULL AND producto IS NOT NULL
							AND aniomes = v_sAnioMes;
*/

					--))
/*            foreach   
                    SELECT SKIP siRegistros  FIRST 21 v_sCodRet, tipo_reg, empresa, sucursal, ejecutivo, v_sNombre, producto, fechacierre, numctasdia, metactasdia, cumpmetactas,
                           montoctasdia, montoincrementodia, metaincremento, cumpsaldo, numabonosctascap, numabonosctascred, recvspagomin, recvspagovencido,
                           numclientelact, numcompago, numacuerdopago, numconsedocta, numretirocapta, numretirocoloca, montoabonosctascap, montoabonosctascred,
                           montoretirocapta, montoretirocoloca
                    INTO   v_sCodRet,v_iTipoReg,v_sEmpresa,v_sSucursal,v_sEjecutivo,v_sNombre,v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                           v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                           v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                           v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion
                    FROM bdmis:tmp_cifrascierresuc WHERE sucursal = p_sSucursal AND (fechacierre = v_sAnioMesDia or fechacierre = v_sAnioMes)
*/
--JYDG 06/05/2010

                    RETURN  '00005',v_iTipoReg,'',v_sSucursal,v_sEjecutivo,'No existe información del reporte del cierre diario de la sucursal',v_sProducto,v_dFechaCierre,v_iNumCtasDia,v_iMetasCtasDia,v_mMetasCtasCumplidas,
                        v_mMontoCtasDia,v_mMontoIncrementoDia,v_mMetaIncremento,v_mSaldoCumprido,v_iNumAbonoCtasCap,v_iNumAbonoCtasCred,v_mRecVsPagoMin,v_mRecVsVencido,
                        v_iNumCteAct,v_iNumComPago,v_iNumAcuerdoPago,v_iNumConsEdoCta,v_iNumRetiroCaptacion,v_iNumRetiroColocacion,v_mMontoAbonoCtasCap,v_mMontoAbonoCtasCred,
                        v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion,v_iNumCtasDiaTDC,v_iMetasCtasDiaTDC,v_mMetasCtasCumplidasTDC WITH RESUME;
--JYDG 06/05/2010            end foreach;  


                END IF;        
			--	END FOREACH;
    			  if v_sEmpresa = '' then
                        LET v_sCodRet = '00005';
                        LET v_sNombre =  'No existe información del reporte del cierre diario de la sucursal';
                  end if;

-- --JYDG 06/05/2010
    			  if v_sEmpresa = 'No existe información del reporte del cierre diario de la sucursal' then
                        LET v_sCodRet = '00005';
                        LET v_sNombre =  'No existe información del reporte del cierre diario de la sucursal';
                  end if;
-- --JYDG 06/05/2010

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
				v_mMontoRetiroCaptacion,v_mMontoRetiroColocacion,v_iNumCtasDiaTDC,v_iMetasCtasDiaTDC,v_mMetasCtasCumplidasTDC;
	END IF;

END;
END PROCEDURE;