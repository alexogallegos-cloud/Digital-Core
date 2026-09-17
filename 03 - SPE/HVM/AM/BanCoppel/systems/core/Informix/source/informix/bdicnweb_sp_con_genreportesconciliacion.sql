CREATE PROCEDURE "informix".sp_con_genreportesconciliacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING   CHAR(5)     AS codret,
            INTEGER     AS id_registro,
            CHAR(100)   AS   nombre_reporte,
            DATE        AS  fecha_reporte,
            DATETIME HOUR TO SECOND AS hr_reporte,
            CHAR(8)     AS usuario_insert,
            CHAR(1)     AS  estatus;


--=====DEFINICIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iRegistro INTEGER;
    DEFINE cNombreArchivo CHAR(100);
    DEFINE dFechaReporte DATE;
    DEFINE dHrReporte DATETIME HOUR TO SECOND;
    DEFINE cUsuario CHAR(8);
    DEFINE cEstatus CHAR(1);
    DEFINE iTotalRegistros INTEGER;


 --INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '';
    LET iSqlErr =  0;
    LET iRegistro = 0;
    LET cNombreArchivo = '0';
    LET dFechaReporte = '';
    LET dHrReporte = '';
    LET cUsuario = '';
    LET cEstatus = '';
    LET iTotalRegistros = 0;

    BEGIN
       ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
            RETURN cCodRet, iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_genreportesconciliacion.out';
		--TRACE ON;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus;
		END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
            RETURN cCodRet, iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion id_registro, nombre_reporte, fecha_reporte, hr_reporte, usuario_insert, estatus 
	        INTO iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus
            FROM "informix".sw_con_genreportesconciliacion
            WHERE usuario_insert = pUsuario

            LET iTotalRegistros = iTotalRegistros + 1;
            RETURN cCodRet, iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus WITH RESUME;
        END FOREACH;

        IF iTotalRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iRegistro, cNombreArchivo, dFechaReporte, dHrReporte, cUsuario, cEstatus;
        END IF;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 05/07/2023',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÃN ADMINISTRATIVA',
'DESCRIPCION: Consulta todos los reportes guardados en la tabla sw_con_genreportesconciliacion por usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_genreportesconciliacion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING   CHAR(5)     AS codret,
            INTEGER     AS totalRegistros;


--=====DEFINICIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iTotalRegistros INTEGER;


 --INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '';
    LET iSqlErr =  0;
    LET iTotalRegistros = 0;

    BEGIN
       ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
            RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_genreportesconciliacion_totales.out';
		--TRACE ON;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
            RETURN cCodRet, iTotalRegistros;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT COUNT(*)
        INTO iTotalRegistros
        FROM "informix".sw_con_genreportesconciliacion
        WHERE usuario_insert = pUsuario;

        IF iTotalRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTotalRegistros;
        END IF;

        RETURN cCodRet, iTotalRegistros;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 05/07/2023',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÃN ADMINISTRATIVA',
'DESCRIPCION: Consulta el numero total de reportes guardados en la tabla sw_con_genreportesconciliacion por usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificareportespendientesconcilacion(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificareportespendientesconcilacion.out';
		-- TRACE ON;
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select count (estatus) as filas 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_con_genreportesconciliacion WHERE usuario_insert = pUsuario and estatus ='0';
		
	    RETURN cCodRet,iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 06/07/2023',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: VERIFICA SI EL USUARIO TIENE REPORTES POR DESCARGAR --ESTATUS 0',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_consulta_casual_fraccion(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pCuenta CHAR(10), pNumcte CHAR(12))

RETURNING CHAR(5)  AS codret,
          INTEGER  AS id_casual,
          CHAR(40) AS causal_revision,
          CHAR(2)  AS id_fraccion ,
          CHAR(2)  AS concepto,
          CHAR(40) AS des_fraccion

    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE icasual   INTEGER;
    DEFINE cDesCasual CHAR(40);
    DEFINE cFraccion   CHAR(2);
    DEFINE cConcepto   CHAR(2);
    DEFINE cDesFraccion CHAR(40);
    DEFINE iRegistros  INTEGER;
    DEFINE cInversion     CHAR(10);
    DEFINE cArea       CHAR(2);
    DEFINE cDescripion CHAR(40);
    DEFINE cFecha      DATETIME YEAR TO FRACTION(3);
    DEFINE irowid      INTEGER;

    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cDesCasual  = '';
    LET cFraccion = '';
    LET cConcepto = '';
    LET cDesFraccion = '';
    LET icasual = 0;
    LET iRegistros = 0;
    LET cArea = '';
    LET cDescripion = '';
    LET cFecha = '';
    LET irowid = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_consulta_casual_fraccion.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
		END IF;

        EXECUTE PROCEDURE bdicnweb:"informix".sp_ipab_consultarea_usuario(pUsuario, pIdFuncion) 
        INTO cCodRet, cUsuario, cArea, cDescripion;

            IF cCodRet <> '00000' THEN
                LET cCodRet = '00981'; -- El usuario no tiene una area designada
			    RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
            END IF;
        --si el Ã¡rea es 3 Administracion y Finanzas 
        IF cArea = '3' THEN
            --Debera ver el ultimo registro del Area 2 Desarrollo Organizacional
            LET cArea = '2';
        END IF;

        SELECT COUNT(*) INTO iRegistros 
        FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
        WHERE clave_unica = pNumcte
        AND area = cArea;

        IF iRegistros > 0 THEN

            SELECT MAX(fecha_insert) INTO cFecha
            FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
            WHERE clave_unica = pNumcte AND area = cArea;

            SELECT FIRST 1 id_causal, causal_revision, fraccion, concepto
            INTO   icasual, cDesCasual, cFraccion, cConcepto
            FROM   bdinteg:"informix".si_ipab_marcaje_excluidos
            WHERE  clave_unica = pNumcte
            AND    area = cArea
            AND    fecha_insert = cFecha;
            
            SELECT (fraccion || ' ' || concepto || ' ' ||descripcion) AS des_fraccion
            INTO cDesFraccion
            FROM bdinteg:"informix".si_ipab_marcaje_fracciones
            WHERE fraccion = cFraccion AND concepto = cConcepto;

        END IF;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
        END IF;

        RETURN cCodRet, icasual, cDesCasual, cFraccion, cConcepto, cDesFraccion;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta todos los valores casual de revisiÃ³n y FracciÃ³n de un nÃºmero de cuenta dado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_consulta_fideicomiso(pUsuario CHAR(8), 
                                                        pIdFuncion CHAR(10), 
                                                        pNumcte CHAR(12), 
                                                        pIdcasual INTEGER)

RETURNING CHAR(5)  AS codret,
          char(10) AS no_fideicomiso,
          char(100) AS nombre_fideicomiso,
          char(40)  AS  alta_fideicomiso,
          char(80)  AS  fideicomitente,
          char(80)  AS  fideicomisario,
          char(100) AS  fines_fideicomiso,
          char(80)  AS  tipo_fideicomiso,
          char(80)  AS  Patrimonio_inicial,
          char(40)  AS  moneda_nacional,
          char(40)  AS  moneda_extranjera,
          char(100) AS  representante,
          INTEGER   As  rowid;


    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE icasual   INTEGER;
    DEFINE iRegistros  INTEGER;
    DEFINE cArea       CHAR(2);
    DEFINE cDescripion CHAR(40);

    DEFINE cNumFideicomiso CHAR(10);
    DEFINE cNombre_fideicomiso CHAR(100);
    DEFINE cAlta_fideicomiso char(40);
    DEFINE cFideicomitente char(80);
    DEFINE cFideicomisario CHAR(100);
    DEFINE cFines_fideicomiso char(80);
    DEFINE cTipo_fideicomiso char(80);
    DEFINE cPatrimonio_inicial char(80);
    DEFINE cMoneda_nacional char(40);
    DEFINE cMoneda_extranjera char(40);
    DEFINE cRepresentante CHAR(100);
    DEFINE iRowid INTEGER;

    LET cCodRet = 0;
    LET iSqlErr = 0;
    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cNombre_fideicomiso = '';
    LET cAlta_fideicomiso = '';
    LET cFideicomitente = '';
    LET cFideicomisario = '';
    LET cFines_fideicomiso = '';
    LET cTipo_fideicomiso = '';
    LET cPatrimonio_inicial = '';
    LET cMoneda_nacional = '';
    LET cMoneda_extranjera = '';
    LET cRepresentante = '';
    LET icasual = 0;
    LET iRegistros = 0;
    LET cNumFideicomiso = '';
    LET cArea = '';
    LET cDescripion = '';
    LET iRowid = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_consulta_casual_fraccion.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;

        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;

		END IF;

            EXECUTE PROCEDURE bdicnweb:"informix".sp_ipab_consultarea_usuario(pUsuario, pIdFuncion) 
            INTO cCodRet, cUsuario, cArea, cDescripion;

            IF cCodRet <> '00000' THEN
                LET cCodRet = '00981'; -- El usuario no tiene una area designada
			    RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;
            END IF;

            SELECT FIRST 1 nvl(no_fideicomiso,'') INTO cNumFideicomiso
            FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
            WHERE clave_unica = pNumcte 
            AND area = cArea;

            SELECT COUNT(*) INTO iRegistros
            FROM bdinteg:"informix".si_ipab_marcaje_fideicomiso a
            INNER JOIn bdinteg:"informix".si_ipab_marcaje_excluidos b 
            ON a.no_fideicomiso = b.no_fideicomiso
            AND id_causal = pIdcasual
            AND b.area = cArea
            AND a.no_fideicomiso = cNumFideicomiso;
            
        IF iRegistros > 0 THEN

            SELECT FIRST 1 a.no_fideicomiso, nombre_fideicomiso,alta_fideicomiso  ,fideicomitente  ,fideicomisario  ,fines_fideicomiso, tipo_fideicomiso ,patrimonio_inicial,  moneda_nacional, moneda_extranjera,representante, a.rowid
            INTO cNumFideicomiso,cNombre_fideicomiso,cAlta_fideicomiso,cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, irowid
            FROM bdinteg:"informix".si_ipab_marcaje_fideicomiso a
            INNER JOIn bdinteg:"informix".si_ipab_marcaje_excluidos b 
            ON a.no_fideicomiso = b.no_fideicomiso
            AND id_causal = pIdcasual
            AND b.clave_unica = pNumcte
            AND b.area = cArea
            AND a.no_fideicomiso = cNumFideicomiso;

        END IF;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;

        END IF;
			RETURN cCodRet, cNumFideicomiso, cNombre_fideicomiso, cAlta_fideicomiso, cFideicomitente, cFideicomisario, cFines_fideicomiso, cTipo_fideicomiso, cPatrimonio_inicial, cMoneda_nacional, cMoneda_extranjera, cRepresentante, iRowid;
        	

    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta todos los valores casual de revisiÃ³n y FracciÃ³n de un nÃºmero de cuenta dado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_consulta_usuario(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5)  AS codret,
          CHAR(8)  AS usuario,
          CHAR(45)  AS nombre;

    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE cNombre     CHAR(45);
    DEFINE iRegistros  INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cNombre = '';
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_consulta_usuario.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cUsuario, cNombre;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cNombre;
		END IF;

        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT b.usuario, a.nombre
            INTO cUsuario, cNombre
            FROM bdinteg:si_ejecut a INNER JOIN bdinteg:si_ipab_marcaje_areas_usuarios b 
            ON a.ejecutivo = b.usuario

            LET iregistros = iRegistros + 1;
            RETURN cCodRet, cUsuario, cNombre WITH RESUME;
        END FOREACH;
      
        IF iregistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cUsuario, cNombre;
		ELIF iregistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cUsuario, cNombre;
		END IF;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta los usuarios pertenecientes a un Ã¡rea de la tabla si_ipab_marcaje_areas_usuarios.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_consulta_usuario_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5)  AS codret,
          INTEGER AS  registros;

    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE iRegistros  INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iregistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_consulta_usuario_totales.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, iregistros;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iregistros;
		END IF;

        SELECT DISTINCT COUNT(b.usuario) 
        INTO iregistros
        FROM bdinteg:si_ejecut a INNER JOIN bdinteg:si_ipab_marcaje_areas_usuarios b 
        ON a.ejecutivo = b.usuario;

        IF iregistros = 0 THEN
            LET cCodRet  = '00017';
        END IF;

        RETURN cCodRet, iregistros;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Devuelve el total de usuarios pertenecientes a un area de la tabla si_ipab_marcaje_areas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_consultarea_usuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5)  AS codret,
          CHAR(8)  AS usuario,
          CHAR(2)  AS id_area,
          CHAR(40) AS descripcion;

    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE cArea       CHAR(2);
    DEFINE cPerfil     INTEGER;
    DEFINE cDescripion CHAR(40);
    DEFINE iRegistros  INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cArea = '';
    LET cDescripion = '';
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, cArea, cDescripion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_consultarea_usuario.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cUsuario, cArea, cDescripion;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cArea, cDescripion;
		END IF;

        SELECT NVL(b.id_area, ''), NVL(descripcion, '')
        INTO cArea, cDescripion
        FROM bdinteg:"informix".si_ipab_marcaje_areas_usuarios a
        INNER JOIN  bdinteg:"informix".si_ipab_marcaje_areas b on a.id_area = b.id_area
        WHERE usuario = pUsuario;

        LET cUsuario = pUsuario;
      
        IF dbinfo('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '00017';
		END IF;

        RETURN cCodRet, cUsuario, cArea, cDescripion;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta el Ã¡rea a la que pertenece un usuario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_marcaje_areas(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5)  AS codret,
          INTEGER  AS id_area,
          CHAR(40) AS descripcion;


    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE iArea   INTEGER;
    DEFINE cDescripion CHAR(40);
    DEFINE iRegistros INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET iArea = '';
    LET cDescripion = '';
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iArea, cDescripion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_marcaje_areas.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, iArea, cDescripion;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iArea, cDescripion;
		END IF;

        FOREACH
            SELECT id_area, descripcion
            INTO   iArea, cDescripion
            FROM bdinteg:"informix".si_ipab_marcaje_areas

            LET iRegistros = iRegistros + 1;
            RETURN cCodRet, iArea, cDescripion WITH RESUME;
        END FOREACH;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iArea, cDescripion;
        END IF;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta todas la Ã¡reas que registra (jurÃ­dico Corporativo, JurÃ­dico Fiduciario, Control Operativo, Capital Humano).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_marcaje_casual(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5)  AS codret,
          INTEGER  AS id_causal,
          CHAR(40) AS descripcion;

    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE icasual   INTEGER;
    DEFINE cDescripion CHAR(40);
    DEFINE iRegistros INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET icasual = '';
    LET cDescripion = '';
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, icasual, cDescripion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_marcaje_casual.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, icasual, cDescripion;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, icasual, cDescripion;
		END IF;

        FOREACH
            SELECT id_causal, descripcion
            INTO   icasual, cDescripion
            FROM bdinteg:"informix".si_ipab_marcaje_causal
            ORDER BY id_causal

            LET iRegistros = iRegistros + 1;
            RETURN cCodRet, icasual, cDescripion WITH RESUME;
        END FOREACH;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, icasual, cDescripion;
        END IF;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta todos los causales de revisiÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_marcaje_fracciones(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5)  AS codret,
          CHAR(2)  AS fraccion,
          CHAR(2)  AS concepto,
          CHAR(40) AS descripcion;

    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cFraccion   CHAR(2);
    DEFINE cConcepto   CHAR(2);
    DEFINE cDescripion CHAR(40);
    DEFINE iRegistros INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cFraccion = '';
    LET cConcepto = '';
    LET cDescripion = '';
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFraccion, cConcepto, cDescripion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_marcaje_fracciones.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cFraccion, cConcepto, cDescripion;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFraccion, cConcepto, cDescripion;
		END IF;

        FOREACH
            SELECT fraccion, concepto, descripcion
            INTO   cFraccion, cConcepto, cDescripion
            FROM bdinteg:"informix".si_ipab_marcaje_fracciones
            ORDER BY fraccion, concepto

            LET iRegistros = iRegistros + 1;
            RETURN cCodRet, cFraccion, cConcepto, cDescripion WITH RESUME;
        END FOREACH;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cFraccion, cConcepto, cDescripion;
        END IF;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Consulta todos los valores relacionados a FracciÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_ope_casual_fraccion(pUsuario CHAR(8), 
                                                        pIdFuncion CHAR(10), 
                                                        pCuenta CHAR(11), 
                                                        pNumCliente CHAR(10), 
                                                        pFraccion CHAR(2),
                                                        pConcpeto CHAR(2),
                                                        pidCasual INTEGER,
                                                        pArea     INTEGER,
                                                        pConsulta SMALLINT)
RETURNING CHAR(5)  AS codret;


    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE icasual   INTEGER;
    DEFINE cDesCasual CHAR(40);
    DEFINE cFraccion   CHAR(2);
    DEFINE cConcepto   CHAR(2);
    DEFINE cDesFraccion CHAR(40);
    DEFINE iRegistros  INTEGER;

    DEFINE cTipoPersona CHAR(2);
    DEFINE cNombre1     CHAR(50);
    DEFINE cNombre2     CHAR(26);
    DEFINE cApellidoPa     CHAR(26);
    DEFINE cApellidoMa    CHAR(26);
    DEFINE cExclusion     CHAR(50);
    DEFINE cTipoPersonaDes CHAR(10);
    DEFINE cInversion     CHAR(10);
    DEFINE cBanco        CHAR(30);


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cDesCasual  = '';
    LET cFraccion = '';
    LET cConcepto = '';
    LET cDesFraccion = '';
    LET icasual = 0;
    LET iRegistros = 0;

    LET cTipoPersona = '';
    LET cNombre1     = '';
    LET cNombre2     = '';
    LET cApellidoPa  = '';
    LET cApellidoMa  = '';
    LET cExclusion   = '';
    LET cTipoPersonaDes = '';
    LET cInversion = '';
    LET cBanco = '';

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_ope_casual_fraccion.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pConcpeto = '' OR pidCasual = '' OR pNumCliente = '' OR pFraccion = '' OR pConsulta = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        -- SE VALIDA QUE EL PERFIL SEA DE AREA JURIDICA
        IF pArea = '4' AND pConsulta IN ('1','2') THEN
            
            SELECT count(*) INTO iRegistros
            FROM   bdinteg:"informix".si_ipab_marcaje_excluidos
            WHERE  clave_unica = pNumCliente
            AND    area = pArea AND fraccion = pFraccion AND concepto = pConcpeto;

            --SI NO EXISTE UN REGISTRO CON DICHO CLIENTE Y FRACCIÃN SE TOMA COMO ALTA, SI NO MODIFCACIÃN 
            IF iRegistros = 0 or iRegistros is null THEN
                LET pConsulta = '1';
            ELSE
                LET pConsulta = '2';
            END IF;
        END IF;
        
        LET iRegistros = '0';

        --ALTA
        IF pConsulta = '1' THEN

            SELECT razon_social
		    INTO cBanco 
		    FROM bdinteg:"informix".si_empresas
		    WHERE empresa = '001';

            SELECT tpo_persona, (TRIM(nombre1) || ' ' || TRIM(nombre2)) AS nombre, apell_paterno,apell_materno
            INTO cTipoPersona, cNombre1, cApellidoPa, cApellidoMa
            FROM bdinteg:"informix".si_cliente
            WHERE numcte = pNumCliente;

            IF TRIM(cTipoPersona) IN ('01','03') THEN
                LET cTipoPersonaDes = 'F';
            ELIF TRIM(cTipoPersona) IN ('02', '04', '05') THEN
                LET cTipoPersonaDes = 'M';
            END IF;

            SELECT descripcion
            INTO    cDesCasual
            FROM bdinteg:"informix".si_ipab_marcaje_causal
            WHERE id_causal = pidCasual;

            IF pFraccion <> '' AND pConcpeto <> '' THEN

                 SELECT descripcion
                 INTO   cExclusion
                FROM bdinteg:"informix".si_ipab_marcaje_fracciones
                WHERE fraccion = pFraccion AND concepto = pConcpeto;
            END IF;

            IF EXISTS (SELECT cuenta FROM bdinvers:sv_maeinv WHERE status_cta = "1" and num_cte = pNumCliente ) THEN

            FOREACH

                SELECT cuenta, cta_cheques
                --- INTO pCuenta, cInversion
                INTO cInversion, pCuenta
                FROM bdinvers:sv_maeinv
                WHERE status_cta = "1" and num_cte = pNumCliente
                
                INSERT INTO bdinteg:"informix".si_ipab_marcaje_excluidos(institucion, personalidad, clave_unica, cuenta, inversion, nombre, apell_paterno, apell_materno, id_causal, causal_revision, fraccion, concepto, exclusion, area, no_fideicomiso, ejecutivo, fecha_insert) 
	            VALUES(cBanco, TRIM(cTipoPersonaDes), pNumCliente, NVL(pCuenta,'') , NVL(cInversion,''), TRIM(cNombre1) , cApellidoPa, cApellidoMa, pidCasual, TRIM(cDesCasual), pFraccion, pConcpeto, TRIM(cExclusion) , pArea, '', pUsuario, CURRENT);

            END FOREACH

            ELSE
                 SELECT FIRST 1 cuenta
                 INTO pCuenta
                 FROM bdicheq:sc_maechq 
                 WHERE num_cte = pNumCliente 
                 AND status_cta in('1','3','4','5');

                 INSERT INTO bdinteg:"informix".si_ipab_marcaje_excluidos(institucion, personalidad, clave_unica, cuenta, inversion, nombre, apell_paterno, apell_materno, id_causal, causal_revision, fraccion, concepto, exclusion, area, no_fideicomiso, ejecutivo, fecha_insert) 
	             VALUES(cBanco, TRIM(cTipoPersonaDes), pNumCliente, NVL(pCuenta,'') , cInversion, TRIM(cNombre1) , cApellidoPa, cApellidoMa, pidCasual, TRIM(cDesCasual), pFraccion, pConcpeto, TRIM(cExclusion) , pArea, '', pUsuario, CURRENT);
            END IF;

        --MODIFICACION
        ELIF pConsulta = '2' THEN

            SELECT descripcion
            INTO    cDesCasual
            FROM bdinteg:"informix".si_ipab_marcaje_causal
            WHERE id_causal = pidCasual;

            SELECT descripcion
            INTO cDesFraccion
            FROM bdinteg:"informix".si_ipab_marcaje_fracciones
            WHERE fraccion = pFraccion AND concepto = pConcpeto;

            IF pArea = '4' THEN

                UPDATE bdinteg:"informix".si_ipab_marcaje_excluidos 
                SET id_causal = pidCasual, 
                fraccion = pFraccion, 
                concepto = pConcpeto, 
                exclusion = cDesFraccion,
                fecha_insert = CURRENT,
                causal_revision = cDesCasual
                WHERE clave_unica = pNumCliente 
                AND area = pArea 
                AND concepto = pConcpeto
                AND fraccion = pFraccion ;

            ELSE 

                UPDATE bdinteg:"informix".si_ipab_marcaje_excluidos 
                SET id_causal = pidCasual, 
                fraccion = pFraccion, 
                concepto = pConcpeto, 
                exclusion = cDesFraccion,
                fecha_insert = CURRENT,
                causal_revision = cDesCasual
                WHERE clave_unica = pNumCliente 
                AND area = pArea;
            END IF;

        --BAJA
        ELIF pConsulta = '3' THEN

            IF pArea = '4' THEN

                DELETE FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
                WHERE clave_unica = TRIM(pNumCliente)
                AND area = pArea
                AND fraccion = pFraccion
                AND concepto = pConcpeto;

            ELSE 
                DELETE FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
                WHERE clave_unica = TRIM(pNumCliente)
                AND area = pArea;
            END IF;
                    
        ELIF pConsulta = '4' THEN
            SELECT count(*) INTO iRegistros
            FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
            WHERE clave_unica = pNumCliente
            AND area = pArea
            AND concepto = pConcpeto
            AND fraccion = pFraccion;

            IF iRegistros = 0 THEN
                LET cCodRet = '00017';
            END IF;
        END IF;

        RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Realiza la alta, modificaciÃ³n y eliminaciÃ³n de un marcaje exclusivo cuando el area sea diferente de fideicomiso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_ope_fideicomiso(pUsuario CHAR(8), 
                                                    pIdFuncion CHAR(10), 
                                                    pCuenta CHAR(11), 
                                                    pNumCliente CHAR(10), 
                                                    pFraccion CHAR(2),
                                                    pConcepto CHAR(2),
                                                    pidCasual INTEGER,
                                                    pConsulta SMALLINT,
                                                    pno_fideicomiso char(10),
                                                    pnombre_fideicomiso  char(100),
                                                    palta_fideicomiso    char(40),
                                                    pfideicomitente      char(80),
                                                    pfideicomisario      char(80),
                                                    pfines_fideicomiso   char(100),
                                                    ptipo_fideicomiso    char(80),
                                                    pPatrimonio_inicial  char(80),
                                                    pmoneda_nacional     char(40),
                                                    pmoneda_extranjera   char(40),
                                                    prepresentante       char(100),
                                                    pArea INTEGER,
                                                    pRowId INTEGER)

RETURNING CHAR(5)  AS codret;


    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE icasual   INTEGER;
    DEFINE cDesCasual CHAR(40);
    DEFINE cFraccion   CHAR(2);
    DEFINE cConcepto   CHAR(2);
    DEFINE cDesFraccion CHAR(40);
    DEFINE iRegistros  INTEGER;

    DEFINE cTipoPersona CHAR(2);
    DEFINE cNombre1     CHAR(50);
    DEFINE cNombre2     CHAR(26);
    DEFINE cApellidoPa     CHAR(26);
    DEFINE cApellidoMa    CHAR(26);
    DEFINE cInversion     CHAR(10);
    DEFINE cTipoPersonaDes CHAR(10);
    DEFINE cExclusion     CHAR(50);
    DEFINE cNumFideicomiso CHAR(10);
    DEFINE cBanco CHAR(30);



    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = '';
    LET cDesCasual  = '';
    LET cFraccion = '';
    LET cConcepto = '';
    LET cDesFraccion = '';
    LET icasual = 0;
    LET iRegistros = 0;

    LET cTipoPersona = '';
    LET cNombre1     = '';
    LET cNombre2     = '';
    LET cApellidoPa  = '';
    LET cApellidoMa  = '';
    LET cInversion   = '';
    LET cTipoPersonaDes = '';
    LET cExclusion = '';
    LET cNumFideicomiso = '';
    LET cBanco = '';

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_ope_fideicomiso.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = ''  OR pidCasual = ''  OR pNumCliente = '' OR  pConsulta = '' OR pArea = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

        --ALTA
        IF pConsulta = '1' THEN

            SELECT razon_social
		    INTO cBanco 
		    FROM bdinteg:"informix".si_empresas
		    WHERE empresa = '001';

            INSERT INTO bdinteg:"informix".si_ipab_marcaje_fideicomiso
                   (no_fideicomiso, nombre_fideicomiso,alta_fideicomiso  ,fideicomitente  ,fideicomisario  ,fines_fideicomiso, tipo_fideicomiso   ,patrimonio_inicial,  moneda_nacional, moneda_extranjera,representante)
            VALUES(pno_fideicomiso, pnombre_fideicomiso, palta_fideicomiso, pfideicomitente, pfideicomisario, pfines_fideicomiso, ptipo_fideicomiso, pPatrimonio_inicial, pmoneda_nacional, pmoneda_extranjera, prepresentante);

            SELECT tpo_persona, (TRIM(nombre1) || ' ' || TRIM(nombre2)) AS nombre, apell_paterno,apell_materno
            INTO cTipoPersona, cNombre1, cApellidoPa, cApellidoMa
            FROM bdinteg:"informix".si_cliente
            WHERE numcte = pNumCliente;

            IF TRIM(cTipoPersona) IN ('01','03') THEN
                LET cTipoPersonaDes = 'F';
            ELIF TRIM(cTipoPersona) IN ('02', '04', '05') THEN
                LET cTipoPersonaDes = 'M';
            END IF;
            
            SELECT descripcion
            INTO    cDesCasual
            FROM bdinteg:"informix".si_ipab_marcaje_causal
            WHERE id_causal = pidCasual;

            IF EXISTS (SELECT cuenta FROM bdinvers:sv_maeinv WHERE status_cta = "1" and num_cte = pNumCliente ) THEN
                FOREACH

                    SELECT cuenta, cta_cheques
                    --- INTO pCuenta, cInversion
                    INTO cInversion, pCuenta
                    FROM  bdinvers:sv_maeinv
                    WHERE status_cta = "1" and num_cte = pNumCliente

                    INSERT INTO bdinteg:"informix".si_ipab_marcaje_excluidos(institucion, personalidad, clave_unica, cuenta, inversion, nombre, apell_paterno, apell_materno, id_causal, causal_revision, fraccion, concepto, exclusion, area, no_fideicomiso, ejecutivo, fecha_insert) 
	                VALUES(cBanco, TRIM(cTipoPersonaDes), pNumCliente, NVL(pCuenta,'') , NVL(cInversion,''), TRIM(cNombre1) , cApellidoPa, cApellidoMa, pidCasual, TRIM(cDesCasual), '', '', '' , pArea, pno_fideicomiso, pUsuario, TODAY);

                END FOREACH

            ELSE 
                 SELECT FIRST 1 cuenta
                 INTO pCuenta
                 FROM bdicheq:sc_maechq 
                 WHERE num_cte = pNumCliente 
                 AND status_cta in('1','3','4','5');

                INSERT INTO bdinteg:"informix".si_ipab_marcaje_excluidos(institucion, personalidad, clave_unica, cuenta, inversion, nombre, apell_paterno, apell_materno, id_causal, causal_revision, fraccion, concepto, exclusion, area, no_fideicomiso, ejecutivo, fecha_insert) 
	            VALUES(cBanco, cTipoPersonaDes, pNumCliente, NVL(pCuenta,'') , '', TRIM(cNombre1) , cApellidoPa, cApellidoMa, pidCasual, TRIM(cDesCasual), '', '', '', pArea, pno_fideicomiso, pUsuario, TODAY);
            END IF;
        --MODIFICACION
        ELIF pConsulta = '2' THEN

            SELECT descripcion
            INTO    cDesCasual
            FROM bdinteg:"informix".si_ipab_marcaje_causal
            WHERE id_causal = pidCasual;

            SELECT descripcion
            INTO cDesFraccion
            FROM bdinteg:"informix".si_ipab_marcaje_fracciones
            WHERE fraccion = pFraccion AND concepto = pConcepto;

            SELECT FIRST 1 nvl(no_fideicomiso,'') INTO cNumFideicomiso
            FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
            WHERE clave_unica = pNumCliente
            AND area = pArea;

            UPDATE bdinteg:"informix".si_ipab_marcaje_fideicomiso 
            SET no_fideicomiso = pno_fideicomiso,
                nombre_fideicomiso = pnombre_fideicomiso, 
                alta_fideicomiso = palta_fideicomiso, 
                fideicomitente = pfideicomitente, 
                fideicomisario = pfideicomisario, 
                fines_fideicomiso = pfines_fideicomiso, 
                tipo_fideicomiso = ptipo_fideicomiso, 
                patrimonio_inicial = pPatrimonio_inicial, 
                moneda_nacional = pmoneda_nacional, 
                moneda_extranjera = pmoneda_extranjera, 
                representante = prepresentante 
            WHERE rowid = pRowId;

            IF pFraccion = 'nu' THEN
                LET pFraccion = '';
            END IF;

            IF pConcepto = 'nu' THEN
                LET pConcepto = '';
            END IF;

            UPDATE bdinteg:"informix".si_ipab_marcaje_excluidos 
            SET id_causal = pidCasual, 
                fraccion = pFraccion, 
                concepto = pConcepto,
                causal_revision = cDesCasual,
                exclusion = cDesFraccion,
                fecha_insert = TODAY,
                no_fideicomiso = pno_fideicomiso
            WHERE clave_unica = pNumCliente 
            AND no_fideicomiso = cNumFideicomiso
            AND area = pArea ;

        --BAJA
        ELIF pConsulta = '3' THEN

            DELETE FROM bdinteg:"informix".si_ipab_marcaje_fideicomiso  where rowid = pRowId;

            DELETE FROM bdinteg:"informix".si_ipab_marcaje_excluidos 
            WHERE clave_unica = pNumCliente AND area = pArea;
            
        END IF;
        RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Realiza la alta, modificaciÃ³n y eliminaciÃ³n de un marcaje exclusivo y un fideicomiso cuando el area sea fideicomiso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_repfideicomisomarcajeipab(
	pUsuario CHAR(8), 
	pIdFuncion CHAR(10), 
	pRutaDescarga CHAR(100), 
	pCasual INTEGER, 
	pIdArea INTEGER)

    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE nomFecha CHAR(19);
	DEFINE cFecha CHAR(10);
	DEFINE iRegistros INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	LET cFecha = '';
	LET iRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;  

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_repfideicomisomarcajeipab.out';
		--TRACE ON;

		IF pRutaDescarga='' OR pUsuario = '' OR pIdFuncion = '' OR pIdArea = '' THEN
			LET cCodRet = '00003';
			LET cNombreArchivo = 'Se encuentran campos nulos o vacÃ­os';	
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT FIRST 1 '1'
		INTO iRegistros
		FROM bdinteg:"informix".si_ipab_marcaje_fideicomiso f 
		INNER JOIN bdinteg:"informix".si_ipab_marcaje_excluidos e 
		ON f.no_fideicomiso = e.no_fideicomiso 
		WHERE e.area = pIdArea 
		AND e.id_causal = pCasual;

		IF iRegistros = 0  OR iRegistros IS NULL THEN
			LET cCodRet = '00017';
			LET cNombreArchivo = 'No se encontraron registros';	
	       RETURN cCodRet, cNombreArchivo;
		END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
			
		LET cNombreArchivo = '';
    	
		LET cCmd1 ="";
		LET cCmd1 ="SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'NUMERO DE FIDEICOMISO', 'NOMBRE DEL FIDEICOMISO', 'FECHA DE ALTA DEL FIDEICOMISO', 'FIDEICOMITENTE', 'FIDEICOMISARIO', 'FINES DEL FIDEICOMISO', 'TIPO O CLASE DE FIDEICOMISO', 'PATRIMONIO INICIAL', 'MONEDA NACIONAL','MONEDA EXTRANJERA','REPRESENTANTE COMUN' FROM systables WHERE tabid = 1";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT *  FROM (SELECT f.no_fideicomiso, f.nombre_fideicomiso, f.alta_fideicomiso, f.fideicomitente, f.fideicomisario, f.fines_fideicomiso, f.tipo_fideicomiso, f.patrimonio_inicial, f.moneda_nacional, f.moneda_extranjera, f.representante";	
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:'informix'.si_ipab_marcaje_fideicomiso f INNER JOIN bdinteg:'informix'.si_ipab_marcaje_excluidos e ON f.no_fideicomiso = e.no_fideicomiso"; 
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE e.area = '"|| pIdArea ||"' AND e.id_causal = '"|| pCasual ||"' )) AS TB"; 


		-- SE DEFINE NOMBRE DEL REPORTE A GENERAR		
		LET nomFecha = TO_CHAR(dFechaHoy, '%d%m%Y');
        LET dHoraHoy = TO_CHAR(dHoraHoy, '%H:%M:%S');
		LET cNombreArchivo = 'REP_MARCAJE_IPAB_FIDEICOMISO_'||TRIM(nomFecha)||'_'||dHoraHoy||'.xls';
		LET cNombreArchivo = REPLACE(cNombreArchivo, ':', '');

        --LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		--RUTA PRUEBAS
		--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		--RUTA PRODUCTIVA
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		--Borrado de consulta
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

					-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el caracter delimitador al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);
				
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 27/02/2024',
'MODULO: IPAB',
'DESCRIPCION: SPL encargado de generar el reporte de fideicomiso ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_repmarcajeipab(
	pUsuario CHAR(8), 
	pIdFuncion CHAR(10), 
	pRutaDescarga CHAR(100), 
	pCasual INTEGER, 
	pConcepto INTEGER,
	pFraccion CHAR(2), 
	pIdArea INTEGER,
	pMotivo CHAR(100))

    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE nomFecha CHAR(19);
	DEFINE cFecha CHAR(10);
	DEFINE cBanco CHAR(30);
	DEFINE iRegistros INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	LET cFecha = '';
	LET iRegistros = 0;
	

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;  

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_repmarcajeipab.out';
		--TRACE ON;

		IF pRutaDescarga='' OR pUsuario = '' OR pIdFuncion = '' OR pIdArea = '' OR pConcepto = '' OR pMotivo = '' THEN
			LET cCodRet = '00003';
			LET cNombreArchivo = 'Se encuentran campos nulos o vacÃ­os';	

	       RETURN cCodRet, cNombreArchivo;
    	END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;

		--SI EL ÃREA ES DE TIPO 3 Administracion y Finanzas VISUALIZA LAS ALTAS DEL ÃREA 2 
		IF pIdArea = '3' THEN
			LET pIdArea = '2';
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pIdArea < '5' THEN
			SELECT FIRST 1 '1' 
			INTO iRegistros
			FROM bdinteg:"informix".si_ipab_marcaje_excluidos e
			WHERE area = pIdArea 
			AND e.id_causal = pCasual 
			AND e.concepto = pConcepto
			AND e.fraccion = pFraccion;

		ELSE 
			SELECT FIRST 1 '1' 
			INTO iRegistros
			FROM bdinteg:"informix".si_ipab_marcaje_excluidos e
			WHERE area = pIdArea 
			AND e.id_causal = pCasual;
		END IF;

		IF iRegistros IS NULL OR iRegistros = 0 THEN
			LET cCodRet = '00017';
			LET cNombreArchivo = 'No se encontraron registros';
			RETURN cCodRet, cNombreArchivo;
		END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
			
		LET cNombreArchivo = '';
    	
		LET cCmd1 ="";
		LET cCmd1 ="SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'MOTIVO DE REPORTE:', '"|| TRIM(pMotivo) || "', ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',' ' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT 'INSTITUCION', 'PERSONALIDAD', 'CLAVE UNICA', 'NUMERO DE CUENTA(S)', 'NUMERO DE INVERSION', 'NOMBRE', 'APELLIDO PATERNO', 'APELLIDO MATERNO', 'CAUSAL DE REVISION','DESCRIPCION','FRACCION', 'CONCEPTO', 'EXCLUSION' FROM systables WHERE tabid = 1";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT institucion, personalidad,   '''' ||clave_unica,  '''' ||cuenta, '''' ||inversion, nombre, apell_paterno ,apell_materno,TO_CHAR(id_causal),causal_revision,fraccion, concepto, exclusion FROM bdinteg:si_ipab_marcaje_excluidos a";	
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE 1 = 1"; 

		IF pIdArea IS NOT NULL THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" AND area = '"|| pIdArea ||"' "; 
		END IF;

		IF pCasual IS NOT NULL  THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" AND id_causal = '"|| pCasual ||"' "; 
		END IF;

		IF pConcepto IS NOT NULL  THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" AND concepto = '"|| pConcepto ||"'"; 
		END IF;

		IF pFraccion <> '' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" AND fraccion = '"|| TRIM(pFraccion) ||"'"; 
		END IF;
		LET cCmd1 =""||TRIM(cCmd1)||" ) AS TB  ";

		-- SE DEFINE NOMBRE DEL REPORTE A GENERAR		
		LET nomFecha = TO_CHAR(dFechaHoy, '%d%m%Y');
        LET dHoraHoy = TO_CHAR(dHoraHoy, '%H:%M:%S');
		LET cNombreArchivo = 'REP_MARCAJE_IPAB_'||TRIM(nomFecha)||'_'||dHoraHoy||'.xls';
		LET cNombreArchivo = REPLACE(cNombreArchivo, ':', '');

        --LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		--RUTA PRUEBAS
		--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		--RUTA PRODUCTIVA
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		--Borrado de consulta
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

					-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el caracter delimitador al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);
				
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 17/11/2023',
'MODULO: IPAB',
'DESCRIPCION: SPL encargado de generar el reporte de Marcaje Excluido ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ipab_validausuariopass(pUsuario CHAR(8), pIdFuncion CHAR(10), pPass CHAR(50))
RETURNING CHAR(5)  AS codret,
          CHAR(8)  AS usuario,
          INTEGER AS exitoso;

    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE cUsuario    CHAR(8);
    DEFINE cExitoso    INTEGER;
    DEFINE iRegistros  INTEGER;


    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cUsuario = pUsuario;
    LET cExitoso  = 0;
    LET iRegistros = 0;

    BEGIN 
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, cExitoso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ipab_validausuariopass.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cUsuario, cExitoso;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cExitoso;
		END IF;

        IF EXISTS (SELECT 1 FROM bdinteg:si_seg_usuarios WHERE id_usuario= TRIM(pUsuario) AND encriptacion = TRIM(pPass)) THEN
            LET cExitoso = '1';
        ELSE
            LET cExitoso= '0';
        END IF;
        RETURN cCodRet, cUsuario, cExitoso;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:17/11/2023',
'MODULO: Operaciones ',
'FUNCIONALIDAD: IPAB',
'DESCRIPCION: Valida el usuario y la contraseÃ±a del usuario en sesiÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfmonitoroperacionescaja_duplicados(pUsuario CHAR(8),pIdFuncion CHAR(10),pDuplicado INTEGER,pStatus CHAR(2),pOperacion CHAR(1), pOpcion CHAR(1), pFechaAct CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5) AS codret,
		CHAR(4) AS sucursal,
		CHAR(50) AS desc_sucursal,
		DATE AS fecha_operacion,
		CHAR(50) AS desc_status,
		CHAR(8) AS folio_operacion,
		MONEY(14,2) AS importe,
		CHAR(50) AS operacion,
		CHAR(4) AS cod_proveedor,
		CHAR(50) AS terceros, 
		CHAR(16) AS papeleta,
		CHAR(40) AS usuario,
		CHAR(2) AS cod_status,
		CHAR(6) AS id_atm,
		INTEGER AS billete1000,
		INTEGER AS billete500, 
		INTEGER AS billete200, 
		INTEGER AS billete100, 
		INTEGER AS billete50,  
		INTEGER AS billete20,  
		INTEGER AS billete10,  
		INTEGER AS billete5,   
		INTEGER AS billete2,   
		INTEGER AS billete1,   
		INTEGER AS billete_c50, 
		CHAR(40) AS desc_caja,
		INTEGER AS posicion_rep,
		MONEY(18,2) AS saldo_caja,
		CHAR(4) AS cc_atm,
        INTEGER AS total_duplicados,
		INTEGER AS total_concentrar;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cSucursal CHAR(4);
		DEFINE cDescSucursal CHAR(45);
		DEFINE dFechaOperacion DATE;
		DEFINE cDescStatus CHAR(50);
        DEFINE cFolioOperacion CHAR(8);
        DEFINE mImporte MONEY(14,2);
		DEFINE cOperacion CHAR(50);
		DEFINE cCodProveedor CHAR(4);
		DEFINE cTerceros CHAR(50);
		DEFINE cPapeleta CHAR(16);
		DEFINE cUsuario CHAR(40);
		DEFINE cCodStatus CHAR(2);    
		DEFINE iIdATM CHAR(6);
		DEFINE iBillete1000 INTEGER;      
		DEFINE iBillete500  INTEGER;      
		DEFINE iBillete200  INTEGER;      
		DEFINE iBillete100  INTEGER;      
		DEFINE iBillete50   INTEGER;      
		DEFINE iBillete20   INTEGER;      
		DEFINE iBillete10   INTEGER;      
		DEFINE iBillete5    INTEGER;      
		DEFINE iBillete2    INTEGER;      
		DEFINE iBillete1    INTEGER;      
		DEFINE iBillete_c50  INTEGER;
        DEFINE cDescCaja CHAR(40);
        DEFINE iPosicionRep INTEGER;    
		DEFINE mSaldoCaja   MONEY(18,2); 
		DEFINE cCcATM CHAR(4);
		DEFINE iTotalDuplicados INTEGER;
		DEFINE iTotalConcentrar INTEGER;
        DEFINE iNoRegistros INTEGER; 
        DEFINE iRecuperacion INTEGER;
        DEFINE iRegistros INTEGER;
		DEFINE dFechaInsert DATE;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cSucursal = '';
		LET cDescSucursal = '';
		LET dFechaOperacion = NULL;
		LET cDescStatus = '';
        LET cFolioOperacion = '';
        LET mImporte = NULL;
		LET cOperacion = '';
		LET cCodProveedor = '';
		LET cTerceros = '';
		LET cPapeleta = '';
		LET cUsuario = '';
		LET cCodStatus = '';   
		LET iIdATM = 0; 
		LET iBillete1000 = 0;      
		LET iBillete500  = 0;      
		LET iBillete200  = 0;      
		LET iBillete100  = 0;      
		LET iBillete50   = 0;      
		LET iBillete20   = 0;      
		LET iBillete10   = 0;      
		LET iBillete5    = 0;      
		LET iBillete2    = 0;      
		LET iBillete1    = 0;      
		LET iBillete_c50  = 0; 
        LET cDescCaja = '';
        LET iPosicionRep = 0;    
		LET mSaldoCaja   = NULL; 
		LET cCcATM = '';
		LET iTotalDuplicados=0;
		LET iTotalConcentrar=0;
        LET iNoRegistros = 0; 
        LET iRecuperacion = 0;
        LET iRegistros = 0;
		LET dFechaInsert = '';
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfmonitoroperacionescaja_duplicados.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pOperacion ='' OR pOperacion NOT IN (1,2,3,4) THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar;
            END IF;
            
            -- VALIDACION DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM , iTotalDuplicados, iTotalConcentrar;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar;
			END IF;
			
			--EXCEL
			IF pOperacion = '1' THEN 
			
				SET ISOLATION TO DIRTY READ;
				FOREACH		
					SELECT SKIP pRegistros FIRST pRecuperacion 
					m.sucursal, m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
					m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
					m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,TRIM(REPLACE(UPPER(m.desc_caja),'CAJA GENERAL','')) AS caja_descripcion,
					m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
					INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar
					FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
					WHERE m.us_insert = pUsuario
					ORDER BY caja_descripcion ASC	  
					
					 LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
					cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar WITH RESUME;
				
				END FOREACH;
				
			--OPERACION_GRID 2
			ELIF pOperacion = '2' THEN 
				
				SET ISOLATION TO DIRTY READ;
				IF pOpcion = 'S' AND pFechaAct <> '' THEN 
					FOREACH		
						SELECT SKIP pRegistros FIRST pRecuperacion 
						m.sucursal,m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
						m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
						m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,m.desc_caja,m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
						INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar
						FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
						WHERE m.us_insert = pUsuario
							AND m.posicion_rep = 1 AND TRIM(m.cod_tatus) = '01' AND m.fecha_operacion = pFechaAct
						ORDER BY m.sucursal ASC	  
						
						LET iNoRegistros = iNoRegistros + 1;
						
						RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar WITH RESUME;
					
					END FOREACH;
				ELIF pOpcion = 'C' AND pFechaAct <> '' THEN  
					FOREACH		
						SELECT SKIP pRegistros FIRST pRecuperacion 
						m.sucursal,m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
						m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
						m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,m.desc_caja,m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
						INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar
						FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
						WHERE m.us_insert = pUsuario
							AND m.posicion_rep = 1 AND TRIM(m.cod_tatus) IN ('01','12') AND m.fecha_operacion = pFechaAct
						ORDER BY m.sucursal ASC	  
						
						LET iNoRegistros = iNoRegistros + 1;
						
						RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar WITH RESUME;
					
					END FOREACH;

				ELSE 
					FOREACH		
						SELECT SKIP pRegistros FIRST pRecuperacion 
						m.sucursal,m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
						m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
						m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,m.desc_caja,m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
						INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar
						FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
						WHERE m.us_insert = pUsuario
							AND m.posicion_rep=1
						ORDER BY m.sucursal ASC	  
						
						LET iNoRegistros = iNoRegistros + 1;
						
						RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar WITH RESUME;
					
					END FOREACH;
				END IF;
				
				

			--OPERACION_DUPLICADOS 3
			ELIF pOperacion = '3' THEN		
			
				SET ISOLATION TO DIRTY READ;
					
					FOREACH		
						SELECT SKIP pRegistros FIRST pRecuperacion 
						m.sucursal,m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
						m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
						m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,m.desc_caja,m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
						INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar
						FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
						WHERE m.us_insert=pUsuario
							  AND m.cod_tatus= CASE WHEN pStatus = '' THEN m.cod_tatus ELSE pStatus END
							  AND m.duplicado=pDuplicado
							  AND m.posicion_rep=1
						ORDER BY m.sucursal ASC	  
						
						 LET iNoRegistros = iNoRegistros + 1;
						
						RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar WITH RESUME;
					
					END FOREACH;
			
			END IF;
			
			--generar un reporte con los registros que tengan estatus 01 Solicitud DotaciÃ³n Sucursal o 12 Solicitud DotaciÃ³n ATM
		    SET ISOLATION TO DIRTY READ;
				IF pOperacion = '4' THEN 
					FOREACH		
					SELECT SKIP pRegistros FIRST pRecuperacion 
					m.sucursal, m.desc_sucursal, m.fecha_operacion,m.desc_status,m.folio_operacion,m.importe,m.operacion,
					m.cod_proveedor,m.terceros,m.papeleta,m.usuario,m.cod_tatus,m.id_atm,m.billete_1000,m.billete_500,m.billete_200,m.billete_100,m.billete_50,m.billete_20,
					m.billete_10,m.billete_5,m.billete_2,m.billete_1,m.billete_c50,TRIM(REPLACE(UPPER(m.desc_caja),'CAJA GENERAL','')) AS caja_descripcion,
					m.posicion_rep,m.saldo_caja,m.cc_atm,m.total_duplicado,m.total_status_concentrar
					INTO cSucursal,cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar
					FROM bdicnweb:"informix".sw_cg_monitoroperacioness m
					WHERE m.us_insert = pUsuario				  
							AND TRIM(m.cod_tatus) in ('01','12') 
						ORDER BY caja_descripcion ASC 
						
						LET iNoRegistros = iNoRegistros + 1;
						
						RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar WITH RESUME;
					
					END FOREACH;
				END IF;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
					RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
					cDescCaja, iPosicionRep, mSaldoCaja, cCcATM,iTotalDuplicados, iTotalConcentrar;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
					RETURN cCodRet, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
					cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iTotalDuplicados, iTotalConcentrar;
			END IF;   	
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/OCTUBRE/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD:  CONSULTAS REPORTES > MONITOR DE OPERACIONES',
'DESCRIPCION: SP que consulta informaciÃ³n de los registros que estan duplicados o registros que se pueden concentrar',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 25/OCTUBRE/2016',
'DESCRIPCION: Se agrega parametro de entrada pOperacion',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 27/ENERO/2017',
'DESCRIPCION: Se modifica consulta para el tipo pOperacion excel, se cambia desc_caja por campo caja_descripcion',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 28/11/2020',
'DESCRIPCION: Se modifica procedimiento para retornar de forma separada  No Sucursal y Descripcion.',
'AUTOR: Mario Gonzalez Vazquez',
'FECHA: 12/04/2024',
'DESCRIPCION: Se modifica Sp para agregar una nueva condicion para agregar codigo para generar un nuevo reporte con los registros que tengan estatus 01 Solicitud DotaciÃ³n Sucursal o 12 Solicitud DotaciÃ³n ATM ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cheques_devueltos(pBandera CHAR(2),
													pUsuario CHAR(8), 
													pIdFuncion CHAR(10),
													pNumCuenta CHAR(20), 
													pNumCheque CHAR(7),
													pFechaInicial DATE, 
													pFechaFinal DATE,
													pRegistros INTEGER, 
													pRecuperacion INTEGER,
													pSistema CHAR(20),
													pConsecutivo CHAR(3),
													pCodBanco CHAR(3), 
													pFechaPresenta DATE, 
													pArchivo CHAR(100),
													pLado CHAR(1), 
													pStatusImg SMALLINT, 
													pLimpia CHAR(1),
													pNumCte CHAR(9),
													pFecha	DATE)

		RETURNING 
			CHAR(5) 	AS codret,
			INTEGER 	AS num_registros,	
			CHAR(2)		AS	motivo_devolucion,     
			CHAR(35)	AS	decripcion,    
			CHAR(3)		AS 	empresa,
			CHAR(3)		AS	clave_banco,
			CHAR(40)	AS 	descripcion_banco,
			CHAR(20)	AS	cuenta,
			CHAR(7)		AS	num_cheque,
			DATE		AS  fecha_presenta,
			MONEY(16,2)	AS	monto,
			MONEY(16,2)	AS	monto_aplica, 
			MONEY(16,2)	AS	suma_comision, 
			CHAR(3)		AS	formato_imagen, 
			INTEGER		AS	tamano_imagen_A,
			INTEGER		AS	tamano_imagen_B,
			INTEGER 	AS consecutivo,
			DATE 		AS fecha_hoy,
			CHAR(3)   	AS formato_img;	
-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cMotivoDevolucion CHAR(2);
DEFINE cDecripcion CHAR(35);
DEFINE cEmpresa CHAR(3);
DEFINE cClaveBanco CHAR(3);
DEFINE cDescripcionBanco CHAR(40);
DEFINE cCuenta CHAR(20);
DEFINE NumCheque CHAR(7);
DEFINE fechaPresenta DATE;
DEFINE mMonto MONEY(18,2);
DEFINE mMontoAplica MONEY(18,2);
DEFINE mSumaComision MONEY(18,2);
DEFINE cFormatoImagen CHAR(3);
DEFINE iTamanoImagenA INTEGER;
DEFINE iTamanoImagenB INTEGER;
DEFINE iConsecutivo INTEGER;
DEFINE dFechaHoy DATE;
DEFINE cImgFormato CHAR(3);

-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iNoRegistros  = 0;
LET cMotivoDevolucion   = '';
LET cDecripcion = '';
LET cEmpresa = '';
LET cClaveBanco = '';
LET cDescripcionBanco = '';
LET cCuenta = '';
LET NumCheque = '';
LET fechaPresenta = '';
LET mMonto = 0.00;
LET mMontoAplica = 0.00;
LET mSumaComision = 0.00;
LET cFormatoImagen = '';
LET iTamanoImagenA = 0;
LET iTamanoImagenB = 0;
LET iConsecutivo = 0;
LET dFechaHoy = mdy(1,1,2000);
LET cImgFormato = '';
	BEGIN
	-- ############################################################################
	-- #                    Control de Errores para INFORMIX                      #
	-- ############################################################################
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cheques_devueltos.out";
		--TRACE ON;
	-- ############################################################################
	-- #                    Validar parametros de entrada                         #
	-- ############################################################################
		IF pBandera = '' THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		END IF;
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCuenta = '' OR pNumCheque = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '2' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '3' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '4' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pConsecutivo = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '5' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '6' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pCodBanco = '' OR pNumCuenta = '' OR pNumCheque = '' OR pFechaPresenta = '' OR pArchivo = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		ELIF pBandera = '7' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pCodBanco = '' OR pNumCuenta = '' OR pNumCheque = '' OR pLado = '' OR pFechaPresenta = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
			END IF;
		END IF;



		IF pBandera = '1' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultacheqsimg(pUsuario, pIdFuncion, pNumCuenta, pNumCheque)
			INTO cCodRet, iNoRegistros;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		ELIF pBandera = '2' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_consultachequesdevueltos(pUsuario, pIdFuncion, pNumCte, pFechaInicial, pFechaFinal, pRegistros, pRecuperacion)
				INTO cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB
				RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato WITH RESUME;
			END FOREACH;
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultachequesdevueltos_totales(pUsuario, pIdFuncion, pNumCte,pFechaInicial, pFechaFinal)
			INTO cCodRet, iNoRegistros;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		ELIF pBandera = '4' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultaconsecutivoarch(pUsuario, pIdFuncion,pSistema,pConsecutivo)
			INTO cCodRet,iConsecutivo,dFechaHoy;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_consultamovaplicacion_totales(pUsuario, pIdFuncion, pFecha)	
			INTO cCodRet, iNoRegistros;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE "informix".sp_ope_grabaimagenchqsdevueltos(pUsuario, pIdFuncion, pCodBanco, pNumCuenta, pNumCheque, pFechaPresenta, pArchivo
							,pLado, pStatusImg, pLimpia)
			INTO cCodRet;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		ELIF pBandera = '7' THEN
			EXECUTE PROCEDURE "informix".sp_ope_validaimagenchequedev(pUsuario, pIdFuncion, pCodBanco, pNumCuenta, pNumCheque, pLado, pFechaPresenta)
			INTO cCodRet,cImgFormato;
			RETURN cCodRet, iNoRegistros, cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,
					mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB,iConsecutivo,dFechaHoy,cImgFormato;
		END IF;
	END;

END PROCEDURE
DOCUMENT 
"AUTOR : Eduardo ï¿½vila Pï¿½rez Tagle",
'MODULO: Cï¿½maras de compensaciï¿½n',
"FUNCIONAMIENTO:SP padre de cheques devueltos",
"FECHA : 03-03-2023";

CREATE PROCEDURE "informix".sp_ope_consultacheqsimg(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCuenta CHAR(20), pNumCheque CHAR(7))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros  = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacheqsimg.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCuenta = '' OR  pNumCheque = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;		
			
		SELECT COUNT(*)  
			INTO iNoRegistros
			FROM bditef:cce_cheques_img
			WHERE numcuenta= pNumCuenta
			AND numcheque= pNumCheque
			AND lado_ft IN('A','B') 
			AND imagen IS NOT NULL;	
			RETURN cCodRet, iNoRegistros;		
		END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 25/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CHEQUES DEVUELTOS',
'DESCRIPCION: Consulta el numero de registros q contiene la consulta de la tabla bditef:cce_cheques_img',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaconsecutivoarch(pUsuario CHAR(8), pIdFuncion CHAR(10),pSistema CHAR(20),pConsecutivo CHAR(3))
		RETURNING CHAR(5) AS codret,
		INTEGER AS consecutivo,
		DATE AS fecha_hoy;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iConsecutivo INTEGER;
    DEFINE dFechaHoy DATE;
	DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '0000';
	LET iCodRetSp = 0;
	LET iConsecutivo = 0;
    LET dFechaHoy = mdy(1,1,2000);
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iConsecutivo,dFechaHoy;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaconsecutivoarch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iConsecutivo,dFechaHoy;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iConsecutivo,dFechaHoy;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		 
		EXECUTE PROCEDURE bditef:"informix".sp_consultaconsecutivoarchivo(pSistema,pConsecutivo)			 
				INTO cCodRetSp,iConsecutivo,dFechaHoy;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_consultaconsecutivoarchivo';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';	
		END IF;		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,iConsecutivo,dFechaHoy;	
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iConsecutivo,dFechaHoy;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 20/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CHEQUES DEVUELTOS',
'DESCRIPCION: SPL que obtiene el consecutivo de un proceso ejecutado el mismo dia, eliminando los registros anteriores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_grabaimagenchqsdevueltos(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodBanco CHAR(3), pCuenta CHAR(20),pNumCheque CHAR(7), pFechaPresenta DATE, pArchivo CHAR(100),pLado CHAR(1), pStatusImg SMALLINT, pLimpia CHAR(1) )
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cMensaje = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_grabaimagenchqsdevueltos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCodBanco = '' OR  pCuenta = '' OR  pNumCheque= '' OR  pFechaPresenta IS NULL OR  pArchivo = '' OR  pLado = '' OR  pStatusImg IS NULL OR pLimpia = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;			 
		EXECUTE PROCEDURE bditef:"informix".sp_grabaimageneschqdevueltos(pUsuario, pCodBanco,pCuenta,pNumCheque,pFechaPresenta,pArchivo,pLado,pStatusImg, pLimpia)
			INTO cCodRetSp, cMensaje;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_grabaimageneschqdevueltos';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';	
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:CHEQUES DEVUELTOS',
'DESCRIPCION: SPL que realiza el grabado de cheques devueltos pLimpia = 1 elimina los registros con el empleado correspondiente, pLimpia <> '' registra las imagenes de los cheques devueltos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validaimagenchequedev(pUsuario CHAR(8), pIdFuncion CHAR(10), pCveBanco CHAR(3), pCuenta CHAR(20), pNumCheque CHAR(7), pLadoFt CHAR(1), dFechaPresenta DATE)
		RETURNING CHAR(5) AS codret,
		CHAR(3)   AS formato_img;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(50);
	DEFINE cImgFormato CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cMensaje = '';
	LET cImgFormato = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cImgFormato;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validaimagenchequedev.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveBanco = '' OR pCuenta = '' OR pNumCheque = '' OR pLadoFt = '' OR dFechaPresenta IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cImgFormato;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cImgFormato;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		 
		EXECUTE PROCEDURE bditef:"informix".sp_validaimagencheque_dev(pCveBanco,pCuenta,pNumCheque,pLadoFt,dFechaPresenta)			 
				INTO cCodRetSp,cMensaje,cImgFormato;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_validaimagencheque_dev';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00719';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00720';	
		END IF;		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cImgFormato;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cImgFormato;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 20/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CHEQUES DEVUELTOS',
'DESCRIPCION: SPL que realiza la verificaciï¿½n si existe la imagen del cheque.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualiza_chqrevisados_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pIdRegistro INTEGER, pOpcion INTEGER)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualiza_chqrevisados_ccep.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pIdRegistro IS NULL  OR pOpcion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD

		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		IF pOpcion = 1 THEN
			UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
			SET id_status_proceso = 'R'
			WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND id_consultadetallecheque40 = pIdRegistro;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00017";
				RETURN cCodRet;        
			END IF;   
		END IF;
		
		IF pOpcion = 2 THEN
			UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
			SET (id_status_proceso, imagenf, imagent,imagen_formatof,imagen_formatot,tam_anv_img_cheque,tam_rev_img_cheque,ind_img_cheque) = ('F','','','','','','',0) 
			WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND id_consultadetallecheque40 = pIdRegistro;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00017";
				RETURN cCodRet;        
			END IF;   
		END IF;	
		
        RETURN cCodRet;    
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 29/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Actualiza la tabla sw_cc_consultadetallecheque40 con indicador de correccion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccep_eliminacheques_cod46(pUsuario CHAR(8), pIdFuncion CHAR(10),pDireccionMac CHAR(15), pIdsEliminar CHAR(500))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIddetallechq INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cDesc_banco  CHAR(40);
	DEFINE cCtareferencia CHAR(14);
	DEFINE iNum_cheque INTEGER;
	DEFINE dMonto_orig DECIMAL(14,2);
	DEFINE cNum_cuentadep CHAR(20);
	DEFINE cSi_transacc CHAR(4);
	DEFINE cAplica CHAR(2);
	DEFINE cMotivo_dev CHAR(37);																	 
	DEFINE cDigitalizado CHAR(1);
	DEFINE cCompensacion CHAR(3);
	DEFINE cTransacc CHAR(2);
	DEFINE cCodseguridad CHAR(3);
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);																	 
	DEFINE cTipo_cta_dep CHAR(2);
	DEFINE cNombreBen CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE cCodAlertamiento CHAR(2);	
	DEFINE bInTransaction BOOLEAN;
	DEFINE cIdPresentar CHAR(8);
	DEFINE cTipoOperacion CHAR(1);                   		
	DEFINE dFechaPresenta DATE;
	DEFINE cNumcte CHAR(1);
	DEFINE cCtaDeposito CHAR(1);	
	DEFINE cSucursal CHAR(1);
	DEFINE cMotivo CHAR(1);
	DEFINE cEjecutivoReviso CHAR(1);
	DEFINE dFechaRevision DATE;			
	DEFINE cTiempoIniRev CHAR(8);
	DEFINE cTiempoFinRev CHAR(8);
	DEFINE cDevuelto CHAR(1);
	DEFINE cRevisado CHAR(1);

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET iIddetallechq = 0;
	LET cBanco = '';
	LET cDesc_banco  = '';
	LET cCtareferencia = '';
	LET iNum_cheque = 0;
	LET dMonto_orig = 0.0;
	LET cNum_cuentadep = '';
	LET cSi_transacc = '';
	LET cAplica = '';
	LET cMotivo_dev  = '';																	 
	LET cDigitalizado = '';
	LET cCompensacion = '';
	LET cTransacc = '';
	LET cCodseguridad = '';
	LET cDigverpre = '';
	LET cDigverinter = '';																	 
	LET cTipo_cta_dep = '';
	LET cNombreBen = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cCodAlertamiento = '';
	LET bInTransaction = 'f';
	LET cIdPresentar = '';
	LET cTipoOperacion = '';                   		
	LET dFechaPresenta = NULL;
	LET cNumcte = '';
	LET cCtaDeposito = '';	
	LET cSucursal = '';
	LET cMotivo = '';
	LET cEjecutivoReviso = '';
	LET dFechaRevision  =NULL;			
	LET cTiempoIniRev = '';
	LET cTiempoFinRev = '';
	LET cDevuelto = '';
	LET cRevisado = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;
				
		ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';				
				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;				
					RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccep_eliminacheques_cod46.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pIdsEliminar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
				IF TRIM(pIdsEliminar) = 'TODOS' THEN
					FOREACH SELECT iddetallechq INTO cIdPresentar FROM bdicnweb:'informix'.ccep_procesacod46detalle_tmp
					
						UPDATE bdicnweb:'informix'.ccep_procesacod46detalle_tmp
						SET indReversar = 'E'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = cIdPresentar;			
					END FOREACH;
				ELSE
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pIdsEliminar, '|')
								INTO cIdPresentar
			
						UPDATE bdicnweb:'informix'.ccep_procesacod46detalle_tmp
						SET indReversar = 'E'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = cIdPresentar;		
					END FOREACH;
				END IF;
							
		COMMIT WORK;
		
		
		FOREACH SELECT iddetallechq,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,
							si_transacc,aplica,motivo_dev,digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,tipo_cta_dep,
							nombreBen,rfcCte,curpCte,codAlertamiento
					INTO iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
						cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,
						cCurpCte,cCodAlertamiento
					FROM bdicnweb:'informix'.ccep_procesacod46detalle_tmp
					WHERE usuario = pUsuario
					AND direccionMac = pDireccionMac
					AND indReversar = 'E'
			
			LET cTipoOperacion = '3';                   		
			LET dFechaPresenta = MDY(1, 1, 1900);
			LET cNumcte = '';
			LET cCtaDeposito = '';	
			LET cSucursal = '';
			LET cMotivo = '';
			LET cEjecutivoReviso = '';
			LET dFechaRevision = MDY(1, 1, 1900);			
			LET cTiempoIniRev = '00:00:00';
			LET cTiempoFinRev =  '00:00:00'; -- "hh:mm:ss"
			LET cDevuelto = '0';
			LEt cRevisado = '';
			 
			EXECUTE PROCEDURE bditef:'informix'.sp_cce_chequesrevisados(cTipoOperacion,'1',cEmpresa,Trim(cBanco), Trim(cCtareferencia) , 
							iNum_cheque, dFechaPresenta,Trim(cNumcte),cCtaDeposito,dMonto_orig,cSucursal,cMotivo,cEjecutivoReviso,
							dFechaRevision,cTiempoIniRev,cTiempoFinRev,cDevuelto,cRevisado)INTO cCodRetSp;
    
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cce_chequesrevisados';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
			END IF;		
		END FOREACH;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: /03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de hacer la eliminacion de cheques cod 46.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultachequescod47totales_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaHoy DATE, pFechadevol DATE, pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS iNoRegistros,
				  INTEGER AS iTotalValidos,
				  DECIMAL(18,2) AS dMontoTotalValido;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cNombreArchivoPRE CHAR(40);
	DEFINE cNombreArchivo CHAR(40);
	DEFINE iNombrePro INTEGER;
	DEFINE codret INTEGER;	
	DEFINE cCveBanco CHAR(3);
	DEFINE cDescBanco CHAR(40);
	DEFINE cCtaReferencia CHAR(40);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cSucursal CHAR(44);
	DEFINE cSiTransaccion CHAR(4);
	DEFINE contReg INTEGER;
	DEFINE dMontoTotalValido DECIMAL(18,2);	
	DEFINE cDigitalizado CHAR(1);
	DEFINE iTotalValidos INTEGER;	
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cCampoCliente CHAR(20);
	DEFINE cCampoCuenta CHAR(20);
	DEFINE cTablaClientes CHAR(30);
	DEFINE cNoCliente CHAR(20);
	DEFINE cNombreCte CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE iNoRegistros INTEGER;		
	DEFINE cCompensacion CHAR(3);
	DEFINE cTransacc CHAR(2);
	DEFINE cCodseguridad CHAR(3);
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);
	DEFINE cCtaRef CHAR(14);
	DEFINE cTipoEliminacion CHAR(50);
	
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreArchivoPRE = '';
	LET cNombreArchivo = '';
	LET iNombrePro = 0;
	LET codret = 0;
	LET cCveBanco = '';
	LET cDescBanco = '';
	LET cCtaReferencia = '';
	LET iNumCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cSucursal = '';
	LET cSiTransaccion = '';
	LET contReg = 0;
	LET dMontoTotalValido = 0.0;
	LET cDigitalizado = '';
	LET iTotalValidos = 0;
	LET cTipoCuentaDep = '';
	LET cCampoCliente  = '';
	LET cCampoCuenta = '';
	LET cTablaClientes = '';
	LET cNoCliente = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cCodAlertamiento = '';
	LET iNoRegistros = 0;
	LET cCompensacion= '';
	LET cTransacc = '';
	LET cCodseguridad = '';
	LET cDigverpre = '';
	LET cDigverinter = '';
	LET cCtaRef = '';
	LET cTipoEliminacion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultachequescod47totales_ccep.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaHoy IS NULL OR pFechadevol IS NULL OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
		END IF;		
		
		LET cNombreArchivo = 'ELI_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y')||'_MN';
		SELECT COUNT(nombrearchivo)
		INTO iNombrePro
		FROM bditef:cce_encabezado 
		WHERE nombrearchivo = cNombreArchivo;
		
		IF iNombrePro <> 0 THEN
			LET cCodRet = '00778';
			RETURN cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
		END IF;
		
		DELETE FROM bdicnweb:"informix".ccep_procesacod47detalle_tmp;
		
		LET cNombreArchivoPRE = 'PRE_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y')||'_MN_01';
		LET contReg = 0;
		LET dMontoTotalValido = 0.0;
		
		FOREACH SELECT cod_ret::integer, banco, nom_banco, SUBSTR(referencia, 6, 20) AS referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion
					INTO iCodRetSp, cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cSiTransaccion
					FROM TABLE(PROCEDURE bdicheq:'informix'.sp_cce_consultar_chequespresentados(cEmpresa, TO_CHAR(DATE(pFechaHoy), '%Y%m%d'),cNombreArchivoPRE)) 
						AS sc_cce_presentada(cod_ret, banco, nom_banco, referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion)
		
					IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultar_detallecheques';
					ELIF iCodRetSp = 1 THEN 
						LET cCodRet = '00003';
					END IF;	
					
					LET cCtaRef = SUBSTR(cCtaReferencia, 10, 20);			
					LET cTipoEliminacion = 'Devolucion Interna';
					-- SE CONSULTA EL DETALLE DE L0S CHEQUES
					
					
					FOREACH SELECT cod_ret::INTEGER AS codret, compensacion, transaccion, cod_seguridad, digverpre, digverinter
						INTO iCodRetSp, cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter
						FROM TABLE (PROCEDURE bditef:'informix'.sp_cce_consultar_detallecheques(cEmpresa, cCveBanco, cCtaRef, iNumCheque))
						AS detalle_cheque(cod_ret, compensacion, transaccion, cod_seguridad, digverpre, digverinter)
						
							--LET iCodRet = cCodRetSp::INTEGER;
							IF codret < 0 THEN
									RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultar_detallecheques';
							ELIF codret = 1 THEN 
								LET cCodRet = '00003';
							END IF;

							IF iCodRetSp = 0 THEN
								LET cDigitalizado = 'S';						
								LET iTotalValidos = iTotalValidos + 1;
								LET dMontoTotalValido = dMontoTotalValido + mImporte;
							ELSE
								LET cDigitalizado = 'N';	
								LET cTipoEliminacion = 'datos detalle cheque no encontrados';
							END IF;
							
						-- CONSULTAR EL NOMBRE Y EL RFC (MAPEO)
							SELECT tipo_cta_dep, campo_cliente, campo_cuenta, tabla_clientes
							INTO cTipoCuentaDep, cCampoCliente, cCampoCuenta, cTablaClientes
							FROM bditef:'informix'.cce_mapeo_cecoban
							WHERE empresa = cEmpresa
								AND transacc = cSiTransaccion;
								
							IF cTipoCuentaDep IS NULL THEN -- ERROR DE QUE NO SE ENCONTRO EL MAPEO CECOBAN
								LET cDigitalizado = 'N';
								LET cTipoEliminacion = 'datos cuenta Cte no encontrada';								
								--RETURN cCodRet,;
							ELSE
								---- CONSULTA PREPARADA
								PREPARE noClienteStmt FROM 'SELECT '||TRIM(cCampoCliente)||' FROM '||TRIM(cTablaClientes)||' WHERE '||TRIM(cCampoCuenta)||" = '"||TRIM(cCuentaDeposito)||"';";
								DECLARE noClienteCur CURSOR FOR noClienteStmt;
								OPEN noClienteCur;
								FETCH noClienteCur INTO cNoCliente;
								CLOSE noClienteCur;
								
								SELECT cod_ret::integer AS codret, nombre, rfc, curp
								INTO iCodRetSp, cNombreCte, cRfcCte, cCurpCte
								FROM TABLE (PROCEDURE bditef:'informix'.consnomcte(cEmpresa, cNoCliente))
									AS tmp_nombre_cte(cod_ret, nombre, rfc, curp);	
								
									--LET iCodRet = cCodRetSp::INTEGER;
								IF codret < 0 THEN
										RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:consnomcte';
								ELIF codret <> 0 THEN 
									LET cDigitalizado = 'N';
									LET cTipoEliminacion = 'datos Cte no encontrados';	
								END IF;
								
								--RECUPERA EL VALOR ORIGINAL DEL CODIGO DE ALERTAMIENTO DEL PRESENTADO
								SELECT alertamiento 						
								INTO cCodAlertamiento
								FROM bditef:cce_detalle
								WHERE num_cuenta= Trim(cCtaRef) 
								AND num_cheque= iNumCheque 
								AND bco_receptor= cCveBanco
								AND fecha_presini = TO_CHAR(DATE(pFechadevol), '%Y%m%d')
								AND cod_operacion='40';
		
							END IF;
							
					
							INSERT INTO bdicnweb:"informix".ccep_procesacod47detalle_tmp
							(usuario,direccionMac,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,tipo_eliminacion,digitalizado,
							compensacion,transacc,codseguridad,digverpre,digverinter,sitransacc,nombreBen,rfcCte,curpCte,tipo_cta_dep,codAlertamiento,indeliminar)
							VALUES
							(pUsuario,pDireccionMac,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,
							cCompensacion,cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,'C');
							
							FREE noClienteCur;
							FREE noClienteStmt;
					END FOREACH;
		END FOREACH;

		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:'informix'.ccep_procesacod47detalle_tmp
		WHERE usuario = pUsuario
			AND direccionMac = pDireccionMac;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, 0, 0, 0;
		END IF;
		
		RETURN cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 16/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Conteo de registro totales  e insercion a tablas temporales del procesamiento de registros.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadelvorevcod46total_ccep(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechadevol DATE, pFechaHoy DATE,pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS iTotalValidos,
				  DECIMAL(20,2)	AS dMontoTotalValido,
				  INTEGER AS iNoBloque;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE codRet3 CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);    
	DEFINE cBanco CHAR(3);
    DEFINE cDesc_banco CHAR(40);
    DEFINE cCtaReferencia CHAR(40);
    DEFINE iNumCheque INTEGER;
    DEFINE dMonto_orig DECIMAL(14,2);
    DEFINE cNumCuentaDep CHAR(20);
    DEFINE cSucursal CHAR(44);
    DEFINE cSiTransacc CHAR(4);
    DEFINE cCodDescDevo CHAR(37);	
	DEFINE cDigitalizado CHAR(1);
	DEFINE cCompensacion CHAR(3);
	DEFINE cTransacc CHAR(2);
	DEFINE cCodseguridad CHAR(3);
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);    
	DEFINE iTotalValidos INTEGER;  
	DEFINE dMontoTotalValido DECIMAL(20,2);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cCampoCliente CHAR(20);
	DEFINE cCampoCuenta CHAR(20);
	DEFINE cTablaClientes CHAR(30);
	DEFINE cNoCliente CHAR(20);
	DEFINE cNombreCte CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE indDevuelto CHAR(1);	
	DEFINE dFechaHoy DATE;
	DEFINE iexistArch INTEGER;
	DEFINE indEliminado CHAR(1);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE iCodRet INTEGER;
	DEFINE cCtaRef CHAR(14);
	DEFINE indReversado INTEGER;
	DEFINE codret INTEGER;
	DEFINE iNoBloque INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET codRet3 = '';	
	LET cBanco = '';
	LET cDesc_banco = '';
	LET cCtaReferencia = '';
	LET iNumCheque = 0;
	LET dMonto_orig = 0.0;
	LET cNumCuentaDep = '';
	LET cSucursal = '';
	LET cSiTransacc = '';
	LET cCodDescDevo = '';
	LET cDigitalizado = '';
	LET cCompensacion = '';
	LET cTransacc = '';
	LET cCodseguridad = '';
	LET cDigverpre = '';
	LET cDigverinter = '';
	LET iTotalValidos = 0;  
	LET dMontoTotalValido = 0.0;
	LET cCampoCliente = '';
	LET cCampoCuenta = '';
	LET cTablaClientes = '';
	LET cNoCliente = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET indDevuelto = '';	
	LET dFechaHoy = null;
	LET iexistArch = 0;
	LET indEliminado = '';
	LET cCodAlertamiento = '';
	LET iCodRet = 0;
	LET cCtaRef = '';
	LET cTipoCuentaDep = '';
	LET indReversado = 0;
	LET codret = 0;
	LET iNoBloque = 0;
	
		BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadelvorevcod46total_ccep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pFechadevol IS NULL OR pFechaHoy IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
		END IF;
		
		SELECT MAX(num_bloque::INTEGER) + 1
		INTO iNoBloque
		FROM bditef:"informix".cce_encabezado
		WHERE fecha_presenta = TO_CHAR(DATE(pFechaHoy),'%Y%m%d')
		AND SUBSTR(nombrearchivo, 1, 3) = 'REV';

		IF NVL(iNoBloque, 0) = 0 THEN
				LET iNoBloque = 1;
		END IF;				
																	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;														
		
		LET iTotalValidos = 0;
		LET dMontoTotalValido = 0.0;
		
		DELETE FROM bdicnweb:"informix".ccep_procesacod46detalle_tmp;
		
		FOREACH SELECT cod_ret::integer, cve_banco, desc_banco, cuenta_referencia AS cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, sitransaccion,cCodDescDevo
				INTO cCodRetSp,cBanco,cDesc_banco,cCtaReferencia,iNumCheque,dMonto_orig,cNumCuentaDep,cSucursal,cSiTransacc,cCodDescDevo
				FROM TABLE(PROCEDURE bdicheq:'informix'.sp_cce_consultar_cheques46(cEmpresa,pFechadevol)) 
				AS sc_cce_presentada(cod_ret, cve_banco, desc_banco, cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, sitransaccion, cCodDescDevo)
					
		
				IF cCodRetSp < 0 THEN
					RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultar_cheques46';
				ELIF cCodRetSp = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
				END IF;
			

				LET cCtaRef = SUBSTR(cCtaReferencia, 10, 20);
			
				-- SE CONSULTA EL DETALLE DE L0S CHEQUES
				FOREACH SELECT cod_ret::INTEGER AS codret, compensacion, transaccion, cod_seguridad, digverpre, digverinter
						INTO iCodRetSp, cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter
						FROM TABLE (PROCEDURE bditef:'informix'.sp_cce_consultar_detallecheques(cEmpresa, cBanco, cCtaRef, iNumCheque))
						AS detalle_cheque(cod_ret, compensacion, transaccion, cod_seguridad, digverpre, digverinter)
					
					IF iCodRetSp = 0 THEN
						LET cDigitalizado = 'S';						
						LET iTotalValidos = iTotalValidos + 1;
					ELSE
						LET cDigitalizado = 'N';						
					END IF;
					
				-- CONSULTAR EL NOMBRE Y EL RFC (MAPEO)
					SELECT tipo_cta_dep, campo_cliente, campo_cuenta, tabla_clientes
					INTO cTipoCuentaDep, cCampoCliente, cCampoCuenta, cTablaClientes
					FROM bditef:'informix'.cce_mapeo_cecoban
					WHERE empresa = cEmpresa
						AND transacc = cSiTransacc;
						
					IF cTipoCuentaDep IS NULL THEN -- ERROR DE QUE NO SE ENCONTRO EL MAPEO CECOBAN
						RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
					END IF;
					
					---- CONSULTA PREPARADA
					PREPARE noClienteStmt0 FROM 'SELECT '||TRIM(cCampoCliente)||' FROM '||TRIM(cTablaClientes)||' WHERE '||TRIM(cCampoCuenta)||" = '"||TRIM(cNumCuentaDep)||"';";
					DECLARE noClienteCur0 CURSOR FOR noClienteStmt0;
					OPEN noClienteCur0;
					FETCH noClienteCur0 INTO cNoCliente;
					CLOSE noClienteCur0;
					
					SELECT cod_ret::integer, nombre, rfc, curp
					INTO iCodRetSp, cNombreCte, cRfcCte, cCurpCte
					FROM TABLE (PROCEDURE bditef:'informix'.consnomcte(cEmpresa, cNoCliente))
					AS tmp_nombre_cte(cod_ret, nombre, rfc, curp);
					
					--VALIDAR SI EL CHEQUE FUE DEVUELTO POR CAMARA PARA ESE DIA
					--Y LO OMITE DE LA INSERCION
					LET indDevuelto = '0';
					SELECT codigo_retorno 
					INTO codRet3
					FROM bditef:cce_cheques_dev 
					WHERE empresa= cEmpresa 
					AND cvebanco= Trim(cBanco)
					AND numcuenta= Trim(cCtaRef)
					AND numcheque= iNumCheque
					AND fechapresenta = pFechadevol;
					
					IF codRet3 = '000' THEN
						LET indDevuelto = '1';
					END IF;
					
					
					--VALIDAR SI UN CHEQUE FUE REVERSADO DURANTE EL DIA
					--Y LO OMITE DE LA INSERCION
					
					--Consulta fecha
					SELECT fecha_hoy 
					INTO dFechaHoy
					FROM bdicheq:'informix'.sc_fechas
					WHERE empresa = cEmpresa;
					
					LET indReversado = '0';
					SELECT COUNT(nombrearchivo) 
					INTO iexistArch
					FROM bditef:cce_detalle
					WHERE bco_receptor= Trim(cBanco)
					AND num_cuenta= Trim(cCtaRef) 
					AND num_cheque= iNumCheque
					AND fecha_transfer= TO_CHAR(DATE(dFechaHoy), '%Y%m%d')
					AND cod_operacion='46';
					
					IF iexistArch > 0 THEN
						LET indReversado = '1';
					END IF;
					
					--VALIDAR SI UN CHEQUE FUE ELIMINADO EL DIA HAB ANTERIOR
					--Y LO OMITE DE LA INSERCION
					LET indEliminado = 0;
					LET iexistArch = 0;
					SELECT nombrearchivo
					INTO iexistArch
					FROM bditef:cce_detalle 
					WHERE bco_receptor = Trim(cBanco)
					AND num_cuenta = Trim(cCtaRef)
					AND num_cheque = iNumCheque
					AND fecha_transfer = TO_CHAR(DATE(pFechadevol), '%Y%m%d')
					AND cod_operacion = '47';
					
					IF iexistArch > 0 THEN
						LET indEliminado = '1';					
					END IF;
					
					IF indDevuelto = 0 AND indReversado = 0 AND indEliminado = 0 THEN
						--RECUPERA EL VALOR ORIGINAL DEL CODIGO DE ALERTAMIENTO DEL PRESENTADO
						SELECT alertamiento 						
						INTO cCodAlertamiento
						FROM bditef:cce_detalle
						WHERE num_cuenta= Trim(cCtaRef) 
						AND num_cheque= iNumCheque 
						AND bco_receptor= cBanco
						AND fecha_presini = TO_CHAR(DATE(pFechadevol), '%Y%m%d')
						AND cod_operacion='40';
						
						LET dMontoTotalValido = dMontoTotalValido + dMonto_orig;
						
						INSERT INTO bdicnweb:"informix".ccep_procesacod46detalle_tmp
						(usuario,direccionMac,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,si_transacc,aplica,motivo_dev,
						digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,
						tipo_cta_dep,nombreBen,rfcCte,curpCte,codAlertamiento,indReversar)
						VALUES
						(pUsuario,pDireccionMac,cBanco,cDesc_banco,TRIM(cCtaRef),iNumCheque,dMonto_orig,cNumCuentaDep,cSiTransacc,'S',cCodDescDevo,
						cDigitalizado,cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter,
						cTipoCuentaDep,cNombreCte,cRfcCte,cCurpCte,cCodAlertamiento,'C');
					ELSE
						LET iTotalValidos = iTotalValidos - 1;
					END IF;
					FREE noClienteCur0;
					FREE noClienteStmt0;
				END FOREACH;
			
	END FOREACH;
		
	RETURN cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 11/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Consulta registros a reversar y regresa no total de registros.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaprocescod41_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS idRowDetalle,	
				  CHAR(3) AS cBancoLibrado,
				  CHAR(50) AS cDescbancoLibrado,
				  DECIMAL(14,2) AS mImporte,
				  CHAR(13) AS cCuentaReferencia,
				  CHAR(10) AS cNumCheque,
				  CHAR(20)  AS cCuentaDeposito,
				  CHAR(70) AS cObservaciones,
				  CHAR(100) AS cMotivoDevolucion,
				  CHAR(2) AS cprocesar;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;		
	DEFINE idRowDetalle INTEGER;	
	DEFINE cBancoLibrado  CHAR(3);
	DEFINE cDescbancoLibrado CHAR(50);
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaReferencia CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cObservaciones CHAR(70);
	DEFINE cMotivoDevolucion CHAR(100);
	DEFINE cprocesar CHAR(2);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;	
	LET idRowDetalle = 0;	
	LET cBancoLibrado = '';
	LET cDescbancoLibrado = '';
	LET mImporte = 0.0;
	LET cCuentaReferencia = '';
	LET cNumCheque = '';
	LET cCuentaDeposito = '';
	LET cObservaciones = '';
	LET cMotivoDevolucion = '';
	LET cprocesar = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,
																											cMotivoDevolucion,cprocesar; 
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaprocescod41_ccep.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,
																											cMotivoDevolucion,cprocesar; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,
																											cMotivoDevolucion,cprocesar; 
		END IF;
		
		FOREACH
				SELECT iddetallechq,bancoLibrado,descbancoLibrado,importe,cuentaReferencia,numCheque,CuentaDeposito,observaciones,motivoDevolucion,procesar 
				INTO idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar 
				FROM bdicnweb:ccep_procesacod41detalle_tmp 
				WHERE usuario = pUsuario
				AND direccionMac = pDireccionMac
					
				LET iNoRegistros = iNoRegistros + 1; 
				RETURN cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,
																											cMotivoDevolucion,cprocesar WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar;
		END IF;	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 09/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Consulta la tabla temporal ccep_procesacod41detalle_tmp que tiene los datos procesados del archivo devol.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_datosdiahoy_cod47(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  DATE AS dFechaHoy,
				  CHAR(3) AS cNoBanco,
				  CHAR(1) AS cProcesado,
				  DATE AS dFechaHabilAnt;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNoBanco CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE iNombrePro INTEGER;
	DEFINE cProcesado CHAR(1);
	DEFINE dFechaHabilAnt DATE;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFecha = null;
	LET cNoBanco = '';
	LET cNombreArchivo = '';
	LET iNombrePro = 0;
	LET dFechaHabilAnt = null;		
	LET cProcesado = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_datosdiahoy_cod47.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;
		
		--obtiene la fecha Habil del dia.
		SELECT fecha_hoy INTO dFecha FROM bdinteg:'informix'.si_fechas;
		
		--calcula fecha de devolucion habil anterior
		EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFecha)
		INTO cCodRetSp, dFechaHabilAnt;
		
		IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_habil_ant';
		ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		--consulta numero banco propio
		SELECT valor INTO cNoBanco FROM bdinteg:si_param WHERE empresa = '001' and cod_param='5';
		
		--valida si ya fue procesada una eliminaciÃ³n el dÃ­a de hoy
		LET cNombreArchivo = 'ELI_'||TO_CHAR(DATE(dFecha), '%d%m%Y')||'_MN';
		SELECT COUNT(nombrearchivo)
		INTO iNombrePro
		FROM bditef:cce_encabezado 
		WHERE nombrearchivo = cNombreArchivo;
		
		IF iNombrePro <> 0 THEN
			LET cProcesado= 't';			
		END IF;
		
		RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA:17/03/2016 ',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Obtiene la fecha actual, cadigo de banco propio y validacion de archivo ya procesado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_eliminasinprocesartmpcod40(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_eliminasinprocesartmpcod40.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		 DELETE FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		 WHERE ejecutivo = pUsuario 
         AND direccion_mac = pDireccionMac 
		 AND chq_procesado <> '2'
		 AND ind_duplicado <>  '1';
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: JUNIO 2016',
'MODULO: CAMARA PRESENTADA',
'FUNCIONALIDAD: GENERADOR ARCHIVOS CODIGO40',
'DESCRIPCION: ELIMINA REGISTROS PARA NOS MOSTRARLOS EN LA GENERACION EXITOSA',
'BD: BDICNWEB';

CREATE PROCEDURE "informix".sp_genera_archivo_presencod46(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechadevol DATE, pFechaHoy DATE, pNoBloque INTEGER,
														  pNoBanco CHAR(3),pRutaDescarga CHAR(50), pDireccionMac CHAR(15), pIdsPresentados CHAR(500))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS TotalRegTruncados,
				  CHAR(30) AS NombreArchivo;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE cPrueba CHAR(1); 
	DEFINE iTotCheques INTEGER;
	DEFINE iTotImporte INTEGER;
	DEFINE itotRegTruncados INTEGER;
	DEFINE iBloqueInicial INTEGER;
	DEFINE cIdPresentar CHAR(8);
	DEFINE iNoDigitalizados INTEGER;	
	DEFINE cTipoRegistro CHAR(2);
	DEFINE cNumSecuencia CHAR(7);
	DEFINE cNumBanco CHAR(3);
	DEFINE cNoBanco CHAR(3);
	DEFINE cSentidoTransfer CHAR(1);
	DEFINE cPlazaCecoban CHAR(2);
	DEFINE cServicioTEI CHAR(1);
	DEFINE iDiaMesTransfer SMALLINT;
	DEFINE cFechaPresenta CHAR(8);
	DEFINE cUsoFuturo1 CHAR(9);
	DEFINE cTipoArchivo CHAR(1);
	DEFINE cUsoFuturo2 CHAR(302);	
	DEFINE iSecuencia INTEGER;
	DEFINE mMontoImagen DECIMAL(14,2);	
	DEFINE iIddetallechq INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cDesc_banco  CHAR(40);
	DEFINE cCtareferencia CHAR(14);
	DEFINE iNum_cheque INTEGER;
	DEFINE dMonto_orig DECIMAL(14,2);
	DEFINE cNum_cuentadep CHAR(20);
	DEFINE cSi_transacc CHAR(4);
	DEFINE cAplica CHAR(2);
	DEFINE cMotivo_dev CHAR(37);																	 
	DEFINE cDigitalizado CHAR(1);
	DEFINE cCompensacion CHAR(3);
	DEFINE cTransacc CHAR(2);
	DEFINE cCodseguridad CHAR(3);
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);																	 
	DEFINE cTipo_cta_dep CHAR(2);
	DEFINE cNombreBen CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE cCodOper CHAR(2);
	DEFINE cFechatrasnfer CHAR(8);
	DEFINE cBancoCedente CHAR(3);
	DEFINE cBancoLibrado CHAR(3);
	DEFINE cImporte CHAR(16);
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE cLoteEntrada CHAR(7);
	DEFINE cSecEntrada CHAR(4);
	DEFINE cLoteSAlida CHAR(7);
	DEFINE cSecSalida CHAR(4);
	DEFINE cCveTrans CHAR(2);
	DEFINE cPlazaCompensa CHAR(3);
	DEFINE cNumCuenta CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cCodSegur CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE iTotalRegTruncados INTEGER;
	DEFINE cTruncado CHAR(1);	
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cCtaDep CHAR(20);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(1);
	DEFINE cUsoFuturo CHAR(1);	
	DEFINE iTotalCheques INTEGER;
	DEFINE cTotRegs CHAR(7);
	DEFINE mTotalImporte DECIMAL(20,2);
	DEFINE cTipoSumario CHAR(2);
	DEFINE cTotalRegs CHAR(7);
	DEFINE cTotalRegTruncados CHAR(7);
	DEFINE cTipoGranSumario CHAR(2);
	DEFINE cSentido CHAR(1);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cNumOperaciones CHAR(7);
	DEFINE cNumBloques CHAR(2);
	DEFINE cFolio CHAR(9);
	DEFINE cFecha CHAR(8);
	DEFINE bInTransaction BOOLEAN;
	DEFINE cTranSBCcheque CHAR(4);
	DEFINE cCodRetTrasacc CHAR(3);
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cNoBloque CHAR(5);	
	DEFINE cImported CHAR(15);
	DEFINE cImportes CHAR(18);
	DEFINE cMontos CHAR(15);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cPrueba = ''; 
	LET iTotCheques = 0;
	LET iTotImporte = 0;
	LET itotRegTruncados = 0;
	LET iBloqueInicial = 0;
	LET cIdPresentar = '';
	LET iNoDigitalizados = 0;
	LET cTipoRegistro = '';
	LET cNumSecuencia = '';
	LET cNumBanco = '';
	LET cNoBanco = '';
	LET cSentidoTransfer = '';
	LET cPlazaCecoban = '';
	LET cServicioTEI = '';
	LET iDiaMesTransfer = 0;
	LET cFechaPresenta = '';
	LET cUsoFuturo1 = '';
	LET cTipoArchivo = '';
	LET cUsoFuturo2 = '';
	LET iSecuencia = 0;
	LET mMontoImagen = 0.0;
	LET iIddetallechq = 0;
	LET cBanco = '';
	LET cDesc_banco  = '';
	LET cCtareferencia = '';
	LET iNum_cheque = 0;
	LET dMonto_orig = 0.0;
	LET cNum_cuentadep = '';
	LET cSi_transacc = '';
	LET cAplica = '';
	LET cMotivo_dev = '';																	 
	LET cDigitalizado = '';
	LET cCompensacion = '';
	LET cTransacc = '';
	LET cCodseguridad = '';
	LET cDigverpre = '';
	LET cDigverinter = '';																	 
	LET cTipo_cta_dep = '';
	LET cNombreBen = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cCodAlertamiento = '';
	LET cTipoRegistro = '';
	LET cCodOper = '';
	LET cFechatrasnfer = '';
	LET cBancoCedente = '';
	LET cBancoLibrado = '';
	LET cImporte = '';
	LET cMonto = '';
	LET cCents = '';
	LET cLoteEntrada = '';
	LET cSecEntrada = '';
	LET cLoteSAlida = '';
	LET cSecSalida = '';
	LET cCveTrans = '';
	LET cPlazaCompensa = '';
	LET cNumCuenta = '';
	LET cNumCheque = '';
	LET cCodSegur = '';
	LET cUbicFis = '';
	LET iTotalRegTruncados = 0;
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cCtaDep = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET iTotalCheques = 0;
	LET cTotRegs = '';
	LET mTotalImporte = 0.0;
	LET cTipoSumario = '';
	LET cTotalRegs = '';
	LET cTotalRegTruncados = '';
	LET cTipoGranSumario = '';
	LET cSentido = '';
	LET cCodOperacion = '';
	LET cNumOperaciones = '';
	LET cNumBloques = '';
	LET cFolio = '';
	LET cFecha = '';
	LET bInTransaction = 'f';
	LET cTranSBCcheque = '';
	LET cCodRetTrasacc = '';
	LET mImporte = 0.0;
	LET cNoBloque ='';
	LET cImported ='';
	LET cImportes = '';
	LET cMontos = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, 0,'';
		END EXCEPTION;
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;		
		ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';				
				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;				
					RETURN cCodRet, 0,'';
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genera_archivo_presencod46.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechadevol IS NULL OR pFechaHoy IS NULL OR pNoBloque IS NULL  OR pNoBanco ='' OR
							 pRutaDescarga = '' OR 	pDireccionMac = '' OR pIdsPresentados = ''	THEN
			LET cCodRet = '00003';
			RETURN cCodRet, 0,'';
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, 0,'';
		END IF;
			
		LET cNombreArchivo = 'REV_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y')||'_MN_'||LPAD(pNoBloque, 2, '0');	
		LET cPrueba = '0'; --' 1 archivo prueba, 0 archivo real
		LET iTotCheques = 0;
		LET iTotImporte = 0;
		LET itotRegTruncados = 0;
		LET iBloqueInicial = 1;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			IF TRIM(pIdsPresentados) = 'TODOS' THEN
				FOREACH SELECT iddetallechq INTO cIdPresentar FROM  bdicnweb:'informix'.ccep_procesacod46detalle_tmp
											
					UPDATE bdicnweb:'informix'.ccep_procesacod46detalle_tmp
					SET indReversar = 'R'
					WHERE usuario = pUsuario
					AND direccionMac = pDireccionMac
					AND iddetallechq = TRIM(cIdPresentar)::INTEGER;			
				END FOREACH;
			ELSE
				FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pIdsPresentados, '|')
								INTO cIdPresentar
			
					UPDATE bdicnweb:'informix'.ccep_procesacod46detalle_tmp
					SET indReversar = 'R'
					WHERE usuario = pUsuario
					AND direccionMac = pDireccionMac
					AND iddetallechq = TRIM(cIdPresentar)::INTEGER;
			
				END FOREACH;
			END IF;
			
		COMMIT WORK;
		
		
		SELECT COUNT(*)
		INTO iNoDigitalizados
		FROM bdicnweb:'informix'.ccep_procesacod46detalle_tmp
		WHERE usuario = pUsuario
		AND direccionMac = pDireccionMac
		AND indReversar = 'R'
		AND digitalizado = 'S';
		
		
		
		IF iNoDigitalizados > 0 THEN
		--================
		-- CCE ENCABEZADO
		--================
			LET cTipoRegistro = '01';      --' encabezado
			LET cNumSecuencia = ''||iBloqueInicial;
			LET cNumSecuencia = LPAD(TRIM(cNumSecuencia),7,'0');
			LET cNumBanco = pNoBanco;      --' banco bancoppel
			LET cSentidoTransfer = 'E';    --' bancoppel --> cecoban
			LET cPlazaCecoban = '01';
			LET cServicioTEI = '1';        --' moneda nacional
			LET iDiaMesTransfer = DAY(pFechaHoy);
			LET cNoBloque = LPAD(pNoBloque, 5, '0');
			LET cFechaPresenta = TO_CHAR(pFechaHoy, '%Y%m%d');
			LET cUsoFuturo1 = ' ';
			LET cTipoArchivo = cPrueba;
			LET cUsoFuturo2 = ' ';
			
			-- ESCRITURA DE LA CADENA DE TEXTO EN UN ARCHIVO
			SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cNumBanco||cSentidoTransfer||cPlazaCecoban||cServicioTEI||LPAD(iDiaMesTransfer, 2, '0')||
							cNoBloque||cFechaPresenta||LPAD(cUsoFuturo1,9,' ')||cTipoArchivo||LPAD(cUsoFuturo2,302,' ')||'" > '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
		
			EXECUTE PROCEDURE bditef:'informix'.sp_cce_guardar_encabezado(cNombreArchivo, cTipoRegistro, cNumSecuencia, cNumBanco, 
											cSentidoTransfer, cPlazaCecoban, cServicioTEI, LPAD(iDiaMesTransfer, 2, '0'),cNoBloque, 
											cFechaPresenta, cTipoArchivo, pUsuario, pFechaHoy) INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_encabezado';
			END IF;


		  -- '================
		  -- '  CCE DETALLE
		  -- '================
			LET iSecuencia = 0;
			SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
			FOREACH SELECT iddetallechq,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,
							si_transacc,aplica,motivo_dev,digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,tipo_cta_dep,
							nombreBen,rfcCte,curpCte,codAlertamiento
					INTO iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
						cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,
						cCurpCte,cCodAlertamiento
					FROM bdicnweb:'informix'.ccep_procesacod46detalle_tmp
					WHERE usuario = pUsuario
					AND direccionMac = pDireccionMac
					AND indReversar = 'R'
				
				
					IF iIddetallechq IS NOT NULL THEN
						LET iSecuencia = iSecuencia + 1;
						LET cTipoRegistro = '02';  --' tipo detalle
						LET cNumSecuencia = ''||(iBloqueInicial + iSecuencia);
						LET cNumSecuencia = LPAD(TRIM(cNumSecuencia),7,'0');						
						LET cCodOper = '46'; -- ' 40 presentacion - 41 devoluciones
										 --' 12 presentacion de consulta interbancaria - 46 Reverso presentacion
						LET cFechatrasnfer = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');
						LET cBancoCedente = pNoBanco;      --' banco bancoppel
						LET cBancoLibrado = cBanco;
						
						-- formateo importe						
						LET cImported = '';
						LET cImported = TO_CHAR(dMonto_orig);
						LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
						LET cMonto = LPAD(TRIM(cMonto),12,'0');
						LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
						LET cImported = TRIM(cMonto ||'.'|| LPAD(TRIM(cCents),2,'0'));
				
				
						LET cLoteEntrada = '0000000';
						LET cSecEntrada = '0000';
						LET cLoteSalida = '0000000';
						LET cSecSalida = '0000';
						LET cCveTrans  = LPAD(TRIM(cTransacc),2,'0');
						LET cPlazaCompensa= LPAD(TRIM(cCompensacion),3,'0');
						LET cNumCuenta = LPAD(TRIM(cCtareferencia),13,'0');
						LET cNumCheque = ''||iNum_cheque;					
						LET cNumCheque = LPAD(TRIM(cNumCheque),10,'0');	
						
						LET cCodSegur = LPAD(TRIM(cCodseguridad),3,'0');
						LET cUbicFis = '00000000';
						
						--' 0 truncado con imagen - 1 truncado sin imagen
						If dMonto_orig > mMontoImagen Then
							LET cTruncado = '0';
							LET iTotalRegTruncados = iTotalRegTruncados + 1;
						Else
							LET cTruncado = '1';
						End If		
						
												
						LET cMotivoDevol = SUBSTR(cMotivo_dev,1,2);
						LET cFechaInicial = TO_CHAR(DATE(pFechadevol), '%Y%m%d');
						LET cPlazaIntercam = '01'; -- mexico df
						
						IF TRIM(cRfcCte) = '' OR cRfcCte IS NULL  THEN
							LET cRfcCte = 'RFC NO DISP';
						ELSE	
							LET cRfcCte = TRIM(cRfcCte);
						END IF;
						
						IF TRIM(cCurpCte) = '' THEN
							LET cCurpCte = ' ';
						ELSE
							LET cCurpCte = TRIM(cCurpCte);
						END IF;
						
						LET cCtaDep = LPAD(TRIM(cNum_cuentadep),20,'0');
						
						LET cCtaAlertamiento = '00';
						
						SELECT numero INTO cTranSBCcheque FROM bdinteg:si_transacc where empresa= cEmpresa and abreviatura = 'DEPLOCALREGCC';
						
						IF cSi_transacc <> 	cTranSBCcheque THEN
							LET cCtaAlertamiento = '99';
						ELSE
							EXECUTE PROCEDURE bditef:cta_alertamiento(cEmpresa, cTipo_cta_dep) INTO cCodRetTrasacc, cCodAlertamiento;
							
							If cCodRetTrasacc = '000' THEN
								LET cCtaAlertamiento = cCodAlertamiento;
							END IF;
							
						END IF;

						LET cFolioSeguro = ' ';
						LET cUsoFuturo = ' ';

						-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
						SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOper||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
										cLoteEntrada||cSecEntrada||cLoteSalida||cSecSalida||cCveTrans||cPlazaCompensa||
										cNumCuenta||cNumCheque||LPAD(cDigverinter,1,'0')||LPAD(cDigverpre,1,'0')||
										cCodSegur||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||LPAD(cRfcCte,13,' ')||
										LPAD(cCurpCte,18, ' ')||LPAD(cTipo_cta_dep,2,'0')||LPAD(TRIM(NVL(cNum_cuentadep,'')),20,'0')||LPAD(cNombreBen,40,' ')||cCtaAlertamiento||
										LPAD(cFolioSeguro,12,' ')||LPAD(cUsoFuturo,120,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
																				
						LET iTotalCheques = iTotalCheques + 1;	
						LET mTotalImporte = mTotalImporte + dMonto_orig;
						
						-- GRABADO EN BASE DEL DETALLE
						EXECUTE PROCEDURE bditef:sp_cce_guardar_detalle(cNombreArchivo,cTipoRegistro,cNumSecuencia,cCodOper,cFechatrasnfer,
						cBancoCedente,cBancoLibrado,dMonto_orig,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTrans,cPlazaCompensa,
						cNumCuenta,cNumCheque,LPAD(cDigverinter,1,'0'),LPAD(cDigverpre,1,'0'),cCodSegur,
						cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,LPAD(cTipo_cta_dep,2,'0'),
						cCtaDep,cNombreBen,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
						END IF;
						
						UPDATE bdicnweb:'informix'.ccep_procesacod46detalle_tmp
						SET digitalizado = 'S'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = iIddetallechq;
							
					END IF;
			END FOREACH;

			
			-- '================
			-- ' CCE SUMARIO
			-- '================    
			LET cTipoSumario = '09';  --' tipo sumario			
			LET iSecuencia = iSecuencia + 2;
			LET cNumSecuencia = LPAD(TO_CHAR(iSecuencia),7,'0');				
			LET cCodOper = '46';   --' 40 presentacion - 41 devoluciones
								   --' 12 presentacion de consulta interbancaria - 46 Reverso presentacion					
			LET cTotRegs = LPAD(TO_CHAR(iTotalCheques),7,'0');			
			LET cImportes = '';                 
			LET cImportes = TO_CHAR(mTotalImporte);
			LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
			LET cMontos = LPAD(TRIM(cMontos),15,'0');
			LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
			LET cImportes = TRIM(cMontos ||'.'|| LPAD(cCents,2,'0'));			
			LET cTotalRegTruncados = TO_CHAR(iTotalRegTruncados);
			LET cTotalRegTruncados = LPAD(TRIM(cTotalRegTruncados),7,'0');
			LET cUsoFuturo=' ';

			-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
			SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOper||cTotRegs||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,300,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
		
			EXECUTE PROCEDURE bditef:sp_cce_guardar_sumario(cNombreArchivo,cTipoSumario,cNumSecuencia,cCodOperacion,iTotalCheques,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
			END IF;
						
			-- '==================
			-- ' CCE GRAN SUMARIO
			-- '==================	
			LET cTipoGranSumario = '51';
			LET cSentido = 'E';
			LET cCodOperacion = '46';
			LET cNumOperaciones =  cTotRegs;
			LET cNumBloques = '01';
			LET cNumBanco = pNoBanco;
			LET cFolio = LPAD(pNoBloque,9,'0');
			LET cFecha = TO_CHAR(pFechaHoy, '%Y%m%d');			
			
			LET cImportes = '';                 
			LET cImportes = TO_CHAR(mTotalImporte);
			LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
			LET cMontos = LPAD(TRIM(cMontos),15,'0');
			LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
			LET cImportes = TRIM(cMontos ||'.'|| LPAD(cCents,2,'0'));
			
			LET cTotalRegTruncados = LPAD(TO_CHAR(iTotalRegTruncados),7,'0');
			LET cUsoFuturo=' ';
    
			-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
			SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||cNumBloques||cNumBanco||cFolio||cFecha||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,284,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
		
			EXECUTE PROCEDURE bditef:sp_cce_guardar_gransumario(cNombreArchivo,cTipoGranSumario,cSentido,cCodOperacion,iTotalCheques,cNumBloques,
			cNumBanco,pNoBloque,cFecha,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
			END IF;
			
			LET cNombreArchivo = TRIM(cNombreArchivo)||'.cce';
			
		ELSE
			LET cCodRet = '00768';
		END IF;	
	END;
	
	IF bInTransaction = 't' THEN
			BEGIN WORK;
	END IF;
	
	RETURN cCodRet,iTotalRegTruncados,cNombreArchivo;	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 14/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Genera el archivo cod 46 reverso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genera_archivo_presencod47(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaHoy DATE, pNoBloque INTEGER,
														  pNoBanco CHAR(3),pRutaDescarga CHAR(50), pDireccionMac CHAR(15), pIdsEliminar CHAR(500))
						RETURNING CHAR(5) AS codret,
								  INTEGER AS TotalRegTruncados,
								  CHAR(30) AS NombreArchivo;
				  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE cPrueba CHAR(1); 
	DEFINE iTotCheques INTEGER;
	DEFINE iTotImporte INTEGER;
	DEFINE itotRegTruncados INTEGER;
	DEFINE iBloqueInicial INTEGER;
	DEFINE cIdPresentar CHAR(8);		  				  
	DEFINE cTipoRegistro CHAR(2);
	DEFINE cNumSecuencia CHAR(7);
	DEFINE cNumBanco CHAR(3);
	DEFINE cNoBanco CHAR(3);
	DEFINE cSentidoTransfer CHAR(1);
	DEFINE cPlazaCecoban CHAR(2);
	DEFINE cServicioTEI CHAR(1);
	DEFINE iDiaMesTransfer SMALLINT;
	DEFINE cFechaPresenta CHAR(8);
	DEFINE cUsoFuturo1 CHAR(9);
	DEFINE cTipoArchivo CHAR(1);
	DEFINE cUsoFuturo2 CHAR(302);			  
	DEFINE iSecuencia INTEGER;
	DEFINE mMontoImagen DECIMAL(14,2);			  				  
	DEFINE iIddetallechq INTEGER;
	DEFINE cCveBanco CHAR(3);
	DEFINE cDescBanco  CHAR(40);
	DEFINE cCtaRef CHAR(14);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cTipoEliminacion CHAR(50);																	 
	DEFINE cDigitalizado CHAR(1);	
	DEFINE cCompensacion CHAR(3);
	DEFINE cTransacc CHAR(2);
	DEFINE cCodseguridad CHAR(3);
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);
	DEFINE cSiTransaccion CHAR(4);
	DEFINE cNombreCte CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);	
	DEFINE cTipoCuentaDep CHAR(2);		
	DEFINE cCodAlertamiento CHAR(2);			  					
	DEFINE cCodOper CHAR(2);
	DEFINE cFechatrasnfer CHAR(8);
	DEFINE cBancoCedente CHAR(3);
	DEFINE cBancoLibrado CHAR(3);
	DEFINE cImporte CHAR(16);
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE cLoteEntrada CHAR(7);
	DEFINE cSecEntrada CHAR(4);
	DEFINE cLoteSAlida CHAR(7);
	DEFINE cSecSalida CHAR(4);
	DEFINE cCveTrans CHAR(2);
	DEFINE cPlazaCompensa CHAR(3);
	DEFINE cNumCuenta CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cCodSegur CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE iTotalRegTruncados INTEGER;
	DEFINE cTruncado CHAR(1);	
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cCtaDep CHAR(20);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(1);
	DEFINE cUsoFuturo CHAR(1);	
	DEFINE iTotalCheques INTEGER;
	DEFINE cTotRegs CHAR(7);
	DEFINE mTotalImporte DECIMAL(20,2);
	DEFINE cTipoSumario CHAR(2);
	DEFINE cTotalRegs CHAR(7);
	DEFINE cTotalRegTruncados CHAR(7);
	DEFINE cTipoGranSumario CHAR(2);
	DEFINE cSentido CHAR(1);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cNumOperaciones CHAR(7);
	DEFINE cNumBloques CHAR(2);
	DEFINE cFolio CHAR(9);
	DEFINE cFecha CHAR(8);
	DEFINE bInTransaction BOOLEAN;
	DEFINE cTranSBCcheque CHAR(4);
	DEFINE cCodRetTrasacc CHAR(3);
	DEFINE cNoBloque CHAR(5);
	DEFINE cImported CHAR(15);
	DEFINE cImportes CHAR(18);
	DEFINE cMontos CHAR(15);

	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '';
	LET cNombreArchivo = '';
	LET cPrueba = ''; 
	LET iTotCheques = 0;
	LET iTotImporte = 0;
	LET itotRegTruncados = 0;
	LET iBloqueInicial = 0;
	LET cIdPresentar = '';		  
	LET cTipoRegistro  = '';
	LET cNumSecuencia = '';
	LET cNumBanco = '';
	LET cNoBanco  = '';
	LET cSentidoTransfer = '';
	LET cPlazaCecoban = '';
	LET cServicioTEI = '';
	LET iDiaMesTransfer = 0;
	LET cFechaPresenta = '';
	LET cUsoFuturo1 = '';
	LET cTipoArchivo = '';
	LET cUsoFuturo2 = ''; 
	LET iSecuencia = 0;
	LET mMontoImagen = 0.0;			  
	LET iIddetallechq = 0;
	LET cCveBanco = '';
	LET cDescBanco = '';
	LET cCtaRef = '';
	LET iNumCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cTipoEliminacion = '';																	 
	LET cDigitalizado  = '';	
	LET cCompensacion  = '';
	LET cTransacc = '';
	LET cCodseguridad = '';
	LET cDigverpre = '';
	LET cDigverinter  = '';
	LET cSiTransaccion = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cCurpCte  = '';	
	LET cTipoCuentaDep = '';		
	LET cCodAlertamiento = '';			  	
	LET cCodOper = '';
	LET cFechatrasnfer = '';
	LET cBancoCedente = '';
	LET cBancoLibrado = '';
	LET cImporte = '';
	LET cMonto = '';
	LET cCents = '';
	LET cLoteEntrada = '';
	LET cSecEntrada = '';
	LET cLoteSAlida = '';
	LET cSecSalida = '';
	LET cCveTrans = '';
	LET cPlazaCompensa = '';
	LET cNumCuenta = '';
	LET cNumCheque = '';
	LET cCodSegur  = '';
	LET cUbicFis = '';
	LET iTotalRegTruncados  = 0;
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cCtaDep = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET iTotalCheques = 0;
	LET cTotRegs = '';
	LET mTotalImporte = 0.0;
	LET cTipoSumario = '';
	LET cTotalRegs = '';
	LET cTotalRegTruncados = '';
	LET cTipoGranSumario = '';
	LET cSentido = '';
	LET cCodOperacion = '';
	LET cNumOperaciones = '';
	LET cNumBloques = '';
	LET cFolio = '';
	LET cFecha = '';
	LET bInTransaction = 'f';
	LET cTranSBCcheque = '';
	LET cCodRetTrasacc =  '';	
	LET cNoBloque = '';
	LET cImportes = '';
	LET cMontos = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, 0,'';
		END EXCEPTION;
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;
				
		ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';				
				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;				
					RETURN cCodRet, 0,'';
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genera_archivo_presencod47.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaHoy IS NULL OR pNoBloque IS NULL  OR pNoBanco ='' OR
							 pRutaDescarga = '' OR 	pDireccionMac = '' OR pIdsEliminar = ''	THEN
			LET cCodRet = '00003';
			RETURN cCodRet, 0,'';
		END IF;
		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, 0,'';
		END IF;
		

		LET cNombreArchivo = 'ELI_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y')||'_MN';
		
		LET cPrueba = '0'; --' 1 archivo prueba, 0 archivo real
		LET iTotCheques = 0;
		LET iTotImporte = 0;
		LET itotRegTruncados = 0;
		LET iBloqueInicial = 1;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
				IF TRIM(pIdsEliminar) = 'TODOS' THEN
					FOREACH SELECT iddetallechq INTO cIdPresentar FROM  bdicnweb:'informix'.ccep_procesacod47detalle_tmp
					
						UPDATE bdicnweb:'informix'.ccep_procesacod47detalle_tmp
						SET indeliminar = 'G'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = cIdPresentar;
					END FOREACH;
				ELSE
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pIdsEliminar, '|')
								INTO cIdPresentar
			
						UPDATE bdicnweb:'informix'.ccep_procesacod47detalle_tmp
						SET indeliminar = 'G'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = cIdPresentar;			
					END FOREACH;
				END IF;				
		COMMIT WORK;
		
			
		--================
		-- CCE ENCABEZADO
		--================
			LET cTipoRegistro = '01';      --' encabezado
			LET cNumSecuencia = TO_CHAR(iBloqueInicial);
			LET cNumSecuencia = LPAD(TRIM(cNumSecuencia),7,'0');
			LET cNumBanco = pNoBanco;      --' banco bancoppel
			LET cSentidoTransfer = 'E';    --' bancoppel --> cecoban
			LET cPlazaCecoban = '01';
			LET cServicioTEI = '1';        --' moneda nacional
			LET iDiaMesTransfer = DAY(pFechaHoy);
			LET cNoBloque = LPAD(TO_CHAR(iBloqueInicial), 5, '0');
			LET cFechaPresenta = TO_CHAR(pFechaHoy, '%Y%m%d');
			LET cUsoFuturo1 = ' ';
			LET cTipoArchivo = cPrueba;
			LET cUsoFuturo2 = ' ';
			
			-- ESCRITURA DE LA CADENA DE TEXTO EN UN ARCHIVO
			SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cNumBanco||cSentidoTransfer||cPlazaCecoban||cServicioTEI||LPAD(iDiaMesTransfer, 2,'0')||
							cNoBloque||cFechaPresenta||LPAD(cUsoFuturo1,9,' ')||cTipoArchivo||LPAD(cUsoFuturo2,302,' ')||'" > '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
			
			EXECUTE PROCEDURE bditef:'informix'.sp_cce_guardar_encabezado(cNombreArchivo, cTipoRegistro, cNumSecuencia, cNumBanco, 
											cSentidoTransfer, cPlazaCecoban, cServicioTEI, LPAD(iDiaMesTransfer, 2, '0'),cNoBloque, 
											cFechaPresenta, cTipoArchivo, pUsuario, pFechaHoy) INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_encabezado';
			END IF;


		 -- '================
		  -- '  CCE DETALLE
		  -- '================
		
			LET iSecuencia = 0;
			SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
			
			FOREACH SELECT iddetallechq,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,
				tipo_eliminacion,digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,sitransacc,nombreBen,rfcCte,curpCte,tipo_cta_dep,codAlertamiento
				INTO iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,
				cCompensacion,cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento
				FROM bdicnweb:'informix'.ccep_procesacod47detalle_tmp
				WHERE usuario = pUsuario
				AND direccionMac = pDireccionMac
				AND indeliminar = 'G'
					
					IF iIddetallechq IS NOT NULL THEN
						LET iSecuencia = iSecuencia + 1;
						LET cTipoRegistro = '02';  -- tipo detalle
						LET cNumSecuencia = TO_CHAR(iBloqueInicial + iSecuencia);
						LET cNumSecuencia = LPAD(TRIM(cNumSecuencia),7,'0');						
						LET cCodOper = '47'; -- 40 presentacion - 41 devoluciones
											 -- 12 presentacion de consulta interbancaria - 46 Reverso presentacion
											 -- 47 eliminaciÃ³n de presentacion corte 1
						LET cFechatrasnfer = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');
						LET cBancoCedente = pNoBanco;      --' banco bancoppel
						LET cBancoLibrado = cCveBanco;
				
				
						-- formateo importe						
						LET cImported = '';
						LET cImported = TO_CHAR(mImporte);
						LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
						LET cMonto = LPAD(TRIM(cMonto),12,'0');
						LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
						LET cImported = TRIM(cMonto ||'.'|| LPAD(TRIM(cCents),2,'0'));
				
				
						LET cLoteEntrada = '0000000';
						LET cSecEntrada = '0000';
						LET cLoteSalida = '0000000';
						LET cSecSalida = '0000';
						LET cCveTrans  = LPAD(cTransacc,2,'0');
						LET cPlazaCompensa= LPAD(TRIM(cCompensacion),3,'0');
						LET cNumCuenta = LPAD(TRIM(cCtaRef),13,'0');
						LET cNumCheque = LPAD(TO_CHAR(iNumCheque),10,'0');						
						
						LET cCodSegur = LPAD(TRIM(cCodseguridad),3,'0');
						LET cUbicFis = '00000000';
						
						--' 0 truncado con imagen - 1 truncado sin imagen
						If mImporte > mMontoImagen Then
							LET cTruncado = '0';
							LET iTotalRegTruncados = iTotalRegTruncados + 1;
						Else
							LET cTruncado = '1';
						End If		
						
						LET cMotivoDevol = '00'; --motivo dev para eliminados siempre es 00
						LET cFechaInicial = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');
						LET cPlazaIntercam = '01'; -- mexico df
						
						IF TRIM(cRfcCte) = ''  OR cRfcCte IS NULL THEN
							LET cRfcCte = 'RFC NO DISP';
						ELSE	
							LET cRfcCte = TRIM(cRfcCte);
						END IF;
						
						IF TRIM(cCurpCte) = '' THEN
							LET cCurpCte = ' ';
						ELSE
							LET cCurpCte = TRIM(cCurpCte);
						END IF;
						
						LET cCtaDep = LPAD(cCuentaDeposito,20,'0');
											
						LET cCtaAlertamiento = '00';
						
						SELECT numero INTO cTranSBCcheque FROM bdinteg:si_transacc where empresa= cEmpresa and abreviatura = 'DEPLOCALREGCC';
						
						IF cSiTransaccion <> 	cTranSBCcheque THEN
							LET cCtaAlertamiento = '99';
						ELSE
							EXECUTE PROCEDURE bditef:cta_alertamiento(cEmpresa, cTipoCuentaDep) INTO cCodRetTrasacc, cCodAlertamiento;
							
							If cCodRetTrasacc = '000' THEN
								LET cCtaAlertamiento = cCodAlertamiento;
							END IF;
							
						END IF;

						LET cFolioSeguro = ' ';
						LET cUsoFuturo = ' ';

						-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
						SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOper||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
										cLoteEntrada||cSecEntrada||cLoteSalida||cSecSalida||cCveTrans||cPlazaCompensa||
										cNumCuenta||cNumCheque||LPAD(cDigverinter,1,'0')||LPAD(cDigverpre,1,'0')||
										cCodSegur||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||LPAD(cRfcCte,13,' ')||
										LPAD(cCurpCte,18, ' ')||LPAD(cTipoCuentaDep,2,'0')||LPAD(TRIM(NVL(cCuentaDeposito,'')),20,'0')||LPAD(cNombreCte,40,' ')||cCtaAlertamiento||
										LPAD(cFolioSeguro,12,' ')||LPAD(cUsoFuturo,120,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
																				
						LET iTotalCheques = iTotalCheques + 1;	
						LET mTotalImporte = mTotalImporte + mImporte;
						
					
						--GRABADO EN BASE DEL DETALLE					
						EXECUTE PROCEDURE bditef:sp_cce_guardar_detalle(cNombreArchivo,cTipoRegistro,cNumSecuencia,cCodOper,cFechatrasnfer,
						cBancoCedente,cBancoLibrado,mImporte,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTrans,cPlazaCompensa,
						cCtaRef,iNumCheque,LPAD(cDigverinter,1,'0'),LPAD(cDigverpre,1,'0'),cCodSegur,
						cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,LPAD(cTipoCuentaDep,2,'0'),
						cCuentaDeposito,cNombreCte,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
						END IF;
						
						
						EXECUTE PROCEDURE bdicheq:sp_cce_eliminar_cheques(cEmpresa,TRIM(cCuentaDeposito),TRIM(cCveBanco), iNumCheque,cImported)INTO cCodRetSp;
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_eliminar_cheques';
						END IF;
						
						UPDATE bdicnweb:'informix'.ccep_procesacod47detalle_tmp
						SET digitalizado = 'S'
						WHERE usuario = pUsuario
						AND direccionMac = pDireccionMac
						AND iddetallechq = iIddetallechq;
														
					END IF;
			END FOREACH;
			

			-- '================
			-- ' CCE SUMARIO
			-- '================    
			LET cTipoSumario = '09';  --' tipo sumario			
			LET iSecuencia = iSecuencia + 2;
			LET cNumSecuencia = TO_CHAR(iSecuencia);
			LET cNumSecuencia = LPAD(TRIM(cNumSecuencia),7,'0');				
			LET cCodOper = '47';   -- 40 presentacion - 41 devoluciones
								   -- 12 presentacion de consulta interbancaria - 46 Reverso presentacion
								   -- 47 eliminacion de presentaciones
			LET cTotRegs = LPAD(TO_CHAR(iTotalCheques),7,'0');						
			
			--formateo de importe
			LET cImportes = '';                 
			LET cImportes = TO_CHAR(mTotalImporte);
			LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
			LET cMontos = LPAD(TRIM(cMontos),15,'0');
			LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
			LET cImportes = TRIM(cMontos ||'.'|| LPAD(cCents,2,'0'));
			
			
			LET cTotalRegTruncados = LPAD(TO_CHAR(iTotalRegTruncados),7,'0');
			LET cUsoFuturo=' ';

			-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
			SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOper||cTotRegs||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,300,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
			
			EXECUTE PROCEDURE bditef:sp_cce_guardar_sumario(cNombreArchivo,cTipoSumario,cNumSecuencia,cCodOper,iTotalCheques,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
			END IF;
			
			
			-- '==================
			-- ' CCE GRAN SUMARIO
			-- '==================
			
			LET cTipoGranSumario = '51';
			LET cSentido = 'E';
			LET cCodOperacion = '47';
			LET cNumOperaciones =  LPAD(TO_CHAR(iTotalCheques),7,'0');
			LET cNumBloques = '01';
			LET cNumBanco = pNoBanco;
			LET cFolio = LPAD(TO_CHAR(iBloqueInicial),9,'0');
			LET cFecha = TO_CHAR(pFechaHoy, '%Y%m%d');
			
			LET cImportes = '';                 
			LET cImportes = TO_CHAR(mTotalImporte);
			LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
			LET cMontos = LPAD(TRIM(cMontos),15,'0');
			LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
			LET cImportes = TRIM(cMontos ||'.'|| LPAD(cCents,2,'0'));
			
			
			
			LET cTotalRegTruncados = LPAD(TO_CHAR(iTotalRegTruncados),7,'0');
			LET cUsoFuturo=' ';

			-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
			SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||cNumBloques||cNumBanco||cFolio||cFecha||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,284,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
			
			EXECUTE PROCEDURE bditef:sp_cce_guardar_gransumario(cNombreArchivo,cTipoGranSumario,cSentido,cCodOperacion,iTotalCheques,cNumBloques,
			cNumBanco,iBloqueInicial,cFecha,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
			END IF;
			
			LET cNombreArchivo = TRIM(cNombreArchivo)||'.cce';

			IF bInTransaction = 't' THEN
					BEGIN WORK;
			END IF;
			
			RETURN cCodRet,iTotalRegTruncados,cNombreArchivo;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 16/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Genera el archivo cod 47, eliminaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultachequesdevueltos(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCte CHAR(9),pFechaInicial DATE, pFechaFinal DATE,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 
		CHAR(5) AS codret,
		CHAR(2)		AS	motivo_devolucion,     
		CHAR(35)	AS	decripcion,    
		CHAR(3)		AS 	empresa,
		CHAR(3)		AS	clave_banco,
		CHAR(40)	AS 	descripcion_banco,
		CHAR(20)	AS	cuenta,
		CHAR(7)		AS	num_cheque,
		DATE		AS  fecha_presenta,
		MONEY(16,2)	AS	monto,
		MONEY(16,2)	AS	monto_aplica, 
		MONEY(16,2)	AS	suma_comision, 
		CHAR(3)		AS	formato_imagen, 
		INTEGER		AS	tamano_imagen_A,
		INTEGER		AS	tamano_imagen_B;				
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMotivoDevolucion CHAR(2);
	DEFINE cDecripcion CHAR(35);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClaveBanco CHAR(3);
	DEFINE cDescripcionBanco CHAR(40);
	DEFINE cCuenta CHAR(20);
	DEFINE NumCheque CHAR(7);
	DEFINE fechaPresenta DATE;
	DEFINE mMonto MONEY(18,2);
	DEFINE mMontoAplica MONEY(18,2);
	DEFINE mSumaComision MONEY(18,2);
	DEFINE cFormatoImagen CHAR(3);
	DEFINE iTamanoImagenA INTEGER;
	DEFINE iTamanoImagenB INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cMotivoDevolucion   = '';
	LET cDecripcion = '';
	LET cEmpresa = '';
	LET cClaveBanco = '';
	LET cDescripcionBanco = '';
	LET cCuenta = '';
	LET NumCheque = '';
	LET fechaPresenta = '';
	LET mMonto = 0.00;
	LET mMontoAplica = 0.00;
	LET mSumaComision = 0.00;
	LET cFormatoImagen = '';
	LET iTamanoImagenA = 0;
	LET iTamanoImagenB = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultachequesdevueltos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		FOREACH
			EXECUTE PROCEDURE bditef:"informix".sp_consultarchequesdevueltos3(pNumCte,pFechaInicial, pFechaFinal, pRegistros,pRecuperacion)
				INTO cCodRetSp,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_consultarchequesdevueltos3';
			END IF;
			IF pNumCte = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL  OR pRegistros IS NULL AND cCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
			END IF;
			IF cCodRetSp = 1 THEN
				LET cCodRet = '00718';	
				RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cMotivoDevolucion,UPPER(TRIM(cDecripcion)),cEmpresa,cClaveBanco,UPPER(TRIM(cDescripcionBanco)),cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB WITH RESUME;			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cMotivoDevolucion,cDecripcion,cEmpresa,cClaveBanco,cDescripcionBanco,cCuenta,NumCheque,fechaPresenta,mMonto,mMontoAplica,mSumaComision,cFormatoImagen,iTamanoImagenA,iTamanoImagenB;
		END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:Cheques Devueltos',
'DESCRIPCION: SPL que consulta el detalle de los cheques devueltos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultachequesdevueltos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9),pFechaInicial DATE, pFechaFinal DATE)	
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultachequesdevueltos_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNumCte = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		EXECUTE PROCEDURE bditef:"informix".sp_consultarchequesdevueltos3_totales(pNumCte,pFechaInicial, pFechaFinal)
			INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:sp_consultarchequesdevueltos2_totales';
		END IF;		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;

		RETURN cCodRet, iNumRegistros;		
	END;
END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:Cheques Devueltos',
'DESCRIPCION: SPL que consulta el total de los cheques devueltos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultachequetamdif(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
					CHAR(3) AS cvebanco,
					CHAR(40) AS descripcionbanco,
					CHAR(20) AS cuentareferencia,
					INTEGER AS nocheque,
					DECIMAL(14,2) AS importe,
					CHAR(20) AS cuentadeposito,
					CHAR(44) AS suscursaloperadora,
					CHAR(1) AS chqprocesado,
					CHAR(3) AS chqcompensacion,
					CHAR(2) AS chqtransaccion,
					CHAR(3) AS chqcodseguridad,
					CHAR(1) AS chqdigverpre,
					CHAR(1) AS chqdigverinter,
					CHAR(1) AS indimgcheque,
					INTEGER AS tamanversoimagen,
					INTEGER AS tamreversoimagen,
					CHAR(4) AS transaccion,
					CHAR(60) AS nombrecliente,
					CHAR(13) AS rfccliente,
					CHAR(20) AS curpcliente,
					CHAR(2) AS tipoctadeposito,
					INTEGER AS idregistro,
					CHAR(1) AS cIdStatusProceso;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cCveBanco CHAR(3);
	DEFINE cDescripcionBanco CHAR(40);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE iNoCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cSuscursalOperadora CHAR(44);
	DEFINE cChqProcesado CHAR(1);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cChqTransaccion CHAR(2);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnversoImagen INTEGER;
	DEFINE iTamReversoImagen INTEGER;
	DEFINE cTransaccion CHAR(4);
	DEFINE cNombreCliente CHAR(60);
	DEFINE cRfcCliente CHAR(13);
	DEFINE cCurpCliente CHAR(20);
	DEFINE cTipoCtaDeposito CHAR(2);
	DEFINE iIdRegistro INTEGER;
	DEFINE cIdStatusProceso CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	LET cCveBanco = '';
	LET cDescripcionBanco = '';
	LET cCuentaReferencia = '';
	LET iNoCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cSuscursalOperadora = '';
	LET cChqProcesado = '';
	LET cChqCompensacion = '';
	LET cChqTransaccion = '';
	LET cChqCodSeguridad = '';
	LET cChqDigVerPre = '';
	LET cChqDigVerInter = '';
	LET cIndImgCheque = '';
	LET iTamAnversoImagen = 0;
	LET iTamReversoImagen = 0;
	LET cTransaccion = '';
	LET cNombreCliente = '';
	LET cRfcCliente = '';
	LET cCurpCliente = '';
	LET cTipoCtaDeposito = '';
	LET iIdRegistro = 0;
	LET cIdStatusProceso = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultachequetamdif.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
		
		FOREACH SELECT banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, chq_procesado, 
					chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, 
					ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque,
					transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, id_consultadetallecheque40, id_status_proceso
				INTO cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte, cCuentaDeposito, cSuscursalOperadora, cChqProcesado,
					cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter,
					cIndImgCheque, iTamAnversoImagen, iTamReversoImagen,
					cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND id_status_proceso = 'D'
					
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso WITH RESUME;
					
			LET iNoRegistros = iNoRegistros + 1;
	
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 12/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener los cheques de cÃ³digo 40 tamanio diferentes en imagen.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
					CHAR(3) AS cvebanco,
					CHAR(40) AS descripcionbanco,
					CHAR(20) AS cuentareferencia,
					INTEGER AS nocheque,
					DECIMAL(14,2) AS importe,
					CHAR(20) AS cuentadeposito,
					CHAR(44) AS suscursaloperadora,
					CHAR(1) AS chqprocesado,
					CHAR(3) AS chqcompensacion,
					CHAR(2) AS chqtransaccion,
					CHAR(3) AS chqcodseguridad,
					CHAR(1) AS chqdigverpre,
					CHAR(1) AS chqdigverinter,
					CHAR(1) AS indimgcheque,
					INTEGER AS tamanversoimagen,
					INTEGER AS tamreversoimagen,
					CHAR(4) AS transaccion,
					CHAR(60) AS nombrecliente,
					CHAR(13) AS rfccliente,
					CHAR(20) AS curpcliente,
					CHAR(2) AS tipoctadeposito,
					INTEGER AS idregistro,
					CHAR(1) AS cIdStatusProceso;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cCveBanco CHAR(3);
	DEFINE cDescripcionBanco CHAR(40);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE iNoCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cSuscursalOperadora CHAR(44);
	DEFINE cChqProcesado CHAR(1);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cChqTransaccion CHAR(2);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnversoImagen INTEGER;
	DEFINE iTamReversoImagen INTEGER;
	DEFINE cTransaccion CHAR(4);
	DEFINE cNombreCliente CHAR(60);
	DEFINE cRfcCliente CHAR(13);
	DEFINE cCurpCliente CHAR(20);
	DEFINE cTipoCtaDeposito CHAR(2);
	DEFINE iIdRegistro INTEGER;
	DEFINE cIdStatusProceso CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	LET cCveBanco = '';
	LET cDescripcionBanco = '';
	LET cCuentaReferencia = '';
	LET iNoCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cSuscursalOperadora = '';
	LET cChqProcesado = '';
	LET cChqCompensacion = '';
	LET cChqTransaccion = '';
	LET cChqCodSeguridad = '';
	LET cChqDigVerPre = '';
	LET cChqDigVerInter = '';
	LET cIndImgCheque = '';
	LET iTamAnversoImagen = 0;
	LET iTamReversoImagen = 0;
	LET cTransaccion = '';
	LET cNombreCliente = '';
	LET cRfcCliente = '';
	LET cCurpCliente = '';
	LET cTipoCtaDeposito = '';
	LET iIdRegistro = 0;
	LET cIdStatusProceso = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultadetallechequecodigo40.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
		
		FOREACH SELECT banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, chq_procesado, 
					chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, 
					ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque,
					transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, id_consultadetallecheque40, id_status_proceso
				INTO cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte, cCuentaDeposito, cSuscursalOperadora, cChqProcesado,
					cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter,
					cIndImgCheque, iTamAnversoImagen, iTamReversoImagen,
					cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso WITH RESUME;
					
			LET iNoRegistros = iNoRegistros + 1;
	
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/02/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener el detalle de los cheques de cï¿½digo 40.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultadetallechequecodigo46(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                  INTEGER AS iIddetallechq,
                                  CHAR(3) AS cBanco,
                                  CHAR(40) AS cDesc_banco,
                                  CHAR(40) AS cCtareferencia,
                                  INTEGER AS iNum_cheque,
                                  DECIMAL(14,2) AS dMonto_orig,
                                  CHAR(20) AS cNum_cuentadep,
                                  CHAR(4) AS cSi_transacc,
                                  CHAR(2) AS cAplica,
                                  CHAR(37) AS cMotivo_dev,                                                                                                                               
                                  CHAR(1) AS cDigitalizado,
                                  CHAR(3) AS cCompensacion,
                                  CHAR(2) AS cTransacc,
                                  CHAR(3) AS cCodseguridad,
                                  CHAR(1) AS cDigverpre,
                                  CHAR(1) AS Digverinter,
                                  CHAR(2) AS cTipo_cta_dep,
                                  CHAR(60) AS cNombreBen,
                                  CHAR(13) AS cRfcCte,
                                  CHAR(20)      AS cCurpCte,
                                  CHAR(2) AS cCodAlertamiento,
								  INTEGER AS iTamImgChqAnverso,
								  INTEGER AS iTamImgChqReverso;
                                        

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iIddetallechq INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDesc_banco  CHAR(40);
        DEFINE cCtareferencia CHAR(14);
        DEFINE iNum_cheque INTEGER;
        DEFINE dMonto_orig DECIMAL(14,2);
        DEFINE cNum_cuentadep CHAR(20);
        DEFINE cSi_transacc CHAR(4);
        DEFINE cAplica CHAR(2);
        DEFINE cMotivo_dev CHAR(37);                                                                                                                                     
        DEFINE cDigitalizado CHAR(1);
        DEFINE cCompensacion CHAR(3);
        DEFINE cTransacc CHAR(2);
        DEFINE cCodseguridad CHAR(3);
        DEFINE cDigverpre CHAR(1);
        DEFINE cDigverinter CHAR(1);                                                                                                                                     
        DEFINE cTipo_cta_dep CHAR(2);
        DEFINE cNombreBen CHAR(60);
        DEFINE cRfcCte CHAR(13);
        DEFINE cCurpCte CHAR(20);
        DEFINE cCodAlertamiento CHAR(2);
		DEFINE iTamImgChqAnverso INTEGER;
        DEFINE iTamImgChqReverso INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET iIddetallechq = 0;
        LET cBanco = '';
        LET cDesc_banco = '';
        LET cCtareferencia = '';
        LET iNum_cheque = 0;
        LET dMonto_orig = 0.0;
        LET cNum_cuentadep = '';
        LET cSi_transacc = '';
        LET cAplica = '';
        LET cMotivo_dev = '';                                                                                                                                    
        LET cDigitalizado = '';
        LET cCompensacion = '';
        LET cTransacc = '';
        LET cCodseguridad = '';
        LET cDigverpre = '';
        LET cDigverinter = '';                                                                                                                                   
        LET cTipo_cta_dep = '';
        LET cNombreBen = '';
        LET cRfcCte = '';
        LET cCurpCte = '';
        LET cCodAlertamiento = '';
		LET iTamImgChqAnverso = 0;
        LET iTamImgChqReverso = 0;
        
                
        BEGIN   
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                                        cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,
                                        cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultadetallechequecodigo46.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                                        cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,
                                        cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                                        cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,
                                        cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF;
                
                FOREACH SELECT iddetallechq,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,
                               si_transacc,aplica,motivo_dev,digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,tipo_cta_dep,
                               nombreBen,rfcCte,curpCte,codAlertamiento,tamAnversoImg,tamReversoImg

                               INTO iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                               cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,cCodAlertamiento,
							   iTamImgChqAnverso,iTamImgChqReverso
                               FROM bdicnweb:'informix'.ccep_procesacod46detalle_tmp
                               WHERE usuario = pUsuario
                               AND direccionMac = pDireccionMac
                                
                               RETURN cCodRet,iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                               cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,
                               cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso WITH RESUME;
                                                
                     LET iNoRegistros = iNoRegistros + 1;    
                END FOREACH;
                
                IF iNoRegistros = 0 THEN
                                LET cCodRet = '00017';
                        
                        RETURN cCodRet,iIddetallechq,cBanco,cDesc_banco,cCtareferencia,iNum_cheque,dMonto_orig,cNum_cuentadep,cSi_transacc,cAplica,cMotivo_dev,
                                        cDigitalizado,cCompensacion,cTransacc,cCodseguridad,cDigverpre,cDigverinter,cTipo_cta_dep,cNombreBen,cRfcCte,cCurpCte,
                                        cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF; 
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 11/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener el detalle de los cheques de codigo 46.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultadetallechequecodigo47(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                  INTEGER AS iIddetallechq,
                                  CHAR(3) AS cCveBanco,
                                  CHAR(40) AS cDescBanco,
                                  CHAR(40) AS cCtaRef,
                                  INTEGER AS iNumCheque,
                                  DECIMAL(14,2) AS mImporte,
                                  CHAR(20) AS cCuentaDeposito,
                                  CHAR(50) AS cTipoEliminacion,                                                                                                                                                          
                                  CHAR(1) AS cDigitalizado,
                                  CHAR(3) AS cCompensacion,
                                  CHAR(2) AS cTransacc,
                                  CHAR(3) AS cCodseguridad,
                                  CHAR(1) AS cDigverpre,
                                  CHAR(1) AS cDigverinter,
                                  CHAR(4) AS cSiTransaccion,
                                  CHAR(60) AS cNombreCte,
                                  CHAR(13) AS cRfcCte,
                                  CHAR(20) AS cCurpCte,                           
                                  CHAR(2) AS cTipoCuentaDep,                     
                                  CHAR(2) AS cCodAlertamiento,
								  INTEGER AS iTamImgChqAnverso,
								  INTEGER AS iTamImgChqReverso;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        
        DEFINE iIddetallechq INTEGER;
        DEFINE cCveBanco CHAR(3);
        DEFINE cDescBanco  CHAR(40);
        DEFINE cCtaRef CHAR(14);
        DEFINE iNumCheque INTEGER;
        DEFINE mImporte DECIMAL(14,2);
        DEFINE cCuentaDeposito CHAR(20);
        DEFINE cTipoEliminacion CHAR(50);                                                                                                                                        
        DEFINE cDigitalizado CHAR(1);   
        DEFINE cCompensacion CHAR(3);
        DEFINE cTransacc CHAR(2);
        DEFINE cCodseguridad CHAR(3);
        DEFINE cDigverpre CHAR(1);
        DEFINE cDigverinter CHAR(1);
        DEFINE cSiTransaccion CHAR(4);
        DEFINE cNombreCte CHAR(60);
        DEFINE cRfcCte CHAR(13);
        DEFINE cCurpCte CHAR(20);       
        DEFINE cTipoCuentaDep CHAR(2);          
        DEFINE cCodAlertamiento CHAR(2);
		DEFINE iTamImgChqAnverso INTEGER;
        DEFINE iTamImgChqReverso INTEGER;
        
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        
        LET iIddetallechq = 0;
        LET cCveBanco = '';
        LET cDescBanco = '';
        LET cCtaRef = '';
        LET iNumCheque = 0;
        LET mImporte = 0.0;
        LET cCuentaDeposito = '';
        LET cTipoEliminacion  = '';                                                                                                                                      
        LET cDigitalizado = ''; 
        LET cCompensacion = '';
        LET cTransacc = '';
        LET cCodseguridad = '';
        LET cDigverpre = '';
        LET cDigverinter = '';
        LET cSiTransaccion = '';
        LET cNombreCte = '';
        LET cRfcCte = '';
        LET cCurpCte = '';      
        LET cTipoCuentaDep = '';                
        LET cCodAlertamiento = '';
		LET iTamImgChqAnverso = 0;
        LET iTamImgChqReverso = 0;
        
        
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,cCompensacion,
                                        cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultadetallechequecodigo47.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,cCompensacion,
                                        cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,cCompensacion,
                                        cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF;
                
                
                FOREACH SELECT iddetallechq,banco,desc_banco,ctareferencia,num_cheque,monto_orig,num_cuentadep,
                                tipo_eliminacion,digitalizado,compensacion,transacc,codseguridad,digverpre,digverinter,sitransacc,nombreBen,rfcCte,curpCte,tipo_cta_dep,codAlertamiento,tamAnversoImg,tamReversoImg
                                INTO iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,                                     
                                cCompensacion,cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso
                                FROM bdicnweb:'informix'.ccep_procesacod47detalle_tmp
                                WHERE usuario = pUsuario
                                AND direccionMac = pDireccionMac
                        
                        
                        
                        RETURN cCodRet, iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,
                                        cCompensacion,cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,
                                        cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso WITH RESUME;
                                        
                        LET iNoRegistros = iNoRegistros + 1;    
                END FOREACH;
                
                
                IF iNoRegistros = 0 THEN
                   LET cCodRet = '00017';
                        
                   RETURN cCodRet, iIddetallechq,cCveBanco,cDescBanco,cCtaRef,iNumCheque,mImporte,cCuentaDeposito,cTipoEliminacion,cDigitalizado,cCompensacion,
                          cTransacc,cCodSeguridad,cDigVerPre, cDigVerInter,cSiTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cCodAlertamiento,iTamImgChqAnverso,iTamImgChqReverso;
                END IF; 
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 16/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener el detalle de los cheques de codigo 47.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaimportececoban(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			MONEY(14,2) AS importe_cecoban;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE mImporte MONEY(14,2);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET mImporte = 0.00;
	LET iNoRegistros = 0;


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mImporte;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaimportececoban.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mImporte;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mImporte;
		END IF;

		SELECT valor
		INTO mImporte
		FROM bditef:'informix'.cce_param
		WHERE empresa = cEmpresa AND cod_param = '2';

		IF NVL(mImporte,0) = 0 THEN
			LET cCodRet = '00530'; --EL IMPORTE MÃXIMO DE CECOBAN NO EXISTE
		END IF;

		RETURN cCodRet, NVL(mImporte,0);

	END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/01/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: SPL que consulta el valor del importe para envio de imagen a cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_datoscarga_genarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
						  DATE AS fecha_habil_ant,
						  CHAR(3) AS cNoBanco;
                 
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE dFecha DATE;
        DEFINE dFechaHabilAnt DATE;
        DEFINE iNoRegistros INTEGER;
		DEFINE cNoBanco CHAR(3);
                
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET dFecha = '';
        LET dFechaHabilAnt = '';
        LET iNoRegistros = 0;
		LET cNoBanco = '';
        
		BEGIN                
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaHabilAnt, cNoBanco;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_datoscarga_genarchivo.out';
            --TRACE ON;
            
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHabilAnt, cNoBanco;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaHabilAnt, cNoBanco;
			END IF;
			
			--obtiene la fecga Habil anterior habil.
			SELECT fecha_hoy 
			INTO dFecha FROM bdinteg:'informix'.si_fechas;
			
			EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFecha)
			INTO cCodRetSp, dFechaHabilAnt;
			
			IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_habil_ant';
			ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, dFechaHabilAnt, cNoBanco;
			END IF;
			
			--consulta numero banco propio
			SELECT valor INTO cNoBanco FROM bdinteg:si_param WHERE empresa = '001' and cod_param='5';
			
			
			RETURN cCodRet, dFechaHabilAnt, cNoBanco;
	
	END;
        
END PROCEDURE 
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 02/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de consultar el dia habil anterior a la fecha consultada y numero de banco propio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_datosgral_archivocod46_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
						  DATE AS dFechaHoy,
						  CHAR(3) AS cNoBanco,
						  DATE AS dFechaHabilProx,
						  DATE AS dFechaHabilAnt,
						  DATE AS dFechaHabilAnt2;
               
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE dFecha DATE;
        DEFINE dFechaHabilAnt DATE;
		DEFINE dFechaHabilAnt2 DATE;
		DEFINE dFechaHabilProx DATE;
		DEFINE cNoBanco CHAR(3);
                
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET dFecha = '';
        LET dFechaHabilAnt = '';
		LET cNoBanco = '';
		LET dFechaHabilAnt2 = null;
		LET dFechaHabilProx = null;
        
		BEGIN                
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_datosgral_archivocod46_ccep.out';
            --TRACE ON;
            
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
			END IF;
			
			--obtiene la fecha Habil del dia.
			SELECT fecha_hoy 
			INTO dFecha FROM bdinteg:'informix'.si_fechas;
			
			--consulta numero banco propio
			SELECT valor INTO cNoBanco FROM bdinteg:si_param WHERE empresa = '001' and cod_param='5';
			
			
			--calcula fecha proxima habil
			EXECUTE PROCEDURE bditef:'informix'.cal_fecha_pre_fh(dFecha)
			INTO cCodRetSp, dFechaHabilProx;
			
			IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_fecha_pre_fh';
			ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003';
					RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
			END IF;
			
			
			--calcula fecha de devolucion habil anterior
			EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFecha)
			INTO cCodRetSp, dFechaHabilAnt;
			
			IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_habil_ant';
			ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003';
					RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
			END IF;
			
			
			--calcula fecha anterior de la fecha nueva
			EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFechaHabilProx)
			INTO cCodRetSp, dFechaHabilAnt2;
			
			IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_habil_ant';
			ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003';
					RETURN ;
			END IF;
			
			RETURN cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
	END;
        
END PROCEDURE 
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 09/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Consulta parametros de inicio para la generacion del codigo 46.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_reportecodigo46(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(43) AS banco,
				  CHAR(20) AS numerocuenta,
				  CHAR(7) AS numerocheque,
				  DECIMAL(16,2) AS monto,
				  CHAR(20) AS cuentaDeposito,
				  CHAR(130) AS cliente,
				  CHAR(40) AS motivoDevolucion,
				  CHAR(54) AS aplicado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNumerocuenta CHAR(20);
	DEFINE cNumerocheque CHAR(7);
	DEFINE dMonto DECIMAL(16,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cNumcte CHAR(20);
	DEFINE cRazonSocial CHAR(60);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApellidoPaterno CHAR(26);
	DEFINE cApellidoMaterno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cCodigoRetorno CHAR(5);
	DEFINE cCliente CHAR(130);
	DEFINE cBanco CHAR(43);
	DEFINE cMotivoDevolucion CHAR(40);
	DEFINE cAplicado CHAR(54);
	DEFINE cMotivo CHAR(2);
	DEFINE cDescripcionMotivo CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iRecuperacion = 0;
	LET cNumerocuenta = '';
	LET cNumerocheque = '';
	LET dMonto = 0;
	LET cCuentaDeposito = '';
	LET cNumcte = '';
	LET cRazonSocial = '';
	LET cNombre2 = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cNombre1 = '';
	LET cCodigoRetorno = '';
	LET cCliente = '';
	LET cBanco = '';
	LET cMotivoDevolucion = '';
	LET cAplicado = '';
	LET cMotivo = '';
	LET cDescripcionMotivo = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '', '', '', '', '', '', '', '';
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reportecodigo46.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, '', '', '', '', '', '', '', '';
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, '', '', '', '', '', '', '', '';
		END IF;
		
		FOREACH
            SELECT cceCheques.cvebanco || ' ' || siBancos.descripcion, 
			cceCheques.numcuenta, cceCheques.numcheque, cceCheques.monto, cceCheques.cta_deposito,
			cceCheques.numcte, siCliente.razon_social, siCliente.nombre2, siCliente.apell_paterno, 
			siCliente.apell_materno, siCliente.nombre1, cceCheques.motivo, siCodDevCam.descripcion, 
			cceCheques.codigo_retorno
			INTO cBanco,  cNumerocuenta, cNumerocheque, dMonto, cCuentaDeposito, cNumcte, cRazonSocial, cNombre2, 
			cApellidoPaterno, cApellidoMaterno, cNombre1, cMotivo, cDescripcionMotivo, cCodigoRetorno
			FROM 
			bditef:cce_cheques_dev	cceCheques,
			bdinteg:si_bancos		siBancos,
			bdinteg:si_cliente		siCliente,
			bdinteg:si_coddevcam	siCodDevCam
			WHERE 
			cceCheques.fechapresenta = pFecha AND
			cceCheques.cvebanco = siBancos.banco AND
			cceCheques.numcte = siCliente.numcte AND
			cceCheques.motivo = siCodDevCam.codigo 
			
			LET cMotivoDevolucion = TRIM(cMotivo) || ' ' || TRIM(cDescripcionMotivo);
			LET iRecuperacion = iRecuperacion + 1;
			IF TRIM(cRazonSocial) <> '' THEN
				LET cCliente = TRIM(cNumcte) || ' ' || TRIM(cRazonSocial);
			ELSE
				LET cCliente = TRIM(cNumcte);
				LET cCliente = TRIM(cCliente) || ' ' || cNombre1;
				LET cCliente = TRIM(cCliente) || ' ' || cNombre2;
				LET cCliente = TRIM(cCliente) || ' ' || cApellidoPaterno;
				LET cCliente = TRIM(cCliente) || ' ' || cApellidoMaterno;
			END IF
				
			IF TRIM(cCodigoRetorno)	= '000' THEN
				LET cAplicado = 'SI';
			ELSE
				SELECT 'NO ' || TRIM(siCodret.codigo_retorno) || ' ' || TRIM(siCodret.descripcion) INTO cAplicado FROM bdinteg:si_codret siCodret
				WHERE siCodret.codigo_retorno = cCodigoRetorno AND cMotivo = siCodret.sistema;
			END IF;
			
			RETURN cCodRet, UPPER(cBanco), cNumerocuenta, cNumerocheque, dMonto, cCuentaDeposito, UPPER(cCliente),
			UPPER(cMotivoDevolucion), UPPER(cAplicado) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', '', '', '', '', '';
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 15/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL el cual consulta los registros para generar el reporte codigo 46.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validachequeduplicado(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pNumCuenta CHAR(20), pBanco CHAR(3), pNumCheque CHAR(10), pImporte MONEY(14,2))
		RETURNING CHAR(5) AS codret,
			CHAR(22) AS nom_archivo,
			MONEY(14,2) AS monto_valido;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha CHAR(10);
	DEFINE cFechaHoy CHAR(8);
	DEFINE cNomArchivo CHAR(22);
	DEFINE mMontoTotalV MONEY(14,2);
	
	DEFINE iNoRegistros INTEGER;
	DEFINE dOtraFechaDate DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cFechaHoy = '';
	LET cNomArchivo = '';
	LET mMontoTotalV = 0.00;
	
	LET iNoRegistros = 0;
	LET dOtraFechaDate = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomArchivo, mMontoTotalV;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validachequeduplicado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBanco = '' OR  pNumCuenta = '' OR  pNumCheque = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo, mMontoTotalV;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo, mMontoTotalV;
		END IF;
		
		-- Consulta fecha
		SELECT fecha_hoy 
		INTO dFecha
		FROM bdicheq:'informix'.sc_fechas
		WHERE empresa = cEmpresa;
		
		IF NVL(dFecha,'') = '' THEN
			LET cCodRet = '00533'; --EL PARÃMETRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA
			RETURN cCodRet, cNomArchivo, mMontoTotalV;
		END IF;
		
		LET cFechaHoy = SUBSTR(dFecha, 7, 4) || SUBSTR(dFecha, 1, 2) || SUBSTR(dFecha, 4, 2);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		-- Valida que el cheque no exista
		SELECT nombrearchivo
		INTO cNomArchivo
		FROM bditef:"informix".cce_detalle 
		WHERE cod_operacion = '40'
			AND bco_receptor = TRIM(pBanco)
			AND num_cuenta = TRIM(pNumCuenta)	-- pNumCuenta CHAR(13)
			AND num_cheque = TRIM(pNumCheque)
			AND fecha_presini = cFechaHoy;
			
		IF NVL(cNomArchivo,'') = '' THEN
			RETURN cCodRet, NVL(cNomArchivo,''), mMontoTotalV;
		ELSE 		
			-- Marcar como procesado
			UPDATE bditef:"informix".cce_cheques_det SET presentado = '1'
			WHERE empresa =  cEmpresa
				AND cvebanco = TRIM(pBanco)
				AND numcheque = TRIM(pNumCheque)
				AND numcuenta = TRIM(pNumCuenta)
				AND fechapresenta = DATE(dFecha);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			ELSE
				LET cCodRet = '00726'; --ESTE CHEQUE ESTÃ DUPLICADO
				
				-- Ajusta el monto total operaciones
				LET mMontoTotalV = mMontoTotalV - ROUND(pImporte);
			END IF;
	
			RETURN cCodRet, NVL(cNomArchivo,''), mMontoTotalV;
		END IF;
	
		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/01/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de validar en la tabla bditef:cce_detalle que el cheque no exista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesconsultacod41(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(18))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS iNoRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;      

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesconsultacod41.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SELECT  count(*)
		INTO iNoRegistros
		FROM bdicnweb:ccep_procesacod41detalle_tmp 
		WHERE usuario = pUsuario
		AND direccionMac = pDireccionMac;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00017";
		END IF; 
		
		RETURN cCodRet,iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 08/06/2016',
'MODULO: Camara de Compensacion electronica presentada',
'FUNCIONALIDAD: Generador de archivos codigo 41',
'DESCRIPCION: conteo de totales de registros del archivo a cargar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_descargaimg_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				 INTEGER AS contDesImg, 
				 CHAR(1) AS existTamDifImg;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdConsultaDetalleCheque40 INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE cNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnvImgCheque INTEGER;
	DEFINE iTamRevImgCheque INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cDireccionMac CHAR(15);
	DEFINE iContadorDescargaImg INTEGER;
	DEFINE mMontoImagen DECIMAL(16,2);
	DEFINE tamImgOrigF INTEGER;
	DEFINE tamImgOrigT INTEGER;
	DEFINE bTamDiferente BOOLEAN;
	DEFINE bExistTamDifImg CHAR(1);
	DEFINE iExistenImgsDigitalizadas INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE iTamImgChqAnverso INTEGER;
	DEFINE iTamImgChqReverso INTEGER;
	DEFINE cIsImagenCheque CHAR(1);
	DEFINE bImagenF BLOB;
	DEFINE bImagenT BLOB;
	DEFINE cImagenFormatoT CHAR(3);
	DEFINE cImagenFormatoF CHAR(3);
	DEFINE dFechaHoy DATE;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdConsultaDetalleCheque40 = 0;
	LET cBanco = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = 0;
	LET mImporte = 0.0;
	LET cIndImgCheque = '';
	LET iTamAnvImgCheque = 0;
	LET iTamRevImgCheque = 0;
	LET cEjecutivo = '';
	LET cDireccionMac = '';
	LET iContadorDescargaImg = 0;
	LET mMontoImagen = 0.0;
	LET tamImgOrigF = 0;
	LET tamImgOrigT = 0;
	LET bTamDiferente = 'f';
	LET bExistTamDifImg = 'f';
	LET iExistenImgsDigitalizadas = 0;
	LET cEmpresa = '001';
	LET iTamImgChqAnverso = 0;
	LET iTamImgChqReverso = 0;
	LET cIsImagenCheque ='';
	LET bImagenF = NULL;
	LET bImagenT = NULL;
	LET cImagenFormatoT = '';
	LET cImagenFormatoF = '';
	LET dFechaHoy = NULL;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_valida_descargaimg_ccep.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac= ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END IF;
		
		--SE VERIFICA SI EXISTEN IMAGENES O MONTOS MAYORES 
		SELECT COUNT(ind_img_cheque)
		INTO iExistenImgsDigitalizadas
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND (ind_img_cheque = '1' OR  ind_img_cheque = '0');
		
		IF iExistenImgsDigitalizadas > 0 THEN
		
			--SE OBTIENE PARAMETRO DE MONTO
			SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
			LET iContadorDescargaImg = 0;
			
			--VALIDA SI LOS TAMANIOS DE LA IMAGEN SON IGUALES Y ACTUALIZA TABLA sw_cc_consultadetallecheque40
			FOREACH SELECT id_consultadetallecheque40,banco,cuenta_referencia,num_cheque,importe,
					ind_img_cheque,tam_anv_img_cheque,tam_rev_img_cheque,ejecutivo,direccion_mac
					INTO iIdConsultaDetalleCheque40,cBanco,cCuentaReferencia,cNumCheque,mImporte,
					cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,cEjecutivo,cDireccionMac
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					
					LET tamImgOrigF =0;
					LET tamImgOrigT = 0;
					LET bTamDiferente = 'f';
					
					IF mImporte >  mMontoImagen THEN
							IF cIndImgCheque = 1 THEN
								SELECT FIRST 1 imagen_tam INTO tamImgOrigF FROM bditef:cce_cheques_img 
								WHERE cvebanco= cBanco
								AND numcuenta= cCuentaReferencia
								AND numcheque= cNumCheque
								AND (lado_ft='F' OR lado_ft='A');
								
								IF tamImgOrigF > 0 and iTamAnvImgCheque > 0 THEN
									LET iContadorDescargaImg = iContadorDescargaImg + 1;
								END IF;
								
								SELECT FIRST 1 imagen_tam INTO tamImgOrigT FROM bditef:cce_cheques_img 
								WHERE cvebanco= cBanco
								AND numcuenta= cCuentaReferencia
								AND numcheque= cNumCheque
								AND (lado_ft='T' OR lado_ft='B' );	
								
								IF tamImgOrigT > 0 AND iTamRevImgCheque > 0 THEN
									LET iContadorDescargaImg = iContadorDescargaImg + 1;
								END IF;							
								
								IF tamImgOrigF <> iTamAnvImgCheque THEN
									LET bTamDiferente = 't';
								END IF;
								
								IF tamImgOrigT <> iTamRevImgCheque THEN
									LET bTamDiferente = 't';
								END IF;
								
								
								IF bTamDiferente = 't' THEN
									LET bExistTamDifImg = 't';
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET id_status_proceso = 'D'
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								END IF;
								
							ELIF cIndImgCheque = 0 THEN
								SELECT fecha_hoy 
								INTO dFechaHoy
								FROM bdicheq:'informix'.sc_fechas
								WHERE empresa = cEmpresa;
							
								
								SELECT FIRST 1 imagen_tam, imagen, imagen_formato
									INTO iTamImgChqAnverso,bImagenF , cImagenFormatoF
									FROM bditef:'informix'.cce_cheques_img
									WHERE empresa = cEmpresa
									AND cvebanco = cBanco
									AND numcuenta = cCuentaReferencia
									AND numcheque = cNumCheque
									AND fechapresenta = dFechaHoy
									AND lado_ft in ('F','A');
									
								IF iTamImgChqAnverso IS NOT NULL THEN
									-- SE CONSULTA EL TAMANIO DEL REVERSO DEL CHEQUE
									SELECT FIRST 1 imagen_tam, imagen, imagen_formato
										INTO iTamImgChqReverso, bImagenT , cImagenFormatoT
										FROM bditef:'informix'.cce_cheques_img
										WHERE empresa = cEmpresa
											AND cvebanco = cBanco
											AND numcuenta = cCuentaReferencia
											AND numcheque = cNumCheque
											AND fechapresenta = dFechaHoy
											AND lado_ft in ('T','B' );
									LET cIsImagenCheque = '1';
																		
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET (ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, imagenf,imagent,imagen_formatof,imagen_formatot,id_status_proceso) = 
									(cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT,'P')
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								ELSE
									LET cIsImagenCheque = '0';
									
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET (id_status_proceso,ind_img_cheque) = ('F',cIsImagenCheque)
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								END IF;
							END IF;		
					END IF;	
			END FOREACH;
		ELSE
			LET cCodRet = '00017';
		END IF;		
		RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 23/02/2016',
'MODULO: CCEP',
'FUNCIONALIDAD: Generador de Archivo',
'DESCRIPCION: actualiza tabla sw_cc_consultadetallecheque40 respecto a imagenes correctas',
'BD: BDICNWEB';

CREATE PROCEDURE "informix".sp_generador_archivos(pBandera CHAR(2), 
													pUsuario CHAR(8), 
													pIdFuncion CHAR(10), 
													pDireccionMac CHAR(15), 
													pIdRegistro INTEGER, 
													pOpcion INTEGER,
													pImporteTotal DECIMAL(14,2),
													pnombrearchivo CHAR(30), 
													pRutaArchivo CHAR(60),
													pIdsEliminar CHAR(500),
													pFechaHoy DATE, 
													pFechadevol DATE,
													pRegistros INTEGER,
													pRecuperacion INTEGER, 
													pNoBloque INTEGER,
													pNoBanco CHAR(3),
													pRutaDescarga CHAR(50), 
													pIdsPresentados CHAR(500),
													pIdCheque INTEGER, 
													pFecha DATE, 
													pCodigo CHAR(2),
													pIdConsulta CHAR(1))
													
				

RETURNING
		CHAR(5) 		AS r_codret,
		CHAR(1) 		AS r_bBanDetalle,
		DECIMAL(20,2) 	AS r_importeTotal,
		INTEGER 		AS r_iNoRegistros,
		INTEGER 		AS r_iTotalValidos,
		DECIMAL(18,2) 	AS r_dMontoTotalValido,
		INTEGER 		AS r_iNoBloque,
		INTEGER 		AS r_idRowDetalle,	
		CHAR(3) 		AS r_cBancoLibrado,
		CHAR(50) 		AS r_cDescbancoLibrado,
		DECIMAL(14,2) 	AS r_mImporte,
		CHAR(13) 		AS r_cCuentaReferencia,
		CHAR(10) 		AS r_cNumCheque,
		CHAR(20)  		AS r_cCuentaDeposito,
		CHAR(70) 		AS r_cObservaciones,
		CHAR(100) 		AS r_cMotivoDevolucion,
		CHAR(2) 		AS r_cprocesar,
		DATE 			AS r_dFechaHoy,
		CHAR(3) 		AS r_cNoBanco,
		CHAR(1) 		AS r_cProcesado,
		DATE 			AS r_dFechaHabilAnt,
		INTEGER 		AS r_TotalRegTruncados,
		CHAR(30) 		AS r_NombreArchivo,
		BOOLEAN 		AS r_esta_duplicado,		
		CHAR(3) 		AS r_cvebanco,
		CHAR(40) 		AS r_descripcionbanco,
		CHAR(20) 		AS r_cuentareferencia,
		INTEGER 		AS r_nocheque,
		DECIMAL(14,2) 	AS r_nImporte,
		CHAR(20)		AS r_cuentaDeposito,
		CHAR(44) 		AS r_sucursaloperadora,
		CHAR(20) 		AS r_cChqProcesado,
		CHAR(3) 		AS r_chqcompensacion,
		CHAR(2) 		AS r_chqtransaccion,
		CHAR(3) 		AS r_chqcodseguridad,
		CHAR(1) 		AS r_chqdigverpre,
		CHAR(1) 		AS r_chqdigverinter,
		CHAR(1) 		AS r_indimgcheque,
		INTEGER 		AS r_tamanversoimagen,
		INTEGER 		AS r_tamreversoimagen,
		CHAR(4) 		AS r_transaccion,
		CHAR(60) 		AS r_nombrecliente,
		CHAR(13) 		AS r_rfccliente,
		CHAR(20) 		AS r_curpcliente,
		CHAR(2) 		AS r_tipoctadeposito,
		INTEGER 		AS r_idregistro,
		CHAR(1) 		AS r_cIdStatusProceso,
		INTEGER 		AS r_num_registros,
		INTEGER 		AS r_doc_incompletos,
		MONEY(16,2) 	AS r_monto_total_invalido,
		INTEGER 		AS r_total_validos,
		MONEY(16,2) 	AS r_monto_total_valido,
		INTEGER 		AS r_noImagenesDesc,
		DATE 			AS r_dFechaHabilProx,
		DATE 			AS r_dFechaHabilAnt1,
		DATE 			AS r_dFechaHabilAnt2;

--DECLARACIï¿½N DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE importeTotal DECIMAL(20,2);	
DEFINE bBanDet CHAR(1);
DEFINE iNoRegistros INTEGER;
DEFINE iTotalValidos INTEGER;
DEFINE iNoBloque INTEGER;
DEFINE idRowDetalle INTEGER;
DEFINE cBancoLibrado  CHAR(3);
DEFINE cDescbancoLibrado CHAR(50);
DEFINE mImporte DECIMAL(14,2);
DEFINE cCuentaReferencia CHAR(13);
DEFINE cNumCheque CHAR(10);
DEFINE cCuentaDeposito CHAR(20);
DEFINE cObservaciones CHAR(70);
DEFINE cMotivoDevolucion CHAR(100);
DEFINE cprocesar CHAR(2);
DEFINE cEmpresa CHAR(3);
DEFINE dFecha DATE;
DEFINE cNoBanco CHAR(3);
DEFINE cProcesado CHAR(1);
DEFINE cNombreArchivo CHAR(30);
DEFINE dFechaHabilAnt DATE;	
DEFINE bIsChequeDuplicado BOOLEAN;
DEFINE dMontoTotalValido DECIMAL(16,2);
DEFINE cCveBanco CHAR(3);
DEFINE cDescripcionBanco CHAR(40);
DEFINE iNoCheque INTEGER;
DEFINE cSuscursalOperadora CHAR(44);
DEFINE cChqProcesado CHAR(1);
DEFINE cChqCompensacion CHAR(3);
DEFINE cChqTransaccion CHAR(2);
DEFINE cChqCodSeguridad CHAR(3);
DEFINE cChqDigVerPre CHAR(1);
DEFINE cChqDigVerInter CHAR(1);
DEFINE cIndImgCheque CHAR(1);
DEFINE iTamAnversoImagen INTEGER;
DEFINE iTamReversoImagen INTEGER;
DEFINE iTotalRegTruncados INTEGER;
DEFINE cTransaccion CHAR(4);
DEFINE cNombreCliente CHAR(60);
DEFINE cRfcCliente CHAR(13);
DEFINE cCurpCliente CHAR(20);
DEFINE cTipoCtaDeposito CHAR(2);
DEFINE iIdRegistro INTEGER;
DEFINE cIdStatusProceso CHAR(1);
DEFINE iNoImagenes INTEGER;
DEFINE iNoChequesValidos INTEGER;
DEFINE iNoDocsIncompletos INTEGER;
DEFINE mMontoTotalValido MONEY(16,2);
DEFINE mMontoTotalInvalido MONEY(16,2);
DEFINE cStatusProceso CHAR(1);
DEFINE dFechaHabilAnt1 DATE;
DEFINE dFechaHabilAnt2 DATE;
DEFINE dFechaHabilProx DATE;

--DEFINICIï¿½N
LET cCodRet = '00000';
LET iSqlErr = 0;
LET importeTotal = 0;
LET bBanDet = '';
LET iNoRegistros = 0;
LET iTotalValidos = 0;
LET dMontoTotalValido = 0.0;
LET iNoBloque = 0;
LET idRowDetalle = 0;	
LET cBancoLibrado = '';
LET cDescbancoLibrado = '';
LET mImporte = 0.0;
LET cCuentaReferencia = '';
LET cNumCheque = '';
LET cCuentaDeposito = '';
LET cObservaciones = '';
LET cMotivoDevolucion = '';
LET cprocesar = '';

LET cEmpresa = '001';
LET dFecha = null;
LET cNoBanco = '';
LET dFechaHabilAnt = null;		
LET cProcesado = 'f';
LET bIsChequeDuplicado = 'f';

LET cCveBanco = '';
LET cDescripcionBanco = '';
LET cCuentaReferencia = '';
LET iNoCheque = 0;
LET mImporte = 0.0;
LET cCuentaDeposito = '';
LET cSuscursalOperadora = '';
LET cChqProcesado = '';
LET cChqCompensacion = '';
LET cChqTransaccion = '';
LET cChqCodSeguridad = '';
LET cChqDigVerPre = '';
LET cChqDigVerInter = '';
LET cIndImgCheque = '';
LET iTamAnversoImagen = 0;
LET iTamReversoImagen = 0;
LET cTransaccion = '';
LET cNombreCliente = '';
LET cRfcCliente = '';
LET cCurpCliente = '';
LET cTipoCtaDeposito = '';
LET iIdRegistro = 0;
LET cIdStatusProceso = '';	
LET cNombreArchivo = '';
LET iNoRegistros = 0;
LET iNoImagenes = 0;
LET iNoChequesValidos = 0;
LET iNoDocsIncompletos = 0;
LET mMontoTotalValido = 0.0;
LET mMontoTotalInvalido = 0.0;
LET cStatusProceso = '';
LET iTotalRegTruncados = 0;
LET dFechaHabilAnt1 = null;
LET dFechaHabilAnt2 = null;
LET dFechaHabilProx = null;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_generador_archivo.out';
	    --TRACE ON;

		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;

		
		IF pBandera = '1' THEN
			EXECUTE PROCEDURE "informix".sp_actualiza_chqrevisados_ccep(pUsuario, pIdFuncion, pDireccionMac, pIdRegistro, pOpcion)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE "informix".sp_aplicadevol_cod41_ccep(pUsuario, pIdFuncion, pImporteTotal, pDireccionMac)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		--PENDIENTE
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_cargacod41_ccep(pUsuario, pIdFuncion,pnombrearchivo, pRutaArchivo, pDireccionMac)
			INTO cCodRet,bBanDet,importeTotal;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '4' THEN
			EXECUTE PROCEDURE "informix".sp_ccep_eliminacheques_cod46(pUsuario, pIdFuncion, pDireccionMac, pIdsEliminar)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE "informix".sp_consultachequescod47totales_ccep(pUsuario, pIdFuncion, pFechaHoy, pFechadevol, pDireccionMac)
			INTO cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE "informix".sp_consultadelvorevcod46total_ccep(pUsuario, pIdFuncion, pFechadevol, pFechaHoy, pDireccionMac)
			INTO cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		ELIF pBandera = '7' THEN
            FOREACH
			EXECUTE PROCEDURE "informix".sp_consultaprocescod41_ccep(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,
				 cCuentaDeposito,cObservaciones, cMotivoDevolucion,cprocesar

			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2 WITH RESUME;
             END FOREACH;

		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE "informix".sp_datosdiahoy_cod47(pUsuario , pIdFuncion)
			INTO cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '9' THEN
			EXECUTE PROCEDURE "informix".sp_genera_archivo_presencod46(pUsuario, pIdFuncion, pFechadevol, pFechaHoy, pNoBloque,
														  pNoBanco,pRutaDescarga, pDireccionMac, pIdsPresentados)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;	
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '10' THEN
			EXECUTE PROCEDURE "informix".sp_genera_archivo_presencod47(pUsuario, pIdFuncion, pFechaHoy, pNoBloque,
														  pNoBanco,pRutaDescarga, pDireccionMac, pIdsEliminar)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;	
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '11' THEN
			EXECUTE PROCEDURE "informix".sp_ope_chequeduplicado(pUsuario , pIdFuncion , pIdCheque , pFecha , pCodigo)
			INTO cCodRet, bIsChequeDuplicado;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '12' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consbloquearchivopresentado(pUsuario , pIdFuncion, pIdConsulta )
			INTO cCodRet, iNoBloque;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '13' THEN
		FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_consultachequetamdif(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
		END FOREACH;

		ELIF pBandera = '14' THEN
			FOREACH 
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
				INTO cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
				
				RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
				cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
				iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
			END FOREACH;
		ELIF pBandera = '15' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40_totales(pUsuario , pIdFuncion , pDireccionMac)
			INTO cCodRet, iNoRegistros, iNoDocsIncompletos, mMontoTotalInvalido, iNoChequesValidos, mMontoTotalValido, iNoImagenes;
			LET mMontoTotalInvalido= NVL(mMontoTotalInvalido, 0.0);
			LET mMontoTotalValido = NVL(mMontoTotalValido, 0.0);

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '16' THEN
			EXECUTE PROCEDURE "informix".sp_ope_datoscarga_genarchivo(pUsuario , pIdFuncion )
			INTO cCodRet, dFechaHabilAnt, cNoBanco;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '17' THEN
			EXECUTE PROCEDURE "informix".sp_ope_datosgral_archivocod46_ccep(pUsuario , pIdFuncion )
			INTO cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '18' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultaimportececoban(pUsuario , pIdFuncion)
			INTO cCodRet,importeTotal;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '19' THEN
			EXECUTE PROCEDURE "informix".sp_ope_validachequeduplicado(pUsuario , pIdFuncion, pRutaDescarga, pNoBanco, pRutaDescarga, pImporteTotal)
			INTO cCodRet,cNombreArchivo,importeTotal;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '20' THEN
			EXECUTE PROCEDURE "informix".sp_ope_generarchivopresentado(pUsuario , pIdFuncion, pNoBloque, pRutaDescarga, pDireccionMac)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '21' THEN
			EXECUTE PROCEDURE "informix".sp_ope_genera_archivo_img_presentado(pUsuario , pIdFuncion, pNoBloque, pRutaDescarga, pDireccionMac, pOpcion)
			INTO cCodRet,cNombreArchivo;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '22' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_tef_grab_arch_cam(pUsuario, pRegistros, pImporteTotal, pIdRegistro, pnombrearchivo, pRecuperacion, pOpcion)
			INTO cCodRet,cObservaciones;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '23' THEN
			EXECUTE PROCEDURE "informix".sp_valida_descargaimg_ccep(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet,iNoRegistros, cIdStatusProceso;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '24' THEN
			EXECUTE PROCEDURE "informix".sp_eliminasinprocesartmpcod40(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '25' THEN
            FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo46(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet, iIdRegistro, cNoBanco, cDescripcionBanco, cCuentaReferencia, cNumCheque,
				mImporte, cCuentaDeposito, cTransaccion, cObservaciones, cMotivoDevolucion,
				cIndImgCheque, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cTipoCtaDeposito, cNombreCliente, cRfcCliente, cCurpCliente, cNombreArchivo, iTamAnversoImagen, iTamReversoImagen
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
            END FOREACH;
		ELIF pBandera = '26' THEN
			EXECUTE PROCEDURE "informix".sp_totalesconsultacod41(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet, iNoRegistros;
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '27' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_reportecodigo46(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion) 
			INTO cCodRet, cDescripcionBanco, cCuentaReferencia, cNumCheque, importeTotal, cCuentaDeposito, cNombreCliente, cMotivoDevolucion, cObservaciones
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
            END FOREACH;
		ELIF pBandera = '28' THEN
			FOREACH 
                EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo47(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion) 
                INTO cCodRet, idRowDetalle, cNoBanco, cDescripcionBanco, cCuentaReferencia, cNumCheque, importeTotal, cCuentaDeposito,
                cObservaciones,cIndImgCheque, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, cNombreArchivo, iTamAnversoImagen, iTamReversoImagen
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
            END FOREACH;
		ELIF pBandera = '29' THEN
			SELECT fecha_hoy 
			INTO dFecha
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = cEmpresa;
			
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		END IF;
	END;

END PROCEDURE;