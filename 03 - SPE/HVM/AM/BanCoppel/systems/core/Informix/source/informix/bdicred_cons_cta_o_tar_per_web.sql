CREATE PROCEDURE "informix".cons_cta_o_tar_per_web(pempresa     CHAR(3),
                                           psistema     SMALLINT,
                                           ptipoctatar  CHAR(1),
                                           pctatar      CHAR(20),
                                           pregistros   SMALLINT,
                                           pMigracionVisaActiva CHAR(1))

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
          CHAR(26),      -- Nombre2
          CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,           -- Fecha Nacimiento
          CHAR(13),      -- RFC
          CHAR(20),      -- CUENTA
          CHAR(20),      -- TARJETA
          CHAR(1),       -- STATUS APLICATIVOS
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR(3);       --STATUS INTERCARD


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numcte        CHAR(20);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_paterno       CHAR(26);
DEFINE s_materno       CHAR(26);
DEFINE s_fechanac      DATE;
DEFINE s_rfc           CHAR(13);
DEFINE s_cuenta        CHAR(20);
DEFINE s_tarjeta       CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE s_status        CHAR(1);
DEFINE s_status_cta       CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE bValCuenta       BOOLEAN;
DEFINE cValor           CHAR(2);
DEFINE cValorCred       CHAR(2);
DEFINE cStatusCred       CHAR(2);
DEFINE cProdTransfer   CHAR(4);
DEFINE cProdTarjeta    CHAR(4);
DEFINE vBinTar       CHAR(6);
DEFINE vSubBinTar      CHAR(2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET v_cuantos    = 0;
LET s_numcte     = "";
LET s_nombre1  = "";
LET s_nombre2  = "";
LET s_paterno  = "";
LET s_materno  = "";
LET s_fechanac = "";
LET s_rfc  = "";
LET s_cuenta   = "";
LET s_tarjeta  = "";
LET s_status    = "";
LET s_status_cta ="";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta =  "";
LET bValCuenta    = "T";
LET cValor        = "";
LET cValorCred    = "";
LET cStatusCred   = "";
LET cProdTransfer = '';
LET cProdTarjeta  = '';
LET vBinTar  = '';
LET vSubBinTar = '';

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/cons_cta_o_tar_per.sql";
--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


   LET pempresa = pempresa;
   LET psistema = psistema;
   LET ptipoctatar = ptipoctatar;
   LET pctatar = pctatar;


  -- Valida Parametros de Entrada

  IF pempresa = "" OR
     psistema = "" OR
     ptipoctatar = "" OR
     pctatar = "" THEN
     LET scod_ret = "00110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
  END IF
  
      -----------------------------------VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000------------------------------ 
      SELECT valor
      INTO cProdTransfer
      FROM bditransfer:"informix".tf_param
      WHERE empresa = pempresa AND cod_param = 4;

      SELECT prodtarjeta 
      INTO cProdTarjeta
      FROM bdicheq:"informix".sc_tarjeta
      WHERE empresa = pempresa AND num_tarjeta = pctatar;


      IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
      
         LET scod_ret = "00858";
         
         RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
         
      END IF
---------------------------TERMINA VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000-------------------------------- 

  IF psistema = 1 THEN -- Sistema de Cheques
  
                SELECT valor  INTO cValor
            FROM bdicheq:"informix".sc_param WHERE codparam = 'longcta';

     IF ptipoctatar = "C" THEN

        --Valida que la cuenta exista en cheques

        SELECT mae.status_cta, mae.num_cte, mae.cuenta, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
               clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc
          INTO s_status, s_numcte, s_cuenta, s_producto, s_divisa,
               s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc
          FROM bdicheq:"informix".sc_maechq mae,
               bdinteg:"informix".si_cliente clie,
               bdinteg:"informix".si_ctepf cte,
               bdinteg:"informix".si_divisas div,
               bdicheq:"informix".sc_producto prod
         WHERE mae.empresa = clie.empresa
               AND mae.empresa = cte.empresa
               AND mae.num_cte = clie.numcte
               AND mae.num_cte = cte.numcte
               AND prod.empresa = mae.empresa
               AND prod.producto = mae.producto
               AND div.empresa = mae.empresa
               AND div.divisa = prod.divisa
               AND ((mae.empresa= pempresa) AND (mae.cuenta= pctatar));

       --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
      EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
      INTO bValCuenta;                  

      IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
         LET scod_ret = "00002";
         RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
      END IF 
      
        IF s_status IS NULL OR s_status  = "" THEN
           LET scod_ret = "00100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status = "2" THEN
           LET scod_ret = "00200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status = "3" THEN
           LET scod_ret = "00100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        -- Busca las Tarjetas Relacionadas a las Cuentas
      -- Se agrega la validacion a la sc_firmantes para solo buscar tarjetas autorizadas
      -- CGP 10032015
        FOREACH
            SELECT tardeb.num_tarjeta, tardeb.cuenta, tardeb.status_tar, tar.codstatustarjeta
            INTO s_tarjeta, s_cuenta, s_status, s_codstatustarjeta
            FROM bdicheq:"informix".sc_tarjeta tardeb, intercard:"informix".tarjeta tar, bdicheq:"informix".sc_firmantes as firm
         WHERE (tardeb.empresa= pempresa)
            AND (tardeb.cuenta= pctatar)
            AND(tardeb.num_tarjeta = tar.numtarjeta )
         and (firm.cuenta = tardeb.cuenta)
         and (firm.numcte = tardeb.numcte)
            ORDER BY num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF

           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;


        END FOREACH
     END IF

     IF ptipoctatar = "T" THEN

        FOREACH
           SELECT tarj.cuenta, tarj.numcte, tarj.num_tarjeta, tarj.status_tar, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta, mae.status_cta
             INTO s_cuenta, s_numcte, s_tarjeta, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta, s_status_cta
             FROM bdicheq:"informix".sc_tarjeta tarj,
              bdicheq:"informix".sc_maechq mae, --se agrega la tabla maechq para validar el estatus de la cuenta de la tarjeta que se desliza  
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdinteg:"informix".si_divisas div,
                  bdicheq:"informix".sc_producto prod,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
              AND tarj.cuenta = mae.cuenta
                  AND prod.empresa = tarj.empresa
                  AND prod.producto = mae.producto
                  AND div.empresa = tarj.empresa
                  AND div.divisa = prod.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
               -- AND (tarj.tipo_tarjeta='T')
               -- AND (tarj.status_tar='A')
                  AND (tarj.num_tarjeta=pctatar))
            ORDER BY tarj.num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
         
                
         --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
         EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
         INTO bValCuenta;   
      --se valida el estatus de la cuenta de la tarjeta que se esta deslizando
         IF s_status_cta IS NULL OR s_status_cta  = "" THEN
           LET scod_ret = "00100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status_cta = "2" THEN
           LET scod_ret = "00200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status_cta = "3" THEN
           LET scod_ret = "00100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

         IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
            LET scod_ret = "00002";
         END IF
   
         --dsb 28/05/2012
         IF scod_ret <> "00002" THEN
            SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
            EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
            INTO bValCuenta;                  

            IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" OR s_cuenta IS NULL THEN 
               LET scod_ret = "00002";
            END IF
         END IF
         
         
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

         
        END FOREACH
     END IF
  END IF

  IF psistema = 6 THEN -- Sistema de Credito

                SELECT valor INTO cValorCred
            FROM bdicred:"informix".sd_param WHERE cod_param = '8';
            
     IF ptipoctatar = "T" THEN


      --DSB PAY INICIO
      LET vBinTar = SUBSTR(pctatar,1,6);
      IF pMigracionVisaActiva = '1' THEN
            LET vSubBinTar = SUBSTR(pctatar,7,2);
      END IF
        
      IF TRIM(vBinTar) = '514014' OR (TRIM(vBinTar) = '426807' AND TRIM(vSubBinTar) = '05' OR TRIM(vSubBinTar) = '08') THEN
      
        FOREACH
          SELECT tarc.numcuenta, tarc.numtarjeta, tar.numcliente, tar.codstatustarjeta, def.num_producto || " " || def.nombre_prod, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta
             INTO s_cuenta, s_tarjeta, s_numcte, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta
             FROM intercard:"informix".tarjetacuenta tarc,
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdicred:"informix".sd_definicion def,
                  bdinteg:"informix".si_divisas div,
                  intercard:"informix".tarjeta tar
            WHERE clie.numcte = cte.numcte
              AND tar.numcliente = clie.numcte
                  AND tar.numcliente = cte.numcte
                  AND tarc.numtarjeta = tar.numtarjeta
              AND div.divisa = '01'
                  AND def.num_producto = '8100'
                  AND ((def.empresa=pempresa)
                  AND (tar.numtarjeta=pctatar))
              
              RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;
       END FOREACH
              
      ELSE

      --DSB PAY FIN

        FOREACH


           SELECT tarj.num_credito, tarj.num_tarjeta, tarj.numcte, tarj.status_tar, def.num_producto || " " || def.nombre_prod, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta
             INTO s_cuenta, s_tarjeta, s_numcte, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta
             FROM bdicred:"informix".sd_tarjeta tarj,
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdicred:"informix".sd_maecred mae,
                  bdicred:"informix".sd_definicion def,
                  bdinteg:"informix".si_divisas div,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
                  AND mae.empresa = tarj.empresa
                  AND mae.num_credito = tarj.num_credito
                  AND def.empresa = tarj.empresa
                  AND def.num_producto = mae.num_producto
                  AND div.empresa = mae.empresa
                  AND div.divisa = mae.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
                  --AND (tarj.tipo_tarjeta='T')
                  AND (tarj.num_tarjeta=pctatar))



           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
           
           
          LET cStatusCred = (SELECT status_cred FROM sd_maecred WHERE num_credito=s_cuenta);
 
          IF cStatusCred NOT IN ("AA","BT","BA","E1","E2","E3") THEN
                LET scod_ret = "00279";
                RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
           END IF

          --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
         EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
         INTO bValCuenta;                  

         IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" THEN 
            LET scod_ret = "00002";
         END IF
         
         --dsb 28/05/2012
         --Se valida la cuenta en tarjetacuenta 
         IF scod_ret <> "00002" THEN
            SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
            EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
            INTO bValCuenta;                  

            IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" OR s_cuenta IS NULL  THEN 
               LET scod_ret = "00002";
            END IF
         END IF
         
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

        END FOREACH
     END IF
  END IF

  END IF;  --DSB PAY
  
END
END PROCEDURE
DOCUMENT
"Especificacion: Se modifico para que consulte el status de la tarjeta en",
"                la tabla intercard:tarjeta y se regrese como codigo de retorno",
"Base de Datos : bdicred",
"AUTOR : Elmer Lopez Valenzuela",
"FECHA : 12/Oct/2016";

CREATE PROCEDURE "informix".sp_consultadatos_motor_pp(pEmpresa CHAR(4), pNumSol CHAR(20))
RETURNING 	CHAR(6) 	   as cCodRet,
			CHAR(20)	   as cSolBanco,
			CHAR(20)	   as cNumCteBco,
			CHAR(20) 	   as cNumCte,
			CHAR(4)		   as pEmpresa,
			CHAR(2)		   as cStatusSolicitud,
			CHAR(3)		   as cCausa_Sol,
			CHAR(4)		   as cNum_Producto,
			CHAR(2)		   as cTipoGrupo,
			CHAR(1)		   as cTp_solicitud,
			INTEGER  	   as cB_INE,
			CHAR(50)	   as cHabita_en,
			CHAR(1)		   as cPuntualidadCoppel,
			CHAR(3)		   as cProfesion,
			SMALLINT	   as sId_actividad,
			CHAR(60)	   as cDescAct,
			SMALLINT	   as sId_subactividad,
			CHAR(50)	   as vDescSubAct,
			CHAR(1)		   as cSituacionEspecial,
			SMALLINT 	   as sCausaSituacion,
			CHAR(1)		   as cMotivoRechBcpl,
			SMALLINT 	   as sHist_meses,
			DECIMAL(5,2)   as dEficienciaCoppel,
			INTEGER		   as iCtas_StatusDif_FF_6011,
			CHAR(4)		   as cProducto,
			DECIMAL(18,2)  as mAbonoMuebles,
			DECIMAL(18,2)  as mAbonoPrestamos,
			DECIMAL(18,2)  as mAbonoRopa,
			DECIMAL(18,2)  as mAbonoAire,
			DECIMAL(18,2)  as mAbonoAfiliados,
			DECIMAL(18,2)  as mAbonoReestructura,
			DECIMAL(18,2)  as mVencidoMuebles,
			DECIMAL(18,2)  as mVencidoRopa,
			DECIMAL(18,2)  as mVencidoPrestamos,
			DECIMAL(18,2)  as mVencidoAire,
			DECIMAL(18,2)  as mVencidoAfiliados,
			DECIMAL(18,2)  as mVencidoReestructura,
			CHAR(13)	   as cFechaUltimoPago,
			INTEGER 	   as iReprestamos,
			CHAR(1)		   as cOrigenSol,
			CHAR(60)	   as cDescripcion,
			CHAR(1)		   as cRiesgoViviendaCpl,
			CHAR(1)		   as cRiesgoViviendaBcpl,
			CHAR(1)		   as cActRiesgoCpl,
			CHAR(1)		   as cActRiesgoBCpl,
			CHAR(1)	   as cDescpRiesgo,
			VARCHAR(50)	   as iMax_MOP,
			CHAR(2)		   as cInstCta_MayorMOP,
			DECIMAL(14,2)  as dMonto_UDIS_MayorMOP,
			VARCHAR(50)	   as iMax_MOP_Hist_6m,
			CHAR(2)		   as cInstCta_MayorMOP_6m,
			DECIMAL(14,2)  as dMontoUDIS_MM_6m,
			VARCHAR(50)	   as iMM_Histo_12m,
			CHAR(2)		   as cInstCta_MayorMOP_12m,
			DECIMAL(14,2)  as dMontoUDIS_MM_12m,
			INTEGER		   as iNumCtasMOP_4_12m,
			INTEGER		   as iNumCtasMOP_5_12m,
			INTEGER		   as iNumCtasMOP_mayor5_12m,
			INTEGER		   as iMOP4_12mCon1o2,
			INTEGER		   as iMOP5_12mCon1o2,
			INTEGER		   as iMOPmayor5_12mCon1o2,
			CHAR(2)		   as cInstitucionMMOP_provocaRech,
			DECIMAL(14,2)  as dMontoUDIS_MM_Rech,
			INTEGER  	   as iNumCtasMOP_4_30m,
			INTEGER  	   as iNumCtasMOP_5_30m,
			INTEGER  	   as iNumCtasMOP_mayor5_30m,
			INTEGER  	   as iCtasMOP_4_30mCon1o2,
			INTEGER  	   as iCtasMOP_5_30mCon1o2,
			INTEGER  	   as iCtasMOP_mayor5_30mCon1o2,
			VARCHAR(50)	   as iMM_Histo_30m,
			CHAR(2)  	   as cInstCta_MM_30m_Rech,
			DECIMAL(14,2)  as dMotoUDIS_MM_30m_Rech,
			VARCHAR(50)	   as iNumCtas_ClvOb,
			DECIMAL(14,2)  as dMontoUdis,
			CHAR(2)  	   as cInstitucion,
			CHAR(2)  	   as cClvObser,
			SMALLINT  	   as sBc_Score,
			INTEGER 	   as vClvExclusionMasReciente,
			CHAR(2)		   as cInstitucionClvExclusionMasReciente, 
			INTEGER  	   as iCtas_SinComServ,
			INTEGER 	   as iCtas_SinComServ_pagar,
			INTEGER  	   as iNumCtas_SHBr,
			INTEGER  	   as iNumCtas_SHBr_pagar,
			INTEGER  	   as BC_101,
			INTEGER  	   as iMM_act_Bancos,
			VARCHAR(50)    as iMM_hist_alto_Bancos,
			VARCHAR(50)	   as iMM_hist_Bancos,
			INTEGER  	   as iCtasBancosMOP_tl26,
			INTEGER  	   as iCtasBancosMOP_tl38,
			INTEGER 	   as iCtasBancosMOP_tl27,
			INTEGER  	   as iCtasBancosMOP_act_hist_alto,
			INTEGER 	   as iCtasComServMOP_tl26,
			INTEGER  	   as iCtasComServMOP_tl38,
			INTEGER 	   as iCtasComServMOP_tl27,
			INTEGER  	   as iCtasCSM_act_hist_alto,
			INTEGER 	   as iCtasComServMOP_tl26_12m,
			INTEGER 	   as iCtasComServMOP_tl38_12m,
			INTEGER 	   as iCtasComServMOP_tl27_12m,
			INTEGER		   as iCtasCSM_ActHistAlto_12m,
			CHAR(10)	   as dtFechaAux,
			VARCHAR(50)	   as iMaxMOP_actBancos,
			VARCHAR(50)	   as iMaxMOP_histAltBancos,
			VARCHAR(50)	   as iMaxMOP_histBancos,
			VARCHAR(50)	   as iMaxMOP_actCtas,
			VARCHAR(50)	   as iMaxMOP_histAltCtas,
			VARCHAR(50)	   as iMaxMOP_histCtas,
			VARCHAR(30)    as dSituacionPagoCoppel,
			DECIMAL(18,2)  as mIngreso_Mensual,
			DECIMAL(18,2)  as mPagoMinimo,
			SMALLINT	   as sCteLargo8,
			INTEGER		   as iMeses_hist_Val,
			CHAR(1)		   as cTipo_Alta_CteProsp,
			DECIMAL(18,2)  as mLinea_tienda,
			DECIMAL(18,2)  as mImporte_hip,
			DECIMAL(9,6)   as dTasa,
			VARCHAR(50)	   as sFlagHuella,
			CHAR(1)		   as cResultadoOsTel,
			CHAR(1)		   as cTieneOstel,
			CHAR(1)		   as cEnvioCat,
			INTEGER		   as iSolMc,
			INTEGER		   as iSolMcAux,
			CHAR(2)		   as cCod_Ult_Identif,
			CHAR(13)	   as cTelCasa,
			CHAR(13)	   as cTelTrabajo,
			VARCHAR(50)	   as sValida_Cel,
			CHAR(10) 	   as dtUltimaCompra,
			VARCHAR(50)	   as iBanderareferencia,
			CHAR(10)	   as dtFechaCte,
			CHAR(20)	   as cFolioMovil,
			CHAR(1)		   as cFlagGeoMov,
			VARCHAR(50)	   as iFlagGeoSuc,
			VARCHAR(50)	   as iCanal_Sol,
			CHAR(1)		   as cOrigenCte,
			VARCHAR(50)	   as sFlagForzarEnvioMC,
			VARCHAR(50)	   as iSecuenciaOs,
			CHAR(1)		   as cStatusRespOs,
			CHAR(10)	   as dtFecha_Respuesta,
			CHAR(20)	   as cNumSol_Os,
			CHAR(1)		   as cCompIngresos,
			DECIMAL(14,2)  as dIngresoCac,
			SMALLINT	   as sCompValido,
			CHAR(1)		   as cTipo_movimiento,
			CHAR(4)		   as cSucursal,
			CHAR(1)		   as cTipoSolOS,
			DECIMAL(14,2)  as dCompromisosCac,
			SMALLINT	   as sFlag_oro,
			DECIMAL(18,2)  as mIngreso_Neto,
			CHAR(10)	   as dtFechaNac,
			CHAR(1)		   as cSexo,
			CHAR(50)	   as cEdo_Civil,
			INTEGER	   	   as iTiem_Edo_Civil,
			INTEGER		   as UT0034,
			CHAR(50)	   as cOcupacion,
			INTEGER	       as iTiem_Ocupacion,
			CHAR(50) 	   as cEscolaridad,
			CHAR(50)	   as cTipoResidencia,
			INTEGER	       as iTiem_Residencia,
			VARCHAR(10)    as vClvEdoCob,
			VARCHAR(200)   as vLocalidad,
			CHAR(50)	   as cEntidad,
			VARCHAR(50)	   as sCteLargo,
			CHAR(20)	   as cCURP,
			VARCHAR(50)	   as iFlagEmpleado,
			DECIMAL(14,2)  as dValor_3s,
			CHAR(1)		   as cStatusMovil,
			CHAR(20) 	   as cCteProsp,
			CHAR(2)  	   as cStatusSol_CteProsp,
			CHAR(1) 	   as cRTipo3,
			CHAR(1)  	   as cVigSolOS,
			CHAR(30)	   as sBuenPagos,
			DECIMAL(14,2)  as dCompromisos,
			VARCHAR(50)	   as sFlagBuenPago12,
			VARCHAR(50)	   as sFlagBuenPago30, 
			VARCHAR(50)	   as sEntidad_Localidad,
			CHAR(2)		   as cNuevoStatusOstel,
			CHAR(20)	   as cCteProspVig,
			DECIMAL(18,2)  as mCompro_banco,
			DECIMAL(14,2)  as dComprobanco_TDC,
			DECIMAL(14,2)  as mCompro_bancoPP, 
			CHAR(20)	   as cGeoCte,
			VARCHAR(50)	   as iCanalV1,
			VARCHAR(50)	   as IQ0002, 
			INTEGER		   as iCtas_StatusFF_6011,
			INTEGER	       as iTiem_Edo_Civil_meses,
			INTEGER		   as iExisteCliente,
			DECIMAL(18,2)  as mSaldoRopa,
			DECIMAL(18,2)  as mSaldoMuebles,
			DECIMAL(18,2)  as mSaldoPrestamos, 		 
			SMALLINT	   as vgrupoA,		 
			CHAR(20)	   as NumSolMovil,
			SMALLINT	   as iFlag2credito,
			INTEGER		   as NumCuentaPagoMinimo,
			CHAR(10)	   as dtFechaSolicitud,
			SMALLINT	   as sEdadCte,
			SMALLINT 	   as pMeses_historia_grupo,
			DECIMAL(5,2)   as pSituacion_pago_grupo,
			DECIMAL(18,2) as dSalariomin,
			DECIMAL(18,2) as dTasa_Ordinaria,
			DECIMAL(18,2) as dTasa_Moratoria,
			DECIMAL(18,2) as diva,
			DECIMAL(18,2) as dDiaspromedio,
			DECIMAL(18,2) as dTope_ingre,
			DECIMAL(18,2) as dcVeces_smb,
			DECIMAL(18,2) as dPorcpermitido,
			DECIMAL(18,2) as dMesespermitido,
			DECIMAL(18,2) as dMinimomesespermitido,
			CHAR(30) 	  as cEstado,
			CHAR(30)      as cMunicipio,
			SMALLINT 	  as cBRM_reing,
			CHAR(1)		  as Validaos,
			VARCHAR(100)  as iNewMPP,
			VARCHAR(50)   as vCuentasPF,
			INTEGER		  as BCScorePP,
			INTEGER		  as ScorePropietario,
			INTEGER       as vEficUltSem,
			INTEGER       as vMorAct,
			INTEGER       as vPorcUso,
			CHAR(1)       as velemPuntualidad,
			INTEGER 	  as IQ00012,
			DECIMAL(18,2) as vSumSaldoActualTL22,
			DECIMAL(18,2) as vSumLimCredTL23,
			VARCHAR(50)   as iParamincrDecr,
			INTEGER       as iExisteSolPP,
			SMALLINT 	  as vNumTotalCtas,
			INTEGER 	  as vCtas_al_corriente,
			INTEGER 	  as vCtas_sin_historia,
			SMALLINT 	  as vMesesAperCtaAntigua,
			SMALLINT	  as vMesesAperCtaAntiguaRev,
			INTEGER		  as vNumVecesBANCOPPEL,
			INTEGER 	  as vNumVecesTiendaComercial,
			INTEGER 	  as vNumTotalCtasTL13,
			DECIMAL(14,2) as v_valor_1s,
			INTEGER       as inumppf,
			INTEGER       as mTasa_Interes,
			INTEGER       as capacidad_pres,
			DECIMAL(18,2) as vSaldoMorHistAltaTL36,
			INTEGER       as vCtas_30_mas_atraso_hist,
			INTEGER 	  as iNumCtasAper36,
			CHAR(10) 	  as TL37,
			CHAR(10) 	  as iExisteBR_TL_mora,
			CHAR(10)	  as vFechaTL37,
			DECIMAL(18,2) as iSumaTL13,
			VARCHAR(50)	  as iFlag2credito2,
			VARCHAR(50)   as iValorICC,
			CHAR(2)		  as vInstitucion,
			VARCHAR(50)	  as pFrecuencia,
			VARCHAR(50)   as iDiaPago,
			INTEGER	  	  as vMaxPlazoDias,
			VARCHAR(50)   as vFalloSic,
			CHAR(10)      as dtFechaHoy,
			DECIMAL(18,2) as vSum_bal,
			DECIMAL(18,2) as vSum_higcred,
			VARCHAR(30)	  as origeninput1,	
			VARCHAR(30)	  as origeninput2,	
			VARCHAR(30)	  as origeninput3,	
			VARCHAR(30)	  as origeninput4,	
			DECIMAL(14,2) as origeninput5,
			DECIMAL(14,2) as origeninput6,
			DECIMAL(14,2) as origeninput7,
			DECIMAL(14,2) as origeninput8,
			INTEGER as 		Ictegrandata,
			VARCHAR(10) as fechaaut_grandata,
			VARCHAR(10) as fechacons_grandata,
	---------------------------------------------------------------------------------------------------------------------------------
	-- VARIABLES NUEVAS DE DEVOLUCION  (BRM Marzo 2025) -----------------------------------------------------------------------------
	DECIMAL(10,2) AS dIngreso_ajustado,
	INTEGER 	  AS iMora_coppel,	
	INTEGER 	  AS iSaldo_vencido_coppel,
	INTEGER 	  AS iMora_bancoppel,
	INTEGER 	  AS iSaldo_vencido_bancoppel,
	VARCHAR(50)   AS vTipo_transaccion,        -------------------char(50) en el sp
	INTEGER 	  AS iAntiguedad,
	INTEGER 	  AS iHawk,
	INTEGER 	  AS iFraudes,
	INTEGER 	  AS iFlag_creditopp_activo,
	INTEGER 	  AS iEstabilidadvivienda,
	INTEGER 	  AS iRechazoos,
	INTEGER 	  AS iCn_sic,
	INTEGER 	  AS iLista_negra, 
	INTEGER 	  AS iNo_tramitedia_tdc,
	INTEGER 	  AS iNo_tramitedia_pp,
	CHAR(1000)    AS dSics_montopagar_revolvente,
	CHAR(1000)    AS dSics_montopagar_norevolvente,
	CHAR(1000)    AS dSics_saldoactual_revolvente,
	CHAR(1000)    AS dSics_saldoactual_norevolvente,
	DECIMAL(18,2) AS dGc_saldoactual_coppel,
	DECIMAL(18,2) AS dGc_saldoactual_bancoppel,
	DECIMAL(12,2) AS dGc_montopagar_coppel,
	DECIMAL(18,2) AS Gc_montopagar_bancoppel,
	VARCHAR(50)   AS vTipo_colectivo,
	DECIMAL(8,2)  AS dReestructuras,
	INTEGER  	  AS dIdentificacion_falsa,
	DECIMAL(8,2)  AS dQuebranto,
	DECIMAL(8,2)  AS dPromedio_ingresom_ult4d,
	VARCHAR(24)  AS dContinuidad_depositos_nomina,
	VARCHAR(50)   AS vTipo_empleado_code,
	VARCHAR(50)   AS vTipo_empleado_name,
	VARCHAR(50)   AS vObservacion_mc,
	VARCHAR(50)   AS vOrigeninput9,
	VARCHAR(50)   AS vOrigeninput10,
	VARCHAR(50)   AS vOrigeninput11,
	VARCHAR(50)   AS vOrigeninput12,
	INTEGER 	  AS Origeninput13,
	INTEGER 	  AS Origeninput14,
	INTEGER 	  AS Origeninput15,
	INTEGER 	  AS Origeninput16;
	---------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- DEFINICION DE VARIABLES ---------------------------
--DEFINICION DE VARIABLES DATOS DEL CLIENTE
DEFINE cNumCte                  CHAR(20);      --numero de cliente Coppel
DEFINE cNumCteComp				CHAR(20);      --numero de cliente Coppel completo
DEFINE cNumCteBco		        CHAR(20);      --numero de cliente Bancoppel
DEFINE cNumCteBcoN		        CHAR(20);      --numero de cliente Bancoppel
DEFINE cB_INE		            INTEGER;       --Flag de validaciÃÂÃÂÃÂÃÂ³n INE B_ife
DEFINE cCurp 					CHAR(20);      --Corresponde al CURP del cliente 
DEFINE dtFechaCte			    CHAR(10);      --Corresponde a la fecha de alta del cliente
DEFINE dtFechaNac 				CHAR(10);      --Corresponde a la Fecha de Nacimiento del cliente 
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);      --Correspojde al estado civil del cliente -**
DEFINE iTiem_Edo_Civil          INTEGER;       --Corresponde al tiempo del estado civil 
DEFINE iTiem_Edo_Civil_meses    INTEGER;       --Corresponde al tiempo de estado civil en  meses
DEFINE cEscolaridad             CHAR(50);      --Corresponde al grado maximo de estudios del cliente 
DEFINE cHabita_en               CHAR (50);     --Tipo de vivienda del cliente -**
DEFINE cTipoResidencia          CHAR (50);     --Corresponde al tipo de residencia
DEFINE cEntidad                 CHAR(50);      --Corresponde a la entidad de residencia del cliente -**
DEFINE vLocalidad        		VARCHAR(200);  --Corresponde a la localidad del cliente
DEFINE iTiem_Residencia   		INTEGER;       --Corresponde al tiempo de residencia  
DEFINE cGeoCte		  		    CHAR(20);      --Corresponde a las cordenadas de localizaciÃÂÃÂÃÂÃÂ³n del cliente 
DEFINE cFlagGeoMov			    CHAR(1);       --Corresponde al flag de geolocalizaciÃÂÃÂÃÂÃÂ³n 
DEFINE iFlagGeoSuc		        VARCHAR(50);   --Correspode al flag de geolocalizacion diderente a la ubicaciÃÂÃÂÃÂÃÂ³n de la sucursal
DEFINE cTelCasa                 CHAR(13);      --Corresponde al telÃÂÃÂÃÂÃÂ©fono de casa del cliente
DEFINE cTelTrabajo              CHAR(13);      --Corresponde al telÃÂÃÂÃÂÃÂ©fono de trabajo del cliente
DEFINE cNumCel					VARCHAR(13);
DEFINE Ictegrandata				INTEGER;
DEFINE fechaaut_grandata		VARCHAR(10);
DEFINE fechacons_grandata 		VARCHAR(10);
DEFINE iBanderaReferencia		VARCHAR(50);   --Corresponde a un flag de coincidencia de las referencias telefÃÂÃÂÃÂÃÂ³nicas vs las enviadas a supervisiÃÂÃÂÃÂÃÂ³n
DEFINE sValida_Cel	            VARCHAR(50);   --iValidaCel (numero de tel celulares activos y validados deberÃÂÃÂÃÂÃÂ­a ser max=1
DEFINE cOcupacion               CHAR(50);      --Corresponde a la ocupaciÃÂÃÂÃÂÃÂ³n del cliente
DEFINE iTiem_Ocupacion          INTEGER;       --Corresponde al tiempo que lleva laborando
DEFINE cProfesion             	CHAR(3);       --profesiÃÂÃÂÃÂÃÂ³n del cliente
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente
DEFINE cDescAct 			    CHAR(60);      --descripciÃÂÃÂÃÂÃÂ³n de la actividad que realiza el cliente
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente
DEFINE vDescSubAct      		VARCHAR (50);  --descripciÃÂÃÂÃÂÃÂ³n de la actividad que realiza el cliente
DEFINE mIngreso_Mensual			DECIMAL(18,2); --Corresponde al ingreso mensual reportado por el cliente
DEFINE mIngreso_Neto            DECIMAL(18,2); --Corresponde al ingreso mensual neto del cliente ** validar si viene de informaciÃÂÃÂÃÂÃÂ³n de coppel
DEFINE cCompIngresos			CHAR(1);       --Corresponde al flag comprobante de ingresos del cliente
DEFINE dIngresoCac              DECIMAL(14,2); --Corresponde al ingreso del cliente con comprobante de ingresos valido por Mesa de Control
DEFINE sCompValido      		SMALLINT;      --Corresponde al flag de validaciÃÂÃÂÃÂÃÂ³n por parte de mesa de control del comprobante de ingreso
DEFINE sFlagHuella              VARCHAR(50);   --corresponde a la coincidencia o no de la hulla del cliente banco vs coppel
DEFINE cCod_Ult_Identif         CHAR(2);       --Corresponde a la ultima identificacion presentada por el cliente ( INE,PASAPORTE....ETC)
DEFINE iReferencia				INTEGER;
DEFINE iReferencia1				INTEGER;
DEFINE iReferencia2 			INTEGER;
DEFINE vHuella                  SMALLINT;
DEFINE cValidaINE				CHAR(20);
DEFINE sEdadCte					SMALLINT;
DEFINE cNombreCte				CHAR(50);
DEFINE pMeses_historia_grupo 	SMALLINT;
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);
DEFINE v_meses                SMALLINT; --MACM
DEFINE v_cuantos              SMALLINT;	--MACM								   

--DEFINICION DE VARIABLES DE CUENTA COPPEL
DEFINE dtUltimaCompra           CHAR(10) ;           --Fecha ultima compra
DEFINE cPuntualidadCoppel       CHAR(1);        --clasicficaciÃÂÃÂÃÂÃÂ³n del cliente Coppel de acuerdo al comportamiento de pago en todas sus cuentas
DEFINE dEficienciaCoppel    	DECIMAL(5,2);   --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE dSituacionPagoCoppel     VARCHAR(30);   --calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE cSituacionEspecial       CHAR(1);        --Corresponde a la revisiÃÂÃÂÃÂÃÂ³n de situaciones especiales que pueda tener el cliente en coppel
DEFINE sCausaSituacion          SMALLINT;       --Causa de la situaciÃÂÃÂÃÂÃÂ³n especial
DEFINE sHist_meses              SMALLINT;       -- tiempo de experiencia crediticia en Coppel del cliente pendiente -->Preca
DEFINE cFechaUltimoPago         CHAR(13);       --fecha ultimo pago
DEFINE mAbonoMuebles         	DECIMAL(18,2);    --Abono mensual del cliente en muebles
DEFINE mAbonoPrestamos       	DECIMAL(18,2);    --Abono mensual del cliente en prestamo
DEFINE mAbonoRopa            	DECIMAL(18,2);    --Abono mensual del cliente en ropa
DEFINE mVencidoPrestamos        DECIMAL(18,2);    --vencido mensual del cliente en prestamo personal
DEFINE mAbonoAire    		    DECIMAL(18,2);    --Abono mensual del cliente en tiempo aire
DEFINE mAbonoAfiliados 	        DECIMAL(18,2);    --Abono mensual del cliente en afiliados
DEFINE mAbonoReestructura 	    DECIMAL(18,2);    --Abono mensual del cliente en reestructuras
DEFINE mVencidoMuebles 	        DECIMAL(18,2);    --vencido mensual del cliente en muebles
DEFINE mVencidoRopa 	        DECIMAL(18,2);    --vencido mensual del cliente en ropa
DEFINE mVencidoAire             DECIMAL(18,2);    --vencido mensual del cliente en tiempo aire
DEFINE mVencidoAfiliados        DECIMAL(18,2);    --vencido mensual del cliente en afiliados
DEFINE mVencidoReestructura     DECIMAL(18,2);    --vencido mensual del cliente en reestructura
DEFINE mPagoMinimo              DECIMAL(18,2);    --Corresponde al pago mÃÂÃÂÃÂÃÂ­nimo del cliente
DEFINE mLinea_tienda            DECIMAL(18,2);    --Corresponde a la lÃÂÃÂÃÂÃÂ­nea de crÃÂÃÂÃÂÃÂ©dito del cliente
DEFINE cTipoSolOS		    	CHAR(1);        --Corresponde al tipo de solicitud ( titular/prospecto) de la ultima OS registrada
DEFINE mSaldoRopa				DECIMAL(18,2);
DEFINE mSaldoMuebles			DECIMAL(18,2);
DEFINE mSaldoPrestamos			DECIMAL(18,2);

--DEFINICION DE VARIABLES DE BANCO
DEFINE mCompro_banco            	DECIMAL(18,2);   --Corresponde a los compromisos banco del cliente 
DEFINE dComprobanco_TDC         	DECIMAL(14,2);  --Corresponde a los compromisos de tarjeta de crÃÂÃÂÃÂÃÂ©dito Bancoppel
DEFINE mCompro_bancoPP				DECIMAL(14,2);
DEFINE v_comprobancoprestamo    	DECIMAL(18,2);
DEFINE cNumcreditoCCFF				CHAR(20);
DEFINE iCtas_StatusDif_FF_6011  	INTEGER;        --Corresponde al # de cuentas con estatuus <> FF y producto =6011
DEFINE iCtas_StatusFF_6011      	INTEGER;        --Corresponde al # de cuentas con estatuus = FF y producto =6011
DEFINE iReprestamos             	INTEGER;        --correpsonde al flag represtamos
DEFINE cSolBanco					CHAR(20);
DEFINE sFlag_oro					SMALLINT;       --Corresponde al flag de tarjeta Oro
DEFINE vClvEdoCob       			VARCHAR(10);    --Corresponde a la variable Clave Estado Cobranza 
DEFINE cEstado                      CHAR(30);
DEFINE cMunicipio                   CHAR(30);
DEFINE cResultadoOsTel          	CHAR(1);        --Corresponde al resultado de la Orden de SupervisiÃÂÃÂÃÂÃÂ³n telÃÂÃÂÃÂÃÂ©fonico
DEFINE cTieneOstel              	CHAR(1);        --Corresponde al flag que identifica si la solicitud tiene o no Orden de supervisiÃÂÃÂÃÂÃÂ³n telÃÂÃÂÃÂÃÂ©fonica
DEFINE cEnvioCat                	CHAR(1);        --Corresponde al flag que identifica si  la solicitud se envio al Centro de atenciÃÂÃÂÃÂÃÂ³n telefÃÂÃÂÃÂÃÂ³nica CAT
DEFINE iSolMc				    	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud a mesa de control
DEFINE iSolMcAux		        	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud referencia a mesa de control
DEFINE iSecuenciaOs			    	VARCHAR(50);        --Corresponde a la secuencia de orden de supervisiÃÂÃÂÃÂÃÂ³n  de la ultima OS registrada
DEFINE cStatusRespOs		    	CHAR(1);        --Corresponde al estatus de la respuesta de orden de supervisiÃÂÃÂÃÂÃÂ³n  de la ultima OS registrada
DEFINE dtFecha_Respuesta			CHAR(10);           --Corresponde a la fecha de respuesta de la Orden de SupervisiÃÂÃÂÃÂÃÂ³n  de la ultima OS registrada
DEFINE cMotivoRechBcpl  			CHAR(1); 		--Motivo de rechazo BanCoppel 
DEFINE cDescripcion					CHAR(60);
DEFINE cRiesgoViviendaCpl  			CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE cProducto2                	CHAR (4);
DEFINE v_comprobanco            	DECIMAL(18,2);
DEFINE v_compromi_tdc      			DECIMAL(14,2);
DEFINE dtMaxFechaCorte      		DATE;
DEFINE cGrado_riesgo        		CHAR(2);
DEFINE dMto_reserva         		DECIMAL(18,2);
DEFINE dtFechaAper         			CHAR(10);
DEFINE cStatus_cred					CHAR(2);
DEFINE dSdo_vencido					DECIMAL(18,2);
DEFINE dSdo_vencidocrd      		DECIMAL(18,2);
DEFINE v_capacidad_pago				DECIMAL(18,2);
DEFINE iPlazo                  		INTEGER;

--DEFINICION DE VARIABLES DE BURO
DEFINE dCompromisos                 DECIMAL(14,2); --Corresponde a los compromisos de todas las cuentas del cliente BC
DEFINE dCompromisoscal              DECIMAL(14,2);
DEFINE dMontoUdis                   DECIMAL(14,2); --monto en UDIS de la observaciÃÂÃÂÃÂÃÂ³n mas reciente
DEFINE cInstitucion                 CHAR(2);       --nombre de la instituciÃÂÃÂÃÂÃÂ³n de la observaciÃÂÃÂÃÂÃÂ³n mas reciente
DEFINE cClvObser                    CHAR(2);       --clave de observaciÃÂÃÂÃÂÃÂ³n mas reciente (vStatus) 
DEFINE iNumCtas_ClvOb               VARCHAR(50);       --Numero de cuentas que tienen clave de observaciÃÂÃÂÃÂÃÂ³n FD,PS,SU,CV,PC,SG,SP,SR,UP,FR en BurÃÂÃÂÃÂÃÂ³, no considera comunicaciones y servicios
--DEFINE iMax2_MOP                     VARCHAR(50);       --Maximo MOP actual, no considera Comunicaciones y servicios,cuentas Bancoppel con clave de observaciÃÂÃÂÃÂÃÂ³n RV
--DEFINE cInstCta2_MayorMOP            CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP
--DEFINE dMonto_UDIS2_MayorMOP         DECIMAL(14,2); --Monto UDIS de  cuenta con mayor MOP
DEFINE iMax_MOP                     VARCHAR(50);       --Maximo MOP actual, no considera Comunicaciones y servicios,cuentas Bancoppel con clave de observaciÃÂÃÂÃÂÃÂ³n RV
DEFINE cInstCta_MayorMOP            CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP
DEFINE dMonto_UDIS_MayorMOP         DECIMAL(14,2); --Monto UDIS de  cuenta con mayor MOP
DEFINE iMax_MOP_Hist_6m             VARCHAR(50);       --Maximo_MOP histÃÂÃÂÃÂÃÂ³rico 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_6m         CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP histÃÂÃÂÃÂÃÂ³rico 6 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_6m             DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃÂÃÂÃÂÃÂ³rico 6 meses de cuentas con >=100 UDIS
DEFINE iMM_Histo_12m                VARCHAR(50);       --Maximo_MOP histÃÂÃÂÃÂÃÂ³rico 12 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_12m        CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP histÃÂÃÂÃÂÃÂ³rico 12 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_12m            DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃÂÃÂÃÂÃÂ³rico 12 meses de cuentas con >=100 UDIS
DEFINE iNumCtasMOP_4_12m            INTEGER;       --Numero de cuentas MOP =4 ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_12m            INTEGER;       --Numero de cuentas MOP =5 ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_12m       INTEGER;       --Numero de cuentas MOP >5 ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iMOP4_12mCon1o2   			INTEGER;       --Numero de cuentas MOP =4 ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE iMOP5_12mCon1o2   			INTEGER;       --Numero de cuentas MOP =5 ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE iMOPmayor5_12mCon1o2			INTEGER;       --Numero de cuentas MOP >5 ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE cInstCta_MayorMOP_30m        CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP histÃÂÃÂÃÂÃÂ³rico 30 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_Rech           DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP, de cuenta que provoca el rechazo
DEFINE iNumCtasMOP_4_30m            INTEGER;       --Numero de cuentas MOP =4 ultimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_30m            INTEGER;       --Numero de cuentas MOP =5 ultimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_30m       INTEGER;       --Numero de cuentas MOP >5 ultimos 30 meses, UDIS >=100, sin comunicaciones ni servicios
DEFINE iCtasMOP_4_30mCon1o2         INTEGER;       --Numero de cuentas MOP =4 ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE iCtasMOP_5_30mCon1o2         INTEGER;       --Numero de cuentas MOP =4 ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE iCtasMOP_mayor5_30mCon1o2    INTEGER;       --Numero de cuentas MOP >5 ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE cInstitucionMMOP_provocaRech CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP (ultimos 30 dÃÂÃÂÃÂÃÂ­as),de cuenta que provoca el rechazo
DEFINE dMontoUDIS_30d_Rech          DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (ultimos 30 dÃÂÃÂÃÂÃÂ­as), de cuenta que provoca el rechazo
DEFINE iMM_Histo_30m                VARCHAR(50);       --Maximo_MOP histÃÂÃÂÃÂÃÂ³rico 30 meses de cuentas con >=100 UDIS (Se jerarquizan por fecha_reporte, " para mns de salida")
DEFINE cInstCta_MM_30m_Rech         CHAR(2);       --Nombre de instituciÃÂÃÂÃÂÃÂ³n de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de cuenta que provoca el rechazo
DEFINE dMotoUDIS_MM_30m_Rech        DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de la cuenta que provoca el rechazo
DEFINE iMM_act_Bancos               INTEGER;       --Maximo_MOP actual de bancos
DEFINE iMM_hist_alto_Bancos         VARCHAR(50);       --Maximo_MOP historico mas alto bancos
DEFINE iMM_hist_Bancos              VARCHAR(50);       --Maximo_MOP historico bancos
DEFINE iCtasBancosMOP_tl26          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP actual (tl26) en  MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl38          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP historico mas alto (tl38) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl27          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" , tl06 = R ( revolvente) y con MOP historico (tl27) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_act_hist_alto INTEGER;       --Numero de cuentas de Bancos con MOP actual, historico e historico mas alto ( incluye Bancoppel)
DEFINE iCtasComServMOP_tl26         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mas alto  (tl38) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasCSM_act_hist_alto       INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mas alto en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl26_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mas alto  (tl38) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27)  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasCSM_ActHistAlto_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mas alto  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iMaxMOP_actBancos            VARCHAR(50);       --Maximo_MOP actual de bancos reportadas el ultimo aÃÂÃÂÃÂÃÂ±o
DEFINE iMaxMOP_histAltBancos        VARCHAR(50);       --Maximo_MOP historico mas alto de bancos reportadas el ultimo aÃÂÃÂÃÂÃÂ±o
DEFINE iMaxMOP_histBancos           VARCHAR(50);       --Maximo_MOP historico de bancos reportadas el ultimo aÃÂÃÂÃÂÃÂ±o
DEFINE iMaxMOP_actCtas              VARCHAR(50);       --Maximo_MOP actual de todas las cuentas
DEFINE iMaxMOP_histAltCtas          VARCHAR(50);       --Maximo_MOP histroico mas alto de todas las cuentas
DEFINE iMaxMOP_histCtas             VARCHAR(50);       --Maximo_MOP historico de todas las cuentas
DEFINE iCtas_SinComServ             INTEGER;       --Numero de cuentas sin comunicaciones ni servicios
DEFINE iCtas_SinComServ_pagar       INTEGER;       --Numero de cuentas sin comunicaciones ni servicios con monto a pagar >0
DEFINE iNumCtas_SHBr                INTEGER;       --Numero de cuentas, son de servicios ,hipoteca y bienes raÃÂÃÂÃÂÃÂ­ces
DEFINE iNumCtas_SHBr_pagar          INTEGER;       --Numero de cuentas con monto a pagar >0, servicios (tl02), hipoteca (tl06=M),bienes raÃÂÃÂÃÂÃÂ­ces (tl07=RE)

DEFINE dMaxMtoUdi	 				DECIMAL(14,2);
DEFINE vCuantos      				SMALLINT;
DEFINE vTpCambioUdi  				DECIMAL(14,6);
DEFINE vTpCambioUs   				DECIMAL(14,6);
DEFINE vCodUdi       				CHAR(2);
DEFINE vCodUs       				CHAR(2);
DEFINE vClase        				CHAR(1);
DEFINE v_mod_parame           		CHAR(1);	--MACM										
DEFINE vInstitucion  				CHAR(2);
DEFINE vMontoUdis    				DECIMAL(14,2);
DEFINE vTl27						CHAR(24);
DEFINE var_i        				smallint;
DEFINE var_j	    				smallint;
DEFINE vmeses_pos   				smallint;
define vmeses6      				varchar(6);
define vmeses12     				varchar(12);
define vmeses30     				varchar(30);
DEFINE bandera6  					INTEGER;
DEFINE bandera12 					INTEGER;
DEFINE bandera30 					INTEGER;
define vmeses_ctas   				smallint;
DEFINE pSIC							CHAR(1);
DEFINE MOPHistoricoAltoTl38 		INTEGER; 
DEFINE MaxComServMOP_tl38 			INTEGER;
DEFINE cInstitucionCtas 			CHAR(2);
DEFINE cMOPmeses 					CHAR(2);
DEFINE vTipoHitCalu					INTEGER;
DEFINE scoreCalu					INTEGER;

--DEFINICION DE VARIABLES DE SOLICITUD
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE dtDiaFF  				CHAR(2);
DEFINE dtMesFF  				CHAR(2);
DEFINE dtAnoFF  				CHAR(4);
DEFINE cCteProsp		        CHAR(20);       --numero de cliente prospecto
DEFINE cStatusSol_CteProsp      CHAR(2);        --Corresponde al estatus de la solicitud del cliente prospecto 
DEFINE cTipo_Alta_CteProsp      CHAR(1);        --Tipo de Alta Cte Prospecto
DEFINE cCteProspVig			    CHAR(20);       --Corresponde a la vigencia del cliente  prospecto
DEFINE cSucursal   			    CHAR(4);        --Numero de Sucursal
DEFINE iFlagEmpleado            VARCHAR(50);       --Corresponde al flag de empleado Coppel y/o Bancoppel
DEFINE sEntidad_Localidad		VARCHAR(50);       --Corresponde a la variable entidad/localidad 
DEFINE iCanal_Sol         	    VARCHAR(50);        --Corresponde al canal por el cual se originÃÂÃÂÃÂÃÂ³ la solicitud
DEFINE iCanalV1				    VARCHAR(50);        --Canal de solicitud ingresada por prospectÃÂÃÂÃÂÃÂ©o
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE cPiloto 					CHAR(1);
DEFINE cCausa_Sol			    CHAR(3);        --causa del rechazo de la solicitud
DEFINE cTipoGrupo 			    CHAR(2);        --grupo de evaluaciÃÂÃÂÃÂÃÂ³n al cual pertenece la solicitud
DEFINE cProducto                CHAR(4);        --producto de porcentaje mas bajo y si existe empate se toma el mas reciente
DEFINE sFlagForzarEnvioMC       VARCHAR(50);       --Etatus de la ultima solicitud que no terminÃÂÃÂÃÂÃÂ³ en (AN,PC) y que su producto si se envÃÂÃÂÃÂÃÂ­a a mesa de control (6300,6400,7600,7700,9100,9300,6001,6800)
DEFINE cNumSol_Os			    CHAR(20);       --Corresponde al numero de solicitud de la Orden de supervisiÃÂÃÂÃÂÃÂ³n  de la ultima OS registrada
DEFINE dValor_3s                DECIMAL(14,2);  --Corresponde al valor del score  de Circulo de crÃÂÃÂÃÂÃÂ©dito 
DEFINE cFolioMovil         	    CHAR(20);       --Folio solicitud movil
DEFINE cStatusMovil             CHAR(1);        --Estatus solicitud movil
DEFINE sBc_Score                SMALLINT;  		--valor del score ( Indica la calificaciÃÂÃÂÃÂÃÂ³n del score solicitado "numero positivo")
DEFINE cInstitucionClvExclusionMasReciente CHAR(2); -- Corresponde a la INSTITUCION de exclusion mas reciente
DEFINE vClvExclusionMasReciente INTEGER;	-- Corresponde a la CALVE de exclusion mas reciente
DEFINE cTicket				   	CHAR(20); 
DEFINE cEdo_proceso			   	CHAR(4); 
DEFINE cNum_men				   	CHAR(3); 
DEFINE cEmpresa				   	CHAR(4); 
DEFINE cNumSolRef            	CHAR(20);

DEFINE v_respsic             	CHAR(1);	--MACM


DEFINE IQ0002               VARCHAR(50);       --Numero de consultas al cliente por instituciÃÂÃÂÃÂÃÂ³n
DEFINE BC_101               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE UT0034               INTEGER;       --Utilization percent of bank revolving trades (Porcentaje de utilizaciÃÂÃÂÃÂÃÂ³n en cuentas revolventes bancarias).
DEFINE ut0034_aux 			INTEGER;
DEFINE ut0034_aux2			INTEGER;
DEFINE vSum_higcred   		DECIMAL(18,2);
DEFINE vSum_bal             DECIMAL(18,2);
DEFINE dtFechaHoyAUX        DATE;
DEFINE maxmoptot			INTEGER;
DEFINE pmaxmop				INTEGER;
DEFINE pmaxmop1 		    INTEGER;

DEFINE pmeses		  		INTEGER;
DEFINE Bandera			   	INTEGER;
DEFINE i            		INTEGER;
DEFINE ki           		INTEGER;
DEFINE kiz          		INTEGER;

--DEFINICION DE VARIABLES DE EVALUACION
DEFINE cRTipo3           CHAR(1);       --Corresponde a la clave de envÃÂÃÂÃÂÃÂ­o a OS ( A,R,D.....)
DEFINE cVigSolOS         CHAR(1);       --Corresponde si la solicitud esta vigente o vencida para envÃÂÃÂÃÂÃÂ­o a OS (vVigente)
DEFINE sBuenPagos        CHAR(30);      --Corresponde al buen pago 
DEFINE sFlagBuenPago12   VARCHAR(50);      --Corresponde al flag de buen pago 12meses
DEFINE sFlagBuenPago30   VARCHAR(50);      --Corresponde al flag de buen pago 30meses
DEFINE cNuevoStatusOstel CHAR(2);       --Corresponde al estatus despuÃÂÃÂÃÂÃÂ©s de la OS tel*** Oscar solicita tabla **rev
DEFINE iExisteCliente    INTEGER;       --Conteo de solicitudes del cliente para producto Coppel con estatus diferente de 'PC','AN','MC'
DEFINE cTipo_movimiento  CHAR(1);       --Correspode al tipo de movimiento ( U,M) unico, mixto 
DEFINE dCompromisosCac   DECIMAL(14,2); --Compromisos registrados en las tabla ss_solicitudes_cac ( aparentemenete son los compromisos validados por Mesa de Control, ya no se usa)
DEFINE dtFechaAux        CHAR(10);          --Fecha de la ultima consulta realizada que no sea de Bancoppel
DEFINE dTasa             DECIMAL(9,6);  --
DEFINE dtasaMora		 DECIMAL(9,6);
DEFINE cOrigenSol        CHAR(1);       --Corresponde al origen ( contiene T,B,vacio)*
DEFINE cOrigenCte        CHAR(1);       --Corresponde al origen del cliente ( prospecto, titular...)
DEFINE mImporte_hip      DECIMAL(18,2);         --Corresponde al monto de la hipoteca del cliente
DEFINE iMeses_hist_Val   INTEGER;      	--Numero de de meses de historia validos del cliente de acuerdo a su edad
DEFINE sCteLargo8        SMALLINT;      --Determina si es grupo 8
DEFINE sCteLargo         VARCHAR(50);      --Corresponde a clientes con cuenta de captaciÃÂÃÂÃÂÃÂ³n en su primer producto ( solo dÃÂÃÂÃÂÃÂ©bito)
DEFINE vgrupoA 			 SMALLINT;		--Conteo por empresa y cliente de la tabla sd_grupo_cliente
DEFINE NumSolMovil		 CHAR(20);		--Numero de solicitud movil de la tabla ss_solicitudes_movil
DEFINE iFlag2credito 	 SMALLINT;		--Variable flag sale del procedure sp_valida2Credito

DEFINE cCodRet2Cred 	 CHAR(6);
DEFINE iValorICC	     VARCHAR(50);
DEFINE v_moneda     	 CHAR(2); 
DEFINE v_monto 			 DECIMAL(18,2);

DEFINE v_total      	 DECIMAL(18,2);
DEFINE v_imp_hip   		 DECIMAL(18,2);
DEFINE v_factor    		 DECIMAL(14,6);
DEFINE v_tot_tp          DECIMAL(14,2);

DEFINE CadenaTl27 		VARCHAR(30);
DEFINE CantTl27 		INTEGER;

DEFINE v_SituacionPagoCoppel  DECIMAL(5,2);	--MACM

------------------------
--DEFINE cuenta 					INTEGER;
DEFINE NumCuentaPagoMinimo 		INT8;
DEFINE contenedor 				INTEGER;
DEFINE comparador 				INTEGER;
DEFINE dSalariomin				DECIMAL(18,2);
DEFINE dTasa_Ordinaria 			DECIMAL(18,2);
DEFINE dTasa_Moratoria 			DECIMAL(18,2);
DEFINE diva 					DECIMAL(18,2);
DEFINE dDiaspromedio 			DECIMAL(18,2);
DEFINE dTope_ingre 				DECIMAL(18,2);
DEFINE dcVeces_smb 				DECIMAL(18,2);
DEFINE dPorcpermitido 			DECIMAL(18,2);
DEFINE dMesespermitido 			DECIMAL(18,2);
DEFINE dMinimomesespermitido 	DECIMAL(18,2);
DEFINE vlatitud 				VARCHAR(10);
DEFINE vlongitud 				VARCHAR(11);
------------------------
--Cambios Olivia
DEFINE cBRM_reing SMALLINT;

------------------------
--Cambios 120523
DEFINE cnumcte_stdiq_consultassic			CHAR(20);
DEFINE cnumcte_stdiq_MesesFechaConsulIq		CHAR(20);
DEFINE cnum_clientetl_arrendamiento			CHAR(20);
DEFINE cnumcte_stdiq_consultasfinanciera	CHAR(20);

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cCodRet         CHAR(6);
DEFINE cMensaje_ret    VARCHAR(100);
DEFINE cRFC			   CHAR(13);

--VARIABLES AGREGADAS PARA PRESTAMOS PERSONALES //NO SE RETORNAN, HAY QUE CONSULTARLO
DEFINE iNewMPP 		   			VARCHAR(100);
DEFINE vEficUltSem     			INTEGER;
DEFINE vMorAct         			INTEGER;
DEFINE vPorcUso        			INTEGER;
DEFINE velemPuntualidad    		CHAR(1);
DEFINE Validaos		   			CHAR(1);
DEFINE vCuentasPF 	   			VARCHAR(50);
DEFINE BCScorePP 	   			INTEGER;
DEFINE ScorePropietario 	    INTEGER;
DEFINE IQ00012					INTEGER;
DEFINE vSumSaldoActualTL22      DECIMAL(18,2);
DEFINE vSumLimCredTL23          DECIMAL(18,2);
DEFINE iParamIncrDecr			VARCHAR(50);
DEFINE ptipogrupo 				CHAR(2);
DEFINE phit 					CHAR(6);
DEFINE iExisteSolPP				INTEGER;
DEFINE vNumTotalCtas            SMALLINT;
DEFINE vCtas_al_corriente		INTEGER;
DEFINE vCtas_sin_historia		INTEGER;
DEFINE vMesesAperCtaAntigua     SMALLINT;
DEFINE dTl13					DATE;
DEFINE d2Tl13					DATE;
DEFINE vMesesAperCtaAntiguaRev  SMALLINT;
DEFINE vNumVecesBANCOPPEL       INTEGER;
DEFINE vNumVecesTiendaComercial INTEGER;
DEFINE vNumTotalCtasTL13		INTEGER;
DEFINE v_valor_1s               DECIMAL(14,2);
DEFINE vAntiguedad              CHAR(1);
DEFINE inumppf					INTEGER;
DEFINE mTasa_Interes			INTEGER;
DEFINE capacidad_pres			INTEGER;
DEFINE iDiaPago      			VARCHAR(50);
DEFINE vSaldoMorHistAltaTL36    DECIMAL(18,2);
DEFINE vFechaTL37               char(10);
DEFINE vCtas_30_mas_atraso_hist	INTEGER;
DEFINE iNumCtasAper36			INTEGER;
DEFINE TL37						CHAR(10);
DEFINE iExisteBR_TL_mora		CHAR(10);
DEFINE iSumaTL13 				DECIMAL(18,2);
DEFINE vMesesTL13 				DECIMAL(18,2);
DEFINE iFlag2credito2			VARCHAR(50);
DEFINE pFrecuencia				VARCHAR(50);
DEFINE vMaxPlazoDias            INTEGER;
DEFINE vPlazoCred               INTEGER;
DEFINE vFalloSic				VARCHAR(50);
DEFINE dtFechaHoy		    	CHAR(10);
DEFINE dfecha36m                DATE;


--VARIABLES EXTRAS
DEFINE origeninput1 			VARCHAR(30);
DEFINE origeninput2 			VARCHAR(30);
DEFINE origeninput3 			VARCHAR(30);
DEFINE origeninput4 			VARCHAR(30);
DEFINE origeninput5 			DECIMAL(14,2);
DEFINE origeninput6 			DECIMAL(14,2);
DEFINE origeninput7 			DECIMAL(14,2);
DEFINE origeninput8 			DECIMAL(14,2);

DEFINE vMensaje				VARCHAR(255);	--MACM
DEFINE GEN1 	MONEY(14,2);	--MACM
DEFINE GEN2 	MONEY(14,2);	--MACM
DEFINE GEN3 	INTEGER    ;	--MACM
DEFINE iCertif 	INTEGER;
DEFINE v_valor_2s INTEGER;

------------------ DECLARACION DE VARIABLES NUEVAS (BRM - 2025) ----------------- 

DEFINE dIngreso_ajustado 				DECIMAL(10,2);
DEFINE iMora_coppel						INTEGER;
DEFINE iSaldo_vencido_coppel 			INTEGER;
DEFINE iMora_bancoppel 					INTEGER;
DEFINE iSaldo_vencido_bancoppel 		INTEGER;
DEFINE vTipo_transaccion 				VARCHAR(50);
DEFINE iAntiguedad 						INTEGER;
DEFINE iHawk 							INTEGER;
DEFINE iFraudes 						INTEGER;
DEFINE iFlag_creditopp_activo 			INTEGER;
DEFINE iEstabilidadvivienda				INTEGER;
DEFINE iRechazoos 						INTEGER;
DEFINE iCn_sic 							INTEGER;
DEFINE iLista_negra 					INTEGER;
DEFINE iNo_tramitedia_tdc 				INTEGER;
DEFINE iNo_tramitedia_pp 				INTEGER;
DEFINE dSics_montopagar_revolvente 		CHAR(1000);
DEFINE dSics_montopagar_norevolvente 	CHAR(1000);
DEFINE dSics_saldoactual_revolvente 	CHAR(1000);
DEFINE dSics_saldoactual_norevolvente 	CHAR(1000);
DEFINE dGc_saldoactual_coppel 			DECIMAL(18,2);
DEFINE dGc_saldoactual_bancoppel 		DECIMAL(18,2);
DEFINE dGc_montopagar_coppel 			DECIMAL(18,2);
DEFINE Gc_montopagar_bancoppel 			DECIMAL(18,2);
DEFINE vTipo_colectivo 					VARCHAR(50);
DEFINE dReestructuras 					DECIMAL(8,2);
DEFINE dIdentificacion_falsa 			INTEGER;
DEFINE dQuebranto 						DECIMAL(8,2);
DEFINE dPromedio_ingresom_ult4d 		DECIMAL(8,2);
DEFINE dContinuidad_depositos_nomina 	VARCHAR(24);
DEFINE vTipo_empleado_code 				VARCHAR(50);
DEFINE vTipo_empleado_name 				VARCHAR(50);
DEFINE vObservacion_mc 					VARCHAR(50);
DEFINE vOrigeninput9 					VARCHAR(50);
DEFINE vOrigeninput10 					VARCHAR(50);
DEFINE vOrigeninput11 					VARCHAR(50);
DEFINE vOrigeninput12 					VARCHAR(50);
DEFINE Origeninput13 					INTEGER;
DEFINE Origeninput14 					INTEGER;
DEFINE Origeninput15 					INTEGER;
DEFINE Origeninput16 					INTEGER;

---------------------------- VARIABLES INTERNAS DEL BRM 2025 ----------------------------------------------
DEFINE dtFech_Solic			 DATE;
DEFINE dFechaIni 			 DATE;
DEFINE dFechaFin 			 DATE;
DEFINE dFechaAltaCtaNom 	 DATE;
DEFINE dtFechaSolicitudAux 	 DATE;
DEFINE dtFechaAuxContinuidad DATE;
DEFINE dSdoActCap 			 DECIMAL(18,2);
DEFINE dSdoActCap_crd 		 DECIMAL(18,2);
DEFINE dVenc_traspRev 		 DECIMAL(18,2);
DEFINE dMont_finRev 		 DECIMAL(18,2);
DEFINE dMax_traspRev 		 DECIMAL(18,2);
DEFINE dSum_MontFinRev 		 DECIMAL(18,2);
DEFINE dSum_dSdoActCap		 DECIMAL(18,2);
DEFINE dSum_dSdoActCap_crd	 DECIMAL(18,2);
DEFINE dVenc_traspPP 		 DECIMAL(18,2);
DEFINE dMont_finPP 			 DECIMAL(18,2);
DEFINE dMax_traspPP 		 DECIMAL(18,2);
DEFINE dSum_MontFinPP 		 DECIMAL(18,2);
DEFINE iIng_Ajust            INTEGER;
DEFINE iAuxCont 			 INTEGER;
DEFINE iCuentaCte 			 CHAR(20);
DEFINE dMontoTotAux 		 DECIMAL(8,2);
DEFINE iMontoTotAux			 INTEGER;
DEFINE iConteo 				 INTEGER;
DEFINE iTransac 			 VARCHAR(15);
DEFINE vDescrip 			 VARCHAR(15);
DEFINE iSumpp 				 INTEGER;
DEFINE iSumtdc				 INTEGER;
DEFINE iCont				 INTEGER;
DEFINE iSald_TotCoppel		 DECIMAL(18,2);
DEFINE iMont_PagCoppel		 DECIMAL(18,2);
DEFINE iDiaConsul_Act 		 INTEGER;
DEFINE iDiaConsul_Ant 		 INTEGER;
DEFINE ivencidoBanRev 		 DECIMAL(18,2);
DEFINE ivencidoBanPP 		 DECIMAL(18,2);
DEFINE iDiaConsul 			 INTEGER;
DEFINE ivencidoBancop 		 DECIMAL(18,2);
DEFINE iTipoListaNegra  	 VARCHAR(1);
DEFINE vObserv_Sol			 VARCHAR(20);
DEFINE cTL12				 VARCHAR(10);
DEFINE cTL22				 VARCHAR(10);
DEFINE cResult				 VARCHAR(50);
DEFINE cMensListaNegra  	 VARCHAR(100);
DEFINE vNum_Cred 			 VARCHAR(20);

-- DECLARACION DE VARIABLES DE SPS EN LLAMADO INTERNO DEL BRM 2025
DEFINE pRfc 		   CHAR(13);
DEFINE pNombre1 	   CHAR(26);
DEFINE pNombre2 	   CHAR(26);
DEFINE pApellPaterno   CHAR(26);
DEFINE pApellMaterno   CHAR(26);
DEFINE pFechaNac 	   CHAR(8);
DEFINE cList_neg	   CHAR(1);
DEFINE fechanacFor	   CHAR(8);

--VARIABLES AUXILIARES
DEFINE iNumCteAux                INTEGER;
DEFINE iNumCuentaAux             INTEGER;

-- ASIGNACION DE VARIABLES DE SPS EN LLAMADO INTERNO DEL BRM 2025
LET pRfc 		    = '';
LET pNombre1 	    = '';
LET pNombre2 	    = '';
LET pApellPaterno   = '';
LET pApellMaterno   = '';
LET pFechaNac 	    = '';
LET cList_neg		= '';
LET fechanacFor		= '';


-- ASIGNACION DE VARIABLES DEL BRM E INTERNAS --
LET dIngreso_ajustado 				= 0.0;
LET iMora_coppel					= 0;
LET iSaldo_vencido_coppel 			= 0;
LET iMora_bancoppel 				= 0;
LET iSaldo_vencido_bancoppel 		= 0;
LET vTipo_transaccion 				= '';
LET iAntiguedad 					= 0;
LET iHawk 							= 0;
LET iFraudes 						= 0;
LET iFlag_creditopp_activo 			= 0;
LET iEstabilidadvivienda			= 0;
LET iRechazoos 						= 0;
LET iCn_sic 						= 0;
LET iLista_negra 					= 0;
LET iNo_tramitedia_tdc 				= 0;
LET iNo_tramitedia_pp 				= 0;
LET dSics_montopagar_revolvente 	= '';
LET dSics_montopagar_norevolvente 	= '';
LET dSics_saldoactual_revolvente 	= '';
LET dSics_saldoactual_norevolvente 	= '';
LET dGc_saldoactual_coppel 			= 0.0;
LET dGc_saldoactual_bancoppel 		= 0.0;
LET dGc_montopagar_coppel 			= 0.0;
LET Gc_montopagar_bancoppel 		= 0.0;
LET vTipo_colectivo 				= '';
LET dReestructuras 					= 0.0;
LET dIdentificacion_falsa 			= 0;
LET dQuebranto 						= 0.0;
LET dPromedio_ingresom_ult4d 		= 0.0;
LET dVenc_traspRev 					= 0.0;
LET dMont_finRev 					= 0.0;
LET dMax_traspRev 					= 0.0;
LET dSum_MontFinRev 				= 0.0;
LET dSum_dSdoActCap					= 0.0;
LET dSum_dSdoActCap_crd				= 0.0;
LET dVenc_traspPP 					= 0.0;
LET dMont_finPP 					= 0.0;
LET dMax_traspPP 					= 0.0;
LET dSum_MontFinPP 					= 0.0;
LET dContinuidad_depositos_nomina 	= '';
LET vTipo_empleado_code 			= '';
LET vTipo_empleado_name 			= '';
LET vObservacion_mc 				= '';
LET vOrigeninput9 					= '';
LET vOrigeninput10 					= '';
LET vOrigeninput11 					= '';
LET vOrigeninput12 					= '';
LET vNum_Cred 						= '';
LET Origeninput13 					= 0;
LET Origeninput14 					= 0;
LET Origeninput15 					= 0;
LET Origeninput16 					= 0;
LET iDiaConsul 						= 0;
LET ivencidoBancop 					= 0;

------------- ASIGNACION DE VARIABLES INTERNAS DEL BRM 2025 ------------- 

LET iIng_Ajust            = 0.0;
LET iAuxCont 			  = 0;
LET iCuentaCte 			  = '0';
LET dMontoTotAux 		  = 0;
LET iMontoTotAux		  = 0;
LET iConteo 			  = 0;
LET iTransac 			  = '';
LET vDescrip			  = '';
LET iSumpp 				  = 0;
LET iSumtdc				  = 0;
LET iCont				  = 0;
LET iSald_TotCoppel		  = 0.0;
LET iMont_PagCoppel		  = 0.0;
LET iDiaConsul_Act 		  = 0;
LET iDiaConsul_Ant 		  = 0;
LET ivencidoBanRev 		  = 0;
LET ivencidoBanPP 		  = 0;
LET dSdoActCap 			  = 0.0;
LET dSdoActCap_crd		  = 0.0;
LET iTipoListaNegra  	  = '';
LET vObserv_Sol			  = '';
LET cTL12				  = '';
LET cTL22				  = '';
LET cResult				  = '';
LET cMensListaNegra  	  = '';
LET dtFech_Solic		  = DATE(1);
LET dFechaIni 			  = DATE(1);
LET dFechaFin 			  = DATE(1);
LET dFechaAltaCtaNom 	  = DATE(1);
LET dtFechaSolicitudAux   = DATE(1);
LET dtFechaAuxContinuidad = DATE(1);

--------------------------- DECLARACION DE VARIABLES NUEVAS PRESTAMOS PERSONALES---------------------------
--VARIABLES EXTRAS
LET origeninput1 = 		'';
LET origeninput2 = 		'';
LET origeninput3 = 		'';
LET origeninput4 = 		'';
LET origeninput5 = 		0;
LET origeninput6 = 		0;
LET origeninput7 = 		0;
LET origeninput8 = 		0;

LET vMensaje = '';	--MACM

LET dfecha36m = 		DATE(1);
LET iNewMPP 			="1";
LET vEficUltSem         = 0;
LET vMorAct             = 0;
LET vPorcUso            = 0;
LET velemPuntualidad    = '';
LET Validaos   		= '';
LET vCuentasPF 			="0";
LET BCScorePP 			=0;
LET ScorePropietario 			=0;
LET IQ00012		 				= 0;
LET vSumSaldoActualTL22         = 0;
LET vSumLimCredTL23             = 0;
LET iParamIncrDecr 				= "";
LET ptipogrupo = ''; 
LET phit = '';
LET iExisteSolPP	= 0;
LET vNumTotalCtas                   = 0;
LET vCtas_al_corriente				 = 0;
LET vCtas_sin_historia				 = 0;
LET vMesesAperCtaAntigua            = 0;
LET vMesesAperCtaAntiguaRev 		= 0;
LET vNumVecesBANCOPPEL              = 0;
LET vNumVecesTiendaComercial        = 0;
LET vNumTotalCtasTL13				 = 0;
LET v_valor_1s   = 0;
LET vAntiguedad  = "0";
LET inumppf			= 0;
LET mTasa_Interes = 0;
LET capacidad_pres = 0;
LET iDiaPago        =""; 
LET vSaldoMorHistAltaTL36           = 0.00;
LET vFechaTL37 = "";
LET vCtas_30_mas_atraso_hist		 = 0;
LET iNumCtasAper36  	   			= 0;
LET TL37 = '';
LET iExisteBR_TL_mora = '0';
LET iSumaTL13 						 = 0;
LET vMesesTL13						= 0;
LET iFlag2credito2					="";
LET iValorICC						="";
LET pFrecuencia						="";
LET vMaxPlazoDias                   = 0;
LET vPlazoCred                  	= 0;
LET vFalloSic						="0";

--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
LET cNumCte               ="";
LET cNumCteComp			  = "";     
LET cNumCteBco		      ="";  
LET cNumCteBcoN		      ="";    
LET cCurp  				  ="";
LET cB_INE                =0;     
LET cValidaINE			  = "";                     
LET dtFechaCte			  = '1900-01-01';
LET dtFechaHoy        	  = '1900-01-01';
LET dtFechaNac 			  = '1900-01-01';
LET cSexo                 ="";       
LET cEdo_Civil            ="";       
LET iTiem_Edo_Civil       = 0;       
LET iTiem_Edo_Civil_meses = 0;      
LET cEscolaridad          ="";
LET cHabita_en            ="??";      
LET cTipoResidencia       = "";      
LET cEntidad              ="";
LET vLocalidad         	  = '';
LET iTiem_Residencia   	  = 0;      
LET cGeoCte		  		  ='';      
LET cFlagGeoMov			  ='';       
LET iFlagGeoSuc		      ="0";    
LET cTelCasa              ="";      
LET cTelTrabajo           ="";     
let cNumCel 			  = '';
LET Ictegrandata		  = 0;
LET fechaaut_grandata	  ='1900-01-01';
LET fechacons_grandata	  ='1900-01-01';
LET iBanderaReferencia	  ="0";                                    
LET sValida_Cel	          = "0";    
LET COcupacion            = "";      
LET iTiem_Ocupacion       = 0;      
LET cProfesion            ="";
LET sId_actividad		  = 0;      
LET cDescAct              ="";                                        
LET sId_subactividad	  = 0;      
LET vDescSubAct           = "";                                         
LET mIngreso_Mensual	  = 0;         
LET mIngreso_Neto         = 0;         
LET cCompIngresos		  ="";       
LET dIngresoCac           = 0; 
LET sCompValido      	  = 0;       
LET sFlagHuella           ="0";      
LET cCod_Ult_Identif      ="";       
LET iReferencia			  = 0;
LET iReferencia1		  = 0;	
LET iReferencia2		  = 0;
LET vHuella				  = 0;
--LET cuenta 				  = 0;
LET sEdadCte			  = 0;
LET cNombreCte 			  ='';
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;
LET vlatitud  			  ="";
LET vlongitud 		      ="";
LET v_meses               =0;
LET v_cuantos             =0;							 

--INICIALIZACION DE VARIABLES DE CUENTA COPPEL
LET dtUltimaCompra       		 	= '1900-01-01';          
LET cPuntualidadCoppel   		  	='';        
LET dEficienciaCoppel			  	= 0;       
LET dSituacionPagoCoppel		  	= "0"; 
LET cSituacionEspecial   		  	="?";
LET sCausaSituacion      		  	= 0;       
LET sHist_meses               	  	= 0;      
LET cFechaUltimoPago     		  	="";
LET mAbonoMuebles    	 			= 0;        
LET mAbonoPrestamos    				= 0;
LET mAbonoRopa        				= 0;
LET mAbonoAire           			= 0;
LET mAbonoAfiliados     			= 0;
LET mAbonoReestructura   			= 0;
LET mVencidoMuebles 	 			= 0;
LET mVencidoRopa 	     			= 0; 
LET mVencidoPrestamos    			= 0; 
LET mVencidoAire         			= 0; 
LET mVencidoAfiliados    			= 0;
LET mVencidoReestructura 			= 0;  
LET mPagoMinimo          			= 0;
LET mLinea_tienda        			= 0;    
LET cTipoSolOS		     			="";      
LET mSaldoRopa			 			= 0;
LET mSaldoMuebles		 			= 0;
LET mSaldoPrestamos		 			= 0;

--INICIALIZACION DE VARIABLES DE BANCO
LET mCompro_banco           = 0;    
LET mCompro_bancoPP			= 0;
LET dComprobanco_TDC        = 0;  
LET v_comprobancoprestamo   = 0;

LET cProducto2				= "";
LET iCtas_StatusDif_FF_6011 = 0;
LET iCtas_StatusFF_6011     = 0;       
LET iReprestamos           	= 0;
LET cSolBanco				= pNumSol;
LET sFlag_oro		        = 0;       
LET vClvEdoCob              ="";    
LET cEstado 				='';
LET cMunicipio 				='';
LET cResultadoOsTel         ="";         
LET cTieneOstel             ="";        
LET cEnvioCat               ="";        
LET iSolMc			        = 0;        
LET iSolMcAux		        = 0;        
LET iSecuenciaOs	        ="0";       
LET cStatusRespOs	        ="";        
LET dtFecha_Respuesta       = '1900-01-01';       
LET cMotivoRechBcpl 		= "0";
LET cDescripcion			="";
LET cRiesgoViviendaCpl  	=""; 
LET cRiesgoViviendaBcpl 	="";
LET cActRiesgoCpl       	="";
LET cActRiesgoBCpl			="";
LET cDescpRiesgo			= "";
LET cNumcreditoCCFF			= "";
LET v_comprobanco       	= 0;
LET v_compromi_tdc 			= 0;
LET dtMaxFechaCorte			= DATE(1);
LET cStatus_cred			= "";
LET cGrado_riesgo			= "";
LET dMto_reserva			= "";
LET dtFechaAper        		= DATE(1);
LET dSdo_vencido			= 0;
LET dSdo_vencidocrd			= 0;
LET v_capacidad_pago   		= 0;
LET iPlazo              	= 0;


--INICIALIZACION DE VARIABLES DE BURO
LET dCompromisos              = 0; 
LET dCompromisoscal           = 0;
LET dMontoUdis                = 0; 
LET cInstitucion              ="";
LET cClvObser				  ="";
LET iNumCtas_ClvOb            ="0";     
LET iMax_MOP                  ="0";     
LET cInstCta_MayorMOP         ="";       
LET dMonto_UDIS_MayorMOP      = 0; 
LET iMax_MOP_Hist_6m          = "0";     
LET cInstCta_MayorMOP_6m      ="";       
LET dMontoUDIS_MM_6m          = 0; 
LET iMM_Histo_12m             ="0";    
LET cInstCta_MayorMOP_12m     ="";      
LET dMontoUDIS_MM_12m         = 0; 
LET iNumCtasMOP_4_12m         = 0;       
LET iNumCtasMOP_5_12m         = 0;       
LET iNumCtasMOP_mayor5_12m    = 0;       
LET iMOP4_12mCon1o2           = 0;                                  
LET iMOP5_12mCon1o2           = 0;       
LET iMOPmayor5_12mCon1o2      = 0;
LET cInstCta_MayorMOP_30m     ="";       
LET dMontoUDIS_MM_Rech        = 0; 
LET iNumCtasMOP_4_30m         = 0;       
LET iNumCtasMOP_5_30m         = 0;       
LET iNumCtasMOP_mayor5_30m    = 0;
LET iCtasMOP_4_30mCon1o2      = 0;
LET iCtasMOP_5_30mCon1o2      = 0;
LET iCtasMOP_mayor5_30mCon1o2 = 0;    
LET cInstitucionMMOP_provocaRech ="";       
LET dMontoUDIS_30d_Rech          = 0; 
LET iMM_Histo_30m                ="0";       
LET cInstCta_MM_30m_Rech         =""; 
LET dMotoUDIS_MM_30m_Rech        = 0; 
LET iMM_act_Bancos               = 0;        
LET iMM_hist_alto_Bancos         = '0';    
LET iMM_hist_Bancos              ="0";      
LET iCtasBancosMOP_tl26          = 0;       
LET iCtasBancosMOP_tl38          = 0;       
LET iCtasBancosMOP_tl27          = 0;       
LET iCtasBancosMOP_act_hist_alto = 0;      
LET iCtasComServMOP_tl26         = 0;       
LET iCtasComServMOP_tl38         = 0;       
LET iCtasComServMOP_tl27         = 0;       
LET iCtasCSM_act_hist_alto       = 0;        
LET iCtasComServMOP_tl26_12m     = 0;       
LET iCtasComServMOP_tl38_12m     = 0;       
LET iCtasComServMOP_tl27_12m     = 0;        
LET iCtasCSM_ActHistAlto_12m     = 0;       
LET iMaxMOP_actBancos            = "0";    
LET iMaxMOP_histAltBancos        = "0";    
LET iMaxMOP_histBancos           = "0";    
LET iMaxMOP_actCtas              = "0";    
LET iMaxMOP_histAltCtas          = "0";       
LET iMaxMOP_histCtas             = "0";     
LET iCtas_SinComServ             = 0;       
LET iCtas_SinComServ_pagar       = 0;      
LET iNumCtas_SHBr                = 0;       
LET iNumCtas_SHBr_pagar          = 0;       
LET dMaxMtoUdi				     = 0;
LET vCodUdi      				 = "";
LET vCodUs      				 = "";
LET vTpCambioUdi 				 = 0;
LET vTpCambioUs  				 = 0;
LET vCuantos  				 	 = 0;
LET vClase       				 = "";
LET v_mod_parame				 = "";						  
LET vInstitucion 				 = '';
LET vMontoUdis 			  		 = 0;
LET var_i      			  		 = 0;  
LET vmeses_pos 			  		 = 0;
LET vmeses_ctas 		  		 = 0;
LET cInstitucionCtas 	  		 = '';
LET cMOPmeses			  		 = '';
LET vTipoHitCalu				 = 0;
LET scoreCalu					 = 0;
LET pSIC                  		 = "";
LET  MOPHistoricoAltoTl38 		 = 0; 
LET  MaxComServMOP_tl38   		 = 0; 

--INICIALIZACION DE VARIABLES DE SOLICITUD
LET dtFechaSolicitud       = '1900-01-01';
LET dtDiaFF  			   = '01';
LET dtMesFF  			   = '01';
LET dtAnoFF		 	       = '1900';
LET cCteProsp		       ="";
LET cStatusSol_CteProsp    ="";
LET cTipo_Alta_CteProsp	   ="";
LET cCteProspVig		   ="";
LET cSucursal   	       ="";
LET iFlagEmpleado          ="0"; 
LET sEntidad_Localidad     ="0";
LET iCanal_Sol             ="0";
LET iCanalV1		       ="0";
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET cPiloto 			   ="";
LET cCausa_Sol		       ="";
LET cTipoGrupo 		       ="";
LET cProducto              ='????';   
LET sFlagForzarEnvioMC     ="";
LET cNumSol_Os		       ="";
LET dValor_3s              = 0;
LET cFolioMovil            ="";
LET cStatusMovil           ='';
LET sBc_Score              = 0;  
LET cInstitucionClvExclusionMasReciente = "";
LET vClvExclusionMasReciente = 0;
LET cTicket				   =""; 
LET cEdo_proceso	   	   =""; 
LET cNum_men		       =""; 
LET cEmpresa		       =""; 
LET cNumSolRef             = '';

--INICIALIZACION DE VARIABLES DE PARAMETRICOS

LET IQ0002             ="0.00";
LET BC_101             = 0;
LET UT0034             = 0;
LET ut0034_aux         = 0;
LET ut0034_aux2        = 0;
LET vSum_bal           = 0;
LET vSum_higcred       = 0;
LET dtFechaHoyAUX      = DATE(1);   
LET maxmoptot     	   = 0;
LET pmaxmop			   = 0;
LET pmaxmop1 		   = 0;

LET pmeses		       = 0;
LET Bandera			   = 0;
LET ki                 = 0;
LET kiz                = 0;

--INICIALIZACION DE VARIABLES DE EVALUACION
LET cRTipo3           ="";
LET cVigSolOS		  ="";
LET sBuenPagos        ="0";
LET sFlagBuenPago12	  ="0";
LET sFlagBuenPago30	  ="0";
LET cNuevoStatusOstel ="";
LET iExisteCliente    = 0;
LET cTipo_movimiento  ="";
LET dCompromisosCac   = 0;
LET dtFechaAux		  = '1900-01-01';
LET dTasa			  = 0;
LET dtasaMora = 0;
LET cOrigenSol        ='1';
LET cOrigenCte		  ="";
LET mImporte_hip      = 0;
LET iMeses_hist_Val   = 0;
LET sCteLargo8		  = 0;
LET sCteLargo         ="0";
LET vgrupoA 		  = 0;
LET NumSolMovil		  = '';
LET iFlag2credito 	  = 0;
LET NumCuentaPagoMinimo = 0;
LET v_moneda    	  = '';
LET v_monto 		  =0;
LET v_total       	  = 0;
LET v_imp_hip    	  = 0;
LET v_factor    	  = 0;
LET v_tot_tp     	  = 0;
LET NumCuentaPagoMinimo 						= 0;

LET CadenaTl27 	= '';
LET CantTl27 	= 0;
--LET cuenta 		= 0;
LET v_SituacionPagoCoppel = 0;							

--parametros tdc visa Olivia
LET dSalariomin 			= 0;
LET dTasa_Ordinaria 		= 0; --
LET dTasa_Moratoria 		= 0; 
LET diva 					= 0;
LET dDiaspromedio 			= 0;
LET dTope_ingre 			= 0;
LET dcVeces_smb 			= 0;
LET dPorcpermitido 			= 0;
LET dMesespermitido 		= 0;
LET dMinimomesespermitido 	= 0;
LET cBRM_reing = 1;
LET GEN1 = 0;  --MACM
LET GEN2 = 0;  --MACM
LET GEN3 = 0;  --MACM
LET iCertif = 0;	--MACM

------------------------
--Cambios 120523
LET cnumcte_stdiq_consultassic			= '';
LET cnumcte_stdiq_MesesFechaConsulIq	= '';
LET cnum_clientetl_arrendamiento		= '';
LET cnumcte_stdiq_consultasfinanciera	= '';

--DECLARACION DE VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="000000";
LET cMensaje_ret        = '';
LET cRFC = '';
LET v_respsic    = "";
LET v_valor_2s = 0;

-- Variables nuevas PDN
LET iEstabilidadvivienda = 0;
LET ifraudes = 0;

--Variables auxiliares
LET iNumCteAux                  = 0;
LET iNumCuentaAux               = 0;


BEGIN

	ON  EXCEPTION IN (-535)
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH resume;
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
      ROLLBACK WORK;
			LET cCodRet = iSqlErr;
			
			IF dSics_montopagar_revolvente = '' AND dSics_montopagar_norevolvente = '' AND dSics_saldoactual_revolvente = '' AND dSics_saldoactual_norevolvente = '' THEN
    
				LET dSics_montopagar_revolvente = '[0]';
				LET dSics_montopagar_norevolvente = '[0]';
				LET dSics_saldoactual_revolvente = '[0]';
				LET dSics_saldoactual_norevolvente = '[0]';

			END IF;
			
			RETURN  NVL(cCodRet,000000), NVL(cSolBanco,''),	NVL(cNumCteBco,''),	NVL(cNumCte,''), NVL(pEmpresa,''), 
			NVL(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cPuntualidadCoppel,''), NVL(cProfesion,''),
			NVL(sId_actividad,0), NVL(cDescAct,''), NVL(sId_subactividad,0), NVL(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), NVL(cMotivoRechBcpl,''), NVL(sHist_meses,0), NVL(dEficienciaCoppel,0), NVL(iCtas_StatusDif_FF_6011,0),
			NVL(cProducto,"????"), NVL(mAbonoMuebles,0), NVL(mAbonoPrestamos,0), NVL(mAbonoRopa,0),  NVL(mAbonoAire,0), NVL(mAbonoAfiliados,0),
			NVL(mAbonoReestructura,0), NVL(mVencidoMuebles,0), NVL(mVencidoRopa,0), NVL(mVencidoPrestamos,0), NVL(mVencidoAire,0), 
			NVL(mVencidoAfiliados,0), NVL(mVencidoReestructura,0), NVL(cFechaUltimoPago,'1900-01-01'), NVL(iReprestamos,0),
			NVL(cOrigenSol,'1'), NVL(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			NVL(cActRiesgoBCpl,''),	NVL(cDescpRiesgo,''), NVL(iMax_MOP,"0"), NVL(cInstCta_MayorMOP,''), 
			NVL(dMonto_UDIS_MayorMOP,0), NVL(iMax_MOP_Hist_6m,"0"), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,"0"), NVL(cInstCta_MayorMOP_12m,''),  NVL(dMontoUDIS_MM_12m,0), NVL(iNumCtasMOP_4_12m,0),
			NVL(iNumCtasMOP_5_12m,0), NVL(iNumCtasMOP_mayor5_12m,0), NVL(iMOP4_12mCon1o2,0), NVL(iMOP5_12mCon1o2,0),
			NVL(iMOPmayor5_12mCon1o2,0), NVL(cInstitucionMMOP_provocaRech,''), NVL(dMontoUDIS_MM_Rech,0), NVL(iNumCtasMOP_4_30m,0),
			NVL(iNumCtasMOP_5_30m,0), NVL(iNumCtasMOP_mayor5_30m,0), NVL(iCtasMOP_4_30mCon1o2,0), NVL(iCtasMOP_5_30mCon1o2,0),
			NVL(iCtasMOP_mayor5_30mCon1o2,0), NVL(iMM_Histo_30m,"0"), NVL(cInstCta_MM_30m_Rech,''), NVL(dMotoUDIS_MM_30m_Rech,0), 
			NVL(iNumCtas_ClvOb,"0"), NVL(dMontoUdis,0), NVL(cInstitucion,''), NVL(cClvObser,'0'), NVL(sBc_Score,0), 
			NVL(vClvExclusionMasReciente,0), NVL(cInstitucionClvExclusionMasReciente,''), NVL(iCtas_SinComServ,0),
			NVL(iCtas_SinComServ_pagar,0), NVL(iNumCtas_SHBr,0), NVL(iNumCtas_SHBr_pagar,0),  NVL(BC_101,0), 
			NVL(iMM_act_Bancos,0), NVL(iMM_hist_alto_Bancos,'0'), NVL(iMM_hist_Bancos,"0"), NVL(iCtasBancosMOP_tl26,0),
			NVL(iCtasBancosMOP_tl38,0), NVL(iCtasBancosMOP_tl27,0), NVL(iCtasBancosMOP_act_hist_alto,0), 
			NVL(iCtasComServMOP_tl26,0), NVL(iCtasComServMOP_tl38,0), NVL(iCtasComServMOP_tl27,0), NVL(iCtasCSM_act_hist_alto,0),
			NVL(iCtasComServMOP_tl26_12m,0), NVL(iCtasComServMOP_tl38_12m,0), NVL(iCtasComServMOP_tl27_12m,0), 
			NVL(iCtasCSM_ActHistAlto_12m,0), NVL(dtFechaAux,'1900-01-01'), NVL(iMaxMOP_actBancos,"0"), 
			NVL(iMaxMOP_histAltBancos,"0"), NVL(iMaxMOP_histBancos,"0"),  NVL(iMaxMOP_actCtas,"0"), NVL(iMaxMOP_histAltCtas,"0"),
			NVL(iMaxMOP_histCtas,"0"), NVL(dSituacionPagoCoppel,"0"), NVL(mIngreso_Mensual,0), NVL(mPagoMinimo,0), NVL(sCteLargo8,0),
			NVL(iMeses_hist_Val,0), NVL(cTipo_Alta_CteProsp,''), NVL(mLinea_tienda,0), NVL(mImporte_hip,0), NVL(dTasa,0),
			NVL(sFlagHuella,"0"), NVL(cResultadoOsTel,''), NVL(cTieneOstel,''), NVL(cEnvioCat,''), NVL(iSolMc,0),
			NVL(iSolMcAux,0), NVL(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,"0"), 
			NVL(dtUltimaCompra,'1900-01-01'), NVL(iBanderareferencia,"0"), NVL(dtFechaCte,'1900-01-01'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), NVL(iFlagGeoSuc,"0"), NVL(iCanal_Sol,"0"), NVL(cOrigenCte,''), NVL(sFlagForzarEnvioMC,""), 
			NVL(iSecuenciaOs,"0"), NVL(cStatusRespOs,''), NVL(dtFecha_Respuesta, '1900-01-01'), NVL(cNumSol_Os,''), NVL(cCompIngresos,''),
			NVL(dIngresoCac,0), NVL(sCompValido, 0), NVL(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), NVL(mIngreso_Neto,0), NVL(dtFechaNac,'1900-01-01'), NVL(cSexo,''),
			NVL(cEdo_Civil,''), NVL(iTiem_Edo_Civil,-99), NVL(UT0034,-999), NVL(cOcupacion,''),	NVL(iTiem_Ocupacion, -99), 
			NVL(cEscolaridad,''), NVL(cTipoResidencia,''), NVL(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,"0"), NVL(cCURP,''), NVL(iFlagEmpleado,"0"), NVL(dValor_3s,0),
			NVL(cStatusMovil,''), NVL(cCteProsp,''), NVL(cStatusSol_CteProsp,''), NVL(cRTipo3,''), NVL(cVigSolOS,''), NVL(sBuenPagos,'0'),
			NVL(dCompromisos,0), NVL(sFlagBuenPago12,"0"), NVL(sFlagBuenPago30,"0"), NVL(sEntidad_Localidad,"0"), NVL(cNuevoStatusOstel,''), 
			NVL(cCteProspVig,''), NVL(mCompro_banco,0), NVL(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), NVL(cGeoCte,''), NVL(iCanalV1,"99"), 
			NVL(IQ0002,"0.00"), NVL(iCtas_StatusFF_6011,0), NVL(iTiem_Edo_Civil_meses, -99), NVL(iExisteCliente,0), NVL(mSaldoRopa,0), NVL(mSaldoMuebles,0), 
			NVL(mSaldoPrestamos,0), NVL(vgrupoA,''), NVL(NumSolMovil,''), NVL(iFlag2credito,0), NVL(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '1900-01-01'), 
			NVL(sEdadCte,0), NVL(pMeses_historia_grupo,0), NVL(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0), NVL(Validaos,'0'), NVL(iNewMPP,""),
			NVL(vCuentasPF,"0"), NVL(BCScorePP,0), NVL(ScorePropietario,0), NVL(vEficUltSem,0), NVL(vMorAct,0), NVL(vPorcUso,0), NVL(velemPuntualidad,''),
			NVL(IQ00012,0), NVL(vSumSaldoActualTL22,0), NVL(vSumLimCredTL23,0), NVL(iParamincrDecr,""), NVL(iExisteSolPP,0), NVL(vNumTotalCtas,0), NVL(vCtas_al_corriente,0),
			NVL(vCtas_sin_historia,0), NVL(vMesesAperCtaAntigua,0), NVL(vMesesAperCtaAntiguaRev,0), NVL(vNumVecesBANCOPPEL,0), NVL(vNumVecesTiendaComercial,0),
			NVL(vNumTotalCtasTL13,0), NVL(v_valor_1s,0), NVL(inumppf,0), NVL(mTasa_Interes,0), NVL(capacidad_pres,0), NVL(vSaldoMorHistAltaTL36,0), NVL(vCtas_30_mas_atraso_hist,0),
			NVL(iNumCtasAper36,0), NVL(TL37,'1900-01-01'), NVL(iExisteBR_TL_mora,'0'), NVL(vFechaTL37,'1900-01-01'), NVL(iSumaTL13,0), NVL(iFlag2credito2,""), NVL(iValorICC,""), NVL(vInstitucion,''),
			NVL(pFrecuencia,""), NVL(iDiaPago,""), NVL(vMaxPlazoDias,0), NVL(vFalloSic,"0"), NVL(dtFechaHoy,'1900-01-01'), NVL(vSum_bal,0), NVL(vSum_higcred,0),
			NVL(origeninput1,''), NVL(origeninput2,''), NVL(origeninput3,''), NVL(origeninput4,''), NVL(origeninput5,0), NVL(origeninput6,0), NVL(origeninput7,0), NVL(origeninput8,0),
			NVL(Ictegrandata,0), NVL(fechaaut_grandata,'1900-01-01'), NVL(fechacons_grandata,'1900-01-01'),
			-- EMPIEZAN VARIABLES DE RETORNO DE BRM 2025 --
			NVL(dIngreso_ajustado, 0.0), NVL(iMora_coppel, 0), NVL(iSaldo_vencido_coppel, 0), NVL(iMora_bancoppel, 0), NVL(iSaldo_vencido_bancoppel, 0), NVL(vTipo_transaccion, ''), NVL(iAntiguedad, 0),
			NVL(iHawk, 0), NVL(iFraudes, 0), NVL(iFlag_creditopp_activo, 0), NVL(iEstabilidadvivienda, 0), NVL(iRechazoos, 0), NVL(iCn_sic, 0), NVL(iLista_negra, 0), NVL(iNo_tramitedia_tdc, 0),
			NVL(iNo_tramitedia_pp, 0), NVL(dSics_montopagar_revolvente, '[0]'), NVL(dSics_montopagar_norevolvente, '[0]'), NVL(dSics_saldoactual_revolvente, '[0]'), NVL(dSics_saldoactual_norevolvente, '[0]'),
			NVL(dGc_saldoactual_coppel, 0.0), NVL(dGc_saldoactual_bancoppel, 0.0), NVL(dGc_montopagar_coppel, 0.0), NVL(Gc_montopagar_bancoppel, 0.0), NVL(vTipo_colectivo, ''),
			NVL(dReestructuras, 0.0), NVL(dIdentificacion_falsa, 0.0), NVL(dQuebranto, 0.0), NVL(dPromedio_ingresom_ult4d, 0.0), NVL(dContinuidad_depositos_nomina, 0.0), NVL(vTipo_empleado_code, ''),
			NVL(vTipo_empleado_name, ''), NVL(vObservacion_mc, ''), NVL(vOrigeninput9, ''), NVL(vOrigeninput10, ''), NVL(vOrigeninput11, ''), NVL(vOrigeninput12, ''), NVL(Origeninput13, 0),
			NVL(Origeninput14, 0), NVL(Origeninput15, 0), NVL(Origeninput16, 0);
		END IF;
	END EXCEPTION;
END

	--SET debug file to '/informix/MarcoCardenas/MotorNomina/SP/sp_consultadatos_motor_pp'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	-----------------------------
	SELECT fecha_hoy
		INTO dtFechaHoyAUX
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;
    
    	SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;

---------------------------------------------------- VARIABLES DATOS DEL CLIENTE
		IF NVL(pEmpresa,'') = '' OR NVL(pNumSol,'') = '' THEN
			LET cCodRet = '020202';

        ELSE
    		SELECT numcte, num_producto
    		INTO cNumCteBco, cNum_Producto  
    		FROM bdisolic:"informix".ss_solicitudes 
    		WHERE num_solicitud = pNumSol;

            SELECT  numcte_ref --Fecha de alta cliente 1ra vez
    		INTO  cNumCteComp
    		FROM bdinteg:"informix".si_cliente
    		WHERE numcte= cNumCteBco;

            IF 	NVL(cNumCteBco,'') = '' THEN
    			LET cCodRet = '030303';
				
				IF dSics_montopagar_revolvente = '' AND dSics_montopagar_norevolvente = '' AND dSics_saldoactual_revolvente = '' AND dSics_saldoactual_norevolvente = '' THEN
    
					LET dSics_montopagar_revolvente = '[0]';
					LET dSics_montopagar_norevolvente = '[0]';
					LET dSics_saldoactual_revolvente = '[0]';
					LET dSics_saldoactual_norevolvente = '[0]';

				END IF;
				
				RETURN NVL(cCodRet,000000), NVL(cSolBanco,''),	NVL(cNumCteBco,''),	NVL(cNumCte,''), NVL(pEmpresa,''), 
				NVL(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
				NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cPuntualidadCoppel,''), NVL(cProfesion,''),
				NVL(sId_actividad,0), NVL(cDescAct,''), NVL(sId_subactividad,0), NVL(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
				NVL(sCausaSituacion,-99), NVL(cMotivoRechBcpl,''), NVL(sHist_meses,0), NVL(dEficienciaCoppel,0), NVL(iCtas_StatusDif_FF_6011,0),
				NVL(cProducto,"????"), NVL(mAbonoMuebles,0), NVL(mAbonoPrestamos,0), NVL(mAbonoRopa,0),  NVL(mAbonoAire,0), NVL(mAbonoAfiliados,0),
				NVL(mAbonoReestructura,0), NVL(mVencidoMuebles,0), NVL(mVencidoRopa,0), NVL(mVencidoPrestamos,0), NVL(mVencidoAire,0), 
				NVL(mVencidoAfiliados,0), NVL(mVencidoReestructura,0), NVL(cFechaUltimoPago,'1900-01-01'), NVL(iReprestamos,0),
				NVL(cOrigenSol,'1'), NVL(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
				NVL(cActRiesgoBCpl,''),	NVL(cDescpRiesgo,''), NVL(iMax_MOP,"0"), NVL(cInstCta_MayorMOP,''), 
				NVL(dMonto_UDIS_MayorMOP,0), NVL(iMax_MOP_Hist_6m,"0"), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
				NVL(iMM_Histo_12m,"0"), NVL(cInstCta_MayorMOP_12m,''),  NVL(dMontoUDIS_MM_12m,0), NVL(iNumCtasMOP_4_12m,0),
				NVL(iNumCtasMOP_5_12m,0), NVL(iNumCtasMOP_mayor5_12m,0), NVL(iMOP4_12mCon1o2,0), NVL(iMOP5_12mCon1o2,0),
				NVL(iMOPmayor5_12mCon1o2,0), NVL(cInstitucionMMOP_provocaRech,''), NVL(dMontoUDIS_MM_Rech,0), NVL(iNumCtasMOP_4_30m,0),
				NVL(iNumCtasMOP_5_30m,0), NVL(iNumCtasMOP_mayor5_30m,0), NVL(iCtasMOP_4_30mCon1o2,0), NVL(iCtasMOP_5_30mCon1o2,0),
				NVL(iCtasMOP_mayor5_30mCon1o2,0), NVL(iMM_Histo_30m,"0"), NVL(cInstCta_MM_30m_Rech,''), NVL(dMotoUDIS_MM_30m_Rech,0), 
				NVL(iNumCtas_ClvOb,"0"), NVL(dMontoUdis,0), NVL(cInstitucion,''), NVL(cClvObser,'0'), NVL(sBc_Score,0), 
				NVL(vClvExclusionMasReciente,0), NVL(cInstitucionClvExclusionMasReciente,''), NVL(iCtas_SinComServ,0),
				NVL(iCtas_SinComServ_pagar,0), NVL(iNumCtas_SHBr,0), NVL(iNumCtas_SHBr_pagar,0),  NVL(BC_101,0), 
				NVL(iMM_act_Bancos,0), NVL(iMM_hist_alto_Bancos,'0'), NVL(iMM_hist_Bancos,"0"), NVL(iCtasBancosMOP_tl26,0),
				NVL(iCtasBancosMOP_tl38,0), NVL(iCtasBancosMOP_tl27,0), NVL(iCtasBancosMOP_act_hist_alto,0), 
				NVL(iCtasComServMOP_tl26,0), NVL(iCtasComServMOP_tl38,0), NVL(iCtasComServMOP_tl27,0), NVL(iCtasCSM_act_hist_alto,0),
				NVL(iCtasComServMOP_tl26_12m,0), NVL(iCtasComServMOP_tl38_12m,0), NVL(iCtasComServMOP_tl27_12m,0), 
				NVL(iCtasCSM_ActHistAlto_12m,0), NVL(dtFechaAux,'1900-01-01'), NVL(iMaxMOP_actBancos,"0"), 
				NVL(iMaxMOP_histAltBancos,"0"), NVL(iMaxMOP_histBancos,"0"),  NVL(iMaxMOP_actCtas,"0"), NVL(iMaxMOP_histAltCtas,"0"),
				NVL(iMaxMOP_histCtas,"0"), NVL(dSituacionPagoCoppel,""), NVL(mIngreso_Mensual,0), NVL(mPagoMinimo,0), NVL(sCteLargo8,0),
				NVL(iMeses_hist_Val,0), NVL(cTipo_Alta_CteProsp,''), NVL(mLinea_tienda,0), NVL(mImporte_hip,0), NVL(dTasa,0),
				NVL(sFlagHuella,"0"), NVL(cResultadoOsTel,''), NVL(cTieneOstel,''), NVL(cEnvioCat,''), NVL(iSolMc,0),
				NVL(iSolMcAux,0), NVL(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,"0"), 
				NVL(dtUltimaCompra,'1900-01-01'), NVL(iBanderareferencia,"0"), NVL(dtFechaCte,'1900-01-01'), NVL(cFolioMovil,""),
				NVL(cFlagGeoMov,""), NVL(iFlagGeoSuc,"0"), NVL(iCanal_Sol,"0"), NVL(cOrigenCte,''), NVL(sFlagForzarEnvioMC,""), 
				NVL(iSecuenciaOs,"0"), NVL(cStatusRespOs,''), NVL(dtFecha_Respuesta, '1900-01-01'), NVL(cNumSol_Os,''), NVL(cCompIngresos,''),
				NVL(dIngresoCac,0), NVL(sCompValido, 0), NVL(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
				NVL(dCompromisosCac,0), NVL(sFlag_oro,0), NVL(mIngreso_Neto,0), NVL(dtFechaNac,'1900-01-01'), NVL(cSexo,''),
				NVL(cEdo_Civil,''), NVL(iTiem_Edo_Civil,-99), NVL(UT0034,-999), NVL(cOcupacion,''),	NVL(iTiem_Ocupacion, -99), 
				NVL(cEscolaridad,''), NVL(cTipoResidencia,''), NVL(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
				NVL(cEntidad,''), NVL(sCteLargo,"0"), NVL(cCURP,''), NVL(iFlagEmpleado,"0"), NVL(dValor_3s,0),
				NVL(cStatusMovil,''), NVL(cCteProsp,''), NVL(cStatusSol_CteProsp,''), NVL(cRTipo3,''), NVL(cVigSolOS,''), NVL(sBuenPagos,'0'),
				NVL(dCompromisos,0), NVL(sFlagBuenPago12,"0"), NVL(sFlagBuenPago30,"0"), NVL(sEntidad_Localidad,"0"), NVL(cNuevoStatusOstel,''), 
				NVL(cCteProspVig,''), NVL(mCompro_banco,0), NVL(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), NVL(cGeoCte,''), NVL(iCanalV1,"99"), 
				NVL(IQ0002,"0.00"), NVL(iCtas_StatusFF_6011,0), 
				NVL(iTiem_Edo_Civil_meses, -99), 	NVL(iExisteCliente,0), NVL(mSaldoRopa,0), NVL(mSaldoMuebles,0), 
				NVL(mSaldoPrestamos,0), NVL(vgrupoA,''), NVL(NumSolMovil,''), NVL(iFlag2credito,0), NVL(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '1900-01-01'), 
				NVL(sEdadCte,0), NVL(pMeses_historia_grupo,0), NVL(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
				NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
				NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0), NVL(Validaos,'0'), NVL(iNewMPP,""),
				NVL(vCuentasPF,"0"), NVL(BCScorePP,0), NVL(ScorePropietario,0), NVL(vEficUltSem,0), NVL(vMorAct,0), NVL(vPorcUso,0), NVL(velemPuntualidad,''),
				NVL(IQ00012,0), NVL(vSumSaldoActualTL22,0), NVL(vSumLimCredTL23,0), NVL(iParamincrDecr,""), NVL(iExisteSolPP,0), NVL(vNumTotalCtas,0), NVL(vCtas_al_corriente,0),
				NVL(vCtas_sin_historia,0), NVL(vMesesAperCtaAntigua,0), NVL(vMesesAperCtaAntiguaRev,0), NVL(vNumVecesBANCOPPEL,0), NVL(vNumVecesTiendaComercial,0),
				NVL(vNumTotalCtasTL13,0), NVL(v_valor_1s,0), NVL(inumppf,0), NVL(mTasa_Interes,0), NVL(capacidad_pres,0), NVL(vSaldoMorHistAltaTL36,0), NVL(vCtas_30_mas_atraso_hist,0),
				NVL(iNumCtasAper36,0), NVL(TL37,'1900-01-01'), NVL(iExisteBR_TL_mora,'0'), NVL(vFechaTL37,'1900-01-01'), NVL(iSumaTL13,0), NVL(iFlag2credito2,""), NVL(iValorICC,""), NVL(vInstitucion,''),
				NVL(pFrecuencia,""), NVL(iDiaPago,""), NVL(vMaxPlazoDias,0), NVL(vFalloSic,"0"), NVL(dtFechaHoy,'1900-01-01'), NVL(vSum_bal,0), NVL(vSum_higcred,0),
				NVL(origeninput1,''), NVL(origeninput2,''), NVL(origeninput3,''), NVL(origeninput4,''), NVL(origeninput5,0), NVL(origeninput6,0), NVL(origeninput7,0), NVL(origeninput8,0),
				NVL(Ictegrandata,0), NVL(fechaaut_grandata,'1900-01-01'),NVL(fechacons_grandata,'1900-01-01'),
				-- EMPIEZAN VARIABLES DE RETORNO DE BRM 2025 --
				NVL(dIngreso_ajustado, 0.0), NVL(iMora_coppel, 0), NVL(iSaldo_vencido_coppel, 0), NVL(iMora_bancoppel, 0), NVL(iSaldo_vencido_bancoppel, 0), NVL(vTipo_transaccion, ''),
				NVL(iAntiguedad, 0), NVL(iHawk, 0), NVL(iFraudes, 0), NVL(iFlag_creditopp_activo, 0), NVL(iEstabilidadvivienda, 0), NVL(iRechazoos, 0), NVL(iCn_sic, 0), NVL(iLista_negra, 0), NVL(iNo_tramitedia_tdc, 0),
				NVL(iNo_tramitedia_pp, 0), NVL(dSics_montopagar_revolvente, '[0]'), NVL(dSics_montopagar_norevolvente, '[0]'), NVL(dSics_saldoactual_revolvente, '[0]'), NVL(dSics_saldoactual_norevolvente, '[0]'),
				NVL(dGc_saldoactual_coppel, 0.0), NVL(dGc_saldoactual_bancoppel, 0.0), NVL(dGc_montopagar_coppel, 0.0), NVL(Gc_montopagar_bancoppel, 0.0), NVL(vTipo_colectivo, ''),
				NVL(dReestructuras, 0.0), NVL(dIdentificacion_falsa, 0.0), NVL(dQuebranto, 0.0), NVL(dPromedio_ingresom_ult4d, 0.0), NVL(dContinuidad_depositos_nomina, 0.0), NVL(vTipo_empleado_code, ''),
				NVL(vTipo_empleado_name, ''), NVL(vObservacion_mc, ''), NVL(vOrigeninput9, ''), NVL(vOrigeninput10, ''), NVL(vOrigeninput11, ''), NVL(vOrigeninput12, ''), NVL(Origeninput13, 0),
				NVL(Origeninput14, 0), NVL(Origeninput15, 0), NVL(Origeninput16, 0);
    		END IF;
			
			
			SELECT count(*) INTO iCertif FROM bdisolic:ss_certif_evaluacion_cte_pp WHERE cSolBanco_ss = pNumSol;
			IF iCertif > 0 THEN
				DELETE FROM bdisolic:ss_certif_evaluacion_cte_pp WHERE cSolBanco_ss = pNumSol;  
				DELETE FROM bdisolic:ss_certif_evaluacion_cte_pp_2 WHERE pnumsol_ss = pNumSol;  																					
				LET iCertif = 0;
			END IF;
			
			SELECT count(*) INTO iCertif FROM bdisolic:ss_certif_evaluacion_buro_pp WHERE cSolBanco_ss = pNumSol;
			IF iCertif > 0 THEN
				DELETE FROM bdisolic:ss_certif_evaluacion_buro_pp WHERE cSolBanco_ss = pNumSol;  
				LET iCertif = 0;
			END IF;
		
			
			
			LET cValidaINE = '';
			FOREACH
				SELECT limit 1 TRIM(NVL(resultado,''))
				INTO cValidaINE
				FROM bdinteg:"informix".si_bitacora_ife 
				WHERE numcte = cNumCteBco 
				ORDER BY fecha DESC
			END FOREACH

			LET cValidaINE = UPPER(cValidaINE);

			IF cValidaINE = 'TRUE' OR cValidaINE = 'VERDADERO' THEN
				LET cB_INE = 1;
			ELSE
				LET cB_INE = 0;
			END IF;
			
			-- Prender bandera en 1 si la identificacion es falsa
			IF cValidaINE = 'TRUE' OR cValidaINE = 'VERDADERO' THEN
				LET dIdentificacion_falsa = 0;
			ELSE
				LET dIdentificacion_falsa = 1;
			END IF;

		

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET b_ine = cB_INE --alter
				WHERE num_solicitud = pNumSol;
				--MACM SE CONSIDERO EN OBTENER EL NUMERO DE PARAMETRICO
				SELECT TRIM(sol.tipo_calculo), mov.status
				INTO v_mod_parame,cStatusMovil
				FROM bdisolic:"informix".ss_solicitudes sol
				LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov 
						on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
				WHERE sol.empresa = pEmpresa
				AND sol.num_solicitud = pNumSol;  

						
				-- *******************************************************************
				-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
				-- *******************************************************************
				-- Se obtiene el grupo
    			call bdisolic:"informix".sp_obtienegrupo (pNumSol)RETURNING cCodRet,ptipogrupo,phit;	
    			UPDATE bdisolic:"informix".ss_resum_scor_fin
    			SET grupo = ptipogrupo
    			WHERE empresa = pEmpresa AND num_solicitud = pNumSol;	
				--- fin de grupo														  

				select count(*) into iParamIncrDecr from bdisolic:ss_resumen_scoring where num_solicitud = pNumSol and ptipogrupo in (select grupo from bdisolic:ss_param_porc_lincred)
	        	and phit in (select respuesta_sic from bdisolic:ss_param_porc_lincred);

				EXECUTE PROCEDURE bdicred:"informix".sp_valida2Credito (pempresa, cNumCteBco, pnumsol, 1)
				INTO  cCodRet2Cred,iFlag2credito2,iValorICC;

				SELECT institucion, fallosIC
 				INTO vInstitucion, vFalloSIC
				FROM bdisolic:"informix".ss_solicitudes_sic
				WHERE ROWID = (SELECT MAX(rowid)
				FROM bdisolic:"informix".ss_solicitudes_sic
				WHERE numcte= cNumCteBco
				AND num_solicitud = pNumSol);

				SELECT situacion_pago, meses_historia
				INTO v_SituacionPagoCoppel, v_meses
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE empresa =  pEmpresa
				AND num_solicitud = pNumSol;

				SELECT valor
				INTO v_cuantos
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 300;

				IF v_SituacionPagoCoppel IS NULL THEN
       				LET v_SituacionPagoCoppel= 0;
   				END IF;

				 -- clientes coppel sin compras, se le da tratamiento de cliente nuevo
			    IF ( v_SituacionPagoCoppel < 0  ) and cTp_solicitud NOT IN ('C') THEN
			       LET v_meses = 0;	
				   LET v_SituacionPagoCoppel = 0;
			    END IF;

			    IF (v_meses <= v_cuantos) and cTp_solicitud NOT IN ('C') THEN
			        LET vAntiguedad = "1";					
			    END IF;

			    -- se les asigno vAntiguedad = "0";
			    -- a los clientes con 1 mes de antiguedad
			    -- lalo 28jun07
			    IF (v_meses = 1) and cTp_solicitud NOT IN ('C') THEN
			        LET vAntiguedad = "0";					
			    END IF;

			    IF v_mod_parame = 1 THEN

					SELECT a.puntuacion
	            	INTO v_valor_1s
	            	FROM bdisolic:"informix".ss_scoring_financ a, bdisolic:"informix".ss_resum_scor_fin b
	            	WHERE a.empresa = pempresa
	            	AND a.tp_solicitud = cTp_solicitud
	            	AND a.secuencia > 0
	            	AND b.empresa= a.empresa
	            	AND b.num_solicitud= pNumSol
	            	AND a.circulo_credito = DECODE (b.evalua_cc,"X","X","0","0","2","1","3","1","4","1","1")
	            	AND DECODE(b.situacion_pago,-1,0,b.meses_historia) >= a.min_mes_hist
	            	AND DECODE(b.situacion_pago,-1,0,b.meses_historia) <= a.max_mes_hist
	            	AND DECODE(b.situacion_pago,-1,0,b.situacion_pago) >= a.min_porc_pago
	            	AND DECODE(b.situacion_pago,-1,0,b.situacion_pago) <= a.max_porc_pago
	            	AND a.tp_cliente = vAntiguedad;

					IF v_valor_1s IS NULL THEN
	            		LET v_valor_1s = 0;
	        		END IF;

				END IF;	

            SELECT NVL(e.rango_minimo, 0) --Tiempo Estado Civil
				INTO iTiem_Edo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 4
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;

				------------------------		
			SELECT NVL(e.rango_minimo,-99) --Tiempo Estado Civil Meses
				INTO iTiem_Edo_Civil_meses
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 41
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;

			IF iTiem_Edo_Civil_meses = 12 AND (iTiem_Edo_Civil = 0 OR iTiem_Edo_Civil IS NULL OR iTiem_Edo_Civil = 16) THEN
				IF iTiem_Edo_Civil IS NULL THEN -- Si es nulo tiempo estado civil, registrar elemento ya que no tiene asignado ese grupo.
					INSERT INTO bdisolic:ss_detalle_scoring VALUES('001', 2, 4, 17, '01', pNumSol, 0);
				END IF;

				SELECT NVL(e.rango_minimo, 0) --Tiempo Estado Civil
				INTO iTiem_Edo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 4
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;
				--LET iTiem_Edo_Civil = 17;
			END IF;

			FOREACH 
					SELECT  LIMIT 1 catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, NVL(trim(ciu.nombre),'')
					INTO vClvEdoCob, vLocalidad --Localidad y Estado de cobranza
					FROM bdinteg:"informix".si_direcciones_actual dir
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
					LEFT OUTER JOIN bdinteg:"informix".si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
					WHERE dir.numcte = cNumCteBco 
					AND dir.tipo_dir='1'
					order by dir.fecha_insert desc
			END FOREACH;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET ClvEdoCob = vClvEdoCob,
					localidad = vLocalidad --alter
				WHERE num_solicitud = pNumSol;

			SELECT grupo
				INTO sEntidad_Localidad
				FROM bdisolic:"informix".ss_cat_edo_localidad_param
				WHERE clave_estado = vClvEdoCob
				AND localidad = vLocalidad;
			
			IF NVL(sEntidad_Localidad, "") = "" THEN
				LET sEntidad_Localidad = 6;
			END IF;

			FOREACH
				SELECT LIMIT 1 NVL(z.municipiozona, '')
				INTO  cMunicipio
				FROM bdinteg:"informix".si_cliente a
					LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte)
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
					LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
					LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
				WHERE a.NumCte = cNumCteBco
				AND NVL(d.tipo_dir,'') = '1'
				order by d.fecha_insert desc
			END FOREACH;
						
			EXECUTE PROCEDURE bdinteg:sp_eliminaacentos(cMunicipio)
			into cMunicipio;
			
			SELECT valor::DECIMAL(14,2)
				INTO dDiaspromedio -- Salario Minimo Base
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 355;
			
			SELECT valor::DECIMAL(14,2)
				INTO dcVeces_smb 
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 364;

			let cFolioMovil = ''; 
			SELECT folio_movil
				INTO cFolioMovil
				FROM bdisolic:"informix".ss_solicitudes_movil
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND status <> '3';
				
			SELECT num_solicitud
				INTO NumSolMovil
				FROM bdisolic:"informix".ss_solicitudes_movil
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND numcte = cNumCteBco;
				 
			SELECT domicilio_alta, TRIM(geolocalizacion), substr(geolocalizacion,1,10), substr(geolocalizacion,12,21)
				INTO cFlagGeoMov,cGeoCte, vlatitud, vlongitud 
				FROM bdinteg:"informix".si_solicitud_movil
				WHERE folio = cFolioMovil; --Se tiene el domicilio_alta solo si es movil

			SELECT {+INDEX(bdinteg:"informix":si_ptf idx_si_pft_lat_lon)} count (id_ptf)
				INTO iFlagGeoSuc
				FROM bdinteg:"informix".si_ptf 
				WHERE latitud = vlatitud 
				AND longitud  = vlongitud;

			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END 
				INTO cTelCasa 
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 1;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET telefono_domicilio = cTelCasa 
				WHERE num_solicitud = pNumSol;

			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END
				INTO cTelTrabajo
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 3;	

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET telefono_trabajo = cTelTrabajo 
				WHERE num_solicitud = pNumSol;

			SELECT  count(numcte) --Cantidad de celulares activos y validados
				INTO sValida_Cel
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 2
				AND status_tel = 'A'
				AND cofetel = 'V';

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET valida_cel = sValida_Cel 
				WHERE num_solicitud = pNumSol;

			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END
				into cNumCel 
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 2
				AND status_tel = 'A'
				AND cofetel = 'V'; 

			SELECT COUNT(num_celular)
				INTO Ictegrandata  
				FROM  bdiburo:"informix".br_cliente_aut
				WHERE num_cliente = cNumCteBco 
				and fecha_hora_aut =(SELECT MAX(fecha_hora_aut )
									FROM  bdiburo:"informix".br_cliente_aut 
									WHERE num_cliente=cNumCteBco);

			if NVL(Ictegrandata,0) > 0 then 
				foreach
					select limit 1  NVL(fecha_hora_aut::date,'1900-01-01')
						into fechaaut_grandata 
						from bdiburo:"informix".br_cliente_aut
						WHERE num_cliente = cNumCteBco
						and num_celular = cNumCel
						order by fecha_hora_aut
				end foreach;
				IF fechaaut_grandata <> '1900-01-01' THEN
					LET dtDiaFF = LPAD(DAY(fechaaut_grandata::DATE), 2, '0');
					LET dtMesFF = LPAD(MONTH(fechaaut_grandata::DATE), 2, '0');
					LET dtAnoFF = LPAD(YEAR(fechaaut_grandata::DATE), 4, '0');

					LET fechaaut_grandata = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
				END IF;
				foreach
					select limit 1  NVL(fecha_hora_consulta::date,'1900-01-01')
						into fechacons_grandata 
						from bdiburo:"informix".br_cliente_aut
						WHERE num_cliente = cNumCteBco
						and num_celular = cNumCel
						order by fecha_hora_consulta
				end foreach;
				IF fechacons_grandata <> '1900-01-01' THEN
					LET dtDiaFF = LPAD(DAY(fechacons_grandata::DATE), 2, '0');
					LET dtMesFF = LPAD(MONTH(fechacons_grandata::DATE), 2, '0');
					LET dtAnoFF = LPAD(YEAR(fechacons_grandata::DATE), 4, '0');

					LET fechacons_grandata = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
				END IF;
			else 
				let Ictegrandata = 0;
				SELECT COUNT(num_celular)
					INTO Ictegrandata  
					FROM  bdiburo:"informix".br_cliente_aut
					WHERE num_cliente = cNumCteBco 
					and fecha_hora_aut =(SELECT MAX(fecha_hora_aut )
										FROM  bdiburo:"informix".br_cliente_aut 
										WHERE num_cliente=cNumCteBco);

				if NVL(Ictegrandata,0) > 0 then
					foreach
						select limit 1  NVL(fecha_hora_aut::date,'1900-01-01')
							into fechaaut_grandata 
							from bdiburo:"informix".br_cliente_aut_historial
							WHERE num_cliente = cNumCteBco
							and num_celular = cNumCel
							order by fecha_hora_aut
					end foreach;
					IF fechaaut_grandata <> '1900-01-01' THEN
						LET dtDiaFF = LPAD(DAY(fechaaut_grandata::DATE), 2, '0');
						LET dtMesFF = LPAD(MONTH(fechaaut_grandata::DATE), 2, '0');
						LET dtAnoFF = LPAD(YEAR(fechaaut_grandata::DATE), 4, '0');

						LET fechaaut_grandata = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
					END IF;
					foreach
						select limit 1 NVL(fecha_hora_consulta::date,'1900-01-01')
							into fechacons_grandata 
							from bdiburo:"informix".br_cliente_aut_historial
							WHERE num_cliente = cNumCteBco
							and num_celular = cNumCel
							order by fecha_hora_consulta
					end foreach;
					IF fechacons_grandata <> '1900-01-01' THEN
						LET dtDiaFF = LPAD(DAY(fechacons_grandata::DATE), 2, '0');
						LET dtMesFF = LPAD(MONTH(fechacons_grandata::DATE), 2, '0');
						LET dtAnoFF = LPAD(YEAR(fechacons_grandata::DATE), 4, '0');

						LET fechacons_grandata = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
					END IF;
				end if;

			end if;

			SELECT {+INDEX bdinteg:"informix".si_clientecomparacionbanconomatch idx_clientecomparacionbanconomatch)} COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanconomatch
				WHERE numcte = cNumCteBco
				AND tipo = 6;
					
			IF vHuella = 0 THEN
				SELECT {+INDEX bdinteg:"informix".si_clientecomparacionbanconomatch idx_clientecomparacionbanconomatch)} COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanco
				WHERE numcte = cNumCteBco
				AND tipo = 7;
				IF vHuella > 0 THEN
					LET sFlagHuella = "1";
				END if;
			END if;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_ConsultaReferencias (pEmpresa, cNumCteBco)
				INTO cCodRet,iReferencia1,iReferencia2;

            FOREACH -- OS no se requiere, no esta activa
				SELECT num_referencia
					INTO iReferencia
					FROM  bdisolic:"informix".ss_ostelrefsolicitud
					WHERE num_solicitud = pNumSol
						
				IF iReferencia NOT IN (iReferencia1,iReferencia2) THEN
					LET iBanderareferencia = "1";			
					EXIT FOREACH;
				END IF;
			END FOREACH;	
			
			SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
				WHERE numcte = cNumCteBco;	
					
			IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
				SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea_hist a   
				WHERE numcte = cNumCteBco								 
				AND fecha_consulta = (SELECT MAX(fecha_consulta)
										FROM bdinteg:"informix".si_huella_linea_hist b 
										WHERE   numcte = cNumCteBco)
				AND secuencia = (SELECT MAX(secuencia)
									FROM bdinteg:"informix".si_huella_linea_hist c 
									WHERE  numcte = cNumCteBco);
			END IF;

            IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
				
				SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
					INTO cEdo_proceso, cNum_men, cEmpresa
					FROM bdinteg:"informix".si_huella_linea_resultado 
					WHERE ticket = cTicket
					AND estado_proceso = '2'
					AND empresa IN (0,1,2,3)
					AND num_mensaje = "602";

				IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresa,"") <> "" THEN
					LET iFlagEmpleado = "1";
				END if;
			END if;

			--MACM

			SELECT num_producto
				INTO cProducto
				FROM bdicred:"informix".sd_situacion_pago a, bdicred:"informix".sd_maecred b
				WHERE b.numcte = cNumCteBco
				AND b.empresa = pEmpresa
				AND a.empresa = b.empresa
				AND a.num_credito = b.num_credito
				AND a.fecha = (SELECT MAX(fecha) 
								FROM bdicred:"informix".sd_situacion_pago s
								WHERE s.empresa = b.empresa
								AND s.num_credito = b.num_credito
								AND s.porcentaje=(SELECT MIN(porcentaje)
													FROM bdicred:"informix".sd_situacion_pago j
													WHERE j.empresa = b.empresa
													AND j.num_credito=b.num_credito));

			------------------------------------------------------VARIABLES DE SOLICITUD
			
			FOREACH
				SELECT COUNT(numcte) 
				INTO iExisteCliente
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = cNumCteBco
				AND num_solicitud <> pNumSol 
				AND  tipo_solicitud = "C"
				AND status_solicitud NOT IN ('PC','AN','MC')
			END FOREACH;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET existecliente = iExisteCliente --alter
				WHERE num_solicitud = pNumSol;

			SELECT numcte_pros,status_numcte_pros
				INTO cCteProsp,cStatusSol_CteProsp
				FROM bdiprospectos:"informix".pr_cliente 
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND tipo_cliente = 3 
				AND status_numcte_pros NOT IN ('AN','PC','CN','CP');

			IF cStatusSol_CteProsp IS NULL THEN
				LET cPiloto	= '1';
			ELIF (iExisteCliente > 0) THEN
				LET cPiloto	= '1';		
			END IF;

			IF NVL(cCteProsp,'') = '' AND cPiloto = '1' THEN
				SELECT numcte_pros INTO cCteProspVig
				FROM bdiprospectos:"informix".pr_cliente 
				WHERE empresa = pEmpresa AND numcte = cNumCteBco AND tipo_cliente = 3;
			ELSE
				LET cCteProspVig = cCteProsp;
			END IF;

			SELECT c.tipo_alta
				INTO cTipo_Alta_CteProsp
				FROM bdisolic:"informix".ss_resum_scor_fin a, bdisolic:"informix".ss_solicitudes b, outer bdiprospectos:"informix".pr_cliente c
				WHERE a.empresa = pEmpresa 
				AND a.num_solicitud = b.num_solicitud 
				AND b.numcte = c.numcte
				AND a.num_solicitud = pNumSol;

			SELECT NVL(canal_sol, 99)
				INTO iCanalV1
				FROM bdisolic:"informix".ss_prospecteo_solicitudes
				WHERE num_solicitud = pNumSol 
				AND estatus <> 'F';

			LET pNumSol = pNumSol;
			LET cNumSolRef = cNumSolRef;
	
			SELECT count(ctesl.numcte) , count(ctes2.numcte)
                INTO sCteLargo,sCteLargo8
                FROM bdisolic:"informix".ss_clienteslargos ctesl-- Agrupar 2 consultas
                LEFT JOIN bdisolic:"informix".ss_clienteslargos ctes2 on (ctes2.numcte = cNumCteBco AND ctes2.fecha_vig_ini<= dtFechaHoy AND ctes2.fecha_vig_fin >= dtFechaHoy AND ctes2.status = 'AC')
                WHERE ctesl.numcte = cNumCteBco     
                AND ctesl.fecha_vig_ini<= dtFechaHoy 
                AND ctesl.fecha_vig_fin >= dtFechaHoy;

			-- Determina si es grupo A  -- sDeter_Grupo_A
			SELECT COUNT(numcte) 
				INTO vgrupoA
				FROM bdicred:"informix".sd_grupo_cliente 
				WHERE empresa = pEmpresa
				AND numcte  = cNumCteBco;

			EXECUTE PROCEDURE bdinteg:"informix".mesesvalidoscte (cNumCteBco)
				INTO cCodRet,iMeses_hist_Val;

			SELECT sc01::INTEGER
			INTO dValor_3s
			FROM bdiburo:"informix".br_sc a
			WHERE a.rowid = (SELECT MAX(b.rowid) 
								FROM bdiburo:"informix".br_sc b
								WHERE institucion = 'CC'
								AND b.num_cliente = cNumCteBco
								AND sc00 <> "004")
			AND institucion = 'CC'
			AND num_cliente = cNumCteBco
			AND sc00 <> "004";

			FOREACH
				SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
				INTO  iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta,cNumSol_Os,cTipoSolOS
				FROM  bdisolic:"informix".ss_solicitudes a
				JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
				WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) 
																from bdisolic:"informix".ss_osclientesupervisar AS d 
																WHERE d.num_solicitud = b.num_solicitud)
				AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte = cNumCteBco 
				UNION 
				SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
				FROM bdisolic:"informix".ss_osclientesupervisar
				WHERE empresa  = '001' AND num_solicitud  = cCteProspVig --cCteProsp
				AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar 
									WHERE num_solicitud  = cCteProspVig) --cCteProsp
				ORDER BY fecharespuesta DESC

			END FOREACH;
				
			------------------------------------------------------ VARIABLES DE BANCOPPEL

			LET cNumcreditoCCFF = "";

			SELECT COUNT(num_solicitud)
				INTO iSolMc
				FROM bdisolic:"informix".ss_solicitudes_mc
				WHERE empresa = pEmpresa
				AND  num_solicitud = pNumSol; 	
			
			SELECT COUNT(num_solicitud)--
				INTO iSolMcAux 
				FROM bdisolic:"informix".ss_solicitudes_mc
				WHERE empresa = pEmpresa
				AND  num_solicitud = cNumSolRef; 

			SELECT COUNT(num_credito) 
				INTO iCtas_StatusDif_FF_6011
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco          
				AND status_cred <> "FF"
				AND num_producto = '6011';

			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_act_riesgo( pEmpresa,cNumCteBco) -- Nota obtener consultas
			INTO cCodRet,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo;

			EXECUTE PROCEDURE bdisolic:"informix".sp_OStelConsultaResultado (pEmpresa, pNumSol)--Actualmente no se valida
				INTO cCodRet, cResultadoOsTel, cTieneOstel, cEnvioCat;

			IF cCodRet <> '000' THEN
			
				IF dSics_montopagar_revolvente = '' AND dSics_montopagar_norevolvente = '' AND dSics_saldoactual_revolvente = '' AND dSics_saldoactual_norevolvente = '' THEN
    
					LET dSics_montopagar_revolvente = '[0]';
					LET dSics_montopagar_norevolvente = '[0]';
					LET dSics_saldoactual_revolvente = '[0]';
					LET dSics_saldoactual_norevolvente = '[0]';

				END IF;
			
				LET cCodRet = '00001';
				RETURN NVL(cCodRet,000000), NVL(cSolBanco,''),	NVL(cNumCteBco,''),	NVL(cNumCte,''), NVL(pEmpresa,''), 
				NVL(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
				NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cPuntualidadCoppel,''), NVL(cProfesion,''),
				NVL(sId_actividad,0), NVL(cDescAct,''), NVL(sId_subactividad,0), NVL(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
				NVL(sCausaSituacion,-99), NVL(cMotivoRechBcpl,''), NVL(sHist_meses,0), NVL(dEficienciaCoppel,0), NVL(iCtas_StatusDif_FF_6011,0),
				NVL(cProducto,"????"), NVL(mAbonoMuebles,0), NVL(mAbonoPrestamos,0), NVL(mAbonoRopa,0),  NVL(mAbonoAire,0), NVL(mAbonoAfiliados,0),
				NVL(mAbonoReestructura,0), NVL(mVencidoMuebles,0), NVL(mVencidoRopa,0), NVL(mVencidoPrestamos,0), NVL(mVencidoAire,0), 
				NVL(mVencidoAfiliados,0), NVL(mVencidoReestructura,0), NVL(cFechaUltimoPago,'1900-01-01'), NVL(iReprestamos,0),
				NVL(cOrigenSol,'1'), NVL(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
				NVL(cActRiesgoBCpl,''),	NVL(cDescpRiesgo,''), NVL(iMax_MOP,"0"), NVL(cInstCta_MayorMOP,''), 
				NVL(dMonto_UDIS_MayorMOP,0), NVL(iMax_MOP_Hist_6m,"0"), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
				NVL(iMM_Histo_12m,"0"), NVL(cInstCta_MayorMOP_12m,''),  NVL(dMontoUDIS_MM_12m,0), NVL(iNumCtasMOP_4_12m,0),
				NVL(iNumCtasMOP_5_12m,0), NVL(iNumCtasMOP_mayor5_12m,0), NVL(iMOP4_12mCon1o2,0), NVL(iMOP5_12mCon1o2,0),
				NVL(iMOPmayor5_12mCon1o2,0), NVL(cInstitucionMMOP_provocaRech,''), NVL(dMontoUDIS_MM_Rech,0), NVL(iNumCtasMOP_4_30m,0),
				NVL(iNumCtasMOP_5_30m,0), NVL(iNumCtasMOP_mayor5_30m,0), NVL(iCtasMOP_4_30mCon1o2,0), NVL(iCtasMOP_5_30mCon1o2,0),
				NVL(iCtasMOP_mayor5_30mCon1o2,0), NVL(iMM_Histo_30m,"0"), NVL(cInstCta_MM_30m_Rech,''), NVL(dMotoUDIS_MM_30m_Rech,0), 
				NVL(iNumCtas_ClvOb,"0"), NVL(dMontoUdis,0), NVL(cInstitucion,''), NVL(cClvObser,'0'), NVL(sBc_Score,0), 
				NVL(vClvExclusionMasReciente,0), NVL(cInstitucionClvExclusionMasReciente,''), NVL(iCtas_SinComServ,0),
				NVL(iCtas_SinComServ_pagar,0), NVL(iNumCtas_SHBr,0), NVL(iNumCtas_SHBr_pagar,0),NVL(BC_101,0), 
				NVL(iMM_act_Bancos,0), NVL(iMM_hist_alto_Bancos,'0'), NVL(iMM_hist_Bancos,"0"), NVL(iCtasBancosMOP_tl26,0),
				NVL(iCtasBancosMOP_tl38,0), NVL(iCtasBancosMOP_tl27,0), NVL(iCtasBancosMOP_act_hist_alto,0),  
				NVL(iCtasComServMOP_tl26,0), NVL(iCtasComServMOP_tl38,0), NVL(iCtasComServMOP_tl27,0), NVL(iCtasCSM_act_hist_alto,0),
				 NVL(iCtasComServMOP_tl26_12m,0), NVL(iCtasComServMOP_tl38_12m,0), NVL(iCtasComServMOP_tl27_12m,0), 
				NVL(iCtasCSM_ActHistAlto_12m,0), NVL(dtFechaAux,'1900-01-01'), NVL(iMaxMOP_actBancos,"0"), 
				NVL(iMaxMOP_histAltBancos,"0"), NVL(iMaxMOP_histBancos,"0"),   NVL(iMaxMOP_actCtas,"0"), NVL(iMaxMOP_histAltCtas,"0"),
				NVL(iMaxMOP_histCtas,"0"), NVL(dSituacionPagoCoppel,"0"), NVL(mIngreso_Mensual,0), NVL(mPagoMinimo,0), NVL(sCteLargo8,0),
				NVL(iMeses_hist_Val,0), NVL(cTipo_Alta_CteProsp,''), NVL(mLinea_tienda,0), NVL(mImporte_hip,0), NVL(dTasa,0),
				NVL(sFlagHuella,"0"), NVL(cResultadoOsTel,''), NVL(cTieneOstel,''), NVL(cEnvioCat,''), NVL(iSolMc,0),
				NVL(iSolMcAux,0), NVL(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,"0"), 
				NVL(dtUltimaCompra,'1900-01-01'), NVL(iBanderareferencia,"0"), NVL(dtFechaCte,'1900-01-01'), NVL(cFolioMovil,""),
				NVL(cFlagGeoMov,""), NVL(iFlagGeoSuc,"0"), NVL(iCanal_Sol,"0"), NVL(cOrigenCte,''), NVL(sFlagForzarEnvioMC,""), 
				NVL(iSecuenciaOs,"0"), NVL(cStatusRespOs,''), NVL(dtFecha_Respuesta, '1900-01-01'), NVL(cNumSol_Os,''), NVL(cCompIngresos,''),
				NVL(dIngresoCac,0), NVL(sCompValido, 0), NVL(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
				NVL(dCompromisosCac,0), NVL(sFlag_oro,0), NVL(mIngreso_Neto,0), NVL(dtFechaNac,'1900-01-01'), NVL(cSexo,''),
				NVL(cEdo_Civil,''), NVL(iTiem_Edo_Civil,-99), NVL(UT0034,-999), NVL(cOcupacion,''),	NVL(iTiem_Ocupacion, -99), 
				NVL(cEscolaridad,''), NVL(cTipoResidencia,''), NVL(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
				NVL(cEntidad,''), NVL(sCteLargo,"0"), NVL(cCURP,''), NVL(iFlagEmpleado,"0"), NVL(dValor_3s,0),
				NVL(cStatusMovil,''), NVL(cCteProsp,''), NVL(cStatusSol_CteProsp,''), NVL(cRTipo3,''), NVL(cVigSolOS,''), NVL(sBuenPagos,'0'),
				NVL(dCompromisos,0), NVL(sFlagBuenPago12,"0"), NVL(sFlagBuenPago30,"0"), NVL(sEntidad_Localidad,"0"), NVL(cNuevoStatusOstel,''), 
				NVL(cCteProspVig,''), NVL(mCompro_banco,0), NVL(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), NVL(cGeoCte,''), NVL(iCanalV1,"99"), 
				NVL(IQ0002,"0.00"), NVL(iCtas_StatusFF_6011,0), 
				NVL(iTiem_Edo_Civil_meses, -99), NVL(iExisteCliente,0), NVL(mSaldoRopa,0), 
				NVL(mSaldoMuebles,0), NVL(mSaldoPrestamos,0), NVL(vgrupoA,''), NVL(NumSolMovil,''), NVL(iFlag2credito,0), NVL(NumCuentaPagoMinimo,0),
				NVL(dtFechaSolicitud, '1900-01-01'), NVL(sEdadCte,0), NVL(pMeses_historia_grupo,0), NVL(pSituacion_pago_grupo,0), NVL(dSalariomin,0), 
				NVL(dTasa_Ordinaria,0), NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
				NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0), NVL(Validaos,'0'),
				NVL(iNewMPP,""), NVL(vCuentasPF,"0"), NVL(BCScorePP,0), NVL(ScorePropietario,0), NVL(vEficUltSem,0), NVL(vMorAct,0), NVL(vPorcUso,0), 
				NVL(velemPuntualidad,''), NVL(IQ00012,0), NVL(vSumSaldoActualTL22,0), NVL(vSumLimCredTL23,0), NVL(iParamincrDecr,""), NVL(iExisteSolPP,0),
				NVL(vNumTotalCtas,0), NVL(vCtas_al_corriente,0), NVL(vCtas_sin_historia,0), NVL(vMesesAperCtaAntigua,0), NVL(vMesesAperCtaAntiguaRev,0),
				NVL(vNumVecesBANCOPPEL,0), NVL(vNumVecesTiendaComercial,0), NVL(vNumTotalCtasTL13,0), NVL(v_valor_1s,0), NVL(inumppf,0), NVL(mTasa_Interes,0),
				NVL(capacidad_pres,0), NVL(vSaldoMorHistAltaTL36,0), NVL(vCtas_30_mas_atraso_hist,0), NVL(iNumCtasAper36,0), NVL(TL37,'1900-01-01'), NVL(iExisteBR_TL_mora,'0'),
				NVL(vFechaTL37,'1900-01-01'), NVL(iSumaTL13,0), NVL(iFlag2credito2,""), NVL(iValorICC,""), NVL(vInstitucion,''), NVL(pFrecuencia,""), NVL(iDiaPago,""),
				NVL(vMaxPlazoDias,0), NVL(vFalloSic,"0"), NVL(dtFechaHoy,'1900-01-01'), NVL(vSum_bal,0), NVL(vSum_higcred,0),
				NVL(origeninput1,''), NVL(origeninput2,''), NVL(origeninput3,''), NVL(origeninput4,''), NVL(origeninput5,0), NVL(origeninput6,0), NVL(origeninput7,0), NVL(origeninput8,0),
				NVL(Ictegrandata,0), NVL(fechaaut_grandata,'1900-01-01'),NVL(fechacons_grandata,'1900-01-01'),
				-- EMPIEZAN VARIABLES DE RETORNO DE BRM 2025 --
				NVL(dIngreso_ajustado, 0.0), NVL(iMora_coppel, 0), NVL(iSaldo_vencido_coppel, 0), NVL(iMora_bancoppel, 0), NVL(iSaldo_vencido_bancoppel, 0), NVL(vTipo_transaccion, ''),
				NVL(iAntiguedad, 0), NVL(iHawk, 0), NVL(iFraudes, 0), NVL(iFlag_creditopp_activo, 0), NVL(iEstabilidadvivienda, 0), NVL(iRechazoos, 0), NVL(iCn_sic, 0), NVL(iLista_negra, 0), NVL(iNo_tramitedia_tdc, 0),
				NVL(iNo_tramitedia_pp, 0), NVL(dSics_montopagar_revolvente, '[0]'), NVL(dSics_montopagar_norevolvente, '[0]'), NVL(dSics_saldoactual_revolvente, '[0]'), NVL(dSics_saldoactual_norevolvente, '[0]'),
				NVL(dGc_saldoactual_coppel, 0.0), NVL(dGc_saldoactual_bancoppel, 0.0), NVL(dGc_montopagar_coppel, 0.0), NVL(Gc_montopagar_bancoppel, 0.0), NVL(vTipo_colectivo, ''),
				NVL(dReestructuras, 0.0), NVL(dIdentificacion_falsa, 0.0), NVL(dQuebranto, 0.0), NVL(dPromedio_ingresom_ult4d, 0.0), NVL(dContinuidad_depositos_nomina, 0.0), NVL(vTipo_empleado_code, ''),
				NVL(vTipo_empleado_name, ''), NVL(vObservacion_mc, ''), NVL(vOrigeninput9, ''), NVL(vOrigeninput10, ''), NVL(vOrigeninput11, ''), NVL(vOrigeninput12, ''), NVL(Origeninput13, 0),
				NVL(Origeninput14, 0), NVL(Origeninput15, 0), NVL(Origeninput16, 0);
			END IF;

			LET cCodRet = '000000';
			--------------
			SELECT COUNT(a.status_solicitud) 
				INTO sFlagForzarEnvioMC -- Bandera para el envio forzado de solicitud a MC
				FROM bdisolic:"informix".ss_solicitudes s
				LEFT JOIN bdisolic:"informix".ss_autorizacion a ON s.empresa = a.empresa AND a.num_solicitud = s.num_solicitud
				WHERE s.empresa = pEmpresa
				AND s.numcte = cNumCteBco
				AND s.num_solicitud <> pNumSol
				AND s.fecha_hora = (SELECT MAX(fecha_hora)
										FROM bdisolic:"informix".ss_solicitudes 
										WHERE empresa = pEmpresa
										AND numcte = cNumCteBco
										AND num_solicitud <> pNumSol 
										--AND status_solicitud NOT IN('AN','PC') AND num_producto IN('6800','6001','6300','7600','7700'))
										AND status_solicitud NOT IN('AN','PC') AND num_producto IN (SELECT num_producto
																										FROM bdicred:"informix".sd_definicion
																										WHERE empresa = pEmpresa
																										and envio_mesa_control = '1'))
				AND a.status_solicitud = 'CM' AND s.status_solicitud IN('CM','CN');

			SELECT valor 
				INTO dMaxMtoUdi
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = "309";

			SELECT TRIM(valor) 
				INTO vCodUdi
				FROM bdinteg:"informix".si_param
				WHERE empresa = pEmpresa
				AND cod_param = 16;

			SELECT TRIM(valor) 
				INTO vCodUs
				FROM bdinteg:"informix".si_param
				WHERE empresa = pEmpresa
				AND cod_param = 17;

			SELECT TRIM(valor)
				INTO vClase
				FROM bdicred:"informix".sd_param
				WHERE empresa = pEmpresa
				AND cod_param = "336";

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa,dtFechaHoyAUX,vCodUdi,vClase,'0')
				INTO cCodRet,vTpCambioUdi;

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa,dtFechaHoyAUX,vCodUs,vClase,'1')
				INTO cCodRet,vTpCambioUs;

			let i = 0;
			let var_i = 0;
			let bandera12 = 0;
			LET dMontoUDIS_MM_Rech = 0;
			let vmeses12 = 0;
			FOREACH
				SELECT 	institucion, tl27,
						round(CASE 	WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl36,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((NVL(b.tl36,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   NVL(b.tl36,0) 
							ELSE NVL(b.tl24,0) END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				INTO vInstitucion, vTl27, vMontoUdis, vmeses_pos
				FROM bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND NVL(tl26,'') <> ''
				AND b.tl11=c.tipo
				and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				ORDER BY tl17 DESC

				let vCuantos = 0;
				let i = 0;
			
				let vmeses12 = replace(replace(replace(replace(vmeses12||substr(vTl27,1,12),'-','0'),'X','0'),'U','0'),' ','0');
				for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) >= 5 and vMontoUdis >= dMaxMtoUdi) then
						LET vCuantos = 1;
						exit for;
					end if;
				end for;

				if (vCuantos = 1) then
					LET dMontoUDIS_MM_Rech = vMontoUdis;
				end if;
			END FOREACH;

			--------------------- Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R	
			SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO MOPHistoricoAltoTl38
				FROM bdiburo:br_tl WHERE num_cliente = cNumCteBco;

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl38
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco
			END FOREACH;

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl27
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco
			END FOREACH;	

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl26
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06 = 'R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco
			END FOREACH;	

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_act_hist_alto
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco
			END FOREACH;

			--------------------- Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"
			FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl38
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco
			END FOREACH;

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl26
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco
			END FOREACH;	

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl27
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco
			END FOREACH;	

			FOREACH
				SELECT count (num_cliente)
					INTO iCtasCSM_act_hist_alto
					FROM bdiburo:"informix".br_tl
					WHERE (tl26 in ('2','3','4','5','6','7','96','97','99') 
							OR tl27 in ('2','3','4','5','6','7','96','97','99') )
					AND num_cliente = cNumCteBco
					AND tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl38 = MOPHistoricoAltoTl38
					AND tl06='R'
			END FOREACH;	
				
			---------------- Numero de cuentas BCSCORE
			LET iCtas_SinComServ = 0;
			
			FOREACH
				SELECT count (num_cliente) --Validar con cal_circulocredito
				INTO iCtas_SinComServ	-----sin comunicaciones ni servicios	iCtas_SinComServ
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
				AND num_cliente = cNumCteBco
			END FOREACH;
			
			LET iCtas_SinComServ_pagar = 0;
			
			FOREACH
				SELECT count (num_cliente)
				INTO iCtas_SinComServ_pagar--pagar iCtas_SinComServ_pagar
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
				AND a.tl12 <> 0
				AND num_cliente = cNumCteBco				
			END FOREACH;
			
			LET iNumCtas_SHBr_pagar = 0;
			
			FOREACH
				SELECT count (num_cliente)
				INTO iNumCtas_SHBr_pagar
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl06 = 'M' AND a.tl07 = 'RE'
				AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
				AND num_cliente = cNumCteBco
			END FOREACH;	

			LET iNumCtas_SHBr = 0; 
			FOREACH
				SELECT count (num_cliente)
				INTO iNumCtas_SHBr
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl06 = 'M' AND a.tl07 = 'RE'
				AND a.tl02 = 'SERVICIOS'
				AND num_cliente = cNumCteBco
			END FOREACH;

			---------------- Maximo MOP de bancos 

			SELECT MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
				INTO iMaxMOP_actCtas
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;

			SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMaxMOP_histAltCtas
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;

			LET var_i = 0;
			LET CantTl27 = 0;
			LET CadenaTl27 = '';
			LET contenedor = '';
			LET comparador = 0;

			FOREACH
				SELECT length(trim (tl27)), tl27
					INTO CantTl27 , CadenaTl27
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco

				if NVL(CadenaTl27,'') = '' THEN
					continue foreach;
				end if;
				for var_i = 1 to CantTl27
					IF (SUBSTR(CadenaTl27,var_i,1) NOT IN ('U','X', 'D', '-', ' ', '0') ) THEN
						LET contenedor = SUBSTR(CadenaTl27,var_i,1);
						IF(contenedor::INTEGER > comparador) THEN
							LET comparador = contenedor;
						END IF;
					END IF;
				end for;
				LET iMaxMOP_histCtas = contenedor;
			END FOREACH;
			------------

			SELECT  MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO MaxComServMOP_tl38
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco;
			
			SELECT count (num_cliente)
				INTO iCtasComServMOP_tl38_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl38 = MaxComServMOP_tl38
				AND (((year(dtFechaHoyAUX) - year(NVL(tl17,dtFechaHoyAUX)))*12) + (month(dtFechaHoyAUX) - month(NVL(tl17,dtFechaHoyAUX)))) <= 12;			

			SELECT count (num_cliente)  
				INTO iCtasComServMOP_tl26_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl26 in ('2','3','4','5','6','7','96','97','99')
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL') --- Ver opcion de meterlas a catalogo BRM = 1
				AND (((year(dtFechaHoyAUX) - year(NVL(tl17,dtFechaHoyAUX)))*12) + (month(dtFechaHoyAUX) - month(NVL(tl17,dtFechaHoyAUX)))) <= 12;
			
			SELECT count (num_cliente)  
				INTO iCtasComServMOP_tl27_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl27 in ('2','3','4','5','6','7','96','97','99')
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
				AND (((year(dtFechaHoyAUX) - year(NVL(tl17,dtFechaHoyAUX)))*12) + (month(dtFechaHoyAUX) - month(NVL(tl17,dtFechaHoyAUX)))) <= 12;

			SELECT count (num_cliente)  
				INTO iCtasCSM_ActHistAlto_12m
				FROM bdiburo:"informix".br_tl
				WHERE (tl27 in ('2','3','4','5','6','7','96','97','99')
						OR tl38 = MaxComServMOP_tl38)
				AND num_cliente = cNumCteBco
				AND (((year(dtFechaHoyAUX) - year(NVL(tl17,dtFechaHoyAUX)))*12) + (month(dtFechaHoyAUX) - month(NVL(tl17,dtFechaHoyAUX)))) <= 12
				AND tl26 in ('2','3','4','5','6','7','96','97','99') 
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL');

			------------------------------------------------------ VARIABLES DE EVALUACION
			--se contempla validaciones para determinar el status de la solicitud de acuerdo a la OS telefonica y sus meses de historia del cliente		 
			SELECT resultado 
				INTO cNuevoStatusOstel
				FROM bdisolic:"informix".ss_ostel
				WHERE empresa = pEmpresa
				AND tp_solicitud = cTp_solicitud
				AND min_mes_hist <= sHist_meses
				AND max_mes_hist >= sHist_meses
				AND origen= cOrigenCte
				AND os_tel = cResultadoOsTel; 
				
			IF cpiloto = '1' THEN
				EXECUTE PROCEDURE bdisolic:"informix".sp_os_consultatipo3(pEmpresa, cNumCteBco,cNum_Producto,2 ) 
				INTO  cCodRet, cRTipo3, cVigSolOS; 
			END IF;
		
		IF cNum_Producto = '6400' THEN
			-- AQUI VAN LAS VARIABLES BRM 2025 --
------------------------------------------------------------------------------------------------------------------------------------------------------
			-- ASIGNACION DE VARIABLES NUEVAS DE BRM (Marzo 2025) --
			-- dIngreso_ajustado -- se obtiene:
			
			------EMPIEZA INGRESO AJUSTADO ***********************++
			
				SELECT COUNT(sndc.numcte), COUNT(DISTINCT (sndc.cuenta))  
				INTO iNumCteAux, iNumCuentaAux
				FROM bdicheq:"informix".sc_nom_disp_cte as sndc
				WHERE sndc.numcte  = cNumCteBco;
				
			--TIPO_EMPEADO_NAME	
			--TIPO_TRANSACCION
							
			IF iNumCteAux > 1 THEN
			  
					IF iNumCuentaAux > 1 THEN
					 
						SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta   
						INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
						FROM bdicheq:"informix".sc_nom_disp_cte 
						WHERE numcte = cNumCteBco 
						AND ingresos_netos = (SELECT MAX(ingresos_netos) 
						FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco);
						
						   
											--OBTENER LA CUENTA DE MAYOR INGRESO
					
					ELSE
							
							SELECT COUNT(sndc.cuenta) 
							INTO iNumCuentaAux
							FROM bdicheq:"informix".sc_nom_disp_cte as sndc
							WHERE sndc.numcte  = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW';
							
							IF iNumCuentaAux > 1 THEN
							
							SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
							INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
							FROM bdicheq:"informix".sc_nom_disp_cte
							WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW'
							AND ingresos_netos = (SELECT MAX(ingresos_netos) 
							FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW');
							
							ELSE
							
							SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
							INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
							FROM bdicheq:"informix".sc_nom_disp_cte
							WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW';
							
							END IF;
							
							
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
							LET vTipo_transaccion = '';
							LET dIngreso_ajustado = 0;
						END IF;
						
						IF vTipo_transaccion = '' AND dIngreso_ajustado = 0 THEN
								--ORDENAR POR TIPO TRANSACCION
								
								SELECT COUNT(sndc.cuenta) 
								INTO iNumCuentaAux
								FROM bdicheq:"informix".sc_nom_disp_cte as sndc
								WHERE sndc.numcte  = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN';
								
								IF iNumCuentaAux > 1 THEN
								
								
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN'
								AND ingresos_netos = (SELECT MAX(ingresos_netos) 
								FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN');
								
								ELSE
								
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN';
								
								
								END IF;
								
						END IF;
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
							LET vTipo_transaccion = '';
							LET dIngreso_ajustado = 0;
						END IF;
						
						IF vTipo_transaccion = '' AND dIngreso_ajustado = 0 THEN
						
								SELECT COUNT(sndc.cuenta) 
								INTO iNumCuentaAux
								FROM bdicheq:"informix".sc_nom_disp_cte as sndc
								WHERE sndc.numcte  = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB';
								
								IF iNumCuentaAux > 1 THEN
							
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB'
								AND ingresos_netos = (SELECT MAX(ingresos_netos) 
								FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB');
								
								ELSE
								
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB';
								
								END IF;
								 
							
						END IF;
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
							LET vTipo_transaccion = '';
							LET dIngreso_ajustado = 0;
						END IF;
						
						IF vTipo_transaccion = '' AND dIngreso_ajustado = 0 THEN
						
								SELECT COUNT(sndc.cuenta) 
								INTO iNumCuentaAux
								FROM bdicheq:"informix".sc_nom_disp_cte as sndc
								WHERE sndc.numcte  = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP';
								
								IF iNumCuentaAux > 1 THEN
							
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP'
								AND ingresos_netos = (SELECT MAX(ingresos_netos) 
								FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP');
								
								ELSE
								
								SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
								INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
								FROM bdicheq:"informix".sc_nom_disp_cte
								WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP';
								
								END IF;
								
							
						END IF;						
					  
					END IF;
			ELSE
				SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta 
				INTO vTipo_transaccion, dIngreso_ajustado, iCuentaCte
				FROM bdicheq:"informix".sc_nom_disp_cte
				WHERE numcte = cNumCteBco;
			END IF;
			
			IF NVL(dIngreso_ajustado,0) = 0 THEN
				LET dIngreso_ajustado = 0;
			END IF;
			
			--TIPO_EMPLEADO_CODE					
			IF vTipo_transaccion = 'EPB' THEN
				LET vTipo_empleado_code = '001';
			ELIF vTipo_transaccion = 'PEN' THEN
				LET vTipo_empleado_code = '002';
			ELIF vTipo_transaccion = 'SWD' THEN
				LET vTipo_empleado_code = '003';
			ELIF vTipo_transaccion = 'EGP' THEN
				LET vTipo_empleado_code = '004';		
			ELSE
				LET vTipo_empleado_code = '';  
			END IF;
			
			SELECT descripcion INTO vTipo_empleado_name FROM bdicheq:"informix".sc_nomina_tipoctes WHERE clave_tipo = vTipo_transaccion;
			
			IF NVL(vTipo_empleado_name,'') = '' THEN
				LET vTipo_empleado_name = '';
			END IF;
			
			LET vTipo_transaccion = vTipo_empleado_name;
			
			------TERMINA INGRESO AJUSTADO ***********************++
			
		
			-- iMora_coppel -- se obtiene: en Linea 3454			

			-- iSaldo_vencido_coppel -- se obtiene -
			SELECT vencidoropa, vencidototalaire, vencidomuebles, vencidoprestamos, vencidototalafiliados, vencidototalreestructura
			INTO mVencidoRopa, mVencidoAire, mVencidoMuebles, mVencidoPrestamos, mVencidoAfiliados, mVencidoReestructura
			FROM bdisolic:"informix".ss_revision_determinacion 
			WHERE num_solicitud = pNumSol
			AND numcte = cNumCteBco;
			
			LET iSaldo_vencido_coppel =  (NVL(mVencidoMuebles, 0.0) + NVL(mVencidoRopa, 0.0) + NVL(mVencidoPrestamos, 0.0) +
									  	  NVL(mVencidoAire, 0.0) + NVL(mVencidoAfiliados, 0.0) + NVL(mVencidoReestructura, 0.0));

			-- iMora_bancoppel -- Se Obtiene
			FOREACH
				SELECT num_credito INTO vNum_Cred
				FROM bdicred:"informix".sd_maecred
				WHERE numcte = cNumCteBco
				AND empresa = pEmpresa
				AND status_cred IN ('E1', 'E2', 'E3')

				SELECT mto_fin_ven_trasp, monto_financiado, sdo_cap_insoluto
				INTO dVenc_traspRev, dMont_finRev, dSdoActCap
				FROM bdicred:"informix".sd_maesdos
				WHERE num_credito = vNum_Cred;

				IF dMax_traspRev < dVenc_traspRev THEN
					LET dMax_traspRev = NVL(dVenc_traspRev, 0.0);
				END IF;

				LET dSum_MontFinRev = (NVL(dSum_MontFinRev, 0.0) + NVL(dMont_finRev, 0.0));
				LET dSum_dSdoActCap = (NVL(dSum_dSdoActCap, 0.0) + NVL(dSdoActCap, 0.0));
			END FOREACH;

			LET ivencidoBanRev = NVL(dMax_traspRev, 0.0);

			FOREACH
				SELECT num_credito INTO vNum_Cred
				FROM bdicred:"informix".sd_maecredcrd
				WHERE numcte = cNumCteBco
				AND empresa = pEmpresa
				AND status_cred IN ('E1', 'E2', 'E3')

				SELECT mto_fin_ven_trasp, monto_financiado, sdo_cap_insoluto
				INTO dVenc_traspPP, dMont_finPP, dSdoActCap_crd
				FROM bdicred:"informix".sd_maesdoscrd				
				WHERE num_credito = vNum_Cred;

				IF dMax_traspPP < dVenc_traspPP THEN
					LET dMax_traspPP = NVL(dVenc_traspPP, 0.0);
				END IF;
				
				LET dSum_MontFinPP = (NVL(dSum_MontFinPP, 0.0) + NVL(dMont_finPP, 0.0));
				LET dSum_dSdoActCap_crd = (NVL(dSum_dSdoActCap_crd, 0.0) + NVL(dSdoActCap_crd, 0.0));

			END FOREACH;

			LET ivencidoBanPP = dMax_traspPP;

			IF ivencidoBanRev >= ivencidoBanPP THEN
    			
				LET ivencidoBancop = NVL(ivencidoBanRev, 0.0);
			
			ELSE 
    			
				LET ivencidoBancop = NVL(ivencidoBanPP, 0.0);
			
			END IF;

			LET iMora_bancoppel = NVL(ivencidoBancop, 0.0);

			-- Gc_montopagar_bancoppel -- Se Obtiene
			LET Gc_montopagar_bancoppel = (NVL(dSum_MontFinRev,0.0) + NVL(dSum_MontFinPP, 0.0));
			
			-- dGc_saldoactual_bancoppel --
			LET dGc_saldoactual_bancoppel = NVL(dSum_dSdoActCap, 0.0) + NVL(dSum_dSdoActCap_crd, 0.0);

			-- iSaldo_vencido_bancoppel -- Se obtiene  -- Saldo vencido PP
			SELECT SUM(NVL(A.monto_vencido,0))
			INTO iSumpp
			FROM bdicred:"informix".sd_maesdoscrd A
			INNER JOIN bdicred:"informix".sd_maecredcrd B on (A.num_credito = B.num_credito)
			WHERE B.empresa = pEmpresa
			AND B.numcte = cNumCteBco
			AND B.status_cred IN ('E1', 'E2', 'E3', 'VP');
			
			SELECT SUM(NVL(A.monto_vencido,0))
			INTO iSumtdc
			FROM bdicred:"informix".sd_maesdos A
			INNER JOIN bdicred:"informix".sd_maecred B on (A.num_credito = B.num_credito)
			WHERE B.empresa = pEmpresa
			AND B.numcte = cNumCteBco 
			AND B.status_cred IN ('E1', 'E2', 'E3'); 

			LET iSaldo_vencido_bancoppel = 	(NVL(iSumpp, 0) + NVL(iSumtdc, 0));
			
			-- iAntiguedad -- Se Obtiene --
			SELECT fecha_hoy
            INTO dtFechaHoyAUX
            FROM bdicred:"informix".sd_fechas
            WHERE empresa = pEmpresa;
			
			SELECT A.fecha_alta
			INTO dFechaAltaCtaNom
			FROM bdicheq:"informix".sc_maenoc A
			INNER JOIN bdicheq:"informix".sc_maechq B ON A.cuenta = B.cuenta
			WHERE B.status_cta = '1'
			AND B.num_cte = cNumCteBco
			AND A.cuenta = iCuentaCte;
			
			LET iAntiguedad = months_between(dtFechaHoyAUX, dFechaAltaCtaNom);

			-- iHawk -- se obtiene
 			LET iHawk = 0;

			-- iFraudes -- Pendiente (Falta el origen de la consulta) se devuelve Valor asignado al inicio
			LET iFraudes = 0;
			
			-- iFlag_creditopp_activo -- Se obtiene
			LET iConteo = 0;
			
			SELECT  count(*) INTO iConteo
			FROM bdicred:"informix".sd_maecredcrd a 
			inner join bdicred:sd_definicion b on a.num_producto = b.num_producto
			WHERE  A.numcte = cNumCteBco
			AND A.status_cred IN ('E1', 'E2', 'E3')
			AND familia in ('002','003');

			
			IF 	iConteo > 0 THEN

				LET iFlag_creditopp_activo = 1;
			ELSE 
				LET iFlag_creditopp_activo = 0;
			END IF;

			-- iEstabilidadvivienda -- Se Obtiene en la Linea 3265

			-- iRechazoos -- Pendiente (Falta el origen de la consulta)
			LET iRechazoos = 0;

			-- iCn_sic -- Se Obtine (cuentas canceladas)
			LET iConteo = 0;

			SELECT COUNT(*) INTO iConteo
			FROM bdiburo:"informix".br_tl
	 		WHERE tl30 = 'CC'
	 		AND num_cliente = cNumCteBco;

			IF 	iConteo > 0 THEN

				LET iCn_sic = 1;
			ELSE
				LET iCn_sic = 0;
			END IF;

			-- iLista_negra -- Se obtiene
			SELECT F.rfc, F.nombre1, F.nombre2, F.apell_paterno, F.apell_materno, to_char(G.fecha_nac, "%d%m%y")
			INTO pRfc, pNombre1, pNombre2, pApellPaterno, pApellMaterno, pFechaNac
			FROM bdinteg:"informix".si_cliente F INNER JOIN bdinteg:"informix".si_ctepf G
			ON F.numcte = G.numcte
			WHERE F.numcte = cNumCteBco; -- completar consulta en sp productivo

			LET fechanacFor = SUBSTR(pFechaNac,9,2) || SUBSTR(pFechaNac,6,2) || SUBSTR(pFechaNac,1,4);

			EXECUTE PROCEDURE bdiauditor:"informix".sp_perfisica_listanegra_exp(pRfc, pNombre1, pNombre2, pApellPaterno, pApellMaterno, fechanacFor)
			INTO cCodRet, cMensListaNegra, cList_neg, iTipoListaNegra;

			IF cList_neg = '1' THEN
				LET iLista_negra = 1;
			ELSE
				LET iLista_negra = 0;
			END IF;

			-- iNo_tramitedia_tdc -- Se obtiene
			SELECT count(num_solicitud)
            INTO iNo_tramitedia_tdc
            FROM bdisolic:"informix".ss_solicitudes 
            WHERE numcte = cNumCteBco
            AND DATE(fecha_insert) >=  DATE(TODAY - 30 UNITS day)
            AND num_producto IN (SELECT
                                 num_producto
                                 FROM bdicred:"informix".sd_definicion
                                 WHERE cod_tipcred='03'
                                 AND familia IN (SELECT
                                                 id_familia
                                                 FROM bdicred:"informix".sd_familia_productos
                                                 WHERE id_familia IN ('001'))); --Familia TDC
            
            --iNo_tramitedia_pp -- Se obtiene
            SELECT COUNT(num_solicitud)
            INTO iNo_tramitedia_pp 
            FROM bdisolic:"informix".ss_solicitudes
            WHERE numcte = cNumCteBco
            AND DATE(fecha_insert) >= DATE(TODAY - 30 UNITS day)
            AND num_producto IN (SELECT
                                 num_producto
                                 FROM bdicred:"informix".sd_definicion
                                 WHERE cod_tipcred = '05' 
                                 AND familia IN (SELECT
                                                 id_familia
                                                 FROM bdicred:sd_familia_productos 
                                                 WHERE id_familia IN ('002','003'))); --Familia prestamos			

            -- dSics_montopagar_revolvente -- Se Obtienen 
			-- dSics_saldoactual_revolvente -- Se Obtienen 
			-- VARIABLES REVOLVENTES --
			LET iCont = 1;
			FOREACH
				SELECT CAST(tl12 AS integer), CAST(tl22  AS integer)
				INTO cTL12, cTL22
				FROM bdiburo:"informix".br_tl
				WHERE tl06 = 'R' AND tl11 = 'Z'
				AND tl12 <> 0 AND tl02 NOT IN ('BANCOPPEL', 'COPPEL') 
				AND num_cliente = cNumCteBco				
				AND (tl16 is null OR tl16 = '')
				
				--
				
				IF  iCont = 1 THEN
            		
					LET dSics_montopagar_revolvente = '[' || NVL(cTL12,'0');
					LET dSics_saldoactual_revolvente = '[' || NVL(cTL22,'0');
					
				ELSE

					LET dSics_montopagar_revolvente = TRIM(dSics_montopagar_revolvente) ||','|| NVL(cTL12,'0');
	        		LET dSics_saldoactual_revolvente = TRIM(dSics_saldoactual_revolvente) ||','|| NVL(cTL22,'0');
				
				END IF;
				
				LET iCont = iCont + 1;
				
			END FOREACH;
			
			--
			IF dSics_montopagar_revolvente <> '' AND dSics_saldoactual_revolvente <> '' THEN
				LET dSics_montopagar_revolvente = TRIM(dSics_montopagar_revolvente) || ']';
				LET dSics_saldoactual_revolvente = TRIM(dSics_saldoactual_revolvente)  || ']';
				
			ELSE 
			
				LET dSics_montopagar_revolvente = '[0]' ;
				LET dSics_saldoactual_revolvente = '[0]';
			
			END IF;
			
			-- ------------------------------------------------------------------------------------------------------------ --		
			-- VARIABLES NO REVOLVENTES -- -- dSics_montopagar_norevolvente -- dSics_saldoactual_norevolvente -- Se Obtienen 
			
			LET iCont = 1;
			LET cTL12 = '';
			LET cTL22 = '';
			
			FOREACH
			
				SELECT CAST((br.tl12 * cir.factor) as integer) , cast(br.tl22 as integer)
				INTO cTL12, cTL22
				FROM bdiburo:"informix".br_tl br INNER JOIN bdisolic:"informix".ss_circulo_frecpag cir ON (br.tl11 = cir.tipo) 
				where br.tl11 <> 'Z' AND br.tl12 <> 0
				AND tl06 <> 'R'
				AND br.tl02 NOT IN ('BANCOPPEL', 'COPPEL') 
				AND br.num_cliente = cNumCteBco
				AND (br.tl16 is null OR br.tl16 = '')
				
				IF iCont = 1 THEN 
				
					LET dSics_montopagar_norevolvente = '[' || NVL(cTL12,'0');
					LET dSics_saldoactual_norevolvente = '[' || NVL(cTL22,'0');
					
				ELSE

					LET dSics_montopagar_norevolvente = TRIM(dSics_montopagar_norevolvente) ||','|| NVL(cTL12,'0');
	        		LET dSics_saldoactual_norevolvente = TRIM(dSics_saldoactual_norevolvente) ||','|| NVL(cTL22,'0');
				
				END IF;
				
				LET iCont = iCont + 1;		
		
			END FOREACH;
			
			IF dSics_montopagar_norevolvente <> '' AND dSics_saldoactual_norevolvente <> '' THEN
				LET dSics_montopagar_norevolvente = TRIM(dSics_montopagar_norevolvente) || ']';
				LET dSics_saldoactual_norevolvente = TRIM(dSics_saldoactual_norevolvente)  || ']';
				
			ELSE 
			
				LET dSics_montopagar_norevolvente = '[0]' ;
				LET dSics_saldoactual_norevolvente = '[0]';
			
			END IF;
		
			LET iConteo = 0;

			-- dGc_saldoactual_coppel --
			-- dGc_montopagar_coppel -- 
			SELECT
			(saldoropa + saldomuebles + saldoprestamos + saldototalaire + saldototalafiliados + saldototalreestructura),
			(abonomensualropa + abonomensualmuebles + abonomensualprestamos + abonomensualaire + abonomensualafiliados + abonomensualreestructura)
			INTO iSald_TotCoppel, iMont_PagCoppel
			FROM bdisolic:"informix".ss_resum_scor_fin
			WHERE num_solicitud = pNumSol;

			LET dGc_saldoactual_coppel = iSald_TotCoppel;
			LET dGc_montopagar_coppel = iMont_PagCoppel;

			-- vTipo_colectivo (Enviar vacio en el retorno) -- Se Obtiene
			LET vTipo_colectivo = '';

			-- dReestructuras -- Se obtiene (ambientar para tres clientes)
			LET iConteo = 0;

			SELECT COUNT(*) INTO iConteo
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_producto IN ('6011', '8600')
			AND numcte = cNumCteBco
			AND status_solicitud = 'AP';							   
			
			LET dReestructuras = iConteo;		-- Verificar solicitudes o Creditos

			-- dIdentificacion_falsa -- Se Obtiene en la validacion del INE
			-- (En la linea 1546 ya estas asignando el valor para la bandera de identificacion falsa.)

			-- dQuebranto (0 y 1 dependiendo si se rechaza)  (iSumpp + iSumtdc);
			LET iSumpp = 0;
			LET iSumtdc = 0;

			SELECT MAX(A.mto_fin_ven_trasp) INTO iSumpp
			FROM bdicred:"informix".sd_maesdoscrd A 
			inner join bdicred:"informix".sd_maecredcrd B on (A.num_credito = B.num_credito)
			WHERE B.empresa = pEmpresa
			AND B.numcte = cNumCteBco 
			AND B.status_cred IN ('E1', 'E2', 'E3');

			-- Quebranto TDC
			SELECT MAX(C.mto_fin_ven_trasp) INTO iSumtdc
			FROM bdicred:"informix".sd_maesdos C 
			inner join bdicred:"informix".sd_maecred D on (C.num_credito = D.num_credito)
			WHERE D.empresa = pEmpresa
			AND D.numcte = cNumCteBco 
			AND D.status_cred IN ('E1', 'E2', 'E3');

			IF iSumpp >= 8 THEN
    			
				LET dQuebranto = 1;
			
			ELIF iSumtdc >= 8 THEN
    		
				LET dQuebranto = 1;
			
			ELSE    
    		
				LET dQuebranto = 0;
			
			END IF;			
			
			-- dPromedio_ingresom_ult4d -- Se Obtiene dFechaIni
			SELECT fecha_insert INTO dtFech_Solic
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_solicitud = pNumSol AND empresa = pEmpresa;
			
			--EMPIEZA promedio y continuidad **********************
			
			WHILE iAuxCont <= 24 --Meses
			
				LET iAuxCont = iAuxCont + 1;
				LET dMontoTotAux = 0;
				
				EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFech_Solic, -iAuxCont) 
				INTO dtFechaSolicitudAux; 
				
				LET dFechaIni =  MDY(MONTH(dtFechaSolicitudAux), 1, YEAR(dtFechaSolicitudAux));
				LET dFechaFin =  LAST_DAY(dtFechaSolicitudAux);
					
				SELECT LIMIT 1 scm.fech_alt
					INTO dtFechaAuxContinuidad
					FROM bdicheq:"informix".sc_movhis AS scm
					INNER JOIN bdinteg:"informix".si_transacc AS sit ON scm.transacc = sit.numero
					WHERE scm.transacc in ('0293','0287') AND scm.cuenta = iCuentaCte 
					AND scm.fech_alt BETWEEN dFechaIni AND dFechaFin
					AND sit.descripcion = 'DEPOSITO POR PAGO DE NOMINA';	
				
				IF (dtFechaAuxContinuidad IS NULL) OR (dtFechaAuxContinuidad = '') THEN
					LET dContinuidad_depositos_nomina = dContinuidad_depositos_nomina||"0"; 
				ELSE
					LET dContinuidad_depositos_nomina = dContinuidad_depositos_nomina||"1"; 
				END IF;
				
				IF iAuxCont <= 4 THEN
				
					SELECT SUM(scm.monto_tot) 
					INTO dMontoTotAux
					FROM bdicheq:"informix".sc_movhis AS scm
					INNER JOIN bdinteg:"informix".si_transacc AS sit ON scm.transacc = sit.numero
					WHERE scm.transacc in ('0293','0287') AND scm.cuenta = iCuentaCte 
					AND scm.fech_alt BETWEEN dFechaIni AND dFechaFin
					AND sit.descripcion = 'DEPOSITO POR PAGO DE NOMINA';
				
					IF (dMontoTotAux IS NOT NULL) OR (dMontoTotAux > 0) THEN
						LET iMontoTotAux = iMontoTotAux + 1;
					ELSE 
						LET dMontoTotAux = 0;
					END IF;
				
					LET dPromedio_ingresom_ult4d = dPromedio_ingresom_ult4d + dMontoTotAux;
				
				END IF;	
			
			END WHILE;
			
			IF iMontoTotAux > 0 THEN
			
				LET dPromedio_ingresom_ult4d = dPromedio_ingresom_ult4d/iMontoTotAux;
				
				LET dPromedio_ingresom_ult4d = dPromedio_ingresom_ult4d/10000;
				
				LET dPromedio_ingresom_ult4d = ROUND(dPromedio_ingresom_ult4d,2);
				
				LET dPromedio_ingresom_ult4d = dPromedio_ingresom_ult4d*100;
				
			ELSE 
			
				LET dPromedio_ingresom_ult4d = 0;
			
			END IF;
			
			--TERMINA promedio y continuidad ***********************
			

			-- vObservacion_mc -- Se Obtiene 
			SELECT observaciones INTO vObserv_Sol 
			FROM bdisolic: ss_solicitudes_mc WHERE num_solicitud = pNumSol;

			LET vObservacion_mc = NVL(vObserv_Sol, '');
			
			-- QUEDAN 8 VARIABLES EMERGENTES POR POSIBLES CAMBIOS DEL BRM --
			LET vOrigeninput9 = '';

			LET vOrigeninput10 = '';

			LET vOrigeninput11 = '';

			LET vOrigeninput12 = '';

			LET Origeninput13 = 0;

			LET Origeninput14 = 0;

			LET Origeninput15 = 0;

			LET Origeninput16 = 0;

        END IF;
			
/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
			EXECUTE PROCEDURE bdisolic:"informix".cal_buen_pago(cNumCteBco,'0') INTO cCodRet, sBuenPagos;
			--BEGIN WORK;

			INSERT INTO bdisolic:"informix".ss_certif_evaluacion_cte_pp (cSolBanco_ss,cNumCteBco_ss,cStatusSolicitud_ss,iCtas_StatusDif_FF_6011,sCteLargo8,iMeses_hist_Val,sFlagHuella,
			iSolMc,iSolMcAux,iBanderareferencia,sFlagForzarEnvioMC,sCteLargo,iFlagEmpleado,cRTipo3,cVigSolOS,sBuenPagos,cCteProspVig,cEstado_ss,cMunicipio,cPuntualidadCoppel,
			dEficienciaCoppel_ss,cFechaUltimoPago_ss,iReprestamos_ss,cCteProsp,cStatusSol_CteProsp,vgrupoA,iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta,cNumSol_Os,cTipoSolOS,iExisteSolPP_ss,
			ictegrandata,  cfechaaut_grandata, cfechacons_grandata,corigeninput1,corigeninput2,
			corigeninput3,corigeninput4,corigeninput5,corigeninput6,corigeninput7,corigeninput8, fecha_insert) VALUES(
			cSolBanco,cNumCteBco,cStatusSolicitud,iCtas_StatusDif_FF_6011,sCteLargo8,iMeses_hist_Val,sFlagHuella,
			iSolMc,iSolMcAux,iBanderareferencia,sFlagForzarEnvioMC,sCteLargo,iFlagEmpleado,cRTipo3,cVigSolOS,sBuenPagos,cCteProspVig,cEstado,cMunicipio,cPuntualidadCoppel,
			dEficienciaCoppel,cFechaUltimoPago,iReprestamos,cCteProsp,cStatusSol_CteProsp,vgrupoA,iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta,cNumSol_Os,cTipoSolOS,iExisteSolPP,
			Ictegrandata,  fechaaut_grandata, fechacons_grandata,origeninput1,origeninput2,
			origeninput3,origeninput4,origeninput5,origeninput6,origeninput7,origeninput8,  current);	

			--MACM se modifica el nombre de algunas variables
			INSERT INTO bdisolic:"informix".ss_certif_evaluacion_buro_pp (cSolBanco_ss,cNumCteBco_ss,iMax_MOP_ss ,cInstCta_MayorMOP_ss ,dMonto_UDIS_MayorMOP_ss ,iMax_MOP_Hist_6m_ss ,
			cInstCta_MayorMOP_6m_ss ,dMontoUDIS_MM_6m_ss ,iMM_Histo_12m_ss ,cInstCta_MayorMOP_12m_ss ,dMontoUDIS_MM_12m_ss ,iNumCtasMOP_4_12m_ss ,iNumCtasMOP_5_12m_ss ,
			iNumCtasMOP_mayor5_12m_ss ,iMOP4_12mCon1o2_ss ,iMOP5_12mCon1o2_ss ,iMOPmayor5_12mCon1o2_ss ,dMontoUDIS_MM_Rech ,iNumCtasMOP_4_30m_ss ,iNumCtasMOP_5_30m_ss ,iNumCtasMOP_mayor5_30m_ss ,
			iCtasMOP_4_30mCon1o2_ss ,iCtasMOP_5_30mCon1o2_ss ,iCtasMOP_mayor5_30mCon1o2_ss ,iMM_Histo_30m_ss ,cInstCta_MM_30m_Rech_ss,dMotoUDIS_MM_30m_Rech_ss ,iNumCtas_ClvOb_ss ,dMontoUdis_ss ,
			cInstitucion_ss ,cClvObser_ss ,sBc_Score_ss ,vClvExclusionMasReciente_ss ,cInstitucionClvExclusionMasReciente_ss ,iCtas_SinComServ ,iCtas_SinComServ_pagar ,iNumCtas_SHBr ,iNumCtas_SHBr_pagar ,
			iMM_act_Bancos_ss ,	iMM_hist_alto_Bancos_ss ,iMM_hist_Bancos_ss ,iCtasBancosMOP_tl26 ,iCtasBancosMOP_tl38 ,iCtasBancosMOP_tl27 ,iCtasBancosMOP_act_hist_alto ,iCtasComServMOP_tl26 ,
			iCtasComServMOP_tl38 ,iCtasComServMOP_tl27 ,iCtasCSM_act_hist_alto ,iCtasComServMOP_tl26_12m ,iCtasComServMOP_tl38_12m ,iCtasComServMOP_tl27_12m ,
			iCtasCSM_ActHistAlto_12m ,dtFechaAux ,iMaxMOP_actBancos_ss  ,iMaxMOP_histAltBancos_ss ,iMaxMOP_histBancos_ss ,iMaxMOP_actCtas ,iMaxMOP_histAltCtas ,iMaxMOP_histCtas ,mPagoMinimo_ss ,sFlagBuenPago12_ss ,
			sFlagBuenPago30_ss ,NumCuentaPagoMinimo_ss ,dValor_3s ,iCtas_StatusDif_FF_6011 ,sCteLargo8 ,iMeses_hist_Val ,sFlagHuella ,iSolMc ,iSolMcAux ,iBanderareferencia ,sFlagForzarEnvioMC ,
			sCteLargo ,iFlagEmpleado ,cRTipo3 ,cVigSolOS ,sBuenPagos ,cCteProspVig ,vCtas_30_mas_atraso_hist_ss ,vSaldoMorHistAltaTL36_ss ,vNumTotalCtasTL13_ss ,vNumVecesTiendaComercial_ss ,
			vNumVecesBANCOPPEL_ss ,vMesesAperCtaAntiguaRev_ss ,vMesesAperCtaAntigua_ss ,vCtas_sin_historia_ss ,vCtas_al_corriente_ss ,vNumTotalCtas_ss ,vFechaTL37_ss ,iExisteBR_TL_mora_ss ,vSumSaldoActualTL22_ss ,
			vSumLimCredTL23_ss ,iNumCtasAper36_ss,	vCuentasPF_ss, fecha_insert) VALUES(
			cSolBanco,cNumCteBco,iMax_MOP ,cInstCta_MayorMOP ,dMonto_UDIS_MayorMOP ,iMax_MOP_Hist_6m ,
			cInstCta_MayorMOP_6m ,dMontoUDIS_MM_6m ,iMM_Histo_12m ,cInstCta_MayorMOP_12m ,dMontoUDIS_MM_12m ,iNumCtasMOP_4_12m ,iNumCtasMOP_5_12m ,iNumCtasMOP_mayor5_12m ,
			iMOP4_12mCon1o2 ,iMOP5_12mCon1o2 ,iMOPmayor5_12mCon1o2 ,dMontoUDIS_MM_Rech ,iNumCtasMOP_4_30m ,iNumCtasMOP_5_30m ,iNumCtasMOP_mayor5_30m ,iCtasMOP_4_30mCon1o2 ,
			iCtasMOP_5_30mCon1o2 ,iCtasMOP_mayor5_30mCon1o2 ,iMM_Histo_30m ,cInstCta_MM_30m_Rech,dMotoUDIS_MM_30m_Rech ,iNumCtas_ClvOb ,dMontoUdis ,cInstitucion ,cClvObser ,
			sBc_Score ,vClvExclusionMasReciente ,cInstitucionClvExclusionMasReciente ,iCtas_SinComServ ,iCtas_SinComServ_pagar ,iNumCtas_SHBr ,iNumCtas_SHBr_pagar ,iMM_act_Bancos ,
			iMM_hist_alto_Bancos ,iMM_hist_Bancos ,iCtasBancosMOP_tl26 ,iCtasBancosMOP_tl38 ,iCtasBancosMOP_tl27 ,iCtasBancosMOP_act_hist_alto ,iCtasComServMOP_tl26 ,
			iCtasComServMOP_tl38 ,iCtasComServMOP_tl27 ,iCtasCSM_act_hist_alto ,iCtasComServMOP_tl26_12m ,iCtasComServMOP_tl38_12m ,iCtasComServMOP_tl27_12m ,iCtasCSM_ActHistAlto_12m ,
			dtFechaAux ,iMaxMOP_actBancos  ,iMaxMOP_histAltBancos ,iMaxMOP_histBancos ,iMaxMOP_actCtas ,iMaxMOP_histAltCtas ,iMaxMOP_histCtas ,mPagoMinimo ,sFlagBuenPago12 ,
			sFlagBuenPago30 ,NumCuentaPagoMinimo ,dValor_3s ,iCtas_StatusDif_FF_6011 ,sCteLargo8 ,iMeses_hist_Val ,sFlagHuella ,iSolMc ,iSolMcAux ,iBanderareferencia ,sFlagForzarEnvioMC ,
			sCteLargo ,iFlagEmpleado ,cRTipo3 ,cVigSolOS ,sBuenPagos ,cCteProspVig ,vCtas_30_mas_atraso_hist ,vSaldoMorHistAltaTL36 ,vNumTotalCtasTL13 ,vNumVecesTiendaComercial ,
			vNumVecesBANCOPPEL ,vMesesAperCtaAntiguaRev ,vMesesAperCtaAntigua ,vCtas_sin_historia ,vCtas_al_corriente ,vNumTotalCtas ,vFechaTL37 ,iExisteBR_TL_mora ,vSumSaldoActualTL22 ,
			vSumLimCredTL23 ,iNumCtasAper36, vCuentasPF, current);

			-- COMMIT WORK;
			LET cNumCteBcoN = cNumCteBco;

			EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pEmpresa, cNumCteBco, pNumSol)
	            INTO cCodRet, v_respsic, dcompromisos, vMensaje;
			
			UPDATE bdisolic:"informix".ss_resum_scor_fin 
			set pago_minimo = dcompromisos
			WHERE empresa =  pEmpresa
			AND num_solicitud = pNumSol;
			
			EXECUTE PROCEDURE bdisolic:"informix".calulavariables_modelo2_pp (pEmpresa,pNumSol)
				INTO cCodRet, vTipoHitCalu, scoreCalu;
			
			SELECT count(num_solicitud)
			INTO v_valor_2s
			FROM bdisolic:"informix".ss_resumen_scoring
			WHERE num_solicitud = pNumsol
			AND seccion = 2;

			
			IF NVL(v_valor_2s,0) = 0 THEN
				--Se inserta valor de la seccion 2
				INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
				VALUES (pEmpresa, pNumSol, 2, scoreCalu);
			END IF;
			
			EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pEmpresa, pNumSol, '0')
				INTO cCodRet, GEN1, GEN2, GEN3;

			
			SELECT LIMIT 1 vmeses6_ss,vmeses12_ss,vmeses30_ss			
			INTO vmeses6,vmeses12,vmeses30			
			FROM bdisolic:"informix".ss_certif_evaluacion_buro_pp  
			WHERE cSolBanco_ss = pNumSol
			AND cNumCteBco_ss = cNumCteBcoN;
			
			--VALIDAR 12 meses
			
			let var_i = 0;
				for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) = 4) then
						LET iNumCtasMOP_4_12m = iNumCtasMOP_4_12m + 1;
					ELIF (substr(vmeses12,var_i,1) = 5) THEN
						LET iNumCtasMOP_5_12m = iNumCtasMOP_5_12m + 1;
					ELIF (substr(vmeses12,var_i,1) >5) THEN
						LET iNumCtasMOP_mayor5_12m = iNumCtasMOP_mayor5_12m + 1;		
					end if;					 
				End for; 
				
				
				let var_i = 0;
				for var_i = 1 to 6
					if(substr(vmeses12,var_i,1) in ('1','2')) then
						for var_j = 1 to 12 
							if (substr(vmeses12,var_i,1) = 4) then
								LET iMOP4_12mCon1o2 = iMOP4_12mCon1o2 + 1;
							end if;
							if (substr(vmeses12,var_i,1) = 5) THEN
								LET iMOP5_12mCon1o2 = iMOP5_12mCon1o2 + 1;
							end if;
							if (substr(vmeses12,var_i,1) >5) THEN
								LET iMOPmayor5_12mCon1o2 = iMOPmayor5_12mCon1o2 + 1;		
							end if;
						end for;
					end if;
				end for;
				
			
			--VALIDAR 30 meses
			
			 for var_i = 1 to 30
				if (substr(vmeses30,var_i,1) = 4) THEN
					LET iNumCtasMOP_4_30m = iNumCtasMOP_4_30m + 1;
				ELIF (substr(vmeses30,var_i,1) = 5) THEN
					LET iNumCtasMOP_5_30m = iNumCtasMOP_5_30m + 1;
				ELIF (substr(vmeses30,var_i,1) >5) THEN
					LET iNumCtasMOP_mayor5_30m = iNumCtasMOP_mayor5_30m + 1;		
				end if;	
			end for;
			LET var_i = 0;
			for var_i = 1 to 12
				if(substr(vmeses30,var_i,1) in ('1','2')) then
					for var_j = 1 to 30
						if (substr(vmeses30,var_i,1) = 4) THEN
							LET iCtasMOP_4_30mCon1o2 = iCtasMOP_4_30mCon1o2 + 1;
						end if;
						IF (substr(vmeses30,var_i,1) = 5) THEN
							LET iCtasMOP_5_30mCon1o2 = iCtasMOP_5_30mCon1o2 + 1;
						end if;
						IF (substr(vmeses30,var_i,1) >5) THEN
							LET iCtasMOP_mayor5_30mCon1o2 = iCtasMOP_mayor5_30mCon1o2 + 1;		
						end if;
					end for;
				end if;
			end for;
			
			LET iNumCtasMOP_4_12m = NVL(iNumCtasMOP_4_12m,0);
			LET iNumCtasMOP_5_12m = NVL(iNumCtasMOP_5_12m,0);
			LET iNumCtasMOP_mayor5_12m = NVL(iNumCtasMOP_mayor5_12m,0);
			LET iMOP4_12mCon1o2 = NVL(iMOP4_12mCon1o2,0);
			LET iMOP5_12mCon1o2 = NVL(iMOP5_12mCon1o2,0);
			LET iMOPmayor5_12mCon1o2 = NVL(iMOPmayor5_12mCon1o2,0);
			LET iNumCtasMOP_4_30m = NVL(iNumCtasMOP_4_30m,0);
			LET iNumCtasMOP_5_30m = NVL(iNumCtasMOP_5_30m,0);
			LET iNumCtasMOP_mayor5_30m = NVL(iNumCtasMOP_mayor5_30m,0);
			LET iCtasMOP_4_30mCon1o2 = NVL(iCtasMOP_4_30mCon1o2,0);
			LET iCtasMOP_5_30mCon1o2 = NVL(iCtasMOP_5_30mCon1o2,0);
			LET iCtasMOP_mayor5_30mCon1o2 = NVL(iCtasMOP_mayor5_30mCon1o2,0);
			
			--ACTUALIZAR LA INFORMACION EN LA TABLA DE CERTIFICACION
			UPDATE bdisolic:"informix".ss_certif_evaluacion_buro_pp
				SET iNumCtasMOP_4_12m_ss = iNumCtasMOP_4_12m,
					iNumCtasMOP_5_12m_ss = iNumCtasMOP_5_12m,
					iNumCtasMOP_mayor5_12m_ss = iNumCtasMOP_mayor5_12m,		
					iMOP4_12mCon1o2_ss = iMOP4_12mCon1o2,
					iMOP5_12mCon1o2_ss = iMOP5_12mCon1o2,
					iMOPmayor5_12mCon1o2_ss = iMOPmayor5_12mCon1o2,		
					iNumCtasMOP_4_30m_ss = iNumCtasMOP_4_30m,
					iNumCtasMOP_5_30m_ss = iNumCtasMOP_5_30m,
					iNumCtasMOP_mayor5_30m_ss = iNumCtasMOP_mayor5_30m,		
					iCtasMOP_4_30mCon1o2_ss = iCtasMOP_4_30mCon1o2,
					iCtasMOP_5_30mCon1o2_ss = iCtasMOP_5_30mCon1o2,
					iCtasMOP_mayor5_30mCon1o2_ss = iCtasMOP_mayor5_30mCon1o2
					WHERE cSolBanco_ss = pNumSol 
					AND cNumCteBco_ss = cNumCteBcoN;
					
			LET pNumSol = pNumSol;
            LET cNumCteBcoN = cNumCteBcoN;

			--MACM obtener informacion de la tabla de certificacion
			
			SELECT LIMIT 1 iMax_MOP_ss,cInstCta_MayorMOP_ss,dMonto_UDIS_MayorMOP_ss,iMax_MOP_Hist_6m_ss,cInstCta_MayorMOP_6m_ss,dMontoUDIS_MM_6m_ss,
			iMM_Histo_12m_ss,cInstCta_MayorMOP_12m_ss,dMontoUDIS_MM_12m_ss,iNumCtasMOP_4_12m_ss,iNumCtasMOP_5_12m_ss,iNumCtasMOP_mayor5_12m_ss,
			iMOP4_12mCon1o2_ss,iMOP5_12mCon1o2_ss,iMOPmayor5_12mCon1o2_ss,iCtasMOP_4_30mCon1o2_ss,iCtasMOP_5_30mCon1o2_ss,iCtasMOP_mayor5_30mCon1o2_ss,
			iMM_Histo_30m_ss,cInstCta_MM_30m_Rech_ss,dMotoUDIS_MM_30m_Rech_ss,iNumCtas_ClvOb_ss,dMontoUdis_ss,cInstitucion_ss,cClvObser_ss,vClvExclusionMasReciente_ss,
            cInstitucionClvExclusionMasReciente_ss,iNumCtasMOP_4_30m_ss,iNumCtasMOP_5_30m_ss,iNumCtasMOP_mayor5_30m_ss,iMM_act_Bancos_ss ,iMM_hist_alto_Bancos_ss ,
			vCuentasPF_ss ,vSumSaldoActualTL22_ss ,vSumLimCredTL23_ss ,vNumTotalCtas_ss ,vCtas_al_corriente_ss ,vCtas_sin_historia_ss ,vMesesAperCtaAntigua_ss ,
			vMesesAperCtaAntiguaRev_ss ,vNumVecesBANCOPPEL_ss ,vNumVecesTiendaComercial_ss,vNumTotalCtasTL13_ss ,vSaldoMorHistAltaTL36_ss ,vCtas_30_mas_atraso_hist_ss ,vFechaTL37_ss,
			sFlagBuenPago12_ss, sFlagBuenPago30_ss, NumCuentaPagoMinimo_ss, sBc_Score_ss, BCScorePP_ss, ScorePropietario_ss, iMM_hist_Bancos_ss, iMaxMOP_actBancos_ss, iMaxMOP_histAltBancos_ss,
			iMaxMOP_histBancos_ss, iExisteBR_TL_mora_ss, mPagoMinimo_ss, iNumCtasAper36_ss		
			INTO iMax_MOP,cInstCta_MayorMOP,dMonto_UDIS_MayorMOP,iMax_MOP_Hist_6m,cInstCta_MayorMOP_6m,dMontoUDIS_MM_6m,
			iMM_Histo_12m,cInstCta_MayorMOP_12m,dMontoUDIS_MM_12m,iNumCtasMOP_4_12m,iNumCtasMOP_5_12m,iNumCtasMOP_mayor5_12m,
			iMOP4_12mCon1o2,iMOP5_12mCon1o2,iMOPmayor5_12mCon1o2,iCtasMOP_4_30mCon1o2,iCtasMOP_5_30mCon1o2,iCtasMOP_mayor5_30mCon1o2,
			iMM_Histo_30m,cInstCta_MM_30m_Rech,dMotoUDIS_MM_30m_Rech,iNumCtas_ClvOb,dMontoUdis,cInstitucion,cClvObser,vClvExclusionMasReciente,
            cInstitucionClvExclusionMasReciente,iNumCtasMOP_4_30m,iNumCtasMOP_5_30m,iNumCtasMOP_mayor5_30m,iMM_act_Bancos ,iMM_hist_alto_Bancos , vCuentasPF ,vSumSaldoActualTL22 ,
			vSumLimCredTL23 ,vNumTotalCtas ,vCtas_al_corriente ,vCtas_sin_historia ,vMesesAperCtaAntigua ,
			vMesesAperCtaAntiguaRev ,vNumVecesBANCOPPEL ,vNumVecesTiendaComercial,vNumTotalCtasTL13 ,vSaldoMorHistAltaTL36 ,vCtas_30_mas_atraso_hist ,vFechaTL37,
			sFlagBuenPago12, sFlagBuenPago30, NumCuentaPagoMinimo, sBc_Score, BCScorePP, ScorePropietario, iMM_hist_Bancos, iMaxMOP_actBancos, iMaxMOP_histAltBancos,
			iMaxMOP_histBancos, iExisteBR_TL_mora, mPagoMinimo, iNumCtasAper36		
			FROM bdisolic:"informix".ss_certif_evaluacion_buro_pp  
			WHERE cSolBanco_ss = pNumSol
			AND cNumCteBco_ss = cNumCteBcoN;
			LET ScorePropietario = scoreCalu;
			
			--MACM obtener informacion de la tabla de certificacion
			SELECT LIMIT 1 cNumCte_ss, BC_101_ss, UT0034_ss, cOcupacion_ss, iTiem_Ocupacion_ss, cTipoResidencia_ss,  iTiem_Residencia_ss,  
			IQ0002_ss, vEficUltSem_ss, vMorAct_ss, vPorcUso_ss,	velemPuntualidad_ss, IQ00012_ss, iSumaTL13_ss, vMaxPlazoDias_ss, vSum_bal_ss,
			mAbonoMuebles_ss, mAbonoPrestamos_ss, mAbonoRopa_ss, dTasa_ss, cCompIngresos_ss, dIngresoCac_ss, dCompromisosCac_ss, sFlag_oro_ss, 
			mCompro_banco_ss, dComprobanco_TDC_ss, mCompro_bancoPP_ss, iCtas_StatusFF_6011_ss::INTEGER, dSalariomin_ss, dTasa_Ordinaria_ss, 
			dTasa_Moratoria_ss, diva_ss, dDiaspromedio_ss, dTope_ingre_ss, dMesespermitido_ss, dMinimomesespermitido_ss, cProfesion_ss, sId_actividad_ss, 
			sId_subactividad_ss, cDescAct_ss, vDescSubAct_ss, cSituacionEspecial_ss , sCausaSituacion_ss , dEficienciaCoppel_ss, sHist_meses_ss,
			mAbonoAire_ss, mAbonoAfiliados_ss, mAbonoReestructura_ss, mVencidoMuebles_ss, mVencidoRopa_ss, mVencidoAire_ss, mVencidoAfiliados_ss,
			mVencidoReestructura_ss, cOrigenSol_ss, cTipoGrupo_ss, mVencidoPrestamos_ss, dEficienciaCoppel_ss, mIngreso_Mensual_ss, mLinea_tienda_ss,
			mImporte_hip_ss, cHabita_en_ss, cCod_Ult_Identif_ss, cCurp_ss, dtUltimaCompra_ss, iCanal_Sol_ss, cOrigenCte_ss, sCompValido_ss, cTipo_movimiento_ss,
			mIngreso_Neto_ss, mSaldoRopa_ss, mSaldoMuebles_ss, mSaldoPrestamos_ss, pMeses_historia_grupo_ss, pSituacion_pago_grupo_ss, dPorcpermitido_ss,
			pFrecuencia_ss, iDiaPago_ss, cPuntualidadCoppel_ss, dtFechaCte_ss, cSexo_ss, cEdo_Civil_ss, cEscolaridad_ss, cEntidad_ss, iFlag2credito_ss, sEdadCte_ss,
			cEstado_ss, iExisteSolPP_ss, vSum_higcred_ss, cSucursal_ss, dtFechaNac_ss, dtFechaSolicitud_ss, capacidad_pres_ss, cFechaUltimoPago_ss, iReprestamos_ss,
			cStatusSolicitud_ss, cNum_Producto_ss, cTp_solicitud_ss
			INTO cNumCte, BC_101, UT0034, cOcupacion, iTiem_Ocupacion, cTipoResidencia,  iTiem_Residencia, 
			IQ0002, vEficUltSem, vMorAct, vPorcUso,	velemPuntualidad, IQ00012, iSumaTL13, vMaxPlazoDias, vSum_bal,
			mAbonoMuebles, mAbonoPrestamos,  mAbonoRopa, dTasa, cCompIngresos, dIngresoCac, dCompromisosCac, sFlag_oro, 
			mCompro_banco, dComprobanco_TDC, mCompro_bancoPP, iCtas_StatusFF_6011, dSalariomin, dTasa_Ordinaria, 
			dTasa_Moratoria, diva, dDiaspromedio, dTope_ingre, dMesespermitido, dMinimomesespermitido, cProfesion, sId_actividad, 
			sId_subactividad, cDescAct, vDescSubAct, cSituacionEspecial, sCausaSituacion , dEficienciaCoppel, sHist_meses,
			mAbonoAire, mAbonoAfiliados, mAbonoReestructura, mVencidoMuebles, mVencidoRopa, mVencidoAire, mVencidoAfiliados,
			mVencidoReestructura, cOrigenSol, cTipoGrupo, mVencidoPrestamos, dSituacionPagoCoppel, mIngreso_Mensual, mLinea_tienda, 
			mImporte_hip, cHabita_en, cCod_Ult_Identif, cCurp, dtUltimaCompra, iCanal_Sol, cOrigenCte, sCompValido, cTipo_movimiento,
			mIngreso_Neto, mSaldoRopa, mSaldoMuebles, mSaldoPrestamos, pMeses_historia_grupo, pSituacion_pago_grupo, dPorcpermitido,
			pFrecuencia, iDiaPago, cPuntualidadCoppel, dtFechaCte, cSexo, cEdo_Civil, cEscolaridad, cEntidad, iFlag2credito, sEdadCte,
			cEstado, iExisteSolPP, vSum_higcred, cSucursal, dtFechaNac, dtFechaSolicitud, capacidad_pres, cFechaUltimoPago, iReprestamos,
			cStatusSolicitud, cNum_Producto, cTp_solicitud			
			FROM bdisolic:"informix".ss_certif_evaluacion_cte_pp  
			WHERE cSolBanco_ss = pNumSol
			AND cNumCteBco_ss = cNumCteBcoN; -- order by fecha_insert desc;
			
			
			--SE VALIDA QUE EL NUM PRODUCTO SEA PRESTAMO DIRECTO DE NOMINA PARA INSERTAR EN LA TABLA ss_certif_evaluacion_cte_pp_2
			IF cNum_Producto = '6400' THEN
				
				INSERT INTO bdisolic:"informix".ss_certif_evaluacion_cte_pp_2(
				pnumsol_ss, pnumctebanco_ss, cproducto_ss, ingreso_ajustado_ss, mora_coppel_ss, saldo_vencido_coppel_ss,
				mora_bancoppel_ss, saldo_vencido_bancoppel_ss, tipo_transaccion_ss,	antiguedad_ss, hawk_ss, fraudes_ss,
				flag_creditopp_activo_ss, estabilidadvivienda_ss, rechazoos_ss, cn_sic_ss, lista_negra_ss, no_tramitedia_tdc_ss,
				no_tramitedia_pp_ss, sics_montopagar_revolvente_ss, sics_montopagar_norevolvente_ss, sics_saldoactual_revolvente_ss,
				sics_saldoactual_norevolvente_ss, gc_saldoactual_coppel_ss, gc_saldoactual_bancoppel_ss, gc_montopagar_coppel_ss,
				gc_montopagar_bancoppel_ss, tipo_colectivo_ss, reestructuras_ss, identificacion_falsa_ss, quebranto_ss,
				promedio_ingresom_ult4d_ss, continuidad_depositos_nomina_ss, tipo_empleado_code_ss,	tipo_empleado_name_ss,
				observacion_mc_ss, origeninput9_ss, origeninput10_ss, origeninput11_ss, origeninput12_ss,origeninput13_ss,
				origeninput14_ss, origeninput15_ss, origeninput16_ss, fecha_insert)
				VALUES(pNumSol, cNumCteBco, cNum_Producto, dIngreso_ajustado, iMora_coppel, iSaldo_vencido_coppel, iMora_bancoppel,
				iSaldo_vencido_bancoppel, vTipo_transaccion, iAntiguedad, iHawk, iFraudes, iFlag_creditopp_activo, iEstabilidadvivienda,
				iRechazoos, iCn_sic, iLista_negra, iNo_tramitedia_tdc, iNo_tramitedia_pp, dSics_montopagar_revolvente,
				dSics_montopagar_norevolvente, dSics_saldoactual_revolvente, dSics_saldoactual_norevolvente, dGc_saldoactual_coppel,
				dGc_saldoactual_bancoppel, dGc_montopagar_coppel, Gc_montopagar_bancoppel, vTipo_colectivo, dReestructuras,
				dIdentificacion_falsa, dQuebranto, dPromedio_ingresom_ult4d, dContinuidad_depositos_nomina, vTipo_empleado_code,
				vTipo_empleado_name, vObservacion_mc, vOrigeninput9, vOrigeninput10, vOrigeninput11, vOrigeninput12, Origeninput13,
				Origeninput14, Origeninput15, Origeninput16, CURRENT);
			
			END IF;

			-- iEstabilidadvivienda -- Se Obtiene
			LET iEstabilidadvivienda = iTiem_Residencia * 12;

			--MACM SE AGREGAN CALCULOS AL REGRESAR DE LOS SPS
			
			IF NVL(cSexo,'') = '' THEN
				SELECT sexo INTO cSexo 
				FROM bdinteg:si_ctepf 
				WHERE numcte = cNumCteBcoN;
				
				UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET sexo = cSexo 
                WHERE num_solicitud = pNumSol;						  
			END IF;
			
			IF NVL(sId_actividad,'') = '' THEN
                SELECT a.claveopcionpuesto
                INTO sId_actividad
                FROM bdinteg:"informix".si_ingresos a
                WHERE a.numcte = cNumCteBco
                AND a.tipo_ingreso='T'
                AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
                                    FROM bdinteg:"informix".si_ingresos b
                                    WHERE b.numcte=a.numcte
                                    AND b.tipo_ingreso='T');
                
                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad = sId_actividad 
                WHERE num_solicitud = pNumSol;
            END IF;

            IF NVL(sId_subactividad,'') = '' THEN
                SELECT a.clavesubopcionpuesto
                INTO sId_subactividad 
                FROM bdinteg:"informix".si_ingresos a
                WHERE a.numcte = cNumCteBco
                AND a.tipo_ingreso='T'
                AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
                                    FROM bdinteg:"informix".si_ingresos b
                                    WHERE b.numcte=a.numcte
                                    AND b.tipo_ingreso='T');

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET subactividad = sId_subactividad 
                WHERE num_solicitud = pNumSol;
            END IF;

            IF NVL(cDescAct,'') = '' THEN
                SELECT descrip
                INTO cDescAct
                FROM bdinteg:"informix".si_actsubact
                WHERE  id_subact = 0 
                AND id_act = sId_actividad;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad_descrip = cDescAct 
                WHERE num_solicitud = pNumSol;
            END IF;    

            EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cDescAct)
            INTO cDescAct;

            IF NVL(vDescSubAct,'') = '' THEN
                SELECT descrip
                INTO vDescSubAct
                FROM bdinteg:"informix".si_actsubact
                WHERE  id_subact = sId_subactividad AND id_act = sId_actividad;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad_descrip = vDescSubAct 
                WHERE num_solicitud = pNumSol;
            END IF;

            EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(vDescSubAct)
            INTO vDescSubAct;
			
						
			UPDATE bdisolic:"informix".ss_revision_determinacion 
			SET mto_pagos_bco  = mCompro_banco, pago_tdc = dComprobanco_TDC,
			pago_prest = mCompro_bancoPP, profesion  = cProfesion,
			abonomensualmuebles = mAbonoMuebles, abonomensualprestamos = mAbonoPrestamos,
			abonomensualropa = mAbonoRopa, abonomensualaire = mAbonoAire, 
			abonomensualafiliados = mAbonoAfiliados, abonomensualreestructura = mAbonoReestructura, 
			vencidomuebles = mVencidoMuebles, vencidoropa = mVencidoRopa,
			vencidoprestamos= mVencidoPrestamos, vencidototalaire= mVencidoAire, 
			vencidototalafiliados = mVencidoAfiliados, vencidototalreestructura = mVencidoReestructura,
			ctas_statusff_6011 = iCtas_StatusFF_6011, entidad = cEntidad,
			habita_en = cHabita_en, cod_ult_identif = cCod_Ult_Identif
			WHERE num_solicitud = pNumSol;
			
			--Se agrega las solicitudes con status CN y causa CCB, CGC para no avanzar de status.
            IF cStatusSolicitud = "CN" THEN
                      
                SELECT NVL(causa_solicitud,"")
                INTO cCausa_Sol 
                FROM bdisolic:"informix".ss_autorizacion 
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol
                AND status_solicitud = cStatusSolicitud;                      
                -- Solicitudes en CCB, CGC no deben de avanzar de status
    
            END IF;
			
			IF sBc_Score < 0 THEN
				LET sBc_Score = -1;
			ELIF sBc_Score IS NULL THEN
				LET sBc_Score = 0;             
			END IF;
			
			IF v_mod_parame <> 1 THEN
				
				LET v_valor_1s = sBc_Score;
				IF v_valor_1s < 0 THEN
					LET v_valor_1s = -1;
				ELIF v_valor_1s IS NULL THEN
					LET v_valor_1s=0;             
				END IF;
			END IF;
			
										
			IF v_respsic = 'X' THEN
	            LET v_valor_1s = -1;
				LET sBc_Score = -1;
				LET dValor_3s = 0;
			END IF;
			
			if cTp_solicitud  = 'P' then
       			EXECUTE PROCEDURE bdisolic:"informix".sp_validageneraos(pempresa, cNumCteBco,pNumSol,dtFechaHoyAUX) into  cCodRet, Validaos;
			end if;
			
			IF NVL(cSituacionEspecial,'') = '' THEN
            	SELECT situacion_credito
				INTO cSituacionEspecial	  
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE empresa =  pEmpresa
				AND num_solicitud = pNumSol;
			END IF;
			
			IF vMaxPlazoDias IS NULL THEN
				IF	(vCuentasPF > 0 AND vCuentasPF <=3) THEN 
					LET vMaxPlazoDias = -1;		--Nulo cuentas <=3
				ELIF (vCuentasPF > 3) THEN 
					LET vMaxPlazoDias = -1;	--Nulo cuentas > 3
				END IF;
			END IF;
			
			IF(vEficUltSem IS NOT NULL) THEN 
				--se agrega validacion para que no arroje el -99998 siempre
			ELSE
				IF vEficUltSem is null THEN
					LET vEficUltSem = -99999;			--Nulo 
				ELSE 
					LET vEficUltSem = -99998; --Cualquier otro caso
				END IF;
			END IF;
			
			IF(vMorAct IS NOT NULL) THEN 
				--se agrega validacion para que no arroje el -99998 siempre
			ELSE
				IF vMorAct is null THEN
					LET vMorAct = -99999;			--Nulo 
				ELSE 
					LET vMorAct = -99998; --Cualquier otro caso
				END IF;
			END IF;

			LET iMora_coppel = vMorAct;
						
			IF vMesesAperCtaAntigua is null THEN
				LET vMesesAperCtaAntigua = -1;
			END IF;
			
			IF(vSumSaldoActualTL22 = 0) THEN
    		    LET vSumSaldoActualTL22 = -1;
    		END IF;
						
			IF vMesesAperCtaAntiguaRev is null Then
				Let vMesesAperCtaAntiguaRev = -1;
			END IF;

			IF NVL(sEdadCte, 0 ) = 0 THEN
				EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, cNumCteBco) 
				INTO cCodRet, cNombreCte, sEdadCte;
			END IF;	
				
			IF cEdo_Civil is null then
				SELECT NVL(descripcion,'') --Estado Civil
				INTO cEdo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 3
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;	
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEdo_Civil)
				INTO cEdo_Civil;
			END IF;
			
			IF cEscolaridad IS NULL THEN
				SELECT descripcion --Escolaridad
				INTO cEscolaridad
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 21
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;	
	
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEscolaridad)
				INTO cEscolaridad;
			END IF;
			
			IF cTipoResidencia IS NULL THEN
				SELECT descripcion --Tipo residencia
                INTO cTipoResidencia
                FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
                WHERE d.grupo = 5
                AND e.grupo = d.grupo 
                AND e.elemento = d.elemento
                AND e.seccion = d.seccion 
                AND d.num_solicitud = pNumSol;
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cTipoResidencia)
				INTO cTipoResidencia;
			END IF;

			IF 	cOcupacion IS NULL THEN
				SELECT NVL(descripcion,'') 
                INTO cOcupacion
                FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
                WHERE d.grupo = 7
                AND e.grupo = d.grupo 
                AND e.elemento = d.elemento
                AND e.seccion = d.seccion 
                AND d.num_solicitud = pNumSol;
			
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cOcupacion)
				INTO cOcupacion;
            END IF;
			
			EXECUTE PROCEDURE bdinteg:sp_eliminaacentos(cEstado)
			into cEstado;
			
			UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_pp
			SET sId_actividad_ss = sId_actividad, sId_subactividad_ss = sId_subactividad, cDescAct_ss = cDescAct, vDescSubAct_ss = vDescSubAct,
			cSituacionEspecial_ss = cSituacionEspecial, vMaxPlazoDias_ss = vMaxPlazoDias, vEficUltSem_ss = vEficUltSem, vMorAct_ss = vMorAct,
			cEdo_Civil_ss = cEdo_Civil, cEscolaridad_ss = cEscolaridad, cTipoResidencia_ss = cTipoResidencia, cOcupacion_ss = cOcupacion, 
			dcompromisos_ss = dcompromisos, cSexo_ss = cSexo
			WHERE cSolBanco_ss = pNumSol
			AND cNumCteBco_ss = cNumCteBcoN;
			
			--MACM SE CAMBIAN LOS FORMATOS DE fecha
			
			IF cFechaUltimoPago IS NULL OR cFechaUltimoPago = '' OR cFechaUltimoPago = '1900-01-01' THEN
				LET cFechaUltimoPago = NVL(cFechaUltimoPago,'1900-01-01'); 			
			ELSE			
	                        LET dtDiaFF = SUBSTR(cFechaUltimoPago,1,2); 
				LET dtMesFF = SUBSTR(cFechaUltimoPago,4,2); 
				LET dtAnoFF = SUBSTR(cFechaUltimoPago,7,4); 
				LET cFechaUltimoPago = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			
			IF dtFechaCte IS NULL OR dtFechaCte = '' OR dtFechaCte = '1900-01-01' THEN
				LET dtFechaCte = NVL(dtFechaCte,'1900-01-01'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaCte::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaCte::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaCte::DATE), 4, '0');
				LET dtFechaCte = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			--30/06/2022 
			IF vFechaTL37 IS NULL OR vFechaTL37 = '' OR vFechaTL37 = '1900-01-01'  THEN
				LET vFechaTL37 = NVL(vFechaTL37,'1900-01-01'); 			
			ELSE
			        LET dtMesFF = SUBSTR(vFechaTL37,1,2); 
				LET dtDiaFF = SUBSTR(vFechaTL37,4,2); 
				LET dtAnoFF = SUBSTR(vFechaTL37,7,4); 
				LET vFechaTL37 = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;

			IF dtFechaNac IS NULL OR dtFechaNac = '' OR dtFechaNac = '1900-01-01' THEN
				LET dtFechaNac = NVL(dtFechaNac,'1900-01-01'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaNac::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaNac::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaNac::DATE), 4, '0');
				LET dtFechaNac = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;

			IF dtFechaSolicitud IS NULL OR dtFechaSolicitud = '' OR dtFechaSolicitud = '1900-01-01'  THEN
				LET dtFechaSolicitud = NVL(dtFechaSolicitud,'1900-01-01'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaSolicitud::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaSolicitud::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaSolicitud::DATE), 4, '0');
				LET dtFechaSolicitud = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;

			IF dtUltimaCompra IS NULL OR dtUltimaCompra = '' OR dtUltimaCompra = '1900-01-01'  THEN
				LET dtUltimaCompra = NVL(dtUltimaCompra,'1900-01-01'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtUltimaCompra::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtUltimaCompra::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtUltimaCompra::DATE), 4, '0');
				LET dtUltimaCompra = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			
			IF dtFecha_Respuesta IS NULL OR dtFecha_Respuesta = '' OR dtFecha_Respuesta = '1900-01-01' THEN
				LET dtFecha_Respuesta = NVL(dtFecha_Respuesta,'1900-01-01'); 			
			ELSE
			        LET dtDiaFF = LPAD(DAY(dtFecha_Respuesta::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFecha_Respuesta::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFecha_Respuesta::DATE), 4, '0');
				LET dtFecha_Respuesta = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			
			IF dtFechaHoy IS NULL OR dtFechaHoy = '' OR dtFechaHoy = '1900-01-01' THEN
				LET dtFechaHoy = NVL(dtFechaHoy,'1900-01-01'); 			
			ELSE
				LET dtDiaFF = LPAD(DAY(dtFechaHoy::DATE), 2, '0');
                LET dtMesFF = LPAD(MONTH(dtFechaHoy::DATE), 2, '0');
                LET dtAnoFF = LPAD(YEAR(dtFechaHoy::DATE), 4, '0');
				LET dtFechaHoy = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			
    END IF;
	
			IF 	dSics_montopagar_revolvente = '' THEN    
				LET dSics_montopagar_revolvente = '[0]';
			END IF;

			IF dSics_montopagar_norevolvente = '' THEN
				LET dSics_montopagar_norevolvente = '[0]';
			END IF;	
				
			IF	dSics_saldoactual_revolvente = '' THEN
				LET dSics_saldoactual_revolvente = '[0]';
			END IF;

			IF	dSics_saldoactual_norevolvente = '' THEN
				LET dSics_saldoactual_norevolvente = '[0]';
			END IF;
			
			RETURN  NVL(cCodRet,000000), NVL(cSolBanco,''),	NVL(cNumCteBco,''),	NVL(cNumCte,''), NVL(pEmpresa,''), 
			NVL(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cPuntualidadCoppel,''), NVL(cProfesion,''),
			NVL(sId_actividad,0), NVL(cDescAct,''), NVL(sId_subactividad,0), NVL(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), NVL(cMotivoRechBcpl,''), NVL(sHist_meses,0), NVL(dEficienciaCoppel,0), NVL(iCtas_StatusDif_FF_6011,0),
			NVL(cProducto,"????"), NVL(mAbonoMuebles,0), NVL(mAbonoPrestamos,0), NVL(mAbonoRopa,0),  NVL(mAbonoAire,0), NVL(mAbonoAfiliados,0),
			NVL(mAbonoReestructura,0), NVL(mVencidoMuebles,0), NVL(mVencidoRopa,0), NVL(mVencidoPrestamos,0), NVL(mVencidoAire,0), 
			NVL(mVencidoAfiliados,0), NVL(mVencidoReestructura,0), NVL(cFechaUltimoPago,'1900-01-01'), NVL(iReprestamos,0),
			NVL(cOrigenSol,'1'), NVL(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			NVL(cActRiesgoBCpl,''),	NVL(cDescpRiesgo,''), NVL(iMax_MOP,"0"), NVL(cInstCta_MayorMOP,''), 
			NVL(dMonto_UDIS_MayorMOP,0), NVL(iMax_MOP_Hist_6m,"0"), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,"0"), NVL(cInstCta_MayorMOP_12m,''),  NVL(dMontoUDIS_MM_12m,0), NVL(iNumCtasMOP_4_12m,0),
			NVL(iNumCtasMOP_5_12m,0), NVL(iNumCtasMOP_mayor5_12m,0), NVL(iMOP4_12mCon1o2,0), NVL(iMOP5_12mCon1o2,0),
			NVL(iMOPmayor5_12mCon1o2,0), NVL(cInstitucionMMOP_provocaRech,''), NVL(dMontoUDIS_MM_Rech,0), NVL(iNumCtasMOP_4_30m,0),
			NVL(iNumCtasMOP_5_30m,0), NVL(iNumCtasMOP_mayor5_30m,0), NVL(iCtasMOP_4_30mCon1o2,0), NVL(iCtasMOP_5_30mCon1o2,0),
			NVL(iCtasMOP_mayor5_30mCon1o2,0), NVL(iMM_Histo_30m,"0"), NVL(cInstCta_MM_30m_Rech,''), NVL(dMotoUDIS_MM_30m_Rech,0), 
			NVL(iNumCtas_ClvOb,"0"), NVL(dMontoUdis,0), NVL(cInstitucion,''), NVL(cClvObser,'0'), NVL(sBc_Score,0), 
			NVL(vClvExclusionMasReciente,0), NVL(cInstitucionClvExclusionMasReciente,''), NVL(iCtas_SinComServ,0),
			NVL(iCtas_SinComServ_pagar,0), NVL(iNumCtas_SHBr,0), NVL(iNumCtas_SHBr_pagar,0), /*NVL(BC1,-1),*/ NVL(BC_101,0), 
			NVL(iMM_act_Bancos,0), NVL(iMM_hist_alto_Bancos,'0'), NVL(iMM_hist_Bancos,"0"), NVL(iCtasBancosMOP_tl26,0),
			NVL(iCtasBancosMOP_tl38,0), NVL(iCtasBancosMOP_tl27,0), NVL(iCtasBancosMOP_act_hist_alto,0), 
			NVL(iCtasComServMOP_tl26,0), NVL(iCtasComServMOP_tl38,0), NVL(iCtasComServMOP_tl27,0), NVL(iCtasCSM_act_hist_alto,0),
			 NVL(iCtasComServMOP_tl26_12m,0), NVL(iCtasComServMOP_tl38_12m,0), NVL(iCtasComServMOP_tl27_12m,0), 
			NVL(iCtasCSM_ActHistAlto_12m,0),  NVL(dtFechaAux,'1900-01-01'),  NVL(iMaxMOP_actBancos,"0"), 
			NVL(iMaxMOP_histAltBancos,"0"), NVL(iMaxMOP_histBancos,"0"),   NVL(iMaxMOP_actCtas,"0"), NVL(iMaxMOP_histAltCtas,"0"),
			NVL(iMaxMOP_histCtas,"0"), NVL(dSituacionPagoCoppel,"0"), NVL(mIngreso_Mensual,0), NVL(mPagoMinimo,0), NVL(sCteLargo8,0),
			NVL(iMeses_hist_Val,0), NVL(cTipo_Alta_CteProsp,''), NVL(mLinea_tienda,0), NVL(mImporte_hip,0), NVL(dTasa,0),
			NVL(sFlagHuella,"0"), NVL(cResultadoOsTel,''), NVL(cTieneOstel,''), NVL(cEnvioCat,''), NVL(iSolMc,0),
			NVL(iSolMcAux,0), NVL(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,"0"), 
			NVL(dtUltimaCompra,'1900-01-01'), NVL(iBanderareferencia,"0"), NVL(dtFechaCte,'1900-01-01'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), NVL(iFlagGeoSuc,"0"), NVL(iCanal_Sol,"0"), NVL(cOrigenCte,''), NVL(sFlagForzarEnvioMC,""), 
			NVL(iSecuenciaOs,"0"), NVL(cStatusRespOs,''), NVL(dtFecha_Respuesta, '1900-01-01'), NVL(cNumSol_Os,''), NVL(cCompIngresos,''),
			NVL(dIngresoCac,0), NVL(sCompValido, 0), NVL(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), NVL(mIngreso_Neto,0), NVL(dtFechaNac,'1900-01-01'), NVL(cSexo,''),
			NVL(cEdo_Civil,''), NVL(iTiem_Edo_Civil,-99), NVL(UT0034,-999), NVL(cOcupacion,''),	NVL(iTiem_Ocupacion, -99), 
			NVL(cEscolaridad,''), NVL(cTipoResidencia,''), NVL(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,"0"), NVL(cCURP,''), NVL(iFlagEmpleado,"0"), NVL(dValor_3s,0),
			NVL(cStatusMovil,''), NVL(cCteProsp,''), NVL(cStatusSol_CteProsp,''), NVL(cRTipo3,''), NVL(cVigSolOS,''), NVL(sBuenPagos,'0'),
			NVL(dCompromisos,0), NVL(sFlagBuenPago12,"0"), NVL(sFlagBuenPago30,"0"), NVL(sEntidad_Localidad,"0"), NVL(cNuevoStatusOstel,''), 
			NVL(cCteProspVig,''), NVL(mCompro_banco,0), NVL(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), NVL(cGeoCte,''), NVL(iCanalV1,"99"), 
			NVL(IQ0002,"0.00"), NVL(iCtas_StatusFF_6011,0),	NVL(iTiem_Edo_Civil_meses, -99), NVL(iExisteCliente,0), NVL(mSaldoRopa,0), NVL(mSaldoMuebles,0), 
			NVL(mSaldoPrestamos,0), NVL(vgrupoA,''), NVL(NumSolMovil,''), NVL(iFlag2credito,0), NVL(NumCuentaPagoMinimo,0), NVL(dtFechaSolicitud, '1900-01-01'), 
			NVL(sEdadCte,0), NVL(pMeses_historia_grupo,0), NVL(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,0), NVL(Validaos,'0'), NVL(iNewMPP,""),
			NVL(vCuentasPF,"0"), NVL(BCScorePP,0), NVL(ScorePropietario,0), NVL(vEficUltSem,0), NVL(vMorAct,0), NVL(vPorcUso,0), NVL(velemPuntualidad,''),
			NVL(IQ00012,0), NVL(vSumSaldoActualTL22,0), NVL(vSumLimCredTL23,0), NVL(iParamincrDecr,""), NVL(iExisteSolPP,0), NVL(vNumTotalCtas,0), NVL(vCtas_al_corriente,0),
			NVL(vCtas_sin_historia,0), NVL(vMesesAperCtaAntigua,0), NVL(vMesesAperCtaAntiguaRev,0), NVL(vNumVecesBANCOPPEL,0), NVL(vNumVecesTiendaComercial,0), 
			NVL(vNumTotalCtasTL13,0), NVL(v_valor_1s,0), NVL(inumppf,0), NVL(mTasa_Interes,0), NVL(capacidad_pres,0), NVL(vSaldoMorHistAltaTL36,0), NVL(vCtas_30_mas_atraso_hist,0),
			NVL(iNumCtasAper36,0), NVL(TL37,'1900-01-01'), NVL(iExisteBR_TL_mora,'0'), NVL(vFechaTL37,'1900-01-01'), NVL(iSumaTL13,0), NVL(iFlag2credito2,""), NVL(iValorICC,""), NVL(vInstitucion,''),
			NVL(pFrecuencia,""), NVL(iDiaPago,""), NVL(vMaxPlazoDias,0), NVL(vFalloSic,"0"), NVL(dtFechaHoy,'1900-01-01'), NVL(vSum_bal,0), NVL(vSum_higcred,0),
			NVL(origeninput1,''), NVL(origeninput2,''), NVL(origeninput3,''), NVL(origeninput4,''), NVL(origeninput5,0), NVL(origeninput6,0), NVL(origeninput7,0), NVL(origeninput8,0),
			NVL(Ictegrandata,0), NVL(fechaaut_grandata,'1900-01-01'),NVL(fechacons_grandata,'1900-01-01'),
			-- EMPIEZAN VARIABLES DE RETORNO DE BRM 2025 --
			NVL(dIngreso_ajustado, 0.0), NVL(iMora_coppel, 0), NVL(iSaldo_vencido_coppel, 0), NVL(iMora_bancoppel, 0), NVL(iSaldo_vencido_bancoppel, 0), NVL(vTipo_transaccion, ''),
			NVL(iAntiguedad, 0), NVL(iHawk, 0), NVL(iFraudes, 0), NVL(iFlag_creditopp_activo, 0), NVL(iEstabilidadvivienda, 0), NVL(iRechazoos, 0), NVL(iCn_sic, 0), NVL(iLista_negra, 0),
			NVL(iNo_tramitedia_tdc, 0), NVL(iNo_tramitedia_pp, 0), NVL(dSics_montopagar_revolvente, '[0]'), NVL(dSics_montopagar_norevolvente, '[0]'), NVL(dSics_saldoactual_revolvente, '[0]'),
			NVL(dSics_saldoactual_norevolvente, '[0]'), NVL(dGc_saldoactual_coppel, 0.0), NVL(dGc_saldoactual_bancoppel, 0.0), NVL(dGc_montopagar_coppel, 0.0), NVL(Gc_montopagar_bancoppel, 0.0),
			NVL(vTipo_colectivo, ''), NVL(dReestructuras, 0.0), NVL(dIdentificacion_falsa, 0.0), NVL(dQuebranto, 0.0), NVL(dPromedio_ingresom_ult4d, 0.0), NVL(dContinuidad_depositos_nomina, 0.0),
			NVL(vTipo_empleado_code, ''), NVL(vTipo_empleado_name, ''), NVL(vObservacion_mc, ''), NVL(vOrigeninput9, ''), NVL(vOrigeninput10, ''), NVL(vOrigeninput11, ''), NVL(vOrigeninput12, ''),
			NVL(Origeninput13, 0), NVL(Origeninput14, 0), NVL(Origeninput15, 0), NVL(Origeninput16, 0);

END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea sp para armado de variables necesarias para motor de evaluacion prestamos personales',
'Modifico    : JAMQ',
'Fecha       : 01/08/2023',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica armado de variables en sp para motor de evaluacion prestamos personales',
'Modifico    : Vera Mariscal',
'Fecha       : 27/09/2023',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica sp para corregir el error productivo con temas en null en la respuesta de buro',
'Modifico    : Jose Angel Maya',
'Fecha       : 22/03/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agregan variables que se necesitan para el motor de evaluacion de prestamos personales MACM',
'Modifico    : Marco Antonio Cardenas Medina',
'Fecha       : 15/08/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agregan variables que se implementaran para el unificado anticipo de nomina y prestamo directo de nomina (BRM)',
'Modifico    : Carlos Abraham Velasco Nunez 97267953',
'Fecha       : 07/04/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_tabla_amortizacion_pp_web( pEmpresa CHAR(3),pNumCred CHAR(20),pSucursal CHAR(4), pSolicitudes INTEGER)

	RETURNING   CHAR(5)         AS Codigo, 		  	-- CODIGO DE RETORNO
				INTEGER         AS Periodo,       	-- PERIODO ACTUAL
				DATE            AS FechaCouta,	  	-- FECHA DEL PAGO
				MONEY(14,2)   	AS SaldoInicial,  	-- SALDO INICIAL
				DECIMAL(18,2)   AS Mensualidad,	  	-- MENSUALIDAD
				MONEY(14,2)   	AS Intereses,	  	-- INTERESES
				MONEY(14,2)  	AS IvaInteres,	  	-- IVA DE INTERESES
				DECIMAL(18,2)   AS Capital,		  	-- CAPITAL
				DECIMAL(18,2)   AS SaldoFinal,	  	-- SALDO FINAL
				INTEGER        	AS DiasPeriodo,	  	-- DIAS DEL PERIODO
				DATE            AS FechaAper,	  	-- FECHA DE APERTURA
				CHAR(3)         AS NumMesesPago,	-- NUMERO DE MESES PAGO
				DECIMAL(18,2)	AS MontoContratado,	-- MONTO CONTRATADO PARA PP Y/O ENGANCHE PAGADO DE LA RTC
				DECIMAL(18,2)	AS MontoTotalaPagar,-- MONTO TOTAL A PAGAR PARA PP Y RTC
				DECIMAL(18,2) 	AS TasaAnualFija,	-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
				DECIMAL(18,2)	AS TotalLiquida,	-- TOTAL LIQUIDACION PARA PP Y RTC
				DECIMAL(18,2) 	AS TeAhorrarias	;	-- MONTO TOTAL DEL AHORRO PARA PP Y RTC

	-- VARIABLES PARA RETORNO DE DATOS --
	DEFINE cCodRet     			CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
	DEFINE iPeriodo				INTEGER;			-- PERIODO ACTUAL PARA PP
	DEFINE iCicloRtc 			INTEGER;   			-- PERIODO ACTUAL PARA RTC
	DEFINE dtFechaCouta			DATE;				-- FECHA DEL PAGO PARA PP
	DEFINE dtFecha_Alta       	DATE;				-- FECHA DEL PAGO PARA RTC
	DEFINE dSdoInicial			MONEY(14,2);		-- SALDO INICIAL
	DEFINE dMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
	DEFINE dIntereses			MONEY(14,2);		-- INTERESES
	DEFINE dIvaInt				DECIMAL(14,2);		-- IVA DE INTERESES
	DEFINE dCapital				MONEY(14,2);		-- CAPITAL
	DEFINE dSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
	DEFINE iDiasPeriodo			INTEGER;			-- DIAS DEL PERIODO
	DEFINE dtFechaAper			DATE;				-- FECHA DE APERTURA
	DEFINE dPlazoAux      		DECIMAL(18,6);		-- NUMERO DE MESES PAGO
	DEFINE dMtoContrato      	DECIMAL(18,2);		-- MONTO CONTRATADO PARA PP
	DEFINE dEnganchePag      	DECIMAL(18,2);		-- ENGANCHE PAGADO DE LA RTC
	DEFINE dMtoTotalaPagar      DECIMAL(18,2);		-- MONTO TOTAL A PAGAR PARA PP Y RTC
	DEFINE cTasaFija      		CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTasaFija      		DECIMAL(18,2);		-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTotLiqpp 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA PRESTAMO
	DEFINE dTotLiqRtc 			DECIMAL(18,2);   	-- TOTAL LIQUIDACION PARA REESCTRUCTURA
	DEFINE dTotAhorro  			DECIMAL(18,2);		-- MONTO DE TE AHORRARIAS
	DEFINE cCadena1      		CHAR(3);
	DEFINE cCadena2      		CHAR(6);
	DEFINE cCadena3      		CHAR(6);
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	DEFINE iSqlErr      		INTEGER;			-- CODIGO DE ERROR
	DEFINE dTasa				DECIMAL(18,6);		-- TASA ANUAL
	DEFINE dTasa_Mora			DECIMAL(18,6);		-- TASA ANUAL MORATORIA	
	DEFINE iContador 			INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
	DEFINE cProducto     		CHAR(4);			-- NUMERO DEL PRODUCTO
	DEFINE dCapacidadPres		DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE
	DEFINE iDiaPago      		INTEGER;			-- DIA DE PAGO
	DEFINE iPagosRealizados 	INTEGER;			-- NUMERO DE PAGOS REALIZADO
	DEFINE dIva              	MONEY(14,2);		-- IVA DE SUCURSAL
	-- VARIABLES AUXILIARES PARA PRESTAMO
	DEFINE dtFechaInicial		DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
	DEFINE dtFechaAnt			DATE;				-- FECHA ANTERIOR DE COUTA
	DEFINE dTasaInt 			DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE dtFechaCoutaAux		DATE;				-- FECHA DEL PAGO AUXILIAR
	DEFINE cFrecuencia     		CHAR(1);			-- FECUENCIA DEL PAGO
	DEFINE dMontoAut 			DECIMAL(18,6); 		-- MONTO DEL CREDITO
	DEFINE dPlazo  	 			DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	DEFINE dtFechaIniRtc		DATE;				-- FECHA CUOTA DE LA PRIMERA MENSUALIDAD
	DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
	DEFINE dSobreTasa			DECIMAL(18,2);		-- TASA ANUAL
	DEFINE cDias_Cal_Int    	CHAR(10);			-- DIAS PARA EL CALCULO DE INTERESES
	DEFINE cFactor_SobreTasa 	CHAR(1);			-- FACTOR SOBRE TASA
	DEFINE dTasa_IntDiario      DECIMAL(10,6);		-- TASA DE INTERES DIARIO
	DEFINE dTasa_Interes    	DECIMAL(9,6);		-- TASA DE INTERES
	DEFINE sPlazoMax			SMALLINT;			-- PLAZO MAXIMO
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	DEFINE cCod_Ret2 			CHAR(5);			-- CODIGO DE RETORNO
	DEFINE cMensaje 			CHAR(80);  	  		-- MENSAJE DE RETORNO
	DEFINE cNumCred				CHAR(20); 	  		-- NUMERO DE CREDITO
	DEFINE cNumProd				CHAR(4); 	  		-- NUMERO DEL PRODUCTO
	DEFINE cDescProd			CHAR(40);      		-- DESCRIPCION DEL PRODUCTO
	DEFINE cNumCte				CHAR(20);      		-- NUMERO DE CLIENTE
	DEFINE cNomCte				CHAR(150);			-- NOMBRE DEL CLIENTE
	DEFINE dMtoLinea			DECIMAL(18,2);		-- MONTO DE LINEA OTORGADA
	DEFINE cStatus 				CHAR (60); 			-- ESATUS DEL CREDITO
	DEFINE dtProximo 			DATE;				-- FECHA DEL PROXIMO PAGO
	DEFINE dtFecha 				DATE; 				-- FECHA DEL PAGO
	DEFINE dSaldo				DECIMAL(18,2); 		-- SALDO DEL CREDITO
	DEFINE mInteres 			DECIMAL(18,2);   	-- INTERESES DEL CREDITO
	DEFINE dIvaInt2				DECIMAL(18,2);   	-- IVA DE INTERESES DEL CREDITO
	DEFINE mTotal 				DECIMAL(18,2);  	-- MONTO TOTAL DEL CREDITO
	DEFINE mPagos 				DECIMAL(18,2);      -- MONTO DE PAGO DEL CREDITO
	DEFINE mMinimo 				DECIMAL(18,2);   	-- MONTO DE PAGO MINIMO DEL CREDITO
	DEFINE mSaldar 				DECIMAL(18,2); 		-- MONTO DE TOTAL DE LIQUIDACION
	DEFINE dAhorro  			DECIMAL(18,2);		-- MONTO DE AHORRO DEL CREDITO
	DEFINE mDeuda 				DECIMAL(18,2);   	-- MONTO DE DEUDA DEL CREDITO
	DEFINE mPagReal				DECIMAL(18,2);   	-- MONTO DE PAGO REAL DEL CREDITO
	DEFINE mIntDeven			DECIMAL(18,2);   	-- INTERESES DEVENGADOS DEL CREDITO
	DEFINE dIvaIntDeven			DECIMAL(18,2);  	-- IVA DE INTERES DEVENGADOS DEL CREDITO
	DEFINE mComision 			DECIMAL(18,2);   	-- MONTO DE COMISION DEL CREDITO
	DEFINE mIvaCom 				DECIMAL(18,2);   	-- IVA DE COMISION DEL CREDITO
	DEFINE mMonto 				DECIMAL(18,2);   	-- MONTO DEL CREDITO
	DEFINE iPagos 				INTEGER;       		-- NUMERO DE PAGOS DEL CREDITO
	DEFINE iPlazo 				INTEGER;   			-- NUMERO DE PLAZOS DEL CREDITO
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS

	-- VARIABLES PARA RETORNO DE DATOS
	LET cCodRet     			= '00000';
	LET iPeriodo				= 0;
	LET iCicloRtc				= 0;
	LET dtFechaCouta			= DATE(1);
	LET dtFecha_Alta			= DATE(1);
	LET dSdoInicial				= 0;
	LET dMensualidad			= 0;
	LET dIntereses				= 0;
	LET dIvaInt					= 0;
	LET dCapital				= 0;
	LET dSdoFinal				= 0;
	LET iDiasPeriodo			= 0;
	LET dtFechaAper				= DATE(1);
	LET dPlazoAux      			= 0;
	LET dMtoContrato      		= 0;
	LET dEnganchePag			= 0;
	LET dMtoTotalaPagar      	= 0;
	LET dTasaFija				= 0;
	LET dTotLiqpp 				= 0;
	LET dTotLiqRtc 				= 0;
	LET dTotAhorro  			= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	LET iSqlErr      			= 0;
	LET dTasa					= 0;
	LET dTasa_Mora				= 0;
	LET iContador 				= 0;
	LET cProducto     			= '';
	LET dCapacidadPres			= 0;
	LET iDiaPago      			= 0;
	LET iPagosRealizados 		= 0;
	LET dIva              		= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO
	LET dtFechaInicial			= DATE(1);
	LET dtFechaAnt				= DATE(1);
	LET dTasaInt 				= DATE(1);
	LET dtFechaCoutaAux			= DATE(1);
	LET cFrecuencia     		= '';
	LET dMontoAut 				= 0;
	LET dPlazo  	 			= 0;
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	LET dtFechaActual			= DATE(1);
	LET dtFechaIniRtc			= DATE(1);
	LET dSobreTasa				= 0;
	LET cDias_Cal_Int    		= '';
	LET cFactor_SobreTasa 		= '';
	LET dTasa_IntDiario     	= 0;
	LET dTasa_Interes    		= 0;
	LET sPlazoMax				= 0;
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	LET cCod_Ret2 				= '00000';
	LET cMensaje 				= '';
	LET cNumCred				= '';
	LET cNumProd				= '';
	LET cDescProd				= '';
	LET cNumCte					= '';
	LET cNomCte					= '';
	LET dMtoLinea				= 0;
	LET cStatus 				= '';
	LET dtProximo 				= DATE(1);
	LET dtFecha 				= DATE(1);
	LET dSaldo					= 0;
	LET mInteres 				= 0;
	LET dIvaInt2				= 0;
	LET mTotal 					= 0;
	LET mPagos 					= 0;
	LET mMinimo 				= 0;
	LET mSaldar 				= 0;
	LET dAhorro  				= 0;
	LET mDeuda 					= 0;
	LET mPagReal				= 0;
	LET mIntDeven				= 0;
	LET dIvaIntDeven			= 0;
	LET mComision 				= 0;
	LET mIvaCom 				= 0;
	LET mMonto 					= 0;
	LET iPagos 					= 0;
	LET iPlazo 					= 0;
	LET cCodRetTDif				= '';

	BEGIN

		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
			END IF;
		END  EXCEPTION

		--SET DEBUG FILE TO '/tmp/sp_obtiene_tabla_amortizacion_pp_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO,
		--INCLUYE EL ENGANCHE PAGADO DE LA REESTRUCTURA
		SELECT plazo, periodo_plazo,fecha_apertura,num_producto,valor_preferencial,tasa_interes::CHAR(6)
		INTO dPlazo,cFrecuencia,dtFechaCouta,cProducto,dEnganchePag,cTasaFija
		FROM "informix".sd_maecredcrd
		WHERE empresa = pEmpresa AND num_credito = pNumCred
		--AND status_cred IN ('BA','BT','AA','VP');
		AND status_cred IN ('BA','BT','AA','VP','E1','E2','E3');   -- IFRS MACF

		IF NVL(cProducto,'') = '' THEN
			LET cCodRet = '01042';
			RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
				NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
				NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
		END IF;

		--SE TOMA COMO REFERENCIA LA FECHA DE APERTURA PARA PP
		LET dtFechaCoutaAux = dtFechaCouta;

		--SI ES CREDINOMINA RESPETA RESPETA LA FECHA ACTUAL
		SELECT fecha_hoy
		INTO dtFechaActual
		FROM "informix".sd_fechas
		WHERE empresa = pEmpresa ;

		-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
		SELECT  sdo_cap_insoluto,mto_capitalizado
		INTO  dSdoInicial,dMtoTotalaPagar
		FROM "informix".sd_maesdoscrd
		WHERE num_credito = pNumCred
		AND empresa = pEmpresa;

        SELECT monto_linea 
        INTO dSdoInicial
        FROM sd_linea_prestamo 
        WHERE num_credito=pNumCred;

		--NUMERO DE PAGOS REALIZADOS
		SELECT COUNT(num_credito)
		INTO iPagosRealizados
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCred
		AND capital_status = '5';

		-- SE OBTIENE EL I.V.A
		SELECT valor
		INTO dIva
		FROM "informix".sd_param
		WHERE empresa = '001'
		AND cod_param = '12';
	
		SELECT a.factor_sobretasa, a.sobretasa, plazo_max_cred
		INTO cFactor_SobreTasa,  dSobreTasa, sPlazoMax
		FROM "informix".sd_definicion a
		WHERE a.num_producto = cProducto;
		
		--EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pNumCred, '') INTO cCodRetTDif, dTasa, dTasa_Mora;
		LET dTasa = cTasaFija; -- Calculo de intereses diarios se hace en base a la tasa del credito ya que varia por credito.
		
		
		--MONTO DE LA MENSUALIDAD
		--OBTIENE LA FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
		SELECT capital_mto_cuota,fecha_cuota
		INTO dCapacidadPres,dtFechaIniRtc
		FROM "informix".sd_amortiza_creditocrd
		WHERE num_credito = pNumCred
		AND  num_pago = 1;

		--NO APLICA PARA PRESTAMO DIRECTO NOMINA
		IF TRIM(cProducto) <> '6400' THEN
			--CONSULTA EL MONTO TOTAL A PAGAR DE LA REESTRUCTURA Y EL SALDO DE TE AHORRARIAS
			EXECUTE PROCEDURE  "informix".sp_ofi_consultasdos(pEmpresa,pNumCred,pSucursal)
			INTO cCod_Ret2,cMensaje,cNumCred,cNumProd,cDescProd,cNumCte,cNomCte,dMtoLinea,dtFecha,dSaldo,mInteres,dIvaInt2,mTotal,mPagos,iPagos,
			iPlazo,dtProximo,mMinimo,mSaldar,dAhorro,mDeuda,mPagReal,mIntDeven,dIvaIntDeven,mComision,mIvaCom,mMonto,cStatus;

			--SI EXISTE ALGUN ERROR SE RETORNA EL CODIGO DEL PROCEDIMIENTO sp_ofi_consultasdos
			IF cCod_Ret2::INTEGER <> 0  THEN
				LET cCodRet = cCod_Ret2;
				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
			END IF;

			IF TRIM(cProducto) <> '6011' THEN
				--TOTAL LIQUIDACION PARA PRESTAMO PERSONAL
				LET dTotLiqpp = NVL(mTotal,0);
				--MONTO CONTRATADO
				LET dMtoContrato = NVL(dMtoLinea,0);
			END IF;
			
			IF TRIM(cProducto) = '6800' THEN
				--TOTAL LIQUIDACION PARA PRESTAMO PERSONAL
				LET dTotLiqpp = NVL(dMtoLinea,0);
				--MONTO CONTRATADO
				LET dMtoContrato = NVL(dMtoLinea,0);
			END IF;
			
			--TASA DE INTERES FIJA ANUAL
			IF NVL(cTasaFija,'') <> '' THEN
				LET cCadena1 = SUBSTR(cTasaFija, 0, INSTR(cTasaFija, '.')-1);
				LET cCadena2 = (cTasaFija - cCadena1); 
				LET cCadena2 = SUBSTR(cCadena2, 3, INSTR(cCadena2, '.'));
				LET cTasaFija = TRIM(cCadena1)  || '.' || TRIM(cCadena2);
				LET dTasaFija = NVL(TRIM(cTasaFija)::DECIMAL(18,2),0);
			END IF;
		ELSE
			-- LOS VALORES PARA TASA FIJAL ANUAL Y MONTO TOTAL A PAGAR
			-- NO APLICAN PARA CREDINOMINA
			LET dMtoTotalaPagar = 0;
			LET dTasaFija = 0;
		END IF;

		IF TRIM(cProducto) <> '6011' THEN

			LET dMontoAut = NVL(dSdoInicial,0);
			LET dPlazo = NVL(dPlazo,0) - NVL(iPagosRealizados,0);
			-- SE OBTIENE LA TASA ANUAL CON IVA
			LET dTasaInt = NVL(dTasa,0) / 100;
			LET dPlazoAux = NVL(dPlazo,0);

			IF cFrecuencia = 'M'  THEN --FRECUENCIA MENSUAL
				LET dPlazo = dPlazo * 1;
				LET iDiasPeriodo = 30;
			ELIF cFrecuencia = 'Q'  THEN --FRECUENCIA QUINCENAL
				LET dPlazo = dPlazo * 2;
				LET iDiasPeriodo = 15;
			END IF;

			LET dMensualidad = ROUND(dCapacidadPres,0);

			CALL "informix".monthadd(dtFechaCouta,iPagosRealizados) RETURNING dtFechaCouta;

			-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
			LET dtFechaInicial = dtFechaCouta;
			LET dtFechaAnt = dtFechaCouta;

			FOR iContador = 1 TO dPlazo  STEP 1

				-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO 
				--QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
				IF dSdoFinal > 0 THEN
					LET dSdoInicial = NVL(dSdoFinal,0);
				END IF;

				IF dSdoFinal <= 0 AND iContador > 1 THEN
					EXIT FOR;
				END IF;

				--SE OBTIENEN LOS MESES DEL PERIODO
				LET iPeriodo = NVL(iContador,0) + NVL(iPagosRealizados,0);

				-- ********************************************************************************************************************
				-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
				--*********************************************************************************************************************
				--PERIODO DE PAGO PARA CREDINOMINA
				IF TRIM(cProducto) <> '6400' THEN  
					--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
					CALL "informix".monthadd(dtFechaInicial,iContador) RETURNING dtFechaCouta;
					--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
					CALL "informix".monthadd(dtFechaInicial,iContador-1) RETURNING dtFechaAnt;

					--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
					--SE PASAN AL DIA SIGUIENTE
					IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
						LET dtFechaCouta = dtFechaCouta + 1;
					END IF;

					IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
						LET dtFechaAnt = dtFechaAnt + 1;
					END IF;

					IF iContador = 1 THEN
						IF NVL(iPagosRealizados,0 ) =0 THEN
							LET iDiasPeriodo = dtFechaCouta - dtFechaCoutaAux;
						ELSE
							LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
						END IF
					ELSE
						LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
					END IF;
				END IF;

				--SE CALCULAN LOS INTERESES
				LET dIntereses = NVL(dSdoInicial,0) * (NVL(dTasaInt,0) / 360) * NVL(iDiasPeriodo,0);
				-- SE CALCULA EL IVA DE LOS INTERESES
				LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

				IF dMontoAut < dMensualidad THEN
					LET dMensualidad = NVL(dMontoAut,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
					LET dCapital = NVL(dMontoAut,0);
				ELSE
					LET dCapital = NVL(dMensualidad,0) - (NVL(dIntereses,0) + NVL(dIvaInt,0));
					LET dIntereses = NVL(dIntereses,0) ;
					LET dIvaInt  = NVL(dIvaInt,0) ;
					LET iDiasPeriodo= NVL(iDiasPeriodo,0);
				END IF;

				-- SE CALCULA EL SALDO FINAL
				LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
				LET dMontoAut = NVL(dSdoInicial,0) - NVL(dCapital,0);
				--SUMA TOTAL DE TE AHORRARIAS

				--NO APLICA PARA PRESTAMO DIRECTO NOMINA
				IF TRIM(cProducto) <> '6400' THEN
					LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
				END IF;

				-- SE UTILIZA PARA PODER PAGINAR
				IF iContador <= pSolicitudes THEN
					CONTINUE FOR;
				END IF;

				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0) WITH RESUME;
			END FOR;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_obtiene_tabla_amortizacion_web( pEmpresa CHAR(3),pNumCred CHAR(20),pSucursal CHAR(4), pSolicitudes INTEGER)

	RETURNING   CHAR(5)         AS Codigo, 		  	-- CODIGO DE RETORNO
				INTEGER         AS Periodo,       	-- PERIODO ACTUAL
				DATE            AS FechaCouta,	  	-- FECHA DEL PAGO
				MONEY(18,2)   	AS SaldoInicial,  	-- SALDO INICIAL
				DECIMAL(18,2)   AS Mensualidad,	  	-- MENSUALIDAD
				MONEY(14,2)   	AS Intereses,	  	-- INTERESES
				MONEY(14,2)  	AS IvaInteres,	  	-- IVA DE INTERESES
				DECIMAL(18,2)   AS Capital,		  	-- CAPITAL
				DECIMAL(18,2)   AS SaldoFinal,	  	-- SALDO FINAL
				INTEGER        	AS DiasPeriodo,	  	-- DIAS DEL PERIODO
				DATE            AS FechaAper,	  	-- FECHA DE APERTURA
				CHAR(3)         AS NumMesesPago,	-- NUMERO DE MESES PAGO
				DECIMAL(18,2)	AS MontoContratado,	-- MONTO CONTRATADO PARA PP Y/O ENGANCHE PAGADO DE LA RTC
				DECIMAL(18,2)	AS MontoTotalaPagar,-- MONTO TOTAL A PAGAR PARA PP Y RTC
				DECIMAL(18,2) 	AS TasaAnualFija,	-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
				DECIMAL(18,2)	AS TotalLiquida,	-- TOTAL LIQUIDACION PARA PP Y RTC
				DECIMAL(18,2) 	AS TeAhorrarias	;	-- MONTO TOTAL DEL AHORRO PARA PP Y RTC

	-- VARIABLES PARA RETORNO DE DATOS --
	DEFINE cCodRet     			CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
	DEFINE iPeriodo				INTEGER;			-- PERIODO ACTUAL PARA PP
	DEFINE iCicloRtc 			INTEGER;   			-- PERIODO ACTUAL PARA RTC
	DEFINE dtFechaCouta			DATE;				-- FECHA DEL PAGO PARA PP
	DEFINE dtFecha_Alta       	DATE;				-- FECHA DEL PAGO PARA RTC
	DEFINE dSdoInicial			MONEY(18,6);		-- SALDO INICIAL
	DEFINE dMensualidad			DECIMAL(18,6);		-- MENSUALIDAD
	DEFINE dIntereses			MONEY(18,6);		-- INTERESES
	DEFINE dIvaInt				DECIMAL(18,6);		-- IVA DE INTERESES
	DEFINE dCapital				MONEY(18,6);		-- CAPITAL
	DEFINE dSdoFinal			DECIMAL(18,6);		-- SALDO FINAL
	DEFINE iDiasPeriodo			INTEGER;			-- DIAS DEL PERIODO
	DEFINE dtFechaAper			DATE;				-- FECHA DE APERTURA
	DEFINE dPlazoAux      		DECIMAL(18,6);		-- NUMERO DE MESES PAGO
	DEFINE dMtoContrato      	DECIMAL(18,6);		-- MONTO CONTRATADO PARA PP
	DEFINE dEnganchePag      	DECIMAL(18,6);		-- ENGANCHE PAGADO DE LA RTC
	DEFINE dMtoTotalaPagar      DECIMAL(18,6);		-- MONTO TOTAL A PAGAR PARA PP Y RTC
	DEFINE cTasaFija      		CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTasaFija      		DECIMAL(18,6);		-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
	DEFINE dTotLiqpp 			DECIMAL(18,6);   	-- TOTAL LIQUIDACION PARA PRESTAMO
	DEFINE dTotLiqRtc 			DECIMAL(18,6);   	-- TOTAL LIQUIDACION PARA REESCTRUCTURA
	DEFINE dTotAhorro  			DECIMAL(18,6);		-- MONTO DE TE AHORRARIAS
	DEFINE cCadena1      		CHAR(3);
	DEFINE cCadena2      		CHAR(6);
	DEFINE cCadena3      		CHAR(6);
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	DEFINE iSqlErr      		INTEGER;			-- CODIGO DE ERROR
	DEFINE dTasa				DECIMAL(18,6);		-- TASA ANUAL
	DEFINE dTasa_Mora			DECIMAL(18,6);		-- TASA ANUAL MORATORIA	
	DEFINE iContador 			INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
	DEFINE cProducto     		CHAR(4);			-- NUMERO DEL PRODUCTO
	DEFINE dCapacidadPres		DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE
	DEFINE iDiaPago      		INTEGER;			-- DIA DE PAGO
	DEFINE iPagosRealizados 	INTEGER;			-- NUMERO DE PAGOS REALIZADO
	DEFINE dIva              	MONEY(18,6);		-- IVA DE SUCURSAL
	-- VARIABLES AUXILIARES PARA PRESTAMO
	DEFINE dtFechaInicial		DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
	DEFINE dtFechaAnt			DATE;				-- FECHA ANTERIOR DE COUTA
	DEFINE dTasaInt 			DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE dtFechaCoutaAux		DATE;				-- FECHA DEL PAGO AUXILIAR
	DEFINE cFrecuencia     		CHAR(1);			-- FECUENCIA DEL PAGO
	DEFINE dMontoAut 			DECIMAL(18,6); 		-- MONTO DEL CREDITO
	DEFINE dPlazo  	 			DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	DEFINE dtFechaIniRtc		DATE;				-- FECHA CUOTA DE LA PRIMERA MENSUALIDAD
	DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
	DEFINE dSobreTasa			DECIMAL(18,6);		-- TASA ANUAL
	DEFINE cDias_Cal_Int    	CHAR(10);			-- DIAS PARA EL CALCULO DE INTERESES
	DEFINE cFactor_SobreTasa 	CHAR(1);			-- FACTOR SOBRE TASA
	DEFINE dTasa_IntDiario      DECIMAL(18,6);		-- TASA DE INTERES DIARIO
	DEFINE dTasa_Interes    	DECIMAL(18,6);		-- TASA DE INTERES
	DEFINE sPlazoMax			SMALLINT;			-- PLAZO MAXIMO
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	DEFINE cCod_Ret2 			CHAR(6);			-- CODIGO DE RETORNO
	DEFINE cMensaje 			CHAR(80);  	  		-- MENSAJE DE RETORNO
	DEFINE cNumCred				CHAR(20); 	  		-- NUMERO DE CREDITO
	DEFINE cNumProd				CHAR(4); 	  		-- NUMERO DEL PRODUCTO
	DEFINE cDescProd			CHAR(40);      		-- DESCRIPCION DEL PRODUCTO
	DEFINE cNumCte				CHAR(20);      		-- NUMERO DE CLIENTE
	DEFINE cNomCte				CHAR(150);			-- NOMBRE DEL CLIENTE
	DEFINE dMtoLinea			DECIMAL(18,6);		-- MONTO DE LINEA OTORGADA
	DEFINE cStatus 				CHAR (60); 			-- ESATUS DEL CREDITO
	DEFINE dtProximo 			DATE;				-- FECHA DEL PROXIMO PAGO
	DEFINE dtFecha 				DATE; 				-- FECHA DEL PAGO
	DEFINE dSaldo				DECIMAL(18,6); 		-- SALDO DEL CREDITO
	DEFINE mInteres 			DECIMAL(18,6);   	-- INTERESES DEL CREDITO
	DEFINE dIvaInt2				DECIMAL(18,6);   	-- IVA DE INTERESES DEL CREDITO
	DEFINE mTotal 				DECIMAL(18,6);  	-- MONTO TOTAL DEL CREDITO
	DEFINE mPagos 				DECIMAL(18,6);      -- MONTO DE PAGO DEL CREDITO
	DEFINE mMinimo 				DECIMAL(18,6);   	-- MONTO DE PAGO MINIMO DEL CREDITO
	DEFINE mSaldar 				DECIMAL(18,6); 		-- MONTO DE TOTAL DE LIQUIDACION
	DEFINE dAhorro  			DECIMAL(18,6);		-- MONTO DE AHORRO DEL CREDITO
	DEFINE mDeuda 				DECIMAL(18,6);   	-- MONTO DE DEUDA DEL CREDITO
	DEFINE mPagReal				DECIMAL(18,6);   	-- MONTO DE PAGO REAL DEL CREDITO
	DEFINE mIntDeven			DECIMAL(18,6);   	-- INTERESES DEVENGADOS DEL CREDITO
	DEFINE dIvaIntDeven			DECIMAL(18,6);  	-- IVA DE INTERES DEVENGADOS DEL CREDITO
	DEFINE mComision 			DECIMAL(18,6);   	-- MONTO DE COMISION DEL CREDITO
	DEFINE mIvaCom 				DECIMAL(18,6);   	-- IVA DE COMISION DEL CREDITO
	DEFINE mMonto 				DECIMAL(18,6);   	-- MONTO DEL CREDITO
	DEFINE iPagos 				INTEGER;       		-- NUMERO DE PAGOS DEL CREDITO
	DEFINE iPlazo 				INTEGER;   			-- NUMERO DE PLAZOS DEL CREDITO
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS

	-- VARIABLES PARA RETORNO DE DATOS
	LET cCodRet     			= '00000';
	LET iPeriodo				= 0;
	LET iCicloRtc				= 0;
	LET dtFechaCouta			= DATE(1);
	LET dtFecha_Alta			= DATE(1);
	LET dSdoInicial				= 0;
	LET dMensualidad			= 0;
	LET dIntereses				= 0;
	LET dIvaInt					= 0;
	LET dCapital				= 0;
	LET dSdoFinal				= 0;
	LET iDiasPeriodo			= 0;
	LET dtFechaAper				= DATE(1);
	LET dPlazoAux      			= 0;
	LET dMtoContrato      		= 0;
	LET dEnganchePag			= 0;
	LET dMtoTotalaPagar      	= 0;
	LET dTasaFija				= 0;
	LET dTotLiqpp 				= 0;
	LET dTotLiqRtc 				= 0;
	LET dTotAhorro  			= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO/REESTRUCTURA/CREDINOMINA
	LET iSqlErr      			= 0;
	LET dTasa					= 0;
	LET dTasa_Mora				= 0;
	LET iContador 				= 0;
	LET cProducto     			= '';
	LET dCapacidadPres			= 0;
	LET iDiaPago      			= 0;
	LET iPagosRealizados 		= 0;
	LET dIva              		= 0;
	-- VARIABLES AUXILIARES PARA PRESTAMO
	LET dtFechaInicial			= DATE(1);
	LET dtFechaAnt				= DATE(1);
	LET dTasaInt 				= DATE(1);
	LET dtFechaCoutaAux			= DATE(1);
	LET cFrecuencia     		= '';
	LET dMontoAut 				= 0;
	LET dPlazo  	 			= 0;
	-- VARIABLES AUXILIARES PARA REESTRUCTURA
	LET dtFechaActual			= DATE(1);
	LET dtFechaIniRtc			= DATE(1);
	LET dSobreTasa				= 0;
	LET cDias_Cal_Int    		= '';
	LET cFactor_SobreTasa 		= '';
	LET dTasa_IntDiario     	= 0;
	LET dTasa_Interes    		= 0;
	LET sPlazoMax				= 0;
	-- VARIABLES PARA EL PROCEDIMIENTO sp_ofi_consultasdos
	LET cCod_Ret2 				= '000000';
	LET cMensaje 				= '';
	LET cNumCred				= '';
	LET cNumProd				= '';
	LET cDescProd				= '';
	LET cNumCte					= '';
	LET cNomCte					= '';
	LET dMtoLinea				= 0;
	LET cStatus 				= '';
	LET dtProximo 				= DATE(1);
	LET dtFecha 				= DATE(1);
	LET dSaldo					= 0;
	LET mInteres 				= 0;
	LET dIvaInt2				= 0;
	LET mTotal 					= 0;
	LET mPagos 					= 0;
	LET mMinimo 				= 0;
	LET mSaldar 				= 0;
	LET dAhorro  				= 0;
	LET mDeuda 					= 0;
	LET mPagReal				= 0;
	LET mIntDeven				= 0;
	LET dIvaIntDeven			= 0;
	LET mComision 				= 0;
	LET mIvaCom 				= 0;
	LET mMonto 					= 0;
	LET iPagos 					= 0;
	LET iPlazo 					= 0;
	LET cCodRetTDif				= '';

	BEGIN

		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
			END IF;
		END  EXCEPTION

		--SET DEBUG FILE TO '/tmp/sp_obtiene_tabla_amortizacion.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO,
		--INCLUYE EL ENGANCHE PAGADO DE LA REESTRUCTURA
		SELECT plazo, periodo_plazo,fecha_apertura,
			num_producto,valor_preferencial,tasa_interes::CHAR(6)
		INTO dPlazo,cFrecuencia,dtFechaCouta,
			cProducto,dEnganchePag,cTasaFija
		FROM "informix".sd_maecredcrd
		WHERE empresa = pEmpresa AND num_credito = pNumCred
		--AND status_cred IN ('BA','BT','AA','VP');
		AND status_cred IN ('BA','BT','AA','VP','E1','E2','E3');   -- IFRS MACF

		IF NVL(cProducto,'') = '' THEN
			LET cCodRet = '01042';
			RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
				NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
				NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
		END IF;

		--SE TOMA COMO REFERENCIA LA FECHA DE APERTURA PARA PP
		LET dtFechaCoutaAux = dtFechaCouta;

		--SI ES CREDINOMINA RESPETA RESPETA LA FECHA ACTUAL
		SELECT fecha_hoy
		INTO dtFechaActual
		FROM "informix".sd_fechas
		WHERE empresa = pEmpresa ;

		-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
		SELECT  sdo_cap_insoluto,mto_capitalizado
		INTO  dSdoInicial,dMtoTotalaPagar
		FROM "informix".sd_maesdoscrd
		WHERE num_credito = pNumCred
		AND empresa = pEmpresa;

		--NUMERO DE PAGOS REALIZADOS
		SELECT COUNT(num_credito)
		INTO iPagosRealizados
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCred
		AND capital_status = '5';

		-- SE OBTIENE EL I.V.A
		SELECT valor
		INTO dIva
		FROM "informix".sd_param
		WHERE empresa = '001'
		AND cod_param = '12';

		-- SE OBTIENE LA TASA ANUAL
		/*SELECT c.valor,a.factor_sobretasa,a.sobretasa,plazo_max_cred
		INTO dTasa,cFactor_SobreTasa,dSobreTasa,sPlazoMax
		FROM "informix".sd_definicion a
		INNER JOIN bdinteg:"informix".si_fechavalor c
				ON (c.tasa = a.cod_tasa_base
				AND c.fecha = (SELECT MAX(r.fecha)
							FROM bdinteg:"informix".si_fechavalor r
							WHERE r.tasa = a.cod_tasa_base
							AND r.fecha = r.fecha
							AND r.empresa = a.empresa)
				AND c.empresa = a.empresa)
		WHERE a.num_producto = cProducto
		AND a.empresa = pEmpresa;*/
		
		SELECT a.factor_sobretasa, a.sobretasa, plazo_max_cred
		  INTO cFactor_SobreTasa,  dSobreTasa, sPlazoMax
		  FROM "informix".sd_definicion a
		 WHERE a.num_producto = cProducto;
		
		--EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pNumCred, '') INTO cCodRetTDif, dTasa, dTasa_Mora;
		LET dTasa = cTasaFija; -- Calculo de intereses diarios se hace en base a la tasa del credito ya que varia por credito.
		
		
		--MONTO DE LA MENSUALIDAD
		--OBTIENE LA FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
		SELECT capital_mto_cuota,fecha_cuota
		INTO dCapacidadPres,dtFechaIniRtc
		FROM "informix".sd_amortiza_creditocrd
		WHERE num_credito = pNumCred
		AND  num_pago = 1;

			--CONSULTA EL MONTO TOTAL A PAGAR DE LA REESTRUCTURA Y EL SALDO DE TE AHORRARIAS
			EXECUTE PROCEDURE  "informix".sp_ofi_consultasdos(pEmpresa,pNumCred,pSucursal)
			INTO cCod_Ret2,cMensaje,cNumCred,cNumProd,cDescProd,cNumCte,cNomCte,dMtoLinea,dtFecha,dSaldo,mInteres,dIvaInt2,mTotal,mPagos,iPagos,
			iPlazo,dtProximo,mMinimo,mSaldar,dAhorro,mDeuda,mPagReal,mIntDeven,dIvaIntDeven,mComision,mIvaCom,mMonto,cStatus;

			--SI EXISTE ALGUN ERROR SE RETORNA EL CODIGO DEL PROCEDIMIENTO sp_ofi_consultasdos
			IF cCod_Ret2::INTEGER <> 0  THEN
				LET cCodRet = cCod_Ret2;
				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
			END IF;

			IF TRIM(cProducto) = '6011' THEN
				--TOTAL LIQUIDACION PARA REESTRUCTURA
				LET dTotLiqRtc = NVL(mTotal,0);
				--MONTO TOTAL A PAGAR
				LET dMtoTotalaPagar = NVL(dMtoLinea,0);
			ELSE
				--TOTAL LIQUIDACION PARA PRESTAMO PERSONAL
				LET dTotLiqpp = NVL(mTotal,0);
				--MONTO CONTRATADO
				LET dMtoContrato = NVL(dMtoLinea,0);
			END IF;
			
			
			--TASA DE INTERES FIJA ANUAL
			IF NVL(cTasaFija,'') <> '' THEN
				LET cCadena1 = SUBSTR(cTasaFija, 0, INSTR(cTasaFija, '.')-1);
				LET cCadena2 = (cTasaFija - cCadena1); 
				LET cCadena2 = SUBSTR(cCadena2, 3, INSTR(cCadena2, '.'));
				LET cTasaFija = TRIM(cCadena1)  || '.' || TRIM(cCadena2);
				LET dTasaFija = NVL(TRIM(cTasaFija)::DECIMAL(18,2),0);
			END IF;


		IF TRIM(cProducto) = '6011' THEN

			--DIAS PARA EL CALCULO DE LOS INTERESES
			SELECT valor
			INTO cDias_Cal_Int
			FROM "informix".sd_param
			WHERE empresa = '001'
			AND cod_param = '24';

			--CALCULO PARA LA TASA DE INTERES DIARIO
			LET dTasa_Interes = NVL(dTasa,0);
			LET dTasa_IntDiario = ROUND((dTasa_Interes/cDias_Cal_Int)/100,8);
			--FECHA CUOTA PARA LA PRIMERA MENSUALIDAD
			LET dtFecha_Alta = dtFechaIniRtc;

			IF NVL(iPagosRealizados,0) > 0 then
				--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
				CALL "informix".monthadd(dtFechaIniRtc,NVL(iPagosRealizados,0)) RETURNING dtFecha_Alta;
				--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
				CALL "informix".monthadd(dtFechaIniRtc,NVL(iPagosRealizados,0)-1) RETURNING dtFechaActual;
			END IF;

			LET iCicloRtc = NVL(iPagosRealizados,0);

			WHILE iCicloRtc < sPlazoMax and dSdoInicial <> 0

				LET iCicloRtc = NVL(iCicloRtc,0) + 1;

				--CALCULO DE LOS DIAS DE PERIODO
				IF iCicloRtc = 1 THEN
					LET iDiasPeriodo = dtFecha_Alta - dtFechaCoutaAux;
				ELSE
					LET iDiasPeriodo = dtFecha_Alta - dtFechaActual;
				END IF;

				--SE CALCULAN LOS INTERESES POR DIA
				LET dIntereses = ROUND(NVL(dSdoInicial,0) * NVL(dTasa_IntDiario,0) ,2);
				--SE CALCULAN LOS INTERES POR LOS DIAS DEL PERIODO
				LET dIntereses = ROUND(NVL(dIntereses,0) * NVL(iDiasPeriodo,0),2);
				--SE CALCULA EL IVA DE LOS INTERESES
				LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

				--SI LOS INTERESES SON NEGATIVOS TERMINA EL CICLO
				IF dIntereses < 0 THEN
					EXIT WHILE;
				END IF;

				--CALCULO PARA EL MONTO DE CAPITAL
				LET dCapital = NVL(dCapacidadPres,0) - NVL(dIntereses,0) - NVL(dIvaInt,0) ;
				IF dCapital > dSdoInicial then
					LET dCapital = NVL(dSdoInicial,0);
				END IF
				--CALCULO PARA EL MONTO DE MENSUALIDAD
				LET dMensualidad = NVL(dCapital,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
				-- SE CALCULA EL SALDO FINAL
				LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
				--SUMA TOTAL DE TE AHORRARIAS
				LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);

				LET iContador =  NVL(iContador,0) + 1;
				IF iContador > pSolicitudes THEN
					RETURN NVL(cCodRet,''), NVL(iCicloRtc,0), NVL(dtFecha_Alta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0),
					NVL(dIvaInt,0), NVL(dCapital,0), NVL(dSdoFinal,0),NVL(iDiasPeriodo,0), NVL(dtFecha_Alta,DATE(1)), NVL(iCicloRtc,0),
					NVL(dEnganchePag,0),NVL(dMtoTotalaPagar,0),	NVL(dTasaFija,0),NVL(dTotLiqRtc,0),NVL(dTotAhorro,0) WITH RESUME;
				END IF;
				LET dtFechaActual = dtFecha_Alta;
				LET dtFecha_Alta = dtFecha_Alta + 1 UNITS MONTH;
				LET dSdoInicial = NVL(dSdoInicial,0) - NVL(dCapital,0);

				IF dSdoInicial <= 0 then
					LET dSdoInicial = 0;
				END IF;
			END WHILE

		ELSE

			LET dMontoAut = NVL(dSdoInicial,0);
			LET dPlazo = NVL(dPlazo,0) - NVL(iPagosRealizados,0);
			-- SE OBTIENE LA TASA ANUAL CON IVA
			LET dTasaInt = NVL(dTasa,0) / 100;
			LET dPlazoAux = NVL(dPlazo,0);

			IF cFrecuencia = 'M'  THEN --FRECUENCIA MENSUAL
				LET dPlazo = dPlazo * 1;
				LET iDiasPeriodo = 30;
			ELIF cFrecuencia = 'Q'  THEN --FRECUENCIA QUINCENAL
				LET dPlazo = dPlazo * 2;
				LET iDiasPeriodo = 15;
			END IF;

			LET dMensualidad = ROUND(dCapacidadPres,0);

			CALL "informix".monthadd(dtFechaCouta,iPagosRealizados) RETURNING dtFechaCouta;

			-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
			LET dtFechaInicial = dtFechaCouta;
			LET dtFechaAnt = dtFechaCouta;

			FOR iContador = 1 TO dPlazo  STEP 1

				-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO 
				--QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
				IF dSdoFinal > 0 THEN
					LET dSdoInicial = NVL(dSdoFinal,0);
				END IF;

				IF dSdoFinal <= 0 AND iContador > 1 THEN
					EXIT FOR;
				END IF;

				--SE OBTIENEN LOS MESES DEL PERIODO
				LET iPeriodo = NVL(iContador,0) + NVL(iPagosRealizados,0);

				-- ********************************************************************************************************************
				-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
				--*********************************************************************************************************************
				--PERIODO DE PAGO PARA CREDINOMINA
				IF TRIM(cProducto) = '6400' THEN  
					--SE OBTIENE LA FECHA DE LA PROXIMA FECHA CUOTA
					EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dtFechaCouta,pNumCred)
					INTO cCodRet,dtFechaCouta,iDiaPago;

					IF cCodRet::INTEGER <> 0  THEN
						LET cCodRet = '01032';	-- OCURRIO UN ERROR PARA LA FECHA DE PAGO DE CREDINOMINA
						RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
							NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
							NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0);
					END IF;

					--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
					--SE PASAN AL DIA SIGUIENTE
					IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
						LET dtFechaCouta = dtFechaCouta + 1;
					END IF;
					IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
						LET dtFechaAnt = dtFechaAnt + 1;
					END IF;

					--SE OBTIENEN LOS DIAS DEL PERIODO
					LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
					LET dtFechaAnt = dtFechaCouta;

				ELSE
					--OBTIENE LA FECHA DE LA SIGUIENTE FECHA DE PAGO
					CALL "informix".monthadd(dtFechaInicial,iContador) RETURNING dtFechaCouta;
					--OBTIENE LA FECHA DE LA FECHA DE PAGO ANTERIOR
					CALL "informix".monthadd(dtFechaInicial,iContador-1) RETURNING dtFechaAnt;

					--SI LA FECHA CUOTA O FECHA ANTERIOS ESTAN ENTRE LOS DIAS FESTIVOS 1 DE ENERO Y 25 DE DICIEMBRE
					--SE PASAN AL DIA SIGUIENTE
					IF (MONTH(dtFechaCouta) = 1 AND DAY(dtFechaCouta) = 1) OR (MONTH(dtFechaCouta) = 12 AND DAY(dtFechaCouta) = 25) THEN
						LET dtFechaCouta = dtFechaCouta + 1;
					END IF;

					IF (MONTH(dtFechaAnt) = 1 AND DAY(dtFechaAnt) = 1) OR (MONTH(dtFechaAnt) = 12 AND DAY(dtFechaAnt) = 25) THEN
						LET dtFechaAnt = dtFechaAnt + 1;
					END IF;

					IF iContador = 1 THEN
						IF NVL(iPagosRealizados,0 ) =0 THEN
							LET iDiasPeriodo = dtFechaCouta - dtFechaCoutaAux;
						ELSE
							LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
						END IF
					ELSE
						LET iDiasPeriodo = dtFechaCouta - dtFechaAnt;
					END IF;
				END IF;

				--SE CALCULAN LOS INTERESES
				LET dIntereses = NVL(dSdoInicial,0) * (NVL(dTasaInt,0) / 360) * NVL(iDiasPeriodo,0);
				-- SE CALCULA EL IVA DE LOS INTERESES
				LET dIvaInt = ROUND(NVL(dIntereses,0) * NVL(dIva,0),2);

				IF dMontoAut < dMensualidad THEN
					LET dMensualidad = NVL(dMontoAut,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
					LET dCapital = NVL(dMontoAut,0);
				ELSE
					LET dCapital = NVL(dMensualidad,0) - (NVL(dIntereses,0) + NVL(dIvaInt,0));
					LET dIntereses = NVL(dIntereses,0) ;
					LET dIvaInt  = NVL(dIvaInt,0) ;
					LET iDiasPeriodo= NVL(iDiasPeriodo,0);
				END IF;

				-- SE CALCULA EL SALDO FINAL
				LET dSdoFinal = NVL(dSdoInicial,0) - NVL(dCapital,0);
				LET dMontoAut = NVL(dSdoInicial,0) - NVL(dCapital,0);
				--SUMA TOTAL DE TE AHORRARIAS

				--NO APLICA PARA PRESTAMO DIRECTO NOMINA
				IF TRIM(cProducto) <> '6400' THEN
					LET dTotAhorro = NVL(dTotAhorro,0) + NVL(dIntereses,0) + NVL(dIvaInt,0);
				END IF;

				-- SE UTILIZA PARA PODER PAGINAR
				IF iContador <= pSolicitudes THEN
					CONTINUE FOR;
				END IF;

				RETURN NVL(cCodRet,''), NVL(iPeriodo,0), NVL(dtFechaCouta,DATE(1)), NVL(dSdoInicial,0), NVL(dMensualidad,0), NVL(dIntereses,0), NVL(dIvaInt,0),
					NVL(dCapital,0), NVL(dSdoFinal,0), NVL(iDiasPeriodo,0), NVL(dtFechaAper,DATE(1)), NVL(dPlazoAux,0),NVL(dMtoContrato,0),NVL(dMtoTotalaPagar,0),
					NVL(dTasaFija,0),NVL(dTotLiqpp,0),NVL(dTotAhorro,0) WITH RESUME;
			END FOR;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'MODIFICO: 95358897 - ISARAI BOJORQUEZ',
'MODIFICACION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LOS MONTOS DE AHORRO,TASA DE INTERES Y TOTAL LIQUIDACION,',
'DE UN PRESTAMO PERSONAL O REESTRUCTURA EJECUTANDO EL PROCEDIMIENTO sp_ofi_consultasdos.',
'ADEMAS DE CONSULTAR EL MONTO CONTRATADO DE UN PRESTAMO PERSONAL O EL AUDEUDO DE LA REESTRUCTURA',
'PP-PRESTAMO PERSONAL/RTC-REESCTRUCTURA DE TARJETA DE CREDITO',
'FECHA: 29/08/2018 ',
'BD:BDICRED',
'--------------------------------------------------------------------------------------------------------------------',
'MODIFICO: 99804965 - RAMON ARELLANO',
'MODIFICACION: SE MODIFICA PROCEDIMIENTO PARA OBTENER EL MONTO CONTRATADO Y LA TASA FIJA PARA PRODUCTO 6400,',
'FECHA: 01/02/2024',
'BD:BDICRED'
;

CREATE PROCEDURE "informix".sp_registradatos_motor_pp(
----Parametros de entrada
	pEmpresa CHAR(4),
	pNumSol CHAR(20),
	pNumCteBanco CHAR(20),
	cProducto CHAR(4),
	cMensajeMotivoCC CHAR(100),
	cRespSic CHAR(1),
	dMonto_Hipoteca MONEY,
	cTipo_sol CHAR(1),
	cNuevoStatus CHAR(2),
	cCausaSolicitud CHAR(3),
	vMorAct DECIMAL(10,2),
	vNuevoStatus_grupo5 CHAR(2),
	dSituacionPagoCoppel DECIMAL(10,2),
	PuntosESTADO_CIVIL_VAR_INT DECIMAL(10,2),
	vNumVecesTiendaComercial CHAR(20),
	PuntosUT0034 DECIMAL(10,2),
	PuntosvVI_Ocup_TmpOcup DECIMAL(10,2),
	PuntosVI_Edad_Escolaridad DECIMAL(10,2),
	v_min_flujo DECIMAL(14,2),
	v_salariomin DECIMAL(14,2),
	cSituacionCredito CHAR(1),
	v_comprobancoCRNOM DECIMAL(14,2),
	vgrupo_sol CHAR(1),
	vGrupoSol CHAR(1),
	v_lineasinTopes DECIMAL(14,2),
	v_ingreso_ant MONEY(14,2),
	v_ingresomensual_lc CHAR(20),
	cElementOs DECIMAL(14,2),
	v_limiteSup DECIMAL(14,2),
	v_tasasiniva DECIMAL(10,6),
	v_comprobancoPP DECIMAL(14,2),
	v_linea DECIMAL(14,2),
	v_factor_vp DECIMAL(21,10),
	v_flujo_libre1 DECIMAL(14,2),
	v_hereda_status CHAR(2),
	VI_Edad_Escolaridad DECIMAL(14,8),
	v_compromisos_33 MONEY(16,2),
	dCompromisosTotal MONEY(14,2),
	dCRA DECIMAL(14,2),
	v_ingreso CHAR(20),
	v_Valor_3s DECIMAL(14,2),
	v_valor DECIMAL(14,2),
	v_valor_2s DECIMAL(14,2),
	v_tasa DECIMAL(9,6),
	vcompromiso_coppel DECIMAL(14,2),
	v_porcentaje_compromiso DECIMAL(14,2),
	v_lineaAnt DECIMAL(14,2),
	v_lineaban DECIMAL(14,2),--sin uso
	v_meses DECIMAL(18,2),
	dPorcIncr DECIMAL(14,2),
	dPorcDecr DECIMAL(14,2),
	dMontoIncr DECIMAL(14,2),
	dMontoDecr DECIMAL(14,2),
	v_lineaRR DECIMAL(14,2),
	cBanderaRR CHAR(1),
	v_monto_cap_pago CHAR(20),
	cRevisionMC CHAR(1),
	dPorHipo DECIMAL(14,2),
	dPorSic DECIMAL(14,2),
	dPorOtros DECIMAL(14,2),
	iMotivoOs DECIMAL(10,2),-----------
	iProdMC DECIMAL(10,2),
	vMesesyMonto DECIMAL(14,8),
	vMesesAperCtaAntiguaRev CHAR(80),
	dOtrosComp DECIMAL(14,2),
	v_tope_ingreso DECIMAL(14,2),
	v_bs_score DECIMAL(14,2),
	dlinea_min_prod DECIMAL(18,2),
	ptipogrupoAux CHAR(1),
	v_comprobancoTDC DECIMAL(14,2),
	iSecuenciaOs DECIMAL(10,2),
	iFiltroParam DECIMAL(10,2),
	v_limiteInf DECIMAL(14,2),
	iMeses DECIMAL(10,2),
	cStatusRespOs CHAR(1),
	suma_gastos DECIMAL(14,2),
	ptipogrupo CHAR(2),
	cTieneOstel CHAR(1),
	cResultadoOsTel CHAR(1),
	bandera_grupo5 DECIMAL(10,2),
	cCanalv1 DECIMAL(10,2),
	cbanobligadosol DECIMAL(14,2),
	ccapturaobligsol DECIMAL(14,2),
	cCteProsp CHAR(20),
	Flag2credito DECIMAL(14,2),
	sBanAuto DECIMAL(14,2),
	IQ0002 DECIMAL(10,2),
	cEdo_civil CHAR(80), --sin uso
	cCompIngresos CHAR(1),
	dIngresoCac DECIMAL(14,2),
	iISM DECIMAL(14,2),
	v_flujo_libre2 DECIMAL(14,2),
	v_tasaMens DECIMAL(9,6),
	iSolMc DECIMAL(10,2),
	iFlagForzarEnvioMC DECIMAL(14,2),
	cStatusMovil CHAR(2),
	BC_101 INTEGER,--BC_101 CHAR(2) MACM
	v_capacidad MONEY(14,2),
	ESTADO_CIVIL_VAR_INT DECIMAL(18,2),
	dValorOs DECIMAL(10,4),
	iBanderaFaltaOSTEL DECIMAL(10,2),
	vPorcCta30oMasDias DECIMAL(10,2),
	iBanderaProsNoTit DECIMAL(10,2),
	v_comprobanco MONEY,
	iEnviarMC DECIMAL(10,2),
	UT0034 DECIMAL(10,2),
	iTotalParametrico DECIMAL(10,2),
	pmonto_autorizado DECIMAL(14,2),
	vMaxPlazoDias DECIMAL(14,2),
	VI_TpResid_TmpResid DECIMAL(14,2),
	vMensajeStatus CHAR(80),
	vlMontoHipoteca DECIMAL(10,2),
	vlMontoHipoteca_ant DECIMAL(14,2),
	vflagoro DECIMAL(14,2),
	iIdRiesgo DECIMAL(10,2),
	cStatusSolicitud CHAR(2),
	v_compromisos_sic_lc MONEY(14,2),
	cNuevoStatusOstel CHAR(2),
	v_linea_tienda MONEY(14,2),
	vPorcUso DECIMAL(15,8),
	vPromAntigMesesCtaRepUlt3Meses DECIMAL(10,2),
	vPromAntMax DECIMAL(14,2),
	vPromAntMin DECIMAL(14,2),
	vPuntualidad DECIMAL(14,8),
	vRatioConsUlt3M12M DECIMAL(10,2),
	vScoreEficUltSemMax DECIMAL(14,2),
	vScoreEficUltSemMin DECIMAL(14,2),
	vScorePlazoDiasMax DECIMAL(14,2),
	vScorePlazoDiasMin DECIMAL(14,2),
	vScorePorcjCta30oMasDiasMax DECIMAL(14,2),
	vScorePorcjCta30oMasDiasMin DECIMAL(14,2),
	vScorePorcjUsoMax DECIMAL(14,2),
	vScorePorcjUsoMin DECIMAL(14,2),
	vScoreRatioCon3MMax DECIMAL(14,2),
	vScoreRatioCon3MMin DECIMAL(14,2),
	vTipoHit DECIMAL(14,2),
	vValorCivil DECIMAL(14,2), --sin uso
	vVI_Ocup_TmpOcup DECIMAL(10,4),
	cSegmento CHAR(1),
	dFecha_Respuesta CHAR(10),
	dFechaVencimiento CHAR(10),
	IAsignaCapSaturada CHAR(10),
	PuntosvEstado DECIMAL(10,2),
	sHist_meses DECIMAL(14,2),
	PuntosVI_TpResid_TmpResid DECIMAL(10,2),
	PuntosvMesesyMonto DECIMAL(10,2),
	PuntosvPuntualidad DECIMAL(10,2),
	PuntosvScorminelementRev DECIMAL(10,2),
	PuntosBC_101 DECIMAL(10,2),
	PuntosIQ0002 DECIMAL(10,2),
	out_SCod_Ret CHAR(6),
	v_ingreso_salariomin CHAR(2),
	v_ingreso_valida CHAR(20),
	sts_prev_pa CHAR(20),
	vBanCoppelTiendaComercial DECIMAL(14,2),
	vCompromisos MONEY,
	vEficUltSem DECIMAL(14,2),
	vEstado DECIMAL(10,2),
	cSucursal   		CHAR(4),
	iValorICC	         DECIMAL(14,2),
	vCuentasPF   DECIMAL(14,8), --sin uso
	vMesesAperCtaAntigua DECIMAL(14,8),--sin uso
	PorcRangfijoMin 					DECIMAL(14,2),
	PorcRangofijoMax 				DECIMAL(14,2),
	vScorePorcSdoMin 				DECIMAL(14,8),
	vScorePorcSdoMax 			DECIMAL(14,2),
	vScoreMorActMin 	            DECIMAL(14,2),
	vScoreMorActMax 				DECIMAL(14,2),
	vAntiguedad            CHAR(1),-------------Agregar a BRM PP
    Capacidad_pago MONEY(14,2),
    PuntosGrupo72 DECIMAL(10,2),
    PuntosGrupo73 DECIMAL(10,2),
    PuntosGrupo74 DECIMAL(10,2),
    PuntosGrupo75 DECIMAL(10,2),
    PuntosGrupo76 DECIMAL(10,2),
    PuntosGrupo77 DECIMAL(10,2),
    PuntosGrupo78 DECIMAL(10,2),
    PuntosGrupo79 DECIMAL(10,2),
    cStatusPr CHAR(2),
    vcompromiso_coppel_2 DECIMAL(14,8),
	cNuevoStatusProsecto CHAR(2),
	vScorminelementRev DECIMAL(14,8),
	Origenout1 VARCHAR(30),--tasasiniva
	Origenout2 VARCHAR(30),
	Origenout3 VARCHAR(30),
	Origenout4 VARCHAR(30),
	Origenout5 DECIMAL(14,2),
	Origenout6 DECIMAL(14,2),
	Origenout7 DECIMAL(14,2),
	Origenout8 DECIMAL(14,2),
	pIngresoAjustado    	DECIMAL(10,2),-----
	pMoraCoppel 	         	DECIMAL(10,2),
	pMoraBancoppel  	DECIMAL(10,2),
	pSaldoVenCoppel	DECIMAL(10,2),
	pSaldoVencBancoppel		DECIMAL(10,2),
	pQuebranto			INTEGER,
	pSituacionEsp			CHAR(50),
	pReestructura			Integer,
	pFraudes			Integer,
	pListaNegra			SMALLINT,
	pIdenFalsa			SMALLINT,
	pnoTramiteDia_TDC		Integer,
	pcNoTramiteDia_PP		Integer,
	iHawk				Integer,
	sModelo			CHAR(50),
	iTipoSegmento		CHAR(50),
	dSics_montoPagar_revolvente  VARCHAR(250),
	dSics_montoPagar_noRevolvente 	VARCHAR(250),
	dSic_saldoActual_revolvente  VARCHAR(250),
	dSic_saldoActual_noRevolvente 	VARCHAR(250),
	dGc_saldoActual_Coppel   		DECIMAL (10,2),
	dGc_saldoActual_Banco   		DECIMAL (10,2),
	dCompromisos_cliente  		 DECIMAL (10,2),
	dCapacidadPago     			DECIMAL (10,2),
	dDecil       				Integer,
	dPti       				DECIMAL (10,2),
	dDti       				DECIMAL (10,2),
	dTasa       				DECIMAL (10,2),
	iPlazo2      				Integer,
	dVeces_Ingreso     			DECIMAL (10,2),
	dMaximo_Monto     			DECIMAL (10,2),
	cTipoColectivo     			VARCHAR(50),
	dMonto       				DECIMAL (10,2),
	dCuota       				DECIMAL (10,2),
	dPti_Real      				DECIMAL (10,2),
	dDti_Real      				DECIMAL (10,2),
	dPuntos_promedio_ingresom_ult4d	DECIMAL (10,2),
	dPromedio_ingresom_ult4d			Integer,
	pPuntos_continuidad_depositos_nomina	DECIMAL (10,2),
	pContinuidad_depositos_nomina		Integer,
	pOrigenout9					VARCHAR(50),
	pOrigenout10					VARCHAR(50),
	pOrigenout11					VARCHAR(50),
	pOrigenout12					VARCHAR(50),
	pOrigenout13					VARCHAR(50),
	pOrigenout14					Integer,
	pOrigenout15					Integer,
	pOrigenout16					Integer,
	pOrigenout17					Integer,
	pOrigenout18					Integer,
	pEdition_ss                      SMALLINT, 
    pEditiondate_ss CHAR (10))

RETURNING CHAR(5);

----Declaracion de variables--------	

DEFINE v_hoy                  DATE;
DEFINE vfechaServ DATE;
DEFINE sConsulta               SMALLINT;
DEFINE vCodUdi      CHAR(2);
DEFINE vCodUs       CHAR(2);
DEFINE vTpCambioUdi DECIMAL(14,6);
DEFINE vTpCambioUs  DECIMAL(14,6);
DEFINE vClase        CHAR(1);
DEFINE v_mod_parame           CHAR(1);
DEFINE v_valor_4s             DECIMAL(14,2);
DEFINE v_seccion              SMALLINT;
DEFINE iPlazo                  INTEGER;
DEFINE cTipoMovto            CHAR(1);
DEFINE isolcomp			INTEGER; -- se utiliza para condicionar insert en ss_solicitudes_cac
DEFINE iValido   		INTEGER; -- se utiliza para condicionar insert en ss_solicitudes_cac
DEFINE cMensajeRet   	CHAR(100); -- auxiliar para retorno de SP  sp_valida_comprobante
DEFINE iNewMPP INTEGER; -- sin uso, condicionaba el llamado de calula_variables
DEFINE existe_gpo5			INTEGER; -- condiciona insercion en bitacora_os_gpo5
DEFINE dTl13 DATE;

-----------------------------
DEFINE ppeso SMALLINT;
DEFINE pelemento SMALLINT;
DEFINE pgrupo SMALLINT;

------------------------------

DEFINE scod_ret              CHAR(5);
DEFINE cCodRet2Cred              CHAR(6);
DEFINE cProducto2    CHAR(4); -- cProducto

DEFINE vsqlerr                INTEGER;
DEFINE isam_err	SMALLINT;
DEFINE error_info CHAR(100);
DEFINE wBegin       CHAR(1);

----Inicializacion de variables-----

LET v_hoy = DATE(1);
LET vfechaServ = DATE(1);
LET sConsulta = 0;
LET vCodUdi = "";
LET vCodUs = "";
LET vTpCambioUdi = 0;
LET vTpCambioUs = 0;
LET vClase = "";
LET v_mod_parame = "2";
LET v_valor_4s = 0;
LET v_seccion = 2;
LET iPlazo = 0;
LET cTipoMovto = "";
LET isolcomp = 0; 
LET iValido = 0;
LET cMensajeRet = "";
LET iNewMPP = 1;
LET existe_gpo5 = 0;
LET ppeso = 0;
LET pelemento = 0;
LET pgrupo = 0;

LET scod_ret = "00000";
LET cCodRet2Cred = "00000";

LET cProducto2 = "";
LET vsqlerr = 0;
LET isam_err = 0;
LET error_info = "";
LET wBegin = "N";

LET vMensajeStatus = trim(vMensajeStatus);
LET cMensajeMotivoCC = trim(cMensajeMotivoCC);

-- ****************************************************************************
-- *                        CONTROL DE CAMBIOS                                *
-- ****************************************************************************
----------------------------------------------------------------------------------------------------------------',
--DESCRIPCION: Se agregan variables que se necesitan para el motor de evaluacion de prestamos personales MACM', 
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:15/08/2024',
--BD: BDICRED';
--DESCRIPCION: Se topa el valor de la variable ut0034 a 999999 por desbordamiento.
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:28/10/2024',
--BD: BDICRED';
--DESCRIPCION: Se actualiza la columna "cOrigenout3_ss" por el nombre "cNivelEndeudamiento_ss",
--AUTOR:Kevin Galvez Parra ',
--FECHA:02/04/2025',
--BD: BDICRED';
																		   
	--SET DEBUG FILE TO '/tmp/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	--SET debug file to '/informix/MarcoCardenas/PruebasMotor/registradatos/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	-- SET DEBUG FILE TO '/home/e10001126/logsapp/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	-- TRACE ON;

BEGIN
	----Control de excepciones
	ON EXCEPTION SET vsqlerr, isam_err, error_info
		IF vsqlerr != 0 THEN
			LET scod_ret=vsqlerr;
			INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_registradatos_motor_pp", vsqlerr, CURRENT ||error_info||' sol '||TRIM(pNumSol));
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN  scod_ret;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-255)
		LET wBegin = "B";
	END EXCEPTION WITH RESUME;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	----
	BEGIN WORK;

	insert into bdisolic:"informix".ss_certif_evaluacion_salida_pp(
		pNumSol_ss,pNumCteBanco_ss,vNumVecesTiendaComercial_ss,v_hereda_status_ss,
		iFlagForzarEnvioMC_ss,iSecuenciaOs_ss,cStatusRespOs_ss,cResultadoOsTel_ss,bandera_grupo5_ss,iMeses_ss,v_compromisos_33_ss,v_monto_cap_pago_ss,
		iProdMC_ss,v_valor_ss,iFiltroParam_ss,v_lineaban_ss,cTieneOstel_ss,cCanalv1_ss,cbanobligadosol_ss,ccapturaobligsol_ss,cCteProsp_ss,Flag2credito_ss,
		sBanAuto_ss,IQ0002_ss,cEdo_civil_ss,iSolMc_ss,cStatusMovil_ss,iBanderaProsNoTit_ss,iEnviarMC_ss,iTotalParametrico_ss,vflagoro_ss,cStatusSolicitud_ss,
		cNuevoStatusOstel_ss,vScoreEficUltSemMax_ss,vScoreEficUltSemMin_ss,vScorePlazoDiasMax_ss,vScorePlazoDiasMin_ss,vScorePorcjCta30oMasDiasMax_ss,
		vScorePorcjCta30oMasDiasMin_ss,vScorePorcjUsoMax_ss,vScorePorcjUsoMin_ss,vScoreRatioCon3MMax_ss,vScoreRatioCon3MMin_ss,vValorCivil_ss,
		dFechaVencimiento_ss,IAsignaCapSaturada_ss,sHist_meses_ss,out_SCod_Ret_ss,v_ingreso_salariomin_ss,v_ingreso_valida_ss,sts_prev_pa_ss,
		vCuentasPF_ss,vMesesAperCtaAntigua_ss,PorcRangfijoMin_ss,PorcRangofijoMax_ss,vScorePorcSdoMin_ss,vScorePorcSdoMax_ss,vScoreMorActMin_ss,
		vScoreMorActMax_ss,vAntiguedad_ss,cStatusPr_ss,vcompromiso_coppel_2_ss,vMaxPlazoDias_ss,vScorminelementRev_ss,vPromAntMin_ss,vPromAntMax_ss,
		cOrigenout1_ss,cOrigenout2_ss,cNivelEndeudamiento_ss,cOrigenout4_ss,cOrigenout5_ss,cOrigenout6_ss,cOrigenout7_ss,cOrigenout8_ss,fecha_insert_ss)
	values(
		pNumSol,pNumCteBanco,vNumVecesTiendaComercial,v_hereda_status,
		iFlagForzarEnvioMC,iSecuenciaOs,cStatusRespOs,cResultadoOsTel,bandera_grupo5,iMeses,v_compromisos_33,v_monto_cap_pago,
		iProdMC,v_valor,iFiltroParam,v_lineaban,cTieneOstel,cCanalv1,cbanobligadosol,ccapturaobligsol,cCteProsp,Flag2credito,
		sBanAuto,IQ0002,cEdo_civil,iSolMc,cStatusMovil,iBanderaProsNoTit,iEnviarMC,iTotalParametrico,vflagoro,cStatusSolicitud,
		cNuevoStatusOstel,vScoreEficUltSemMax,vScoreEficUltSemMin,vScorePlazoDiasMax,vScorePlazoDiasMin,vScorePorcjCta30oMasDiasMax,
		vScorePorcjCta30oMasDiasMin,vScorePorcjUsoMax,vScorePorcjUsoMin,vScoreRatioCon3MMax,vScoreRatioCon3MMin,vValorCivil,
		dFechaVencimiento,IAsignaCapSaturada,sHist_meses,out_SCod_Ret,v_ingreso_salariomin,v_ingreso_valida,sts_prev_pa,
		vCuentasPF,vMesesAperCtaAntigua,PorcRangfijoMin,PorcRangofijoMax,vScorePorcSdoMin,vScorePorcSdoMax,vScoreMorActMin,
		vScoreMorActMax,vAntiguedad,cStatusPr,vcompromiso_coppel_2,vMaxPlazoDias,vScorminelementRev,vPromAntMin,vPromAntMax,
		Origenout1,Origenout2,Origenout3,Origenout4,Origenout5,Origenout6,Origenout7,Origenout8,current);

	LET BC_101 = BC_101;	
      IF(cProducto ='6400')THEN
		insert into bdisolic:"informix".ss_certif_evaluacion_salida_pp_2(pnumsol_ss,pnumctebanco_ss,cproducto_ss,ingreso_ajustado_ss,
		mora_coppel_ss,mora_bancoppel_ss,saldo_vencido_coppel_ss,saldo_vencido_bancoppel_ss,quebranto_ss,situacion_especial_ss,reestructuras_ss,
		fraudes_ss,lista_negra_ss,identificacion_falsa_ss,no_tramitedia_tdc_ss,no_tramitedia_pp_ss,hawk_ss,modelo_ss,tipo_segmento_ss,
		sics_montopagar_revolvente_ss,sics_montopagar_norevolvente_ss,sics_saldoactual_revolvente_ss,sics_saldoactual_norevolvente_ss,gc_saldoactual_coppel_ss,
		gc_saldoactual_bancoppel_ss,compromisos_cliente_ss,capacidad_pago_ss,decil_ss,pti_ss,dti_ss,tasa_ss,plazo_ss,veces_ingreso_ss,
		maximo_monto_ss,tipo_colectivo_ss,monto_ss,cuota_ss,pti_real_ss,dti_real_ss,puntos_promedio_ingresom_ult4d_ss,vpromedio_ingresom_ult4d_ss,
		puntos_continuidad_depositos_nomina_ss,vcontinuidad_depositos_nomina_ss,origenout9_ss,origenout10_ss,origenout11_ss,origenout12_ss,
		origenout13_ss,origenout14_ss,origenout15_ss,origenout16_ss,origenout17_ss,origenout18_ss,edition_ss,editiondate_ss,fecha_insert)
		values(pNumSol,pNumCteBanco,cProducto,pIngresoAjustado,pMoraCoppel,pMoraBancoppel,pSaldoVenCoppel,pSaldoVencBancoppel,pQuebranto,
		pSituacionEsp,pReestructura,pFraudes,pListaNegra,pIdenFalsa,pnoTramiteDia_TDC,pcNoTramiteDia_PP,iHawk,sModelo,iTipoSegmento,dSics_montoPagar_revolvente,
		dSics_montoPagar_noRevolvente,dSic_saldoActual_revolvente,dSic_saldoActual_noRevolvente,dGc_saldoActual_Coppel,dGc_saldoActual_Banco,
		dCompromisos_cliente,dCapacidadPago,dDecil ,dPti,dDti,dTasa,iPlazo2,dVeces_Ingreso,dMaximo_Monto,cTipoColectivo,dMonto,dCuota,dPti_Real,dDti_Real,dPuntos_promedio_ingresom_ult4d,
		dPromedio_ingresom_ult4d,pPuntos_continuidad_depositos_nomina,pContinuidad_depositos_nomina,pOrigenout9,pOrigenout10,pOrigenout11,pOrigenout12,pOrigenout13,pOrigenout14,pOrigenout15,pOrigenout16,pOrigenout17,pOrigenout18,pEdition_ss,pEditiondate_ss,current);
     --actualizar capacidad_pres
	 
	UPDATE bdisolic:"informix".ss_solicitudes
                SET  capacidad_pres = dCapacidadPago
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;
				
	UPDATE bdisolic:"informix".ss_revision_determinacion 
	SET tasa = dTasa
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;
	
	END IF;
	/*IF(out_SCod_Ret = '00007') THEN
		IF wbegin = 'S' THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
		RETURN scod_ret;
	END IF;*/

	SELECT fecha_hoy
	INTO v_hoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

    SELECT tipo_movimiento
    INTO cTipoMovto
    FROM  bdisolic:"informix".ss_resum_scor_fin
    WHERE empresa =  pEmpresa
    AND num_solicitud = pNumSol;

	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET tp_gen_planpago = vTipoHit  
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;  				

	UPDATE bdisolic:"informix".ss_resum_scor_fin
	SET evalua_cc = cRespSic,
	motivo_cc = cMensajeMotivoCC,
	pago_minimo = v_compromisos_sic_lc,
	secuenciaconsulta = sConsulta,         
	monto_hipoteca = dMonto_Hipoteca
	WHERE empresa = pEmpresa
	AND num_solicitud = pNumSol;

	----
	SELECT TRIM(valor) INTO vCodUdi
	FROM bdinteg:"informix".si_param
	WHERE empresa = pEmpresa
	AND cod_param = 16;

	SELECT TRIM(valor) INTO vCodUs
	FROM bdinteg:"informix".si_param
	WHERE empresa = pEmpresa
	AND cod_param = 17;

	SELECT TRIM(valor) INTO vClase
	FROM bdicred:"informix".sd_param
	WHERE empresa = pEmpresa
	AND cod_param = "336";

	EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, v_hoy,vCodUdi,vClase,'0')
	INTO scod_ret,vTpCambioUdi;

	IF scod_ret<>'00000' THEN
		RETURN scod_ret;
	END IF;

	EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, v_hoy,vCodUs,vClase,'1')
	INTO scod_ret,vTpCambioUs;
	IF scod_ret<>'00000' THEN
		RETURN scod_ret;
	END IF;

	-- mahr-cnbv Se actualiza el grupo para que los calculos se realicen en base a ese grupo.
	UPDATE bdisolic:"informix".ss_revision_determinacion 
	SET monto_hipoteca = dMonto_Hipoteca,
	evalua_cc = cRespSic,
	compromiso_sic = v_compromisos_sic_lc,
	tipo_cambio_udi = vTpCambioUdi,
	tipo_cambio_dls = vTpCambioUs
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;

	----
	IF cRespSic in ('1','2','3','4') AND cTipo_sol NOT IN ('C')  THEN --JMAH  Solicitudes coppel no se rechazan			
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
						INTO scod_ret;

		IF NVL(pNumSol,'') <> '' THEN	
			UPDATE bdisolic:"informix".ss_solicitudes_movil
			SET status = '3',--finalizado
			descripcion_status = vMensajeStatus 
			WHERE 	empresa  = pEmpresa 
			AND  num_solicitud = pNumSol;
		END IF;                

		IF scod_ret <> '00000' THEN
			LET scod_ret = '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN scod_ret;
		END IF;

		IF wbegin = 'S' THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;

		RETURN scod_ret;
	END IF; 	

	/*select count(*) into iNewMPP 
	from bdisolic:"informix".ss_param_mpp 
	WHERE empresa = '001'
	AND idSuc = cSucursal
	AND produc = cProducto;*/
	
	IF UT0034 > 999999 THEN 
		LET UT0034 = 999999;
	END IF;
	
	IF iNewMPP > 0 THEN--Nuevo modelo PP
		DELETE FROM bdisolic:"informix".ss_detalle_modelo where num_solicitud = pNumSol;
	
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = pNumSol; 
									
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo >= 44 and grupo <= 47 and tpo_persona = '01' and  num_solicitud = pNumSol;

		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo in (16,49,50,51,52,53,54,55,56,57,63,64,65,66,67,60,68,61) and tpo_persona = '01' and  num_solicitud = pNumSol;
								
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' AND seccion ='2'  
		AND grupo IN (27,51,52,56,60,61,67,69,70,71,72,73,74,75,76,77,78,79,80) AND tpo_persona = '01' AND num_solicitud = pNumSol; 						

		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'BC_101',BC_101,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'UT0034',UT0034,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'OCUPACION_&_TIEMPO_OCUPACION',vVI_Ocup_TmpOcup,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'IQ0002',IQ0002,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Residencia_&_Tpo_Residencia',VI_TpResid_TmpResid,current,user);			
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'EDO_CIVIL_&_GENERO',ESTADO_CIVIL_VAR_INT,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Edad&_Escolaridad',VI_Edad_Escolaridad,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Estado',vEstado,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Diferencias_Meses_&CtaMasAntigua_CtaRevolvente',vMesesAperCtaAntiguaRev,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Meses_y_monto_de_la_fecha_de_morosidad_mas_grave_mas_reciente',vMesesyMonto,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Porcentaje_Cuentas_30_o_Mas_Dias_Atraso',vPorcCta30oMasDias,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Maximo_plazo_en_dias',vMaxPlazoDias,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Ratio_numero_de_consultas_en_los_ultimos_3_meses_entre_numero_de_consultas_de_los_ultimos_12_meses',vRatioConsUlt3M12M,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'PRODUCTO BANCOPPEL-TIENDA COMERCIAL',vBanCoppelTiendaComercial,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Promedio_de_la_antiguedad_en_meses_de_cuentas_reportadas_en_los_ultimos_3_meses',vPromAntigMesesCtaRepUlt3Meses,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Eficiencia_Ultimo_Semestre',vEficUltSem,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Mora_Actual',vMorAct,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Porcentaje_de_Uso',vPorcUso,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Puntualidad',vPuntualidad,current,user);

		UPDATE BDISOLIC:"informix".ss_detalle_scoring SET valor = 0 WHERE empresa =  pEmpresa AND seccion = 2 AND num_solicitud = pNumSol;
		
		INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosBC_101
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 27 AND elemento = BC_101);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosUT0034
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 51 AND UT0034 BETWEEN rango_min AND rango_max AND (
            (elemento between PorcRangfijoMin AND PorcRangofijoMax) OR (elemento between vScorePorcSdoMin AND vScorePorcSdoMax) OR  elemento IN (29)));
        
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvVI_Ocup_TmpOcup
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 52 AND elemento = vVI_Ocup_TmpOcup);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosIQ0002
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 56 AND IQ0002 BETWEEN rango_min AND rango_max AND elemento IN (6,7,8,9,10));

		INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosVI_TpResid_TmpResid
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 60 AND elemento = VI_TpResid_TmpResid);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosESTADO_CIVIL_VAR_INT
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 61 AND elemento = ESTADO_CIVIL_VAR_INT);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosVI_Edad_Escolaridad
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 67 AND elemento = VI_Edad_Escolaridad);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvEstado
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 69 AND elemento = vEstado);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvScorminelementRev
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 70 AND elemento = vScorminelementRev);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvMesesyMonto
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 71 AND elemento = vMesesyMonto);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo72 --(vPorcCta30oMasDias)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 72 AND vPorcCta30oMasDias BETWEEN rango_min AND rango_max AND elemento between vScorePorcjCta30oMasDiasMin AND vScorePorcjCta30oMasDiasMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo73 --(vMaxPlazoDias)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 73 AND vMaxPlazoDias BETWEEN rango_min AND rango_max AND elemento between vScorePlazoDiasMin AND vScorePlazoDiasMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo74 --(vRatioConsUlt3M12M)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=74 and vRatioConsUlt3M12M BETWEEN rango_min AND rango_max AND elemento between vScoreRatioCon3MMin AND vScoreRatioCon3MMax);
        
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo75 --(vNumVecesTiendaComercial)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=75 and vNumVecesTiendaComercial BETWEEN rango_min AND rango_max AND elemento = vBanCoppelTiendaComercial);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo76 --(vPromAntigMesesCtaRepUlt3Meses)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=76 and vPromAntigMesesCtaRepUlt3Meses  BETWEEN rango_min AND rango_max AND elemento BETWEEN vPromAntMin AND vPromAntMax);
        
		LET cTipo_sol = cTipo_sol;
		LET vEficUltSem = vEficUltSem;
		LET vScoreEficUltSemMin = vScoreEficUltSemMin;
		LET vScoreEficUltSemMax = vScoreEficUltSemMax;
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo77 --(vEficUltSem)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=77 and vEficUltSem BETWEEN rango_min AND rango_max AND elemento between vScoreEficUltSemMin AND vScoreEficUltSemMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo78 
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=78 and elemento between  vScoreMorActMin AND vScoreMorActMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo79 --(vPorcUso)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=79 and vPorcUso BETWEEN rango_min AND rango_max AND ((elemento between vScorePorcjUsoMin AND vScorePorcjUsoMax) OR  elemento IN (1,13)));

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvPuntualidad
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 80 AND elemento = vPuntualidad);

        
	END IF;
	
	--MACM
	IF ( dSituacionPagoCoppel < 0  ) THEN
       LET v_meses = 0;
       LET dSituacionPagoCoppel = 0;
    END IF;

    UPDATE bdisolic:"informix".ss_revision_determinacion 
    SET situacion_pago = dSituacionPagoCoppel,
    meses_historia = v_meses, 
    situacion_credito = cSituacionCredito,
    bs_score = v_bs_score,--v_valor_1s,
    score_prop = v_valor_2s,
    fico_score = v_valor_3s,
    linea_tienda = v_linea_tienda
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol;	

	----
    DELETE FROM bdisolic:"informix".ss_resumen_scoring
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol;

    DELETE FROM bdisolic:"informix".ss_autorizacion
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol
    AND status_solicitud IN ("RT","EE");


    -- Se inserta valor de la seccion 1
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, 1, v_bs_score);

    --Se inserta valor de la seccion 2
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, v_seccion, v_valor_2s);

    -- FICO SCORE/Se inserta valor de la seccion 3
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, 3, v_valor_3s);

	----
    IF v_mod_parame = 2 AND cTipo_sol NOT IN ('C') THEN        
        IF Flag2credito = 1 THEN
            INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
            VALUES (pEmpresa, pNumSol, 5, iValorICC);

            IF cNuevoStatus = "RT" THEN
                UPDATE bdisolic:"informix".ss_revision_determinacion
                SET flag2creditoicc = 1
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;
            END IF;
        END IF;		   
    END IF;

	----
    IF v_valor < iTotalParametrico THEN					  
        EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus,cCausaSolicitud, vMensajeStatus)
        INTO scod_ret;

        IF NVL(pNumSol,'') <> '' THEN	
            UPDATE bdisolic:"informix".ss_solicitudes_movil		
            SET status = '3',--finalizado
            descripcion_status = vMensajeStatus 
            WHERE empresa = pEmpresa 
            AND num_solicitud = pNumSol;
        END IF;

        IF scod_ret <> '00000' THEN
            LET scod_ret = '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
            IF wbegin = 'S' THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN scod_ret;
        END IF;

        IF wbegin = 'S' THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
		UPDATE  bdisolic:"informix".ss_revision_determinacion 
		SET ingreso_mensual = v_ingreso_ant,
			ingreso_mensual_lc		= v_ingresomensual_lc,    
			pago_crnom				= v_comprobancoCRNOM, 
			pago_prest				= v_comprobancoPP, 
			pago_tdc				= v_comprobancoTDC, 
			compromiso_sic_lc       = vcompromisos,	        
			monto_coppel			= vcompromiso_coppel,		
			mto_pagos_bco			= v_comprobanco,		
			compromiso_mens        	= dCompromisosTotal,
			factor1         		= 0,
			factor2         		= 0,
			valor_cta            	= 0, 
			valor_cma            	= 0,
			valor_tab            	= 0,
			valor_rab            	= dCRA,
			valor_pres            	= v_factor_vp, -- se quita para que no la actualice en caso de que sea el producto 6400 tasa = v_tasasiniva ,
			tasa_iva        		= v_tasa,
			tasa_mens        		= v_tasaMens,
			cap_pag_min           	= v_min_flujo,
			tope_ingreso_tope		= v_tope_ingreso,
			linea_teorica        	= v_lineasinTopes,
			limiteInf				= v_limiteInf,
			limiteSup				= v_limiteSup,
			linea_credito			= v_lineaAnt,
			porc_incre           	= dPorcIncr,
			porc_decre           	= dPorcDecr, 
			monto_incre           	= dMontoIncr, 
			monto_decre           	= dMontoDecr,  
			linea_final				= v_linea,
			bandera_rr		        = cBanderaRR,
			linea_rest				= v_lineaRR,
			bandera_mc		      	= cRevisionMC,	
			porc_hipo	         	= dPorHipo,
			porc_buro           	= dPorSic,
			porc_otros          	= dPorOtros,
			perfil_riesgo           = iIdRiesgo,
			ingreso_sm 				= iISM,
			monto_hipoteca          = vlMontoHipoteca_ant,
			monto_hipoteca_lc       = vlMontoHipoteca ,
			otros_gastos        	= dOtrosComp,
			score_prop          	= v_valor_2s, -- v_score_prop
			comprob_ing_val_mc  	= cCompIngresos,
			monto_reportado_mc  	= dIngresoCac,
			salario_minimo      	= v_salariomin,
			linea_min_prod      	= dlinea_min_prod, 
			suma_gastos         	= suma_gastos
		WHERE  empresa  = pEmpresa
		AND num_solicitud = pNumSol;
		
		IF(cProducto <> '6400' )THEN 
		UPDATE  bdisolic:"informix".ss_revision_determinacion 
		SET tasa     	    		= v_tasasiniva
		WHERE  empresa  = pEmpresa
		AND num_solicitud = pNumSol;
		END IF;

        RETURN scod_ret;			         
    END IF; 

	----
    IF NVL(cTieneOstel,'') = 'V' THEN
        IF nvl(cResultadoOsTel,'') = '' THEN--JMAH RQM 18 056
            --IF (iProdMC = 1) AND (iEnviarMC = 1 OR cTipo_sol = 'C' ) AND iSolMc = 0 THEN--para que la solicitud aunque le falte la respuesta de OSTEL pase a MC a su revision
            IF (iProdMC <> 1) AND (iEnviarMC <> 1 OR cTipo_sol <> 'C' ) AND iSolMc <> 0 THEN--para que la solicitud aunque le falte la respuesta de OSTEL pase a MC a su revision
            --ELSE						  						
                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
                            INTO scod_ret;

                IF NVL(pNumSol,'') <> '' THEN	
                    UPDATE bdisolic:"informix".ss_solicitudes_movil		
                        SET status = '3',--finalizado
                        descripcion_status = vMensajeStatus 
                    WHERE 	empresa  = pEmpresa 
                    AND  num_solicitud = pNumSol;
                END IF;

                IF scod_ret <> '00000' THEN
                    LET scod_ret = '00002'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    IF wbegin = 'S' THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    RETURN scod_ret;
                END IF;

                IF wbegin = 'S' THEN
                    COMMIT WORK;
                    BEGIN WORK;
                ELSE
                    COMMIT WORK;
                END IF;
                RETURN scod_ret;

            END IF;
        ELSE			
            INSERT INTO bdisolic:"informix".ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor)
            VALUES (pEmpresa, 2, 25,cElementOs, "01",pNumSol, dValorOs);
        END IF;	
    END IF;

	----
    IF cTieneOstel = 'V' AND iBanderaFaltaOSTEL =0 THEN        
        IF cNuevoStatusOstel = 'RT' THEN
            EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
            INTO scod_ret;

            IF NVL(pNumSol,'') <> '' THEN	
                UPDATE bdisolic:"informix".ss_solicitudes_movil		
                SET status = '3',--finalizado
                descripcion_status = vMensajeStatus 
                WHERE 	empresa  = pEmpresa 
                AND  num_solicitud = pNumSol;
            END IF;

            IF scod_ret <> '00000' THEN
                LET scod_ret = '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                IF wbegin = 'S' THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN scod_ret;
            END IF;

            IF wbegin = 'S' THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            RETURN scod_ret;
        END IF               
    END IF;			
		
	----
    IF cProducto <> '7800' THEN 	
        IF cTipo_sol NOT IN ('C')   THEN	
            --IF (v_compromisos_33 - vCompromisos) >= v_monto_cap_pago::DECIMAL(10,2) THEN

                IF NVL(sHist_meses,0) > 0 THEN                     
                    IF NVL(sHist_meses,0) > iMeses  THEN 
                        INSERT INTO bdisolic:"informix".ss_cambio_grupo (empresa ,num_solicitud ,grupo_anterior,grupo_nuevo ,user_insert ,fecha_insert)
                        VALUES (pEmpresa,pNumSol,ptipogrupoAux,ptipogrupo,USER,CURRENT);            
                    END IF;
                END IF;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET grupo = ptipogrupo 
                WHERE empresa = pEmpresa 
                AND num_solicitud = pNumSol;

                UPDATE bdisolic:"informix".ss_resum_scor_fin
                SET grupo = vGrupoSol
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;

                IF v_ingreso_valida > 0 THEN 
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET salario_minimo = v_ingreso_salariomin
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                UPDATE bdisolic:"informix".ss_resum_scor_fin 
                set compromisos_bco = v_comprobanco 
                where empresa = pEmpresa 
                and num_solicitud = pNumSol;

                IF iNewMPP > 0 THEN	
                    UPDATE bdisolic:"informix".ss_solicitudes 
                    SET tp_gen_planpago = cSegmento 
                    WHERE empresa = pEmpresa 
                    AND num_solicitud =pNumSol;
                END IF;

                IF vcompromiso_coppel_2 = 0 AND cTipoMovto = 'M' THEN
                    IF v_porcentaje_compromiso <> 0 OR v_porcentaje_compromiso IS NOT NULL THEN
                        UPDATE bdisolic:"informix".ss_revision_determinacion 
                        SET compromiso_coppel_simulado =  'SI',
                        porcentaje_compromiso =  v_porcentaje_compromiso||'% '
                        WHERE num_solicitud = pNumSol;
                    END IF;
                END IF;

                IF IAsignaCapSaturada = 0 THEN
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET ingreso_lc = v_ingreso,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_lineasinTopes
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                IF NVL(vflagoro,0) = 0 THEN
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET ingreso_lc = v_ingreso,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_lineasinTopes
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                update bdisolic:"informix".ss_solicitudes 
                set tasa_base_piso =  TO_CHAR(v_capacidad)
                where num_solicitud = pNumSol 
                and empresa = pEmpresa;   

                IF NVL(vflagoro,0) = 0  AND vAntiguedad = '' THEN
                    UPDATE bdisolic:"informix".ss_solicitudes_tdcoro
                    SET ingreso_lc = v_ingresomensual_lc,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_linea
                    WHERE empresa = pEmpresa
                    AND numero_solicitud = pNumSol;
                ELSE
                    UPDATE  bdisolic:"informix".ss_revision_determinacion 
                    SET ingreso_mensual = v_ingreso_ant,
                        ingreso_mensual_lc		= v_ingresomensual_lc,    
                        pago_crnom				= v_comprobancoCRNOM, 
                        pago_prest				= v_comprobancoPP, 
                        pago_tdc				= v_comprobancoTDC, 
                        compromiso_sic_lc       = vcompromisos,        
                        monto_coppel			= vcompromiso_coppel,		
                        mto_pagos_bco			= v_comprobanco,		
                        compromiso_mens        	= dCompromisosTotal,
                        factor1         		= 0,
                        factor2         		= 0,
                        valor_cta            	= 0, 
                        valor_cma            	= 0,
                        valor_tab            	= 0,
                        valor_rab            	= dCRA,
                        valor_pres            	= v_factor_vp, -- -- se quita para que no la actualice en caso de que sea el producto 6400  tasa     	    		= v_tasasiniva ,
                        tasa_iva        		= v_tasa,
                        tasa_mens        		= v_tasaMens,
                        cap_pag_min           	= v_min_flujo,
                        tope_ingreso_tope		= v_tope_ingreso,
                        linea_teorica        	= v_lineasinTopes,
                        limiteInf				= v_limiteInf,
                        limiteSup				= v_limiteSup,
                        linea_credito			= v_lineaAnt,
                        porc_incre           	= dPorcIncr,
                        porc_decre           	= dPorcDecr, 
                        monto_incre           	= dMontoIncr, 
                        monto_decre           	= dMontoDecr,  
                        linea_final				= v_linea,
                        bandera_rr		        = cBanderaRR,
                        linea_rest				= v_lineaRR,
                        bandera_mc		      	= cRevisionMC,	
                        porc_hipo	         	= dPorHipo,
                        porc_buro           	= dPorSic,
                        porc_otros          	= dPorOtros,
                        perfil_riesgo           = iIdRiesgo,
                        ingreso_sm 				= iISM,
                        monto_hipoteca          = vlMontoHipoteca_ant,
                        monto_hipoteca_lc       = vlMontoHipoteca ,
                        otros_gastos        	= dOtrosComp,
                        score_prop          	= v_valor_2s, -- v_score_prop
                        comprob_ing_val_mc  	= cCompIngresos,
                        monto_reportado_mc  	= dIngresoCac,
                        salario_minimo      	= v_salariomin,
                        linea_min_prod      	= dlinea_min_prod, 
                        suma_gastos         	= suma_gastos
                    WHERE  empresa  = pEmpresa
                    AND num_solicitud = pNumSol;
                END IF;

                SELECT NVL(plazo_max_cred,0)
                INTO iPlazo
                FROM bdicred:"informix".sd_definicion
                WHERE empresa = pEmpresa
                AND num_producto = cProducto;
                
                UPDATE bdisolic:"informix".ss_solicitudes
                SET monto_autorizado = pmonto_autorizado,-- se quita para que no la actualice en caso de que sea el producto 6400 capacidad_pres = Capacidad_pago,
                plazo = iPlazo
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol; 
				
				IF(cProducto <> '6400' )THEN 
				
					UPDATE  bdisolic:"informix".ss_revision_determinacion 
					SET tasa = v_tasasiniva
					WHERE  empresa  = pEmpresa
					AND num_solicitud = pNumSol;
					
					UPDATE bdisolic:"informix".ss_solicitudes
					SET capacidad_pres = Capacidad_pago
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSol; 
				
				END IF;

           		
            --END IF;
        END IF;
    END IF

    --IF (cNuevoStatus = 'EE' OR  cNuevoStatus = 'AT') OR (cTipo_sol = 'C' AND iSolMc = 0 ) THEN 	

    IF bandera_grupo5 > 0 AND cCanalv1 <> 4 THEN				
        SELECT COUNT (*) INTO existe_gpo5
        FROM bdisolic:"informix".bitacora_os_gpo5 
        WHERE empresa = pEmpresa 
        AND num_solicitud = pNumSol;

        IF existe_gpo5 = 0 THEN
            INSERT INTO bdisolic:"informix".bitacora_os_gpo5 VALUES (pEmpresa,cProducto,pNumSol,
            (Case When (nvl(cRespSic,'X') = 'X')  Then 'No-Hit' Else 'Hit' end),
            v_hoy,'',vNuevoStatus_grupo5,cSucursal,vgrupo_sol,v_bs_score,v_valor_2s,v_valor_3s,v_valor_4s,pmonto_autorizado,'Excepcion de OS grupo 5',"");
        ELSE 
            UPDATE bdisolic:"informix".bitacora_os_gpo5 
            SET bc_score = v_bs_score,
                sc_propietario = v_valor_2s,
                fico_score = v_valor_3s, 
                fc_extended = v_valor_4s,
                linea_credito = pmonto_autorizado 
            WHERE num_solicitud = pNumSol;
        END IF;
    END IF;
                            
    IF (NVL(iFlagForzarEnvioMC,0) > 0 OR (iProdMC = 1 AND iSolMc = 0 AND iEnviarMC = 1 AND Flag2credito = 0) OR cProducto IN ('9100','9300','9200','9400')) AND  cStatusSolicitud <> 'MC'  THEN

        IF (cCanalv1 = 99) OR cProducto IN ('9100','9300','9200','9400') OR (cbanobligadosol = 1 AND ccapturaobligsol = 1) THEN

            IF iSolMc = 0  THEN
                INSERT INTO bdisolic:"informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
                VALUES (pEmpresa,pNumSol,pNumCteBanco,cSucursal,cProducto, pmonto_autorizado, cNuevoStatus,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);
            END IF;
        END IF;
        
    END IF;		

    IF NVL(cProducto,'') <> '' THEN 
        IF nvl(iSecuenciaOs,0) <> 0 THEN	
            IF(v_hoy  <= dFechaVencimiento) THEN
                IF(SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos = iSecuenciaOs)=0 THEN 
                    IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solic_rt WHERE num_solicitud = pNumSol) THEN
                        INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
                        VALUES(pEmpresa, pNumSol, v_hoy, TO_DATE(dFecha_Respuesta,'%d/%m/%Y'),cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
                    END IF;
                END IF; 
            END IF;

            IF ( NVL(cCteProsp,'') <>'' AND iBanderaProsNoTit = 0 ) THEN
                IF (SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos=iSecuenciaOs) = 0 THEN 
                    IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solic_rt WHERE num_solicitud = pNumSol) THEN
                        INSERT INTO bdisolic:"informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status,usuario_solicita,secuenciaos,motivo_os)
                        VALUES (pEmpresa, pNumSol, TODAY,TO_DATE(dFecha_Respuesta,'%d/%m/%Y'),cStatusPr, "sistema",iSecuenciaOs,iMotivoOs);
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    
    IF cNuevoStatus = 'EE' AND NVL(sBanAuto,0) = 0 AND cCanalv1 <> 0 THEN--de donde sale
     IF(SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos = iSecuenciaOs)=0 THEN 
        INSERT INTO bdisolic:"informix".ss_solicitud_os
        (empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
        VALUES
        (pEmpresa, pNumSol, v_hoy, "S", "sistema", iMotivoOs);	
     END IF;			   
    END IF;	
    --END IF;

	----
    LET cProducto2 = cProducto;
    IF  cCanalv1 <> 4  THEN --revision para incrementos de lineasd e credito
        EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(pEmpresa ,pNumCteBanco , pNumSol)
        INTO scod_ret,cMensajeRet,iValido;

        IF (scod_ret::INTEGER = 0 AND iValido = 1 AND cNuevoStatus = 'AT') THEN

            SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
            IF isolcomp = 0 THEN
                INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
                (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
                VALUES (pEmpresa, pNumSol, pNumCteBanco,cSucursal, cProducto2, cNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
            END IF;
        ELSE
            IF  cProducto2 IN ('9100','9300') THEN
                SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
                IF isolcomp = 0 THEN
                    INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
                    (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
                    VALUES (pEmpresa, pNumSol, pNumCteBanco,cSucursal, cProducto2, cNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
                END IF;			
            END IF;
        END IF;
    END IF;
		
    IF (cCanalv1 = 4)  THEN
        UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
        set sts_prev_pa 	    = cNuevoStatusProsecto, --revisar
        vvalor_junk         =  pmonto_autorizado,         
        imotivos_junk       = iMotivoOs,      
        iband_altaostel     = iBanderaFaltaOSTEL,
        ctipo_movto_junk    = cTipoMovto,         
        flagforenviomcjunk  = iFlagForzarEnvioMC,
        v_hereda_stat_junk  = v_hereda_status    
        WHERE num_solicitud = pNumSol;				

    END IF;
		
    IF cNuevoStatus = 'PA' AND  NVL(pNumSol,'') <> '' AND NVL(cStatusMovil,'') ='1' THEN			--para que cuando tenga completo el proceso lo deje en AT								

        UPDATE bdisolic:"informix".ss_solicitudes_movil		
        SET status_solicitud = cNuevoStatus		
        WHERE 	empresa  = pEmpresa 
        AND  num_solicitud = pNumSol;

    END IF;

    IF (cNuevoStatusProsecto <> 'RT' and cCanalv1 = 0) then
	
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		set sts_prev_pa 	    = cNuevoStatusProsecto, 
			vvalor_junk         =  pmonto_autorizado,         
			imotivos_junk       = iMotivoOs,      
			iband_altaostel     = iBanderaFaltaOSTEL,
			ctipo_movto_junk    = cTipoMovto,         
			flagforenviomcjunk  = iFlagForzarEnvioMC,
			v_hereda_stat_junk  = v_hereda_status    
		where num_solicitud = pNumSol; 
	END IF;
    
    EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus )
            INTO scod_ret;

    IF scod_ret <> '00000' THEN
        LET scod_ret = '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
        IF wbegin = 'S' THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN scod_ret;
    END IF;
    IF wbegin = 'S' THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    RETURN scod_ret;	
END
RETURN scod_ret;
END PROCEDURE
DOCUMENT
	'AUTOR      : Andres Godinez Hernandez - Kairos DS',
	'DESCRIPCION: Procedimiento para registro de resultados del motor de evaluacion para prestamo personal',
	'------------------------------------------------------------------------------------',
	'Autor:  Erika Berenice Bautista Gil',
	'Modifica: Modificaciones parametros de entrada y tablas de certificacion para PDN (6400)',
	'Fecha: 10/03/2025',
	'Peticion:RQM 09 654 ',
	'------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actualizasaldos_cred(pempresa CHAR(3),pNumcredito CHAR(20),pNumProd CHAR(4), pMontoEfec MONEY(14,2), pMontoCargo MONEY(14,2),pFolioMovto CHAR(20) DEFAULT "",pSucursal CHAR(4), pUsuario CHAR(20))
 RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(100);
DEFINE CodRet                        CHAR(6);
DEFINE codretRev					 CHAR(5);
DEFINE Mensaje                       CHAR(80);

DEFINE cCredito_promo                CHAR(20);
DEFINE cfolio_suc_promo              CHAR(16);
DEFINE cfolio_mov_promo              CHAR(16);
DEFINE dFecha	                     DATE;
DEFINE v_fecha_hoy                   DATE;
DEFINE dtFechaMesiversario           DATE;

DEFINE cNumTarjeta  		CHAR(20);
DEFINE cFolio               CHAR(16);
DEFINE cBegin               CHAR(1);
DEFINE  vlStatusCred        CHAR(2);
DEFINE g_Remanente						MONEY(14,2);
DEFINE g_IntMoraCob 					MONEY(14,2);
DEFINE g_IntVencCob 					MONEY(14,2);
DEFINE g_CapVencCob 					MONEY(14,2);
DEFINE g_IntVigCob 						MONEY(14,2);
DEFINE g_CapVigCob 						MONEY(14,2);
DEFINE g_Impuesto 						MONEY(14,2);
DEFINE g_Comision 						MONEY(14,2);
DEFINE g_Seguro							MONEY(14,2);
DEFINE g_SdoCapInsol					MONEY(14,2);

DEFINE v_tipocambio     DECIMAL(14,6);
DEFINE mMonto                         MONEY(14,2);
DEFINE cTrans           CHAR(4);

DEFINE mTasa		MONEY(14,2);

DEFINE iDiasMes		INTEGER;

DEFINE vmto_final_cs    MONEY(14,2);
DEFINE v_capital_cs     MONEY(14,2);
DEFINE v_interes_cs     MONEY(14,2);
DEFINE v_iva_cs         MONEY(14,2);
DEFINE GLOBAL g_Empresa        CHAR(3)     DEFAULT ' ';
DEFINE GLOBAL g_NumCredito     CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';
DEFINE g_Cuenta			CHAR(20);
DEFINE g_Trans 		CHAR(4);
DEFINE mSdoDisp money(14,2);
DEFINE mMontoRet money(14,2);
DEFINE cPasoCargo char(1);
DEFINE cTranPFSI_aux	CHAR(4);
DEFINE cTranCargoTdc	CHAR(4);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
			  LET CodRet     = iSqlErr;
			  LET Mensaje = cErrorInfo;

		  IF cBegin = "S" THEN
			  ROLLBACK WORK;
		   END IF;

		   RETURN CodRet,Mensaje;
	   END IF;
	END EXCEPTION;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET CodRet              = "000000";
LET codretRev           = "00000";
LET Mensaje   = "Se realizÃÂÃÂ³ el proceso exitosamente";

LET cCredito_promo      = '';
LET cfolio_suc_promo    = '';
LET cfolio_mov_promo    = '';
LET dFecha             = DATE(1);
LET v_fecha_hoy = DATE(1);
LET dtFechaMesiversario = DATE(1);

LET cBegin           = "N";

LET v_tipocambio     = 0;
LET mMonto           =0;
LET cTrans           ="";

LET mTasa            = 0;

LET iDiasMes		 = 0;

LET vmto_final_cs    = 0;
LET v_capital_cs     = 0;
LET v_interes_cs     = 0;
LET v_iva_cs         = 0;
LET g_SdoCapInsol	 = 0;
LET g_Cuenta         = '';
LET g_Trans      	 = '';
LET mSdoDisp 	 	 = '';
LET mMontoRet 	 	 = 0;
LET cPasoCargo 		 = '';
LET vlStatusCred    = '';
LET cTranPFSI_aux	= '';
LET cTranCargoTdc	= '';



 --SET DEBUG FILE TO "/respaldosbd/Efrain/188-lib29/Saldos/sp_actualizasaldos_cred.out";
 --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10;
	SET LOCK MODE TO WAIT 3;
	
	 IF pNumProd = 'PFSI' THEN
		LET pNumProd = '6900';
		LET cTranPFSI_aux = '8654';
	 END IF;

	SELECT fecha_hoy INTO v_fecha_hoy
    FROM bdicred: "informix".sd_fechas a
    WHERE a.empresa = pEmpresa;


	--SE OBTIENE LA TRANSACCION PARA EL PAGO
	--ME 17/04/2018
	IF pMontoEfec > 0 THEN 			--PAGO ANTICIPADO EFECTIVO
		LET cTrans    = "8151";		--SU PAGO CREDISOLUCIONES EFECTIVO
		LET mMonto=pMontoEfec;
	ELIF pMontoCargo > 0 THEN		--PAGO ANTICIPADO CON CARGO A CUENTA
		LET cTrans    = "8150";		--SU PAGO CREDISOLUCIONES CARGO X CTA
		LET mMonto=pMontoCargo;
	END IF;
		
	--LET folio_suc=folio_suc;

	SELECT monto,mv_interes_cs,mv_iva_cs,mv_capital_cs
	INTO vmto_final_cs, v_interes_cs, v_iva_cs, v_capital_cs
	FROM bdicred: "informix".sd_montopagcrd where folio =  pFolioMovto;

	--FMV 21Jul14: Reasignacion de la variable global para generar los movimientos en la fecha correcta.

	--FOREACH WITH HOLD  --FMV 15JUL14: Se adiciona with hold, ya que solo cobraba 1 credisolucion en vencimiento.
		SELECT a.fecha, a.num_credito,a.folio_suc,a.folio_movto, c.prox_fecha_pago,a.num_tarjeta
		INTO dFecha,cCredito_promo,cfolio_suc_promo,cfolio_mov_promo,dtFechaMesiversario,cNumTarjeta
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
		AND a.empresa = b.empresa
		AND a.empresa = c.empresa
		and a.num_sol_prestamo = pNumcredito
		AND a.num_sol_prestamo = b.num_credito
		AND a.num_sol_prestamo = c.num_credito
		AND num_pro_prestamo = '6900';
		--AND a.status = 2
		--AND b.status_cred = 'AA';

		LET cCredito_promo = cCredito_promo;
		--- PROCESO GENERICO PARA GENERAR UN FOLIO PARA LA PROMOCION
		/*	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pUsuario)
		INTO CodRet,g_Folio;
		IF CodRet::INTEGER <> 0 THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
            IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;*/
		-- AAME 25102018 INC 27 108 Se actualiza la variable del folio con el que se generÃÂÃÂ³ de la credisolucion para guardar respaldo
        LET g_Folio =  pFolioMovto;
		--Inicia Respaldo de Tablas de Reversion
		LET g_NumCredito = cCredito_promo;
		CALL RespaldaCredito() RETURNING CodRet;
		IF (CodRet <> "000") THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
			IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;
		IF ( cCredito_promo is not null ) THEN

			--8150 y 8151         RECUPERACION CREDISOLUCIONES ANTICIPADO
			--BEGIN WORK;
			LET cBegin = "S";

			IF pMontoEfec > 0 or pMontoCargo >0  THEN
			--4202         IVA CREDISOLUCIONES ANTICIPADO
				IF v_iva_cs <> 0 THEN
					
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4202'; ELSE LET cTranCargoTdc = '8233'; END IF;
						
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_iva_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'IVA CRED ANTICIPADO', dFecha)
					RETURNING CodRet;

					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
                           END IF;
                           RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';
					
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_iva_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_iva_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4201         INTERES CREDISOLUCIONES ANTICIPADO
				IF v_interes_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4201'; ELSE LET cTranCargoTdc = '8232'; END IF;
					   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_interes_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'INTERES CREDI ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de interes credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';					
						
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_interes_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_interes_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4200         CAPITAL CREDISOLUCIONES ANTICIPADO

				IF v_capital_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4200'; ELSE LET cTranCargoTdc = '8231'; END IF;
				   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_capital_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'CAPITAL CRED ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'PAG'
					AND estatus = 'R';

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_actual = monto_actual - v_capital_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;
				
				LET g_Folio = pFolioMovto;

				IF cTrans = '8151' AND cTranPFSI_aux != '8654' Then  -- No ejecute el pago a la TDC cuando venga desde cargo automatico de Sdo a Favor para PF Sdo Inmediato.
					COMMIT WORK;
					CALL "informix".principalrefer(pempresa,cCredito_promo,'01',cNumTarjeta,USER,pSucursal,pFolioMovto,cTrans,0,mMonto,pNumcredito)
					RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;
				Elif cTrans    = "8150" THEN
					-- DSB TH 20161108
					SELECT a.numcta
					INTO g_Cuenta
					FROM  "informix".sd_verif_cuentas_crd a
					WHERE a.empresa      = pempresa 
					AND a.numcredisol  = pNumcredito;
						  
					--LET =  TRIM(cCredito_promo::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS';
					
					CALL "informix".sp_cgoctefva_abontdc(pempresa,pSucursal,pUsuario,'0438',cTrans,'0618',pFolioMovto,g_Cuenta,cCredito_promo,01,mMonto,'01',TRIM(pNumcredito::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS','',pUsuario,0)
					RETURNING CodRet, codretRev , iSqlErr, g_Trans, dFecha, mSdoDisp, mMontoRet, cPasoCargo, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					--COMMIT WORK;	
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;							
				END IF
				LET CodRet = CodRet;
			END IF;
              --COMMIT WORK;
		END IF;

		--Seccion para Quitar Retenido Excedente
		SELECT status_cred INTO vlStatusCred
		FROM bdicred: "informix".sd_maecredcrd
		WHERE num_credito = pNumcredito;

		IF vlStatusCred = 'FF' THEN
			select  monto into  v_iva_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';

			--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				select  monto into  v_iva_cs
				FROM bdicred: "informix".sd_maeretenido
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';				
			END IF;	
			
			select  monto into  v_capital_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';
				 
			IF NVL(v_iva_cs,0) = 0 THEN
				LET v_iva_cs = 0;
			END IF;
			IF NVL(v_capital_cs,0) = 0 THEN
				LET v_capital_cs = 0;
			END IF;
				
			IF v_iva_cs > 0 or v_capital_cs >=0 THEN

				UPDATE bdicred: "informix".sd_maesdos
				SET sdo_retenido = sdo_retenido - (v_iva_cs+v_capital_cs)
				WHERE empresa = '001'
				AND num_credito = cCredito_promo;

				UPDATE bdicred: "informix".sd_promocion_credito
				SET monto_int_iva = 0, monto_actual = 0, status = 6
				WHERE empresa = '001'
				AND num_sol_prestamo = pNumcredito;

				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
				
				--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = 0
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';				
				END IF;	
			
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'PAG'
				AND estatus = 'R';

			END IF;
		END IF;
		--END FOREACH;
		LET CodRet = "000000";
		LET Mensaje   = "Se realizo el proceso exitosamente";

    	RETURN CodRet,Mensaje;

	END;
END PROCEDURE
DOCUMENT
'Autor: 97468789 - Jesus Manuel Bustamante Lujano',
'Folio: 126',
'Descripcion: Se crea procedimiento para generar cargos a las credisoluciones',
'Fecha: 11/11/2016',
'BD: bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para que actualice el campo "monto" de la tabla "sd_maesdos" y se filtra por "referencia" ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 30/03/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc en el saldo retenido ',
'Modifico    : Cinthia Aguilar Xingu',
'Fecha       : Enero-2026',
'BD          : bdicred'
;

CREATE PROCEDURE "informix".sp_principal_suc_rr(pEmpresa                  CHAR(3),
												pNumCredito               CHAR(20),
												pProducto 				  CHAR(4),
												pMontoOperacionEfec       DECIMAL(18,2),
												pMontoOperacionCargCuenta DECIMAL(18,2),
												pUsuario 				  CHAR(8),
												pSucursal 				  CHAR(4),
												pFolio 					  CHAR(16),
												pTransaccion 			  CHAR(4))
RETURNING CHAR(5) AS Cod_Ret,
	CHAR(80)      AS mensaje_Retorno,
	CHAR(20) 	  AS Num_Credito,
	CHAR(20) 	  AS Cuenta_eje,
	CHAR(40) 	  AS Producto,
	CHAR(20) 	  AS Num_Cliente,
	CHAR(150) 	  AS Nom_Cliente,
	DECIMAL(18,2) AS Pago_Efectivo,
	DECIMAL(18,2) AS Pago_Cuenta,
	DECIMAL(18,2) AS Monto_Operacion,
	DECIMAL(18,2) AS Saldo_Actual,
	CHAR(60)      AS Status_Actual;

---DECLARACIONES
DEFINE iSqlErr                      INTEGER;
DEFINE iIsamErr                     INTEGER;
DEFINE cErrorInfo                   CHAR(80);
DEFINE cMensajeRet                  CHAR(80);
DEFINE cCodRet                      CHAR(6);
DEFINE cSucursal             	    CHAR(4);
DEFINE dMontoOperacion        		DECIMAL(18,2);
DEFINE cBanderarespaldo      	    CHAR(1);
DEFINE GLOBAL gRespaldoActivo 		CHAR(1) DEFAULT '1';
DEFINE cTransacc_rel          		CHAR(4);
DEFINE dMontoFinanciado      	    DECIMAL(18,2);
DEFINE dIvaSuc                		DECIMAL(5,3);
DEFINE dMontoInt              		DECIMAL(18,2);
DEFINE dPagoMensualidades     		DECIMAL(18,2);
DEFINE dMontoOperacionEfecAux   	DECIMAL(18,2);
DEFINE dMontoOperacionCargCuentaAux DECIMAL(18,2);
DEFINE GLOBAL g_Transacc    		CHAR(4)        DEFAULT '';
DEFINE GLOBAL g_TransaccSuc 		CHAR(4)        DEFAULT '';
DEFINE g_CodigoFun    				INTEGER;

---VARIABLES DEL PROCESO DE sp_principal_rr
DEFINE cCod_Ret		      CHAR(5);
DEFINE cMensaje_Ret       CHAR(125);
DEFINE dSdo_Ant		      DECIMAL(18,2);
DEFINE dComision	      DECIMAL(18,2);
DEFINE dIva_Com		      DECIMAL(18,2);
DEFINE dInt_Mora	      DECIMAL(18,2);
DEFINE dIva_Int_Mora      DECIMAL(18,2);
DEFINE dInt_Vdo		      DECIMAL(18,2);
DEFINE dIva_Int_Vdo       DECIMAL(18,2);
DEFINE dInt_Ordi          DECIMAL(18,2);
DEFINE dIva_Int_Ordi      DECIMAL(18,2);
DEFINE dCapital		      DECIMAL(18,2);
DEFINE dMonto_Pago        DECIMAL(18,2);
DEFINE cCuenta_Eje        CHAR(20);
DEFINE dSdo_Actual        DECIMAL(18,2);
DEFINE dPago_Min     	  DECIMAL(18,2);
DEFINE cFecha_Limite_Pago CHAR(17);

-- VARIABLES sp_principal_pp
DEFINE cCodigoRetorno_P    CHAR(5);
DEFINE cMensajeRetorno_P   CHAR(125);
DEFINE dSdo_Anterior_P     DECIMAL(18,2);
DEFINE dComision_P         DECIMAL(18,2);
DEFINE dIva_Com_P          DECIMAL(18,2);
DEFINE dInt_Mora_P         DECIMAL(18,2);
DEFINE dIva_Int_Mora_P     DECIMAL(18,2);
DEFINE dInt_Vdo_P          DECIMAL(18,2);
DEFINE dIva_Int_Vdo_P      DECIMAL(18,2);
DEFINE dInt_Ordi_P         DECIMAL(18,2);
DEFINE dIva_Int_Ordi_P     DECIMAL(18,2);
DEFINE dCapital_P          DECIMAL(18,2);
DEFINE dMonto_Pago_P       DECIMAL(18,2);
DEFINE cCuenta_Eje_P       CHAR(20);
DEFINE dSdoActual_P        DECIMAL(18,2);
DEFINE dPago_Min_P         DECIMAL(18,2);
DEFINE cFecha_LimitePago_P CHAR(17);

-- VARIABLES  sp_pago_anticipado_pp
DEFINE cCod_Retorno_Ap       CHAR(5);
DEFINE cMens_Ret          	 CHAR(125);
DEFINE dSdo_Anterior         DECIMAL(18,2);
DEFINE dComision_Ap          DECIMAL(18,2);
DEFINE dIva_Com_Ap           DECIMAL(18,2);
DEFINE dInt_Mora_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Mora_Ap      DECIMAL(18,2);
DEFINE dInt_Vdo_Ap           DECIMAL(18,2);
DEFINE dIva_Int_Vdo_Ap       DECIMAL(18,2);
DEFINE dInt_Ordi_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Ordi_Ap      DECIMAL(18,2);
DEFINE dCapital_Ap           DECIMAL(18,2);
DEFINE dMonto_Pago_Ap        DECIMAL(18,2);
DEFINE cCuenta_Eje_Ap        CHAR(20);
DEFINE dSdo_Act_Ap           DECIMAL(18,2);
DEFINE dPago_Min_Ap          DECIMAL(18,2);
DEFINE cFecha_Limite_Pago_Ap CHAR(17);

DEFINE cCodRetCD	  CHAR(6);
DEFINE cMensajeCD 	  CHAR(80);
DEFINE cNumCredCD 	  CHAR(20);
DEFINE cNumCteCD 	  CHAR(20);
DEFINE cNomProductoCD CHAR(40);
DEFINE cNumTarjetaCD  CHAR(20);
DEFINE cNomCteCD      CHAR(150);

--VARIABLES para sp_consulta_saldos_general
DEFINE cCodRetSP			 CHAR(6);
DEFINE cMensajeSP			 CHAR(80);
DEFINE cNumCredito      	 CHAR(20);
DEFINE cCodTipCred      	 CHAR(2);
DEFINE cDescStatusCred  	 CHAR(60);
DEFINE iIdUnidadProd     	 INTEGER;
DEFINE cCodCaract2       	 CHAR(3);
DEFINE dtFechaOrigen    	 DATE;
DEFINE dtFechaProxPago  	 DATE;
DEFINE dPagoMinimo      	 DECIMAL(18,2);
DEFINE dtFechaUltPago    	 DATE;
DEFINE iPlazo           	 INTEGER;
DEFINE iPagosRealizados 	 INTEGER;
DEFINE dLineaOtorgada    	 DECIMAL(18,2);
DEFINE dTasaInteres      	 DECIMAL(9,6);
DEFINE dTasaMoratorios  	 DECIMAL(9,6);
DEFINE dMontoSBC        	 DECIMAL(14,2);
DEFINE dCapVig           	 DECIMAL(18,2);
DEFINE dCapTrans         	 DECIMAL(18,2);
DEFINE dCapVdoExig       	 DECIMAL(18,2);
DEFINE dCapVdoNoExig    	 DECIMAL(18,2);
DEFINE dSdoActCap        	 DECIMAL(18,2);
DEFINE dIntVig           	 DECIMAL(18,2);
DEFINE dIntVdo           	 DECIMAL(18,2);
DEFINE dIntMoratorio     	 DECIMAL(18,2);
DEFINE dIntMes          	 DECIMAL(18,2);
DEFINE dSdoActInt        	 DECIMAL(18,2);
DEFINE dIvaIntVig        	 DECIMAL(18,2);
DEFINE dIvaIntVdo        	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
DEFINE dIvaIntMes        	 DECIMAL(18,2);
DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
DEFINE dComPend          	 DECIMAL(18,2);
DEFINE dIvaCom            	 DECIMAL(18,2);
DEFINE dSdoRetenido     	 DECIMAL(18,2);
DEFINE dSdoTotalLiq     	 DECIMAL(18,2);
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);
DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE iCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE iCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE iAplicoPago           INTEGER;

-- DSB  - TH - EM -2017-03-16
DEFINE dMontoAux 			 DECIMAL(18,2);
DEFINE dtFechaActual	  	 DATE;
DEFINE dFechaAmortiza    	 DATE;
DEFINE mMensualidad          DECIMAL(18,2);
DEFINE iFlaPagoAnticipado    INTEGER;
DEFINE cCodigoFunth      	 CHAR(3);
DEFINE g_TransaccAnt		 CHAR(4);
DEFINE cCodRetAux		CHAR(6);
DEFINE dNumCredito      CHAR(20);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE c_Folio_Suc		  CHAR(16);
--AAME Quita Validacion If exits select por variables 21052018
DEFINE cnumcredisol   CHAR(20);
DEFINE ccapital_status CHAR(1);
DEFINE vNumCte         CHAR(20); --RQM 10 915-4
DEFINE vNumCel         CHAR(13); --RQM 10 915-4
DEFINE vFecha          CHAR(10); --RQM 10 915-4
DEFINE vstcred         CHAR(2); --RQM 10 915-4
DEFINE vMontoPago      DECIMAL(18,2); --RQM 10 915-4
DEFINE banderaApoyo		SMALLINT;
---- CONDONACIONES Y QUITAS 
DEFINE indicaQuitaCondona	CHAR (1);
DEFINE montoQuita			DECIMAL(18,2);
DEFINE montoCondona			DECIMAL(18,2);
DEFINE bandera_quita_restante	SMALLINT;
DEFINE monto_condona			DECIMAL(18,2);
DEFINE monto_qc				DECIMAL(18,2);
DEFINE totalquitacapvenc    DECIMAL(18,2);
DEFINE status_cred_quita	CHAR(2);
DEFINE p_Divisa             CHAR(2);
DEFINE dFechaCuota			DATE;
DEFINE monto_balanza		DECIMAL(18,2);
DEFINE monto_orden			DECIMAL(18,2);
DEFINE condona_accesorios 	DECIMAL(18,2);
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0;
DEFINE vFechaVencCred		DATE;
DEFINE cTranPFSI_aux		CHAR(4);
DEFINE cEnvioSMSRespMultic	CHAR(1);
DEFINE cbanfamilia			 CHAR(3); -- RQM 10 1177
DEFINE ATR_Cred    INTEGER;
DEFINE iPagosVencidos    INTEGER;

DEFINE vMesesVencidos		SMALLINT;
DEFINE vMesesHistoria		INTEGER;
DEFINE dMontoOtorgado   	DECIMAL(18,2);
DEFINE vIntVencido          MONEY(18,2);
DEFINE vIvaIntVigente		DECIMAL(14,2);
DEFINE vIvaIntVencido		DECIMAL(14,2); --RQM 09 459
DEFINE vCapitalMtoCuota		DECIMAL(14,2);
DEFINE vSdoCredito			DECIMAL(18,2);
DEFINE vIntMoratorio        MONEY(18,2); --RQM 09 459
DEFINE dSdoCapInsoluto      DECIMAL(14,2); 

DEFINE dFechapago   		DATE;  
DEFINE dFechaUltMov 		DATE; 
DEFINE dFechanegociacion    DATE;
DEFINE dPagorealizado       DECIMAL(14,2);
DEFINE dPagoParcial         DECIMAL(14,2);

DEFINE wBegin           CHAR(1);

--INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = '';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cCodRet         = '00000';
LET cSucursal       = '';
LET dMontoOperacion = 0;
LET g_Transacc      = pTransaccion;
LET cTransacc_rel   = '';

LET dMontoFinanciado     		 = 0;
LET dIvaSuc              		 = 0;
LET dMontoInt            		 = 0;
LET dPagoMensualidades           = 0;
LET dMontoOperacionEfecAux       = pMontoOperacionEfec;
LET dMontoOperacionCargCuentaAux = pMontoOperacionCargCuenta;
LET g_CodigoFun					 = 0;

--VARIABLES DEL PROCESO DE sp_principal_rr
LET cCod_Ret		   = '';
LET cMensaje_Ret       = '';
LET dSdo_Ant		   = 0.0;
LET dComision		   = 0.0;
LET dIva_Com		   = 0.0;
LET dInt_Mora		   = 0.0;
LET dIva_Int_Mora      = 0.0;
LET dInt_Vdo		   = 0.0;
LET dIva_Int_Vdo       = 0.0;
LET dInt_Ordi          = 0.0;
LET dIva_Int_Ordi      = 0.0;
LET dCapital		   = 0.0;
LET dMonto_Pago        = 0.0;
LET cCuenta_Eje        = '';
LET dSdo_Actual        = 0.0;
LET dPago_Min          = 0.0;
LET cFecha_Limite_Pago = '';

--VARIABLES sp_principal_pp
LET cCodigoRetorno_P    = '00000';
LET cMensajeRetorno_P   = '';
LET dSdo_Anterior_P     = 0;
LET dComision_P         = 0;
LET dIva_Com_P          = 0;
LET dInt_Mora_P         = 0;
LET dIva_Int_Mora_P     = 0;
LET dInt_Vdo_P          = 0;
LET dIva_Int_Vdo_P      = 0;
LET dInt_Ordi_P         = 0;
LET dIva_Int_Ordi_P     = 0;
LET dCapital_P          = 0;
LET dMonto_Pago_P       = 0;
LET cCuenta_Eje_P       = 0;
LET dSdoActual_P        = 0;
LET dPago_Min_P         = 0;
LET cFecha_LimitePago_P = '';

-- VARIABLES sp_pago_anticipado_ppsr y sp_pago_anticipado_pp
LET cCod_Retorno_Ap          = '00000';
LET cMens_Ret             = '';
LET dSdo_Anterior         = 0;
LET dComision_Ap          = 0;
LET dIva_Com_Ap           = 0;
LET dInt_Mora_Ap          = 0;
LET dIva_Int_Mora_Ap      = 0;
LET dInt_Vdo_Ap           = 0;
LET dIva_Int_Vdo_Ap       = 0;
LET dInt_Ordi_Ap          = 0;
LET dIva_Int_Ordi_Ap      = 0;
LET dCapital_Ap           = 0;
LET dMonto_Pago_Ap        = 0;
LET cCuenta_Eje_Ap        = '';
LET dSdo_Act_Ap           = 0;
LET dPago_Min_Ap          = 0;
LET cFecha_Limite_Pago_Ap = '';

LET cCodRetCD			= '';
LET cMensajeCD 			= '';
LET cNumCredCD 			= '';
LET cNumCteCD 			= '';
LET cNomProductoCD		= '';
LET cNumTarjetaCD    	= '';
LET cNomCteCD     		= '';
LET gRespaldoActivo    	= '0';
LET cBanderarespaldo	= '1';

--INICIALIZACIONES PARA sp_consulta_saldos_general
LET cCodRetSP             = '';
LET cMensajeSP			  = '';
LET cNumCredito      	  = '';
LET cCodTipCred      	  = '';
LET cDescStatusCred  	  = '';
LET iIdUnidadProd     	  = 0;
LET cCodCaract2       	  = '';
LET dtFechaOrigen    	  = DATE(1);
LET dtFechaProxPago  	  = DATE(1);
LET dPagoMinimo      	  = 0;
LET dtFechaUltPago    	  = DATE(1);
LET iPlazo           	  = 0;
LET iPagosRealizados 	  = 0;
LET dLineaOtorgada    	  = 0;
LET dTasaInteres      	  = 0;
LET dTasaMoratorios  	  = 0;
LET dMontoSBC        	  = 0;
LET dCapVig           	  = 0;
LET dCapTrans         	  = 0;
LET dCapVdoExig       	  = 0;
LET dCapVdoNoExig    	  = 0;
LET dSdoActCap        	  = 0;
LET dIntVig           	  = 0;
LET dIntVdo           	  = 0;
LET dIntMoratorio     	  = 0;
LET dIntMes          	  = 0;
LET dSdoActInt        	  = 0;
LET dIvaIntVig        	  = 0;
LET dIvaIntVdo        	  = 0;
LET dIvaIntMoratorio  	  = 0;
LET dIvaIntMes        	  = 0;
LET dSdoActIvaInt     	  = 0;
LET dComPend          	  = 0;
LET dIvaCom            	  = 0;
LET dSdoRetenido     	  = 0;
LET dSdoTotalLiq     	  = 0;
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;
LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET iCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET iCausaCred            = 0;
LET cDescSitEspCred       = '';
LET iAplicoPago           = 0;

-- DSB - TH - EM - 2017-03-16
LET dMontoAux 			= pMontoOperacionEfec + pMontoOperacionCargCuenta;
LET dtFechaActual  	 	= DATE(1);
LET dFechaAmortiza    	= DATE(1);
LET mMensualidad        = 0;
LET iFlaPagoAnticipado  = 0;
LET g_TransaccAnt       = '';
LET cCodRetAux			= '';
LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = 0;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     ='';
--AAME Quita Validacion If exits select por variables 21052018
LET cnumcredisol        = '';
LET ccapital_status 	= '';
LET vNumCte             = ''; --RQM 10 915-4
LET vNumCel             = ''; --RQM 10 915-4
LET vFecha              = ''; --RQM 10 915-4
LET vstcred             = ''; --RQM 10 915-4
LET vMontoPago          = 0; --RQM 10 915-4

LET banderaApoyo		= 0;
---- CONDONACIONES Y QUITAS 
LET indicaQuitaCondona	= '';
LET montoQuita			= 0;
LET montoCondona		= 0;
LET bandera_quita_restante = 0;
LET monto_condona			= 0;
LET monto_qc			= 0;
LET totalquitacapvenc   = 0;
LET status_cred_quita	= 0;
LET p_Divisa			= '';
LET dFechaCuota			= DATE(1);
LET monto_balanza		= 0;
LET monto_orden			= 0;
LET condona_accesorios	= 0;
LET vFechaVencCred		= DATE (1);
-- LET gprocesa				= 0;	--- variable global que valida si procesa capital para quitas
LET cTranPFSI_aux		= '';
LET cEnvioSMSRespMultic	= '';
LET cbanfamilia				= ''; -- RQM 10 1177
LET ATR_Cred  =0;
LET iPagosVencidos = 0;
--RQM 09 459
LET vMesesVencidos		= 0;
LET vMesesHistoria		= 0;
LET dMontoOtorgado  	= 0;
LET vIntVencido 		= 0;
LET vIvaIntVigente		= 0;
LET vIvaIntVencido		= 0;
LET vCapitalMtoCuota	= 0;
LET vSdoCredito			= 0;
LET vIntMoratorio 		= 0; --RQM 09 459
LET dSdoCapInsoluto     = 0;

LET dFechapago          = DATE (1);
LET dFechaUltMov        = DATE (1);
LET dFechanegociacion   = DATE (1);
LET dPagorealizado      = 0;
LET dPagoParcial        = 0;
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet  = cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
       END IF;
    END EXCEPTION;
  
    SELECT fecha_hoy
	INTO dtFechaActual
	FROM  bdicred:"informix".sd_fechas
	where empresa= '001';
		
	SELECT status_cred,divisa,fecha_vencim
	INTO status_cred_quita,p_Divisa,vFechaVencCred
	FROM bdicred:sd_maecredcrd
	WHERE num_credito = pNumCredito;	
	---- realiza consulta para validar si es quita, condonacion o quita por operaciones
	SELECT indicador_proceso,mto_quita,monto_condonado,fecha_negociacion --,NVL(saldo_tot_liquidar,0)
		INTO indicaQuitaCondona,montoQuita,montoCondona,dFechanegociacion --, totalquitacapvenc
	FROM bdicred:sd_bitacora_quitacondonacion
	WHERE num_credito = pNumCredito
	AND estatus_proceso = 'PR';	
	--AND fecha_negociacion >= dtFechaActual;

	IF indicaQuitaCondona IS NULL OR indicaQuitaCondona = '' THEN
		LET indicaQuitaCondona = '';
	END IF;
	
	IF montoQuita IS NULL OR montoQuita = '' THEN
		LET montoQuita = 0;
	END IF;
	
	IF montoCondona IS NULL OR montoCondona = '' THEN
		LET montoCondona = 0;
	END IF;
	IF dFechanegociacion IS NULL OR dFechanegociacion ='' THEN
		LET dFechanegociacion   = DATE (1);
	END IF;
	
    LET monto_qc = montoQuita + montoCondona;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	--- se agrega validacion para que no mande error cuando es quita operativa, pueda mandar pago cero	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUsuario,'') = ''
	OR NVL(pSucursal,'') = ''   OR NVL(pFolio,'') = ''  OR NVL(g_Transacc,'') = ''
	OR (NVL(pMontoOperacionEfec,0) = 0 AND NVL(pMontoOperacionCargCuenta,0) = 0 AND indicaQuitaCondona NOT IN ('O','U')) THEN
		LET cCodRet = '00361';
		LET cMensajeRet  = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pTransaccion = '8654' THEN	-- Banderas para cargo sdo a favor en tdc para PG Sdo Inmediato
		LET cTranPFSI_aux = 'PFSI';
	END IF;

	LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
    
	SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
	INTO g_Transacc,g_CodigoFun --, cTransacc_rel
	FROM bdicred:"informix".sd_conceptospagomanualcrd
	WHERE transacc_suc = g_TransaccSuc
	AND num_producto = pProducto;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	-- --AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1 SE OBTIENE LA FAMILIA DEL PRODUCTO
	SELECT familia
	INTO cbanfamilia
	FROM  "informix".sd_definicion 
	WHERE empresa = pEmpresa AND num_producto = pProducto;
	
	LET vMontoPago = pMontoOperacionEfec+pMontoOperacionCargCuenta; --RQM 10 915-4

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;


	SELECT mensualidad INTO mMensualidad
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_sol_prestamo = pNumCredito
	AND empresa = pEmpresa;


	LET g_Transacc = g_Transacc;
	LET vMontoPago = vMontoPago;
	LET indicaQuitaCondona = indicaQuitaCondona;
	LET status_cred_quita = status_cred_quita;
	
	IF pProducto = '6800' THEN		-- Identifica el envio de sms o no
		IF g_Transacc = '7590' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 2; -- atm
			LET cEnvioSMSRespMultic = '0';
			 
		ELIF g_Transacc = '8738' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 3; -- whats
			LET cEnvioSMSRespMultic = '0';

		ELIF g_Transacc = '8317'	THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 1; -- sms
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '5025' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 4; -- app
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '7506' THEN
			LET cEnvioSMSRespMultic = '0';		
		ELSE	   
			LET cEnvioSMSRespMultic = '1';
		END IF;
	END IF;

	SELECT NVL(atr,0),mto_fin_ven_trasp
	INTO ATR_Cred ,iPagosVencidos
	FROM bdicred:"informix".sd_maesdoscrd 
	WHERE num_credito = pNumCredito
	AND empresa       = pEmpresa;
			

	--- Validacion para Quita, Condonacion, O = Quita de Operaciones sin cancelcion de linea de PD, U = Quita Operacion con cancelacion si es PD
	IF g_Transacc NOT IN ('8671','8701') AND vMontoPago >= monto_qc  AND dFechanegociacion >= dtFechaActual
	--AND  ((indicaQuitaCondona = 'Q' AND status_cred_quita in ('BT')) OR (indicaQuitaCondona = 'C' AND status_cred_quita in ('BT','BA')))
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3') and ATR_Cred>0))  )
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR ( pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) )) -- se agrega validacion por IFRS AEH
	OR (g_Transacc NOT IN ('8671','8701') AND (indicaQuitaCondona IN ('O','U') )) THEN 
	--	IF pProducto IN ('6300','7600','7700','6800','6011') THEN --PRESTAMO 12 18 y 24, PRESTAMO DIGITAL
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;

		UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago,int_vencido = dIntVdo,iva_int_vencido = dIvaIntVdo, cap_vigente = dCapVig, iva_int_vigente = dIvaIntVig,
		cap_vigente_cq = NVL(dCapVig,0), iva_int_vigente_cq =  dIvaIntVig,
		int_moratorio = dIntMoratorio, iva_int_mora = dIvaIntMoratorio,int_vigente_cq =  dIntVig,
		int_vencido_cq = dIntVdo,iva_int_vencido_cq = dIvaIntVdo,
		int_moratorio_cq = dIntMoratorio, iva_int_mora_cq = dIvaIntMoratorio,
		cap_vencido = dCapVdoExig, int_vigente = dIntVig, cap_vencido_cq = dCapVdoExig,
         -----------------------------------------------------------------------	 		
		meses_vencidos = dPagosVdos, copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0), 
		saldo_tot_liquidar = dSdoTotalLiq WHERE num_credito = pNumCredito and estatus_proceso='PR';
		-----------------------------------------------------------------------	
		COMMIT;
		BEGIN;	
		IF pProducto NOT IN ('6011','8600') THEN

			---- total balanza
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_orden
			---into monto_balanza
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 = 'V'		---- V es Orden
			and capital_status = '2'
			AND num_credito = pNumCredito;
				
			---- total orden
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_balanza
			--- into monto_orden
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 <> 'V'		--- diferente de V es balanza
			and capital_status = '2'
			AND num_credito = pNumCredito;

			IF monto_balanza IS NULL THEN LET monto_balanza = 0; END IF;
			IF monto_orden IS NULL THEN LET monto_orden = 0; END IF;
							
			--			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_balanza;
			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_orden;
		
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap + monto_balanza THEN

					LET condona_accesorios = dSdoTotalLiq - vMontoPago;	 -- 	- (vMontoPago - (dSdoActCap + monto_balanza));
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%				
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;	
				END IF;
			END IF;
		ELSE

			LET condona_accesorios = dSdoTotalLiq - dSdoActCap;
			----- QUITA DE REESTRUCTURAS  
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap THEN
				
					LET condona_accesorios = dSdoTotalLiq - vMontoPago;
					
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios y capital que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%	
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;	
				END IF;
			END IF;

		END IF;
			LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
			SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
			INTO g_Transacc,g_CodigoFun --, cTransacc_rel
			FROM bdicred:"informix".sd_conceptospagomanualcrd
			WHERE transacc_suc = g_TransaccSuc
			AND num_producto = pProducto;
			--- Apaga respaldo
			IF condona_accesorios > 0  THEN
				LET gRespaldoActivo = '1';
				LET gprocesa = 2;
			END IF;
	     --Si el pago es menor al monto quita/condonado y la fecha de pago sea menor o igual a la fecha negociacion se actualiza el pago en la bitacora
	ELIF g_Transacc NOT IN ('8671','8701') AND vMontoPago < monto_qc  AND dFechanegociacion >= dtFechaActual
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) ))    THEN
		 
        UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago
        WHERE num_credito = pNumCredito and estatus_proceso='PR';
COMMIT;	
	BEGIN; 
	LET indicaQuitaCondona = '';
		
	ELIF dFechanegociacion < dtFechaActual AND g_Transacc NOT IN ('8671','8701') AND ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 		
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5))) THEN
		
			UPDATE "informix".sd_bitacora_quitacondonacion 
			SET estatus_proceso = 'CN',fecha_status = dtFechaActual
            WHERE num_credito = pNumCredito and estatus_proceso='PR';
	COMMIT;	
	
	BEGIN; 
		LET indicaQuitaCondona = '';
		   
	ELSE
		-- Si no pasa por el flujo y variable global esta activa no realiza respaldo, prepara el anticipo de quita
		LET indicaQuitaCondona = '';
		IF gprocesa = 2 THEN
			LET gRespaldoActivo = '1';
		END IF;
	END IF;

	--AAME Quita Validacion If exits select por variables 21052018
	SELECT limit 1 NVL(a.capital_status,'')
	INTO ccapital_status
	FROM bdicred:"informix".sd_amortiza_creditocrd a
	WHERE a.empresa = pEmpresa
	AND a.num_credito = pNumCredito
	AND a.capital_status IN ('1','2','7','6');
		
	IF NVL(ccapital_status,'') = '' THEN
		SELECT limit 1 NVL(a.capital_status,'')
		INTO ccapital_status
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = pNumCredito
		AND a.capital_status IN ('3');
	END IF;

	 --se valida si se va realizar un pago normal.
	IF ccapital_status IN ('1','2','7','6') THEN --AAME Quita Validacion If exits select por variables 21052018

		--se obtiene la informacion del  cliente
		SELECT  a.sucursal, b.monto_financiado, round((today - a.fecha_apertura)/30.4)
		INTO  cSucursal, dMontoFinanciado, vMesesHistoria
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_maesdoscrd b,
		bdicred:"informix".sd_maecredanexocrd c
		WHERE a.num_credito = pNumCredito
		AND a.empresa       = pEmpresa
		AND b.empresa       = a.empresa
		AND b.num_credito   = a.num_credito
		AND c.num_credito   = b.num_credito
		AND c.empresa       = b.empresa;

		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND sucursal  = cSucursal;

		-- 2011-11-30 Se cambia metodo de calculo de moratorio
		SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) +	(SUM(round((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)*dIvaSuc,2)))
		INTO dMontoInt
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCredito
		AND capital_status IN ('2','7','1','6');

		LET dMontoFinanciado = dMontoFinanciado + dMontoInt;
		---- se agrega transacciones de quitas solo para pago en efectivo
		IF g_Transacc IN ('7970','8205','8160','8286', '7990','8335','8671','8701','8654','4320')  THEN--pago en efectivo --DSB 20/11/2015 se Agrega la Transaccion 8160 --- 8335 SPEI

			IF pMontoOperacionEfec <= dMontoFinanciado THEN
				LET dPagoMensualidades = pMontoOperacionEfec;
				LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionEfec;
				LET pMontoOperacionEfec = 0;
			ELSE
				LET dPagoMensualidades = dMontoFinanciado;
				LET pMontoOperacionEfec = pMontoOperacionEfec - dPagoMensualidades;
				LET dMontoFinanciado =0;
			END IF;

			IF pProducto IN ('6011','8600') THEN --REESTRUCTURAS
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--- Se agrega variable para indicar si el pago es mayor a cero de lo contrario mandara error el sp principal pp
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS
																								  
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS			
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual = dSdoActual_P;
				LET cCuenta_Eje = cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			END IF;			
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionEfec = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionEfec > 0 THEN
				IF pProducto IN ('6011','8600') THEN
					-- REALIZA EL PAGO ANTICIPADO
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					IF cCod_Ret::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')   INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual = dSdo_Actual;
					LET cCuenta_Eje = cCuenta_Eje;
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN	
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
																		
																								   
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN
				-- REALIZA EL PAGO ANTICIPADO

					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;

					LET dSdo_Actual=dSdo_Act_Ap;
					LET cCuenta_Eje= cCuenta_Eje_Ap;

				END IF;
			END IF;
		END IF;
					
		--IF g_Transacc in ('7998') OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
		IF g_Transacc in ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF dMontoFinanciado > 0 THEN
				IF pMontoOperacionCargCuenta <= dMontoFinanciado THEN
				  LET dPagoMensualidades = pMontoOperacionCargCuenta;
				  LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionCargCuenta;
				  LET pMontoOperacionCargCuenta = 0;
				ELSE
				  LET dPagoMensualidades = dMontoFinanciado;
				  LET pMontoOperacionCargCuenta = pMontoOperacionCargCuenta - dPagoMensualidades;
				  LET dMontoFinanciado =0;
				END IF;
			END IF;

			--pago con cargo a cuenta     
			IF pProducto IN ('6011','8600') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN
			--AAME RQM 10 1177 Se valida la familia de productos Prestamos y Linea Credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual=dSdoActual_P;
				LET cCuenta_Eje= cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			
			END IF;
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionCargCuenta = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionCargCuenta > 0  THEN
				IF pProducto IN  ('6011','8600') THEN
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;
						 
					IF cCod_Ret::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual=dSdo_Actual;
					LET cCuenta_Eje= cCuenta_Eje;
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
				--AAME RQM 10 1177 Se valida la familia de productos Prestamo y linea de credito a Plazo
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN

					-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;
		 
					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
 					
					LET dSdo_Actual = dSdo_Act_Ap;
					LET cCuenta_Eje = cCuenta_Eje_Ap;
				END IF;
			END IF;
		END IF;

		--cuando entra por este flujo se realiza un pago anticipado
	ELIF ccapital_status IN ('3') THEN --AAME Quita Validacion If exits select por variables 21052018
	---- se agregan transacciones de quitas para pago anticipado solo en pago efectivo	
		IF g_Transacc IN ('7970','8205','8160','8286','7990','8335','8671','8701','8654','4320')  THEN --pago en efectivo --- 8335 SPEI

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamos y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN
				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
								
			END IF;
		END IF;

		--IF g_Transacc ='7998' OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'
		IF g_Transacc IN ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'

			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamo y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN

				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp (pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
			END IF;
		END IF;
	ELSE
		-- Cuando el credito ya esta saldado... y no es posible aplicar el pago
		LET cCodRet = '00374';
		LET cMensajeRet= 'El credito ya esta saldado';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	IF pProducto = '6900' AND g_Transacc IN ("8150","8160","8654") THEN	
		IF g_Transacc ="8150" THEN
			LET mMontoCargo = dMontoAux;
		END IF;

		IF g_Transacc in ("8160","8654") THEN
			LET mMontoEfec = dMontoAux;
			--AAME Quita Validacion If exits select por variables 21052018
			Select limit 1 numcredisol 
			INTO cnumcredisol
			from  bdicred: "informix".sd_verif_cuentas_crd  
			where empresa = pempresa AND numcredisol = pNumCredito;
			
			IF cnumcredisol <> '' Then
				DELETE FROM bdicred: "informix".sd_verif_cuentas_crd WHERE empresa = pempresa AND numcredisol=pNumCredito;
			END IF
		END IF;

		IF cTranPFSI_aux = 'PFSI' THEN
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,'PFSI',mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		ELSE
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,pProducto,mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		END IF;

	   IF (cCodRetAux <> "000000") THEN
		   LET cCodRet      = "00053";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago del credisolucion";

			/*IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;*/
			RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
		END IF;	
	END IF;
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = cCodRetCD;
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	LET dMontoOperacion = dMontoOperacionEfecAux + dMontoOperacionCargCuentaAux;
	
	--Se ejecuta sp para poder obtener el status del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
	IF cCodRetSP <> '000000' THEN
		LET cCodRet = cCodRetSP;
		LET cMensajeRet= cMensajeSP;
	END IF;
	
	IF dSdoActCap <= 0 THEN
		IF pProducto = '6900' AND g_Transacc IN("8150","8160","8654") THEN
			--Seccion para Quitar Retenido Excedente
			SELECT monto_actual,monto_int_iva,folio_movto,num_credito INTO mMonto,v_iva_cs,cfolio_mov,dNumCredito
			FROM "informix".sd_promocion_credito
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maesdos
			SET sdo_retenido = sdo_retenido - (mMonto + v_iva_cs)
			WHERE empresa = '001'
			AND num_credito = dNumCredito;

			UPDATE bdicred: "informix".sd_promocion_credito
			SET monto_actual=0,monto_int_iva = 0, status = 6
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = dNumCredito
				AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
			END IF;	

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';	
		END IF;
	END IF;
	
	-- RQM 09 473: TRIAD INI
	EXECUTE PROCEDURE "informix".sp_graba_indicador_cnr(pEmpresa,pNumCredito,dMontoAux,g_Transacc,g_CodigoFun,1,dtFechaActual,pFolio,0,0,2)
	INTO cCodRet;
	
	--IF pProducto = '6800' and pTransaccion not in ('611','620') THEN  -- RQM 10 915-4 
	--AAME RQM 10 1177 Se valida la familia de Linea Credito a Plazo
	IF (cbanfamilia IN ('003') AND pProducto NOT IN('6400')) and pTransaccion not in ('611','620')  THEN	 -- RQM 10 915-4
		SELECT NVL(a.telefono,''), b.status_cred INTO vNumCel,vstcred								
		FROM bdinteg:si_telefonos a
		JOIN bdicred:sd_maecredcrd b on a.numcte = b.numcte
		WHERE a.tipo_tel = 2 AND a.verificado = 'V' AND a.status_tel = 'A' AND b.num_credito = pNumCredito; 
		
		SELECT COUNT (*)
			INTO banderaApoyo
		FROM bdicred:sd_diferir
		WHERE numcte = cNumCteCD
		AND canal_baja = 21;
		
		IF banderaApoyo = 0 THEN
			IF vNumCel <> '' OR vNumCel IS NOT NULL THEN
				LET vFecha = DAY(dtFechaActual) || '/' || MONTH(dtFechaActual) || '/' || YEAR(dtFechaActual);						
					IF vstcred = 'FF'  THEN
						----Envio de mensaje de Liquidacion del prestamo						 								 
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_FF','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					ELSE
						IF cEnvioSMSRespMultic = '1' THEN  
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_CAUT','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					END IF;
			END IF;
		END IF;
	END IF; 
	
	IF  (indicaQuitaCondona IN ('Q','C','O','U') AND  g_Transacc NOT IN ('8671','8701'))   THEN	
		
		SELECT 
		SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
        SUM((mora_provi_ordi + mora_provi_cope + mora_sdo_ordi) - (mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)),
        NVL(SUM(interes_debe - interes_pagado),0),
		SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
		INTO vIntVencido,
			vIntMoratorio,
			vIvaIntVigente, 
			vIvaIntVencido
		FROM "informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_credito = pNumCredito;
		
		SELECT capital_mto_cuota INTO vCapitalMtoCuota
		FROM sd_amortiza_creditocrd WHERE num_credito = pNumCredito
		AND fecha_cuota = dtFechaActual;
		
		IF  indicaQuitaCondona IN ('Q','O','U') AND dSdoTotalLiq > 0 THEN
			
			LET gprocesa = 2;
			
			IF pProducto NOT IN ('6011','8600') THEN
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de PP
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8671')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
			ELSE 
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de Rees
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8701')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;			
			END IF;
		END IF;
		----- Se omite la O Quita de operaciones ya que no requieren se cancele
		IF  pProducto = '6800' AND indicaQuitaCondona IN ('Q','U') THEN
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital, cuando el capital se salda con el pago y se debe cancelar el credito
			CALL "informix".genmovcrd(pEmpresa,pNumCredito, '6800', 2, '002', dtFechaActual,dLineaOtorgada,pFolio,pSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
			RETURNING cCodigoRetorno_P, cMensajeRetorno_P;

			UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = dtFechaActual, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = pNumCredito;
			
		END IF;
		
		--Se consulta el saldo capital insoluto y la fecha pago
		SELECT A.sdo_cap_insoluto,B.fecha_proceso,A.monto_otorgado,A.fecha_ult_mov
		INTO dSdoCapInsoluto, dFechapago, dMontoOtorgado,dFechaUltMov
		FROM bdicred:"informix".sd_maesdoscrd A
		INNER JOIN bdicred:"informix".sd_maecredanexocrd B ON B.num_credito = A.num_credito
		WHERE A.num_credito = pNumCredito
		AND A.empresa = pEmpresa;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;
		
		LET vSdoCredito = dMontoOtorgado-dSdoCapInsoluto-dSdoRetenido;


		----------------------------------------------------------------------------
		UPDATE "informix".sd_bitacora_quitacondonacion 
			SET meses_historia = vMesesHistoria, sdo_credito = vSdoCredito, 
			fecha_pago = today, abono_mensual_al_quita = NVL(vCapitalMtoCuota,0),
			fecha_ult_mov = dFechaUltMov, fecha_liquidacion = today,
			fecha_status = today, estatus_proceso = 'FI',saldo_tot_liquidar = dSdoTotalLiq,
			copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0),
			int_moratorio = dIntMoratorio,
        ----------------------------------------------------------------------------
			cap_vigente_dq = NVL(dCapVig,0), 
			cap_vencido_dq = dCapVdoExig, 
			int_vigente_dq = dIntVig, 
			int_vencido_dq = dIntVdo,
			int_moratorio_dq = dIntMoratorio,		
			iva_int_vigente_dq = dIvaIntVig, 
			iva_int_vencido_dq = dIvaIntVdo,
			iva_int_mora_dq = dIvaIntMoratorio
			WHERE num_credito = pNumCredito and estatus_proceso='PR';
		----------------------------------------------------------------------------
		--COMMIT;
		LET gprocesa = 0;
	END IF;
	
	RETURN cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
	dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para realizar pagos normales y anticipados de prestamos a plazo, en efectivo, con cargo a cuenta o mixto',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 22 de Junio 2011',
'BD: BDICRED',
'VERSION: 20110624.1808',
'DESCRIPCION: Se Modifica codigo de mensaje para cuando el credito ya este saldado.',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 18 de Agosto 2011',
'BD: BDICRED',
'VERSION: 20110818.1808',
'DESCRIPCION: Se modifica metodo de calculo del IVA moratorio.',
'AUTOR: Diego Guerra Atienzo ',
'FECHA: 30 de Noviembre 2011',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACION: Se modifica sp_principal_suc_rr agregandole la ejecucion del sp_consulta_saldos_general para Retornar el status actual del credito ',
'SUSTENTO: RQM_09-338_Deposito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred',
'DESCRIPCION: Se Agregan las Transacciones 8150 y 8160 Para los Producto 6900 ',
'FECHA: 28/11/2015',
'Modifico: 92597688 - Yadira Morales Zazueta',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para filtrar dtFechaProxPago >= dtFechaActual ademasagregan las transacciones 8160 y 81150. ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 17/03/2017',
'BD          : bdicred',
'-------------------------------------------------------------------------',
'Modifico: 95992243 - Trinidad Hernadez',
'Folio: 188',
'Modificacion: Se quitan movimientos a la sd_movdia',
'BD: bdicred',
'Fecha: 25/04/2017',
'-------------------------------------------------------------------------',
'Modifico: Cinthia Aguilar',
'Modificacion: se agrega la validacion para liberar saldo retenido para las credisoluciones',
'BD: bdicred',
'Fecha: Enero.2026';

CREATE PROCEDURE "informix".sp_genera_archivo_carteralinea_solo(pEmpresa char(3))

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

--Creado por: Abrham Lopez L. 05/08/2011. Proceso para la generacion del archivo de Cartera en Linea
-- Modificado por: MAHR Octubre 2011. Se agregan al proceso productos de colocacion ademas de la Tarjeta de Credito Prestamo Personal y Reestructura.
--      Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.
-- Modificado por MAHR. Mayo 2012. Se crea sp sp_genera_carteraenlinea_tab, que genera los saldos de la cartera vencida y la almacena en la tabla:
--		sd_sdos_cartera_linea y desde dicha tabla se genera el archivo de Cartera en linea.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cEmpresa             CHAR(3);
DEFINE cCod_ret				CHAR(6);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivoAuxRPp    CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoNvo		CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE pFecha               DATE;
DEFINE vnomProceso			CHAR(20);
DEFINE cMensajeRet          CHAR(125);
--DEFINE credcontproc 	    char(1);
--DEFINE intecontproc 	    char(1);
DEFINE cProceso             CHAR(4);
DEFINE cCod_retBit          CHAR(6);

--SET DEBUG FILE TO "/ifxsif01/PEDRO/carteralinea/sp_cartera_total_ppyr_finmes.out";
--TRACE ON;	


--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cEmpresa                = "";
LET cCod_Ret                = "000000";
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivoAuxRPp       = "";
LET cnomarchivo1			= "";
LET cnomarchivoNvo			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cMensajeRet				= 'PROCESO EXITOSO';
LET vnomProceso             = "";
--LET credcontproc            = "";
--LET intecontproc            = "";
LET cProceso                = '0203';
LET cCod_retBit             = '00000';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;            
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;       

        /*UPDATE bdicred:"informix".sd_contproc SET status_proc = "C",  hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = "Cobranza en Linea Sin Generar"
            WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha   = pFecha; 
        UPDATE bdinteg:"informix".sx_contproc SET status_proc = "C", hora_fin = CURRENT, codret  = cCod_ret
            WHERE empresa = pEmpresa AND proceso   = vnomProceso  AND fecha   = pFecha; */
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '01') RETURNING cCod_retBit;       
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    LET pfecha = date(1);

    -- Obtener la fecha del dia de ayer
    SELECT fecha_ant INTO pFecha
        FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
		
	--LET pFecha= mdy('02','28','2022'); -- fecha de prueba 
		

    IF pFecha IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF

    -- *******************************************************
    --  INSERTA BITACORA PARA EJECUCION DE PROCESO           *
    -- *******************************************************
    /* Se elimina la bitacora ya que cuando por error se ejecuta la cartera en linea despues del cambio de fecha, al dia posterior no permite
       la ejecucion del proceso por que indica que ya fue ejecuta, cuando no se ha ejecutado ese dia. Se agrega la bitacora en cobranza para su registro.

    SELECT status_proc INTO intecontproc FROM bdinteg:"informix".sx_contproc WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pfecha;
    IF (intecontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;
    SELECT status_proc INTO credcontproc FROM bdicred:"informix".sd_contproc WHERE empresa = pEmpresa  AND proceso = vnomProceso AND fecha = pFecha;
    IF (credcontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    IF (intecontproc IS NULL) THEN
        INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
            VALUES ('001',vnomProceso,pFecha,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF (credcontproc IS NULL) THEN
        INSERT INTO bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
            VALUES ('001',vnomProceso,pFecha,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    END IF;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'I' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdicred:"informix".sd_contproc SET status_proc = 'I', mensaje = 'Iniciamos' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    */

    -- *******************************************************
    --  FIN BITACORA                                         *
    -- *******************************************************

	-- Validacion de parametros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--Validacion de la empresa
    SELECT empresa INTO cEmpresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 34;  
            
                --Valida que exista la carpeta
    IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--let cruta = '/ifxsif01/PEDRO/carteralinea/'; -- Ruta de pruebas

    --Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 35;
    IF NVL (cnombre,'') = '' THEN
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = '104006';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;


                        --Validar que existe el archivo
    LET cnomarchivo		=  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo1	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivoNvo	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'_nuevo'||'.txt';

        --              Obtiene la consulta de la Cartera de Tarjeta de Credito                                     -
        --------------------------------------------------------------------------------------------------------------
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       - 
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

   -- IF pServicio = '1' OR pServicio = '3' THEN

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo); 

        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, " 
            || " (sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + moratorio + interes_iva) sdo_venc_tot, mensualidad_actual, "
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10),ejecutivo "
            || " FROM bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6001','8100','8500') "; 

        LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';

        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo || " >> " || TRIM(cRuta) || cnomarchivoNvo; --cnomarchivo1;
        SYSTEM cSql;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo;
        SYSTEM cSQL;

   -- END IF;

	  -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
		LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
		System cSQL;                                          --Nota se quito el parametro de la fecha de apertura 
	
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
		System cSQL;
		
	
    --IF pServicio = '2' OR pServicio = '3' THEN
            
        LET cnomarchivoAuxRPp =  trim(cnombre)||'R_PP_Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
        -- cnomarchivo1 Contiene la consulta de Tarjeta de Credito...

        LET cSQL  = ""; 
        LET cSQL1 = "";
        LET cSQL2 = "";
        LET cSQL3 = "";

        --              Obtiene la consulta de la Cartera de Reestructura y Prestamo Personal                       -
        -- -------------------------------------------------------------------------------------------------------- -
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       -
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivoAuxRPp); 
        --AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, "
            || " (sdo_cap_insoluto + sdo_intereses + interes_iva + moratorio + sdo_retenido ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + interes_iva + moratorio - iva_int_trasp) sdo_venc_tot, mensualidad_actual, " 
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10), ejecutivo "
            || " from bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6011','6300','6400','6800','7600','7700') ";
            
        LET cSQL3 = '">'||TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';

        LET cSQL = trim(cSQL1) ||cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivoAuxRPp || " >> " || TRIM(cRuta) || cnomarchivoNvo;		SYSTEM cSql;

        --Borra el archivo de control.
    	LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoAuxRPp;
        SYSTEM cSQL;

   -- END IF;          
   
   -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
	LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
    System cSQL;												--Nota se quito el parametro de la fecha de apertura 
	
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
    System cSQL;
	
	
    --                  Fin consultas | & | Concluye datos en bitacora                                          -
  
    LET cCod_Ret = "00000";
    LET cMensajeRet = "PROCESO CONCLUIDO";

    /*UPDATE bdicred:"informix".sd_contproc SET status_proc = 'F', hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = cMensajeRet
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'F', hora_fin = CURRENT, codret = cCod_ret
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha  = pFecha; */

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '03') RETURNING cCod_retBit;
    RETURN cCod_ret,cMensajeRet;

END;

END PROCEDURE;