CREATE PROCEDURE "informix".sp_busca_aclaraciones_gerente(p_NumEmpleado CHAR(10))
 RETURNING 
    CHAR(15) AS pky_aclaracion,
    CHAR(15) AS folio_csuac,
    CHAR(62) AS nombre_promotor,
    CHAR(15) AS num_promotor,
    CHAR(15) AS fecha_vencimiento;

DEFINE resultado_pky_aclaracion CHAR(10);
DEFINE resultado_folio_csuac CHAR(10);
DEFINE resultado_nombre CHAR(60);
DEFINE resultado_numero_emp_promotor CHAR(10);
DEFINE resultado_fechacaptura DATE;


DEFINE resultado_dias_vencimiento INTEGER;
DEFINE resultado_fecha_vencimiento DATE;

    FOREACH
        select distinct aclaclaracion.pky_aclaracion,aclaclaracion.folio_csuac,usuarios.nombre,
		aclcontrol.numero_emp_promotor,aclaclaracion.fechacaptura
        into resultado_pky_aclaracion,resultado_folio_csuac,resultado_nombre,
        resultado_numero_emp_promotor,resultado_fechacaptura
		from 
		informix.acl_control_aclaracion_tel aclcontrol, 
		informix.acl_aclaracion aclaclaracion,  
		informix.acl_estatus_corporativo aclestatuscorp, 
		informix.acl_opcion_cliente aclopcionclie,
		bdinteg:si_ejecut as usuarios
		where aclcontrol.fky_aclaracion=aclaclaracion.pky_aclaracion  
		and aclestatuscorp.pky_estatus_corporativo=aclaclaracion.fky_estatus_corp_analisis 
		and aclopcionclie.pky_opcion_cliente=aclcontrol.fky_opcion_cliente 
		and aclcontrol.numero_emp_gerente=p_NumEmpleado 
		and aclestatuscorp.nombre='CIERRE_EN_PROCESO' 
		and aclaclaracion.fky_cat_tipo_aclaracion='2' 
		and aclopcionclie.nombre='VIA_EJECUTIVO' 
		and aclcontrol.acl_leida_gerente='0' 
		and usuarios.ejecutivo=aclcontrol.numero_emp_promotor

        select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';

        LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;
                 
        return resultado_pky_aclaracion|| '*',resultado_folio_csuac|| '*',resultado_nombre|| '*',
               resultado_numero_emp_promotor|| '*',resultado_fecha_vencimiento|| '*' with resume;
    END FOREACH;
END PROCEDURE

DOCUMENT
'Sp sp_busca_aclaraciones_gerente',
'Busca las aclaraciones que tiene asignadas el gerente',
'Sistema: Aclaraciones',
'AUTOR : Rodolfo Velazquez',
'Area: Sucursales',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 26/Octubre/2017',
'VERSION: 1.0.0';

CREATE PROCEDURE "informix".sp_busca_aclaraciones_promotor(p_NumEmpleado CHAR(10))
 RETURNING 
    CHAR(15) AS pky_aclaracion,
    CHAR(15) AS folio_csuac,
    CHAR(15) AS fecha_vencimiento;

DEFINE resultado_pky_aclaracion CHAR(10);
DEFINE resultado_folio_csuac CHAR(10);
DEFINE resultado_fechacaptura DATE;


DEFINE resultado_dias_vencimiento INTEGER;
DEFINE resultado_fecha_vencimiento DATE;

    FOREACH
        select distinct aclaclaracion.pky_aclaracion,aclaclaracion.folio_csuac,aclaclaracion.fechacaptura
        into resultado_pky_aclaracion,resultado_folio_csuac,resultado_fechacaptura
		from 
		informix.acl_control_aclaracion_tel aclcontrol, 
		informix.acl_aclaracion aclaclaracion,  
		informix.acl_estatus_corporativo aclestatuscorp, 
		informix.acl_opcion_cliente aclopcionclie
		where aclcontrol.fky_aclaracion=aclaclaracion.pky_aclaracion  
		and aclestatuscorp.pky_estatus_corporativo=aclaclaracion.fky_estatus_corp_analisis 
		and aclopcionclie.pky_opcion_cliente=aclcontrol.fky_opcion_cliente 
		and aclcontrol.numero_emp_promotor=p_NumEmpleado 
		and aclestatuscorp.nombre='CIERRE_EN_PROCESO' 
		and aclaclaracion.fky_cat_tipo_aclaracion='2' 
		and aclopcionclie.nombre='VIA_EJECUTIVO' 
		and aclcontrol.acl_leida_promotor='0' 
		and aclcontrol.fky_aclaracion=aclaclaracion.pky_aclaracion



        select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';

        LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;
                 
        return resultado_pky_aclaracion|| '*',resultado_folio_csuac|| '*',resultado_fecha_vencimiento|| '*' with resume;
    END FOREACH;
END PROCEDURE

DOCUMENT
'Sp sp_busca_aclaraciones_promotor',
'Busca las aclaraciones que tiene asignadas el promotor',
'Sistema: Aclaraciones',
'AUTOR : Rodolfo Velazquez',
'Area: Sucursales',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 26/Octubre/2017',
'VERSION: 1.0.0';

CREATE PROCEDURE "informix".sp_buscaempleadohuella (p_sNumeroEmpleado CHAR(8), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(45) AS nombreEmpleado,  CHAR(3) AS puesto, CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad, CHAR(20) AS nombramiento

	-- Definicion de variables
	DEFINE resultado_nombreEmpleado     CHAR(45);
	DEFINE resultado_puesto             CHAR(3);
	DEFINE resultado_sucursal           CHAR(5);
	DEFINE resultado_nombreSucursal 	CHAR(40);
	DEFINE resultado_nombreEstado 		CHAR(30);
	DEFINE resultado_nombreCiudad		CHAR(60);
	DEFINE resultado_nombramiento		CHAR(20);
    DEFINE iSqlErr                  	INTEGER;
	
	DEFINE v_activo 			        SMALLINT;
	
    -- Inicialización de las variables.
	LET resultado_nombreEmpleado 		= '';
	LET resultado_puesto 				= '';
	LET resultado_sucursal 				= '';
	LET resultado_nombreSucursal 		= '';
	LET resultado_nombreEstado 			= '';
	LET resultado_nombreCiudad 			= '';
	LET resultado_nombramiento 			= '';

	LET v_activo 			   			= '';
	
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Validación de usuarios no registrados 06/01/2013
-- Se agrega la validación para que no ingresen usuarios de corporativo no registrados en el sistema.
-- SADVC 
	
    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_nombreEmpleado = '';
				LET resultado_puesto = '';
				LET resultado_sucursal = '';
				LET resultado_nombreSucursal = '';
				LET resultado_nombreEstado = '';
				LET resultado_nombreCiudad = '';
				LET resultado_nombramiento = '';
			
				RETURN resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento;

			END IF;

        END EXCEPTION;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Se agrega validación para usuarios no permitidos / registrados.
-- validación que se encuentren en la BD de aclaraciones y que pertenezcan a una sucursal.
-- SADVC 
	
	SELECT activo
		INTO v_activo
	FROM acl_usuario 
	WHERE num_empleado = p_sNumeroEmpleado;
		
	IF (v_activo = 1) THEN 
		
		SELECT FIRST 1 eje.nombre, eje.puesto, eje.sucursal, suc.nombre as nombresucursal, 
				nvl(edo.nombre,'') as estado, nvl(ciu.nombre,'') as ciudad, eje.nombramiento
			INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, 
				resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento
		FROM bdinteg:si_ejecut eje
			INNER JOIN bdinteg:si_ptf sp ON eje.sucursal = sp.id_ptf and sp.tipo ='I'--> Busca a nivel Administrativo
			INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf
			LEFT OUTER JOIN bdinteg:si_ciudades ciu on sp.cve_ciudad = ciu.ciudad
			LEFT OUTER JOIN bdinteg:si_estados edo on sp.cve_estado = edo.estado
		WHERE eje.ejecutivo = p_sNumeroEmpleado
			 AND eje.empresa = p_sNumeroEmpresa 
			 AND password <> "BAJA";
		
		IF (resultado_nombreEmpleado is null or resultado_nombreEmpleado = '') THEN
			SELECT FIRST 1 eje.nombre, eje.puesto, eje.sucursal, suc.nombre as nombresucursal, 
					nvl(edo.nombre,'') as estado, nvl(ciu.nombre,'') as ciudad, eje.nombramiento
				INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, 
					resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento
			FROM bdinteg:si_ejecut eje
				INNER JOIN bdinteg:si_ptf sp ON eje.sucursal = sp.id_ptf and sp.tipo = 'S'--> Busca a nivel Sucursal
				INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf
				LEFT OUTER JOIN bdinteg:si_ciudades ciu on sp.cve_ciudad = ciu.ciudad
				LEFT OUTER JOIN bdinteg:si_estados edo on sp.cve_estado = edo.estado
			WHERE eje.ejecutivo = p_sNumeroEmpleado
				 AND eje.empresa = p_sNumeroEmpresa 
				 AND password <> "BAJA";
		END IF;
	
	ELSE 
	
		SELECT FIRST 1 eje.nombre, eje.puesto, eje.sucursal, suc.nombre as nombresucursal, 
				nvl(edo.nombre,'') as estado, nvl(ciu.nombre,'') as ciudad, eje.nombramiento
			INTO resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, 
				resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento
		FROM bdinteg:si_ejecut eje
			INNER JOIN bdinteg:si_ptf sp ON eje.sucursal = sp.id_ptf and sp.tipo = 'S'--> ValidaciÃ³n de la sucursal
			INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf
			LEFT OUTER JOIN bdinteg:si_ciudades ciu on sp.cve_ciudad = ciu.ciudad
			LEFT OUTER JOIN bdinteg:si_estados edo on sp.cve_estado = edo.estado
		WHERE eje.ejecutivo = p_sNumeroEmpleado
			 AND eje.empresa = p_sNumeroEmpresa 
			 AND password <> "BAJA";
	 
	 
	 END IF;
	 
	 RETURN resultado_nombreEmpleado, resultado_puesto, resultado_sucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad, resultado_nombramiento;

	END

END PROCEDURE
DOCUMENT
'Sp			:	sp_buscaempleadohuella',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Modificacion	:	Bancoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	13/Marzo/2018',
'VERSION		: 	2.0.0',
'BD			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_datos_sucursal_numero (p_numeroSuc CHAR(5), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(5) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad;

	--definicion de variables--
	DEFINE resultado_numeroSucursal 	CHAR(5);
    DEFINE resultado_nombreSucursal		CHAR(40);
    DEFINE resultado_nombreEstado		CHAR(30);
    DEFINE resultado_nombreCiudad		CHAR(60);
    DEFINE iSqlErr                     	INTEGER;

     -- Inicialización de las variables.
	LET resultado_numeroSucursal = '';
	LET resultado_nombreSucursal = '';
	LET resultado_nombreEstado = '';
	LET resultado_nombreCiudad = '';

    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_numeroSucursal = '';
				LET resultado_nombreSucursal = '';
				LET resultado_nombreEstado = '';
				LET resultado_nombreCiudad = '';
				RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad;
			END IF;
		END EXCEPTION;

		SELECT DISTINCT suc.sucursal, suc.nombre, '' as estado, '' as ciudad
	        INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad
		FROM bdinteg:si_sucursales suc
		WHERE suc.empresa = p_sNumeroEmpresa AND sucursal = p_numeroSuc;

		RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad WITH RESUME;

	END
END PROCEDURE
DOCUMENT
'Sp			:	sp_consulta_datos_sucursal_numero',
'Sistema		:	Aclaraciones',
'AUTOR			:	Bancoppel',
'Area			:	Sistemas Administrativos y Perifericos',
				'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	13/Marzo/2018',
'VERSION		: 	1.0.0',
'BD			:	bdiaclaracion';

CREATE PROCEDURE  "informix".sp_busqueda_nombres_de_sucursales (p_NumCte CHAR(30))

RETURNING  CHAR(11) AS numero_sucursal, CHAR(76) AS nombre_sucursal, CHAR(300) AS direccion;

DEFINE resultado_nombre_sucursal        CHAR(75);
DEFINE resultado_numero_sucursal        CHAR(10);
DEFINE resultado_direccion_suc          CHAR(100);
DEFINE resultado_direccion2             CHAR(100);

--Búsqueda de Clientes por Código Postal
IF ((SELECT COUNT (suc.sucursal)
		FROM bdinteg:si_sucursales AS suc
            Inner Join bdinteg:si_ptf sp on suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
                AND suc.d_codigo = sp.cp
            Left Outer Join bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
                AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
    	WHERE suc.tpo_sucursal = 'S'
			AND suc.d_codigo = (select dir_act.cod_postal from bdinteg:si_direcciones_actual as dir_act
				WHERE dir_act.tipo_dir = '1' AND dir_act.numcte = (p_NumCte)))>0) THEN
	FOREACH
		SELECT suc.sucursal AS numero, trim(nvl(suc.nombre,'')) AS nombre, trim(nvl(sp.calle,'SIN DIRECCION')) as direccion,
				trim(nvl(UPPER('COL ' || sl.desc_colonia || ' CP ' || sp.cp),'SIN DIRECCION')) as direccion2
			INTO resultado_numero_sucursal,resultado_nombre_sucursal,resultado_direccion_suc,resultado_direccion2
		FROM bdinteg:si_sucursales AS suc
            Inner Join bdinteg:si_ptf sp on suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
                AND suc.d_codigo = sp.cp
            Left Outer Join bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
                AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
    	WHERE suc.tpo_sucursal = 'S'
			AND suc.d_codigo = (select dir_act.cod_postal from bdinteg:si_direcciones_actual as dir_act
				WHERE dir_act.tipo_dir = '1' AND dir_act.numcte = (p_NumCte))

		return resultado_numero_sucursal || '*'  , resultado_nombre_sucursal || '*' ,resultado_direccion_suc || '*' || resultado_direccion2 || '*' with resume;

	END FOREACH;
ELSE
	--Búsqueda de Clientes por Ciudad
	IF ((SELECT count(sp.id_ptf)
			FROM bdinteg:si_direcciones_actual usr
                INNER JOIN bdinteg:si_ptf sp ON usr.ciudad = sp.cve_ciudad AND usr.estado = sp.cve_estado
                INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
                LEFT OUTER JOIN bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
					AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
			WHERE sp.tipo = 'S' AND usr.tipo_dir = '1'
				AND usr.numcte = p_NumCte) > 0) THEN

		FOREACH
			SELECT suc.sucursal as numero, trim(nvl(suc.nombre,'')) as nombre, trim(nvl(sp.calle,'SIN DIRECCION')) as direccion,
                    trim(nvl(UPPER('COL ' || sl.desc_colonia || ' CP ' || sp.cp),'SIN DIRECCION')) as direccion2
				INTO resultado_numero_sucursal, resultado_nombre_sucursal,resultado_direccion_suc,resultado_direccion2
			FROM bdinteg:si_direcciones_actual usr
                INNER JOIN bdinteg:si_ptf sp ON usr.ciudad = sp.cve_ciudad AND usr.estado = sp.cve_estado
                INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
                LEFT OUTER JOIN bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
					AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
			WHERE sp.tipo = 'S' AND usr.tipo_dir = '1'
				AND usr.numcte = p_NumCte

			return resultado_numero_sucursal || '*'  , resultado_nombre_sucursal || '*' ,resultado_direccion_suc || '*' || resultado_direccion2 || '*' with resume;

		END FOREACH;
	ELSE
		--Búsqueda de Clientes por Estado
		IF ((SELECT count(sp.id_ptf)
				FROM bdinteg:si_direcciones_actual usr
					INNER JOIN bdinteg:si_ptf sp ON usr.estado = sp.cve_estado
					INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
					LEFT OUTER JOIN bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
						AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
				WHERE sp.tipo = 'S' AND usr.tipo_dir = '1'
					AND usr.numcte = p_NumCte) > 0) THEN

			FOREACH
				SELECT suc.sucursal as numero, trim(nvl(suc.nombre,'')) as nombre, trim(nvl(sp.calle,'SIN DIRECCION')) as direccion,
						trim(nvl(UPPER('COL ' || sl.desc_colonia || ' CP ' || sp.cp),'SIN DIRECCION')) as direccion2
					INTO resultado_numero_sucursal, resultado_nombre_sucursal,resultado_direccion_suc,resultado_direccion2
				FROM bdinteg:si_direcciones_actual usr
					INNER JOIN bdinteg:si_ptf sp ON usr.estado = sp.cve_estado
					INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf AND sp.tipo = suc.tpo_sucursal
					LEFT OUTER JOIN bdinteg:si_localidades sl ON sp.cp= sl.cp AND sp.cve_estado = sl.cve_estado
						AND sp.cve_mun = sl.cve_mun AND sp.cve_localidad = sl.cve_localidad_cnbv AND sp.cve_col=sl.cve_col
				WHERE sp.tipo = 'S' AND usr.tipo_dir = '1'
					AND usr.numcte = p_NumCte

				return resultado_numero_sucursal || '*' , resultado_nombre_sucursal || '*', resultado_direccion_suc || '*' || resultado_direccion2 || '*' with resume;

			END FOREACH;

		END IF
	END IF
END IF
END PROCEDURE
DOCUMENT
'Sp			:	sp_busqueda_nombres_de_sucursales',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Modificacion	:	Bancoppel',
'Area			:	Sistemas Administrativos y Perifericos',
				'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	13/Marzo/2018',
'VERSION		: 	2.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_cargo_recurrente(p_num_tarjeta CHAR(16), p_folio_suc char(15))
     RETURNING  VARCHAR (4) AS cCodRet, --Salida de codigo de retorno
                VARCHAR(2) AS  indicador_recurrente; -- Salida de indicador de cargo recurrente
    --definicion de variables-- 
    DEFINE ind_cargo_rec CHAR(2); 
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(3); 
    DEFINE indicador_recurrente CHAR (2);
    DEFINE esBinCredito INTEGER;
--  Inicializacion de las variables.
    LET cCodRet = '000';
    LET esBinCredito=0;
    LET indicador_recurrente = 'F';

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET ind_cargo_rec = '';
                RETURN iSqlErr,ind_cargo_rec;
            END IF;
        END EXCEPTION;
        LET esBinCredito = (SELECT count (bin) FROM intercard:bines b WHERE b.bin = SUBSTR (p_num_tarjeta, 1, 6) and b.creditodebito = 'C');
	    IF esBinCredito = 1 THEN 
             IF EXISTS (SELECT * FROM intercard:movimiento
	                    WHERE numtarjeta = p_num_tarjeta
	                    AND secuenciaextendida = p_folio_suc
	                    AND fechahorainauthj between today-90 and today
	                    AND prodind = '02' 
	                    AND tipotransaccionposdigitada  = 'CA' 
	                    AND codigoiso = '00' 
	                    AND movconciliado = 'V' 
	                    AND codreversa = '0' 
	                    AND movreversado = 'F')
	         THEN 
	            LET indicador_recurrente = 'V';
	         ELSE IF EXISTS (SELECT * FROM intercard:movimientohistorico
	                        WHERE numtarjeta = p_num_tarjeta
	                        AND secuenciaextendida = p_folio_suc
 	                        AND fechahorainauthj between today-90 and today
	                        AND prodind = '02' 
	                        AND tipotransaccionposdigitada  = 'CA'
	                        AND codigoiso = '00' 
	                        AND movconciliado = 'V' 
	                        AND codreversa = '0' 
	                        AND movreversado = 'F') 
	            THEN
	                 LET indicador_recurrente = 'V';
	            END IF;
	         END IF;
           END IF;
        return  cCodRet||',',indicador_recurrente;
    END;
END PROCEDURE;