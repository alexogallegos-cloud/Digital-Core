CREATE PROCEDURE "informix".sp_gen_rep_cel_repetidos()
    RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE dFechaHoy DATE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE pRutaDescarga CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET dFechaHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET pRutaDescarga = '/RESPALDOSNEW';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
					
		IF pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		   
		LET dFechaHoy = CURRENT;
		
		LET cNombreArchivo = 'rep_cel_repetidos_'||YEAR(dFechaHoy - 1 UNITS month)||LPAD(MONTH(dFechaHoy- 1 UNITS month),2,0)||'.xls';
		
		
		LET cCmd1 = "SELECT 'Numero','Fecha de alta','Sucursal','No. promotor','No. cliente Banco','Telefono celular' "
					|| " FROM systables WHERE tabid = 1 UNION ALL SELECT {AVOID_FULL (bdinteg:si_telefonos) ,AVOID_FULL (bdinteg:si_ejecut)} * FROM( "
					|| " SELECT {AVOID_FULL (bdinteg:si_telefonos idx_si_telefonos_telefono, idx_fecha_tel)} TO_CHAR(ROW_NUMBER() OVER(ORDER BY tel_actual.telefono, tel_actual.fecha_hora)) AS numero, TO_CHAR(tel_actual.fecha_hora, '%d/%m/%Y') as fecha_alta, si_e.sucursal as sucursal, tel_actual.user_insert as promotor, tel_actual.numcte as no_cliente_banco, tel_actual.telefono as tel_celular"
					|| " FROM (SELECT {AVOID_FULL (bdinteg:si_telefonos idx_si_telefonos_telefono, idx_fecha_tel)} telefono FROM si_telefonos a where month(a.fecha_hora) = "|| month(dFechaHoy - 1 UNITS month) ||" and year(a.fecha_hora) = "|| year(dFechaHoy - 1 UNITS month) ||" AND a.tipo_tel = '2' AND a.status_tel = 'A' GROUP  BY telefono HAVING  COUNT(telefono) > 4) as tel_rep"
					|| " left join si_telefonos as tel_actual on tel_actual.telefono	= tel_rep.telefono and month(tel_actual.fecha_hora) = "|| month(dFechaHoy - 1 UNITS month) ||" and year(tel_actual.fecha_hora) = "|| year(dFechaHoy - 1 UNITS month)||""	
					|| " left join si_ejecut as si_e on si_e.ejecutivo = tel_actual.user_insert)";
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'gen_rep_cel_repetidos.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'gen_rep_cel_repetidos.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdinteg '||TRIM(pRutaDescarga)||'gen_rep_cel_repetidos.sql';
            SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'gen_rep_cel_repetidos.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			
			LET cSql = '';
			LET cSql = "sed s/^[ r]*//"||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
								
			LET cSql = '';
			LET cSql = "sed s/^[ r]*//"||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			
			
		COMMIT WORK;
		
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 854',
'AUTOR : 90127902 - Epigmenio Martinez Pedraza',
'FECHA : 25/05/2022',
'MODIFICACION: Se crea el proceso para la generacion del reporte de numeros repetidos 5 o mas en el mes anterior',
'SUSTENTO: Generar un reporte que contendrÃ¡ el detalle Ãºnicamente de',
          'los telÃ©fonos que se repitan 5 o mÃ¡s veces, el cual se depositara en la carpeta compartida',
          'de operaciones y se generara los primeros dÃ­as del mes',
'SOLICITA : Jorge Alberto GarcÃ­a LÃ³pez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_alta_ctemovil(pFolio CHAR(12))
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
DEFINE lenScve_elector  CHAR(18);
DEFINE subScve_elector  CHAR(2);
DEFINE iTotal 			INTEGER;

DEFINE ultimo 			INTEGER;

DEFINE s_exist_lugar_nac CHAR(2);
DEFINE s_exist_curp      CHAR(18);


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
LET ssvt_sMpo          = "00000";
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
LET lenScve_elector     = "";
LET subScve_elector     = "";
LET iTotal = 0;

LET s_exist_lugar_nac  = "";
LET s_exist_curp       = "";


BEGIN
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
	   RETURN iSqlErr, snumcte;
        END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/emm/sp_alta_ctemovil_PRUEBA.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

------------Insert en la tabla de pp_errores  para monitoreo
INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora) VALUES('00000', 'sp_alta_ctemovil', CURRENT, CURRENT);

------------Fin del insert en tabla pp_errores

SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
FROM bdinteg:si_fechas
WHERE empresa = '001';

DELETE FROM si_valida_folio_detalle
WHERE folio = pFolio
AND fecha = svt_fecha_hoy;

DELETE FROM bdisolic:ss_detalle_scoring_movil
WHERE bdisolic:ss_detalle_scoring_movil.empresa = svt_empresa
AND bdisolic:ss_detalle_scoring_movil.folio_movil = pFolio;

DELETE FROM bdisolic:ss_solicitudes_movil
WHERE  bdisolic:ss_solicitudes_movil.empresa = svt_empresa
AND  bdisolic:ss_solicitudes_movil.folio_movil = pFolio;


	--FOREACH --Se quita el ciclo que esta de mas
		--Arma Cursor Principal de si_solicitud_movil
		SELECT id, numcte, cte_coppel, numcte_coppel, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc,
			  ap_sexo, ap_calle, colonia, deleg_mpo, edo, ap_cod_postal, domicilio_actual, domicilio_alta, cve_elector, curp,
			  fecha_registro, estado, municipio, seccion, localidad, emision, vigencia, ocr, nivel_ingresos, edo_civil,
			  tpo_edo_civil, meses_edo_civil, tipo_residencia , tiempo_domicilio , actividad, subactividad, empresa, tel_trabajo,
			  tiempo_trabajo, tiempo_trab_ant, edad, pers_dependen, comp_ingresos, escolaridad, pers_domicilio,pers_trabajan, producto,
			  telefono_casa, telefono, carrier, email, num_tdc_coppel, status_tdc_coppel, num_prestamo, status_prestamo, num_tdc_bcoppel,
			  status_tdc_bcoppel, situacion_esp, causa, folio, geolocalizacion, firma_bc, fotografias, procesado_trans, folio_procesado,
			  status_solicitud,ejecutivo,fecha_insert, ap_apell_paterno, ap_apell_materno, ap_nombre1, ap_nombre2, ap_fecha_nac,pais_nac,
			  ap_id_estado,ap_id_ciudad,ap_id_colonia

		INTO sid, snumcte, scte_coppel, snumcte_coppel, sapell_paterno, sapell_materno, snombre1, snombre2, sfecha_nac, srfc,
			ssexo, scalle, scolonia, sdeleg_mpo, sedo, scod_postal, sdomicilio_actual, sdomicilio_alta, scve_elector, scurp,
			sfecha_registro, sestado, smunicipio, sseccion, slocalidad, semision, svigencia, socr, snivel_ingresos, sedo_civil,
			stpo_edo_civil, smeses_edo_civil, stipo_residencia, stiempo_domicilio, sactividad, ssubactividad, sempresa, stel_trabajo,
			stiempo_trabajo, stiempo_trab_ant, sedad, spers_dependen, scomp_ingresos, sescolaridad, spers_domicilio,spers_trabajan, sproducto,
			stelefono_casa, stelefono, scarrier, semail, snum_tdc_coppel, sstatus_tdc_coppel, snum_prestamo, sstatus_prestamo, snum_tdc_bcoppel,
			sstatus_tdc_bcoppel, ssituacion_esp, scausa, sfolio, sgeolocalizacion, sfirma_bc, sfotografias, sprocesado_trans, sfolio_procesado,
			sstatus_solicitud,sejecutivo,sfecha_insert, sAP_paterno, sAP_materno, sAP_nombre1, sAP_nombre2, sAP_fecha_nac,spais_nacimiento,
			ssvt_sEdo, ssvt_sCiudad, ssvt_sColonia
		FROM si_solicitud_movil
		WHERE folio_procesado = '0'
		AND folio = pFolio;

		LET sAP_paterno      = TRIM(sAP_paterno);
		LET sAP_materno      = TRIM(sAP_materno);
		LET sAP_nombre1      = TRIM(sAP_nombre1);
		LET sAP_nombre2      = TRIM(sAP_nombre2);
		LET ssexo            = TRIM(ssexo);
		LET snumcte          = TRIM(snumcte);
		LET scve_elector     = TRIM(scve_elector);

		 --Valida formato de la fecha de nacimiento
		LET svt_dia = "";
		LET svt_mes = "";
		LET svt_year = "";
		LET svt_dia = sAP_fecha_nac[1,2];
		LET svt_mes = sAP_fecha_nac[4,5];
		LET svt_year = sAP_fecha_nac[7,10];

		IF LENGTH(svt_year)<=2 THEN
			LET svt_year="19"||svt_year;
		END IF;
		LET sAP_fecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

		IF ssexo="H" THEN
			LET ssexo="M";
		ELIF ssexo="M" THEN
			LET ssexo="F";
		END IF;

	 ---Valida la sucursal asignada al ejecutivo.

		FOREACH
			SELECT sucursal INTO svt_sucursal
            FROM si_usuario_movil
            WHERE ejecutivo = sejecutivo
            AND activo = "1"
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

            RETURN sCodRet, snumcte;
			--CONTINUE FOREACH;
		END IF;

        -----VALIDA EN LISTA NEGRA-------------------------------------------
        LET sFechaLN = svt_mes ||'/'|| svt_dia ||'/'|| svt_year;

        EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra(sAP_nombre1, sAP_nombre2, sAP_paterno, sAP_materno, sFechaLN) INTO cCodRetLN;

        IF(cCodRetLN = '000002') THEN
            LET sDesc = 'En lista negra';
			LET sCodRet = '00008';

            INSERT INTO si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
            VALUES(pFolio,snumcte,UPPER(sAP_paterno),UPPER(sAP_materno),UPPER(sAP_nombre1),UPPER(sAP_nombre2),sAP_fecha_nac,TODAY);

            RETURN sCodRet, snumcte;
            --CONTINUE FOREACH;
        END IF;
        ----------------------------------------------------------

		--OBTENIENDO LOS DATOS DEL RFC MODIFICADO Y COMPARANDO CON EL RFC ACTUAL
		/*LET sAP_dia = "";
		LET sAP_mes = "";
		LET sAP_year = "";
		LET sAP_dia = sAP_fecha_nac[1,2];
		LET sAP_mes = sAP_fecha_nac[4,5];
		LET sAP_year = sAP_fecha_nac[7,10];*/

		IF LENGTH(svt_year)<=2 THEN
			LET svt_year="19"||svt_year;
		END IF;
		LET sAP_fecnac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

		CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		RETURNING sRetCod, sAP_rfc;

		LET sAP_rfc = trim(sAP_rfc);

		IF sRetCod<>'00000' THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00020";
			UPDATE si_solicitud_movil SET status_valua=2 WHERE folio = pFolio;
			--CONTINUE FOREACH;
            RETURN sCodRet, snumcte;
		END IF;
		UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE folio=pFolio;
                         --COMPARANDO RFC ORIGINAL CONTRA RFC NUEVO, SI LOS RFC'S SON DISTINTOS...
		IF srfc<>sAP_rfc THEN
			--SE BUSCA QUE NO EXISTA EL RFC MODIFICADO EN LA TABLA DE CLIENTES
			select FIRST 1 1 INTO iTotal FROM si_cliente where rfc=sAP_rfc;

			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				--EN CASO DE EXISTIR, SE TOMA EL CLIENTE MODIFICADO Y SE ACTUALIZA LA TABLA DE SOLICITUD MOVIL CON ESE DATO

				LET snumcte=(select numcte FROM si_cliente where rfc=sAP_rfc);
				LET snumcte=trim(snumcte);

				UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE folio=pFolio;

				LET lenScve_elector = LENGTH(scve_elector);
				LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);

				IF lenScve_elector =18 THEN
					IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
						LET scve_elector='';
					ELSE
						LET scve_elector=substr(scve_elector,13,2);
						--UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte	and lugar_nac='' and validacurp is null;
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
				--LET sfecha_nac= sAP_fecnac;
			END IF;
		END IF;

        IF snumcte IS NULL OR snumcte = "" THEN

			IF LENGTH(spers_domicilio)<=2 THEN
			   LET spers_domicilio="0"||spers_domicilio;
			END IF;

            ---Ejecuta la Rutina de ALTA de Clientes
			LET lenScve_elector = LENGTH(scve_elector);
			LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);

			IF lenScve_elector = 18 THEN
				IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
					LET scve_elector='';
				ELSE
					LET scve_elector=substr(scve_elector,13,2);
					--UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte and lugar_nac='' and validacurp is null;
				END IF;
			END IF;

			CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sapell_paterno,sapell_materno,snombre1,snombre2,srfc,
						  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
						  sAP_fecnac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
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

				--CONTINUE FOREACH;
                RETURN sCodRet, snumcte;
			ELSE
				LET snumcte = svt_numcte;
				IF (sRetCod = "104") OR (sRetCod = "106") OR (sRetCod = "118") THEN
					LET snumcte = (select numcte from si_cliente where rfc=srfc);
					LET snumcte = trim(snumcte);
					LET svt_numcte=snumcte;
					LET lenScve_elector = LENGTH(scve_elector);
					LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);

						IF lenScve_elector =18 THEN
							IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
								LET scve_elector='';
							ELSE
								LET scve_elector=substr(scve_elector,13,2);
								--UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte	and lugar_nac='' and validacurp is null;
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
			SELECT lugar_nac,curp 
			INTO s_exist_lugar_nac,s_exist_curp
			FROM si_ctepf
			WHERE numcte = snumcte;
			
			IF s_exist_lugar_nac <> "" THEN
				LET scve_elector = s_exist_lugar_nac;
			ELSE
				LET lenScve_elector = LENGTH(scve_elector);
				LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);

				IF lenScve_elector =18 THEN
					IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
						LET scve_elector='';
					ELSE
						LET scve_elector=substr(scve_elector,13,2);
						--UPDATE si_ctepf SET lugar_nac=scve_elector where numcte=snumcte and lugar_nac='' and validacurp is null;
					END IF;
				END IF;
			END IF;

			IF s_exist_curp <> "" THEN
				LET scurp = s_exist_curp;
			END IF;

			CALL ctefisico(svt_empresa,"C",snumcte,svt_sucursal,sejecutivo,"01","2",sapell_paterno,sapell_materno,snombre1,snombre2,srfc,
			"32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
			sAP_fecnac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
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

		--Validando Codigo Postal
		CALL sp_valida_numero(scod_postal)
		RETURNING sRetCod, sSPosc1, sSPosc2, sSPosc3, sSPosc4, sSPosc5;

		IF sRetCod<>"00000" THEN
			SELECT cp INTO scod_postal FROM si_ptf WHERE id_ptf='0010' AND tipo = 'S';
		END IF;

		--Se ejecuta la Actualizacion de la Direccion Actual.
		--CALL sp_act_dirmovil(scod_postal,snumcte)
		--RETURNING sRetCod,ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,ssvt_sCP,ssvt_sNumCiudad,ssvt_sColonia,ssvt_sMpo;

		SELECT
			limit 1 {+INDEX (bdinteg:si_ciudades ix_2363)}{+INDEX (bdinteg:si_catzonas idx_zona)}
			b.pais, a.numerociudad
		INTO
			ssvt_Pais, ssvt_sNumCiudad
		FROM
			bdinteg:si_catzonas a
			JOIN
			bdinteg:si_ciudades b ON a.numerociudad=b.ciudad_coppel AND a.numerociudad<>0
		WHERE
			b.estado = ssvt_sEdo
			AND
			b.ciudad = ssvt_sCiudad
			AND
			a.numerocolonia = ssvt_sColonia
			AND
			a.codigopostalzona = scod_postal;

		IF ssvt_sEdo = '09' THEN
			LET ssvt_sMpo='00'||ssvt_sCiudad;
		END IF;

		LET sRetCod = '00000';
		LET ssvt_sCP = scod_postal;

		IF sRetCod != "00000" THEN
			INSERT INTO si_valida_folio_detalle
			VALUES(pFolio,"sp_act_dirmovil",snumcte,sRetCod,svt_fecha_hoy);
			LET sCodRet = "00016";
			--Actualiza el status_valua por el folio

			UPDATE si_solicitud_movil
			SET(status_valua)=(2)
			WHERE folio = pFolio;

			--CONTINUE FOREACH;
            RETURN sCodRet, snumcte;
		END IF;

		---Ejecuta la Rutina de ALTA de Direcciones
		SELECT tipo_cliente  INTO sTpoCte FROM bdinteg:si_cliente WHERE numcte=snumcte;
		IF sTpoCte ="2" THEN
			CALL direcciones(svt_empresa,"A",snumcte,0,"1",scalle," ",ssvt_sMpo," ",ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,scod_postal,"1",
			stelefono_casa,"2",stelefono,"3",stel_trabajo," "," "," "," ",ssvt_sNumCiudad," "," "," ",
			134176,ssvt_sColonia," ","N",0,0,0,0,0,0,0," ",sejecutivo,svt_fecha_hoy,svt_sucursal)
			RETURNING sRetCod;

			IF sRetCod != "000" THEN
				INSERT INTO si_valida_folio_detalle
				VALUES(pFolio,"direcciones",snumcte,sRetCod,svt_fecha_hoy);
				LET sCodRet = "00003";
				--Actualiza el status_valua por el folio
				UPDATE si_solicitud_movil
				SET(status_valua)=(2)
				WHERE folio = pFolio;

				--CONTINUE FOREACH;
                RETURN sCodRet, snumcte;
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

			--CONTINUE FOREACH;
            RETURN sCodRet, snumcte;
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

			--CONTINUE FOREACH;
            RETURN sCodRet, snumcte;
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

					--CONTINUE FOREACH;
                    RETURN sCodRet, snumcte;
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

				  --CONTINUE FOREACH;
                  RETURN sCodRet, snumcte;
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
            ELIF svt_sucursal="5124" THEN
			   LET svt_sucursal="0336";
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
				--CONTINUE FOREACH;
                RETURN sCodRet, snumcte;
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
            ELIF svt_sucursal="5124" THEN
			   LET svt_sucursal="0336";
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
			   --CONTINUE FOREACH;
               RETURN sCodRet, snumcte;
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
            ELIF svt_sucursal="5124" THEN
			   LET svt_sucursal="0336";
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

				--CONTINUE FOREACH;
                RETURN sCodRet, snumcte;
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
		IF snumcte IS NULL OR snumcte = "" AND sfirma_bc = "1" THEN
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

					--CONTINUE FOREACH;
                    RETURN sCodRet, snumcte;
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

				--CONTINUE FOREACH;
                RETURN sCodRet, snumcte;
			END IF;
		END IF;

		LET vt_fech_hora = "";
		SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
		FROM sysmaster:"informix".sysshmvals;

		UPDATE si_solicitud_movil
		SET(fecha_profin)=(vt_fech_hora)
		WHERE folio = pFolio;
	--END FOREACH;
	--Se quita el ciclo que esta de mas
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
"Ver.  : 1.8",
"Mod   : Se comentan los siguientes UPDATE",
"AUTOR : Eduardo Martinez Martinez",
"FECHA : 09/Julio/2020",
"Ver.  : 1.9";

CREATE PROCEDURE "informix".sp_cte_ctefisico(pIdSolMovil INTEGER)
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret            CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE sid                INTEGER;
DEFINE snumcte            CHAR(20);
DEFINE sfolio             CHAR(12);
DEFINE sstatus_valua      INTEGER;
DEFINE sfecha_insert      DATE;
DEFINE IfirmaCop		  INT;
DEFINE IfirmaBan		  INT;
DEFINE IBuro     		  INT;
--Valida numero cliente
DEFINE svt_empresa        CHAR(3);
DEFINE svt_sucursal       CHAR(4);
DEFINE sejecutivo         CHAR(8);
DEFINE sAP_paterno        CHAR(26);
DEFINE sAP_materno        CHAR(26);
DEFINE sAP_nombre1        CHAR(26);
DEFINE sAP_nombre2        CHAR(26);
DEFINE srfc               CHAR(13);
DEFINE snumcte_coppel     CHAR(20);
DEFINE sAP_fecha_nac      CHAR(10);
DEFINE svt_dia            CHAR(2);
DEFINE svt_mes            CHAR(2);
DEFINE svt_year           CHAR(4);
DEFINE scve_elector       CHAR(18);
DEFINE sedo_civil         CHAR(1);
DEFINE sactividad         CHAR(2);
DEFINE ssexo              CHAR(1);
DEFINE scurp              CHAR(18);
DEFINE socr               CHAR(13);
DEFINE semail             CHAR(100);
DEFINE sescolaridad       CHAR(2);
DEFINE stipo_residencia   CHAR(1);
DEFINE spers_domicilio    CHAR(2);
DEFINE sRetCod            CHAR(5);
DEFINE sAP_rfc            CHAR(13);
DEFINE sAP_rfc_2          CHAR(13);
DEFINE svt_fecha_hoy      DATE;
DEFINE spais_nacimiento	  CHAR(3);

--Inicializacion de variables
LET vcodret              = '00000';
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sfecha_insert        = "";
LET IfirmaCop			 = 0;
LET IfirmaBan            = 0;
LET IBuro                = 0;
--Valida numero cliente
LET svt_empresa          = "001";
LET svt_sucursal         = "";
LET sejecutivo           = "";
LET sAP_paterno          = '';
LET sAP_materno          = '';
LET sAP_nombre1          = '';
LET sAP_nombre2          = '';
LET srfc                 = "";
LET snumcte_coppel       = "";
LET sAP_fecha_nac        = '';
LET svt_dia              = "";
LET svt_mes              = "";
LET svt_year             = "";
LET scve_elector         = "";
LET sedo_civil           = "";
LET sactividad           = "";
LET ssexo                = "";
LET scurp                = "";
LET socr                 = "";
LET semail               = "";
LET sescolaridad         = "";
LET stipo_residencia     = "";
LET spers_domicilio      = "";
LET sRetCod              = "";
LET sAP_rfc              = '';
LET sAP_rfc_2            = '';
LET svt_fecha_hoy        = "";
LET spais_nacimiento     = "";

--SET DEBUG FILE TO '/informix/emm/sp_cte_ctefisico.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

BEGIN
	ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
	RETURN vCodret;
	END IF;
	END EXCEPTION

	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

	SELECT id, numcte, folio,status_valua,fecha_insert,firma_cc,firma_bc,firma_buro,
			ejecutivo,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,rfc,numcte_coppel,ap_fecha_nac,edo_civil,
			actividad,ap_sexo,curp,ocr,email,escolaridad,tipo_residencia,pais_nac,ap_rfc
	INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert,IfirmaCop,IfirmaBan,IBuro,
			sejecutivo,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,srfc,snumcte_coppel,sAP_fecha_nac,sedo_civil,
			sactividad,ssexo,scurp,socr,semail,sescolaridad,stipo_residencia,spais_nacimiento,sAP_rfc_2
	FROM bdinteg:si_solicitud_movil
	WHERE bdinteg:si_solicitud_movil.id=pIdSolMovil
	AND bdinteg:si_solicitud_movil.status_valua=0;
	
	IF sid IS NULL OR sid ="" THEN
		LET vcodret          = '00001';
	ELSE
		LET sAP_paterno      = TRIM(sAP_paterno);
		LET sAP_materno      = TRIM(sAP_materno);
		LET sAP_nombre1      = TRIM(sAP_nombre1);
		LET sAP_nombre2      = TRIM(sAP_nombre2);
		LET ssexo            = TRIM(ssexo);
		LET snumcte          = TRIM(snumcte);
		--Valida formato de la fecha de nacimiento
		LET svt_dia          = sAP_fecha_nac[1,2];
		LET svt_mes          = sAP_fecha_nac[4,5];
		LET svt_year         = sAP_fecha_nac[7,10];
		
		IF LENGTH(svt_year)<=2 THEN	
			IF TRIM(svt_year) IN ('00','01','02','03','04','05','06','07','08','09','10') THEN
				LET svt_year="20"||svt_year;
			ELSE
				LET svt_year="19"||svt_year;
			END IF
		END IF;

		IF ssexo="H" THEN
			LET ssexo="M";
		ELIF ssexo="M" THEN
			LET ssexo="F";
		END IF;

		FOREACH
			SELECT sucursal INTO svt_sucursal FROM si_usuario_movil WHERE ejecutivo = sejecutivo AND activo = "1"
		END FOREACH;

		IF svt_sucursal IS NULL OR svt_sucursal = "" THEN
			LET sRetCod = "00015";
			INSERT INTO si_valida_folio_detalle VALUES (sfolio,"nohayejecutivo",snumcte,sRetCod,svt_fecha_hoy);
			UPDATE si_solicitud_movil SET status_valua = 2 WHERE id=sid;
		END IF;
		
		LET sAP_fecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);
		
		--Calcula e inserta bdinteg:si_solicitud_movil.ap_rfc en caso de que sea null o ""
		IF sAP_rfc_2 IS NULL OR sAP_rfc_2 = "" THEN
			CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecha_nac)
			RETURNING sRetCod, sAP_rfc;
			
			LET sAP_rfc = trim(sAP_rfc);

			IF sRetCod<>'00000' THEN
				INSERT INTO si_valida_folio_detalle VALUES (sfolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
				
				UPDATE si_solicitud_movil SET status_valua=2 WHERE id=sid;
				
			END IF;
			UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE id=sid; 
		ELSE
			LET sAP_rfc = trim(sAP_rfc_2);
		END IF;
		
		LET sRetCod = "000";
		
		--Calcula e inserta bdinteg:si_solicitud_movil.numcte en caso de que sea null o ""
		IF snumcte IS NULL OR snumcte = "" THEN
			
			SELECT numcte INTO snumcte FROM si_cliente WHERE rfc = sAP_rfc;
			
			IF snumcte IS NULL OR snumcte = "" THEN
			
				CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_rfc,
							  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
							  sAP_fecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
							 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
				RETURNING sRetCod,snumcte;
			
			END IF;
			IF snumcte IS NOT NULL AND snumcte != "" THEN
				UPDATE si_solicitud_movil SET numcte=snumcte WHERE id=sid;
			END IF;
		END IF;
		
		IF sRetCod<>'000' THEN
			INSERT INTO si_valida_folio_detalle VALUES (sfolio,'ctefisico',snumcte,sRetCod,svt_fecha_hoy);
		END IF;
	END IF;
	
RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Jorge Alberto Garcia Lopez",
"Descripcion: Ejecuta el SPL ctefisico",
"Fecha      : 29/01/2020",
"Version    : 1.1",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_monitor_numctemovil()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret            CHAR(5);
DEFINE vcodretdet         CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE sid                INTEGER;
DEFINE snumcte            CHAR(20);
DEFINE sfolio             CHAR(12);
DEFINE sstatus_valua      INTEGER;
DEFINE sfecha_insert      DATE;
DEFINE vt_status_valua    INTEGER;
DEFINE iexiste_imagen0602 INTEGER;
DEFINE iexiste_imagen0601 INTEGER;
DEFINE iexiste_imagen0600 INTEGER;
DEFINE iexiste_imagen0001 INTEGER;
DEFINE IfirmaCop		  INT;
DEFINE IfirmaBan		  INT;
DEFINE IBuro     		  INT;
--Valida numero cliente
DEFINE svt_empresa        CHAR(3);
DEFINE svt_sucursal       CHAR(4);
DEFINE sejecutivo         CHAR(8);
DEFINE sAP_paterno        CHAR(26);
DEFINE sAP_materno        CHAR(26);
DEFINE sAP_nombre1        CHAR(26);
DEFINE sAP_nombre2        CHAR(26);
DEFINE srfc               CHAR(13);
DEFINE snumcte_coppel     CHAR(20);
DEFINE sAP_fecha_nac      CHAR(10);
DEFINE svt_dia            CHAR(2);
DEFINE svt_mes            CHAR(2);
DEFINE svt_year           CHAR(4);
DEFINE scve_elector       CHAR(18);
DEFINE sedo_civil         CHAR(1);
DEFINE sactividad         CHAR(2);
DEFINE ssexo              CHAR(1);
DEFINE scurp              CHAR(18);
DEFINE socr               CHAR(13);
DEFINE semail             CHAR(100);
DEFINE sescolaridad       CHAR(2);
DEFINE stipo_residencia   CHAR(1);
DEFINE spers_domicilio    CHAR(2);
DEFINE sRetCod            CHAR(5);
DEFINE lenScve_elector    CHAR(18);
DEFINE subScve_elector    CHAR(2);
DEFINE iTotal 			  INTEGER;
DEFINE sAP_rfc            CHAR(13);
DEFINE svt_fecha_hoy      DATE;
DEFINE spais_nacimiento	  CHAR(3);
DEFINE svt_numcte         CHAR(20);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sfecha_insert        = "";
LET vt_status_valua      = 0;
LET iexiste_imagen0602   = 0;
LET iexiste_imagen0601   = 0;
LET iexiste_imagen0600   = 0;
LET iexiste_imagen0001   = 0;
LET IfirmaCop			 = 0;
LET IfirmaBan            = 0;
LET IBuro                = 0;
--Valida numero cliente
LET svt_empresa          = "001";
LET svt_sucursal         = "";
LET sejecutivo           = "";
LET sAP_paterno          = '';
LET sAP_materno          = '';
LET sAP_nombre1          = '';
LET sAP_nombre2          = '';
LET srfc                 = "";
LET snumcte_coppel       = "";
LET sAP_fecha_nac        = '';
LET svt_dia              = "";
LET svt_mes              = "";
LET svt_year             = "";
LET scve_elector         = "";
LET sedo_civil           = "";
LET sactividad           = "";
LET ssexo                = "";
LET scurp                = "";
LET socr                 = "";
LET semail               = "";
LET sescolaridad         = "";
LET stipo_residencia     = "";
LET spers_domicilio      = "";
LET sRetCod              = "";
LET lenScve_elector      = "";
LET subScve_elector      = "";
LET iTotal               = 0;
LET sAP_rfc              = '';
LET svt_fecha_hoy        = "";
LET spais_nacimiento     = "";
LET svt_numcte           = "";

--SET DEBUG FILE TO '/informix/VH/sp_monitor_numctemovil.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

BEGIN
 ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
		RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF vcodret != "000" THEN

    LET vcodret = "999";
    --RETURN vCodret;

 END IF;
 
 SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
 FROM bdinteg:si_fechas
 WHERE empresa = '001';

 ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
	SELECT {+INDEX (bdinteg:si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert,firma_cc,firma_bc,firma_buro,
			ejecutivo,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,rfc,numcte_coppel,ap_fecha_nac,edo_civil,
			actividad,ap_sexo,curp,ocr,email,escolaridad,tipo_residencia,pais_nac
	INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert,IfirmaCop,IfirmaBan,IBuro,
			sejecutivo,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,srfc,snumcte_coppel,sAP_fecha_nac,sedo_civil,
			sactividad,ssexo,scurp,socr,semail,sescolaridad,stipo_residencia,spais_nacimiento
	FROM bdinteg:si_solicitud_movil
	WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
	AND bdinteg:si_solicitud_movil.status_valua = 0
	ORDER BY folio
	
	LET sAP_paterno      = TRIM(sAP_paterno);
	LET sAP_materno      = TRIM(sAP_materno);
	LET sAP_nombre1      = TRIM(sAP_nombre1);
	LET sAP_nombre2      = TRIM(sAP_nombre2);
	LET ssexo            = TRIM(ssexo);
	LET snumcte          = TRIM(snumcte);
	--Valida formato de la fecha de nacimiento
	LET svt_dia          = sAP_fecha_nac[1,2];
	LET svt_mes          = sAP_fecha_nac[4,5];
	LET svt_year         = sAP_fecha_nac[7,10];
	
	IF LENGTH(svt_year)<=2 THEN
		LET svt_year="19"||svt_year;
	END IF;

	IF ssexo="H" THEN
		LET ssexo="M";
	ELIF ssexo="M" THEN
		LET ssexo="F";
	END IF;
	
	FOREACH
		SELECT sucursal INTO svt_sucursal FROM si_usuario_movil WHERE ejecutivo = sejecutivo AND activo = "1"
	END FOREACH;

	IF svt_sucursal IS NULL OR svt_sucursal = "" THEN
		LET sRetCod = "00015";
		
		INSERT INTO si_valida_folio_detalle VALUES (sfolio,"nohayejecutivo",snumcte,sRetCod,svt_fecha_hoy);
		
		UPDATE si_solicitud_movil SET status_valua = 2 WHERE folio = sfolio;
		  
		CONTINUE FOREACH;
	END IF;
	
	LET sAP_fecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);
	
	CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecha_nac)
	RETURNING sRetCod, sAP_rfc;
	
	LET sAP_rfc = trim(sAP_rfc);

	IF sRetCod<>'00000' THEN
		INSERT INTO si_valida_folio_detalle VALUES (sfolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
		
		UPDATE si_solicitud_movil SET status_valua=2 WHERE folio = sfolio;
		
		CONTINUE FOREACH;
	END IF;
	
	UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE folio=sfolio; 
	
	LET sRetCod = "000";
	
	IF snumcte IS NULL OR snumcte = "" THEN
		
		SELECT numcte INTO snumcte FROM si_cliente WHERE rfc = sAP_rfc;
		
		IF snumcte IS NULL OR snumcte = "" THEN
		
			CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_rfc,
						  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
						  sAP_fecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
						 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
			RETURNING sRetCod,snumcte;
		
		END IF;
		
	END IF;
	
	IF (snumcte IS NULL) OR (snumcte = "")  THEN
		
		CONTINUE FOREACH;
		
	END IF;
	
	UPDATE si_solicitud_movil SET numcte=snumcte WHERE id=sid; 

	--Validacion en bdidigital@coppelimg_tcp:dg_expediente_img1
	LET IfirmaCop        = NVL(IfirmaCop,0);
	LET IfirmaBan        = NVL(IfirmaBan,0);
	LET IBuro            = NVL(IBuro,0);
	
	SELECT
		COUNT(*) INTO iexiste_imagen0001
	FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
	JOIN bdidigital@coppelimg_tcp:dg_expediente b 
		ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
	WHERE 
		a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0001';
	
	IF iexiste_imagen0001 = 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0001
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.cod_docto='0001';
	
		IF iexiste_imagen0001 = 0 THEN
			SELECT
				COUNT(*) INTO iexiste_imagen0001
			FROM bdidigital@coppelimg_tcp:dg_expediente_img2 a
			JOIN bdidigital@coppelimg_tcp:dg_expediente b 
				ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta AND a.secuencia = b.secuencia
			WHERE 
				a.cliente = snumcte AND a.cod_docto='0001';
			
			IF iexiste_imagen0001 = 0 THEN
				CONTINUE FOREACH;
			END IF;
		END IF;
	END IF;
	
	IF IfirmaCop > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0600
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0600';
			
		IF iexiste_imagen0600 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
	
	IF IfirmaBan > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0601
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0601';
			
		IF iexiste_imagen0601 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
	
	IF IBuro > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0602
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0602';
			
		IF iexiste_imagen0602 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
		
	--Ejecuta rutina de alta de solicitud por folio
	IF sfolio IS NOT NULL THEN

		CALL sp_ALTA_CTEMOVIL(sfolio)
		RETURNING vcodretdet,snumcte;

		IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

		   LET vt_status_valua = 0;

		   SELECT status_valua INTO vt_status_valua
		   FROM si_solicitud_movil
		   WHERE folio = sfolio;
	   
		   IF vt_status_valua = 1 THEN

			  UPDATE si_solicitud_movil
			  SET(status_valua)=(1)
			  WHERE folio = sfolio;
		   END IF;

		END IF;
		
	END IF;
			
		
		
 END FOREACH;

RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 11/03/2015",
"Version    : 1.2",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_valida_cel_repetido(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;
DEFINE iValidaDiasTu    INTEGER;
DEFINE sTelefonoAct CHAR(13);

LET sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;
LET iValidaDiasTu    = 0;
LET sTelefonoAct     = 0;

BEGIN
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LMendoza/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;  
    SET LOCK MODE TO WAIT 3;
	
	SELECT telefono INTO sTelefonoAct FROM bdinteg:"informix".si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel=2;
		IF (TRIM(sTelefonoAct) == TRIM(pNumCel)) THEN RETURN sCodRet, iCantRep;
			END IF;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel IN ('A','C') AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
	

		
	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;