CREATE PROCEDURE "informix".apercred1_tcpba( 
			 P_EMPRESA       VARCHAR(3),
                         P_SOLICITUD     VARCHAR(20),
		 	 P_EJECUTIVO     CHAR(8))

RETURNING CHAR(5);

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE V_SECUENCIA_MAX       INTEGER;
DEFINE V_EQ_DIAS             INTEGER;
DEFINE V_EXISTE_REG          INTEGER;
DEFINE P_ERROR               VARCHAR(8);
DEFINE P_MENSAJE             VARCHAR(80);
DEFINE V_DIF_INT             INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO DATE;
DEFINE V_INSERT              INTEGER;
DEFINE V_E_CODTRASP          INTEGER;
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
define v_num_credito         char(20);
define vdigverif             char(1);
DEFINE SQL_ERR               INTEGER;
DEFINE ISAM_ERR              INTEGER;
DEFINE ERROR_INFO            VARCHAR(80);
define vcodret               char(5);
DEFINE vNumCte               CHAR(20);
DEFINE vTpCte                CHAR(1);
DEFINE vIngreso              DECIMAL(14,2);
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vMensaje              CHAR(200);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte             SMALLINT;
DEFINE i		     SMALLINT;

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;

	 DELETE FROM SD_MAESDOS
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	 DELETE FROM SD_MOVDIA
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	 DELETE FROM SD_MAECREDANEXO
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

         UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AT"
          WHERE empresa = P_EMPRESA
            AND num_solicitud = P_SOLICITUD;

         DELETE FROM bdisolic:ss_autorizacion 
          WHERE empresa = P_EMPRESA
            AND num_solicitud = P_SOLICITUD
	    AND status_solicitud = "AP";

	 DELETE FROM bdicred:sd_amortiza_credito
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;
	 
	 DELETE FROM SD_MAECRED 
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

         RETURN P_ERROR;
    END EXCEPTION;

      --***********************
      --INICIALIZA VARIABLE
      --***********************


      LET V_EXISTE_REG = 0;
      LET P_ERROR      = '00000';
      LET P_MENSAJE    = 'PROCESO EXITOSO';
      LET V_EQ_DIAS    = 0;
      LET V_DIF_INT    = 0;
      LET V_FECHA_FIN_PRORRATEO = NULL;
      LET v_num_credito = "";
      LET i = 0;

      -- ******************
      -- Determina Fechas *
      -- ******************
	SELECT fecha_hoy, fecha_hoy + 12 units month
	  INTO V_FECHA_APERT, V_FECHA_VENC
	  FROM sd_fechas
	 WHERE empresa = P_EMPRESA;


      -- ****************************
      -- Determina Tasas de Interes *
      -- ****************************
	--INTERES ORDINARIO
	SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota
	  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte
	  FROM sd_definicion a, bdisolic:ss_solicitudes b,
	       bdinteg:si_fechavalor c
	 WHERE b.empresa = P_EMPRESA
	   AND num_solicitud = P_SOLICITUD
	   AND a.empresa = b.empresa
	   AND a.num_producto = b.num_producto
	   AND c.empresa = a.empresa
	   AND c.tasa = a.cod_tasa_base
	   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
			   WHERE r.empresa = P_EMPRESA
			     AND r.tasa = a.cod_tasa_base);


	IF v_factor = "+" THEN
		LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
	ELIF v_factor = "-" THEN
		LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
	ELIF v_factor = "*" THEN
		LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
	ELSE
		LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
	END IF

        --INTERES MORATORIO
        SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
          INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
          FROM sd_definicion a, bdisolic:ss_solicitudes b,
               bdinteg:si_fechavalor c
         WHERE b.empresa = P_EMPRESA
           AND num_solicitud = P_SOLICITUD
           AND a.empresa = b.empresa
           AND a.num_producto = b.num_producto
           AND c.empresa = a.empresa
           AND c.tasa = a.cod_tasa_mora 
           AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
                           WHERE r.empresa = P_EMPRESA
                             AND r.tasa = a.cod_tasa_mora);



        IF v_factor = "+" THEN
                LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA;
        ELIF v_factor = "-" THEN
                LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA;
        ELIF v_factor = "*" THEN
                LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA;
        ELSE
                LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA;
        END IF

        --INTERES A FAVOR DEL CLIENTE
        SELECT c.valor, a.factor_sobretasa, a.sobretasa
          INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
          FROM sd_anexodefinicion a, bdisolic:ss_solicitudes b,
               bdinteg:si_fechavalor c
         WHERE b.empresa = P_EMPRESA
           AND num_solicitud = P_SOLICITUD
           AND a.empresa = b.empresa
           AND a.num_producto = b.num_producto
           AND c.empresa = a.empresa
           AND c.tasa = a.cod_tasa_base
           AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
                           WHERE r.empresa = P_EMPRESA
                             AND r.tasa = a.cod_tasa_base);
        


        IF V_FACTOR_FAV = "+" THEN
                LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
        ELIF V_FACTOR_FAV = "-" THEN
                LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
        ELIF V_FACTOR_FAV = "*" THEN
                LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
        ELSE
                LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
        END IF




      --***** ACTUALIZA SD_MAECRED
    {  BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR;
    END EXCEPTION;}

         INSERT INTO bdicred:sd_maecred
               (EMPRESA                ,NUM_CREDITO
               ,NUM_PRODUCTO           ,EJECUTIVO
               ,NUMCTE                 ,DIVISA
               ,SUCURSAL               ,ID_ORIGEN
               ,ORIGEN                 ,COD_TIPO_LINEA
               ,COD_LINEA              ,PORC_REC_PROP
               ,STATUS_CRED            ,BANDERA_RENOVAC
               ,BANDERA_PRORROGA       ,PERIODO_PLAZO
               ,PLAZO                  ,FECHA_APERTURA
               ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
               ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
               ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
               ,COD_TASA_BASE          ,FACTOR_SOBRETASA
               ,SOBRETASA              ,TASA_INTERES
               ,COD_TASA_MORA          ,SOBRETASA_MORA
               ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
               ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
               ,ES_FISICA              ,BANDERA_FI_FO
               ,CODIGO_PRO             ,SUPERFICIE
               ,ACTIVIDAD              ,CAL_EDOS_FIN
               ,TIPO_CALCULO           ,ADMITE_TLP
               ,REL_GARCRED            ,ID_UNIDAD_PROD
               ,NUM_APER_ANT           ,REV_TASA_VAR_PER
               ,DIA_PARA_REVISAR       ,COD_PROD
               ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
               ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
               ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
               ,CAMPO_TRAB1            ,CAMPO_TRAB2
               ,CAMPO_TRAB3            ,CAMPO_TRAB4
               ,CALIFICACION_RIESGO    ,COD_AGRICOLA
               ,TASA_BASE_PISO         ,SOBRETASA_PISO
               ,FACTOR_PISO            ,TASA_PISO
               ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
               ,FACTOR_TECHO           ,TASA_TECHO
               )
         SELECT SOL.EMPRESA                ,P_SOLICITUD
               ,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
               ,SOL.NUMCTE                 ,DEF.DIVISA
               ,SOL.SUCURSAL               ,''
               ,''                         ,''
               ,''                         ,100                     
               ,'AA'                       ,'N'
               ,'N'                        ,DEF.PERIODO_PLAZO
               ,0                          ,V_FECHA_APERT
               ,V_FECHA_VENC               ,"3"
               ,"2"                        ,CTR.DIAS_TRAS_CAP
               ,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
               ,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
               ,DEF.SOBRETASA              ,V_TASA_INTERES   
               ,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
               ,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA        
               ,''                         ,''
               ,TIP.ES_FISICA              ,''
               ,DEF.COD_PROD               ,0
               ,''                         ,''
               ,DEF.TIPO_CALCULO           ,''
               ,0                          ,''
               ,''                         ,DEF.REV_TASA_VAR_PER
               ,DEF.DIA_PARA_REVISAR       ,''
               ,'M'                        ,''
               ,''                         ,0             
               ,0                          ,V_FECHA_APERT        
               ,0                          ,0
               ,''                         ,''
               ,'A'                        ,''
               ,''                         ,''                
               ,''                         ,''           
               ,''                         ,''                  
               ,''                         ,''            
         FROM   BDISOLIC:SS_SOLICITUDES SOL
              , BDISOLIC:SS_ANEXOSOL    ANX
              , BDINTEG:SI_CLIENTE      CLI
              , BDINTEG:SI_TIPPER       TIP
              , SD_CODTRASP             CTR
              , SD_DEFINICION           DEF
         WHERE  DEF.EMPRESA         = SOL.EMPRESA
         AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
         AND    CTR.PERIOD_PAG_INT  = "2"
         AND    CTR.PERIOD_PAGO_CAP = "3"
         AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
         AND    CTR.EMPRESA         = DEF.EMPRESA
         AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
         AND    CLI.NUMCTE          = SOL.NUMCTE
         AND    CLI.EMPRESA         = SOL.EMPRESA
         AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
         AND    ANX.EMPRESA         = SOL.EMPRESA
         AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
         AND    SOL.EMPRESA         = P_EMPRESA;
      --END;

      --LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
      --IF V_INSERT = 0 THEN
         --LET P_ERROR = '00001';
         --LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACIàN DEL CRDITO';
         --RETURN P_ERROR, P_MENSAJE,v_num_credito;
      --END IF;


      --***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
    BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR;
    END EXCEPTION;


	INSERT INTO sd_maecredanexo
		(empresa,               num_credito,       
		 dia_corte,             dias_gracia_mora,   
		 tp_dias_calc_mora,     dias_fecha_max_pago,
		 tp_dias_fecha_pago,    cod_tasa_base_cte, 
		 factor_sobretasa_cte,  sobretasa_cte,      
		 tasa_interes_cte,      fecha_proceso)
	SELECT P_EMPRESA,               P_SOLICITUD,       
	       def.dia_cuota,           def.gracia_calc_mora, 
	       def.pago_adic_sig_cuo,   def.tipo_cliente,
	       def.maneja_linea,        def.cod_tasa_base,
	       def.factor_sobretasa,    def.sobretasa,
	       V_TASA_FAVOR,            V_FECHA_APERT 
	  FROM sd_definicion def, sd_anexodefinicion b, 
	       bdisolic:ss_solicitudes c
	 WHERE c.empresa = P_EMPRESA
	   AND c.num_solicitud = P_SOLICITUD
	   AND def.empresa = c.empresa
	   AND def.num_producto = c.num_producto
	   AND b.empresa = def.empresa
	   AND b.num_producto = c.num_producto
	   AND b.cod_prod = def.cod_tipcred; 
	       
	       


    END;
      --***** ACTUALIZA SD_MAESDOS

    BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR;
    END EXCEPTION;

         INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
                                )
                          SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,TODAY                  ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO   ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                          FROM   BDISOLIC:SS_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;
      END;

	SELECT a.num_producto, a.divisa, b.monto_solicitado, b.sucursal
	  INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL
	  FROM bdisolic:ss_solicitudes b, sd_definicion a
	 WHERE b.empresa = P_EMPRESA
	   AND b.num_solicitud = P_SOLICITUD
	   AND a.empresa = b.empresa
	   AND a.num_producto = b.num_producto;

      SELECT USER
             || REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
        INTO VV_FOLIO
        FROM SD_FECHAS;


      EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_SOLICITUD,
	                          V_PRODUCTO        , 1,
                                "001"             , V_FECHA_APERT,
                                V_MONTO           , VV_FOLIO,
                                VV_SUCURSAL       ,VV_DIVISA,
                                "0000")
	INTO P_ERROR, P_MENSAJE;

    -- *********************************************************
    -- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
    -- *********************************************************

       LET vFechaT = MONTH(V_FECHA_APERT) || "/" || vDiaCorte || "/" || 
		    YEAR(V_FECHA_APERT);
       IF DAY(V_FECHA_APERT) > vDiaCorte THEN
       	   CALL sp_calcula_fecha ("001" ,1 ,"M" ,vFechaT ,"01" ,"01")
           RETURNING P_ERROR, P_MENSAJE, vFechaT;
       END IF

        FOR i = 1 TO 12

                INSERT INTO sd_amortiza_credito values
                (P_EMPRESA,P_SOLICITUD,vFechaT,"3",0,0,0,"1","0","",
                  0,0,"1","0","",
                  0,0,"1","0","",
                  0,0,0,0,0,0,0,"1",
                  0,0,"1","",
                  i,0,0,"","");

            EXECUTE PROCEDURE sp_calcula_fecha
                (P_EMPRESA ,1 ,"M" ,vFechaT ,"01" ,"01")
            INTO P_ERROR, P_MENSAJE, vFechaT;
        END FOR

    -- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- **************************************

    UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AP"
     WHERE empresa = P_EMPRESA
       AND num_solicitud = P_SOLICITUD;

    SELECT nombre INTO vMensaje
      FROM bdinteg:si_ejecut
     WHERE ejecutivo = P_EJECUTIVO
       AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:ss_autorizacion
     VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    V_FECHA_APERT, V_FECHA_APERT, USER, TODAY); 

    -- ******************************
    -- Actualiza Datos del Cliente  *
    -- ******************************

    SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
      INTO vNumCte, vTpCte, vIngreso
      FROM bdinteg:si_cliente a, bdisolic:ss_solicitudes b,
	   bdisolic:ss_resum_scor_fin c
     WHERE a.numcte = b.numcte
       AND b.empresa = P_EMPRESA
       AND b.num_solicitud = P_SOLICITUD
       AND c.empresa = b.empresa
       AND c.num_solicitud = b.num_solicitud;


    IF vTpCte = "1" THEN
	UPDATE bdinteg:si_ingresos
	   SET ingreso_mensual = vIngreso
	 WHERE empresa = P_EMPRESA
	   AND numcte = vNumCte
	   AND tipo_ingreso = "T";
    ELSE
	UPDATE bdinteg:si_cliente
	   SET tipo_cliente = "1"
	 WHERE numcte = vNumCte;

	INSERT INTO bdinteg:si_ingresos
	  (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
	VALUES
	  (P_EMPRESA, vNumCte, 1, "T", vIngreso);
    END IF


      RETURN P_ERROR;
END;
END PROCEDURE;