CREATE PROCEDURE "informix".renivelaplanpagos()
   RETURNING CHAR(5);

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';

   DEFINE CuotaFija              MONEY(14,2);
   DEFINE TasaInteres            DECIMAL(9,6);
   DEFINE vPlazo                 SMALLINT;
   DEFINE Factor                 DECIMAL(9,6);

   DEFINE Interes                MONEY(14,2);
   DEFINE Capital                MONEY(14,2);
   DEFINE SdoCapital             MONEY(14,2);

   DEFINE vFecha                 DATE;
   DEFINE vSdoCap                MONEY(14,2);
   DEFINE vCapit                 MONEY(14,2);
   DEFINE vInter                 MONEY(14,2);
   DEFINE SdoInteres             MONEY(14,2);

   DEFINE MontoRealPag           MONEY(14,2);
   DEFINE StatusCuota            CHAR(1);
   DEFINE wfecha                 DATE;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "RenivelaPLanPagos.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = '000';

   CREATE  TEMP TABLE
      RenivPagos
         (fecha   DATE,
          sdocap  MONEY(14,2),
          capit   MONEY(14,2),
          inter   MONEY(14,2));

   INSERT INTO RenivPagos SELECT
                             fecha_cuota,
                             0,
                             0,
                             0
                          FROM
                             sd_pagocapit
                          WHERE
                             empresa  = g_Empresa
                          AND
                             num_credito = g_NumCredito
                          AND
                             status_cuota = '1';

   SELECT
      tasa_interes,
      (SELECT a.monto_cuota + b.monto_cuota
         FROM sd_pagocapit a, sd_paginter b
        WHERE b.num_credito = a.num_credito
          AND b.fecha_cuota = a.fecha_cuota
          AND a.num_credito = g_NumCredito
          AND a.fecha_cuota = (SELECT MIN(fecha_cuota) FROM sd_pagocapit d
                                WHERE d.num_credito = g_NumCredito)),
 
      plazo,
      sdo_capital
   INTO
      TasaInteres,
      CuotaFija,
      vPlazo,
      SdoCapital
   FROM
      sd_maecred a,
      sd_maesdos b
   WHERE
      a.empresa = g_Empresa
   AND
     a.num_credito = g_NumCredito
   AND
      b.empresa = a.empresa
   AND
      b.num_credito = a.num_credito;

   SELECT
      SUM(saldo_cuota - monto_real_pag)
   INTO
      SdoCapital
   FROM
      sd_pagocapit
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito
   AND
     status_cuota = '1';


   LET Factor = ROUND((((TasaInteres/ 100) / 12) + 1) , 6);

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      LET vInter = ROUND((SdoCapital * (Factor - 1)), 2);
      LET vCapit = CuotaFija - vInter;
      IF (vCapit > SdoCapital) THEN
         LET vCapit = SdoCapital;
      END IF;
      LET vSdoCap = SdoCapital;
      LET SdoCapital = SdoCapital - vCapit;
      UPDATE
         RenivPagos
      SET
         SdoCap = vSdoCap,
         Capit  = vCapit,
         Inter  = vInter
      WHERE
         fecha = vFecha;

   END FOREACH;

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      UPDATE
         sd_pagocapit
      SET
         monto_cuota = vCapit,
         saldo_cuota = vCapit,
         monto_real_pag = 0
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

      UPDATE
         sd_paginter
      SET
         monto_cuota = vInter
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

   END FOREACH;

   SELECT
      SUM(monto_cuota - monto_real_pag)
   INTO
     SdoInteres
   FROM
      sd_paginter
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;

   UPDATE
      sd_maesdos
   SET
      sdo_no_exig = SdoInteres
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;


   DROP TABLE RenivPagos;

   RETURN CodRet;

END PROCEDURE

DOCUMENT
'Programa de Renivelacion de Pagos despues de un Pago Anticipado ',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Diciembre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".carga_movhis_edocta_movadic()
RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;
--
DEFINE p_empresa     	CHAR(3);
DEFINE p_secuencia   	integer;
DEFINE p_fecha_mov   	DATE ;
DEFINE p_hora_mov    	DATETIME HOUR to FRACTION(3);
DEFINE p_sucursal    	CHAR(4);
DEFINE p_num_credito 	CHAR(20);
DEFINE p_plaza       	CHAR(3);
DEFINE p_transacc_suc	CHAR(4);
DEFINE p_usuario     	CHAR(8);
DEFINE p_monto       	DECIMAL(18,2);
DEFINE p_codigo_fun  	CHAR(3);
DEFINE p_codigo_ref  	INTEGER;
DEFINE p_divisa      	CHAR(2);
DEFINE p_reversado   	CHAR(1);
DEFINE p_folio_suc   	CHAR(16);
DEFINE p_num_producto	CHAR(4);
DEFINE p_nro_tarjeta 	VARCHAR(20,1);
DEFINE p_referencia  	VARCHAR(80,1);
DEFINE p_tipo_cambio 	DECIMAL(14,6);
DEFINE p_monto_dls   	DECIMAL(14,2);
DEFINE p_suc_origen  	VARCHAR(4,1);
DEFINE p_rfc_comer   	VARCHAR(20,1);
DEFINE p_referencia23	VARCHAR(23,1);

--
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "000";
LET vsqlerr = 0;
LET numcredito="";
LET icontador=1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "limpia_amortizacredito.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

--  update statistics medium for table bdicred:sd_movhisedocta;

  FOREACH WITH HOLD 
		SELECT a.empresa,			a.secuencia,			   a.fecha_mov,			
			   a.hora_mov,			a.sucursal,                a.num_credito,
			   a.plaza,				a.transacc_suc,			   a.usuario,
			   a.monto,             a.codigo_fun,			   a.codigo_ref,
			   a.divisa,			a.reversado,			   a.folio_suc,
			   a.num_producto,      a.nro_tarjeta,			   a.referencia,
			   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
		       a.rfc_comer,			a.referencia23		
          into
               p_empresa,           p_secuencia,               p_fecha_mov, 
               p_hora_mov,          p_sucursal,                p_num_credito, 
               p_plaza,             p_transacc_suc,            p_usuario, 
               p_monto,             p_codigo_fun,              p_codigo_ref, 
               p_divisa,            p_reversado,               p_folio_suc, 
               p_num_producto,      p_nro_tarjeta,             p_referencia, 
               p_tipo_cambio,       p_monto_dls,               p_suc_origen, 
               p_rfc_comer,         p_referencia23
        FROM sd_movhis a
        where empresa = '001' 
        and fecha_mov >= mdy('12','21','2008') 
        and fecha_mov <= mdy('01','20','2009') 
        and reversado = 'N' and
 (( codigo_fun = '033' and codigo_ref = 6616)
 or ( codigo_fun = '033' and codigo_ref = 6617)
 or ( codigo_fun = '039' and codigo_ref = 6709)
 or ( codigo_fun = '335' and codigo_ref = 6616)
 or ( codigo_fun = '334' and codigo_ref = 6616)
 or ( codigo_fun = '335' and codigo_ref = 6617)
 or ( codigo_fun = '334' and codigo_ref = 6617)
 or ( codigo_fun = '336' and codigo_ref = 6616)
 or ( codigo_fun = '336' and codigo_ref = 6617)
 or ( codigo_fun = '337' and codigo_ref = 11)
 or ( codigo_fun = '337' and codigo_ref = 12)
 or ( codigo_fun = '033' and codigo_ref = 5)
 or ( codigo_fun = '039' and codigo_ref = 6704)
 or ( codigo_fun = '335' and codigo_ref = 5)
 or ( codigo_fun = '334' and codigo_ref = 5)
 or ( codigo_fun = '336' and codigo_ref = 5)
 or ( codigo_fun = '337' and codigo_ref = 5)
 or ( codigo_fun = '033' and codigo_ref = 6640)
 or ( codigo_fun = '038' and codigo_ref = 1)
 or ( codigo_fun = '039' and codigo_ref = 6707)
 or ( codigo_fun = '033' and codigo_ref = 6641)
 or ( codigo_fun = '039' and codigo_ref = 6708)
 or ( codigo_fun = '335' and codigo_ref = 6640)
 or ( codigo_fun = '334' and codigo_ref = 6640)
 or ( codigo_fun = '335' and codigo_ref = 6641)
 or ( codigo_fun = '334' and codigo_ref = 6641)
 or ( codigo_fun = '336' and codigo_ref = 6640)
 or ( codigo_fun = '336' and codigo_ref = 6641)
 or ( codigo_fun = '337' and codigo_ref = 6640)
 or ( codigo_fun = '337' and codigo_ref = 6641))

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        insert into sd_movhisedocta 
             values (p_empresa, p_secuencia, p_fecha_mov, p_hora_mov, p_sucursal, p_num_credito, p_plaza, p_transacc_suc, p_usuario, p_monto, p_codigo_fun, p_codigo_ref, p_divisa, p_reversado, p_folio_suc, p_num_producto, p_nro_tarjeta, p_referencia, p_tipo_cambio, p_monto_dls, p_suc_origen, p_rfc_comer, p_referencia23);
    
    IF icontador>=45000 then
        COMMIT WORK; 
--        update statistics medium for table bdicred:sd_movhisedocta;
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  update statistics medium for table bdicred:sd_movhisedocta;


  RETURN scod_ret;
END
END PROCEDURE;