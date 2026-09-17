CREATE PROCEDURE "informix".sp_descarga_arch_vartdc(pfecha DATE)
       RETURNING CHAR(6) AS codigo, CHAR(200) AS mensaje;
 
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(200);
DEFINE	cCod_ret		CHAR(6);

DEFINE vnum_cuenta		CHAR(20);
DEFINE vapellido_p		CHAR(30);
DEFINE vapellido_m		CHAR(30);
DEFINE vp_nombre		CHAR(25);
DEFINE vs_nombre		CHAR(25);
DEFINE vfecha_nac		DATE;
DEFINE vrfc				CHAR(13);
DEFINE vdireccion		CHAR(160);
DEFINE vdireccion1		CHAR(80);
DEFINE vdireccion2		CHAR(80);
DEFINE vcolon_pobla		CHAR(65);
DEFINE vdeleg_munic		CHAR(65);
DEFINE vciudad			CHAR(65);
DEFINE vestado			CHAR(4);
DEFINE vcp				CHAR(5);
DEFINE vfecha_proc		DATE;

DEFINE vpaso			INTEGER;
DEFINE vnum_arch		CHAR(4);
DEFINE vfecha_arch		CHAR(6);
DEFINE vfec_com			CHAR(6);
DEFINE vnom_archivo		CHAR(100);
DEFINE cnomarchivo1		CHAR(100);
DEFINE vmonth			CHAR(2);
DEFINE vyear			CHAR(2);
DEFINE cruta			CHAR(100);

DEFINE cSql				CHAR(30000);
DEFINE cSql1			CHAR(200);
DEFINE cSql2			CHAR(30000);

LET sql_err				= 0;
LET isam_err			= 0;
LET error_info			= '';
LET cMensaje			= '';
LET cCod_ret			= '000000';
LET vnum_cuenta			= '';
LET vapellido_p			= '';
LET vapellido_m			= '';
LET vp_nombre			= '';
LET vs_nombre			= '';
LET vfecha_nac			= DATE(1);
LET vrfc				= '';
LET vdireccion			= '';
LET vdireccion1			= '';
LET vdireccion2			= '';
LET vcolon_pobla		= '';
LET vdeleg_munic		= '';
LET vciudad				= '';
LET vestado				= '';
LET vcp					= '';
LET vfecha_proc			= DATE(1);

LET vpaso				= 0;
LET vnum_arch			= '';
LET cnomarchivo1		= '';
LET vfecha_arch			= '';
LET vfec_com			= '';
LET vnom_archivo		= '';
LET vmonth				= '';
LET vyear				= '';
LET cruta				= '';

LET cSql				= '';
LET cSql1				= '';
LET cSql2				= '';

  --SET DEBUG FILE TO "sp_descarga_arch_vartdc.out";
  --TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = TRIM(error_info) || "     ERROR EN EL PASO: " || vpaso;
		IF vnum_cuenta <> "" THEN
			LET cMensaje = cMensaje || "   EN LA CUENTA: " || TRIM(vnum_cuenta);
		END IF;
		RETURN cCod_ret, TRIM(cMensaje);
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--OBTENER FECHA DEL ARCHIVO CON EL QUE SE TRABAJARA
	SELECT TRIM(valor) INTO vfecha_arch 
	FROM "informix".br_param 
	WHERE cod_param = 144; LET vpaso = 1;

	IF vfecha_arch IS NULL THEN LET vfecha_arch = ""; END IF;

	--OBTENER RUTA DEL ARCHIVO
	SELECT TRIM(valor) INTO cruta 
	FROM bdicobranza:"informix".cb_param 
	WHERE empresa = "001"
	AND cod_param = 87;	 LET vpaso = 2;
	
	LET vfecha_proc = MDY(MONTH(pfecha), 1, YEAR(pfecha)) - 1 UNITS DAY;

	LET vfec_com = LPAD(MONTH(pfecha),2,0) || YEAR(pfecha); 

	IF vfecha_arch <> vfec_com THEN

		BEGIN WORK;
			UPDATE "informix".br_param
			SET valor = "01"
			WHERE cod_param = 143;
		COMMIT WORK; LET vpaso = 3;

	END IF;
	
	--OBTENER NUMERO DEL ARCHIVO CON EL QUE SE TRABAJARA
	SELECT TRIM(valor) INTO vnum_arch 
	FROM "informix".br_param 
	WHERE cod_param = 143; LET vpaso = 4;
	
	IF vnum_arch = "" OR vnum_arch IS NULL THEN LET vnum_arch = "01"; END IF;

	LET vyear = SUBSTR(YEAR(pfecha),3,2);

	LET vmonth = LPAD(MONTH(pfecha),2,0);

	LET vnom_archivo = "VARTDC_000270_" || vyear || vmonth || "_" || TRIM(vnum_arch) || ".txt";

	IF NOT EXISTS (SELECT fecha_proceso FROM "informix".br_arch_vartdc_proc WHERE fecha_proceso = vfecha_proc GROUP BY fecha_proceso) THEN
		TRUNCATE TABLE "informix".br_arch_vartdc_proc DROP STORAGE; LET vpaso = 5;
	END IF;

	SELECT shr.num_credito, 
	TRIM(cte.apell_paterno) apellido_paterno,
	TRIM(cte.apell_materno) apellido_materno,
	TRIM(cte.nombre1) primer_nombre,
	TRIM(cte.nombre2) segundo_nombre,
	ctf.fecha_nac,
	cte.rfc,
	TRIM(cll.nombrecalle) || ' ' || TRIM(dir.numeroextcalle) || ' ' || TRIM(dir.numerointcalle) direccion,
	TRIM(czn.nombrezona) colonia,
	TRIM(czn.municipiozona) municipio,
	TRIM(czn.poblacionzona) ciudad,
	TRIM(UPPER(cir.descripcion)) estado,
	dir.cod_postal,
	shr.fecha_cierre
	FROM bdicred:"informix".sd_hist_reserva shr
		INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = shr.numcte)
		INNER JOIN bdinteg:"informix".si_ctepf ctf ON (ctf.numcte = shr.numcte)
		INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON (dir.numcte = shr.numcte AND dir.tipo_dir = '1')
		INNER JOIN bdinteg:"informix".si_catcalles cll ON (cll.numerocalle = dir.numerocalle)
		INNER JOIN bdisolic:"informix".ss_circulo_edos cir ON (cir.empresa = shr.empresa AND cir.clave = dir.estado)
		INNER JOIN bdinteg:"informix".si_catzonas czn ON (czn.numerociudad = dir.numerociudad and czn.numerocolonia = dir.numerocolonia)
	WHERE shr.empresa = "001"
	AND shr.num_credito NOT IN(SELECT var.numero_cuenta FROM "informix".br_arch_vartdc_proc var WHERE var.numero_cuenta = shr.num_credito AND var.fecha_proceso = vfecha_proc)
	AND shr.fecha_cierre = vfecha_proc
	INTO TEMP paso_reserva WITH NO LOG;	LET vpaso = 6;

	CREATE INDEX indx_paso_reserva ON paso_reserva(fecha_cierre);
	UPDATE statistics high FOR TABLE paso_reserva; LET vpaso = 7;

	FOREACH WITH HOLD
		SELECT num_credito, apellido_paterno, apellido_materno, primer_nombre, segundo_nombre,
			fecha_nac, rfc, REPLACE(direccion, "|", ""), REPLACE(colonia, "|", ""), REPLACE(municipio, "|", ""),
			REPLACE(ciudad, "|", ""), REPLACE(estado, "|", ""), cod_postal
		INTO vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre,
			vfecha_nac, vrfc, vdireccion, vcolon_pobla, vdeleg_munic,
			vciudad, vestado, vcp
		FROM "informix".paso_reserva
		WHERE fecha_cierre = vfecha_proc

		LET vpaso = 8;

		IF vapellido_m = '' OR vapellido_m IS NULL THEN
			LET vapellido_m = "NO PROPORCIONADO";
		END IF;

		IF LENGTH(TRIM(vdireccion)) > 80 THEN
			LET vdireccion1 = vdireccion;
			LET vdireccion2 = SUBSTR(vdireccion,81,80);
		ELSE
			LET vdireccion1 = TRIM(vdireccion);
		END IF; LET vpaso = 9;

		BEGIN WORK; 
			INSERT INTO "informix".br_arch_vartdc_proc (numero_cuenta, apellido_paterno, apellido_materno, primer_nombre,
			segundo_nombre, fecha_nacimiento, rfc, direccion1, direccion2,
			colonia_poblacion, delegacion_municipio, ciudad, estado, cp, fecha_proceso)
			VALUES (vnum_cuenta, vapellido_p, vapellido_m, vp_nombre,
			vs_nombre, vfecha_nac, vrfc, vdireccion1, vdireccion2,
			vcolon_pobla, vdeleg_munic, vciudad, vestado, vcp, vfecha_proc);
		COMMIT WORK; LET vpaso = 10;

		LET vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre = "", "", "", "", "";
		LET vfecha_nac, vrfc, vdireccion, vcolon_pobla, vdeleg_munic = DATE(1), "", "", "", "";
		LET vciudad, vestado, vcp, vdireccion1, vdireccion2 = "", "", "", "", "";

	END FOREACH;
	
	LET vpaso = 11;
	
    UPDATE statistics medium FOR TABLE "informix".br_arch_vartdc_proc;

	LET cnomarchivo1 = "Aux_" || vnom_archivo; LET vpaso = 12;

	--SE INSERTE LAYOUT SOLICITADO EN EL ARCHIVO querylayout.txt
	LET cSql = 'echo "numero_cuenta|apellido_paterno|apellido_materno|primer_nombre|segundo_nombre|fecha_nacimiento|rfc|direccion1|direccion2|colonia_poblacion|delegacion_municipio|ciudad|estado|cp|" >>' || TRIM(cruta) || "querylayout.txt";
	SYSTEM (cSql); LET vpaso = 13;

	--SE PASA LAYOUT AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "sed 's/$//g' "|| TRIM(cruta) || "querylayout.txt >> " || TRIM(cruta) || vnom_archivo;
    SYSTEM TRIM(cSql); LET vpaso = 14;

	--SE ARMA SCRIPT QUE CONTENDRA EL QUERY DE LA DESCARGA DE LA INFORMACION
	LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '">' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql1); LET vpaso = 15;

	LET cSql2 = 'echo "' || "SELECT numero_cuenta, apellido_paterno, apellido_materno, primer_nombre, segundo_nombre," || '">>' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 16;

	LET cSql2 = "";
	LET cSql2 = 'echo "' || "fecha_nacimiento, rfc, direccion1, direccion2, colonia_poblacion, delegacion_municipio," || '">>' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 17;

	LET cSql2 = "";
	LET cSql2 = 'echo "' || "ciudad, estado, cp" || '">>' || TRIM(cruta) || 'querycc.sql';
	SYSTEM TRIM(cSql2); LET vpaso = 18;

	LET cSql2 = "";
	LET cSql2 = 'echo "' || "FROM br_arch_vartdc_proc WHERE fecha_proceso = MDY(" ||MONTH(vfecha_proc)|| "," ||DAY(vfecha_proc)|| "," ||YEAR(vfecha_proc)|| ");" || '">>' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 19;

	--ASIGNACION DE PERMISO AL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql); LET vpaso = 20;

	--EJCUCION DEL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "dbaccess bdiburo " || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql); LET vpaso = 21;

	--SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "sed 's/$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || vnom_archivo;
    SYSTEM cSql; LET vpaso = 22;

	--ASIGNACION DE PERMISO AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql; LET vpaso = 23;

	--BORRADO DE ARCHIVOS TEMPORALES
	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || "querycc.sql";		
	SYSTEM TRIM(cSql); LET vpaso = 24;

	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || "querylayout.txt";
	SYSTEM TRIM(cSql); LET vpaso = 25;

	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || TRIM(cnomarchivo1);
	SYSTEM TRIM(cSql); LET vpaso = 26;

	--SE COMPACTA ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "gzip " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql; LET vpaso = 27;

	--ASIGNACION DE PERMISO AL ARCHIVO COMPACTADO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo)||".gz";
	SYSTEM cSql; LET vpaso = 28;

	LET vnum_arch = vnum_arch::INTEGER + 1;

	IF LENGTH(vnum_arch) < 2 THEN LET vnum_arch = LPAD(TRIM(vnum_arch),2,"0"); END IF;

	BEGIN WORK;
		UPDATE "informix".br_param
		SET valor = vnum_arch
		WHERE cod_param = 143;LET vpaso = 29;
	
	--ACTUALIZACION PARA EL VALOR DE LA FECHA DEL ARCHIVO
		UPDATE "informix".br_param
		SET valor = vfec_com
		WHERE cod_param = 144;
	COMMIT WORK; LET vpaso = 30;

    LET cMensaje = "PROCESO EXITOSO, REGISTROS PROCESADOS.";

    RETURN cCod_ret, TRIM(cMensaje);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DESCARGA DEL ARCHIVO VARTDC PARA CC.',
'AUTOR: Carlos Valenzuela',
'CREACION: 04/10/2016',
'BD: bdiburo';

CREATE PROCEDURE "informix".sp_burofisicas_cortos_nov19()
RETURNING CHAR(6),
          CHAR(100);


-- Autor: Roque Enrique Solis CampaÃ±a
-- Fecha de ModificaciÃ³n 19/08/2009
-- Observaciones: Se modifica el acceso a la tabla si_feriado de la base de datos bdinteg,
--                eliminaciÃ³n de variables innecesarias, omitir las comparaciones con los 
--                estatus y los filtros o validaciones que se hicieran con los mismos debido a 
--                que solo se espera crÃ©ditos con estatus "AA", contemplar la eliminaciÃ³n de las 
--                tablas temporales.
-- Fecha de ModificaciÃ³n 20/08/2009
-- Observaciones: Se modificaron el Ã­ndice de la tabla br_burofisicas_cortos.

DEFINE vcodret                       CHAR(6);
DEFINE vfecha_hoy                    DATE;
DEFINE vPriDiaMes                    DATE;
DEFINE vUltDiaMes					 DATE;
DEFINE vUltMesRep					 DATE;
DEFINE vcredito_maximo               DECIMAL(18,2);
DEFINE vcredito_maximo1              DECIMAL(18,2);
DEFINE vrea_cal_cuota                INTEGER;
DEFINE vmonto                        DECIMAL(18);
DEFINE vheader                       CHAR(150);
DEFINE vsegmento_pn                  CHAR(375);
DEFINE vsegmento1_pn                 CHAR(375);
DEFINE vsegmento2_pa                 CHAR(326);
DEFINE vsegmento4_tl                 CHAR(436);
DEFINE vsegmento5_tr                 CHAR(255);
DEFINE vapell_paterno                CHAR(26);
DEFINE vapell_materno                CHAR(26);
DEFINE vnombre1                      CHAR(26);
DEFINE vnombre2                      CHAR(26);
DEFINE vfecha_nac                    DATE;
DEFINE vanio                         CHAR(4);
DEFINE vmes                          CHAR(2);
DEFINE vdia                          CHAR(2);

DEFINE vanioup                       CHAR(4);
DEFINE vmesup                        CHAR(2);
DEFINE vdiaup                        CHAR(2);

DEFINE vrfc                          CHAR(13);
DEFINE vestado_civil                 CHAR(1);
DEFINE vsexo                         CHAR(1);
DEFINE vcalle,vcalle1                CHAR(40);
DEFINE vcolonia                      CHAR(40);
DEFINE vdelegacion                   CHAR(40);
DEFINE vestado                       CHAR(4);
DEFINE vcod_postal                   CHAR(10);
DEFINE vnum_credito                  CHAR(25);
DEFINE vnum_producto                 CHAR(4);
DEFINE vtp_linea                     CHAR(4);
DEFINE vnum_pagos                    CHAR(5);
DEFINE vfrecuencia                   CHAR(1);
DEFINE vfecha_apertura               DATE;
DEFINE vnumcte                       CHAR(20);
DEFINE vencabezado1                  CHAR(4);
DEFINE vversion                      CHAR(2);
DEFINE vclave_usu_bc                 CHAR(10);
DEFINE vnombre_usu                   CHAR(16);
DEFINE vciclo                        CHAR(2);
DEFINE vfecha_reporte                CHAR(8);
DEFINE vfechaup                CHAR(8);
DEFINE vuso_futuro                   CHAR(10);
DEFINE vinf_adicional                CHAR(98);
DEFINE vsql                          CHAR(2000);
DEFINE varchivo                      CHAR(60);
DEFINE varchivo_des                  CHAR(60);
--DEFINE i                             SMALLINT;
DEFINE vfecha_ini                    DATE;
DEFINE vpago_cap, vpago_int          DATE;
DEFINE vfrecpago                     CHAR(1);
DEFINE vcuota_cap                    INTEGER;
DEFINE vcuotas_ven                   SMALLINT;
DEFINE vmonto_otorgado, vsaldo_vig, vsaldo_venc, vsaldo_actual,v_interes        DECIMAL(18,2);
DEFINE vfechacuota                   DATE;
DEFINE vdiasvenc                     SMALLINT;
DEFINE vmop                          CHAR(2);
DEFINE vnumreg                       INTEGER;
DEFINE existe                        SMALLINT;
DEFINE vciudad                       CHAR(40);
DEFINE vruta_interfase               CHAR(200);
DEFINE vsecuencia                    SMALLINT;
DEFINE vmanzana                      SMALLINT;
DEFINE vandador                      SMALLINT;
DEFINE vlote                         SMALLINT;
DEFINE vedificio                     SMALLINT;
DEFINE ventrada                      SMALLINT;
DEFINE vdiacuota                     SMALLINT;
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE dtFecha_ultimo_reporte        DATE;
DEFINE vmontoinsoluto                DECIMAL(18,2);      
DEFINE vfecha_vencido                DATE;
DEFINE vmontolutpago                 DECIMAL(18,2);      
DEFINE vdiasatraso                   INTEGER;
DEFINE vfechaultpago                 DATE;
DEFINE vfechaultcompra               DATE;

DEFINE iPeriodo                      INTEGER;
DEFINE dtFechaProxReporte            DATE;
DEFINE sProceso                      SMALLINT;
DEFINE cStatusProc                   CHAR(1);
DEFINE cMensajeFin                   CHAR(100);
DEFINE iTotalProcesados              INTEGER;
DEFINE vStatusCred                   CHAR(02);
DEFINE vstatus_credAnt               CHAR(02);
DEFINE vfecha_fin_mes_ant            date;
define vsaldo_vencAnt                decimal(18,2);

-- Agrega variables para tabla de datos en texto
-- Segmento PN
DEFINE tb_apell_paterno          CHAR(26);
DEFINE tb_apell_materno          CHAR(26);
DEFINE tb_nombre1                CHAR(26);
DEFINE tb_nombre2                CHAR(26);
DEFINE tb_fecha_nac              CHAR(08);
DEFINE tb_rfc                    CHAR(13);
DEFINE tb_nacionalidad           CHAR(03);
DEFINE tb_estado_civil           CHAR(1);
DEFINE tb_sexo                   CHAR(1);

-- Segmento PA
DEFINE tb_calle                  CHAR(40);
DEFINE tb_colonia                CHAR(40);
DEFINE tb_delegacion             CHAR(40);
DEFINE tb_ciudad                 CHAR(40);
DEFINE tb_estado                 CHAR(4);
DEFINE tb_cod_postal             CHAR(10);
DEFINE tb_codigo_pais   		 CHAR(2);  --RQM 09 467_Version 14  

-- Segmento TL
DEFINE tb_clave_usu              CHAR(10);
DEFINE tb_nombre_usu             CHAR(16);
DEFINE tb_num_credito            CHAR(25);
DEFINE tb_responsabilidad        CHAR(01);
DEFINE tb_tipo_cuenta            CHAR(01);
DEFINE tb_tipo_producto          CHAR(02);
DEFINE tb_clave_monetaria        CHAR(02);
DEFINE tb_num_pagos              CHAR(05);
DEFINE tb_frecpago               CHAR(01);
DEFINE tb_monto_pagar            DECIMAL(18);
DEFINE tb_fecha_apertura         CHAR(08);
DEFINE tb_fecha_ult_pago         CHAR(08);
DEFINE tb_fecha_ult_compra       CHAR(08);
DEFINE tb_fecha_cierre           CHAR(08);
DEFINE tb_fecha_reporte          CHAR(08);
DEFINE tb_credito_maximo         DECIMAL(18,2); 
DEFINE tb_saldo_actual           DECIMAL(18,2);
DEFINE tb_monto_otorgado         DECIMAL(18,2);
DEFINE tb_saldo_venc             DECIMAL(18,2);
DEFINE tb_cuotas_ven             SMALLINT;
DEFINE tb_mop                    CHAR(02);
DEFINE tb_clave_obs              CHAR(02);
DEFINE tb_plazo_meses       	 CHAR(5); --RQM 09 467_Version 14 
-- Segmento TRLR
DEFINE tb_total_sdo_actual       DECIMAL(14,2);
DEFINE tb_total_sdo_vencido      DECIMAL(14,2);
DEFINE tb_total_seg_intf         DECIMAL(03);
DEFINE tb_total_seg_pn           DECIMAL(09);
DEFINE tb_total_seg_pa           DECIMAL(09);
DEFINE tb_total_seg_pe           DECIMAL(09);
DEFINE tb_total_seg_tl           DECIMAL(09);
DEFINE tb_total_bloques          DECIMAL(06);
DEFINE tb_nombre_otorg           CHAR(09);
DEFINE tb_domicilio_dev          CHAR(65);
DEFINE tb_fecha_vencimiento      CHAR(08);
DEFINE tb_monto_insoluto         DECIMAL(18,2);
DEFINE tb_ultimo_pago            DECIMAL(18,2);

DEFINE vlMnpioReportar  char(40);  --GEV
DEFINE vlCodigoReportar   char(10);
DEFINE vlCodigoPOstalZona char(5);
-- Venta de cartera ini
DEFINE isqlErr                   INTEGER;
DEFINE iBanderaIndex             INTEGER;
DEFINE vperio_ejecucion          CHAR(02);
DEFINE iCP                       INTEGER;
DEFINE dFechaConsulta            DATE;
DEFINE vfecha_hoy_aux            DATE;

--IPCB CAMPOS NUEVOS RQM 09 467_Version 14 
DEFINE scalle_conocido 		SMALLINT;
DEFINE cpais     			CHAR(3);
DEFINE ccodigo_pais  		CHAR(2);
DEFINE cplazo_meses  		CHAR(4);
DEFINE dplazo_meses  		DECIMAL(5,2);
DEFINE vclave_ciudad   		CHAR(3);
DEFINE vclave_edo      		CHAR(2);

DEFINE tb_monto_originacion  DECIMAL(18,2);
DEFINE d_monto_originacion   DECIMAL(18,2);
DEFINE dmonto_autorizado     DECIMAL(18,2);

DEFINE vsegmento3_pe   		 CHAR(500);
DEFINE vmonto_int			 DECIMAL(18,2);

-- Segmento PE
DEFINE cnombre_empleador   	CHAR(99);
DEFINE tb_nombre_empleador 	CHAR(99);
DEFINE vprofesion          	CHAR(3);
DEFINE tb_origen_razon_soc 	CHAR(2);


DEFINE tb_fingcartvenc	  	CHAR(8);
DEFINE v_fecha_vencto 	  	DATE;
DEFINE vf_ingcartvenc 	  	CHAR(8);
DEFINE tb_diasatraso       	SMALLINT;
DEFINE vnum_tarjeta         CHAR(25);
DEFINE vnum_tarjeta_ant     CHAR(25);
DEFINE dFecha_reporte_tarj  DATE;
DEFINE cStatus_tar          CHAR(1);
DEFINE vCodstatus_tarjetanvo CHAR(3);
DEFINE tb_num_credito_ext   CHAR(25);
DEFINE cCredExterno         CHAR(20);
DEFINE tb_num_tarjeta       CHAR(25);
DEFINE vcodret2             char(5);
DEFINE cProceso             CHAR(4);
DEFINE iIsamErr             INTEGER;
DEFINE iCuenta_regs         INTEGER;  
DEFINE iCuenta_regs_2       INTEGER;  
DEFINE vdescripcion_feriado char(30);
--IPCB CAMPOS NUEVOS RQM 09 467_Version 14    

LET dtFecha_ultimo_reporte  = DATE(1);
LET iPeriodo                = 0;
LET dtFechaProxReporte      = DATE(1);
LET sProceso                = 0;
LET cStatusProc             = "";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET iBanderaIndex           = 0;
LET iCP                     = 0;
LET cMensajeFin             = '';
LET iTotalProcesados        = 0;
LET vperio_ejecucion        = '7';
LET vmontoinsoluto          = 0;
LET vfecha_vencido          = DATE(1);
LET vmontolutpago           = 0;      
LET vdiasatraso             = 0;
LET vfechaultpago           = DATE(1);
LET vfechaultcompra         = DATE(1);
LET vStatusCred             = '';
LET vstatus_credAnt         = '';
LET vfecha_fin_mes_ant      = DATE(1);
LET vsaldo_vencAnt          = 0;

LET vsegmento5_tr           = '';
LET tb_total_sdo_actual     = 0;
LET tb_total_sdo_vencido    = 0;
LET tb_total_seg_intf       = 0;
LET tb_total_seg_pn         = 0;
LET tb_total_seg_pa         = 0;
LET tb_total_seg_pe         = 0;
LET tb_total_seg_tl         = 0;
LET tb_total_bloques        = 0;
LET tb_nombre_otorg         = '';
LET tb_domicilio_dev        = '';
LET tb_fecha_vencimiento    = '';
LET tb_monto_insoluto       = 0;
LET tb_ultimo_pago          = 0;

LET vnum_credito = '';

LET vanioup      = '';
LET vmesup       = '';
LET vdiaup       = '';
LET vfechaup = '';
LET vfecha_hoy_aux = date(1);

   LET scalle_conocido = 0;
   LET cpais    = '';
   LET ccodigo_pais = '';
LET tb_codigo_pais = '';
LET cnombre_empleador = '';
LET tb_nombre_empleador = '';
LET cplazo_meses = '';
LET tb_monto_originacion = 0;
LET d_monto_originacion = 0;
LET tb_plazo_meses = '';
LET vprofesion = '';
LET dplazo_meses = 0;
LET dmonto_autorizado = 0;
LET tb_origen_razon_soc = '';

LET vclave_edo 		= '';
LET scalle_conocido = 0;
LET cpais    		= '';
LET vclave_ciudad	= '';
LET vnum_tarjeta    = '';
LET vnum_tarjeta_ant = '';
LET dFecha_reporte_tarj = date(1);
LET cStatus_tar         = '';
LET vCodstatus_tarjetanvo = '';
LET tb_num_credito_ext   = '';
LET tb_num_tarjeta = '';
LET vcodret2 = '';
LET cProceso = '0058';
LET iIsamErr = 0;
LET iCuenta_regs = 0;
LET iCuenta_regs_2 = 0;
LET vdescripcion_feriado = '';

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET vcodret = iSqlErr;

      LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES cancelado' || ' ' || vnum_credito;

      UPDATE bdicred:sd_control_procesos
         SET status_proceso = 'C',
             mensaje        = vcodret || ' ' || cMensajeFin
       WHERE empresa='001' 
         AND cod_proceso = 'cintaparcialbc';

	  let cMensajeFin = trim(vcodret) || '- ' || iIsamErr || '-' || trim(vnum_credito);
	  CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '02') RETURNING vcodret2; 	 
		 
      RETURN vcodret,cMensajeFin;

      ROLLBACK WORK;

   END IF;
END EXCEPTION;

LET vcodret = "000000";
LET vsql = "";

SET DEBUG FILE TO "/tmp/sp_burofisicas_cortos.out";
TRACE ON; 

   CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '01') RETURNING vcodret2; 

   SELECT UPPER(valor) 
     INTO vencabezado1
     FROM br_param
    WHERE cod_param = 3;

   SELECT UPPER(valor) 
     INTO vversion
     FROM br_param
    WHERE cod_param = 4;

   SELECT UPPER(valor) 
     INTO vnombre_usu
     FROM br_param
    WHERE cod_param = 6;

   SELECT UPPER(valor) 
     INTO vciclo
     FROM br_param
    WHERE cod_param = 7;

    SELECT UPPER(valor) 
      INTO vuso_futuro
      FROM br_param
     WHERE cod_param = 8;

    SELECT UPPER(valor) 
      INTO vclave_usu_bc
      FROM br_param
     WHERE cod_param = 127;

     LET vinf_adicional = "&";

	 SELECT fecha_hoy,pri_dia_mes,ult_dia_mes
       INTO vfecha_hoy,vPriDiaMes,vUltDiaMes
       FROM bdicred:sd_fechas
      WHERE empresa='001';

--temporal para pruebas	  
--  let vfecha_hoy = mdy('01','15','2019');
--  let vPriDiaMes = mdy('01','01','2019');
--temporal para pruebas
   
   
   
   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

-- Verifica que el control de procesos no reporte el proceso activo para poder ejecutarlo
   SELECT status_proceso, fecha_proceso, fecha_prox_proceso --gev
     INTO cStatusProc, dtFecha_ultimo_reporte, dtFechaProxReporte --gev
     FROM bdicred:sd_control_procesos
    WHERE empresa='001' 
      AND cod_proceso = 'cintaparcialbc';

 IF dtFecha_ultimo_reporte IS NULL THEN
     LET dtFecha_ultimo_reporte = vfecha_hoy - 1 UNITS DAY;
  END IF;
  
--IPCB Trae ultimo del mes de reporte
  IF month(dtFecha_ultimo_reporte) <> month(vfecha_hoy) THEN
	LET vUltMesRep = monthadd(vUltDiaMes -1);
  ELSE
	LET vUltMesRep = vUltDiaMes;
  END IF;
 
  IF dtFechaProxReporte IS NULL THEN
    LET dtFechaProxReporte = vfecha_hoy;  
  END IF;
  
  
  IF cStatusProc IS NULL THEN
    INSERT INTO bdicred:sd_control_procesos (empresa,cod_proceso,fecha_proceso,status_proceso,fecha_prox_proceso)
    VALUES ('001','cintaparcialbc',vfecha_hoy-3 units day,'',vfecha_hoy);
  END IF;
	  
  IF cStatusProc = 'I' THEN
     LET vcodret = '000001';
     LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES en ejecucion';
     RETURN vcodret,cMensajeFin;
  END IF;

-- Valida que el dÃ­a actual corresponda al dÃ­a de ejecuciÃ³n que indica el control de procesos   IF (vfecha_hoy <= NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc = 'F') THEN
  IF (vfecha_hoy <= NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc = 'F') THEN
      LET vcodret = '000002';
      LET cMensajeFin = 'El proceso ENVIO PAGOS PARCIALES ya fue ejecutado';
      RETURN vcodret,cMensajeFin;
   END IF;        

   IF vfecha_hoy > NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc in ('C','I') THEN
-- Reinicio donde se quedo
       UPDATE bdicred:sd_control_procesos
          SET status_proceso = 'I',
              mensaje = 'PROCESANDO'
        WHERE cod_proceso = 'cintaparcialbc';

   ELSE
       UPDATE bdicred:sd_control_procesos
          SET --fecha_proceso = vfecha_hoy,
              status_proceso = 'I',
              mensaje = 'PROCESANDO'
        WHERE cod_proceso = 'cintaparcialbc';    
   END IF;        
/*
   IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N') THEN
      LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
   END IF;
*/
-- Hace las adaptaciones a la tabla de SEPOMEX
    select {+FULL(bdinteg:si_catsepomex)} *,
    CASE when  d_estado= 'AGUASCALIENTES'then 'AGS'
         when  d_estado= 'BAJA CALIFORNIA'then 'BCN'
         when  d_estado= 'BAJA CALIFORNIA SUR'then 'BCS'
         when  d_estado= 'CAMPECHE'then 'CAM'
         when  d_estado= 'CHIAPAS'then 'CHS'
         when  d_estado= 'CHIHUAHUA'then 'CHI'
         when  d_estado= 'COAHUILA DE ZARAGOZA'then 'COA'
         when  d_estado= 'COLIMA'then 'COL'
         when  d_estado= 'CIUDAD DE MEXICO'then 'CDMX'
         when  d_estado= 'DURANGO'then 'DGO'
         when  d_estado= 'GUERRERO'then 'GRO'
         when  d_estado= 'GUANAJUATO'then 'GTO'
         when  d_estado= 'HIDALGO'then 'HGO'
         when  d_estado= 'JALISCO'then 'JAL'
         when  d_estado= 'MICHOACAN DE OCAMPO'then 'MICH'
         when  d_estado= 'MORELOS'then 'MOR'
         when  d_estado= 'NAYARIT'then 'NAY'
         when  d_estado= 'NUEVO LEON'then 'NL'
         when  d_estado= 'OAXACA'then 'OAX'
         when  d_estado= 'PUEBLA'then 'PUE'
         when  d_estado= 'QUERETARO'then 'QRO'
         when  d_estado= 'QUINTANA ROO'then 'QR'
         when  d_estado= 'SAN LUIS POTOSI'then 'SLP'
         when  d_estado= 'SINALOA'then 'SIN'
         when  d_estado= 'SONORA'then 'SON'
         when  d_estado= 'TABASCO'then 'TAB'
         when  d_estado= 'TAMAULIPAS'then 'TAM'
         when  d_estado= 'TLAXCALA'then 'TLA'
         when  d_estado= 'VERACRUZ DE IGNACIO DE LA LLAVE'then 'VER'
         when  d_estado= 'YUCATAN'then 'YUC'
         when  d_estado= 'ZACATECAS'then 'ZAC'
         when  d_estado= 'MEXICO'then 'EM '
		 
    ELSE '' END estado_abrev FROM bdinteg:si_catsepomex into temp sepomex with no log;
 ---CreaciÃ³n de indices por cada una de las validacines de SEPOMEX
    CREATE INDEX idx_sepomex  ON sepomex(d_codigo,d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex1 ON sepomex(d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex2 ON sepomex(d_asenta,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex3 ON sepomex(d_codigo,estado_abrev) in dbs_movhis_idx5 online;

    UPDATE STATISTICS MEDIUM FOR TABLE sepomex;


    LET vfecha_ini = MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy));
    LET vanio      = YEAR(vfecha_hoy);
    LET vmes       = LPAD(MONTH(vfecha_hoy),2,"0");
    LET vdia       = LPAD(DAY(vfecha_hoy),2,"0");
    LET vfecha_reporte = vdia||vmes||vanio;

    SELECT {+INDEX(bdicred:sd_maecredanexo idx_maecredanexo2)} a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,d.dia_cuota,fecha_ult_pago,a.status_cred,a.plazo   --RQM 09 467_Version 14 incluye a.plazo
--      INTO vnum_credito,vnum_producto,vnumcte,vfecha_apertura,vtp_linea,vfrecuencia,vdiacuota,vcuota_cap,vpago_cap
      FROM bdicred:sd_maecred a,
           bdicred:sd_maecredanexo b,
           bdicred:sd_maesdoshist c,
    bdicred:sd_definicion d
     WHERE a.empresa = '001'
		--AND a.sucursal in ('0547','0249','0192')--para pruebas
       AND a.num_credito >= '600000000000'
       AND status_cred NOT IN ('CV','FC')
       AND a.empresa = b.empresa
       AND a.num_credito = b.num_credito
       AND a.empresa = c.empresa
       AND a.num_credito = c.num_credito
       AND b.fecha_ult_pago >= dtFecha_ultimo_reporte
       AND b.fecha_ult_pago < vfecha_hoy
         AND a.empresa = d.empresa
         AND a.num_producto = d.num_producto
     AND c.fecha = CASE WHEN DAY(b.fecha_ult_pago) >= b.dia_corte  and (b.dia_corte > day(vUltMesRep)) THEN
							 vUltMesRep
                        WHEN DAY(b.fecha_ult_pago) >= b.dia_corte  and  (b.dia_corte <= day(vUltMesRep)) THEN 
							 MDY(MONTH(b.fecha_ult_pago),b.dia_corte,YEAR(b.fecha_ult_pago))
                        WHEN DAY(b.fecha_ult_pago) < b.dia_corte  and  (b.dia_corte > day(bdicred:monthadd(vUltMesRep,-1)))THEN
							 bdicred:monthadd(vUltMesRep,-1)
						ELSE
							MDY(MONTH(bdicred:monthadd(vUltMesRep,-1)),b.dia_corte,YEAR(bdicred:monthadd(vUltMesRep,-1)))                        
                     END
     AND a.fecha_apertura < mdy(month(vfecha_hoy),'01',year(vfecha_hoy))
--and a.num_credito in (select num_credito from bdicred:sd_maecred_temp)
UNION ALL
--    SELECT a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,b.dia_corte,c.monto_financiado,fecha_ult_pago
    SELECT a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,b.dia_corte dia_cuota,fecha_ult_pago,a.status_cred,a.plazo   --RQM 09 467_Version 14 incluye a.plazo
      FROM bdicred:sd_maecredcrd a,
           bdicred:sd_maecredanexocrd b,
--           bdicred:sd_maesdoshistcrd c,
           bdicred:sd_maesdoscrd c,
           bdicred:sd_definicion d
     WHERE a.empresa = '001'
	   --AND a.sucursal in ('0547','0249','0192')--para pruebas
       AND a.num_credito >= '610000000000'
       AND a.num_producto = '6011'
       AND a.status_cred <> 'FF'
       AND a.empresa = b.empresa
       AND a.num_credito = b.num_credito
       AND a.empresa = c.empresa
       AND a.num_credito = c.num_credito
       AND b.fecha_ult_pago >= dtFecha_ultimo_reporte
       AND b.fecha_ult_pago < vfecha_hoy
       AND a.empresa = d.empresa
       AND a.num_producto = d.num_producto
/*       AND c.fecha = CASE WHEN DAY(b.fecha_ult_pago) >= day(b.dia_corte) THEN 
                          MDY(MONTH(b.fecha_ult_pago),day(b.dia_corte),YEAR(b.fecha_ult_pago))                                
                     ELSE
                          MDY(MONTH(b.fecha_ult_pago - 1 UNITS MONTH),day(b.dia_corte),YEAR(b.fecha_ult_pago - 1 UNITS MONTH)) 
                     END
     AND a.fecha_apertura < c.fecha*/
     AND a.fecha_apertura < vfecha_hoy
--and a.num_credito in (select num_credito from bdicred:sd_maecredcrd_temp)
    INTO temp creditos WITH NO LOG;

    
	
	--IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_cortos WHERE numreg = 1) THEN
	SELECT COUNT(*) INTO iCuenta_regs
	FROM bdiburo:br_burofisicas_cortos WHERE numreg = 1;
	
	IF iCuenta_regs > 0 THEN
        TRUNCATE TABLE "informix".br_burofisicas_describe_cortos;
        TRUNCATE TABLE "informix".br_burofisicas_cortos;
    END IF;

    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas_cortos where numreg > 0;

    IF vnumreg IS NULL OR vnumreg = 0 THEN LET vnumreg = 1; END IF;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

FOREACH WITH HOLD
    SELECT num_credito,num_producto,numcte,fecha_apertura,maneja_linea,period_pag_int,dia_cuota,fecha_ult_pago,status_cred,plazo  --RQM 09 467_Version 14 incluye plazo cplazo_meses
      INTO vnum_credito,vnum_producto,vnumcte,vfecha_apertura,vtp_linea,vfrecuencia,vdiacuota,vpago_cap,vStatusCred, cplazo_meses
      FROM creditos 
	  WHERE num_credito not in ('700000000021','700000000013','700000000039') --Exclusion RQI 21 052 

      LET vanioup = YEAR(vpago_cap);
      LET vmesup = LPAD(MONTH(vpago_cap),2,"0");
      LET vdiaup = LPAD(DAY(vpago_cap),2,"0");
      LET vfechaup = vdiaup||vmesup||vanioup;
 
      --IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_describe_cortos WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup) THEN 
      --   CONTINUE FOREACH; 
      --END IF;
	  
	  SELECT count(*) into iCuenta_regs_2
	  FROM bdiburo:br_burofisicas_describe_cortos WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup;
	  
	  IF iCuenta_regs_2 > 0 THEN
	     CONTINUE FOREACH; 
	  END IF;
	  	  
      SELECT 
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,TRIM(rfc),
             nvl(estado_civil," "),nvl(sexo,"I")
        INTO vapell_paterno,vapell_materno,vnombre1,
             vnombre2,vfecha_nac,vrfc,
             vestado_civil,vsexo
        FROM bdinteg:si_cliente a, bdinteg:si_ctepf b
       WHERE a.numcte = vnumcte
         AND a.numcte = b.numcte; 



    IF vfecha_nac IS NULL THEN 
       LET vrfc = ""; 
    END IF;

-- Venta de cartera ini
-- Solo se reporta el mes de la venta

   LET vsegmento_pn = "";   LET vsegmento2_pa = "";  LET vsegmento3_pe=""; LET vsegmento4_tl = "";  --RQM 09 467_Version 14 se limpia variable vsegmento3_pe

-- Inicializa variables
-- Segmento PN
   LET tb_apell_paterno = "";   LET tb_apell_materno = "";   LET tb_nombre1       = "";   LET tb_nombre2       = "";
   LET tb_fecha_nac     = "";   LET tb_rfc           = "";   LET tb_nacionalidad  = "";   LET tb_estado_civil  = "";
   LET tb_sexo          = "";

-- Segmento PA
   LET tb_calle         = "";   LET tb_colonia       = "";   LET tb_delegacion    = "";   LET tb_ciudad        = "";
   LET tb_estado        = "";   LET tb_cod_postal    = "";   LET vcredito_maximo  = 0.0;

-- Segmento TL
   LET tb_clave_usu         = "";   LET tb_nombre_usu        = "";   LET tb_num_credito       = "";   LET tb_responsabilidad   = "";
   LET tb_tipo_cuenta       = "";   LET tb_tipo_producto     = "";   LET tb_clave_monetaria   = "";   LET tb_num_pagos         = "";
   LET tb_frecpago          = "";   LET tb_monto_pagar       = 0.0;   LET tb_fecha_apertura    = "";   LET tb_fecha_ult_pago    = "";
   LET tb_fecha_ult_compra  = "";   LET tb_fecha_cierre      = "";   LET tb_fecha_reporte     = "";   LET tb_credito_maximo    = 0.0;
   LET tb_saldo_actual      = 0.0;   LET tb_monto_otorgado    = 0.0;   LET tb_saldo_venc        = 0.0;   LET tb_cuotas_ven        = 0;
   LET tb_mop               = "";   LET tb_clave_obs         = "";   LET vrea_cal_cuota       = 0;
   LET vlMnpioReportar = '';   		LET vlCodigoReportar ='';     LET vlCodigoPOstalZona =''; --GEV

-- Segmento PE --RQM 09 467_Version 14
   LET tb_nombre_empleador 	= "";	LET tb_origen_razon_soc 	= "";	LET tb_fingcartvenc 		= "";	LET tb_diasatraso 			= 0;	   
      
-- INICIA ARMADO SEGMENTO PN (Nombre)

   LET vanio = YEAR(vfecha_nac);
   LET vmes = LPAD(MONTH(vfecha_nac),2,"0");
   LET vdia = LPAD(DAY(vfecha_nac),2,"0");

-- Agrega Apellido Paterno
    LET vsegmento1_pn    = LPAD(LENGTH(TRIM(vapell_paterno)),2,"0")||TRIM(vapell_paterno);
    LET tb_apell_paterno = TRIM(vapell_paterno);

-- Agrega Apellido Materno
   IF vapell_materno IS NOT NULL THEN
      LET vsegmento1_pn    = TRIM(vsegmento1_pn)||'00'||LPAD(LENGTH(TRIM(vapell_materno)),2,"0")||TRIM(vapell_materno);
      LET tb_apell_materno = TRIM(vapell_materno);
   ELSE
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0016NO PROPORCIONADO';
   END IF;

-- Agrega Primero Nombre
   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'02'||LPAD(LENGTH(TRIM(vnombre1)),2,"0")||vnombre1;
   LET tb_nombre1    = vnombre1;

-- Agrega Segundo Nombre
   IF vnombre2 IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'03'||LPAD(LENGTH(TRIM(vnombre2)),2,"0")||vnombre2;
      LET tb_nombre2    = vnombre2;
   END IF;

-- Agrega Fecha de Nacimiento
   IF vfecha_nac IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0408'||vdia||vmes||vanio;
      LET tb_fecha_nac = vdia||vmes||vanio;
   END IF;

-- Agrega RFC
   LET existe = LENGTH(vrfc);
   IF vrfc IS NULL OR existe < 10 THEN
      IF vrfc[2,2] = "A" OR vrfc[2,2] = "E" OR vrfc[2,2] = "I" OR vrfc[2,2] = "O" OR vrfc[2,2] = "U" THEN
         LET vrfc = vapell_paterno[1,2]||vapell_materno[1,1]||vnombre1[1,1]||vanio[3,4]||vmes||vdia;
      ELSE
         LET vrfc = vapell_paterno[1,1]||vapell_paterno[3,3]||vapell_materno[1,1]||vnombre1[1,1]||vanio[3,4]||vmes||vdia;
      END IF
   END IF

   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'05'||LPAD(LENGTH(TRIM(vrfc)),2,"0")||vrfc;
   LET tb_rfc = vrfc;

-- Agrega Nacionalidad
   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0802MX';
   LET tb_nacionalidad  = "MX";

-- Agrega Estado Civil
   IF vestado_civil IS NOT NULL THEN
      IF vestado_civil = 'C' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101M';
      END IF;
      IF vestado_civil = 'S' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101S';
      END IF;
      IF vestado_civil = 'U' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101F';
      END IF;
      IF vestado_civil = 'D' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101D';
      END IF;
      IF vestado_civil = 'V' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101W';
      END IF;
      LET tb_estado_civil  = vestado_civil;
   END IF;

-- Agrega Sexo
   IF vsexo IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1201'||vsexo;
      LET tb_sexo  = vsexo;
   END IF;
   LET vsegmento_pn = 'PN'||TRIM(vsegmento1_pn);
-- TERMINA ARMADO SEGMENTO PN (Nombre)

-- INICIA ARMADO SEGMENTO PA (DirecciÃ³n)
/*
   SELECT {+INDEX(bdinteg:si_direcciones inx_direcciones)} MAX(secuencia) 
     INTO vsecuencia
     FROM bdinteg:si_direcciones
    WHERE numcte = vnumcte 
      AND tipo_dir = '1';
*/
		SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||Trim(a.numerointcalle),
			nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(c.estado),
			lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,
			nvl(substr( CodigoPOstalZona,1,5),''),--GEV
			case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
			a.pais, a.ciudad, a.estado
		INTO vcalle,vcolonia,vdelegacion,vestado,vcod_postal,
			vmanzana,vandador,vlote,vedificio,ventrada,
			vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad, vclave_edo
		FROM bdinteg:si_direcciones_actual a 
        left outer join bdisolic:ss_circulo_edos c on a.estado = c.clave
        left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
        left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
        WHERE a.numcte= vnumcte
          AND a.tipo_dir="1"
          AND c.empresa = "001";
	  
	  ---Inicia Bloque de Validaciones Sepomex  --GEV
	  ---Validacion por Codigo POstal del Cliente, Delegacion, Estado
      SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE d_codigo = vcod_postal AND substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
      ---Validacion por Delegacion, Estado  
      IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
         group by d_mnpio, d_codigo ;    
		 
      end if;
	  ---Validacion por Colonia, Estado  		
      IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  trim(substr(d_asenta,1,32)) = vcolonia AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
		  
      end if;
	  ---Validacion por Codigo POstal de Zona, Estado  		
      IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  d_codigo = lpad(vlCodigoPOstalZona,5,"0") AND estado_abrev = vestado
         group by d_mnpio, d_codigo ;   
		 
      end if;
	  IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  d_codigo = vcod_postal AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
		  
      end if;
	  ---Validacion por Codigo POstal de Zona, Estado  		
      IF nvl(iCP,0) > 0 THEN
          let vdelegacion =vlMnpioReportar;
          let vcod_postal =vlCodigoReportar;
	  END IF;  
       ---Fin de Bloque de Validaciones Sepomex ---GEV
--validar para la tabla c la clave del estado ya que usa el campo clave

     LET vcalle1 = "";
     IF vmanzana > 0 THEN
        LET vcalle1 ="mza. "|| vmanzana;
     END IF
     IF vandador > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"and. "||     vmanzana ;
     END IF
     IF vlote > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"lt. "  ||   vlote ;
     END IF
     IF vedificio > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"ed. "||     vedificio ;
     END IF
     IF ventrada > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"ent. "||     ventrada ;
     END IF
     LET vcalle = TRIM(vcalle)||' '||TRIM(vcalle1);
	 
	 IF scalle_conocido = 1 THEN
		   LET vcalle = 'DOMICILIO CONOCIDO SN';
	 END IF;

  LET vciudad = "";

  IF vcod_postal IS NULL THEN     LET vcod_postal = "00000";  END IF;

-- Agrega Direccion
  LET vsegmento2_pa = LPAD(LENGTH(TRIM(vcalle)),2,"0")||vcalle;
  LET tb_calle      = vcalle;


-- Agrega Colonia
  IF vcolonia IS NOT NULL THEN
     LET vsegmento2_pa = TRIM(vsegmento2_pa)||'01'||LPAD(LENGTH(TRIM(vcolonia)),2,"0")||vcolonia;
     LET tb_colonia    = vcolonia;
  ELSE
	let vsegmento2_pa = trim(vsegmento2_pa)||'0100'; --RQM 09 467_Version 14
  END IF;

-- Agrega Delegacion o Municipio
  IF vdelegacion != "" THEN
     LET vsegmento2_pa = TRIM(vsegmento2_pa)||'02'||LPAD(LENGTH(TRIM(vdelegacion)),2,"0")||vdelegacion;
     LET tb_delegacion = vdelegacion;
  ELIF vdelegacion = "" or vdelegacion is null then
	 LET vsegmento2_pa = trim(vsegmento2_pa)||'0200'; --RQM 09 467_Version 14	 
-- Agrega Ciudad si delegacion es blanco --RQM 09 467_Version 14	
	   SELECT nvl(nombre,'') INTO vciudad
           FROM bdinteg:si_ciudades 
          WHERE estado = vclave_edo
            AND ciudad = vclave_ciudad;       
		
		IF  vciudad != ''  then
			LET vsegmento2_pa = TRIM(vsegmento2_pa)||'03'||LPAD(LENGTH(TRIM(vciudad)),2,"0")||vciudad;
			LET tb_ciudad     = vciudad;
		ELSE-- vciudad = ''  then 
		  let vsegmento2_pa = trim(vsegmento2_pa)||'0300'; 
		END IF
  END IF

-- Agrega Estado
  LET vsegmento2_pa = TRIM(vsegmento2_pa)||'04'||LPAD(LENGTH(TRIM(vestado)),2,"0")||TRIM(vestado);
  LET tb_estado     = TRIM(vestado);

-- Agrega Codigo Postal
  LET vsegmento2_pa = TRIM(vsegmento2_pa)||'05'||LPAD(LENGTH(TRIM(vcod_postal)),2,"0")||TRIM(vcod_postal);
  LET tb_cod_postal = TRIM(vcod_postal);

-- Agregar origen del domicilio (pais) --RQM 09 467_Version 14
  LET vsegmento2_pa = trim(vsegmento2_pa)||'1202MX';
  LET tb_codigo_pais  = 'MX';  
  
  LET vsegmento2_pa = 'PA'||TRIM(vsegmento2_pa);
-- TERMINA ARMADO SEGMENTO PA (DirecciÃ³n)

  LET vcuotas_ven = 0;
  LET vpago_int = "";
-- INICIA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14
  --Etiqueta PE -Nombre o Razo Social del empleador 
        SELECT nvl(a.nombre_empresa,'')
          INTO cnombre_empleador
          FROM bdinteg:si_ingresos a
         WHERE a.numcte = vNumcte
           AND a.sec_ingreso = (SELECT max(sec_ingreso)
                                  FROM bdinteg:si_ingresos 
                                 WHERE numcte = a.numcte);

     IF cnombre_empleador = '' or cnombre_empleador is null THEN
        IF vprofesion = '06' THEN 
           LET cnombre_empleador = 'DESEMPLEADO';
        ELIF vprofesion = '10' THEN
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';
        ELIF vprofesion = '12' THEN
           LET cnombre_empleador = 'LABORES DEL HOGAR';
        ELIF vprofesion = '15' THEN
           LET cnombre_empleador = 'ESTUDIANTE';
        ELIF vprofesion = '16' THEN
           LET cnombre_empleador = 'JUBILADO';
        ELSE 
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';  
        END IF;
    END IF;
    
	let vsegmento3_pe = 	lpad(length(trim(cnombre_empleador)),2,"0")  || trim(cnombre_empleador);
	let tb_nombre_empleador = trim(cnombre_empleador);  


	-- Agregar origen del domicilio De la razÃ³n social (pais) 
	let vsegmento3_pe = trim(vsegmento3_pe)||'1802MX';
	let tb_origen_razon_soc  = 'MX';

	let vsegmento3_pe = 'PE'||trim(vsegmento3_pe);           	  
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14	

-- INICIA ARMADO SEGMENTO TL (Datos Financieros)
    
	-- RQM 09 502 MACF
	-- Obtener el nÃºmero de tarjeta de br_burofisicas_describe
	if vnum_producto in('6001','6600','7000','8100','8500') then
		/*select limit 1 num_tarjeta into vnum_tarjeta
		  from bdiburo:br_burofisicas_describe
		 where num_credito = vnum_credito
           and nvl(fecha_cierre,'') = '';*/

    select num_tarjeta  into vnum_tarjeta
		  from bdiburo:br_bitacora_tarjeta
		 where num_credito = vnum_credito;		   
 	  
         -- si no existe, significa que no se enviÃ³ en la cinta mensual anterior, buscar en sd_tarjeta 
	     if nvl(vnum_tarjeta,'') = '' then
		    select a.num_tarjeta, a.status_tar
              into vnum_tarjeta, cStatus_tar		 
		      from bdicred:sd_tarjeta a
             where a.empresa = '001' and a.num_credito = vnum_credito
               and a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001'
                                  and num_credito = a.num_credito and tipo_tarjeta = 'T');
								  
			-- Si tampoco estÃ¡ en sd_tarjeta, buscarla en intercard:tarjeta
			if nvl(vnum_tarjeta,'') = '' then
			   select limit 1 a.numtarjeta into vnum_tarjeta
			     from intercard:tarjeta a, intercard:tarjetacuenta b
                where a.numtarjeta = b.numtarjeta and b.numcuenta = vnum_credito and codstatustarjeta = 'ACT' and titular = 'T';
			end if;
            
			-- Si tampoco estÃ¡ en intercard:tarjeta
            if nvl(vnum_tarjeta,'') = '' then  			
			   let vnum_tarjeta = '0000000000000000'; --asignarle ceros para que no truene el armado de la cadena 
            end if;
			
		 end if;
    end if;	
	


	-- RQM 09 502 MACF

  --IF vnum_producto in ('6001','6600','7000') THEN  --IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino
  IF vnum_producto in ('6001','6600','7000','8100','8500') THEN 
      SELECT monto_otorgado,
          nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
          nvl(monto_vencido + mto_venc_trasp,0), nvl(sdo_no_exig,0),
          nvl(monto_financiado,0),case when sdo_cap_insoluto >=0 then sdo_cap_insoluto else 0 end
        INTO vmonto_otorgado, vsaldo_vig, vsaldo_venc, v_interes,vcuota_cap, vmontoinsoluto
        FROM bdicred:sd_maesdos c
       WHERE c.empresa = '001'
         AND c.num_credito = vnum_credito;
--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
  -- Obtiene datos de indicadores
        select fecha_ultima_compra, num_vencidos, saldo_maximo, fecha_vencido, dias_atraso, monto_ultimo_pago_h
          into vpago_int, vcuotas_ven, vcredito_maximo, vfecha_vencido, vdiasatraso, vmontolutpago
          from bdicred:sd_indicador_cred
         where empresa = "001" 
           and num_credito = vnum_credito;
  ELSE
      SELECT monto_otorgado,
          nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
          nvl(monto_vencido + mto_venc_trasp,0), sdo_no_exig,
          monto_otorgado,case when sdo_cap_insoluto >=0 then sdo_cap_insoluto else 0 end
        INTO vmonto_otorgado, vsaldo_vig, vsaldo_venc, v_interes, vcredito_maximo, vmontoinsoluto
        FROM bdicred:sd_maesdoscrd c
       WHERE c.empresa = '001'
         AND c.num_credito = vnum_credito;

      SELECT {+INDEX(bdicred:sd_amortiza_creditocrd amorsx)} 
             nvl(SUM(capital_mto_cuota - capital_pagado - interes_pagado - iva_pagado),0), 
             nvl(SUM(CASE WHEN capital_status IN ('2','7') THEN 1 ELSE 0 END),0)
        INTO vcuota_cap,
             vcuotas_ven
        FROM bdicred:sd_amortiza_creditocrd
       WHERE empresa = '001'
         AND num_credito = vnum_credito
         AND capital_status in ('1','2','7');

--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
		select nvl(fecha_vencido,date(1)), -- primer incumplimiento
               nvl(dias_atraso,0), -- dias de atraso
               fecha_ultimo_pago_h -- fecha de ultimo pago
          into vfecha_vencido,
               vdiasatraso,
               vfechaultpago
          from bdicred:sd_indicador_cred_crd
         where empresa = "001" 
           and num_credito = vnum_credito;	

        if (vfechaultpago is not null) then

            select nvl(sum(monto),0) 
              into vmontolutpago -- monto de ultimo pago de crd
              from bdicred:sd_movhiscrd
             where empresa = '001' 
               and num_credito = vnum_credito
               and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd) 
               and codigo_ref = 1
               and fecha_mov = vfechaultpago
               and reversado = 'N';
        else
            let vmontolutpago = 0;
        end if;

--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
  END IF;

--RQM 09 325 rss 
   if (vStatusCred in ('AA','FF')) or (vStatusCred = 'VP' and vsaldo_venc <= 0) then 
      let vdiasatraso = 0; 
   else 
      let vdiasatraso = vdiasatraso ;
      let vfecha_hoy = vfecha_hoy ;
      let vPriDiaMes = vPriDiaMes ;

      let vdiasatraso = vdiasatraso + round((date(vfecha_hoy) - date(vPriDiaMes)));
   end if;

   if vfecha_vencido is null then let vfecha_vencido = date(1); end if;

   LET vfechacuota = MDY(MONTH(vfecha_hoy),vdiacuota,YEAR(vfecha_hoy));

   IF vfechacuota < vfecha_apertura OR vnum_credito IS NULL THEN -- creditos sin procesar
      CONTINUE FOREACH;
   END IF

-- Agregar Clave y nombre del otorgante
   LET vsegmento4_tl = '02TL0110'||vclave_usu_bc||'02'||LPAD(LENGTH(TRIM(vnombre_usu)),2,"0")||vnombre_usu;
   LET tb_clave_usu  = vclave_usu_bc;
   LET tb_nombre_usu = vnombre_usu;

-- Agregar Numero de credito
   -- LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_credito)),2,"0")||TRIM(vnum_credito);
   -- LET tb_num_credito = TRIM(vnum_credito);

   
   --if vnum_producto <> '6011' then
   if vnum_producto in('6001','6600','7000','8100','8500') then  -- RQM 09 502
      LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_tarjeta)),2,"0")||TRIM(vnum_tarjeta);
      LET tb_num_credito = TRIM(vnum_credito);
      LET tb_num_tarjeta = trim(vnum_tarjeta);
   else
      LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_credito)),2,"0")||TRIM(vnum_credito);
      LET tb_num_credito = TRIM(vnum_credito);
	  LET tb_num_tarjeta = '';
   end if;
   
     
   
-- Agregar Tipo de responsabilidad de la cuenta
-- I = Individual
-- J = Mancomunada
-- C = Obligado Solidario

   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'0501I0601';
   LET tb_responsabilidad   = "I";

-- Agregar Tipo de cuenta y tipo de producto
-- TIPO DE CUENTA
-- I = Pagos Fijos
-- M = Hipotecaria
-- O = Sin limite preesTABLEcido
-- R = Revolvente

-- TIPO DE PRODUCTO
-- CC = Tarjeta de Credito
-- PL = Prestamo Personal

  IF vtp_linea = '1' THEN
     LET vsegmento4_tl    = TRIM(vsegmento4_tl)||'R0702CC';
     LET vnum_pagos       = 0;
     LET vfrecpago        = "M";
     LET tb_tipo_cuenta   = "R";
     LET tb_tipo_producto = "CC";
  ELIF vtp_linea = '0' THEN
        LET vsegmento4_tl =  TRIM(vsegmento4_tl)||'R0702CC';
        LET vnum_pagos       =  0;
        LET vfrecpago        =  "M";
        LET tb_tipo_cuenta   =  "R";
        LET tb_tipo_producto =  "CC";
   ELSE
      CONTINUE FOREACH;
   END IF;

--Agregar Clave Monetaria
-- MX = Pesos
-- US = Dolares
-- UD = Unidades de Inversion
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'0802MX';
   LET tb_clave_monetaria   = "MX";

-- Agregar Numero de Pagos
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'10'||LPAD(LENGTH(vnum_pagos),2,"0")||TRIM(vnum_pagos);
   LET tb_num_pagos = TRIM(vnum_pagos);

-- Agregar Fecuencia de Pagos
-- M = Mensual
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1101'||vfrecpago;
   LET tb_frecpago = vfrecpago;

-- Agregar Monto a Pagar 
-- Se adelanta la obtencion de saldos
   LET vsaldo_actual = 0;
    
   
   IF ( v_interes IS NULL OR v_interes <= 0 ) THEN
      LET v_interes = 0;
   END IF;

-- Se agregan exepciones de pago y saldo
   LET vsaldo_vig = vsaldo_vig + v_interes;
   LET vrea_cal_cuota = 0;

   IF vcuota_cap >= vsaldo_vig THEN
      IF vsaldo_vig > 0 THEN
         LET vcuota_cap = vsaldo_vig / 10;
         LET vrea_cal_cuota = 1;
      ELSE
         LET vcuota_cap = 0;
      END IF;
   END IF;

   IF ROUND(vcuota_cap,0) = 0 AND vsaldo_vig > 0 THEN
      LET vcuota_cap = vsaldo_vig / 10;
      LET vrea_cal_cuota = 1;
   END IF;

   IF ROUND(vcuota_cap,0) = 0 THEN LET vcuota_cap = ROUND(vsaldo_vig,0); END IF;

   IF vcuota_cap > 0 THEN
      LET vmonto = ROUND(vcuota_cap,0);
   ELSE
      LET vmonto = 0;
   END IF

 
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1209'||LPAD(ROUND(vmonto,0),9,"0");
   LET tb_monto_pagar = ROUND(vmonto,0);
   
-- Agregar Fecha de Apertura de la Cuenta
   LET vanio = YEAR(vfecha_apertura);
   LET vmes = LPAD(MONTH(vfecha_apertura),2,"0");
   LET vdia = LPAD(DAY(vfecha_apertura),2,"0");
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1308'||vdia||vmes||vanio;

   LET tb_fecha_apertura    = vdia||vmes||vanio;

  IF vpago_cap IS NULL THEN LET vpago_cap = vfecha_apertura; END IF;
  IF vpago_int IS NULL THEN LET vpago_int = vfecha_apertura; END IF;

-- Agregar Fecha de Ultimo Pago
  LET vanio = YEAR(vpago_cap);
  LET vmes = LPAD(MONTH(vpago_cap),2,"0");
  LET vdia = LPAD(DAY(vpago_cap),2,"0");

  LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'1408'||vdia||vmes||vanio;
  LET tb_fecha_ult_pago = vdia||vmes||vanio;

-- Agregar Fecha de Ultima Compra
  IF vpago_int >= vfecha_hoy THEN LET vpago_int = vpago_cap; END IF;

  LET vanio = YEAR(vpago_int);
  LET vmes = LPAD(MONTH(vpago_int),2,"0");
  LET vdia = LPAD(DAY(vpago_int),2,"0");

  LET vsegmento4_tl       = TRIM(vsegmento4_tl)||'1508'||vdia||vmes||vanio;
  LET tb_fecha_ult_compra = vdia||vmes||vanio;

  
-- Agregar Fecha Reporte
   LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'1708'||vfecha_reporte;
   LET tb_fecha_reporte  = vfecha_reporte;

   IF (vsaldo_venc IS NULL) OR (vsaldo_venc < 0) THEN LET vsaldo_venc = 0; END IF

-- Agregar Saldo MÃ¡ximo

  IF (vcredito_maximo is null) or (vcredito_maximo < 0) then let vcredito_maximo = 0.0; end if


  LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'2109'||LPAD(ROUND(vcredito_maximo,0),9,"0");
  LET tb_credito_maximo = ROUND(vcredito_maximo,0);

-- Agregar Saldo Actual
  LET vsaldo_actual   = ROUND(vsaldo_vig,0);
  LET tb_saldo_actual = vsaldo_actual;
  
  
  IF nvl(vsaldo_actual,'') = '' THEN --- RQM 09 467_Version 14
    LET vsegmento4_tl = trim(vsegmento4_tl)||'2200';
  END IF;

    
  IF vsaldo_actual >= 0 THEN
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2210'||LPAD(ROUND(vsaldo_actual,0),10,"0");
  ELSE
     LET vsaldo_actual = abs(vsaldo_actual);
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2210'||LPAD(ROUND(vsaldo_actual,0),9,"0")||"-";
  END IF

-- Agregar Limite de Credito
	IF nvl(vmonto_otorgado,'') = '' THEN --- RQM 09 467_Version 14
		LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2300';
	ELSE
		LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'2309'||LPAD(ROUND(vmonto_otorgado,0),9,"0");
		LET tb_monto_otorgado = ROUND(vmonto_otorgado,0);
	END IF;
	
-- Se agregan pagos vencidos
  IF (vsaldo_venc <= 0 OR vcuotas_ven = 0 OR vcuotas_ven IS NULL) THEN
     LET vcuotas_ven = 0;
  END IF;   

---Modificar de acuerdo a circulo
/*--RQM 09 325 rss
  IF vfecha_apertura > vfecha_ini THEN
     LET vmop = "00";
               --ELIF (vmonto = 0  AND vstatus_cred <> 'CV')   THEN
  ELIF (vmonto = 0 )   THEN
     LET vmop = "01";
     LET vsaldo_venc = 0;
  ELIF (vcuotas_ven = 0) THEN
     LET vmop = "01";
     LET vsaldo_venc = 0;
  ELIF vcuotas_ven = 1 THEN
     LET vmop = "02";
  ELIF vcuotas_ven = 2 THEN
     LET vmop = "03";
  ELIF vcuotas_ven = 3 THEN
     LET vmop = "04";
  ELIF vcuotas_ven = 4 THEN
     LET vmop = "05";
  ELIF vcuotas_ven = 5 THEN
     LET vmop = "06";
  ELIF (vcuotas_ven >= 6) AND (vcuotas_ven <= 12)  THEN
     LET vmop = "07";
  ELIF vcuotas_ven > 12 THEN
     LET vmop = "96";
  END IF
*/--RQM 09 325 rss
--RQM 09 325 rss
    LET vmop = '';
    if (vmontoinsoluto > 0 and vmontoinsoluto < 1) then
       let vmontoinsoluto =1;
	end if;
---Modificar de acuerdo a circulo

   let vfecha_hoy_aux = (vfecha_hoy + 1 units day);
   execute PROCEDURE bdicred:"informix".monthadd(vfecha_hoy_aux, -1) into vfecha_hoy_aux;

--   if (vfecha_apertura < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 and vmontoinsoluto <= 0 then
--      let vmop = "UR";
--   elif (vfecha_apertura >= ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 then

   if vfecha_apertura < vfecha_hoy_aux and vfechaultpago < vfecha_hoy_aux and vfechaultcompra < vfecha_hoy_aux and vdiasatraso = 0 and vmontoinsoluto <= 0 then
      let vmop = "UR";
   elif vfecha_apertura >= vfecha_hoy_aux and vfechaultpago < vfecha_hoy_aux and vfechaultcompra < vfecha_hoy_aux and vdiasatraso = 0 then
      let vmop = "00";
   elif (vdiasatraso  =   0) then
      let vmop = "01";
   elif (vdiasatraso >=   1 and vdiasatraso <=  29) then
      let vmop = "02";
   elif (vdiasatraso >=  30 and vdiasatraso <=  59) then
      let vmop = "03";
   elif (vdiasatraso >=  60 and vdiasatraso <=  89) then
      let vmop = "04";
   elif (vdiasatraso >=  90 and vdiasatraso <= 119) then
      let vmop = "05";
   elif (vdiasatraso >= 120 and vdiasatraso <= 149) then
      let vmop = "06";
--   elif (vdiasatraso >= 150 and vdiasatraso <= (vfecha_hoy - (vfecha_hoy - 1 units year)) - 1) then
--   elif (vdiasatraso >= 150 and vdiasatraso <= 354) then
   elif (vdiasatraso >= 150 and vdiasatraso <= (abs(date(vfecha_hoy)) - abs(date(vfecha_hoy - 1 units year))) - 1) then
      let vmop = "07";
   else
      let vmop = "96";
   end if
--RQM 09 325 rss

   IF vsaldo_venc < 1 AND vcuotas_ven > 0 THEN
      LET vsaldo_venc = 1; 
   END IF

-- Agregar Saldo vencido
	IF  NVL(vsaldo_venc,'') = '' THEN --- RQM 09 467_Version 14
            let vsegmento4_tl = trim(vsegmento4_tl)||'2400';
	ELSE
		LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2409'||LPAD(ROUND(vsaldo_venc,0),9,"0");
		LET tb_saldo_venc = ROUND(vsaldo_venc,0);
	END IF;

	
-- Agregar Numero de Pagos Vencidos
  IF vsaldo_venc > 0 THEN
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2504'||LPAD(vcuotas_ven,4,"0");
     LET tb_cuotas_ven = vcuotas_ven;
  END IF

-- Agregar Forma de Pago
-- UR = Cuenta sin informacion
-- 00 = Muy reciente para ser informada
-- 01 = Pago puntual y adecudo
-- 02 = Atraso de 01 a 29 dias
-- 03 = Atraso de 30 a 59 dias
-- 04 = Atraso de 60 a 89 dias
-- 05 = Atraso de 90 a 119 dias
-- 06 = Atraso de 120 a 149 dias
-- 07 = Atraso de 150 hasta 12 meses
-- 96 = atraso de 12 meses
-- 97 = Cuenta con deuda parcial o total sin recuperar
-- 99 = Fraude cometido por el cliente 
  
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2602'||vmop;
     LET tb_mop        = vmop;

   
--RQM 09 325 rss --IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino
    LET vstatus_credAnt = '';
    --IF vnum_producto IN ('6001','6600','7000') AND vStatusCred = 'AA' AND vmop != 'UR' THEN  
    IF vnum_producto IN ('6001','6600','7000','8100','8500') AND vStatusCred = 'AA' AND vmop != 'UR' THEN
       SELECT status_cred  
         INTO vstatus_credAnt
         FROM bdicred:sd_maecredcont
        WHERE empresa = '001'
          AND fecha = vfecha_fin_mes_ant  --'2013/07/31'
          AND num_credito = vnum_credito;
    ELIF vnum_producto = '6011' AND vStatusCred IN ('AA','VP') AND vmop != 'UR' THEN
   select status_cred, nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0),0)   
     into vstatus_credAnt, vsaldo_vencAnt
     from bdicred:sd_maecredcontcrd a inner join bdicred:sd_maesdoscontcrd b
       on a.num_credito = b.num_credito
    where a.empresa = '001'  and b.empresa = '001'
      and a.fecha = b.fecha 
      and a.fecha = vfecha_fin_mes_ant  --'2013/07/31'
      and a.num_credito = vnum_credito;
    END IF;
--IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino        
    --IF (vnum_producto IN ('6001','6600','7000') AND vstatus_credAnt IN ('BT','BA') AND vStatusCred = 'AA') 
	IF (vnum_producto IN ('6001','6600','7000','8100','8500') AND vstatus_credAnt IN ('BT','BA') AND vStatusCred = 'AA')
		OR  (vnum_producto='6011' AND 
	 (vstatus_credAnt IN ('BT','BA') or (vstatus_credAnt ='VP' and vsaldo_vencAnt > 0))
	  AND vStatusCred IN ('AA','VP') AND vsaldo_venc <= 0) THEN 
			   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'3002'||'EL';
			   LET tb_clave_obs               = 'EL';
	END IF;

  
  LET vanio = year(vfecha_vencido);
  LET vmes = lpad(month(vfecha_vencido),2,"0");
  LET vdia = lpad(day(vfecha_vencido),2,"0");
  
  IF vmop IN ('00','01','UR') THEN  --RQM 09 467_Version 14
	LET vsegmento4_tl = TRIM(vsegmento4_tl)||'430801011900';
	LET tb_fecha_vencimiento = '01011900';
  ELSE
	LET vsegmento4_tl = TRIM(vsegmento4_tl)||'4308'||vdia||vmes||vanio;
	LET tb_fecha_vencimiento = vdia||vmes||vanio;
  END IF;

-- Saldo insoluto
  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'4410'||
                       lpad(round(vmontoinsoluto,0),10,"0");
  LET tb_monto_insoluto = round(vmontoinsoluto,0);


-- MONTO DE ULTIMO PAGO
  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'4509'||
                        lpad(round(vmontolutpago,0),9,"0");
  LET tb_ultimo_pago = round(vmontolutpago,0);
--RQM 09 325 rss 
-- PLAZO EN MESES RQM 09 467_Version 14
   IF vnum_producto = '6011' THEN  
	 let vsegmento4_tl  = TRIM(vsegmento4_tl)||'500'|| length(cplazo_meses)+3 || trim(cplazo_meses) || '.00';                       
	 let tb_plazo_meses = trim(cplazo_meses);    
  ELSE
	 LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'50040.00';
	 let tb_plazo_meses = '0'; 
  END IF; 
-- MONTO DE CRÃDITO A LA ORIGINACION  --RQM 09 467_Version 14
	IF vnum_producto <> '6011' THEN
	  SELECT monto_solicitado INTO dmonto_autorizado
		FROM bdisolic:ss_solicitudes
	   WHERE empresa = '001'
		 AND num_solicitud = vnum_credito;
	  
	  IF  nvl(dmonto_autorizado,'') = '' THEN	 
		 select nvl(monto_otorgado,0) INTO dmonto_autorizado
			from bdicred:sd_maesdos
			where empresa = "001"
			and num_credito = vnum_credito;
	  END IF;	 
	  
	  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'5109'||
						  lpad(round(dmonto_autorizado,0),9,"0");
	  LET tb_monto_originacion = round(dmonto_autorizado,0);			 
    ELSE   
		SELECT nvl(monto_otorgado,0)    
        into d_monto_originacion
        FROM bdicred:sd_maesdoscontcrd
        where empresa = "001"
        and fecha = vfecha_fin_mes_ant
        and num_credito = vnum_credito;
    
	  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'5109'||
						lpad(round(d_monto_originacion,0),9,"0");
	  LET tb_monto_originacion = round(d_monto_originacion,0);
    END IF;	

-- Agregar clave de observacion -- Venta de Cartera Fin
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'9903FIN';
   LET vsegmento4_tl = 'TL'||TRIM(vsegmento4_tl);
-- TERMINA ARMADO SEGMENTO TL (Datos Financieros)

   IF TRIM(vsegmento_pn) != "PN" AND TRIM(vsegmento2_pa) != "PA" AND TRIM(vsegmento3_pe) != "PE" AND TRIM(vsegmento4_tl) != "TL" THEN
--
    --SELECT count(*) INTO iCP
		--FROM sepomex WHERE d_codigo = tb_cod_postal AND d_mnpio = tb_delegacion AND estado_abrev = tb_estado;

      IF iCP IS NULL THEN LET iCP = 0; END IF;

      IF iCP > 0 THEN

          BEGIN WORK;

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento_pn);

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento2_pa);
			   
		  LET vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
		  INSERT INTO br_burofisicas_cortos
				VALUES(vnumreg,vsegmento3_pe);			   

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento4_tl);

    -- Se agrega tabla para grabar informacion enviada
          INSERT INTO br_burofisicas_describe_cortos (num_credito, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc, nacionalidad,
		         estado_civil, sexo, calle, colonia, delegacion, ciudad, estado, cod_postal, origen_dom, razon_social, origen_razon_soc, clave_usu,
				 nombre_usu, responsabilidad, tipo_cuenta, tipo_producto, clave_monetaria, num_pagos, frecpago, monto_pagar, fecha_apertura, fecha_ult_pago,
				 fecha_ult_compra, fecha_cierre, fecha_reporte, credito_maximo, saldo_actual, monto_otorgado, saldo_venc, cuotas_ven, mop, clave_obs, 
				 int_calculo, fecha_vencimiento, monto_insoluto, ultimo_pago, plazo_meses, monto_originacion, num_tarjeta) 
               VALUES (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, 
                       tb_estado_civil, tb_sexo, tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
					   tb_codigo_pais, tb_nombre_empleador,tb_origen_razon_soc,  --RQM 09 467_Version 14  
					   tb_clave_usu, 
                       tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, 
                       tb_monto_pagar, tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, 
                       tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado, tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago
					   ,tb_plazo_meses,tb_monto_originacion,vnum_tarjeta); --tb_plazo_meses,tb_monto_originacion, RQM 09 467_Version 14 
--                       tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado, tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota); 


		  
          COMMIT WORK;

          LET tb_total_sdo_vencido = tb_total_sdo_vencido + tb_saldo_venc;
          LET tb_total_sdo_actual = tb_total_sdo_actual + tb_saldo_actual;

          LET tb_total_seg_pn = tb_total_seg_pn + 1;
          LET tb_total_seg_pa = tb_total_seg_pa + 1;
          LET tb_total_seg_tl = tb_total_seg_tl + 1;

          LET contador_commit = contador_commit  + 1;
          LET tb_total_bloques = tb_total_bloques + 1;
          LET iTotalProcesados = iTotalProcesados + 1;
      END IF;
      LET iCP = 0;
   END IF

END FOREACH; 

UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cortos;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cortos;

IF WEEKDAY(vfecha_hoy) = 1 THEN
-- Genera registro encabezado
    LET vheader = vencabezado1||vversion||vclave_usu_bc||vnombre_usu||
                  vciclo||vfecha_reporte||vuso_futuro||
                  RPAD(TRIM(vinf_adicional),98,"&");
    LET vnumreg = 1;
    LET tb_total_seg_intf = 1;

    LET tb_nombre_otorg = vnombre_usu;
    LET tb_domicilio_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.';

    INSERT INTO br_burofisicas_cortos VALUES (vnumreg,vheader);


-- Descarga y arma segmento TRLR y lo inserta

/* Por el RQM 09 430 Envio de Cintas Semanales a Circulo de CrÃ©dito, se hace la separaciÃ³n de la generaciÃ³n de las cintas a las SICs
    LET varchivo = "genburofiscortos.sql";
    LET varchivo_des = "genburofis_describe_cortos.sql";

    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO /resplogifx/burodecredito/enviodepagos/xburofiscortos.unl' ||
                    ' SELECT registro FROM bdiburo:br_burofisicas_cortos WHERE numreg=1 ' ||
                    ' UNION ' ||
                    ' SELECT CASE WHEN substr(a.registro,1,2)='||'''TL'''||' AND a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
                    ' THEN trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-2))::lvarchar ||' || 
                    ' trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-1))::lvarchar||' || 
                    ' trim((replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||')))::lvarchar '  ||
                    ' ELSE trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-2))::lvarchar||' ||  
                    ' trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-1))::lvarchar||' ||  
                    ' trim(registro)::lvarchar' ||  
                    ' END' ||  
                    ' FROM bdiburo:br_burofisicas_cortos a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos"||vfecha_reporte||".txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofis*.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos"||vfecha_reporte||".txt ";
    SYSTEM vsql;

*/--Por el RQM 09 430 Envio de Cintas Semanales a Circulo de CrÃ©dito, se hace la separaciÃ³n de la generaciÃ³n de las cintas a las SICs

END IF;

DROP TABLE sepomex;
DROP TABLE creditos;

LET cMensajeFin = 'El proceso ENVIO PAGOS PARCIALES se ejecuto exitosamente. Creditos procs. ' || iTotalProcesados;

IF DATE(vfecha_hoy) - DATE(dtFecha_ultimo_reporte) > 1 THEN
   LET dtFechaProxReporte = vfecha_hoy;
END IF;

--IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N') THEN
--   LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
--END IF;

SELECT descripcion INTO vdescripcion_feriado
  FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N';
  
IF nvl(vdescripcion_feriado,'') <> '' THEN
   LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
END IF;

IF dtfechaproxreporte is null then LET dtfechaproxreporte = vfecha_hoy; END IF
UPDATE bdicred:sd_control_procesos
   SET fecha_proceso = dtFechaProxReporte,
       fecha_prox_proceso = dtFechaProxReporte + 1, --gev
	   status_proceso = 'F',
       mensaje        = vcodret || ' ' || cMensajeFin
 WHERE cod_proceso = 'cintaparcialbc';   

 CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '03') RETURNING vcodret2; 
 
RETURN vcodret,cMensajeFin;

END;
END PROCEDURE

DOCUMENT
'Se realiza procedimiento para reportar a las',
'sociedades crediticias por entregas parciales los',
'clientes que pagan y se ponen al corriente durante',
'el mes',
'AUTOR : Viridiana Osobampo',
'FECHA : 18/08/2009',
'BD    : BDIBURO';

CREATE PROCEDURE "informix".monthadd(d DATE, i INTEGER)
     RETURNING DATE;

     DEFINE d1 DATE;
     DEFINE rv DATE;
     DEFINE rv2 DATE;

     LET d1 = MDY(MONTH(d), 1, YEAR(d)); -- First day of given month
     LET rv2 = EXTEND(d1, YEAR TO DAY) + i UNITS MONTH; -- Add i months
     LET rv = rv2 + (d - d1); -- Add the days back
     IF MONTH(rv) != MONTH(rv2) THEN -- If the month changed
     LET rv = rv - DAY(rv); -- Subtract the number of days
     -- to get last day of prior month
     END IF;
     RETURN rv;
END PROCEDURE;