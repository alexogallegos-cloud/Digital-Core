CREATE PROCEDURE "informix".sp_camp_tdc_inact_nunc_crea_arch(pEmpresa CHAR(3), pTipo_camp CHAR(3), psNumCamp SMALLINT, 
                                                            pdfecha_gen_camp DATE, pdfecha_desde DATE, pdfecha_hasta DATE, pdFechaHoy DATE )

RETURNING CHAR(6);

-- Creado: MAHR. Julio 2013.- Genera el archivo con la informacion del cliente de cada campaña para el CAT.
--                            Genera archivo para envio de SMS y envio de SMS a través de Latinia


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cMensaje				CHAR(80);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cdelimitadorsms      CHAR(1);
DEFINE cruta                CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cMesFecha            CHAR(3);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(2500);
DEFINE cSQL3                CHAR(500);
DEFINE cSms_Envio           CHAR(1);
DEFINE cSms_archivo         CHAR(1);
DEFINE vnumTarjeta          CHAR(20);
DEFINE cNumCredito          CHAR(20);
DEFINE cNumCte              CHAR(20);
DEFINE cNomEstado           CHAR(20);
DEFINE cNomCiudad           CHAR(20);
DEFINE cTelCel              CHAR(13);
DEFINE cNombre1             CHAR(26);
DEFINE cNombre2             CHAR(26);
DEFINE cApellPat            CHAR(26);
DEFINE cApellMat            CHAR(26);
DEFINE cNombreCte           CHAR(10);
DEFINE cNumCta              CHAR(20);
DEFINE iMax_Regs_camp       INTEGER;
DEFINE cIdPlantillaSMS      CHAR(10);
DEFINE iCel                 SMALLINT;
DEFINE iContador            INTEGER;
DEFINE sTot_CtesSms         SMALLINT;
DEFINE cTotCtesSms          CHAR(10);
DEFINE cArchCorr_Credisol   CHAR(1);
DEFINE iMinCorre_cred       DECIMAL(18,2);

--SET DEBUG FILE TO "/informix/gpe/sp_camp_tdc_inact_nunc_crea_arch.out";
--TRACE ON;

--Inicialización de variables
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = '';
LET cCod_ret            = '000000';
LET cCod_RetIB          = '';
LET cMensaje            = 'PROCESO EXITOSO';
LET vproceso			= '0506';
LET cempresa            = '';
LET cdelimitador        = '';
LET cdelimitadorsms     = '';
LET cruta               = '';
LET cnomarchivo         = '';
LET cnomarchivo1		= '';
LET cnomarchivoejecsql  = '';
LET cMesFecha           = '';
LET cSQL                = '';
LET cSQL1               = '';
LET cSQL2               = '';
LET cSQL3               = '';
LET cSms_Envio          = '';
LET cSms_archivo        = '';
LET vnumTarjeta         = '';
LET cNumCredito         = '';
LET cNumCte             = '';
LET cNomEstado          = '';
LET cNomCiudad          = '';
LET cTelCel             = '';
LET cNombre1            = '';
LET cNombre2            = '';
LET cApellPat           = '';
LET cApellMat           = '';
LET cNombreCte          = '';
LET cNumCta             = '';
LET iMax_Regs_camp      = 0;
LET cIdPlantillaSMS     = '';
LET iCel                = 0;
LET iContador           = 0;
LET sTot_CtesSms        = 0;
LET cTotCtesSms         = '';
LET cArchCorr_Credisol  = '';
LET iMinCorre_cred      = 0;

                      
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR ||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'GENERA ARCHIVO'||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;

    -- Elimina tabla temporal
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_arch_telef_sms' ) THEN DROP TABLE tmp_arch_telef_sms; END IF;   
	-- Elimina tabla temporal2
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'temp_sd_camp_inactiv_nuncas' ) THEN DROP TABLE temp_sd_camp_inactiv_nuncas; END IF;   

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(pTipo_camp, '') = '' OR NVL(psNumCamp, 0) = 0 OR pdfecha_gen_camp = date(1) OR pdfecha_desde = date(1) 
       OR pdfecha_hasta = date(1) ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;
  
	--Obtener caracter delimitador
    SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 61 AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;
	IF NVL(cdelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Obtiene la ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 1; 
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret = '104005';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||psNumCamp::CHAR, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
    IF month(pdFechaHoy) = 1    THEN LET cMesFecha = 'ENE';
    ELIF month(pdFechaHoy) = 2  THEN LET cMesFecha = 'FEB';
    ELIF month(pdFechaHoy) = 3  THEN LET cMesFecha = 'MAR';
    ELIF month(pdFechaHoy) = 4  THEN LET cMesFecha = 'ABR';
    ELIF month(pdFechaHoy) = 5  THEN LET cMesFecha = 'MAY';
    ELIF month(pdFechaHoy) = 6  THEN LET cMesFecha = 'JUN';
    ELIF month(pdFechaHoy) = 7  THEN LET cMesFecha = 'JUL';
    ELIF month(pdFechaHoy) = 8  THEN LET cMesFecha = 'AGO';
    ELIF month(pdFechaHoy) = 9  THEN LET cMesFecha = 'SEP';
    ELIF month(pdFechaHoy) = 10 THEN LET cMesFecha = 'OCT';
    ELIF month(pdFechaHoy) = 11 THEN LET cMesFecha = 'NOV';
    ELSE LET cMesFecha = 'DIC'; END IF;

	-- Crea tabla y llena informacion de telefonos de los clientes, segun la campaña correspondiente.
    CREATE TABLE temp_sd_camp_inactiv_nuncas
	(
	tipo_campania char(3),	tipo_logica smallint,	num_credito char(20),
	numcte char(20),prioridad integer,nombre char(50),	sexo char(2),	
	estado_civil char(2),	email char(60),	estado char(30),
	telefono1            CHAR(13),    telefono2            CHAR(13),    telefono3            CHAR(13),
	telefono4            CHAR(13),    extension            CHAR(05));
	
	INSERT INTO temp_sd_camp_inactiv_nuncas
	SELECT camp.tipo_campania, camp.tipo_logica, camp.num_credito, camp.numcte, camp.prioridad,
		trim(camp.ap_paterno)||' '||trim(camp.ap_materno)||' '||trim(camp.primer_nombre)||' '||trim(camp.segundo_nombre) nombre,
		camp.sexo, camp.estado_civil, camp.email, camp.estado, tel1.telefono_orig, tel2.telefono_orig, tel3.telefono_orig, tel4.telefono_orig,
		tel3.extension FROM bdicred:sd_camp_inactiv_nuncas camp
	LEFT OUTER JOIN bdinteg:si_telefonos_nvo_layout_cat tel1 ON (camp.numcte = tel1.numcte and tel1.tipotelefono = '1'
		AND tel1.grupo_archivos = 'INA_NUN')
	LEFT OUTER JOIN bdinteg:si_telefonos_nvo_layout_cat tel2 ON (camp.numcte = tel2.numcte and tel2.tipotelefono = '2'
		AND tel2.grupo_archivos = 'INA_NUN')
	LEFT OUTER JOIN bdinteg:si_telefonos_nvo_layout_cat tel3 ON (camp.numcte = tel3.numcte and tel3.tipotelefono = '3'
		AND tel3.grupo_archivos = 'INA_NUN')
	LEFT OUTER JOIN bdinteg:si_telefonos_nvo_layout_cat tel4 ON (camp.numcte = tel4.numcte and tel4.tipotelefono = '4'
		AND tel4.grupo_archivos = 'INA_NUN')
		WHERE camp.fecha_gen_campania = pdfecha_gen_camp
		AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = psNumCamp 
		AND camp.fecha_entreg_desde = pdfecha_desde AND camp.fecha_entreg_hasta = pdfecha_hasta
		AND camp.status_cte = 'INACT';
		--ORDER BY camp.grupo, camp.prioridad ASC;
		
		update temp_sd_camp_inactiv_nuncas 
		set telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''), 
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),'');
		--Elimina
		delete from temp_sd_camp_inactiv_nuncas where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		and nvl(telefono4,'')='';

		update temp_sd_camp_inactiv_nuncas set telefono2 = ''
		where nvl(telefono1,'')= nvl(telefono2,'');

		update temp_sd_camp_inactiv_nuncas set telefono3 = ''
		where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

		update temp_sd_camp_inactiv_nuncas set telefono4 = ''
		where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,'');

		update temp_sd_camp_inactiv_nuncas 
		set telefono4 = nvl(telefono4,'') ,
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,''); 		

		update temp_sd_camp_inactiv_nuncas 
		set telefono4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono4,1,2) else SUBSTR(telefono4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then SUBSTR(telefono4,3,4) else SUBSTR(telefono4,4,3) end 
						   AND (SUBSTR(telefono4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono4 ,
			telefono1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono1,1,2) else SUBSTR(telefono1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then SUBSTR(telefono1,3,4) else SUBSTR(telefono1,4,3) end 
						   AND (SUBSTR(telefono1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono1 ,		 
			telefono2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono2 ,1,2) else SUBSTR(telefono2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then SUBSTR(telefono2 ,3,4) else SUBSTR(telefono2,4,3) end 
						   AND (SUBSTR(telefono2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono2 ,
			telefono3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono3,1,2) else SUBSTR(telefono3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then SUBSTR(telefono3,3,4) else SUBSTR(telefono3,4,3) end 
						   AND (SUBSTR(telefono3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono3; 
			
			update temp_sd_camp_inactiv_nuncas 
			set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3);

    LET cnomarchivo1 = trim(pTipo_camp)||'_Aux_'|| cMesFecha || substr(year(pdFechaHoy),1) ||'_'|| psNumCamp::CHAR || '.txt';  
    LET cnomarchivo  = trim(pTipo_camp)||'_'|| cMesFecha ||'_'|| substr(year(pdFechaHoy),1) ||'_' || psNumCamp::CHAR || '.txt';
    LET cnomarchivoejecsql = 'Ejecuta_camp_inact_nunca.sql';

    LET cSQL='';
    LET cSQL = 'echo "tipo_promocion'|| cdelimitador ||'tipo_logica'|| cdelimitador ||'num_credito'|| cdelimitador ||'num_cliente'|| cdelimitador ||'prioridad'|| cdelimitador ||'nombre'|| cdelimitador 
                ||'sexo'||cdelimitador ||'estado_civil'||cdelimitador ||'email' || cdelimitador || 'estado' || cdelimitador ||'telefono_1'|| cdelimitador || 'telefono_2' || cdelimitador || 'telefono_3' || cdelimitador 
                ||'telefono_4' ||cdelimitador || 'extension' || cdelimitador || ' " >' ||TRIM(cruta)|| cnomarchivo;
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = " SELECT camp.tipo_campania, camp.tipo_logica, camp.num_credito, camp.numcte, camp.prioridad, "
        || " camp.nombre, "
        || " camp.sexo, camp.estado_civil, camp.email, camp.estado, camp.telefono1, camp.telefono2, camp.telefono3, camp.telefono4, "
        || " camp.extension FROM bdicred:temp_sd_camp_inactiv_nuncas camp ORDER BY prioridad ASC";

    LET cSQL3 = '">'||TRIM(cruta)|| cnomarchivoejecsql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cruta)|| cnomarchivoejecsql;
    System cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || cnomarchivoejecsql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

	--DROP TABLE temp_sd_camp_inactiv_nuncas;
    ---------------------------------------------------------------------------------------------------
    --                                      ENVIO DE SMS                                             --
    ---------------------------------------------------------------------------------------------------

    -- Parametros para generar el archivo y/o envio automatico de los mensajes SMS
    SELECT trim(valor_alfabetico) INTO cSms_archivo FROM bdicred:sd_param_campania WHERE empresa=pempresa AND tipo_campania=3 AND grupo_parametro='CAMPINCNUN' AND num_parametro=27;
    SELECT trim(valor_alfabetico) INTO cSms_Envio FROM bdicred:sd_param_campania WHERE empresa=pempresa AND tipo_campania=3 AND grupo_parametro='CAMPINCNUN' AND num_parametro=28;

    -- Obtiene nombre de plantilla y registros de acuerdo a la campaña a generar.
    IF psNumCamp = 2 THEN
        SELECT valor_numerico, trim(valor_alfabetico) INTO iMax_Regs_camp, cIdPlantillaSMS   -- Campaña de credisoluciones
          FROM bdicobranza:cb_param_campania WHERE tipo_campania = 51 AND grupo_parametro = 'LATINIA' AND num_parametro = 17;
    ELSE
        SELECT valor_numerico, trim(valor_alfabetico) INTO iMax_Regs_camp, cIdPlantillaSMS   -- Campañas de promociones: 1,3,4 y 5
          FROM bdicobranza:cb_param_campania WHERE tipo_campania = 51 AND grupo_parametro = 'LATINIA' AND num_parametro = 16;
    END IF;

    -- Genera archivo .ready con la informacion de los mensajes sms a enviar, solo para campañas 1 a 5. Camp 6 no se genera.
    IF cSms_archivo = '1' AND psNumCamp < 6 THEN

        -- Caracter delimitador para el archivo
        SELECT trim(valor_alfabetico) INTO cdelimitadorsms FROM bdicobranza:cb_param_campania	
         WHERE empresa = pEmpresa AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 2;
        IF NVL(cdelimitadorsms,'') = '' THEN
            LET cCod_Ret= '104004';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||psNumCamp::CHAR||'-SMS', '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene los datos a ingresar al archivo.
        CREATE TABLE tmp_arch_telef_sms ( num SERIAL,       NoTel CHAR(10),     diferido  char(12), caducidad  CHAR(12),
                                          texto char(160),  etiqueta char(50),  plantilla char(10), NomCte     CHAR(10) );

        -- substr(tel.telefono,length(tel.telefono)-9,10) tel_recons, 
        INSERT INTO tmp_arch_telef_sms ( num, NoTel, plantilla, NomCte )
            SELECT 0, tel.telefono_orig, cIdPlantillaSMS,
                   CASE WHEN length(camp.primer_nombre) >= 3 THEN substr(trim(camp.primer_nombre),1,10) ELSE substr(trim(camp.segundo_nombre),1,10) END
              FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_telefonos_nvo_layout_cat tel ON (camp.num_credito = tel.num_credito AND camp.numcte = tel.numcte )
             WHERE camp.fecha_gen_campania = pdfecha_gen_camp AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = psNumCamp 
               AND camp.fecha_entreg_desde = pdfecha_desde AND camp.fecha_entreg_hasta = pdfecha_hasta 
               AND camp.grupo = 'A' AND tel.grupo_archivos = 'INA_NUN' AND tel.tipotelefono = '2'; --- Query para incluir telefono 2 en archivo

            /*SELECT 0, substr(tel.telefono,length(tel.telefono)-9,10), cIdPlantillaSMS, 
                CASE WHEN length(camp.primer_nombre) >= 3 then substr(trim(camp.primer_nombre),1,10) else substr(trim(camp.segundo_nombre),1,10) END
              FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_telefonos_actual tel ON ( camp.numcte = tel.numcte )
             WHERE camp.fecha_gen_campania = pdfecha_gen_camp AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = psNumCamp 
               AND camp.fecha_entreg_desde = pdfecha_desde AND camp.fecha_entreg_hasta = pdfecha_hasta
               AND camp.grupo = 'A' AND  tel.tipo_tel = '2';*/

        SELECT Count(*) INTO sTot_CtesSms FROM tmp_arch_telef_sms;
        LET cTotCtesSms = sTot_CtesSms;

        -- Genera archivo .ready de los clientes a enviar SMS
        LET cnomarchivo1 = trim(pTipo_camp)||'_Aux_'|| cMesFecha || substr(year(pdFechaHoy),1) ||'_'|| psNumCamp::CHAR || '.ready';  
        LET cnomarchivo  = trim(pTipo_camp)||'_'|| cMesFecha ||'_'|| substr(year(pdFechaHoy),1) ||'_' || psNumCamp::CHAR || '.ready';
        LET cnomarchivoejecsql = 'Ejec_camp_inact_nunca_sms.sql';

        LET cSQL='';
        LET cSQL = 'echo "BANCOPPEL'||cdelimitadorsms||'productos'||cdelimitadorsms||cdelimitadorsms||'sms3'||cdelimitadorsms||trim(cIdPlantillaSMS)||cdelimitadorsms
                         || trim(cTotCtesSms) || ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM cSQL;

        LET cSQL = '';
        LET cSQL = ' echo "<EOF>">'||TRIM(cruta)||'sms_fin_arch_camp.txt';
        SYSTEM cSQL;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitadorsms || ''''||'';

        LET cSQL2 = " SELECT num, NoTel, diferido,caducidad,texto,etiqueta,plantilla, " || "'nombre=' || trim(NomCte) FROM tmp_arch_telef_sms ";

        LET cSQL3 = ' " >'||TRIM(cruta)|| cnomarchivoejecsql;
        LET cSQL = '';
        LET cSQL = trim(cSQL1) || RTRIM(cSQL2) || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cruta)|| cnomarchivoejecsql;
        System cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = '';
        LET cSql = "sed 's/"||cdelimitadorsms||"$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
        SYSTEM cSql;

        LET cSql = '';
        LET cSql = "sed 's/|$//g' "||TRIM(cruta)||"sms_fin_arch_camp.txt >>"||TRIM(cruta)||TRIM(cnomarchivo);		
        SYSTEM cSql;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1 || ' ' || TRIM(cruta)|| 'sms_fin_arch_camp.txt';
        SYSTEM cSQL;

    END IF;

    -- Envio de mensajes sms de modo automático, a traves de latinia (tabla), solo para campañas 1 a 5.
    ---------------------------------------------------------------------------------------------------

    IF cSms_Envio = '1' AND psNumCamp < 6 THEN 

        --IF ( vtotal_enviados <  iMax_Regs_camp) THEN -- Mensajes enviados son menor al maximo permitido por campaña
        IF iMax_Regs_camp > 0 THEN
            LET iContador = 0;
            FOREACH WITH HOLD
                SELECT camp.num_credito, camp.numcte, camp.ap_paterno, camp.ap_materno, camp.primer_nombre, camp.segundo_nombre, camp.estado, 
                       camp.ciudad, tel.telefono_orig
                  INTO cNumCredito, cNumCte, cApellPat, cApellMat, cNombre1, cNombre2, cNomEstado, cNomCiudad, cTelCel
                  FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_telefonos_nvo_layout_cat tel 
                       ON ( camp.num_credito = tel.num_credito AND camp.numcte = tel.numcte )
                 WHERE camp.fecha_gen_campania = pdfecha_gen_camp AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = psNumCamp 
                   AND camp.fecha_entreg_desde = pdfecha_desde AND camp.fecha_entreg_hasta = pdfecha_hasta 
                   AND camp.grupo = 'A' AND tel.grupo_archivos = 'INA_NUN' AND tel.tipotelefono = '2'


                SELECT nvl(num_tarjeta,'0') INTO vnumTarjeta FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_credito = cNumCredito 
                   AND secuencia = (select max(secuencia) from bdicred:sd_tarjeta t where empresa = t.empresa and num_credito = t.num_credito 
                                      and t.tipo_tarjeta = 'T' and t.status_tar = 'A')
                   AND tipo_tarjeta = 'T' AND status_tar = 'A';

                IF trim(cTelCel) != '' THEN
                    LET iCel = LENGTH(cTelCel) + 1 - 10;
                    IF ( LENGTH(cTelCel) > 10 ) THEN 
                        LET cTelCel = SUBSTR(cTelCel,iCel,10);
                    ELIF ( LENGTH(cTelCel) < 10 ) THEN 
                        LET cTelCel ='';  
                        CONTINUE FOREACH;    
                    END IF;

                    LET cNombreCte = SUBSTR(cNombre1, 1, 10);

                    call bdimnsj:"informix".sp_registra_evento (2, cIdPlantillaSMS, cNumCte, cNumCredito, vnumTarjeta, 2, cNombreCte,
                                '','','','',0,0,0,0,0, '', '')RETURNING cCod_RetIB;

                    LET iContador = iContador + 1;
                END IF;    
                IF (iContador = iMax_Regs_camp) THEN EXIT FOREACH; END IF;
            END FOREACH;
        END IF;
    END IF;

    ---------------------------------------------------------------------------------------------------
    --         Genera el ARCHIVO DE CORREO DIRECTO directo de la campaña 2 (Credisoluciones)         --
    ---------------------------------------------------------------------------------------------------

    SELECT NVL(trim(valor_alfabetico),'0') INTO cArchCorr_Credisol FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
        AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 29;

    SELECT NVL(valor_numerico,0) INTO iMinCorre_cred FROM bdicred:"informix".sd_param_campania WHERE empresa = '001'  --  INTO cArchCorr_Credisol
        AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 30;

    IF psNumCamp = 2 AND cArchCorr_Credisol = '1' THEN

        LET cnomarchivo1 = trim(pTipo_camp) || '_CORREO_' ||'Aux_'|| cMesFecha || substr(year(pdFechaHoy),1) ||'_'|| psNumCamp::CHAR || '.txt';  
        LET cnomarchivo  = trim(pTipo_camp) || '_CORREO_' || cMesFecha ||'_'|| substr(year(pdFechaHoy),1) ||'_' || psNumCamp::CHAR || '.txt';
        LET cnomarchivoejecsql = 'Ejecuta_correo_inact_nunca.sql';

        LET cSQL='';
        LET cSQL = 'echo "num_credito'||';'||'num_cliente'||';'||'nombre'||';'||'sexo'||';'||'calle'||';'||'num_exterior'||';'
                    ||'num_interior'||';'||'colonia'||';'||'delegacion' ||';'|| 'ciudad' ||';'||'estado'||';'|| 'c.p.' ||';'
                    || ' " >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM cSQL;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
        LET cSQL2 = " SELECT camp.num_credito, camp.numcte, TRIM(camp.ap_paterno) ||' '|| TRIM(camp.ap_materno) ||' '|| TRIM(camp.primer_nombre) "
            || " ||' '|| TRIM(camp.segundo_nombre) nombre, camp.sexo, TRIM(calle.nombrecalle) AS calle, "
            || " TRIM(dir.numeroextcalle) AS numextcalle, TRIM(dir.numerointcalle) AS numintecalle, TRIM(zon.nombrezona) AS colonia, "
            || " TRIM(zon.municipiozona) AS municipio, TRIM(ciudad.nombreciudad) AS ciudad, "
            || " TRIM(edo.nombre) AS estado, lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal "
            || " FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_direcciones_actual dir ON ( camp.numcte = dir.numcte and dir.tipo_dir = '1' ) "
            || " LEFT JOIN bdinteg:si_estados edo ON ( dir.estado = edo.estado ) "
            || " LEFT JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle) "
            || " LEFT JOIN bdinteg:si_catzonas zon ON ( dir.numerociudad = zon.numerociudad and dir.numerocolonia = zon.numerocolonia ) "
            || " LEFT JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad) "
            || " WHERE camp.fecha_gen_campania = '"|| pdfecha_gen_camp || "'"
            || " AND camp.tipo_campania = '"|| pTipo_camp ||"'"
            || " AND camp.num_sub_campania = '"|| psNumCamp  ||"'"
            || " AND camp.fecha_entreg_desde = '"|| pdfecha_desde ||"'" 
            || " AND camp.fecha_entreg_hasta = '"|| pdfecha_hasta ||"'"
            || " AND camp.grupo = 'A' AND monto_otorgado >= " || iMinCorre_cred;

        LET cSQL3 = '">'||TRIM(cruta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cruta)|| cnomarchivoejecsql;
        System cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
        SYSTEM cSql;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
        SYSTEM cSQL;

    END IF;

    --CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'Finaliza sp_camp_tdc_inact_nunc_crea_arch ' || psNumCamp::CHAR, '02') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;