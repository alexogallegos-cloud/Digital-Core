CREATE PROCEDURE "informix".sp_genera_sol_cps_exp(P_EMPRESA CHAR(3),o_numsol CHAR(20),o_numcte CHAR(20),
								o_producto CHAR(4),o_tipo_prod char (1),o_sucursal char (4),o_monto DECIMAL (18,2))
RETURNING CHAR(6);

	--- o_monto		Es el monto solicitado que se captura en el proceso de originacion.

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

DEFINE cCodRet					CHAR(6); 
DEFINE vsqlerr                	INTEGER;

--- RQM 09 530

DEFINE rev_user_insert 			CHAR(30);
DEFINE scod_ret_rev				CHAR(5);
DEFINE aux_sol_revalua			CHAR (20);
DEFINE scod_ret_rev2			CHAR(5);
DEFINE aux_numcte_ref			CHAR(20);
DEFINE aux_tipo_relacion		CHAR(2);
DEFINE aux_nombre_ref			CHAR(104);
DEFINE aux_parentesco			CHAR(2);
DEFINE aux_telefono_ref			CHAR(13);
DEFINE auxRev_tp_ingreso		INTEGER;
DEFINE auxRev_periodo_ingreso	INTEGER;
DEFINE rev_telefono_ref1		CHAR(13);
DEFINE rev_telefono_ref2		CHAR(13);
DEFINE bandera_cancelacion 		INTEGER;
DEFINE scod_ret_rev3			CHAR (5);
DEFINE scod_ret_rev4			CHAR (5);

DEFINE	rev_situacion_pago       	DECIMAL(5,2);
DEFINE	rev_situacion_credito    	CHAR(1);
DEFINE	rev_meses_historia       	SMALLINT;
DEFINE	rev_fuente               	CHAR(1);
DEFINE	rev_evalua_cc            	CHAR(1);
DEFINE	rev_motivo_cc            	VARCHAR(100);
DEFINE	rev_ingreso_mensual      	MONEY;
DEFINE	rev_tp_ingreso           	INTEGER;
DEFINE	rev_periodo_ingreso      	INTEGER;
DEFINE	rev_pago_minimo          	MONEY;
DEFINE	rev_linea_tienda         	MONEY;
DEFINE	rev_causa                	SMALLINT;
DEFINE	rev_puntualidad          	CHAR(2);
DEFINE	rev_saldoropa            	MONEY;
DEFINE	rev_saldomuebles         	MONEY;
DEFINE	rev_saldoprestamos       	MONEY;
DEFINE	rev_vencidoropa          	MONEY;
DEFINE	rev_vencidomuebles       	MONEY;
DEFINE	rev_vencidoprestamos     	MONEY;
DEFINE	rev_abonomensualropa     	MONEY;
DEFINE	rev_abonomensualmuebles  	MONEY;
DEFINE	rev_abonomensualprestamos	MONEY;
DEFINE	rev_fecha_ultima_compra  	DATE;
DEFINE	rev_secuenciaconsulta    	SMALLINT;
DEFINE	rev_origen               	CHAR(1);
DEFINE	rev_smbc                 	INTEGER;
DEFINE	rev_salario_minimo       	DECIMAL(14,2) ;
DEFINE	rev_compromisos_bco      	DECIMAL(14,2) ;
DEFINE	rev_situacion_especial   	CHAR(1);
DEFINE	rev_causa_situacion      	SMALLINT;
DEFINE	rev_grupo                	CHAR(1);
DEFINE	rev_ingreso_lc           	DECIMAL(18,2);
DEFINE	rev_valor_cma            	DECIMAL(18,2);
DEFINE	rev_valor_tab            	DECIMAL(18,2);
DEFINE	rev_linea_teorica        	DECIMAL(18,2);
DEFINE	rev_tipo_movimiento      	CHAR(1);
DEFINE	rev_num_solicitud_ref    	CHAR(20);
DEFINE	rev_monto_hipoteca       	DECIMAL(14,2);
DEFINE	rev_fechaultimopago      	CHAR(13);
DEFINE	rev_prestamoautorizado   	CHAR(1);
DEFINE	rev_montoautorizado      	INT8;
DEFINE	rev_represtamo           	INT8;

DEFINE	rev_saldoaire            	 MONEY;  ---Autor: Jesus Tapia(INICIO) 	27/09/2021
DEFINE	rev_vencidoaire              MONEY;
DEFINE	rev_abonomensualaire     	 MONEY;
DEFINE	rev_saldoafiliados           MONEY;
DEFINE	rev_vencidoafiliados         MONEY;
DEFINE	rev_abonomensualafiliados    MONEY;
DEFINE	rev_saldoreestructura        MONEY;
DEFINE	rev_vencidoreestructura      MONEY;
DEFINE	rev_abonomensualreestructura MONEY;
DEFINE	rev_scorepuntualidad		 INTEGER;
DEFINE sc_seccion      				SMALLINT;
DEFINE sc_grupo        				SMALLINT;
DEFINE sc_elemento     				SMALLINT;
DEFINE sc_tpo_persona  				CHAR(2);
DEFINE sc_valor        				DECIMAL(10,4);
DEFINE stS_prevP					CHAR(2);
DEFINE pMontosol                    DECIMAL(18,2);
DEFINE soLorigen                    CHAR(20);


------Referencias
DEFINE cps_cSucursal 					CHAR(4);
DEFINE cps_cApellPaterno 				CHAR(26);
DEFINE cps_cApellMaterno 				CHAR(26);
DEFINE cps_cNombre1 					CHAR(26);
DEFINE cps_cNombre2 					CHAR(26);
DEFINE cps_cRfc 						CHAR(13);
DEFINE cps_dtFechaNac 					DATE;
DEFINE cps_cCurp 						CHAR(20);
DEFINE cps_cSexo 						CHAR(1);
DEFINE cps_cEstadoCivil 				CHAR(2);
DEFINE cps_cNacionalidad 				CHAR(3);
DEFINE cps_cNoFm 						CHAR(18);
DEFINE cps_cCodigoIden 					CHAR(2);
DEFINE cps_cNumIdentif 					CHAR(30);
DEFINE cps_cPersDomicilio 				CHAR(2);
DEFINE cps_cEmail 						CHAR(60);
DEFINE cps_cParentesco 					CHAR(2);
DEFINE cps_cApellCasada 				CHAR(26);
DEFINE cps_cNumcteRef 					CHAR(20);
DEFINE cps_cNumCteBanco 				CHAR(20);
DEFINE cps_cUsuario 					CHAR(8);
DEFINE cps_dtFecha 						DATE;
DEFINE cps_iContadorRef   				INTEGER;
DEFINE cps_iSecuencia2   				INTEGER;

DEFINE scod_ret_ref						CHAR (6);

DEFINE rev_limiteinf 					DECIMAL(14,2);
DEFINE pCodret                          CHAR (6);
DEFINE cCanal_sol						CHAR (2);

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************

LET cCodRet					= "00000";
LEt vsqlerr					= 0;

LET rev_user_insert 		= '';
LET scod_ret_rev 			= '';
LET aux_sol_revalua			= '';
LET scod_ret_rev2			= '';
LET aux_numcte_ref			= '';
LET aux_tipo_relacion		= '';
LET aux_nombre_ref			= '';
LET aux_parentesco			= '';
LET aux_telefono_ref 		= '';
LET auxRev_tp_ingreso 		= 0;
LET auxRev_periodo_ingreso 	= 0;
LET rev_telefono_ref1 		= '';
LET rev_telefono_ref2 		= '';
LET bandera_cancelacion 	= 0;
LET scod_ret_rev3 			= '';
LEt scod_ret_rev4			= '';


LET rev_situacion_pago        = 0;
LET rev_situacion_credito     = '';
LET rev_meses_historia        = 0;
LET rev_fuente                = '';
LET rev_evalua_cc             = '';
LET rev_motivo_cc             = '';
LET rev_ingreso_mensual       = 0;
LET rev_tp_ingreso            = 0;
LET rev_periodo_ingreso       = 0;
LET rev_pago_minimo           = 0;
LET rev_linea_tienda          = 0;
LET rev_causa                 = '';
LET rev_puntualidad           = '';
LET rev_saldoropa             = 0;
LET rev_saldomuebles          = 0;
LET rev_saldoprestamos        = 0;
LET rev_vencidoropa           = 0;
LET rev_vencidomuebles        = 0;
LET rev_vencidoprestamos      = 0;
LET rev_abonomensualropa      = 0;
LET rev_abonomensualmuebles   = 0;
LET rev_abonomensualprestamos = 0;
LET rev_fecha_ultima_compra   = '';
LET rev_secuenciaconsulta     = '';
LET rev_origen                = '';
LET rev_smbc                  = 0;
LET rev_salario_minimo        = 0;
LET rev_compromisos_bco       = 0;
LET rev_situacion_especial    = '';
LET rev_causa_situacion       = '';
LET rev_grupo                 = '';
LET rev_ingreso_lc            = 0;
LET rev_valor_cma             = 0;
LET rev_valor_tab             = 0;
LET rev_linea_teorica         = 0;
LET rev_tipo_movimiento       = '';
LET rev_num_solicitud_ref     = '';
LET rev_monto_hipoteca        = 0;
LET rev_fechaultimopago       = '';
LET rev_prestamoautorizado    = '';
LET rev_montoautorizado       = 0;
LET rev_represtamo            = 0;

LET rev_saldoaire 				 = 0; ---Autor: Jesus Tapia(INICIO) 	27/09/2021
LET rev_vencidoaire 			 = 0;
LET rev_abonomensualaire 		 = 0;
LET rev_saldoafiliados 			 = 0;
LET rev_vencidoafiliados 		 = 0;
LET rev_abonomensualafiliados    = 0;
LET rev_saldoreestructura 		 = 0;
LET rev_vencidoreestructura 	 = 0;
LET rev_abonomensualreestructura = 0;
LET rev_scorepuntualidad		 = 0; ---Autor: Jesus Manuel(FINAL)	27/09/2021

LET sc_seccion 				  = 0;
LET sc_grupo				  = 0;
LET sc_elemento 			  = 0;
LET sc_tpo_persona 			  = '';
LET sc_valor 				  = 0;


------Referencias
LET cps_cSucursal  				= "";
LET cps_cApellPaterno  			= "";
LET cps_cApellMaterno  			= "";
LET cps_cNombre1  				= "";
LET cps_cNombre2  				= "";
LET cps_cRfc  					= "";
LET cps_dtFechaNac 				= DATE(1);
LET cps_cCurp  					= "";
LET cps_cSexo  					= "";
LET cps_cEstadoCivil  			= "";
LET cps_cNacionalidad  			= "";
LET cps_cNoFm  					= "";
LET cps_cCodigoIden  			= "";
LET cps_cNumIdentif  			= "";
LET cps_cPersDomicilio  		= "";
LET cps_cEmail  				= "";
LET cps_cParentesco  			= "";
LET cps_cApellCasada  			= "";
LET cps_cNumcteRef  			= "";
LET cps_cNumCteBanco 			= "";
LET cps_cUsuario  				= "";
LET cps_dtFecha 				= DATE(1);
LET cps_iContadorRef 			= 0;
LET cps_iSecuencia2 			= 0;

LET scod_ret_ref				= '';
LEt rev_limiteinf				= 0;
LET pCodret                     ='000000';
LET stS_prevP					='';
LET pMontosol                   =0;
LET soLorigen                   ='';
LET cCanal_sol					= '';
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   

set isolation to dirty read;
set lock mode to wait 3;

   
	BEGIN

		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET cCodRet=vsqlerr;
				CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, '0106', cCodRet, "Error sp_genera_sol_cps " ||TRIM(o_numcte)||' '||TRIM (aux_sol_revalua), '02') 
					Returning  scod_ret_ref;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

	--    SET DEBUG FILE TO '/informix/sp_genera_sol_cps.out';
	--    TRACE ON;
			
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

			SELECT user_insert
				INTO rev_user_insert
			FROM bdisolic:ss_solicitudes 
			where num_solicitud = o_numsol;
	
			---- Genera solicitud nueva
			EXECUTE PROCEDURE bdisolic:asigna_numsol (p_empresa,o_producto)
				INTO scod_ret_rev, aux_sol_revalua;
			---  Graba en las tablas de precalificacion	

			IF length(aux_sol_revalua) = 12 then			
				EXECUTE PROCEDURE "informix".graba_sol_precalificada (p_empresa,aux_sol_revalua,o_numcte,
							o_sucursal,o_tipo_prod,o_producto,rev_user_insert)
					INTO scod_ret_rev2;
			END IF;

			IF scod_ret_rev::INTEGER <> 0 OR scod_ret_rev2::INTEGER <> 0 THEN
				LET cCodRet = '0001';
				RETURN cCodRet;
			END IF;

			--- Hereda datos de originacion de la solicitud origen
			SELECT situacion_pago,situacion_credito,meses_historia,fuente,evalua_cc,motivo_cc,ingreso_mensual,tp_ingreso,periodo_ingreso,pago_minimo,linea_tienda,causa,
				puntualidad,saldoropa,saldomuebles,saldoprestamos,vencidoropa,vencidomuebles,vencidoprestamos,abonomensualropa,abonomensualmuebles,abonomensualprestamos,
				fecha_ultima_compra,secuenciaconsulta,origen,smbc,salario_minimo,compromisos_bco,situacion_especial,causa_situacion,grupo,ingreso_lc,valor_cma,valor_tab,
				linea_teorica,tipo_movimiento,num_solicitud_ref,monto_hipoteca,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,
				vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados, abonomensualafiliados, saldototalafiliados, vencidototalreestructura,abonomensualreestructura, saldototalreestructura, scorepuntualidad
			INTO rev_situacion_pago,rev_situacion_credito,rev_meses_historia,rev_fuente,rev_evalua_cc,rev_motivo_cc,rev_ingreso_mensual,rev_tp_ingreso,rev_periodo_ingreso,rev_pago_minimo,rev_linea_tienda,rev_causa,
				rev_puntualidad,rev_saldoropa,rev_saldomuebles,rev_saldoprestamos,rev_vencidoropa,rev_vencidomuebles,rev_vencidoprestamos,rev_abonomensualropa,rev_abonomensualmuebles,rev_abonomensualprestamos, 
				rev_fecha_ultima_compra,rev_secuenciaconsulta,rev_origen,rev_smbc,rev_salario_minimo,rev_compromisos_bco,rev_situacion_especial,rev_causa_situacion,rev_grupo,rev_ingreso_lc,rev_valor_cma,rev_valor_tab,
				rev_linea_teorica,rev_tipo_movimiento,rev_num_solicitud_ref,rev_monto_hipoteca,rev_fechaultimopago,rev_prestamoautorizado,rev_montoautorizado,rev_represtamo,
				rev_vencidoaire, rev_abonomensualaire, rev_saldoaire, rev_vencidoafiliados, rev_abonomensualafiliados, rev_saldoafiliados, rev_vencidoreestructura, rev_abonomensualreestructura, rev_saldoreestructura, rev_scorepuntualidad
			FROM bdisolic:"informix".ss_resum_scor_fin
			WHERE a.num_solicitud = o_numsol;
			
			INSERT INTO bdisolic:ss_resum_scor_fin (empresa,num_solicitud,situacion_pago,situacion_credito,meses_historia,fuente,evalua_cc,motivo_cc,ingreso_mensual,tp_ingreso,periodo_ingreso,pago_minimo,linea_tienda,causa,
				puntualidad,saldoropa,saldomuebles,saldoprestamos,vencidoropa,vencidomuebles,vencidoprestamos,abonomensualropa,abonomensualmuebles,abonomensualprestamos,
				fecha_ultima_compra,secuenciaconsulta,origen,smbc,salario_minimo,compromisos_bco,situacion_especial,causa_situacion,grupo,ingreso_lc,valor_cma,valor_tab,
				linea_teorica,tipo_movimiento,num_solicitud_ref,monto_hipoteca,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,
				vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados, abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura, scorepuntualidad)
			VALUES(p_empresa,aux_sol_revalua,rev_situacion_pago,rev_situacion_credito,rev_meses_historia,rev_fuente,rev_evalua_cc,rev_motivo_cc,rev_ingreso_mensual,rev_tp_ingreso,rev_periodo_ingreso,rev_pago_minimo,rev_linea_tienda,rev_causa,
				rev_puntualidad,rev_saldoropa,rev_saldomuebles,rev_saldoprestamos,rev_vencidoropa,rev_vencidomuebles,rev_vencidoprestamos,rev_abonomensualropa,rev_abonomensualmuebles,rev_abonomensualprestamos,
				rev_fecha_ultima_compra,rev_secuenciaconsulta,rev_origen,rev_smbc,rev_salario_minimo,rev_compromisos_bco,rev_situacion_especial,rev_causa_situacion,rev_grupo,rev_ingreso_lc,rev_valor_cma,rev_valor_tab,
				rev_linea_teorica,rev_tipo_movimiento,rev_num_solicitud_ref,rev_monto_hipoteca,rev_fechaultimopago,rev_prestamoautorizado,rev_montoautorizado,rev_represtamo,
				rev_vencidoaire, rev_abonomensualaire, rev_saldoaire, rev_vencidoafiliados, rev_abonomensualafiliados, rev_saldoafiliados, rev_vencidoreestructura, rev_abonomensualreestructura, rev_saldoreestructura, rev_scorepuntualidad);
					
			-- Hereda canal de origen
			SELECT canal_sol INTO cCanal_sol FROM  bdisolic:"informix".ss_solicitudes
			WHERE empresa = P_EMPRESA AND num_solicitud = o_numsol;
			
			UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = cCanal_sol
			WHERE numcte = o_numcte AND num_solicitud = aux_sol_revalua;
					
					
			FOREACH
			
				select seccion,grupo,elemento,tpo_persona,valor
					INTO sc_seccion,sc_grupo,sc_elemento,sc_tpo_persona,sc_valor
				from bdisolic:ss_detalle_scoring 
					Where num_solicitud = o_numsol
				and grupo  in (2,3,4,41,5,6,7,8,9,10,11,38,16,21,22,39)
					order by grupo
					
					INSERT INTO "informix".ss_detalle_scoring
						VALUES(p_empresa,sc_seccion,sc_grupo,sc_elemento,sc_tpo_persona,aux_sol_revalua,sc_valor);
			
			END FOREACH;
		
			--- Hereda datos de las referencias	
			FOREACH
				SELECT numcte_ref, tipo_relacion, nombre_ref, parentesco, telefono_ref
					INTO aux_numcte_ref, aux_tipo_relacion, aux_nombre_ref, aux_parentesco, aux_telefono_ref
				FROM "informix".ss_refpersonales 
				WHERE num_solicitud = o_numsol
				AND numcte = o_numcte
				
					INSERT INTO  "informix".ss_refpersonales
							(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion, 
								nombre_ref, parentesco, telefono_ref)
					VALUES  (p_empresa, aux_sol_revalua, o_numcte,aux_numcte_ref, aux_tipo_relacion, 
							aux_nombre_ref, aux_parentesco, aux_telefono_ref);
				
			END FOREACH;

			--Se obtiene la ultima referencia del cliente, para omitir proceso en el califica1
			FOREACH	WITH HOLD
				SELECT sucursal,apell_paterno,apell_materno,nombre1,
					nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,
					pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert, fecha_insert
				INTO cps_cSucursal,cps_cApellPaterno,cps_cApellMaterno,cps_cNombre1,cps_cNombre2,cps_cRfc,
					cps_dtFechaNac,cps_cCurp,cps_cSexo,cps_cEstadoCivil,cps_cNacionalidad,cps_cNoFm,cps_cCodigoIden,cps_cNumIdentif ,cps_cPersDomicilio,
					cps_cEmail ,cps_cParentesco,cps_cApellCasada,cps_cNumcteRef ,cps_cNumCteBanco,cps_cUsuario ,cps_dtFecha
				FROM bdinteg:"informix".si_refclientes a
				WHERE a.empresa = '001'
				AND a.numcte = o_numcte	
				AND num_solicitud = o_numsol
				ORDER BY secuencia ASC
				
				LET cps_iContadorRef = cps_iContadorRef+1;
				
				IF cps_iContadorRef > 2 THEN
					EXIT FOREACH;
				END IF;
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk_cps
					(p_empresa,"A",aux_sol_revalua,o_numcte,cps_cSucursal,cps_cApellPaterno,cps_cApellMaterno,cps_cNombre1,cps_cNombre2,cps_cRfc,
					cps_dtFechaNac,cps_cCurp,cps_cSexo,cps_cEstadoCivil,cps_cNacionalidad,cps_cNoFm,cps_cCodigoIden,cps_cNumIdentif ,cps_cPersDomicilio,
					cps_cEmail ,cps_cParentesco,cps_cApellCasada,cps_cNumcteRef ,cps_cNumCteBanco,cps_cUsuario ,cps_dtFecha,0 )
				INTO scod_ret_rev3,cps_iSecuencia2;

				IF scod_ret_rev3::INTEGER <> 0 THEN

					CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, '0106', scod_ret_rev3, "Error sp_refclientes_cjunk " ||TRIM(o_numcte)||' '||TRIM (aux_sol_revalua)||' '||TRIM (cps_cNombre1)||' '||TRIM(cps_cApellPaterno)||' '||cps_iSecuencia2, '02') 
						Returning  scod_ret_ref;

					LET cCodRet= '0003'; 
					RETURN cCodRet; 
				END IF;

					LET cps_cSucursal  		= "";
					LET cps_cApellPaterno  	= "";
					LET cps_cApellMaterno  	= "";
					LET cps_cNombre1  		= "";
					LET cps_cNombre2  		= "";
					LET cps_cRfc  			= "";	
					LET cps_dtFechaNac 		= DATE(1);
					LET cps_cCurp  			= "";
					LET cps_cSexo  			= "";
					LET cps_cEstadoCivil  	= "";
					LET cps_cNacionalidad  	= "";
					LET cps_cNoFm  			= "";
					LET cps_cCodigoIden  	= "";
					LET cps_cNumIdentif  	= "";
					LET cps_cPersDomicilio  = "";
					LET cps_cEmail  		= "";
					LET cps_cParentesco  	= "";
					LET cps_cApellCasada  	= "";
					LET cps_cNumcteRef  	= "";
					LET cps_cNumCteBanco 	= "";
					LET cps_cUsuario  		= "";
					LET cps_dtFecha 		= DATE(1);


			END FOREACH;
			
			SELECT tp_ingreso,periodo_ingreso
				INTO auxRev_tp_ingreso,auxRev_periodo_ingreso
			FROM "informix".ss_resum_scor_fin
			WHERE num_solicitud = o_numsol;
			
			SELECT telefono_ref1,telefono_ref2
				INTO rev_telefono_ref1,rev_telefono_ref2
			FROM "informix".ss_revision_determinacion
			WHERE empresa = p_empresa AND num_solicitud = o_numsol;

			--- Proceso de calificacion para la nueva solicitud	
			EXECUTE PROCEDURE "informix".califica_scoring_cjunk(p_empresa,aux_sol_revalua,'',''
				,rev_ingreso_mensual,auxRev_tp_ingreso,auxRev_periodo_ingreso,'','','','',''
				,rev_telefono_ref1,rev_telefono_ref2,o_monto)
			INTO scod_ret_rev4;
			
			IF scod_ret_rev4::INTEGER <> 0 THEN
				LET cCodRet= '0004'; 
				RETURN cCodRet; 
			END IF;
------- INICIO ICM ENVIAR A PROSPECTEO 	21/08/2020		
			
            SELECT num_solicitud INTO soLorigen FROM "informix".ss_prospecteo_solicitudes 
			WHERE NUM_SOLICITUD = o_numsol AND empresa = '001';
			
			IF dbinfo("sqlca.sqlerrd2") = 1 THEN			
					
				SELECT status_solicitud, monto_autorizado
				  INTO stS_prevP,pMontosol
				 FROM ss_solicitudes WHERE num_solicitud = aux_sol_revalua;
				
				IF stS_prevP <> 'RT' THEN 
				  EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol('001', 'SISTEMA',aux_sol_revalua, "PA","", "Pre-Autorizada" )
				  INTO pCodret;
					
				    IF pCodret <> '000000' THEN 
				 	LET cCodRet= '0004'; 
				    RETURN cCodRet;
				    END IF;
				   
				 INSERT INTO "informix".ss_prospecteo_solicitudes(empresa, numcte, num_producto, num_solicitud, estatus, status_solicitud, fecha, domi_ife, canal_sol, sts_prev_pa, vvalor_junk, imotivos_junk, iband_altaostel, ctipo_movto_junk, flagforenviomcjunk, v_hereda_stat_junk)
				 VALUES('001', o_numcte, '6800', aux_sol_revalua, 'A', 'PA', today, 0, 0, stS_prevP, pMontosol, 0, 0, '', 0, stS_prevP);
                 
				 UPDATE ss_solicitudes SET monto_solicitado = pMontosol WHERE num_solicitud = aux_sol_revalua AND empresa = '001';
				END IF;	
			END IF;
------- FIN ICM ENVIAR A PROSPECTEO	21/08/2020					
			
			--- Se agrega minimo por producto, para actualizar ss_solicitudes para el otorgamiento
			SELECT limiteinf
				INTO rev_limiteinf
			FROM "informix".ss_revision_determinacion
			WHERE empresa = p_empresa AND num_solicitud = aux_sol_revalua;
			
				IF rev_limiteinf IS NOT NULL OR rev_limiteinf <> 0 THEN
				  UPDATE "informix".ss_solicitudes
					SET monto_solicitado = rev_limiteinf
				  WHERE empresa = p_empresa
					AND num_solicitud = aux_sol_revalua;
				END IF;
	
	END
  RETURN cCodRet;
END PROCEDURE
