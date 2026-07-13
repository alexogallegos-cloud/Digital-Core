CREATE PROCEDURE "informix".sp_conssdoedos(cEmpresa CHAR(3),CNumCredito CHAR(20),pultreg SMALLINT)
RETURNING	CHAR(5) AS CodRet,
			CHAR(10) AS fechaperiodo,
			DECIMAL(14,2) AS saldo,
			DECIMAL(14,2) AS mINimo,
			DECIMAL(14,2) AS pagos,
			DECIMAL(14,2) AS pagosactual;

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr			SMALLINT;
DEFINE Ncantidad		SMALLINT;
DEFINE Nciclos			SMALLINT;
DEFINE cCodRet			CHAR(5);
DEFINE cCodRet1  		CHAR(5);
DEFINE Cfechaperiodo	CHAR(10);
DEFINE Nsaldocorte		DECIMAL(14,2);
DEFINE NpagomINimo		DECIMAL(14,2);
DEFINE Npagos			DECIMAL(14,2);
DEFINE Npagosactual     DECIMAL(14,2);
DEFINE dtFechaHoy		DATE;
DEFINE cTipCred			CHAR(2);
DEFINE NSucursal		INTEGER;
DEFINE Niva				DECIMAL(5,3);
DEFINE Ndiacorte		SMALLINT;
DEFINE NdiafIN			SMALLINT;
DEFINE cPeriodos		INTEGER;
DEFINE vPagosHist    DECIMAL (14,2);
DEFINE vPagosAct     DECIMAL (14,2);
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCorte2  DATE;
DEFINE iTotalCtas    INTEGER;

LET sSqlErr			= 0;
LET cCodRet			= '00100';
LET cCodRet1		= '00000';
LET Cfechaperiodo	= '';
LET Nsaldocorte		= 0;
LET NpagomINimo		= 0;
LET Npagos			= 0;
LET Ncantidad		= 0;
LET dtFechaHoy		= DATE(1);
LET cTipCred		= '';
LET NSucursal 		= 0;
LET Niva			= 0;
LET Nciclos			= 0;
LET Ndiacorte		= 0;
LET NdiafIN			= 0;
LET cPeriodos		= 0;
LET vPagosHist  = 0;
LET vPagosAct   = 0;
LET dFechaCorte = DATE(1);
LET dFechaMesiver = DATE(1);
LET dFechaCorte2  = DATE(1);


LET iTotalCtas = 0;
LET Npagosactual = 0;

--SET DEBUG FILE TO '/ifxsif01/joel/Modificados/sp_conssdoedos_pba.out';
	--TRACE ON;

BEGIN
ON EXCEPTION SET sSqlErr
	LET cCodRet = sSqlErr;
	RETURN cCodRet, Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
END EXCEPTION;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa;

	SELECT valor::integer INTO cPeriodos
	FROM bdinteg:"informix".si_param
    WHERE cod_param = 400
    AND empresa = cEmpresa;

	SELECT b.cod_prod,a.sucursal
	INTO cTipCred,NSucursal
	FROM bdicred:"informix".sd_maecred a,
	bdicred:"informix".sd_tipprod b
	WHERE a.num_credito = CNumCredito
	AND a.empresa=cEmpresa
	AND a.empresa=b.empresa
	AND a.num_producto=b.abrevia_prod;

     IF (cTipCred IS NULL) THEN
		SELECT b.cod_prod
		INTO cTipCred
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_tipprod b
		WHERE a.num_credito = CNumCredito
		AND a.empresa=cEmpresa
		AND a.empresa=b.empresa
		AND a.num_producto=b.abrevia_prod;

		IF (cTipCred IS NULL) THEN
			LET cCodRet= '00100';
			RETURN cCodRet, TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
		END IF;
     END IF;

    IF cTipCred='T' THEN
  -- Obtiene fecha de corte
        SELECT dia_corte::INTEGER
        INTO Ndiacorte
        FROM bdicred:"informix".sd_maecredanexo
        WHERE empresa = cEmpresa
        AND num_credito = CNumCredito;

	    IF DAY(dtFechaHoy) <= Ndiacorte THEN
			let dFechaCorte = monthadd(mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy)), -1);
		ELSE
			let dFechaCorte = mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy));
		END IF;
	-- Obtenemos el iva de sucursal
	SELECT iva 
	INTO Niva
	FROM bdinteg:si_sucursales
	WHERE sucursal = NSucursal;

  -- Obtiene pagos realizados historicos
        SELECT NVL(SUM(monto),0)
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhis
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;
  -- Obtiene pagos realizados actual
        SELECT NVL(SUM(monto),0)
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdia
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;

        LET Npagosactual = vPagosHist + vPagosAct;

        FOREACH	WITH HOLD
            SELECT skip pultreg limit 11
			a.fecha fecha,
			ROUND((sdo_moratorio+sdo_contab_mora)*(1 + Niva),2) + sdo_cap_INsoluto +
			INt_tra_no_exig - CASE WHEN NVL(mto_venc_trasp,0) > 0 THEN sdo_INt_anticip ELSE 0 END +
			NVL((SELECT campo_trabajo1
			FROM bdicred:"informix".sd_amortiza_credito
			WHERE a.empresa = empresa
			AND a.num_credito = num_credito
			AND a.fecha = fecha_cuota),0) saldo_corte,
            ROUND((sdo_moratorio+sdo_contab_mora)*(1 + Niva),2) + monto_fINanciado +
            INt_tra_no_exig - CASE WHEN NVL(mto_venc_trasp,0) > 0 THEN sdo_INt_anticip ELSE 0 END +
			NVL((SELECT campo_trabajo1
			FROM bdicred:"informix".sd_amortiza_credito
			WHERE a.empresa = empresa
			AND a.num_credito = num_credito
			AND a.fecha = fecha_cuota),0) pago_mINimo,
            NVL((SELECT SUM(monto)
            FROM bdicred:"informix".sd_movhis d
			WHERE d.empresa = a.empresa
			  AND d.num_credito = a.num_credito
			  AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
			  AND codigo_ref = 1
			  AND reversado = 'N'
			  AND fecha_mov > MONTHadd(a.fecha,-1)
			  AND fecha_mov <= a.fecha),0) monto_pagado
			INTO Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos
			FROM bdicred:"informix".sd_maesdoshist a,
				 bdicred:"informix".sd_maecredanexo b
			WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
			  AND a.fecha <= dFechaCorte
			AND a.fecha >  monthadd(dFechaCorte , -1 * (cPeriodos))
            AND a.num_credito = CNumCredito
            ORDER BY 1 DESC

			LET iTotalCtas = iTotalCtas + 1;
			IF iTotalCtas > cPeriodos THEN
				CONTINUE FOREACH;
			END IF

            LET cCodRet = '00000';
            RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;
            LET Ncantidad = Ncantidad + 1;
        END FOREACH;
    ELSE --lee dia de corte
		SELECT dia_corte::INTEGER
		INTO Ndiacorte
		FROM bdicred:"informix".sd_maecredanexocrd
		WHERE empresa = cEmpresa
		AND num_credito = CNumCredito;

        EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(cEmpresa,Ndiacorte)
        INTO cCodRet1, dFechaMesiver, dFechaCorte;

        IF (cCodRet1 <> '00000') THEN
			LET cCodRet= '00200';
			RETURN cCodRet, TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
        END IF;

-- Obtiene pagos realizados historicos
        SELECT NVL(SUM(monto),0)
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhiscrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov  in (today - 1, today - 2, today - 3, today - 4, today - 5, today - 6, today - 7, today - 8, today - 9, today  - 10, today - 11, today - 12, today - 13, today - 14, today - 15, today - 16,
          today - 17, today -18, today - 19, today - 20, today - 21, today - 22, today - 23, today - 24, today - 25, today  - 26, today - 27, today - 28, today - 29, today - 30, today - 31) 
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
  -- Obtiene pagos realizados actual
        SELECT NVL(SUM(monto),0)
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdiacrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
          
        LET Npagosactual = vPagosHist + vPagosAct;

        LET iTotalCtas = 1;
        LET Ncantidad = 1;
        WHILE iTotalCtas <= cPeriodos and Ncantidad <= (pultreg + 11)
            LET dFechaCorte = monthadd(dtFechaHoy, iTotalCtas * -1);
            --LET Ncantidad = Ncantidad + 1;
            IF ( Ndiacorte = 31 ) or ( Ndiacorte > 28 and month(dFechaCorte)= 2) THEN
                LET dFechaCorte = monthadd(mdy(month(dFechaCorte),1,year(dFechaCorte)),1) - 1 units day;
            ELSE
                LET dFechaCorte = mdy(month(dFechaCorte),Ndiacorte,year(dFechaCorte)) ;
            END IF;

            SELECT
            a.fecha fecha,
            ROUND((sdo_moratorio+sdo_contab_mora)*(1 + Niva),2) + ROUND(sdo_cap_INsoluto,2) + ROUND(INt_tra_no_exig,2) + ROUND(mto_venc_INt,2) + ROUND(sdo_no_exig,2) + ROUND(mto_fINan_vdo,2),
            ROUND((sdo_moratorio+sdo_contab_mora)*(1 + Niva),2) + ROUND(monto_fINanciado,2) + ROUND(INt_tra_no_exig,2) + ROUND(mto_venc_INt,2) + ROUND(sdo_no_exig,2) + ROUND(mto_fINan_vdo,2)
            INTO Cfechaperiodo, Nsaldocorte, NpagomINimo
            FROM bdicred:"informix".sd_maesdoshistcrd a,
                 bdicred:"informix".sd_maecredanexocrd b
            WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
              AND a.num_credito = CNumCredito
              AND a.fecha = dFechaCorte;

              
            let dFechaCorte2 = MONTHadd(dFechaCorte,1);

			SELECT NVL(SUM(monto),0)
			INTO Npagos
			FROM bdicred:"informix".sd_movhiscrd d
			WHERE d.empresa = cEmpresa
			AND d.num_credito = CNumCredito
			AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
			AND codigo_ref = 1
			AND reversado = 'N' AND fecha_mov  in (today - 1, today - 2, today - 3, today - 4, today - 5, today - 6, today - 7, today - 8, today - 9, today  - 10, today - 11, today - 12, today - 13, today - 14, today - 15, today - 16,
                        today - 17, today -18, today - 19, today - 20, today - 21, today - 22, today - 23, today - 24, today - 25, today  - 26, today - 27, today - 28, today - 29, today - 30, today - 31)
			AND fecha_mov between date(dFechaCorte + 1 units day) and dFechaCorte2;

            IF ( Cfechaperiodo is not null ) THEN
                LET cCodRet = '00000';
                IF ( Ncantidad > pultreg ) THEN
                    RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;
                END IF;
                LET Ncantidad = Ncantidad + 1;
            END IF;

            LET iTotalCtas = iTotalCtas + 1;
        END WHILE;
/*
        FOREACH	WITH HOLD
            SELECT
            --LPAD(YEAR(a.fecha),4,0)||'/'||LPAD(MONTH(a.fecha),2,0) fecha,
            date(a.fecha + 1 units day) fecha,
            ROUND((sdo_moratorio+sdo_contab_mora)*1.16,2) + sdo_cap_INsoluto + INt_tra_no_exig + mto_venc_INt + sdo_no_exig + mto_fINan_vdo,
            ROUND((sdo_moratorio+sdo_contab_mora)*1.16,2) + monto_fINanciado + INt_tra_no_exig + mto_venc_INt + sdo_no_exig + mto_fINan_vdo,
            NVL((SELECT SUM(monto)
            FROM bdicred:"informix".sd_movhiscrd d
            WHERE d.empresa = a.empresa
            AND d.num_credito = a.num_credito
            AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
            AND codigo_ref = 1
            AND reversado = 'N'
            AND fecha_mov > a.fecha
            AND fecha_mov <= MONTHadd(a.fecha,1)),0) monto_pagado
            INTO Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos
            FROM bdicred:"informix".sd_maesdoshistcrd a,
                 bdicred:"informix".sd_maecredanexocrd b
            WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
              AND DAY(a.fecha) = DAY(mdy(MONTH(dFechaCorte),b.dia_corte::INTEGER,YEAR(dFechaCorte)) - 1 units DAY)
              AND a.fecha <= dFechaCorte
              AND a.fecha > monthadd(dFechaCorte ,-TRIM(cPeriodos))
              AND a.num_credito = CNumCredito
             ORDER BY 1 DESC

			LET iTotalCtas = iTotalCtas + 1;
			IF iTotalCtas <= pultreg THEN
				CONTINUE FOREACH;
			END IF

            LET cCodRet = '00000';
            RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;

            LET Ncantidad = Ncantidad + 1;
        END FOREACH;
*/
    END IF;

    IF (Ncantidad = 0) THEN
        RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
    END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se parametriza el numero de meses(variable cPeriodos) y se agrega lINea "a.fecha fecha," para obtener fecha completa y se paguina el sp',
'MODIFICO: Claudio Almodovar',
'FECHA: 30/07/2014',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_conssdoedos_mib(cEmpresa CHAR(3),CNumCredito CHAR(20),pultreg SMALLINT)
RETURNING	CHAR(5) AS CodRet,
			CHAR(10) AS fechaperiodo,
			DECIMAL(14,2) AS saldo,
			DECIMAL(14,2) AS mINimo,
			DECIMAL(14,2) AS pagos,
			DECIMAL(14,2) AS pagosactual;

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr			SMALLINT;
DEFINE Ncantidad		SMALLINT;
DEFINE Nciclos			SMALLINT;
DEFINE cCodRet			CHAR(5);
DEFINE cCodRet1  		CHAR(5);
DEFINE Cfechaperiodo	CHAR(10);
DEFINE Nsaldocorte		DECIMAL(14,2);
DEFINE NpagomINimo		DECIMAL(14,2);
DEFINE Npagos			DECIMAL(14,2);
DEFINE Npagosactual     DECIMAL(14,2);
DEFINE dtFechaHoy		DATE;
DEFINE cTipCred			CHAR(2);
DEFINE NSucursal		INTEGER;
DEFINE Niva				DECIMAL(5,3);
DEFINE Ndiacorte		SMALLINT;
DEFINE NdiafIN			SMALLINT;
DEFINE cPeriodos		INTEGER;
DEFINE vPagosHist    DECIMAL (14,2);
DEFINE vPagosAct     DECIMAL (14,2);
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCorte2  DATE;
DEFINE iTotalCtas    INTEGER;

LET sSqlErr			= 0;
LET cCodRet			= '00100';
LET cCodRet1		= '00000';
LET Cfechaperiodo	= '';
LET Nsaldocorte		= 0;
LET NpagomINimo		= 0;
LET Npagos			= 0;
LET Ncantidad		= 0;
LET dtFechaHoy		= DATE(1);
LET cTipCred		= '';
LET NSucursal 		= 0;
LET Niva			= 0;
LET Nciclos			= 0;
LET Ndiacorte		= 0;
LET NdiafIN			= 0;
LET cPeriodos		= 0;
LET vPagosHist  = 0;
LET vPagosAct   = 0;
LET dFechaCorte = DATE(1);
LET dFechaMesiver = DATE(1);
LET dFechaCorte2  = DATE(1);


LET iTotalCtas = 0;
LET Npagosactual = 0;

	--SET DEBUG FILE TO '/ifxsif01/joel/Modificados/sp_conssdoedos_pba.out';
	--TRACE ON;

BEGIN
ON EXCEPTION SET sSqlErr
	LET cCodRet = sSqlErr;
	RETURN cCodRet, Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
END EXCEPTION;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa;

	SELECT valor::integer INTO cPeriodos
	FROM bdinteg:"informix".si_param
    WHERE cod_param = 400
    AND empresa = cEmpresa;
	

	SELECT b.cod_prod,sucursal
	INTO cTipCred,NSucursal
	FROM bdicred:"informix".sd_maecred a,
	bdicred:"informix".sd_tipprod b
	WHERE a.num_credito = CNumCredito
	AND a.empresa=cEmpresa
	AND a.empresa=b.empresa
	AND a.num_producto=b.abrevia_prod;
	
	SELECT iva 
	INTO Niva
	FROM bdinteg:si_sucursales
	WHERE sucursal = NSucursal;

     IF (cTipCred IS NULL) THEN
		SELECT b.cod_prod
		INTO cTipCred
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_tipprod b
		WHERE a.num_credito = CNumCredito
		AND a.empresa=cEmpresa
		AND a.empresa=b.empresa
		AND a.num_producto=b.abrevia_prod;

		IF (cTipCred IS NULL) THEN
			LET cCodRet= '00100';
			RETURN cCodRet, TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
		END IF;
     END IF;

    IF cTipCred='T' THEN
  -- Obtiene fecha de corte
        SELECT dia_corte::INTEGER
        INTO Ndiacorte
        FROM bdicred:"informix".sd_maecredanexo
        WHERE empresa = cEmpresa
        AND num_credito = CNumCredito;

	    IF DAY(dtFechaHoy) <= Ndiacorte THEN
			let dFechaCorte = monthadd(mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy)), -1);
		ELSE
			let dFechaCorte = mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy));
		END IF;

  -- Obtiene pagos realizados historicos
        SELECT NVL(SUM(monto),0)
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhis
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;
  -- Obtiene pagos realizados actual
        SELECT NVL(SUM(monto),0)
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdia
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;

        LET Npagosactual = vPagosHist + vPagosAct;

        FOREACH	WITH HOLD
            SELECT skip pultreg limit 11
			a.fecha fecha,
			ROUND((sdo_moratorio+sdo_contab_mora)*(Niva+1),2) + sdo_cap_INsoluto +
			INt_tra_no_exig - CASE WHEN NVL(mto_venc_trasp,0) > 0 THEN sdo_INt_anticip ELSE 0 END +
			NVL((SELECT campo_trabajo1
			FROM bdicred:"informix".sd_amortiza_credito
			WHERE a.empresa = empresa
			AND a.num_credito = num_credito
			AND a.fecha = fecha_cuota),0) saldo_corte,
            ROUND((sdo_moratorio+sdo_contab_mora)*(Niva+1),2) + monto_fINanciado +
            INt_tra_no_exig - CASE WHEN NVL(mto_venc_trasp,0) > 0 THEN sdo_INt_anticip ELSE 0 END +
			NVL((SELECT campo_trabajo1
			FROM bdicred:"informix".sd_amortiza_credito
			WHERE a.empresa = empresa
			AND a.num_credito = num_credito
			AND a.fecha = fecha_cuota),0) pago_mINimo,
            NVL((SELECT SUM(monto)
            FROM bdicred:"informix".sd_movhis d
			WHERE d.empresa = a.empresa
			  AND d.num_credito = a.num_credito
			  AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
			  AND codigo_ref = 1
			  AND reversado = 'N'
			  AND fecha_mov > MONTHadd(a.fecha,-1)
			  AND fecha_mov <= a.fecha),0) monto_pagado
			INTO Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos
			FROM bdicred:"informix".sd_maesdoshist a,
				 bdicred:"informix".sd_maecredanexo b
			WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
			  AND a.fecha <= dFechaCorte
			AND a.fecha >  monthadd(dFechaCorte , -1 * (cPeriodos))
            AND a.num_credito = CNumCredito
            ORDER BY 1 DESC

			LET iTotalCtas = iTotalCtas + 1;
			IF iTotalCtas > cPeriodos THEN
				CONTINUE FOREACH;
			END IF

            LET cCodRet = '00000';
            RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;
            LET Ncantidad = Ncantidad + 1;
        END FOREACH;
    ELSE --lee dia de corte
		SELECT dia_corte::INTEGER
		INTO Ndiacorte
		FROM bdicred:"informix".sd_maecredanexocrd
		WHERE empresa = cEmpresa
		AND num_credito = CNumCredito;

        EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(cEmpresa,Ndiacorte)
        INTO cCodRet1, dFechaMesiver, dFechaCorte;

        IF (cCodRet1 <> '00000') THEN
			LET cCodRet= '00200';
			RETURN cCodRet, TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
        END IF;

-- Obtiene pagos realizados historicos
        SELECT NVL(SUM(monto),0)
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhiscrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
  -- Obtiene pagos realizados actual
        SELECT NVL(SUM(monto),0)
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdiacrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
          
        LET Npagosactual = vPagosHist + vPagosAct;

        LET iTotalCtas = 1;
        LET Ncantidad = 1;
        WHILE iTotalCtas <= cPeriodos and Ncantidad <= (pultreg + 11)
            LET dFechaCorte = monthadd(dtFechaHoy, iTotalCtas * -1);
            --LET Ncantidad = Ncantidad + 1;
            IF ( Ndiacorte = 31 ) or ( Ndiacorte > 28 and month(dFechaCorte)= 2) THEN
                LET dFechaCorte = monthadd(mdy(month(dFechaCorte),1,year(dFechaCorte)),1) - 1 units day;
            ELSE
                LET dFechaCorte = mdy(month(dFechaCorte),Ndiacorte,year(dFechaCorte)) ;
            END IF;

            SELECT
            a.fecha fecha,
            ROUND((sdo_moratorio+sdo_contab_mora)*(Niva+1),2) + ROUND(sdo_cap_INsoluto,2) + ROUND(INt_tra_no_exig,2) + ROUND(mto_venc_INt,2) + ROUND(sdo_no_exig,2) + ROUND(mto_fINan_vdo,2),
            ROUND((sdo_moratorio+sdo_contab_mora)*(Niva+1),2) + ROUND(monto_fINanciado,2) + ROUND(INt_tra_no_exig,2) + ROUND(mto_venc_INt,2) + ROUND(sdo_no_exig,2) + ROUND(mto_fINan_vdo,2)
            INTO Cfechaperiodo, Nsaldocorte, NpagomINimo
            FROM bdicred:"informix".sd_maesdoshistcrd a,
                 bdicred:"informix".sd_maecredanexocrd b
            WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
              AND a.num_credito = CNumCredito
              AND a.fecha = dFechaCorte;

              
            let dFechaCorte2 = MONTHadd(dFechaCorte,1);

			SELECT NVL(SUM(monto),0)
			INTO Npagos
			FROM bdicred:"informix".sd_movhiscrd d
			WHERE d.empresa = cEmpresa
			AND d.num_credito = CNumCredito
			AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
			AND codigo_ref = 1
			AND reversado = 'N'
			AND fecha_mov between date(dFechaCorte + 1 units day) and dFechaCorte2;

            IF ( Cfechaperiodo is not null ) THEN
                LET cCodRet = '00000';
                IF ( Ncantidad > pultreg ) THEN
                    RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;
                END IF;
                LET Ncantidad = Ncantidad + 1;
            END IF;

            LET iTotalCtas = iTotalCtas + 1;
        END WHILE;
/*
        FOREACH	WITH HOLD
            SELECT
            --LPAD(YEAR(a.fecha),4,0)||'/'||LPAD(MONTH(a.fecha),2,0) fecha,
            date(a.fecha + 1 units day) fecha,
            ROUND((sdo_moratorio+sdo_contab_mora)*1.16,2) + sdo_cap_INsoluto + INt_tra_no_exig + mto_venc_INt + sdo_no_exig + mto_fINan_vdo,
            ROUND((sdo_moratorio+sdo_contab_mora)*1.16,2) + monto_fINanciado + INt_tra_no_exig + mto_venc_INt + sdo_no_exig + mto_fINan_vdo,
            NVL((SELECT SUM(monto)
            FROM bdicred:"informix".sd_movhiscrd d
            WHERE d.empresa = a.empresa
            AND d.num_credito = a.num_credito
            AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
            AND codigo_ref = 1
            AND reversado = 'N'
            AND fecha_mov > a.fecha
            AND fecha_mov <= MONTHadd(a.fecha,1)),0) monto_pagado
            INTO Cfechaperiodo, Nsaldocorte, NpagomINimo, Npagos
            FROM bdicred:"informix".sd_maesdoshistcrd a,
                 bdicred:"informix".sd_maecredanexocrd b
            WHERE a.empresa = b.empresa
              AND a.num_credito = b.num_credito
              AND DAY(a.fecha) = DAY(mdy(MONTH(dFechaCorte),b.dia_corte::INTEGER,YEAR(dFechaCorte)) - 1 units DAY)
              AND a.fecha <= dFechaCorte
              AND a.fecha > monthadd(dFechaCorte ,-TRIM(cPeriodos))
              AND a.num_credito = CNumCredito
             ORDER BY 1 DESC

			LET iTotalCtas = iTotalCtas + 1;
			IF iTotalCtas <= pultreg THEN
				CONTINUE FOREACH;
			END IF

            LET cCodRet = '00000';
            RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual WITH RESUME;

            LET Ncantidad = Ncantidad + 1;
        END FOREACH;
*/
    END IF;

    IF (Ncantidad = 0) THEN
        RETURN cCodRet,TRIM(Cfechaperiodo), Nsaldocorte, NpagomINimo, Npagos, Npagosactual;
    END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se parametriza el numero de meses(variable cPeriodos) y se agrega lINea "a.fecha fecha," para obtener fecha completa y se paguina el sp',
'MODIFICO: Claudio Almodovar',
'FECHA: 30/07/2014',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_depura_sd_amortiza_2()
--EXECUTE PROCEDURE sp_depura_sd_amortiza_2();
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);   -- mensaje

-- Modificacion -> Se hardcodea la fecha por motivo de que no corre con la variable dFechaDepura

DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
DEFINE sHoraInicial	SMALLINT;
DEFINE sHoraFinal	SMALLINT;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE iCuentasProcesadas	INTEGER;
DEFINE iCount_sd_amortiza_credito_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = date(1);
LET sHoraInicial = 0;
LET sHoraFinal	 = 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET iCuentasProcesadas	= 0;
LET iCount_sd_amortiza_credito_old	= 0;
LET cProceso		= '0003';
LET P_COD_RET   	= '000000';

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;	
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;
			CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;			
            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/RESPALDOSNEW/Ulises/sp_depura_sd_movhis2.out';
    --TRACE ON;

    CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
	--begin; update "informix".sd_param_movhis_dep set num_credito = '' where proceso = 10; commit;
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 10;

    IF vNumCredAux = '' OR vNumCredAux IS NULL THEN 
       --LET vNumCredAux = '0'; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(10,'0');
    END IF;

--    select fecha_insert
--      into dFechaDepura
--    from sd_param
--    where empresa = '001'
--    and cod_param = '800'; 

    SELECT valor
      INTO dFechaDepura
      FROM "informix".sd_param
     WHERE cod_param = '115';

    IF dFechaDepura IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '115', 'FECHA DEPURACION AMORTIZA_CREDITO CUENTAS ACTIVAS', '12/31/2018', user, TODAY);
			
		--LET dFechaDepura = mdy('12','31','2018');
	END IF;

	SELECT valor
      INTO sHorasProceso
      FROM "informix".sd_param
     WHERE cod_param = '116';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '116', 'PARAMETRO DE HORAS A PROCESAR CUENTAS ACTIVAS', '5', user, TODAY);

		--LET sHorasProceso = 5;
    END IF;

       SELECT num_credito
           FROM "informix".sd_maecred
           WHERE empresa  = '001' 
            AND num_credito > vNumCredAux
			AND status_cred IN ('AA','BA','BT')
			INTO TEMP cuentas_activas WITH NO LOG;
		
		UPDATE STATISTICS MEDIUM FOR TABLE cuentas_activas;
		
	FOREACH WITH HOLD	

		SELECT TRIM(num_credito)
           INTO vNumCred 
        FROM cuentas_activas
		ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;

            insert into "informix".sd_amortiza_credito_old --sd_amortiza_credito_14
            select * from "informix".sd_amortiza_credito
            where empresa = '001'
            and fecha_cuota <= mdy('12','31','2018') --dFechaDepura
            and num_credito = vNumCred
            and capital_status = 5;

            DELETE FROM "informix".sd_amortiza_credito
            where empresa = '001'
            and fecha_cuota <= mdy('12','31','2018') --dFechaDepura
            and num_credito = vNumCred
            and capital_status = 5;

			LET iCount_sd_amortiza_credito_old	= iCount_sd_amortiza_credito_old + 1;
						
			UPDATE "informix".sd_param_movhis_dep
			SET num_credito = vNumCred
			where proceso = 10;		

        COMMIT WORK;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			EXIT FOREACH;
		END IF;
		
    END FOREACH;
	drop table cuentas_activas;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_amortiza_credito_old : ' ||iCount_sd_amortiza_credito_old;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = 'El proceso DEPURA CUENTAS ACTIVAS termino exitosamente. Cuentas procesadas ' || iCuentasProcesadas;

	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	
    RETURN cCodRet,cMensaje;

    END
END PROCEDURE;