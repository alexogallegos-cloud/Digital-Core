CREATE PROCEDURE "informix".sp_actualizar_catalogos_sepomex(pUsuario CHAR(8))
RETURNING
	CHAR(5) AS Cod_Ret;
---DECLARACIONES
    DEFINE v_cod_ret				CHAR(5);
    DEFINE iSqlErr					INTEGER;
    DEFINE iSamErr					INTEGER;
	DEFINE s_Estado					CHAR(2);
	DEFINE s_Ciudad					CHAR(3);
	DEFINE s_NombreCiudad			VARCHAR(60);
	DEFINE i_CiudadCoppel			INTEGER;
	DEFINE s_Pais					CHAR(3);
	DEFINE i_TipoCiudad				INTEGER;
	DEFINE s_SiglasEstado			CHAR(4);
	DEFINE v_cod_ret2				CHAR(5);
	DEFINE i_numerociudad			INTEGER;
	DEFINE i_numerocolonia			INTEGER;
	DEFINE s_nombrezona				CHAR(60);
	DEFINE s_poblacionzona			CHAR(100);
	DEFINE s_municipiozona			CHAR(50);
	DEFINE i_codigopostalzona		INTEGER;
	DEFINE s_CodigoPostal			CHAR(5);
	DEFINE s_Asenta					CHAR(60);
	DEFINE s_TipoAsenta				CHAR(25);
	DEFINE i_Estado					INTEGER;
	DEFINE s_DescCiudad				CHAR(100);
	DEFINE s_CveCiudad				CHAR(3);
	DEFINE s_mnpio					CHAR(40);
	DEFINE i_CveCiudad              SMALLINT;
	DEFINE vcantReg		            SMALLINT;
	DEFINE v_fecha                  DATE;
	DEFINE cNombreProceso           CHAR(30);
	DEFINE ERROR_INFO               VARCHAR(80);
	DEFINE vMensaje 	            CHAR(80);
	DEFINE c_CadenaAInsertar        CHAR(100);
	
	---INICIALIZACIONES
	LET v_cod_ret 				= "00000";
	LET s_Estado				= "";
	LET s_Ciudad				= "";
	LET s_NombreCiudad			= "";
	LET i_CiudadCoppel			= 0;
	LET s_Pais					= "";
	LET i_TipoCiudad			= 0;
	LET s_SiglasEstado			= "";
	LET v_cod_ret2				= "00000";
	LET i_numerociudad			= 0;
	LET i_numerocolonia			= 0;
	LET s_nombrezona			= "";
	LET s_poblacionzona			= "";
	LET s_municipiozona			= "";
	LET i_codigopostalzona		= 0;
	LET s_CodigoPostal			= "";
	LET s_Asenta				= "";
	LET s_TipoAsenta			= "";
	LET i_Estado				= 0;
	LET s_DescCiudad			= "";
	LET s_CveCiudad				= "";
    LET i_CveCiudad             = 0;
	LET vcantReg                = 0;
	LET v_fecha                 = DATE(1);
	LET cNombreProceso          = 'ACTUALIZAR CATALOGOS SEPOMEX';
	LET ERROR_INFO              = '';
	LET vMensaje                = '';
	LET c_CadenaAInsertar       = '';
	
 --Fecha:	 2010-05-31
 --Modificado: Jesus Manuel Aguilar Heredia
 --Descripcion: se valida que el registro no exista en la tabla si_catciudades previo a la insercion, para evitar duplicados 

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr, ERROR_INFO 
        IF iSqlErr <> 0 THEN
		    LET v_cod_ret = iSqlErr;
			LET vMensaje  = iSamErr || '-' || ERROR_INFO;
			
			INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, 0 ,user, v_fecha,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
			
			RETURN v_cod_ret;
	    END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/macf/sp_actualizar_catalogos_SEPOMEX.out";
	--TRACE ON;
	
	IF NVL(pUsuario,"") = "" THEN
	    LET v_cod_ret = "00001"; -- Es necesario indicar el usuario que actualizara el catÃ¡logo
		 RETURN v_cod_ret;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET s_Pais					= "001";
	LET i_TipoCiudad			= 2;
	
	 select fecha_hoy 
       into v_fecha
       from bdinteg:si_fechas
	  where empresa = '001';
	
	/*LET v_fecha = MDY('07','22','2022');   -- Solo pruebas MACF*/
	
	--- ACTUALIZAR CIUDADES
	-- FOREACH
	FOREACH WITH HOLD
		SELECT estado, ciudad, nombre, ciudad_coppel
		INTO s_Estado, s_Ciudad, s_NombreCiudad, i_CiudadCoppel
		FROM bdinteg:si_catsepomex_ciudades
		WHERE estatus = "CIUDAD NUEVA"
		
		LET s_NombreCiudad = TRIM(s_NombreCiudad);
		
		IF NOT EXISTS(SELECT ciudad FROM si_ciudades WHERE pais = s_Pais AND estado = s_Estado AND ciudad = s_Ciudad AND nombre = s_NombreCiudad 
						AND tipo_ciudad = i_TipoCiudad AND d_ciudad = s_NombreCiudad ) THEN
			
			--- INSERTA LAS NUEVAS CIUDADES EN EL SI_CIUDADES
			  INSERT INTO si_ciudades (pais, estado, ciudad, nombre, localidad_banxico, localidad_inegi, ciudad_coppel, 
						tipo_ciudad, user_insert, fecha_insert, d_ciudad)
			  VALUES(s_Pais, s_Estado, s_Ciudad, s_NombreCiudad, "", "", i_CiudadCoppel, 
						--i_TipoCiudad, USER, TODAY, s_NombreCiudad);
						i_TipoCiudad, pUsuario, v_fecha, s_NombreCiudad);

			
		END IF;
		
		IF NOT EXISTS(SELECT numerociudad FROM si_catciudades WHERE numeroestado = s_Estado AND numerociudad = s_Ciudad AND nombreciudad = s_NombreCiudad 
						AND tipo_ciudad = i_TipoCiudad) THEN
			--- OBTIENE LAS SIGLAS DEL ESTADO
			SELECT siglas
			INTO s_SiglasEstado
			FROM bdinteg:si_estados
			WHERE estado = s_Estado;

			--- INSERTA LAS NUEVAS CIUDADES EN EL SI_CATCIUDADES
			 INSERT INTO si_catciudades (numerociudad, nombreciudad, inicialciudad, tasainteres, numeroestado, inicialestado, 
					salariominimo, gerentezona, regioncobranzas, ivaciudad, antiguedadciudad, unificaciudadesinformes, 
					unificaciudadescobranzas, gerentecobranzas, generajobcarteratienda, inicialcredito, regionestadodecuenta, 
					tasainteresropa, tasainteresmueble12, tasainteresmueble18, tasainteresprestamo, tasainterescelular1, 
					tasainterescelular2, tipozona, fechaultimaactualizacion, tipo_ciudad, numerociudadcoppel, 
					nombreciudadcoppel, numero_region) 
			   VALUES (i_CiudadCoppel, s_NombreCiudad, SUBSTR(s_NombreCiudad,1,4), 0, s_Estado::INTEGER, s_SiglasEstado
					, 0, 0, 0, 0, '', 0, 0, 0, '', '', '', 0, 0, 0, 0, 0, 0, '', '', '', 0, '', 0);
		END IF;
		
	END FOREACH;
	
	--- BORRA LA CIUDADES NUEVAS DEL CATALOGO DE CIUDADES DE SEPOMEX

	  DELETE bdinteg:si_catsepomex_ciudades
	  WHERE estatus = "CIUDAD NUEVA";
	
	--- ACTUALIZAR COLONIAS
	--FOREACH

	FOREACH WITH HOLD
		SELECT numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona
		INTO i_numerociudad, i_numerocolonia, s_nombrezona, s_poblacionzona, s_municipiozona, i_codigopostalzona
		FROM bdinteg:si_catsepomex_colonias
		WHERE estatus = "COLONIA NUEVA"
	    
		LET s_nombrezona = trim(s_nombrezona);
		LET s_poblacionzona = trim(s_poblacionzona);
		LET s_municipiozona = trim(s_municipiozona);

		EXECUTE PROCEDURE grabazonacallexasignar(1, i_numerociudad, i_numerocolonia, s_nombrezona, "", i_codigopostalzona, 
						s_municipiozona, s_poblacionzona,pUsuario)
		INTO v_cod_ret2;
	
	    --- SOLO PRUEBAS MACF
		--LET c_CadenaAInsertar = i_numerociudad || ' - ' || i_numerocolonia || ' - ' || s_nombrezona;
		--    IF v_cod_ret2 <> '000' THEN
		--	   INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        --       VALUES('grabazonacallexasignar', v_cod_ret2, c_CadenaAInsertar , 0 ,user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
		--	END IF;
		--- SOLO PRUEBAS MACF
	
	END FOREACH
	

	--- BORRA LA COLONIAS NUEVAS DEL CATALOGO DE COLONIAS DE SEPOMEX
	  DELETE bdinteg:si_catsepomex_colonias    
	    WHERE estatus = "COLONIA NUEVA";        

	/*  --- COMENTAR BLOQUE, porque al actualizar lo hace tambiÃ©n sobre zonas no correctas- 2002/07/22
	--- ACTUALIZAR CODIGOS POSTALES
	--FOREACH
	FOREACH WITH HOLD
		SELECT d_codigo, d_asenta, c_estado, d_ciudad, d_mnpio
		INTO s_CodigoPostal, s_Asenta, i_Estado, s_DescCiudad, s_mnpio
		FROM bdinteg:si_catsepomex
		WHERE estatus = 3
		
		LET s_Asenta = TRIM(s_Asenta);
		LET s_DescCiudad = TRIM(s_DescCiudad);
		LET s_mnpio = TRIM(s_mnpio);
		
		--- OBTIENE EL NUMERO DE CIUDAD ATRAVES DEL NUMERO DE ESTADO Y NOMBRE DE CIUDAD
		SELECT FIRST 1 ciudad_coppel
		INTO i_CveCiudad
		FROM bdinteg:si_ciudades
		WHERE estado = LPAD(i_Estado,2,"0")
		AND TRIM(d_ciudad ) = TRIM(s_DescCiudad)
		AND elegir is null;
		
		LET vCantReg  = 0;
		--- ACTUALIZA EL CODIGO POSTAL AL DOMICILIO

			UPDATE bdinteg:si_catzonas
			SET codigopostalzona = s_CodigoPostal, f_modifica = v_fecha,
			    --usr_modifica = pUsuario
				usr_modifica = pUsuario, estatus = '3' -- SOLO TEST MACF
				
			WHERE numerociudad = i_CveCiudad        
			--AND nombrezona = s_Asenta
			--AND poblacionzona = s_DescCiudad
			--AND municipiozona = s_mnpio;
			AND nomzona_spmx = s_Asenta        -- RQI 21 232 MACF 20210701
			AND mnpio_spmx = s_mnpio
			AND pobzona_spmx = s_DescCiudad;  

		
	END FOREACH
	
	
	--- LOS DOMICILIOS QUE TIENEN CODIGO POSTAL NUEVO CAMBIAN A ESTATUS 1, QUE ES EXISTENTE DESPUES DE HABER ACTUALIZAO EL CATALOGO DEL BANCO
	UPDATE bdinteg:si_catsepomex
	    SET estatus = 1     
	   WHERE estatus = 3;
	*/
	
	RETURN v_cod_ret;
END

END PROCEDURE
DOCUMENT
"AUTOR: Mohamed CarreÃ³n",
"DESCRIPCION: procedimiento para actualizar ciudades, colonias y codigos postales",
"CrÃ©dito",
"FECHA: Abril  de 2010",
"VERSION:BD: bdinteg.",
"Autor: MACF. Agregar hold al for each. 20190926",
"FECHA: 2021-07-01",
"DESCRIPCION: Se actualiza el upd del CP en si_catzonas para hacerlo en base a los tres nuevos campos(nomzona_spmx,mnpio_spmx,pobzona_spmx)",
"AUTOR: MACF";

CREATE PROCEDURE "informix".sp_marcazonas_baja(p_Usuario   CHAR(8))
RETURNING CHAR(5) AS Cod_Ret;
---------------------------------------------------------------------------------------------------------------------------------
--DECLARACIONES
DEFINE v_cod_ret				CHAR(5);
DEFINE iSqlErr					INTEGER;
DEFINE iSamErr					INTEGER;
DEFINE s_DescCiudad				CHAR(100);
DEFINE p_FechaHoy				DATE;
DEFINE i_CveEstado				INTEGER;
DEFINE i_CiudadCoppel			INTEGER;
DEFINE s_BandExisteSimilar		CHAR(1);
DEFINE i_CveEstadoAnte			INTEGER;

DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE s_MarcaUniHab			CHAR(1);
DEFINE i_NvaColonia				INTEGER;

DEFINE maxColonia               INTEGER;

DEFINE cEmpresa                 CHAR(3);
DEFINE iRegistros               INTEGER;
DEFINE iIdRegistro				INTEGER;

DEFINE cPobZona					CHAR(27);
DEFINE cMunZona					CHAR(27);
DEFINE cNombreZona				CHAR(32);
DEFINE iCodPst					INTEGER;
DEFINE cCiudad					CHAR(100);
DEFINE cMunicipio				CHAR(40);
DEFINE iNumCiudad				INTEGER;
DEFINE cNomCol					CHAR(60);
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje  	            CHAR(80);
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE c_Cve_estado             CHAR(2);
DEFINE c_CodPst                 CHAR(5); 

DEFINE c_nomzona_spmx           CHAR(60);
DEFINE c_pobzona_spmx           CHAR(100);
DEFINE c_mnpio_spmx             CHAR(50);
DEFINE i_d_codigo               INTEGER;
DEFINE i_Result_1               INTEGER;
DEFINE v_fechamax_ejec          DATE;
DEFINE v_fecha_baja             DATE;
DEFINE i_Cont_upd_baja          INTEGER;
DEFINE i_cont_spmx              INTEGER;
DEFINE v_f_inserta              DATE;
DEFINE c_Usuario                CHAR(8);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--INICIALIZACIONES	
LET v_cod_ret				    = "00000";
LET iSqlErr					    = 0;
LET iSamErr					    = 0;
LET s_DescCiudad			    = "";
LET p_FechaHoy				    = DATE(1);
LET i_CveEstado				    = 0;
LET i_CiudadCoppel			    = 0;
LET s_BandExisteSimilar		    = "F";
LET i_CveEstadoAnte			    = 0;
LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET s_MarcaUniHab			    = "";
LET i_NvaColonia			    = 0;
LET maxColonia                  = 0;
LET cEmpresa                    = "001";
LET iRegistros                  = 0;
LET cPobZona					= "";
LET cMunZona					= "";
LET cNombreZona					= "";
LET iCodPst						= 0;
LET cCiudad						= "";
LET cMunicipio					= "";
LET iNumCiudad					= 0;
LET cNomCol						= "";
LET cNombreProceso              = 'MARCA ZONAS BAJA';
LET vMensaje                    = ''; 
LET ERROR_INFO                  = '';
LET c_Cve_estado                = '';
LET c_CodPst                    = '';
LET c_nomzona_spmx              = '';
LET c_pobzona_spmx              = ''; 
LET c_mnpio_spmx                = ''; 
LET i_d_codigo                  = 0;
LET i_Result_1                  = 0;
LET v_fechamax_ejec             = DATE(1);
LET v_fecha_baja                = DATE(1);
LET i_Cont_upd_baja             = 0;
LET i_cont_spmx                 = 0;
LET v_f_inserta                 = DATE(1);
LET c_Usuario                   = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET pdqpriority 20;

BEGIN

ON EXCEPTION SET iSqlErr, iSamErr, ERROR_INFO
    LET v_cod_ret = iSqlErr;
	LET vMensaje  = iSamErr || '-' || ERROR_INFO;
	
	INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, 0 ,user, p_FechaHoy,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
	
    RETURN v_cod_ret;
END EXCEPTION;


 --SET DEBUG FILE TO "/ifxsif01/macf/sp_conciliar_colonias_sepomex.out";
 --TRACE ON;

   LET c_Usuario = p_Usuario;


 --OBTIENE LA FECHA DEL SISTEMA
 SELECT fecha_hoy
   INTO p_FechaHoy
   FROM si_fechas
  WHERE empresa = cEmpresa; 
 
  --LET p_FechaHoy = MDY('07','24','2022');  ---  SOLO TEST MACF
 
   SELECT max(fecha_ejecucion) into v_fechamax_ejec
    FROM bdinteg:si_catsepomex;
 
  LET iNumCiudad = 0;
  LET i_NumColonia = 0;
  LET iRegistros = 0;
  
  FOREACH WITH HOLD
		
			select a.estado, TRIM(a.d_ciudad) INTO c_Cve_estado, s_DescCiudad
			  from bdinteg:si_ciudades a
			       inner join bdinteg:si_catsepomex b on a.d_ciudad = b.d_ciudad and a.estado = b.c_estado
			 where a.ciudad_coppel > 0 
			    and a.elegir is null
			 group by 1,2 order by 1,2
  
            FOREACH WITH HOLD
			
			    SELECT a.numerociudad,  a.numerocolonia, a.nombrezona, a.poblacionzona, a.municipiozona,  TRIM(a.nomzona_spmx), TRIM(a.mnpio_spmx), TRIM(a.pobzona_spmx), a.codigopostalzona, a.f_inserta 
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iCodPst, v_f_inserta
				  FROM bdinteg:si_catzonas a
				                  inner join bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
				   WHERE b.d_ciudad = s_DescCiudad
                     AND b.estado = c_Cve_estado
					 AND NVL(a.nomzona_spmx,'') <> '' AND NVL(a.mnpio_spmx,'') <> '' AND  NVL(a.pobzona_spmx,'') <> ''
  
                LET s_CodigoPostal = lpad(iCodPst,5,'0');
  
          IF c_Cve_estado <> '09' THEN
  
					SELECT count(*) INTO i_cont_spmx
					  FROM bdinteg:si_catsepomex
					 WHERE d_codigo = s_CodigoPostal
					   AND d_asenta = c_nomzona_spmx
					   AND d_ciudad = s_DescCiudad
					   AND d_mnpio = c_mnpio_spmx
					   AND c_estado = c_Cve_estado;

					IF i_cont_spmx <= 0 THEN
					
					   BEGIN;

						 UPDATE bdinteg:si_catzonas
							SET nomzona_spmx = null, mnpio_spmx = null, pobzona_spmx = null, fecha_baja = today, usr_modifica = c_Usuario
						  WHERE	numerociudad = iNumCiudad AND numerocolonia = i_NumColonia; 
						 
					   COMMIT;
								 
					END IF;

					LET i_cont_spmx = 0;
					LET s_CodigoPostal = '';
				ELSE

				   SELECT count(*) INTO i_cont_spmx
					  FROM bdinteg:si_catsepomex
					 WHERE d_codigo = s_CodigoPostal
					   AND d_asenta = c_nomzona_spmx
					   --AND d_ciudad = s_DescCiudad
					   AND d_mnpio = c_mnpio_spmx
					   AND c_estado = c_Cve_estado;

					IF i_cont_spmx <= 0 THEN
					
					   BEGIN;

						 UPDATE bdinteg:si_catzonas
							SET nomzona_spmx = null, mnpio_spmx = null, pobzona_spmx = null, fecha_baja = today, usr_modifica = c_Usuario
						  WHERE	numerociudad = iNumCiudad AND numerocolonia = i_NumColonia; 
						 
					   COMMIT;
								 
					END IF;

					LET i_cont_spmx = 0;
					LET s_CodigoPostal = '';
				
				END IF;
				
			END FOREACH;
  END FOREACH;				   
  
  RETURN v_cod_ret;
END
END PROCEDURE;