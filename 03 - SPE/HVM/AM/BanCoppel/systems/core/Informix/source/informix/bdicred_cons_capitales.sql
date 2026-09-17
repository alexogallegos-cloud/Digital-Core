CREATE PROCEDURE "informix".cons_capitales(p_empresa CHAR(3),
                                           pnum_credito CHAR(20))
RETURNING CHAR(6),
          CHAR(80),
          CHAR(20),
          CHAR(60),
          CHAR(45),
          CHAR(30),
          CHAR(40),
          CHAR(20),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2);

   --####################################################################
   --#####                    variables                      #####
   --####################################################################

   DEFINE i                  INTEGER;
   DEFINE text               VARCHAR(100);
   DEFINE v_apell_paterno    VARCHAR(15);
   DEFINE v_apell_materno    VARCHAR(15);
   DEFINE v_nombre1          VARCHAR(15);
   DEFINE v_nombre2          VARCHAR(15);
   DEFINE v_razon_social     VARCHAR(40);
   DEFINE v_num_prod         VARCHAR(04);
   DEFINE v_monto_ven_tras   LIKE SD_MAESDOS.MTO_VENC_TRASP;
   DEFINE p_cod_ret          VARCHAR(8);
   DEFINE p_mensaje          VARCHAR(80);
   DEFINE v_numcte	     VARCHAR(20);
   DEFINE v_cliente	     VARCHAR(60);
   DEFINE v_ejecut	     VARCHAR(45);
   DEFINE v_divnom	     VARCHAR(30);
   DEFINE v_prodnom	     VARCHAR(40);
   DEFINE v_num_credito      VARCHAR(20);
   DEFINE v_sdo_capital      DECIMAL(18,2);
   DEFINE v_mto_ministra     DECIMAL(18,2);
   DEFINE v_monto_otorgado   DECIMAL(18,2);
   DEFINE v_sdo_cap_insoluto DECIMAL(18,2);
   DEFINE v_monto_vencido    DECIMAL(18,2);

BEGIN


   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET p_cod_ret          = '00000';
   LET p_mensaje          = ' ';
   LET v_apell_paterno    = ' ';
   LET v_apell_materno    = ' ';
   LET v_nombre1          = ' ';
   LET v_nombre2          = ' ';
   LET v_cliente          = ' ';
   LET v_divnom           = ' ';
   LET v_prodnom          = ' ';
   LET v_razon_social     = ' ';
   LET v_numcte           = ' ';
   LET v_num_credito      = ' ';
   LET v_sdo_capital      = 0;
   LET v_mto_ministra     = 0;
   LET v_monto_otorgado   = 0;
   LET v_sdo_cap_insoluto = 0;
   LET v_monto_vencido    = 0;
   LET v_monto_ven_tras	  = 0;
--   v_monto_financiado := 0;
--   v_sdo_acum_vencido := 0;
--   v_monto_recuperado  := 0;
   LET v_ejecut           = ' ';
   LET v_num_prod         = ' ';

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = ' ' THEN
      LET p_cod_ret = '223'; -- NUMERO DE CREDITO NULO O BLANCO
--      GOTO FIN;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;
END;

BEGIN
   SELECT num_credito,sdo_capital,mto_ministra_cap,monto_otorgado,
--          sdo_cap_insoluto,monto_vencido,monto_financiado,
            sdo_cap_insoluto,monto_vencido, mto_venc_trasp
--          sdo_acum_vencido
   INTO v_num_credito,v_sdo_capital,v_mto_ministra,v_monto_otorgado,
--        v_sdo_cap_insoluto,v_monto_vencido,v_monto_financiado,
        v_sdo_cap_insoluto,v_monto_vencido, v_monto_ven_tras
--        v_sdo_acum_vencido
   FROM sd_maesdos
   WHERE empresa = p_empresa
   AND   num_credito = v_num_credito;

--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_num_credito IS NULL OR v_num_credito = ' ' THEN
      LET p_cod_ret = '224'; -- NO EXISTE EL CREDITO
--      GOTO FIN;
   END IF;

BEGIN
      SELECT si_cliente.numcte,apell_paterno,apell_materno,nombre1,
             nombre2,razon_social
      INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
      FROM sd_maecred, bdinteg:si_cliente si_cliente
      WHERE sd_maecred.empresa     = p_empresa
      AND   sd_maecred.num_credito = v_num_credito
      AND   sd_maecred.empresa     = si_cliente.empresa
      AND   sd_maecred.numcte      = si_cliente.numcte;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;
      IF v_razon_social IS NULL OR v_razon_social = ' ' THEN
         LET v_cliente = TRIM (v_nombre1) || ' ' || TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || ' ' ||
                         TRIM (v_apell_paterno) || ' ' ||
                         TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
--BEGIN
--   SELECT SUM(monto_real_pag) INTO v_monto_recuperado
--  FROM sd_pagocapit
--   WHERE empresa = p_empresa
--   AND   num_credito = v_num_credito
--   AND   status_cuota IN ('3','5','9');
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
--END;
--   IF v_monto_recuperado IS NULL THEN
--     v_monto_recuperado := 0;
--   END IF;
BEGIN
   SELECT nombre INTO v_ejecut
   FROM sd_maecred, bdinteg:si_ejecut si_ejecut
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND  sd_maecred.empresa      = si_ejecut.empresa
   AND  sd_maecred.ejecutivo    = si_ejecut.ejecutivo;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

    IF v_ejecut IS NULL OR v_ejecut = ' ' THEN
      LET v_ejecut    = ' ';
   END IF;

BEGIN
   SELECT num_producto INTO v_num_prod
   FROM sd_maecred
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

BEGIN
   SELECT nombre_prod INTO v_prodnom
   FROM sd_definicion
   WHERE empresa = p_empresa
   AND   num_producto = v_num_prod;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   LET v_prodnom = SUBSTR(TRIM (v_num_prod) || ' ' || TRIM (v_prodnom),1,40);

   IF v_prodnom IS NULL THEN
      LET v_prodnom = ' ';
   END IF;

BEGIN
   SELECT descripcion INTO v_divnom
   FROM sd_maecred, bdinteg:si_divisas si_divisas
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND   sd_maecred.empresa     = si_divisas.empresa
   AND   sd_maecred.divisa      = si_divisas.divisa;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_sdo_capital IS NULL THEN
      LET v_sdo_capital = 0;
   END IF;
   IF v_mto_ministra IS NULL THEN
      LET v_mto_ministra = 0;
   END IF;
   IF v_monto_otorgado IS NULL THEN
      LET v_monto_otorgado = 0;
   END IF;
   IF v_sdo_cap_insoluto IS NULL THEN
      LET v_sdo_cap_insoluto = 0;
   END IF;
   IF v_monto_vencido IS NULL THEN
      LET v_monto_vencido = 0;
   END IF;
   if v_monto_ven_tras is null then
      LET v_monto_ven_tras = 0;
   end if;

   LET v_monto_vencido = v_monto_vencido + v_monto_ven_tras;

--   IF v_monto_financiado IS NULL THEN
--      v_monto_financiado := 0;
--   END IF;
--   IF v_sdo_acum_vencido IS NULL THEN
--      v_sdo_acum_vencido := 0;
--   END IF;
--   IF v_monto_recuperado IS NULL THEN
--      v_monto_recuperado := 0;
--   END IF;
--   <<FIN>>
--     NULL;
--   EXCEPTION
--      WHEN OTHERS THEN
--       SIPK_MENSAJES.SP_TRAE_MENSAJE (SQLCODE, SQLERRM, P_COD_RET, P_MENSAJE);
RETURN    p_cod_ret,p_mensaje,
          v_numcte,v_cliente,v_ejecut,v_divnom,v_prodnom,v_num_credito,
          v_sdo_capital,v_mto_ministra,v_monto_otorgado,v_sdo_cap_insoluto,
          v_monto_vencido;  --p_cod_ret,p_mensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Herndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".log_cierre(vEmpresa CHAR(3),
			    vNumCred CHAR(20),
			    vCodRet  CHAR(5),
			    vFecha   DATE,
			    vDesc    VARCHAR(200,1))
RETURNING SMALLINT;


DEFINE vContador SMALLINT;
DEFINE vParamPara SMALLINT;

	SELECT valor INTO vParamPara
	  FROM sd_param
	 WHERE empresa = vEmpresa
	   AND cod_param ="79";

	INSERT INTO sd_valcierre
	 (empresa, cod_ret, num_credito, secuencia, fecha_proc,
	  desc_err)
	VALUES
	 (vEmpresa, vCodRet, vNumCred, 0, vFecha, vDesc);


	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*) INTO vContador
	  FROM sd_valcierre
	 WHERE empresa = vEmpresa
	   AND fecha_proc = vFecha;

	IF vContador >= vParamPara THEN
		RETURN vContador;
	ELSE
		LET vContador = 0;
	END IF

	RETURN vContador;

END PROCEDURE
			    
;