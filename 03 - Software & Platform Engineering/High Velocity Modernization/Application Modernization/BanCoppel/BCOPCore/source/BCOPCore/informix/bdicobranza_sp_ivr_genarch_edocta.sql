CREATE PROCEDURE "informix".sp_ivr_genarch_edocta(pEmpresa CHAR(3))

RETURNING CHAR(12);
/*__________________________________________________________________________________________________________________________________________________________________________
--'Creado por: Abrham López L.'
--'Fecha: 24/11/2011.'
--'Descripción: Proceso para la generación del archivo ivr para llamadas robotizadas para encuetas del estado de cuenta.'
--'Base de Datos: BDICOBRANZA.'
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- Modificado por: Abrham López L., fecha 04-04-2013. Se realiza homologación de sp para buscar los estados de cuenta en la instancia de PLD
*/
--DECLARACION DE VARIABLES.
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE cruta                CHAR(100);
DEFINE vproceso				CHAR(30);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE vEmpresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE pFecha               DATE;
DEFINE vTotalctecd          INTEGER;
DEFINE vNum_credito 		CHAR(20);
DEFINE vNombre1 			CHAR(26);
DEFINE vNombre2 			CHAR(26);
DEFINE vApellido1 			CHAR(26);
DEFINE vApellido2 			CHAR(26);
DEFINE vTelcasa 			CHAR(13);
DEFINE vTelcelular  		CHAR(13);
DEFINE vMoras 				INTEGER;
DEFINE vCiudad_coppel		SMALLINT;
DEFINE vNombreciudad 		VARCHAR(60,1);
DEFINE vRegioncobranza 		CHAR(30);
DEFINE vMonto 				DECIMAL(18,2);
DEFINE vAntiguedadcte		DATE;
DEFINE vMaxfechaemision     DATE;
DEFINE vNomciudadcop        VARCHAR(120,1);
DEFINE vNumciudadcop        SMALLINT;
DEFINE vNomregion           CHAR(30);
DEFINE vCampania            SMALLINT;
DEFINE vNumProducto         CHAR(4);
DEFINE sPaso                SMALLINT;
DEFINE vpri_dia_mes         DATE;

DEFINE cnomarchitemp		CHAR(100);
DEFINE cnomarchitem         CHAR(100);
DEFINE cCadena				CHAR(2500);
DEFINE vNom_ciudad          CHAR(30);

--SET DEBUG FILE TO "/resplogifx/archivoscartera/IVR_EDOCTA.out";
--TRACE ON;

--INICIALIZACION DE VARIABLES.
LET sql_err                 = "";
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '3002';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET vEmpresa                = "";
LET cdelimitador            = "";
LET vTotalctecd				= 0;
LET vNum_credito 			= "";
LET vNombre1 				= "";
LET vNombre2 				= "";
LET vApellido1 				= "";
LET vApellido2 				= "";
LET vTelcasa 				= "";
LET vTelcelular 			= "";
LET vMoras 					= "";
LET vCiudad_coppel			= "";
LET vNombreciudad 			= "";
LET vRegioncobranza 		= "";
LET vMonto 					= 0;
LET vAntiguedadcte			= '01-01-1900';
LET vMaxfechaemision        = '01-01-1900';
LET vNomciudadcop           = "";
LET vNumciudadcop           = 0;
LET vNomregion              = "";
LET vCampania               = 0; 
LET vNumProducto            = "";
LET sPaso                   = 0;
LET cnomarchitemp			= "";
LET cnomarchitem            = "";
LET cCadena   				= "";
LET vNom_ciudad				= "";
LET vpri_dia_mes            = '01-01-1900';
 
--INICIA PROCESO
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;
	
--SE INSERTA EN BITACORA CUANDO INICIA EL PROCESO.
	CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');

--DIRECTIVA PARA LECTURA DE TABLAS BLOQUEADAS.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SACAR FECHA DEL DIA DE HOY.
	Select Fecha_Hoy, pri_dia_mes
         Into pFecha, vpri_dia_mes
		From bdicred:sd_fechas
		Where empresa = pEmpresa;
	
	LET vMaxfechaemision = date(vpri_dia_mes) - 1 units day;
	
	LET vMaxfechaemision = mdy(month(vMaxfechaemision),20,year(vMaxfechaemision)); 

--SACAMOS LA EMPRESA.
    SELECT empresa
		INTO vEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;
--VALIDACION QUE EXISTA LA EMPRESA.
	IF NVL (vEmpresa, '') = '' THEN
        LET cCod_Ret= '104002';
		SELECT descripcion
            INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;

--OBTENER CARACTER DELIMITADOR.
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 2;
--VALIDA QUE EXISTA EL CARACTER DELIMITADOR.
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;

--OBTENER LA RUTA DEL ARCHIVO.
	SELECT TRIM(valor_alfabetico)
		INTO cruta
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 36;
--VALIDA QUE EXISTA LA RUTA.
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
            RETURN cCod_ret;
    END IF;

--OBTIENE EL NOMBRE DEL ARCHIVO.
    SELECT TRIM(valor_alfabetico)
        INTO cnombre
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 48;		
--VALIDA QUE EXISTA PARAMETRO DE NOMBRE DE ARCHIVO.
	IF NVL(cnombre,'') = '' THEN
        LET cCod_Ret= '104006';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;
	
	--SELECCIONAMOS EL NUMERO DE CAMPAÑA
		select id_campania 
			into vCampania
			from bdicobranza:cb_campanias
			where empresa = pEmpresa 
			and id_campania = 20;
			
--BORRAMOS LA TABLA DONDE SE INSERTARON LOS DATOS PARA FORMAR EL ARCHIVO SI ESTA EXISTE.		
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname = 'cb_temp_ivr_edocta';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_temp_ivr_edocta;
            END IF; 

--CREAMOS TABLA DONDE INSERTAREMOS LOS DATOS PARA FORMAR ARCHIVO.
    create table bdicobranza:cb_temp_ivr_edocta (
			cliente          CHAR(20),
			num_credito      CHAR(20),
			nombre1          CHAR(26),
			nombre2          CHAR(26),
			apellido1        CHAR(26),
			apellido2        CHAR(26),
			telcasa          CHAR(13),
			telcelular       CHAR(13),
			mora             INTEGER,
			ciudad_coppel    SMALLINT,
			nombreciudad     VARCHAR(60,1),
			regioncobranzas  CHAR(30),
			monto_otorgado   DECIMAL(18,2),
			fecha_insert     DATE,
			primary key (cliente, num_credito) 
			);
			
	--SACAMOS LA MAXIMA FECHA DE EMISION DEL ESTADO DE CUENTA DE TC.		
	--	select limit 1 max(fecha_emision)
	--	 into vMaxfechaemision
	--	 from bdicred@pld_tcp:sd_encabezado_edocta;
		
	--SE HACE EL COUNT DE CLIENTES, DE LOS CUALES SACAREMOS EL 10%
		SELECT  direccion_del, COUNT(fecha_emision) total_porciudad, num_producto
				FROM bdicred@pld_tcp:sd_encabezado_edocta
				WHERE fecha_emision = vMaxfechaemision
				and num_credito not in (select num_credito from bdicobranza:cb_ivr_edocta)
				AND num_producto = '6001'
		GROUP BY direccion_del, num_producto
		INTO temp sd_total_cte_porciudad;
		
		LET cnomarchitemp =  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
		LET cnomarchitem =  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

	--SELECCIONAMOS EL 10% DE CLIENTES POR CIUDAD.
		FOREACH	WITH HOLD
		
			SELECT round(nvl(nvl(a.total_porciudad,0) * (.10), 0)), b.numerociudad,trim(b.nombreciudad), c.nombre_region
				INTO vTotalctecd, vNumciudadcop, vNom_ciudad, vNomregion
				FROM sd_total_cte_porciudad a, bdinteg:si_catciudades b, bdinteg:si_regiones c
					WHERE a.direccion_del = b.nombreciudad
					AND a.num_producto = '6001'--vNumProducto
					AND b.numero_region = c.numero_region	
			GROUP BY total_porciudad, b.numerociudad,b.nombreciudad, c.nombre_region
	--END FOREACH;			
	--VALIDACION PARA QUE SI EL 10% DE CLIENTES ES IGUAL A CERO YA NO SIGA.
            IF nvl(vTotalctecd,0) <= 0 THEN
			CONTINUE foreach;
			END IF
						
			LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchitemp) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
			
			LET cSQL2 = " select  LIMIT "||vTotalctecd	
						|| " a.numcte, a.num_credito, trim(c.nombre1)nombre, trim(c.nombre2)nombre2, trim (c.apell_paterno)apellido1, trim (c.apell_materno)apellido2, "
						|| " 	trim(substr(tel1.telefono,length(tel1.telefono)-9,10)) as telcasa, "
						|| " 	trim(substr(tel2.telefono,length(tel2.telefono)-9,10)) as telcelular, "
						|| " 	b.mto_fin_ven_trasp::integer No_Vencidos," ||vNumciudadcop|| ", '"||trim(vNom_ciudad)||"', '"||trim(vNomregion)||"', b.monto_otorgado, a.fecha_apertura "
					--	|| " 	b.mto_fin_ven_trasp::integer No_Vencidos,b.monto_otorgado, a.fecha_apertura "
						|| " 	from bdicred:sd_maecred a "
						|| " 	join bdicred:sd_maesdos b on (a.empresa = b.empresa and a.num_credito = b.num_credito) "
						|| " 	join bdicred:sd_maecredanexo d on (a.empresa = d.empresa and a.num_credito = d.num_credito) "
						|| " 	join bdinteg:si_cliente c on (a.numcte = c.numcte)"
						|| " 	join bdinteg:si_direcciones_actual dir  on (a.numcte = dir.numcte )"
						|| " 	join bdinteg:si_telefonos tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1 and "
						|| " 		tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = dir.numcte and tipo_tel = 1)) and (nvl(tel1.telefono,'')<> '') "
						|| " 	join bdinteg:si_telefonos tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2 and "
						|| " 		tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = dir.numcte and tipo_tel = 2)) and (nvl(tel2.telefono,'') <> '') "
						|| " 	where a.status_cred in ('AA','BT','BA','E1','E2','E3') "
						|| " 	and a.fecha_apertura < '"||vMaxfechaemision||"' "   
						|| " 	and dir.tipo_dir = 1 "
						|| " 	and dir.numerociudad = "||vNumciudadcop||" ";

				LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRedocta1.sql';

				LET cSQL = trim(cSQL1) ||RTRIM(cSQL2) || trim(cSQL3);
				System cSQL;

				LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRedocta1.sql';
				System cSQL;

				LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRedocta1.sql';
				System cSQL;

			 --BORRA EL ULTIMO CARACTER DELIMITADOR Y PASA EL ARCHIVO YA SIN EL DELIMITADOR FINAL A OTRO ARCHIVO.
				LET cSQl = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchitemp) || " >> " || TRIM(cRuta) || TRIM(cnomarchitem);
				SYSTEM cSQL;
				
				--Borra el archivo de control.
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRedocta1.sql';
				SYSTEM cSQL;

				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || cnomarchitemp;
				SYSTEM cSQL;  
		--END IF;
	END FOREACH; 
	IF DBINFO("sqlca.sqlerrd2") > 0 --A.L.L
	THEN
--TOMAMOS EL ARCHIVO PARA INSERTARLO EN LA TABLA
	LET cCadena = 'echo " load from '|| SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cnomarchitem,1,
	LENGTH(cnomarchitem))  || ' insert into bdicobranza:cb_temp_ivr_edocta " >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
    let cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));	
	
--BORRA EL ARCHIVO DE CONTROL.
    let cCadena = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	let cCadena = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cnomarchitem;    System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	
-------------------------------------------------SE GENERA EL ARCHIVO FINAL PARA CAMPAÑA IVR EDOCTA------------------------------------------------------------------------------	

--VALIDAR QUE EXISTE EL ARCHIVO.
	LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivo =  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = " select  cliente, num_credito, nombre1, nombre2, apellido1, apellido2, telcasa, telcelular, mora, ciudad_coppel, trim(nombreciudad), trim(regioncobranzas), monto_otorgado, fecha_insert "
                    || " from bdicobranza:cb_temp_ivr_edocta " ;

    LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRedocta2.sql';

	LET cSQL = trim(cSQL1) ||RTRIM(cSQL2) || trim(cSQL3);
    System cSQL;

	LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRedocta2.sql';
	System cSQL;

	LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRedocta2.sql';
	System cSQL;

 --BORRA EL ULTIMO CARACTER DELIMITADOR Y PASA EL ARCHIVO YA SIN EL DELIMITADOR FINAL A OTRO ARCHIVO.
	LET cSQl = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
	SYSTEM cSQL;

--BORRA EL ARCHIVO DE CONTROL.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRedocta2.sql';
	SYSTEM cSQL;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
--INSERTAMOS EN LA TABLA LOS NUMEROS DE CREDITO TOMADOS EN ESTA GENERACION DE CAMPAÑA PARA NO TOMARLOS EN CUENTA DE NUEVO EN LA SIGUIENTE VUELTA.
	INSERT INTO bdicobranza:"informix".cb_ivr_edocta(empresa, num_credito, campania, fecha_insert)
	select vEmpresa, num_credito, vCampania, today
	FROM bdicobranza:cb_temp_ivr_edocta;
	
	
--SE INSERTA EN BITACORA  CUANDO FINALIZA EL PROCESO
	CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '03');
	end if
	RETURN cCod_ret;

END;
END PROCEDURE;