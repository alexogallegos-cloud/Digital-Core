CREATE PROCEDURE "informix".sp_guardaprospecto_his(pCteProsp CHAR(10))

	RETURNING CHAR (5) AS rCodRet;

	---------------------DECLARACION DE VARIABLES----------------------------------------
	
    DEFINE iSqlErr							INTEGER;
	DEFINE cCodRet							CHAR(5);
	
    DEFINE vempresah                     	CHAR(3);
    DEFINE vnum_solicitudh               	CHAR(20);
    DEFINE vstatus_solicitudh            	CHAR(1);
    DEFINE vsituacion_especialh          	CHAR(1);
    DEFINE vcausa_sitesph                	INTEGER;
    DEFINE vpuntos_parcnh                	SMALLINT;
    DEFINE vpar_altoriesgoh              	SMALLINT;
    DEFINE vpar_celularesh               	SMALLINT;
    DEFINE vpar_prestamosh               	SMALLINT;
    DEFINE vingreso_mensualh             	INTEGER;
    DEFINE vcap_sistematica_abonoh       	INTEGER;
    DEFINE vtope_abonocoppelh            	INTEGER;
    DEFINE vcapmaxima_abonoh             	INTEGER;
    DEFINE vcapreal_abonoh               	INTEGER;
    DEFINE vlineacredito_realh           	INTEGER;
    DEFINE vlineacreditotopeh            	INTEGER;
    DEFINE vfechalineacreditorealh       	CHAR(10);
    DEFINE vfechalineacreditotopeh       	CHAR(10);
    DEFINE vcompromisossich             	INTEGER;
    DEFINE vflaglineacreditoesph         	SMALLINT;
    DEFINE vcod_reth                     	CHAR(3);
    DEFINE vlimitecreditoh               	INTEGER;
    DEFINE vlimitecreditopesosh          	INTEGER;
    DEFINE vparaaltoriesgonvoh           	INTEGER;
    DEFINE vcampo_1h                     	CHAR(1);
    DEFINE vcampo_2h                     	CHAR(1);
    DEFINE vcampo_3h                     	CHAR(1);
    DEFINE vclienteprospectoh            	CHAR(10);
    DEFINE vid_situacionesh              	INTEGER;
    DEFINE vpuntualidad_ref1h            	CHAR(2);
    DEFINE vpuntualidad_ref2h            	CHAR(2);
    DEFINE vflagtestigoparametricocnh    	CHAR(1);
    DEFINE vflag_altadirecta_asupervisarh	CHAR(1);
    DEFINE vpuntos_var_paramh            	INTEGER;
    DEFINE vpuntos_var_sich              	INTEGER;
    DEFINE vscore_domicilioh             	INTEGER;
    DEFINE vnuevo_puntajefinalh          	SMALLINT;
    DEFINE vcanal_origenpros               INTEGER;   
    DEFINE vcampo_5h                     	INTEGER;
    DEFINE vcampo_6h                     	INTEGER;
    DEFINE vcampo_7h                     	INTEGER;
    DEFINE vcampo_8h                     	INTEGER;
    DEFINE vnum_secuenciah                  SMALLINT;
    DEFINE vnum_sec                   		SMALLINT;
    DEFINE dFecha		                	DATE;
    DEFINE dHora							DATE;
    
    DEFINE vejecutivo_autoh    				CHAR(8);
    DEFINE vcomentarioh        				VARCHAR(255,1);
    DEFINE vcausa_solicitudh   				CHAR(3);
    DEFINE vcausa_situacionh   				SMALLINT;
    DEFINE vfecha_entradah     				DATE;
    DEFINE vfecha_salidah      				DATE;
    DEFINE vuser_inserth       				CHAR(8);
    DEFINE vfecha_inserth      				DATE;
    DEFINE vrevision_cach      				INTEGER;
    DEFINE vfecha_horah        				DATE;
    
    DEFINE vfecha_solicitudh                	DATE;
    DEFINE vfecha_respuestah                	DATE;
    DEFINE vstatush                         	CHAR(1);
    DEFINE vusuario_solicitah               	CHAR(8);
    DEFINE vusuario_gestorh                 	VARCHAR(110);
    DEFINE vobservacion1h                   	VARCHAR(255);
    DEFINE vobservacion2h                   	VARCHAR(255);
    DEFINE vobservacion3h                   	VARCHAR(255);
    DEFINE vsituacionespecialh              	CHAR(1);
    DEFINE vcausasituacionespecialh         	SMALLINT;
    DEFINE vsituacionespecialrespuestah     	CHAR(1);
    DEFINE vcausasituacionespecialrespuestah	SMALLINT;
    DEFINE vsecuenciaosh                    	INTEGER;
    DEFINE vmotivo_osh                      	INTEGER;

    DEFINE vseccionh      	SMALLINT;
    DEFINE vgrupoh       	SMALLINT;
    DEFINE velementoh     	SMALLINT;
    DEFINE vtpo_personah  	CHAR(2);
    DEFINE vvalorh        	DECIMAL(5,2);

    --SET debug file to '/informix/mesparza/guardaprospecto_his.out';
    --trace on;

	----------------INICIALIZA DE VARIABLES------------------------------------------------
	LET cCodRet						='00001';
	LET iSqlErr						=0;

	LET vempresah                   ='';
    LET vnum_solicitudh             ='';
    LET vstatus_solicitudh          ='';
    LET vsituacion_especialh        ='';
    LET vcausa_sitesph              =0;
    LET vpuntos_parcnh              =0;
    LET vpar_altoriesgoh            =0;
    LET vpar_celularesh             =0;
    LET vpar_prestamosh             =0;
    LET vingreso_mensualh           =0;
    LET vcap_sistematica_abonoh     =0;
    LET vtope_abonocoppelh          =0;
    LET vcapmaxima_abonoh           =0;
    LET vcapreal_abonoh             =0;
    LET vlineacredito_realh         =0;
    LET vlineacreditotopeh          =0;
    LET vfechalineacreditorealh     ='';
    LET vfechalineacreditotopeh     ='';
    LET vcompromisossich            =0;
    LET vflaglineacreditoesph       =0;
    LET vcod_reth                   ='';
    LET vlimitecreditoh             =0;
    LET vlimitecreditopesosh        =0;
    LET vparaaltoriesgonvoh         =0;
    LET vcampo_1h                   ='';
    LET vcampo_2h                   ='';
    LET vcampo_3h                   ='';
    LET vclienteprospectoh          ='';
    LET vid_situacionesh            =0;
    LET vpuntualidad_ref1h          ='';
    LET vpuntualidad_ref2h          ='';
    LET vflagtestigoparametricocnh  ='';
    LET vflag_altadirecta_asupervisarh	='';
    LET vpuntos_var_paramh            	=0;
    LET vpuntos_var_sich              	=0;
    LET vscore_domicilioh             	=0;
    LET vnuevo_puntajefinalh          	=0;
    LET vcanal_origenpros	            =0;  
    LET vcampo_5h                     	=0;
    LET vcampo_6h                     	=0;
    LET vcampo_7h                     	=0;
    LET vcampo_8h                     	=0;
    LET vnum_secuenciah                 =0;
    LET vnum_sec                        =0;
    LET dFecha		                = CURRENT::DATE;
    LET dHora						= CURRENT;
    
    LET vejecutivo_autoh    	='';
    LET vcomentarioh        	='';
    LET vcausa_solicitudh   	='';
    LET vsituacion_especialh	='';
    LET vcausa_situacionh   	=0;
    LET vfecha_entradah     	='';
    LET vfecha_salidah      	='';
    LET vuser_inserth       	='';
    LET vfecha_inserth      	='';
    LET vrevision_cach      	=0;
    LET vfecha_horah        	='';
    
    LET vfecha_solicitudh                	='';
    LET vfecha_respuestah                	='';
    LET vstatush                         	='';
    LET vusuario_solicitah               	='';
    LET vusuario_gestorh                 	='';
    LET vobservacion1h                   	='';
    LET vobservacion2h                   	='';
    LET vobservacion3h                   	='';
    LET vsituacionespecialh              	='';
    LET vcausasituacionespecialh         	=0;
    LET vsituacionespecialrespuestah     	='';
    LET vcausasituacionespecialrespuestah	=0;
    LET vsecuenciaosh                    	=0;
    LET vmotivo_osh                      	=0;

    LET vseccionh      	=0;
    LET vgrupoh       	=0;
    LET velementoh     	=0;
    LET vtpo_personah  	='';
    LET vvalorh        	='';
	
	
	BEGIN 

		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		        
        SELECT  NVL(MAX(num_secuencia),0)
        INTO vnum_sec
        FROM "informix".pr_autorizacion_his WHERE num_solicitud=pCteProsp;

        LET vnum_secuenciah=vnum_sec+1;

        --Respaldo pr_nuevo_parametrico
        IF (SELECT COUNT(num_solicitud)FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud=pCteProsp) > 0 THEN	
            INSERT INTO "informix".pr_nuevo_parametrico_his(empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos, ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal, fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto, id_situaciones, puntualidad_ref1, puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal, canal_origenpros, campo_5, campo_6, campo_7, campo_8,num_secuencia, fecha_historico, hora_historico)
            SELECT empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos, ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal, fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto, id_situaciones, puntualidad_ref1, puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal, canal_origenpros, campo_5, campo_6, campo_7, campo_8, vnum_secuenciah,dFecha, dHora
            FROM "informix".pr_nuevo_parametrico 
            WHERE num_solicitud=pCteProsp;

            DELETE
            FROM "informix".pr_nuevo_parametrico 
            WHERE num_solicitud=pCteProsp;
        END IF;          

		--Respaldo pr_solicitud_os
        IF (SELECT COUNT(num_solicitud)FROM bdiprospectos:"informix".pr_solicitud_os WHERE num_solicitud=pCteProsp) > 0 THEN	
            INSERT INTO "informix".pr_solicitud_os_his(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os, num_secuencia, fecha_historico, hora_historico)
            SELECT empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os, vnum_secuenciah,dFecha, dHora
            FROM "informix".pr_solicitud_os
            WHERE num_solicitud=pCteProsp;

            DELETE
            FROM "informix".pr_solicitud_os 
            WHERE num_solicitud=pCteProsp; 
        END IF;
		
		--Respaldo pr_detalle_scoring
        IF (SELECT COUNT(num_solicitud)FROM bdiprospectos:"informix".pr_detalle_scoring WHERE num_solicitud=pCteProsp) > 0 THEN	
            INSERT INTO "informix".pr_detalle_scoring_his(empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor,num_secuencia, fecha_historico, hora_historico)
            SELECT empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor,vnum_secuenciah,dFecha, dHora
            FROM "informix".pr_detalle_scoring
            WHERE num_solicitud=pCteProsp;

            DELETE
            FROM "informix".pr_detalle_scoring 
            WHERE num_solicitud=pCteProsp; 
        END IF;
		
		--Respaldo pr_autorizacion
        IF (SELECT COUNT(num_solicitud)FROM bdiprospectos:"informix".pr_autorizacion WHERE num_solicitud=pCteProsp) > 0 THEN	
            INSERT INTO "informix".pr_autorizacion_his(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, situacion_especial, causa_situacion, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora,num_secuencia, fecha_historico, hora_historico)
            SELECT empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, situacion_especial, causa_situacion, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora,vnum_secuenciah,dFecha, dHora
            FROM "informix".pr_autorizacion 
            WHERE num_solicitud=pCteProsp;

            DELETE
            FROM "informix".pr_autorizacion 
            WHERE num_solicitud=pCteProsp;  
        END IF;  
         

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
            Let cCodRet = '00003'; -- No se encontraron registros
        ELSE
            LET cCodRet = '00000';
        END IF;	
   
		RETURN cCodRet;			
	END	
END PROCEDURE

