CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
ptipo_cliente 		CHAR(1),
pap_nombre1        	CHAR(26),
pap_nombre2        	CHAR(26),
pap_apell_paterno  	CHAR(26),
pap_apell_materno  	CHAR(26),
pap_sexo           	CHAR(1),
pap_fecha_nac      	CHAR(10),
pap_rfc            	CHAR(13),
pemail             	CHAR(100),
ptelefono_casa     	CHAR(10),
ptelefono          	CHAR(10),
pcarrier           	CHAR(1),
ppais_nac          	CHAR(3),
pap_cod_postal     	CHAR(5),
pap_id_estado       CHAR(2),
pap_id_ciudad       CHAR(5),
pap_id_colonia      CHAR(10),
pap_id_municipio    CHAR(5),
pap_id_calle        CHAR(40),
pnumero_exterior	CHAR(10),
pnumero_interior	CHAR(10),
pentre_calles		CHAR(40),
pcomplemento		CHAR(80),
ptarjeta_de_credito_activa	CHAR(1),
pultimos_cuatro_digitos	CHAR(4),
pcredito_hipotecario	CHAR(1),
pcredito_automotriz		CHAR(1),
pfirma_buro        	CHAR(1),
pescolaridad       	CHAR(2),
pestado_civil       CHAR(1),
ptpo_edo_civil     	CHAR(2),
pmeses_edo_civil   	CHAR(2),
ptipo_residencia   	CHAR(1),
ptiempo_domicilio  	CHAR(2),
ppers_domicilio    	CHAR(2),
ppers_trabajan     	CHAR(2),
ppers_dependen     	CHAR(2),
pempresa           	CHAR(60),
ptiempo_trabajo    	CHAR(2),
ptiempo_trab_ant   	CHAR(2),
pactividad         	CHAR(2),
psubactividad      	CHAR(2),
pnivel_ingresos    	CHAR(8),
ptel_trabajo       	CHAR(10),
pprimer_nombre_referencia	CHAR(26),
psegundo_nombre_referencia	CHAR(26),	
pprimer_apellido_referencia	CHAR(26),
psegundo_apellido_referencia	CHAR(26),
pfecha_de_nacimiento_referencia	DATE,
pgenero_referencia				CHAR(1),
pparentesco_referencia			CHAR(2),
pNumCteCoppelRef	CHAR(20),
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pCanal				CHAR(10),
pnumero_control     CHAR(25),
pfecha_hora        	DATETIME YEAR to FRACTION(5)
)

    RETURNING 
          CHAR(4)       as vcodret1,
		  CHAR(120)     as vmsjresp,
		  CHAR(2)       as vcodsolbcpl,
		  CHAR(40)      as vdescsolbcpl,
		  CHAR(255)     as vmotivobcpl,
		  CHAR(4)       as vproductobcpl,
		  CHAR(20)      as vfoliobcpl,
		  CHAR(2)       as vcodsolcpl,
		  CHAR(40)      as vdescsolcpl,
		  CHAR(255)     as vmotivocpl,
		  CHAR(4)       as vproductocpl,
		  CHAR(20)      as vfoliocpl;
         
    DEFINE vcodret1 CHAR(4);
	DEFINE vmsjresp CHAR(120);
	DEFINE vcodsolbcpl CHAR(2);
	DEFINE vdescsolbcpl CHAR(40);
	DEFINE vmotivobcpl CHAR(255);
	DEFINE vproductobcpl CHAR(4);
	DEFINE vfoliobcpl CHAR(20);
	DEFINE vcodsolcpl CHAR(2);
	DEFINE vdescsolcpl CHAR(40);
	DEFINE vmotivocpl CHAR(255);
	DEFINE vproductocpl CHAR(4);
	DEFINE vfoliocpl CHAR(20);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE wBegin   CHAR (1);
	
	--Agregar  subcanal
	DEFINE cSubCanal CHAR(2);
	DEFINE cSucFisica CHAR(4);
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = '';
	LET vdescsolbcpl = '';
	LET vmotivobcpl = '';
	LET vproductobcpl = '';
	LET vfoliobcpl = '';
	LET vcodsolcpl = '';
	LET vdescsolcpl = '';
	LET vmotivocpl = '';
	LET vproductocpl = '';
	LET vfoliocpl = '';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET wBegin = "N";
	
	LET cSubCanal = '';
	LET cSucFisica = '';

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_alta_solicitud_movil_online.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vmsjresp = isam_err;
				--LET vmsjresp = desc_err;
				RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-255)
			INSERT INTO bdisolic:ax_paso values ("bdinteg:sp_alta_solicitud_movil_online", sql_err, CURRENT ||isam_err||' cte '||TRIM(pnumcte));
			LET wBegin = "B";
		END EXCEPTION WITH RESUME;

		ON EXCEPTION IN (-535)
		LET wBegin = "S";
      --ROLLBACK WORK;
        COMMIT WORK;
		BEGIN WORK;
		--COMMIT WORK;
		END EXCEPTION WITH RESUME;
	
		--SET DEBUG FILE TO "/informix/sp_alta_solicitud_movil_online_RGH.out";
		--TRACE ON;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--BEGIN WORK;
		COMMIT WORK;		
		
		--Se agrega validacion del campo pCanal para determinar si viene de un sub canal con sucursal fisica
		--ej:  100318 los dos primeros digitos es el subcanal
		--los otros 4 digitos son de la sucursal fisica se hardcodea el campo pCanal =4 es decir 
		--se esta mandando un subcanal 10 donde el canal original es el 4 (DUD)
		
		IF LENGTH(TRIM(pCanal)) > 2 THEN
			LET cSubCanal = SUBSTR(TRIM(pCanal),1,2);
			LET cSucFisica =  SUBSTR(TRIM(pCanal),3,4);
		ELSE 
			IF TRIM(pCanal) = '2' THEN 
				LET cSubCanal =  TRIM(pCanal);
				LET cSucFisica = '8503';
			END IF;
		END IF;	
		
		LET pCanal = '4';
		
		--Bitacora de solicitudes recibidas
		INSERT INTO bdinteg:"informix".si_solicitud_movil_online(productos, numcte, tipo_cliente, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref,numctecoppel_ref ,tel_celular_ref, canal,ejecutivo ,numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,ptipo_cliente,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,pNumCteCoppelRef,ptelefono_celular_referencia,TRIM(pCanal),pejecutivo,pnumero_control,pfecha_hora);
		-------Crea solicitudes de credito
	    EXECUTE PROCEDURE bdinteg:"informix".sp_crea_solicitud_internet(pproductos,pnumcte,ptipo_cliente,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,pNumCteCoppelRef,ptelefono_celular_referencia,pejecutivo,TRIM(pCanal),cSubCanal,cSucFisica,pnumero_control,pfecha_hora) 
	    INTO vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
		--commit WORK;
		IF wbegin = 'S' THEN
			COMMIT WORK;
			BEGIN WORK;
		--ELSE 
			--COMMIT WORK;
			--BEGIN WORK;
		END IF;
		
		IF wbegin <> 'B' THEN
			BEGIN WORK;
		END IF;
		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
		 
	END;
	
END PROCEDURE
DOCUMENT
'FOLIO: RQI 23 1411 REQUERIMENTO REFERENCIAS',
'FECHA: 06/02/2024',
'MODIFICACION: Se crea nuevo parametro llamado pNumCteCoppelRef y consultas para cliente referencia pago referencia',
'SOLICITO: Aracely Urena',
'AUTOR : Miguel Angel Martinez Martinez',
'BD: BDINTEG',
'FOLIO: RQI 23 1411 CANAL 2',
'FECHA: 06/02/2024',
'MODIFICACION: Se crea parametro para la implementacion del canal en los parametros de entrada',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG',
'FECHA: 10/09/2024',
'MODIFICACION: Se agrega validacion del campo pCanal para determinar si viene de un sub canal con sucursal fisica',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_crea_solicitud_internet(pproductos CHAR(200), pnumcte CHAR(20), ptipo_cliente CHAR(1), pap_nombre1 CHAR(26), pap_nombre2 CHAR(26),
                                                        pap_apell_paterno CHAR(26), pap_apell_materno CHAR(26), pap_sexo CHAR(1), pap_fecha_nac CHAR(10),
                                                        pap_rfc CHAR(13), pemail CHAR(100), ptelefono_casa CHAR(10), ptelefono CHAR(10),
                                                        pcarrier CHAR(1), ppais_nac CHAR(3), pap_cod_postal CHAR(5), pap_id_estado CHAR(2),
														pap_id_ciudad CHAR(5), pap_id_colonia INTEGER, pap_id_municipio CHAR(5), pap_id_calle INTEGER,
                                                        pnumero_exterior CHAR(10),  pnumero_interior CHAR(10), pentre_calles CHAR(40), pcomplemento CHAR(80),
                                                        ptarjeta_de_credito_activa CHAR(1), pultimos_cuatro_digitos CHAR(4), pcredito_hipotecario CHAR(1), pcredito_automotriz CHAR(1),
                                                        pfirma_buro CHAR(1), pescolaridad CHAR(2), pestado_civil CHAR(1), ptpo_edo_civil CHAR(2),
                                                        pmeses_edo_civil CHAR(2), ptipo_residencia CHAR(1), ptiempo_domicilio CHAR(2), ppers_domicilio CHAR(2),
                                                        ppers_trabajan CHAR(2), ppers_dependen CHAR(2), pempresa CHAR(60), ptiempo_trabajo CHAR(2),
                                                        ptiempo_trab_ant CHAR(2), pactividad CHAR(2), psubactividad CHAR(2), pnivel_ingresos CHAR(8),
                                                        ptel_trabajo CHAR(10), pprimer_nombre_referencia CHAR(26), psegundo_nombre_referencia CHAR(26), pprimer_apellido_referencia CHAR(26),
                                                        psegundo_apellido_referencia CHAR(26), pfecha_de_nacimiento_referencia DATE, pgenero_referencia CHAR(1), pparentesco_referencia CHAR(2),
                                                        pNumCteCoppelRef CHAR(20), ptelefono_celular_referencia CHAR(10), pejecutivo CHAR(8),pCanal CHAR(2),pSubCanal CHAR(2),pSucursalFisica CHAR(4), idBuro CHAR(25),fecha_hora datetime year to fraction(5))

  RETURNING  CHAR (4)     AS cod_ret,
             CHAR (120)   AS rMensaje_resp,
             CHAR(2)      AS rEtatus_sol_bcpl,
             CHAR(40)     AS rDesc_estatus_bcpl,
             CHAR(255)    AS rMotivo_rechazo_bcpl,
             CHAR(4)      AS rClave_producto_bcpl,
             CHAR(20)     AS rFolio_solicitud_bcpl,
             CHAR(2)      AS rEstatus_sol_cpl,
             CHAR(40)     AS rDesc_estatus_cpl,
             CHAR(255)    AS rCausa_situacion_cpl,
             CHAR(4)      AS rClave_producto_cpl,
             CHAR(20)     AS rFolio_solicitud_cpl;
----
----------DECLARACION DE VARIABLES
DEFINE cod_ret                 CHAR(4);
DEFINE rMensaje_resp           CHAR(120);
DEFINE rEtatus_sol_bcpl        CHAR(2);
DEFINE rDesc_estatus_bcpl      CHAR(40);
DEFINE rMotivo_rechazo_bcpl    CHAR(255);
DEFINE rClave_producto_bcpl    CHAR(4);
DEFINE rFolio_solicitud_bcpl   CHAR(20);
DEFINE rEstatus_sol_cpl        CHAR(2);
DEFINE rDesc_estatus_cpl       CHAR(40);
DEFINE rCausa_situacion_cpl    CHAR(255);
DEFINE rClave_producto_cpl     CHAR(4);
DEFINE rFolio_solicitud_cpl    CHAR(20);
DEFINE iSqlErr                 INTEGER;
---------variables sp calcularrFC
DEFINE rfc_cod_ret			   CHAR(5);
DEFINE rfc                     CHAR(13);
DEFINE ing_codret			   CHAR(5);
---------variables sp consdatadic
DEFINE fecha_actual            DATE;
---------variables sp consdatadicC
DEFINE dat_CodRet              CHAR(5);
DEFINE dat_NumCte              CHAR(20);
DEFINE dat_Apell_Paterno       CHAR(26);
DEFINE dat_Apell_Materno       CHAR(26);
DEFINE dat_Nombre1             CHAR(26);
DEFINE dat_Nombre2             CHAR(26);
DEFINE dat_Rfc                 CHAR(13);
DEFINE dat_FechaNacimiento     CHAR(10);
-------varibales sp_edad_personA
DEFINE cte_ed_cod_ret          CHAR(5);
DEFINE cte_edad                CHAR(5);
-------varibales mayoria edad mATRIMONIO
DEFINE p_ed_cod_ret            CHAR(5);
DEFINE param_edad              CHAR(20);
-------varibales mayoria edad tRABAJAR
DEFINE p_ed_cod_ret2           CHAR(5);
DEFINE param_edad2             CHAR(20);
-------varibales catmensajesmaestro
DEFINE maes_CodRet             CHAR(5);
DEFINE maes_NumMnje      SMALLINT;
DEFINE maes_Sec       SMALLINT;
DEFINE maes_Descrip         CHAR(100);
---- variables obtener productos solicitados
DEFINE tcoppel                 INTEGER;
DEFINE tbanco                  INTEGER;
DEFINE cant_prods              INTEGER;
DEFINE prod_unico              char(4);
------varibles catmensajey productos ofrecer
DEFINE cProdcontinua           CHAR(4);
DEFINE cTpSolicitudOfr         CHAR(1);
------variables ctes relcionados_filtro
DEFINE ret_relacion            CHAR(5);
DEFINE referencia              CHAR(10);
------variables situacion_pagotienda
DEFINE ret_tienda              CHAR(3);
DEFINE tda_mensaje             CHAR(300);
------variables situacion_pagobanco
DEFINE spagocod_ret         CHAR(3);
DEFINE cMensaje             CHAR(300);
DEFINE s_tipper             CHAR(2);
DEFINE s_referen1           CHAR(20);
DEFINE s_nomrefer1          CHAR(110);
DEFINE s_referen2           CHAR(20);
DEFINE s_nomrefer2          CHAR(110);
DEFINE s_sexo               CHAR(1);
DEFINE s_edocivil           CHAR(1);
DEFINE s_edad               SMALLINT;
DEFINE s_habita_en          CHAR(2);
DEFINE s_puesto             CHAR(3);
DEFINE s_creditos           SMALLINT;
DEFINE s_profesion          CHAR(3);
DEFINE s_tel_ref_1          CHAR(13);
DEFINE s_tel_ref_2          CHAR(13);
DEFINE s_parentesco1        CHAR(2);
DEFINE s_parentesco2        CHAR(2);
DEFINE s_cteref             CHAR(20);
------variables cte fisico
--DEFINE tpo_per                 CHAR(2);
--DEFINE tpo_clie                CHAR(1);
DEFINE cte_codret              CHAR(3);
DEFINE cte_num                 CHAR(9);
------variables bdinteg:"informix".alta_sol_tc_cjunk
DEFINE dir_codret              CHAR(3);
------variables numerosolicitud
DEFINE sol_codretban           CHAR(3);
DEFINE sol_codretban_5         CHAR(5);
DEFINE nvo_numsolicban         CHAR(20);
DEFINE sol_codretcop           CHAR(3);
DEFINE nvo_numsoliccop         CHAR(20);


-----------------RGH------------------------------------------------------------
DEFINE mensaje_resp_buro       CHAR(120);
DEFINE pfolio_bc               VARCHAR(99);
DEFINE cod_retbackb				CHAR(6);
DEFINE p_sexo					CHAR(1);
DEFINE p_edocivl				CHAR(1);
DEFINE p_tmpoedocivl			CHAR(2);
DEFINE p_messedocivl			CHAR(2);
DEFINE p_residencia				CHAR(2);
DEFINE p_tmpodomicilio			CHAR(2);
DEFINE p_actividad				CHAR(2);
DEFINE p_tmpotrabajo			CHAR(2);
DEFINE p_tmpotrab_ant			CHAR(2);
DEFINE p_cteedad				CHAR(2);
DEFINE p_persdependen			CHAR(2);
DEFINE p_compingres				CHAR(1);
DEFINE p_segpop					CHAR(1);
DEFINE p_escolaridad			CHAR(1);
DEFINE p_persdomicilio          CHAR(2);
DEFINE p_perstrabajan           CHAR(2);
DEFINE p_numproducto			CHAR(20);
DEFINE p_comilla				CHAR(1);
-----------------RGH------------------------------------------------------------

------variables registra_parametrico
DEFINE detall_codret           CHAR(3);
DEFINE rev_codret              CHAR(5);
------variables calificascoring
DEFINE calif_codret            CHAR(3);
------variables prospecteo
DEFINE prosp_codret             CHAR(5);
DEFINE prosp_cte                CHAR(9);
DEFINE prosp_prod               CHAR(4);
DEFINE prosp_numsol             CHAR(12);
------ OBTENRER variables PARA EJECUTAR PARAMETRICO
DEFINE param_codret           CHAR(5);
DEFINE param_cliente          CHAR(9);
DEFINE param_folio            CHAR(25);
DEFINE param_elemento         CHAR(10);
DEFINE param_descripcion      CHAR(40);
DEFINE scod_ret               CHAR(5);
DEFINE isam_err               SMALLINT;
DEFINE error_info             CHAR(100);
DEFINE cinstitucion           CHAR(2);
DEFINE v_hoy                  DATE;
DEFINE cinstitucion2 		  CHAR(2);						
DEFINE pfolio_cc              VARCHAR(99);	
DEFINE pfolio                 VARCHAR(99);		
DEFINE iInstituciones         INTEGER;	
DEFINE cInstiResp1			  CHAR (2);	
DEFINE cInstiResp2			  CHAR (2);
DEFINE vfechaServ DATE;
------VARIABLE ERROR MENSAJE 32 CAMBIAR ENVIO A 1 SE VAYA CON DEMONIO
--DEFINE sts_sol               CHAR(1);
--DEFINE sts_envio             INTEGER;

------ compara telefono
DEFINE cCodretPunt  CHAR(5);

------ variables validar telefono
DEFINE vt_codret		CHAR(5);
DEFINE vt_casa			CHAR(1);
DEFINE vt_celular		CHAR(1);
DEFINE vt_oficina		CHAR(1);

------ variables RFC refernecia
DEFINE rfcref_cod_ret             CHAR(5);
DEFINE ref_rfc                    CHAR(13);

DEFINE dat_CodRet_ref             CHAR(5);
DEFINE dat_NumCte_ref             CHAR(20);
DEFINE dat_apell_Paterno_ref      CHAR(26);
DEFINE dat_Apell_Materno_ref      CHAR(26);
DEFINE dat_Nombre1_ref            CHAR(26);
DEFINE dat_Nombre2_ref            CHAR(26);
DEFINE dat_Rfc_ref                CHAR(13);
DEFINE dat_FechaNacimiento_ref    CHAR(10);

------ variables referencia cliente banco
DEFINE rb_cte_codret    CHAR(5);
DEFINE rb_cte_sec       INTEGER;
------ variables referencia cliente coppel
DEFINE rc_cte_codret    CHAR(5);
DEFINE rc_cte_sec       INTEGER;

------ variables direccion referencia banco
DEFINE drb_codret    CHAR(5); 

------ variables ciente fisico
DEFINE cte_fis_codret  CHAR(5);
DEFINE cte_fis_num     CHAR(20);

------ variables cliente prospecto (conyugue) 
DEFINE cte_prosp_conyuge_dir_codret  CHAR(5);

------ variables conjuye
DEFINE con_codret    CHAR(5);
DEFINE cCelular				  CHAR (10);	
DEFINE cCorreo				  CHAR (100);
DEFINE vSpl                   CHAR (50);
------ variables actualizacion statusSolicitud
DEFINE sttSolicitud       CHAR(2);

------- Variables canal solicitudes---------
DEFINE cEjecutivo2 			CHAR(8);


----------------------------------------------
----------INCIACION DE VARIABLES -------------
----------------------------------------------
LET cod_ret                 ="0000";
LET rMensaje_resp           ="";
LET rEtatus_sol_bcpl        ="";
LET rDesc_estatus_bcpl      ="";
LET rMotivo_rechazo_bcpl    ="";
LET rClave_producto_bcpl    ="";
LET rFolio_solicitud_bcpl   ="";
LET rEstatus_sol_cpl        ="";
LET rDesc_estatus_cpl       ="";
LET rCausa_situacion_cpl    ="";
LET rClave_producto_cpl     ="";
LET rFolio_solicitud_cpl    ="";
LET iSqlErr                 =0;
-----variables variables sp calcularrfc
LET rfc_cod_ret             ="";
LET rfc                     ="";
LET ing_codret				="";
-----variables variables sp calcularrfc
LET fecha_actual            ="";
---------variables sp consdatadiicC
LET dat_CodRet              ="00000";
LET dat_NumCte              ="";
LET dat_Apell_Paterno       ="";
LET dat_Apell_Materno       ="";
LET dat_Nombre1             ="";
LET dat_Nombre2             ="";
LET dat_Rfc                 ="";
LET dat_FechaNacimiento     ="";
-------varibales sp_edad_persona
LET cte_ed_cod_ret          ="000";
LET cte_edad                ="";
-------varibales mayoria edad parametro
LET p_ed_cod_ret            ="00000";
LET param_edad              ="";
-------varibales mayoria edad trabajar
LET p_ed_cod_ret2           ="00000";
LET param_edad2             ="";
-------varibales catmensajesmaestro
LET maes_CodRet             ="000";
LET maes_NumMnje            =0;
LET maes_Sec                =0;
LET maes_Descrip            ="";
---- variables obtener productos solicitados
LET tcoppel                 =0;
LET tbanco                  =0;
LET cant_prods              =0;
LET prod_unico              ="";
------varibles catmensajey productos ofrecer
LET cProdcontinua           ="";
LET cTpSolicitudOfr         ="";
------variables ctes relcionados_filtro
LET ret_relacion            = "00000";
LET referencia              = "";
------variables situacion_pago_tienda
LET ret_tienda              = "000";
LET tda_mensaje             = "";
------variables situacion_pagobanco
LET spagocod_ret            = "000";
LET cMensaje                ="";
LET s_tipper                ="";
LET s_referen1              ="";
LET s_nomrefer1             ="";
LET s_referen2              ="";
LET s_nomrefer2             ="";
LET s_sexo                  ="";
LET s_edocivil              ="";
LET s_edad                  ="";
LET s_habita_en             ="";
LET s_puesto                ="";
LET s_creditos              ="";
LET s_profesion             ="";
LET s_tel_ref_1             ="";
LET s_tel_ref_2             ="";
LET s_parentesco1           ="";
LET s_parentesco2           ="";
LET s_cteref                ="";
------variables ctefisico
LET cte_codret              = "000";
LET cte_num                 ="";
------variables bdinteg:"informix".alta_sol_tc_cjunk
LET dir_codret              ="000";
------variables numerosolicitud
LET sol_codretban           ="000";
LET sol_codretban_5         ="00000";
LET nvo_numsolicban         ="";
LET sol_codretcop           ="000";
LET nvo_numsoliccop         ="";
-----------------RGH------------------------------------------------------------
LET mensaje_resp_buro       = "";
LET pfolio_bc               = "";
LET cod_retbackb			="";
LET p_sexo					="";
LET p_edocivl				="";
LET p_tmpoedocivl			="";
LET p_messedocivl			="";
LET p_residencia			="";
LET p_tmpodomicilio			="";
LET p_actividad				="";
LET p_tmpotrabajo			="";
LET p_tmpotrab_ant			="";
LET p_cteedad				="";
LET p_persdependen			="";
LET p_compingres			="";
LET p_segpop				="";
LET p_escolaridad			="";
LET p_persdomicilio         ="";
LET p_perstrabajan          ="";
LET p_numproducto			="";
LET p_comilla				="'";
-----------------RGH------------------------------------------------------------
------variables registra_parametrico
LET detall_codret           ="000";
LET rev_codret              ="00000";
------variables calificascoring
LET calif_codret            ="000" ;
------variables prospecteo
LET prosp_codret            ="00000";
LET prosp_cte               = "";
LET prosp_prod              = "";
LET prosp_numsol            = "";
------ OBTENRER variables PARA EJECUTAR PARAMETRICO
LET param_codret                ="00000";
LET param_cliente               ="";
LET param_folio                 ="";
LET param_elemento              ="";
LET param_descripcion           ="";
LET scod_ret            = "00000";
LET cinstitucion                ="";		
LET cinstitucion2				="";	
LET pfolio_cc               = "";	
LET pfolio               = "";		
LET iInstituciones		 =0;	
LET cInstiResp1			 = "";
LET cInstiResp2			 = "";
------VARIABLE ERROR MENSAJE 32 CAMBIAR ENVIO A 1 SE VAYA CON DEMONIO
--LET sts_sol                 = "";
--LET sts_envio               = 0;

LET cEjecutivo2			="";					  
------VARIABLE ERROR MENSAJE 32 CAMBIAR ENVIO A 1 SE VAYA CON DEMONIO
--LET sts_sol                 = "";
--LET sts_envio               = 0;

------ compara telefono
LET cCodretPunt ="00040";

------ variables validar telefono
LET vt_codret		="000";
LET vt_casa			="";
LET vt_celular		="";
LET vt_oficina		="";

------ variables RFC referencia
LET rfcref_cod_ret    ="00000";
LET ref_rfc           ="";

LET dat_CodRet_ref              ="00000";
LET dat_NumCte_ref              ="";
LET dat_apell_Paterno_ref       ="";
LET dat_Apell_Materno_ref       ="";
LET dat_Nombre1_ref             ="";
LET dat_Nombre2_ref             ="";
LET dat_Rfc_ref                 ="";
LET dat_FechaNacimiento_ref     ="";

------ variables referencia cliente banco
LET rb_cte_codret    ="00000";
LET rb_cte_sec       =0;

------ variables referencia cliente coppel
LET rc_cte_codret    ="00000";
LET rc_cte_sec       =0;

------ variables direccion referencia banco
LET drb_codret    ="000";

------ variables ciente fisico
LET cte_fis_codret  ="000";
LET cte_fis_num     ="";

------ variables conjuye
LET con_codret   ='000';
LET cCelular = "";
LET cCorreo  = "";
LET vSpl     = "";

LET cte_prosp_conyuge_dir_codret = "000";

BEGIN

	ON EXCEPTION SET iSqlerr, isam_err, error_info
		IF iSqlErr <> 0 THEN
			LET cod_ret = iSqlErr;
			INSERT INTO bdisolic:ax_paso values ("bdinteg:sp_crea_solicitud_internet", iSqlerr, CURRENT ||error_info||' cte '||TRIM(pnumcte));
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/e99804975/DUD-Cobranza/Liberar/LiberarV2/bdinteg/Sps/sp_crea_solicitud_internet'||TRIM(pnumcte)||'.out';
	--TRACE ON;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


  -------  VERIFICACION DE LOS DATOS RECIBIDOS
IF  pproductos IS NULL OR pproductos = "" THEN
  LET cod_ret = "0010";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PRODUCTO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pnumcte IS NULL OR pnumcte = "" THEN
  LET cod_ret = "0011";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA NUMERO DE CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_nombre1 IS NULL OR pap_nombre1 = "" THEN
  LET cod_ret = "0012";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA NOMBRE DE CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  pap_nombre2 IS NULL OR pap_nombre2 =   "" THEN
  LET cod_ret = "0013";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  pap_apell_paterno IS NULL OR pap_apell_paterno =   "" THEN
  LET cod_ret = "0014";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA APELLIDO DE CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  pap_apell_materno IS NULL OR pap_apell_materno =   "" THEN
  LET cod_ret = "0015";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  pap_sexo IS NULL OR pap_sexo =   "" THEN
  LET cod_ret = "0015";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA SEXO DE CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_fecha_nac IS NULL OR pap_fecha_nac =   "" THEN
  LET cod_ret = "0016";
  LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA FECHA NACIMIENTO DE CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_rfc IS NULL OR pap_rfc =   "" THEN
   LET cod_ret = "0017";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA RFC CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pemail IS NULL OR pemail =   "" THEN
   LET cod_ret = "0018";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA EMAIL CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  ptelefono_casa IS NULL OR ptelefono_casa =   "" THEN
   LET cod_ret = "0018";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  ptelefono IS NULL OR ptelefono =   "" THEN
   LET cod_ret = "0020";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TELEFONO CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pcarrier IS NULL OR pcarrier =   "" THEN
   LET cod_ret = "0021";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CARRIER CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ppais_nac IS NULL OR ppais_nac =   "" THEN
   LET cod_ret = "0022";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PAIS NACIMIENTO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_cod_postal IS NULL OR pap_cod_postal =   "" THEN
   LET cod_ret = "0023";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CODIGO POSTAL CLIENTE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_id_estado IS NULL OR pap_id_estado =   "" THEN
   LET cod_ret = "0024";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA ESTADO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_id_ciudad IS NULL OR pap_id_ciudad =   "" THEN
   LET cod_ret = "0025";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CIUDAD.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_id_colonia IS NULL OR pap_id_colonia =   "" THEN
   LET cod_ret = "0026";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA COLONIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_id_municipio IS NULL OR pap_id_municipio =   "" THEN
   LET cod_ret = "0027";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA MUNICPIO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pap_id_calle IS NULL OR pap_id_calle =   "" THEN
   LET cod_ret = "0028";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CALLE.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pnumero_exterior IS NULL OR pnumero_exterior =   "" THEN
   LET cod_ret = "0029";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA NUMERO EXTERIOR.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  pnumero_interior IS NULL OR pnumero_interior =   "" THEN
   LET cod_ret = "0030";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pentre_calles IS NULL OR pentre_calles =   "" THEN
   LET cod_ret = "0031";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pcomplemento IS NULL OR pcomplemento =   "" THEN
   LET cod_ret = "0032";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  ptarjeta_de_credito_activa IS NULL OR ptarjeta_de_credito_activa =   "" THEN
   LET cod_ret = "0033";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TARJETA DE CREDITO ACTIVA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pultimos_cuatro_digitos IS NULL OR pultimos_cuatro_digitos =   "" THEN
   LET cod_ret = "0034";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA ULTIMOS CUATRO DIGITOS.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pcredito_hipotecario IS NULL OR pcredito_hipotecario =   "" THEN
   LET cod_ret = "0035";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CREDITO HIPOTECARIO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pcredito_automotriz IS NULL OR pcredito_automotriz =   "" THEN
   LET cod_ret = "0036";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA CREDITO AUTOMOTRIZ.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pfirma_buro IS NULL OR pfirma_buro =   "" THEN
   LET cod_ret = "0037";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA FIRMA BURO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pescolaridad IS NULL OR pescolaridad =   "" THEN
   LET cod_ret = "0038";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA ESCOLARIDAD.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pestado_civil IS NULL OR pestado_civil =   "" THEN
   LET cod_ret = "0039";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA ESTADO CIVIL.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ptpo_edo_civil IS NULL OR ptpo_edo_civil =   "" THEN
   LET cod_ret = "0040";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIPO ESTADO CIVIL.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
-- IF  pmeses_edo_civil IS NULL OR pmeses_edo_civil =   "" THEN
   --LET cod_ret = "0041";
--  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
--ND IF;
 IF  ptipo_residencia IS NULL OR ptipo_residencia =   "" THEN
   LET cod_ret = "0042";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA RESIDENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ptiempo_domicilio IS NULL OR ptiempo_domicilio =   "" THEN
   LET cod_ret = "0043";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIEMPO DOMICILIO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ppers_domicilio IS NULL OR ppers_domicilio =   "" THEN
   LET cod_ret = "0044";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PERSONAS DOMICILIO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ppers_trabajan IS NULL OR ppers_trabajan =   "" THEN
   LET cod_ret = "0045";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PERSONAS TRABAJAN.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ppers_dependen IS NULL OR ppers_dependen =   "" THEN
   LET cod_ret = "0046";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PERSONAS DEPENDIENTES.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  pempresa IS NULL OR pempresa =   "" THEN
   LET cod_ret = "0047";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  ptiempo_trabajo IS NULL OR ptiempo_trabajo =   "" THEN
   LET cod_ret = "0048";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIEMPO TRABAJO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ptiempo_trab_ant IS NULL OR ptiempo_trab_ant =   "" THEN
   LET cod_ret = "0049";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIEMPO TRABAJO ANTERIOR.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pactividad IS NULL OR pactividad =   "" THEN
   LET cod_ret = "0050";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIPO ACTIVIDAD.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  psubactividad IS NULL OR psubactividad =   "" THEN
   LET cod_ret = "0051";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TIPO SUB ACTIVIDAD.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pnivel_ingresos IS NULL OR pnivel_ingresos =   "" THEN
   LET cod_ret = "0052";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA NIVEL INGRESOS.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  ptel_trabajo IS NULL OR ptel_trabajo =   "" THEN
   LET cod_ret = "0053";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  pprimer_nombre_referencia IS NULL OR pprimer_nombre_referencia =   "" THEN
   LET cod_ret = "0054";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PRIMER NOMBRE REFERENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  psegundo_nombre_referencia IS NULL OR psegundo_nombre_referencia =   "" THEN
   LET cod_ret = "0055";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
 IF  pprimer_apellido_referencia IS NULL OR pprimer_apellido_referencia =   "" THEN
   LET cod_ret = "0056";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PRIMER APELLIDO REFERENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 /*IF  psegundo_apellido_referencia IS NULL OR psegundo_apellido_referencia =   "" THEN
   LET cod_ret = "0057";
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;*/
IF pestado_civil IN ('U','C') AND ( pfecha_de_nacimiento_referencia IS NULL OR pfecha_de_nacimiento_referencia = "" ) THEN
	LET cod_ret = "0058";
  	LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA FECHA DE NACIMIENTO REFERENCIA.';
	RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pgenero_referencia IS NULL OR pgenero_referencia =   "" THEN
   LET cod_ret = "0059";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA GENERO REFERENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pparentesco_referencia IS NULL OR pparentesco_referencia =   "" THEN
    LET cod_ret = "0060";
	LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA PARENTESCO REFERENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  ptelefono_celular_referencia IS NULL OR ptelefono_celular_referencia =   "" THEN
    LET cod_ret = "0061";
	LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA TELEFONO CELULAR REFERENCIA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  pejecutivo IS NULL OR pejecutivo =   "" THEN
   LET cod_ret = "0062";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA EJECUTIVO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  idBuro IS NULL OR idBuro = ""  THEN
   LET cod_ret = "0064";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA ID BURO.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;
 IF  fecha_hora IS NULL OR fecha_hora =   "" THEN
   LET cod_ret = "0063";
   LET rMensaje_resp='FALTA EL PARAMETRO DE ENTRADA FECHA.';
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
 END IF;

----------------------------------------------------------------------------------------------
-------------------------   COMIENZO DE LA INFORMACION   -------------------------------------
----------------------------------------------------------------------------------------------

/*
	LET p_numproducto = REPLACE(pproductos, ',' , "','");
	LET p_numproducto =  "\'"||p_numproducto||"\'";
	LET p_numproducto = TRIM(p_numproducto);
*/
 IF LENGTH (pproductos) > 5 THEN
  LET  cant_prods = 2;
 END IF;
 IF LENGTH (pproductos) = 4 THEN
  LET  cant_prods = 1;
 END IF;
   /* SELECT count(num_producto)
	INTO cant_prods
	FROM bdicred:"informix".sd_definicion WHERE num_producto in (p_numproducto);
*/
 IF cant_prods > 1 THEN
  LET tcoppel = 1;
  LET tbanco = 1;
  ELIF
  cant_prods = 1 THEN
   SELECT num_producto
   INTO prod_unico
   FROM bdicred:"informix".sd_definicion WHERE num_producto =  pproductos and empresa = '001';
     IF prod_unico = '6500' THEN
      LET tcoppel = 1;
     END IF;
        IF prod_unico = '6001'  THEN
         LET tbanco = 1;
        END IF;
 END IF;

 SELECT fecha_hoy
 INTO fecha_actual
 FROM bdinteg:"informix".si_fechas where empresa = '001';
SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy INTO v_hoy FROM bdicred:"informix".sd_fechas WHERE empresa = '001';

--RQI 21 246  Originacion de solicitudes 24 x 7 INI
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
INTO vfechaServ
FROM sysmaster:sysshmvals;

IF v_hoy < vfechaServ OR fecha_actual < vfechaServ THEN
	LET v_hoy = vfechaServ;
	LET fecha_actual = vfechaServ;
END IF;
--RQI 21 246  Originacion de solicitudes 24 x 7 FIN


 EXECUTE PROCEDURE bdinteg:"informix".sp_calcularrfc(pap_apell_paterno, pap_apell_materno, pap_nombre1||" "||pap_nombre2, pap_fecha_nac)
 INTO rfc_cod_ret, rfc;
	IF rfc_cod_ret <> '00000' THEN
		LET cod_ret = '0004';
		LET rMensaje_resp='ERROR AL CALCULAR EL RFC.';
		INSERT INTO bdisolic:ax_paso values ("alta internet.sp_calcularrfc", rfc_cod_ret, CURRENT ||' cte '||TRIM(pnumcte));
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;

	EXECUTE PROCEDURE bdicheq:"informix".consdatadic('001', rfc)
	INTO dat_CodRet, dat_NumCte, dat_apell_Paterno, dat_Apell_Materno, dat_Nombre1, dat_Nombre2, dat_Rfc, dat_FechaNacimiento;
	IF dat_CodRet <> '00000' THEN
		LET cod_ret = '0005';
		LET rMensaje_resp=' ERROR NO. SOLICITUD. NO EXISTE EN LA TABLA DE CLIENTES. bdicheq:consdatadic';
		INSERT INTO bdisolic:ax_paso values ("alta internet.consdatadic", dat_CodRet, CURRENT ||' rfc '||TRIM(rfc));
	RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;

 EXECUTE PROCEDURE bdinteg:"informix".sp_ObtenerEdadPersona(fecha_actual,pap_fecha_nac)
 INTO cte_ed_cod_ret,cte_edad;
   IF cte_ed_cod_ret <> '000' THEN
     LET cod_ret = '0003';
     LET rMensaje_resp='ERROR AL OBTENER LA EDAD DEL CLIENTE.';
	 INSERT INTO bdisolic:ax_paso values ("alta internet.sp_ObtenerEdadPersona", cte_ed_cod_ret, CURRENT ||' fecha_actual '||TRIM(fecha_actual) || ' pap_fecha_nac '|| TRIM(pap_fecha_nac));
  RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;

 -----extrae edad minima matrimonio
 EXECUTE PROCEDURE bdisolic:"informix".sp_obtenerparametros('001', '360')
 INTO p_ed_cod_ret,param_edad;
   IF p_ed_cod_ret <> '00000' THEN
     LET cod_ret = '0006';
	 INSERT INTO bdisolic:ax_paso values ("alta internet.sp_obtenerparametros", p_ed_cod_ret, CURRENT ||' parametros(001,360)');
     RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;

   -----extrae edad minima trabajar
 EXECUTE PROCEDURE bdisolic:"informix".sp_obtenerparametros('001', '361')
 INTO p_ed_cod_ret2,param_edad2;
   IF p_ed_cod_ret2 <> '00000' THEN
     LET cod_ret = '0006';
	 INSERT INTO bdisolic:ax_paso values ("alta internet.sp_obtenerparametros", p_ed_cod_ret2, CURRENT ||' parametros(001,361)');
     RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;

  IF cte_edad < param_edad THEN
   LET cod_ret = '0006';
   LET rMensaje_resp='ERROR AL OBTENER LA EDAD MINIMA DEL CLIENTE ';
   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
  END IF;

  IF cte_edad < param_edad2 THEN
   LET cod_ret = '0006';
   LET rMensaje_resp='ERROR AL OBTENER LA EDAD MINIMA DEL CLIENTE ';
   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
  END IF;
-------Evalua historial de comportamiento tienda y banco.
  IF tbanco = 1 THEN
  EXECUTE PROCEDURE bdisolic:"informix".situacion_pago_tienda_cjunk('001',pnumcte,'6001','0318',pejecutivo,-1,' ',0,'','','',0, 0, 0,0,0,0,0,0,0,0,01-01-1900,1)
   INTO ret_tienda,tda_mensaje;
   IF ret_tienda <> '000' THEN
    LET cod_ret = '0007';
    LET rMensaje_resp = tda_mensaje;
	   INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_tienda_cjunk", ret_tienda, CURRENT ||' cte '||TRIM(pnumcte));
        RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;
  EXECUTE PROCEDURE bdisolic:"informix".situacion_pago_banco_cjunk('001',pnumcte,'6001','0318',pejecutivo,0,'0')
   INTO spagocod_ret, cMensaje,s_tipper, s_referen1, s_nomrefer1,s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,s_habita_en, s_puesto, s_creditos,s_profesion, s_tel_ref_1, s_tel_ref_2,s_parentesco1, s_parentesco2, s_cteref;
   IF spagocod_ret <> '000' THEN
    LET cod_ret = '0008';
    LET rMensaje_resp = cMensaje;
	INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_banco_cjunk", spagocod_ret, CURRENT ||' cte '||TRIM(pnumcte));
        RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
         END IF;
 END IF;
-------Evalua historial de comportamiento tienda.
 IF tcoppel = 1 and prod_unico = '6500' THEN
  EXECUTE PROCEDURE bdisolic:"informix".situacion_pago_tienda_cjunk('001',pnumcte,'6500','0318',pejecutivo,-1,' ',0,'','','',0, 0, 0,0,0,0,0,0,0,0,01-01-1900,1)
   INTO ret_tienda,tda_mensaje;
   IF ret_tienda <> '000' THEN
    LET cod_ret = '0007';
    LET rMensaje_resp = tda_mensaje;
	INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_tienda_cjunk", ret_tienda, CURRENT ||' cte '||TRIM(pnumcte));
        RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;
  EXECUTE PROCEDURE bdisolic:"informix".situacion_pago_banco_cjunk('001',pnumcte,'6500','0318',pejecutivo,0,'0')
    INTO spagocod_ret, cMensaje,s_tipper, s_referen1, s_nomrefer1,s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,s_habita_en, s_puesto, s_creditos,s_profesion, s_tel_ref_1, s_tel_ref_2,s_parentesco1, s_parentesco2, s_cteref;
   IF spagocod_ret <> '000' THEN
    LET cod_ret = '0008';
    LET rMensaje_resp = cMensaje;
	INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_banco_cjunk", spagocod_ret, CURRENT ||' cte '||TRIM(pnumcte));
        RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
         END IF;
 END IF;
------obtiene mensaje resultante si es que hay
 EXECUTE PROCEDURE bdinteg:"informix".consultacatmensajes_mensaje(2,1,'0','', pnumcte)
 INTO maes_CodRet,maes_NumMnje;
   IF maes_CodRet <> '000' THEN
     IF  maes_NumMnje = 2 OR maes_NumMnje = 5 THEN
   LET cod_ret = '0001';
   LET rMensaje_resp = 'DEBE SER MAYOR DE EDAD PARA EL TRAMITE bdinteg:consultacatmensajes_mensaje';
   INSERT INTO bdisolic:ax_paso values ("alta internet.consultacatmensajes_mensaje", maes_CodRet, CURRENT ||' cte '||TRIM(pnumcte));
   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
  END IF;

  IF maes_NumMnje = 9 OR maes_NumMnje = 13  THEN
   LET cod_ret = '0101';
   LET rMensaje_resp = 'CTE ORDEN SUPERVISION CALLE RECHAZADA VIGENTE consultacatmensajes_mensaje';
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
  END IF;
-------------Revisar definicion
  IF prod_unico = '6500'  and (maes_NumMnje = 10 OR maes_NumMnje = 11 OR maes_NumMnje = 12) THEN
   LET cod_ret = '0102';
   LET rMensaje_resp = ' CLIENTE CON SOLICITUD COPPEL EN TRAMITE bdinteg:consultacatmensajes_mensaje';
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
  END IF;

  IF maes_NumMnje = 1 OR maes_NumMnje = 3 OR maes_NumMnje = 4 OR maes_NumMnje = 6 THEN
	FOREACH
			SELECT s.num_producto,s.tp_solicitud
				INTO cProdcontinua,cTpSolicitudOfr
			FROM bdisolic:"informix".ss_solic_producto s
            INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto  AND p.sucursal = '0318')
            INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = 'A')
            WHERE s.empresa = '001'
			AND s.tp_solicitud IN ('T','C')
			AND s.num_producto IN ('6500','6001')
            AND s.num_producto NOT IN (SELECT num_producto
                                         FROM bdisolic:"informix".ss_solicitudes
                                        WHERE empresa= '001'
                                          AND numcte = pnumcte
                                          AND status_solicitud IN("EA","EE","AT","AP","CC","OA","OS","BC","ST","CE","PA"))

		IF cProdcontinua = '6500' THEN
			LET tcoppel = 1;
		END IF;
		IF cProdcontinua = '6001' THEN
			LET tbanco = 1;
		END IF;
	END FOREACH
	END IF;
   END IF;
----verifica si es cliente relacionado
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados_filtro ('001', pnumcte)
	INTO ret_relacion,referencia;
	IF ret_relacion = '00000' THEN
		LET tcoppel = 0;
	END IF;
	IF prod_unico = '6500' and tcoppel = 0 THEN
		LET cod_ret = '0002';
		LET rMensaje_resp = 'CLIENTE COPPEL RELACIONADO EN BANCOPPEL sp_consultactesrelacionados_filtro';
	RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;

----Actualiza los datos del cliente
      IF pap_sexo = 'H' THEN 
	   LET pap_sexo = 'M';
	  ELSE
	   LET pap_sexo = 'F';
	  END IF;

----Telefono celular y correo actuales para clientes tipo 1	  
	SELECT tipo_cliente  INTO ptipo_cliente  FROM bdinteg:si_cliente WHERE numcte = pnumcte;
	IF(ptipo_cliente = '1') THEN
	
		SELECT telefono  INTO cCelular  FROM bdinteg:si_telefonos_actual WHERE numcte = pnumcte and tipo_tel = '2';
		SELECT FIRST 1 correo_elec  INTO cCorreo  FROM bdinteg:si_correos WHERE numcte = pnumcte and status_correo = 'A';
		
		IF(cCelular IS NOT NULL AND cCelular <> '') THEN
			LET ptelefono = cCelular;
		END IF;
		
		IF(cCorreo IS NOT NULL AND cCorreo <> '') THEN
			LET pemail = cCorreo;
		END IF;
		
	END IF;
	  
	--RQI 61 1074 - Onboarding digital E2E 
	--WorkAround canal cobranza - Se actualiza parametro con el ejecutivo 7000001 cuando viene de cobranza 
	IF pejecutivo <> '70000001' THEN 
		LET cEjecutivo2 = pejecutivo;
		LET pejecutivo = '70000001';
	END IF;
    EXECUTE PROCEDURE bdinteg:"informix".ctefisico('001', 'C', pnumcte, '0318', pejecutivo, '01', ptipo_cliente, pap_apell_paterno, pap_apell_materno,	pap_nombre1, pap_nombre2, pap_rfc, '32', '000', pactividad, '000', '000', ptipo_residencia,	'',	'',	'01', '0',	'0', '0000000',	pap_fecha_nac, '00', '001', '',	pestado_civil, '0', '0', pap_sexo, '', '', '', '', ppers_dependen, '', pemail, '', '0',	pescolaridad,	ptipo_residencia, ptiempo_domicilio, '', 0, '', '', '',	pejecutivo,	'',	ppers_domicilio, ppais_nac)
	INTO cte_codret,cte_num;
		IF cte_codret <> '000' THEN
			LET cod_ret = '0009';
			LET rMensaje_resp = 'HUBO UN PROBLEMA EN LA ACTUALIZACION DE DATOS DEL CLIENTE bdinteg:ctefisico';
			INSERT INTO bdisolic:ax_paso values ("alta internet.ctefisico", cte_codret, CURRENT ||' cte '||TRIM(pnumcte));
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
 ----Actualiza direcciones del cliente
	EXECUTE PROCEDURE bdinteg:"informix".direcciones('001','C',pnumcte,0,'1','','',LPAD (TRIM(pap_id_municipio), 5 , "0"),pentre_calles,'001',pap_id_estado,LPAD (TRIM(pap_id_municipio), 3 , "0"),pap_cod_postal,'1',ptelefono_casa,'2',ptelefono,'','','','','','', pap_id_ciudad,pnumero_exterior,pnumero_interior,'',pap_id_calle,pap_id_colonia,'','',0,0,0,0,0,0,0,pcomplemento,pejecutivo,v_hoy,'0318',pcarrier)
	INTO dir_codret;
		IF dir_codret <> '000' and dir_codret <> '001' THEN
			LET cod_ret = '0065';
			LET rMensaje_resp = 'HUBO UN PROBLEMA EN LA ACTUALIZACION DE DOMICILIO DEL CLIENTE direcciones';
			INSERT INTO bdisolic:ax_paso values ("alta internet.direcciones", dir_codret, CURRENT ||' cte '||TRIM(pnumcte));
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_ingresos ('C', '001',pnumcte, 0,'T' , pempresa, '4',ptiempo_trabajo,'','',pnivel_ingresos,pejecutivo,v_hoy,'0', 0, pactividad,psubactividad,0,'', 0, 0)
	INTO ing_codret;
		IF ing_codret <> '000' THEN
			LET cod_ret = '0065';
			LET rMensaje_resp = 'HUBO UN PROBLEMA EN LA INSERCION DE LOS INGRESOS bdinteg:sp_ingresos';
			INSERT INTO bdisolic:ax_paso values ("alta internet.sp_ingresos", ing_codret, CURRENT ||' cte '||TRIM(pnumcte));
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
	--RQI 61 1074 - Onboarding digital E2E 
	--WorkAround canal cobranza - Se actualiza parametro con el ejecutivo 7000001 cuando viene de cobranza 
	IF cEjecutivo2 <> '' THEN 
		LET pejecutivo  = cEjecutivo2;
	END IF;	
/*----Actualiza las bdinteg:"informix".alta_sol_tc_cjunk del cliente
    EXECUTE PROCEDURE bdinteg:"informix".alta_sol_tc_cjunk('001','C',pnumcte,0,1,pap_id_calle,pap_id_colonia,pap_id_municipio,pentre_calles,'001',pap_id_estado,pap_id_ciudad,pap_cod_postal,'1',ptelefono_casa,'2',ptelefono_casa,'','','', pap_id_ciudad,pnumero_exterior,pnumero_interior,pnumero_interior,pap_id_calle,pap_id_colonia,'','',0,0,0,0,0,0,0,'',pejecutivo,v_hoy,'8503',pcarrier)
	INTO dir_codret;
		IF dir_codret <> '000' THEN
		LET cod_ret = '0065';
		LET rMensaje_resp = 'HUBO UN PROBLEMA EN LA ACTUALIZACION DE LAS bdinteg:"informix".alta_sol_tc_cjunk DEL CLIENTE';
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;
*/

----------------------------------------------------------------------------------------------
-------------------------         GENERA SOLICITUDES     -------------------------------------
----------------------------------------------------------------------------------------------
----Genera las solicitudes
-----------vERIFICA MIXTAS
    IF tbanco = 1 AND tcoppel = 1 AND cant_prods = 2 THEN
      EXECUTE PROCEDURE bdisolic:"informix".alta_sol_tc_cjunk('001',pnumcte,'6001','8503',pejecutivo,'','',0,'',0,0,0,0,'',0,0,0,0,0,0,0,0,0,'')
        INTO sol_codretban_5,nvo_numsolicban;
		LET sol_codretban = sol_codretban_5;
         IF sol_codretban <> '000' THEN
           LET cod_ret = '0066';
           LET rMensaje_resp = 'PROBLEMA AL GENERAR EL NUMERO DE SOLICITUD bdisolic:alta_sol_tc_cjunk';
		   INSERT INTO bdisolic:ax_paso values ("alta internet.alta_sol_tc_cjunk", sol_codretban_5, CURRENT ||' cte '||TRIM(pnumcte));
           RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
          END IF;
      EXECUTE PROCEDURE bdisolic:"informix".alta_sol_tc_cjunk('001',pnumcte,'6500','8503',pejecutivo,'','',0,'',0,0,0,0,'',0,0,0,0,0,0,0,0,0,'')
      INTO sol_codretcop,nvo_numsoliccop;
	 ---UPDATE bdisolic:"informix".ss_solicitudes SET envio_parametrico = 6 WHERE num_solicitud = nvo_numsoliccop;
         IF sol_codretcop <> '000' THEN
           LET cod_ret = '0067';
           LET rMensaje_resp = 'HUBO UN PROBLEMA AL GENERAR EL NO. DE SOLICITUD bdisolic:alta_sol_tc_cjunk';
		   INSERT INTO bdisolic:ax_paso values ("alta internet.alta_sol_tc_cjunk", sol_codretcop, CURRENT ||' cte '||TRIM(pnumcte));
           RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
         END IF;
		-------------------------------------------------RGH------------------------------------------------------------
		--FJPR
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = pCanal
		WHERE numcte = pnumcte AND num_solicitud = nvo_numsoliccop;
		IF iSqlErr <> 0 THEN
			LET vSpl = 'ss_solicitudes.canal_sol';
		END IF;		
	 
	 	UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = pCanal
		WHERE numcte = pnumcte AND num_solicitud = nvo_numsolicban;
		IF iSqlErr <> 0 THEN
			LET vSpl = 'ss_solicitudes.canal_sol';
		END IF;
		--FJPR
		-----rgh 13022020
		/*EXECUTE PROCEDURE bdiburo:burocred('001','8503',pejecutivo,nvo_numsolicban,0)
		INTO scod_ret;*/
		-----rgh 13022020

		SELECT insti1,insti2 INTO cInstiResp1,cInstiResp2 
		FROM bdisolic:"informix".ss_canales_solic
		WHERE canal_solic = pCanal;

		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp1)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
			
		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp2)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
		
		FOREACH		
			SELECT institucion INTO cinstitucion FROM bdiburo:"informix".br_traslado WHERE numcte = idBuro
			--AEHC 18Ago20
			--SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = idBuro;			  
			
			/*EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cinstitucion)
			INTO cod_retbackb, mensaje_resp_buro;

				IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
					LET cod_ret = '0068';
					LET rMensaje_resp = mensaje_resp_buro;
					RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
				END IF;*/
	--Agregar cambios para ambas instituciones 

			UPDATE bdiburo:"informix".br_tl SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_cr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_hi SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_hr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_iq SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pa SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pe SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pn SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_rs SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_sc SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_ar SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_ur SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_es SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_error SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_traslado SET numcte = pnumcte, num_solicitud = nvo_numsolicban where numcte = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_respuesta SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			UPDATE bdiburo:"informix".br_respuesta_aprocesar SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			UPDATE bdiburo:"informix".br_respuesta_aprocesar_aux  SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			
			
			LET iInstituciones = iInstituciones +1;
			
			--SELECT es03 INTO pfolio_bc FROM BDIBURO:br_es WHERE num_cliente = pnumcte;
			SELECT es03 INTO pfolio FROM BDIBURO:br_es WHERE num_cliente = pnumcte and fecha in(select max(fecha) from BDIBURO:br_es WHERE num_cliente = pnumcte) AND institucion = cinstitucion;
			IF cinstitucion = 'CC' THEN
				LET	pfolio_cc = pfolio;
			ELSE
				LET	pfolio_bc = pfolio;
			END IF;
		END FOREACH;
		
		-- nvo_numsolicban validar que exista br_respuesta -- existe insercion normal --no existe fecha sic_nula
		SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = pnumcte;
		IF iInstituciones > 1 THEN
			IF pfolio_cc <> "" AND pfolio_bc <> "" THEN
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, 'CC', v_hoy, v_hoy, '', pfolio_bc, pfolio_cc);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert_Conpfolio';
				END IF;
					
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, 'CC', v_hoy, v_hoy, '', pfolio_bc, pfolio_cc);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert_Conpfolio';
				END IF;
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, 'CC', v_hoy, NULL, '', NULL, NULL);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert_Sinpfolio';
				END IF;
					
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, 'CC', v_hoy, NULL, '', NULL, NULL);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert_Sinpfolio';
				END IF;
			
			END IF;
		ELSE
			IF cinstitucion = 'BC' THEN -- En caso de autenticador por BC
				IF pfolio_bc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert_cinstitucion';
					END IF;
				
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert_cinstitucion';
					END IF;
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert_cinstitucion';
					END IF;
							
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert_cinstitucion';
					END IF;
				END IF;
				
			ELIF cinstitucion = 'CC' THEN -- En caso de antecedentes nulos y no se haya ido a consumir BC
				IF pfolio_cc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', NULL, pfolio_cc);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert';
					END IF;
					
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', NULL, pfolio_cc);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert';
					END IF;
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert';
					END IF;
					
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
					IF iSqlErr <> 0 THEN
						LET vSpl = 'ss_solicitudes_sic.insert';
					END IF;
				END IF;
			END IF;
		END IF;
		
    END IF;


----Genera las solicitudes VERIFICA BANCO
    IF tbanco = 1 AND prod_unico = '6001' THEN
      EXECUTE PROCEDURE bdisolic:"informix".alta_sol_tc_cjunk('001',pnumcte,'6001','8503',pejecutivo,'','',0,'',0,0,0,0,'',0,0,0,0,0,0,0,0,0,'')
        INTO sol_codretban,nvo_numsolicban;
         IF sol_codretban <> '000' THEN
           LET cod_ret = '0066';
           LET rMensaje_resp = 'PROBLEMA AL GENERAR EL NUMERO DE SOLICITUD bdisolic:alta_sol_tc_cjunk';
		   INSERT INTO bdisolic:ax_paso values ("alta internet.alta_sol_tc_cjunk", sol_codretban, CURRENT ||' cte '||TRIM(pnumcte));
           RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
          END IF;
		-------------------------------------------------RGH------------------------------------------------------------
		--FJPR
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = pCanal
		WHERE numcte = pnumcte AND num_solicitud = nvo_numsolicban;
	
		--FJPR
		 ---rgh 13022020
		 /*EXECUTE PROCEDURE bdiburo:burocred('001','8503',pejecutivo,nvo_numsolicban,0)
		 INTO scod_ret;*/
		 ---rgh 13022020

		SELECT insti1,insti2 INTO cInstiResp1,cInstiResp2 
		FROM bdisolic:"informix".ss_canales_solic
		WHERE canal_solic = pCanal;

		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp1)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
			
		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp2)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
			
		FOREACH		
			SELECT institucion INTO cinstitucion FROM bdiburo:"informix".br_traslado WHERE numcte = idBuro	 
			--SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = idBuro;																						 
			 
			/*EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cinstitucion)
			INTO cod_retbackb, mensaje_resp_buro;

				IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
					LET cod_ret = '0068';
					LET rMensaje_resp = mensaje_resp_buro;
					RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
				END IF;*/

			UPDATE bdiburo:"informix".br_tl SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_cr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_hi SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_hr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_iq SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pa SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pe SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_pn SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_rs SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_sc SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_ar SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_ur SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_es SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_error SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_traslado SET numcte = pnumcte, num_solicitud = nvo_numsolicban where numcte = idBuro AND institucion = cinstitucion;
			UPDATE bdiburo:"informix".br_respuesta SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			UPDATE bdiburo:"informix".br_respuesta_aprocesar SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			UPDATE bdiburo:"informix".br_respuesta_aprocesar_aux  SET numcte = pnumcte, num_solicitud = nvo_numsolicban where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
			
			LET iInstituciones = iInstituciones +1;
			--SELECT es03 INTO pfolio_bc FROM BDIBURO:br_es WHERE num_cliente = pnumcte;
			--SELECT es03 INTO pfolio_bc FROM BDIBURO:br_es WHERE num_cliente = pnumcte and fecha in(select max(fecha) from BDIBURO:br_es WHERE num_cliente = pnumcte) AND institucion = cinstitucion;
			SELECT es03 INTO pfolio FROM BDIBURO:br_es WHERE num_cliente = pnumcte and fecha in(select max(fecha) from BDIBURO:br_es WHERE num_cliente = pnumcte) AND institucion = cinstitucion;
					
			IF cinstitucion = 'CC' THEN
				LET	pfolio_cc = pfolio;
			ELSE
				LET	pfolio_bc = pfolio;
			END IF;
			
		END FOREACH;
		-- si no existe br_respuesta mismo flujo que arriba
		-------------------------------------------------RGH------------------------------------------------------------
		-- si la institucion es bc se queda igual
		-- cc se cambia donde se inserta folio
		/*IF EXISTS (SELECT * FROM bdiburo:"informix".br_respuesta WHERE num_solicitud = nvo_numsolicban AND institucion = cinstitucion) THEN
			IF cinstitucion = 'BC' THEN
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', NULL, pfolio_bc);
			END IF;
		ELSE
			INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
			VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
		
		END IF;*/
		SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = pnumcte;
		IF iInstituciones > 1 THEN
			IF pfolio_cc <> "" AND pfolio_bc <> "" THEN
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, 'CC', v_hoy, v_hoy, '', pfolio_bc, pfolio_cc);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert';
				END IF;
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, 'CC', v_hoy, NULL, '', NULL, NULL);
				IF iSqlErr <> 0 THEN
					LET vSpl = 'ss_solicitudes_sic.insert';
				END IF;
			END IF;
		ELSE
			IF cinstitucion = 'BC' THEN 
				IF pfolio_bc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
				END IF
			ELIF cinstitucion = 'CC' THEN
				IF pfolio_cc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, v_hoy, '', NULL, pfolio_cc);
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsolicban, nvo_numsolicban, cinstitucion, v_hoy, NULL, '', NULL, NULL);
				END IF
			END IF;	
		END IF;
	
    END IF;
----Genera las solicitudes VERIFICA COPPEL
    IF tcoppel = 1 AND prod_unico = '6500' THEN
      EXECUTE PROCEDURE bdisolic:"informix".alta_sol_tc_cjunk('001',pnumcte,'6500','8503',pejecutivo,'','',0,'',0,0,0,0,'',0,0,0,0,0,0,0,0,0,'')
     INTO sol_codretcop,nvo_numsoliccop; 
	 ---UPDATE bdisolic:"informix".ss_solicitudes SET envio_parametrico = 6 WHERE num_solicitud = nvo_numsoliccop;
         IF sol_codretcop <> '000' THEN
		   IF sol_codretcop = '710' THEN 
				LET cod_ret = '0067';
				LET rMensaje_resp = 'EL CLIENTE YA CUENTA CON UNA SOLICITUD EN TRAMITE';
				INSERT INTO bdisolic:ax_paso values ("alta internet.alta_sol_tc_cjunk", sol_codretcop, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		   ELSE 
				LET cod_ret = '0067';
				LET rMensaje_resp = 'HUBO UN PROBLEMA AL GENERAR EL NUMERO DE SOLICITUD';
				INSERT INTO bdisolic:ax_paso values ("alta internet.alta_sol_tc_cjunk", sol_codretcop, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		   END IF;
         END IF;

		-------------------------------------------------RGH------------------------------------------------------------
		--FJPR
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = pCanal
		WHERE numcte = pnumcte AND num_solicitud = nvo_numsoliccop;
		--FJPR
		-------rgh 13022020
		/*EXECUTE PROCEDURE bdiburo:burocred('001','8503',pejecutivo,nvo_numsoliccop,0)
	    INTO scod_ret;*/
	    -------rgh 13022020
		
		SELECT insti1,insti2 INTO cInstiResp1,cInstiResp2 
		FROM bdisolic:"informix".ss_canales_solic
		WHERE canal_solic = pCanal;

		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp1)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
			
		EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cInstiResp2)
		INTO cod_retbackb, mensaje_resp_buro;
			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				INSERT INTO bdisolic:ax_paso values ("alta internet.sp_generarespaldoshistoricosic_au", cod_retbackb, CURRENT ||' cte '||TRIM(pnumcte));
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;
		
	FOREACH		
	SELECT institucion INTO cinstitucion FROM bdiburo:"informix".br_traslado WHERE numcte = idBuro	 	
		--SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = idBuro;																						 
	    
		/*EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_au(pnumcte, cinstitucion)
		INTO cod_retbackb, mensaje_resp_buro;

			IF cod_retbackb <> '000000' AND cod_retbackb <> '000002' THEN
				LET cod_ret = '0068';
				LET rMensaje_resp = mensaje_resp_buro;
				RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
			END IF;*/

		UPDATE bdiburo:"informix".br_tl SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_cr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_hi SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_hr SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_iq SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_pa SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_pe SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_pn SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_rs SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_sc SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_ar SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_ur SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_es SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_error SET num_cliente = pnumcte WHERE num_cliente = idBuro AND institucion = cinstitucion;
		UPDATE bdiburo:"informix".br_traslado SET numcte = pnumcte, num_solicitud = nvo_numsoliccop where numcte = idBuro AND institucion = cinstitucion;
        UPDATE bdiburo:"informix".br_respuesta SET numcte = pnumcte, num_solicitud = nvo_numsoliccop where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
        UPDATE bdiburo:"informix".br_respuesta_aprocesar SET numcte = pnumcte, num_solicitud = nvo_numsoliccop where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
        UPDATE bdiburo:"informix".br_respuesta_aprocesar_aux  SET numcte = pnumcte, num_solicitud = nvo_numsoliccop where num_solicitud = idBuro AND institucion = cinstitucion; -- se agrega filtro num_solicitud para optimizar
		
		LET iInstituciones = iInstituciones +1;
		--SELECT es03 INTO pfolio_bc FROM BDIBURO:br_es WHERE num_cliente = pnumcte;
		--SELECT es03 INTO pfolio_bc FROM BDIBURO:br_es WHERE num_cliente = pnumcte and fecha in(select max(fecha) from BDIBURO:br_es WHERE num_cliente = pnumcte) AND institucion = cinstitucion;
		SELECT es03 INTO pfolio FROM BDIBURO:br_es WHERE num_cliente = pnumcte and fecha in(select max(fecha) from BDIBURO:br_es WHERE num_cliente = pnumcte) AND institucion = cinstitucion;
		
		IF cinstitucion = 'CC' THEN
			LET	pfolio_cc = pfolio;
		ELSE
			LET	pfolio_bc = pfolio;
		END IF;
	
	END FOREACH;
	-------------------------------------------------RGH------------------------------------------------------------
	 ---IF (cant_prods = 1) then
	/*IF EXISTS (SELECT * FROM bdiburo:"informix".br_respuesta WHERE num_solicitud = nvo_numsoliccop AND institucion = cinstitucion) THEN
		IF cinstitucion = 'BC' THEN --FJPR
			INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
			VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
		ELSE
			INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
			VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, v_hoy, '', NULL, pfolio_bc);
		END IF;
	ELSE
		INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
		VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, NULL, '', NULL, NULL);
	
	END IF;*/
	-----ELSE
	 ---   INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
	 ---   VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsolicban, 'BC', TODAY, TODAY, '', pfolio_bc, NULL);
	--END IF;
		SELECT FIRST 1 institucion INTO cinstitucion FROM BDIBURO:br_traslado WHERE numcte = pnumcte;
		IF iInstituciones > 1 THEN
			IF pfolio_cc <> "" AND pfolio_bc <> "" THEN
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, 'CC', v_hoy, v_hoy, '', pfolio_bc, pfolio_cc);
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
				VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, 'CC', v_hoy, NULL, '', NULL, NULL);
			END IF;
		ELSE
			IF cinstitucion = 'BC' THEN
				IF pfolio_bc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, v_hoy, '', pfolio_bc, NULL);
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, NULL, '', NULL, NULL);
				END IF;
			ELIF cinstitucion = 'CC' THEN
				IF pfolio_cc <> "" THEN
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, v_hoy, '',NULL, pfolio_cc);
				ELSE
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic(empresa, numcte, num_solicitud, num_solicitud_sic, institucion, fecha_insert, fecha_sic, causa_rt, folio_bc, folio_cc)
					VALUES('001', pnumcte, nvo_numsoliccop, nvo_numsoliccop, cinstitucion, v_hoy, NULL, '',NULL, NULL);
				END IF;
			END IF;
		END IF;

END IF;
-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------          GENERA REGISTRO PROSPECTEO BANCO CON CANAL 4    ----------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  IF nvo_numsolicban <> "" THEN
	EXECUTE PROCEDURE bdisolic:"informix".sp_prospecteo_solicitudes_online('001', pnumcte, '6001', nvo_numsolicban, 'A' , '1', 0, pCanal,pSubCanal,pSucursalFisica )
    INTO prosp_codret, prosp_cte,prosp_prod,prosp_numsol;
    IF prosp_codret <> '00000' THEN
		LET cod_ret = '0069';
		INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_prospecteo_solicitudes_online", prosp_codret, CURRENT ||' cte '||TRIM(pnumcte)||' nvo_numsolicban '|| nvo_numsolicban);
	    EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
	   INTO rev_codret;
	   --LET cod_ret = prosp_codret;
	   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:sp_prospecteo_solicitudes_online';
	   INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.reversasol_tc", rev_codret, CURRENT ||' nvo_numsolicban '|| nvo_numsolicban||' pejecutivo '||TRIM(pejecutivo));
	   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  END IF;

-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------          GENERA REGISTRO PROSPECTEO COPPEL CON CANAL 4    ---------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  IF nvo_numsoliccop <> "" THEN
    EXECUTE PROCEDURE bdisolic:"informix".sp_prospecteo_solicitudes_online('001', pnumcte, '6500', nvo_numsoliccop, 'A' , '1', 0, pCanal,pSubCanal,pSucursalFisica)
    INTO prosp_codret, prosp_cte,prosp_prod,prosp_numsol;
		IF prosp_codret <> '00000' THEN
		LET cod_ret = '0070';
		INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_prospecteo_solicitudes_online", prosp_codret, CURRENT ||' cte '||TRIM(pnumcte)||' nvo_numsoliccop '|| nvo_numsoliccop);
	   EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
	   INTO rev_codret;
	   ----LET cod_ret = prosp_codret;
	   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:sp_prospecteo_solicitudes_online';
	   INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.reversasol_tc1", rev_codret, CURRENT ||' nvo_numsoliccop '|| nvo_numsoliccop||' pejecutivo '||TRIM(pejecutivo));
	   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

  END IF;

/* EXECUTE PROCEDURE bdisolic:"informix".sp_conssolicitudescredito2_mov_2(1,'001','0318',0,pnumcte,'','',0,0,0, 1, 0, '', '');
   IF maes_CodRet <> '000' THEN
     LET cod_ret = maes_CodRet;
     RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;
*/
-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------        Obtiene las respuestas del parametrico ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
    EXECUTE PROCEDURE bdinteg:"informix".sp_datos_comple_detalle_online(idBuro)
      INTO param_codret, param_cliente, param_folio, param_elemento, param_descripcion;
      IF param_codret <> "00000" THEN
			INSERT INTO bdisolic:ax_paso values ("alta internet.sp_datos_comple_detalle_online", param_codret, CURRENT ||' idBuro '||TRIM(idBuro));
			EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
			INTO rev_codret;
				LET cod_ret = '0071';
				LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdinteg:sp_datos_comple_detalle_online';
				INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc2", rev_codret, CURRENT ||' pejecutivo '||TRIM(pejecutivo)||' nvo_numsolicban '|| nvo_numsolicban);
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	  END IF;

-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------        Genera Envio parametrico para BANCO ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

  IF nvo_numsolicban <> "" THEN
     SELECT elemento INTO p_sexo FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 2;

   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,2,p_sexo) ---- sexo H M se espera 3 o 4
   INTO detall_codret;
    IF detall_codret <> '000' THEN
	 INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring1", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban)||' idBuro '||TRIM(idBuro));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
	  LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc3", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

    SELECT elemento INTO p_edocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 3;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,3,p_edocivl) ------Actual  S C D se espera numero equivalente bdisolic:ss_scoring_element
    INTO detall_codret;
      IF detall_codret <> '000' THEN
	      INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring2", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
        EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
        INTO rev_codret;
        LET cod_ret = '0072';
        LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
        INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc4", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
        RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
      END IF;

     SELECT elemento INTO p_tmpoedocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 4;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,4,p_tmpoedocivl)----- ACTUAL nuemro de anios que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring3", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
   INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc5", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_messedocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 41;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,41,p_messedocivl) ----- ACTUAL numero de meses que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring4", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
		INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc6", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_residencia FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 5;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,5,p_residencia) ----- ACTUAL numero de meses que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring5", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
       EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
	  LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
		INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc7", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpodomicilio FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 6;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,6,p_tmpodomicilio) ----- ACTUAL numero tiempo que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
		IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring6", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
        LET cod_ret = '0072';
		LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
		INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc8", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_actividad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 7;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,7,p_actividad)  ----- ACTUAL numero de ocuapacion catalgo  equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring7", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
	 INTO rev_codret;
		LET cod_ret = '0072';
		LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
		INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc9", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
		RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpotrabajo FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 8;
	 EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,8,p_tmpotrabajo) ----- ACTUAL Tiempo trabajo capturado desde pagina se espera equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring8", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
    INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
	  INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc10", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpotrab_ant FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 9;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,9,p_tmpotrab_ant) ----- ACTUAL Tiempo trabajo anterior capturado desde pagina se espera equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring9", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
	  LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
	  INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc11", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_cteedad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 10;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,10,p_cteedad)  ----- ACTUAL No se recibe edad se calculo para otro proceso se requiere equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring10", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
       EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc12", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_persdependen FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 11;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,11,p_persdependen)  ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring11", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
       EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
	  INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc13", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_compingres FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 38;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,38,p_compingres) -----****-*-**--*-*###  ACTUALMENTE no se recibe se pone la opcion 1 por defecto "no trae comporobante de ingresos" #######
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring12", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc14", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_segpop FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 16;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,16,p_segpop) -----****-*-**--*-*###  ACTUALMENTE no se recibe se pone la opcion 2 por defecto "no TIENE Seguro PopulAr " #######
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring13", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc15", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_escolaridad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 21;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,21,p_escolaridad)  ----- ####   ACTUAL Numero de grado del catalogo del OFI en front Validar si es equivalente bdisolic:ss_scoring_element #########
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring14", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
	  LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc16", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

   SELECT elemento INTO p_persdomicilio FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 22;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,22,p_persdomicilio) ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element para personas que viven ene l dom
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring15", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
	  INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc17", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
   SELECT elemento INTO p_perstrabajan FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 39;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsolicban,'T','01',2,39,p_perstrabajan) ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element para personas que trabajan que viven en el dom
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring16", detall_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
   INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc18", rev_codret, CURRENT ||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  END IF;
-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------        Genera Envio parametrico para COPPEL ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

  IF nvo_numsoliccop <> "" THEN
     SELECT elemento INTO p_sexo FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 2;

   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,2,p_sexo) ---- sexo H M se espera 3 o 4
   INTO detall_codret;
    IF detall_codret <> '000' THEN
	INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring17", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
   INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc19", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
   END IF;

     SELECT elemento INTO p_edocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 3;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,3,p_edocivl) ------Actual  S C D se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring18", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
   INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc20", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpoedocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 4;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,4,p_tmpoedocivl)----- ACTUAL nuemro de anios que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring19", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc21", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_messedocivl FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 41;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,41,p_messedocivl) ----- ACTUAL numero de meses que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring20", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc22", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_residencia FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 5;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,5,p_residencia) ----- ACTUAL numero de meses que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring21", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc23", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpodomicilio FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 6;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,6,p_tmpodomicilio) ----- ACTUAL numero tiempo que capturo se espera numero equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring22", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc24", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_actividad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 7;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,7,p_actividad)  ----- ACTUAL numero de ocuapacion catalgo  equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring23", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc25", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpotrabajo FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 8;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,8,p_tmpotrabajo) ----- ACTUAL Tiempo trabajo capturado desde pagina se espera equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring24", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc26", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_tmpotrab_ant FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 9;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,9,p_tmpotrab_ant) ----- ACTUAL Tiempo trabajo anterior capturado desde pagina se espera equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring25", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc27", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_cteedad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 10;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,10,p_cteedad)  ----- ACTUAL No se recibe edad se calculo para otro proceso se requiere equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring26", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc28", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_persdependen FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 11;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,11,p_persdependen)  ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring27", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc29", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_compingres FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 38;
    EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,38,p_compingres) -----****-*-**--*-*###  ACTUALMENTE no se recibe se pone la opcion 1 por defecto "no trae comporobante de ingresos" #######
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring28", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc30", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_segpop FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 16;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,16,p_segpop) -----****-*-**--*-*###  ACTUALMENTE no se recibe se pone la opcion 2 por defecto "no TIENE Seguro PopulAr " #######
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring29", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc31", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

     SELECT elemento INTO p_escolaridad FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 21;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,21,p_escolaridad)  ----- ####   ACTUAL Numero de grado del catalogo del OFI en front Validar si es equivalente bdisolic:ss_scoring_element #########
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring30", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc32", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;

   SELECT elemento INTO p_persdomicilio FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 22;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,22,p_persdomicilio) ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element para personas que viven ene l dom
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring31", detall_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
   LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc33", rev_codret, CURRENT ||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
   SELECT elemento INTO p_perstrabajan FROM bdinteg:"informix".si_datos_comple_deta WHERE folio = idBuro and seccion = 2 and grupo = 39;
   EXECUTE PROCEDURE bdisolic:"informix".recibe_detalle_scoring('001',nvo_numsoliccop,'T','01',2,39,p_perstrabajan) ----- ACTUAL Numero de personas capturadas en pagina se requiere equivalente bdisolic:ss_scoring_element para personas que trabajan que viven en el dom
   INTO detall_codret;
       IF detall_codret <> '000' THEN
	   INSERT INTO bdisolic:ax_paso values ("alta internet.recibe_detalle_scoring32", iSqlerr, CURRENT ||detall_codret||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
     EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
  INTO rev_codret;
      LET cod_ret = '0072';
	  LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:recibe_detalle_scoring';
      INSERT INTO bdisolic:ax_paso values ("alta internet.reversasol_tc34", iSqlerr, CURRENT ||rev_codret||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  END IF;

-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------        CALIFICA SOLICITUDES BANCO  ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  IF nvo_numsolicban <> "" THEN
      EXECUTE PROCEDURE bdisolic:"informix".califica_scoring_cjunk('001',nvo_numsolicban,'','',pnivel_ingresos,0,0,'','','','','',ptelefono_casa,ptelefono,'0')
      INTO calif_codret;
    IF calif_codret <> '000' THEN
      INSERT INTO bdisolic:ax_paso values ("alta internet.califica_scoring_cjunk", iSqlerr, CURRENT ||calif_codret||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsolicban,pejecutivo)
      INTO rev_codret;
      LET cod_ret = '0073';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:califica_scoring_cjunk';
      INSERT INTO bdisolic:ax_paso values ("alta internet:reversasol_tc", iSqlerr, CURRENT ||rev_codret||' nvo_numsolicban '||TRIM(nvo_numsolicban));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  END IF;
-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------          CALIFICA SOLICITUDES COPPEL          --------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  IF nvo_numsoliccop <> "" THEN
    EXECUTE PROCEDURE bdisolic:"informix".califica_scoring_cjunk('001',nvo_numsoliccop,'','',pnivel_ingresos,0,0,'','','','','',ptelefono_casa,ptelefono,'0')
    INTO calif_codret;
    IF calif_codret <> '000' THEN
      INSERT INTO bdisolic:ax_paso values ("alta internet.califica_scoring_cjunk", iSqlerr, CURRENT ||calif_codret||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      EXECUTE PROCEDURE bdisolic:"informix".reversasol_tc('001',nvo_numsoliccop,pejecutivo)
      INTO rev_codret;
      LET cod_ret = '0073';
      LET rMensaje_resp = 'VERIFIQUE SUS SOLICITUDES bdisolic:califica_scoring_cjunk';
      INSERT INTO bdisolic:ax_paso values ("alta internet:reversasol_tc", iSqlerr, CURRENT ||rev_codret||' nvo_numsoliccop '||TRIM(nvo_numsoliccop));
      RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  END IF;
-------------AQUI VA LO DE REFERENCIAS
---RQI 23 1411
-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------        VALIDAMOS TELEFONO CLIENTE       ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  /*IF pNumCteCoppelRef IS NULL THEN
    LET pNumCteCoppelRef = '';
  END IF;
*/
  --IF pNumCteCoppelRef <> '' then
  /*  EXECUTE PROCEDURE bdinteg:"informix".sp_compara_tel('001', '', ptelefono_celular_referencia, 2, pnumcte, '4')
    INTO cCodretPunt;

    IF(cCodretPunt <> '00040') THEN
      LET cod_ret = '0075';
      LET rMensaje_resp = 'EL TELEFONO NO DEBE SER IGUAL AL DEL CLIENTE';
	    INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_compara_tel", cCodretPunt, CURRENT ||' pnumcte '|| TRIM(pnumcte) ||' ptelefono '|| ptelefono ||' ptelefono_celular_referencia '|| ptelefono_celular_referencia );
	    RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
    END IF;
  --END IF;
*/
---RQI 23 1411
-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------        VALIDAMOS TELEFONO VALIDO       ---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
	EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono('001', '', ptelefono_celular_referencia, '')
	INTO vt_codret, vt_casa, vt_celular, vt_oficina;
	IF vt_codret <> '000' THEN
	    LET cod_ret = '0076';
	    LET rMensaje_resp = 'EL TELEFONO DE LA REFERENCIA NO ES NUMERO VALIDO';
	    INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_validatelefono", vt_codret, CURRENT ||' ptelefono_celular_referencia '|| ptelefono_celular_referencia);
	    RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
	END IF;

  -- CLIENTE EXISTE O NO EXISTENTE
  --IF pestado_civil IN ('S','V','D') THEN
    ----- BANCO -----
    IF nvo_numsolicban <> "" THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk('001', 'A', nvo_numsolicban, pnumcte, '8503', pprimer_apellido_referencia, psegundo_apellido_referencia, pprimer_nombre_referencia, psegundo_nombre_referencia, '',
		pfecha_de_nacimiento_referencia, '', '', '', '', '', '', '', '', '', pparentesco_referencia, '', pNumCteCoppelRef, '', pejecutivo, fecha_hora, 0)
		INTO rb_cte_codret, rb_cte_sec;
		
		IF rb_cte_codret <> '00000' THEN
			INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_refclientes_cjunk", rc_cte_codret, CURRENT ||' nvo_numsolicban '|| TRIM(nvo_numsoliccop) ||' pnumcte '|| TRIM(pnumcte));

			LET cod_ret = '0078';
			LET rMensaje_resp = 'ERROR AL GUARDAR LA REFERENCIA DEL CLIENTE';
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
	  
		EXECUTE PROCEDURE bdinteg:"informix".sp_refdirecciones_cjunk('001','0','A',pnumcte,rb_cte_sec,'1','','','','','','','','','','','C',ptelefono_celular_referencia,'','','','','','','','','','','','','','','','','','','','','','','','','')
		INTO drb_codret;
		IF drb_codret <> '000' THEN
			LET cod_ret = '0079';
			LET rMensaje_resp = 'ERROR AL GUARDAR LA DIRECCION DE LA REFERENCIA DEL CLIENTE';
			INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_refdirecciones_cjunk", drb_codret, CURRENT ||' pnumcte '|| TRIM(pnumcte) ||' rb_cte_sec '|| rb_cte_sec ||' ptelefono_celular_referencia '|| ptelefono_celular_referencia);
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
	  
	END IF;

    --- COPPEL -----
    IF nvo_numsoliccop <> "" THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk('001', 'A', nvo_numsoliccop, pnumcte, '8503', pprimer_apellido_referencia, psegundo_apellido_referencia, pprimer_nombre_referencia, psegundo_nombre_referencia, '',
		pfecha_de_nacimiento_referencia, '', '', '', '', '', '', '', '', '', pparentesco_referencia, '', pNumCteCoppelRef, '', pejecutivo, fecha_hora, 0)
		INTO rc_cte_codret, rc_cte_sec;
	  
		IF  rc_cte_codret <> '00000' THEN
			INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_refclientes_cjunk", rc_cte_codret, CURRENT ||' nvo_numsoliccop '|| TRIM(nvo_numsoliccop) ||' pnumcte '|| TRIM(pnumcte));

			LET cod_ret = '0078';
			LET rMensaje_resp = 'ERROR AL GUARDAR LA REFERENCIA DEL CLIENTE';
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_refdirecciones_cjunk('001','0','A',pnumcte,rc_cte_sec,'1','','','','','','','','','','','C',ptelefono_celular_referencia,'','','','','','','','','','','','','','','','','','','','','','','','','')
		INTO drb_codret;
		IF drb_codret <> '000' THEN
			LET cod_ret = '0079';
			LET rMensaje_resp = 'ERROR AL GUARDAR LA DIRECCION DE LA REFERENCIA DEL CLIENTE';
			INSERT INTO bdisolic:"informix".ax_paso values ("alta internet.sp_refdirecciones_cjunk", drb_codret, CURRENT ||' pnumcte '|| TRIM(pnumcte) ||' rb_cte_sec '|| rb_cte_sec ||' ptelefono_celular_referencia '|| ptelefono_celular_referencia);
			RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
		END IF;
	  
    END IF;
  --END IF;
  
-------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------                OBTIENE SALIDA DEL PROCEDIMIENTO           ---------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
  IF  cant_prods >1 AND (nvo_numsolicban <> "" OR nvo_numsoliccop <> "")  THEN   

    SELECT ss_sol.status_solicitud, ss_stts.descripcion, ss_aut.comentario, ss_sol.num_producto, ss_sol.num_solicitud
	INTO rEtatus_sol_bcpl,rDesc_estatus_bcpl,rMotivo_rechazo_bcpl,rClave_producto_bcpl,rFolio_solicitud_bcpl
    FROM bdisolic:"informix".ss_solicitudes ss_sol 
	LEFT JOIN bdisolic:"informix".ss_autorizacion ss_aut ON ss_sol.num_solicitud = ss_aut.num_solicitud AND ss_sol.status_solicitud = ss_aut.status_solicitud
	INNER JOIN bdisolic:"informix".ss_status_sol ss_stts ON ss_sol.status_solicitud = ss_stts.status_solicitud
    WHERE ss_sol.numcte = pnumcte
            AND ss_sol.num_solicitud = nvo_numsolicban
            AND ss_sol.num_producto = '6001';
			
	IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
		LET rMensaje_resp = 'NO SE PUDO OBTENER LA SOLICITUD BANCO';
	END IF;

	SELECT ss_sol.status_solicitud, ss_stts.descripcion, ss_aut.comentario, ss_sol.num_producto, ss_sol.num_solicitud
	INTO rEstatus_sol_cpl,rDesc_estatus_cpl,rCausa_situacion_cpl,rClave_producto_cpl,rFolio_solicitud_cpl
    FROM bdisolic:"informix".ss_solicitudes ss_sol
	LEFT JOIN bdisolic:"informix".ss_autorizacion ss_aut ON ss_sol.num_solicitud = ss_aut.num_solicitud AND ss_sol.status_solicitud = ss_aut.status_solicitud
	INNER JOIN bdisolic:"informix".ss_status_sol ss_stts ON ss_sol.status_solicitud = ss_stts.status_solicitud
    WHERE ss_sol.numcte = pnumcte
            AND ss_sol.num_solicitud = nvo_numsoliccop
            AND ss_sol.num_producto = '6500';
			
	IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
		LET rMensaje_resp = 'NO SE PUDO OBTENER LA SOLICITUD TIENDA';
	END IF;		
	
	  
	ELIF  cant_prods = 1 AND nvo_numsolicban <> "" THEN 
	
	SELECT ss_sol.status_solicitud, ss_stts.descripcion, ss_aut.comentario, ss_sol.num_producto, ss_sol.num_solicitud
	INTO rEtatus_sol_bcpl,rDesc_estatus_bcpl,rMotivo_rechazo_bcpl,rClave_producto_bcpl,rFolio_solicitud_bcpl
    FROM bdisolic:"informix".ss_solicitudes ss_sol 
	LEFT JOIN bdisolic:"informix".ss_autorizacion ss_aut ON ss_sol.num_solicitud = ss_aut.num_solicitud AND ss_sol.status_solicitud = ss_aut.status_solicitud
	INNER JOIN bdisolic:"informix".ss_status_sol ss_stts ON ss_sol.status_solicitud = ss_stts.status_solicitud
    WHERE ss_sol.numcte = pnumcte
            AND ss_sol.num_solicitud = nvo_numsolicban
            AND ss_sol.num_producto = '6001';
			
	IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
		LET cod_ret = '0074';
		LET rMensaje_resp = 'NO SE PUDO OBTENER LA SOLICITUD BANCO';
	END IF;

	
	ELIF cant_prods = 1 AND nvo_numsoliccop <> "" THEN 
	
	SELECT ss_sol.status_solicitud, ss_stts.descripcion, ss_aut.comentario, ss_sol.num_producto, ss_sol.num_solicitud
	INTO rEstatus_sol_cpl,rDesc_estatus_cpl,rCausa_situacion_cpl,rClave_producto_cpl,rFolio_solicitud_cpl
    FROM bdisolic:"informix".ss_solicitudes ss_sol
	LEFT JOIN bdisolic:"informix".ss_autorizacion ss_aut ON ss_sol.num_solicitud = ss_aut.num_solicitud AND ss_sol.status_solicitud = ss_aut.status_solicitud
	INNER JOIN bdisolic:"informix".ss_status_sol ss_stts ON ss_sol.status_solicitud = ss_stts.status_solicitud
    WHERE ss_sol.numcte = pnumcte
            AND ss_sol.num_solicitud = nvo_numsoliccop
            AND ss_sol.num_producto = '6500';
			
	IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
		LET cod_ret = '0074';
		LET rMensaje_resp = 'NO SE PUDO OBTENER LA SOLICITUD TIENDA';
	END IF;		
    
	ELSE 	
		LET cod_ret = '0074';
		LET rMensaje_resp = 'NO SE PUDO OBTENER LA SOLICITUD MIXTA';
	END IF;
	  
	-----pOR ERROR EN MENSAJE 32 QUE NO SALGA DE STATUS EC
    /* SELECT status_solicitud, envio_parametrico INTO sts_sol,sts_envio  FROM bdisolic:"informix".ss_solicitudes
	 WHERE num_solicitud = nvo_numsoliccop AND EMPRESA = '001';
      IF sts_sol = 'EC' AND sts_envio = 6 THEN
	  UPDATE bdisolic:"informix".ss_solicitudes SET envio_parametrico = 1  WHERE num_solicitud = nvo_numsoliccop AND EMPRESA = '001';
	  END IF;*/
   RETURN cod_ret, rMensaje_resp, rEtatus_sol_bcpl, rDesc_estatus_bcpl, rMotivo_rechazo_bcpl, rClave_producto_bcpl, rFolio_solicitud_bcpl, rEstatus_sol_cpl, rDesc_estatus_cpl, rCausa_situacion_cpl, rClave_producto_cpl, rFolio_solicitud_cpl;
END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Se Crea procedimiento para generar cliente, solicitud y su evaluacion con buro de credito',
'             cuando la solicitud sea coppel se enviara coppel en linea a traves del servicio BANCOPPEL inYAU',
'AUTOR : Ivan Castillo',
'FECHA : 13/11/2019',
'BD: bdinteg',
'DESCRIPCION: RQI 61 1074 - Onboarding digital E2E  WorkAround canal cobranza - Se actualiza procedimiento para enviar el pEjecutivo 70000001 cuando es empleado del canal 2',
'AUTOR : Jesus Isaias Bueno Castro',
'FECHA : 18/08/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'FOLIO: RQI 23 1411 REQUERIMENTO REFERENCIAS',
'FECHA: 26/04/2023',
'MODIFICACION: Se crea nuevo parametro llamado pNumCteCoppelRef y consultas para cliente referencia pago referencia',
'SOLICITO: Aracely Urena',
'AUTOR : Miguel Angel Martinez Martinez',
'BD: BDINTEG',
'----------------------------------------------------------------------------------------------------------------',
'FOLIO: RQI 23 1411 Canal calle',
'FECHA: 12/10/2023',
'MODIFICACION: Se agrega parametro canal ',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG',
'----------------------------------------------------------------------------------------------------------------',
'FOLIO:  ',
'FECHA: 12/04/2024',
'MODIFICACION: Se quita validacion del telefono de la referencia con el telefono del solcitante esta validacion se hace en el',
'				front y ocaciona un error 0041 en el escenario donde el solicitante pone el telefono',
'				registrado previamente en el telefono de la referencia',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG',
'FECHA: 10/09/2024',
'MODIFICACION: Se agrega consulta para el guardado del sub canal y sucursal fisica en solicitudes que vienen por subcanales',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_registraenviohuelladec (
														pOrigenTicket       CHAR(1),
														pNumCte             CHAR(20),
														pSecuencia          CHAR(50)
														)																
--DATOS A REGRESAR---
RETURNING             	
CHAR(5) 			AS CodRet;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_registraenviohuelladec"
Folio.........: 841 - ComparaciÃÂ³n en linea de 10 huellas_V2.0.
Autor.........: 90127902 - Carlos VÃÂ¡zquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;


-- SET DEBUG FILE TO '/home/sysifx/sp_registraenviohuelladec.out';
-- TRACE ON;

-- LET CURRENT			= TO_CHAR(CURRENT, '%m/%d/%Y %H:%M:%S');
-- INICIALIZACION DE VARIABLE.
LET cCodRet			= '00000';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	UPDATE "informix".si_huella_linea_dec
	SET origen_ticket = pOrigenTicket,
		fecha_env = CURRENT		
	WHERE numcte = TRIM(pNumCte) 
	AND secuencia = pSecuencia;		
	
	RETURN cCodret;
END;
END PROCEDURE;