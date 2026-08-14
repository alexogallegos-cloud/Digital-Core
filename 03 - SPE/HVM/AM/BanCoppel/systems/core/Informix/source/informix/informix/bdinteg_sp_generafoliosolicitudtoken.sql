CREATE PROCEDURE "informix".sp_generafoliosolicitudtoken()
RETURNING  	CHAR(6) AS codret,
			CHAR(12) AS foliosolicitutoken;

DEFINE cCodRet 			CHAR(6);
DEFINE cFolioSolToken	CHAR(12);
DEFINE iSqlErr			INTEGER;

DEFINE cCodigo			CHAR(3);
DEFINE cDescripcion		CHAR(4);

DEFINE cFolio0			CHAR(12);
DEFINE cFolio1			CHAR(12);
DEFINE cFolio2			CHAR(12);
DEFINE cFolio3			CHAR(12);
DEFINE cFolio4			CHAR(12);
DEFINE cFolio5			CHAR(12);
DEFINE cFolio6			CHAR(12);
DEFINE cFolio7			CHAR(12);
DEFINE cFolio8			CHAR(12);
DEFINE cFolio9			CHAR(12);
DEFINE cFolio10			CHAR(12);
DEFINE cFolio11			CHAR(12);

DEFINE iFolio0			INTEGER;
DEFINE iFolio1			INTEGER;
DEFINE iFolio2			INTEGER;
DEFINE iFolio3			INTEGER;
DEFINE iFolio4			INTEGER;
DEFINE iFolio5			INTEGER;
DEFINE iFolio6			INTEGER;
DEFINE iFolio7			INTEGER;
DEFINE iFolio8			INTEGER;
DEFINE iFolio9			INTEGER;
DEFINE iFolio10			INTEGER;
DEFINE iFolio11			INTEGER;

DEFINE iAlfaNum1		INTEGER;
DEFINE iAlfaNum2		INTEGER;
DEFINE iAlfaNum3		INTEGER;
DEFINE iAlfaNum4		INTEGER;
DEFINE iAlfaNum5		INTEGER;

DEFINE iCont			INTEGER;

DEFINE dValor			DECIMAL(18,2);

DEFINE dFechahoy		DATE;
DEFINE cDia				CHAR(2);
DEFINE cMes				CHAR(2);
DEFINE cAnio			CHAR(4);


LET cCodRet 			= '000001';
LET cFolioSolToken	 	= '';
LET iSqlErr				= 0;
LET cCodigo				= '';
LET cDescripcion		= '';

LET cFolio0				= '';
LET cFolio1				= '';
LET cFolio2				= '';	
LET cFolio3				= '';
LET cFolio4				= '';
LET cFolio5				= '';
LET cFolio6				= '';
LET cFolio7				= '';
LET cFolio8				= '';
LET cFolio9				= '';
LET cFolio10			= '';
LET cFolio11			= '';

LET iFolio0				= 0;
LET iFolio1				= 0;
LET iFolio2				= 0;
LET iFolio3				= 0;
LET iFolio4				= 0;
LET iFolio5				= 0;
LET iFolio6				= 0;
LET iFolio7				= 0;
LET iFolio8				= 0;
LET iFolio9				= 0;
LET iFolio10			= 0;
LET iFolio11			= 0;

LET iAlfaNum1			= 0;
LET iAlfaNum2			= 0;
LET iAlfaNum3			= 0;
LET iAlfaNum4			= 0;
LET iAlfaNum5			= 0;

LET iCont				= 0;

LET dValor				= 0;

LET dFechahoy			= DATE(1);
LET cDia				= '';
LET cMes				= '';
LET cAnio				= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,cFolioSolToken;
		END IF;
	END EXCEPTION;

--SET debug FILE TO "/home/Antonio/sp_generafoliosolicitudtoken.out";
--Trace ON;
	SET LOCK MODE TO WAIT 3;
	--Obtiene la fecha del sistema
	SELECT fecha_hoy 
	INTO dFechahoy
	FROM bdicheq:"informix".sc_fechas 
	WHERE empresa = '001';
	
	--Juego de datos con formANDo las letras.
	WHILE iCont <= 4
		
	 --Obtiene numero al azae del 1-100
	 EXECUTE PROCEDURE bdicheq:"informix".sp_random()INTO dValor;
	 
	 SELECT MOD(SUBSTR(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO fraction(3),7,2) + dValor,99) 
	 INTO dValor from sysmaster:sysshmvals;
				
		--Compara que el valor se encuentre entre los rangos explicitos
		IF (dValor > 65 AND dValor < 90) Or (dValor > 47 AND dValor < 58) THEN

			IF iCont = 0 THEN			
				LET iAlfaNum1 = dValor::INTEGER;
			END IF;
			
			IF iCont = 1 THEN			
				LET iAlfaNum2 = dValor::INTEGER;
			END IF;
			
			IF iCont = 2 THEN			
				LET iAlfaNum3 = dValor::INTEGER;
			END IF;

			
			IF iCont = 3 THEN			
				LET iAlfaNum4 = dValor::INTEGER;
			END IF;
						
			IF iCont = 4 THEN			
				LET iAlfaNum5 = dValor::INTEGER;
			END IF;

			LET iCont = iCont + 1;
		END IF;
		
		-- Si el valor obtenido no se encuentra en los rangos anteriores se divide entre 10 ya que los valores estan entre 1 y 100,
		-- estos se redondean para obtener un valor entre 1 y 9
        IF dValor::INTEGER >= 0 AND dValor::INTEGER <= 9 THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(dValor::INTEGER) INTO cCodRet,cCodigo,cDescripcion;
			
            IF iCont = 0 THEN			
				LET iAlfaNum1 = cDescripcion::INTEGER;
			END IF;
			
			IF iCont = 1 THEN			
				LET iAlfaNum2 = cDescripcion::INTEGER;
			END IF;
			
			IF iCont = 2 THEN			
				LET iAlfaNum3 = cDescripcion::INTEGER;
			END IF;

			
			IF iCont = 3 THEN			
				LET iAlfaNum4 = cDescripcion::INTEGER;
			END IF;
						
			IF iCont = 4 THEN			
				LET iAlfaNum5 = cDescripcion::INTEGER;
			END IF;
            LET iCont = iCont + 1;
        END IF;
	END WHILE;
	
	-- Obtiene los valores de fechas, DDMMAA
	LET cDia = LPAD(DAY(dFechahoy),2,'0');
	LET cMes = LPAD(MONTH(dFechahoy),2,'0');
	LET cAnio = LPAD(YEAR(dFechahoy),4,'0');
	
	--Inicia con el algoritmo para generar el identificador de 11 digitos
	LET iFolio0 = SUBSTR(cDia,1,1)::INTEGER;
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum1) INTO cCodRet,cCodigo,cDescripcion;
	LET iFolio1 = CASE WHEN iAlfaNum1 > 65 THEN iAlfaNum1 - 64 ELSE  cDescripcion::INTEGER END;
    LET iFolio2 = SUBSTR(cAnio,3,1)::INTEGER;
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum2) INTO cCodRet,cCodigo,cDescripcion;
	LET iFolio3 = CASE WHEN iAlfaNum2 > 65 THEN iAlfaNum2 - 64 ELSE  cDescripcion::INTEGER END;
    LET iFolio4 = SUBSTR(cDia,2,1)::INTEGER;
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum3) INTO cCodRet,cCodigo,cDescripcion;
	LET iFolio5 = CASE WHEN iAlfaNum3 > 65 THEN iAlfaNum3 - 64 ELSE  cDescripcion::INTEGER END;
    LET iFolio6 = SUBSTR(cMes,1,1)::INTEGER;
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum4) INTO cCodRet,cCodigo,cDescripcion;
	LET iFolio7 = CASE WHEN iAlfaNum4 > 65 THEN iAlfaNum4 - 64 ELSE  cDescripcion::INTEGER END;
    LET iFolio8 = SUBSTR(cAnio,4,1)::INTEGER;
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum5) INTO cCodRet,cCodigo,cDescripcion;
	LET iFolio9 = CASE WHEN iAlfaNum5 > 65 THEN iAlfaNum5 - 64 ELSE  cDescripcion::INTEGER END;
    LET iFolio10 = SUBSTR(cMes,2,1)::INTEGER;
	
	-- Genera el digito verificador
	LET iFolio11 = iFolio11 + (iFolio0 * 1);
	LET iFolio11 = iFolio11 + (iFolio1 * 5);
    LET iFolio11 = iFolio11 + (iFolio2 * 1);
    LET iFolio11 = iFolio11 + (iFolio3 * 5);
    LET iFolio11 = iFolio11 + (iFolio4 * 1);
    LET iFolio11 = iFolio11 + (iFolio5 * 5);
    LET iFolio11 = iFolio11 + (iFolio6 * 1);
    LET iFolio11 = iFolio11 + (iFolio7 * 5);
    LET iFolio11 = iFolio11 + (iFolio8 * 1);
    LET iFolio11 = iFolio11 + (iFolio9 * 5);
    LET iFolio11 = iFolio11 + (iFolio10 * 1);
	LET iFolio11 = iFolio11 + 137;
    LET iFolio11 = MOD(iFolio11,7);
	
	--asigna el 1er numero
	LET cFolio0 = SUBSTR(cDia,1,1)::INTEGER;
	--asigna el 2do numero
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum1) INTO cCodRet,cCodigo,cDescripcion;
	LET cFolio1 = TRIM(cDescripcion);    
	--asigna el 3er numero
	LET cFolio2 = SUBSTR(cAnio,3,1)::INTEGER;	
    --asigna el 4to numero
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum2) INTO cCodRet,cCodigo,cDescripcion;
	LET cFolio3 = TRIM(cDescripcion);	
    --asigna el 5to numero
	LET cFolio4 = SUBSTR(cDia,2,1)::INTEGER;
    --asigna el 6to numero
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum3) INTO cCodRet,cCodigo,cDescripcion;
	LET cFolio5 = TRIM(cDescripcion);	
    --asigna el 7mo numero
	LET cFolio6 = SUBSTR(cMes,1,1)::INTEGER;
    --asigna el 8vo numero
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum4) INTO cCodRet,cCodigo,cDescripcion;
	LET cFolio7 = TRIM(cDescripcion);	
    --asigna el 9no numero
	LET cFolio8 = SUBSTR(cAnio,4,1)::INTEGER;
	--asigna el 10mo numero
	EXECUTE PROCEDURE bdinteg:"informix".sp_consultacodigoascii(iAlfaNum5) INTO cCodRet,cCodigo,cDescripcion;
	LET cFolio9 = TRIM(cDescripcion);	
    --asigna el 11mo numero
	LET cFolio10 = SUBSTR(cMes,2,1)::INTEGER;	
    --asigna el 12vo digito verificador
	LET cFolio11 = iFolio11;
	
	--Une los 12 digitos y/o letras.
	LET cFolioSolToken = TRIM(cFolio0) || TRIM(cFolio1) || TRIM(cFolio2) || TRIM(cFolio3) || TRIM(cFolio4) || TRIM(cFolio5) || TRIM(cFolio6) || TRIM(cFolio7) || TRIM(cFolio8) || TRIM(cFolio9) || TRIM(cFolio10) || TRIM(cFolio11);
	
	--Comprueba que el folio generado es de 12 digitos
	IF LENGTH(cFolioSolToken) = 12 Then
        LET cCodRet = '000000';
    END IF;
	
	RETURN cCodRet,cFolioSolToken;
END
END PROCEDURE
Document
'DESCRIPCION: Proceso que genera el codigo de solicitud de token', 
'AUTOR: Antonio Bastidas',
'FECHA: 03/10/2011',
'VERSION: 20111003.1328',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualiza_telefonos()
returning char(30);

    --- V3 Mejoras 20111201 MACF
    --- V2 20100504 Agregar validaciones   
    --- V1 20100218 Crear SP
    
    define cod_ret char(30);
    define sql_err integer;
    define v_numcte char(20);
    define v_tipo_telef char(1);
    define v_telefono char(13);
    define v_tipo_telef1 char(1);
    define v_telefono1 char(13);
    define v_extension char(5);
    define v_numcte1 char(20);
    define v_tipo_telef2 char(1);
    define v_telefono2 char(13);
    define v_tipo_telef3 char(1);
    define v_telefono3 char(13);
    define v_secuencia integer;
    define cMensaje 		CHAR(150);
    DEFINE isam_err 		INTEGER;
    DEFINE error_info		CHAR(150);
        
    define v_tipo_dir_r char(1);
    define v_calle_r char(40);
    define v_colonia_r char(60);
    define v_entre_calles_r char(40);
    define v_pais_r char(3);
    define v_estado_r char(2);
    define v_ciudad_r char(3);
    define v_municipio_r char(5);
    define v_cod_postal_r char(5);
    define v_apart_postal_r char(11);
    define v_tipo_telef1_r char(1);
    define v_telefono1_r char(13);
    define v_tipo_telef2_r char(1);
    define v_telefono2_r  char(13);
    define v_tipo_telef3_r char(1);
    define v_telefono3_r char(13);
    define v_extension_r char(5);
    define v_estado_inegi_r char(2);
    define v_municipio_inegi_r char(3);
    define v_localidad_inegi_r char(4);
    define v_numerociudad_r smallint;
    define v_numeroextcalle_r char(10);
    define v_numerointcalle_r char(10);
    define v_departamento_r char(6);
    define v_numerocalle_r integer;
    define v_numerocolonia_r integer;
    define v_puntocardinal_r char(1);
    define v_unidadhabitac_r  char(1);
    define v_manzana_r smallint;
    define v_otros_r smallint;
    define v_andador_r smallint;
    define v_etapa_r smallint;
    define v_lote_r smallint;
    define v_edificio_r smallint;
    define v_entrada_r smallint;
    define v_observaciones_r char(80);
    define v_user_insert_r char(8);
    define v_fecha_insert_r date;
    define v_max_secuencia integer;

    --SET DEBUG FILE TO "/informix/macf/sp_actualiza_telefonos.out";
    --TRACE ON;
    
    let cod_ret  = '00000';
    let v_numcte = '';
    let v_secuencia = 0;
    let v_max_secuencia = 0;
    LET cMensaje = '';
    LET isam_err	  	 = 0;
    LET error_info = '';
    
    BEGIN

    on exception set sql_err, isam_err, error_info
        if sql_err <> 0 then
            let cod_ret = sql_err;
            LET cMensaje = error_info;
            
            INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
             VALUES('sp_actualiza_telefonos.sql', cod_ret, cMensaje, 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

            
            return cod_ret;
        end if
    end exception;

      INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
      VALUES('sp_actualiza_telefonos.sql', '11111', 'PROCESO INICIALIZADO', 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


    set isolation to dirty read;
    set lock mode to wait 3;

    -- // Domicilio CASA
    foreach
        select numcte, tipo_telef1, telefono1, extension  -- // Primero tipo P (Casa)
          into v_numcte, v_tipo_telef, v_telefono, v_extension
          from bdinteg:si_gestion_telefonica

        if v_tipo_telef IN('P', 'C', 'A') then
            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte)} max(secuencia) 
              into v_secuencia
              from bdinteg:si_direcciones_actual
             where numcte = v_numcte;

            if nvl(v_secuencia,0) = 0 then
                continue foreach;
            end if 

            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                   d.tipo_dir, d.calle, d.colonia, d.entre_calles, 
                   d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, d.tipo_telef1, d.telefono1, 
                   d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, d.estado_inegi, d.municipio_inegi,
                   d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, d.numerocalle,
                   d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                   d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
              into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r,
                   v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,
                   v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, v_estado_inegi_r, v_municipio_inegi_r,
                   v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                   v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
                   v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, 
                   v_fecha_insert_r
              from bdinteg:si_direcciones_actual d
             where d.numcte = v_numcte
               and d.tipo_dir = '1';

            let v_max_secuencia = v_secuencia + 1;
            
            --if (v_telefono is not null or v_telefono <> '') then
            if nvl(v_telefono, '') <> '' then
            
                if v_tipo_telef = 'P' then 
                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 'P', 
                      v_telefono, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                elif v_tipo_telef = 'C' then
                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                      v_telefono1_r, 'C', v_telefono, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                elif v_tipo_telef = 'A' then
                    --if v_telefono1_r is null or v_telefono1_r = '' then
                    if nvl(v_telefono1_r, '') = '' then
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 'P', 
                          v_telefono, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    elif nvl(v_telefono2_r, '') = ''  then
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                          v_telefono1_r, 'P', v_telefono, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    else
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                          v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, 'P', v_telefono, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    end if
                end if
            end if
        elif v_tipo_telef = 'T' then
            --if v_telefono is not null then
            if nvl(v_telefono, '') <> '' then
                select {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte)} 
                       max(secuencia) 
                  into v_secuencia
                  from bdinteg:si_direcciones_actual
                 where numcte = v_numcte;

                select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                       d.tipo_dir, d.calle, d.colonia, d.entre_calles, 
                       d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, d.tipo_telef1, d.telefono1, 
                       d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, d.estado_inegi, d.municipio_inegi,
                       d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, d.numerocalle,
                       d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                       d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
                  into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r,
                       v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,
                       v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, v_estado_inegi_r, v_municipio_inegi_r,
                       v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                       v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
                       v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, 
                       v_fecha_insert_r
                  from bdinteg:si_direcciones_actual d
                 where d.numcte =  v_numcte
                   and d.tipo_dir = '2';

                --if (v_tipo_dir_r is not null and v_pais_r is not null and v_estado_r is not null) then
                if nvl(v_tipo_dir_r,'') <> '' and nvl(v_pais_r,'') <> '' and nvl(v_estado_r, '') <> '' then
                    let v_max_secuencia = v_secuencia + 1;

                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                      v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, 'O', v_telefono, v_extension, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                end if
            end if
        end if
    
    end foreach;
      
    INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
    VALUES('sp_actualiza_telefonos.sql', cod_ret, 'PROCESO FINALIZADO', 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
    
    end

    return cod_ret;
    
END PROCEDURE;