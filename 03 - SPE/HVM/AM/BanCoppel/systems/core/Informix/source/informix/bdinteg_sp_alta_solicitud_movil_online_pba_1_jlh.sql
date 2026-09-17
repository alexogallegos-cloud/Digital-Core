CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online_pba_1_jlh(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
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
pap_id_estado         	CHAR(2),
pap_id_ciudad         	CHAR(3),
pap_id_colonia        	CHAR(10),
pap_id_municipio      	CHAR(5),
pap_id_calle          	CHAR(40),
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
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pnumero_control         	CHAR(25),
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
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = 'PA';
	LET vdescsolbcpl = 'Pre autorizada';
	LET vmotivobcpl = '';
	LET vproductobcpl = '6001';
	LET vfoliobcpl = '11111111';
	LET vcodsolcpl = 'PA';
	LET vdescsolcpl = 'Pre autorizada';
	LET vmotivocpl = '';
	LET vproductocpl = '6500';
	LET vfoliocpl = '55555555';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

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

		--SET DEBUG FILE TO "/informix/LIP/logs/sp_alta_solicitud_movil_online.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO informix.si_solicitud_movil_online(productos, numcte, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref, tel_celular_ref, ejecutivo, numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,ptelefono_celular_referencia,pejecutivo,pnumero_control,pfecha_hora);

		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
	END;
	
END PROCEDURE;