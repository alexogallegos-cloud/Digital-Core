CREATE PROCEDURE "informix".sp_carga_creditos_vta_progapoyo() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCod_Ret CHAR(6);
DEFINE cRuta CHAR (50);
DEFINE cDatosCtesCamp CHAR (50);
DEFINE dtCampAct DATETIME YEAR TO SECOND;
DEFINE dtCampIni DATETIME YEAR TO SECOND;
DEFINE dtCampFin DATETIME YEAR TO SECOND;
DEFINE dFechaIniCred DATETIME YEAR TO SECOND;


DEFINE wBegin                CHAR(1);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);
DEFINE dtFechaHoy			DATE;

-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_consulta_proyecta_credisol
DEFINE c_CodigoRet_pp           CHAR(6);
DEFINE i_Periodo_pp             INTEGER;
DEFINE d_FechaCouta_pp          DATE;
DEFINE d_FechaAper_pp           DATE;
DEFINE i_Cont                   SMALLINT;
DEFINE cMensajeRet 		CHAR(50);



LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCod_Ret = '000000';
LET cRuta = '';
LET cDatosCtesCamp = '';
LET wBegin = '';
LET dtCampAct = CURRENT;
LET cArchivo_dbld    = "f_datosctes.com";
LET cArchivo_log     = "f_datosctes.log";


-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_consulta_proyecta_credisol
LET c_CodigoRet_pp              = '';

LET i_Cont                      = 0;
LET dtFechaHoy			= DATE(1);
LET cMensajeRet 		= '';





BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
	
   	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
  

  --SET DEBUG FILE TO '/RESPALDOSNEW/CARTE/sp_carga_creditos.out';
  --TRACE ON;

    LET cDatosCtesCamp="creditosvtaprogapoyo"; 
	LET cRuta="/RESPALDOSNEW/";  	
 
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy INTO dtFechaHoy
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	IF NVL(cRuta,'') <> '' THEN
		IF NVL(cDatosCtesCamp,'') <> '' THEN
			LET dtCampAct = CURRENT;
			LET cDatosCtesCamp = TRIM(cDatosCtesCamp)||'.unl';                
			
			TRUNCATE TABLE "informix".creditos_venta_progapoyo;
						   
		   --system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosCtesCamp) ||' DELIMITER '|| "'" || '|' || "'" || ' 1;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
		   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosCtesCamp) ||' DELIMITER '|| "'" || '|' || "'" || ' 2;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
		   system ' echo "INSERT INTO creditos_venta_progapoyo;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
		   system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

		   system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datosctes.sh';
		   system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 10000' || ' " >> ' || TRIM(cRuta)|| 'dbload_datosctes.sh'; 
		   system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';
		   system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';             
		  -- system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';          
		   system ' echo "update statistics medium for table creditos_venta_progapoyo; ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';           
		   system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';           
		   system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datosctes.sh';
		   system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datosctes.sh';     
			
			LET cCodRet = '000000';
		ELSE
			LET cCodRet = '000002';
		END IF;
		 
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 19/FEB/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_productos_act (  pEmpresa CHAR(3), pUsuario CHAR(8), pnum_producto CHAR(4), ptpoejecucion CHAR(1), o_solicitudes SMALLINT)
		RETURNING CHAR(6) AS cod_ret,
				  CHAR(3) AS tot_reg,
				  CHAR(4) AS numproducto,
				  CHAR(3) AS Cod_Definicion,
				  CHAR(50) AS Prod_Nombre,
				  CHAR(3) AS Codigo_Grupo,
				  CHAR(4) AS Codigo_Docto,
				  CHAR(50) AS Des_cripcion,
				  CHAR(4) AS Codproducto,
				  CHAR(2) AS codtipcred,
				  CHAR(40) AS nombreprod,
				  CHAR (21) AS montomincred,
				  CHAR (21) AS montomaxcred,
				  CHAR(2) AS di_visa,
				  CHAR(1) AS sevaloriza,
				  CHAR(2) AS tipocalculo,
				  CHAR(1) AS tasafijaovar,
				  CHAR(8) AS codtasabase,
				  CHAR(22) AS sobretasa,
				  CHAR(1) AS factorsobretasa,
				  CHAR(1) AS tiporefinanc,
				  CHAR(22) AS porcentrefinanc,
				  CHAR(1) AS pagoadicsigcuo,
				  CHAR(1) AS periodpagint,
				  CHAR(1) AS periodpagocap,
				  CHAR(1) AS periodoplazo,
				  CHAR(2) AS plazomincred,
				  CHAR(2) AS plazomaxcred,
				  CHAR(1) AS tasamoraadic,
				  CHAR(8) AS codtasamora,
				  CHAR(1) AS factsobretmora,
				  CHAR(22) AS sobretasamora,
				  CHAR(22) AS factormoratorio,
				  CHAR(1) AS cretasavarper,
				  CHAR(2) AS diapararevisar,
				  CHAR(1) AS pre_autoriza,
				  CHAR(8) AS tasa_basepiso,
				  CHAR(22) AS sobretasapiso,
				  CHAR(1) AS factorpiso,
				  CHAR(22) AS tasapiso,
				  CHAR(8) AS tasa_basetecho,
				  CHAR(22) AS sobretasatecho,
				  CHAR(1) AS factortecho,
				  CHAR(22) AS tasatecho,
				  CHAR(1) AS bandprod,
				  CHAR(10) AS codprod,
				  CHAR(2) AS tpopersona,
				  CHAR(2) AS tipocliente,
				  CHAR(1) AS seg_mentado,
				  CHAR(22)AS poracciones,
				  CHAR(1) AS manejalinea,
				  CHAR(2) AS diacuota,
				  CHAR(2) AS graciacalcmora,
				  CHAR(1) AS tp_solicitud,
				  CHAR(2) AS si_glas,
				  CHAR(3) AS family;


	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 						CHAR(6);
	DEFINE iSqlErr 						INTEGER;
	DEFINE iIsamErr     				INTEGER;
	DEFINE cErrorInfo   				VARCHAR(255,1);
	DEFINE cEmpresa         			CHAR(3);
	DEFINE cUsuario						CHAR(8);
    DEFINE cNum_Producto    			CHAR(4);
	DEFINE v_ya_existe 					SMALLINT;
	DEFINE ccod_tipcred					CHAR(2);
	DEFINE cnombre_prod					CHAR(40);
	DEFINE dmonto_min_cred				DECIMAL(21,2);
	DEFINE dmonto_max_cred				DECIMAL(21,2);
	DEFINE cdivisa						CHAR(2);
	DEFINE cse_valoriza     		 	CHAR(1);
	DEFINE ctipo_calculo    		 	CHAR(2);
	DEFINE ctasa_fija_o_var 		 	CHAR(1);
	DEFINE ccod_tasa_base 	 			CHAR(8);
	DEFINE dsobretasa       		 	DECIMAL(16,6);
	DEFINE cfactor_sobretasa		 	CHAR(1);
	DEFINE ctipo_refinanc   			CHAR(1);
	DEFINE dporcent_refinanc 			DECIMAL(16,6);
	DEFINE cpago_adic_sig_cuo			CHAR(1);
	DEFINE cperiod_pag_int  			CHAR(1);
	DEFINE cperiod_pago_cap 			CHAR(1);
	DEFINE cperiodo_plazo   			CHAR(1);
	DEFINE iplazo_min_cred  			INTEGER;
	DEFINE iplazo_max_cred  			INTEGER;
	DEFINE ctasa_mora_adic  			CHAR(1);
	DEFINE ccod_tasa_mora   			CHAR(8);
	DEFINE cfact_sobret_mora			CHAR(1);
	DEFINE dsobretasa_mora 				DECIMAL(16,6);
	DEFINE dfactor_moratorio 			DECIMAL(16,6);
	DEFINE ccrev_tasa_var_per			CHAR(1);
	DEFINE idia_para_revisar 			INTEGER;
	DEFINE cpreautoriza      			CHAR(1);
	DEFINE ctasa_base_piso   			CHAR(8);
	DEFINE dsobretasa_piso  			DECIMAL(16,6);
	DEFINE cfactor_piso     			CHAR(1);
	DEFINE dtasa_piso       			DECIMAL(16,6);
	DEFINE ctasa_base_techo  			CHAR(8);
	DEFINE dsobretasa_techo     		DECIMAL(16,6);
	DEFINE cfactor_techo     			CHAR(1);
	DEFINE dtasa_techo          		DECIMAL(16,6);
	DEFINE cband_prod        			CHAR(1);
	DEFINE ccod_prod         			CHAR(10);
	DEFINE ctpo_persona     			CHAR(2);
	DEFINE ctipo_cliente     			CHAR(5);
	DEFINE csegmentado       			CHAR(1);
	DEFINE dpor_acciones        		DECIMAL(16,6);
	DEFINE cmaneja_linea     			CHAR(1);
	DEFINE idia_cuota        			INTEGER;
	DEFINE igracia_calc_mora 			INTEGER;
	DEFINE ctpsolicitud					CHAR(1);
	DEFINE csiglas						CHAR(2);
	DEFINE cCodDefinicion				CHAR(3);
	DEFINE cProdNombre 					CHAR(50);
	DEFINE cCodigoSec 				CHAR(3);
	DEFINE cCodigoDocto					CHAR(4);
	DEFINE cDescripcion 				CHAR(50);
	DEFINE cCod_producto				CHAR(4);
	DEFINE iCountexiste					INTEGER;
	DEFINE cfamilia						CHAR(3);
	DEFINE cCodproducto1 				CHAR(4);
	DEFINE cCodproducto2 				CHAR(4);
	DEFINE cCodproducto3 				CHAR(4);
	DEFINE iTotregistros					INTEGER;
	DEFINE iContcodproducto1			INTEGER;
	DEFINE iContcodproducto2			INTEGER;
	DEFINE iContcodproducto3			INTEGER;
	DEFINE iContcodproducto4			INTEGER;

		-----------

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iIsamErr        		= 0;
	LET cErrorInfo      		= "";
	LET cEmpresa = pEmpresa;
	LET cUsuario = pUsuario;
	LET cNum_Producto 		 = '';
	LET v_ya_existe			 = 0;
	LET ccod_tipcred		 = '';
	LET cnombre_prod		 = '';
	LET dmonto_min_cred		 = 0;
	LET dmonto_max_cred		 = 0;
	LET cdivisa				 = '';
	LET cse_valoriza     	 = '';
	LET ctipo_calculo    	 = '';
	LET ctasa_fija_o_var 	 = '';
	LET ccod_tasa_base 	 	 = '';
	LET dsobretasa       	 = 0;
	LET cfactor_sobretasa	 = '';
	LET ctipo_refinanc   	 = '';
	LET dporcent_refinanc 	 = 0;
	LET cpago_adic_sig_cuo	 = '';
	LET cperiod_pag_int  	 = '';
	LET cperiod_pago_cap 	 = '';
	LET cperiodo_plazo   	 = '';
	LET iplazo_min_cred  	 = 0;
	LET iplazo_max_cred  	 = 0;
	LET ctasa_mora_adic  	 = '';
	LET ccod_tasa_mora   	 = '';
	LET cfact_sobret_mora	 = '';
	LET dsobretasa_mora 	 = 0;
	LET dfactor_moratorio 	 = 0;
	LET ccrev_tasa_var_per	 = '';
	LET idia_para_revisar 	 = 0;
	LET cpreautoriza      	 = '';
	LET ctasa_base_piso   	 = '';
	LET dsobretasa_piso  	 = 0;
	LET cfactor_piso     	 = '';
	LET dtasa_piso       	 = 0;
	LET ctasa_base_techo  	 = '';
	LET dsobretasa_techo     = 0;
	LET cfactor_techo     	 = '';
	LET dtasa_techo          = 0;
	LET cband_prod        	 = '';
	LET ccod_prod         	 = '';
	LET ctpo_persona     	 = '';
	LET ctipo_cliente     	 = '';
	LET csegmentado       	 = '';
	LET dpor_acciones        = 0;
	LET cmaneja_linea     	 = '';
	LET idia_cuota        	 = 0;
	LET igracia_calc_mora 	 = 0;
	LET ctpsolicitud		= '';
	LET csiglas				= '';
	LET cCodDefinicion		= '';
	LET cProdNombre 		= '';
	LET cCodigoSec 		= '';
	LET cCodigoDocto		= '';
	LET cDescripcion 		= '';
	LET cCod_producto		= '';
	LET iCountexiste		= 0;
	LET cfamilia			='0';
	LET cCodproducto1 = substr(pnum_producto,1,2) || '01';
	LET cCodproducto2 = substr(pnum_producto,1,2) || '33';
	LET cCodproducto3 = substr(pnum_producto,1,2) || '34';
	LET iTotregistros	= 0;
	LET iContcodproducto1	= 0;
	LET iContcodproducto2	= 0;
	LET iContcodproducto3	= 0;
	LET iContcodproducto4	= 0;
	-------

	BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
				NVL(cnombre_prod,''),NVL(dmonto_min_cred::CHAR(24),''),NVL(dmonto_max_cred::CHAR(24),''),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
				NVL(dsobretasa::CHAR(22),''),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc::CHAR(22),''),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
				NVL(cperiodo_plazo,''),NVL(iplazo_min_cred::CHAR(2),''),NVL(iplazo_max_cred::CHAR(2),''),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora::CHAR(22),''),
				NVL(dfactor_moratorio::CHAR(22),''),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso::CHAR(22),''),NVL(cfactor_piso,''),
				NVL(dtasa_piso::CHAR(22),''),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo::CHAR(22),''),NVL(cfactor_techo,''),NVL(dtasa_techo::CHAR(22),''),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
				NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones::CHAR(22),''),NVL(cmaneja_linea,''),NVL(idia_cuota::CHAR(2),''),NVL(igracia_calc_mora::CHAR(2),''),NVL(ctpsolicitud,''),NVL(csiglas,''),
				NVL(cfamilia,'');
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/sp_cons_param_banderaprod.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pEmpresa = '' OR pUsuario = '' OR ptpoejecucion = '' THEN
			LET cCodRet = '00001';
				RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
				NVL(cnombre_prod,''),NVL(dmonto_min_cred::CHAR(24),''),NVL(dmonto_max_cred::CHAR(24),''),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
				NVL(dsobretasa::CHAR(22),''),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc::CHAR(22),''),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
				NVL(cperiodo_plazo,''),NVL(iplazo_min_cred::CHAR(2),''),NVL(iplazo_max_cred::CHAR(2),''),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora::CHAR(22),''),
				NVL(dfactor_moratorio::CHAR(22),''),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso::CHAR(22),''),NVL(cfactor_piso,''),
				NVL(dtasa_piso::CHAR(22),''),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo::CHAR(22),''),NVL(cfactor_techo,''),NVL(dtasa_techo::CHAR(22),''),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
				NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones::CHAR(22),''),NVL(cmaneja_linea,''),NVL(idia_cuota::CHAR(2),''),NVL(igracia_calc_mora::CHAR(2),''),NVL(ctpsolicitud,''),NVL(csiglas,''),
				NVL(cfamilia,'');
		END IF;

		IF ptpoejecucion = '1' THEN
				SELECT count(num_producto)
				INTO iTotregistros
				FROM "informix".sd_definicion
				WHERE flag_arbol = '1';

			FOREACH
				SELECT skip o_solicitudes limit 10 num_producto,cod_tipcred,nombre_prod,monto_min_cred,monto_max_cred,divisa,se_valoriza,tipo_calculo,tasa_fija_o_var,cod_tasa_base,sobretasa,
				factor_sobretasa,tipo_refinanc,porcent_refinanc,pago_adic_sig_cuo,period_pag_int, period_pago_cap,periodo_plazo,plazo_min_cred,plazo_max_cred,
				tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,factor_moratorio,rev_tasa_var_per,dia_para_revisar,preautoriza,tasa_base_piso,
				sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,band_prod,cod_prod,tpo_persona,tipo_cliente,segmentado,
				por_acciones,maneja_linea,dia_cuota,gracia_calc_mora,siglas,familia 
				INTO cnum_producto, ccod_tipcred, cnombre_prod, dmonto_min_cred, dmonto_max_cred, cdivisa, cse_valoriza, ctipo_calculo, ctasa_fija_o_var, ccod_tasa_base, dsobretasa,
				cfactor_sobretasa, ctipo_refinanc, dporcent_refinanc, cpago_adic_sig_cuo, cperiod_pag_int, cperiod_pago_cap, cperiodo_plazo, iplazo_min_cred, iplazo_max_cred,
				ctasa_mora_adic, ccod_tasa_mora, cfact_sobret_mora, dsobretasa_mora, dfactor_moratorio, ccrev_tasa_var_per, idia_para_revisar, cpreautoriza, ctasa_base_piso,
				dsobretasa_piso, cfactor_piso, dtasa_piso, ctasa_base_techo, dsobretasa_techo, cfactor_techo, dtasa_techo, cband_prod, ccod_prod, ctpo_persona, ctipo_cliente, csegmentado,
				dpor_acciones, cmaneja_linea, idia_cuota, igracia_calc_mora,csiglas,cfamilia
				FROM "informix".sd_definicion
				WHERE flag_arbol = '1'

				IF ccod_tipcred = '03' THEN
					LET ctpsolicitud = 'T';
				ELIF ccod_tipcred = '05' THEN
					LET ctpsolicitud = 'P';
				ELIF ccod_tipcred = '00' THEN
					LET ctpsolicitud = 'C';
				END IF;

				RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
				NVL(cnombre_prod,''),NVL(dmonto_min_cred,0),NVL(dmonto_max_cred,0),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
				NVL(dsobretasa,0),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc,0),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
				NVL(cperiodo_plazo,''),NVL(iplazo_min_cred,0),NVL(iplazo_max_cred,0),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora,0),
				NVL(dfactor_moratorio,0),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso,0),NVL(cfactor_piso,''),
				NVL(dtasa_piso,0),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo,0),NVL(cfactor_techo,''),NVL(dtasa_techo,0),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
				NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones,0),NVL(cmaneja_linea,''),NVL(idia_cuota,0),NVL(igracia_calc_mora,0),NVL(ctpsolicitud,''),NVL(csiglas,''),
				NVL(cfamilia,'') WITH RESUME;
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002';
				RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
				NVL(cnombre_prod,''),NVL(dmonto_min_cred,0),NVL(dmonto_max_cred,0),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
				NVL(dsobretasa,0),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc,0),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
				NVL(cperiodo_plazo,''),NVL(iplazo_min_cred,0),NVL(iplazo_max_cred,0),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora,0),
				NVL(dfactor_moratorio,0),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso,0),NVL(cfactor_piso,''),
				NVL(dtasa_piso,0),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo,0),NVL(cfactor_techo,''),NVL(dtasa_techo,0),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
				NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones,0),NVL(cmaneja_linea,''),NVL(idia_cuota,0),NVL(igracia_calc_mora,0),NVL(ctpsolicitud,''),NVL(csiglas,''),
				NVL(cfamilia,'');
			END IF;
		ELIF ptpoejecucion = '2' THEN --Tabla de digitalizacion_det

			SELECT count(*)
			INTO iCountexiste
			FROM bdidigital@coppelimg_tcp:dg_definicion
			WHERE empresa = pEmpresa
			AND cod_producto = pnum_producto;

			IF NVL(iCountexiste,0) > 0 THEN

				LET cCodproducto1 = substr(pnum_producto,1,2) || '01';
				LET cCodproducto2 = substr(pnum_producto,1,2) || '33';
				LET cCodproducto3 = substr(pnum_producto,1,2) || '34';
				
					SELECT count(b.cod_definicion)
					INTO iContcodproducto1
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = pnum_producto;
					--UNION ALL
					SELECT count (b.cod_definicion)
					INTO iContcodproducto2
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto1;
					--UNION ALL
					SELECT count(b.cod_definicion)
					INTO iContcodproducto3
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto2;
					--UNION ALL
					SELECT count(b.cod_definicion)
					INTO iContcodproducto4
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto3;				
					
					LET iTotregistros = iContcodproducto1 + iContcodproducto2 + iContcodproducto3 + iContcodproducto4;

				FOREACH
					SELECT skip o_solicitudes limit 10 b.cod_definicion, b.prod_nombre, a.secuencia, c.cod_docto, c.descripcion, b.cod_producto
					INTO cCodDefinicion, cProdNombre, cCodigoSec, cCodigoDocto, cDescripcion, cCod_producto
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = pnum_producto
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, a.secuencia, c.cod_docto, c.descripcion, b.cod_producto
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto1
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, a.secuencia, c.cod_docto, c.descripcion, b.cod_producto
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto2
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, a.secuencia, c.cod_docto, c.descripcion, b.cod_producto
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_producto = cCodproducto3

					RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
					NVL(cnombre_prod,''),NVL(dmonto_min_cred::CHAR(24),''),NVL(dmonto_max_cred::CHAR(24),''),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
					NVL(dsobretasa::CHAR(22),''),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc::CHAR(22),''),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
					NVL(cperiodo_plazo,''),NVL(iplazo_min_cred::CHAR(2),''),NVL(iplazo_max_cred::CHAR(2),''),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora::CHAR(22),''),
					NVL(dfactor_moratorio::CHAR(22),''),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso::CHAR(22),''),NVL(cfactor_piso,''),
					NVL(dtasa_piso::CHAR(22),''),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo::CHAR(22),''),NVL(cfactor_techo,''),NVL(dtasa_techo::CHAR(22),''),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
					NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones::CHAR(22),''),NVL(cmaneja_linea,''),NVL(idia_cuota::CHAR(2),''),NVL(igracia_calc_mora::CHAR(2),''),NVL(ctpsolicitud,''),NVL(csiglas,''),
					NVL(cfamilia,'') WITH RESUME;
				END FOREACH;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
					RETURN cCodRet, NVL(iTotregistros::CHAR(3),0),NVL(cnum_producto,''),NVL(cCodDefinicion,''),NVL(cProdNombre,''),NVL(cCodigoSec,''),NVL(cCodigoDocto,''),NVL(cDescripcion,''),NVL(cCod_producto,''),NVL(ccod_tipcred,''),
					NVL(cnombre_prod,''),NVL(dmonto_min_cred::CHAR(24),''),NVL(dmonto_max_cred::CHAR(24),''),NVL(cdivisa,''),NVL(cse_valoriza,''),NVL(ctipo_calculo,''),NVL(ctasa_fija_o_var,''),NVL(ccod_tasa_base,''),
					NVL(dsobretasa::CHAR(22),''),NVL(cfactor_sobretasa,''),NVL(ctipo_refinanc,''),NVL(dporcent_refinanc::CHAR(22),''),NVL(cpago_adic_sig_cuo,''),NVL(cperiod_pag_int,''),NVL(cperiod_pago_cap,''),
					NVL(cperiodo_plazo,''),NVL(iplazo_min_cred::CHAR(2),''),NVL(iplazo_max_cred::CHAR(2),''),NVL(ctasa_mora_adic,''),NVL(ccod_tasa_mora,''),NVL(cfact_sobret_mora,''),NVL(dsobretasa_mora::CHAR(22),''),
					NVL(dfactor_moratorio::CHAR(22),''),NVL(ccrev_tasa_var_per,''),NVL(idia_para_revisar,''),NVL(cpreautoriza,''),NVL(ctasa_base_piso,''),NVL(dsobretasa_piso::CHAR(22),''),NVL(cfactor_piso,''),
					NVL(dtasa_piso::CHAR(22),''),NVL(ctasa_base_techo,''),NVL(dsobretasa_techo::CHAR(22),''),NVL(cfactor_techo,''),NVL(dtasa_techo::CHAR(22),''),NVL(cband_prod,''),NVL(ccod_prod,''),NVL(ctpo_persona,''),
					NVL(ctipo_cliente,''),NVL(csegmentado,''),NVL(dpor_acciones::CHAR(22),''),NVL(cmaneja_linea,''),NVL(idia_cuota::CHAR(2),''),NVL(igracia_calc_mora::CHAR(2),''),NVL(ctpsolicitud,''),NVL(csiglas,''),
					NVL(cfamilia,'');
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Maria Elena Angulo Aispuro',
'FECHA: 23/09/2020',
'DESCRIPCION: Consultar los productos activos para consultar desde OFI y homologar la información en postgres.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_obtiene_comisiones_productos(pProducto CHAR(4), pSubProducto CHAR(4))	
	RETURNING 	CHAR(5) AS CodRet , 
				CHAR(2) AS Periodo_Plazo,
				CHAR(1) AS Comi_comision_anual,
				CHAR(7) AS Monto_comision_anual,
				CHAR(1) AS Comi_disposicion,
				CHAR(7) AS Monto_comi_disposicion,
				CHAR(1) AS Comi_gasto_cobranza,
				CHAR(7) AS Monto_gasto_cobranza,
                CHAR(1) AS Comi_aclaracion_no,
				CHAR(7) AS Monto_aclaracion_no,
				CHAR(1) AS Comi_liquidacion_antic,
				CHAR(7) AS Monto_liquidacion_antic,
				CHAR(1) AS Comi_apertura,
                CHAR(7) AS Monto_comis_apertura;
				
	-- Declaracion de variables
	DEFINE iSqlErr          		INTEGER;
	DEFINE isam_err         		INTEGER;
	DEFINE error_info       		VARCHAR(60);
	DEFINE cCodRet           		CHAR(5);
	DEFINE cPeriodoPlazo			CHAR(1);
	DEFINE cComi_comision_anual		CHAR(1);
	DEFINE dComi_disposicion       	DECIMAL(16);
	DEFINE dComi_gasto_cobranza		DECIMAL(16);
	DEFINE dComi_aclaracion_no    	DECIMAL(16);
	DEFINE dComi_liquidacion_antic 	DECIMAL(16);
	DEFINE cComi_apertura			CHAR(1);
	DEFINE dMonto_comision_anual	DECIMAL(20,2);
	DEFINE dMonto_comi_disposicion	DECIMAL(20,2);
	DEFINE dMonto_gasto_cobranza	DECIMAL(20,2);
	DEFINE dMonto_aclaracion_no		DECIMAL(20,2);
	DEFINE dMonto_liquidacion_antic	DECIMAL(20,2);
	DEFINE dMonto_comis_apertura	DECIMAL(20,2);
	DEFINE cCod_comision_anual		CHAR(4);
	DEFINE cCod_disposicion       	CHAR(4);
	DEFINE cCod_gasto_cobranza		CHAR(4);
	DEFINE cCod_aclaracion_no    	CHAR(4);
	DEFINE cCod_liquidacion_antic 	CHAR(4);
	DEFINE cCod_comis_apertura		CHAR(4);
	DEFINE cformaplica					CHAR(1);
	
	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET isam_err            		= 0;
	LET error_info          		= "";
	LET cCodRet              		= '00000';
	LET cPeriodoPlazo				='';
	LET cComi_comision_anual		='';
	LET dComi_disposicion			= 0;
	LET dComi_gasto_cobranza		= 0;
	LET dComi_aclaracion_no			= 0;
	LET dComi_liquidacion_antic		= 0;
	LET cComi_apertura				= '';
	LET dMonto_comision_anual		= 0;
	LET dMonto_comi_disposicion		= 0;
	LET dMonto_gasto_cobranza		= 0;
	LET dMonto_aclaracion_no		= 0;
	LET dMonto_liquidacion_antic	= 0;
	LET dMonto_comis_apertura		= 0;
	LET cCod_comision_anual			= '';
	LET cCod_disposicion			= '';
	LET cCod_gasto_cobranza			= '';
	LET cCod_aclaracion_no			= '';
	LET cCod_liquidacion_antic		= '';
	LET cCod_comis_apertura			= '';
	LET cformaplica						= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','','','','','','','','','';
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtiene_comisiones_productos.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pProducto <> '' AND pSubProducto = '' THEN
			SELECT d.periodo_plazo,d.cobro_comision_anual,d.comi_disposicion_efect,d.comi_gasto_cobranza,d.comi_aclaracion_no,d.comi_liquidacion_antic,cobro_comis_apertura,
				   d.cod_comision_anualidad,d.cod_comision_efectivo,d.cod_comi_gasto_cobranza,d.cod_comi_aclaracion_no,d.cod_comi_liquidacion_antic,cod_comision_apertura	   
			INTO cPeriodoPlazo,cComi_comision_anual,dComi_disposicion,dComi_gasto_cobranza,dComi_aclaracion_no,dComi_liquidacion_antic,cComi_apertura,
				 cCod_comision_anual,cCod_disposicion,cCod_gasto_cobranza,cCod_aclaracion_no,cCod_liquidacion_antic,cCod_comis_apertura
			FROM bdicred:sd_definicion d
			WHERE d.num_producto = pProducto;
		ELIF pProducto <> '' AND pSubProducto <> '' THEN
			SELECT d.periodo_plazo,d.cobro_comision_anual,d.comi_disposicion_efect,d.comi_gasto_cobranza,d.comi_aclaracion_no,d.comi_liquidacion_antic,d.cobro_comis_apertura,
				   d.cod_comision_anualidad,d.cod_comision_efectivo,d.cod_comi_gasto_cobranza,d.cod_comi_aclaracion_no,d.cod_comi_liquidacion_antic,cod_comision_apertura	   
			INTO cPeriodoPlazo,cComi_comision_anual,dComi_disposicion,dComi_gasto_cobranza,dComi_aclaracion_no,dComi_liquidacion_antic,cComi_apertura,
				 cCod_comision_anual,cCod_disposicion,cCod_gasto_cobranza,cCod_aclaracion_no,cCod_liquidacion_antic,cCod_comis_apertura
			FROM bdicred:sd_subproducto d
			WHERE id_subproducto = pSubProducto;
		END IF;
		IF cComi_comision_anual = '1' THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_comision_anual;
			IF NVL(cformaplica,'') = '1' THEN
				SELECT monto INTO dMonto_comision_anual FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_comision_anual;
			ELSE 
				SELECT apli_factor INTO dMonto_comision_anual FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_comision_anual;						
			END IF; 
		END IF;
		IF dComi_disposicion = 1 THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = 	cCod_disposicion;	
			IF NVL(cformaplica,'') = '1' THEN
				SELECT monto INTO dMonto_comi_disposicion FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_disposicion;
			ELSE
				SELECT apli_factor INTO dMonto_comi_disposicion FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_disposicion;
			END IF;
		END IF;
		IF dComi_gasto_cobranza = 1 THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = 	cCod_gasto_cobranza;	
			IF NVL(cformaplica,'') = '1' THEN		
				SELECT monto INTO dMonto_gasto_cobranza FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_gasto_cobranza;
			ELSE
				SELECT apli_factor INTO dMonto_gasto_cobranza FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_gasto_cobranza;
			END IF;
		END IF;
		IF dComi_aclaracion_no = 1 THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = 	cCod_aclaracion_no;	
			IF NVL(cformaplica,'') = '1' THEN		
				SELECT monto INTO dMonto_aclaracion_no FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_aclaracion_no;
			ELSE
				SELECT apli_factor INTO dMonto_aclaracion_no FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_aclaracion_no;
			END IF;			
		END IF;
		IF dComi_liquidacion_antic = 1 THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = 	cCod_liquidacion_antic;	
			IF NVL(cformaplica,'') = '1' THEN		
				SELECT monto INTO dMonto_liquidacion_antic FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_liquidacion_antic;
			ELSE
				SELECT apli_factor INTO dMonto_liquidacion_antic FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_liquidacion_antic;
			END IF;				
		END IF;
		IF cComi_apertura = '1' THEN
			SELECT form_aplica INTO cformaplica FROM bdicred:sd_tpcomis WHERE cod_comis = 	cCod_comis_apertura;	
			IF NVL(cformaplica,'') = '1' THEN		
				SELECT monto INTO dMonto_comis_apertura FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_comis_apertura;
			ELSE
				SELECT apli_factor INTO dMonto_comis_apertura FROM bdicred:sd_tpcomis WHERE cod_comis = cCod_comis_apertura;
			END IF;			
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		END IF;
		
		RETURN cCodRet,cPeriodoPlazo,cComi_comision_anual,dMonto_comision_anual,dComi_disposicion,dMonto_comi_disposicion,dComi_gasto_cobranza,dMonto_gasto_cobranza,
			   dComi_aclaracion_no,dMonto_aclaracion_no,dcomi_liquidacion_antic,dMonto_liquidacion_antic,cComi_apertura,dMonto_comis_apertura;

	END;
END PROCEDURE
DOCUMENT
'Modificacion: Se crea el procedimiento almacenado "sp_obtiene_comisiones_productos" para obtener las comisiones de los productos seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_obtiene_descripcion_productos (pEmpresa CHAR(3), pNumProducto CHAR(4))	
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(4) AS Num_Producto,
				CHAR(40) AS Nombre_Producto,
				CHAR(4) AS Id_Subproducto,
				CHAR(40) AS Desc_Subproducto;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE cSubProducto					CHAR(2);
	DEFINE cNumProducto					CHAR(4); 
	DEFINE cNombreProducto				CHAR(40); 
	DEFINE cIdSubproducto				CHAR(4); 
	DEFINE cDescSubproducto				CHAR(40);

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cSubProducto        		= '';
	LET cNumProducto        		= '';
	LET cNombreProducto        		= '';
	LET cIdSubproducto        		= '';
	LET cDescSubproducto       		= '';

	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumProducto,cNombreProducto,cIdSubproducto,cDescSubproducto;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/ifxsif01/JL/sp_obtiene_descripcion_productos.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pNumProducto,'') = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet,cNumProducto,cNombreProducto,cIdSubproducto,cDescSubproducto;
		ELSE
			--Verifica si el producto seleccionado es producto padre o SubProducto
			SELECT num_producto,nombre_prod 
			INTO cNumProducto,cNombreProducto
			FROM bdicred:"informix".sd_definicion 
			WHERE empresa = pEmpresa
			AND num_producto = pNumProducto;
			
			IF NVL(cNumProducto,'') = '' AND NVL(cNombreProducto,'') = '' THEN
				LET cSubProducto = TO_NUMBER(SUBSTR(TRIM(pNumProducto), 3,4));
				
				SELECT num_producto,nombre_prod,id_subproducto,desc_subproducto
				INTO cNumProducto,cNombreProducto,cIdSubproducto,cDescSubproducto
				FROM bdicred:"informix".sd_subproducto 
				WHERE id_subproducto = cSubProducto;
			END IF;
			
			RETURN cCodRet,cNumProducto,cNombreProducto,cIdSubproducto,cDescSubproducto;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,cNumProducto,cNombreProducto,cIdSubproducto,cDescSubproducto;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtiene_descripcion_productos" para verificar el producto seleccionado por el usuario y obtiene su descripcion',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_obtiene_tasas_diferenciadas(pProducto CHAR(4), pIdSubProducto CHAR(4), pTipoEjecucion CHAR(1))	
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(2) AS Grupo,
				decimal(11,6) AS Modelo_Hit_Bueno,
				decimal(11,6)AS Modelo_Hit_Malo,
				decimal(11,6)AS Modelo_NO_Hit;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          		INTEGER;
	DEFINE isam_err         		INTEGER;
	DEFINE error_info       		VARCHAR(60);
	DEFINE cCodRet           		CHAR(5);
	DEFINE cGrupo					CHAR(2);
	DEFINE dTasaOrdinaria1			decimal(11,6);
	DEFINE dTasaOrdinaria2			decimal(11,6);
	DEFINE dTasaOrdinaria3			decimal(11,6);
	
	-- Asignacion variables
	LET iSqlErr             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET cCodRet              	= '00000';
	LET cGrupo					= '';
	LET dTasaOrdinaria1			= 0;
	LET dTasaOrdinaria2			= 0;
	LET dTasaOrdinaria3			= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','';
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtiene_tasas_productos.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN
			IF pProducto <> '' AND pIdSubProducto = '' THEN
				---Tasa de interes ordinaria
				FOREACH 
					SELECT a.grupo, a.tasa_int_ordinaria, b.tasa_int_ordinaria, c.tasa_int_ordinaria
					INTO cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3
					FROM bdicred:sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1')
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X')
					WHERE a.num_producto = pProducto AND a.evalua_cc = '0'
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3 WITH resume;
				END FOREACH;
			ELIF pProducto <> '' AND pIdSubProducto <> '' THEN
				---Tasa de interes ordinaria SubProducto
				FOREACH 
					SELECT a.grupo, a.tasa_int_ordinaria, b.tasa_int_ordinaria, c.tasa_int_ordinaria
					INTO cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3
					FROM bdicred:sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1')
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X')
					WHERE a.num_producto = pProducto AND a.id_subproducto = pIdSubProducto AND a.evalua_cc = '0'
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3 WITH resume;
				END FOREACH;
			END IF;
		ELIF pTipoEjecucion = '2' THEN
			IF pProducto <> '' AND pIdSubProducto = '' THEN
				---Tasa de interes moratoria
				FOREACH
					SELECT a.grupo, a.tasa_int_moratoria, b.tasa_int_moratoria, c.tasa_int_moratoria
					INTO cGrupo,dTasaOrdinaria1,dTasaOrdinaria2,dTasaOrdinaria3
					FROM bdicred:sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1')
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X')
					WHERE a.num_producto = pProducto AND a.evalua_cc = '0'
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3 WITH resume;
				END FOREACH;
			ELIF pProducto <> '' AND pIdSubProducto <> '' THEN
				---Tasa de interes moratoria SubProducto
				FOREACH
					SELECT a.grupo, a.tasa_int_moratoria, b.tasa_int_moratoria, c.tasa_int_moratoria
					INTO cGrupo,dTasaOrdinaria1,dTasaOrdinaria2,dTasaOrdinaria3
					FROM bdicred:sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1')
					INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X')
					WHERE a.num_producto = pProducto AND a.id_subproducto = pIdSubProducto AND a.evalua_cc = '0'
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3 WITH resume;
				END FOREACH;
			END IF;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,cGrupo, dTasaOrdinaria1, dTasaOrdinaria2, dTasaOrdinaria3;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Modificacion: Se crea el procedimiento almacenado "sp_obtiene_tasas_productos" para obtener las tasas de interes de los productos seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_cons_param_banderaprod (  pEmpresa CHAR(3), pUsuario CHAR(8), pTipoBandera CHAR(1), pBandera CHAR(50), pNum_Producto CHAR(4), pcve_canal SMALLINT)			 
		RETURNING CHAR(6) AS codret,
				  CHAR(100) AS descodret,
				  CHAR (1) AS banderaactydesact,
				  CHAR (1) AS numobligados,
				  CHAR (1) AS capturaobligada,
				  CHAR(1) AS idgarantia,
				  CHAR(16) AS aforogarantia,
				  CHAR(20) AS cuenta_concentradora;
	--*TIPOS DE EJECUCIÓN**************
	--* 1 - Bandera Documentos a imprimir
	--*	2 - Bandera Mensajes a activar
	--* 3 - Bandera Canal de Operacion por producto
	--* 4 - Bandera Obligado Solidario
	--* 5 - Bandera Garantias
	--* 6 - Bandera Cuenta Concentradora
	--* 7 - Bandera Activos Prestamo
	--* 8 - Bandera Activos Lineas Prestamo
	--* 9 - Bandera Activos Tarjetas de Crédito

	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 						CHAR(6);
	DEFINE cdesc_codret					CHAR(100);
	DEFINE iSqlErr 						INTEGER;	
	DEFINE iIsamErr     				INTEGER;
	DEFINE cErrorInfo   				VARCHAR(255,1);	
	DEFINE cEmpresa         			CHAR(3);
	DEFINE cUsuario						CHAR(8);
	DEFINE cBandera 					CHAR(50);
	DEFINE iBandera						INTEGER;
	DEFINE cTipoBandera 				CHAR(1);
    DEFINE cNum_Producto    			CHAR(4);
	DEFINE v_ya_existe 					SMALLINT;
	DEFINE sbanderaactydesact			SMALLINT;
    DEFINE cnum_obligados             	CHAR(1);
    DEFINE ccaptura_obligatoria       	CHAR(1);
	DEFINE scve_canal 					SMALLINT;
	DEFINE sid_evento 					SMALLINT;	
    DEFINE sidgarantia                	SMALLINT;
    DEFINE dporcentajeaforo           	DECIMAL(14,2);	
	DEFINE cidcta_concentradora 		CHAR(1);
	DEFINE ccta_concentradora 			CHAR(20);	
		-----------


	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************	

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iIsamErr        		= 0;
	LET cErrorInfo      		= "";	
	LET cdesc_codret = '';
	LET cEmpresa = pEmpresa;        	
	LET cUsuario = pUsuario;
	LET cBandera = pBandera;
	LET cTipoBandera = pTipoBandera;	
	LET cNum_Producto = pNum_Producto;  
	LET v_ya_existe			 = 0;
	LET sbanderaactydesact   = 0;
    LET cnum_obligados              = '';
    LET ccaptura_obligatoria        = '';
	LET scve_canal  = pcve_canal;
	LET sid_evento = 0;	
    LET sidgarantia                 = 0;
    LET dporcentajeaforo            = 0;
	LET cidcta_concentradora = '';
	LET ccta_concentradora = '';		 
	-------	
	 
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;	
				LET cdesc_codret = cErrorInfo;			
				RETURN cCodRet,cdesc_codret,sbanderaactydesact, cnum_obligados, ccaptura_obligatoria, sidgarantia, dporcentajeaforo, ccta_concentradora;
	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_cons_param_banderaprod.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa = '' OR pTipoBandera = '' OR (pBandera = '' AND cTipoBandera NOT IN('4','6','7','8','9')) OR pUsuario = '' OR pNum_Producto = '' OR (pcve_canal = '' AND cTipoBandera IN('2','3')) THEN
			LET cCodRet = '00001';
			LET cdesc_codret = 'Faltan parámetros de Entrada';	
			RETURN cCodRet,cdesc_codret,sbanderaactydesact, cnum_obligados, ccaptura_obligatoria, sidgarantia, dporcentajeaforo, ccta_concentradora;
		END IF;
		
		-- Bandera Documentos a imprimir
		IF cTipoBandera = '1' THEN 
			LET iBandera = cBandera::INTEGER;
			SELECT count(cod_docto) INTO v_ya_existe
			FROM bdicred:"informix".sd_doctosimprimexproducto WHERE num_producto = cNum_Producto AND cod_docto::INTEGER = iBandera;
			
			IF NVL(v_ya_existe,0) = 1 THEN
				SELECT cantidad INTO sidgarantia --copias de documento
				FROM bdicred:"informix".sd_doctosimprimexproducto WHERE num_producto = cNum_Producto AND cod_docto::INTEGER = iBandera;
			
				LET sbanderaactydesact = v_ya_existe;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF;
		END IF;
		-- Bandera Mensajes a activar
		IF cTipoBandera = '2' THEN 
			LET sid_evento = cBandera::SMALLINT;
			SELECT count(id_evento) INTO v_ya_existe
			FROM bdicred:"informix".sd_activacion_sms_email WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento = sid_evento;
			
			IF NVL(v_ya_existe,0) >= 1 THEN
				LET sbanderaactydesact = 1;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF;  							
		END IF;
		-- Bandera Canal de Operacion por producto
		IF cTipoBandera = '3' THEN 
			LET iBandera = cBandera::INTEGER;
			SELECT count(cod_operaciones) INTO v_ya_existe
			FROM bdicred:"informix".sd_operaciones_canal WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND cod_operaciones = iBandera;

			IF NVL(v_ya_existe,0) >= 1 THEN
				LET sbanderaactydesact = 1;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF; 										
			
		END IF;
		-- Bandera Obligado solidario
		IF cTipoBandera = '4' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT obligado_solidario, num_obligados, captura_obligatoria 
				INTO sbanderaactydesact, cnum_obligados, ccaptura_obligatoria
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT obligado_solidario, num_obligados, captura_obligatoria 
					INTO sbanderaactydesact, cnum_obligados, ccaptura_obligatoria
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			
			END IF;  
		END IF;
		-- Bandera Garantías
		IF cTipoBandera = '5' THEN 		
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT garantias, idgarantia, porcentajeaforo 
				INTO sbanderaactydesact, sidgarantia, dporcentajeaforo
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
				
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT garantias, idgarantia, porcentajeaforo 
					INTO sbanderaactydesact, sidgarantia, dporcentajeaforo
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			
			END IF;  
		END IF;	
		-- Bandera Cta Concentradora
		IF cTipoBandera = '6' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT NVL(idcta_concentradora,'0'), NVL(cta_concentradora,'') 
				INTO sbanderaactydesact, ccta_concentradora
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
				
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT NVL(idcta_concentradora,'0'), NVL(cta_concentradora,'') 
					INTO sbanderaactydesact, ccta_concentradora
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			END IF;									
		END IF;	
		-- Bandera si pertenece a Familia Préstamo
		IF cTipoBandera = '7' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '002' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;			
		-- Bandera si pertenece a Familia Línea de Crédito
		IF cTipoBandera = '8' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '003' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				/*SELECT plazo_linea
				INTO sidgarantia
				FROM "informix".sd_definicion
				WHERE familia = '003' AND num_producto = cNum_Producto;	*/
				
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;		
		-- Bandera si pertenece a Familia Tarjetas de Crédito
		IF cTipoBandera = '9' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '001' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;	 		
		RETURN cCodRet,cdesc_codret,NVL(sbanderaactydesact,0), NVL(cnum_obligados,'0'), NVL(ccaptura_obligatoria,'0'), NVL(sidgarantia::CHAR(1),'0'), NVL(dporcentajeaforo::CHAR(16),'0.0'), NVL(ccta_concentradora,'');
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Maria Elena Angulo Aispuro',
'FECHA: 20/08/2020',
'DESCRIPCION: Consultar parametros de banderas activas de caracteristicas de productos para consultar desde OFI.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_ce_aplicadisposicion(v_num_credito CHAR(20), v_num_cuenta CHAR(20), v_importe MONEY (14,2), v_usuario CHAR(8), v_tipo_prod CHAR(2), v_tipo_disp CHAR(1))
RETURNING CHAR(5), money(14,2), CHAR (16);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para disposiciÃ??Ã?Â³n de crÃ??Ã?Â©dito empresarial - OriÃ??Ã?Â³n
    -- Autor: SADCV
    -- Fecha: 30/09/2013
	-- ModificaciÃ??Ã?Â³n: 01/08/2016
	-- ValidaciÃ??Ã?Â³n de disposiciÃ??Ã?Â³n
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	
	DEFINE v_importe_1		MONEY(14,2);
	DEFINE v_sdo_actual		MONEY(14,2);
	DEFINE v_importe_ap		MONEY(14,2);
	
	DEFINE v_FolioSUC       CHAR(16);
	DEFINE v_FolioSUC_1     CHAR(16);
    DEFINE v_fecha_folio    CHAR(10);
	
	DEFINE DCodret_a 		CHAR (5);
	DEFINE DTranret_c		CHAR (4);
	DEFINE DFechoy_c		DATE ;
	DEFINE DVsdodisp_c 		MONEY (14,2);
	DEFINE DVmontoret_c		MONEY (14,2);
	
	DEFINE v_count 			INTEGER;
	DEFINE v_transacc       CHAR(5);
	DEFINE v_referencia     CHAR (25);
	DEFINE v_status_disposicion	CHAR (1);
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET v_importe_1			= '';
	LET v_sdo_actual		= '';
	LET v_importe_ap		= '';

	LET v_FolioSUC			= '';
	LET v_FolioSUC_1		= '';
    LET v_fecha_folio       = '';
	
	LET DCodret_a 			= '';
	
	LET v_count 			= 0;
	
	LET v_transacc = '';
	LET v_referencia = '';
	
		
   -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
	--SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicadisposicion"||TRIM(v_num_cuenta)||".out";
	--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            --ROLLBACK WORK;
            RETURN cCodRet, v_importe, v_FolioSUC;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//
	
	--> ValidaciÃ??Ã?Â¬on de cuentas eje.
	
	SELECT status_disposicion
	INTO v_status_disposicion
	FROM sd_ce_cuentas_bf
	WHERE num_cta_eje = v_num_cuenta;
	
	
	--IF v_num_cuenta IN ('12000004071','12000004101','12000004098','12000004144','27000000146','12000004063','10423264514', '10423693881') THEN  ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje
	IF v_status_disposicion = '0' THEN
		
		LET cCodRet = '00000';
	
	ELSE   ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje
	
	--> AsignaciÃ??Ã?Â³n de transacciones para cargos a cuentas de cheques. 
	
		IF (v_tipo_prod = '01') THEN  ----------------------------------------------------------------------------------->>> Linea Credito
		
			LET v_transacc = '3323';
			LET v_referencia = 'No Credito Revolvente ';
		
			ELSE
		
			LET v_transacc = '0337';
			LET v_referencia = 'No Credito Empresarial ';
		
		END IF;
	

	
	IF (v_tipo_disp = '0') THEN   --> Primer envÃ??Ã?Â­o 
	
		SET ISOLATION DIRTY READ;

		LET v_fecha_folio  = substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);

		LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_num_credito),8,'0');
		
		CALL bdicheq:abono_ref ('001', '9250', v_usuario, v_transacc, '0000', v_FolioSUC, v_num_cuenta, v_num_credito, v_importe, v_importe, 0, 0, 0, '01', v_referencia||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
		RETURNING DCodret_a;

		
	ELIF (v_tipo_disp = '1') THEN --> Error por respuesta tardia interact
	
		SELECT COUNT (*), folio_suc, monto_tot
		INTO v_count, v_FolioSUC_1, v_importe_1
		FROM bdicheq:sc_movdia WHERE empresa = '001' AND transacc = v_transacc AND cuenta = v_num_cuenta AND monto_tot = v_importe AND cancelad = '' AND referencia = v_referencia||LPAD(TRIM(v_num_credito),12,'0')
		GROUP BY folio_suc, monto_tot;

		LET v_FolioSUC_1 = v_FolioSUC_1;
		LET v_importe_1 = v_importe_1; 
		LET v_count = v_count;
		
			IF (v_count >= 1)  THEN		
						
				LET v_importe 	= v_importe_1;
				LET v_FolioSUC 	= v_FolioSUC_1;
				LET cCodRet 	= '000'; 
				
					ELSE
			
				SET ISOLATION DIRTY READ;

				LET v_fecha_folio  = substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);

				LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_num_credito),8,'0');
				
				CALL bdicheq:abono_ref ('001', '9250', v_usuario, '0337', '0000', v_FolioSUC, v_num_cuenta, v_num_credito, v_importe, v_importe, 0, 0, 0, '01', 'No Credito Empresarial '||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
				RETURNING DCodret_a;
			
			END IF;
		
    	END IF;
		
	END IF;   ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje 
	
	
	-->
	-- LET v_importe 	= v_importe;
	-- LET v_FolioSUC 	= v_FolioSUC;
	-- LET cCodRet 	= '000'; 
	
	LET cCodRet = LPAD (TRIM(DCodret_a), 5, '0');
	
    RETURN cCodRet, v_importe, v_FolioSUC;
    
	END;
	
END PROCEDURE;