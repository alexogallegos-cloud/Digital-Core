CREATE PROCEDURE "informix".sp_gen_clabe_interbancaria(pEmpresa CHAR(3), NumCredito CHAR(12),p_producto CHAR (4))
    RETURNING CHAR(6), CHAR (100);



   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
	DEFINE v_cod_ret			CHAR(6);
	DEFINE vsqlerr				INTEGER;
	DEFINE cuentaClabe			CHAR(18);

	DEFINE vcodret          	CHAR(6);
	DEFINE sqlerr           	INTEGER;
	DEFINE vctaclabecred        CHAR(18);
	DEFINE vdigverif        	CHAR(1);
	DEFINE vbanco           	CHAR(3);
	DEFINE p_cod_financiero 	CHAR (3);
	DEFINE aux_NumCredito 		CHAR(20);
	DEFINE aux_vctaclabecred 	CHAR(20);



   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret,vctaclabecred;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
	--  SET DEBUG FILE TO "/informix/Israel/sp_gen_clabe_interbancaria.out";
	--  TRACE ON;
	   
	LET vcodret    =  "000000";
	LET vctaclabecred  = " ";

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

		---- Consulta numero banco (clabe receptor de SPEI)
	  select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo de producto financiero
	   SELECT  cod_financiero INTO p_cod_financiero
		  FROM bdicred:sd_definicion
		  WHERE empresa = pempresa and num_producto = p_producto;

		   IF p_cod_financiero IS NULL OR p_cod_financiero = " " THEN
			  LET p_cod_financiero = "XXX";
		   END IF;
	   
	   --- Obtiene credito a 11 posiciones
	   LET aux_NumCredito = TRIM(SUBSTRING(NumCredito FROM 1 for 11));
	   
	   ---Arma cuenta previo 17 posiciones
	   LET aux_vctaclabecred = TRIM (vbanco || p_cod_financiero || aux_NumCredito);
	   
	   --- Proceso para generar codigo verificador
	   call digverclabe_cred(aux_vctaclabecred)
			returning vcodret, vdigverif;
			
		--- Arma cuenta final 18 posiciones
	   LET vctaclabecred = trim(aux_vctaclabecred) || vdigverif;
	   
	END;

	RETURN vcodret,vctaclabecred;

END PROCEDURE
DOCUMENT
'GENERA CUENTA CLABE INTERBANCARIA PARA PRODUCTOS DE CREDITO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_valida_spei_cred(p_cta_clabe CHAR(18),pmonto MONEY(14,2))
RETURNING CHAR(6)       	AS retorno,
		CHAR(100)     		AS mensaje,
		CHAR (20)			AS numcte,
		CHAR (100)			AS nombre,
		CHAR (13)			AS rfc;	
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vMensaje             CHAR(300);
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;

DEFINE vbanco				CHAR (3);
DEFINE p_cod_banco			CHAR (3);
DEFINE p_cod_financiero		CHAR (3);
DEFINE p_cod_producto		CHAR (4);
DEFINE tipo_producto		INTEGER;
DEFINE v_status_cred		CHAR(2);
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte				CHAR(20);
DEFINE v_producto			CHAR (4);
DEFINE v_sucursal			CHAR (4);
DEFINE v_divisa				CHAR (2);
DEFINE v_divisa_cred		CHAR (2);
DEFINE v_transaccion		CHAR(4);
DEFINE v_Folio				CHAR(16);
DEFINE v_tipo_bloqueo		INTEGER;
DEFINE v_causa_bloqueo		CHAR (3);
DEFINE valida_total_posisiones INTEGER;
DEFINE v_validanumerico		CHAR(1);

DEFINE cCodRetGF			CHAR (3);
DEFINE cFolioSucGF			CHAR (16);

DEFINE CodRet				CHAR(5);     -- Codigo de Retorno
DEFINE g_Remanente			MONEY(14,2); -- Remanente
DEFINE g_IntMoraCob			MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE g_IntVencCob			MONEY(14,2); -- Interes Vencido Cobrado
DEFINE g_CapVencCob			MONEY(14,2); -- Capital Vencido Cobrado
DEFINE g_IntVigCob			MONEY(14,2); -- Interes Vigente Cobrado
DEFINE g_CapVigCob			MONEY(14,2); -- Capital Vigente Cobrado
DEFINE g_Impuesto			MONEY(14,2); -- Impuesto Cobrado
DEFINE g_Comision			MONEY(14,2); -- Comisiones Cobradas
DEFINE g_Seguro				MONEY(14,2); -- Seguro Cobrado

DEFINE cCodRet2				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);

DEFINE v_apell_paterno		CHAR (25);
DEFINE v_apell_materno		CHAR (25);
DEFINE v_nombrecte			CHAR (100);
DEFINE v_nombre1			CHAR (25);
DEFINE v_nombre2			CHAR (25);
DEFINE v_rfc				CHAR (13);
DEFINE pempresa				CHAR (3);


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet      			= '000000';
LET vMensaje				= 'Proceso Exitoso';
LET iSqlErr      			= 0;
LET iIsamErr     			= 0;

LET vbanco					= '';
LET p_cod_banco				= '';
LET p_cod_financiero		= '';
LET p_cod_producto			= '';
LET tipo_producto			= 0;
LET v_status_cred			= '';
LET v_num_credito			= '';
LET v_numcte				= '';
LET v_producto				= '';
LET v_sucursal				= '';
LET v_divisa				= '';
LET v_divisa_cred			= '';
LET v_transaccion			= '';
LET v_Folio					= '';
LET v_tipo_bloqueo			= 0;
LET v_causa_bloqueo			= '';
LET valida_total_posisiones = 0;
LET v_validanumerico		= '';

LET cCodRetGF				= '';
LET cFolioSucGF				= '';

LET CodRet		         	= '';
LET g_Remanente	         	= 0;
LET g_IntMoraCob	     	= 0;
LET g_IntVencCob	     	= 0;
LET g_CapVencCob	     	= 0;
LET g_IntVigCob	         	= 0;
LET g_CapVigCob	         	= 0;
LET g_Impuesto	         	= 0;
LET g_Comision	         	= 0;
LET g_Seguro		     	= 0;

LET cCodRet2			= "00000";
LET cMensaje			= "Se realizÃ³ el proceso exitosamente";
LET cNumCreditocrd		= '';
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";

LET v_apell_paterno			= '';
LET v_apell_materno			= '';
LET v_nombre1				= '';
LET v_nombre2				= '';
LET v_nombrecte				= '';
LET v_rfc					= '';
LET pempresa				= '001';


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;		
				RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
			END IF;
		END EXCEPTION;
		
---	  SET DEBUG FILE TO '/informix/Israel/sp_valida_spei_cred.out';
--	  SET DEBUG FILE TO '/RESPALDOSNEW/Israel/sp_valida_spei_cred.out';
--	  TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	


		IF p_cta_clabe = '' OR p_cta_clabe IS NULL OR pmonto IS NULL OR  NVL (pmonto,'') = '' THEN
			LET cCodRet = '14';
			LET vMensaje = 'Falta informaciÃ³n mandatoria para completar el pago';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;
		
		--- Obtiene el numero de posiciones
		LET valida_total_posisiones = LENGTH(p_cta_clabe);
		
		--- Valida que la cadena sea solo numerica
		EXECUTE PROCEDURE bdinteg:sp_esnumerico (p_cta_clabe)
			INTO v_validanumerico;
		
		---- Consulta numero banco (clabe receptor de SPEI)
		select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo Bancario
		LET p_cod_banco = SUBSTR(p_cta_clabe,1,3);
		--- Obtiene codigo financiero
		LET p_cod_financiero = SUBSTR(p_cta_clabe,4,3);
		--- Obtiene numero de producto
		LET p_cod_producto = SUBSTR(p_cta_clabe,7,2)||'00';
			
		IF NVL (p_cod_banco,'') <> vbanco THEN
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF pmonto <= 0 THEN
			LET cCodRet = '15';
			LET vMensaje = 'Tipo de pago erroneo';	
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF p_cod_producto = '6500' OR valida_total_posisiones <> 18 THEN
			LET cCodRet = '17';
			LET vMensaje = 'Tipo de cuenta no corresponde';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF v_validanumerico = 'F' THEN
			LET cCodRet = '19';
			LET vMensaje = 'Caracter invalido';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;	
				
		IF p_cod_financiero in ('975') OR p_cod_producto = '7800' THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,a.id_unidad_prod,a.Cod_caract_2,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_tipo_bloqueo,v_causa_bloqueo,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecred a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF (v_tipo_bloqueo <> '' OR v_tipo_bloqueo IS NOT NULL) 
--					AND (v_causa_bloqueo <> '' OR v_causa_bloqueo IS NOT NULL) THEN --- VALIDAR ESTATUS BLOQUEADO
--						LET cCodRet = '2';
--						LET vMensaje = 'Cuenta Bloqueada';
--						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('FI','FF') THEN --- Validar tipos de canceladas FI cancelada por saldos inmateriales
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:"informix".principalrefer (pempresa,v_num_credito,1,'',user,v_sucursal,cFolioSucGF,v_transaccion,0,pmonto,'')
						INTO CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
							g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
							g_Comision, g_Seguro;
							
						IF (CodRet::INTEGER <> 0) THEN
							LET cCodRet = '000448';
							LET vMensaje = 'Error al ejecutar el pago';
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
								
						END IF;
				END IF;

		ELIF p_cod_financiero in ('970','971','972') THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecredcrd a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF v_status_cred = '' THEN --- VALIDAR ESTATUS BLOQUEADO
--					LET cCodRet = '2';
--					LET vMensaje = 'Cuenta Bloqueada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('CN','FF') THEN --- 
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr (pempresa,v_num_credito,v_producto,pmonto,0,user,v_sucursal,cFolioSucGF,v_transaccion)
						INTO cCodRet2,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,
							Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;
							
						IF (cCodRet2::INTEGER <> 0) THEN
							LET cCodRet = '000449';
							LET vMensaje = cMensaje;
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
							
						END IF;
				END IF;
		ELSE
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;		
		END IF;
		
	END		
	
RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

END PROCEDURE
DOCUMENT
'Proceso que realiza la validacion para aplicar un SPEI de credito',
'AUTOR : Israel Travieso',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".respaldacrd(eEmpresa    CHAR(3),
                                        eNumCredito CHAR(20),
                                        eFolio      CHAR(20))
   RETURNING CHAR(5);   --CodRet


   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;

   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';

   LET CodRet = "000";
   SELECT MAX(secuencia)
     INTO wSecuenciaPago
     FROM sd_secpago
    WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;

--set debug file to "respaldacredito.out";
--trace on;


  LET g_NumCredito = eNumCredito;
  LET g_Folio      = eFolio;
  LET g_Empresa    = eEmpresa;

   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN
      LET wSecuenciaPago = 0;
   END IF;

   LET wSecuenciaPago = wSecuenciaPago + 1;

   INSERT INTO
      sd_secpago (empresa, num_credito, folio_suc, secuencia)
   VALUES
      (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago);

                             --**    Respalda Maecred                          --
   INSERT INTO sd_maecredrev
        (empresa           , num_credito     , folio           , num_producto    , ejecutivo          ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2	   , cuenta_clabe)
   SELECT
        empresa            , num_credito     , g_folio         , num_producto    , ejecutivo         ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2	   , cuenta_clabe
    FROM sd_maecred
   WHERE num_credito = g_NumCredito
   AND   empresa = g_Empresa;

                             --**    Respalda Maesdos      --

   INSERT INTO sd_maesdosrev
         (empresa            , num_credito         , folio            , fecha_ult_mov     , sdo_int_anticip  ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4        )
   SELECT
          empresa            , num_credito         , g_Folio          ,  fecha_ult_mov    , sdo_int_anticip   ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4
   FROM sd_maesdos
   WHERE empresa   = g_Empresa
   AND num_credito = g_NumCredito;


                             --**    Respalda MaecredAnexo --
   INSERT INTO sd_maecredanexorev
        (empresa            , num_credito       ,  folio, dia_corte , dias_gracia_mora    , tp_dias_calc_mora,
         dias_fecha_max_pago, tp_dias_fecha_pago,  cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte    ,
         tasa_interes_cte   , fecha_vencto      ,  prox_fecha_pago  , fecha_proceso       , fecha_ult_pago  )
   SELECT
        empresa             , num_credito       ,  g_Folio,  dia_corte,  dias_gracia_mora , tp_dias_calc_mora,
         dias_fecha_max_pago, tp_dias_fecha_pago,  cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte    ,
         tasa_interes_cte   , fecha_vencto      ,  prox_fecha_pago  , fecha_proceso       , fecha_ult_pago
  FROM sd_maecredanexo
  WHERE empresa     = g_Empresa
    AND num_credito = g_NumCredito;

                             --**    Respalda AmortizaCredito --

  INSERT INTO sd_amortiza_creditorev(
       empresa                , folio            , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4         )
  SELECT
       empresa                , g_folio          , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4
 FROM sd_amortiza_credito
 WHERE empresa     = g_empresa
   ANd Num_credito = g_numcredito;

   RETURN CodRet;

END PROCEDURE
;