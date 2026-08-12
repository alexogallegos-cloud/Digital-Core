CREATE PROCEDURE "informix".liquida_cred(ax_numcred  CHAR(20),
			                 ax_empresa  CHAR(3), 
					 ax_folio    CHAR(16),
					 ax_usuario  CHAR(8),
					 ax_sucursal CHAR(4)) 
RETURNING CHAR(5);



-- ****************************************************************************
-- *                           DEFINICION DE VARIABLES                        *
-- ****************************************************************************
DEFINE s_codret   CHAR(5);
DEFINE vsqlerr    INTEGER;
DEFINE v_intdia   MONEY(14,2);
DEFINE v_intmes   MONEY(14,2);
DEFINE v_mtocon   MONEY(14,2);
DEFINE v_sdo      MONEY(14,2);
DEFINE v_fechavig DATE;
DEFINE v_hoy      DATE;
DEFINE v_dias     SMALLINT;
DEFINE v_tpcred   CHAR(2);
DEFINE v_tran     CHAR(4);
DEFINE v_codseg   CHAR(4);

-- ****************************************************************************
-- *                      ASIGNACION DE VALORES A VARIABLES                   *
-- ****************************************************************************
LET s_codret     = "000";
LET vsqlerr      = 0;
SELECT fecha_hoy INTO v_hoy FROM sd_fechas;
SELECT TRIM(valor) INTO v_tran 
  FROM sd_param 
 WHERE empresa = ax_empresa 
   AND cod_param = "201";
-- ****************************************************************************
-- *                              CONTROL DE ERRORES                          *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET s_codret=vsqlerr;
      RETURN s_codret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                           PROGRAMA PRINCIPAL                             *
-- ****************************************************************************
		SELECT cod_tipcred INTO v_tpcred
		  FROM sd_maecred a, sd_definicion b
		 WHERE num_credito = ax_numcred
		   AND b.num_producto = a.num_producto
		   AND b.empresa = a.empresa; 

        	IF v_tpcred ="01" OR v_tpcred ="04" THEN
                	SELECT valor INTO v_dias
                	  FROM sd_param
               	         WHERE cod_param ="75";
        	ELSE
                	SELECT valor INTO v_dias
              	          FROM sd_param
              	         WHERE cod_param ="24";
		END IF

		EXECUTE PROCEDURE calc_intdialiq(ax_numcred)
		   INTO  s_codret, v_intdia, v_dias;
		IF s_codret ="00000" THEN
			LET s_codret ="000";
		END IF

                -- Determina Fecha Cuota Vigente
                SELECT NVL(MIN(fecha_cuota),"01/01/1800")
                  INTO v_fechavig
                  FROM sd_paginter, sd_fechas
                 WHERE fecha_cuota >= fecha_hoy
                   AND num_credito = ax_numcred
                   AND sd_paginter.empresa = ax_empresa;

		FOREACH SELECT UNIQUE(cod_comis)
			  INTO v_codseg
			  FROM sd_detcomi
                         WHERE empresa = ax_empresa 
                           AND num_credito = ax_numcred
                           AND fecha_alta > v_hoy
		           AND estado_com = "P"
                           AND EXISTS(SELECT cod_comis FROM sd_tpcomis
                                       WHERE comi_o_seg = "2")

			UPDATE sd_detcomi SET estado_com = "C", 
					      fecha_pago = v_hoy
                         WHERE empresa = ax_empresa
                           AND num_credito = ax_numcred
                           AND fecha_alta > v_fechavig
			   AND cod_comis = v_codseg
                           AND estado_com = "P";


		END FOREACH


		IF v_fechavig = v_hoy THEN
			SELECT monto_cuota - monto_real_pag
		    	  INTO v_intmes
			  FROM sd_paginter
		         WHERE num_credito = ax_numcred
			   AND fecha_cuota = v_fechavig;

			UPDATE sd_maesdos SET sdo_no_exig = v_intmes
		 	 WHERE num_credito = ax_numcred
		   	   AND empresa = ax_empresa ;

                        UPDATE sd_paginter SET monto_cuota = 0
                         WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_cuota > v_fechavig
                           AND status_cuota <> "5"
			   AND monto_real_pag = 0;

			-- Determina monto de intereses por condonacion con 
			-- el fin de no reembolsar esa cxantidad al cliente

			SELECT SUM(monto) INTO v_mtocon
			  FROM sd_movdia
			 WHERE codigo_ref IN (7,8,9)
			   AND codigo_fun = "005"
			   AND num_credito = ax_numcred;

			-- Determina si hay que regresar monto por intereses
			-- pagados por adelantado


			SELECT SUM(monto_real_pag) INTO v_intmes 
			  FROM sd_paginter 
			 WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_cuota > v_fechavig;
			
			LET v_intmes = v_mtocon - v_intmes;
			IF v_intmes > 0 THEN

			   EXECUTE PROCEDURE 
				bdicheq:abono_ref(ax_empresa, ax_sucursal,
						  ax_usuario, v_tran,
						  "0604",     ax_folio,
						  SUBSTR(ax_numcred,1,9)||"300",
						  0, v_intmes, v_intmes,0,0,0,
						  "01", "REEMBOLSO INT CRED")
				INTO s_codret;
				
			   IF s_codret <> "000" THEN
				RETURN s_codret;
			   END IF

			END IF

                        UPDATE sd_paginter SET monto_cuota = 0,
					       monto_real_pag = 0,
					       status_cuota ="5"
                         WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_cuota > v_fechavig;

			-- Cancela cuotas de Seguros mayores a la vigente
			UPDATE sd_detcomi SET estado_com ="C"
                         WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_alta > v_fechavig;

			RETURN s_codret;
		END IF

		SELECT monto_real_pag INTO v_sdo
		  FROM sd_paginter
		 WHERE num_credito = ax_numcred
		   AND empresa = ax_empresa
		   AND fecha_cuota = v_fechavig;

		IF v_fechavig <> "01/01/1800" THEN
		  IF v_sdo > v_intdia THEN
			LET v_sdo = v_sdo - v_intdia;
			UPDATE sd_paginter SET monto_cuota = v_intdia,
					       monto_real_pag = v_intdia
		 	 WHERE num_credito = ax_numcred
		   	   AND empresa = ax_empresa 
		   	   AND fecha_cuota = v_fechavig;

			UPDATE sd_maesdos SET sdo_no_exig = 0
		 	 WHERE num_credito = ax_numcred
		   	   AND empresa = ax_empresa ;

                        SELECT SUM(monto_real_pag) INTO v_intmes
			  FROM sd_paginter
                         WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_cuota > v_fechavig;

                        -- Determina monto de intereses por condonacion con
                        -- el fin de no reembolsar esa cxantidad al cliente

                        SELECT SUM(monto) INTO v_mtocon
                          FROM sd_movdia
                         WHERE codigo_ref IN (7,8,9)
                           AND codigo_fun = "005"
                           AND num_credito = ax_numcred;

			LET v_intmes = v_mtocon - (v_intmes + v_sdo);
                        IF v_intmes > 0 THEN

                           EXECUTE PROCEDURE
                                bdicheq:abono_ref(ax_empresa, ax_sucursal,
                                                  ax_usuario, v_tran,
                                                  "0604",     ax_folio,
                                                  SUBSTR(ax_numcred,1,9)||"300",
                                                  0, v_intmes, v_intmes,0,0,0,
                                                  "01", "REEMBOLSO INT CRED")
                                INTO s_codret;

                           IF s_codret <> "000" THEN
                                RETURN s_codret;
                           END IF

                        END IF

		  ELSE
			UPDATE sd_paginter SET monto_cuota = v_intdia
		 	 WHERE num_credito = ax_numcred
		   	   AND empresa = ax_empresa 
		   	   AND fecha_cuota = v_fechavig;

			UPDATE sd_maesdos SET sdo_no_exig = v_intdia
		 	 WHERE num_credito = ax_numcred
		   	   AND empresa = ax_empresa ;

                        -- Determina monto de intereses por condonacion con
                        -- el fin de no reembolsar esa cxantidad al cliente

                        SELECT SUM(monto) INTO v_mtocon
                          FROM sd_movdia
                         WHERE codigo_ref IN (7,8,9)
                           AND codigo_fun = "005"
                           AND num_credito = ax_numcred;

                        SELECT SUM(monto_real_pag) INTO v_intmes
			  FROM sd_paginter
                         WHERE num_credito = ax_numcred
                           AND empresa = ax_empresa
                           AND fecha_cuota > v_fechavig;

			LET v_intmes = v_mtocon - v_intmes;

                        IF v_intmes > 0 THEN

                           EXECUTE PROCEDURE
                                bdicheq:abono_ref(ax_empresa, ax_sucursal,
                                                  ax_usuario, v_tran,
                                                  "0604",     ax_folio,
                                                  SUBSTR(ax_numcred,1,9)||"300",
                                                  0, v_intmes, v_intmes,0,0,0,
                                                  "01", "REEMBOLSO INT CRED")
                                INTO s_codret;

                           IF s_codret <> "000" THEN
                                RETURN s_codret;
                           END IF

                        END IF

		  END IF


		  UPDATE sd_paginter SET monto_cuota = 0, 
					 monto_real_pag = 0,
					 status_cuota ="5"
		   WHERE num_credito = ax_numcred
		     AND empresa = ax_empresa
		     AND fecha_cuota > v_fechavig;

                  -- Cancela cuotas de Seguros mayores a la vigente
                  UPDATE sd_detcomi SET estado_com ="C"
                   WHERE num_credito = ax_numcred
                     AND empresa = ax_empresa
                     AND fecha_alta > v_fechavig;

		END IF


END
	RETURN s_codret;



END PROCEDURE
DOCUMENT
'Procedimiento de Liquidacion de Creditos en transaccion de pago',
' es llamado por Principal (PL)',
'AUTOR : Antonio Ruiz Mtz. ',
'FECHA : 17/Noviembre/2005',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cargoref_td1(pSucursal   CHAR(4),
                                pUsuario    CHAR(8),
                                pNumTran    CHAR(4),
                                pNumTranS   CHAR(4),
                                pFolio      CHAR(16),
                                pNumCredito CHAR(20),
                                pMonto      MONEY(16,2),
                                pDivisa     CHAR(2),
                                pReferencia CHAR(40))
   RETURNING CHAR(5), CHAR(4), DATE, MONEY(16,2), MONEY(16,2);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE MontoOtorgado       MONEY(16,2);
   DEFINE CodigoRef           INTEGER;
   DEFINE CodigoFun           CHAR(3);
   DEFINE wEmpresa            CHAR(3);
   DEFINE wSucursal           CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE pForzado            CHAR(1);
   DEFINE wBegin              CHAR(1);
   define vusuario            char(8);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
   END EXCEPTION;




   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

set explain on;



   LET wBegin = "N";
   let vusuario = User;

   BEGIN WORK;
   LET cod_ret = "000";
   LET CodigoFun = "002";
   LET MontoOtorgado = 0;
   if pNumTranS = "9999" then --- Retiro de instacash por ventanilla
      LET Codigoref = 6;
      LET pForzado = "N";
   else
      if pNumTran[1,1] = "1" then
         LET Codigoref = 7;
      else
         LET Codigoref = 8;
      end if
      IF(pNumTran[4,4] = "1") THEN
         LET pForzado = "S";
      ELSE
         LET pForzado = "N";
      END IF;
   end if

   LET FechaHoy = NULL;
   SELECT
      a.empresa,
      a.sucursal,
      a.divisa,
      a.num_producto,
      a.status_cred,
      b.monto_otorgado - b.sdo_cap_insoluto,
      c.maneja_linea
   INTO
      wEmpresa,
      wSucursal,
      wDivisa,
      NumProducto,
      StatusCred,
      Saldo,
      ManejaLinea
   FROM
      sd_maecred a,
      sd_maesdos b,
      sd_definicion c
   WHERE
      a.num_credito = pNumCredito and
      a.empresa = "001"
   AND
      b.num_credito = a.num_credito and
      a.empresa = b.empresa
   AND
      c.num_producto = a.num_producto;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pNumTranS = "9999" then
      	LET cod_ret = "100";
      ELSE
      	LET cod_ret = "008";
      END IF
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
   END IF;

   IF(ManejaLinea <> "S") THEN
      LET cod_ret = "206";
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
   END IF;

   IF (Saldo = 0 AND pForzado <> "S") THEN
      LET cod_ret = "202";
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
   END IF;

--boorame
   LET pForzado = "S";
--hasat aqui

   IF (pMonto > Saldo AND pForzado <> "S") THEN
      IF pNumTranS = "9999" then
      	LET cod_ret = "700";
      ELSE
      	LET cod_ret = "203";
      END IF
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
   END IF;

   IF(pMonto > Saldo) THEN
      LET MontoOtorgado = pMonto - Saldo;
   END IF;

   UPDATE
      sd_maesdos
   SET
      sdo_capital = sdo_capital + pMonto,
      sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
      mto_ministra_cap = mto_ministra_cap + pMonto,
      cargos_mes_cap   = cargos_mes_cap + pmonto
   WHERE
      num_credito = pNumCredito
   AND
      empresa = wEmpresa;

   SELECT
      fecha_hoy
   INTO
      FechaHoy
   FROM
      sd_fechas
   WHERE
      empresa = wEmpresa;

   CALL genmov(wEmpresa, pNumCredito, NumProducto,
               CodigoRef, CodigoFun, FechaHoy,
               pMonto, pFolio, wSucursal, wDivisa, pNumTran)
      RETURNING cod_ret, mensaje;


   IF(cod_ret <> "00000") THEN
      ROLLBACK WORK;
   ELSE
      COMMIT WORK;
   END IF;
   IF (wBegin = "S") THEN
     BEGIN WORK;
   END IF;
   LET Saldo = Saldo - pMonto + MontoOtorgado;
   RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto;
END PROCEDURE
DOCUMENT
'Esta funcion realiza el cargo a una linea de credito  ',
'Inta - Cash',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'BD : bdicred ',
'CLIENTE : CACSI';

CREATE PROCEDURE "informix".modif_minis(
   p_num_credito CHAR(20),
   p_sucursal    CHAR(4),
   p_ejecutivo   CHAR(8),
   p_cuota1      smallint,
   p_fecha1      DATE,
   p_monto1      MONEY(14,2),
   p_status1     CHAR(1),
   p_cuota2      smallint,
   p_fecha2      DATE,
   p_monto2      MONEY(14,2),
   p_status2     CHAR(1),
   p_cuota3      smallint,
   p_fecha3      DATE,
   p_monto3      MONEY(14,2),
   p_status3     CHAR(1),
   p_cuota4      smallint,
   p_fecha4      DATE,
   p_monto4      MONEY(14,2),
   p_status4     CHAR(1),
   p_cuota5      smallint,
   p_fecha5      DATE,
   p_monto5      MONEY(14,2),
   p_status5     CHAR(1),
   p_cuota6      smallint,
   p_fecha6      DATE,
   p_monto6      MONEY(14,2),
   p_status6     CHAR(1),
   p_cuota7      smallint,
   p_fecha7      DATE,
   p_monto7      MONEY(14,2),
   p_status7     CHAR(1),
   p_cuota8      smallint,
   p_fecha8      DATE,
   p_monto8      MONEY(14,2),
   p_status8     CHAR(1),
   p_cuota9      smallint,
   p_fecha9      DATE,
   p_monto9      MONEY(14,2),
   p_status9     CHAR(1),
   p_cuota10     smallint,
   p_fecha10     DATE,
   p_monto10     MONEY(14,2),
   p_status10    CHAR(1),
   p_cuota11     smallint,
   p_fecha11     DATE,
   p_monto11     MONEY(14,2),
   p_status11    CHAR(1),
   p_cuota12     smallint,
   p_fecha12     DATE,
   p_monto12     MONEY(14,2),
   p_status12    CHAR(1),
   p_cuota13     smallint,
   p_fecha13     DATE,
   p_monto13     MONEY(14,2),
   p_status13    CHAR(1),
   p_cuota14     smallint,
   p_fecha14     DATE,
   p_monto14     MONEY(14,2),
   p_status14    CHAR(1),
   p_cuota15     smallint,
   p_fecha15     DATE,
   p_monto15     MONEY(14,2),
   p_status15    CHAR(1),
   p_cuota16     smallint,
   p_fecha16     DATE,
   p_monto16     MONEY(14,2),
   p_status16    CHAR(1),
   p_cuota17     smallint,
   p_fecha17     DATE,
   p_monto17     MONEY(14,2),
   p_status17    CHAR(1),
   p_cuota18     smallint,
   p_fecha18     DATE,
   p_monto18     MONEY(14,2),
   p_status18    CHAR(1),
   p_cuota19     smallint,
   p_fecha19     DATE,
   p_monto19     MONEY(14,2),
   p_status19    CHAR(1),
   p_cuota20     smallint,
   p_fecha20     DATE,
   p_monto20     MONEY(14,2),
   p_status20    CHAR(1)
   )
   RETURNING CHAR(5);



   --Define Variables de Trabajo

   DEFINE v_codret               LIKE bdinteg:si_codret.codigo_retorno;
   DEFINE vm_num_credito         LIKE sd_maecred.num_credito;
   DEFINE vmn_num_credito        LIKE sd_detminis.num_credito;
   DEFINE vm_num_minis           LIKE sd_detminis.num_minis;
   DEFINE vm_fecha_otorga        LIKE sd_detminis.fecha_otorga;
   DEFINE vm_fecha_prog          LIKE sd_detminis.fecha_programada;
   DEFINE vm_monto_otorgado      LIKE sd_detminis.monto_otorgado;
   DEFINE vm_monto_real          LIKE sd_detminis.monto_real_otorg;
   DEFINE vm_mto_anticipado      LIKE sd_detminis.mto_anticipado;
   DEFINE vm_sdo_por             LIKE sd_detminis.sdo_por_ministrar;
   DEFINE vm_sdo_cuota           LIKE sd_detminis.sdo_cuota;
   DEFINE vm_status_ministra     LIKE sd_detminis.status_ministra;
   DEFINE vm_obser1              LIKE sd_detminis.obser1;
   DEFINE vm_campo1              LIKE sd_detminis.campo1;
   DEFINE vm_campo2              LIKE sd_detminis.campo2;
   DEFINE vm_campo3              LIKE sd_detminis.campo3;
   DEFINE vm_campo4              LIKE sd_detminis.campo4;
   DEFINE vp_minis_orig_prop     LIKE sd_solcamin.minis_orig_prop;
   DEFINE v_cuantas              INTEGER;
   DEFINE i                      INTEGER;
   DEFINE v_regional             LIKE bdinteg:si_regional.regional;
   DEFINE v_plaza                LIKE bdinteg:si_plazas.plaza;
   DEFINE vt_num_credito         LIKE sd_maecred.num_credito;
   DEFINE vt_num_minis           LIkE sd_solcamin.num_minis;
   DEFINE cStatus                CHAR(2);
   DEFINE cCveSucursal           CHAR(4);
   DEFINE pcuota                 SMALLINT;
   DEFINE pfecha                 DATE;
   DEFINE pmonto                 MONEY(14,2);
   DEFINE pstatus                CHAR(1);



   --Inicializa Variables



   LET vm_num_credito           = "  ";
   LET vmn_num_credito          = "  ";
   LET vm_num_minis             = 0;
   LET vm_fecha_otorga          = "  ";
   LET vm_fecha_prog            = "  ";
   LET vm_monto_otorgado        = 0;
   LET vm_monto_real            = 0;
   LET vm_mto_anticipado        = 0;
   LET vm_sdo_por               = 0;
   LET vm_sdo_cuota             = 0;
   LET vm_status_ministra       = " ";
   LET vm_obser1                = "  ";
   LET vm_campo1                = 0;
   LET vm_campo2                = 0;
   LET vm_campo3                = 0;
   LET vm_campo4                = "  ";
   LET v_codret                 = "000";
   LET vp_minis_orig_prop       = "P";
   LET v_cuantas                = 0;
   LET i                        = 0;
   LET v_regional               = " ";
   LET v_plaza                  = " ";
   LET vt_num_credito           = " ";
   LET vt_num_minis             = 0;
   LET cStatus                  = "";

   --Validacion de los Parametros
   IF p_num_credito IS NULL OR
      p_sucursal    IS NULL OR
      p_ejecutivo   IS NULL THEN
      LET v_codret  = "016";
      RETURN v_codret;
   END IF;

   IF p_cuota1      IS NULL OR
      p_fecha1      IS NULL OR
      p_monto1      IS NULL OR
      p_status1     IS NULL THEN
      LET v_codret  = "017";
      RETURN v_codret;
   END IF;

   IF p_cuota2      IS NULL OR
      p_fecha2      IS NULL OR
      p_monto2      IS NULL OR
      p_status2     IS NULL THEN
      LET v_codret  = "018";
      RETURN v_codret;
   END IF;

   IF p_cuota3      IS NULL OR
      p_fecha3      IS NULL OR
      p_monto3      IS NULL OR
      p_status3     IS NULL THEN
      LET v_codret  = "019";
      RETURN v_codret;
   END IF;

   IF p_cuota4      IS NULL OR
      p_fecha4      IS NULL OR
      p_monto4      IS NULL OR
      p_status4     IS NULL THEN
      LET v_codret  = "020";
      RETURN v_codret;
   END IF;

   --Validacion de los Datos

   IF p_num_credito IS NULL OR p_num_credito = "                    " THEN
      LET v_codret  = "021";
      RETURN v_codret;
   END IF;

   IF p_sucursal IS NULL OR p_sucursal = "   " THEN
      LET v_codret  = "022";
      RETURN v_codret;
   END IF;

   --Valida Sucursal, Plaza, Regional

   SELECT plaza
      INTO v_plaza
      FROM bdinteg:si_sucursales
      WHERE bdinteg:si_sucursales.sucursal = p_sucursal;

   SELECT regional
      INTO v_regional
      FROM bdinteg:si_plazas
      WHERE bdinteg:si_plazas.plaza = v_plaza;


   --Valida el Numero de Credito

   SELECT num_credito,sucursal
      INTO vm_num_credito, cCveSucursal
      FROM sd_maecred
      WHERE num_credito = p_num_credito;

   IF vm_num_credito IS NULL OR vm_num_credito = "  " THEN
      LET v_codret = "023";
      RETURN v_codret;
   END IF

   IF cCveSucursal != p_sucursal THEN
      LET v_codret = "246"; -- EL CREDITO NO ES DE LA SUCURSAL QUE SOLICITA
      RETURN v_codret;
   END IF;


   -- Valida que la existencia de una solicitud

   SELECT status_cambio
      INTO cStatus
      FROM sd_solcamin
      WHERE sd_solcamin.num_credito     = p_num_credito AND
            sd_solcamin.minis_orig_prop = "P" AND
            sd_solcamin.num_minis       = 1 ;

   IF cStatus = "RE" OR cStatus = "RV" OR cStatus = "OP" THEN
      DELETE FROM bdicred:sd_solcamin
         WHERE bdicred:sd_solcamin.num_credito = p_num_credito;
   ELSE
      IF cStatus = "CO" OR cStatus = "AT" THEN
         LET v_codret = "412";                     -- SOLICITUD ESTA EN TRAMITE
         RETURN v_codret;
--    ELSE
--       LET v_codret = "419";                     -- SOLICITUD YA FUE APLICADA
--       RETURN v_codret;
      END IF
   END IF

   --Valida el Numero de Ministraciones por Ministrar por Credito

   SELECT COUNT(*)
      INTO v_cuantas
      FROM sd_detminis
      WHERE num_credito = p_num_credito;
      --AND  status_ministra = "P";

   IF v_cuantas > 0 THEN
      FOR i = 1 TO 20
         IF i = 1 THEN
            LET pcuota  = p_cuota1;
            LET pfecha  = p_fecha1;
            LET pmonto  = p_monto1;
            LET pstatus = p_status1;
         ELIF i = 2 THEN
            LET pcuota  = p_cuota2;
            LET pfecha  = p_fecha2;
            LET pmonto  = p_monto2;
            LET pstatus = p_status2;
         ELIF i = 3 THEN
            LET pcuota  = p_cuota3;
            LET pfecha  = p_fecha3;
            LET pmonto  = p_monto3;
            LET pstatus = p_status3;
         ELIF i = 4 THEN
            LET pcuota  = p_cuota4;
            LET pfecha  = p_fecha4;
            LET pmonto  = p_monto4;
            LET pstatus = p_status4;
         ELIF i = 5 THEN
            LET pcuota  = p_cuota5;
            LET pfecha  = p_fecha5;
            LET pmonto  = p_monto5;
            LET pstatus = p_status5;
         ELIF i = 6 THEN
            LET pcuota  = p_cuota6;
            LET pfecha  = p_fecha6;
            LET pmonto  = p_monto6;
            LET pstatus = p_status6;
         ELIF i = 7 THEN
            LET pcuota  = p_cuota7;
            LET pfecha  = p_fecha7;
            LET pmonto  = p_monto7;
            LET pstatus = p_status7;
         ELIF i = 8 THEN
            LET pcuota  = p_cuota8;
            LET pfecha  = p_fecha8;
            LET pmonto  = p_monto8;
            LET pstatus = p_status8;
         ELIF i = 9 THEN
            LET pcuota  = p_cuota9;
            LET pfecha  = p_fecha9;
            LET pmonto  = p_monto9;
            LET pstatus = p_status9;
         ELIF i = 10 THEN
            LET pcuota  = p_cuota10;
            LET pfecha  = p_fecha10;
            LET pmonto  = p_monto10;
            LET pstatus = p_status10;
         ELIF i = 11 THEN
            LET pcuota  = p_cuota11;
            LET pfecha  = p_fecha11;
            LET pmonto  = p_monto11;
            LET pstatus = p_status11;
         ELIF i = 12 THEN
            LET pcuota  = p_cuota12;
            LET pfecha  = p_fecha12;
            LET pmonto  = p_monto12;
            LET pstatus = p_status12;
         ELIF i = 13 THEN
            LET pcuota  = p_cuota13;
            LET pfecha  = p_fecha13;
            LET pmonto  = p_monto13;
            LET pstatus = p_status13;
         ELIF i = 14 THEN
            LET pcuota  = p_cuota14;
            LET pfecha  = p_fecha14;
            LET pmonto  = p_monto14;
            LET pstatus = p_status14;
         ELIF i = 15 THEN
            LET pcuota  = p_cuota15;
            LET pfecha  = p_fecha15;
            LET pmonto  = p_monto15;
            LET pstatus = p_status15;
         ELIF i = 16 THEN
            LET pcuota  = p_cuota16;
            LET pfecha  = p_fecha16;
            LET pmonto  = p_monto16;
            LET pstatus = p_status16;
         ELIF i = 17 THEN
            LET pcuota  = p_cuota17;
            LET pfecha  = p_fecha17;
            LET pmonto  = p_monto17;
            LET pstatus = p_status17;
         ELIF i = 18 THEN
            LET pcuota  = p_cuota18;
            LET pfecha  = p_fecha18;
            LET pmonto  = p_monto18;
            LET pstatus = p_status18;
         ELIF i = 19 THEN
            LET pcuota  = p_cuota19;
            LET pfecha  = p_fecha19;
            LET pmonto  = p_monto19;
            LET pstatus = p_status19;
         ELIF i = 20 THEN
            LET pcuota  = p_cuota20;
            LET pfecha  = p_fecha20;
            LET pmonto  = p_monto20;
            LET pstatus = p_status20;
         END IF

         IF pmonto = 0 OR pmonto IS NULL THEN
            EXIT FOR;
         END IF;

         --Selecciona los Datos A Detalle de La Ministracion
         SELECT *
            INTO vmn_num_credito, vm_num_minis, vm_fecha_otorga,
                 vm_fecha_prog, vm_monto_otorgado, vm_monto_real,
                 vm_mto_anticipado, vm_sdo_por, vm_sdo_cuota,
                 vm_status_ministra, vm_obser1, vm_campo1,
                 vm_campo2, vm_campo3, vm_campo4
            FROM sd_detminis
            WHERE num_credito = p_num_credito AND
                  num_minis   = pcuota;

         IF pfecha = "01/01/1800" OR vm_fecha_prog IS NULL THEN
            EXIT FOR;
         END IF;

         --Validacion de Insercion o Actualizacion de los Registros.
         SELECT num_credito,num_minis
            INTO vt_num_credito,vt_num_minis
            FROM sd_solcamin
            WHERE num_credito = p_num_credito AND
                  num_minis   = i             AND
                  minis_orig_prop = "O";

         LET pstatus = vm_status_ministra;
         IF vt_num_minis IS NULL THEN
            INSERT INTO sd_solcamin
               VALUES(v_regional,v_plaza,p_sucursal,p_num_credito,
                      pcuota,vp_minis_orig_prop,pfecha,
                      pfecha, pmonto, vm_monto_real,
                      vm_mto_anticipado, vm_sdo_por, pmonto,
                      pstatus, vm_obser1, p_ejecutivo,
                      " "," ","CO","  ");
         ELSE
            UPDATE sd_solcamin
               SET(fecha_programada,sdo_cuota,comentarios)=(pfecha,pmonto,vm_obser1)
                  WHERE num_credito = p_num_credito AND
                        num_minis   = i             AND
                        minis_orig_prop = "O";
         END IF

      END FOR

   END IF

  RETURN v_codret;

END PROCEDURE;