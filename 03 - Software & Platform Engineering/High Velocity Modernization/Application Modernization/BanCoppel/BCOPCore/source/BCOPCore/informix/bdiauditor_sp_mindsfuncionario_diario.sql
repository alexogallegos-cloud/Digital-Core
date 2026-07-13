CREATE PROCEDURE "informix".sp_mindsfuncionario_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_FUNCIONARIO VARCHAR(50);
DEFINE vconteo					INTEGER;
DEFINE v_conteonuevos           INTEGER;
DEFINE v_conteoactualizado		INTEGER;
DEFINE v_conteobajas            INTEGER; 

--VARIABLE LAYOUT FUNCIONARIO
DEFINE 	v_idpaisnacimiento		CHAR(3);
DEFINE 	v_idestadonacimiento	INTEGER;
DEFINE	v_idpais				CHAR(3);
DEFINE	v_idestado				INTEGER;
DEFINE	v_idmunicipio			INTEGER;
DEFINE	v_idplaza				INTEGER;
DEFINE	v_idnacionalidad		CHAR(1);
DEFINE	v_aliassucursal			INTEGER;
DEFINE	v_idsexo				CHAR(1);
DEFINE	v_noempleado			CHAR(8);
DEFINE	v_nombre				CHAR(100);
DEFINE	v_apellidopaterno		CHAR(100);
DEFINE	v_apellidomaterno		CHAR(100);
DEFINE	v_fechanacimiento		CHAR(1);
DEFINE	v_rfc					CHAR(1);
DEFINE	v_departamento			CHAR(30);
DEFINE	v_puesto				CHAR(30);
DEFINE	v_fechabaja				CHAR(1);
DEFINE	v_estatus				INTEGER;
DEFINE	v_idestatuscargaminds	INTEGER;
DEFINE	v_fecharegistro			CHAR(10);
DEFINE  v_password				CHAR(40);
DEFINE  cDia    				CHAR(2);
DEFINE  cMes    				CHAR(2);
DEFINE  cAno    				CHAR(4);
DEFINE  cFecha					CHAR(8);

--VARIABLES DE PASO
DEFINE temp_fechafechanacimiento DATE;
DEFINE temp_fecharegistro		 DATE;
DEFINE v_fecha_hoy 				 DATE;
DEFINE v_fecha_ant				 DATE;
DEFINE v_vigencia				 DATE;

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET vconteo = 0;
LET v_conteonuevos = 0;
LET v_conteoactualizado = 0;
LET v_conteobajas = 0;
LET v_idpaisnacimiento = 'ZZ';
LET v_idestadonacimiento = 99999999;
LET	v_idpais = 'ZZ';
LET	v_idestado = 99999999;
LET	v_idmunicipio = 99999999;
LET	v_idplaza = 99999999;
LET	v_idnacionalidad = '1';
LET v_idsexo = '3';
LET v_fechabaja = ' ';
LET	v_fechanacimiento = ' ';
LET	v_rfc = ' ';
LET v_vigencia = ' ';
LET cDia = '';
LET cMes = '';
LET cAno = '';
BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
		LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsfuncionario_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_FUNCIONARIO,vconteo,v_conteonuevos,v_conteoactualizado,v_conteobajas,cod_ret||' '||vmensaje,'sp_mindsfuncionario_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/triad/entrada/descargas/sp_mindsfuncionario_diario.out';
    --TRACE ON;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	  = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_FUNCIONARIO = 'CargaFunMinds_'||TRIM(cFecha);

	LET vpaso = 3;
	---borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_funcionario_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT {+INDEX(bdinteg:si_ejecut idx_si_ejecut_fecha)} se.sucursal,se.ejecutivo,se.nombre,se.fecha_insert,sd.descripcion,se.nombramiento,se.vigencia,se.vigencia
		INTO v_aliassucursal,v_noempleado,v_nombre,temp_fecharegistro,V_departamento,v_puesto,v_password,v_vigencia
		fROM bdinteg:si_ejecut se
		LEFT JOIN bdinteg:si_departamentos sd ON se.departamento = sd.departamento
		WHERE se.fecha_insert = v_fecha_ant  
		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		
		LET vpaso = 6;
		--Conteo/Actualiza estatus de bajas y nuevos ingresos
		IF v_aliassucursal is null or v_aliassucursal = 0 THEN
			LET v_aliassucursal = 99999999;
		ELSE 
			LET v_aliassucursal = v_aliassucursal;
		END IF
		
		LET vpaso = 7;
		--Conteo/Actualiza estatus de bajas y nuevos ingresos
		IF TRIM(v_password) = 'BAJA' THEN
			LET v_estatus = 0;
			LET v_conteobajas = v_conteobajas + 1;
		ELSE 
			LET v_estatus = 1;
			LET v_conteonuevos = v_conteonuevos + 1;
		END IF
		
		LET vpaso = 8;
		--Nuevos empleados que se.fecha_insert=v_fecha_ant
		IF v_vigencia=v_fecha_ant and TRIM(v_password) = 'BAJA' THEN
			LET v_estatus = 0;
			LET v_conteobajas = v_conteobajas + 1;
		ELSE 
			LET v_estatus = 1;
			LET v_conteonuevos = v_conteonuevos + 1;
		END IF
		
		LET vpaso = 9;
		--descripcion=null poner "SUCURSAL"
		IF V_departamento is null THEN
			LET V_departamento = 'SUCURSAL';
		ELSE
			LET V_departamento = V_departamento;
		END IF
		
		LET vpaso = 10;
		--Desglosa el nombre completo en nombre y apellidos
		LET v_nombre = TRIM(v_nombre);
		LET v_apellidomaterno = TRIM(RIGHT(TRIM(v_nombre),CHARINDEX(' ', REVERSE(TRIM(v_nombre)))-1));
		LET v_nombre = TRIM(SUBSTR(TRIM(v_nombre),1,CHARINDEX(TRIM(v_apellidomaterno),TRIM(v_nombre))-1));
		LET v_apellidopaterno = TRIM(RIGHT(TRIM(v_nombre),CHARINDEX(' ', REVERSE(TRIM(v_nombre)))));
		LET v_nombre = TRIM(v_nombre);
		
		LET v_noempleado 	= REPLACE(v_noempleado,'|','');
		LET v_nombre 		= REPLACE(v_nombre,'|','');
		LET v_departamento 	= REPLACE(v_departamento,'|','');
		LET v_puesto 		= REPLACE(v_puesto,'|','');
		LET v_password 		= REPLACE(v_password,'|','');
		
		LET vpaso = 11;
		--trae el v_apellidomaterno al v_apellidopaterno
		IF v_apellidopaterno IS NULL THEN
			LET v_apellidopaterno = TRIM(v_apellidomaterno);
		ELSE
			LET v_nombre = TRIM(SUBSTR(TRIM(v_nombre),1,CHARINDEX(TRIM(v_apellidopaterno),TRIM(v_nombre))-1));
		END IF
		
		--Conversión de tipo fecha
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		
		--Inserta información en temporal
		LET vconteo = vconteo + 1;
		
		LET vpaso = 12;
		INSERT INTO "informix".tbl_funcionario_minds(idregistro,idpaisnacimiento,idestadonacimiento,idpais,idestado,idmunicipio,idplaza,idnacionalidad,aliassucursal,idsexo,noempleado,nombre,
								apellidopaterno,apellidomaterno,fechanacimiento,rfc,departamento,puesto,fechaalta,fechabaja,estatus,idestatuscargaminds,fecharegistro)
		VALUES(vconteo,v_idpaisnacimiento,v_idestadonacimiento,v_idpais,v_idestado,v_idmunicipio,v_idplaza,v_idnacionalidad,v_aliassucursal,v_idsexo,v_noempleado,v_nombre,
			v_apellidopaterno,v_apellidomaterno,v_fechanacimiento,v_rfc,v_departamento,v_puesto,v_fecharegistro,v_fechabaja,v_estatus,v_idestatuscargaminds,v_fecharegistro);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 13;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_FUNCIONARIO||'.txt select * FROM bdiauditor:tbl_funcionario_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_FUNCIONARIO||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 14;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_FUNCIONARIO||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_FUNCIONARIO||'_01.sql';
	system vsql;
	
	LET vpaso = 15;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_FUNCIONARIO||'_01.sql';
	system vsql;
	
	LET vpaso = 16;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_FUNCIONARIO);
	
	--Guarda registro en tabla TBL_LOGEXTRACCION_MINDS(bitacora control)
	insert into "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	values (v_fecha_hoy,vmensaje,vconteo,v_conteonuevos,v_conteoactualizado,v_conteobajas,'sp_mindsfuncionario_diario');
		
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Fernando Torres Soto',
'FECHA: 06/12/2022',
'DESCRIPCION: Se modifica el valor de las variables v_idpaisnacimiento y v_idpais para que el valor coincida con la llave foranea en tabla destino en el sistema MINDS debido a las modificaciones que hizo el proveedor',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindscliente_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTE 		VARCHAR(50);

--VARIABLE LAYOUT CLIENTE
DEFINE v_idkycestatus        	CHAR(1);
DEFINE v_idtipopersona			INTEGER;DEFINE v_idprocedenciarecurso	INTEGER;DEFINE v_iddestinorecurso		INTEGER;DEFINE v_idactividadeconomica	CHAR(7);DEFINE v_idsexo					CHAR(1);DEFINE v_idnacionalidad			CHAR(3);DEFINE v_idnacionalidad1		CHAR(3);DEFINE v_idpaisnacimiento		CHAR(3);DEFINE v_clave_pais				CHAR(3);
DEFINE v_idestadonacimiento 	INTEGER;DEFINE v_estado					CHAR(2);
DEFINE v_txtestadonacimiento 	CHAR(1);
DEFINE v_nic 					CHAR(20);DEFINE v_nombreorazons			CHAR(60);DEFINE v_apaterno				CHAR(26);DEFINE v_amaterno 				CHAR(26);DEFINE v_fechanacconstitucion 	CHAR(10);DEFINE v_rfc					CHAR(13);DEFINE v_curp					CHAR(20);DEFINE v_email					CHAR(50);DEFINE v_fiel					CHAR(10);
DEFINE v_ingresomensual 		DECIMAL(14,2);
DEFINE v_fecharegistro			CHAR(10);DEFINE v_fideicomiso 			INTEGER;
DEFINE v_noempleado				CHAR(8);DEFINE v_aliassucursal			INTEGER;DEFINE v_grupoeconomico       	CHAR(1);
DEFINE v_idfuentesingreso 		INTEGER;
DEFINE v_fechamodificacion  	CHAR(10);
DEFINE v_idpaisnacionalidad		CHAR(3);DEFINE v_activo					INTEGER;DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_idestatuscargaminds	INTEGER;DEFINE v_idpaisasignacionfiscal CHAR(2);DEFINE v_entidadpublica			INTEGER;
DEFINE v_spid					INTEGER;
DEFINE v_gobierno				INTEGER;
define v_conteocliente          integer;
DEFINE v_paisnacimiento 		CHAR(10);
DEFINE v_profesion				CHAR(4);
DEFINE v_giro					CHAR(3);
DEFINE v_ciudad					INTEGER;
DEFINE v_estado_geo				INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_ipaisgeo				CHAR(3);
DEFINE v_paisgeo				CHAR(2);

--VARIABLE DE PASO
DEFINE nombrepf1 				CHAR(26);DEFINE nombrepf2 				CHAR(26);DEFINE nombrepm 				CHAR(60);DEFINE temp_fechanacconstitucion DATE;DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE v_id_act					INTEGER;
DEFINE v_id_subact				INTEGER;

--SE INICIALIZAN VARIABLES
LET v_activo = 1;
LET v_idestatuscargaminds = 0;
LET v_idpaisasignacionfiscal = 'MX';
LET v_idfuentesingreso = 1;LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idpaisnacimiento = '';
LET v_paisnacimiento = '';
LET v_fideicomiso = 0;
LET v_giro = '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
        LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscliente_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTE,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscliente_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscliente_his.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTE	 = 'CargaCteMinds_'||TRIM(cFecha);
	LET vpaso = 3;
	
	---borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cliente_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD 
		SELECT {+AVOID_FULL(bdinteg:si_cliente)} tpo_persona,numcte,nombre1,nombre2,razon_social,apell_paterno,apell_materno,rfc,fecha_insert,ejecutivo,sucursal
		INTO v_idtipopersona,v_nic,nombrepf1,nombrepf2,nombrepm,v_apaterno,v_amaterno,v_rfc,temp_fecharegistro,v_noempleado,v_aliassucursal
		FROM bdinteg:si_cliente 
		WHERE tipo_cliente = '1' 
		AND fecha_insert = v_fecha_ant 
		UNION ALL
		SELECT {+AVOID_FULL(bdinteg:si_cliente)} tpo_persona,numcte,nombre1,nombre2,razon_social,apell_paterno,apell_materno,rfc,fecha_insert,ejecutivo,sucursal
		--INTO v_idtipopersona,v_nic,nombrepf1,nombrepf2,nombrepm,v_apaterno,v_amaterno,v_rfc,temp_fecharegistro,v_noempleado,v_aliassucursal
		FROM bdinteg:si_cliente 
		WHERE tipo_cliente = '1' 
		AND fecha_alta = v_fecha_ant 
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		IF v_idtipopersona IN(1,3) THEN --PERSONA FISICA
			
			LET vpaso = 6;
			
			SELECT profesion,sexo,nacionalidad,lugar_nac,fecha_nac,curp,id_pais
			INTO v_profesion,v_idsexo,v_idnacionalidad,v_estado,temp_fechanacconstitucion,v_curp,v_clave_pais
			FROM bdinteg:si_ctepf 
			WHERE numcte = v_nic;
						
			LET v_curp 	= REPLACE(v_curp,'|','');
			
			LET vpaso = 7;
			
			SELECT {+AVOID_FULL(bdinteg:si_bitacoraapertura)} FIRST 1 id_act,id_subact
			INTO v_id_act,v_id_subact
			FROM bdinteg:si_bitacoraapertura 
			WHERE numcte = v_nic 
			AND id_pregunta='6';
			
			SELECT {+AVOID_FULL(bdinteg:si_actsubact)} FIRST 1 idcnbv 
			INTO v_idactividadeconomica
			FROM bdinteg:si_actsubact 
			WHERE id_act = v_id_act
			AND id_subact = v_id_subact;
			
			IF v_idsexo = 'F' THEN
				LET v_idsexo = '2';
			ELIF v_idsexo = 'M' THEN
				LET v_idsexo = '1';
			END IF
			
			LET vpaso = 8;
			
			SELECT estado 
			INTO v_idestadonacimiento
			FROM bdinteg:si_estados 
			WHERE estado = v_estado;
			
			IF (v_idestadonacimiento < 1) OR (v_idestadonacimiento > 32) OR (v_idestadonacimiento IS NULL) THEN
				LET v_idestadonacimiento = 99999999;
			END IF

			LET v_nombreorazons = TRIM(nombrepf1) || " " || TRIM(nombrepf2);
			LET v_fechanacconstitucion = to_char(temp_fechanacconstitucion, '%Y-%m-%d');
			
			LET vpaso = 9;
			
			SELECT {+INDEX(bdinteg:si_paises idx_clave_pais)} clave_pais 
			INTO v_idpaisnacimiento
			FROM bdinteg:si_paises 
			WHERE clave_pais = v_clave_pais;
			
			IF (v_idpaisnacimiento IS NULL) OR (v_idpaisnacimiento = '') THEN
				LET v_idpaisnacimiento = 'N/A';
			END IF
			
			LET v_idpaisnacionalidad = v_idpaisnacimiento;			
			LET vpaso = 10;
			
			SELECT FIRST 1 {+INDEX(bdinteg:si_correos idx_corr_cte_cons)} correo_elec
			INTO v_email
			FROM bdinteg:si_correos
			WHERE status_correo = 'A' 
			AND tipo_correo = '1'
			AND numcte = v_nic;
			
			LET vpaso = 11;
			
		ELIF v_idtipopersona IN(2,4,5) THEN --PERSONA MORAL
			
			LET vpaso = 12;
			
			SELECT nacionalidad,fecha_constitct,emailpm,giro
			INTO v_idnacionalidad,temp_fechanacconstitucion,v_email,v_giro
			FROM bdinteg:si_ctepm 
			WHERE numcte = v_nic;
			--**Recuerda traerte el idcnbv de la bdinteg:si_actsubact para la v_idactividadeconomica, sin la longitud del idcnbv no es de 7 hay que ponerle el default '9999999'
			
			LET v_idsexo = '3';
			LET v_idpaisnacimiento = 'N/A';
			LET v_idpaisnacionalidad = 'N/A';
			LET v_nombreorazons = TRIM(nombrepm);
			LET v_apaterno = NULL;
			LET v_amaterno = NULL;
			LET v_fechanacconstitucion = to_char(temp_fechanacconstitucion, '%Y-%m-%d');			LET v_curp = NULL;
			LET v_idestadonacimiento = 99999999;
			
			--**nueva asignacion de actividad economica 
			IF (v_giro = '001' ) or (v_giro = 1) THEN 
				LET v_idactividadeconomica = '8400002';
			ELIF (v_giro = '002' ) or (v_giro = 2) THEN 
				LET v_idactividadeconomica = '8400004';
			ELIF (v_giro = '003' ) THEN
				LET v_idactividadeconomica = '6999900';
			ELIF (v_giro = '004' ) THEN
				LET v_idactividadeconomica = '9900900';
			ELIF (v_giro = '005' ) THEN
				LET v_idactividadeconomica = '3999903';
			ELIF (v_giro = '006' ) THEN
				LET v_idactividadeconomica = '8949888';
			ELIF (v_giro = '999' ) THEN
				LET v_idactividadeconomica = '9221011';
			ELIF (v_giro = '' or v_giro is null ) THEN
				LET v_idactividadeconomica = '9999999';
			END IF
			
			LET vpaso = 13;
			
		END IF
		
		LET vpaso = 14;
		
		IF (length(v_idactividadeconomica) <> 7) OR (v_idactividadeconomica IS NULL) OR (v_idactividadeconomica = '0000000') THEN
			LET v_idactividadeconomica = '9999999';
		END IF
		
		IF (v_idsexo IS NULL) OR (v_idsexo = '') THEN
			LET v_idsexo = '3';
		END IF
		
		IF v_fechanacconstitucion < '1900-01-01' THEN
			LET v_fechanacconstitucion = '1900-01-01';
		END IF
		
		IF v_idnacionalidad = '001' or v_idnacionalidad = '1' or v_idnacionalidad = 1 or v_idnacionalidad is null THEN
			LET v_idnacionalidad1 = '1';		ELSE 
			LET v_idnacionalidad1 = '2';		END IF

		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vpaso = 15;
		
		SELECT {+INDEX(bdicheq:sc_maechq mae1)} FIRST 1 proced_aperturacta,proced_mantenercta 
		INTO v_idprocedenciarecurso,v_iddestinorecurso
		FROM bdicheq:sc_maechq 
		WHERE num_cte = v_nic;
		--Recuerda quitar 0's de los dos rubros
		
		IF v_idprocedenciarecurso IS NULL THEN
			LET v_idprocedenciarecurso = 23;
		END IF
		IF v_iddestinorecurso IS NULL THEN
			LET v_iddestinorecurso = 9;
		END IF
		
		-- GEOLOCALIZACION
		SELECT T.ciudad, T.cod_postal, T.estado, T.pais
		INTO v_ciudad, v_cp, v_estado_geo, v_ipaisgeo
		FROM
		(
			SELECT FIRST 1 ciudad, cod_postal, estado, pais
			FROM bdinteg:si_direcciones_actual
			WHERE numcte = v_nic
			AND tipo_dir = '1'
			ORDER BY secuencia DESC
		) AS T;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE ciudad = v_ciudad
		AND estado = v_estado_geo;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado_geo = 0) OR (v_estado_geo IS NULL) THEN
			LET v_estado_geo = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF
		
		---Realizar conteo de registros y guardar en v_conteocliente
		
		LET vconteo = vconteo + 1;
		LET vpaso = 16;
		--INSERTA LOS VALORES EN LOS PARAMETROS DE LA TABLA DE PASO.
		INSERT INTO "informix".tbl_cliente_minds (idregistro,idtipopersona,idprocedenciarecurso,iddestinorecurso,idactividadeconomica,idsexo,idnacionalidad,idpaisnacimiento,idestadonacimiento,
												nic,nombreorazons,apaterno,amaterno,fechanacconstitucion,rfc,curp,email,fecharegistro,fideicomiso,
												noempleado,aliassucursal,idfuentesingreso,fechamodificacion,idpaisnacionalidad,activo,fechaactualizacion,idestatuscargaminds,
												idpaisasignacionfiscal,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_idtipopersona,v_idprocedenciarecurso,v_iddestinorecurso,v_idactividadeconomica,v_idsexo,v_idnacionalidad1,v_idpaisnacimiento,v_idestadonacimiento,
				v_nic,v_nombreorazons,v_apaterno,v_amaterno,v_fechanacconstitucion,v_rfc,v_curp,v_email,v_fecharegistro,v_fideicomiso,
				v_noempleado,v_aliassucursal,v_idfuentesingreso,v_fechaactualizacion,v_idpaisnacionalidad,v_activo,v_fechaactualizacion,v_idestatuscargaminds,
				v_idpaisasignacionfiscal,v_plaza,v_ciudad,v_estado_geo,v_cp,v_paisgeo);
				
		LET vpaso = 17;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			let vcommit = 0;			
		END IF	
		
	END FOREACH;
	
	LET vpaso = 18;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF	
	
	LET vpaso = 19;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CLIENTES
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTE||'.txt select * FROM bdiauditor:tbl_cliente_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTE||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 20;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTE||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTE||'_01.sql';
	system vsql;
	
	LET vpaso = 21;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTE||'_01.sql';
	system vsql;
	
	
	LET vpaso = 22;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTE);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscliente_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 22/08/2019',
'DESCRIPCION: Generación de información clientes para sistemas MINDS PLD',
'BD: bdiauditor',
'AUTOR: Fernando Torres Soto',
'FECHA: 26/12/2022',
'DESCRIPCION: Se agrega los campos correspondietnes al requerimiento de geolocalizacion',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindscuenta_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(50);

--VARIABLE LAYOUT CUENTA
DEFINE v_nic					CHAR(20);
DEFINE v_nocuenta				CHAR(20);
DEFINE v_fechaapertura			CHAR(10);
DEFINE v_clavemoneda 			INTEGER;
DEFINE v_activo					INTEGER;
DEFINE v_clabe					CHAR(18);
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_idpropositocuenta		CHAR(2);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_idplazopago			INTEGER;
DEFINE v_total_cr_amt			DECIMAL(18,2);
DEFINE v_fechavencimiento		CHAR(10);
DEFINE v_monto_aportacion		DECIMAL(18,2);
DEFINE vconteo					INTEGER;
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_sucursal				CHAR(5);
DEFINE v_estado					INTEGER;
DEFINE v_ciudad					INTEGER;
DEFINE v_cp						CHAR(5);
DEFINE v_plaza					INTEGER;
DEFINE v_ipaisgeo				CHAR(3);
DEFINE v_paisgeo				CHAR(2);

--VARIABLES DE PASO
DEFINE v_status					CHAR(2);
DEFINE temp_fechaapertura		DATE;
DEFINE temp_fechavencimiento	DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE v_opinternacional		CHAR(1);
DEFINE cVenMon					DECIMAL(18,2);

--SE INICIALIZAN VARIABLES
LET v_activo = 0;
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_monto_aportacion = 0;
LET v_clavemoneda = 1;
LET v_opinternacional = 0;
LET cVenMon = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscuenta_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscuenta_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscliente_his.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaCtaMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cuenta_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		--bdicheq:sc_maenoc noc es el detalle bienen datos de la cuenta , bdicheq:sc_maechq chq informacion de saldos 
		SELECT chq.num_cte,chq.cuenta,chq.status_cta,chq.cuenta_clabe,chq.proced_mantenercta,noc.fecha_alta,chq.sucursal
		INTO v_nic,v_nocuenta,v_status,v_clabe,v_idpropositocuenta,temp_fechaapertura,v_sucursal
		FROM bdicheq:sc_maechq chq, bdicheq:sc_maenoc noc, bdinteg:si_cliente cli
		WHERE chq.cuenta = noc.cuenta
		AND chq.producto <> '1100' -- NO TRAER INVERSION CRECIENTE
		AND cli.numcte = chq.num_cte
		AND cli.tipo_cliente = '1'
		AND noc.fecha_alta = v_fecha_ant
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		IF v_status = '1' THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		IF (v_idpropositocuenta IS NULL) or (v_idpropositocuenta = '') THEN
			LET v_idpropositocuenta = 5;
		ELSE
			LET v_idpropositocuenta = v_idpropositocuenta::INTEGER;
		END IF
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF
		
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 6;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,clavemoneda,opinternacional,activo,clabe,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_clavemoneda,v_opinternacional,v_activo,v_clabe,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 7;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF	
		
	END FOREACH
	
	LET vpaso = 8;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 9;
	
	FOREACH WITH HOLD
		--bdicred:sd_maecred tabla creditos
		SELECT sd.numcte,sd.num_credito,sd.fecha_apertura,sd.fecha_vencim,sd.divisa,sd.status_cred,sd.plazo,sd.sucursal
		INTO v_nic,v_nocuenta,temp_fechaapertura,temp_fechavencimiento,v_clavemoneda,v_status,v_idplazopago,v_sucursal
		FROM bdicred:sd_maecred sd, bdinteg:si_cliente cli
		WHERE sd.numcte = cli.numcte
		AND cli.tipo_cliente = '1'
		AND fecha_apertura = v_fecha_ant
		
		LET cVenMon = 0;
		LET vpaso = 10;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
	
		LET vpaso = 11;
		
		SELECT monto_otorgado,monto_reservado, NVL(monto_vencido + mto_venc_trasp,0)
		INTO v_total_cr_amt,v_monto_aportacion, cVenMon
		FROM bdicred:sd_maesdos
		WHERE num_credito = v_nocuenta;

		IF v_status IN ('AM','AA','AC','AE','AR','E1') AND cVenMon = 0 THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF

		
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechavencimiento = to_char(temp_fechavencimiento, '%Y-%m-%d');
		LET v_monto_aportacion = NVL(v_monto_aportacion,0);
		LET vconteo = vconteo + 1;
		LET v_idpropositocuenta = 5; 
		
		LET vpaso = 12;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,fechavencimiento,clavemoneda,opinternacional,activo,total_cr_amt,idplazopago,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_fechavencimiento,v_clavemoneda,v_opinternacional,v_activo,v_total_cr_amt,v_idplazopago,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 13;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	
	END FOREACH
	
	LET vpaso = 14;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 15;
	
	FOREACH WITH HOLD
		SELECT crd.numcte,crd.num_credito,crd.fecha_apertura,crd.fecha_vencim,crd.divisa,crd.status_cred,crd.plazo,crd.sucursal
		INTO v_nic,v_nocuenta,temp_fechaapertura,temp_fechavencimiento,v_clavemoneda,v_status,v_idplazopago,v_sucursal
		FROM bdicred:sd_maecredcrd crd, bdinteg:si_cliente cli
		WHERE cli.numcte = crd.numcte
		AND cli.tipo_cliente = '1'
		AND fecha_apertura = v_fecha_ant
		
		LET cVenMon = 0;
		LET vpaso = 16;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		SELECT monto_otorgado,monto_reservado,NVL(monto_vencido + mto_venc_trasp,0)
		INTO v_total_cr_amt,v_monto_aportacion,cVenMon
		FROM bdicred:sd_maesdoscrd
		WHERE num_credito = v_nocuenta;
		
		IF v_status IN ('AM','AA','AC','AE','AR','E1') AND cVenMon = 0 THEN
			LET v_activo = '1';
		ELSE
			LET v_activo = '0';
		END IF
		
		LET vpaso = 17;
		
		-- GEOLOCALIZACION
		SELECT estado, ciudad, d_codigo, pais
		INTO v_estado, v_ciudad, v_cp, v_ipaisgeo
		FROM bdinteg:si_sucursales
		WHERE sucursal = v_sucursal;
		
		IF ( v_ipaisgeo IS NULL) THEN
			LET v_ipaisgeo = '';
		END IF
		
		SELECT clave_pais
		INTO v_paisgeo
		FROM bdinteg:si_paises
		WHERE pais = v_ipaisgeo;
		
		SELECT localidad_banxico::INTEGER
		INTO v_plaza
		FROM bdinteg:si_ciudades
		WHERE estado = v_estado 
		AND ciudad = v_ciudad;
		
		IF(v_plaza = 0) OR (v_plaza IS NULL) THEN
			LET v_plaza = 99999999;
		END IF
	
		IF(v_ciudad = 0) OR (v_ciudad IS NULL) THEN
			LET v_ciudad = 99999999;
		END IF
	
		IF(v_estado = 0) OR (v_estado IS NULL) THEN
			LET v_estado = 99999999;
		END IF
	
		IF(v_cp = '') OR (v_cp IS NULL) THEN
			LET v_cp = '00000';
		END IF
		
		IF (v_paisgeo IS NULL) OR (v_paisgeo = '') THEN
			LET v_paisgeo = 'ZZ';
		END IF
	
		LET v_fechaapertura = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fechaapertura, '%Y-%m-%d');
		LET v_fechavencimiento = to_char(temp_fechavencimiento, '%Y-%m-%d');
		LET v_monto_aportacion = NVL(v_monto_aportacion,0);
		LET vconteo = vconteo + 1;
		LET v_idpropositocuenta = 5; 
		
		LET vpaso = 18;
		
		INSERT INTO "informix".tbl_cuenta_minds (idregistro,nic,nocuenta,fechaapertura,fechavencimiento,clavemoneda,activo,total_cr_amt,idplazopago,fechaactualizacion,idestatuscargaminds,idpropositocuenta,fecharegistro,monto_aportacion,idplaza,idciudadsepomex,idestado,cp,paisgeo)
		VALUES (vconteo,v_nic,v_nocuenta,v_fechaapertura,v_fechavencimiento,v_clavemoneda,v_activo,v_total_cr_amt,v_idplazopago,v_fechaactualizacion,v_idestatuscargaminds,v_idpropositocuenta,v_fecharegistro,v_monto_aportacion,v_plaza,v_ciudad,v_estado,v_cp,v_paisgeo);	
		
		LET vpaso = 19;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	
	END FOREACH
	
	LET vpaso = 20;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 21;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * FROM bdiauditor:tbl_cuenta_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 22;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 23;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 24;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscuenta_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 11/09/2019',
'DESCRIPCION: Generación de información cuentas para sistemas MINDS PLD',
'BD: bdiauditor',
'AUTOR: Fernando Torres Soto',
'FECHA: 26/12/2022',
'DESCRIPCION: Se agrega los campos correspondietnes al requerimiento de geolocalizacion',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_chq_crg_xml_head()
RETURNING	CHAR(08)	AS	cod_ret 		 ,
			CHAR(120)	AS	mensaje			 ,
			CHAR(10)	AS	vercion 		 ,
			CHAR(06)	AS	org_regulador	 ,
			CHAR(06)	AS	cve_entidad		 ;
			
			
--variables de retorno
	DEFINE	cod_ret			CHAR(08); 		
	DEFINE	mensaje			CHAR(80);
	DEFINE	vvercion 		CHAR(10);
	DEFINE	vorg_regulador	CHAR(06);
	DEFINE	vcve_entidad	CHAR(06);
	
	
--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER; 	
	
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			RETURN 	 cod_ret
					,'iIsamErr: '|| iIsamErr || 'vErrorInfo: sp_pld_chq_crg_xml_head ' || vErrorInfo || ' En paso: ' || vpaso 
					,""
					,""
					,""
			;
			
		END IF;
	END EXCEPTION;

	--inicializciÃ³n de variables
	LET cod_ret			='00000000';
	LET	mensaje			='PROCESO EXITOSO';
	LET	vvercion		='';
	LET	vorg_regulador	='';
	LET	vcve_entidad	='';
	
	SET ISOLATION TO DIRTY READ;
	
	LET vpaso =1;
	
	--obtenemos la verciÃ³n
	SELECT valor INTO vvercion FROM param WHERE llave = 'VERSION_XML';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		LET	vvercion = '1.0';
	END IF
	
	LET vpaso =2;
	--obtenemos el organismo regulador
	SELECT valor INTO vorg_regulador FROM param WHERE llave = 'CVE_ORGANO_REGULADOR';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000002','NO SE ENCONTRO EL ORGANISMO REGULADOR EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF

	LET vpaso =3;
	--obtenemos la clave de la entidad
	SELECT valor INTO vcve_entidad FROM param WHERE llave = 'CVE_ENTIDAD';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000003','NO SE ENCONTRO LA CLAVEDE LA ENTIDAD EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF
	
	RETURN cod_ret,mensaje,vvercion,vorg_regulador,vcve_entidad;
	
END
END PROCEDURE	
	
	;