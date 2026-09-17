CREATE PROCEDURE "informix".sp_soe_consultacatoperaciones(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS id_operacion,
				  CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCatOperacion INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCatOperacion = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCatOperacion, cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultacatoperaciones.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCatOperacion, UPPER(cDescripcion);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iCatOperacion, UPPER(cDescripcion);
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		FOREACH SELECT id_cat_oper, desc_oper 
			INTO iCatOperacion, cDescripcion FROM bdibei:"informix".bei_cat_operaciones 
				WHERE activo = 't'
				RETURN cCodRet, iCatOperacion, UPPER(cDescripcion) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, iCatOperacion, UPPER(cDescripcion);
		ELIF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCatOperacion, UPPER(cDescripcion);
		END IF;
		RETURN cCodRet, iCatOperacion, UPPER(cDescripcion);
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/12/2014',
'DESCRIPCION: Consulta catalogo de operaciones, el cual retorna un cÃ³digo y una descripcion del mismo para la generacion de reporte de actividades en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_obt_direcciones_cliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pTipoDir CHAR(1))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS pcTipoDir,
		CHAR(20) AS cDescTipoDir, 
		CHAR(40) AS cCalle, 
		CHAR(10) AS cNumExt, 
		CHAR(10) AS cNumInt, 
		CHAR(60) AS cColonia, 
		CHAR(100)AS cMunDel, 
		CHAR(30) AS cEstado, 
		CHAR(5)  AS cCp, 
		CHAR(80) AS cObservaciones;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCalle CHAR(40);
	DEFINE cNumInt CHAR(10);
	DEFINE cNumExt CHAR(10);
	DEFINE cColonia CHAR(60);
	DEFINE cMunDel CHAR(100);
	DEFINE cEstado	CHAR(30);
	DEFINE cCp CHAR(5);
	DEFINE cObservaciones CHAR(80);
	DEFINE cDescTipoDir CHAR(20);
	DEFINE Cmensaje CHAR (100);
	DEFINE cSecuencia CHAR (1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCalle = '';
	LET cNumInt = '';
	LET cNumExt = '';
	LET cColonia = '';
	LET cMunDel = '';
	LET cEstado	 = '';
	LET cCp = '';
	LET cObservaciones = '';
	LET cDescTipoDir = '';
	LET Cmensaje = '';
	LET cSecuencia = ''; 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, pTipoDir, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obt_direcciones_cliente.out';
		--TRACE ON;
		
		--IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pTipoDir = '' THEN
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, pTipoDir, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, pTipoDir, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
		END IF;
		
		--VALIDA QUE EL CLIENTE EXISTA
		IF EXISTS(SELECT {+ INDEX (bdinteg:"informix".si_direcciones_actual.idx_diract_cte)} numcte FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte)THEN
				IF EXISTS(SELECT {+ INDEX (bdinteg:"informix".si_direcciones_actual.idx_diract_cte)} numcte FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte AND tipo_dir = '1') THEN
				SELECT tdr.desc_tipo_dir, ca.nombrecalle, dr.numeroextcalle, dr.numerointcalle, zo.nombrezona, cd.nombre, 
						es.nombre, dr.cod_postal, dr.observaciones, dr.secuencia::char
				INTO cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones, cSecuencia
				FROM bdinteg:"informix".si_direcciones_actual dr
				INNER JOIN bdinteg:"informix".si_cat_tipo_direcciones tdr ON dr.tipo_dir = tdr.tipo_dir
				INNER JOIN bdinteg:"informix".si_estados es ON dr.estado = es.estado
				INNER JOIN bdinteg:"informix".si_ciudades cd ON dr.ciudad = cd.ciudad AND dr.estado = cd.estado
				INNER JOIN bdinteg:"informix".si_catcalles ca ON dr.numerocalle =  ca.numerocalle
				INNER JOIN bdinteg:"informix".si_catzonas zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia AND
				dr.numcte = pNumCte AND dr.tipo_dir = '1';
				--dr.numcte = pNumCte AND dr.tipo_dir = pTipoDir;
				RETURN cCodRet, cSecuencia, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
			ELSE
				LET cCodRet = '00080'; --EL CLIENTE NO TIENE DOMICILIO DE TRABAJO
				RETURN cCodRet, cSecuencia, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
			END IF;
		ELSE
			LET cCodRet = '00022'; --El NUMERO DE CLIENTE NO EXISTE
			RETURN cCodRet, cSecuencia, cDescTipoDir, cCalle, cNumExt, cNumInt, cColonia, cMunDel, cEstado, cCp, cObservaciones;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 30/10/2014',
'DESCRIPCION: Obtiene las direcciones de trabajo de un cliente registrado en EmpresaNet SOE ',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_cons_disp_manco_orden_pago_bei(pIdOperacion INTEGER)
RETURNING CHAR(5), CHAR(10), CHAR(20), CHAR(17), CHAR(10), CHAR(20),
        CHAR(3), CHAR(4), INTEGER, INTEGER, INTEGER, INTEGER,INTEGER,    
        SMALLINT, SMALLINT,MONEY(14,2),INTEGER,CHAR(30),INTEGER, DECIMAL(18,2),
        DECIMAL(18,2), MONEY(14,2), MONEY(14,2), MONEY(14,2);

    
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vf_aplicacion       CHAR(10);
    DEFINE vcuenta_origen      CHAR(20);        
    DEFINE vnombre_archivo     CHAR(17);
    DEFINE vf_dispersion       CHAR(10);
    DEFINE vcte_empresa        CHAR(20);
    DEFINE vid_empresa         CHAR(3);  
    DEFINE vid_oper            CHAR(4);
    DEFINE vid_catOperacion    INTEGER;
    DEFINE vid_usuario         INTEGER;
    DEFINE vtamano_archivo     INTEGER;
    DEFINE vtipo_archivo       INTEGER;
    DEFINE vtipo_cuentas       INTEGER;   
    DEFINE vtipo_oper          SMALLINT;
    DEFINE vstatus_archivo     SMALLINT;
    DEFINE vmontoTotal         MONEY(14,2);
	DEFINE vCantidadEmpleados	INTEGER;
	DEFINE vConcepto			CHAR(30);
	DEFINE vTipoDispersion		INTEGER;	
	DEFINE vcargoDispersion     DECIMAL(18,2);
	DEFINE vtotalSinComision	DECIMAL (18,2);
    DEFINE vComsion             MONEY(14,2);	
	DEFINE viva                 MONEY(14,2);
	DEFINE vivaComsion			MONEY(14,2);


    LET cCod_ret = '00000';
    LET vf_aplicacion = TODAY;
    LET vcuenta_origen = '';
    LET vnombre_archivo = '';
    LET vf_dispersion = TODAY;
    LET vcte_empresa = '';
    LET vid_empresa = '';
    LET vid_oper = '';
    LET vid_catOperacion = 0;
    LET vid_usuario = 0;
    LET vtamano_archivo = 0;
    LET vtipo_archivo = 0;
    LET vtipo_cuentas = 0;
    LET vtipo_oper = 0;
    LET vstatus_archivo = 0;
    LET vmontoTotal = 0;
    LET vCantidadEmpleados	= 0;
	LET vConcepto			= '';
	LET vTipoDispersion		= 0;
	LET vcargoDispersion	= 0;
	LET vtotalSinComision	= 0;
    LET vComsion = 0;
    LET viva        = 0;
    LET vivaComsion = 0;
  ---------------------------------------------------
	-- 06 Junio 2014 
	-- Se actualiza para manejo de formatos de fecha --
  ---------------------------------------------------

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
                vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
                vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
                vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
                vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
                viva,vivaComsion;
      END IF ;
    END EXCEPTION ;

     SELECT to_char(f_aplicacion,"%iY-%m-%d") as f_aplicacion, cuenta_origen, archivos.nombre_archivo, to_char(f_dispersion,"%iY-%m-%d") as f_dispersion,
            cte_empresa, id_empresa, id_oper, id_cat_operacion, 
            operacionesmancomunadasoperador.id_usuario, tamano_archivo, 
            tipo_archivo, tipo_cuentas, tipo_oper, status_archivo, montoTotal,
			cantidadEmpleados, referencia, tipoDispersion, cargoDispersion, totalSinComision,
            comision, valor_iva, ivacomision
     INTO vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
        vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
        vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
        vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
		vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
        viva,vivaComsion
    FROM "informix".bei_operacionesmancomunadasoperador AS operacionesmancomunadasoperador
       INNER JOIN "informix".bei_archivos_orden_pago AS archivos 
        ON (operacionesmancomunadasoperador.nombre_archivo = archivos.nombre_archivo AND
    operacionesmancomunadasoperador.id_cliente = archivos.cte_empresa)
    WHERE operacionesmancomunadasoperador.ID_OPERACION = to_char(pIdOperacion);

    RETURN cCod_ret, vf_aplicacion, vcuenta_origen, vnombre_archivo, vf_dispersion,
                vcte_empresa, vid_empresa, vid_oper, vid_catOperacion, vid_usuario,
                vtamano_archivo, vtipo_archivo, vtipo_cuentas, vtipo_oper,
                vstatus_archivo, vmontoTotal, vCantidadEmpleados, vConcepto,
                vTipoDispersion, vcargoDispersion,vtotalSinComision, vComsion,
                viva,vivaComsion;

END

END PROCEDURE;