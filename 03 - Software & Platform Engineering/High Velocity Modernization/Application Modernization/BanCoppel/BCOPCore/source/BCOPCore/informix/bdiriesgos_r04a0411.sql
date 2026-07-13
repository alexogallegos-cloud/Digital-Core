CREATE PROCEDURE "informix".r04a0411(p_empresa varchar(3), p_fecha_tc date)

RETURNING CHAR(5),varchar(64);

DEFINE vCodret          char(3);
DEFINE iSqlErr          integer;
DEFINE iSamErr          integer;
DEFINE cVarDataErr      varchar(64);

DEFINE tnumrenglon      int;
DEFINE tprecio_compra   int;
DEFINE tclaveparam      int;
DEFINE tvalorparam      char(255);

DEFINE tTotalcartera    money(18,2); --19

DEFINE tTotvigente      money(18,2); --13
DEFINE tPrivigente      money(18,2); --11
DEFINE tIntvigente      money(18,2); --12
--A
DEFINE tTotvigsv        money(18,2); -- 5
DEFINE tPrivigsvMN      money(18,2); -- 1
DEFINE tPrivigsvUD      money(18,2); -- 2
DEFINE tIntvigsvMN      money(18,2); -- 3
DEFINE tIntvigsvUD      money(18,2); -- 4
--B
DEFINE tTotvigcv        money(18,2); --10
DEFINE tPrivigcvMN      money(18,2); -- 6
DEFINE tPrivigcvUD      money(18,2); -- 7
DEFINE tIntvigcvMN      money(18,2); -- 8
DEFINE tIntvigcvUD      money(18,2); -- 9
--C
DEFINE tTotvencida      money(18,2); --18
DEFINE tPrivencidaMN    money(18,2); --14
DEFINE tPrivencidaUD    money(18,2); --15
DEFINE tIntvencidaMN    money(18,2); --16
DEFINE tIntvencidaUD    money(18,2); --17

DEFINE tMes             char(2);
DEFINE tAnio            char(4);
DEFINE tMesSiguiente    int;
DEFINE tCadFecha        char(10);
DEFINE tDiaUltimo       date;

DEFINE tsaldocolumna1   money(18,2);
DEFINE tsaldocolumna2   money(18,2);
DEFINE tsaldocolumna3   money(18,2);
DEFINE tsaldocolumna4   money(18,2);
DEFINE tsaldocolumna5   money(18,2);
DEFINE tsaldocolumna6   money(18,2);
DEFINE tsaldocolumna7   money(18,2);
DEFINE tsaldocolumna8   money(18,2);
DEFINE tsaldocolumna9   money(18,2);
DEFINE tsaldocolumna10  money(18,2);
DEFINE tsaldocolumna11  money(18,2);
DEFINE tsaldocolumna12  money(18,2);
DEFINE tsaldocolumna13  money(18,2);

--**************************************************
-- Creado por Fabiola Corrales Tapia 06/Feb/2007 --*
-- Debug del Procedure                           --*
                                  --*
--**************************************************

--LET tMes = LPAD (MONTH(p_fecha_tc),2,'0');
--LET tAnio = YEAR(p_fecha_tc);
--EXECUTE PROCEDURE bdicont:diasmes (YEAR(p_fecha_tc), MONTH(p_fecha_tc)) INTO tMesSiguiente;
--LET tCadFecha = tMes||tMesSiguiente||tAnio;
--LET tDiaUltimo = tCadFecha::DATE;

IF p_fecha_tc IS NULL OR p_empresa IS NULL OR p_empresa = '' THEN
    LET vCodRet = '007';
    LET iSqlErr = vCodRet;
    LET IsamErr = 0;
    --// Aplica Raise Exception para que se muestre al usuario el error
    RAISE EXCEPTION iSqlErr, iSamErr, cVarDataErr;
END IF

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = 0, saldocolumna2 =0, saldocolumna3 =0, saldocolumna4 =0, saldocolumna5 =0,
       saldocolumna6 =0, saldocolumna7 =0, saldocolumna8 =0, saldocolumna9 =0, saldocolumna10 =0, saldocolumna11 =0, saldocolumna12 =0,
       saldocolumna13 =0 WHERE clavereporte = 'R040411MN';

LET tprecio_compra = 0;
SELECT NVL(precio_compra,0) INTO tprecio_compra FROM bdinteg:si_histdiv WHERE divisa ='09' AND fecha_tc = p_fecha_tc;

FOREACH
    SELECT claveparam, valorparam INTO tclaveparam, tvalorparam FROM bdirepaut:sp_param  WHERE empresa = p_empresa AND
           substr(claveparam::char(10),1,2) = '11'

    LET tnumrenglon   =0;

    LET tTotalcartera =0;

    LET tTotvigente   =0;
    LET tPrivigente   =0;
    LET tIntvigente   =0;
    --A
    LET tTotvigsv     =0;
    LET tPrivigsvMN   =0;
    LET tPrivigsvUD   =0;
    LET tIntvigsvMN   =0;
    LET tIntvigsvUD   =0;
    --B
    LET tTotvigcv     =0;
    LET tPrivigcvMN   =0;
    LET tPrivigcvUD   =0;
    LET tIntvigcvMN   =0;
    LET tIntvigcvUD   =0;
    --C
    LET tTotvencida   =0;
    LET tPrivencidaMN =0;
    LET tPrivencidaUD =0;
    LET tIntvencidaMN =0;
    LET tIntvencidaUD =0;
    LET tTotalcartera =0;

    --A
    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivigsvMN FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'AA' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(fecha) = YEAR(p_fecha_tc); -- 1

    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivigsvUD FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'AA' AND
               c.divisa ='09'  AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 2
               AND MONTH(fecha) = MONTH(p_fecha_tc) AND YEAR(fecha) = YEAR(p_fecha_tc);
    LET tPrivigsvUD = tPrivigsvUD * tprecio_compra;

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvigsvMN  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'AA' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 3
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(fecha) = YEAR(p_fecha_tc);

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvigsvUD  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'AA' AND
               c.divisa = '09' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 4
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);

    LET tIntvigsvUD = tIntvigsvUD * tprecio_compra;
    LET tPrivigsvMN = tPrivigsvMN + tPrivigsvUD;
    LET tIntvigsvMN = tIntvigsvMN + tIntvigsvUD;
    LET tTotvigsv   = tPrivigsvMN + tIntvigsvMN; --5

    --B
    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivigcvMN FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BA' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 6
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);

    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivigcvUD FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BA' AND
               c.divisa ='09'  AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 7
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);
    LET tPrivigcvUD = tPrivigcvUD * tprecio_compra;

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvigcvMN  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BA' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 8
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvigcvUD  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BA' AND
               c.divisa = '09' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam -- 9
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);
    LET tIntvigcvUD = tIntvigcvUD * tprecio_compra;

    LET tPrivigcvMN = tPrivigcvMN + tPrivigcvUD;
    LET tIntvigcvMN = tIntvigcvMN + tIntvigcvUD;
    LET tTotvigcv   = tPrivigcvMN + tIntvigcvMN; --10

    LET tPrivigente = tPrivigsvMN + tPrivigcvMN; --11
    LET tIntvigente = tIntvigsvMN + tIntvigcvMN; --12
    LET tTotvigente = tPrivigente + tIntvigente; --13

    --C
    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivencidaMN FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BT' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam --14
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);

    SELECT NVL(SUM(s.sdo_cap_insoluto - sdo_no_exig),0) INTO tPrivencidaUD FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BT' AND
               c.divisa ='09'  AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam --15
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);
    LET tPrivencidaUD = tPrivencidaUD * tprecio_compra;

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvencidaMN  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BT' AND
               c.divisa = '01' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam --16
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);

    SELECT NVL(SUM(sdo_no_exig),0) INTO tIntvencidaUD  FROM bdicred:sd_maesdoscont s, bdicred:sd_maecredcont c WHERE c.status_cred = 'BT' AND
               c.divisa = '09' AND s.num_credito = c.num_credito AND s.empresa = p_empresa AND c.num_producto = tvalorparam --17
               AND MONTH(s.fecha) = MONTH(p_fecha_tc) AND YEAR(s.fecha) = YEAR(p_fecha_tc);
    LET tIntvencidaUD = tIntvencidaUD * tprecio_compra;

    LET tPrivencidaMN = tPrivencidaMN + tPrivencidaUD;
    LET tIntvencidaMN = tIntvencidaMN + tIntvencidaUD;
    LET tTotvencida   = tPrivencidaMN + tIntvencidaMN; --18
    LET tTotalcartera = tTotvigente + tTotvencida; --19

    LET tnumrenglon   = substr (tclaveparam::char(10),3,4);

    UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tTotalcartera, saldocolumna2 = saldocolumna2 + tTotvigente,
           saldocolumna3 = saldocolumna3 + tPrivigente, saldocolumna4 = saldocolumna4 + tIntvigente, saldocolumna5 = saldocolumna5 + tTotvigsv,
           saldocolumna6 = saldocolumna6 + tPrivigsvMN, saldocolumna7 = saldocolumna7 + tIntvigsvMN, saldocolumna8 = saldocolumna8 + tTotvigcv,
           saldocolumna9 = saldocolumna9 + tPrivigcvMN, saldocolumna10 = saldocolumna10 + tIntvigcvMN, saldocolumna11 = saldocolumna11 + tTotvencida,
           saldocolumna12 = saldocolumna12 + tPrivencidaMN, saldocolumna13 = saldocolumna13 + tIntvencidaMN
           WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = tnumrenglon;
END FOREACH;

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = ROUND(saldocolumna1,0), saldocolumna2 = ROUND(saldocolumna2,0),
       saldocolumna3 = ROUND(saldocolumna3,0), saldocolumna4 = ROUND(saldocolumna4,0), saldocolumna5 = ROUND(saldocolumna5,0),
       saldocolumna6 = ROUND(saldocolumna6,0), saldocolumna7 = ROUND(saldocolumna7,0), saldocolumna8 = ROUND(saldocolumna8,0),
       saldocolumna9 = ROUND(saldocolumna9,0), saldocolumna10 = ROUND(saldocolumna10,0), saldocolumna11 = ROUND(saldocolumna11,0),
       saldocolumna12 = ROUND(saldocolumna12,0), saldocolumna13 = ROUND(saldocolumna13,0)
       WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa;

FOREACH
    SELECT numerorenglon, saldocolumna1, saldocolumna2, saldocolumna3, saldocolumna4, saldocolumna5, saldocolumna6,
           saldocolumna7, saldocolumna8, saldocolumna9, saldocolumna10, saldocolumna11, saldocolumna12, saldocolumna13
           INTO tnumrenglon, tsaldocolumna1, tsaldocolumna2, tsaldocolumna3, tsaldocolumna4, tsaldocolumna5, tsaldocolumna6,
           tsaldocolumna7, tsaldocolumna8, tsaldocolumna9, tsaldocolumna10, tsaldocolumna11, tsaldocolumna12, tsaldocolumna13
           FROM bdirepaut:sp_resumenfiltro WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa
           ORDER BY numerorenglon DESC

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna11 = saldocolumna12 + saldocolumna13, saldocolumna8 = saldocolumna9 + saldocolumna10,
       saldocolumna5 = saldocolumna6 + saldocolumna7
       WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = tnumrenglon;

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna3 = saldocolumna6 + saldocolumna9, saldocolumna4 = saldocolumna7 + saldocolumna10
       WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = tnumrenglon;

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna2 = saldocolumna3 + saldocolumna4
       WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = tnumrenglon;

UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna2 + saldocolumna11
       WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = tnumrenglon;

    IF tnumrenglon = 20 OR tnumrenglon = 30 OR tnumrenglon = 40 OR tnumrenglon = 50 OR tnumrenglon = 60 OR tnumrenglon = 70 OR tnumrenglon = 80 THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND (numerorenglon = 20 OR numerorenglon = 10);
     END IF

    IF tnumrenglon = 100 OR tnumrenglon = 110  THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND (numerorenglon = 90 OR numerorenglon = 10);
    END IF

    IF tnumrenglon = 140 OR tnumrenglon = 150  THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND (numerorenglon = 130 OR numerorenglon = 120 OR numerorenglon = 10);
    END IF

    IF tnumrenglon = 160 OR tnumrenglon = 170 OR tnumrenglon = 180 THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND (numerorenglon = 120 OR numerorenglon = 10);
    END IF

    IF tnumrenglon = 200 OR tnumrenglon = 210 OR tnumrenglon = 220 OR tnumrenglon = 230 OR tnumrenglon = 240 THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = 190;
    END IF

    IF tnumrenglon = 260 OR tnumrenglon = 270  THEN
        UPDATE bdirepaut:sp_resumenfiltro SET saldocolumna1 = saldocolumna1 + tsaldocolumna1, saldocolumna2 = saldocolumna2 + tsaldocolumna2,
               saldocolumna3 = saldocolumna3 + tsaldocolumna3, saldocolumna4 = saldocolumna4 + tsaldocolumna4, saldocolumna5 = saldocolumna5 + tsaldocolumna5,
               saldocolumna6 = saldocolumna6 + tsaldocolumna6, saldocolumna7 = saldocolumna7 + tsaldocolumna7, saldocolumna8 = saldocolumna8 + tsaldocolumna8,
               saldocolumna9 = saldocolumna9 + tsaldocolumna9, saldocolumna10 = saldocolumna10 + tsaldocolumna10, saldocolumna11 = saldocolumna11 + tsaldocolumna11,
               saldocolumna12 = saldocolumna12 + tsaldocolumna12, saldocolumna13 = saldocolumna13 + tsaldocolumna13
               WHERE identautoridad = 'CNBV' AND clavereporte = 'R040411MN' AND empresa = p_empresa AND numerorenglon = 250;
    END IF
END FOREACH;
RETURN '000',NULL;
END PROCEDURE;