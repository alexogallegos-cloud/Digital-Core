CREATE PROCEDURE "informix".sp_rep_ctes_pagvencidos(pEmpresa CHAR(03))

RETURNING CHAR(6),CHAR(80);

DEFINE cCodret         CHAR(6);
DEFINE iIsamErr        SMALLINT;
DEFINE cMensajeRet     CHAR(80);
DEFINE sql_err         INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE v_fch_ini       DATE;
DEFINE v_fch_fin       DATE;
DEFINE cNombre_Archivo CHAR(100);
DEFINE cSql            CHAR(2024);
DEFINE var_rga         CHAR(05);
DEFINE cNom_mes        CHAR(10);
DEFINE pFecha          DATE;
DEFINE iNum_dia        INTEGER;
DEFINE iNum_mes        INTEGER;
DEFINE iNum_anio       INTEGER;
DEFINE iQuery          SMALLINT;
DEFINE cruta				CHAR(100);

DEFINE cNum_credito             CHAR(20);
DEFINE cSucursal				CHAR(04);
DEFINE dFecha_apertura			DATE;
DEFINE sNum_periodos			SMALLINT;
DEFINE dMonto_otorgado			DECIMAL(18,02);
DEFINE dSdo_cap_insoluto		DECIMAL(18,02);
DEFINE dSdo_capital				DECIMAL(18,02);
DEFINE dTransitorio				DECIMAL(18,02);
DEFINE dVencido_exigible		DECIMAL(18,02);
DEFINE dVencido_no_exigible		DECIMAL(18,02);
DEFINE dInteres_vencido			DECIMAL(18,02);


LET cCodret         = '000000';
LET iIsamErr        = 0;
LET v_fch_ini       = '';
LET v_fch_fin       = '';
LET sql_err         = 0;
LET cErrorInfo      = '';
LET cNombre_Archivo = '';
LET cSql            = '';
LET iNum_dia        = 0;
LET iNum_anio       = 0;
LET iNum_mes        = 0;
LET cNom_mes        = '';
LET iQuery          = 0;
LET cMensajeRet     = 'El proceso de PAGOS VENCIDOS se ejecutó correctamente';
--Variables que se usan para el insert y creación del archivo de salida
LET cNum_credito            = '';
LET cSucursal				= '';
LET dFecha_apertura			= date(0);
LET sNum_periodos			= 0;
LET dMonto_otorgado			= 0.00;
LET dSdo_cap_insoluto		= 0.00;
LET dSdo_capital			= 0.00;
LET dTransitorio			= 0.00;
LET dVencido_exigible		= 0.00;
LET dVencido_no_exigible	= 0.00;
LET dInteres_vencido		= 0.00;
LET cruta					= "";

BEGIN

 ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
             LET cCodret = sql_err;
             LET cMensajeRet= cErrorInfo;
             RETURN cCodret,cMensajeRet;
  END EXCEPTION;

--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_rep_ctes_pagvencidos.out";
--TRACE ON;
--Ruta
SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND num_parametro = 2;

LET pFecha    = TODAY;
LET iNum_dia  = day(pFecha);
LET iNum_mes  = month(pFecha);
LET iNum_anio = year(pFecha);

IF iNum_dia >= 1 AND iNum_dia <= 5 THEN
--Query de consulta al fin de mes
    LET iQuery = 1;
    LET iNum_dia = day(mdy(month(pFecha),1,year(pFecha))-1);
    IF iNum_mes > 1  THEN LET iNum_mes = iNum_mes - 1; ELSE LET iNum_mes = 12; END IF;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';         END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';       END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';         END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';         END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';          END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';         END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';         END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';        END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';    END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';       END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';     END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre'; LET iNum_anio = year(pFecha)-1; END IF;
ELIF iNum_dia >= 21 AND iNum_dia <= 25 THEN
--Query de consulta al corte
    LET iQuery = 2;
    LET iNum_dia = 20;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';       END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';     END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';       END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';       END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';        END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';       END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';       END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';      END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';  END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';     END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';   END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre';   END IF;
ELSE
    LET cCodret     = '999999';
    LET cMensajeRet = 'Hoy no es un día válido para ejecutar el proceso de PAGOS VENCIDOS';
    RETURN cCodret,cMensajeRet;
END IF;

LET  cNombre_Archivo= 'Rep_Ctes_PagosVencidos_' || iNum_dia || TRIM(cNom_mes) || iNum_anio || '.txt';

IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_ctes_pagosvencidos' ) THEN
   DROP TABLE temp_ctes_pagosvencidos;
END IF;

   CREATE TABLE  temp_ctes_pagosvencidos
    ( num_credito        CHAR(20),  
      sucursal           CHAR(04),
      fecha_apertura     DATE,
      num_periodos       SMALLINT,
      monto_otorgado     DECIMAL(18,02),
      sdo_cap_insoluto   DECIMAL(18,02),
      sdo_capital        DECIMAL(18,02),
      monto_vencido      DECIMAL(18,02),
      mto_venc_trasp     DECIMAL(18,02),
      cap_tras_no_venci  DECIMAL(18,02),
      interes_vencido    DECIMAL(18,02)
    );

CREATE INDEX idx_temp_ctes
    ON informix.temp_ctes_pagosvencidos(num_credito, sucursal);

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;

IF iQuery = 1 THEN
  INSERT INTO  temp_ctes_pagosvencidos
    select a.num_credito, a.sucursal, fecha_apertura, num_periodos, monto_otorgado, sdo_cap_insoluto,  
    sdo_capital vigente, monto_vencido transitorio, mto_venc_trasp vencido_exigible, cap_tras_no_venci vencido_no_exigible, 
    case when mto_venc_trasp > 0 then int_tra_no_exig - nvl((select sdo_int_anticip from bdicred:sd_maesdoshist where empresa = pEmpresa 
    and a.num_credito = num_credito and fecha = mdy(month(a.fecha),'20',year(a.fecha))),0) else 0 end interes_vencido 
    from bdicred:sd_maecredcont a,
    bdicred:sd_maesdoscont c,
    bdicred:sd_histvalcon b
    where a.empresa = pEmpresa
      and a.empresa = b.empresa and a.empresa = c.empresa
      and a.num_credito = b.num_credito and a.num_credito = c.num_credito
      and a.fecha = mdy(iNum_mes,iNum_dia,iNum_anio) and a.fecha = c.fecha
      and fecha_alta = a.fecha and num_periodos in (1,2,3);
ELSE
    FOREACH
        select b.num_credito, 
        (select count(*) from bdicred:sd_maesdoshist d where empresa = pEmpresa and b.num_credito = d.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0) and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)), 
        monto_otorgado, sdo_cap_insoluto, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, 
        case when mto_venc_trasp > 0  then int_tra_no_exig - sdo_int_anticip else 0 end
          into cNum_credito, 
        sNum_periodos, dMonto_otorgado, dSdo_cap_insoluto, dSdo_capital, dTransitorio, dVencido_exigible, dVencido_no_exigible, 
        dInteres_vencido 
        from bdicred:sd_maesdoshist b
        where b.empresa = pEmpresa
          and b.num_credito = b.num_credito
        and b.fecha = mdy(iNum_mes,iNum_dia,iNum_anio)
                and b.num_credito = (select num_credito from bdicred:sd_maecred where empresa=pEmpresa and num_credito=b.num_credito)
          and (monto_vencido > 0 or mto_venc_trasp > 0)
          and (select count(*) from bdicred:sd_maesdoshist c where empresa = pEmpresa and b.num_credito = c.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0)
        and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)) in (1,2,3)

        select a.sucursal, fecha_apertura 
          into cSucursal, dFecha_apertura
        from bdicred:sd_maecred a
        where a.empresa = '001' 
          and a.num_credito = cNum_credito;

      INSERT INTO temp_ctes_pagosvencidos VALUES (
         cNum_credito,cSucursal,dFecha_apertura,sNum_periodos,dMonto_otorgado,dSdo_cap_insoluto,
         dSdo_capital,dTransitorio,dVencido_exigible,dVencido_no_exigible,dInteres_vencido);

--Se inicializan las variables que se usan para el insert y creación del archivo de salida
        LET cNum_credito            = '';
        LET cSucursal				= '';
        LET dFecha_apertura			= date(0);
        LET sNum_periodos			= 0;
        LET dMonto_otorgado			= 0.00;
        LET dSdo_cap_insoluto		= 0.00;
        LET dSdo_capital			= 0.00;
        LET dTransitorio			= 0.00;
        LET dVencido_exigible		= 0.00;
        LET dVencido_no_exigible	= 0.00;
        LET dInteres_vencido		= 0.00;

    END FOREACH

END IF;

  --Se genera archivo con la informacion del reporte
LET cSql = '';
LET cSql = 'echo "UNLOAD TO ' ||  trim(cRuta) || 'ReporteCtes_PagosVencidos.unl' || ' DELIMITER ' || '''|'''|| 
           ' select * from bdicred:temp_ctes_pagosvencidos;'|| 
           ' " >'||TRIM(cruta)||'ReporteCtes_PagosVencidos.sql';

SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = "sed 's/|$//g' " || trim(cruta) || "ReporteCtes_PagosVencidos.unl > " || trim(cruta) || cNombre_Archivo;
SYSTEM cSql;
     
LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.unl';
SYSTEM cSql;

DROP TABLE  temp_ctes_pagosvencidos;  
       
RETURN cCodret,cMensajeRet;

END
END PROCEDURE;