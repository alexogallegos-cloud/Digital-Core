CREATE PROCEDURE "informix".sp_alta_ctemovil_pba24(pFolio char(12))
RETURNING CHAR(5) as codret, CHAR(20) as Cliente;

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sRetCod          CHAR(5);
DEFINE ssCodRet         CHAR(6);
DEFINE ssMensaje        CHAR(80);
DEFINE sErrProc		CHAR(5);
DEFINE sPaterno         CHAR(26);
DEFINE sMaterno         CHAR(26);

--VARIABLES PARA COMPARACION DE NOMBRES
DEFINE sNom1A           CHAR(26);
DEFINE sNom2A           CHAR(26);
DEFINE sApPatA          CHAR(26);
DEFINE sApMatA          CHAR(26);
DEFINE sFecNacA         CHAR(10);
DEFINE sNom1B           CHAR(26);
DEFINE sNom2B           CHAR(26);
DEFINE sApPatB          CHAR(26);
DEFINE sApMatB          CHAR(26);
DEFINE sFecNacB         CHAR(10);
DEFINE dPorcentaje      DECIMAL(6,1);
DEFINE dParamPorc       DECIMAL(6,1);
DEFINE sRFCCortoA       CHAR(10);
DEFINE sRFCCortoB       CHAR(10);
DEFINE sOCRMovil        CHAR(9);

--VARIABLES PARA COMPARACION DE DATOS
DEFINE sgrupo           CHAR(3);
DEFINE spregunta        CHAR(50);
DEFINE selemento        INTEGER;
DEFINE sdescripcion     CHAR(50);
DEFINE sparametro_sp    CHAR(15);
DEFINE scampo           CHAR(15);
DEFINE sclave           CHAR(2);
DEFINE sdescrip_clave   CHAR(50);

DEFINE sid                INTEGER;
DEFINE snumcte            CHAR(20);
DEFINE scte_coppel        CHAR(1);
DEFINE snumcte_coppel     CHAR(20);
DEFINE sapell_paterno     CHAR(26);
DEFINE sapell_materno     CHAR(26);
DEFINE snombre1           CHAR(26);
DEFINE snombre2           CHAR(26);
DEFINE sfecha_nac         CHAR(10);
DEFINE srfc               CHAR(13);
DEFINE ssexo              CHAR(1);
DEFINE scalle             CHAR(40);
DEFINE scolonia           CHAR(60);
DEFINE sdeleg_mpo         CHAR(40);
DEFINE sedo               CHAR(40);
DEFINE scod_postal        CHAR(5);
DEFINE sdomicilio_actual  CHAR(1);
DEFINE sdomicilio_alta    CHAR(1);
DEFINE scve_elector       CHAR(18);
DEFINE scurp              CHAR(18);
DEFINE sfecha_registro    CHAR(7);
DEFINE sestado            CHAR(2);
DEFINE smunicipio         CHAR(3);
DEFINE sseccion           CHAR(4);
DEFINE slocalidad         CHAR(4);
DEFINE semision           CHAR(4);
DEFINE svigencia          CHAR(4);
DEFINE socr               CHAR(13);
DEFINE snivel_ingresos    CHAR(8);
DEFINE sedo_civil         CHAR(1);
DEFINE stpo_edo_civil     CHAR(2);
DEFINE smeses_edo_civil   CHAR(2);
DEFINE stipo_residencia   CHAR(1);
DEFINE stiempo_domicilio  CHAR(2);
DEFINE sactividad         CHAR(2);
DEFINE ssubactividad      CHAR(2);
DEFINE sempresa           CHAR(60);
DEFINE stel_trabajo       CHAR(10);
DEFINE stiempo_trabajo    CHAR(2);
DEFINE stiempo_trab_ant   CHAR(2);
DEFINE sedad              CHAR(2);
DEFINE spers_dependen     CHAR(2);
DEFINE scomp_ingresos     CHAR(2);
DEFINE sescolaridad       CHAR(2);
DEFINE spers_domicilio    CHAR(2);
DEFINE spais_nacimiento	  CHAR(3);
DEFINE spers_trabajan     CHAR(2);
DEFINE sproducto          CHAR(3);
DEFINE stelefono_casa     CHAR(10);
DEFINE stelefono          CHAR(10);
DEFINE scarrier           CHAR(1);
DEFINE semail             CHAR(100);
DEFINE snum_tdc_coppel    CHAR(12);
DEFINE sstatus_tdc_coppel CHAR(2);
DEFINE snum_prestamo      CHAR(12);
DEFINE sstatus_prestamo   CHAR(2);
DEFINE snum_tdc_bcoppel   CHAR(12);
DEFINE sstatus_tdc_bcoppel CHAR(2);
DEFINE ssituacion_esp     CHAR(1);
DEFINE scausa             CHAR(4);
DEFINE sfolio             CHAR(12);
DEFINE sgeolocalizacion   CHAR(20);
DEFINE sfirma_bc          CHAR(1);
DEFINE sfotografias       CHAR(1);
DEFINE sprocesado_trans   CHAR(1);
DEFINE sfolio_procesado   CHAR(1);
DEFINE sstatus_solicitud  CHAR(8);
DEFINE sejecutivo         CHAR(8);
DEFINE sfecha_insert      DATE;

DEFINE svt_seccion      CHAR(1);
DEFINE svt_empresa      CHAR(3);
DEFINE svt_numcte       CHAR(20);
DEFINE svt_ejecutivo    CHAR(8);
DEFINE svt_fecha_hoy    DATE;
DEFINE svt_elemento     INTEGER;
DEFINE svt_descrip      CHAR(50);

DEFINE ssvt_seccion     CHAR(3);
DEFINE svt_grupo        CHAR(3);
DEFINE svt_folio        CHAR(12);
DEFINE ssvt_elemento    INTEGER;
DEFINE svt_cod_ret      CHAR(3);
DEFINE svt_clave        CHAR(2);

DEFINE sivt_empresa     CHAR(3);
DEFINE sivt_secuencia   INTEGER;
DEFINE sivt_descripcion CHAR(20);
DEFINE siivt_secuencia  INTEGER;

DEFINE svt_campo1       CHAR(1);
DEFINE svt_campo2       CHAR(1);
DEFINE svt_campo3       CHAR(1);

DEFINE svt_producto     CHAR(4);
DEFINE svt_mensaje      VARCHAR(200);
DEFINE svt_dia          CHAR(2);
DEFINE svt_mes          CHAR(2);
DEFINE svt_year         CHAR(4);
DEFINE svt_solic1       CHAR(20);
DEFINE svt_solic2       CHAR(20);
DEFINE svt_solic3       CHAR(20);
DEFINE svt_sucursal     CHAR(4);

DEFINE ssvt_Pais        CHAR(3);
DEFINE ssvt_sEdo        CHAR(2);
DEFINE ssvt_sCiudad     CHAR(5);
DEFINE ssvt_sCP         CHAR(5);
DEFINE ssvt_sNumCiudad  CHAR(6);
DEFINE ssvt_sColonia    CHAR(6);
DEFINE ssvt_sMpo        CHAR(5);
DEFINE vt_fech_hora     CHAR(19);
DEFINE vt_fech_hora2    CHAR(19);
DEFINE sSPosc1          CHAR(1);
DEFINE sSPosc2          CHAR(1);
DEFINE sSPosc3          CHAR(1);
DEFINE sSPosc4          CHAR(1);
DEFINE sSPosc5          CHAR(1);
DEFINE sTpoCte 			CHAR(1);

DEFINE sAP_paterno     CHAR(26);
DEFINE sAP_materno     CHAR(26);
DEFINE sAP_nombre1     CHAR(26);
DEFINE sAP_nombre2     CHAR(26);
DEFINE sAP_fecha_nac   CHAR(10);
DEFINE sAP_rfc         CHAR(13);
DEFINE sAP_dia          CHAR(2);
DEFINE sAP_mes          CHAR(2);
DEFINE sAP_year         CHAR(4);
DEFINE sAP_fecnac       CHAR(10);

DEFINE o_telefono1      CHAR(13);
DEFINE o_telefono2      CHAR(13);
DEFINE o_telefono3      CHAR(13);
DEFINE o_extension      CHAR(5);
DEFINE vTipoTel         SMALLINT;
DEFINE vCanal           SMALLINT;
DEFINE v_CodRetTel      CHAR(5);

DEFINE sDesc		    CHAR(50);

DEFINE cCodRetLN	    CHAR(6);
DEFINE sFechaLN         CHAR(10);

LET iSqlErr          =0;
LET sCodRet          ='00000';
LET sRetCod          ="99999";
LET sErrProc         ='';
LET sNumCte          ='';
LET sRFC             ='';
LET sPaterno         ='';
LET sMaterno         ='';
LET sNombre1         ='';
LET sNombre2         ='';
LET sFecha_Nac       ='';
LET sTelefono        ='';

LET sNom1A           ='';
LET sNom2A           ='';
LET sApPatA          ='';
LET sApMatA          ='';
LET sFecNacA         ='';
LET sNom1B           ='';
LET sNom2B           ='';
LET sApPatB          ='';
LET sApMatB          ='';
LET sFecNacB         ='';
LET dPorcentaje      =0;
LET dParamPorc       =0;
LET sRFCCortoA       ='';
LET sRFCCortoB       ='';
LET sOCRMovil        ='';
LET sOCR             ='';
LET sEmpresa         ='';

LET sseccion         = "";
LET sgrupo           = "";
LET spregunta        = "";
LET selemento        = 0;
LET sdescripcion     = "";
LET sparametro_sp    = "";
LET scampo           = "";
LET sclave           = "";
LET sdescrip_clave   = "";

LET sid                = 0;
LET snumcte            = "";
LET scte_coppel        = "";
LET snumcte_coppel     = "";
LET sapell_paterno     = "";
LET sapell_materno     = "";
LET snombre1           = "";
LET snombre2           = "";
LET sfecha_nac         = "";
LET srfc               = "";
LET ssexo              = "";
LET scalle             = "";
LET scolonia           = "";
LET sdeleg_mpo         = "";
LET sedo               = "";
LET scod_postal        = "";
LET sdomicilio_actual  = "";
LET sdomicilio_alta    = "";
LET scve_elector       = "";
LET scurp              = "";
LET sfecha_registro    = "";
LET sestado            = "";
LET smunicipio         = "";
LET sseccion           = "";
LET slocalidad         = "";
LET semision           = "";
LET svigencia          = "";
LET socr               = "";
LET snivel_ingresos    = "";
LET sedo_civil         = "";
LET stpo_edo_civil     = "";
LET smeses_edo_civil   = "";
LET stipo_residencia   = "";
LET stiempo_domicilio  = "";
LET sactividad         = "";
LET ssubactividad      = "";
LET sempresa           = "";
LET stel_trabajo       = "";
LET stiempo_trabajo    = "";
LET stiempo_trab_ant   = "";
LET sedad              = "";
LET spers_dependen     = "";
LET scomp_ingresos     = "";
LET sescolaridad       = "";
LET spers_domicilio    = "";
LET spais_nacimiento   = "";
LET spers_trabajan     = "";
LET sproducto          = "";
LET stelefono_casa     = "";
LET stelefono          = "";
LET scarrier           = "";
LET semail             = "";
LET snum_tdc_coppel    = "";
LET sstatus_tdc_coppel = "";
LET snum_prestamo      = "";
LET sstatus_prestamo   = "";
LET snum_tdc_bcoppel   = "";
LET sstatus_tdc_bcoppel = "";
LET ssituacion_esp     = "";
LET scausa             = "";
LET sfolio             = "";
LET sgeolocalizacion   = "";
LET sfirma_bc        = "";
LET sfotografias       = "";
LET sprocesado_trans   = "";
LET sfolio_procesado   = "";
LET sstatus_solicitud  = "";
LET sfecha_insert      = "";
LET svt_empresa        = "";
LET svt_numcte         = "";
LET svt_ejecutivo      = "";
LET sejecutivo         = "";
LET svt_fecha_hoy      = "";
LET svt_elemento       = 0;
LET svt_descrip        = "";

LET ssvt_seccion       = "";
LET svt_grupo          = "";
LET svt_folio          = "";
LET ssvt_elemento      = 0;
LET svt_cod_ret        = "";
LET svt_clave          = "";

LET ssCodRet           = "000000";
LET ssMensaje          = " ";
LET sivt_empresa       = "";
LET sivt_secuencia     = 0;
LET sivt_descripcion   = "";
LET siivt_secuencia    = 4;

LET svt_campo1         = "";
LET svt_campo2         = "";
LET svt_campo3         = "";
LET svt_producto       = "";
LET svt_empresa        = "001";
LET svt_mensaje        = "En este acto otorgo expresamente mi consentimiento para que EL RESPONSABLE pueda utilizar mis datos personales exclusivamente para los fines que se encuentran asentados en el Aviso de Privacidad.";
LET svt_dia            = "";
LET svt_mes            = "";
LET svt_year           = "";
LET svt_solic1         = "";
LET svt_solic2         = "";
LET svt_solic3         = "";
LET svt_sucursal       = "";

LET ssvt_Pais          = "";
LET ssvt_sEdo          = "";
LET ssvt_sCiudad       = "";
LET ssvt_sCP           = "";
LET ssvt_sNumCiudad    = "";
LET ssvt_sColonia      = "";
LET ssvt_sMpo          = "";
LET vt_fech_hora = current hour to fraction;
LET sSPosc1            = '';
LET sSPosc2            = '';
LET sSPosc3            = '';
LET sSPosc4            = '';
LET sSPosc5            = '';
LET sTpoCte			   = '';

LET sAP_paterno        = '';
LET sAP_materno        = '';
LET sAP_nombre1        = '';
LET sAP_nombre2        = '';
LET sAP_fecha_nac      = '';
LET sAP_rfc            = '';
LET sAP_dia            = '';
LET sAP_mes            = '';
LET sAP_year           = '';
LET sAP_fecnac         = '';

LET o_telefono1        ='';
LET o_telefono2        ='';
LET o_telefono3        ='';
LET o_extension        ='';
LET vTipoTel           =0;
LET vCanal             =1;
LET v_CodRetTel        ='';

LET sDesc              ='';

LET cCodRetLN           ='';   
LET sFechaLN            ='';   

BEGIN
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
	   RETURN iSqlErr, snumcte;
        END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SET DEBUG FILE TO '/tmp/sp_alta_ctemovil.out';
TRACE ON;

SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
FROM bdinteg:si_fechas
WHERE empresa = '001';

DELETE FROM si_valida_folio_detalle
WHERE folio = pFolio
AND fecha = svt_fecha_hoy;

DELETE FROM bdisolic:ss_detalle_scoring_movil
WHERE bdisolic:ss_detalle_scoring_movil.empresa = svt_empresa
AND bdisolic:ss_detalle_scoring_movil.folio_movil = pFolio;

	FOREACH
		--Arma Cursor Principal de si_solicitud_movil
		SELECT id, numcte, cte_coppel, numcte_coppel, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc,
			  sexo, ap_calle, colonia, deleg_mpo, edo, cod_postal, domicilio_actual, domicilio_alta, cve_elector, curp,
			  fecha_registro, estado, municipio, seccion, localidad, emision, vigencia, ocr, nivel_ingresos, edo_civil,
			  tpo_edo_civil, meses_edo_civil, tipo_residencia , tiempo_domicilio , actividad, subactividad, empresa, tel_trabajo,
			  tiempo_trabajo, tiempo_trab_ant, edad, pers_dependen, comp_ingresos, escolaridad, pers_domicilio,pers_trabajan, producto,
			  telefono_casa, telefono, carrier, email, num_tdc_coppel, status_tdc_coppel, num_prestamo, status_prestamo, num_tdc_bcoppel,
			  status_tdc_bcoppel, situacion_esp, causa, folio, geolocalizacion, firma_bc, fotografias, procesado_trans, folio_procesado,
			  status_solicitud,ejecutivo,fecha_insert, trim(ap_apell_paterno), trim(ap_apell_materno), trim(ap_nombre1), trim(ap_nombre2), ap_fecha_nac,pais_nac

		INTO sid, snumcte, scte_coppel, snumcte_coppel, sapell_paterno, sapell_materno, snombre1, snombre2, sfecha_nac, srfc,
			ssexo, scalle, scolonia, sdeleg_mpo, sedo, scod_postal, sdomicilio_actual, sdomicilio_alta, scve_elector, scurp,
			sfecha_registro, sestado, smunicipio, sseccion, slocalidad, semision, svigencia, socr, snivel_ingresos, sedo_civil,
			stpo_edo_civil, smeses_edo_civil, stipo_residencia, stiempo_domicilio, sactividad, ssubactividad, sempresa, stel_trabajo,
			stiempo_trabajo, stiempo_trab_ant, sedad, spers_dependen, scomp_ingresos, sescolaridad, spers_domicilio,spers_trabajan, sproducto,
			stelefono_casa, stelefono, scarrier, semail, snum_tdc_coppel, sstatus_tdc_coppel, snum_prestamo, sstatus_prestamo, snum_tdc_bcoppel,
			sstatus_tdc_bcoppel, ssituacion_esp, scausa, sfolio, sgeolocalizacion, sfirma_bc, sfotografias, sprocesado_trans, sfolio_procesado,
			sstatus_solicitud,sejecutivo,sfecha_insert, sAP_paterno, sAP_materno, sAP_nombre1, sAP_nombre2, sAP_fecha_nac,spais_nacimiento
		FROM si_solicitud_movil
		WHERE folio_procesado = "0"
		AND folio = pFolio      

		 --Valida formato de la fecha de nacimiento
		LET svt_dia = "";
		LET svt_mes = "";
		LET svt_year = "";
		LET svt_dia = sfecha_nac[1,2];
		LET svt_mes = sfecha_nac[4,5];
		LET svt_year = sfecha_nac[7,10];

		IF LENGTH(svt_year)<=2 THEN
			LET svt_year="19"||svt_year;
		END IF;
		LET sfecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

		IF TRIM(ssexo)="H" THEN
			LET ssexo="M";
		ELIF TRIM(ssexo)="M" THEN
			LET ssexo="F";
		END IF;

	 ---Valida la sucursal asignada al ejecutivo.

		FOREACH
			SELECT sucursal INTO svt_sucursal
			FROM si_usuario_movil

			WHERE ejecutivo = sejecutivo
			AND activo = "1"
			
			IF svt_sucursal != " " THEN
			   --EXIT FOREACH;
			END IF;
		END FOREACH;

		IF svt_sucursal IS NULL OR svt_sucursal = " " THEN
			LET sRetCod = "00015";
			
			IF snumcte IS NULL THEN
			   LET snumcte = " ";
			END IF;
			
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,"nohayejecutivo",snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00015";
			--Actualiza el status_valua por el folio
			  UPDATE si_solicitud_movil
			  SET(status_valua)=(2)
			  WHERE folio = pFolio;

			CONTINUE FOREACH;
		END IF;

        -----VALIDA EN LISTA NEGRA-------------------------------------------
        LET sFechaLN = SUBSTR(sAP_fecha_nac,4,2) ||'/'|| SUBSTR(sAP_fecha_nac,0,2) ||'/'|| SUBSTR(sAP_fecha_nac,7,4);	
        
        EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra(sAP_nombre1, sAP_nombre2, sAP_paterno, sAP_materno, sFechaLN) INTO cCodRetLN;

        IF(cCodRetLN = '000002') THEN
            LET sDesc = 'En lista negra';
			LET sCodRet = '00008';
            
            INSERT INTO si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
            VALUES(pFolio,snumcte,UPPER(sAP_paterno),UPPER(sAP_materno),UPPER(sAP_nombre1),UPPER(sAP_nombre2),sAP_fecha_nac,TODAY);

            CONTINUE FOREACH;	
        END IF;        
        ----------------------------------------------------------
                     
		--OBTENIENDO LOS DATOS DEL RFC MODIFICADO Y COMPARANDO CON EL RFC ACTUAL
		LET sAP_dia = "";
		LET sAP_mes = "";
		LET sAP_year = "";
		LET sAP_dia = sAP_fecha_nac[1,2];
		LET sAP_mes = sAP_fecha_nac[4,5];
		LET sAP_year = sAP_fecha_nac[7,10];

		IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		END IF;
		LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		RETURNING sRetCod, sAP_rfc;

		IF sRetCod<>'00000' THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00020";
			UPDATE si_solicitud_movil SET status_valua=2 WHERE folio = pFolio;
			CONTINUE FOREACH;
		END IF;
		UPDATE si_solicitud_movil SET ap_rfc=trim(sAP_rfc) WHERE folio=pFolio; 
                         --COMPARANDO RFC ORIGINAL CONTRA RFC NUEVO, SI LOS RFC'S SON DISTINTOS...
		IF srfc<>sAP_rfc THEN
			--SE BUSCA QUE NO EXISTA EL RFC MODIFICADO EN LA TABLA DE CLIENTES
			IF EXISTS(select numcte FROM si_cliente where rfc=sAP_rfc) THEN
				--EN CASO DE EXISTIR, SE TOMA EL CLIENTE MODIFICADO Y SE ACTUALIZA LA TABLA DE SOLICITUD MOVIL CON ESE DATO
				LET snumcte=(select numcte FROM si_cliente where rfc=sAP_rfc);
				UPDATE si_solicitud_movil SET ap_rfc=trim(sAP_rfc) WHERE folio=pFolio; 

				IF LENGTH(TRIM(scve_elector))=18 THEN
					IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
						LET scve_elector='';
					ELSE
						LET scve_elector=substr(scve_elector,13,2);									
						UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte	and lugar_nac='' and validacurp is null;
					END IF;
				END IF;
			ELSE 
				--EN CASO DE QUE NO EXISTA EL RFC MODIFICADO, SE ACTUALIZAN LAS VARIABLES DE NOMBRES Y FECHA DE NACIMIENTO 
				--CON LOS DATOS DE LOS CAMPOS MODIFICADOS
				LET sapell_paterno= sAP_paterno;
				LET sapell_materno= sAP_materno;
				LET snombre1= sAP_nombre1;
				LET snombre2= sAP_nombre2;
				LET srfc= sAP_rfc;
				LET sfecha_nac= sAP_fecnac;
			END IF;
		END IF;

        IF snumcte IS NULL OR TRIM(snumcte) = "" THEN

			IF LENGTH(spers_domicilio)<=2 THEN
			   LET spers_domicilio="0"||spers_domicilio;
			END IF;
			
            ---Ejecuta la Rutina de ALTA de Clientes
			IF LENGTH(TRIM(scve_elector))=18 THEN
				IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
					LET scve_elector='';
				ELSE
					LET scve_elector=substr(scve_elector,13,2);									
					UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte and lugar_nac='' and validacurp is null;
				END IF;
			END IF;
			
			CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sapell_paterno,sapell_materno,snombre1,snombre2,srfc,
						  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
						  sfecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
						 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
			RETURNING sRetCod,svt_numcte;
			
            --Valida el Codigode Retorno de esta Ejecucion
			IF (sRetCod != "000") AND (sRetCod != "104") AND (sRetCod != "106") AND (sRetCod != "118")  THEN
				LET snumcte = svt_numcte;
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"ctefisico",snumcte,sRetCod,svt_fecha_hoy);
				LET sCodRet = "00001";
				--Actualiza el status_valua por el folio
				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio; 

				CONTINUE FOREACH;
			ELSE
				LET snumcte = svt_numcte;
				IF (sRetCod = "104") OR (sRetCod = "106") OR (sRetCod = "118") THEN
					LET snumcte = (select numcte from si_cliente where rfc=srfc);
					LET svt_numcte=snumcte;

						IF LENGTH(TRIM(scve_elector))=18 THEN
							IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
								LET scve_elector='';
							ELSE
								LET scve_elector=substr(scve_elector,13,2);									
								UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte	and lugar_nac='' and validacurp is null;	
							END IF;
						END IF;

				END IF;
				---Actualiza el Numero de Cliente
				UPDATE si_solicitud_movil
				SET(numcte)=(svt_numcte)
				WHERE folio_procesado = "0"
				AND folio = pFolio;
			END IF;
        ELSE
			IF LENGTH(TRIM(scve_elector))=18 THEN
				IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
					LET scve_elector='';
				ELSE
					LET scve_elector=substr(scve_elector,13,2);									
					UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte and lugar_nac='' and validacurp is null;
				END IF;
			END IF;

			CALL ctefisico(svt_empresa,"C",snumcte,svt_sucursal,sejecutivo,"01","2",sapell_paterno,sapell_materno,snombre1,snombre2,srfc,
			"32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
			sfecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
			sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
			RETURNING sRetCod,svt_numcte;
			
			IF (sRetCod = "000") OR (sRetCod = "104") OR (sRetCod = "106") OR (sRetCod = "118")  THEN
				UPDATE si_solicitud_movil
				SET(numcte)=(svt_numcte)
				WHERE folio_procesado = "0"
				AND folio = pFolio;
			END IF;
					   
			LET sRetCod = "000";
			---Valida el Coreo para no Ejecutarlo en blanco

			IF semail IS NOT NULL AND semail != "" THEN
			---Ejecuta la Rutina de ALTA de Correos Electronicos
				CALL sp_registra_correos(svt_empresa,snumcte,semail,1,1,sejecutivo)
				RETURNING sRetCod;
					IF (sRetCod != "000" AND sRetCod != "999") THEN
						INSERT INTO si_valida_folio_detalle
						VALUES(pFolio,"sp_registra_correo",snumcte,sRetCod,svt_fecha_hoy);
						LET sCodRet = "00002";
					END IF;
			END IF;
		END IF;

		DELETE FROM bdisolic:ss_solicitudes_movil
		WHERE  bdisolic:ss_solicitudes_movil.empresa = svt_empresa
		AND  bdisolic:ss_solicitudes_movil.folio_movil = pFolio;

		--Validando Codigo Postal
		CALL sp_valida_numero(scod_postal)
		RETURNING sRetCod, sSPosc1, sSPosc2, sSPosc3, sSPosc4, sSPosc5;

		IF sRetCod<>"00000" THEN
			SELECT d_codigo INTO scod_postal FROM si_sucursales WHERE sucursal='0010';
		END IF;

		--Se ejecuta la Actualizacion de la Direccion Actual.
		CALL sp_act_dirmovil(scod_postal,snumcte)
		RETURNING sRetCod,ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,ssvt_sCP,ssvt_sNumCiudad,ssvt_sColonia,ssvt_sMpo;

		IF sRetCod != "00000" THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,"sp_act_dirmovil",snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00016";
			--Actualiza el status_valua por el folio

			UPDATE si_solicitud_movil
			SET(status_valua)=(2)
			WHERE folio = pFolio;

			CONTINUE FOREACH;
		END IF;

		---Ejecuta la Rutina de ALTA de Direcciones
		SELECT tipo_cliente  INTO sTpoCte FROM bdinteg:si_cliente WHERE numcte=snumcte;
		IF sTpoCte ="2" THEN	 
			CALL direcciones(svt_empresa,"A",snumcte,0,"1",scalle," ",ssvt_sMpo," ",ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,scod_postal,"1",
			stelefono_casa,"2",stelefono,"3",stel_trabajo," "," "," "," ",ssvt_sNumCiudad," "," "," ",
			0,ssvt_sColonia," ","N",0,0,0,0,0,0,0," ",sejecutivo,svt_fecha_hoy,svt_sucursal)
			RETURNING sRetCod;

			IF sRetCod != "000" THEN
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"direcciones",snumcte,sRetCod,svt_fecha_hoy);
				LET sCodRet = "00003";
				--Actualiza el status_valua por el folio
				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio;

				CONTINUE FOREACH;
			END IF;
		ELSE
			-- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
			SELECT telefono
			INTO o_telefono1
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 1;

			IF o_telefono1 is null THEN
				LET o_telefono1 = ' ';
			END IF;

			IF o_telefono1 <> stelefono_casa THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stelefono_casa is not null AND stelefono_casa <> '' ) AND ( stelefono_casa is not null AND stelefono_casa <> '' ) ) THEN
					LET vTipoTel = 1;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stelefono_casa, vTipoTel, '', 0, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;

			SELECT telefono
			INTO o_telefono2
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 2;

			IF o_telefono2 is null THEN
				LET o_telefono2 = ' ';
			END IF;

			IF o_telefono2 <> stelefono THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stelefono is not null AND stelefono <> '' ) AND ( stelefono is not null AND stelefono <> '' ) ) THEN
					LET vTipoTel = 2;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stelefono, vTipoTel, '', scarrier, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;

			SELECT telefono, extension
			INTO o_telefono3, o_extension
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 3;

			IF o_telefono3 is null THEN
				LET o_telefono3 = ' ';
			END IF;

			IF o_telefono3 <> stel_trabajo THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stel_trabajo is not null AND stel_trabajo <> '' ) AND ( stel_trabajo is not null AND stel_trabajo <> '' ) ) THEN
					LET vTipoTel = 3;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stel_trabajo, vTipoTel, o_extension, 0, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;
		END IF;
					 
		--valida la ejecucion de los Ingresos por la nueva Solicitud
		LET sRetCod = "000";
		CALL sp_ingresos("A",svt_empresa,snumcte,0,"T",sempresa,"0",0,"","",snivel_ingresos,sejecutivo,svt_fecha_hoy,"0",0,sactividad,ssubactividad,0,0,0,0)
		RETURNING sRetCod;

		IF sRetCod != "000" THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,"Ingresos",snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00012";
			--EXIT FOREACH;
			--Actualiza el status_valua por el folio
			UPDATE si_solicitud_movil
			SET(status_valua)=(2)
			WHERE folio = pFolio;

			CONTINUE FOREACH;
		END IF;

		LET sRetCod = "000";
		CALL sp_datos_comple_detalle(sfolio)
		RETURNING sRetCod, snumcte, sfolio, svt_elemento, svt_descrip;

		IF sRetCod != "00000" THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,"sp_datos_comple_detalle",snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00004";
			--Actualiza el status_valua por el folio
			UPDATE si_solicitud_movil
			SET(status_valua)=(2)
			WHERE folio = pFolio;

			CONTINUE FOREACH;
		ELSE
			---Genera_detalle_Scoring_movil
			FOREACH
				SELECT {+INDEX (bdinteg:si_datos_comple_deta idx_fol_movil)} seccion, grupo, folio, elemento, cod_ret, clave
				INTO ssvt_seccion, svt_grupo, svt_folio, ssvt_elemento, svt_cod_ret, svt_clave
				FROM si_datos_comple_deta
				WHERE folio = pFolio
				
				--Valida la ejecucion del Scoring.
				IF svt_cod_ret = "000" THEN
					CALL bdisolic:recibe_detalle_scoring_movil(svt_empresa, svt_folio, ssvt_seccion, svt_grupo, ssvt_elemento)
					RETURNING ssCodRet, ssMensaje;
				ELSE
					LET sCodRet = "00005";
					
				--Actualiza el status_valua por el folio
					UPDATE si_solicitud_movil
					SET(status_valua)=(2)
					WHERE folio = pFolio;

					CONTINUE FOREACH;
				END IF;
			END FOREACH;

			IF ssCodRet != "000000" THEN
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"bdisolic:recibe_detalle_scoring_movil",snumcte,ssCodRet,svt_fecha_hoy);
				LET sCodRet = "00006";
				--Actualiza el status_valua por el folio

				  UPDATE si_solicitud_movil
				  SET(status_valua)=(2)
				  WHERE folio = pFolio;

				  CONTINUE FOREACH; 
			END IF;
		END IF;

		--valida el Producto
		SELECT producto[1],producto[2],producto[3] INTO svt_campo1,svt_campo2,svt_campo3
		FROM si_solicitud_movil
		WHERE producto = sproducto
		AND folio_procesado = "0"
		AND folio = pFolio
		AND producto != " ";

		LET svt_solic1         = "";
		LET svt_solic2         = "";
		LET svt_solic3         = "";

		IF svt_campo2 = "1" THEN
			LET svt_producto  = "6001";
			---Genera_detalle_registra_folio_movil
			IF svt_sucursal="5007" THEN
			   LET svt_sucursal="0131";
			END IF;
			CALL bdisolic:sp_registra_folio_movil(svt_empresa,pFolio,svt_sucursal,snumcte,svt_producto,snumcte_coppel,snivel_ingresos,5,4,0,sejecutivo)
			RETURNING ssCodRet;

			IF ssCodRet = "000002" THEN
			   LET ssCodRet = "000000";
			END IF;
			IF ssCodRet != "000000" THEN
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"00010",snumcte,ssCodRet,svt_fecha_hoy);
				LET sCodRet = "00010";
				--EXIT FOREACH;
				--Actualiza el status_valua por el folio

				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio;
				CONTINUE FOREACH;
			ELSE
				---Valida y actualiza el numero de solicitud.
				SELECT num_solicitud INTO svt_solic2
				FROM bdisolic:ss_solicitudes_movil
				WHERE bdisolic:ss_solicitudes_movil.folio_movil = pFolio
				AND bdisolic:ss_solicitudes_movil.producto = svt_producto;

				IF svt_solic2 IS NOT NULL THEN
					--Actualiza la tabla de solicitud_movil
					UPDATE si_solicitud_movil
					SET(num_tdc_bcoppel)=(svt_solic2)
					WHERE folio_procesado = "0"
					AND folio = pFolio;
				END IF;
			END IF;
		END IF;

		IF svt_campo3 = "1" THEN
			LET svt_producto  = "6300";
			---Genera_detalle_registra_folio_movil
			IF svt_sucursal="5007" THEN
			   LET svt_sucursal="0131";
			END IF;
			CALL bdisolic:sp_registra_folio_movil(svt_empresa,pFolio,svt_sucursal,snumcte,svt_producto,snumcte_coppel,snivel_ingresos,5,4,0,sejecutivo)
			RETURNING ssCodRet;

			IF ssCodRet = "000002" THEN
			   LET ssCodRet = "000000";
			END IF;
			IF ssCodRet != "000000" THEN
			   INSERT INTO si_valida_folio_detalle
			   VALUES(pFolio,"00011",snumcte,ssCodRet,svt_fecha_hoy);
			   LET sCodRet = "00011";
			   --Actualiza el status_valua por el folio

			   UPDATE si_solicitud_movil
			   SET(status_valua)=(2)
			   WHERE folio = pFolio;
			   CONTINUE FOREACH;
			ELSE
				---Valida y actualiza el numero de solicitud.
				SELECT num_solicitud INTO svt_solic3
				FROM bdisolic:ss_solicitudes_movil
				WHERE bdisolic:ss_solicitudes_movil.folio_movil = pFolio
				AND bdisolic:ss_solicitudes_movil.producto = svt_producto;

				IF svt_solic3 IS NOT NULL THEN
					--Actualiza la tabla de solicitud_movil
					UPDATE si_solicitud_movil
					SET(num_prestamo)=(svt_solic3)
					WHERE folio_procesado = "0"
					AND folio = pFolio;
				END IF;
			END IF;
		END IF;

		IF svt_campo1 = "1" THEN
			LET svt_producto  = "6500";
			---Genera_detalle_registra_folio_movil
			IF svt_sucursal="5007" THEN
			LET svt_sucursal="0131";
			END IF;
			CALL bdisolic:sp_registra_folio_movil(svt_empresa,pFolio,svt_sucursal,snumcte,svt_producto,snumcte_coppel,snivel_ingresos,5,4,0,sejecutivo)
			RETURNING ssCodRet;

			IF ssCodRet = "000002" THEN
			   LET ssCodRet = "000000";
			END IF;
			IF ssCodRet != "000000" THEN
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"bdisolic:sp_registra_folio_movil",snumcte,ssCodRet,svt_fecha_hoy);
				LET sCodRet = "00007";
				--Actualiza el status_valua por el folio

				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio;

				CONTINUE FOREACH;
			ELSE
				---Valida y actualiza el numero de solicitud.
				SELECT num_solicitud INTO svt_solic1
				FROM bdisolic:ss_solicitudes_movil
				WHERE bdisolic:ss_solicitudes_movil.folio_movil = pFolio
				AND bdisolic:ss_solicitudes_movil.producto = svt_producto;

				IF svt_solic1 IS NOT NULL THEN
					--Actualiza la tabla de solicitud_movil
					UPDATE si_solicitud_movil
					SET(num_tdc_coppel)=(svt_solic1)
					WHERE folio_procesado = "0"
					AND folio = pFolio;
				END IF;
			END IF;
		END IF;

	--Valida mensaje de privacidad
		IF snumcte IS NULL OR TRIM(snumcte) = "" AND sfirma_bc = "1" THEN
		ELSE
			LET ssCodRet = "000";
			CALL sp_valida_aviso_privacidad(svt_empresa, snumcte)
			RETURNING ssCodRet;

			IF ssCodRet = "000" OR ssCodRet = "001" THEN
				--Ejecuta y valida la propuesta de privacidad
				LET ssCodRet = "000";
				CALL sp_insert_autor_privacidad(svt_empresa, snumcte, svt_sucursal, "1" , svt_mensaje)
				RETURNING ssCodRet;

				IF ssCodRet != "00000" THEN
					INSERT INTO si_valida_folio_detalle
					VALUES(pFolio,"sp_insert_autor_privacidad",snumcte,ssCodRet,svt_fecha_hoy);
					LET sCodRet = "00008";
					--EXIT FOREACH;
					--Actualiza el status_valua por el folio

					UPDATE si_solicitud_movil
					SET(status_valua)=(2)
					WHERE folio = pFolio;

					CONTINUE FOREACH;
				END IF;
				LET sCodRet = "00000";
			ELSE
				LET sCodRet = sRetCod;
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"sp_valida_aviso_privacidad",snumcte,ssCodRet,svt_fecha_hoy);
				LET sCodRet = "00009";
				--Actualiza el status_valua por el folio
				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio;

				CONTINUE FOREACH;
			END IF;
		END IF;

		LET vt_fech_hora = "";
		SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
		FROM sysmaster:"informix".sysshmvals;

		UPDATE si_solicitud_movil
		SET(fecha_profin)=(vt_fech_hora)
		WHERE folio = pFolio; 
	END FOREACH;
RETURN sCodRet, NVL(snumcte,'');
END
END PROCEDURE
DOCUMENT
"Spl para el alta de Clientes desde la forma de captura movil ",
"base de datos: bdinteg",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 03/Marzo/2015",
"Ver.  : 1.1",
"Mod   : Se incluye el spl de ingesos",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 10/Marzo/2015",
"Ver.  : 1.2",
"Mod   : Se Cambia relacion de transaccion (6001,6300 y 6500) (6500,6001 y 6300)",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 25/Marzo/2015",
"Ver.  : 1.3",
"Mod   : Se Cambia relacion de campos  num_tdc_coppel,num_tdc_bcoppel,num_prestamo",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 26/Marzo/2015",
"Ver.  : 1.4",
"Mod   : Se Cambia relacion para extraer la sucursal por el ejecutivo ",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 07/Abril/2015",
"Ver.  : 1.5",
"Mod   : Se Cambia relacion de transaccion (6500,6001 y 6300) (6001,6300 y 6500)",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 10/Abril/2015",
"Ver.  : 1.6",
"Mod   : Se Anexan detalle de tiempos en el proceso)",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 29/Abril/2015",
"Ver.  : 1.7",
"Mod   : Se Anexan validaciones para la personas en el domicilio)",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 06/Mayo/2015",
"Ver.  : 1.8";

CREATE PROCEDURE "informix".sp_importarcofetel_mib()
	
	--DATOS A REGRESAR
	RETURNING CHAR(5);

	--DEFINICIÓN DE VARIABLES
	DEFINE cCodret 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cSql 	CHAR(200);
	DEFINE cRuta 	VARCHAR(200);
	DEFINE vExiste	INTEGER;

	--INICIALIZA VARIABLES
	LET cCodret ='000';
	LET iSqlErr = 0;
	LET cSql 	= '';
	LET cRuta 	= '';
	LET vExiste = 0;

	SET DEBUG FILE TO "/tmp/sp_importarcofetel.out";
	TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;

		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		SELECT TRIM(valor)
		INTO cRuta
		FROM bdinteg:"informix".si_param
		WHERE cod_param = "58";

		if (cRuta IS NULL) OR (cRuta = '') THEN

			LET cCodret = '001';

		END IF;

		--- VERIFICA SI EXISTE LA TABLA TEMPORAL PARA BORRARLA
		SELECT count(*) 
		into vExiste 
		FROM "informix".tmp_si_cattelefono_mib;

		IF (vExiste > 0) THEN

			LET cSql = '';
			LET cSql = 'echo "unload to  '|| cRuta || 'resp_telefonos.unl' || ' SELECT * FROM tmp_si_cattelefono_mib" > ' || cRuta || 'instruccion1.sql';
			SYSTEM cSql;
			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'resp_telefonos.unl';
			SYSTEM cSql;

			truncate table "informix".tmp_si_cattelefono_mib;

		END IF;

		LET cSql = '';
		LET cSql = 'echo "LOAD FROM '|| cRuta || 'telefonos.sql' || ' DELIMITER ' || '''|''' || ' INSERT INTO tmp_si_cattelefono_mib" > ' || cRuta || 'instruccion.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql = "chmod 777 " || cRuta || 'instruccion.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion.sql';
		SYSTEM cSql;

		RETURN cCodret;

	END
END PROCEDURE

DOCUMENT
'REALIZO:	Carmén Orozco',
'FECHA:		27-12-2008',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Mohamed Carreón',
'FECHA:		17-02-2009',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  temporal tmp_si_cattelefonos y no a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Frank Gaxiola',
'FECHA:		17-11-2009',
'FUNCION:	Se modifica para que la ruta del servidor sea tomada de un parametro',
'BDD:		bdinteg',

'MODIFICO:	Daniela Ramírez',
'FECHA:		31-01-2012',
'FUNCION:	Se aplican reglas de informix',
'BDD:		bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_consulta_saldos_general2(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
				returning CHAR(5)       AS Codigo_Retorno,
						  DATE          AS fecha_origen,
						  DATE          AS fecha_prox_pago,
						  DECIMAL(18,2) AS pago_minimo,
						  DATE          AS fecha_ult_pago,
						  INTEGER       AS plazo,
						  INTEGER       AS pagos_realizados,
						  DECIMAL(18,2) AS linea_otorgada,
						  DECIMAL(9,6)  AS tasa_interes,
						  DECIMAL(9,6)  AS tasa_moratorios,
						  DECIMAL(14,2) AS monto_sbc,
						  DECIMAL(18,2) AS cap_vig,
						  DECIMAL(18,2) AS cap_trans,
						  DECIMAL(18,2) AS cap_vdo_exig,
						  DECIMAL(18,2) AS cap_vdo_no_exig,
						  DECIMAL(18,2) AS sdo_act_total_cap,
						  DECIMAL(18,2) AS int_vig,
						  DECIMAL(18,2) AS int_vdo,
						  DECIMAL(18,2) AS int_moratorios,
						  DECIMAL(18,2) AS int_mes,
						  DECIMAL(18,2) AS sdo_act_total_int,
						  DECIMAL(18,2) AS iva_int_vig,
						  DECIMAL(18,2) AS iva_int_vdo,
						  DECIMAL(18,2) AS iva_int_moratorios,
						  DECIMAL(18,2) AS iva_int_mes,
						  DECIMAL(18,2) AS sdo_act_total_iva,
						  DECIMAL(18,2) AS com_pend,
						  DECIMAL(18,2) AS iva_com,
						  DECIMAL(18,2) AS sdo_retenido,
						  DECIMAL(18,2) AS total_liquidacion,
						  DECIMAL(18,2) AS int_devengado,
						  DECIMAL(18,2) AS iva_int_devengado,
						  DECIMAL(18,2) AS linea_disponible,
						  DECIMAL(18,2) AS pagos_vdos,
						  DECIMAL(18,2) AS pago_inmediato,
                          DATE          AS Fecha_Cartera_Vendida;
						  
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE 	codigo_retorno   	  CHAR(6);
DEFINE 	mensaje_retorno  	  CHAR(80);
DEFINE 	numero_credito   	  CHAR(20);
DEFINE 	codigo_tipcred   	  CHAR(2);         
DEFINE 	fecha_origen     	  DATE;
DEFINE 	fecha_prox_pago  	  DATE;
DEFINE 	pago_minimo      	  DECIMAL(18,2);
DEFINE 	fecha_ult_pago   	  DATE;
DEFINE 	plazo            	  INTEGER;
DEFINE 	pagos_realizados 	  INTEGER;
DEFINE 	linea_otorgada   	  DECIMAL(18,2);
DEFINE 	tasa_interes     	  DECIMAL(9,6);
DEFINE 	tasa_moratorios       DECIMAL(9,6);
DEFINE 	monto_sbc        	  DECIMAL(14,2);
DEFINE 	cap_vig          	  DECIMAL(18,2);
DEFINE 	cap_trans        	  DECIMAL(18,2);
DEFINE 	cap_vdo_exig	 	  DECIMAL(18,2);
DEFINE 	cap_vdo_no_exig  	  DECIMAL(18,2);
DEFINE 	sdo_act_total_cap 	  DECIMAL(18,2);
DEFINE 	int_vig          	  DECIMAL(18,2);
DEFINE 	int_vdo               DECIMAL(18,2);
DEFINE 	int_moratorios   	  DECIMAL(18,2);
DEFINE 	int_mes          	  DECIMAL(18,2);
DEFINE 	sdo_act_total_int 	  DECIMAL(18,2);
DEFINE 	iva_int_vig      	  DECIMAL(18,2);
DEFINE 	iva_int_vdo      	  DECIMAL(18,2);
DEFINE 	iva_int_moratorios 	  DECIMAL(18,2);
DEFINE 	iva_int_mes      	  DECIMAL(18,2);
DEFINE 	sdo_act_total_iva 	  DECIMAL(18,2);
DEFINE 	com_pend              DECIMAL(18,2);
DEFINE 	iva_com          	  DECIMAL(18,2);
DEFINE 	sdo_retenido     	  DECIMAL(18,2);
DEFINE 	total_liquidacion 	  DECIMAL(18,2);
DEFINE 	int_devengado    	  DECIMAL(18,2);
DEFINE 	iva_int_devengado 	  DECIMAL(18,2);
DEFINE 	linea_disponible  	  DECIMAL(18,2);
DEFINE 	pagos_vdos       	  DECIMAL(18,2);
DEFINE 	desc_status_cred	  CHAR(60);
DEFINE 	id_bloqueo_cred  	  INTEGER;
DEFINE 	bloqueo_cta           CHAR(60);
DEFINE 	id_causa_bloqueo_cred CHAR(3);
DEFINE 	causa_bloqueo_cta     CHAR(50);
DEFINE 	id_sit_esp_cte    	  CHAR(1);
DEFINE 	id_causa_esp_cte      INTEGER;
DEFINE 	sit_esp_cte           CHAR(75);
DEFINE 	id_sit_esp_cred       CHAR(1);
DEFINE 	id_causa_esp_cred     INTEGER;
DEFINE 	sit_esp_cred          CHAR(75);
DEFINE  dFechCartVendida      DATE;


--VARIABLES EXTRAS
DEFINE decPagoInmediato      DECIMAL(18,2);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	

--INICIALIZA VARIABLES STORE
LET codigo_retorno   	  = "";
LET mensaje_retorno  	  = "";
LET numero_credito   	  = "";
LET codigo_tipcred   	  = "";
LET fecha_origen     	  = "";
LET fecha_prox_pago  	  = "";
LET pago_minimo      	  = 0;
LET fecha_ult_pago   	  = "";
LET plazo            	  = 0;
LET pagos_realizados 	  = 0;
LET linea_otorgada   	  = 0;
LET tasa_interes     	  = 0;
LET tasa_moratorios       = 0;
LET monto_sbc        	  = 0;
LET cap_vig          	  = 0;
LET cap_trans        	  = 0;
LET cap_vdo_exig	 	  = 0;
LET cap_vdo_no_exig  	  = 0;
LET sdo_act_total_cap 	  = 0;
LET int_vig          	  = 0;
LET int_vdo               = 0;
LET int_moratorios   	  = 0;
LET int_mes          	  = 0;
LET sdo_act_total_int 	  = 0;
LET iva_int_vig      	  = 0;
LET iva_int_vdo      	  = 0;
LET iva_int_moratorios 	  = 0;
LET iva_int_mes      	  = 0;
LET sdo_act_total_iva 	  = 0;
LET com_pend              = 0;
LET iva_com          	  = 0;
LET sdo_retenido     	  = 0;
LET total_liquidacion 	  = 0;
LET int_devengado    	  = 0;
LET iva_int_devengado 	  = 0;
LET linea_disponible  	  = 0;
LET pagos_vdos       	  = 0;
LET desc_status_cred	  = "";
LET id_bloqueo_cred  	  = 0;
LET bloqueo_cta           = "";
LET id_causa_bloqueo_cred = "";
LET causa_bloqueo_cta     = "";
LET id_sit_esp_cte    	  = "";
LET id_causa_esp_cte      = 0;
LET sit_esp_cte           = "";
LET id_sit_esp_cred       = "";
LET id_causa_esp_cred     = 0;
LET sit_esp_cred          = "";

LET decPagoInmediato     = 0;
LET dFechCartVendida     ="";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_saldos_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN  
				cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
				tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
				sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
				iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
	END IF;
	-- TERMINA VALIDACION	
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN 
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
		END IF;
		set isolation to dirty read;
		
		EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general('001',cNUMCUENTA)

		INTO
		codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
		tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
		sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
		iva_int_devengado, linea_disponible, pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, 
		id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, id_causa_esp_cred, sit_esp_cred;          
		
		IF pago_minimo < 0 then
            Let pago_minimo = 0;
        END IF;
		--LET decPagoInmediato = cap_trans + cap_vdo_exig + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;
		LET decPagoInmediato = pago_minimo + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;

		LET cCodRet = SUBSTR(codigo_retorno,2,6);
        IF cCodRet='00001' THEN
            LET cCodRet ='00047';
        ELIF cCodRet='00002' THEN    
            LET cCodRet ='00017';
        END IF;

        FOREACH
            SELECT LIMIT 1 fecha INTO dFechCartVendida FROM bdicred:sd_maecred_vendida WHERE num_credito  = cNUMCUENTA
            UNION
            SELECT fecha FROM bdicred:sd_maecredcrd_vendida WHERE num_credito  = cNUMCUENTA
        END FOREACH;



		RETURN 
		    cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÃA",
"FUNCIONAMIENTO:Obtener la informaciÃ³n de la Cuenta de CrÃ©dito de una Cliente respecto a:  Capital, InterÃ©s, IVA, Devengado, Saldos, Otros y Pago Inmediato. ",
"El SP extraerÃ¡ la informaciÃ³n de la Base de Datos central de Informix, enviando como parÃ¡metro el  No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultamotivocancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2), pCliente CHAR(20), pCuenta CHAR(20))
	RETURNING 
		CHAR(5) AS codret,
		CHAR(40) AS motivo_cancelacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cMotivoCancelacion CHAR(40);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cMotivoCancelacion = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN				
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMotivoCancelacion;			
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/mfinis/sp_consultamotivocancelacion.out";
	    --TRACE ON;
		
		IF pCliente = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		
		
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(pUsuario,pIdFuncion, pCliente, pSistemaCuenta,'2')INTO cCodRet;
		
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta = '01' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT descripcion
				INTO cMotivoCancelacion 
			FROM bdicheq:"informix".sc_maechq ma
			LEFT JOIN bdicheq:"informix".sc_motivocancel mb 
				ON ma.empresa = mb.empresa
				AND ma.motivo = mb.clave
			WHERE ma.empresa = '001' 
				AND ma.num_cte = pCliente
				AND ma.cuenta = pCuenta;		
			
		END IF;
		
		RETURN cCodRet, cMotivoCancelacion;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 21/04/2017',
'MODULO: Consultas ',
'FUNCIONALIDAD: Cintilla Cuentas CaptaciÃ³n',
'DESCRIPCION: Spl quee realiza la consulta del motivo de cancelaciÃ³n',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacta_club_pba1(pEmpresa CHAR(3), pCliente CHAR(20), pPoliza CHAR(20),pCteCoppel CHAR(20))
RETURNING CHAR(6) as CodRet, CHAR(1) AS Domiciliada, CHAR(20) AS NumCta, CHAR(20) AS NumTarjeta, CHAR(4) AS SucOperante, CHAR(8) AS NumPromotor, CHAR(16) AS FolioOperacion, CHAR(1) AS Respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cDomiciliada CHAR(1);
DEFINE cNumCta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cSucOperante CHAR(4);
DEFINE cNumPromotor CHAR(8);
DEFINE cFolioOperacion CHAR(16);
DEFINE cTipoPago CHAR(1);
DEFINE dFecha DATETIME YEAR TO SECOND;
DEFINE cRespuesta CHAR(1);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;
LET cDomiciliada = '';
LET cNumCta='';
LET cNumTarjeta='';
LET cSucOperante='';
LET cNumPromotor='';
LET cFolioOperacion='';
LET cRespuesta='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacta_club.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pPoliza,''))='' THEN
			LET cCodret	= "000001";
		ELSE
			SELECT  MAX(fecha)
			INTO dFecha
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa;
			
			SELECT respuesta
			INTO cRespuesta
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa
			AND fecha=dFecha;
		
			SELECT suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,foliooperacion
			INTO cSucOperante,cNumPromotor,cTipoPago,cNumTarjeta,cNumCta,cFolioOperacion
			FROM  "informix".si_club_proteccion
			WHERE empresa= pEmpresa AND numcte=pCliente;
			--AND num_poliza= pPoliza;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
			ELSE
				IF TRIM(NVL(cTipoPago,''))='1' THEN
					LET cDomiciliada = 'S';
				ELSE 
					LET cDomiciliada = 'N';
					LET cNumCta='';
					LET cNumTarjeta='';
				END IF
			END IF
		END IF
		
RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
END
END PROCEDURE

DOCUMENT
"Descripción: Retorna la cuenta domiciliada para el Club de protección.",
"Autor : Leslie Rendón",
"FECHA : 07/07/2014",
"BD    : bdinteg",

'Descripción: Se comenta filtro num_poliza = pPoliza para que no se realice la comparacion en la tabla si_club_proteccion',
'Autor : Bryan Limon',
'FECHA : 16/05/2017',
'BD    : bdinteg'
;

CREATE PROCEDURE "informix".sp_actualiza_rep_ctas_tel_mail()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE cCodRet        	  CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE cNumcte            CHAR(20);
DEFINE cCorreo            CHAR(100);
DEFINE cTelefono          CHAR(10);
DEFINE sCommit            SMALLINT;
DEFINE iContador          INTEGER;
DEFINE cCuenta		      CHAR(20);

----------------INICIALIZA VARIABLES------------------
LET cCodRet             ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET cNumcte             ='';
LET cCorreo             ='';
LET cTelefono           ='';
LET sCommit             = 0;
LET iContador           = 0;
LET cCuenta             ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
    SELECT {+INDEX ("informix".si_rep_ctas_tel_mail idx_rep_ctas_tel_mail)} cuenta
	INTO cCuenta
	FROM si_rep_ctas_tel_mail
		
        SELECT LIMIT 1 num_cte INTO cNumcte FROM bdicheq:sc_maechq WHERE cuenta = cCuenta;        
        SELECT LIMIT 1 correo_elec INTO cCorreo FROM si_correos WHERE status_correo = 'A' AND numcte = cNumcte AND secuencia = (select max(secuencia) from si_correos where  numcte = cNumcte); 
        SELECT LIMIT 1 telefono INTO cTelefono FROM si_telefonos_actual WHERE status_tel='A' AND tipo_tel=2 AND numcte = cNumcte;               

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET iContador = 0;
            LET sCommit = -1;
        END IF;			        

        UPDATE si_rep_ctas_tel_mail SET numcte = NVL(cNumcte,''), correo = NVL(cCorreo,''), celular = NVL(cTelefono,'')
        WHERE cuenta = cCuenta;

        --Ejecutar un commit cada 1000 registros.
        IF (iContador >= 5000) THEN
            COMMIT WORK;	
            LET iContador = 0;            
            BEGIN WORK;
        END IF;	

    END FOREACH;
	
	IF sCommit = -1 THEN
        COMMIT WORK;        
        END IF;
	LET sCommit = 0;

	LET cDesc = 'Proceso Correcto';
    RETURN cCodRet, cDesc;

END;
END PROCEDURE;