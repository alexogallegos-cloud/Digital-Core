CREATE PROCEDURE "informix".apercred1_tc_upgrade(
			P_EMPRESA       VARCHAR(3),
			P_SOLICITUD     VARCHAR(20),
		 	P_EJECUTIVO     CHAR(8))

RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la busqueda de tabla si_ingresos
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
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA         CHAR(1);
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
DEFINE vDiaCorte        SMALLINT;
DEFINE i                SMALLINT;
DEFINE V_CATIVA		    DECIMAL(9,6);
DEFINE V_MERCADEO       CHAR(1);
DEFINE iSecIngreso      SMALLINT;
---I---RQM 10 960 TDC GC
DEFINE vPtosTasaPref		DECIMAL(9,6);
DEFINE vIdTasaFref			CHAR(1);
DEFINE v_cont				INTEGER;
---F---RQM 10 960 TDC GC						
--RQM 10 679 AAME
DEFINE cCodRetOro       CHAR(6);
DEFINE cMenRet          VARCHAR(100,1);
DEFINE dLinea           DECIMAL(18,2)	;
DEFINE cSolOro          CHAR(20) ;
DEFINE iConfirmaOro		SMALLINT ;
DEFINE cTelCel          CHAR(10) ;
DEFINE cCodRet          CHAR(6) ;
DEFINE cCodRetTDif		CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE dFechaT          DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE iFrecuencia      INTEGER;

DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal        DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);			  
DEFINE mMntoComApert    DECIMAL(18,2);      
DEFINE dComisiones      DECIMAL(18,2);
DEFINE mMntoComAnual    DECIMAL(18,2);      -- FIN RQM 10 993 CAT
DEFINE dComs_GastCob	DECIMAL(18,2);		-- RQM 10 1253
--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE gpo              CHAR(1); --RQM 10 1225
DEFINE evalcc           CHAR(1); --RQM 10 1225
DEFINE v_idi            CHAR(1); --RQM 10 1225
DEFINE vDispEfec        CHAR(1); --RQM 10 1225
DEFINE v_indde          SMALLINT; --RQM 10 1225
DEFINE cIFRS			CHAR(1);
DEFINE cStatus_cred 	CHAR(2);
DEFINE iAtr_Act_ifrs	INTEGER;



--SET DEBUG FILE TO "/informix/RGB/apercred1_tc_upgrade.out";
--TRACE ON;

LET V_TASA_MORA = 0;
LET V_TASA_INTERES = 0;
LET V_MERCADEO = "";

---I---RQM 10 960 TDC GC
LET vPtosTasaPref = 0;
LET vIdTasaFref = "";
LET v_cont = 0;
---F---RQM 10 960 TDC GC					

--RQM 10 679 AAME
LET  cCodRetOro	= "";
LET  cMenRet = "";
LET  dLinea	 = 0;
LET  cSolOro = "";
LET  iConfirmaOro = 0;

LET cTelCel = "";
LET dFechaT = DATE(1);
LET iDiaPago = 0;
LET iFrecuencia = 0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET cCodRetTDif			= '';
LET vCatFinal =0;
LET dPagoReq =0;

LET cCobro_Apertu    = '';          -- INI RQM 10 993 CAT
LET cCodComis_Apert  = '';
LET cCobrComisAnual  = '';
LET dClvComAnualTit  = '';
LET dClvComAnualAdi  = '';
LET cCat_adicional   = '';
LET dMtoComAnualTit  = 0;
LET dMtoComAnualAdi  = 0;
LET mMntoComApert    = 0;
LET mMntoComAnual    = 0;
LET dComisiones      = 0;           -- FIN RQM 10 993 CAT
LET V_SOBRETASA		= 0;
LET V_SOBRETASA_MORA =0;
LET V_FACTOR	    = "";
LET V_FACTOR_MORA   = "";
LET dComs_GastCob	 = 0;			-- RQM 10 1253
--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET gpo              =''; --RQM 10 1225
LET evalcc           =''; --RQM 10 1225
LET v_idi            =''; --RQM 10 1225
LET vDispEfec        =''; --RQM 10 1225
LET v_indde          = 0; --RQM 10 1225
LET cIFRS			 ='';
LET cStatus_cred 	 ='';
LET iAtr_Act_ifrs	 = 0;



--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
SELECT valor INTO V_CATIVA
FROM   sd_param
WHERE  cod_param = '034';
IF V_CATIVA IS NULL THEN
   LET V_CATIVA = 0;
END IF


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
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

	DELETE FROM SD_INDICADOR_CRED
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;
		
         RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
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
--	SELECT fecha_hoy, fecha_hoy + 12 units month

    SELECT fecha_hoy
	  INTO V_FECHA_APERT
	  FROM sd_fechas
	 WHERE empresa = P_EMPRESA;

     let  V_FECHA_VENC=date(0);

     call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;
	 
    -- Valida si se encuentra activa funcionalidad de IFRS		
	SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	
	
	 ---AAME RQM 10 679 Se lee si la solicitud es candidato a oro y confirmo que si la quiere en la pantalla de asignacion
	 SELECT  confirma_oro	
		INTO iConfirmaOro
	FROM  bdisolic:"informix".ss_solicitudes_tdcoro 
	WHERE numero_solicitud_oro = P_SOLICITUD;
	 
	 
	 IF  NVL(iConfirmaOro,0) = 1 THEN --AAME RQM 10 679 Clientes que se les apertura la solicitud de oro
		SELECT valor INTO V_CATIVA
		FROM   "informix".sd_param
		WHERE  cod_param = '093';
		
	 END IF;
	 
      -- ****************************
      -- Determina Tasas de Interes *
      -- ****************************
						
	--INTERES ORDINARIO E INTERES MORATORIO
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(P_EMPRESA, P_SOLICITUD, '') INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
	IF cCodRetTDif <> '000000' THEN
		LET P_ERROR = cCodRetTDif;
		RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
	/*SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref
	  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte, vIdTasaFref, vPtosTasaPref
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
	*/				--	RQM 10 1224

	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.fact_sobret_mora, a.sobretasa_mora, a.ind_disp_efec
	  INTO V_FACTOR,           V_SOBRETASA, vDiaCorte,   vIdTasaFref,    vPtosTasaPref,		 V_FACTOR_MORA,		 V_SOBRETASA_MORA, vDispEfec
	  FROM sd_definicion a
	 INNER JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND b.num_solicitud = P_SOLICITUD)
	 WHERE a.empresa = P_EMPRESA;

	IF v_factor = "+" THEN
		LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
	ELIF v_factor = "-" THEN
		LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
	ELIF v_factor = "*" THEN
		LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
	ELSE
		LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
	END IF

	---I---RQM 10 960 TDC GC
	---- VALIDACION PARA CALCULO DE TASA PREFERENCIAL
	IF vIdTasaFref = '1' THEN
	
	SELECT COUNT (*) 
	INTO v_cont
	FROM bdicred:"informix".sd_ctascarg
	WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
	
		IF v_cont <> 0 THEN
			LET V_TASA_INTERES = V_TASA_INTERES - vPtosTasaPref;
		END IF
		
		IF V_TASA_INTERES < 0 THEN
			LET V_TASA_INTERES = 0;
		END IF
		
	END IF
	---F---RQM 10 960 TDC GC						 
						   
		--INTERES MORATORIO
        /*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
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
		*/

        IF V_FACTOR_MORA = "+" THEN
                LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
        ELIF V_FACTOR_MORA = "-" THEN
                LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
        ELIF V_FACTOR_MORA = "*" THEN
                LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
        ELSE
                LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
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

		  --***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)

			
																																			
			SELECT a.num_producto, a.divisa, b.monto_solicitado, b.sucursal, nvl(a.cobro_comis_apertura,'0'), nvl(a.cod_comision_apertura,''), 
				   a.cobro_comision_anual, substr(a.cod_comision_anualidad,1,4), substr(a.cod_comision_anualidad,5,4), a.cat_comi_anual_adicional 
			  INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cCobro_Apertu, cCodComis_Apert, cCobrComisAnual, dClvComAnualTit, dClvComAnualAdi, cCat_adicional
			  FROM bdisolic:ss_solicitudes b, sd_definicion a
			 WHERE b.empresa = P_EMPRESA
			   AND b.num_solicitud = P_SOLICITUD
			   AND a.empresa = b.empresa
			   AND a.num_producto = b.num_producto;
		
		--- Genera cuenta Clabe
		EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,V_PRODUCTO)
			INTO vcod_ret, cta_Clabe;		  

      --***** ACTUALIZA SD_MAECRED

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
			   ,cuenta_clabe
               )
         SELECT SOL.EMPRESA                ,P_SOLICITUD
               ,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
               ,SOL.NUMCTE                 ,DEF.DIVISA
               ,SOL.SUCURSAL               ,''
               ,''                         ,''
               ,''                         ,100
               -- IFRS ,'AA'                       ,'N'
			   ,cStatus_cred               ,'N'
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
			   ,''                         ,CASE WHEN (DEF.NUM_PRODUCTO='8100') THEN '1' ELSE '' END
               ,'A'                        ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
			   ,cta_Clabe
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

      --LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
      --IF V_INSERT = 0 THEN
         --LET P_ERROR = '00001';
         --LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACION DEL CR?DITO';
         --RETURN P_ERROR, P_MENSAJE,v_num_credito;
      --END IF;


      --***** ACTUALIZA SD_MAESDOS

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
								,ACT
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
								,iAtr_Act_ifrs
                          FROM   BDISOLIC:SS_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;
      SELECT USER
             || REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
        INTO VV_FOLIO
        FROM sd_fechas;


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
	IF V_PRODUCTO  <> "7800" THEN
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
  END IF
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
        (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
         comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
     VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    V_FECHA_APERT, V_FECHA_APERT, USER, TODAY);

    INSERT INTO bdicred:"informix".sd_indicador_cred
		      (empresa,num_credito, fecha_alta)
          VALUES(P_EMPRESA,P_SOLICITUD,V_FECHA_APERT );
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

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO V_MERCADEO 
    FROM   bdinteg:si_ctepf 
    WHERE  numcte = vNumCte;
     
	 
	  
IF  V_PRODUCTO   =  "7800" THEN

--Se actualiza la solicitud de credito ligada a la cuenta y movil	
		SELECT  movil_cuenta ,frecuencia_pgo
		INTO cTelCel ,iFrecuencia
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta		
		WHERE numcte = vNumCte
		AND num_solicitud  = P_SOLICITUD;
		
		
			--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
			INTO cCodRet,dFechaT,iDiaPago;
			
	INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		 dia_corte,             dias_gracia_mora,
		 tp_dias_calc_mora,     dias_fecha_max_pago,
		 tp_dias_fecha_pago,    cod_tasa_base_cte,
		 factor_sobretasa_cte,  sobretasa_cte,
		 tasa_interes_cte,      fecha_proceso,prox_fecha_pago )
	SELECT P_EMPRESA,               P_SOLICITUD,
	       DAY(dFechaT),           def.gracia_calc_mora,
	       def.pago_adic_sig_cuo,   def.tipo_cliente,
	       iFrecuencia,        def.cod_tasa_base,
	       def.factor_sobretasa,    def.sobretasa,
	       V_TASA_FAVOR,            V_FECHA_APERT ,dFechaT
	  FROM sd_definicion def, sd_anexodefinicion b,
	       bdisolic:ss_solicitudes c
	 WHERE c.empresa = P_EMPRESA
	   AND c.num_solicitud = P_SOLICITUD
	   AND def.empresa = c.empresa
	   AND def.num_producto = c.num_producto
	   AND b.empresa = def.empresa
	   AND b.num_producto = c.num_producto
	   AND b.cod_prod = def.cod_tipcred;

	   
	   
	   -- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
	/*INSERT INTO "informix".sd_amortiza_credito
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
	VALUES
		(
			P_EMPRESA,			P_SOLICITUD,
			dFechaT,			"3",
			0,					0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);*/

ELSE
	INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		 dia_corte,             dias_gracia_mora,
		 tp_dias_calc_mora,     dias_fecha_max_pago,
		 tp_dias_fecha_pago,    cod_tasa_base_cte,
		 factor_sobretasa_cte,  sobretasa_cte,
		 tasa_interes_cte,      fecha_proceso )
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


END IF


	
    IF vTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO iSecIngreso FROM bdinteg:si_ingresos WHERE empresa = P_EMPRESA
		AND numcte = vNumCte AND tipo_ingreso = 'T';
		
		UPDATE bdinteg:si_ingresos
		   SET ingreso_mensual = vIngreso
		   WHERE empresa = P_EMPRESA
		   AND numcte = vNumCte
		   AND tipo_ingreso = "T"
		   AND sec_ingreso = iSecIngreso;
    ELSE
	
		UPDATE bdinteg:si_cliente
		   SET tipo_cliente = "1"
		 WHERE numcte = vNumCte;
		
		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO iSecIngreso
		FROM bdinteg:si_ingresos 
		WHERE empresa = P_EMPRESA 
		AND numcte = vNumCte 
		AND tipo_ingreso = "T";

		INSERT INTO bdinteg:si_ingresos
		  (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES
		  (P_EMPRESA, vNumCte, iSecIngreso, "T", vIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;
    IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
       LET V_TASA_MORA = V_TASA_MORA * -1;
    END IF
	
	IF V_PRODUCTO  = "7800" THEN
	
		--Mandar el registra evento para el envio de mensajes
		
		--insertar en la tabla para enviar sms	 ÃÂ¡Felicidades! Tu Anticipo de Nomina ha sido autorizado, puedes disponer de hasta $#,### cuando lo necesites.	
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_1' , '000000000','', '','1', V_MONTO, '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
		--insertar en la tabla para enviar sms	 ÃÂ¿Solicita tu Anticipo de Nomina enviando un SMS al ###### con la palabra Anticipo + monto que deseas sin signo de pesos?	
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_2' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	
	ELSE

		LET dPagoReq = V_MONTO * (V_TASA_INTERES /100) / 360 * 30;

        IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura.
            SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
            LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
        END IF;
		-- AAME 17072019 INI Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
        IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
            SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
            SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
            LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
            LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);
            IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
            LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
		ELSE
			LET mMntoComAnual = 0;
		END IF;
		-- Para 6001 solo cobra apertura, para <> 6001 no cobra apertura, cobra anualidad
		LET dComisiones = dComisiones + mMntoComApert;		
        --LET dComisiones = NVL(mMntoComApert,0) + NVL(mMntoComAnual,0);

		--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36,50) 
        --EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36, dComisiones) 
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, V_TASA_INTERES) 		
		into cCodRet,cMensajeRet,vCatFinal;	
		IF cCodRet::INTEGER =0 AND  vCatFinal <> 0  THEN
			LET V_CATIVA = vCatFinal;			
		END IF;
		-- AAME 17072019 FIN Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
		UPDATE bdisolic:ss_revision_determinacion SET cat = V_CATIVA 	WHERE empresa = P_EMPRESA 	AND num_solicitud = P_SOLICITUD;
	END IF;
	
	--***** ACTUALIZA SD_BITACORA_DISPEFEC RQM 10 1225
	IF vDispEfec  = '1' THEN
		SELECT b.grupo,b.evalua_cc  
		INTO  gpo,evalcc
		FROM  bdisolic:ss_revision_determinacion b 
		WHERE b.EMPRESA = P_EMPRESA 
		AND   b.num_solicitud = P_SOLICITUD;
		
		IF gpo = '1' AND evalcc IN ('0','X')  THEN --A+ -> HIT / NO HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND evalcc IN ('0')  THEN -- NO A+ -> HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND nvl(evalcc,'X') = 'X' THEN-- NO A+ -> NO HIT
		   LET v_idi = '1';
		ELSE 
		   LET v_idi = '0';
		END IF;	
		   
		--INSERCION EN TABLA BITACORA DISPOSICION EN EFECTIVO
			 INSERT INTO bdicred:sd_bitacora_dispefec
				   (EMPRESA                ,NUM_CREDITO
				   ,FECHA_STATUS           ,IND_DISP_INI
				   ,IND_DISP_ACT           ,GRUPO
				   ,EVALUA_CC              ,FECHA_INSERT)
			 VALUES(P_EMPRESA,P_SOLICITUD,null,v_idi,null,gpo,evalcc,TODAY);
			 
		--SE ACTUALIZA TABLA SD_MAECRED CON EL VALOR DEL PERIODO_POR_EVALUAR REUSANDO EL CAMPO DIFERIMIENTO_INT
		    LET v_indde = v_idi::INTEGER;
		    UPDATE bdicred:"informix".sd_maecred SET diferimiento_int = v_indde
			WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD ;
        		
	END IF;
    ---------------------------- 

    RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
END;
END PROCEDURE;