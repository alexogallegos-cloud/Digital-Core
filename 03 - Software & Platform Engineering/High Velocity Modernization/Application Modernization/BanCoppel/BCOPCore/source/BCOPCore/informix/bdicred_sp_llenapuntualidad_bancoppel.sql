CREATE PROCEDURE "informix".sp_llenapuntualidad_bancoppel()
    RETURNING char(6);

    DEFINE cCodRet char(6);
    DEFINE cEmpresa char(3);
    DEFINE cNumCred char(20);
    DEFINE cNumProd char(4);
    DEFINE mCR money(14,2);
    DEFINE mSdoCte money(14,2);
    DEFINE mSdoVencido money(14,2);
    DEFINE mSdoMora money(14,2);
    DEFINE mCT money(14,2);
    DEFINE dFechaIni date;
    DEFINE dFechaFin date;
    DEFINE dFechaHis date; -- Jom fecha his
    DEFINE iMesesAtraso smallint;
    DEFINE cMesAnio char(7);
    DEFINE dEficiencia decimal(7,2);
    DEFINE sql_err integer;
    DEFINE iavisos integer;
    DEFINE ieficiencia integer;
    DEFINE cSql CHAR(2024);
    DEFINE cNombreArchivo1 CHAR(50);
    define cEstatusCred char(02);
 BEGIN

   ON EXCEPTION SET sql_err
      LET cCodRet = sql_err;
      RETURN cCodRet;
   END EXCEPTION;

--   SET DEBUG FILE TO "pagos_puntuales.err";
--   TRACE ON;

   LET cCodRet = "000000";
   LET cEmpresa = "001";
   LET cNumCred = "";
   LET cNumProd = "";
   LET mCR = 0.00;
   LET mSdoCte = 0.00;
   LET mSdoVencido = 0.00;
   LET mCT = 0.00;
   LET dFechaIni = DATE(1);
   LET dFechaFin = DATE(1);
   LET dFechaHis = DATE(1); -- Jom fecha his
   LET iMesesAtraso = 0;
   LET cMesAnio = "";
   LET iavisos = 0;
   LET ieficiencia = 0;
   LET cSql= "";
   let cEstatusCred = '';

   drop TABLE sd_puntualidad_bancoppel;

   CREATE TABLE sd_puntualidad_bancoppel(
    empresa char (4),
    num_credito char(20),
    mesanio char(7),
    num_producto char(4),
    cr MONEY(14,2),
    ct money(14,2),
    saldo money(14,2),
    sdo_vencido money(14,2),
    sdo_moratorio money(14,2),
    num_meses_atraso smallint,
    eficiencia decimal(7,2),
    PRIMARY KEY(empresa,num_credito,mesanio));


   LET  cNombreArchivo1= 'PuntualidadBancoppel' || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';


   LET dFechaFin = mdy(MONTH(CURRENT),20,YEAR(CURRENT));
   LET dFechaIni = mdy(MONTH(CURRENT),21,YEAR(CURRENT));

   LET dFechaHis = dFechaFin;
   IF DAY(CURRENT) >= 21 THEN
       LET dFechaIni = dFechaIni::DATE - 1 UNITS MONTH; -- JOM
       LET dFechaHis = dFechaHis::DATE - 1 UNITS MONTH; -- JOM
   ELSE
       LET dFechaFin = dFechaFin::DATE - 1 UNITS MONTH; -- JOM
       LET dFechaIni = dFechaIni::DATE - 2 UNITS MONTH; -- JOM
       LET dFechaHis = dFechaHis::DATE - 2 UNITS MONTH; -- JOM
   END IF;

   LET cMesAnio = LPAD(TRIM(MONTH(dFechaIni)::CHAR(2)),2,'0') || '/' || YEAR(dFechaIni);

   FOREACH
      SELECT empresa, num_credito, num_producto, status_cred
      INTO   cEmpresa, cNumCred, cNumProd, cEstatusCred
      FROM sd_maecred
      WHERE empresa = '001' and num_credito >= ''

-- no reportar cartera vendida -- ****

      if (cEstatusCred = 'CC' or cEstatusCred = 'CV') then 
         continue foreach;
      end if;

      SELECT NVL(monto_financiado,0), 
             NVL(sdo_capital,0) + NVL(cap_tras_no_venci,0) + NVL(sdo_no_exig,0)+NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),
-- agregar interes mes (vigente) --
             NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),
             NVL(sdo_contab_mora,0)
      INTO mCT, mSdoCte, mSdoVencido, mSdoMora
      FROM sd_maesdoshist 
      WHERE fecha = dFechaHis and empresa = cEmpresa AND num_credito = cNumCred; -- Jom


-- en meses vencidos considerar estado de cuenta (procedure cobranza)


    LET iavisos=0;
    LET ieficiencia=0;

    SELECT SUBSTR(cl_cobra,1,2)+0, SUBSTR(cl_cobra,51,1)+0
    INTO ieficiencia,iavisos
    FROM bdicred:sd_encabezado_edocta
    WHERE fecha_emision = dFechaHis 
    AND num_credito = cNumCred;

      IF iavisos = 0 THEN
         LET iMesesAtraso = "0";
        ELIF iavisos = 1 THEN
         LET iMesesAtraso = "1";
        ELIF iavisos = 2 THEN
         LET iMesesAtraso=  "2";
        ELIF ieficiencia = 2 THEN
         LET iMesesAtraso=  "3";         
        ELIF ieficiencia = 3 THEN
         LET iMesesAtraso=  "4"; 
        ELIF ieficiencia = 4 THEN
         LET iMesesAtraso=  "5"; 
        ELIF ieficiencia = 5 THEN
         LET iMesesAtraso=  "7";
      END IF;
     
      SELECT nvl(SUM(monto),0)
      INTO mCR
      FROM sd_movhis
      WHERE empresa = cEmpresa
      AND num_credito = cNumCred
      AND codigo_fun IN ('033', '333','334','046','342')
      AND codigo_ref = '1' --jom
      AND reversado = 'N'
      AND num_producto = cNumProd
      AND fecha_mov >= dFechaIni and fecha_mov <= dFechaFin;

      SELECT NVL(situacion_pago,0) INTO dEficiencia
      FROM bdisolic:ss_resum_scor_fin
      where empresa = cEmpresa and num_solicitud = cNumCred;

      INSERT INTO sd_puntualidad_bancoppel(empresa, num_credito, mesanio, num_producto, cr, ct, saldo, sdo_vencido, sdo_moratorio,num_meses_atraso,eficiencia)
      VALUES(cEmpresa, cNumCred, cMesAnio, cNumProd, NVL(mCR,0), NVL(mCT,0), NVL(mSdoCte,0), NVL(mSdoVencido,0), NVL(mSdoMora,0),iMesesAtraso,NVL(dEficiencia,0));
   
   END FOREACH;

   LET cSql = 'echo "UNLOAD TO ' || '''sd_puntualidad_bancoppel.unl''' || ' DELIMITER ' || '''|'''  ||
                    ' SELECT empresa,num_credito,mesanio,num_producto,cr,'||            
                    ' ct,saldo,sdo_vencido,sdo_moratorio,num_meses_atraso,eficiencia'||     
                    ' FROM bdicred:sd_puntualidad_bancoppel ' ||
                    ' " > sd_puntualidad_bancoppel1.sql';

   let cSql = cSql;
   SYSTEM cSql;
 
   LET cSql = '';
   LET cSql = 'dbaccess bdicred sd_puntualidad_bancoppel1.sql';
   SYSTEM cSql;

   LET cSql = '';
   LET cSql = "sed 's/|$//g' sd_puntualidad_bancoppel.unl > " || cNombreArchivo1;
   SYSTEM cSql;

   LET cSql = '';
   LET cSQL = 'rm sd_puntualidad_bancoppel.unl sd_puntualidad_bancoppel1.sql';
   SYSTEM cSql;
   
-- LET cSql = '';
-- LET cSql = "scp " || trim(cNombreArchivo1) || " sysbancartera@10.36.192.252:/resp_riesgos";
-- SYSTEM cSql;


   RETURN cCodRet;
END;
END PROCEDURE;