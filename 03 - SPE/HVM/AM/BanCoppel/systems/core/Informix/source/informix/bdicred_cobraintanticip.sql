CREATE PROCEDURE "informix".cobraintanticip()
   RETURNING CHAR(5), MONEY(14,2), MONEY(14,2);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoIntAnticip MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumInt    MONEY(14,2) DEFAULT 0;

   
   DEFINE GLOBAL g_IntVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_PagoAdic      CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL gStatusCap      CHAR(1)     DEFAULT " ";

   DEFINE vInteresAnticip        MONEY(14,2);


   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVig                LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanciado       LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vCodigoFun             CHAR(3);
   DEFINE vSdoACumMesInt         MONEY(14,2);
   DEFINE vProvisionNorm         MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
 

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET vIntVig = 0;
      RETURN CodRet, vIntVig, vProvision;
   END EXCEPTION;

   LET CodRet = "000";
   LET vCodigoFun = "034";   --Utilizada para realizar la provision
   LET vSdoAcumMesInt = 0;
   LET vProvisionNorm = 0;
   LET vInteresAnticip = 0;
   LET vProvision = 0;
   LET vIntVig = 0;

   IF (g_ManejaLinea <> 'S') THEN

      IF (g_PagoAdic = '1') THEN   -- Siguientes Cuotas
         SELECT 
            fecha_cuota,
            cuota_rec,
            monto_cuota,
            monto_real_pag,
            (monto_cuota - monto_real_pag),
            NVL(monto_financiado,0),
            status_cuota 
         INTO
            vFechaCuota,
            vCuotaRec,
            vMontoCuota,
            vMontorealPag,
            vIntVig,
            vMontoFinanciado,
            vStatusCuota 
         FROM
            sd_paginter
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = (SELECT
                              MIN(fecha_cuota)
                           FROM
                              sd_paginter
                           WHERE
                              empresa = g_Empresa
                           AND
                              num_credito = g_NumCredito
                           AND
                              fecha_cuota >= g_Fecha
                           AND
                              status_cuota = '1')
         AND
         status_cuota = '1';
      ELSE
         SELECT 
            fecha_cuota,
            cuota_rec,
            monto_cuota,
            monto_real_pag,
            (monto_cuota - monto_real_pag),
            NVL(monto_financiado,0),
            status_cuota 
         INTO
            vFechaCuota,
            vCuotaRec,
            vMontoCuota,
            vMontorealPag,
            vIntVig,
            vMontoFinanciado,
            vStatusCuota 
         FROM
            sd_paginter
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = (SELECT
                              MAX(fecha_cuota)
                           FROM
                              sd_paginter
                           WHERE
                              empresa = g_Empresa
                           AND
                              num_credito = g_NumCredito
                           AND
                              fecha_cuota >= g_Fecha
                           AND
                              status_cuota = '1')
         AND
         status_cuota = '1';

      END IF;
      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF (nRows = 0) THEN
         RETURN CodRet, 0, 0;
      END IF;

      IF (gStatusCap != "5") THEN
         IF (g_Remanente >= vIntVig) THEN
            LET g_Remanente = g_Remanente - vIntVig;
            LET vCuotaRec = vStatusCuota;
            LET vStatusCuota = '5';
         ELSE
            LET vIntVig = g_Remanente;
            LET g_Remanente = 0;
         END IF;

          -- Valida Provision Pendiente
         IF (vMontoFinanciado <= (vMontoRealPag + vIntVig)) THEN
            LET vProvision = vIntVig - vMontoFinanciado;
         ELSE
            LET vProvision = 0;
         END IF;

         UPDATE    
            sd_paginter
         SET
            monto_real_pag = monto_real_pag + vIntVig,
            fecha_pag     = g_fecha,
            monto_financiado = vMontoFinanciado + vProvision,
            cuota_rec      = vCuotaRec,
            status_cuota   = vStatusCuota
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = vFechaCuota;    

   ELSE
      UPDATE 
         sd_paginter
      SET
         status_cuota = "5",
         monto_cuota  = 0,
         cuota_rec = vCuotaRec      
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;    
  
      LET gStatusCap = " ";
      LET vIntVig = 0;
      LET vProvision = 0;
   END IF;
 
      ---------------------------------------
      --   PAGO ANTICIPADO INSTACASH       --
      ---------------------------------------

   ELSE
      IF (g_Remanente > 0 AND g_SdoIntereses > 0) THEN
         LET vIntVig = g_SdoIntereses;
         IF (g_Remanente >= g_SdoIntereses) THEN
            LET g_Remanente = g_Remanente - g_SdoIntereses;
            LET vInteresAnticip = g_SdoIntereses;
            LET g_SdoIntereses = 0;
         ELSE
            LET g_SdoIntereses = g_SdoIntereses - g_Remanente;
            LET vInteresAnticip = g_Remanente;
            LET g_Remanente = 0;
         END IF;
         
         IF(vInteresAnticip >= g_SdoIntAnticip) THEN
            LET vInteresAnticip = vInteresAnticip - g_SdoIntAnticip;
            LET vProvision = vProvision + g_SdoIntAnticip;
            LET g_SdoIntAnticip  = 0;
         ELSE
            LET g_SdoIntAnticip = g_SdoIntAnticip - vInteresAnticip;
            LET vProvision = vProvision + vInteresAnticip;
            LET vInteresAnticip   = 0;
         END IF;


         IF(vInteresAnticip >= g_SdoIntAntDev) THEN
            LET vInteresAnticip = vInteresAnticip - g_SdoIntAntDev;
            LET vProvision      = vProvision + g_SdoIntAntDev;
            LET g_SdoIntAntDev  = 0;
         ELSE
            LET g_SdoIntAntDev = g_SdoIntAntDev - vInteresAnticip;
            LET vProvision     = vProvision + vInteresAnticip;
            LET vInteresAnticip = 0;
         END IF;  
         LET vIntVig = vProvision;
      END IF;
      
 
   END IF;


   RETURN CodRet, vIntVig, vProvision; 
   
END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Interes Anticipado',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobracapanticip()
   RETURNING CHAR(5), MONEY(14,2);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_PagoAdic      CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoCapInsoluto  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoCapitalizado MONEY(14,2) DEFAULT 0;
 
   DEFINE GLOBAL g_CapVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro1                LIKE sd_pagocapit.monto_cuota;
   DEFINE CapCobrado             LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;

   DEFINE GLOBAL gStatusCap      CHAR(1)   DEFAULT " ";

   DEFINE vCapVig                MONEY(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapAnticip.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET vCobro1 = 0;
      RETURN CodRet, vCobro1;
   END EXCEPTION;

   LET CodRet = '000';
   LET vCObro1 = 0;
   LET vCapVig = 0;
   LET gStatusCap = " ";
   
   IF (g_ManejaLinea <> 'S') THEN
      IF (g_PagoAdic = '1') THEN
         SELECT
            fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
            (saldo_cuota - monto_real_pag), status_cuota
         INTO
            vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag, 
            vAdeudoCuota, vStatusCuota 
	 FROM sd_pagocapit 
	WHERE empresa = g_Empresa 
         AND num_credito = g_NumCredito
         AND fecha_cuota = (SELECT MIN(fecha_cuota)
                              FROM sd_pagocapit
                             WHERE empresa = g_Empresa
                               AND num_credito = g_NumCredito
                               AND fecha_cuota >= g_Fecha
                               AND status_cuota = '1'
	 		       AND saldo_cuota - monto_real_pag > 0)
         AND status_cuota = '1';
            
      ELSE
         SELECT fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
            (saldo_cuota - monto_real_pag), status_cuota
	 INTO vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag, 
            vAdeudoCuota, vStatusCuota
         FROM sd_pagocapit
         WHERE empresa = g_Empresa 
         AND num_credito = g_NumCredito
         AND fecha_cuota = (SELECT MAX(fecha_cuota)
                              FROM sd_pagocapit
                             WHERE empresa = g_Empresa
                               AND num_credito = g_NumCredito
                               AND fecha_cuota >= g_Fecha
                               AND status_cuota = '1'
	 		       AND saldo_cuota - monto_real_pag > 0)
         AND status_cuota = '1';
      END IF;
      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF (nRows = 0) THEN
            RETURN CodRet, 0;
      END IF;
      IF (g_Remanente >= vAdeudoCuota) THEN
         LET g_Remanente = g_Remanente - vAdeudoCuota;
         LET vCuotaRec = vStatusCuota;
         LET vStatusCuota = '1';
      ELSE
         LET vAdeudoCuota = g_Remanente;
         LET g_Remanente = 0;
      END IF;
      LET vCobro1 = vCobro1 + vAdeudoCuota;
      UPDATE
         sd_pagocapit
      SET
         monto_real_pag = monto_real_pag + vAdeudoCuota,
         fecha_pago     = g_fecha,
         status_cuota   = vStatusCuota
      WHERE
         empresa     = g_empresa
      AND
         num_credito = g_NumCredito 
      AND
         fecha_cuota = vFechaCuota;
      
      LET gStatusCap = vStatusCuota;

    ---------------------------------------------
    --   COBRO ANTICIPADO INSTACASH            --
    ---------------------------------------------

   ELSE
     IF(g_Remanente > 0 AND g_SdoCapInsoluto > 0) THEN
        LET vCapVig = g_SdoCapInsoluto;
        IF (g_Remanente >= g_SdoCapInsoluto) THEN
           LET g_Remanente      = g_Remanente - g_SdoCapInsoluto;
           LET CapCobrado       = g_SdoCapInsoluto;
           LET g_SdoCapInsoluto = 0; 
        ELSE
           LET g_SdoCapInsoluto = g_SdoCapInsoluto - g_Remanente;
           LET CapCobrado       = g_Remanente;
           LET g_Remanente      = 0;
        END IF;       
   
        LET vCobro1 = CapCobrado;
 
        IF (CapCobrado >= g_SdoCapInsoluto) THEN 
           LET CapCobrado       = CapCobrado - g_SdoCapInsoluto;
           LET g_SdoCapInsoluto = 0; 
        ELSE
           LET g_SdoCapInsoluto = g_SdoCapInsoluto - CapCobrado;
           LET CapCobrado       = 0;
        END IF;

        IF (CapCobrado >= g_MtoCapitalizado) THEN
           LET CapCobrado = CapCobrado - g_MtoCapitalizado;
           LET g_MtoCapitalizado = 0;
        ELSE
           LET g_MtoCapitalizado = g_MtoCapitalizado - CapCobrado;
           LET CapCobrado = 0;
        END IF;
     END IF;

   END IF;

   RETURN CodRet, vCobro1;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital Anticipado, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".clasifica_cartvend(eempresa      CHAR(3),
				  enum_credito  CHAR(20),
			 	  etp_venta     CHAR(1),
				  enum_producto CHAR(4),
				  eusuario      CHAR(8))
RETURNING CHAR(5), CHAR(80);

-- ****************************************************************************
-- *                         DEFINICION DE VARIABLES                          *
-- ****************************************************************************
DEFINE vcod_ret       CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE vmensaje       CHAR(80);
DEFINE vfuncion       CHAR(3);
DEFINE v_vigente      MONEY(14,2);
DEFINE v_vencido      MONEY(14,2);
DEFINE v_venctrasp    MONEY(14,2);
DEFINE v_intnoexig    MONEY(14,2);
DEFINE v_int_venc     MONEY(14,2);
DEFINE v_intvenctrasp MONEY(14,2);
DEFINE vnum_producto  CHAR(4);
DEFINE vhoy           DATE;
DEFINE vfolio         CHAR(16);
DEFINE vsucursal      CHAR(4);
DEFINE vdivisa        CHAR(2);
-- ****************************************************************************
-- *                         ASIGNACION DE VARIABLES                          *
-- ****************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;
LET vmensaje = "PROCESO CONCLUIDO EXITOSAMENTE";
SELECT eusuario || SUBSTR(current hour to fraction    ,1,2 ) ||
                   SUBSTR(current hour to fraction    ,4,2 ) ||
                   SUBSTR(current hour to fraction    ,7,2 ) ||
                   SUBSTR(enum_credito,8 ,2),
      fecha_hoy
 INTO vfolio, vhoy
 FROM sd_fechas;
-- ****************************************************************************
-- *                         CONTROL DE ERRORES                               *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      ROLLBACK WORK;
      LET vmensaje = " ";
      RETURN vcod_ret, vmensaje; 
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                         PROGRAMA PRINCIPAL                               *
-- ****************************************************************************
	IF etp_venta = "2" THEN
		IF enum_producto = " " OR enum_producto IS NULL THEN
			LET vcod_ret = "0020";
			LET vmensaje = "Debe Definir un Producto"; 
			RETURN vcod_ret, vmensaje;
		END IF
		LET vfuncion = "021";
	ELIF etp_venta = "1" THEN
		LET vfuncion = "020";
	ELSE 
		LET vfuncion = "036";
	END IF
	BEGIN WORK;

	SELECT sdo_capital, monto_vencido, mto_venc_trasp, sdo_no_exig,
	       mto_venc_int,mto_venc_tra_int, num_producto, sucursal,
	       divisa
	  INTO v_vigente  , v_vencido,     v_venctrasp,    v_intnoexig,
	       v_int_venc,  v_intvenctrasp,vnum_producto,  vsucursal,
	       vdivisa
	  FROM sd_maesdos a, sd_maecred b
	 WHERE b.num_credito = a.num_credito
	   AND b.empresa     = a.empresa
	   AND a.num_credito = enum_credito
	   AND a.empresa     = eempresa; 

	-- Liquida o Traspasa el Capital Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 1, 
				 vfuncion, vhoy, v_vigente, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 2, 
				 vfuncion, vhoy, v_vencido, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 3, 
				 vfuncion, vhoy, v_venctrasp, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 4, 
				 vfuncion, vhoy, v_intnoexig, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 5, 
				 vfuncion, vhoy, v_int_venc, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 6, 
				 vfuncion, vhoy, v_intvenctrasp, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	IF etp_venta = "1" THEN
		-- Liquida o Traspasa el Interes Moratorios 
		EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto,
					 7, vfuncion, vhoy, v_intvenctrasp, 
					 vfolio, vsucursal, vdivisa, "0000")
		   INTO vcod_ret, vmensaje;
		IF vcod_ret <> "00000" THEN
      			ROLLBACK WORK;
			RETURN vcod_ret, vmensaje;
		END IF

		UPDATE sd_pagocapit SET monto_real_pag = saldo_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_paginter SET monto_real_pag = monto_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_detmora SET sdo_mora_ordi = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

		-- Se va a verificar pero de entrada el seguro se cancela

		UPDATE sd_detcomi SET estado_com = "C"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND estado_com = "P";

		UPDATE sd_maesdos SET sdo_no_exig      = 0,
				      sdo_exig_int     = 0,
				      sdo_moratorio    = 0,
				      sdo_capital      = 0,
				      sdo_cap_insoluto = 0,
				      monto_vencido    = 0,
				      mto_venc_trasp   = 0,
				      mto_venc_int     = 0,
				      mto_venc_tra_int = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;


		UPDATE sd_maecred SET status_cred = "FE"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

	ELIF etp_venta = "2" THEN
		UPDATE sd_maecred SET num_producto = enum_producto 
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;
	ELSE
		UPDATE sd_maecred SET status_cred = "CC"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

                UPDATE sd_maesdos SET sdo_no_exig      = 0,
                                      sdo_exig_int     = 0,
                                      sdo_moratorio    = 0,
                                      mto_venc_int     = 0,
                                      mto_venc_tra_int = 0
                 WHERE num_credito = enum_credito
                   AND empresa = eempresa ;

		UPDATE sd_paginter SET monto_cuota = 0, status_cuota ="1"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa
		   AND monto_cuota > 0
		   AND status_cuota <> "5";

	END IF
	

	COMMIT WORK;
END
	RETURN vcod_ret, vmensaje;
END PROCEDURE;