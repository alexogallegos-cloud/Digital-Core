CREATE PROCEDURE "informix".sp_acl_obtenerlogpreguntas(pNoCliente CHAR(20),pTipo CHAR(1))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_combo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNum_combo INTEGER;
    DEFINE iAux INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNum_combo = 0;
    LET iAux =0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNum_combo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_acl_obtenerlogpreguntas.out';
		-- TRACE ON;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (pTipo=0) THEN
		
		FOREACH
		SELECT combo
        INTO iNum_combo
		FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE COMBO NOT IN(SELECT combo FROM  bdiaclaracion:"informix".acl_logautenticacion
        WHERE   no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL)
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;

        IF iNum_combo = 0 THEN
        UPDATE bdiaclaracion:"informix".acl_logautenticacion SET marcado = 1 
        WHERE   no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL;

        FOREACH
        SELECT combo
        INTO iNum_combo
		FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE COMBO NOT IN(SELECT combo FROM  bdiaclaracion:"informix".acl_logautenticacion
        WHERE   no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL)
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;

        END IF;

        IF (iNum_combo IS NULL) THEN 
        RETURN cCodRet,iAux;     
        END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,iNum_combo;
		END IF;	
		
		ELIF (pTipo=1) THEN
		
		FOREACH
		SELECT combo
        INTO iNum_combo
		FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE bdiaclaracion:"informix".acl_prg_inises_autcte.excluida = 0 AND COMBO NOT IN(SELECT combo FROM bdiaclaracion:"informix".acl_logautenticacion
        WHERE  no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT))
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;

        IF iNum_combo = 0 THEN
        UPDATE bdiaclaracion:"informix".acl_logautenticacion SET marcado = 1 
        WHERE no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL;

        FOREACH
		SELECT combo
        INTO iNum_combo
		FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE bdiaclaracion:"informix".acl_prg_inises_autcte.excluida = 0 AND COMBO NOT IN(SELECT combo FROM bdiaclaracion:"informix".acl_logautenticacion
        WHERE no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT)  AND marcado IS NULL)
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;

        END IF;

        IF (iNum_combo IS NULL) THEN 
        RETURN cCodRet,iAux;     
        END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,iNum_combo;
		END IF;	

        ELIF (pTipo=2) THEN
		
		FOREACH
		SELECT combo
        INTO iNum_combo
	    FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE bdiaclaracion:"informix".acl_prg_inises_autcte.excluida2 = 0 AND COMBO NOT IN(SELECT combo FROM bdiaclaracion:"informix".acl_logautenticacion
        WHERE no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT)  )
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;


        IF iNum_combo = 0 THEN
        UPDATE bdiaclaracion:"informix".acl_logautenticacion SET marcado = 1 
        WHERE   no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL;

        FOREACH
		SELECT combo
        INTO iNum_combo
	    FROM bdiaclaracion:"informix".acl_prg_inises_autcte
        WHERE bdiaclaracion:"informix".acl_prg_inises_autcte.excluida2 = 0 AND COMBO NOT IN(SELECT combo FROM bdiaclaracion:"informix".acl_logautenticacion
        WHERE   no_cliente = pNoCliente AND fecha_autenticacion = DATE(CURRENT) AND marcado IS NULL)
		GROUP BY combo
        ORDER BY combo

        LET iAux = iAux+1;
        
        RETURN cCodRet,iNum_combo WITH RESUME;
		END FOREACH;

            
        END IF;
            

        IF (iNum_combo IS NULL) THEN 
        RETURN cCodRet,iAux;     
        END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,iNum_combo;
		END IF;	
		
		END IF;
		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Norberto Corona',
'FECHA: 07/05/2021',
'MODULO: CAT',
'RQM/RQI: RQM 10 1388',
'FUNCIONALIDAD: RECUPERA LAS PREGUNTAS DISPONIBLES SEGUN EL TIPO DE COMBO',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_obtenernombreestados()
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS num_estado,
		CHAR(30) AS nom_estado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNum_estado CHAR(2) ;
	DEFINE cNom_estado CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cNom_estado = '';
	LET cNum_estado = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNum_estado,cNom_estado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_acl_obtenernombreestados.out';
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
		SELECT estado,nombre
		INTO cNum_estado,cNom_estado
		FROM bdinteg:"informix".si_estados
        ORDER BY nombre
        RETURN cCodRet,cNum_estado,cNom_estado WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,cNum_estado,cNom_estado;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Norberto Corona',
'FECHA: 07/05/2021',
'MODULO: CAT',
'RQM/RQI: RQM 10 1388',
'FUNCIONALIDAD: RECUPERA EL CATALOGO DE ESTADOS',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_actualizaempaclaracion(pUsuario CHAR(8), pKyaclaracion INTEGER)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_actualizaempaclaracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pKyaclaracion  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		UPDATE bdiaclaracion:"informix".acl_aclaracion SET num_empleado = pUsuario WHERE pky_aclaracion = pKyaclaracion;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Norberto Corona',
'FECHA: 07/05/2021',
'MODULO: CAT',
'RQM/RQI: RQM 10 1388',
'FUNCIONALIDAD:',
'DESCRIPCION: SPL encargado de actualizar el nÃºmero de empleado en la tabla acl_aclaracion',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_obtenerpreguntasiniciosesion(pTipoPreg CHAR(1), pTipoCombo CHAR(2))
	RETURNING CHAR(5) AS codret,
        INTEGER AS id,
		CHAR(200) AS pregunta,
		CHAR(30) AS componente,
		CHAR(30) AS tipo_captura,
		INTEGER AS num_caracteres;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cPregunta CHAR(200) ;
	DEFINE cComponente CHAR(30);
	DEFINE cTipoCaptura CHAR(30);
	DEFINE iNumCaracteres INTEGER;
    DEFINE iId INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cPregunta = '';
	LET cComponente = 0;
	LET cTipoCaptura ='';
	LET iNumCaracteres =0;
    LET iId=0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iId,cPregunta,cComponente,cTipoCaptura,iNumCaracteres;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_acl_obtenerpreguntasiniciosesion.out';
		-- TRACE ON;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT identificador,pregunta,tipo_componente_visual,tipo_captura,numero_caracteres
			INTO iId,cPregunta,cComponente,cTipoCaptura,iNumCaracteres
			FROM bdiaclaracion:"informix".acl_prg_inises_autcte 
			WHERE tipo_pregunta = pTipoPreg AND combo = pTipoCombo
			ORDER BY identificador
		
			LET cPregunta = REPLACE(TRIM(cPregunta), "?", "&#");
        
			RETURN cCodRet,iId,cPregunta,cComponente,cTipoCaptura,iNumCaracteres WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,iId,cPregunta,cComponente,cTipoCaptura,iNumCaracteres;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Norberto Corona',
'FECHA: 07/05/2021',
'MODULO: CAT',
'RQM/RQI: RQM 10 1388',
'FUNCIONALIDAD: RECUPERA LAS PREGUNTAS DE INICIO DE SESION (1) O AUTENTICACION (2)',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_datos_adicionales_movimiento(p_folio_suc CHAR(30), p_num_tarjeta CHAR(16), p_origen_evento INTEGER) RETURNING	 CHAR(5)   AS cod_ret, CHAR(19) AS id_comer;
        
    --Variables--
    DEFINE sql_err                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE v_cod_ret                    CHAR(5);
    
    DEFINE v_nombre_origen              CHAR(50);
    DEFINE v_id_comer                   CHAR(19);
    
	DEFINE v_existe_movimiento          SMALLINT;
	
	
    LET v_cod_ret                       = '00000';
    LET sql_err                         = NULL;
    LET isam_err                        = NULL;
	
    LET v_nombre_origen                 = NULL;
    LET v_id_comer                      = NULL;
	
	LET v_existe_movimiento             = NULL;
    
    --SET DEBUG FILE TO "/informix/traces/sp_obten_datos_adicionales_movimiento.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
        ON EXCEPTION SET sql_err, isam_err
            IF sql_err <> 0 THEN
                
                LET v_cod_ret = sql_err;
                LET v_id_comer = isam_err;
                RETURN v_cod_ret, v_id_comer;
                
            END IF;
        END EXCEPTION;
        
        SELECT nombre 
            INTO v_nombre_origen 
        FROM "informix".acl_origen_evento 
        WHERE pky_origen_evento = p_origen_evento;
        
        IF v_nombre_origen IN ('POS','ATMS') THEN
            
            IF SUBSTR(p_folio_suc,1,1) = 'i' THEN
                LET p_folio_suc = SUBSTR(p_folio_suc,2,29);
            END IF;
            
            SELECT 1, idretailer
                INTO v_existe_movimiento, v_id_comer
            FROM intercard:movimiento
            WHERE secuenciaextendida = p_folio_suc
                AND numtarjeta = p_num_tarjeta;
            
			IF (v_existe_movimiento IS NULL) THEN
                SELECT 1, idretailer
                INTO v_existe_movimiento, v_id_comer
                    FROM intercard:movimientohistorico
                WHERE secuenciaextendida = p_folio_suc
                    AND numtarjeta = p_num_tarjeta;
            END IF; 
        END IF;
        
		IF ((v_existe_movimiento IS NULL) OR (v_id_comer IS NULL) OR (v_id_comer = '')) THEN
			LET v_cod_ret = '00001';
            LET v_id_comer = 'SIN INFORMACION';
        END IF;
		
        RETURN v_cod_ret, v_id_comer;
    
    END;
END PROCEDURE
DOCUMENT
'Sistema         :    Aclaraciones',
'CreaciÃ³n        :    BanCoppel',
'Area            :    Sistemas Administrativos y Perifericos',
                      'Gerencia de Mtto y Soporte IV',
'Coordinador     :    Norberto Corona Berruecos',
'FECHA           :    2021',
'Requerimiento   :    RQM 06 731-5',
'VERSION         :    1.0.0',
'BD              :    bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_validarnumerorespuestas(p_NumCte CHAR(30))
RETURNING  CHAR(5) as  codretorno, INTEGER as preguntasconrespuesta;

    --definicion de variables--
    DEFINE cResultado_rfc			         CHAR(13);
    DEFINE cResultado_fecha_nac              CHAR(10);
    DEFINE cResultado_correo                 CHAR(50);
    DEFINE cResultado_telefono               CHAR(10);
    DEFINE cResultado_celular                CHAR(10);
    DEFINE cResultado_estado                 CHAR(30);
	DEFINE cResultado_estadoN                CHAR(30);
	DEFINE cResultado_calle                  CHAR(50);
	DEFINE cResultado_colonia                CHAR(50);
    DEFINE cResultado_tarjeta                CHAR(4);
    DEFINE iSqlErr                           INTEGER;
	DEFINE cCodRet 							 CHAR(5);
	DEFINE iTotalRespuesta					 INTEGER;
	
    -- Inicializacion de las variables.
	
    LET cResultado_rfc = NULL;
    LET cResultado_fecha_nac = NULL;
    LET cResultado_correo = NULL;
    LET cResultado_telefono = NULL;
    LET cResultado_celular = NULL;
    LET cResultado_estado = NULL;
	LET cResultado_estadoN =NULL;
	LET cResultado_calle =NULL;
	LET cResultado_colonia=NULL;
	
	LET iSqlErr =0;
	LET cCodRet='00000';
	LET iTotalRespuesta =0;

    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotalRespuesta;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_validarnumerorespuestas.out';
		--TRACE ON;
		

	FOREACH
		SELECT
                 rfc as rfc,tc.numtarjeta as tarjeta, 
                 cte.fecha_nac as fecha_nac,
                 em.correo_elec as correo_electronico,
                 st.telefono as telefono_casa,
                 st1.telefono as celular,
                 edo.nombre as estado,
				 ct.nombrecalle as calle,
                 sz.nombrezona as colonia
				 
                 INTO cResultado_rfc,cResultado_tarjeta,cResultado_fecha_nac,cResultado_correo,cResultado_telefono,cResultado_celular,cResultado_estado,cResultado_calle,cResultado_colonia
                 FROM bdinteg:si_cliente sc
                 Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:si_telefonos_actual st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 Left Outer Join bdinteg:si_telefonos_actual st1 on st1.numcte = sc.numcte and st1.tipo_tel = '2' and st1.status_tel = 'A'
                 Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
                 Left Outer Join intercard:tarjeta tc on tc.numcliente = sc.numcte and codstatustarjeta = 'ACT'
                 Left Outer Join bdinteg:si_ctepf cte on cte.numcte = sc.numcte
            where
            sc.NUMCTE = p_NumCte

             IF cResultado_tarjeta is not null THEN
                LET iTotalRespuesta = 1;
             END IF;

			END FOREACH;

			LET cResultado_estadoN = ( select estados.nombre from bdinteg:si_ctepf ctpf
            inner join bdinteg:si_estados estados on ctpf.lugar_nac = estados.estado where numcte = p_NumCte);
			
			
    IF cResultado_rfc is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	 IF cResultado_fecha_nac is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+2; --SI TIENE FECHA DE NAC TIENE EDAD 
	END IF;
	 IF cResultado_correo is not null THEN		
		LET iTotalRespuesta = iTotalRespuesta+3; --SI TIENE CORREO TIENE DOMINIO y PRIMERAS 4 LETRAS 
	END IF;
	 IF cResultado_celular is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	 IF cResultado_estado is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	 IF cResultado_calle is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	 IF cResultado_colonia is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	 IF cResultado_estadoN is not null THEN
		LET iTotalRespuesta = iTotalRespuesta+1;
	END IF;
	

          RETURN cCodRet,iTotalRespuesta;

END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/03/2021',
'MODULO: CAT',
'FUNCIONALIDAD: RECUPERA EL NUMERO DE PREGUNTAS CON RESPUESTA DEL CLIENTE',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_validarpreguntasautenticacion(p_NumCte CHAR(20))
RETURNING  CHAR(5) as  codretorno, CHAR(30) as rfc, CHAR(30) as fecha_nac, CHAR(50) as correo, CHAR(30) as telefono, CHAR(30) as celular, CHAR(50) as estado,CHAR(50) as estado_nacio,CHAR(100) as calle, CHAR(100) as colonia;

    --definicion de variables--
    DEFINE cResultado_rfc			         CHAR(13);
    DEFINE cResultado_fecha_nac              CHAR(10);
    DEFINE cResultado_correo                 CHAR(50);
    DEFINE cResultado_telefono               CHAR(10);
    DEFINE cResultado_celular                CHAR(10);
    DEFINE cResultado_estado                 CHAR(30);
	DEFINE cResultado_estadoN                CHAR(30);
	DEFINE cResultado_calle                  CHAR(50);
	DEFINE cResultado_colonia                CHAR(50);
    DEFINE iSqlErr                           INTEGER;
	DEFINE cCodRet 							 CHAR(5);


    -- Inicializacion de las variables.
	
    LET cResultado_rfc = '';
    LET cResultado_fecha_nac = '';
    LET cResultado_correo = '';
    LET cResultado_telefono = '';
    LET cResultado_celular = '';
    LET cResultado_estado = '';
	LET cResultado_estadoN ='';
	LET cResultado_calle ='';
	LET cResultado_colonia='';
	LET iSqlErr =0;
	LET cCodRet='00000';
	

    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cResultado_rfc,cResultado_fecha_nac,cResultado_correo,cResultado_telefono,cResultado_celular,cResultado_estado,cResultado_estadoN,cResultado_calle,cResultado_colonia;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_validarpreguntasautenticacion.out';
		--TRACE ON;

	
		SELECT
                 rfc as rfc,
                 TO_CHAR(cte.fecha_nac,'%m/%d/%Y') as fecha_nac,
                 em.correo_elec as correo_electronico,
                 substr(st.telefono,length(st.telefono)-9,10) as telefono_casa,
                 substr(st1.telefono,length(st1.telefono)-9,10) as celular,
                 edo.nombre as estado,
				 ct.nombrecalle as calle,
                 sz.nombrezona as colonia
				 
                 INTO cResultado_rfc,cResultado_fecha_nac,cResultado_correo,cResultado_telefono,cResultado_celular,cResultado_estado,cResultado_calle,cResultado_colonia
                 FROM bdinteg:si_cliente sc
                 Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:si_telefonos st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 Left Outer Join bdinteg:si_telefonos_actual st1 on st1.numcte = sc.numcte and st1.tipo_tel = '2' and st1.status_tel = 'A'
                 Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
                 Left Outer Join bdinteg:si_ctepf cte on cte.numcte = sc.numcte

            where
            sc.NUMCTE = p_NumCte;
			
			LET cResultado_estadoN = ( select estados.nombre from bdinteg:si_ctepf ctpf
            inner join bdinteg:si_estados estados on ctpf.lugar_nac = estados.estado where numcte = p_NumCte);

            IF cResultado_rfc is null THEN
             LET cResultado_rfc = '0';
            END IF;
            IF cResultado_fecha_nac is null THEN
             LET cResultado_fecha_nac = '0';
            END IF;
            IF cResultado_correo is null THEN
             LET cResultado_correo = '0';
            END IF;
            IF cResultado_telefono is null THEN
             LET cResultado_telefono = '0';
            END IF;
            IF cResultado_celular is null THEN
             LET cResultado_celular = '0';
            END IF;
            IF cResultado_estado is null THEN
             LET cResultado_estado = '0';
            END IF;
            IF cResultado_estadoN is null THEN
             LET cResultado_estadoN = '0';
            END IF;
            IF cResultado_calle is null THEN
             LET cResultado_calle = '0';
            END IF;
            IF cResultado_colonia is null THEN
             LET cResultado_colonia = '0';
            END IF;

		RETURN cCodRet,"25,40,55&#"||cResultado_rfc,"28,43,46,52,58&#"||cResultado_fecha_nac,"34,37,49,53&#"||cResultado_correo,"26,31,38,44,59&#"||cResultado_telefono,"29,41,56&#"||cResultado_celular,"27,39,50,57&#"||cResultado_estado,"32,35,42,47,60&#"||cResultado_estadoN,"30,48,51&#"||cResultado_calle,"33,36,45,54&#"||cResultado_colonia;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			 RETURN cCodRet,cResultado_rfc,cResultado_fecha_nac,cResultado_correo,cResultado_telefono,cResultado_celular,cResultado_estado,cResultado_estadoN,cResultado_calle,cResultado_colonia;
		END IF;	
         

END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/03/2021',
'MODULO: CAT',
'FUNCIONALIDAD: RECUPERA LAS RESPUESTAS DE LAS PREGUNTAS DE AUTENTICACION',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_insertalog(pUsuario CHAR(8),pFlujo CHAR(30), pNumCliente CHAR(20),pIdPreg CHAR(2), pRespuesta CHAR(100),pRespuestaCorrecta CHAR(1),pBandera CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cTipoPreg CHAR(2);
	DEFINE cTipoCombo CHAR(2);
	DEFINE cPregunta CHAR(200);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cTipoPreg='';
	LET cTipoCombo='';
	LET cPregunta='';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_acl_insertalog.out';
		-- TRACE ON;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        IF pBandera = '1' THEN
            INSERT INTO bdiaclaracion:"informix".acl_logautenticacion (flujo,usuario,no_cliente,tipo_pregunta,combo,pregunta,respuesta,respuesta_correcta,fecha_autenticacion)
            VALUES (pFlujo, pUsuario, pNumCliente, '', pIdPreg,'', pRespuesta, pRespuestaCorrecta, CURRENT);
        ELSE	
            SELECT tipo_pregunta,combo, pregunta INTO cTipoPreg,cTipoCombo,cPregunta FROM bdiaclaracion:"informix".acl_prg_inises_autcte WHERE identificador = pIdPreg;
            
            INSERT INTO bdiaclaracion:"informix".acl_logautenticacion (flujo,usuario,no_cliente,tipo_pregunta,combo,pregunta,respuesta,respuesta_correcta,fecha_autenticacion)
            VALUES (pFlujo, pUsuario, pNumCliente, cTipoPreg,cTipoCombo,cPregunta,pRespuesta,pRespuestaCorrecta,CURRENT);
        END IF;	
		
        
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodRet ='99999';
		END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 23/03/2021',
'MODULO: CAT',
'FUNCIONALIDAD: INSERTA LAS PREGUNTAS DE INICIO DE SESION O AUTENTICACION EN EL LOG',
'DESCRIPCION: ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_cred_cliente_crd(p_sNumeroCliente CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 	CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃÂ³n de las variables.
     LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
            END IF;
        END EXCEPTION;

		FOREACH
			SELECT SKIP p_skip DISTINCT bdicred:sd_maecredcrd.num_producto as numeroProducto, nombre_prod AS nombreProducto, bdicred:sd_maecredcrd.num_credito AS cuentaProducto, intercard:tarjetacuenta.numtarjeta AS tarjetaProducto, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicred:sd_maecredcrd 
                LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecredcrd.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecredcrd.num_producto = bdicred:sd_definicion.num_producto) 
                LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecredcrd.num_credito = intercard:tarjetacuenta.numcuenta)
				--LEFT JOIN bdicred:sd_tarjeta ON (bdicred:sd_maecredcrd.empresa = bdicred:sd_tarjeta.empresa and bdicred:sd_maecredcrd.num_credito = bdicred:sd_tarjeta.num_credito)
				LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
            WHERE bdicred:sd_maecredcrd.numcte = p_sNumeroCliente 
            AND bdicred:sd_maecredcrd.status_cred IN ('AA' ,'BA', 'BT','VP','E1','E2','E3') 		--IFRS  
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_cred_cuenta_crd(p_sNumeroCuenta CHAR(20), p_skip INT, p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;

	--definicion de variables--
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto         CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃÂ³n de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';
	
    --SET DEBUG FILE TO '/informix/sp_busca_producto_cred_cuenta_crd.out';
    --TRACE ON;	

    SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
            END IF;
        END EXCEPTION;

        	FOREACH
			SELECT SKIP p_skip bdicred:sd_definicion.num_producto,nombre_prod, num_credito, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicred:sd_maecredcrd 
                	LEFT JOIN bdicred:sd_definicion 
                        ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa 
                            AND bdicred:sd_definicion.num_producto = bdicred:sd_maecredcrd.num_producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecredcrd.num_credito = intercard:tarjetacuenta.numcuenta)
					LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
            		WHERE num_credito = p_sNumeroCuenta
                    AND bdicred:sd_maecredcrd.status_cred IN ('AA' ,'BA', 'BT','VP','E1','E2','E3') 		 --IFRS 
            		ORDER BY num_credito asC
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta WITH RESUME;
        	END FOREACH;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_cred_tarjeta_crd(p_sNumeroTarjeta CHAR(20), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto     CHAR(60);
	DEFINE resultado_numeroCuenta       CHAR(30);
	DEFINE resultado_numeroTarjeta      CHAR(30);
	DEFINE iSqlErr                      INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';

    --SET DEBUG FILE TO '/informix/sp_busca_producto_cred_tarjeta_crd.out';
    --TRACE ON;	
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
           	 IF iSqlErr <> 0 THEN
                 LET resultado_numeroProducto ='';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta,cStatusTarjeta;
          	 END IF;
        END EXCEPTION;

        FOREACH
			SELECT bdicred:sd_definicion.num_producto,nombre_prod, num_credito, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta,cStatusTarjeta
			FROM bdicred:sd_maecredcrd 
                	LEFT JOIN bdicred:sd_definicion 
                        ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa
                        AND bdicred:sd_definicion.num_producto = bdicred:sd_maecredcrd.num_producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecredcrd.num_credito = intercard:tarjetacuenta.numcuenta)
					LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
                    WHERE bdicred:sd_maecredcrd.empresa = p_sNumeroEmpresa
					AND status_cred IN ('AA' ,'BA', 'BT','VP','E1','E2','E3')		--IFRS 
            		AND intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta
                    RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta,cStatusTarjeta;        
			END FOREACH;
			
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_prod_cred(p_numeroCliente CHAR(20))
--SP QUE REGRESA LOS PRODUCTOS CON  estatus AA y BA con sus tarjetas asociadas
     RETURNING  CHAR(8)     AS numeroproducto,
                        CHAR(30)    AS nombreproducto,
                        CHAR(30)    AS cuentaproducto,
                        CHAR(30)    AS statusCuenta,
                        CHAR(30)    AS numero_tarjeta,
                        CHAR(30)    AS status_tarjeta;
    --definicion de variables--
    DEFINE resultado_numeroproducto             CHAR(8);
    DEFINE resultado_nombreproducto             CHAR(30);
    DEFINE resultado_cuentaproducto              CHAR(30);
    DEFINE resultado_statusCuenta                  CHAR(30);
    DEFINE resultado_numero_tarjeta                 CHAR(30);
    DEFINE resultado_status_tarjeta                 CHAR(30);
    DEFINE iSqlErr                                          INTEGER;

     -- Inicialización de las variables.


    LET resultado_numeroproducto        = '';
    LET resultado_nombreproducto        = '';
    LET resultado_cuentaproducto        = '';
    LET resultado_statusCuenta          = '';
    LET resultado_numero_tarjeta     = '';
    LET resultado_status_tarjeta        = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET resultado_numeroproducto= '';
                    LET resultado_nombreproducto= '';
                    LET resultado_cuentaproducto= '';
                    LET resultado_statusCuenta= '';
                    LET resultado_numero_tarjeta = '';
                    LET resultado_status_tarjeta= '';
                RETURN resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,
                                resultado_statusCuenta , resultado_numero_tarjeta, resultado_status_tarjeta;
            END IF;
        END EXCEPTION;
        FOREACH
                   

            SELECT  DISTINCT bdicred:sd_maecred.num_producto AS numeroProducto,
                                                    nombre_prod AS nombreProducto,
                                                    bdicred:sd_maecred.num_credito AS cuentaProducto,
                                                    DECODE(bdicred:sd_maecred.status_cred,'AA','VIGENTE NORMAL','BA','VENCIDA NORMAL',  'BT', 'VENCIDA TRASPASADA','E1','CREDITO ETAPA 1','E2','CREDITO ETAPA 2','E3','CREDITO ETAPA 3') AS status_cuenta,
                                                    bdicred:sd_tarjeta.num_tarjeta AS numero_tarjeta ,
                                                    DECODE (bdicred:sd_tarjeta.status_tar,'A','ACTIVA','C','CANCELADA',NULL,'')  AS status_tarjeta
                INTO resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,resultado_statusCuenta , resultado_numero_tarjeta,resultado_status_tarjeta
                    FROM bdicred:sd_maecred
                    LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecred.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecred.num_producto = bdicred:sd_definicion.num_producto)
                    LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
                    LEFT JOIN bdicred:sd_tarjeta ON  (bdicred:sd_maecred.num_credito = bdicred:sd_tarjeta.num_credito and bdicred:sd_tarjeta.status_tar IN ('A','I','C'))
                    WHERE bdicred:sd_maecred.numcte = p_numeroCliente
                    AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT', 'E1', 'E2', 'E3')		--IFRS 
                    AND bdicred:sd_tarjeta.tipo_tarjeta in ('T','C')
                    AND bdicred:sd_tarjeta.tipo_tarjeta != 'A'
                    AND bdicred:sd_tarjeta.secuencia in (select max(secuencia) from bdicred:sd_tarjeta where numcte = p_numeroCliente GROUP BY num_credito)
                    

        RETURN  resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,resultado_statusCuenta , resultado_numero_tarjeta,resultado_status_tarjeta  WITH RESUME;
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_producto_cred_cliente(p_sNumeroCliente CHAR(20), p_skip INT)

     RETURNING  CHAR(6) AS numeroProducto,
                CHAR(60) AS nombreProducto, 
                CHAR(30) AS numeroCuenta, 
                CHAR(30) AS numeroTarjeta;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);
    DEFINE iSqlErr                          INTEGER;
    
     -- Inicio de las variables.
     LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;

        FOREACH
            SELECT DISTINCT bdicred:sd_maecred.num_producto as numeroProducto, nombre_prod AS nombreProducto, bdicred:sd_maecred.num_credito AS cuentaProducto, num_tarjeta AS tarjetaProducto
            INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
            FROM bdicred:sd_maecred 
                LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecred.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecred.num_producto = bdicred:sd_definicion.num_producto) 
                LEFT OUTER JOIN bdicred:sd_tarjeta ON (bdicred:sd_maecred.num_credito = bdicred:sd_tarjeta.num_credito and bdicred:sd_tarjeta.status_tar IN ('A','I','C'))
            WHERE bdicred:sd_maecred.numcte = p_sNumeroCliente 
            AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3') 		--IFRS 
            AND bdicred:sd_tarjeta.tipo_tarjeta in ('T','C')
            AND bdicred:sd_tarjeta.tipo_tarjeta != 'A'
            AND bdicred:sd_tarjeta.secuencia in (select max(secuencia) from bdicred:sd_tarjeta where numcte = p_sNumeroCliente GROUP BY num_credito)

            RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta WITH RESUME;
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_prod_cred_1(p_numeroCliente CHAR(20))
--SP QUE REGRESA LOS PRODUCTOS CON  estatus AA y BA con sus tarjetas asociadas
     RETURNING  CHAR(8)     AS numeroproducto,
                        CHAR(30)    AS nombreproducto,
                        CHAR(30)    AS cuentaproducto,
                        CHAR(30)    AS statusCuenta,
                        CHAR(30)    AS numero_tarjeta,
                        CHAR(30)    AS status_tarjeta;
    --definicion de variables--
    DEFINE resultado_numeroproducto             CHAR(8);
    DEFINE resultado_nombreproducto             CHAR(30);
    DEFINE resultado_cuentaproducto              CHAR(30);
    DEFINE resultado_statusCuenta                  CHAR(30);
    DEFINE resultado_numero_tarjeta                 CHAR(30);
    DEFINE resultado_status_tarjeta                 CHAR(30);
    DEFINE iSqlErr                                          INTEGER;

     -- Inicialización de las variables.


    LET resultado_numeroproducto        = '';
    LET resultado_nombreproducto        = '';
    LET resultado_cuentaproducto        = '';
    LET resultado_statusCuenta          = '';
    LET resultado_numero_tarjeta     = '';
    LET resultado_status_tarjeta        = '';

    --SET DEBUG FILE TO '/informix/sp_fal_busca_prod_cred_1.out';
    --TRACE ON;	
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET resultado_numeroproducto= '';
                    LET resultado_nombreproducto= '';
                    LET resultado_cuentaproducto= '';
                    LET resultado_statusCuenta= '';
                    LET resultado_numero_tarjeta = '';
                    LET resultado_status_tarjeta= '';
                RETURN resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,
                                resultado_statusCuenta , resultado_numero_tarjeta, resultado_status_tarjeta;
            END IF;
        END EXCEPTION;
        FOREACH
                   
            SELECT  DISTINCT bdicred:sd_maecred.num_producto AS numeroProducto,
                                                    nombre_prod AS nombreProducto,
                                                    bdicred:sd_maecred.num_credito AS cuentaProducto,
                                                    DECODE(bdicred:sd_maecred.status_cred,'AA','VIGENTE NORMAL','BA','VENCIDA NORMAL',  'BT', 'VENCIDA TRASPASADA','E1','CREDITO ETAPA 1','E2','CREDITO ETAPA 2','E3','CREDITO ETAPA 3') AS status_cuenta,
                                                    CASE 
                                                    WHEN bdicred:sd_tarjeta.num_tarjeta IS NULL THEN ''
                                                    else bdicred:sd_tarjeta.num_tarjeta end numero_tarjeta,
                                                    DECODE (bdicred:sd_tarjeta.status_tar,'A','ACTIVA','C','CANCELADA',NULL,'')  AS status_tarjeta
                    INTO resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,resultado_statusCuenta , resultado_numero_tarjeta,resultado_status_tarjeta
                    FROM bdicred:sd_maecred
                    LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecred.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecred.num_producto = bdicred:sd_definicion.num_producto)
                    LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
                    LEFT JOIN bdicred:sd_tarjeta ON  (bdicred:sd_maecred.num_credito = bdicred:sd_tarjeta.num_credito and bdicred:sd_tarjeta.status_tar IN ('A','I','C'))
                    WHERE bdicred:sd_maecred.numcte = p_numeroCliente
                    AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3')		--IFRS 
                    and bdicred:sd_tarjeta.num_tarjeta is null

        RETURN  resultado_numeroproducto , resultado_nombreproducto , resultado_cuentaproducto ,resultado_statusCuenta , resultado_numero_tarjeta,resultado_status_tarjeta  WITH RESUME;
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_producto_cred_cliente_1(p_sNumeroCliente CHAR(20), p_skip INT)

     RETURNING  CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);
    DEFINE iSqlErr                          INTEGER;
    
     -- Inicio de las variables.
     LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
            
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;

        FOREACH
            SELECT DISTINCT bdicred:sd_maecred.num_producto as numeroProducto, nombre_prod AS nombreProducto, bdicred:sd_maecred.num_credito AS cuentaProducto,
                    CASE 
                    WHEN bdicred:sd_tarjeta.num_tarjeta IS NULL THEN ''
                    else bdicred:sd_tarjeta.num_tarjeta end tarjetaProducto
                    INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
            FROM bdicred:sd_maecred 
                LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecred.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecred.num_producto = bdicred:sd_definicion.num_producto) 
                LEFT OUTER JOIN bdicred:sd_tarjeta ON (bdicred:sd_maecred.num_credito = bdicred:sd_tarjeta.num_credito and bdicred:sd_tarjeta.status_tar IN ('A','I','C'))
            WHERE bdicred:sd_maecred.numcte = p_sNumeroCliente
            AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT', 'E1', 'E2', 'E3') 		--IFRS  
            and bdicred:sd_tarjeta.num_tarjeta is null

            RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta WITH RESUME;
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_aclaraciones_producto_cliente
        (p_tipo_consulta         INTEGER, 
        p_id_producto            INTEGER,
        p_tipo_producto          INTEGER, 
        p_num_cliente            INTEGER, 
        p_pky_rango_importe      INTEGER)
    RETURNING   CHAR(5) AS s_codRet,
        VARCHAR(20) AS s_monto_total_aclaraciones,
        VARCHAR(20) AS s_numero_aclaraciones_con_abono,
        VARCHAR(20) AS s_importe_aclaraciones_con_abono,
        VARCHAR(20) AS s_numero_aclaraciones_sin_abono,
        VARCHAR(20) AS s_importe_aclaraciones_sin_abono,
        VARCHAR(20) AS s_total_numero_aclaraciones,
        VARCHAR(20) AS s_total_importe_aclaraciones;

DEFINE cod_retorno                                     CHAR(5);
DEFINE monto_total_aclaraciones_producto_cliente       MONEY;
DEFINE numero_aclaraciones_con_abono                   INTEGER;
DEFINE numero_aclaraciones_sin_abono                   INTEGER;
DEFINE importe_aclaraciones_con_abono                  MONEY;
DEFINE importe_aclaraciones_sin_abono                  MONEY;
DEFINE total_numero_aclaraciones                       INTEGER;
DEFINE total_importe_aclaraciones                      MONEY;

DEFINE monto_total_aclaraciones_producto_cliente_temp  MONEY;
DEFINE numero_aclaraciones_con_abono_temp              INTEGER;
DEFINE numero_aclaraciones_sin_abono_temp              INTEGER;
DEFINE importe_aclaraciones_con_abono_temp             MONEY;
DEFINE importe_aclaraciones_sin_abono_temp             MONEY;
DEFINE total_numero_aclaraciones_temp                  INTEGER;
DEFINE total_importe_aclaraciones_temp                 MONEY;

DEFINE iSqlErr                                         INTEGER;
DEFINE uno                                             INTEGER;
DEFINE cero                                            INTEGER;
DEFINE resolucion_con_abono_temporal                   INTEGER;
DEFINE resolucion_sin_abono_temporal                   INTEGER;
DEFINE estatus_aclaracion_ingresada                    INTEGER;
DEFINE estatus_aclaracion_con_dic_sin_digi             INTEGER;
DEFINE estatus_aclaracion_finalizada                   INTEGER;
DEFINE estatus_corp_gral_pred_aceptado                 INTEGER;
DEFINE estatus_corp_gral_cierre_prev_no_real           INTEGER;
DEFINE estatus_corp_gral_cierre_prev                   INTEGER;
DEFINE estatus_corp_analisis                           INTEGER;
DEFINE estatus_corp_por_abonar                         INTEGER;
DEFINE estatus_corp_dictamen_acep                      INTEGER;
DEFINE aclaracion_cuenta_movil                         INTEGER;
DEFINE estatus_dictamen_abonada_sin_autor              INTEGER;
DEFINE resolucion_con_abono                            INTEGER;
DEFINE estatus_corp_predictaminada                     INTEGER;
DEFINE fechaPasada                                     DATE;
DEFINE fechaActual                                     DATE;
DEFINE v_rango_menor                                   INTEGER;
DEFINE v_rango_mayor                                   INTEGER;
DEFINE v_monto_intervalo                               MONEY;

LET fechaActual                                        = NULL;
LET fechaPasada                                        = NULL;

LET total_numero_aclaraciones                          = 0;
LET total_importe_aclaraciones                         = 0;
LET numero_aclaraciones_con_abono                      = 0;
LET numero_aclaraciones_sin_abono                      = 0;
LET monto_total_aclaraciones_producto_cliente          = 0;
LET importe_aclaraciones_con_abono                     = 0;
LET importe_aclaraciones_sin_abono                     = 0;

LET monto_total_aclaraciones_producto_cliente_temp     = NULL;
LET numero_aclaraciones_con_abono_temp                 = NULL;
LET numero_aclaraciones_sin_abono_temp                 = NULL;
LET importe_aclaraciones_con_abono_temp                = NULL;
LET importe_aclaraciones_sin_abono_temp                = NULL;
LET total_numero_aclaraciones_temp                     = NULL;
LET total_importe_aclaraciones_temp                    = NULL;

LET cod_retorno                                        = '000*';
LET uno                                                = 1;
LET cero                                               = 0;

LET estatus_aclaracion_con_dic_sin_digi                = NULL;
LET estatus_corp_gral_cierre_prev                      = NULL;
LET estatus_corp_gral_cierre_prev_no_real              = NULL;
LET resolucion_con_abono_temporal                      = NULL;
LET resolucion_sin_abono_temporal                      = NULL;
LET resolucion_con_abono                               = NULL;
LET estatus_aclaracion_ingresada                       = NULL;
LET estatus_corp_analisis                              = NULL;
LET estatus_corp_predictaminada                        = NULL;
LET estatus_corp_por_abonar                            = NULL;
LET estatus_aclaracion_finalizada                      = NULL;
LET estatus_corp_dictamen_acep                         = NULL;
LET aclaracion_cuenta_movil                            = NULL;
LET estatus_dictamen_abonada_sin_autor                 = NULL;

LET v_rango_menor                                      = 0;
LET v_rango_mayor                                      = 0;
LET v_monto_intervalo                                  = 0;

BEGIN

ON EXCEPTION
    SET iSqlErr
    IF iSqlErr <> 0 THEN
        RETURN  '001*',iSqlErr||'*',0||'*',0||'*',0||'*',0||'*',0||'*',0||'*'; --RETURNING
    END IF;    
END EXCEPTION;
SET ISOLATION TO DIRTY READ; 
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/ifxsif01/VJMP/OPT_SP/traces/ejecucion_pbas.out"; --> TRACE
--TRACE ON;

/* Suma de abonos por rango */

--Obtiene la Fecha del dí­a de Hoy
SELECT fecha_hoy 
    INTO fechaActual
FROM bdinteg:si_fechas;

--Para Pruebas:
--LET fechaActual = today;

--Obtiene la fecha con un año de diferencia
LET fechaPasada = ADD_MONTHS(fechaActual,-12);

--Se valida si es requerido ejecutar el SP cuando es para ingreso de Aclaraciones
IF (p_tipo_consulta = '1') THEN
    /* Obtiene los rangos del intervalo (pky_rango_importe) */
    SELECT rango_menor, rango_mayor, monto_intervalo
        INTO v_rango_menor, v_rango_mayor, v_monto_intervalo
    FROM acl_rango_importe 
    WHERE pky_rango_importe = p_pky_rango_importe;
    
    LET v_monto_intervalo = NVL(v_monto_intervalo,cero);
    
    IF v_monto_intervalo = 0 THEN--Si el Valor en la columna monto_intervalo es cero, no es requerido ejecutar el SP
        RETURN cod_retorno,0||'*',0||'*',0||'*',0||'*',0||'*',0||'*',0||'*'; --RETURNING
	END IF;
END IF;


--Se obtienen las variables de los estatus
SELECT pky_estatus_aclaracion 
    INTO estatus_aclaracion_con_dic_sin_digi
FROM "informix".acl_estatus_aclaracion 
WHERE nombre='ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_gral_cierre_prev
FROM "informix".acl_estatus_corporativo 
where nombre = 'CIERRE_PREVENTIVO';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_gral_cierre_prev_no_real
FROM "informix".acl_estatus_corporativo 
where nombre = 'CIERRE_PREVENTIVO_NO_REALIZADO';

SELECT pky_resolucion 
    INTO resolucion_con_abono_temporal
FROM "informix".acl_resolucion 
where nombre = 'abonoMontoMaximo';

SELECT pky_resolucion 
    INTO resolucion_sin_abono_temporal
FROM "informix".acl_resolucion 
where nombre='analisisMontoMaximo';

SELECT pky_resolucion 
    INTO resolucion_con_abono
FROM "informix".acl_resolucion 
where nombre='abonoMontoMaximoBC';

SELECT pky_estatus_aclaracion 
    INTO estatus_aclaracion_ingresada
FROM "informix".acl_estatus_aclaracion 
where nombre='ACLARACION_INGRESADA';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_analisis
FROM "informix".acl_estatus_corporativo 
where nombre = 'ANALISIS';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_predictaminada
FROM "informix".acl_estatus_corporativo 
where nombre = 'PREDICTAMINADA';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_por_abonar
FROM "informix".acl_estatus_corporativo 
where nombre = 'POR_ABONAR';

SELECT pky_estatus_aclaracion 
    INTO estatus_aclaracion_finalizada
FROM "informix".acl_estatus_aclaracion 
where nombre = 'ACLARACION_FINALIZADA';

SELECT pky_estatus_corporativo 
    INTO estatus_corp_dictamen_acep
FROM "informix".acl_estatus_corporativo 
where nombre = 'DICTAMEN_ACEPTADA';

SELECT pky_cat_tipo_aclaracion 
    INTO aclaracion_cuenta_movil
from "informix".acl_cat_tipo_aclaracion 
where nombre = 'ACLARACION_VIA_TELEFONICA_TRAN';

SELECT pky_estatus_corporativo 
    INTO estatus_dictamen_abonada_sin_autor
FROM "informix".acl_estatus_corporativo 
where nombre = 'DICTAMEN_ABONADA_SIN_AUTORIZACION';

--Se crea la tabla temporal con las aclaraciones ingresadas del cliente
DROP TABLE IF EXISTS tblAclaraciones;
SELECT 
    acl.folio_csuac, acl.fechacaptura, acl.fky_cat_tipo_aclaracion, acl.fky_estatus_aclaracion, 
    acl.fky_estatus_corp_general, acl.num_cliente, acl.procede, mov.cargo, mov.exitoso, 
    tp.tipo_producto, mov.duplicado, mov.montoprocedente--, ri.pky_rango_importe
FROM acl_aclaracion acl 
    INNER JOIN acl_producto pr ON pr.pky_producto=acl.fky_producto 
    INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto = pr.fky_tipo_producto 
    INNER JOIN acl_movimiento mov ON mov.fky_aclaracion = acl.pky_aclaracion 
	/*INNER JOIN acl_rango_importe ri ON acl.fky_id_regla = acl.fky_regla_negocio 
		AND acl.importereclamado BETWEEN rango_menor AND rango_mayor */
WHERE acl.fky_cat_tipo_aclaracion <> aclaracion_cuenta_movil 
    AND acl.num_cliente= p_num_cliente 
    --AND tp.tipo_producto = p_tipo_producto 
	AND acl.fechacaptura BETWEEN fechaPasada AND fechaActual
INTO TEMP tblAclaraciones WITH NO LOG;

--Se generan los í­ndices para efectuar las búsquedas
CREATE INDEX "informix".idx_tblAclaraciones_monto ON tblAclaraciones(montoprocedente) ONLINE;
CREATE INDEX "informix".idx_tblAclaraciones_folio ON tblAclaraciones(folio_csuac) ONLINE;
CREATE INDEX "informix".idx_tblAclaraciones_estatus ON tblAclaraciones(fky_estatus_aclaracion, fky_estatus_corp_general) ONLINE;

--Se actualizan los montos nulos a 0
UPDATE tblAclaraciones SET montoprocedente = 0 WHERE montoprocedente IS NULL;

IF (p_tipo_consulta = '1') THEN
    
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_ingresada 
		AND fky_estatus_corp_general  =estatus_corp_analisis;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_finalizada 
		AND fky_estatus_corp_general =estatus_corp_dictamen_acep 
		AND procede=uno;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_ingresada 
		AND fky_estatus_corp_general=estatus_corp_gral_cierre_prev_no_real;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
		AND fky_estatus_corp_general=estatus_corp_gral_cierre_prev 
		AND procede=uno;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
		AND fky_estatus_corp_general=estatus_corp_dictamen_acep 
		AND procede=uno;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
		AND fky_estatus_corp_general=estatus_corp_dictamen_acep 
		AND procede=cero;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
		AND fky_estatus_corp_general=estatus_dictamen_abonada_sin_autor 
		AND procede=uno;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion= estatus_aclaracion_ingresada 
		AND fky_estatus_corp_general=estatus_corp_predictaminada;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente_temp = NULL;
	
	SELECT SUM(montoprocedente)
		INTO monto_total_aclaraciones_producto_cliente_temp
	FROM tblAclaraciones
	WHERE montoprocedente BETWEEN v_rango_menor AND v_rango_mayor 
		AND (cargo = cero AND exitoso = uno)
		AND fky_estatus_aclaracion = estatus_aclaracion_finalizada 
		AND fky_estatus_corp_general=estatus_dictamen_abonada_sin_autor 
		AND procede=uno;
	
	LET monto_total_aclaraciones_producto_cliente_temp = NVL(monto_total_aclaraciones_producto_cliente_temp, cero);
	LET monto_total_aclaraciones_producto_cliente = monto_total_aclaraciones_producto_cliente + monto_total_aclaraciones_producto_cliente_temp;
	LET monto_total_aclaraciones_producto_cliente = NVL(monto_total_aclaraciones_producto_cliente, cero);
    
END IF;

/* Consultas para el tablero de seguimiento */
IF (p_tipo_consulta = '2') THEN
    ---------------ACLARACIONES CON ABONO TEMPORAL---------------
    
    --Se realizan las búsquedas y se van sumando las cantidades
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_analisis 
        AND (cargo=cero AND exitoso=uno)
		AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_finalizada 
        AND fky_estatus_corp_general = estatus_corp_dictamen_acep 
        AND procede=uno
		AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_gral_cierre_prev_no_real 
        AND (cargo=cero AND exitoso=uno)
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
        AND fky_estatus_corp_general = estatus_corp_gral_cierre_prev 
        AND procede = uno
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
        AND fky_estatus_corp_general = estatus_corp_dictamen_acep 
        AND procede=uno
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_finalizada 
        AND fky_estatus_corp_general = estatus_dictamen_abonada_sin_autor 
        AND procede=uno
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_predictaminada 
        AND cargo=0
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono_temp = NULL;
    LET numero_aclaraciones_con_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_con_abono_temp, numero_aclaraciones_con_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
        AND fky_estatus_corp_general = estatus_dictamen_abonada_sin_autor 
        AND procede=uno
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_con_abono_temp = NVL(importe_aclaraciones_con_abono_temp, cero);
    LET numero_aclaraciones_con_abono_temp = NVL(numero_aclaraciones_con_abono_temp, cero);
    
    LET importe_aclaraciones_con_abono = importe_aclaraciones_con_abono + importe_aclaraciones_con_abono_temp;
    LET numero_aclaraciones_con_abono = numero_aclaraciones_con_abono + numero_aclaraciones_con_abono_temp;
    
    LET importe_aclaraciones_con_abono = NVL(importe_aclaraciones_con_abono, cero);
    LET numero_aclaraciones_con_abono = NVL(numero_aclaraciones_con_abono, cero);
    
    
    ---------------ACLARACIONES SIN ABONO TEMPORAL---------------
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_analisis 
        AND (procede is null AND cargo is null)
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_finalizada 
        AND fky_estatus_corp_general = estatus_corp_dictamen_acep AND procede=cero
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_gral_cierre_prev_no_real 
        AND (procede is null OR procede = 0)
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_con_dic_sin_digi 
        AND fky_estatus_corp_general = estatus_corp_gral_cierre_prev AND procede=cero
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion = estatus_aclaracion_con_dic_sin_digi 
        AND fky_estatus_corp_general = estatus_corp_dictamen_acep AND procede=cero
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_por_abonar AND procede is null
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_predictaminada AND cargo is null
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono_temp = NULL;
    LET numero_aclaraciones_sin_abono_temp = NULL;
    
    SELECT SUM(montoprocedente), COUNT(DISTINCT folio_csuac) 
        INTO importe_aclaraciones_sin_abono_temp, numero_aclaraciones_sin_abono_temp
    FROM tblAclaraciones
    WHERE fky_estatus_aclaracion= estatus_aclaracion_ingresada 
        AND fky_estatus_corp_general = estatus_corp_predictaminada 
        AND (procede = 0 AND cargo=1)
        AND tipo_producto = p_tipo_producto;
    
    LET importe_aclaraciones_sin_abono_temp = NVL(importe_aclaraciones_sin_abono_temp, cero);
    LET numero_aclaraciones_sin_abono_temp = NVL(numero_aclaraciones_sin_abono_temp, cero);
    
    LET importe_aclaraciones_sin_abono = importe_aclaraciones_sin_abono + importe_aclaraciones_sin_abono_temp;
    LET numero_aclaraciones_sin_abono = numero_aclaraciones_sin_abono + numero_aclaraciones_sin_abono_temp;
    
    LET importe_aclaraciones_sin_abono = NVL(importe_aclaraciones_sin_abono, cero);
    LET numero_aclaraciones_sin_abono = NVL(numero_aclaraciones_sin_abono, cero);
    
    --Se obtienen los Totales
    LET total_numero_aclaraciones = (numero_aclaraciones_sin_abono + numero_aclaraciones_con_abono);
    LET total_importe_aclaraciones = (importe_aclaraciones_sin_abono + importe_aclaraciones_con_abono);
    
    
END IF;
    --Se elimina la tabla temporal
    DROP TABLE IF EXISTS tblAclaraciones;
    
RETURN cod_retorno, NVL(monto_total_aclaraciones_producto_cliente,0)||'*', 
        NVL(numero_aclaraciones_con_abono,0)||'*', NVL(importe_aclaraciones_con_abono,0)||'*', 
        NVL(numero_aclaraciones_sin_abono,0)||'*', NVL(importe_aclaraciones_sin_abono,0)||'*',
        NVL(total_numero_aclaraciones,0)||'*',NVL(total_importe_aclaraciones,0);
END
END PROCEDURE
DOCUMENT
'Sp : sp_consulta_aclaraciones_producto_cliente',
'Sistema : Aclaraciones',
'AUTOR : Root',
'Modificación : Desarrollo Coppel',
'Modificación V4: Víctor J. Mendoza',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador : Norberto Corona Berruecos',
'FECHA : Enero/2020',
'VERSION : 4.0.0',
'BD : bdiaclaracion';

CREATE PROCEDURE "informix".sp_inserta_comentario(pFolio_csuac CHAR(16), pComentario LVARCHAR, pNumEmpleado CHAR(8))
--RETURNING CoRet CHAR(5), Resultado VARCHAR(250);
RETURNING CHAR(5) AS CoRet, VARCHAR(250) AS Resultado;
    DEFINE cCodRet              CHAR(6);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
	DEFINE CMensaje             CHAR(80);

    DEFINE vFolioCsuac			CHAR(11);
	DEFINE vResultado			CHAR(50);
	DEFINE vFechaActual         DATETIME YEAR to FRACTION(5);
	DEFINE vFechaDictamen		DATETIME YEAR to FRACTION(5);
	
	DEFINE wBegin               CHAR(1);
	
	DEFINE vIDAclaracion		INTEGER;
	DEFINE vEstatusAclInicial	INTEGER;
	DEFINE vEstatusCorpInicial	INTEGER;
	DEFINE vEstatusAnaInicial	INTEGER;
	DEFINE vFechaCapturaAcl		DATE;
	DEFINE vAreaAcl				INTEGER;

	DEFINE vIDUsusario			INTEGER;
	
	DEFINE vAccionAbono			INTEGER;
	DEFINE vAbonoTemporal		INTEGER;
	DEFINE vIndicadorAfectacion	INTEGER;
	DEFINE vAccionComentario	INTEGER;
	DEFINE v_comentario			LVARCHAR;
		

	
	LET vIDAclaracion		= NULL;
	LET vEstatusAclInicial	= NULL;
	LET vEstatusCorpInicial	= NULL;
	LET vEstatusAnaInicial	= NULL;
	LET vFechaCapturaAcl	= NULL;
	LET vAreaAcl			= NULL;
	LET cCodRet				= '00000';
	LET v_comentario 		= NULL;
	LET vAccionComentario	= NULL;
	LET vResultado			= NULL;
	
BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET cCodRet = sql_err;
		--ROLLBACK WORK;
		IF vResultado IS NULL THEN
			LET vResultado = 'Proceso Fallido';
		ELSE
			LET vResultado = TRIM(vResultado) || '-' || 'Proceso Fallido';
		END IF;
		
		
				
		RETURN cCodRet, vResultado;
	END EXCEPTION;
	
	/*ON EXCEPTION IN (-535)
			  
			  COMMIT WORK;
				
	END EXCEPTION WITH RESUME;*/

	SELECT current 
		INTO vFechaActual 
	FROM systables WHERE tabid = 1;

	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
	--SET DEBUG FILE TO "/resplogifx/Rey_David/sp_aplica_meses"||"_"||""||TRIM(pFolio_csuac)||""||".out";
	--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   
		SELECT pky_resolucion--, descripcion
			INTO vAccionComentario--, vDescripcionAccion
		FROM acl_resolucion
		WHERE nombre = 'comentarioTransaccion';
		
		SELECT pky_usuario 
			INTO vIDUsusario
		FROM acl_usuario
		WHERE  num_empleado = pNumEmpleado;
	
   	----
	
		LET v_comentario = 'El Usuario '|| pNumEmpleado || ' Capturo: ' ||pComentario;
	
		SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, pky_aclaracion, fky_area,  fechacaptura, 
				 folio_csuac
			INTO vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDAclaracion, vAreaAcl,  vFechaCapturaAcl, 
				vFolioCsuac
		FROM acl_aclaracion
		WHERE folio_csuac = pFolio_csuac;
		
	
			INSERT INTO acl_entrada_bitacora 
				(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
					fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
			VALUES(entrada_bitacora_seq.nextval, v_comentario, current, vFolioCsuac, vAccionComentario, vIDAclaracion, vAreaAcl, 
				vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDUsusario);
			
						

	
	RETURN cCodRet, 'Comentario Guardado Correctamente';


	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_inserta_comentario',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Rey David Zavala Garcia',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	16/08/2022',
'VERSION		:	1.0.0',
'BD    			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscarevento(
                        pTipoProducto INTEGER,
                        pOrigenEvento INTEGER,
						pEstatusTarjeta CHAR(3))

	RETURNING
		CHAR(3) 			as cCodRet,
		INTEGER 			as pky_tipo_evento,
		SMALLINT			as capturamanual,
		CHAR(50)			as descripcion,
		SMALLINT			as diferenciaimportes,
		CHAR(4)				as grupo_doc,
		CHAR(50)			as nombre,
		INTEGER				as fky_tipo_transaccion,
		MONEY				as costo,
		SMALLINT			as acepta_cargos_recurrentes,
		CHAR(2)				as motivobloqueodebito,
		INTEGER				as tipobloqueocredito,
		CHAR(2)				as motivobloqueocredito,
		INTEGER				as tipobloqueodebito,
		CHAR(3)				as statusTarjeta,
		CHAR(1)				as validacion_cancelacion_automatica,
		CHAR(1)				as es_compra_a_meses;

	--Variables--
		DEFINE sql_err 						INTEGER;
		DEFINE v_cod_ret 					CHAR(3);
		DEFINE v_pky_tipo_evento  			INTEGER;
		DEFINE v_capturamanual	 			SMALLINT;
		DEFINE v_descripcion  				VARCHAR(50);
		DEFINE v_diferenciaimportes  		SMALLINT;
		DEFINE v_grupo_doc  				VARCHAR(4);
		DEFINE v_nombre  					VARCHAR(50);
		DEFINE v_fky_tipo_transaccion  		INTEGER;
		DEFINE v_costo 						MONEY;
		DEFINE v_acepta_cargos_recurrentes	SMALLINT;
		DEFINE v_motivobloqueodebito  		CHAR(2);
		DEFINE v_tipobloqueocredito 		INTEGER;
		DEFINE v_motivobloqueocredito 		CHAR(2);
		DEFINE v_tipobloqueodebito 			INTEGER;
		DEFINE v_statustarjeta		 		CHAR(3);
		DEFINE v_indroboextravio 			SMALLINT;
		DEFINE v_contador_eventos 			INTEGER;
		DEFINE v_validacion_cancelacion_automatica CHAR(1);
		DEFINE v_es_compra_a_meses 			CHAR(1);

		LET v_cod_ret 					= "000";
		LET v_pky_tipo_evento 			= "";
		LET v_capturamanual	 			= "";
		LET v_descripcion 				= "";
		LET v_diferenciaimportes		= "";
		LET v_grupo_doc					= "";
		LET v_nombre					= "";
		LET v_fky_tipo_transaccion		= "";
		LET v_costo						= "";
		LET v_acepta_cargos_recurrentes	= "";
		LET v_motivobloqueodebito		= "";
		LET v_tipobloqueocredito		= "";
		LET v_motivobloqueocredito		= "";
		LET v_tipobloqueodebito 		= "";
		LET v_statustarjeta				= "";
		LET v_indroboextravio			= 0;
		LET v_contador_eventos 			= 0;
		LET v_validacion_cancelacion_automatica = "";
		LET v_es_compra_a_meses			= "";


		BEGIN
		  ON EXCEPTION SET sql_err
		     IF sql_err <> 0 THEN
		   	     LET v_cod_ret = sql_err;
			     RETURN v_cod_ret,v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
			     		v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,
						v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses;
		     END IF;
		   END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_buscarevento.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT indicador_robo_extravio
		INTO v_indroboextravio
		FROM acl_origen_evento
		WHERE pky_origen_evento = pOrigenEvento;
		
		IF v_indroboextravio = 1 THEN
			SELECT COUNT(*) 
			INTO v_contador_eventos
			FROM acl_tipo_evento tipoeve
			INNER JOIN acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
			INNER JOIN acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
			WHERE tipoeve.fky_origen_evento = pOrigenEvento
			AND tipoproduc.pky_tipo_producto=pTipoProducto
				AND tipoeve.status_tarjeta = pEstatusTarjeta;
				
		
			IF  v_contador_eventos > 0 THEN
				
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto and
						tipoeve.status_tarjeta=pEstatusTarjeta
						order by tipoeve.descripcion asc

					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
				
			ELSE
				
				SET ISOLATION TO DIRTY READ;
			
				FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto
						order by tipoeve.descripcion asc
			
					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
			
			END IF;
			
		ELSE
			
			SET ISOLATION TO DIRTY READ;
			
			FOREACH
					select tipoeve.pky_tipo_evento, tipoeve.capturamanual, tipoeve.descripcion, tipoeve.diferenciaimportes, tipoeve.grupo_doc, tipoeve.nombre,
						tipoeve.fky_tipo_transaccion, tipoeve.costo, tipoeve.acepta_cargos_recurrentes, tipoeve.motivobloqueodebito, tipoeve.tipobloqueocredito,
						tipoeve.motivobloqueocredito, tipoeve.tipobloqueodebito, tipoeve.status_tarjeta, tipoeve.validacion_can_msi, tipoeve.compra_meses
						INTO v_pky_tipo_evento,v_capturamanual,v_descripcion,v_diferenciaimportes,v_grupo_doc,v_nombre,v_fky_tipo_transaccion,
							v_costo,v_acepta_cargos_recurrentes,v_motivobloqueodebito,v_tipobloqueocredito,v_motivobloqueocredito,v_tipobloqueodebito,v_statustarjeta, v_validacion_cancelacion_automatica, v_es_compra_a_meses
						from acl_tipo_evento tipoeve
						inner join acl_origen_evento origeneve on tipoeve.fky_origen_evento=origeneve.pky_origen_evento
						inner join acl_tipo_prod_tipo_evento tipoproduceve on tipoeve.pky_tipo_evento=tipoproduceve.fky_tipo_evento
						inner join acl_tipo_producto tipoproduc on tipoproduceve.fky_tipo_producto=tipoproduc.pky_tipo_producto
						where tipoeve.activo=1 and
						origeneve.pky_origen_evento=pOrigenEvento and
						tipoproduc.pky_tipo_producto=pTipoProducto
						order by tipoeve.descripcion asc
			
					RETURN
						v_cod_ret,
						v_pky_tipo_evento,
						v_capturamanual,
						v_descripcion,
						v_diferenciaimportes,
						v_grupo_doc,
						v_nombre,
						v_fky_tipo_transaccion,
						v_costo,
						v_acepta_cargos_recurrentes,
						v_motivobloqueodebito,
						v_tipobloqueocredito,
						v_motivobloqueocredito,
						v_tipobloqueodebito,
						v_statustarjeta,
						v_validacion_cancelacion_automatica,
						v_es_compra_a_meses
					WITH RESUME;
				END FOREACH;
		
		END IF;

		END;
END PROCEDURE
DOCUMENT
'Sp sp_buscarevento',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 16/10/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD    :  bdiaclaracion',
'AUTOR: Juan RomÃ?Â¡n Toledo',
'FECHA: 09/12/2019',
'DESCRIPCION: Se modifica procedimiento para retornar tipos evento por estatus tarjeta existente.',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_cte_domiciliacion(
	bandera CHAR(5),
	eNumeroCliente CHAR(20),
	eNumeroTarjeta CHAR(20),
	eNumeroCuenta CHAR(20),
	eEmpresa CHAR(3),
	eTelefonoTransfer CHAR(20),
	ePrimerNombre CHAR(30),
	eSegundoNombre CHAR(30),
	ePrimerApellido CHAR(30),
	eSegundoApellido CHAR(30),
	eTelefonoCorreo CHAR(5),
	eConsultaDatosActual INTEGER,
	eNumEmpleado CHAR(12),
	eClienteTelefonoCelular CHAR(20),
	eClienteCorreoElectronico CHAR(100),
	eFechaInicial DATE,
	eFechaFinal DATE,
	eMonto money(16,2),
	eNumeroTransacciones lvarchar,
	--eNumeroTransacciones LIST(CHAR(4) NOT NULL);
	eFolioSuc CHAR(20),
	eOrigenEvento INTEGER,
	eArchivoInternacional CHAR(30),
	eArchivoNacional CHAR(30),
	eSkip INTEGER,
	opc1 CHAR(30),
	opc2 CHAR(30),
	opc3 CHAR(30),
	opc4 CHAR(30),
	opc5 CHAR(30))

RETURNING 

	CHAR(5)   AS sCodigoRetorno, 
	CHAR(100) AS sCodigoDescripcion,
	CHAR(10)  AS sNumeroRegistros,
	CHAR(20)  AS sNumeroCliente,
	CHAR(30)  AS sPrimerNombre,
	CHAR(30)  AS sSegundoNombre,
	CHAR(30)  AS sPrimerApellido,
	CHAR(30)  AS sSegundoApellido,
	CHAR(6)   AS sNumeroProducto,
	CHAR(60)  AS sDescripcionProducto,
	CHAR(20)  AS sNumeroCuenta,
	CHAR(20)  AS sNumeroTarjeta,
	CHAR(3)   AS sStatusTarjeta,
	CHAR(20)  AS sTelefonoTransfer,
	CHAR(30)  AS sNumeroCuentaInversion,
	CHAR(30)  AS sNumeroCuentaTransfer,
	CHAR(30)  AS sNumeroClienteTransfer,
	CHAR(20)  AS sTelefonoCasa,
	CHAR(20)  AS sTelefonoCelular,
	CHAR(30)  AS sCompaniaCelular,
	INTEGER   AS sIdCompaniaCelular,
	CHAR(100) AS sCorreoElectronico,
	DATE      AS sFechaMovimiento,
	DATETIME HOUR to FRACTION(3) AS sHoraMovimiento,
	MONEY(16,2) AS sMonto,
	CHAR(20)  AS sFolioSuc,
	CHAR(40)  AS sReferencia,
	CHAR(30)  AS sNombreSucursal,
	CHAR(5)   AS sNumeroSucursal,
	CHAR(5)   AS sTransaccion,
	CHAR(50)  AS sTranDescripcion,
	CHAR(10)  AS sActivo,
	CHAR(10)  AS sTipoMovimiento,
	CHAR(10)  AS sMovimientoDuplicado,
	CHAR(23)  AS sReferencia23,
	BOOLEAN   AS sReversado,
	CHAR(40)  AS sReferenciaComercio,
	DATE      AS sFechaConsumo,
	DATETIME HOUR to FRACTION(3) AS sHoraConsumo,
	CHAR(5)   AS sModoEntrada,
	CHAR(5)   AS sSecuenciaFolio,
	CHAR(30)  AS ret1,
	CHAR(30)  AS ret2,
	CHAR(30)  AS ret3,
	CHAR(30)  AS ret4,
	CHAR(30)  AS ret5;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE BUSQUEDA DE CLIENTES Y MOVIMIENTOS PARA CANCELACION Y OBJECION DE DOMICILIACIONES POR EL BUS.
-- FECHA : 22/07/2022
-- BD: Bdiaclaracion
-- SISTEMA : Aclaraciones
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

	-- DATOS SALIDA
	DEFINE sCodigoRetorno CHAR(5);
	DEFINE sCodigoDescripcion CHAR(100);
	DEFINE sNumeroRegistros CHAR(10);
	DEFINE sNumeroCliente CHAR(20);
	DEFINE sPrimerNombre CHAR(30);
	DEFINE sSegundoNombre CHAR(30);
	DEFINE sPrimerApellido CHAR(30);
	DEFINE sSegundoApellido CHAR(30);
	DEFINE sNumeroProducto CHAR(6);
	DEFINE sDescripcionProducto CHAR(60);
	DEFINE sNumeroCuenta CHAR(20);
	DEFINE sNumeroTarjeta CHAR(20);
	DEFINE sStatusTarjeta CHAR(3);
	DEFINE sTelefonoTransfer CHAR(20);
	DEFINE sNumeroCuentaInversion CHAR(30);
	DEFINE sNumeroCuentaTransfer CHAR(30);
	DEFINE sNumeroClienteTransfer CHAR(30);
	DEFINE sTelefonoCasa CHAR(20);
	DEFINE sTelefonoCelular CHAR(20);
	DEFINE sCompaniaCelular CHAR(30);
	DEFINE sIdCompaniaCelular INTEGER;
	DEFINE sCorreoElectronico CHAR(100);
	DEFINE sFechaMovimiento DATE;
	DEFINE sHoraMovimiento DATETIME HOUR to FRACTION(3);
	DEFINE sMonto MONEY(16,2);
	DEFINE sFolioSuc CHAR(20);
	DEFINE sReferencia CHAR(40);
	DEFINE sNombreSucursal CHAR(30);
	DEFINE sNumeroSucursal CHAR(5);
	DEFINE sTransaccion CHAR(5);
	DEFINE sTranDescripcion CHAR(50);
	DEFINE sActivo CHAR(10);
	DEFINE sTipoMovimiento CHAR(10);
	DEFINE sMovimientoDuplicado CHAR(10);
	DEFINE sReferencia23 CHAR(23);
	DEFINE sReversado BOOLEAN;
	DEFINE sReferenciaComercio CHAR(40);
	DEFINE sFechaConsumo DATE;
	DEFINE sHoraConsumo DATETIME HOUR to FRACTION(3);
	DEFINE sModoEntrada CHAR(5);
	DEFINE sSecuenciaFolio CHAR(5);
	DEFINE ret1 CHAR(30);
	DEFINE ret2 CHAR(30);
	DEFINE ret3 CHAR(30);
	DEFINE ret4 CHAR(30);
	DEFINE ret5 CHAR(30);
	DEFINE iSqlErr INTEGER ;
	DEFINE reversado CHAR(30);
	
	
	

	/* INICIALIZACION DE VARIABLES */
	
	LET sCodigoRetorno = '00000';
	LET sCodigoDescripcion = 'Proceso Exitoso.';
	LET sNumeroRegistros = '';
	LET sNumeroCliente = '';
	LET sPrimerNombre = '';
	LET sSegundoNombre = '';
	LET sPrimerApellido = '';
	LET sSegundoApellido = '';
	LET sNumeroProducto = '';
	LET sDescripcionProducto = '';
	LET sNumeroCuenta = '';
	LET sNumeroTarjeta = '';
	LET sStatusTarjeta = '';
	LET sTelefonoTransfer = '';
	LET sNumeroCuentaInversion = '';
	LET sNumeroCuentaTransfer = '';
	LET sNumeroClienteTransfer = '';
	LET sTelefonoCasa = '';
	LET sTelefonoCelular = '';
	LET sCompaniaCelular = '';
	LET sIdCompaniaCelular = '';
	LET sCorreoElectronico = '';
	LET sFechaMovimiento = '';
	LET sHoraMovimiento = ''; 
	LET sMonto = '';
	LET sFolioSuc = '';
	LET sReferencia = '';
	LET sNombreSucursal = '';
	LET sNumeroSucursal = '';
	LET sTransaccion = '';
	LET sTranDescripcion = '';
	LET sActivo = '';
	LET sTipoMovimiento = '';
	LET sMovimientoDuplicado = '';
	LET sReferencia23 = '';
	LET sReversado = 'f';
	LET sReferenciaComercio = '';
	LET sFechaConsumo  = '';
	LET sHoraConsumo = '';
	LET sModoEntrada = '';
	LET sSecuenciaFolio = '';
	LET ret1 = '';
	LET ret2 = '';
	LET ret3 = '';
	LET ret4 = '';
	LET ret5 = '';
	LET iSqlErr = 0;
	LET reversado = '';
	
	
BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno,'', 'bdiaclaracion:sp_busca_cte_domiciliacion', 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));

			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		    sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		    sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		    sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		END IF;
	END EXCEPTION; 
			
	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_busca_cte_domiciliacion.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	IF bandera =  "1" THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientespornumero(eNumeroCliente) INTO sNumeroCliente, sPrimerNombre,sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "2") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientesportarjeta(eNumeroTarjeta) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "3") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscarclientesporcuenta(eNumeroCuenta, eEmpresa) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "4") THEN  --Validar si no es necesario todos los parametros
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscarclientespornombre(eEmpresa,ePrimerNombre,eSegundoNombre,ePrimerApellido,eSegundoApellido,'', '','',eSkip) INTO sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
			
		END FOREACH;
	
	ELIF (bandera = "5") THEN --Para este caso el numero de cuenta es el numero de credito de la tabla sd_maecred	
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cuenta(eNumeroCuenta,eSkip,eEmpresa) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "6") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_tarjeta(eNumeroTarjeta,eEmpresa) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta;
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "7") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_transfer_telefono(eTelefonoTransfer,eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sTelefonoTransfer, sNumeroClienteTransfer, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "8") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_deb_cheq_cliente(eNumeroCliente,eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "9") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "10") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_cred_cliente_crd(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sStatusTarjeta
	
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "11") THEN
	
		FOREACH
		
			EXECUTE PROCEDURE bdinteg:sp_busca_producto_deb_inver_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sNumeroCuentaInversion 
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "12") THEN
	
		FOREACH
           
		   EXECUTE PROCEDURE bdinteg:sp_busca_producto_transfer_cliente(eNumeroCliente, eSkip) INTO sNumeroProducto, sDescripcionProducto, sNumeroCuenta, sNumeroTarjeta, sTelefonoTransfer, sNumeroClienteTransfer, sStatusTarjeta
		
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
				   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
				   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
				   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "13") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos(eEmpresa, eNumeroCliente, eConsultaDatosActual, eTelefonoCorreo) INTO sCodigoRetorno,sTelefonoCelular, sCorreoElectronico,sSecuenciaFolio, sActivo, ret1, sIdCompaniaCelular, sCompaniaCelular, ret2     
			
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	ELIF (bandera = "14") THEN 
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_cheques_dia3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa) 
			INTO sFechaMovimiento, sHoraMovimiento,sMonto,sFolioSuc,sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo 
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean	
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "15") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_inversion_dia2(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento,sMonto,sFolioSuc,sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,reversado	
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "16") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_inversion_his2(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTransacciones,eEmpresa) INTO sFechaMovimiento;
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "17") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_transfer(eNumeroCuenta,eTelefonoTransfer,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
		INTO sFechaMovimiento, sHoraMovimiento, sMonto, sTransaccion, sTranDescripcion,sFolioSuc,sNumeroSucursal;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "18") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_credito_dia3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "19") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_credito_his3(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "20") THEN
		
		FOREACH
			
			EXECUTE PROCEDURE bdinteg:sp_buscar_movimientos_creditocrd_his(eNumeroCuenta,eFechaInicial,eFechaFinal,eMonto,eSkip,eNumeroTarjeta,eNumeroTransacciones,eEmpresa)
			INTO sFechaMovimiento, sHoraMovimiento, sMonto,sFolioSuc, sNumeroSucursal,sNombreSucursal,sTransaccion,sTranDescripcion,sReferencia23,reversado,sReferenciaComercio,sFechaConsumo,sHoraConsumo
			IF reversado = '' THEN LET sReversado = 'f'; ELSE LET sReversado = 't'; END IF; --Validacion de variable que si viene en blanco manda un bolean
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
					   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
					   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
					   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		
		END FOREACH;
	
	ELIF (bandera = "21") THEN	
		
		EXECUTE PROCEDURE bdiaclaracion:sp_consulta_tipo_movimiento(eFolioSuc,eNumeroTarjeta,eOrigenEvento) INTO sTipoMovimiento, sModoEntrada;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "22") THEN
		
		EXECUTE PROCEDURE bdiaclaracion:sp_obten_secuencia_folio() INTO sSecuenciaFolio;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
		   
	ELIF (bandera = "23") THEN
		
		EXECUTE PROCEDURE bdinteg:sp_obten_referencia23_cheques(eFolioSuc,eArchivoInternacional,eArchivoNacional,eEmpresa) INTO sReferencia23;
		
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
	ELIF (bandera = "24") THEN
		
		FOREACH
		
			EXECUTE PROCEDURE bdidomi:sp_consultaparamdomi("12") 
			INTO sCodigoRetorno, sCodigoDescripcion, sTranDescripcion
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
			   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
			   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
			   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;	
		
		END FOREACH;
	ELIF (bandera = "25") THEN
	
		FOREACH
		
			EXECUTE PROCEDURE bdidomi:sp_consultactasdomi(eNumeroCliente,0) 
			INTO sCodigoRetorno, sNumeroCuenta, sNumeroProducto,ret1,sNumeroTarjeta 
			RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
			   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
			   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
			   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5 WITH RESUME;
		END FOREACH;		
	ELSE
		
		LET sCodigoRetorno = '00004';
		LET sCodigoDescripcion = 'BÃºsqueda No Encontrada.';
	
		RETURN sCodigoRetorno, sCodigoDescripcion, sNumeroRegistros, sNumeroCliente, sPrimerNombre, sSegundoNombre, sPrimerApellido, sSegundoApellido, sNumeroProducto, sDescripcionProducto, sNumeroCuenta,           
		   sNumeroTarjeta, sStatusTarjeta, sTelefonoTransfer, sNumeroCuentaInversion, sNumeroCuentaTransfer, sNumeroClienteTransfer, sTelefonoCasa, sTelefonoCelular, sCompaniaCelular, sIdCompaniaCelular,      
		   sCorreoElectronico, sFechaMovimiento, sHoraMovimiento, sMonto, sFolioSuc, sReferencia, sNombreSucursal, sNumeroSucursal, sTransaccion, sTranDescripcion, sActivo, sTipoMovimiento, sMovimientoDuplicado,    
		   sReferencia23, sReversado, sReferenciaComercio, sFechaConsumo, sHoraConsumo, sModoEntrada, sSecuenciaFolio, ret1, ret2, ret3, ret4, ret5;
	END IF;		
END
END PROCEDURE;