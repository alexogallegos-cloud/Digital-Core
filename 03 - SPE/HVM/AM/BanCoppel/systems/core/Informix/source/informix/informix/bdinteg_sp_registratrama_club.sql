CREATE PROCEDURE "informix".sp_registratrama_club
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pNumCteCoppel CHAR(20),
   pNumPoliza CHAR(20),
   pTrama CHAR(4000),
   pFecha CHAR(21),
   pEnvio CHAR(1),
   pOpcion CHAR(1)
 )
RETURNING CHAR(6) AS CodRet,
		  CHAR(25) as FechaInsert

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE	cFechaInsert CHAR(19);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cFechaInsert = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet,cFechaInsert;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_registratrama_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pOpcion,'') <> ''  THEN

		LET pOpcion = TRIM(pOpcion);
		LET pFecha = TRIM(pFecha);
		
		IF pOpcion= '1' THEN
			IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTrama,'') <> '' THEN
				LET cFechaInsert = CURRENT YEAR TO SECOND;
				LET cFechaInsert= TRIM(cFechaInsert);
				Insert into "informix".si_club_servicio (empresa,numcte,numcte_coppel,num_poliza,trama,fecha,envio)
									                      values(pEmpresa,pNumCte,pNumCteCoppel,pNumPoliza,pTrama,cFechaInsert,'0');
			ELSE
				LET cCodRet = '000001'; 
			END IF;	
		END IF;
		
		IF TRIM(pOpcion)= '2' THEN
			IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pFecha,'') <> '' AND NVL(pEnvio,'') <> '' THEN
				LET pNumCte=TRIM(pNumCte);
				LET pEmpresa=TRIM(pEmpresa);
				LET pEnvio=TRIM(pEnvio);
			
				UPDATE "informix".si_club_servicio 
				SET envio = pEnvio 
				WHERE numcte = pNumCte AND
				fecha = pFecha;
				LET cFechaInsert = pFecha;
			ELSE
				LET cCodRet = '000001'; 
			END IF;	
		END IF;
		
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	
	RETURN cCodRet, cFechaInsert;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:02/Jul/2014",
"Descripción: Se crea SP para registrar todas las tramas del Club de Proteccion que se envíen a Coppel",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdinteg";

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
pPais_nacimiento			CHAR(3))

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

--SET DEBUG FILE TO "/home/sysifx/Aracely/bdinteg/opt/sp_actualiza_ctemovil.out";
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
			status_valua=2
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
			status_valua=0	
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
		status_valua=0	
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
'SUSTENTO: SE DEFINIO CON JAIME GONZÃÂÃÂÃÂLEZ Y VICTOR HUGO SÃÂÃÂÃÂNCHEZ MENDOZA EN EL REQUERIMIENTO',
'RQI 61 116? Alta mÃÂÃÂÃÂ³vil',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_inserta_erridbox(pSucursal CHAR(5), pError CHAR(100), pEjecutivo CHAR(8))
RETURNING CHAR(5) AS CodRet;

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

LET cCodRet = '00000';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet;	
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_calcularrfc.out';
    --TRACE ON;

    INSERT INTO  bdinteg:"informix".si_biterr_idbox(sucursal, error, ejecutivo, fecha) 
    VALUES(pSucursal, pError, pEjecutivo, current);


RETURN cCodRet;
END
END PROCEDURE 
DOCUMENT
'DESCRIPCION: Pertenece a la base de datos bdinteg, registra error generado por idbox';

CREATE PROCEDURE "informix".sp_cifra_archivo(pCodigo char(20)) 
returning 
          char(06) as resultado,
          char(80) as mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define vEmpresa             char(3);
define iCodRet              integer;
define cCodRet              char(06);
define isam_err             integer;
define visam_err            integer;
define error_info	          char(150);
define verror_info	        char(150);
define vUsuario             char(20);
define vCodigo              char(20);
define vLLave               char(200);
define vNomarch             char(100);
define vRutaOrigen          char(100);
define vRutaDestino         char(100);
define vNomarchSalida       char(100);
define vRutaOriginales      char(100);
define vNomarch_salida      char(100);
define vArmaShellExt        char(5000);
define v_ext_entrada          char(10);
define v_ext_salida           char(10);
define v_retorno_linea        char(1);
define vDirTemp				char(20);


define vfecha_hoy           DATE;
define vPri_dia_mes         DATE;
define vDia, vMes           char(2);
define vAnio                char(4);
define vBlinda              char(50);

let cMensajeRet             = 'Proceso Exitoso';
let cMensajeRet2            = '';
let vEmpresa                = '001';
let iCodRet                 = 0;
let cCodRet                 = '000000';
let isam_err                = 0;
let visam_err               = 0;
let error_info              = '';
let verror_info             = '';
let vUsuario                = '';
let vCodigo                 = '';
let vLLave                  = '';
let vNomarch                = '';
let vRutaOrigen             = '';
let vRutaDestino            = '';
let vNomarchSalida          = '';
let vfecha_hoy              = date(1);
let vPri_dia_mes            = date(1);
let vDia                    = '';
let vMes                    = '';
let vAnio                   = '';
let vRutaOriginales         = '';
let vNomarch_salida         = '';
let vBlinda                 = '';
let vArmaShellExt		        = '';
let v_ext_entrada           = '';
let v_ext_salida            = '';
let v_retorno_linea         = '';
let vDirTemp				= '/RESPALDOSNEW';

--**************************** Control de errores ******************************
begin
    on exception set iCodRet, isam_err, error_info
    	if iCodRet <> 0 then
          	let cCodRet = iCodRet;
            --let cMensajeRet ='Error al blindar archivo >> '|| vNomarch;
            let visam_err = isam_err;
            let verror_info = error_info;
            let cMensajeRet =  visam_err || ' - ' || trim(verror_info);
                	
  			return cCodRet,cMensajeRet ;
      end if;
    end exception;

--  Set debug file to "/tmp/sp_cifra_archivo.out";
--  trace on;

    let vCodigo = trim(pCodigo);
    let vBlinda = 'blinda_archivo_' || trim(vCodigo) || '.sh'; 

    FOREACH
      SELECT trim(usuario), trim(llave), trim(nomarch), trim(ruta_origen), trim(nomarch_salida),trim(ruta_destino), trim(ruta_originales), trim(ext_entrada),
             trim(ext_salida), trim(retorno_linea)
        INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales, v_ext_entrada, v_ext_salida, v_retorno_linea
        FROM bdinteg:si_configura_pgp
       WHERE codigo = vCodigo
        order by secuencia
  
      IF vUsuario <>  user THEN
          LET cCodRet = '00200';
          LET cMensajeRet = 'Usuario para cifrado incorrecto';
          return cCodRet,cMensajeRet;
      END IF;
     
      IF TRIM(v_ext_salida) = '' or TRIM(v_ext_salida) IS NULL THEN let v_ext_salida = 'pgp'; END IF;  

      IF TRIM(v_retorno_linea) = 'S' THEN
        --SYSTEM ' echo " for file in '|| trim(vRutaOrigen) || '*.txt; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';  ---MACF  
        --system ' echo " for file in '|| trim(vRutaOrigen) || '*.' || trim(v_ext_entrada) || '; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system ' echo " for file in '|| trim(vRutaOrigen) || trim(vNomarch) || '.' || trim(v_ext_entrada) || '; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system ' echo "  do mv '|| '\$file'||' \$file''.TX''" >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh'; 
        system ' echo "  sed ''s/$/\r/g''' ||' \$file''.TX'' >> \$file " >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh'; 
        system ' echo "  rm ' || '\$file''.TX'' " >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';     
        system ' echo " done' || '">>' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system 'chmod 777 ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system '/usr/bin/sh ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
      END IF;
    
   
      SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || trim(vUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin">' || trim(vRutaOrigen) || trim(vBlinda);
      SYSTEM 'echo "export HOME=/home/' || trim(vUsuario) || '">>' || trim(vRutaOrigen) || trim(vBlinda); 
      SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i ' || trim(vRutaOrigen) || trim(vNomarch) || ' -r ' || '''' || trim(vLLave) || '''' ||" --armor --compression --output " || trim(vRutaDestino) || trim(vNomarch_salida) ||" --temp-dir " || trim(vDirTemp) ||'">>' || trim(vRutaOrigen) || trim(vBlinda) ;
      SYSTEM 'chmod 777 ' || trim(vRutaOrigen) || trim(vBlinda);   
      SYSTEM '/usr/bin/sh ' || trim(vRutaOrigen) || trim(vBlinda);
      SYSTEM 'mv ' || trim(vRutaOrigen) || trim(vNomarch) || ' ' || vRutaOriginales;
     
      
      system ' echo " for file in '|| trim(vRutaDestino) || '*.asc; " > ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';  
      --SYSTEM ' echo "  do mv '|| '\$file'||' \`echo \$file | sed ''s/\(.*\.\)asc/\1pgp/''\`;' || ' " >> ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh'; 
      system ' echo "  do mv '|| '\$file'||' \`echo \$file | sed ''s/\(.*\.\)asc/\1' || trim(v_ext_salida) || '/''\`;' || ' " >> ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';
      system ' echo " done' || '">>' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';
      system '/usr/bin/sh ' || trim(vRutaDestino)  || 'cambia_ext_' || trim(vCodigo) || '.sh';
    
         
    END FOREACH
    
    return cCodRet,cMensajeRet;

end;
end procedure;