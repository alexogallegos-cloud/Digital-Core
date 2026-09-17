CREATE PROCEDURE "informix".sp_conciliar_colonias_sepomex(p_NumEstado INTEGER,
                                                p_Usuario   CHAR(8))
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
DEFINE i_NumColoniasNvas		INTEGER;
DEFINE i_NumColoniasSim			INTEGER;
DEFINE i_CveEstadoAnte			INTEGER;

DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE s_MarcaUniHab			CHAR(1);
DEFINE i_NvaColonia				INTEGER;

DEFINE maxColonia               INTEGER;

DEFINE iCiudadAnte				INTEGER;
DEFINE cEmpresa                 CHAR(3);
DEFINE iNumCol1                 INTEGER;
DEFINE iNumCol2                 INTEGER;
DEFINE cBanCons                 CHAR(1);
DEFINE cEdo1                    CHAR(2);
DEFINE cEdo2                    CHAR(2);
DEFINE cCd1                     CHAR(3);
DEFINE cCd2                     CHAR(3);
DEFINE cPais1                   CHAR(3);
DEFINE cPais2                   CHAR(3);
DEFINE cCod1                    CHAR(5);
DEFINE cCod2                    CHAR(5);
DEFINE cCdCoppel1               INTEGER;
DEFINE cCdCoppel2               INTEGER;
DEFINE iRegistros               INTEGER;
DEFINE parEstado1				SMALLINT;
DEFINE parEstado2				SMALLINT;
DEFINE iIdRegistro				INTEGER;

DEFINE cPobZona					CHAR(27);
DEFINE cMunZona					CHAR(27);
DEFINE cNombreZona				CHAR(60);
DEFINE iCodPst					INTEGER;
DEFINE cCiudad					CHAR(100);
DEFINE cMunicipio				CHAR(40);
DEFINE iNumCiudad				INTEGER;
DEFINE cNomCol					CHAR(60);
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje  	            CHAR(80);
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE s_Municipio_corto        CHAR(27);
DEFINE s_Asenta_corto           CHAR(32);
DEFINE cCiudad_corto            CHAR(27);
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
DEFINE v_fechamax_alta          DATE;  
DEFINE i_Cont_upd_reactiva      INTEGER;
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
LET i_NumColoniasNvas		    = 0;
LET i_NumColoniasSim		    = 0;
LET i_CveEstadoAnte			    = 0;

LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET s_MarcaUniHab			    = "";
LET i_NvaColonia			    = 0;

LET maxColonia                  = 0;

LET iCiudadAnte				    = 0;
LET cEmpresa                    = "001";
LET iNumCol1                    = 0;
LET iNumCol2                    = 999999;
LET cBanCons                    = "";
LET cEdo1                       = "";
LET cEdo2                       = "ZZ";
LET cCd1                        = "";
LET cCd2                        = "ZZZ";
LET cPais1                      = "";
LET cPais2                      = "ZZZ";
LET cCod1                       = "";
LET cCod2                       = "ZZZZZ";
--LET cCdCoppel1                  = 0;
LET cCdCoppel1                  = 1;
LET cCdCoppel2                  = 999999;
LET iRegistros                  = 0;
LET parEstado1					= 0;
LET parEstado2				    = 0;

LET cPobZona					= "";
LET cMunZona					= "";
LET cNombreZona					= "";
LET iCodPst						= 0;
LET cCiudad						= "";
LET cMunicipio					= "";
LET iNumCiudad					= 0;
LET cNomCol						= "";
LET cNombreProceso              = 'CONCILIAR COLS SPMX';
LET vMensaje                    = ''; 
LET ERROR_INFO                  = '';
LET s_Municipio_corto           = '';
LET s_Asenta_corto              = '';
LET cCiudad_corto               = '';
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
LET v_fechamax_alta             = DATE(1);
LET i_Cont_upd_reactiva         = 0;

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



--OBTIENE LA FECHA DEL SISTEMA
SELECT fecha_hoy
  INTO p_FechaHoy
  FROM si_fechas
 WHERE empresa = cEmpresa; 
 
  /*LET p_FechaHoy = MDY('08','14','2022');  ---  SOLO TEST MACF*/
 
--VALIDA QUE EL ESTADO NO ESTE VACIO
IF NVL(p_NumEstado,"") = "" OR NVL(p_Usuario,"") = "" THEN
    RETURN "00001";
END IF;
	
--INICIALIZA LA TABLA DE COLONIAS
-- TRUNCATE bdinteg:si_catsepomex_colonias;

--OPCION DE CONCILIACION POR MEDIO DE UN ESTADO
IF p_NumEstado > 0 THEN
   LET cBanCons = "E";
   LET cEdo1 = LPAD(p_NumEstado,2,"0");
ELSE 
	LET cEdo1 = LPAD(0,2,"0");
   LET cBanCons = "G";
END IF;

LET i_NumColoniasSim  = 0;
LET i_NumColoniasNvas = 0;

--OBTIENE LAS DISTINTAS CIUDADES PERTENECIENTES AL ESTADO DE SEPOMEX
-- PRIMER BLOQUE: PROCESAR LAS DE TAMAÑO DE COLS IGUAL AL DE SI_CAZONAS
FOREACH WITH HOLD
	SELECT estado 
	INTO parEstado1
	FROM si_estados
	WHERE estado = CASE WHEN cEdo1 > 0 THEN cEdo1
          ELSE estado END
	FOREACH WITH HOLD
	      SELECT a.ciudad_coppel ,  b.d_codigo     ,  b.d_tipo_asenta ,  b.d_mnpio    ,  b.d_asenta  ,  b.d_ciudad    ,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_ciudad
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         AND b.c_estado = a.estado
	         AND b.estatus  = 2
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
			 AND a.elegir is null
			 AND b.fecha_baja is null
	         ORDER BY a.ciudad_coppel
	        --ORDER BY b.c_estado, b.d_ciudad


	        LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
			--LET s_Asenta     = TRIM(substr(s_Asenta,1,32));  -- Agregado MACF 20210124 test
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
	        LET c_Cve_estado  = LPAD(c_Cve_estado,2,"0");
			LET i_d_codigo = s_CodigoPostal::INTEGER;                --- MACF 2022-06-29
			--LET s_CodigoPostal = s_CodigoPostal::INTEGER;
			LET s_Municipio = TRIM(s_Municipio);  --- Agregado MACF 20210124 test
			
		--IF LENGTH(trim(s_Asenta)) <= 30 AND  LENGTH(trim(s_Municipio)) <= 27 AND LENGTH(TRIM(s_DescCiudad)) <=27 THEN
		--- Ya no importaría el tamaño de la colonia
		

	        				
	        --BUSCA LA COLONIA EN EL CATALOGO Y OBTIENE EL NUMERO DE COLONIA EN CASO AFIRMATIVO
	         /*  SELECT FIRST 1 numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, ROWID 
	             INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, iCodPst, iIdRegistro
	             FROM bdinteg:si_catzonas
	            WHERE numerociudad  = i_CiudadCoppel 
	              AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
	              AND municipiozona = s_Municipio_corto
	              AND nombrezona    = s_Asenta
				  --AND codigopostalzona = s_CodigoPostal; -- Es mejor que no busque con este filtro pq puede ser diferente el CP
				  AND poblacionzona = s_DescCiudad;  -- Probar que también filtre por este campo, pq puede existir pero con poblacionzona incorrecta
             */
			 
			--NUEVA FORMA DE BUSCAR LA COLONIA
			    SELECT FIRST 1 numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, 
				       nomzona_spmx, mnpio_spmx, pobzona_spmx, ROWID
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, iCodPst,
				       c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iIdRegistro 
				  FROM bdinteg:si_catzonas
				  WHERE numerociudad  = i_CiudadCoppel 
	                AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
					AND codigopostalzona = i_d_codigo           --- MACF 2022-06-29
	                AND mnpio_spmx = s_Municipio
	                AND nomzona_spmx = s_Asenta
					AND pobzona_spmx = s_DescCiudad;
					
				LET c_nomzona_spmx = TRIM(c_nomzona_spmx);
				LET c_mnpio_spmx = TRIM(c_mnpio_spmx);
				LET c_pobzona_spmx = TRIM(c_pobzona_spmx);
				  
	        --OBTIENE LA MARCA DE UNIDAD HABITACIONAL, LE PONE "S" CUANDO ES UNIDAD O CUNJUNTO HABITACIONAL EN CASO CONTRARIO DE PONE "N"
			     LET s_MarcaUniHab = DECODE(s_TipoAsenta,"UNIDAD HABITACIONAL","S","CONJUNTO HABITACIONAL","S","N");
				 LET cNombreZona = TRIM(cNombreZona);
				 
	            --IF NVL(i_NumColonia,0) <> 0 THEN 
				--IF NVL(cPobZona,'') <> '' AND  NVL(cMunZona,'') <> '' AND  NVL(cNombreZona,'') <> '' THEN 
				IF NVL(cPobZona,'') = '' AND  NVL(cMunZona,'') = '' AND  NVL(cNombreZona,'') = '' THEN 
				    
                    -- Corregir en lugar de buscarla también por el CP agregar el filtro por estado -- Cambio
					-- Buscar también con CP
					-- OMITIR ESTA BUSQUEDA REPETIDA PROB. INECESARIA
					/*SELECT FIRST 1 d_ciudad, d_mnpio, d_asenta, d_codigo
					INTO cCiudad, cMunicipio, cNomCol, s_CodigoPostal
					FROM bdinteg:si_catsepomex 
					--WHERE d_codigo = iCodPst AND d_asenta = cNombreZona AND d_ciudad = s_DescCiudad AND d_mnpio = s_Municipio;
					WHERE d_asenta = s_Asenta AND d_ciudad = s_DescCiudad AND d_mnpio = s_Municipio AND c_estado = c_Cve_estado
                      AND d_codigo = s_CodigoPostal;*/
				
				    /*LET s_CodigoPostal = s_CodigoPostal::INTEGER;*/
				

					/*LET cCiudad_corto = TRIM(substr(cCiudad,1,27));*/

										
					/*LET s_Municipio_corto =  TRIM(substr(cMunicipio,1,27));*/
					

					  /*IF (iCodPst <> i_d_codigo) THEN*/
					   
					   /*UPDATE bdinteg:si_catzonas 
						  SET poblacionzona = cCiudad, municipiozona = cMunicipio, codigopostalzona = s_CodigoPostal,
						      f_modifica = p_FechaHoy, usr_modifica = p_Usuario
						WHERE numerociudad = iNumCiudad
						  AND numerocolonia = i_NumColonia
						   --AND nombrezona =  TRIM(cNomCol)
						  AND nomzona_spmx =  c_nomzona_spmx
						  AND ROWID = iIdRegistro; */
						  
						/*UPDATE bdinteg:si_catzonas 
						   SET codigopostalzona = s_CodigoPostal, f_modifica = p_FechaHoy, usr_modifica = p_Usuario
					     WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia AND ROWID = iIdRegistro;*/	
					 
					  /*END IF;*/
					  
					/*ELSE

					   UPDATE bdinteg:si_catzonas 
						  SET nomzona_spmx = cNomCol, mnpio_spmx = cMunicipio, pobzona_spmx = cCiudad, f_modifica = p_FechaHoy
						WHERE numerociudad = iNumCiudad
						  AND numerocolonia = i_NumColonia
						   --AND nombrezona =  TRIM(cNomCol)
						  AND nombrezona =  cNomCol
						  AND ROWID = iIdRegistro;*/

					--END IF;
					
	            --INSERTA COLONIA EXISTENTE
                    
						/*INSERT INTO bdinteg:si_catsepomex_colonias (fecha_ejecucion, numerociudad, numerocolonia, nombrezona, poblacionzona,
																	  municipiozona, codigopostalzona, marcaunidadhabitacional, user_insert,
																	   fecha_insert, estatus) 
							 VALUES (p_FechaHoy, i_CiudadCoppel, i_NumColonia, s_Asenta,s_DescCiudad,
									 s_Municipio, s_CodigoPostal, s_MarcaUniHab, p_Usuario,
									 p_FechaHoy,"COLONIA EXISTENTE");*/
                    
	            /*ELSE*/
							SELECT MAX(numerocolonia)
							  INTO maxColonia                                                                                         
							  FROM bdinteg:si_catzonas
							 WHERE numerociudad  = i_CiudadCoppel
							   AND numerocolonia BETWEEN iNumCol1 AND iNumCol2;
							
							IF iCiudadAnte = i_CiudadCoppel  THEN
							   let i_NvaColonia = i_NvaColonia + 1;
							else
							   --let i_NvaColonia = maxColonia + 1; 
							   let i_NvaColonia = NVL(maxColonia,0) + 1;   --MODIFICAR MACF 20210201
							end if;
					
					        LET iCiudadAnte = i_CiudadCoppel;
							
							--begin;
								INSERT INTO bdinteg:si_catsepomex_colonias (fecha_ejecucion, numerociudad, numerocolonia, nombrezona, poblacionzona,
																			   municipiozona, codigopostalzona, marcaunidadhabitacional, user_insert,
																			   fecha_insert, estatus) 
									 VALUES (p_FechaHoy, i_CiudadCoppel, i_NvaColonia, s_Asenta,s_DescCiudad,
											 s_Municipio, s_CodigoPostal, s_MarcaUniHab, p_Usuario,
											 p_FechaHoy,"COLONIA NUEVA");
                            --commit;
							--LET i_Result_1 = DBINFO("sqlca.sqlerrd2");
							
	                        LET i_NumColoniasNvas = i_NumColoniasNvas + 1;
							
							
	            END IF;
       
	
	        LET s_DescCiudad 		 = "";

					LET i_CiudadCoppel		 = 0;
					LET s_CodigoPostal 		 = "";
					LET s_TipoAsenta 		 = "";
					LET s_Municipio			 = "";
					LET s_Asenta 			 = "";
					LET i_NumColonia 		 = 0;

					LET s_MarcaUniHab        = "";


					LET i_d_codigo           = 0;
					
					
	END FOREACH;

LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00002";
END IF;

--AGREGA A LA BITACORA EL NUMERO DE CIUDADES SIMILARES DEL ESTADO ANTERIOR
    --INSERT INTO si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert)
         --VALUES ("CONCILIACION COLONIAS", "COLONIA SIMILAR", i_NumColoniasSim, i_CveEstadoAnte, p_Usuario, p_FechaHoy);
	--	 VALUES ("CONCILIACION COLONIAS", "COLONIA SIMILAR", i_NumColoniasSim, cEdo1, p_Usuario, p_FechaHoy);
--AGREGA A LA BITACORA EL NUMERO DE CIUDADES NUEVAS AL ESTADO ANTERIOR
    IF i_NumColoniasNvas > 0 THEN
    INSERT INTO si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert) 
         --VALUES ("CONCILIACION COLONIAS", "COLONIA NUEVA", i_NumColoniasNvas, i_CveEstadoAnte, p_Usuario, p_FechaHoy);		
		 VALUES ("CONCILIACION COLONIAS", "COLONIA NUEVA", i_NumColoniasNvas, cEdo1, p_Usuario, p_FechaHoy);		
    END IF;

 --->>  AGREGAR EN OTRO FOREACH LO QUE PUSE EN EL sp_conciliar_colonias_sepomex_09Dif_cdmx  PARA LAS ALCALDÍAS DE LA CDMX, YA QUE EN EL PRINCIPAL Y PRIMER FOREACH
 --->>  NO SE MATCHEAN LAS CIUDADES-ALCALDÍAS CON LA D_CIUDA DE SPMX PQ EN ESA TBL SOLO EXISTE LA D_CIUDAD: CIUDAD DE MEXICO
 LET i_NumColoniasNvas = 0;
 
 IF cEdo1 = '09' THEN
   
	LET parEstado1 = cEdo1;
	
	FOREACH WITH HOLD
	      SELECT a.ciudad_coppel ,  b.d_codigo     ,  b.d_tipo_asenta ,  b.d_mnpio    ,  b.d_asenta  ,  b.d_ciudad    ,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_mnpio
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         --AND b.d_ciudad = a.d_ciudad    -- comentado solo para procesar las alcaldías de CDMX
	         AND b.c_estado = a.estado
	         AND b.estatus  = 2
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
			 AND a.elegir is null
			 AND a.ciudad_coppel <> 6564
			 AND b.fecha_baja is null
	         ORDER BY a.ciudad_coppel
	        --ORDER BY b.c_estado, b.d_ciudad


	        LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
			--LET s_Asenta     = TRIM(substr(s_Asenta,1,32));  -- Agregado MACF 20210124 test
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
	        --LET c_Cve_estado  = LPAD(c_Cve_estado,2,"0");
			LET i_d_codigo = s_CodigoPostal::INTEGER;                --- MACF 2022-06-29
			--LET s_CodigoPostal = s_CodigoPostal::INTEGER;   
			LET s_Municipio = TRIM(s_Municipio);  --- Agregado MACF 20210124 test
		


			--NUEVA FORMA DE BUSCAR LA COLONIA
			    SELECT FIRST 1 numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, 
				       nomzona_spmx, mnpio_spmx, pobzona_spmx, ROWID
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, iCodPst,
				       c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iIdRegistro 
				  FROM bdinteg:si_catzonas
				  WHERE numerociudad  = i_CiudadCoppel 
	                AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
					AND codigopostalzona = i_d_codigo          --- MACF 2022-06-29
	                AND mnpio_spmx = s_Municipio
	                AND nomzona_spmx = s_Asenta;
					--AND pobzona_spmx = s_DescCiudad	 -- Para las alcaldías CDMX no se toma poblacionzona  
			
			  LET c_nomzona_spmx = TRIM(c_nomzona_spmx);
				LET c_mnpio_spmx = TRIM(c_mnpio_spmx);
				LET c_pobzona_spmx = TRIM(c_pobzona_spmx);
				  
	        --OBTIENE LA MARCA DE UNIDAD HABITACIONAL, LE PONE "S" CUANDO ES UNIDAD O CUNJUNTO HABITACIONAL EN CASO CONTRARIO DE PONE "N"
			   LET s_MarcaUniHab = DECODE(s_TipoAsenta,"UNIDAD HABITACIONAL","S","CONJUNTO HABITACIONAL","S","N");
				 LET cNombreZona = TRIM(cNombreZona);
				 
				 LET s_CodigoPostal = s_CodigoPostal::INTEGER;
				 
	            --IF NVL(i_NumColonia,0) <> 0 THEN 

				--IF NVL(cPobZona,'') <> '' AND  NVL(cMunZona,'') <> '' AND  NVL(cNombreZona,'') <> '' THEN 
				IF NVL(cPobZona,'') = '' AND  NVL(cMunZona,'') = '' AND  NVL(cNombreZona,'') = '' THEN 
				    
                    -- OMITIR ESTA BUSQUEDA REPETIDA PROB. INECESARIA
					-- Corregir en lugar de buscarla también por el CP agregar el filtro por estado 					
					/*SELECT FIRST 1 d_ciudad, d_mnpio, d_asenta
					INTO cCiudad, cMunicipio, cNomCol
					FROM bdinteg:si_catsepomex 
					--WHERE d_codigo = iCodPst AND d_asenta = cNombreZona AND d_ciudad = s_DescCiudad AND d_mnpio = s_Municipio;
					--WHERE d_asenta = s_Asenta AND d_ciudad = s_DescCiudad AND d_mnpio = s_Municipio AND c_estado = c_Cve_estado;
					WHERE d_asenta = s_Asenta AND d_mnpio = s_Municipio AND c_estado = c_Cve_estado
					  AND d_codigo = s_CodigoPostal;
				    */
					


					
					---HACER UN SOLO UPD
					--IF (NVL(cPobZona,'') = '' OR TRIM(cPobZona) <> TRIM(cCiudad_corto)) OR ( NVL(cMunZona,'') = '' OR TRIM(cMunZona) <> TRIM(s_Municipio_corto) ) 
					--IF NVL(cPobZona,'') = '' OR ( NVL(cMunZona,'') = '' OR TRIM(cMunZona) <> TRIM(s_Municipio_corto) ) 
					--IF NVL(cPobZona,'') <> '' AND  NVL(cMunZona,'') <> '' AND  NVL(cNombreZona,'') <> '' THEN    --- MACF 2022-06-29
					
					 /*  IF (iCodPst <> i_d_codigo) THEN*/
					   
					   /*UPDATE bdinteg:si_catzonas 
						  SET poblacionzona = s_Municipio_corto, municipiozona = s_Municipio_corto, codigopostalzona = s_CodigoPostal,
						      nomzona_spmx = cNomCol, mnpio_spmx = cMunicipio, pobzona_spmx = cMunicipio, f_modifica = p_FechaHoy,
							  usr_modifica = p_Usuario
						WHERE numerociudad = iNumCiudad
						  AND numerocolonia = i_NumColonia
						  --AND nombrezona =  cNomCol
						  AND nomzona_spmx =  c_nomzona_spmx
						  AND ROWID = iIdRegistro;*/
					   
						/*   UPDATE bdinteg:si_catzonas 
							  SET codigopostalzona = s_CodigoPostal, f_modifica = p_FechaHoy, usr_modifica = p_Usuario
							WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia AND ROWID = iIdRegistro;	*/
					   
					   /*END IF;*/
					--END IF;
					
	            --INSERTA COLONIA EXISTENTE
						/*INSERT INTO bdinteg:si_catsepomex_colonias (fecha_ejecucion, numerociudad, numerocolonia, nombrezona, poblacionzona,
																	  municipiozona, codigopostalzona, marcaunidadhabitacional, user_insert,
																	   fecha_insert, estatus) 
							 VALUES (p_FechaHoy, i_CiudadCoppel, i_NumColonia, s_Asenta,s_Municipio,
									 s_Municipio, s_CodigoPostal, s_MarcaUniHab, p_Usuario,
									 p_FechaHoy,"COLONIA EXISTENTE");*/
	            /*ELSE*/
							SELECT MAX(numerocolonia)
							  INTO maxColonia                                                                                         
							  FROM bdinteg:si_catzonas
							 WHERE numerociudad  = i_CiudadCoppel
							   AND numerocolonia BETWEEN iNumCol1 AND iNumCol2;
							
							IF iCiudadAnte = i_CiudadCoppel  THEN
							   let i_NvaColonia = i_NvaColonia + 1;
							else
							   --let i_NvaColonia = maxColonia + 1; 
							   let i_NvaColonia = NVL(maxColonia,0) + 1;   --MODIFICAR MACF 20210201
							end if;
					
					        LET iCiudadAnte = i_CiudadCoppel;
							
								INSERT INTO bdinteg:si_catsepomex_colonias (fecha_ejecucion, numerociudad, numerocolonia, nombrezona, poblacionzona,
																			   municipiozona, codigopostalzona, marcaunidadhabitacional, user_insert,
																			   fecha_insert, estatus) 
									 --VALUES (p_FechaHoy, i_CiudadCoppel, i_NvaColonia, s_Asenta,s_DescCiudad,
									 VALUES (p_FechaHoy, i_CiudadCoppel, i_NvaColonia, s_Asenta,s_Municipio,
											 s_Municipio, s_CodigoPostal, s_MarcaUniHab, p_Usuario,
											 p_FechaHoy,"COLONIA NUEVA");

	                        LET i_NumColoniasNvas = i_NumColoniasNvas + 1;
	            END IF;
		
		        LET s_DescCiudad 		 = "";
				LET i_CveEstado 		 = 0;
				LET i_CiudadCoppel		 = 0;
				LET s_CodigoPostal 		 = "";
				LET s_TipoAsenta 		 = "";
				LET s_Municipio			 = "";
				LET s_Asenta 			 = "";
				LET i_NumColonia 		 = 0;

				LET s_MarcaUniHab        = "";


		 
    END FOREACH;		
 END IF;	
 
 LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00002";
END IF;

--AGREGA A LA BITACORA EL NUMERO DE CIUDADES NUEVAS AL ESTADO ANTERIOR
    IF i_NumColoniasNvas > 0 THEN
    INSERT INTO si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert) 
         --VALUES ("CONCILIACION COLONIAS", "COLONIA NUEVA", i_NumColoniasNvas, i_CveEstadoAnte, p_Usuario, p_FechaHoy);		
		 VALUES ("CONCILIACION COLONIAS", "COLONIA NUEVA", i_NumColoniasNvas, cEdo1, p_Usuario, p_FechaHoy);		
    END IF;
 
  SELECT max(fecha_ejecucion) into v_fechamax_ejec
    FROM bdinteg:si_catsepomex;
 
  LET iNumCiudad = 0;
  LET i_NumColonia = 0;
  LET iRegistros = 0;
 
 --- MARCAR COMO BAJA LAS ZONAS QUE SE MARCARON ASÍ EN si_catsepomex 
 FOREACH WITH HOLD
     SELECT d_codigo, d_asenta, d_tipo_asenta, d_mnpio, d_ciudad, c_estado, fecha_baja
	   INTO s_CodigoPostal, s_Asenta, s_TipoAsenta, s_Municipio, s_DescCiudad, c_Cve_estado , v_fecha_baja
	  FROM bdinteg:si_catsepomex
	  WHERE c_estado = cEdo1
	    AND fecha_baja >= v_fechamax_ejec
	  
	  IF cEdo1 <> '09' THEN
	  
		  SELECT NVL(a.numerociudad,0), NVL(a.numerocolonia,0) 
			INTO iNumCiudad, i_NumColonia
			FROM bdinteg:si_catzonas a 
			         inner join bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
					            and b.estado = cEdo1
		   WHERE a.codigopostalzona = s_CodigoPostal
			 AND a.nomzona_spmx = s_Asenta
			 AND a.mnpio_spmx = s_Municipio
			 AND a.pobzona_spmx= s_DescCiudad;

			IF iNumCiudad <> 0 AND i_NumColonia <> 0 THEN

			   UPDATE bdinteg:si_catzonas 
				  SET f_modifica = v_fecha_baja, fecha_baja = v_fecha_baja, nomzona_spmx = NULL, mnpio_spmx = NULL, pobzona_spmx = NULL, usr_modifica = p_Usuario
				 WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia;		   
				
			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros > 0 THEN
				  LET i_Cont_upd_baja = i_Cont_upd_baja+1;
			   END IF;
			   
			   LET iRegistros = 0;
				
			END IF;		
	  ELSE
	  
	       --- CIUDAD DE MEXICO
		   SELECT NVL(a.numerociudad,0), NVL(a.numerocolonia,0) 
			INTO iNumCiudad, i_NumColonia
			FROM bdinteg:si_catzonas a 
			         inner join bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
					            and b.estado = cEdo1
		   WHERE a.codigopostalzona = s_CodigoPostal
			 AND a.nomzona_spmx = s_Asenta
			 AND a.mnpio_spmx = s_Municipio
			 AND a.pobzona_spmx= s_DescCiudad
			 AND a.numerociudad = 6564;

			IF iNumCiudad <> 0 AND i_NumColonia <> 0 THEN

			   UPDATE bdinteg:si_catzonas 
				  SET f_modifica = v_fecha_baja, fecha_baja = v_fecha_baja, nomzona_spmx = NULL, mnpio_spmx = NULL, pobzona_spmx = NULL, usr_modifica = p_Usuario
				 WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia;		   
				
			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros > 0 THEN
				  LET i_Cont_upd_baja = i_Cont_upd_baja+1;
			   END IF;
			   
			   LET iRegistros = 0;
			   
			END IF;	 
	        
			---- ALCALDIAS
			SELECT NVL(a.numerociudad,0), NVL(a.numerocolonia,0) 
			INTO iNumCiudad, i_NumColonia
			FROM bdinteg:si_catzonas a 
			         inner join bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
					            and b.estado = cEdo1
		   WHERE a.codigopostalzona = s_CodigoPostal
			 AND a.nomzona_spmx = s_Asenta
			 AND a.mnpio_spmx = s_Municipio
			 --AND a.pobzona_spmx= s_DescCiudad;
			 AND a.numerociudad <> 6564;

			IF iNumCiudad <> 0 AND i_NumColonia <> 0 THEN

			   UPDATE bdinteg:si_catzonas 
				  SET f_modifica = v_fecha_baja, fecha_baja = v_fecha_baja, nomzona_spmx = NULL, mnpio_spmx = NULL, pobzona_spmx = NULL, usr_modifica = p_Usuario
				 WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia;		   
				
			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros > 0 THEN
				  LET i_Cont_upd_baja = i_Cont_upd_baja+1;
			   END IF;
			   
			   LET iRegistros = 0;
			END IF;
	  END IF;
   END FOREACH;
	
  
   IF i_Cont_upd_baja > 0 THEN
      INSERT INTO si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert) 
       	 VALUES ("CONCILIACION COLONIAS", "COLONIA BAJA", i_Cont_upd_baja, cEdo1, p_Usuario, p_FechaHoy);		
   END IF;
	 
	 
	 SELECT max(fecha_alta) into v_fechamax_alta
     FROM bdinteg:si_catsepomex;
	 
	LET i_CiudadCoppel = 0; LET s_CodigoPostal = '';  LET s_TipoAsenta = ''; LET s_Municipio = '';  LET s_Asenta = ''; LET s_DescCiudad = ''; LET c_Cve_estado = ''; LET i_d_codigo = 0;
	
    -- REACTIVAR LAS ZONAS QUE ANTERIORMENTE SE MARCARON COMO BAJA  01/09/2022 MACF
	FOREACH WITH HOLD
	      SELECT a.ciudad_coppel, b.d_codigo, b.d_tipo_asenta, b.d_mnpio, b.d_asenta, b.d_ciudad, b.c_estado
	        INTO i_CiudadCoppel, s_CodigoPostal, s_TipoAsenta, s_Municipio, s_Asenta, s_DescCiudad,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1 AND cCd2
	         AND a.estado   BETWEEN parEstado1 AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         --AND a.d_ciudad = b.d_mnpio
	         AND b.d_codigo BETWEEN cCod1 AND cCod2
	         AND b.d_ciudad = a.d_ciudad    -- Se incluyen las de CDMX
	         AND b.c_estado = a.estado
	         AND b.estatus  = 5
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
			 AND a.elegir is null
			 AND b.fecha_alta >= v_fechamax_alta
	         ORDER BY a.ciudad_coppel
 
         LET i_d_codigo = s_CodigoPostal::INTEGER;

		 SELECT a.numerociudad, a.numerocolonia, --, a.nombrezona, a.poblacionzona, a.municipiozona, a.codigopostalzona, 
					   a.ROWID
		  INTO iNumCiudad, i_NumColonia, --, cNombreZona, cPobZona, cMunZona, iCodPst,
			   iIdRegistro 
		  FROM bdinteg:si_catzonas a
			   INNER JOIN bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
					and b.estado = c_Cve_estado
		  WHERE a.numerociudad  = i_CiudadCoppel 
			AND a.numerocolonia BETWEEN iNumCol1 AND iNumCol2
			AND a.codigopostalzona = i_d_codigo
			AND a.nombrezona = SUBSTR(s_Asenta,1,32)
			AND a.poblacionzona = SUBSTR(s_DescCiudad,1,27)	
			AND a.municipiozona = SUBSTR(s_Municipio,1,27)
			AND nvl(a.fecha_baja,'') <> ''
			AND a.usr_modifica = 'syscobra';


			IF iNumCiudad <> 0 AND i_NumColonia <> 0 THEN

			   UPDATE bdinteg:si_catzonas 
				  SET f_inserta = p_FechaHoy, nomzona_spmx = s_Asenta, mnpio_spmx = s_Municipio, pobzona_spmx = s_DescCiudad, usr_modifica = p_Usuario, fecha_baja = null
				 WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia AND ROWID = iIdRegistro;		   
				
			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros > 0 THEN
				  LET i_Cont_upd_reactiva = i_Cont_upd_reactiva+1;
			   END IF;
			   
			   LET iRegistros = 0;
			END IF;	
		
	END FOREACH;	
		
	

	--PARA REACTIVAR SOLO LAS ALCALDÍAS 
	IF cEdo1 = '09' THEN
	   FOREACH WITH HOLD
	      SELECT a.ciudad_coppel, b.d_codigo, b.d_tipo_asenta, b.d_mnpio, b.d_asenta, b.d_ciudad, b.c_estado
	        INTO i_CiudadCoppel, s_CodigoPostal, s_TipoAsenta, s_Municipio, s_Asenta, s_DescCiudad,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1 AND cCd2
	         AND a.estado   BETWEEN parEstado1 AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_mnpio       -- Se incluyen las alcaldías
	         AND b.d_codigo BETWEEN cCod1 AND cCod2
	         --AND b.d_ciudad = a.d_ciudad    -- Se excluye CDMX
	         AND b.c_estado = a.estado
	         AND b.estatus  = 5
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
			 AND a.elegir is null
			 AND a.ciudad_coppel <> 6564
			 --AND b.fecha_baja is null
			 AND b.fecha_alta >= v_fechamax_alta
	         ORDER BY a.ciudad_coppel
	
			LET i_d_codigo = s_CodigoPostal::INTEGER;
	
	         SELECT a.numerociudad, a.numerocolonia, --, a.nombrezona, a.poblacionzona, a.municipiozona, a.codigopostalzona, 
					   a.ROWID
			  INTO iNumCiudad, i_NumColonia, --, cNombreZona, cPobZona, cMunZona, iCodPst,
				   iIdRegistro 
			  FROM bdinteg:si_catzonas a
				   INNER JOIN bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
						and b.estado = c_Cve_estado
			  WHERE a.numerociudad  = i_CiudadCoppel 
				AND a.numerocolonia BETWEEN iNumCol1 AND iNumCol2
				AND a.codigopostalzona = i_d_codigo
				AND a.nombrezona = SUBSTR(s_Asenta,1,32)
				--AND poblacionzona = SUBSTR(s_DescCiudad,1,27)
				AND a.municipiozona = SUBSTR(s_Municipio,1,27)
				AND nvl(a.fecha_baja,'') <> ''
				AND a.usr_modifica = 'syscobra';
				
			IF iNumCiudad <> 0 AND i_NumColonia <> 0 THEN

			   UPDATE bdinteg:si_catzonas 
				  SET f_inserta = p_FechaHoy, nomzona_spmx = s_Asenta, mnpio_spmx = s_Municipio, pobzona_spmx = s_DescCiudad, usr_modifica = p_Usuario, fecha_baja = null
				 WHERE numerociudad = iNumCiudad AND numerocolonia = i_NumColonia AND ROWID = iIdRegistro;		   
				
			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros > 0 THEN
				  LET i_Cont_upd_reactiva = i_Cont_upd_reactiva+1;
			   END IF;
			   
			   LET iRegistros = 0;
			END IF;		
				
	
	    END FOREACH;
	
	END IF;
	
	IF i_Cont_upd_reactiva > 0 THEN
       INSERT INTO bdinteg:si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert) 
       	 VALUES ("CONCILIACION COLONIAS", "COLONIA REACTIVACION", i_Cont_upd_reactiva, cEdo1, p_Usuario, p_FechaHoy);		
    END IF;
	 
END FOREACH;	 
	 
    RETURN v_cod_ret;
END
END PROCEDURE

DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: MttoSepomexConciliacion',
'Solicito: Paul Ivan Quintero',
'Descripcion: Se modifica para optimizar el proceso, obteniendo una consulta inicial por estados y que en las inserciones',
'no se contemplen funciones en la información a registrar.',
'Fecha: 21/06/2010',
'Version: 201000705.1009',
'BD: bdinteg',

'Modifico: Adrian Lara',
'Proyecto: MttoSepomexConciliacion',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Se agrego las validaciones para poblacionzona y municipiozona del catalago de zonas que verifica que no sean nulas',
'o sean correspondientes al campo d_ciudad y d_mnpio del catalago de sepomex, en caso de no cumplirce esta validacion',
'se debe actualizar los dos campos del catalago de zonas con respecto a los dos del catalago de sepomex. Esto solo aplica',
'cuando la colonia exista dentro del catalago de zonas.',
'Fecha: 20/07/2010',
'Version: 20100721.1859',
'BD: bdinteg',

'Modifico: MACF',
'Descripcion: Modificar validación de colonias. Cambiar inicialización de variable cCdCoppel1.',
'Version: 20190926.1300',
'Modifico: MACF',
'Descripcion: Agregar el filtro de CP en la consulta a si_catzonas para validar si existe la colonia.',
'Fecha: 2022-06-29',
'Descripcion: Reactivar colonias anteriormente dadas de baja.',
'Fecha: 01/09/2022 (MACF)';

CREATE PROCEDURE "informix".sp_consultarclientebpi2(pTipo CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20), pCveOperacion CHAR (12),pSucursal CHAR(5),pIdusuario CHAR(10),pIpusu CHAR(16))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(10), -- Fecha Registro
	CHAR(10), -- Fecha Nacimiento
    CHAR(20), -- Numero de Cliente
    CHAR(26), -- Apellido Paterno
    CHAR(26), -- Apellido Materno
    CHAR(26), -- Nombre1
    CHAR(26), -- Nombre2
    CHAR(4),  -- Id Status
    CHAR(5), -- suc Registro
	CHAR(40), -- Nom Suc
    CHAR(12), -- Folio Contrato
    CHAR(250), -- DescriciÃÂ³n ValidaciÃÂ³n
    SMALLINT, --Tipo Servicio
    CHAR(6),  --Status token
	char(15), --Num Sol Token
	money(16,2), --Costo Token
	CHAR(100),--correo
	CHAR(13);
	

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE vCodRet      CHAR(5);
    DEFINE vFechaReg    CHAR(10);
	DEFINE vFechaNac    CHAR(10);
    DEFINE vNumCte      CHAR(20);
    DEFINE vApePat      CHAR(26);
    DEFINE vApeMat      CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vStatus      SMALLINT;
    DEFINE vSucReg      CHAR(5);
	DEFINE vSucNom      CHAR(40);
    DEFINE vMensValid   CHAR(250);
    DEFINE vTipoPersona CHAR(2);
    DEFINE vFolio       CHAR(55);
    DEFINE vF_status    DATE;
    DEFINE vF_registro  DATE;
    DEFINE vFecha_Hoy  DATE;
    DEFINE vTipoServicio SMALLINT;
    DEFINE vStatusToken CHAR(6);
    DEFINE vIdStatusAnterior SMALLINT;
	DEFINE vSolicitud CHAR(15);
	
	--Variables de Retorno del Stored sp_cons_detenvios_token2	
	DEFINE vFolioSuc char(16);
	DEFINE vCuenta char(20); 
	DEFINE vFecha date;
	DEFINE vSucursal char(4); 
	DEFINE vCargoTot money(16,2);
	DEFINE vCorreo char(100);
	DEFINE vCelular char(13);
	
	DEFINE cod_ret char(5);
	DEFINE vcCondDesEnc char(55);
	DEFINE vFolioEnc char(55);
	

    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET vCodRet =   '000';
    LET vFechaReg = '01/01/1900';
	LET vFechaNac = '01/01/1900';
    LET vNumCte =   '';
    LET vApePat =   '';
    LET vApeMat =   '';
    LET vNombre1 =  '';
    LET vNombre2 =  '';
    LET vStatus = 0;
    LET vSucReg = '';
	LET vSucNom = '';
    LET vMensValid = '';
    LET vTipoPersona = '';
    LET vFolio = '';
    LET vF_status  =  '01/01/1900';
    LET vF_registro = '01/01/1900';
    LET vTipoServicio = 0;
    LET vStatusToken = '';
    LET vIdStatusAnterior = 0;
	LET vSolicitud= '';
	LET vFolioSuc= '';
	LET vCuenta= '';
	LET vFecha= '';
	LET vSucursal= '';
	LET vCargoTot = 0;
	LET vCorreo = '';
	LET vCelular= '';
	
	LET cod_ret= '';
	LET vcCondDesEnc= '';
    LET vFolioEnc = '';


	--**************************************************************
	-- Creado por: Manuel Osuna Valencia 
	-- Fecha: 2010-09-03                                
	-- Solicito: Ismael Hernandez
	-- Stored de Consulta de Cliente y Registro de Bitacora para la
	-- ReimpresiÃÂ³n de documentos.
	--**************************************************************

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vFechaReg, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vMensValid, vTipoServicio, vStatusToken,vSolicitud,vCargoTot,vCorreo,vCelular;
        END IF;
    END EXCEPTION;
	
		SELECT telefono INTO vCelular FROM bdinteg:si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel= 2 AND status_tel='A';
		IF vCelular IS NULL THEN
			LET vCelular='';
		END IF;
		SELECT correo_elec INTO vCorreo FROM bdinteg:si_correos WHERE numcte=pNumCte AND tipo_correo= 1 AND status_correo='A';
		IF vCorreo IS NULL THEN
			LET vCorreo = '';
		END IF;
		
		IF pTipo = '2' THEN 
			IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte and tpo_persona = '01') THEN
					IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte ) > 0 THEN
								SELECT bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1,
									 bdi_sicte.nombre2, bdi_sibpi.id_status, bdi_sibpi.suc_registro, bdi_sisuc.nombre, bdi_sibpi.folio_contrato, bdi_sibpi.f_registro::date,
									 bdi_sictepf.fecha_nac, bdi_sibpi.servicio
								INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vFechaReg, vFechaNac,vTipoServicio 
								FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi, bdinteg:si_sucursales bdi_sisuc
								WHERE bdi_sicte.numcte = pNumCte
									AND bdi_sicte.empresa = pEmpresa
									AND bdi_sicte.tpo_persona = '01'
									AND bdi_sicte.numcte = bdi_sictepf.numcte
									AND bdi_sicte.numcte = bdi_sibpi.numcte
									AND bdi_sibpi.suc_registro = bdi_sisuc.sucursal;
								 
								IF vStatus = '0' OR  vStatus = '88' OR  vStatus = '99' THEN 
									LET vCodRet =  '003';
									LET vMensValid = 'Este cliente tiene el servicio de banca por Internet cancelado, bloqueado o pre-activaciÃÂ³n incompleta';
								ELIF (SELECT count(status_destino) FROM si_bpicatcambiostatus WHERE Proceso = pTipo AND status_origen = vStatus ) = 0  THEN
									IF  EXISTS (SELECT mensaje FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus) 										THEN
										SELECT mensaje INTO vMensValid FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = 										vStatus;
								ELSE
									LET vCodRet = '-002';
									LET vMensValid = 'El cliente tiene un estatus invÃÂ¡lido para el servicio';
								END IF;

							END IF;	 
					ELSE
							SELECT mensaje INTO vMensValid FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
							LET vCodRet = '004';
					END IF		
									  
			ELSE
					SELECT tpo_persona INTO vTipoPersona FROM bdinteg:si_cliente WHERE numcte = pNumcte;
					IF vTipoPersona = '02' THEN
							LET vCodRet = '002';						
							LET vMensValid = 'Cliente Moral, verifique';
						
					ELSE
							LET vCodRet =   '001';
    						LET vMensValid = 'Cliente no Existe';							

				   END IF;
			END IF;
		ELIF pTipo = '1' THEN
		
			select solicitud into vSolicitud from bdibpi:bpi_tokensolicitud  where numcte = pNumCte and f_solicitud = 
           (select max(f_solicitud) from bdibpi:bpi_tokensolicitud  where numcte = pNumCte);
		   
		   IF vSolicitud <> ""  THEN
				EXECUTE PROCEDURE  bdibpi:sp_cons_detenvios_token2(pEmpresa,vSolicitud) INTO vCodRet,vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot; 
				
		   END IF;	
			   
		ELIF pTipo = '3' THEN	
			
		--Registra Datos en la bitacora
			insert into si_bpibitacora(fecha_oper,id_operacion,sucursal,id_usuario,ipusuario,fecha_aplic,cuenta_origen)
			values(current,'1019',pSucursal,pIdusuario,pIpusu,date(current),pNumCte);	
			
				
		END IF;	

IF LENGTH(vFolio) >12 THEN
		
        -- Entra a Desencripta folio solo cuando el folio esta encriptado
        EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vFolio) INTO cod_ret, vcCondDesEnc;	
        LET vFolio = vcCondDesEnc;

        
        IF vFolio = TRIM('Valor Nulo') THEN
            LET vFolio = '';
        END IF;   


    RETURN vCodRet, vFechaReg, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vMensValid, vTipoServicio, vStatusToken,vSolicitud,vCargoTot,vCorreo,vCelular;

ELSE

    RETURN vCodRet, vFechaReg, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vMensValid, vTipoServicio, vStatusToken,vSolicitud,vCargoTot,vCorreo,vCelular;
END IF; 


END
END PROCEDURE
DOCUMENT
"Modificado: Hector Juan Casanova Edeza",
"Proyecto: BPI",
"Solicito: Ismael Hernandez",
"Descripcion: se modifica el formato de casteo del campo fecha registro al formato  MM/DD/AAAA.",
"Fecha: 2010/10/15",
"Version: 20101015.1642",
'',
"Modificado: Edgar Ivan Rochin Rocha",
"Proyecto: BPI",
"Solicito: Ismael Hernandez",
"Descripcion: se modifico para que regrese el nombre de la sucursal.",
"Fecha: 2010/11/04",
"Version: 2010/11/04.1648",
"Se modifica el insert para registro en la bitacora, cambiando el id_oper",
"Fecha: 30-07-2012";

CREATE PROCEDURE "informix".sp_obthuellasactes2(pNumCteCorr CHAR(20), pNumCteInc CHAR(20))
	RETURNING
	CHAR(6) 	AS 	cCodRet,
	CHAR(942)	AS	cTrama,
	CHAR(942)	AS	cTrama2,
	CHAR(942)	AS	cTramaInc,
	CHAR(942)	AS	cTramaInc2;


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    
	DEFINE cTrama	    	CHAR(942);
	DEFINE cTrama2	    	CHAR(942);
	DEFINE cTramaInc    	CHAR(942);
	DEFINE cTramaInc2    	CHAR(942);
	DEFINE cTipoCte	    	CHAR(1);
	DEFINE cTipoCte2    	CHAR(1);
	DEFINE cSecTitular    	CHAR(2);
	DEFINE cSecInco	    	CHAR(2);
	DEFINE cTicket1	    	CHAR(20);
	DEFINE cTicket2	    	CHAR(20);
	DEFINE cTicket3	    	CHAR(20);
	DEFINE iNumCte	    	INTEGER;
	DEFINE ibandera	    	INTEGER;

    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	
	LET cTrama				= '';
	LET cTrama2				= '';
	LET cTramaInc			= '';
	LET cTramaInc2			= '';
	LET cTipoCte			= '';
	LET cTipoCte2			= '';
	LET cSecTitular    		= '';
	LET cSecInco	    	= '';
	LET cTicket1	    	= '';
	LET cTicket2	    	= '';
	LET cTicket3	    	= '';
	LET iNumCte	    		= 0;
	LET ibandera	    	= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_obthuellasactes2.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF NVL(pNumCteCorr,'') = '' OR NVL(pNumCteInc,'') = '' THEN
		LET cCodRet = '000001';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	END IF
	
	--VALIDA QUE SEAN TITULARES AMBOS CLIENTES.
	SELECT tipo_cliente
	INTO cTipoCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteCorr;
	
	IF NVL(cTipoCte,'') = '' THEN -- CLIENTE CORRECTO NO EXISTE
		LET cCodRet = '000002';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	END IF;
		
	SELECT tipo_cliente
	INTO cTipoCte2
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteInc;
	
	IF NVL(cTipoCte2,'') = '' THEN --CLIENTE INCORRECTO NO EXISTE
		LET cCodRet = '000003';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	ELSE
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TITULAR
		SELECT dmapa, imapa, secuencia
		INTO cTrama, cTrama2, cSecTitular
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteCorr
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteCorr);		
		
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TRASPASAR
		SELECT dmapa, imapa, secuencia
		INTO cTramaInc, cTramaInc2, cSecInco
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteInc
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteInc);
		
		--VALIDA QUE LA SECUENCIA EXISTA EN LA CONSULTA A LA TABLA "si_cte_huella" SINO, REGRESA UN CODIGO DE RETORNO
		IF cSecTitular <> '' THEN
			SELECT ticket
			INTO cTicket1
			FROM bdinteg:"informix".si_huella_linea
			WHERE numcte = pNumCteCorr
			AND secuencia = cSecTitular;
			
			IF NVL(cTicket1,'') = '' THEN
				SELECT ticket
				INTO cTicket2
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE numcte = pNumCteCorr
				AND secuencia = cSecTitular
				AND fecha_consulta = (SELECT MAX (fecha_consulta)
									  FROM bdinteg:"informix".si_huella_linea_hist
									  WHERE numcte = pNumCteCorr
									  AND secuencia = cSecTitular);
									  
				IF cTicket2 = '' THEN
					LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
					RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
				END IF;
			END IF;
		END IF;
		
		
		--SE CONSULTA EL NUMERO DE CLIENTE PARA VER SI SE REALIZO LA COMPARACIÃÂ DE HUELLA EXITOSA EN SUCURSAL SINO SE MANDA CODIGO DE EXITO
		IF cTicket1 <> '' THEN
			LET cTicket3 = cTicket1;
		ELIF cTicket2 <> '' THEN
			LET cTicket3 = cTicket2;
		ELSE
			LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
		END IF;	
		
		
			SELECT LIMIT 1 cliente
			INTO iNumCte
			FROM bdinteg:"informix".si_huella_linea_resultado
			WHERE estado_proceso = '2'
			AND cliente = pNumCteInc
			AND ticket = cTicket3
			AND empresa  = '5'
			AND num_mensaje = '602';
			--AND secuencia = cSecInco; -- ESTA LINEA SE ACTIVARA CUANDO LO DE SUCURSAL YA ESTE
										-- FUNCIONANDO,ES DECIR, CUANDO EL VALOR DE LA SECUENCIA SE ESTE
										-- GUARDANDO EN LAS TABLAS.

			IF NOT iNumCte > 0 THEN
                SELECT LIMIT 1 cliente
                INTO iNumCte
                FROM bdinteg:"informix".si_huella_linea_resultado_hist
                WHERE estado_proceso = '2'
                AND cliente = pNumCteInc
                AND ticket = cTicket3
                AND empresa  = '5'
                AND num_mensaje = '602';
            END IF;    
		
			IF iNumCte > 0 THEN
				LET cCodRet = '000006';  --Los clientes consultados ya tuvieron la comparaciÃ³Â®Â Â¤e huellas
			END IF;
	END IF;
	
	RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));		
END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/08/2022',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusion Manual de Clientes',
'DESCRIPCION: Se crea procedimiento el cual consulta la tabla si_cte_huella para traer la informacion de la huella derecha e izquierda del cliente por su maxima secuencia',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_datos_contacto_bpi(pEmpresa CHAR(3),pIdUsuario CHAR(11))
RETURNING CHAR (5);
	-- Creador: Solser
	-- Objetivo: Validar datos de contacto de  usuario BPI
	-- Fecha: 03/01/2022
	
	DEFINE sql_err int;
	DEFINE vCodRet CHAR (5);
    DEFINE vNumCliente CHAR (9);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet ;
		  END IF ;
		END EXCEPTION ;
		
		LET vCodRet = '00000';
        LET vNumCliente = '';
       
		
		SET LOCK MODE TO WAIT 3;
        
        IF(LENGTH(TRIM(NVL(pEmpresa,''))) = 0  OR  LENGTH(TRIM(NVL(pIdUsuario,''))) = 0)THEN
            LET vCodRet="00003";
            RETURN vCodRet;
        END IF;

      

        SELECT numcliente INTO vNumCliente FROM bdibpi:bpi_usuario where id_usuario= pIdUsuario and st_portal = 'activo';     
        IF (vNumCliente <> '' OR vNumCliente IS NOT NULL) THEN
           
             	IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = vNumCliente 	AND status_tel ='A' AND tipo_tel=2) = 0 THEN 
                    LET vCodRet="00001";
                ELIF (SELECT count(correo_elec) FROM bdinteg:"informix".si_correos WHERE numcte = vNumCliente AND status_correo = 'A') = 0 THEN 
                    LET vCodRet="00002";
                END IF
        ELSE
             LET vCodRet="00004";
        END IF;
                 
     
         
		RETURN vCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Solser',
'FECHA.........: 03-01-2022',
'CREACION..: Validación deatos de contacto bpi',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDInteg';

CREATE PROCEDURE "informix".sp_valida_cel_repetido_bpi(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='V'	
	AND (DATE(CURRENT) - DATE(SUBSTR(fecha_hora,0,10)) < 90);
		
	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;