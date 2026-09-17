CREATE PROCEDURE "informix".sp_actualiza_ctemovil(
pId							INTEGER,
pCte_coppel					CHAR(1),
pNumcte_coppel 		        CHAR(20),
pApell_paterno 		        CHAR(26),
pApell_materno 		        CHAR(26),
pNombre1 					CHAR(26),
pNombre2 					CHAR(26),
pFecha_nac					CHAR(10),
pSexo 						CHAR(1),
pCalle 						CHAR(40),
pColonia 					CHAR(60),
pMunicipio 					CHAR(40),
pEstado 					CHAR(40),
pCod_Postal 		        CHAR(5),
pDomicilio 					CHAR(1),
pDomicilio_act 		        CHAR(1),
pClave_IFE 					CHAR(18),
pCURP 						CHAR(18),
pAnio_Registro 		        CHAR(7),
pCve_Estado 		        CHAR(2),
pCve_Municipio 		        CHAR(3),
pSeccion 					CHAR(4),
pLocalidad 					CHAR(4),
pEmision 					CHAR(4),
pVigencia 					CHAR(4),
pOCR 						CHAR(13),
pIngresos 					CHAR(8),
pEdo_Civil 					CHAR(1),
pAniosEdocivil 		        CHAR(2),
pMesesEdocivil 		        CHAR(2),
pTipoResidencia 	        CHAR(1),
pTiempoDomActual 	        CHAR(2),
pActividad 					CHAR(2),
pSubActividad 		        CHAR(2),
pEmpresa 					CHAR(60),
pTel_Trabajo 		        CHAR(10),
pAniosEmpleoActual 	        CHAR(2),
pAniosmpleoAnterior         CHAR(2),
pEdad 						CHAR(2),
pPersDepenEconom 	        CHAR(2),
pComprobIngresos 	        CHAR(2),
pEscolaridad 		        CHAR(2),
pHabitanDomicilio 	        CHAR(2),
pPersDomTrabajan 	        CHAR(2),
pProducto 					CHAR(3),
ptel_casa 					CHAR(10),
pCelular 					CHAR(10),
pCompTel 					CHAR(1),
pEmail 						CHAR(100),
pGeolocalizacion 	        CHAR(20),
pFirmaCteCc 		        CHAR(1),
pFirmaCteBc 		        CHAR(1),
pFirmaCteBuro 		        CHAR(1),
pFotos 						CHAR(1),
pEjecutivo 					CHAR(8),
pAp_apell_paterno 	        CHAR(26),
pAp_apell_materno 	        CHAR(26),
pAp_nombre1 		        CHAR(26),
pAp_nombre2 		        CHAR(26),
pAp_fecha_nac 		        CHAR(10),
pAp_sexo 					CHAR(1),
pAp_calle 					CHAR(40),
pAp_colonia 		        CHAR(150),
pAp_municipio 		        CHAR(40),
pAp_estado 					CHAR(40),
pAp_cod_Postal 		        CHAR(5),
pAp_clave_IFE 		        CHAR(18),
pAp_CURP 					CHAR(18),
pAp_anio_Registro 	        CHAR(7),
pAp_cve_Estado 		        CHAR(2),
pAp_cve_Municipio 	        CHAR(3),
pAp_seccion 		        CHAR(4),
pAp_localidad 		        CHAR(4),
pAp_emision 		        CHAR(4),
pAp_vigencia 		        CHAR(4),
pAp_OCR 					CHAR(13),
pPais_nacimiento			CHAR(3),
pIdEstado                   CHAR(2),
pIdCiudad                   CHAR(3),
pIdColonia                  INTEGER,
pAp_Id_Estado               CHAR(2),
pAp_Id_Ciudad               CHAR(3),
pAp_Id_Colonia              INTEGER)

RETURNING CHAR(5) AS CodRet, CHAR(50) AS Descripcion;
--DEFINE VARIABLES
DEFINE cCodRet        	  CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE vt_fech_hora    	  CHAR(19);
--DEFINE telefono 		  CHAR(10);

DEFINE sDiasDIff        CHAR(10);
DEFINE SNrows           INTEGER;
DEFINE SNumTel          CHAR(10);

DEFINE cCodRetLN	    CHAR(6);
DEFINE SFolio           CHAR(12);
DEFINE SNumcte          CHAR(20);
DEFINE sFechaLN         CHAR(10);

--INICIALIZA VARIABLES
LET cCodRet             ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';

LET sDiasDIff          ='';
LET SNrows             =0;
LET SNumTel            ='';

LET cCodRetLN          ='';
LET SFolio             ='';
LET SNumcte            ='';
LET sFechaLN           ='';    
	
BEGIN
-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		LET cDesc='Error no controlado';
		RETURN cCodRet,cDesc;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/emm/sp_actualiza_ctemovil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-----VALIDA EN LISTA NEGRA------------------
LET sFechaLN = SUBSTR(pAp_fecha_nac,4,2) ||'/'|| SUBSTR(pAp_fecha_nac,0,2) ||'/'|| SUBSTR(pAp_fecha_nac,7,4);	

Execute procedure bdiauditor:"informix".sp_busqueda_cte_listanegra(pAp_nombre1, pAp_nombre2, pAp_apell_paterno, pAp_apell_materno, sFechaLN) INTO cCodRetLN;

IF(cCodRetLN = '000002') THEN
    LET CDesc = 'No es posible continuar con el proceso del cliente';
	LET cCodRet = '00008';

    SELECT folio, numcte INTO sFolio, sNumcte FROM bdinteg:"informix".si_solicitud_movil WHERE  id = pId ;
    INSERT INTO si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
    VALUES(sFolio,sNumcte,UPPER(pAp_apell_paterno),UPPER(pAp_apell_materno),UPPER(pAp_nombre1),UPPER(pAp_nombre2),pAp_fecha_nac,TODAY);

	RETURN cCodRet,CDesc;	
END IF;
IF(cCodRetLN = '000001') THEN
    LET CDesc = 'Datos incorrectos, capturar nuevamente';
	LET cCodRet = '00008';
	RETURN cCodRet,CDesc;	
END IF;
-------------------------------------------
--VALIDAR OCR
LET pOCR = TRIM(pOCR);

IF pOCR = 'error' OR pOCR = 'error la imag' THEN
	LET pOCR='';
END IF;


--VALIDA PARAMETROS
IF pFirmaCteCc='' THEN
	LET pFirmaCteCc=0;
END IF;
IF pFirmaCteBc='' THEN
	LET pFirmaCteBc=0;
END IF;
IF pFirmaCteBc='' THEN
	LET pFirmaCteBc=0;
END IF;
IF pFotos='' THEN
	LET pFotos=0;
END IF;


IF LENGTH(pAp_fecha_nac)<10 THEN
    LET pAp_fecha_nac=pAp_fecha_nac[1,2]||'/'||pAp_fecha_nac[3,4]||'/'||pAp_fecha_nac[5,8];
END IF

LET pCod_Postal = TRIM(pCod_Postal);

--IF LENGTH(TRIM(pCod_Postal))<5 AND TRIM(pCod_Postal)<>""  THEN
IF LENGTH(pCod_Postal)<5 AND pCod_Postal<>""  THEN
   LET 	pCod_Postal="0"||pCod_Postal;
END IF;

IF LENGTH(pAniosEdocivil)=2 THEN
 IF pAniosEdocivil[1]="0" THEN
	LET pAniosEdocivil=pAniosEdocivil[2];
 END IF;
END IF;

IF LENGTH(pMesesEdocivil)=2 THEN
	IF pMesesEdocivil[1]="0" THEN
	LET pMesesEdocivil=pMesesEdocivil[2];
 END IF;
END IF;

IF LENGTH(pTiempoDomActual)=2 THEN
	IF pTiempoDomActual[1]="0" THEN
	LET pTiempoDomActual=pTiempoDomActual[2];
 END IF;
END IF;

IF LENGTH(pAniosEmpleoActual)=2 THEN
	IF pAniosEmpleoActual[1]="0" THEN
	LET pAniosEmpleoActual=pAniosEmpleoActual[2];
 END IF;
END IF; 	 

IF LENGTH(pAniosmpleoAnterior)=2 THEN
	IF pAniosmpleoAnterior[1]="0" THEN
	LET pAniosmpleoAnterior=pAniosmpleoAnterior[2];
 END IF;
END IF; 	

IF LENGTH(pPersDepenEconom)=2 THEN
	IF pPersDepenEconom[1]="0" THEN
	LET pPersDepenEconom=pPersDepenEconom[2];
 END IF;
END IF; 	

IF LENGTH(pHabitanDomicilio)=2 THEN
	IF pHabitanDomicilio[1]="0" THEN
	LET pHabitanDomicilio=pHabitanDomicilio[2];
 END IF;
END IF; 

IF LENGTH(pPersDomTrabajan)=2 THEN
	IF pPersDomTrabajan[1]="0" THEN
	LET pPersDomTrabajan=pPersDomTrabajan[2];
 END IF;
END IF;  	        


    INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
        VALUES(pId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_actualiza_ctemovil',current,current);

    SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
    FROM sysmaster:"informix".sysshmvals;
	
	---Valida que el telefono no este registrado mas de una vez
	--LET telefono = TRIM(telefono);
	LET pCelular = TRIM(pCelular);
    SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_telefono)} LIMIT 1 telefono INTO SNumTel from bdinteg:"informix".si_solicitud_movil WHERE telefono = pCelular;
	
    LET SNrows = dbinfo("sqlca.sqlerrd2");     
    IF SNrows > 0 THEN
		SELECT LIMIT 1 TODAY - fecha_insert Dias 
		INTO sDiasDIff FROM (SELECT {+index (bdinteg:"informix".si_solicitud_movil idx_telefono_id)} TODAY, fecha_insert FROM bdinteg:"informix".si_solicitud_movil WHERE telefono = pCelular AND id!= pId ORDER BY fecha_insert DESC);
		--INTO sDiasDIff FROM (SELECT TODAY, fecha_insert FROM si_solicitud_movil WHERE TRIM(telefono) = TRIM(pCelular) AND id!= pId ORDER BY fecha_insert DESC);

        IF sDiasDIff <= 90 THEN               
			UPDATE bdinteg:"informix".si_solicitud_movil
			SET ap_cte_coppel = TRIM(UPPER(pCte_coppel)),
			ap_numcte_coppel = TRIM(pNumcte_coppel),
			apell_paterno = TRIM(UPPER(pApell_paterno)),
			apell_materno = TRIM(UPPER(pApell_materno)),
			nombre1 = TRIM(UPPER(pNombre1)),
			nombre2 = TRIM(UPPER(pNombre2)),
			fecha_nac = TRIM(pFecha_nac),
			sexo = TRIM(UPPER(pSexo)),
			calle = TRIM(UPPER(pCalle)),
			colonia = TRIM(UPPER(pColonia)),
			deleg_mpo = TRIM(UPPER(pMunicipio)),
			edo = TRIM(UPPER(pEstado)),
			cod_postal = TRIM(pCod_Postal),
			domicilio_actual = TRIM(UPPER(pDomicilio)),
			domicilio_alta=TRIM(UPPER(pDomicilio_act)),
			cve_elector = TRIM(UPPER(pClave_IFE)),
			curp = TRIM(UPPER(pCURP)),
			fecha_registro = TRIM(pAnio_Registro),
			estado = TRIM(pCve_Estado),
			municipio = TRIM(pCve_Municipio),
			seccion = TRIM(pSeccion),
			localidad = TRIM(pLocalidad),
			emision = TRIM(pEmision),
			vigencia = TRIM(pVigencia),
			ocr = TRIM(pOCR),
			nivel_ingresos = TRIM(pIngresos),
			edo_civil = TRIM(UPPER(pEdo_Civil)),
			tpo_edo_civil = TRIM(pAniosEdocivil),
			meses_edo_civil = TRIM(pMesesEdocivil),
			tipo_residencia = TRIM(UPPER(pTipoResidencia)),
			tiempo_domicilio = TRIM(pTiempoDomActual),
			actividad = TRIM(pActividad),
			subactividad = TRIM(pSubActividad),
			empresa = TRIM(UPPER(pEmpresa)),
			tel_trabajo = TRIM(pTel_Trabajo),
			tiempo_trabajo = TRIM(pAniosEmpleoActual),
			tiempo_trab_ant = TRIM(pAniosmpleoAnterior),
			Edad = TRIM(pEdad),
			pers_dependen = TRIM(pPersDepenEconom),
			comp_ingresos = TRIM(pComprobIngresos),
			escolaridad = TRIM(UPPER(pEscolaridad)),
			pers_domicilio = TRIM(pHabitanDomicilio),
			pers_trabajan = TRIM(pPersDomTrabajan),
			producto = TRIM(pProducto),
			telefono_casa=TRIM(ptel_casa),
			telefono = TRIM(pCelular),
			carrier = TRIM(pCompTel),
			email = TRIM(pEmail),
			geolocalizacion = TRIM(pGeolocalizacion),
			firma_cc = TRIM(pFirmaCteCc),
			firma_bc = TRIM(pFirmaCteBc),
			firma_buro = TRIM(pFirmaCteBuro),
			fotografias = TRIM(pFotos),
			--ejecutivo=TRIM(pEjecutivo),
			ap_apell_paterno=TRIM(UPPER(pAp_apell_paterno)),
			ap_apell_materno=TRIM(UPPER(pAp_apell_materno)),
			ap_nombre1=TRIM(UPPER(pAp_nombre1)),
			ap_nombre2=TRIM(UPPER(pAp_nombre2)),
			ap_fecha_nac=TRIM(pAp_fecha_nac),
			ap_sexo=TRIM(UPPER(pAp_sexo)),
			ap_calle=TRIM(UPPER(pAp_calle)),
			ap_colonia=TRIM(UPPER(pAp_colonia)),
			ap_deleg_mpo=TRIM(UPPER(pAp_municipio)),
			ap_edo=TRIM(UPPER(pAp_estado)),
			ap_cod_Postal=TRIM(pAp_cod_Postal),
			ap_cve_elector=TRIM(pAp_clave_IFE),
			ap_CURP=TRIM(UPPER(pAp_CURP)),
			ap_fecha_registro=TRIM(pAp_anio_Registro),
			ap_estado=TRIM(pAp_cve_Estado),
			ap_municipio=TRIM(pAp_cve_Municipio),
			ap_seccion=TRIM(pAp_seccion),
			ap_localidad=TRIM(pAp_localidad),
			ap_emision=TRIM(pAp_emision),
			ap_vigencia=TRIM(pAp_vigencia),
			ap_OCR=TRIM(pAp_OCR),
			pais_nac=TRIM(UPPER(pPais_nacimiento)),
			fecha_finparam=vt_fech_hora,
			status_valua=2,
			id_estado=TRIM(pIdEstado),
			id_ciudad=TRIM(pIdCiudad),
			id_colonia=pIdColonia,
			ap_id_estado=TRIM(pAp_Id_Estado),
			ap_id_ciudad=TRIM(pAp_Id_Ciudad),
			ap_id_colonia=pAp_Id_Colonia
		    WHERE id = pId;
           
            LET cCodRet = '00007';
            LET cDesc='Solicitud no procesada. Celular ya registrado.';
            
            SELECT folio, numcte INTO SFolio, SNumcte FROM bdinteg:"informix".si_solicitud_movil WHERE id = pId;
            INSERT INTO si_bitacora_celular_registrado_am(folio, numcliente, celular, fecha)
			VALUES(SFolio,SNumcte,pCelular,TODAY);

            RETURN cCodRet,cDesc;
        ELSE
			UPDATE bdinteg:"informix".si_solicitud_movil
			SET ap_cte_coppel = TRIM(UPPER(pCte_coppel)),
			ap_numcte_coppel = TRIM(pNumcte_coppel),
			apell_paterno = TRIM(UPPER(pApell_paterno)),
			apell_materno = TRIM(UPPER(pApell_materno)),
			nombre1 = TRIM(UPPER(pNombre1)),
			nombre2 = TRIM(UPPER(pNombre2)),
			fecha_nac = TRIM(pFecha_nac),
			sexo = TRIM(UPPER(pSexo)),
			calle = TRIM(UPPER(pCalle)),
			colonia = TRIM(UPPER(pColonia)),
			deleg_mpo = TRIM(UPPER(pMunicipio)),
			edo = TRIM(UPPER(pEstado)),
			cod_postal = TRIM(pCod_Postal),
			domicilio_actual = TRIM(UPPER(pDomicilio)),
			domicilio_alta=TRIM(UPPER(pDomicilio_act)),
			cve_elector = TRIM(UPPER(pClave_IFE)),
			curp = TRIM(UPPER(pCURP)),
			fecha_registro = TRIM(pAnio_Registro),
			estado = TRIM(pCve_Estado),
			municipio = TRIM(pCve_Municipio),
			seccion = TRIM(pSeccion),
			localidad = TRIM(pLocalidad),
			emision = TRIM(pEmision),
			vigencia = TRIM(pVigencia),
			ocr = TRIM(pOCR),
			nivel_ingresos = TRIM(pIngresos),
			edo_civil = TRIM(UPPER(pEdo_Civil)),
			tpo_edo_civil = TRIM(pAniosEdocivil),
			meses_edo_civil = TRIM(pMesesEdocivil),
			tipo_residencia = TRIM(UPPER(pTipoResidencia)),
			tiempo_domicilio = TRIM(pTiempoDomActual),
			actividad = TRIM(pActividad),
			subactividad = TRIM(pSubActividad),
			empresa = TRIM(UPPER(pEmpresa)),
			tel_trabajo = TRIM(pTel_Trabajo),
			tiempo_trabajo = TRIM(pAniosEmpleoActual),
			tiempo_trab_ant = TRIM(pAniosmpleoAnterior),
			Edad = TRIM(pEdad),
			pers_dependen = TRIM(pPersDepenEconom),
			comp_ingresos = TRIM(pComprobIngresos),
			escolaridad = TRIM(UPPER(pEscolaridad)),
			pers_domicilio = TRIM(pHabitanDomicilio),
			pers_trabajan = TRIM(pPersDomTrabajan),
			producto = TRIM(pProducto),
			telefono_casa=TRIM(ptel_casa),
			telefono = TRIM(pCelular),
			carrier = TRIM(pCompTel),
			email = TRIM(pEmail),
			geolocalizacion = TRIM(pGeolocalizacion),
			firma_cc = TRIM(pFirmaCteCc),
			firma_bc = TRIM(pFirmaCteBc),
			firma_buro = TRIM(pFirmaCteBuro),
			fotografias = TRIM(pFotos),
			--ejecutivo=TRIM(pEjecutivo),
			ap_apell_paterno=TRIM(UPPER(pAp_apell_paterno)),
			ap_apell_materno=TRIM(UPPER(pAp_apell_materno)),
			ap_nombre1=TRIM(UPPER(pAp_nombre1)),
			ap_nombre2=TRIM(UPPER(pAp_nombre2)),
			ap_fecha_nac=TRIM(pAp_fecha_nac),
			ap_sexo=TRIM(UPPER(pAp_sexo)),
			ap_calle=TRIM(UPPER(pAp_calle)),
			ap_colonia=TRIM(UPPER(pAp_colonia)),
			ap_deleg_mpo=TRIM(UPPER(pAp_municipio)),
			ap_edo=TRIM(UPPER(pAp_estado)),
			ap_cod_Postal=TRIM(pAp_cod_Postal),
			ap_cve_elector=TRIM(pAp_clave_IFE),
			ap_CURP=TRIM(UPPER(pAp_CURP)),
			ap_fecha_registro=TRIM(pAp_anio_Registro),
			ap_estado=TRIM(pAp_cve_Estado),
			ap_municipio=TRIM(pAp_cve_Municipio),
			ap_seccion=TRIM(pAp_seccion),
			ap_localidad=TRIM(pAp_localidad),
			ap_emision=TRIM(pAp_emision),
			ap_vigencia=TRIM(pAp_vigencia),
			ap_OCR=TRIM(pAp_OCR),
			pais_nac=TRIM(UPPER(pPais_nacimiento)),
			fecha_finparam=vt_fech_hora,
			status_valua=0,
			id_estado=TRIM(pIdEstado),
			id_ciudad=TRIM(pIdCiudad),
			id_colonia=pIdColonia,
			ap_id_estado=TRIM(pAp_Id_Estado),
			ap_id_ciudad=TRIM(pAp_Id_Ciudad),
			ap_id_colonia=pAp_Id_Colonia
			WHERE id = pId AND (status_valua IS NULL OR status_valua =0);
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00006';
				LET cDesc='La solicitud ya fue procesada anteriormente.';
				RETURN cCodRet,cDesc;
			END IF;   
		 
		   LET cDesc='Solicitud Procesada Satisfactoriamente...';
		   RETURN cCodRet,cDesc;
		END IF;
    ELSE
		UPDATE bdinteg:"informix".si_solicitud_movil
		SET ap_cte_coppel = TRIM(UPPER(pCte_coppel)),
		ap_numcte_coppel = TRIM(pNumcte_coppel),
		apell_paterno = TRIM(UPPER(pApell_paterno)),
		apell_materno = TRIM(UPPER(pApell_materno)),
		nombre1 = TRIM(UPPER(pNombre1)),
		nombre2 = TRIM(UPPER(pNombre2)),
		fecha_nac = TRIM(pFecha_nac),
		sexo = TRIM(UPPER(pSexo)),
		calle = TRIM(UPPER(pCalle)),
		colonia = TRIM(UPPER(pColonia)),
		deleg_mpo = TRIM(UPPER(pMunicipio)),
		edo = TRIM(UPPER(pEstado)),
		cod_postal = TRIM(pCod_Postal),
		domicilio_actual = TRIM(UPPER(pDomicilio)),
		domicilio_alta=TRIM(UPPER(pDomicilio_act)),
		cve_elector = TRIM(UPPER(pClave_IFE)),
		curp = TRIM(UPPER(pCURP)),
		fecha_registro = TRIM(pAnio_Registro),
		estado = TRIM(pCve_Estado),
		municipio = TRIM(pCve_Municipio),
		seccion = TRIM(pSeccion),
		localidad = TRIM(pLocalidad),
		emision = TRIM(pEmision),
		vigencia = TRIM(pVigencia),
		ocr = TRIM(pOCR),
		nivel_ingresos = TRIM(pIngresos),
		edo_civil = TRIM(UPPER(pEdo_Civil)),
		tpo_edo_civil = TRIM(pAniosEdocivil),
		meses_edo_civil = TRIM(pMesesEdocivil),
		tipo_residencia = TRIM(UPPER(pTipoResidencia)),
		tiempo_domicilio = TRIM(pTiempoDomActual),
		actividad = TRIM(pActividad),
		subactividad = TRIM(pSubActividad),
		empresa = TRIM(UPPER(pEmpresa)),
		tel_trabajo = TRIM(pTel_Trabajo),
		tiempo_trabajo = TRIM(pAniosEmpleoActual),
		tiempo_trab_ant = TRIM(pAniosmpleoAnterior),
		Edad = TRIM(pEdad),
		pers_dependen = TRIM(pPersDepenEconom),
		comp_ingresos = TRIM(pComprobIngresos),
		escolaridad = TRIM(UPPER(pEscolaridad)),
		pers_domicilio = TRIM(pHabitanDomicilio),
		pers_trabajan = TRIM(pPersDomTrabajan),
		producto = TRIM(pProducto),
		telefono_casa=TRIM(ptel_casa),
		telefono = TRIM(pCelular),
		carrier = TRIM(pCompTel),
		email = TRIM(pEmail),
		geolocalizacion = TRIM(pGeolocalizacion),
		firma_cc = TRIM(pFirmaCteCc),
		firma_bc = TRIM(pFirmaCteBc),
		firma_buro = TRIM(pFirmaCteBuro),
		fotografias = TRIM(pFotos),
		--ejecutivo=TRIM(pEjecutivo),
		ap_apell_paterno=TRIM(UPPER(pAp_apell_paterno)),
		ap_apell_materno=TRIM(UPPER(pAp_apell_materno)),
		ap_nombre1=TRIM(UPPER(pAp_nombre1)),
		ap_nombre2=TRIM(UPPER(pAp_nombre2)),
		ap_fecha_nac=TRIM(pAp_fecha_nac),
		ap_sexo=TRIM(UPPER(pAp_sexo)),
		ap_calle=TRIM(UPPER(pAp_calle)),
		ap_colonia=TRIM(UPPER(pAp_colonia)),
		ap_deleg_mpo=TRIM(UPPER(pAp_municipio)),
		ap_edo=TRIM(UPPER(pAp_estado)),
		ap_cod_Postal=TRIM(pAp_cod_Postal),
		ap_cve_elector=TRIM(pAp_clave_IFE),
		ap_CURP=TRIM(UPPER(pAp_CURP)),
		ap_fecha_registro=TRIM(pAp_anio_Registro),
		ap_estado=TRIM(pAp_cve_Estado),
		ap_municipio=TRIM(pAp_cve_Municipio),
		ap_seccion=TRIM(pAp_seccion),
		ap_localidad=TRIM(pAp_localidad),
		ap_emision=TRIM(pAp_emision),
		ap_vigencia=TRIM(pAp_vigencia),
		ap_OCR=TRIM(pAp_OCR),
		pais_nac=TRIM(UPPER(pPais_nacimiento)),
		fecha_finparam=vt_fech_hora,
		status_valua=0,
		id_estado=TRIM(pIdEstado),
		id_ciudad=TRIM(pIdCiudad),
		id_colonia=pIdColonia,
		ap_id_estado=TRIM(pAp_Id_Estado),
		ap_id_ciudad=TRIM(pAp_Id_Ciudad),
		ap_id_colonia=pAp_Id_Colonia
		WHERE id = pId AND (status_valua IS NULL OR status_valua =0);
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00006';
			LET cDesc='La solicitud ya fue procesada anteriormente.';
			RETURN cCodRet,cDesc;
		END IF;   
	 
	   LET cDesc='Solicitud Procesada Satisfactoriamente...';
	   RETURN cCodRet,cDesc;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, PEDRO JIMENEZ GUZMAN',
'FOLIO: 1484',
'DESCRIPCION: Actualiza la tabla si_solicitud_movil con los parametros recibidos',
'FECHA: 10/02/2015',
'VERSION: 10022015.1144',
'SUSTENTO: SE DEFINIO CON JAIME GONZALEZ Y VICTOR HUGO SANCHEZ MENDOZA EN EL REQUERIMIENTO',
'RQI 61 116? Alta movil',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_insbitsmstelcte_apps(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5),pdigito_ver CHAR(6), ptelefono CHAR(10), pEmail  CHAR(100), pteclea_ejecut CHAR(100), pbandera boolean)

RETURNING char(5) as codret ;

DEFINE iSqlErr			INTEGER;
DEFINE iNumRnd          INTEGER;
DEFINE iExist           INTEGER;
DEFINE dNumRnd2         DECIMAL(10,0);
DEFINE cCodigo          CHAR(6);
DEFINE cCodSp1          CHAR(5);
DEFINE cCodSp           CHAR(5);
DEFINE pEmail 			CHAR(100);
DEFINE pSec		  		CHAR(10);

LET iNumRnd     =   0;
LET iExist	    =   0;
LET dNumRnd2    =   0;
LET cCodigo     =   '';
LET cCodSp1     =   '00000';
LET cCodSp      =   '00000';
LET pEmail		= 	'';
LET pSec		= 	'';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	--SET DEBUG FILE TO "/informix/ireb/correo/sp_insbitsmstelcte_apps.out";
    --TRACE ON; 
	
	SELECT correo_elec, MAX(secuencia)  
	INTO pEmail, pSec
	FROM bdinteg:si_correos 
	WHERE  status_correo = 'A' 
	AND numcte = pnumcte
	and tipo_correo='1'
	GROUP BY correo_elec;

	
	IF (LENGTH(TRIM(pdigito_ver)) = 4) THEN
		
		--*****OPCION 1 DE INSERCION*****--
		IF popcion='1' THEN		
				
				SELECT count(numcte) INTO iExist 
					FROM bdinteg: "informix".si_bitsmstelsms 
					WHERE numcte=pnumcte 
					AND telefono=ptelefono 
					AND fecha::date = TODAY 
					AND bandera='f';
			   
			    IF (iExist = 0) THEN
				
					INSERT INTO bdinteg: "informix".si_bitsmstelsms(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
					VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
		
				ELSE
			 
					FOREACH
					
						SELECT LIMIT 1 digito_ver INTO pdigito_ver 
							FROM "informix".si_bitsmstelsms 
							WHERE numcte=pnumcte 
							AND telefono=ptelefono
							AND fecha::date = TODAY
							AND bandera='f'
							ORDER BY fecha DESC
							
					END FOREACH;	
					
			    END IF;

  			    IF (psucursal = '5007') THEN --MENSJA SMS PARA LAS APPS

					--Envia SMS
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)					
					INTO cCodSp;  				
					
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'APP_CLVCEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail , ptelefono, 1, 0, 0, 0, 0,current,current)										
					INTO cCodSp1;  									
					
					IF cCodSp <> '00000' AND cCodSp1 <> '00000' THEN
						LET cCodSp='00002'; 
						--LET cMensajeRet = 'ERROR EN LATINIA';
					ELSE
						LET cCodSp='00000'; 
					END IF;
					
				ELSE
			
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;					   
					  
				END IF;
					   
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
		ELIF popcion='2' THEN
		
				SELECT count(numcte) INTO iExist 
					FROM bdinteg: "informix".si_bitsmstelsms 
					WHERE numcte=pnumcte AND ejecutivo=pejecutivo 
					AND sucursal=psucursal 
					AND fecha::date = TODAY 
					AND teclea_ejecut IS NULL;
				
				IF (iExist > 0) THEN 
				
					UPDATE bdinteg: "informix".si_bitsmstelsms SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
					
				ELSE
				
					LET cCodSp  =  '00001';
					Return cCodSp;
					
				END IF;
				
				--AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
				IF pbandera<>'F' or pbandera<>'f' THEN
					UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
				END IF;
				

		END IF; 
		
	ELSE -- ENTONCES ES DE 6
	
		--*****OPCION 1 DE INSERCION*****--
		IF popcion='1' THEN		
			   
				SELECT count(numcte) INTO iExist FROM bdinteg: "informix".si_bitsmstelsms_bpi 
				WHERE numcte=pnumcte 
				AND telefono=ptelefono 
				AND fecha::date = TODAY AND bandera='f';	   

			    IF (iExist = 0) THEN
				   INSERT INTO bdinteg: "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
				ELSE
					FOREACH
						SELECT LIMIT 1 digito_ver INTO pdigito_ver 
						FROM "informix".si_bitsmstelsms_bpi 
						WHERE numcte=pnumcte and telefono=ptelefono
						AND fecha::date = TODAY 
						AND bandera='f'
						ORDER BY fecha DESC
					END FOREACH;
				END IF;
			
			   IF (psucursal = '5007') THEN  --MENSJA SMS PARA LAS APPS		
			   
					--Envia SMS
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;  				
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail, ptelefono, 1, 0, 0, 0, 0,current,current)										
					INTO cCodSp1;  									
					
					IF cCodSp <> '00000' AND cCodSp1 <> '00000' THEN
					LET cCodSp='00002'; 
					--LET cMensajeRet = 'ERROR EN LATINIA';
					ELSE
					LET cCodSp='00000'; 
					END IF;
			
					
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;
				   
				END IF;
		
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--		
		ELIF popcion='2' THEN
		
				SELECT count(numcte) into iExist FROM bdinteg: "informix".si_bitsmstelsms_bpi 
				WHERE numcte=pnumcte 
				AND ejecutivo=pejecutivo 
				AND sucursal=psucursal 
				AND fecha::date = TODAY 
				AND teclea_ejecut IS NULL;				
				
				IF (iExist > 0) THEN 
				
					UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;

				ELSE

					LET cCodSp  =  '00001';
					Return cCodSp;

				END IF;
				
				--AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
				
				IF pbandera<>'F' or pbandera<>'f' THEN
					UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
				END IF;

		END IF;  
	END IF;

RETURN cCodSp;
END
END PROCEDURE;