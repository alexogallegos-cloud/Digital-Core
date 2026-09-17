CREATE PROCEDURE "informix".sp_consulta_subproducto(p_num_producto CHAR(4),p_nombre_prod CHAR(40),p_Id_subproducto CHAR(4) ,p_tpo_ejecucion CHAR(1))

	RETURNING CHAR(5), --Codigo de retorno
			  VARCHAR(100), 
			  VARCHAR(100), 
			  VARCHAR(100), 
			  VARCHAR(100), 
			  VARCHAR(100), 
			  VARCHAR(100), 
			  VARCHAR(100),
			  VARCHAR(100);
			  
			  --EXECUTE PROCEDURE "informix".sp_consulta_subproducto('6800','','','0');
			  --EXECUTE PROCEDURE "informix".sp_consulta_subproducto('6800','','1','1');
			  --Tipo Ejecucion 0 -- Retornas los valores del Llenado del combo subproducto
			  --Tipo Ejecucion 1 -- Retorna el id del subproducto, Descripcion del subproducto, Num_Producto, Nombre del Producto,Plazo Minimo para Credito, Plazo Maxima para Credito,Linea Minima Credito,Linea Maxima Credito
			  --Tipo Ejecucion 2 -- Retorna el Edad Minima ,Edad Maxima , Monto min a disponer credito, Frecuencia de pago, Bandera Comision gastos cobranza,Comision gastos cobranza,Bandera Comision anualidad,Valor Comision anualidad
			  --Tipo Ejecucion 3 -- Retorna el Bandera Comision disp de efectivo, Valor Comision disp de efectivo, Bandera Comision aclara no procedente, Valor Comision aclara no procede, Bandera Comision liquidacion antic, Valor Comision liquidacion antic,Bandera Comision apertura, Valor Comision apertura
			  --Tipo Ejecucion 4 -- Retorna el BanDera de Garantias, Tipos de garantia, porcentaje del aforo, Bandera Obligado Solidario, Bandera numero obligados, Bandera captura obligatoria,Checkbox cta medios acceso, Bandera cancelacion x inactividad
			  --Tipo Ejecucion 5 -- Retorna el Bandera cancelacion x vigencia, Tiempo cancelar en meses, Bandera Seguro de Vida, Bandera Cobro Mensualidad, Checkbox envio MC, Checkbox Id_domiciliacion,  Checkbox Conciliador, Checkbox Historicocred
			  --Tipo Ejecucion 6 -- Retorna el Checkbox Periodogracia,Dias de gracia,Bandera tpo condonacion Cap e Int, Bandera tpo condonacion Int, Bandera estado de cuenta,Id estado de cuenta, Emision Edocta, Rango periodo inicial
			  --Tipo Ejecucion 7 -- Retorna el Rango periodo final, Bandera Cta Concentradora, Cuenta Concentradora, cRangoini_gracia,cRangofin_gracia
			  			  			    
	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 				   CHAR(5);
	DEFINE iSqlErr  			   INTEGER;
	DEFINE cId_subproducto 		   VARCHAR(4);
	DEFINE cDesc_subproducto 	   VARCHAR(100);
    DEFINE cNum_Producto    	   CHAR(4);
    DEFINE cNomb_Producto   	   CHAR(40);
    DEFINE cPlazo_Minimo    	   SMALLINT;
    DEFINE cPlazo_Maximo    	   SMALLINT;
    DEFINE cMonto_Min_Cred  	   DECIMAL(18,2);
    DEFINE cMonto_Max_Cred  	   DECIMAL(18,2);
    DEFINE cEdad_Minima     	   SMALLINT;
    DEFINE cEdad_Maxima     	   SMALLINT;
	DEFINE cMonto_Min_Disp		   DECIMAL(18,2);
	DEFINE cMonto_max_disp		   DECIMAL(18,2);
	DEFINE cPeriodo_Plazo		   VARCHAR(30);
	DEFINE cComision_Gastos        SMALLINT;
	DEFINE cValor_Comision_Gastos  DECIMAL(18,2);
	DEFINE cComision_Anualidad     CHAR(1);
	DEFINE cValor_Comision_Anualid DECIMAL(18,2);
	DEFINE cComision_Disposicion   SMALLINT;
	DEFINE cValor_Comision_Dispos  DECIMAL(18,2);
	DEFINE cComision_Aclaracion    SMALLINT;
	DEFINE cValor_Comision_Aclar   DECIMAL(18,2);
	DEFINE cComision_Liquidacion   SMALLINT;
	DEFINE cValor_Comision_Liquid  DECIMAL(18,2);
	DEFINE cComision_Apertura 	   CHAR(1);
	DEFINE cValor_Comision_Aper    DECIMAL(18,2);
    DEFINE cGarantias 			   SMALLINT;
	DEFINE cTipo_Garantia 		   VARCHAR (30);
	DEFINE cPorcentaje_Aforo 	   DECIMAL (18,2);
	DEFINE cObligado_Solidario 	   CHAR(1);
	DEFINE cNum_Obligados		   CHAR(1);
	DEFINE cCaptura_Obligatoria	   CHAR(1);
	DEFINE cCuentas_Medios 		   CHAR(1);
	DEFINE cCancelacion_Inac 	   CHAR(1);
	DEFINE cCancelacion_Vig 	   CHAR(1);
	DEFINE cTiempo_Cancelar 	   CHAR(2);
	DEFINE cSeguro_Vida 		   CHAR(1);
	DEFINE cCobro_Mensualidad 	   CHAR(1);
	DEFINE cEnvio_Mesa_Control 	   CHAR(1);
	DEFINE cId_Domiciliacion 	   CHAR(1);
	DEFINE cConciliador 		   CHAR(1);
	DEFINE cHistorico_Cred 		   CHAR(1);
	DEFINE cPeriodo_Gracia 		   CHAR(1);
	DEFINE cDias_Gracia 	 	   INTEGER;
	DEFINE cCapital_Interes 	   CHAR(1);
	DEFINE cIntereses 	 		   CHAR(1);
	DEFINE Ccapital				   CHAR(1);
	DEFINE cEstado_Cuenta 		   CHAR(1);
	DEFINE cId_Edocta			   VARCHAR(30);
	DEFINE cEmision_estado_cuenta  CHAR(2);
	DEFINE cRango_inicial          CHAR(2);
	DEFINE cRango_final            CHAR(2);
	DEFINE cIdcta_concentradora    CHAR(1);
	DEFINE cCta_concentradora      CHAR(20);
	DEFINE cEnvia_os 			   SMALLINT;
	DEFINE flag_tpcomis_ComGastos  	   CHAR(1);
	DEFINE flag_tpcomis_ComAnualidad   CHAR(1);
	DEFINE flag_tpcomis_ComDisposicion CHAR(1);
	DEFINE flag_tpcomis_ComAclaracion  CHAR(1);
	DEFINE flag_tpcomis_ComLiquidacion CHAR(1);
	DEFINE flag_tpcomis_ComApertura	   CHAR(1);
	DEFINE v_ya_existe 			   	   SMALLINT;
	DEFINE cAuxId_subproducto 		   VARCHAR(5);
    DEFINE cRangoini_gracia  CHAR(2);
    DEFINE cRangofin_gracia  CHAR(2);
	
	DEFINE vVariable1			   	   VARCHAR(100);
	DEFINE vVariable2			   	   VARCHAR(100);
	DEFINE vVariable3			   	   VARCHAR(100);
	DEFINE vVariable4			   	   VARCHAR(100);
	DEFINE vVariable5			   	   VARCHAR(100);
	DEFINE vVariable6			   	   VARCHAR(100);
	DEFINE vVariable7			   	   VARCHAR(100);
	DEFINE vVariable8			   	   VARCHAR(100);
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************	

	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cId_subproducto 	= '';
	LET cDesc_subproducto	= ''; 
	LET cNum_Producto 		= '';  	
	LET cNomb_Producto 		= '';  
	LET cPlazo_Minimo 		= 0;	
	LET cPlazo_Maximo 		= 0;	
	LET cMonto_Min_Cred		= 0;	
	LET cMonto_Max_Cred 	= 0;
	LET cEdad_Minima 		= 0;
	LET cEdad_Maxima 		= 0;
	LET cMonto_Min_Disp 	= 0;
	LET cMonto_max_disp 	= 0;
	LET cPeriodo_Plazo 		= '';
	LET cComision_Gastos 	= 0;
	LET cValor_Comision_Gastos 	= 0;
	LET cComision_Anualidad  	= '';
	LET cValor_Comision_Anualid = 0;
	LET cComision_Disposicion 	= 0;
	LET cValor_Comision_Dispos 	= 0;
	LET cComision_Aclaracion 	= 0;
	LET cValor_Comision_Aclar 	= 0;
	LET cComision_Liquidacion 	= 0;
	LET cValor_Comision_Liquid 	= 0;
	LET cComision_Apertura 		= '';
	LET cValor_Comision_Aper 	= 0;
	LET cGarantias 				= 0;
	LET cTipo_Garantia 			= '';	
	LET cPorcentaje_Aforo 		= 0;
	LET cObligado_Solidario  	= '';
	LET cNum_Obligados		 	= '';
	LET cCaptura_Obligatoria 	= '';	
	LET cCuentas_Medios 	 	= '';	
	LET cCancelacion_Inac 	 	= '';
	LET cCancelacion_Vig 	 	= '';
	LET cTiempo_Cancelar 	 	= '';
	LET cSeguro_Vida 		 	= '';
	LET cCobro_Mensualidad 	 	= '';
	LET cEnvio_Mesa_Control  	= '';	
	LET cId_Domiciliacion 	 	= '';
	LET cConciliador 		 	= '';
	LET cHistorico_Cred 	 	= '';	
	LET cPeriodo_Gracia 	 	= '';	
	LET cDias_Gracia 	 	 	= 0;
	LET cCapital_Interes 	 	= '';
	LET cIntereses 	 		 	= '';
	LET Ccapital			 	= '';
	LET cEstado_Cuenta 		 	= '';
	LET cId_Edocta			 	= '';
	LET cEmision_estado_cuenta  = '';
	LET cRango_inicial 			= '';
	LET cRango_final 			= '';
	LET cIdcta_concentradora 	= '';
	LET cCta_concentradora 		= '';
	LET cEnvia_os			 	= 0;
	LET flag_tpcomis_ComGastos	    = '';
	LET flag_tpcomis_ComAnualidad   = '';
	LET flag_tpcomis_ComDisposicion = '';
	LET flag_tpcomis_ComAclaracion  = '';
	LET flag_tpcomis_ComLiquidacion = '';
	LET flag_tpcomis_ComApertura	= '';
	LET v_ya_existe			 		= 0;
	LET cAuxId_subproducto = '';
    LET cRangoini_gracia ='';
    LET cRangofin_gracia='';
	
	LET vVariable1			        = '';
	LET vVariable2			        = '';
	LET vVariable3			        = '';
	LET vVariable4			        = '';
	LET vVariable5			        = '';
	LET vVariable6			        = '';
	LET vVariable7			        = '';
	LET vVariable8			        = '';
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,vVariable1,vVariable2,vVariable3, vVariable4, vVariable5,vVariable6,vVariable7,vVariable8;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/Stored_Procedures/sp_consulta_subproducto.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (p_num_producto = '' AND p_nombre_prod = '' AND p_tpo_ejecucion = '0') OR (p_tpo_ejecucion <> '0' AND p_Id_subproducto ='' ) THEN
			LET cCodRet = '00001';
			RETURN cCodRet,vVariable1,vVariable2,vVariable3, vVariable4, vVariable5,vVariable6,vVariable7,vVariable8;
		ELSE
			
			SELECT COUNT(*)
			INTO   v_ya_existe
			FROM   "informix".sd_subproducto
			WHERE  num_producto  = p_num_producto OR nombre_prod  = p_nombre_prod OR id_subproducto  = p_Id_subproducto;

			IF v_ya_existe > 0 THEN
					
				IF p_tpo_ejecucion = '0' THEN
					FOREACH
						SELECT {+INDEX(sd_subproducto idx_sd_subproducto)} id_subproducto,desc_subproducto
						INTO   cId_subproducto,cDesc_subproducto
						FROM   "informix".sd_subproducto
						WHERE  num_producto  = p_num_producto OR nombre_prod  = p_nombre_prod			

						LET vVariable1 = cId_subproducto::VARCHAR(100);
						LET vVariable2 = cDesc_subproducto::VARCHAR(100);	
						
						RETURN cCodRet,vVariable1,vVariable2,vVariable3, vVariable4, vVariable5,vVariable6,vVariable7,vVariable8 WITH RESUME;
					END FOREACH;			
				ELSE
					SELECT COUNT(*)
					INTO   v_ya_existe
					FROM   "informix".sd_subproducto
					WHERE  num_producto  = p_num_producto AND nombre_prod  = p_nombre_prod AND id_subproducto  = p_Id_subproducto;
				
					IF v_ya_existe > 0 THEN
						SELECT id_subproducto,desc_subproducto,num_producto,nombre_prod, plazo_min_cred, plazo_max_cred, monto_min_cred, monto_max_cred, edad_min, edad_max, monto_min_disp,monto_max_disp,
						(SELECT {+INDEX(sd_cattipopago idx_sd_cattipopago)} a.valor FROM sd_cattipopago a, sd_subproducto b WHERE SUBSTR(a.tipo_pago,0,1) = b.periodo_plazo AND b.num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto) AS periodo_plazo,
						comi_gasto_cobranza, cobro_comision_anual, comi_disposicion_efect, comi_aclaracion_No, comi_liquidacion_antic, cobro_comis_apertura, garantias, (SELECT a.tipo_garantia FROM sd_tipo_garantia a , sd_subproducto b WHERE a.id_garantia = b.idgarantia AND b.num_producto  = p_num_producto AND id_subproducto  = p_Id_subproducto) AS tipo_garantia, 
						porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, cuentas_medios, cancelacion_inac, cancelacion_Vig, tiempo_cancelar, seguro_vida, cobro_mensualidad, envio_mesa_control, id_domiciliacion, conciliador, historico_cred, periodo_gracia, dias_gracia, capital_interes, intereses, capital, estado_cuenta,
						(SELECT a.id_estdocta FROM sd_tipo_edocta a, sd_subproducto b WHERE a.id_estdocta = b.id_estadocuenta AND b.num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto) AS id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,idcta_concentradora,cta_concentradora,envia_os,rangoini_gracia,rangofin_gracia
						INTO   cId_subproducto,cDesc_subproducto, cNum_Producto,cNomb_Producto,cPlazo_Minimo,cPlazo_Maximo,cMonto_Min_Cred,cMonto_Max_Cred,cEdad_Minima,cEdad_Maxima,cMonto_Min_Disp,cMonto_max_disp,cPeriodo_Plazo,cComision_Gastos,cComision_Anualidad,
						cComision_Disposicion,cComision_Aclaracion, cComision_Liquidacion,cComision_Apertura,cGarantias,cTipo_Garantia,cPorcentaje_Aforo,cObligado_Solidario,cNum_Obligados,cCaptura_Obligatoria,cCuentas_Medios,cCancelacion_Inac,cCancelacion_Vig,
						cTiempo_Cancelar,cSeguro_Vida,cCobro_Mensualidad,cEnvio_Mesa_Control,cId_Domiciliacion,cConciliador,	cHistorico_Cred,cPeriodo_Gracia,cDias_Gracia,cCapital_Interes,cIntereses,Ccapital,cEstado_Cuenta,cId_Edocta,cEmision_estado_cuenta,cRango_inicial,cRango_final,
						cIdcta_concentradora,cCta_concentradora,cEnvia_os,cRangoini_gracia,cRangofin_gracia
						FROM  "informix".sd_subproducto
						WHERE nombre_prod  = p_nombre_prod AND num_producto  = p_num_producto AND id_subproducto  = p_Id_subproducto;

						SELECT form_aplica
						INTO flag_tpcomis_ComGastos
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comi_gasto_cobranza
						AND id_subproducto = p_Id_subproducto;	

						IF flag_tpcomis_ComGastos = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Gastos FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_gasto_cobranza AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;							
						ELIF flag_tpcomis_ComGastos = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Gastos FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_gasto_cobranza AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;																	
						END IF;						

						SELECT form_aplica
						INTO flag_tpcomis_ComAnualidad
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comision_anualidad
						AND id_subproducto = p_Id_subproducto;

						IF flag_tpcomis_ComAnualidad = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Anualid FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_anualidad AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;										
						ELIF flag_tpcomis_ComAnualidad = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Anualid FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_anualidad AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;																
						END IF;							
						
						SELECT form_aplica
						INTO flag_tpcomis_ComDisposicion
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comision_efectivo
						AND id_subproducto = p_Id_subproducto;
						
						IF flag_tpcomis_ComDisposicion = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Dispos FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_efectivo AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;		
						ELIF flag_tpcomis_ComDisposicion = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Dispos FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_efectivo AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;						
						END IF;									
												
						SELECT form_aplica
						INTO flag_tpcomis_ComAclaracion
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comi_aclaracion_no
						AND id_subproducto = p_Id_subproducto;
						
						IF flag_tpcomis_ComAclaracion = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Aclar FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_aclaracion_no AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;															
						ELIF flag_tpcomis_ComAclaracion = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Aclar FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_aclaracion_no AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;																	
						END IF;						
											
						SELECT form_aplica
						INTO flag_tpcomis_ComLiquidacion
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comi_liquidacion_antic
						AND id_subproducto = p_Id_subproducto;
						
						IF flag_tpcomis_ComLiquidacion = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Liquid FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_liquidacion_antic AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto; 			
						ELIF flag_tpcomis_ComLiquidacion = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Liquid FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comi_liquidacion_antic AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto; 									
						END IF;							
						
						SELECT form_aplica
						INTO flag_tpcomis_ComApertura
						FROM sd_tpcomis a,sd_subproducto b
						WHERE a.cod_comis = b.cod_comision_apertura
						AND id_subproducto = p_Id_subproducto;

						IF flag_tpcomis_ComApertura = 1 THEN 
							SELECT a.monto INTO cValor_Comision_Aper FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_apertura AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;	
						ELIF flag_tpcomis_ComApertura = 2 THEN 
							SELECT a.apli_factor INTO cValor_Comision_Aper FROM sd_tpcomis a,sd_subproducto b WHERE a.cod_comis = b.cod_comision_apertura AND num_producto = p_num_producto AND id_subproducto  = p_Id_subproducto;						
						END IF;							
						
						IF p_tpo_ejecucion = '1' THEN
							LET vVariable1 = cId_subproducto::VARCHAR(100);
							LET vVariable2 = cDesc_subproducto::VARCHAR(100);
							LET vVariable3 = cNum_Producto::VARCHAR(100);
							LET vVariable4 = cNomb_Producto::VARCHAR(100);
							LET vVariable5 = cPlazo_Minimo::VARCHAR(100);
							LET vVariable6 = cPlazo_Maximo::VARCHAR(100);	
							LET vVariable7 = cMonto_Min_Cred::VARCHAR(100);
							LET vVariable8 = cMonto_Max_Cred::VARCHAR(100);				  
						ELIF p_tpo_ejecucion = '2' THEN
							LET vVariable1 = cEdad_Minima::VARCHAR(100);
							LET vVariable2 = cEdad_Maxima::VARCHAR(100);
							LET vVariable3 = cMonto_Min_Disp::VARCHAR(100);
							LET vVariable4 = cPeriodo_Plazo::VARCHAR(100);
							LET vVariable5 = cComision_Gastos::VARCHAR(100);
							LET vVariable6 = cValor_Comision_Gastos::VARCHAR(100);	
							LET vVariable7 = cComision_Anualidad::VARCHAR(100);
							LET vVariable8 = cValor_Comision_Anualid::VARCHAR(100);							
						ELIF p_tpo_ejecucion = '3' THEN
							LET vVariable1 = cComision_Disposicion::VARCHAR(100);
							LET vVariable2 = cValor_Comision_Dispos::VARCHAR(100);
							LET vVariable3 = cComision_Aclaracion::VARCHAR(100);
							LET vVariable4 = cValor_Comision_Aclar::VARCHAR(100);
							LET vVariable5 = cComision_Liquidacion::VARCHAR(100);
							LET vVariable6 = cValor_Comision_Liquid::VARCHAR(100);	
							LET vVariable7 = cComision_Apertura::VARCHAR(100);
							LET vVariable8 = cValor_Comision_Aper::VARCHAR(100);					
						ELIF p_tpo_ejecucion = '4' THEN
							LET vVariable1 = cGarantias::VARCHAR(100);
							LET vVariable2 = cTipo_Garantia::VARCHAR(100);
							LET vVariable3 = cPorcentaje_Aforo::VARCHAR(100);
							LET vVariable4 = cObligado_Solidario::VARCHAR(100);
							LET vVariable5 = cNum_Obligados::VARCHAR(100);
							LET vVariable6 = cCaptura_Obligatoria::VARCHAR(100);
							LET vVariable7 = cCuentas_Medios::VARCHAR(100);
							LET vVariable8 = cCancelacion_Inac::VARCHAR(100);					
						ELIF p_tpo_ejecucion = '5' THEN
							LET vVariable1 = cCancelacion_Vig::VARCHAR(100);
							LET vVariable2 = cTiempo_Cancelar::VARCHAR(100);
							LET vVariable3 = cSeguro_Vida::VARCHAR(100);
							LET vVariable4 = cCobro_Mensualidad::VARCHAR(100);
							LET vVariable5 = cEnvio_Mesa_Control::VARCHAR(100);
							LET vVariable6 = cId_Domiciliacion::VARCHAR(100);
							LET vVariable7 = cConciliador::VARCHAR(100);
							LET vVariable8 = cHistorico_Cred::VARCHAR(100);	
						ELIF p_tpo_ejecucion = '6' THEN
							LET vVariable1 = cPeriodo_Gracia::VARCHAR(100);
							LET vVariable2 = cDias_Gracia::VARCHAR(100);
							LET vVariable3 = cCapital_Interes::VARCHAR(100);
							LET vVariable4 = cIntereses::VARCHAR(100);
							LET vVariable5 = cEstado_Cuenta::VARCHAR(100);
							LET vVariable6 = cId_Edocta::VARCHAR(100);		
							LET vVariable7 = cEmision_estado_cuenta::VARCHAR(100);
							LET vVariable8 = cRango_inicial::VARCHAR(100);
						ELIF p_tpo_ejecucion = '7' THEN
							LET vVariable1 = cRango_final::VARCHAR(100);
							LET vVariable2 = cIdcta_concentradora::VARCHAR(100);
							LET vVariable3 = cCta_concentradora::VARCHAR(100);
							LET vVariable4 = cMonto_max_disp::VARCHAR(100);
							LET vVariable5 = Ccapital::VARCHAR(100);
							LET vVariable6 = cEnvia_os::VARCHAR(100);
							LET vVariable7 = flag_tpcomis_ComGastos::VARCHAR(100);
							LET vVariable8 = flag_tpcomis_ComAnualidad::VARCHAR(100);
						ELIF p_tpo_ejecucion = '8' THEN
							LET vVariable1 = flag_tpcomis_ComDisposicion::VARCHAR(100);
							LET vVariable2 = flag_tpcomis_ComAclaracion::VARCHAR(100);
							LET vVariable3 = flag_tpcomis_ComLiquidacion::VARCHAR(100);
							LET vVariable4 = flag_tpcomis_ComApertura::VARCHAR(100);
							LET vVariable5 = cRangoini_gracia::VARCHAR(100);
							LET vVariable6 = cRangofin_gracia::VARCHAR(100);
							LET vVariable7 = '';
							LET vVariable8 = '';	

							IF LENGTH(cId_subproducto) < 2 THEN
								LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), CONCAT('0',cId_subproducto));
							ELSE
								LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), cId_subproducto);
							END IF;						
							--Se  agrega registro en temporal para identificar que se trata de un subproducto cuando se ejecute el sp de frecuencia de pago
							INSERT INTO "informix".tmp_sd_frectipopago
							SELECT 0,tipo_pago,num_producto
							FROM "informix".sd_frectipopago
							WHERE num_producto = cAuxId_subproducto;							
						END IF;					
						
						RETURN cCodRet,vVariable1,vVariable2,vVariable3, vVariable4, vVariable5,vVariable6,vVariable7,vVariable8;
					END IF;
				END IF;	
			ELSE
				LET cCodRet = '00002';
				RETURN cCodRet,vVariable1,vVariable2,vVariable3, vVariable4, vVariable5,vVariable6,vVariable7,vVariable8;
			END IF;
		END IF;
	END
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_consulta_subproducto" para obtener los datos de un subproducto previamente registrado',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_inserta_subproducto(pDesc_subproducto VARCHAR(100),pNum_producto CHAR(4),pNomb_Producto CHAR(40))

	RETURNING CHAR(5) AS CodRet, --Codigo de retorno
			  CHAR(5) AS cId_subproducto; --Id de subproducto; 
  
	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 				 	   CHAR(5);
	DEFINE iSqlErr  			 	   INTEGER;
	DEFINE vExiste_Subprod		 	   SMALLINT;
	DEFINE vExisteId				   SMALLINT;
	DEFINE cId_subproducto 		 	   CHAR(5);
	DEFINE cAuxId_subproducto 		   VARCHAR(5);
	DEFINE cNum_Producto			   CHAR(4);
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vExiste_Subprod = 0;
	LET vExisteId = 0;
	LET cId_subproducto = '';
	LET cAuxId_subproducto = '';
	LET cNum_Producto = '';
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cId_subproducto;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/Stored_Procedures/sp_inserta_subproducto.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // Valida parametros de entrada
		IF (pDesc_subproducto = '' AND pNum_producto = '' AND pNomb_Producto = '') THEN
			LET cCodRet = '00001';
		ELSE
			--Verifica si existe subproducto
			SELECT {+INDEX(sd_subproducto idx_sd_subproducto)} COUNT(*)
			INTO   vExiste_Subprod
			FROM   "informix".sd_subproducto
			WHERE  desc_subproducto = pDesc_subproducto;

			IF vExiste_Subprod = 0 THEN
				SELECT COUNT(*)
				INTO vExisteId
				FROM "informix".sd_subproducto;
				
				IF vExisteId = 0 THEN
					SELECT num_producto
					INTO cNum_Producto
					FROM "informix".sd_definicion
					WHERE num_producto = pNum_producto OR pNomb_Producto = nombre_prod;
				
					LET cId_subproducto = '1';		
					LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), CONCAT('0',cId_subproducto));
					
					INSERT INTO "informix".sd_subproducto (id_subproducto,desc_subproducto,empresa,num_producto,cod_tipcred,nombre_prod,monto_min_cred,monto_max_cred,edad_min,edad_max,divisa,se_valoriza,tipo_calculo,tasa_fija_o_var,cod_tasa_base,sobretasa,factor_sobretasa,
					tipo_refinanc,porcent_refinanc,pago_adic_sig_cuo,period_pag_int,period_pago_cap,dias_traspaso_int,dias_traspaso_cap,periodo_plazo,plazo_min_cred,plazo_max_cred,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,factor_moratorio,rev_tasa_var_per,dia_para_revisar,preautoriza,tasa_base_piso,
					sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,band_prod,cod_prod,tpo_persona,tipo_cliente,segmentado,por_acciones,maneja_linea,maneja_mora,maneja_pago_sost,capitaliza,cuenta_asosciada,llena_solicitud,lleva_nombre,dia_cuota,gracia_calc_mora,user_insert,
					fecha_insert,cat_edocta,cat_caratula,activa_calif,siglas,ind_comision,tran_comision,prefijo_os,rechazo_rgc,f_modifica_montos,monto_min_disp,monto_max_disp,factor_pago_min,mto_pago_min,fact_pag_min_lc,fac_pagm_suma_sdo,flag_arbol,realizar_convenio,cobro_comision_anual,cobro_anual_titular,cobro_anual_adicional,
					fecha_1er_cobro_anual,cobro_parcializ_anual,cod_comision_efectivo,cobro_comis_apertura,cod_comision_apertura,cod_comision_anualidad,cat_comi_anual_adicional,bandera_os,plazo_linea,edocta_param,cod_rep_rob,cod_rep_ext,cod_rep_danmal,cod_rep_acl,cod_rep_ven,cod_rep_pet,id_domiciliacion,id_tasa_pref,
					puntos_tasa_pref,cat_edc_com_anualidad,id_excluye_os,msj_alta_movil,cod_financiero,transacc_spei,dias_cobro_aut,reporte_cartera,link_carta,link_carta_activo,valida_sms,ind_disp_efec,oferta_emp,familia,garantias,idgarantia,porcentajeaforo,comi_gasto_cobranza,cod_comi_gasto_cobranza,comi_aclaracion_no,
					cod_comi_aclaracion_no,comi_liquidacion_antic,cod_comi_liquidacion_antic,obligado_solidario,num_obligados,captura_obligatoria,conciliador,historico_cred,cancelacion_inac,cancelacion_vig,seguro_vida,periodo_gracia,dias_gracia,comi_disposicion_efect,cierre_prest,tipo_nomina,cuentas_medios,tiempo_cancelar,
					cobro_mensualidad,envio_mesa_control,capital_interes,intereses,capital,id_tipo_facturacion,n_dias_facturacion,dia_facturacion,rango_f_fecha_inic,rango_f_fecha_fin,estado_cuenta,id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,idcta_concentradora,cta_concentradora,envia_os,rangoini_gracia,rangofin_gracia)
					SELECT cId_subproducto AS id_subproducto,pDesc_subproducto AS desc_subproducto,empresa,num_producto,cod_tipcred,nombre_prod,monto_min_cred,monto_max_cred,edad_min,edad_max,divisa,se_valoriza,tipo_calculo,tasa_fija_o_var,cod_tasa_base,sobretasa,factor_sobretasa,
					tipo_refinanc,porcent_refinanc,pago_adic_sig_cuo,period_pag_int,period_pago_cap,dias_traspaso_int,dias_traspaso_cap,periodo_plazo,plazo_min_cred,plazo_max_cred,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,factor_moratorio,rev_tasa_var_per,dia_para_revisar,preautoriza,tasa_base_piso,
					sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,band_prod,cod_prod,tpo_persona,tipo_cliente,segmentado,por_acciones,maneja_linea,maneja_mora,maneja_pago_sost,capitaliza,cuenta_asosciada,llena_solicitud,lleva_nombre,dia_cuota,gracia_calc_mora,user_insert,
					fecha_insert,cat_edocta,cat_caratula,activa_calif,siglas,ind_comision,tran_comision,prefijo_os,rechazo_rgc,f_modifica_montos,monto_min_disp,monto_max_disp,factor_pago_min,mto_pago_min,fact_pag_min_lc,fac_pagm_suma_sdo,flag_arbol,realizar_convenio,cobro_comision_anual,cobro_anual_titular,cobro_anual_adicional,
					fecha_1er_cobro_anual,cobro_parcializ_anual,cod_comision_efectivo,cobro_comis_apertura,cod_comision_apertura,cod_comision_anualidad,cat_comi_anual_adicional,bandera_os,plazo_linea,edocta_param,cod_rep_rob,cod_rep_ext,cod_rep_danmal,cod_rep_acl,cod_rep_ven,cod_rep_pet,id_domiciliacion,id_tasa_pref,
					puntos_tasa_pref,cat_edc_com_anualidad,id_excluye_os,msj_alta_movil,cod_financiero,transacc_spei,dias_cobro_aut,reporte_cartera,link_carta,link_carta_activo,valida_sms,ind_disp_efec,oferta_emp,familia,garantias,idgarantia,porcentajeaforo,comi_gasto_cobranza,cod_comi_gasto_cobranza,comi_aclaracion_no,
					cod_comi_aclaracion_no,comi_liquidacion_antic,cod_comi_liquidacion_antic,obligado_solidario,num_obligados,captura_obligatoria,conciliador,historico_cred,cancelacion_inac,cancelacion_vig,seguro_vida,periodo_gracia,dias_gracia,comi_disposicion_efect,cierre_prest,tipo_nomina,cuentas_medios,tiempo_cancelar,
					cobro_mensualidad,envio_mesa_control,capital_interes,intereses,capital,id_tipo_facturacion,n_dias_facturacion,dia_facturacion,rango_f_fecha_inic,rango_f_fecha_fin,estado_cuenta,id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,idcta_concentradora,cta_concentradora,envia_os,rangoini_gracia,rangofin_gracia
					FROM "informix".sd_definicion
					WHERE num_producto = pNum_producto OR pNomb_Producto = nombre_prod;
					
					INSERT INTO "informix".sd_tasas_disposiciones_diferenciadas
					SELECT empresa,CURRENT AS fecha_tasa,cAuxId_subproducto AS num_producto,grupo,evalua_cc,tasa_int_ordinaria,tasa_int_moratoria,porc_max_disposicion,meses_buen_comp_disp,CURRENT AS fecha_insert,cId_subproducto AS id_subproducto
					FROM "informix".sd_tasas_disposiciones_diferenciadas
					WHERE num_producto = pNum_producto;
					
					INSERT INTO "informix".sd_frectipopago
					SELECT valor,tipo_pago,cAuxId_subproducto AS num_producto_id
					FROM "informix".sd_frectipopago
					WHERE num_producto = cNum_Producto;
					
				ELSE
					SELECT num_producto
					INTO cNum_Producto
					FROM "informix".sd_definicion
					WHERE num_producto = pNum_producto OR pNomb_Producto = nombre_prod;
					
					SELECT MAX(id_subproducto)
					INTO cId_subproducto
					FROM "informix".sd_subproducto;
					
					LET cId_subproducto = (cId_subproducto::INTEGER)+1;
					
					IF LENGTH(cId_subproducto) < 2 THEN
						LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), CONCAT('0',cId_subproducto));
					ELSE
						LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), cId_subproducto);
					END IF;
					
					INSERT INTO "informix".sd_subproducto (id_subproducto,desc_subproducto,empresa,num_producto,cod_tipcred,nombre_prod,monto_min_cred,monto_max_cred,edad_min,edad_max,divisa,se_valoriza,tipo_calculo,tasa_fija_o_var,cod_tasa_base,sobretasa,factor_sobretasa,
					tipo_refinanc,porcent_refinanc,pago_adic_sig_cuo,period_pag_int,period_pago_cap,dias_traspaso_int,dias_traspaso_cap,periodo_plazo,plazo_min_cred,plazo_max_cred,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,factor_moratorio,rev_tasa_var_per,dia_para_revisar,preautoriza,tasa_base_piso,
					sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,band_prod,cod_prod,tpo_persona,tipo_cliente,segmentado,por_acciones,maneja_linea,maneja_mora,maneja_pago_sost,capitaliza,cuenta_asosciada,llena_solicitud,lleva_nombre,dia_cuota,gracia_calc_mora,user_insert,
					fecha_insert,cat_edocta,cat_caratula,activa_calif,siglas,ind_comision,tran_comision,prefijo_os,rechazo_rgc,f_modifica_montos,monto_min_disp,monto_max_disp,factor_pago_min,mto_pago_min,fact_pag_min_lc,fac_pagm_suma_sdo,flag_arbol,realizar_convenio,cobro_comision_anual,cobro_anual_titular,cobro_anual_adicional,
					fecha_1er_cobro_anual,cobro_parcializ_anual,cod_comision_efectivo,cobro_comis_apertura,cod_comision_apertura,cod_comision_anualidad,cat_comi_anual_adicional,bandera_os,plazo_linea,edocta_param,cod_rep_rob,cod_rep_ext,cod_rep_danmal,cod_rep_acl,cod_rep_ven,cod_rep_pet,id_domiciliacion,id_tasa_pref,
					puntos_tasa_pref,cat_edc_com_anualidad,id_excluye_os,msj_alta_movil,cod_financiero,transacc_spei,dias_cobro_aut,reporte_cartera,link_carta,link_carta_activo,valida_sms,ind_disp_efec,oferta_emp,familia,garantias,idgarantia,porcentajeaforo,comi_gasto_cobranza,cod_comi_gasto_cobranza,comi_aclaracion_no,
					cod_comi_aclaracion_no,comi_liquidacion_antic,cod_comi_liquidacion_antic,obligado_solidario,num_obligados,captura_obligatoria,conciliador,historico_cred,cancelacion_inac,cancelacion_vig,seguro_vida,periodo_gracia,dias_gracia,comi_disposicion_efect,cierre_prest,tipo_nomina,cuentas_medios,tiempo_cancelar,
					cobro_mensualidad,envio_mesa_control,capital_interes,intereses,capital,id_tipo_facturacion,n_dias_facturacion,dia_facturacion,rango_f_fecha_inic,rango_f_fecha_fin,estado_cuenta,id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,idcta_concentradora,cta_concentradora,envia_os,rangoini_gracia,rangofin_gracia)
					SELECT cId_subproducto AS id_subproducto,pDesc_subproducto AS desc_subproducto,empresa,num_producto,cod_tipcred,nombre_prod,monto_min_cred,monto_max_cred,edad_min,edad_max,divisa,se_valoriza,tipo_calculo,tasa_fija_o_var,cod_tasa_base,sobretasa,factor_sobretasa,
					tipo_refinanc,porcent_refinanc,pago_adic_sig_cuo,period_pag_int,period_pago_cap,dias_traspaso_int,dias_traspaso_cap,periodo_plazo,plazo_min_cred,plazo_max_cred,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,factor_moratorio,rev_tasa_var_per,dia_para_revisar,preautoriza,tasa_base_piso,
					sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,band_prod,cod_prod,tpo_persona,tipo_cliente,segmentado,por_acciones,maneja_linea,maneja_mora,maneja_pago_sost,capitaliza,cuenta_asosciada,llena_solicitud,lleva_nombre,dia_cuota,gracia_calc_mora,user_insert,
					fecha_insert,cat_edocta,cat_caratula,activa_calif,siglas,ind_comision,tran_comision,prefijo_os,rechazo_rgc,f_modifica_montos,monto_min_disp,monto_max_disp,factor_pago_min,mto_pago_min,fact_pag_min_lc,fac_pagm_suma_sdo,flag_arbol,realizar_convenio,cobro_comision_anual,cobro_anual_titular,cobro_anual_adicional,
					fecha_1er_cobro_anual,cobro_parcializ_anual,cod_comision_efectivo,cobro_comis_apertura,cod_comision_apertura,cod_comision_anualidad,cat_comi_anual_adicional,bandera_os,plazo_linea,edocta_param,cod_rep_rob,cod_rep_ext,cod_rep_danmal,cod_rep_acl,cod_rep_ven,cod_rep_pet,id_domiciliacion,id_tasa_pref,
					puntos_tasa_pref,cat_edc_com_anualidad,id_excluye_os,msj_alta_movil,cod_financiero,transacc_spei,dias_cobro_aut,reporte_cartera,link_carta,link_carta_activo,valida_sms,ind_disp_efec,oferta_emp,familia,garantias,idgarantia,porcentajeaforo,comi_gasto_cobranza,cod_comi_gasto_cobranza,comi_aclaracion_no,
					cod_comi_aclaracion_no,comi_liquidacion_antic,cod_comi_liquidacion_antic,obligado_solidario,num_obligados,captura_obligatoria,conciliador,historico_cred,cancelacion_inac,cancelacion_vig,seguro_vida,periodo_gracia,dias_gracia,comi_disposicion_efect,cierre_prest,tipo_nomina,cuentas_medios,tiempo_cancelar,
					cobro_mensualidad,envio_mesa_control,capital_interes,intereses,capital,id_tipo_facturacion,n_dias_facturacion,dia_facturacion,rango_f_fecha_inic,rango_f_fecha_fin,estado_cuenta,id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,idcta_concentradora,cta_concentradora,envia_os,rangoini_gracia,rangofin_gracia
					FROM "informix".sd_definicion
					WHERE num_producto = pNum_producto OR pNomb_Producto = nombre_prod;
					
					INSERT INTO "informix".sd_tasas_disposiciones_diferenciadas
					SELECT empresa,CURRENT AS fecha_tasa,cAuxId_subproducto AS num_producto,grupo,evalua_cc,tasa_int_ordinaria,tasa_int_moratoria,porc_max_disposicion,meses_buen_comp_disp,CURRENT AS fecha_insert,cId_subproducto AS id_subproducto
					FROM "informix".sd_tasas_disposiciones_diferenciadas
					WHERE num_producto = cNum_Producto;
					
					INSERT INTO "informix".sd_frectipopago
					SELECT valor,tipo_pago,cAuxId_subproducto AS num_producto_id
					FROM "informix".sd_frectipopago
					WHERE num_producto = cNum_Producto;
					
				END IF;
			ELSE
				LET cCodRet = '00002';
			END IF;
		END IF;
		RETURN cCodRet,cId_subproducto;
	END
END PROCEDURE
DOCUMENT
'AUTOR:EVER FIERRO HERNANDEZ',
'Se crea el procedimiento almacenado "sp_inserta_subproducto" para insertar el subproducto en la tabla de las tasas "sd_tasas_disposiciones_diferenciadas"',
'Y en la tabla de los Subproductos "sd_subproducto" ',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_cancelacion_ctas_x_plastico_cancelado(pEmpresa CHAR(3))
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(150,1) AS mensaje_retorno;

DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(150,1);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(150,1);

DEFINE cEmpresa         CHAR(3);
DEFINE dtFechaHoy       DATE;
DEFINE dtFechaCompara   DATE;
DEFINE iMeses           INTEGER;
DEFINE cNumCred         VARCHAR(20,1);
DEFINE cCodRetAux       CHAR(5);
DEFINE cFolioSucAux     CHAR(16);
DEFINE iTotalRegistros  INTEGER;
DEFINE cFechaGenArchivo CHAR(8);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2704);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2304);
DEFINE cSQL3                CHAR(200);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";
LET cMensajeRet     = "PROCESO EXITOSO";

LET cEmpresa        = "";
LET dtFechaHoy      = DATE(1);
LET dtFechaCompara  = DATE(1);
LET iMeses          = 0;
LET cNumCred        = "";
LET cCodRetAux      = "";
LET cFolioSucAux    = "";
LET iTotalRegistros = 0;
LET cFechaGenArchivo = "";
LET cnomarchivo  = "";
LET cnomarchivo1 = "";
LET cnomarchivoEjecSql = "";
LET cSQL       = "";
LET cSQL1      = "";
LET cSQL2      = "";
LET cSQL3      = "";
LET cruta      = "/resplogifx/archivoscartera/";
--LET cruta      = "/informix/Paulq/Disminucion/";
LET cnombre	   = "candidatos_cancelacion_";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

set isolation to dirty read;
set lock mode to wait 3;
--SET PDQPRIORITY 5; HMD-INCIDENCIA-20220224


 --SET DEBUG FILE TO '/informix/paulq/pbas/sp_cancelacion_ctas_x_plastico_cancelado.out';
 --TRACE ON;

 SELECT empresa
   INTO cEmpresa     
   FROM bdinteg:si_empresas 
  WHERE empresa= pEmpresa;
  
  IF TRIM(NVL(cEmpresa,'')) = '' THEN
	  LET cCodRet = '000001';
	  LET cMensajeRet = 'El parámetro de la empresa no es valido';
	  RETURN cCodRet, cMensajeRet;
  END IF;

	SELECT fecha_hoy
      INTO dtFechaHoy
	  FROM 'informix'.sd_fechas
	 WHERE empresa = pEmpresa;

	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		LET cMensajeRet = 'La fecha del sistema no es valida';
		RETURN cCodRet,cMensajeRet;
	END IF;
 

	SELECT TRIM(valor)::INTEGER
		INTO iTotalRegistros
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "184";	
 
 	IF NVL(iTotalRegistros,0) = 0 THEN
		LET cCodRet = '000005';
		LET cMensajeRet = 'El limite de cuentas por cancelar mensual no es correcto';
		RETURN cCodRet,cMensajeRet;
	END IF;


TRUNCATE TABLE "informix".paso_can_x_plastico_cancelados;

  INSERT INTO "informix".paso_can_x_plastico_cancelados
SELECT LIMIT iTotalRegistros {+MULTI_INDEX("informix".sd_maecred)} 
a.num_credito AS num_credito,
a.numcte AS num_cliente,
a.sucursal AS numero_sucursal,
b.monto_otorgado AS linea_credito,
b.sdo_cap_insoluto AS saldo_fecha_cancelacion,
DATE(1) AS fecha_primer_compra_o_disposicion,
a.fecha_apertura AS fecha_Apertura,
e.fechaultmodif::DATE AS fecha_cancelacion_plastico,
TODAY
FROM bdicred:"informix".sd_maecred a
INNER JOIN bdicred:"informix".sd_maesdos b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito AND  b.sdo_capital = 0 AND b.sdo_cap_insoluto = 0 AND b.sdo_retenido = 0)
INNER JOIN bdicred:"informix".sd_indicador_cred c ON (c.num_credito = a.num_credito AND c.empresa = a.empresa AND NVL(fecha_ultimo_pago,DATE(1))= DATE(1) AND NVL(fecha_ultima_compra,DATE(1))= DATE(1))
INNER JOIN bdicred:"informix".sd_tarjeta d ON (d.empresa = a.empresa AND d.num_credito = a.num_credito 
        AND d.secuencia = (SELECT MAX(f.secuencia) FROM bdicred:sd_tarjeta f WHERE
                               f.empresa = d.empresa AND f.num_credito = d.num_credito AND f.tipo_tarjeta = d.tipo_tarjeta AND f.status_tar = f.status_tar)
    AND d.tipo_tarjeta = 'T'
    AND d.status_tar = 'C')
INNER JOIN intercard:"informix".tarjeta e ON (e.numtarjeta = d.num_tarjeta AND codstatustarjeta = 'CAN')
WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
       AND a.num_producto IN('6001','6600','8100')
           AND a.status_cred IN ('AA','E1')
       AND a.fecha_apertura = a.fecha_apertura
       AND (e.fechaultmodif::date - a.fecha_apertura) <=30
       AND (TODAY - e.fechaultmodif::date) >= 30
       AND a.num_credito not in (SELECT g.num_credito FROM bdicred:sd_tarjeta g WHERE
                               g.empresa = a.empresa AND g.num_credito = a.num_credito AND g.tipo_tarjeta = 'A' AND g.status_tar = g.status_tar);

   
   UPDATE STATISTICS HIGH FOR TABLE "informix".paso_can_x_plastico_cancelados;

  FOREACH WITH HOLD     
	  SELECT num_credito
		INTO cNumCred
		FROM "informix".paso_can_x_plastico_cancelados	
		
			EXECUTE PROCEDURE "informix".sp_cancelarcredito(pEmpresa,cNumCred,'4',"92579841","92579841","4","9290")
			INTO cCodRetAux, cFolioSucAux;
			
			IF cCodRetAux::INTEGER <> 0 THEN
			   DELETE FROM "informix".paso_can_x_plastico_cancelados WHERE num_credito = cNumCred;
			END IF;				
  END FOREACH
  
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '000006';
	LET cMensajeRet = 'No hay creditos por cancelar';
	
ELSE

	LET cFechaGenArchivo =  to_char(dtFechaHoy,'%d%m%y');	
	LET cnomarchivo1 = TRIM(cnombre)||TRIM(cFechaGenArchivo)||'_Aux_'||'.txt ';
    LET cnomarchivo =  TRIM(cnombre)||TRIM(cFechaGenArchivo)||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_can_x_plastico' || '.sql';
	    

    LET cSQL='';
    LET cSQL = 'echo "Numero de Credito'||'|'||'Numero de Cliente'||'|'||'Numero de Sucursal'||'|'||'Linea de Credito'
			   ||'|'||'Saldo a la Fecha de Cancelacion'||'|'||'Fecha primer 1a Compra o Disposicion'
               ||'|'||'Fecha de Apertura'||'|'||'Fecha de Cancelacion Plastico'
               ||'|'||'Fecha de Cancelacion'||' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;
	
		
	LET cSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);

     LET cSQL2 = " SELECT num_credito, numcte, sucursal, linea_credito,saldo_fecha_cancelacion, "
	        || " fecha_1_compra_disposicion, fecha_apertura, "
			|| " fecha_cancelacion_plastico, "
			|| " fecha_cancelacion "
			|| " FROM bdicred:'informix'.paso_can_x_plastico_cancelados; ";
		
			
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;	

END IF;

	RETURN cCodRet,cMensajeRet;

END

END PROCEDURE
DOCUMENT 
'Se realiza procedimiento realizar la cancelación',
'de cuentas por plastico cancelado',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 15/OCTUBRE/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cierre_diario_pp_parte_mib(pEmpresa CHAR(3), pCodTipCred CHAR(2), pProceso CHAR(3))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

-- Modifico: Francisco Martinez Viveros
-- Fecha: 21/mar/2013
-- Comentario: Se adicionan los movimientos de provision a fin de mes, para los prestamos que facturan el dia 1o. de mes
-- se genera el movimiento provision del periodo al dia 31 y el movimiento del dia 1 mas su facturacion.
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(125);

DEFINE cBegin         CHAR(1);
DEFINE cFolio         CHAR(16);
DEFINE cEmpresa       CHAR(3);
DEFINE cNumCredito    CHAR(20);
DEFINE cStatusCred    CHAR(2);
DEFINE cStatusCredAnt CHAR(2);
DEFINE cStatusCredIndica CHAR(2);
DEFINE cDivisa        CHAR(2);
DEFINE cNumProducto   CHAR(4);
DEFINE dtFechaApert   DATE;
DEFINE iDiaCorte      INTEGER;
DEFINE cSucursal      CHAR(4);
DEFINE cPlaza         CHAR(3);
DEFINE dIvaSuc        DECIMAL(5,3);
DEFINE cCodTipCred    CHAR(2);
DEFINE iDiasCalc      INTEGER;
DEFINE dtFechaHoy     DATE;
DEFINE dtFechaHoyAux  DATE;
DEFINE dtFechaProx    DATE;
DEFINE dtFechaFinMes  DATE;
--DEFINE dtFechaFinMesAnt DATE;
DEFINE dtFechaProxCuota  DATE;
DEFINE dtFechaVencto  DATE;
DEFINE iDiasInt       INTEGER;
DEFINE iDiasInt_inh   INTEGER;

DEFINE dIntDiario     DECIMAL(18,2);
DEFINE dIntDiario_inh DECIMAL(18,2);

DEFINE dTasaInter       DECIMAL(9,6);
DEFINE dTasaInterMor    DECIMAL(9,6);
DEFINE dTasaInterMorCop DECIMAL(9,6);
DEFINE dSdoCapital      DECIMAL(18,2);
DEFINE dMntVencido      DECIMAL(18,2);
DEFINE dMntVencTras     DECIMAL(18,2);
DEFINE dCapTrasNoVen    DECIMAL(18,2);
DEFINE dSdoCapInso      DECIMAL(18,2);
DEFINE dSdoNoExig       DECIMAL(18,2);
DEFINE dSdoInt          DECIMAL(18,2);
DEFINE dSdoInt_inh      DECIMAL(18,2);
DEFINE dSdodiaantint    DECIMAL(18,2);
DEFINE dSdomesantint    DECIMAL(18,2);
DEFINE dSdomoratorio    DECIMAL(18,2);
DEFINE dSdocontabmora   DECIMAL(18,2);
DEFINE dMontofinanciado DECIMAL(18,2);
DEFINE dIvaIntVencido   DECIMAL(18,2);
DEFINE dIvaIntVigente   DECIMAL(18,2);
DEFINE dSdotrab4        DECIMAL(18,2);
DEFINE dSdo             DECIMAL(18,2);
DEFINE dtFechaCuota     DATE;
DEFINE dtFechaCuotaAnt  DATE;
DEFINE dProvInt       	DECIMAL(14,2);
DEFINE dProvInt_inh    	DECIMAL(14,2);
DEFINE dIvaPag        	DECIMAL(14,2);
--ini cas
DEFINE dIntGrav      	DECIMAL(14,2);
DEFINE dIntExen       	DECIMAL(14,2);
DEFINE dIntGrav_inh   	DECIMAL(14,2); --FMV
DEFINE dIntExen_inh    	DECIMAL(14,2); --FMV

DEFINE dtIvaFechaPag    DATE;
DEFINE dCapMtoCuota     DECIMAL(14,2);
DEFINE dCapMtoCuota_ori DECIMAL(14,2);
DEFINE iNumPago         INTEGER;
DEFINE dProvIva       	DECIMAL(14,2);
DEFINE dProvIva_inh    	DECIMAL(14,2); --FMV
DEFINE dIntVdo          DECIMAL(18,2);
DEFINE dTraspCap        DECIMAL(14,2);
DEFINE dTraspInt        DECIMAL(18,2);
DEFINE cCapStatusCuota  CHAR(1);
DEFINE dSdoMora         DECIMAL(18,2);
DEFINE dIntMora         DECIMAL(18,2);
DEFINE dIntCope         DECIMAL(18,2);
DEFINE iContCierre      INTEGER;
DEFINE iContCorte       INTEGER;
DEFINE iContCommit      INTEGER;
DEFINE cIdProc1         CHAR(1);
DEFINE cIdProc2         CHAR(1);
DEFINE cIdProc3         CHAR(1);
DEFINE cIdProc4         CHAR(1);
DEFINE dIntProvFinMes   DECIMAL(18,2);
DEFINE dIvaProvFinMes   DECIMAL(18,2);
DEFINE dIvaIntReal      DECIMAL(18,2);
DEFINE dIvaIntReal_inh  DECIMAL(18,2); --FMV
DEFINE dtFechaMesiversario DATE;
DEFINE cBanTemp         CHAR(1);
DEFINE iNumVdos         INTEGER;
DEFINE iPerTrasp        INTEGER;
DEFINE credcontproc 	char(1);
DEFINE intecontproc 	char(1);
DEFINE CodigoRefProvIva INTEGER;
DEFINE CodigoRefProvInt INTEGER;
DEFINE dIntPeriodo      DECIMAL(18,2);
DEFINE dIvaPeriodo      DECIMAL(18,2);
DEFINE cSQL				CHAR(200);
DEFINE vlCapitalDebe    DECIMAL (14,2);
--FMV 03-SEP-11 --CREDINOMINA
DEFINE iTpDiasFechaPago INTEGER;
--FMV 09-MAY-11
DEFINE dCapTrasVen_Amort DECIMAL(14,2);
--SDFM 11-06-12 -- VENTA PP
DEFINE v_marca_ayuda CHAR(1);
--FMV 24abr13: Indicadores de buro
DEFINE vf_fecha_ult_pago DATE;
DEFINE vdias_atraso      INTEGER;
--FMV 9jul13: Traspaso 90, finalizando plazo
DEFINE vf_fecha_vencim   DATE;
DEFINE vi_dias_trasp_cap INTEGER;
DEFINE vlIntVenBal      DECIMAL (14,2);
DEFINE vlIvaIntVenBal   DECIMAL (14,2);
DEFINE Campotrabajo3 CHAR(10);
-- JOM 11/04/2013 Se cambia traspado a periodos INI
DEFINE dFechacuotamin   DATE;
DEFINE iNumVdosaux      INTEGER;
DEFINE pNumCredIni		CHAR(20);
DEFINE pNumCredFin		CHAR(20);

-- RQM 09 473 TRIAD
DEFINE vSdoTotLiquidar 			decimal(18,2);
DEFINE vPagoMinimo 				decimal(18,2);
DEFINE vSdoTotVencido 			decimal(18,2);

-- JOM 11/04/2013 Se cambia traspado a periodos FIN
--FMJ APoyo 2014
DEFINE wbandera_apoyo 	CHAR(1);
DEFINE iFechaVencto	  	DATE;
DEFINE cNumCteApoyo	  	CHAR(20);
DEFINE cDifApoy			SMALLINT;	
DEFINE cDifApoyoBaja	SMALLINT;	
DEFINE dInteresApoyo	DECIMAL(18,2);
DEFINE dIvaApoyo        DECIMAL(18,2);
DEFINE dIvaApoyoPag1    DECIMAL(18,2);
DEFINE dCapitalApoyo	DECIMAL(18,2);
DEFINE dCountAmort		SMALLINT;
DEFINE sNumPagApoyo		SMALLINT;
DEFINE dCapMntoCutApoy	DECIMAL(18,2);
DEFINE StatusCred_apoyo CHAR (2);
DEFINE dprovint_inh_aux DECIMAL(14,2);
DEFINE vMensaje			CHAR(50);
DEFINE dIvaIntReal_inh_aux DECIMAL(14,2);

DEFINE psaldoInteresApoyo DECIMAL(14,2);
DEFINE psaldoIvaApoyo 	DECIMAL(14,2);
DEFINE dFactor 			DECIMAL(14,2);
DEFINE dPagoInt 		DECIMAL(14,2);
DEFINE dPagoIvaInt 		DECIMAL(14,2);
DEFINE dCapMtoCuotaApoyo DECIMAL(14,2);
DEFINE pInteresactualPagado DECIMAL(14,2);
DEFINE pIvaActualPagado	DECIMAL(14,2);
DEFINE ivaPagadoAnterior DECIMAL(14,2);
DEFINE psaldoInteresTrasApoyo DECIMAL(14,2);

DEFINE apoyo_iva_debe DECIMAL(14,2);
LET apoyo_iva_debe = 0;

LET cBegin           = "N";
LET cFolio         	 = "";
LET cEmpresa         = "";
LET cNumCredito      = "";
LET cStatusCred    	 = "";
LET cStatusCredAnt 	 = "";
LET cStatusCredIndica = "";
LET cNumProducto   	 = "";
LET cDivisa          = "";
LET dtFechaApert     = DATE(1);
LET iDiaCorte        = 0;
LET cSucursal      	 = "";
LET cPlaza         	 = "";
LET dIvaSuc          = 0;
LET cCodTipCred      = "";
LET iDiasCalc        = 0;
LET dtFechaHoy       = DATE(1);
LET dtFechaHoyAux    = DATE(1);
LET dtFechaProx      = DATE(1);
LET dtFechaFinMes    = DATE(1);
--LET dtFechaFinMesAnt    = DATE(1);
LET dtFechaProxCuota = DATE(1);
LET dtFechaVencto    = DATE(1);
LET iDiasInt         = 0;
LET iDiasInt_inh     = 0;

LET dIntDiario       = 0;
LET dIntDiario_inh   = 0;
LET dTasaInter       = 0;
LET dTasaInterMor    = 0;
LET dTasaInterMorCop = 0;
LET dSdoCapital      = 0;
LET dMntVencido      = 0;
LET dMntVencTras     = 0;
LET dCapTrasNoVen    = 0;
LET dSdoCapInso      = 0;
LET dSdoNoExig       = 0;
LET dSdoInt          = 0;
LET dSdoInt_inh      = 0;

LET dSdodiaantint       = 0;
LET dSdomesantint       = 0;
LET dSdomoratorio       = 0;
LET dSdocontabmora      = 0;
LET dMontofinanciado    = 0;
LET dIvaIntVencido      = 0;
LET dIvaIntVigente      = 0;
LET dSdotrab4           = 0;
LET dSdo                = 0;
LET dtFechaCuota        = DATE(1);
LET dtFechaCuotaAnt     = DATE(1);
LET dProvInt       	    = 0;
LET dProvInt_inh  	    = 0;
LET dIvaPag        	    = 0;
LET dtIvaFechaPag       = DATE(1);
LET dCapMtoCuota        = 0;
LET dCapMtoCuota_ori	= 0;
LET iNumPago            = 0;
LET dProvIva       	    = 0;
LET dProvIva_inh  	    = 0;
LET dIntVdo             = 0;
LET dTraspCap           = 0;
LET dTraspInt           = 0;
LET cCapStatusCuota     = "";
LET dSdoMora            = 0;
LET dIntMora            = 0;
LET dIntCope            = 0;
LET iContCierre         = 0;
LET iContCorte          = 0;
LET iContCommit         = 0;
LET cIdProc1            = "";
LET cIdProc2            = "";
LET cIdProc3            = "";
LET cIdProc4            = "";

LET dIntProvFinMes      = 0;
LET dIvaProvFinMes      = 0;
LET dtFechaMesiversario = DATE(1);
LET cBanTemp            = 'N';
LET iNumVdos            = 0;
LET iPerTrasp           = 0;
LET dIntGrav            = 0;
LET dIntExen            = 0;
LET dIntGrav_inh        = 0;
LET dIntExen_inh        = 0;

LET ccodret             ='000';
LET CodigoRefProvIva    = 0;
LET CodigoRefProvInt    = 0;
LET dIntPeriodo         = 0;
LET dIvaPeriodo         = 0;
LET cSQL				= "";
LET vlCapitalDebe       = 0;
-- FMV 09-MAY-11 INICIO DE LA VARIABLE PARA EL CALCULO DE INTERES EN VENCIMIENTO, STATUS 1 DE AMORTIZA
LET dCapTrasVen_Amort = 0;
--FMV 03-SEP-11 --6400
LET iTpDiasFechaPago = 0;
--SDFM 11-06-12 -- VENTA PP
LET v_marca_ayuda = "";
LET vf_fecha_ult_pago = DATE(1);
LET vdias_atraso = 0;
LET vf_fecha_vencim   = DATE(1);
LET vi_dias_trasp_cap = 0;
LET vlIntVenBal      = 0;
LET vlIvaIntVenBal   = 0;
LET Campotrabajo3 = '';
-- JOM 11/04/2013 Se cambia traspado a periodos INI
LET dFechacuotamin = DATE(1);
LET iNumVdosaux    = 0;
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
LET wbandera_apoyo = '';
LET cNumCteApoyo = '';
LET cDifApoy = 0;
LET cDifApoyoBaja = 0;	
LET dInteresApoyo = 0;
LET dIvaApoyo     = 0;
LET dIvaApoyoPag1 = 0;
LET dCapitalApoyo = 0;
LET dCountAmort	  = 0;
LET sNumPagApoyo  = 0;
LET dCapMntoCutApoy	= 0;
LET StatusCred_apoyo = '';
--LET totalApoyo		= 0;
LET psaldoInteresApoyo = 0;
LET psaldoIvaApoyo	= 0;
LET dFactor 		= 0;
LET dPagoInt 		= 0;
LET dPagoIvaInt 	= 0;
LET dCapMtoCuotaApoyo = 0;
LET pInteresactualPagado = 0;
LET pIvaActualPagado	= 0;
LET ivaPagadoAnterior 	= 0;
LET psaldoInteresTrasApoyo	= 0;

LET iFechaVencto = DATE(1);
LET pNumCredIni		='';
LET pNumCredFin		='';


-- RQM 09 473 TRIAD
LET vSdoTotLiquidar 		= 0.0;
LET vPagoMinimo				= 0.0;
LET vSdoTotVencido 			= 0.0;
LET dprovint_inh_aux 		= 0;
LET vMensaje				= '';
LET dIvaIntReal_inh_aux		= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;
---SET PDQPRIORITY 5; HMD-INCIDENCIA-20220224


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cNumCredito ||cErrorInfo;

      IF cBegin = "S" THEN
          ROLLBACK WORK;
       END IF;
/*
      UPDATE "informix".sd_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             cod_ret     = cCodRet,
             mensaje     = cMensajeRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

      UPDATE bdinteg:sx_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             codret      = cCodRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;
*/
	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_pp;
	  END IF;

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;
 
--	SET DEBUG FILE TO '/ifxsif01/Israel/sp_cierre_diario_pp_parte.out';
 	--TRACE ON; 

-- *******************************************************
--  VALIDACIONES DE EJECUCION DE PROCESO                 *
-- *******************************************************
SELECT a.empresa
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = pEmpresa;

IF NVL(cEmpresa,"") = "" THEN
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes,
       USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
           ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
           ||SUBSTR(CURRENT,18,2)
  INTO dtFechaHoy, dtFechaProx, dtFechaFinMes,
       cFolio
  FROM "informix".sd_fechas a
 WHERE a.empresa = cEmpresa; 
 
 --temporal solo para pruebas
--let  dtFechaHoy = today-1;
--let  dtFechaProx = dtFechaHoy+1;
 --temporal solo para pruebas
 
-- *******************************************************
--  INSERTA PARA EJECUCION DE PROCESO                 *
-- *******************************************************
--INI CAS
/*
    SELECT status_proc
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    SELECT status_proc
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
      VALUES ('001','CierrePrest',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;

    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierrePrest',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;

    UPDATE bdinteg:sx_contproc
       SET status_proc='I'
     WHERE fecha= dtFechaHoy
       and proceso ='CierrePrest';

     UPDATE bdicred:sd_contproc
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy
        and proceso ='CierrePrest';
*/
--FIN CAS
SELECT a.cod_tipcred
  INTO cCodTipCred
  FROM "informix".sd_tipcred a
 WHERE a.cod_tipcred  = pCodTipCred
   AND a.empresa      = cEmpresa;

IF NVL(cCodTipCred,"") = "" THEN
     LET cCodRet     = "000002";
     LET cMensajeRet = "El tipo de credito indicado no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.valor
  INTO iDiasCalc
  FROM "informix".sd_param a
 WHERE a.cod_param = "24";

IF iDiasCalc IS NULL THEN
    LET cCodRet     = "000003";
    LET cMensajeRet = "Parametro para los dias de calculo de interes no encontrado";
    RETURN cCodRet, cMensajeRet;
END IF;

-- Dias de interes.
LET iDiasInt = dtFechaProx - dtFechaHoy;

IF NVL(iDiasInt,0) <= 0 THEN
    LET cCodRet     = "000004";
    LET cMensajeRet = "Fechas incorrectas";
    RETURN cCodRet, cMensajeRet;
END IF;

IF pProceso IS NULL OR pProceso = '' THEN
    LET cCodRet     = "000005";
    LET cMensajeRet = "Parametro de proceso invalido";
    RETURN cCodRet, cMensajeRet;
END IF;


SELECT substr(valor,1,12),substr(valor,14,12)
INTO pNumCredIni,pNumCredFin
FROM bdicred:sd_param 
WHERE empresa 	= cEmpresa 
  AND cod_param	= pProceso;

IF pNumCredIni IS NULL OR pNumCredFin IS NULL OR pNumCredIni = '' OR pNumCredFin = '' THEN
    LET cCodRet     = "000006";
    LET cMensajeRet = "Sin cuentas a procesar";
    RETURN cCodRet, cMensajeRet;
END IF;
  
SELECT a.empresa, a.sucursal, a.iva, a.plaza
  FROM bdinteg:si_sucursales a
 WHERE a.tpo_sucursal = "S"
  INTO TEMP tmp_sucursales_pp;
CREATE INDEX indx_sucursal_pp ON tmp_sucursales_pp (empresa, sucursal);

LET cBanTemp = 'S';

--CALL "informix".monthadd(dtFechaFinMes,-1) RETURNING dtFechaFinMesAnt;
--LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);
CALL "informix".sp_valfechabil(dtFechaHoy+1,'+') RETURNING cCodRet, dtFechaHoyAux;
/*
---- PROCESO DE CANCELCION Y REPRESTAMO DE DIGITAL
IF dtFechaHoy >= MDY (09,01,2020) AND dtFechaHoy < MDY (10,01,2020) THEN

	FOREACH WITH HOLD
        SELECT a.num_credito         , c.prox_fecha_pago  ,  a.numcte
          INTO cNumCredito          , dtFechaMesiversario ,  cNumCteApoyo
          FROM sd_programa_apoyo2020crd apoyo, sd_maecredcrd a, sd_maecredanexocrd c, sd_definicion d
         WHERE apoyo.num_credito = a.num_credito 
           AND c.num_credito   = a.num_credito
           AND c.empresa       = a.empresa
           AND d.num_producto  = a.num_producto
           AND d.empresa       = c.empresa
           AND a.empresa       = cEmpresa
           AND a.status_cred   NOT IN ("FF","FM","CC","FC","CV","FI")
           AND c.fecha_proceso = dtFechaHoy
           AND d.cod_tipcred   = cCodTipCred
		   AND apoyo.bandera   = 'A'
		   AND a.num_producto  = '6800'
		   AND c.prox_fecha_pago = dtFechaHoy
           AND a.num_credito >=  pNumCredIni
           AND a.num_credito <  pNumCredFin
			
				CALL sp_diferir_cancela_credito(cNumCteApoyo,cNumCredito,2,20) 
					RETURNING cCodRet,vMensaje;

				EXECUTE PROCEDURE "informix".sp_prestamoflex_sms_apoyo(2,cNumCteApoyo,0)
					INTO cCodRet;

--	END FOREACH;
END IF;
*/

-- *******************************************************
--  SELECCION DE CREDITOS PARA PROCESAR                  *
-- *******************************************************
FOREACH WITH HOLD
        SELECT a.num_credito         , a.status_cred       , a.num_producto     , a.sucursal         , a.divisa           ,
               a.fecha_apertura      , a.tasa_interes      , a.tasa_moratorios  , b.sdo_capital      , b.monto_vencido    ,
               b.mto_venc_trasp      , b.cap_tras_no_venci , b.sdo_cap_insoluto , b.sdo_no_exig      , b.sdo_intereses    ,
               c.dia_corte           , b.int_tra_no_exig   , c.fecha_vencto     , c.prox_fecha_pago  , b.provision_normal ,
               b.sdo_global_int      , d.period_pago_cap   , b.sdo_dia_ant_int  , b.sdo_mes_ant_int  , b.sdo_moratorio    ,
               b.sdo_contab_mora     , b.monto_financiado  , b.mto_venc_int     , b.mto_finan_vdo    , b.sdo_trab4        ,
	           nvl(c.tp_dias_fecha_pago,0) , a.id_origen   , c.fecha_ult_pago   , a.fecha_vencim     , a.dias_trasp_cap   ,
               a.campo_trab3		 , a.numcte

          INTO cNumCredito          , cStatusCred         , cNumProducto       , cSucursal           , cDivisa            ,
               dtFechaApert         , dTasaInter          , dTasaInterMor      , dSdoCapital         , dMntVencido        ,
               dMntVencTras         , dCapTrasNoVen       , dSdoCapInso        , dSdoNoExig          , dSdoInt            ,
               iDiaCorte            , dIntVdo             , dtFechaVencto      , dtFechaMesiversario , dIntProvFinMes     ,
               dIvaProvFinMes       , iPerTrasp           , dSdodiaantint      , dSdomesantint       , dSdomoratorio      ,
               dSdocontabmora       , dMontofinanciado    , dIvaIntVencido     , dIvaIntVigente      , dSdotrab4          ,
               iTpDiasFechaPago     , v_marca_ayuda       , vf_fecha_ult_pago  , vf_fecha_vencim     , vi_dias_trasp_cap  ,
               Campotrabajo3		, cNumCteApoyo
          FROM sd_maecredcrd a, sd_maesdoscrd b, sd_maecredanexocrd c, sd_definicion d
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa
           AND c.num_credito   = a.num_credito
           AND c.empresa       = a.empresa
           AND d.num_producto  = a.num_producto
           AND d.empresa       = c.empresa
           AND a.empresa       = cEmpresa
           AND a.status_cred   NOT IN ("FF","FM","CC","FC","CV","FI")
           AND c.fecha_proceso = dtFechaHoy
           AND d.cod_tipcred   = cCodTipCred
           AND a.num_credito >=  pNumCredIni
           AND a.num_credito <  pNumCredFin	
		
--let cMensajeRet = pNumCredIni||'-'||pNumCredFin;
		   
--RETURN cCodRet, cMensajeRet;

		   
 --          IF cBegin = "N" AND iContCommit=0 THEN
               BEGIN WORK;
               LET cBegin = "S";
--           END IF;

            LET cStatusCredAnt     = cStatusCred;
            LET cStatusCredIndica  = cStatusCred;
            LET cIdProc1          = "";	 LET cIdProc2          = "";
            LET cIdProc3          = "";	 LET cIdProc4          = "";
            LET dIvaIntReal       = 0;	 LET dIvaIntReal_inh   = 0;
            LET dProvIva          = 0;	 LET dProvInt          = 0;
            LET dProvIva_inh      = 0;	 LET dProvInt_inh      = 0;
            LET dCapMtoCuota      = 0;	 LET dSdoInt_inh       = 0;
            LET dIntGrav_inh      = 0;	 LET dIntExen_inh      = 0;
            LET iDiasInt_inh      = 0;	 LET dIntDiario_inh    = 0;
			LET iContCommit		  = 0;
			LET StatusCred_apoyo  = '';
			LET vMensaje		  		= '';
			LET dprovint_inh_aux 		= 0;
			LET dIvaIntReal_inh_aux		= 0;
			LET psaldoInteresApoyo		= 0;
			LET psaldoIvaApoyo			= 0;
			LET dPagoInt				= 0;
			LET	dPagoIvaInt				= 0;
			LET pInteresactualPagado 	= 0;
			LET pIvaActualPagado		= 0;
			LET ivaPagadoAnterior 	= 0;
			LET dFactor				= 0;
			LET dCapMtoCuotaApoyo	= 0;
			LET apoyo_iva_debe		= 0;

	--		IF  cNumProducto in ('6300','7600','7700','6800') THEN
				------Programa Apoyo
				SELECT bandera INTO wbandera_apoyo
				  FROM sd_programa_apoyo2021crd
				 WHERE num_credito = cNumCredito;

				IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;
				/*		--- se apaga inscripcion al programa de apoyo 01/08/2020 ITD
				IF wbandera_apoyo = '' THEN
					-- Consulta si el credito tenia status vigente a fin de febrero
					SELECT status_cred INTO StatusCred_apoyo FROM bdicred:sd_maecredcontcrd 
					 WHERE num_credito = cNumCredito AND fecha = mdy('03','31','2020');
					 
					 IF StatusCred_apoyo IS NULL THEN
						LET StatusCred_apoyo = '';	
					 END IF;
				
					IF cNumProducto = '6800' AND StatusCred_apoyo = '' THEN
						SELECT count(*) INTO iContCommit
					      FROM bdicred:sd_maecredcrd a, bdicred:sd_linea_prestamo b
						 WHERE a.num_credito = b.num_credito
						   AND a.num_credito = cNumCredito
					  	   AND b.fecha_otorga <= mdy('03','31','2020')
						   AND fecha_cancela IS NULL;
			   
					END IF;

					IF iContCommit > 0 OR StatusCred_apoyo = 'AA' THEN		-- Si termino feb con AA
						-- Consulta tabla origen de programa apoyo: Registro de diferimiento por parte del cliente
						SELECT canal,canal_baja INTO cDifApoy ,cDifApoyoBaja FROM bdicred:sd_diferir
						 WHERE numcte = cNumCteApoyo;
						 
						 IF cDifApoy IS NULL THEN
							LET cDifApoy = 0;
						 END IF;

						-- Solo inserte cuando sea mesiversario. Para casos q estan registrado en sd_diferir y no en sd_programa_apoyo2020crd. Solo entra si se encuentra en vigente: AA
						IF (cDifApoy > 0 AND cDifApoyoBaja IS NULL) OR 
							(cDifApoyoBaja IS NULL AND dMontofinanciado > 0 ) AND (dtFechaHoy = dtFechaMesiversario) AND cStatusCred = 'AA' THEN   
						
							INSERT INTO bdicred:"informix".sd_programa_apoyo2020crd VALUES (cNumCredito,dtFechaHoy,"A",date(1));
							UPDATE bdicred:"informix".sd_maecredcrd SET campo_trab3 = "BAJA" WHERE num_credito = cNumCredito;
							LET wbandera_apoyo = 'A';
							LET Campotrabajo3 = 'BAJA';
							
						END IF;
					END IF;
				END IF; */
	--		END IF;
			  		
-- Venta de Cartera de PP
		IF (v_marca_ayuda = '1' OR cStatusCred = 'CV' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN
		
			  -- Identificar  (Cierre de Mes).
			 IF dtFechaHoy = dtFechaFinMes THEN
			    LET cIdProc1 = "C";
			 END IF;
			 -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
			 IF dtFechaHoyAux = dtFechaMesiversario THEN
				LET cIdProc2 = "F";
			 END IF;
			 -- Identificar un (Mesiversario)
			 IF dtFechaHoy = dtFechaMesiversario THEN
				 LET cIdProc3 = "M";
			 END IF;
             --FMV 7mar13: Valida registros de la Provision a fin de mes, para PP Factu dia 1o. de mes
             IF cIdProc1 = "C" AND cIdProc2 = "F" THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;


            IF ( v_marca_ayuda = '1' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN
			
				IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN			
					---- respaldo antes de alguna modificacion
					 INSERT INTO "informix".sd_maecredcrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maecredcrd
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				   
					 INSERT INTO "informix".sd_maesdoscrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maesdoscrd
					 WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				  
					 INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_apoyo2021
					 SELECT dtFechaHoy, * FROM bdicred:"informix".sd_amortiza_creditocrd
					  WHERE num_credito = cNumCredito AND empresa = pEmpresa;					  
					  
					 INSERT INTO "informix".sd_maecredanexocrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maecredanexocrd
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					  
					-- respaldo para la sd_linea_prestamo
					 INSERT INTO "informix".sd_linea_prestamo_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_linea_prestamo
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				END IF;
			
               SELECT COUNT(*)
                 INTO iNumVdos
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status IN ("2","7");

                  IF (iNumVdos = 0) THEN
                      UPDATE "informix".sd_maecredanexocrd
                         SET fecha_vencto  = NULL
                       WHERE num_credito    = cNumCredito
                         AND empresa        = cEmpresa;
				  END IF;

               UPDATE sd_maesdoscrd
                  SET mto_fin_ven_trasp = iNumVdos
                WHERE empresa = cEmpresa
                  AND num_credito = cNumCredito;


               UPDATE "informix".sd_maecredanexocrd
                  SET fecha_proceso  = dtFechaProx
                WHERE num_credito    = cNumCredito
                  AND empresa        = cEmpresa;


               IF cIdProc1 = "C" or day(dtFechaHoy)=20 THEN
                  INSERT INTO "informix".sd_maesdoscontcrd
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maesdoscrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;

                  INSERT INTO "informix".sd_maecredcontcrd
                       SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,
								cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,
								tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,
								valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,
								credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
                         FROM informix.sd_maecredcrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;
               IF ( cIdProc3 = "M" ) THEN
                      call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                          RETURNING cCodRet, dtFechaProxCuota;

                      UPDATE "informix".sd_maecredanexocrd
                         SET prox_fecha_pago = dtFechaProxCuota
                       WHERE num_credito     = cNumCredito
                         AND empresa         = cEmpresa;
                  END IF;

                  IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                     INSERT INTO "informix".sd_maesdoshistcrd
                           SELECT dtFechaHoy, *
                             FROM informix.sd_maesdoscrd
                            WHERE num_credito = cNumCredito
                              AND empresa     = cEmpresa;
                  END IF;
			   IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN
		
					if  cIdProc3 = "M" then
						update bdicred:"informix".sd_amortiza_creditocrd
							set fecha_cuota = monthadd(fecha_cuota,1)
						where capital_status in (3,7,1)
							AND num_credito = cNumCredito
							AND empresa = pEmpresa;
					end if;
			   END IF;
			END IF;
			   --calculo de los int diarios para programa apoyo sea sobre deuda total. No existe amortiza con status 1 (se pasa a 3)
               --LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
		--	   LET dIntDiario = (((dSdoCapital + dCapTrasNoVen) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
		--	   
		--	   LET dSdodiaantint = dSdoInt;
		--	   LET dSdoInt  = dSdoInt + dIntDiario;
						  
			   --------------------------
			   -- Calcula PROVISION
/*
				----- provision de 1 dia cuando es fin de mes
				IF cIdProc1 = "C"  and (dSdoCapital + dCapTrasNoVen) > 0 THEN
				
					SELECT a.iva, a.plaza
						INTO dIvaSuc, cPlaza
					FROM tmp_sucursales_pp a
						WHERE empresa  = cEmpresa
						AND sucursal = cSucursal;
				
					SELECT a.fecha_cuota, --  a.iva_pagado,
							a.iva_fecha_pago,
							NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
						INTO dtFechaCuota,-- dIvaPag,
							dtIvaFechaPag,
							dCapMtoCuota,iNumPago
					FROM "informix".sd_amortiza_creditocrd a
					WHERE a.empresa        = cEmpresa
						AND a.num_credito    = cNumCredito
						AND a.capital_status = "3";

					LET dProvInt = dSdoInt;

					CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
													dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt)
						RETURNING cCodRet,dIvaIntReal,cMensajeRet;

					IF cCodRet <> "000000" THEN
						LET cCodRet      = "000005";
						LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN cCodRet,cMensajeRet;
					END IF;

					IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
					IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

					LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;
					LET CodigoRefProvIva    = 7;
					LET CodigoRefProvInt    = 6;


					IF dProvInt > 0 THEN  
						IF cIdProc4 = '' THEN
							LET dProvInt = dProvInt - dIntProvFinMes;
						ELSE
							LET dProvInt = dProvInt  - dProvInt_inh;	
						END IF;
					END IF;
					
					IF dProvInt > 0 THEN    

						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
						"606", dtFechaHoy ,dProvInt, cFolio,
						cSucursal, cDivisa, "0000",'PROV','')
						RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							LET cCodRet      = cCodRet;
							LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
							IF cBegin = "S" THEN
								ROLLBACK WORK;
							END IF;
							RETURN cCodRet,cMensajeRet;
						END IF;

						IF cIdProc4 = '' THEN
							LET dProvIva = dProvIva - dIvaProvFinMes;
						ELSE
							LET dProvIva = dProvIva - dProvIva_inh;
						END IF;

						IF dProvIva > 0 THEN
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
										"606", dtFechaHoy , dProvIva, cFolio,cSucursal, cDivisa, "0000",'PROV','')
								RETURNING cCodRet,cMensajeRet;
							IF (cCodRet <> "000000") THEN
								LET cCodRet      = "000007";
								LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
								IF cBegin = "S" THEN
									ROLLBACK WORK;
								END IF;
								RETURN cCodRet,cMensajeRet;
							END IF;
						END IF;

					END IF;
					
					IF cNumProducto <> '6900' THEN
						IF dProvInt>0 and dProvIva<=0 then
							LET dIntGrav = dProvInt;
							LET dIntExen = 0;
						ELSE
							LET dIntGrav = dProvIva/dIvaSuc;
							IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
							LET dIntExen = dProvInt-dIntGrav;
						END IF;

						IF dIntGrav>0 THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
												  "606",  dtFechaHoy  , dIntGrav, cFolio,
												  cSucursal, cDivisa, "0000",'GRAV','')
								RETURNING cCodRet,cMensajeRet;
								IF (cCodRet <> "000000") THEN
									   LET cCodRet      = "000007";
									   LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
									   IF cBegin = "S" THEN
										  ROLLBACK WORK;
									   END IF;
									   RETURN cCodRet,cMensajeRet;
								END IF;
						END IF;
						IF dIntExen>0 THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
												  "606", dtFechaHoy, dIntExen, cFolio,
												  cSucursal, cDivisa, "0000",'EXEN','')
								RETURNING cCodRet,cMensajeRet;
								IF (cCodRet <> "000000") THEN
									   LET cCodRet      = "000007";
									   LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
									   IF cBegin = "S" THEN
										  ROLLBACK WORK;
									   END IF;
									   RETURN cCodRet,cMensajeRet;
								END IF;
						END IF;
					END IF;
	
				END IF;
				
			   -- Fin Calcula provision					   
			   --------------------------
		
		
				 if  cIdProc3 = "M" then
					select nvl((interes_debe - interes_pagado),0), nvl((iva_debe - iva_pagado),0), nvl(iva_pagado,0), NVL((capital_debe - capital_pagado),0), nvl(num_pago,0)
					  into dInteresApoyo					     , dIvaApoyo					 , dIvaApoyoPag1    , dCapitalApoyo							, sNumPagApoyo
		              from bdicred:sd_amortiza_creditocrd 
		             where empresa = cEmpresa 
			           and num_credito = cNumCredito 
			           and capital_status = '1';	

						IF dInteresApoyo IS NULL THEN
							LET dInteresApoyo = 0;
							LET dIvaApoyo = 0;
							LET dIvaApoyoPag1 = 0;
							LET dCapitalApoyo = 0;
							LET sNumPagApoyo = 0;
							LET dCapMntoCutApoy = 0;
						END IF;
				 
				    update bdicred:"informix".sd_amortiza_creditocrd
				       set capital_status = '5'
				     where capital_status = '1'
				       and num_credito = cNumCredito
                       and empresa = pEmpresa;
				 
				    update bdicred:"informix".sd_amortiza_creditocrd
					   set interes_debe = interes_debe + dInteresApoyo, 
						   iva_debe = iva_debe + dIvaApoyoPag1, iva_pagado = iva_pagado + dIvaApoyoPag1, iva_fecha_pago = dtFechaHoy 	
						   -- fecha de ultimo pago de iva para provision
					 where capital_status in ('3')
				       and num_credito = cNumCredito
                       and empresa = pEmpresa;
					LET dCountAmort = dbinfo("sqlca.sqlerrd2");
					IF dCountAmort = 0 AND dCapitalApoyo > 0 THEN 			-- Es decir, no existe un registro 3 por ser ultima, generale nueva por apoyo

						select nvl(capital_mto_cuota,0)
						  into dCapMntoCutApoy
						  from bdicred:sd_amortiza_creditocrd 
						 where empresa = cEmpresa 
						   and num_credito = cNumCredito 
						   and num_pago = 1;
					
						INSERT INTO "informix".sd_amortiza_creditocrd
								(
									empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
									capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
									capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
									interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
									iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
									mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
									mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
									mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
									num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
									campo_trabajo4
								)
							VALUES
								(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
									dCapMntoCutApoy,       0,				0,			        "3",
									"3",         		"",				dInteresApoyo,       0,
									"1",                "1",			NULL,			     dIvaApoyoPag1,
									0,			        "1",			"1",                 "",
									0,			         0,				0,			         0,
									0,			         0,				0,			         "1",
									0,			          0,			"1",			     "",
							(sNumPagApoyo +1),		      0,			0,			         "",
									""
								);
					END IF;
				  
					   
					UPDATE bdicred:"informix".sd_maesdoscrd
				       SET sdo_intereses = sdo_intereses  + dInteresApoyo, provision_normal = provision_normal + dInteresApoyo, 
					       sdo_global_int = sdo_global_int + dIvaApoyo
			         WHERE empresa = cEmpresa
				       AND num_credito = cNumCredito;
  
				 end if;
				 END IF;
*/				 
			   IF cIdProc1 ='C' THEN
			     SELECT min(fecha_cuota) INTO  iFechaVencto
				   FROM "informix".sd_amortiza_creditocrd a
				  WHERE a.empresa        = cEmpresa
					AND a.num_credito    = cNumCredito
					AND a.capital_status IN ("2","7");						  
				 IF iFechaVencto IS NULL THEN  LET vdias_atraso= 0; 
				 ELIF cStatusCred ='AA' THEN LET vdias_atraso= 0;
				 ELSE
			       LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);                   
			     END IF;
				 UPDATE "informix".sd_indicador_cred_crd
                      SET dias_atraso   = NVL(vdias_atraso,0)  
                   WHERE empresa = pEmpresa
                     AND num_credito = cNumCredito;
			   END IF;
			   /*
			   --------------------------
			   -- Calcula Intereses para PROGRAMA APOYO 2020
			   SELECT sum(capital_debe - capital_pagado) INTO dCapTrasVen_Amort
				 FROM sd_amortiza_creditocrd
				WHERE empresa = cEmpresa
				  AND num_credito = cNumCredito
				  AND capital_status = '1';
			   IF dCapTrasVen_Amort IS NULL THEN	LET dCapTrasVen_Amort = 0; 	END IF;
			   
			   --Actualizacion de los int diarios en sd_amortiza_creditocrd
               UPDATE "informix".sd_amortiza_creditocrd
                  SET interes_debe = interes_debe + dIntDiario
                WHERE empresa        = cEmpresa		
                  AND num_credito    = cNumCredito
                  AND capital_status = "3";
					 
			   --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;					 
               UPDATE sd_maesdoscrd
				  SET fecha_ult_mov = dtFechaHoy,
					sdo_intereses = sdo_intereses + dSdoInt,
					sdo_dia_ant_int = dSdodiaantint,
					sdo_mes_ant_int = dSdomesantint,
					sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
--					sdo_no_exig = dSdoNoExig,
					sdo_no_exig = 0,
					mto_finan_vdo = 0,
					provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE provision_normal END),
					dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END),
					sdo_dia_ant_cap = sdo_cap_insoluto,
					sdo_capital = dSdoCapital,
					sdo_cap_insoluto = dSdoCapInso,
					dias_acum_cap = (dias_acum_cap + iDiasInt),
					monto_vencido = dMntVencido,
					mto_venc_trasp = dMntVencTras,
					-- monto_financiado = dMontofinanciado,
					monto_financiado = 0,					
					sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE sdo_global_int END),
					cap_tras_no_venci = dCapTrasNoVen,
					mto_venc_int = dIvaIntVencido,
					int_tra_no_exig = dIntVdo,
					sdo_trab4 = dSdotrab4,
					mto_fin_ven_trasp = iNumVdos
				WHERE empresa = cEmpresa
				  AND num_credito = cNumCredito;

			END IF;
			
			
			  select sum(interes_debe - interes_pagado) vencido_balanza,
					   sum(iva_debe - iva_pagado) iva_vencido_balanza
				  into vlIntVenBal, vlIvaIntVenBal
				  from bdicred:sd_amortiza_creditocrd 
				 where empresa = cEmpresa 
				   and num_credito = cNumCredito 
				   and capital_status = '2'
				   and campo_trabajo3 <> 'V';
			
				if  vlIntVenBal is null then
				   let vlIntVenBal = 0;
				   let vlIvaIntVenBal = 0;
				end if;

				LET dSdoNoExig = 0;
				LET dMontofinanciado = 0;
				
				SELECT provision_normal,sdo_global_int
					INTO dSdoInt,dProvIva
				FROM bdicred:sd_maesdoscrd 
				WHERE num_credito = cNumCredito;

				 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									--	(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									--		  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									--		  ELSE (dSdoNoExig + dIntProvFinMes)  END)
											  dSdoInt, dIntVdo,
									--	(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
									--		  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									--		  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
											  dProvIva,
										dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
				RETURNING cCodRet;
				*/
				
            select sum(interes_debe - interes_pagado) vencido_balanza,
                   sum(iva_debe - iva_pagado) iva_vencido_balanza
              into vlIntVenBal, vlIvaIntVenBal
              from bdicred:sd_amortiza_creditocrd 
             where empresa = cEmpresa 
               and num_credito = cNumCredito 
               and capital_status = '2'
               and campo_trabajo3 <> 'V';
        
            if  vlIntVenBal is null then
               let vlIntVenBal = 0;
               let vlIvaIntVenBal = 0;
            end if;

			 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
		  	RETURNING cCodRet;

				IF (cCodRet <> "000") THEN
					 LET cCodRet     = "000002";
					 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
					 RETURN cCodRet, cMensajeRet;
				END IF;
			
            COMMIT WORK;
            CONTINUE FOREACH;
		END IF;
-- Venta de cartera de PP
-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
           --Se obtiene el saldo para calcular los int diarios.
  --FMV 09-may-11  Calcula el int sobre el sdo capital sin el monto de traspaso ya calculado en la facturacion
  
            SELECT sum(capital_debe - capital_pagado)
               INTO dCapTrasVen_Amort
              FROM sd_amortiza_creditocrd
             WHERE empresa = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status = '1';

               IF dCapTrasVen_Amort IS NULL
                 THEN
                    LET dCapTrasVen_Amort = 0;
               END IF; 
			   /*
			   IF wbandera_apoyo = 'A' THEN		--Programa apoyo 2020
					LET dCapTrasVen_Amort = 0;
			   END IF;
				*/
			   --calculo de los int diarios
			   LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;

             IF dtFechaHoy = dtFechaFinMes AND dtFechaHoyAux = dtFechaMesiversario THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;

            IF cIdProc4 = "P"  THEN
               LET dIntDiario_inh = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt_inh;
               LET dSdoInt_inh  = dSdoInt_inh + dSdoInt + dIntDiario_inh;
            END IF;

                  --Actualizacion de los int diarios en maestro de saldos (sd_maesdoscrd)
                  LET dSdodiaantint = dSdoInt;
                  LET dSdoInt       = dSdoInt + dIntDiario;
                  --Actualizacion de los int diarios en sd_amortiza_creditocrd
                  UPDATE "informix".sd_amortiza_creditocrd
                     SET interes_debe = interes_debe + dIntDiario
                   WHERE empresa        = cEmpresa
                     AND num_credito    = cNumCredito
                     AND capital_status = "3";

                  --Se actualiza la fecha del proximo proceso
                  UPDATE "informix".sd_maecredanexocrd
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;

-- *******************************************************
--  IDENTIFICACION DE PROCESOS POR REALIZAR              *
-- *******************************************************
          -- Validacion para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN
            LET cIdProc1 = "C";
          END IF;
          -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
          IF dtFechaHoyAux = dtFechaMesiversario THEN
                LET cIdProc2 = "F";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
 SELECT a.iva, a.plaza
   INTO dIvaSuc, cPlaza
   FROM tmp_sucursales_pp a
  WHERE empresa  = cEmpresa
    AND sucursal = cSucursal;
--********************************************************************
-- PROVISION ESPECIAL PARA PRESTAMOS CON MESIVERSARIO DIA 1o. DE MES
--********************************************************************
IF cIdProc1 = "C" AND cIdProc4 = "P" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota,
                --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt_inh = dSdoInt_inh;
 
 
	IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
	IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;
 
--	LET dIntProvFinMes = dIntProvFinMes;
	LET dsdoint = dsdoint;
 
/* 	IF wbandera_apoyo = 'A' THEN
		LET dprovint_inh_aux = dProvInt_inh- dIntProvFinMes;
			---- se ejecuta con variable nueva dprovint_inh_aux  -- ITD
		  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
										  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dprovint_inh_aux)
		  RETURNING cCodRet,dIvaIntReal_inh_aux,cMensajeRet;
	--	 LET dProvInt_inh = dSdoInt_inh;
	END IF; */
	
			---- llamado original con dSdoInt_inh calcula el IVA sobre el Interes acomulado-- ITD
		  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
										  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt_inh)
		  RETURNING cCodRet,dIvaIntReal_inh,cMensajeRet;



  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

 --              IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
 --              IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva_inh = dIvaIntReal_inh; -- dIvaProvFinMes;

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   
            LET CodigoRefProvInt    = 8;   
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        IF dProvInt_inh > 0 THEN              
                LET dProvInt = dProvInt - dIntProvFinMes;
				
	/*			IF wbandera_apoyo = 'A' THEN
				
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
											  "606",  dtFechaHoy , dprovint_inh_aux, cFolio,
											  cSucursal, cDivisa, "0000",'PROV','')
					RETURNING cCodRet,cMensajeRet;
					
				ELSE */
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
											  "606",  dtFechaHoy , dProvInt_inh, cFolio,
											  cSucursal, cDivisa, "0000",'PROV','')
					RETURNING cCodRet,cMensajeRet;
	--			END IF;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;

            --LET dProvIva_inh = dProvIva_inh - dIvaProvFinMes; FMV 19mar13 NO SE DESCUENTA PROVISION FIN DE MES y PROVISIONA IVA
                IF dProvIva_inh > 0 THEN
			/*		IF wbandera_apoyo = 'A' THEN
					
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dIvaIntReal_inh_aux, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
					ELSE		*/
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva_inh, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
			--		END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt_inh>0 and dProvIva_inh<=0 then
                    LET dIntGrav_inh = dProvInt_inh;
                    LET dIntExen_inh = 0;
                ELSE
                    LET dIntGrav_inh = dProvIva_inh/dIvaSuc;
                    IF dIntGrav_inh>dProvInt_inh THEN LET dIntGrav_inh=dProvInt_inh; END IF;
                    LET dIntExen_inh = dProvInt_inh-dIntGrav_inh;
                END IF;

                IF dIntGrav_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
                                           then dtFechaHoy end, dIntGrav_inh, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
                IF dIntExen_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
                                           then dtFechaHoy end, dIntExen_inh, cFolio,
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;
END IF;
--*************************************************************************
--   FIN DE PROVISION POR REGISTROS DE MOVTO EN FIN MES
--*************************************************************************
-- *******************************************************
--  PROVISION                                            *
-- *******************************************************
IF cIdProc1 = "C" OR cIdProc2 = "F" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota, --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
             INTO dtFechaCuota,-- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt = dSdoInt;

  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
                                  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt)
  RETURNING cCodRet,dIvaIntReal,cMensajeRet;

  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   --FMV 6ene11: Se cambian codigos 8 x 9 para Vencido
            LET CodigoRefProvInt    = 8;   --FMV 6ene11: Se cambian codigos 9 x 8 para Vencido
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        IF dProvInt > 0 THEN  
                IF cIdProc4 = '' THEN
                   LET dProvInt = dProvInt - dIntProvFinMes;
                ELSE
                   --LET dProvInt = dProvInt - dIntProvFinMes - dProvInt_inh;
				   LET dProvInt = dProvInt  - dProvInt_inh;	
                END IF;
		END IF;
        IF dProvInt > 0 THEN    

				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
				                          "606", dtFechaHoy ,dProvInt, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;
                              
                IF cIdProc4 = '' THEN
                   LET dProvIva = dProvIva - dIvaProvFinMes;
                ELSE
                   --LET dProvIva = dProvIva - dIvaProvFinMes - dProvIva_inh;
                   LET dProvIva = dProvIva - dProvIva_inh;
                END IF;
  
                IF dProvIva > 0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt>0 and dProvIva<=0 then
                    LET dIntGrav = dProvInt;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIva/dIvaSuc;
                    IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
                    LET dIntExen = dProvInt-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606",  dtFechaHoy  , dIntGrav, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
                IF dIntExen>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", dtFechaHoy, dIntExen, cFolio,
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de int gravable y exento
        END IF;
END IF;

-- *******************************************************
-- FACTURACION                                           *
-- *******************************************************

--FMV 31-ENE-11
IF cIdProc2 = "F" THEN

		--- se obtienen los  montos de INT e IVA de la maeretenido del programa de apoyo
		SELECT monto
			INTO psaldoInteresApoyo
		FROM bdicred:sd_maeretenido 
		WHERE num_credito = cNumCredito
			AND transacc = '8374'
			AND estatus = 'R';

			IF psaldoInteresApoyo IS NULL THEN
				LET psaldoInteresApoyo = 0;
			END IF;

		SELECT monto
			INTO psaldoIvaApoyo
		FROM bdicred:sd_maeretenido 
		WHERE num_credito = cNumCredito
			AND transacc ='8375'
			AND estatus = 'R';

		IF psaldoIvaApoyo IS NULL THEN
			LET psaldoIvaApoyo = 0;
		END IF;
		
		
		IF  (dSdoCapital + dCapTrasNoVen) <= 0 AND (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
			SELECT a.fecha_cuota, --  a.iva_pagado,
				a.iva_fecha_pago,
				NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
			INTO dtFechaCuota,-- dIvaPag,
				dtIvaFechaPag,
				dCapMtoCuota,iNumPago
			FROM "informix".sd_amortiza_creditocrd a
			WHERE a.empresa        = cEmpresa
				AND a.num_credito    = cNumCredito
				AND a.capital_status = "3";

			IF dtFechaCuota IS NOT NULL THEN
				LET dtFechaCuotaAnt = dtFechaCuota;
			END IF;
		END IF;
			
			
END IF;
/*
IF cIdProc2 = "F" AND wbandera_apoyo = 'A' AND dtFechaHoy >= MDY (09,30,2020) AND dtFechaHoy < MDY (11,01,2020)  THEN 

	CALL sp_diferir_cancela_credito(cNumCteApoyo,cNumCredito,2,20) 
					RETURNING cCodRet,vMensaje;
					
				UPDATE bdicred:sd_programa_apoyo2020crd 
				SET bandera = 'B',fecha_inactivacion = CURRENT 
				WHERE num_credito = cNumCredito;
				
				UPDATE bdicred:sd_maecredcrd 
					SET campo_trab3 = ''
				WHERE num_credito = cNumCredito;		

				---- Tiene el saldo total de intereses identificando si realizo algun pago
				select nvl((interes_debe - interes_pagado),0),
					nvl((iva_debe - iva_pagado),0), iva_pagado
					into  psaldoInteresApoyo,
						  psaldoIvaApoyo, ivaPagadoAnterior
				from bdicred:sd_amortiza_creditocrd 
				where empresa = cEmpresa 
					and num_credito = cNumCredito 
					and fecha_cuota = ADD_MONTHS (dtFechaCuota, -1);

				IF psaldoInteresApoyo IS NULL THEN
					LET psaldoInteresApoyo = 0;
					LET psaldoIvaApoyo = 0;
					LET ivaPagadoAnterior = 0;
				END IF;
				
				select interes_pagado, iva_pagado, iva_debe
					into  pInteresactualPagado,pIvaActualPagado, apoyo_iva_debe
				from bdicred:sd_amortiza_creditocrd 
				where empresa = cEmpresa 
					and num_credito = cNumCredito 
					and capital_status = '3';
					
				IF pInteresactualPagado IS NULL THEN
					LET pInteresactualPagado = 0;
					LET pIvaActualPagado = 0;
					LET apoyo_iva_debe = 0;
				END IF;
				
				LET psaldoInteresApoyo = psaldoInteresApoyo - pInteresactualPagado;
				---	SI EL IVA DE APOYO ES MAYOR A CERO, SE DESCUENTA SI REALIZO PAGOS
				IF psaldoIvaApoyo > 0 THEN
						LET psaldoIvaApoyo = psaldoIvaApoyo - (pIvaActualPagado - ivaPagadoAnterior);
				END IF;

				IF psaldoIvaApoyo < 0 THEN
					LET psaldoIvaApoyo = 0;
				END IF;
				
				IF psaldoInteresApoyo < 0 THEN
					LET psaldoInteresApoyo = 0;
				END IF;
			
				IF psaldoInteresApoyo > 0 THEN
						
					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',cNumCredito,cFolio,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'8374',0,psaldoInteresApoyo,user,'R','INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);

					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',cNumCredito,cFolio,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'8375',0,psaldoIvaApoyo,user,'R','IVA INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);						
							
					UPDATE bdicred:sd_amortiza_creditocrd 
					SET interes_debe = interes_debe - psaldoInteresApoyo,
						iva_debe = iva_debe - psaldoIvaApoyo
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito 
						and capital_status = '3';	
						
					UPDATE bdicred:sd_maesdoscrd 
					SET provision_normal = provision_normal - psaldoInteresApoyo,
						sdo_global_int = sdo_global_int - psaldoIvaApoyo,
						sdo_retenido = sdo_retenido + psaldoInteresApoyo + psaldoIvaApoyo
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
				END IF;
				
				
			LET dIvaIntVigente = dIvaIntVigente;
			LET dIvaIntVigente = dIvaIntVigente - psaldoIvaApoyo;

	
END IF;
*/
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen + psaldoInteresApoyo + psaldoIvaApoyo ) > 0 THEN

		LET iNumPago = iNumPago + 1 ;
        
      select nvl((interes_debe - interes_pagado),0),
				nvl((iva_debe - iva_pagado),0) + nvl(dIvaIntReal,0)
		  into  vlIntVenBal, vlIvaIntVenBal
		  from bdicred:sd_amortiza_creditocrd 
		  where empresa = cEmpresa 
			and num_credito = cNumCredito 
			and capital_status = '3';	 
			
			
			LET dSdoCapital = dSdoCapital;
			LET dCapTrasNoVen = dCapTrasNoVen;
			LET dCapMtoCuota = dCapMtoCuota;
			
        --- si la suma de capitales menos la cuota original menos insteres es < 0, es para obtener un monto cuota con todo lo que se debe
		--- capital e intereses (si el capital de la cuota es mayor al capital, se sustituye por el capital mas intereses)
		IF ((dSdoCapital + dCapTrasNoVen - (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal )) <= 0)  
			and ((dSdoCapital + dCapTrasNoVen) > 0 OR (psaldoInteresApoyo + psaldoIvaApoyo) > 0) THEN
		----    500  - (2000 - 500 - 50) = -950    ---- PA 600 + 60 
		
			LET dCapMtoCuotaApoyo = dCapMtoCuota - (dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal);
								---  =  2000 - 500 + 500 +50 = 950 
			IF (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
				--- 
				IF dCapMtoCuotaApoyo >= (psaldoInteresApoyo + psaldoIvaApoyo)  THEN
				
					LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal + psaldoInteresApoyo + psaldoIvaApoyo;
				
					UPDATE "informix".sd_amortiza_creditocrd
					   SET capital_mto_cuota   = dCapMtoCuota,
						interes_debe 			= interes_debe + psaldoInteresApoyo,
						iva_debe				= iva_debe + psaldoIvaApoyo
					 WHERE empresa             = cEmpresa
					   AND num_credito         = cNumCredito
					   AND capital_status      = "3";
					   
					LET vlIntVenBal = vlIntVenBal + psaldoInteresApoyo;
					LET vlIvaIntVenBal = vlIvaIntVenBal + psaldoIvaApoyo;

			----    500  - (2000 - 500 - 50) = -950    ---- PA 1000 + 100 = 1100
					   ------ cancelar  retenido
					UPDATE bdicred:sd_maeretenido 
						SET monto = 0, estatus = 'S'
					WHERE num_credito = cNumCredito
						AND transacc = '8374'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maeretenido 
						SET monto = 0, estatus = 'S'
					WHERE num_credito = cNumCredito
						AND transacc = '8375'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maesdoscrd 
					SET sdo_retenido = sdo_retenido - (psaldoInteresApoyo + psaldoIvaApoyo)
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
						
					LET dPagoInt = psaldoInteresApoyo;
					LET dPagoIvaInt = psaldoIvaApoyo;
						
					LET psaldoInteresApoyo = 0;
					LET psaldoIvaApoyo = 0;
					   
				ELSE
						---- proporcional, acompletar cuota
					LET dFactor = psaldoInteresApoyo / (psaldoInteresApoyo + psaldoIvaApoyo);
					LET dPagoInt = round(dCapMtoCuotaApoyo * dFactor,2);		
					LET dPagoIvaInt = dCapMtoCuotaApoyo - dPagoInt;					
				
				
					UPDATE "informix".sd_amortiza_creditocrd
					   SET interes_debe 			= interes_debe + dPagoInt,
						iva_debe				= iva_debe + dPagoIvaInt
					 WHERE empresa             = cEmpresa
					   AND num_credito         = cNumCredito
					   AND capital_status      = "3";
					   
					LET vlIntVenBal = vlIntVenBal + dPagoInt;
					LET vlIvaIntVenBal = vlIvaIntVenBal + dPagoIvaInt;
					----- agregar movimientos
					------- disminuir de la retenido
					
					UPDATE bdicred:sd_maeretenido 
						SET monto = monto - dPagoInt
					WHERE num_credito = cNumCredito
						AND transacc = '8374'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maeretenido 
						SET monto = monto - dPagoIvaInt
					WHERE num_credito = cNumCredito
						AND transacc = '8375'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maesdoscrd 
					SET sdo_retenido = sdo_retenido - (dPagoInt + dPagoIvaInt)
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
				
					LET psaldoInteresApoyo = psaldoInteresApoyo - dPagoInt;
					LET psaldoIvaApoyo = psaldoIvaApoyo - dPagoIvaInt;
					
				
				END IF;
				
				IF dPagoInt>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 50,
										  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dPagoInt, cFolio,
										  cSucursal, cDivisa, "0000",'INT','')
						RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000007";
							   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
				END IF;				
				
				IF dPagoIvaInt>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 51,
										  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dPagoIvaInt, cFolio,
										  cSucursal, cDivisa, "0000",'INT','')
						RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000007";
							   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
				END IF;				
				
			ELSE  	

				LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal ;
			--	LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
				UPDATE "informix".sd_amortiza_creditocrd
				   SET capital_mto_cuota   = dCapMtoCuota
				 WHERE empresa             = cEmpresa
				   AND num_credito         = cNumCredito
				   AND capital_status      = "3";
			
			END IF;
		

		END IF;
		
		LET dCapMtoCuota_ori = dCapMtoCuota;
		---- cuando los intereses son mayor al monto cuota le deja todo el monto en un monto cuota sin limite
		IF  (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal) < 0 THEN	
			LET dCapMtoCuota = vlIntVenBal + vlIvaIntVenBal;
					
				UPDATE "informix".sd_amortiza_creditocrd
				SET capital_mto_cuota   = dCapMtoCuota
				WHERE empresa             = cEmpresa
				AND num_credito         = cNumCredito
				AND capital_status      = "3";			
		END IF;
		
		LET dPagoIvaInt = dPagoIvaInt;
		let dIvaIntReal = dIvaIntReal;
		LET dIvaIntVigente	=dIvaIntVigente;
		
		----- la resta del monto cuota menos los intereses es para obtener solo el capital
        LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;
        --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - dProvInt - dProvIva - dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal ;
        --LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - dProvInt - dProvIva- dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdomesantint = vlIntVenBal; --dSdoInt;
        LET dSdoNoExig = dSdoNoExig +  vlIntVenBal; --dSdoInt;
        LET dSdoInt = 0;
        LET dIvaIntVigente = dIvaIntVigente + dIvaIntReal + dPagoIvaInt;

        IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;

		UPDATE "informix".sd_amortiza_creditocrd
		   SET capital_debe        = capital_mto_cuota - vlIntVenBal - vlIvaIntVenBal,
			   iva_debe            = iva_debe + (dIvaIntReal),
			   capital_status      = "1",
			   capital_status_ant  = "3"
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "3";


		select  capital_debe
		  into vlCapitalDebe
		  from "informix".sd_amortiza_creditocrd
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

		if vlCapitalDebe is null then let vlCapitalDebe = 0; end if;

		select interes_debe,
			   iva_debe
		  into dIntPeriodo,
			   dIvaPeriodo
		  from "informix".sd_amortiza_creditocrd
		 where empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

	    IF dIntPeriodo IS NULL THEN LET dIntPeriodo=0; END IF;
	    IF dIvaPeriodo IS NULL THEN LET dIvaPeriodo=0; END IF;

		IF dIntPeriodo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 43,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIntPeriodo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;
		IF psaldoInteresApoyo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 48,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, psaldoInteresApoyo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;		
		IF dIvaPeriodo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 44,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIvaPeriodo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;
		IF psaldoIvaApoyo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 49,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, psaldoIvaApoyo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;		
      -- LET vlCapitalDebe = dCapMtoCuota - (interes_debe - interes_pagado) - (dIvaIntReal);
	  --FNV: 31-ENE-2011
		 --IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) > 0 THEN
		 ----- agregar variables disminuidas, si sobra de retenido
		IF (dSdoCapital + dCapTrasNoVen - vlCapitalDebe) > 0 OR  (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
		
			LET dCapMtoCuota = dCapMtoCuota_ori;
	  -- IF (dSdoCapital - dCapMtoCuota) >  0 THEN
			   INSERT INTO "informix".sd_amortiza_creditocrd
						(
							empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
							capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
							capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
							interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
							iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
							mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
							mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
							mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
							num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
							campo_trabajo4
						)
					VALUES
						(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
							dCapMtoCuota,        0,				0,			        "3",
							"3",         		"",				0,			         0,
							"1",                "1",			NULL,			     0,
							0,			        "1",			"1",                 "",
							0,			         0,				0,			         0,
							0,			         0,				0,			         "1",
							0,			          0,			"1",			     "",
							iNumPago,		      0,			0,			         "",
							""
						);
						
		END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
 IF  cIdProc3 = "M"  THEN

               SELECT NVL(a.capital_debe - a.capital_pagado,0),NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap,dTraspInt
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

					IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
					IF dTraspInt IS NULL THEN LET dTraspInt=0; END IF;
----Realiza traspasos a transitorio
        IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN
			IF dTraspCap>0 OR dTraspInt > 0 THEN

               LET dMntVencido = dMntVencido + dTraspCap;
               LET dSdoCapital = dSdoCapital - dTraspCap;

                UPDATE "informix".sd_amortiza_creditocrd
                   SET capital_status = "7",
                       capital_status_ant  = "1",
                       campo_trabajo3 = ''
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

						IF cStatusCred='AA' THEN
							  --Se actualiza la fecha de vencimiento
							  UPDATE "informix".sd_maecredanexocrd
								 SET fecha_vencto  = dtFechaHoy
							   WHERE num_credito    = cNumCredito
								 AND empresa        = cEmpresa;

							 --FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
							  UPDATE "informix".sd_indicador_cred_crd
								 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)
							   WHERE num_credito   = cNumCredito
								 AND empresa       = cEmpresa;
						END IF;

                  -- Traspaso capital vigente a transitorio.
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3,
							  "026", dtFechaHoy, dTraspCap, cFolio,
							  cSucursal, cDivisa, "0000",'TCVAT','')
					  RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
					    IF dTraspInt > 0 THEN
						  -- Traspaso interes vigente a transitorio.
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 6,
								  "026", dtFechaHoy, dTraspInt, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAT','')
						  RETURNING cCodRet,cMensajeRet;
							IF (cCodRet <> "000000") THEN
								   LET cCodRet      = cCodRet;
								   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
								   IF cBegin = "S" THEN
									  ROLLBACK WORK;
								   END IF;
								   RETURN cCodRet,cMensajeRet;
							 END IF;
					    END IF; -- IF dTraspInt > 0 THEN
            END IF; --IF dTraspCap>0 THEN
		END IF; --IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN

        --ELSE
			IF cIdProc3 = "M" AND cStatusCred='BT' THEN
                LET dMntVencTras = dMntVencTras + dTraspCap;
                LET dCapTrasNoVen = dCapTrasNoVen - dTraspCap;
                LET dIntVdo = dIntVdo + dSdoNoExig;
                LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
                LET dIvaIntVigente=0;

                UPDATE "informix".sd_amortiza_creditocrd
                   SET capital_status = "2",
                       capital_status_ant  = "1",
                       campo_trabajo3 ='V'
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

                   LET dSdoNoExig = 0;

                  -- Traspaso capital vencido no exigible a vencido exigible.
                IF dTraspCap > 0 THEN --FMV 25Mar13: Se omite generar movimiento en 0, cuando ya termino devengamiento
                    CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 2,
                           "026", dtFechaHoy, dTraspCap, cFolio,
                           cSucursal, cDivisa, "0000",'TCVNEAVE','')
                        RETURNING cCodRet,cMensajeRet;

                    IF (cCodRet <> "000000") THEN
                           LET cCodRet      = "000014";
                           LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vencido no exigible a vencido exigible";
							IF cBegin = "S" THEN
                              ROLLBACK WORK;
                            END IF;
                           RETURN cCodRet,cMensajeRet;
                    END IF;
                END IF;  --dTraspCap > 0 THEN  FMV 25Mar13:
			END IF; --IF cIdProc3 = "M" AND cStatusCred='BT' THEN


                UPDATE "informix".sd_maecredanexocrd
                   SET prox_fecha_pago = dtFechaProxCuota,
                       dia_corte       = iDiaCorte
                  WHERE num_credito     = cNumCredito
                    AND empresa         = cEmpresa;

                    IF (cStatusCredIndica = "AA" and dTraspCap>0 and cNumProducto <> '6900') then
                        let cStatusCredIndica = 'BA';
                    END IF;

                UPDATE "informix".sd_maecredcrd
                   SET status_cred = (CASE WHEN cStatusCred = "AA" and dTraspCap>0 and cNumProducto <> '6900' THEN "BA" ELSE status_cred END),
                       fecha_pago_cap = dtFechaProxCuota,
                       fecha_pago_int = dtFechaProxCuota
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;
---Ini cas Validacion solicitada por operaciones para que no cobre el int devengado
---de un dia cuando la reestructura llega a su ultima mensualidad
                    IF dCapTrasNoVen = 0 AND dSdoCapital = 0 AND dSdoInt > 0 THEN
                       LET dSdoInt = 0;
                    END IF;
---Fin cas Validacion solicitada por operaciones
END IF;

------Realiza traspasos a vencido
-- FMV 9jul2013: Traspaso a Vencido aquellos prestamos que llegan a la ultima cuota y pasan los 90 dias vencidos
-- JOM 11/04/2013 Se cambia traspado a periodos INI
-- Se realiza el traspado en la mensualidad 4 para considerar 90 o mas dias en transitorio            
           SELECT COUNT(a.num_credito), nvl(min(fecha_cuota), date(1))
             INTO iNumVdos, dFechacuotamin
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status IN ("2","7");
            
            IF day(dtFechaHoy) >= iDiaCorte  then 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin ) + 1;  
            ELSE 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin );
            END IF;

            IF (cStatusCred='BA' AND iNumVdos >= 4) or (cStatusCred='BA' and iNumVdos < iNumVdosaux and iNumVdosaux >= 4 and dFechacuotamin <> date(1)) 
--            IF cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) --OR vf_fecha_vencim < dtFechaHoy
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
				  THEN
					--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
					SELECT monto
						INTO psaldoInteresTrasApoyo
					FROM bdicred:sd_maeretenido 
					WHERE num_credito = cNumCredito
						AND transacc = '8374'
						AND estatus = 'R';

						IF psaldoInteresTrasApoyo IS NULL THEN
							LET psaldoInteresTrasApoyo = 0;
						END IF;
						LET dCapTrasNoVen = dCapTrasNoVen + dSdoCapital;
						LET dMntVencTras = dMntVencTras + dMntVencido;
						LET dIntVdo = dIntVdo + dSdoNoExig;
						LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;

						UPDATE "informix".sd_maecredcrd
						   SET status_cred = "BT"
						 WHERE num_credito = cNumCredito
						   AND empresa     = cEmpresa;

						UPDATE "informix".sd_amortiza_creditocrd
						   SET capital_status = "2",
							   capital_status_ant  = "7"
						 WHERE empresa        = cEmpresa
						   AND num_credito    = cNumCredito
						   AND capital_status = "7";

                  -- Traspaso capital vigente a vdo no exigible.
					IF dCapTrasNoVen > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 4,
							  "026", dtFechaHoy, dSdoCapital, cFolio,
							  cSucursal, cDivisa, "0000",'TCVAVNE','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000010";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a vdo no exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dCapTrasNoVen > 0 THEN

					  -- Traspaso capital transitorio a exigible.
					IF dMntVencTras  > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 1,
							  "026", dtFechaHoy, dMntVencido, cFolio,
							  cSucursal, cDivisa, "0000",'TCTAE','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000011";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital transitorio a exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dMntVencTras  > 0

					  -- Traspaso interes vigente a vdo.
					IF dIntVdo > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 5,
							  "026", dtFechaHoy, dSdoNoExig, cFolio,
							  cSucursal, cDivisa, "0000",'TIVAV','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000012";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso interes vigente a vdo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; --IF dIntVdo > 0
					
					IF psaldoInteresTrasApoyo > 0 THEN
					  -- Traspaso interes vigente a transitorio.
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7,
							  "026", dtFechaHoy, psaldoInteresTrasApoyo, cFolio,
							  cSucursal, cDivisa, "0000",'TIVAV','')
					  RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso Interes Apoyo vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
					END IF;

						LET dSdoCapital = 0;
						LET dMntVencido = 0;
						LET dIvaIntVigente = 0;
						LET dSdoNoExig = 0;
            END IF; --  cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) OR vf_fecha_vencim < dtFechaHoy


-- *******************************************************
-- CALCULO DE INTERES MORATORIO                          *
-- *******************************************************
    LET dTasaInterMorCop = dTasaInterMor - dTasaInter;
--IPCB	
	IF dTasaInterMorCop < 0 THEN
		LET dTasaInterMorCop = 0;
	END IF;
	
FOREACH
     SELECT a.fecha_cuota,
            SUM(NVL(a.capital_debe,0) - NVL(a.capital_pagado,0))
       INTO dtFechaCuota,
            dSdoMora
       FROM "informix".sd_amortiza_creditocrd a
      WHERE a.empresa        = cEmpresa
        AND a.num_credito    = cNumCredito
        AND a.capital_status IN ("2","7")
   GROUP BY 1

     IF NVL(dSdoMora,0) > 0 THEN
          --Se calcula el interes moratorio
          LET dIntMora = (dSdoMora * dTasaInter / (iDiasCalc * 100)) * iDiasInt;

          --Se calculan el interes moratorio copete
          LET dIntCope = (dSdoMora * dTasaInterMorCop / (iDiasCalc * 100)) * iDiasInt;

          -- se actualizan los intereses moratorios en la amortizacrd
          UPDATE "informix".sd_amortiza_creditocrd
             SET mora_sdo_ordi = mora_sdo_ordi + dIntMora,
                 mora_sdo_cope = mora_sdo_cope + dIntCope
           WHERE empresa     = cEmpresa
             AND num_credito = cNumCredito
             AND fecha_cuota = dtFechaCuota;

             LET dSdomoratorio = dSdomoratorio + dIntCope;
             LET dSdocontabmora = dSdocontabmora + dIntMora;
     END IF;
END FOREACH;

   SELECT COUNT(*), min(fecha_cuota) 
     INTO iNumVdos,iFechaVencto
     FROM "informix".sd_amortiza_creditocrd a
    WHERE a.empresa        = cEmpresa
      AND a.num_credito    = cNumCredito
      AND a.capital_status IN ("2","7");

   IF iNumVdos IS NULL THEN
      LET iNumVdos = 0;
   END IF;

    UPDATE sd_maesdoscrd
    SET fecha_ult_mov = dtFechaHoy,
        sdo_int_anticip = 0,
        sdo_int_ant_dev = 0,
        sdo_intereses = dSdoInt,
        sdo_dia_ant_int = dSdodiaantint,
        sdo_mes_ant_int = dSdomesantint,
        sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
--        sdo_retenido = 0,
        sdo_acum_cap_int = 0,
        sdo_exig_int = 0,
        sdo_no_exig = dSdoNoExig,
--        provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE dIntProvFinMes END),
		provision_normal = (CASE WHEN cIdProc1 = "C" THEN (dSdoInt) ELSE dIntProvFinMes END),
        dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END),
        sdo_dia_ant_mor = (sdo_moratorio + sdo_contab_mora),
        sdo_mes_ant_mor= (CASE WHEN cIdProc3 = "F" THEN sdo_dia_ant_mor ELSE sdo_mes_ant_mor END),
        sdo_moratorio = dSdomoratorio,
        sdo_contab_mora = dSdocontabmora,
        dias_acum_mora = (CASE WHEN (dSdomoratorio + dSdocontabmora) > 0 THEN (dias_acum_mora + iDiasInt) ELSE dias_acum_mora END),
        sdo_dia_ant_cap = sdo_cap_insoluto,
        sdo_mes_ant_cap = 0,
        sdo_acum_mes_cap = 0,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,
        --mto_capitalizado = 0,
        mto_ministra_cap = 0,
        dias_acum_cap = (dias_acum_cap + iDiasInt),
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado,
--        sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE dIvaProvFinMes END),
        sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE dIvaProvFinMes END),
        cap_tras_no_venci = dCapTrasNoVen,
        mto_venc_int = dIvaIntVencido,
        mto_finan_vdo = dIvaIntVigente,
        int_tra_no_exig = dIntVdo,
        sdo_trab4 = dSdotrab4,
        mto_fin_ven_trasp = iNumVdos
    WHERE  empresa = cEmpresa
      AND  num_credito = cNumCredito;

-- *******************************************************
-- RESPALDO DE INFORMACION CONTABILIDAD A FIN DE MES     *
-- *******************************************************

     IF cIdProc1 = "C" THEN

           INSERT INTO "informix".sd_maesdoscontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdoscrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcontcrd
                SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,
						cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,
						tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,
						valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,
						credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
                  FROM informix.sd_maecredcrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

             LET iContCierre = iContCierre + 1;

             IF (iContCierre = 80000) THEN
                LET iContCierre = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
             END IF;
     END IF;
-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshistcrd
             SELECT dtFechaHoy, *
               FROM informix.sd_maesdoscrd
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;

            LET iContCorte = iContCorte + 1;

            IF iContCorte = 30000 THEN
                LET iContCorte = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
            END IF;
    END IF;

-- ***********************************
-- GUARDA SALDOS FIN DE DIA          *
-- ***********************************

      select sum(interes_debe - interes_pagado) vencido_balanza,
             sum(iva_debe - iva_pagado) iva_vencido_balanza
        into vlIntVenBal, vlIvaIntVenBal
        from bdicred:sd_amortiza_creditocrd 
        where empresa = cEmpresa
          and num_credito = cNumCredito 
		      and campo_trabajo3 <> 'V'
          and capital_status = '2';
        
      if  vlIntVenBal is null then
         let vlIntVenBal = 0;
         let vlIvaIntVenBal = 0;
      end if;
	  
	  LET dSdoNoExig = dSdoNoExig;
	  LET dSdoInt = dSdoInt;
	  LET dIntProvFinMes = dIntProvFinMes;
	  
	  LET dIvaIntVigente = dIvaIntVigente;
	  LET dProvIva = dProvIva;
	  LET dIvaProvFinMes = dIvaProvFinMes;
	  
	  LEt cIdProc1 = cIdProc1;
	  LEt cIdProc2 = cIdProc2;

	  LET dIvaIntReal = dIvaIntReal;	----- Trael calculo de IVA del monto total de int arrastrado (dSdoInt) por el programa de apoyo
	  
/*	  IF wbandera_apoyo = 'A' AND cIdProc1 = "C" AND cIdProc2 = "" THEN
			CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dIvaIntReal)
									  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
								dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
			 RETURNING cCodRet;
	  ELSE		*/
	  
			CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
									  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
								dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
			 RETURNING cCodRet;
--	 END IF;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- ****************************************
-- FIN DEL PROCESO                        *
-- ****************************************
--          LET iContCommit = iContCommit + 1;

--           IF cBegin = "S" AND iContCommit > 2 THEN
               COMMIT WORK;
               LET cBegin = "N";
--               LET iContCommit = 0;
--           END IF;
            --FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
            --FMV 17jun13: Ajuste para prestamos q vencen a fin de mes y cambio de estatus vigente
                    IF (dtFechaHoy = dtFechaFinMes)  THEN
                        IF (cStatusCredIndica = 'AA') THEN
                            LET vdias_atraso = 0;
                        ELSE
                            LET vdias_atraso = (dtFechaFinMes - nvl(dtFechaVencto,dtFechaFinMes) + 1);
                        END IF;

                         UPDATE "informix".sd_indicador_cred_crd
                            SET dias_atraso   = vdias_atraso,
                                fecha_ultimo_pago = vf_fecha_ult_pago,
                                fecha_ultimo_pago_h = vf_fecha_ult_pago
                          WHERE empresa = cEmpresa
                            AND num_credito = cNumCredito;
                    END IF; --IF cIdProc1 = "C"
				
-- *******************************************************
-- 	RQM 09 473: TRIAD	                                 *
-- *******************************************************
	LET vSdoTotLiquidar 	= dSdoCapInso + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
	LET vPagoMinimo 	    = dMontofinanciado + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
							  
	LET vSdoTotVencido 		=  dMntVencido + dMntVencTras +
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
	 
	-- Actualizacion DIARIA.
	UPDATE "informix".sd_indicador_cred_crd
		SET sdo_tot_liquidar 	= vSdoTotLiquidar,
			pago_minimo 		= vPagoMinimo,
			sdo_tot_vencido 	= vSdoTotVencido,
			saldo_maximo_hist   = CASE WHEN(vSdoTotLiquidar > nvl(saldo_maximo_hist,0)) THEN vSdoTotLiquidar ELSE nvl(saldo_maximo_hist,0) END
	WHERE 	empresa				= cEmpresa
	AND 	num_credito 		= cNumCredito;

	--Actualizacion al CORTE.
	IF cIdProc3 = "M" THEN 
		UPDATE "informix".sd_indicador_cred_crd
		SET num_vencidos_ch 	= CASE WHEN num_vencidos_ch IS NULL OR num_vencidos_ch = '' THEN iNumVdos ELSE num_vencidos_ch END,
			sdo_tot_liquidar_ch = vSdoTotLiquidar,
			pago_minimo_ch  	= vPagoMinimo,
			intereses_periodo_ch = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									ELSE (dSdoNoExig + dIntProvFinMes) END),
			sdo_tot_vencido_ch 	= vSdoTotVencido,
			fecha_primera_mora  = CASE WHEN fecha_primera_mora IS NULL OR fecha_primera_mora = '' THEN iFechaVencto ELSE fecha_primera_mora END,
			fecha_ultima_mora	= CASE WHEN iFechaVencto IS NOT NULL THEN iFechaVencto ELSE fecha_ultima_mora END,
			max_mora_hist       = CASE WHEN iNumVdos > nvl(max_mora_hist,0) THEN iNumVdos ELSE nvl(max_mora_hist,0) END
		WHERE empresa			= cEmpresa
		AND num_credito 		= cNumCredito;
	END IF;	

	--Actualizacion a FIN DE MES.
	IF cIdProc1 = "C" THEN
		UPDATE "informix".sd_indicador_cred_crd 
		SET sdo_tot_liquidar_h = vSdoTotLiquidar,
			pago_minimo_h 	   = vPagoMinimo,
			sdo_tot_vencido_h  = vSdoTotVencido
		WHERE empresa = cEmpresa
		AND num_credito = cNumCredito;
    END IF;
	-- RQM 09 473: TRIAD - FIN	

END FOREACH;
--    IF iContCommit > 0 THEN --  COMMIT WORK;--    END IF;

    IF iContCierre > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
    END IF;

    IF iContCorte > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
    END IF;

   LET cCodRet = "000";   LET cMensajeRet = "PROCESO CONCLUIDO";
/*
    UPDATE "informix".sd_contproc
       SET status_proc = "F", 		hora_fin    = CURRENT,
           cod_ret     = cCodRet, 	mensaje     = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F",		hora_fin    = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_pp;
	       LET cBanTemp ='N';
	   END IF;
*/  
 RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;